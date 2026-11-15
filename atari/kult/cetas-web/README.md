# CETAS browser edition

A playable JavaScript adaptation of the supplied `CETAS (WIP).ATR`, alongside
Kult's browser edition. Start the persistent local server from the Kult folder:

```sh
python3 editor/start-background.py
```

Open **http://127.0.0.1:8772/cetas-web/**. Both browser games and the pixel
workshop link to one another. The server survives closure of its launching
terminal; rerun the launcher after rebooting. All game files are static and
can alternatively be served from this directory with Python's HTTP server.

## Playing

Arrows/WASD move; hold Space to fire; X spends a screen-clearing pulse;
P/Escape pauses; Enter starts/resumes/restarts. Touch users drag the playfield
to steer and use the Fire and Pulse buttons. Leaving the tab pauses the game.
Sound is opt-in synthesized effects. Fullscreen depends on browser support.

There is one active player projectile at a time, reflecting CETAS's slot-1
allocation. Start with three lives and three pulses; every 25 defeated objects
restores one pulse. Large opponents take multiple hits. Finish the script and
clear surviving opponents to win. Four script checkpoints allow practice;
restart resets score/lives. Best score is stored locally, separately from Kult.

## What comes from CETAS

`build_assets.py` reuses the existing disk recovery/editor tools to extract:

- All 44 unique sprite records from the original pointer tables, preserving
  their dimensions, bottom-up pixel rows and seven-byte headers.
- The four player frames and position variants for object types 1–18.
- The original resource D title artwork.
- Spawn bytecode from $AA04 through $ABDD: delay changes, counted loops,
  wait-until-clear gates, burst spawning, object records and custom-call IDs.
- Movement tables for types 2, 9, 10, 11, 12, 16, 17 and 18. The JavaScript
  table step retains byte arithmetic, phase resets and bounds checks. Type 18
  uses 25 steps, unlike type 17's 22 steps, even though they share tables.

The movement tests compare 884 successive state transitions against the
original handlers executed using py65, stopping before rendering and skipping
secondary projectile allocation. These checks cover both initial and phase-
wrap cases. Every script checkpoint is tested through the end of the script.

## Adaptations and limits

This is not an Atari emulator or a claim of an exact WIP restoration. Object
updates run at a chosen 25 Hz; rendering and input run at 50 Hz. Player speed,
coordinate clipping, collision rectangle placement, enemy health, aiming,
secondary projectile timing, death effects, score and completion handling are
adapted. The original collision headers inform bounded browser hitboxes; this
is not a verbatim translation of the entire collision routine.

The six-byte spawn records and script order are retained. Delay/loop/wait and
burst commands have browser equivalents; $FA custom 6502 calls are not run.
The $217B call shows a phase banner and $ABDE marks the end. Spawn positions use
seeded browser randomness rather than POKEY RANDOM. Five primary scripted
objects can be active at once, as with slots 12–16; secondary projectiles use
a separate browser list. Missed non-boss objects expire after a bounded time.

Types 13 and 15 use reconstructed aiming/movement. Secondary enemy fire and
player animation selection are adapted. The final large opponent retains its
original graphics and table path with browser health and attacks. Three lives,
emergency pulses and pulse replenishment are browser conveniences. There is
no invented eight-stage campaign: the source is a single WIP spawn script.

The decorative moving stars and blue palette are browser presentation additions.
Original POKEY music, hardware display effects, introduction slideshow, exact
status display and post-game screen are not reproduced. Editor drafts do not
automatically change this game; original ATR/XEX files are never modified.

## Verification

From the Kult directory:

```sh
python3 cetas-web/build_assets.py
node cetas-web/engine.test.cjs
node cetas-web/browser.test.cjs
```

Extraction requires py65. Browser tests require Playwright and the running local
server; use `PLAYWRIGHT_MODULE`, `CHROMIUM_PATH` and `GAME_URL` as needed.
Tests cover source-CPU movement comparisons, sprite coverage, one-shot limit,
pulse latching, damage/invulnerability, pause, every script checkpoint through
completion, keyboard/touch controls, score persistence, sound and narrow layout.
