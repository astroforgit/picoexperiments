#!/usr/bin/env sh
# Build, verify and package Prince and the Nimf. Pass an output directory optionally.
set -eu
release_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
cd "$release_dir/.."
sh atari/city/build.sh
node release/audit-balance.cjs
for test in test-release-menu test-sfx test-release-campaign test-runtime test-story-intro test-story-streaming test-outro test-outro-shortcut test-game-over test-double-fire-turn test-encounter-popup test-hit-impact test-permanent-casualties; do
    python3 "atari/city/tools/$test.py"
done
for test in tests/*.test.cjs; do node "$test"; done
if [ "$#" -gt 0 ]; then python3 release/package.py --output "$1"; else python3 release/package.py; fi
