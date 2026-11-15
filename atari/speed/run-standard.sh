#!/usr/bin/env sh
# Shared standard-Atari configuration used by Babajaga and the Speed games.
set -eu
script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
if [ "$#" -eq 0 ]; then
    echo "usage: $0 game.xex [Altirra launcher options]" >&2
    exit 2
fi
image=$(realpath -- "$1")
shift
exec "$script_dir/../babajaga/run-emulator.sh" "$image" "$@"
