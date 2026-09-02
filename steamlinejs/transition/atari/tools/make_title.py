#!/usr/bin/env python3
"""Convert the Romek source artwork to an Atari ANTIC mode D bitmap."""

from __future__ import annotations

from pathlib import Path
import sys

from PIL import Image


WIDTH = 160
HEIGHT = 64
PALETTE = (
    (0, 0, 0),        # COLBK: black
    (214, 137, 17),   # COLOR0: amber
    (0, 96, 101),     # COLOR1: teal
    (207, 232, 36),   # COLOR2: portal green
)


def nearest_color(pixel: tuple[int, int, int]) -> int:
    return min(
        range(len(PALETTE)),
        key=lambda index: sum(
            (pixel[channel] - PALETTE[index][channel]) ** 2
            for channel in range(3)
        ),
    )


def title_color(x: int, y: int, pixel: tuple[int, int, int], index: int) -> int:
    """Keep the large title letters solid after four-color reduction."""
    if max(pixel) < 120 or sum(pixel) < 250:
        return index

    regions = (
        (89, 113, 5, 31, 2),   # R: teal
        (113, 135, 4, 31, 3),  # O: green
        (89, 114, 31, 64, 3),  # M: green
        (114, 136, 31, 64, 1), # E: amber
        (136, 160, 31, 64, 2), # K: teal
    )
    for left, right, top, bottom, color in regions:
        if left <= x < right and top <= y < bottom:
            return color
    return index


def convert(source_path: Path, output_path: Path, preview_path: Path) -> None:
    source = Image.open(source_path).convert("RGB")

    # Center-crop to the exact 160x64 artwork ratio before pixel reduction.
    # The text-mode menu is rendered by the Atari beneath this bitmap.
    target_ratio = WIDTH / HEIGHT
    source_ratio = source.width / source.height
    if source_ratio > target_ratio:
        crop_width = round(source.height * target_ratio)
        left = (source.width - crop_width) // 2
        source = source.crop((left, 0, left + crop_width, source.height))
    elif source_ratio < target_ratio:
        crop_height = round(source.width / target_ratio)
        top = (source.height - crop_height) // 2
        source = source.crop((0, top, source.width, top + crop_height))

    source = source.resize((WIDTH, HEIGHT), Image.Resampling.NEAREST)

    indexes = []
    for offset, pixel in enumerate(source.getdata()):
        x = offset % WIDTH
        y = offset // WIDTH
        index = nearest_color(pixel)
        indexes.append(title_color(x, y, pixel, index))
    packed = bytearray()
    for offset in range(0, len(indexes), 4):
        a, b, c, d = indexes[offset : offset + 4]
        packed.append((a << 6) | (b << 4) | (c << 2) | d)

    output_path.write_bytes(packed)

    preview = Image.new("RGB", (WIDTH, HEIGHT))
    preview.putdata([PALETTE[index] for index in indexes])
    preview.resize((WIDTH * 4, HEIGHT * 4), Image.Resampling.NEAREST).save(
        preview_path
    )

    expected_size = WIDTH * HEIGHT // 4
    if len(packed) != expected_size:
        raise RuntimeError(f"expected {expected_size} bytes, wrote {len(packed)}")


def main() -> None:
    project = Path(__file__).resolve().parent.parent
    source = project / "assets" / "romek-title-source.png"
    output = project / "assets" / "romek-title.2bpp"
    preview = project / "assets" / "romek-title-preview.png"

    if len(sys.argv) == 4:
        source, output, preview = map(Path, sys.argv[1:])
    elif len(sys.argv) != 1:
        raise SystemExit("usage: make_title.py [SOURCE OUTPUT PREVIEW]")

    convert(source, output, preview)
    print(f"Wrote {output} and {preview}")


if __name__ == "__main__":
    main()
