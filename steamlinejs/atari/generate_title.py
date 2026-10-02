#!/usr/bin/env python3
"""Convert elephant.png to a standard Atari ANTIC F title screen."""

from pathlib import Path

from PIL import Image, ImageOps


ROOT = Path(__file__).resolve().parent
WIDTH = 320
HEIGHT = 176
POSTER_WIDTH = 160
LINE_BYTES = WIDTH // 8
FIRST_BLOCK_LINES = 96


def main():
    source = Image.open(ROOT / "elephant.png").convert("L")
    source = ImageOps.autocontrast(source, cutoff=1)
    poster = source.resize((POSTER_WIDTH, HEIGHT), Image.Resampling.LANCZOS)
    poster = poster.point(lambda value: 255 if value >= 126 else 0, mode="1")

    screen = Image.new("1", (WIDTH, HEIGHT), 0)
    screen.paste(poster, ((WIDTH - POSTER_WIDTH) // 2, 0))

    data = bytearray()
    for y in range(HEIGHT):
        if y == FIRST_BLOCK_LINES:
            # ANTIC bitmap DMA must start afresh at the next 4K boundary.
            data.extend(bytes(256))
        for x in range(0, WIDTH, 8):
            value = 0
            for bit in range(8):
                value = (value << 1) | (screen.getpixel((x + bit, y)) != 0)
            data.append(value)

    assert len(data) == FIRST_BLOCK_LINES * LINE_BYTES + 256 + (HEIGHT - FIRST_BLOCK_LINES) * LINE_BYTES
    (ROOT / "title-screen.bin").write_bytes(data)
    screen.save(ROOT / "title-screen-preview.png")


if __name__ == "__main__":
    main()
