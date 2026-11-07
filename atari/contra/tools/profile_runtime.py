"""Sample native CPU cycles by routine, using a saved gameplay snapshot."""
from pathlib import Path
import sys,pickle,collections,json,bisect
from build import labels
R=Path(__file__).resolve().parents[1];L=labels(R/'gen/runtime.lab')
a=pickle.load(open(sys.argv[1],'rb'));assert a.xex==(R/'contra.xex').read_bytes()
cycles=collections.Counter();counts=collections.Counter();step=a.cpu.step
ranges=[('interrupt',L['NMI']),('idle',L['RENDER_IDLE']),('flip/palette',L['FLIP']),('compose',L['COMPOSE']),('catchup',L['CATCH_UP']),('tiles',L['EMIT_TILES']),('tile',L['EMIT_TILE']),('bgready',L['BG_READY']),('objexpand',L['OBJ_EXPAND']),('background',L['EMIT_BG']),('sprites',L['EMIT_SPRITES']),('expand',L['EXPAND']),('input',L['READ_INPUT']),('irq',L['IRQ']),('keyboard',L['KB_READ']),('pattern',L['PATTERN_SELECT']),('schedule',L['FRAME_SCHEDULE']),('chrdirty',L['MARK_CHR_DIRTY']),('startup',L['START']),('ppu',0xc000),('sound',0xd800)]
ranges=sorted((v,n) for n,v in ranges);addresses=[v for v,n in ranges]
def prof():
 pc=a.cpu.pc;c=a.cpu.processorCycles;step();cycles[pc]+=a.cpu.processorCycles-c;counts[pc]+=1
n=int(sys.argv[2]) if len(sys.argv)>2 else 100
start=a.mem.ram[0x1a];flips=len(a.xdl_addr_log);a.cpu.step=prof;a.run_frames(n);a.cpu.step=step
s=collections.Counter()
for pc,c in cycles.items():
 if 0x4000<=pc<0xc000:group='NES game'
 elif 0x1000<=pc<0x2800 or 0xc000<=pc<0xd000 or 0xd800<=pc<0xf000:group=ranges[bisect.bisect_right(addresses,pc)-1][1]
 else:group='other'
 s[group]+=c
report={'frames':n,'game_ticks':(a.mem.ram[0x1a]-start)&255,'pictures':(len(a.xdl_addr_log)-flips)//3,'cycles':dict(s.most_common())}
print(json.dumps(report,indent=2));(R/'gen'/('profile-'+Path(sys.argv[1]).stem+'.json')).write_text(json.dumps(report,indent=2)+'\n')
