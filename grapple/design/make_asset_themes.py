#!/usr/bin/env python3
"""Draw companion assets at the exact native Grapple sheet sizes.

White/black are the two shared VBXE colours. Thwomp eyes may also use red.
Shapes stay inside the original cells; collision and movement do not change.
"""
from pathlib import Path
from PIL import Image, ImageDraw
from blackmetal_assets import blackmetal_cell

ROOT = Path(__file__).resolve().parent
W, B, R = '#ffffff', '#000000', '#ff0000'
THEMES = {'scifi':'SciFi', 'surreal':'Surreal', 'goth':'GothPunk', 'blackmetal':'BlackMetal'}
SIZES = {'mover':(16,16), 'spikes':(16,16), 'cannon':(16,16),
         'cannonball':(10,10), 'thwomp':(48,16), 'checkpoint':(32,16)}


def cell(theme, asset, state=0):
    if theme == "blackmetal":
        return blackmetal_cell(asset, state)
    im=Image.new('RGBA',(10,10) if asset=='cannonball' else (16,16))
    d=ImageDraw.Draw(im)
    if asset=='cannonball':
        if theme=='scifi':
            d.ellipse((1,1,8,8),fill=B,outline=W)
            d.line((3,3,6,6),fill=W)
            d.line((6,3,3,6),fill=W)
            for p in ((0,4),(9,5),(5,0),(4,9)):d.point(p,fill=W)
        elif theme=='surreal':
            d.polygon(((0,5),(3,2),(6,2),(9,5),(6,8),(3,8)),fill=W)
            d.ellipse((3,3,6,7),fill=B)
            d.point((5,3),fill=W)
            d.point((1,1),fill=W);d.point((8,9),fill=W)
        else:
            d.ellipse((1,1,8,8),fill=B,outline=W)
            d.rectangle((3,2,6,5),fill=W)
            d.point((3,3),fill=B);d.point((6,3),fill=B)
            d.line((4,6,5,6),fill=W)
            d.point((4,4),fill=B)
    elif asset=='cannon':
        if theme=='scifi':
            d.polygon(((1,2),(3,0),(12,9),(9,12)),fill=W)
            d.line((3,3,10,10),fill=B,width=2)
            d.line((1,2,3,0),fill=W,width=2)
            d.rectangle((7,9,14,14),fill=B,outline=W)
            d.line((9,12,12,12),fill=W)
            d.point((13,10),fill=W)
        elif theme=='surreal':
            d.line(((10,11),(13,14),(15,12)),fill=W)
            d.line(((8,12),(7,15),(4,14)),fill=W)
            d.ellipse((2,2,13,13),fill=W)
            d.ellipse((3,3,8,8),fill=B)
            d.point((4,4),fill=W)
            d.line((0,2,3,3),fill=W)
            d.line((2,0,3,3),fill=W)
        else:
            d.ellipse((6,6,14,14),fill=B,outline=W)
            d.polygon(((0,2),(2,0),(11,8),(8,11)),fill=W)
            d.line((2,2,9,9),fill=B)
            d.line((1,3,3,1),fill=B)
            d.line((9,10,12,10),fill=W)
            d.line((9,12,12,12),fill=W)
            d.point((13,8),fill=W)
    elif asset=='mover':
        d.rectangle((0,0,15,15),fill=B,outline=W)
        if theme=='scifi':
            d.rectangle((3,3,12,12),outline=W)
            for x in (1,14):
                for y in (2,13):d.point((x,y),fill=W)
            d.line((5,7,10,7),fill=W)
            d.line((7,5,7,10),fill=W)
        elif theme=='surreal':
            d.line(((2,5),(8,2),(13,6),(13,11),(7,14),(2,10),(2,5)),fill=W)
            d.line(((2,5),(7,8),(13,6)),fill=W)
            d.line((7,8,7,14),fill=W)
            d.line((8,2,8,6),fill=W)
        else:
            d.line((2,2,13,13),fill=W)
            d.line((13,2,2,13),fill=W)
            d.ellipse((5,5,10,10),fill=B,outline=W)
            for x in (3,12):
                for y in (3,12):d.point((x,y),fill=W)
    elif asset=='spikes':
        if theme=='scifi':
            d.rectangle((0,12,15,15),fill=W)
            d.line((1,14,14,14),fill=B)
            for x in (2,7,12):
                d.line((x,2,x,11),fill=W)
                d.point((x,0),fill=W)
                d.line((x-1,10,x+1,10),fill=W)
        elif theme=='surreal':
            for x,tip in ((0,3),(5,0),(10,4)):
                d.polygon(((x,14),(x+1,tip),(x+3,tip+2),(x+4,14)),fill=W)
                d.point((x+2,12),fill=(0,0,0,0))
            d.line((0,15,15,15),fill=W)
        else:
            d.line((0,13,15,13),fill=W)
            d.line((0,15,15,15),fill=W)
            for x in (2,7,12):
                d.line((x,4,x,15),fill=W)
                d.polygon(((x-2,5),(x,0),(x+2,5)),fill=W)
                d.point((x,3),fill=(0,0,0,0))
    elif asset=='thwomp':
        if theme=='scifi':
            d.polygon(((3,0),(12,0),(15,3),(15,12),(12,15),(3,15),(0,12),(0,3)),fill=B,outline=W)
            d.rectangle((3,4,12,9),outline=W)
            d.line((4,6,11,6),fill=R if state else W)
            if state==2:
                d.line((4,4,7,6),fill=W);d.line((11,4,8,6),fill=W)
            for x in (4,7,10):d.point((x,12),fill=W)
        elif theme=='surreal':
            d.ellipse((1,1,14,14),fill=W)
            d.line(((1,8),(0,12),(3,14)),fill=W)
            d.line(((14,8),(15,12),(12,15)),fill=W)
            if state==0:d.line((3,7,12,7),fill=B)
            else:
                d.polygon(((2,7),(5,4),(10,4),(13,7),(10,10),(5,10)),fill=B)
                d.line((7,5,7,9),fill=R,width=2)
            if state==2:d.line((5,12,10,12),fill=B)
        else:
            d.polygon(((0,0),(5,3),(10,3),(15,0),(13,9),(13,13),(10,15),(5,15),(2,13),(2,9)),fill=B,outline=W)
            if state==0:
                d.line((4,7,6,7),fill=W);d.line((9,7,11,7),fill=W)
            else:
                d.line((4,6,6,7),fill=R);d.line((11,6,9,7),fill=R)
            d.line((5,11,10,11),fill=W)
            if state==2:
                for x in (5,7,9):d.line((x,11,x,13),fill=W)
    elif asset=='checkpoint':
        # Only white and transparency, matching the checkpoint classifier.
        if theme=='scifi':
            d.line((7,6,7,14),fill=W)
            d.line((3,15,12,15),fill=W)
            d.rectangle((4,4,11,8),outline=W)
            if state:
                d.line((7,0,7,2),fill=W)
                d.line((1,4,2,5),fill=W);d.line((13,5,14,4),fill=W)
                d.point((7,6),fill=W)
        elif theme=='surreal':
            d.line((7,8,7,15),fill=W)
            d.line(((3,15),(7,12),(11,15)),fill=W)
            d.ellipse((3,3,11,9),outline=W)
            if state:
                d.line((7,4,7,8),fill=W)
                d.point((1,1),fill=W);d.point((13,2),fill=W)
            else:d.line((4,6,10,6),fill=W)
        else:
            d.line(((5,3),(5,1),(9,1),(9,3)),fill=W)
            d.polygon(((3,4),(11,4),(10,11),(4,11)),outline=W)
            d.line((5,13,9,13),fill=W)
            d.line((7,11,7,15),fill=W)
            if state:
                d.line((7,5,7,9),fill=W)
                d.point((0,6),fill=W);d.point((14,6),fill=W)
    return im


