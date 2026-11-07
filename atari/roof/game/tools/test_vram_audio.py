"""Recorded sounds in spare VBXE memory, copied to the RAM playback buffer.

- Every clip is uploaded to the audited free banks; nothing else lands there.
- A long play session (menu, bobber popup, sound toggle, casting, random
  clips) never writes VRAM outside the audited graphics ranges, and never
  changes the background, cloud or popup art.
- Each clip is copied byte-exactly into the playback buffer pages; copying
  happens only during pauses, so playback is never interrupted.
- A clip spanning all four buffer segments plays every level in order with
  no lost or late samples.
- Loading does not cost a frame: presents and screens match a no-load run.
"""
from pathlib import Path
import sys,json,shutil,subprocess,tempfile,os,hashlib
import numpy as np
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'tools'))
from pcm_emu import PcmAtari
from emu import load_labels, FRAME_CYCLES
from sounds import sound_settings,sample_blobs
from samples import (AUDIO_BANKS,VRAM_USED,BUFFER_PAGES,BUFFER_SEGMENTS,BUFFER_CAPACITY,
                     VRAM_CAPACITY,vram_layout,pages,levels,hz,SOURCES)

def build(sound):
 """Build a variant in a temporary copy; returns (labels, xex path, tmp)."""
 tmp=tempfile.TemporaryDirectory();work=Path(tmp.name)/'game';work.mkdir()
 for name in ['tools','gen','assets']:shutil.copytree(ROOT/name,work/name,ignore=shutil.ignore_patterns('__pycache__'))
 for name in ['build.sh','star-fisher.asm','sky.asm','sound.asm','bobber-menu.asm','menu-ui.asm','fishing.asm']:shutil.copy2(ROOT/name,work/name)
 scene=json.loads((ROOT/'editor-scene.json').read_text())
 (work/'editor-scene.json').write_text(json.dumps({**scene,'sound':sound}))
 subprocess.run(['bash','build.sh'],cwd=work,check=True,stdout=subprocess.DEVNULL,env=dict(os.environ,STAR_FISHER_SOUNDS=str(SOURCES)))
 return load_labels(work/'star-fisher.lab'),work/'star-fisher.xex',tmp

def clip_data(sound):
 blobs=sample_blobs(sound);return [blobs[i] for i in range(len(sound['samples']['clips']))]

def bank_image(clips):
 """Expected contents of the audio banks, in AUDIO_BANKS order."""
 data=b''.join(c+bytes(pages(c)*256-len(c)) for c in clips)
 return data+bytes(-len(data)%4096)

