#!/usr/bin/env sh
set -eu

if [ "$#" -lt 1 ]; then
    echo "usage: $0 path/to/program.xex" >&2
    exit 2
fi

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
xex_path=$(realpath "$1")
ps_script=$(wslpath -w "$script_dir/run-xex.ps1")
windows_xex=$(wslpath -w "$xex_path")

exec /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe \
    -NoProfile -ExecutionPolicy Bypass -File "$ps_script" \
    -XexPath "$windows_xex"

