# Atari Sound web app

Run from the repository:

```sh
./atari-sound/run-web.sh
```

Open the printed URL if your browser does not open automatically. Python 3 is the
only server requirement. The app runs at `http://127.0.0.1:8765/web/` by default;
use `--port 9000` to choose another port or `--no-browser` to skip opening it.

The **PICO conversions** tab contains the 721 music games and optionally 140 SFX
auditions. Each game has its original Atari conversion and an experimental version
using RMT instruments. The **Atari remixes** tab compares 305 original Atari tracks
with their remixes. The **MIDI to RMT** tab plays both an audio rendition of the
original Pokey Overdrive MIDI and its POKEY conversion, with downloads for the
original `.mid` and converted `.rmt` files. Search, choose a version, then select a
bank or subsong if present.
The Stop button ends playback. Atari audio is synthesized in the browser; the
original MIDI uses a pre-rendered MP3 preview. No emulator is required. The
existing Altirra launchers remain available for native playback.

Run `python3 atari-sound/web/build_catalog.py` after rebuilding either source
collection. It writes the compact `tracks.json` used by the browser. The web app
loads existing `.sap` and `.rmt` files in place. The MIDI preview is the only
pre-rendered audio file.

Playback uses [ASAP](https://asap.sourceforge.net/), version 8 browser JavaScript,
by Piotr Fusik, under GPL-2.0-or-later. Its source is in `vendor/`; the license
text is `vendor/COPYING`. Original and remixed music retains its original
ownership and attribution as recorded in the adjacent manifests and catalogs.
The MIDI preview was rendered with TiMidity++ and FreePats. FreePats grants an
exception for audio compositions made with its instrument patches.

## GitHub Pages

The deployment workflow publishes a compact site containing this app and its
referenced SAP files. After Pages is set to **GitHub Actions**, the direct app URL
is `https://astroforgit.github.io/picoexperiments/atari-sound/web/`. The site
root redirects there. Run `python3 atari-sound/web/build_site.py _site` to check
the package locally.
