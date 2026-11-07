"""Exhaustion results, held-input protection and fresh-game resources."""
from pathlib import Path
import sys
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT.parents[1]/'lair/tools'))
from emu import Atari,load_labels
L=load_labels(ROOT/'star-fisher.lab');a=Atari(ROOT/'star-fisher.xex');a.boot();r=a.mem.ram

def put(k,v):r[L[k]]=v
def get(k):return r[L[k]]
def call(k):a.call(L[k])
def empty():
 put('WORMS_SPARE',0);put('WORM_STOCK',0);r[L['WORM_STOCK']+1]=0
# Last catch must be landed and scored before game over.
empty();put('STATE',3);put('CAUGHT',0);put('BAIT_PRESENT',0);put('SCORE',4);call('LANDED')
assert get('STATE')==6 and get('SCORE')==5 and get('BAIT_PRESENT')==0
# An empty return or an ignored last bite also ends the night.
put('STATE',3);put('CAUGHT',255);put('SCORE',2);call('LANDED');assert get('STATE')==6 and get('SCORE')==2
put('STATE',5);put('BAIT_PRESENT',1);call('LOSE_BAIT');assert get('STATE')==6 and get('SCORE')==2
# Results accept ordinary keys, special keys, joystick fire/direction and console keys.
for kind,code in [('key',0x12),('key',0x15),('key',0x25),('key',0x28),('key',0x0c),('fire',0),('direction',0),('console',0)]:
 a.set_input();a.kbcode=255;a.skstat=255;a.consol=7
 call('GAME_OVER_ENTER');call('GAME_OVER_INPUT');assert get('RESULT_ARMED')==1
 if kind=='key':a.kbcode=code;a.skstat=0xfb
 elif kind=='fire':a.set_input(trig=1)
 elif kind=='direction':a.set_input(stick=7)
 else:a.consol=6
 call('GAME_OVER_INPUT');assert get('STATE')==7 and get('SCORE')==2 and get('MENU_RELEASE')==1,(kind,code)
# Fresh live main loop: final worm lost in water, results stay until a new press.
a=Atari(ROOT/'star-fisher.xex');a.boot();a.run_frames(15);r=a.mem.ram
for k,v in [('STATE',5),('SCORE',2),('BASE_X',120),('BASE_Y',70),('BAIT_PRESENT',1),('BITE_STAGE',2),('BITE_TIMER',1),('WORMS_SPARE',0),('WORM_STOCK',0)]:put(k,v)
r[L['WORM_STOCK']+1]=0;r[L['BITE_TIMER']+1]=0
a.run_frames(20);assert get('STATE')==6 and get('SCORE')==2
a.screenshot(ROOT/'screenshots/game-over.png',scale=3)
def key(code,frames=12):a.kbcode=code;a.skstat=0xfb;a.run_frames(frames)
def release():a.kbcode=255;a.skstat=255;a.run_frames(12)
key(0x3f,40);assert get('STATE')==7 and get('SCORE')==2 and get('BAIT_PRESENT')==0
release();key(0x0c);release()
assert get('STATE')==0 and get('SCORE')==0 and get('BAIT_PRESENT')==1 and get('WORMS_SPARE')==4
assert get('WORM_STOCK')==2 and r[L['WORM_STOCK']+1]==2 and get('WORM_TYPE')==0
# A held strike on landing cannot dismiss results before release.
for k,v in [('STATE',3),('PHASE',0),('SCORE',1),('CAUGHT',255),('BAIT_PRESENT',0),('WORMS_SPARE',0)]:put(k,v)
key(0x3f,40);assert get('STATE')==6
release();key(0x15);assert get('STATE')==7 and get('POPUP_ACTIVE')==0
print('PASS final catch scored, exhausted bait game over, any-input dismissal, held-input protection, and fresh five-worm/zero-score restart')
