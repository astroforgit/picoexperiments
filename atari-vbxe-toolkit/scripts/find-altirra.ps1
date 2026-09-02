param([string] $AltirraPath)

$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'AltirraTools.psm1') -Force

$resolved = Get-AltirraPath -ExplicitPath $AltirraPath
Write-Output $resolved

$portableIni = Join-Path (Split-Path -Parent $resolved) 'Altirra.ini'
if (Test-Path -LiteralPath $portableIni) {
    Write-Output ('Configuration storage: portable INI at ' + $portableIni)
}
else {
    Write-Output 'Configuration storage: normal per-user Altirra profile'
}

