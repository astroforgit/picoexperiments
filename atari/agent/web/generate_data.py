#!/usr/bin/env python3
"""Build dist/data.json for the atlas: Poland instead of the USA.

The data has the same shape as the game's: 100 cities on a 160x160 map
grid (x in double-width pixels, as in Agent USA), a map outline as pixel
runs, per-city station and skyline bytes, InfoBooth cities, joystick
navigation and 16 departure slots per city.

Cities and their coordinates are real. The InfoBooth cities are the
voivodeship seats. The rail network is invented: express trains link big
cities (more likely when they are close, Warsaw is a hub) and regional
trains link every city to its nearest neighbours. It is random but
repeatable (fixed seed).
"""

import json
import math
import random
from pathlib import Path

OUT = Path(__file__).resolve().parent / "dist" / "data.json"
SEED = 1984

# name, voivodeship, latitude, longitude, population in thousands
CITIES = [
    ("Warszawa", "mazowieckie", 52.23, 21.01, 1860),
    ("Kraków", "małopolskie", 50.06, 19.94, 800),
    ("Wrocław", "dolnośląskie", 51.11, 17.03, 670),
    ("Łódź", "łódzkie", 51.76, 19.46, 650),
    ("Poznań", "wielkopolskie", 52.41, 16.93, 540),
    ("Gdańsk", "pomorskie", 54.35, 18.65, 485),
    ("Szczecin", "zachodniopomorskie", 53.43, 14.55, 390),
    ("Bydgoszcz", "kujawsko-pomorskie", 53.12, 18.01, 330),
    ("Lublin", "lubelskie", 51.25, 22.57, 330),
    ("Białystok", "podlaskie", 53.13, 23.16, 295),
    ("Katowice", "śląskie", 50.26, 19.02, 285),
    ("Gdynia", "pomorskie", 54.52, 18.53, 245),
    ("Częstochowa", "śląskie", 50.81, 19.12, 210),
    ("Radom", "mazowieckie", 51.40, 21.15, 200),
    ("Rzeszów", "podkarpackie", 50.04, 22.00, 197),
    ("Toruń", "kujawsko-pomorskie", 53.01, 18.60, 196),
    ("Kielce", "świętokrzyskie", 50.87, 20.63, 185),
    ("Gliwice", "śląskie", 50.29, 18.67, 175),
    ("Olsztyn", "warmińsko-mazurskie", 53.78, 20.48, 170),
    ("Bielsko-Biała", "śląskie", 49.82, 19.04, 168),
    ("Zielona Góra", "lubuskie", 51.94, 15.51, 140),
    ("Rybnik", "śląskie", 50.10, 18.55, 135),
    ("Opole", "opolskie", 50.67, 17.93, 127),
    ("Tychy", "śląskie", 50.12, 18.98, 127),
    ("Gorzów Wielkopolski", "lubuskie", 52.73, 15.24, 120),
    ("Elbląg", "warmińsko-mazurskie", 54.16, 19.40, 117),
    ("Płock", "mazowieckie", 52.55, 19.71, 116),
    ("Wałbrzych", "dolnośląskie", 50.77, 16.28, 110),
    ("Włocławek", "kujawsko-pomorskie", 52.65, 19.07, 108),
    ("Tarnów", "małopolskie", 50.01, 20.99, 108),
    ("Koszalin", "zachodniopomorskie", 54.19, 16.17, 106),
    ("Kalisz", "wielkopolskie", 51.76, 18.09, 99),
    ("Legnica", "dolnośląskie", 51.21, 16.16, 99),
    ("Grudziądz", "kujawsko-pomorskie", 53.48, 18.75, 94),
    ("Słupsk", "pomorskie", 54.46, 17.03, 89),
    ("Nowy Sącz", "małopolskie", 49.62, 20.69, 83),
    ("Jelenia Góra", "dolnośląskie", 50.90, 15.73, 78),
    ("Siedlce", "mazowieckie", 52.17, 22.29, 77),
    ("Konin", "wielkopolskie", 52.22, 18.25, 72),
    ("Piotrków Trybunalski", "łódzkie", 51.40, 19.70, 72),
    ("Inowrocław", "kujawsko-pomorskie", 52.80, 18.26, 72),
    ("Lubin", "dolnośląskie", 51.40, 16.20, 72),
    ("Piła", "wielkopolskie", 53.15, 16.74, 72),
    ("Ostrów Wielkopolski", "wielkopolskie", 51.65, 17.81, 71),
    ("Suwałki", "podlaskie", 54.10, 22.93, 69),
    ("Stargard", "zachodniopomorskie", 53.34, 15.05, 67),
    ("Gniezno", "wielkopolskie", 52.54, 17.60, 67),
    ("Ostrowiec Świętokrzyski", "świętokrzyskie", 50.93, 21.39, 67),
    ("Głogów", "dolnośląskie", 51.66, 16.08, 66),
    ("Leszno", "wielkopolskie", 51.84, 16.57, 63),
    ("Zamość", "lubelskie", 50.72, 23.25, 62),
    ("Łomża", "podlaskie", 53.18, 22.06, 62),
    ("Ełk", "warmińsko-mazurskie", 53.83, 22.36, 61),
    ("Chełm", "lubelskie", 51.14, 23.47, 61),
    ("Tomaszów Mazowiecki", "łódzkie", 51.53, 20.01, 61),
    ("Kędzierzyn-Koźle", "opolskie", 50.35, 18.21, 61),
    ("Mielec", "podkarpackie", 50.29, 21.42, 60),
    ("Stalowa Wola", "podkarpackie", 50.58, 22.05, 60),
    ("Tczew", "pomorskie", 54.09, 18.78, 60),
    ("Przemyśl", "podkarpackie", 49.78, 22.77, 59),
    ("Biała Podlaska", "lubelskie", 52.03, 23.13, 57),
    ("Świdnica", "dolnośląskie", 50.84, 16.49, 57),
    ("Racibórz", "śląskie", 50.09, 18.22, 55),
    ("Ostrołęka", "mazowieckie", 53.09, 21.58, 52),
    ("Starachowice", "świętokrzyskie", 51.04, 21.07, 48),
    ("Wejherowo", "pomorskie", 54.61, 18.24, 48),
    ("Puławy", "lubelskie", 51.42, 21.97, 47),
    ("Skierniewice", "łódzkie", 51.95, 20.15, 47),
    ("Kołobrzeg", "zachodniopomorskie", 54.18, 15.58, 46),
    ("Krosno", "podkarpackie", 49.69, 21.77, 46),
    ("Radomsko", "łódzkie", 51.07, 19.45, 46),
    ("Nysa", "opolskie", 50.47, 17.33, 44),
    ("Ciechanów", "mazowieckie", 52.88, 20.62, 43),
    ("Kutno", "łódzkie", 52.23, 19.36, 43),
    ("Sieradz", "łódzkie", 51.60, 18.73, 41),
    ("Świnoujście", "zachodniopomorskie", 53.91, 14.25, 40),
    ("Szczecinek", "zachodniopomorskie", 53.71, 16.70, 40),
    ("Chojnice", "pomorskie", 53.70, 17.56, 40),
    ("Mińsk Mazowiecki", "mazowieckie", 52.18, 21.56, 40),
    ("Bolesławiec", "dolnośląskie", 51.26, 15.57, 39),
    ("Malbork", "pomorskie", 54.04, 19.03, 38),
    ("Oświęcim", "małopolskie", 50.04, 19.22, 37),
    ("Sanok", "podkarpackie", 49.56, 22.21, 37),
    ("Jarosław", "podkarpackie", 50.02, 22.68, 37),
    ("Kwidzyn", "pomorskie", 53.73, 18.93, 37),
    ("Mława", "mazowieckie", 53.11, 20.38, 30),
    ("Iława", "warmińsko-mazurskie", 53.60, 19.57, 33),
    ("Lębork", "pomorskie", 54.54, 17.75, 35),
    ("Łowicz", "łódzkie", 52.11, 19.94, 28),
    ("Bartoszyce", "warmińsko-mazurskie", 54.25, 20.81, 23),
    ("Augustów", "podlaskie", 53.84, 22.98, 30),
    ("Giżycko", "warmińsko-mazurskie", 54.04, 21.76, 29),
    ("Zgorzelec", "dolnośląskie", 51.15, 15.01, 30),
    ("Zakopane", "małopolskie", 49.30, 19.95, 27),
    ("Kłodzko", "dolnośląskie", 50.43, 16.66, 26),
    ("Sandomierz", "świętokrzyskie", 50.68, 21.75, 23),
    ("Hajnówka", "podlaskie", 52.74, 23.58, 20),
    ("Międzyrzecz", "lubuskie", 52.44, 15.58, 18),
    ("Brodnica", "kujawsko-pomorskie", 53.26, 19.40, 28),
    ("Łuków", "lubelskie", 51.93, 22.38, 30),
]

