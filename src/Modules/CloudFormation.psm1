<#
This Module was derived from the AWSQuickStart Module with improvements and changes

Method used to create starting point for Proxy Cmdlets:
$metadata = New-Object System.Management.Automation.CommandMetaData (Get-Command Wtite-Host)
[System.Management.Automation.ProxyCommand]::Create($metadata) | Out-File C:\Scripts\MyWrite-Host.ps1

$metadata = New-Object System.Management.Automation.CommandMetaData (Get-Command Write-Debug)
[System.Management.Automation.ProxyCommand]::Create($metadata) | Out-File C:\Scripts\MyWrite-Debug.ps1

$metadata = New-Object System.Management.Automation.CommandMetaData (Get-Command Write-Warning)
[System.Management.Automation.ProxyCommand]::Create($metadata) | Out-File C:\Scripts\MyWrite-Warning.ps1

$metadata = New-Object System.Management.Automation.CommandMetaData (Get-Command Write-Error)
[System.Management.Automation.ProxyCommand]::Create($metadata) | Out-File C:\Scripts\MyWrite-Error.ps1
#>

Function Write-CloudFormationHost {
    [CmdletBinding(RemotingCapability='None')]
    Param(
        [Parameter(Position=0, ValueFromPipeline=$true, ValueFromRemainingArguments=$true)]
        [System.Object]${Object},

        [switch]${NoNewline},

        [System.Object]${Separator},

        [System.ConsoleColor]${ForegroundColor},

        [System.ConsoleColor]${BackgroundColor}
    )

    Begin {
        Try {
            $outBuffer = $null
            If ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer)) {
                $PSBoundParameters['OutBuffer'] = 1
            }
            $PSBoundParameters['Object'] = "$(Get-Date -format 'yyyy-MM-dd HH:mm:ss,fff') [INFO] $($PSBoundParameters['Object'])"
            $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Write-Host', [System.Management.Automation.CommandTypes]::Cmdlet)
            $scriptCmd = {& $wrappedCmd @PSBoundParameters }
            $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
            $steppablePipeline.Begin($PSCmdlet)
        }
        Catch {
            Throw
        }
    }

    Process {
        Try {
            $steppablePipeline.Process($_)
        }
        Catch {
            Throw
        }
    }

    End {
        Try {
            $steppablePipeline.End()
        }
        Catch {
            Throw
        }
    }
}

Function Write-CloudFormationDebug {
    [CmdletBinding(RemotingCapability='None')]
    Param(
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [Alias('Msg')]
        [AllowEmptyString()]
        [string]${Message}
    )

    Begin {
        Try {
            $outBuffer = $null
            If ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer)) {
                $PSBoundParameters['OutBuffer'] = 1
            }
            $PSBoundParameters['Message'] = "$(Get-Date -format 'yyyy-MM-dd HH:mm:ss,fff') [DEBUG] $($PSBoundParameters['Message'])"
            $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Write-Debug', [System.Management.Automation.CommandTypes]::Cmdlet)
            $scriptCmd = {& $wrappedCmd @PSBoundParameters }
            $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
            $steppablePipeline.Begin($PSCmdlet)
        }
        Catch {
            Throw
        }
    }

    Process {
        Try {
            $steppablePipeline.Process($_)
        }
        Catch {
            Throw
        }
    }

    End {
        Try {
            $steppablePipeline.End()
        }
        Catch {
            Throw
        }
    }
}

Function Write-CloudFormationWarning {
    [CmdletBinding(RemotingCapability='None')]
    Param(
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [Alias('Msg')]
        [AllowEmptyString()]
        [string]${Message}
    )

    Begin {
        Try {
            $outBuffer = $null
            if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer)) {
                $PSBoundParameters['OutBuffer'] = 1
            }
            $PSBoundParameters['Message'] = "$(Get-Date -format 'yyyy-MM-dd HH:mm:ss,fff') [WARNING] $($PSBoundParameters['Message'])"
            $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Write-Warning', [System.Management.Automation.CommandTypes]::Cmdlet)
            $scriptCmd = {& $wrappedCmd @PSBoundParameters }
            $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
            $steppablePipeline.Begin($PSCmdlet)
        }
        Catch {
            Throw
        }
    }

    Process {
        Try {
            $steppablePipeline.Process($_)
        }
        Catch {
            Throw
        }
    }

    End {
        Try {
            $steppablePipeline.End()
        }
        Catch {
            Throw
        }
    }
}

