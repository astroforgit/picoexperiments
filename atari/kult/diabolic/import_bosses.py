#!/usr/bin/env python3
"""Convert the model's four-by-four atlas to shared 64x64 1-bit boss resources."""
import json
from pathlib import Path
from PIL import Image,ImageDraw
ROOT=Path(__file__).resolve().parent
def main():
 atlas=Image.open(ROOT/'art/bosses/candidates-sheet.png').convert('L');w,h=atlas.size
 bosses=[]
 for row,(slug,name) in enumerate([('bone-dragon','Bone dragon'),('iron-manta','Iron manta'),('void-kraken','Void kraken'),('insect-queen','Insect queen')]):
  frames=[]
  for col in range(4):
   # Fixed grid crops and uniform scaling preserve model-authored motion.
   crop=atlas.crop((col*w//4,row*h//4,(col+1)*w//4,(row+1)*h//4))
   frame=crop.resize((64,64),Image.Resampling.BOX).point(lambda v:255 if v>=110 else 0)
   frames.append([int(v>0) for v in frame.getdata()])
  bosses.append(dict(id='boss-'+slug,name=name,source='Image model / native conversion',width=64,height=64,frames=frames))
 (ROOT/'art/bosses/catalog.json').write_text(json.dumps(bosses,separators=(',',':'))+'\n')
 preview=Image.new('RGB',(4*192,4*218),(10,12,16));draw=ImageDraw.Draw(preview)
 for row,b in enumerate(bosses):
  draw.text((8,row*218+5),b['name'],fill='white')
  for col,pixels in enumerate(b['frames']):
   frame=Image.new('L',(64,64));frame.putdata([v*235 for v in pixels]);preview.paste(frame.resize((192,192),Image.Resampling.NEAREST),(col*192,row*218+24))
 preview.save(ROOT/'art/bosses/native-preview.png')
 print('Imported four model-designed four-frame bosses.')
if __name__=='__main__':main()
