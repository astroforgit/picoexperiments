#!/usr/bin/env python3
"""Convert the generated Sójka artwork into compact VBXE screen data."""

from pathlib import Path
import gzip
import textwrap
from PIL import Image, ImageDraw, ImageEnhance, ImageFont


ATARI_DIR = Path(__file__).resolve().parent
PROJECT_DIR = ATARI_DIR.parent
ASSET_DIR = PROJECT_DIR / "assets"
GENERATED_DIR = ATARI_DIR / "generated"
WIDTH, HEIGHT = 160, 100
MISSILE_WIDTH, MISSILE_HEIGHT = 168, 39

# A screen-only 16-colour palette. The game palette is restored before play.
PALETTE = [
    (3, 1, 10),       # 0  void
    (7, 6, 22),       # 1  black violet
    (6, 21, 48),      # 2  deep navy
    (7, 44, 80),      # 3  midnight blue
    (8, 74, 117),     # 4  blue
    (26, 119, 151),   # 5  cyan blue
    (81, 163, 166),   # 6  faded cyan
    (226, 240, 222),  # 7  ivory
    (30, 20, 17),     # 8  sepia black
    (62, 39, 29),     # 9  dark umber
    (96, 62, 39),     # 10 brown
    (139, 92, 53),    # 11 warm brown
    (185, 135, 75),   # 12 antique gold
    (210, 187, 122),  # 13 parchment
    (82, 63, 131),    # 14 nebula violet
    (146, 208, 70),   # 15 gravity green
]

# Runtime palette used by the playable rooms. The level-06 missile uses this
# palette so displaying it does not require changing any game colours.
GAME_PALETTE = [
    (0, 0, 0), (7, 3, 17), (14, 7, 27), (5, 31, 57),
    (7, 111, 145), (226, 243, 228), (70, 135, 143), (14, 7, 27),
    (148, 227, 68), (239, 255, 158), (148, 227, 68), (245, 79, 119),
    (38, 177, 218), (150, 236, 255), (70, 135, 143), (255, 255, 255),
    (3, 1, 10),
    (0, 57, 166),     # 17 Russian-flag blue
    (213, 43, 30),    # 18 Russian-flag red
]

STORY_PAGES = (
    "Sójka straciła swoje ukochane gniazdo. Zagubiona rosyjska rakieta "
    "trafiła prosto w drzewo, na którym się znajdowało. Jednak każdy bardziej "
    "wtajemniczony znawca ptaków wie, że ptaki nie umierają — a już szczególnie "
    "sójki. Po prostu trafiają w inne miejsca. Nasza Sójka przeniosła się do "
    "równoległego wszechświata. Nie ma już drogi powrotnej.",
    "To świat pełen unoszących się wysp, odwróconej grawitacji i "
    "niebezpiecznych pułapek. Zbierając klucze, otwierając międzywymiarowe "
    "przejścia i pokonując kolejne przeszkody, Sójka przemierza obcy kosmos "
    "w poszukiwaniu bezpiecznego miejsca.\n"
    "Jej celem nie jest już odnalezienie starego gniazda. Musi znaleźć tutaj "
    "nowy dom — gniazdo z widokiem na cały wszechświat.",
)

FONT_PATH = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
STORY_FONT_PATH = Path("/usr/share/consolefonts/Uni2-VGA8.psf.gz")


def font(size):
    return ImageFont.truetype(FONT_PATH, size=size)


def centered_text(draw, y, text, size, fill, stroke=0):
    selected = font(size)
    bounds = draw.textbbox((0, 0), text, font=selected, stroke_width=stroke)
    x = (WIDTH - (bounds[2] - bounds[0])) // 2
    draw.text((x, y), text, font=selected, fill=fill,
              stroke_width=stroke, stroke_fill=PALETTE[0])


