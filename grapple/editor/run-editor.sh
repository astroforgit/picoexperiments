#!/usr/bin/env sh
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo_root=$(CDPATH= cd -- "$script_dir/../.." && pwd)
editor_port=8090
open_browser=1

for argument in "$@"; do
    case "$argument" in
        --no-open) open_browser=0 ;;
        *[!0-9]*) echo "usage: $0 [port] [--no-open]" >&2; exit 2 ;;
        *) editor_port=$argument ;;
    esac
done

if ! command -v python3 >/dev/null 2>&1; then
    echo "python3 is required to serve the editor" >&2
    exit 1
fi

cd "$repo_root"
python3 -m http.server "$editor_port" --bind 127.0.0.1 &
editor_server_pid=$!
trap 'kill "$editor_server_pid" 2>/dev/null || true' EXIT INT TERM

editor_url="http://127.0.0.1:$editor_port/grapple/editor/?world=/steamlinejs/world.json&revision=world-8"
echo "Grapple Level Editor: $editor_url"
echo "Press Ctrl+C to stop the server."

if [ "$open_browser" -eq 1 ]; then
    if command -v wslpath >/dev/null 2>&1 &&
        [ -x /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe ]; then
        /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe \
            -NoProfile -Command "Start-Process '$editor_url'" >/dev/null
    elif command -v xdg-open >/dev/null 2>&1; then
        xdg-open "$editor_url" >/dev/null 2>&1 || true
    fi
fi

wait "$editor_server_pid"
