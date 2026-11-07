#!/usr/bin/env python3
"""Publish a reproducible, self-contained game package and compatibility files."""
from pathlib import Path
import argparse,hashlib,shutil,zipfile
root=Path(__file__).resolve().parents[1]
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,default=root/'release/dist');args=p.parse_args()
out=args.output.resolve();out.mkdir(parents=True,exist_ok=True)
atari=root/'atari';city=atari/'city'
for name in ('heroes-vbxe3.xex','prince-and-the-nymph.xex'):shutil.copyfile(city/'city-vbxe.xex',atari/name)
for name in ('heroes-story.atr','prince-and-the-nymph.atr'):shutil.copyfile(city/'generated/heroes-story.atr',atari/name)
# Single-file alternative: a bootable disk holding the same XEX and pictures.
shutil.copyfile(city/'city-vbxe.atr',atari/'prince-and-the-nymph-boot.atr')
files={name:atari/name for name in ('prince-and-the-nymph-boot.atr','prince-and-the-nymph.xex','prince-and-the-nymph.atr','run-prince-and-the-nymph.sh','run-prince-and-the-nymph.ps1','run-prince-and-the-nymph.cmd','run-prince-and-the-nymph-boot.sh','run-prince-and-the-nymph-boot.ps1')}
files['AltirraTools.psm1']=root.parents[1]/'atari-vbxe-toolkit/scripts/AltirraTools.psm1'
files['README.txt']=root/'release/README.txt'
files['VERSION']=root/'VERSION'
version=(root/'VERSION').read_text().strip()
assert f'version {version}' in (root/'release/README.txt').read_text().split('\n')[0],'README.txt title must name the VERSION'
for name,src in files.items():
 if src.resolve()!=(out/name).resolve():shutil.copyfile(src,out/name)
checks=''.join(f'{hashlib.sha256((out/name).read_bytes()).hexdigest()}  {name}\n' for name in sorted(files))
(out/'SHA256SUMS').write_text(checks)
with zipfile.ZipFile(out/'prince-and-the-nymph.zip','w',zipfile.ZIP_DEFLATED) as z:
 for name in [*files,'SHA256SUMS']:
  info=zipfile.ZipInfo(name,(2026,10,19,0,0,0));info.compress_type=zipfile.ZIP_DEFLATED;info.external_attr=(0o100755 if name.endswith('.sh') else 0o100644)<<16
  z.writestr(info,(out/name).read_bytes())
print(f'Published {out}/prince-and-the-nymph.zip')
