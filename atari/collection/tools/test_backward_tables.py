#!/usr/bin/env python3
"""Negative guards and known real-input checks for Fiji-family recovery."""
import unittest, tempfile, json, os, shutil, subprocess
from pathlib import Path
from unittest.mock import patch
from types import SimpleNamespace
from recover_backward_tables import (ROOT,TEMPLATE,SELF_WORDS,TABLE_WORDS,
    GuardMemory,identify,unpack,context,parse,word,independent_replay,recover_game,audit,prepare_context,pointer_loop_contexts)
from py65.devices.mpu6502 import MPU


def fiji_context():
    raw=(ROOT/'games/fiji-130-xe/original.xex').read_bytes()
    parts,_=parse(raw);ram=bytearray(65536);owners={}
    for p in parts[:6]:
        if p['kind']!='segment':continue
        start=p['address'];ram[start:start+len(p['data'])]=p['data']
        owners.update((start+i,p['offset']+4+i) for i in range(len(p['data'])))
    return ram,owners,raw,0x7e04


class BackwardTablesTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):cls.ram,cls.owners,cls.raw,cls.core=fiji_context()

    def test_known_real_output_and_uninitialized_zp_independence(self):
        a=unpack(self.ram,self.owners,self.raw,self.core,0)
        b=unpack(self.ram,self.owners,self.raw,self.core,255)
        self.assertEqual(a[1],[[0x8200,0x8aa8]])
        self.assertEqual(a[1:4],b[1:4])
        self.assertEqual(a[0][0x8200:0x8aa8],b[0][0x8200:0x8aa8])
        import hashlib
        self.assertEqual(hashlib.sha256(a[0][0x8200:0x8aa8]).hexdigest(),
            '7ec0e48a8a2e747739e370d2b8ccbdb0b945341781c99cdbe6a7d2cde0c1fb2a')

    def test_each_fixed_decoder_byte_is_checked(self):
        # Pointer-record address is an allowed parameter; all other isolated
        # single-byte changes must violate a fixed byte or linked references.
        for off in range(len(TEMPLATE)):
            if off in (10,11):continue
            ram=bytearray(self.ram);ram[self.core+off]^=1
            with self.subTest(offset=off),self.assertRaises(ValueError):identify(ram,self.core)

    def test_unloaded_decoder_rejected(self):
        owners=dict(self.owners);del owners[self.core+100]
        with self.assertRaisesRegex(ValueError,'fully loaded'):unpack(self.ram,owners,self.raw,self.core)

    def test_unloaded_pointer_record_rejected(self):
        owners=dict(self.owners);del owners[0x7e00]
        with self.assertRaisesRegex(ValueError,'provenance'):unpack(self.ram,owners,self.raw,self.core)

    def test_unloaded_compressed_input_rejected(self):
        owners=dict(self.owners);del owners[0x8397]
        with self.assertRaisesRegex(ValueError,'provenance'):unpack(self.ram,owners,self.raw,self.core)

    def test_changed_original_input_rejected(self):
        ram=bytearray(self.ram);ram[0x8397]^=1
        with self.assertRaisesRegex(ValueError,'provenance'):unpack(ram,self.owners,self.raw,self.core)

    def test_unknown_prior_call_cannot_supply_context(self):
        ram=bytearray(self.ram);ram[0x7d43:0x7d45]=b'\x00\x60'
        with self.assertRaisesRegex(ValueError,'supported unmodified context'):
            context(ram,self.owners,0x7d42,self.core)

    def prefix_fixture(self,hexbytes):
        ram=bytearray(self.ram);owners=dict(self.owners);start=0x7000
        data=bytes.fromhex(hexbytes)+b'\x20'+self.core.to_bytes(2,'little')+b'\x60'
        ram[start:start+len(data)]=data
        owners.update((start+i,len(self.raw)+i) for i in range(len(data)))
        return ram,owners,start,self.raw+data

    def test_display_clock_prefix_preserves_guarded_output(self):
        ram,owners,start,raw=self.prefix_fixture('a9008d2f028d00d4a514c514f0fc')
        call=context(ram,owners,start,self.core)
        self.assertEqual(call['context_kind'],'display_clock_prefix_v1')
        self.assertEqual(len(call['display_writes']),2)
        self.assertEqual(len(call['clock_waits']),1)
        prepared,origins=prepare_context(ram,owners,call,self.core)
        image,spans,_,_,_=unpack(prepared,origins,raw,self.core)
        self.assertEqual(spans,[[0x8200,0x8aa8]])
        self.assertNotIn(0x14,origins)
        self.assertEqual(image[0x8200:0x8aa8],unpack(self.ram,self.owners,self.raw,self.core)[0][0x8200:0x8aa8])

    def test_display_prefix_rejects_portb_unknown_value_and_changed_wait(self):
        for data in ('a9ff8d01d3','a514c514f0fd','a514c514f0fc8d2f02','a9018d00d4'):
            ram,owners,start,_=self.prefix_fixture(data)
            with self.subTest(prefix=data),self.assertRaises(ValueError):context(ram,owners,start,self.core)

    def test_display_prefix_requires_all_instruction_bytes(self):
        ram,owners,start,_=self.prefix_fixture('a9008d2f02a514c514f0fc')
        del owners[start+8]
        with self.assertRaises(ValueError):context(ram,owners,start,self.core)

    def test_display_write_removes_old_file_provenance(self):
        ram,owners,start,_=self.prefix_fixture('a9008d2f02')
        ram[0x22f]=0x22;owners[0x22f]=123
        prepared,origins=prepare_context(ram,owners,context(ram,owners,start,self.core),self.core)
        self.assertEqual(prepared[0x22f],0)
        self.assertNotIn(0x22f,origins)

    def test_known_decrement_can_clear_keyboard_latch(self):
        ram,owners,start,_=self.prefix_fixture('a2008e2f02a514c514f0fcca8efc02')
        call=context(ram,owners,start,self.core)
        self.assertEqual(call['display_writes'][-1]['value'],255)

    def pointer_fixture(self):
        raw=(ROOT/'games/robbo-sws-magnetic/original.xex').read_bytes()
        parts,_=parse(raw);ram=bytearray(65536);owners={}
        for p in parts:
            if p['kind']!='segment':continue
            a=p['address'];data=p['data'];ram[a:a+len(data)]=data
            owners.update((a+i,p['offset']+4+i) for i in range(len(data)))
            if a==0x2e2 and data==b'\x00\x43':break
        return ram,owners,raw,0x4300,0x4404

    def test_pointer_loop_rejects_unbounded_or_changed_control_flow(self):
        ram,owners,raw,entry,core=self.pointer_fixture()
        calls=pointer_loop_contexts(ram,owners,entry,core)
        self.assertEqual(len(calls),2)
        for offset,value in ((1,1),(15,0xf3),(19,0),(24,7),(24,0),(26,0xe8)):
            mutated=bytearray(ram);mutated[entry+offset]=value
            with self.subTest(offset=offset),self.assertRaises(ValueError):pointer_loop_contexts(mutated,owners,entry,core)
        del owners[calls[1]['pointer_copy']['source']]
        with self.assertRaises(ValueError):pointer_loop_contexts(ram,owners,entry,core)

    def test_pointer_copy_keeps_original_file_provenance(self):
        ram,owners,raw,entry,core=self.pointer_fixture()
        call=pointer_loop_contexts(ram,owners,entry,core)[0]
        prepared,origins=prepare_context(ram,owners,call,core)
        src,dst=call['pointer_copy']['source'],call['pointer_copy']['destination']
        self.assertEqual(prepared[dst:dst+4],ram[src:src+4])
        self.assertEqual([origins[dst+i] for i in range(4)],[owners[src+i] for i in range(4)])
        del owners[src]
        with self.assertRaises(ValueError):prepare_context(ram,owners,call,core)

    def test_whole_caller_two_record_execution_matches_guarded_images(self):
        ram,owners,raw,entry,core=self.pointer_fixture()
        calls=pointer_loop_contexts(ram,owners,entry,core);expected=[]
        current_ram=ram;current_owners=owners
        for call in calls:
            current_ram,current_owners=prepare_context(current_ram,current_owners,call,core)
            image,spans,_,_,evidence=unpack(current_ram,current_owners,raw,core)
            expected.append({a:image[a] for lo,hi in spans for a in range(lo,hi)})
            changed=set(expected[-1]);changed.update(range(evidence['tables']+1,evidence['tables']+158));changed.update(range(evidence['tail'],evidence['tail']+evidence['copied_tail_bytes']))
            current_owners={a:o for a,o in current_owners.items() if a not in changed}
        class Recording(list):
            def __setitem__(self,a,v):
                list.__setitem__(self,a,v)
                if self.pc==core+0xde:self.outputs[-1][a]=v
        for poison in (0,255):
            memory=Recording([poison]*65536);memory.pc=None;memory.outputs=[]
            for a in owners:list.__setitem__(memory,a,ram[a])
            cpu=MPU(memory=memory);cpu.pc=entry;cpu.sp=0xbd;cpu.a=poison;cpu.x=poison;cpu.y=poison;cpu.p=0x20|(poison&0xc7)
            for _ in range(4_000_000):
                if cpu.pc==calls[-1]['after_loop']:break
                self.assertTrue(entry<=cpu.pc<entry+27 or core<=cpu.pc<core+335)
                if cpu.pc==core:memory.outputs.append({})
                memory.pc=cpu.pc;cpu.step()
            else:self.fail('Caller/decoder execution did not reach the end of its bounded loop')
            self.assertEqual(memory.outputs,expected)
            self.assertEqual(cpu.x,8);self.assertEqual(cpu.sp,0xbd)

    def test_backreference_to_loaded_but_unemitted_ram_rejected(self):
        mem=GuardMemory(self.ram,self.owners,self.raw,self.core,identify(self.ram,self.core),0)
        list.__setitem__(mem,0x2a,0);list.__setitem__(mem,0x2b,0x82)
        with self.assertRaisesRegex(ValueError,'non-output RAM'):
            mem.before(SimpleNamespace(pc=self.core+0xdc,y=0))

    def test_uninitialized_workspace_read_rejected(self):
        mem=GuardMemory(self.ram,self.owners,self.raw,self.core,identify(self.ram,self.core),0)
        mem.pc=self.core+0x5e
        with self.assertRaisesRegex(ValueError,'Uninitialized RAM'):mem[0x7f59]

    def test_output_cannot_modify_decoder_or_stack(self):
        for address in (self.core+10,0x1a0,0xd000,0xd7ff):
            mem=GuardMemory(self.ram,self.owners,self.raw,self.core,identify(self.ram,self.core),0)
            mem.pc=self.core+0xde;mem.pending=('literal',self.owners[0x8200])
            with self.assertRaisesRegex(ValueError,'overlaps'):mem[address]=self.ram[0x8200]

    def test_scratch_copy_cannot_modify_active_decoder(self):
        layout=identify(self.ram,self.core);layout['tail']=self.core+0x40
        mem=GuardMemory(self.ram,self.owners,self.raw,self.core,layout,0)
        mem.pc=self.core+0x27;mem.tail_origin=self.owners[0x8200]
        with self.assertRaisesRegex(ValueError,'overlaps active decoder'):
            mem[self.core+0x40]=self.ram[0x8200]

    def test_independent_recorder_with_varied_memory_and_registers(self):
        image,spans,_,_,_=unpack(self.ram,self.owners,self.raw,self.core)
        for poison in (0,255):independent_replay(self.ram,self.owners,self.core,image,spans,poison)
        corrupted=bytearray(image);corrupted[spans[0][0]]^=1
        with self.assertRaisesRegex(ValueError,'differs'):
            independent_replay(self.ram,self.owners,self.core,corrupted,spans,0)

    def test_mads_preflight_failure_publishes_nothing(self):
        with tempfile.TemporaryDirectory(prefix='atari-fiji-test-') as temp:
            root=Path(temp);game=root/'games/fixture';(game/'decompiled').mkdir(parents=True)
            (game/'original.xex').write_bytes(self.raw)
            (game/'metadata.json').write_text(json.dumps({'title':'Fixture'}))
            with patch('recover_backward_tables.ROOT',root),patch.dict(os.environ,{'MADS':'/bin/false'}):
                with self.assertRaisesRegex(ValueError,'MADS mismatch'):recover_game(('fixture',True))
            self.assertFalse((game/'decompiled/recovered-stages').exists())
            self.assertEqual((game/'original.xex').read_bytes(),self.raw)

    def test_curated_marker_and_existing_recovery_are_preserved(self):
        with tempfile.TemporaryDirectory(prefix='atari-fiji-test-') as temp:
            root=Path(temp);d=root/'games/fixture/decompiled';d.mkdir(parents=True)
            marker=d/'reconstruction.json';marker.write_text('{}\n')
            with patch('recover_backward_tables.ROOT',root):
                self.assertEqual(recover_game(('fixture',True))['status'],'curated_preserved')
                marker.unlink();(d/'recovered-stages').mkdir()
                recovery=d/'recovered-stages/recovery.json';text='{"stages":[{"source":"existing.asm"}]}\n';recovery.write_text(text)
                self.assertEqual(recover_game(('fixture',True))['status'],'existing_recovery_preserved')
                self.assertEqual(recovery.read_text(),text)

    @unittest.skipUnless(shutil.which(os.environ.get('MADS','mads')),'MADS required')
    def test_publication_source_only_build_and_full_context_audit(self):
        with tempfile.TemporaryDirectory(prefix='atari-fiji-test-') as temp:
            root=Path(temp);game=root/'games/fixture';(game/'decompiled').mkdir(parents=True)
            (game/'original.xex').write_bytes(self.raw)
            (game/'metadata.json').write_text(json.dumps({'title':'Fixture'}))
            (root/'tools').mkdir();shutil.copy2(ROOT/'tools/rebuild_stages.py',root/'tools/rebuild_stages.py')
            with patch('recover_backward_tables.ROOT',root):
                result=recover_game(('fixture',True));self.assertEqual(result['status'],'published')
                out=game/'decompiled/recovered-stages'
                for path in out.glob('*.bin'):path.unlink()
                (out/'rebuilt-packed.xex').unlink()
                p=subprocess.run(['sh',str(out/'build.sh')],capture_output=True,text=True)
                self.assertEqual(p.returncode,0,p.stdout+p.stderr)
                self.assertEqual((out/'rebuilt-packed.xex').read_bytes(),self.raw)
                for path in out.glob('*.bin'):path.unlink()
                self.assertEqual(audit(game)['status'],'full_context_replay_source_mads_and_packed_verified')
                self.assertEqual((game/'original.xex').read_bytes(),self.raw)


if __name__=='__main__':unittest.main()
