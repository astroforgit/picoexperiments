#!/usr/bin/env python3
"""Draw map.png from the game data: the US map (map_rle), every city
(city_xy) and the rail links between them (city_links). Capitals (the
cities with an InfoBooth, city_flags bit 7) are drawn larger.

Usage: python3 render.py ORIGINAL.xex OUT.png   (needs Pillow)
"""
import os
import sys

from PIL import Image, ImageDraw

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from xex import load                                # noqa: E402

MAP_RLE, CITY_XY, CITY_LINKS, CITY_NAMES, CITY_FLAGS = \
    0x7FAA, 0xA443, 0xA2B1, 0xA37B, 0xAFF3
SCALE = 5


def unpack_map(ram):
    """The map as DrawMap leaves it: 160 rows of 40 bytes (mode E). The
    game ANDs each byte with map_mask ($55), which leaves the outline in
    colour 1."""
    out = bytearray()
    a = MAP_RLE
    while True:
        b = ram[a]
        a += 1
        if b:
            out.append(b & 0x55)
            continue
        n = ram[a]
        a += 1
        if not n:
            return out
        out += bytes(n)


def main():
    _, ram = load(sys.argv[1])
    bitmap = unpack_map(ram)
    rows = len(bitmap) // 40
    colours = [(28, 72, 28), (10, 10, 10), (230, 230, 230), (28, 72, 28)]
    im = Image.new('RGB', (160 * SCALE * 2, rows * SCALE), colours[0])
    d = ImageDraw.Draw(im)
    for y in range(rows):
        for x in range(160):
            v = bitmap[y * 40 + x // 4] >> (6 - 2 * (x & 3)) & 3
            if v:
                d.rectangle([x * SCALE * 2, y * SCALE,
                             (x + 1) * SCALE * 2 - 1, (y + 1) * SCALE - 1],
                            fill=colours[v])

    def at(c):
        x, y = ram[CITY_XY + 2 * c], ram[CITY_XY + 2 * c + 1]
        return (x * 2 + 1) * SCALE, y * SCALE + SCALE // 2

    def word(a):
        return ram[a] | ram[a + 1] << 8

    for c in range(1, 101):
        p = word(CITY_LINKS + 2 * c)
        while ram[p]:
            d.line([at(c), at(ram[p] & 0x7F)], fill=(200, 160, 60), width=2)
            p += 2
    for c in range(1, 101):
        x, y = at(c)
        r = 6 if ram[CITY_FLAGS + c] & 0x80 else 3
        d.ellipse([x - r, y - r, x + r, y + r], fill=(255, 255, 255),
                  outline=(0, 0, 0))
    im.save(sys.argv[2])


if __name__ == '__main__':
    main()
