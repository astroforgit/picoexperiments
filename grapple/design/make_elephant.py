#!/usr/bin/env python3
"""Draw a Grapple elephant frontman inspired by steamlinejs/atari/elephant.png.

This is a hand-authored 16px interpretation of the reference's broad ears,
raised trunk, tusks, dark stage clothing and spiked cuffs. Each action is drawn
on the existing engine's pose/timing contract, including collapse and grapple.
"""
from pathlib import Path
from PIL import Image, ImageDraw
from convert_character import SLIM_POSES, SLOTS
from blackmetal_assets import blackmetal_cell

ROOT=Path(__file__).resolve().parent
OUT=ROOT/'BlackMetal'
# Four source regions, classified by the existing native build pipeline.
SKIN=(255,255,255,255)
CLOTH=(0,255,0,255)
IVORY=(0,0,255,255)
METAL=(255,0,0,255)
DISPLAY={SKIN:'#b8bdc9',CLOTH:'#454653',IVORY:'#fff3d9',METAL:'#f5f6ff'}


def elephant_frame(slot,pose):
    im=Image.new('RGBA',(16,16))
    d=ImageDraw.Draw(im)
    head,shoulder,hip,arms,legs,_=pose
    hx,hy=head
    hx=min(hx,10)
    # Keep weight transfer, foot planting and grapple reach matched to gameplay.
    for leg in legs:
        d.line(leg,fill=CLOTH,width=2)
        x,y=leg[-1]
        d.line((x-1,y,x+1,y),fill=METAL)
        d.point(leg[1],fill=SKIN)
    d.line((shoulder,hip),fill=CLOTH,width=4)
    sx,sy=shoulder
    ix,iy=hip
    d.line((sx-1,sy+1,ix,iy-1),fill=METAL)
    d.point((sx,sy+2),fill=IVORY)  # Pendant.
    d.line((ix-2,iy,ix+1,iy),fill=METAL)  # Studded belt.
    for x0,y0,x1,y1 in arms:
        d.line((x0,y0,x1,y1),fill=SKIN,width=2)
        d.point((x1-1,y1),fill=CLOTH)
        d.point((x1-1,y1-1),fill=METAL)
        d.point((x1-2,y1+1),fill=METAL)
    if slot==15:
        # Ears splay on the ground; the trunk curls towards the fallen body.
        d.ellipse((hx-5,hy-1,hx-1,hy+3),fill=SKIN)
        d.ellipse((hx-2,hy-2,hx+2,hy+2),fill=SKIN)
        d.line(((hx+1,hy+1),(hx+3,hy+3),(hx+5,hy+3)),fill=SKIN,width=2)
        d.line((hx-1,hy+1,hx+1,hy+1),fill=CLOTH)
        d.line(((hx,hy+2),(hx+1,hy+4),(hx+2,hy+3)),fill=IVORY)
    else:
        # Large ears and raised trunk make the elephant read at native scale.
        d.ellipse((hx-6,hy-1,hx-2,hy+4),fill=SKIN)
        d.line((hx-5,hy,hx-4,hy+3),fill=CLOTH)
        d.ellipse((hx-3,hy-2,hx+1,hy+3),fill=SKIN)
        d.point((hx-3,hy+2),fill=METAL)
        if slot in (17,18):
            trunk=((hx+1,hy+1),(14,hy+1),(15,hy-1))
        elif slot in (11,12):
            trunk=((hx+1,hy),(hx+3,hy+1),(hx+3,hy-2))
        else:
            sway=1 if slot in (1,6,8,14) else 0
            trunk=((hx+1,hy+1),(hx+3,hy+3),(hx+3,hy+6),(hx+5,hy+5),(hx+5,hy+2+sway))
        d.line(trunk,fill=SKIN,width=2)
        d.point(trunk[-1],fill=METAL)
        # Ivory tusk, dark eye, pale brow; preserve a distinct cheek outline.
        d.line(((hx,hy+2),(hx+1,hy+4),(hx+2,hy+3)),fill=IVORY)
        d.point((hx,hy),fill=CLOTH)
        d.point((hx-1,hy-1),fill=METAL)
    return im


def generate():
    OUT.mkdir(exist_ok=True)
    sheet=Image.new('RGBA',(80,64))
    for slot,pose in SLIM_POSES.items():
        sheet.paste(elephant_frame(slot,pose),((slot%5)*16,(slot//5)*16))
    sheet.save(OUT/'player-elephant.png')
    displayed=Image.new('RGBA',sheet.size)
    colours={marker:tuple(bytes.fromhex(colour[1:]))+(255,) for marker,colour in DISPLAY.items()}
    displayed.putdata([colours.get(pixel,(0,0,0,0)) for pixel in sheet.getdata()])
    displayed.resize((480,384),Image.Resampling.NEAREST).save(OUT/'sheet-preview.png')
    for state,slots in SLOTS.items():
        frames=[displayed.crop(((s%5)*16,(s//5)*16,(s%5+1)*16,(s//5+1)*16))
                .resize((128,128),Image.Resampling.NEAREST) for s in slots]
        frames[0].save(OUT/f'{state}-preview.gif',save_all=True,append_images=frames[1:],
                       duration=60 if state=='grapple_horiz' else 80,loop=0,disposal=2)
    board=Image.new('RGB',(800,430),'#111521')
    bd=ImageDraw.Draw(board)
    bd.text((16,12),'ELEPHANT FRONTMAN / BLACK METAL',fill='white')
    for i,slot in enumerate(SLIM_POSES):
        x=16+(i%8)*96;y=40+(i//8)*124
        cell=elephant_frame(slot,SLIM_POSES[slot])
        cell.putdata([colours.get(p,(0,0,0,0)) for p in cell.getdata()])
        cell=cell.resize((80,80),Image.Resampling.NEAREST)
        board.paste(cell,(x,y),cell)
        label=next(name for name,slots in SLOTS.items() if slot in slots)
        bd.text((x,y+86),f'{label} {slot}',fill='#b7c3dc')
    bd.text((16,300),'MATCHING BLACK-METAL COMPANIONS',fill='white')
    for index,asset in enumerate(('mover','spikes','cannon','cannonball','thwomp','checkpoint')):
        count=3 if asset=='thwomp' else 2 if asset=='checkpoint' else 1
        for state in range(count):
            c=blackmetal_cell(asset,state)
            scale=2 if count==3 else 3 if count==2 else 4
            c=c.resize((c.width*scale,c.height*scale),Image.Resampling.NEAREST)
            board.paste(c,(16+index*130+state*c.width,330),c)
        bd.text((16+index*130,400),asset,fill='#b7c3dc')
    board.save(OUT/'elephant-preview.png')


if __name__=='__main__':generate()
