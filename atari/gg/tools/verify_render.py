#!/usr/bin/env python3
"""Compare the Atari framebuffer with a VIC-II rendering of the same state.

verify_render.py SNAP FRAMES [--every N] [--out DIR] [GNG_INPUT env]

When the main context replays an IRQ chain log (compose_main), the log's
records (raster line, VIC registers, $DD00, sprite pointers), the C64
memory as the VIC sees it (RAM, colour RAM, the VRAM image of the VIC bank
for $C000-$EFFF) and the list being built are captured. When the blitter
has drawn that list, its framebuffer is compared with tools/vic.py
rendering the same log. With --out, side-by-side images (Atari, VIC-II,
differences in red) are saved for frames with differences.
"""
import argparse
import os
import sys

import numpy as np
from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from atari_emu import load_labels  # noqa: E402
from atari_snap import load_snap, parse_inputs  # noqa: E402
import vic  # noqa: E402

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
lab = load_labels(os.path.join(HERE, 'gen', 'runtime.lab'))
V_LOG = 0x7E000


def capture(a):
    r = a.mem.ram
    ri = r[lab['LOG_BUSY']]           # the log being replayed
    n = r[lab['LOG_CNT'] + ri]
    recs = []
    for i in range(n):
        b = a.vram[V_LOG + ri * 2048 + i * 64:V_LOG + ri * 2048 + i * 64 + 58].tobytes()
        recs.append((b[0] | b[1] << 8, b[2:49], b[49], b[50:58]))
    mem = bytearray(r)
    mem[0xC000:0xF000] = a.vram[0x68000:0x6B000].tobytes()
    col = bytearray(x & 15 for x in r[0xD800:0xDC00])
    return recs, mem, col


def reference(recs, mem, col):
    def ptr_addrs(regs, dd):
        bank = (3 - (dd & 3)) * 0x4000
        scr = bank + ((regs[0x18] >> 4) & 15) * 0x400
        return [scr + 0x3F8 + i for i in range(8)]
    line0, regs0, dd0, p0 = recs[0]
    ptr0 = dict(zip(ptr_addrs(regs0, dd0), p0))
    log = []
    prev, pdd, pp = bytearray(regs0), dd0, dict(ptr0)
    for line, regs, dd, p in recs[1:]:
        for i in range(0x2F):
            if regs[i] != prev[i]:
                log.append((line, 0, i, regs[i]))
        if dd != pdd:
            log.append((line, 0, 0x40, dd))
        for ad, v in zip(ptr_addrs(regs, dd), p):
            if pp.get(ad) != v:
                log.append((line, 0, 0x10000 | ad, v))
                pp[ad] = v
        prev, pdd = bytearray(regs), dd

    class C:
        pass
    c = C()
    c.mem = C()
    c.mem.ram = mem
    c.colram = col
    return vic.render(c, frame=(bytes(regs0), dd0, log, ptr0))


def run(args):
    a = load_snap(args.snap)
    inp = parse_inputs(os.environ.get('GNG_INPUT', ''))
    cpu = a.cpu
    pend = {}
    results = []
    count = [0]
    if args.out:
        os.makedirs(args.out, exist_ok=True)
    orig = a.blit_list

    def blit():
        v = a.vregs
        start = v[0x50] | v[0x51] << 8 | (v[0x52] & 7) << 16
        acc = orig()
        lst = 1 if start >= 0x66800 else 0
        if lst in pend and 0x65000 <= start < 0x67A60:
            data = pend.pop(lst)
            count[0] += 1
            if count[0] % args.every == 0:
                compare(a, lst, data)
        return acc

    def compare(a, lst, data):
        ref = reference(*data)
        ref_rgb = vic.PAL[ref[35:235, 32:352]].astype(np.int16)
        base = 0x12000 if lst else 0
        fb = a.vram[base:base + 368 * 200].reshape(200, 368)[:, 24:344]
        # palette per line from the picture's XDL segments
        r = a.mem.ram
        n = r[lab['SEG_N'] + lst]
        pals = []
        for k in range(n):
            pals += [r[lab['SEG_PL'] + lst * 12 + k]] * r[lab['SEG_LN'] + lst * 12 + k]
        pals = (pals + [1] * 200)[:200]
        fb_rgb = np.zeros((200, 320, 3), dtype=np.int16)
        for y in range(200):
            fb_rgb[y] = a.palette[pals[y]][fb[y]]
        fb_rgb[fb == 0] = 0
        diff = np.abs(fb_rgb - ref_rgb).max(axis=2) > 8
        bad = int(diff.sum())
        results.append((a.frame, bad))
        rows = sorted({y // 8 for y in np.nonzero(diff)[0]})
        print(f'frame {a.frame}: {bad} pixels differ' + (f' (FB rows {rows[:12]})' if bad else ''), flush=True)
        if args.detail and bad:
            for line, regs, dd, p in data[0]:
                print(f'  log {line:3}: y {bytes(regs[1:16:2]).hex()} x {bytes(regs[0:16:2]).hex()} msb {regs[16]:02x} '
                      f'en {regs[0x15]:02x} col {bytes(regs[0x27:0x2F]).hex()} ptr {bytes(p).hex()}')
            lbase = 0x66800 if lst else 0x65000
            for i in range(168, 224):
                b = a.vram[lbase + i * 21:lbase + i * 21 + 21]
                src = b[0] | b[1] << 8 | (b[2] & 7) << 16
                dst = b[6] | b[7] << 8 | (b[8] & 7) << 16
                off = dst - base
                print(f'  blit ptr ${(src - 0x4C000) // 512:02x} fb x {off % 368 - 24} y {off // 368} '
                      f'w {b[12] + 1} h {b[14] + 1} and {b[15]:02x}')
                if not b[20] & 8:
                    break
        if args.out and bad:
            img = np.concatenate([fb_rgb, ref_rgb, np.where(diff[..., None], [255, 0, 0], ref_rgb // 3)], axis=1)
            Image.fromarray(img.astype(np.uint8)).resize((960 * 2, 400), Image.NEAREST).save(
                os.path.join(args.out, f'v{a.frame:05d}.png'))

    a.blit_list = blit
    cm_end = lab['CM_END']
    end = a.frame + args.frames
    while a.frame < end:
        a.set_input(**inp(a.frame))
        t_end = a.next_frame
        while cpu.processorCycles < t_end:
            if cpu.pc == cm_end and a.mems == 0xFB:
                pend[a.mem.ram[lab['BL']]] = capture(a)
            cpu.step()
        a.next_frame += a.frame_cycles
        a.vblank()
    bad = [b for _, b in results]
    print(f'{len(results)} pictures compared, {sum(1 for b in bad if b)} with differences, '
          f'max {max(bad) if bad else 0}')


if __name__ == '__main__':
    ap = argparse.ArgumentParser()
    ap.add_argument('snap')
    ap.add_argument('frames', type=int)
    ap.add_argument('--every', type=int, default=1)
    ap.add_argument('--out')
    ap.add_argument('--detail', action='store_true')
    run(ap.parse_args())
