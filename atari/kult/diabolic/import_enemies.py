#!/usr/bin/env python3
"""Extract the user-supplied enemy sheet into native four-frame 16x16 sprites."""
import json
from pathlib import Path
from PIL import Image, ImageDraw
ROOT = Path(__file__).resolve().parent
# Explicit cells exclude neighbouring sprites and the sheet's caption.
ROWS = [
    ([(14,14,84,83),(86,14,158,83),(159,10,233,84),(234,11,307,83),(310,10,373,87),
      (374,17,454,115),(455,9,548,91),(549,11,620,99),(638,8,705,100),(713,7,779,104),(780,8,861,97)],
     ['Scarab','Crown bug','Longleg','Hornet','Tentacle','Teardrop fighter','Scout saucer','Diamond drone','Armoured rocket','Needle fighter','Trident fighter']),
    ([(15,97,82,164),(83,91,163,165),(164,92,237,164),(239,90,323,163),(324,95,393,166),
      (440,92,522,176),(541,94,601,176),(602,83,664,166),(667,90,763,177),(765,96,841,177)],
     ['Claw bug','Hooded drone','Mask bug','Watcher','Blade bug','Arrow rocket','Double-wing fighter','Light rocket','Heavy interceptor','Star fighter']),
    ([(10,175,84,247),(84,175,151,246),(153,174,222,248),(223,173,294,248),(295,174,368,248),
      (369,134,478,251),(480,176,571,253),(574,175,663,255),(673,174,777,252),(780,164,859,250)],
     ['Spider','Crab','Ant','Jellyfish','Mantis','Twin-fin fighter','Bell saucer','Triangle saucer','Walker saucer','Shuttle'])
]
image = Image.open(ROOT.parent/'enemys.webp').convert('L')
items=[]
for row,(boxes,names) in enumerate(ROWS):
    for col,(box,name) in enumerate(zip(boxes,names)):
        crop=image.crop(box).point(lambda p:255 if p<125 else 0)
        crop=crop.crop(crop.getbbox())
        # Bugs and saucers stay upright; rockets point into right-to-left flight.
        rotate=(row==0 and col in (5,7,8,9,10)) or (row==1 and col>=5) or (row==2 and col in (5,9))
        if rotate:crop=crop.transpose(Image.Transpose.ROTATE_90)
        scale=min(14/crop.width,14/crop.height)
        crop=crop.resize((max(1,round(crop.width*scale)),max(1,round(crop.height*scale))),Image.Resampling.BOX).point(lambda p:255 if p>=100 else 0)
        base=Image.new('L',(16,16));base.paste(crop,((16-crop.width)//2,(16-crop.height)//2))
        frames=[]
        for f in range(4):
            frame=base.copy()
            if rotate:
                # Rear exhaust flickers, without moving the hull or hit box.
                end=(16-crop.width)//2+crop.width
                for x in range(end,min(16,end+(1,2,1,0)[f])):frame.putpixel((x,8),255)
            else:
                # Animate the central light; preserve the creature's silhouette.
                if f in (1,2):
                    for x in (7,8):frame.putpixel((x,7),255-base.getpixel((x,7)))
            frames.append([int(p>0) for p in frame.getdata()])
        items.append(dict(id=f'sheet-{len(items):02}',name=f'Sheet · {name}',width=16,height=16,
                          frames=frames,source='enemys.webp',crop=list(box),rotation=90 if rotate else 0))
(ROOT/'art/imported-enemies.json').write_text(json.dumps(items,separators=(',',':'))+'\n')
preview=Image.new('RGB',(8*112,4*112),'#101018');draw=ImageDraw.Draw(preview)
for i,item in enumerate(items):
    sprite=Image.new('L',(16,16));sprite.putdata([p*255 for p in item['frames'][0]])
    x,y=(i%8)*112,(i//8)*112
    preview.paste(sprite.resize((64,64),Image.Resampling.NEAREST),(x+24,y+6))
    draw.text((x+4,y+76),item['name'].split(' · ')[1],fill='white')
    draw.text((x+4,y+91),item['id'],fill='#aaaaaa')
preview.save(ROOT/'art/imported-enemies.png')
print(f'Imported {len(items)} animated enemies.')
