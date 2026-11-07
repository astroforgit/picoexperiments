"""Recorded sounds for POKEY volume-only playback, shared by build and editor.

Source files live in ../sounds (any format ffmpeg reads). Each clip is cut,
band-limited and resampled by ffmpeg, normalised, scaled by its gain and
quantised to 4 bits, two samples per byte (high nibble first). Timer 1 plays
them at 63337 / (AUDF1 + 1) Hz: clips on channel 2, the wind loop on channel 3.
"""
from pathlib import Path
import json, re, subprocess
import numpy as np
ROOT=Path(__file__).resolve().parents[1]
SOURCES=Path(__import__('os').environ.get('STAR_FISHER_SOUNDS',str(ROOT.parent/'sounds')))
CLOCK=63337
RATES={19:'3.2 kHz',15:'4.0 kHz',13:'4.5 kHz',10:'5.8 kHz'}
MAX_CLIPS=16
# Seconds per excerpt; the playback buffer may set a lower limit at higher rates.
MAX_LENGTH=10
# RAM free for samples: below the MEMAC window, the BASIC area, and RAM under
# the OS ROM (the game runs with the OS off). $FFFA-$FFFF holds the vectors.
REGIONS=[(0x7800,0x9000,'low'),(0xa000,0xc000,'basic'),(0xc000,0xd000,'os'),(0xd800,0xfffa,'os')]
DEFAULTS={'rate': 15, 'wind': {'mode': 'off', 'file': 'A_short,_sharp,_reso_#4-1793835340752.wav', 'start': 0, 'length': 2, 'gain': 85}, 'clips': [{'name': 'Resonance', 'file': 'A_short,_sharp,_reso_#4-1793835340752.wav', 'start': 0, 'length': 2, 'gain': 85, 'perTenMinutes': 6}, {'name': 'Distant echo', 'file': 'Distant,_echoing_int_#1-1793835554153.mp3', 'start': 0, 'length': 1.45, 'gain': 85, 'perTenMinutes': 6}, {'name': 'Distant train', 'file': 'ElevenLabs_A_loud_realistic_train_horn_blasting_in_the_distance,_deep_powerful_tone,_outdoor_railway_environmen.mp3', 'start': 0, 'length': 1.85, 'gain': 85, 'perTenMinutes': 6}, {'name': 'Water shimmer', 'file': 'The_Water_Surface_A__#4-1793835996554.mp3', 'start': 0, 'length': 0.9, 'gain': 85, 'perTenMinutes': 6}], 'delayMin': 5, 'delayMax': 15}

BUNDLED=ROOT/'assets/audio'
AUDIO_SUFFIXES={'.mp3','.wav','.ogg','.oga','.flac','.aif','.aiff','.m4a'}

def sources():
 return sorted({p.name for directory in (BUNDLED,SOURCES) if directory.is_dir()
                for p in directory.iterdir() if p.is_file() and p.suffix.lower() in AUDIO_SUFFIXES})

def source_path(name):
 if not isinstance(name,str) or name not in sources():raise ValueError(f'Unknown sound file: {name}')
 bundled=BUNDLED/name
 return bundled if bundled.is_file() else SOURCES/name

def duration(name):
 out=subprocess.run(['ffprobe','-v','error','-show_entries','format=duration','-of','csv=p=0',str(source_path(name))],capture_output=True,text=True,check=True,timeout=15)
 return float(out.stdout.strip())

def _number(v,lo,hi,label):
 if type(v) not in (int,float) or not lo<=v<=hi:raise ValueError(f'{label} must be a number from {lo} to {hi}')
 return round(float(v),2)

def _int(v,lo,hi,label):
 if type(v)!=int or not lo<=v<=hi:raise ValueError(f'{label} must be an integer from {lo} to {hi}')
 return v

