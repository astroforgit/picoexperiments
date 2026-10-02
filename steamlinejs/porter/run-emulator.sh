#!/usr/bin/env sh
set -eu

project_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
atari_dir="$project_dir/atari"
workspace_root=$(CDPATH= cd -- "$project_dir/../.." && pwd)
vbxe_runner="$workspace_root/atari-vbxe-toolkit/scripts/run-xex.sh"
xex_path="$atari_dir/porter-vbxe.xex"

if ! command -v node >/dev/null 2>&1; then
    echo "Porter launcher: Node.js was not found in PATH." >&2
    exit 1
fi

if ! command -v mads >/dev/null 2>&1; then
    echo "Porter launcher: MADS assembler was not found in PATH." >&2
    exit 1
fi

if [ ! -x "$vbxe_runner" ]; then
    echo "Porter launcher: VBXE runner not found: $vbxe_runner" >&2
    exit 1
fi

echo "Building Porter VBXE..."
"$atari_dir/build.sh"

if [ ! -f "$xex_path" ]; then
    echo "Porter launcher: build did not create $xex_path" >&2
    exit 1
fi

echo "Configuring responsive audio..."
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe \
    -NoProfile -ExecutionPolicy Bypass \
    -File "$(wslpath -w "$atari_dir/tools/configure_audio.ps1")"

echo "Starting Porter in Altirra..."
exec "$vbxe_runner" "$xex_path"
