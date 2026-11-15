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
# Altirra cannot boot an image from the WSL share. Compare game bytes,
# excluding the mutable save sector, so saving cannot hide a newer build.
function Sync-BootDisk([string]$Source, [string]$Destination, [int]$SaveSector) {
    $sourceBytes = [IO.File]::ReadAllBytes($Source)
    $offset = 16 + 384 + ($SaveSector - 4) * 256
    if ($SaveSector -lt 4 -or $offset + 256 -gt $sourceBytes.Length) { throw 'Invalid save-sector layout' }
    if (-not (Test-Path -LiteralPath $Destination)) {
        [IO.File]::WriteAllBytes($Destination, $sourceBytes)
        return
    }
    $cachedBytes = [IO.File]::ReadAllBytes($Destination)
    $saved = $null
    if ($offset + 256 -le $cachedBytes.Length) {
        $saved = New-Object byte[] 256
        [Array]::Copy($cachedBytes, $offset, $saved, 0, 256)
        [Array]::Clear($cachedBytes, $offset, 256)
    }
    [Array]::Clear($sourceBytes, $offset, 256)
    $sha = [Security.Cryptography.SHA256]::Create()
    try {
        $same = [Convert]::ToBase64String($sha.ComputeHash($sourceBytes)) -eq [Convert]::ToBase64String($sha.ComputeHash($cachedBytes))
    } finally { $sha.Dispose() }
    if ($same) { return }
    # Keep a recoverable copy before upgrading the cached disk.
    Copy-Item -LiteralPath $Destination -Destination ($Destination + '.previous') -Force
    if ($null -ne $saved -and [Text.Encoding]::ASCII.GetString($saved,0,4) -eq 'NYS1' -and $saved[4] -in @(42,43)) {
        [Array]::Copy($saved, 0, $sourceBytes, $offset, 256)
    }
    [IO.File]::WriteAllBytes($Destination, $sourceBytes)
}
if ($disk.StartsWith('\\')) {
    $local = Join-Path $env:TEMP 'prince-and-the-nymph-boot.atr'
    $layout = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'city/generated/story-layout.json') -Raw | ConvertFrom-Json
    Sync-BootDisk $disk $local $layout.saveSector
    $disk = $local
}
# Preserve the user's configured hardware and persistent VBXE profile.
# /bootrw mounts the disk in D1 read/write (so the save slot persists) and
# cold-boots it; the disk's own loader switches BASIC off and loads the game.
$arguments = @('/nosi', '/w', '/noautoprofile', '/bootrw', ('"' + $disk + '"'))
$process = Start-Process -FilePath $emulator -ArgumentList $arguments -PassThru
Write-Output ('Started Altirra PID ' + $process.Id)
Write-Output ('Boot disk D1: ' + $disk)
