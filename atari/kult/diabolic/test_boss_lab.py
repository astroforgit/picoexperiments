"""Native movement, collision calibration and repeatable escape-route evidence."""
import unittest
from py65.devices.mpu6502 import MPU
from build import create_runtime
from boss_lab import call,move,hit,trace,movement_graph,escape,replay_route,safe_bands,pressure,allowed_positions,blocked,STARTS,FORMATION_COUNT

class BossLab(unittest.TestCase):
 @classmethod
 def setUpClass(cls):
  _,cls.ram,_,_=create_runtime()
 def test_native_movement_and_edges(self):
  c=MPU(memory=list(self.ram))
  self.assertEqual(move(c,12,56,1,1),(15,62))
  self.assertEqual(move(c,12,56,-1,-1),(9,50))
  self.assertEqual(move(c,99,110,1,1),(102,112))
  self.assertEqual(move(c,102,112,1,1),(102,112))
  self.assertEqual(move(c,0,0,-1,-1),(0,0))
 def test_collision_model_matches_6502_edges(self):
  signature=bytes.fromhex('ad bF f0 0d 98 f3 0d 61 2d')
  address=bytes(self.ram).index(signature,0x1800,0x1b80)
  c=MPU(memory=list(self.ram));m=c.memory;m[0xe957]=40;m[0xe958]=56
  for dx in (-9,-8,-7,0,18,19,20,21):
   for dy in (-17,-16,-15,0,14,15,16,17):
    m[0x1bd0]=40+dx;m[0x1bd8]=56+dy;m[0xf0bf]=m[0xf398]=m[0x2d61]=0;c.x=0
    call(c,address)
    self.assertEqual(m[0xf398]==3,hit(40,56,40+dx,56+dy),(dx,dy))
 def test_native_escape_routes_three_cycles(self):
  graph=movement_graph(self.ram)
  for pattern in range(FORMATION_COUNT+1):
   frames=trace(self.ram,pattern,(12,56));allowed=allowed_positions(frames,graph)
   for start in STARTS:
    route,counts=escape(frames,start,graph,allowed=allowed)
    self.assertIsNotNone(route,(pattern,start))
    replay_route(self.ram,pattern,start,route,frames)
    for tick,bullets in enumerate(frames[1:],1):
     old={b[0]:b[1:] for b in frames[tick-1]}
     for i,x,y in bullets:
      if i in old:
       if x-old[i][0]>2:
        self.assertLessEqual(old[i][0],7);self.assertEqual((x,y),(88,64))
       else:
        self.assertIn(x-old[i][0],tuple(range(-16,1))+(2,))
        self.assertLessEqual(abs(y-old[i][1]),4)
 def test_curtain_leaves_one_narrow_opening_and_no_camping_height(self):
  for pattern in range(FORMATION_COUNT+1):
   frames=trace(self.ram,pattern,(12,56))
   p=pressure(frames)
   self.assertGreater(p['blockedPercent'],85)
   safe=set(range(113));openings=[]
   for tick in (50,80,110):
    bands=safe_bands(frames[tick]);self.assertEqual(len(bands),1)
    a,b=bands[0];self.assertLessEqual(b-a+1,18)
    openings.append(a);safe&=set(range(a,b+1))
   self.assertGreaterEqual(len(set(openings)),2)
   self.assertFalse(safe)
   for x in (12,48,72,102):
    campers=[y for y in range(113) if all(not blocked((x,y),bs) for bs in frames)]
    self.assertFalse(campers,(pattern,x,campers))

if __name__=='__main__':unittest.main()
