#!/usr/bin/env python3
from pathlib import Path
from PIL import Image
import argparse

PALETTE = [
    (0, 0, 0), (29, 43, 83), (126, 37, 83), (0, 135, 81),
    (171, 82, 54), (95, 87, 79), (194, 195, 199), (255, 241, 232),
    (255, 0, 77), (255, 163, 0), (255, 255, 39), (0, 231, 88),
    (41, 173, 255), (131, 118, 156), (255, 119, 168), (255, 204, 170),
]


def parse_args():
    ap = argparse.ArgumentParser(
        description='Export __gfx__ spritesheets from all .p8 files into mirrored PNG resources.'
    )
    ap.add_argument('--input', default='allgames', help='Folder containing .p8 files')
    ap.add_argument('--output', default='allgames_resources', help='Output folder for PNG resources')
    ap.add_argument('--upscale', type=int, default=1, help='Pixel upscale factor')
    ap.add_argument('--overwrite', action='store_true', help='Overwrite existing PNGs')
    return ap.parse_args()


def char_to_color(ch):
    if '0' <= ch <= '9':
        return ord(ch) - ord('0')
    cl = ch.lower()
    if 'a' <= cl <= 'f':
        return 10 + ord(cl) - ord('a')
    return 0


def extract_gfx_rows(p8_path):
    rows = []
    in_gfx = False
    with p8_path.open('r', encoding='utf-8', errors='replace') as fh:
        for raw in fh:
            line = raw.rstrip('\n\r')
            if not in_gfx:
                if line == '__gfx__':
                    in_gfx = True
                continue
            if line.startswith('__'):
                break
            rows.append(line)
    if not rows:
        raise ValueError('No __gfx__ section found')
    rows = rows[:128]
    while len(rows) < 128:
        rows.append('')
    normalized = []
    for row in rows:
        row = row[:128].ljust(128, '0')
        normalized.append([char_to_color(ch) for ch in row])
    return normalized


def palette_image(rows, upscale):
    width = len(rows[0])
    height = len(rows)
    img = Image.new('P', (width, height))
    flat = []
    for rgb in PALETTE:
        flat.extend(rgb)
    flat.extend([0] * (768 - len(flat)))
    img.putpalette(flat)
    img.putdata([px for row in rows for px in row])
    if upscale > 1:
        img = img.resize((width * upscale, height * upscale), Image.Resampling.NEAREST)
    return img


def export_one(src_path, dst_path, upscale, overwrite):
    if dst_path.exists() and not overwrite:
        return False
    rows = extract_gfx_rows(src_path)
    dst_path.parent.mkdir(parents=True, exist_ok=True)
    palette_image(rows, upscale).save(dst_path)
    return True


def main():
    args = parse_args()
    src_root = Path(args.input)
    dst_root = Path(args.output)
    if args.upscale < 1:
        raise SystemExit('--upscale must be >= 1')
    if not src_root.exists():
        raise SystemExit(f'Input folder not found: {src_root}')

    written = 0
    skipped = 0
    failed = []
    for src_path in sorted(src_root.rglob('*.p8')):
        rel = src_path.relative_to(src_root)
        dst_path = (dst_root / rel).with_suffix('.png')
        try:
            if export_one(src_path, dst_path, args.upscale, args.overwrite):
                written += 1
            else:
                skipped += 1
        except Exception as exc:
            failed.append((src_path.as_posix(), str(exc)))

    print(f'Input root: {src_root}')
    print(f'Output root: {dst_root}')
    print(f'Written: {written}')
    print(f'Skipped: {skipped}')
    print(f'Failed: {len(failed)}')
    for path, err in failed[:20]:
        print(f'FAIL {path}: {err}')
    if failed:
        raise SystemExit(1)


if __name__ == '__main__':
    main()
