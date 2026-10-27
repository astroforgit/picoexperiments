# Curse of the Lich King for Atari VBXE

This is an Atari XL/XE + VBXE port of *Curse of the Lich King* (v1.2) by Johan Peitz, with
audio by Gruber. The source is the PICO-8 cartridge `[RPG]/Curse of the Lich King.p8.png`.

The whole game is ported: the title screen, the procedurally generated floors 1 to 8,
monsters and their AI, fog of war, props, items, the backpack, the altar, anvil and well,
the floor 8 boss, death and victory. POKEY plays the sound effects. The music is not
played (see *Sound*).

It needs an Atari XL/XE (64K) with a VBXE FX core at `$D600` or `$D700`.

## Build and run

```sh
./build.sh                    # MADS -> lich.xex
./build.sh --regenerate-data  # also re-decode the cartridge and rebuild data/ and gen/
./run.sh                      # build, then start in the persistent Altirra VBXE profile
```

## Editor

`editor/index.html` is a web editor for the game data. Open it in a browser; it works offline
from the file system. It edits a game description (`game.json`):

- **Rules:** every generator and game parameter (room counts and sizes, room types per floor,
  trap, pot, door, curse, bless and enchant chances, level-up gains, the boss floor...), the
  monster budget, mimics and treasure rooms per floor, and the experience table.
- **Monsters:** all entity types, with animated previews and editable stats, sprites and
  abilities. Below them are the monsters of other games (Porklike, BulbaRogue, Crocolike,
  The Demon Within, or any `.p8` loaded with "Load a .p8 cart"), with their stats and
  animations. "Add to game" copies a monster's 4 frames to the second sprite page and adds it
  as a new monster; its special mechanics become abilities.
- **Items:** names, sprites, attack, healing, the floor they appear from, and where they are
  found. Items can be added.
- **Floors & maps:** hand-made 128×32 maps (paint ground, walls, the start, stairs, props and
  monsters) and which floors use them instead of the generator. Maps of other games can be
  selected on their own map and converted, tile by tile (walls by sprite flag, single tiles
  overridable: stairs, start, spikes, doors...).
- **Sprites, Furniture, Texts:** both sprite pages with a pixel editor and the sprite flags, the
  3×3 furniture pieces of the rooms, and every text of the game (checked against the font).
- **Export:** checks the data and downloads `game.json`.

Put the exported file into `data/game.json`, run `python3 tools/make_data.py`, then
`./build.sh`. The bundled game uses the Diabolic Crypt environment style; gameplay
rules, sprite flags, entity types and furniture placement remain unchanged.

### Dungeon artwork

The **Sprites** tab offers **Use Diabolic Crypt**, **Use The Demon Within**, **Use Crocolike Dungeon**,
**Use Verdigris Crypt**, and **Use original artwork**.

Diabolic Crypt starts from the original Lich King walls, stairs and furniture.
Charcoal masonry, charred brown oak, a blood-red altar, a horned idol and engraved
tombs give revision 2 a darker look. The previous subtle revision remains selectable.
Guest monster sprites and all gameplay data are preserved.

The Demon Within style imports its actual wall tiles and stairs (source 14/15)
from `allgames/[RPG]/The Demon Within (v1.0.0b).p8`. It restores Lich King's original
furniture shapes. Selected stone, metal, ceramic and cloth colors become charcoal
and cyan; all 21 wooden tile variants, including tables, chairs, doors, chests and
shelves, remain pixel-identical to the original Lich cartridge. Floor wall shadows
match the imported masonry. Mappings and preserved wood IDs are recorded in
`editor/demon-art.js`. Crocolike Dungeon imports the actual wall pixels
and stairs from `allgames/[RPG]/Crocolike.p8`: 16 wall variants are selected using
Crocolike's wall signature table, and source tiles 14/15 become the exit/start.
Source floors, doors, chests and pottery are also used. The furniture is adapted
to its rust/plum masonry and emerald/lime props. Tile mappings and the source
cartridge hash are recorded in `editor/crocolike-art.js`.

