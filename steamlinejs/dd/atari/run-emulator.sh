#!/usr/bin/env sh
set -eu

project_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
workspace_root=$(CDPATH= cd -- "$project_dir/../../.." && pwd)
vbxe_runner="$workspace_root/atari-vbxe-toolkit/scripts/run-xex.sh"
xex_path="$project_dir/double-dragon-vbxe.xex"

if ! command -v python3 >/dev/null 2>&1; then
    echo "Double Dragon launcher: Python 3 was not found in PATH." >&2
    exit 1
fi

if ! command -v "${MADS:-mads}" >/dev/null 2>&1; then
    echo "Double Dragon launcher: MADS was not found in PATH." >&2
    exit 1
fi

if [ ! -x "$vbxe_runner" ]; then
    echo "Double Dragon launcher: VBXE runner not found: $vbxe_runner" >&2
    exit 1
fi

echo "Building Double Dragon VBXE..."
bash "$project_dir/build.sh"

if [ ! -f "$xex_path" ]; then
    echo "Double Dragon launcher: build did not create $xex_path" >&2
    exit 1
fi

echo "Starting Double Dragon in Altirra..."
exec "$vbxe_runner" "$xex_path"