Function Write-CloudFormationError {
    [CmdletBinding(DefaultParameterSetName='NoException', RemotingCapability='None')]
    Param(
        [Parameter(ParameterSetName='WithException', Mandatory=$true)]
        [System.Exception]${Exception},

        [Parameter(ParameterSetName='NoException', Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [Parameter(ParameterSetName='WithException')]
        [Alias('Msg')]
        [AllowEmptyString()]
        [AllowNull()]
        [string]${Message},

        [Parameter(ParameterSetName='ErrorRecord', Mandatory=$true)]
        [System.Management.Automation.ErrorRecord]${ErrorRecord},

        [Parameter(ParameterSetName='WithException')]
        [Parameter(ParameterSetName='NoException')]
        [System.Management.Automation.ErrorCategory]${Category},

        [Parameter(ParameterSetName='NoException')]
        [Parameter(ParameterSetName='WithException')]
        [string]${ErrorId},

        [Parameter(ParameterSetName='NoException')]
        [Parameter(ParameterSetName='WithException')]
        [System.Object]${TargetObject},

        [string]${RecommendedAction},

        [Alias('Activity')]
        [string]${CategoryActivity},

        [Alias('Reason')]
        [string]${CategoryReason},

        [Alias('TargetName')]
        [string]${CategoryTargetName},

        [Alias('TargetType')]
        [string]${CategoryTargetType}
    )

    Begin {
        Try {
            $outBuffer = $null
            If ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer)) {
                $PSBoundParameters['OutBuffer'] = 1
            }
            $PSBoundParameters['Message'] = "$(Get-Date -format 'yyyy-MM-dd HH:mm:ss,fff') [WARNING] $($PSBoundParameters['Message'])"
            $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Write-Error', [System.Management.Automation.CommandTypes]::Cmdlet)
            $scriptCmd = {& $wrappedCmd @PSBoundParameters }
            $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
            $steppablePipeline.Begin($PSCmdlet)
        }
        Catch {
            Throw
        }
    }

    Process {
        Try {
            $steppablePipeline.Process($_)
        }
        Catch {
            Throw
        }
    }

    End {
        Try {
            $steppablePipeline.End()
        }
        Catch {
            Throw
        }
    }
}

Function Write-CloudFormationVerbose {
    [CmdletBinding(RemotingCapability='None')]
    Param(
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [Alias('Msg')]
        [AllowEmptyString()]
        [string]${Message}
    )

    Begin {
        Try {
            $outBuffer = $null
            If ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer)) {
                $PSBoundParameters['OutBuffer'] = 1
            }
            $PSBoundParameters['Message'] = "$(Get-Date -format 'yyyy-MM-dd HH:mm:ss,fff') [INFO] $($PSBoundParameters['Message'])"
            $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Write-Verbose', [System.Management.Automation.CommandTypes]::Cmdlet)
            $scriptCmd = {& $wrappedCmd @PSBoundParameters }
            $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
            $steppablePipeline.Begin($PSCmdlet)
        }
        Catch {
            Throw
        }
    }

    Process {
        Try {
            $steppablePipeline.Process($_)
        }
        Catch {
            Throw
        }
    }

    End {
        Try {
            $steppablePipeline.End()
        }
        Catch {
            Throw
        }
    }
}

Function Register-CloudFormationWaitHandle {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string]$Handle,

        [Parameter(Mandatory=$false)]
        [string]$Path = 'HKLM:\SOFTWARE\Amazon\CloudFormation\',

        [Parameter(Mandatory=$false)]
        [switch]$Base64Handle
    )

    Try {
        $ErrorActionPreference = "Stop"

        Write-Verbose "Creating $Path"
        New-Item $Path -Force

        If ($Base64Handle) {
            Write-Verbose "Trying to decode handle Base64 string as UTF8 string"
            $decodedHandle = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($Handle))
            if ($decodedHandle -notlike "http*") {
                Write-Verbose "Now trying to decode handle Base64 string as Unicode string"
                $decodedHandle = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($Handle))
            }
            Write-Verbose "Decoded handle string: $decodedHandle"
            $Handle = $decodedHandle
        }

        Write-Verbose "Creating Handle Registry Key"
        New-ItemProperty -Path $Path -Name Handle -Value $Handle -Force

        Write-Verbose "Creating ErrorCount Registry Key"
        New-ItemProperty -Path $Path -Name ErrorCount -Value 0 -PropertyType dword -Force
    }
    Catch {
        Write-Verbose $_.Exception.Message
    }
}

