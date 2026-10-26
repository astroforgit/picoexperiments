import sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1];sys.path.insert(0,str(ROOT/'tools/reference'))
from atari_emu import Atari,load_labels
from c64 import C64
from vic import render,PAL
from PIL import Image
labels=load_labels(ROOT/'gen/runtime.asm.lab');a=Atari(ROOT/'pilka.xex');a.boot()
# Wait for the restoration to complete before applying test-only render bypass.
while a.cpu.pc!=0x975b:a.cpu.step()
a.mem.ram[labels['RENDER']]=0x60
for f in range(600):
 a.set_input(trig=150<=f<160 or 300<=f<310,stick=7 if f>450 else 15);a.run_frames(1)
 if f in (119,299,599):
  print(f,'mode',a.mem.ram[0x97dd],'vic',a.mem.ram[0xde00:0xde40].hex(),'pc',hex(a.cpu.pc),flush=True)
  print('sprites',[(a.mem.ram[0x9f+i],a.mem.ram[0xe4+i],a.mem.ram[0xcd+i]) for i in range(23)],flush=True)
  (ROOT/f'analysis/logic-{f}.bin').write_bytes(a.mem.ram)
