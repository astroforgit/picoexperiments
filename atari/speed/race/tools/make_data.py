#!/usr/bin/env python3
"""Build the data of SPEEDMAZA RACE from the PICO-8 game and the SpeedMaza image.

Track: track 1 of picospeed.txt: discs of radius 28 along the centre line
(the PICO-8 track with its kerbs), rasterised into an ANTIC mode 8 map in
two colours like SpeedMaza's maze: road = background, the rest = walls.
Car: the PICO-8 car outline (small square + long rectangle), pre-rotated in
32 directions for players 0 and 3.

Usage: python3 make_data.py PICO_TXT SPEEDMAZA_IMAGE OUTDIR
Writes OUTDIR/data/*.bin, OUTDIR/gen/*.asm and OUTDIR/gen/track_preview.png
"""
import math
import os
import re
import sys

import numpy as np
from PIL import Image

# ---- geometry -------------------------------------------------------------
SX = 0.95            # colour clocks per PICO-8 pixel
SY = 1.52            # scan lines per PICO-8 pixel (keeps circles round)
MAP_BYTES = 84       # bytes per map row (4 mode-8 pixels each, 16 cc per byte)
MAP_ROWS = 192       # 4 blocks of 48 rows, one per 4K page ($6000-$9FFF)
ROWS_PER_BLOCK = 48
VIEW_X = 0x51        # car x minus camera x (see race.asm, UpdateCamera)
VIEW_Y = 90          # car y minus camera y (scan lines)
DL_LINES = 27        # mode 8 lines in the game display list
ROAD_R = 28                      # PICO-8 track: kerb circle r=28 (road r=24)
CAR_SCALE = 1.25                 # PICO-8 car is 11x6 px; a bit bigger here
START = (44.0, 64.0)             # car start (PICO-8 coords), before the line


def track_points(txt):
    m = re.search(r'w=\{(.*?)\}\n', txt, re.S)
    code = re.findall(r'"([^"]*)"', m.group(1))[0]          # track 1
    d = e = 64.0
    c = 0.0
    sub, cps = [], []
    for k, ch in enumerate(code):
        c += ord(ch) / 32 - 1.75
        a = math.cos(2 * math.pi * c) * 8
        b = -math.sin(2 * math.pi * c) * 8                   # PICO-8 sin
        for j in range(1, 5):
            sub.append((d, e, k, j))                          # disc centres
            d += a
            e += b
        cps.append((d, e))
    return sub, cps


