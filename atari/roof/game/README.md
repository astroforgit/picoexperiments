# Star Fisher — VBXE game and pixel workshop

A quiet fishing game above dark nineteenth-century Paris. Load the spring gauge,
cast the float into the sky and watch it. It rests quietly with its bottom submerged,
then a star may nibble, gently tug or pull it completely under. Strike at the right
moment, and reel home to replace lost bait. The line hides
while the float waits, and drifting clouds can hide the float itself. A POKEY night
ambience is currently disabled. The optional ambience includes: wind, and now and then a distant dog, a steam
train whistle, a church bell, an owl, a cat or a passing carriage. Collect five stars to finish the night.

## Pixel editor

Start the local web editor and open http://127.0.0.1:8791:

```sh
./editor/run.sh
```

The editor uses the same 320×240 indexed background and all 256 palette entries
as the native game. Pixels use nearest-neighbour enlargement, with a grid,
coordinate readout, and a magnifier. No repainting or AI regeneration is involved
when moving an object or editing a light mask.

- **Lights:** choose a group, zoom to its window, then paint or erase individual
  pixels (right-click also erases). Rectangle filling, undo/redo, and up to 16
  independent groups are supported. Select steady, candle, or on/off lighting.
  Masks can use up to 512 pixels in total, anywhere outside the interface strips.
- **Sky library:** drag a proposed small star, comet, moon, galaxy or dark cloud
  onto the scene. Alternatively, select a design and click to place it.
- **Scene:** move, duplicate, delete or nudge placed objects. Arrow keys move one
  pixel; Shift moves ten. The original painting remains a fixed backdrop.
- **Edit selected sprite pixels:** alter a proposal with the native palette or
  make a copy. Palette index 0 is transparent. Right-click erases.
- **Sky settings:** set one-pixel and two-pixel star counts (0–96 each), the
  percentage that gently twinkle (0–100), and meteor chance per ten seconds
  (0–100%), and the star colour: ivory, the moon's colour, the colour of the
  stars painted in the original artwork, or a custom colour. Star positions
  remain fixed. Save/Build and JSON export retain all settings.
- **Sounds:** sample rate, memory meter, wind (recorded loop or synthesised
  noise) and up to six recorded sounds with name, file, start, length, gain
  and plays per 10 minutes. Select a sound and drag on the waveform below the
  screen: the top strip moves the selection through the whole recording, the
  close-up chooses exactly what plays. ▶ Original plays the source slice;
  ▶ Atari 4-bit plays the exact levels the game will play. ▶ Night mix plays
  30 seconds of wind with randomly chosen sounds.
- **Fishing:** configure quiet waiting time, gentle-interest escalation, and each
  scenario's relative frequency, duration, catch chance, bait loss when ignored,
  and bait loss after a failed strike. Turn the spring gauge bounce on or off.
- **Caught star:** choose the native float/caught-star mask.
  The game uses its gold/ivory pulse colours; placed sprites retain their colours.
- **Save project:** writes `editor-scene.json`, retaining the previous save as
  `editor-scene.previous.json`. JSON import/export and a local draft are available.
- **Build Atari:** saves, rebuilds the XEX, and renders a screenshot in the actual
  headless emulator. **Built game** shows that framebuffer, not a web recreation.

Placed sky decorations (including cloud stamps) are currently static in the
native game. Three separate native clouds drift slowly across the sky and mask
stars. A short meteor falls occasionally, with long random pauses. These moving
effects appear in Built game; the composition canvas edits the static scene.
Sky stars remain fixed; a selected fraction gently change between two ivory shades. The editor's light-animation
preview follows the native lighting rules; its wall-clock pace is approximate
because native game updates follow rendering cadence. The indexed scene pixels
and saved masks themselves are shared exactly with the native build.

The server binds to loopback only and writes only this game's project and build
outputs. Run `editor/run.sh 8792` to use another port. Earlier concept images and
packages remain outside the editable project.

## Bobber catalogue

Press **B** during play to open the dark navy **Bobber Designs** catalogue,
with gold selection borders and framed cards matching the original concept sheet. Fishing pauses while it is open. Eight designs each have
small and large versions; the default is **02 Quill, small (1×6 pixels)**.

- Left/right arrows: previous/next design (wraps around).
- Up/down arrows: switch small/large size.
- Enter, A, Space or joystick fire: equip the highlighted bobber and resume.
- B or Escape: close without applying changes.

The selected bobber stays equipped when returning to the start menu. Every design has its bottom third submerged while waiting, and disappears
completely during an aggressive dive.

## Play

Load `star-fisher.xex` on an Atari XL/XE with a VBXE FX core, or in a suitably
configured emulator. PAL, 320×240 is the current target. Both D640 and D740
register bases are detected. The adjacent projects' Altirra launcher works with:

```sh
./run.sh
```

The game starts in a menu drawn over the live night scene:

