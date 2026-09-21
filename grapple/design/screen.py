"""Compose the Grapple title screen at the Atari VBXE native 320x200."""
from PIL import Image, ImageDraw
import math, random

GAME = "/home/marcin/tmp/pico/grapple/"
OUTD = "/tmp/claude-1000/-home-marcin-tmp-pico/cbd8ee78-9856-49ef-8b75-5d5a923e1ae0/scratchpad/title/"
W, H = 320, 200
random.seed(48)   # ludum dare 48

# ---------------- the game's own font ---------------------------------
FONT_ROWS = ['ABCDEFGHIJ', 'KLMNOPQRST', 'UVWXYZabcd', 'efghijklmn',
             'opqrstuvwx', 'yz01234567', '89!@#$%^&*', '()-_=+{}[]',
             '\\|;:\'",.<>', '/?`~']
CHAR = {c: (x, y) for y, row in enumerate(FONT_ROWS) for x, c in enumerate(row)}
font = Image.open(GAME + "bin/assets/deluxe16.png").convert("RGBA")

def text(dst, s, ox, oy, scale=1, color=(255, 255, 255), shadow=None, track=0):
    if shadow:
        text(dst, s, ox + scale, oy + scale, scale, shadow, None, track)
    cx = ox
    for ch in s:
        if ch == ' ':
            cx += (8 + track) * scale; continue
        gx, gy = CHAR[ch]
        glyph = font.crop((gx * 8, gy * 15, gx * 8 + 8, gy * 15 + 15))
        if scale != 1:
            glyph = glyph.resize((8 * scale, 15 * scale), Image.NEAREST)
        tint = Image.new("RGBA", glyph.size, color + (255,))
        dst.paste(tint, (cx, oy), glyph)
        cx += (8 + track) * scale
    return cx

def width(s, scale=1, track=0):
    return len(s) * (8 + track) * scale

# ---------------- background: the abyss -------------------------------
img = Image.new("RGBA", (W, H), (0, 0, 0, 255))
d = ImageDraw.Draw(img)
for y in range(H):
    t = y / (H - 1)
    glow = max(0.0, (t - 0.55) / 0.45) ** 2          # lava light from below
    r = int(9 + 10 * t + 96 * glow)
    g = int(9 + 8 * t + 26 * glow)
    b = int(18 + 16 * t + 14 * glow)
    d.line([(0, y), (W, y)], fill=(r, g, b, 255))

ROCK = [(58, 40, 30), (46, 32, 26), (38, 44, 66), (48, 48, 56), (34, 54, 38)]
def rock_column(x, top, bottom, seedshift):
    """Blocky cave rock in 8px cells, shaded by depth like the port's terrain."""
    for cy in range(top, bottom, 8):
        band = ROCK[((cy // 8) + seedshift) % len(ROCK)]
        k = 0.45 + 0.55 * (cy / H)
        c = tuple(int(v * k) for v in band)
        d.rectangle([x, cy, x + 7, cy + 7], fill=c + (255,))
        d.line([(x, cy), (x + 7, cy)], fill=tuple(int(v * 1.5) for v in c) + (255,))

# left wall + right wall, jagged
for i, x in enumerate(range(0, 56, 8)):
    depth = 200 - int(abs(math.sin(i * 1.1 + 0.6)) * 70) - i * 6
    rock_column(x, 0, max(24, H - depth), i)
    rock_column(x, H - 26 - int(abs(math.cos(i * 0.9)) * 22), H, i + 2)
for i, x in enumerate(range(288, 320, 8)):
    rock_column(x, 0, 30 + int(abs(math.sin(i * 1.4)) * 26), i + 1)
# floor ledge she stands on
for i, x in enumerate(range(176, 320, 8)):
    top = 186 + (2 if i % 3 else 0)
    rock_column(x, top, H, i)
d.line([(176, 186), (320, 186)], fill=(150, 72, 40, 255))

# drifting dust motes lit by the glow
for _ in range(70):
    x, y = random.randrange(W), random.randrange(H)
    v = random.choice([(90, 70, 70), (130, 90, 70), (70, 70, 90)])
    d.point((x, y), fill=v + (255,))

# ---------------- rope arcing from off-screen to her hook -------------
rope = [(320, 2), (306, 12), (292, 22), (281, 33)]
for i in range(len(rope) - 1):
    d.line([rope[i], rope[i + 1]], fill=(96, 104, 120, 255), width=2)
    d.line([(rope[i][0], rope[i][1] - 1), (rope[i+1][0], rope[i+1][1] - 1)],
           fill=(140, 150, 166, 255), width=1)

# ---------------- heroine ---------------------------------------------
hero = Image.open(OUTD + "hero.png").convert("RGBA")
HX, HY = 212, 30
img.paste(hero, (HX, HY), hero)

# warm rim light from the abyss below, cool rim from above
hp = hero.load(); ip = img.load()
for y in range(hero.height):
    for x in range(hero.width):
        r, g, b, a = hp[x, y]
        if not a or (r, g, b) != (14, 10, 16):
            continue                      # rim only on the outer keyline
        def empty(dx, dy):
            nx, ny = x + dx, y + dy
            if not (0 <= nx < hero.width and 0 <= ny < hero.height):
                return True
            return not hp[nx, ny][3]
        px, py = HX + x, HY + y
        if not (0 <= px < W and 0 <= py < H):
            continue
        if empty(0, 1) and empty(-1, 0):
            ip[px, py] = (255, 146, 72, 255)      # lava glow from below left
        elif empty(0, -1) and empty(1, 0):
            ip[px, py] = (150, 170, 210, 255)     # cool light from above

# soften the rock behind the left-hand text column
panel = Image.new("RGBA", (W, H), (0, 0, 0, 0))
pd = ImageDraw.Draw(panel)
for x in range(206):
    a = 190 if x < 150 else int(190 * (1 - (x - 150) / 56.0))
    pd.line([(x, 0), (x, H)], fill=(6, 6, 12, a))
img.alpha_composite(panel)

# ---------------- title -----------------------------------------------
t1, t2 = "GRAPPLE", "THE ABYSS!"
x1 = 14
text(img, t1, x1, 18, 3, (255, 62, 48), shadow=(60, 6, 10), track=-1)
text(img, t1, x1, 16, 3, (255, 236, 226), track=-1)   # lit top layer
# red underglow bar
d.rectangle([x1, 62, x1 + width(t1, 3, -1) - 6, 64], fill=(198, 30, 34, 255))
text(img, t2, x1 + 4, 70, 2, (255, 210, 190), shadow=(70, 10, 14), track=0)

# ---------------- menu ------------------------------------------------
ITEMS = ["normal mode", "hard mode", "controls", "options"]
for i, label in enumerate(ITEMS):
    y = 104 + i * 16
    sel = (i == 0)
    text(img, label, 30, y, 1, (255, 236, 226) if sel else (176, 156, 156))
    if sel:
        d.polygon([(18, y + 3), (18, y + 12), (25, y + 7)], fill=(255, 62, 48, 255))

text(img, "atari xl/xe + vbxe", 14, 168, 1, (112, 132, 154))
text(img, "a game by hayden mccraw", 14, 182, 1, (122, 106, 112))

img.convert("RGB").save(OUTD + "title.png")
img.convert("RGB").resize((W * 3, H * 3), Image.NEAREST).save(OUTD + "title_big.png")
print("title ok")
