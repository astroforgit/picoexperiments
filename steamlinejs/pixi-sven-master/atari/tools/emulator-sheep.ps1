param([Parameter(Mandatory=$true)][int]$ProcessId)
$ErrorActionPreference='Stop'
$window=Join-Path $PSScriptRoot 'emulator-window.ps1'
$evidence=Join-Path $PSScriptRoot '../evidence'
& $window -ProcessId $ProcessId -Key R -HoldMilliseconds 100
& $window -ProcessId $ProcessId -Key Space -HoldMilliseconds 50 -DoublePress
& $window -ProcessId $ProcessId -Key P -HoldMilliseconds 100
& $window -ProcessId $ProcessId -OutputPath (Join-Path $evidence 'sheep-whistle-altirra.png')
& $window -ProcessId $ProcessId -Key R -HoldMilliseconds 100
Start-Sleep -Seconds 2
& $window -ProcessId $ProcessId -Key P -HoldMilliseconds 100
& $window -ProcessId $ProcessId -OutputPath (Join-Path $evidence 'sheep-wandering-altirra.png')
