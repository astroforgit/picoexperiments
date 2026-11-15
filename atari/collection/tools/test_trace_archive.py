"""Admission and byte-preservation checks; no collection project is modified."""
from pathlib import Path
import os,shutil,struct,subprocess,tempfile,unittest
from disasm import parse,analyse
from trace_archive import merge_runtime,emit,read_pcmap

def segment(address,data):return struct.pack('<HH',address,address+len(data)-1)+data

def parts(data):return parse(data)[0]

class MappingTests(unittest.TestCase):
    def test_identical_overlays_ambiguous(self):
        p=parts(segment(0x2000,b'\xa9\x01\x60')+segment(0x2000,b'\xa9\x01\x60'))
        code,admitted,e=merge_runtime(p,{}, {0x2000:b'\xa9\x01\x60'})
        self.assertFalse(code);self.assertEqual(e['unmatched_execution_addresses']['ambiguous_original_overlay'],[0x2000])

    def test_distinct_overlay_maps_only_matching_file_offset(self):
        p=parts(segment(0x2000,b'\xa9\x01\x60')+segment(0x2000,b'\xa9\x02\x60'))
        code,admitted,e=merge_runtime(p,{}, {0x2000:b'\xa9\x01\x60'})
        self.assertEqual(code,{4:(0x2000,2)});self.assertEqual(e['added_code_bytes'],2)

    def test_three_byte_evidence_must_fit_one_segment(self):
        p=parts(segment(0x2000,b'\xea\x60')+segment(0x2002,b'\x00'))
        code,admitted,e=merge_runtime(p,{}, {0x2000:b'\xea\x60\x00'})
        self.assertFalse(code);self.assertEqual(e['unique_three_byte_matches'],0)

    def test_static_boundaries_preserved(self):
        p=parts(segment(0x2000,b'\xad\xa9\x01\xea\xea'));static={4:(0x2000,3)}
        code,admitted,e=merge_runtime(p,static,{0x2001:b'\xa9\x01\xea'})
        self.assertEqual(code,static);self.assertEqual(e['added_code_bytes'],0)

    def test_conflicting_runtime_boundaries_both_rejected(self):
        p=parts(segment(0x2000,b'\xad\xa9\x01\xea\xea'))
        code,admitted,e=merge_runtime(p,{}, {0x2000:b'\xad\xa9\x01',0x2001:b'\xa9\x01\xea'})
        self.assertFalse(code);self.assertEqual(len(e['unmatched_execution_addresses']['conflicting_runtime_instruction_boundaries']),2)

    def test_changed_and_outside_execution_are_not_original_code(self):
        p=parts(segment(0x2000,b'\xa9\x01\x60'))
        code,admitted,e=merge_runtime(p,{}, {0x2000:b'\xa9\x02\x60',0x8000:b'\xa9\x01\x60'})
        self.assertFalse(code);self.assertEqual(e['observed_execution_addresses'],2)

    def test_pcmap_requires_complete_records(self):
        with self.assertRaises(ValueError):read_pcmap(b'\0')

    def test_emitter_mads_preserves_markers_overlays_and_tail(self):
        assembler=os.environ.get('MADS','mads')
        if not shutil.which(assembler):self.skipTest('MADS unavailable')
        original=b'\xff\xff'+segment(0x2000,b'\xa9\x01\x60\xea\xea')+b'\xff\xff'+segment(0x2000,b'\xa9\x02\x60\xea\xea')+b'\x12\x34\x56'
        p,warning=parse(original);static,*_=analyse(p);code,admitted,e=merge_runtime(p,static,{0x2000:b'\xa9\x01\x60'})
        assembly,_=emit(p,code,admitted,'Fixture')
        with tempfile.TemporaryDirectory(prefix='archive-runtime-test-') as tmp:
            tmp=Path(tmp);source=tmp/'source.asm';binary=tmp/'output.xex';source.write_text(assembly)
            proc=subprocess.run([assembler,str(source),'-o:'+str(binary)],capture_output=True,text=True)
            self.assertEqual(proc.returncode,0,proc.stdout+proc.stderr);self.assertEqual(binary.read_bytes(),original)

if __name__=='__main__':unittest.main(verbosity=2)
