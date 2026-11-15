# Validation results

Build verified on 2026-09-06.

| Check | Result |
| --- | --- |
| Cartridge files scanned | 1,768 |
| Cartridges without audible SFX | 46 |
| Parse errors remaining | 0 |
| Distinct game/audio exports | 861 |
| Static music exports | 721 |
| SFX audition exports | 140 |
| Native PMS/XEX banks checked | 1,030 |
| SAP files loaded by ASAP | 1,132 |
| SAP subsongs initialized and rendered | 15,499 |
| Python / assembled 6502 tests | 8 passed |

The bank check validates every pointer, successor index, decompressed frame count,
AUDCTL value and XEX data segment. py65 executes the assembled decoder through
page crossings, long holds, pattern transitions, stop, loop and pause/resume.
A separate test executes the universal loader with a simulated Atari CIO service
and checks title layout and console controls, including held-key handling.

ASAP independently emulates the 6502 and POKEY. Every subsong rendered its first
100 ms successfully. Porter additionally rendered a non-silent 20-second 44.1 kHz
mono WAV with a peak absolute 16-bit sample value of 12,363. This is a playback
smoke test, not a full-duration listening review of every song.

No physical Atari, real DOS device, or full-system ANTIC display test was run.
The converter does not execute game Lua, so runtime-generated music and exact
PICO timbres remain outside this static arrangement. See README.md.

## Songs crossing memory banks

These 17 games have at least one song link that needs a manual bank change.
Each manifest specifies the destination XEX, pattern ID and frame offset.
Other multi-bank games split at natural independent-song boundaries.

- [Anywhere for you](mscsrc/anywhere-for-you/manifest.json)
- [ClausQuest (v.1.4)](mscsrc/clausquest-v-1-4/manifest.json)
- [Confusing Prison Mansion](mscsrc/confusing-prison-mansion/manifest.json)
- [Cosmo Boing Deluxe](mscsrc/cosmo-boing-deluxe/manifest.json)
- [DespiteBike](mscsrc/despitebike/manifest.json)
- [Hooked on Amstrad Chiptunes - Vol. 1](mscsrc/hooked-on-amstrad-chiptunes-vol-1/manifest.json)
- [Hypercolor Paint](mscsrc/hypercolor-paint/manifest.json)
- [Pico-RAY](mscsrc/pico-ray/manifest.json)
- [Pico-Tron](mscsrc/pico-tron/manifest.json)
- [Pico Zombie Garden](mscsrc/pico-zombie-garden/manifest.json)
- [PicoVox](mscsrc/picovox/manifest.json)
- [Sarah and the Lonely Key](mscsrc/sarah-and-the-lonely-key/manifest.json)
- [Save Yourself](mscsrc/save-yourself/manifest.json)
- [Super Kill Each Other](mscsrc/super-kill-each-other/manifest.json)
- [Tetyis (v1.01)](mscsrc/tetyis-v1-01/manifest.json)
- [The Chamber Scrolls](mscsrc/the-chamber-scrolls/manifest.json)
- [Tube Runner](mscsrc/tube-runner/manifest.json)
