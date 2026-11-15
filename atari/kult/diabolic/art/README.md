# Generated sprite designs

Generated using the built-in image-generation tool, then converted by
`../import_generated.py` to native monochrome, four-frame Atari sprite data
in `designs.json`. Source: `generated-sprite-sheet.png`.

Prompt:

Use case: stylized-concept. Asset type: a single production reference sprite sheet for a monochrome Atari 800XL side-scrolling space shooter. Generate ONE clean sprite design sheet on pure black, containing 8 rows and 4 animation frames per row in an evenly spaced grid. No labels, no text, no borders, no glow. White pixel art only, hard square pixels. Rows 1–4: four distinct right-facing playable spacecraft, each long and low, approximately 40 by 16 logical pixels: horned interceptor, sleek arrow fighter, twin-engine wing fighter, compact armored craft. Four frames show small changing engine flames, ship silhouette stable. Rows 5–8: four distinct left-facing enemy designs, approximately 16 by 16 logical pixels: mechanical orb with rotating segments, winged drone with flapping wings, armored beetle with moving legs, spiked alien with pulsing eye. Four frames each with coherent small animation. Plenty of black separation between every cell. True side-on arcade silhouettes, highly legible at tiny pixel size. Do not imitate existing game franchises.

## User-supplied enemies

`imported-enemies.json` contains 31 designs extracted from `../../enemys.webp`
by `../import_enemies.py`. The explicit crop rectangles omit neighbouring
sprites and the sheet caption. The source is retained unchanged. Rockets and
fighters originally pointing upward are rotated 90 degrees counterclockwise
so they face the player to the left; creatures and saucers remain upright.
Each design fits the native 16×16 monochrome enemy format, with four animation
frames (exhaust flicker or a pulsing central light). `imported-enemies.png`
shows the converted designs. Details are simplified at Atari resolution.

The supplied sheet displays Shutterstock attribution (2807464639); these
imports are user-supplied artwork, not newly generated original designs.
