#!/usr/bin/env sh
# Disk-streamed gallery test: picture count does not reserve extra image memory.
set -eu
runner_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
image="$runner_dir/heroes-outro-full-quality-test.xex"
story="$runner_dir/prince-and-the-nimf.atr"
launcher="$runner_dir/run-outro-full-quality-test.ps1"
for file in "$image" "$story" "$launcher"; do
    if [ ! -f "$file" ]; then echo "Required viewer file not found: $file" >&2; exit 1; fi
done
case "${1:-}" in
    --check) printf 'Screens: eight new gallery paintings; Fire/Enter/Space advances, then replay.\nMemory: existing screen buffers, 256-byte staging, no picture caches.\nViewer: %s\nStory disk: %s\n' "$image" "$story"; exit 0 ;;
    '') ;;
    *) echo "Usage: $0 [--check]" >&2; exit 2 ;;
esac
exec /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe \
    -NoProfile -ExecutionPolicy Bypass -File "$(wslpath -w "$launcher")"
