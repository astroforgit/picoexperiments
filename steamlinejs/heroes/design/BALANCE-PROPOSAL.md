# Greenhaven single-fighter balance proposal

9 September 2026 — original design proposal, not a record of implemented rules.

**User correction:** repeated individual units are allowed on both sides,
including five soldiers. All one-per-family/type restrictions below are superseded.
The integrated city battle now implements an initial subset using the old turn
structure; see [current rules](../atari/city/README.md). The complete abilities,
normal-start economy and balance targets here remain proposals.

The source inventory is in [UNIT-INVENTORY.md](UNIT-INVENTORY.md), with full
extracted records in [unit-inventory.json](unit-inventory.json). This proposal
supersedes the army, combat and economy suggestions in the older
[PROJECT-PLAN.md](../PROJECT-PLAN.md); the current city implementation already
supersedes that document's automatic recruitment and fixed building-slot mapping.

## Recommended shape

Keep five individual player fighters and normally two to five distinct enemy
fighters on the existing 7×6 hex battlefield. Preserve the five city upgrade
families and build twelve authored battles across the four hostile locations.
Use OpenBounty's roles and selected abilities, the existing Atari battle's small
board and readable controls, and the city's separate building/recruitment economy.

Army size is limited to **five individuals per side**, with no uniqueness rule.
Militia, Guard and Knight can coexist, and all five slots may hold the same type.
Upgrading changes only the selected fighter. Encounter difficulty can use repeated
soldiers or monsters, but counts must never become stack multipliers. Re-test
five-archer, five-tank and five-healer parties before adopting the economy and
ability values below: the earlier mixed-family balance assumption no longer holds.

The source roster is a reference library, not a requirement to ship all 25
OpenBounty troops. Peasants, Sprites, Gnomes, Elves, Pikemen, Nomads, Dwarves,
Barbarians, Cavalry, Druids and Archmages can inspire later alternative recruits.
Adding all of them now would require more buildings or a replacement-choice
system and would make the first campaign harder to balance. Keep the current
15 player tiers and the 16 enemy candidates below; Dragon is reserved for an
optional later encounter, leaving 15 enemy types in the twelve-battle campaign.

## Why more HP helps, and what it cannot fix

The old Atari Knight has 5 HP and 2 damage; the current city Knight has 13 HP
and 4 damage. These are different prototype tables, not a shared balance model.
OpenBounty's 35-HP Knight and 200-HP Dragon are balanced around creature counts,
skill modifiers, leadership and stack casualties. Copying those values with
count=1 would make many cheap units irrelevant.

Use **attacks to defeat a unit**, effective actions per round and positioning as
the main measures. Multiplying HP and damage by the same factor barely changes
battle length. Raising HP alone gives tactics time to matter, but too much
creates slow fights and makes unlimited healing unbeatable.

Starting targets, to measure in tests:

- A frontline fighter survives roughly 4–6 ordinary direct hits from a peer;
  ranged/support troops usually survive 3–4. Retaliation and focus fire shorten
  their actual lifetime.
- Ordinary fights take approximately 5–9 rounds including approach; bosses 7–11.
  Aim for about 3–6 minutes with animation, then measure on the real interface.
- Same-tier upgrades improve durability and damage moderately. A third fighter
  should usually be more useful than rushing a second-tier upgrade on one of two
  fighters: another unit brings another activation and target to protect.
- A large boss needs a few distinct allies or an announced special action.
  Extra HP alone does not compensate for five player activations against one.

Examples with the proposed physical damage rule: a 7-damage attack deals 6 to
Militia's armor 1, so 32 HP takes six hits; a 14-damage attack deals 11 to Knight's
armor 3, so 60 HP also takes six. A 22-HP unarmored Hunter takes four hits of 7.
These are arithmetic examples, not simulated win-rate evidence.

## Exact baseline combat rules

Use these same rules for player and enemy fighters unless an ability explicitly
says otherwise. These are planned changes to the old battle engine.

