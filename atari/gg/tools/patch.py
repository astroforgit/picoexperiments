#!/usr/bin/env python3
"""Turn the code map's I/O and KERNAL references into patches and stubs.

Every instruction with an absolute operand in $D000-$DFFF is either
retargeted (same instruction, operand moved to the runtime's shadow of the
chip register) or replaced by JSR to a stub that emulates it:

  VIC $D000-$D3FF   -> shadow $DE00 + (reg & $3F); reads of $D011/$D012
                       (raster) go through get_d011/get_d012
  SID $D400-$D7FF   -> shadow $DF00 + (reg & $1F); stores to a control
                       register or indexed stores also record gate changes;
                       reads of $D41B/$D41C return random values
  colour RAM        -> stores happen as they are and mark the colour dirty
  CIA1 $DC00/$DC01  -> reads through get_dc00/get_dc01 (joystick, keyboard)
  other CIA         -> unchanged (plain RAM on the Atari)
  KERNAL            -> JSR/JMP to the runtime's replacements

plus the hooks into the game (idle wait, playfield draw, loader).

Writes gen/stubs.asm and gen/patchlist.json: {unit: [[addr, [bytes or
'label' / 'label+n' / '<label' / '>label']]]}.
"""
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from dis6502 import OPS  # noqa: E402

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
GEN = os.path.join(HERE, 'gen')

READS = {'lda', 'ldx', 'ldy', 'cmp', 'cpx', 'cpy', 'bit', 'and', 'ora', 'eor', 'adc', 'sbc'}
STORES = {'sta', 'stx', 'sty'}
RMW = {'inc', 'dec', 'asl', 'lsr', 'rol', 'ror'}
KERNAL = {0xFFD2: 'k_chrout', 0xFFF0: 'k_plot', 0xFFE4: 'k_getin', 0xFF9F: 'k_scnkey'}
KEXIT = {0xEA31, 0xEA81, 0xFEBC}

# loader and decruncher hooks (entry image); see src/loader.asm
LOADER = [
    (0x55DE, 0x4C, 'ldr_entry'),
    (0x5659, 0x4C, 'ldr_get'),
    (0x552F, 0x20, 'ls_store'),
    (0x5529, 0x20, 'lf_fetch'),
    (0x55CE, 0x8D, 'ls_op+1'),
    (0x55D4, 0x8D, 'ls_op+2'),
    (0x55AC, 0x8D, 'lf_op+1'),
    (0x55B8, 0x8D, 'lf_op+2'),
    (0x5523, 0xCE, 'lf_op+2'),
]
LOADER_DEAD = range(0x55DE, 0x5760)       # the replaced serial loader
HOOKS = [
    (0x3AB4, 0x4C, 'idle_wait', b'\xad\x00\x07'),
    (0x386A, 0x4C, 'hook_scroll', b'\x4c\xd0\x00'),
    (0x5BCA, 0x4C, 'hook_swap', b'\xa0\x00\xae'),     # block swap (charsets)
]
# stores into charset memory: level set-up and the IRQ's animated characters
CHARSET_STORES = {0x5C2B: 'cs_mark',
                  0x3B59: 'anim_mark1', 0x3B5D: 'anim_mark1',
                  0x3B73: 'anim_mark2', 0x3B77: 'anim_mark2'}

MODE_SUFFIX = {'abs': '', 'abx': ',x', 'aby': ',y'}


def word(w):
    return [f'<{w}', f'>{w}']


class Stubs:
    def __init__(self):
        self.code = []
        self.names = {}

    def get(self, key, body):
        if key not in self.names:
            name = f's{len(self.names):03d}'
            self.names[key] = name
            self.code.append(f'{name}' + body)
        return self.names[key]


def raster_wait(mem, pc, stubs):
    """A busy wait for one raster line at pc -> JSR to a wait_line stub, else None."""
    op = mem[pc]
    w = mem[pc + 1] | mem[pc + 2] << 8
    if w != 0xD012:
        return None

    def back(at):                    # BNE at 'at' jumping to pc (or pc-2 for lda #n first)
        off = mem[at + 1]
        return mem[at] == 0xD0 and (at + 2 + (off - 256 if off > 127 else off)) & 0xFFFF

    if op == 0xAD and back(pc + 3) == pc:                       # lda $d012 / bne
        s = stubs.get(('w', 0), '\n        lda #0\n        jsr wait_line\n        lda #0\n        rts')
        return [0x20] + word(s)
    if op == 0xAD and mem[pc + 3] == 0xC9 and back(pc + 5) == pc:  # lda $d012 / cmp #n / bne
        n = mem[pc + 4]
        s = stubs.get(('w', n), f'\n        lda #${n:02X}\n        jsr wait_line\n        lda #${n:02X}\n        rts')
        return [0x20] + word(s)
    if op == 0xCD and back(pc + 3) in (pc, pc - 2):              # (lda #n /) cmp $d012 / bne
        s = stubs.get(('wa',), '\n        jsr wait_line\n        cmp wl_n\n        rts')
        return [0x20] + word(s)
    return None


