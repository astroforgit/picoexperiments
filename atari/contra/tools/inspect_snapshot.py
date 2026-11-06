from pathlib import Path
import sys,pickle,numpy as np
from build import labels
R=Path(__file__).resolve().parents[1];l=labels(R/'gen/runtime.lab');n=labels(R/'gen/nes.lab');a=pickle.load(open(sys.argv[1],'rb'))
for name in ['IN_VBI','RENDER_ACTIVE','PENDING','ANY_DIRTY','CHR_DIRTY','ES_MISSING','CU_FLAG','BACK','LAT_X','LAT_Y','LAT_CTRL','C_MASK','TICKS_OWED','TICK_PHASE']:print(name,a.mem.ram[l[name]])
print('game',a.mem.ram[0x18],'stage',a.mem.ram[0x30],'levelroutine',a.mem.ram[0x2c],'playerxy',a.mem.ram[0x334],a.mem.ram[0x31a],'chr0',list(a.vram[0x61000:0x61010]))
print('visible OAM',[(i, list(a.mem.ram[0x200+4*i:0x204+4*i])) for i in range(64) if a.mem.ram[0x200+i*4]<239])
print('snapshot OAM',[(i, list(a.mem.ram[0x800+4*i:0x804+4*i])) for i in range(64) if a.mem.ram[0x800+i*4]<239])
print('flags',sum(a.mem.ram[l['EXPF_BG']:l['EXPF_BG']+256]),sum(a.mem.ram[l['EXPF_OBJ']:l['EXPF_OBJ']+256]))
fixed=(R/'gen/contra.bin').read_bytes()[16+7*16384:];print('fixed code changes',[(hex(i+0x4000),x,y) for i,(x,y) in enumerate(zip(a.mem.ram[0x4000:0x8000],fixed)) if x!=y][:20])
ref=(R/'gen/reference-chr.bin').read_bytes();print('chr differences',np.count_nonzero(a.vram[0x60000:0x62000]!=np.frombuffer(ref,dtype=np.uint8)))
