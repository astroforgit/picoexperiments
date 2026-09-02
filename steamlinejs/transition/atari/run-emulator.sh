#!/usr/bin/env sh
set -eu

project_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
workspace_root=$(CDPATH= cd -- "$project_dir/../../.." && pwd)
atari_runner="$workspace_root/atari-vbxe-toolkit/scripts/run-xex.sh"
xex_path="$project_dir/bin/transition.xex"

if ! command -v make >/dev/null 2>&1; then
    echo "Transition launcher: GNU Make was not found in PATH." >&2
    exit 1
fi

if ! command -v mads >/dev/null 2>&1; then
    echo "Transition launcher: MADS assembler was not found in PATH." >&2
    exit 1
fi

if [ ! -x "$atari_runner" ]; then
    echo "Transition launcher: Atari runner not found: $atari_runner" >&2
    exit 1
fi

echo "Building Transition..."
make -C "$project_dir"

if [ ! -f "$xex_path" ]; then
    echo "Transition launcher: build did not create $xex_path" >&2
    exit 1
fi

echo "Starting Transition in Altirra..."
exec "$atari_runner" "$xex_path"