Saved sessions upgrade once to the current art revision while preserving custom
pixel edits. Selecting any of the six styles persists across reloads.

The earlier Verdigris Crypt style redraws 82 environment tiles: the 16 connected wall shapes, floor
patterns, stairs, doors, pottery, chests, shelves, furniture, shrine, anvil, well
and their spent/broken states. Slate, moss green, oak, brass and cyan accents use
the existing PICO-8/VBXE palette. Heroes, enemies, weapons and HUD are preserved.

The Verdigris artwork was drawn for this game after inspecting the local Porklike,
Crocolike, BulbaRogue and The Demon Within sprite sheets; reference sprites were
not copied. Existing saved sessions receive the new art only on tiles that still
match the original artwork. Hand-edited tiles and game settings are retained.
Use **Apply edits & restart** in Play to refresh an already-running game snapshot.

The tile definitions and reversible art packs can be regenerated with:

```sh
python3 tools/make_crypt_art.py       # regenerate the Verdigris pack
python3 tools/make_crocolike_art.py   # regenerate the Crocolike pack
python3 tools/make_demon_art.py       # select Demon walls + original furniture
python3 tools/make_diabolic_art.py    # select subtly diabolic original artwork
python3 tools/make_editor_assets.py
python3 tools/make_data.py
./build.sh
```

`make_crypt_art.py`, `make_crocolike_art.py` `make_demon_art.py` and `make_diabolic_art.py` deliberately replace the environment
tile set in `data/game.json`; edit their definitions to change the bundled style. The pre-artwork
checkpoint is commit `01484800`.

### Additive monster bestiary

The **Monsters** tab lists 25 enemies from weakest to strongest using an estimated
power score (HP + 5 × attack + range and ability weights). Sorting never changes
entity IDs. Editable HP, attack and first floor update the ranking. **Use in game**
controls spawning in procedural floors, custom maps, pot surprises and summons;
apply edits and restart Play after changing the roster. Raq'zul remains required
for the final encounter. Encounters can still explicitly simulate disabled types.

All ten original Lich enemies retain their original sprites and stats. Ten imported
creatures are independent additions with Lich-scale stats and staged floor access:
marsh/carrion slimes, fallen mage, lesser demon, thornling, berserker, bone dancer,
scorpion, night haunter and dread reaper. Imported creatures never carry the boss
victory ability. Five original animated fantasy designs add an ash bat, grave goblin,
bone hound, blood knight and ember drake. These use 60 separate animation tiles on
sprite page 2. The resulting 40 entity types fill the Atari type limit; advanced
library imports require removing an added type first.

Existing saved sessions migrate recognized guest replacements back to the original
pixels, then add the independent creatures without changing edited original stats.
Custom-painted sprites and occupied animation slots are kept. If a custom roster
has insufficient capacity, a warning reports additions that could not fit.

The catalog is generated by `tools/make_bestiary.py` and stored in
`editor/bestiary-pack.js`. This supersedes the older sprite-replacement workflow.
To regenerate the current build:

```sh
python3 tools/make_bestiary.py
python3 tools/make_editor_assets.py
python3 tools/make_data.py
./build.sh
node --test editor/play-engine.test.cjs editor/encounter.test.cjs
```

### Level inspector, balance and encounters

The editor opens on **Level inspector**. Select a floor to see its saved map or a
seeded design layout. Enemy outlines and the roster show positions, counts, HP,
attack and abilities. Select enemies on the map or with coordinate buttons, then
choose **Simulate selected**. Save a design as a custom floor before painting
placements; it is assigned to that floor and included in the existing JSON export.
The full map editor remains available for terrain, starts, stairs and props.

**Balance** compares eligible enemy types and budgets across floors. HP, attack,
first floor and budgets can be edited directly. Hero level and weapon controls
provide baseline hits-to-kill and HP-loss comparisons.

