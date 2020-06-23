<#
.Synopsis
    Joins an Instance to the specified Domain.
.Description
    Join-Domain joins an instance to the specified Domain, using supplied Credentials.
.Parameter DomainName
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
.Example
    Configure-Groups -DomainName m1.dxc-ap.com `
                     -SecretId Production-DirectoryService-Administrator
    Creates Groups using the default ./Groups.csv file using credentials stored in SecretsManager.
.Example
    Configure-Groups -DomainName m1.dxc-ap.com `
                     -UserName Admin -Password <Password>
    Creates Groups using the default ./Groups.csv file using an explicit specified user and password.
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
    [string]$Password = ""
)

Write-Host
Write-CloudFormationHost "Joining Computer to Domain $DomainName"

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

    Add-Computer -DomainName $DomainName -Credential $Credential -ErrorAction Stop
    Write-CloudFormationHost "Computer $env:ComputerName joined to Domain $DomainName, restarting..."

    Restart-Computer
}
Catch {
    $_ | Send-CloudFormationFailure
}

Start-Sleep 1
