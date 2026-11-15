#!/usr/bin/env python3
"""slack.py SNAP FRAMES [C64]: cycles per frame the game's main loop spends in its
timer waits ($8213, $8225, $814C, $88B1...) - slack means it runs at full speed."""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
WAITS = [(0x8213, 0x8218), (0x8222, 0x822A), (0x814C, 0x8151), (0x9A73, 0x9A78)]
n = int(sys.argv[2])
if len(sys.argv) > 3:
    from cauldron import Cauldron
    c = Cauldron(); c.restore(sys.argv[1]); cpu = c.cpu
    slack = 0
    for f in range(n):
        end = c.cycles + 19656
        while c.cycles < end:
            pc = cpu.pc; c0 = c.cycles
            c.run(1)
            if any(a <= pc < b for a, b in WAITS):
                slack += c.cycles - c0
    print('C64 wait cycles/frame', slack // n)
else:
    from atari_snap import load_snap
    a = load_snap(sys.argv[1]); cpu = a.cpu
    slack = 0
    end = a.frame + n
    while a.frame < end:
        pc = cpu.pc; c0 = cpu.processorCycles
        a.run_until(c0 + 1)
        if any(lo <= pc < hi for lo, hi in WAITS):
            slack += cpu.processorCycles - c0
        if cpu.processorCycles >= a.next_frame:
            a.next_frame += a.frame_cycles
            a.vblank()
    print('Atari wait cycles/frame', slack // n)
