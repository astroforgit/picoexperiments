#!/usr/bin/env python3
"""Assemble the small static subset needed by GitHub Pages."""
import argparse
import json
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
WEB = ROOT / 'atari-sound' / 'web'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('output', type=Path, help='output directory for the Pages artifact')
    args = parser.parse_args()
    output = args.output.resolve()
    if output in (ROOT, ROOT / 'atari-sound', WEB):
        raise SystemExit('Choose a separate output directory')
    if output.exists():
        shutil.rmtree(output)
    destination = output / 'atari-sound' / 'web'
    destination.mkdir(parents=True)
    for name in ('index.html', 'app.js', 'style.css', 'tracks.json'):
        shutil.copy2(WEB / name, destination / name)
    shutil.copytree(WEB / 'vendor', destination / 'vendor')
    catalog = json.loads((WEB / 'tracks.json').read_text())
    paths = set()
    for track in catalog['pico']:
        paths.update(Path('atari-sound') / 'mscsrc' / track['id'] / name for name in track['banks'])
        paths.update(Path('atari-sound') / 'rmt-variations' / track['id'] / name for name in track['variations'])
    for track in catalog['remixes']:
        paths.add(Path('atari-sound') / 'remixes' / track['id'] / 'original.sap')
        paths.add(Path('atari-sound') / 'remixes' / track['id'] / 'remix.sap')
    for relative in sorted(paths):
        source = ROOT / relative
        if not source.is_file():
            raise SystemExit(f'Missing audio: {relative}')
        target = output / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, target)
    (output / 'index.html').write_text('<!doctype html><meta charset="utf-8"><meta http-equiv="refresh" content="0;url=atari-sound/web/"><title>Atari Sound</title><a href="atari-sound/web/">Open Atari Sound</a>\n')
    (output / '.nojekyll').touch()
    print(f'Built Pages site with {len(paths)} SAP files at {output}')


if __name__ == '__main__':
    main()
