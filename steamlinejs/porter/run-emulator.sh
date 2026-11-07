#!/usr/bin/env sh
set -eu

project_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
atari_dir="$project_dir/atari"
workspace_root=$(CDPATH= cd -- "$project_dir/../.." && pwd)
vbxe_toolkit="$workspace_root/atari-vbxe-toolkit/scripts/AltirraTools.psm1"

if ! command -v node >/dev/null 2>&1; then
    echo "Porter launcher: Node.js was not found in PATH." >&2
    exit 1
fi

if ! command -v mads >/dev/null 2>&1; then
    echo "Porter launcher: MADS assembler was not found in PATH." >&2
    exit 1
fi

if [ ! -f "$vbxe_toolkit" ]; then
    echo "Porter launcher: VBXE toolkit not found: $vbxe_toolkit" >&2
    exit 1
fi

exec "$atari_dir/run.sh" "$@"