**Encounters** supports custom enemy groups, sequential fights, deterministic seeds,
up to 1,000 trial seeds, a turn slider, HP replay and combat log. It uses the game's
fixed damage, weapon bonuses, XP thresholds and level-up gains. Poison, paralysis,
stun, slow, vampire, weapon theft and boss melee healing are modeled. Changes to
inputs invalidate earlier results.

The level inspector now uses the same JavaScript generator as Play, including room
drift, furniture, loot, traps and special rooms. **Play this floor** starts the
selected floor with the same seed. Browser RNG replaces Atari POKEY entropy, so it
does not reproduce an Atari seed byte for byte. Save a generated layout as a custom
floor to export its exact starting placements.

The separate **Encounters** tab remains an adjacent-combat estimate. It excludes
movement, range, consumables, enchantments and post-combat poison; unsupported
abilities are listed. Use **Play** to test the full spatial behavior.

Run the planning model's regression tests with Node.js 18 or newer:

```sh
node --test editor/encounter.test.cjs
```

### Playable JavaScript port

Open **▶ Play** in the offline editor and press **Embark**. It runs a snapshot of
current editor data. **Apply edits & restart** takes a fresh snapshot; a running
session is retained when visiting other editor tabs. The **Live artwork** pane beside
the game applies walls, stairs and individual object categories immediately, without
restarting or changing position, health, inventory or enemy state. Pick a category,
then click a style thumbnail; categories can use different styles. These choices
are saved to the editor and exported with the game. Open/broken object states and
all wall connections are updated together. Reloading the page ends the
play session, while editor data still uses its existing local save.

- Arrow keys / WASD: move, bump enemies to attack, bump props to interact.
- X / Enter / Space: backpack and select; C / Escape: close. Backpack arrows select.
- P: pause / resume. On-screen buttons also work on touch screens.
- Period: wait one turn (an editor convenience). Paralysis advances automatically.
- Seed, starting floor and hero level provide repeatable test runs. Normal play
  starts on floor 1 at level 1. Fullscreen and optional sound are available.

The pure engine in `editor/play-engine.js` follows `src/level.asm`, `src/entity.asm`,
`src/items.asm`, `src/game.asm` and the reference cartridge. It implements procedural
and custom floors, auto-tiling, fog and line of sight, awareness/chase/flee AI, all
19 ability flags, combat and status effects, inventory and enchantments, shrines,
traps, XP, floor transitions, death and victory. The inspector and Play share the
generator. **Save starting layout as custom floor** captures the initial floor,
not the already-consumed loot and defeated enemies.

Sprites, sprite flags, stats, items, rules and game texts come from the editor
snapshot. The cartridge font, title map and sound notes are generated with:

```sh
python3 tools/make_play_assets.py
node --test editor/play-engine.test.cjs editor/encounter.test.cjs
```

This is a source-based JavaScript port, not a 6502/VBXE emulator. RNG, animation,
camera interpolation, dialog timing and browser sound timbres differ. Sound uses
cartridge pitches/timing with Web Audio oscillators rather than POKEY emulation;
music remains off, matching the Atari port. Gates and levers retain their original
blocking behavior. Excess entities respect the source's 224-slot limit. Invalid
room settings and exhausted generation attempts produce an error instead of hanging.

### Monster abilities

