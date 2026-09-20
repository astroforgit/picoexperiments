param(
    [Parameter(Mandatory = $true)] [string] $XexPath,
    [Parameter(Mandatory = $true)] [string] $OutputPrefix
)

$ErrorActionPreference = 'Stop'
$altirraPath = 'C:\Users\grzeg\OneDrive\Desktop\atari\emulator\Altirra64.exe'

Add-Type @'
using System;
using System.Text;
using System.Runtime.InteropServices;
public static class NativeWindow {
    [StructLayout(LayoutKind.Sequential)]
    public struct RECT { public int Left, Top, Right, Bottom; }

    [DllImport("user32.dll")]
    public static extern bool GetWindowRect(IntPtr hWnd, out RECT rect);

    [DllImport("user32.dll", CharSet = CharSet.Unicode)]
    public static extern IntPtr FindWindow(string className, string windowName);

    [DllImport("user32.dll")]
    public static extern IntPtr GetLastActivePopup(IntPtr hWnd);

    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);

    [DllImport("user32.dll")]
    public static extern bool SetWindowPos(IntPtr hWnd, IntPtr insertAfter,
        int x, int y, int width, int height, uint flags);

    [DllImport("user32.dll")]
    public static extern bool SetCursorPos(int x, int y);

    [DllImport("user32.dll")]
    public static extern void mouse_event(uint flags, uint dx, uint dy, uint data, UIntPtr extra);

    [DllImport("user32.dll")]
    public static extern void keybd_event(byte key, byte scan, uint flags, UIntPtr extra);

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
}
'@

Add-Type -AssemblyName System.Drawing

function Save-WindowScreenshot([IntPtr] $Handle, [string] $Path) {
    $rect = New-Object NativeWindow+RECT
    if (-not [NativeWindow]::GetWindowRect($Handle, [ref] $rect)) {
        throw 'Unable to read the Altirra window bounds.'
    }

    $width = $rect.Right - $rect.Left
    $height = $rect.Bottom - $rect.Top
    $bitmap = New-Object System.Drawing.Bitmap($width, $height)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    try {
        $graphics.CopyFromScreen($rect.Left, $rect.Top, 0, 0, $bitmap.Size)
        $bitmap.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
    }
    finally {
        $graphics.Dispose()
        $bitmap.Dispose()
    }
}

function Click-Window([IntPtr] $Handle, [int] $X, [int] $Y) {
    $rect = New-Object NativeWindow+RECT
    if (-not [NativeWindow]::GetWindowRect($Handle, [ref] $rect)) {
        throw 'Unable to read the Altirra window bounds.'
    }
    [NativeWindow]::SetCursorPos($rect.Left + $X, $rect.Top + $Y) | Out-Null
    [NativeWindow]::mouse_event(0x0002, 0, 0, 0, [UIntPtr]::Zero)
    [NativeWindow]::mouse_event(0x0004, 0, 0, 0, [UIntPtr]::Zero)
}

function Click-Client([IntPtr] $Handle, [int] $X, [int] $Y) {
    $packedPoint = [IntPtr] (($Y -shl 16) -bor ($X -band 0xffff))
    [NativeWindow]::PostMessage(
        $Handle, 0x0200, [UIntPtr]::Zero, $packedPoint) | Out-Null
    [NativeWindow]::PostMessage(
        $Handle, 0x0201, [UIntPtr]::new(1), $packedPoint) | Out-Null
    [NativeWindow]::PostMessage(
        $Handle, 0x0202, [UIntPtr]::Zero, $packedPoint) | Out-Null
}

function Find-MenuPosition([IntPtr] $Menu, [string] $Name) {
    $count = [NativeWindow]::GetMenuItemCount($Menu)
    for ($position = 0; $position -lt $count; ++$position) {
        $label = New-Object System.Text.StringBuilder 256
        [NativeWindow]::GetMenuString($Menu, $position, $label, 256, 0x400) | Out-Null
        $cleanLabel = $label.ToString().Replace('&', '').Split("`t")[0]
        if ($cleanLabel -eq $Name) {
            return $position
        }
    }
    throw ('Altirra menu item not found: ' + $Name)
}

function Invoke-MenuPath([IntPtr] $Handle, [string[]] $Path) {
    $menu = [NativeWindow]::GetMenu($Handle)
    if ($menu -eq [IntPtr]::Zero) {
        throw 'Altirra main menu was not found.'
    }
    for ($index = 0; $index -lt $Path.Count; ++$index) {
        $position = Find-MenuPosition $menu $Path[$index]
        if ($index -eq $Path.Count - 1) {
            $command = [NativeWindow]::GetMenuItemID($menu, $position)
            [NativeWindow]::PostMessage(
                $Handle, 0x0111, [UIntPtr] $command, [IntPtr]::Zero) | Out-Null
        }
        else {
            $menu = [NativeWindow]::GetSubMenu($menu, $position)
        }
    }
}

$arguments = @(
    '/portabletemp', '/skipsetup', '/nosi', '/w',
    '/adddevice', 'vbxe',
    '/run', $XexPath
)

$process = Start-Process -FilePath $altirraPath -ArgumentList $arguments -PassThru
try {
    $deadline = [DateTime]::UtcNow.AddSeconds(15)
    do {
        Start-Sleep -Milliseconds 250
        $process.Refresh()
    } while ($process.MainWindowHandle -eq [IntPtr]::Zero -and
             [DateTime]::UtcNow -lt $deadline)

    if ($process.MainWindowHandle -eq [IntPtr]::Zero) {
        throw 'Altirra did not create a main window.'
    }

    [NativeWindow]::SetWindowPos($process.MainWindowHandle, [IntPtr]::Zero,
        0, 0, 0, 0, 0x0005) | Out-Null
    Start-Sleep -Seconds 4
    [NativeWindow]::SetForegroundWindow($process.MainWindowHandle) | Out-Null
    Save-WindowScreenshot $process.MainWindowHandle ($OutputPrefix + '-idle.png')

    [NativeWindow]::keybd_event(0x27, 0, 0, [UIntPtr]::Zero)
    Start-Sleep -Milliseconds 300
    Save-WindowScreenshot $process.MainWindowHandle ($OutputPrefix + '-grapple.png')
    Start-Sleep -Milliseconds 700
    [NativeWindow]::keybd_event(0x27, 0, 2, [UIntPtr]::Zero)
    Start-Sleep -Milliseconds 250
    Save-WindowScreenshot $process.MainWindowHandle ($OutputPrefix + '-moved.png')

    Write-Output ('Altirra PID: ' + $process.Id)
    Write-Output ('Window title: ' + $process.MainWindowTitle)
    Write-Output ('Captured: ' + $OutputPrefix + '-idle.png')
    Write-Output ('Captured: ' + $OutputPrefix + '-grapple.png')
    Write-Output ('Captured: ' + $OutputPrefix + '-moved.png')
}
finally {
    if (-not $process.HasExited) {
        $process.CloseMainWindow() | Out-Null
        if (-not $process.WaitForExit(3000)) {
            $process.Kill()
        }
    }
}
