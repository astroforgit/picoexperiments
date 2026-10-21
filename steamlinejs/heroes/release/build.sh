#!/usr/bin/env sh
# Build, verify and package Prince and the Nymph. Pass an output directory optionally.
set -eu
release_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
cd "$release_dir/.."
sh atari/city/build.sh
node atari/city/tools/build-outro-full-quality.js
cp atari/city/outro-full-quality-test.xex atari/heroes-outro-full-quality-test.xex
node release/audit-balance.cjs
for test in test-gallery test-outro-full-quality test-chapel test-release-menu test-difficulty test-sfx test-release-campaign test-runtime test-story-intro test-story-streaming test-outro test-outro-shortcut test-game-over test-double-fire-turn test-encounter-popup test-hit-impact test-permanent-casualties; do
    python3 "atari/city/tools/$test.py"
done
for test in tests/*.test.cjs; do node "$test"; done
if [ "$#" -gt 0 ]; then python3 release/package.py --output "$1"; else python3 release/package.py; fi
if [ "$#" -gt 0 ]; then python3 release/package-gallery.py --output "$1"; else python3 release/package-gallery.py; fi
