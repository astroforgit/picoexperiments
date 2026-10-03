"""Read Agent USA's XEX and rebuild the RAM image the game starts with."""

LOAD_START, LOAD_END = 0x21FF, 0xB87F   # the one big segment
RELOC_SRC, RELOC_DST, RELOC_LEN = 0x2200, 0x0800, 0x0810
RUN = 0x2AA0


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
    """Return (image, ram).

    image is memory right after loading: one segment at $21FF-$B87F, a
    single byte $A7 at $0000, RUN $2AA0.

    ram is memory when the game proper starts at $2D1E: the stub at $2AA0
    clears $0400-$21FF and copies $2200-$2AFF to $0800-$10FF; the stub at
    $B800 then clears $1010-$2A1F. So $0800-$100F holds what the file had
    at $2200-$2A0F, and everything from $2A20 up is as loaded."""
    d = open(path, 'rb').read()
    image = bytearray(0x10000)
    run = None
    for s, blk, _ in segments(d):
        if s == 0x02E0:
            run = blk[0] | blk[1] << 8
        else:
            image[s:s + len(blk)] = blk
    assert run == RUN
    ram = bytearray(image)
    ram[0x0400:0x2200] = bytes(0x1E00)
    ram[RELOC_DST:RELOC_DST + 0x900] = image[RELOC_SRC:RELOC_SRC + 0x900]
    ram[0x1010:0x2A20] = bytes(0x2A20 - 0x1010)
    return image, ram
