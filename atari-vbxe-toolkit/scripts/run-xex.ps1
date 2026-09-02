param(
    [Parameter(Mandatory = $true)] [string] $XexPath,
    [string] $AltirraPath,
    [switch] $Debugger,
    [switch] $Wait
)

$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'AltirraTools.psm1') -Force

$emulator = Get-AltirraPath -ExplicitPath $AltirraPath
if (-not (Test-Path -LiteralPath $XexPath -PathType Leaf)) {
    throw ('XEX file not found: ' + $XexPath)
}
$image = (Resolve-Path -LiteralPath $XexPath).ProviderPath

# These arguments deliberately reuse the persistent profile. Do not add
# /portabletemp, /cleardevices, or an on-every-run /adddevice shortcut here.
$arguments = @('/nosi', '/w', '/noautoprofile')
if ($Debugger) {
    $arguments += '/debug'
    $arguments += '/debugcmd:.vbxe'
}
$arguments += '/run'
$arguments += ('"' + $image + '"')

$process = Start-Process -FilePath $emulator `
    -ArgumentList $arguments -PassThru
Write-Output ('Started Altirra PID ' + $process.Id)
Write-Output ('Image: ' + $image)
Write-Output 'Profile mode: persistent, automatic profile switching disabled'

if ($Wait) {
    $process.WaitForExit()
    exit $process.ExitCode
}
