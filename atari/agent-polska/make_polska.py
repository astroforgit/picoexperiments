#!/usr/bin/env python3
"""Make agent-polska.xex: Agent USA with Polish cities and a map of Poland.

The game code is not changed. This script patches the data tables of the
original XEX (addresses as in ../agent/decompiled/agent.asm):

  map_rle      $7FAA  the map, run-length packed (outline of Poland)
  city_names   $A37B  pointers, names at $A50D (ASCII, no Polish letters)
  city_xy      $A443  map position of every city
  city_links   $A2B1  pointers, rail links at $9B55
  city_station $4B73  time zone (all the same), layout and number of people
  city_flags   $AFF3  InfoBooth (voivodeship seat), skyline type and offset
  city_left/right/up/down $99C4..  InfoBooth joystick navigation

and three story texts that mention America and state capitals.

The cities, the outline and the rail network come from
../agent/web/generate_data.py, the same data as the Agent Polska atlas.
Express trains become the game's "special" links (bit 7): you cannot board
them without a ticket, and fuzz does not spread along them.

Usage: python3 make_polska.py   (writes agent-polska.xex next to it)
"""
import importlib.util
import math
import random
import sys
import unicodedata
from pathlib import Path

HERE = Path(__file__).resolve().parent
ORIG = HERE.parent / "agent" / "Agent USA (1984)(Scholastic Wizware)(US).xex"
OUT = HERE / "agent-polska.xex"
WEB = HERE.parent / "agent" / "web" / "generate_data.py"

SEG_START, SEG_END = 0x21FF, 0xB87F          # the one big segment
MAP_RLE, MAP_END = 0x7FAA, 0x85D2
NAME_PTRS, NAMES, NAMES_END = 0xA37B, 0xA50D, 0xAA4E
CITY_XY = 0xA443
LINK_PTRS, LINKS, LINKS_END = 0xA2B1, 0x9B55, 0xA2B0
CITY_STATION, CITY_FLAGS = 0x4B73, 0xAFF3
NAV = {"left": 0x99C4, "right": 0x9A28, "up": 0x9A8C, "down": 0x9AF0}
MAX_NAME = 18                                # status line, ticket typing

# names that do not fit in 18 characters, or that contain a hyphen (the
# ticket counter accepts letters, digits, space, comma and full stop)
SHORT = {
    "Ostrowiec Świętokrzyski": "OSTROWIEC SW.",
    "Piotrków Trybunalski": "PIOTRKOW TRYB.",
    "Gorzów Wielkopolski": "GORZOW WLKP.",
    "Ostrów Wielkopolski": "OSTROW WLKP.",
    "Tomaszów Mazowiecki": "TOMASZOW MAZ.",
}

# story texts: same length as the original, so the messages keep their size
TEXTS = [
    ("         Somewhere in America,", "          Somewhere in Poland,"),
    ("    You, Agent U.S.A., are the only",
     "    You, Agent Polska, are the only"),
    ("    InfoBooth in each state capital.",
     " InfoBooth in each voivodeship seat."),
]


def ascii_name(name):
    """WARSZAWA: upper case, no Polish letters, no hyphens."""
    if name in SHORT:
        return SHORT[name]
    s = name.replace("ł", "l").replace("Ł", "L")
    s = unicodedata.normalize("NFKD", s).encode("ascii", "ignore").decode()
    return s.upper().replace("-", " ")


def screen(text):
    """ASCII to ANTIC screen codes, as MADS d'...' does."""
    out = bytearray()
    for ch in text:
        c = ord(ch)
        assert 0x20 <= c < 0x60 or 0x61 <= c <= 0x7A, ch
        out.append(c - 0x20 if c < 0x60 else c)
    return bytes(out)


def pack_map(bitmap):
    """The game's map format: a non-zero byte is copied, 0,n is n zero
    bytes, 0,0 ends."""
    out = bytearray()
    i = 0
    while i < len(bitmap):
        if bitmap[i]:
            out.append(bitmap[i])
            i += 1
            continue
        n = 0
        while i < len(bitmap) and not bitmap[i] and n < 255:
            n += 1
            i += 1
        out += bytes((0, n))
    return bytes(out + b"\0\0")


