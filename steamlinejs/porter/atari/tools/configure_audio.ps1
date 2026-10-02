# Porter needs interactive audio. Keep the existing VBXE/hardware profile;
# only reduce its host playback queue and enable sound.
$ErrorActionPreference = 'Stop'
$audioKey = 'HKCU:\Software\virtualdub.org\Altirra\Profiles\00000000'
if (-not (Test-Path $audioKey)) {
    throw 'Altirra audio profile not found. Run the workspace emulator setup first.'
}
$settings = @{'Audio: Latency'=20; 'Audio: Extra buffer'=20; 'Audio: Mute'=0}
foreach ($name in $settings.Keys) {
    $old = Get-ItemPropertyValue -Path $audioKey -Name $name -ErrorAction SilentlyContinue
    if ($old -ne $settings[$name]) {
        New-ItemProperty -Path $audioKey -Name $name -Value $settings[$name] -PropertyType DWord -Force | Out-Null
        Write-Output ($name + ': ' + $old + ' -> ' + $settings[$name])
    }
}
Write-Output 'Porter audio: 20ms latency + 20ms extra buffer, unmuted.'
