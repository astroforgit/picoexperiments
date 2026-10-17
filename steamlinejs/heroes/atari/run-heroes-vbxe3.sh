#!/usr/bin/env sh
# Launch the published v3 executable with the workspace's persistent Altirra profile.
set -eu
runner_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
image="$runner_dir/heroes-vbxe3.xex"
launcher="$runner_dir/../../../atari-vbxe-toolkit/scripts/run-xex.sh"
if [ ! -f "$image" ]; then
    echo "Game not found: $image" >&2
    exit 1
fi
if [ ! -f "$launcher" ]; then
    echo "Altirra launcher not found: $launcher" >&2
    exit 1
fi
case "${1:-}" in
    --check)
        printf 'Game: %s\nLauncher: %s\n' "$image" "$launcher"
        exit 0 ;;
    '') ;;
    *) echo "Usage: $0 [--check]" >&2; exit 2 ;;
esac
exec sh "$launcher" "$image"
