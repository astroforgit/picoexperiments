#!/usr/bin/env python3
"""Run the original Celeste Lua (pico/celeste.lua) as a reference.

A small PICO-8 shim (lupa) provides btn/rnd/sin/map/spr/... and a
128x128 framebuffer, so the port can be compared with the original
frame by frame:

    ref = PicoRef(); ref.step(buttons); ref.player(); ref.image()
"""
import math
import random
import re
from pathlib import Path
import numpy as np
from lupa import LuaRuntime

HERE = Path(__file__).resolve().parent.parent
PAL = [(0, 0, 0), (29, 43, 83), (126, 37, 83), (0, 135, 81), (171, 82, 54),
       (95, 87, 79), (194, 195, 199), (255, 241, 232), (255, 0, 77),
       (255, 163, 0), (255, 255, 39), (0, 231, 88), (41, 173, 255),
       (131, 118, 156), (255, 119, 168), (255, 204, 170)]

PRELUDE = r'''
function add(t,v) t[#t+1]=v return v end
function del(t,v) for i=1,#t do if t[i]==v then table.remove(t,i) return v end end end
function count(t) return #t end
function all(c)
  local i=0 local prev=nil
  return function()
    if i==0 or c[i]==prev then i=i+1 end
    prev=c[i]
    return prev
  end
end
function foreach(t,f) for v in all(t) do f(v) end end
function flr(x) return math.floor(x) end
function abs(x) return math.abs(x) end
function min(a,b) return math.min(a,b) end
function max(a,b) return math.max(a,b) end
function sin(x) return math.floor(-math.sin(x*2*math.pi)*65536+0.5)/65536 end
function cos(x) return math.floor(math.cos(x*2*math.pi)*65536+0.5)/65536 end
function sub(s,i,j) return string.sub(s,i,j) end
function rnd(n) return math.floor(py_rnd()*(n or 1)*65536)/65536 end
function fmul(a,b) return math.floor(a*b*65536)/65536 end
'''


def fixed_literal(m):
    """Decimal literal -> the value PICO-8's 16.16 parser stores."""
    v = round(float(m.group(0)) * 65536)
    return f'({v}/65536)'


def convert(src):
    """PICO-8 dialect -> Lua 5.x, with 16.16-exact constants/products."""
    src = src.replace('d_full*0.70710678118', 'fmul(d_full,0.70710678118)')
    src = src.replace('sin(this.step)*0.5', 'fmul(sin(this.step),0.5)')
    src = re.sub(r'(?<![\w.])\d*\.\d+', fixed_literal, src)
    out = []
    for line in src.split('\n'):
        line = line.replace('!=', '~=')
        m = re.match(r'^(\s*)if\s*\((.*)\)\s*(return.*)$', line)
        if m and 'then' not in line:
            line = f'{m.group(1)}if {m.group(2)} then {m.group(3)} end'
        line = re.sub(r'freeze-=1', 'freeze=freeze-1', line)
        m = re.match(r'^(\s*)([\w\.\[\]]+)\s*([\+\-\*/])=\s*(.+)$', line)
        if m and m.group(3) == '*':
            line = f'{m.group(1)}{m.group(2)} = fmul({m.group(2)}, {m.group(4)})'
        elif m:
            line = f'{m.group(1)}{m.group(2)} = {m.group(2)} {m.group(3)} ({m.group(4)})'
        out.append(line)
    return '\n'.join(out)


