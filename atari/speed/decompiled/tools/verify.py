#!/usr/bin/env python3
"""Check that the rebuilt XEX loads exactly the bytes of the unpacked image.

Usage: python3 verify.py REBUILT.xex IMAGE.bin
Every byte loaded from $0FFE-$BBFF must equal the image; every byte of the
image in that range that is NOT loaded must be zero (the game builds the maze,
display list and PM area there at run time).
"""
import sys

xex = open(sys.argv[1], "rb").read()
img = open(sys.argv[2], "rb").read()
loaded = {}
i = 0
while i < len(xex):
    if xex[i:i + 2] == b"\xff\xff":
        i += 2
    s = xex[i] | xex[i + 1] << 8
    e = xex[i + 2] | xex[i + 3] << 8
    i += 4
    for k in range(e - s + 1):
        loaded[s + k] = xex[i + k]
    i += e - s + 1

bad = [a for a in range(0x0FFE, 0xBC00)
       if (a in loaded and loaded[a] != img[a]) or (a not in loaded and img[a])]
if bad:
    print(f"MISMATCH at {len(bad)} bytes, first ${bad[0]:04X}")
    sys.exit(1)
n = sum(1 for a in loaded if 0x0FFE <= a < 0xBC00)
print(f"OK: {n} loaded bytes match the unpacked image; the rest of $0FFE-$BBFF is zero")
