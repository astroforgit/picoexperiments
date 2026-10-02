# Milestone 1: flock, pursuit, lives, and water

Checkpoint before implementation: `53f280f`.

## Research basis

The 2002 original combines sheep moods and repeated interaction with a shepherd,
a pursuing dog, lives, water escapes, and bonuses. References reviewed before
implementation:

- [Historical Sven 1 guide](https://www.scheer-halle.de/sp/sv1_tip.htm): mood symbols, interaction and level time.
- [June 2002 review](https://www.sk.rs/2002/06/sitf01.html): pursuit/rest, water relocation and additional mechanics.
- [Original-game publisher listing](https://mut.de/products/sven-bomwollen-das-original-download): sheep moods, enemies and water escape.

This build recreates the first core loop with progress indicators and the existing
five-frame love scene. Enemy contact plays the battle cloud at the collision
site for 42 ticks (0.84 seconds), including on the final-life game-over screen. It does not claim original timing, AI, scoring, or sprite accuracy
for the newly drawn enemies.

## Implemented rules and tuning

| Rule | Value / behavior |
| --- | --- |
| Flock | Eight sheep; completed sheep remain removed until restart |
| Starting clock | 90 seconds; cap 99 |
| Starting lives | Three |
| Mood age | Sunny below 20 seconds, cloudy from 20, storm from 40; cap 60 |
| Initial ages | 0, 4, 8, 2, 12, 6, 14, 10 seconds, creating different urgency |
| Interaction range | 18 horizontal / 12 vertical pixels from sprite anchor |
| Interaction | Hold fire while stationary; four segments, 16 sunny or 24 cloudy ticks per segment |
| Partial progress | Completed segments persist; incomplete segment resets when leaving/releasing |
| Storm sheep | Cannot be helped until calmed; contact costs one life |
| Whistle | Two fire presses within 15 simulation ticks; calms within 69×41 axis distances by 24 mood seconds |
| Whistle cooldown | 100 simulation ticks (two seconds) |
| Dog | Pursues for 100 ticks, rests for 50; up to 25 horizontal / 12.5 vertical pixels per second |
| Shepherd | Four-point patrol, up to 25 horizontal / 12.5 vertical pixels per second |
| Hit | Lose one life; safe relocation; 20-tick stun and 100-tick protection |
| Water | Relocation, no lost life, 50-tick protection and re-entry cooldown |
| Reward | 25 points and two seconds per sheep; 200 points for the flock |

All simulation ticks are 1/50 second on PAL and NTSC. Water checks the actor's
feet against an 8 KB bit mask derived from blue pixels in the supplied meadow.
Safe respawn candidates are checked against both enemies. Enemy movement is
depth-sorted with the sheep and Sven; icons are drawn afterward for readability.

## Files

- `game.asm`: original clock/control/state shell, now calling milestone routines.
- `milestone.asm`: sheep age/progress, enemies, collision, lives, safe spawn, water, whistle.
- `renderer.asm`: eleven actors sorted by baseline, icons, lives/time/points HUD.
- `tools/make_assets.py`: original artwork conversion, generated enemy atlas slicing,
  code-defined icons, and water mask.
- `tools/test_runtime.py`: mechanics and stress coverage for both register pages/video rates.
- `tools/test_playthrough.py`: complete play using only joystick/fire writes, with
  enemies and all rules active; the observer reads positions but never edits game state.
- `assets/README.md`: artwork provenance and exact built-in imagegen prompt.

## Findings during implementation

The first blue-color threshold excluded the shoreline's pale water. The mask was
corrected and now has upper-puddle, lower-puddle, and shoreline regression cases.
The initial dog moved horizontally twice as fast as intended relative to its
vertical speed, making repeated hits too frequent. Correcting this produced
successful full playthroughs with two lives left on both PAL and NTSC timing.
The observer route takes about 16 seconds; actual player skill and routing vary.

Original sequel features, new worlds, mushrooms, UFO encounters, and soundtrack
reconstruction are intentionally deferred to later milestones.

## Living sheep update

Each sheep walks one pixel every eight simulation ticks, with a distinct phase
and a maximum 12-pixel horizontal / 8-pixel vertical distance from its home.
Water and screen bounds reject movement. Within 28 horizontal / 20 vertical
pixels of Sven, sheep stand still and face him along the dominant axis. Whistle
reactions last 75 ticks: affected live sheep stop, face Sven, and show a heart
above their unchanged progress bar. Completed sheep do not react or wander.
Directional love scenes use all 20 existing workshop frames. This update does
not change enemy speed, lives, score or interaction duration.

## Interaction feedback update

The active love direction now follows Sven's approach and is locked until
release. Completion no longer draws a combined Sven/sheep sprite after Sven
has become visible. Dog artwork fits a 46×32 envelope (previously 36×25).
Starting a new interaction alerts the dog for 100 ticks, bypassing rest and
moving at 50 horizontal / 25 vertical pixels per second. Ordinary pursuit stays
at 25 / 12.5. Diagonal motion keeps horizontal facing until horizontally aligned.

Whistling now requires a double fire press (0.3-second window), including near
a friendly sheep or while moving. Single/held fire retains normal interaction.
Pause and restart clear incomplete double presses. The two-second whistle
cooldown still applies.

## Devil sheep and mushroom milestone

Implemented the supplied mechanics as an adaptation: four mood icons with
lightning warning, horned red devil sprites in four directions, faster angry
movement, electrical stun/point penalty, golden speed mushrooms, foul odor
mushrooms, and varied safe water escapes. UFOs are excluded as requested.

Age thresholds are 20/35/50/52 seconds; devil duration is eight seconds, then
age returns to 20 with a new local wandering center. Dark-cloud sheep move
every four ticks instead of eight, devils every two ticks and can leave their
normal home radius. All movement remains bounded and avoids water. Whistles
reduce age by 24 only before lightning. Shock lasts 100 ticks, deducts ten
points with saturation, and has a 125-tick repeat cooldown; it grants no enemy
protection. Golden speed lasts 250 ticks; foul odor affects live sheep within
69 horizontal / 41 vertical pixels. Mushrooms do not respawn until restart.

Natural devil recovery is an explicit adaptation rule so untreated sheep cannot
make the level permanently unwinnable. The other numerical values are likewise
tuning choices; the pasted account is not treated as verified historical data.
