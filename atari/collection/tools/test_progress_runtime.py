import sys,json,tempfile,unittest,hashlib,os
from pathlib import Path
from unittest.mock import patch
from types import SimpleNamespace
sys.path.insert(0,str(Path(__file__).resolve().parent))
import progress,verify_all

class IntegrationTests(unittest.TestCase):
 def setUp(self):
  self.tmp=tempfile.TemporaryDirectory();self.root=Path(self.tmp.name);self.records=[]
  self.p=patch.object(progress,'ROOT',self.root);self.p.start();self.v=patch.object(verify_all,'ROOT',self.root);self.v.start()
 def tearDown(self):self.p.stop();self.v.stop();self.tmp.cleanup()
 def game(self,name,runtime=False,stages=False,curated=False):
  game=self.root/'games'/name;dec=game/'decompiled';dec.mkdir(parents=True)
  original=b'fixture';(game/'original.xex').write_bytes(original)
  rec=dict(title=name,folder='games/'+name,sha256=hashlib.sha256(original).hexdigest());self.records.append(rec)
  (dec/'build.sh').write_text('#!/bin/sh\nset -eu\n');(dec/'build.sh').chmod(0o755)
  if runtime:
   (dec/'runtime-archive.json').write_text(json.dumps(dict(status='runtime_enhanced_original_archive_verified',byte_exact_rebuild=True,runtime_evidence=dict(added_code_bytes=80,added_runtime_instructions=40))))
   (dec/'build-runtime-archive.sh').write_text('#!/bin/sh\n')
  if stages:
   out=dec/'recovered-stages';out.mkdir();(out/'recovery.json').write_text(json.dumps(dict(stages=[dict(bytes=100,code_bytes=60,instructions=30)])))
  if curated:(dec/'reconstruction.json').write_text(json.dumps(dict(status='partially_annotated',image_bytes=200,code_bytes=120,instructions=60,test_frames=3600,source='source.asm',recovered_stage_count=1,packed_output='packed.xex')))
  return dec,rec
 def test_categories_and_separate_totals(self):
  self.game('plain');self.game('runtime',runtime=True);self.game('stage',stages=True);self.game('curated',curated=True)
  rows,s=progress.build_index(dict(games=self.records),{})
  self.assertEqual([r['recovery_level'] for r in rows],['archive_listing_only','archive_listing_runtime_enhanced','unpacked_stages_mads_verified','partially_annotated'])
  self.assertEqual(s['verified_recovered_stage_images'],2);self.assertEqual(s['recovered_stage_bytes_including_overlays'],300)
  self.assertEqual(s['decoded_recovered_code_bytes'],180);self.assertEqual(s['archive_runtime_added_code_bytes'],80);self.assertEqual(s['archive_runtime_added_instructions'],40)
  self.assertEqual(s['not_yet_unpacked_or_individually_reconstructed'],2)
 def test_category_precedence(self):
  self.game('stage',runtime=True,stages=True);self.game('curated',runtime=True,stages=True,curated=True)
  rows,_=progress.build_index(dict(games=self.records),{})
  self.assertEqual(rows[0]['recovery_level'],'unpacked_stages_mads_verified');self.assertEqual(rows[1]['recovery_level'],'partially_annotated')
 def test_hook_idempotent_preserves_mode_skips_curated(self):
  dec,_=self.game('runtime',runtime=True);self.assertTrue(progress.install_runtime_build_hook(dec));text=(dec/'build.sh').read_text()
  self.assertFalse(progress.install_runtime_build_hook(dec));self.assertEqual(text,(dec/'build.sh').read_text());self.assertEqual((dec/'build.sh').stat().st_mode&0o777,0o755)
  dec,_=self.game('curated',runtime=True,curated=True);before=(dec/'build.sh').read_bytes();self.assertFalse(progress.install_runtime_build_hook(dec));self.assertEqual(before,(dec/'build.sh').read_bytes())
 def test_family_notes_preserved_and_missing_notes_include_audit(self):
  for name in ('existing','missing'):
   dec,_=self.game(name,stages=True);out=dec/'recovered-stages';r=json.loads((out/'recovery.json').read_text());r['decoder_family']='backward-fiji-v1';r['limitations']=['Family-specific limitation'];(out/'recovery.json').write_text(json.dumps(r))
   if name=='existing':(out/'README.txt').write_text('Do not erase decoder limitation\n')
  (self.root/'manifest.json').write_text(json.dumps(dict(games=self.records)))
  progress.main()
  self.assertEqual((self.root/'games/existing/decompiled/recovered-stages/README.txt').read_text(),'Do not erase decoder limitation\n')
  text=(self.root/'games/missing/decompiled/recovered-stages/README.txt').read_text();self.assertIn('recover_backward_tables.py --audit "$(cd ../.. && pwd)"',text);self.assertIn('Family-specific limitation',text)
 def test_verify_uses_normal_build_and_checks_runtime_output(self):
  dec,rec=self.game('runtime',runtime=True)
  (dec/'game.xex').write_bytes(b'fixture');(dec/'runtime-archive.xex').write_bytes(b'fixture')
  with patch.object(verify_all.subprocess,'run',return_value=SimpleNamespace(returncode=0,stdout='')) as run:
   result=verify_all.verify(rec);self.assertEqual(result['status'],'pass');self.assertEqual(result['runtime_archive_status'],'pass');self.assertEqual(run.call_args.args[0],['sh','build.sh'])
   (dec/'runtime-archive.xex').write_bytes(b'bad');self.assertEqual(verify_all.verify(rec)['status'],'fail')
 def test_verify_curated_ignores_archived_runtime_view(self):
  dec,rec=self.game('curated',runtime=True,curated=True);(dec/'packed.xex').write_bytes(b'fixture')
  with patch.object(verify_all.subprocess,'run',return_value=SimpleNamespace(returncode=0,stdout='')):
   result=verify_all.verify(rec);self.assertEqual(result['status'],'pass');self.assertNotIn('runtime_archive_status',result)

 def test_relocation_does_not_inflate_unpacked_progress(self):
  dec,_=self.game('relocated');out=dec/'relocated-runtime';out.mkdir();(out/'recovery.json').write_text(json.dumps({'stages':[{'bytes':100,'code_bytes':50}]}))
  rows,summary=progress.build_index({'games':self.records},{})
  self.assertEqual(summary['relocated_runtime_projects'],1);self.assertEqual(summary['relocated_runtime_bytes'],100)
  self.assertEqual(summary['verified_recovered_stage_images'],0);self.assertEqual(summary['not_yet_unpacked_or_individually_reconstructed'],1)
  self.assertEqual(rows[0]['recovery_level'],'archive_listing_only')
 def test_verifier_checks_relocated_rebuild(self):
  dec,rec=self.game('relocated');out=dec/'relocated-runtime';out.mkdir();(out/'recovery.json').write_text('{}');(dec/'game.xex').write_bytes(b'fixture');(out/'rebuilt-packed.xex').write_bytes(b'fixture')
  with patch.object(verify_all.subprocess,'run',return_value=SimpleNamespace(returncode=0,stdout='')):
   self.assertEqual(verify_all.verify(rec)['relocated_runtime_status'],'pass')
   (out/'rebuilt-packed.xex').write_bytes(b'bad');self.assertEqual(verify_all.verify(rec)['status'],'fail')
 def test_relocation_without_hook_is_built_and_stale_output_cannot_hide_failure(self):
  dec,rec=self.game('relocated');out=dec/'relocated-runtime';out.mkdir();(out/'recovery.json').write_text('{}');(dec/'game.xex').write_bytes(b'fixture');(out/'rebuilt-packed.xex').write_bytes(b'fixture')
  with patch.object(verify_all.subprocess,'run',side_effect=[SimpleNamespace(returncode=0,stdout=''),SimpleNamespace(returncode=1,stdout='relocation assembly failed')]) as run:
   result=verify_all.verify(rec);self.assertEqual(result['status'],'fail');self.assertIn('relocation assembly failed',result['error'])
   self.assertEqual([call.args[0] for call in run.call_args_list],[['sh','build.sh'],['sh','relocated-runtime/build.sh']])
 def test_relocation_hook_avoids_duplicate_build(self):
  dec,rec=self.game('relocated');out=dec/'relocated-runtime';out.mkdir();(out/'recovery.json').write_text('{}');(dec/'game.xex').write_bytes(b'fixture');(out/'rebuilt-packed.xex').write_bytes(b'fixture');(dec/'build.sh').write_text('sh relocated-runtime/build.sh\n')
  with patch.object(verify_all.subprocess,'run',return_value=SimpleNamespace(returncode=0,stdout='')) as run:
   self.assertEqual(verify_all.verify(rec)['status'],'pass');self.assertEqual(run.call_count,1)

if __name__=='__main__':unittest.main(verbosity=2)
