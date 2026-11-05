"""Native POKEY ambience: recorded clips (channel 2) and the recorded wind loop
(channel 3) must play exactly the 4-bit levels the editor previews; the
synthesised wind (channel 4) keeps its gentle gusts and silent gaps; idle
sound stops the timer; sound off is silent. Uses tools/pcm_emu.py for IRQs."""
from pathlib import Path
import sys,json,shutil,subprocess,tempfile,os
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'tools'))
from pcm_emu import PcmAtari
from emu import load_labels
from sounds import wind_tables,sound_settings,chances,sample_blobs
from samples import levels,layout,region_of,SOURCES,hz
from scene_model import load_scene
from PIL import Image
scene=load_scene(Image.open(ROOT/'assets/editor-base.png').getpalette())

def build(sound):
 """Build a variant in a temporary copy; returns (labels, xex path, tmp)."""
 tmp=tempfile.TemporaryDirectory();work=Path(tmp.name)/'game';work.mkdir()
 for name in ['tools','gen','assets']:shutil.copytree(ROOT/name,work/name,ignore=shutil.ignore_patterns('__pycache__'))
 for name in ['build.sh','star-fisher.asm','sky.asm','sound.asm','bobber-menu.asm','menu-ui.asm','fishing.asm']:shutil.copy2(ROOT/name,work/name)
 (work/'editor-scene.json').write_text(json.dumps({**scene,'sound':sound}))
 subprocess.run(['bash','build.sh'],cwd=work,check=True,stdout=subprocess.DEVNULL,env=dict(os.environ,STAR_FISHER_SOUNDS=str(SOURCES)))
 return load_labels(work/'star-fisher.lab'),work/'star-fisher.xex',tmp

def unpack(data):return [v for b in data for v in (b>>4,b&15)]

# Exercise both streams using only the bundled source, including on clean checkouts.
loop=dict(mode='recorded',file='Crackle_of_the_Cosmo_#1-1793835899954.mp3',start=0,length=3.4,gain=100)
effect=dict(name='Test phrase',file=loop['file'],start=.25,length=1.3,gain=80,perTenMinutes=6)
sound=sound_settings(dict(enabled=True,samples=dict(rate=10,wind=loop,clips=[effect])))
L,xex,tmp=build(sound)
assert (L['SOUND_ENABLED'],L['WIND_PCM'],L['WIND_SYNTH'],L['CLIP_COUNT'])==(1,1,0,len(sound['samples']['clips']))
a=PcmAtari(xex);a.boot();r=a.mem.ram
blobs=sample_blobs(sound);place=layout(blobs)
for key,data in blobs.items():
 assert bytes(r[place[key]:place[key]+len(data)])==data,f'Sample {key} at ${place[key]:04x} ({region_of(place[key])})'
print(f'PASS {len(blobs)} samples, {sum(map(len,blobs.values()))} bytes, loaded into low, BASIC and under-OS RAM',flush=True)

# Wind loop: channel 3 plays the loop's levels continuously, wrapping seamlessly.
a.run_frames(30);start=len(a.pcm[0xD205]);a.run_frames(250)
played=[v for _,v in a.pcm[0xD205][start:]];loop=unpack(blobs['wind'])
assert len(played)>len(loop)+10,'Recorded wind must keep looping'
at=next(k for k in range(len(loop)) if all(played[i]==loop[(k+i)%len(loop)] for i in range(64)))
assert all(v==loop[(at+i)%len(loop)] for i,v in enumerate(played)),'Wind loop must play every nibble in order'
assert abs(levels(sound['samples']['wind'],sound['samples']['rate'],True)[-1]-loop[0])<=4,'Loop seam must be smooth'
print(f'PASS recorded wind: {len(played)} samples on channel 3 follow the {len(loop)}-sample loop',flush=True)

# Each clip: force it with the chance table, then compare every played nibble.
for i,clip in enumerate(sound['samples']['clips']):
 for j in range(L['CLIP_COUNT']):r[L['CLIP_CHANCE']+j]=0 if j<i else 255
 r[L['CLIP_CLOCK']]=2;start=len(a.pcm[0xD203])
 expected=unpack(blobs[i])
 a.run_frames(int(len(expected)/hz(sound['samples']['rate'])*50)+10)
 assert r[L['CLIP_ON']]==0,clip['name']+' must finish'
 played=[v for _,v in a.pcm[0xD203][start:]]
 assert played[:len(expected)]==expected,clip['name']
 r[L['CLIP_CHANCE']:L['CLIP_CHANCE']+L['CLIP_COUNT']]=bytes(L['CLIP_COUNT'])
 a.run_frames(60);assert len(a.pcm[0xD203])==start+len(expected),'One clip at a time; none while chances are zero'
 print(f'PASS {clip["name"]}: {len(expected)} samples on channel 2 match the editor preview',flush=True)
