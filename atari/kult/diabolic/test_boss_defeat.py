import unittest
from py65.devices.mpu6502 import MPU
from build import create_runtime
from boss_lab import call

class BossDefeat(unittest.TestCase):
 @classmethod
 def setUpClass(cls):_,cls.ram,_,_=create_runtime()
 def scene(self,guardian):
  c=MPU(memory=list(self.ram));m=c.memory
  m[0xfd04]=guardian;m[0xfd0a]=m[0x2d22]=0;m[0x2d20]=4;m[0x2dc0]=1
  m[0x2d23:0x2d25]=[88,48];m[0xf398]=m[0xf0bf]=m[0x2d61]=0
  m[0xe957:0xe959]=[100,56]
  return c
 def test_both_bosses_burst_once_without_hitting_or_moving_player(self):
  for guardian in (0,1):
   c=self.scene(guardian);m=c.memory
   call(c,0x030f);self.assertFalse(c.p&1)
   call(c,0xdac0)
   self.assertEqual(m[0x2dc0],9);self.assertEqual(m[0x1be0:0x1be8],[1]*8)
   self.assertEqual(m[0x1bd0:0x1bd8],[100]*8);self.assertEqual(m[0x1bd8:0x1be0],[56]*8)
   for tick in range(24):
    call(c,0x030f);self.assertFalse(c.p&1)
    for i in range(8):c.x=i;call(c,0x1809)
    self.assertEqual(m[0xf398],0)
    call(c,0xdac0)
   self.assertEqual(m[0x2dc0],10);self.assertFalse(any(m[0x1be0:0x1be8]))
   self.assertEqual(m[0xe957:0xe959],[100,56])
   for _ in range(8):call(c,0xdac0)
   self.assertEqual(m[0x2dc0],10);self.assertFalse(any(m[0x1be0:0x1be8]))
 def test_zero_health_burst_draws_and_erases_in_both_buffers(self):
  for guardian in (0,1):
   for buffer in (0,1):
    c=self.scene(guardian);m=c.memory;call(c,0xdac0)
    m[0x3b1b]=m[0x3b1e]=0x60;m[0x7439]=buffer;m[0x7446]=0;m[0x7e:0x80]=[0,0x60]
    base=0x8000+buffer*8192;m[base:base+8192]=[0]*8192
    for y in range(128):m[0x6000+y*3:0x6002+y*3]=list((base+y*64).to_bytes(2,'little'))
    call(c,0x1803);self.assertTrue(any(m[base:base+8192]))
    call(c,0x1800);self.assertFalse(any(m[base:base+8192]))
 def test_old_player_explosion_is_bypassed_at_guardian_completion(self):
  self.assertEqual(bytes(self.ram[0xfc64:0xfc67]),bytes.fromhex('4c7cfc'))
  for entry in (0xf39d,0xf3e5,0xf420):self.assertEqual(self.ram[entry],0x60)
if __name__=='__main__':unittest.main()
