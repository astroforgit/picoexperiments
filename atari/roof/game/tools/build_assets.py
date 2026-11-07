from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import math
from bobbers import build_popup, tables as bobber_tables
from sounds import asm_tables as sound_tables
from scene_model import load_scene, apply_stamps, apply_starfield, starfield, star_tone, star_bright, star_dim, scenario_slots, SCENARIOS
ROOT=Path(__file__).resolve().parents[1]
# Static art is generated separately. Only palette/resolution conversion here.
im=Image.open(ROOT/'assets/background-night-art.png').convert('RGB').resize((320,240),Image.Resampling.LANCZOS)
q=im.quantize(colors=245,method=Image.Quantize.MEDIANCUT)
palette=[0,0,0]+[v&254 for v in q.getpalette()[:246*3]]
palette[246*3:247*3]=[216,210,184] # gentle ivory twinkle shade
# Reserve two warm window colours without changing the existing sprite indices.
palette += [106,62,26, 218,158,74]
palette += [12,18,36, 246,218,138, 152,174,214, 250,244,210, 6,8,14, 46,52,70, 230,100,92]
assert len(palette)==768
bg=Image.frombytes('P',(320,240),bytes(x+1 for x in q.tobytes()));bg.putpalette(palette)
# Interface and bitmap glyphs are game graphics, not edits to the illustration.
d=ImageDraw.Draw(bg);d.rectangle((0,0,319,12),fill=249)
font=ImageFont.load_default(size=9)
d.text((5,1),'M - MENU',font=font,fill=251)
scene=load_scene(palette)
# Slot 246 carries the selected ambient star tone (ivory keeps its dim shade).
palette[246*3:247*3]=star_tone(scene['sky']);bg.putpalette(palette)
bg.save(ROOT/'assets/editor-base.png')
apply_starfield(bg,scene)
apply_stamps(bg,scene)
bg.save(ROOT/'assets/background-320x240.png')
vram=bytearray(0x20000);vram[:76800]=bg.tobytes()
# Native transparent cloud sprite, 160x40, at VRAM $14000. Opaque centre
# hides stars; ragged transparent edges keep the grainy night-art style.
def nearest(rgb):return min(range(1,246),key=lambda i:sum((palette[i*3+j]-rgb[j])**2 for j in range(3)))
cloud_colors=[nearest(rgb) for rgb in [(8,11,19),(11,15,25),(14,19,31)]]
for y in range(40):
 for x in range(160):
  xx=x*.6;yy=y*.6
  density=max(1-((xx-cx)/rx)**2-((yy-cy)/ry)**2 for cx,cy,rx,ry in [(22,15,22,7),(44,11,29,10),(69,14,26,8)])
  density += .12*math.sin(xx*.37+yy*.6)+.09*math.sin(xx*.81-yy*.4)
  grain=(x*17+y*29)%11
  if density>0 and (density>.55 or grain<density*18):
   vram[0x14000+y*160+x]=cloud_colors[0 if density>.55 else 1 if grain<7 else 2]
popup=build_popup(palette)
vram[0x16000:0x16000+240*164]=popup.tobytes()
(ROOT/'assets/vram.bin').write_bytes(vram)
(ROOT/'gen/loads.asm').write_text(''.join(f"        org $a000\n        ins 'assets/vram.bin',{i},4096\n        ini upload_bank\n" for i in range(0,len(vram),4096)))
lines=bobber_tables()
field=starfield(scene)
lines.append(f'STARFIELD_COUNT = {len(field)}')
lines.append(f'METEOR_THRESHOLD = {scene["sky"]["meteorProbability"]*255//100}')
lines.append(f'STAR_BRIGHT = {star_bright(scene["sky"])}')
lines.append(f'STAR_DIM = {star_dim(scene["sky"],palette)}')
for label,values in [('field_lo',[(p['y']*320+p['x'])&255 for p in field]),('field_hi',[(p['y']*320+p['x'])>>8 for p in field]),('field_flags',[(p['size']-1)|(2 if p['twinkle'] else 0) for p in field]),('field_phase',[p['phase'] for p in field])]:
 lines.append(label+'\n        dta '+','.join(map(str,values or [0])))
