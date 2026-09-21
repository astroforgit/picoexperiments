"""Grapple heroine as pixel art: supersampled blockout -> downsample ->
palette quantize -> outline. Internal outlines separate the limbs."""
from PIL import Image, ImageDraw
import math

S = 6
W, H = 84, 170
OUTDIR = "/tmp/claude-1000/-home-marcin-tmp-pico/cbd8ee78-9856-49ef-8b75-5d5a923e1ae0/scratchpad/title/"

HAIR   = (255, 46, 40);  HAIR_D = (168, 16, 24);  HAIR_L = (255, 126, 84)
SKIN   = (247, 202, 170); SKIN_D = (206, 140, 110)
SUIT   = (206, 22, 34);  SUIT_D = (122, 10, 26);  SUIT_L = (255, 96, 86)
BOOT   = (34, 26, 36);   BOOT_L = (96, 78, 98)
METAL  = (188, 198, 210); METAL_D = (104, 116, 132)
OUT    = (14, 10, 16)

img = Image.new("RGBA", (W * S, H * S), (0, 0, 0, 0))
d = ImageDraw.Draw(img)

def P(*pts): return [(x * S, y * S) for x, y in pts]
def poly(pts, fill): d.polygon(P(*pts), fill=fill)
def ell(x0, y0, x1, y1, fill): d.ellipse(P((x0, y0), (x1, y1)), fill=fill)

def capsule(a, b, ra, rb, fill):
    ax, ay = a; bx, by = b
    dx, dy = bx - ax, by - ay
    L = math.hypot(dx, dy) or 1
    nx, ny = -dy / L, dx / L
    poly([(ax + nx*ra, ay + ny*ra), (bx + nx*rb, by + ny*rb),
          (bx - nx*rb, by - ny*rb), (ax - nx*ra, ay - ny*ra)], fill)
    ell(ax-ra, ay-ra, ax+ra, ay+ra, fill)
    ell(bx-rb, by-rb, bx+rb, by+rb, fill)

def limb(a, b, ra, rb, fill, ink=True):
    """Capsule with a dark keyline so limbs read against the body."""
    if ink: capsule(a, b, ra + 1.1, rb + 1.1, OUT)
    capsule(a, b, ra, rb, fill)

# ---------------- hair: back mass, kept clear of the arms -------------
poly([(38,18),(49,23),(51,38),(47,50),(40,60),(28,68),(19,62),(18,47),
      (21,31),(28,20)], HAIR_D)
poly([(37,19),(47,24),(48,37),(44,48),(37,57),(27,64),(21,58),(21,46),
      (24,32),(30,21)], HAIR)
# strand falling in front of her right shoulder
poly([(24,44),(30,52),(29,68),(24,76),(19,72),(21,58)], HAIR_D)
poly([(24,45),(28,53),(27,66),(23,73),(20,69),(22,57)], HAIR)

# ---------------- legs -------------------------------------------------
limb((32, 90), (29, 124), 7.5, 5.0, SUIT)
limb((44, 90), (47, 122), 7.5, 5.0, SUIT)
limb((29, 120), (27, 148), 5.6, 4.4, BOOT)
limb((47, 118), (50, 148), 5.6, 4.4, BOOT)
poly([(21,146),(33,146),(34,166),(19,166)], BOOT)
poly([(44,146),(56,146),(59,166),(42,166)], BOOT)
poly([(19,161),(35,161),(35,167),(17,167)], BOOT_L)
poly([(42,161),(60,161),(60,167),(42,167)], BOOT_L)
poly([(19,166),(35,166),(35,168),(17,168)], OUT)
poly([(42,166),(60,166),(60,168),(42,168)], OUT)

# ---------------- torso: fitted suit ----------------------------------
poly([(26,47),(51,47),(49,62),(45,76),(46,86),(51,94),(38,98),(25,94),
      (30,86),(31,76),(27,62)], OUT)
