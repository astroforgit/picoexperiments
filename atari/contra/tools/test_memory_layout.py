"""Prove unsafe VRAM maps fail assembly, using isolated negative variants."""
from pathlib import Path
import tempfile,shutil,subprocess,json
from build import ROOT,MADS

def main():
 results=[]
 with tempfile.TemporaryDirectory(prefix='contra-map-') as td:
  r=Path(td);shutil.copytree(ROOT/'src',r/'src');(r/'gen').mkdir()
  for p in (ROOT/'gen').glob('*.asm'):shutil.copy2(p,r/'gen'/p.name)
  shutil.copy2(ROOT/'gen/pitch.bin',r/'gen/pitch.bin')
  original=(r/'src/defs.asm').read_text()
  for name,old,new in [('PRG overlap','$1C000','$18000'),('CHR overlap','$78000','$61000'),('list overflow','MAXT      = 112','MAXT      = 200')]:
   assert old in original
   (r/'src/defs.asm').write_text(original.replace(old,new,1))
   p=subprocess.run([MADS,'runtime.asm','-o:../bad.obx'],cwd=r/'src',capture_output=True,text=True)
   assert p.returncode or 'ERROR' in p.stdout,(name,'unsafe map accepted')
   assert 'ert ' in p.stdout,(name,p.stdout,p.stderr)
   results.append(name)
 (ROOT/'gen/layout-negative-tests.json').write_text(json.dumps({'rejected':results},indent=2)+'\n')
 print('PASS invalid layouts rejected:',', '.join(results))
if __name__=='__main__':main()
