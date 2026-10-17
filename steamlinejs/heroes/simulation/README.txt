CURRENT VERSION: see ../NATIVE-V3.txt. The active editor/native preset now includes
monster abilities, permanent casualties, paid replacements and the former Cavalry/Demon/practice candidate. The notes below
describe the earlier v2 benchmark and are retained for historical comparisons.

Greenhaven stats-only gameplay simulator

Requires Node.js 18 or newer. No packages, browser, renderer or emulator needed.
Run from the heroes directory:

  node simulation/run.cjs --seeds 200 --output simulation/results
  node simulation/trace.cjs --strategy mixed --seed 2 --output mixed-seed2.json
  node simulation/trace.cjs --strategy mounted --seed 1 --candidate cavalry --output mounted-candidate.json
  node simulation/check-formations.cjs > formations.json
  node tests/campaign-sim.test.cjs

The first command runs all balance experiments and writes summary JSON/CSV,
per-seed results and detailed example traces. --only accepts comma-separated
experiment IDs to run a subset. --config selects another editor JSON export.
trace.cjs writes a single audit trace including every purchase, building/fighter
upgrade, battle, movement step, attack, summon and remaining gold.
Strategies: infantry, ranged, mounted, casters, mixed.
Candidate modes: none (current editor), practice (opening replay plus Demon HP3),
cavalry (practice plus Cavalry damage3). Candidate mode modifies a copy only.

Open unit-editor.html and scroll to Stats-only gameplay simulation to run this
same model against the current unsaved editor draft. Run one campaign shows the
complete trace. Comparison checks the current draft versus the cavalry
candidate. Export simulation JSON preserves input values, settings and results.

Model:
- Current editor data: starting gold50, two Spearmen, level2 Barracks, capacity3.
- Four sequential region gates, configured victory thresholds and seeded groups.
- Individual fighters on the 7x6 odd-row hex board; fixed obstacles10 and31.
- Trees block shooting; living units block movement, not shooting.
- Player phase then enemy phase. Player bot activates fighters in army-slot order,
  chooses legal positions with pathfinding, and prioritizes kills and Warlock.
- One AP per step; using all AP ends the turn. An attack ends the turn. No armor,
  retaliation, random damage, healing or unimplemented spell abilities.
- Enemy movement follows the current native greedy-nearest-hero rule, including
  deterministic tie order. A separate experiment gives enemies pathfinding.
- Warlock summons a Demon within3 instead of shooting; newly summoned fighters
  can act that phase. Total allocated slots12; dead slots are not reused.
  Killing Warlock immediately wins even when escorts survive.
- Five predetermined shopping plans. Purchases do not inspect the next enemy
  group. Buildings bought sequentially; recruits use the highest unlocked tier;
  slot capacity and upgrade-difference prices are enforced. No selling or
  changing strategy mid-campaign is modeled.
- Troops recover fully after every battle; no permanent casualties or replacements.
- Defeat gives no reward/progress. Baseline bot retreats to replay the previous
  cleared region when possible. A replay victory advances the global encounter
  seed, so returning later can produce a different group. Immediate retries with
  unchanged state reproduce the same group. No free rerolls or forced victories.
- Early-practice experiment permits replay of the already-won first Forest stage
  for20 gold, without victory credit, at any later point in the campaign.
- Bounded at45 fights and60 rounds per battle. The bot also stops after repeated
  losses against the same group once all its planned upgrades are exhausted.

Limits:
This is an independent JavaScript rules model, not execution of the native game.
Geometry/line-of-sight are checked against all1764 compiled native table entries.
Unit/economy, movement/AP, summoning and campaign invariants have focused tests.
This does not establish full native-engine parity or hardware correctness.
Reported completion percentages are frequencies for fixed bots across seeded
encounter rosters, not human win probabilities. Seeds reuse a small authored
pool, so these are not independent human playtests. Fixed activation order,
objective targeting, lack of selling/replanning and enemy pathfinding can affect
outcomes strongly. A failed purchase strategy does not prove an unrecoverable
save or an unwinnable human encounter.

The current editor preset and native content are kept unchanged by experiments.
Candidate JSON includes simulationSettings; these are simulator settings and
are not understood by the native importer or the editor's progression preview.
Any recommendation needs native implementation and human playtesting.

Tests require the full project checkout, including the generated native table and
standalone editor. The script bundle contains everything needed for headless
campaign runs; the report generator uses Python3 and its standard library.
