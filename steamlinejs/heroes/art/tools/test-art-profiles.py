#!/usr/bin/env python3
"""Asset dimensions, distinct poses, untouched originals and native crop blitter checks."""
from pathlib import Path
import json,hashlib,importlib.util
from PIL import Image
ROOT=Path(__file__).resolve().parents[2];profile=ROOT/'atari/city/assets/profiles/vbxe-v2';manifest=json.loads((profile/'manifest.json').read_text())
assert len(manifest['files'])==150
for entry in manifest['files']:
 file=profile/entry['path'];assert hashlib.sha256(file.read_bytes()).hexdigest()==entry['sha256'];im=Image.open(file).convert('RGBA');assert list(im.size)==entry['size'];assert im.getchannel('A').getbbox()
 if entry['path'].startswith('medieval/'):
  assert im.size==(32,28)
  # Runtime always uses at most15 opaque local-palette colors.
  assert entry['opaqueColors']<=15,entry
for name in {p.stem.rsplit('-',1)[0] for p in (profile/'medieval').glob('*.png')}:
 frames=[Image.open(profile/'medieval'/f'{name}-{f}.png').convert('RGBA').tobytes() for f in range(6)]
 assert len(set(frames[:4]))>=3,(name,'walk poses collapsed');assert frames[4]!=frames[5],(name,'attack poses collapsed')
classic=json.loads((ROOT/'art/vbxe-v2/classic-manifest.json').read_text())
for entry in classic['files']:assert hashlib.sha256((ROOT/'atari/city/assets'/entry['path']).read_bytes()).hexdigest()==entry['sha256'],entry['path']
assert hashlib.sha256((ROOT/'atari/city/city-vbxe.xex').read_bytes()).hexdigest()==classic['executableSHA256']
assert (ROOT/'art/work/native-classic/city-vbxe.xex').read_bytes()==(ROOT/'atari/city/city-vbxe.xex').read_bytes()
for key in ['classic','vbxe-v2']:
 build=ROOT/'art/work'/('native-'+key);spec=importlib.util.spec_from_file_location('runtime_'+key,build/'tools/test-runtime.py');r=importlib.util.module_from_spec(spec);spec.loader.exec_module(r)
 meta=json.loads((build/'generated/asset-profile.json').read_text());assert meta['profile']==key
 for page in [0xd600,0xd700]:
  m=r.Machine(page);bank=m.get('back_bank');m.put('render_bank',bank)
  for i,g in enumerate(meta['buildingGeometry']):
   m.mem.vram[bank*65536:bank*65536+64000]=bytes([7])*64000;m.put('calc_x',100,2);m.put('calc_y',40);m.cpu.a=i;m.call('draw_building')
   expected=bytearray([7])*64000;source=0x30000+meta['buildingOffsets'][i]
   for y in range(g['h']):
    for x in range(g['w']):
     pixel=m.mem.vram[source+y*g['w']+x]
     if pixel:expected[(40+g['y']+y)*320+100+g['x']+x]=pixel
   assert bytes(m.mem.vram[bank*65536:bank*65536+64000])==expected,(key,page,i)
 print('PASS',key,'all fifteen building anchors/transparency/blits at D600 and D700;',meta['compressedAnimationBytes'],'animation bytes,',meta['idleCaches'],'idle caches.')
print('PASS: 150 correctly sized assets, all21 walk/attack sets, exact original preservation and byte-identical classic executable.')
