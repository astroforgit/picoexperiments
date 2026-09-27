#!/usr/bin/env python3
"""Unpack SPEEDmaza.xex by running its own depacker in a 6502 emulator.

The original XEX is one compressed block at $2000-$5784 plus a tiny INIT stub
at $5800. The depacker at $2000 copies itself to zero page / stack page,
unpacks the program to $0FFE-$BBFF and finally jumps to the Action! entry
point $433B. We emulate it with py65 until PC reaches $433B and dump RAM.

Usage: python3 unpack.py ORIGINAL.xex OUT_IMAGE.bin
Needs: pip install py65
"""
import sys
from py65.devices.mpu6502 import MPU

ENTRY = 0x433B          # Action! main PROC reached after unpacking


def segments(data):
    i = 0
    while i < len(data):
        if data[i:i + 2] == b"\xff\xff":
            i += 2
        start = data[i] | data[i + 1] << 8
        end = data[i + 2] | data[i + 3] << 8
        i += 4
        yield start, data[i:i + end - start + 1]
        i += end - start + 1


def main():
    src, out = sys.argv[1], sys.argv[2]
    mpu = MPU()
    for start, blob in segments(open(src, "rb").read()):
        if start >= 0x2000 and start < 0x5800:      # packed program only
            mpu.memory[start:start + len(blob)] = list(blob)
    mpu.pc, mpu.sp = 0x2000, 0xFF
    steps = 0
    while mpu.pc != ENTRY:
        mpu.step()
        steps += 1
        if steps > 20_000_000:
            sys.exit("depacker did not reach $433B")
    open(out, "wb").write(bytes(mpu.memory[:0x10000]))
    print(f"unpacked in {steps} instructions -> {out}")


if __name__ == "__main__":
    main()
