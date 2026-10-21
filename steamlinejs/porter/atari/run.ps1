# Start Porter (porter-vbxe.xex) in Altirra with the persistent VBXE profile.
#
#   .\run.ps1              fast load, profile's video standard
#   .\run.ps1 -Pal         force PAL   (-Ntsc forces NTSC)
#   .\run.ps1 -Debugger    open Altirra's debugger as well
#   .\run.ps1 -SlowLoad    load through normal-speed SIO like real hardware
param(
    [string] $XexPath = (Join-Path $PSScriptRoot 'porter-vbxe.xex'),
    [string] $AltirraPath,
    [switch] $Pal,
    [switch] $Ntsc,
    [switch] $Debugger,
    [switch] $SlowLoad
)

$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot '..\..\..\atari-vbxe-toolkit\scripts\AltirraTools.psm1') -Force

if (-not (Test-Path -LiteralPath $XexPath -PathType Leaf)) {
    throw ('porter-vbxe.xex not found (' + $XexPath + '). Run build.sh first.')
}
$emulator = Get-AltirraPath -ExplicitPath $AltirraPath
$image = (Resolve-Path -LiteralPath $XexPath).ProviderPath

# Porter's jump and teleport sounds need a short host audio queue.
& (Join-Path $PSScriptRoot 'tools\configure_audio.ps1')

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
Write-Output ('Porter started in Altirra (PID ' + $process.Id + ')')
Write-Output 'Controls: joystick moves and aims; fire jumps; SPACE, SHIFT, joy 2 fire or 2nd button teleports; OPTION mutes'
