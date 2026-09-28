# Legacy collection-checkpoint route (53f280f). Use emulator-milestone.ps1 for current gameplay.
param([Parameter(Mandatory=$true)][int]$ProcessId)
$ErrorActionPreference = 'Stop'
$evidence = Join-Path $PSScriptRoot '../evidence'
$window = Join-Path $PSScriptRoot 'emulator-window.ps1'
function Move-Sven([string]$key,[int]$ms) {
 & $window -ProcessId $ProcessId -Key $key -HoldMilliseconds $ms
}
function Save-Game([string]$name) {
 & $window -ProcessId $ProcessId -OutputPath (Join-Path $evidence ($name+'.png'))
}
Move-Sven R 150
Save-Game 'playthrough-start'
Move-Sven D 310
Move-Sven S 400
Move-Sven Space 100
Save-Game 'collected-1'
Move-Sven A 1100
Move-Sven Space 100
Save-Game 'collected-2'
Move-Sven A 250
Move-Sven S 740
Move-Sven Space 100
Save-Game 'collected-3'
Move-Sven W 1880
Move-Sven Space 100
Save-Game 'collected-4'
Move-Sven D 650
Move-Sven S 240
Move-Sven Space 100
Save-Game 'collected-5'
Move-Sven D 900
Move-Sven W 280
Move-Sven Space 100
Save-Game 'collected-6'
Move-Sven D 470
Move-Sven S 720
Move-Sven Space 100
Save-Game 'collected-7'
Move-Sven A 270
Move-Sven S 1140
Move-Sven Space 100
Save-Game 'playthrough-end'
Save-Game 'win'
Start-Sleep -Milliseconds 1200
Save-Game 'win-settled'
Move-Sven Space 100
Save-Game 'replay'