# voivodeship seats (Bydgoszcz/Toruń and Gorzów/Zielona Góra share one)
SEATS = {"Warszawa", "Kraków", "Wrocław", "Łódź", "Poznań", "Gdańsk",
         "Szczecin", "Bydgoszcz", "Toruń", "Lublin", "Białystok",
         "Katowice", "Rzeszów", "Kielce", "Olsztyn", "Zielona Góra",
         "Gorzów Wielkopolski", "Opole"}

# the border, clockwise from Świnoujście (longitude, latitude)
BORDER = [
    (14.22, 53.93), (14.60, 53.96), (15.00, 54.05), (15.60, 54.20),
    (16.20, 54.32), (16.80, 54.56), (17.50, 54.76), (18.30, 54.84),
    (18.55, 54.70), (18.60, 54.43), (18.95, 54.35), (19.40, 54.40),
    (19.65, 54.45), (20.50, 54.38), (21.50, 54.33), (22.30, 54.35),
    (22.79, 54.36), (23.10, 54.30), (23.50, 54.18), (23.50, 53.95),
    (23.60, 53.60), (23.90, 53.15), (23.60, 52.65), (23.20, 52.30),
    (23.60, 51.90), (23.65, 51.55), (24.14, 50.86), (23.98, 50.40),
    (23.50, 50.25), (22.95, 49.95), (22.70, 49.60), (22.88, 49.10),
    (22.56, 49.08), (22.00, 49.22), (21.50, 49.43), (20.90, 49.35),
    (20.30, 49.40), (20.00, 49.20), (19.50, 49.60), (19.10, 49.40),
    (18.85, 49.52), (18.60, 49.85), (18.20, 50.00), (17.70, 50.25),
    (17.00, 50.45), (16.90, 50.22), (16.60, 50.10), (16.30, 50.40),
    (16.20, 50.65), (15.80, 50.75), (15.00, 50.98), (14.82, 50.87),
    (14.98, 51.30), (14.75, 51.60), (14.60, 52.10), (14.55, 52.60),
    (14.15, 52.85), (14.40, 53.25), (14.30, 53.70), (14.22, 53.93),
]

