# Recovered original Heroes of Lowrez statistics

Recovered 2026-09-10 from the local **Heroes of Lowrez 1.1** web bundle. These are original values, not the estimates in the older Atari implementation or the current Greenhaven balance. Machine-readable data: [stats.json](stats.json).

| Unit identifier | Side | HP | Damage | AP / speed | Range |
|---|---|---:|---:|---:|---:|
| spearman | Player | 3 | 2 | 2 | 1 |
| archer | Player | 3 | 1 | 1 | 4 |
| swordsman | Player | 4 | 3 | 2 | 1 |
| beast | Enemy | 3 | 2 | 3 | 1 |
| ogre | Enemy | 5 | 4 | 2 | 1 |
| skeleton | Enemy | 3 | 1 | 1 | 4 |
| dark | Enemy | 4 | 3 | 2 | 1 |
| demon | Enemy | 2 | 2 | 2 | 1 |
| sniper | Enemy | 3 | 1 | 2 | 5 |
| warlock | Enemy | 7 | 1* | 1 | 3* |
| minibeast | Enemy | 3 | 1 | 3 | 1 |

Names preserve source identifiers: do not silently rename `dark` to a guessed creature name. There is no separate Knight, Bat, or Imp entry in this bundle's KINDS table.

*Warlock has dmg=1 in its data, but its action summons a Demon into an empty, treeless hex within range 3, instead of attacking. A summoned Demon enters the turn queue immediately after the Warlock. Killing the Warlock triggers victory even with other enemies remaining.*

## Rules that affect balance

Verified in `lua_modules/tactic.lua`:

- The original battlefield is a 5×5 hex grid. Units are individuals; duplicate types are allowed on both sides.
- Each movement step costs 1 AP. Spending all AP ends the turn. Moving while retaining AP allows another move or an attack. An attack ends the turn regardless of remaining AP.
- Initial turn order sorts all units by descending AP, mixing both sides; subsequent turns rotate through that queue. Ties have no explicit tie-break rule.
- Damage subtracts the fixed dmg value from HP. There is no armor, retaliation, random damage, or stack multiplier in this attack routine.
- Trees and occupied cells block movement. Range search traverses hex links without line-of-sight blocking by trees or units.
- Therefore AP is both movement allowance and initial initiative, not a separate attack count. An Archer with 1 AP cannot move and shoot in the same turn.

## Recruitment and upgrades

Verified in globals, town, and upgrade scripts:

| Action | Gold | Requirement |
|---|---:|---|
| Recruit Spearman | 25 | Available army slot |
| Spearman → Archer | 40 | Workshop, costing 110 |
| Spearman → Swordsman | 50 | Blacksmith, costing 130 |
| Expand capacity from 3 to 5 | 100 | Build Tower |

A newly recruited Archer therefore costs 65 total and a Swordsman 75, excluding the shared building cost. Upgrades replace the unit type, not a numerical experience level. Upgraded units can be demoted to Spearmen; the demotion handler has no refund. Normal reset starts with 100 gold, two Spearmen, and no buildings. The globals file also contains a debug snapshot with 7777 gold; that is distinct from `reset_snapshot()`.

## Original encounters

Copied from `BATTLES` in globals; requirement means the named encounter must have been completed.

| Encounter | Enemies | Gold | Requirement | Flags |
|---|---|---:|---|---|
| Beast Lair | 2 Minibeasts | 50 | — | |
| Ruins | 3 Beasts | 100 | — | |
| Elder Ruins | 5 Demons | 110 | Ruins | |
| Forest | 4 Beasts, 1 Minibeast | 120 | Elder Ruins | |
| Crypt | 2 Skeletons, 2 Dark | 120 | — | |
| Deep Forest | 4 Beasts, 1 Ogre | 150 | Forest | |
| Graveyard | 2 Skeletons, 3 Dark | 160 | Crypt | |
| Merry Men | 4 Snipers, 1 Ogre | 200 | Graveyard | Once |
| Ogre Camp | 2 Beasts, 3 Ogres | 200 | Merry Men | Once |
| Warlock | 2 Skeletons, 1 Warlock, 2 Demons | 1000 | Ogre Camp | Final |

There is also a special index-0 Prelude definition containing one Warlock and reward 1000; it should not be treated as a normal opening farm encounter.

The source's rough party-strength heuristic is `sum(AP × 0.5 + HP + damage + range × 0.75 + summon_bonus)`, where summon_bonus is 10 for summoners and 0 otherwise. This is an original heuristic, not proof of balanced encounters.

## Reproduction and evidence

Run from any directory:

```sh
python3 /home/marcin/tmp/pico/steamlinejs/heroes/design/lowrez/recover.py
```

Requires Python 3 and system liblz4. The script reads the local archive only, uses the standard Defold XTEA-CTR archive decoding and LZ4 decompression, and extracts resources to `/tmp/lowrez-extracted`. It does not execute game code. All 133 resources decompress/read successfully; the 17 script resources contain Lua source within protobuf messages.

Relevant extracted Lua files:

- `085.lua`: `lua_modules/globals.lua`, unit definitions, prices, encounters, reset.
- `081.lua`: `lua_modules/tactic.lua`, battle rules.
- `109.lua`: `upgrade/upgrade.gui_script`, upgrade and demotion behavior.
- `120.lua`: `town/town.gui_script`, recruitment and capacity.

Input archive SHA-256 fingerprints are recorded in stats.json. Game data and scripts belong to their original authors. Existing Atari balance and the editable HTML page were not modified.

Decoding references: [Defold archive reader, version 1.2.170](https://github.com/defold/defold/blob/1.2.170/engine/resource/src/resource_archive.cpp), [Defold XTEA implementation](https://github.com/defold/defold/blob/1.2.170/engine/dlib/src/dlib/crypt.cpp). The [arcdEx project](https://github.com/jht3QAQ/arcdEx) also documents Lua-source recovery from older web bundles.
