<#
.Synopsis
Configures Active Directory Sites, including a Site Link.
.Description
Configure-ADSites changes the name of the default Site to ZoneA, then optionally
creates a second site for ZoneB, along with a Site Link.
groups.
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
    Write-CloudFormationHost "Configuring Sites"

    Try {
        Get-ADObject -SearchBase (Get-ADRootDSE).ConfigurationNamingContext -filter {Name -eq 'Default-First-Site-Name'} | Rename-ADObject -NewName ZoneA
        Write-CloudFormationHost "Site Default-First-Site-Name renamed to ZoneA"
    }
    Catch {
        Throw "Site Default-First-Site-Name could not be renamed to ZoneA, Error: $($_.Exception.Message)"
    }

    If ($MultiZone) {
        Try {
            New-ADReplicationSite ZoneB
            Write-CloudFormationHost "Site ZoneB created"
        }
        Catch {
            Throw "Site ZoneB could not be created, Error: $($_.Exception.Message)"
        }

        Write-CloudFormationHost "Configuring SiteLink"

        Try {
            Get-ADObject -SearchBase (Get-ADRootDSE).ConfigurationNamingContext -filter {Name -eq 'DEFAULTIPSITELINK'} | Rename-ADObject -NewName 'ZoneA-ZoneB'
            Write-CloudFormationHost "SiteLink DEFAULTIPSITELINK renamed to ZoneA-ZoneB"
        }
        Catch {
            Throw "SiteLink DEFAULTIPSITELINK could not be renamed to ZoneA-ZoneB, Error: $($_.Exception.Message)"
        }

        Try {
            Get-ADReplicationSiteLink -Filter {SitesIncluded -eq "ZoneA"} | Set-ADReplicationSiteLink -SitesIncluded @{add='ZoneB'} -ReplicationFrequencyInMinutes 15 -Replace @{'options'=1}
            Write-CloudFormationHost "SiteLink ZoneA-ZoneB configured"
        }
        Catch {
            Throw "SiteLink ZoneA-ZoneB could not be configured, Error: $($_.Exception.Message)"
        }
    }
}
Catch {
    $_ | Send-CloudFormationFailure
}

Start-Sleep 1
