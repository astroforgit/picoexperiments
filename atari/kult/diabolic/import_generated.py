#!/usr/bin/env python3
"""Convert the generated design sheet into fixed-size native 1-bit sprite data."""
import json
from pathlib import Path
from PIL import Image
from build import ship
ROOT=Path(__file__).resolve().parent
im=Image.open(ROOT/'art/generated-sprite-sheet.png').convert('L')
w,h=im.size
names=['Horned interceptor','Arrow fighter','Twin-engine fighter','Armoured scout','Orbit sentinel','Wing drone','Armoured beetle','Spiked watcher']
items=[]
for row,name in enumerate(names):
    cells=[im.crop((round(col*w/4),round(row*h/8),round((col+1)*w/4),round((row+1)*h/8))) for col in range(4)]
    bounds=[cell.point(lambda p:255 if p>120 else 0).getbbox() for cell in cells]
    box=(min(b[0] for b in bounds),min(b[1] for b in bounds),max(b[2] for b in bounds),max(b[3] for b in bounds))
    width,height=(40,16) if row<4 else (16,16)
    frames=[]
    for cell in cells:
        crop=cell.crop(box);scale=min((width-2)/crop.width,(height-2)/crop.height)
        crop=crop.resize((max(1,round(crop.width*scale)),max(1,round(crop.height*scale))),Image.Resampling.BOX)
        frame=Image.new('L',(width,height));frame.paste(crop,((width-crop.width)//2,(height-crop.height)//2))
        frames.append([int(p>=85) for p in frame.getdata()])
    items.append(dict(id=('ship-' if row<4 else 'enemy-')+str(row%4),name=name,width=width,height=height,frames=frames,source='image-model'))
items.insert(0,dict(id='diabolic',name='Diabolic (current ship)',width=40,height=16,frames=[[int(p) for p in ship(f).getdata()] for f in range(4)],source='original-reskin'))
(ROOT/'art/designs.json').write_text(json.dumps(items,separators=(',',':'))+'\n')
print('Converted generated art into 4 animated ships and 4 animated enemies; retained Diabolic.')
