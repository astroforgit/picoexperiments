#!/usr/bin/env python3
"""Author three 16px Grapple heroes on the game's six animation phases.

Run from any directory; outputs stay beside this script. Artwork uses the
existing four region markers and hard-edged pixel drawing, without resizing.
"""
from pathlib import Path
from PIL import Image, ImageDraw
from convert_character import SLIM_POSES, SLOTS

ROOT = Path(__file__).resolve().parent
MARKERS = {'accent': (255, 0, 0, 255), 'suit': (255, 255, 255, 255),
           'legs': (0, 255, 0, 255), 'face': (0, 0, 255, 255)}
PALETTES = {
    'scifi': {'accent': '#ffb454', 'suit': '#d5f5ff', 'legs': '#527da8', 'face': '#39d9d2'},
    'surreal': {'accent': '#ff79bd', 'suit': '#e9dcff', 'legs': '#9b70e8', 'face': '#ffe89b'},
    'goth': {'accent': '#d65085', 'suit': '#646579', 'legs': '#c3c9d6', 'face': '#ffccc1'}
}


def frame(kind, slot, pose):
    image = Image.new('RGBA', (16, 16))
    d = ImageDraw.Draw(image)
    h, shoulder, hip, arms, legs, trail = pose
    hx, hy = h
    col = MARKERS
    # Keep the leg cycle, arm direction and collapse pose matched to gameplay.
    for leg in legs:
        d.line(leg, fill=col['legs'], width=2 if kind == 'scifi' else 1)
        x, y = leg[-1]
        d.line((x-1, y, x+1, y), fill=col['accent'])
    if kind == 'scifi':
        # Oxygen pack, articulated suit, square helmet and luminous visor.
        sx, sy = shoulder
        d.rectangle((sx-4, sy, sx-3, min(15, sy+4)), fill=col['legs'])
        d.point((sx-4, sy+1), fill=col['accent'])
        for x0, y0, x1, y1 in arms:
            d.line((x0,y0,x1,y1), fill=col['suit'], width=2)
            d.point((x1,y1), fill=col['accent'])
        d.line((shoulder, hip), fill=col['suit'], width=3)
        d.point(shoulder, fill=col['accent'])
        d.rectangle((hx-3,hy-2,hx+2,hy+2), fill=col['suit'])
        d.rectangle((hx-1,hy-1,hx+2,hy+1), fill=col['legs'])
        d.line((hx,hy-1,hx+2,hy-1), fill=col['face'])
        d.point((hx+1,hy), fill=col['face'])
        d.point((hx-3,hy), fill=col['accent'])
        # Grapple gauntlet points along the actual horizontal pull poses.
        if slot in (17,18):
            d.line((13,6,15,6), fill=col['face'])
        if slot == 15:
            d.line((hx,hy,hx+2,hy+1), fill=col['accent'])
    elif kind == 'goth':
        # Long hair follows the existing motion phases. All clothing is closed.
        d.line(trail, fill=col['accent'], width=2)
        for x0,y0,x1,y1 in arms:
            d.line((x0,y0,x1,y1), fill=col['suit'])
            d.point((x1,y1), fill=col['face'])
        d.line((shoulder,hip), fill=col['suit'], width=3)
        sx,sy=shoulder
        ix,iy=hip
        d.line((ix-2,iy-1,ix-2,min(15,iy+2)), fill=col['suit'])
        d.point((sx,sy+1), fill=col['legs'])
        d.point((ix,iy-1), fill=col['legs'])
        d.rectangle((hx-2,hy-2,hx+1,hy+1), fill=col['accent'])
        d.line((hx+1,hy,hx+1,hy+2), fill=col['face'])
        d.point((hx+1,hy+1), fill=col['suit'])
        d.point((hx-1,hy-2), fill=col['legs'])
    else:
        # A single floating eye with a ribbon body and swaying dream tendrils.
        d.line(trail, fill=col['accent'])
        tx, ty = trail[-1]
        d.point((max(0,tx-1),min(15,ty+1)), fill=col['face'])
        for x0,y0,x1,y1 in arms:
            d.line((x0,y0,x1,y1), fill=col['accent'])
            d.point((x1,y1), fill=col['face'])
        d.line((shoulder,hip), fill=col['suit'], width=2)
        d.point(hip, fill=col['accent'])
        d.polygon([(hx-4,hy),(hx-2,hy-2),(hx+1,hy-2),(hx+3,hy),
                   (hx+1,hy+2),(hx-2,hy+2)], fill=col['accent'])
        d.line((hx-3,hy,hx+2,hy), fill=col['suit'], width=2)
        d.line((hx,hy-1,hx,hy+1), fill=col['legs'])
        d.point((hx+1,hy-1), fill=col['face'])
        # Blink once during idle; a closed eye when the character collapses.
        if slot in (1,15):
            d.line((hx-3,hy,hx+2,hy), fill=col['legs'])
        d.point((max(0,hx-4),max(0,hy-3)), fill=col['face'])
    return image


def generate():
    board = Image.new('RGB', (720, 460), '#111521')
    bd = ImageDraw.Draw(board)
    for row,kind in enumerate(PALETTES):
        folder = ROOT / {'scifi':'SciFi', 'surreal':'Surreal', 'goth':'GothPunk'}[kind]
        folder.mkdir(exist_ok=True)
        sheet = Image.new('RGBA', (80,64))
        for slot,pose in SLIM_POSES.items():
            cell = frame(kind,slot,pose)
            sheet.paste(cell, ((slot%5)*16,(slot//5)*16))
        sheet.save(folder / f'player-{kind}.png')
        palette = PALETTES[kind]
        coloured = Image.new('RGBA', sheet.size)
        lookup = {MARKERS[key]:tuple(bytes.fromhex(palette[key][1:]))+(255,) for key in MARKERS}
        coloured.putdata([lookup.get(pixel,(0,0,0,0)) for pixel in sheet.getdata()])
        coloured.resize((480,384), Image.Resampling.NEAREST).save(folder / 'sheet-preview.png')
        for name, slots in SLOTS.items():
            cells = [coloured.crop(((s%5)*16,(s//5)*16,(s%5+1)*16,(s//5+1)*16))
                     .resize((128,128),Image.Resampling.NEAREST) for s in slots]
            cells[0].save(folder / f'{name}-preview.gif', save_all=True,
                          append_images=cells[1:], duration=60 if name=='grapple_horiz' else 80,
                          loop=0, disposal=2)
        bd.text((16,row*150+12), {'scifi':'ORBIT RANGER / SCI-FI', 'surreal':'DREAM EYE / SURREAL', 'goth':'NIGHTSHADE / GOTH PUNK'}[kind], fill='white')
        for i,slot in enumerate((0,5,6,7,11,13,15,17)):
            cell=coloured.crop(((slot%5)*16,(slot//5)*16,(slot%5+1)*16,(slot//5+1)*16))
            cell=cell.resize((80,80),Image.Resampling.NEAREST)
            board.paste(cell,(16+i*86,row*150+40),cell)
            bd.text((16+i*86,row*150+124),f'frame {slot}',fill='#9daac6')
    board.save(ROOT / 'characters-preview.png')


if __name__ == '__main__':
    generate()
