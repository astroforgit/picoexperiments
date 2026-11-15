#!/usr/bin/env python3
"""Babajaga Atari sketch: native 2-bpp artwork in the recovered CETAS engine."""
import hashlib,json,sys
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
ROOT=Path(__file__).resolve().parent
sys.path.insert(0,str(ROOT.parent/'kult/editor'))
from assets import project,export_cetas,word
from recover import load
from atr import files
PAL=[(12,16,34),(92,77,137),(212,168,100),(251,234,193)]

def witch(frame=0,width=36,height=23,shift=0,hurt=False):
    # A compact adult witch silhouette, facing right; two-bit native pixel art.
    im=Image.new('L',(36,23));d=ImageDraw.Draw(im);flutter=[0,1,0,-1][frame]
    # Broom bristles and long wooden handle.
    d.line((3,18,32,18),fill=2);d.line((8,17,33,17),fill=3)
    for y in range(16,22):d.line((1+(y%2),y,9,18),fill=2)
    d.line((2,19,9,18),fill=3)
    # Tapered dress, bent knees and slim boots.
    d.polygon([(16,10),(13,11),(8,13+flutter),(5,12+flutter),(8,15),(14,15),(17,13)],fill=1)
    d.polygon([(17,10),(19,11),(19,12),(17,14),(20,16),(13,16),(15,13)],fill=1)
    d.point((18,11),fill=3)
    d.line([(17,16),(19,18),(18,20)],fill=3)
    d.line((18,20,21,20),fill=1)
    d.line([(14,16),(15,18),(14,21)],fill=2)
    d.line((14,21,17,21),fill=1)
    # Bare forearm, with a gap beneath the face so it cannot read as a beard.
    d.line([(19,12),(21,14),(24,15)],fill=3)
    d.point((24,16),fill=2)
    # Long hair stays BEHIND the face, streaming left in the direction of flight.
    d.polygon([(15,5),(17,5),(16,8),(14,10),(11,11+flutter),(7,10+flutter),(11,9),(13,7)],fill=2)
    d.line([(14,7),(12,9),(9,9+flutter)],fill=3)
    # Small oval face, visible eye, cheek and clean chin; no hair below the jaw.
    d.polygon([(17,6),(19,6),(20,7),(19,8),(18,9),(17,8)],fill=3)
    d.point((19,7),fill=0)
    d.point((19,8),fill=2)
    d.point((18,10),fill=3)
    # Swept pointed hat with a narrow brim and a bright hatband.
    d.polygon([(13,5),(15,1),(18,0),(17,2),(19,5)],fill=1)
    d.line((14,4,18,4),fill=2)
    d.line((12,5,21,5),fill=1)
    d.point((17,3),fill=3)
    # Four genuine poses: fluttering cloth and small boot/hand changes.
    if frame%2:d.point((22,20),fill=2);d.point((14,22),fill=1)
    if hurt:
        d.line((26,3,26,7),fill=3);d.line((24,5,28,5),fill=3)
    out=Image.new('L',(width,height));out.paste(im,(shift,height-23))
    return out

def spell(w,h,shift=0):
    im=Image.new('L',(w,h));d=ImageDraw.Draw(im);x=min(w-3,6+shift);y=h//2
    d.line((x-3,y,x+2,y),fill=3);d.line((x,y-2,x,y+2),fill=3)
    d.point((x-4,y+1),fill=2);d.line((0,y,x-5,y),fill=1);return im

def pack(im,bottom_up=False):
    w,h=im.size;assert w%4==0
    return bytes(sum(im.getpixel((x+j,y))<<(6-j*2) for j in range(4)) for y in (range(h-1,-1,-1) if bottom_up else range(h)) for x in range(0,w,4))

def rgb(im):
    out=Image.new('RGB',im.size);out.putdata([PAL[v] for v in im.getdata()]);return out

