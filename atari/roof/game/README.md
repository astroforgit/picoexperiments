# Star Fisher — VBXE game and pixel workshop

A quiet fishing game above dark nineteenth-century Paris. Cast a long black rod
into the sky and leave the float there. Stars blink into view at random places.
Eventually one appears at the bait: the float flashes and a bite tone sounds.
Tap A or fire to strike and reel it home. Collect five stars to finish the night.

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
- **Gameplay star:** choose the actual native blinking/flying/caught star mask.
  The game uses its gold/ivory pulse colours; placed sprites retain their colours.
- **Save project:** writes `editor-scene.json`, retaining the previous save as
  `editor-scene.previous.json`. JSON import/export and a local draft are available.
- **Build Atari:** saves, rebuilds the XEX, and renders a screenshot in the actual
  headless emulator. **Built game** shows that framebuffer, not a web recreation.

Placed sky decorations (including cloud stamps) are currently static in the
native game. Gameplay stars still blink and drift. The editor's light-animation
preview follows the native lighting rules; its wall-clock pace is approximate
because native game updates follow rendering cadence. The indexed scene pixels
and saved masks themselves are shared exactly with the native build.

The server binds to loopback only and writes only this game's project and build
outputs. Run `editor/run.sh 8792` to use another port. Earlier concept images and
packages remain outside the editable project.

## Play

Load `star-fisher.xex` on an Atari XL/XE with a VBXE FX core, or in a suitably
configured emulator. PAL, 320×240 is the current target. Both D640 and D740
register bases are detected. The adjacent projects' Altirra launcher works with:

```sh
./run.sh
```

- **Hold A, Space, or joystick fire**, then **release** to cast.
- Holding longer chooses a farther spot: short, medium, or long reach.
- The float stays in that spot. Casting no longer triggers automatic reeling.
- **WAIT FOR A BITE** means leave the float out. Three stars blink and relocate.
- **BITE! TAP A / FIRE**, the flashing float, and a tone signal a bite.
- **Tap A, Space, or fire during the bite** to hook the star and reel it home.
- Tapping while waiting retrieves an empty float so you can cast elsewhere.
- Ignoring a bite loses that opportunity, but leaves the float in the sky.
- A caught star scores only after it reaches the fisherman.
- **R** resets. After five catches, press R to play another night.

Once retrieval starts, reeling animates automatically. A held reel button cannot
start another cast when the float reaches home; release and press again.

## Game sketch

```text
REST → HOLD / CHARGE → RELEASE / CAST → FLOAT WAITS
  ↑                                    │       ↑
  │                           random bite      │ missed bite
  │                                    ↓       │
  └── LAND CATCH ← REEL ← TAP A/FIRE ← FLOAT FLASHES
  └── EMPTY REEL ← TAP WHILE WAITING

Five landed stars → NIGHT COMPLETE
```

The float is a small coral-and-ivory marker attached to the longer charcoal
line. During a bite, its lower end flashes. Filled five-point gold/ivory stars
appear at random sky positions, fade out, and relocate; there are at most three
at once. Two of the three stars slowly fly in opposite directions between
appearances. No animated stars use the old cross-shaped glyph. A star appears at the float after a random waiting interval. Cast
strength currently changes the location, not the bite probability.

Six small windows add warm amber light to the houses. Distant windows switch
on and off on independent slow timers; the nearest dormer stays lit and briefly
flickers. Lights use their own random seed so they do not change bite timing.

The moon, comet, and sparse background stars are brighter, while the buildings
and sky retain the dark gothic lighting. These celestial background features
and the seated character body are static. The rod, line, float, gameplay stars,
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
```

- `star-fisher.asm`: native 6502 game, controls, states, VBXE drawing and tones.
- `star-fisher.xex`: current executable.
- `tools/build_assets.py`: image conversion, palette, interface and rod poses.
- `assets/background-float-art.png`: current bright-celestial/dark-city plate.
- `assets/background-320x240.png`: indexed background with interface strips.
- `screenshots/float-fishing-demo.gif`: recording from the running XEX.
- `screenshots/window-lights-demo.gif`: animated city-light preview.
- `tools/test_display.py`: actual XDL palette selection for both buffers and VBXE
  register addresses, plus exact agreement with editor RGB colours. This checks
  the attribute bits explicitly because the shared screenshot emulator assumes palette 1.
- `tools/test_stars.py`: five-point glyph shape, pixel bounds and slow drifting motion.
- `tools/test_windows.py`: window placement, full framebuffer addresses, dim/on/off
  states, clean restoration, and independent lighting timers.
- `tools/test_game.py`: upload, blink/relocation, wait, missed bite, manual reel,
  held-input handling, all three distances, five catches, and register-base tests.

## Implementation

The game uses states REST, CHARGE, CAST, REEL, WIN, WAIT and BITE. Randomness
comes from a small LFSR seeded from POKEY on reset. Waiting and bite durations
are counted in game updates; the current prototype follows render cadence,
not a tuned 50 Hz simulation. A bite lasts 48 updates; waiting lasts 60–123.

The background occupies VRAM $00000. The blitter restores hidden framebuffers
at $20000/$40000; the game draws dynamic graphics, then swaps XDLs at $7e000.
The blitter command resides at $7f000. Palette zero is unused; reserved colours
provide the black rod, charcoal line, coral float, bright stars, amber window
lights and interface.
The boot and bank-upload scheme is reused from the adjacent Lich slideshow.

The background was edited with the built-in image tool: brighten only the
existing moon, comet, and sparse stars, retaining the dark city and character
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