Function Register-CloudFormationSignal {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [string]$Stack,

        [Parameter(Mandatory=$true)]
        [string]$Resource,

        [Parameter(Mandatory=$true)]
        [string]$Region,

        [Parameter(Mandatory=$false)]
        [string]$Path = 'HKLM:\SOFTWARE\Amazon\CloudFormation\'
    )

    Try {
        $ErrorActionPreference = "Stop"

        Write-Verbose "Creating $Path"
        New-Item $Path -Force

        Write-Verbose "Creating Stack Registry Key"
        New-ItemProperty -Path $Path -Name Stack -Value $Stack -Force

        Write-Verbose "Creating Resource Registry Key"
        New-ItemProperty -Path $Path -Name Resource -Value $Resource -Force

        Write-Verbose "Creating Region Registry Key"
        New-ItemProperty -Path $Path -Name Region -Value $Region -Force

        Write-Verbose "Creating ErrorCount Registry Key"
        New-ItemProperty -Path $Path -Name ErrorCount -Value 0 -PropertyType dword -Force
    }
    Catch {
        Write-Verbose $_.Exception.Message
    }
}


Function Get-CloudFormationErrorCount {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$false)]
        [string]$Path = 'HKLM:\SOFTWARE\Amazon\CloudFormation\'
    )

    Process {
        Try {
            Write-Verbose "Getting ErrorCount Registry Key"
            Get-ItemProperty -Path $Path -Name ErrorCount -ErrorAction Stop | Select-Object -ExpandProperty ErrorCount
        }
        Catch {
            Write-Verbose $_.Exception.Message
        }
    }
}

Function Add-CloudFormationErrorCount {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$false)]
        [string]$Path = 'HKLM:\SOFTWARE\Amazon\CloudFormation\'
    )

    Process {
        Try {
            $Count = Get-ItemProperty -Path $Path -Name ErrorCount -ErrorAction Stop | Select-Object -ExpandProperty ErrorCount
            $Count += 1

            Write-Verbose "Creating ErrorCount Registry Key"
            Set-ItemProperty -Path $Path -Name ErrorCount -Value $Count -ErrorAction Stop
        }
        Catch {
            Write-Verbose $_.Exception.Message
        }
    }
}

Function Get-CloudFormationWaitHandle {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$false, ValueFromPipeline=$true)]
        [string]$Path = 'HKLM:\SOFTWARE\Amazon\CloudFormation\'
    )

    Process {
        Try {
            $ErrorActionPreference = "Stop"

            Write-Verbose "Getting Handle key value from $Path"
            $key = Get-ItemProperty $Path

            Return $key.Handle
        }
        Catch {
            Write-Verbose $_.Exception.Message
        }
    }
}

Function Get-CloudFormationSignal {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$false)]
        [string]$Path = 'HKLM:\SOFTWARE\Amazon\CloudFormation\'
    )

    Try {
        $ErrorActionPreference = "Stop"

        Write-Verbose "Getting Stack, Resource, and Region key values from $Path"
        $key = Get-ItemProperty $Path
        $signal = @{
            Stack = $key.Stack
            Resource = $key.Resource
            Region = $key.Region
        }
        $toReturn = New-Object -TypeName PSObject -Property $signal

        If ($toReturn.Stack -and $toReturn.Resource -and $toReturn.Region) {
            Return $toReturn
        } Else {
            Return $null
        }
    }
    Catch {
        Write-Verbose $_.Exception.Message
    }
}

Function Unregister-CloudFormationWaitHandle {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$false, ValueFromPipeline=$true)]
        [string]$Path = 'HKLM:\SOFTWARE\Amazon\CloudFormation\'
    )

    Process {
        Try {
            $ErrorActionPreference = "Stop"

            Write-Verbose "Getting Handle key value from $Path"
            $key = Get-ItemProperty -Path $Path -Name Handle -ErrorAction SilentlyContinue

            If ($key) {
                Write-Verbose "Removing Handle key value from $Path"
                Remove-ItemProperty -Path $Path -Name Handle
            }
        }
        Catch {
            Write-Verbose $_.Exception.Message
        }
    }
}

