"""Extra terrain tiles and hazard sprites, drawn in the game's own idiom.

The cave art is one bit deep: solid black fill, a one-pixel white keyline, and
transparency everywhere else. WorldFilter paints the silhouette edge white at
runtime and DepthFilter tints the whole tilemap by depth, so nothing here may
use a colour of its own -- a tile that ships its own hue would refuse to take
the zone tint and would read as a foreign object in every zone but one.

Terrain decoration follows the zone it belongs to. The shallow cave tiles are
organic blobs, the deep "digital" tiles are numerals, and the castle band in
between had no decoration at all until now. The tiles added here fill that gap
and extend the two existing vocabularies.

Run from anywhere:

    python3 grapple/design/make_tiles.py

It rewrites bin/assets/world.png in place, preserving every existing tile, and
writes the two hazard sheets beside it. Running it twice changes nothing.
"""
import math
import os

from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
ASSETS = os.path.join(HERE, os.pardir, "bin", "assets")

TILE = 16
SHEET_COLS = 8
SHEET_ROWS = 4

BLACK = (0, 0, 0, 255)
WHITE = (255, 255, 255, 255)
CLEAR = (0, 0, 0, 0)

# '#' is fill, 'O' is decoration, '.' is transparent.
FILL, DECO, VOID = "#", "O", "."


def from_rows(rows):
    """A 16x16 RGBA tile from the ASCII grid used throughout this file."""
    assert len(rows) == TILE, f"expected {TILE} rows, got {len(rows)}"
    image = Image.new("RGBA", (TILE, TILE), CLEAR)
    for y, row in enumerate(rows):
        assert len(row) == TILE, f"row {y} is {len(row)} wide, expected {TILE}"
        for x, cell in enumerate(row):
            image.putpixel((x, y), {FILL: BLACK, DECO: WHITE, VOID: CLEAR}[cell])
    return image


# --------------------------------------------------------------------------
# Terrain: cave zone. Blob speckles, matching tiles 2 and 3.
# --------------------------------------------------------------------------

DRIPSTONE = from_rows([
    "################",
    "######OO########",
    "######OO########",
    "#######O########",
    "################",
    "############OO##",
    "###O########OO##",
    "###O#########O##",
    "###O############",
    "##########OO####",
    "###OO######O####",
    "###OOO##########",
    "####OO#######O##",
    "#############O##",
    "#############O##",
    "################",
])

# Hollow shards: an outline reads as a facet where a solid blob reads as a hole.
CRYSTALS = from_rows([
    "################",
    "################",
    "#######O########",
    "######O#O#######",
    "######O#O#######",
    "#####O###O######",
    "#####OOOOO######",
    "################",
    "##O########O####",
    "#O#O######O#O###",
    "#O#O######O#O###",
    "##O########O####",
    "################",
    "######O#########",
    "#####O#O########",
    "######O#########",
])

# --------------------------------------------------------------------------
# Terrain: castle zone. Courses of four, so the mortar lines still meet at the
# seam when the tile repeats vertically.
# --------------------------------------------------------------------------

MASONRY = from_rows([
    "#######O########",
    "#######O########",
    "#######O########",
    "OOOOOOOOOOOOOOOO",
    "###O########O###",
    "###O########O###",
    "###O########O###",
    "OOOOOOOOOOOOOOOO",
    "#######O########",
    "#######O########",
    "#######O########",
    "OOOOOOOOOOOOOOOO",
    "###O########O###",
    "###O########O###",
    "###O########O###",
    "OOOOOOOOOOOOOOOO",
])

ARROW_SLIT = from_rows([
    "################",
    "################",
    "#####OOOOOO#####",
    "####O######O####",
    "####O##OO##O####",
    "####O##OO##O####",
    "####O##OO##O####",
    "####O##OO##O####",
    "####O##OO##O####",
    "####O##OO##O####",
    "####O######O####",
    "#####OOOOOO#####",
    "################",
    "################",
    "################",
    "################",
])

# --------------------------------------------------------------------------
# Terrain: digital zone. The existing tiles down there are decimal numerals in
# a 6x7 face; these are the same face saying 10 and 01.
# --------------------------------------------------------------------------

GLYPHS = {
    "0": ["#OOOO#", "OO##OO", "OO##OO", "OO##OO", "OO##OO", "OO##OO", "#OOOO#"],
    "1": ["##OO##", "#OOO##", "##OO##", "##OO##", "##OO##", "##OO##", "#OOOO#"],
}


