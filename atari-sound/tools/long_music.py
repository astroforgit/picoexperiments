"""Streaming LZ compression for long PAL arrangements on a 64K Atari."""
from collections import defaultdict, deque
from pathlib import Path
import struct
import subprocess
import tempfile
import convert

ROOT = Path(__file__).resolve().parents[1]

def pack(raw):
    table = defaultdict(deque)
    output, literals = bytearray(), bytearray()
    def flush():
        if literals:
            output.append(len(literals)-1)
            output.extend(literals)
            literals.clear()
    p = 0
    while p < len(raw):
        key = raw[p:p+3]
        candidates = table[key]
        while candidates and candidates[0] < p-4096:
            candidates.popleft()
        length, distance = 0, 0
        for q in list(candidates)[-48:][::-1]:
            n = 0
            while n < 130 and p+n < len(raw) and raw[q+n] == raw[p+n]:
                n += 1
            if n > length:
                length, distance = n, p-q
        if length >= 4:
            flush()
            output.extend((128+length-3, distance & 255, distance >> 8))
        else:
            length = 1
            literals.append(raw[p])
            if len(literals) == 128:
                flush()
        for q in range(p, p+length):
            table[raw[q:q+3]].append(q)
        p += length
    flush()
    return bytes(output)

def unpack(raw):
    out = bytearray()
    p = 0
    while p < len(raw):
        token = raw[p]; p += 1
        if token < 128:
            n = token+1
            if p+n > len(raw): raise ValueError('Truncated literals')
            out.extend(raw[p:p+n]); p += n
        else:
            if p+2 > len(raw): raise ValueError('Truncated match')
            distance = int.from_bytes(raw[p:p+2], 'little'); p += 2
            if not 1 <= distance <= min(4096, len(out)): raise ValueError('Invalid distance')
            for _ in range((token & 127)+3): out.append(out[-distance])
    return bytes(out)

def build_player():
    base = (ROOT/'player/player.asm').read_text()
    base = base.replace('        lda #0\n        sta delay\n        sta stopped',
        '        jsr lz_reset\n        lda #0\n        sta delay\n        sta stopped')
    begin, end = base.index('getbyte ldy #0'), base.index('\npaused  dta')
    base = base[:begin]+(ROOT/'player/lz-reader.asm').read_text()+base[end:]
    base = base.replace('PATTERN', 'SECTION')
    base = base.replace('forward ldx selected','forward ldx current')
    base = base.replace('backward\n        ldx selected','backward\n        ldx current')
    with tempfile.TemporaryDirectory() as directory:
        d = Path(directory)
        (d/'long.asm').write_text(base)
        subprocess.run(['mads', str(d/'long.asm'), '-s', f'-o:{d}/long.obx', f'-t:{d}/long.lab'], check=True, capture_output=True)
        labels = {p[2].lower(): int(p[1], 16) for line in (d/'long.lab').read_text().splitlines() if len(p := line.split()) == 3}
        return (d/'long.obx').read_bytes(), labels

def export(folder, title, frames, sections, player, labels):
    data = bytearray(convert.HEADER)
    data[:6] = b'PMZ1\1'+bytes([len(sections)])
    data[8:48] = convert.screen_text(title)
    for i, section in enumerate(sections):
        start = section['frame']
        end = sections[i+1]['frame'] if i+1 < len(sections) else len(frames)
        encoded = convert.encode(frames[start:end])
        compressed = pack(encoded)
        assert unpack(compressed) == encoded
        address = convert.BASE+len(data)
        data[0x40+i] = i+1
        data[0x80+i] = (i+1) % len(sections)
        data[0xc0+i], data[0x100+i] = address & 255, address >> 8
        data.extend(compressed)
    if len(data) > 0x8000:
        # Fewer independently reset seek points let long repeated instrument
        # phrases share a dictionary, without truncating the arrangement.
        if len(sections)>1: return export(folder,title,frames,sections[::2],player,labels)
        raise ValueError(f'Long music exceeds 32K: {len(data)}')
    (folder/'REMIX.PMZ').write_bytes(data)
    binary = player+convert.segment(convert.BASE, data)
    # BASIC must be disabled before a segment crosses $A000.
    loader = b'\xff\xff'+convert.segment(0x2f00, bytes.fromhex('ad01d309028d01d360'))+convert.segment(0x2e2, struct.pack('<H', 0x2f00))
    (folder/'REMIX.XEX').write_bytes(loader+binary+convert.segment(0x2e0, struct.pack('<H', labels['start'])))
    seconds = len(frames)/convert.FPS
    header = (f'SAP\r\nAUTHOR "<?>"\r\nNAME "{title}"\r\nDATE "2026"\r\nTYPE B\r\n'
              f'INIT {labels["init"]:04X}\r\nPLAYER {labels["tick"]:04X}\r\n'
              f'TIME {int(seconds)//60:02}:{seconds%60:06.3f} LOOP\r\n')
    (folder/'remix.sap').write_bytes(header.encode()+binary)
    return len(data)
