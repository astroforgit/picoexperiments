"""Native cloud occlusion, slow motion and intermittent meteor regression."""
from pathlib import Path
import sys
import numpy as np
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT.parents[1]/'lair/tools'))
from emu import Atari,load_labels
L=load_labels(ROOT/'star-fisher.lab');a=Atari(ROOT/'star-fisher.xex');a.boot();a.run_frames(15);r=a.mem.ram

def get(n):return r[L[n]]
def put(n,v):r[L[n]]=v
assert 1<=L['STAR_PIXELS']<=2
put('RANDOM_SEED',53);a.call(L['RESET_SKY'])
initial=bytes(r[L['CLOUD_X']:L['CLOUD_X']+3])
for _ in range(7):a.call(L['UPDATE_SKY'])
assert bytes(r[L['CLOUD_X']:L['CLOUD_X']+3])==initial
a.call(L['UPDATE_SKY'])
assert list(r[L['CLOUD_X']:L['CLOUD_X']+3])==[9,118,208]
assert get('METEOR_LIFE')==0
# A cloud body must hide a bright star; its transparent edge preserves sky.
put('BUFFER',2);put('DRAW_BANK',0xa0)
a.vram[0x20000:0x20000+76800]=252
a.call(L['DRAW_CLOUDS'])
cloud=a.vram[0x14000:0x14000+96*24].reshape(24,96)
for i,y in enumerate([43,81,113]):
 x=r[L['CLOUD_X']+i]
 rendered=a.vram[0x20000:0x20000+76800].reshape(240,320)[y:y+24,x:x+96]
 assert np.array_equal(rendered[cloud!=0],cloud[cloud!=0])
 assert np.all(rendered[cloud==0]==252)
a.call(L['BACKGROUND'])
assert bytes(a.vram[0x20000:0x20000+76800])==bytes(a.vram[:76800]),'Old cloud/meteor pixels must be restored'
# Force countdown expiry, then check downward movement and finite lifetime.
put('METEOR_WAIT',1);put('SKY_TICKS',3);a.call(L['UPDATE_SKY'])
assert get('METEOR_LIFE')==24 and get('METEOR_Y')==34
x=get('METEOR_X');a.call(L['UPDATE_SKY'])
assert get('METEOR_X')==x+2 and get('METEOR_Y')==37
for _ in range(23):a.call(L['UPDATE_SKY'])
assert get('METEOR_LIFE')==0 and get('METEOR_WAIT')>=128
for _ in range(100):a.call(L['UPDATE_SKY'])
assert get('METEOR_LIFE')==0
appearances=0
for _ in range(2200):
 before=get('METEOR_LIFE');a.call(L['UPDATE_SKY'])
 appearances+=before==0 and get('METEOR_LIFE')==24
 assert all(0<=v<=224 for v in r[L['CLOUD_X']:L['CLOUD_X']+3])
assert appearances>=2 and get('RANDOM_SEED')==53
# Save a native rendered meteor/cloud preview.
put('METEOR_LIFE',16);put('METEOR_X',94);put('METEOR_Y',74)
a.call(L['RENDER']);a.vregs[0x41]=0;a.vregs[0x42]=0xe0;a.vregs[0x43]=7
a.screenshot(ROOT/'screenshots/night-sky.png',scale=3)
print('PASS tiny stars, slow cloud motion/bounds, opaque masking/transparent edges, restoration, downward meteor and long recurring pauses, independent fishing RNG')
