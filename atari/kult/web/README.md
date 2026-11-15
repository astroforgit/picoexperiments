# Kult browser edition — Diabolic space variant

A playable, local JavaScript adaptation of the supplied Atari Kult game.

The current browser variant replaces the helicopter with the **Diabolic**, a
swept-wing spacecraft with claw-like tips, a glowing cockpit and animated
engines. A seeded layered starfield, slowly moving nebulae and a shaded planet
replace the building terrain. Depth-dependent star speeds and steering parallax
create a perspective effect. There is no terrain collision in this variant.
Enemy waves, weapons, pickups and stage progression remain.

`space.js` contains the new canvas artwork. Original helicopter and map data
remain archived in `assets.json`; the browser no longer draws them. The Atari
XEX and the pixel editor are unchanged.
Start the persistent local server from the Kult directory:

```sh
python3 editor/start-background.py
```

Then open **http://127.0.0.1:8772/web/**. The server runs independently of the
launching terminal. Run the command again after rebooting; an already-running
server is reused. Logs and its PID are saved under `editor/.runtime/`.
Alternatively, `editor/run.sh` runs in the foreground until its terminal closes.
The pixel workshop also links to it through **Play Kult**.

Alternatively serve this directory with `python3 -m http.server 8773 --bind
127.0.0.1` and open http://127.0.0.1:8773. The workshop backlink then needs the
editor's separate address. No npm install, external CDN or runtime Python
asset decoding is required: `assets.json` is committed-ready static data.

## Controls

- Arrow keys or WASD: move. Space: fire. X: screen-clearing pulse.
- P/Escape: pause/resume. Enter: start, resume or play again.
- Touch: drag the playfield to steer; hold Fire and tap Pulse.
- Choose any of eight starting sectors before starting/restarting.
- Sound toggle enables synthesized effects after interaction; fullscreen is
  available in supporting browsers. Leaving the tab automatically pauses.

Three ships and three pulses start each flight. Weapons have three spread
levels, with a maximum of six player shots on screen. Every twelfth defeated
enemy drops a pickup; weapon, pulse and extra-ship drops cycle. A guardian ends
each sector. Clearing all eight sectors wins. High score persists locally;
progress within a flight does not. Restart immediately begins a fresh flight.

## Original data and reconstruction limits

`build_assets.py` uses the existing recovery tools against `Kult (v1).xex`.
It executes Kult's own map decoder at $0300 for each stream in $C217, expands
section sequences at $4B00 using the map pointer formula from $E920, and reads:

- Four player frames and all 32 enemy designs × four frames, plus effects.
- 256 background tiles and eight stage maps (512 columns × eight rows).
- All 384 wave records, in original stage order.
- The sine lookup at $7164 and all 32 motion records at $7310.
- Guardian composition at $FED2 and tiles at $DAC0 (one-based map indices).

`motionPoints` translates $E7A4–$E7F8, preserving byte wrapping and all eight
slot positions. Tests compare 80 successive updates for every referenced
motion against execution of the original 6502 routine (2,560 samples).

This is **not a cycle-accurate port or Atari emulator**. Gameplay scheduling,
entry/exit offsets, coordinate scaling, scrolling speed, enemy health, weapon
spread, collision cores, pickups, score, lives, guardian attacks and stage
completion rules are reconstructed/adapted. Formation/state and delay fields
are retained in the extracted wave records but not interpreted as original
behaviour. Each wave launches eight enemies. Waves expire after a bounded
time so the player can progress after missing enemies. Stage progression is
tied to 48 waves and a guardian, not the original map-end counter. The guardian
uses the original initial composition, without all original transformations.

Colours are an illustrative four-colour palette. Sound effects are Web Audio
synthesis; original POKEY music, interrupt/display-list effects and menus are
not reproduced. Editor drafts are not automatically applied to the browser
version. Original XEX/ATR files remain unchanged.

The original scenery remains recoverable with `build_assets.py`. Regenerating
assets does not replace the browser ship or space artwork.

## Development and checks

```sh
python3 web/build_assets.py
node web/engine.test.cjs
node web/browser.test.cjs
```

Run from the parent Kult directory. Extraction requires `py65`, as does the
existing decompiler. Browser testing requires Playwright and the editor server;
set `PLAYWRIGHT_MODULE`, `CHROMIUM_PATH` or `GAME_URL` if needed. The native
engine uses a fixed 50 Hz simulation, independent of rendering frame rate.

Tests cover CPU motion equivalence, map/wave coverage, shooting, pickups,
invulnerability, pause, all stage transitions, victory/restart, keyboard and
touch input, sound activation, local score persistence and narrow layout.
