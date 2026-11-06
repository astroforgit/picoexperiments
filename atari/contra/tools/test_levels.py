"""Load and exercise all eight stages in the built Atari executable.

Test-only RAM setup skips waits and selects stages; the executable has no trainer.
"""
from pathlib import Path
import json,pickle,sys
from atari_emu import Atari
from build import labels
R=Path(__file__).resolve().parents[1];L=labels(R/'gen/runtime.lab');N=labels(R/'gen/nes.lab')
def val(a,n):return a.mem.ram[N[n]]
def put(a,n,v):a.mem.ram[N[n]]=v

def main():
 start=int(next((x.split('=')[1] for x in sys.argv if x.startswith('--from-stage=')), '1'))-1
 if start:
  saved=R/'gen'/('ntsc' if '--ntsc' in sys.argv else 'pal')/('d700' if '--d700' in sys.argv else 'd600')/f'stage-{start}.pkl'
  if not saved.exists():saved=R/f'gen/stage-{start}.pkl'
  a=pickle.load(saved.open('rb'))
  assert a.xex==(R/'contra.xex').read_bytes(),'snapshot belongs to another executable'
 else:
  a=Atari(R/'contra.xex',pal='--ntsc' not in sys.argv,vbxe_page=0xd7 if '--d700' in sys.argv else 0xd6);a.boot();a.run_frames(130)
 out=R/'gen'/('ntsc' if '--ntsc' in sys.argv else 'pal')/('d700' if '--d700' in sys.argv else 'd600');out.mkdir(parents=True,exist_ok=True)
 records=[]
 if start and (out/'level-tests.json').exists():
  records=[rec for rec in json.loads((out/'level-tests.json').read_text()) if rec['stage']<=start]
  for rec in records:
   checkpoint=pickle.load((out/f"stage-{rec['stage']}.pkl").open('rb'))
   assert checkpoint.xex==a.xex,'earlier stage report belongs to another executable'
 for stage in range(start,start+1 if '--one' in sys.argv else 8):
  # Entry through the game's own new-game initialization, then stage header.
  while a.mem.ram[L['IN_VBI']]:a.run_frames(1)
  put(a,'PLAYER_MODE',1 if '--two' in sys.argv else 0)
  put(a,'GAME_ROUTINE_INDEX',4);put(a,'DEMO_MODE',0)
  for _ in range(1000):
   a.run_frames(1)
   if val(a,'GAME_ROUTINE_INDEX')==5 and not a.mem.ram[L['IN_VBI']]:break
  else:raise AssertionError('new-game init stalled')
  put(a,'CURRENT_LEVEL',stage)
  put(a,'LEVEL_ROUTINE_INDEX',0)
  a.mem.ram[L['SCENE_READY']]=0
  # Break at the actual routine entry, before its timer loads. Sampling
  # only at video boundaries can miss every gap between long game NMIs.
  # This is a test-only presentation-wait skip, never a gameplay patch.
  cpu_step=a.cpu.step;score_wait_skips=0
  def step_with_score_skip():
   nonlocal score_wait_skips
   if a.cpu.pc==N['LEVEL_ROUTINE_02'] and val(a,'GAME_ROUTINE_INDEX')==5:
    put(a,'DELAY_TIME_LOW_BYTE',0);put(a,'DELAY_TIME_HIGH_BYTE',0)
    score_wait_skips+=1
   cpu_step()
  a.cpu.step=step_with_score_skip
  try:
   for elapsed in range(800):
    a.run_frames(1)
    if val(a,'LEVEL_ROUTINE_INDEX')==4 and a.mem.ram[L['SCENE_READY']] and not a.mem.ram[L['IN_VBI']]:break
   else:raise AssertionError(f'stage {stage+1} initialization stalled')
  finally:a.cpu.step=cpu_step
  assert score_wait_skips==1,(stage,'score wait breakpoint not reached exactly once')
  # Let the player land and renderer finish; move/shoot and exercise jumping.
  bullet_seen=False;positions=set();flips=len(a.xdl_addr_log)
  for f in range(110):
   a.set_input(stick=7 if f>35 else 15,trig=int(f>25),shift=50<=f<68,stick1=7 if f>40 else 15,trig1=int(f>30) if '--two' in sys.argv else 0)
   a.run_frames(1)
   positions.add((val(a,'SPRITE_X_POS'),val(a,'SPRITE_Y_POS')))
   bullet_seen|=any(a.mem.ram[N['PLAYER_BULLET_ROUTINE']:N['PLAYER_BULLET_ROUTINE']+16])
  a.screenshot(out/f'stage-{stage+1}.png')
  with (out/f'stage-{stage+1}.pkl').open('wb') as f:pickle.dump(a,f)
  assert val(a,'CURRENT_LEVEL')==stage
  assert bullet_seen,(stage,'no bullets')
  assert len(positions)>4,(stage,'no movement')
  assert len(a.xdl_addr_log)>flips,(stage,'no displayed frames')
  rec=dict(stage=stage+1,score_wait_skips=score_wait_skips,load_frames=elapsed+1,positions=len(positions),bullets=bullet_seen,display_updates=(len(a.xdl_addr_log)-flips)//3)
  if '--two' in sys.argv:
   assert val(a,'P2_GAME_OVER_STATUS')==0
   assert a.mem.ram[N['SPRITE_X_POS']+1]>32
   rec['player2_x']=a.mem.ram[N['SPRITE_X_POS']+1]
  records.append(rec);print(rec,flush=True)
  (out/'level-tests.json').write_text(json.dumps(records,indent=2)+'\n')
 (out/'level-tests.json').write_text(json.dumps(records,indent=2)+'\n')
 with (out/'all-levels.pkl').open('wb') as f:pickle.dump(a,f)
if __name__=='__main__':main()
