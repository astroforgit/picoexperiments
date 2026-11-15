#!/usr/bin/env python3
"""Execute every alternate SAP pattern in ASAP and check native data and flow."""
import argparse
from concurrent.futures import ProcessPoolExecutor
import json
from pathlib import Path
import build_remixes as b
import convert

ROOT = Path(__file__).resolve().parents[1]


def verify(task):
    game, library = task
    lib = b.api(library)
    folder = ROOT/game['directory']
    manifest = json.loads((folder/'manifest.json').read_text())
    frames_checked = entries_checked = 0
    totals = {}
    for bank in manifest['banks']:
        data = (folder/(bank['file']+'.PMS')).read_bytes()
        assert data[:4] == b'PMS1' and len(data) <= convert.MAX_BANK
        assert data[5] == len(bank['entries'])
        # Independently parse native load segments, check actual loaded score.
        binary = (folder/(bank['file']+'.XEX')).read_bytes()
        memory, pos = bytearray(65536), 0
        while pos < len(binary):
            start = int.from_bytes(binary[pos:pos+2], 'little'); pos += 2
            if start == 65535: continue
            end = int.from_bytes(binary[pos:pos+2], 'little'); pos += 2
            assert end >= start and pos+end-start+1 <= len(binary)
            memory[start:end+1] = binary[pos:pos+end-start+1]; pos += end-start+1
        assert memory[convert.BASE:convert.BASE+len(data)] == data
        streams = []
        for i, entry in enumerate(bank['entries']):
            pointer = data[0xc0+i]+256*data[0x100+i]-convert.BASE
            assert convert.HEADER <= pointer < len(data)
            expected = list(convert.decode(data[pointer:]))
            assert len(expected) == entry['frames']
            assert all(f[8] == 0 and all((f[j]&15) <= 7 for j in (1, 3, 5, 7)) for f in expected)
            assert data[0x80+i] == entry['next_local']
            streams.append(expected)
            totals[entry['id']] = totals.get(entry['id'], 0)+len(expected)
        for i, (entry, expected) in enumerate(zip(bank['entries'], streams)):
            suffix = '-extra' if i >= 32 else ''
            actual = b.capture(lib, folder/(bank['file']+suffix+'.sap'), len(expected)+1, i % 32)
            if actual[:-1] != expected:
                at = next(k for k, pair in enumerate(zip(actual, expected)) if pair[0] != pair[1])
                raise AssertionError(f'{folder.name}/{bank["file"]} entry {i}, frame {at}')
            next_entry = entry['next_local']
            if next_entry != 255:
                assert actual[-1] == streams[next_entry][0], 'Pattern transition mismatch'
            else:
                assert all(actual[-1][j]&15 == 0 for j in (1, 3, 5, 7)), 'End did not silence'
            frames_checked += len(expected)
            entries_checked += 1
    cart = json.loads((ROOT/'mscsrc'/folder.name/'source-music.json').read_text())
    for pid, total in totals.items():
        pattern = cart['music'][pid] if game['kind'] == 'music' else dict(channels=[pid,64,64,64])
        assert total == max(1, round(convert.duration_ticks(pattern, cart['sfx'])*convert.TICK*convert.FPS))
    return frames_checked, entries_checked


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--library', required=True)
    args = parser.parse_args()
    games = json.loads((ROOT/'rmt-variations/catalog.json').read_text())['games']
    frames = entries = 0
    with ProcessPoolExecutor(max_workers=4) as pool:
        for i, (f, e) in enumerate(pool.map(verify, ((g, args.library) for g in games)), 1):
            frames += f; entries += e
            if i % 50 == 0: print(f'Validated {i}/{len(games)} games, {frames} frames', flush=True)
    report = dict(games=len(games), entries=entries, frames=frames, failures=0,
                  checks=['Every SAP pattern and following transition matches POKEY data in ASAP',
                          'Every native XEX contains its complete PMS score within Atari RAM',
                          'Every pattern retains its original PICO duration', 'Fixed clock, volume at most 7'])
    (ROOT/'rmt-variations/validation.json').write_text(json.dumps(report, indent=2)+'\n')
    print(json.dumps(report, indent=2))


if __name__ == '__main__': main()
