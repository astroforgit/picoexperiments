# Kult: Diabolic — stars-only Atari edition

A native modification of Kult for a standard PAL Atari 800XL with 64 KB.
Booting opens directly into spaceship gameplay: no title menu, stage-one
announcement or fire prompt. Later stage announcements are skipped as well.
The original waves, weapons, score display, sound and monochrome palette remain.

The starfield follows the supplied grayscale canvas example: right-to-left motion,
three depth layers, rounded foreground stars and gradual triangular luminance
ramps. Native rates are 0.5, 1.5 and 3.5 hires pixels per game update, preserving
the example's 1:3:7 far/middle/near speed ratio. All stars are two-by-two hires pixels. Near stars are bright white; middle and
distant stars use medium and dark grey shades. Brightness and movement speed
supply the depth cue. Near stars remain brighter than the middle layer
throughout their gentle twinkle cycle. There are no cross-shaped flares or streaks.

The layout contains 8 near, 16 middle and 32 far stars, placed with random
positions and separation checks. Every star has its own horizontal coordinate;
there are no shared missile columns or regularly spaced star rows.

The scanline interrupt prefetches positions before the horizontal blanking wait,
then writes all three positions before the beam reaches the left edge. This
prevents stars vanishing in the left half of the sky. Full glyphs are retained
separately and clipped pixel by pixel at the playfield boundaries; a star wraps
only after its trailing pixels have left the sky. No stars draw into the HUD or
side borders. The old tile background is black. Brightness phases differ
between depth groups.

This is an Atari adaptation: quantized grayscale and pixel-rounded shapes
replace canvas alpha blending and anti-aliasing; translucent nebula gradients
are not rendered. Stars remain harmless. No planets, comets, new colour hues or
VBXE are used.

Run:

```sh
/home/marcin/tmp/pico/atari/kult/diabolic/run-emulator.sh
```

The launcher shares Babajaga/Speed's isolated standard Altirra configuration.
Arrow keys move; left Ctrl fires. The original `Kult (v1).xex` is untouched.

## Saved planet-and-comet edition

- `saved/kult-diabolic-planets-comets.xex`: the previous playable executable.
- `saved/planets-comets-source.zip`: complete source, graphics and verification
  snapshot from before this change. Extract into a sibling of `diabolic/` under
  `kult/` to rebuild it with the same relative editor/decompiler paths.
- `saved/scenery-planets.png`: the previous scenery asset preview.

To play the saved version:

```sh
/home/marcin/tmp/pico/atari/babajaga/run-emulator.sh /home/marcin/tmp/pico/atari/kult/diabolic/saved/kult-diabolic-planets-comets.xex
```

## Build and verification

```sh
cd /home/marcin/tmp/pico/atari/kult/diabolic
./build.sh
python3 test_build.py
```

Requires Python 3, Pillow, py65 and MADS. `space.asm` implements native horizontal star
movement, scanline positions, luminance ramps and menu cleanup. `build.py` generates graphics and packages
the patched runtime. A literal prefix in the retired tile bank prevents Kult's
in-place depacker from overwriting unread input. Every loaded runtime block is
verified by replaying the original 6502 loader.

CPU tests check patch boundaries, ship alignments, harmless stars versus solid
enemy pixels, leftward layer speeds, horizontal wrapping and unchanged vertical graphics, luminance
phases, direct-start patches, scanline interrupt restoration and blank terrain. `verify-emulator.ps1`
boots the distributed executable in Altirra without menu-bypass debugger edits
and captures direct flight and later gameplay. This is a smoke test, not a full
campaign completion test.

`python3 verify_edges.py` runs an additional actual-emulator check. After normal
flight captures, it freezes star movement and places eight foreground stars at
known horizontal positions, including partially visible stars at both edges.
It verifies every expected star pixel in the captured image. These diagnostic
RAM edits are confined to that emulator session, never the distributed XEX.
The verifier rejects stale screenshots as well as missing expected pixels.


## Flight workshop

Open http://127.0.0.1:8772/flight/ while `python3 editor/serve.py --port 8772`
is running from the Kult directory. Select a sector and wave, enemy slot,
movement path, hit points and drop pattern. The lower canvas previews the
selected encounter; click it and use arrows to steer and Space to fire.
Browser entry timing and drawing are approximations of the native game.

There are five animated ship styles and 36 enemy designs (32 original plus
four new). Each has four animation frames. Assign a design to one of the
32 native slots; all waves referencing that slot share its appearance.
Movement paths are also shared by waves. Save/Open project preserves the
full configuration as JSON.

Enemy shooting supports Off, Straight and Aim towards ship, configurable
interval and speed. Up to four native hardware missile shots can exist at
once. Aimed shots choose an upward, level or downward trajectory when fired;
they do not home. Hits use the original death and invulnerability handling.

Download Atari XEX creates a verified executable. Apply to local game saves
`game-project.json` and replaces `kult-diabolic.xex`; restart
`diabolic/run-emulator.sh` to play it. The original Kult executable is preserved.
Run `python3 diabolic/test_workshop.py` for native export and shooting checks.
The generated source art and conversion provenance are in `art/`.


### Aggressive flight balance

Twin-engine fighter is selected by default. Wave entry starts at offset 96
instead of 128, and formations advance left twice per update. Path phase
increments are 1.5 times their previous values (rounded to signed integers).
Aimed enemy fire defaults to an 18-update interval and speed 3.
Every native drop pattern retains at most two package awards, distributed
through the wave; package types and patterns with fewer awards are preserved.
The preceding saved project is `saved/project-before-aggressive.json`.

Enemy bullets are bright rectangular 8×4-pixel laser bolts, distinct from the
2×2 stars. The browser encounter preview uses the same proportions.
