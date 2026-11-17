import json,subprocess,shutil,unittest
from pathlib import Path
import test_encounters as existing
from workshop import default_project

class MixedWave(unittest.TestCase):
 @classmethod
 def setUpClass(cls):
  existing.Encounters.setUpClass();cls.p=existing.Encounters.p;cls.ram=existing.Encounters.ram
 cpu=existing.Encounters.cpu
 call=existing.Encounters.call
 load=existing.Encounters.load
 def test_mixed_single_pass_lanes_and_browser_parity(self):
  c=self.cpu();self.load(c,7);m=c.memory;m[0x7446]=3
  starts=[0]*8;previous=[128]*8;frames=[]
  for tick in range(240):
   self.call(c,0x3b03);positions=[]
   for i in range(8):
    progress=m[0x2d40+i]
    if previous[i]==128 and progress<128:starts[i]+=1;self.assertEqual(progress,0)
    if previous[i]<128 and progress<128:self.assertEqual(progress-previous[i],2 if i==0 else 3)
    positions.append([((m[0x7462+i]+3)&255),m[0x746a+i]] if progress<128 else None)
   live=[p for p in positions if p]
   for i,p in enumerate(live):
    for q in live[i+1:]:self.assertGreaterEqual(abs(p[1]-q[1]),16)
   frames.append(positions);previous=list(m[0x2d40:0x2d48])
  self.assertEqual(starts,[1]*8);self.assertEqual(previous,[255]*8)
  result=subprocess.run([shutil.which('node'),str(Path(__file__).resolve().parents[1]/'editor/meteors-parity.cjs')],input=json.dumps(dict(project=default_project(),sine=list(self.ram[0x7164:0x7264]),traces=[dict(kind=7,frames=frames)])),text=True,capture_output=True)
  self.assertEqual(result.returncode,0,result.stderr)
 def test_mixed_damage_animation_and_bombs(self):
  self.assertEqual(bytes(self.ram[0x2400:0x2420]),bytes(32),'The scrolling sky still uses tile zero')
  c=self.cpu();m=c.memory;explosions=m[0x7d00:0x8000].copy();self.load(c,7)
  self.assertEqual(m[0x7d00:0x8000],explosions)
  for i in range(8):
   c.y=i;self.call(c,0x0486)
   self.assertEqual(c.a,128,"Waiting lanes must not draw fragments at the right edge")
   m[0x7586+i]=2;c.x=i;self.call(c,0x3b09)
   self.assertEqual(m[0x7586+i],2 if i<2 else 1)
   for frame in range(4):
    m[0x743c]=frame;c.x=0;c.y=i;self.call(c,0x3b06)
    self.assertEqual(c.a,3 if i<2 else frame&1)
  m[0x74e0:0x74e8]=[16]*8;self.call(c,0x2429)
  self.assertEqual(m[0x74e0:0x74e8],[16,16,4,4,4,4,4,4])
  self.call(c,0x3b03)
  self.assertEqual(m[0x74e2:0x74e8],[4]*6,'Movement must not resurrect destroyed enemies')

if __name__=='__main__':unittest.main()
