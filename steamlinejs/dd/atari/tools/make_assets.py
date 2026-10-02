#!/usr/bin/env python3
"""Decode the supplied SNES 4bpp CHR and NES packed screen/metasprite data.

No ROM download or SNES assembler is required. Palette assignments and the
Atari encounter campaign are adaptations; tile pixels and poses are source data.
"""
from pathlib import Path
import re
import json
import hashlib
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT.parent / 'double-dragon-snes-main/double-dragon-snes-main/src'
OUT = ROOT / 'generated'

def raw(name):
    result = bytearray()
    for line in (SOURCE / name).read_text().splitlines():
        line = line.split(';')[0].strip()
        if line.startswith('.byte '):
            for item in line[6:].split(','):
                item = item.strip()
                if not re.fullmatch(r'\$[0-9A-Fa-f]{2}', item):
                    raise ValueError(f'{name}: nonliteral data {item}')
                result.append(int(item[1:], 16))
    return result

def word(data, p):
    return data[p] | data[p+1] << 8

def tile(data, number):
    p = number * 32
    assert p+32 <= len(data)
    return [sum(((data[p+16*(plane//2)+y*2+plane%2] >> (7-x)) & 1) << plane
                for plane in range(4)) for y in range(8) for x in range(8)]

def scan_poses(data):
    poses = {}
    for p in range(len(data)-8):
        n = data[p+1]
        if data[p] != 254 or not 4 <= n <= 40:
            continue
        a, t, xy = [word(data, p+i)-0x8000 for i in (2,4,6)]
        if not (0 <= a <= len(data)-n and 0 <= t <= len(data)-n and 0 <= xy <= len(data)-n*2):
            continue
        if any(v & ~0xc3 for v in data[a:a+n]):
            continue
        poses[p+0x8000] = (n, a, t, xy)
    return poses

def pose(data, chrdata, header, colors=(32,36), chained=False):
    im = Image.new('P', (64,64))
    p=header-0x8000
    parts=[]
    if data[p] == 254:
        n,a,t,xy=scan_poses(data)[header]
        parts=[(data[a+i],data[t+i],data[xy+i*2],data[xy+i*2+1]) for i in range(n)]
        p+=8
    while chained and 0 < data[p] < 40 and not data[p+1] & ~0xc3:
        count,attr=data[p:p+2]
        t,xy=word(data,p+2)-0x8000,word(data,p+4)-0x8000
        if not (0 <= t <= len(data)-count and 0 <= xy <= len(data)-count*2): break
        parts.extend((attr,data[t+i],data[xy+i*2],data[xy+i*2+1]) for i in range(count))
        p+=6
    for attr,number,x,y in parts:
        x = x if x < 128 else x-256
        if not -32 <= x <= 24 or not 0 <= y <= 56:
            raise ValueError(f'pose {header:04x}: invalid coordinate {x},{y}')
        for k, c in enumerate(tile(chrdata, number)):
            if c:
                xx,yy=k%8,k//8
                if attr&64: xx=7-xx
                if attr&128: yy=7-yy
                im.putpixel((32+x+xx, 56-y+yy), colors[attr&1]+c)
    return im

def audit():
    OUT.mkdir(exist_ok=True)
    banks = [raw(f'chrom-tiles-{i}.asm') for i in range(8)]
    data = raw('bank4.asm')
    palette = [0,0,0]*256
    for i,c in enumerate([(0,0,0),(70,100,210),(238,180,132),(245,240,220)]):
        for base in (0,32,36): palette[(base+i)*3:(base+i)*3+3] = c
    sheet = Image.new('RGB', (8*160, 4*160), '#25252e')
    for bank in range(32):
        im = Image.new('P',(128,128)); im.putpalette(palette)
        for t in range(256):
            pixels = tile(banks[bank//4], bank%4*256+t)
            for k,c in enumerate(pixels): im.putpixel((t%16*8+k%8,t//16*8+k//8),c)
        sheet.paste(im.convert('RGB'),(bank%8*160,bank//8*160+20))
        ImageDraw.Draw(sheet).text((bank%8*160,bank//8*160),f'CHR {bank}', fill='white')
    sheet.save(OUT/'chr-audit.png')
    items = []
    for header in scan_poses(data):
        if header >= 0x8951: break
        try: items.append((header,pose(data,banks[0],header)))
        except ValueError: pass
    sheet = Image.new('RGB',(8*128, ((len(items)+7)//8)*140),'#25252e')
    for i,(header,im) in enumerate(items):
        im.putpalette(palette)
        sheet.paste(im.resize((128,128)).convert('RGB'),(i%8*128,i//8*140))
        ImageDraw.Draw(sheet).text((i%8*128,i//8*140),f'{header:04x}',fill='white')
    sheet.save(OUT/'pose-audit.png')
    bg = raw('bank0.asm')
    sheet = Image.new('RGB',(6*256,7*256),'#25252e')
    for s in range(37):
        im = Image.new('P',(256,240)); im.putpalette(palette)
        p = word(bg,s*2)-0x8000
        for row in range(30):
            r = word(bg,p+row*2)-0x8000
            if not 0 <= r < len(bg)-32: continue
            for col in range(32):
                for k,c in enumerate(tile(banks[4],bg[r+col])):
                    im.putpixel((col*8+k%8,(29-row)*8+k//8),c)
        sheet.paste(im.convert('RGB'),(s%6*256,s//6*256+16))
        ImageDraw.Draw(sheet).text((s%6*256,s//6*256),str(s),fill='white')
    sheet.save(OUT/'screen-audit.png')
    sheet=Image.new('RGB',(16*96,3*128),'#25252e')
    for row,header in enumerate([0x8085,0x895e,0x8fac]):
        for ch in range(16):
            chunk=banks[ch//4][ch%4*8192:(ch%4+1)*8192]
            im=pose(data,chunk,header); im.putpalette(palette)
            sheet.paste(im.resize((96,96)).convert('RGB'),(ch*96,row*128+20))
            ImageDraw.Draw(sheet).text((ch*96,row*128),f'{header:04x} CHR{ch}',fill='white')
    sheet.save(OUT/'pose-banks.png')
    data=raw('bank3.asm')
    items=[]
    for header in scan_poses(data):
        if header>=0x8c62: break
        try: items.append((header,pose(data,banks[0][:8192],header,chained=True)))
        except ValueError: pass
    sheet=Image.new('RGB',(8*128,((len(items)+7)//8)*128),'#25252e')
    for i,(header,im) in enumerate(items):
        im.putpalette(palette)
        sheet.paste(im.resize((128,128)).convert('RGB'),(i%8*128,i//8*128))
        ImageDraw.Draw(sheet).text((i%8*128,i//8*128),f'{header:04x}',fill='white')
    sheet.save(OUT/'native-poses.png')
    groups=[(0x8c62,0x9429,0),(0x980e,0x9bf9,2),(0xa86d,0xad50,5)]
    for lo,hi,ch in groups:
        items=[]
        chunk=banks[ch//4][ch%4*8192:(ch%4+1)*8192]
        for header in scan_poses(data):
            if not lo <= header < hi: continue
            try: items.append((header,pose(data,chunk,header,chained=True)))
            except ValueError: pass
        sheet=Image.new('RGB',(8*128,((len(items)+7)//8)*128),'#25252e')
        for i,(header,im) in enumerate(items):
            im.putpalette(palette)
            sheet.paste(im.resize((128,128)).convert('RGB'),(i%8*128,i//8*128))
            ImageDraw.Draw(sheet).text((i%8*128,i//8*128),f'{header:04x}',fill='white')
        sheet.save(OUT/f'enemy-{ch}-poses.png')
    sheet=Image.new('RGB',(7*320,2*216),'#25252e')
    for j,screen in enumerate((18,28)):
        for chrset in range(19,26):
            im=Image.new('P',(256,200)); im.putpalette(palette)
            p=word(bg,screen*2)-0x8000
            for row in range(25):
                r=word(bg,p+(row+5)*2)-0x8000
                for col in range(32):
                    for k,c in enumerate(tile(banks[chrset//4],chrset%4*256+bg[r+col])):
                        im.putpixel((col*8+k%8,(24-row)*8+k//8),c)
            sheet.paste(im.resize((320,200)).convert('RGB'),((chrset-19)*320,j*216+16))
            ImageDraw.Draw(sheet).text(((chrset-19)*320,j*216),f'screen{screen} CHR{chrset}',fill='white')
    sheet.save(OUT/'stage-banks.png')
    bg=raw('bank1.asm')
    sheet=Image.new('RGB',(4*320,4*216),'#25252e')
    for j,screen in enumerate((0,2,4,6)):
        for chrset in range(22,26):
            im=Image.new('P',(256,200)); im.putpalette(palette)
            p=word(bg,screen*2)-0x8000
            for row in range(25):
                r=word(bg,p+(row+5)*2)-0x8000
                for col in range(32):
                    for k,c in enumerate(tile(banks[chrset//4],chrset%4*256+bg[r+col])):
                        im.putpixel((col*8+k%8,(24-row)*8+k//8),c)
            sheet.paste(im.resize((320,200)).convert('RGB'),((chrset-22)*320,j*216+16))
            ImageDraw.Draw(sheet).text(((chrset-22)*320,j*216),f'bank1 screen{screen} CHR{chrset}',fill='white')
    sheet.save(OUT/'hideout-banks.png')

def build():
    OUT.mkdir(exist_ok=True)
    banks = [raw(f'chrom-tiles-{i}.asm') for i in range(8)]
    bg, actors = raw('bank0.asm'), raw('bank3.asm')
    assert len(bg) == len(actors) == 16384
    assert all(len(b) == 32768 for b in banks)
    palette = [0]*768
    colors = [
        (0,0,0),(18,22,38),(55,63,86),(133,125,124),(216,191,159),
        (13,25,32),(59,79,88),(129,137,129),(214,199,158),
        (13,26,22),(44,74,48),(110,130,69),(185,170,109),
        (22,15,27),(72,49,73),(139,103,111),(219,174,144),
    ]
    for i,c in enumerate(colors): palette[i*3:i*3+3] = c
    costumes = [((35,84,204),(77,133,240)),((128,41,33),(196,74,48)),
                ((136,38,117),(224,64,156)),((62,131,59),(124,181,83))]
    for group, (shirt,pants) in enumerate(costumes):
        for half, cloth in enumerate((shirt,pants)):
            for i,c in enumerate(((0,0,0),cloth,(224,160,108),(252,216,172))):
                p=(64+group*8+half*4+i)*3
                palette[p:p+3]=c
    palette[96*3:96*3+3] = (247,210,120)
    palette[97*3:97*3+3] = (230,235,248)
    # Four tile atlases at $20000, one 1024x200 panorama cache at $30000.
    # Maps remain in CPU RAM; a stage transition rebuilds the cache via blits.
    vram = bytearray(0x5f000)
    stages = [
        {'bank':0,'screens':[0,2,4,6],'chr':16,'name':'THE STREETS'},
        {'bank':0,'screens':[8,10,12,14],'chr':18,'name':'INDUSTRIAL AREA'},
        {'bank':0,'screens':[18,20,22,24],'chr':20,'name':'THE CAVES'},
        {'bank':1,'screens':[6,8,10,12],'chr':22,'name':'THE HIDEOUT'},
    ]
    maps=[]
    for stage,desc in enumerate(stages):
        chrset=desc['chr']
        atlas=[bytes(1+stage*4+c for c in tile(banks[chrset//4],chrset%4*256+t)) for t in range(256)]
        vram[stage*16384:(stage+1)*16384]=b''.join(atlas)
        bg=raw(f"bank{desc['bank']}.asm")
        mapdata=bytearray(128*25)
        im=Image.new('P',(1024,200)); im.putpalette(palette)
        for room,screen in enumerate(desc['screens']):
            p=word(bg,screen*2)-0x8000
            for row in range(25):
                r=word(bg,p+(29-row)*2)-0x8000
                assert 0 <= r <= len(bg)-32
                for col in range(32):
                    number=bg[r+col]
                    mapdata[row*128+room*32+col]=number
                    im.paste(Image.frombytes('P',(8,8),atlas[number]),(room*256+col*8,row*8))
        maps.append(mapdata)
        (OUT/f'map-{stage}.bin').write_bytes(mapdata)
        im.save(OUT/f'world-{stage+1}.png')
        im.crop((0,0,320,200)).save(OUT/f'stage-{stage+1}.png')
        if stage == 0: vram[0x10000:0x42000]=im.tobytes()
    (OUT/'maps.asm').write_text('\n'.join(
        f"world_map_{i} ins 'generated/map-{i}.bin'" for i in range(4))+'\n')
    # Main-game bank 3: base FE records plus constant-attribute limb records.
    # Four poses per fighter, right then left; source poses face left.
    configs = [
        (0,[0x80cd,0x8133,0x85e5,0x8a50]),
        # Enemy fourth poses are source knockdown frames (no extra VRAM).
        (0,[0x8cd4,0x8d06,0x919d,0x9400]),
        (2,[0x9877,0x989f,0x9aab,0x9bd4]),
        (5,[0xa8cd,0xa908,0xaba9,0xacfe]),
    ]
    sprite_images=[]
    for group,(chrset,headers) in enumerate(configs):
        chrdata=banks[chrset//4][chrset%4*8192:(chrset%4+1)*8192]
        for facing in range(2):
            for header in headers:
                im=pose(actors,chrdata,header,(64+group*8,68+group*8),chained=True).crop((0,8,64,64))
                if not facing: im=im.transpose(Image.Transpose.FLIP_LEFT_RIGHT)
                im.putpalette(palette)
                address=0x42000+len(sprite_images)*3584
                vram[address:address+3584]=im.tobytes()
                sprite_images.append(im)
    sheet=Image.new('RGB',(8*128,4*112),(18,22,38))
    for i,im in enumerate(sprite_images): sheet.paste(im.resize((128,112)).convert('RGB'),(i%8*128,i//8*112))
    sheet.save(OUT/'fighters.png')
    # Uppercase ASCII font uses $7e000 and unused tails of the framebuffers.
    # The renderer writes only 64000 of each framebuffer's 65536 bytes.
    from PIL import ImageFont
    fnt=ImageFont.load_default()
    font=bytearray()
    for ch in range(32,96):
        im=Image.new('P',(8,12)); ImageDraw.Draw(im).text((0,0),chr(ch),font=fnt,fill=97)
        font.extend(im.tobytes())
    vram[0x5e000:0x5e000+42*96]=font[:42*96]
    tail0=bytearray(4096); tail0[0xa00:]=font[42*96:58*96]
    tail1=bytearray(4096); tail1[0xa00:0xa00+6*96]=font[58*96:]
    font_addresses=[0x7e000+i*96 for i in range(42)]+[0xfa00+i*96 for i in range(16)]+[0x1fa00+i*96 for i in range(6)]
    (OUT/'font.asm').write_text('\n'.join(
        name+' dta '+','.join(f'${(address>>shift)&255:02x}' for address in font_addresses)
        for name,shift in [('font_lo',0),('font_hi',8),('font_bank',16)])+'\n')
    assert len(vram) == 0x5f000
    includes=[]
    segments=[(32+i,vram[p:p+4096]) for i,p in enumerate(range(0,len(vram),4096))]+[(15,tail0),(31,tail1)]
    for i,(bank,pixels) in enumerate(segments):
        filename=f'bank-{i:02d}.bin'
        (OUT/filename).write_bytes(pixels)
        includes.extend(['        org upload_index',f'        dta {bank}',
                         '        org $8000',f"        ins 'generated/{filename}'",'        ini upload_bank'])
    (OUT/'assets.asm').write_text('\n'.join(includes)+'\n')
    (OUT/'palette.bin').write_bytes(bytes(palette))
    manifest={'source':str(SOURCE.relative_to(ROOT.parent)), 'stages':stages,
              'sprites':len(sprite_images),'sprite_size':[64,56], 'vram_end':hex(0x20000+len(vram)),
              'upload_banks':[bank for bank,pixels in segments], 'world_size':[1024,200],
              'inputs':{f.name:hashlib.sha256(f.read_bytes()).hexdigest() for f in
                        [SOURCE/'bank0.asm',SOURCE/'bank1.asm',SOURCE/'bank3.asm',*[SOURCE/f'chrom-tiles-{i}.asm' for i in range(8)]]}}
    (OUT/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    print(f'Converted 16 rooms, 4 tile atlases, {len(sprite_images)} fighter frames; {len(segments)} VRAM uploads')

if __name__ == '__main__':
    import sys
    audit() if '--audit' in sys.argv else build()
