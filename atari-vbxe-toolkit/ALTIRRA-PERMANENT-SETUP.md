# Permanent Altirra VBXE setup

This is a one-time operation. Altirra saves the device in the active normal
profile and reuses it on later launches.

## Recommended settings

| Setting | Value |
|---|---|
| Computer | Atari XL/XE, normally 800XL or compatible |
| VBXE device | VideoBoard XE (VBXE) |
| Core | FX 1.26 |
| Base address | `$D600 (standard)` |
| Shared memory | Disabled |
| Video standard | NTSC or PAL as required by the program |
| Joystick | Port 0 |

## Configure it manually

1. Launch the normal `Altirra64.exe`. Do not use `/portabletemp`.
2. Select **System → Configure System...**.
3. Select **Devices** in the left pane.
4. Select **Add Device... → Internal devices → VideoBoard XE (VBXE)**.
5. In **VideoBoard XE Settings**, select:
   - **FX 1.26**;
   - **`$D600 (standard)`**;
   - leave **Enable shared memory** unchecked.
6. Confirm the small VBXE dialog with **OK**.
7. Confirm Configure System with **OK**.
8. Close Altirra normally so all settings are flushed.
9. Launch Altirra again and verify that **System → Configure System... →
   Devices** still contains VideoBoard XE.

The helper script `scripts/open-vbxe-config.ps1` performs steps 1–3 and leaves
the dialog open for the final selection.

## Where Altirra saves it

Normal mode saves settings in the current Windows user's Altirra profile. This
is the recommended mode for this toolkit.

Portable mode is also persistent, but different: launching Altirra once with
`/portable` creates `Altirra.ini` beside the executable. Altirra then detects
that file on future direct launches. Do not confuse `/portable` with
`/portabletemp`; the latter intentionally discards settings at exit.

## Profiles and automatic switching

VBXE belongs to the active Altirra profile. If several profiles exist, attach
VBXE to the XL/XE profile used for development. The supplied runner passes
`/noautoprofile`, preventing an XEX load from silently switching to a different
profile that may not contain VBXE.