| Ability | Effect | From |
| --- | --- | --- |
| poison, paralyze, bolt, blink, boss | as in the cartridge (toxic rat, ghost, eyeball, imp, Raq'zul) | Lich King |
| flee | runs away from the hero | Lich King (box), Crocolike (scared) |
| treasure | drops blessed food when killed | Lich King (box) |
| stun | the first hit stuns the hero instead of hurting | Crocolike, BulbaRogue |
| curse | the first hit makes the hero forget the explored map | Crocolike |
| vampire | heals itself by its attack (30%) | Crocolike (vamp) |
| steal_item | the first hit steals a backpack item | Crocolike (stealitm) |
| steal_weapon | the first hit steals the weapon in hand | Crocolike (stealeqp) |
| slow | moves every other turn | Crocolike, BulbaRogue |
| still | never moves, hits what is next to it | Porklike (weed) |
| pounce | leaps along a free row or column to the hero | Porklike (kong) |
| summon | summons a monster every 3rd turn and keeps away | Porklike (queen) |
| hunter | always knows where the hero is | Porklike (reaper) |
| blind | the hero sees only 1 tile for 5 turns | Porklike |
| invisible | only seen when next to the hero | Porklike |

Their numbers (turns, chances, the summoned monster) are parameters in the Rules tab.
`tools/test_abilities.py ability...` builds a test room per ability and reports what happens.

## Controls

| PICO-8 button | Joystick | Keyboard |
| --- | --- | --- |
| Move, menu cursor | joystick 0 | arrow keys (`-` `=` `+` `*`) or W A S D |
| X: backpack, select, start | fire | X, V, M, SPACE, RETURN |
| O: close | — | C, Z, N, ESC |

The game is playable with a one-button joystick:

- Fire also closes a message box that has no cursor.
- In the backpack and its item menu, pushing left closes the menu.

Each button counts only after it has been seen released once. A held button repeats like
PICO-8's `btnp()`: 15 ticks after the press, then every 4 ticks.

## PICO-8 conversion

`tools/convert_cart.py` decodes the cartridge with the repository's `scrip/pico_convert.py`
and writes:

- `pico/cart.bin`: the raw 32K cartridge memory.
- `pico/lich.p8`: the text cartridge. It is identical to `allgames/[RPG]/Curse of the Lich King.p8`.
- `pico/lich.lua`: the game code.
- `pico/lich_gfx.png` and `pico/lich_gfx_x4.png`: the sprite sheet.
- `pico/lich_map.png`: the cartridge map, which holds the title background.

`tools/lichdata.py` builds the game description from the cartridge (the default
`data/game.json`, written when missing). `tools/make_data.py` turns `data/game.json` into:

- `data/gfx.bin` and `data/gfx2.bin`: the two sprite pages (4 bpp).
- `data/floors.bin`: the hand-made floors, run-length encoded (at most 8K).
- `data/stage.bin`: the font masks and the three XDLs.
- `data/sfx.bin`: the sound effects.
- `gen/params.asm`: the rules, as `P_...` constants.
- `gen/tables.asm`: the monster, ability and item tables, loot lists, per-floor tables, the
  map pieces, sprite flags, palettes, the fade table and the glyph widths.
- `gen/strings.asm`: every text of the game, encoded as glyph numbers of the cart's own
  proportional font.

`tools/make_editor_assets.py` writes `editor/assets.js` (the current `data/game.json` and the bundled
library carts).

## How it works

- **Memory.** Once loaded, the program switches the OS ROM off and runs its own NMI
  handler. The tile map, fog, the per-tile entity lists and the sound effects live in the
  RAM under the ROM.
- **Data-driven rules.** The generator, items and monster behaviour read the constants and
  tables generated from `data/game.json`. Monsters can use a second sprite page (VRAM
  `$38000`: raw, dark and flash copies) and hand-made floors are unpacked from VRAM `$3E000`
  into the map instead of generating it.
- **Display.** VBXE low-resolution overlay at narrow width shows the 128×128 PICO-8
  screen. Even rows are shown on two lines and odd rows on one, so the screen looks
  square. Three framebuffers (`$00000`, `$04000` and `$30000`) let the CPU draw the next
  frame while the previous one waits for the vertical blank.
- **Palettes.** The sprite sheet is expanded at load time into four 8-bit copies, one per
  palette the game uses: raw, lit (`pal(14,1)`), dark (fog) and the white hit flash.
  Mirrored sprites use a negative blitter source step. The screen fade rewrites the VBXE
  palette.
- **Map and fog.** The level is baked into a 1024×256 VRAM image, `$40000`–`$7FFFF`. A tile
  is re-drawn there only when its fog state changes. Each frame copies the visible
  17×17-tile window with one blit.
- **Text.** Each distinct (string, colours) pair is rendered glyph by glyph once, into one
  of 32 VRAM slots of 256×8 pixels. After that, every `pr()` of it is a single clipped
  blit. Lookups by string pointer skip hashing for texts that do not change every frame.
- **Blitter lists.** Two command lists (`$0E000` and `$0F000`) alternate, so the next
  list is built while the blitter runs the previous one. All drawing is clipped in
  software to the PICO-8 `clip()` rectangle.
- **HUD.** The HUD box is drawn off screen, in framebuffer 3 at `$34000`, whenever a value
  changes. Every frame it is copied with a single blit.
- **Game logic.** `src/level.asm`, `src/entity.asm`, `src/items.asm`, `src/windows.asm` and
  `src/game.asm` translate the Lua closely. The game runs at the original 30 ticks per
  second: PAL paces 3 ticks per 5 frames, NTSC 1 tick every 2 frames. Distances are
  compared as squares, so no square roots are needed.
- **Speed.** Every screen holds 30 ticks per second, except while walking on floor 8 with
  about 190 entities, which runs at about 85% of that. Generating a floor takes about 0.7 s
  on floor 1 and 2 s on floor 8, behind the fade to black.

### Differences from the cartridge

- **Music.** The music is not played.
- **Item menu cursor.** The item menu (use/equip/discard) gets a cursor. The cartridge
  never sets one, so its items could not be selected.
- **Hero on the first turn.** The hero is entered in the occupancy lists when a floor
  starts. The cart only adds it after its first move.
- **Random numbers.** They come from a 16-bit xorshift mixed with POKEY's `RANDOM`, and
  `flr(rnd(n))` uses an 8-bit fraction. Game outcomes therefore differ from PICO-8's
  random sequence, but not in their odds.
- **Text widths.** These use the real glyph widths from the start. The cartridge uses
  width 4 for a glyph until it has drawn that glyph once.

## Sound

`src/sound.asm` is the POKEY player from the Celeste port. It plays the cart's sound
effects on channels 3 and 2, with PICO-8's timing and its pitch, volume, noise, slide,
fade and arpeggio effects. Only the sound effects (6 and 32 to 63) are kept in
`data/sfx.bin`; they are copied into the RAM under the OS ROM ($C900, $FD00) while the
program loads. `music()` does nothing, and `SOUND = 0` in `lich.asm` silences
everything.

A second joystick button on POT 0 can be enabled with `USE_POT = 1`. It is off because
Altirra's paddle readings are not stable enough to use without a paddle attached.

## Testing tools

These run the game headless in `tools/emu.py`, a py65 Atari with enough VBXE emulation:
MEMAC, the blitter with a timing model, the palette and XDL screenshots. It is adapted
from the Celeste port.

- `tools/shot.py "script"`: plays an input script and saves screenshots to `shots/`. The
  steps are frames, `f` (fire), `c` (close), `u`/`d`/`l`/`r` (moves) and `s:name`
  (screenshot).
- `tools/deep.py N "script"`: the same, after regenerating the level at floor N.
- `tools/bot.py turns seed [depth [strong]]`: a bot that plays the game. It finds paths
  to monsters, props and stairs, equips weapons and eats. It has played several floors,
  died (the death box and return to the title), and killed Raq'zul on floor 8 (the
  victory sequence).
- `tools/fuzz.py`: random input, and reports where the CPU stalls.
- `tools/rate.py` and `tools/prof.py`: game ticks per 300 frames, and a CPU profile.
- `tools/pico_ref.py`: runs the original Lua generator through a PICO-8 shim (lupa). It
  measured the entity counts (up to about 200 on floor 8) used to size the tables.

The game has also been run in Altirra 4.40 (NTSC, VBXE at `$D600`). It shows the title,
starts the game and plays there.
