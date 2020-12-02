<#
.Synopsis
    Converts the reserved DHCP Dynamic Private Address to a Static Private Address.
.Description
    Configure-StaticPrivateAddress obtains an Instance's current Private Address, which once assigned is permanent within the VPC, but considered
    a Dynamic Address within Windows, and converts this into a Static Address within Windows.
.Notes
       Author: Michael Crawford
    Copyright: 2018 by DXC.technology
             : Permission to use is granted but attribution is appreciated
#>
[CmdletBinding()]
Param (
    [Parameter(Position=0, Mandatory=$false)]
    [string]$DNSServerAddress
)

Write-Host
Write-CloudFormationHost "Configuring Static Private Address"

If (!$DNSServerAddress) {
    $DNSServerAddress = (Get-NetIPConfiguration).DNSServer.ServerAddresses
}

$netip = Get-NetIPConfiguration
$ipconfig = Get-NetIPAddress | ?{$_.IpAddress -eq $netip.IPv4Address.IpAddress}
Get-NetAdapter | Set-NetIPInterface -DHCP Disabled
Get-NetAdapter | New-NetIPAddress -AddressFamily IPv4 -IPAddress $netip.IPv4Address.IpAddress -PrefixLength $ipconfig.PrefixLength -DefaultGateway $netip.IPv4DefaultGateway.NextHop
Get-NetAdapter | Set-DnsClientServerAddress -ServerAddresses $DNSServerAddress
