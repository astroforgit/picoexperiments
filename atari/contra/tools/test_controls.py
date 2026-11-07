"""Pause/resume and fixed-bank integrity regression on a gameplay checkpoint."""
from pathlib import Path
import pickle,json
from build import labels
R=Path(__file__).resolve().parents[1];N=labels(R/'gen/nes.lab')
a=pickle.load(open(R/'gen/pal/d600/stage-1.pkl','rb'))
assert a.xex==(R/'contra.xex').read_bytes()
a.set_input();a.run_frames(5)
a.set_input(consol=6);a.run_frames(3)
a.set_input();a.run_frames(10)
assert a.mem.ram[N['PAUSE_STATE']]==1
position=lambda:(a.mem.ram[N['SPRITE_X_POS']],a.mem.ram[N['SPRITE_Y_POS']])
before=position();a.set_input(stick=7,trig=1,shift=True);a.run_frames(30)
assert position()==before,'player moved while paused'
a.set_input(consol=6);a.run_frames(3)
a.set_input();a.run_frames(5)
assert a.mem.ram[N['PAUSE_STATE']]==0
assert a.mem.ram[0x4000:0x8000]==(R/'gen/contra.bin').read_bytes()[-16384:]
report={'pause_and_resume':True,'movement_frozen_while_paused':True,'fixed_game_bank_intact':True}
(R/'gen/controls-test.json').write_text(json.dumps(report,indent=2)+'\n');print(report)
