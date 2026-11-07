#!/usr/bin/env python3
"""Extract and unpack the supplied Arlasoft Soccer disk. Requires py65.

This is analysis tooling, not an Atari build. No sibling project is modified.
The unpacker endpoint is specific to the supplied ARLASOC program.
"""
from pathlib import Path
import hashlib
import json
from py65.devices.mpu6502 import MPU
from py65.disassembler import Disassembler

ROOT = Path(__file__).resolve().parents[1]
SPT = [21] * 17 + [19] * 7 + [18] * 6 + [17] * 5


def sector(disk, track, sec):
    if not 1 <= track <= len(SPT) or not 0 <= sec < SPT[track - 1]:
        raise ValueError(f'Invalid D64 sector {track}/{sec}')
    start = (sum(SPT[:track - 1]) + sec) * 256
    data = disk[start:start + 256]
    if len(data) != 256:
        raise ValueError('Truncated D64')
    return data


def chain(disk, track, sec):
    seen = set()
    while track:
        if (track, sec) in seen:
            raise ValueError('Cyclic D64 chain')
        seen.add((track, sec))
        data = sector(disk, track, sec)
        yield data
        track, sec = data[:2]


def main():
    disk = (ROOT / 'arlasoc.d64').read_bytes()
    out = ROOT / 'analysis'
    out.mkdir(exist_ok=True)
    entries = []
    program = None
    for block in chain(disk, 18, 1):
        for pos in range(0, 256, 32):
            entry = block[pos:pos + 32]
            if not entry[2]:
                continue
            name = entry[5:21].rstrip(b'\xa0').decode('latin1')
            payload = bytearray()
            for data in chain(disk, entry[3], entry[4]):
                if data[0] == 0 and data[1] == 0:
                    raise ValueError('Invalid final sector length')
                payload.extend(data[2:] if data[0] else data[2:data[1] + 1])
            entries.append({'name': name, 'type': entry[2], 'bytes': len(payload),
                            'sha256': hashlib.sha256(payload).hexdigest()})
            if name == 'ARLASOC' and entry[2] & 7 == 2:
                program = payload
    if program is None:
        raise ValueError('ARLASOC PRG missing')
    if not program.startswith(bytes.fromhex('01080b081e009e32303631000000')):
        raise ValueError('Unexpected BASIC loader; unpacker requires review')
    (out / 'arlasoc.prg').write_bytes(program)
    cpu = MPU()
    start = int.from_bytes(program[:2], 'little')
    cpu.memory[start:start + len(program) - 2] = program[2:]
    cpu.memory[1] = 0x37
    cpu.pc = 2061  # BASIC SYS 2061
    for steps in range(3_000_000):
        if cpu.pc == 0x01c2:
            if bytes(cpu.memory[0x1c2:0x1c5]) == bytes.fromhex('4c5b97'):
                cpu.step()
                break
        if cpu.memory[cpu.pc] == 0 or cpu.disassemble[cpu.memory[cpu.pc]][0] == '???':
            raise ValueError(f'Unexpected opcode at ${cpu.pc:04x}')
        cpu.step()
    else:
        raise ValueError('Unpacker instruction limit exceeded')
    ram = bytes(cpu.memory)
    (out / 'unpacked-64k.bin').write_bytes(ram)
    dis = Disassembler(cpu)
    pc = cpu.pc
    listing = []
    for _ in range(96):
        size, instruction = dis.instruction_at(pc)
        listing.append(f'{pc:04X}  {ram[pc:pc + size].hex(" "):8}  {instruction}')
        pc += size
    (out / 'entry-disassembly.txt').write_text('\n'.join(listing) + '\n')
    result = {'disk_sha256': hashlib.sha256(disk).hexdigest(), 'files': entries,
              'entry': cpu.pc, 'instructions_to_entry': steps + 1,
              'cpu': {key: getattr(cpu, key) for key in ('pc', 'a', 'x', 'y', 'sp', 'p')},
              'ram_sha256': hashlib.sha256(ram).hexdigest(),
              'note': 'RAM captured after decompression, before game initialization. Not an emulator save state or Atari executable.'}
    (out / 'manifest.json').write_text(json.dumps(result, indent=2) + '\n')
    print(f'Extracted ARLASOC: {len(program)} bytes; entry ${cpu.pc:04X}; {steps + 1} instructions')


if __name__ == '__main__':
    main()
