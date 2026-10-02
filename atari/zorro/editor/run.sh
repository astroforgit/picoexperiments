#!/usr/bin/env sh
# Start the Zorro editor server and open it in the Windows browser.
#   ./run.sh [port]
set -eu
cd "$(dirname "$0")"
PORT="${1:-8765}"
python3 serve.py "$PORT" &
SERVER=$!
trap 'kill $SERVER 2>/dev/null' EXIT INT TERM
sleep 1
if command -v cmd.exe >/dev/null 2>&1; then
    cmd.exe /c start "" "http://localhost:$PORT" >/dev/null 2>&1 || true
else
    echo "Open http://localhost:$PORT"
fi
wait $SERVER