for k in range(3):lines.append(f'palette_{k}\n        dta '+','.join(map(str,palette[k::3])))
# Rod poses: 4 wind-up frames, then the forward swing that settles by frame 9.
# The line and float are drawn at runtime from the rod tip.
def line(a,b):
 x,y=a;xx,yy=b;dx=abs(xx-x);sx=1 if x<xx else -1;dy=-abs(yy-y);sy=1 if y<yy else -1;err=dx+dy;out=[]
 while True:
  out.append((x,y))
  if (x,y)==(xx,yy):return out
  e=2*err
  if e>=dy:err+=dy;x+=sx
  if e<=dx:err+=dx;y+=sy
rods=[];tips=[]
for f in range(24):
 hand=(242,159)
 if f<4:tip=(185+f*20,92-f*3)
 else:
  t=(f-4)/19
  tip=(round(245-79*min(t*4,1)),round(83-4*math.sin(t*math.pi)))
 control=(round((hand[0]+tip[0])/2+7),round((hand[1]+tip[1])/2-7))
 curve=[]
 for n in range(17):
  u=n/16
  point=(round((1-u)**2*hand[0]+2*(1-u)*u*control[0]+u*u*tip[0]),
         round((1-u)**2*hand[1]+2*(1-u)*u*control[1]+u*u*tip[1]))
  if curve:curve.extend(line(curve[-1],point)[1:])
  else:curve.append(point)
 rods.append(list(dict.fromkeys(y*320+x for x,y in curve)));tips.append(tip)
lines+=['rod_lo\n        dta '+','.join(f'<rod_{i}' for i in range(24)),'rod_hi\n        dta '+','.join(f'>rod_{i}' for i in range(24))]
lines.append('tip_x_table\n        dta '+','.join(str(x) for x,y in tips))
lines.append('tip_y_table\n        dta '+','.join(str(y) for x,y in tips))
for i,offsets in enumerate(rods):
 assert all(0<=o<64000 for o in offsets)
 lines.append(f'rod_{i}\n        dta '+','.join(f'a({o})' for o in offsets)+',a($ffff)')
