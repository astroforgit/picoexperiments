#!/usr/bin/env python3
"""Local editor, following the neighboring Zorro editor's HTTP/save workflow."""
from pathlib import Path
from http.server import ThreadingHTTPServer, BaseHTTPRequestHandler
import json,sys,subprocess,threading,shutil,os
from urllib.parse import urlsplit
from PIL import Image
HERE=Path(__file__).resolve().parent
EMULATOR=HERE.parent.parents[1]/'lair/tools'
ROOT=Path(os.environ.get('STAR_FISHER_ROOT',str(HERE.parent)))
sys.path.insert(0,str(ROOT/'tools'))
from scene_model import PROJECT,load_scene,validate
from sounds import wind_preview,sound_settings,usage
import samples
WAVES={}

def wave(name):
 """Peak envelope at 50 points per second for the clip picker (cached)."""
 if name not in WAVES:
  import numpy as np
  raw=subprocess.run(['ffmpeg','-v','error','-i',str(samples.source_path(name)),'-ac','1','-ar','8000','-f','s16le','-'],capture_output=True,check=True).stdout
  x=np.abs(np.frombuffer(raw,np.int16).astype(float));n=len(x)//160
  peaks=x[:n*160].reshape(n,160).max(1) if n else np.zeros(0)
  WAVES[name]=dict(file=name,duration=len(x)/8000,rate=50,peaks=np.minimum(255,np.round(np.sqrt(peaks/32768)*255)).astype(int).tolist())
 return WAVES[name]

def original(clip):
 """The selected slice of the source recording as a 22 kHz WAV."""
 return subprocess.run(['ffmpeg','-v','error','-ss',str(clip['start']),'-t',str(clip['length']),'-i',str(samples.source_path(clip['file'])),'-ac','1','-ar','22050','-f','wav','-'],capture_output=True,check=True).stdout
LOCK=threading.RLock()
MAX_SIZE=600_000

def save(scene):
 data=json.dumps(validate(scene),indent=2)+'\n'
 if PROJECT.exists():shutil.copy2(PROJECT,ROOT/'editor-scene.previous.json')
 temp=PROJECT.with_suffix('.tmp');temp.write_text(data);temp.replace(PROJECT)

def preview():
 sys.path.insert(0,str(EMULATOR))
 from emu import Atari
 a=Atari(ROOT/'star-fisher.xex');a.boot();a.run_frames(15)
 a.screenshot(ROOT/'screenshots/editor-native.png',scale=1)

class Handler(BaseHTTPRequestHandler):
 def send(self,code,data,ctype='application/json'):
  if not isinstance(data,bytes):data=json.dumps(data).encode()
  self.send_response(code);self.send_header('Content-Type',ctype);self.send_header('Content-Length',str(len(data)));self.send_header('Cache-Control','no-store');self.end_headers();self.wfile.write(data)
 def do_GET(self):
  path=urlsplit(self.path).path
  if path=='/api/state':
   with LOCK:
    im=Image.open(ROOT/'assets/editor-base.png');pal=im.getpalette()
    self.send(200,dict(width=320,height=240,palette=pal,pixels=list(im.getdata()),scene=load_scene(pal),saved=PROJECT.exists()))
   return
  files={'/vendor/asap.js':('vendor/asap.js','text/javascript'),'/vendor/COPYING':('vendor/COPYING','text/plain'),'/':('index.html','text/html'),'/index.html':('index.html','text/html'),'/editor.js':('editor.js','text/javascript'),'/core.js':('core.js','text/javascript'),'/pokey.js':('pokey.js','text/javascript'),'/style.css':('style.css','text/css'),'/native-preview.png':('native-preview.png','image/png')}
  if path=='/native-preview.png':
   p=ROOT/'screenshots/editor-native.png'
   if p.exists():self.send(200,p.read_bytes(),'image/png')
   else:self.send(404,{'error':'Build or preview the game first.'})
   return
  if path=='/api/sound-sources':
   self.send(200,[dict(file=f,duration=round(samples.duration(f),2)) for f in samples.sources()]);return
  if path=='/api/sound-wave':
   from urllib.parse import parse_qs
   try:self.send(200,wave(parse_qs(urlsplit(self.path).query).get('file',[''])[0]))
   except (ValueError,subprocess.CalledProcessError) as e:self.send(400,{'error':str(e)})
   return
  if path=='/game.xex':self.send(200,(ROOT/'star-fisher.xex').read_bytes(),'application/octet-stream');return
  if path in files:
   filename,ctype=files[path];p=HERE/filename
   if p.exists():self.send(200,p.read_bytes(),ctype);return
  self.send(404,{'error':'Not found'})
 def do_POST(self):
  host=self.headers.get('Host','');origin=self.headers.get('Origin')
  if host not in (f'127.0.0.1:{self.server.server_port}',f'localhost:{self.server.server_port}') or (origin and origin not in (f'http://{host}',)):
   self.send(403,{'error':'Use the local editor address to save.'});return
  path=urlsplit(self.path).path
  if path not in ['/api/save','/api/build','/api/preview','/api/sound-preview','/api/sample-preview','/api/sample-original','/api/sound-usage']:
   self.send(404,{'error':'Not found'});return
  try:
   size=int(self.headers.get('Content-Length','0'))
   if not 0<size<=MAX_SIZE:raise ValueError('Project is empty or too large')
   body=json.loads(self.rfile.read(size))
   if path=='/api/sound-preview':
    self.send(200,dict(wind=wind_preview(sound_settings(body))));return
   if path in ('/api/sample-preview','/api/sample-original'):
    loop=bool(body.get('loop'));clip=samples.clip_settings(body.get('clip'),'Sound',loop);rate=body.get('rate',13)
    if rate not in samples.RATES:raise ValueError('Choose a listed sample rate')
    if path=='/api/sample-original':self.send(200,original(clip),'audio/wav')
    else:self.send(200,dict(rate=samples.hz(rate),levels=samples.levels(clip,rate,loop)))
    return
   if path=='/api/sound-usage':
    self.send(200,usage(sound_settings(body)));return
   with LOCK:
    if path!='/api/preview':save(body)
    if path=='/api/build':
     old=(ROOT/'star-fisher.xex').read_bytes()
     proc=subprocess.run(['bash','build.sh'],cwd=ROOT,capture_output=True,text=True,timeout=120)
     if proc.returncode:
      (ROOT/'star-fisher.xex').write_bytes(old)
      self.send(422,{'error':'Build failed. Previous executable retained.','detail':(proc.stdout+proc.stderr)[-2500:]});return
    if path in ['/api/build','/api/preview']:preview()
    self.send(200,dict(message='Game built. Native preview updated.' if path=='/api/build' else 'Project saved.' if path=='/api/save' else 'Native preview ready.',preview=path!='/api/save'))
  except (ValueError,TypeError,KeyError) as e:self.send(400,{'error':str(e)})
  except subprocess.CalledProcessError as e:self.send(400,{'error':'Could not read that sound: '+(e.stderr or b'').decode(errors='replace')[-300:]})
  except subprocess.TimeoutExpired:self.send(504,{'error':'Build timed out.'})
  except Exception as e:self.send(500,{'error':str(e)})
 def log_message(self,fmt,*args):print(fmt%args,flush=True)

if __name__=='__main__':
 port=int(sys.argv[1]) if len(sys.argv)>1 else 8791
 server=ThreadingHTTPServer(('127.0.0.1',port),Handler)
 print(f'Star Fisher pixel editor: http://127.0.0.1:{port}',flush=True)
 server.serve_forever()
