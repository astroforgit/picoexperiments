#!/usr/bin/env python3
"""Convert a multi-sheet pixel character into the Grapple VBXE player sheet.

The Atari pipeline reads one 80x64 sheet of 16x16 frames whose colours are
region markers, not art: red is hair, white the top, green the legs and blue
the skin. This takes a character drawn at a larger size, in its own palette,
and produces that sheet.

    python3 convert_character.py PixelCharacterV1/PixelCharacterV1 \
        --out PixelCharacterV1/player-pixelv1.png

Source animations rarely match the port's six states, so missing ones are
substituted and reported. Substitutions are listed on stdout: read them.
"""
import argparse
import os
from collections import Counter

from PIL import Image

CELL = 16
SHEET_COLS = 5
SHEET_ROWS = 4

# Region markers the generator understands.
HAIR, SKIN, TOP, LEGS = "hair", "skin", "top", "legs"
MARKER = {
    HAIR: (255, 0, 0, 255),
    SKIN: (0, 0, 255, 255),
    TOP: (255, 255, 255, 255),
    LEGS: (0, 255, 0, 255)
}
# Ties broken in this order when a source block is evenly split, so small but
# identifying features (the face, the ponytail) survive the reduction.
PRIORITY = [HAIR, SKIN, TOP, LEGS]

# PixelCharacterV1's palette. The hair tie and the eyes fold into the hair:
# both are dark or blue accents that read as hair at 16x16.
DEFAULT_REGIONS = {
    (26, 26, 26): HAIR, (38, 38, 38): HAIR, (84, 40, 40): HAIR,
    (122, 151, 204): HAIR, (107, 133, 179): HAIR,
    (255, 180, 153): SKIN, (230, 142, 115): SKIN,
    (230, 230, 230): TOP, (179, 179, 179): TOP, (255, 255, 255): TOP,
    (41, 51, 31): LEGS, (21, 26, 16): LEGS
}

# Where each state lives in the 80x64 sheet the port already reads.
SLOTS = {
    "idle": [0, 1, 2, 3],
    "run": [5, 6, 7, 8, 9],
    "jump": [11, 12],
    "fall": [13, 14],
    "dead": [15],
    "grapple_horiz": [17, 18]
}


def load_frames(path, regions):
    """Split a strip into frames of classified regions."""
    image = Image.open(path).convert("RGBA")
    size = image.height
    count = image.width // size
    pixels = image.load()
    frames = []
    unknown = Counter()
    for index in range(count):
        grid = [[None] * size for _ in range(size)]
        for y in range(size):
            for x in range(size):
                r, g, b, a = pixels[index * size + x, y]
                if a < 128:
                    continue
                region = regions.get((r, g, b))
                if region is None:
                    unknown[(r, g, b)] += 1
                    continue
                grid[y][x] = region
        frames.append(grid)
    return frames, size, unknown


def global_bounds(all_frames):
    """One box for every frame, so the figure does not jitter between them."""
    x0, y0, x1, y1 = 10 ** 6, 10 ** 6, -1, -1
    for frames in all_frames:
        for grid in frames:
            for y, row in enumerate(grid):
                for x, value in enumerate(row):
                    if value is None:
                        continue
                    x0, y0 = min(x0, x), min(y0, y)
                    x1, y1 = max(x1, x), max(y1, y)
    return x0, y0, x1, y1


def reduce_frame(grid, box, coverage):
    """Block-majority downscale into a 16x16 cell, standing on the last row."""
    x0, y0, x1, y1 = box
    width = x1 - x0 + 1
    height = y1 - y0 + 1
    scale = height / float(CELL)
    columns = max(1, min(CELL, int(round(width / scale))))
    offset = (CELL - columns) // 2
    cell = [[None] * CELL for _ in range(CELL)]
    for cy in range(CELL):
        sy0 = y0 + int(cy * scale)
        sy1 = max(sy0 + 1, y0 + int((cy + 1) * scale))
        for cx in range(columns):
            sx0 = x0 + int(cx * scale)
            sx1 = max(sx0 + 1, x0 + int((cx + 1) * scale))
            counts = Counter()
            total = 0
            for sy in range(sy0, min(sy1, y1 + 1)):
                for sx in range(sx0, min(sx1, x1 + 1)):
                    total += 1
                    value = grid[sy][sx]
                    if value is not None:
                        counts[value] += 1
            if not counts or sum(counts.values()) < total * coverage:
                continue
            best = max(counts.values())
            for region in PRIORITY:
                if counts.get(region, 0) == best:
                    cell[cy][offset + cx] = region
                    break
    return cell


