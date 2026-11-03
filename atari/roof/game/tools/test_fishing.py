"""Bait lifecycle, exact odds, PAL deadlines, clipping and real-input catches."""
from pathlib import Path
import sys
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT.parents[1]/'lair/tools'));sys.path.insert(0,str(ROOT/'tools'))
from emu import Atari,load_labels
from bobbers import pixels,DESIGNS
L=load_labels(ROOT/'star-fisher.lab');a=Atari(ROOT/'star-fisher.xex');a.boot();r=a.mem.ram

def put(n,v):r[L[n]]=v
def get(n):return r[L[n]]
def call(n):a.call(L[n])
def timer():return get('BITE_TIMER')+256*r[L['BITE_TIMER']+1]
def setup(stage=0):
 for k,v in [('STATE',5),('BAIT_PRESENT',1),('BASE_X',120),('BASE_Y',90),('PRESS_EDGE',0),('POPUP_ACTIVE',0),('RANDOM_SEED',91),('INTEREST_BONUS',0)]:put(k,v)
 if stage:
  put('DIVE_TIMER',0);r[L['DIVE_TIMER']+1]=0;a.cpu.a=stage;call('SCENARIO_START')
 else:call('QUIET_START')
# Uniform rejection sampler: accepted raw draws contain exactly two of each percent.
for percent in (0,5,10,80,100):
 results=[]
 for seed in range(1,256):
  nxt=((seed<<1)^(29 if seed&128 else 0))&255
  if nxt>200:continue
  put('RANDOM_SEED',seed);a.cpu.a=percent;call('CHANCE_PERCENT');results.append(not(a.cpu.p&1))
 assert sum(results)==percent*2
assert get('SCENARIO_CATCH')==0 and r[L['SCENARIO_CATCH']+1]==5 and r[L['SCENARIO_CATCH']+2]==80
assert r[L['SCENARIO_MISSED']+1]==10 and r[L['SCENARIO_MISSED']+2]==100
setup();assert 400<=timer()<=1000
for _ in range(200):call('BITE_VBLANK');call('WAITING');assert (get('FLOAT_X'),get('FLOAT_Y'))==(120,90)
setup(1);positions=set()
for _ in range(100):
 call('BITE_VBLANK');call('WAITING');positions.add((get('FLOAT_X'),get('FLOAT_Y')))
assert len(positions)>2 and all(abs(x-120)<=1 and 90<=y<=91 for x,y in positions)
setup(2);assert timer()==50
for _ in range(49):call('BITE_VBLANK')
assert timer()==1;call('WAITING');assert get('BITE_STAGE')==2
put('POPUP_ACTIVE',1)
for _ in range(60):call('BITE_VBLANK')
assert timer()==1;put('POPUP_ACTIVE',0)
call('BITE_VBLANK');call('WAITING');assert timer()==0 and get('BAIT_PRESENT')==0 and get('BITE_STAGE')==0
for _ in range(1000):call('BITE_VBLANK');call('WAITING')
assert get('BAIT_PRESENT')==0 and get('BITE_STAGE')==0
# A late strike cannot catch after the dive expires.
setup(2);put('BITE_TIMER',0);r[L['BITE_TIMER']+1]=0;put('PRESS_EDGE',1);put('CAUGHT',255)
call('WAITING');assert get('STATE')==3 and get('CAUGHT')==255 and get('BAIT_PRESENT')==0
put('PHASE',0);call('REELING');assert get('BAIT_PRESENT')==1 and get('STATE')==0
# Force event outcomes independently, without changing the user's settings.
setup(1);r[L['SCENARIO_MISSED']+1]=100;put('BITE_TIMER',0);r[L['BITE_TIMER']+1]=0;call('WAITING');assert get('BAIT_PRESENT')==0
r[L['SCENARIO_MISSED']+1]=10
# Other scenarios respect their timeout policy; a false alarm preserves bait.
for stage in (3,4,5):
 setup(stage)
 assert timer()==(100 if stage==3 else 75)
 original=r[L['SCENARIO_MISSED']+stage]
 r[L['SCENARIO_MISSED']+stage]=0
 put('BITE_TIMER',0);r[L['BITE_TIMER']+1]=0;call('WAITING')
 assert get('BAIT_PRESENT')==1 and get('BITE_STAGE') in ((0,2) if stage in (3,5) else (0,))
 r[L['SCENARIO_MISSED']+stage]=original
# The two-row menu clamps navigation before indexing its generated masks.
put('STATE',7);put('MENU_ROW',1);put('DIR_EDGE',2);put('PRESS_EDGE',0)
call('MENU');assert get('MENU_ROW')==1
# All sixteen floats are partially submerged, completely hidden for dives,
# and fully visible during casting/reeling. No old tilt/glint mechanics.
for selected in range(16):
 setup();put('BOBBER_SELECTED',selected);put('BUFFER',2);put('DRAW_BANK',0xa0)
 visible=len(DESIGNS[selected//2][selected%2]);visible-=max(1,visible//3)
 for state,stage in [(5,0),(5,2),(3,0)]:
  put('STATE',state);put('BITE_STAGE',stage);a.vram[0x20000:0x20000+76800]=0;call('DRAW_FLOAT')
  expected=bytearray(76800)
  for dx,dy,c in pixels(selected//2,selected%2):
   if state==5 and (stage==2 or dy>=visible):continue
   expected[(90+dy)*320+120+dx]=c
  assert bytes(a.vram[0x20000:0x20000+76800])==expected,(selected,state,stage)
print('PASS exact 5/10/80% rolls, still waiting, gentle motion, 50-VBI dive, pause, deadline, empty-bait lockout, rebait and all sprite waterlines',flush=True)
# Fresh instance: actual inputs cast, catch, land and replenish bait five times.
a=Atari(ROOT/'star-fisher.xex');a.boot();r=a.mem.ram;a.run_frames(15)
def key(down):a.kbcode=0x3f if down else 255;a.skstat=0xfb if down else 255
def until(test,limit=600):
 for _ in range(limit):
  a.run_frames(1)
  if test():return
 raise AssertionError(('Timed out',get('STATE')))
key(True);a.run_frames(8);key(False);a.run_frames(8)
for n in range(5):
 key(True);until(lambda:get('CHARGE')>=5);key(False);until(lambda:get('STATE')==5)
 # Force a live aggressive opportunity and guaranteed hook for integration.
 put('BITE_STAGE',2);put('BITE_TIMER',100);r[L['BITE_TIMER']+1]=0;r[L['SCENARIO_CATCH']+2]=100
 key(True);until(lambda:get('STATE') in (0,4));key(False);a.run_frames(6)
 assert get('SCORE')==n+1 and get('BAIT_PRESENT')==(1 if n<4 else 0)
 assert get('WORMS_SPARE')==max(0,3-n)
 if n<4:
  a.kbcode=0x1f if n%2 else 0x1e;a.skstat=0xfb;a.run_frames(8);key(False);a.run_frames(6)
  assert get('BAIT_PRESENT')==1 and get('WORMS_SPARE')==3-n
assert get('STATE')==4
print('PASS real-input casting, timed strikes, reeling, automatic replacement, finite bait and five-star win')