def clip_settings(c,label,loop=False):
 if not isinstance(c,dict):raise ValueError(label+' must be an object')
 out=dict(file=c.get('file'),start=_number(c.get('start',0),0,36000,label+' start'),length=_number(c.get('length',1),.1,MAX_LENGTH,label+' length'),gain=_int(c.get('gain',100),0,200,label+' gain'))
 if not isinstance(out['file'],str) or not re.fullmatch(r'[^/\\]{1,200}',out['file']):raise ValueError(label+' needs a sound file')
 if not loop:
  out['name']=str(c.get('name','Sound'))[:40]
  out['perTenMinutes']=_int(c.get('perTenMinutes',6),0,100,label+' plays per 10 minutes')
 return out

def sample_settings(value):
 if value is None:value=json.loads(json.dumps(DEFAULTS))
 if not isinstance(value,dict):raise ValueError('Sample settings must be an object')
 rate=value.get('rate',DEFAULTS['rate'])
 if rate not in RATES:raise ValueError('Choose a listed sample rate')
 wind=value.get('wind',DEFAULTS['wind'])
 mode=wind.get('mode','recorded') if isinstance(wind,dict) else None
 if mode not in ('recorded','synth','off'):raise ValueError('Wind must be recorded, synth or off')
 clips=value.get('clips',[])
 if not isinstance(clips,list) or len(clips)>MAX_CLIPS:raise ValueError(f'Use at most {MAX_CLIPS} recorded sounds')
 delay_min=_int(value.get('delayMin',5),1,120,'Minimum silence')
 delay_max=_int(value.get('delayMax',15),delay_min,120,'Maximum silence')
 return dict(rate=rate,delayMin=delay_min,delayMax=delay_max,wind=dict(mode=mode,**clip_settings(wind,'Wind loop',True)),clips=[clip_settings(c,f'Sound {i+1}') for i,c in enumerate(clips)])

def hz(rate):return CLOCK/(rate+1)

