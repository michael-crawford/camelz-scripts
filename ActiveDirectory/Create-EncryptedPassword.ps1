<#
.Synopsis
    Creates an Encrypted Password which is saved to a File
.Description
    Create-EncryptedPassword obtains a Plain Text Password and a Plain Text Encryption Key
    from the user, and first creates a SecureString Password, then converts that into an
    Encrypted String Password, which can be saved and used on other hosts.
.Example
    Create-EncryptedPassword
    Creates an Encrypted Password and saves it in the User's Documents Folder with the
    Filename %User%-EncryptedPassword.txt
.Notes
       Author: Michael Crawford
    Copyright: 2018 by DXC.technology
             : Permission to use is granted but attribution is appreciated
#>
[CmdletBinding()]
Param ()

$Shell = New-Object -ComObject Wscript.Shell

$Disclaimer = @'
This command will ask you to enter a password. This value is converted
into a SecureString as it is read into a variable - it is never saved
in plain text in any form. SecureStrings can never be converted back
into plain text, but they also can not be saved to a file, or used on
a different host.
'@+[environment]::NewLine+[environment]::NewLine+@'
So, we must convert the SecureString into an Encrypted String, which
can be saved. In order for this Encrypted String to be decryptable
back into a SecureString on another Host by a different Admin (did I
mention SecureStrings can never be converted back into plain text?),
we must specify an Encryption Key to be used for this encryption.
This key is throw-away, and will only be used to safely send the
secure string to a Directory Admin for AWS. Once this command is
complete, you will have a file on your Desktop containing your
Encrypted Password. You should email this file to the AWS Directory
Admin who requested this, and then communicate the Encryption Key
used to encrypt this file via a second channel, such as a phone call
or text message. If this Encryption Key is compromised, it can only
convert the Encrypted Password back into a SecureString (did I
mention SecureStrings can never be converted back into plain text?),
so no need to be paranoid about how you transmit this Key.
'@+[environment]::NewLine+[environment]::NewLine+@'
Once the AWS Directory Admin receives your Encrypted Password, your
Encryption Key will be used to decrypt this back to a SecureString.
The Admin will not be able to obtain your Plain Text Password!
This SecureString will then be re-encrypted into another Encrypted
String value and stored in a CSV file used to automate the
creation of your user account. This will allow you to have a
known password which only YOU know immediately available to login
to any Windows Hosts.
'@

$Shell.Popup($Disclaimer, 0, 'How This Works',0x1)

[void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
$User = [Microsoft.VisualBasic.Interaction]::InputBox('Please enter your Username', 'Username')
$SecurePassword = [Microsoft.VisualBasic.Interaction]::InputBox('Please enter your Password', 'Password') | ConvertTo-SecureString -AsPlainText -Force
$PlainTextKey = [Microsoft.VisualBasic.Interaction]::InputBox('Please enter an Encryption Key (< 24 characters)', 'Encryption Key')

$Encoder = [System.Text.Encoding]::UTF8
$Key = $Encoder.GetBytes($PlainTextKey.PadRight(24))

$EncryptedPassword = ConvertFrom-SecureString $SecurePassword -Key $Key

$EncryptedPassword | Out-File "$([Environment]::GetFolderPath('Desktop'))\$($User)-EncryptedPassword.txt"

$Instructions = @"
Your Encrypted Password is: $EncryptedPassword
"@+[environment]::NewLine+[environment]::NewLine+@"
Your Encrypted Password has been saved to: $([Environment]::GetFolderPath('Desktop'))\$($User)-EncryptedPassword.txt
"@+[environment]::NewLine+[environment]::NewLine+@"
It was encrypted with key: $PlainTextKey
"@+[environment]::NewLine+[environment]::NewLine+@"
Email this file to the AWS Directory Admin, and send the Encryption key by a different secure method.
"@

$Shell.Popup($Instructions, 0, 'What to do next',0x1)
