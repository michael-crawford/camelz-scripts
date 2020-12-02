<#
.Synopsis
    Creates the initial Enterprise Admin for a new Forest
.Description
    New-EnterpriseAdmin creates the first User in a new Active Directory Forest, then adds this user
    to the groups necessary for them to become an Enterprise Admin.
.Parameter DomainName
    Specifies the domain to which the user is added
.Parameter SecretId
    Specifies the Id of a SecretsManager Secret containing the User Name and Password for the user account.
.Parameter UserName
    Specifies a user account for the initial Enterprise Admin.
    The default is 'Admin', to match AWS DirectoryService, where that name is fixed. To keep the ActiveDirectory
    Template behavior as close to DirectoryService as possible, we strongly recommend you do not modify this
    name from the default value of 'Admin' - no other values have been tested!
.Parameter Password
    Specifies the password for the user account.
    Avoid using this method if possible - it's more secure to have SecretsManager create and store the password.
.Parameter Groups
    Specifies the groups to which the members will be added.
    The default is @('domain admins','schema admins','enterprise admins').
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
    [string[]]$Groups = @('Enterprise Admins','Domain Admins','Schema Admins')
)

Write-Host
Write-CloudFormationHost "Adding Enterprise Administrator $UserName to Domain $DomainName"

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

    Write-CloudFormationHost "Creating $UserName@$DomainName User"

    New-ADUser -Name $UserName `
               -UserPrincipalName $UserName@$DomainName `
               -Description "Administrator created via CloudFormation to Administer Active Directory" `
               -AccountPassword $SecurePassword `
               -Enabled $true -PasswordNeverExpires $true
    Write-CloudFormationHost "$UserName@$DomainName User created"

    Write-CloudFormationHost "Converting $UserName User to an Enterprise Admin"

    ForEach ($Group In $Groups) {
        Add-ADGroupMember -Identity $Group -Members $UserName
    }
}
Catch {
    $_ | Send-CloudFormationFailure
}

Start-Sleep 1
