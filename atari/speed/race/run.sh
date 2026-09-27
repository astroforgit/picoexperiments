#!/usr/bin/env sh
# Run SPEEDMAZA RACE in Altirra (builds it first if race.xex is missing).
#   ./run.sh           play the game
#   ./run.sh auto      watch the self-driving test build
#   ./run.sh rebuild   rebuild, then play
set -eu
cd "$(dirname "$0")"
XEX=race.xex
case "${1:-}" in
    auto)    [ -f race_auto.xex ] || ./build.sh auto; XEX=race_auto.xex ;;
    rebuild) ./build.sh ;;
    "")      [ -f race.xex ] || ./build.sh ;;
    *)       echo "usage: $0 [auto|rebuild]" >&2; exit 2 ;;
esac
exec ../../../atari-vbxe-toolkit/scripts/run-xex.sh "$XEX"
