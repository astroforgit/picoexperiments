#!/usr/bin/env python3
"""Verify recovered images and replay original compression literals without edits."""
from pathlib import Path
import hashlib,json,sys


def reconstruct(report, original, read_image):
    """Return verified packed bytes without writing files.

    read_image(binary_name) supplies an assembled image from either published
    storage or temporary preparation. The caller controls all filesystem access.
    """
    if not report['stages']:
        raise ValueError('No independently verified recovered stages are available')
    if hashlib.sha256(original).hexdigest()!=report['original_sha256']:
        raise ValueError('Original input hash changed')
    packed=bytearray(original)
    for stage in report['stages']:
        image=read_image(stage['binary'])
        if hashlib.sha256(image).hexdigest()!=stage['sha256']:
            raise ValueError('Assembled stage differs from depacker output')
        for offset,index in stage['literal_patches']:
            if not (0<=offset<len(packed) and 0<=index<len(image)):
                raise ValueError('Literal patch outside input or image')
            packed[offset]=image[index]
    if bytes(packed)!=original:
        raise ValueError('Reconstructed XEX differs from original')
    return bytes(packed)


def rebuild(out):
    out=Path(out).resolve()
    report=json.loads((out/'recovery.json').read_text())
    original=(out.parents[1]/'original.xex').read_bytes()
    packed=reconstruct(report, original, lambda name:(out/name).read_bytes())
    (out/'rebuilt-packed.xex').write_bytes(packed)
    return True


if __name__=='__main__':
    rebuild(sys.argv[1]);print('PASS: assembled stages and reconstructed packed XEX are byte-identical.')
