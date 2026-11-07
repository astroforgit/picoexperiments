#!/usr/bin/env python3
"""Translate the SNES port's eight NES PRG banks into MADS sources for the Atari.

The banks keep their original addresses. Platform accesses become calls into
the Atari runtime through a fixed vector table (see SERVICES), so the banks can
be assembled before the runtime. Unknown SNES-only constructs are errors.
"""
from pathlib import Path
import re
import subprocess
import sys
import os

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT.parent / 'double-dragon-snes-main/double-dragon-snes-main/src'
GEN = ROOT / 'gen'

# Fixed runtime vector table: each entry is a 3-byte JMP at VECTOR_BASE + 3*i.
VECTOR_BASE = 0x1000
SERVICES = [
    # PPU data port (replaces STA/STX/STY $2007 and LDA $2007)
    'ppu_w_a', 'ppu_w_x', 'ppu_w_y', 'ppu_r_a',
    # services named after the SNES port's JSL targets
    'convert_audio', 'write_tile_and_attribute_rewrite',
    'convert_nes_attributes_and_immediately_dma_them',
    'set_vram_increment_based_on_a_and_store', 'set_vram_increment_to_1_and_store',
    'full_attribute_copy_from_0628', 'dd_update_row_attributes', 'dd_one_off_update',
    'dd_update_column_attributes', 'change_write_increment_based_on_carry_flag',
    'set_vram_increment_to_32_no_store', 'set_bottom_3_rows_of_attributes_to_55',
    'clear_bg_vm_jsl', 'restore_ppu_control_from_a', 'write_palette_data',
    'write_8_palette_entries_from_f1b6', 'do_critical_snes_nmi_chores',
    'enable_nmi_and_store', 'reset_2a03_audio', 'disable_sprites_and_bg_and_store',
    'enable_bg_and_sprites_and_store', 'disable_sprites_and_store',
    'enable_sprites_and_store', 'disable_bg_and_store', 'enable_bg_and_store',
    'augment_input', 'disable_nmi_and_store', 'handle_mmc1_control_register',
    'bankswitch_obj_chr_data', 'change_ppu_vblank_status', 'check_for_bg_chr_bankswap',
    'check_for_initial_obj_loads', 'store_vmaddh_to_proper_range',
    # Atari additions
    'prg_bank', 'hud_scroll', 'latch_scroll', 'wait_vblank', 'idle_spin', 'stack_reset',
]

# Variables the banks reference by name. SNES hardware registers map to plain
# Atari RAM; the runtime reads them.
RAM_SYMBOLS = {
    'VMADDL': 0x0A40, 'VMADDH': 0x0A41,
    'RDNMI': 0x0A42,          # always $80: the vblank flag reads as set
    'JOYSER0': 0x0A43, 'JOYSER1': 0x0A44,
}


def constants():
    values = {}
    for name in ('vars.inc', '2a03_variables.inc'):
        for line in (SOURCE / name).read_text().splitlines():
            m = re.match(r'\s*(?:\.define\s+)?(\w+)\s*(?:=\s*|\s+)(\$[\da-fA-F]+)\s*(?:;.*)?$', line, re.I)
            if m:
                values[m[1]] = int(m[2][1:], 16)
    values['SOUND_IO_BASE'] = values['SOUND_EMULATOR_BUFFER_START']
    for line in (SOURCE / '2a03_variables.inc').read_text().splitlines():
        m = re.match(r'\.DEFINE\s+(\w+)\s+SOUND_IO_BASE\s*\+\s*(\d+)', line)
        if m:
            values[m[1]] = values['SOUND_IO_BASE'] + int(m[2])
    values.update(RAM_SYMBOLS)
    return values


def vector(name):
    return VECTOR_BASE + 3 * SERVICES.index(name)


