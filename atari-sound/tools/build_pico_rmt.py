#!/usr/bin/env python3
"""Build a separate, reproducible RMT-derived arrangement for every PICO export."""
import argparse
from collections import Counter
from concurrent.futures import ProcessPoolExecutor
import json
from pathlib import Path
import shutil
import tempfile
import convert
import pico_rmt

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT/'rmt-variations'


def write_json(path, value):
    path.write_text(json.dumps(value, indent=2, ensure_ascii=False)+'\n')


from rmt_instruments import extract

def build_one(task):
    game, bank, player, labels = task
    original = ROOT/game['directory']
    slug = original.name
    cart = json.loads((original/'source-music.json').read_text())
    manifest = json.loads((original/'manifest.json').read_text())
    settings = pico_rmt.profile(cart, game['title'], bank, game['kind'])
    def renderer(pid, pattern, sfx):
        count = max(1, round(convert.duration_ticks(pattern, sfx)*convert.TICK*convert.FPS))
        return pico_rmt.render(pattern, sfx, count, settings, bank)
    with tempfile.TemporaryDirectory(prefix='build-', dir=str(OUTPUT)) as tmp:
        folder = Path(tmp)
        result = convert.export_game(folder, game['title'], cart, manifest['sources'], '', player, labels, renderer)
        result.update(arrangement=settings['style'], style_name=settings['style_name'], donor=settings['donor'], controls='Space / N / P')
        result['warnings'] = [w for w in result['warnings'] if 'Custom instruments' not in w]
        result['warnings'] += ['Isolated RMT instruments play the PICO notes; custom waves use the assigned instrument.',
                               'Static PICO score only; gameplay-driven Lua music changes are not executed.']
        write_json(folder/'manifest.json', result)
        write_json(folder/'arrangement.json', settings)
        # Original extraction remains in mscsrc; avoid another copy of all source scores.
        (folder/'source-music.json').unlink()
        destination = OUTPUT/slug
        if destination.exists():
            # Only generated assets owned by this builder are replaced.
            for path in folder.iterdir(): shutil.copy2(path, destination/path.name)
            keep = {p.name for p in folder.iterdir()}
            for path in destination.iterdir():
                if path.suffix in ('.PMS', '.XEX', '.sap') and path.name not in keep: path.unlink()
        else:
            shutil.copytree(folder, destination)
    return dict(directory='rmt-variations/'+slug, title=game['title'], kind=game['kind'],
                banks=len(result['banks']), warnings=result['warnings'], arrangement=settings['style'],
                style_name=settings['style_name'], donor=settings['donor'])


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--library', type=Path, help='ASAP library exposing Pico_New/Pico_Frame; needed for donor extraction')
    parser.add_argument('--limit', type=int)
    parser.add_argument('--workers', type=int, default=4)
    args = parser.parse_args()
    OUTPUT.mkdir(exist_ok=True)
    bank_path = OUTPUT/'instrument-bank.json'
    if args.library:
        bank = extract(args.library)
        write_json(bank_path, bank)
    else:
        bank = json.loads(bank_path.read_text())
    print('Donors:', len(bank['sources']), 'RMT tracks,', len(bank['voices']), 'isolated instruments,',
          'no added percussion', flush=True)
    games = json.loads((ROOT/'catalog.json').read_text())['games']
    if args.limit: games = games[:args.limit]
    player, labels = convert.build_player('mads')
    results = []
    with ProcessPoolExecutor(max_workers=args.workers) as pool:
        for result in pool.map(build_one, ((g, bank, player, labels) for g in games)):
            results.append(result)
            if len(results) % 20 == 0: print('Built', len(results), '/', len(games), flush=True)
    catalog = dict(summary=dict(music_games=sum(g['kind'] == 'music' for g in results),
                                sfx_auditions=sum(g['kind'] == 'sfx-audition' for g in results),
                                banks=sum(g['banks'] for g in results),
                                styles=dict(Counter(g['style_name'] for g in results))), games=results)
    write_json(OUTPUT/'catalog.json', catalog)
    print(json.dumps(catalog['summary'], indent=2), flush=True)


if __name__ == '__main__': main()
