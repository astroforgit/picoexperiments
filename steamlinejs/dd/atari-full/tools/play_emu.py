"""Boot, start a 1-player game and play a little; screenshots + timing."""
import sys, random
from pathlib import Path
from atari_emu import Atari, load_labels
ROOT = Path('..')
a = Atari(ROOT / 'double-dragon.xex', pal='--ntsc' not in sys.argv)
a.boot()
lab = load_labels(ROOT / 'gen/runtime.lab')
rnd = random.Random(1)
st = {'h': 0, 'in': {}}
def inputs(f):
    if f < 700:
        return dict(consol=6 if f in range(380, 386) or f in range(560, 566) else 7)
    if st['h'] <= 0:
        st['in'] = dict(stick=rnd.choice([7, 7, 7, 6, 5, 11, 15]), trig=rnd.choice([0, 1]), shift=rnd.choice([False, True]))
        st['h'] = rnd.randint(2, 15)
    st['h'] -= 1
    d = dict(st['in'])
    if f % 2: d['trig'] = 0; d['shift'] = False
    return d
shots = [int(x) for x in sys.argv[1:] if x.isdigit()]
for s in shots:
    a.run_frames(s - a.frame, inputs)
    a.screenshot(ROOT / f'gen/play-{s}.png')
    r = a.mem.ram
    print(s, 'stage', r[0x3D], r[0x3E], '$100=%02x' % r[0x100], 'drops', r[lab['DROPS']], 'blits', a.blits, flush=True)
