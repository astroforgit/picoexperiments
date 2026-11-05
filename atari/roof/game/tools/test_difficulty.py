"""Probability-only difficulty and cursor/Enter activation."""
from pathlib import Path
import sys
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT.parents[1]/'lair/tools'))
from emu import Atari,load_labels
L=load_labels(ROOT/'star-fisher.lab');a=Atari(ROOT/'star-fisher.xex');a.boot();r=a.mem.ram

def put(k,v):r[L[k]]=v
def get(k):return r[L[k]]
def call(k):a.call(L[k])
activity=[]
for level in range(3):
 put('DIFFICULTY',level)
 for chance in range(101):
  a.cpu.a=chance;call('DIFFICULTY_CATCH')
  assert a.cpu.a==(min(100,chance+chance//4) if level==0 else chance if level==1 else chance//2)
 active=0
 for seed in range(1,256):
  for k,v in [('STATE',5),('BAIT_PRESENT',1),('BITE_STAGE',0),('BITE_TIMER',0),('INTEREST_BONUS',0),('PRESS_EDGE',0),('RANDOM_SEED',seed),('BASE_X',120),('BASE_Y',90)]:put(k,v)
  r[L['BITE_TIMER']+1]=0;call('WAITING');active+=get('BITE_STAGE')!=0
 activity.append(active)
 a.cpu.a=6;call('SCENARIO_START');assert get('BITE_TIMER')==150
assert activity[0]>activity[1]>activity[2],activity
# Actual keyboard navigation changes difficulty and opens BOOBER with Enter.
a=Atari(ROOT/'star-fisher.xex');a.boot();a.run_frames(15);r=a.mem.ram
def tap(code):
 a.kbcode=code;a.skstat=0xfb;a.run_frames(10);a.kbcode=255;a.skstat=255;a.run_frames(10)
assert get('DIFFICULTY')==1
for _ in range(3):tap(0x0f)
assert get('MENU_ROW')==3
tap(0x07);assert get('DIFFICULTY')==2 and get('STATE')==7
tap(0x0c);assert get('DIFFICULTY')==0
tap(0x07);assert get('DIFFICULTY')==1
tap(0x0e);assert get('MENU_ROW')==2
tap(0x0c);assert get('POPUP_ACTIVE')==1
tap(0x1c);assert get('POPUP_ACTIVE')==0 and get('STATE')==7
a.screenshot(ROOT/'screenshots/difficulty-menu.png',scale=3)
print('PASS exact catch scaling, decreasing action probabilities, unchanged bite duration and real cursor/Enter controls',activity)
