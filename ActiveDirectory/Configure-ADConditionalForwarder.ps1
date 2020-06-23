<#
.Synopsis
    Creates an ActiveDirectory Conditional Forwarder.
.Description
    Configure-ADConditionalForwarder configures an Active Directory Conditional Forwarder.
.Notes
       Author: Michael Crawford
    Copyright: 2018 by DXC.technology
             : Permission to use is granted but attribution is appreciated
#>
[CmdletBinding()]
Param (
    [Parameter(Mandatory=$true)]
    [string]$ForwardDomainName,

    [Parameter(Mandatory=$true)]
    [string]$DNSAddress1,

    [Parameter(Mandatory=$false)]
    [string]$DNSAddress2,

    [Parameter(Mandatory=$false)]
    [ValidateSet('Domain','Forest')]
    [string]$ReplicationScope = 'Domain'
)

Try {
    Write-Host
    Write-CloudFormationHost "Creating a Conditional Forwarder"

    Add-DnsServerConditionalForwarderZone -Name $ForwardDomainName `
                                          -MasterServers $(If (!$DNSAddress2) {@($DNSAddress1)} Else {@($DNSAddress1,$DNSAddress2)}) `
                                          -ReplicationScope $ReplicationScope

    Write-CloudFormationHost "Conditional Forwarder created"
}
catch {
    $_ | Send-CloudFormationFailure
}