# Whole-block replacements in bank 7, keyed by (first line, last line) of the
# SNES source (1-based, inclusive). Each starts at a known NES address.
def bank7_replacements(src):
    lines = src.splitlines()

    def find(text, start=0):
        for i in range(start, len(lines)):
            if text in lines[i]:
                return i + 1
        raise ValueError(f'bank7: marker not found: {text}')

    rep = {}
    # C276: restore the NES tile/attribute stream routine that the SNES port
    # replaced (its original code is kept in the source's comments).
    a = find('  jslb write_tile_and_attribute_rewrite, $a0')
    b = find(': nops 28', a)
    rep[(a, b)] = '''
        ert * <> $c276
        lda $8000,x
        sta $21
        lda $8001,x
        sta $22
        ert * <> $c280
        ldy #0
        lda ($21),y
        cmp #0
        bne local_c2c8
        iny
        lda ($21),y
        cmp #0
        bne local_c2a5
        lda $16
        cmp #5
        bmi local_stream_done
        cmp #$0d
        bpl local_stream_done
        clc
        adc #$0c
        jmp $c25a
local_stream_done
        ert * <> $c29f
'''
    # Palette routine at ED65: STZ is 65816-only.
    a = find('  STZ PALETTE_OFFSET')
    b = find('  nops 10', a)
    rep[(a, b)] = f'''
        lda #0
        sta PALETTE_OFFSET
        lda #$10
        sta PALETTE_ENTRY_CNT
        jsr ${vector('write_palette_data'):04x}
        dta $ea,$ea,$ea,$ea,$ea,$ea,$ea,$ea,$ea
        ert * <> $ed7b
'''
    # The SNES port swapped VMADDL/VMADDH here; the NES writes $23F0.
    a = find('  STA VMADDL ; $2006', find('  LDA VMDATALREAD'))
    rep[(a - 1, a + 2)] = '''
        lda #$23
        sta VMADDH
        lda #$F0
        sta VMADDL
'''
    # FE76..FF15: MMC1 writes become direct Atari bank selection.
    a = find('; fe76 -Set bank switch control registers')
    b = find('; FF16 - the NES NMI routine') - 1
    rep[(a, b)] = f'''
        ert * <> $fe76
        sta BANK_SWITCH_CTRL_REGS
        jsr ${vector('handle_mmc1_control_register'):04x}
        lda PPU_CONTROL_STATE
        rts
        :$fe9e-* dta $ea
; FE9E - sprite pattern table bank (CHR $0000)
        sta BANK_SWITCH_CTRL_SPRITE_BANK
        sta CHR_BANK_BANK_TO_LOAD
        jsr ${vector('bankswitch_obj_chr_data'):04x}
        lda PPU_CONTROL_STATE
        rts
        :$fec6-* dta $ea
; FEC6 - background pattern table bank (CHR $1000)
        sta BANK_SWITCH_CTRL_BG_BANK
        sta BG_CHR_BANK_SWITCH
        jsr ${vector('check_for_bg_chr_bankswap'):04x}
        lda PPU_CONTROL_STATE
        rts
        :$feee-* dta $ea
; FEEE - PRG bank at $8000
        sta ACTIVE_NES_BANK
        jsr ${vector('prg_bank'):04x}
        lda PPU_CONTROL_STATE
        rts
        :$ff16-* dta $ea
'''
    # NES NMI: the SNES pushed an extra program bank byte.
    a = find('  PLA ; extra PLA for us because the Bank is there too')
    rep[(a, a)] = '        nop'
    # Stack reset and interrupt exit.
    a = find('@set_stack_to_1ff: ; 11 bytes')
    b = find('  JMP @return_from_stack_shenanigans', a)
    rep[(a, b)] = f'''local_set_stack_to_1ff
        ldx #$ff
        txs
        jsr ${vector('stack_reset'):04x}
        jmp local_return_from_stack_shenanigans
        dta $ea,$ea
'''
    a = find('  jml return_from_nes_nmi')
    rep[(a, a)] = '        rti\n        dta $ea,$ea,$ea'
    # HUD scroll after the (removed) sprite-0 wait: tell the renderer.
    a = find('; ec79 - This appears to be setting the scroll for the HUD')
    b = find('  nops 21', a)
    rep[(a, b)] = f'        jmp ${vector("hud_scroll"):04x}\n        dta ' + ','.join(['$ea'] * 19)
    # FCBF wrote the frame's scroll and PPUCTRL; the renderer latches them.
    a = find('; FCBF - reset the PPU Control and H/V Scroll')
    b = find('  nops 18', a)
    rep[(a, b)] = f'        jmp ${vector("latch_scroll"):04x}\n        dta ' + ','.join(['$ea'] * 15)
    return rep


