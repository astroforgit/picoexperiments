"""Verify native intro loading, all six pages, and final modal dismissal."""
from pathlib import Path
import shot
from emu import load_labels
root=Path(__file__).resolve().parent.parent
labels=load_labels(root/'lich.lab');a=shot.run('80,f,300');ram=a.mem.ram
raw=(root/'data/intro.bin').read_bytes()
assert bytes(a.vram[0x34000:0x35000])==raw
pages=int((root/'gen/intro.asm').read_text().split('=')[1])
for page in range(pages):
 assert ram[labels['INTRO_ACTIVE']]==1
 assert ram[labels['INTRO_PAGE']]==page
 assert bytes(ram[labels['INV_TEXT']:labels['INV_TEXT']+320])==raw[page*512:page*512+320]
 if page==0:
  (root/'shots').mkdir(exist_ok=True);a.screenshot(root/'shots/intro-poem.png',scale=4)
 shot.step(a,'f');shot.step(a,'30')
assert ram[labels['INTRO_ACTIVE']]==0
assert ram[labels['MODAL_TOP']]==255
print('PASS native VRAM intro load, all pages, input advance and final dismissal')
