#!/usr/bin/env python3
"""Resample the eight encoded PicoRacer courses for the VBXE renderer."""
from pathlib import Path

root = Path(__file__).resolve().parents[2]
cart = (root / 'allgames/[Race]/PicoRacer-2048.p8').read_text()
map_text = cart.split('__map__\n', 1)[1].split('\n__sfx__', 1)[0]
raw = bytes.fromhex(''.join(map_text.splitlines()))
assert len(raw) == 4096
out = []
lengths = []
for course in range(8):
    block = raw[course * 512:(course + 1) * 512]
    original = []
    for at in range(0, 510, 3):
        length, curve, width = block[at:at + 3]
        if not length:
            break
        assert width > 0
        original.extend([curve - 128] * length)
    assert original
    lengths.append(len(original))
    # 192 playable cells preserve the order and mean curvature of each course.
    samples = []
    for i in range(192):
        a = i * len(original) // 192
        b = max(a + 1, (i + 1) * len(original) // 192)
        samples.append(round(sum(original[a:b]) / (b - a)))
    out.extend(x & 255 for x in samples)
Path(__file__).with_name('tracks.bin').write_bytes(bytes(out))
print('wrote eight 192-cell tracks; original segment counts:', ', '.join(map(str, lengths)))
