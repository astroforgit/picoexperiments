#!/usr/bin/env python3
"""VIC-II frame renderer for the headless C64 model (reference pictures).

Renders the last complete frame line by line, applying the register writes
logged during that frame (raster splits). Memory is read as it is now, so
screen/colour RAM changes made during the frame are not separated. Text,
multicolour text, extended colour, hires and multicolour bitmap modes and all
8 sprites (expansion, multicolour, priorities) are drawn. The picture is
384x272: the 320x200 display starts at (32, 35); PAL raster line 16 is y=0.
"""
import numpy as np

PEPTO = [
    (0x00, 0x00, 0x00), (0xFF, 0xFF, 0xFF), (0x68, 0x37, 0x2B), (0x70, 0xA4, 0xB2),
    (0x6F, 0x3D, 0x86), (0x58, 0x8D, 0x43), (0x35, 0x28, 0x79), (0xB8, 0xC7, 0x6F),
    (0x6F, 0x4F, 0x25), (0x43, 0x39, 0x00), (0x9A, 0x67, 0x59), (0x44, 0x44, 0x44),
    (0x6C, 0x6C, 0x6C), (0x9A, 0xD2, 0x84), (0x6C, 0x5E, 0xB5), (0x95, 0x95, 0x95)]
PAL = np.array(PEPTO, dtype=np.uint8)
W, H, TOP, LEFT = 384, 272, 16, 32


def render(c, frame=None, ram=None, colram=None):
    """Return a (272, 384) array of C64 colour indices."""
    regs0, dd00, log, ptrs = frame or c.last_frame
    ram = bytearray(c.mem.ram if ram is None else ram)
    cram = c.colram if colram is None else colram
    for a, v in ptrs.items():
        ram[a] = v
    regs = bytearray(regs0)
    out = np.zeros((H, W), dtype=np.uint8)
    li = 0
    for y in range(H):
        line = y + TOP
        while li < len(log) and log[li][0] < line:
            _, _, r, v = log[li]
            if r >= 0x10000:
                ram[r & 0xFFFF] = v
            elif r == 0x40:
                dd00 = v
            else:
                regs[r] = v
            li += 1
        render_line(out[y], line, regs, dd00, ram, cram)
    return out


def render_line(row, line, regs, dd00, ram, cram):
    bank = (3 - (dd00 & 3)) * 0x4000
    d011, d016, d018 = regs[0x11], regs[0x16], regs[0x18]
    border = regs[0x20] & 15
    row[:] = border
    if not d011 & 0x10:
        return
    top, bot = (51, 251) if d011 & 8 else (55, 247)
    left, right = (LEFT, LEFT + 320) if d016 & 8 else (LEFT + 7, LEFT + 311)
    fg = np.zeros(W, dtype=bool)
    if top <= line < bot:
        ys = d011 & 7
        rel = line - 48 - ys
        pix = np.full(320, regs[0x21] & 15, dtype=np.uint8)
        fgl = np.zeros(320, dtype=bool)
        if rel >= 0:
            crow, py = rel >> 3, rel & 7
            if crow < 25:
                draw_chars(pix, fgl, crow, py, regs, bank, ram, cram)
        xs = d016 & 7
        row[LEFT + xs:LEFT + 320] = pix[:320 - xs]
        row[LEFT:LEFT + xs] = regs[0x21] & 15
        fg[LEFT + xs:LEFT + 320] = fgl[:320 - xs]
        draw_sprites(row, fg, line, regs, bank, ram)
        row[:left] = border
        row[right:] = border
        return
    draw_sprites(row, fg, line, regs, bank, ram, border_only=True)


def vram(ram, bank, a):
    a &= 0x3FFF
    if bank in (0x0000, 0x8000) and 0x1000 <= a < 0x2000:
        return None                       # char ROM (not available)
    return bank + a


