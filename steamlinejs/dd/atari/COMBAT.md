# Combat rebalance

This changes the playable `double-dragon-vbxe.xex`, not just the source-port
reference runner. It is still an adaptation, not the original engine's exact
AI or damage system. The complete source port remains separate work.

The old enemies took one horizontal step every other simulation tick, chased
the same depth coordinate, hit immediately on contact and always dealt one
damage. Entire jumps were invulnerable, so repeated jump kicks cleared the
campaign with little risk. Ordinary enemies started with only three health.

## Enemy decisions

All enemies now approach on separate depth lanes, commit to an attack direction
during a visible windup, strike once, then recover. A hit requires Billy to
remain in front, in range and within eight pixels of depth at impact time.
Moving out of the lane or behind the attacker makes it miss.

One enemy approaches Billy's left side via an offset depth lane, with an edge
fallback. Williams sometimes guards an approaching frontal swing; punches
are blocked, grounded kicks do one chip damage, and jumping kicks break the
guard. Rear hits bypass it. Linda sometimes sidesteps a visible swing instead.
Abobo keeps approaching, moves more slowly, and recovers from hit stun sooner.
The decisions use a deterministic LFSR, not knowledge of future input.

Each enemy gets at most one defensive decision per swing once eligible, rather
than rerolling every tick of the windup. Guards last through the current move's
impact plus two ticks, so a long kick no longer outlasts the guard accidentally.
A blocked punch earns Williams a counterattack after that guard ends, using his
full five-tick windup. He only starts it if Billy is still in front, in range
and in the same depth lane. Leaving the lane or crossing behind can avoid it;
an interrupted guard loses its counter. A guard without contact earns none.

All times below are at the existing 30 Hz simulation rate:

| Enemy | Windup | Recovery | Hit damage | Endurance by stage |
|---|---:|---:|---:|---|
| Williams | 5 ticks | 13 ticks | 2 | 8 / 12 / 16 / 20 |
| Linda | 7 ticks | 16 ticks | 2 | 8 / 12 / 16 / 20 |
| Abobo | 9 ticks | 20 ticks | 5 | 32 / 38 / 38 / 38 |

The recovery column is for connecting strikes. A miss (including an evaded or
immune hit) adds six ticks: 19/22/26. Enemies cannot move, defend or attack
during recovery, leaving Billy a longer opening after baiting a swing.

Billy retains 12 health and three lives. Hits cancel his attack and jump,
briefly stun him and knock him back without wrapping at a screen edge. Damage
saturates at zero. A lethal hit stops enemy processing for that tick so the next
enemy cannot hit a freshly respawned life immediately.

Punch/kick/jump-kick damage is 1/2/3, with reach 30/38/42 pixels and attack
duration 12/16/16 ticks. A jump permits one attack. Its high portion evades
ground strikes, but launch and landing do not; landing adds eight ticks before
another jump. Grounded-attack hit stun lasts seven ticks; Abobo's lasts three.

Surviving jump-kick hits knock all three enemy types down: six ticks of recoil
(12 pixels, clamped to screen bounds), 22 ticks prone, then ten ticks getting
up. Movement and attacks are disabled throughout; additional hits are ignored
until recovery completes. Knockdown cancels a committed strike or guard.
The prone sprites come from source bank 3 records $9400/$9BD4/$ACFE;
getting up reuses an upright pose to stay within the existing sprite budget.
These timings are adaptation tuning, not cycle-exact original behavior.
Lethal hits still remove the enemy immediately and count toward wave completion.

## Adapted grab-and-throw

Down + fire selects a new 18-tick action. At its start, it captures the nearest
living Williams/Linda within 18 pixels horizontally and eight in depth, in
front of Billy, provided the target is stunned or in attack recovery. Guards,
ready attackers, fallen enemies and Abobo are excluded. Only one target is held.
Ten ticks later the throw deals four damage and places a survivor behind Billy,
using the existing knockdown/recovery sequence with bounded recoil. A lethal
throw counts once toward the wave. Missed grabs still consume the action.

The hold grants Billy no immunity. An enemy hit or loss of a life releases the
target into recovery and cancels the throw; wave/restart setup clears ownership.
The current implementation reuses poses and does not throw enemies into other
enemies, add grapple strikes, or reproduce original experience unlocks.
This is a newly written adaptation mechanic, not a recovered source-engine port.

## Original-source comparison

Additional inspection of bank 6: $8950 checks player action `$03A8` and distance
`$03E4,X` before selecting an enemy substate in `$0430,X`. $8A0A combines
player action, facing checks and two separation thresholds (`$03EC,X < 6`,
`$03E4,X < $22`) in its decision path. This supports state- and position-aware
decisions, not an unconditional contact attack. The guard counter, single-roll
reaction rule and six-tick miss penalty here are explicit adaptation choices;
these routines do not establish those exact rules or durations in the original.

The supplied bank 6 at $8000 dispatches enemy action states through the table
at $805C. It is not a single chase/contact loop. Spawn setup at $924C and the
health table at $9389 distinguish enemy types. The Williams, Linda and Abobo
rows supply the endurance tiers used above. Applying those tiers by stage here
is adaptation tuning, not a claim that every source-engine spawn has that HP.

Source bank 4 at $AFEF–$B094 selects move-specific hit records and queues
damage in `$03D0,X`; $AA6F subtracts that damage from `$03B4,X`, saturating at
zero. The source initializes the single-player hero to $40 health at bank 6
$99EF. This build keeps its 12-point HUD and uses deliberately stronger
adapted enemy damage instead of claiming numerical parity with that system.
Weapons, original grapple/throw rules, experience unlocks and original enemy state machines
still require the full-source port. Background music is disabled; short POKEY
combat effects are enabled again.

## Checks

```sh
bash build.sh
python3 tools/test_combat.py
python3 tools/test_runtime.py
```

The checks execute the assembled Atari code, including grab ownership, throw
timing, interruption, screen-edge limits, lethal throws, attack commitment,
misses, species damage, guard direction, Linda's sidestep, flanking, vulnerable
jump phases, landing recovery, lethal damage, respawn and game over. The old
jump-kick bot is retained as an exploit regression. World progression is
checked separately with explicit combat fixtures, not reported as a playthrough.
