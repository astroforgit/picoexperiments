"""Exact helper recognition and fixed-copy provenance regression checks."""
import struct,unittest
from py65.devices.mpu6502 import MPU
from recover_common import candidates,indexed_helper_source
from loader_contexts import FIXED_COPIES,apply_fixed_init,load_contexts

class HelperTests(unittest.TestCase):
 def test_nine_byte_wrapper_arguments(self):
  ram=bytearray(65536);core=0x3000;ram[core+2]=0x56;ram[core+79:core+81]=b'\xff\xff'
  wrapper=core-9
  ram[wrapper:core]=b'\x8e'+(core+79).to_bytes(2,'little')+b'\x8c'+(core+80).to_bytes(2,'little')+b'\x4c'+(core+35).to_bytes(2,'little')
  ram[0x4000:0x4007]=b'\xa2\x00\xa0\x50\x20'+wrapper.to_bytes(2,'little')
  loaded=set(range(wrapper,core+90))|set(range(0x4000,0x4007))|{0x5000}
  self.assertIn(0x5000,dict(candidates(ram,loaded,core)))
  for offset in range(9):
   changed=bytearray(ram);changed[wrapper+offset]^=1
   self.assertNotIn(0x5000,dict(candidates(changed,loaded,core)))
 def helper(self):
  ram=bytearray(65536);pc=0x2100;wrapper=0x2000
  ram[pc:pc+12]=bytes.fromhex('0a aa bd 00 25 bc 01 25 aa 4c 00 20');ram[0x2500:0x2504]=bytes.fromhex('00 30 00 40')
  return ram,set(range(pc,pc+12))|set(range(0x2500,0x2504)),pc,wrapper
 def test_constant_index_helper(self):
  r,l,p,w=self.helper();self.assertEqual(indexed_helper_source(r,l,p,0,w),0x3000);self.assertEqual(indexed_helper_source(r,l,p,1,w),0x4000)
 def test_unknown_index_or_unloaded_table_rejected(self):
  r,l,p,w=self.helper();self.assertIsNone(indexed_helper_source(r,l,p,None,w));l.remove(0x2503);self.assertIsNone(indexed_helper_source(r,l,p,1,w))
 def test_changed_helper_body_rejected(self):
  for off in (0,1,2,5,6,8,9,10,11):
   r,l,p,w=self.helper();r[p+off]^=1;self.assertIsNone(indexed_helper_source(r,l,p,0,w))

class FixedCopyTests(unittest.TestCase):
 def fixture(self,spec):
  ram=bytearray((i*29+17)&255 for i in range(65536))
  for a,body in spec['bodies']:ram[a:a+len(body)]=body
  ram[0x2e2:0x2e4]=spec['entry'].to_bytes(2,'little')
  return ram,set(range(65536)),dict(enumerate(range(65536))),bytes(ram)
 def test_cpu_copy_loop_matches_provenance_model(self):
  for spec in FIXED_COPIES:
   ram,loaded,owners,original=self.fixture(spec);cpu=MPU(memory=list(ram));cpu.pc=spec['entry']
   stop={'colony7-input-pages-v1':0x1f52,'runfast-code-copy-v1':0x045a,'rgb-code-copy-v1':0x2023}[spec['kind']]
   for _ in range(50000):
    if cpu.pc==stop:break
    if cpu.pc in (0x1fa1,0x2010):cpu.memory[0x14]=(cpu.memory[0x14]+1)&255
    cpu.step()
   else:self.fail('Copy loop did not terminate')
   proof=apply_fixed_init(ram,loaded,owners,original,4);self.assertEqual(proof['unknown_bytes'],0)
   lo=spec['destination'];hi=lo+spec['length'];self.assertEqual(ram[lo:hi],bytes(cpu.memory[lo:hi]))
   self.assertEqual([owners[a] for a in range(lo,hi)],list(range(spec['source'],spec['source']+spec['length'])))
   for address,value in spec['modified']:self.assertEqual(ram[address],cpu.memory[address]);self.assertNotIn(address,loaded)
 def test_every_copy_body_mutation_rejected(self):
  for spec in FIXED_COPIES:
   for address,body in spec['bodies']:
    for offset in range(len(body)):
     ram,loaded,owners,original=self.fixture(spec);ram[address+offset]^=1
     self.assertIsNone(apply_fixed_init(ram,loaded,owners,bytes(ram),4))
 def test_unknown_and_modified_source_never_gain_provenance(self):
  for spec in FIXED_COPIES:
   ram,loaded,owners,original=self.fixture(spec);source=spec['source'];dest=spec['destination']
   # Pick copied data beyond the required code signature where possible.
   bad=spec['length']-1;loaded.remove(source+bad)
   proof=apply_fixed_init(ram,loaded,owners,original,4)
   self.assertEqual(proof['unknown_bytes'],1);self.assertNotIn(dest+bad,loaded);self.assertNotIn(dest+bad,owners)
 def test_missing_body_byte_rejected(self):
  for spec in FIXED_COPIES:
   ram,loaded,owners,original=self.fixture(spec);loaded.remove(spec['entry']);self.assertIsNone(apply_fixed_init(ram,loaded,owners,original,4))
 def test_changed_source_cannot_keep_original_owner(self):
  for spec in FIXED_COPIES:
   ram,loaded,owners,original=self.fixture(spec);offset=spec['length']-1;ram[spec['source']+offset]^=1
   proof=apply_fixed_init(ram,loaded,owners,original,4)
   self.assertEqual(proof['unknown_bytes'],1);self.assertNotIn(spec['destination']+offset,loaded);self.assertNotIn(spec['destination']+offset,owners)
 def test_wrong_init_vector_rejected(self):
  for spec in FIXED_COPIES:
   ram,loaded,owners,original=self.fixture(spec);ram[0x2e2]^=1;self.assertIsNone(apply_fixed_init(ram,loaded,owners,bytes(ram),4))
 def test_original_and_derived_views_and_later_overlay(self):
  spec=FIXED_COPIES[2];ram,_,_,_=self.fixture(spec)
  def segment(a,data):return struct.pack('<HH',a,a+len(data)-1)+data
  raw=b'\xff\xff'+segment(0x2000,ram[0x2000:0x20d0])+segment(0x2e2,b'\x00\x20')+segment(0xbf02,b'\x55')+segment(0x2e2,b'\x00\x30')
  contexts=[]
  for part,memory,loaded,owners,proofs in load_contexts(raw):contexts.append((part,bytes(memory),set(loaded),dict(owners),proofs))
  self.assertEqual(len(contexts),4);self.assertFalse(contexts[0][4]);self.assertTrue(contexts[1][4]);self.assertEqual(contexts[3][1][0xbf02],0x55)
  self.assertEqual(raw[contexts[3][3][0xbf02]],0x55);self.assertEqual(contexts[1][4],contexts[3][4])

if __name__=='__main__':unittest.main(verbosity=2)