1. **Round order:** alternate one player activation and one enemy activation.
   Player chooses any unacted fighter; enemy AI chooses one unacted fighter.
   Player starts each round. When one side runs out of unacted units, the other
   finishes. Reset acted and retaliation flags at the next round. No initiative
   stat, morale, critical hits, misses or random damage in version one.
2. **Activation:** move up to Move hexes, then attack, use one ability, defend or
   finish. Acting ends the activation; no move after attacking. Movement may stop
   early. This deliberately replaces the old move-two-or-move-one-and-attack
   rule and must be taught in the HUD.
3. **Damage:** physical `max(1, Attack - Armor)`; magic ignores Armor. Apply
   special flat reductions after this and clamp to at least 1. Clamp HP at zero.
   A wounded fighter retains full Attack until defeated; no hidden stack count.
4. **Ranged attacks:** Range is hex distance, inclusive. For units with Range>1,
   any adjacent living enemy forces an adjacent attack at `floor(Attack/2)`
   before armor, using the normal damage kind. They cannot shoot elsewhere while
   engaged. No long-range penalty. Basic attacks are unlimited except Giant's
   three boulders. Show the exact predicted damage before confirmation.
5. **Retaliation:** a surviving defender counterattacks once per round after an
   adjacent basic attack, for half its effective adjacent Attack rounded down,
   minimum 1 before armor. An engaged ranged defender's effective adjacent Attack
   is already halved. No retaliation to distant shots or active abilities; a
   retaliation never causes another retaliation or on-hit ability. Defeated
   units never retaliate. Low numbers keep melee from becoming suicidal.
6. **Defend:** ends activation, adds 2 Armor until that unit's next activation
   begins. It does not reduce magic damage. A unit may instead finish with no
   action. Healing/burst attacks also consume the action; never grant free heals.
7. **Terrain:** trees and pillars block movement and attacks through them;
   occupancy blocks movement but not shots. Precompute symmetric hex line-of-sight
   masks; if a shot passes exactly between two hexes, either blocking hex blocks
   it. Flying/phase units may cross obstacles and occupied cells but must land
   on a free, non-obstacle cell within Move distance. They do not ignore attack LOS.
8. **Recovery:** restore all recruited fighters to full HP after victory, defeat
   or retreat, including those knocked out. Combat casualties do not dismiss
   campaign units. Loss/retreat pays nothing and adds no progress. This is the
   recommended first mode; permanent death would require a separate economy pass.
9. **Win/loss:** defeat every living enemy to win; loss when all player fighters
   are knocked out. If the last enemy dies, resolve victory immediately, before
   future summon triggers. Commit rewards once per completed battle instance.

Armor, alternate activations, abilities, LOS and recovery are not all implemented
in the old prototype. Treat this list as the rules contract for the balance tests.

## Player roster: proposed complete battle statistics

Attack is the basic attack; all Range-1 attacks are melee. P=physical, M=magic.
An ability is in addition to these stats but consumes the normal action unless
marked passive. Recruit gold preserves the current city prices. Unit upgrades
cost the next tier's recruit price minus the current price.

