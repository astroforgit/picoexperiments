#!/usr/bin/env python3
import sys,unittest
from pathlib import Path
ROOT=Path(__file__).resolve().parent
sys.path.insert(0,str(ROOT))
from build import project,kult,word
from py65.devices.mpu6502 import MPU

class NativeSpaceTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.original=project('kult')['banks']['ram']
        cls.ram=kult((ROOT/'kult-diabolic.xex').read_bytes())[0]
    def cpu(self):return MPU(memory=list(self.ram))
    def call(self,c,pc,stop=0x200):
        c.pc=pc;c.stPushWord(stop-1)
        for _ in range(100000):
            if c.pc==stop:return
            c.step()
        self.fail(f'CPU did not return from {pc:04x}')
    def test_only_intended_ranges_changed(self):
        allowed=[(0x1780,0x1800),(0xf914,0xf917),(0xeaad,0xeab0),(0xf91c,0xf91f),(0xeb52,0xeb55),(0xfcab,0xfcae),(0x300,0x480),(0xf80e,0xf811),(0xf819,0xf81c),(0xfb8c,0xfb90),(0xfdad,0xfdb1),(0xfc9b,0xfc9e),(0xfcfe,0xfd00),(0xfd02,0xfd04),(0xdac0,0xdf00),(0xfed2,0xff12),(0x480,0x1781),(0xf925,0xf928),(0x1800,0x2400),(0xc1ff,0xc202),(0xf801,0xf804),(0xf8de,0xf8df),(0x6f84,0x7074),(0x6001,0x6007),(0x61c3,0x61c9),(0x6384,0x6a84),(0xeb25,0xeb28),(0xed1c,0xed1d),(0xf814,0xf816),(0xf891,0xf894),(0xf39d,0xf39e),(0xf81f,0xf831),(0xf48d,0xf48e),(0xf491,0xf492),(0xf476,0xf477),(0xf47a,0xf47b),(0xee11,0xee14),(0xed7a,0xed7d),(0x4f80,0x5f80),(0xf90b,0xf90e),(0xf93c,0xf93f),(0xf92b,0xf92e),(0xf7fb,0xf7fe),(0xf890,0xf891),(0xfa04,0xfa05),(0xf420,0xf421),(0xf46f,0xf470),(0x7044,0x7074),(0x6499,0x657b),(0xf81c,0xf81f),(0x6777,0x699c),(0x4e7b,0x4e7c),(0xf841,0xf844),(0xf3e5,0xf3e6),(0xc1b4,0xc1b7),(0xf886,0xf889),(0xfa13,0xfa16),(0x4400,0x4a00),(0xfc22,0xfc25),(0xf7f2,0xf7f5),(0xeb60,0xeb63),(0xfa64,0xfa67),(0xf816,0xf819),(0x4a00,0x4b00),(0x7310,0x7410),(0xebb1,0xebb3),(0xfc1b,0xfc1c),(0x2400,0x4400),(0x6a84,0x6f84),(0xf746,0xf749),(0xf834,0xf837),(0xc41b,0xc41e),(0xe843,0xe846),(0xf75f,0xf760),(0xf764,0xf765),(0xf769,0xf76a),(0xc126,0xc129),(0xc23b,0xc23c),(0xf975,0xf977)]
        loaded=set()
        for block in project('kult')['blocks']:
            if block['start'] not in (0xd301,0xbb00):loaded.update(range(block['start'],block['start']+block['size']))
        for a in loaded:
            old,new=self.original[a],self.ram[a]
            if old!=new:self.assertTrue(any(lo<=a<hi for lo,hi in allowed),hex(a))
    def test_no_fuel_items_logic_or_gauge(self):
        self.assertNotIn(7,self.ram[0x4a00:0x4b00])
        c=self.cpu();c.memory[0x4e7b]=0;c.memory[0xf398]=0
        for _ in range(1000):
            c.pc=0xf841;c.step();self.assertEqual(c.pc,0xf85b)
        self.assertEqual(c.memory[0xf398],0)
        before=c.memory[0x6300:0x6a00].copy();self.call(c,0xf3e5)
        self.assertEqual(c.memory[0x6300:0x6a00],before)

    def test_ship_alignments(self):
        for frame in range(4):
            base=word(self.ram,0x7450+frame*2);src=self.ram[base:base+80]
            self.assertNotEqual(src,self.original[base:base+80])
            for shift in range(4):
                expected=b''.join((int.from_bytes(src[y*5:y*5+5],'big')>>(shift*2)).to_bytes(5,'big') for y in range(16))
                self.assertEqual(expected,self.ram[base+shift*80:base+(shift+1)*80])
    def test_background_cannot_hit_ship_but_enemies_can(self):
        for pixel,expected in [(0,0),(0x55,0),(0xaa,3),(0xff,3)]:
            c=self.cpu();c.memory[0xef74]=0x60;c.memory[0xfa]=0;c.memory[0xfb]=0x78
            c.memory[0x7800:0x7850]=[pixel]*80;c.memory[0xf398]=0
            self.call(c,0xf953);self.assertEqual(c.memory[0xf398],expected)
        # Every enemy frame still has solid pixels after reserving colour 01.
        for frame in range(128):self.assertTrue(any(v&0xaa for v in self.ram[0x4f80+frame*32:0x4fa0+frame*32]))
    def test_leftward_depth_speeds_wrapping_twinkle_and_cleanup(self):
        c=self.cpu();c.memory[0xe9d6]=0x60;self.call(c,0x4000)
        positions=c.memory[0xd004:0xd008]
        graphics=c.memory[0x3300:0x3800]
        pages=(0x3800,0x3900,0x3a00)
        original=[c.memory[p+40:p+168] for p in pages]
        colours=[]
        for _ in range(16):
            stack=c.sp;self.call(c,0x4003,0xf908);c.sp=stack
            colours.append(tuple(c.memory[0x2c0:0x2c4]))
        for page,data,shift in zip(pages,original,(28,12,4)):
            expected=[58+(v-58-shift)%137 if v else 0 for v in data]
            self.assertEqual(c.memory[page+40:page+168],expected)
        for lane in range(3):
            for y in range(256):
                x=c.memory[0x3800+lane*256+y]
                self.assertEqual(c.memory[0x3400+lane*256+y],c.memory[0x2800+lane*256+y]&c.memory[0x2c00+x])
        self.assertEqual(c.memory[0xd004:0xd008],positions)
        self.assertGreater(len(set(colours)),1)
        self.assertTrue(all(all(v%2==0 and 2<=v<=14 for v in frame) for frame in colours))
        self.call(c,0x4006);self.assertEqual(c.memory[0xd01d],0)
        self.assertEqual(c.memory[0xd000:0xd008],[0]*8)
    def test_stars_clip_only_at_sky_edges(self):
        # Actual hardware coordinates: sky spans colour clocks 64..191.
        # A round star's widest row is bits 3..4. It remains partly visible
        # until its trailing pixels leave the left edge, then respawns outside.
        for x,expected in ((61,0x18),(60,0x08),(59,0),(58,0),(194,0),(188,0x10),(187,0x18),(186,0x18)):
            self.assertEqual(0x18 & self.ram[0x2c00+x],expected)

    def test_direct_start_and_star_raster(self):
        self.assertEqual(self.ram[0xc126:0xc129],bytes.fromhex('4c55c1'))
        self.assertEqual(self.ram[0xc23b],0x60)
        c=self.cpu();c.memory[0xe9d6]=0x60;self.call(c,0x4000)
        self.assertEqual(c.memory[0xd00c],0x55)  # all four missiles double width
        self.assertEqual((c.memory[0x601b],c.memory[0x61dd]),(0x80,0x80))
        c.a=0x91;c.x=0x37;c.y=0x5b;c.memory[0xd40b]=19
        c.stPushWord(0x200);c.stPush(c.p);c.pc=0x400c
        positions=[]
        for _ in range(10000):
            if c.pc==0x200:break
            if c.memory[c.pc:c.pc+3]==[0x8d,0,0xd0]:positions.append(c.a)
            c.step()
        else:self.fail('Star raster did not return')
        self.assertEqual((c.a,c.x,c.y),(0x91,0x37,0x5b))
        self.assertEqual(positions,c.memory[0x382a:0x38aa])
        c.pc=0x400c;c.memory[0xd40b]=100
        for _ in range(30):
            if c.pc==0xea73:break
            c.step()
        self.assertEqual(c.pc,0xea73)

    def test_all_tile_choices_stay_in_star_bank(self):
        c=self.cpu()
        for section in range(32):
            c.memory[0x4e79]=section
            for column in range(16):
                c.memory[0x4e7a]=column
                for row in range(8):
                    c.y=row;self.call(c,0x4009)
                    p=word(c.memory,0x80)
                    self.assertEqual(p,0x2400)
                    self.assertEqual(c.y,row)
                    self.assertTrue(all(v&0xaa==0 for v in self.ram[p:p+32]))
if __name__=='__main__':unittest.main()
