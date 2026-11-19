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


## Meteor showers and animated sub-boss

The Flight workshop's Encounter selector chooses normal formation, four meteor-shower presets, or animated sub-boss.
Meteor sections enter from above, below, the right, or alternating top/bottom lanes.
The applied sequence begins with normal waves 1–2, meteor showers at waves 3, 5 and 7 and a sub-boss at wave 8, and alternating top/bottom meteors at wave 11.
The same introductory sequence is available in each sector; later waves retain
their original formations unless edited.

Enemy numbers are one-based editor labels: original enemy 15 (rock) and enemy
20 (skull), independent of appearance assignments to ordinary enemy slots.
Meteors resist shots and make no drops. Each lane waits before
spawning a rock at its entry edge. At update 192 spawning stops; existing rocks keep
travelling to the opposite edge. No visible rock
is removed at the wave deadline. Dodge them.
The sub-boss stays at the right and uses a selectable 64×64 four-frame tile
resource, with a central 64×32 damage area and one health pool (wave hit points × 8). It fires
the full-height curtains described below. Global firing Off disables its attacks.
The sub-boss must be defeated to advance.
The applied wave-8 sub-boss has 64 HP. Defeating it
always releases exactly three packages: weapon-2 upgrade, weapon-3 upgrade,
and a shield. They are spread apart and drift left for collection. Ordinary sprite/explosion buffers are
restored after the encounter. The end-of-sector guardian now uses generated Insect Queen artwork.

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
sky. Meteor sprites are clipped at the lower edge without
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

### Native sub-boss bullet formations

Six attacks use Kult's original sine table (`$7164`): **Sine sweep**, **Cosine
arc**, **Double-sine ribbon**, **Reverse sine sweep**, **Folded arc**, and
**Braided ribbon**. Each bends the curtain horizontally and moves
the opening vertically. Ordinary enemy motion edits do not change these attacks.
Original enemy-18 projectiles keep the larger two animation frames visible.

In the standalone nine-wave lab, a one-time 24-step entrance precedes the
formation primitive: six bullets form over 16 steps (following
a two-update charge), then rush left at a nominal 24 pixels/update, four times
the ship's 6 pixels/update. Trigonometric offsets slightly vary individual speed.
A new wave begins every 30 updates. Its formation overlaps the older wave's two
trailing guards. The guards are normally 16 updates behind; calibrated mixed-pattern
transitions release them one update earlier to preserve its reaction margin.
Each projectile stores its own lane and pattern so a new wave cannot alter an
older guard's path. Slots can be reused only after the previous shot exits.

The opening alternates between upper and lower positions. With a 40×16-pixel
ship and 16×16 bullets, the evaluated curtains block approximately 87–89% of
legal ship heights at X=24 pixels. The trigonometric gap width varies slightly.
No stationary height survives the sequence at the tested flight columns.
Bombs clear both generations and give a fresh entrance delay.

The isolated primitive uses an emitter at X88/Y48 in native colour-clock/scanline coordinates.
In the live four-wave attack the boss has already left the screen, and each
formation step takes two game updates while the pilot moves every update.
The legacy difficulty value remains compatible with saved projects; its control
is hidden because these measured waves currently use a single speed.

`boss.asm` remains at `$6550..$6683`. `boss-sprites.asm` uses retired terrain-map
memory at `$1800..$1B7F`; state is at `$1B80..$1BFF`, two background stores at
`$1C00..$1FFF`, and aligned original-enemy-18 frames at `$2000..$22FF`.
The original terrain decoder is disabled. Sprites restore in reverse draw order
and clip at the bottom edge. Packaging replays the original loader and checks
the entire new bank. `test_boss_sprites.py` checks both buffers, overlaps, clipping,
full-field movement and stationary boss coordinates.

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

### Boss wave test environment

Open http://127.0.0.1:8772/boss-lab/ (also linked from the flight workshop).
It displays native projectile traces, hitboxes, X/Y plots, a time scrubber,
verified escape routes and manual arrow-key dodging. Playback speed is adjustable;
wall-clock update rate depends on Atari rendering load.

Regenerate after building or applying edited paths:

```sh
python3 diabolic/boss_lab.py
```

