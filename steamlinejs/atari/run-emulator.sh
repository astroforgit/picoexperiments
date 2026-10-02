#!/usr/bin/env sh
set -eu
project_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
echo "Building Streamline (standard Atari XL/XE)..."
"$project_dir/build.sh"
if command -v atari800 >/dev/null 2>&1; then
    exec atari800 -xl -pal -nobasic -run "$project_dir/streamline-atari.xex" "$@"
fi
powershell=/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe
if [ -x "$powershell" ] && command -v wslpath >/dev/null 2>&1; then
    exec "$powershell" -NoProfile -ExecutionPolicy Bypass \
        -File "$(wslpath -w "$project_dir/run-standard.ps1")" \
        -XexPath "$(wslpath -w "$project_dir/streamline-atari.xex")" "$@"
fi
echo "Install Atari800, or run from WSL with Altirra available on Windows." >&2
echo "Built image: $project_dir/streamline-atari.xex" >&2
exit 1
