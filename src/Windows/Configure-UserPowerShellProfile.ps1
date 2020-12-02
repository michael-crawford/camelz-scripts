<#
.Synopsis
    Configures the specified user's PowerShell profile
.Description
    Configures the specified user's PowerShell profile, located here:
    C:\Users\$UserName\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
.Parameter UserName
    The UserName to configure. Defaults to the current user.
.Notes
       Author: Michael Crawford
    Copyright: 2017 by DXC.technology
             : Permission to use is granted but attribution is appreciated

    Notes to set the default window size.
    - In this registry key: HKEY_CURRENT_USER\Console, you have
      - ScreenBufferSize (Default: 80W x 300L; New: 200W x 1000L
        - Default (hex): 12c0050
        - Default (dec): 19660880
        - New (hex): 3e800c8 - 3e800c8
        - New (dec): 65536200
      - WindowSize (Default: 80W x 25L; New: 160W x 32L)
        - Default (hex): 190050
        - Default (dec): 1638480
        - New (hex): 2000a0 - 2000a0 (after relogin, after properties change)
        - New (dec): 2097312


#>
[CmdletBinding()]
Param (
    [Parameter(Position=0, Mandatory=$false)]
    [string]$UserName = $env:UserName
)

Write-Host
Write-CloudFormationHost "Configuring Windows PowerShell Profile for $UserName"

New-Item C:\Users\$UserName\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1 -ItemType file -Force

@'
Set-Location C:\

$Shell = $Host.UI.RawUI

$size = $Shell.WindowSize
$size.width=120
$size.height=32
$Shell.WindowSize = $size

$size = $Shell.BufferSize
$size.width=256
$size.height=2000
$Shell.BufferSize = $size

$Shell.BackgroundColor = ($background = 'White')
$Shell.ForegroundColor = ($foreground = 'Black')
$Host.PrivateData.ErrorForegroundColor = 'Red'
$Host.PrivateData.ErrorBackgroundColor = $background
$Host.PrivateData.WarningForegroundColor = 'Magenta'
$Host.PrivateData.WarningBackgroundColor = $background
$Host.PrivateData.DebugForegroundColor = 'Blue'
$Host.PrivateData.DebugBackgroundColor = $background
$Host.PrivateData.VerboseForegroundColor = 'DarkGreen'
$Host.PrivateData.VerboseBackgroundColor = $background
$Host.PrivateData.ProgressForegroundColor = 'DarkCyan'
$Host.PrivateData.ProgressBackgroundColor = $background

Clear-Host
'@ | Out-File -FilePath C:\Users\$UserName\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1 -Append -Encoding ASCII
