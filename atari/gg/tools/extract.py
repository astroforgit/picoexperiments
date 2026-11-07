#!/usr/bin/env python3
"""Record what every disk file writes when the game loads it: extract.py

Runs the C64 model through the boot, the intro, the menu and the start of
each level (and the "play original" mode), with the loader traps recording
every byte the decruncher stores. Writes gen/loads.json: per file, the
segments (address, bytes) in final form and the $01 value. A file that is
loaded more than once must produce the same bytes every time.
"""
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import gng  # noqa: E402


def runs(rec):
    """(start, bytes) runs of a {addr: value} map."""
    out = []
    for a in sorted(rec):
        if out and out[-1][0] + len(out[-1][1]) == a:
            out[-1][1].append(rec[a])
        else:
            out.append((a, [rec[a]]))
    return out


def main():
    files = {}

    def collect(g):
        for r in g.capture:
            if r['mode'] != 0:
                continue
            w = {a: v for a, (v, io) in r['writes'].items()}
            io = sorted(a for a, (v, io) in r['writes'].items() if io)
            prev = files.get(r['file'])
            if prev and prev['writes'] != w:
                print(f'file {r["file"]:02X}: different contents on reload', file=sys.stderr)
            files[r['file']] = {'writes': w, 'io': io, 'segs': r['segs']}

    # boot -> menu (intro 08, game 09, menu 0A)
    g = gng.Game(verbose=False)
    g.capture = []
    f0 = g.frame
    while not g.loads or g.loads[-1][1] != 0x0A:
        k = g.frame - f0
        g.joy2 = 0xEF if k % 400 in range(200, 210) else 0xFF
        g.run(63 * 312)
    g.run(63 * 312 * 120)
    collect(g)
    for level in range(1, 7):
        for original in (False, True) if level == 1 else (False,):
            g = gng.Game(verbose=False, snapshot=gng.menu_snapshot())
            g.capture = []
            g = gng.start_game(level, original=original, game=g)
            collect(g)
            print(f'level {level} original={original}: loads', [hex(x[1]) for x in g.loads], flush=True)
    out = {f'{n:02X}': {'segs': v['segs'], 'io': v['io'],
                        'runs': [[a, bytes(b).hex()] for a, b in runs(v['writes'])]}
           for n, v in sorted(files.items())}
    os.makedirs(os.path.join(gng.HERE, 'gen'), exist_ok=True)
    with open(os.path.join(gng.HERE, 'gen', 'loads.json'), 'w') as f:
        json.dump(out, f, indent=0)
    for n, v in out.items():
        total = sum(len(h) // 2 for a, h in v['runs'])
        rng = ', '.join(f'${a:04X}-${a + len(h) // 2 - 1:04X}' for a, h in v['runs'])
        print(f'{n}: {total:6} bytes  io-writes {len(v["io"]):4}  {rng}')


if __name__ == '__main__':
    main()
