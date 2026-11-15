#!/usr/bin/env sh
set -eu

music_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
if ! command -v wslpath >/dev/null 2>&1; then
    echo 'This launcher uses Windows Altirra from WSL. On Windows, run tools/music-library.ps1.' >&2
    exit 1
fi
if [ ! -f "$music_dir/catalog.json" ]; then
    echo 'Music catalog missing. Run: python3 tools/convert.py' >&2
    exit 1
fi
case "${1-}" in
    -h|--help)
        echo 'Usage: ./run-emulator.sh [--compare|--library] [game name]'
        echo 'Defaults to the original/remix comparison when remixes are available.'
        echo 'Use --library for the PICO music collection and auditions.'
        exit 0 ;;
esac
mode=library
if [ -f "$music_dir/remixes/catalog.json" ]; then mode=compare; fi
case "${1-}" in
    --compare) mode=compare; shift ;;
    --library) mode=library; shift ;;
esac
powershell_bin=/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe
if [ "$mode" = compare ]; then
    exec "$powershell_bin" -NoProfile -STA -ExecutionPolicy Bypass \
        -File "$(wslpath -w "$music_dir/tools/compare-music.ps1")" -Game "${*:-draconus}"
fi
exec "$powershell_bin" -NoProfile -STA -ExecutionPolicy Bypass \
    -File "$(wslpath -w "$music_dir/tools/music-library.ps1")" -Game "${*:-porterpatch1-1}"
