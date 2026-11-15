import unittest,struct
from assets import project,export,validate,rle,load,parse,files,word
from recover import kult
from py65.devices.mpu6502 import MPU
class ExportTests(unittest.TestCase):
    def test_noop(self):
        for game in ('kult','cetas'):self.assertEqual(export(game,{}),project(game)['original'])
    def test_kult_graphics_repack(self):
        p=project('kult');edits={}
        for a in p['assets']:
            if a['id'] in ('char-0','player-0-0','player-0-3','tile-33','enemy-0-0','enemy-31-3','enemy-32-3'):edits[str(a['offset'])]=p['banks']['ram'][a['offset']]^0xff
        edits[str(0xc402)]=0x42
        result=export('kult',{'ram':edits});ram,_,_,_=kult(result)
        for a,v in edits.items():self.assertEqual(ram[int(a)],v)
        self.assertEqual(len(result),len(p['original']))
    def test_cetas_all_pictures_and_sprite(self):
        p=project('cetas');edits={name:{'0':p['banks'][name][0]^0xff} for name in 'ABCD'}
        a=next(a for a in p['assets'] if a['id']=='sprite-5428');edits['game']={str(a['offset']):p['banks']['game'][a['offset']]^0xff}
        result=export('cetas',edits);fs={n.rstrip('.'):b for n,b,_,_ in files(result)}
        for name,start in zip('ABCD',(0x8010,0x2010,0x4010,0x6010)):
            ram,_=load(fs[name]);self.assertEqual(ram[start],edits[name]['0']);self.assertEqual(ram[start+1:start+7680],p['banks'][name][1:])
        ram,_=load(fs['E']);self.assertEqual(ram[a['offset']],edits['game'][str(a['offset'])]);self.assertEqual(fs['AUTO'],p['files']['AUTO']);self.assertEqual(fs['XAUTORUN'],p['files']['XAUTORUN']);self.assertEqual(result[:400],p['original'][:400])
        self.assertEqual(len(result),92176)
    def test_original_loader_accepts_raw_picture(self):
        p=project('cetas');data=struct.pack('<HH',0x8010,0x9e0f)+p['banks']['A'];memory,_=load(p['files']['AUTO']);cpu=MPU(memory=list(memory));cpu.pc=0x105c;pos=0
        for _ in range(200000):
            if cpu.pc==0x11ca:
                if pos==len(data):break
                cpu.a=data[pos];pos+=1;cpu.FlagsNZ(cpu.a);cpu.p&=~1;cpu.pc=(cpu.stPopWord()+1)&65535;continue
            cpu.step()
        else:self.fail('Loader did not consume the file')
        self.assertEqual(bytes(cpu.memory[0x8010:0x9e10]),p['banks']['A'])
    def test_sprite_metadata(self):
        p=project('cetas');ram=p['banks']['game'];a=next(a for a in p['assets'] if a['id']=='sprite-5428');self.assertEqual((a['width'],a['height'],a['offset'],a['flipY']),(36,23,0x542f,True))
        self.assertEqual(ram[0x5429]*ram[0x542a],207)
        p=project('kult');ram=p['banks']['ram']
        for frame in range(4):
            a=next(a for a in p['assets'] if a['id']==f'player-{frame}-0');base=a['offset'];src=ram[base:base+80]
            for shift in (1,2,3):
                expected=b''.join((int.from_bytes(src[y*5:y*5+5],'big')>>(shift*2)).to_bytes(5,'big') for y in range(16));self.assertEqual(expected,ram[base+shift*80:base+(shift+1)*80])
    def test_enemy_coverage_and_runtime_expansion(self):
        p=project('kult');ram=p['banks']['ram']
        self.assertEqual(set(ram[0x4400:0x4a00:4]),set(range(32)))
        enemies=[a for a in p['assets'] if a['category']=='Enemy sprites']
        self.assertEqual(len(enemies),128)
        self.assertEqual(len(p['collections']),33)
        for group in p['collections']:
            for id in group['ids']:
                a=next(a for a in p['assets'] if a['id']==id)
                cpu=MPU(memory=list(ram));cpu.pc=0xf0c4;cpu.a=0;cpu.x=a['offset']&255;cpu.y=a['offset']>>8
                cpu.stPushWord(0x01ff)
                for _ in range(20000):
                    if cpu.pc==0x0200:break
                    cpu.step()
                else:self.fail('Sprite expansion did not return')
                source=ram[a['offset']:a['offset']+32];base=word(ram,0xef31)
                for shift in range(4):
                    expected=b''.join((int.from_bytes(source[y*2:y*2+2]+b'\0','big')>>(shift*2)).to_bytes(3,'big') for y in range(16))
                    self.assertEqual(bytes(cpu.memory[base+shift*48:base+(shift+1)*48]),expected,id)
        p=project('cetas');ram=p['banks']['game']
        self.assertEqual(len(p['collections']),17)
        for object_type,group in enumerate(p['collections'],2):
            expected={f'sprite-{word(ram,0x2d67+(object_type-1)*8+i*2):04x}' for i in range(4)}
            self.assertEqual(set(group['ids']),expected)
    def test_forbid_code_edits(self):
        for game,edits in [('kult',{'ram':{'49152':0}}),('cetas',{'game':{'8192':0}}),('kult',{'ram':{'51200':256}})]:
            with self.assertRaises(ValueError):validate(game,edits)
if __name__=='__main__':unittest.main()
