# Legacy checkpoint timing exercise; active enemies now affect idle runs.
param([Parameter(Mandatory=$true)][int]$ProcessId)
$ErrorActionPreference = 'Stop'
$evidence = Join-Path $PSScriptRoot '../evidence'
$window = Join-Path $PSScriptRoot 'emulator-window.ps1'
$events = New-Object System.Collections.Generic.List[object]
function Snap([string]$name) {
 & $window -ProcessId $ProcessId -OutputPath (Join-Path $evidence ($name+'.png'))
 $events.Add(@{name=$name; utc=[DateTime]::UtcNow.ToString('o')})
}
& $window -ProcessId $ProcessId -Key R -HoldMilliseconds 100
Snap 'timer-start'
Start-Sleep -Seconds 10
Snap 'timer-after-10s'
& $window -ProcessId $ProcessId -Key P -HoldMilliseconds 100
Snap 'paused'
Start-Sleep -Seconds 10
Snap 'paused-after-10s'
& $window -ProcessId $ProcessId -Key P -HoldMilliseconds 100
Snap 'resumed'
& $window -ProcessId $ProcessId -Key R -HoldMilliseconds 100
Snap 'timeout-start'
Start-Sleep -Seconds 45
Snap 'timeout-midpoint'
Start-Sleep -Seconds 46
Snap 'timeout'
& $window -ProcessId $ProcessId -Key Space -HoldMilliseconds 100
Snap 'timeout-replay'
$events | ConvertTo-Json | Set-Content -Encoding UTF8 (Join-Path $evidence 'timing.json')
