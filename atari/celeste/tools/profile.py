#!/usr/bin/env python3
"""Measure the 6502 time of each game tick (update + draw list) per room.

Counts all CPU cycles (including the VBI) except the idle loops that
wait for the next tick.  A PAL tick has 1.67 frames on average (3 ticks
per 5 frames, ~54,600 cycles); the port keeps full speed while the
average stays below that.  Prints, per room,
the mean and worst cycles per tick and the number of blitter commands.

usage: profile.py [ticks-per-room]
"""
import sys
import random
from pathlib import Path
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
from compare import AtariTicks, L
from emu import FRAME_CYCLES


def main():
    ticks = int(sys.argv[1]) if len(sys.argv) > 1 else 150
    rnd = random.Random(7)
    at = AtariTicks()
    at.advance()
    for b in [''] * 3 + ['j'] * 2 + [''] * 90:
        at.set_buttons(b)
        at.advance()
    idle = {L['MAIN_LOOP'], L['MAIN_LOOP'] + 2, L['WAIT_PRESENT'], L['WAIT_PRESENT'] + 3}
    print('room  mean-cycles  worst  frames(mean/worst)  blits(mean/worst)')
    for room in range(31):
        at.jsr('LOAD_ROOM', room % 8, room // 8)
        costs, blits = [], []
        held, left = '', 0
        for t in range(ticks):
            if left == 0:
                held = ''.join(c for c in 'lrudjx' if rnd.random() < .3)
                left = rnd.randint(1, 10)
            left -= 1
            at.set_buttons(held)
            a = at.a
            cpu = a.cpu
            a.frame_blits = 0
            # count every cycle except the idle loops that wait for the VBI
            busy = 0
            left = False
            while True:
                if cpu.processorCycles >= a.next_frame:
                    a.next_frame += FRAME_CYCLES
                    a.vblank()
                pc = cpu.pc
                if pc == L['READ_INPUT'] and left:
                    break
                c0 = cpu.processorCycles
                a.step()
                if pc == L['READ_INPUT']:
                    left = True
                if pc not in idle:
                    busy += cpu.processorCycles - c0
            costs.append(busy)
            blits.append(a.frame_blits)
        mean = sum(costs) / len(costs)
        print(f'{room:4d}  {mean:11.0f}  {max(costs):6d}  {mean / FRAME_CYCLES:5.2f}/{max(costs) / FRAME_CYCLES:5.2f}'
              f'        {sum(blits) / len(blits):5.1f}/{max(blits)}')


if __name__ == '__main__':
    main()