def translate(bank, services_used):
    path = SOURCE / f'bank{bank}.asm'
    src = path.read_text()
    replacements = bank7_replacements(src) if bank == 7 else {}
    skip_until = 0
    out = []
    active = True
    segment_seen = False
    anonymous = 0
    lines = src.splitlines()
    for number, original in enumerate(lines, 1):
        if number <= skip_until:
            continue
        for (a, b), text in replacements.items():
            if a == number:
                out.append(f'; ---- replaced source lines {a}-{b}')
                out.append(text)
                skip_until = b
                break
        if number <= skip_until:
            continue
        code = original.split(';', 1)[0].strip()
        if code.startswith('.segment'):
            if segment_seen:
                break
            segment_seen = True
            continue
        if code.startswith('.if '):
            if code not in ('.if ENABLE_MSU = 0', '.if ENABLE_MSU = 1'):
                raise ValueError(f'bank{bank}:{number}: unsupported conditional: {code}')
            active = code.endswith('= 0')
            continue
        if code == '.endif':
            active = True
            continue
        if not active:
            continue
        anchor = re.fullmatch(r';\s*([\da-fA-F]{4}) - bank \d+\s*', original)
        if anchor:
            expected = int(anchor[1], 16)
            if bank == 7 and expected == 0xe300:
                expected = 0xe307   # the comment follows a block crossing E300
            out.append(f'        ert * <> ${expected:04x}')
        if not code:
            continue
        if code.startswith(':'):
            anonymous += 1
            out.append(f'anon_{anonymous}')
            code = code[1:].strip()

        def anon_ref(m):
            signs = m[1]
            target = anonymous + len(signs) if signs[0] == '+' else anonymous - len(signs) + 1
            return f'anon_{target}'
        code = re.sub(r':([+]+|[-]+)', anon_ref, code)
        code = code.replace('@', 'local_')
        code = re.sub(r'^(ASL|LSR|ROL|ROR)\s+A$', r'\1', code, flags=re.I)
        if code.endswith(':'):
            out.append(code[:-1])
            continue
        low = code.lower()
        if low.startswith('.byte '):
            code = 'dta ' + code[6:]
        elif low.startswith('nops '):
            code = 'dta ' + ','.join(['$ea'] * int(code.split()[1]))
        elif low.startswith('jslb '):
            service = code.split()[1].split(',')[0]
            if service not in SERVICES:
                raise ValueError(f'bank{bank}:{number}: no Atari service for {service}')
            services_used.add(service)
            code = f'jsr ${vector(service):04x} ; {service}\n        nop'
        elif re.fullmatch(r'(sta|stx|sty)\s+vmdatal', low):
            code = f'jsr ${vector("ppu_w_" + low[2]):04x} ; {code}'
        elif low == 'lda vmdataldread' or low == 'lda vmdatalread':
            code = f'jsr ${vector("ppu_r_a"):04x} ; {code}'
        elif low.startswith(('jml', 'jsl', 'plb', 'phb', 'stz', 'setaxy', 'seta', 'setxy', 'bra ')) or low == 'inc':
            raise ValueError(f'bank{bank}:{number}: 65816 instruction left: {code}')
        elif code.startswith('.'):
            raise ValueError(f'bank{bank}:{number}: unsupported directive {code}')
        if bank == 6 and code == 'LDA #$03' and 'thumbs up' in lines[number - 3]:
            code = 'LDA #$01 ; NES value (the SNES port used sheet 3)'
        out.append(f'        {code} ; {number}')
    return '\n'.join(out) + '\n'


def build():
    GEN.mkdir(exist_ok=True)
    values = constants()
    header = '\n'.join(f'{k} = ${v:x}' for k, v in sorted(values.items()))
    used = set()
    for bank in range(8):
        body = translate(bank, used)
        base = 0xC000 if bank == 7 else 0x8000
        asm = GEN / f'bank{bank}.asm'
        asm.write_text(f'{header}\n        opt h-\n        org ${base:04x}\n{body}\n        ert * <> ${base + 0x4000:x}\n')
        r = subprocess.run([os.environ.get('MADS', 'mads'), str(asm), f'-o:{GEN}/bank{bank}.bin',
                            f'-t:{GEN}/bank{bank}.lab', f'-l:{GEN}/bank{bank}.lst'],
                           capture_output=True, text=True)
        if r.returncode:
            sys.exit(r.stdout + r.stderr)
        size = (GEN / f'bank{bank}.bin').stat().st_size
        if size != 0x4000:
            sys.exit(f'bank {bank}: {size} bytes')
    vec = '\n'.join(f'SVC_{n.upper()} = ${vector(n):04x}' for n in SERVICES)
    (GEN / 'vectors.asm').write_text(
        f'; generated by tools/translate.py\nVECTOR_BASE = ${VECTOR_BASE:04x}\n' + vec + '\n' +
        '\n'.join(f'{k} = ${v:04x}' for k, v in RAM_SYMBOLS.items()) + '\n')
    (GEN / 'vector-table.asm').write_text(
        '; generated by tools/translate.py: the banks call these fixed addresses\n'
        f'        org ${VECTOR_BASE:04x}\n' +
        '\n'.join(f'        jmp {n}' for n in SERVICES) + '\n')
    print(f'translated 8 banks; services used: {len(used)}')


if __name__ == '__main__':
    build()
