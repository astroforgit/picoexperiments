#!/usr/bin/env bash
# Rebuild the Atari model snapshots used by the test tools (after a build):
# gen/snap/f1000.pkl (attract mode), gen/snap/game1900.pkl (level 1 play),
# gen/snap/menu300.pkl (options menu) and the NTSC level 1 snapshot
# gen/snap/ntsc1900.pkl
set -euo pipefail
cd "$(dirname "$0")/.."
python3 tools/atari_snap.py save 300 gen/snap/menu300.pkl
for m in pal ntsc; do
  if [ $m = ntsc ]; then export GNG_NTSC=1; out=ntsc; else unset GNG_NTSC; out=game; fi
  python3 tools/atari_snap.py save 1000 gen/snap/$m-f1000.pkl '320:15:1,330:15:0'
  python3 - "$m" "$out" <<'PY'
import sys
sys.path.insert(0, 'tools')
from atari_snap import load_snap, save_snap, parse_inputs
m, out = sys.argv[1], sys.argv[2]
a = load_snap(f'gen/snap/{m}-f1000.pkl')
a.run_frames(900, inputs=parse_inputs('1100:15:1,1110:15:0'))
save_snap(a, f'gen/snap/{out}1900.pkl')
print(f'saved gen/snap/{out}1900.pkl at frame', a.frame)
PY
done
mv gen/snap/pal-f1000.pkl gen/snap/f1000.pkl
rm -f gen/snap/ntsc-f1000.pkl
