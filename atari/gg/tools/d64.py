#!/usr/bin/env python3
"""Extract the files of the Ghosts'n Goblins Arcade D64 into disk/."""
import os, sys

SPT = [21] * 17 + [19] * 7 + [18] * 6 + [17] * 5


def offset(t, s):
    return (sum(SPT[:t - 1]) + s) * 256


def read_chain(d, t, s):
    out = bytearray()
    while t:
        b = d[offset(t, s):offset(t, s) + 256]
        if b[0] == 0:
            out += b[2:b[1] + 1]
            break
        out += b[2:]
        t, s = b[0], b[1]
    return bytes(out)


def directory(d):
    t, s = 18, 1
    while t:
        b = d[offset(t, s):offset(t, s) + 256]
        for i in range(8):
            e = b[i * 32:i * 32 + 32]
            if e[2]:
                yield e[5:21], e[3], e[4]
        t, s = b[0], b[1]


def main():
    here = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    src = sys.argv[1] if len(sys.argv) > 1 else os.path.join(here, 'GhostNGoblinsArcade_N0S_FL_Universal.d64')
    d = open(src, 'rb').read()
    out = os.path.join(here, 'disk')
    os.makedirs(out, exist_ok=True)
    for i, (raw, t, s) in enumerate(directory(d)):
        data = read_chain(d, t, s)
        short = raw[:5].decode('latin1').strip('\xa0 ').replace("'", '')
        name = 'boot' if i == 0 else short
        open(os.path.join(out, name + '.prg'), 'wb').write(data)
        print(f'{name:8} {t:2},{s:2} {len(data):6} load ${data[0] | data[1] << 8:04X}')


if __name__ == '__main__':
    main()
