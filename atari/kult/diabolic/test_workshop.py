import json,re,unittest
from pathlib import Path
from py65.devices.mpu6502 import MPU
from build import create_runtime,package,kult,ROOT
from workshop import catalog,default_project,validate,pack

class WorkshopTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.p,cls.ram,_,_=create_runtime()
        listing=(ROOT/'space.lst').read_text()
        cls.shots=int(re.search(r'^\s*\d+\s+([0-9A-F]{4})\s+Shots\s*$',listing,re.M)[1],16)
    def call(self,c,pc):
        c.pc=pc;c.stPushWord(0x1ff)
        for _ in range(100000):
            if c.pc==0x200:return
            c.step()
        self.fail('Routine did not return')
    def test_catalog_and_animation(self):
        lib=catalog();self.assertEqual(len(lib['ships']),5);self.assertEqual(len(lib['enemies']),36)
        for a in lib['ships']+lib['enemies']:
            self.assertEqual(len(a['frames']),4)
            for frame in a['frames']:
                self.assertEqual(len(frame),a['width']*a['height']);self.assertTrue(set(frame)<={0,1})
            if a.get('source')=='image-model':self.assertGreater(len({tuple(f) for f in a['frames']}),1)
    def test_custom_native_export_roundtrip(self):
        config=default_project();config['ship']='ship-2';config['slots']=['enemy-'+str(i%4) for i in range(32)]
        config['motions'][0]=[-3,7,2,-1,16,-32,9,12];config['waves'][0][0]=[3,0,7,4]
        config['firing']={'mode':1,'interval':18,'speed':3}
        p,ram,_,_=create_runtime(config);out=package(p,ram);loaded=kult(out)[0]
        self.assertEqual(loaded[0x4400:0x4404],bytes([3,0,7,4]))
        self.assertEqual(loaded[0x7310:0x7318],bytes(n&255 for n in config['motions'][0]))
        self.assertEqual(loaded[0x2d00:0x2d03],bytes([1,18,3]))
        enemy=next(a for a in catalog()['enemies'] if a['id']=='enemy-3')
        self.assertEqual(loaded[0x4f80+3*128:0x4fa0+3*128],pack(enemy['frames'][0],16,16))
    def test_reject_invalid_projects(self):
        for mutate in (lambda p:p['slots'].__setitem__(0,'no-such-design'),lambda p:p['waves'][0][0].__setitem__(0,32),lambda p:p['motions'][0].__setitem__(0,128),lambda p:p['firing'].__setitem__('interval',0)):
            p=default_project();mutate(p)
            with self.assertRaises(ValueError):validate(p)
    def test_enemy_fires_aimed_hardware_shot(self):
        c=MPU(memory=list(self.ram));c.memory[0x2d00:0x2d05]=[2,12,2,11,0]
        c.memory[0x74e1]=0x10;c.memory[0x7463]=100;c.memory[0x746b]=50
        c.memory[0x7444]=c.memory[0x7446]=c.memory[0xfd04]=0
        c.memory[0xe957]=12;c.memory[0xe958]=80
        self.call(c,self.shots)
        self.assertEqual(c.memory[0x2d13],1)
        self.assertEqual((c.memory[0x2d17],c.memory[0x2d1b],c.memory[0x2d1f]),(98,59,1))
        self.assertEqual(c.memory[0xd007],162)
        self.assertEqual([c.memory[0x3300+y]&192 for y in range(99,103)],[192]*4)
        self.assertEqual(c.memory[0x3300+103]&192,0)
    def test_bullets_hit_and_respect_invulnerability(self):
        for immune,expected in ((0,3),(20,0)):
            c=MPU(memory=list(self.ram));c.memory[0x2d10]=1;c.memory[0x2d14]=19;c.memory[0x2d18]=60;c.memory[0x2d1c]=0
            c.memory[0xe957]=12;c.memory[0xe958]=56;c.memory[0xf0bf]=immune;c.memory[0xf398]=0
            self.call(c,self.shots);self.assertEqual(c.memory[0xf398],expected);self.assertEqual(c.memory[0x2d10],0)
    def test_aggressive_balance(self):
        self.assertEqual(default_project()["ship"],"ship-2")
        self.assertEqual(self.ram[0xebb1:0xebb3],b"\xea\xea")
        self.assertEqual(self.ram[0xfc1b],96)
        for i in range(32):
            self.assertLessEqual(sum(bool(n) for n in self.ram[0x4a00+i*8:0x4a08+i*8]),2)
        self.assertEqual(self.ram[0x2d00:0x2d03],bytes([2,18,3]))
    def test_equal_star_sizes(self):
        layout=json.loads((ROOT/'star-layout.json').read_text())
        self.assertEqual({s['height'] for s in layout},{2})
        for star in layout:
            self.assertEqual(self.ram[0x2800+star['lane']*256+star['y']:0x2802+star['lane']*256+star['y']],b'\x08\x08')
if __name__=='__main__':unittest.main()
