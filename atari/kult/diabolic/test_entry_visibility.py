"""Pending actors must never leak into the scrolling right-edge gutter."""
import unittest
from py65.devices.mpu6502 import MPU
from build import create_runtime
from boss_lab import call

class EntryVisibility(unittest.TestCase):
 @classmethod
 def setUpClass(cls):cls.ram=create_runtime()[1]
 def scene(self,buffer=0):
  c=MPU(memory=list(self.ram));m=c.memory
  m[0xfd04]=m[0xf398]=0;m[0x7439]=buffer;m[0x7e:0x80]=[0,0x60]
  base=0x8000+buffer*8192;m[0x8000:0xc000]=[0]*16384
  for y in range(128):m[0x6000+3*y:0x6002+3*y]=list((base+y*64).to_bytes(2,'little'))
  m[0x74e0:0x74e8]=[16]*8;m[0x7482:0x748a]=[0]*8
  m[0x746a:0x7472]=list(range(0,128,16))
  m[0x7a00:0x7d00]=[255]*768
  call(c,0xec4b)
  return c
 def test_waiting_meteors_never_draw_at_any_scroll_phase(self):
  for mode in (1,2,3,6,7):
   for buffer in (0,1):
    for scroll in (1,2,3,4):
     with self.subTest(mode=mode,buffer=buffer,scroll=scroll):
      c=self.scene(buffer);m=c.memory;m[0x2d20]=mode;m[0x2d40:0x2d48]=[128]*8
      # Positions reserved with scroll=4, then drawn after the raster changed it.
      m[0x7462:0x746a]=[124]*8;m[0x7446]=scroll;m[0x7444]=0
      call(c,0xeb25)
      self.assertFalse(any(m[0x8000:0xc000]))
      self.assertEqual(m[0x74e0:0x74e8],[16]*8,'Keep reservations so the wave cannot end early')
      self.assertFalse(any(m[0x74a8:0x74c8]),'Do not save ghost backgrounds')
 def test_new_ordinary_wave_waits_for_its_own_coordinates(self):
  for buffer in (0,1):
   c=self.scene(buffer);m=c.memory;m[0x2d20]=0;m[0x2d21]=0
   m[0x7444]=96;m[0x7446]=1;m[0x7462:0x746a]=[28]*8
   call(c,0xeb25)
   self.assertFalse(any(m[0x8000:0xc000]),'Previous-wave positions flashed with the new enemy graphics')
   call(c,0x3b03)
   self.assertEqual(m[0x2d21],1)
   m[0x7462:0x746a]=[20]*8;m[0x7444]=0
   call(c,0xeb25)
   self.assertTrue(any(m[0x8000:0xc000]),'Real incoming enemies must still draw')
 def test_active_meteors_and_ordinary_rewards_remain_visible(self):
  for mode in (0,1,2,3,6,7):
   c=self.scene();m=c.memory;m[0x2d20]=mode;m[0x2d21]=1;m[0x2d40]=0;c.y=0
   call(c,0x486);self.assertEqual(c.a,16)
  c=self.scene();m=c.memory;m[0x2d20]=m[0x2d21]=0
  for state in (0,4,128):
   m[0x74e0]=state;c.y=0;call(c,0x486);self.assertEqual(c.a,state)

if __name__=='__main__':unittest.main()
