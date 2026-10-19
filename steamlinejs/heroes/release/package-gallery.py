from pathlib import Path
import json,shutil,zipfile,hashlib,argparse,subprocess
root=Path(__file__).resolve().parents[1]
parser=argparse.ArgumentParser();parser.add_argument('--output',type=Path,default=root/'release/dist');args=parser.parse_args();out=args.output.resolve();out.mkdir(parents=True,exist_ok=True)
if any(not (out/name).exists() or (out/name).read_bytes()!=src.read_bytes() for name,src in [('prince-and-the-nimf.xex',root/'atari/city/city-vbxe.xex'),('prince-and-the-nimf.atr',root/'atari/city/generated/heroes-story.atr')]) or not (out/'AltirraTools.psm1').exists():
 subprocess.check_call(['python3',str(root/'release/package.py'),'--output',str(out)])
paintings=json.loads((root/'atari/city/gallery-content.json').read_text())['paintings']
for i,p in enumerate(paintings,1):
 shutil.copyfile((root/'atari/city'/p['image']).resolve(),out/f'gallery-art-{i}.png')
 shutil.copyfile(root/f'atari/city/generated/outro-full-quality-{i}.png',out/f'gallery-native-{i}.png')
meta=root/'art/gallery-v1/generation.json';d=json.loads(meta.read_text())
for i,p in enumerate(d['prompts']):p['references']=['art/intro-v1/forest-love.png']+(['art/gallery-v1/painter-sitting.png'] if i>=4 else [])
meta.write_text(json.dumps(d,indent=2)+'\n')
page='''<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Prince and the Nimf — Lost Paintings</title><style>body{margin:0;background:#10171b;color:#e9eee9;font:17px/1.6 system-ui;padding:25px;text-align:center}main{max-width:1150px;margin:auto}img{display:block;max-width:100%;width:100%;height:auto;image-rendering:pixelated;border:1px solid #6e8762}button,a{font:inherit;background:#263529;color:#f2dfaa;border:1px solid #6e8762;border-radius:5px;padding:8px 12px;margin:5px;display:inline-block;cursor:pointer}button[aria-pressed=true]{background:#526444}small{color:#b2bdaa}.buttons{display:flex;flex-wrap:wrap;justify-content:center}p{max-width:900px;margin:14px auto}</style><main><h1>The Lost Paintings</h1><p>Prince and the Nimf · Everything by astrofor</p><p>Eight portraits from the scattered collection of goblin master painter Grubbrush.</p><div id="scenes" class="buttons"></div><p><button id="native" aria-pressed="true">Atari screen</button><button id="art" aria-pressed="false">Original artwork</button></p><p id="counter"></p><img id="picture" src="gallery-native-1.png" alt="The artist and his muse"><p><button id="back">← Previous</button><button id="next">Next →</button></p><p><a href="heroes-outro-full-quality-test.zip" download>Download streaming test package</a><a href="prince-and-the-nimf.zip" download>Download full game</a></p><p>The test viewer shows only these eight paintings. Fire, Enter or Space advances; the final picture loops back to the first. Its launcher automatically mounts the required companion ATR.</p><p>Memory: pictures stream one at a time from disk into the existing front/back screen buffers through a 256-byte staging buffer. No extra image caches are reserved as the collection grows. The 1 MB disk contains the artwork.</p><small>In the game: discover the notebook after two victories, recover two paintings per lair, then open Art Gallery in a built Chapel. The collection resets with a new campaign.</small></main><script>const titles=TITLES;let selected=0,original=false;function show(){document.querySelector('#picture').src='gallery-'+(original?'art':'native')+'-'+(selected+1)+'.png';document.querySelector('#picture').alt=titles[selected];document.querySelector('#counter').textContent=(selected+1)+' / '+titles.length+' — '+titles[selected];document.querySelector('#native').setAttribute('aria-pressed',!original);document.querySelector('#art').setAttribute('aria-pressed',original)}titles.forEach((title,i)=>{const b=document.createElement('button');b.textContent=(i+1)+'. '+title;b.onclick=()=>{selected=i;show()};document.querySelector('#scenes').append(b)});document.querySelector('#next').onclick=()=>{selected=(selected+1)%titles.length;show()};document.querySelector('#back').onclick=()=>{selected=(selected+titles.length-1)%titles.length;show()};document.querySelector('#native').onclick=()=>{original=false;show()};document.querySelector('#art').onclick=()=>{original=true;show()};show();</script></html>'''
(out/'gallery-preview.html').write_text(page.replace('TITLES',json.dumps([p['title'] for p in paintings])))
notes='''PRINCE AND THE NIMF: STREAMING GALLERY TEST
Everything by astrofor

The test now shows ONLY the eight new gallery paintings, not the intro,
wedding ending or game-over pictures. Fire / Enter / Space advances; after
picture eight it loops to the first. Release between presses.

WSL/source:
  cd /home/marcin/tmp/pico/steamlinejs/heroes/atari
  ./run-outro-full-quality-test.sh

Windows package: extract all files and run run-outro-full-quality-test.cmd.
Keep the companion prince-and-the-nimf.atr beside the XEX. The launcher mounts
it in D1 using the existing Altirra profile. Manual loading needs this ATR in D1.

All paintings stream from the 1 MB ATR into the existing display buffers.
The previous image is replaced; no resident per-picture caches are allocated.
Staging RAM: 256 bytes. Original 320x144 picture quality and shared 256-colour
palette are retained. Game code and graphics outside the framebuffers
are not overwritten by the paintings. The viewer XEX is about 36 KB, independent
of the eight raw picture files on disk.

The main game retains its original intro, wedding ending and defeat picture.
Build the Chapel for ART GALLERY. Notes appear after two victories, then two
unique portraits can be recovered in each lair. Their locations are shuffled
at campaign start. Forest wins three/four provide its two; other lairs give
one on each of wins one/two. Viewing is free. No saves: a new game resets them.
Native tests cover both VBXE mappings, exact streamed pictures, constant memory,
missing media/retry, discovery progression and unchanged economy/army state.
Live Altirra/hardware disk timing remains unverified by desktop automation.

Source images and exact built-in imagegen prompts: art/gallery-v1/.
'''
(out/'outro-full-quality-test-notes.txt').write_text(notes)
shutil.copyfile(root/'atari/heroes-outro-full-quality-test.xex',out/'heroes-outro-full-quality-test.xex')
files={'README.txt':out/'outro-full-quality-test-notes.txt','heroes-outro-full-quality-test.xex':out/'heroes-outro-full-quality-test.xex','prince-and-the-nimf.atr':out/'prince-and-the-nimf.atr','gallery-preview.html':out/'gallery-preview.html','AltirraTools.psm1':out/'AltirraTools.psm1'}
for name in ('run-outro-full-quality-test.sh','run-outro-full-quality-test.ps1','run-outro-full-quality-test.cmd'):files[name]=root/'atari'/name
for i in range(1,9):
 for kind in ('native','art'):files[f'gallery-{kind}-{i}.png']=out/f'gallery-{kind}-{i}.png'