def levels(clip,rate,loop=False,max_level=15):
 """Quantise to a single DAC or the summed range of three DACs."""
 r=hz(rate);extra=.3 if loop else 0
 cmd=['ffmpeg','-v','error','-ss',str(clip['start']),'-t',str(clip['length']+extra),'-i',str(source_path(clip['file'])),'-ac','1',
      '-af',f'highpass=f=120,lowpass=f={int(r*.45)},aresample={int(round(r))}','-f','f32le','-']
 x=np.frombuffer(subprocess.run(cmd,capture_output=True,check=True).stdout,np.float32).astype(float)
 if not len(x):raise ValueError(f'{clip["file"]}: nothing at {clip["start"]} s')
 x-=x.mean()
 if loop:
  # The loop plays x[:body]. Its head crossfades in from what followed its
  # end, so wrapping from the last sample back to the first stays continuous.
  body=min(len(x),int(clip['length']*r));tail=x[body:];n=min(len(tail),body)
  x=x[:body].copy()
  if n:
   w=np.linspace(0,1,n);x[:n]=x[:n]*w+tail[:n]*(1-w)
 peak=np.max(np.abs(x))
 if peak<1e-7 or clip['gain']==0:return [0]*(len(x)+(len(x)%2))
 midpoint=max_level/2
 y=midpoint+midpoint*np.clip(x/peak*clip['gain']/100,-1,1)
 if not loop:
  # Ease in from and out to level 0 (the idle output) so clips do not click.
  n=min(len(y)//4,int(.02*r))
  if n:
   ramp=np.linspace(0,1,n);y[:n]*=ramp;y[-n:]*=ramp[::-1]
 # Carry part of the rounding error forward. This reduces low-frequency
 # quantisation distortion on sustained chords at the same four-bit depth.
 if max_level>15:
  # Direct rounding avoids a noise-shaped oscillation in quiet passages.
  return np.rint(y).astype(int).tolist()
 out=[]
 error=0.0
 for sample in y:
  target=float(sample)+.65*error
  level=max(0,min(15,round(target)))
  out.append(level)
  error=target-level if 0<=target<=15 else 0.0
 if len(out)%2:out.append(out[0] if loop else 0)
 return out

def pack(lv):return bytes(lv[i]<<4|lv[i+1] for i in range(0,len(lv),2))

def layout(blobs):
 """First-fit decreasing into REGIONS. blobs: {key: bytes} -> {key: address}."""
 free=[[a,b] for a,b,_ in REGIONS];place={}
 for key,data in sorted(blobs.items(),key=lambda kv:-len(kv[1])):
  for f in free:
   if f[1]-f[0]>=len(data):place[key]=f[0];f[0]+=len(data);break
  else:raise ValueError(f'This sample needs {len(data)} contiguous bytes. The largest available block is {max(b-a for a,b in free)} bytes. Shorten the selection or lower its sample rate.')
 return place

def capacity():return sum(b-a for a,b,_ in REGIONS)

# Random one-shots (wind off) live in VBXE memory. During a silent pause the
# main loop copies the next one, a page at a time, into a CPU RAM playback
# buffer; the IRQ then plays it from there exactly as before.
#
# Audited VRAM occupancy (exclusive ends), from build_assets.py, the blits
# and the XDL/blitter setup in star-fisher.asm, sky.asm and bobber-menu.asm:
VRAM_USED=[(0x00000,0x12c00,'background 320x240'),(0x14000,0x15900,'cloud sprite 160x40'),
           (0x16000,0x1f9c0,'bobber popup 240x164'),(0x20000,0x32c00,'framebuffer A'),
           (0x40000,0x52c00,'framebuffer B'),(0x60000,0x6ad70,'cached menu panel, rows 53-138'),
           (0x7e000,0x7e020,'two XDLs'),(0x7f000,0x7f015,'blitter command')]
# Whole 4 KiB MEMAC banks that nothing above touches.
AUDIO_BANKS=[0x13,*range(0x33,0x40),*range(0x53,0x60),*range(0x6b,0x7e)]
VRAM_CAPACITY=len(AUDIO_BANKS)*4096
# Playback buffer: CPU RAM pages free once the game runs (OS, DOS and BASIC
# are off; code ends below $7800, MEMAC is $9000-$9FFF, I/O $D000-$D7FF and
# the vectors sit in the unused page $FF00-$FFFF).
BUFFER_SEGMENTS=[(0x04,0x20),(0x78,0x90),(0xa0,0xd0),(0xd8,0xff)]
BUFFER_PAGES=[p for a,b in BUFFER_SEGMENTS for p in range(a,b)]
BUFFER_CAPACITY=len(BUFFER_PAGES)*256
assert all(not (a<(b+1)*4096 and b*4096<e) for b in AUDIO_BANKS for a,e,_ in VRAM_USED)

def pages(data):return (len(data)+255)//256

def vram_layout(clips,rate,names=None):
 """Pack clips page-aligned into AUDIO_BANKS. clips: [bytes] -> first logical page of each."""
 names=names or [f'Sound {i+1}' for i in range(len(clips))]
 first=[];used=0
 for name,data in zip(names,clips):
  if pages(data)>len(BUFFER_PAGES):
   raise ValueError(f'{name} needs {len(data)} bytes ({len(data)/hz(rate):.2f} s). The playback buffer holds {BUFFER_CAPACITY} bytes ({BUFFER_CAPACITY/hz(rate):.2f} s at {round(hz(rate))} Hz). Shorten it or lower the sample rate.')
  first.append(used);used+=pages(data)
 if used*256>VRAM_CAPACITY:
  raise ValueError(f'Recorded sounds need {used*256} bytes; free VBXE memory holds {VRAM_CAPACITY} bytes ({VRAM_CAPACITY/hz(rate):.1f} s at {round(hz(rate))} Hz). Shorten or remove a sound, or lower the sample rate.')
 return first

def buffer_end(length):
 """CPU address just after the last sample, and its buffer segment."""
 page=BUFFER_PAGES[(length-1)>>8]
 seg=next(i for i,(a,b) in enumerate(BUFFER_SEGMENTS) if a<=page<b)
 return (page<<8|((length-1)&255))+1,seg

def region_of(address):return next(kind for a,b,kind in REGIONS if a<=address<b)
