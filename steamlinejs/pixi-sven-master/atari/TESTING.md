# Sven VBXE verification

Tested locally on 2026-09-06. See `DEVELOPMENT.md` for the bugs found and the
implementation passes; this file describes the resulting checks and limits.

## Build

- MADS 2.1.7, Python 3, Pillow 10.4.0, py65 1.2.0.
- Executable: `sven-vbxe.xex`, **139,000 bytes**.
- SHA-256: `f2883ebe61889435631cfb0122e7288422ef96a598f4eaa7e1ba4318e89e39a0`.
- 33 embedded 4 KB VRAM uploads, 320×200 background, 38 sprite frames.
- `./verify.sh` rebuilds and runs the complete assembled-code suite.

In this workspace, py65 was already available in `/tmp/porter-test-deps`:

```sh
PYTHONPATH=/tmp/porter-test-deps ./verify.sh
```

That directory is only a local test dependency, not a game/build requirement.
For a fresh environment, install `requirements-test.txt` instead.

## CPU / VBXE model

The XEX is loaded segment by segment, executing every INIT vector on py65.
All four combinations of `$D600`/`$D700` and PAL/NTSC pass. The model uses real
GTIA register values (`$01` PAL, `$0E` NTSC), separate keyboard status/control
semantics, a deterministic 16-bit OS clock, palette streaming, banked VRAM,
opaque copies, and transparent blits.

Checks include:

- All asset uploads and the palette match the generated source bytes.
- Ready mode leaves the 90-second timer untouched; the HUD has exactly two
  timer digits, with no stale third character.
- One emulated second moves Sven exactly 100 horizontal pixels on PAL and NTSC.
- Clock wrap, multi-frame stalls, and the 90-second timeout preserve countdown
  timing; movement catch-up is bounded.
- WASD and joystick input, opposing directions, odd-coordinate bounds,
  held-fire behavior, edge-triggered START, pause/resume, and OPTION mute.
- Far-away fire collects nothing; eight reachable sheep produce the win state.
- Smoke finishes, all collected sheep disappear, and ending sounds become
  silent. Replay resets the game.
- 400 fixed-seed mixed-input steps per configuration preserve bounds/state.
- Both framebuffers are exercised. Every blit stays in bounds and avoids the
  displayed buffer. Actor baselines are sorted, and an independent composition
  matches the final visible framebuffer.
- Without VBXE, the requirement message is displayed and no blitter runs.

The full nine-actor render takes **5,556 modeled CPU cycles**, excluding VBXE
DMA, OS interrupt overhead, and the real raster wait. This is a CPU-work
measurement, not a claimed hardware frame rate.

## Local Altirra

The sandboxed Windows launch initially failed with `UtilBindVsockAnyPort`.
Launching the existing local helper outside that sandbox worked. Tests use
Altirra/x64 **4.40**, the existing **XL ATOS PAL+VBXE / 320K Rambo** profile.
No device setup or persistent video-standard changes were made.

The first longer run found the PAL-detection error that the original CPU fixture
had hidden. The code and fixture were corrected, and the scenarios were rerun.
The corrected timer goes from 90 to 79 over 10.642 wall-clock seconds (including screenshot
helper overhead). Paused gameplay and HUD pixels are exactly unchanged across a
separate 10.668-second wait. The timeout check reaches `00` and the loss
message after a 92.320-second observation interval; Space then restores `90`
and a new game. The detailed screenshot timestamps are in
[`evidence/timing.json`](evidence/timing.json).

The final corrected-speed playthrough collects all eight sheep with 58 seconds
remaining, displays the win message, lets the smoke finish, and replays to a
fresh `0/8`, `90` game. The screenshots below were inspected directly.

| Check | Evidence |
| --- | --- |
| Original HUD bug | [Baseline](evidence/baseline-window.png) |
| Corrected timer | [After 10.642 seconds](evidence/timer-after-10s.png) |
| Pause remains unchanged | [Paused](evidence/paused.png), [10.668 seconds later](evidence/paused-after-10s.png) |
| Collection animation | [First sheep](evidence/collected-1.png) |
| All eight sheep / win | [Win after effects finish](evidence/win-settled.png) |
| Replay after winning | [Fresh game](evidence/replay.png) |
| Timeout and replay | [Time up](evidence/timeout.png), [fresh game](evidence/timeout-replay.png) |

The test scripts operate a specified local process and save screenshots:

```powershell
.\tools\emulator-playthrough.ps1 -ProcessId <Altirra PID>
.\tools\emulator-timing.ps1 -ProcessId <Altirra PID>
```

Run them sequentially: both send real keyboard events to the same window.
The playthrough uses timed WASD movement and fire; screenshots need inspection
because host keyboard timing can vary. The timing scenario also waits through
the full timeout. These scripts do not infer a pass merely from sending keys.

## Remaining limits

The real emulator run is PAL using the existing VBXE profile. Actual NTSC and
`$D700` emulator configurations, physical VBXE hardware, and a physical joystick
have not been exercised; those variants currently have CPU-model coverage.
POKEY envelope/register behavior is tested, but audio has not been assessed by
listening. The model does not emulate raster timing, OS interrupts, or VBXE DMA
contention. A PAL ANTIC/NTSC GTIA hybrid machine is outside the video-detection
assumptions.
