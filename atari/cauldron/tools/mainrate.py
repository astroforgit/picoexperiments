#!/usr/bin/env python3
"""mainrate.py SNAP FRAMES [ADDR]: executions of the game's main loop jump ($8482) per frame."""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from atari_snap import load_snap  # noqa: E402
a = load_snap(sys.argv[1]); cpu = a.cpu; n = 0
frames = int(sys.argv[2]); addr = int(sys.argv[3], 16) if len(sys.argv) > 3 else 0x8482
end = a.frame + frames
while a.frame < end:
    if cpu.pc == addr:
        n += 1
    a.run_until(cpu.processorCycles + 1)
    if cpu.processorCycles >= a.next_frame:
        a.next_frame += a.frame_cycles
        a.vblank()
print(f'${addr:04X}: {n / frames:.2f} per frame')
