# LLM quick start

Read this file before operating Altirra or testing a VBXE program.

## Stable facts

- Target: Atari XL/XE with a VideoBoard XE (VBXE) FX core.
- Preferred core: **FX 1.26**.
- Preferred register page: **`$D600` (standard)**.
- Shared-memory mode: **disabled**, unless a specific program says otherwise.
- Primary local emulator: Windows Altirra 4.40 x64.
- Joystick gameplay normally uses joystick port 0.
- Well-behaved programs should detect VBXE at both `$D600` and `$D700`.

## Required workflow

1. Check that Altirra exists:

   ```powershell
   powershell.exe -ExecutionPolicy Bypass -File .\atari-vbxe-toolkit\scripts\find-altirra.ps1
   ```

2. If permanent VBXE setup has not been confirmed, read
   `ALTIRRA-PERMANENT-SETUP.md`. The helper below opens Altirra's Configure
   System dialog and selects Devices; a human finishes the final device picker:

   ```powershell
   powershell.exe -ExecutionPolicy Bypass -File .\atari-vbxe-toolkit\scripts\open-vbxe-config.ps1
   ```

3. Build the target with its own build script.

4. Run it using the persistent profile:

   ```sh
   atari-vbxe-toolkit/scripts/run-xex.sh path/to/program.xex
   ```

5. Confirm the expected screen and exercise input. For a fast emulator-only
   check, use `probe/vbxe-probe.xex` first.

## Hard rules

- Do not use `/portabletemp` when the user wants persistent configuration.
- Do not use `/cleardevices`; it removes normal emulated devices.
- Do not try to add VBXE on every run with `/adddevice vbxe`. In the tested
  Altirra 4.40 installation, the attempted command-line device shortcut caused
  a fatal emulator error. Use the GUI once and then reuse the saved profile.
- Do not overwrite or delete an existing Altirra profile or `Altirra.ini`.
- Do not upload a private XEX to an online emulator without explicit approval
  naming the destination.
- Do not assume a black screen means an assembler failure. First run the probe
  and check the VBXE configuration.

## Success criteria

- The probe displays `VBXE FX DETECTED` and either `REGISTERS AT D600` or
  `REGISTERS AT D700`.
- A VBXE game no longer displays `VBXE REQUIRED`.
- Reloading Altirra later still has VideoBoard XE attached without repeating
  setup.
