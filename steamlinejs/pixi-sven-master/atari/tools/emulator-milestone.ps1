param([Parameter(Mandatory=$true)][int]$ProcessId)
$ErrorActionPreference='Stop'
$window=Join-Path $PSScriptRoot 'emulator-window.ps1'
$evidence=Join-Path $PSScriptRoot '../evidence'
function Press([string]$key,[int]$ms) { & $window -ProcessId $ProcessId -Key $key -HoldMilliseconds $ms }
function Snap([string]$name) { & $window -ProcessId $ProcessId -OutputPath (Join-Path $evidence ($name+'.png')) }
Snap 'milestone-ready'
Press R 100
Press D 310
Press S 400
Press Space 1100
Press P 100
Snap 'milestone-progress-and-enemies'
Start-Sleep -Seconds 3
Snap 'milestone-paused'
# New game, move down/right into the shoreline, avoiding the initial dog.
Press R 100
Press D 1160
Press S 1450
Press P 100
Snap 'milestone-water-escape'
# Leave Sven idle so enemy pursuit and all three life losses can be inspected.
Press R 100
Start-Sleep -Seconds 8
Snap 'milestone-hit'
Start-Sleep -Seconds 20
Snap 'milestone-danger'
Press P 100
Snap 'milestone-inspect'