def font(size):return ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf',size)
def title(height=192,end=False):
    im=Image.new('L',(160,height));d=ImageDraw.Draw(im)
    d.ellipse((108,12,145,54),fill=2);d.ellipse((101,8,135,46),fill=0)
    for i in range(45):
        x=(i*47+13)%158;y=(i*29+7)%(height-35);d.point((x,y),fill=1 if i%3 else 3)
    for i in range(14):
        x=i*13-8;y=height-30-(i*17)%24;d.polygon([(x,y),(x-7,height-8),(x+7,height-8)],fill=1)
    d.rectangle((0,height-8,159,height),fill=1)
    label='BABAJAGA';f=font(21);d.text(((160-d.textlength(label,font=f))/2,25),label,font=f,fill=3,stroke_width=0)
    art=witch(1).resize((108,69),Image.Resampling.NEAREST);im.paste(art,(25,62),art.point(lambda p:255 if p else 0))
    d=ImageDraw.Draw(im)
    for text,y,size in [('FLY AGAIN' if end else 'A WITCH ON THE WIND',height-47,8),('PRESS FIRE',height-32,9),('CETAS ENGINE / ATARI SKETCH',height-18,6)]:
        f=font(size);d.text(((160-d.textlength(text,font=f))/2,y),text,font=f,fill=3 if size==9 else 2)
    # Fonts are antialiased in L mode: quantize their coverage to native indices.
    im=im.point(lambda v:min(3,v));return im

def build():
    p=project('cetas');banks={k:bytearray(v) for k,v in p['banks'].items()};ram=banks['game'];meta={a['address']:a for a in p['assets'] if a['category']=='Sprites'}
    manifest=[];frames=[]
    # $2C52 table interleaves four animation choices for each x-position pair.
    for group in range(2):
        for frame in range(4):
            ptr=word(ram,0x2c52+group*16+frame*2);a=meta[ptr]
            im=witch(frame,a['width'],a['height'],group*2)
            ram[a['offset']:a['offset']+a['width']*a['height']//4]=pack(im,True)
            manifest.append(dict(address=ptr,width=a['width'],height=a['height'],role=f'flight {frame+1}, alignment {group*2}'));frames.append(im)
    for i in range(2):
        ptr=word(ram,0x2c72+i*2);a=meta[ptr];im=witch(i,a['width'],a['height'],hurt=True)
        ram[a['offset']:a['offset']+a['width']*a['height']//4]=pack(im,True)
        manifest.append(dict(address=ptr,width=a['width'],height=a['height'],role='hit/death pose'));frames.append(im)
    for shift in range(4):
        ptr=word(ram,0x2d67+5*8+shift*2);a=meta[ptr];im=spell(a['width'],a['height'],shift)
        ram[a['offset']:a['offset']+a['width']*a['height']//4]=pack(im,True)
    cover=title();banks['D']=bytearray(pack(cover));banks['F']=bytearray(pack(title(162,True)))
    disk=export_cetas(banks);(ROOT/'babajaga.atr').write_bytes(disk)
    actual={n.rstrip('.'):b for n,b,_,_ in files(disk)};rebuilt,_=load(actual['E']);assert bytes(rebuilt)==bytes(ram)
    edits={k:{str(i):v for i,v in enumerate(b) if v!=p['banks'][k][i]} for k,b in banks.items() if k!='F'}
    edits={k:v for k,v in edits.items() if v}
    (ROOT/'babajaga-editor.json').write_text(json.dumps(dict(format='kult-cetas-editor',version=1,game='cetas',edits=edits),indent=2)+'\n')
    rgb(cover).resize((640,384),Image.Resampling.NEAREST).save(ROOT/'title.png')
    sheet=Image.new('RGB',(800,360),PAL[0]);d=ImageDraw.Draw(sheet)
    for i,im in enumerate(frames):
        x=(i%5)*160;y=(i//5)*180;art=rgb(im).resize((im.width*4,im.height*2),Image.Resampling.NEAREST);sheet.paste(art,(x,y+25));d.text((x+5,y+5),f'POSE {i+1:02}',font=font(11),fill=PAL[3])
    sheet.save(ROOT/'sprites.png');rgb(witch()).resize((576,184),Image.Resampling.NEAREST).save(ROOT/'witch.png')
    (ROOT/'manifest.json').write_text(json.dumps(dict(name='Babajaga',format='Atari SD ATR',sha256=hashlib.sha256(disk).hexdigest(),player=manifest,changedFiles=[n for n in actual if actual[n]!=p['files'][n]],originalSha256=hashlib.sha256(p['original']).hexdigest()),indent=2)+'\n')
    print('Built babajaga.atr:',len(disk),'bytes; 10 witch poses, spell variants, title and end screen.')
    return p,banks,actual
if __name__=='__main__':build()
