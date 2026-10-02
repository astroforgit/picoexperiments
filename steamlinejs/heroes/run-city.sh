#!/usr/bin/env sh
# Launch the built Greenhaven city in Windows Altirra from WSL.
# Use --build to regenerate artwork and rebuild the XEX first.
set -eu

heroes_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
city_dir="$heroes_dir/atari/city"

case "${1:-}" in
    --build) "$city_dir/build.sh" ;;
    '') ;;
    -h|--help)
        echo "Usage: $0 [--build]"
        echo "Launch the VBXE city in Altirra; optionally rebuild first."
        exit 0
        ;;
    *) echo "Usage: $0 [--build]" >&2; exit 2 ;;
esac

if [ ! -f "$city_dir/city-vbxe.xex" ]; then
    echo "City executable is missing. Run $0 --build first." >&2
    exit 1
fi

exec "$heroes_dir/../../atari-vbxe-toolkit/scripts/run-xex.sh" \
    "$city_dir/city-vbxe.xex"
