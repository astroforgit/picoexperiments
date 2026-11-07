"""PAL charging deadlines and forward trajectories at every power level."""
from pathlib import Path
import sys
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT.parents[1]/'lair/tools'))
from emu import Atari,load_labels
L=load_labels(ROOT/'star-fisher.lab');a=Atari(ROOT/'star-fisher.xex');a.boot();r=a.mem.ram

def put(k,v):r[L[k]]=v
def get(k):return r[L[k]]
def call(k):a.call(L[k])
for spring in (0,1):
 for k,v in [('STATE',0),('PRESS_EDGE',1),('POPUP_ACTIVE',0),('SPRING_MODE',spring)]:put(k,v)
 call('IDLE')
 for frame in range(1,26):
  call('CHARGE_VBLANK');assert get('CHARGE')==frame*39//25
 assert get('CHARGE')==39
 put('POPUP_ACTIVE',1)
 for _ in range(30):call('CHARGE_VBLANK')
 assert get('CHARGE')==39
 put('POPUP_ACTIVE',0)
 for _ in range(25):call('CHARGE_VBLANK')
 assert get('CHARGE')==(0 if spring else 39)
# Every power level lands farther forward than the release position.
last_x=255
for power in range(40):
 put('STATE',1);put('CHARGE',power);call('LAUNCH')
 target=get('TARGET_X');assert 12<=target<=140 and target<last_x;last_x=target
 previous=None
 for _ in range(23):
  call('CASTING')
  if get('PHASE')>=8:
   x=get('FLOAT_X')
   if previous is not None:assert x<=previous,(power,previous,x)
   previous=x
 assert get('STATE')==5 and get('FLOAT_X')==target
 assert get('FLOAT_Y')==get('TARGET_Y')
print('PASS full power at 25 PAL frames, spring/hold modes, popup pause, and all 40 forward cast trajectories')
