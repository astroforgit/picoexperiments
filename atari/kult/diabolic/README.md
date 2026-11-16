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
selected encounter; click it and use arrows to steer, Ctrl to fire and Space to activate a shield.
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


## Meteor showers and skull sub-boss

The Flight workshop's Encounter selector chooses normal formation, three meteor-shower presets, or skull sub-boss.
All meteor presets now enter from the top only.
The applied sequence begins with normal waves 1–2, meteor showers at waves 3, 5 and 7 and a skull at wave 8.
The same introductory sequence is available in each sector; later waves retain
their original formations unless edited.

Enemy numbers are one-based editor labels: original enemy 15 (rock) and enemy
20 (skull), independent of appearance assignments to ordinary enemy slots.
Meteors resist shots and make no drops. Each lane waits before
spawning a rock at Y=0. At update 192 spawning stops; existing rocks keep
travelling until their top edge passes the bottom of the sky. No visible rock
is removed at the wave deadline. Dodge them.
The skull enters from the right as a 64×32-pixel composite of eight tiles,
bobs vertically, shares one health pool (wave hit points × 8), and fires
four concurrent aimed rockets in bursts: a shot opportunity every three
updates for 40 updates, then a 24-update pause. Global firing Off still disables
its rockets. The skull must be defeated to advance.
The applied wave-8 skull has 64 HP. Defeating it
always releases exactly three packages: weapon-2 upgrade, weapon-3 upgrade,
and a shield. They are spread apart and drift left for collection. Ordinary sprite/explosion buffers are
restored after the encounter. The original end-of-sector guardian is preserved.

Even-numbered ordinary enemy slots (2, 4, …, 32 in the editor) can fire a
left-facing copy of the original player bullet. One such shot uses the spare
PMG player, preserving its eight-row bitmap at hardware pixel width; other
shots and boss rockets retain their large bolt graphics.

The browser preview uses the same tracks and burst cadence, with approximate
native timing. Its health bar is a preview aid; the Atari HUD is unchanged.
Old project JSON files without encounter selections load as ordinary waves.

Implementation references inspected locally (ideas adapted, no imported code):
- `allgames/[ShootEmUp]/Nebula Fighter v1.0.5.p8`: separate fighter, carrier,
  mini-boss and boss definitions; aimed and radial enemy firing routines.
- `allgames/[ShootEmUp]/4 Giga Boss Fights.p8`: boss progression and separate
  boss health/death states. This Atari adaptation uses bounded four-missile
  bursts to fit the hardware, rather than dense radial bullet fields.

Native hooks are in `encounters.asm`; `test_encounters.py` checks meteor weapon immunity, shared boss health, completion, sprite restoration and
packed-export flags, and recovery after player death. `editor/encounters.test.cjs` checks preview behaviour.


Fuel is removed from this edition: no fuel packages, depletion, refills or
empty-fuel death. The fuel icon, gauge and its frame are removed from the lower HUD.
Weapons, score and lives remain. The former bonus area now displays a shield icon and stock count.


Meteor lanes now use mixed speeds of 2, 3, 4, 5, 6 and 7 scanlines per update;
the fastest rocks move over twice as fast as the slowest. The former fuel
gauge now shows remaining boss HP (skull and original sector guardian),
clearing between boss encounters. The top lives icon is a spaceship.

The first rock travels slowly (2 scanlines per update). The next lane waits
32 updates before spawning, giving roughly two seconds of warning.


## Shields and controls

Start with three shields; shield pickups replenish stock to a maximum of three.
Press **Space** to consume one and gain 17 native updates of invulnerability
(about one second at PAL speed), shown by a tight ellipse around the spaceship.
Holding Space consumes only one shield; release and press again after it ends.
The shield protects against enemies, meteors, guardian contact and projectiles.
It causes no damage. Shift activates a bomb from its separate stock. The old fuel and
score-only bonus packages are absent; shield pickups use a shield-shaped sprite.

Native controls: arrows move; shooting is automatic; tap/release Left Ctrl to
cycle available weapons; Space activates a shield; Shift uses a bomb. Editor preview: arrows move,
Ctrl fires, Space activates a shield. Its shield stock and expiry match the game.
`verify-emulator.ps1 -CheckShield` adds a labelled visual diagnostic capture after
normal gameplay, setting only temporary emulator RAM to show the shield ring.

The active shield is a tight 44×20-pixel ellipse around the 40×16 ship,
with a one-pixel outline and approximately one clear pixel at its bounds.
It is drawn in the playfield and restored separately in both framebuffers;
it does not enlarge the ship collision box or leave trails when it expires.

## Imported enemy sheet

The 31 designs in `../enemys.webp` are available in the flight workshop as
**Sheet · …** entries, with four animation frames each. Upward-facing fighters
and rockets face left. This earlier imported set remains available for any
ordinary enemy slot. The current game uses the model redesigns below instead.
Existing wave paths, shooting and rewards are retained. Meteor and skull
encounters use their dedicated redesigns regardless of ordinary slot assignments.

