<#
.Synopsis
    Adds Domain Groups to the local Remote Desktop Users Group
.Description
    Configure-RemoteDesktopUsers reads a CSV file containing Active Directory Groups and adds them
    to the local Remote Desktop Users Group.
.Parameter RemoteDesktopUsersPath
    Specifies the path to the RemoteDesktopUsers input CSV file.
    The default value is '.\RemoteDesktopUsers.csv'.
.Example
    Configure-RemoteDesktopUsers
    Obtains Users using the default ./RemoteDesktopUsers.csv file.
.Example
    Configure-RemoteDesktopUsers -RemoteDesktopUsersPath 'C:\cfn\temp\CustomRemoteDesktopUsers.csv'
    Obtains Users using a custom CSV file
.Notes
       Author: Michael Crawford
    Copyright: 2018 by DXC.technology
             : Permission to use is granted but attribution is appreciated
#>
[CmdletBinding()]
Param (
    [Parameter(Mandatory=$false)]
    [string]$RemoteDesktopUsersPath = '.\RemoteDesktopUsers.csv'
)

Try {
    $DNSRoot = (Get-WmiObject Win32_ComputerSystem).Domain

    $Users = @()
    If (Test-Path $RemoteDesktopUsersPath) {
       $Users = Import-CSV $RemoteDesktopUsersPath
    }
    Else {
       Throw  "-RemoteDesktopUsersPath $RemoteDesktopUsersPath is invalid."
    }

    $Group="Remote Desktop Users"

    Write-Host
    Write-CloudFormationHost "Adding Remote Desktop Users"

    ForEach ($User In $Users) {
        Try {
            $GroupObj = [ADSI]"WinNT://localhost/$Group"
            $GroupObj.Add("WinNT://$DNSRoot/$($User.SamAccountName)")
            Write-CloudFormationHost "- User $($User.Name) added to Group $Group"
        }
        Catch {
            Write-CloudFormationWarning "- User $($User.Name) could not be added to Group $Group, Error: $($_.Exception.Message)"
        }
    }
}
Catch {
    $_ | Send-CloudFormationFailure
}

Start-Sleep 1
