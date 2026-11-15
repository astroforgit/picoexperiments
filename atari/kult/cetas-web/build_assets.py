#!/usr/bin/env python3
import json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parent
sys.path.insert(0,str(ROOT.parent/'editor'))
from assets import project,word
from py65.devices.mpu6502 import MPU
p=project('cetas');ram=p['banks']['game'];sprites={}
for a in p['assets']:
    if a['category']!='Sprites':continue
    b=p['banks'][a['bank']];w=a['width'];h=a['height'];at=a['offset']
    pixels=[(b[at+(h-1-y)*(w//4)+x//4]>>(6-(x%4)*2))&3 for y in range(h) for x in range(w)]
    sprites[a['id']]=dict(width=w,height=h,pixels=pixels,header=a['header'])
types={str(t):[f'sprite-{word(ram,0x2d67+(t-1)*8+i*2):04x}' for i in range(4)] for t in range(1,19)}
specs={2:(0x2b63,0x2b72,15,0,164,192,16),9:(0x2a19,0x2a4b,50,0,164,191,0),10:(0x2848,0x285a,18,0,164,183,0),11:(0x2984,0x29ac,40,0,164,183,0),12:(0x28bc,0x2902,70,40,172,183,0),16:(0x25c8,0x2618,80,0,164,191,0),17:(0x272e,0x2744,22,0,164,183,0),18:(0x272e,0x275a,25,0,164,183,0)}
paths={str(t):dict(dx=list(ram[x:x+n]),dy=list(ram[y:y+n]),length=n,repeat=repeat,xmax=xmax,ymax=ymax,ymin=ymin) for t,(x,y,n,repeat,xmax,ymax,ymin) in specs.items()}
script=list(ram[0xaa04:0xabde]);chapters=[dict(name='01 · Opening barrage',cursor=0,delay=0)];i=0;delay=0
while i<len(script):
    op=script[i]
    if op==255:delay=script[i+1];i+=2
    elif op in (254,251):i+=2
    elif op==250:i+=3
    elif op==252:
        i+=1
        if i<len(script):chapters.append(dict(name=f'{len(chapters)+1:02} · Script checkpoint',cursor=i,delay=delay))
    elif op==253:i+=1
    elif op==0:break
    else:i+=6
chapters=chapters[:-1] if chapters[-1]['cursor']>=len(script)-5 else chapters
pic=p['banks']['D'];title=[(v>>shift)&3 for v in pic for shift in (6,4,2,0)]
data=dict(sprites=sprites,types=types,player=['sprite-5428','sprite-54fe','sprite-5601','sprite-56d7'],paths=paths,script=script,chapters=chapters,title=title,sway=list(ram[0x26bf:0x26cf]))
(ROOT/'assets.json').write_text(json.dumps(data,separators=(',',':'))+'\n')
fixtures=[]
for t in specs:
    for initial in [(160,100,0),(120,80,specs[t][2]-1)]:
        cpu=MPU(memory=list(ram));slot=12;cpu.memory[0xc00+slot]=t;cpu.memory[0xc20+slot],cpu.memory[0xc40+slot],cpu.memory[0xca0+slot]=initial;cpu.memory[0xd20a]=7;cpu.memory[0x99]=1
        samples=[]
        for tick in range(100):
            cpu.pc=word(ram,0x2df5+t*2);cpu.x=slot;cpu.sp=255;cpu.stPushWord(0x2fe)
            for _ in range(2000):
                if cpu.pc==0x2b81:break
                if cpu.pc in (0x2a7d,0x2ab1):cpu.pc=(cpu.stPopWord()+1)&65535;continue
                cpu.step()
            else:raise RuntimeError('Handler did not return')
            state=[cpu.memory[0xc20+slot],cpu.memory[0xc40+slot],cpu.memory[0xca0+slot],cpu.memory[0xc00+slot]!=7];samples.append(state)
            if not state[3]:break
        fixtures.append(dict(type=t,initial=initial,samples=samples))
(ROOT/'motion-fixtures.json').write_text(json.dumps(fixtures,separators=(',',':'))+'\n')
print(f'Extracted {len(sprites)} sprites, {len(chapters)} script checkpoints and {sum(len(f["samples"]) for f in fixtures)} CPU motion samples.')
