# Start Celeste (celeste.xex) in Altirra with the persistent VBXE profile.
#
#   .\run.ps1              fast load, profile's video standard
#   .\run.ps1 -Pal         force PAL   (-Ntsc forces NTSC)
#   .\run.ps1 -Debugger    open Altirra's debugger as well
#   .\run.ps1 -SlowLoad    load through normal-speed SIO like real hardware
param(
    [string] $XexPath = (Join-Path $PSScriptRoot 'celeste.xex'),
    [string] $AltirraPath,
    [switch] $Pal,
    [switch] $Ntsc,
    [switch] $Debugger,
    [switch] $SlowLoad
)

$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot '..\..\atari-vbxe-toolkit\scripts\AltirraTools.psm1') -Force

if (-not (Test-Path -LiteralPath $XexPath -PathType Leaf)) {
    throw ('celeste.xex not found (' + $XexPath + '). Run build.sh first.')
}
$emulator = Get-AltirraPath -ExplicitPath $AltirraPath
$image = (Resolve-Path -LiteralPath $XexPath).ProviderPath

# Reuse the persistent profile that has VideoBoard XE attached; never add
# /portabletemp, /cleardevices or /adddevice here (see atari-vbxe-toolkit).
$arguments = @('/nosi', '/w', '/noautoprofile', '/nobasic')
if (-not $SlowLoad) { $arguments += @('/siopatch', '/fastboot') }
if ($Pal) { $arguments += '/pal' }
if ($Ntsc) { $arguments += '/ntsc' }
if ($Debugger) { $arguments += '/debug' }
$arguments += '/run'
$arguments += ('"' + $image + '"')

$process = Start-Process -FilePath $emulator -ArgumentList $arguments -PassThru
Write-Output ('Celeste started in Altirra (PID ' + $process.Id + ')')
Write-Output 'Controls: joystick or WASD move; fire, O or X jump; 2nd button, joy 2 fire, P, SPACE, C or SHIFT dash'