def numeral_tile(top, bottom):
    """Two rows of two glyphs, laid out like the existing numeral tiles."""
    rows = [list(FILL * TILE) for _ in range(TILE)]
    for block, pair in ((0, top), (8, bottom)):
        for column, digit in ((1, pair[0]), (9, pair[1])):
            for y, glyph_row in enumerate(GLYPHS[digit]):
                for x, cell in enumerate(glyph_row):
                    rows[block + y][column + x] = cell
    return from_rows(["".join(row) for row in rows])


BINARY = numeral_tile("10", "01")

# --------------------------------------------------------------------------
# Hazards. Drawn by sampling a shape at 8x and thresholding, because a sawtooth
# rim and a flame edge are curves; the keyline is then grown outwards from the
# result exactly as the hand-drawn sprites have it -- white on the transparent
# side of the boundary, never eating into the fill.
# --------------------------------------------------------------------------

SUPERSAMPLE = 8


def rasterize(inside, width=TILE, height=TILE):
    """Fill mask from a predicate on continuous sprite coordinates."""
    step = 1.0 / SUPERSAMPLE
    offset = step / 2.0
    threshold = SUPERSAMPLE * SUPERSAMPLE / 2
    mask = [[False] * width for _ in range(height)]
    for y in range(height):
        for x in range(width):
            hits = 0
            for sy in range(SUPERSAMPLE):
                for sx in range(SUPERSAMPLE):
                    if inside(x + offset + sx * step, y + offset + sy * step):
                        hits += 1
            mask[y][x] = hits >= threshold
    return mask


def keyline(mask):
    """Black fill plus the one-pixel white outline the other sprites carry."""
    height, width = len(mask), len(mask[0])
    image = Image.new("RGBA", (width, height), CLEAR)
    for y in range(height):
        for x in range(width):
            if mask[y][x]:
                image.putpixel((x, y), BLACK)
                continue
            neighbours = ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1))
            if any(0 <= nx < width and 0 <= ny < height and mask[ny][nx]
                   for nx, ny in neighbours):
                image.putpixel((x, y), WHITE)
    return image


CENTRE = TILE / 2.0


def sawblade_frame(index, frames):
    """One step of a spinning blade: serrated rim, bore, three expansion slots.

    The rotation is carried by the slots, not by the teeth. A tooth deep enough
    to survive the keyline is three pixels of a seven-pixel radius, and a rim
    cut that far in reads as a star rather than as a disc; so the teeth stay a
    one-pixel serration and the slots -- holes in the fill, which the keyline
    then floods white -- do the animating. Three slots over four frames turn a
    third of a revolution and land back on the shape they started from.
    """
    teeth, slots = 12, 3
    tip, root, bore = 7.4, 6.3, 2.2
    phase = index / frames * (2 * math.pi / slots)

    def inside(px, py):
        dx, dy = px - CENTRE, py - CENTRE
        radius = math.hypot(dx, dy)
        if radius < bore:
            return False
        angle = math.atan2(dy, dx) + phase
        if 3.1 <= radius <= 5.9:
            for slot in range(slots):
                # Each slot is a radial cut, raked back against the spin.
                cut = slot * 2 * math.pi / slots + (radius - 3.1) * 0.22
                offset = (angle - cut + math.pi) % (2 * math.pi) - math.pi
                if abs(offset * radius) <= 0.85:
                    return False
        along = (angle * teeth / (2 * math.pi)) % 1.0
        return radius <= root + (tip - root) * along

    return keyline(rasterize(inside))


# Rest, then the jet climbing out of the nozzle over three steps.
FLAME_HEIGHTS = [0.0, 3.5, 7.5, 11.5]

NOZZLE_TOP = 13.0
LIP = 11.5


def flame_vent_frame(index):
    """A nozzle bolted to the floor of the tile, with a jet of the given height.

    The jet leaves the nozzle narrower than the lip it comes out of. Without
    that shoulder the two silhouettes merge and the sprite reads as one cone
    rather than as fire coming out of a thing.
    """
    height = FLAME_HEIGHTS[index]
    lean = math.sin(index * 2.3) * 0.9

    def inside(px, py):
        dx = px - CENTRE
        if py >= NOZZLE_TOP:
            # Housing, flaring towards the floor it is bolted to.
            return abs(dx) <= 3.5 + (py - NOZZLE_TOP) * 0.8
        if py >= LIP:
            return abs(dx) <= 5.0  # the lip, wider than both housing and jet
        if height <= 0:
            return False
        tip = LIP - height
        if py < tip:
            return False
        # Along the jet: 0 at the lip, 1 at the tip.
        along = (LIP - py) / height
        half = 3.3 * (1.0 - along ** 1.8) + 0.7 * math.sin(along * 7.0 + index)
        return abs(dx - lean * along * along) <= max(half, 0.0)

    return keyline(rasterize(inside))


