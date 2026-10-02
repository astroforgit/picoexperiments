# Restored medieval previews

The editor uses the original `medieval-heroes-v2.png` again. The rejected code-drawn designs are archived and no longer used. Player tiers retain the five previous shared base appearances.

New enemy artwork was created using built-in imagegen, with the hero atlas as the visual reference. Active files:

- `medieval-enemies-a-alpha.png`: Minibeast, Wolf, Bat, Skeleton, Zombie, Bone Archer, Ogre.
- `medieval-enemies-b.png`: Warlock, Imp, Beast, Dark, Demon, Sniper.
- `medieval-enemy-roster.png`: browser-rendered review sheet.

Each atlas has six columns: four walking/flapping poses, attack preparation, attack release. Idle uses the first walking pose with the editor's subtle breathing motion. All assets are embedded in the HTML for offline use. Crops use measured boundaries rather than assuming generation produced an equal grid. Background alpha was corrected on sheet A using built-in imagegen; the uncorrected sheet is retained for provenance.

These are editor preview changes only; combat stats and Atari binary are unchanged.

## Prompts

Sheet A: use the medieval hero atlas as style reference only. Create a new enemy animation atlas matching richly shaded, realistic-proportioned 1990s medieval fantasy pixel art. Transparent background, six columns and seven rows. Rows: small brown horned Minibeast; silver-gray dire Wolf; purple-black giant Bat; ivory Skeleton with wooden bow; green Zombie in torn peasant clothes; teal-hooded Bone Archer with crossbow; olive Ogre in leather and fur carrying a club. Four walking/flapping poses with carried weapons, then attack preparation and release. Preserve full bodies, consistent design and scale, detailed anatomy and textures. No geometric vector art or chibi proportions.

Sheet B: same style reference and layout, six rows. Rows: violet-black Warlock with skull staff; orange-red Imp with tail and claws; brown-furred muscular humanoid Beast; obsidian-armored Dark knight with crimson cape, sword and shield; imposing red winged Demon; moss-green masked Sniper with longbow. Four walking-only poses followed by attack preparation and release. Warlock summons violet magic, creatures claw, knight slashes, Sniper shoots.

Alpha correction: remove only the painted gray-white checkerboard from sheet A; replace it with true transparent alpha, preserving all 42 sprites, positions, colors, dimensions, weapons and detailed silhouettes.

Validation: all 28 previews contain visible artwork; all 13 enemy idle images are distinct; walking selects only frames 0–3, attack selects 4–5, idle selects the resting pose. Browser reports no JavaScript errors.
