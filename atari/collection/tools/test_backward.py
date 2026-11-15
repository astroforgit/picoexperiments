#!/usr/bin/env python3
"""Family-specific regression tests; reads curated Zaxxon as a stable fixture."""
import unittest
from pathlib import Path
import recover_backward as rb
class BackwardTests(unittest.TestCase):
 @classmethod
 def setUpClass(cls):
  cls.data=(rb.ROOT/'games/zaxxon/original.xex').read_bytes()
  cls.contexts=[(i,e,k,bytes(m),dict(o)) for i,e,k,m,o in rb.snapshots(cls.data)]
  cls.i,cls.entry,cls.kind,cls.memory,cls.owners=cls.contexts[0]
  cls.core=0x4027;cls.end=0x420b
 def test_full_decoder_validation(self):
  self.assertEqual(rb.validate_core(self.memory,self.core,self.owners),0x7900)
  for offset in range(329):
   mutated=bytearray(self.memory);mutated[self.core+offset]^=1
   self.assertIsNone(rb.validate_core(mutated,self.core,self.owners),f'accepted changed byte {offset}')
 def test_complete_relocated_core_operands(self):
  core=0x6000;table=0x5000;m=bytearray(65536);expected=bytearray(rb.TEMPLATE)
  for i,v in rb.REL.items():expected[i:i+2]=(core+v).to_bytes(2,'little')
  for i,v in rb.TABLE.items():expected[i:i+2]=(table+v).to_bytes(2,'little')
  expected[165]=(table+156)&255;expected[169]=(table+156)>>8
  m[core:core+329]=expected
  self.assertEqual(rb.validate_core(m,core),table)
  m[core+2]^=1
  self.assertIsNone(rb.validate_core(m,core))
 def test_independent_write_recorder_detects_extra_write(self):
  memory=rb.ReferenceMemory([0]*65536,self.core,0x7900,0x7a09)
  memory[0x14]=3;memory[self.core+12]=4;memory[0x799d]=5;memory[0x8000]=6
  self.assertEqual(memory.output,[(0x8000,6)])
 def test_missing_core_provenance(self):
  owners=dict(self.owners);del owners[self.core+328]
  self.assertIsNone(rb.validate_core(self.memory,self.core,owners))
 def test_reachable_call_context(self):
  self.assertIn((0x4017,self.core,self.end),rb.reachable_calls(self.memory,self.owners,self.entry,{self.core:0x7900}))
  self.assertEqual(rb.reachable_calls(self.memory,self.owners,0x1000,{self.core:0x7900}),[])
  m=bytearray(self.memory);m[0x4013]=0xa9
  self.assertEqual(rb.reachable_calls(m,self.owners,self.entry,{self.core:0x7900}),[])
 def test_missing_input_provenance_rejected(self):
  owners=dict(self.owners);del owners[self.end]
  with self.assertRaisesRegex(ValueError,'original-file backed'):rb.replay(self.data,self.memory,owners,self.core,self.end)
  owners=dict(self.owners);del owners[self.end-1]
  with self.assertRaisesRegex(ValueError,'provenance'):rb.replay(self.data,self.memory,owners,self.core,self.end)
 def test_changed_original_input_rejected(self):
  m=bytearray(self.memory);m[self.end]^=1
  with self.assertRaisesRegex(ValueError,'changed from archived'):rb.replay(self.data,m,self.owners,self.core,self.end)
 def test_destination_overwrites_decoder_rejected(self):
  m=bytearray(self.memory);data=bytearray(self.data);header=self.end-(m[self.end] or 256)
  for address,value in ((header-1,(self.core+10)>>8),(header-2,(self.core+10)&255)):
   m[address]=value;data[self.owners[address]]=value
  with self.assertRaisesRegex(ValueError,'overlaps active decoder'):rb.replay(data,m,self.owners,self.core,self.end)
 def test_io_destination_rejected(self):
  m=bytearray(self.memory);data=bytearray(self.data);header=self.end-(m[self.end] or 256)
  for address,value in ((header-1,0xd0),(header-2,1)):
   m[address]=value;data[self.owners[address]]=value
  with self.assertRaisesRegex(ValueError,'Atari I/O'):rb.replay(data,m,self.owners,self.core,self.end)
 def test_io_workspace_and_input_rejected(self):
  m=bytearray(self.memory);expected=bytearray(rb.TEMPLATE);table=0xd000
  for i,v in rb.TABLE.items():expected[i:i+2]=(table+v).to_bytes(2,'little')
  expected[165]=(table+156)&255;expected[169]=(table+156)>>8
  m[self.core:self.core+329]=expected
  self.assertIsNone(rb.validate_core(m,self.core,self.owners))
  m=bytearray(self.memory);m[0xd001]=1;o=dict(self.owners);o[0xd001]=0
  with self.assertRaisesRegex(ValueError,'Atari I/O'):rb.replay(self.data,m,o,self.core,0xd001)
 def test_fixed_argument_wrapper_and_register_arithmetic(self):
  m=bytearray(self.memory);o=dict(self.owners);pc=0x1000
  block=bytes.fromhex('a2 00 ca a0 42 20 27 40 60')
  m[pc:pc+len(block)]=block;o.update({pc+i:i for i in range(len(block))});o[0x42ff]=0
  self.assertIn((pc+5,self.core,0x42ff),rb.reachable_calls(m,o,pc,{self.core:0x7900}))
  m[pc:pc+4]=bytes.fromhex('20 23 40 60');m[self.core-4:self.core]=bytes.fromhex('a2 0b a0 42')
  self.assertIn((pc,self.core,self.end),rb.reachable_calls(m,o,pc,{self.core:0x7900}))
 def test_independent_known_image_and_literals(self):
  stage,image,_=rb.prove(self.data,self.memory,self.owners,self.core,self.end)
  self.assertEqual(stage['sha256'],'e15907339fded2a4eaafca1853e4547ca5787ed83fb5f537814ac0326cc7de9c')
  self.assertEqual(stage['spans'],[[0x7a09,0x8000]])
  self.assertEqual(len(stage['literal_patches']),61)
  self.assertEqual(stage['backreference_reads'],1466)
  self.assertEqual(len(image),1527)
 def test_curated_preserved(self):
  result=rb.process(('zaxxon',True,'/nonexistent/mads'))
  self.assertEqual(result['status'],'curated_reconstruction_preserved')
 def test_foreign_audit_rejected(self):
  with self.assertRaises((ValueError,FileNotFoundError)):rb.audit(rb.ROOT/'games/zaxxon')
