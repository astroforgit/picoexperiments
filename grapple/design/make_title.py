#!/usr/bin/env python3
"""Turn a piece of source art into the Grapple title screen.

Takes any image -- a FLUX generation, a painting, a photo of a napkin -- and
produces both a preview PNG and the binaries the VBXE build needs:

    python3 make_title.py art.png                 # cutout or full frame
    python3 make_title.py art.png --fit cover     # fill the frame, crop
    python3 make_title.py art.png --no-text       # art already has the logo

Source art with an alpha channel is treated as a cutout: it is scaled to the
figure height and composited over a generated cave background. Opaque art is
fitted to the whole frame instead.

The palette is capped at 63 colours because load_palette in grapple-vbxe.asm
indexes four-byte records with X, so 256/4 records is the hard ceiling (see
the depth-palette check in generate_assets.js). Raising that needs a 16-bit
index in the loader.
"""
import argparse
import math
import os
import random
import sys

from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
GAME = os.path.dirname(HERE)
W, H = 320, 200
PALETTE_LIMIT = 63          # load_palette's 8-bit record index

# Colours reserved for the type, kept out of quantization so the text stays
# crisp instead of being smeared across nearby palette entries.
INK_WHITE = (255, 236, 226)
INK_RED = (255, 62, 48)
INK_SHADOW = (60, 6, 10)
INK_DIM = (176, 156, 156)
INK_BLUE = (112, 132, 154)
INK_GREY = (122, 106, 112)
RESERVED = [INK_WHITE, INK_RED, INK_SHADOW, INK_DIM, INK_BLUE, INK_GREY]

FONT_ROWS = ['ABCDEFGHIJ', 'KLMNOPQRST', 'UVWXYZabcd', 'efghijklmn',
             'opqrstuvwx', 'yz01234567', '89!@#$%^&*', '()-_=+{}[]',
             '\\|;:\'",.<>', '/?`~']
CHAR = {c: (x, y) for y, row in enumerate(FONT_ROWS) for x, c in enumerate(row)}


def load_font():
    return Image.open(os.path.join(GAME, "bin", "assets", "deluxe16.png")).convert("RGBA")


def draw_text(dst, font, s, ox, oy, scale=1, color=INK_WHITE, shadow=None, track=0):
    if shadow:
        draw_text(dst, font, s, ox + scale, oy + scale, scale, shadow, None, track)
    cx = ox
    for ch in s:
        if ch == ' ':
            cx += (8 + track) * scale
            continue
        if ch not in CHAR:
            continue
        gx, gy = CHAR[ch]
        glyph = font.crop((gx * 8, gy * 15, gx * 8 + 8, gy * 15 + 15))
        if scale != 1:
            glyph = glyph.resize((8 * scale, 15 * scale), Image.NEAREST)
        dst.paste(Image.new("RGBA", glyph.size, color + (255,)), (cx, oy), glyph)
        cx += (8 + track) * scale
    return cx