LAT_TOP, LAT_BOTTOM = 54.95, 48.95
LON_LEFT = 14.0
ROWS_PER_DEG = 152 / (LAT_TOP - LAT_BOTTOM)
X_SCALE = math.cos(math.radians(52))        # a degree of longitude is shorter
GRID_X0 = 41                                # centres Poland on the 160 grid


def to_grid(lon, lat):
    """Map grid position: x in double-width pixels (0-159), y in rows."""
    x = (lon - LON_LEFT) * X_SCALE * ROWS_PER_DEG / 2 + GRID_X0
    y = (LAT_TOP - lat) * ROWS_PER_DEG + 4
    return x, y


def km(a, b):
    """Rough distance in km between two cities (equirectangular)."""
    dx = (a["lon"] - b["lon"]) * 111.3 * X_SCALE
    dy = (a["lat"] - b["lat"]) * 111.3
    return math.hypot(dx, dy)


def outline_runs():
    """Rasterise the border into pixel runs [x, y, width], like the game's
    map outline."""
    pixels = set()
    points = [to_grid(lon, lat) for lon, lat in BORDER]
    for (x0, y0), (x1, y1) in zip(points, points[1:]):
        steps = int(max(abs(x1 - x0) * 2, abs(y1 - y0)) * 2) + 1
        for i in range(steps + 1):
            t = i / steps
            pixels.add((round(x0 + (x1 - x0) * t), round(y0 + (y1 - y0) * t)))
    runs = []
    for y in sorted({p[1] for p in pixels}):
        xs = sorted(p[0] for p in pixels if p[1] == y)
        start = prev = xs[0]
        for x in xs[1:] + [None]:
            if x is not None and x == prev + 1:
                prev = x
                continue
            runs.append([start, y, prev - start + 1])
            if x is not None:
                start = prev = x
    return runs


