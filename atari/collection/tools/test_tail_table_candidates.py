"""Bounded pointer-table discovery; no relaxation of replay guards."""
import unittest
from recover_common import tail_table_sources

class TailTableTests(unittest.TestCase):
 def fixture(self,conditional=False):
  ram=bytearray(65536);call=0x2409;table=0x2500
  head=bytes.fromhex('8a 48 bd 00 25 bc 01 25 aa 20 00 20')
  tail=bytes.fromhex('68 d0 05 48 20 00 30 68 aa e8 e8 e0 04 90 e5') if conditional else bytes.fromhex('68 aa e8 e8 e0 04 90 ec')
  ram[call-9:call+3+len(tail)]=head+tail;ram[table:table+4]=bytes.fromhex('00 30 00 40')
  return ram,set(range(call-9,call+3+len(tail)))|set(range(table,table+4)),call
 def test_after_wrapper_table(self):
  r,l,c=self.fixture();self.assertEqual(tail_table_sources(r,l,c),[0x3000,0x4000])
 def test_conditional_first_entry(self):
  r,l,c=self.fixture(True);self.assertEqual(tail_table_sources(r,l,c),[0x3000,0x4000])
 def test_wrong_loop_branch(self):
  r,l,c=self.fixture();r[c+10]=0xed;self.assertEqual(tail_table_sources(r,l,c),[])
 def test_odd_or_zero_bound(self):
  for n in (0,3,130):
   r,l,c=self.fixture();r[c+8]=n;self.assertEqual(tail_table_sources(r,l,c),[])
 def test_missing_table_byte(self):
  r,l,c=self.fixture();l.remove(0x2503);self.assertEqual(tail_table_sources(r,l,c),[])
 def test_missing_instruction_byte(self):
  r,l,c=self.fixture();l.remove(c+10);self.assertEqual(tail_table_sources(r,l,c),[])
 def test_mismatched_high_table(self):
  r,l,c=self.fixture();r[c-3]=2;self.assertEqual(tail_table_sources(r,l,c),[])
 def test_missing_saved_index(self):
  r,l,c=self.fixture();r[c-9]=0xea;self.assertEqual(tail_table_sources(r,l,c),[])
 def test_conditional_branch_and_restore_required(self):
  for offset in (4,5,6,10,11,12,13,14,16,17):
   r,l,c=self.fixture(True);r[c+offset]^=1;self.assertEqual(tail_table_sources(r,l,c),[])

if __name__=='__main__':unittest.main(verbosity=2)
