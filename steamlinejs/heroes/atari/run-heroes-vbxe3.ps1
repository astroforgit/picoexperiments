param([switch]$Check, [string]$AltirraPath)
$ErrorActionPreference = 'Stop'
& (Join-Path $PSScriptRoot 'run-prince-and-the-nimf.ps1') -Check:$Check -AltirraPath $AltirraPath
