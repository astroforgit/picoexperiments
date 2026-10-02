param([Parameter(Mandatory=$true)][int]$ProcessId)
$ErrorActionPreference='Stop'
$window=Join-Path $PSScriptRoot 'emulator-window.ps1'
$evidence=Join-Path $PSScriptRoot '../evidence'
& $window -ProcessId $ProcessId -OutputPath (Join-Path $evidence 'moods-ready.png')
# Start, move beside the purple mushroom, then touch it from above.
& $window -ProcessId $ProcessId -Key R -HoldMilliseconds 100
& $window -ProcessId $ProcessId -Key D -HoldMilliseconds 900
& $window -ProcessId $ProcessId -Key S -HoldMilliseconds 680
Start-Sleep -Seconds 2
& $window -ProcessId $ProcessId -Key P -HoldMilliseconds 100
& $window -ProcessId $ProcessId -OutputPath (Join-Path $evidence 'moods-devils.png')
# Independently collect the golden mushroom and inspect the speed indication.
& $window -ProcessId $ProcessId -Key R -HoldMilliseconds 100
& $window -ProcessId $ProcessId -Key A -HoldMilliseconds 280
& $window -ProcessId $ProcessId -Key S -HoldMilliseconds 180
& $window -ProcessId $ProcessId -OutputPath (Join-Path $evidence 'moods-speed.png')
& $window -ProcessId $ProcessId -Key P -HoldMilliseconds 100
