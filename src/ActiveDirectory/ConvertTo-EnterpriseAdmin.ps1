<#
.Synopsis
    Converts Users to an Enterprise Admin
.Description
    ConvertTo-EnterpriseAdmin adds the list of specified Users to the groups necessary for them
    to become an Enterprise Admin.
.Parameter Groups
    Specifies the groups to which the members will be added.
    The default is @('domain admins','schema admins','enterprise admins').
.Parameter Members
    Specifies the members to be converted.
.Notes
       Author: Michael Crawford, derived from AWSQuickStart
    Copyright: 2018 by DXC.technology
             : Permission to use is granted but attribution is appreciated
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$false)]
    [string[]]$Groups = @('Enterprise Admins','Domain Admins','Schema Admins'),

    [Parameter(Mandatory=$true)]
    [string[]]$Members
)

Try {
    Write-Host
    Write-CloudFormationHost "Converting $($Members) to Enterprise Admins"

    ForEach ($Group In $Groups) {
        Add-ADGroupMember -Identity $Group -Members $Members
    }
}
Catch {
    $_ | Send-CloudFormationFailure
}

Start-Sleep 1
