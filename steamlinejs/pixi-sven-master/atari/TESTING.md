# Illustrated title screen — 2026-09-07

The reference-style title is embedded in `sven-vbxe.xex` (344,602 bytes), SHA-256
`0c3c7b8cb72a0dcd31357ce56ed5a9550208108e1815902c7196f910bd45f30d`.
The build now uploads 80 banks, including the independent title bitmap at
`$60000`; game sprite addresses and the gameplay palette remain unchanged.

The runtime suite checks exact title framebuffer pixels across both buffers,
the title palette, Fire-to-play, restored meadow palette/background and HUD,
and the existing mechanics on D600/D700 at 50/60 Hz. The modeled title capture
is `generated/title-runtime.png`; the asset preview is `generated/title-preview.png`.
The verification log is `evidence/title-tests.txt`.

Altirra 4.40 PAL displayed the new title. `evidence/title-altirra.png` is partially
obscured by a desktop window; `evidence/title-start-altirra.png` confirms Space
entered the meadow with restored colors and HUD. Real hardware and NTSC remain
unverified. Artwork and the exact built-in imagegen prompt: `assets/TITLE.md`.

---

# First milestone verification

## Moods, devil sheep and mushrooms — 2026-09-07

Current executable: 269,670 bytes, 106 sprite slots, 62 upload banks. The current
checksum is in `sven-vbxe.sha256`. [Final regression output](evidence/moods-tests.txt)
covers four mood stages, refusal, whistle boundary, devil transformation/recovery,
shock stun/point saturation/repeat protection, enemy vulnerability, both mushrooms,
speed expiry, movement bounds, pause and restart. PAL/NTSC full playthroughs
use only inputs and include live enemies, moods, water and mushrooms.

The ANTIC display list is now aligned to a 256-byte boundary: the enlarged code
previously put it across a 1 KB boundary, hiding the HUD in Altirra. A layout
assertion now checks this hardware constraint.

New artwork and prompts: [assets/DEVILS.md](assets/DEVILS.md). The importer
converts the generated RGB sheet to transparent indexed sprites, including
removal of border-connected checker background.

CPU-model visual evidence: [electrical shock](generated/devil-shock.png) and
[red sheep](generated/devil-mushrooms.png). Altirra checks use
`tools/emulator-moods.ps1`. Final Altirra PAL screenshots confirm the
[restored HUD](evidence/moods-ready.png), [devil sheep after foul mushroom](evidence/moods-devils.png)
and [golden mushroom speed boost](evidence/moods-speed.png). The full modeled
wins finish at 61.42 simulated seconds with one life (PAL) and 60.15 seconds
with three lives (NTSC). These are not claimed as full Altirra wins. Physical
VBXE hardware remains untested.

The following sections are historical reports for earlier builds.

## Double-fire whistle update

Current binary: 248,199 bytes. Whistle requires two fire presses within 15
simulation ticks (0.3 seconds), with a release between presses. Single fire
does not whistle; held fire still interacts. Pause/restart clear click history.
[Regression output](evidence/double-fire-tests.txt) covers actual joystick and
Space edges at PAL/NTSC rates, held input, expiry, pause and restart, plus full
gameplay regressions. `emulator-sheep.ps1` now uses the window helper’s
`-DoublePress` switch to send the same input in Altirra.

The sections below describe earlier builds.

## Dog and slower-interaction update

Current executable: 248,134 bytes; current checksum in `sven-vbxe.sha256`.
The dog is enlarged and enters a two-second fast pursuit when interaction
begins. All four love directions are selected from Sven’s approach and locked
during the scene. Sunny/cloudy progress takes 64/96 simulation ticks.
Completion and release each render exactly one Sven.

`tools/test_encounters.py` covers direction locking, progress duration, duplicate
removal, rest interruption and stable diagonal pursuit. The full input-only
controller now selects safer sheep, retreats from nearby enemies and whistles
at storm sheep. The former fixed route lost all lives under the stronger pursuit.
See [current regression output](evidence/dog-interaction-tests.txt).

The existing Altirra PAL milestone exercise was rerun on this binary;
`milestone-*.png` now show the larger dog and this updated build. Full wins
are CPU-model checks, not Altirra wins. Reports below describe historical builds.

## Living sheep update

Current build: 248,061 bytes, 94 sprites, 57 upload banks. The current hash is
in `sven-vbxe.sha256`. [Regression output](evidence/sheep-tests.txt) includes
all four runtime configurations, full input-only PAL/NTSC wins, and dedicated
sheep behavior checks. The full runs now finish with one life remaining.

New Altirra PAL captures: [whistle](evidence/sheep-whistle-altirra.png) and
[wandering](evidence/sheep-wandering-altirra.png). These use the existing
profile and keyboard helper `tools/emulator-sheep.ps1`.

The following sections describe earlier builds and their evidence.

## Interaction animation update

The current executable adds the five existing `humpRight` frames for sheep
interaction and completion. The former completion cloud now plays only on
dog/shepherd contact, at the original collision site. The automated regression
checks active animation, release, completion, both enemy contacts, final-life
animation expiry and restart. See [new run](evidence/interaction-tests.txt).

