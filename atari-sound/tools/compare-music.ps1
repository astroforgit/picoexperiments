param([string]$Game = 'draconus', [switch]$Check)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()
$root = Split-Path -Parent $PSScriptRoot
$helper=Join-Path $PSScriptRoot 'AltirraTools.psm1'
if(-not(Test-Path -LiteralPath $helper)){
    $helper=Join-Path (Split-Path -Parent $root) 'atari-vbxe-toolkit\scripts\AltirraTools.psm1'
}
Import-Module $helper -Force
$emulator=$null
try { $emulator=Get-AltirraPath } catch { }
$tracks = @((Get-Content -LiteralPath (Join-Path $root 'remixes\catalog.json') -Raw -Encoding UTF8 | ConvertFrom-Json).tracks)
$script:visibleTracks=$tracks
$script:filtering=$false
$script:process = $null
$script:picoLibrary = $null
$script:side = 'original'
$script:mode = 'emulator'
$statePath = Join-Path $root 'player\comparison-state.json'
$form = New-Object Windows.Forms.Form
$form.Text = 'Atari Sound - Original / Remix'
$form.ClientSize = New-Object Drawing.Size(960, 590)
$form.MinimumSize = New-Object Drawing.Size(976, 629)
$form.StartPosition = 'CenterScreen'
$form.Font = New-Object Drawing.Font('Segoe UI', 11)
$form.KeyPreview = $true

function Make-Label($parent,$text,$x,$y,$w,$h,$size=11) {
    $c = New-Object Windows.Forms.Label
    $c.Text=$text; $c.SetBounds($x,$y,$w,$h)
    $c.Font=New-Object Drawing.Font('Segoe UI',$size)
    $parent.Controls.Add($c)
    return $c
}
function Make-Button($parent,$text,$x,$y,$w,$h) {
    $b=New-Object Windows.Forms.Button
    $b.Text=$text; $b.SetBounds($x,$y,$w,$h)
    $parent.Controls.Add($b)
    return $b
}
$null=Make-Label $form 'OLD HITS / NEW MELODIES' 24 16 575 42 22
$null=Make-Label $form 'Search:' 610 24 80 30
$search=New-Object Windows.Forms.TextBox
$search.SetBounds(690,20,246,32)
$form.Controls.Add($search)
$newSongsButton=Make-Button $form 'New songs' 490 18 112 36
$newSongsButton.Add_Click({if($search.Text -eq 'New composition'){$search.Text=''}else{$search.Text='New composition'}})
$null=Make-Label $form ($tracks.Count.ToString()+' music pairs:') 24 72 140 30
$choices=New-Object Windows.Forms.ComboBox
$choices.DropDownStyle='DropDownList'
$choices.SetBounds(168,68,768,34)
$choices.Anchor='Top, Left, Right'
foreach($t in $tracks){$choices.Items.Add(($t.title+'  /  '+$t.remix))|Out-Null}
$form.Controls.Add($choices)
$left=New-Object Windows.Forms.Panel
$left.SetBounds(24,122,444,310)
$left.BackColor=[Drawing.Color]::FromArgb(231,237,247)
$form.Controls.Add($left)
$right=New-Object Windows.Forms.Panel
$right.SetBounds(492,122,444,310)
$right.BackColor=[Drawing.Color]::FromArgb(222,241,232)
$form.Controls.Add($right)
$null=Make-Label $left 'ORIGINAL' 20 16 400 28 12
$originalTitle=Make-Label $left '' 20 48 400 48 25
$credit=Make-Label $left '' 20 105 400 58
$null=Make-Label $left "Original melody, bass and drums.`r`nRuns the original Atari music routine." 20 163 400 60
$originalPlay=Make-Button $left 'Play original in Atari' 20 234 404 48
$rightHeading=Make-Label $right 'NEW REMIX' 20 16 400 28 12
$remixTitle=Make-Label $right '' 20 48 400 48 25
$newInfo=Make-Label $right '' 20 105 400 58
$remixDescription=Make-Label $right "New melody with changing themes.`r`nOriginal bass and drums." 20 163 410 60
$remixPlay=Make-Button $right 'Play remix in Atari' 20 234 404 48
$stop=Make-Button $form 'Stop' 810 446 126 42
$status=Make-Label $form 'Select either side. Only one plays at a time.' 24 452 775 44
$null=Make-Label $form 'N / P: next / previous music    Left / Right: play original / remix' 24 510 750 26
$picoButton=Make-Button $form 'PICO music' 790 503 146 38
$null=Make-Label $form 'In Atari: Space pauses; N / P selects remix sections or original subsongs.' 24 550 920 26 10