def generate():
    board=Image.new('RGB',(860,len(THEMES)*170+10),'#111521')
    bd=ImageDraw.Draw(board)
    for row,(theme,foldername) in enumerate(THEMES.items()):
        folder=ROOT/foldername
        folder.mkdir(exist_ok=True)
        bd.text((16,row*170+10),{'scifi':'SCI-FI / plasma, railgun, machinery',
            'surreal':'SURREAL / eyes, impossible cube, dream teeth',
            'goth':'GOTH PUNK / engraved skull, ironwork, gargoyle, lantern',
            'blackmetal':'BLACK METAL / thorns, horned iron, spiked skull, corpse paint, ritual candle'}[theme],fill='white')
        for column,(asset,size) in enumerate(SIZES.items()):
            sheet=Image.new('RGBA',size)
            count=3 if asset=='thwomp' else 2 if asset=='checkpoint' else 1
            for state in range(count):sheet.paste(cell(theme,asset,state),(state*16,0))
            sheet.save(folder/(asset+'.png'))
            # Show all state frames, with two thwomps below the first one.
            for state in range(count):
                c=cell(theme,asset,state)
                scale=5 if count==1 else 3
                c=c.resize((c.width*scale,c.height*scale),Image.Resampling.NEAREST)
                x=16+column*140+(state%2)*50 if count>1 else 16+column*140
                y=row*170+37+(state//2)*50
                board.paste(c,(x,y),c)
            bd.text((16+column*140,row*170+142),asset,fill='#b7c3dc')
    board.save(ROOT/'asset-themes-preview.png')


if __name__=='__main__':generate()
