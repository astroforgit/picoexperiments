#!/usr/bin/env python3
"""Actual ANTIC/GTIA check of eight star positions, including both clipped edges.
Only the emulator verification session is patched; the distributed XEX isn't.
"""
import json,re,subprocess
from pathlib import Path
from PIL import Image
ROOT=Path(__file__).resolve().parent
from build import kult
ram=kult((ROOT/'kult-diabolic.xex').read_bytes())[0]
listing=(ROOT/'space.lst').read_text()
address=int(re.search(r'^\s*\d+\s+([0-9A-F]{4}) .*Velocity dta',listing,re.M)[1],16)
commands=[f'e {address:04X} 00 00 00']
fixtures=[]
for star,x in zip([s for s in json.loads((ROOT/'star-layout.json').read_text()) if s['lane']==0],(60,61,70,96,120,152,186,188)):
    y=star['y'];h=star['height']
    mask=ram[0x2c00+x];glyph=[ram[0x2800+y+i]&mask for i in range(h)]
    commands.append(f'e {0x3800+y:04X} '+' '.join([f'{x:02X}']*h))
    commands.append(f'e {0x3400+y:04X} '+' '.join(f'{v:02X}' for v in glyph))
    fixtures.append((x,y,glyph))
(ROOT/'verification/edge-check.commands').write_text('\n'.join(commands)+'\n')
winpath=subprocess.check_output(['wslpath','-w',str(ROOT/'verify-emulator.ps1')],text=True).strip()
capture=ROOT/'verification/edges.png'
if capture.exists():capture.unlink()
subprocess.run(['/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe','-NoProfile','-ExecutionPolicy','Bypass','-File',winpath,'-CheckEdges'],check=True)
im=Image.open(capture).convert('RGB');checked=0;missing=[]
for x,y,glyph in fixtures:
    for dy,bits in enumerate(glyph):
        for bit in range(8):
            if bits & (0x80>>bit):
                for dx in (0,1):
                    px=(x+bit)*2-88+dx;py=y+dy-8
                    assert 40<=px<296
                    checked+=1
                    if max(im.getpixel((px,py)))<20:missing.append((px,py))
assert not missing,f'Missing star pixels in emulator: {missing}'
print(f'PASS: {checked} native star pixels at eight positions, including both clipped edges.')
