# Troubleshooting

## Program displays `VBXE REQUIRED`

Run `probe/vbxe-probe.xex`. If it also reports no VBXE:

1. Open **System → Configure System... → Devices**.
2. Confirm **VideoBoard XE (VBXE)** is attached.
3. Confirm FX 1.26 at `$D600`.
4. Confirm the launcher did not switch profiles.

## VBXE disappears on every restart

The emulator was probably launched with `/portabletemp`, which is explicitly
temporary. Configure normal Altirra once and close it normally. The supplied
runner never uses `/portabletemp`.

## Altirra crashes during scripted setup

Do not combine `/cleardevices` with an attempted `/adddevice vbxe` shortcut.
This combination produced an Altirra Program Failure in the tested Altirra
4.40 installation. Configure VideoBoard XE through the GUI once.

## Correct configuration, but loading an XEX loses VBXE

Altirra may have automatically selected another profile. Use
`scripts/run-xex.ps1` or `scripts/run-xex.sh`; they pass `/noautoprofile`.

## Black screen

1. Run the probe.
2. Confirm that the target XEX has a valid run segment.
3. Check whether the program expects `$D600` only or detects `$D700` too.
4. Check XDL addresses, VRAM bank selection, and `VCTL` enable order.
5. Disable unrelated accelerators and add-ons only through a separate test
   profile; never destroy the user's normal profile.

## Joystick input does not work

- Confirm the program reads joystick port 0.
- Check **Input → Input Mappings** in Altirra.
- Altirra commonly maps cursor keys to joystick directions, but mappings are
  user-configurable.
- Hold the key long enough for the game to sample multiple frames.

## Emulator executable not found

Set the Windows environment variable `ALTIRRA_PATH` to `Altirra64.exe`, or
pass `-AltirraPath` to a PowerShell script. Run `scripts/find-altirra.ps1` to
see all locations checked.

## Online emulator

The browser build at `https://ilmenit.github.io/AltirraSDL/` can be used as a
secondary test. Uploading an XEX sends it to a public web application context,
so obtain explicit user approval naming that destination before uploading
private project code. Local Altirra is the primary workflow.

