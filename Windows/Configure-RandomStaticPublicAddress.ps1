<#
.Synopsis
    Assigns a Static Public IP (EIP) from a list of EIPs.
.Description
    Configure-RandomStaticPublicAddress associates an EIP from a list of provided EIPs to an Instance.
.Parameter EIPs
    Specifies an array of EIPs which can be associated with the Instance.
.Notes
       Author: Michael Crawford
    Copyright: 2018 by DXC.technology
             : Permission to use is granted but attribution is appreciated
#>
[CmdletBinding()]
Param (
    [Parameter(Mandatory=$true)]
    [string[]]$EIPs
)

Try {
    $ErrorActionPreference = "Stop"

    Start-Transcript -Path c:\cfn\log\Configure-RandomStaticPublicAddress.ps1.txt -Append

    # Sanitize allowed EIPs to be used from list passed
    $allowedEIPs = $EIPs | ? { $PSItem -ne 'Null' }

    # Determine current region
    $region = (Invoke-RestMethod http://169.254.169.254/latest/dynamic/instance-identity/document).region

    # Get instance private IP address
    $privateIP = (Test-Connection -ComputerName $env:COMPUTERNAME -Count 1).IPV4Address.IPAddressToString

    # Get assigned EIP addresses
    $assignedEIP = Get-EC2Address -Region $region | ? { $PSItem.PublicIp -in $allowedEIPs -and $PSItem.PrivateIpAddress -eq $privateIP }

    # If assigned print it, Else wait a random time between 1-30 seconds and try associating...
    If ($assignedEIP) {
        Write-Host "Elastic IP already assigned:"
        $assignedEIP
    }
    Else {
        $timer = Get-Random -Minimum 1 -Maximum 31
        Write-Host "Sleeping for $timer seconds"
        Start-Sleep -Seconds $timer
        # Get local instance ID
        $instanceID = Invoke-RestMethod http://169.254.169.254/latest/meta-data/instance-id
        $associated = $false
        $tries = 0
        Do {
            # Get avaiable IPs from allowed EIPs that are not associated already
            $availableEIPs = Get-EC2Address -Region $region | ? { $PSItem.PublicIp -in $allowedEIPs -and $PSItem.PrivateIpAddress -eq $null }
            If ($availableEIPs.Count -gt 0) {
                # Randomly choose one of the available EIPs for assignment
                $randomAvailableEIP = $availableEIPs[(Get-Random -Minimum 0 -Maximum $availableEIPs.Count )]
                Try {
                    # Try to associate the EIP
                    Write-Host "Associating $($randomAvailableEIP.AllocationId): $($randomAvailableEIP.PublicIp)"
                    $associationID = Register-EC2Address -Region $region -AllocationId $randomAvailableEIP.AllocationId -InstanceId $instanceID
                    $associated = $true
                    Write-Host "Successfully associated the Elastic IP"
                }
                Catch {
                    $tries++
                    Write-Host "Failed to associate Elastic IP. Try #$tries"
                }
            }
            Else {
                Throw "[ERROR] No Elastic IPs available for this region from the allowed list: $($allowedEIPs -join ',')"
            }
        } While (-not $associated -and $tries -lt 10)
        If (-not $associated) {
            Throw "[ERROR] Unable to associate Elastic IP after multiple tries."
        }

        $confirmed = $false
        $tries = 0
        Do {
            Try {
                # Try to get the associated EIP
                $associatedEIP = Get-EC2Address -Region $region -AllocationId $randomAvailableEIP.AllocationId
            }
            Catch {
                Write-Host "Error fetching associated Elastic IP."
            }
            # Confirm that it is associated with this instance
            If ($associatedEIP.InstanceId -eq $instanceID) {
                $confirmed = $true
                Write-Host "Confirmed the Elastic IP association:"
                $associatedEIP
            }
            Else {
                $tries++
                Write-Host "Failed to confirm associated Elastic IP. Try#$tries"
                Start-Sleep -Seconds 3
            }
        } While (-not $confirmed -and $tries -lt 40)
        If (-not $confirmed) {
            Throw "[ERROR] Unable to confirm Elastic IP after multiple tries."
        }
    }
}
Catch {
    $_ | Send-CloudFormationFailure
}
