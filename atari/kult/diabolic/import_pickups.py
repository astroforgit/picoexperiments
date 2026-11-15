#!/usr/bin/env python3
"""Convert the generated five-cell pickup sheet into native monochrome icons."""
import json
from pathlib import Path
from PIL import Image,ImageDraw
ROOT=Path(__file__).resolve().parent
im=Image.open(ROOT/'art/pickups-redesigned-sheet.png').convert('L');items=[]
preview=Image.new('RGB',(640,128),'black');d=ImageDraw.Draw(preview)
for i,name in enumerate(['Weapon 1','Weapon 2','Weapon 3','Weapon 4','Shield']):
 cell=im.crop((round(i*im.width/5),0,round((i+1)*im.width/5),im.height)).point(lambda p:255 if p>=128 else 0)
 cell=cell.crop(cell.getbbox());scale=min(16/cell.width,16/cell.height)
 cell=cell.resize((round(cell.width*scale),round(cell.height*scale)),Image.Resampling.BOX).point(lambda p:255 if p>=100 else 0)
 icon=Image.new('1',(16,16));icon.paste(cell,((16-cell.width)//2,(16-cell.height)//2))
 frame=[int(p>0) for p in icon.getdata()]
 items.append(dict(name=name,width=16,height=16,frames=[frame]*4,id=f'pickup-{i}',source='image-model'))
 preview.paste(icon.resize((80,80),Image.Resampling.NEAREST),(i*128+24,8));d.text((i*128+30,100),name,fill='white')
(ROOT/'art/pickups.json').write_text(json.dumps(items,separators=(',',':'))+'\n');preview.save(ROOT/'art/pickups-native.png')
