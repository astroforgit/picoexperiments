# SPDX-License-Identifier: GPL-3.0-or-later
# Adapted from ScummVM RncDecoder (Copyright ScummVM developers).
# https://github.com/scummvm/scummvm/blob/master/common/compression/rnc_deco.cpp
# GNU GPL v3 or later; no warranty. https://www.gnu.org/licenses/gpl-3.0.html
import struct
from rnc2 import crc16


def unpack(data):
    if len(data) < 18 or data[:4] != b'RNC\x01':
        raise ValueError('Expected RNC method 1')
    size, packed, raw_crc, packed_crc = struct.unpack('>IIHH', data[4:16])
    src = data[18:18 + packed]
    if len(src) != packed or crc16(src) != packed_crc:
        raise ValueError('Packed size/CRC mismatch')
    pos, count, high = 0, 0, 0
    out = bytearray()

    def word(p):
        return int.from_bytes(src[p:p+2], 'little')

    low = word(0)

    def bits(n):
        nonlocal pos, count, low, high
        result = low & ((1 << n) - 1)
        left = count - n
        if left < 0:
            low = (low >> count) | ((high << (16 - count)) & 65535)
            high >>= count
            pos += 2
            if pos > len(src) + 2:
                raise ValueError('Truncated bitstream')
            high = word(pos)
            n -= count
            left = 16 - n
        low = ((low >> n) | ((high << (16 - n)) & 65535)) & 65535
        high >>= n
        count = left
        return result

    def table():
        lengths = [bits(4) for _ in range(bits(5))]
        code = 0
        entries = []
        for width in range(1, 17):
            for symbol, length in enumerate(lengths):
                if length == width:
                    value = code >> (16 - width)
                    reverse = int(f'{value:0{width}b}'[::-1], 2)
                    entries.append((width, reverse, symbol))
                    code += 1 << (16 - width)
        return entries

    def value(entries):
        for width, code, symbol in entries:
            if low & ((1 << width) - 1) == code:
                bits(width)
                return symbol if symbol < 2 else (1 << (symbol - 1)) | bits(symbol - 1)
        raise ValueError('Invalid Huffman symbol')

    bits(2)
    for _ in range(data[17]):
        raw, offsets, lengths = table(), table(), table()
        runs = bits(16)
        for run in range(runs):
            length = value(raw)
            if length and (pos + length > len(src) or len(out) + length > size):
                raise ValueError('Invalid literal length')
            if length:
                out.extend(src[pos:pos+length]); pos += length
                a, b = word(pos), word(pos + 2)
                low = (low & ((1 << count) - 1)) | ((a << count) & 65535)
                high = ((a >> (16 - count)) | (b << count)) & 65535
            if run < runs - 1:
                distance, length = value(offsets) + 1, value(lengths) + 2
                if distance > len(out) or len(out) + length > size:
                    raise ValueError('Invalid back-reference')
                for _ in range(length):
                    out.append(out[-distance])
    if len(out) != size or crc16(out) != raw_crc:
        raise ValueError('Unpacked size/CRC mismatch')
    return bytes(out)
