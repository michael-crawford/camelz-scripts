[CmdletBinding()]
Param ()

[void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
$User = [Microsoft.VisualBasic.Interaction]::InputBox('Please enter the User''s Username (only works with Admin)', 'Username')
$AutomationTextKey = [Microsoft.VisualBasic.Interaction]::InputBox('Please enter the Automation Encryption Key', 'Automation Encryption Key')

$Encoder = [System.Text.Encoding]::UTF8
$AutomationKey = $Encoder.GetBytes($AutomationTextKey.PadRight(24))

$AutomationEncryptedPassword = Get-Content "$($env:USERPROFILE)\Downloads\$($User)-AutomationEncryptedPassword.txt"
$SecurePassword = ConvertTo-SecureString $AutomationEncryptedPassword -Key $AutomationKey

$Credential = New-Object System.Management.Automation.PSCredential($User, $SecurePassword)

$Users = Get-ADUser -SearchBase “OU=Users,OU=hlsbi,DC=i,DC=ad,DC=hlsb,DC=dxcanalytics,DC=com” -Filter * -Credential $Credential | Select SamAccountName,Name

$Shell = New-Object -ComObject Wscript.Shell
$Shell.Popup("$($Users | Out-String)", 0, 'Users',0x1)
