# Existing unit inventory — 9 September 2026

This is the local snapshot taken before duplicate recruitment and integrated
battles were added; current city stats and rules have since changed. It inventories
the local copies at that point, not upstream releases. Numeric tables below
are existing source data, not recommended single-fighter balance. Complete raw
OpenBounty troop records (including dwelling, population, growth, morale group,
spoils, tier counts and animation paths), hero classes and city costs are in
[unit-inventory.json](unit-inventory.json).

## Scope and confidence

- **OpenBounty:** all 25 troop records in the local [King’s Bounty pack](../openbounty-main/openbounty-main/assets/kings-bounty/game.json:2953).
- **Portable web battle:** all nine unit IDs and stat arrays in [engine.js](../web/engine.js:24).
- **Previous native Atari battle:** all nine unit types in [heroes-vbxe.asm](../atari/heroes-vbxe.asm:363). Extraction verified all four numeric arrays match the web implementation exactly.
- **Current Atari city:** all 15 recruit tiers in [content.json](../atari/city/content.json). These are independent of the battle prototype's stats and are not yet deployed into it.
- **Original Heroes of Lowrez:** compiled Defold/WASM and archives, not editable gameplay source. The local [investigation notes](../web/README.md:27) identify minibeast, skeleton, ogre, bat, warlock and imp; the knight and archer are visible reference characters. The separate skeleton-archer type is explicit in the reconstruction. Do not claim a complete original roster or recovered original HP: the reconstruction explicitly says its numbers are approximations. Raw string matches are not a reliable full catalog.
- No further playable game source trees were found under `heroes`. OpenBounty's `tests/fixtures/animpack` is a test fixture, not a second game roster. The web and native battle versions are the same design, not two unrelated games.

## OpenBounty: complete troop table

Melee is the authored min–max roll **before** skill, stack count and other modifiers.
Ranged is min/max/ammunition, **not attack distance**. MAGIC units use their
ranged minimum as fixed base damage; the zero maximum is intentional.
Movement is OpenBounty's own move-rate field; flight has separate handling.

| ID | Troop | HP per creature | Skill | Move | Melee | Ranged min/max/ammo | Recruit gold | Abilities |
|---|---|---:|---:|---:|---|---|---:|---|
| 0 | Peasants | 1 | 1 | 1 | 1–1 | 0/0/0 | 10 | — |
| 1 | Sprites | 1 | 1 | 1 | 1–2 | 0/0/0 | 15 | FLY |
| 2 | Militia | 2 | 2 | 2 | 1–2 | 0/0/0 | 50 | — |
| 3 | Wolves | 3 | 2 | 3 | 1–3 | 0/0/0 | 40 | — |
| 4 | Skeletons | 3 | 2 | 2 | 1–2 | 0/0/0 | 40 | UNDEAD |
| 5 | Zombies | 5 | 2 | 1 | 2–2 | 0/0/0 | 50 | UNDEAD |
| 6 | Gnomes | 5 | 2 | 1 | 1–3 | 0/0/0 | 60 | — |
| 7 | Orcs | 5 | 2 | 2 | 2–3 | 1/2/10 | 75 | — |
| 8 | Archers | 10 | 2 | 2 | 1–2 | 1/3/12 | 250 | — |
| 9 | Elves | 10 | 3 | 3 | 1–2 | 2/4/24 | 200 | — |
| 10 | Pikemen | 10 | 3 | 2 | 2–4 | 0/0/0 | 300 | — |
| 11 | Nomads | 15 | 3 | 2 | 2–4 | 0/0/0 | 300 | — |
| 12 | Dwarves | 20 | 3 | 1 | 2–4 | 0/0/0 | 350 | — |
| 13 | Ghosts | 10 | 4 | 3 | 3–4 | 0/0/0 | 400 | ABSORB, UNDEAD |
| 14 | Knights | 35 | 5 | 1 | 6–10 | 0/0/0 | 1000 | — |
| 15 | Ogres | 40 | 4 | 1 | 3–5 | 0/0/0 | 750 | — |
| 16 | Barbarians | 40 | 4 | 3 | 1–6 | 0/0/0 | 750 | — |
| 17 | Trolls | 50 | 4 | 1 | 2–5 | 0/0/0 | 1000 | REGEN |
| 18 | Cavalry | 20 | 4 | 4 | 3–5 | 0/0/0 | 800 | — |
| 19 | Druids | 25 | 5 | 2 | 2–3 | 10/0/3 | 700 | MAGIC |
| 20 | Archmages | 25 | 5 | 1 | 2–3 | 25/0/2 | 1200 | FLY, MAGIC |
| 21 | Vampires | 30 | 5 | 1 | 3–6 | 0/0/0 | 1500 | FLY, LEECH, UNDEAD |
| 22 | Giants | 60 | 5 | 3 | 10–20 | 5/10/6 | 2000 | — |
| 23 | Demons | 50 | 6 | 1 | 5–7 | 0/0/0 | 3000 | FLY, SCYTHE |
| 24 | Dragons | 200 | 6 | 1 | 25–50 | 0/0/0 | 5000 | FLY, IMMUNE |

