"""Every automatic moving-wall sequence has a native joystick escape route."""
import json,unittest
from pathlib import Path
from py65.devices.mpu6502 import MPU
from build import create_runtime
from boss_lab import call,trace,movement_graph,allowed_positions,escape,replay_route,transition_windows,pressure
class WallVariants(unittest.TestCase):
 @classmethod
 def setUpClass(cls):cls.ram=create_runtime()[1]
 def test_selector_cycles_all_starting_shapes_and_opening_directions(self):
  c=MPU(memory=list(self.ram));m=c.memory;m[0x2ddc]=0
  for visit in range(25):
   call(c,0x6556);v=visit%12
   self.assertEqual((m[0x2d78],m[0x2d7b]),(v%6,v//6))
  # An actual retreat enters the selector, rather than leaving it unused.
  m[0xfd04]=0;m[0x2d20]=4;m[0x2d22]=32;m[0x2dc0]=3;m[0x2dc3]=4;m[0x2d23]=128
  m[0x2dc6]=m[0x2d70]=3;m[0x1be0:0x1be8]=[0]*8;m[0x2ddc]=8;m[0xf398]=0
  call(c,0xdac0)
  self.assertEqual((m[0x2dc0],m[0x2d78],m[0x2d7b],m[0x2ddc]),(4,2,1,9))
 def test_all_twelve_sequences_have_escape_routes(self):
  graph=movement_graph(self.ram);report=[];signatures=set()
  for variant in range(12):
   seed,gap=variant%6,variant//6
   frames=trace(self.ram,0,(12,56),rotation_seed=seed,gap_seed=gap)
   signatures.add(json.dumps(frames));windows=transition_windows(frames);pressure(frames)
   allowed=allowed_positions(frames,graph);routes=[]
   for start in ((12,0),(12,56),(12,112)):
    route,_=escape(frames,start,graph,allowed=allowed)
    self.assertIsNotNone(route,(variant,start))
    replay_route(self.ram,0,start,route,frames,rotation_seed=seed,gap_seed=gap)
    routes.append(dict(start=start,route=route))
   report.append(dict(variant=variant,seed=seed,gap=gap,frames=frames,routes=routes,windows=windows))
  self.assertEqual(len(signatures),12)
  Path('/tmp/kult-wall-variants.json').write_text(json.dumps(report))
  print('12 distinct wall sequences: 36 native escape routes, 3-update reaction delay, full collision replay.')
if __name__=='__main__':unittest.main()
