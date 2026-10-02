#!/usr/bin/env python3
"""Bind the recovered engine's explicit service names to native 6502 code."""
import json
from build_source_engine import OUT


def build():
    services = json.loads((OUT/'manifest.json').read_text())['services']
    labels = {p[2]: int(p[1],16) for line in (OUT/'bank7.lab').read_text().splitlines()
              if len(p := line.split()) == 3}
    lines = ['; Generated from the assembled source service and symbol manifest.']
    for name in ('LOCAL_EXIT_FROM_INTERRUPT', 'LOCAL_SET_STACK_TO_1FF', 'LOCAL_RETURN_FROM_STACK_SHENANIGANS'):
        lines.append(f'SOURCE_{name} = ${labels[name]:04x}')
    lines.append(f'PLATFORM_SERVICE_COUNT = {len(services)}')
    for part, prefix in (('lo','<'),('hi','>')):
        lines.append('platform_services_'+part)
        for index, (name,address) in enumerate(services.items()):
            if address != 0x1000+index*4:
                raise ValueError('service addresses must be contiguous four-byte slots')
            lines.append(f'        dta {prefix}platform_{name}')
    for name in services:
        if name in ('enable_nmi_and_store','disable_nmi_and_store'):
            op,mask = ('ora',128) if name.startswith('enable') else ('and',127)
            lines += [f'platform_{name}', '        lda $10ff', f'        {op} #{mask}',
                      '        sta $10ff','        jmp platform_result_a']
        elif name.endswith('and_store') and ('sprites' in name or '_bg_' in name):
            mask = 24 if 'sprites_and' in name or 'and_sprites' in name else (16 if 'sprites' in name else 8)
            op,mask = ('ora',mask) if name.startswith('enable') else ('and',255^mask)
            lines += [f'platform_{name}','        lda $10fe', f'        {op} #{mask}',
                      '        sta $10fe','        jmp platform_result_a']
    (OUT/'platform-tables.asm').write_text('\n'.join(lines)+'\n')
    print(f'Bound {len(services)} source platform interfaces.')


if __name__ == '__main__':
    build()
