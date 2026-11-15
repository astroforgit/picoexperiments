# PicoRacer-2048 for Atari VBXE

This is a playable Atari XL/XE + VBXE FX adaptation of
`[Race]/PicoRacer-2048.p8.png`. The game code and course data came from
`allgames/[Race]/PicoRacer-2048.p8`. The eight course names and ordered
curvature data are retained. Each original course is resampled to 192 road
cells for the Atari renderer.

The port has a perspective road, three-lap races against one rival, time
attack, acceleration, braking, steering, limited boost, a timer, and result
screens. The road view and car art are new for VBXE. AI, handling, and course
geometry are simplified; the PICO-8 track editor, replay system, music, and
sound effects are not included.

## Requirements

- Atari XL/XE with VBXE FX 1.2x at `$D600` or `$D700`
- MADS assembler to rebuild
- Python 3 only when regenerating course data

## Build and run

From the repository root, build and launch in the configured Altirra VBXE
profile with:

```sh
./atari/2048/run-emulator.sh
```

The launcher works from any current directory. `./build.sh` builds without
launching, and `./build.sh --regenerate-assets` rebuilds `tracks.bin` from
the decompiled cartridge before assembling. The included XEX can be loaded
directly into an Atari VBXE system. The emulator runner uses the existing persistent Altirra
profile described in `atari-vbxe-toolkit/LLM-QUICKSTART.md`.

## Controls

Either joystick port works. On the menu, up/down selects one of the eight
courses, left/right changes race mode, and fire starts. During a race, up
accelerates, down brakes, left/right steers, and fire uses boost. Space or
the Atari START key can select menu items and return from a result screen.

The font and VBXE blitter setup follow `atari/race`. VBXE detection checks
both register pages, as described in `atari-vbxe-toolkit/REFERENCE.md` and
the FX 1.26 PDF in `atari-vbxe-toolkit/docs`.
