#!/usr/bin/env sh
# Reuse the persistent Altirra profile, booting the single-file disk in D1:.
set -eu
runner_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
disk="$runner_dir/prince-and-the-nymph-boot.atr"
launcher="$runner_dir/run-prince-and-the-nymph-boot.ps1"
for file in "$disk" "$launcher"; do
    if [ ! -f "$file" ]; then echo "Required game file not found: $file" >&2; exit 1; fi
done
case "${1:-}" in
    --check) printf 'Boot disk: %s\nLauncher: %s\n' "$disk" "$launcher"; exit 0 ;;
    '') ;;
    *) echo "Usage: $0 [--check]" >&2; exit 2 ;;
esac
exec /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe \
    -NoProfile -ExecutionPolicy Bypass -File "$(wslpath -w "$launcher")"
