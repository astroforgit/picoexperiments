param([Parameter(Mandatory=$true)][int]$ProcessId, [switch]$ScrollCheck)
$ErrorActionPreference = 'Stop'
Add-Type @'
using System;
using System.Runtime.InteropServices;
public class DDWindow {
 [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
 [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
 [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h,int c);
 [DllImport("user32.dll")] public static extern bool MoveWindow(IntPtr h,int x,int y,int w,int z,bool repaint);
 [DllImport("user32.dll")] public static extern void keybd_event(byte key,byte scan,uint flags,UIntPtr extra);
 [DllImport("user32.dll")] public static extern bool SetProcessDPIAware();
}
'@
[DDWindow]::SetProcessDPIAware() | Out-Null
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms
$p=Get-Process -Id $ProcessId
if ($p.ProcessName -notlike 'Altirra*') { throw 'Expected the Altirra process launched for this test' }
$h=$p.MainWindowHandle
[DDWindow]::ShowWindow($h,9) | Out-Null
[DDWindow]::MoveWindow($h,20,20,1050,820,$true) | Out-Null
[DDWindow]::SetForegroundWindow($h) | Out-Null
Start-Sleep -Milliseconds 700
if ([DDWindow]::GetForegroundWindow() -ne $h) {
 throw 'Altirra did not acquire focus; no keys will be sent or desktop screenshots captured.'
}
$out=Join-Path (Split-Path $PSScriptRoot -Parent) 'generated'
function Capture([string]$Name) {
 if ([DDWindow]::GetForegroundWindow() -ne $h) { throw 'Altirra lost focus; capture aborted.' }
 $bmp=New-Object System.Drawing.Bitmap(1050,820)
 $g=[System.Drawing.Graphics]::FromImage($bmp)
 try {
  $g.CopyFromScreen(20,20,0,0,$bmp.Size)
  $bmp.Save((Join-Path $out $Name),[System.Drawing.Imaging.ImageFormat]::Png)
 } finally { $g.Dispose(); $bmp.Dispose() }
}
function Press([byte]$Key,[int]$Milliseconds=100) {
 if ([DDWindow]::GetForegroundWindow() -ne $h) { throw 'Altirra lost focus; input aborted.' }
 [DDWindow]::keybd_event($Key,0,0,[UIntPtr]::Zero)
 try {
  $clock=[Diagnostics.Stopwatch]::StartNew()
  while ($clock.ElapsedMilliseconds -lt $Milliseconds) {
   if ([DDWindow]::GetForegroundWindow() -ne $h) { throw 'Altirra lost focus during input; aborting.' }
   Start-Sleep -Milliseconds 50
  }
 }
 finally { [DDWindow]::keybd_event($Key,0,2,[UIntPtr]::Zero) }
 Start-Sleep -Milliseconds 180
}
Capture 'altirra-title.png'
Press 32
Capture 'altirra-start.png'
Press 68 700
Capture 'altirra-move.png'
Press 32 500
Press 80
Capture 'altirra-paused.png'
if ($ScrollCheck) {
 Press 82
 Press 68 1200
 Press 32 13000
 Capture 'altirra-wave-cleared.png'
 Press 68 4000
 Press 80
 Capture 'altirra-scrolled.png'
}
Write-Output 'Captured title, start, movement and paused combat. Game left paused.'
