"""Shared editor/native asset model. All colours are actual VBXE palette indices."""
from pathlib import Path
import json, math, re
from sounds import sound_settings
ROOT=Path(__file__).resolve().parents[1]
PROJECT=ROOT/'editor-scene.json'
SKY_DEFAULTS=dict(onePixelStars=48,twoPixelStars=16,twinklePercent=25,meteorProbability=30)
# Ambient star tone for palette slot 246. Moon and painted tones are the mean
# of the brightest moon pixels in background-night-art.png and of the painted
# stars in background-art.png. Ivory keeps 252 bright and 246 as its dim shade.
STAR_TONES=dict(ivory=[216,210,184],moon=[246,232,204],painted=[246,218,172])
STAR_COLOR_MODES=['ivory','moon','painted','custom']
# New bait scenarios. Legacy `floats` settings are intentionally not reused.
SCENARIOS=[('interest','Gentle interest',70,5,10,10,25),('attack','Aggressive dive',1,80,100,100,10),('nibble','Cautious nibble',8,15,25,25,20),('falseAlarm','False alarm',5,0,0,0,15),('sideTake','Sideways take',2,50,60,60,15),('repeated','Repeated tugging',10,30,50,50,30),('heavySwim','Heavy swimming',8,20,35,35,30)]

def sky_settings(value):
 if value is None:value={}
 if not isinstance(value,dict):raise ValueError('Sky settings must be an object')
 sky={k:integer(value.get(k,v),0,96 if k in ('onePixelStars','twoPixelStars') else 100,k) for k,v in SKY_DEFAULTS.items()}
 sky['starColor']=value.get('starColor','ivory')
 if sky['starColor'] not in STAR_COLOR_MODES:raise ValueError('Star colour must be one of '+', '.join(STAR_COLOR_MODES))
 rgb=value.get('starRgb',[200,220,255])
 if not isinstance(rgb,list) or len(rgb)!=3:raise ValueError('Custom star colour must be three RGB values')
 sky['starRgb']=[integer(c,0,255,'Star RGB') for c in rgb]
 return sky

def star_tone(sky):
 return [c&254 for c in sky['starRgb']] if sky['starColor']=='custom' else STAR_TONES[sky['starColor']]

def star_bright(sky):return 252 if sky['starColor']=='ivory' else 246

