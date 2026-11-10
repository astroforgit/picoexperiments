#!/usr/bin/env python3
"""Headless integration smoke test; not a substitute for full-machine testing."""
import argparse,json,sys,hashlib
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'tools/reference'))
from atari_emu import Atari,load_labels
p=argparse.ArgumentParser();p.add_argument('--frames',type=int,default=1200);p.add_argument('--page',type=lambda x:int(x,16),default=0xd6);args=p.parse_args()
r=load_labels(ROOT/'gen/runtime.asm.lab');a=Atari(ROOT/'pilka.xex',vbxe_page=args.page);a.boot()
for _ in range(2_000_000):
 if a.cpu.pc==0x975b:break
 a.cpu.step()
else:raise AssertionError('Startup did not enter the C64 game')
a.next_frame=a.cpu.processorCycles+a.frame_cycles
assert a.vregs[0x40]==3
# The banner upload must survive loading/restoration and match the generated art.
assert bytes(a.vram[0x78000:0x78a00])==(ROOT/'gen/banners.bin').read_bytes()
original_step=a.cpu.step
menu_calls=match_calls=0

def checked_step():
 global menu_calls,match_calls
 pc=a.cpu.pc;op=a.mem[pc]
 if pc==r['MENU_FRAME']:menu_calls+=1
 if pc==0x972c:match_calls+=1
 if pc==0x9ccd:record_check()
 assert a.cpu.disassemble[op][0]!='???', f'Unsupported opcode ${op:02x} at ${pc:04x}'
 assert op!=0, f'Unexpected BRK at ${pc:04x}'
 return original_step()
a.cpu.step=checked_step
snapshots=[];records=0
source=(ROOT/'analysis/unpacked-64k.bin').read_bytes()
def record_check():
 # $9CCD: the game is about to read a 35-byte formation record at ($16).
 # On the C64 that is RAM under the I/O area; it must be the same data.
 global records
 idx=a.mem.ram[0x22]&0x3f
 c64=0xda7d+35*idx if idx<0x21 else 0xc980+0x100*(idx-0x21) if idx<0x29 else 0xe9c3+35*idx
 at=a.mem.ram[0x16]|a.mem.ram[0x17]<<8
 assert bytes(a.mem[at+i] for i in range(35))==source[c64:c64+35],f'formation record {idx} differs'
 records+=1
for f in range(args.frames):
 a.set_input(trig=100<=f<125 or (f>750 and f%160<12),stick=(13 if 40<=f<50 else [7,14,11,13][(f//140)%4] if f>600 else 15))
 a.run_frames(1)
 if f==39:menu_selection=a.mem.ram[0x92c2]
 if f==79:
  assert a.mem.ram[0x92c2]!=menu_selection, 'Joystick did not move menu selection'
  assert menu_calls>0 and a.blits>1000, 'Original options menu was not rendered'
  assert a.mem.ram[0x97dd]!=0, 'Regression must cover a pending disabled SID request'
 if f in (79,299,599,899,args.frames-1):
  tag=f'{args.page:02x}-{f}'
  a.screenshot(ROOT/f'analysis/atari-{tag}.png',scale=2)
  snapshots.append({'frame':f,'game_tick':a.mem.ram[r['FRAMES']],'blits':a.blits,
                    'sprite_state':list(a.mem.ram[0x9f:0xfc]),
                    'audio_silent':all(not any(v[:9]) for v in a.pokey_log)})
  print(tag,'blits',a.blits,'ticks',a.mem.ram[r['FRAMES']],flush=True)
 assert not any(a.pokey[:9]), 'Unexpected POKEY audio output'
assert a.blits>1000
assert a.nmi_count>=args.frames-1
if args.frames>=900:
 assert match_calls>0, 'Fire did not start a match from the menu'
 assert records>=20, 'Formation records were not read'
 assert len({bytes(s['sprite_state']) for s in snapshots})>1
report={'vbxe_page':hex(args.page),'pal':True,'frames':args.frames,
        'xex_sha256':hashlib.sha256((ROOT/'pilka.xex').read_bytes()).hexdigest(),
        'snapshots':snapshots,'limitations':'Headless model only; full match, scoring and real hardware are not covered.'}
(ROOT/f'analysis/test-{args.page:02x}.json').write_text(json.dumps(report,indent=2)+'\n')
print(f'PASS: boot, exact banner upload, instruction execution, {records} formation records, VBXE drawing and silent POKEY.')
