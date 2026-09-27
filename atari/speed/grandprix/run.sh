#!/usr/bin/env sh
# Run SPEEDMAZA GRAND PRIX in Altirra (builds it first if needed).
#   ./run.sh           play
#   ./run.sh auto      watch the self-driving test build
#   ./run.sh rebuild   rebuild, then play
set -eu
cd "$(dirname "$0")"
XEX=grandprix.xex
case "${1:-}" in
    auto)    [ -f grandprix_auto.xex ] || ./build.sh auto; XEX=grandprix_auto.xex ;;
    rebuild) ./build.sh ;;
    "")      [ -f grandprix.xex ] || ./build.sh ;;
    *)       echo "usage: $0 [auto|rebuild]" >&2; exit 2 ;;
esac
exec ../../../atari-vbxe-toolkit/scripts/run-xex.sh "$XEX"
