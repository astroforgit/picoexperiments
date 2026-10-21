#!/usr/bin/env sh
# Reuse the persistent Altirra profile, mounting the story disk in D1:.
set -eu
runner_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
image="$runner_dir/prince-and-the-nimf.xex"
story="$runner_dir/prince-and-the-nimf.atr"
launcher="$runner_dir/run-prince-and-the-nimf.ps1"
for file in "$image" "$story" "$launcher"; do
    if [ ! -f "$file" ]; then echo "Required game file not found: $file" >&2; exit 1; fi
done
case "${1:-}" in
    --check) printf 'Game: %s\nStory disk: %s\nLauncher: %s\n' "$image" "$story" "$launcher"; exit 0 ;;
    '') ;;
    *) echo "Usage: $0 [--check]" >&2; exit 2 ;;
esac
exec /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe \
    -NoProfile -ExecutionPolicy Bypass -File "$(wslpath -w "$launcher")"
