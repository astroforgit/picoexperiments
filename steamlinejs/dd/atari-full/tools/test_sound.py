"""Run every sound command through the original driver and Atari converter."""
from pathlib import Path
import sys
from atari_emu import Atari, load_labels
ROOT = Path(__file__).resolve().parents[1]
a = Atari(ROOT / 'double-dragon.xex', pal='--ntsc' not in sys.argv); a.boot(); a.run_frames(60)
a.nmien = 0; a.memb = 0; a.mems = 0x94
lab = load_labels(ROOT / 'gen/runtime.lab'); r = a.mem.ram
bank = bytes(a.vram[5*0x4000:6*0x4000])
effects = songs = 0
for command in range(1, 44):
    a.cpu.a = 0; a.call(0x8000)
    a.call(lab['RESET_2A03_AUDIO'])
    a.cpu.a = command; a.call(0x8000)
    pointer = int.from_bytes(bank[(command-1)*2+0x800:(command-1)*2+0x802], 'little')
    music = bank[pointer-0x8000] == 255
    heard = False
    for tick in range(180):
        a.call(0x8003)
        a.call(lab['CONVERT_AUDIO'])
        assert not any(r[0x70D:0x711]), (command, 'music track active')
        audible = any(a.pokey[i] & 15 for i in (1,3,5,7))
        heard |= audible
        if music:
            assert not audible, (command, tick, 'music audible')
        for channel in range(4):
            if not r[0x711+channel]:
                assert not a.pokey[1+channel*2] & 15, (command, tick, 'stuck channel')
    if music:
        songs += 1
    else:
        assert heard, (command, 'effect silent')
        effects += 1
    a.cpu.a = 255; a.call(0x8000); a.call(lab['CONVERT_AUDIO'])
    assert not any(a.pokey[i] & 15 for i in (1,3,5,7)), (command, 'stop did not silence')
# Cost of a completely idle conversion, including call/return.
start = a.cpu.processorCycles
for _ in range(100): a.call(lab['CONVERT_AUDIO'])
print(f'{effects} effect commands audible; {songs} music commands silent; stop/tails passed')
print(f'Idle audio conversion: {(a.cpu.processorCycles-start)//100} CPU cycles')