def build_sheet(states, box, coverage):
    """Lay the states out where generate_assets.js expects to find them."""
    sheet = Image.new("RGBA", (CELL * SHEET_COLS, CELL * SHEET_ROWS), (0, 0, 0, 0))
    pixels = sheet.load()
    notes = []
    for state, positions in SLOTS.items():
        frames = states.get(state)
        if not frames:
            continue
        for slot, position in enumerate(positions):
            grid = reduce_frame(frames[slot % len(frames)], box, coverage)
            ox = (position % SHEET_COLS) * CELL
            oy = (position // SHEET_COLS) * CELL
            for y in range(CELL):
                for x in range(CELL):
                    region = grid[y][x]
                    if region:
                        pixels[ox + x, oy + y] = MARKER[region]
    return sheet, notes


def draw_line(pixels, origin, points, colour, thickness=1):
    """Draw connected, hard-edged pixel lines without antialiasing."""
    ox, oy = origin
    previous = points[0]
    for point in points:
        x0, y0 = previous
        x1, y1 = point
        dx, dy = abs(x1 - x0), abs(y1 - y0)
        sx = 1 if x0 < x1 else -1
        sy = 1 if y0 < y1 else -1
        error = dx - dy
        while True:
            for wide in range(thickness):
                x, y = ox + x0 - wide, oy + y0
                if 0 <= x - ox < CELL and 0 <= y - oy < CELL:
                    pixels[x, y] = colour
            if (x0, y0) == (x1, y1):
                break
            twice = error * 2
            if twice > -dy:
                error -= dy
                x0 += sx
            if twice < dx:
                error += dx
                y0 += sy
        previous = point


# Hand-authored on the classic animation's timing: the coordinates keep the
# direction and energy of each pose, but not its bulky outline.  Hair points
# form a separate loose ribbon so it can lag, lift and curl between phases.
SLIM_POSES = {
    0:  ((9, 3), (9, 6), (8, 10), ((8, 7, 7, 10), (10, 7, 10, 10)),
         (((8, 10), (7, 13), (6, 15)), ((9, 10), (10, 13), (10, 15))),
         ((7, 4), (6, 6), (5, 8), (5, 11), (4, 13))),
    1:  ((9, 4), (9, 7), (8, 10), ((8, 8, 7, 11), (10, 8, 10, 11)),
         (((8, 10), (7, 13), (6, 15)), ((9, 10), (10, 13), (11, 15))),
         ((7, 5), (6, 7), (5, 9), (4, 11), (5, 13))),
    2:  ((10, 3), (9, 6), (8, 10), ((8, 7, 7, 10), (10, 7, 11, 10)),
         (((8, 10), (7, 13), (6, 15)), ((9, 10), (10, 13), (11, 15))),
         ((8, 4), (7, 6), (6, 8), (5, 10), (4, 12))),
    3:  ((10, 3), (9, 6), (8, 10), ((8, 7, 7, 10), (10, 7, 10, 10)),
         (((8, 10), (7, 13), (7, 15)), ((9, 10), (10, 13), (11, 15))),
         ((8, 4), (7, 6), (6, 8), (6, 11), (5, 14))),
    5:  ((11, 3), (10, 6), (9, 9), ((9, 7, 7, 9), (10, 7, 12, 8)),
         (((9, 9), (8, 12), (8, 15)), ((9, 10), (11, 12), (12, 14))),
         ((9, 4), (7, 5), (6, 7), (4, 7), (3, 9))),
    6:  ((11, 3), (10, 6), (9, 9), ((9, 7, 7, 9), (10, 7, 12, 9)),
         (((9, 9), (7, 11), (4, 13)), ((9, 10), (11, 12), (14, 12))),
         ((9, 4), (7, 5), (5, 5), (3, 6), (2, 8))),
    7:  ((12, 3), (10, 6), (9, 9), ((9, 7, 7, 9), (10, 7, 13, 8)),
         (((9, 9), (7, 11), (4, 14)), ((9, 10), (12, 11), (14, 13))),
         ((10, 4), (8, 5), (6, 4), (4, 5), (2, 5))),
    8:  ((11, 3), (10, 6), (9, 9), ((9, 7, 8, 9), (10, 7, 12, 9)),
         (((9, 9), (7, 12), (5, 13)), ((9, 10), (10, 13), (11, 15))),
         ((9, 4), (7, 5), (5, 4), (3, 5), (2, 7))),
    9:  ((10, 4), (9, 7), (8, 10), ((8, 8, 7, 10), (9, 8, 11, 10)),
         (((8, 10), (7, 13), (7, 15)), ((9, 10), (10, 13), (12, 15))),
         ((8, 5), (6, 6), (4, 6), (3, 8), (2, 9))),
    11: ((11, 2), (10, 5), (8, 8), ((9, 6, 7, 8), (10, 6, 12, 7)),
         (((8, 8), (7, 11), (5, 13)), ((9, 9), (10, 12), (8, 14))),
         ((9, 3), (7, 4), (5, 4), (3, 6), (2, 8))),
    12: ((11, 2), (10, 5), (8, 8), ((9, 6, 7, 8), (10, 6, 12, 7)),
         (((8, 8), (7, 11), (6, 14)), ((9, 9), (10, 11), (9, 13))),
         ((9, 3), (7, 4), (6, 3), (4, 4), (3, 6))),
    13: ((10, 3), (9, 6), (9, 9), ((8, 7, 7, 9), (10, 7, 11, 9)),
         (((9, 9), (9, 12), (8, 15)), ((10, 9), (11, 12), (13, 15))),
         ((8, 4), (6, 4), (5, 3), (3, 3), (2, 2))),
    14: ((10, 4), (9, 7), (9, 10), ((8, 8, 7, 10), (10, 8, 11, 10)),
         (((9, 10), (9, 13), (8, 15)), ((10, 10), (11, 13), (13, 15))),
         ((8, 5), (6, 4), (5, 2), (3, 2), (2, 4))),
    15: ((8, 8), (8, 10), (10, 11), ((8, 10, 6, 11), (9, 10, 11, 10)),
         (((10, 11), (8, 13), (6, 14)), ((10, 12), (12, 13), (14, 13))),
         ((6, 9), (4, 8), (3, 10), (2, 12), (4, 13))),
    17: ((12, 3), (10, 6), (8, 9), ((10, 6, 14, 6), (10, 7, 14, 7)),
         (((8, 9), (6, 11), (4, 14)), ((9, 9), (8, 12), (7, 14))),
         ((10, 4), (8, 4), (6, 3), (4, 4), (2, 6))),
    18: ((12, 4), (10, 7), (8, 9), ((10, 7, 14, 6), (10, 8, 14, 7)),
         (((8, 9), (6, 11), (3, 13)), ((9, 9), (8, 12), (6, 14))),
         ((10, 5), (8, 5), (6, 4), (4, 5), (2, 4)))
}


def retarget_to_reference(reference_path):
    """Draw a slim alternate hero on the classic phase sequence."""
    reference = Image.open(reference_path).convert("RGBA")
    if reference.size != (CELL * SHEET_COLS, CELL * SHEET_ROWS):
        raise ValueError("pose reference must be an 80x64 Grapple player sheet")

    sheet = Image.new("RGBA", reference.size, (0, 0, 0, 0))
    target = sheet.load()
    for position, pose in SLIM_POSES.items():
        ox = (position % SHEET_COLS) * CELL
        oy = (position // SHEET_COLS) * CELL
        head, shoulder, hip, arms, legs, hair = pose
        origin = (ox, oy)

        # Long, loose hair is its own narrow ribbon rather than the classic
        # solid cape. It changes curve in every phase to show drag and lift.
        draw_line(target, origin, hair, MARKER[HAIR], 2)
        hx, hy = head
        for x, y in ((hx - 1, hy - 1), (hx, hy - 1), (hx + 1, hy - 1),
                     (hx - 2, hy), (hx - 1, hy), (hx, hy),
                     (hx - 2, hy + 1), (hx - 1, hy + 1)):
            target[ox + x, oy + y] = MARKER[HAIR]

        for x0, y0, x1, y1 in arms:
            draw_line(target, origin, ((x0, y0), (x1, y1)), MARKER[SKIN])
        for leg in legs:
            draw_line(target, origin, leg, MARKER[LEGS])

        # Paint the narrow shirt over the shoulder roots so the pale torso
        # remains readable instead of turning into one continuous skin line.
        draw_line(target, origin, (shoulder, hip), MARKER[TOP], 2)
        target[ox + hip[0], oy + hip[1]] = MARKER[LEGS]
        target[ox + hip[0] - 1, oy + hip[1]] = MARKER[LEGS]

        # A small face and neck keep the head readable beside the blue hair.
        for x, y in ((hx + 1, hy), (hx, hy + 1), (hx + 1, hy + 1),
                     (shoulder[0], shoulder[1] - 1)):
            target[ox + x, oy + y] = MARKER[SKIN]
    return sheet


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("folder", help="folder holding *Animation.png strips")
    ap.add_argument("--out", required=True)
    ap.add_argument("--coverage", type=float, default=0.34,
                    help="fraction of a source block that must be painted "
                         "for the reduced pixel to be kept (default 0.34)")
    ap.add_argument("--pose-reference",
                    help="use an 80x64 Grapple sheet's exact silhouettes and "
                         "repaint them with this character's four regions")
    args = ap.parse_args()

    sources = {
        "idle": "IdleAnimation.png",
        "run": "RunAnimation.png",
        "jump": "JumpAnimation.png"
    }
    loaded = {}
    unknown = Counter()
    for state, name in sources.items():
        path = os.path.join(args.folder, name)
        if not os.path.exists(path):
            continue
        frames, size, missing = load_frames(path, DEFAULT_REGIONS)
        unknown.update(missing)
        loaded[state] = frames
        print(f"{state:14} {len(frames)} frames of {size}x{size}")
    if unknown:
        print("warning: unclassified colours (left transparent): " +
              ", ".join(f"#{r:02x}{g:02x}{b:02x} x{n}"
                        for (r, g, b), n in unknown.most_common(6)))

    box = global_bounds(loaded.values())
    print(f"figure box {box[2] - box[0] + 1}x{box[3] - box[1] + 1} source pixels")

    # The port needs six states. Fill the ones this character does not have,
    # and say so rather than letting them pass as authored.
    states = dict(loaded)
    substitutions = []
    if "run" in states and len(states["run"]) > len(SLOTS["run"]):
        count = len(states["run"])
        picked = [round(i * count / len(SLOTS["run"])) % count
                  for i in range(len(SLOTS["run"]))]
        states["run"] = [states["run"][i] for i in picked]
        substitutions.append(f"run: sampled frames {picked} from {count}")
    if "fall" not in states and "jump" in states:
        states["fall"] = list(reversed(states["jump"]))
        substitutions.append("fall: the jump frames, reversed")
    if "grapple_horiz" not in states and "run" in states:
        states["grapple_horiz"] = [states["run"][0], states["run"][2]]
        substitutions.append("grapple_horiz: two run frames")
    if "dead" not in states and "idle" in states:
        states["dead"] = [states["idle"][0]]
        substitutions.append("dead: the first idle frame")

    sheet = (retarget_to_reference(args.pose_reference)
             if args.pose_reference else
             build_sheet(states, box, args.coverage)[0])
    sheet.save(args.out)
    print(f"wrote {args.out} ({sheet.width}x{sheet.height})")
    if substitutions and not args.pose_reference:
        print("substituted, because the source has no art for them:")
        for note in substitutions:
            print(f"  - {note}")
    elif args.pose_reference:
        print("retargeted all gameplay slots to the reference animation phases")


if __name__ == "__main__":
    main()
