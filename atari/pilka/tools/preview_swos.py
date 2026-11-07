#!/usr/bin/env python3
"""Export four SWOS player sheets to indexed pixels and a contact sheet.

320x256, four planes interleaved per scanline (40 bytes per plane).
Palette is gamePalette from SWOS-RE/SWOS2/Data.c; runtime kit recoloring
has not been applied. These are source sheets, not mapped game animations.
"""
from pathlib import Path
from PIL import Image, ImageDraw
ROOT = Path(__file__).resolve().parents[1]
COLORS = [0x360,0x999,0xfff,0,0x721,0xa40,0xf71,0x250,
          0x030,0x370,0xf00,0x00f,0x702,0x88f,0x380,0xff0]
PALETTE = [((c >> shift) & 15) * 17 for c in COLORS for shift in (8,4,0)]


def main():
    folder = ROOT / 'assets/swos'
    target = folder / 'indexed'
    target.mkdir(exist_ok=True)
    contact = Image.new('RGB', (640, 560), '#202830')
    draw = ImageDraw.Draw(contact)
    for index, name in enumerate(('CJCTEAM1','CJCTEAM2','CJCTEAM3','CJCTEAMG')):
        data = (folder / 'unpacked' / (name + '.RAW')).read_bytes()
        if len(data) != 40960:
            raise ValueError(f'Unexpected sheet size: {name}')
        pixels = bytes(sum(((data[y*160+p*40+x//8] >> (7-x%8)) & 1) << p
                           for p in range(4)) for y in range(256) for x in range(320))
        (target / (name + '.pixels')).write_bytes(pixels)
        im = Image.frombytes('P', (320,256), pixels)
        im.putpalette(PALETTE + [0] * (768-len(PALETTE)))
        im.save(target / (name + '.png'))
        x,y = index % 2 * 320, index // 2 * 280
        contact.paste(im.convert('RGB'), (x,y+24))
        draw.text((x+8,y+7), name, fill='white')
    (target / 'palette.rgb').write_bytes(bytes(PALETTE))
    contact.resize((1280,1120), Image.Resampling.NEAREST).save(folder / 'player-sheets.png')
    print('Exported four 320x256 indexed player sheets and palette.')


if __name__ == '__main__':
    main()
