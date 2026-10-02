# Devil sheep and mushroom artwork

Generated with the built-in imagegen tool. Source atlas: `devils-mushrooms-atlas.png`.

The tool returned RGB checkerboard artwork rather than the requested alpha channel. The source is retained unchanged; the VBXE importer treats border-connected neutral checker pixels as transparent when creating indexed sprite data. The first four cells become directional devil sheep; the next two become the good and foul mushroom.

Initial prompt:

Create a production game sprite atlas on genuinely transparent RGBA background, exactly 4 equal columns and 2 equal rows, generous transparent padding within each cell, no text or grid. Style: humorous hand-painted 2D meadow cartoon matching the provided sheep reference, brown outlines, readable at tiny Atari resolution. Top row: the SAME angry crimson-red wool sheep with two curved pale devil horns, brown face and legs, exaggerated angry eyes, in four distinct orientations LEFT TO RIGHT: facing camera/down, facing away/up, facing left, facing right. Complete full bodies, consistent size and ground baseline. Bottom row LEFT TO RIGHT: friendly golden-orange mushroom with cream stem; foul purple-green mushroom with a small green odor curl; repeat friendly mushroom; repeat foul mushroom. Mushrooms substantially smaller than sheep, no faces. No other characters, no gore, no UFOs. Reference image is style/shape reference only; create new red horned sheep assets. Each object isolated in its own cell, no overlaps.

Correction prompt used for the selected atlas:

Edit this sprite atlas: remove ALL brown/black gradient background and colored glow completely, make background genuinely transparent alpha, including gaps between legs and horns. Preserve the eight objects, positions, 4 columns by 2 rows, colors and outlines exactly. No checkerboard, no ground, no new background. Output transparent RGBA PNG.

A further transparency retry was rejected from the build because it restored an opaque background:

Produce a PNG with an ACTUAL ALPHA CHANNEL (RGBA), NOT an RGB image of a checkerboard. Remove the fake white checkerboard background from this atlas. Every background pixel must have alpha 0. Keep precisely the four red horned sheep on the top row and the four mushrooms on the bottom row, unchanged positions, two rows four columns. This is a game sprite sheet requiring genuine transparent output. No checkerboard pixels should remain in the raster.

