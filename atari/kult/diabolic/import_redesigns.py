#!/usr/bin/env python3
"""Convert the image model's 8x4 reference redesign into native sprite frames."""
import json
from pathlib import Path
from PIL import Image, ImageDraw
ROOT=Path(__file__).resolve().parent
names=['Rotor drone','Interceptor','Devourer','Scout drone','Delta fighter','Orbital escort','Horned sentinel','Arrow fighter','Star cluster','Alien mask','Razor fighter','Orb quartet','Star sentinel','Heavy drone','Crater meteor','Spiked mine','Horned crawler','Orbital ring','Blade fighter','Skull hunter','Comet drone','Escort quartet','Pulse star','Triple probe','Orb carrier','Space serpent','Sun mine','Rotary blade','Twin crescents','Armoured orb','Twin-pod fighter','Diamond swarm']
im=Image.open(ROOT/'art/redesigned-enemies-sheet.png').convert('L')
items=[]
for i,name in enumerate(names):
    col,row=i%8,i//8
    cell=im.crop((round(col*im.width/8),round(row*im.height/4),round((col+1)*im.width/8),round((row+1)*im.height/4)))
    cell=cell.point(lambda p:255 if p>=128 else 0)
    cell=cell.crop(cell.getbbox())
    if i==30:cell=cell.transpose(Image.Transpose.ROTATE_90)
    scale=min(14/cell.width,14/cell.height)
    cell=cell.resize((max(1,round(cell.width*scale)),max(1,round(cell.height*scale))),Image.Resampling.BOX).point(lambda p:255 if p>=110 else 0)
    base=Image.new('L',(16,16));base.paste(cell,((16-cell.width)//2,(16-cell.height)//2))
    frames=[]
    aircraft=i in (0,1,3,4,7,10,13,18,30)
    for f in range(4):
        frame=base.copy()
        if aircraft:
            end=(16-cell.width)//2+cell.width
            for x in range(end,min(16,end+(1,2,1,0)[f])):frame.putpixel((x,8),255)
        else:
            # Pulse a small interior light, retaining the generated outline.
            if f in (1,2):
                for x in (7,8):frame.putpixel((x,8),255-base.getpixel((x,8)))
        frames.append([int(p>0) for p in frame.getdata()])
    items.append(dict(id=f'redesign-{i}',name=f'Redesigned {i+1:02} · {name}',width=16,height=16,frames=frames,source='original-redesign',original=f'original-{i}'))
(ROOT/'art/redesigned-enemies.json').write_text(json.dumps(items,separators=(',',':'))+'\n')
preview=Image.new('RGB',(1024,512),'black');draw=ImageDraw.Draw(preview)
for i,a in enumerate(items):
    cell=Image.new('L',(16,16));cell.putdata([p*255 for p in a['frames'][0]])
    x,y=i%8*128,i//8*128;preview.paste(cell.resize((96,96),Image.Resampling.NEAREST),(x+16,y+8));draw.text((x+56,y+112),f'{i+1:02}',fill='#aaa')
preview.save(ROOT/'art/redesigned-enemies-native.png')
print('Converted 32 redesigns to animated native sprites.')