checks=''.join(hashlib.sha256(p.read_bytes()).hexdigest()+'  '+name+'\n' for name,p in sorted(files.items()))
with zipfile.ZipFile(out/'heroes-outro-full-quality-test.zip','w',zipfile.ZIP_DEFLATED) as z:
 for name,p in files.items():
  info=zipfile.ZipInfo(name,(2026,10,19,0,0,0));info.compress_type=zipfile.ZIP_DEFLATED;info.external_attr=(0o100755 if name.endswith('.sh') else 0o100644)<<16;z.writestr(info,p.read_bytes())
 z.writestr('SHA256SUMS',checks)
shutil.copyfile(out/'prince-and-the-nimf.xex',out/'heroes-vbxe-v3.xex');shutil.copyfile(out/'prince-and-the-nimf.atr',out/'heroes-story.atr');shutil.copyfile(out/'prince-and-the-nimf.zip',out/'heroes-vbxe-v3.zip')
# Preserve the old ending comparison: its high-quality side must show main-game endings.
p=out/'outro-quality-comparison.html'
if p.exists():
 s=p.read_text().replace('story-outro-full-quality-1.png','story-outro-1.png').replace("'story-outro-full-quality-'+n","'story-outro-'+n");p.write_text(s)
print('Published eight-painting preview, standalone streaming XEX/ATR package and full game aliases.')
