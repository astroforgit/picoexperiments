param([string] $Game = 'porterpatch1-1', [string] $AltirraPath, [switch] $Check)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()
$musicRoot = Split-Path -Parent $PSScriptRoot
$helper = Join-Path $PSScriptRoot 'AltirraTools.psm1'
if (-not (Test-Path $helper)) { $helper = Join-Path (Split-Path $musicRoot -Parent) 'atari-vbxe-toolkit\scripts\AltirraTools.psm1' }
Import-Module $helper -Force
$emulator = Get-AltirraPath -ExplicitPath $AltirraPath
$catalog = Get-Content (Join-Path $musicRoot 'catalog.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$variants = Get-Content (Join-Path $musicRoot 'rmt-variations\catalog.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$byName = @{}
foreach ($entry in $variants.games) { $byName[(Split-Path $entry.directory -Leaf)] = $entry }
$script:pairs = @($catalog.games | Sort-Object title | ForEach-Object {
    $id = Split-Path $_.directory -Leaf
    [pscustomobject]@{ id=$id; title=$_.title; kind=$_.kind; original=$_; rmt=$byName[$id] }
})
$script:chosen = $null
$script:playing = $null
$script:updating = $false
$script:manifests = @($null, $null)
$stateFile = Join-Path $musicRoot 'player\launcher-state.json'
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Atari Sound - PICO comparison'
$form.ClientSize = New-Object System.Drawing.Size(1040, 650)
$form.MinimumSize = $form.Size
$form.StartPosition = 'CenterScreen'
$form.Font = New-Object System.Drawing.Font('Segoe UI', 10)
function Label-At($text, $x, $y, $width, $height) {
    $label = New-Object System.Windows.Forms.Label
    $label.Text=$text; $label.SetBounds($x,$y,$width,$height)
    $form.Controls.Add($label); return $label
}
$heading = Label-At 'PICO MUSIC / ORIGINAL AND RMT INSTRUMENTS' 18 12 970 32
$heading.Font = New-Object System.Drawing.Font('Segoe UI', 16, [System.Drawing.FontStyle]::Bold)
$remixesButton = New-Object System.Windows.Forms.Button
$remixesButton.Text='Atari remixes'
$remixesButton.SetBounds(810,12,212,34)
$remixesButton.Add_Click({
    Stop-Music
    $status.Text='Opening Atari remixes in Altirra'
    Save-State $status.Text
    Start-Process powershell.exe -ArgumentList @('-NoProfile','-STA','-ExecutionPolicy','Bypass','-File',('"'+(Join-Path $PSScriptRoot 'compare-music.ps1')+'"'))
})
$form.Controls.Add($remixesButton)
$remixesButton.BringToFront()

$null = Label-At 'Search game or RMT track:' 18 56 205 28
$search = New-Object System.Windows.Forms.TextBox
$search.SetBounds(226,52,530,30); $form.Controls.Add($search)
$includeSfx = New-Object System.Windows.Forms.CheckBox
$includeSfx.Text='Include SFX auditions'; $includeSfx.SetBounds(786,52,235,30)
$form.Controls.Add($includeSfx)
$list = New-Object System.Windows.Forms.ListView
$list.SetBounds(18,94,1004,320); $list.View='Details'; $list.FullRowSelect=$true
$list.MultiSelect=$false; $list.HideSelection=$false
$list.Columns.Add('Original game conversion',490) | Out-Null
$list.Columns.Add('Same game - RMT instruments',490) | Out-Null
$form.Controls.Add($list)
$script:bankBoxes = @(); $script:playButtons = @(); $script:sideLabels = @()
for ($i=0; $i -lt 2; $i++) {
    $x=18+510*$i
    $label = Label-At '' $x 426 490 58
    $script:sideLabels += $label
    $box = New-Object System.Windows.Forms.ComboBox
    $box.DropDownStyle='DropDownList'; $box.SetBounds($x,492,490,30)
    $form.Controls.Add($box); $script:bankBoxes += $box
    $button = New-Object System.Windows.Forms.Button
    $button.Text=@('Play original conversion','Play RMT instruments')[$i]
    $button.SetBounds($x,532,490,38); $button.Tag=$i
    $button.Add_Click({ param($sender,$eventArgs) Play-Side ([int]$sender.Tag) })
    $form.Controls.Add($button); $script:playButtons += $button
}
$status = Label-At 'Choose a game. Play either side to compare the same PICO score.' 18 582 880 27
$stop = New-Object System.Windows.Forms.Button
$stop.Text='Stop'; $stop.SetBounds(922,578,100,32); $form.Controls.Add($stop)
$null = Label-At 'Double-click either column to play. App: Left / Right = compare, N / P = game. New Atari player: Space / N / P.' 18 620 1000 26
function Save-State($message, $image='', $side='') {
    $emulatorId=$null
    if ($script:playing -and -not $script:playing.HasExited) { $emulatorId=$script:playing.Id }
    [ordered]@{launcher_pid=$PID; emulator_pid=$emulatorId; status=$message; image=$image; side=$side} |
        ConvertTo-Json | Set-Content -LiteralPath $stateFile -Encoding UTF8
}
function Stop-Music {
    if ($script:playing -and -not $script:playing.HasExited) {
        $script:playing.CloseMainWindow() | Out-Null
        if (-not $script:playing.WaitForExit(2000)) { $script:playing.Kill() }
    }
    if ($script:playing) { $script:playing.Dispose() }
    $script:playing=$null
}
function Select-Game {
    if ($script:updating) { return }
    $script:chosen=$null
    if ($list.SelectedItems.Count) { $script:chosen=$list.SelectedItems[0].Tag }
    for ($i=0; $i -lt 2; $i++) {
        $script:bankBoxes[$i].Items.Clear(); $script:manifests[$i]=$null
        $script:playButtons[$i].Enabled=$false; $script:sideLabels[$i].Text=''
        if (-not $script:chosen) { continue }
        $entry=@($script:chosen.original,$script:chosen.rmt)[$i]
        if (-not $entry) { $script:sideLabels[$i].Text='No matching conversion available.'; continue }
        $folder=Join-Path $musicRoot $entry.directory
        $manifest=Get-Content (Join-Path $folder 'manifest.json') -Raw -Encoding UTF8 | ConvertFrom-Json
        $script:manifests[$i]=$manifest
        foreach ($bank in $manifest.banks) {
            $script:bankBoxes[$i].Items.Add(('{0}.XEX - {1} patterns' -f $bank.file,@($bank.entries).Count)) | Out-Null
        }
        if ($script:bankBoxes[$i].Items.Count) { $script:bankBoxes[$i].SelectedIndex=0; $script:playButtons[$i].Enabled=$true }
        $description='Original automatic Atari conversion'
        if ($i -eq 1) { $description='Instruments from '+$entry.donor+' | PICO rhythm retained' }
        $script:sideLabels[$i].Text=$script:chosen.title+"`r`n"+$description
    }
}
function Filter-Games {
    $oldId=''; if ($script:chosen) { $oldId=$script:chosen.id }
    $script:updating=$true; $list.BeginUpdate()
    try {
        $list.Items.Clear()
        foreach ($pair in $script:pairs) {
            if (-not $includeSfx.Checked -and $pair.kind -eq 'sfx-audition') { continue }
            $text=$pair.title+' '+$pair.rmt.donor
            if ($search.Text -and $text.IndexOf($search.Text,[StringComparison]::OrdinalIgnoreCase) -lt 0) { continue }
            $item=New-Object System.Windows.Forms.ListViewItem([string]$pair.title)
            $right=$pair.title+' | '+$pair.rmt.donor
            if (-not $pair.rmt) { $right=$pair.title+' | unavailable' }
            $item.SubItems.Add($right) | Out-Null; $item.Tag=$pair; $list.Items.Add($item) | Out-Null
        }
    } finally { $list.EndUpdate(); $script:updating=$false }
    $form.Text='Atari Sound - PICO comparison ('+$list.Items.Count+' games)'
    $match=@($list.Items | Where-Object { $_.Tag.id -eq $oldId })
    if ($match.Count) { $match[0].Selected=$true; $match[0].EnsureVisible() }
    elseif ($list.Items.Count) { $list.Items[0].Selected=$true }
    Select-Game
}
function Play-Side([int]$side) {
    if (-not $script:chosen -or $script:bankBoxes[$side].SelectedIndex -lt 0) { return }
    try {
        $entry=@($script:chosen.original,$script:chosen.rmt)[$side]
        $bank=@($script:manifests[$side].banks)[$script:bankBoxes[$side].SelectedIndex]
        $image=Join-Path (Join-Path $musicRoot $entry.directory) ($bank.file+'.XEX')
        if (-not (Test-Path -LiteralPath $image)) { throw ('Missing music file: '+$image) }
        Stop-Music
        $profile=Join-Path $musicRoot 'player\music-runtime.ini'
        if (-not (Test-Path $profile)) { Copy-Item (Join-Path $musicRoot 'player\music-profile.ini') $profile }
        $script:playing=Start-Process -FilePath $emulator -ArgumentList @('/nosi','/w','/noautoprofile','/portablealt',('"'+$profile+'"'),'/kernel','llexl','/nobasic','/run',('"'+$image+'"')) -PassThru
        $name=@('original conversion','RMT instruments')[$side]
        $status.Text='Playing '+$script:chosen.title+' - '+$name
        Save-State $status.Text $image $name
    } catch { $status.Text=$_.Exception.Message; [System.Windows.Forms.MessageBox]::Show($form,$status.Text,'Atari Sound') | Out-Null }
}
$search.Add_TextChanged({ Filter-Games })
$includeSfx.Add_CheckedChanged({ Filter-Games })
$list.Add_SelectedIndexChanged({ Select-Game })
$list.Add_MouseDoubleClick({ param($sender,$e)
    $hit=$list.HitTest($e.Location)
    if ($hit.Item -and $hit.SubItem) { Play-Side ($hit.Item.SubItems.IndexOf($hit.SubItem)) }
})
$stop.Add_Click({ Stop-Music; $status.Text='Stopped'; Save-State 'Stopped' })
$form.Add_FormClosed({ Stop-Music; Save-State 'Closed' })
$form.KeyPreview=$true
$form.Add_KeyDown({ param($sender,$e)
    if ($search.Focused -or $script:bankBoxes[0].Focused -or $script:bankBoxes[1].Focused) { return }
    if ($e.KeyCode -eq 'Left') { Play-Side 0; $e.SuppressKeyPress=$true }
    elseif ($e.KeyCode -eq 'Right') { Play-Side 1; $e.SuppressKeyPress=$true }
    elseif ($e.KeyCode -in @('N','P') -and $list.Items.Count) {
        $index=0; if ($list.SelectedIndices.Count) { $index=$list.SelectedIndices[0] }
        if ($e.KeyCode -eq 'N') { $index++ } else { $index-- }
        $index=($index+$list.Items.Count)%$list.Items.Count
        $list.Items[$index].Selected=$true; $list.Items[$index].EnsureVisible(); $e.SuppressKeyPress=$true
    }
})
$null=$form.Handle; $null=$list.Handle
Filter-Games
$initial=@($list.Items | Where-Object { $_.Tag.id -eq $Game })
if ($initial.Count) { $list.SelectedItems.Clear(); $initial[0].Selected=$true; $initial[0].EnsureVisible(); Select-Game }
if ($Check) {
    if ($list.Items.Count -ne $catalog.summary.music_games) { throw 'Music count mismatch' }
    foreach ($pair in $script:pairs) {
        if (-not $pair.rmt -or (Split-Path $pair.rmt.directory -Leaf) -ne $pair.id) { throw 'Mismatched comparison pair' }
        foreach ($entry in @($pair.original,$pair.rmt)) {
            $folder=Join-Path $musicRoot $entry.directory
            $manifest=Get-Content (Join-Path $folder 'manifest.json') -Raw -Encoding UTF8 | ConvertFrom-Json
            foreach ($bank in $manifest.banks) { if (-not (Test-Path (Join-Path $folder ($bank.file+'.XEX')))) { throw 'Missing comparison bank' } }
        }
    }
    if (-not $script:playButtons[0].Enabled -or -not $script:playButtons[1].Enabled) { throw 'Comparison controls disabled' }
    $includeSfx.Checked=$true
    if ($list.Items.Count -ne $script:pairs.Count) { throw 'SFX filter mismatch' }
    $includeSfx.Checked=$false; $search.Text='Chicken'
    if (-not $list.Items.Count) { throw 'Donor search failed' }
    $search.Text='no-such-game-9876'
    if ($script:playButtons[0].Enabled -or $script:playButtons[1].Enabled) { throw 'Empty search still playable' }
    $search.Text=''
    Write-Output ('Checked '+$script:pairs.Count+' matched pairs, both bank lists, search and playback controls')
    $form.Dispose(); exit 0
}
$form.Add_Shown({ Save-State 'Ready - choose original or RMT instruments' })
[System.Windows.Forms.Application]::Run($form)