Ability codes: FLY flight; UNDEAD undead identity; ABSORB adds killed creatures
to the attacking stack; LEECH restores creatures up to the original stack count;
REGEN clears residual injury; MAGIC special ranged spell damage; SCYTHE can kill
half a stack; IMMUNE cancels MAGIC ranged damage in the damage routine. These
semantics are specific to this implementation. For example ghosts are not marked
FLY in this pack, and dragons have no separate ranged breath attack in these data.

The local [damage routine](../openbounty-main/openbounty-main/engine/combat.c:385)
uses `base_damage * turn_count * (attacker_skill + 5 - defender_skill) / 10`,
then applies morale/artifact effects, accumulated injury, casualties and special
abilities. At equal skill the core formula halves base stack damage. Setting
count to one does not produce a balanced individual-fighter game. SCYTHE's
rounded-up half-count effect is especially unsuitable: against a one-creature
stack it can kill that creature outright. Regeneration clears injury, which is
also much stronger when the entire army slot represents only one creature.

OpenBounty also has four **hero classes**, distinct from battlefield troops:
Knight, Paladin, Sorceress and Barbarian. Their leadership, spell resources,
commissions and starting armies are included in the raw JSON. They are not four
extra recruitable troop types.

## Web and previous Atari battle: complete shared roster

| ID | Unit | HP | Damage | Range | Move |
|---|---|---:|---:|---:|---:|
| 0 | Knight | 5 | 2 | 1 | 2 |
| 1 | Archer | 3 | 2 | 3 | 2 |
| 2 | Minibeast | 3 | 1 | 1 | 2 |
| 3 | Skeleton warrior | 3 | 1 | 1 | 1 |
| 4 | Ogre | 6 | 3 | 1 | 1 |
| 5 | Bat | 2 | 1 | 1 | 2 |
| 6 | Warlock | 7 | 2 | 3 | 1 |
| 7 | Imp | 2 | 1 | 1 | 2 |
| 8 | Skeleton archer | 2 | 1 | 3 | 1 |

The [old encounter tables](../atari/generate_data.js:106) are:

1. Two Minibeasts + Ogre.
2. Skeleton warrior + two Skeleton archers.
3. Two Bats + Ogre + Minibeast.
4. Two Skeleton archers + Warlock; the battle code summons Imps.

All four initial enemy rosters violate strict one-per-type. The native
[summoning routine](../atari/heroes-vbxe.asm:998) also lacks an existing-Imp
uniqueness check. Their encounter logic must change, not just their HP tables.
Both implementations reserve 12 unit slots and use a 7×6 hex board. The old web
README's eight-slot statement is stale relative to the source.

## Current Atari city: complete recruit roster

The city currently uses one unit per building family, five independent army slots,
first-free recruitment, half-price dismissal and unit upgrades paid as the
recruit-price difference. Building upgrades unlock units but do not upgrade the
army automatically. It starts with 60,000 test gold and no buildings or units.
Move, armor and combat abilities are not defined in its current content file.

| Building | Tier | Unit | HP | Damage | Range | Recruit gold | Building build/upgrade gold |
|---|---:|---|---:|---:|---:|---:|---:|
| BARRACKS | 1 | Militia | 6 | 2 | 1 | 50 | 100 |
| BARRACKS | 2 | Guard | 9 | 3 | 1 | 100 | 120 |
| BARRACKS | 3 | Knight | 13 | 4 | 1 | 180 | 240 |
| ARCHERY RANGE | 1 | Hunter | 4 | 2 | 3 | 50 | 100 |
| ARCHERY RANGE | 2 | Archer | 6 | 3 | 3 | 100 | 120 |
| ARCHERY RANGE | 3 | Marksman | 8 | 4 | 4 | 180 | 240 |
| RANGER LODGE | 1 | Scout | 5 | 2 | 1 | 75 | 150 |
| RANGER LODGE | 2 | Ranger | 7 | 3 | 1 | 140 | 180 |
| RANGER LODGE | 3 | Beastmaster | 10 | 4 | 1 | 230 | 280 |
| CHAPEL | 1 | Acolyte | 5 | 1 | 1 | 90 | 180 |
| CHAPEL | 2 | Healer | 7 | 2 | 1 | 160 | 200 |
| CHAPEL | 3 | Priest | 9 | 3 | 1 | 250 | 300 |
| WIZARD TOWER | 1 | Apprentice | 3 | 3 | 3 | 110 | 220 |
| WIZARD TOWER | 2 | Mage | 5 | 4 | 3 | 200 | 240 |
| WIZARD TOWER | 3 | Wizard | 7 | 6 | 4 | 320 | 340 |

Names that overlap (Knight, Archer, Militia, Ogre, etc.) do not imply matching stats or identical roles across projects. Preserve provenance when merging IDs.
