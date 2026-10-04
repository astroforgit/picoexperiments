import sys, random, bisect
from collections import Counter
from pathlib import Path
from atari_emu import Atari, load_labels
ROOT = Path('..')
a = Atari(ROOT / 'double-dragon.xex')
a.boot()
lab = load_labels(ROOT / 'gen/runtime.lab')
exec(open('play_emu.py').read().split('shots =')[0].split("lab = load_labels(ROOT / 'gen/runtime.lab')")[1])
a.run_frames(int(sys.argv[1]) if len(sys.argv) > 1 else 850, inputs)
# label ranges inside the runtime code
names = sorted((v, k) for k, v in lab.items() if 0x1080 <= v < 0x2800)
addrs = [v for v, k in names]
cyc = Counter()
cpu = a.cpu
for f in range(30):
    a.set_input(**inputs(a.frame))
    while cpu.processorCycles < a.next_frame:
        pc = cpu.pc
        c0 = cpu.processorCycles
        cpu.step()
        if 0x1080 <= pc < 0x2800:
            i = bisect.bisect_right(addrs, pc) - 1
            cyc[names[i][1]] += cpu.processorCycles - c0
        elif pc >= 0x8000 or pc >= 0x3000:
            cyc['GAME'] += cpu.processorCycles - c0
    a.next_frame += a.frame_cycles
    a.vblank()
for k, v in cyc.most_common(30): print('%-28s %8d per frame' % (k, v // 30))
