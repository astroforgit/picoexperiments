#!/usr/bin/env python3
"""Decode The Lair PICO-8 cartridge into pico/.

Uses scrip/pico_convert.py (the repo's .p8.png decoder) and writes:

  pico/cart.bin        raw 32K cartridge memory (gfx, map, flags, sfx, music)
  pico/lair.p8         text cartridge (same as allgames/[BeatEmUp]/lair.p8)
  pico/lair.lua        game code
  pico/lair_gfx.png    sprite sheet (128x128), plus an x4 enlargement
  pico/lair_map.png    the cartridge map (128x32 tiles)
"""
from pathlib import Path
import sys
from PIL import Image

HERE = Path(__file__).resolve().parent.parent
ROOT = HERE.parent.parent
sys.path.insert(0, str(ROOT / 'scrip'))
import pico_convert as pc

PNG = ROOT / '[BeatEmUp]' / 'lair.p8.png'
PAL = [(0, 0, 0), (29, 43, 83), (126, 37, 83), (0, 135, 81), (171, 82, 54),
       (95, 87, 79), (194, 195, 199), (255, 241, 232), (255, 0, 77),
       (255, 163, 0), (255, 255, 39), (0, 231, 88), (41, 173, 255),
       (131, 118, 156), (255, 119, 168), (255, 204, 170)]

raw = pc.cart_bytes(PNG)
cart = raw[:0x8000]
fmt, p8, code = pc.build_p8(raw)
out = HERE / 'pico'
out.mkdir(exist_ok=True)
(out / 'cart.bin').write_bytes(cart)
(out / 'lair.p8').write_bytes(p8)
(out / 'lair.lua').write_bytes(code)


def pix(x, y):
    b = cart[y * 64 + x // 2]
    return b >> 4 if x & 1 else b & 15


img = Image.new('RGB', (128, 128))
img.putdata([PAL[pix(x, y)] for y in range(128) for x in range(128)])
img.save(out / 'lair_gfx.png')
img.resize((512, 512), Image.NEAREST).save(out / 'lair_gfx_x4.png')

m = Image.new('RGB', (1024, 256))
for ty in range(32):
    for tx in range(128):
        t = cart[0x2000 + ty * 128 + tx]
        if t == 0:
            continue
        sx, sy = (t % 16) * 8, (t // 16) * 8
        for y in range(8):
            for x in range(8):
                m.putpixel((tx * 8 + x, ty * 8 + y), PAL[pix(sx + x, sy + y)])
m.save(out / 'lair_map.png')
print(f'{PNG.name}: {fmt} code, {len(code)} bytes of Lua')