def build_rails(cities, rng):
    """Undirected links: {frozenset(a, b): express}."""
    links = {}
    big = [c for c in cities if c["pop"] >= 150]
    # express trains between big cities, at most 5 per city (6 for Warsaw); Warsaw is the
    # hub and almost always has a train to the largest cities
    pairs = []
    for i, a in enumerate(big):
        for b in big[i + 1:]:
            d = km(a, b)
            p = min(0.9, math.exp(-d / 220) * 1.6)
            if "Warszawa" in (a["name"], b["name"]):
                p = max(p, 1.0 if min(a["pop"], b["pop"]) >= 400 else 0.6)
            hub = "Warszawa" in (a["name"], b["name"])
            pairs.append(((not hub, p < 1, rng.random() / p), a, b, p))
    express = {c["id"]: 0 for c in cities}
    for _, a, b, p in sorted(pairs, key=lambda e: e[0]):
        cap = {c["id"]: 6 if c["name"] == "Warszawa" else 5 for c in (a, b)}
        if all(express[c["id"]] < cap[c["id"]] for c in (a, b)) \
                and rng.random() < p:
            links[frozenset((a["id"], b["id"]))] = True
            express[a["id"]] += 1
            express[b["id"]] += 1
    # regional trains to the nearest neighbours; a city that already has 8
    # destinations takes no more, so its neighbours use the next one
    def degree(cid):
        return sum(cid in key for key in links)
    for a in cities:
        near = sorted((c for c in cities if c is not a), key=lambda c: km(a, c))
        wanted = 2 + (rng.random() < 0.6) + (rng.random() < 0.25)
        for b in near[:8]:
            key = frozenset((a["id"], b["id"]))
            mine = sum(1 for k in links if a["id"] in k and not links[k])
            if mine >= wanted or degree(a["id"]) >= 8:
                break
            if key not in links and degree(b["id"]) < 8:
                links[key] = False
    # everything reachable: join components by their closest pair
    while True:
        comp = {cities[0]["id"]}
        grow = True
        while grow:
            grow = False
            for key in links:
                if len(key & comp) == 1:
                    comp |= key
                    grow = True
        if len(comp) == len(cities):
            break
        inside = [c for c in cities if c["id"] in comp]
        outside = [c for c in cities if c["id"] not in comp]
        a, b = min(((a, b) for a in inside for b in outside),
                   key=lambda pair: km(*pair))
        links[frozenset((a["id"], b["id"]))] = False
    # at most 8 destinations per city (16 slots, two trains a day each):
    # drop the longest regional links first, never cutting a city off
    for c in sorted(cities, key=lambda c: -degree(c["id"])):
        while degree(c["id"]) > 8:
            mine = [k for k in links if c["id"] in k]
            mine.sort(key=lambda k: (links[k], -km(*(cities[i - 1] for i in k))))
            for k in mine:
                other = next(iter(k - {c["id"]}))
                if degree(other) > 2:
                    del links[k]
                    break
            else:
                break
    return links


