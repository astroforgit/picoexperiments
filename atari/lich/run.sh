#!/usr/bin/env bash
# Rebuild from game data and start Altirra with the persistent VBXE profile.
# ./run.sh [--no-build] [--game path/to/exported-game.json]
set -euo pipefail
here="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
build_game=1
game_data="$here/data/game.json"
while (($#)); do
    case "$1" in
        --no-build) build_game=0; shift ;;
        --game) game_data="${2:?--game needs a game.json path}"; shift 2 ;;
        *) echo "Usage: $0 [--no-build] [--game path/to/game.json]" >&2; exit 2 ;;
    esac
done
if ((build_game)); then
    python3 "$here/tools/make_data.py" "$game_data"
    "$here/build.sh"
fi
exec "$here/../../atari-vbxe-toolkit/scripts/run-xex.sh" "$here/lich.xex"
