"""Publication regressions: fake stream discovery, real MADS/reconstruction.
No original collection file is modified. Run with MADS=/path/to/mads python3 ...
"""
from pathlib import Path
import hashlib,json,os,struct,sys,tempfile,unittest
from unittest.mock import patch
import extend_stages as ext
from rebuild_stages import reconstruct


class PublicationTests(unittest.TestCase):
    def setUp(self):
        self.temp=tempfile.TemporaryDirectory(prefix='atari-publication-fixtures-')
        self.root=Path(self.temp.name);self.game=self.root/'games/sample';self.out=self.game/'decompiled/recovered-stages';self.out.mkdir(parents=True)
        self.raw=b'\xff\xff'+struct.pack('<HH',0x5000,0x5000)+b'\x42'
        (self.game/'original.xex').write_bytes(self.raw)
        old={'source':'stage-01.asm','binary':'stage-01.bin','spans':[[0x9000,0x9001]],'sha256':hashlib.sha256(b'\x55').hexdigest(),'depacker_address':0x4000,'compressed_source':0x5010,'literal_patches':[]}
        self.report={'title':'Sample','stages':[old],'original_sha256':hashlib.sha256(self.raw).hexdigest()}
        (self.out/'recovery.json').write_text(json.dumps(self.report)+'\n')
        (self.out/'stage-01.asm').write_text('; Preserve this manually annotated source exactly.\n opt h-\n org $9000\n dta $55\n')
        (self.out/'build.sh').write_text('#!/bin/sh\n# original build recipe\n');(self.out/'build.sh').chmod(0o755)
        def unpack(ram,core,source,loaded):
            image=bytearray(ram);image[0x8000]=0x42
            return bytes(image),[[0x8000,0x8001]],[(0x5000,0x8000)],1
        self.patches=[patch.object(ext,'ROOT',self.root),patch.object(ext,'core_offsets',lambda data:iter([0x4000])),patch.object(ext,'candidates',lambda ram,loaded,core:[(0x5000,[])]),patch.object(ext,'unpack',unpack)]
        for p in self.patches:p.start()
        self.record={'folder':'games/sample','title':'Sample'}

    def tearDown(self):
        for p in reversed(self.patches):p.stop()
        self.temp.cleanup()

    def snapshot(self):
        return {str(p.relative_to(self.out)):(p.read_bytes(),p.stat().st_mode&0o777) for p in self.out.rglob('*') if p.is_file()}

    def test_missing_existing_binary_assembled_and_published(self):
        before=(self.out/'stage-01.asm').read_bytes()
        before_mode=(self.out/'build.sh').stat().st_mode&0o777
        result=ext.extend(self.record)
        self.assertEqual(result['status'],'new_images_mads_and_packed_verified')
        self.assertEqual((self.out/'stage-01.asm').read_bytes(),before)
        self.assertEqual((self.out/'stage-01.bin').read_bytes(),b'\x55')
        self.assertEqual((self.out/'extension-01.bin').read_bytes(),b'\x42')
        self.assertEqual((self.out/'rebuilt-packed.xex').read_bytes(),self.raw)
        self.assertIn('extension-01.asm',(self.out/'build.sh').read_text())
        self.assertEqual((self.out/'build.sh').stat().st_mode&0o777,before_mode)
        self.assertEqual(len(json.loads((self.out/'recovery.json').read_text())['stages']),2)
        after=self.snapshot();self.assertEqual(ext.extend(self.record)['status'],'no_new_images');self.assertEqual(self.snapshot(),after)

    def test_forced_preflight_failure_publishes_nothing(self):
        before=self.snapshot()
        with patch.object(ext,'reconstruct',side_effect=ValueError('forced preflight failure')):
            with self.assertRaisesRegex(ValueError,'forced preflight failure'):ext.extend(self.record)
        self.assertEqual(self.snapshot(),before)
        self.assertFalse((self.out/'stage-01.bin').exists())

    def test_corrupt_existing_binary_publishes_nothing(self):
        (self.out/'stage-01.bin').write_bytes(b'\x99');before=self.snapshot()
        with self.assertRaisesRegex(ValueError,'Assembled stage differs'):ext.extend(self.record)
        self.assertEqual(self.snapshot(),before)

    def test_new_curated_marker_prevents_publication(self):
        before=self.snapshot()
        def curate_then_return(report,original,reader):
            packed=reconstruct(report,original,reader)
            (self.game/'decompiled/reconstruction.json').write_text('{"curated":true}\n')
            return packed
        with patch.object(ext,'reconstruct',side_effect=curate_then_return):result=ext.extend(self.record)
        self.assertEqual(result['status'],'curated_preserved');self.assertEqual(result['added'],[])
        self.assertEqual(self.snapshot(),before)

    def test_orphan_binary_name_is_not_overwritten(self):
        (self.out/'extension-01.bin').write_bytes(b'preserved orphan')
        result=ext.extend(self.record)
        self.assertEqual(result['added'][0]['source'],'extension-02.asm')
        self.assertEqual((self.out/'extension-01.bin').read_bytes(),b'preserved orphan')

    def test_original_hash_failure_publishes_nothing(self):
        changed=dict(self.report,original_sha256='0'*64)
        (self.out/'recovery.json').write_text(json.dumps(changed)+'\n');before=self.snapshot()
        with self.assertRaisesRegex(ValueError,'Original input hash changed'):ext.extend(self.record)
        self.assertEqual(self.snapshot(),before)


class PureReconstructionTests(unittest.TestCase):
    def test_negative_patch_index_rejected(self):
        original=b'\x42';image=b'\x42'
        report={'original_sha256':hashlib.sha256(original).hexdigest(),'stages':[{'binary':'image.bin','sha256':hashlib.sha256(image).hexdigest(),'literal_patches':[[-1,0]]}]}
        with self.assertRaisesRegex(ValueError,'outside input or image'):reconstruct(report,original,lambda name:image)


if __name__=='__main__':unittest.main(verbosity=2)