class LoaderPrefixTests(unittest.TestCase):
 def test_lowered_stack_pointer_collision(self):
  cpu=rb.MPU();cpu.pc=0x4000;cpu.memory[cpu.pc]=0x48;cpu.sp=0xa1
  with self.assertRaisesRegex(ValueError,'live decoder stack'):rb.check_stack_workspace(cpu,0x100,0x1a2,[])
  with self.assertRaisesRegex(ValueError,'prior caller'):rb.check_stack_workspace(cpu,0x100,0x1a2,[0x1a1,0x1a2])
  cpu.sp=0xff
  with self.assertRaisesRegex(ValueError,'prior caller frame'):rb.check_stack_workspace(cpu,0x100,0x1a2,[0x1fe,0x1ff])
 def test_unknown_entry_stack_is_rejected(self):
  with self.assertRaisesRegex(ValueError,'proven TXS'):rb.stack_setup(0x100,0x1a2,None,0xfd)
  context={'kind':'prefix_TXS_FF_then_JSR','entry_sp':0xfd,'reset_value':255,'prior_caller_live_bytes':[510,511]}
  with self.assertRaisesRegex(ValueError,'prior caller'):rb.stack_setup(0x100,0x1ff,context,0xfd)
 def test_unknown_init_invalidates_previous_file_ownership(self):
  import struct
  def seg(a,b):return struct.pack('<HH',a,a+len(b)-1)+b
  raw=b'\xff\xff'+seg(0x3000,b'\x42')+seg(0x8000,bytes.fromhex('20 00 81 60'))+seg(0x8100,bytes.fromhex('a9 99 8d 00 30 60'))+seg(0x2e2,bytes.fromhex('00 80'))+seg(0x4000,bytes.fromhex('ad 00 30 8d 00 50 60'))+seg(0x2e2,bytes.fromhex('00 40'))
  for context in rb.relocated_snapshots(raw):self.assertNotIn(0x5000,context[4])
 def test_exact_helper_models_stack_return_writes(self):
  memory=bytearray(65536);owners={}
  for a,b in [(0x4000,bytes.fromhex('a2 ff 9a a2 00 20 00 41 ad fe 01 8d 00 50 60')),(0x4100,bytes.fromhex('8e 2f 02 a5 14 c5 14 f0 fc 60')),(0x1fe,b'\x42')]:
   memory[a:a+len(b)]=b;owners.update({a+i:a+i for i in range(len(b))})
  output,origins,writes,calls,proof=rb.loader_prefix(bytes(memory),memory,owners,0x4000)
  self.assertEqual(output[0x5000],7);self.assertNotIn(0x5000,origins);self.assertNotIn(0x1fe,origins)
 def test_rom_memory_arithmetic_stops(self):
  memory=bytearray(65536);block=bytes.fromhex('ee 00 c0 60');memory[0x4000:0x4004]=block;memory[0xc000]=0x42;owners={a:a for a in (0x4000,0x4001,0x4002,0x4003,0xc000)}
  output,origins,writes,calls,proof=rb.loader_prefix(bytes(memory),memory,owners,0x4000)
  self.assertEqual(output[0xc000],0x42);self.assertIn('hardware/ROM',proof['stop_reason']);self.assertEqual(writes,[])
 def test_stack_reset_does_not_prove_return_to_loader(self):
  memory=bytearray(65536);block=bytes.fromhex('a2 ff 9a 60');memory[0x4000:0x4004]=block;owners={a:a for a in range(0x4000,0x4004)}
  proof=rb.loader_prefix(bytes(memory),memory,owners,0x4000)[4]
  self.assertNotEqual(proof['stop_reason'],'modeled RTS return');self.assertFalse(proof['original_caller_return_frame_preserved'])
 def test_self_overlapping_dma_helper_not_summarized(self):
  memory=bytearray(65536);owners={}
  for a,b in [(0x4000,bytes.fromhex('a2 00 20 2a 02 60')),(0x22a,bytes.fromhex('8e 2f 02 a5 14 c5 14 f0 fc 60'))]:
   memory[a:a+len(b)]=b;owners.update({a+i:a+i for i in range(len(b))})
  proof=rb.loader_prefix(bytes(memory),memory,owners,0x4000)[4]
  self.assertEqual(proof['exact_hardware_wait_summaries'],[]);self.assertEqual(proof['stop_pc'],0x4002)
 def test_mule_reset_proof_and_relocated_core(self):
  data=(rb.ROOT/'games/m-u-l-e/original.xex').read_bytes()
  context=next(s for s in rb.relocated_snapshots(data) if s[1]==0xba95)
  self.assertEqual(rb.validate_core(context[3],0x4b7,context[4]),0x100)
  proof=context[5]['loader_prefixes'][-1]['observed_call_stack_contexts'][str(0xbac2)]
  self.assertEqual(proof,{'kind':'prefix_TXS_FF_then_JSR','reset_pc':0xba97,'reset_value':255,'call':0xbac2,'entry_sp':253,'prior_caller_live_bytes':[510,511]})
  self.assertTrue(context[5]['loader_prefixes'][-1]['independent_replay'])
 def test_missing_mule_copy_input_stops_before_core(self):
  data=(rb.ROOT/'games/m-u-l-e/original.xex').read_bytes()
  context=next((i,e,k,bytes(m),dict(o)) for i,e,k,m,o in rb.snapshots(data) if e==0xba95)
  owners=context[4];del owners[0x9e5b]
  memory,origins,writes,calls,proof=rb.loader_prefix(data,context[3],owners,context[1])
  self.assertEqual(calls,[]);self.assertIsNone(rb.validate_core(memory,0x4b7,origins))
 def test_representative_previous_reports_still_audit(self):
  for slug in ('jungle-hunt','escape-from-earth'):
   self.assertEqual(rb.audit('games/'+slug)['status'],'family_audit_passed')
if __name__=='__main__':unittest.main()

