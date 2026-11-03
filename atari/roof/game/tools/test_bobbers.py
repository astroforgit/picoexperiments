"""Keyboard modal behaviour and all sixteen native bobber sprites."""
from pathlib import Path
import sys
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT.parents[1]/'lair/tools'));sys.path.insert(0,str(ROOT/'tools'))
from emu import Atari,load_labels
from bobbers import pixels
L=load_labels(ROOT/'star-fisher.lab')
a=Atari(ROOT/'star-fisher.xex');a.boot();a.run_frames(15);r=a.mem.ram
for selected in range(16):
 for tilt in (0,):
  for k,v in [('BOBBER_SELECTED',selected),('BUFFER',2),('DRAW_BANK',0xa0),('FLOAT_X',120),('FLOAT_Y',90),('STATE',3),('TILT',tilt)]:r[L[k]]=v
  a.vram[0x20000:0x20000+76800]=0;a.call(L['DRAW_FLOAT'])
  expected=bytearray(76800)
  for dx,dy,c in pixels(selected//2,selected%2):
   x,y=(120-dy,90+dx) if tilt else (120+dx,90+dy)
   expected[y*320+x]=c
  assert bytes(a.vram[0x20000:0x20000+76800])==expected,(selected,tilt)
  assert (r[L['FLOAT_X']],r[L['FLOAT_Y']])==(120,90)
print('PASS all eight designs in both sizes, full sprites, stable attachment',flush=True)
# Use real keyboard input and the running main loop.
a=Atari(ROOT/'star-fisher.xex');a.boot();a.run_frames(15);r=a.mem.ram
def get(k):return r[L[k]]
def key(code,frames=10):
 a.kbcode=code;a.skstat=0xfb;a.run_frames(frames)
def release():a.kbcode=255;a.skstat=255;a.run_frames(10)
def tap(code):key(code);release()
assert get('BOBBER_SELECTED')==2
tap(0x3f) # start game
tap(0x15)
assert get('POPUP_ACTIVE')==1 and get('STATE')==0
# Holding B does not repeatedly close/reopen. A release plus next B cancels.
release();tap(0x15);assert get('POPUP_ACTIVE')==0
key(0x15,40);assert get('POPUP_ACTIVE')==1;release()
state={k:get(k) for k in ['STATE','CHARGE','PHASE','SCORE','CASTS','BITE_TIMER']}
a.run_frames(30);assert all(get(k)==v for k,v in state.items())
tap(0x07);assert get('POPUP_SELECTED')==4 # right: pear, small
tap(0x0e);assert get('POPUP_SELECTED')==5 # up: pear, large
tap(0x1c);assert get('POPUP_ACTIVE')==0 and get('BOBBER_SELECTED')==2
# Enter applies; no cast is triggered by confirming.
tap(0x15);tap(0x06);tap(0x0f);assert get('POPUP_SELECTED')==1
tap(0x0c);assert get('BOBBER_SELECTED')==1 and get('POPUP_ACTIVE')==0 and get('CASTS')==0
# B works while waiting and does not consume the behaviour timer.
r[L['STATE']]=5;r[L['BITE_TIMER']]=200;r[L['BITE_TIMER']+1]=0;r[L['BASE_X']]=150;r[L['BASE_Y']]=32
key(0x15);timer=get('BITE_TIMER');a.run_frames(30);assert get('BITE_TIMER')==timer;release()
# Fire applies a size choice; stay in waiting rather than striking on confirmation.
tap(0x0f);tap(0x3f);assert get('POPUP_ACTIVE')==0 and get('STATE')==5 and get('CASTS')==0
# Catalogue screenshot with the user's Quill / Small selection highlighted.
r[L['BOBBER_SELECTED']]=2;tap(0x15);a.run_frames(8)
a.screenshot(ROOT/'screenshots/bobber-selection-popup.png',scale=3)
print('PASS B debounce, arrow navigation, size choice, Escape cancel, Enter/fire apply, pause/resume and no accidental strike; saved popup')
