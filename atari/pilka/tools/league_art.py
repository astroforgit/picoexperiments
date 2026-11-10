"""Pack the menu artwork and the league's small computer badges for VBXE."""
from PIL import Image

ART_PAGES = (0x5d000, 0x5e000, 0x7a000, 0x7e000, 0x7f000, 0x72000)
ART_WIDTH, ART_HEIGHT = 64, 60
ART_PALETTE = 0xb0
BADGES = 0x7b400

# Seven-by-seven pixel interpretations in CLUBS order. The dark outline
# keeps the bright details readable against both the crowd and the grass.
CRESTS = [
    # Atari Fuji
    (".......", "..#.#..", "..###..", "..###..", ".##.##.", "##...##", "......."),
    # Commodore C=
    (".......", ".####..", "##.....", "##..RRR", "##.....", ".###BBB", "......."),
    # Amiga Boing Ball
    ("..###..", ".#R#R#.", "#R#R#R#", "R#R#R#R", "#R#R#R#", ".R#R#R.", "..###.."),
    # Spectrum rainbow flash
    (".......", "....YGB", "...YGB.", "..YGB..", ".YGB...", "YGB....", "......."),
    # CPC monitor
    (".......", ".#####.", ".#GGG#.", ".#G.G#.", ".#####.", "...#...", "..###.."),
    # BBC Micro owl
    (".......", ".Y...Y.", ".YYYYY.", "YY.Y.YY", ".YY#YY.", "..YYY..", "...Y..."),
    # Apple rainbow
    ("....G..", "...G...", ".GGG.G.", "YYYYYY.", "OOOOOOO", "RRRRRR.", ".BBBB.."),
    # IBM stripes
    (".......", "BBBBBBB", ".......", "BBBBBBB", ".......", "BBBBBBB", "......."),
]
INK = {".": 0, "#": 0x61, "R": 0x62, "G": 0x6d, "B": 0x6e, "Y": 0x67, "O": 0x6a}


def build(root):
    sheet = Image.open(root / "assets" / "league-menu.png").convert("RGB")
    assert sheet.size == (3 * ART_WIDTH, 2 * ART_HEIGHT)
    indexed = sheet.quantize(colors=16, dither=Image.Dither.NONE)
    rgb = indexed.getpalette()
    palette = bytes(v for i in range(16) for v in (ART_PALETTE + i, *rgb[3*i:3*i+3]))
    pictures = []
    for i, address in enumerate(ART_PAGES):
        left, top = i % 3 * ART_WIDTH, i // 3 * ART_HEIGHT
        tile = indexed.crop((left, top, left + ART_WIDTH, top + ART_HEIGHT))
        pictures.append((address, bytes(ART_PALETTE + pixel for pixel in tile.tobytes())))
    state = bytearray(4096)
    for i, crest in enumerate(CRESTS):
        assert len(crest) == 7 and all(len(row) == 7 for row in crest)
        start = BADGES & 4095
        start += i * 49
        pixels = bytearray()
        for y, row in enumerate(crest):
            for x, character in enumerate(row):
                near_ink = any(
                    0 <= x+dx < 7 and 0 <= y+dy < 7 and crest[y+dy][x+dx] != "."
                    for dx, dy in ((0, -1), (-1, 0), (1, 0), (0, 1))
                )
                pixels.append(0x60 if character == "." and near_ink else INK[character])
        state[start:start+49] = pixels
    (root / "gen" / "league-art.asm").write_text(
        "art_mid dta " + ",".join(str(address >> 8 & 255) for address in ART_PAGES) + "\n"
        "art_bank dta " + ",".join(str(address >> 16) for address in ART_PAGES) + "\n"
        "crest_lo dta " + ",".join(str((BADGES + i*49) & 255) for i in range(8)) + "\n"
        "crest_mid dta " + ",".join(str((BADGES + i*49) >> 8 & 255) for i in range(8)) + "\n"
    )
    return palette, pictures, state
