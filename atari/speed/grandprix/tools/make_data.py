#!/usr/bin/env python3
"""Build the data of SPEEDMAZA GRAND PRIX from the PICO-8 game and SpeedMaza.

All four tracks of picospeed.txt, each drawn like SPEEDMAZA RACE's track
(centre line 2x the PICO-8 size, straights turned into S-bends, road of half
width 42 around it, two colours), with checkpoints, how sharp the road bends
after each checkpoint (the computer cars brake by it), a starting grid and
oil patches. Every row of a track is stored as its road spans (first and
last pixel), most rows as small changes from the row above; that stream and
the checkpoint tables are packed with a small LZ77 variant. When a race
starts the game unpacks the chosen track to $6000 and rebuilds the rows in
the span format of SPEEDMAZA RACE in a work area at $3000.

Usage: python3 make_data.py PICO_TXT SPEEDMAZA_IMAGE OUTDIR
Writes OUTDIR/data/*.bin, OUTDIR/gen/*.asm and OUTDIR/gen/*.png
"""
import math
import os
import re
import sys

import numpy as np
from PIL import Image, ImageDraw

# ---- geometry -------------------------------------------------------------
SX = 0.95            # colour clocks per PICO-8 pixel
SY = 1.52            # scan lines per PICO-8 pixel (keeps circles round)
SCALE = 2.0          # track layout 2x the PICO-8 size
ROAD_R = 42          # road half width (PICO-8 track: 28): room for 3 cars
VIEW_X = 0x51        # car x minus camera x (see grandprix.asm, UpdateCamera)
VIEW_Y = 92          # car y minus camera y (scan lines)
DL_LINES = 23        # mode 8 lines in the game display list
CAR_SCALE = 0.72     # PICO-8 car is 11x6 px; 8 px wide here
START_BACK = 24      # grid: cars this far (PICO-8 px) before the start line
GRID = [(-18, 0), (-6, -15), (-6, 15)]   # (along, across) per car, inside the road
CP_R = 64            # checkpoint box half size (PICO-8 px)
WIGGLE_A = 36        # S-bends on the straights: sideways amplitude
WIGGLE_L = 360       # ... and length of one left-right pair
OIL = 6              # oil patches per track (2 bytes x 3 rows each)
MINI_CX = 78         # minimap: centre (mode E pixel) in the 160 x 29 status bar
MINI_H = 29          # ... its height; x = cc / 96, y = lines / 96 (keeps the shape)

# ---- work area in the game (must match grandprix.asm)
WORK = 0x3000
MAX_CP = 132
MAX_ROWS = 372
W_CP = WORK                       # cpXLo, cpXHi, cpYLo, cpYHi, cpCurve
W_ROWPTR = WORK + 5 * MAX_CP      # 2 bytes per map row, filled by the game
W_SPANS = W_ROWPTR + 2 * MAX_ROWS
W_END = 0x48DF                    # RMT player starts here
LOW_AREA = (0x0700, 0x2000)       # packed tracks moved here at start
LOW_TEMP = 0x6000                 # ... loaded here first (map ring, unused then)


def track_points(code):
    """Centre line of one PICO-8 track, scaled, with S-bends on the straights."""
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
    seg = np.hypot(*(np.roll(P, -1, 0) - P).T)
    s = np.concatenate([[0], np.cumsum(seg)[:-1]])
    L = seg.sum()
    straight = (np.array(bend) == 0).astype(float)
    half = int(WIGGLE_L / 2 / (8 * SCALE))
    kern = np.ones(2 * half + 1) / (2 * half + 1)
    w = np.convolve(np.concatenate([straight[-half:], straight, straight[:half]]),
                    kern, "valid")
    w = np.clip((w - 0.35) / 0.5, 0, 1)
    from_start = np.minimum(s, L - s)
    w *= np.clip((from_start - 0.5 * WIGGLE_L) / (0.5 * WIGGLE_L), 0, 1)
    t = np.roll(P, -1, 0) - np.roll(P, 1, 0)
    t /= np.hypot(*t.T)[:, None]
    normal = np.stack([-t[:, 1], t[:, 0]], 1)
    off = WIGGLE_A * w * np.sin(2 * math.pi * s / WIGGLE_L)
    Q = P + normal * off[:, None]
    line = [tuple(q) for q in Q] + [tuple(Q[0])]
    cps = [tuple(Q[i]) for i in range(4, n, 4)] + [tuple(Q[0])]
    return line, cps


