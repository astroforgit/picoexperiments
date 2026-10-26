#!/usr/bin/env python3
"""Decode the user-supplied SWOS archive's graphics after 7z extraction."""
from pathlib import Path
import hashlib
import json
import rnc1
import rnc2
ROOT = Path(__file__).resolve().parents[1]


def main():
    src = ROOT / 'amiga/SWOS2526/data/grafs'
    out = ROOT / 'assets/swos/unpacked'
    out.mkdir(parents=True, exist_ok=True)
    records = []
    for path in sorted(src.iterdir()):
        packed = path.read_bytes()
        method = packed[3] if packed.startswith(b'RNC') else 0
        if method not in (0, 1, 2):
            raise ValueError(f'Unsupported RNC method in {path}')
        data = {1: rnc1.unpack, 2: rnc2.unpack}.get(method, lambda b: b)(packed)
        (out / path.name).write_bytes(data)
        records.append({'file': path.name, 'source_bytes': len(packed),
                        'decoded_bytes': len(data), 'rnc_method': method,
                        'crc_verified': method != 0,
                        'sha256': hashlib.sha256(data).hexdigest()})
    (out.parent / 'manifest.json').write_text(json.dumps(records, indent=2) + '\n')
    print(f'Decoded {len(records)} graphics files; {sum(r["crc_verified"] for r in records)} CRC-verified.')


if __name__ == '__main__':
    main()
