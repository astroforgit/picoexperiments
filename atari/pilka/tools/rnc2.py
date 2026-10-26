# SPDX-License-Identifier: GPL-3.0-or-later
# RNC method 2 decoder adapted from ScummVM's RncDecoder::unpackM2.
# Copyright ScummVM developers; Python adaptation 2026.
# https://github.com/scummvm/scummvm/blob/master/common/compression/rnc_deco.cpp
# Distributed without warranty under GNU GPL version 3 or later:
# https://www.gnu.org/licenses/gpl-3.0.html
import struct


def crc16(data):
    crc = 0
    for byte in data:
        crc ^= byte
        for _ in range(8):
            crc = (crc >> 1) ^ (0xa001 if crc & 1 else 0)
    return crc


def unpack(data):
    if len(data) < 18 or data[:4] != b'RNC\x02':
        raise ValueError('Expected RNC method 2')
    size, packed, raw_crc, packed_crc = struct.unpack('>IIHH', data[4:16])
    src = data[18:18 + packed]
    if len(src) != packed or crc16(src) != packed_crc:
        raise ValueError('Packed size/CRC mismatch')
    pos = bits = count = 0
    out = bytearray()

    def byte():
        nonlocal pos
        if pos >= len(src):
            raise ValueError('Truncated RNC stream')
        value = src[pos]
        pos += 1
        return value

    def bit():
        nonlocal bits, count
        if count == 0:
            bits, count = byte(), 8
        value = (bits >> 7) & 1
        bits <<= 1
        count -= 1
        return value

    def emit(value):
        if len(out) >= size:
            raise ValueError('Output exceeds declared size')
        out.append(value)

    bit(); bit()
    while True:
        while bit() == 0:
            emit(byte())
        length, high, load = 2, 0, False
        if bit() == 0:
            length = (length << 1) | bit()
            if bit():
                length = ((length - 1) << 1) | bit()
                if length == 9:
                    for _ in range(4):
                        high = (high << 1) | bit()
                    for _ in range((high + 3) * 4):
                        emit(byte())
                    continue
            load = True
        elif bit():
            length += 1
            if bit():
                length = byte()
                if length == 0:
                    if bit():
                        continue
                    break
                length += 8
            load = True
        if load and bit():
            high = bit()
            if bit():
                high = ((high << 1) | bit()) | 4
                if bit() == 0:
                    high = (high << 1) | bit()
            elif high == 0:
                high = 2 | bit()
        distance = (high << 8) + byte() + 1
        if distance > len(out):
            raise ValueError('Invalid back-reference')
        for _ in range(length):
            emit(out[-distance])
    if len(out) != size or crc16(out) != raw_crc:
        raise ValueError('Unpacked size/CRC mismatch')
    return bytes(out)
