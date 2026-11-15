param([string]$OutputDirectory, [switch]$CheckEdges, [switch]$CheckShield, [switch]$LongRun, [string]$GamePath, [string]$FirstCycles='1312D00')
$ErrorActionPreference='Stop'
$game=Join-Path $PSScriptRoot 'kult-diabolic.xex'
if ($GamePath) {$game=$GamePath}
if (!(Test-Path -LiteralPath $game)) {throw 'Build the XEX first.'}
$config=Join-Path $PSScriptRoot '..\..\babajaga\altirra-standard.ini'
$emulator=Join-Path $env:USERPROFILE 'OneDrive\Desktop\atari\emulator\Altirra64.exe'
if (!$OutputDirectory) {$OutputDirectory=Join-Path $PSScriptRoot 'verification'}
# Automated runs must keep advancing if another application takes focus.
# Use a disposable copy; never change the user's normal emulator profile.
$testConfig=[System.IO.Path]::GetTempFileName()
$profileText=[System.IO.File]::ReadAllText($config).Replace('"Pause when inactive" = 1','"Pause when inactive" = 0')
[System.IO.File]::WriteAllText($testConfig,$profileText,(New-Object System.Text.UTF8Encoding($false)))
$config=$testConfig
$log=Join-Path $OutputDirectory 'gameplay.log'
$commands=@(
('.logopen "'+$log+'"'),
('gcr $'+$FirstCycles),
('.autotest_saveimage "'+(Join-Path $OutputDirectory 'direct-start.png')+'"'),
'db 2D20 L10','db 2F00 L20','db 7A00 L30','db 7AC0 L30','db 743A L8',
# No emulator RAM edits: the distributed executable starts flight itself.
'gcr $989680',
('.autotest_saveimage "'+(Join-Path $OutputDirectory 'flight.png')+'"'),
'.gtia', 'db 3640 L40', 'db 2C0 L10', 'db 43FF L1','db 4E75 L10', 'db 4000 L10', 'db 22F L1', 'r',
'gcr $989680',
('.autotest_saveimage "'+(Join-Path $OutputDirectory 'flight-later.png')+'"'),
'db 43FF L1','db 4E75 L10','r','.logclose','.autotest_exit')
if ($LongRun) {
    $commands=$commands[0..($commands.Count-3)]
    $commands+=@('gcr $6000000','db C298 L2','r',
        ('.autotest_saveimage "'+(Join-Path $OutputDirectory 'long-run.png')+'"'),
        '.logclose','.autotest_exit')
}
if ($CheckShield) {
    $commands=$commands[0..($commands.Count-3)]
    # Diagnostic visual check only; the executable is never patched.
    $commands+=@('e 2D61 11','e F0BF 20','e F398 00','e E957 30 38','gcr $40000',
        ('.autotest_saveimage "'+(Join-Path $OutputDirectory 'shield.png')+'"'),
        '.gtia','db 2D60 L4','.logclose','.autotest_exit')
}
if ($CheckEdges) {
    $commands=$commands[0..($commands.Count-3)]
    $commands+=Get-Content -LiteralPath (Join-Path $PSScriptRoot 'verification\edge-check.commands')
    $commands+=@('gcr $80000',('.autotest_saveimage "'+(Join-Path $OutputDirectory 'edges.png')+'"'),'.logclose','.autotest_exit')
}
$argsList=@('/nosi','/w','/portablealt',('"'+$config+'"'),'/noautoprofile','/hardware','800xl','/memsize','64K','/pal','/nobasic','/nostereo','/cleardevices','/run',('"'+$game+'"'),'/autotest','/debug')
foreach($cmd in $commands){$argsList+=('/debugcmd:"'+$cmd.Replace('"','\"')+'"')}
$started=Get-Date
$p=Start-Process -FilePath $emulator -ArgumentList $argsList -PassThru
$timeout=60000
if ($LongRun) {$timeout=180000}
if (!$p.WaitForExit($timeout)) {$p.Kill();Remove-Item -LiteralPath $testConfig -Force;throw 'Emulator verification timed out.'}
Remove-Item -LiteralPath $testConfig -Force
if ($p.ExitCode -ne 0) {throw ('Emulator exited with code '+$p.ExitCode)}
foreach ($name in @('direct-start.png','flight.png','flight-later.png')) {
    $capture=Get-Item -LiteralPath (Join-Path $OutputDirectory $name)
    if ($capture.LastWriteTime -lt $started) {throw ('Missing fresh emulator capture: '+$name)}
}
if ((Get-Content -Raw -LiteralPath $log) -match 'Illegal instruction hit') {throw 'Emulator hit an illegal instruction; inspect gameplay.log.'}
Write-Output ('Altirra exit code: '+$p.ExitCode)
