# Send virtual-key presses to an Altirra window and capture it.
# altirra-keys.ps1 -AltirraProcessId PID -StepList "wait:3000;key:113:200;shot:C:\path.png"
param(
    [Parameter(Mandatory = $true)] [int] $AltirraProcessId,
    [Parameter(Mandatory = $true)] [string] $StepList
)
$ErrorActionPreference = 'Stop'
Add-Type @'
using System;
using System.Runtime.InteropServices;
public static class AltKeys {
    [StructLayout(LayoutKind.Sequential)]
    public struct RECT { public int Left, Top, Right, Bottom; }
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int c);
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
    [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out RECT r);
    [DllImport("user32.dll")] public static extern void keybd_event(byte k, byte s, uint f, UIntPtr e);
}
'@
Add-Type -AssemblyName System.Drawing
$p = Get-Process -Id $AltirraProcessId
$deadline = [DateTime]::UtcNow.AddSeconds(20)
while ($p.MainWindowHandle -eq [IntPtr]::Zero -and [DateTime]::UtcNow -lt $deadline) {
    Start-Sleep -Milliseconds 250; $p.Refresh()
}
$h = $p.MainWindowHandle
foreach ($s in $StepList.Split(";")) {
    $f = $s.Split(':', 2)
    switch ($f[0]) {
        'wait' { Start-Sleep -Milliseconds ([int]$f[1]) }
        'key' {
            $k = $f[1].Split(':')
            [AltKeys]::ShowWindow($h, 9) | Out-Null
            [AltKeys]::SetForegroundWindow($h) | Out-Null
            Start-Sleep -Milliseconds 100
            [AltKeys]::keybd_event([byte][int]$k[0], 0, 0, [UIntPtr]::Zero)
            Start-Sleep -Milliseconds ([int]$k[1])
            [AltKeys]::keybd_event([byte][int]$k[0], 0, 2, [UIntPtr]::Zero)
        }
        'shot' {
            [AltKeys]::ShowWindow($h, 9) | Out-Null
            [AltKeys]::SetForegroundWindow($h) | Out-Null
            Start-Sleep -Milliseconds 300
            $r = New-Object AltKeys+RECT
            [AltKeys]::GetWindowRect($h, [ref]$r) | Out-Null
            $bmp = New-Object System.Drawing.Bitmap(($r.Right - $r.Left), ($r.Bottom - $r.Top))
            $g = [System.Drawing.Graphics]::FromImage($bmp)
            $g.CopyFromScreen($r.Left, $r.Top, 0, 0, $bmp.Size)
            $bmp.Save($f[1], [System.Drawing.Imaging.ImageFormat]::Png)
            $g.Dispose(); $bmp.Dispose()
            Write-Output ('shot ' + $f[1])
        }
    }
}
