#!/usr/bin/env python3
"""Mechanical atlas extraction/format conversion; Pillow is used for alpha analysis only."""
from pathlib import Path
from collections import deque
import json,subprocess,hashlib,shutil
from PIL import Image
ROOT=Path(__file__).resolve().parents[2];SRC=ROOT/'art/vbxe-v2/sources';OUT=ROOT/'atari/city/assets/profiles/vbxe-v2';WORK=ROOT/'art/work/native-extract'
OUT.mkdir(parents=True,exist_ok=True);WORK.mkdir(parents=True,exist_ok=True)
def convert(*args):subprocess.run(['convert',*map(str,args)],check=True)
def bounds(file,rect):
 # Main component bounds reject stray pixels from neighboring atlas cells. Read only.
 im=Image.open(file).convert('RGBA').crop(rect);w,h=im.size;mask=im.getchannel('A');raw=mask.tobytes();seen=bytearray(w*h);parts=[]
 for start,a in enumerate(raw):
  if a<128 or seen[start]:continue
  q=[start];seen[start]=1;xs=[];ys=[]
  for pos in q:
   x=pos%w;y=pos//w;xs.append(x);ys.append(y)
   for yy in range(max(0,y-1),min(h,y+2)):
    for xx in range(max(0,x-1),min(w,x+2)):
     n=yy*w+xx
     if not seen[n] and raw[n]>=128:seen[n]=1;q.append(n)
  parts.append((len(q),min(xs),min(ys),max(xs)+1,max(ys)+1))
 if not parts:raise ValueError('Empty atlas cell '+str(rect))
 biggest=max(p[0] for p in parts);parts=[p for p in parts if p[0]>=max(6,biggest*.02)]
 return (min(p[1] for p in parts)+rect[0],min(p[2] for p in parts)+rect[1],max(p[3] for p in parts)+rect[0],max(p[4] for p in parts)+rect[1])
def extract(file,box,dest,w,h,scale=None,flip=False):
 x,y,r,b=box;bw,bh=r-x,b-y
 if scale is None:scale=min((w-2)/bw,(h-2)/bh)
 nw,nh=max(1,round(bw*scale)),max(1,round(bh*scale));tmp=WORK/'cell.png'
 convert(file,'-crop',f'{bw}x{bh}+{x}+{y}','+repage','-channel','A','-threshold','50%','+channel','-filter','Point','-resize',f'{nw}x{nh}!',*(['-flop'] if flip else []),tmp)
 # Center on a shared one-pixel clear bottom baseline; no artistic pixel painting.
 convert('-size',f'{w}x{h}','xc:none',tmp,'-gravity','south','-geometry','+0+1','-composite',dest)
def scene(name,dest,w,h):convert(SRC/(name+'.png'),'-filter','Point','-resize',f'{w}x{h}!','-dither','None','-colors','96',OUT/dest)
scene('city','city-background.png',320,200);scene('map','encounters-background.png',320,200)
im=Image.open(SRC/'battlefields.png');w,h=im.size
for i,name in enumerate(['forest','catacombs','caves','ruins']):
 x=round((i%2)*w/2);y=round((i//2)*h/2);bw=round((i%2+1)*w/2)-x;bh=round((i//2+1)*h/2)-y
 convert(SRC/'battlefields.png','-crop',f'{bw}x{bh}+{x}+{y}','+repage','-filter','Point','-resize','320x128!','-dither','None','-colors','48',OUT/f'battle-{name}.png')
file=SRC/'buildings.png';w,h=Image.open(file).size;ys=[0,347,671,h]
for col,family in enumerate(['barracks','archery','lodge','chapel','tower']):
 for tier in range(3):
  rect=(round(col*w/5),ys[tier],round((col+1)*w/5),ys[tier+1]);box=bounds(file,rect)
  # Genuine upgrade growth, all fifteen share the same base line.
  targetHeight=[43,53,62][tier];scale=min(54/(box[2]-box[0]),targetHeight/(box[3]-box[1]));dest=OUT/f'{family}-{tier+1}.png';extract(file,box,dest,56,64,scale)
  convert(dest,'-dither','None','-colors','24',dest)
sheets=[('heroes',['militia','spearman','swordsman','archer','wizard'],[0,223,449,676,869,1072],False),('enemies_a',['minibeast','wolf','bat','skeleton','zombie','bone-archer','ogre'],[0,176,316,476,673,862,1030,1268],True),('enemies_b',['warlock','imp','beast','dark','demon','sniper'],[0,234,390,573,765,965,1182],True),('mounted',['mounted-scout','mounted-ranger','mounted-cavalry'],[0,281,574,830],False)]
(OUT/'medieval').mkdir(exist_ok=True)
for name,names,ys,flip in sheets:
 file=SRC/(name+'.png');w,h=Image.open(file).size;assert ys[-1]==h
 for row,unit in enumerate(names):
  boxes=[bounds(file,(round(c*w/6),ys[row],round((c+1)*w/6),ys[row+1])) for c in range(6)]
  scale=min(30/max(b[2]-b[0] for b in boxes),26/max(b[3]-b[1] for b in boxes));frames=[]
  for c,box in enumerate(boxes):
   dest=WORK/f'{unit}-{c}.png';extract(file,box,dest,32,28,scale,flip);frames.append(dest)
  # One shared 15-color+transparent palette per six-pose animation row.
  strip=WORK/'strip.png';convert(*frames,'+append','-dither','None','-colors','16',strip)
  for c in range(6):convert(strip,'-crop',f'32x28+{c*32}+0','+repage',OUT/'medieval'/f'{unit}-{c}.png')
  print('Converted',unit)
file=SRC/'obstacles.png';w,h=Image.open(file).size
for col,name in enumerate(['tree','pillar','rock']):
 rect=(round(col*w/3),0,round((col+1)*w/3),h);dest=OUT/f'battle-{name}.png';extract(file,bounds(file,rect),dest,32,28);convert(dest,'-dither','None','-colors','16',dest)
files=[]
for p in sorted(OUT.rglob('*.png')):
 im=Image.open(p).convert('RGBA');pixels=im.getdata();opaque={rgb[:3] for rgb in pixels if rgb[3]>=128};alpha=im.getchannel('A');files.append({'path':str(p.relative_to(OUT)),'size':list(im.size),'opaqueColors':len(opaque),'sha256':hashlib.sha256(p.read_bytes()).hexdigest()})
assert len(files)==150,len(files)
manifest={'profile':'vbxe-v2','nativeResolution':[320,200],'generationTool':'built-in image_gen','sources':'art/vbxe-v2/generation.json','preserves':'Classic assets remain in their original paths; no classic PNG was overwritten.','files':files}
(OUT/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n');print('Prepared',len(files),'native assets in',OUT)
