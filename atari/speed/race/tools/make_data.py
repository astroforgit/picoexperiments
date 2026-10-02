#!/usr/bin/env python3
"""Build the data of SPEEDMAZA RACE from the PICO-8 game and the SpeedMaza image.

Track: the centre line of track 1 of picospeed.txt, 3x bigger, its
straights bent into S-curves, with a road
of half width 35 around it, drawn into an ANTIC mode 8 map in two colours
like SpeedMaza's maze (road = background, the rest = walls). Every map row
is stored as its list of road spans; the game unpacks rows as they scroll
into view.
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
SCALE = 3.0          # track layout 3x the PICO-8 size (a longer lap)
ROAD_R = 35          # road half width (PICO-8 track: 28)
RING_ROWS = 32       # rows unpacked at a time ($6000-$7FFF, 256 bytes each)
VIEW_X = 0x51        # car x minus camera x (see race.asm, UpdateCamera)
VIEW_Y = 90          # car y minus camera y (scan lines)
DL_LINES = 27        # mode 8 lines in the game display list
CAR_SCALE = 1.25     # PICO-8 car is 11x6 px; a bit bigger here
START_BACK = 20      # car starts this far (PICO-8 px) before the start line
CP_R = 64            # checkpoint box half size (PICO-8 px)
WIGGLE_A = 50        # S-bends on the straights: sideways amplitude
WIGGLE_L = 460       # ... and length of one left-right pair


def track_points(txt):
    """Centre line of PICO-8 track 1, scaled, with S-bends on the straights.

    Returns the polyline (closed) and the checkpoints (one per PICO-8 track
    character, i.e. every 4th point).
    """
    m = re.search(r'w=\{(.*?)\}\n', txt, re.S)
    code = re.findall(r'"([^"]*)"', m.group(1))[0]          # track 1
    d = e = 64.0
    c = 0.0
    pts, bend = [(d, e)], [0.0]
    for ch in code:
        dc = ord(ch) / 32 - 1.75                             # turn per character
        c += dc
        a = math.cos(2 * math.pi * c) * 8
        b = -math.sin(2 * math.pi * c) * 8                   # PICO-8 sin
        for j in range(4):
            d += a
            e += b
            pts.append((d, e))
            bend.append(abs(dc))
    P = np.array(pts) * SCALE
    n = len(P)
    # arc length along the (closed) line
    seg = np.hypot(*(np.roll(P, -1, 0) - P).T)
    s = np.concatenate([[0], np.cumsum(seg)[:-1]])
    L = seg.sum()
    # weight 1 on straights, fading to 0 at the corners and at the start line
    straight = (np.array(bend) == 0).astype(float)
    half = int(WIGGLE_L / 2 / (8 * SCALE))
    kern = np.ones(2 * half + 1) / (2 * half + 1)
    w = np.convolve(np.concatenate([straight[-half:], straight, straight[:half]]),
                    kern, "valid")
    w = np.clip((w - 0.35) / 0.5, 0, 1)
    from_start = np.minimum(s, L - s)
    w *= np.clip((from_start - 0.5 * WIGGLE_L) / (0.5 * WIGGLE_L), 0, 1)
    # shift sideways by a sine: S-bends
    t = np.roll(P, -1, 0) - np.roll(P, 1, 0)
    t /= np.hypot(*t.T)[:, None]
    normal = np.stack([-t[:, 1], t[:, 0]], 1)
    off = WIGGLE_A * w * np.sin(2 * math.pi * s / WIGGLE_L)
    Q = P + normal * off[:, None]
    line = [tuple(q) for q in Q] + [tuple(Q[0])]
    cps = [tuple(Q[i]) for i in range(4, n, 4)] + [tuple(Q[0])]
    return line, cps


LOGO_WORD = "HARD"   # replaces the big "SPEED" of the title logo
LOGO_FONT = "/usr/share/fonts/opentype/urw-base35/NimbusSans-Bold.otf"
LOGO_BOX = (2, 2, 90, 29)   # x0, y0, x1, y1 in mode E pixels (old "SPEED")
# credit lines, in the letters of the SpeedMaza credits (one line would not fit)
CREDIT = ["TINY", "MODIFICATIONS:", "ASTROFOR"]
# SpeedMaza credit lines: first picture line and text (spaces left out)
FONT_LINES = {29: "GAME:HUSAK", 37: "CODE:HUSAK", 45: "GFX:HUSAK",
              61: "HISCORE:HUSAK", 69: "PRESSBUTTON"}
# no Y in SpeedMaza: the top of its X on a stem
GLYPH_Y = ["2331.1332", ".3331332.", "..33333..", "...333...",
           "...333...", "...333...", "...333...", "...333..."]
LETTER_GAP = 2
WORD_GAP = 9


def mode_e_pack(pix):
    """2-bit pixel rows (numpy, width 160) -> mode E bytes."""
    p = pix.reshape(pix.shape[0], 40, 4).astype(np.uint8)
    return (p[..., 0] << 6 | p[..., 1] << 4 | p[..., 2] << 2 | p[..., 3]).tobytes()


def mode_e_unpack(data, rows):
    b = np.frombuffer(data, np.uint8)[:rows * 40].reshape(rows, 40)
    return np.stack([(b >> s) & 3 for s in (6, 4, 2, 0)], 2).reshape(rows, 160)


def title_logo(pic):
    """Draw LOGO_WORD over the big "SPEED" of the title picture.

    The word is rendered from a bold sans font and shaded with colours 1-2
    at the edges, like the original lettering.
    """
    from PIL import ImageDraw, ImageFont
    x0, y0, x1, y1 = LOGO_BOX
    k = 8                                                  # supersampling
    font = ImageFont.truetype(LOGO_FONT, 200)
    l, t, r, b = font.getbbox(LOGO_WORD)
    img = Image.new("L", (r - l, b - t), 0)
    ImageDraw.Draw(img).text((-l, -t), LOGO_WORD, 255, font=font)
    img = img.resize(((x1 - x0) * k, (y1 - y0) * k), Image.LANCZOS)
    cov = np.asarray(img.resize((x1 - x0, y1 - y0), Image.BOX)) / 255
    rows = y1                                              # logo lines 0..28
    pix = mode_e_unpack(pic, rows).copy()
    pix[:, :x1 + 2] = 0                                    # clear "SPEED"
    pix[y0:y1, x0:x1] = np.digitize(cov, [0.2, 0.45, 0.75])
    return mode_e_pack(pix) + pic[rows * 40:]


def credit_line(pic):
    """CREDIT lines, centred, 8 mode E lines each, in the SpeedMaza letters."""
    pix = mode_e_unpack(pic, 85)
    font = {"Y": np.array([[int(c) if c != "." else 0 for c in r] for r in GLYPH_Y])}
    for r, text in FONT_LINES.items():
        rows = pix[r:r + 8]
        on = np.flatnonzero(rows.any(0))
        cuts = np.flatnonzero(np.diff(on) > 1)
        segs = list(zip(np.r_[on[0], on[cuts + 1]], np.r_[on[cuts], on[-1]] + 1))
        assert len(segs) == len(text), text
        for ch, (x0, x1) in zip(text, segs):
            font.setdefault(ch, rows[:, x0:x1])
    out = b""
    for line in CREDIT:
        glyphs = []
        for word in line.split():
            if glyphs:
                glyphs.append(np.zeros((8, WORD_GAP - LETTER_GAP), np.uint8))
            for ch in word:
                glyphs += [font[ch], np.zeros((8, LETTER_GAP), np.uint8)]
        img = np.hstack(glyphs[:-1])
        w = img.shape[1]
        assert w <= 160, (line, w)
        rows = np.zeros((8, 160), np.uint8)
        rows[:, (160 - w) // 2:(160 - w) // 2 + w] = img
        out += mode_e_pack(rows)
    return out


def main():
    pico_txt, image, out = sys.argv[1:4]
    mem = open(image, "rb").read()
    os.makedirs(os.path.join(out, "data"), exist_ok=True)
    os.makedirs(os.path.join(out, "gen"), exist_ok=True)
    line, cps = track_points(open(pico_txt).read())
    start_x, start_y = line[0]

    # ---- map size: the camera must stay inside the map wherever the car
    # can be (on the road, a few pixels over the edge at most)
    reach = ROAD_R + 4
    xs = [p[0] for p in line]
    ys = [p[1] for p in line]
    x_lo, x_hi = min(xs) - reach, max(xs) + reach
    y_lo, y_hi = min(ys) - reach, max(ys) + reach
    map_bytes = math.ceil((x_hi - x_lo) * SX / 16) + 12 + 1
    map_rows = math.ceil((y_hi - y_lo) * SY / 8) + DL_LINES + 1
    assert map_bytes <= 256, map_bytes
    cam_x_max = (map_bytes - 12) * 16
    cam_y_max = (map_rows - DL_LINES) * 8
    off_x = VIEW_X + (cam_x_max - (x_hi - x_lo) * SX) / 2 - x_lo * SX
    off_y = VIEW_Y + (cam_y_max - (y_hi - y_lo) * SY) / 2 - y_lo * SY

    def to_world(x, y):
        return x * SX + off_x, y * SY + off_y

    # ---- rasterise: road where a pixel centre is within ROAD_R of the line
    W = map_bytes * 4
    px = (np.arange(W) * 4 + 2 - off_x) / SX              # pico x per column
    py = (np.arange(map_rows) * 8 + 4 - off_y) / SY       # pico y per row
    dist = np.full((map_rows, W), 1e9)
    for (x0, y0), (x1, y1) in zip(line, line[1:]):
        c0 = max(0, np.searchsorted(px, min(x0, x1) - ROAD_R) - 1)
        c1 = np.searchsorted(px, max(x0, x1) + ROAD_R) + 1
        r0 = max(0, np.searchsorted(py, min(y0, y1) - ROAD_R) - 1)
        r1 = np.searchsorted(py, max(y0, y1) + ROAD_R) + 1
        X, Y = np.meshgrid(px[c0:c1], py[r0:r1])
        vx, vy = x1 - x0, y1 - y0
        t = np.clip(((X - x0) * vx + (Y - y0) * vy) / (vx * vx + vy * vy), 0, 1)
        dd = np.hypot(X - x0 - t * vx, Y - y0 - t * vy)
        dist[r0:r1, c0:c1] = np.minimum(dist[r0:r1, c0:c1], dd)
    col = np.where(dist <= ROAD_R, 0, 3).astype(np.uint8)  # road / wall (PF2)

    # ---- compress every row as its road spans. Row = walls ($FF bytes)
    # except the spans: count, then per span first byte, AND mask for it,
    # last byte, AND mask for it (bytes in between become 0)
    def clear_mask(p0, p1):                                # pixels p0..p1 -> 00
        m = 0xFF
        for p in range(p0, p1 + 1):
            m &= ~(3 << (6 - 2 * p)) & 0xFF
        return m
    rle = bytearray()
    row_off = []
    for r in range(map_rows):
        road = np.flatnonzero(col[r] == 0)
        spans = []
        if len(road):
            cuts = np.flatnonzero(np.diff(road) > 1)
            for x0, x1 in zip(np.r_[road[0], road[cuts + 1]], np.r_[road[cuts], road[-1]]):
                b0, b1 = x0 // 4, x1 // 4
                if b0 == b1:
                    m0 = m1 = clear_mask(x0 % 4, x1 % 4)
                else:
                    m0, m1 = clear_mask(x0 % 4, 3), clear_mask(0, x1 % 4)
                spans.append((b0, m0, b1, m1))
        row_off.append(len(rle))
        rle.append(len(spans))
        for sp in spans:
            rle += bytes(sp)
    open(os.path.join(out, "data", "track_rle.bin"), "wb").write(rle)

    # preview: one pixel per mode 8 pixel, rows squeezed to keep proportions
    prev = Image.fromarray(np.where(col == 0, 0, 150).astype(np.uint8))
    prev = prev.convert("RGB").resize((W, int(map_rows * 8 / 4 / 1.2)), Image.NEAREST)

    # ---- checkpoints (world cc / lines); the last one fires on the line
    pts = cps[:-1] + [(start_x + CP_R, start_y)]           # fires at the start x
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

    sx, sy = to_world(start_x - START_BACK * SCALE, start_y)
    cos_t = [round(127 * math.cos(2 * math.pi * t / 256)) & 0xFF for t in range(256)]
    siny_t = [round(-127 * SY / SX / 2 * math.sin(2 * math.pi * t / 256)) & 0xFF
              for t in range(256)]
    prog = [min(0x60, round(i * 0x60 / n)) for i in range(n + 1)]
    g = []
    g.append("; generated by tools/make_data.py - do not edit")
    g.append(f"CP_COUNT\t= {n}\t; checkpoints (last one = start/finish line)")
    g.append(f"START_X\t= {int(sx)}\t; car start, colour clocks")
    g.append(f"START_Y\t= {int(sy)}\t; car start, scan lines")
    g.append(f"CP_RX\t= {int(CP_R * SX)}\t; checkpoint box half width (cc)")
    g.append(f"CP_RY\t= {int(CP_R * SY)}\t; checkpoint box half height (lines)")
    g.append(f"MAP_BYTES\t= {map_bytes}")
    g.append(f"MAP_ROWS\t= {map_rows}")
    g.append(f"CAM_X_MAX\t= {cam_x_max}")
    g.append(f"CAM_Y_MAX\t= {cam_y_max}")
    g.append(f"VIEW_X\t= {VIEW_X}")
    g.append(f"VIEW_Y\t= {VIEW_Y}")
    g.append("; start of every compressed map row")
    g.append("rowPtr")
    for i in range(0, map_rows, 8):
        g.append("\tdta " + ",".join(f"a(trackRle+{o})" for o in row_off[i:i + 8]))
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
    for old in ("track.bin",):
        if os.path.exists(os.path.join(out, "data", old)):
            os.remove(os.path.join(out, "data", old))
    open(os.path.join(out, "data", "title_pic.bin"), "wb").write(title_logo(mem[0x1000:0x2000]))
    open(os.path.join(out, "data", "credit_pic.bin"), "wb").write(credit_line(mem[0x1000:0x2000]))
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
    fx, fy = 1 / 4, 1 / 4 / 1.2
    for x, y in zip(cpx, cpy):
        dr.rectangle([x * fx - 1, y * fy - 1, x * fx + 1, y * fy + 1], outline=(255, 0, 0))
    dr.ellipse([sx * fx - 3, sy * fy - 3, sx * fx + 3, sy * fy + 3], outline=(255, 255, 0))
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
    print(f"map {map_bytes}x{map_rows}, compressed {len(rle)} bytes, "
          f"checkpoints {n}, start ({int(sx)},{int(sy)})")


if __name__ == "__main__":
    main()