def sheet(frames):
    strip = Image.new("RGBA", (TILE * len(frames), TILE), CLEAR)
    for index, frame in enumerate(frames):
        strip.paste(frame, (index * TILE, 0))
    return strip


# --------------------------------------------------------------------------
# Previews. The art is one bit and the game tints it, so these stand in the
# cave's own colours rather than on white: a keyline that reads on a light page
# can still vanish against the rock it will actually be drawn over.
# --------------------------------------------------------------------------

PREVIEW_SCALE = 6
ROCK = (28, 24, 34, 255)
CAVE_TINT = (227, 156, 115)


def tinted(frame):
    """One frame as the shallow-cave zone renders it."""
    out = Image.new("RGBA", frame.size, ROCK)
    for y in range(frame.height):
        for x in range(frame.width):
            r, g, b, a = frame.getpixel((x, y))
            if not a:
                continue
            out.putpixel((x, y), (r * CAVE_TINT[0] // 255,
                                  g * CAVE_TINT[1] // 255,
                                  b * CAVE_TINT[2] // 255, 255))
    return out


def upscale(image):
    return image.resize((image.width * PREVIEW_SCALE,
                         image.height * PREVIEW_SCALE), Image.NEAREST)


def save_loop(frames, path, duration):
    shown = [upscale(tinted(frame)).convert("P", palette=Image.ADAPTIVE)
             for frame in frames]
    shown[0].save(path, save_all=True, append_images=shown[1:],
                  duration=duration, loop=0)


# --------------------------------------------------------------------------

# Tile 18 is lava and carries no art; 19 onwards were free.
NEW_TILES = {
    19: DRIPSTONE,
    20: CRYSTALS,
    21: MASONRY,
    22: ARROW_SLIT,
    23: BINARY,
}


def main():
    sawblade = [sawblade_frame(i, 4) for i in range(4)]
    flame_vent = [flame_vent_frame(i) for i in range(len(FLAME_HEIGHTS))]

    world_path = os.path.join(ASSETS, "world.png")
    world = Image.open(world_path).convert("RGBA")
    grown = Image.new("RGBA", (SHEET_COLS * TILE, SHEET_ROWS * TILE), CLEAR)
    grown.paste(world, (0, 0))

    # The editor and the tilemap both index this sheet, so an entity's tile has
    # to show the entity: its resting frame is what the level designer places.
    tiles = dict(NEW_TILES)
    tiles[24] = sawblade[0]
    tiles[25] = flame_vent[len(FLAME_HEIGHTS) - 1]
    for index, tile in tiles.items():
        grown.paste(tile, (index % SHEET_COLS * TILE, index // SHEET_COLS * TILE))
    grown.save(world_path)

    sheet(sawblade).save(os.path.join(ASSETS, "sawblade.png"))
    sheet(flame_vent).save(os.path.join(ASSETS, "flamevent.png"))

    # Previews, for reviewing the art without starting the game.
    save_loop(sawblade, os.path.join(HERE, "sawblade-spin.gif"), 1000 // 16)
    # The vent rests far longer than it burns, so the preview holds each frame
    # for the share of the cycle the game gives it.
    save_loop([flame_vent[0]] * 6 + [flame_vent[0], flame_vent[1]] * 2 +
              [flame_vent[3], flame_vent[2]] * 3,
              os.path.join(HERE, "flamevent-cycle.gif"), 1000 // 8)
    strip = Image.new("RGBA", (TILE * len(tiles), TILE), CLEAR)
    for slot, index in enumerate(sorted(tiles)):
        strip.paste(tinted(tiles[index]), (slot * TILE, 0))
    upscale(strip).save(os.path.join(HERE, "tiles.png"))

    print(f"world.png now {SHEET_COLS}x{SHEET_ROWS} tiles; "
          f"added {sorted(tiles)}")
    print(f"sawblade.png {len(sawblade)} frames, "
          f"flamevent.png {len(flame_vent)} frames")


if __name__ == "__main__":
    main()