The lab decodes the **built XEX**, measures joystick transitions from `$E95B`,
and records the actual `$6550` boss routine across three changing openings. A two-dimensional reachability search
allows a three-update reaction delay initially and at every opening transition,
with an extra two-pixel collision margin.
126 starting cases cover all six patterns and the rotating sequence. Each chosen route is
replayed through native joystick and collision code for nine waves, with no
invulnerability, shields or bombs. This establishes a route for those cases,
not a guarantee for arbitrary player movement. The native bullet collision uses
the complete 40×16 ship and 16×16 projectile bounding boxes, including transparent
corners. `test_boss_lab.py` checks the boundary comparisons against 6502 execution.

`editor/boss-lab.test.cjs` compares every native projectile position against the
browser simulation. The lab checks the XEX hash and marks traces stale after a
new export. `editor/boss-lab.browser.test.cjs` exercises the visual controls.

The acceptance test rejects a sequence without an escape route, with an idle
camping position, with less than 85% peak danger, or with an opening transition
that leaves less than three or more than four reaction updates after movement.
Measured transitions allow 12–13 updates in total; the minimum repositioning
takes 9–10. The lab reports contiguous safe bands and danger percentage for
every update, plus each transition's movement and reaction budgets. Seconds
remain conditional on the selected playback rate. `boss_lab.py` reads the built
XEX; exported traces are shared by pattern to keep the JSON artifact small.

Formation parameters and guard timings live in `editor/boss-formations.json`.
The native builder generates `boss-formations.js` and packs the same parameters
into Atari RAM, so preview/export settings share one definition. Presets 1–3
remain compatible; presets 4–6 are available in the editor and native exports.

Additional regression coverage includes every rotation entry with both opening
directions, a 24-wave continuous run, bomb resets in formation and rush phases,
invalid settings, and loader round-trips for the new presets. Negative controls
reject closed walls, empty/easy waves, excessive preparation time, and a ship
unable to move vertically. Browser tests replay every native winning joystick
route and check all 64 collision-boundary cases. The editor tests exercise all
six previews, preset persistence and browser-game handoff.

Meteor sections offer top-down (1), bottom-up (2), right-to-left (3), and alternating top/bottom (6). The mixed section uses separate columns, never crossing horizontal and vertical streams. Each lane owns one meteor; no lane can respawn until its previous meteor exits. The first meteor remains slow, spawning stops after 192 updates, and active meteors drain naturally. The default sequence adds the mixed section at wave 11. Native/browser position parity and pairwise lane separation are covered by `test_encounters.py` and `editor/meteors.test.cjs`.

The native/browser parity test requires Node.js 22 or later on PATH alongside Python (`python3 -m unittest discover -s diabolic -p test_encounters.py`).

Temporary Atari debug keys: **1** jumps to the first sub-boss in the current sector, **2** to top-down meteors, **3** to bottom-up meteors, **4** to right-to-left meteors, and **5** to alternating top/bottom meteors. Holding a key does not repeatedly restart the wave. If that encounter type is absent from the sector, the current wave continues.

**6** jumps to the mixed meteor/enemy test wave (encounter type 7). Two indestructible rocks and six shootable enemies enter from the right, staggered in separate horizontal lanes. The first rock is slower; every actor crosses once. Bombs destroy enemies but leave rocks intact. The selected enemy slot supplies two animation frames; the original explosion frames are preserved. The Queen remains the end-of-level boss. The mixed controller occupies `$2420..$24FF`; `$2400..$241F` must remain the blank scrolling terrain tile. Waiting mixed-wave actors are hidden until their scheduled entry.

## Selectable 64×64 sub-boss artwork

The flight editor's **Sub-boss appearance** section offers the Bone Dragon (default), Iron Manta, Void Kraken, and Insect Queen. Every selection
has four 64×64 monochrome frames. Save/export retains `boss.design`; older
projects automatically select Bone Dragon. Apply to local game and restart,
then press **1** to preview. **6** loads the mixed meteor/enemy wave.

During firing, the sub-boss stays at X=88 colour clocks and bobs vertically.
It uses the original guardian tile drawing/erasing routines, with its own tile
bank and frame maps. The central 64×32 damage area, health, rewards and six
attack patterns are retained. The browser/safety search uses the full 64×64
rectangle as a conservative contact envelope; native contact is pixel-based.

Retired terrain-map storage now contains `boss-art.asm` at $0480, selected tile
frames at $0800..$0FFF, and four 4×4 tile maps at $1000..$103F. The end-of-level Insect Queen has its own deduplicated tile bank at $1040 and
frame maps at $1740; the old dragon tiles/maps are cleared from the executable. The tile hook saves/restores the guardian's render
state. The loader keeps this bank literal to prevent in-place decompression
from overwriting unread input; every export replays the original loader.

