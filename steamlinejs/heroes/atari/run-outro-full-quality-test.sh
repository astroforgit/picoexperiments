#!/usr/bin/env sh
# Standalone full-resolution ending viewer with the existing Altirra profile.
set -eu
runner_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
image="$runner_dir/heroes-outro-full-quality-test.xex"
launcher="$runner_dir/../../../atari-vbxe-toolkit/scripts/run-xex.sh"
if [ ! -f "$image" ] || [ ! -f "$launcher" ]; then
    echo "Missing viewer XEX or Altirra launcher" >&2
    exit 1
fi
case "${1:-}" in
    --check) printf 'Viewer: %s\nLauncher: %s\n' "$image" "$launcher"; exit 0 ;;
    '') ;;
    *) echo "Usage: $0 [--check]" >&2; exit 2 ;;
esac
exec sh "$launcher" "$image"
