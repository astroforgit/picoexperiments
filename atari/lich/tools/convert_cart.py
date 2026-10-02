#!/usr/bin/env python3
"""Decode the Curse of the Lich King PICO-8 cartridge into pico/.

Uses scrip/pico_convert.py (the repo's .p8.png decoder) and writes:

  pico/cart.bin        raw 32K cartridge memory (gfx, map, flags, sfx, music)
  pico/lich.p8         text cartridge
  pico/lich.lua        game code
  pico/lich_gfx.png    sprite sheet (128x128), plus an x4 enlargement
  pico/lich_map.png    the cartridge map (title screen background)
"""
from pathlib import Path
import sys
from PIL import Image

HERE = Path(__file__).resolve().parent.parent
ROOT = HERE.parent.parent
sys.path.insert(0, str(ROOT / 'scrip'))
import pico_convert as pc

PNG = ROOT / '[RPG]' / 'Curse of the Lich King.p8.png'
PAL = [(0, 0, 0), (29, 43, 83), (126, 37, 83), (0, 135, 81), (171, 82, 54),
       (95, 87, 79), (194, 195, 199), (255, 241, 232), (255, 0, 77),
       (255, 163, 0), (255, 255, 39), (0, 231, 88), (41, 173, 255),
       (131, 118, 156), (255, 119, 168), (255, 204, 170)]

cart = pc.cart_bytes(PNG)[:0x8000]
fmt, p8, code = pc.build_p8(pc.cart_bytes(PNG))
out = HERE / 'pico'
out.mkdir(exist_ok=True)
(out / 'cart.bin').write_bytes(cart)
(out / 'lich.p8').write_bytes(p8)
(out / 'lich.lua').write_bytes(code)

def pix(x, y):
    b = cart[y * 64 + x // 2]
    return b >> 4 if x & 1 else b & 15

img = Image.new('RGB', (128, 128))
img.putdata([PAL[pix(x, y)] for y in range(128) for x in range(128)])
img.save(out / 'lich_gfx.png')
img.resize((512, 512), Image.NEAREST).save(out / 'lich_gfx_x4.png')

# map: rows 0..31 at $2000, rows 32..63 share the lower half of the gfx
m = Image.new('RGB', (1024, 256))
for ty in range(32):
    for tx in range(128):
        t = cart[0x2000 + ty * 128 + tx]
        if t == 0:
            continue
        sx, sy = (t % 16) * 8, (t // 16) * 8
        for y in range(8):
            for x in range(8):
                c = pix(sx + x, sy + y)
                if c:
                    m.putpixel((tx * 8 + x, ty * 8 + y), PAL[c])
m.save(out / 'lich_map.png')
print(f'{PNG.name}: {fmt} code, {len(code)} bytes of Lua')
