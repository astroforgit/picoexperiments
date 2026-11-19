"""Native 256x32 bottom panel; compact 3x5 lettering and selected-weapon dots."""
from PIL import Image,ImageDraw
from pathlib import Path
ROOT=Path(__file__).resolve().parent
FONT={'S':['111','100','111','001','111'],'C':['111','100','100','100','111'],'O':['111','101','101','101','111'],'R':['110','101','110','101','101'],'E':['111','100','110','100','111'],'T':['111','010','010','010','010'],'A':['010','101','111','101','101'],'G':['111','100','101','101','111'],'B':['110','101','110','101','110']}
def packed(im):
 return bytes(sum(int(im.getpixel((x+i,y)))<<(7-i) for i in range(8)) for y in range(im.height) for x in range(0,im.width,8))
def build_hud(ram, write_patterns=True):
 im=Image.new('1',(256,32));d=ImageDraw.Draw(im);d.rectangle((0,0,255,31),outline=1)
 def label(x,y,text):
  for letter in text:
   for dy,row in enumerate(FONT.get(letter,['000']*5)):
    for dx,b in enumerate(row):
     if b=='1':d.point((x+dx,y+dy),fill=1)
   x+=4
 label(80,4,'SCORE');label(80,23,'STAGE');label(160,23,'BOSS')
 # Compact twin-engine ship, distinct from the old helicopter and line icons.
 d.polygon([(16,8),(23,10),(30,14),(37,16),(30,18),(23,22),(16,24),(20,18),(14,18),(14,14),(20,14)],fill=1)
 d.line((23,15,31,16),fill=0);d.line((23,17,29,17),fill=0)
 # Four aligned counters: lives, bombs, shields, clocks.
 d.polygon([(129,4),(134,6),(140,8),(134,10),(129,11),(131,8)],fill=1)
 d.ellipse((161,6,168,12),outline=1);d.line((166,6,166,3,169,3),fill=1)
 d.line((193,4,201,4,201,8,197,12,193,8,193,4),fill=1)
 d.ellipse((225,3,234,12),outline=1);d.line((229,5,229,8,232,8),fill=1)
 ram[0x6684:0x6a84]=packed(im)
 patterns=[]
 for mode in range(4):
  shot=Image.new('1',(16,16));draw=ImageDraw.Draw(shot)
  lanes=[(8,), (4,11), (2,8,14), (1,5,10,14)][mode]
  for y in lanes:
   for x in (2,7,12):draw.point((x,y),fill=1)
  patterns.append(packed(shot))
 if write_patterns:(ROOT/'hud-patterns.bin').write_bytes(b''.join(patterns))
 return im
