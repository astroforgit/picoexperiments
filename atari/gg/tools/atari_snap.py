#!/usr/bin/env python3
"""Save/restore Atari model state to skip the slow boot:
atari_snap.py save FRAME OUT [GNG_INPUT]   |  used by other tools via load_snap()"""
import os
import pickle
import sys
import time
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from atari_emu import Atari  # noqa: E402

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FIELDS = ('vregs', 'vbxe_page', 'memc', 'mems', 'memb', 'palette', 'csel', 'psel', 'pal', 'frame_cycles',
          'pokey', 'portb', 'nmien', 'nmist', 'frame', 'next_frame', 'blits', 'blit_busy_until', 'consol',
          'skstat', 'kbcode', 'in_stick', 'in_stick1', 'in_trig0', 'in_trig1', 'in_pot', 'random', 'dlist',
          'dmactl', 'irqen', 'irqst', 'last_key')


def parse_inputs(text):
    inputs = {}
    for item in filter(None, text.split(',')):
        f, st, tr = item.split(':')
        inputs[int(f)] = (int(st, 0), int(tr))
    state = {'stick': 15, 'trig': 0}

    def inp(frame):
        if frame in inputs:
            state['stick'], state['trig'] = inputs[frame]
        return dict(stick=state['stick'], trig=state['trig'])
    return inp


def save_snap(a, path):
    c = a.cpu
    st = {k: getattr(a, k) for k in FIELDS}
    st['ram'] = bytes(a.mem.ram)
    st['vram'] = a.vram.tobytes()
    st['cpu'] = (c.pc, c.a, c.x, c.y, c.sp, c.p, c.processorCycles)
    with open(path, 'wb') as f:
        pickle.dump(st, f)


def load_snap(path):
    import numpy as np
    a = Atari(os.path.join(HERE, 'gng.xex'))
    with open(path, 'rb') as f:
        st = pickle.load(f)
    a.mem.ram[:] = st.pop('ram')
    a.vram = np.frombuffer(st.pop('vram'), dtype=np.uint8).copy()
    c = a.cpu
    c.pc, c.a, c.x, c.y, c.sp, c.p, c.processorCycles = st.pop('cpu')
    for k, v in st.items():
        setattr(a, k, v)
    return a


if __name__ == '__main__':
    a = Atari(os.path.join(HERE, 'gng.xex'), pal=os.environ.get('GNG_NTSC') != '1')   # GNG_NTSC=1: NTSC machine
    a.boot()
    t = time.time()
    a.run_frames(int(sys.argv[2]), inputs=parse_inputs(sys.argv[4] if len(sys.argv) > 4 else ''))
    save_snap(a, sys.argv[3])
    print('saved at frame', a.frame, round(time.time() - t, 1), 's')
