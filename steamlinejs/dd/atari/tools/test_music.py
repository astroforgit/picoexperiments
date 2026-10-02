#!/usr/bin/env python3
"""Compare relocated music against the original SAP for more than one loop."""
from py65.devices.mpu6502 import MPU
from make_music import extract, relocated
from pathlib import Path

def call(cpu, address, a=0, x=0, y=0):
    cpu.a, cpu.x, cpu.y = a,x,y
    cpu.stPushWord(0x2ffe); cpu.pc=address
    for _ in range(30000):
        if cpu.pc == 0x2fff: return
        cpu.step()
    raise AssertionError(f'Player stuck: {cpu.pc:04x}')

def check():
    original, moved = MPU(), MPU()
    blocks = extract()
    # The supplied standalone XEX is packed. Execute only its depacker and
    # compare the recovered music/player, without running its OS takeover.
    packed=MPU(); data=(Path(__file__).resolve().parents[2]/'Double_Dragon_Industrial_A.xex').read_bytes()
    p=2
    while p<len(data):
        lo=int.from_bytes(data[p:p+2],'little'); hi=int.from_bytes(data[p+2:p+4],'little'); p+=4
        packed.memory[lo:hi+1]=data[p:p+hi-lo+1]; p+=hi-lo+1
    packed.pc=packed.memory[0x2e0]+256*packed.memory[0x2e1]
    for _ in range(200000):
        if packed.pc==0x100: break
        packed.step()
    else: raise AssertionError('Reference XEX did not unpack')
    for address,block in blocks.items():
        assert bytes(packed.memory[address:address+len(block)])==block
    for cpu, data in ((original,blocks),(moved,relocated(blocks))):
        for address, block in data.items(): cpu.memory[address:address+len(block)] = block
    call(original,0xc80); call(moved,0x600,y=0xa4)
    states=set()
    for tick in range(4000):
        call(original,0x603); call(moved,0x603)
        assert original.memory[0xd200:0xd209] == moved.memory[0xd200:0xd209], tick
        states.add(bytes(moved.memory[0xd200:0xd209]))
    assert len(states)>100
    assert not any(moved.memory[0x280:0x390]), 'player overwrote OS workspace'
    print('Original SAP vs relocated player: 4000 identical POKEY frames, OS workspace preserved: PASS')
    from test_runtime import Machine, LABELS
    if 'music_vbi' not in LABELS:
        print('Music integration disabled in current game; reference checks only.')
        return
    from copy import deepcopy
    base=Machine()
    for rate in (50,60):
        m=deepcopy(base); m.call('restart'); m.set('rate',rate)
        zp=bytes(m.mem.ram[0xcb:0xde]); os=bytes(m.mem.ram[0x280:0x390])
        reference=MPU()
        for address,block in blocks.items(): reference.memory[address:address+len(block)]=block
        call(reference,0xc80)
        for _ in range(120):
            saved=(m.cpu.a,m.cpu.x,m.cpu.y,m.cpu.sp,m.cpu.p&0xcf)
            m.vblank(); call(reference,0x603)
            assert (m.cpu.a,m.cpu.x,m.cpu.y,m.cpu.sp,m.cpu.p&0xcf)==saved
            assert list(m.mem.ram[0xd200:0xd209])==reference.memory[0xd200:0xd209]
        assert bytes(m.mem.ram[0xcb:0xde]) == zp
        assert bytes(m.mem.ram[0x280:0x390]) == os
        state=bytes(m.mem.ram[0xa280:0xa390])
        m.mem.ram[0x14]=(m.mem.ram[0x14]+4)&255
        m.call('frame_time')
        assert bytes(m.mem.ram[0xa280:0xa390]) == state, 'render catch-up advanced music'
        for mode, muted in ((2,0),(0,0),(3,0),(4,0),(1,1)):
            m.set('mode',mode); m.set('muted',muted)
            state=bytes(m.mem.ram[0xa280:0xa390])
            m.vblank()
            assert all(m.mem.ram[a]==0 for a in (0xd201,0xd203,0xd205,0xd207))
            assert bytes(m.mem.ram[0xa280:0xa390]) == state
        m.set('mode',1); m.set('muted',0); m.vblank()
        assert any(m.mem.ram[a] for a in (0xd201,0xd203,0xd205,0xd207))
        m.call('restart')
        fresh=deepcopy(base); fresh.call('restart')
        assert m.mem.ram[0xa280:0xa390] == fresh.mem.ram[0xa280:0xa390]
        m.set('music_busy',1)
        state=bytes(m.mem.ram[0xa280:0xa390]); m.vblank()
        assert bytes(m.mem.ram[0xa280:0xa390])==state
        m.set('music_busy',0)
    # Drive real renderer instructions with periodic NMIs, including while it
    # is using zero-page pointers. Long rendering cannot bunch player calls.
    m=deepcopy(base); m.call('restart'); m.set('rate',60)
    period=114*262; deadline=m.cpu.processorCycles+period; times=[]
    for _ in range(12):
        m.cpu.stPushWord(0x5fe); m.cpu.pc=LABELS['render']
        for step in range(300000):
            if m.cpu.pc==0x5ff: break
            if m.cpu.processorCycles>=deadline:
                times.append(m.cpu.processorCycles); m.vblank(); deadline+=period
            else: m.cpu.step()
        else: raise AssertionError('Renderer stalled under music interrupts')
    assert len(times)>=12
    assert all(abs(b-a-period)<8 for a,b in zip(times,times[1:]))
    print('Supplied RMT/XEX agree; VBI output matches SAP; register/OS/ZP safety, init lock, pause/mute/restart, regular updates during rendering: PASS')

if __name__ == '__main__': check()
