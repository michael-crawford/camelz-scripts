<#
.Synopsis
    Associates an Elastic IP with an Instance.
.Description
    Associate-EIP associates an Elastic IP with an Instance. It handles a situation where
    multiple EIPs exist per Availablity Zone.
.Notes
       Author: Michael Crawford
    Copyright: 2018 by DXC.technology
             : Permission to use is granted but attribution is appreciated
#>
[CmdletBinding()]
Param (
    [string]$EIPAAllocationId,

    [string]$EIPBAllocationId,

    [string]$EIPCAllocationId,

    [string]$EIPDAllocationId,

    [string]$EIPEAllocationId,

    [string]$EIPFAllocationId
)

Try {
    $ErrorActionPreference = "Stop"

    $Zone = Invoke-RestMethod http://169.254.169.254/latest/meta-data/placement/availability-zone
    $Region = $Zone.Substring(0,$Zone.Length-1)
    $ZoneCode = $Zone.Substring($Zone.Length-1,1)
    $InstanceId = Invoke-RestMethod http://169.254.169.254/latest/meta-data/instance-id

    Switch ($ZoneCode) {
        "a" { $AllocationId = $EIPAAllocationId }
        "b" { $AllocationId = $EIPBAllocationId }
        "c" { $AllocationId = $EIPCAllocationId }
        "d" { $AllocationId = $EIPDAllocationId }
        "e" { $AllocationId = $EIPEAllocationId }
        "f" { $AllocationId = $EIPFAllocationId }
    }

    Write-Host
    Write-CloudFormationHost "Associating EIP $AllocationId with instance $InstanceId"

    $Association = Register-EC2Address -AllocationId $AllocationId -InstanceId $InstanceId -Region $Region
}
Catch {
    $_ | Send-CloudFormationFailure
}

Start-Sleep 1
