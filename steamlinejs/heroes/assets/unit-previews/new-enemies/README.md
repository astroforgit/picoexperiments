# Evil Nymph and Ogre Mage artwork, revision 2

Generated using built-in imagegen with medieval-heroes-v2.png and medieval-enemies-b.png as visual references, following PROMPT.md and MEDIEVAL-ENEMIES.md. Detailed shaded medieval figures, natural proportions, true alpha, six animation columns and two rows. All source poses face right, matching the original editor previews.

Nymph: emerald leaf dress, violet wings, airborne with bent knees throughout; four wing-flap poses, charm preparation and release. Ogre Mage: olive skin, blue/violet gold-trimmed robe, orb staff; four walking poses, spell preparation and release. The prior single-unit atlases are retained for provenance.

atlas.json records the measured cell boundaries. The editor embeds the full-resolution source for offline use. build-medieval.js crops the same source, downsamples to 32x28, and mirrors only the native enemy sprites to face the player army. Nymph native frames reserve three transparent pixels below the flying body. Cell geometry is fixed across poses to prevent per-frame size changes.
