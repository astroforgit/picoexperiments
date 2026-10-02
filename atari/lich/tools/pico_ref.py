#!/usr/bin/env python3
"""Run the original Lich King Lua (pico/lich.lua) headless as a reference.

A PICO-8 shim (lupa) provides map/sprite-flag memory, rnd and the
helpers the cart uses; drawing and sound calls are no-ops.  Used to
measure the level generator (entity counts, room-placement work) and
to sanity-check the port's generator statistics.
"""
import random
import re
from pathlib import Path
from lupa import LuaRuntime

HERE = Path(__file__).resolve().parent.parent

PRELUDE = r'''
function add(t,v) t[#t+1]=v return v end
function del(t,v) for i=1,#t do if t[i]==v then table.remove(t,i) return v end end end
function all(c)
  local i=0 local prev=nil
  return function()
    if i==0 or c[i]==prev then i=i+1 end
    prev=c[i]
    return prev
  end
end
function flr(x) return math.floor(x) end
function abs(x) return math.abs(x) end
function min(a,b) return math.min(tonumber(a),tonumber(b)) end
function max(a,b) return math.max(tonumber(a),tonumber(b)) end
function mid(a,b,c) if a>b then a,b=b,a end return math.max(a,math.min(b,c)) end
function sqrt(x) return math.sqrt(x) end
function sin(x) return -math.sin(x*2*math.pi) end
function sub(s,i,j) return string.sub(s,i,j) end
function tonum(s) return tonumber(s) end
function shr(a,n) return a/2^n end
function band(a,b) return 0 end
function rnd(n) if type(n)=="table" then return n[1] end return math.floor(py_rnd()*tonumber(n or 1)*65536)/65536 end
function mget(x,y) NGET=NGET+1 x=flr(x) y=flr(y) if x<0 or y<0 or x>127 or y>31 then return 0 end return MAP[y*128+x] end
function mset(x,y,v) x=flr(x) y=flr(y) if x<0 or y<0 or x>127 or y>31 then return end MAP[y*128+x]=flr(tonumber(v)) NSET=NSET+1 end
function fget(t,f) return (FLAGS[t] >> f) & 1 == 1 end
function sget(x,y) return SHEET[y*128+x] end
function memset() for i=0,4095 do MAP[i]=0 end end
function reload() end
function music() end function sfx() end function pal() end function fillp() end
function camera() end function cls() end function spr() end function map() end
function pset() end function rect() end function rectfill() end function clip() end
function flip() end function time() return 0 end function btnp() return false end
'''


def compound(stmt):
    return re.sub(r'^(\s*)([\w\.\[\]]+)\s*([\+\-\*/])=\s*(.+)$',
                  lambda m: f'{m.group(1)}{m.group(2)} = {m.group(2)} {m.group(3)} ({m.group(4)})', stmt)


def convert(src):
    src = src.replace('i+=1\nlastpos=i', 'lastpos=i+1')   # Lua 5.4+: loop vars are const
    out = []
    for line in src.split('\n'):
        line = line.replace('!=', '~=')
        m = re.match(r'^(\s*)if\s*(\(.*\))\s*(\w.*)$', line)
        done = False
        if m and ' then' not in line:
            cond, rest = m.group(2), m.group(3)
            depth = 0
            for i, ch in enumerate(cond):
                depth += ch == '('
                depth -= ch == ')'
                if depth == 0 and i < len(cond) - 1:
                    break
            else:
                line = f'{m.group(1)}if {cond} then {compound(rest)} end'
                done = True
        if not done:
            line = compound(line)
        line = re.sub(r'(\w)then\b', r'\1 then', line)
        line = re.sub(r'(?<![\w"])([a-z_]+)"([^"]*)"', lambda m: m.group(0) if m.group(1) in ('then', 'return', 'and', 'or', 'not') else f'{m.group(1)}("{m.group(2)}")', line)
        out.append(line)
    return '\n'.join(out)


