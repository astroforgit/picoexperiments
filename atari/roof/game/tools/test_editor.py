"""End-to-end editor QA in an isolated game copy, never the user's working draft."""
from pathlib import Path
import tempfile,shutil,subprocess,os,sys,time,json,urllib.request,urllib.error,socket
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'tools'))
from scene_model import validate,default_scene,apply_stamps,apply_starfield
node=os.environ.get('NODE_BINARY','node')
with socket.socket() as probe:
 probe.bind(('127.0.0.1',0));port=probe.getsockname()[1]
with tempfile.TemporaryDirectory(prefix='star-fisher-editor-') as tmp:
 work=Path(tmp)/'game';work.mkdir()
 for name in ['tools','gen','assets']:
  shutil.copytree(ROOT/name,work/name,ignore=shutil.ignore_patterns('__pycache__'))
 (work/'screenshots').mkdir()
 for name in ['build.sh','star-fisher.asm','sky.asm','sound.asm','bobber-menu.asm','menu-ui.asm','fishing.asm','star-fisher.xex']:shutil.copy2(ROOT/name,work/name)
 # Keep audio imports inside the test workspace, alongside the reference library.
 test_sounds=Path(tmp)/'sounds';test_sounds.mkdir()
 for source in (ROOT.parent/'sounds').glob('*'):
  if source.is_file(): (test_sounds/source.name).symlink_to(source)
 env=dict(os.environ,STAR_FISHER_ROOT=str(work),STAR_FISHER_SOUNDS=str(test_sounds),EDITOR_URL=f'http://127.0.0.1:{port}',SCREENSHOT_PATH=str(ROOT/'screenshots/editor-library.png'))
 server=subprocess.Popen([sys.executable,str(ROOT/'editor/serve.py'),str(port)],env=env,stdout=subprocess.DEVNULL,stderr=subprocess.STDOUT)
 try:
  for _ in range(50):
   try:
    state=json.load(urllib.request.urlopen(env['EDITOR_URL']+'/api/state'));break
   except (OSError,urllib.error.URLError):time.sleep(.1)
  else:raise AssertionError('Test server did not start')
  invalid=default_scene(state['palette']);invalid['windows'][0]['pixels']=[[320,240]]
  req=urllib.request.Request(env['EDITOR_URL']+'/api/save',data=json.dumps(invalid).encode(),headers={'Content-Type':'application/json'})
  try:urllib.request.urlopen(req);raise AssertionError('Bad project accepted')
  except urllib.error.HTTPError as e:assert e.code==400
  assert not (work/'editor-scene.json').exists()
  subprocess.run([node,str(ROOT/'editor/browser.test.cjs')],env=env,check=True,timeout=180)
  scene=validate(json.loads((work/'editor-scene.json').read_text()))
  assert len(scene['windows'])==7 and scene['windows'][-1]['pixels']==[[200,200],[319,239]]
  base=Image.open(work/'assets/editor-base.png');expected=base.copy();apply_starfield(expected,scene);apply_stamps(expected,scene)
  actual=Image.open(work/'assets/background-320x240.png')
  assert expected.tobytes()==actual.tobytes() and expected.getpalette()==actual.getpalette(),'Native build must match exact editor scene pixels'
  assert json.loads((work/'assets/windows.json').read_text())==[w['pixels'] for w in scene['windows']]
  # Execute the edited XEX: seven masks and selected custom game-star shape.
  sys.path.insert(0,str(ROOT.parents[1]/'lair/tools'))
  from emu import Atari,load_labels
  L=load_labels(work/'star-fisher.lab');a=Atari(work/'star-fisher.xex');a.boot();a.run_frames(15)
  assert L['WINDOW_COUNT']==7
  assert L['STARFIELD_COUNT']==19 and L['METEOR_THRESHOLD']==255
  # Fishing and star colour settings from the browser reach the executable.
  assert L['SPRING_GAUGE']==0 and L['STAR_BRIGHT']==246
  assert a.mem.ram[L['SCENARIO_CATCH']+2]==60 and a.palette[1][246].tolist()==[246,232,204]
  # Sound settings from the browser: louder wind, a frequent train.
  from sounds import chances
  assert scene['sound']['wind']['volume']==9 and L['WIND_PCM']==1 and L['CLIP_COUNT']==1 and L['PCM_AUDF']==15
  assert list(a.mem.ram[L['CLIP_CHANCE']:L['CLIP_CHANCE']+1])==chances(scene['sound'])
  assert sum(bool(a.mem.ram[L['FIELD_FLAGS']+i]&2) for i in range(19))==11
  a.mem.ram[L['LIGHT_ON']:L['LIGHT_ON']+7]=bytes([0]*6+[2])
  a.call(L['RENDER']);addr=(a.mem.ram[L['BUFFER']]<<16)+200*320+200
  assert a.vram[addr]==248,'Painted window pixel must reach actual VBXE framebuffer'
  bottom=(a.mem.ram[L['BUFFER']]<<16)+239*320+319
  assert a.vram[bottom]==248,'Bottom-right light must survive save/build and reach native framebuffer'
  # Compile the empty and maximum sky to catch 6502 loop/count boundaries.
  for count in (0,96):
   scene['sky'].update(onePixelStars=count,twoPixelStars=count,twinklePercent=100,meteorProbability=0)
   (work/'editor-scene.json').write_text(json.dumps(scene))
   subprocess.run(['bash','build.sh'],cwd=work,check=True,stdout=subprocess.DEVNULL,env=env)
   labels=load_labels(work/'star-fisher.lab');edge=Atari(work/'star-fisher.xex');edge.boot();edge.run_frames(15)
   assert labels['STARFIELD_COUNT']==2*count and labels['METEOR_THRESHOLD']==0
   edge.mem.ram[labels['BUFFER']]=2;edge.mem.ram[labels['DRAW_BANK']]=0xa0
   edge.vram[0x20000:0x20000+76800]=0;edge.call(labels['DRAW_STARFIELD'])
   assert sum(edge.vram[0x20000:0x20000+76800]!=0)==count*3
  print('PASS isolated persistence, validation, exact indexed background, seven native window groups and edited framebuffer pixel')
 finally:
  server.terminate();server.wait(timeout=10)
