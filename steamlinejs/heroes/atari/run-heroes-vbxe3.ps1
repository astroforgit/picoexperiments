param([switch]$Check)
$ErrorActionPreference = 'Stop'
$image = Join-Path $PSScriptRoot 'heroes-vbxe3.xex'
$launcher = Join-Path $PSScriptRoot '../../../atari-vbxe-toolkit/scripts/run-xex.ps1'
if (-not (Test-Path -LiteralPath $image -PathType Leaf)) { throw "Game not found: $image" }
if (-not (Test-Path -LiteralPath $launcher -PathType Leaf)) { throw "Altirra launcher not found: $launcher" }
if ($Check) {
    Write-Output "Game: $image"
    Write-Output "Launcher: $launcher"
    exit 0
}
& $launcher -XexPath $image
