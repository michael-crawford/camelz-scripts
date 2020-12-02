<#
.Synopsis
    Creates Active Directory Domain Aliases
.Description
    Configure-ADDomainAliases reads a CSV file containing Active Directory Domain Aliases and HostNames
    to create a set of DNS CName records within the DNS zone associated with the Domain Controller where this script is run.
.Parameter DomainName
    Specifies the domain for the user account.
.Parameter SecretId
    Specifies the Id of a SecretsManager Secret containing the User Name and Password for the user account.
.Parameter UserName
    Specifies a user account that has permission to add aliases to the domain.
    The default is 'Admin'.
.Parameter Password
    Specifies the password for the user account.
    Avoid using this method if possible - it's more secure to have SecretsManager create and store the password.
.Parameter DomainAliasesPath
    Specifies the path to the Domain Aliases input CSV file.
    The default value is '.\Aliases.csv'.
.Parameter DirectoryService
    Indicates use of the AWS DirectoryService.
.Example
    Configure-ADDomainAliases -DomainName m1.dxc-ap.com `
                              -SecretId Production-DirectoryService-Administrator
    Creates Domain Aliases using the default ./DomainAliases.csv file using a password stored in SecretsManager.
.Example
    Configure-ADDomainAliases -DomainName m1.dxc-ap.com `
                              -UserName Admin -Password <Password> `
                              -DomainAliasesPath 'C:\cfn\temp\CustomDomainAliases.csv'
    Creates Domain Aliases using a custom CSV file using an explicitly passed password.
.Notes
       Author: Michael Crawford
    Copyright: 2019 by DXC.technology
             : Permission to use is granted but attribution is appreciated
#>
[CmdletBinding()]
Param (
    [Parameter(Mandatory=$true)]
    [string]$DomainName,

    [Parameter(Mandatory=$false)]
    [string]$SecretId = "",

    [Parameter(Mandatory=$false)]
    [string]$UserName = "Admin",

    [Parameter(Mandatory=$false)]
    [string]$Password = "",

    [Parameter(Mandatory=$false)]
    [string]$DomainAliasesPath = ".\DomainAliases.csv",

    [switch]$DirectoryService
)

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

    $SecurePassword = ConvertTo-SecureString -String "$Password" -AsPlainText -Force
    $Credential = New-Object System.Management.Automation.PSCredential("$UserName@$DomainName", $SecurePassword)

    $DistinguishedName = (Get-ADDomain -Current LocalComputer -Credential $Credential).DistinguishedName
    $DNSRoot = (Get-ADDomain -Current LocalComputer -Credential $Credential).DNSRoot
    $NetBIOSName = (Get-ADDomain -Current LocalComputer -Credential $Credential).NetBIOSName
    $DomainController = (Get-ADDomainController -Credential $Credential).HostName

    $Aliases = @()
    If (Test-Path $DomainAliasesPath) {
       $Aliases = Import-CSV $DomainAliasesPath
    }
    Else {
       Throw  "-DomainAliasesPath $DomainAliasesPath is invalid."
    }

    Write-Host
    Write-CloudFormationHost "Adding Domain Aliases"

    ForEach ($Alias In $Aliases) {
        Try {
            If (Get-DnsServerResourceRecord -RRType "CName" -Name $($Alias.Alias) -ZoneName $DNSRoot -ErrorAction "SilentlyContinue") {
                Write-Verbose "Alias $($Alias.Alias) exists"
            }
            Else {
                Write-Verbose "Alias $($Alias.Alias) does not exist"
                If ($($Alias.HostName -match '.+?\\$')) {
                    $HostNameAlias = $($Alias.HostName).$($DNSRoot)
                }

                Add-DnsServerResourceRecordCName -Name $($Alias.Alias) `
                                                 -HostNameAlias "$($Alias.HostName).$($DNSRoot)" `
                                                 -ZoneName $DNSRoot
                Write-CloudFormationHost "Alias $($Alias.Alias) -> $($Alias.HostName).$($DNSRoot) created"
            }
        }
        Catch {
            Write-CloudFormationWarning "Alias $($Alias.Alias) could not be created, Error: $($_.Exception.Message)"
        }
    }
}
Catch {
    $_ | Send-CloudFormationFailure
}

Start-Sleep 1