def cave_background(seed=48):
    """The abyss: vertical gradient, blocky rock in the port's depth colours."""
    random.seed(seed)
    img = Image.new("RGBA", (W, H), (0, 0, 0, 255))
    d = ImageDraw.Draw(img)
    for y in range(H):
        t = y / (H - 1)
        glow = max(0.0, (t - 0.55) / 0.45) ** 2
        d.line([(0, y), (W, y)], fill=(int(9 + 10 * t + 96 * glow),
                                       int(9 + 8 * t + 26 * glow),
                                       int(18 + 16 * t + 14 * glow), 255))
    rock = [(58, 40, 30), (46, 32, 26), (38, 44, 66), (48, 48, 56), (34, 54, 38)]

    def column(x, top, bottom, shift):
        for cy in range(top, bottom, 8):
            band = rock[((cy // 8) + shift) % len(rock)]
            k = 0.45 + 0.55 * (cy / H)
            c = tuple(int(v * k) for v in band)
            d.rectangle([x, cy, x + 7, cy + 7], fill=c + (255,))
            d.line([(x, cy), (x + 7, cy)], fill=tuple(min(255, int(v * 1.5)) for v in c) + (255,))

    for i, x in enumerate(range(0, 56, 8)):
        depth = 200 - int(abs(math.sin(i * 1.1 + 0.6)) * 70) - i * 6
        column(x, 0, max(24, H - depth), i)
        column(x, H - 26 - int(abs(math.cos(i * 0.9)) * 22), H, i + 2)
    for i, x in enumerate(range(288, 320, 8)):
        column(x, 0, 30 + int(abs(math.sin(i * 1.4)) * 26), i + 1)
    for i, x in enumerate(range(176, 320, 8)):
        column(x, 186 + (2 if i % 3 else 0), H, i)
    d.line([(176, 186), (320, 186)], fill=(150, 72, 40, 255))
    for _ in range(70):
        d.point((random.randrange(W), random.randrange(H)),
                fill=random.choice([(90, 70, 70), (130, 90, 70), (70, 70, 90)]) + (255,))
    return img


def fit_frame(src, mode):
    """Scale source art to cover or fit inside 320x200."""
    sw, sh = src.size
    scale = max(W / sw, H / sh) if mode == "cover" else min(W / sw, H / sh)
    new = src.resize((max(1, round(sw * scale)), max(1, round(sh * scale))), Image.LANCZOS)
    out = Image.new("RGBA", (W, H), (0, 0, 0, 255))
    out.paste(new, ((W - new.width) // 2, (H - new.height) // 2))
    return out


def place_cutout(src, bg, height, anchor_x, feet_y):
    """Scale a transparent-background figure and stand it on the ledge."""
    src = src.crop(src.getbbox() or (0, 0, src.width, src.height))
    scale = height / src.height
    fig = src.resize((max(1, round(src.width * scale)), height), Image.LANCZOS)
    out = bg.copy()
    out.alpha_composite(fig, (anchor_x - fig.width // 2, feet_y - height))
    return out


def shade_panel(img, right=206, fade=56, alpha=190):
    panel = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    pd = ImageDraw.Draw(panel)
    for x in range(right):
        a = alpha if x < right - fade else int(alpha * (1 - (x - (right - fade)) / float(fade)))
        pd.line([(x, 0), (x, H)], fill=(6, 6, 12, a))
    img.alpha_composite(panel)
    return img


def type_layer(items=("normal mode", "hard mode", "controls", "options")):
    """The title and menu, on transparency, using only reserved colours."""
    font = load_font()
    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    draw_text(layer, font, "GRAPPLE", 14, 18, 3, INK_RED, shadow=INK_SHADOW, track=-1)
    draw_text(layer, font, "GRAPPLE", 14, 16, 3, INK_WHITE, track=-1)
    d.rectangle([14, 62, 14 + 7 * 23 - 6, 64], fill=INK_RED + (255,))
    draw_text(layer, font, "THE ABYSS!", 18, 70, 2, INK_WHITE, shadow=INK_SHADOW)
    for i, label in enumerate(items):
        y = 104 + i * 16
        draw_text(layer, font, label, 30, y, 1, INK_WHITE if i == 0 else INK_DIM)
        if i == 0:
            d.polygon([(18, y + 3), (18, y + 12), (25, y + 7)], fill=INK_RED + (255,))
    draw_text(layer, font, "atari xl/xe + vbxe", 14, 168, 1, INK_BLUE)
    draw_text(layer, font, "a game by hayden mccraw", 14, 182, 1, INK_GREY)
    return layer


def quantize(art, layer, colors, dither):
    """Quantize the art, then stamp the type in with exact reserved indices."""
    art_colors = max(2, colors - len(RESERVED))
    d = Image.Dither.FLOYDSTEINBERG if dither else Image.Dither.NONE
    q = art.convert("RGB").quantize(colors=art_colors, method=Image.MEDIANCUT, dither=d)

    pal = q.getpalette()[: art_colors * 3]
    table = [tuple(pal[i * 3:i * 3 + 3]) for i in range(art_colors)]
    reserved_index = {}
    for rgb in RESERVED:
        reserved_index[rgb] = len(table)
        table.append(rgb)

    qp = q.load()
    lp = layer.load()
    for y in range(H):
        for x in range(W):
            r, g, b, a = lp[x, y]
            if a > 127:
                qp[x, y] = reserved_index.get((r, g, b), reserved_index[INK_WHITE])
    flat = []
    for rgb in table:
        flat.extend(rgb)
    flat.extend([0] * (768 - len(flat)))
    q.putpalette(flat)
    return q, table


def rle(data):
    """Byte run-length encoding: (count, value) pairs, count 1..255."""
    out = bytearray()
    i = 0
    while i < len(data):
        v = data[i]
        n = 1
        while i + n < len(data) and data[i + n] == v and n < 255:
            n += 1
        out.append(n)
        out.append(v)
        i += n
    return bytes(out)


def main():
    ap = argparse.ArgumentParser(description="Build the Grapple title screen from source art.")
    ap.add_argument("art", nargs="?", help="source image; omit to render background + type only")
    ap.add_argument("--fit", choices=["cutout", "cover", "contain"], default="auto",
                    help="cutout composites a transparent figure over the cave (default for "
                         "art with alpha); cover/contain fit the whole frame")
    ap.add_argument("--colors", type=int, default=PALETTE_LIMIT)
    ap.add_argument("--no-dither", action="store_true")
    ap.add_argument("--no-text", action="store_true", help="art already carries the logo")
    ap.add_argument("--no-panel", action="store_true", help="skip the shadow behind the menu")
    ap.add_argument("--figure-height", type=int, default=170)
    ap.add_argument("--figure-x", type=int, default=254)
    ap.add_argument("--feet-y", type=int, default=198)
    ap.add_argument("--out", default=os.path.join(HERE, "title-screen"))
    ap.add_argument("--bin-dir", default=os.path.join(GAME, "atari"))
    args = ap.parse_args()

    if args.colors > PALETTE_LIMIT:
        print(f"warning: {args.colors} colours exceeds load_palette's {PALETTE_LIMIT}-record "
              f"ceiling; the loader needs a 16-bit index for more", file=sys.stderr)

    bg = cave_background()
    if args.art:
        src = Image.open(args.art).convert("RGBA")
        has_alpha = src.getextrema()[3][0] < 250
        mode = args.fit
        if mode == "auto":
            mode = "cutout" if has_alpha else "cover"
        if mode == "cutout":
            art = place_cutout(src, bg, args.figure_height, args.figure_x, args.feet_y)
        else:
            art = fit_frame(src, mode)
        print(f"source {src.size} -> {mode}")
    else:
        art = bg

    if not args.no_panel:
        art = shade_panel(art)
    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0)) if args.no_text else type_layer()

    indexed, table = quantize(art, layer, args.colors, not args.no_dither)

    preview = indexed.convert("RGB")
    preview.save(args.out + ".png")
    preview.resize((W * 3, H * 3), Image.NEAREST).save(args.out + "-3x.png")

    raw = indexed.tobytes()
    assert len(raw) == W * H, len(raw)
    os.makedirs(args.bin_dir, exist_ok=True)
    with open(os.path.join(args.bin_dir, "title-screen.bin"), "wb") as f:
        f.write(raw)
    packed = rle(raw)
    with open(os.path.join(args.bin_dir, "title-screen-rle.bin"), "wb") as f:
        f.write(packed)
    with open(os.path.join(args.bin_dir, "title-palette.asm"), "w") as f:
        f.write("; Generated by design/make_title.py -- title screen palette\n")
        for i, (r, g, b) in enumerate(table):
            f.write(f"        dta {i},{r},{g},{b}\n")

    print(f"palette   {len(table)} colours (limit {PALETTE_LIMIT})")
    print(f"bitmap    {len(raw)} bytes raw")
    print(f"rle       {len(packed)} bytes ({100.0 * len(packed) / len(raw):.1f}% of raw)")
    print(f"preview   {args.out}.png and {args.out}-3x.png")


if __name__ == "__main__":
    main()
