import unittest
from build import create_runtime,package,kult
from py65.devices.mpu6502 import MPU
class SpriteWaves(unittest.TestCase):
 @classmethod
 def setUpClass(cls):cls.p,cls.ram,_,_=create_runtime()
 def call(self,c,address):
  c.pc=address;c.stPushWord(0x1ff)
  for _ in range(300000):
   if c.pc==0x200:return
   c.step()
  self.fail(hex(c.pc))
 def test_loader_reserved_bank_and_original_enemy18(self):
  replay=kult(package(self.p,self.ram))[0]
  self.assertEqual(bytes(replay[0x1800:0x2400]),bytes(self.ram[0x1800:0x2400]))
  original=self.p['banks']['ram'][0x4f80+17*128:0x4f80+18*128]
  for f in range(4):
   for row in range(16):self.assertEqual(bytes(self.ram[0x2000+f*192+row*3:0x2003+f*192+row*3]),bytes(original[f*32+row*2:f*32+row*2+2])+b'\0')
 def test_draw_restore_overlap_and_clipping_both_buffers(self):
  for buffer in (0,1):
   for overlap in (False,True):
    for scroll in (0,3):
     c=MPU(memory=list(self.ram));m=c.memory;m[0x3b1b]=m[0x3b1e]=0x60
     m[0x2d20]=4;m[0x2d22]=80;m[0x2d00]=2;m[0x7439]=buffer;m[0x7446]=scroll
     base=0x8000+buffer*8192;m[base:base+8192]=[0x55]*8192;m[0x7e:0x80]=[0,0x60]
     for y in range(128):m[0x6000+y*3:0x6002+y*3]=list((base+y*64).to_bytes(2,'little'))
     m[0x1be0:0x1be8]=[1]*8;m[0x1bd0:0x1bd8]=[20]*8 if overlap else [0,12,24,64,90,120,124,127];m[0x1bd8:0x1be0]=[56]*8 if overlap else [0,16,32,48,64,112,120,127]
     code=bytes(m[0x1800:0x1b80]);self.call(c,0x1803)
     self.assertNotEqual(m[base:base+8192],[0x55]*8192)
     self.call(c,0x1800);self.assertEqual(m[base:base+8192],[0x55]*8192)
     self.assertEqual(bytes(m[0x1800:0x1b80]),code)
 def test_meteor_edge_does_not_write_outside_sky_or_leave_pixels(self):
  # At the maximum scrolling row offset, an off-right sprite used to spill
  # into the next scanline (and the other framebuffer on the bottom row).
  for buffer in (0,1):
   for scroll in range(1,5):
    for x in range(120,128):
     c=MPU(memory=list(self.ram));m=c.memory
     m[0x3b1b]=m[0x3b1e]=0x60;m[0x2d20]=4;m[0x2d22]=21;m[0x2dc4]=2
     m[0x7439]=buffer;m[0x7446]=scroll;m[0x7e:0x80]=[0,0x60]
     base=0x8000+buffer*8192
     m[0x8000:0xc000]=[0]*16384
     for y in range(128):m[0x6000+y*3:0x6002+y*3]=list((base+y*64+31).to_bytes(2,'little'))
     m[0x1be0:0x1be8]=[1]+[0]*7;m[0x1bd0]=x;m[0x1bd8]=112
     self.call(c,0x1803)
     end_column=31+(128+scroll+3)//4
     allowed={base+y*64+col for y in range(112,128) for col in range(31,end_column)}
     dirty={a for a in range(0x8000,0xc000) if m[a]}
     self.assertTrue(dirty)
     self.assertFalse(dirty-allowed,(buffer,scroll,x,sorted(dirty-allowed)))
     self.call(c,0x1800)
     self.assertFalse(any(m[0x8000:0xc000]))
 def test_full_wave_traversal_and_stationary_boss(self):
  for pattern in (1,2,3):
   c=MPU(memory=list(self.ram));m=c.memory;m[0x2d74]=pattern;m[0x2d23]=88;m[0x2d24]=48;m[0x2d70]=3;m[0xf0bf]=255
   boss=[88,96,104,112]*2+[48]*4+[64]*4;m[0x7462:0x7472]=boss
   points=[];peak=0
   for t in range(127):
    self.call(c,0x6550);live=[(m[0x1bd0+i],m[0x1bd8+i]) for i in range(8) if m[0x1be0+i]];peak=max(peak,len(live));points+=live
    self.assertEqual(m[0x7462:0x7472],boss)
   span=(max(p[0] for p in points)-min(p[0] for p in points),max(p[1] for p in points)-min(p[1] for p in points))
   print('Pattern',pattern,'range:',span,'peak sprites:',peak)
   self.assertEqual(peak,8);self.assertGreater(span[0],80);self.assertGreaterEqual(span[1],112)
   m[0x2d70]=2;self.call(c,0x6550)
   self.assertEqual(m[0x1be0:0x1be8],[0]*8)
if __name__=='__main__':unittest.main()