function Save-State($message,$image='') {
    if($Check){return}
    $emulatorId=$null
    if($script:process -and -not $script:process.HasExited){$emulatorId=$script:process.Id}
    [ordered]@{launcher_pid=$PID;emulator_pid=$emulatorId;status=$message;image=$image;side=$script:side;mode=$script:mode} |
        ConvertTo-Json | Set-Content -LiteralPath $statePath -Encoding UTF8
}
function Stop-All {
    if($script:process){
        if(-not $script:process.HasExited){
            $script:process.CloseMainWindow()|Out-Null
            if(-not $script:process.WaitForExit(2000)){$script:process.Kill()}
        }
        $script:process.Dispose();$script:process=$null
    }
}
function Select-Track {
    if($script:filtering -or $choices.SelectedIndex -lt 0){return}
    Stop-All
    $t=$script:visibleTracks[$choices.SelectedIndex]
    $originalTitle.Text=$t.title
    $originalTitle.Font=New-Object Drawing.Font('Segoe UI',$(if($t.title.Length -gt 35){14}elseif($t.title.Length -gt 22){18}else{25}))
    $credit.Text='ASMA original'+"`r`n"+$t.author
    if($t.author -eq '<?>'){$credit.Text="ASMA original`r`nComposer not identified in the archive"}
    $rightHeading.Text=$(if($t.arrangement -eq 'New composition'){'NEW COMPOSITION'}else{'NEW REMIX'})
    $remixTitle.Text=$t.remix
    $remixTitle.Font=New-Object Drawing.Font('Segoe UI',$(if($t.remix.Length -gt 45){12}elseif($t.remix.Length -gt 22){17}else{25}))
    $remixDescription.Text="New melody with changing themes.`r`nOriginal bass and drums."
    if($t.arrangement -and $t.arrangement -ne 'Full arrangement'){
        $remixDescription.Text=$t.arrangement+".`r`nOriginal bass and drums; evolving lead."
    }
    if($t.composition_module -and $t.description){ $remixDescription.Text=$t.description }
    if($t.sections){
        $newInfo.Text=('{0}:{1:00} arrangement / {2} sections' -f [int][Math]::Floor($t.duration_seconds/60),[int]($t.duration_seconds%60),$t.sections.Count)+"`r`n"+'Inspired by '+$t.title
    } else {
        $newInfo.Text=('A new {0:N1}-second remix loop' -f $t.duration_seconds)+"`r`n"+'Inspired by '+$t.title
    }
    $status.Text='Ready: '+$t.title+' / '+$t.remix
    Save-State $status.Text
}
function Play-Side([string]$side) {
    if($choices.SelectedIndex -lt 0){return}
    try {
        Stop-All
        $script:side=$side
        $t=$script:visibleTracks[$choices.SelectedIndex]
        $folder=Join-Path $root $t.directory
        if(-not $emulator){
            $picker=New-Object Windows.Forms.OpenFileDialog
            $picker.Title='Select Altirra emulator'
            $picker.Filter='Altirra emulator|Altirra64.exe;Altirra.exe'
            try {
                if($picker.ShowDialog($form) -ne 'OK'){return}
                $script:emulator=$picker.FileName
            } finally { $picker.Dispose() }
        }
        $file=Join-Path $folder ($side.ToUpper()+'.XEX')
        $profile=Join-Path $root 'player\music-runtime.ini'
        if(-not(Test-Path -LiteralPath $profile)){
            Copy-Item -LiteralPath (Join-Path $root 'player\music-profile.ini') -Destination $profile
        }
        $script:process=Start-Process -FilePath $emulator -ArgumentList @('/nosi','/w','/noautoprofile','/portablealt',('"'+$profile+'"'),'/kernel','llexl','/run',('"'+$file+'"')) -PassThru
        $name=$t.title
        if($side -eq 'remix'){$name=$t.remix}
        $status.Text='Playing '+$side+': '+$name
        Save-State $status.Text $file
    } catch {
        $status.Text=$_.Exception.Message
        [Windows.Forms.MessageBox]::Show($form,$status.Text,'Atari Sound')|Out-Null
    }
}
$choices.Add_SelectedIndexChanged({Select-Track})
$search.Add_TextChanged({
    $script:filtering=$true
    $query=$search.Text.Trim()
    $newSongsButton.Text=$(if($query -eq 'New composition'){'Show all'}else{'New songs'})
    $script:visibleTracks=@($tracks | Where-Object {($query.Length -eq 0) -or (($_.title+' '+$_.remix+' '+$_.author+' '+$_.arrangement).IndexOf($query,[StringComparison]::OrdinalIgnoreCase) -ge 0)})
    $choices.Items.Clear()
    foreach($t in $script:visibleTracks){$choices.Items.Add(($t.title+'  /  '+$t.remix))|Out-Null}
    $script:filtering=$false
    $available=$script:visibleTracks.Count -gt 0
    foreach($button in @($originalPlay,$remixPlay)){$button.Enabled=$available}
    if($available){$choices.SelectedIndex=0}
    else {Stop-All;$status.Text='No matching music';Save-State $status.Text}
})
$originalPlay.Add_Click({Play-Side 'original'})
$remixPlay.Add_Click({Play-Side 'remix'})
$stop.Add_Click({Stop-All;$status.Text='Stopped';Save-State 'Stopped'})
$picoButton.Add_Click({
    Stop-All
    if($script:picoLibrary -and -not $script:picoLibrary.HasExited){return}
    $script:picoLibrary=Start-Process -FilePath (Join-Path $PSHOME 'powershell.exe') -ArgumentList @('-NoProfile','-STA','-ExecutionPolicy','Bypass','-File',('"'+(Join-Path $PSScriptRoot 'music-library.ps1')+'"')) -PassThru
    $status.Text='Opened the PICO-to-Atari music library.'
    Save-State $status.Text
})
$form.Add_FormClosed({Stop-All;Save-State 'Closed'})
$form.Add_KeyDown({
    param($sender,$e)
    if($search.Focused -or $script:visibleTracks.Count -eq 0){return}
    switch($e.KeyCode){
        'N' {$choices.SelectedIndex=($choices.SelectedIndex+1)%$script:visibleTracks.Count;Play-Side $script:side;$e.Handled=$true}
        'P' {$choices.SelectedIndex=($choices.SelectedIndex+$script:visibleTracks.Count-1)%$script:visibleTracks.Count;Play-Side $script:side;$e.Handled=$true}
        'Left' {Play-Side 'original';$e.Handled=$true}
        'Right' {Play-Side 'remix';$e.Handled=$true}
    }
    if($e.Handled){$e.SuppressKeyPress=$true}
})
$selected=0
for($i=0;$i -lt $tracks.Count;$i++){if($tracks[$i].id -eq $Game){$selected=$i}}
$choices.SelectedIndex=$selected
if($Check){
    foreach($t in $tracks){
        foreach($name in @('ORIGINAL.XEX','REMIX.XEX','original.sap','remix.sap')){
            if(-not(Test-Path -LiteralPath (Join-Path (Join-Path $root $t.directory) $name))){throw ('Missing '+$t.id+'/'+$name)}
        }
    }
    if($originalTitle.Text -ne $tracks[$selected].title -or $remixTitle.Text -ne $tracks[$selected].remix){throw 'Comparison selection failed'}
    $search.Text='warhawk'
    if($script:visibleTracks.Count -lt 1 -or $originalTitle.Text -notmatch 'Warhawk'){throw 'Search failed'}
    $search.Text='no_matching_music_12345'
    if($script:visibleTracks.Count -ne 0 -or $originalPlay.Enabled){throw 'Empty search failed'}
    $search.Text=''
    if($script:visibleTracks.Count -ne $tracks.Count){throw 'Clear search failed'}
    $newCount=@($tracks | Where-Object {$_.arrangement -eq 'New composition'}).Count
    if($newCount){
        $search.Text='New composition'
        if($script:visibleTracks.Count -ne $newCount -or $rightHeading.Text -ne 'NEW COMPOSITION'){throw 'New compositions filter failed'}
        if($newSongsButton.Text -ne 'Show all'){throw 'New songs toggle label failed'}
        $search.Text=''
    }
    Write-Output ('Comparison checked: '+$tracks.Count+' original/remix pairs, left and right labels match.')
    $form.Dispose();exit 0
}
$form.Add_Shown({Save-State 'Ready - choose original or remix in Atari'})
[Windows.Forms.Application]::Run($form)
