#!/usr/bin/env python3
"""Optional independent SAP/POKEY emulator validation using a compiled libasap."""
import argparse
import ctypes as ct
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--library', required=True, help='path to ASAP shared library')
    p.add_argument('--collection', type=Path, default=ROOT/'mscsrc', help='collection to validate (e.g. auditions)')
    args = p.parse_args()
    lib = ct.CDLL(args.library)
    for name, result, arguments in [
        ('ASAP_New', ct.c_void_p, []),
        ('ASAP_Delete', None, [ct.c_void_p]),
        ('ASAP_Load', ct.c_bool, [ct.c_void_p, ct.c_char_p, ct.c_void_p, ct.c_int]),
        ('ASAP_GetInfo', ct.c_void_p, [ct.c_void_p]),
        ('ASAPInfo_GetSongs', ct.c_int, [ct.c_void_p]),
        ('ASAPInfo_GetChannels', ct.c_int, [ct.c_void_p]),
        ('ASAP_PlaySong', ct.c_bool, [ct.c_void_p, ct.c_int, ct.c_int]),
        ('ASAP_Generate', ct.c_int, [ct.c_void_p, ct.c_void_p, ct.c_int, ct.c_int]),
    ]:
        f = getattr(lib, name)
        f.restype, f.argtypes = result, arguments
    player = lib.ASAP_New()
    files = sorted(args.collection.glob('*/*.sap'))
    subsongs = 0
    try:
        for path in files:
            raw = path.read_bytes()
            if not lib.ASAP_Load(player, str(path).encode(), raw, len(raw)):
                raise RuntimeError(f'ASAP rejected {path}')
            info = lib.ASAP_GetInfo(player)
            for song in range(lib.ASAPInfo_GetSongs(info)):
                if not lib.ASAP_PlaySong(player, song, 100):
                    raise RuntimeError(f'ASAP could not init {path}, subsong {song}')
                buffer = ct.create_string_buffer(8820*lib.ASAPInfo_GetChannels(info))
                if lib.ASAP_Generate(player, buffer, len(buffer), 1) != len(buffer):
                    raise RuntimeError(f'ASAP render failed: {path}, subsong {song}')
                subsongs += 1
        report = dict(sap_files=len(files), subsongs=subsongs, render_ms_per_subsong=100,
                      failures=0, emulator='ASAP (independent 6502 and POKEY emulation)')
        report_dir = ROOT if args.collection == ROOT/'mscsrc' else args.collection
        (report_dir/'asap-validation.json').write_text(json.dumps(report, indent=2)+'\n')
        print(json.dumps(report, indent=2))
    finally:
        lib.ASAP_Delete(player)


if __name__ == '__main__':
    main()
