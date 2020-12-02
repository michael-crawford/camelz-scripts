<#
.Synopsis
    Configures Active Directory DNS to work with AWS DNS.
.Description
    Configure-ADDNS configures Active Directory DNS to work with AWS DNS, including
    these actions:
    - Creates a Reverse Lookup Zone.
    - Creates a PTR Record for the first Domain Controller.
    - Creates a Conditional Forwarder to the VPC's Route53 Private HostedZone.
.Parameter VpcCidr
    Specifies VPC CIDR Block.
.Parameter PrivateDomainName
    Specifies the Route53 Private Domain Name associated with the VPC.
.Example
    Configure-ADDNS -VpcCidr 172.21.24.0/21 `
                    -PrivateDomainName d.hlsb.dxcanalytics.com
    Configures Active Directory for the Stable Development Environment VPC.
.Notes
       Author: Michael Crawford
    Copyright: 2018 by DXC.technology
             : Permission to use is granted but attribution is appreciated

    This script assumes it is running on the Primary Domain Controller in Zone A,
    the hostname has been set, and Domain Services have been installed.
#>
[CmdletBinding()]
Param (
    [Parameter(Mandatory=$true)]
    [string]$VpcCidr,

    [Parameter(Mandatory=$true)]
    [string]$PrivateDomainName
)

Write-Host

Write-Verbose "Calculating Parameters"

$DirectoryDomainName = (Get-WmiObject Win32_ComputerSystem).Domain
$DomainControllerAHostName = $Env:ComputerName
$DomainControllerAPrivateIp = Invoke-RestMethod http://169.254.169.254/latest/meta-data/local-ipv4

$VpcAddress = $VpcCidr.Split('/')[0]
$VpcNetmask = $VpcCidr.split('/')[1]
$VpcOctets = $VpcAddress.split('.')
$VpcDnsAddress = $VpcOctets[0] + '.' + $VpcOctets[1] + '.' + $VpcOctets[2] + '.' + $([Int]$VpcOctets[3] + 2)

$DomainControllerAFQDN = $DomainControllerAHostName + '.' + $DirectoryDomainName
$DomainControllerAOctets = $DomainControllerAPrivateIp.split('.')

If ([Int]$VpcNetmask -LT 24) {
    $VpcReverseNetworkID = $VpcOctets[0] + '.' + $VpcOctets[1] + '.0.0/16'
    $VpcReverseZoneName = $VpcOctets[1] + '.' + $VpcOctets[0] + '.in-addr.arpa'
    $DomainControllerAPTR = $DomainControllerAOctets[3] + '.' + $DomainControllerAOctets[2]
}
Else {
    $VpcReverseNetworkID = $VpcOctets[0] + '.' + $VpcOctets[1] + '.' + $VpcOctets[2] + '.0/24'
    $VpcReverseZoneName = $VpcOctets[2] + '.' +$VpcOctets[1] + '.' + $VpcOctets[0] + '.in-addr.arpa'
    $DomainControllerAPTR = $DomainControllerAOctets[3]
}

Try {
    Try {
        Write-Verbose "Creating Reverse Lookup Zone"

        Add-DnsServerPrimaryZone -NetworkID $VpcReverseNetworkID `
                                 -ReplicationScope Domain

        Write-CloudFormationHost "Reverse Lookup Zone created"
    }
    Catch {
        Throw "Conditional Forwarder could not be created, Error: $($_.Exception.Message)"
    }

    Try {
        Write-Verbose "Creating Domain Controller A PTR Record"

        Add-DnsServerResourceRecordPtr -Name $DomainControllerAPTR `
                                       -ZoneName $VpcReverseZoneName `
                                       -PtrDomainName $DomainControllerAFQDN

        Write-CloudFormationHost "Domain Controller A PTR record created"
    }
    Catch {
        Throw "Domain Controller A PTR record could not be created, Error: $($_.Exception.Message)"
    }

    Try {
        Write-Verbose "Creating Conditional Forwarder to AWS Private HostedZone $PrivateDomainName"

        Add-DnsServerConditionalForwarderZone -Name $PrivateDomainName `
                                              -MasterServers @($VpcDnsAddress) `
                                              -ReplicationScope Domain
        Write-CloudFormationHost "Conditional Forwarder to AWS Private HostedZone $PrivateDomainName created"
    }
    Catch {
        Throw "Conditional Forwarder could not be created, Error: $($_.Exception.Message)"
    }
}
catch {
    $_ | Send-CloudFormationFailure
}
