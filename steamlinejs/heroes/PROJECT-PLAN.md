# Atari VBXE town-and-battles project plan

Planning baseline: 8 September 2026. This is a proposed design, not implemented functionality. Working assumption: “one unit of one type” means one individual fighter per building, not a King's Bounty stack containing many creatures.

**Recommendation.** Extend the existing Heroes VBXE battle prototype with a small campaign. Keep two main management screens—City/Army and Encounters—with a separate battle view entered from an encounter. Use King's Bounty/OpenBounty for troop roles, abilities and bounty presentation. Keep the existing 7×6 hex battlefield and individual HP model.

**What is already here.**

| Local project | Findings | Use in this project |
|---|---|---|
| Original Heroes of Lowrez bundle in this directory | Compiled Defold/WebAssembly game, archive data and two battle screenshots; not an editable original gameplay source tree | Visual reference: large readable fighters, quiet grass background, sparse HUD, dark movement highlights |
| `web/engine.js` and `web/app.js` | Portable integer rules, 7×6 hex board, 12 unit slots, four battles, knight/archer, enemy AI, queued action presentation and warlock summoning | Browser rules reference and a quick place to playtest the campaign |
| `atari/heroes-vbxe.asm` | Native MADS/6502 implementation, 320×200 indexed VBXE output, double buffering, transparent blits, joystick input and four battles | Main implementation foundation |
| `atari/generate_data.js` | Build-time PNG conversion and generated hex lookup tables | Extend into a shared content pipeline for units, buildings and encounters |
| `openbounty-main/openbounty-main/engine/combat.c` and `engine/include/combat.h` | 6×5 battlefield, five stack slots per side, stack casualties, retaliation, ranged ammunition, flight, spells and deterministic combat support | Reference for selected tactical abilities and reproducible testing |
| OpenBounty `engine/` versus `src/` | Game logic separated from platform rendering and input | Preserve the same separation in the smaller game |

The web README still mentions an eight-unit cap; both current web and Atari code define 12. The Atari battle initializer currently creates a knight and archer directly. Army-driven deployment must replace that initialization. Warlock summoning is tied to the final battle number in the web rules; make it an explicit encounter/ability setting.

OpenBounty's C engine has desktop dependencies and a broader game-state model even though it is separate from raylib. Translating its complete combat module would add work and stack-based rules that this design does not need. Its [upstream repository](https://github.com/dannyheskett/openbounty) provides the broader reference. Treat existing game artwork as reference material; prepare original release assets. The local OpenBounty source includes an MIT license; preserve its notice if incorporating source portions.

**The game loop.**

```text
CITY / ARMY <----------> ENCOUNTERS
  build, upgrade           choose an unlocked location
       ^                            |
       |                            v
       +---- RESULT <------------ BATTLE
          gold, progress        tactical hex combat
```

After the result, return to Encounters with an immediately available City button. No walking, world travel, exploration fog, calendar or weekly upkeep. A location is a selectable entrance in a static illustrated scene.

**City and army screen.** Show the town in the upper area, five army portraits along the bottom, and a compact gold/status strip. Selecting a building displays its fighter, next upgrade, cost and one clear action. Empty plots show the building cost. Use a small panel over the scene for details rather than another full management screen.

Each building owns one army slot. Building it creates its fighter immediately. Upgrading replaces that slot's type; the old and new types cannot coexist. Each building can be built only once. All owned fighters deploy automatically, so no separate recruitment quantities, reserves or deployment screen are required initially.

Suggested roster; names and abilities are proposals:

| Building | Upgrade line | Tactical purpose |
|---|---|---|
| Barracks | Militia → Guard → Knight | Durable melee fighter; later gain one retaliation per round |
| Archery range | Hunter → Archer → Marksman | Fragile ranged damage; later gain a stronger stationary shot |
| Lodge | Scout → Ranger → Beastmaster | Mobile flanking fighter; later gain obstacle traversal |
| Chapel | Acolyte → Healer → Priest | Limited healing; later gain an anti-undead ability |
| Tower | Apprentice → Mage → Wizard | Fragile caster; later gain a limited area attack |

