"""Native distance gating and aimed-shot direction at any wave phase."""
import math,unittest
from py65.devices.mpu6502 import MPU
from build import create_runtime
from boss_lab import call
class Approach(unittest.TestCase):
 @classmethod
 def setUpClass(cls):cls.ram=create_runtime()[1]
 def test_gate_distance_phase_and_registers(self):
  c=MPU(memory=list(self.ram));m=c.memory
  for mode in (0,7):
   m[0x2d20]=mode
   for age in (0,47,48,255):
    m[0x2dfc]=age
    for progress in (8,55,56,100):
     m[0x2d42]=progress
     for player in (0,12,60,100):
      m[0xe957]=player
      for enemy in (24,47,48,72,119):
       c.a=enemy;c.x=3;c.y=2;call(c,0xe300)
       allowed=enemy-player>=52
       self.assertEqual(not bool(c.p&1),allowed)
       self.assertEqual((c.a,c.x,c.y),(enemy,3,2))
 def test_aim_uses_distance_speed_and_player_position(self):
  c=MPU(memory=list(self.ram));m=c.memory;m[0xe957]=12
  for mode in (0,7):
   m[0x2d20]=mode
   for speed in (1,3,6,8):
    m[0x2d02]=speed
    for x in (48,72,119):
     m[0x2d14]=x
     for y in (8,40,80,120):
      m[0x2d18]=y
      for player in (0,56,112):
       m[0xe958]=player;c.x=0;call(c,0xe303)
       ticks=math.ceil((x-12)/(6 if mode==7 else speed));delta=player+8-y
       expected=(1 if delta>=0 else -1)*((abs(delta)+ticks//2)//ticks)
       self.assertEqual(c.a,expected&255);self.assertEqual(c.x,0)
 def test_single_aimed_shot_is_dodgeable_after_reaction_delay(self):
  import re
  from pathlib import Path
  from boss_lab import move
  listing=Path(__file__).with_name('space.lst').read_text()
  shots=int(re.search(r'^\s*\d+\s+([0-9A-F]{4})\s+Shots\s*$',listing,re.M)[1],16)
  for start in range(0,113,2):
   for enemy_y in range(8,121,16):
    survived=False
    for dx,direction in ((0,-1),(0,1),(-1,0),(1,0),(-1,-1),(-1,1),(1,-1),(1,1)):
     c=MPU(memory=list(self.ram));m=c.memory
     m[0x2d20]=0;m[0x2d00:0x2d05]=[2,180,6,0,0]
     m[0x2d10:0x2d14]=[1,0,0,0];m[0x2d14]=64;m[0x2d18]=enemy_y
     m[0xe957:0xe959]=[12,start];m[0xf0bf]=m[0xf398]=m[0xfd04]=0
     m[0x74e0:0x74e8]=[0]*8;c.x=0;call(c,0xe303);m[0x2d1c]=c.a
     for tick in range(18):
      move(c,m[0xe957],m[0xe958],0 if tick<2 else dx,0 if tick<2 else direction)
      call(c,shots)
      if m[0xf398]:break
     else:survived=True;break
    self.assertTrue(survived,(start,enemy_y))
if __name__=='__main__':unittest.main()
