import unittest,sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from build import create_runtime,package,kult
from workshop import default_project,validate
from py65.devices.mpu6502 import MPU
class Encounters(unittest.TestCase):
 @classmethod
 def setUpClass(cls):cls.p,cls.ram,_,_=create_runtime()
 def cpu(self):return MPU(memory=list(self.ram))
 def call(self,c,address):
  c.pc=address;c.stPushWord(0x1ff)
  for _ in range(200000):
   if c.pc==0x200:return
   c.step()
  self.fail(hex(c.pc))
 def load(self,c,kind):
  c.memory[0xfd04]=0;c.memory[0x74e0:0x74e8]=[16]*8
  c.memory[0x80:0x82]=[0,0x44];c.memory[0x4401]=kind<<5;c.memory[0xfb8a]=0;c.memory[0xfc09]=4;c.a=7
  self.call(c,0x3b00)
 def test_meteor_immunity_and_exit(self):
  for kind in (1,2,3):
   c=self.cpu();self.load(c,kind);c.memory[0x4e77]=3;c.memory[0xd20f]=0
   for _ in range(192):
    self.call(c,0x3b03)
    for i in range(8):
     c.x=i;hp=c.memory[0x7586+i];self.call(c,0x3b09);self.assertEqual(c.memory[0x7586+i],hp)
    self.call(c,0x3b0c);self.assertEqual(c.memory[0x4e77],3)
   for _ in range(50):self.call(c,0x3b03)
   self.assertEqual(c.memory[0x74e0:0x74e8],[128]*8)
   c.memory[0x74e0:0x74e8]=[0]*8;self.call(c,0x3b03);self.assertEqual(c.memory[0x74e0:0x74e8],[0]*8)
 def test_boss_composite_health_and_restore(self):
  c=self.cpu();original=c.memory[0x7d00:0x8000].copy();self.load(c,4)
  for _ in range(25):self.call(c,0x3b03)
  self.assertEqual(c.memory[0x7462:0x746a],[88,96,104,112]*2)
  self.assertEqual(c.memory[0x2d22],32)
  for i in range(8):c.y=i;self.call(c,0x3b06);self.assertEqual(c.a,i)
  for i in range(32):c.x=i%8;self.call(c,0x3b09)
  self.assertEqual(c.memory[0x2d22],0);self.assertEqual(c.memory[0x7482:0x748a],[0x11,0x12,0x14,0,0,0,0,0]);self.assertEqual(c.memory[0x74e0:0x74e8],[0,0,0,128,128,128,128,128])
  self.load(c,0);self.assertEqual(c.memory[0x7d00:0x8000],original)
 def test_pack_encounter_flags_and_legacy(self):
  out=package(self.p,self.ram);ram=kult(out)[0]
  self.assertEqual(ram[0x4400+2*4+1]>>5,1);self.assertEqual(ram[0x4400+7*4+1]>>5,4)
  p=default_project();del p['encounters'];self.assertEqual(validate(p)['encounters'][0],[0]*48)
  p['encounters']=[[5]*48]*8
  with self.assertRaises(ValueError):validate(p)
 def test_player_death_does_not_resurrect_corrupted_sprites(self):
  for kind in (1,2,3,4):
   c=self.cpu();self.load(c,kind);c.memory[0x74e0:0x74e8]=[0]*8
   self.call(c,0x3b03);self.assertEqual(c.memory[0x74e0:0x74e8],[0]*8)
 def test_meteors_spawn_at_top_and_drain_without_vanishing(self):
  for kind in (1,2,3):
   c=self.cpu();self.load(c,kind);previous=[128]*8;spawned=0;speeds=(2,4,6,3,5,4,7,5)
   for tick in range(245):
    self.call(c,0x3b03);current=c.memory[0x2d40:0x2d48]
    for i,(old,new) in enumerate(zip(previous,current)):
     if old>=128 and new<128:
      self.assertEqual(new,0);self.assertLess(c.memory[0x2d21],192);spawned+=1
     elif old<128:
      self.assertEqual(new,min(128,old+speeds[i]))
    previous=current.copy()
   self.assertGreater(spawned,8);self.assertEqual(previous,[128]*8)
 def test_first_meteor_is_slow_and_has_warning_gap(self):
  c=self.cpu();self.load(c,1)
  for tick in range(25):
   self.call(c,0x3b03)
   self.assertEqual(c.memory[0x2d40],tick*2)
   self.assertEqual(c.memory[0x2d41:0x2d48],[128]*7)
 def test_reward_triplet_is_not_repeated(self):
  c=self.cpu();self.load(c,4);c.memory[0x2d22]=1;c.x=0;self.call(c,0x3b09)
  self.assertEqual(c.memory[0x7482:0x7485],[0x11,0x12,0x14])
  c.memory[0x7482]=0
  for _ in range(10):self.call(c,0x3b03)
  self.assertEqual(c.memory[0x7482],0)
 def test_boss_meter_full_half_empty_and_hidden(self):
  c=self.cpu();self.load(c,4)
  for hp,filled in ((32,14),(16,7),(1,1),(0,0)):
   c.memory[0x2d22]=hp;self.call(c,0x3b0f)
   self.assertEqual(sum(c.memory[0x679a+row*32]==255 for row in range(14)),filled)
  c.memory[0x2d20]=0;self.call(c,0x3b0f)
  self.assertTrue(all(c.memory[0x677a+row*32]==0 for row in range(16)))
  c.memory[0xfd04]=1;c.memory[0xfd0a]=50;self.call(c,0x3b0f)
  self.assertEqual(sum(c.memory[0x679a+row*32]==255 for row in range(14)),7)
 def test_space_shield_stock_duration_and_hold(self):
  c=self.cpu();c.memory[0xf51a]=0x60;c.memory[0xf398]=0;c.memory[0xf0bf]=0
  c.memory[0x4e77]=3;c.memory[0xd20f]=0xfb;c.memory[0xd209]=0x21
  self.call(c,0x3b12);self.assertEqual(c.memory[0x4e77],2);self.assertEqual(c.memory[0x2d61],17)
  for _ in range(17):self.call(c,0x3b12)
  self.assertEqual(c.memory[0x2d61],0);self.assertEqual(c.memory[0x4e77],2)
  c.memory[0xd20f]=0xff;self.call(c,0x3b12)
  c.memory[0xd20f]=0xfb;self.call(c,0x3b12);self.assertEqual(c.memory[0x4e77],1)
 def test_shield_keeps_ship_visible(self):
  c=self.cpu();c.memory[0xf0bf]=32;c.memory[0x2d61]=17
  self.call(c,0x3b18);self.assertEqual(c.a,0)
  c.memory[0x2d61]=0;self.call(c,0x3b18);self.assertEqual(c.a,32)
 def test_shield_pickup_cap(self):
  for stock,expected in ((0,1),(2,3),(3,3)):
   c=self.cpu();c.memory[0x4e77]=stock;c.pc=0xf9fd
   for _ in range(12):
    if c.pc==0xfa0a:break
    c.step()
   self.assertEqual(c.memory[0x4e77],expected)
 def test_tight_shield_restores_both_framebuffers(self):
  c=self.cpu();c.memory[0xec05]=c.memory[0xeca7]=0x60;c.memory[0x2d61]=17
  for buffer,base in enumerate((0x8000,0xa000)):
   table=0x6000+buffer*0x200
   for y in range(128):c.memory[table+y*3:table+y*3+2]=list((base+y*64).to_bytes(2,'little'))
   c.memory[base:base+8192]=[0x55]*8192
  for buffer in (0,1):
   c.memory[0x7439]=buffer;c.memory[0x7e:0x80]=[0,0x60+buffer*2]
   c.memory[0xe957]=30;c.memory[0xe958]=50;c.memory[0x7446]=2
   self.call(c,0x3b1b);self.assertEqual(c.memory[0x2d63+buffer],c.memory[0x2d68])
   base=0x8000+buffer*0x2000
   changed=[(i%64*8+bit,i//64) for i,v in enumerate(c.memory[base:base+8192]) for bit in range(8) if (v^0x55)&(128>>bit)]
   self.assertTrue(changed);self.assertTrue(all(62<=x<=105 and 48<=y<=67 for x,y in changed))
  for buffer in (0,1):
   c.memory[0x7439]=buffer;self.call(c,0x3b1e)
   self.assertEqual(c.memory[0x8000+buffer*8192:0xa000+buffer*8192],[0x55]*8192)
 def test_shield_ring_clips_to_sky(self):
  c=self.cpu();c.memory[0xec05]=c.memory[0xeca7]=0x60;c.memory[0x2d61]=17
  c.memory[0xe957]=c.memory[0xe958]=c.memory[0x7446]=c.memory[0x7439]=0;c.memory[0x7e:0x80]=[0,0x60]
  for y in range(128):c.memory[0x6000+y*3:0x6002+y*3]=list((0x8000+y*64).to_bytes(2,'little'))
  self.call(c,0x3b1b);count=c.memory[0x2d63];self.assertLess(count,c.memory[0x2d68]);self.assertGreater(count,0)
  for i in range(count):self.assertTrue(0x8000<=c.memory[0x2500+i]+256*c.memory[0x2600+i]<0xa000)
 def test_bomb_key_no_longer_damages_boss(self):
  c=self.cpu();self.load(c,4);c.memory[0xd20f]=0;c.memory[0x4e77]=2;c.memory[0xf360]=0
  self.call(c,0x3b0c);self.assertEqual(c.memory[0x2d22],32);self.assertEqual(c.memory[0x4e77],2)
if __name__=='__main__':unittest.main()
