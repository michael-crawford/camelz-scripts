<#
.Synopsis
    Creates a new Active Directory forest
.Description
    Install-ADDSForest creates a new Active Directory Forest.
    This exists as a separate script mainly so we can obtain Secrets via SecretsManager, as that is
    not currently possible directly within cfn-init logic.
.Parameter DomainName
    Specifies the domain to use for the initial domain of the forest
.Parameter DomainNetbiosName
    Specifies the NetBIOS domain for the initial domain of the forest
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

    [Parameter(Mandatory=$true)]
    [string]$DomainNetbiosName,

    [Parameter(Mandatory=$false)]
    [string]$SafeModeSecretId = "",

    [Parameter(Mandatory=$false)]
    [string]$SafeModePassword = ""
)

Write-Host
Write-CloudFormationHost "Creating a new Forest with Domain $DomainName and NetBIOS Domain $DomainNetbiosName"

Try {
    $ErrorActionPreference = "Stop"

    If ($SafeModeSecretId) {
      $SafeModeSecretString = Get-SECSecretValue -SecretId $SafeModeSecretId | Select -ExpandProperty SecretString
      $SafeModePassword = $SafeModeSecretString | ConvertFrom-Json | Select -ExpandProperty password
    }

    If (-Not $SafeModePassword) {
      Throw "SafeModePassword not found"
    }

    $SecureSafeModePassword = ConvertTo-SecureString "$SafeModePassword" -AsPlainText -Force

    Install-ADDSForest -ForestMode Win2012R2 -DomainMode Win2012R2 -Confirm:$false -Force `
                       -DomainName $DomainName -DomainNetbiosName $DomainNetbiosName `
                       -SafeModeAdministratorPassword $SecureSafeModePassword
    Write-CloudFormationHost "Forest $DomainName created"
}
Catch {
    $_ | Send-CloudFormationFailure
}

Start-Sleep 1