Boss-route validation now reserves the full 64×64 artwork. Starts beside the
boss (X > 136 pixels) react after three updates and may retreat during warm-up;
normal flight starts retain the 27-update initial wait. Later transitions keep
the same three-update reaction delay. The lab displays this initial wait.


## Shared boss actions

Both the sub-boss (debug **1**) and Insect Queen (**6**) now enter from the right,
choose straight or sinusoidal fire for 96 updates, then retreat to launch either
four curtain waves or a meteor section. Entry and retreat each take 20 updates
(about 1.2 seconds at 17 updates/second), with the body drawn until it crosses
the right edge. They return only after every remaining
hazard has left the playfield. The next firing style and hazard are chosen by a
small random generator.

Straight fire follows the original guardian routine: six slots, the first free
slot considered once per update, a 1-in-4 firing chance, and four colour clocks
of leftward movement immediately on spawning. The 16-step animation and muzzle
height tables ($FCCA/$FCDA/$FCEA) advance every update, so shots come from the
original changing heights instead of a fixed body offset. Rounded hollow orbs
replace the original projectile art. Sine fire uses the same launch sequence
and horizontal speed, with three slots and a 1-in-8 chance; its vertical sine
motion is retained. Meteors use one of the existing top, bottom,
right, or separated alternating top/bottom lane layouts. Their first meteor is
slow; spawning ends after 192 updates without deleting surviving rocks. Bosses
can be damaged only during the two firing actions. Bombs clear projectiles but
do not destroy meteors.

The flight editor's boss preview and browser game run the same controller.
**Preview four-wave attack** starts the actual paced off-screen attack directly.
The separate nine-wave lab remains an explicitly labeled primitive inspection.
`test_boss_actions.py` compares 6,400 native CPU updates with browser state and
projectile coordinates, and searches for a continuous escape route using the
player's actual movement steps and collision bounds. This proves route existence
for the tested seeds, not that every player reaction or random sequence succeeds.

The controller occupies the retired dragon bank at $DAC0..$DEFF; helpers use
$0300..$047F. State is at $2DC0, with meteor lane waits at $2DE0. Rounded orb and
meteor graphics use $0680..$07FF. Both tile drawing and erasing clip at the right
edge during entry/retreat. `verify-emulator.ps1 -CheckBossActions -DebugKey 1`
(or `6`) captures and checks all four actions in Altirra.

## Boss rendering performance

The sub-boss collision actors remain active for damage tests, but their eight
invisible sprites no longer perform bitmap drawing/background backups. The
obsolete building-buffer scroll and copying pause during either boss fight;
PM parallax stars continue normally. Full-width boss erasure and the tile/bullet
copy loops use faster paths, with partial-edge clipping retained. Blank body
tiles are skipped. A separate cache for each framebuffer keeps unchanged boss
pixels; animation, movement, disappearance, death, and boss type invalidate it.
The cache helper occupies $1780..$17FF and its state uses $2DD2..$2DDB.

In the rendering-optimization checkpoint (`ca802161`), the PAL Altirra runner’s
continuous six-orb firing test
completed 32 updates before and 68 after in 8 × 1,048,576 emulated cycles:
approximately **6.8 → 14.4 game updates/second**. This is a targeted firing test,
not a claim of constant frame rate across every encounter. The native CPU test
for drawing/restoring the body, hit targets and six orbs fell from 95,352 to
42,545 cycles (55% less). Reusing an unchanged body costs under 500 cycles.

`test_boss_performance.py` protects those budgets, collision state, ordinary
actors/rewards, cache invalidation, scrolling resumption and loader coverage.
`verify-emulator.ps1 -CheckBossPerformance -PerformanceContinuous -DebugKey 1`
repeats the live timing test. Omit `-PerformanceContinuous` to restart the
six-orb burst in each measurement window; `-GamePath` accepts a baseline XEX.
The diagnostic wrapper only modifies emulator RAM, not the distributed game.


Boss death/respawn regression: the terrain hold releases while `$F398` marks
player death. Kult's original respawn waits for scroll phase 2, so freezing that
counter could leave the ship invisible forever after a meteor collision. The
body caches invalidate during death as well. `test_boss_respawn.py` covers all
four scroll phases for both bosses. `verify-emulator.ps1 -CheckBossMeteorDeath`
forces a real right-to-left meteor collision and waits through the original
particle effect to check that one life is spent and gameplay resumes with the
same boss health. A live sub-boss now holds its wave during player respawn,
including phase zero; only a deliberate debug-key jump bypasses that hold.