def prepare_source(path):
    source = Image.open(path).convert("RGB")
    source = ImageEnhance.Contrast(source).enhance(1.08)
    # Reduce the generated art to an Atari-sized pixel grid first, then double
    # it. Text is added afterward at the full logical resolution so it stays
    # crisp while the illustration compresses into a small RLE segment.
    source = source.resize((WIDTH // 2, HEIGHT // 2), Image.Resampling.BOX)
    return source.resize((WIDTH, HEIGHT), Image.Resampling.NEAREST)


def prepare_title_source(path):
    # The close portrait has large shapes and compresses well enough to retain
    # the complete 160x100 logical resolution.
    source = Image.open(path).convert("RGB")
    source = ImageEnhance.Contrast(source).enhance(1.08)
    return source.resize((WIDTH, HEIGHT), Image.Resampling.BOX)


def shift_title_portrait(image):
    shifted = Image.new("RGB", (WIDTH, HEIGHT), PALETTE[0])
    shifted.paste(image, (0, 11))
    return shifted


def add_title_copy(image):
    overlay = Image.new("RGBA", (WIDTH, HEIGHT), (0, 0, 0, 0))
    overlay_draw = ImageDraw.Draw(overlay)
    overlay_draw.rectangle((0, 68, WIDTH - 1, HEIGHT - 1), fill=(*PALETTE[0], 210))
    image = Image.alpha_composite(image.convert("RGBA"), overlay).convert("RGB")
    draw = ImageDraw.Draw(image)
    centered_text(draw, 2, "SÓJKA", 25, PALETTE[13], stroke=1)
    centered_text(draw, 70, "GAME WRITTEN BY KULTISTI", 7, PALETTE[7])
    centered_text(draw, 80, "ATARI PORT BY ASTROFOR", 7, PALETTE[6])
    centered_text(draw, 90, "FIRE OR SPACE TO START", 6, PALETTE[15])
    return image


def add_ending_copy(image):
    overlay = Image.new("RGBA", (WIDTH, HEIGHT), (0, 0, 0, 0))
    overlay_draw = ImageDraw.Draw(overlay)
    overlay_draw.rectangle((0, 69, WIDTH - 1, HEIGHT - 1), fill=(*PALETTE[0], 220))
    image = Image.alpha_composite(image.convert("RGBA"), overlay).convert("RGB")
    draw = ImageDraw.Draw(image)
    centered_text(draw, 70, "YOU HAVE FOUND A NEW NEST", 7, PALETTE[13])
    centered_text(draw, 79, "WITH A VIEW TO THE WHOLE UNIVERSE", 7, PALETTE[7])
    centered_text(draw, 91, "FIRE OR SPACE TO REPLAY", 6, PALETTE[15])
    return image


def wrap_pixels(draw, text, selected_font, width):
    lines = []
    for paragraph in text.split("\n"):
        words = paragraph.split()
        line = ""
        for word in words:
            candidate = word if not line else f"{line} {word}"
            if draw.textlength(candidate, font=selected_font) <= width:
                line = candidate
            else:
                lines.append(line)
                line = word
        if line:
            lines.append(line)
        lines.append(None)
    return lines[:-1]


def make_story_screen(text, page_number):
    image = Image.new("RGB", (WIDTH, HEIGHT), PALETTE[0])
    mask = Image.new("1", (WIDTH, HEIGHT), 0)
    draw = ImageDraw.Draw(mask)
    selected_font = ImageFont.truetype(
        "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", size=7
    )
    lines = wrap_pixels(draw, text, selected_font, WIDTH - 6)
    y = 3
    for line in lines:
        if line is None:
            continue
        draw.text((3, y), line, font=selected_font, fill=1)
        y += 8
    if y > 93:
        raise RuntimeError(
            f"Story page {page_number} exceeds its screen: final text y={y}"
        )
    footer_font = ImageFont.truetype(FONT_PATH, size=6)
    footer = f"{page_number}/2  FIRE / SPACE"
    footer_width = draw.textbbox((0, 0), footer, font=footer_font)[2]
    draw.text(((WIDTH - footer_width) // 2, 93), footer, font=footer_font, fill=1)
    image.paste(PALETTE[7], mask=mask)
    return image


def read_psf1(path):
    data = gzip.open(path, "rb").read()
    if data[:2] != b"\x36\x04":
        raise RuntimeError(f"Unsupported console font: {path}")
    mode, char_size = data[2], data[3]
    glyph_count = 512 if mode & 1 else 256
    glyph_start = 4
    glyphs = [
        data[glyph_start + index * char_size:glyph_start + (index + 1) * char_size]
        for index in range(glyph_count)
    ]
    unicode_map = {}
    position = glyph_start + glyph_count * char_size
    glyph_index = 0
    while glyph_index < glyph_count and position + 1 < len(data):
        value = int.from_bytes(data[position:position + 2], "little")
        position += 2
        if value == 0xFFFF:
            glyph_index += 1
        elif value != 0xFFFE:
            unicode_map.setdefault(chr(value), glyph_index)
    return glyphs, unicode_map


def story_lines(text):
    lines = []
    for paragraph in text.split("\n"):
        lines.extend(textwrap.wrap(
            paragraph, width=38, break_long_words=False, break_on_hyphens=False
        ))
        lines.append("")
    return lines[:-1]


def write_story_text():
    glyphs, unicode_map = read_psf1(STORY_FONT_PATH)
    pages = []
    all_characters = {" "}
    for page_number, text in enumerate(STORY_PAGES, start=1):
        lines = story_lines(text)
        if len(lines) > 19:
            raise RuntimeError(f"Story page {page_number} needs {len(lines)} text rows")
        screen = [" " * 40 for _ in range(23)]
        for row, line in enumerate(lines, start=1):
            screen[row] = f" {line}".ljust(40)[:40]
        footer = f"{page_number}/2  FIRE / SPACE"
        screen[21] = footer.center(40)
        pages.append(screen)
        all_characters.update("".join(screen))

    ordered_characters = [" "] + sorted(all_characters - {" "})
    if len(ordered_characters) > 128:
        raise RuntimeError("Story charset exceeds ANTIC's 128-glyph text mode")
    screen_codes = {character: index for index, character in enumerate(ordered_characters)}
    charset = bytearray(1024)
    for character, screen_code in screen_codes.items():
        source_character = "-" if character == "—" and character not in unicode_map else character
        if source_character not in unicode_map:
            raise RuntimeError(f"The VGA story font lacks {character!r}")
        glyph = glyphs[unicode_map[source_character]]
        charset[screen_code * 8:screen_code * 8 + 8] = glyph[:8]

    encoded_pages = [
        bytes(screen_codes[character] for row in page for character in row) + bytes(80)
        for page in pages
    ]
    lines = ["        org $A000", "story_charset"]
    for start in range(0, len(charset), 32):
        values = ",".join(f"${value:02X}" for value in charset[start:start + 32])
        lines.append(f"        dta {values}")
    for page_number, (origin, page) in enumerate(
        zip((0xA400, 0xA800), encoded_pages), start=1
    ):
        lines.extend([f"        org ${origin:04X}", f"story_page_{page_number}"])
        for start in range(0, len(page), 40):
            values = ",".join(f"${value:02X}" for value in page[start:start + 40])
            lines.append(f"        dta {values}")
    lines.append("")
    (GENERATED_DIR / "sojka-story-text.inc").write_text(
        "\n".join(lines), encoding="ascii"
    )

    for page_number, page in enumerate(encoded_pages, start=1):
        preview_image = Image.new("RGB", (320, 200), (0, 0, 0))
        pixels = preview_image.load()
        for row in range(23):
            for column in range(40):
                glyph = charset[page[row * 40 + column] * 8:][:8]
                for glyph_y, bits in enumerate(glyph):
                    for glyph_x in range(8):
                        if bits & (0x80 >> glyph_x):
                            pixels[column * 8 + glyph_x, 16 + row * 8 + glyph_y] = PALETTE[7]
        preview_image.save(ASSET_DIR / f"sojka-story-{page_number}-vbxe.png")
    return [len(story_lines(text)) for text in STORY_PAGES]


def quantize(image):
    indices = []
    for red, green, blue in image.getdata():
        indices.append(min(
            range(len(PALETTE)),
            key=lambda index: (
                (red - PALETTE[index][0]) ** 2
                + (green - PALETTE[index][1]) ** 2
                + (blue - PALETTE[index][2]) ** 2
            ),
        ))
    return indices


def encode_runs(indices):
    encoded = []
    for y in range(HEIGHT):
        row = indices[y * WIDTH:(y + 1) * WIDTH]
        x = 0
        while x < WIDTH:
            colour = row[x]
            length = 1
            while x + length < WIDTH and row[x + length] == colour and length < 16:
                length += 1
            encoded.append((colour << 4) | (length - 1))
            x += length
    return encoded


def preview(indices, destination):
    image = Image.new("P", (WIDTH, HEIGHT))
    flat_palette = [component for colour in PALETTE for component in colour]
    image.putpalette(flat_palette + [0] * (768 - len(flat_palette)))
    image.putdata(indices)
    image.resize((320, 200), Image.Resampling.NEAREST).save(destination)


def write_data(label, origin, encoded, destination, capacity):
    if len(encoded) + 2 > capacity:
        raise RuntimeError(
            f"{label} needs {len(encoded) + 2} bytes but its segment holds {capacity}"
        )
    lines = [
        f"        org ${origin:04X}",
        f"{label}",
        f"        dta a({len(encoded)})",
    ]
    for start in range(0, len(encoded), 24):
        values = ",".join(f"${value:02X}" for value in encoded[start:start + 24])
        lines.append(f"        dta {values}")
    lines.extend([f"{label}_end", ""])
    destination.write_text("\n".join(lines), encoding="ascii")


def write_palette():
    lines = ["screen_palette"]
    for index, (red, green, blue) in enumerate(PALETTE):
        lines.append(f"        dta {index},{red},{green},{blue}")
    lines.extend(["        dta $FF", ""])
    (GENERATED_DIR / "sojka-screen-palette.inc").write_text(
        "\n".join(lines), encoding="ascii"
    )


def prepare_missile(path):
    """Reduce the generated illustration to a transparent in-game run sprite."""
    source = Image.open(path).convert("RGBA")
    alpha_box = source.getchannel("A").getbbox()
    if alpha_box:
        source = source.crop(alpha_box)
    source.thumbnail((MISSILE_WIDTH, MISSILE_HEIGHT), Image.Resampling.BOX)
    reduced = Image.new("RGBA", (MISSILE_WIDTH, MISSILE_HEIGHT), (0, 0, 0, 0))
    reduced.paste(
        source,
        ((MISSILE_WIDTH - source.width) // 2, (MISSILE_HEIGHT - source.height) // 2),
    )

    pixels = []
    for red, green, blue, alpha in reduced.getdata():
        if alpha < 32:
            pixels.append(None)
            continue
        pixels.append(min(
            (3, 4, 5, 6, 8, 13, 15, 17, 18),
            key=lambda index: (
                (red - GAME_PALETTE[index][0]) ** 2
                + (green - GAME_PALETTE[index][1]) ** 2
                + (blue - GAME_PALETTE[index][2]) ** 2
            ),
        ))
    return pixels


def missile_runs(indices):
    runs = []
    for y in range(MISSILE_HEIGHT):
        row = indices[y * MISSILE_WIDTH:(y + 1) * MISSILE_WIDTH]
        x = 0
        while x < MISSILE_WIDTH:
            colour = row[x]
            if colour is None:
                x += 1
                continue
            length = 1
            while x + length < MISSILE_WIDTH and row[x + length] == colour:
                length += 1
            runs.append((x, y, length, colour))
            x += length
    return runs


def write_missile(indices):
    runs = missile_runs(indices)
    byte_count = len(runs) * 4 + 1
    if byte_count > 0x0B00:
        raise RuntimeError(
            f"level06_missile_pixels needs {byte_count} bytes but its segment holds 2816"
        )
    lines = ["        org $8500", "level06_missile_pixels"]
    for x, y, width, colour in runs:
        lines.append(f"        dta {x},{y},{width},{colour}")
    lines.extend(["        dta $FF", "level06_missile_pixels_end", ""])
    (GENERATED_DIR / "sojka-level06-missile.inc").write_text(
        "\n".join(lines), encoding="ascii"
    )

    preview = Image.new("P", (MISSILE_WIDTH, MISSILE_HEIGHT), 0)
    flat_palette = [component for colour in GAME_PALETTE for component in colour]
    preview.putpalette(flat_palette + [0] * (768 - len(flat_palette)))
    preview.putdata([0 if value is None else value for value in indices])
    enlarged = preview.resize((MISSILE_WIDTH * 3, MISSILE_HEIGHT * 3), Image.Resampling.NEAREST)
    enlarged.save(ASSET_DIR / "sojka-level06-missile-vbxe.png", transparency=0)
    enlarged.save(PROJECT_DIR / "editor" / "sojka-level06-missile-vbxe.png", transparency=0)
    return len(runs)


def main():
    GENERATED_DIR.mkdir(parents=True, exist_ok=True)
    title = add_title_copy(shift_title_portrait(
        prepare_title_source(ASSET_DIR / "sojka-title-torso-source.png")
    ))
    ending = add_ending_copy(prepare_source(ASSET_DIR / "sojka-ending-gothic-source.png"))
    title_indices = quantize(title)
    ending_indices = quantize(ending)
    missile_indices = prepare_missile(ASSET_DIR / "sojka-level06-missile-v2-source.png")

    preview(title_indices, ASSET_DIR / "sojka-title-vbxe.png")
    preview(ending_indices, ASSET_DIR / "sojka-ending-vbxe.png")
    write_palette()
    story_line_counts = write_story_text()
    missile_run_count = write_missile(missile_indices)
    write_data(
        "ending_screen_rle", 0x6000, ending_indices and encode_runs(ending_indices),
        GENERATED_DIR / "sojka-ending-screen.inc", 0x1000,
    )
    write_data(
        "title_screen_rle", 0x7400, title_indices and encode_runs(title_indices),
        GENERATED_DIR / "sojka-title-screen.inc", 0x1C00,
    )
    print(
        "Generated VBXE screens:",
        f"title={len(encode_runs(title_indices))} bytes,",
        f"ending={len(encode_runs(ending_indices))} bytes,",
        f"story pages={story_line_counts[0]}/{story_line_counts[1]} text rows,",
        f"level-06 missile={missile_run_count} runs",
    )


if __name__ == "__main__":
    main()