Refresh http://127.0.0.1:8772/flight/ to see the updated catalog. If a previously
saved browser draft still shows the old assignments, save it first if wanted,
then click **Load current game** to load the current Atari project's settings.
Use **Apply to local game** after changing selections and restart the emulator.
Regenerate the imported assets with `python3 diabolic/import_enemies.py` from
the Kult directory, then run `./diabolic/build.sh`.

Enemy drawing and background restoration clip at the bottom of the 128-row
sky. Meteors remain visible until they completely leave the screen, without
writing into the adjacent framebuffer or game code. The regression test runs
the native blitter and restore routine at every bottom-edge position in both
framebuffers and checks that memory outside the screen remains unchanged.

Use `verify-emulator.ps1 -LongRun` for an extended emulator run beyond the
previous crash point; the verifier rejects logged illegal-instruction stops.

## Model redesigns of all originals

The current game now uses the **Redesigned 01–32** catalog, generated using a
reference sheet of all original enemies. The flight editor's **All 32 original
enemies** panel shows original and redesigned animations side by side. Click
either thumbnail to use it in its numbered slot, or **Use all 32 redesigns**
to update all slots in your draft. **Apply to local game** writes your choices.
**Load current game** replaces an older browser draft with the applied settings.
The meteor and skull encounters use redesigns 15 and 20 independently of slots.
See `art/README.md` for the reference, generated sheet, prompt and conversion.

## Single bottom HUD

The top HUD, progress indicator and wave mini-map are removed. One thin-bordered
bottom panel shows the miniature ship with animated exhaust and a dotted preview
of the selected weapon, score, stage, lives, bombs and shields. Bomb and shield
icons share the same row. Boss health uses eight horizontal segments at the
bottom-right, empty outside boss encounters.

Start with three bombs and three shields. **Shift** uses one bomb per press;
holding it does not consume more. Bombs destroy ordinary active enemies, clear
enemy projectiles and deal 16 damage to skulls/guardians. Meteors remain
indestructible. Bombs are a three-use reserve per new game; shield pickups still
replenish shields only. **Space** still provides one second of shield immunity.

`hud_art.py` draws the native 256×32 panel and dotted patterns; `hud.asm` updates
its counters and controls in the memory formerly used by the hidden top panel.
The playfield dimensions and meteor clipping remain unchanged.

Emulator verification uses a temporary profile with background pausing disabled;
the normal runner profile is not modified.

The obsolete progress-bar reset at `$F8DE` is disabled as well as its frame
updates: it used to erase the new bomb routine when a stage initialized.
`test_hud.py` now runs native initialization before activating a bomb, including
actual sound setup and explosion progression. `verify-bombs.ps1` consumes all
three bombs in Altirra, checks the stock sequence and runtime code, and runs
on after the explosions. It simulates the Shift status read in temporary RAM
and restores it; the distributed executable is never patched by the test.

Weapon and shield pickups now use the model-redesigned badges documented in
`art/README.md`. The editor's encounter preview displays the same icons.

### Native boss missile patterns

Boss settings export to `$2D74` (0 rotation, 1 curved fan, 2 weave, 3 slalom)
and `$2D75` (0–2 intensity). Four hardware missiles fire from HeadX/HeadY+16,
with individual ages/phases and eight updates between shots. A muzzle marker
telegraphs the first train. Two four-shot trains fit a 192-update cycle, leaving
time for all projectiles to leave naturally before the next warning. Captured
vertical aim is fixed, not homing. The skull stays at X88/Y48 after entering.

`boss.asm` occupies `$6550..$6683`, after the HUD code and before its bitmap.
The builder checks both bounds. Scratch uses `$2D76..$2D7D` and `$2D7F`;
per-shot ages occupy `$2D80..$2D83`. `test_boss_patterns.py` checks real 6502
execution, mouth origins, dodge routes, stationary-player hits, fixed boss
position, cleanup and code-memory preservation.

### Temporary debug shortcut

During Atari gameplay, press **1** to jump to the first skull sub-boss wave in the
current sector (wave 8 in the default project). Holding the key does not retrigger;
release and press again to restart the fight. Existing enemies, pickups and shots
are cleared, the ship is repositioned, and brief invulnerability protects entry.
Lives, score, weapons, bombs and shield stock are preserved. Edited sectors with
no sub-boss wave are left unchanged.

This temporary hook is isolated in `debug.asm` at `$3F50`, called in place of the
normal wave-loader call at `$F801`; `$2D7E` is its held-key latch. Remove that build
hook/module when debug navigation is no longer wanted. `test_debug.py` covers all
sectors, reordered/missing bosses and release/repress behavior. Emulator diagnostic:
`verify-emulator.ps1 -CheckDebugJump`.
