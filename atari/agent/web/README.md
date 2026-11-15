# Agent Polska city atlas

An interactive browser map in the style of *Agent USA* (1984), with Poland
instead of the USA. It has 100 Polish cities (real positions, population and
voivodeship) and a map outline drawn as pixel runs on the game's 160×160
grid. The 18 voivodeship seats are the InfoBooth cities. Each city has
station and skyline bytes, joystick navigation and 16 departure slots, as
in the game.

The rail network is not the real one. `generate_data.py` invents it with
fixed-seed randomness:

- Express trains link the big cities (over 150,000 people). They are more
  likely the closer the cities are, with at most 5 per city. Warsaw is the
  hub: it always has an express train to the cities over 400,000 people.
- Regional trains link every city to its 2-4 nearest neighbours.
- Every city is reachable, and none has more than 8 destinations (16 slots,
  two trains a day to each).

Regenerate `dist/data.json` after changing the cities or the rules:

```sh
python3 generate_data.py
```

`generate_usa_data.py` is the original exporter of the USA data from the
game's XEX. It now writes `dist/data-usa.json`, which the app does not load.

Serve `dist` with any static HTTP server, for example:

```sh
python3 -m http.server 8000 --directory dist
```

Then open `http://localhost:8000/`. Opening `index.html` directly from the
filesystem will not load `data.json` in browsers that restrict file fetches.
