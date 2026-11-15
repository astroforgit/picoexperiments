import unittest,tempfile,struct,json,shutil,subprocess
from unittest.mock import patch
from pathlib import Path
import recover_relocated_rom as rr

def seg(a,b):return struct.pack('<HH',a,a+len(b)-1)+b

def fixture(destination=0xc000,unknown=False,mutation=False):
 base=0x233a;table=b'\x00'+b''.join(struct.pack('<HH',a,a+4) for a in (destination,0xd800,0xe400,0xf000));helper=bytearray(table+rr.body(base))
 if mutation:helper[17]^=1
 raw=b'\xff\xff'+seg(base,helper)
 for i in range(4):
  raw+=seg(0x2400,bytes(range(4)))
  if unknown and i==0:raw+=seg(0x2e2,struct.pack('<H',0x8000))
  raw+=seg(0x2e2,struct.pack('<H',base+17))
 return raw

class RelocationTests(unittest.TestCase):
 def discover(self,raw):
  with tempfile.TemporaryDirectory() as t:
   g=Path(t);(g/'original.xex').write_bytes(raw);return rr.discover(g)
 def test_four_exact_copies(self):
  d,images,_=self.discover(fixture());self.assertEqual(len(d['stages']),4);self.assertFalse(d['errors']);self.assertTrue(all(v==bytes(range(4)) for v in images.values()))
 def test_full_helper_mutations_rejected(self):
  helper=b'\0'*17+rr.body(0x233a)
  for i in range(17,95):
   v=bytearray(helper);v[i]^=1;self.assertFalse(rr.identify(v,0x233a),i)
 def test_io_destination_rejected(self):
  d,_,_=self.discover(fixture(0xd000));self.assertFalse(d['stages']);self.assertTrue(d['errors'])
 def test_unknown_init_invalidates_state(self):
  d,_,_=self.discover(fixture(unknown=True));self.assertFalse(d['stages'])
 def test_unknown_init_drops_old_input_ownership(self):
  raw=fixture();base=0x233a;table=b'\0'+b''.join(struct.pack('<HH',a,a+4) for a in (0xc000,0xd800,0xe400,0xf000));raw=seg(0x2400,b'abcd')+seg(0x2e2,b'\x00\x80')+seg(base,table+rr.body(base))+seg(0x2e2,struct.pack('<H',base+17))
  d,_,_=self.discover(b'\xff\xff'+raw);self.assertFalse(d['stages']);self.assertTrue(d['errors'])
 def test_relocated_helper_full_body(self):
  self.assertTrue(rr.identify(b'\0'*17+rr.body(0x3800),0x3800));self.assertFalse(rr.identify(b'\0'*17+rr.body(0x233a),0x3800))
 def test_helper_must_fit_unbanked_ordinary_ram(self):
  for base in (0x00b0,0x0100,0x01ff,0x3fa2,0x4000,0x7fff,0x9fa2,0xa000,0xd300):
   helper=b'\0'*17+rr.body(base)
   self.assertFalse(rr.identify(helper,base))
   with self.assertRaisesRegex(ValueError,'protected or banked'):rr.replay(base,helper,b'abcd',0xc000,0xc004,0)
  for base in (0x0200,0x233a,0x3fa1,0x8000,0x9fa1):self.assertTrue(rr.identify(b'\0'*17+rr.body(base),base))
 def test_scratch_alias_cannot_produce_phantom_later_copies(self):
  base=0x00b0;table=b'\0'+b''.join(struct.pack('<HH',a,a+4) for a in (0xc000,0xd800,0xe400,0xf000));raw=b'\xff\xff'+seg(base,table+rr.body(base))
  for _ in range(4):raw+=seg(0x2400,b'abcd')+seg(0x2e2,struct.pack('<H',base+17))
  d,_,_=self.discover(raw);self.assertFalse(d['stages'])
 def test_input_cannot_cross_unknown_xe_bank_window(self):
  base=0x233a;n=0x1c01;helper=b'\0'+struct.pack('<HH',0xd800,0xd800+n)+b'\0'*12+rr.body(base)
  raw=b'\xff\xff'+seg(base,helper)+seg(0x2400,b'A'*n)+seg(0x2e2,struct.pack('<H',base+17))
  d,_,_=self.discover(raw);self.assertFalse(d['stages']);self.assertIn('XE bank',d['errors'][0]['error'])
 @unittest.skipUnless(shutil.which('mads'),'MADS required')
 def test_source_only_build_and_audit(self):
  with tempfile.TemporaryDirectory() as t:
   root=Path(t);g=root/'games/test';(g/'decompiled').mkdir(parents=True);(g/'original.xex').write_bytes(fixture());(root/'tools').mkdir();shutil.copy2(rr.ROOT/'tools/rebuild_stages.py',root/'tools/rebuild_stages.py')
   result=rr.publish(g);self.assertEqual(result['status'],'relocated_runtime_mads_verified');out=g/'decompiled/relocated-runtime'
   for f in out.glob('*.bin'):f.unlink()
   (out/'rebuilt-packed.xex').unlink();p=subprocess.run(['sh','build.sh'],cwd=out,capture_output=True,text=True);self.assertEqual(p.returncode,0,p.stdout+p.stderr);self.assertEqual((out/'rebuilt-packed.xex').read_bytes(),fixture());self.assertEqual(rr.audit(g)['images'],4)
 @unittest.skipUnless(shutil.which('mads'),'MADS required')
 def test_original_change_during_preparation_prevents_publication(self):
  with tempfile.TemporaryDirectory() as t:
   game=Path(t);(game/'decompiled').mkdir();(game/'original.xex').write_bytes(fixture());real=rr.reconstruct
   def change_original(*args):
    packed=real(*args);(game/'original.xex').write_bytes(fixture()+b'changed');return packed
   with patch.object(rr,'reconstruct',side_effect=change_original):
    with self.assertRaisesRegex(ValueError,'Project changed'):rr.publish(game)
   self.assertFalse((game/'decompiled/relocated-runtime').exists())
if __name__=='__main__':unittest.main()
