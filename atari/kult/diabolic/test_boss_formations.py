"""Coverage for six formation presets, mixed transitions and rejected candidates."""
import json,unittest
from py65.devices.mpu6502 import MPU
from pathlib import Path
from build import create_runtime,package,kult
from workshop import default_project,validate
from boss_lab import trace,transition_windows,movement_graph,escape,pressure,replay_route,call

class FormationCoverage(unittest.TestCase):
 @classmethod
 def setUpClass(cls):cls.original,cls.ram,_,_=create_runtime()
 def test_every_rotation_entry_and_opening_direction(self):
  for seed in range(6):
   for gap in (0,1):
    windows=transition_windows(trace(self.ram,0,(12,56),rotation_seed=seed,gap_seed=gap))
    self.assertEqual(len(windows),8)
    self.assertTrue(all(3<=w['maxReactionUpdates']<=4 for w in windows))
 def test_long_mixed_run(self):
  frames=trace(self.ram,0,(12,56),ticks=24+30*24)
  self.assertEqual(len(transition_windows(frames)),23)
  route,_=escape(frames,(12,56),movement_graph(self.ram))
  self.assertIsNotNone(route)
  replay_route(self.ram,0,(12,56),route,frames)
 def test_impossible_and_easy_candidates_are_rejected(self):
  graph=movement_graph(self.ram)
  # A closed wall cannot pass the danger/opening acceptance check.
  with self.assertRaises(AssertionError):pressure([[[i,12,i*16] for i in range(8)]])
  with self.assertRaises(AssertionError):pressure([[]]*100)
  frames=trace(self.ram,1,(12,56))
  at=transition_windows(frames)[0]['nextRushTick']-1
  with self.assertRaises(AssertionError):transition_windows(frames[:at]+[[]]*20+frames[at:])
  # A ship unable to move vertically cannot negotiate alternating openings.
  horizontal={p:{q for q in neighbours if q[1]==p[1]} for p,neighbours in graph.items()}
  route,_=escape(frames,(12,56),horizontal)
  self.assertIsNone(route)
 def test_new_presets_validate_and_export(self):
  for pattern in (4,5,6):
   project=default_project();project['boss']['pattern']=pattern;validate(project)
   source,ram,_,_=create_runtime(project)
   loaded=kult(package(source,ram))[0]
   self.assertEqual(loaded[0x2d74],pattern)
   self.assertEqual(loaded[0x2300:0x2360],ram[0x2300:0x2360])
  for bad in (-1,7,1.5,True):
   project=default_project();project['boss']['pattern']=bad
   with self.assertRaises(ValueError):validate(project)
 def test_bombs_clear_each_formation_during_formation_and_rush(self):
  for pattern in range(1,7):
   for tick in (25,43,55,73):
    c=MPU(memory=list(self.ram));m=c.memory;m[0x2d7c]=24;m[0x2d74]=pattern;m[0x2d23]=88;m[0x2d24]=48;m[0x2d70]=3;m[0xf0bf]=255
    for _ in range(tick):call(c,0x6550)
    m[0x2d70]=2;call(c,0x6550)
    self.assertEqual(m[0x1be0:0x1be8],[0]*8)
    self.assertEqual(m[0x2d7c],24)
    for _ in range(24):call(c,0x6550);self.assertEqual(m[0x1be0:0x1be8],[0]*8)
    call(c,0x6550);self.assertEqual(sum(m[0x1be0:0x1be8]),6)
 def test_native_parameters_match_shared_configuration(self):
  configs=json.loads((Path(__file__).parents[1]/'editor/boss-formations.json').read_text())
  self.assertEqual(len(configs),6)
  for i,f in enumerate(configs,1):
   self.assertEqual([self.ram[a+i] for a in (0x2300,0x2310,0x2320,0x2350)],[f[k] for k in ('doubleTime','phase','rowShift','xPhase')])
   self.assertEqual(list(self.ram[0x2330+(i-1)*2:0x2332+(i-1)*2]),f['soloGuards'])
if __name__=='__main__':unittest.main()
