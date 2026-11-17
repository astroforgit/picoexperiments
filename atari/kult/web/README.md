# Diabolic browser simulator

The browser now loads the currently applied Atari project from the local editor
server, including selected animated sprites, all 8 × 48 waves, native movement
parameters, encounters, capped drop tables and circular pickup icons. It uses the
same simulation and renderer as the flight workshop. The bottom-only HUD uses the
actual native 256 × 32 artwork and digit font, with dotted weapon patterns, lives,
bombs, shields and the skull boss health bar. Equal-sized monochrome stars move
right to left at three speeds. No fuel, planets, buildings or wave minimap.

From the Kult directory:

```sh
python3 editor/start-background.py
```

Open http://127.0.0.1:8772/web/ to start flying immediately. A plain static HTTP
server is no longer sufficient: this version needs `/api/diabolic` and the shared
flight simulation served by the editor. No npm install is needed.

## Controls

- Arrows / WASD: move; the ship fires automatically.
- Ctrl: cycle four weapon patterns.
- Shift: bomb; Space: one-second shield. Three of each at the start.
- P / Escape or Pause: pause/resume. Leaving the window pauses automatically.
- Touch: drag to steer, use the weapon/bomb/shield buttons.
- Select a sector and starting wave, then Restart here to practice.

Each sequence preserves inventory, weapon, score and damage between waves.
Meteors drain offscreen before the next wave begins. Skull bosses drop three
rewards. Normal formations use the current native drop tables (at most two).

## Editor drafts

At http://127.0.0.1:8772/flight/, select a sector and scroll its 48 wave cards.
Choose a card to edit encounter type, enemy slot, movement, HP and drop pattern.
Move earlier/later reorders the whole record and its encounter type; Copy/Paste
replaces a destination wave. Sector lengths stay fixed for Atari compatibility.

Play from selected wave runs to the end of the selected sector inside the editor.
Loop selected wave is for movement tuning. Play draft in browser game saves a
separate local preview snapshot and opens the full browser simulator at the
selected wave. It does not apply changes to Atari files. Save/Open project and
Apply to local game include all edits; applying rebuilds the native XEX.

## Reconstruction limits

This is a JavaScript simulation, not an Atari emulator. Wave movement uses the
translated native motion routine; collision, timing, scoring, weapons and sounds
are approximations. Sector-end guardians retain their recovered original artwork and 100 HP; POKEY
music is not reproduced.
`engine.js`, `space.js` and `assets.json` retain the earlier reconstruction and
archived source data; the active UI uses `flight-core.js` and `renderer.js`.

Checks: `editor/waves-core.test.cjs`, `editor/waves.browser.test.cjs`, plus existing
flight, encounter, shield and bomb tests. Browser tests require Playwright.

## Boss bullet formations

Six attacks use Kult's original sine table (`$7164`): **Sine sweep**, **Cosine
arc**, **Double-sine ribbon**, **Reverse sine sweep**, **Folded arc**, and
**Braided ribbon**. Each bends the curtain horizontally and moves
the opening vertically. Ordinary enemy motion edits do not change these attacks.
Original enemy-18 projectiles keep the larger two animation frames visible.

After a one-time 24-update entrance, six bullets form over 16 updates (following
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

The boss remains fixed at X88/Y48 in native colour-clock/scanline coordinates.
The legacy difficulty value remains compatible with saved projects; its control
is hidden because these measured waves currently use a single speed.

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

Sub-boss appearance now uses the shared 64×64 four-frame boss catalog selected
in the flight editor. Its animation frame follows the native encounter age.
The larger appearance has a conservative full-size contact envelope while
player shots still target its central 64×32 damage area. The end-of-level boss uses the generated Insect Queen. The original dragon is
removed from the catalog and the modified native executable.
