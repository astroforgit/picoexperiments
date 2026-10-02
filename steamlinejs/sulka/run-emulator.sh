#!/usr/bin/env sh
set -eu

project_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
atari_dir="$project_dir/atari"
levels_export="$project_dir/sulka-levels.asm"
workspace_root=$(CDPATH= cd -- "$project_dir/../.." && pwd)
vbxe_runner="$workspace_root/atari-vbxe-toolkit/scripts/run-xex.sh"

if ! command -v mads >/dev/null 2>&1; then
    echo "Sójka launcher: MADS assembler was not found in PATH." >&2
    exit 1
fi

if ! python3 -c "import PIL" >/dev/null 2>&1; then
    echo "Sójka launcher: Python Pillow is required to convert the VBXE screens." >&2
    exit 1
fi

if [ ! -x "$vbxe_runner" ]; then
    echo "Sójka launcher: VBXE runner not found: $vbxe_runner" >&2
    exit 1
fi

if [ -f "$levels_export" ]; then
    if ! command -v node >/dev/null 2>&1; then
        echo "Sójka launcher: Node.js is required to apply sulka-levels.asm." >&2
        exit 1
    fi
    echo "Validating and applying sulka-levels.asm..."
    (
        cd "$project_dir"
        node editor/apply-export.js sulka-levels.asm
    )
else
    echo "No sulka-levels.asm found; using the levels already embedded in the Atari source."
fi

echo "Converting title, story, ending, and level-06 artwork for VBXE..."
python3 "$atari_dir/generate_screens.py"

echo "Building Sójka VBXE..."
(
    cd "$atari_dir"
    mads sulka-vbxe.asm -o:sulka-vbxe.xex
)

echo "Starting Sójka in Altirra..."
exec "$vbxe_runner" "$atari_dir/sulka-vbxe.xex"
