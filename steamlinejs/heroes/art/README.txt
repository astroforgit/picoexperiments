Heroes VBXE v2 artwork — 17 October 2026

This is an optional new art profile. The classic artwork and current executable
are preserved. art/vbxe-v2/classic-manifest.json records their exact hashes.
The classic profile rebuilds to a byte-for-byte identical 408920-byte XEX.
The new executable is409025 bytes and keeps the existing native gameplay data.
The editor balance preset and simulator settings have not been imported into it.

Coverage: 150 replacement PNGs at the actual runtime dimensions:
  - Town and encounter map,320x200 each.
  - All fifteen building tiers,56x64 transparent cells.
  - Four battle arenas,320x128 each.
  - Three terrain obstacles,32x28.
  - Twenty-one fighter designs, six32x28 poses each (126 frames), including
    the five hero designs, thirteen enemies and three mounted appearances.
    Four walk poses and two attack poses are preserved for each design.

Source artwork was made with the built-in image_gen tool. The exact prompts
and source provenance are in art/vbxe-v2/generation.json. All nine generated
images are saved under art/vbxe-v2/sources. Atlas extraction, nearest-neighbor
resizing, alpha cleanup and palette conversion are deterministic build steps.
No generated image is referenced only from an external cache directory.

The new renderer stores buildings using their opaque bounding rectangles,
preserving their original56x64 screen anchors. This cuts building storage from
53760 to33010 bytes (20750 bytes saved). Freed padding is split at4K aperture
boundaries and used for packed fighter poses and idle caches. The new animation
art uses30044 bytes rather than22269, with eight idle caches rather than four.
The global palette remains256 entries; fighter rows use a shared15-color plus
transparent local palette. No new display mode or hardware requirement is added.

The crop-specific native instructions are conditionally assembled only for the
new profile. The classic binary is unchanged. Verification uses the actual
occupied building length when checking graphics/animation allocations.

Rebuild from the heroes directory (Node18+, Python3/Pillow, ImageMagick and MADS):
  python3 art/tools/prepare-vbxe-v2.py
  node art/tools/build-profile.cjs classic
  node art/tools/build-profile.cjs vbxe-v2

These commands build in art/work/native-classic and art/work/native-vbxe-v2.
The current atari/city/city-vbxe.xex is not overwritten. art/work is ignored.
HEROES_ART_PROFILE selects native art, defaulting to classic. The isolated
builder sets it and provides the existing original unit-atlas directory.

Generate the native A/B comparison and downloadable builds:
  python3 art/tools/export-review.py --classic art/work/native-classic --new art/work/native-vbxe-v2 --output art/work/review
  python3 art/tools/make-comparison.py --review art/work/review --output PATH_TO_OUTPUTS

The exporter reads the built palette, VRAM and compressed animation streams.
It also captures town/map/battle screens from the assembled6502 program running
in the functional VBXE emulator. No screenshots are recreated with mock UI.
art/asset-comparison.html is a standalone copy of the current comparison.
The output directory includes both XEXs, prompts, source atlases, original/new
native input PNGs, decoded indexed previews and a complete ZIP for review.

Comparison controls:54 paired entries grouped into game screens, scenery,
buildings, animated fighters and obstacles. Side by side, wipe and blink modes;
1x-8x crisp zoom; synchronized idle/walk/attack; pause and step frames. The
sixteen-bit building anchors, footprints and terrain layout can be reviewed at
native size, not just on large generated source sheets.

Verification (py65 and Pillow required for native execution):
  python3 art/tools/test-art-profiles.py
  python3 art/work/native-vbxe-v2/tools/test-hero-animation.py
  python3 art/work/native-vbxe-v2/tools/test-battle-speed.py
  python3 art/work/native-vbxe-v2/tools/test-runtime.py
  python3 art/work/native-vbxe-v2/tools/test-chapel.py

Verified:150 dimensions/hashes, distinct walk/attack poses, unchanged classic
assets/XEX, all15 building blits at D600 and D700, all168 runtime unit/pose
mappings at both register pages, nonoverlapping CPU/VRAM allocations, animation
motion/projectiles, cache correctness and numeric HUD. Offline browser checks
cover all54 entries, image differences, animation controls, wipe pixels and blink.
CPU-cycle measurements come from the functional emulator, not Atari frame-rate
or physical-hardware timing tests. Visual quality is reviewable per asset;
the preserved classic profile allows any individual redesign to be rejected.

Measured ten-unit redraw (native-style benchmark, both D600/D700):
Classic208187 warm /408396 cold CPU cycles; v2 102313 warm /424171 cold.
The v2 warm case uses about51% fewer CPU cycles; the cold case is slightly
more expensive. This is not a physical Atari frame-rate measurement.
