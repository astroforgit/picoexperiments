"""Validate actual XDL palette selection, which the shared emulator ignores.

VBXE FX 1.26 manual p.11: XDLC_ATT bits 5:4 choose overlay palette;
bits 1:0 choose width. Do not use Atari.screenshot for this regression.
"""
from pathlib import Path
import sys
import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT.parents[1] / 'lair/tools'))
from emu import Atari

expected = np.array(Image.open(ROOT / 'assets/editor-base.png').getpalette(), dtype=np.uint8).reshape(256, 3)
for page in (0xD6, 0xD7):
    a = Atari(ROOT / 'star-fisher.xex', vbxe_page=page)
    a.boot()
    a.run_frames(15)
    for offset, framebuffer in ((0, 0x20000), (16, 0x40000)):
        xdl = bytes(a.vram[0x7E000 + offset:0x7E000 + offset + 10])
        assert xdl[:3] == bytes([0x62, 0x88, 239]), 'Expected 240-line SR display with attributes'
        assert int.from_bytes(xdl[3:6], 'little') == framebuffer
        assert int.from_bytes(xdl[6:8], 'little') == 320
        palette_index = (xdl[8] >> 4) & 3
        assert xdl[8] & 3 == 1, 'Expected normal 320px width'
        assert palette_index == 1, f'XDL selects palette {palette_index}; artwork is uploaded to palette 1'
        assert np.array_equal(a.palette[palette_index], expected), 'Displayed RGB palette must match editor'
    # Render from the palette actually selected by the active display list.
    address = int(a.vregs[0x41]) | int(a.vregs[0x42]) << 8 | int(a.vregs[0x43]) << 16
    xdl = bytes(a.vram[address:address + 10])
    base = int.from_bytes(xdl[3:6], 'little')
    pixels = a.vram[base:base + 76800].reshape(240, 320)
    rgb = a.palette[(xdl[8] >> 4) & 3][pixels]
    output = ROOT / 'screenshots' / f'palette-fixed-{page:02x}.png'
    output.parent.mkdir(exist_ok=True)
    Image.fromarray(rgb).resize((960, 720), Image.Resampling.NEAREST).save(output)
print('PASS both XDL buffers select uploaded RGB palette, exact editor colours, D640 and D740')
