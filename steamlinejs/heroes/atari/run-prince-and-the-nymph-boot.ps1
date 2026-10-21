param([switch]$Check, [string]$AltirraPath)
$ErrorActionPreference = 'Stop'
$disk = Join-Path $PSScriptRoot 'prince-and-the-nymph-boot.atr'
$module = Join-Path $PSScriptRoot 'AltirraTools.psm1'
if (-not (Test-Path -LiteralPath $module -PathType Leaf)) {
    $module = Join-Path $PSScriptRoot '../../../atari-vbxe-toolkit/scripts/AltirraTools.psm1'
}
foreach ($file in @($disk, $module)) {
    if (-not (Test-Path -LiteralPath $file -PathType Leaf)) { throw "Required game file not found: $file" }
}
if ($Check) {
    Write-Output "Boot disk: $disk"
    exit 0
}
Import-Module $module -Force
$emulator = Get-AltirraPath -ExplicitPath $AltirraPath
# Altirra cannot boot an image from the \\wsl.localhost share; boot a local copy.
if ($disk.StartsWith('\\')) {
    $local = Join-Path $env:TEMP 'prince-and-the-nymph-boot.atr'
    Copy-Item -LiteralPath $disk -Destination $local -Force
    $disk = $local
}
# Preserve the user's configured hardware and persistent VBXE profile.
# A bare image path mounts the disk in D1 and cold-boots it; the disk's own
# loader switches BASIC off and loads the game and its pictures.
$arguments = @('/nosi', '/w', '/noautoprofile', ('"' + $disk + '"'))
$process = Start-Process -FilePath $emulator -ArgumentList $arguments -PassThru
Write-Output ('Started Altirra PID ' + $process.Id)
Write-Output ('Boot disk D1: ' + $disk)
