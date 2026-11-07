"""Native random one-shots: exact DAC levels, bounded silent gaps and mute."""
from pathlib import Path
import sys,json
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'tools'))
from pcm_emu import PcmAtari
from emu import load_labels, FRAME_CYCLES
from samples import levels,hz
L=load_labels(ROOT/'star-fisher.lab')
s=json.loads((ROOT/'editor-scene.json').read_text())['sound']['samples']
assert L['CLIP_HQ']==1 and L['WIND_PCM']==L['WIND_SYNTH']==0
expected=[levels(c,s['rate'],False,45) for c in s['clips']]
a=PcmAtari(ROOT/'star-fisher.xex');a.boot();r=a.mem.ram
get=lambda k:r[L[k]]
assert s['delayMin']<=get('SILENCE_LEFT')<=s['delayMax']
a.run_frames(60)
assert a.irqs==0 and all(not log for log in a.pcm.values())
seen=set()
for trial in range(5):
 # Accelerate only the remaining seconds, then check the last full second.
 r[L['SILENCE_LEFT']]=1;r[L['CLIP_CLOCK']]=50
 before=a.irqs;a.run_frames(48)
 assert a.irqs==before and not get('CLIP_ON')
 start=len(a.pcm[0xd203]);a.run_frames(4)
 assert get('CLIP_ON')
 i=get('LOAD_CLIP')
 seen.add(i)
 # Emulated frames are FRAME_CYCLES long; wait for every sample period.
 a.run_frames(len(expected[i])*a.period()//FRAME_CYCLES+40)
 assert not get('CLIP_ON') and a.irqen==0
 channels=[[v for _,v in a.pcm[addr][start:]] for addr in (0xd203,0xd205,0xd207)]
 assert [sum(v) for v in zip(*channels)]==expected[i],i
 assert s['delayMin']-1<=get('SILENCE_LEFT')<=s['delayMax']
 count=a.irqs;a.run_frames(50)
 assert a.irqs==count and all(a.pokey[i]==0 for i in (1,3,5,7))
print('PASS random selection, initial silence, exact 46-level clips and silent gaps',seen,flush=True)
assert len(seen)>1
# Menu off during a sample freezes playback; On resumes the same clip.
r[L['SILENCE_LEFT']]=1;r[L['CLIP_CLOCK']]=1;a.run_frames(5)
assert get('CLIP_ON')
r[L['MENU_ROW']]=4
def tap(code):
 a.kbcode=code;a.skstat=0xfb;a.run_frames(8)
 a.kbcode=255;a.skstat=255;a.run_frames(8)
tap(0x0c)
assert not get('SOUND_ACTIVE') and not a.irqen
n=a.irqs;a.run_frames(60);assert n==a.irqs
tap(0x0c);assert get('SOUND_ACTIVE') and a.irqs>n
print('PASS menu mute/resume during a random sound')
