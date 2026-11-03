"""Night ambience for POKEY, shared by the native build and the editor preview.

Recorded sounds (tools/samples.py) play as 4-bit volume-only samples from a
POKEY timer 1 IRQ: occasional clips on channel 2 and, optionally, a looping
recorded wind on channel 3. The wind can instead be synthesised on channel 4,
following Slayder (slay.atr, SLAYDER.XEX $52f0): distortion 8 noise. Our
quieter adaptation uses a higher noise clock, a smooth gust envelope and
silent gaps. The editor previews the synthesised wind through ASAP and the
recorded sounds from their exact 4-bit levels.
"""
import math, random
from samples import sample_settings, levels, pack, layout, region_of, hz, capacity

WIND_DEFAULTS=dict(volume=2,pitch=40,gust=3,speed=1,flutter=0)
WIND_LIMITS=dict(volume=15,pitch=255,gust=15,speed=15,flutter=15)
def _int(n,lo,hi,label):
 if type(n)!=int or not lo<=n<=hi:raise ValueError(f'{label} must be an integer from {lo} to {hi}')
 return n

def sound_settings(value):
 if value is None:value={}
 if not isinstance(value,dict):raise ValueError('Sound settings must be an object')
 wind=value.get('wind',{})
 if not isinstance(wind,dict):raise ValueError('Invalid wind settings')
 clean_wind={k:_int(wind.get(k,v),0,WIND_LIMITS[k],'Wind '+k) for k,v in WIND_DEFAULTS.items()}
 return dict(enabled=bool(value.get('enabled',False)),wind=clean_wind,samples=sample_settings(value.get('samples')))

def chances(sound):
 """Per-second start thresholds out of 256, cumulative, never above 255."""
 raw=[c['perTenMinutes']*256/600 for c in sound['samples']['clips']]
 scale=min(1,250/sum(raw)) if sum(raw) else 0
 total=0;out=[]
 for r in raw:total+=round(r*scale);out.append(min(255,total))
 return out

# ------------------------------------------------------------------- wind
def wind_tables(wind):
 """A passing gust, then silence. No continuous low-frequency noise bed.

 Same distortion-8 POKEY mode as Slayder, with a higher noise clock and
 lower volume. The middle half of the cycle fades in/out; the other half
 is silent. Zero speed holds the silent starting point.
 """
 vol=[];freq=[]
 for i in range(64):
  envelope=math.sin(math.pi*(i-16)/32)**2 if 16<i<48 else 0
  vol.append(max(0,min(15,round(wind['volume']*(1+wind['gust']*.05)*envelope))))
  freq.append(max(0,min(255,wind['pitch']-round(wind['gust']*envelope))))
 return vol,freq

def wind_preview(sound):
 vol,freq=wind_tables(sound['wind'])
 return dict(volume=vol,freq=freq,speed=sound['wind']['speed'],flutter=sound['wind']['flutter'])

def sample_blobs(sound):
 s=sound['samples'];blobs={}
 if s['wind']['mode']=='recorded':blobs['wind']=pack(levels(s['wind'],s['rate'],True))
 for i,c in enumerate(s['clips']):blobs[i]=pack(levels(c,s['rate']))
 return blobs

def usage(sound):
 blobs=sample_blobs(sound)
 return dict(bytes=sum(map(len,blobs.values())),capacity=capacity(),rate=round(hz(sound['samples']['rate'])))

def asm_tables(sound,gen):
 """Constants and tables for gen/tables.asm; sample data segments to gen (gen/samples.asm)."""
 s=sound['samples'];on=sound['enabled']
 blobs=sample_blobs(sound) if on else {}
 place=layout(blobs)
 pcm_wind=on and s['wind']['mode']=='recorded';clips=s['clips'] if on else []
 lines=[f'SOUND_ENABLED = {int(on)}',f"WIND_SYNTH = {int(on and s['wind']['mode']=='synth')}",f'WIND_PCM = {int(pcm_wind)}',
        f'CLIP_COUNT = {len(clips)}',f"PCM_AUDF = {s['rate']}",
        f"WIND_SPEED = {sound['wind']['speed']*16}",f"WIND_FLUTTER = {sound['wind']['flutter']}"]
 lines+=[f"WIND_START = {place['wind']}",f"WIND_END = {place['wind']+len(blobs['wind'])}"] if pcm_wind else ['WIND_START = 0','WIND_END = 0']
 vol,freq=wind_tables(sound['wind'])
 lines.append('wind_vol\n        dta '+','.join(str(0x80|v if v else 0) for v in vol))
 lines.append('wind_freq\n        dta '+','.join(map(str,freq)))
 starts=[place[i] for i in range(len(clips))];ends=[place[i]+len(blobs[i]) for i in range(len(clips))]
 for label,values in [('clip_lo',[a&255 for a in starts]),('clip_hi',[a>>8 for a in starts]),('clip_end_lo',[a&255 for a in ends]),
                      ('clip_end_hi',[a>>8 for a in ends]),('clip_chance',chances(sound) if clips else [])]:
  lines.append(label+'\n        dta '+','.join(map(str,values or [0])))
 # RAM under the OS is staged at $A000 and copied there with the OS switched
 # out, in ascending order (copies are whole pages, so a later blob simply
 # overwrites an earlier copy's tail). Direct loads into $A000-$BFFF go last.
 for old in gen.parent.glob('sample_*.bin'):old.unlink()
 seg=[];direct=[];staged=[];n=0
 for key,data in blobs.items():(staged if region_of(place[key])=='os' else direct).append((place[key],data))
 for address,data in sorted(staged):
  for off in range(0,len(data),0x2000):
   chunk=data[off:off+0x2000];name=f'sample_{n}.bin';(gen.parent/name).write_bytes(chunk);n+=1
   seg.append(f"        org os_copy_dest\n        dta a({address+off}),{(len(chunk)+255)//256}\n        org $a000\n        ins 'gen/{name}'\n        ini os_copy")
 for address,data in sorted(direct,key=lambda d:(d[0]>=0xa000,d[0])):
  name=f'sample_{n}.bin';(gen.parent/name).write_bytes(data);n+=1
  seg.append(f"        org {address}\n        ins 'gen/{name}'")
 gen.write_text('\n'.join(seg)+'\n')
 return lines
