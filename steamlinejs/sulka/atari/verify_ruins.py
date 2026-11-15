#!/usr/bin/env python3
from pathlib import Path
import argparse
import subprocess
import tempfile
from py65.devices.mpu6502 import MPU
from PIL import Image, ImageDraw
ROOT=Path(__file__).resolve().parent.parent
parser=argparse.ArgumentParser(description="Check sketch scenery using a 6502 and a minimal VBXE memory/blitter model.")
parser.add_argument('--preview', type=Path, help='Optional rendered static-room contact sheet')
args=parser.parse_args()
with tempfile.TemporaryDirectory() as directory:
    temp=Path(directory)
    subprocess.run(['mads', str(ROOT/'atari/sulka-vbxe.asm'), f'-o:{temp}/game.xex', f'-t:{temp}/labels.txt'], check=True, capture_output=True)
    label_text=(temp/'labels.txt').read_text()
    binary=(temp/'game.xex').read_bytes()
labels={}
for line in label_text.splitlines():
    parts=line.split()
    if len(parts)==3 and parts[0]=='00': labels[parts[2]]=int(parts[1],16)
raw=binary; pos=0; used=set(); base=[0]*65536
while pos<len(raw):
    start=int.from_bytes(raw[pos:pos+2],'little');pos+=2
    if start==65535:continue
    end=int.from_bytes(raw[pos:pos+2],'little');pos+=2
    addresses=set(range(start,end+1));assert not used&addresses,f'Segment overlap {start:04x}'
    used|=addresses;base[start:end+1]=raw[pos:pos+end-start+1];pos+=end-start+1
class Memory:
    def __init__(self):self.ram=base.copy();self.vram=bytearray(512*1024);self.bank=127
    def __getitem__(self,key):
        if isinstance(key,slice):return self.ram[key]
        if 0x9000<=key<0xa000:return self.vram[self.bank*4096+key-0x9000]
        return self.ram[key]
    def __setitem__(self,key,value):
        if isinstance(key,slice):self.ram[key]=value;return
        if key==0xd65f:self.bank=value&127
        if 0x9000<=key<0xa000:self.vram[self.bank*4096+key-0x9000]=value
        else:self.ram[key]=value
m=Memory();cpu=MPU(memory=m)
def get(name):return m[labels[name]]
def put(name,v):m[labels[name]]=v
def word(name):return get(name)+256*m[labels[name]+1]
def addr(name):return word(name)+65536*m[labels[name]+2]
blits=[]
def run(name):
    cpu.pc=labels[name];cpu.sp=255;cpu.stPushWord(0xffe)
    for steps in range(3000000):
        if cpu.pc==0xfff:return steps
        if cpu.pc==labels['WAIT_BLIT']:cpu.pc=cpu.stPopWord()+1
        elif cpu.pc==labels['DO_BLIT']:
            src,dst=addr('BL_SRC'),addr('BL_DST');w,h=word('BL_W')+1,get('BL_H')+1
            blits.append((src,dst,w,h))
            for y in range(h):
                for x in range(w):
                    value=m.vram[src+y*word('BL_SSY')+x*get('BL_SSX')]
                    value=(value&get('BL_AND'))^get('BL_XOR')
                    if get('BL_MODE')!=1 or value:m.vram[dst+y*word('BL_DSY')+x*get('BL_DSX')]=value
            cpu.pc=cpu.stPopWord()+1
        else:cpu.step()
    raise AssertionError('CPU did not return')
steps=run('UPLOAD_RUINS');assert m.bank==127
palette={};i=labels['PALETTE']
while m[i]!=255:palette[m[i]]=tuple(m[i+1:i+4]);i+=4
for filename,bank in (('ukr1-line-background-vbxe.png',4),('ukr2-line-background-vbxe.png',5),('galaxy-painted-vbxe.png',6)):
    expected=Image.open(ROOT/f'assets/{filename}').convert('RGB')
    actual=Image.new('RGB',(224,140));actual.putdata([palette[m.vram[bank*65536+y*256+x]] for y in range(140) for x in range(224)])
    assert actual.tobytes()==expected.tobytes(),f'VRAM background {filename} differs'
assert all(m.vram[i]==0 for i in range(4*65536)), 'Upload overwrote frame/cache/sprite banks'
sheet=Image.new('RGB',(640,600));spots={0:(0,0),1:(320,0),2:(0,200),5:(320,200),6:(0,400),13:(320,400)}
for room in range(24):
    ptr=m[labels['LEVELS_LO']+room]+256*m[labels['LEVELS_HI']+room]
    put('LEVEL_NUMBER',room);put('LEVEL_PTR',ptr&255);m[labels['LEVEL_PTR']+1]=ptr>>8
    m[labels['LEVEL_MAP']:labels['LEVEL_MAP']+336]=m[ptr:ptr+336]
    original=bytes(m[labels['LEVEL_MAP']:labels['LEVEL_MAP']+336])
    blits.clear();run('BUILD_ROOM_CACHE')
    sketches=[b for b in blits if b[0] in (4*65536,5*65536,6*65536)]
    assert len(sketches)==1
    assert sketches[0][0] == (4 + room % 2 if room < 6 else 6)*65536, f'Wrong theme in room {room+1}'
    assert bytes(m[labels['LEVEL_MAP']:labels['LEVEL_MAP']+336])==original
    if room in spots:
        image=Image.new('RGB',(320,200));image.putdata([palette[v] for v in m.vram[2*65536:2*65536+64000]])
        ImageDraw.Draw(image).text((10,8),f'ROOM {room+1:02}',fill=(180,180,180));sheet.paste(image,spots[room])
# Execute the actual wall dispatch for every room and both hatching variants.
for room in range(24):
    put('LEVEL_NUMBER', room);put('RENDER_BANK',2)
    put('TILE_X',40);m[labels['TILE_X']+1]=0;put('TILE_Y',28)
    for variant in (0,1):
        put('DRAW_COL',variant);put('DRAW_ROW',0)
        run('DRAW_WALL')
        actual=[palette[m.vram[2*65536+(28+y)*320+37+x]] for y in range(7) for x in range(16)]
        theme='outline' if room < 6 else 'neon'
        expected=list(Image.open(ROOT/f'assets/platform-{theme}-{variant}.png').convert('RGB').getdata())
        assert actual==expected, (room,variant,theme)
if args.preview:
    sheet.resize((1280,1200),Image.Resampling.NEAREST).save(args.preview)
print(f'PASS: nonoverlapping XEX segments; 6502 upload ({steps} instructions) pixel-exact for all three backgrounds; VRAM isolation; all 24 room caches and collision-map preservation; outline platforms in levels 1–6; fluorescent plastic and galaxy from level 7.')
