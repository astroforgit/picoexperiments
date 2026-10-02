#!/usr/bin/env sh
set -eu

project_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
workspace_root=$(CDPATH= cd -- "$project_dir/../.." && pwd)
vbxe_runner="$workspace_root/atari-vbxe-toolkit/scripts/run-xex.sh"
xex_path="$project_dir/streamline-vbxe.xex"
asm_path="$project_dir/streamline-vbxe.asm"

if ! command -v node >/dev/null 2>&1; then
    echo "Streamline launcher: Node.js was not found in PATH." >&2
    exit 1
fi

if ! command -v mads >/dev/null 2>&1; then
    echo "Streamline launcher: MADS assembler was not found in PATH." >&2
    exit 1
fi

if [ ! -x "$vbxe_runner" ]; then
    echo "Streamline launcher: VBXE runner not found: $vbxe_runner" >&2
    exit 1
fi

echo "Building Streamline (VBXE)..."
(cd "$project_dir" && node generate_levels.js \
    && mads streamline-vbxe.asm \
       -o:streamline-vbxe.xex \
       -t:streamline-vbxe.lab \
       -l:streamline-vbxe.lst)

if [ ! -f "$xex_path" ]; then
    echo "Streamline launcher: build did not create $xex_path" >&2
    exit 1
fi

if [ ! -f "$asm_path" ]; then
    echo "Streamline launcher: expected source not found: $asm_path" >&2
    exit 1
fi

echo "Starting Streamline in Altirra..."
exec "$vbxe_runner" "$xex_path"
