#!/usr/bin/env python3
"""Run the original The Lair Lua (pico/lair.lua) headless, with drawing.

A PICO-8 shim (lupa, Lua 5.2) implements the drawing API the cart uses
(camera, clip, pal/palt, spr, sspr, map, print, rectfill, circfill, circ,
pset, pget, rect), btn(), rnd(), cartdata and a rough sfx channel model
for stat(18)/stat(19).  It renders 128x128 frames, so the original can be
looked at and compared with the Atari port.

    python3 tools/pico_ref.py "script"     (same steps as tools/shot.py)
"""
import math
import random
import re
import sys
from pathlib import Path

import numpy as np
from lupa import lua52

HERE = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(Path(__file__).resolve().parent))
from font import GLYPHS                      # noqa: E402

PAL = np.array([(0, 0, 0), (29, 43, 83), (126, 37, 83), (0, 135, 81), (171, 82, 54),
                (95, 87, 79), (194, 195, 199), (255, 241, 232), (255, 0, 77),
                (255, 163, 0), (255, 255, 39), (0, 231, 88), (41, 173, 255),
                (131, 118, 156), (255, 119, 168), (255, 204, 170)], dtype=np.uint8)

PRELUDE = r'''
function add(t,v) if t==nil then return end t[#t+1]=v return v end
function del(t,v) if t==nil then return end for i=1,#t do if t[i]==v then table.remove(t,i) return v end end end
function all(c)
  if c==nil then return function() end end
  local i=0 local prev=nil
  return function()
    if i==0 or c[i]==prev then i=i+1 end
    prev=c[i]
    return prev
  end
end
function flr(x) return math.floor(x or 0) end
function abs(x) return math.abs(x or 0) end
function min(a,b) return math.min(a,b or 0) end
function max(a,b) return math.max(a,b or 0) end
function mid(a,b,c) b=b or 0 c=c or 0 if a>b then a,b=b,a end return math.max(a,math.min(b,c)) end
function sqrt(x) return math.sqrt(x or 0) end
function sgn(x) if (x or 0)<0 then return -1 end return 1 end
function sin(x) return -math.sin((x or 0)*2*math.pi) end
function cos(x) return math.cos((x or 0)*2*math.pi) end
function sub(s,i,j) return string.sub(s,i,j) end
function rnd(n) return math.floor(py_rnd()*(n or 1)*65536)/65536 end
'''


def compound(line):
    m = re.search(r'([\w\.\[\]]+)\s*([-+*/%])=(.*)$', line)
    if not m:
        return line
    lhs, op, rhs = m.group(1), m.group(2), m.group(3)
    return line[:m.start()] + f'{lhs}={lhs}{op}({rhs})'


def convert(src):
    out = []
    for line in src.split('\n'):
        line = line.replace('!=', '~=')
        m = re.match(r'^(.*?)\bif\s*\(', line)
        if m and ' then' not in line and not re.search(r'\bthen\b', line):
            start = m.end() - 1
            depth = 0
            for i in range(start, len(line)):
                depth += line[i] == '('
                depth -= line[i] == ')'
                if depth == 0:
                    break
            cond, rest = line[start:i + 1], line[i + 1:]
            line = f'{m.group(1)}if {cond} then {compound(rest)} end'
        else:
            line = compound(line)
        out.append(line)
    return '\n'.join(out)


