#!/usr/bin/env python3
"""Run the game in tools/emu.py and save shots.png: the title, two story
pages and a station in play.

Usage: python3 shot.py GAME.xex OSROM.rom OUT.png   (needs Pillow, py65)
OSROM is any 16 KB XL OS image, e.g. AltirraOS (kernelxl.rom) built
from the Altirra sources with MADS.
"""
import os
import sys

from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from emu import Atari                               # noqa: E402


def main():
    game, rom, out = sys.argv[1:4]
    a = Atari(game, rom)
    a.boot(60)
    shots = []
    for frames in (250, 1950, 2050):        # title, train page, story page
        a.run_frames(frames)
        shots.append(a.screenshot(scale=1))
    a.consol = 6                            # START
    a.run_frames(5)
    a.consol = 7
    a.run_frames(500)
    a.stick = 7                             # walk right a little
    a.run_frames(40)
    a.stick = 15
    a.run_frames(60)
    shots.append(a.screenshot(scale=1))
    w, h = shots[0].size
    sheet = Image.new('RGB', (w * 2, h * 2))
    for i, im in enumerate(shots):
        sheet.paste(im, ((i % 2) * w, (i // 2) * h))
    sheet.save(out)


if __name__ == '__main__':
    main()
