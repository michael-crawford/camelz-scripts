[CmdletBinding()]
Param (
    [Parameter(Position=0, Mandatory=$true)]
    [string]$ZoneA,

    [Parameter(Position=1, Mandatory=$true)]
    [string]$ZoneB,

    [Parameter(Position=2, Mandatory=$true)]
    [string]$EIPAllocationA,

    [Parameter(Position=3, Mandatory=$false)]
    [string]$EIPAllocationB
)

Write-Host
Write-CloudFormationHost "Configuring Static Public Address"

Try {
    $ErrorActionPreference = "Stop"

    # Get zone and region
    $zone = Invoke-RestMethod http://169.254.169.254/latest/meta-data/placement/availability-zone
    $region = $zone -replace ".$"

    # Get instance
    $instance = Invoke-RestMethod http://169.254.169.254/latest/meta-data/instance-id

    # Choose EIP Allocation
    If ($zone -eq $ZoneA) {
        $allocation = $EIPAllocationA
    }
    Else {
        $allocation = $EIPAllocationB
    }

    # Associate Public Address
    $association = Register-EC2Address -AllocationId $allocation -InstanceId $instance -Region $region
}
Catch {
    $_ | Send-CloudFormationFailure
}

Start-Sleep 1