class PicoRef:
    def __init__(self, seed=1):
        cart = (HERE / 'pico' / 'cart.bin').read_bytes()
        gfx = cart[0:0x2000]
        self.sheet = np.zeros((128, 128), dtype=np.uint8)
        for i, b in enumerate(gfx):
            y, x = divmod(i * 2, 128)
            self.sheet[y, x] = b & 15
            self.sheet[y, x + 1] = b >> 4
        self.map = np.frombuffer((HERE / 'data' / 'map.bin').read_bytes(), dtype=np.uint8).reshape(64, 128)
        self.flags = cart[0x3000:0x3100]
        self.fb = np.zeros((128, 128), dtype=np.uint8)
        self.dpal = list(range(16))
        self.cam = (0, 0)
        self.buttons = [False] * 6
        self.sounds = []
        self.music_log = []
        rng = random.Random(seed)
        lua = LuaRuntime(unpack_returned_tuples=True)
        self.lua = lua
        g = lua.globals()
        g.py_rnd = rng.random
        g.btn = lambda i: self.buttons[int(i)]
        g.mget = lambda x, y: int(self.map[int(y), int(x)])
        g.fget = lambda n, f: bool(self.flags[int(n)] >> int(f) & 1)
        g.sfx = lambda n, *a: self.sounds.append(int(n))
        g.music = lambda n, *a: self.music_log.append(int(n))
        g.pal = self.pal
        g.camera = self.camera
        g.rectfill = self.rectfill
        g.circfill = self.circfill
        g.line = self.line
        g.spr = self.spr
        g.map = self.draw_map
        g.print = self.print
        lua.execute(PRELUDE)
        lua.execute(convert((HERE / 'pico' / 'celeste.lua').read_text()))
        from make_font import FONT_GLYPHS
        self.font = FONT_GLYPHS
        lua.globals()._init()

    # ------------------------------------------------------------ api
    def pal(self, a=None, b=None):
        if a is None:
            self.dpal = list(range(16))
        else:
            self.dpal[int(a) & 15] = int(b) & 15

    def camera(self, x=0, y=0):
        self.cam = (math.floor(x), math.floor(y))

    def pset(self, x, y, c):
        x -= self.cam[0]
        y -= self.cam[1]
        if 0 <= x < 128 and 0 <= y < 128:
            self.fb[y, x] = self.dpal[c & 15]

    def rectfill(self, x0, y0, x1, y1, c):
        x0, y0, x1, y1 = (math.floor(v) for v in (x0, y0, x1, y1))
        if x1 < x0:
            x0, x1 = x1, x0
        if y1 < y0:
            y0, y1 = y1, y0
        c = self.dpal[math.floor(c) & 15]
        cx, cy = self.cam
        x0, x1 = max(x0 - cx, 0), min(x1 - cx, 127)
        y0, y1 = max(y0 - cy, 0), min(y1 - cy, 127)
        if x0 <= x1 and y0 <= y1:
            self.fb[y0:y1 + 1, x0:x1 + 1] = c

    def line(self, x0, y0, x1, y1, c):
        self.rectfill(x0, y0, x1, y1, c)

    def circfill(self, x, y, r, c):
        x, y, r = math.floor(x), math.floor(y), math.floor(r)
        shape = {1: ['.#.', '###', '.#.'],
                 2: ['.###.', '#####', '#####', '#####', '.###.']}[r]
        for j, row in enumerate(shape):
            for i, ch in enumerate(row):
                if ch == '#':
                    self.pset(x - r + i, y - r + j, math.floor(c))

    def spr(self, n, x, y, w=1, h=1, fx=False, fy=False):
        n = math.floor(n)
        x, y = math.floor(x), math.floor(y)
        sx, sy = (n % 16) * 8, (n // 16) * 8
        tile = self.sheet[sy:sy + 8, sx:sx + 8]
        if fx:
            tile = tile[:, ::-1]
        if fy:
            tile = tile[::-1, :]
        for j in range(8):
            for i in range(8):
                c = int(tile[j, i])
                if c:
                    self.pset(x + i, y + j, c)

    def draw_map(self, cx, cy, sx, sy, w, h, layer=0):
        for ty in range(int(h)):
            for tx in range(int(w)):
                t = int(self.map[int(cy) + ty, int(cx) + tx])
                if t and (layer == 0 or self.flags[t] & int(layer) == int(layer)):
                    self.spr(t, sx + tx * 8, sy + ty * 8)

    def print(self, s, x, y, c):
        s = str(s)
        x, y = math.floor(x), math.floor(y)
        for ch in s:
            g = self.font.get(ch)
            if g:
                for j, row in enumerate(g):
                    for i, px in enumerate(row):
                        if px == '#':
                            self.pset(x + i, y + j, math.floor(c))
            x += 4

    # ------------------------------------------------------------ run
    def step(self, buttons=(), draw=True):
        """buttons: iterable of 'l','r','u','d','j','x'."""
        names = 'lrudjx'
        self.buttons = [n in buttons for n in names]
        g = self.lua.globals()
        g._update()
        if draw:
            g._draw()

    def player(self):
        """(kind, x, y, spd.x, spd.y) of the player or spawn, or None."""
        r = self.lua.eval('''(function()
          for o in all(objects) do
            if o.type==player then return "player",o.x,o.y,o.spd.x,o.spd.y end
            if o.type==player_spawn then return "spawn",o.x,o.y,o.spd.x,o.spd.y end
          end end)()''')
        return r if r and r[0] else None

    def room(self):
        g = self.lua.globals()
        return int(g.room.x), int(g.room.y)

    def image(self, path=None, scale=4):
        from PIL import Image
        rgb = np.array(PAL, dtype=np.uint8)[self.fb]
        im = Image.fromarray(rgb, 'RGB').resize((128 * scale, 128 * scale), Image.NEAREST)
        if path:
            im.save(path)
        return im
