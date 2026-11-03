"""Full dives cannot bypass their cooldown; smaller motions and odds are distinct."""
from pathlib import Path
import sys
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT.parents[1]/'lair/tools'))
from emu import Atari,load_labels
L=load_labels(ROOT/'star-fisher.lab');a=Atari(ROOT/'star-fisher.xex');a.boot();r=a.mem.ram

def put(k,v):r[L[k]]=v
def get(k):return r[L[k]]
def call(k):a.call(L[k])
def dive():return get('DIVE_TIMER')+256*r[L['DIVE_TIMER']+1]
for k,v in [('STATE',5),('BAIT_PRESENT',1),('BASE_X',120),('BASE_Y',90),('POPUP_ACTIVE',0),('INTEREST_BONUS',0),('RANDOM_SEED',91),('PRESS_EDGE',0)]:put(k,v)
assert dive()==9000
for _ in range(8999):call('BITE_VBLANK')
assert dive()==1
a.cpu.a=2;call('SCENARIO_START');assert get('BITE_STAGE')==0 and dive()==1
put('POPUP_ACTIVE',1)
for _ in range(20):call('BITE_VBLANK')
assert dive()==1;put('POPUP_ACTIVE',0)
for state in (4,7):
 put('STATE',state);call('BITE_VBLANK');assert dive()==1
put('STATE',5);call('BITE_VBLANK');assert dive()==0
a.cpu.a=2;call('SCENARIO_START');assert get('BITE_STAGE')==2 and dive()==9000 and get('BITE_TIMER')==50
a.cpu.a=2;call('SCENARIO_START');assert get('BITE_STAGE')==0 and dive()==9000
for stage,catch,loss in ((6,30,50),(7,20,35)):
 assert r[L['SCENARIO_CATCH']+stage]==catch and r[L['SCENARIO_MISSED']+stage]==r[L['SCENARIO_FAILED']+stage]==loss
 a.cpu.a=stage;call('SCENARIO_START');positions=set()
 for t in range(64):
  put('BITE_PHASE',t);call('BITE_PLACE');positions.add((get('FLOAT_X'),get('FLOAT_Y')))
 assert len(positions)>=5 and all(90<=y<=92 for x,y in positions)
 assert max(abs(x-120) for x,y in positions)==(1 if stage==6 else 3)
# Surviving small actions increase interest but cannot defeat the dive cooldown.
for stage in (1,3,5,6,7):
 r[L['SCENARIO_MISSED']+stage]=0
 put('INTEREST_BONUS',0);put('BITE_STAGE',stage);put('BITE_TIMER',0);r[L['BITE_TIMER']+1]=0
 call('WAITING');assert get('BITE_STAGE')==0 and get('INTEREST_BONUS')==5
print('PASS three-minute dive gate, pause, one-second dive, all small-action escalation gates and 30/50 + 20/35 action odds/motions')
