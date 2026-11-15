"""Render the arcade video RAM the way the Amiga AGA port shows it.

fg tiles 4000-433F and bg tiles 4800-4B3F; tile offset o is shown at column
25 - (o >> 5), row o & 31. The background scrolls vertically: screen line s
shows background line (s + scroll) & 255. fg colour 0 is transparent.
"""
from pathlib import Path
import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
TILES = ROOT / "src" / "phoenix-main" / "assets" / "tiles" / "aga"


def load_sheets():
    sheets = {}
    for layer in ("back", "fore"):
        for pal in (0, 1):
            im = Image.open(TILES / f"sheet_{layer}_{pal}.png").convert("RGB")
            sheets[layer, pal] = np.array(im)
    return sheets


SHEETS = None


def tile(layer, pal, code):
    x = (code & 31) * 8
    y = (code >> 5) * 8
    return SHEETS[layer, pal][y:y + 8, x:x + 8]


def layer_image(ram, base, layer, pal):
    img = np.zeros((256, 208, 3), np.uint8)
    for o in range(0x340):
        code = ram[base + o]
        col = 25 - (o >> 5)
        row = o & 31
        img[row * 8:row * 8 + 8, col * 8:col * 8 + 8] = tile(layer, pal, code)
    return img


def render(ram, video, scroll):
    """ram: 4 KB bank contents (offset 0 = 0x4000)."""
    global SHEETS
    if SHEETS is None:
        SHEETS = load_sheets()
    pal = (video >> 1) & 1
    bg = layer_image(ram, 0x800, "back", pal)
    bg = np.roll(bg, -scroll, axis=0)
    fg = layer_image(ram, 0x000, "fore", pal)
    mask = fg.any(axis=2)
    out = bg.copy()
    out[mask] = fg[mask]
    return out


def save(img, path, scale=2):
    Image.fromarray(img).resize((img.shape[1] * scale, img.shape[0] * scale), Image.NEAREST).save(path)