The report below records the earlier milestone binary and its Altirra evidence;
its executable size/checksum and sprite counts predate this animation change.
The current checksum is in `sven-vbxe.sha256` (74 sprites / 48 upload banks).

Date: 2026-09-06. The earlier collection game is preserved in checkpoint
`53f280f`; this report describes the new gameplay milestone.

## Final executable and reproduction

- `sven-vbxe.xex`: **202,221 bytes**.
- SHA-256: `da4f9af48b0b325b6d97cf16a812f89640217c61ec4ef1694ba9b6b09042d548`.
- MADS 2.1.7, Pillow 10.4.0, py65 1.2.0.
- 46 embedded 4 KB uploads, 69 sprite slots, 8 KB CPU water mask.

From `atari`, install `requirements-test.txt` and run `./verify.sh`. In the local
workspace py65 was already available, so verification used:

```sh
PYTHONPATH=/tmp/porter-test-deps ./verify.sh
sha256sum -c sven-vbxe.sha256
```

[Full output](evidence/milestone-tests.txt) records the passing mechanics matrix
and the two complete playthroughs. Builds refresh the checksum automatically.

## Assembled-code coverage

The harness executes each XEX INIT segment and then the actual 6502 routines.
Its VBXE model covers banked memory, palette streaming, opaque/transparent blits,
and deterministic OS clock/input reads. All combinations of `$D600` / `$D700`
and PAL / NTSC pass, as does the missing-VBXE path.

Assertions cover:

- Asset/palette integrity, ready state, correct hardware video detection,
  one-second movement, countdown, clock wrap and skipped renders.
- Pause freezing time, moods, actors and protection; held START and OPTION edges.
- Sustained interaction, persistent partial progress, completed smoke, score,
  time bonuses, sunny/cloudy/storm transitions, whistle range/cooldown.
- Dog pursuit and rest, shepherd patrol, hits from both enemies and storm sheep,
  exactly one life lost per hit, protection and the final zero-lives state.
- Upper puddle, lower puddle and pale shoreline water: relocation and protection
  without losing a life.
- Win/replay, time-out, finite ending audio, and sound mute.
- Eleven actors sorted by baseline followed by eight mood/progress overlays.
  Every blit stays in bounds and avoids the displayed buffer; an independent
  composition matches the final framebuffer.
- 500 fixed-seed mixed-input steps per configuration preserve valid bounds,
  life counts, scores, timers and states.

The full initial scene costs approximately **14,100 modeled CPU cycles** to
render. This excludes VBXE DMA, OS interrupt cost and real raster waiting; it is
not a hardware FPS measurement.

## Complete gameplay without state manipulation

`tools/test_playthrough.py` observes positions and sends joystick/fire values.
It never changes player positions, lives, timers, moods, enemy state or score.
All gameplay systems remain enabled. Both PAL and NTSC runs complete all eight
sheep with **two lives and 91 seconds remaining**, including the collection time
bonuses. Completion is at approximately 15.86 / 15.88 simulated seconds.

The earlier dog step caused repeated deaths in this route. Its horizontal speed
was corrected to match the meadow's movement proportions, and the complete
playthrough was rerun successfully. This test supplements isolated mechanics
checks with proof that the full loop is playable.

[Modeled win framebuffer](generated/milestone-playthrough-win.png)

## Local Altirra

Actual local emulator: **Altirra/x64 4.40, XL ATOS PAL+VBXE / 320K Rambo**, using
its existing persistent profile. The game does not use that CPU RAM expansion.
The Windows helper was run outside the restricted sandbox. No device/video
profile changes were made.

`tools/emulator-milestone.ps1 -ProcessId <PID>` exercises actual keyboard input
and saves these screenshots. The script sends inputs; screenshots are inspected
rather than treating successful key delivery as a gameplay pass.

| Check | Evidence |
| --- | --- |
| New enemies, icons and HUD | [Ready screen](evidence/milestone-ready.png) |
| Interaction and active enemies | [Gameplay](evidence/milestone-progress-and-enemies.png) |
| Pause | [Paused](evidence/milestone-paused.png) |
| Water relocates Sven, retaining three lives | [Water escape](evidence/milestone-water-escape.png) |
| Enemy contact / life loss | [Hit](evidence/milestone-hit.png) |
| Three lives exhausted; game-over message | [Danger](evidence/milestone-danger.png) |

Earlier `baseline-*`, `timer-*`, `collected-*`, `win*`, and `timeout*` screenshots
belong to the checkpoint development history, not this milestone executable.

## Limits

Actual emulator testing is PAL with the existing VBXE profile. Physical VBXE
hardware, a physical joystick, and actual NTSC/D700 emulator configurations have
not been exercised. The full automatic win is currently verified in the CPU
model, not claimed as an Altirra playthrough. Audio register/envelope behavior
passes tests; sound has not been assessed by listening. The model does not
emulate DMA contention or OS interrupt timing. A mixed PAL ANTIC / NTSC GTIA
machine is outside the video-detection assumptions.
