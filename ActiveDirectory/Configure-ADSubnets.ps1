<#
.Synopsis
Configures Active Directory Subnets, associated within Sites
.Description
Configure-ADSubnets by obtaining subnets per availability zone from the AWS API,
and then creating them within the appropriate Site.
.Parameter VpcId
Specifies the VPC ID
.Parameter MultiZone
Indicates multi-zone should be configured.
.Notes
    Author: Michael Crawford
 Copyright: 2018 by DXC.technology
          : Permission to use is granted but attribution is appreciated
#>
[CmdletBinding()]
Param (
    [Parameter(Position=0, Mandatory=$true)]
    [string]$VpcId,

    [switch]$MultiZone
)

Try {
    Write-Host
    Write-CloudFormationHost "Configuring Subnets"

    Write-Verbose "Obtaining Region"
    $Zone = Invoke-RestMethod http://169.254.169.254/latest/meta-data/placement/availability-zone
    $Region = $Zone.Substring(0,$Zone.Length-1)
    $ZoneCode = $Zone.Substring($Zone.Length-1,1)

    Write-Verbose "Validate Zones"
    If ($ZoneCode -ne "a") {
        Throw "This script is not running on an Intance in $($Region)a"
    }
    $ZoneA = $Region + "a"
    $ZoneB = $Region + "b"

    Try {
        Write-Verbose "Adding ZoneA Subnets to Site ZoneA"
        Get-EC2Subnet -Filter @( @{Name = 'vpc-id'; Values = $VpcId}; @{Name = 'availabilityZone'; Values = $ZoneA} ) |
        Select-Object CidrBlock, @{Name="Description";Expression={$_.tags | where key -eq "Name" | select Value -expand Value}} |
        ForEach-Object { New-ADReplicationSubnet -Name $_.CidrBlock -Description $_.Description -Location $Region -Site ZoneA }
        Write-CloudFormationHost "ZoneA Subnets added to to Site ZoneA"
    }
    Catch {
        Throw "ZoneA Subnets could not be added to Site, Error: $($_.Exception.Message)"
    }

    Try {
        If ($MultiZone) {
            Write-Verbose "Adding ZoneB Subnets to Site ZoneB"
            Get-EC2Subnet -Filter @( @{Name = 'vpc-id'; Values = $VpcId}; @{Name = 'availabilityZone'; Values = $ZoneB} ) |
            Select-Object CidrBlock, @{Name="Description";Expression={$_.tags | where key -eq "Name" | select Value -expand Value}} |
            ForEach-Object { New-ADReplicationSubnet -Name $_.CidrBlock -Description $_.Description -Location $Region -Site ZoneB }
            Write-CloudFormationHost "ZoneB Subnets added to to Site ZoneB"
        }
        Else {
            Write-Verbose "Adding ZoneB Subnets to Site ZoneA"
            Get-EC2Subnet -Filter @( @{Name = 'vpc-id'; Values = $VpcId}; @{Name = 'availabilityZone'; Values = $ZoneB} ) |
            Select-Object CidrBlock, @{Name="Description";Expression={$_.tags | where key -eq "Name" | select Value -expand Value}} |
            ForEach-Object { New-ADReplicationSubnet -Name $_.CidrBlock -Description $_.Description -Location $Region -Site ZoneA }
            Write-CloudFormationHost "ZoneB Subnets added to to Site ZoneA"
        }
    }
    Catch {
        Throw "ZoneB Subnets could not be added to Site, Error: $($_.Exception.Message)"
    }
}
Catch {
    $_ | Send-CloudFormationFailure
}

Start-Sleep 1
