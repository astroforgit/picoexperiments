"""Common decoder tools must never reinterpret or quarantine foreign families."""
from pathlib import Path
import json,tempfile,unittest
from unittest.mock import patch
import recover_common,extend_stages,audit_recovered,audit_prefixes

class FamilyPreservationTests(unittest.TestCase):
    def test_foreign_family_is_preserved_by_all_common_tools(self):
        for family in ('backward-zaxxon-v1','backward-fiji-v1'):
            with self.subTest(family=family),tempfile.TemporaryDirectory(prefix='atari-family-') as tmp:
                root=Path(tmp);game=root/'games/sample';out=game/'decompiled/recovered-stages';out.mkdir(parents=True)
                (game/'original.xex').write_bytes(b'\xff\xff')
                (out/'recovery.json').write_text(json.dumps({'decoder_family':family,'stages':[{'source':'keep.asm'}]}))
                (out/'keep.asm').write_text('; Preserve family-specific source\n')
                (out/'build.sh').write_text('# family-specific build\n')
                def snapshot():return {str(p.relative_to(root)):p.read_bytes() for p in root.rglob('*') if p.is_file()}
                before=snapshot()
                for module,function,args in ((recover_common,'recover',({'folder':'games/sample','title':'Sample'},)),(extend_stages,'extend',({'folder':'games/sample','title':'Sample'},)),(audit_recovered,'audit',('games/sample',)),(audit_prefixes,'check',('games/sample',))):
                    with patch.object(module,'ROOT',root):result=getattr(module,function)(*args)
                    self.assertEqual(result['status'],'foreign_decoder_preserved')
                    self.assertEqual(snapshot(),before)

if __name__=='__main__':unittest.main(verbosity=2)
