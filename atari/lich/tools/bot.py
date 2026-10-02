#!/usr/bin/env python3
"""A bot that plays the port in the headless emulator, to exercise combat,
props, items and stairs over several floors.

It reads the game's RAM (map, fog, entities), walks (BFS) to the nearest
monster, unused prop or seen stairs, else explores, equips the best weapon
and eats when hurt.  Prints a log line per turn and saves screenshots.

    python3 tools/bot.py [turns] [seed]
"""
import collections
import random
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent))
from emu import Atari, load_labels

HERE = Path(__file__).resolve().parent.parent
L = load_labels(HERE / 'lich.lab')
STICK = {(-1, 0): 11, (1, 0): 7, (0, -1): 14, (0, 1): 13}
FLAGS = None


class Bot:
    start_depth = 1
    strong = False

    def __init__(self, seed):
        self.a = Atari(HERE / 'lich.xex')
        self.a.random = seed & 255
        self.a.boot()
        self.r = self.a.mem.ram
        self.rng = random.Random(seed)
        self.shots = 0

    def g(self, name, off=0):
        return self.r[L[name] + off]

    def s8(self, v):
        return v - 256 if v > 127 else v

    def press(self, stick=15, trig=0, key=None, hold=3, after=3):
        a = self.a
        a.set_input(stick=stick, trig=trig)
        if key is not None:
            a.kbcode, a.skstat = key, 0xFB
        a.run_frames(hold)
        a.kbcode, a.skstat = 0xFF, 0xFF
        a.set_input()
        a.run_frames(after)

    def wait_ready(self, limit=600):
        """Until the hero can act (phase 0, no sleep), or a modal is up."""
        for _ in range(limit):
            if self.g('STATE') == 1 and self.g('PHASE') == 0 and self.g('SLEEP') == 0 \
                    and self.g('NEXT_BTN') == 0xFF:
                return True
            self.a.run_frames(1)
        return False

    def tile(self, x, y):
        if 0 <= x < 128 and 0 <= y < 32:
            return self.r[L['TMAP'] + y * 128 + x]
        return 0

    def fog(self, x, y):
        return self.r[L['FOG'] + y * 128 + x] if 0 <= x < 128 and 0 <= y < 32 else 2

    def entities(self):
        out = []
        for i in range(self.g('ENT_N')):
            e = self.g('ENT_LIST', i)
            d = {k: self.r[L['E_' + k] + e] for k in ('ID', 'TX', 'TY', 'HP', 'FL', 'HPMAX')}
            d['idx'] = e
            d['HP'] = self.s8(d['HP'])
            out.append(d)
        return out

    def shot(self, tag):
        self.a.screenshot(HERE / 'shots' / f'bot_{tag}.png', scale=2)

    def manage_items(self):
        """Equip the strongest weapon, eat when below half health."""
        pl = self.g('PL')
        hp, hpmax = self.s8(self.g('E_HP', pl)), self.g('E_HPMAX', pl)
        items = []
        for s in range(8):
            if self.g('IT_ON', s):
                items.append((s, self.g('IT_TYPE', s), self.s8(self.g('IT_ATK', s)), self.g('IT_EQ', s),
                              self.g('IT_TRAIT', s)))
        wpn = self.g('PL_WPN')
        cur = self.s8(self.g('IT_ATK', wpn)) if wpn < 8 else -1
        want = None
        weapons = [i for i in items if i[1] == 1 and not i[3] and i[4] != 2]
        if weapons and (wpn >= 8 or self.g('IT_TRAIT', wpn) != 2):
            best = max(weapons, key=lambda i: i[2])
            if best[2] > cur:
                want = best[0]
        if want is None and hp * 2 < hpmax:
            food = [i for i in items if i[1] == 0]
            if food:
                want = food[0][0]
        if want is None:
            return False
        # open the backpack (X), move the cursor, select, select "use"/"equip"
        self.press(trig=1)
        self.a.run_frames(6)
        for _ in range(want):
            self.press(stick=13)
        self.press(trig=1)
        self.a.run_frames(4)
        self.press(trig=1)
        self.a.run_frames(10)
        # close anything still open (left closes menus)
        for _ in range(3):
            if self.g('MODAL_TOP') != 0xFF:
                self.press(stick=11)
        return True

    def target(self, px, py, ents):
        """BFS over known floor; returns the first step towards a goal."""
        occupied = {}
        for e in ents:
            if e['HP'] > 0:
                occupied[(e['TX'], e['TY'])] = e
        goals = set()
        for e in ents:
            if e['HP'] <= 0 or e['idx'] == self.g('PL') or self.fog(e['TX'], e['TY']) == 2:
                continue
            fl = e['FL']
            if fl & 1:                        # mob
                goals.add((e['TX'], e['TY']))
            elif fl & 2 and not fl & 0x20 and e['ID'] in (4, 5, 6, 7, 8, 9, 18, 21):
                goals.add((e['TX'], e['TY']))
        stairs = [(x, y) for y in range(32) for x in range(128)
                  if self.tile(x, y) == 16 and self.fog(x, y) != 2]
        flags = FLAGS
        prev = {(px, py): None}
        q = collections.deque([(px, py)])
        found = None
        explore = None
        while q:
            c = q.popleft()
            if c != (px, py) and (c in goals):
                found = c
                break
            for d in ((-1, 0), (1, 0), (0, -1), (0, 1)):
                n = (c[0] + d[0], c[1] + d[1])
                if n in prev:
                    continue
                t = self.tile(*n)
                if self.fog(*n) == 2:
                    if explore is None:
                        explore = c
                    continue
                if n in goals:
                    prev[n] = c
                    q.append(n)
                    continue
                if flags[t] & 1:
                    continue
                if n in occupied and not occupied[n]['FL'] & 8:
                    continue
                prev[n] = c
                q.append(n)
        if found is None and stairs and (self.goal_stairs or not goals):
            s = stairs[0]
            if s in prev:
                found = s
        if found is None:
            found = explore
        if found is None or found == (px, py):
            return self.rng.choice(list(STICK))
        c = found
        while prev[c] != (px, py):
            c = prev[c]
            if c is None:
                return self.rng.choice(list(STICK))
        return (c[0] - px, c[1] - py)

    def run(self, turns):
        global FLAGS
        FLAGS = [self.r[L['TILE_FLAGS'] + i] for i in range(256)]
        a = self.a
        a.run_frames(100)
        self.press(trig=1)
        a.run_frames(400)
        if self.start_depth > 1:
            import deep
            deep.goto_depth(a, self.start_depth)
            a.run_frames(200)
            if self.strong:
                pl = self.g('PL')
                self.r[L['E_HP'] + pl] = 99
                self.r[L['E_HPMAX'] + pl] = 99
                self.r[L['E_ATK'] + pl] = 20
        self.goal_stairs = False
        depth_turns = 0
        last_depth = 1
        for turn in range(turns):
            if self.g('STATE') == 0:
                print('back on the title screen at turn', turn)
                self.shot(f'end_{turn}')
                return
            if self.g('MODAL_TOP') != 0xFF:
                self.shot(f'modal_{self.shots}')
                self.shots += 1
                self.press(key=0x12, after=10)
                continue
            if not self.wait_ready():
                print('not ready: phase', self.g('PHASE'), 'sleep', self.g('SLEEP'))
                a.run_frames(30)
                continue
            depth = self.g('PL_DEPTH')
            if depth != last_depth:
                last_depth, depth_turns, self.goal_stairs = depth, 0, False
                self.shot(f'floor{depth}')
            depth_turns += 1
            if depth_turns > 120:
                self.goal_stairs = True
            if turn % 15 == 0 and self.manage_items():
                continue
            pl = self.g('PL')
            px, py = self.g('E_TX', pl), self.g('E_TY', pl)
            ents = self.entities()
            d = self.target(px, py, ents)
            self.press(stick=STICK[d], hold=3, after=2)
            hp = self.s8(self.g('E_HP', pl))
            print(f'turn {turn} depth {depth} pos {px},{py} hp {hp}/{self.g("E_HPMAX", pl)} '
                  f'lvl {self.g("PL_LVL")} xp {self.g("PL_XP")} ents {self.g("ENT_N")} inv {self.g("INV_N")} '
                  f'wpn {self.g("PL_WPN")}', flush=True)
            if turn % 100 == 0:
                self.shot(f't{turn}')


if __name__ == '__main__':
    b = Bot(int(sys.argv[2]) if len(sys.argv) > 2 else 1)
    if len(sys.argv) > 3:
        b.start_depth = int(sys.argv[3])
        b.strong = len(sys.argv) > 4
    b.run(int(sys.argv[1]) if len(sys.argv) > 1 else 300)
