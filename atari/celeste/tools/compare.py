#!/usr/bin/env python3
"""Play the same input script on the Lua original and on the Atari port.

Each game tick (PICO-8 _update/_draw at 30 Hz) gets the same buttons.
The Atari build is sampled whenever it enters read_input, i.e. once the
previous tick's update and draw have finished.  Prints the first
divergences of room / player kind / position.

usage: compare.py [script-name] [--shots DIR]
"""
import sys
import argparse
from pathlib import Path
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
from emu import Atari, load_labels, FRAME_CYCLES
from pico_ref import PicoRef

ROOT = HERE.parent
L = load_labels(ROOT / 'celeste.lab')
STICK = {'u': 1, 'd': 2, 'l': 4, 'r': 8}


class AtariTicks:
    def __init__(self):
        self.a = Atari(ROOT / 'celeste.xex')
        self.a.boot()
        self.ram = self.a.mem.ram

    def advance(self):
        """Run until the start of the next tick (entry of read_input)."""
        a = self.a
        cpu = a.cpu
        target = L['READ_INPUT']
        left = False        # a VBI may return to read_input: only an
        while True:         # arrival after executing it ends the tick
            if cpu.processorCycles >= a.next_frame:
                a.next_frame += FRAME_CYCLES
                a.vblank()
            pc = cpu.pc
            if pc == target and left:
                break
            a.step()
            if pc == target:
                left = True

    def set_buttons(self, buttons):
        stick = 15
        for b in buttons:
            if b in STICK:
                stick &= ~STICK[b]
        self.a.set_input(stick=stick, trig='j' in buttons, dash='x' in buttons)

    def jsr(self, name, a=0, y=0):
        """Call a routine from the current point (at read_input entry)."""
        cpu = self.a.cpu
        ret = cpu.pc
        sp = cpu.sp
        cpu.stPushWord(ret - 1)
        cpu.a, cpu.y = a, y
        cpu.pc = L[name]
        while not (cpu.pc == ret and cpu.sp == sp):
            if cpu.processorCycles >= self.a.next_frame:
                self.a.next_frame += FRAME_CYCLES
                self.a.vblank()
            self.a.step()

    def balloons(self):
        out = {}
        for i in range(self.byte('OBJ_COUNT')):
            if self.byte('O_TYPE', i) == 4:
                off = (self.byte('O_V1', i) << 8 | self.byte('O_V0', i)) / 65536
                out[(self.byte('O_X', i) - 64, self.byte('O_V2', i) - 64)] = off + self.byte('O_V4', i)
        return out

    def stats(self):
        fruit = sum(self.ram[L['GOT_FRUIT'] + i] for i in range(30))
        return self.byte('DEATHS') | self.byte('DEATHS', 1) << 8, fruit, self.byte('MAX_DJUMP')

    def byte(self, name, off=0):
        return self.ram[L[name] + off]

    def player(self):
        n = self.byte('OBJ_COUNT')
        for i in range(n):
            t = self.byte('O_TYPE', i)
            if t in (1, 2):
                s = lambda f, lo, hi: ((self.byte(hi, i) << 16 | self.byte(lo, i) << 8 | self.byte(f, i))
                                       ^ 0x800000) - 0x800000
                return ('player' if t == 1 else 'spawn', self.byte('O_X', i) - 64, self.byte('O_Y', i) - 64,
                        s('O_SXF', 'O_SXL', 'O_SXH') / 65536, s('O_SYF', 'O_SYL', 'O_SYH') / 65536)
        return None

    def room(self):
        return self.byte('ROOM_X'), self.byte('ROOM_Y')


def script_start():
    """Press jump on the title, then wait for the first room."""
    return [''] * 5 + ['j'] * 3 + [''] * 120


SCRIPTS = {
    # walk right, jump, dash up-right in room 1
    'basic': script_start() + ['r'] * 20 + ['rj'] * 6 + ['r'] * 10 + [''] * 10 +
             ['l'] * 15 + ['j'] * 8 + [''] * 20 + ['ux'] * 2 + [''] * 30 +
             ['rj'] * 12 + ['rux'] * 3 + ['r'] * 40 + [''] * 30,
}


def ref_sync_balloons(ref, at):
    """Give the reference's balloons the Atari's random phases."""
    offs = at.balloons()
    lua = ref.lua
    for o in lua.eval('objects').values():
        if o.type == lua.globals().balloon:
            key = (int(o.x), int(o.start))
            if key in offs:
                o.offset = offs[key]


