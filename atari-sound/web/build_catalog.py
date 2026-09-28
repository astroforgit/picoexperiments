#!/usr/bin/env python3
"""Build the compact browser catalog from the Atari Sound source catalogs."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = Path(__file__).with_name('tracks.json')


def sap_files(directory):
    return sorted((p.name for p in (ROOT / directory).glob('*.sap')), key=lambda name: (name.lower().replace('-extra', ''), '-extra' in name))


def main():
    pico = []
    source = json.loads((ROOT / 'catalog.json').read_text())
    for game in source['games']:
        directory = game['directory']
        banks = sap_files(directory)
        variation_dir = 'rmt-variations/' + Path(directory).name
        variations = sap_files(variation_dir)
        if not banks or not variations:
            continue
        arrangement = ROOT / variation_dir / 'arrangement.json'
        donor = ''
        if arrangement.exists():
            donor = json.loads(arrangement.read_text()).get('style_name', '')
        pico.append({
            'id': Path(directory).name,
            'title': game['title'],
            'kind': game['kind'],
            'banks': banks,
            'variations': variations,
            'donor': donor,
        })

    remixes = []
    source = json.loads((ROOT / 'remixes/catalog.json').read_text())
    for track in source['tracks']:
        directory = ROOT / track['directory']
        if not (directory / 'original.sap').exists() or not (directory / 'remix.sap').exists():
            continue
        remixes.append({
            'id': track['id'],
            'title': track['title'],
            'remix': track['remix'],
            'author': track.get('author', ''),
            'duration': round(track['duration_seconds']),
        })
    midi = []
    for track in json.loads((ROOT / 'midi-catalog.json').read_text())['tracks']:
        for key in ('file', 'midi', 'audio'):
            if not (ROOT / track[key]).is_file():
                raise FileNotFoundError(ROOT / track[key])
        midi.append(track)
    OUT.write_text(json.dumps({'pico': pico, 'remixes': remixes, 'midi': midi}, ensure_ascii=False, separators=(',', ':')) + '\n')
    print(f'Wrote {len(pico)} PICO pairs, {len(remixes)} Atari remix pairs, and {len(midi)} MIDI conversions to {OUT}')


if __name__ == '__main__':
    main()
