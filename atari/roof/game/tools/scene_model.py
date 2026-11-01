"""Shared editor/native asset model. All colours are actual VBXE palette indices."""
from pathlib import Path
import json, math, re
ROOT=Path(__file__).resolve().parents[1]
PROJECT=ROOT/'editor-scene.json'
DEFAULT_WINDOWS=[
 [[x,y] for x in (265,267) for y in (214,215,216,217,220,221,222,223)],
 [[x,y] for x in (107,109) for y in (204,205,206,208,209,210)],
 [[98,185],[98,186]],[[134,189],[134,190]],[[122,194],[122,195]],[[161,193],[161,194]]]
def library(palette):
 def nearest(rgb):return min(range(1,247),key=lambda i:sum((palette[i*3+j]-rgb[j])**2 for j in range(3)))
 blue=nearest((56,68,100));dust=nearest((88,86,112));shadow=nearest((12,16,26))
 result=[]
 def add(id,name,category,rows,colors):
  w=max(map(len,rows));pixels=[colors.get(c,0) for row in rows for c in row.ljust(w,'.')]
  result.append(dict(id=id,name=name,category=category,width=w,height=len(rows),pixels=pixels))
 add('star-petite','Petite five-point','stars',['..a..','aaaaa','.aaa.','.a.a.','a...a'],{'a':250})
 add('star-fine','Fine seven-pixel','stars',['...a...','...a...','aaaaaaa','.aaaaa.','..aaa..','.aa.aa.','.a...a.'],{'a':252})
 add('star-pin','Two-pixel glint','stars',['ab','b.'],{'a':252,'b':250})
 add('star-dust','Single starlight','stars',['a'],{'a':252})
 add('comet-silver','Silver traveller','comets',['b............','..b..........','....bb.......','......bbbb...','........bbwaa','..........aaa'],{'b':blue,'w':251,'a':252})
 add('comet-gold','Golden trail','comets',['b.....................','..b...................','....b.b...............','.......bbbb...........','.........bbbbbbb......','.............bbwwaaa..','................aaaaa.','.................aaa..'],{'b':dust,'w':250,'a':252})
 for kind in ['crescent','full','eclipse']:
  size=13 if kind=='crescent' else 11;p=[]
  for y in range(size):
   for x in range(size):
    r=(size-1)/2;inside=(x-r)**2+(y-r)**2<=r*r
    cut=kind!='full' and (x-r-3)**2+(y-r+1)**2<=(r-0.6)**2
    p.append((252 if (x+y)%4 else 251) if inside and not cut else 0)
  result.append(dict(id='moon-'+kind,name={'crescent':'Slim crescent','full':'Ivory moon','eclipse':'Shadow moon'}[kind],category='moons',width=size,height=size,pixels=p))
 for kind in ['spiral','mist']:
  w,h=35,13;p=[0]*(w*h)
  for y in range(h):
   for x in range(w):
    xx=(x-17)/16;yy=(y-6)/5
    if xx*xx+yy*yy<1 and (x*7+y*13)%7<3:
     p[y*w+x]=dust if abs(xx)<.3 and abs(yy)<.3 else blue
    if kind=='spiral' and abs(yy-.35*math.sin(xx*5))<.13 and abs(xx)<.85:p[y*w+x]=251 if abs(xx)<.15 else dust
  result.append(dict(id='galaxy-'+kind,name='Distant spiral' if kind=='spiral' else 'Stardust mist',category='galaxies',width=w,height=h,pixels=p))
 # A dark cloud stamp is a composition option; placed objects are baked into the scene.
 w,h=40,12;p=[]
 for y in range(h):
  for x in range(w):
   inside=any(((x-cx)/rx)**2+((y-cy)/ry)**2<1 for cx,cy,rx,ry in [(10,7,10,4),(21,5,12,5),(31,8,9,3)])
   p.append(shadow if inside and (x+y)%7 else 0)
 result.append(dict(id='cloud-wisp',name='Dark night wisp',category='clouds',width=w,height=h,pixels=p))
 return result

def default_scene(palette):
 return dict(version=1,assets=library(palette),gameStar='star-petite',stamps=[],windows=[dict(name=['Near dormer','Left dormer','Far window 1','Far window 2','Far window 3','Far window 4'][i],pixels=p,mode='candle' if i==0 else 'blink',initial=i in (0,1,3,5),delay=[80,132,45,190,112,160][i]) for i,p in enumerate(DEFAULT_WINDOWS)])

