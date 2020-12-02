<#
.Synopsis
    Installs a Domain Controller in an existing Active Directory Domain
.Description
    Install-ADDSDomainController installs an Active Directory Domain Controller to an existing Domain.
    This exists as a separate script mainly so we can obtain Secrets via SecretsManager, as that is
    not currently possible directly within cfn-init logic.
.Parameter DomainName
    Specifies the domain to which the controller is added
.Parameter SecretId
    Specifies the Id of a SecretsManager Secret containing the User Name and Password for the user account.
.Parameter UserName
    Specifies a user account that has permission to add domain controllers to an existing domain.
    The default is 'Admin'.
.Parameter Password
    Specifies the password for the user account.
    Avoid using this method if possible - it's more secure to have SecretsManager create and store the password.
.Parameter SafeModeSecretId
    Specifies the Id of a SecretsManager Secret containing the Safe Mode Administrator Password.
.Parameter SafeModePassword
    Specifies the Safe Mode Administrator Password.
    Avoid using this method if possible - it's more secure to have SecretsManager create and store the password.
.Notes
       Author: Michael Crawford
    Copyright: 2019 by DXC.technology
             : Permission to use is granted but attribution is appreciated
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true)]
    [string]$DomainName,

    [Parameter(Mandatory=$false)]
    [string]$SecretId = "",

    [Parameter(Mandatory=$false)]
    [string]$UserName = "Admin",

    [Parameter(Mandatory=$false)]
    [string]$Password = "",

    [Parameter(Mandatory=$false)]
    [string]$SafeModeSecretId = "",

    [Parameter(Mandatory=$false)]
    [string]$SafeModePassword = ""
)

Write-Host
Write-CloudFormationHost "Adding Domain Controller to Domain $DomainName"

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

    If ($SafeModeSecretId) {
      $SafeModeSecretString = Get-SECSecretValue -SecretId $SafeModeSecretId | Select -ExpandProperty SecretString
      $SafeModePassword = $SafeModeSecretString | ConvertFrom-Json | Select -ExpandProperty password
    }

    If (-Not $SafeModePassword) {
      Throw "SafeModePassword not found"
    }

    $SecureSafeModePassword = ConvertTo-SecureString "$SafeModePassword" -AsPlainText -Force

    Install-ADDSDomainController -InstallDns -Confirm:$false -Force `
                                 -DomainName $DomainName -Credential $Credential `
                                 -SafeModeAdministratorPassword $SecureSafeModePassword
    Write-CloudFormationHost "Domain Controller $env:ComputerName added to Domain $DomainName"
}
Catch {
    $_ | Send-CloudFormationFailure
}

Start-Sleep 1
