#!/usr/bin/env python3
"""Game speed from a snapshot: frame waits of the game's main loop ($3AB4),
game ticks and pictures over N frames. speed.py SNAP [N]"""
import os
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from atari_snap import load_snap  # noqa: E402
from atari_emu import load_labels  # noqa: E402

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
lab = load_labels(os.path.join(HERE, 'gen', 'runtime.lab'))
a = load_snap(sys.argv[1])
n = int(sys.argv[2]) if len(sys.argv) > 2 else 200
cpu, r = a.cpu, a.mem.ram
iw = lab['IDLE_WAIT']
waits = pics = 0
orig = a.blit_list


def bl():
    global pics
    v = a.vregs
    if 0x65000 <= (v[0x50] | v[0x51] << 8 | (v[0x52] & 7) << 16) < 0x67A60:
        pics += 1
    return orig()


a.blit_list = bl
t0 = r[lab['TICKS']]
f0 = r[0x0700]
end = a.frame + n
while a.frame < end:
    te = a.next_frame
    while cpu.processorCycles < te:
        if cpu.pc == iw:
            waits += 1
        cpu.step()
    a.next_frame += a.frame_cycles
    a.vblank()
print(f'{n} frames ({"PAL" if a.pal else "NTSC"}): {(r[lab["TICKS"]] - t0) & 255} ticks, '
      f'game frames ($0700) {(r[0x0700] - f0) & 255}, frame waits {waits}, pictures {pics}')
