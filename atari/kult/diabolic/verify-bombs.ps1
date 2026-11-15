param([string]$OutputDirectory, [string]$GamePath)
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
# This diagnostic overrides only the Shift status read in temporary emulator
# RAM, then restores the hardware read. The distributed XEX is not modified.
$listing=[System.IO.File]::ReadAllText((Join-Path $PSScriptRoot 'hud.lst'))
$bombKey=[regex]::Match($listing,'(?m)^\s*\d+\s+([0-9A-F]{4})\s+BombKey\s*$').Groups[1].Value
if (!$bombKey) {throw 'Build the game first to generate hud.lst.'}
$commands=@(('.logopen "'+$log+'"'),'gcr $1312D00','db 64A4 L30',
('e '+$bombKey+' A9 00 EA'),'gcr $200000','db 2D70 L4','db 4014 L3',
('e '+$bombKey+' A9 08 EA'),'gcr $100000',('e '+$bombKey+' A9 00 EA'),'gcr $200000','db 2D70 L4',
('e '+$bombKey+' A9 08 EA'),'gcr $100000',('e '+$bombKey+' A9 00 EA'),'gcr $200000','db 2D70 L4',
('e '+$bombKey+' AD 0F D2'),'gcr $2000000','db 4014 L3',
('.autotest_saveimage "'+(Join-Path $OutputDirectory 'after-bombs.png')+'"'),
'.logclose','.autotest_exit')
$argsList=@('/nosi','/w','/portablealt',('"'+$config+'"'),'/noautoprofile','/hardware','800xl','/memsize','64K','/pal','/nobasic','/nostereo','/cleardevices','/run',('"'+$game+'"'),'/autotest','/debug')
foreach($cmd in $commands){$argsList+=('/debugcmd:"'+$cmd.Replace('"','\"')+'"')}
$started=Get-Date
$p=Start-Process -FilePath $emulator -ArgumentList $argsList -PassThru
$timeout=60000
if (!$p.WaitForExit($timeout)) {$p.Kill();Remove-Item -LiteralPath $testConfig -Force;throw 'Emulator verification timed out.'}
Remove-Item -LiteralPath $testConfig -Force
if ($p.ExitCode -ne 0) {throw ('Emulator exited with code '+$p.ExitCode)}
$text=Get-Content -Raw -LiteralPath $log
if ($text -match 'Illegal instruction hit') {throw 'Bomb test hit an illegal instruction'}
$stocks=@([regex]::Matches($text,'(?m)^2D70: ([0-9A-F]{2})') | ForEach-Object {$_.Groups[1].Value})
if (($stocks -join ',') -ne '02,01,00') {throw ('Incorrect bomb consumption: '+($stocks -join ','))}
if ($text -notmatch '4014: 8D 1B 60') {throw 'Space runtime code was damaged'}
Write-Output ('Exit: '+$p.ExitCode)
