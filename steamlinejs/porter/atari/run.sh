#!/usr/bin/env bash
# Build Porter and start it in Altirra (from WSL).
#   ./run.sh [--no-build] [--pal|--ntsc] [--debug] [--slow-load]
set -euo pipefail
here="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

build=1
args=()
for a in "$@"; do
    case "$a" in
        --no-build)  build=0 ;;
        --pal)       args+=(-Pal) ;;
        --ntsc)      args+=(-Ntsc) ;;
        --debug)     args+=(-Debugger) ;;
        --slow-load) args+=(-SlowLoad) ;;
        -h|--help)   sed -n 2,3p "$0"; exit 0 ;;
        *) echo "unknown option: $a" >&2; exit 2 ;;
    esac
done

if [[ $build == 1 ]]; then
    "$here/build.sh" >/dev/null
fi

exec /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe \
    -NoProfile -ExecutionPolicy Bypass -File "$(wslpath -w "$here/run.ps1")" \
    -XexPath "$(wslpath -w "$here/porter-vbxe.xex")" "${args[@]}"
