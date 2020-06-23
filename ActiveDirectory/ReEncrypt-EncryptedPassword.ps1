<#
.Synopsis
    Decrypts a User-provided Encrypted Password with an Encryption Key, also provided by the User,
    then Re-Encrypts the Password with a common Administrator Encryption Key used for Automation.
.Description
    ReEncrypt-EncryptedPassword decrypts a User-provided Encrypted Password with an Encryption Key,
    then Re-Encrypts the Password with a common Administrator Encryption Key used for Automation.
.Example
    ReEncrypt-EncryptedPassword
    Creates an Encrypted Password and saves it in the User's Documents Folder with the
    Filename %User%-EncryptedPassword.txt
.Notes
       Author: Michael Crawford
    Copyright: 2018 by DXC.technology
             : Permission to use is granted but attribution is appreciated
#>
[CmdletBinding()]
Param ()

[void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
$User = [Microsoft.VisualBasic.Interaction]::InputBox('Please enter the User''s Username', 'Username')
$SourceTextKey = [Microsoft.VisualBasic.Interaction]::InputBox('Please enter the User''s Encryption Key', 'User Encryption Key')
$AutomationTextKey = [Microsoft.VisualBasic.Interaction]::InputBox('Please enter the Automation Encryption Key', 'Automation Encryption Key')

$Encoder = [System.Text.Encoding]::UTF8
$SourceKey = $Encoder.GetBytes($SourceTextKey.PadRight(24))
$AutomationKey = $Encoder.GetBytes($AutomationTextKey.PadRight(24))

$SourceEncryptedPassword = Get-Content "$($env:USERPROFILE)\Downloads\$($User)-EncryptedPassword.txt"
$SecurePassword = ConvertTo-SecureString $SourceEncryptedPassword -Key $SourceKey

$AutomationEncryptedPassword = ConvertFrom-SecureString $SecurePassword -Key $AutomationKey
$AutomationEncryptedPassword | Out-File "$($env:USERPROFILE)\Downloads\$($User)-AutomationEncryptedPassword.txt"