def main():
    pico_txt, image, out = sys.argv[1:4]
    mem = open(image, "rb").read()
    os.makedirs(os.path.join(out, "data"), exist_ok=True)
    os.makedirs(os.path.join(out, "gen"), exist_ok=True)
    sub, cps = track_points(open(pico_txt).read())

    # ---- placement: every position the car can reach must keep the camera
    # inside the map (car centre at most kerb + a few pixels off the line)
    xs = [p[0] for p in sub]
    ys = [p[1] for p in sub]
    reach = ROAD_R + 4
    x_lo, x_hi = min(xs) - reach, max(xs) + reach
    y_lo, y_hi = min(ys) - reach, max(ys) + reach
    cam_x_max = (MAP_BYTES - 12) * 16
    cam_y_max = (MAP_ROWS - DL_LINES) * 8
    room_x = cam_x_max - (x_hi - x_lo) * SX
    room_y = cam_y_max - (y_hi - y_lo) * SY
    assert room_x >= 0 and room_y >= 0, (room_x, room_y)
    off_x = VIEW_X + room_x / 2 - x_lo * SX
    off_y = VIEW_Y + room_y / 2 - y_lo * SY

    def to_world(x, y):
        return x * SX + off_x, y * SY + off_y

    # ---- rasterise: sample every mode 8 pixel at its centre
    W = MAP_BYTES * 4
    px = (np.arange(W) * 4 + 2 - off_x) / SX              # pico x per column
    py = (np.arange(MAP_ROWS) * 8 + 4 - off_y) / SY       # pico y per row
    PX, PY = np.meshgrid(px, py)
    col = np.full(PX.shape, 3, np.uint8)                   # wall = PF2 (%11)
    for (d, e, k, j) in sub:                               # road = background
        col[(PX - d) ** 2 + (PY - e) ** 2 <= ROAD_R ** 2] = 0

    img = bytearray(0x4000)                                # $6000-$9FFF
    row_addr = []
    for r in range(MAP_ROWS):
        base = (r // ROWS_PER_BLOCK) * 0x1000 + (r % ROWS_PER_BLOCK) * MAP_BYTES
        row_addr.append(0x6000 + base)
        for b in range(MAP_BYTES):
            v = 0
            for p in range(4):
                v = v << 2 | int(col[r, b * 4 + p])
            img[base + b] = v
    open(os.path.join(out, "data", "track.bin"), "wb").write(img)

    # preview (mode 8 pixel = 4x8, drawn 4x4 per colour clock/line pair)
    pal = [(0, 0, 0), (0, 0, 0), (0, 0, 0), (170, 120, 30)]
    prev = Image.new("RGB", (W, MAP_ROWS))
    for r in range(MAP_ROWS):
        for c in range(W):
            prev.putpixel((c, r), pal[col[r, c]])
    prev = prev.resize((W * 4, MAP_ROWS * 8 * 4 // 5), Image.NEAREST)

    # ---- checkpoints (world cc / lines); the last one fires on the line
    pts = cps[:-1] + [(64.0 + 45 / SX, 64.0)]      # fires at the start x
    cpx, cpy = zip(*[to_world(x, y) for x, y in pts])
    n = len(pts)

    # ---- car sprites: 32 directions, 16x12 (P0 = left 8, P3 = right 8)
    frames0, frames3 = [], []
    for f in range(32):
        z = f / 32
        # long axis along (cos, -sin): the direction Physics moves the car
        a, b = math.cos(2 * math.pi * z), math.sin(2 * math.pi * z)
        poly = []
        for j in (1, 2):
            i = 0.125
            while i <= 1.25 + 1e-9:
                d = j * math.cos(2 * math.pi * i) * 4 * CAR_SCALE
                e = -math.sin(2 * math.pi * i) * 4 * CAR_SCALE
                poly.append((d * a + b * e, e * a - b * d))
                i += 0.25
        grid = [[0] * 16 for _ in range(12)]
        for (x0, y0), (x1, y1) in zip(poly, poly[1:]):
            for s in range(41):
                t = s / 40
                x = (x0 + (x1 - x0) * t) * SX           # colour clocks
                y = (y0 + (y1 - y0) * t) * SY / 2       # PM double lines
                gx, gy = int(math.floor(x + 8)), int(math.floor(y + 6))
                if 0 <= gx < 16 and 0 <= gy < 12:
                    grid[gy][gx] = 1
        for row in grid:
            frames0.append(int("".join(map(str, row[:8])), 2))
            frames3.append(int("".join(map(str, row[8:])), 2))

    # ---- write gen/tables.asm
    def dta(name, vals, fmt="${:02X}"):
        lines = [f"{name}"]
        for i in range(0, len(vals), 16):
            lines.append("\tdta " + ",".join(fmt.format(v) for v in vals[i:i + 16]))
        return "\n".join(lines)

    sx, sy = to_world(*START)
    cos_t = [round(127 * math.cos(2 * math.pi * t / 256)) & 0xFF for t in range(256)]
    siny_t = [round(-127 * SY / SX / 2 * math.sin(2 * math.pi * t / 256)) & 0xFF
              for t in range(256)]
    prog = [min(0x60, round(i * 0x60 / n)) for i in range(n + 1)]
    g = []
    g.append("; generated by tools/make_data.py - do not edit")
    g.append(f"CP_COUNT\t= {n}\t; checkpoints (last one = start/finish line)")
    g.append(f"START_X\t= {int(sx)}\t; car start, colour clocks")
    g.append(f"START_Y\t= {int(sy)}\t; car start, scan lines")
    g.append(f"CP_RX\t= {int(45 * SX)}\t; checkpoint box half width (cc)")
    g.append(f"CP_RY\t= {int(48 * SY)}\t; checkpoint box half height (lines)")
    g.append(f"MAP_BYTES\t= {MAP_BYTES}")
    g.append(f"MAP_ROWS\t= {MAP_ROWS}")
    g.append(f"CAM_X_MAX\t= {cam_x_max}")
    g.append(f"CAM_Y_MAX\t= {cam_y_max}")
    g.append(f"VIEW_X\t= {VIEW_X}")
    g.append(f"VIEW_Y\t= {VIEW_Y}")
    g.append(dta("rowLo", [a & 0xFF for a in row_addr]))
    g.append(dta("rowHi", [a >> 8 for a in row_addr]))
    g.append(dta("cpXLo", [int(v) & 0xFF for v in cpx]))
    g.append(dta("cpXHi", [int(v) >> 8 for v in cpx]))
    g.append(dta("cpYLo", [int(v) & 0xFF for v in cpy]))
    g.append(dta("cpYHi", [int(v) >> 8 for v in cpy]))
    g.append("; distance bar height for each checkpoint index")
    g.append(dta("cpBar", prog))
    g.append("; car: 32 directions x 12 lines, player 0 (left) and player 3 (right)")
    g.append(dta("car0", frames0))
    g.append(dta("car3", frames3))
    g.append("; cos(t)*127 and -sin(t)*127*1.6/2 for t = 0..255 (256 = full turn)")
    g.append(dta("cosTab", cos_t))
    g.append(dta("sinYTab", siny_t))
    open(os.path.join(out, "gen", "tables.asm"), "w").write("\n".join(g) + "\n")

    # ---- SpeedMaza assets
    def blob(name, lo, hi):
        open(os.path.join(out, "data", name), "wb").write(mem[lo:hi + 1])
    blob("title_pic.bin", 0x1000, 0x1FFF)
    blob("crash_pic.bin", 0x2000, 0x283F)
    blob("rmt_player.bin", 0x48DF, 0x4FFF)
    blob("music.bin", 0x5000, 0x5BA6)
    s = ["; generated by tools/make_data.py from the SpeedMaza image - do not edit"]
    s.append("; display lists (LMS / JVB operands are patched in race.asm)")
    s.append(dta("dlTitleSrc", list(mem[0x2842:0x28AF])))
    s.append(dta("dlCrashSrc", list(mem[0x28B1:0x28EC])))
    s.append(dta("dlWinSrc", list(mem[0x28EE:0x290B])))
    s.append("; 'SPEED' and 'DISTANCE' written sideways into the bars")
    s.append(dta("barTxt1", list(mem[0x290D:0x292A])))
    s.append(dta("barTxt2", list(mem[0x292C:0x2957])))
    open(os.path.join(out, "gen", "speedmaza_data.asm"), "w").write("\n".join(s) + "\n")

    # preview with checkpoints and start
    from PIL import ImageDraw
    dr = ImageDraw.Draw(prev)
    fy = (MAP_ROWS * 8 * 4 // 5) / (MAP_ROWS * 8)
    for x, y in zip(cpx, cpy):
        dr.rectangle([x - 2, y * fy - 2, x + 2, y * fy + 2], outline=(255, 0, 0))
    dr.ellipse([sx - 5, sy * fy - 5, sx + 5, sy * fy + 5], outline=(255, 255, 0))
    prev.save(os.path.join(out, "gen", "track_preview.png"))
    sprite = Image.new("RGB", (32 * 18, 14), (0, 0, 0))
    for f in range(32):
        for r in range(12):
            bits = frames0[f * 12 + r] << 8 | frames3[f * 12 + r]
            for c in range(16):
                if bits >> (15 - c) & 1:
                    sprite.putpixel((f * 18 + c, r + 1), (255, 150, 0))
    sprite.resize((32 * 18 * 3, 14 * 6), Image.NEAREST).save(
        os.path.join(out, "gen", "car_preview.png"))
    print(f"checkpoints {n}, start ({int(sx)},{int(sy)}), room x {room_x:.0f} y {room_y:.0f}")


if __name__ == "__main__":
    main()