Function Unregister-CloudFormationSignal {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$false)]
        [string]$Path = 'HKLM:\SOFTWARE\Amazon\CloudFormation\'
    )

    Try {
        $ErrorActionPreference = "Stop"

        ForEach ($keyName in @('Stack','Resource','Region')) {
            Write-Verbose "Getting Stack, Resource, and Region key values from $Path"
            $key = Get-ItemProperty -Path $Path -Name $keyName -ErrorAction SilentlyContinue

            If ($key) {
                Write-Verbose "Removing $keyName key value from $Path"
                Remove-ItemProperty -Path $Path -Name $keyName
            }
        }
    }
    Catch {
        Write-Verbose $_.Exception.Message
    }
}

Function Write-CloudFormationEvent {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName=$true)]
        [string]$Message,

        [Parameter(Mandatory=$false)]
        [string]$EntryType = 'Error'
    )

    Process {
        Write-Verbose "Checking for CloudFormation Eventlog Source"
        If(![System.Diagnostics.EventLog]::SourceExists('CloudFormation')) {
            New-EventLog -LogName Application -Source CloudFormation -ErrorAction SilentlyContinue
        }
        Else {
            Write-Verbose "CloudFormation Eventlog Source exists"
        }

        Write-Verbose "Writing message to application log"

        Try {
            Write-EventLog -LogName Application -Source CloudFormation -EntryType $EntryType -EventId 1001 -Message $Message
        }
        Catch {
            Write-Verbose $_.Exception.Message
        }
    }
}

Function Send-CloudFormationFailure {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, ValueFromPipeline=$true)]
        [System.Management.Automation.ErrorRecord]$ErrorRecord
    )

    Process {
        Try {
            Write-Verbose "Incrementing error count"
            Add-CloudFormationErrorCount

            Write-Verbose "Getting total error count"
            $errorTotal = Get-CloudFormationErrorCount

            $errorMessage = "Command failure in {0} {1} on line {2} `nException: {3}" -f $ErrorRecord.InvocationInfo.MyCommand.name,
                                                                                         $ErrorRecord.InvocationInfo.ScriptName,
                                                                                         $ErrorRecord.InvocationInfo.ScriptLineNumber,
                                                                                         $ErrorRecord.Exception.ToString()

            $CmdSafeErrorMessage = $errorMessage -replace '[^a-zA-Z0-9\s\.\[\]\-,:_\\\/\(\)]', ''
            If ($CmdSafeErrorMessage.length -gt 255) {
                $CmdSafeErrorMessage = $CmdSafeErrorMessage.substring(0,252) + '...'
            }

            $handle = Get-CloudFormationWaitHandle -ErrorAction SilentlyContinue
            If ($handle) {
                Invoke-Expression "cfn-signal.exe -e 1 --reason='$CmdSafeErrorMessage' '$handle'"
            }
            Else {
                $signal = Get-CloudFormationSignal -ErrorAction SilentlyContinue
                If ($signal) {
                    Invoke-Expression "cfn-signal.exe -e 1 --stack '$($signal.Stack)' --resource '$($signal.Resource)' --region '$($signal.Region)'"
                }
                Else {
                    Throw "No handle or stack/resource/region found in registry"
                }
            }
        }
        Catch {
            Write-Verbose $_.Exception.Message
        }
        Finally {
            Write-CloudFormationEvent -Message $errorMessage
            # throwing an exception to force cfn-init execution to stop
            Throw $CmdSafeErrorMessage
        }
    }
}

Function Send-CloudFormationSuccess {
    [CmdletBinding()]
    Param()

    Process {
        Try {
            # This check is illogical in how it's designed, as it does nothing if it fails
            Write-Verbose "Checking error count"
            If((Get-CloudFormationErrorCount) -eq 0) {
                Write-Verbose "Getting Handle"
                $handle = Get-CloudFormationWaitHandle -ErrorAction SilentlyContinue
                If ($handle) {
                    Invoke-Expression "cfn-signal.exe -e 0 '$handle'"
                }
                Else {
                    $resourceSignal = Get-CloudFormationSignal -ErrorAction SilentlyContinue
                    if ($resourceSignal) {
                        Invoke-Expression "cfn-signal.exe -e 0 --stack '$($resourceSignal.Stack)' --resource '$($resourceSignal.Resource)' --region '$($resourceSignal.Region)'"
                    } else {
                        throw "No handle or stack/resource/region found in registry"
                    }
                }
            }
        }
        catch {
            Write-Verbose $_.Exception.Message
        }
    }
}
