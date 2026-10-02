#!/usr/bin/env python3
"""Reassemble every supplied PRG bank, retaining its original address layout.

This is an intermediate engine image, NOT an Atari executable. SNES service
calls become explicit 6502 JSR interfaces. The manifest lists every interface;
the runner must implement them, never silently skip an unknown call.
"""
from pathlib import Path
import hashlib
import json
import os
import re
import subprocess

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT.parent / 'double-dragon-snes-main/double-dragon-snes-main/src'
OUT = ROOT / 'generated/source-engine'


def constants():
    values = {}
    for name in ('vars.inc', 'registers.inc', '2a03_variables.inc'):
        for line in (SOURCE / name).read_text().splitlines():
            match = re.match(r'\s*(?:\.define\s+)?(\w+)\s*(?:=\s*|\s+)(\$[\da-fA-F]+)\s*(?:;.*)?$', line, re.I)
            if match:
                values[match[1]] = int(match[2][1:], 16)
    values['SOUND_IO_BASE'] = values['SOUND_EMULATOR_BUFFER_START']
    for line in (SOURCE / '2a03_variables.inc').read_text().splitlines():
        match = re.match(r'\.DEFINE\s+(\w+)\s+SOUND_IO_BASE\s*\+\s*(\d+)', line)
        if match:
            values[match[1]] = values['SOUND_IO_BASE'] + int(match[2])
    return values


def translate(bank, services):
    """Translate syntax, with no guessed data/code disassembly or byte removal."""
    source = (SOURCE / f'bank{bank}.asm').read_text()
    lines = []
    active = True
    segment_seen = False
    anonymous = 0
    for number, original in enumerate(source.splitlines(), 1):
        code = original.split(';', 1)[0].strip()
        if code.startswith('.segment'):
            if segment_seen:
                break
            segment_seen = True
            continue
        if code.startswith('.if '):
            if code not in ('.if ENABLE_MSU = 0', '.if ENABLE_MSU = 1'):
                raise ValueError(f'unsupported conditional: {code}')
            active = code.endswith('= 0')
            continue
        if code == '.endif':
            active = True
            continue
        if not active:
            continue
        anchor = re.fullmatch(r';\s*([\da-fA-F]{4}) - bank \d+\s*', original)
        if anchor:
            # Page comments inside byte streams verify preservation of layout.
            # This comment follows an instruction block which crosses E300.
            expected = int(anchor[1], 16)
            if bank == 7 and expected == 0xe300:
                expected = 0xe307
            lines.append(f'        ert * <> ${expected:04x}')
        if not code:
            continue
        if code.startswith(':'):
            anonymous += 1
            lines.append(f'anon_{anonymous}')
            code = code[1:].strip()
        def anon_ref(match):
            signs = match[1]
            target = anonymous + len(signs) if signs[0] == '+' else anonymous - len(signs) + 1
            return f'anon_{target}'
        code = re.sub(r':([+]+|[-]+)', anon_ref, code)
        code = code.replace('@', 'local_')
        code = re.sub(r'^(ASL|LSR|ROL|ROR)\s+A$', r'\1', code, flags=re.I)
        if code.endswith(':'):
            lines.append(code[:-1])
            continue
        if not code:
            continue
        if code.startswith('.byte '):
            code = 'dta ' + code[6:]
        elif code.lower().startswith('nops '):
            code = 'dta ' + ','.join(['$ea'] * int(code.split()[1]))
        elif code.lower().startswith('jslb '):
            service = code.split()[1].split(',')[0]
            if service not in services:
                services[service] = 0x1000 + len(services) * 4
            code = f'jsr ${services[service]:04x}\n        nop'
        elif code.lower().startswith('jml '):
            # These SNES-only paths are replaced before executing the image.
            operand = code.split(None, 1)[1]
            if operand.startswith('('):
                code = f'dta $dc,a({operand[1:-1]})'
            else:
                code = 'dta $5c,0,0,0'
        elif code.lower() == 'plb':
            code = 'dta $ab'
        elif code.lower() == 'inc':
            code = 'dta $1a'
        elif code.lower().startswith('stz '):
            code = f'dta $9c,a({code.split()[1]})'
        elif code.lower() in ('setaxy16', 'setaxy8'):
            code = 'dta $c2,$30' if code.lower() == 'setaxy16' else 'dta $e2,$30'
        elif code.lower() == 'ldx #$01ff':
            code = 'dta $a2,$ff,$01'
        elif code.startswith('.'):
            raise ValueError(f'bank{bank}:{number}: unsupported directive {code}')
        lines.append(f'        {code} ; source line {number}')
    return '\n'.join(lines) + '\n'


def build():
    OUT.mkdir(parents=True, exist_ok=True)
    services = {}
    bodies = [translate(bank, services) for bank in range(8)]
    values = constants()
    header = '\n'.join(f'{name} = ${value:x}' for name, value in sorted(values.items()))
    manifest = {'status': 'intermediate image; not an Atari executable',
                'music': False, 'services': services, 'banks': []}
    for bank, body in enumerate(bodies):
        path = OUT / f'bank{bank}.asm'
        base = 0xc000 if bank == 7 else 0x8000
        path.write_text(f'{header}\n        opt h-\n        org ${base:04x}\n{body}\n        ert * <> ${base+0x4000:x}\n')
        result = subprocess.run([os.environ.get('MADS', 'mads'), str(path),
                                 f'-o:{OUT}/bank{bank}.bin', f'-t:{OUT}/bank{bank}.lab'],
                                capture_output=True, text=True)
        if result.returncode:
            raise RuntimeError(result.stdout + result.stderr)
        data = (OUT / f'bank{bank}.bin').read_bytes()
        if len(data) != 0x4000:
            raise ValueError(f'bank {bank}: expected 16384 bytes, got {len(data)}')
        manifest['banks'].append({'bank': bank, 'size': len(data),
            'sha256': hashlib.sha256(data).hexdigest(),
            'source_sha256': hashlib.sha256((SOURCE / f'bank{bank}.asm').read_bytes()).hexdigest()})
    (OUT / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    print(f'Reassembled all eight PRG banks; {len(services)} explicit hardware services.')


if __name__ == '__main__':
    build()
