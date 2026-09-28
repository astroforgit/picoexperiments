param([int]$ProcessId, [string]$OutputPath, [string]$Key = '', [int]$HoldMilliseconds = 250, [switch]$DoublePress)
$ErrorActionPreference = 'Stop'
if (-not ('SvenWindow' -as [type])) {
Add-Type @'
using System;
using System.Runtime.InteropServices;
public static class SvenWindow {
 [DllImport("user32.dll")] public static extern bool MoveWindow(IntPtr h,int x,int y,int w,int z,bool repaint);
 [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h,int cmd);
 [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
 [DllImport("user32.dll")] public static extern void keybd_event(byte key,byte scan,uint flags,UIntPtr extra);
 [DllImport("user32.dll")] public static extern bool SetProcessDPIAware();
}
'@
}
[SvenWindow]::SetProcessDPIAware() | Out-Null
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
$p = Get-Process -Id $ProcessId
$h = $p.MainWindowHandle
if ($h -eq [IntPtr]::Zero) { throw 'No emulator window' }
$bounds = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea
$w = [Math]::Min(1050,$bounds.Width-40)
$height = [Math]::Min(820,$bounds.Height-40)
[SvenWindow]::ShowWindow($h,9) | Out-Null
[SvenWindow]::MoveWindow($h,$bounds.X+20,$bounds.Y+20,$w,$height,$true) | Out-Null
[SvenWindow]::SetForegroundWindow($h) | Out-Null
Start-Sleep -Milliseconds 500
$keys = @{ A=65; D=68; W=87; S=83; P=80; R=82; Space=32; Left=37; Up=38; Right=39; Down=40; F2=113; F3=114; F4=115 }
if ($Key) {
 $vk = $keys[$Key]
 if (-not $vk) { throw 'Unknown key' }
 for ($press=0; $press -lt $(if ($DoublePress) {2} else {1}); $press++) {
 [SvenWindow]::keybd_event([byte]$vk,0,0,[UIntPtr]::Zero)
 try { Start-Sleep -Milliseconds $HoldMilliseconds }
 finally { [SvenWindow]::keybd_event([byte]$vk,0,2,[UIntPtr]::Zero) }
 if ($DoublePress) { Start-Sleep -Milliseconds 80 }
 }
 Start-Sleep -Milliseconds 200
}
if ($OutputPath) {
 $bmp = New-Object System.Drawing.Bitmap($w,$height)
 $g = [System.Drawing.Graphics]::FromImage($bmp)
 try {
  $g.CopyFromScreen($bounds.X+20,$bounds.Y+20,0,0,$bmp.Size)
  $bmp.Save([IO.Path]::GetFullPath($OutputPath),[System.Drawing.Imaging.ImageFormat]::Png)
 } finally { $g.Dispose(); $bmp.Dispose() }
}
Write-Output $p.MainWindowTitle
