from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import math
from scene_model import load_scene, apply_stamps
ROOT=Path(__file__).resolve().parents[1]
# Static art is generated separately. Only palette/resolution conversion here.
im=Image.open(ROOT/'assets/background-float-art.png').convert('RGB').resize((320,240),Image.Resampling.LANCZOS)
q=im.quantize(colors=246,method=Image.Quantize.MEDIANCUT)
palette=[0,0,0]+[v&254 for v in q.getpalette()[:246*3]]
# Reserve two warm window colours without changing the existing sprite indices.
palette += [106,62,26, 218,158,74]
palette += [12,18,36, 246,218,138, 152,174,214, 250,244,210, 6,8,14, 46,52,70, 230,100,92]
assert len(palette)==768
bg=Image.frombytes('P',(320,240),bytes(x+1 for x in q.tobytes()));bg.putpalette(palette)
# Interface and bitmap glyphs are game graphics, not edits to the illustration.
d=ImageDraw.Draw(bg);d.rectangle((0,0,319,12),fill=249);d.rectangle((0,226,319,239),fill=249)
font=ImageFont.load_default(size=9)
d.text((5,1),'STAR FISHER',font=font,fill=250)
d.text((5,228),'HOLD: CAST   TAP A/FIRE: REEL   R: RESET',font=font,fill=251)
d.text((114,2),'STARS',font=font,fill=251)
d.text((159,2),'/',font=font,fill=251)
d.text((183,2),'CASTS',font=font,fill=251)
d.text((241,2),'POWER',font=font,fill=251)
bg.save(ROOT/'assets/editor-base.png')
scene=load_scene(palette)
apply_stamps(bg,scene)
bg.save(ROOT/'assets/background-320x240.png')
vram=bytearray(0x13000);vram[:76800]=bg.tobytes()
(ROOT/'assets/vram.bin').write_bytes(vram)
(ROOT/'gen/loads.asm').write_text(''.join(f"        org $a000\n        ins 'assets/vram.bin',{i},4096\n        ini upload_bank\n" for i in range(0,len(vram),4096)))
lines=[]
for k in range(3):lines.append(f'palette_{k}\n        dta '+','.join(map(str,palette[k::3])))
# Bresenham points for three cast strengths, 24 poses each, all coordinates <256.
def line(a,b):
 x,y=a;xx,yy=b;dx=abs(xx-x);sx=1 if x<xx else -1;dy=-abs(yy-y);sy=1 if y<yy else -1;err=dx+dy;out=[]
 while True:
  out.append((x,y))
  if (x,y)==(xx,yy):return out
  e=2*err
  if e>=dy:err+=dy;x+=sx
  if e<=dx:err+=dx;y+=sy
frames=[];hooks=[];rods=[]
for power in range(3):
 for f in range(24):
  hand=(242,159)
  if f<4:
   tip=(185+f*20,92-f*3);hook=(tip[0]-4,tip[1]+43)
  else:
   t=(f-4)/19
   tip=(round(245-79*min(t*4,1)),round(83-4*math.sin(t*math.pi)))
   hook=(round(245-(90+power*55)*t),round(138-(55+power*10)*math.sin(t*math.pi*.7)))
  # A gently bent long rod, shared between the three casting distances.
  control=(round((hand[0]+tip[0])/2+7),round((hand[1]+tip[1])/2-7))
  curve=[]
  for n in range(17):
   u=n/16
   point=(round((1-u)**2*hand[0]+2*(1-u)*u*control[0]+u*u*tip[0]),
          round((1-u)**2*hand[1]+2*(1-u)*u*control[1]+u*u*tip[1]))
   if curve:curve.extend(line(curve[-1],point)[1:])
   else:curve.append(point)
  if power==0:rods.append(list(dict.fromkeys(y*320+x for x,y in curve)))
  offsets=list(dict.fromkeys(y*320+x for x,y in line(tip,hook)[1:]))
  frames.append(offsets);hooks.append(hook)
