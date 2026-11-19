"""Native diagonal traces, conservative ship bounds and joystick-route replay."""
import json,shutil,subprocess,unittest
from pathlib import Path
from py65.devices.mpu6502 import MPU
from build import create_runtime,package,kult
from boss_lab import call,move,movement_graph,STARTS
from workshop import default_project

class Diagonal(unittest.TestCase):
 @classmethod
 def setUpClass(cls):
  cls.original,cls.ram,_,_=create_runtime();cls.graph=movement_graph(cls.ram)
  c=cls.scene();cls.frames=[]
  for tick in range(180):
   call(c,0x3b03)
   cls.frames.append([(i,c.memory[0x7462+i],c.memory[0x746a+i]) for i in range(8) if c.memory[0x2d40+i]<128])
 @classmethod
 def scene(cls):
  c=MPU(memory=list(cls.ram));m=c.memory;m[0xfd04]=0;m[0x4e75]=0;m[0xd20f]=0;m[0xd209]=0x33
  call(c,0x3f50);return c
 @staticmethod
 def safe(pos,frame):
  x,y=pos
  # Entire 40x16 ship rectangle, plus two display pixels clearance.
  return not any(x<bx+9 and x+21>bx and y<by+18 and y+18>by for _,bx,by in frame)
 def test_shortcut_loads_all_sectors_and_loader_keeps_controller(self):
  for sector in range(8):
   c=MPU(memory=list(self.ram));m=c.memory;m[0x4e75]=sector;m[0xd20f]=0;m[0xd209]=0x33
   call(c,0x3f50);self.assertEqual(m[0x2d20],5);self.assertEqual(m[0xfb8a],18)
  replay=kult(package(self.original,self.ram))[0]
  self.assertEqual(replay[0xfe83:0xff12],self.ram[0xfe83:0xff12])
 def test_no_meteor_overlap_and_both_diagonals_exit_naturally(self):
  seen=set();previous={};births={}
  for tick,frame in enumerate(self.frames):
   for lane,x,y in frame:
    seen.add(lane)
    if lane not in previous:
     self.assertNotIn(lane,births);births[lane]=tick
     self.assertEqual(y,127 if lane&1 else 0)
    else:
     px,py=previous[lane];self.assertLess(x,px)
     self.assertLess(y,py) if lane&1 else self.assertGreater(y,py)
   for i,a in enumerate(frame):
    for b in frame[i+1:]:self.assertTrue(abs(a[1]-b[1])>=10 or abs(a[2]-b[2])>=18)
   previous={i:(x,y) for i,x,y in frame}
  self.assertEqual(seen,set(range(8)));self.assertFalse(self.frames[-1])
  self.assertEqual(births[0],11)
 def test_native_browser_positions_match(self):
  frames=[]
  for row in self.frames:
   frame=[None]*8
   for i,x,y in row:frame[i]=[x,y]
   frames.append(frame)
  result=subprocess.run([shutil.which('node'),str(Path(__file__).parents[1]/'editor/meteors-parity.cjs')],input=json.dumps(dict(project=default_project(),sine=list(self.ram[0x7164:0x7264]),traces=[dict(kind=8,frames=frames)])),text=True,capture_output=True)
  self.assertEqual(result.returncode,0,result.stderr)
 def test_reachable_routes_with_reaction_delay_and_full_ship_clearance(self):
  # Require clearance against old and new rock positions, not only endpoints.
  allowed=[{p for p in self.graph if self.safe(p,row) and (t==0 or self.safe(p,self.frames[t-1]))} for t,row in enumerate(self.frames)]
  samples=[]
  for tick,row in enumerate(self.frames):
   previous={i:(x,y) for i,x,y in self.frames[tick-1]} if tick else {}
   samples.append([(fraction,[(previous.get(i,(x,y))[0]+(x-previous.get(i,(x,y))[0])*fraction,previous.get(i,(x,y))[1]+(y-previous.get(i,(x,y))[1])*fraction) for i,x,y in row]) for fraction in (.25,.5,.75,1)])
  def transition_safe(tick,old,new):
   for fraction,rocks in samples[tick]:
    x=old[0]+(new[0]-old[0])*fraction;y=old[1]+(new[1]-old[1])*fraction
    if any(x<bx+8.5 and x+20.5>bx and y<by+17 and y+17>by for bx,by in rocks):return False
   return True
  viable=[set() for _ in allowed];viable[-1]=allowed[-1]
  for t in range(len(allowed)-2,-1,-1):
   viable[t]={p for p in allowed[t] if any(transition_safe(t+1,p,q) for q in self.graph[p]&viable[t+1])}
  routes=[]
  for start in STARTS:
   c=self.scene();m=c.memory;m[0xe957:0xe959]=start;m[0xf0bf]=m[0xf398]=m[0x2d61]=0
   pos=start;route=[];changes=0
   for tick in range(len(self.frames)):
    choices={q for q in ({pos} if tick<6 else self.graph[pos])&viable[tick] if transition_safe(tick,pos,q)}
    self.assertTrue(choices,(start,tick))
    target=min(choices,key=lambda q:(q!=pos,abs(q[0]-start[0])+abs(q[1]-start[1]),q))
    command=next((dx,dy) for dx in (-1,0,1) for dy in (-1,0,1) if move(c,*pos,dx,dy)==target)
    move(c,*pos,*command);call(c,0x3b03)
    actual=[(i,m[0x7462+i],m[0x746a+i]) for i in range(8) if m[0x2d40+i]<128]
    self.assertEqual(actual,self.frames[tick]);self.assertTrue(self.safe(target,actual))
    changes+=target!=pos;pos=target;route.append(list(pos))
   routes.append(dict(start=start,movingUpdates=changes,route=route))
  stationary=set.intersection(*allowed)
  self.assertNotIn((12,56),stationary)
  self.assertLess(len(stationary)/len(self.graph),.08)
  self.assertGreater(max(1-len(a)/len(self.graph) for a in allowed),.35)
  print('Diagonal safety:',len(routes),'routes; stationary-safe',len(stationary),'/',len(self.graph),'peak blocked',round(max(1-len(a)/len(self.graph) for a in allowed)*100,1),'%')
  report=dict(reactionUpdates=6,shipStep=[3,6],shipBounds=[20,16],clearance=[1,2],routes=routes,frames=self.frames,stationarySafe=len(stationary),positions=len(self.graph),peakBlockedPercent=round(max(1-len(a)/len(self.graph) for a in allowed)*100,1))
  Path('/tmp/kult-diagonal-safety.json').write_text(json.dumps(report))

if __name__=='__main__':unittest.main()
