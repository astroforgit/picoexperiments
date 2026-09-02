# Atari VBXE emulator toolkit

This directory is the single starting point for running and testing Atari
XL/XE VBXE programs in this repository. An LLM should read
[`LLM-QUICKSTART.md`](LLM-QUICKSTART.md) first.

The intended emulator is **Altirra 4.40 (64-bit)** on Windows. VBXE is stored
in Altirra's normal persistent profile, so it only needs to be configured once.

## Fast path

1. Perform the one-time setup in
   [`ALTIRRA-PERMANENT-SETUP.md`](ALTIRRA-PERMANENT-SETUP.md).
2. Build and run the included probe:

   ```sh
   cd atari-vbxe-toolkit/probe
   ./build.sh
   ../scripts/run-xex.sh vbxe-probe.xex
   ```

3. Run any other XEX:

   ```sh
   atari-vbxe-toolkit/scripts/run-xex.sh grapple/atari/grapple-vbxe.xex
   ```

The runner deliberately uses the saved Altirra configuration. It does **not**
create an isolated profile, clear devices, or add VBXE on every invocation.

## Directory contents

- `LLM-QUICKSTART.md` — mandatory operating instructions for an LLM;
- `ALTIRRA-PERMANENT-SETUP.md` — exact one-time VBXE configuration;
- `TESTING.md` — repeatable build/run/verification workflow;
- `TROUBLESHOOTING.md` — known failures and fixes;
- `REFERENCE.md` — important local paths and technical references;
- `docs/` — local copy of the VBXE FX 1.26 documentation;
- `probe/` — tiny source and prebuilt XEX that detects `$D600` or `$D700`;
- `scripts/` — reusable emulator discovery, setup, and XEX launch scripts.

`scripts/capture-altirra.ps1` can capture a launched emulator by process ID,
which is useful for automated visual verification.

## Known local installation

The currently discovered emulator is:

```text
C:\Users\grzeg\OneDrive\Desktop\atari\emulator\Altirra64.exe
```

The scripts also search common locations and honor the `ALTIRRA_PATH`
environment variable, so the toolkit is not tied to that path.
