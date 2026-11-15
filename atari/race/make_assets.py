#!/usr/bin/env python3
"""Extract Pico Off Road courses, track art, and car mesh from the .p8 source."""
from pathlib import Path
import re
import math
import heapq
from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / 'allgames/[Race]/Pico Off Road.p8'
OUT = Path(__file__).resolve().parent
TITLE_ART = OUT / 'title-art-arcade-v2.png'


def decompress(src):
    out = bytearray()
    i = 0
    while i < len(src):
        c = src[i]
        if c >= 189:
            out.append(c)
            i += 1
            continue
        offset = c - 93
        run = src[i + 1] - 29
        if run >= 65:
            run -= 29
        if offset <= 0 or offset > len(out):
            raise ValueError('invalid course back-reference')
        for _ in range(run):
            out.append(out[-offset])
        i += 2
    if len(out) != 4096:
        raise ValueError(f'expected 4096 tiles, got {len(out)}')
    return out


def convert(data):
    tiles = bytearray()
    waypoints = [[] for _ in range(15)]
    for index, value in enumerate(data):
        x, z = index % 64, index // 64
        if value == 189:
            kind = 11
        elif value == 190:
            kind = 11
        elif value <= 205:
            kind = 11
            waypoints[value - 191].append((x * 8 + 4, z * 8 + 4))
            tiles.append(0x80 | (value - 191))
            continue
        elif value <= 230:
            kind = (value - 206) % 5 + 1
        else:
            kind = (value - 231) % 5 + 6
        # Keep the road and boundary types, but make every course tile flat.
        tiles.append(kind)
    if any(not group for group in waypoints):
        raise ValueError('course is missing a waypoint')
    return tiles, [(sum(x for x, _ in group) // len(group),
                    sum(z for _, z in group) // len(group)) for group in waypoints]


def make_ai_route(tiles, waypoints):
    """Find a wall-safe line between checkpoints and retain each turn."""
    checkpoints = [(x // 8, z // 8) for x, z in waypoints]
    route = []
    for index, start in enumerate(checkpoints):
        goal = checkpoints[(index + 1) % len(checkpoints)]
        queue = [(0, start)]
        cost = {start: 0}
        previous = {}
        while queue:
            distance, position = heapq.heappop(queue)
            if distance != cost[position]:
                continue
            if position == goal:
                break
            x, z = position
            for nx, nz in (((x + 1) % 64, z), ((x - 1) % 64, z),
                           (x, z + 1), (x, z - 1)):
                if not 0 <= nz < 64:
                    continue
                kind = tiles[nz * 64 + nx]
                if 6 <= kind <= 10:
                    continue
                next_cost = distance + 10 + (2 if kind == 11 else 0)
                if next_cost < cost.get((nx, nz), 1 << 30):
                    cost[nx, nz] = next_cost
                    previous[nx, nz] = position
                    heapq.heappush(queue, (next_cost, (nx, nz)))
        if goal not in cost:
            raise ValueError(f'no driveable route from waypoint {index}')
        path = [goal]
        while path[-1] != start:
            path.append(previous[path[-1]])
        path.reverse()
        for offset in range(1, len(path)):
            before = path[offset - 1]
            here = path[offset]
            incoming = ((here[0] - before[0] + 32) % 64 - 32,
                        here[1] - before[1])
            direction = {(1, 0): 0, (-1, 0): 1,
                         (0, 1): 2, (0, -1): 3}[incoming]
            if offset == len(path) - 1:
                route.append((*here, direction))
                continue
            after = path[offset + 1]
            outgoing = ((after[0] - here[0] + 32) % 64 - 32,
                        after[1] - here[1])
            if incoming != outgoing:
                route.append((*here, direction))
    if len(route) > 50:
        raise ValueError('AI route is too long for one-byte indexing')
    return [(x * 8 + 4, z * 8 + 4, direction)
            for x, z, direction in route]


def make_title_scene():
    """Build a full-width title image with the logo baked into its pixels."""
    image = Image.open(TITLE_ART).convert('RGB').resize(
        (320, 160), Image.Resampling.NEAREST)
    arcade_colours = [
        (5, 5, 30), (20, 7, 80), (35, 35, 155), (32, 112, 245),
        (46, 219, 255), (110, 32, 190), (209, 25, 207),
        (250, 91, 209), (225, 18, 31), (255, 81, 39),
        (142, 55, 44), (253, 149, 82), (255, 202, 139),
        (239, 237, 235), (92, 88, 114),
    ]
    palette_image = Image.new('P', (1, 1))
    palette_image.putpalette([component for colour in arcade_colours
                              for component in colour] + [0] * (256 * 3 - 45))
    indexed = image.quantize(palette=palette_image, dither=Image.Dither.NONE)
    palette = indexed.getpalette()
    scene = Image.frombytes('P', image.size,
                            bytes(value + 48 for value in indexed.getdata()))
    scene_palette = [0] * (256 * 3)
    logo_colours = {0: (6, 13, 20), 1: (235, 242, 231),
                    2: (246, 204, 80), 3: (56, 170, 203),
                    4: (222, 67, 51), 40: (36, 151, 242),
                    41: (255, 163, 0), 44: (41, 173, 255)}
    for index, rgb in logo_colours.items():
        scene_palette[index * 3:index * 3 + 3] = rgb
    for index in range(15):
        scene_palette[(48 + index) * 3:(49 + index) * 3] = palette[index * 3:index * 3 + 3]
    scene.putpalette(scene_palette)
    # A hand-drawn 5x7 arcade font stays crisp at native VBXE resolution.
    glyphs = {
        'A': ('01110', '10001', '10001', '11111', '10001', '10001', '10001'),
        'B': ('11110', '10001', '10001', '11110', '10001', '10001', '11110'),
        'C': ('01111', '10000', '10000', '10000', '10000', '10000', '01111'),
        'E': ('11111', '10000', '10000', '11110', '10000', '10000', '11111'),
        'I': ('11111', '00100', '00100', '00100', '00100', '00100', '11111'),
        'K': ('10001', '10010', '10100', '11000', '10100', '10010', '10001'),
        'N': ('10001', '11001', '10101', '10101', '10011', '10001', '10001'),
        'R': ('11110', '10001', '10001', '11110', '10100', '10010', '10001'),
    }
    draw = ImageDraw.Draw(scene)
    for word, left, top, shades in (
            ('BIKINI', 8, 14, (1, 2, 41, 4)),
            ('RACE', 24, 50, (1, 44, 3, 40))):
        for letter_index, letter in enumerate(word):
            for row, pattern in enumerate(glyphs[letter]):
                shade = shades[min(row // 2, 3)]
                for column, pixel in enumerate(pattern):
                    if pixel == '0':
                        continue
                    x = left + letter_index * 18 + column * 3
                    y = top + row * 3
                    draw.rectangle((x + 2, y + 2, x + 4, y + 4), fill=0)
                    draw.rectangle((x + 1, y + 1, x + 3, y + 3), fill=44)
                    draw.rectangle((x, y, x + 2, y + 2), fill=shade)
    scene.convert('RGB').save(OUT / 'title-scene-preview.png')
    raw = scene.tobytes()
    for part in range(5):
        (OUT / f'title-part{part + 1}.bin').write_bytes(
            raw[part * 40 * 256:(part + 1) * 40 * 256])
    lines = ['; The sixteen colors of the illustrated title scene']
    for index in range(15):
        rgb = palette[index * 3:index * 3 + 3]
        lines.append('        dta ' + ','.join(map(str, [48 + index, *rgb])))
    (OUT / 'title-palette.asm').write_text('\n'.join(lines) + '\n')


def decompress_logo(source):
    """Pico-8 LZ77 stream used by title_image (128 x 32 pixels)."""
    out = bytearray()
    i = 0
    while i < len(source):
        code = source[i]
        if code < 48:
            out.append(code - 32)
        else:
            offset, run = 128, code - 46
            if code >= 94:
                run -= 29
            if run >= 103:
                run -= 101
            else:
                i += 1
                offset = source[i] - 31
                if offset >= 63:
                    offset -= 29
            for _ in range(run):
                out.append(out[-offset])
        i += 1
    if len(out) != 128 * 32:
        raise ValueError('title image size mismatch')
    return bytes(out)


def mesh_values(source, name):
    match = re.search(name.encode() + rb'=\[\[(.*?)\]\]', source, re.S)
    if not match:
        raise ValueError(f'{name} missing')
    values = []
    for byte in match.group(1):
        value = byte - 32
        values.append(value - 29 if value >= 62 else value)
    return values


def rotate_vertex(vertex, angle):
    x, y, z = vertex
    cosine, sine = math.cos(angle), math.sin(angle)
    return x * cosine - z * sine, y, x * sine + z * cosine


def triangle_normal(a, b, c):
    # The source game crosses (c-a) with (b-a), in this order.
    u = [c[i] - a[i] for i in range(3)]
    v = [b[i] - a[i] for i in range(3)]
    return (u[1] * v[2] - u[2] * v[1],
            u[2] * v[0] - u[0] * v[2],
            u[0] * v[1] - u[1] * v[0])


def make_car_sprites(source):
    """Rasterize the cartridge's real car mesh at its original scale of five."""
    packed = mesh_values(source, 'car_verticesc')
    vertices = [tuple(-2.1209 + 0.0215 * packed[i + j] for j in range(3))
                for i in range(0, len(packed), 3)]
    packed = mesh_values(source, 'car_trianglesc')
    triangles = [tuple(packed[i:i + 4]) for i in range(0, len(packed), 4)]
    if len(vertices) != 148 or len(triangles) != 236:
        raise ValueError('unexpected car mesh size')

    # 30/31 are upload-time body/accent markers; zero remains transparent.
    colours = {0: 8, 3: 31, 6: 6, 7: 1, 11: 30}
    pixels = bytearray()
    for frame in range(16):
        angle = frame * math.tau / 16
        transformed = [rotate_vertex(v, angle) for v in vertices]
        # Pico Off Road selects pre-culled faces at the centre of each sector.
        culled = [rotate_vertex(v, angle + math.tau / 32) for v in vertices]
        visible = []
        for a, b, c, colour in triangles:
            nx, ny, nz = triangle_normal(culled[a], culled[b], culled[c])
            if nx * -0.5 + ny * 0.5 + nz < 0:
                depth = (culled[a][2] + culled[b][2] + culled[c][2]) / 3
                visible.append((depth, a, b, c, colour))
        visible.sort(reverse=True)
        image = Image.new('L', (28, 24))
        draw = ImageDraw.Draw(image)
        for _, a, b, c, colour in visible:
            points = [(round(14 + (transformed[i][0] + 0.5 * transformed[i][2]) * 5),
                       round(13 + (transformed[i][1] - 0.5 * transformed[i][2]) * 5))
                      for i in (a, b, c)]
            draw.polygon(points, fill=colours[colour])
        pixels.extend(image.tobytes())
    (OUT / 'car-sprites.bin').write_bytes(pixels)

    lines = ['; VRAM addresses of the 16 mesh views for each of four car colours',
             'car_sprite_addresses:']
    for variant in range(4):
        for frame in range(16):
            address = 0x62000 + (variant * 16 + frame) * 28 * 24
            lines.append(f'    dta ${address & 255:02x},${address >> 8 & 255:02x},${address >> 16:02x}')
    (OUT / 'car-sprite-addrs.asm').write_text('\n'.join(lines) + '\n')


def make_road_art(source, courses):
    """Draw a continuous blue rail around each course's collision walls."""
    def section(name):
        return source.split(('__' + name + '__\n').encode(), 1)[1].split(b'__', 1)[0].splitlines()

    gfx = section('gfx')[:128]
    map_rows = section('map')[:32]
    if len(gfx) != 128 or len(map_rows) != 32:
        raise ValueError('incomplete Pico-8 graphics or map section')
    memory = bytearray(0x3000)
    for y, row in enumerate(gfx):
        for x in range(0, 128, 2):
            memory[y * 64 + x // 2] = int(bytes((row[x + 1], row[x])), 16)
    for y, row in enumerate(map_rows):
        for x in range(0, 256, 2):
            memory[0x2000 + y * 128 + x // 2] = int(row[x:x + 2], 16)

    maps = []
    for upper, lower in ((0x2000, 0x2800), (0x1800, 0x1840), (0x2040, 0x2840)):
        ids = bytearray()
        for address in (upper, lower):
            for offset in range(0, 1921, 128):
                ids.extend(memory[address + offset:address + offset + 64])
        if len(ids) != 64 * 32:
            raise ValueError('unexpected road map size')
        maps.append(ids)

    width, height = 512, 256
    atlas = []
    tile_ids = {}
    rendered_maps = []
    for course, old_map in zip(courses, maps):
        # Project the same wall tiles used by gameplay into the flat view.
        walls = bytearray(width * height)
        for y in range(height):
            z = y * 2 + 1
            for x in range(width):
                world_x = (x + y + 1) % 512
                kind = course[(z // 8) * 64 + world_x // 8]
                walls[y * width + x] = kind < 128 and 6 <= kind <= 10

        # The tile boundary has a staircase at diagonal joins. Blur only the
        # visual silhouette by four pixels; the driving collision data stays
        # on the original map. Repeat 32 pixels on either side so the course
        # wraps cleanly at the horizontal edge.
        mask = Image.frombytes('L', (width, height),
                               bytes(255 if wall else 0 for wall in walls))
        padded = Image.new('L', (width + 64, height))
        padded.paste(mask.crop((width - 32, 0, width, height)), (0, 0))
        padded.paste(mask, (32, 0))
        padded.paste(mask.crop((0, 0, 32, height)), (width + 32, 0))
        smoothed = padded.filter(ImageFilter.GaussianBlur(4)).crop(
            (32, 0, width + 32, height))
        silhouette = bytearray(value >= 128 for value in smoothed.tobytes())

        rim = bytearray(width * height)
        for y in range(height):
            row = y * width
            for x in range(width):
                index = row + x
                if not silhouette[index]:
                    continue
                if (not silhouette[row + (x - 1) % width] or
                        not silhouette[row + (x + 1) % width] or
                        (y > 0 and not silhouette[index - width]) or
                        (y + 1 < height and not silhouette[index + width])):
                    rim[index] = 14 if (x // 24) % 2 == 0 else 7

        # The bright top and blue face are one rail. Building them together
        # prevents the torn, overlapping sprite pieces seen at height changes.
        art = bytearray(width * height)
        for y in range(height):
            row = y * width
            for x in range(width):
                colour = rim[row + x]
                if not colour:
                    continue
                face = 2 if colour == 14 else 13
                for depth in range(1, 5):
                    if y + depth < height:
                        art[(y + depth) * width + x] = face if depth < 4 else 8
        for index, colour in enumerate(rim):
            if colour:
                art[index] = colour

        rendered = bytearray()
        for ty in range(32):
            for tx in range(64):
                pixels = bytearray()
                old_tile = old_map[ty * 64 + tx]
                for py in range(8):
                    y = ty * 8 + py
                    for px in range(8):
                        x = tx * 8 + px
                        index = y * width + x
                        colour = art[index]
                        if not colour:
                            colour = 5 if (px * 5 + py * 3) % 11 == 0 else 4
                        if (133 <= old_tile <= 136 and not walls[index] and
                                colour in (4, 5)):
                            original_x = (old_tile % 16) * 8 + px
                            original_y = (old_tile // 16) * 8 + py
                            marker = int(chr(gfx[original_y][original_x]), 16)
                            if marker in (0, 7, 13):
                                colour = marker
                        pixels.append(colour)
                packed = bytes(pixels[i] | (pixels[i + 1] << 4)
                               for i in range(0, 64, 2))
                if packed not in tile_ids:
                    tile_ids[packed] = len(atlas)
                    atlas.append(packed)
                rendered.append(tile_ids[packed])
        rendered_maps.append(rendered)
    if len(atlas) > 255:
        raise ValueError('too many unique road tiles')
    packed_tiles = b''.join(atlas)
    data = packed_tiles + b''.join(rendered_maps)
    if len(data) > 0x3000:
        raise ValueError(f'road art exceeds the staging area: {len(atlas)} tiles')
    (OUT / 'road-assets.bin').write_bytes(data)
    (OUT / 'road-data.asm').write_text(
        '; Continuous blue barrier art aligned to the flat collision map\n'
        f'ROAD_TILE_COUNT = {len(atlas)}\n'
        f'ROAD_TILE_BYTES = {len(packed_tiles)}\n'
        'road_map1 = road_tile_data + ROAD_TILE_BYTES\n'
        'road_map2 = road_map1 + 2048\n'
        'road_map3 = road_map2 + 2048\n')
    return len(atlas)


def main():
    source = SOURCE.read_bytes()
    lines = ['; Generated from allgames/[Race]/Pico Off Road.p8 by make_assets.py']
    routes = []
    courses = []
    for number in (1, 2, 3):
        match = re.search(rb'racing_map%d=\[\[(.*?)\]\]' % number, source, re.S)
        if not match:
            raise ValueError(f'course {number} missing')
        decompressed = decompress(match.group(1))
        tiles, waypoints = convert(decompressed)
        courses.append(tiles)
        (OUT / f'track{number}.bin').write_bytes(tiles)
        routes.append(make_ai_route(tiles, waypoints))
        starts = re.search(rb'starts_racing_map%d=split\(\'(.*?)\'\)' % number, source)
        if not starts:
            raise ValueError(f'course {number} starts missing')
        positions = [int(v) for v in starts.group(1).split(b',')]
        lines += [f'waypoints{number}:']
        for x, z in waypoints:
            lines.append(f'    dta a({x}),a({z})')
        lines += [f'starts{number}:']
        for index in positions:
            lines.append(f'    dta a({(index % 64) * 8 + 4}),a({(index // 64) * 8 + 4})')
    (OUT / 'course-data.asm').write_text('\n'.join(lines) + '\n')
    route_lines = ['; Driveable checkpoint routes: tile X and packed direction/tile Z',
                   'ai_route_ptrs dta a(ai_route1,ai_route2,ai_route3)',
                   'ai_route_lengths dta ' + ','.join(str(len(route)) for route in routes)]
    for number, route in enumerate(routes, 1):
        route_lines.append(f'ai_route{number}:')
        for x, z, direction in route:
            route_lines.append(f'    dta {x // 8},{z // 8 + direction * 64}')
    (OUT / 'ai-route-data.asm').write_text('\n'.join(route_lines) + '\n')
    make_title_scene()
    make_car_sprites(source)
    road_tiles = make_road_art(source, courses)
    font = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf', 9)
    glyphs = bytearray()
    for code in range(32, 96):
        image = Image.new('L', (8, 8))
        # Keep digits in unused high font slots for the VBXE text blitter.
        digit_slots = 'BJMQXZ[\\]^'
        source_code = 48 + digit_slots.index(chr(code)) if chr(code) in digit_slots else code
        ImageDraw.Draw(image).text((0, -2), chr(source_code), font=font, fill=255)
        glyphs.extend(255 if pixel >= 100 else 0 for pixel in image.getdata())
    (OUT / 'font.bin').write_bytes(glyphs)
    print(f'Extracted 3 tracks, {road_tiles} road tiles and 16 car mesh views')


if __name__ == '__main__':
    main()
