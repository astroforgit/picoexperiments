#!/usr/bin/env python3
"""Count game ticks per 300 PAL frames (30 Hz = 180) after a shot.py script."""
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent))
from emu import load_labels
import shot
L = load_labels(Path(__file__).resolve().parent.parent / 'lich.lab')
a = shot.run(sys.argv[1])
gu = L['GAME_UPDATE']
n = 0; blits = a.blits
end = a.frame + 300
while a.frame < end:
    t = a.next_frame
    while a.cpu.processorCycles < t:
        if a.cpu.pc == gu:
            n += 1
        a.step()
    a.next_frame += 32760
    a.vblank()
print(sys.argv[1], 'ticks per 300 frames:', n, 'blits/tick:', (a.blits - blits) / max(n, 1))
