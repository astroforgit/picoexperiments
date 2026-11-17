param([string]$OutputDirectory, [switch]$CheckEdges, [switch]$CheckShield, [switch]$LongRun, [switch]$CheckDebugJump, [switch]$CheckSpriteWaves, [switch]$CheckBossActions, [switch]$CheckBossExit, [switch]$CheckBossPerformance, [switch]$CheckBossMeteorDeath, [switch]$PerformanceContinuous, [string]$GamePath, [string]$FirstCycles='1312D00', [ValidateRange(1,6)][int]$DebugKey=1)
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
if ($CheckDebugJump -or $CheckSpriteWaves -or $CheckBossActions -or $CheckBossExit -or $CheckBossPerformance -or $CheckBossMeteorDeath) {
    $commands=$commands[0..($commands.Count-3)]
    # Simulate a held debug number at the two POKEY read sites, then restore runtime code.
    $keyCode=@(0x1F,0x1E,0x1A,0x18,0x1D,0x1B)[$DebugKey-1]
    # The distributed XEX stays unchanged.
    $commands+=@('e 3F50 A9 00 EA',('e 3F57 A9 {0:X2} EA' -f $keyCode),'gcr $200000',
        'e 3F50 AD 0F D2','e 3F57 AD 09 D2','e F398 00','e F0BF FF','db 2D20 L10','db FB8A L2','db FD04 L7',
        'gcr $989680',
        ('.autotest_saveimage "'+(Join-Path $OutputDirectory 'debug-boss.png')+'"'),
        'db 2D20 L10','r','.logclose','.autotest_exit')
}
if ($CheckBossMeteorDeath) {
    $commands=$commands[0..($commands.Count-3)]
    # Real collision in the right-to-left meteor phase, with no immunity.
    # Scroll phase 1 reproduces the old respawn wait deadlock.
    $commands+=@('e 2DC0 05 00 5D 00 02 00 03 03','e 2D23 80 30',
      'e 2D61 00','e F398 00','e F0BF 00','e E957 0C 38','e 4E78 03',
      'e 758E 01','e 1BE0 00 01 00 00 00 00 00 00','e 1BE8 00 64 00 00 00 00 00 00',
      'e 2DE0 FF FF FF FF FF FF FF FF','gcr $200000',
      'db F398 L1','db 4E78 L1','db 758E L1','db 2DC0 L9',
      ('.autotest_saveimage "'+(Join-Path $OutputDirectory 'meteor-respawn.png')+'"'),
      'gcr $800000','db F398 L1','db 4E78 L1','db 2DC0 L9',
      ('.autotest_saveimage "'+(Join-Path $OutputDirectory 'meteor-after-respawn.png')+'"'),
      '.logclose','.autotest_exit')
}
if ($CheckBossPerformance) {
    $commands=$commands[0..($commands.Count-3)]
    # Count actual controller updates over fixed emulated CPU-cycle windows.
    # Diagnostic wrapper and state changes never touch the executable on disk.
    $commands+=@('e 2DF8 EE F0 2D 4C C0 DA','e F80E 20 F8 2D')
    foreach ($sample in 1..8) {
        $commands+=@('e F398 00','e F0BF FF','e 2D22 FF','e FD0A FF')
        if ($sample -eq 1 -or !$PerformanceContinuous) {
            $commands+=@('e 2DC0 01 00 5D 00 01 00 03','e 2D23 58 30',
              'e 1BE0 01 01 01 01 01 01 00 00','e 1BD0 70 70 70 70 70 70 00 00',
              'e 1BD8 00 14 28 3C 50 64 00 00','e 1BC0 01 01 01 01 01 01 00 00')
        }
        $commands+=@('e 2DF0 00','gcr $100000','db 2DF0 L1')
    }
    $commands+=@('.logclose','.autotest_exit')
}
if ($CheckBossExit) {
    $commands=$commands[0..($commands.Count-3)]
    $commands+=@('e 2DC0 03 00 96 05 01','e 2D23 58 30','e 1BE0 00 00 00 00 00 00 00 00')
    foreach ($frame in 1..36) {
        $commands+=@('e F398 00','e F0BF FF','e 2D22 FF','e FD0A FF','gcr $18000',
            ('.autotest_saveimage "'+(Join-Path $OutputDirectory ('boss-exit-'+$frame+'.png'))+'"'),
            'db 2DC0 L9','db 2D23 L2')
    }
    $commands+=@('.logclose','.autotest_exit')
}
if ($CheckBossActions -or $CheckSpriteWaves) {
    $commands=$commands[0..($commands.Count-3)]
    # Deterministic diagnostic seed; preserve the distributed executable.
    $commands+=@('e 2DC0 01 00 01','e 2DC4 01','e 2D23 58 30','e 1BE0 00 00 00 00 00 00 00 00')
    foreach ($frame in 1..48) {
        $commands+=@('e F398 00','e F0BF FF','e 2D22 FF','e FD0A FF','gcr $200000',
            ('.autotest_saveimage "'+(Join-Path $OutputDirectory ('boss-action-'+$frame+'.png'))+'"'),
            'db 2DC0 L9','db 2D23 L2','db 1740 L40','db FCFA L10','r')
    }
    $commands+=@('.logclose','.autotest_exit')
}
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
if ($LongRun -or $CheckSpriteWaves -or $CheckBossActions) {$timeout=180000}
if (!$p.WaitForExit($timeout)) {$p.Kill();Remove-Item -LiteralPath $testConfig -Force;throw 'Emulator verification timed out.'}
Remove-Item -LiteralPath $testConfig -Force
if ($p.ExitCode -ne 0) {throw ('Emulator exited with code '+$p.ExitCode)}
foreach ($name in @('direct-start.png','flight.png','flight-later.png')) {
    $capture=Get-Item -LiteralPath (Join-Path $OutputDirectory $name)
    if ($capture.LastWriteTime -lt $started) {throw ('Missing fresh emulator capture: '+$name)}
}
if ((Get-Content -Raw -LiteralPath $log) -match 'Illegal instruction hit') {throw 'Emulator hit an illegal instruction; inspect gameplay.log.'}
if ($CheckBossMeteorDeath) {
    $trace=Get-Content -Raw -LiteralPath $log
    $deaths=@([regex]::Matches($trace,'(?im)^F398:\s+([0-9A-F]{2})') | ForEach-Object {$_.Groups[1].Value})
    $lives=@([regex]::Matches($trace,'(?im)^4E78:\s+([0-9A-F]{2})') | ForEach-Object {$_.Groups[1].Value})
    if ($deaths.Count -lt 2 -or $deaths[-1] -ne '00' -or $lives[-1] -ne '02') {
        throw 'Meteor collision did not finish respawning with exactly one life spent.'
    }
}
if ($CheckBossPerformance) {
    $trace=Get-Content -Raw -LiteralPath $log
    $counts=@([regex]::Matches($trace,'(?im)^2DF0:\s+([0-9A-F]{2})') | ForEach-Object {[Convert]::ToInt32($_.Groups[1].Value,16)})
    if ($counts.Count -ne 8 -or ($counts | Where-Object {$_ -eq 0}).Count -gt 0) {throw 'Missing boss update measurements.'}
    Write-Output ('Boss updates per 1048576 cycles: '+($counts -join ', '))
}
if ($CheckBossExit) {
    $trace=Get-Content -Raw -LiteralPath $log
    $positions=@([regex]::Matches($trace,'(?im)^2D23:\s+([0-9A-F]{2})') | ForEach-Object {[Convert]::ToInt32($_.Groups[1].Value,16)})
    if ($positions.Count -lt 20 -or $positions[-1] -ne 128) {throw 'Boss did not complete its rightward exit.'}
    for ($i=1;$i -lt $positions.Count;$i++) {
        $step=$positions[$i]-$positions[$i-1]
        if ($step -lt 0 -or $step -gt 2) {throw 'Boss exit jumped instead of moving gradually.'}
    }
}
if ($CheckDebugJump -and $DebugKey -eq 1 -and (Get-Content -Raw -LiteralPath $log) -notmatch '(?i)2D20:\s+04') {throw 'Debug shortcut did not enter the skull encounter.'}
if ($CheckBossActions -or $CheckSpriteWaves) {
    $trace=Get-Content -Raw -LiteralPath $log
    foreach ($phase in @('01','02','04','05')) {
        if ($trace -notmatch ('(?im)^2DC0:\s+'+$phase+'\s')) {throw ('Boss action not observed: '+$phase)}
    }
}
if ($CheckDebugJump -and $DebugKey -eq 6 -and (Get-Content -Raw -LiteralPath $log) -notmatch '(?i)FD04:\s+01') {throw 'Debug shortcut did not enter the Insect Queen guardian encounter.'}
Write-Output ('Altirra exit code: '+$p.ExitCode)
