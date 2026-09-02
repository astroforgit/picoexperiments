param([string] $AltirraPath)

$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'AltirraTools.psm1') -Force
$emulator = Get-AltirraPath -ExplicitPath $AltirraPath

Add-Type @'
using System;
using System.Text;
using System.Runtime.InteropServices;
public static class AltirraMenuApi {
    [DllImport("user32.dll")]
    public static extern IntPtr GetMenu(IntPtr hWnd);
    [DllImport("user32.dll")]
    public static extern IntPtr GetSubMenu(IntPtr hMenu, int position);
    [DllImport("user32.dll")]
    public static extern int GetMenuItemCount(IntPtr hMenu);
    [DllImport("user32.dll", CharSet = CharSet.Unicode)]
    public static extern int GetMenuString(IntPtr hMenu, uint item,
        StringBuilder text, int maxCount, uint flags);
    [DllImport("user32.dll")]
    public static extern uint GetMenuItemID(IntPtr hMenu, int position);
    [DllImport("user32.dll")]
    public static extern bool PostMessage(IntPtr hWnd, uint message,
        UIntPtr wParam, IntPtr lParam);
    [DllImport("user32.dll")]
    public static extern IntPtr GetLastActivePopup(IntPtr hWnd);
    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")]
    public static extern void keybd_event(byte key, byte scan, uint flags,
        UIntPtr extra);
}
'@

function Find-MenuPosition([IntPtr] $Menu, [string] $Name) {
    $count = [AltirraMenuApi]::GetMenuItemCount($Menu)
    for ($position = 0; $position -lt $count; ++$position) {
        $label = New-Object System.Text.StringBuilder 256
        [AltirraMenuApi]::GetMenuString(
            $Menu, $position, $label, 256, 0x400) | Out-Null
        $clean = $label.ToString().Replace('&', '').Split("`t")[0]
        if ($clean -eq $Name) { return $position }
    }
    throw ('Menu item not found: ' + $Name)
}

$process = Start-Process -FilePath $emulator `
    -ArgumentList @('/nosi', '/w', '/noautoprofile') -PassThru
$deadline = [DateTime]::UtcNow.AddSeconds(15)
do {
    Start-Sleep -Milliseconds 250
    $process.Refresh()
} while ($process.MainWindowHandle -eq [IntPtr]::Zero -and
         [DateTime]::UtcNow -lt $deadline)

if ($process.MainWindowHandle -eq [IntPtr]::Zero) {
    throw 'Altirra did not create a main window.'
}

$mainMenu = [AltirraMenuApi]::GetMenu($process.MainWindowHandle)
$systemPosition = Find-MenuPosition $mainMenu 'System'
$systemMenu = [AltirraMenuApi]::GetSubMenu($mainMenu, $systemPosition)
$configurePosition = Find-MenuPosition $systemMenu 'Configure System...'
$command = [AltirraMenuApi]::GetMenuItemID($systemMenu, $configurePosition)
[AltirraMenuApi]::PostMessage(
    $process.MainWindowHandle, 0x0111, [UIntPtr] $command,
    [IntPtr]::Zero) | Out-Null

Start-Sleep -Milliseconds 750
$dialog = [AltirraMenuApi]::GetLastActivePopup($process.MainWindowHandle)
[AltirraMenuApi]::SetForegroundWindow($dialog) | Out-Null

# Altirra 4.40's category tree includes group headings. Home plus sixteen Down
# presses selects Devices without relying on mouse coordinates or DPI scaling.
[AltirraMenuApi]::keybd_event(0x24, 0, 0, [UIntPtr]::Zero)
[AltirraMenuApi]::keybd_event(0x24, 0, 2, [UIntPtr]::Zero)
for ($index = 0; $index -lt 16; ++$index) {
    [AltirraMenuApi]::keybd_event(0x28, 0, 0, [UIntPtr]::Zero)
    [AltirraMenuApi]::keybd_event(0x28, 0, 2, [UIntPtr]::Zero)
    Start-Sleep -Milliseconds 80
}

Write-Output 'Altirra is open on Configure System > Devices.'
Write-Output 'Finish: Add Device > Internal devices > VideoBoard XE (VBXE).'
Write-Output 'Choose FX 1.26, $D600 standard, shared memory off; confirm both OK dialogs.'
Write-Output 'Close Altirra normally afterward. This is the persistent profile.'

