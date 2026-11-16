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

## Boss attacks

Skull bosses and sector guardians emit staggered, curved bullet trains from their
front/mouth. The editor selects curved fans, weaving streams, slower slaloms or a
rotating sequence. A muzzle warning precedes each cycle. Shots use captured aim,
then follow independent trajectories; they never home on the player. Up to four
shots are active, with pauses between trains. The editor can show projected paths
for practice; no fixed safe corridor is drawn.
