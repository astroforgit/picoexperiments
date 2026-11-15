#!/usr/bin/env python3
"""Build four listening trials only. Never regenerate the mscsrc collection."""
import json
from pathlib import Path
import arrange
import convert

ROOT = Path(__file__).resolve().parents[1]
GAMES = ['porterpatch1-1', 'pushamo', 'porklike', 'celeste-classic-2']


def main():
    output = ROOT/'auditions'
    output.mkdir(exist_ok=True)
    player, labels = convert.build_player('mads')
    games = []
    for name in GAMES:
        original = ROOT/'mscsrc'/name
        manifest = json.loads((original/'manifest.json').read_text())
        cart = json.loads((original/'source-music.json').read_text())
        arrangement = arrange.make_arrangement(cart, manifest['title'])

        def renderer(pid, pattern, sfx):
            length = max(1, round(convert.duration_ticks(pattern, sfx)*convert.TICK*convert.FPS))
            return arrange.render(pattern, sfx, length, arrangement, pid)

        result = convert.export_game(output/name, manifest['title'], cart, manifest['sources'], '',
                                     player, labels, renderer=renderer)
        result['arrangement'] = arrange.STYLE
        result['warnings'] = [w for w in result['warnings'] if 'Custom instruments' not in w]
        result['warnings'].append('Listening trial: custom waves become shaped tonal instruments; large pitch effects are simplified.')
        (output/name/'manifest.json').write_text(json.dumps(result, indent=2)+'\n')
        (output/name/'arrangement.json').write_text(json.dumps(arrangement, indent=2)+'\n')
        games.append(dict(directory=f'auditions/{name}', title=manifest['title'], kind='music',
                          banks=len(result['banks']), warnings=result['warnings'], arrangement=arrange.STYLE))
        print('Audition:', manifest['title'])
    (output/'catalog.json').write_text(json.dumps(dict(summary=dict(music_games=len(games)), games=games), indent=2)+'\n')


if __name__ == '__main__':
    main()