| Building | Tier/unit | HP | Attack/kind | Armor | Move | Range | Recruit gold | Ability |
|---|---|---:|---|---:|---:|---:|---:|---|
| Barracks | 1 Militia | 32 | 7 P | 1 | 2 | 1 | 50 | — |
| Barracks | 2 Guard | 42 | 9 P | 2 | 2 | 1 | 100 | Shield |
| Barracks | 3 Knight | 60 | 12 P | 3 | 2 | 1 | 180 | Shield |
| Archery | 1 Hunter | 22 | 7 P | 0 | 2 | 3 | 50 | — |
| Archery | 2 Archer | 30 | 9 P | 0 | 2 | 3 | 100 | Aimed shot 12, twice |
| Archery | 3 Marksman | 40 | 12 P | 1 | 2 | 3 | 180 | Aimed shot 16, twice |
| Lodge | 1 Scout | 28 | 6 P | 0 | 3 | 1 | 75 | — |
| Lodge | 2 Ranger | 38 | 8 P | 1 | 3 | 1 | 140 | Snare, twice |
| Lodge | 3 Beastmaster | 50 | 11 P | 1 | 3 | 1 | 230 | Snare, twice |
| Chapel | 1 Acolyte | 24 | 4 M | 0 | 2 | 1 | 90 | Heal 8, twice |
| Chapel | 2 Healer | 32 | 5 M | 0 | 2 | 1 | 160 | Heal 12, three times |
| Chapel | 3 Priest | 44 | 7 M | 1 | 2 | 1 | 250 | Heal 16, three times |
| Tower | 1 Apprentice | 20 | 6 M | 0 | 2 | 3 | 110 | Burst 9, twice |
| Tower | 2 Mage | 28 | 8 M | 0 | 2 | 3 | 200 | Burst 12, twice |
| Tower | 3 Wizard | 38 | 10 M | 0 | 2 | 3 | 320 | Burst 15, twice |

Precise abilities:

- **Shield:** passive, reduce physical ranged damage received by a further 2,
  including aimed shots/boulders; minimum 1. Does not protect against magic.
- **Aimed shot:** replace the basic Attack with the listed value for one physical
  ranged hit. Range 3, normal LOS, unusable while engaged. Two charges per battle.
- **Snare:** replace the basic attack with a range-2 ability doing 4 physical
  damage for Ranger or 6 for Beastmaster, then cap target Move at 1 for its next
  activation. Normal LOS. No stacking; after the affected activation it expires.
  Flying units are affected too. It never removes the target's action.
- **Heal:** restore the listed HP to self or a living ally within 2 hexes with
  LOS, capped at maximum. Does not revive. All charges refresh next battle.
- **Burst:** one magic hit at Range 3 with LOS, using the listed damage. Cannot
  be used while engaged. Two charges per battle.

Beastmaster does not summon an extra army unit in this version; its role is fast
control. This preserves the five-slot limit. Reconsider that name or add a pet
animation later if players reasonably expect a summon.

## Enemy roster: proposed complete battle statistics

Enemy prices are not needed: enemies cannot be recruited, and rewards belong to
encounters rather than individual kills. Armor defaults are explicit below.
All abilities obey the same targeting, charge and retaliation rules above.

| Enemy | Inspiration | HP | Attack/kind | Armor | Move | Range | Special rule |
|---|---|---:|---|---:|---:|---:|---|
| Minibeast | Lowrez/Atari | 22 | 5 P | 0 | 2 | 1 | — |
| Wolf | OpenBounty | 20 | 6 P | 0 | 3 | 1 | — |
| Bat | Lowrez/Atari | 14 | 4 P | 0 | 3 | 1 | Flight |
| Skeleton warrior | Both | 28 | 6 P | 1 | 2 | 1 | Undead identity |
| Zombie | OpenBounty | 38 | 7 P | 0 | 1 | 1 | Undead identity |
| Skeleton archer | Atari reconstruction | 22 | 7 P | 0 | 2 | 3 | Undead identity |
| Ghost | OpenBounty | 26 | 6 M | 0 | 2 | 1 | Phase movement, undead |
| Vampire | OpenBounty | 46 | 10 P | 1 | 2 | 1 | Flight, drain 3, undead |
| Orc | OpenBounty | 34 | 8 P | 1 | 2 | 3 | Ordinary ranged attack; engaged penalty |
| Ogre | Both | 56 | 11 P | 1 | 1 | 1 | — |
| Troll | OpenBounty | 58 | 10 P | 1 | 1 | 1 | Regenerate 4, at most three times |
| Giant | OpenBounty | 76 | 14 P | 2 | 2 | 3 | Three boulders; full melee Attack 14 |
| Imp | Lowrez/Atari | 20 | 6 P | 0 | 3 | 1 | — |
| Warlock | Lowrez/Atari | 52 | 10 M | 1 | 2 | 3 | Summon one Imp, once per battle |
| Demon | OpenBounty | 68 | 13 P | 2 | 2 | 1 | Flight; Cleave, twice |
| Dragon (reserve) | OpenBounty | 110 | 16 P | 3 | 2 | 1 | Flight; Breath, twice |

