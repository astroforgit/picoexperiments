"""A/B build PPUCTRL variants in temporary copies; prove register/state equality.

Removing the unused X save/restore must preserve every control value and CPU
register/flag, while saving exactly eight 6502 cycles per call. No production
source is edited by this test. Requires the normal build toolchain.
"""
from pathlib import Path
import tempfile,shutil,subprocess,os,json
from build import labels,ROOT,CA65,LD65,MADS
from atari_emu import Atari

def main():
 source=(ROOT/'src/services.asm').read_text()
 optimized=source.replace('        stx ctrl_x\n','').replace('        ldx ctrl_x\n','').replace('ctrl_x dta 0\n','')
 baseline=optimized.replace('ctrl_a  php\n','ctrl_a  php\n        stx ctrl_x\n').replace('        pla\n        plp\n        rts\nmask_a','        pla\n        ldx ctrl_x\n        plp\n        rts\nctrl_x dta 0\nmask_a',1)
 assert 'stx ctrl_x' in baseline and 'ldx ctrl_x' in baseline
 states=[];costs=[]
 with tempfile.TemporaryDirectory(prefix='contra-ctrl-') as td:
  for name,text in [('baseline',baseline),('optimized',optimized)]:
   r=Path(td)/name;r.mkdir()
   for d in ['src','upstream']:shutil.copytree(ROOT/d,r/d)
   (r/'tools').mkdir();shutil.copy2(ROOT/'tools/build.py',r/'tools/build.py')
   (r/'Contra').mkdir();shutil.copy2(ROOT/'Contra/Contra (USA).nes',r/'Contra/Contra (USA).nes')
   (r/'src/services.asm').write_text(text)
   env=dict(os.environ,CA65=CA65,LD65=LD65,MADS=MADS)
   subprocess.run(['python3','tools/build.py'],cwd=r,env=env,check=True,stdout=subprocess.DEVNULL)
   L=labels(r/'gen/runtime.lab');a=Atari(r/'contra.xex');a.boot()
   for _ in range(2000000):
    if a.cpu.pc==L['NES_RESET']:break
    a.cpu.step()
   else:raise AssertionError('boot failed')
   result=[];cycles=[]
   for value in range(256):
    for flags in (0x20,0x61,0xa4,0xef):
     a.cpu.a=value;a.cpu.x=value^0xa5;a.cpu.y=value^0x5a;a.cpu.p=flags
     start=a.cpu.processorCycles;a.call(L['CTRL_A']);cycles.append(a.cpu.processorCycles-start)
     actual=(a.cpu.a,a.cpu.x,a.cpu.y,a.cpu.p,a.mem.ram[L['NMI_ON']],a.mem.ram[L['LAT_CTRL']],a.mem.ram[L['PPU_INC']])
     expected=(value,value^0xa5,value^0x5a,flags|0x30,value,value,32 if value&4 else 1)
     # PHP/PLP forces the py65 B/unused bits, as on the existing service.
     assert actual==expected,(value,flags,actual,expected)
     result.append(actual)
   states.append(result);costs.append(cycles)
 assert states[0]==states[1]
 assert set(b-a for b,a in zip(*costs))=={8}
 report={'cases':len(states[0]),'register_flags_and_state_identical':True,'cycles_saved_per_call':8,'baseline_cycles':sorted(set(costs[0])),'optimized_cycles':sorted(set(costs[1])),'isolated_temporary_builds':True}
 (ROOT/'gen/ppuctrl-ab.json').write_text(json.dumps(report,indent=2)+'\n');print('PASS',report)
if __name__=='__main__':main()