def draw_chars(pix, fgl, crow, py, regs, bank, ram, cram):
    d011, d016, d018 = regs[0x11], regs[0x16], regs[0x18]
    ecm, bmm, mcm = d011 & 0x40, d011 & 0x20, d016 & 0x10
    if ecm and (bmm or mcm):
        pix[:] = 0                        # invalid mode: black, foreground still counts
        return
    scr = bank + ((d018 >> 4) & 15) * 0x400 + crow * 40
    bg = [regs[0x21] & 15, regs[0x22] & 15, regs[0x23] & 15, regs[0x24] & 15]
    col = crow * 40
    if bmm:
        bmp = bank + ((d018 & 8) << 10) + crow * 320 + py
        for cx in range(40):
            b = ram[bmp + cx * 8]
            s = ram[scr + cx]
            if mcm:
                cols = (bg[0], s >> 4, s & 15, cram[col + cx] & 15)
                for i in range(4):
                    v = b >> (6 - 2 * i) & 3
                    pix[cx * 8 + 2 * i:cx * 8 + 2 * i + 2] = cols[v]
                    fgl[cx * 8 + 2 * i:cx * 8 + 2 * i + 2] = v >= 2
            else:
                for i in range(8):
                    on = b >> (7 - i) & 1
                    pix[cx * 8 + i] = (s >> 4) if on else (s & 15)
                    fgl[cx * 8 + i] = bool(on)
        return
    cbase = ((d018 >> 1) & 7) * 0x800
    for cx in range(40):
        ch = ram[scr + cx]
        cc = cram[col + cx] & 15
        if ecm:
            back = bg[ch >> 6]
            ch &= 63
        else:
            back = bg[0]
        a = vram(ram, bank, cbase + ch * 8 + py)
        b = ram[a] if a is not None else 0
        if mcm and cc & 8:
            cols = (bg[0], bg[1], bg[2], cc & 7)
            for i in range(4):
                v = b >> (6 - 2 * i) & 3
                pix[cx * 8 + 2 * i:cx * 8 + 2 * i + 2] = cols[v]
                fgl[cx * 8 + 2 * i:cx * 8 + 2 * i + 2] = v >= 2
        else:
            for i in range(8):
                on = b >> (7 - i) & 1
                pix[cx * 8 + i] = cc if on else back
                fgl[cx * 8 + i] = bool(on)


def draw_sprites(row, fg, line, regs, bank, ram, border_only=False):
    en = regs[0x15]
    if not en:
        return
    scr = bank + ((regs[0x18] >> 4) & 15) * 0x400
    for n in range(7, -1, -1):
        if not en >> n & 1:
            continue
        sy = regs[1 + 2 * n]
        yexp = regs[0x17] >> n & 1
        dy = (line - sy - 1) & 0xFF      # the first sprite line is Y+1
        if dy >= (42 if yexp else 21):
            continue
        if yexp:
            dy >>= 1
        sx = regs[2 * n] | ((regs[0x10] >> n & 1) << 8)
        ptr = ram[scr + 0x3F8 + n]
        data = bank + ptr * 64 + dy * 3
        bits = ram[data] << 16 | ram[data + 1] << 8 | ram[data + 2]
        xexp = 2 if regs[0x1D] >> n & 1 else 1
        mc = regs[0x1C] >> n & 1
        behind = regs[0x1B] >> n & 1
        cols = (None, regs[0x25] & 15, regs[0x27 + n] & 15, regs[0x26] & 15)
        x0 = sx + 8
        if sx >= 0x1F8:
            x0 = sx - 0x1F8 + 8 - 8
        for i in range(24 // (2 if mc else 1)):
            if mc:
                v = bits >> (22 - 2 * i) & 3
                c, w = cols[v], 2 * xexp
            else:
                v = bits >> (23 - i) & 1
                c, w = (regs[0x27 + n] & 15 if v else None), xexp
            if c is None:
                continue
            for k in range(w):
                x = x0 + i * w + k
                if 0 <= x < W and not (behind and fg[x]):
                    row[x] = c


def to_image(idx, scale=1):
    from PIL import Image
    img = Image.fromarray(PAL[idx])
    if scale != 1:
        img = img.resize((W * scale, H * scale), Image.NEAREST)
    return img
