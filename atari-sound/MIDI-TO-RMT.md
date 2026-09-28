# MIDI to RMT

`tools/midi_to_rmt.py` makes a four-voice Raster Music Tracker module
from a standard MIDI file. It borrows **instrument definitions only** from an
existing four-channel RMT module; the donor's music patterns are removed.

Install the MIDI dependency and convert the included example:

```sh
python3 -m pip install mido
python3 atari-sound/tools/midi_to_rmt.py \
  'atari-sound/Pokey Overdrive-edited.mid'
```

This writes `Pokey Overdrive-edited.rmt` and a `.conversion.json` report next to
the MIDI file. ASAP playback has been verified; you can audition the RMT in
[ASAP's web player](https://asap.sourceforge.net/web.html). Opening and editing
it in the Raster Music Tracker editor still needs a manual check. The default donor is
`asma/asma/Misc/Chicken_Valley.rmt`, which is already in this workspace.

The converter detects named melody, accompaniment and bass MIDI tracks and the
MIDI drum channel. It uses one POKEY voice for each, quantized to RMT rows. The
`--speed` option controls PAL frames per row (default 8). Existing RMT
instruments 2, 7 and 0 play melody, accompaniment and bass; instruments 4, 5
and 6 play kick, snare and hi-hat. Pass `--template` and the six `--*-inst`
options to use a different four-channel instrument donor. The template must
have a separate instrument block before its track data and enough track slots.

This is a constrained arrangement, not a lossless MIDI conversion. One POKEY
voice can sound only one note at a time. Simultaneous notes within a part are
prioritized, and bass notes below the RMT range are raised by octaves. The JSON
report lists retained and dropped note onsets by part. The example retains 781
of 1,180 MIDI note onsets and raises 28 bass onsets; its source is about 58
seconds long. The RMT file loops after the final song line.

The converted example is also available in the **MIDI to RMT** tab of the
[Atari Sound web app](https://astroforgit.github.io/picoexperiments/atari-sound/web/).
That tab also has the original `.mid` download and an MP3 audio preview made
from the original MIDI with TiMidity++ and FreePats General MIDI instruments.