def clear_mask(p0, p1):
    """AND mask turning pixels p0..p1 of a mode 8 byte into 00 (road)."""
    m = 0xFF
    for p in range(p0, p1 + 1):
        m &= ~(3 << (6 - 2 * p)) & 0xFF
    return m


def build_track(code, number):
    line, cps = track_points(code)
    start_x, start_y = line[0]
    reach = ROAD_R + 4
    xs = [p[0] for p in line]
    ys = [p[1] for p in line]
    x_lo, x_hi = min(xs) - reach, max(xs) + reach
    y_lo, y_hi = min(ys) - reach, max(ys) + reach
    map_bytes = math.ceil((x_hi - x_lo) * SX / 16) + 12 + 1
    map_rows = math.ceil((y_hi - y_lo) * SY / 8) + DL_LINES + 1
    assert map_bytes <= 256 and map_rows <= MAX_ROWS, (map_bytes, map_rows)
    cam_x_max = (map_bytes - 12) * 16
    cam_y_max = (map_rows - DL_LINES) * 8
    off_x = VIEW_X + (cam_x_max - (x_hi - x_lo) * SX) / 2 - x_lo * SX
    off_y = VIEW_Y + (cam_y_max - (y_hi - y_lo) * SY) / 2 - y_lo * SY

    def to_world(x, y):
        return x * SX + off_x, y * SY + off_y

    # road where a pixel centre is within ROAD_R of the line
    W = map_bytes * 4
    px = (np.arange(W) * 4 + 2 - off_x) / SX
    py = (np.arange(map_rows) * 8 + 4 - off_y) / SY
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
    col = np.where(dist <= ROAD_R, 0, 3).astype(np.uint8)

    # rows as road spans: count, then first byte, mask, last byte, mask
    # (the format the game unpacks rows from), and the stored form: pixel
    # intervals, as changes from the row above when possible
    spans = bytearray()
    stream = bytearray()
    prev = []
    for r in range(map_rows):
        road = np.flatnonzero(col[r] == 0)
        sp = []
        if len(road):
            cuts = np.flatnonzero(np.diff(road) > 1)
            for x0, x1 in zip(np.r_[road[0], road[cuts + 1]], np.r_[road[cuts], road[-1]]):
                b0, b1 = x0 // 4, x1 // 4
                if b0 == b1:
                    m0 = m1 = clear_mask(x0 % 4, x1 % 4)
                else:
                    m0, m1 = clear_mask(x0 % 4, 3), clear_mask(0, x1 % 4)
                sp.append((b0, m0, b1, m1))
        spans.append(len(sp))
        for s_ in sp:
            spans += bytes(s_)
        px_ = [(int(a), int(b)) for a, b in
               (zip(np.r_[road[0], road[cuts + 1]], np.r_[road[cuts], road[-1]])
                if len(road) else [])]
        if px_ and len(px_) == len(prev) and all(
                -64 <= a - c < 64 and -64 <= b - d < 64 for (a, b), (c, d) in zip(px_, prev)):
            stream.append(0x80 | len(px_))
            for (a, b), (c, d) in zip(px_, prev):
                stream += bytes([(a - c) & 0xFF, (b - d) & 0xFF])
        else:
            stream.append(len(px_))
            for a, b in px_:
                stream += bytes([a & 0xFF, a >> 8, b & 0xFF, b >> 8])
        prev = px_
    assert rebuild_spans(stream, map_rows) == spans
    assert W_SPANS + len(spans) <= W_END, hex(W_SPANS + len(spans))

    # checkpoints; the last one fires on the start line
    pts = cps[:-1] + [(start_x + CP_R, start_y)]
    n = len(pts)
    assert n <= MAX_CP
    wpts = [to_world(x, y) for x, y in pts]
    # sharpness of the road after each checkpoint: heading change (256 =
    # full turn) from this checkpoint to three further on
    ang = [math.atan2(pts[(i + 1) % n][1] - pts[i][1], pts[(i + 1) % n][0] - pts[i][0])
           for i in range(n)]
    curve = []
    for i in range(n):
        tot = 0
        for k in range(3):
            da = ang[(i + k + 1) % n] - ang[(i + k) % n]
            da = (da + math.pi) % (2 * math.pi) - math.pi
            tot += abs(da)
        curve.append(min(63, round(tot / (2 * math.pi) * 256)))

    # oil: patches on the line at evenly spread checkpoints, a bit to the side
    oil = []
    rng = np.random.default_rng(number + 7)
    for i in range(OIL):
        k = 12 + i * (n - 24) // OIL
        (x0, y0), (x1, y1) = pts[k], pts[k + 1]
        nx, ny = -(y1 - y0), x1 - x0
        ln = math.hypot(nx, ny)
        side = rng.uniform(-ROAD_R * 0.45, ROAD_R * 0.45)
        wx, wy = to_world(x0 + nx / ln * side, y0 + ny / ln * side)
        oil.append((int(wy) // 8 - 1, int(wx) // 16))           # top row, first byte

    grid = [to_world(start_x - START_BACK * SCALE + al * SCALE, start_y + ac * SCALE)
            for al, ac in GRID]

    # the unpacked work area: checkpoint tables, room for the row pointers
    # (the game fills them), spans
    blob = bytearray(W_SPANS - WORK)
    for i, (x, y) in enumerate(wpts):
        blob[i] = int(x) & 0xFF
        blob[MAX_CP + i] = int(x) >> 8
        blob[2 * MAX_CP + i] = int(y) & 0xFF
        blob[3 * MAX_CP + i] = int(y) >> 8
        blob[4 * MAX_CP + i] = curve[i]
    unpacked = bytes(blob[:5 * MAX_CP]) + bytes(stream)

    # preview
    img = np.where(col == 0, 0, 150).astype(np.uint8)
    for (r, b) in oil:
        img[r:r + 3, b * 4:b * 4 + 8] = np.where(img[r:r + 3, b * 4:b * 4 + 8] == 0, 90, 150)
    prev = Image.fromarray(img).convert("RGB")
    prev = prev.resize((W, int(map_rows * 8 / 4 / 1.2)), Image.NEAREST)
    dr = ImageDraw.Draw(prev)
    for (x, y) in wpts:
        dr.point((x / 4, y / 4 / 1.2), fill=(255, 0, 0))
    for (x, y) in grid:
        dr.point((x / 4, y / 4 / 1.2), fill=(255, 255, 0))

    # minimap: pixel = (world x / 32) / 3 + addX, line = (world y / 32) / 3 + addY
    mxs = [(int(x) >> 5) // 3 for x, y in wpts]
    mys = [(int(y) >> 5) // 3 for x, y in wpts]
    w, h = max(mxs) - min(mxs) + 1, max(mys) - min(mys) + 1
    assert h <= MINI_H and w <= 64, (w, h)
    mini_x = (MINI_CX - w // 2 - min(mxs)) & 0xFF
    mini_y = ((MINI_H - h) // 2 - min(mys)) & 0xFF

    return dict(blob=unpacked, cp=n, mini_x=mini_x, mini_y=mini_y, map_bytes=map_bytes, map_rows=map_rows,
                cam_x_max=cam_x_max, cam_y_max=cam_y_max, grid=grid, oil=oil,
                preview=prev)


MASK_L = [clear_mask(p, 3) for p in range(4)]      # clear pixels p..3
MASK_R = [clear_mask(0, p) for p in range(4)]      # clear pixels 0..p


def rebuild_spans(stream, rows):
    """What the game's BuildSpans does: stream -> span rows."""
    out = bytearray()
    prev0, prev1 = [0] * 16, [0] * 16
    i = 0
    for r in range(rows):
        c = stream[i]
        i += 1
        n = c & 0x7F
        out.append(n)
        for k in range(n):
            if c & 0x80:
                d0, d1 = stream[i], stream[i + 1]
                i += 2
                x0 = prev0[k] + (d0 - 256 if d0 > 127 else d0)
                x1 = prev1[k] + (d1 - 256 if d1 > 127 else d1)
            else:
                x0 = stream[i] | stream[i + 1] << 8
                x1 = stream[i + 2] | stream[i + 3] << 8
                i += 4
            prev0[k], prev1[k] = x0, x1
            b0, b1 = x0 >> 2, x1 >> 2
            m0, m1 = MASK_L[x0 & 3], MASK_R[x1 & 3]
            if b0 == b1:
                m0 = m1 = m0 | m1
            out += bytes([b0, m0, b1, m1])
    return bytes(out)


def lz_pack(data):
    """LZ77 variant, decoded by Unpack in grandprix.asm.

    Token t < $80: t+1 literal bytes follow. t >= $80: copy (t & $7F) + 3
    bytes from 'offset' bytes back (offset: 2 bytes, low first). The
    unpacked length is known to the decoder.
    """
    out = bytearray()
    lits = bytearray()
    heads = {}

    def flush():
        while lits:
            chunk = lits[:128]
            out.append(len(chunk) - 1)
            out.extend(chunk)
            del lits[:128]
    i = 0
    n = len(data)
    while i < n:
        best_len, best_off = 0, 0
        if i + 3 <= n:
            for j in reversed(heads.get(data[i:i + 3], [])[-64:]):
                k = 3
                while i + k < n and k < 130 and data[j + k] == data[i + k]:
                    k += 1
                if k > best_len:
                    best_len, best_off = k, i - j
                    if k == 130:
                        break
        if best_len >= 4 or (best_len == 3 and not lits):
            flush()
            out.append(0x80 | (best_len - 3))
            out += bytes([best_off & 0xFF, best_off >> 8])
            for k in range(best_len):
                heads.setdefault(data[i + k:i + k + 3], []).append(i + k)
            i += best_len
        else:
            heads.setdefault(data[i:i + 3], []).append(i)
            lits.append(data[i])
            i += 1
    flush()
    return bytes(out)


def lz_unpack(packed, length):
    out = bytearray()
    i = 0
    while len(out) < length:
        t = packed[i]
        i += 1
        if t < 0x80:
            out += packed[i:i + t + 1]
            i += t + 1
        else:
            off = packed[i] | packed[i + 1] << 8
            i += 2
            for _ in range((t & 0x7F) + 3):
                out.append(out[-off])
    return bytes(out)


def dta(name, vals, fmt="${:02X}"):
    lines = [f"{name}"]
    for i in range(0, len(vals), 16):
        lines.append("\tdta " + ",".join(fmt.format(v) for v in vals[i:i + 16]))
    return "\n".join(lines)


def main():
    pico_txt, image, out = sys.argv[1:4]
    mem = open(image, "rb").read()
    os.makedirs(os.path.join(out, "data"), exist_ok=True)
    os.makedirs(os.path.join(out, "gen"), exist_ok=True)
    txt = open(pico_txt).read()
    m = re.search(r'w=\{(.*?)\}\n', txt, re.S)
    codes = re.findall(r'"([^"]*)"', m.group(1))
    tracks = [build_track(c, i) for i, c in enumerate(codes)]

    # pack, then place: as many as fit in the low area, the rest after the code
    low, high = bytearray(), bytearray()
    where = []
    for t in tracks:
        p = lz_pack(t["blob"])
        assert lz_unpack(p, len(t["blob"])) == t["blob"]
        t["packed"] = p
        if LOW_AREA[0] + len(low) + len(p) <= LOW_AREA[1]:
            where.append(("low", len(low)))
            low += p
        else:
            where.append(("high", len(high)))
            high += p
    open(os.path.join(out, "data", "tracks_low.bin"), "wb").write(low)
    open(os.path.join(out, "data", "tracks_high.bin"), "wb").write(high)

    g = ["; generated by tools/make_data.py - do not edit"]
    g.append(f"TRACKS\t= {len(tracks)}")
    g.append(f"CP_RX\t= {int(CP_R * SX)}\t; checkpoint box half width (cc)")
    g.append(f"CP_RY\t= {int(CP_R * SY)}\t; checkpoint box half height (lines)")
    g.append(f"VIEW_X\t= {VIEW_X}")
    g.append(f"VIEW_Y\t= {VIEW_Y}")
    g.append(f"WORK\t= ${WORK:04X}\t; unpacked track")
    g.append(f"MAX_CP\t= {MAX_CP}")
    g.append(f"W_ROWPTR\t= ${W_ROWPTR:04X}")
    g.append(f"W_SPANS\t= ${W_SPANS:04X}")
    g.append(f"LOW_AREA\t= ${LOW_AREA[0]:04X}\t; packed tracks, moved here from LOW_TEMP")
    g.append(f"LOW_TEMP\t= ${LOW_TEMP:04X}")
    g.append(f"LOW_SIZE\t= {len(low)}")
    g.append(f"CP_TABLES\t= {5 * MAX_CP}\t; unpacked: checkpoint tables, then the row stream")
    g.append("; per track: packed data, unpacked length, map and camera size")
    srcs = [(f"LOW_AREA+{o}" if w == "low" else f"tracksHigh+{o}") for w, o in where]
    g.append("tdSrcLo\n\tdta " + ",".join(f"<({s})" for s in srcs))
    g.append("tdSrcHi\n\tdta " + ",".join(f">({s})" for s in srcs))
    for name, key in (("tdLen", None), ("tdRows", "map_rows"), ("tdCamX", "cam_x_max"),
                      ("tdCamY", "cam_y_max")):
        vals = [len(t["blob"]) if key is None else t[key] for t in tracks]
        g.append(dta(name + "Lo", [v & 0xFF for v in vals]))
        g.append(dta(name + "Hi", [v >> 8 for v in vals]))
    g.append(dta("tdBytes", [t["map_bytes"] for t in tracks]))
    g.append("; minimap: pixel = x / 32 / 3 + tdMiniX, line = y / 32 / 3 + tdMiniY")
    g.append(dta("tdMiniX", [t["mini_x"] for t in tracks]))
    g.append(dta("tdMiniY", [t["mini_y"] for t in tracks]))
    g.append(dta("tdCp", [t["cp"] for t in tracks]))
    g.append("; starting grid per track (index track*3+car)")
    gx = [int(x) for t in tracks for x, y in t["grid"]]
    gy = [int(y) for t in tracks for x, y in t["grid"]]
    g.append(dta("gridXLo", [v & 0xFF for v in gx]))
    g.append(dta("gridXHi", [v >> 8 for v in gx]))
    g.append(dta("gridYLo", [v & 0xFF for v in gy]))
    g.append(dta("gridYHi", [v >> 8 for v in gy]))
    g.append(f"; oil patches per track (index track*{OIL}+patch): first row, first byte")
    g.append(f"OIL_N\t= {OIL}")
    rows = [r for t in tracks for r, b in t["oil"]]
    g.append(dta("oilRowLo", [r & 0xFF for r in rows]))
    g.append(dta("oilRowHi", [r >> 8 for r in rows]))
    g.append(dta("oilByte", [b for t in tracks for r, b in t["oil"]]))

    # car sprites: 32 directions, 8x10, one player each
    frames = []
    for f in range(32):
        z = f / 32
        a, b = math.cos(2 * math.pi * z), math.sin(2 * math.pi * z)
        poly = []
        for j in (1, 2):
            i = 0.125
            while i <= 1.25 + 1e-9:
                d = j * math.cos(2 * math.pi * i) * 4 * CAR_SCALE
                e = -math.sin(2 * math.pi * i) * 4 * CAR_SCALE
                poly.append((d * a + b * e, e * a - b * d))
                i += 0.25
        grid = [[0] * 8 for _ in range(10)]
        for (x0, y0), (x1, y1) in zip(poly, poly[1:]):
            for s_ in range(41):
                t = s_ / 40
                x = (x0 + (x1 - x0) * t) * SX
                y = (y0 + (y1 - y0) * t) * SY / 2
                gx_, gy_ = int(math.floor(x + 4)), int(math.floor(y + 5))
                if 0 <= gx_ < 8 and 0 <= gy_ < 10:
                    grid[gy_][gx_] = 1
        for row in grid:
            frames.append(int("".join(map(str, row)), 2))
    g.append("; car: 32 directions x 10 lines (PM double lines)")
    g.append(dta("carShape", frames))
    cos_t = [round(127 * math.cos(2 * math.pi * t / 256)) & 0xFF for t in range(256)]
    siny_t = [round(-127 * SY / SX / 2 * math.sin(2 * math.pi * t / 256)) & 0xFF
              for t in range(256)]
    g.append("; cos(t)*127 and -sin(t)*127*1.6/2 for t = 0..255 (256 = full turn)")
    g.append(dta("cosTab", cos_t))
    g.append(dta("sinYTab", siny_t))
    open(os.path.join(out, "gen", "tables.asm"), "w").write("\n".join(g) + "\n")

    # SpeedMaza parts
    def blob(name, lo, hi):
        open(os.path.join(out, "data", name), "wb").write(mem[lo:hi + 1])
    for old in ("track_rle.bin",):
        if os.path.exists(os.path.join(out, "data", old)):
            os.remove(os.path.join(out, "data", old))
    blob("title_pic.bin", 0x1000, 0x1FFF)
    blob("rmt_player.bin", 0x48DF, 0x4FFF)
    blob("music.bin", 0x5000, 0x5BA6)
    s = ["; generated by tools/make_data.py from the SpeedMaza image - do not edit"]
    s.append(dta("dlTitleSrc", list(mem[0x2842:0x28AF])))
    s.append("; crash screen display list (the 3-2-1-START screens use it)")
    s.append(dta("dlCrashSrc", list(mem[0x28B1:0x28EC])))
    s.append(dta("dlWinSrc", list(mem[0x28EE:0x290B])))
    open(os.path.join(out, "gen", "speedmaza_data.asm"), "w").write("\n".join(s) + "\n")

    # previews: the four tracks side by side, and the car
    ims = [t["preview"] for t in tracks]
    h = max(i.height for i in ims)
    sheet = Image.new("RGB", (sum(i.width for i in ims) + 10 * len(ims), h), (40, 40, 40))
    x = 0
    for i in ims:
        sheet.paste(i, (x, 0))
        x += i.width + 10
    sheet.save(os.path.join(out, "gen", "tracks_preview.png"))
    sprite = Image.new("RGB", (32 * 10, 12), (0, 0, 0))
    for f in range(32):
        for r in range(10):
            for c in range(8):
                if frames[f * 10 + r] >> (7 - c) & 1:
                    sprite.putpixel((f * 10 + c, r + 1), (255, 150, 0))
    sprite.resize((32 * 10 * 3, 12 * 6), Image.NEAREST).save(
        os.path.join(out, "gen", "car_preview.png"))
    for old in ("track_preview.png",):
        if os.path.exists(os.path.join(out, "gen", old)):
            os.remove(os.path.join(out, "gen", old))
    for i, t in enumerate(tracks):
        print(f"track {i + 1}: map {t['map_bytes']}x{t['map_rows']}, {t['cp']} checkpoints, "
              f"{len(t['blob'])} -> {len(t['packed'])} bytes, {where[i][0]}")
    print(f"low area {len(low)} of {LOW_AREA[1] - LOW_AREA[0]}, high {len(high)}")


if __name__ == "__main__":
    main()