Start with Militia and Hunter. First playable version adds only the Lodge and one upgrade for the two starting buildings. Design five slots now, but add Chapel, Tower and advanced abilities after the basic campaign is fun. Movement beyond the existing two-step limit requires rule and pathfinding changes; do not assume a larger movement stat alone enables it.

The army's fighters provide the “heroes” initially. A named commander can appear in the city portrait for flavour. A separate commander class, equipment system and global spell menu are later options; their inclusion should not delay the first campaign.

**Encounters screen and progression.** Use one illustrated region with visible forest, graveyard, cave and tower entrances. Locked entrances stay visible but dim. Selection displays enemy preview, reward and progress such as `2/3 victories`. Joystick directions move between predetermined entrance neighbours; Fire opens the preview and confirms entry. The browser uses clickable entrances.

| Location | Encounter sequence | Unlock |
|---|---|---|
| Woodland | Beasts in the open; trees blocking approach; beasts with a ranged enemy | Three victories open Graveyard |
| Graveyard | Skeleton patrol; archers behind blockers; mixed skeleton guard | Three victories open Cave |
| Cave | Bats; ogre and escorts; heavy guard in a narrow approach | Three victories open Tower |
| Tower | Imp guard; ranged defenders; summoning warlock | Final victory completes the campaign |

Each required victory advances to the next authored battle at that entrance. Losing repeats the current battle. This preserves repeated victories unlocking the next entrance while giving each fight a different tactical problem. Cleared entrances offer a repeatable practice battle for smaller gold rewards. Progress counters saturate at the requirement; replays cannot repeatedly grant the first-clear bonus.

All four entrances fit on the same screen. A second region illustration can be added later without introducing walking. Existing enemy identities can populate the campaign, but their current shared sprite sheet does not provide distinct art for every identity; budget new silhouettes for important roles.

**Combat rules.**

- Keep the current player phase followed by the enemy phase, with automatic activation in army-slot order.
- Preserve current player movement: an immediate attack ends the turn; one move can be followed by an attack, another move or Skip; a direct two-cell move ends the turn. Slower fighters retain their smaller movement budget.
- Begin with melee adjacency, ranged attacks, blocking trees, small integer HP and fixed damage. Keep initial targeting behaviour aligned with the prototype; line-of-sight blocking would be a separate addition.
- Target five friendly fighters and at most seven enemies, within the existing 12-unit total. Reserve capacity explicitly when an encounter summons enemies. No room or free slot means no summon that round.
- Add abilities one at a time: retaliation, limited healing, then flight or an area spell. Implement retaliation as a bounded follow-up action, never an unbounded exchange.
- Show the active fighter, reachable cells, target HP and expected damage. Make “Skip” available as a joystick-selectable HUD action as well as a keyboard shortcut.
- Win when all enemies are defeated; lose when all friendly fighters are defeated. A retreat action returns with no reward or progress.

OpenBounty's damage formulas depend on stack counts, morale and leadership. Do not copy their numbers into individual fighters. Balance single-unit HP and damage around readable battles lasting a few minutes.

**Economy and recovery.** Use gold as the only campaign resource. For the first version, all owned fighters recover fully after battle, including defeated fighters. Buildings and upgrades are permanent. Loss or retreat gives no gold and no victory credit. This is a deliberate proposed simplification: permanent casualties plus paid replacements could leave the player unable to earn enough to recover.

Starting balance example, to be playtested: the first three Woodland wins pay 40, 50 and 60 gold, with a one-time 30-gold completion bonus. First building upgrades cost 60 each; the Lodge costs 100. The resulting 180 gold permits either two upgrades or an upgrade plus a third fighter. A cleared Woodland practice battle pays 20. Unlock later upgrade tiers through region progress so unlimited early replays cannot buy the final army immediately.

No build timers or passive income are necessary. The main choice is improving an existing role versus adding another fighter. Later locations must be beatable without excessive practice farming; test the weakest reasonable purchase paths, not just the strongest roster.

