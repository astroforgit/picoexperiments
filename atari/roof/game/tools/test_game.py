"""Run the actual XEX through cast, float, bite, manual reel and win."""
from pathlib import Path
import sys
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT.parents[1]/'lair/tools'))
from emu import Atari,load_labels
L=load_labels(ROOT/'star-fisher.lab')
def get(a,n):return a.mem.ram[L[n]]
def key(a,down=True,code=0x3f):
 a.kbcode=code if down else 0xff;a.skstat=0xfb if down else 0xff

def until(a,predicate,limit=700,record=None):
 for i in range(limit):
  a.run_frames(1)
  assert sum(a.mem.ram[L['STARS_ACTIVE']:L['STARS_ACTIVE']+3])<=3
  if record is not None and i%6==0:record.append(a.screenshot(scale=2))
  if predicate():return
 raise AssertionError('Timed out: '+str({n:get(a,n) for n in ['STATE','PHASE','CHARGE','SCORE','WAIT_TIMER']}))
def tap(a,code=0x3f):
 key(a,True,code);a.run_frames(6);key(a,False)
def cast(a,charge,mode='key',record=None):
 if mode=='fire':a.set_input(trig=1)
 else:key(a,True,0x21 if mode=='space' else 0x3f)
 until(a,lambda:get(a,'CHARGE')>=charge,record=record)
 a.set_input();key(a,False)
 until(a,lambda:get(a,'STATE')==5,record=record)

a=Atari(ROOT/'star-fisher.xex');a.boot()
assert bytes(a.vram[:len((ROOT/'assets/vram.bin').read_bytes())])==(ROOT/'assets/vram.bin').read_bytes()
a.run_frames(15)
assert get(a,'STATE')==0 and a.screenshot(scale=1).size==(320,240)
a.screenshot(ROOT/'screenshots/float-idle.png',scale=3)
# Blinking stars relocate, rather than drift in a fixed row.
seen=set();hidden=False
for _ in range(110):
 a.run_frames(3)
 for i in range(3):
  seen.add((a.mem.ram[L['STARS_X']+i],a.mem.ram[L['STARS_Y']+i]))
  hidden |= a.mem.ram[L['STARS_LIFE']+i]<12
assert len(seen)>6 and hidden
print('PASS upload, boot, random star positions and blink-off intervals',flush=True)
# Charged A must not auto-cast; casting must stop with a stationary float.
key(a);until(a,lambda:get(a,'CHARGE')==60);a.run_frames(18)
assert get(a,'STATE')==1 and get(a,'CASTS')==0
key(a,False);until(a,lambda:get(a,'STATE')==5)
assert get(a,'POWER')==2 and get(a,'PHASE')==23
anchor=(get(a,'HOOK_X'),get(a,'HOOK_Y'))
a.run_frames(45)
assert get(a,'STATE')==5 and anchor==(get(a,'HOOK_X'),get(a,'HOOK_Y'))
a.screenshot(ROOT/'screenshots/float-waiting.png',scale=3)
# A missed bite does not retrieve the float or award a star.
until(a,lambda:get(a,'STATE')==6)
a.run_frames(9);a.screenshot(ROOT/'screenshots/float-bite.png',scale=3)
until(a,lambda:get(a,'STATE')==5)
assert get(a,'SCORE')==0 and get(a,'PHASE')==23
# Tap without a bite retrieves an empty float.
tap(a);until(a,lambda:get(a,'STATE')==0)
assert get(a,'SCORE')==0
print('PASS stationary float, delayed bite, missed bite stays out, manual empty reel',flush=True)
# Reset and play a complete night with actual inputs, including fire and Space.
tap(a,0x28);a.run_frames(6)
assert get(a,'SCORE')==0 and get(a,'CASTS')==0
frames=[]
for n in range(5):
 record=frames if n==0 else None
 cast(a,[5,25,45,25,5][n],['key','fire','space','key','key'][n],record)
 assert get(a,'POWER')==[0,1,2,1,0][n]
 until(a,lambda:get(a,'STATE')==6,record=record)
 key(a)
 until(a,lambda:get(a,'STATE') in (0,4),record=record)
 assert get(a,'SCORE')==n+1
 # Holding reel does not immediately start another cast after landing.
 a.run_frames(12)
 assert get(a,'STATE')==(4 if n==4 else 0)
 key(a,False);a.run_frames(6)
 print(f'PASS manual catch {n+1}/5',flush=True)
a.screenshot(ROOT/'screenshots/float-win.png',scale=3)
tap(a);a.run_frames(12)
assert get(a,'STATE')==4 and get(a,'SCORE')==5
frames[0].save(ROOT/'screenshots/float-fishing-demo.gif',save_all=True,append_images=frames[1:],duration=120,loop=0)
# Both register bases remain supported.
b=Atari(ROOT/'star-fisher.xex',vbxe_page=0xd7);b.boot();b.run_frames(15)
assert get(b,'TICKS')>0 and b.blits>1
assert bytes(b.vram[:len((ROOT/'assets/vram.bin').read_bytes())])==(ROOT/'assets/vram.bin').read_bytes()
print('PASS five-star win, held-key debounce, D640/D740; saved gameplay GIF',flush=True)
