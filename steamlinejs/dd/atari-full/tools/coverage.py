#!/usr/bin/env python3
"""Run the model through each mission/mode with a simple bot; save coverage."""
from collections import defaultdict
import json, random, sys
from nesmodel import Machine, GEN

def run(mission, mode, frames, seed):
    rnd = random.Random(seed)
    m = Machine()
    m.mem.ram[0x102] = 0x35; m.mem.ram[0x103] = 0x53
    m.executed = set()
    m.indirect = defaultdict(set)
    m.mem.reads = defaultdict(set)
    poked = [False]
    orig = m.step
    def step():
        if m.cpu.pc == 0xE7B1 and not poked[0] and mission is not None:
            m.mem.ram[0x3D] = mission[0]
            m.mem.ram[0x3E] = mission[1]
            poked[0] = True
        orig()
    m.step = step
    state = {'hold': 0, 'btn': 0}
    def inp():
        f = m.frames
        if f < 300:
            # menu: Select presses choose the mode, then Start
            k = f // 20
            if k < 2 * mode and f % 20 < 3 and k % 2 == 0:
                m.buttons = 0x20
            elif 250 <= f < 255:
                m.buttons = 0x10
            else:
                m.buttons = 0
            return
        if state['hold'] <= 0:
            d = rnd.choice([0x01, 0x01, 0x01, 0x09, 0x05, 0x02, 0x00, 0x01])
            a = rnd.choice([0x40, 0x80, 0xC0, 0x00, 0x40])
            state['btn'] = d | a
            state['hold'] = rnd.randint(2, 20)
        state['hold'] -= 1
        b = state['btn']
        if f % 2:
            b &= 0x0F      # release attack buttons every other frame
        if f % 900 < 4:
            b |= 0x10      # Start: continue after game over
        m.buttons = b
    m.input_hook = inp
    m.run_frames(frames)
    tag = f'{mission[0]}{mission[1]}' if mission else 'x'
    m.screenshot(GEN / f'cov-m{tag}-mode{mode}.png')
    print('mission', mission, 'mode', mode, 'final', m.mem.ram[0x3D], m.mem.ram[0x3E], flush=True)
    return m

out_exec = set(); out_ind = defaultdict(set); out_reads = defaultdict(set)
plan = [((ms, sc), 0) for ms in range(4) for sc in range(4)] + [(None, 1), (None, 2), (None, 3)]
frames = int(sys.argv[1]) if len(sys.argv) > 1 else 3000
for i, (mission, mode) in enumerate(plan):
    m = run(mission, mode, frames, i)
    out_exec |= m.executed
    for k, v in m.indirect.items(): out_ind[k] |= v
    for k, v in m.mem.reads.items(): out_reads[k] |= v
json.dump({'executed': sorted(out_exec),
           'indirect': [[list(k), sorted(v)] for k, v in out_ind.items()],
           'reads': [[list(k), sorted(v)] for k, v in out_reads.items()]},
          open(GEN / 'trace.json', 'w'))
print('executed', len(out_exec))
