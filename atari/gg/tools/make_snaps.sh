#!/usr/bin/env bash
# Rebuild the Atari model snapshots used by the test tools (after a build):
# gen/snap/f1000.pkl (attract mode) and gen/snap/game1900.pkl (level 1 play)
set -euo pipefail
cd "$(dirname "$0")/.."
python3 tools/atari_snap.py save 1000 gen/snap/f1000.pkl '320:15:1,330:15:0'
python3 - <<'PY'
import sys
sys.path.insert(0, 'tools')
from atari_snap import load_snap, save_snap, parse_inputs
a = load_snap('gen/snap/f1000.pkl')
a.run_frames(900, inputs=parse_inputs('1100:15:1,1110:15:0'))
save_snap(a, 'gen/snap/game1900.pkl')
print('saved gen/snap/game1900.pkl at frame', a.frame)
PY
