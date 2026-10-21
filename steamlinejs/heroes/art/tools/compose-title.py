#!/usr/bin/env python3
"""Compose the title-screen picture: generated key art plus the gold logo.

Input:  art/title-v1/title-key-art.png (1280x800, generated, see generation.json)
Output: art/title-v1/title.png (320x200 RGB, quantized later by build-assets.js)

The logo is drawn at 4x on the key art and the result is box-reduced, so the
lettering is shaded and anti-aliased like the painting around it. It is set in
URW Bookman with drop capitals, a polished gold ramp, a bevel highlight, a
double bronze/dark outline, a flourish divider and two small glints.
"""
from pathlib import Path
from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parents[1] / 'title-v1'
FONTS = Path('/usr/share/fonts/opentype/urw-base35')
SCALE = 4

# Polished gold: pale top, a sharp darker band at the middle, a reflected
# light line just below it and deep bronze at the foot.
GOLD = [(0.00, (255, 251, 222)), (0.36, (255, 216, 96)), (0.50, (205, 128, 26)),
        (0.53, (252, 206, 98)), (0.75, (226, 150, 44)), (1.00, (128, 58, 14))]
CREAM = [(0.00, (255, 252, 236)), (0.55, (246, 230, 196)), (1.00, (196, 160, 112))]


def font(name, size):
    return ImageFont.truetype(str(FONTS / name), size * SCALE)


def ramp(stops, size, top, bottom):
    """A vertical colour ramp spanning the glyph box from top to bottom."""
    w, h = size
    column = Image.new('RGB', (1, h))
    for j in range(h):
        t = min(1, max(0, (j - top) / max(1, bottom - top)))
        for (a, ca), (b, cb) in zip(stops, stops[1:]):
            if a <= t <= b:
                k = (t - a) / (b - a) if b > a else 0
                column.putpixel((0, j), tuple(int(ca[i] + (cb[i] - ca[i]) * k) for i in range(3)))
                break
    return column.resize((w, h))


def layout(parts):
    """Place (text, font, baseline_shift) runs side by side on one baseline."""
    probe = ImageDraw.Draw(Image.new('L', (1, 1)))
    x, runs = 0, []
    for text, face, gap in parts:
        box = probe.textbbox((0, 0), text, font=face, anchor='ls')
        runs.append((x - box[0], text, face))
        x += box[2] - box[0] + gap
    return runs, x


def lettering(art, runs, origin, stops, outline):
    """Paint one word group: shadow, bronze rim, dark outline, face, bevel."""
    ox, baseline = origin
    pad = 24 * SCALE
    w = max(x for x, _, _ in runs) + 80 * SCALE
    size = (w + 2 * pad, 64 * SCALE)
    by = 44 * SCALE                       # baseline inside the work canvas
    mask, rim, dark = (Image.new('L', size) for _ in range(3))
    for x, text, face in runs:
        p = (pad + x, by)
        ImageDraw.Draw(mask).text(p, text, font=face, fill=255, anchor='ls')
        ImageDraw.Draw(rim).text(p, text, font=face, fill=255, anchor='ls',
                                 stroke_width=outline + 3 * SCALE // 2, stroke_fill=255)
        ImageDraw.Draw(dark).text(p, text, font=face, fill=255, anchor='ls',
                                  stroke_width=outline, stroke_fill=255)
    box = mask.getbbox()
    face_fill = ramp(stops, size, box[1], box[3])
    # Bevel: the top edge of every stroke catches the light.
    lower = ImageChops.offset(mask, 0, 2 * SCALE)
    bevel = ImageChops.subtract(mask, lower).filter(ImageFilter.GaussianBlur(SCALE // 2))
    shadow = rim.filter(ImageFilter.GaussianBlur(3 * SCALE)).point(lambda v: int(v * 0.85))
    at = (ox - pad, baseline - by)
    art.paste((8, 4, 18), (at[0] + 3 * SCALE, at[1] + 4 * SCALE), shadow)
    art.paste((214, 152, 60), at, rim)
    art.paste((38, 16, 8), at, dark)
    art.paste(face_fill, at, mask)
    art.paste((255, 255, 240), at, bevel.point(lambda v: int(v * 0.8)))
    return box[0] - pad + at[0], box[2] - pad + at[0]


def divider(art, left, right, y):
    """Thin gold rule with tapering ends and a central ornament."""
    draw = ImageDraw.Draw(art)
    mid = (left + right) // 2
    for side in (-1, 1):
        for i in range(0, (right - left) // 2 - 10 * SCALE, SCALE):
            x = mid + side * (10 * SCALE + i)
            fade = 1 - i / ((right - left) / 2)
            c = tuple(int(v * fade + d * (1 - fade)) for v, d in zip((246, 196, 84), (90, 50, 20)))
            draw.rectangle([x, y, x + SCALE - 1, y + SCALE - 1], fill=c)
    orn = ImageFont.truetype(str(FONTS / 'D050000L.otf'), 12 * SCALE)
    for colour, offset in (((38, 16, 8), SCALE), ((246, 200, 90), 0)):
        draw.text((mid + offset, y + SCALE // 2 + offset), '❖', font=orn, fill=colour, anchor='mm')


def glint(art, centre, radius):
    """Small four-point star of light."""
    glow = Image.new('L', art.size)
    d = ImageDraw.Draw(glow)
    x, y = centre
    d.polygon([(x - radius, y), (x, y - SCALE), (x + radius, y), (x, y + SCALE)], fill=255)
    d.polygon([(x, y - radius), (x - SCALE, y), (x, y + radius), (x + SCALE, y)], fill=255)
    art.paste((255, 255, 236), (0, 0), glow.filter(ImageFilter.GaussianBlur(SCALE // 2)))


def main():
    art = Image.open(ROOT / 'title-key-art.png').convert('RGB')
    assert art.size == (320 * SCALE, 200 * SCALE)
    cap, small = font('URWBookman-Demi.otf', 35), font('URWBookman-Demi.otf', 25)
    script = font('Z003-MediumItalic.otf', 18)
    words = [('P', cap, 0), ('RINCE', small, 5 * SCALE), ('and the', script, 5 * SCALE),
             ('N', cap, 0), ('YMPH', small, 0)]
    runs, total = layout(words)
    x0, baseline = (art.width - total) // 2, 38 * SCALE
    big = [r for r in runs if r[2] is not script]
    left, right = lettering(art, big, (x0, baseline), GOLD, 5 * SCALE // 2)
    lettering(art, [r for r in runs if r[2] is script], (x0, baseline - 3 * SCALE), CREAM, 2 * SCALE)
    divider(art, left + 6 * SCALE, right - 6 * SCALE, baseline + 6 * SCALE)
    glint(art, (left + 6 * SCALE, baseline - 30 * SCALE), 7 * SCALE)
    glint(art, (right - 4 * SCALE, baseline - 22 * SCALE), 5 * SCALE)
    art.save(ROOT / 'title-4x.png')
    art.resize((320, 200), Image.BOX).save(ROOT / 'title.png')


if __name__ == '__main__':
    main()