class Pico:
    def __init__(self, seed=1, buttons=None):
        self.cart = bytearray((HERE / 'pico' / 'cart.bin').read_bytes())
        c = self.cart
        self.sheet = np.zeros((128, 128), dtype=np.uint8)
        for i in range(0x2000):
            self.sheet[i // 64, (i % 64) * 2] = c[i] & 15
            self.sheet[i // 64, (i % 64) * 2 + 1] = c[i] >> 4
        self.flags = c[0x3000:0x3100]
        self.screen = np.zeros((128, 128), dtype=np.uint8)
        self.rng = random.Random(seed)
        self.buttons = buttons or (lambda frame: 0)
        self.frame = 0
        self.cart_data = [0] * 64
        self.ch_end = [0, 0, 0, 0]         # frame when the sfx on a channel ends
        self.ch_sfx = [-1, -1, -1, -1]
        self.sound_log = []
        self.reset_pal()
        self.spal = list(range(16))
        self.cam = (0, 0)
        self.clipr = (0, 0, 128, 128)
        lua = lua52.LuaRuntime(unpack_returned_tuples=True)
        self.lua = lua
        g = lua.globals()
        g.py_rnd = self.rng.random
        lua.execute(PRELUDE)
        for name in ('camera', 'clip', 'cls', 'pal', 'palt', 'spr', 'sspr', 'map', 'print',
                     'rectfill', 'rect', 'circfill', 'circ', 'pset', 'pget', 'btn', 'peek',
                     'poke', 'dget', 'dset', 'cartdata', 'music', 'sfx', 'stat', 'fget', 'line'):
            g[name] = getattr(self, 'f_' + name)
        src = (HERE / 'pico' / 'lair.lua').read_bytes().decode('latin-1')
        lua.execute(convert(src))
        self.g = g

    # ------------------------------------------------------------ state
    def reset_pal(self):
        self.dpal = list(range(16))
        self.palt = [i == 0 for i in range(16)]

    def f_camera(self, x=0, y=0):
        self.cam = (math.floor(x or 0), math.floor(y or 0))

    def f_clip(self, x=None, y=None, w=None, h=None):
        if x is None:
            self.clipr = (0, 0, 128, 128)
        else:
            x, y = math.floor(x), math.floor(y)
            self.clipr = (max(x, 0), max(y, 0), min(x + math.floor(w), 128), min(y + math.floor(h), 128))

    def f_cls(self, c=0):
        self.screen[:, :] = c
        self.clipr = (0, 0, 128, 128)

    def f_pal(self, a=None, b=None, p=0):
        if a is None:
            self.reset_pal()
            self.spal = list(range(16))
            return
        a, b = int(a) & 15, int(b) & 15
        if p == 1:
            self.spal[a] = b
        else:
            self.dpal[a] = b

    def f_palt(self, c=None, t=None):
        if c is None:
            self.palt = [i == 0 for i in range(16)]
        else:
            self.palt[int(c) & 15] = bool(t)

    def put(self, x, y, c):
        x -= self.cam[0]
        y -= self.cam[1]
        x0, y0, x1, y1 = self.clipr
        if x0 <= x < x1 and y0 <= y < y1:
            self.screen[y, x] = c

    def hspan(self, xa, xb, y, c):
        x0, y0, x1, y1 = self.clipr
        y -= self.cam[1]
        if not (y0 <= y < y1):
            return
        xa, xb = xa - self.cam[0], xb - self.cam[0]
        if xa > xb:
            xa, xb = xb, xa
        xa, xb = max(xa, x0), min(xb, x1 - 1)
        if xa <= xb:
            self.screen[y, xa:xb + 1] = c

    def f_pset(self, x, y, c=6):
        self.put(math.floor(x), math.floor(y), self.dpal[int(c) & 15])

    def f_pget(self, x, y):
        x, y = math.floor(x), math.floor(y)
        if 0 <= x < 128 and 0 <= y < 128:
            return int(self.screen[y, x])
        return 0

    def f_rectfill(self, x0, y0, x1, y1, c=6):
        x0, y0, x1, y1 = (math.floor(v) for v in (x0, y0, x1, y1))
        if x0 > x1:
            x0, x1 = x1, x0
        if y0 > y1:
            y0, y1 = y1, y0
        col = self.dpal[int(c) & 15]
        for y in range(y0, y1 + 1):
            self.hspan(x0, x1, y, col)

    def f_rect(self, x0, y0, x1, y1, c=6):
        x0, y0, x1, y1 = (math.floor(v) for v in (x0, y0, x1, y1))
        col = self.dpal[int(c) & 15]
        self.hspan(x0, x1, y0, col)
        self.hspan(x0, x1, y1, col)
        for y in range(min(y0, y1), max(y0, y1) + 1):
            self.put(x0, y, col)
            self.put(x1, y, col)

    def f_line(self, *a):
        pass

    def circle_spans(self, r):
        """PICO-8 style circle: (dy, dx) pairs of the outline."""
        pts = []
        x, y = r, 0
        d = 1 - r
        while x >= y:
            pts.append((x, y))
            y += 1
            if d < 0:
                d += 2 * y + 1
            else:
                x -= 1
                d += 2 * (y - x) + 1
        return pts

    def f_circfill(self, cx, cy, r=4, c=6):
        cx, cy, r = math.floor(cx), math.floor(cy), math.floor(r)
        if r < 0:
            return
        col = self.dpal[int(c) & 15]
        for x, y in self.circle_spans(r):
            self.hspan(cx - x, cx + x, cy + y, col)
            self.hspan(cx - x, cx + x, cy - y, col)
            self.hspan(cx - y, cx + y, cy + x, col)
            self.hspan(cx - y, cx + y, cy - x, col)

    def f_circ(self, cx, cy, r=4, c=6):
        cx, cy, r = math.floor(cx), math.floor(cy), math.floor(r)
        col = self.dpal[int(c) & 15]
        for x, y in self.circle_spans(r):
            for px, py in ((x, y), (y, x)):
                for sx in (-1, 1):
                    for sy in (-1, 1):
                        self.put(cx + sx * px, cy + sy * py, col)

    def blit(self, sx, sy, sw, sh, dx, dy, dw, dh, fx=False, fy=False):
        dx, dy = math.floor(dx), math.floor(dy)
        for j in range(dh):
            ty = sy + (j * sh) // dh
            if fy:
                ty = sy + sh - 1 - (j * sh) // dh
            for i in range(dw):
                tx = sx + (i * sw) // dw
                if fx:
                    tx = sx + sw - 1 - (i * sw) // dw
                if not (0 <= tx < 128 and 0 <= ty < 128):
                    continue
                c = int(self.sheet[ty, tx])
                if self.palt[c]:
                    continue
                self.put(dx + i, dy + j, self.dpal[c])

    def f_spr(self, n, x, y, w=1, h=1, fx=False, fy=False):
        n = int(n)
        w, h = w or 1, h or 1
        sw, sh = math.floor(w * 8), math.floor(h * 8)
        self.blit((n % 16) * 8, (n // 16) * 8, sw, sh, x, y, sw, sh, fx, fy)

    def f_sspr(self, sx, sy, sw, sh, dx, dy, dw=None, dh=None, fx=False, fy=False):
        sx, sy, sw, sh = (math.floor(v) for v in (sx, sy, sw, sh))
        dw = sw if dw is None else math.floor(dw)
        dh = sh if dh is None else math.floor(dh)
        self.blit(sx, sy, sw, sh, dx, dy, dw, dh, fx, fy)

    def f_map(self, cx, cy, sx, sy, w, h, layer=0):
        cx, cy, sx, sy = (math.floor(v) for v in (cx, cy, sx, sy))
        for ty in range(math.floor(h)):
            for tx in range(math.floor(w)):
                mx, my = cx + tx, cy + ty
                if not (0 <= mx < 128 and 0 <= my < 64):
                    continue
                t = self.mget(mx, my)
                if t == 0:
                    continue
                if layer and (self.flags[t] & layer) != layer:
                    continue
                self.blit((t % 16) * 8, (t // 16) * 8, 8, 8, sx + tx * 8, sy + ty * 8, 8, 8)

    def mget(self, x, y):
        if y < 32:
            return self.cart[0x2000 + y * 128 + x]
        return self.cart[0x1000 + (y - 32) * 128 + x]

    def f_fget(self, t, f=None):
        v = self.flags[int(t)]
        return v if f is None else bool(v >> int(f) & 1)

    def f_print(self, s, x=0, y=0, c=6):
        s = str(s) if not isinstance(s, str) else s
        if isinstance(s, bytes):
            s = s.decode('latin-1')
        x0 = x = math.floor(x)
        y = math.floor(y)
        col = self.dpal[int(c) & 15]
        for ch in s:
            if ch == '\n':
                x = x0
                y += 6
                continue
            g = GLYPHS.get(ch.lower(), GLYPHS.get('?'))
            for gy, row in enumerate(g):
                for gx, p in enumerate(row):
                    if p == '#':
                        self.put(x + gx, y + gy, col)
            x += 4

    def f_btn(self, b):
        return bool(self.buttons(self.frame) >> int(b) & 1)

    def f_peek(self, a):
        return self.cart[int(a)] if int(a) < 0x8000 else 0

    def f_poke(self, a, v):
        a = int(a)
        if a < 0x4300:
            self.cart[a] = int(v) & 255

    def f_cartdata(self, name):
        pass

    def f_dget(self, i):
        return self.cart_data[int(i)]

    def f_dset(self, i, v):
        self.cart_data[int(i)] = v

    def sfx_frames(self, n):
        base = 0x3200 + n * 68
        speed = max(self.cart[base + 65], 1)
        ls, le = self.cart[base + 66], self.cart[base + 67]
        notes = le if ls < le else 32
        if ls < le:
            return 1 << 30               # looping
        return int(notes * speed * 183 / 22050 * 60) + 1

    def f_sfx(self, n, ch=-1, off=0):
        n = int(n)
        self.sound_log.append((self.frame, 'sfx', n, ch))
        if n == -1:
            if ch is not None and ch >= 0:
                self.ch_sfx[int(ch)] = -1
            return
        if ch is None or ch < 0:
            ch = next((i for i in range(4) if self.ch_sfx[i] < 0 or self.ch_end[i] <= self.frame), 3)
        ch = int(ch)
        self.ch_sfx[ch] = n
        self.ch_end[ch] = self.frame + self.sfx_frames(n)

    def f_music(self, n, fade=0, mask=0):
        self.sound_log.append((self.frame, 'music', int(n)))

    def f_stat(self, n):
        n = int(n)
        if 16 <= n <= 19:
            ch = n - 16
            return self.ch_sfx[ch] if self.ch_end[ch] > self.frame else -1
        return 0

    # ------------------------------------------------------------ running
    def step(self):
        self.g._update60()
        self.g._draw()
        self.frame += 1

    def image(self):
        return PAL[np.array(self.spal, dtype=np.uint8)[self.screen]]

    def save(self, path, scale=3):
        from PIL import Image
        im = Image.fromarray(self.image(), 'RGB')
        im.resize((128 * scale, 128 * scale), Image.NEAREST).save(path)


BTN = {'l': 1, 'r': 2, 'u': 4, 'd': 8, 'z': 16, 'x': 32}


def run(script, seed=1, shots=None):
    """Steps: N (frames), z/x (tap), Hk:N (hold buttons k for N frames), s:name."""
    held = [0]
    p = Pico(seed, lambda f: held[0])
    out = shots or HERE / 'shots'
    out.mkdir(exist_ok=True)
    for st in script.split(','):
        st = st.strip()
        if not st:
            continue
        if st.startswith('s:'):
            p.save(out / f'ref_{st[2:]}.png')
            print('shot', st[2:], 'frame', p.frame)
        elif st.isdigit():
            for _ in range(int(st)):
                p.step()
        elif st.startswith('H'):
            keys, n = st[1:].split(':')
            held[0] = sum(BTN[k] for k in keys)
            for _ in range(int(n)):
                p.step()
            held[0] = 0
        else:
            held[0] = sum(BTN[k] for k in st)
            for _ in range(4):
                p.step()
            held[0] = 0
            for _ in range(4):
                p.step()
    return p


if __name__ == '__main__':
    run(sys.argv[1] if len(sys.argv) > 1 else '120,s:title')
