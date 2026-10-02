"""Read Zorro's XEX and rebuild the RAM image the game starts with."""


def segments(d):
    """Yield (start, bytes, has_ffff_header) for each segment of an XEX file."""
    i = 0
    while i < len(d):
        hdr = d[i:i + 2] == b'\xff\xff'
        if hdr:
            i += 2
        s = d[i] | d[i + 1] << 8
        e = d[i + 2] | d[i + 3] << 8
        i += 4
        yield s, d[i:i + e - s + 1], hdr
        i += e - s + 1


def load(path):
    """Return (ram, loaded) as the Atari would have them at JMP $0480.

    The original file has no compression. Each 2.5 KB chunk loaded at $4000
    is copied by the INIT routine at $8012 into the RAM under the OS ROM
    ($D800-$FFFF, $C000-$CEFF). The RUN routine at $5000 then moves
    $1480-$4D7F down to $0480. loaded[a] is 1 for every byte that holds a
    value from the file.
    """
    d = open(path, 'rb').read()
    ram = bytearray(0x10000)
    loaded = bytearray(0x10000)
    run = None
    for s, blk, _ in segments(d):
        if s == 0x02E2:                     # INIT -> the chunk copier at $8012
            assert blk == b'\x12\x80'
            x = ram[0x90]
            dst, end, src = ram[0x8000 + x], ram[0x8006 + x], ram[0x800C + x]
            n = (end - src) * 256
            ram[dst * 256:dst * 256 + n] = ram[src * 256:src * 256 + n]
            loaded[dst * 256:dst * 256 + n] = b'\1' * n
            ram[0x90] = x + 1
        elif s == 0x02E0:
            run = blk[0] | blk[1] << 8
        else:
            ram[s:s + len(blk)] = blk
            loaded[s:s + len(blk)] = b'\1' * len(blk)
    assert run == 0x5000
    ram[0x0480:0x3D80] = ram[0x1480:0x4D80]  # what the RUN stub does
    loaded[0x0480:0x3D80] = b'\1' * 0x3900
    ram[0x90] = 0
    return ram, loaded
