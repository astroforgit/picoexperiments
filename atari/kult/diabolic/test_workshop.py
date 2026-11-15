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
        lib=catalog();self.assertEqual(len(lib['ships']),5);self.assertEqual(len(lib['enemies']),99)
        for a in lib['ships']+lib['enemies']:
            self.assertEqual(len(a['frames']),4)
            for frame in a['frames']:
                self.assertEqual(len(frame),a['width']*a['height']);self.assertTrue(set(frame)<={0,1})
            if a.get('source') in ('image-model','enemys.webp','original-redesign'):self.assertGreater(len({tuple(f) for f in a['frames']}),1)
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
    def test_imported_enemies_in_native_waves(self):
        config=default_project();config['slots']=[f'sheet-{i:02}' for i in range(31)]+['original-31']
        _,ram,_,_=create_runtime(config)
        imported={a['id']:a for a in catalog()['enemies'] if a.get('source')=='enemys.webp'}
        self.assertEqual(len(imported),31)
        used={config['slots'][wave[0]] for sector,kinds in zip(config['waves'],config['encounters']) for wave,kind in zip(sector,kinds) if kind==0}
        self.assertTrue(set(imported)<=used)
        for slot,id in enumerate(config['slots'][:31]):
            for f,frame in enumerate(imported[id]['frames']):
                start=0x4f80+slot*128+f*32
                self.assertEqual(ram[start:start+32],pack(frame,16,16))
    def test_redesigns_replace_all_slots_and_special_encounters(self):
        lib={a['id']:a for a in catalog()['enemies']}
        self.assertEqual(default_project()['slots'],[f'redesign-{i}' for i in range(32)])
        for i in range(32):
            a=lib[f'redesign-{i}'];self.assertEqual(a['original'],f'original-{i}')
            self.assertNotEqual(a['frames'],lib[a['original']]['frames'])
            for f,frame in enumerate(a['frames']):
                start=0x4f80+i*128+f*32
                self.assertEqual(self.ram[start:start+32],pack(frame,16,16))
        self.assertEqual(self.ram[0x2f00:0x2f80],b''.join(pack(f,16,16) for f in lib['redesign-14']['frames']))
        head=lib['redesign-19']['frames'][0]
        for tile in range(8):
            frame=[head[((tile//4*16+y)//2)*16+(tile%4*16+x)//4] for y in range(16) for x in range(16)]
            self.assertEqual(self.ram[0x2e00+tile*32:0x2e20+tile*32],pack(frame,16,16))

    def test_enemy_blit_and_restore_clip_bottom_without_corrupting_code(self):
        for base in (0x8000,0xa000):
            for y in range(112,128):
                c=MPU(memory=list(self.ram))
                for row in range(128):
                    address=base+row*64
                    c.memory[0x6000+row*3:0x6003+row*3]=[address&255,address>>8,0]
                c.memory[0x7e:0x80]=[0,0x60]
                c.memory[0x748a:0x748c]=[0,0x78]
                c.memory[0xec5f]=c.memory[0xfd]=c.memory[0x7439]=0
                c.memory[0x7a00:0x7ac0]=[255]*192
                c.memory[base:base+8192]=[0x55]*8192
                protected=c.memory[base+8192:base+8192+1024].copy()
                c.a=0;c.x=40;c.y=y
                self.call(c,0xedbf)
                self.assertEqual(c.memory[base+8192:base+8192+1024],protected,(base,y,'draw'))
                self.assertNotEqual(c.memory[base:base+8192],[0x55]*8192)
                c.memory[0xeca6]=0;c.y=0
                self.call(c,0xed58)
                self.assertEqual(c.memory[base+8192:base+8192+1024],protected,(base,y,'restore'))
                self.assertEqual(c.memory[base:base+8192],[0x55]*8192,(base,y))

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
    def test_enemy_reuses_mirrored_player_bullet(self):
        c=MPU(memory=list(self.ram));c.memory[0x2d00:0x2d05]=[2,12,2,11,0]
        c.memory[0xfb8b]=17;c.memory[0x74e1]=16;c.memory[0x7463]=100;c.memory[0x746b]=50
        c.memory[0x7444]=c.memory[0x7446]=c.memory[0xfd04]=0
        c.memory[0xe957]=12;c.memory[0xe958]=80
        self.call(c,self.shots)
        self.assertEqual(c.memory[0x2d10],1);self.assertEqual(c.memory[0x2d50],1)
        self.assertEqual(c.memory[0xd003],162)
        self.assertEqual(c.memory[0x3700+99:0x3700+107],c.memory[0x2f80:0x2f88])
        expected=[int(f'{b:08b}'[::-1],2) for b in c.memory[0x7278:0x7280]]
        self.assertEqual(c.memory[0x2f80:0x2f88],expected)
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
