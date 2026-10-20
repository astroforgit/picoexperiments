"""Publish the five-image artist review without changing the campaign package."""
from pathlib import Path
import argparse
import hashlib
import html
import json
import shutil
import zipfile

root = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser()
parser.add_argument('--output', type=Path, required=True)
args = parser.parse_args()
out = args.output.resolve()
folder = out / 'galleryartist'
folder.mkdir(parents=True, exist_ok=True)
city = root / 'atari/city'
layout = json.loads((city / 'generated/outro-full-quality-layout.json').read_text())
assert layout['configFile'] == 'galleryartist-content.json', 'Build the viewer with --artist first'
paintings = json.loads((city / layout['configFile']).read_text())['paintings']
assert len(paintings) == layout['pictureCount'] == 5
files = {}
for name in ('heroes-outro-full-quality-test.xex', 'outro-full-quality-test.json',
             layout['requires'], 'run-outro-full-quality-test.sh',
             'run-outro-full-quality-test.ps1', 'run-outro-full-quality-test.cmd'):
    shutil.copyfile(root / 'atari' / name, folder / name)
    files[name] = folder / name
module = root.parents[1] / 'atari-vbxe-toolkit/scripts/AltirraTools.psm1'
shutil.copyfile(module, folder / module.name)
files[module.name] = folder / module.name
for i, painting in enumerate(paintings, 1):
    for name, source in ((f'native-{i}.png', city / f'generated/outro-full-quality-{i}.png'),
                         (f'original-{i}.png', (city / painting['image']).resolve())):
        shutil.copyfile(source, folder / name)
        files[name] = folder / name
buttons = ''.join('<button data-page="%d">%d. %s</button>' %
                  (i, i, html.escape(p['title'].title())) for i, p in enumerate(paintings, 1))
page = '''<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Artist gallery — VBXE conversion</title><style>body{background:#121c18;color:#f0ead8;font:17px/1.5 system-ui;padding:24px}main{max-width:1250px;margin:auto}button,a{font:inherit;color:#eddfaa;background:#263b2c;border:1px solid #76865b;border-radius:5px;padding:8px 12px;margin:4px;cursor:pointer;display:inline-block}button[aria-pressed=true]{background:#576c3e}img{width:100%;height:auto;display:block;background:#080d0a}img.native{image-rendering:pixelated}small{color:#bac5b7}</style><main><h1>Artist gallery — VBXE conversion</h1><p>Five supplied paintings · Prince and the Nimf · Everything by astrofor</p><nav>BUTTONS</nav><p><button id="native" aria-pressed="true">VBXE screen</button><button id="original" aria-pressed="false">Artist original</button></p><h2 id="caption"></h2><img class="native" id="picture" src="native-1.png" alt=""><p><button id="back">← Previous</button><button id="next">Next →</button></p><p><a href="../heroes-galleryartist-test.zip" download>Download XEX + disk + runners</a></p><small>320×144 picture region, 320×200 complete screen, existing shared 256-colour palette. The test contains only these five images. Fire, Enter or Space advances; the fifth loops to the first. Pictures replace each other in the existing framebuffers through a 256-byte loading buffer. The source artwork and in-game collection are unchanged. Functional 6502/VBXE tests passed; live Altirra/hardware playback has not been verified here.</small></main><script>const titles=TITLES;let page=1,original=false;function show(){const image=document.getElementById('picture');image.src=(original?'original-':'native-')+page+'.png';image.alt=titles[page-1];image.className=original?'':'native';document.getElementById('caption').textContent=page+' / '+titles.length+' — '+titles[page-1];document.getElementById('native').setAttribute('aria-pressed',!original);document.getElementById('original').setAttribute('aria-pressed',original);document.querySelectorAll('[data-page]').forEach(b=>b.setAttribute('aria-pressed',Number(b.dataset.page)===page));}document.querySelectorAll('[data-page]').forEach(b=>b.onclick=()=>{page=Number(b.dataset.page);show()});document.getElementById('native').onclick=()=>{original=false;show()};document.getElementById('original').onclick=()=>{original=true;show()};document.getElementById('next').onclick=()=>{page=page%titles.length+1;show()};document.getElementById('back').onclick=()=>{page=(page+titles.length-2)%titles.length+1;show()};show();</script></html>'''
(folder / 'index.html').write_text(page.replace('BUTTONS', buttons).replace('TITLES', json.dumps([p['title'] for p in paintings])))
files['index.html'] = folder / 'index.html'
notes = '''ARTIST GALLERY VBXE TEST
Prince and the Nimf - Everything by astrofor

This viewer contains ONLY the five supplied files from art/galleryartist.
It is a separate review set; the main game's gallery and story disk are unchanged.

Source checkout:
  cd /home/marcin/tmp/pico/steamlinejs/heroes/atari
  ./run-outro-full-quality-test.sh

Windows: extract the whole ZIP, run run-outro-full-quality-test.cmd.
Keep heroes-galleryartist-test.atr and outro-full-quality-test.json beside the
test XEX and runner. The launcher mounts the artist test disk automatically.
For manual launching, attach heroes-galleryartist-test.atr as D1 before
loading heroes-outro-full-quality-test.xex. The main-game disk is not compatible
with this artist test viewer and will show a retry prompt.

Fire / Enter / Space advances, releasing between presses. After picture five,
the viewer loops. 320x144 artwork and caption/footer area use the existing
256-colour game palette. Each picture streams into the existing front/back
framebuffers through a 256-byte staging buffer. No per-picture VRAM cache.

Rebuild: node atari/city/tools/build-outro-full-quality.js --artist
Rebuild the main game's eight-picture viewer: omit --artist.
Neither command changes the campaign executable, campaign disk or source art.

Originals are preserved. The five conversions, replay, controls, missing/wrong
disk handling and fixed VRAM use pass the functional 6502/VBXE test model on
both supported register mappings. Live Altirra/hardware timing remains unverified.
'''
(folder / 'README.txt').write_text(notes)
files['README.txt'] = folder / 'README.txt'
checks = ''.join(hashlib.sha256(p.read_bytes()).hexdigest() + '  ' + name + '\n'
                 for name, p in sorted(files.items()))
(folder / 'SHA256SUMS').write_text(checks)
files['SHA256SUMS'] = folder / 'SHA256SUMS'
with zipfile.ZipFile(out / 'heroes-galleryartist-test.zip', 'w', zipfile.ZIP_DEFLATED) as z:
    for name, source in files.items():
        z.write(source, name)
shutil.copyfile(out / 'heroes-galleryartist-test.zip', out / 'heroes-outro-full-quality-test.zip')
for name in ('heroes-outro-full-quality-test.xex', 'outro-full-quality-test.json', layout['requires']):
    shutil.copyfile(folder / name, out / name)
print('Published five artist conversions, original/VBXE comparison, matched test XEX/ATR and launchers.')
