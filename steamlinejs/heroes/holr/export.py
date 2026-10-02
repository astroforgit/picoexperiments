#!/usr/bin/env python3
"""Export embedded Lua source from the local Heroes of Lowrez bundle."""
import contextlib
import hashlib
import io
import json
from pathlib import Path
import runpy

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent


def main():
    # Reuse the archive decoder; no recovered game code is executed.
    with contextlib.redirect_stdout(io.StringIO()):
        recovered = runpy.run_path(str(ROOT / 'design/lowrez/recover.py'))
    fields = recovered['fields']
    extracted = recovered['out']
    scripts = []
    for numbered in sorted(extracted.glob('*.lua')):
        index = int(numbered.stem)
        source = fields(fields((extracted / f'{index:03}.bin').read_bytes())[1][0])
        original = source[2][0].decode('utf-8')
        relative = Path(original)
        if relative.is_absolute() or '..' in relative.parts:
            raise ValueError(f'Unsafe resource path: {original}')
        # Preserve script kinds in the filename while giving every export .lua.
        if relative.suffix != '.lua':
            relative = Path(str(relative) + '.lua')
        target = HERE / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        lua = source[1][0]
        lua.decode('utf-8')  # Reject bytecode or invalid text instead of mislabeling it.
        assert lua == numbered.read_bytes()
        target.write_bytes(lua)
        assert target.read_bytes() == lua
        scripts.append({'resource_index': index, 'original_path': original,
                        'export_path': relative.as_posix(), 'bytes': len(lua),
                        'sha256': hashlib.sha256(lua).hexdigest()})
    inputs = {name: hashlib.sha256((ROOT / name).read_bytes()).hexdigest()
              for name in ('game.arci0', 'game.arcd0', 'game.arcd1')}
    (HERE / 'manifest.json').write_text(json.dumps(
        {'archive_sha256': inputs, 'scripts': scripts}, indent=2) + '\n')
    print(f'Exported and byte-verified {len(scripts)} Lua sources to {HERE}')


if __name__ == '__main__':
    main()
