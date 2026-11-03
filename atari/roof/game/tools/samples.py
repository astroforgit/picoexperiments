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
MAX_CLIPS=6
# RAM free for samples: below the MEMAC window, the BASIC area, and RAM under
# the OS ROM (the game runs with the OS off). $FFFA-$FFFF holds the vectors.
REGIONS=[(0x7800,0x9000,'low'),(0xa000,0xc000,'basic'),(0xc000,0xd000,'os'),(0xd800,0xfffa,'os')]
CITY='freesound_community-quiet-city-square-night-19743.mp3'
BREEZE='freesound_community-lonely-winter-breeze-36867.mp3'
DEFAULTS=dict(rate=13,
 wind=dict(mode='recorded',file=BREEZE,start=2.0,length=3.5,gain=70),
 clips=[dict(name='City sound 1',file=CITY,start=310.2,length=1.4,gain=100,perTenMinutes=6),
        dict(name='City sound 2',file=CITY,start=314.2,length=2.4,gain=100,perTenMinutes=6),
        dict(name='City sound 3',file=CITY,start=656.0,length=2.4,gain=100,perTenMinutes=6)])

def sources():
 return sorted(p.name for p in SOURCES.iterdir() if p.is_file() and p.suffix.lower() in ('.mp3','.wav','.ogg','.oga','.flac','.aif','.aiff','.m4a')) if SOURCES.exists() else []

def source_path(name):
 if not isinstance(name,str) or name not in sources():raise ValueError(f'Unknown sound file: {name}')
 return SOURCES/name

def duration(name):
 out=subprocess.run(['ffprobe','-v','error','-show_entries','format=duration','-of','csv=p=0',str(source_path(name))],capture_output=True,text=True,check=True)
 return float(out.stdout.strip())

def _number(v,lo,hi,label):
 if type(v) not in (int,float) or not lo<=v<=hi:raise ValueError(f'{label} must be a number from {lo} to {hi}')
 return round(float(v),2)

def _int(v,lo,hi,label):
 if type(v)!=int or not lo<=v<=hi:raise ValueError(f'{label} must be an integer from {lo} to {hi}')
 return v

def clip_settings(c,label,loop=False):
 if not isinstance(c,dict):raise ValueError(label+' must be an object')
 out=dict(file=c.get('file'),start=_number(c.get('start',0),0,36000,label+' start'),length=_number(c.get('length',1),.1,8,label+' length'),gain=_int(c.get('gain',100),0,200,label+' gain'))
 if not isinstance(out['file'],str) or not re.fullmatch(r'[^/\\]{1,200}',out['file']):raise ValueError(label+' needs a sound file')
 if not loop:
  out['name']=str(c.get('name','Sound'))[:40]
  out['perTenMinutes']=_int(c.get('perTenMinutes',6),0,100,label+' plays per 10 minutes')
 return out

def sample_settings(value):
 if value is None:value=json.loads(json.dumps(DEFAULTS))
 if not isinstance(value,dict):raise ValueError('Sample settings must be an object')
 rate=value.get('rate',13)
 if rate not in RATES:raise ValueError('Choose a listed sample rate')
 wind=value.get('wind',DEFAULTS['wind'])
 mode=wind.get('mode','recorded') if isinstance(wind,dict) else None
 if mode not in ('recorded','synth'):raise ValueError('Wind must be recorded or synth')
 clips=value.get('clips',[])
 if not isinstance(clips,list) or len(clips)>MAX_CLIPS:raise ValueError(f'Use at most {MAX_CLIPS} recorded sounds')
 return dict(rate=rate,wind=dict(mode=mode,**clip_settings(wind,'Wind loop',True)),clips=[clip_settings(c,f'Sound {i+1}') for i,c in enumerate(clips)])

def hz(rate):return CLOCK/(rate+1)

def levels(clip,rate,loop=False):
 """Cut, filter, resample and quantise one clip to 4-bit levels (0-15)."""
 r=hz(rate);extra=.3 if loop else 0
 cmd=['ffmpeg','-v','error','-ss',str(clip['start']),'-t',str(clip['length']+extra),'-i',str(source_path(clip['file'])),'-ac','1',
      '-af',f'highpass=f=120,lowpass=f={int(r*.45)},aresample={int(round(r))}','-f','f32le','-']
 x=np.frombuffer(subprocess.run(cmd,capture_output=True,check=True).stdout,np.float32).astype(float)
 if not len(x):raise ValueError(f'{clip["file"]}: nothing at {clip["start"]} s')
 x-=x.mean()
 if loop:
  # The loop plays x[:body]. Its head crossfades in from what followed its
  # end, so wrapping from the last sample back to the first stays continuous.
  body=min(len(x),int(clip['length']*r));tail=x[body:];n=len(tail)
  x=x[:body].copy()
  if n:
   w=np.linspace(0,1,n);x[:n]=x[:n]*w+tail*(1-w)
 peak=np.max(np.abs(x)) or 1
 y=7.5+7.5*np.clip(x/peak*clip['gain']/100,-1,1)
 if not loop:
  # Ease in from and out to level 0 (the idle output) so clips do not click.
  n=min(len(y)//4,int(.02*r))
  if n:
   ramp=np.linspace(0,1,n);y[:n]*=ramp;y[-n:]*=ramp[::-1]
 out=np.clip(np.round(y),0,15).astype(int).tolist()
 if len(out)%2:out.append(out[0] if loop else 0)
 return out

def pack(lv):return bytes(lv[i]<<4|lv[i+1] for i in range(0,len(lv),2))

def layout(blobs):
 """First-fit decreasing into REGIONS. blobs: {key: bytes} -> {key: address}."""
 free=[[a,b] for a,b,_ in REGIONS];place={}
 for key,data in sorted(blobs.items(),key=lambda kv:-len(kv[1])):
  for f in free:
   if f[1]-f[0]>=len(data):place[key]=f[0];f[0]+=len(data);break
  else:raise ValueError(f'Recorded sounds need {sum(map(len,blobs.values()))} bytes; at most {capacity()} fit. Shorten clips or lower the rate.')
 return place

def capacity():return sum(b-a for a,b,_ in REGIONS)

def region_of(address):return next(kind for a,b,kind in REGIONS if a<=address<b)
