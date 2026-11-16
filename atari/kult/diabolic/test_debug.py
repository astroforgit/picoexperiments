import unittest
from build import create_runtime
from py65.devices.mpu6502 import MPU
class DebugJump(unittest.TestCase):
 @classmethod
 def setUpClass(cls):_,cls.ram,_,_=create_runtime()
 def call(self,c):
  c.pc=0x3f50;c.stPushWord(0x1ff)
  for _ in range(200000):
   if c.pc==0x200:return
   c.step()
  self.fail(hex(c.pc))
 def test_jump_hold_release_repeat_all_sectors(self):
  for stage in range(8):
   c=MPU(memory=list(self.ram));m=c.memory;m[0x4e75]=stage;m[0x74e0:0x74e8]=[16]*8;m[0x7482:0x748a]=[17]*8;m[0x2d10:0x2d14]=[1]*4;m[0x74e8:0x74ee]=[1]*6
   m[0xd20f]=0;m[0xd209]=0x1f;m[0x4e79]=40
   before=bytes(m[0x4000:0x4400])+bytes(m[0x6384:0x6684])
   self.call(c)
   self.assertEqual(m[0x2d20],4);self.assertEqual(m[0xfb8a],8);self.assertGreater(m[0x2d22],0);self.assertEqual(m[0x7482:0x748a],[0]*8);self.assertEqual(m[0x2d10:0x2d14],[0]*4);self.assertEqual(m[0x74e8:0x74ee],[0]*6);self.assertEqual(m[0xfd04],0)
   m[0x2d22]=3;self.call(c);self.assertEqual(m[0x2d22],3)
   m[0xd20f]=4;self.call(c);m[0xd20f]=0;self.call(c);self.assertGreater(m[0x2d22],3)
   self.assertEqual(before,bytes(m[0x4000:0x4400])+bytes(m[0x6384:0x6684]))
 def test_reordered_wave_and_missing_boss(self):
  c=MPU(memory=list(self.ram));m=c.memory;m[0x4e75]=0;m[0xd20f]=0;m[0xd209]=0x1f;m[0x74e0:0x74e8]=[16]*8
  m[0x4400+7*4+1]&=31;m[0x4400+17*4+1]|=128
  self.call(c);self.assertEqual(m[0xfb8a],18);self.assertEqual(m[0x2d20],4)
  c=MPU(memory=list(self.ram));m=c.memory;m[0x4e75]=0;m[0xd20f]=0;m[0xd209]=0x1f;m[0x74e0:0x74e8]=[16]*8;m[0xfb8a]=5
  for w in range(48):m[0x4401+w*4]&=31
  self.call(c);self.assertEqual(m[0xfb8a],5)
if __name__=='__main__':unittest.main()