def classify(mem, pc, stubs):
    """-> list of patch byte values for the 3 bytes at pc, or None (leave)."""
    op = mem[pc]
    name, mode = OPS[op]
    w = mem[pc + 1] | mem[pc + 2] << 8
    if not 0x5800 <= pc < 0x5B00:            # (the multiplexer's compares run in the IRQ chain)
        wt = raster_wait(mem, pc, stubs)
        if wt:
            return wt
    sfx = MODE_SUFFIX.get(mode)
    if name in ('jsr', 'jmp') and w >= 0xE000:
        if w in KERNAL:
            return [op] + word(KERNAL[w])
        if name == 'jmp' and w in KEXIT:
            return [op] + word('k_exit')
        if w == 0xFFFF:
            return None                       # self-modified call site
        raise SystemExit(f'${pc:04X}: unknown KERNAL {name} ${w:04X}')
    if 0xD000 <= w < 0xD400:
        reg = w & 0x3F
        if name in READS and reg in (0x11, 0x12):
            assert mode == 'abs', f'${pc:04X}: indexed raster read'
            fn = 'get_d011' if reg == 0x11 else 'get_d012'
            s = stubs.get(('r', fn, name), f'\n        jsr {fn}\n        {name} rv\n        rts')
            return [0x20] + word(s)
        return [op] + word(f'VIC+${reg:02X}')
    if 0xD400 <= w < 0xD800:
        reg = w & 0x1F
        if name in READS and reg in (0x1B, 0x1C):
            assert mode == 'abs'
            s = stubs.get(('rnd', name), f'\n        jsr get_rnd\n        {name} rv\n        rts')
            return [0x20] + word(s)
        if name in STORES and (mode != 'abs' or reg in (4, 11, 18)):
            tgt = f'SID+${reg:02X}{sfx}'
            s = stubs.get(('g', name, reg, mode), f'''
        {name} {tgt}
        php
        pha
        lda {tgt}
        ora gor+${reg:02X}{sfx}
        sta gor+${reg:02X}{sfx}
        lda {tgt}
        and gand+${reg:02X}{sfx}
        sta gand+${reg:02X}{sfx}
        pla
        plp
        rts''')
            return [0x20] + word(s)
        return [op] + word(f'SID+${reg:02X}')
    if 0xD800 <= w < 0xDC00:
        if name in STORES or name in RMW:
            s = stubs.get(('c', name, w, mode), f'\n        {name} ${w:04X}{sfx}\n        jmp col_mark')
            return [0x20] + word(s)
        return None
    if 0xDC00 <= w < 0xDD00:
        reg = w & 0x0F
        if name in READS and reg in (0, 1):
            assert mode == 'abs', f'${pc:04X}: indexed CIA read'
            fn = 'get_dc00' if reg == 0 else 'get_dc01'
            s = stubs.get(('cia', fn, name), f'\n        jsr {fn}\n        {name} rv\n        rts')
            return [0x20] + word(s)
        if w != 0xDC00 + reg:
            return [op] + word(f'${0xDC00 + reg:04X}')
        return None
    if 0xDD00 <= w < 0xDE00:
        reg = w & 0x0F
        if w != 0xDD00 + reg:
            return [op] + word(f'${0xDD00 + reg:04X}')
        return None
    raise SystemExit(f'${pc:04X}: access to ${w:04X}')


def main():
    cm = json.load(open(os.path.join(GEN, 'codemap.json')))
    loads = json.load(open(os.path.join(GEN, 'loads.json')))
    entry = bytearray(open(os.path.join(GEN, 'entry.bin'), 'rb').read())
    stubs = Stubs()
    out = {}
    for unit, d in cm.items():
        mem = bytearray(entry)
        if unit != 'entry':
            for a, h in loads[unit]['runs']:
                b = bytes.fromhex(h)
                for i, v in enumerate(b):
                    if not 0x5400 <= a + i < 0x5800:
                        mem[a + i] = v
        patches = []
        special = ({a for a, _, _ in LOADER} | {a for a, _, _, _ in HOOKS}) if unit == "entry" else set()
        for pc, op, w in d['refs']:
            if unit == 'entry' and (pc in special or pc in LOADER_DEAD):
                continue
            p = classify(mem, pc, stubs)
            if p is not None:
                patches.append([pc, p])
        # stores to the C64 NMI vector ($FFFA/B, the RESTORE key) would replace
        # the Atari's: they go to c64_nmi
        for pc in d['code']:
            name, mode = OPS[mem[pc]]
            w = mem[pc + 1] | mem[pc + 2] << 8 if mode in MODE_SUFFIX else 0
            if name in STORES | RMW and mode in MODE_SUFFIX and w in (0xFFFA, 0xFFFB):
                patches.append([pc, [mem[pc]] + word(f'c64_nmi+{w - 0xFFFA}')])
        if unit == 'entry':
            for a, op, lab in LOADER:
                patches.append([a, [op] + word(lab)])
            for a, op, lab, orig in HOOKS:
                assert bytes(mem[a:a + 3]) == orig, f'hook ${a:04X}: {mem[a:a + 3].hex()}'
                patches.append([a, [op] + word(lab)])
            for a, mark in CHARSET_STORES.items():
                op = mem[a]
                name, mode = OPS[op]
                w = mem[a + 1] | mem[a + 2] << 8
                assert name in STORES and mode in MODE_SUFFIX and w >= 0xF000, f'${a:04X}'
                s = stubs.get(('cs', a), f'\n        {name} ${w:04X}{MODE_SUFFIX[mode]}\n        jmp {mark}')
                patches.append([a, [0x20] + word(s)])
        patches.sort()
        out[unit] = patches
        print(f'{unit:5}: {len(patches):4} patches')
    print(f'stubs: {len(stubs.names)}')
    with open(os.path.join(GEN, 'stubs.asm'), 'w') as f:
        f.write('; generated by tools/patch.py: I/O stubs\n' + '\n'.join(stubs.code) + '\n')
    with open(os.path.join(GEN, 'patchlist.json'), 'w') as f:
        json.dump(out, f)


if __name__ == '__main__':
    main()
