#!/usr/bin/env python3
"""verify_render.py SNAP [OUT.png]: the framebuffer on screen vs tools/vic.py.

The reference is rendered from the Atari's own copy of the C64 memory and
the newest IRQ log (bank R), so it matches the shown picture when the
screen did not change in the last frame or two. Prints the differing
pixel count and writes reference | Atari | difference.
"""
import os
import sys
import numpy as np
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from atari_emu import load_labels  # noqa: E402
from atari_snap import load_snap  # noqa: E402
import vic  # noqa: E402

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BANK_R = 0x7C000
LOGSZ = 49


def c64_of_atari(a):
    """C64 colour of each framebuffer pixel (palette index -> C64 colour)."""
    lab = load_labels(os.path.join(HERE, 'gen', 'runtime.lab'))
    shown = a.mem.ram[lab['SHOWN']]
    fb = a.vram[shown * 0x10000:shown * 0x10000 + 64000].reshape(200, 320).astype(np.int64)
    # palette per row from the XDL is approximated by matching RGB to C64 colours
    pal = vic.PAL.astype(np.int64)
    out = np.zeros((200, 320), np.int64)
    rgb = np.array(a.screenshot(scale=1))[20:220]
    d = ((rgb[:, :, None, :].astype(np.int64) - pal[None, None]) ** 2).sum(-1)
    out = d.argmin(-1)
    return out, fb


def reference(a, ram):
    ents = []                           # (the entries of the last logged frame)
    for i in range(4):
        b = load_labels(os.path.join(HERE, 'gen', 'runtime.lab'))['LOG'] + i * LOGSZ
        e = ram[b:b + LOGSZ]
        line = e[0] | e[1] << 8
        if i and line <= ents[-1][0]:
            break
        ents.append((line, e[2:2 + 0x2F]))
    regs0 = bytes(ents[0][1]) + bytes(64 - 0x2F)
    log = []
    for line, r in ents[1:]:
        for k in range(0x2F):
            log.append((line + 1, 0, k, r[k]))
    ptrs = {0x43F8 + i: ram[0x43F8 + i] for i in range(8)}

    class C:
        pass
    c = C()
    c.mem = C()
    c.mem.ram = bytearray(ram)
    img = vic.render(c, frame=(regs0, 2, log, ptrs), ram=ram, colram=bytes(x & 15 for x in ram[0xD800:0xDC00]))
    return img[35:235, 32:352]


def to_next_picture(a):
    """Run to the start of a picture's render (C64 memory and log as it
    sees them), then until that picture is on screen. Returns the memory."""
    lab = load_labels(os.path.join(HERE, 'gen', 'runtime.lab'))
    cpu = a.cpu
    mem = None
    seen_ready = False
    for _ in range(8_000_000):
        if mem is None and cpu.pc == lab['RENDER'] and a.mems == 0xFC:
            mem = bytes(a.mem.ram)
        a.run_until(cpu.processorCycles + 1)
        if cpu.processorCycles >= a.next_frame:
            a.next_frame += a.frame_cycles
            a.vblank()
        if mem is None:
            continue
        r = a.mem.ram[lab['READY']]
        if r != 0xFF:
            seen_ready = True
        elif seen_ready:
            return mem
    raise RuntimeError('no picture')


def main():
    a = load_snap(sys.argv[1])
    mem = to_next_picture(a)
    ref = reference(a, mem)
    got, _ = c64_of_atari(a)
    diff = ref != got
    print(f'differing pixels: {int(diff.sum())}')
    if len(sys.argv) > 2:
        from PIL import Image
        w = np.concatenate([vic.PAL[ref], vic.PAL[got], np.where(diff[:, :, None], 255, 0).astype(np.uint8).repeat(3, 2)], 1)
        Image.fromarray(w.astype(np.uint8)).resize((960 * 2, 400), Image.NEAREST).save(sys.argv[2])


if __name__ == '__main__':
    main()