- **Undead:** a descriptive family tag only in this first ruleset. No unlisted
  immunity, healing restriction or hidden damage bonus.
- **Phase/Flight:** movement rules above; Ghost's phase is a proposed adaptation,
  not a claim that OpenBounty gives it FLY.
- **Drain:** Vampire heals up to 3, capped by actual HP removed, after its own
  successful basic attack. Never heals from retaliation or beyond maximum HP.
- **Regenerate:** at the start of Troll's activation, heal up to 4 if wounded,
  consuming one of three charges. No charge is spent at full HP. No regeneration
  after death; no full heal every round as in a literal stack conversion.
- **Boulders:** Giant may use Attack 14 at Range 3 three times. Each distant
  attack consumes one charge. Adjacent attacks use full 14 without consuming a
  charge; with no ammunition it is melee-only. This is the explicit exception
  to the engaged ranged penalty.
- **Summon:** from round 2 onward, Warlock can spend its activation to create one
  Imp on an adjacent legal empty hex. It cannot do this while any friendly Imp
  is alive, at the five-enemy limit, or with no space. Charge is consumed only
  on success. Summoned Imp is marked acted until the following round. Warlock
  can never summon again after success, even after that Imp dies. This prevents
  an endless battle and repeated copies.
- **Cleave:** replace the attack with 13 physical damage to an adjacent target
  and 5 to one other enemy adjacent to Demon. Two charges; no retaliation or
  drain triggers. Only the primary target is required. Preview both hits.
- **Breath:** reserve ability: replace attack with 14 magic damage along a
  straight two-hex ray, hitting enemies only, stopping at blocking terrain.
  Two charges, no retaliation. Dragon has no blanket magic immunity.

Do not add stack-count effects such as Ghost absorption or Demon's half-stack
kill. The finite drain, regeneration and cleave above preserve recognizable
roles without arbitrary one-shot kills or additional fighters.

## Twelve authored encounters

Each region has three distinct contracts. Defeating its next contract advances
that region once; replaying a completed contract cannot advance progression.
Three first-time wins complete the region and unlock the next entrance on the
same map. Names inside each cell below mean exactly **one of each**.

Recommended army is guidance for tuning, not a hard entry condition. Only region
prerequisites lock entrances. An empty army cannot enter battle.

| ID | Region / contract | Enemies | Intended player army | First win gold |
|---|---|---|---|---:|
| F1 | Dark Forest / Strange tracks | Minibeast | 2 tier-1; easy tutorial | 70 |
| F2 | Dark Forest / Hunting ground | Minibeast, Wolf | 2 tier-1 | 80 |
| F3 | Dark Forest / Black canopy | Minibeast, Wolf, Bat | 3 tier-1 | 100 |
| C1 | Catacombs / Broken crypt | Skeleton warrior, Zombie | 3 tier-1 | 120 |
| C2 | Catacombs / Whispering vault | Zombie, Skeleton archer, Ghost | 3–4 mixed tier-1/2 | 140 |
| C3 | Catacombs / Blood chapel | Vampire, Skeleton warrior, Skeleton archer, Zombie | 4 mixed tier-1/2 | 180 |
| M1 | Monster Caves / Bone tunnel | Orc, Ogre, Bat | 4 mixed tier-1/2 | 220 |
| M2 | Monster Caves / Troll hollow | Orc, Troll, Ghost | 4–5 mixed tier-1/2 | 260 |
| M3 | Monster Caves / Giant's den | Giant, Ogre, Orc | 5: 3 tier-2 + 2 tier-1 | 320 |
| N1 | Necromancer Ruins / Soul lanterns | Warlock, Skeleton archer, Ghost; one summoned Imp | 5 tier-2 | 350 |
| N2 | Necromancer Ruins / Demon court | Demon, Vampire, Troll, Skeleton archer | 5 mixed tier-2/3 | 450 |
| N3 | Necromancer Ruins / Warlock's throne | Warlock, Demon, Vampire; one summoned Imp | 5; about 2 tier-3 and 3 tier-2 | 650 |

