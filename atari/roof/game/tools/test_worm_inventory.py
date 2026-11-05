"""Finite inventory, preserved return outcomes and increasing star interest."""
from pathlib import Path
import sys
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT.parents[1]/'lair/tools'))
from emu import Atari,load_labels
L=load_labels(ROOT/'star-fisher.lab');a=Atari(ROOT/'star-fisher.xex');a.boot();r=a.mem.ram

def put(k,v):r[L[k]]=v
def get(k):return r[L[k]]
def call(k):a.call(L[k])
def setup():
 for k,v in [('STATE',5),('BAIT_PRESENT',1),('CAUGHT',255),('PRESS_EDGE',0),('BASE_X',120),('BASE_Y',90),('POPUP_ACTIVE',0),('INTEREST_BONUS',0),('RANDOM_SEED',91)]:put(k,v)
 call('QUIET_START')
# Quiet retrieves preserve the attached worm and all spares.
put('WORMS_SPARE',4)
for _ in range(10):
 setup();put('PRESS_EDGE',1);call('WAITING');assert get('STATE')==3 and get('BAIT_PRESENT')==1
 call('LANDED');assert get('BAIT_PRESENT')==1 and get('WORMS_SPARE')==4 and get('CAUGHT')==255
# Lost bait is automatically replaced once per return, up to four spares.
for spare in range(4,0,-1):
 put('BAIT_PRESENT',0);put('WORM_TYPE',spare%2);call('LANDED')
 assert get('BAIT_PRESENT')==1 and get('WORMS_SPARE')==spare-1 and get('WORM_TYPE')==spare%2
 call('AUTO_REBAIT');assert get('WORMS_SPARE')==spare-1
put('BAIT_PRESENT',0);call('LANDED');assert get('BAIT_PRESENT')==0 and get('WORMS_SPARE')==0
put('PRESS_EDGE',1);call('IDLE');assert get('STATE')==6
a.cpu.a=0;call('EQUIP_WORM');assert get('BAIT_PRESENT')==0
# Neither worm selection nor replenishment is allowed away from home.
put('WORMS_SPARE',4);put('WORM_STOCK',2);r[L['WORM_STOCK']+1]=2
for state in (1,2,3,4,5,7):
 put('STATE',state);a.cpu.a=0;call('EQUIP_WORM');assert get('BAIT_PRESENT')==0 and get('WORMS_SPARE')==4
# Exact percentage-point pressure and cap; zero-risk states remain zero.
for bonus in (0,5,25,50):
 put('INTEREST_BONUS',bonus)
 for base in (0,10,35,60,100):
  a.cpu.a=base;call('PRESSURE_CHANCE');assert a.cpu.a==(min(100,base+bonus) if base else 0)
# Both gentle and sideways survivors build pressure and lead to a dive or short pause.
for stage in (1,5):
 saved=r[L['SCENARIO_MISSED']+stage];r[L['SCENARIO_MISSED']+stage]=0
 for bonus in (0,5,45,50):
  setup();put('INTEREST_BONUS',bonus);put('BITE_STAGE',stage);put('BITE_TIMER',0);r[L['BITE_TIMER']+1]=0
  call('WAITING');assert get('INTEREST_BONUS')==min(50,bonus+5)
  assert get('BITE_STAGE') in (0,2)
  assert get('BITE_TIMER')==(100 if get('BITE_STAGE')==0 else 50)
 r[L['SCENARIO_MISSED']+stage]=saved
counts=[]
for bonus in (0,5,25):
 count=0
 for seed in range(1,256):
  setup();put('RANDOM_SEED',seed);put('INTEREST_BONUS',bonus);put('BITE_TIMER',0);r[L['BITE_TIMER']+1]=0
  call('WAITING');count+=get('BITE_STAGE') in (1,5)
 counts.append(count)
assert counts[0]<counts[1]<=counts[2],counts
# A catch consumes the attached worm, preserves spares and remains visible on landing.
setup();r[L['SCENARIO_CATCH']+2]=100;put('BITE_STAGE',2);put('PRESS_EDGE',1);call('WAITING')
assert get('CAUGHT')==0 and get('BAIT_PRESENT')==0
score=get('SCORE');call('LANDED');assert get('SCORE')==score+1 and get('CAUGHT')==0 and get('BAIT_PRESENT')==1
print('PASS preserved bait, automatic replacement, five-worm limit, persistent caught star, +5-point pressure and increasingly likely repeat bites',counts)
