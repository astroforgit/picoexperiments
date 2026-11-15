# Four listening trials

Run `../run-emulator.sh --library` from this directory, or `./run-emulator.sh --library` from
`atari-sound`. **New auditions only** is selected by default. Pick a game and
double-click it or press Play. Uncheck that box to return to the old collection.

In the new Atari applications: **N** = next pattern, **P** = previous pattern,
**Space** = pause/resume. Shift+N/P also works. Change games in the library.

| Trial | What to listen for | Atari application |
| --- | --- | --- |
| [Porter](porterpatch1-1/) | The existing Porter game's two music instruments, transpositions and timing | [Play in Altirra](porterpatch1-1/MUSIC.XEX) |
| [Pushamo](pushamo/) | Plucked low part, gentle lead, very short percussion | [Play in Altirra](pushamo/MUSIC.XEX) |
| [Porklike](porklike/) | Softer accompaniment and breathing space between notes | [Play in Altirra](porklike/MUSIC.XEX) |
| [Celeste Classic 2](celeste-classic-2/) | Custom PICO waves replaced with shaped tonal instruments | [Play in Altirra](celeste-classic-2/MUSIC.XEX) |

These are arrangements for listening feedback, not exact PICO emulation. The
clock stays at 64 kHz. Phrase transpositions are whole octaves, fixed for each
SFX/channel, rather than changing with individual frames. Tonal voices peak at
2–4 volume steps, with distinct bass, lead and accompaniment envelopes. Noise
bursts last at most three frames at volume 1–2. Long pitch drops become plucks;
custom waveform modulation is simplified. The retained source score is in each
folder alongside the generated `arrangement.json` settings.

Porter's patterns 0–15 use the existing game's actual approach: bass +36
semitones, lead +12, music on POKEY 3/4, volume caps 3/4, a one-step volume
release and one-divider lead vibrato. A py65 comparison against the assembled
original `steamlinejs/porter/atari/music-player.asm` and its data verifies all
3,200 music frames. Remaining Porter patterns use the general soft arrangement.

## ASMA references inspected

The first 20 seconds of these local SAP files were run through ASAP and their
POKEY registers sampled. [asma-analysis.json](asma-analysis.json) records the
clock modes, active distortion types, peak volumes and envelope changes.

- `Games/Hans_Kloss.sap`: Daniel Kleczynski; joined-channel bass and changing percussion tones.
- `Composers/Pelc_Janusz/Fred.sap`: three clean tonal voices with a fixed clock and changing volumes.
- `Composers/Pelc_Janusz/Misja.sap`: strongly shaped bass/percussion using several POKEY modes.
- `Composers/Gilmore_Adam/Draconus.sap`: joined-channel bass with two tonal parts.

This first trial takes the cleaner Porter/Fred direction. It does not claim to
reproduce the other composers' instruments or copy their scores. The ASMA copy
of Hans Kloss uses a different player format from the workspace source version.

All five SAP files (including the extra subsong index) loaded and rendered in
ASAP, covering 103 selectable entries.
The music's artistic quality is for you to judge. The original `mscsrc` music
files were not rebuilt or replaced.

Rebuild only these four trials with `python3 ../tools/build_auditions.py`.
The ordinary full-collection converter retains its original rendering default.
