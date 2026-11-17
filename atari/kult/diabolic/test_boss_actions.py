import json,shutil,subprocess,unittest
from pathlib import Path
from py65.devices.mpu6502 import MPU
from build import create_runtime
from workshop import default_project
from boss_lab import call
class BossActions(unittest.TestCase):
 @classmethod
 def setUpClass(cls):_,cls.ram,_,_=create_runtime()
 def cpu(self,guardian=False,seed=0x5d):
  c=MPU(memory=list(self.ram));m=c.memory;m[0xfd04]=int(guardian);m[0xfd0a]=100;m[0x2d20]=0 if guardian else 4;m[0x2d22]=64;m[0x2d70]=3;m[0x2d00]=2;m[0x2d78]=1;m[0xd20a]=seed^0x5d;m[0x74e0:0x74e8]=[16]*8
  return c
 def step(self,c):
  c.memory[0xf0bf]=255;call(c,0xdac0);m=c.memory
  return [m[0x2dc0],m[0x2dc1],m[0x2d23],m[0x2d24],m[0x2dc8],m[0x2dc4],m[0x2dc7],[[i,m[0x1bd0+i],m[0x1bd8+i]] for i in range(8) if m[0x1be0+i]]]
 def test_complete_native_browser_parity(self):
  traces=[]
  for guardian in (False,True):
   for seed in (0x5d,0x37):
    c=self.cpu(guardian,seed);frames=[self.step(c) for _ in range(1600)]
    self.assertTrue({1,2,3,4,5,6,7,8}<=set(f[0] for f in frames))
    traces.append(dict(guardian=guardian,seed=seed,frames=frames))
  result=subprocess.run([shutil.which('node'),str(Path(__file__).parents[1]/'editor/boss-actions-parity.cjs')],input=json.dumps(dict(project=default_project(),sine=list(self.ram[0x7164:0x7264]),traces=traces)),text=True,capture_output=True)
  self.assertEqual(result.returncode,0,result.stderr)
 def test_four_curtains_then_drain_before_return(self):
  c=self.cpu();m=c.memory;m[0x2dc0]=4;m[0x2dc4]=0;m[0x2d23]=88;m[0x2d24]=48;m[0x2d76]=29;m[0x2d7c]=0;m[0x1bbf]=m[0x2dc6]=3
  births=[];last=False
  for t in range(180):
   old=m[0x1be0];f=self.step(c)
   if m[0x1be0] and not old:births.append(t)
   if f[0]==6:
    self.assertFalse(f[-1]);break
  self.assertEqual(births,[0,30,60,90]);self.assertGreater(t,120);self.assertLess(t,160)
 def test_rocks_have_disjoint_lanes_and_drain(self):
  for direction in (1,2,3,6):
   c=self.cpu();m=c.memory;m[0x2dc0]=5;m[0x2dc4]=2;m[0x2dc7]=direction;m[0x2dc6]=3;m[0x2de0:0x2de8]=[0]+[i*16+24 for i in range(1,8)]
   for t in range(300):
    f=self.step(c)
    if f[0]==6:self.assertFalse(f[-1]);break
    for i,(_,x,y) in enumerate(f[-1]):
     for _,xx,yy in f[-1][i+1:]:self.assertTrue(abs(x-xx)>=8 or abs(y-yy)>=16)
   else:self.fail('Meteor phase never drained')
 def test_hidden_boss_ignores_player_shots(self):
  for phase in (3,4,5,6,7,8):
   c=self.cpu(True);m=c.memory;m[0x2dc0]=phase;m[0x2d23]=88;m[0x2d24]=48;m[0x74e8]=1;m[0x74ee]=88;m[0x74f4]=48
   call(c,0x030c);self.assertEqual(m[0xfd0a],100)
 def test_retreat_and_entry_use_symmetric_steps(self):
  c=self.cpu();m=c.memory
  entry=[self.step(c)[2] for _ in range(20)];self.assertEqual(entry,list(range(126,87,-2)))
  m[0x2dc0]=3;m[0x2dc3]=4;m[0x1be0:0x1be8]=[0]*8
  retreat=[self.step(c)[2] for _ in range(20)];self.assertEqual(retreat,list(range(90,129,2)))
if __name__=='__main__':unittest.main()
