"""Pack the illustrated league menus for VBXE."""
from PIL import Image

ART_PAGES = (0x5d000, 0x5e000, 0x7a000, 0x7e000, 0x7f000, 0x72000)
ART_WIDTH, ART_HEIGHT = 64, 60
ART_PALETTE = 0xb0


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
    (root / "gen" / "league-art.asm").write_text(
        "art_mid dta " + ",".join(str(address >> 8 & 255) for address in ART_PAGES) + "\n"
        "art_bank dta " + ",".join(str(address >> 16) for address in ART_PAGES) + "\n"
    )
    return palette, pictures