def star_dim(sky,palette):
 if sky['starColor']=='ivory':return 246
 target=[c*7//10 for c in star_tone(sky)]
 return min(range(1,246),key=lambda i:sum((palette[i*3+j]-target[j])**2 for j in range(3)))

def fishing_settings(value):
 if value is None:value={}
 if not isinstance(value,dict):raise ValueError('Fishing settings must be an object')
 given=value.get('scenarios',{})
 if not isinstance(given,dict):raise ValueError('Bite scenarios must be an object')
 clean={}
 for id,name,weight,catch,missed,failed,duration in SCENARIOS:
  f=given.get(id,{})
  if not isinstance(f,dict):raise ValueError('Invalid '+name)
  defaults=dict(weight=weight,catch=catch,missedLoss=missed,failedLoss=failed,durationTenths=duration)
  clean[id]={k:integer(f.get(k,v),1 if k=='durationTenths' else 0,100,name+' '+k) for k,v in defaults.items()}
 if not any(f['weight'] for f in clean.values()):raise ValueError('Enable at least one bite scenario')
 lo=integer(value.get('quietMinSeconds',8),1,60,'Minimum quiet seconds')
 hi=integer(value.get('quietMaxSeconds',20),lo,60,'Maximum quiet seconds')
 return dict(diveIntervalSeconds=integer(value.get('diveIntervalSeconds',180),30,600,'Dive interval'),version=2,springGauge=bool(value.get('springGauge',True)),quietMinSeconds=lo,quietMaxSeconds=hi,escalationPercent=integer(value.get('escalationPercent',35),0,100,'Escalation percent'),interestStepPercent=integer(value.get('interestStepPercent',5),0,25,'Interest step'),repeatTakePercent=integer(value.get('repeatTakePercent',60),0,100,'Repeat take chance'),followupSeconds=integer(value.get('followupSeconds',2),1,10,'Follow-up seconds'),scenarios=clean)

def scenario_slots(fishing):
 weights=[fishing['scenarios'][id]['weight'] for id,*_ in SCENARIOS];total=sum(weights)
 counts=[max(1,w*64//total) if w else 0 for w in weights]
 order=sorted(range(len(weights)),key=lambda i:(-(weights[i]*64%total),i))
 while sum(counts)<64:
  for i in order:
   if weights[i] and sum(counts)<64:counts[i]+=1
 while sum(counts)>64:counts[max(range(len(counts)),key=lambda i:(counts[i],-i))]-=1
 return [i+1 for i,n in enumerate(counts) for _ in range(n)]

def starfield(scene):
 settings=sky_settings(scene.get('sky'));state=271828;points=[];used=set()
 assets={a['id']:a for a in scene.get('assets',[])}
 for stamp in scene.get('stamps',[]):
  a=assets[stamp['assetId']]
  used.update((stamp['x']+i%a['width'],stamp['y']+i//a['width']) for i,c in enumerate(a['pixels']) if c)
 def rand():
  nonlocal state
  state=(state*1664525+1013904223)&0xffffffff
  return state>>8
 for size,key in [(1,'onePixelStars'),(2,'twoPixelStars')]:
  for _ in range(settings[key]):
   for attempt in range(10000):
    x=8+rand()%303;y=32+rand()%102
    if 81<=x<=104 and y<=46:continue
    cells={(xx,yy) for xx in range(x-1,x+size+1) for yy in range(y-1,y+2)}
    if not cells&used:break
   else:raise ValueError('Not enough clear sky for this many stars; reduce counts or remove sky objects')
   used.update((x+j,y) for j in range(size))
   points.append(dict(x=x,y=y,size=size,phase=rand()%8,twinkle=False))
 order=list(range(len(points)))
 for i in range(len(order)-1,0,-1):
  j=rand()%(i+1);order[i],order[j]=order[j],order[i]
 for i in order[:(len(points)*settings['twinklePercent']+50)//100]:points[i]['twinkle']=True
 return points

def apply_starfield(image,scene):
 color=star_bright(sky_settings(scene.get('sky')))
 for p in starfield(scene):
  for j in range(p['size']):image.putpixel((p['x']+j,p['y']),color)

def library(palette):
 def nearest(rgb):return min(range(1,246),key=lambda i:sum((palette[i*3+j]-rgb[j])**2 for j in range(3)))
 blue=nearest((56,68,100));dust=nearest((88,86,112));shadow=nearest((12,16,26))
 result=[]
 def add(id,name,category,rows,colors):
  w=max(map(len,rows));pixels=[colors.get(c,0) for row in rows for c in row.ljust(w,'.')]
  result.append(dict(id=id,name=name,category=category,width=w,height=len(rows),pixels=pixels))
 add('star-pin','Two-pixel glint','stars',['ab'],{'a':252,'b':250})
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
 windows=json.loads((ROOT/'assets/default-windows.json').read_text())
 return dict(version=1,assets=library(palette),gameStar='star-pin',stamps=[],windows=windows,sky=sky_settings({}),fishing=fishing_settings({}),sound=sound_settings({}))

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
 return dict(version=1,assets=clean_assets,windows=clean_windows,stamps=clean_stamps,gameStar=star['id'],sky=sky_settings(scene.get('sky')),fishing=fishing_settings(scene.get('fishing')),sound=sound_settings(scene.get('sound')))

def load_scene(palette):
 return validate(json.loads(PROJECT.read_text()) if PROJECT.exists() else default_scene(palette))

def apply_stamps(image,scene):
 assets={a['id']:a for a in scene['assets']}
 for stamp in scene['stamps']:
  a=assets[stamp['assetId']]
  for i,c in enumerate(a['pixels']):
   if c:image.putpixel((stamp['x']+i%a['width'],stamp['y']+i//a['width']),c)
