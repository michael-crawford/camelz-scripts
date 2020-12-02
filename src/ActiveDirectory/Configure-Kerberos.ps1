<#
.Synopsis
    Configures Kerberos.
.Description
    Configures-Kerberos configures Kerberos TODO: Improve this description.
.Parameter DomainName
    Specifies the domain to which the computers are added.
.Parameter PrivateDomainName
    Specifies the domain to which the computers are added.
.Parameter SecretId
    Specifies the Id of a SecretsManager Secret containing the User Name and Password of a user account that has
    permission to join the computers to a new domain.
.Parameter UserName
    Specifies a user account that has permission to join the computers to a new domain.
    The default is 'Admin'.
.Parameter Password
    Specifies the password for the user account.
    Avoid using this method if possible - it's more secure to have SecretsManager create and store the password.
.Parameter DomainName
    Specifies the domain to which the computers are added.
.Notes
       Author:
    Copyright: 2019 by DXC.technology
             : Permission to use is granted but attribution is appreciated
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true)]
    [string]$DomainName,

    [Parameter(Mandatory=$true)]
    [string]$PrivateDomainName,

    [Parameter(Mandatory=$false)]
    [string]$SecretId = "",

    [Parameter(Mandatory=$false)]
    [string]$UserName = "Admin",

    [Parameter(Mandatory=$false)]
    [string]$Password = "",

    [Parameter(Mandatory=$false)]
    [string]$EncryptionType = "AES256-CTS-HMAC-SHA1-96"
)

Write-Host
Write-CloudFormationHost "Creating Kerberos trust between $($PrivateDomainName.ToUpper()) and $DomainName"

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

    $KerberosRealm = $PrivateDomainName.ToUpper()
    ksetup /addkdc $KerberosRealm
    netdom trust $KerberosRealm /Domain:$DomainName /add /realm /passwordt:$SecurePassword
    ksetup /SetEncTypeAttr $KerberosRealm $EncryptionType
}
Catch {
    $_ | Send-CloudFormationFailure
}

Start-Sleep 1

#Write-Output "$KerberosRealm"
#Write-Output "$KerberosADdomain"
#Write-Output "$PasswordSecretId"
#Write-Output "$EncryptionType"


# ksetup /addkdc $KerberosRealm
# netdom trust $KerberosRealm /Domain:$KerberosADdomain /add /realm /passwordt:$PasswordSecretId
# ksetup /SetEncTypeAttr $KerberosRealm $EncryptionType


#ksetup /addkdc R.US-WEST-2.M1.DXC-AP.COM -Verbose
#netdom trust R.US-WEST-2.M1.DXC-AP.COM /Domain:r.ad.m1.dxc-ap.com /add /realm /passwordt:Jzb5eSm0LSBY3OPoFc7f9CQ8EPYSy5k4 -Verbose
#ksetup /SetEncTypeAttr R.US-WEST-2.M1.DXC-AP.COM AES256-CTS-HMAC-SHA1-96 -Verbose