lines+=['pose_lo\n        dta '+','.join(f'<pose_{i}' for i in range(72)),'pose_hi\n        dta '+','.join(f'>pose_{i}' for i in range(72))]
lines+=['rod_lo\n        dta '+','.join(f'<rod_{i}' for i in range(24)),'rod_hi\n        dta '+','.join(f'>rod_{i}' for i in range(24))]
for k,label in enumerate(['hook_x_table','hook_y_table']):lines.append(label+'\n        dta '+','.join(str(p[k]) for p in hooks))
for prefix,poses in [('pose',frames),('rod',rods)]:
 for i,offsets in enumerate(poses):
  assert all(0<=o<64000 for o in offsets)
  lines.append(f'{prefix}_{i}\n        dta '+','.join(f'a({o})' for o in offsets)+',a($ffff)')
# The editor selects the exact mask used by native blinking and flying stars.
star_design=next(a for a in scene['assets'] if a['id']==scene['gameStar'])
star_pixels=[(i%star_design['width']-star_design['width']//2,i//star_design['width']-star_design['height']//2) for i,c in enumerate(star_design['pixels']) if c]
lines.append('star_dx\n        dta '+','.join(str(x&255) for x,y in star_pixels))
lines.append('star_dy\n        dta '+','.join(str(y&255) for x,y in star_pixels))
lines.append(f'STAR_PIXELS = {len(star_pixels)}')
# 3x5 digits for score and casts, 1 byte per row (left pixel is bit 2).
digits=['111101101101111','010110010010111','111001111100111','111001111001111','101101111001001','111100111001111','111100111101111','111001001001001','111101111101111','111101111001111']
lines.append('digit_data\n        dta '+','.join(str(int(s[y:y+3],2)) for s in digits for y in range(0,15,3)))
mask=Image.new('1',(320,50));md=ImageDraw.Draw(mask);md.text((96,33),'FIVE STARS!  R: REPLAY',font=font,fill=1)
win=[y*320+x for y in range(50) for x in range(320) if mask.getpixel((x,y))]
lines.append('win_banner\n        dta '+','.join(f'a({o})' for o in win)+',a($ffff)')
statuses=['HOLD A / FIRE','CHARGING','CASTING','REELING','NIGHT COMPLETE','WAIT FOR A BITE','BITE! TAP A / FIRE']
for i,label in enumerate(statuses):
 mask=Image.new('1',(320,32));md=ImageDraw.Draw(mask);md.text((6,16),label,font=font,fill=1)
 coords=[y*320+x for y in range(32) for x in range(320) if mask.getpixel((x,y))]
 lines.append(f'status_{i}\n        dta '+','.join(f'a({o})' for o in coords)+',a($ffff)')
lines.append('status_lo\n        dta '+','.join(f'<status_{i}' for i in range(7)))
lines.append('status_hi\n        dta '+','.join(f'>status_{i}' for i in range(7)))
# Editable masks, modes and initial timers shared with the browser editor.
windows=[w['pixels'] for w in scene['windows']]
lines.append(f'WINDOW_COUNT = {len(windows)}')
lines.append('light_initial\n        dta '+','.join('2' if w['initial'] else '0' for w in scene['windows']))
lines.append('light_delay\n        dta '+','.join(str(w['delay']) for w in scene['windows']))
lines.append('light_modes\n        dta '+','.join(str({'steady':0,'blink':1,'candle':2}[w['mode']]) for w in scene['windows']))
lines.append('window_lo\n        dta '+','.join(f'<window_{i}' for i in range(len(windows))))
lines.append('window_hi\n        dta '+','.join(f'>window_{i}' for i in range(len(windows))))
for i,panes in enumerate(windows):
 data=[]
 for x,y in panes:
  assert 0<=x<320 and 13<=y<226
  offset=y*320+x
  data.extend([offset>>12,offset&255,0x90|((offset>>8)&15)])
 lines.append(f'window_{i}\n        dta '+','.join(map(str,data))+',255')
import json
(ROOT/'assets/windows.json').write_text(json.dumps(windows))
(ROOT/'gen/tables.asm').write_text('\n'.join(lines)+'\n')
print('Assets:',len(frames),'rod poses;',sum(map(len,frames)),'line pixels')
