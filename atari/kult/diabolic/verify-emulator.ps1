param([string]$OutputDirectory, [switch]$CheckEdges, [string]$GamePath)
$ErrorActionPreference='Stop'
$game=Join-Path $PSScriptRoot 'kult-diabolic.xex'
if ($GamePath) {$game=$GamePath}
if (!(Test-Path -LiteralPath $game)) {throw 'Build the XEX first.'}
$config=Join-Path $PSScriptRoot '..\..\babajaga\altirra-standard.ini'
$emulator=Join-Path $env:USERPROFILE 'OneDrive\Desktop\atari\emulator\Altirra64.exe'
if (!$OutputDirectory) {$OutputDirectory=Join-Path $PSScriptRoot 'verification'}
$log=Join-Path $OutputDirectory 'gameplay.log'
$commands=@(
('.logopen "'+$log+'"'),
'gcr $1312D00',
('.autotest_saveimage "'+(Join-Path $OutputDirectory 'direct-start.png')+'"'),
# No emulator RAM edits: the distributed executable starts flight itself.
'gcr $989680',
('.autotest_saveimage "'+(Join-Path $OutputDirectory 'flight.png')+'"'),
'.gtia', 'db 3640 L40', 'db 2C0 L10', 'db 43FF L1','db 4E75 L10', 'db 4000 L10', 'db 22F L1', 'r',
'gcr $989680',
('.autotest_saveimage "'+(Join-Path $OutputDirectory 'flight-later.png')+'"'),
'db 43FF L1','db 4E75 L10','r','.logclose','.autotest_exit')
if ($CheckEdges) {
    $commands=$commands[0..($commands.Count-3)]
    $commands+=Get-Content -LiteralPath (Join-Path $PSScriptRoot 'verification\edge-check.commands')
    $commands+=@('gcr $80000',('.autotest_saveimage "'+(Join-Path $OutputDirectory 'edges.png')+'"'),'.logclose','.autotest_exit')
}
$argsList=@('/nosi','/w','/portablealt',('"'+$config+'"'),'/noautoprofile','/hardware','800xl','/memsize','64K','/pal','/nobasic','/nostereo','/cleardevices','/run',('"'+$game+'"'),'/autotest','/debug')
foreach($cmd in $commands){$argsList+=('/debugcmd:"'+$cmd.Replace('"','\"')+'"')}
$started=Get-Date
$p=Start-Process -FilePath $emulator -ArgumentList $argsList -PassThru
if (!$p.WaitForExit(60000)) {$p.Kill();throw 'Emulator verification timed out.'}
foreach ($name in @('direct-start.png','flight.png','flight-later.png')) {
    $capture=Get-Item -LiteralPath (Join-Path $OutputDirectory $name)
    if ($capture.LastWriteTime -lt $started) {throw ('Missing fresh emulator capture: '+$name)}
}
Write-Output ('Altirra exit code: '+$p.ExitCode)