**Implementation design.** Keep campaign state separate from temporary battle state. The campaign owns gold, five building levels, location victory counters and completion flags. Deployment converts building levels into fighter types and copies them into battle arrays. A battle result is committed once, then its temporary state is discarded.

Use a single authoring data file to generate JavaScript tables and MADS includes. Suggested records: unit HP/damage/range/movement/ability/sprite; building tier-to-unit mapping and costs; encounter terrain/enemy placements/reward/prerequisite. Validate unique player types, deployment cells, enemy counts and summon capacity during generation.

Add explicit modes: `CITY`, `ENCOUNTERS`, `BATTLE`, `RESULT`. Presentation reads state; input sends actions; only rules change gold and progress. Fixed arrays and bounded event queues remain appropriate. Size animation queues against worst-case turns after adding retaliation or area attacks; the current web queue silently drops events at its capacity.

Use 16-bit gold with a defined maximum and saturating reward arithmetic. Byte-sized building levels, unit IDs and location counters are sufficient. A versioned between-battle save record should fit comfortably below 128 bytes including checksum and reserved fields. Save committed campaign state after purchases and results; reject invalid saves without overwriting them. Browser storage can come first; Atari disk save/load needs an explicit storage and OS-memory plan. Do not promise resume in the middle of a battle for version one.

**VBXE integration.** Keep the current two 64 KiB framebuffer banks, sprite blits and vertical-blank presentation. Cache or rebuild the background when changing screens; avoid caching every campaign scene without a memory budget. Store compact gameplay state in Atari RAM and graphics in VBXE memory.

Before adding code or art, audit the linker map: existing source starts at `$2000`, embeds assets at `$4000`, places text memory at `$8000`, and maps the VBXE CPU window at `$9000`. These fixed regions need overlap assertions and a deliberate revised layout. The current asset verifier also assumes exactly 14,848 asset bytes and must evolve with the asset pipeline. Set a baseline hardware target of a 64 KiB XL/XE with compatible VBXE FX 1.2x, subject to verifying the final memory map and save strategy.

**Delivery order and acceptance.**

| Stage | Deliverable | Complete when |
|---|---|---|
| 1. Content and campaign rules | Shared tables, building-to-army mapping, gold, result commits, unlock rules | Duplicate recruitment is impossible; rewards apply once; losses preserve progress; counters and gold cannot overflow |
| 2. Small browser campaign | Two management screens, Woodland with three battles, third building, two upgrades | A new player can fight, earn, upgrade and open the next entrance; losing always allows retry |
| 3. Native VBXE campaign | City/encounter renderers and joystick navigation connected to the existing battle engine | The same small campaign works on Atari; memory regions do not overlap; screen changes and input behave correctly |
| 4. Full short campaign | Four locations, five buildings, authored encounter variants, final boss | Every location is reachable through reasonable purchases; summon limits and every ability work correctly |
| 5. Save and release polish | Save/load, original art, sound, result feedback and final balancing | Saves survive restart; corrupt saves are handled; complete victory and defeat/retry paths pass emulator and hardware checks |

Create save record/version boundaries in stage 1 even if persistence ships in stage 5. Keep the existing prototypes as reference while building the new campaign in a dedicated project subdirectory when implementation begins.

Testing should cover meaningful gameplay boundaries: purchases without sufficient gold, one fighter per building after upgrades, repeat result handling, unlock thresholds, defeat recovery, obstructed movement, full summon capacity, and save round trips. Use shared deterministic action fixtures to compare browser and Atari state for representative battles. Validate rendering and joystick behaviour in an emulator; structural XEX checks alone do not establish runtime correctness.

**Checks performed for this plan.** Read the local prototypes, their build/data scripts, OpenBounty combat declarations and implementation, and inspected both supplied battle screenshots. `node web/test-engine.js` passed the existing movement, turn and result checks. `node atari/verify_build.js` passed against the existing 23,950-byte executable. No fresh Atari build, emulator playthrough, OpenBounty runtime session or new gameplay implementation was performed.
