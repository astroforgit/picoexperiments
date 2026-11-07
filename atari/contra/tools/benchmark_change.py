"""Compare a runtime optimization with fixed entry points from identical idle-loop states.

Requires the locally preserved work/optimization-baseline and gen/stage-N.pkl
checkpoints from the previous executable.

The checkpoint retains all game/video state; only changed assembled code/table bytes are replaced at an idle boundary. Refuse this method if any other runtime bytes differ.
"""
from pathlib import Path
import pickle,json,hashlib
from build import labels,segments
from atari_emu import Atari
R=Path(__file__).resolve().parents[1]
L=labels(R/'gen/runtime.lab'); old=Atari(R/'work/optimization-baseline/contra.xex');old.boot()
new=Atari(R/'contra.xex');new.boot()
# Boot staging area is the runtime image, before execution changes its state.
before=old.vram[0x40000:0x50000];after=new.vram[0x40000:0x50000]
changed=[i for i in range(65536) if before[i]!=after[i]]
assert all(0xd800<=i<0xfb00 or 0xc000<=i<0xd000 or 0x1000<=i<0x2800 for i in changed),changed[:20]
old_labels=labels(R/'work/optimization-baseline/runtime.lab')
for symbol in ['NMI','RENDER_IDLE','COMPOSE','MARK_CHR_DIRTY']:
 assert L[symbol]==old_labels[symbol],symbol
records=[]
for stage in [1,2]:
 a=pickle.load(open(R/f'gen/stage-{stage}.pkl','rb'))
 assert a.xex==old.xex
 for _ in range(2000000):
  if a.cpu.pc==L['RENDER_IDLE'] and not a.mem.ram[L['IN_VBI']]:break
  a.run_until(a.cpu.processorCycles+1)
 else:raise AssertionError('no idle boundary')
 saved=pickle.dumps(a);rec={'stage':stage,'video_frames':100}
 for name in ['before','after']:
  a=pickle.loads(saved)
  if name=='after':
   for i in changed:a.mem.ram[i]=int(after[i])
  tick=a.mem.ram[0x1a];flips=len(a.xdl_addr_log)
  a.run_frames(100)
  rec[name]={'game_ticks':(a.mem.ram[0x1a]-tick)&255,'pictures':(len(a.xdl_addr_log)-flips)//3}
 records.append(rec);print(rec,flush=True)
(R/'gen/optimization-benchmark.json').write_text(json.dumps(records,indent=2)+'\n')
