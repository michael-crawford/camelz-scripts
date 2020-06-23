<#
.Synopsis
    Configures the Windows TaskBar with useful Programs.
.Description
    Configure-WindowsTaskBar configures the taskbar with programs useful to a Domain Admin
    on a Domain Controller.
.Notes
       Author: Michael Crawford
    Copyright: 2017 by DXC.technology
             : Permission to use is granted but attribution is appreciated

    Remote Desktop = %windir%\system32\mstsc.exe
#>

Write-Host
Write-CloudFormationHost "Configuring Windows TaskBar"

Function Install-TaskBarPinnedItem() {
    [CMDLetBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [System.IO.FileInfo]$Item
    )

    $Pinned = Get-ComFolderItem -Path $Item

    $Pinned.invokeverb('taskbarpin')
}

Function Uninstall-TaskBarPinnedItem() {
    [CMDLetBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [System.IO.FileInfo]$Item
    )

    $Pinned = Get-ComFolderItem -Path $Item

    $Pinned.invokeverb('taskbarunpin')
}

Function Get-ComFolderItem() {
    [CMDLetBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        $Path
    )

    $ShellApp = New-Object -ComObject 'Shell.Application'

    $Item = Get-Item $Path -ErrorAction Stop

    If ($Item -is [System.IO.FileInfo]) {
        $ComFolderItem = $ShellApp.Namespace($Item.Directory.FullName).ParseName($Item.Name)
    }
    ElseIf ($Item -is [System.IO.DirectoryInfo]) {
        $ComFolderItem = $ShellApp.Namespace($Item.Parent.FullName).ParseName($Item.Name)
    }
    Else {
        Throw "Path is not a file nor a directory"
    }

    Return $ComFolderItem
}

$PinnedItems = @(
    'C:\Program Files\Internet Explorer\iexplore.exe'
    'C:\Windows\System32\domain.msc'
    'C:\Windows\System32\dssite.msc'
    'C:\Windows\System32\dsa.msc'
    'C:\Windows\System32\dnsmgmt.msc'
    'C:\Windows\System32\eventvwr.msc'
    'C:\Windows\System32\taskschd.msc'
    'C:\Windows\System32\mstsc.exe'
    'C:\Windows\System32\notepad.exe'
    'C:\Program Files\Windows NT\Accessories\wordpad.exe'
)

ForEach ($Item In $PinnedItems) {
    Uninstall-TaskBarPinnedItem -Item "$Item"
    Install-TaskBarPinnedItem   -Item "$Item"
}
