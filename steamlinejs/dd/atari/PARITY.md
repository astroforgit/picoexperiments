# Supplied NES-derived source versus Atari VBXE

The requested target is the full behavior of the locally supplied game, including
combat, weapons and scenery collisions. **The playable Atari XEX does not meet
that target.** Its four-stage adaptation and the unfinished full-source port are
separate implementations. Passing component tests is not gameplay parity.

The reference is `../double-dragon-snes-main/double-dragon-snes-main/src`.
Its README identifies it as a SNES port of the NES game and explicitly says its
PRG banks are heavily modified. This audit therefore targets that supplied
source; it does not assert identity with an unprovided, unmodified NES ROM.

## Feature checklist

“Partial” means the XEX has an adapted version; “missing” means absent from that
XEX. Source addresses below are original virtual addresses, not Atari addresses.
Some code is stored as literal bytes and must be assembled/disassembled to inspect.

| Feature in supplied source | Playable Atari status | Work required for parity |
|---|---|---|
| Campaign sections and routing | Partial: four stages, 16 selected rooms | Preserve all 11 sections (`bank7:E76F`), original room selection and exits |
| Encounter records and spawn conditions | Partial: 12 newly designed waves | Use original section/spawn records (`bank6:9924`, `924C`) |
| Horizontal and vertical camera logic | Partial: forward horizontal gates | Preserve original camera, section bounds and scroll triggers |
| Ground-plane boundaries and slopes | Missing | Integrate `bank5:B000` and its original piecewise boundary data |
| Platform support and landing | Missing | Integrate `bank5:B3EC`, including its seven-pixel landing tolerance |
| Vertical wall faces | Missing | Integrate `bank5:B6FD`, including height/depth tests and side-specific displacement |
| Pose-dependent terrain probes | Missing | Preserve `bank5:AAA0` and the probe tables for every character/pose |
| Movement correction after collisions | Missing | Integrate the full `bank5:A509` dispatcher and `A971` position correction |
| Falls, unsupported ground and landing state transitions | Missing | Preserve airborne/grounded branches in `bank5:A551`, `A6E6` |
| Climbing and transitions between surfaces | Missing | Preserve surface state, input gating and `bank5:A905`, `B864`, `BA72`, `BDB6` paths |
| Moving/supporting objects | Missing | Preserve object support tests (`bank5:BB8B`) and carried displacement (`A9E9`) |
| Stage obstacles and timed hazards | Missing | Preserve original object dispatch and stage-specific triggers (`bank7:D080` onward) |
| Punch, kick and airborne attacks | Partial: three tuned moves | Use original input/state, animation, timing and attack records |
| Other player actions and combos | Missing | Audit and port every player action state rather than add guessed attack rules |
| Experience and move unlock progression | Missing | Preserve experience accumulator (`bank7:FB8B`), level cap and action gates |
| Grapples, hold strikes and throws | Partial: one adapted grab/throw | Preserve original eligibility, attachment, interruption and throw state transitions |
| Attacks colliding with fighters | Partial: fixed directional/depth ranges | Preserve move-specific hit records and queued damage (`bank4:AFEF–B094`) |
| Damage, stun, invulnerability, knockdown and recovery | Partial: tuned values | Preserve original HP and state transitions (`bank4:AA6F`, `bank6:99EF`) |
| Weapon ownership, pickup and drop | Missing | Preserve original object slots, ownership links and action restrictions |
| Held weapon attacks | Missing | Preserve weapon-specific animation, reach, damage and collision records |
| Thrown weapons/projectiles and explosive objects | Missing | Preserve object action dispatch (`bank7:D9B7` onward), lifetimes and hit behavior |
| Weapon collisions with scenery and rebound | Missing | Preserve object branches of `bank5:A600`, `A73A`, `A846` |
| Conditional weapon graphics and attachment | Missing | Decode conditional source sprite records (`bank7:FB1C`, `F89E`); current asset generator skips them |
| Full enemy roster | Partial: Williams, Linda, Abobo | Include the remaining source roster; `tiles.asm` also identifies Roper, Chin and shadow boss graphics |
| Enemy decision/state machines | Partial: newly written AI | Preserve all source species/state dispatch, facing, movement and attack decisions (`bank6:8000`) |
| Boss encounters and final opponent | Missing as original encounters | Preserve boss-specific scripts, attacks and progression; repeating Abobo is insufficient |
| Full sprite animations | Partial: four selected poses per fighter | Use the original sprite builder and all poses/CHR switches |
| Sprite overlap priority, clipping and palette selection | Partial: adapted depth sorting/palette | Match original sprite construction and priority, including weapon/obstacle sprites |
| Original HUD, health scale and progression display | Partial: 12-point health and simplified HUD | Preserve source health, experience and HUD calculations (`bank7:F55D–F89D`) |
| Score, timer, life loss and continue behavior | Partial: adapted counters/restart | Preserve original scoring and all game-over/continue state transitions |
| Title/menu modes, original player modes | Partial: one title and single-player campaign | Preserve mode selection (`bank7:F7B1–F7F7`) and distinct gameplay paths |
| Intro, demonstration, transitions and ending | Partial: static title/victory messages | Run original scripted sequences and final progression |
| Two-action-button input semantics | Partial: direction + one button | Map original input without losing independent movement/action combinations |
| Simulation and animation cadence | Partial: custom 30 Hz update | Verify source cadence and PAL/NTSC behavior through frame comparisons |
| Sound effects and soundtrack | Partial: short POKEY effects; music disabled | Effects need a native backend; existing project target explicitly omits music |

The weapon rows are behavior requirements, not a verified item-ID catalogue.
Exact item identities, spawn IDs, damage values and action gates still need
source-backed fixtures. The checklist must not be used to imply those audits
or original campaign playthroughs have already happened.

## Implementation order and current progress

1. **Original terrain queries — native component implemented and tested.**
   `tools/build_source_terrain.py` relocates the original boundary, support and
   wall routines, including their original data. See
   [source-engine/TERRAIN.md](source-engine/TERRAIN.md). This does not yet add
   terrain to the playable XEX.
2. **Full native engine memory and platform integration — pending.** Preserve
   bank switching, RAM, indirect/computed addresses, input and frame barriers.
   The adapted campaign cannot safely substitute its room/camera coordinates
   for the original engine's terrain coordinates.
3. **Terrain dispatcher, pose probes, climbing, falling and hazards — pending.**
   Connect the verified queries to original object state and room rendering;
   test movement, recoil and thrown-object paths, not only player walking.
4. **Weapons and combat — pending.** Port ownership and full action/hit state
   machines together, then check individual weapon/move cases against source
   execution. Add progression gates before calling moves complete.
5. **Campaign, roster, bosses, player modes and sequences — pending.** Preserve
   all sections and scripts; complete original-game playthroughs.
6. **Graphics, input, timing, HUD and effects parity — pending.** Verify the
   completed native game in Altirra and compare source/Atari frame traces.

No missing feature above is marked complete in the playable XEX. The original
launcher should only switch to the full-source executable once that executable
exists and its native integration has been verified.
