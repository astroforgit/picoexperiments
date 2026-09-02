function Get-AltirraPath {
    param([string] $ExplicitPath)

    $candidates = @()
    if ($ExplicitPath) { $candidates += $ExplicitPath }
    if ($env:ALTIRRA_PATH) { $candidates += $env:ALTIRRA_PATH }
    if ($env:USERPROFILE) {
        $candidates += (Join-Path $env:USERPROFILE `
            'OneDrive\Desktop\atari\emulator\Altirra64.exe')
        $candidates += (Join-Path $env:USERPROFILE `
            'Desktop\atari\emulator\Altirra64.exe')
    }
    if ($env:LOCALAPPDATA) {
        $candidates += (Join-Path $env:LOCALAPPDATA 'Altirra\Altirra64.exe')
    }

    $command = Get-Command Altirra64.exe -ErrorAction SilentlyContinue
    if ($command) { $candidates += $command.Source }
    $command = Get-Command Altirra.exe -ErrorAction SilentlyContinue
    if ($command) { $candidates += $command.Source }

    foreach ($candidate in $candidates | Select-Object -Unique) {
        if ($candidate -and (Test-Path -LiteralPath $candidate -PathType Leaf)) {
            return (Resolve-Path -LiteralPath $candidate).ProviderPath
        }
    }

    throw ('Altirra was not found. Set ALTIRRA_PATH or pass -AltirraPath. ' +
        'Checked: ' + ($candidates -join '; '))
}

Export-ModuleMember -Function Get-AltirraPath