def integer(n,lo,hi,label):
 if type(n)!=int or not lo<=n<=hi:raise ValueError(f'{label} must be an integer from {lo} to {hi}')
 return n

def validate(scene):
 if not isinstance(scene,dict) or scene.get('version')!=1:raise ValueError('Expected a version 1 Star Fisher project')
 assets=scene.get('assets');windows=scene.get('windows');stamps=scene.get('stamps')
 if not isinstance(assets,list) or not 1<=len(assets)<=32:raise ValueError('Use 1–32 sprite designs')
 ids=set();clean_assets=[]
 for a in assets:
  if not isinstance(a,dict):raise ValueError('Invalid sprite')
  id=a.get('id','')
  if not isinstance(id,str) or not re.fullmatch(r'[a-zA-Z0-9_-]{1,48}',id) or id in ids:raise ValueError('Sprite IDs must be unique safe names')
  ids.add(id);w=integer(a.get('width'),1,64,'Sprite width');h=integer(a.get('height'),1,32,'Sprite height')
  pix=a.get('pixels')
  if not isinstance(pix,list) or len(pix)!=w*h:raise ValueError('Sprite dimensions do not match its pixels')
  pix=[integer(v,0,255,'Palette index') for v in pix]
  category=a.get('category')
  if category not in ['stars','comets','moons','galaxies','clouds']:raise ValueError('Invalid sprite category')
  clean_assets.append(dict(id=id,name=str(a.get('name',id))[:60],category=category,width=w,height=h,pixels=pix))
 byid={a['id']:a for a in clean_assets};star=byid.get(scene.get('gameStar'))
 if not star or star['category']!='stars' or star['width']>9 or star['height']>9 or not any(star['pixels']):raise ValueError('Gameplay star must have visible pixels and fit within 9 × 9')
 if not isinstance(windows,list) or not 1<=len(windows)<=16:raise ValueError('Use 1–16 window groups')
 clean_windows=[];total=0;occupied=set()
 for win in windows:
  if not isinstance(win,dict) or not isinstance(win.get('pixels'),list):raise ValueError('Invalid window group')
  pixels=[];seen=set()
  for point in win['pixels']:
   if not isinstance(point,list) or len(point)!=2:raise ValueError('Invalid window pixel')
   x=integer(point[0],0,319,'Window X');y=integer(point[1],13,225,'Window Y')
   if (x,y) in seen:continue
   if (x,y) in occupied:raise ValueError('A light pixel cannot belong to two window groups')
   seen.add((x,y));pixels.append([x,y])
  occupied.update(seen);total+=len(pixels)
  if win.get('mode') not in ['steady','blink','candle']:raise ValueError('Invalid window lighting mode')
  clean_windows.append(dict(name=str(win.get('name','Window'))[:60],pixels=pixels,mode=win['mode'],initial=bool(win.get('initial',True)),delay=integer(win.get('delay',80),32,255,'Light delay')))
 if total>512:raise ValueError('Window lights can use at most 512 pixels in total')
 if not isinstance(stamps,list) or len(stamps)>64:raise ValueError('Use at most 64 placed objects')
 clean_stamps=[];stamp_ids=set()
 for stamp in stamps:
  if not isinstance(stamp,dict) or stamp.get('assetId') not in byid:raise ValueError('Placed object refers to a missing sprite')
  a=byid[stamp['assetId']];id=stamp.get('id')
  if not isinstance(id,str) or len(id)>64 or id in stamp_ids:raise ValueError('Placed object IDs must be unique')
  stamp_ids.add(id)
  clean_stamps.append(dict(id=id,assetId=a['id'],x=integer(stamp.get('x'),0,320-a['width'],'Object X'),y=integer(stamp.get('y'),13,226-a['height'],'Object Y')))
 return dict(version=1,assets=clean_assets,windows=clean_windows,stamps=clean_stamps,gameStar=star['id'])

def load_scene(palette):
 return validate(json.loads(PROJECT.read_text()) if PROJECT.exists() else default_scene(palette))

def apply_stamps(image,scene):
 assets={a['id']:a for a in scene['assets']}
 for stamp in scene['stamps']:
  a=assets[stamp['assetId']]
  for i,c in enumerate(a['pixels']):
   if c:image.putpixel((stamp['x']+i%a['width'],stamp['y']+i//a['width']),c)
