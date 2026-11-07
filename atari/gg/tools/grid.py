#!/usr/bin/env python3
"""Tile PNGs into one half-size contact sheet: grid.py OUT.png IN1.png IN2.png ..."""
import sys
from PIL import Image

ims = [Image.open(p).convert('RGB') for p in sys.argv[2:]]
w, h = ims[0].size
cols = 2 if len(ims) > 1 else 1
rows = (len(ims) + cols - 1) // cols
o = Image.new('RGB', (w * cols, h * rows))
for i, im in enumerate(ims):
    o.paste(im, ((i % cols) * w, (i // cols) * h))
o.resize((w * cols // 2, h * rows // 2)).save(sys.argv[1])
