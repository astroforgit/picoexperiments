param(
    [Parameter(Mandatory = $true)] [int] $AltirraProcessId,
    [Parameter(Mandatory = $true)] [string] $OutputPath
)

$ErrorActionPreference = 'Stop'

Add-Type @'
using System;
using System.Runtime.InteropServices;
public static class AltirraCaptureApi {
    [StructLayout(LayoutKind.Sequential)]
    public struct RECT { public int Left, Top, Right, Bottom; }
    [DllImport("user32.dll")]
    public static extern bool GetWindowRect(IntPtr hWnd, out RECT rect);
    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int command);
    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);
}
'@
Add-Type -AssemblyName System.Drawing

$process = Get-Process -Id $AltirraProcessId -ErrorAction Stop
$deadline = [DateTime]::UtcNow.AddSeconds(15)
do {
    Start-Sleep -Milliseconds 250
    $process.Refresh()
} while ($process.MainWindowHandle -eq [IntPtr]::Zero -and
         [DateTime]::UtcNow -lt $deadline)

if ($process.MainWindowHandle -eq [IntPtr]::Zero) {
    throw 'Altirra does not have a capturable main window.'
}

[AltirraCaptureApi]::ShowWindow($process.MainWindowHandle, 9) | Out-Null
[AltirraCaptureApi]::SetForegroundWindow($process.MainWindowHandle) | Out-Null
Start-Sleep -Milliseconds 750

$rect = New-Object AltirraCaptureApi+RECT
if (-not [AltirraCaptureApi]::GetWindowRect(
    $process.MainWindowHandle, [ref] $rect)) {
    throw 'Unable to read Altirra window bounds.'
}

$width = $rect.Right - $rect.Left
$height = $rect.Bottom - $rect.Top
$bitmap = New-Object System.Drawing.Bitmap($width, $height)
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
try {
    $graphics.CopyFromScreen($rect.Left, $rect.Top, 0, 0, $bitmap.Size)
    $resolvedOutput = [System.IO.Path]::GetFullPath($OutputPath)
    $bitmap.Save($resolvedOutput, [System.Drawing.Imaging.ImageFormat]::Png)
    Write-Output ('Captured: ' + $resolvedOutput)
    Write-Output ('Window title: ' + $process.MainWindowTitle)
}
finally {
    $graphics.Dispose()
    $bitmap.Dispose()
}