def nearest_in_direction(city, cities, dx, dy):
    """The InfoBooth joystick: the closest city roughly in that direction."""
    best, best_score = city, None
    for other in cities:
        if other is city:
            continue
        vx, vy = other["gx"] - city["gx"], other["gy"] - city["gy"]
        along = vx * dx + vy * dy
        if along <= 0:
            continue
        across = abs(vx * dy - vy * dx)
        if across > along * 1.5:
            continue
        score = along + across * 2
        if best_score is None or score < best_score:
            best, best_score = other, score
    return best["id"]


def main():
    rng = random.Random(SEED)
    assert len(CITIES) == 100, len(CITIES)
    assert len({c[0] for c in CITIES}) == 100
    cities = []
    for i, (name, region, lat, lon, pop) in enumerate(CITIES, 1):
        gx, gy = to_grid(lon, lat)
        cities.append(dict(id=i, name=name, region=region, lat=lat, lon=lon,
                           pop=pop, gx=gx, gy=gy))
    links = build_rails(cities, rng)

    out = []
    for c in cities:
        dests = sorted((next(iter(k - {c["id"]})), express)
                       for k, express in links.items() if c["id"] in k)
        dests.sort(key=lambda d: km(c, cities[d[0] - 1]))
        departures = []
        for n, (dest, express) in enumerate(dests):
            d = km(c, cities[dest - 1])
            ride = min(15, int(d / (45 if express else 28)))
            for slot in (n, n + 8):
                departures.append({"cityId": dest, "slot": slot,
                                   "rideIndex": ride, "express": express,
                                   "km": round(d)})
        people = min(10, 3 + int(math.log2(max(c["pop"], 20) / 20)))
        layout = people - 3                 # shares bits with people, as in the game
        skyline = 4 if c["pop"] >= 500 else 3 if c["pop"] >= 150 else \
            2 if c["pop"] >= 60 else rng.choice((0, 1))
        offset = rng.randrange(16)
        capital = c["name"] in SEATS
        station_byte = layout << 1          # one time zone: CET, code 0
        flags_byte = capital << 7 | skyline << 4 | offset
        out.append({
            "id": c["id"], "name": c["name"], "region": c["region"],
            "population": c["pop"] * 1000,
            "x": round(c["gx"]), "y": round(c["gy"]),
            "lat": c["lat"], "lon": c["lon"],
            "stationByte": station_byte, "timeZone": 0,
            "stationLayout": layout, "people": people,
            "flagsByte": flags_byte, "capital": capital,
            "skylineType": skyline, "skylineOffset": offset,
            "navigation": {
                name: nearest_in_direction(c, cities, dx, dy)
                for name, dx, dy in (("left", -1, 0), ("right", 1, 0),
                                     ("up", 0, -1), ("down", 0, 1))
            },
            "departures": sorted(departures, key=lambda e: e["slot"]),
        })

    assert sum(c["capital"] for c in out) == 18
    assert all(2 <= len(c["departures"]) // 2 <= 8 for c in out)
    OUT.parent.mkdir(parents=True, exist_ok=True)
    data = {"country": "Poland", "outline": outline_runs(), "cities": out}
    OUT.write_text(json.dumps(data, ensure_ascii=False, separators=(",", ":")))
    n_links = len(links)
    n_express = sum(links.values())
    print(f"Exported {len(out)} cities, {n_links} rail links "
          f"({n_express} express) to {OUT}")


if __name__ == "__main__":
    main()