def load_web():
    spec = importlib.util.spec_from_file_location("poland", WEB)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def main():
    web = load_web()
    raw = bytearray(ORIG.read_bytes())
    assert raw[:6] == bytes((0xFF, 0xFF, 0xFF, 0x21, 0x7F, 0xB8))

    def off(addr):
        assert SEG_START <= addr <= SEG_END
        return 6 + addr - SEG_START

    def put(addr, data, end=None):
        if end is not None:
            assert addr + len(data) - 1 <= end, (hex(addr), len(data), hex(end))
        raw[off(addr):off(addr) + len(data)] = data

    # ---- cities, in alphabetical order of their game names
    rng = random.Random(web.SEED)
    cities = []
    for i, (name, region, lat, lon, pop) in enumerate(web.CITIES, 1):
        gx, gy = web.to_grid(lon, lat)
        cities.append(dict(id=i, name=name, region=region, lat=lat, lon=lon,
                           pop=pop, gx=gx, gy=gy))
    links = web.build_rails(cities, rng)
    for c in cities:
        c["game"] = ascii_name(c["name"])
        assert len(c["game"]) <= MAX_NAME, c["game"]
    # alphabetical, but RADOMSKO before RADOM: the ticket counter takes the
    # first name in the list that the typed text starts with
    order = sorted(cities, key=lambda c: c["game"] + "~")
    num = {c["id"]: n for n, c in enumerate(order, 1)}   # web id -> game number
    names = [c["game"] for c in order]
    assert len(set(names)) == 100
    for i, a in enumerate(names):       # no name is a prefix of a later one
        assert not any(b.startswith(a) for b in names[i + 1:]), a

    # names
    blob, ptrs = bytearray(), []
    for name in names:
        ptrs.append(NAMES + len(blob))
        blob += screen(name) + b"\xFF"
    put(NAMES, bytes(blob), NAMES_END)
    for n, p in enumerate(ptrs, 1):
        put(NAME_PTRS + 2 * n, bytes((p & 255, p >> 8)))

    # map positions
    for n, c in enumerate(order, 1):
        x, y = round(c["gx"]), round(c["gy"])
        assert 0 <= x < 160 and 0 <= y < 159
        put(CITY_XY + 2 * n, bytes((x, y)))

    # rail links: two departures a day to each destination, slots n and n+8,
    # listed by slot (the departures board needs them in order)
    blob, ptrs = bytearray(), []
    for c in order:
        dests = [(next(iter(k - {c["id"]})), express)
                 for k, express in links.items() if c["id"] in k]
        dests.sort(key=lambda d: web.km(c, cities[d[0] - 1]))
        assert 2 <= len(dests) <= 8
        entries = []
        for n, (dest, express) in enumerate(dests):
            d = web.km(c, cities[dest - 1])
            ride = min(15, int(d / (45 if express else 28)))
            for slot in (n, n + 8):
                entries.append((slot, num[dest] | (0x80 if express else 0),
                                ride << 4 | slot))
        ptrs.append(LINKS + len(blob))
        for _, dest, info in sorted(entries):
            blob += bytes((dest, info))
        blob.append(0)
    put(LINKS, bytes(blob), LINKS_END)
    for n, p in enumerate(ptrs, 1):
        put(LINK_PTRS + 2 * n, bytes((p & 255, p >> 8)))

    # station and flags bytes, navigation
    for n, c in enumerate(order, 1):
        people = min(10, 3 + int(math.log2(max(c["pop"], 20) / 20)))
        layout = people - 3                 # the same bits give both
        skyline = 4 if c["pop"] >= 500 else 3 if c["pop"] >= 150 else \
            2 if c["pop"] >= 60 else rng.choice((0, 1))
        capital = c["name"] in web.SEATS
        put(CITY_STATION + n, bytes((layout << 1,)))     # time zone 0 for all
        put(CITY_FLAGS + n,
            bytes((capital << 7 | skyline << 4 | rng.randrange(16),)))
        for direction, base in NAV.items():
            dx, dy = {"left": (-1, 0), "right": (1, 0),
                      "up": (0, -1), "down": (0, 1)}[direction]
            target = web.nearest_in_direction(c, cities, dx, dy)
            put(base + n, bytes((num[target],)))

    # map: the outline in colour 3 (the game ANDs it with $55 -> colour 1)
    bitmap = bytearray(160 * 40)
    for x, y, width in web.outline_runs():
        for px in range(x, x + width):
            if 0 <= px < 160 and 0 <= y < 160:
                bitmap[y * 40 + px // 4] |= 3 << (6 - 2 * (px & 3))
    put(MAP_RLE, pack_map(bitmap), MAP_END)

    # story texts
    for old, new in TEXTS:
        assert len(old) == len(new)
        a, b = screen(old), screen(new)
        i = raw.find(a)
        assert i > 0 and raw.find(a, i + 1) < 0, old
        raw[i:i + len(a)] = b

    OUT.write_bytes(raw)
    express = sum(links.values())
    print(f"{OUT.name}: {len(names)} cities, {len(links)} rail links "
          f"({express} express), map {len(pack_map(bitmap))} bytes")


if __name__ == "__main__":
    sys.exit(main())
