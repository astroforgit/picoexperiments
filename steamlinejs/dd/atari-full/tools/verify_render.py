#!/usr/bin/env python3
"""Compare every composed Atari frame with a reference NES rendering.

The reference is computed from the NES-side state the compose used
(nametable shadows, palette, OAM, scroll latch, HUD split) with the PPU
rules of tools/nesmodel.py, and compared pixel by pixel (as NES colour
numbers) with the framebuffer the blitter produced.

verify_render.py FRAMES [--every N] [--save]
"""
import sys
import random
from pathlib import Path
import numpy as np
from atari_emu import Atari, load_labels

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'tools'))
import make_data  # noqa: E402

CHR = None


def chr_bank(b):
    global CHR
    if CHR is None:
        banks = make_data.chr_tiles()
        CHR = []
        for tiles in banks:
            arr = np.zeros((256, 8, 8), dtype=np.uint8)
            for t, rows in enumerate(tiles):
                for y, (p0, p1) in enumerate(rows):
                    for x in range(8):
                        arr[t, y, x] = ((p0 >> (7 - x)) & 1) | (((p1 >> (7 - x)) & 1) << 1)
            CHR.append(arr)
    return CHR[b]


def reference(st):
    """NES colour numbers (0-63) of the frame described by st."""
    nt = st['nt']                       # 2 x 1024
    physof = st['physof']               # logical 0..3 -> physical
    pal = st['pal']
    img = np.zeros((240, 256), dtype=np.int16)
    bg = chr_bank(st['bg_bank'])
    split = st['split']
    for y in range(240):
        if not st['mask'] & 8:
            img[y, :] = pal[0]
            continue
        if y < split:
            yy = st['sy'] + y
            base, x0 = st['ctrl'] & 3, st['sx']
            if yy >= 240:
                base ^= 2
                yy -= 240
        else:
            base, x0 = st['hud_nt'], 0
            yy = 200 + (y - split)
            if yy >= 240:
                base ^= 2
                yy -= 240
        for x in range(256):
            xx = x0 + x
            n = base ^ (1 if xx >= 256 else 0)
            X = xx & 255
            t = nt[physof[n]]
            tile = t[(yy >> 3) * 32 + (X >> 3)]
            attr = t[0x3C0 + (yy >> 5) * 8 + (X >> 5)]
            sh = ((yy >> 4) & 1) * 4 + ((X >> 4) & 1) * 2
            c = bg[tile, yy & 7, X & 7]
            img[y, x] = pal[((attr >> sh) & 3) * 4 + c] if c else pal[0]
    if st['mask'] & 0x10:
        spr = chr_bank(st['obj_bank'])
        o = st['oam']
        for i in range(63, -1, -1):
            y, t, a, x = o[i * 4:i * 4 + 4]
            if y >= 0xEF or a & 0x20:
                continue
            tile = spr[t]
            if a & 0x40:
                tile = tile[:, ::-1]
            if a & 0x80:
                tile = tile[::-1, :]
            for dy in range(8):
                for dx in range(8):
                    c = tile[dy, dx]
                    if c and x + dx < 256 and y + 1 + dy < 240:
                        img[y + 1 + dy, x + dx] = pal[0x10 + (a & 3) * 4 + c]
    return img


def atari_frame(a, back, palsnap):
    fb = 0x40000 if back == 0 else 0x50000
    pix = a.vram[fb:fb + 256 * 240].reshape(240, 256).astype(np.int16)
    out = np.full((240, 256), -1, dtype=np.int16)
    for v in range(256):
        m = pix == v
        if not m.any():
            continue
        if v == 0x20:
            out[m] = palsnap[0]
        elif 0x21 <= v <= 0x2F and v & 3:
            out[m] = palsnap[v - 0x20]
        elif 0x11 <= v <= 0x1F and v & 3:
            out[m] = palsnap[v]
    return out


def main():
    frames = int(sys.argv[1]) if len(sys.argv) > 1 else 1500
    every = int(sys.argv[sys.argv.index('--every') + 1]) if '--every' in sys.argv else 25
    a = Atari(ROOT / 'double-dragon.xex', pal='--ntsc' not in sys.argv)
    a.boot()
    lab = load_labels(ROOT / 'gen/runtime.lab')
    r = a.mem.ram
    rnd = random.Random(1)
    st_in = {'h': 0, 'in': {}}

    modeb = '--modeb' in sys.argv

    def inputs(f):
        if modeb and f < 700:
            if f in range(380, 386) or f in range(600, 606):
                return dict(consol=6)
            if f in range(440, 446) or f in range(470, 476):
                return dict(consol=5)
            return {}
        if f < 700:
            return dict(consol=6 if f in range(380, 386) or f in range(560, 566) else 7)
        if st_in['h'] <= 0:
            st_in['in'] = dict(stick=rnd.choice([7, 7, 7, 6, 5, 11, 15]), trig=rnd.choice([0, 1]),
                               shift=rnd.choice([False, True]))
            st_in['h'] = rnd.randint(2, 15)
        st_in['h'] -= 1
        d = dict(st_in['in'])
        if f % 2:
            d['trig'] = 0
            d['shift'] = False
        return d

    cobs = lab['CO_BS'] + 3
    cpu = a.cpu
    checked = bad = 0
    while a.frame < frames:
        a.set_input(**inputs(a.frame))
        while cpu.processorCycles < a.next_frame:
            pc = cpu.pc
            cpu.step()
            if pc == lab['CO_BS'] and a.frame % every == 0 and r[lab['ANY_DIRTY']] == 0:
                back = r[lab['BACK']]
                s = {
                    'nt': [bytes(r[0x2800:0x2C00]), bytes(r[0x2C00:0x3000])],
                    'physof': [r[lab['NT_PHYSOF'] + 0x20 + n * 4] for n in range(4)],
                    'pal': [v & 0x3F for v in r[0x0D80:0x0DA0]],
                    'mask': r[lab['C_MASK']], 'sx': r[lab['C_X']], 'sy': r[lab['C_Y']],
                    'ctrl': r[lab['C_CTRL']], 'hud_nt': r[lab['C_HUDNT']],
                    'split': r[lab['EB_S']], 'bg_bank': r[lab['BG_BANK']],
                    'obj_bank': r[lab['OBJ_BANK']], 'oam': bytes(r[0x200:0x300]),
                }
                if s['bg_bank'] > 31 or s['obj_bank'] > 31:
                    continue
                # the palette shown with this frame is PALSH now (snapshot at compose)
                ref = reference(s)
                got = atari_frame(a, back, s['pal'])
                diff = ref != got
                checked += 1
                if diff.any():
                    bad += 1
                    ys, xs = np.nonzero(diff)
                    print(f'frame {a.frame}: {diff.sum()} pixels differ, first at ({xs[0]},{ys[0]}) '
                          f'ref {ref[ys[0], xs[0]]} got {got[ys[0], xs[0]]}', flush=True)
                    if '--save' in sys.argv:
                        from PIL import Image
                        Image.fromarray((diff * 255).astype(np.uint8)).save(ROOT / f'gen/diff-{a.frame}.png')
        a.next_frame += a.frame_cycles
        a.vblank()
    print(f'checked {checked} frames, {bad} with differences')
    sys.exit(1 if bad else 0)


if __name__ == '__main__':
    main()
