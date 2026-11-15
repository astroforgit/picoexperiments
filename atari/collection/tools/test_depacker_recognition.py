from recover_common import TEMPLATE_90,TEMPLATE_103,ABSOLUTE_90,ABSOLUTE_103,MUTABLE_90,MUTABLE_103,ZP_OPERANDS,is_core,word_zp

def selftest():
    assert len(TEMPLATE_90) == 90 and len(TEMPLATE_103) == 103
    for template, absolute, mutable in ((TEMPLATE_90, ABSOLUTE_90, MUTABLE_90),
                                        (TEMPLATE_103, ABSOLUTE_103, MUTABLE_103)):
        for base in (0x400, 0x23b7, 0x8000, 0xa100):
            for zp in (0x0c, 0xd9, 0xe2, 0xfe, 0xff, 0x00):
                code = bytearray(template)
                for offset, displacement in ZP_OPERANDS.items():
                    code[offset] = (zp + displacement) & 0xff
                for offset, target in absolute.items():
                    code[offset:offset + 2] = (base + target).to_bytes(2, 'little')
                for offset in mutable:
                    code[offset] = (offset * 13) & 255
                assert is_core(code, 0)
                assert is_core(code, 0, expected_base=base)
                assert not is_core(code, 0, expected_base=base + 1)
                for offset in range(len(code)):
                    if offset in mutable:
                        continue
                    changed = bytearray(code)
                    changed[offset] ^= 1
                    assert not is_core(changed, 0), (len(code), base, zp, offset)
    ram = bytearray(65536)
    ram[0xff], ram[0], ram[0x100] = 0x34, 0x12, 0x99
    assert word_zp(ram, 0xff) == 0x1234
    print('Strict templates, relocation, mutable operands, mutation rejection and ZP wrap: PASS')


if __name__ == '__main__':
    selftest()
