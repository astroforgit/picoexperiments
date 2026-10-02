#!/usr/bin/env python3
"""Generate the native source-address CPU dispatch from the official ISA table.

This bridge executes source instructions without guessing which ROM bytes are
code, coordinates or pointers. py65 supplies build-time opcode metadata only;
the result runs on a real NMOS 6502 without a Python runtime.
"""
from py65.devices.mpu6502 import MPU
from build_source_engine import OUT

MODES = ('imp', 'acc', 'imm', 'zpg', 'zpx', 'zpy', 'abs', 'abx', 'aby', 'inx', 'iny', 'ind', 'rel')
SPECIAL = {'BRK', 'JSR', 'RTS', 'RTI', 'JMP', 'PHA', 'PHP', 'PLA', 'PLP',
           'TSX', 'TXS', 'CLI', 'SEI', 'CLD', 'SED',
           'BCC', 'BCS', 'BEQ', 'BNE', 'BMI', 'BPL', 'BVC', 'BVS'}
STORE = {'STA', 'STX', 'STY'}
RMW = {'ASL', 'LSR', 'ROL', 'ROR', 'INC', 'DEC'}


def build():
    cpu = MPU()
    native = {(name, mode): op for op, (name, mode) in enumerate(cpu.disassemble) if name != '???'}
    modes, operations, opcodes, access = [], [], [], []
    for op, (name, mode) in enumerate(cpu.disassemble):
        if name == '???':
            modes.append(0)
            operations.append('vm_illegal')
            opcodes.append(0xea)
            access.append(0)
            continue
        modes.append(MODES.index(mode))
        operations.append('vm_' + name.lower() if name in SPECIAL else 'vm_native_operation')
        opcodes.append(native.get((name, 'abs'), native.get((name, 'imp'), 0xea)))
        # bit 0: read memory, bit 1: write memory. Immediate/accumulator and
        # implied addressing have separate source/destination handling.
        access.append((int(name not in STORE) | (int(name in STORE | RMW) << 1))
                      if name not in SPECIAL and mode != 'imp' else 0)
    lines = ['; Generated ISA metadata; no runtime dependency on py65.']
    tables = {
        'vm_mode_table': modes, 'vm_native_table': opcodes, 'vm_access_table': access,
        'vm_cycle_table': cpu.cycletime, 'vm_extra_table': cpu.extracycles,
    }
    for label, values in tables.items():
        lines.append(label)
        for start in range(0,256,16):
            lines.append('        dta ' + ','.join(str(x) for x in values[start:start+16]))
    for label, names in (('vm_handler', operations), ('vm_address', ['vm_mode_'+m for m in MODES])):
        for part, prefix in (('lo','<'),('hi','>')):
            lines.append(label+'_'+part)
            for start in range(0,len(names),8):
                lines.append('        dta ' + ','.join(prefix+n for n in names[start:start+8]))
    OUT.mkdir(parents=True, exist_ok=True)
    (OUT/'cpu-tables.asm').write_text('\n'.join(lines)+'\n')
    print('Generated native dispatch for all 151 official source CPU opcodes.')


if __name__ == '__main__':
    build()
