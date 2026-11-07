#!/usr/bin/env python3
"""Execution coverage of the C64 game: coverage.py SCENARIO OUT.json

Scenarios: 'menu' (boot to the options menu, after the intro), 'attract'
(menu -> title, credits, high scores, demo), 'levelN' (start at level N
without trainers: play with a bot until game over), 'inv N' variants via
'levelNi' (invincible), 'original' (the "play original" option).

Records each executed instruction address with the file whose load last
wrote its first byte (or 'boot'), every $D000-$DFFF access made with I/O
mapped (pc, address, r/w), and the $01 values in use.
"""
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import gng  # noqa: E402


class Recorder:
    def __init__(self, g):
        self.g = g
        self.owner = bytearray(65536)        # 0 = boot image, else file number + 1
        self.exec = {}
        self.io = set()
        self.after09 = False
        base = type(g.mem)
        rec = self

        class RMem(base):
            def __getitem__(self, a):
                if 0xD000 <= a < 0xE000 and g.io_on() and rec.after09:
                    rec.io.add((g.cpu.pc, a, 'r'))
                return base.__getitem__(self, a)

            def __setitem__(self, a, v):
                pc = g.cpu.pc
                if 0x5400 <= pc < 0x5800 and g.loads:
                    rec.owner[a] = g.loads[-1][1] + 1
                elif pc < 0x5400 or pc >= 0x5800:
                    if rec.owner[a] < 0x80 and a < 0x0100:
                        rec.owner[a] = 0x80             # copied/generated at run time
                if 0xD000 <= a < 0xE000 and g.io_on() and rec.after09:
                    rec.io.add((pc, a, 'w'))
                base.__setitem__(self, a, v)

        g.mem.__class__ = RMem
        # files already loaded (snapshot start): replay their extents
        loads = json.load(open(os.path.join(gng.HERE, 'gen', 'loads.json')))
        for _, n, _, mode in g.loads:
            for a, h in loads.get(f'{n:02X}', {}).get('runs', []):
                if 0x5400 <= a < 0x5800:
                    continue
                for i in range(len(h) // 2):
                    self.owner[a + i] = n + 1
        for a in range(0xD0, 0xF6):
            if g.loads:
                self.owner[a] = 0x80

    def step_frames(self, n, joy=None):
        g = self.g
        cpu = g.cpu
        end = g.frame + n
        ex = self.exec
        own = self.owner
        while g.frame < end:
            if joy:
                g.joy2 = joy(g.frame)
            stop = g.cycles + 63 * 312
            while g.cycles < stop:
                pc = cpu.pc
                if self.after09:
                    k = (pc, own[pc])
                    ex[k] = ex.get(k, 0) + 1
                g.run(1)
                if not self.after09 and g.loads and g.loads[-1][1] == 0x09 and not (0x5400 <= cpu.pc < 0x5800):
                    self.after09 = True

    def dump(self, path):
        names = {0: 'boot', 0x80: 'copy'}
        out = {'exec': sorted([pc, names.get(o, f'{o - 1:02X}'), n] for (pc, o), n in self.exec.items()),
               'io': sorted([pc, a, k] for pc, a, k in self.io)}
        with open(path, 'w') as f:
            json.dump(out, f)


def bot(seed):
    import random
    rnd = random.Random(seed)
    state = {'joy': 0xF7, 'until': 0}

    def joy(frame):
        if frame >= state['until']:
            r = rnd.random()
            j = 0xF7 if r < 0.55 else 0xFB if r < 0.7 else 0xFF if r < 0.8 else 0xF6 if r < 0.9 else 0xFD
            if rnd.random() < 0.4:
                j &= ~0x10
            state['joy'] = j
            state['until'] = frame + rnd.randint(3, 40)
        return state['joy']
    return joy


def main():
    scen, out = sys.argv[1], sys.argv[2]
    if scen == 'menu':
        g = gng.Game(verbose=False)
        r = Recorder(g)
        f0 = g.frame
        while not g.loads or g.loads[-1][1] != 0x0A:
            r.step_frames(1, lambda f: 0xEF if (f - f0) % 400 in range(200, 210) else 0xFF)
        # browse the menu: down/up/left/right, toggling options, without starting
        seq = [0xFE, 0xFF, 0xFD, 0xFF, 0xFB, 0xFF, 0xF7, 0xFF]
        r.step_frames(1200, lambda f: seq[(f // 30) % len(seq)])
    else:
        g = gng.Game(verbose=False, snapshot=gng.menu_snapshot())
        r = Recorder(g)
        r.after09 = True
        if scen == 'attract':
            g.mem.ram[0xFA] = 9
            r.step_frames(20, lambda f: 0xEF if f % 20 < 6 else 0xFF)
            r.step_frames(4000, lambda f: 0xFF)
        elif scen.startswith('level') or scen == 'original':
            inv = scen.endswith('i')
            level = int(scen[5:].rstrip('i')) if scen.startswith('level') else 1
            opt = g.mem.ram
            opt[0x9155] = int(scen == 'original')
            opt[0x9157] = int(inv)
            opt[0x915A] = 0x80 + level
            opt[0xFA] = 9
            g0 = g.frame
            r.step_frames(40, lambda f: 0xEF if (f - g0) % 20 < 6 else 0xFF)
            # attract mode until fire starts the game
            r.step_frames(300, lambda f: 0xEF if (f - g0) % 100 in range(10, 16) else 0xFF)
            r.step_frames(5000 if not inv else 3000, bot(level))
    r.dump(out)
    print(scen, 'loads', [hex(x[1]) for x in g.loads], 'instructions', len(r.exec))


if __name__ == '__main__':
    main()
