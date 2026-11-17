import unittest
from pathlib import Path
from py65.devices.mpu6502 import MPU
from build import create_runtime,package,kult
from workshop import catalog,default_project,validate,pack

class BossArt(unittest.TestCase):
 @classmethod
 def setUpClass(cls):cls.p,cls.ram,_,_=create_runtime()
 def call(self,c,address):
  c.pc=address;c.stPushWord(0x1ff)
  for _ in range(200000):
   if c.pc==0x200:return
   c.step()
  self.fail(hex(c.pc))
 def test_catalog_frames_and_legacy_migration(self):
  bosses=catalog()['bosses'];self.assertEqual(len(bosses),4)
  for b in bosses:
   self.assertEqual((b['width'],b['height']),(64,64));self.assertEqual(len(b['frames']),4)
   self.assertGreaterEqual(len({bytes(f) for f in b['frames']}),3)
   for f in b['frames']:self.assertEqual(len(f),4096);self.assertEqual(set(f),{0,1})
  p=default_project();del p['boss']['design'];self.assertEqual(validate(p)['boss']['design'],'boss-bone-dragon')
  p['boss']['design']='missing'
  with self.assertRaises(ValueError):validate(p)
 def test_all_designs_export_and_replace_original_dragon(self):
  for b in catalog()['bosses']:
   p=default_project();p['boss']['design']=b['id'];original,ram,_,_=create_runtime(p)
   decoded=kult(package(original,ram))[0]
   self.assertEqual(bytes(decoded[0x480:0x1781]),bytes(ram[0x480:0x1781]))
   self.assertEqual(bytes(ram[0xdac0:0xdac0+3]),bytes.fromhex('4cc3da'))
   self.assertEqual(bytes(ram[0xfed2:0xff12]),bytes(64))
   for f,frame in enumerate(b['frames']):
    for tile in range(16):
     pixels=[frame[(tile//4*16+y)*64+tile%4*16+x] for y in range(16) for x in range(16)]
     at=0x800+f*512+tile*32
     self.assertEqual(bytes(decoded[at:at+32]),pack(pixels,16,16))
 def test_original_tile_renderer_every_frame_and_buffer(self):
  b=next(b for b in catalog()['bosses'] if b['id']=='boss-bone-dragon')
  for buffer in (0,1):
   for frame in range(4):
    c=MPU(memory=list(self.ram));m=c.memory;base=0x8000+buffer*8192
    m[0x7e:0x80]=[0,0x60];m[0x7439]=buffer
    for y in range(128):m[0x6000+y*3:0x6002+y*3]=list((base+y*64).to_bytes(2,'little'))
    m[0x2d20]=4;m[0x2d22]=64;m[0x2dc0]=1;m[0x2dc8]=frame;m[0x2d23]=88;m[0x2d24]=48;m[0xfd04]=0
    m[base:base+8192]=[0]*8192
    state=m[0xfcfa:0xfd04].copy();other=m[0xa000 if buffer==0 else 0x8000:0xc000 if buffer==0 else 0xa000].copy()
    self.call(c,0x480)
    self.assertEqual(m[0xfcfa:0xfd04],state)
    expected=pack(b['frames'][frame],64,64)
    for y in range(128):
     want=[0]*64
     if 32<=y<96:want[22:30]=expected[(y-32)*8:(y-31)*8]
     self.assertEqual(m[base+y*64:base+(y+1)*64],want)
    self.assertEqual(m[0xa000 if buffer==0 else 0x8000:0xc000 if buffer==0 else 0xa000],other)
    self.call(c,0xfc7e);self.assertEqual(m[base:base+8192],[0]*8192)
 def test_insect_queen_replaces_every_guardian_frame(self):
  queen=next(b for b in catalog()['bosses'] if b['id']=='boss-insect-queen')
  self.assertNotIn('boss-original-dragon',[b['id'] for b in catalog()['bosses']])
  self.assertEqual(bytes(self.ram[0xfcfe:0xfd00]),bytes([0x40,0x10]))
  self.assertEqual(bytes(self.ram[0xfd02:0xfd04]),bytes([0x40,0x17]))
  for f,frame in enumerate(queen['frames']):
   for t in range(16):
    index=self.ram[0x1740+f*16+t]
    raw=bytes(self.ram[0x1040+(index-1)*32:0x1040+index*32]) if index else bytes(32)
    pixels=[frame[(t//4*16+y)*64+t%4*16+x] for y in range(16) for x in range(16)]
    self.assertEqual(raw,pack(pixels,16,16))
  old=default_project();old['boss']['design']='boss-original-dragon'
  self.assertEqual(validate(old)['boss']['design'],'boss-insect-queen')
 def test_main_boss_draws_generated_queen_through_original_routine(self):
  queen=next(b for b in catalog()['bosses'] if b['id']=='boss-insect-queen')
  for phase,frame in ((0,0),(1,1),(3,2),(5,3)):
   c=MPU(memory=list(self.ram));m=c.memory;m[0xfd04]=1;m[0xfd0a]=100;m[0x2dc0]=1;m[0x2dc8]=frame;m[0x2d23]=88;m[0x2d24]=48
   m[0x7e:0x80]=[0,0x60];m[0x7439]=0;m[0x8000:0xa000]=[0]*8192
   for y in range(128):m[0x6000+y*3:0x6002+y*3]=list((0x8000+y*64).to_bytes(2,'little'))
   self.call(c,0x480)
   y=32;expected=pack(queen['frames'][frame],64,64)
   for row in range(64):self.assertEqual(bytes(m[0x8000+(y+row)*64+22:0x8000+(y+row)*64+30]),expected[row*8:row*8+8])
 def test_retreat_draw_and_erase_never_touch_right_gutter(self):
  for buffer in (0,1):
   for x in range(88,129,4):
    c=MPU(memory=list(self.ram));m=c.memory;base=0x8000+buffer*8192
    m[0x7e:0x80]=[0,0x60];m[0x7439]=buffer;m[0x2d20]=4;m[0x2d22]=64;m[0x2dc0]=3;m[0x2d23]=x;m[0x2d24]=48
    for y in range(128):
     m[0x6000+y*3:0x6002+y*3]=list((base+y*64).to_bytes(2,'little'))
     m[base+y*64:base+y*64+32]=[0]*32;m[base+y*64+32:base+(y+1)*64]=[165]*32
    self.call(c,0x480);self.call(c,0xfc7e)
    for y in range(128):
     self.assertEqual(m[base+y*64:base+y*64+32],[0]*32)
     self.assertEqual(m[base+y*64+32:base+(y+1)*64],[165]*32)
 def test_main_boss_remains_visible_with_scrolled_row_addresses(self):
  queen=next(b for b in catalog()['bosses'] if b['id']=='boss-insect-queen')
  for offset in (0,16,32,48):
   c=MPU(memory=list(self.ram));m=c.memory;m[0xfd04]=1;m[0xfd0a]=100;m[0x2dc0]=3;m[0x2dc8]=0;m[0x2d23]=88;m[0x2d24]=48;m[0x7446]=0
   m[0x7e:0x80]=[0,0x60];m[0x7439]=0;m[0x8000:0xa100]=[0]*8448
   for y in range(128):m[0x6000+y*3:0x6002+y*3]=list((0x8000+offset+y*64).to_bytes(2,'little'))
   self.call(c,0x480);expected=pack(queen['frames'][0],64,64)
   for row in range(64):self.assertEqual(bytes(m[0x8000+offset+(32+row)*64+22:0x8000+offset+(32+row)*64+30]),expected[row*8:row*8+8])
   self.call(c,0xfc7e);self.assertEqual(m[0x8000:0xa100],[0]*8448)
 def test_defeated_boss_does_not_draw(self):
  c=MPU(memory=list(self.ram));c.memory[0x2d20]=4;c.memory[0x2d22]=0
  before=c.memory[0x8000:0xc000].copy();self.call(c,0x480);self.assertEqual(c.memory[0x8000:0xc000],before)
if __name__=='__main__':unittest.main()
