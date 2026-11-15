import unittest
from py65.devices.mpu6502 import MPU
from build import create_runtime

class HudTests(unittest.TestCase):
 @classmethod
 def setUpClass(cls):cls.ram=create_runtime()[1]
 def cpu(self):return MPU(memory=list(self.ram))
 def call(self,c,pc):
  c.pc=pc;c.stPushWord(0x1ff)
  for _ in range(100000):
   if c.pc==0x200:return
   c.step()
  self.fail(f'Routine did not return: {pc:04x}')
 def test_native_initialization_preserves_hud_code_and_bomb_sound(self):
  c=self.cpu();code=c.memory[0x6384:0x6684].copy()
  self.call(c,0xf8be) # actual original new-stage/background initialization
  self.assertEqual(c.memory[0x6384:0x6684],code)
  c.a=3;self.call(c,0x6387);c.memory[0xd20f]=0;c.memory[0xfd04]=0;c.memory[0x2d20]=0
  c.memory[0x74e0:0x74e8]=[16]*8
  self.call(c,0x638a) # execute actual sound setup, not a stub
  self.assertEqual(c.memory[0x2d70],2);self.assertEqual(c.memory[0x4e77],3)
  self.assertEqual(c.memory[0x74e0:0x74e8],[4]*8)
  for _ in range(4):self.call(c,0xfa8d);self.call(c,0xf51a)
  self.assertEqual(c.memory[0x6384:0x6684],code)
  self.assertEqual(c.memory[0x4000:0x4400],list(self.ram[0x4000:0x4400]))
  self.assertEqual(c.memory[0x74e0:0x74e8],[128]*8)
 def test_redesigned_pickups_match_native_sprite_rows(self):
  import json
  from pathlib import Path
  from build import word
  icons=json.loads((Path(__file__).parent/'art/pickups.json').read_text())
  self.assertEqual(len(icons),5)
  for i,icon in enumerate(icons):
   base=word(self.ram,0x7264+i*2);frame=icon['frames'][0]
   for y in range(16):
    packed=bytes([sum(frame[y*16+x+k]<<(7-k) for k in range(8)) for x in (0,8)]+[0])
    self.assertEqual(bytes(self.ram[base+y*3:base+y*3+3]),packed)

 def test_counters_and_score_are_in_bottom_panel(self):
  c=self.cpu();c.memory[0x4e78]=4;c.memory[0x4e77]=2;c.memory[0x2d70]=1;c.memory[0x4e75]=5
  c.memory[0x4e7c:0x4e80]=[0x78,0x56,0x34,0x12]
  top=c.memory[0x6384:0x6684].copy();ship=c.memory[0x6a84:0x6f84].copy()
  self.call(c,0x6384)
  for x,number in ((21,3),(25,1),(29,2)):
   actual=[c.memory[0x6684+(5+y)*32+x] for y in range(8)]
   self.assertEqual(actual,c.memory[0x4c00+number*8:0x4c08+number*8])
  for i,number in enumerate(range(1,9)):
   self.assertEqual([c.memory[0x680e+i+y*32] for y in range(8)],c.memory[0x4c00+number*8:0x4c08+number*8])
  self.assertEqual(c.memory[0x6384:0x6684],top)
  self.assertEqual(c.memory[0x6a84:0x6f84],ship)
 def test_top_display_list_uses_blank_lines_then_sky(self):
  for start,target in ((0x6001,0x601b),(0x61c3,0x61dd)):
   self.assertEqual(bytes(self.ram[start:start+6]),bytes([0x70]*3+[1,target&255,target>>8]))
 def test_four_distinct_dotted_weapon_previews(self):
  c=self.cpu();patterns=[]
  for weapon in range(4):
   c.memory[0xf24d]=weapon;self.call(c,0x638d)
   rows=[c.memory[0x6684+(8+y)*32+5:0x6684+(8+y)*32+7] for y in range(16)]
   patterns.append(bytes(v for row in rows for v in row))
   for row in rows:
    bits=row[0]*256+row[1]
    self.assertEqual(bits & (bits<<1),0) # separated dots, no continuous beams
  self.assertEqual(len(set(patterns)),4)
 def test_bomb_initialization_empty_stock_and_meteor_immunity(self):
  c=self.cpu();c.a=3;self.call(c,0x6387)
  self.assertEqual((c.memory[0x2d70],c.memory[0x4e77]),(3,3))
  c.memory[0xf533]=0x60;c.memory[0xd20f]=0;c.memory[0x2d20]=1
  c.memory[0x74e0:0x74e8]=[16]*8
  self.call(c,0x638a)
  self.assertEqual(c.memory[0x74e0:0x74e8],[16]*8)
  self.assertEqual(c.memory[0x4e77],3)
  c.memory[0x2d71]=c.memory[0x2d70]=0;c.memory[0x2d20]=0
  self.call(c,0x638a);self.assertEqual(c.memory[0x74e0:0x74e8],[16]*8)
 def test_bombs_hit_ordinary_enemies_and_guardian(self):
  for guardian in (False,True):
   c=self.cpu();c.memory[0xf533]=0x60;c.memory[0xd20f]=0;c.memory[0x2d70]=3
   c.memory[0x74e0:0x74e8]=[16]*8;c.memory[0x2d10:0x2d14]=[1]*4
   c.memory[0xfd04]=int(guardian);c.memory[0xfd0a]=10
   self.call(c,0x638a)
   self.assertEqual(c.memory[0x2d70],2);self.assertEqual(c.memory[0x2d10:0x2d14],[0]*4)
   if guardian:self.assertEqual(c.memory[0xfd0a],0)
   else:self.assertEqual(c.memory[0x74e0:0x74e8],[4]*8)
if __name__=='__main__':unittest.main()
