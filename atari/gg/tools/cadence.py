#!/usr/bin/env python3
"""Picture cadence: for each picture shown, the frames since the previous one
and the age of the game state it shows. cadence.py SNAP [N] (GNG_INPUT)"""
import collections
import os
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from atari_snap import load_snap, parse_inputs  # noqa: E402
from atari_emu import load_labels  # noqa: E402

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
lab = load_labels(os.path.join(HERE, 'gen', 'runtime.lab'))
a = load_snap(sys.argv[1])
n = int(sys.argv[2]) if len(sys.argv) > 2 else 200
inp = parse_inputs(os.environ.get('GNG_INPUT', ''))
cpu, r = a.cpu, a.mem.ram
cm = lab['COMPOSE_MAIN']
logframe = {}          # list -> frame of the log it was composed from
shown = r[lab['SHOWN']]
last = a.frame
gaps, ages = collections.Counter(), collections.Counter()
end = a.frame + n
pend_log = None
into_shown = [0]
import atari_emu  # noqa: E402
_orig = atari_emu.Mem.__setitem__


def _hook(self, addr, v):
    # a list started (run set by the NMI) whose framebuffer is on screen
    if addr == lab['RUN'] and r[lab['READY']] < 2 and r[lab['READY']] == r[lab['SHOWN']]:
        into_shown[0] += 1
    _orig(self, addr, v)


atari_emu.Mem.__setitem__ = _hook
while a.frame < end:
    a.set_input(**inp(a.frame))
    te = a.next_frame
    while cpu.processorCycles < te:
        if cpu.pc == lab['CM_END'] and a.mems == 0xFB:
            logframe[r[lab['BL']]] = pend_log
        if cpu.pc == cm and a.mems == 0xFB and r[lab['LOG_NEW']]:
            pend_log = a.frame
        cpu.step()
    a.next_frame += a.frame_cycles
    a.vblank()
    s = r[lab['SHOWN']]
    if s != shown:
        shown = s
        gaps[a.frame - last] += 1
        if logframe.get(s) is not None:
            ages[a.frame - logframe[s]] += 1
        last = a.frame
print('gaps between pictures (frames: count):', dict(sorted(gaps.items())))
print('age of the shown state (frames: count):', dict(sorted(ages.items())))
print('lists drawn into the framebuffer on screen:', into_shown[0])
