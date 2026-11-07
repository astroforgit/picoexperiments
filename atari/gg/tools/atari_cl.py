#!/usr/bin/env python3
"""Run N frames and save the char layer (V_CL) and both framebuffers as images:
atari_cl.py N OUTDIR"""
import os
import sys
import numpy as np
from PIL import Image
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from atari_emu import Atari  # noqa: E402

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
a = Atari(os.path.join(HERE, 'gng.xex'))
a.boot()
a.run_frames(int(sys.argv[1]))
out = sys.argv[2]
os.makedirs(out, exist_ok=True)
pal = a.palette[1].copy()
for name, base, w, h in (('cl', 0x24000, 320, 200), ('fb0', 0x00000, 368, 200), ('fb1', 0x12000, 368, 200)):
    px = a.vram[base:base + w * h].reshape(h, w)
    rgb = pal[px]
    rgb[px == 0] = 0
    # make "never written" visible: index stats
    Image.fromarray(rgb).resize((w * 2, h * 2), Image.NEAREST).save(os.path.join(out, name + '.png'))
    vals, cnt = np.unique(px, return_counts=True)
    print(name, dict(zip([hex(v) for v in vals[:20]], cnt[:20])))
