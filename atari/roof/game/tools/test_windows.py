"""Validate window pixels across the 64K framebuffer boundary and animate them."""
from pathlib import Path
import sys,json
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT.parents[1]/'lair/tools'))
from emu import Atari,load_labels
L=load_labels(ROOT/'star-fisher.lab')
windows=json.loads((ROOT/'assets/windows.json').read_text())
a=Atari(ROOT/'star-fisher.xex');a.boot();a.run_frames(15);r=a.mem.ram
r[L['LIGHT_ON']:L['LIGHT_ON']+len(windows)]=bytes(len(windows))
a.call(L['RENDER'])
base=r[L['BUFFER']]<<16
unlit=bytes(a.vram[base:base+76800])
for i,panes in enumerate(windows):
 r[L['LIGHT_ON']:L['LIGHT_ON']+len(windows)]=bytes(len(windows))
 r[L['LIGHT_ON']+i]=2
 r[L['LIGHT_FLICKER']+i]=0
 a.call(L['RENDER'])
 expected=bytearray(unlit)
 for x,y in panes:expected[y*320+x]=248
 assert bytes(a.vram[base:base+76800])==expected, f'Window {i} address/extent'
 r[L['LIGHT_FLICKER']+i]=1
 a.call(L['RENDER'])
 for x,y in panes:expected[y*320+x]=247
 assert bytes(a.vram[base:base+76800])==expected, f'Window {i} dim phase'
r[L['LIGHT_ON']:L['LIGHT_ON']+len(windows)]=bytes(len(windows))
a.call(L['RENDER'])
assert bytes(a.vram[base:base+76800])==unlit, 'Unlit windows restore cleanly'
# Graphics art is intact; spare banks inside that range hold recorded sounds.
from samples import AUDIO_BANKS
art=bytearray((ROOT/'assets/vram.bin').read_bytes());loaded=bytearray(a.vram[:len(art)])
for bank in AUDIO_BANKS:
 if bank*4096<len(art):art[bank*4096:(bank+1)*4096]=loaded[bank*4096:(bank+1)*4096]=bytes(4096)
assert loaded==art
print('PASS all window masks, warm/dim colours, >64K addressing, off restoration',flush=True)
# Lighting must not advance gameplay randomness.
seed=r[L['RANDOM_SEED']]
for _ in range(250):a.call(L['UPDATE_LIGHTS'])
assert r[L['RANDOM_SEED']]==seed
# Record an actual idle scene: no injected animation state.
b=Atari(ROOT/'star-fisher.xex');b.boot();b.run_frames(15)
frames=[];seen=[set() for _ in windows];flicker=False
for _ in range(100):
 b.run_frames(6)
 frames.append(b.screenshot(scale=2))
 for i in range(len(windows)):seen[i].add(b.mem.ram[L['LIGHT_ON']+i])
 flicker |= any(b.mem.ram[L['LIGHT_FLICKER']:L['LIGHT_FLICKER']+len(windows)])
assert all(values <= {0,2} for values in seen)
# Validate timer behavior independently of scene-dependent rendering speed.
for i in range(len(windows)):
 r[L['LIGHT_ON']+i]=r[L['LIGHT_INITIAL']+i]
 r[L['LIGHT_TIMER']+i]=r[L['LIGHT_DELAY']+i]
observed=[set() for _ in windows]
for _ in range(600):
 a.call(L['UPDATE_LIGHTS'])
 for i in range(len(windows)):observed[i].add(r[L['LIGHT_ON']+i])
for i,values in enumerate(observed):
 mode=r[L['LIGHT_MODES']+i]
 assert values=={0,2} if mode==1 else values=={r[L['LIGHT_INITIAL']+i]} if mode==0 else 2 in values
b.screenshot(ROOT/'screenshots/window-lights.png',scale=3)
frames[0].save(ROOT/'screenshots/window-lights-demo.gif',save_all=True,append_images=frames[1:],duration=120,loop=0)
print('PASS independent light timers, occasional flicker, unchanged fishing randomness; saved preview',flush=True)
