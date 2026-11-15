# PICO-8 music for Atari 8-bit

Converted music, editable source data, a reusable converter, and a native 6502
player for an Atari with one POKEY. No VBXE or stereo expansion is needed.

## Play

For the unified browser app, run `./atari-sound/run-web.sh` from the repository
root and open the printed URL. It has **PICO conversions** and **Atari remixes**
tabs, with browser playback powered by ASAP. See [web app instructions](web/README.md).


On **Windows**, extract [Atari-Sound-Windows.zip](Atari-Sound-Windows.zip) to a
local drive and double-click `START-WINDOWS.cmd`. Choose either side to play its
native Atari music in Altirra. No WSL or Python is needed for the Windows app.
The emulator gets a separate PAL profile with WaveOut and 120 ms audio buffering.
Playback is emulator-only; no MP3, WAV or other audio previews are included.
Click **PICO music** or launch `START-PICO-WINDOWS.cmd` for the PICO collection.

`./run-emulator.sh` now opens the [original/remix comparison](remixes/README.md):
Original music is on the left and new arrangements are on the right. Draconus,
Commando and Warhawk now have full arrangements lasting 3:00, 2:19 and 3:37.
Search for a track and play either side in Atari.
Use `./run-emulator.sh --library` for the PICO collection and auditions below.

The PICO library presents matched game pairs: **original conversion on the left**,
**experimental RMT instruments on the right**. All 721 music games are included;
**Include SFX auditions** adds 140 pairs. The original files remain unchanged.
Double-click a column or click its Play button. Each side has its own bank selector.
Search by game or RMT donor track. The app starts ready for you to choose a side.

The experimental versions play the PICO score with isolated instruments from
local RMT modules, with no added percussion patterns. See
[RMT arrangement details and sources](rmt-variations/README.md). The four earlier
listening trials remain in `auditions`.

For the PICO library on your WSL/Windows setup, run:

```sh
./run-emulator.sh --library
```

This opens **Atari Sound - Music Library** and starts Porter in the installed
Altirra emulator. Search for a game, select its music bank, and click **Play in
Altirra** or double-click the game. You can switch games without finding files
yourself. Enable **Include SFX auditions** to browse those exports too.

In Altirra, **F2** pauses/resumes, **F3** selects the next pattern, and **F4**
selects the previous pattern. Return to the library window to change games.
**Stop** stops its emulator; closing the library also stops its playback.
Other Altirra sessions are left alone.

An optional argument selects the initial game: `./run-emulator.sh --library porklike`.
The launcher uses your existing Altirra profile and the workspace's emulator
discovery helper. Set `ALTIRRA_PATH` in Windows if the emulator moves. On Windows
without WSL, run `tools/music-library.ps1` with Windows PowerShell in STA mode.

The easiest route is to open [CATALOG.md](CATALOG.md), choose a game, and load its
`MUSIC.XEX` in Altirra or on an Atari XL/XE with at least 64 KB. Games that need
several memory banks have `MUSIC01.XEX`, `MUSIC02.XEX`, etc. **Disable BASIC**
(hold OPTION when booting the Atari). Release OPTION after loading.

Each XEX includes both the application and the music. It starts playing
automatically and displays the game name, current original pattern number in
hexadecimal, playback status, and four channel volume values.

| Atari console key | Action |
| --- | --- |
| START | Pause/resume; restart selected pattern after a song stops |
| SELECT | Select and start the next pattern |
| OPTION | Select and start the previous pattern |
| RESET | Leave the player / return to the operating system |

Selection moves through the bank's entries, including independent songs and
jingles. Playback itself follows the original pattern links, loop and stop
flags. Pattern numbers are the original PICO numbers, not song titles inferred
from gameplay. In `sfx-audition` exports the numbers identify SFX slots instead.

The separate [PLAYER.XEX](PLAYER.XEX) is a DOS file-loading application. Boot
Atari DOS with BASIC disabled, put a game's `MUSIC.PMS` on the disk, run
`PLAYER.XEX`, and enter `D:MUSIC.PMS` at the prompt. A configured emulator host
device also works, for example `H1:MUSIC.PMS`. It loads one bank into memory;
reset and run it again to choose another file. It accepts **PMS**, not SAP.
The self-contained game XEX files do not require DOS file access during play.

For a desktop Atari music player such as ASAP, open `MUSIC.sap`. SAP subsongs
start at different patterns and continue through the song. If there are more
than 32 entries, `MUSIC-extra.sap` exposes the remaining entries while retaining
the same complete playback data. The native XEX/PMS player exposes all entries.

## Files

```text
atari-sound/
  PLAYER.XEX                 universal Atari PMS file loader
  CATALOG.md                 browsable game list
  catalog.json               complete scan, provenance, counts and warnings
  mscsrc/<game-name>/
    MUSIC.PMS                compact native POKEY register score
    MUSIC.sap                standard SAP Type B Atari music file
    MUSIC.XEX                self-contained Atari application
    source-music.json        extracted PICO patterns, SFX notes and instruments
    manifest.json            source paths, pattern mapping and conversion warnings
  player/                    MADS 6502 source and compiled reusable player
  tools/convert.py            extraction, arrangement and build pipeline
  tests/                     format and assembled playback checks
```

