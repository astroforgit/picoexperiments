"""Minimal game overlay, M pause/resume, catalogue navigation and typed counters."""
from pathlib import Path
import sys
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT.parents[1]/'lair/tools'))
from emu import Atari,load_labels
L=load_labels(ROOT/'star-fisher.lab');a=Atari(ROOT/'star-fisher.xex');a.boot();a.run_frames(15);r=a.mem.ram

def put(k,v):r[L[k]]=v
def get(k):return r[L[k]]
def call(k):a.call(L[k])
def count(kind):a.cpu.x=kind;call('INVENTORY_COUNT');return a.cpu.a
def key(code,frames=8):a.kbcode=code;a.skstat=0xfb;a.run_frames(frames)
def release():a.kbcode=255;a.skstat=255;a.run_frames(8)
def tap(code):key(code);release()
assert (count(0),count(1))==(3,2)
a=Atari(ROOT/'star-fisher.xex');a.boot();a.run_frames(15);r=a.mem.ram
# B launches existing catalogue directly from menu, then returns to menu.
tap(0x15);assert get('POPUP_ACTIVE')==1 and get('STATE')==7
tap(0x1c);assert get('POPUP_ACTIVE')==0 and get('STATE')==7
# Menu's selected B row is also actionable with fire.
tap(0x0f);tap(0x0f);assert get('MENU_ROW')==2
tap(0x0c);assert get('POPUP_ACTIVE')==1
tap(0x1c);put('MENU_ROW',0);tap(0x3f);assert get('STATE')==0
# Inventory swaps preserve totals and cannot manufacture worms.
a.cpu.a=1;call('EQUIP_WORM');assert get('WORM_TYPE')==1 and (count(0),count(1))==(3,2) and get('WORMS_SPARE')==4
put('BAIT_PRESENT',0);call('AUTO_REBAIT');assert (count(0),count(1))==(3,1) and get('WORMS_SPARE')==3
put('BAIT_PRESENT',0);call('AUTO_REBAIT');assert get('WORM_TYPE')==0 and (count(0),count(1))==(3,0) and get('WORMS_SPARE')==2
a=Atari(ROOT/'star-fisher.xex');a.boot();a.run_frames(15);r=a.mem.ram;tap(0x3f)
# M during a live bite freezes timers and retains cast position even while rendering.
for k,v in [('STATE',5),('BASE_X',120),('BASE_Y',70),('FLOAT_X',120),('FLOAT_Y',70),('BITE_STAGE',1),('BITE_TIMER',180),('INTEREST_BONUS',5)]:put(k,v)
r[L['BITE_TIMER']+1]=0
tap(0x25);assert get('STATE')==7 and get('MENU_RESUME')==5
snapshot={k:get(k) for k in ('BITE_TIMER','DIVE_TIMER','FLOAT_X','FLOAT_Y','INTEREST_BONUS','WORMS_SPARE','SCORE')}
key(0x25,40);assert get('STATE')==5 # new press resumes; holding cannot toggle repeatedly
release();tap(0x25);assert get('STATE')==7
snapshot={k:get(k) for k in snapshot};a.run_frames(40);assert all(get(k)==v for k,v in snapshot.items())
a.screenshot(ROOT/'screenshots/minimal-menu.png',scale=3)
tap(0x25);assert get('STATE')==5
# No status text or counters in play, including win and caught-star returns.
base=Image.open(ROOT/'assets/background-320x240.png').tobytes()
# User-painted window lights can now reach the bottom row. Disable them
# while asserting that gameplay adds no footer text.
r[L['LIGHT_ON']:L['LIGHT_ON']+L['WINDOW_COUNT']]=bytes(L['WINDOW_COUNT'])
for state in (0,1,2,3,4,5):
 put('STATE',state);put('CLOUD_COUNT',0);put('BUFFER',2);put('DRAW_BANK',0xa0);put('PHASE',0)
 call('RENDER');screen=bytes(a.vram[0x20000:0x20000+76800])
 assert screen[13*320:32*320]==base[13*320:32*320],state
 assert screen[226*320:]==base[226*320:],state
 for y in range(13):assert screen[y*320:y*320+270]==base[y*320:y*320+270]
put('STATE',5);call('RENDER');a.vregs[0x41]=0;a.vregs[0x42]=0xe0;a.vregs[0x43]=7
a.screenshot(ROOT/'screenshots/minimal-game.png',scale=3)
print('PASS icon-only typed counters, finite stock swaps/fallback, M pause/resume, B menu/direct entry and text-free play overlays')
