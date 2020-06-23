<#
.Synopsis
    Updates the Domain Controller DNS Servers.
.Description
    Update-DNSServers updates both Domain Controllers to use both DomainController DNS Servers.
.Parameter DomainControllerAHostName
    Specifies the hostname of the Domain Controller in Zone A.
.Parameter DomainControllerAPrivateIp
    Specifies the private IP Address of the Domain Controller in Zone A.
.Parameter DomainName
    Specifies the domain to which DNS Changes are made.
.Parameter SecretId
    Specifies the Id of a SecretsManager Secret containing the User Name and Password for the user account.
.Parameter UserName
    Specifies a user account that has permission to modify DNS.
    The default is 'Admin'.
.Parameter Password
    Specifies the password for the user account.
    Avoid using this method if possible - it's more secure to have SecretsManager create and store the password.
.Notes
       Author: Michael Crawford, based on AWSQuickStart
    Copyright: 2019 by DXC.technology
             : Permission to use is granted but attribution is appreciated
#>
[CmdletBinding()]
Param (
    [Parameter(Mandatory=$true)]
    [string]$DomainControllerAHostName,

    [Parameter(Mandatory=$true)]
    [string]$DomainControllerAPrivateIp,

    [Parameter(Mandatory=$true)]
    [string]$DomainName,

    [Parameter(Mandatory=$false)]
    [string]$SecretId = "",

    [Parameter(Mandatory=$false)]
    [string]$UserName = "Admin",

    [Parameter(Mandatory=$false)]
    [string]$Password = ""
)

Write-Host
Write-CloudFormationHost "Updating DNS Servers"

Try {
    $ErrorActionPreference = "Stop"

    If ($SecretId) {
      $SecretString = Get-SECSecretValue -SecretId $SecretId | Select -ExpandProperty SecretString
      $UserName = $SecretString | ConvertFrom-Json | Select -ExpandProperty username
      $Password = $SecretString | ConvertFrom-Json | Select -ExpandProperty password
    }

    If (-Not $UserName -Or -Not $Password) {
      Throw "UserName and/or Password not found"
    }

    $SecurePassword = ConvertTo-SecureString "$Password" -AsPlainText -Force
    $Credential = New-Object System.Management.Automation.PSCredential("$UserName@$DomainName", $SecurePassword)

    $DomainControllerBPrivateIP = Invoke-RestMethod http://169.254.169.254/latest/meta-data/local-ipv4

    # Locally update DomainControllerB DNS Servers
    Get-NetAdapter | Set-DnsClientServerAddress -ServerAddresses $DomainControllerBPrivateIp,$DomainControllerAPrivateIp
    Write-CloudFormationHost 'Updated DNS Servers on Domain Controller B'

    # Remotely update DomainControllerA DNS Servers
    Invoke-Command -Scriptblock { param($DomainControllerAPrivateIp, $DomainControllerBPrivateIP) Get-NetAdapter | Set-DnsClientServerAddress -ServerAddresses $DomainControllerAPrivateIp,$DomainControllerBPrivateIP } -ArgumentList $DomainControllerAPrivateIp, $DomainControllerBPrivateIp -ComputerName $DomainControllerAHostName -Credential $Credential
    Write-CloudFormationHost 'Updated DNS Servers on Domain Controller A'
}
Catch {
    $_ | Send-CloudFormationFailure
}

Start-Sleep 1