Matching text and PNG copies of the same game/audio are merged. Different
versions of the same named game get a short audio hash in their directory name.
Different games retain separate folders even if their music happens to match.
No original game files are modified. Source paths are retained; composers are
not guessed, and the original music retains its original ownership/licensing.

## What the conversion preserves

All `.p8`, `.p8.png`, and `.p8.rom` cartridges in the repository are inspected.
PNG audio is decoded from the cartridge pixels, not its cover image. Exported
resource images and non-PICO engines are not treated as PICO cartridges.

Four voices, pitches, rests, relative volume, independent SFX speeds, shortened
patterns, SFX loops, and music loop/stop structure are retained in the static
score. The leftmost non-looping voice determines pattern duration. Playback is
sampled at the PAL video rate (about 49.86 Hz); slide, vibrato, drop, volume fades,
arpeggios and nested custom instruments are arranged at that rate. Timing uses
183/22050 seconds per PICO speed unit, rather than an assumed 1/128 second.

POKEY is a different synthesizer. Tonal instruments become pure POKEY tones with
different gains; noise becomes POKEY noise. The converter chooses the shared
15/64 kHz clock by pitch error. Notes below the four-voice pitch range are raised
by octaves. It does not reproduce exact PICO waveform shapes, phase, detune,
reverb or damping. Custom instruments and effects are approximations, not a
bit-exact PICO audio emulator. Frame rounding can introduce small timing errors.
PAL is the tuning target; the XEX player skips one tick in six on NTSC to retain
approximately the same tempo, with the NTSC clock's small pitch difference.

Cartridges with no audible static music patterns but with sound effects receive
an explicitly labelled `sfx-audition` export containing every audible SFX slot.
This preserves material for arranging music but **does not reconstruct Lua-driven
soundtracks**. The converter does not run Lua, execute `music()`/`sfx()` calls,
apply runtime memory patches, or recover streamed/generated audio. Static music
can include unused editor patterns. See each manifest for warnings and literal
music entry calls found in the text source.

Connected songs are kept in one memory bank whenever they fit. Exceptionally
large songs are split without dropping frames; playback stops at a bank boundary
and needs the next file loaded manually. Exact affected links are listed as
`bank_boundary_stops` in the manifest. This is a memory-resident player, not a
gapless disk-streaming player. The catalog flags affected games.

`slime_platformer.p8` has malformed trailing zero padding in several SFX rows.
The extractor only normalizes that padding; the repair is recorded in the
extracted source and manifest. Other malformed data causes a reported error.

## Rebuild and verify

Requirements: Python 3.8+, Pillow, and MADS on PATH. Tests additionally use py65.

```sh
python3 -m pip install -r atari-sound/requirements.txt
python3 atari-sound/tools/convert.py
python3 -m unittest discover -s atari-sound/tests -v
```

The build assembles the shared player once, scans the collection, and exports
every audio group. `--source PATH`, `--output PATH`, and `--mads PATH` override
the defaults. `--limit N` is for development and produces an explicitly partial
catalog. Rebuilds replace generated products and remove obsolete bank filenames
listed in the previous manifest. Do not hand-edit generated products.

Validation exercises real assembled 6502 instructions in py65, checks register
output and playback transitions, and validates every generated bank. This does
not validate ANTIC display timing, DOS compatibility or analog sound quality on
physical hardware. See [VALIDATION.md](VALIDATION.md) for this build's results.

An optional independent emulator check is available with a compiled ASAP shared
library: `python3 atari-sound/tools/validate_asap.py --library /path/to/libasap.so`.
It loads every SAP and renders the first 100 ms of every subsong in memory;
no audio files are written.

## Reference material

The local reference was
[`HK_PLAY.ASM`](../atari/lkavalon-atari-main/hans-kloss/side_a/HK_PLAY.ASM):
Janusz Pelc's player separates song order, note data and evolving instruments.
This project uses a new register-stream player and does not copy Hans Kloss song
data or claim compatibility with its `.AMC` format. The reference tree also
contains Digi Duck's CMC music assets; these are not interchangeable formats.

The implementation was checked against the
[official PICO-8 manual](https://www.lexaloffle.com/dl/docs/pico-8_manual.html),
[FAKE-08's audio implementation](https://github.com/jtothebell/fake-08/blob/master/source/Audio.cpp),
the [Atari POKEY datasheet](https://www.mikesarcade.com/estore/datasheets/pokey.pdf),
and the [ASAP SAP specification](https://asap.sourceforge.net/sap-format.html).
See [FORMAT.md](FORMAT.md) for the native format and callable player interface.
