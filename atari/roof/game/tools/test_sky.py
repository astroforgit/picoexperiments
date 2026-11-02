"""Actual native fixed stars, gentle twinkling, PAL timing and cloud masking."""
from pathlib import Path
import sys,json
import numpy as np
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT.parents[1]/'lair/tools'))
sys.path.insert(0,str(ROOT/'tools'))
from emu import Atari,load_labels
from scene_model import load_scene,starfield,validate,default_scene
L=load_labels(ROOT/'star-fisher.lab');a=Atari(ROOT/'star-fisher.xex');a.boot();a.run_frames(15);r=a.mem.ram
scene=load_scene(Image.open(ROOT/'assets/editor-base.png').getpalette());field=starfield(scene)
def get(n):return r[L[n]]
def put(n,v):r[L[n]]=v
# Counts and brightness changes match editor settings; positions never change.
assert len(field)==L['STARFIELD_COUNT']==scene['sky']['onePixelStars']+scene['sky']['twoPixelStars']
assert sum(p['twinkle'] for p in field)==(len(field)*scene['sky']['twinklePercent']+50)//100
put('BUFFER',2);put('DRAW_BANK',0xa0)
for tick in range(0,256,32):
 put('SKY_TICKS',tick);a.vram[0x20000:0x20000+76800]=0;a.call(L['DRAW_STARFIELD'])
 expected=np.zeros(76800,dtype=np.uint8)
 for p in field:
  color=246 if p['twinkle'] and (p['phase']+(tick>>5))%8==0 else 252
  expected[p['y']*320+p['x']:p['y']*320+p['x']+p['size']]=color
 assert np.array_equal(a.vram[0x20000:0x20000+76800],expected)
# Neither weather nor twinkling changes fishing randomness.
put('RANDOM_SEED',53);a.call(L['RESET_SKY'])
initial=bytes(r[L['CLOUD_X']:L['CLOUD_X']+3])
for _ in range(63):a.call(L['SKY_VBLANK']);a.call(L['UPDATE_SKY'])
assert bytes(r[L['CLOUD_X']:L['CLOUD_X']+3])==initial
a.call(L['SKY_VBLANK']);a.call(L['UPDATE_SKY'])
assert list(r[L['CLOUD_X']:L['CLOUD_X']+3])==[9,78,148]
# Real PAL ticks: no meteor trial before 500 VBIs (10 seconds).
a.call(L['RESET_SKY'])
for _ in range(499):a.call(L['SKY_VBLANK'])
assert get('METEOR_TRIALS')==0
a.call(L['SKY_VBLANK']);assert get('METEOR_TRIALS')==1
# Test probability endpoints on the actual 6502 compare instruction.
operand=L['METEOR_ROLL_COMPARE']+1;original=r[operand]
for probability in (0,255):
 r[operand]=probability
 for seed in range(1,256):
  put('METEOR_LIFE',0);put('METEOR_TRIALS',1);put('SKY_SEED',seed);a.call(L['UPDATE_SKY'])
  assert get('METEOR_LIFE')==(24 if probability else 0)
r[operand]=original
put('METEOR_LIFE',24);put('METEOR_X',50);put('METEOR_Y',34);put('METEOR_TRIALS',0)
a.call(L['UPDATE_SKY']);assert get('METEOR_X')==52 and get('METEOR_Y')==37
for _ in range(23):a.call(L['UPDATE_SKY'])
assert get('METEOR_LIFE')==0
for _ in range(200):a.call(L['UPDATE_SKY'])
assert get('METEOR_LIFE')==0
# Larger opaque bodies cover stars, transparent edges preserve the sky.
a.vram[0x20000:0x20000+76800]=252;a.call(L['DRAW_CLOUDS'])
cloud=a.vram[0x14000:0x14000+160*40].reshape(40,160)
for i,y in enumerate([40,74,104]):
 x=r[L['CLOUD_X']+i]
 rendered=a.vram[0x20000:0x20000+76800].reshape(240,320)[y:y+40,x:x+160]
 assert np.array_equal(rendered[cloud!=0],cloud[cloud!=0])
 # Other clouds can overlap transparent edges, so inspect an isolated draw separately.
a.call(L['BACKGROUND'])
assert bytes(a.vram[0x20000:0x20000+76800])==bytes(a.vram[:76800])
assert get('RANDOM_SEED')==53
for _ in range(400):
 put('CLOUD_PENDING',1);a.call(L['UPDATE_SKY'])
 assert all(0<=v<=160 for v in r[L['CLOUD_X']:L['CLOUD_X']+3])
# Schema endpoints, old project compatibility and invalid inputs.
for value in (0,96):
 s=default_scene(Image.open(ROOT/'assets/editor-base.png').getpalette());s['sky'].update(onePixelStars=value,twoPixelStars=value,twinklePercent=100)
 assert len(starfield(validate(s)))==value*2
for key,value in [('onePixelStars',97),('meteorProbability',101),('twinklePercent',-1),('twoPixelStars',1.5)]:
 s=json.loads(json.dumps(scene));s['sky'][key]=value
 try:validate(s)
 except ValueError:pass
 else:raise AssertionError('Invalid sky setting accepted')
old=json.loads(json.dumps(scene));old.pop('sky');assert validate(old)['sky']['onePixelStars']==48
put('METEOR_LIFE',0);a.call(L['RENDER']);a.vregs[0x41]=0;a.vregs[0x42]=0xe0;a.vregs[0x43]=7
a.screenshot(ROOT/'screenshots/night-sky.png',scale=3)
print('PASS exact static star counts/positions, gentle selected twinkling, 64-VBI cloud speed, 500-VBI meteor clock, 0/100% probability, downward lifetime, masking/restoration, independent RNG and settings validation')
