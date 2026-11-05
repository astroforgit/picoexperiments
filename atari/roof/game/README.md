# Star Fisher — VBXE game and pixel workshop

A quiet fishing game above dark nineteenth-century Paris. Load the spring gauge,
cast the float into the sky and watch it. It rests quietly with its bottom submerged,
then a star may nibble, gently tug or pull it completely under. Strike at the right
moment, and reel home to replace lost bait. The line hides
while the float waits, and drifting clouds can hide the float itself. POKEY loops excerpts from ambient1.m4a and ambient2.m4a. Collect five stars to finish the night.

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
  Masks can use up to 512 pixels in total, on rows 13–239, including the bottom edge; only the top menu strip is reserved.
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
- **Sounds:** import a recording (up to 32 MB), or choose **Both ambients**, **Ambient 1**, or **Ambient 2**. Select the start and length, compare
  **Original** with the **Atari** preview, and use **Stop** to end the loop preview.
  **Build Atari** writes the soundtrack into the executable. The project stores
  the source filename and selection; imported recordings live in `../sounds`.
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

- **PLAY**, **CLOUDS** (NONE / MEDIUM / HEAVY), **BOOBER**, **DIFFICULTY**, and **SOUND: ON/OFF**.
- **M** opens or closes the pause menu without losing your cast or bite.
- The menu shows rainbow-worm, electric-worm and caught-star icons with numbers.
  Worm counts include the worm on the hook. **B** opens the existing bobber catalogue.
- Joystick or arrow keys (`-` `=` `+` `*`, with or without CONTROL): up/down
  picks a row, left/right changes settings. Fire, A, Space or Enter activates the selected row.
- Clouds: none, three, or six drifting clouds. Difficulty changes probabilities only: Easy / Medium / Hard allow a bite on
  100% / 75% / 40% of quiet-interval completions, and apply 125% / 100% / 50%
  of each action’s base catch chance (rounded down, capped at 100%). Hard can
  therefore leave the bobber still across several intervals. Bite durations,
  casting speed, bait-loss odds and the dive cooldown do not change.

In the game:

- **Hold A, Space, or joystick fire** to load the spring gauge at the top right,
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
- The game screen shows only **M - MENU** and the spring meter, with no status
  messages, counters, title or bottom instructions. PLAY resumes a night, or starts a fresh night after winning or exhausting
  all worms. R also restarts the night.

| Scenario | Motion | Duration | Catch | Bait loss if ignored / failed strike |
| --- | --- | --- | --- | --- |
| Quiet waiting | stationary, partly submerged | 8–20 seconds | 0% | 0% / 0% |
| Gentle interest | one pixel sideways or down | 2.5 seconds | 5% | 10% / 10% |
| Aggressive dive | completely submerged | 1 second | 80% | 100% / 100% |
| Cautious nibble | occasional tiny tug | 2 seconds | 15% | 25% / 25% |
| False alarm | slight sideways sway | 1.5 seconds | 0% | 0% / 0% |
| Sideways take | slides sideways and dips | 1.5 seconds | 50% | 60% / 60% |
| Repeated tugging | repeated small dips and sway | 3 seconds | 30% | 50% / 50% |
| Heavy swimming | stronger sideways swimming and dips | 3 seconds | 20% | 35% / 35% |

These base odds are editable in the Fishing panel. Each surviving small bite adds 5 percentage points to subsequent bait-loss and dive odds,
up to a +50-point bonus. Full dives have a **three-minute minimum interval** of active play, including
before the first dive. Menu, win and bobber-popup time do not count. Only after
this interval can a small action escalate into a dive (base 35% + interest
bonus). The timing is a minimum, not a guaranteed dive every three minutes. If no dive follows, the next encounter comes after two
seconds and increasingly favours gentle interest or another sideways take.
Quiet water and false alarms still cannot consume bait. Reeling home resets
this interest buildup. A missed dive always consumes the worm after 50 PAL frames.

Each night has **five worms total**: three rainbow worms (one already fitted) and two
electric worms. Reeling home preserves a surviving worm and does not spend a spare.
Lost or consumed worms are replaced automatically on return, while spares
remain. Press **1** at home for rainbow bait or **2** for electric bait.
Switching types returns the surviving worm to its stock and takes one of the
other type, without changing the total. Automatic replacement falls back to the
other type when the current type is exhausted. Both use the same bite odds; rainbow bait cycles warm colours, electric bait
pulses blue and white. Bait is replaced only at home, and an empty hook cannot
cast. Menu icon counters include the attached worm and each type’s spares.
When the last worm is gone, a **GAME OVER** popup shows a caught-star icon and
the final count. A final hooked star scores on landing before this screen appears.
Release any held controls, then press any key, joystick button/direction, or
console key to return to the menu. **PLAY** starts a new night with zero stars
and all five worms. Holding the finishing strike cannot skip the result or
accidentally start another night.

The return shows exactly what happened: a brilliant 2×2 caught-star square with eight slowly pulsing halo pixels in place of
the worm, a bare hook after bait loss, or the remaining worm. The caught star
stays on display after landing until the next cast; it scores only once.
A held button cannot start another cast: release and press again.

## Game sketch

