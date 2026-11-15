import hashlib,json,unittest
from pathlib import Path
from build import ROOT,build,pack,title,witch
from assets import word,validate
from recover import load
from py65.devices.mpu6502 import MPU

class BabajagaTests(unittest.TestCase):
 @classmethod
 def setUpClass(cls):cls.original,cls.banks,cls.files=build()
 def call(self,ram,address,setup):
  c=MPU(memory=list(ram));c.pc=address;c.stPushWord(0x2fe);setup(c)
  for _ in range(10000):
   if c.pc==0x2ff:return c
   if c.pc in (0x2b81,0x2e1b):
    if c.pc==0x2e1b:c.a=0;c.FlagsNZ(0)
    c.pc=(c.stPopWord()+1)&65535;continue
   c.step()
  self.fail('CPU routine did not return')
 def test_only_pixel_bytes_change_in_game(self):
  old=self.original['banks']['game'];new=self.banks['game'];allowed=set()
  for a in self.original['assets']:
   if a['category']=='Sprites' and (a['address']<0x5da9 or a['address'] in {word(old,0x2d67+40+i*2) for i in range(4)}):allowed.update(range(a['offset'],a['offset']+a['width']*a['height']//4))
  changes={i for i,(a,b) in enumerate(zip(old,new)) if a!=b}
  self.assertTrue(changes);self.assertTrue(changes<=allowed)
  for n in ('AUTO','XAUTORUN','A','B','C'):self.assertEqual(self.files[n],self.original['files'][n])
 def test_all_player_selections(self):
  old=self.original['banks']['game'];new=self.banks['game'];selected=set()
  for x in range(4):
   for tick in range(32):
    for hurt in (0,1):
     def setup(c):c.x=0;c.memory[0xc00]=1;c.memory[0xc20]=x;c.memory[0xc60]=tick;c.memory[0xc80]=hurt
     a=self.call(old,0x2c76,setup);b=self.call(new,0x2c76,setup);pa=word(a.memory,0xa4);pb=word(b.memory,0xa4)
     self.assertEqual(pa,pb);self.assertEqual(old[pa:pa+7],new[pb:pb+7]);self.assertNotEqual(old[pa+7:pa+7+old[pa+1]*old[pa+2]],new[pb+7:pb+7+new[pb+1]*new[pb+2]]);selected.add(pa)
  self.assertEqual(len(selected),9)
  self.assertNotEqual(old[0x5c69:0x5da9],new[0x5c69:0x5da9])
 def test_movement_and_firing_unchanged(self):
  for direction in range(16):
   def setup(c):
    c.x=0;c.memory[0xc00]=1;c.memory[0xc20]=50;c.memory[0xc40]=88;c.memory[0xc01]=0;c.memory[0x9a]=1
    for i in range(4):c.memory[0x9b+i]=(direction>>i)&1
   a=self.call(self.original['banks']['game'],0x24fb,setup);b=self.call(self.banks['game'],0x24fb,setup)
   self.assertEqual(a.memory[0xc00:0xe00],b.memory[0xc00:0xe00]);self.assertEqual(b.memory[0xc01],6)
 def test_original_loader_reads_new_pictures(self):
  for name,start,size in [('D',0x6010,7680),('F',0xa010,6480)]:
   payload=self.files[name];ram,_=load(self.original['files']['AUTO']);c=MPU(memory=list(ram));c.pc=0x105c;pos=0
   for _ in range(250000):
    if c.pc==0x11ca:
     if pos==len(payload):break
     c.a=payload[pos];pos+=1;c.FlagsNZ(c.a);c.p&=~1;c.pc=(c.stPopWord()+1)&65535;continue
    c.step()
   else:self.fail('Resource loader timeout')
   self.assertEqual(bytes(c.memory[start:start+size]),bytes(self.banks[name]))
 def test_editor_project(self):
  doc=json.loads((ROOT/'babajaga-editor.json').read_text());banks=validate('cetas',doc['edits']);self.assertEqual(bytes(banks['game']),bytes(self.banks['game']));self.assertEqual(bytes(banks['D']),bytes(self.banks['D']))
if __name__=='__main__':unittest.main(verbosity=2)
