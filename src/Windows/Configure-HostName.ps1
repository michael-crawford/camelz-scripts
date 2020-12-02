<#
.Synopsis
    Configures the Hostname.
.Description
    Configure-Hostname configures the hostname, optionally appending a Zone Code
    determined by which zone contains the instance.
.Parameter HostName
    Specifies the hostname to be configured on the Instance.
    The default is 'Admin'.
.Parameter AppendZone
    Indicates a Zone letter should be appended to the HostName, based on the Availability Zone
    where the Instance is running.
.Notes
       Author: Michael Crawford
    Copyright: 2018 by DXC.technology
             : Permission to use is granted but attribution is appreciated
#>
[CmdletBinding()]
Param (
    [Parameter(Position=1, Mandatory=$true)]
    [string]$HostName,

    [switch]$AppendZone
)

Try {
    $ErrorActionPreference = "Stop"

    $Zone = Invoke-RestMethod http://169.254.169.254/latest/meta-data/placement/availability-zone
    $Region = $Zone.Substring(0,$Zone.Length-1)
    $ZoneCode = $Zone.Substring($Zone.Length-1,1)

    if ($AppendZone ) {
        $HostName = $HostName + $ZoneCode
    }

    Write-Host
    Write-CloudFormationHost "Renaming Computer to $HostName"

    Rename-Computer -NewName $HostName
    Write-CloudFormationHost "Computer renamed to $HostName, restarting..."

    Restart-Computer
}
Catch {
    $_ | Send-CloudFormationFailure
}
