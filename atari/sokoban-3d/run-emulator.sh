#!/usr/bin/env sh
set -eu

project_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
workspace_root=$(CDPATH= cd -- "$project_dir/../.." && pwd)
atari_runner="$workspace_root/atari-vbxe-toolkit/scripts/run-xex.sh"
xex_path="$project_dir/bin/sokoban-3d.xex"

if ! command -v make >/dev/null 2>&1; then
    echo "Sokoban 3D launcher: GNU Make was not found in PATH." >&2
    exit 1
fi

if ! command -v mads >/dev/null 2>&1; then
    echo "Sokoban 3D launcher: MADS assembler was not found in PATH." >&2
    exit 1
fi

if [ ! -x "$atari_runner" ]; then
    echo "Sokoban 3D launcher: Atari runner not found: $atari_runner" >&2
    exit 1
fi

echo "Building Sokoban 3D..."
make -C "$project_dir"

if [ ! -f "$xex_path" ]; then
    echo "Sokoban 3D launcher: build did not create $xex_path" >&2
    exit 1
fi

echo "Starting Sokoban 3D in Altirra..."
exec "$atari_runner" "$xex_path"
