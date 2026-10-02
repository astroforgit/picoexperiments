# Title screen

`title-screen-v3.png` is the active artwork, edited with the built-in imagegen
tool to add Sven's red wool sweater and large Atari chest symbol. The conversion
credit is rendered separately in the Atari text row. `title-screen-v2.png` was created with the built-in imagegen
tool using the user's attached Sven/sheep image as the character-style reference.
`title-screen.png` preserves the initial concept. Existing artwork credits apply
to the referenced characters; this is newly generated adaptation artwork.

The build downsamples the active artwork to 320×200, generates an independent
254-color palette with transparent index 0 and white index 255, and stores the
bitmap at VBXE `$60000`. `generated/title-preview.png` is the indexed preview.
The renderer uses this image only in MODE_READY and restores the meadow palette
on starting. All uploads end at `$70000`, below control data at `$7F000`.

## Final generation prompt

### Sweater edit (v3)

Use case: precise-object-edit. Edit this existing Sven Atari VBXE title screen. Change ONLY the clothing of the central dark-wool hero Sven: dress him in a cozy red knitted wool sweater with ribbed collar, cuffs and hem, and an enormous cream-white classic Atari Fuji symbol prominently centered on his chest, taking up most of the sweater front. The symbol is the recognizable Atari three-stroke Fuji emblem: straight vertical central stripe flanked by two symmetrical strokes that curve outward toward the bottom. Make the emblem bold, clean, high contrast, clearly readable when this entire picture is reduced to 320x200. Subtle simple knit marks, same flat hand-drawn cartoon style. Keep Sven's hands on hips and proud pose, same huge yellow muzzle, face, hair, ears, eyes, thin legs and feet. Preserve the four surrounding white sheep, hearts, thought bubbles, scenery, colors, composition and all text exactly: SVEN, VBXE EDITION, PRESS FIRE TO START. No other changes, no additional text, no watermark. Maintain landscape 8:5 canvas.

### Character reference version (v2)

Use case: illustration-story. Create revised finished landscape 8:5 title screen for Atari Sven VBXE, downsampled to 320x200. The most recent user-attached reference image is the CHARACTER DESIGN AND DRAWING STYLE reference: match its simple flat hand-drawn cartoon characters very closely. Sven has shaggy dark olive-brown wool, a huge elongated mustard-yellow rounded muzzle, two big white googly eyes with tiny black pupils close together, flat oval yellow ears, thin brown sticklike arms and legs, yellow oval hooves, pink mouth with goofy smile. NO large curled ram horns, NO realistic wool texture, NO muscular anthropomorphic body, NO polished modern mascot style. Sheep have pure white cloud-scalloped wool, same oversized mustard-yellow muzzles and thin limbs, simple expressive eyes. Preserve this exact charming low-detail old PC cartoon design, slightly irregular thin gray-brown outlines, simple flat fills and very limited shading. Scene: Sven stands upright proudly at center with hands on hips and chest puffed, surrounded by four white sheep looking adoringly toward him with dreamy heart eyes and blushing cheeks. Pink/red comic hearts in white thought bubbles float around him. Full bodies visible. Sunny simple green meadow and blue sky with fluffy clouds and distant hills. Large cream/golden title at top exactly "SVEN", small subtitle "VBXE EDITION". Dark bottom banner exactly "PRESS FIRE TO START". Characters fill the middle between title and banner. Keep thick readable lettering, all text safely inside canvas. Wholesome comical admiration. This is the revised title art for the project, use the user reference for character identity and style, not its pose. No watermark.