One-time region completion bonuses: Forest 100, Catacombs 160, Caves 240,
Ruins 500. Total first-clear rewards including bonuses: **3,940 gold**.
Cleared-contract practice rewards: Forest 25, Catacombs 40, Caves 65, Ruins 90;
no repeat completion bonus. Rewards are per victory, never multiplied by kills
or summons. Replays are optional catch-up, not the intended main income.

Battlefield layout prescription, to author into exact cells in the implementation:

- Player deployment uses the five hexes at column 0, rows 0–4; choose slot order
  before battle. Enemy deployment uses column 6, spreading melee near the center
  and ranged enemies toward opposite edges. Do not auto-place archers forward.
- Forest: 3–5 blocked tree hexes in the central columns with at least two routes.
  F1 starts the Minibeast at (4,2) to shorten the tutorial approach.
- Catacombs: 4–6 central pillars; never a single sealed choke that a player can
  occupy forever. C3 gives the Vampire a route toward the back row.
- Caves: 3–5 rocks, one broad center lane and two side approaches; Giant has a
  clear but avoidable firing lane. Avoid free opening shots into starting cells.
- Ruins: 2–4 broken pillars and enough space around Warlock for a legal summon;
  show the summon warning before round 2. No unavoidable opening area damage.
- Validate all starts as distinct, open and connected; verify ranged lanes and
  escape paths. Exact obstacle coordinates and activation AI must be tested with
  the proposed stats before claiming encounter balance.

Do not implement hidden HP scaling based on the player's army. Unlock information,
enemy portraits, full stats and the exact reward should be visible before entry.
If a fight is too hard, players can make an informed city upgrade or practice choice.

## Economy and progression audit

Keep the existing building prices initially:

| Building | Build tier 1 | Upgrade to 2 | Upgrade to 3 |
|---|---:|---:|---:|
| Barracks | 100 | 120 | 240 |
| Archery | 100 | 120 | 240 |
| Lodge | 150 | 180 | 280 |
| Chapel | 180 | 200 | 300 |
| Tower | 220 | 240 | 340 |

Normal campaign starts with tier-1 Barracks and Archery, one Militia and one
Hunter, and **150 spendable gold**. These starter buildings/troops have 300 gold
of value. Keep today's empty/60,000-gold mode as a separate debug preset.
All tier-1 buildings are available initially. Tier 2 unlocks after F3; tier 3
after M3. These are additional progress checks on both UI and transaction code.
Units can only upgrade as far as their own building has unlocked.

Arithmetic using current costs:

- All buildings through tier 3: 3,010 gold. Five final-tier troops: 1,160 gold.
  Total final roster investment: **4,170**. Incremental unit upgrades sum to the
  same final troop price; there is no double recruitment charge.
- Starter asset value + starting gold + all unique victory rewards:
  `300 + 150 + 3,940 = 4,390`. Full campaign completion can fund all upgrades
  with 220 left, without replays if there are no dismissals.
- Before the final battle, rewards earned are 2,790; with starter assets and
  gold the budget is 3,240. All five tier-2 families cost 2,310, leaving 930:
  enough for two final upgrades, such as Knight (320) and Marksman (320).
  The final battle must therefore be tested against mixed tiers, not five tier-3s.
- By the end of Caves the total available investment is 2,440, enough to field
  all five tier-2 families at 2,310. **Before M3** it is only 1,880: tune M3 for
  three tier-2s plus two tier-1s or another affordable mixed roster, rather than
  requiring five tier-2s. Its reward/bonus funds completion of that tier.
- Starter 150 + F1/F2 rewards 150 can pay 225 for Lodge + Scout before F3.
  This is the intended first lesson: expand the army before rushing power.

