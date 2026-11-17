"""Execute the actual 6502 missile routine and search reachable ship positions."""
import unittest,re
from pathlib import Path
from build import create_runtime
from py65.devices.mpu6502 import MPU

class BossPatterns(unittest.TestCase):
 @classmethod
 def setUpClass(cls):
  original,cls.ram,_,_=create_runtime()
  cls.original_sine=bytes(original['banks']['ram'][0x7164:0x7264])
  cls.shots=int(re.search(r'^\s*\d+\s+([0-9A-F]{4})\s+Shots\s*$',Path(__file__).with_name('space.lst').read_text(),re.M)[1],16)
 def call(self,c):
  c.pc=self.shots;c.stPushWord(0x1ff)
  for _ in range(30000):
   if c.pc==0x200:return
   c.step()
  self.fail('Missile routine failed to return')
 def test_reachable_routes_and_warnings(self):
  for pattern in (1,2,3):
   c=MPU(memory=list(self.ram));m=c.memory
   m[0x2d00]=2;m[0x2d20]=4;m[0x2d22]=80;m[0x2d23]=88;m[0x2d24]=48;m[0xfd04]=0
   m[0x2d74]=pattern;m[0x2d70]=3;m[0xf0bf]=255
   possible={56};seen=False
   for tick in range(127):
    self.call(c)
    bullets=[(m[0x1bd0+i],m[0x1bd8+i]) for i in range(8) if m[0x1be0+i]]
    if tick<23:self.assertFalse(bullets)
    seen|=bool(bullets)
    possible={max(0,min(112,y+dy)) for y in possible for dy in (-6,0,6)}
    possible={y for y in possible if not any(x+8>12 and x<32 and by+16>y and by<y+16 for x,by in bullets)}
    self.assertTrue(possible,(pattern,tick))
   self.assertTrue(seen)
 def test_uses_original_trigonometric_table(self):
  self.assertEqual(bytes(self.ram[0x7164:0x7264]),self.original_sine)
 def test_three_distinct_trigonometric_trajectories(self):
  from boss_lab import trace
  shapes=[trace(self.ram,p,(12,56)) for p in range(1,7)]
  self.assertTrue(all(shapes[a]!=shapes[b] for a in range(6) for b in range(a+1,6)))
  flat=list(self.ram);flat[0x7164:0x7264]=[28]*256
  self.assertNotEqual(shapes[0],trace(flat,1,(12,56)))
 def test_stationary_center_is_hit_at_all_playable_distances(self):
  for pattern in (0,1,2,3):
   for intensity in (0,1,2):
    for x in (12,48,64):
     c=MPU(memory=list(self.ram));m=c.memory;m[0x2d00]=2;m[0x2d20]=4;m[0x2d22]=80;m[0x2d23]=88;m[0x2d24]=48;m[0xfd04]=0;m[0x2d74]=pattern;m[0x2d75]=intensity;m[0xe957]=x;m[0xe958]=56;m[0xf0bf]=0;m[0xf398]=0
     for _ in range(255):self.call(c)
     self.assertEqual(m[0xf398],3,(pattern,intensity,x))
     m[0x2d22]=0;self.call(c);self.assertEqual(m[0x2d10:0x2d14],[0]*4)
 def test_boss_stays_anchored_after_entry(self):
  c=MPU(memory=list(self.ram));m=c.memory;m[0x2d20]=4;m[0x2d22]=80;m[0x2d23]=128;m[0x74e0:0x74e8]=[16]*8;m[0x2d29]=0;m[0x7446]=0
  for tick in range(300):
   c.pc=0x3b03;c.stPushWord(0x1ff)
   while c.pc!=0x200:c.step()
   self.assertEqual(m[0x2d24],48)
   if tick>=19:self.assertEqual(m[0x2d23],88)
if __name__=='__main__':unittest.main()
