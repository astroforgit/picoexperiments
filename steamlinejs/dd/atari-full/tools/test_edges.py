"""Exercise cached sprite slots at all four edges and after hiding/flipping."""
from pathlib import Path
import numpy as np
from atari_emu import Atari, load_labels

ROOT = Path(__file__).resolve().parents[1]
a = Atari(ROOT / 'double-dragon.xex')
a.boot()
r = a.mem.ram
lab = load_labels(ROOT / 'gen/runtime.lab')
# Stop immediately after startup cache initialisation, before game bank changes.
for _ in range(2_000_000):
    if a.cpu.pc == lab['GI_EF']:
        break
    a.cpu.step()
else:
    raise AssertionError('startup did not initialise sprite caches')
assert all(value == 0x30 for value in r[0xF00:0xF80]), 'unexpanded tile zero marked valid'
a.run_frames(60)
a.nmien = 0
# Initialise lists and caches as startup does, without relying on game OAM.
for back in (0, 1):
    a.cpu.a = 0x80 | ((0x2F000 if back == 0 else 0x4F000) >> 14)
    a.cpu.x = back
    a.call(lab['INIT_LIST'])
r[0xE00:0x1000] = bytes(512)
r[0xF00:0xF80] = bytes([0x30]) * 128
r[0x3980:0x3A80] = bytes([1]) * 256
pattern = np.arange(64, dtype=np.uint8).reshape(8, 8) % 4
for tile in range(256):
    a.vram[0x7C000 + tile*64:0x7C000 + (tile+1)*64] = np.where(pattern, pattern | 0xFC, 0).ravel()
count = 0
for back in (0, 1):
    r[lab['BACK']] = back
    a.memb = 0x80 | ((0x2F000 if back == 0 else 0x4F000) >> 14)
    fb = 0x40000 + back * 0x10000
    for x, y in [(x,y) for x in (0,1,247,248,249,254,255) for y in (0,1,230,231,232,233,238,239,255)]:
        for attr in (0, 0x40, 0x80, 0xC3, 0x20, 0):
            r[0x200:0x300] = bytes([255,0,0,0]) * 64
            r[0x2FC:0x300] = bytes([y, 0, attr, x])
            r[lab['C_MASK']] = 0x10
            a.vram[fb:fb+240*256] = 0x20
            guard = a.vram[fb+240*256:fb+241*256].copy()
            a.call(lab['EMIT_SPRITES'])
            start = (0x2F000 if back == 0 else 0x4F000) + lab['SPR0'] * 21
            a.vregs[0x50:0x53] = start.to_bytes(3, 'little')
            a.blit_list()
            expected = np.full((256,256), 0x20, dtype=np.uint8)
            if y < 239 and not attr & 0x20:
                pixels = pattern[::-1 if attr & 0x80 else 1, ::-1 if attr & 0x40 else 1]
                for dy in range(min(8,239-y)):
                    for dx in range(min(8,256-x)):
                        if pixels[dy,dx]:
                            expected[y+1+dy,x+dx] = 0x10 | ((attr & 3)*4) | int(pixels[dy,dx])
            got = a.vram[fb:fb+65536].reshape(256,256)
            # The next row of FB0 contains list 1: clipped sprites must not touch it.
            assert np.array_equal(got[240], guard), (back,x,y,attr, "guard overwritten")
            assert np.array_equal(got[:240], expected[:240]), (back,x,y,attr,np.argwhere(got[:241] != expected[:241])[:8])
            count += 1
print(f'{count} sprite edge/cache cases passed, including framebuffer guard row')

# A newly requested tile must defer presentation, never expose old VRAM pixels.
r[lab['BACK']] = 1
r[lab['C_MEMB']] = a.memb = 0x93
r[lab['OBJ_BANK']] = 0
r[lab['BUDGET']] = 0
r[0x3980] = 0
r[0xF40] |= 0x10
r[0x2FC:0x300] = bytes([238, 0, 0, 255])
a.call(lab['EMIT_SPRITES'])
assert r[lab['ES_MISSING']] == 1, 'missing bottom-right tile was not deferred'
r[lab['BUDGET']] = 1
a.call(lab['EMIT_SPRITES'])
assert r[lab['ES_MISSING']] == 0 and r[0x3980] == 1
print('Bottom-right tile loading defers the frame until graphics are ready')
