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
from samples import AUDIO_BANKS, BUFFER_PAGES, BUFFER_SEGMENTS, BUFFER_CAPACITY, VRAM_CAPACITY, vram_layout, buffer_end, pages

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

def clean_ambient(settings):
 return settings['wind']['mode']=='recorded' and not settings['clips']

def ambient_chunk_keys(blobs):
 return [key for key in blobs if isinstance(key,str) and key.startswith('ambient_')]

def sample_blobs(sound):
 s=sound['samples'];blobs={}
 if clean_ambient(s):
  audio=bytes(levels(s['wind'],s['rate'],True,45))
  # Each chunk must fit a single CPU address range. Advance without a gap at
  # its end. Up to 8 KiB also fits the existing under-ROM staging buffer.
  for offset in range(0,len(audio),8192):
   blobs[f'ambient_{offset}']=audio[offset:offset+8192]
 elif s['wind']['mode']=='recorded':
  blobs['wind']=pack(levels(s['wind'],s['rate'],True))
 for i,c in enumerate(s['clips']):blobs[i]=bytes(levels(c,s['rate'],False,45)) if s['wind']['mode']=='off' else pack(levels(c,s['rate']))
 return blobs

def vram_clips(settings):
 """Random one-shots (wind off) are stored in VBXE memory, not CPU RAM."""
 return settings['wind']['mode']=='off' and bool(settings['clips'])

def ram_blobs(sound,blobs):
 return {k:v for k,v in blobs.items() if not (vram_clips(sound['samples']) and isinstance(k,int))}

def usage(sound,strict=True):
 """Memory budget. strict=False (the editor meter) reports overruns instead of raising."""
 s=sound['samples'];blobs=sample_blobs(sound);rate=hz(s['rate'])
 if vram_clips(s):
  clips=[blobs[i] for i in range(len(s['clips']))]
  error=None
  try:vram_layout(clips,s['rate'],[c['name'] for c in s['clips']])
  except ValueError as e:
   if strict:raise
   error=str(e)
  longest=max(map(len,clips))
  return dict(storage='vbxe',bytes=sum(pages(c) for c in clips)*256,capacity=VRAM_CAPACITY,rate=round(rate),
              clips=len(clips),seconds=round(sum(map(len,clips))/rate,2),capacitySeconds=round(VRAM_CAPACITY/rate,2),
              longest=longest,buffer=BUFFER_CAPACITY,longestSeconds=round(longest/rate,2),bufferSeconds=round(BUFFER_CAPACITY/rate,2),
              perClip=[dict(bytes=pages(c)*256,seconds=round(len(c)/rate,2),fits=pages(c)*256<=BUFFER_CAPACITY) for c in clips],error=error)
 layout(blobs)
 return dict(storage='ram',bytes=sum(map(len,blobs.values())),capacity=capacity(),rate=round(rate))

def vram_tables(clips,rate):
 """Tables for the page copier (sound_load) and the segmented IRQ playback."""
 first=vram_layout(clips,rate)
 ends=[buffer_end(len(c)) for c in clips]
 count=len(clips);mask=(1<<(count-1).bit_length())-1
 rows=[('audio_banks',[0x80|b for b in AUDIO_BANKS]),('buffer_pages',BUFFER_PAGES),
       ('seg_start_hi',[a for a,b in BUFFER_SEGMENTS]),('seg_end_hi',[b for a,b in BUFFER_SEGMENTS]),
       ('clip_bank_index',[f>>4 for f in first]),('clip_bank_page',[0x90|f&15 for f in first]),
       ('clip_pages',[pages(c) for c in clips]),('clip_last_seg',[s for e,s in ends]),
       ('clip_end_lo',[e&255 for e,s in ends]),('clip_end_hi',[e>>8 for e,s in ends])]
 return [f'CLIP_MASK = {mask}']+[label+'\n        dta '+','.join(map(str,values)) for label,values in rows]