- **START GAME** and **CLOUDS** (NONE / MEDIUM / HEAVY, default MEDIUM).
- Joystick or arrow keys (`-` `=` `+` `*`, with or without CONTROL): up/down
  picks a row, left/right changes clouds. Fire, A or Space selects.
- Clouds: none, three, or six drifting clouds. Catch odds use the editor values
  directly, without a difficulty multiplier.

In the game:

- **Hold A, Space, or joystick fire** to load the spring gauge right of POWER,
  then **release** to cast. Full power takes **half a second** (25 PAL frames).
  By default the gauge springs back down after it
  fills, so release at the right moment.
- The gauge level sets forward distance and height: low power makes a short
  cast above the roofs; full power reaches far left and high into the sky.
  Every cast goes forward, away from the fisherman.
- **WATCH THE FLOAT**: the line disappears; only the rod and the float remain.
  Clouds can drift in front of the float.
- **Tap A, Space, or fire** to strike. The line reappears and the float is
  reeled home: **STAR HOOKED!** or **MISSED - EMPTY HOOK**.
- A caught star scores only after it reaches the fisherman.
- **R** returns to the menu. After five catches, press R to play another night.

| Scenario | Motion | Duration | Catch | Bait loss if ignored / failed strike |
| --- | --- | --- | --- | --- |
| Quiet waiting | stationary, partly submerged | 8–20 seconds | 0% | 0% / 0% |
| Gentle interest | one pixel sideways or down | 2.5 seconds | 5% | 10% / 10% |
| Aggressive dive | completely submerged | 1 second | 80% | 100% / 100% |
| Cautious nibble | occasional tiny tug | 2 seconds | 15% | 25% / 25% |
| False alarm | slight sideways sway | 1.5 seconds | 0% | 0% / 0% |
| Sideways take | slides sideways and dips | 1.5 seconds | 50% | 60% / 60% |

These defaults are editable in the Fishing panel. After gentle interest, if bait
survives, there is a 35% chance of an aggressive dive. Otherwise quiet waiting
resumes. A missed dive consumes the worm after exactly 50 PAL frames; the float
returns to its resting position. With no worm, no further star takes interest.
Reel completely home to automatically fit a fresh worm before casting again.
A held button cannot start another cast: release and press again.

## Game sketch

```text
REST / FRESH WORM → CHARGE → CAST → QUIET WAIT → INTEREST / NIBBLE / TAKE
      ↑                              ↑                 │
      │                              └── bait survives ┤
      │                                                ├→ DIVE (1 second)
      │                                                └→ NO WORM: no more bites
      └── LAND CATCH / REBAIT ← REEL ← STRIKE during any waiting state

Five landed stars → NIGHT COMPLETE
```

The default float is the small striped Quill bobber. A four-pixel rainbow worm
hangs beneath it on a fine three-pixel leader, slowly cycling and dimming over
about five seconds. The worm and leader are visible while casting and reeling, but hidden while
the bobber waits in the water. Lost bait disappears; the bobber hides during a dive. The charcoal line is drawn at
runtime from the rod tip while casting, reeling and at rest, never while the
float waits. The sky uses one- and two-pixel
ivory stars in fixed random positions. By default, there are 48 single-pixel
stars and 16 double-pixel stars, with 25% gently twinkling. The editor changes
these counts immediately in the composition preview. Cast strength changes distance and height, not
catch probability.

Three 160×40 dark clouds mask stars as they pass, moving one pixel per 64 PAL
VBIs (about 1.28 seconds). Every 500 PAL VBIs (ten seconds), the game makes one
meteor probability check; the default is 30%. 0% disables meteors, while 100%
always produces a meteor at each check. These clocks are independent of render
speed.

## Sound

Recorded sounds live in `../sounds` (any format ffmpeg reads; the defaults are
the Pixabay `freesound_community` breeze and quiet-city-square recordings).
`tools/samples.py` cuts each chosen part, band-limits and resamples it with
ffmpeg, normalises it, applies its gain and quantises it to 4 bits, two
samples per byte. `sound.asm` plays them in POKEY volume-only mode from a
timer 1 IRQ at 63337 / (AUDF1 + 1) Hz (3.2–5.8 kHz, default 4.5 kHz):

- Channel 1: the silent sample timer.
- Channel 2: recorded clips, one at a time. Once a second the VBI rolls
  against cumulative chances from each clip's plays per 10 minutes. Clips
  ease in and out of silence so they do not click.
- Channel 3: the recorded wind loop. Its end crossfades into its start so the
  loop has no seam. It costs about 15% CPU while it runs; the timer is
  switched off whenever nothing needs it.
- Channel 4: the synthesised wind, when chosen instead. It copies Slayder
  (`../slay.atr`, `SLAYDER.XEX` around $52f0): distortion 8 white noise,
  here with gentle gusts and silent gaps.