def check_upload(a,clips):
 image=bank_image(clips)
 for i in range(0,len(image),4096):
  b=AUDIO_BANKS[i//4096]
  assert bytes(a.vram[b*4096:(b+1)*4096])==image[i:i+4096],f'Audio bank ${b:02x}'

def buffer_bytes(r,n):return b''.join(bytes(r[p<<8:(p<<8)+256]) for p in BUFFER_PAGES[:pages(bytes(n))])[:n]

def load(a,L,i,limit=200):
 r=a.mem.ram;r[L['LOAD_CLIP']]=i;r[L['LOAD_STATE']]=L['LOAD_REQUEST']
 for f in range(limit):
  a.run_frames(1)
  if r[L['LOAD_STATE']]==L['LOAD_READY']:return f+1
 raise AssertionError(f'Clip {i} did not load')

def tap(a,code):
 a.kbcode=code;a.skstat=0xfb;a.run_frames(8)
 a.kbcode=255;a.skstat=255;a.run_frames(8)

# ---------------------------------------------------------------- project
L=load_labels(ROOT/'star-fisher.lab')
sound=sound_settings(json.loads((ROOT/'editor-scene.json').read_text())['sound'])
s=sound['samples'];assert L['CLIP_HQ']==1 and L['CLIP_COUNT']==len(s['clips'])
clips=clip_data(sound);vram_layout(clips,s['rate'])
a=PcmAtari(ROOT/'star-fisher.xex');a.boot();r=a.mem.ram;a.run_frames(2)
check_upload(a,clips)
boot=a.vram.copy()
print(f'PASS {len(clips)} clips, {sum(map(len,clips))} bytes ({sum(map(len,clips))/hz(s["rate"]):.1f} s), uploaded to {len(bank_image(clips))//4096} of {len(AUDIO_BANKS)} free VBXE banks',flush=True)

# Each clip lands byte-exactly in the buffer pages, quickly enough for the
# shortest pause.
timing={}
for i,c in enumerate(clips):
 timing[i]=load(a,L,i)
 assert buffer_bytes(r,len(c))==c,f'Clip {i} buffer'
big=max(range(len(clips)),key=lambda i:len(clips[i]))
rate_pages=pages(clips[big])/timing[big]
# A late load only delays the next clip; still, it should fit the 1 s minimum pause.
assert timing[big]<=50,f'Longest clip took {timing[big]} frames to load'
print(f'PASS every clip copies exactly into the playback buffer; the longest ({pages(clips[big])} pages) loads in {timing[big]/50:.2f} s, {rate_pages:.1f} pages per frame in the menu',flush=True)

# Long session: menu, popup, sound toggle, a night of casting with random
# clips. Silences are shortened so many clips load and play.
r[L['LOAD_STATE']]=L['LOAD_REQUEST'];r[L['SILENCE_LEFT']]=1
overlap=0;started=set()
def frames(n,**inputs):
 global overlap
 for _ in range(n):
  a.set_input(**inputs);a.run_frames(1)
  if r[L['CLIP_ON']]:
   started.add(r[L['LOAD_CLIP']] if r[L['LOAD_STATE']]==L['LOAD_IDLE'] else None)
   overlap+=r[L['LOAD_STATE']]==L['LOAD_COPY']
  elif r[L['SILENCE_LEFT']]>1:r[L['SILENCE_LEFT']]=1
frames(80)
tap(a,0x15);frames(20);tap(a,0x1c)            # bobber popup open/close
r[L['MENU_ROW']]=4;tap(a,0x0c);frames(60);tap(a,0x0c)   # sound off and on
r[L['MENU_ROW']]=0;tap(a,0x0c);frames(30)      # play
for cast in range(4):
 frames(18,trig=1);frames(220)
 frames(30,trig=1);frames(120)
assert overlap==0,'A clip must never be copied while one plays'
assert len(started-{None})>=3,started
dynamic=[(a0,e) for a0,e,name in VRAM_USED if name.startswith(('framebuffer','cached','two XDL','blitter'))]
mask=np.ones(len(a.vram),bool)
for a0,e in dynamic:mask[a0:e]=False
changed=np.flatnonzero((a.vram!=boot)&mask)
assert not len(changed),'VRAM written outside the audited ranges: '+', '.join(f'${x:05x}' for x in changed[:8])
check_upload(a,clips)
print(f'PASS {a.frame} frames of play: art, audio banks and spare VRAM unchanged; {len(started-{None})} different clips played; no copy during playback',flush=True)

# Loading costs no frames: presents and screens match a run without loads.
def session(loading):
 b=PcmAtari(ROOT/'star-fisher.xex');b.boot();br=b.mem.ram;br[L['SOUND_ACTIVE']]=0;shots=[]
 for f in range(240):
  if loading and br[L['LOAD_STATE']] in (L['LOAD_IDLE'],L['LOAD_READY']):br[L['LOAD_CLIP']]=f%len(clips);br[L['LOAD_STATE']]=L['LOAD_REQUEST']
  if not loading:br[L['LOAD_STATE']]=L['LOAD_IDLE']
  b.set_input(trig=1 if 60<=f<75 or 150<=f<165 else 0);b.run_frames(1)
  if f%4==0:shots.append(hashlib.md5(b.screenshot(None,scale=1).tobytes()).hexdigest())
 return b.xdl_writes,shots,br[L['TICKS']]
with_load,without=session(True),session(False)
assert with_load==without,'Loading must not delay or change any presented frame'
print(f'PASS constant loading: {len(with_load[0])} presents and {len(with_load[1])} screens identical to a no-load run',flush=True)

# ------------------------------------------------- all four buffer segments
long_clip=dict(name='Long',file='Crackle_of_the_Cosmo_#1-1793835899954.mp3',start=0,length=8,gain=85,perTenMinutes=6)
short_clip=dict(name='Short',file='Distant,_echoing_int_#1-1793835554153.mp3',start=0,length=1,gain=85,perTenMinutes=6)
variant=sound_settings(dict(enabled=True,samples=dict(rate=15,wind=dict(s['wind']),clips=[long_clip,short_clip],delayMin=1,delayMax=1)))
L2,xex,tmp=build(variant)
vclips=clip_data(variant);assert pages(vclips[0])>sum(b-a for a,b in BUFFER_SEGMENTS[:3]),'Variant must reach the last buffer segment'
b=PcmAtari(xex);b.boot();br=b.mem.ram;b.run_frames(2)
check_upload(b,vclips)
load(b,L2,0);br[L2['SILENCE_LEFT']]=0
start=len(b.pcm[0xd203]);b.run_frames(3);assert br[L2['CLIP_ON']]
expected=levels(long_clip,15,False,45)
b.run_frames(len(expected)*b.period()//FRAME_CYCLES+20)
assert not br[L2['CLIP_ON']] and b.irqen==0
log=[b.pcm[addr][start:] for addr in (0xd203,0xd205,0xd207)]
assert [sum(v for _,v in t) for t in zip(*log)]==expected,'Every level must play in order across all buffer segments'
times=[t for t,_ in log[0]];period=b.period();gaps=np.diff(times)
assert gaps.max()<2*period,f'Late sample: {gaps.max()} cycles (period {period})'
assert br[L2['LOAD_STATE']] in (L2['LOAD_REQUEST'],L2['LOAD_COPY'],L2['LOAD_READY']),'Next clip is chosen when one ends'
tmp.cleanup()
print(f'PASS {len(expected)} samples ({len(expected)/hz(15):.2f} s) across {len(BUFFER_SEGMENTS)} buffer segments; max sample gap {gaps.max()} cycles (period {period})')
