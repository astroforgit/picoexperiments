param([switch]$Check, [string]$AltirraPath)
$ErrorActionPreference = 'Stop'
$image = Join-Path $PSScriptRoot 'heroes-outro-full-quality-test.xex'
$story = Join-Path $PSScriptRoot 'prince-and-the-nimf.atr'
$module = Join-Path $PSScriptRoot 'AltirraTools.psm1'
if (-not (Test-Path -LiteralPath $module -PathType Leaf)) {
    $module = Join-Path $PSScriptRoot '../../../atari-vbxe-toolkit/scripts/AltirraTools.psm1'
}
foreach ($file in @($image, $story, $module)) {
    if (-not (Test-Path -LiteralPath $file -PathType Leaf)) { throw "Required game file not found: $file" }
}
if ($Check) {
    Write-Output "Game: $image"
    Write-Output "Story disk: $story"
    exit 0
}
Import-Module $module -Force
$emulator = Get-AltirraPath -ExplicitPath $AltirraPath
# Preserve the user's configured hardware and persistent VBXE profile.
# /disk attaches the companion image to D1; /run loads the game executable.
$arguments = @('/nosi', '/w', '/noautoprofile', '/disk', ('"' + $story + '"'), '/run', ('"' + $image + '"'))
$process = Start-Process -FilePath $emulator -ArgumentList $arguments -PassThru
Write-Output ('Started Altirra PID ' + $process.Id)
Write-Output ('Game: ' + $image)
Write-Output ('Story disk D1: ' + $story)
