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

## Original enemy redesigns

The built-in image-generation tool received `original-enemies-reference.png`,
a contact sheet extracted from the 32 original Kult enemies. Its resulting
8×4 sheet is `redesigned-enemies-sheet.png`; the exact prompt is saved in
`redesign-prompt.txt`. `../import_redesigns.py` converts the sheet into native
16×16 monochrome four-frame sprites in `redesigned-enemies.json`, with a
converted overview in `redesigned-enemies-native.png`. Animation is added by
the importer (rear exhaust or a small pulsing light); the model produced the
base designs. The twin-pod fighter is rotated left during conversion.

The editor shows all 32 original animations beside their redesigns. The current
and default Atari projects use the redesigns for all ordinary slots, plus the
redesigned meteor and skull for special encounters. Original sprites and the
previous imported catalog remain selectable; original game files are untouched.

## Pickup redesigns

`pickups-reference.png` collects the four existing weapon pickup icons and
shield. The built-in image model redesigned these into the five-cell
`pickups-redesigned-sheet.png`, using the saved `pickups-prompt.txt`.
`../import_pickups.py` converts it to `pickups.json` and `pickups-native.png`.
The Atari builder writes all five icons into their original 3-byte × 16-row
sprite locations, with a blank alignment byte. Editor encounter rewards use
those same converted icons. Pickup behavior and drop rates are unchanged.

The current importer uses `pickups-circular-sheet.png`, a model revision of the
previous sheet with matching circular rings around all five emblems, including
the shield. Its prompt is saved in `pickups-circular-prompt.txt`. The previous
source sheet remains available as a reference. The converted native icons and
editor data retain their existing filenames and pickup behavior.

## Animated boss candidates

`bosses/original-dragon-reference.png` contains the original game's four dragon
frames. The built-in image-generation tool received that reference and produced
`bosses/candidates-sheet.png`: Bone Dragon, Iron Manta, Void Kraken, and Insect
Queen, each with four authored animation frames. `bosses/prompt.txt` records the
prompt. No CLI/API fallback was used.

`../import_bosses.py` converts fixed atlas cells to 64×64 monochrome frames without
inventing animation or resizing each pose separately. `bosses/catalog.json`
contains only the four generated candidates. The reference dragon is retained
solely as generation provenance, not as a selectable or runtime resource. `bosses/native-preview.png`
shows the exact converted frames. The editor and native exporter share this data.