t=L['TICKS'];x=r[t];a.run_frames(100);rate=(r[t]-x)%256
print(f'PASS game keeps running with the wind loop: {rate} updates in 2 s',flush=True)
assert chances(sound)==sorted(chances(sound)) and chances(sound)[-1]<=255
tmp.cleanup()

# Music-only playback spans RAM regions. Each IRQ writes three 4-bit DACs.
clean_track=dict(mode='recorded',file='Crackle_of_the_Cosmo_#1-1793835899954.mp3',start=0,length=4.8,gain=100)
clean=sound_settings(dict(enabled=True,samples=dict(rate=15,wind=clean_track,clips=[])))
L,xex,tmp=build(clean)
assert L['AMBIENT_HQ']==1 and L['AMBIENT_CHUNKS']>1
music=PcmAtari(xex);music.boot();music.run_frames(315)
expected=levels(clean_track,15,True,45)
channels=[[v for _,v in music.pcm[addr]] for addr in (0xD203,0xD205,0xD207)]
played=[sum(tick) for tick in zip(*channels)]
assert len(played)>len(expected)
assert all(value==expected[i%len(expected)] for i,value in enumerate(played))
# Reach the sound row through actual keyboard navigation and toggle it.
r=music.mem.ram
def tap(code):
 music.kbcode=code;music.skstat=0xfb;music.run_frames(8)
 music.kbcode=255;music.skstat=255;music.run_frames(8)
assert r[L['STATE']]==7 and r[L['SOUND_ACTIVE']]==1
for _ in range(4):tap(0x0f)
assert r[L['MENU_ROW']]==4
tap(0x0c)
assert r[L['SOUND_ACTIVE']]==0 and music.irqen==0
assert all(music.pokey[i]==0 for i in (1,3,5,7))
paused=r[L['AMBIENT_PTR']]|r[L['AMBIENT_PTR']+1]<<8
irqs=music.irqs;music.run_frames(60)
assert music.irqs==irqs
assert paused==r[L['AMBIENT_PTR']]|r[L['AMBIENT_PTR']+1]<<8
tap(0x0c)
assert r[L['SOUND_ACTIVE']]==1 and music.irqen==1 and music.irqs>irqs
music.screenshot(ROOT/'screenshots/sound-menu.png',scale=3)
tap(0x0c)
assert r[L['SOUND_ACTIVE']]==0
music.call(L['RESET_GAME'])
assert r[L['SOUND_ACTIVE']]==0,'New nights preserve the sound preference'
tmp.cleanup()
print('PASS clean ambient loop, menu sound toggle, silent IRQ shutdown and resume',flush=True)

# Synthesised wind: noise on channel 4, gentle gusts with silent gaps; the
# timer runs only while a clip plays.
synth={**sound,'samples':{**sound['samples'],'wind':{**sound['samples']['wind'],'mode':'synth'}}}
L,xex,tmp=build(synth)
assert (L['WIND_PCM'],L['WIND_SYNTH'])==(0,1)
b=PcmAtari(xex);b.boot();b.run_frames(200)
vol,freq=wind_tables(synth['wind']);log=b.pokey_log[-150:]
assert {f[7]>>4 for f in log}<={0,8} and {f[7]&15 for f in log}<=set(vol)
assert all(min(freq)<=f[6]<=max(freq)+synth['wind']['flutter'] for f in log)
assert all(abs(p-q)<=1 for p,q in zip(vol,vol[1:]+vol[:1])),'Wind must fade gently'
assert sum(v==0 for v in vol)>=32,'Wind must include long silent gaps'
br=b.mem.ram;br[L['CLIP_CHANCE']:L['CLIP_CHANCE']+L['CLIP_COUNT']]=bytes(L['CLIP_COUNT']);b.run_frames(60)
assert b.irqen&1==0,'Idle sound must stop the timer'
n=b.irqs;b.run_frames(50);assert b.irqs==n,'No IRQs while idle'
print('PASS synthesised wind on channel 4; timer off while no clip plays',flush=True)
tmp.cleanup()

# Sound off: no audio and no IRQs.
L,xex,tmp=build({**sound,'enabled':False})
c=PcmAtari(xex);c.boot();c.run_frames(600)
assert all(not any(f[i]&15 for i in (1,3,5,7)) for f in c.pokey_log) and not c.irqs and not c.pcm[0xD203] and not c.pcm[0xD205],'Sound off must be silent'
tmp.cleanup()
print('PASS sound off is fully silent')