# The float hangs 43 pixels below the tip; reeling ends below the resting rod.
lines+=[f'REEL_HOME_X = {tips[23][0]-4}',f'REEL_HOME_Y = {tips[23][1]+43}']
# Cast gauge: 25 PAL frames to full strength. Every target is ahead of
# the release tip; power increases horizontal distance and height.
GAUGE_MAX=39
lines+=[f'GAUGE_MAX = {GAUGE_MAX}',f'SPRING_GAUGE = {int(scene["fishing"]["springGauge"])}','CAST_MIN_X = 12','CAST_MAX_X = 140']
lines.append('charge_levels\n        dta '+','.join(str(i*GAUGE_MAX//25) for i in range(26)))
lines.append('charge_distance\n        dta '+','.join(str(140-round(i*128/GAUGE_MAX)) for i in range(GAUGE_MAX+1)))
lines.append('charge_height\n        dta '+','.join(str(140-round(i*110/GAUGE_MAX)) for i in range(GAUGE_MAX+1)))
# 16 flight steps lift the float in an arc; the last step lands exactly.
lines.append('arc_table\n        dta '+','.join(str(round(20*math.sin(math.pi*(i+1)/16))) for i in range(16)))
# Bait scenarios use real PAL VBI durations, with exact percentage rolls.
fishing=scene['fishing'];scenarios=fishing['scenarios']
lines.append('scenario_pick\n        dta '+','.join(map(str,scenario_slots(fishing))))
for label,key in [('scenario_catch','catch'),('scenario_missed','missedLoss'),('scenario_failed','failedLoss')]:
 lines.append(label+'\n        dta 0,'+','.join(str(scenarios[id][key]) for id,*_ in SCENARIOS))
for label,shift in [('scenario_time_lo',0),('scenario_time_hi',8)]:
 lines.append(label+'\n        dta 0,'+','.join(str((scenarios[id]['durationTenths']*5>>shift)&255) for id,*_ in SCENARIOS))
lines += [f'DIVE_INTERVAL_FRAMES = {fishing["diveIntervalSeconds"]*50}']
lines += [f'INTEREST_STEP = {fishing["interestStepPercent"]}',f'REPEAT_TAKE_PERCENT = {fishing["repeatTakePercent"]}',f'FOLLOWUP_FRAMES = {fishing["followupSeconds"]*50}']
quiet=list(range(fishing['quietMinSeconds'],fishing['quietMaxSeconds']+1))
lines += [f'QUIET_CHOICES = {len(quiet)}',f'ESCALATION_PERCENT = {fishing["escalationPercent"]}']
for label,shift in [('quiet_time_lo',0),('quiet_time_hi',8)]:lines.append(label+'\n        dta '+','.join(str((seconds*50>>shift)&255) for seconds in quiet))
# The editor selects the exact mask used by native blinking and flying stars.
star_design=next(a for a in scene['assets'] if a['id']==scene['gameStar'])
star_pixels=[(i%star_design['width']-star_design['width']//2,i//star_design['width']-star_design['height']//2) for i,c in enumerate(star_design['pixels']) if c]
lines.append('star_dx\n        dta '+','.join(str(x&255) for x,y in star_pixels))
lines.append('star_dy\n        dta '+','.join(str(y&255) for x,y in star_pixels))
lines.append(f'STAR_PIXELS = {len(star_pixels)}')
# 3x5 digits for score and casts, 1 byte per row (left pixel is bit 2).
digits=['111101101101111','010110010010111','111001111100111','111001111001111','101101111001001','111100111001111','111100111101111','111001001001001','111101111101111','111101111001111']
lines.append('digit_data\n        dta '+','.join(str(int(s[y:y+3],2)) for s in digits for y in range(0,15,3)))
lines+=sound_tables(scene['sound'],ROOT/'gen/samples.asm')
# Start menu text at absolute screen positions inside the panel (x 80-239, y 54-137).
def text_offsets(text,x,y):
 mask=Image.new('1',(320,150));ImageDraw.Draw(mask).text((x,y),text,font=font,fill=1)
 return [yy*320+xx for yy in range(150) for xx in range(320) if mask.getpixel((xx,yy))]
for name,text,x,y in [('result_title','GAME OVER',133,76),('result_hint','ANY KEY',140,119)]:
 lines.append(name+'\n        dta '+','.join(f'a({o})' for o in text_offsets(text,x,y))+',a($ffff)')
menu=[('PLAY',100,84)]+[(f'CLOUDS:  {v}',100,95) for v in ['NONE','MEDIUM','HEAVY']]
menu+=[('BOOBER',100,106)]+[(f'DIFFICULTY: {v}',100,117) for v in ['EASY','MEDIUM','HARD']]+[(f'SOUND: {v}',100,128) for v in ['OFF','ON']]+[('>',90,84+11*r) for r in range(5)]
# Tiny inventory icons: four colourful worm segments and a square star.
for name,x,colors in [('rainbow',99,[255,250,251,252]),('electric',151,[251,252,251,252])]:
 for row,c in enumerate(colors):
  xx=x+(1 if row>1 else 0);yy=65+row*2
  offsets=[(yy+dy)*320+xx+dx for dy in range(2) for dx in range(2)]
  lines.append(f'menu_{name}_{row}\n        dta '+','.join(f'a({o})' for o in offsets)+',a($ffff)')
for i,(text,x,y) in enumerate(menu):lines.append(f'menu_{i}\n        dta '+','.join(f'a({o})' for o in text_offsets(text,x,y))+',a($ffff)')
lines.append('menu_lo\n        dta '+','.join(f'<menu_{i}' for i in range(len(menu))))
lines.append('menu_hi\n        dta '+','.join(f'>menu_{i}' for i in range(len(menu))))
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
  assert 0<=x<320 and 13<=y<240
  offset=y*320+x
  data.extend([offset>>12,offset&255,0x90|((offset>>8)&15)])
 lines.append(f'window_{i}\n        dta '+','.join(map(str,data))+',255')
import json
(ROOT/'assets/windows.json').write_text(json.dumps(windows))
(ROOT/'gen/tables.asm').write_text('\n'.join(lines)+'\n')
print('Assets:',len(rods),'rod poses;',sum(map(len,rods)),'rod pixels')
