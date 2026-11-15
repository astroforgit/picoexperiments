#!/usr/bin/env python3
"""Export Agent USA's original map and city tables (the USA version of the
atlas). Writes dist/data-usa.json; the app itself now loads the Poland data
from generate_data.py."""

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DECOMPILED = ROOT / "decompiled"
sys.path.insert(0, str(DECOMPILED / "tools"))
from render import unpack_map  # noqa: E402
from xex import load  # noqa: E402

XEX = ROOT / "Agent USA (1984)(Scholastic Wizware)(US).xex"
ASM = DECOMPILED / "agent.asm"
OUT = Path(__file__).resolve().parent / "dist" / "data-usa.json"

_, ram = load(XEX)
source = ASM.read_text()
names = {
    int(number): name
    for number, name in re.findall(r"^name_(\d+)\s+dta d'([^']+)'", source, re.M)
}
assert len(names) == 100


def word(address):
    return ram[address] | ram[address + 1] << 8


bitmap = unpack_map(ram)
assert len(bitmap) == 160 * 40
outline = []
for y in range(160):
    x = 0
    while x < 160:
        bit = (bitmap[y * 40 + x // 4] >> (6 - 2 * (x % 4))) & 3
        if not bit:
            x += 1
            continue
        start = x
        while x < 160 and ((bitmap[y * 40 + x // 4] >> (6 - 2 * (x % 4))) & 3):
            x += 1
        outline.append([start, y, x - start])

cities = []
for city_id in range(1, 101):
    station = ram[0x4B73 + city_id]
    flags = ram[0xAFF3 + city_id]
    ptr = word(0xA2B1 + 2 * city_id)
    departures = []
    while ram[ptr]:
        destination = ram[ptr]
        timing = ram[ptr + 1]
        departures.append({
            "cityId": destination & 0x7F,
            "slot": timing & 0x0F,
            "rideIndex": timing >> 4,
            "special": bool(destination & 0x80),
        })
        ptr += 2
    cities.append({
        "id": city_id,
        "name": names[city_id],
        "x": ram[0xA443 + city_id * 2],
        "y": ram[0xA443 + city_id * 2 + 1],
        "stationByte": station,
        "timeZone": station >> 4,
        "stationLayout": (station & 0x0E) >> 1,
        "people": ((station & 0x0F) >> 1) + 3,
        "flagsByte": flags,
        "capital": bool(flags & 0x80),
        "skylineType": (flags & 0x70) >> 4,
        "skylineOffset": flags & 0x0F,
        "navigation": {
            direction: ram[address + city_id]
            for direction, address in (
                ("left", 0x99C4), ("right", 0x9A28),
                ("up", 0x9A8C), ("down", 0x9AF0)
            )
        },
        "departures": sorted(departures, key=lambda entry: entry["slot"]),
    })

assert len(cities) == 100
assert sum(city["capital"] for city in cities) == 49
assert all(1 <= entry["cityId"] <= 100 for city in cities for entry in city["departures"])
OUT.parent.mkdir(parents=True, exist_ok=True)
OUT.write_text(json.dumps({"outline": outline, "cities": cities}, separators=(",", ":")))
print(f"Exported {len(cities)} cities and {len(outline)} map outline runs to {OUT}")
