#!/usr/bin/env python3
"""Boot with inherited PIA output/DDR states; check both actual VBI inputs."""
from pathlib import Path
import sys
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'tools/reference'))
from atari_emu import Atari,load_labels
r=load_labels(ROOT/'gen/runtime.asm.lab')
for page,control,ddr,latch in ((0xd6,0x3c,0x44,0), (0xd7,0x38,0xff,0), (0xd6,0x34,0,0xff)):
    a=Atari(ROOT/'pilka.xex',vbxe_page=page)
    a.pactl=control;a.porta_ddr=ddr;a.porta_output=latch
    if control==0x3c:
        assert a.mem[0xd300]==0xbb, 'Released sticks should expose inherited stuck-left outputs'
    a.boot()
    for _ in range(2_000_000):
        if a.cpu.pc==0x975b:break
        a.cpu.step()
    else:raise AssertionError('Startup did not finish')
    assert a.porta_ddr==0 and a.pactl==(control|4)
    assert a.mem[0xd300]==0xff, 'Released sticks must be neutral'
    a.next_frame=a.cpu.processorCycles+a.frame_cycles
    a.run_frames(24)
    for stick1,stick2,fire1,fire2 in ((15,15,1,1),(11,15,1,1),(15,11,1,1),(7,14,1,1),(15,15,0,1),(15,15,1,0),(15,15,1,1)):
        a.in_stick=stick1;a.in_stick1=stick2;a.in_trig0=fire1;a.in_trig1=fire2
        a.run_frames(2)
        assert a.mem.ram[r['JOY1']]==stick1|(fire1<<4)
        assert a.mem.ram[r['JOY2']]==stick2|(fire2<<4)
    print(f'PASS ${page:02x}: inherited PACTL=${control:02x}, DDRA=${ddr:02x}; neutral, directions, fire and release on both ports',flush=True)
