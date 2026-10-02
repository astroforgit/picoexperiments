#!/usr/bin/env python3
"""Draw Zorro's rooms and object sprites from the game data, for reference.

Usage: python3 render.py ORIGINAL.xex OUTDIR
Writes OUTDIR/rooms.png (all 21 rooms) and OUTDIR/objects.png (the sprite
each of the 58 objects starts with, and its room: any, cat = every catacomb
room). Objects whose sprite is set later are blank. Needs Pillow.

Room data (see LoadRoom at $0FEB):
  * the tile set is copied from tiles[room] (under the OS ROM) to $9FF0,
    8 bytes per 8x8 tile, mode E (4 pixels per byte);
  * the map is copied from map[room] and RLE-decoded: a byte < $80 is a
    tile number; $80+n is followed by one byte that is repeated n times;
    $80 ends the map. Tiles are 40 per row, 22 rows.
  * the four colours come from the room's palette entry, through the DLI.
Sprites (see DrawObject at $14A5): width in bytes, height, then the pixels.
"""
import os
import sys
import math

from PIL import Image, ImageDraw

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from xex import load                                     # noqa: E402

ROOMS = 21
OBJECTS = 0x3A


def atari_rgb(c):
    """Approximate NTSC colour for an Atari colour register value (YIQ, the
    same formula as the editor)."""
    hue, lum = c >> 4, (c & 0x0E) / 14.0
    y, i, q = 0.06 + lum * 0.88, 0.0, 0.0
    if hue:
        ang = -0.35 + (hue - 1) * (2 * math.pi / 15)
        i, q = 0.24 * math.cos(ang), 0.24 * math.sin(ang)

    def cl(v):
        return max(0, min(255, int(round(v * 255))))
    return (cl(y + 0.956 * i + 0.621 * q), cl(y - 0.272 * i - 0.647 * q),
            cl(y - 1.106 * i + 1.703 * q))


def word(ram, lo, hi, i):
    return ram[lo + i] | ram[hi + i] << 8


def room_image(ram, room):
    tiles = word(ram, 0x163E, 0x1653, room)
    mp = word(ram, 0x1668, 0x167D, room)
    pal = ram[0x1614 + room]
    # $9A..$9D = COLPF2, COLPF1, COLPF0, COLBK, loaded in reverse
    colpf2, colpf1, colpf0, colbk = (ram[0x1629 + pal + 3 - k] for k in range(4))
    colours = [atari_rgb(colbk), atari_rgb(colpf0), atari_rgb(colpf1),
               atari_rgb(colpf2)]
    # RLE decode
    cells = []
    p = mp
    while True:
        b = ram[p]
        p += 1
        if b < 0x80:
            cells.append(b)
            continue
        n = b & 0x7F
        if n == 0:
            break
        cells += [ram[p]] * n
        p += 1
    img = Image.new('RGB', (320, 176), colours[0])
    px = img.load()
    for i, t in enumerate(cells):
        cx, cy = i % 40, i // 40
        if cy >= 22:
            break
        for row in range(8):
            v = ram[tiles + t * 8 + row]
            for k in range(4):
                c = colours[(v >> (6 - 2 * k)) & 3]
                x, y = cx * 8 + k * 2, cy * 8 + row
                px[x, y] = c
                px[x + 1, y] = c
    return img


def sprite_image(ram, ptr, colours):
    w, h = ram[ptr], ram[ptr + 1]
    img = Image.new('RGB', (max(w, 1) * 8, max(h, 1)), (0, 0, 0))
    px = img.load()
    for y in range(h):
        for x in range(w):
            v = ram[ptr + 2 + y * w + x]
            for k in range(4):
                c = colours[(v >> (6 - 2 * k)) & 3]
                px[x * 8 + k * 2, y] = c
                px[x * 8 + k * 2 + 1, y] = c
    return img


def main():
    src, outdir = sys.argv[1], sys.argv[2]
    ram, _ = load(src)
    os.makedirs(outdir, exist_ok=True)

    sheet = Image.new('RGB', (3 * 330, 7 * 196), (40, 40, 40))
    d = ImageDraw.Draw(sheet)
    for room in range(ROOMS):
        x, y = (room % 3) * 330 + 5, (room // 3) * 196 + 16
        sheet.paste(room_image(ram, room), (x, y))
        d.text((x, y - 13), 'room %d' % room, fill=(255, 255, 255))
    sheet.save(os.path.join(outdir, 'rooms.png'))

    colours = [(0, 0, 0), (200, 120, 40), (240, 240, 240), (60, 120, 220)]
    sheet = Image.new('RGB', (10 * 90, 6 * 110), (40, 40, 40))
    d = ImageDraw.Draw(sheet)
    for i in range(OBJECTS):
        x, y = (i % 10) * 90 + 5, (i // 10) * 110 + 16
        ptr = word(ram, 0x26E3, 0x271D, i)
        room = ram[0x0574 + 3 * OBJECTS + i]          # initial obj_room
        d.text((x, y - 13), '%d r%s' % (i, 'any' if room == 0xFF else
                                         'cat' if room == 0x80 else room),
               fill=(255, 255, 255))
        if ptr and ram[ptr] and ram[ptr] < 12 and ram[ptr + 1] < 100:
            spr = sprite_image(ram, ptr, colours)
            sheet.paste(spr.resize((spr.width * 2, spr.height * 2)), (x, y))
    sheet.save(os.path.join(outdir, 'objects.png'))


if __name__ == '__main__':
    main()