def ref_stats(ref):
    g = ref.lua.globals()
    fruit = sum(1 for v in g.got_fruit.values() if v)
    return int(g.deaths), fruit, int(g.max_djump)


def fuzz(rooms, ticks, seed, trace=None):
    import random
    total = 0
    for room in rooms:
        rnd = random.Random(seed * 100 + room)
        ref = PicoRef(seed=seed)
        at = AtariTicks()
        at.advance()
        # start the game in both
        for b in [''] * 3 + ['j'] * 2 + [''] * 90:
            at.set_buttons(b); ref.step(b); at.advance()
        rx, ry = room % 8, room // 8
        ref.lua.globals().load_room(rx, ry)
        at.jsr('LOAD_ROOM', rx, ry)
        ref_sync_balloons(ref, at)
        held, left = '', 0
        diffs = 0
        cur = (rx, ry)
        for t in range(ticks):
            if left == 0:
                held = ''.join(c for c in 'lrudjx' if rnd.random() < {'l': .3, 'r': .4, 'u': .25, 'd': .1, 'j': .35, 'x': .15}[c])
                left = rnd.randint(1, 12)
            left -= 1
            at.set_buttons(held)
            ref.step(held)
            at.advance()
            if ref.room() != cur:
                cur = ref.room()
                ref_sync_balloons(ref, at)
            rr, rp, ar, ap_ = ref.room(), ref.player(), at.room(), at.player()
            same = rr == ar and (rp is None) == (ap_ is None)
            if same and rp:
                same = (rp[0] == ap_[0] and rp[1] == ap_[1] and rp[2] == ap_[2]
                        and abs(rp[3] - ap_[3]) < 1e-3 and abs(rp[4] - ap_[4]) < 1e-3)
            same = same and ref_stats(ref) == at.stats()
            if trace and t >= trace[0]:
                print(f'   {t} [{held}] ref {rr} {rp}\n          atari {ar} {ap_}')
            if not same:
                diffs += 1
                print(f"room {room} tick {t} [{held}] ref {rr} {rp} {ref_stats(ref)}")
                print(f"                 atari {ar} {ap_} {at.stats()}")
                break
        total += diffs
        print(f'room {room:2d}: {"ok" if not diffs else "DIVERGED"}  deaths={ref_stats(ref)[0]} room now {ref.room()}')
    return total


def fmt(p):
    if p is None:
        return 'none'
    return f'{p[0]:6s} x={p[1]:7.2f} y={p[2]:7.2f} sx={p[3]:6.2f} sy={p[4]:6.2f}'


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('script', nargs='?', default='basic')
    ap.add_argument('--shots')
    ap.add_argument('--every', type=int, default=0)
    ap.add_argument('--verbose', action='store_true')
    ap.add_argument('--fuzz', type=int, default=0, help='ticks per room')
    ap.add_argument('--rooms', default='0-30')
    ap.add_argument('--seed', type=int, default=1)
    ap.add_argument('--trace', type=int, default=0)
    args = ap.parse_args()
    if args.fuzz:
        a, b = (int(v) for v in args.rooms.split('-'))
        sys.exit(1 if fuzz(range(a, b + 1), args.fuzz, args.seed, [args.trace] if args.trace else None) else 0)
    script = SCRIPTS[args.script]
    ref = PicoRef()
    at = AtariTicks()
    at.advance()
    diffs = 0
    for t, buttons in enumerate(script):
        at.set_buttons(buttons)
        ref.step(buttons)
        at.advance()
        rr, rp = ref.room(), ref.player()
        ar, ap_ = at.room(), at.player()
        same = rr == ar and (rp is None) == (ap_ is None)
        if same and rp:
            same = rp[0] == ap_[0] and int(rp[1]) == ap_[1] and int(rp[2]) == ap_[2]
        if args.verbose or not same:
            print(f'{t:4d} {buttons:4s} ref {rr} {fmt(rp)}')
            print(f'          atari {ar} {fmt(ap_)}{"" if same else "   <-- differs"}')
        if not same:
            diffs += 1
            if diffs > 12:
                break
        if args.shots and args.every and t % args.every == 0:
            ref.image(f'{args.shots}/ref_{t:04d}.png')
            at.a.screenshot(f'{args.shots}/atari_{t:04d}.png')
    print('ticks', t + 1, 'differences', diffs)


if __name__ == '__main__':
    main()
