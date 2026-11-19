param([string]$OutputDirectory, [switch]$CheckEdges, [switch]$CheckShield, [switch]$LongRun, [switch]$CheckDebugJump, [switch]$CheckSpriteWaves, [switch]$CheckBossActions, [switch]$CheckBossExit, [switch]$CheckBossPerformance, [switch]$CheckBossMeteorDeath, [switch]$CheckMeteorEdges, [switch]$CheckPendingSprites, [switch]$CheckClock, [switch]$CheckBossDefeat, [switch]$PerformanceContinuous, [string]$GamePath, [string]$FirstCycles='1312D00', [ValidateRange(1,7)][int]$DebugKey=1)
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
if ($CheckDebugJump) {
    # Protect the diagnostic pilot while waiting for the shortcut. A blocking
    # death animation does not poll keyboard shortcuts.
    $commands=@(foreach ($command in $commands) {
        if ($command -eq 'gcr $989680') {'e F0BF FF'}
        $command
    })
}
if ($CheckDebugJump -or $CheckSpriteWaves -or $CheckBossActions -or $CheckBossExit -or $CheckBossPerformance -or $CheckBossMeteorDeath -or $CheckMeteorEdges -or $CheckPendingSprites -or $CheckClock -or $CheckBossDefeat) {
    $commands=$commands[0..($commands.Count-3)]
    # Simulate a held debug number at the two POKEY read sites, then restore runtime code.
    $keyCode=@(0x1F,0x1E,0x1A,0x18,0x1D,0x1B,0x33)[$DebugKey-1]
    $previewCycles=if ($DebugKey -ge 6) {'400000'} else {'989680'}
    # The distributed XEX stays unchanged.
    $commands+=@('e 3F50 A9 00 EA',('e 3F57 A9 {0:X2} EA' -f $keyCode),'gcr $200000',
        'e 3F50 AD 0F D2','e 3F57 AD 09 D2','e F398 00','e F0BF FF','db 2D20 L10','db FB8A L2','db FD04 L7',
        ('gcr $'+$previewCycles),
        ('.autotest_saveimage "'+(Join-Path $OutputDirectory 'debug-boss.png')+'"'),
        'db 2D20 L10','r','.logclose','.autotest_exit')
}
if ($CheckBossDefeat) {
    $commands=$commands[0..($commands.Count-3)]
    $guardian=if ($DebugKey -eq 6) {'01'} else {'00'}
    $commands+=@(('e FD04 '+$guardian),'e FD0A 00','e 2D20 04','e 2D22 00 58 30','e 2DC0 01 00','e 2D90 00','e F398 00','e F0BF FF')
    foreach ($frame in 1..28) {
        $commands+=@('gcr $20000','db 2DC0 L2','db 1BE0 L8','db E957 L2',
          ('.autotest_saveimage "'+(Join-Path $OutputDirectory ('defeat-'+$frame+'.png'))+'"'))
    }
    $commands+=@('.logclose','.autotest_exit')
}
if ($CheckClock) {
    $commands=$commands[0..($commands.Count-3)]
    # Exercise the actual clock-key handler; leave the distributed XEX untouched.
    $commands+=@('e F398 00','e F0BF FF','e 2D90 00 03 00 00 00',
      'e 2E2F A9 00 EA','e 2E36 A9 17 EA','gcr $20000',
      'e 2E2F AD 0F D2','e 2E36 AD 09 D2','db 2D90 L10',
      ('.autotest_saveimage "'+(Join-Path $OutputDirectory 'clock-active.png')+'"'),
      'gcr $300000','db 2D90 L10',
      ('.autotest_saveimage "'+(Join-Path $OutputDirectory 'clock-midpoint.png')+'"'),
      'gcr $300000','db 2D90 L10',
      ('.autotest_saveimage "'+(Join-Path $OutputDirectory 'clock-expired.png')+'"'),
      '.logclose','.autotest_exit')
}
if ($CheckPendingSprites) {
    $commands=$commands[0..($commands.Count-3)]
    # Hold the mover while exercising real render/scroll/restore loops.
    # Pending state and coordinates reproduce the incoming-edge placeholders.
    # Disable player-shot hits during the artificial hold so they cannot turn
    # these pending actors into intentionally visible explosion frames.
    $commands+=@('e 3B03 60','e F7F5 EA EA EA','e FD04 00','e 1BE0 00 00 00 00 00 00 00 00')
    foreach ($mode in @(2,3,0)) {
        $commands+=@(('e 2D20 {0:X2} 00' -f $mode),'e F398 00','e F0BF FF',
          'e 74E0 10 10 10 10 10 10 10 10','e 7482 00 00 00 00 00 00 00 00',
          'e 2D40 80 80 80 80 80 80 80 80','e 746A 00 10 20 30 40 50 60 70')
        if ($mode -eq 0) {$commands+=@('e 7444 60','e 7462 1C 1C 1C 1C 1C 1C 1C 1C')}
        else {$commands+=@('e 7444 00','e 7462 7C 7C 7C 7C 7C 7C 7C 7C')}
        foreach ($sample in 1..3) {
            $commands+=@('gcr $80000',
              ('.autotest_saveimage "'+(Join-Path $OutputDirectory ('pending-'+$mode+'-'+$sample+'.png'))+'"'),
              'db 74A8 L20','db 2D20 L2','db 7444 L3')
        }
    }
    $commands+=@('e 3B03 4C','e F7F5 20 27 FA','gcr $200000',
      ('.autotest_saveimage "'+(Join-Path $OutputDirectory 'pending-resumed.png')+'"'),
      'db 2D20 L2','.logclose','.autotest_exit')
}
if ($CheckMeteorEdges) {
    $commands=$commands[0..($commands.Count-3)]
    foreach ($direction in @(1,2,3,6)) {
        $commands+=@('e F398 00','e F0BF FF','e 2D22 15','e FD0A 25',
          ('e 2DC0 05 00 5D 00 02 00 03 {0:X2}' -f $direction),
          'e 2D23 80 30','e 1BE0 00 00 00 00 00 00 00 00',
          'e 2DE0 00 28 38 48 58 68 78 88','gcr $400000',
          ('.autotest_saveimage "'+(Join-Path $OutputDirectory ('meteor-entry-'+$direction+'.png'))+'"'),
          'gcr $800000',
          ('.autotest_saveimage "'+(Join-Path $OutputDirectory ('meteor-moving-'+$direction+'.png'))+'"'),
          'e 2DC0 07','gcr $A00000',
          ('.autotest_saveimage "'+(Join-Path $OutputDirectory ('meteor-drained-'+$direction+'.png'))+'"'),
          'db 2DC0 L9','db 1BE0 L8')
    }
    $commands+=@('.logclose','.autotest_exit')
}
if ($CheckBossMeteorDeath) {
    $commands=$commands[0..($commands.Count-3)]
    # Real collision in the right-to-left meteor phase, with no immunity.
    # Scroll phase 1 reproduces the old respawn wait deadlock.
    $commands+=@('e 2DC0 05 00 5D 00 02 00 03 03','e 2D23 80 30',
      'e 2D22 15','e FD0A 25','e 2D61 00','e F398 00','e F0BF 00','e E957 0C 38','e 4E78 03',
      'e 758E 01','e 1BE0 00 01 00 00 00 00 00 00','e 1BE8 00 64 00 00 00 00 00 00',
      'e 2DE0 FF FF FF FF FF FF FF FF','gcr $200000',
      'db F398 L1','db 4E78 L1','db 758E L1','db 2DC0 L9',
      ('.autotest_saveimage "'+(Join-Path $OutputDirectory 'meteor-respawn.png')+'"'),
      'gcr $800000','db F398 L1','db 4E78 L1','db 2DC0 L9','db 2D22 L1','db FD0A L1','db 2D20 L1',
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
if ($LongRun -or $CheckSpriteWaves -or $CheckBossActions -or $CheckMeteorEdges) {$timeout=180000}
if (!$p.WaitForExit($timeout)) {$p.Kill();Remove-Item -LiteralPath $testConfig -Force;throw 'Emulator verification timed out.'}
Remove-Item -LiteralPath $testConfig -Force
if ($p.ExitCode -ne 0) {throw ('Emulator exited with code '+$p.ExitCode)}
foreach ($name in @('direct-start.png','flight.png','flight-later.png')) {
    $capture=Get-Item -LiteralPath (Join-Path $OutputDirectory $name)
    if ($capture.LastWriteTime -lt $started) {throw ('Missing fresh emulator capture: '+$name)}
}
if ((Get-Content -Raw -LiteralPath $log) -match 'Illegal instruction hit') {throw 'Emulator hit an illegal instruction; inspect gameplay.log.'}
if ($CheckBossDefeat) {
    $trace=Get-Content -Raw -LiteralPath $log
    if ($trace -notmatch '(?im)^2DC0: 09 ') {throw 'Boss defeat burst never started.'}
    if ($trace -notmatch '(?im)^1BE0: 01 01 01 01 01 01 01 01') {throw 'Missing eight-shot defeat burst.'}
}
if ($CheckClock) {
    $trace=Get-Content -Raw -LiteralPath $log
    $states=[regex]::Matches($trace,'(?im)^2D90:\s+([0-9A-F]{2}) ([0-9A-F]{2})')
    if ($states.Count -ne 3) {throw 'Missing clock duration samples.'}
    $first=[Convert]::ToInt32($states[0].Groups[1].Value,16)
    $middle=[Convert]::ToInt32($states[1].Groups[1].Value,16)
    if ($first -lt 140 -or $middle -le 0 -or $middle -ge $first -or $states[2].Groups[1].Value -ne '00') {throw 'Clock did not run for three seconds of PAL display time.'}
    foreach ($state in $states) {if ($state.Groups[2].Value -ne '02') {throw 'Clock activation did not spend exactly one charge.'}}
}
if ($CheckPendingSprites -and !$GamePath) {
    $trace=Get-Content -Raw -LiteralPath $log
    $records=[regex]::Matches($trace,'(?im)^74(?:A8|B8):\s+((?:[0-9A-F]{2}\s+){16})')
    if ($records.Count -ne 18) {throw 'Missing pending-sprite framebuffer checks.'}
    foreach ($record in $records) {
        $values=$record.Groups[1].Value.Trim() -split '\s+'
        for ($i=1;$i -lt 16;$i+=2) {
            if ([Convert]::ToInt32($values[$i],16) -ge 128) {throw 'A pending actor was drawn and saved into a framebuffer.'}
        }
    }
    if ($trace -notmatch '(?im)^2D20:\s+00 01\s') {throw 'Ordinary wave did not resume movement after the pending-state check.'}
}
if ($CheckBossMeteorDeath) {
    $trace=Get-Content -Raw -LiteralPath $log
    $deaths=@([regex]::Matches($trace,'(?im)^F398:\s+([0-9A-F]{2})') | ForEach-Object {$_.Groups[1].Value})
    $lives=@([regex]::Matches($trace,'(?im)^4E78:\s+([0-9A-F]{2})') | ForEach-Object {$_.Groups[1].Value})
    if ($deaths.Count -lt 2 -or $deaths[-1] -ne '00' -or $lives[-1] -ne '02') {
        throw 'Meteor collision did not finish respawning with exactly one life spent.'
    }
}
if ($CheckBossMeteorDeath) {
    $hpAddress=if ($DebugKey -eq 6) {'FD0A'} else {'2D22'}
    $expected=if ($DebugKey -eq 6) {'25'} else {'15'}
    if ($trace -notmatch ('(?im)^'+$hpAddress+':\s+'+$expected+'\s')) {
        throw 'Boss health changed during player respawn.'
    }
    $modes=@([regex]::Matches($trace,'(?im)^2D20:\s+([0-9A-F]{2})') | ForEach-Object {$_.Groups[1].Value})
    if ($DebugKey -eq 1 -and ($modes.Count -eq 0 -or $modes[-1] -ne '04')) {
        throw 'Player respawn left the living sub-boss encounter.'
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
if ($CheckDebugJump -and $DebugKey -eq 6 -and (Get-Content -Raw -LiteralPath $log) -notmatch '(?i)2D20:\s+07') {throw 'Debug shortcut did not enter the mixed meteor/enemy encounter.'}
Write-Output ('Altirra exit code: '+$p.ExitCode)

if ($CheckDebugJump -and $DebugKey -eq 7 -and (Get-Content -Raw -LiteralPath $log) -notmatch '(?i)2D20:\s+05') {throw 'Debug shortcut did not enter diagonal meteors.'}
