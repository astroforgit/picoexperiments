#!/usr/bin/env python3
"""Build a native Kult space variant, retaining the original RLE loader."""
import hashlib, json, os, random, struct, subprocess, sys
from pathlib import Path
from PIL import Image, ImageDraw
ROOT=Path(__file__).resolve().parent
sys.path.insert(0,str(ROOT.parent/'editor'))
from assets import project,rle,word
from recover import kult

def packed(im):
    return bytes(sum(im.getpixel((x+i,y))<<(6-i*2) for i in range(4)) for y in range(im.height) for x in range(0,im.width,4))

def ship(frame):
    # Native ANTIC F is 40 hires pixels wide, not the web's 20 colour pairs.
    im=Image.new('1',(40,16));d=ImageDraw.Draw(im)
    d.polygon([(4,1),(15,3),(23,5),(36,0),(32,5),(24,8),(10,6)],fill=0,outline=1)
    d.polygon([(4,14),(15,12),(23,10),(36,15),(32,10),(24,7),(10,9)],fill=0,outline=1)
    d.polygon([(9,6),(17,4),(26,6),(38,8),(26,10),(17,11),(9,9),(12,8)],fill=1)
    d.line([(14,7),(25,7),(32,8)],fill=0)
    d.line([(14,9),(23,9)],fill=0)
    d.line([(1+frame%3,6),(8,6)],fill=1)
    d.line([(2+frame%2,9),(8,9)],fill=1)
    return im

def ship_bytes(im):
    return bytes(sum(int(im.getpixel((x+i,y)))<<(7-i) for i in range(8)) for y in range(16) for x in range(0,40,8))

def package(p,ram):
    # Keep a literal prefix in the retired tile bank: compressing empty space too
    # aggressively lets the in-place decoder overwrite its unread input.
    streams=[bytearray(),bytearray()];phase=0;old=p['banks']['ram']
    for block in p['blocks']:
        a=block['start'];data=bytearray(block['data'])
        for i in range(len(data)):
            if ram[a+i]!=old[a+i]:data[i]=ram[a+i]
        streams[phase]+=rle(struct.pack('<HH',a,len(data)))
        streams[phase]+=(b''.join(bytes([0xbf,v,1]) if v in (0xbf,0xcf) else bytes([v]) for v in data[:6144])+rle(data[6144:]) if a==0x2400 else rle(data))
        if a==0xbb00:
            streams[0]+=rle(bytes(4));phase=1
    streams[1]+=rle(struct.pack('<HH',0x7fee,0xffff))
    result=bytearray(p['original'])
    for base,end,encoded in zip((0x2b00,0x8000),(0x7fee,0xb300),streams):
        assert len(encoded)<=end-base,(hex(base),len(encoded),end-base)
        offset=6+base-0x2b00;result[offset:offset+len(encoded)]=encoded
    replay,_,_,_=kult(result)
    for b in p['blocks']:
        a=b['start'];n=b['size']
        if a not in (0xd301,0xbb00):assert replay[a:a+n]==ram[a:a+n],hex(a)
    return bytes(result)

