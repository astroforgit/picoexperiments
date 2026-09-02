param(
    [Parameter(Mandatory = $true)] [int] $AltirraProcessId,
    [Parameter(Mandatory = $true)]
    [ValidateSet('Left', 'Right', 'Up', 'Down', 'Space', 'R')]
    [string] $Key,
    [int] $HoldMilliseconds = 250
)

$ErrorActionPreference = 'Stop'

Add-Type @'
using System;
using System.Runtime.InteropServices;
public static class AltirraInputApi {
    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int command);
    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")]
    public static extern void keybd_event(byte key, byte scan, uint flags,
        UIntPtr extra);
}
'@

$virtualKeys = @{
    Left = 0x25; Up = 0x26; Right = 0x27; Down = 0x28
    Space = 0x20; R = 0x52
}

$process = Get-Process -Id $AltirraProcessId -ErrorAction Stop
$process.Refresh()
if ($process.MainWindowHandle -eq [IntPtr]::Zero) {
    throw 'Altirra does not have an input window.'
}

[AltirraInputApi]::ShowWindow($process.MainWindowHandle, 9) | Out-Null
[AltirraInputApi]::SetForegroundWindow($process.MainWindowHandle) | Out-Null
Start-Sleep -Milliseconds 250

$virtualKey = [byte] $virtualKeys[$Key]
[AltirraInputApi]::keybd_event($virtualKey, 0, 0, [UIntPtr]::Zero)
try {
    Start-Sleep -Milliseconds $HoldMilliseconds
}
finally {
    [AltirraInputApi]::keybd_event($virtualKey, 0, 2, [UIntPtr]::Zero)
}

Write-Output ('Sent ' + $Key + ' for ' + $HoldMilliseconds +
    'ms to Altirra PID ' + $AltirraProcessId)

