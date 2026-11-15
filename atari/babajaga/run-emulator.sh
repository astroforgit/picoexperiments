#!/usr/bin/env sh
set -eu
script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo_root=$(CDPATH= cd -- "$script_dir/../.." && pwd)
image="$script_dir/babajaga.atr"
case "${1:-}" in
    *.atr|*.ATR|*.xex|*.XEX) image=$(realpath -- "$1"); shift ;;
esac
if [ ! -f "$image" ]; then
    echo "Babajaga disk is missing. Run $script_dir/build.sh first." >&2
    exit 1
fi
if ! command -v wslpath >/dev/null 2>&1; then
    echo "This launcher uses Windows Altirra through WSL." >&2
    exit 1
fi
exec /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe \
    -NoProfile -ExecutionPolicy Bypass -File "$(wslpath -w "$script_dir/run-emulator.ps1")" \
    -DiskPath "$(wslpath -w "$image")" \
    -ToolkitPath "$(wslpath -w "$repo_root/atari-vbxe-toolkit")" "$@"
