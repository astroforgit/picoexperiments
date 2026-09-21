# PixelCharacterV1 as the Grapple hero

An alternative hero converted from the supplied sheets, with blue hair.

## Building her

```sh
grapple/atari/run-character.sh              # build her and launch Altirra
grapple/atari/run-character.sh --build-only # just assemble
```

That runner assembles into `grapple/atari/builds/player-pixelv1/`, so the
default build is never replaced. To build by hand instead:

```sh
PLAYER_SHEET=grapple/design/PixelCharacterV1/player-pixelv1.png \
    BUILD_DIR=/tmp/pixelv1 grapple/atari/build.sh
```

`grapple-vbxe-pixelv1.xex` in this folder is that build, kept separate so the
default build still matches `grapple/bin/assets/player.png`. To adopt her
permanently, copy `player-pixelv1.png` over that file instead; nothing else
needs changing.

## What the conversion did

`../convert_character.py` can reduce her 48x48 source frames to the pipeline's
16x16 cells. For the sheet used here, its `--pose-reference` mode instead draws
a custom slim character on the classic hero's animation phases. Direction,
weight and action follow the original poses, but the outline does not: the
body is roughly half as dense and the long hair is a separate ribbon that
lags, lifts and curls differently from frame to frame.

Her twelve colours become four region markers — red hair, white top, green
legs, blue skin — which the generator turns into palette indices 20, 17, 18
and 16. The hair tie and the eyes fold into the hair: both are accents that
read as hair at this size.

Colours live in the generated `player-palette.asm`, emitted from whichever
sheet built the game, so switching character switches palette with it. Hers
is blue hair `72,148,255`, top `226,226,226`, trousers `64,82,48`, skin
`255,180,153`. Edit `PLAYER_PALETTES.regions` in `generate_assets.js` to
retune them.

Regenerate the editor/game sheet with:

```sh
python3 grapple/design/convert_character.py \
    grapple/design/PixelCharacterV1/PixelCharacterV1 \
    --pose-reference grapple/bin/assets/player.png \
    --out grapple/design/PixelCharacterV1/player-pixelv1.png
```

## Animation phases

The supplied character pack only has idle, run and jump artwork. Earlier
conversion therefore substituted reversed jump frames for fall, run frames
for grapple, and idle for death. The current sheet no longer contains those
placeholders: all sixteen occupied slots follow the classic hero frame for
phase, including two purpose-drawn horizontal grapple poses and a collapsed
death pose. They deliberately preserve only the general pose, not the classic
hero's silhouette.
