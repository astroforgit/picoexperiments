Prince and the Nimf — the lost paintings of goblin master Grubbrush
Everything by astrofor

Eight source images, created with the built-in imagegen tool using the original
forest story illustration as a character/style reference. Exact final prompts
and per-image references are in generation.json. The second set also references
the first painter sitting. All artwork shows adult fantasy characters.

The mechanical exporter converts them to 320x144 pixels in the game's shared
256-colour palette. Captions occupy the lower part of a 320x200 screen.
The game and test viewer stream each page from the companion ATR through a
256-byte CPU buffer into the existing screen buffers; pictures have no separate
resident VRAM caches. The test contains only these eight gallery paintings.

Export and test:
  sh atari/city/build.sh
  node atari/city/tools/build-outro-full-quality.js
  python3 atari/city/tools/test-gallery.py
  python3 atari/city/tools/test-outro-full-quality.py
  python3 release/package-gallery.py
