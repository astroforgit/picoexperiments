param(
    [Parameter(Mandatory = $true)] [string] $DiskPath,
    [Parameter(Mandatory = $true)] [string] $ToolkitPath,
    [string] $VerifyDirectory,
    [switch] $PrintCommand
)
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $ToolkitPath 'scripts\AltirraTools.psm1') -Force
$emulator = Get-AltirraPath
if (-not (Test-Path -LiteralPath $DiskPath -PathType Leaf)) { throw "Disk not found: $DiskPath" }
$image = (Resolve-Path -LiteralPath $DiskPath).ProviderPath
switch ([IO.Path]::GetExtension($image).ToLowerInvariant()) {
    '.atr' { $loadSwitch = '/disk' }
    '.xex' { $loadSwitch = '/run' }
    default { throw 'Choose an ATR disk or XEX executable.' }
}
# Same isolated portable-config pattern as steamlinejs/atari/run-standard.ps1.
# /tempprofile alone still INHERITS the VBXE registry profile; /portablealt does not.
$settings = Join-Path $PSScriptRoot 'altirra-standard.ini'
if (-not (Test-Path -LiteralPath $settings)) {
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'altirra-standard-defaults.ini') -Destination $settings
}
$arguments = @('/nosi', '/w', '/portablealt', ('"' + $settings + '"'), '/noautoprofile',
    '/hardware', '800xl', '/memsize', '64K', '/pal', '/nobasic', '/nostereo', '/cleardevices',
    $loadSwitch, ('"' + $image + '"'))
if ($VerifyDirectory) {
    $log = Join-Path $VerifyDirectory 'boot.log'
    $png = Join-Path $VerifyDirectory 'boot.png'
    $png2 = Join-Path $VerifyDirectory 'timed-frame.png'
    $arguments += @('/autotest', '/debug',
        ('/debugcmd:".logopen \"' + $log + '\""'),
        '/debugcmd:"gcr $1312D00"',
        ('/debugcmd:".autotest_saveimage \"' + $png + '\""'),
        '/debugcmd:"gcr $1312D00"',
        ('/debugcmd:".autotest_saveimage \"' + $png2 + '\""'),
        '/debugcmd:"r"', '/debugcmd:".autotest_listdevices"', '/debugcmd:".pokey"', '/debugcmd:".logclose"', '/debugcmd:".autotest_exit"')
}
if ($PrintCommand) {
    Write-Output ($emulator + ' ' + ($arguments -join ' '))
    exit 0
}
$timer = [Diagnostics.Stopwatch]::StartNew()
$process = Start-Process -FilePath $emulator -ArgumentList $arguments -PassThru
Write-Output ('Started Altirra PID ' + $process.Id)
Write-Output ($loadSwitch + ': ' + $image)
Write-Output 'Standard Atari 800XL, 64 KB, PAL, one POKEY, BASIC/VBXE disabled.'
Write-Output ('Separate configuration: ' + $settings)
Write-Output 'Controls: arrow keys move; left Ctrl is joystick Fire.'
if ($VerifyDirectory) {
    $process.WaitForExit()
    $timer.Stop()
    $result = [ordered]@{ exitCode=$process.ExitCode; elapsedSeconds=[Math]::Round($timer.Elapsed.TotalSeconds,2); cycles=40000000; expectedEmulatedSeconds=22.55; steadyIntervalSeconds=[Math]::Round(((Get-Item -LiteralPath $png2).LastWriteTimeUtc - (Get-Item -LiteralPath $png).LastWriteTimeUtc).TotalSeconds,2); expectedSteadyIntervalSeconds=11.28; configuration=$settings }
    $result | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $VerifyDirectory 'timing.json')
    $result | ConvertTo-Json | Write-Output
}
