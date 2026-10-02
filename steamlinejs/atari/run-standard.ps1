param(
    [Parameter(Mandatory = $true)] [string] $XexPath,
    [string] $AltirraPath
)
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot '../../atari-vbxe-toolkit/scripts/AltirraTools.psm1') -Force
$emulator = Get-AltirraPath -ExplicitPath $AltirraPath
$image = (Resolve-Path -LiteralPath $XexPath).ProviderPath
# A private, persistent profile keeps input mappings without modifying VBXE.
# /portabletemp discarded all mappings and XL defaults enable no controller.
$settings = Join-Path $PSScriptRoot 'altirra-standard.ini'
if (-not (Test-Path -LiteralPath $settings)) {
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'altirra-standard-defaults.ini') -Destination $settings
}
$arguments = @('/nosi', '/portablealt', ('"' + $settings + '"'), '/noautoprofile',
    '/hardware:800xl', '/memsize:64K',
    '/pal', '/nobasic', '/cleardevices', '/run', ('"' + $image + '"'))
$process = Start-Process -FilePath $emulator -ArgumentList $arguments -PassThru
Write-Output ('Started standard Atari XL, VBXE disabled; PID ' + $process.Id)
Write-Output ('Input settings: ' + $settings)
