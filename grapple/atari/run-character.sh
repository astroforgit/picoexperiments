#!/usr/bin/env sh
set -eu

# Build an alternative hero and run it in Altirra, leaving the default build
# in this directory alone. The sheet marks regions rather than drawing them:
# red hair, white top, green legs, blue skin. See ../design/PixelCharacterV1.
#
#     ./run-character.sh                       # PixelCharacterV1, blue hair
#     ./run-character.sh path/to/sheet.png     # any other sheet
#     ./run-character.sh --build-only          # assemble without launching

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo_root=$(CDPATH= cd -- "$script_dir/../.." && pwd)

build_only=0
sheet=""
for argument in "$@"; do
    case "$argument" in
        --build-only) build_only=1 ;;
        -h|--help)
            sed -n '4,10p' "$0" | sed 's/^# \{0,1\}//'
            exit 0 ;;
        -*)
            echo "unknown option: $argument" >&2
            exit 2 ;;
        *)
            if [ -n "$sheet" ]; then
                echo "usage: $0 [path/to/player-sheet.png] [--build-only]" >&2
                exit 2
            fi
            sheet=$argument ;;
    esac
done

if [ -z "$sheet" ]; then
    sheet="$repo_root/grapple/design/PixelCharacterV1/player-pixelv1.png"
fi

if [ ! -f "$sheet" ]; then
    echo "no such player sheet: $sheet" >&2
    echo "usage: $0 [path/to/player-sheet.png] [--build-only]" >&2
    exit 2
fi

sheet=$(realpath "$sheet")
name=$(basename "$sheet" .png)
build_dir="$script_dir/builds/$name"

echo "Character: $name"
echo "Sheet:     $sheet"
echo "Build:     $build_dir"
PLAYER_SHEET="$sheet" BUILD_DIR="$build_dir" "$script_dir/build.sh"

if [ -n "${BUILD_DIR:-}" ] && [ "$BUILD_DIR" != "$build_dir" ]; then
    echo "note: BUILD_DIR from the environment was ignored; this runner picks" \
         "its own build directory per character" >&2
fi

if [ "$build_only" -eq 1 ]; then
    echo "Built $build_dir/grapple-vbxe.xex"
    exit 0
fi

runner="$repo_root/atari-vbxe-toolkit/scripts/run-xex.sh"
if [ ! -x "$runner" ]; then
    echo "emulator runner not found at $runner" >&2
    echo "built $build_dir/grapple-vbxe.xex; run it by hand" >&2
    exit 1
fi

exec "$runner" "$build_dir/grapple-vbxe.xex"
