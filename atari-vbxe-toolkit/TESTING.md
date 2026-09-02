# VBXE testing workflow

## 1. Verify the emulator first

Build the small probe:

```sh
cd atari-vbxe-toolkit/probe
./build.sh
```

Run it:

```sh
../scripts/run-xex.sh vbxe-probe.xex
```

Expected result:

```text
ATARI VBXE PROBE
VBXE FX DETECTED
REGISTERS AT D600
```

`D700` is also accepted, although `$D600` is the standard configuration used
by this project. `VBXE NOT DETECTED` means the emulator profile is wrong; do
not debug the game until the probe succeeds.

## 2. Build the game

Use the build script belonging to the target. Current examples:

```sh
cd grapple/atari && ./build.sh
cd steamlinejs/atari && ./build.sh
```

MADS must be available as `mads`. Node.js is also needed by projects that
generate assets or level data.

## 3. Run the game

From the repository root:

```sh
atari-vbxe-toolkit/scripts/run-xex.sh grapple/atari/grapple-vbxe.xex
```

Or from Windows PowerShell:

```powershell
.\atari-vbxe-toolkit\scripts\run-xex.ps1 `
  -XexPath .\grapple\atari\grapple-vbxe.xex
```

The launcher uses:

- the normal persistent Altirra profile;
- windowed mode;
- a separate emulator process;
- `/noautoprofile` to retain the configured VBXE profile;
- Altirra's `/run` executable loader.

## 4. Exercise controls

- Confirm the main image is a VBXE image rather than `VBXE REQUIRED`.
- Test joystick port 0 mappings.
- Test movement while holding and releasing each direction.
- Test reset/restart controls.
- When animation matters, hold input across several frames instead of sending
  only a quick key tap.

For Grapple, joystick directions shoot and hold the grapple; releasing the
direction releases the rope while preserving momentum. SELECT or `R` resets.

## 5. Record evidence

For a change with visual or movement risk, record:

- exact XEX path and byte size;
- Altirra version;
- VBXE core and base address;
- NTSC/PAL mode;
- idle screenshot;
- screenshot while input is held;
- screenshot after movement or release.

Do not claim a runtime pass from assembly success alone.

For automated local input and screenshots, use the PID printed by the runner:

```powershell
.\atari-vbxe-toolkit\scripts\send-altirra-key.ps1 `
  -AltirraProcessId 1234 -Key Right -HoldMilliseconds 750
.\atari-vbxe-toolkit\scripts\capture-altirra.ps1 `
  -AltirraProcessId 1234 -OutputPath .\artifacts\after-right.png
```
