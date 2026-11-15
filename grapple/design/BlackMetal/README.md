# Elephant Frontman and black-metal companions

The hero is a hand-authored pixel interpretation of
`steamlinejs/atari/elephant.png`: broad elephant ears, curling raised trunk,
ivory tusks, dark stage clothing, a pendant and spiked wrist/boot details.
It is designed at 16×16 rather than downsampling the detailed illustration.

The 80×64 source uses the existing four-region colour markers and all sixteen
native gameplay slots: idle, run, jump, fall, horizontal grapple and collapse.
The small-sprite silhouette is kept inside the engine's existing frame cells.

Companions are new thorned iron movers, branching spikes, horned cannons,
spiked-skull cannonballs, three-state corpse-paint thwomps and two-state
ritual-candle checkpoints. They keep the existing native sheet sizes and
white/black shared palette, plus red alert eyes on thwomps.

Regenerate from the repository root:

```sh
python3 grapple/design/make_elephant.py
python3 grapple/design/make_asset_themes.py
grapple/atari/run-character.sh grapple/design/BlackMetal/player-elephant.png --build-only
```

Choose **Elephant Frontman · black metal** in Assets to select the matching
companion theme, or mix it with any other **Asset theme**. The map previews,
Playtest and the automatic native variant all use those same source sheets.
