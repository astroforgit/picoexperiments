import unittest
from py65.devices.mpu6502 import MPU
from build import create_runtime,package,kult
from boss_lab import call
from workshop import drop_patterns
class Clock(unittest.TestCase):
 @classmethod
 def setUpClass(cls):cls.p,cls.ram,_,_=create_runtime()
 def cpu(self):
  c=MPU(memory=list(self.ram));m=c.memory;m[0xf398]=m[0x7460]=0;m[0xd20f]=4
  call(c,0x2e0f);return c
 def press(self,c,key=0x17):
  c.memory[0xd20f]=0;c.memory[0xd209]=key;call(c,0x2e00)
 def test_keys_stock_duration_and_no_hold_repeat(self):
  for key in (0x17,0x16,0x12):
   c=self.cpu();m=c.memory;self.press(c,key)
   self.assertEqual(m[0x2d90:0x2d92],[150,2])
   for i in range(149):
    call(c,0x2e0c);call(c,0x2e00)
   self.assertEqual(m[0x2d90:0x2d92],[1,2])
   call(c,0x2e0c);call(c,0x2e00)
   self.assertEqual(m[0x2d90:0x2d92],[0,2]);self.assertEqual(m[0x2d94],0)
   call(c,0x2e00);self.assertEqual(m[0x2d91],2)
   m[0xd20f]=4;call(c,0x2e00);self.press(c,key)
   self.assertEqual(m[0x2d90:0x2d92],[150,1])
  c=self.cpu();c.memory[0x2d91]=0;self.press(c)
  self.assertEqual(c.memory[0x2d90],0)
 def test_pause_death_and_real_time_not_update_count(self):
  c=self.cpu();m=c.memory;self.press(c)
  for _ in range(200):call(c,0x2e00)
  self.assertEqual(m[0x2d90],150)
  m[0x7460]=255
  for _ in range(20):call(c,0x2e0c)
  self.assertEqual(m[0x2d90],150)
  m[0xf398]=3;call(c,0x2e00)
  self.assertEqual((m[0x2d90],m[0x2d94],c.a),(0,0,3))
 def load(self,c,kind):
  m=c.memory;m[0xfd04]=0;m[0x74e0:0x74e8]=[16]*8
  m[0x80:0x82]=[0,0x44];m[0x4401]=kind<<5;m[0xfb8a]=0;m[0xfc09]=4;c.a=0
  call(c,0x3b00)
 def test_every_wave_moves_on_every_third_update(self):
  for mode in (0,1,2,3,4,6,7):
   a=self.cpu();b=self.cpu();self.load(a,mode);self.load(b,mode);self.press(b)
   for tick in range(20):
    if tick:call(b,0x2e00)
    call(b,0x2e03)
    if tick%3==2:call(a,0x2e03)
   for lo,hi in ((0x7410,0x7414),(0x7462,0x7472),(0x2d40,0x2d50)):
    self.assertEqual(a.memory[lo:hi],b.memory[lo:hi],(mode,hex(lo)))
 def test_player_projectiles_and_ship_keep_normal_speed(self):
  a=self.cpu();b=self.cpu();self.press(b)
  for c in (a,b):
   m=c.memory;m[0xf533]=0x60;m[0x74e8:0x74ee]=[8]*6;m[0x74ee:0x74f4]=[0]*6;m[0x74f4:0x74fa]=[50]*6
   m[0xf24d]=0;m[0xd300]=7;m[0xe957:0xe959]=[12,56]
  for tick in range(6):
   if tick:call(b,0x2e00)
   call(a,0xe95b);call(b,0xe95b)
   call(b,0x2e18)
   call(a,0x2e18)
  self.assertEqual(a.memory[0x74ee:0x74fa],b.memory[0x74ee:0x74fa])
  self.assertEqual(a.memory[0xe957:0xe959],b.memory[0xe957:0xe959])
  self.assertNotEqual(b.memory[0xe957],12)
 def test_pickups_cap_and_drop_frequency(self):
  rows=drop_patterns(self.p['banks']['ram'])
  self.assertTrue(all(sum(v>0 for v in row)<=2 for row in rows))
  self.assertEqual(sum(row.count(6) for row in rows),24)
  self.assertEqual(sum(row.count(7) for row in rows),4)
  for kind,address in ((5,0x2d91),(6,0x2d70)):
   c=self.cpu();m=c.memory;m[0xf9cc]=0x60;m[address]=2;c.a=kind;call(c,0x2e12)
   self.assertEqual(m[address],3);c.a=kind;call(c,0x2e12);self.assertEqual(m[address],3)
 def test_boss_actions_third_speed_and_frozen_bullets_collide(self):
  for guardian in (False,True):
   a=self.cpu();b=self.cpu()
   for c in (a,b):
    m=c.memory;m[0xfd04]=int(guardian);m[0xfd0a]=100;m[0x2d20]=0 if guardian else 4
    m[0x2d22]=64;m[0x2d00]=2;m[0x2d78]=1;m[0x74e0:0x74e8]=[16]*8
   self.press(b)
   for tick in range(240):
    if tick:call(b,0x2e00)
    a.memory[0xf0bf]=b.memory[0xf0bf]=255
    call(b,0x2e06)
    if tick%3==2:call(a,0x2e06)
   for lo,hi in ((0x2dc0,0x2dc9),(0x1bd0,0x1c00),(0x2d23,0x2d25)):
    self.assertEqual(a.memory[lo:hi],b.memory[lo:hi],(guardian,hex(lo)))
  c=self.cpu();m=c.memory;m[0x2d20]=4;m[0x2d94]=1
  m[0xe957:0xe959]=[12,56];m[0x1be0]=1;m[0x1bd0]=20;m[0x1bd8]=56
  m[0xf0bf]=m[0x2d61]=0
  call(c,0x2e06)
  self.assertEqual(m[0xf398],3);self.assertEqual(m[0x1bd0],20)
 def test_loader_and_blank_boss_targets_preserve_clock_code(self):
  c=self.cpu();code=c.memory[0x2e00:0x3000].copy();self.load(c,4)
  self.assertEqual(c.memory[0x7a00:0x8000],[0]*0x600)
  self.assertEqual(c.memory[0x2e00:0x3000],code)
  decoded=kult(package(self.p,self.ram))[0]
  self.assertEqual(decoded[0x2e00:0x3000],self.ram[0x2e00:0x3000])
if __name__=='__main__':unittest.main()
