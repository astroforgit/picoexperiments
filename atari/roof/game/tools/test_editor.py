"""End-to-end editor QA in an isolated game copy, never the user's working draft."""
from pathlib import Path
import tempfile,shutil,subprocess,os,sys,time,json,urllib.request,urllib.error
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'tools'))
from scene_model import validate,default_scene,apply_stamps
node=os.environ.get('NODE_BINARY','node')
with tempfile.TemporaryDirectory(prefix='star-fisher-editor-') as tmp:
 work=Path(tmp)/'game';work.mkdir()
 for name in ['tools','gen','assets']:
  shutil.copytree(ROOT/name,work/name,ignore=shutil.ignore_patterns('__pycache__'))
 (work/'screenshots').mkdir()
 for name in ['build.sh','star-fisher.asm','star-fisher.xex']:shutil.copy2(ROOT/name,work/name)
 env=dict(os.environ,STAR_FISHER_ROOT=str(work),EDITOR_URL='http://127.0.0.1:8792',SCREENSHOT_PATH=str(ROOT/'screenshots/editor-library.png'))
 server=subprocess.Popen([sys.executable,str(ROOT/'editor/serve.py'),'8792'],env=env,stdout=subprocess.DEVNULL,stderr=subprocess.STDOUT)
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
  assert len(scene['windows'])==7 and scene['windows'][-1]['pixels']==[[200,200]]
  base=Image.open(work/'assets/editor-base.png');expected=base.copy();apply_stamps(expected,scene)
  actual=Image.open(work/'assets/background-320x240.png')
  assert expected.tobytes()==actual.tobytes() and expected.getpalette()==actual.getpalette(),'Native build must match exact editor scene pixels'
  assert json.loads((work/'assets/windows.json').read_text())==[w['pixels'] for w in scene['windows']]
  # Execute the edited XEX: seven masks and selected custom game-star shape.
  sys.path.insert(0,str(ROOT.parents[1]/'lair/tools'))
  from emu import Atari,load_labels
  L=load_labels(work/'star-fisher.lab');a=Atari(work/'star-fisher.xex');a.boot();a.run_frames(15)
  assert L['WINDOW_COUNT']==7
  a.mem.ram[L['LIGHT_ON']:L['LIGHT_ON']+7]=bytes([0]*6+[2])
  a.call(L['RENDER']);addr=(a.mem.ram[L['BUFFER']]<<16)+200*320+200
  assert a.vram[addr]==248,'Painted window pixel must reach actual VBXE framebuffer'
  print('PASS isolated persistence, validation, exact indexed background, seven native window groups and edited framebuffer pixel')
 finally:
  server.terminate();server.wait(timeout=10)