def vram_segments(clips,gen,n):
 """XEX segments: each 4 KiB bank is staged at $A000, then upload_bank copies it."""
 data=b''.join(c+bytes(pages(c)*256-len(c)) for c in clips)
 seg=[]
 for i in range(0,len(data),4096):
  chunk=data[i:i+4096];name=f'sample_{n}.bin';(gen.parent/name).write_bytes(chunk+bytes(4096-len(chunk)));n+=1
  seg.append(f"        org load_bank\n        dta {AUDIO_BANKS[i//4096]}\n        org $a000\n        ins 'gen/{name}'\n        ini upload_bank")
 return seg

def asm_tables(sound,gen):
 """Constants and tables for gen/tables.asm; sample data segments to gen (gen/samples.asm)."""
 s=sound['samples'];on=sound['enabled']
 all_blobs=sample_blobs(sound) if on else {}
 hq=on and vram_clips(s)
 blobs=ram_blobs(sound,all_blobs)
 place=layout(blobs)
 pcm_wind=on and s['wind']['mode']=='recorded';clips=s['clips'] if on else []
 chunks=ambient_chunk_keys(blobs)
 lines=[f"CLIP_HQ = {int(on and s['wind']['mode']=='off' and bool(clips))}",f"SILENCE_MIN = {s['delayMin']}",f"SILENCE_RANGE = {s['delayMax']-s['delayMin']+1}",f'AMBIENT_HQ = {int(bool(chunks))}',f'SOUND_ENABLED = {int(on)}',f"WIND_SYNTH = {int(on and s['wind']['mode']=='synth')}",f'WIND_PCM = {int(pcm_wind)}',
        f'CLIP_COUNT = {len(clips)}',f"PCM_AUDF = {s['rate']}",
        f"WIND_SPEED = {sound['wind']['speed']*16}",f"WIND_FLUTTER = {sound['wind']['flutter']}"]
 lines+=[f"WIND_START = {place['wind']}",f"WIND_END = {place['wind']+len(blobs['wind'])}"] if pcm_wind and not chunks else ['WIND_START = 0','WIND_END = 0']
 if chunks:
  lines.append(f'AMBIENT_CHUNKS = {len(chunks)}')
  for prefix,addresses in [('start',[place[k] for k in chunks]),('end',[place[k]+len(blobs[k]) for k in chunks])]:
   for part,shift in [('lo',0),('hi',8)]:
    lines.append(f'ambient_{prefix}_{part} dta '+','.join(str((v>>shift)&255) for v in addresses))
 if chunks or (on and s['wind']['mode']=='off' and clips):
  # Share each target level evenly across the three volume-only channels.
  for channel in range(3):
   values=[16+v//3+int(v%3>channel) for v in range(46)]
   lines.append(f'ambient_dac_{channel} dta '+','.join(map(str,values)))
 vol,freq=wind_tables(sound['wind'])
 lines.append('wind_vol\n        dta '+','.join(str(0x80|v if v else 0) for v in vol))
 lines.append('wind_freq\n        dta '+','.join(map(str,freq)))
 if hq:
  lines+=vram_tables([all_blobs[i] for i in range(len(clips))],s["rate"])
 else:
  starts=[place[i] for i in range(len(clips))];ends=[place[i]+len(blobs[i]) for i in range(len(clips))]
  for label,values in [('clip_lo',[a&255 for a in starts]),('clip_hi',[a>>8 for a in starts]),('clip_end_lo',[a&255 for a in ends]),
                       ('clip_end_hi',[a>>8 for a in ends])]:
   lines.append(label+'\n        dta '+','.join(map(str,values or [0])))
 lines.append('clip_chance\n        dta '+','.join(map(str,(chances(sound) if clips else []) or [0])))
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
 if hq:seg+=vram_segments([all_blobs[i] for i in range(len(clips))],gen,n)
 gen.write_text('\n'.join(seg)+'\n')
 return lines