Samples use RAM at $7800–$8FFF, $A000–$BFFF, and under the OS ROM at
$C000–$CFFF and $D800–$FFF9 (28 KB in all). Under-OS data is staged at $A000
during loading and copied by `os_copy` with the OS switched out. The build
fails with a clear message if the chosen clips do not fit.

Six small windows add warm amber light to the houses. Distant windows switch
on and off on independent slow timers; the nearest dormer stays lit and briefly
flickers. Lights use their own random seed so they do not change bite timing.

The moon and galaxy remain in the dark gothic background. The permanent comet
and painted stars have been removed; stars and the occasional downward meteor
are now drawn by the game. Three dark, grainy clouds pass in front of them.
The seated character body is static. The rod, line, float, gameplay stars,
bite feedback, and retrieval are animated separately by the game.

## Build and test

Requires MADS, Python 3, and Pillow. The headless tests also use NumPy and py65
through the existing `../../lair/tools/emu.py`.

```sh
./build.sh
python3 tools/test_game.py
python3 tools/test_windows.py
python3 tools/test_stars.py
python3 tools/test_display.py
python3 tools/test_sky.py
python3 tools/test_sound.py
```

- `star-fisher.asm`: native 6502 game, controls, states, VBXE drawing.
- `star-fisher.xex`: current executable.
- `sky.asm`: slow cloud motion, occlusion and occasional falling meteor.
- `tools/test_sky.py`: motion, masking, restoration, meteor lifetime and independent RNG.
- `tools/build_assets.py`: image conversion, palette, interface and rod poses.
- `assets/background-night-art.png`: clean night plate without a permanent comet or stars.
- `assets/background-320x240.png`: indexed background with interface strips.
- `assets/default-windows.json`: default window masks and lighting settings, imported
  from `star-fisher-project (2).json`; used for new editor projects and default builds.
- `screenshots/float-fishing-demo.gif`: recording from the running XEX.
- `screenshots/window-lights-demo.gif`: animated city-light preview.
- `tools/test_display.py`: actual XDL palette selection for both buffers and VBXE
  register addresses, plus exact agreement with editor RGB colours. This checks
  the attribute bits explicitly because the shared screenshot emulator assumes palette 1.
- `tools/test_stars.py`: editor-selected tiny star mask, pixel bounds and preserved drawing anchor.
- `tools/test_windows.py`: window placement, full framebuffer addresses, dim/on/off
  states, clean restoration, and independent lighting timers.
- `tools/test_sound.py`: sample data in all RAM regions; every nibble the
  timer IRQ plays (wind loop and each clip) equals the editor preview; synth
  wind gusts; the timer stops when idle; a silent sound-off build. It uses
  `tools/pcm_emu.py`, the shared emulator plus POKEY timer IRQs.
- `tools/test_game.py` / `tools/test_fishing.py`: exact percentage rolls, quiet
  waiting, timed bites, lost-bait lockout, rebaiting, submerged sprites, menu
  bounds and five catches through real keyboard input.

## Implementation

The game uses states REST, CHARGE, CAST, REEL, WIN, WAIT and MENU. The menu
panel is composed in spare VRAM at $60000 only when a choice changes, then
copied into each frame with one blit. Randomness
comes from a small LFSR seeded from POKEY on reset. Bite durations are counted in PAL vertical blanks (50 Hz), independently of
render cadence, and pause while the bobber catalogue is open. The cast flies in 16 steps of 8.8 fixed-point motion
with an arc; reeling uses the same path code. The build generates the gauge
heights, the 64-slot scenario lookup, PAL duration tables and exact percentage odds
from the project. Palette slot 246 carries the ambient star colour.

The background occupies VRAM $00000; the 160×40 transparent cloud sprite is at $14000. The blitter restores hidden framebuffers
at $20000/$40000; the game draws dynamic graphics, then swaps XDLs at $7e000.
The blitter command resides at $7f000. Palette zero is unused; reserved colours
provide the black rod, charcoal line, coral float, bright stars, amber window
lights and interface.
The boot and bank-upload scheme is reused from the adjacent Lich slideshow.

The background was edited with the built-in image tool to remove the permanent
comet and painted stars, retaining the moon, galaxy, dark city and character
geometry. Earlier art and game packages remain available in the parent folder.

Validation uses the local headless emulator. Physical Atari hardware and desktop
Altirra have not been tested for this revision. NTSC timing is not tuned.

## Editor verification

`tools/test_editor.py` launches an isolated project copy, tests browser drawing,
zoom, drag/drop, sprite editing, import/export and save/build, then boots the
edited XEX to verify a painted window pixel in VBXE memory. It requires Node 18+
and Playwright/Chromium; optional environment variables are `NODE_BINARY`,
`PLAYWRIGHT_MODULE`, and `CHROMIUM_PATH`. It never writes test edits into the live
project.
