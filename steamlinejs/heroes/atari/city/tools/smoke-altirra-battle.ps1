param([Parameter(Mandatory=$true)][int]$AltirraProcessId)
# Use on a freshly launched debug city; builds Barracks, recruits five soldiers,
# enters Forest and captures the actual emulator window. No persistent save edits.
$ErrorActionPreference='Stop'
Add-Type @'
using System;
using System.Runtime.InteropServices;
public static class GreenhavenInput {
 [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
 [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h,int n);
 [DllImport("user32.dll")] public static extern bool MoveWindow(IntPtr h,int x,int y,int w,int z,bool repaint);
 [DllImport("user32.dll")] public static extern void keybd_event(byte key,byte scan,uint flags,UIntPtr extra);
}
'@
$p=Get-Process -Id $AltirraProcessId
[GreenhavenInput]::ShowWindow($p.MainWindowHandle,9)|Out-Null
[GreenhavenInput]::MoveWindow($p.MainWindowHandle,20,20,960,700,$true)|Out-Null
[GreenhavenInput]::SetForegroundWindow($p.MainWindowHandle)|Out-Null
Start-Sleep -Milliseconds 500
function Press([byte]$key) {
 [GreenhavenInput]::keybd_event($key,0,0,[UIntPtr]::Zero)
 try { Start-Sleep -Milliseconds 100 }
 finally {[GreenhavenInput]::keybd_event($key,0,2,[UIntPtr]::Zero)}
 Start-Sleep -Milliseconds 550
}
Press 0x20;Press 0x20
for($i=0;$i -lt 5;$i++){Press 0x20;Press 0x53;Press 0x20}
Press 0x57;Press 0x20;Press 0x20;Press 0x20
Start-Sleep -Milliseconds 1000
$city=Split-Path $PSScriptRoot
$workspace=Split-Path (Split-Path (Split-Path (Split-Path $city)))
& (Join-Path $workspace 'atari-vbxe-toolkit/scripts/capture-altirra.ps1') -AltirraProcessId $AltirraProcessId -OutputPath (Join-Path $city 'generated/altirra-battle.png')