def scenery(ram,rng,write_files=True):
    # Every star has its own randomly placed horizontal position. No missile
    # columns, repeated diagonal grids or evenly spaced vertical sequences.
    placed=[]
    stars=[]
    for lane,count,mask in ((0,8,(8,8)),(1,16,(8,8)),(2,32,(8,8))):
        height=len(mask);occupied=set()
        for i in range(count):
            choices=[y for y in range(43,166-height) if not occupied.intersection(range(y-1,y+height+1))]
            if not choices:raise ValueError('Star layout cannot fit')
            y=rng.choice(choices)
            occupied.update(range(y,y+height))
            best=[]
            for x in range(62,188):
                distance=min(((x-px)**2+((y-py)*.7)**2 for px,py in placed),default=99999)
                best.append((distance,x))
            # Choose among dispersed candidates; do not force rows or columns.
            best.sort(reverse=True)
            x=rng.choice(best[:max(12,len(best)//3)])[1]
            placed.append((x,y));stars.append(dict(lane=lane,x=x,y=y,height=height))
            for dy,bits in enumerate(mask):
                ram[0x3400+lane*256+y+dy]=bits
                ram[0x3800+lane*256+y+dy]=x
    # Retain full round glyphs, then clip only pixels outside the sky's edges.
    for x in range(256):
        ram[0x2c00+x]=sum(0x80>>bit for bit in range(8) if 64<=x+bit<192)
    ram[0x2800:0x2c00]=ram[0x3400:0x3800]
    for lane in range(4):
        for y in range(256):
            x=ram[0x3800+lane*256+y]
            ram[0x3400+lane*256+y]&=ram[0x2c00+x]
    if write_files:(ROOT/'star-layout.json').write_text(json.dumps(stars,indent=2)+'\n')

def create_runtime(settings=None,assemble=False,write_files=False):
    p=project('kult');old=p['banks']['ram'];ram=bytearray(old)
    # Retire all building tiles, retaining black space in the scrolling buffers,
    # and reuse the remainder for PM DMA and the small 6502 extension.
    ram[0x2400:0x4400]=bytes(0x2000)
    rng=random.Random(0xD1AB)
    # Blank terrain eliminates competing sideways motion. Stars use PM DMA.
    scenery(ram,rng,write_files)
    frames=[]
    for f in range(4):
        im=ship(f);frames.append(im)
        base=word(old,0x7450+f*2)
        for shift in range(4):
            aligned=Image.new('1',(40,16));aligned.paste(im,(shift*2,0))
            ram[base+shift*80:base+(shift+1)*80]=ship_bytes(aligned)
    if assemble:subprocess.run([os.environ.get('MADS','mads'),str(ROOT/'space.asm'),'-o:'+str(ROOT/'space.bin'),'-l:'+str(ROOT/'space.lst')],check=True,stdout=subprocess.PIPE)
    code=(ROOT/'space.bin').read_bytes();ram[0x4000:0x4000+len(code)]=code
    patches={
        0xEBB1:('d003','eaea'), # always advance formation twice per update
        0xFC1B:('80','60'),     # spawn closer to the right edge

        0xF764:('73','0c'),
        0xF769:('ea','40'),
        0xC126:('2062c3','4c55c1'), # skip title/menu loop, enter normal game setup
        0xC23B:('20','60'),         # skip stage announcement / fire prompt

        0xF746:('20d6e9','200040'), # graphics initialization
        0xF834:('2008f9','200340'), # per-game-frame parallax
        0xC41B:('adf1c3','200640'), # disable hardware scenery in menus
        0xE843:('2005e9','200940'), # replace building tile selection
        0xF75F:('21','3d'),        # enable single-line player DMA
        0xF975:('c900','29aa'),    # pixel 01 stars cannot cause collisions
    }
    for at,(expected,new) in patches.items():
        assert old[at:at+len(bytes.fromhex(expected))]==bytes.fromhex(expected),hex(at)
        ram[at:at+len(bytes.fromhex(new))]=bytes.fromhex(new)
    from workshop import apply_project, default_project
    apply_project(ram,settings if settings is not None else default_project())
    return p,ram,patches,frames

def main():
    from workshop import load_project
    p,ram,patches,frames=create_runtime(load_project(),assemble=True,write_files=True)
    old=p['banks']['ram']
    out=package(p,ram);(ROOT/'kult-diabolic.xex').write_bytes(out)
    preview=Image.new('1',(164,20))
    for f,im in enumerate(frames):preview.paste(im,(f*41,2))
    preview.resize((656,80),Image.Resampling.NEAREST).convert('RGB').save(ROOT/'ship.png')
    manifest={'original_sha256':hashlib.sha256(p['original']).hexdigest(),'output_sha256':hashlib.sha256(out).hexdigest(),'runtime_changed_bytes':sum(a!=b for a,b in zip(old,ram)),'patches':{f'{a:04X}':{'before':x,'after':y} for a,(x,y) in patches.items()},'cpu_depacker_verified':True}
    (ROOT/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    print('Built',ROOT/'kult-diabolic.xex','with verified original-loader replay.')
if __name__=='__main__':main()
