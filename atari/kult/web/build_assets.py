#!/usr/bin/env python3
"""Extract browser data from the original XEX using its own decompressor."""
import json, sys
from pathlib import Path
ROOT=Path(__file__).resolve().parent
sys.path.insert(0,str(ROOT.parent/'editor'))
from assets import project,word
from py65.devices.mpu6502 import MPU
p=project('kult');ram=p['banks']['ram']
def pixels(at,w,h):
    return [(ram[at+y*(w//4)+x//4]>>(6-(x%4)*2))&3 for y in range(h) for x in range(w)]
stages=[]
for stage in range(8):
    cpu=MPU(memory=list(ram));ptr=word(ram,0xc217+stage*2);cpu.x=ptr&255;cpu.y=ptr>>8;cpu.pc=0x300;cpu.stPushWord(0x2fe)
    for _ in range(1000000):
        if cpu.pc==0x2ff:break
        cpu.step()
    else:raise RuntimeError('Map decoder did not return')
    # $E815 selects section; $E920 resolves $1B80 + section*128.
    sequence=ram[0x4b00+stage*32:0x4b20+stage*32]
    columns=[[cpu.memory[0x1b80+section*128+row*16+col] for row in range(8)] for section in sequence for col in range(16)]
    waves=[list(ram[0x4400+stage*192+i*4:0x4404+stage*192+i*4]) for i in range(48)]
    stages.append(dict(columns=columns,waves=waves))
data=dict(player=[pixels(word(ram,0x7450+i*2),20,16) for i in range(4)],
 enemies=[[pixels(0x4f80+d*128+f*32,8,16) for f in range(4)] for d in range(33)],
 tiles=[pixels(0x2400+i*32,8,16) for i in range(256)],
 guardianTiles=[pixels(0xdac0+i*32,8,16) for i in range(34)],guardianMap=list(ram[0xfed2:0xfee2]),
 sine=list(ram[0x7164:0x7264]),motions=[list(ram[0x7310+i*8:0x7318+i*8]) for i in range(32)],
 formations=[list(ram[0x4a00+i*8:0x4a08+i*8]) for i in range(32)],stages=stages)
(ROOT/'assets.json').write_text(json.dumps(data,separators=(',',':'))+'\n')
# CPU oracle for the translated path function, including byte wrapping.
fixtures=[]
for motion in sorted({w[1] for s in stages for w in s['waves']}):
    cpu=MPU(memory=list(ram));cpu.memory[0x7410:0x7414]=[0]*4;cpu.memory[0x7418:0x7420]=data['motions'][motion]
    samples=[]
    for tick in range(80):
        cpu.pc=0xe7a4;cpu.stPushWord(0x2fe)
        for _ in range(2000):
            if cpu.pc==0x2ff:break
            cpu.step()
        else:raise RuntimeError('Motion routine did not return')
        samples.append([[cpu.memory[0x7462+i],cpu.memory[0x746a+i]] for i in range(8)])
    fixtures.append(dict(motion=motion,samples=samples))
(ROOT/'motion-fixtures.json').write_text(json.dumps(fixtures,separators=(',',':'))+'\n')
print('Extracted 8 stage maps, 384 waves, 132 enemy/effect frames and CPU motion fixtures.')