```text
REST / FIT WORM → CHARGE → CAST → QUIET WAIT → INTEREST / NIBBLE / TAKE
      ↑                              ↑                 │
      │                              └── bait survives ┤
      │                                                ├→ DIVE (1 second)
      │                                                └→ NO WORM: no more bites
      └── LAND CATCH / CHECK BAIT ← REEL ← STRIKE during any waiting state

Five landed stars → NIGHT COMPLETE
```

The default float is the small striped Quill bobber. A four-pixel rainbow worm
hangs beneath it on a fine three-pixel leader, slowly cycling and dimming over
about five seconds. The worm and leader are visible while casting and reeling, but hidden while
the bobber waits in the water. An empty hook replaces lost bait above water; the bobber hides during a dive. The charcoal line is drawn at
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

Sound starts enabled, with silence before the first clip. Open **M**, select
**SOUND**, and press Enter/fire or left/right to toggle it. Off silences all
channels and stops the sample timer; On resumes playback. The preference
lasts through new nights until you reload the game.

The **New night sounds** preset replaces the old continuous ambient loop.
It chooses equally between four excerpts from the new recordings: resonance
(2 s), distant echo (1.45 s), train (1.85 s), and water shimmer (0.9 s).
After each sound finishes, it waits a random 5–15 seconds before choosing
another. Clips never overlap. The initial pause uses the same limits.

The current project plays all 14 recordings in `assets/audio` (47.0 s at
3.96 kHz). The three 10 s "Crackle of the Cosmos" recordings are trimmed to
6.45 s each so that everything fits.

In the editor's Sounds tab, set **Minimum silence** and **Maximum silence**
(1–120 seconds), and choose how much of each recording plays with **Start** and
**Length** (up to 16 sounds, 0.1–10 s each), or by dragging on the waveform.
**Add all recordings** adds every unused recording at full length. Each card
shows how long it plays, the recording's full length and its memory size. Two
meters show the VBXE storage and the longest sound against the playback buffer.
A sound that is too long, or a set that is too large, is flagged in red, and
the build refuses it. **Night mix** previews 30 seconds of the same
sound/pause behavior. Build Atari applies your changes to the XEX.

Random mode uses three POKEY volume registers for 46 summed digital levels,
at 3.96 kHz by default. Channel 1 supplies the silent sample timer. During
pauses all audio channels and sample IRQs are off. Background loop and synth
modes remain available for custom projects; their occasional effects use the
legacy per-ten-minute chance controls instead of the silence settings.

Random-mode sounds are stored in VBXE memory, in the 46 whole 4 KB banks that
no graphics use: $13, $33–$3F, $53–$5F and $6B–$7D (184 KB, 47.6 s at
3.96 kHz). Audited occupied ranges: background $00000–$12BFF, cloud sprite
$14000–$158FF, bobber popup $16000–$1F9BF, framebuffers $20000–$32BFF and
$40000–$52BFF, cached menu panel $60000–$6AD6F, XDLs at $7E000 and the blitter
command at $7F000 (`VRAM_USED` in `tools/samples.py`). Each 4 KB bank is staged
at $A000 while loading and uploaded by `upload_bank`.

When a sound ends, the game picks the next one at random. While the main loop
waits for a frame, `sound_load` copies that sound one 256-byte page at a time
into a CPU RAM playback buffer. It never starts a page within about 40 lines of
the vertical blank, so frames are never delayed, and the sample IRQ never
switches MEMAC. The buffer holds 139 pages (34.8 KB): $0400–$1FFF,
$7800–$8FFF, $A000–$CFFF and $D800–$FEFF. That is the limit for one sound:
8.99 s at 3.96 kHz, 11.2 s at 3.2 kHz, 7.9 s at 4.5 kHz and 6.2 s at 5.8 kHz.
The IRQ steps through the four segments. Copying takes about 3–4 pages per
frame, so a full buffer loads in under 1 s, the shortest allowed pause. If it
does not finish, the next sound simply starts a little later.

At 3.96 kHz, all 14 originals untrimmed would need about 238 KB. At 3.2 kHz
they would need about 191 KB, and the 10 s length cap would also apply. Either
way, some trimming is needed.

Background loop and synth modes keep their samples in CPU RAM: $7800–$8FFF,
$A000–$BFFF, and under the OS ROM at $C000–$CFFF and $D800–$FFF9 (28 KB).

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
python3 tools/test_vram_audio.py
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
  `tools/pcm_emu.py`, the shared emulator plus POKEY timer IRQs and VCOUNT.
- `tools/test_vram_audio.py`: sounds uploaded to the spare VBXE banks; a long
  play session never writes VRAM outside the audited ranges; every sound copies
  byte-exactly into the playback buffer, only during pauses; an 8 s sound plays
  every level across all four buffer segments; constant loading leaves every
  presented frame unchanged.
- `tools/test_game.py` / `tools/test_fishing.py`: exact percentage rolls, quiet
  waiting, timed bites, lost-bait lockout, rebaiting, submerged sprites, menu
  bounds and five catches through real keyboard input.

## Implementation

The game uses states REST, CHARGE, CAST, REEL, WAIT, GAME OVER and MENU. The menu
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