poly([(27,48),(50,48),(48,62),(44,76),(45,86),(50,93),(38,97),(26,93),
      (31,86),(32,76),(28,62)], SUIT)
poly([(38,48),(50,48),(48,62),(44,76),(45,86),(50,93),(38,97)], SUIT_D)
poly([(33,50),(41,50),(39,66),(35,66)], SUIT_L)
ell(29, 86, 48, 101, SUIT)
poly([(28,90),(49,90),(50,96),(27,96)], BOOT)          # belt
ell(44, 91, 53, 99, METAL_D)                            # rope coil at hip
ell(46, 93, 51, 98, (0, 0, 0, 0))

# ---------------- arms -------------------------------------------------
limb((27, 51), (14, 72), 4.6, 3.5, SUIT)                # her right: on hip
limb((14, 72), (25, 87), 3.5, 3.0, SKIN)
ell(21, 83, 30, 92, OUT); ell(22, 84, 29, 91, BOOT)     # glove
limb((49, 51), (60, 40), 4.6, 3.5, SUIT)                # her left: raised
limb((60, 40), (66, 25), 3.5, 3.0, SKIN)
ell(61, 20, 71, 30, OUT); ell(62, 21, 70, 29, BOOT)     # gripping glove

# ---------------- neck + head -----------------------------------------
capsule((38, 38), (38, 48), 3.6, 4.6, SKIN_D)
ell(29, 21, 48, 44, OUT)
ell(30, 22, 47, 43, SKIN)
poly([(30,30),(47,30),(46,24),(38,20),(31,24)], SKIN)
ell(42, 25, 48, 41, SKIN_D)                             # cheek shade
poly([(27,31),(30,21),(38,18),(47,21),(50,30),(45,24),(38,27),(32,25)], HAIR)
poly([(27,31),(30,21),(35,19),(33,27),(30,32)], HAIR_L)
d.rectangle(P((33, 31), (35, 34)), fill=OUT)            # eyes
d.rectangle(P((41, 31), (43, 34)), fill=OUT)
d.rectangle(P((33, 30), (36, 31)), fill=HAIR_D)         # brows
d.rectangle(P((41, 30), (44, 31)), fill=HAIR_D)
d.rectangle(P((36, 38), (40, 39)), fill=SUIT)           # lips

# ---------------- grappling hook + rope --------------------------------
capsule((66, 28), (66, 12), 2.4, 2.4, METAL)
capsule((66, 16), (58, 8), 2.0, 1.5, METAL_D)
capsule((66, 16), (74, 8), 2.0, 1.5, METAL)
capsule((66, 14), (66, 4), 1.8, 1.5, METAL_D)
d.line(P((66, 30), (61, 52), (52, 74), (50, 94)), fill=METAL_D, width=2 * S)

# ---------------- resolve to pixels ------------------------------------
small = img.resize((W, H), Image.LANCZOS)
px = small.load()
PAL = [HAIR, HAIR_D, HAIR_L, SKIN, SKIN_D, SUIT, SUIT_D, SUIT_L,
       BOOT, BOOT_L, METAL, METAL_D, OUT]
for y in range(H):
    for x in range(W):
        r, g, b, a = px[x, y]
        if a < 110:
            px[x, y] = (0, 0, 0, 0); continue
        px[x, y] = min(PAL, key=lambda c: (c[0]-r)**2+(c[1]-g)**2+(c[2]-b)**2) + (255,)

out = small.copy(); op = out.load()
for y in range(H):
    for x in range(W):
        if px[x, y][3]: continue
        if any(0 <= x+dx < W and 0 <= y+dy < H and px[x+dx, y+dy][3]
               for dx, dy in ((1,0),(-1,0),(0,1),(0,-1))):
            op[x, y] = OUT + (255,)
out.save(OUTDIR + "hero.png")
out.resize((W*5, H*5), Image.NEAREST).save(OUTDIR + "hero_big.png")
print("hero ok", out.size)
