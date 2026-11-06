import sys,pickle,json
from pathlib import Path
sys.path.insert(0,'tools')
from build import labels
r=Path('.');l=labels(r/'gen/runtime.lab');n=labels(r/'gen/nes.lab');a=pickle.load(open('gen/pal/d600/all-levels.pkl','rb'))
assert a.xex==(r/'contra.xex').read_bytes()
for _ in range(50):
 if not a.mem.ram[l['IN_VBI']]:break
 a.run_frames(1)
completion_before=a.mem.ram[n['GAME_COMPLETION_COUNT']]
a.mem.ram[n['BOSS_DEFEATED_FLAG']]=1;a.mem.ram[n['LEVEL_ROUTINE_INDEX']]=5
for _ in range(180):
 a.set_input();a.run_frames(1)
 # Ending initialization immediately changes CURRENT_LEVEL from 9 to 8.
 if (a.mem.ram[n['GAME_ROUTINE_INDEX']]==6
     and a.mem.ram[n['GAME_COMPLETION_COUNT']]==((completion_before+1)&255)
     and not a.mem.ram[l['IN_VBI']]):break
else:raise AssertionError('ending transition failed')
print('Original stage-8 completion enters ending and increments completion count',flush=True)
a.run_frames(180);a.screenshot(r/'gen/ending.png')
(r/'gen/ending-test.json').write_text(json.dumps({'forced_boss_defeat_transition':True,'game_routine':a.mem.ram[n['GAME_ROUTINE_INDEX']],'current_level':a.mem.ram[n['CURRENT_LEVEL']],'note':'Tests transition into ending; does not simulate defeating the boss.'},indent=2)+'\n')