class PicoRef:
    def __init__(self, seed=1):
        cart = (HERE / 'pico' / 'cart.bin').read_bytes()
        self.rng = random.Random(seed)
        self.lua = LuaRuntime(unpack_returned_tuples=True)
        g = self.lua.globals()
        g.py_rnd = self.rng.random
        self.lua.execute(PRELUDE)
        self.lua.execute('MAP={} FLAGS={} SHEET={} NSET=0 NGET=0')
        for i in range(4096):
            g.MAP[i] = cart[0x2000 + i]
        for i in range(256):
            g.FLAGS[i] = cart[0x3000 + i]
        for i in range(0x2000):
            g.SHEET[i * 2] = cart[i] & 15
            g.SHEET[i * 2 + 1] = cart[i] >> 4
        src = (HERE / 'pico' / 'lich.lua').read_bytes().decode('latin-1')
        src = src.split('function _init()', 1)[1]
        src = 'function _init()' + src
        self.lua.execute(convert(src))
        self.g = g

    def gen(self, depth):
        lua = self.lua
        lua.execute('pl={depth=%d,sight=4,tx=0,ty=0} entities={} hash={} fog={}' % depth)
        lua.execute('''for y=0,31 do hash[y]={} end
        m_name, m_anim, m_col, m_prop, m_hp, m_atk, m_range, m_sight, m_depth, m_itemchance = explode("hero,a rat,a ghoul,pot,chest,shelves,door,door,altar,gate,lever,gate,spikes,an eyeball,an imp,box,a troll,pot,a skeleton,anvil,body,a toxic rat,a ghost,^raq'zul,well"),explodeval("240,192,224,29,13,15,4,5,25,7,31,9,47,228,244,212,208,27,196,24,11,216,200,248,22"),explodeval("8,8,12,7,7,7,7,7,7,7,7,7,7,14,14,9,3,7,7,7,7,11,7,1,7"),explodeval("0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0,1,0,1,1,0,0,0,1"),explodeval("6,1,6,1,1,1,1,1,1,1,1,1,1,10,10,15,22,1,12,1,1,4,12,45,1"),explodeval("3,1,1,0,0,0,0,0,0,0,0,0,5,0,1,0,3,0,2,0,0,0,1,4,0"),explodeval("1,1,1,1,0,0,0,0,0,0,0,0,0,4,1,1,1,1,1,0,0,1,1,4,0"),explodeval("4,3,3,0,0,0,0,0,0,0,0,0,0,5,3,3,3,0,4,0,0,3,4,5,0"),explodeval("0,1,2,0,0,0,0,0,0,0,0,0,3,5,3,99,6,0,4,0,0,4,7,99,0"),explodeval("0,0,0,4,10,2,0,0,0,0,0,0,0,0,0,0,0,4,0,0,4,0,0,0,0")
        dirx,diry=explodeval"-1,1,0,0,-1,1,1,-1",explodeval"0,0,-1,1,1,-1,1,-1"
        NSET=0 NGET=0''')
        lua.execute('generate_level(2+pl.depth*2)')
        g = self.g
        ents = list(g.entities.values())
        mobs = sum(1 for e in ents if e.mob)
        return dict(ents=len(ents), mobs=mobs, mset=g.NSET, mget=g.NGET,
                    rooms_dropped=g.dropped, rooms_removed=g.removed)

    def map_rows(self):
        g = self.g
        return [[g.MAP[y * 128 + x] for x in range(128)] for y in range(32)]


if __name__ == '__main__':
    import sys
    worst = {}
    for seed in range(int(sys.argv[1]) if len(sys.argv) > 1 else 20):
        r = PicoRef(seed)
        for d in range(1, 9):
            s = r.gen(d)
            w = worst.setdefault(d, dict(s))
            for k, v in s.items():
                w[k] = max(w[k], v)
    for d, w in worst.items():
        print(d, w)