The encounter table's approximate tier labels are goals; these budget constraints
are authoritative when selecting test parties. In particular M3 must use the
pre-win budget above. Never use a battle's own reward to justify entry strength.

Dismissal refunds half the unit's current recruit price, rounded down, matching
the current implementation. Buildings remain. Defeated fighters recover for
free; no upkeep, healing bill or paid resurrection in the first campaign.
If the player voluntarily dismisses the last fighter and spends the money, allow
one **free Militia replacement when the army is completely empty**, requiring the
starter Barracks. Mark that rescued unit's refund value zero; upgrading it requires
paying the full target troop price, clearing that flag. This planned exception
needs a saved flag and explicit tests so rescue/dismiss loops cannot generate gold.
Do not ship an economy where an empty army and zero gold is an unrecoverable save.

## Balance validation and implementation plan

1. Create one versioned content catalog for player/enemy stats, prices, ability
   parameters and twelve encounters. Generate web and MADS tables from it. Keep
   the extracted source inventory separate from the proposed catalog.
2. Integrate campaign `army_units` into battle deployment. Add family IDs,
   Armor, damage kind, charge counters and original/max HP; implement the common
   rules above in the web simulator first. Remove hard-coded Knight/Archer starts
   and repeated enemy spawns. Keep existing Atari 12-slot capacity but enforce
   five living units per side; reuse dead slots safely and cap battle summons.
3. Author exact cell layouts and an explicit AI: prioritize lethal attacks,
   then high damage; retreat casters from engagement where legal; use healing
   only with sufficient missing HP; do not waste charge abilities. Use stable
   tie-breaking so replays are reproducible. Add randomness to layouts only later.
4. Test affordable parties at each pre-battle budget, including damage-heavy,
   healer-heavy and delayed-Tower builds, plus under-equipped challenge parties.
   For each use several deployment orders and tactical policies. Vary obstacle
   layouts only through validated authored alternatives.
5. Record win/loss, rounds, survivors, remaining HP, damage/healing per ability,
   opening-turn kills, lost activations, charge use and purchases needed. Avoid
   reporting a deterministic single-policy result as a general win probability.
   A target could be 75–90% wins for sensible affordable parties over the defined
   scenario/policy suite, with the finale harder; that is a tuning target, not
   evidence. Also test with a human, including on joystick controls.
6. Correct bad encounters through composition, terrain and announced abilities
   before raising HP. Limit ordinary fights exceeding 12 rounds; investigate
   any unkillable regeneration, caster kiting or first-round wipe. Healer should
   improve survival but not be compulsory; no single purchase path should be
   mandatory. Re-run the budget audit after every cost/reward change.
7. Port validated rules to 6502 and compare identical action traces against web
   outcomes: HP, effects, gold, unique families, results and charge use. Verify
   both VBXE register pages and real emulator timing. Add bounded event queues
   sized for area hits and retaliation, rather than silently dropping events.
8. Add versioned between-battle saves, an atomic one-time result commit and a
   normal/debug start selector. Then play the complete campaign from normal
   starting resources, without debug money or manual state changes.

All proposed HP values fit in a byte (maximum 110), as do normal damage, armor,
range and charge counts. Keep damage intermediates wide enough for modifiers,
use saturating HP arithmetic, and retain 16-bit saturating gold. The current city
popup draws only one damage digit and two HP digits: update numeric formatting
before loading this roster, especially 10+ damage and the Dragon's 110 HP.
The existing battle's fixed memory regions and art loader also need a deliberate
merge with the city's VRAM layout; extra unit portraits are not battlefield
animations. Reuse current art for the first tested slice, then author missing
combat sprites for the new enemy families.

Recommended first deliverable: F1–F3 with Militia, Hunter and Scout, no special
abilities beyond flight and common retaliation. Validate control feel and battle
length there, then add Catacombs/healing, Caves/regeneration and finally summons
and area attacks. No game stats or executable are changed by this proposal.