The software projectile renderer clips partially visible rocks at the right
edge before drawing or saving their backgrounds. Each framebuffer record keeps
both width and height, so erasure restores exactly the drawn rectangle. This
prevents edge pixels spilling into the next scanline or framebuffer at the
maximum scroll offset. Full-width sprites retain the unrolled fast path.
`test_boss_sprites.py` checks both buffers and all four horizontal alignments;
the edge regression fails against the previous renderer.


The live off-screen curtain sequence has an 18-game-update lead-in, then four
births at updates 18, 78, 138 and 198. Bullets move every other game update,
including while the last guards drain. Their nominal average rush is 12 pixels
per game update (twice the pilot speed), restoring reaction time independently
of rendering performance. Collision checks still run on the intervening updates.

`editor/boss-wave-safety.test.cjs` and its Playwright browser counterpart test
126 live sequences: all six formations plus rotation, both first-gap directions,
three flight columns and three starting heights. The pilot waits until the
opening starts to unfold, then another six game updates before reacting (about
0.35 seconds at 17 updates/sec). Routes retain two-pixel clearance and replay
through actual Encounter input/collision handling without hits or consumables.
These are tested escape routes, not a guarantee that arbitrary movement is safe.
`test_boss_actions.py` also compares primary firing directly against execution
of the original guardian routine, checks reduced sine-shot density and confirms
native/browser state and projectile parity through full fights.


Incoming sprite visibility: meteor lane reservations for every direction remain
hidden until their progress is below 128. Ordinary formations reset their
position-ready flag when loaded and set it on their first movement update;
this prevents new graphics flashing at the previous wave's coordinates.
`test_entry_visibility.py` covers both framebuffers and all four scroll phases,
while preserving active sprites, explosions and rewards. The Altirra check
`verify-emulator.ps1 -CheckPendingSprites -DebugKey 3` holds pending actors across
real scroll/render cycles and checks that neither buffer saves their pixels.
Pass `-GamePath` to capture a pre-fix executable for comparison (the no-draw
assertion is intentionally disabled for that baseline).


Clock pickups add a slow-motion charge, up to three. Press Z, X or C to spend
one charge: enemies, rocks and hostile projectiles move at
one-third speed for three seconds. Ship movement, firing and player projectiles stay at full speed. The bottom HUD
shows the clock icon and remaining charges alongside bombs and shields. New
games start with three charges; holding a key never spends another charge.
Clock gifts occur in 24 of the 32 ordinary-wave drop patterns, versus four bomb
patterns, with at most two gifts per ordinary wave.

The timer uses 150 PAL display frames, independently of game-update frequency,
and pauses with the game. Death cancels an active effect. Collision checks for
stationary hostile projectiles remain active. Browser gameplay and the wave
editor use the same controls, inventory and movement on every third update.
`test_clock.py` checks native pacing, collisions, duration, pickups and loader
integrity; `editor/clock.browser.test.cjs` checks browser movement and keyboard
controls. `verify-emulator.ps1 -CheckClock` verifies activation, HUD and expiry
in Altirra. Clock code occupies $2E00-$2EFF; its HUD/pacing helper occupies
$2F88-$2FFF and state uses $2D90-$2D99. Invisible boss collision targets now
reuse the blank tile at $2400 instead of the reclaimed clock-code bank.


Round boss shots (straight and sine) now collide using their inner core against
the ship's central body, rather than both full sprite rectangles. This leaves
transparent padding and grazing the wings harmless. In native half-width X
coordinates, the ship core is [6,16) x [4,12) and the orb core is
[2,6) x [4,12); touching edges alone does not count as a hit. The browser uses
the same bounds. Meteor and curtain collision bounds are unchanged.
`test_boss_sprites.py` exhaustively checks relative offsets and protections.


Sub-bosses now start with four times the wave HP setting (half the previous
eight-times multiplier). They retreat off-screen only once per encounter for
one curtain sequence or meteor shower. After returning they stay on-screen
and select straight or sine shots every 96 updates. The used retreat survives
pilot death and resets when a new encounter loads. End-of-level boss health
and repeated retreats are unchanged.
