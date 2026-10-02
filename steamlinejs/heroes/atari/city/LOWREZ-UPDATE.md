# Native Lowrez-based game preset

The game now uses the approved medieval atlas artwork, the imported greenhaven-unit-balance.json combat numbers, and a 50-gold start. Launch `../../run-city.sh` from this directory, or open `city-vbxe.xex` in VBXE-enabled Altirra.

## Start and economy

Start: 50 gold, level-2 Barracks, two individual Spearmen, capacity for three fighters (one free slot and two locked slots). Duplicate units are allowed. No walking world map.

| Building | Units, levels 1 / 2 / 3 | Recruit prices | Building prices, levels 1 / 2 / 3 |
|---|---|---|---|
| Barracks | Militia / Spearman / Swordsman | 15 / 25 / 75 | 50 / 100 / 130 |
| Archery | Hunter / Archer / Marksman | 25 / 65 / 100 | 60 / 110 / 160 |
| Lodge | Scout / Ranger / Cavalry | 20 / 50 / 90 | 70 / 120 / 180 |
| Chapel | Fourth slot / fifth slot / recruit discount | No recruits | 80 / 130 / 190 |
| Tower | Apprentice / Mage / Wizard | 30 / 70 / 120 | 100 / 150 / 220 |

Stats and prices are imported from `../../greenhaven-unit-balance.json`. Archer shooting range is 5, Marksman is 7, Ranger movement is 4 and Cavalry movement is 6. Scout, Ranger and Cavalry have separate mounted artwork. These are customized Lowrez-based values, not an exact copy of Lowrez.

Chapel level 1 costs 80 and unlocks the fourth slot. Level 2 costs 130 and unlocks the fifth slot. Level 3 costs 190 and reduces all recruitment prices by 10 gold (minimum 1). Chapel never recruits a unit. Its discount does not reduce building or individual upgrade prices.

Upgrading an individual costs the difference in recruitment price. Thus Spearman → Swordsman costs 50 gold. Dismissal refunds half the gold actually paid for that fighter, including later upgrades, rounded down. Units fully recover after battle; defeat or retreat pays nothing. The opening encounter is tested as winnable with the two starting Spearmen and no extra gold.

## Encounters

Three victories unlock the next region. The battle header displays the actual contract name.

| Region | Contracts | Rewards |
|---|---|---|
| Forest | Beast Lair; Ruins; Elder Ruins | 50; 100; 110 |
| Catacombs | Crypt; Graveyard; Merry Men | 120; 160; 200 |
| Caves | Forest; Deep Forest; Ogre Camp | 120; 150; 200 |
| Ruins | Warlock Guard; Inner Ruins; Warlock | 160; 200; 1000 |

Ten encounters use original Lowrez enemy lineups and rewards; Warlock Guard and Inner Ruins are new connective encounters. After completing a region, repeating its final contract pays 50 / 80 / 100 / 150 respectively, with no extra progression or region bonus. Rewards are committed once per battle.

Warlock summons Demons into open cells within range 3; its stored damage 1 is not a shooting attack. Killing it immediately wins even if its minions remain. The battle supports 12 total individual slots, so summons stop at the slot limit (dead entries currently retain their slot).

## Battle and artwork

All 25 available types (plus three reserved former Chapel IDs) have shooting-range data (0 for non-shooters), HP, damage and movement allowance. Melee still reaches an adjacent hex. Movement supports allowances up to 6: select one or two reachable steps at a time, with remaining points retained. An attack ends that fighter's turn. Enemy movement uses its full allowance.

The native game retains a 7×6 hex board, player phase followed by enemy phase, and obstacles blocking shots. These differ from original Lowrez's 5×5 board, initiative queue, and range search. Balance will therefore need playtesting.

Approved artwork is converted to 32×28 full-body sprites, six poses per set, using local 15-color palettes mapped into the shared VBXE palette. Five original hero appearances are supplemented by three distinct mounted sets. All thirteen enemy types have their own set. Four walking poses are separate from attack preparation/release. Enemy art is mirrored to face the player army. City portraits use the same artwork.

126 compressed frames use 22,269 bytes of VRAM. Combat metadata lives at CPU $7000; animation metadata lives with the code outside the upload staging area. Build verification checks allocations for overlap.

`content.json` is the native build input. To import the supplied balance again, run `node tools/import-balance.js ../../greenhaven-unit-balance.json`, then `./build.sh`. The importer also accepts JSON exported by the editor. HTML changes remain browser drafts until exported and imported into the game.

## Verification

Run `./build.sh`, then with py65/Pillow installed:

```
python3 tools/test-chapel.py
python3 tools/test-runtime.py
python3 tools/test-hero-animation.py
python3 tools/test-lowrez.py
```

These execute assembled 6502 code with a functional VBXE model at D600 and D700, including the loader, missing-hardware fallback, economy, animation decoding and battle rules. They do not verify physical hardware timing or prove every army composition can win every encounter.

## Faster battle rendering and numeric HUD

Four opaque idle-sprite caches avoid repeated decompression of stationary fighters.
Once full, the cache keeps its entries rather than cycling them out when a fifth
appearance is present. Cache memory is reset logically at each battle and checked
for overlap by the build verifier. Animated poses continue to use the separate
scratch sprite. Tactical range calculations are skipped during animation frames.
Movement advances twice as far per frame and attacks use four frames instead of
eight. A measured ten-unit battle redraw takes about 208,196 CPU cycles with warm
caches versus 408,405 with cold caches in the functional emulator. This is a CPU
measurement, not a physical Atari frame-rate claim.

Floating health bars are removed. The bottom panel shows HP current/maximum,
ATTACK (damage), MOVE (remaining/maximum movement), SHOOT (shooting distance;
0 means no shooting), and ready/acted status. One focused unit is shown in
spaced, labeled columns: hovered unit, otherwise selected ally.
`tools/test-battle-speed.py` verifies cache behavior, CPU reduction and live stats.

Double Fire on the same selected friendly hex within 30 video ticks skips that
unit. Holding the button does not count twice; navigation and menu actions cancel
the pending pair. The original Skip Unit button remains available.
