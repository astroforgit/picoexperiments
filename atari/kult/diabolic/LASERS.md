# Laser razor wave

Press **8** during flight to jump to laser razors. This is also wave 21 of
all eight sectors, and a selectable encounter in the browser wave editor.

Each pattern draws thin, continuous warning beams for 50 PAL display frames
(1.0 seconds), followed by solid, four-scanline lethal beams with pulsing edges for 25 frames
(0.5 seconds). The opening patterns squeeze the safe area gradually. Later
patterns move one narrow safe corridor up and down. Move vertically into the
gap before the warning turns solid; staying still cannot survive all patterns.
Horizontal, parallel diagonal and crossed beams are interleaved throughout
the wave after the opening patterns.
After 15 patterns normal level progression resumes.

Warnings never hurt. Shields and respawn protection work normally. Death
restarts the current warning, rather than respawning into an already live beam.
The warning clock uses display frames, so ordinary game update rate and the
clock pickup do not shorten its 1.0-second warning.

The game cycles through **Long zigzag**, **Diagonal switchbacks**, and
**Crossed detour** on successive laser encounters/debug jumps. Each route has
at least seven transitions whose safe areas are separated by 24–40 scanlines
at the normal flight position. The one-second warning requires prompt movement into the next gap. The route stays intact after death.

Sub-boss moving walls cycle through twelve variations: six possible starting
formations, each beginning with either the lower or upper opening. Each fight
still uses four walls and then drains its projectiles before the boss returns.
The six individual formation choices in the editor continue to pin a formation;
the default rotation uses all twelve sequences across encounters.

The editor has preview selectors for each laser route and wall sequence.
These are preview controls; the Atari game automatically cycles through them.
Laser pattern data is shared through `editor/laser-patterns.json`.

## Verification

`PYTHONPATH=diabolic python3 -m unittest test_lasers`

The native 6502 movement/collision tests search all 57 reachable starting
heights at 16.7, 12.5 and 10 game updates per second. They impose a two-update
reaction delay on each new warning and leave a one-scanline clearance margin.
All 513 routes across three sequence options must survive without consumables; no stationary route may
survive. Separate tests cover exact collision boundaries, invulnerability,
pause, death reset, both framebuffers, changing scroll offsets, real player
background restoration across all 45 patterns, and HUD preservation.
The test writes `/tmp/kult-laser-safety.json`; replay it in Chromium with
`node editor/lasers.browser.test.cjs` while the editor server is running.
`PYTHONPATH=diabolic python3 -m unittest test_wall_variants` verifies all
12 wall sequences, with 36 complete native escape replays from upper, middle,
and lower starting positions. It requires three updates of reaction time.
`node editor/wall-variants.browser.test.cjs` replays the same routes in Chromium
and checks every preview choice in the editor. `test_boss_actions` also checks
complete boss behaviour against the browser, including the variation selector.

These are simulated routes, not a claim that every human player will pass.

`verify-emulator.ps1 -CheckDebugJump -DebugKey 8` checks startup and the shortcut
in Altirra and saves an in-game screenshot.

## Native format

Project encounter kind 9 uses bit 7 of the enemy-design byte; the packed motion
kind remains zero. The loader masks off that flag before resolving sprite data
and selects runtime mode 8. This preserves every existing encounter kind.
`lasers.asm` occupies retired title music data at $DF00–$E2FF. The title VBI's
music call is disabled before those bytes can be interpreted; the separate
gameplay sound-effects driver remains in use. Laser state is $2DE8–$2DEF and $2DF1–$2DFC, with the current sequence end at $2DDD.
The original framebuffer origins are saved at $2DF9/$2DFA and $2DDE/$2DDF,
so erasure remains correct when death or respawn changes the scroll pointers.
The retired terrain-copy pass is skipped during laser encounters.
The wall-sequence counter is $2DDC.

Enemy distance-gated firing uses $E300–$E45F and $2DFD–$2DFF. Enemies
can fire throughout their wave, requiring at least 52 horizontal units between
muzzle and ship. Default bullet speed is 6, between the previous slow (4) and
fast (8) settings. Each enemy wave uses a single bright bullet style and aims
at the ship's position when fired. Key 6 tests the mixed meteor/enemy wave.
The enemy-shot speed does not alter boss projectile speed.

`test_approach` also checks 456 single-shot dodge scenarios at the minimum
firing distance, using native ship movement with a two-update reaction delay.
These include horizontal and diagonal escapes near the screen edges.
