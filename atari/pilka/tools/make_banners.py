#!/usr/bin/env python3
"""Native pixel art for the pitch advertising strip: flowers and Atari Fuji marks."""
from pathlib import Path
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]

def build():
    im=Image.new('P',(320,8),17)
    # Each 32-pixel panel alternates a flower garden and a blue Atari panel.
    fuji=['..#.#.#..','..#.#.#..','..#.#.#..','..#.#.#..','.#..#..#.','#...#...#','#...#...#']
    for panel in range(10):
        x0=panel*32
        if panel%2:
            for y in range(8):
                for x in range(32):im.putpixel((x0+x,y),22)
            for xoff in (3,19):
                for y,line in enumerate(fuji):
                    for x,ch in enumerate(line):
                        if ch=='#':im.putpixel((x0+xoff+x,y),17)
        else:
            for x in (5,15,25):
                for y in (5,6,7):im.putpixel((x0+x,y),21)
                for dx,dy in ((0,0),(-1,1),(1,1),(-2,2),(2,2),(-1,3),(1,3),(0,4)):
                    im.putpixel((x0+x+dx,dy),26 if x!=15 else 20)
                im.putpixel((x0+x,2),23)
                im.putpixel((x0+x+1,6),21)
    from build_assets import SHOWN
    palette=[(0,0,0)]*16+SHOWN
    im.putpalette([v for c in palette for v in c]+[0]*(768-3*len(palette)))
    (ROOT/'gen').mkdir(exist_ok=True)
    # The picture uses 16 + C64 colour; the char layer wants foreground indices.
    from build_assets import FGI
    tiles=b''.join(bytes(FGI[v-16] for v in im.crop((x,0,x+8,8)).getdata()) for x in range(0,320,8))
    (ROOT/'gen/banners.bin').write_bytes(tiles)
    (ROOT/'assets').mkdir(exist_ok=True)
    im.resize((1280,32),Image.Resampling.NEAREST).save(ROOT/'assets/banners-preview.png')
    return tiles

if __name__=='__main__':build()
