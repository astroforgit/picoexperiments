# Porter Patch — Atari VBXE port

This is a new port based directly on `porterpatch1-1.p8`. It does not use the
old conversion's 29 isolated room snapshots.

## Improvements over `atariold`

- complete mutable 128x64 PICO-8 world map;
- original 16x16-screen camera layout and all 28 checkpoint coins;
- 12x12 pre-scaled artwork, giving a 192x192 playfield instead of 128x128;
- jump buffering, coyote time, and four-direction teleporting that remains
  available while Porter is jumping or falling after his first landing;
- red/blue switches, green keys, crumble blocks, falling rocks and rising
  feathers;
- animated hazard/clock tiles, deaths, checkpoint respawn and end sequence;
- horizontal sprite flipping through the VBXE blitter;
- event sound effects through POKEY, with distinct jump and teleport envelopes;
- a steady cavern background behind transparent game tiles, without title text
  or the title character.

## Controls

- joystick left/right: move and aim horizontally
- joystick up/down: aim vertically
- joystick trigger: jump
- `SPACE`: teleport in the aimed direction, including while airborne
- teleporting into a wall or outside the world kills Porter
- SPACE, trigger or any direction on the title screen: start immediately
- the illustrated title waits for input, with the original-game and port credits
- trigger on the end screen: restart
- Atari `OPTION`: toggle all sound on/off
- `1`: jump to the previous level (debug)
- `2`: jump to the next level (debug)

## Build

Install MADS, Node.js and Python 3 with Pillow, then run:

```sh
./build.sh
```

The output is `porter-vbxe.xex`. A VBXE 1.2-compatible core is required.

The title artwork is in `assets/porter-title-credits.png`; the exact 320x200
conversion is `assets/porter-title-preview.png`. `tools/make_title.py` converts
it to 32 colours in palette entries 16..47. Four XEX INIT segments upload it
directly to VBXE before loading the game, keeping assets below BASIC ROM and
preserving the gameplay palette. The title stays visible until SPACE or joystick input.

The separate `assets/porter-background-source.png` uses palette entries 48..79
and lives at VRAM `$40000`. Both gameplay buffers are seeded from it once on
start/restart. Room-cache rebuilds restore the matching background region before
drawing transparent tiles, so the background stays steady across buffer flips.
The display list scans exactly 200 image rows, excluding the uninitialized
framebuffer tail that can produce coloured dots at the bottom. Actors, Porter
and teleport markers are clipped to the room boundaries so they cannot leave
stray pixels in the persistent right/bottom borders.
The background edit prompt is recorded in `assets/background-prompt.txt`.

Jump uses a rising pitch/volume envelope inspired by Fred's `d1/SO.ASM`
player. Teleport uses three notes from Robbo's `d1/R1.ASM` sequence as a short
60ms PAL / 50ms NTSC chirp. These
sources are in `atari/lkavalon-atari-main`.

Press feedback is sampled in VBI (within one display frame), independently of
rendering and teleport destination searches. SPACE is latched by the keyboard
IRQ and the physical joystick trigger is edge-detected in VBI. Short trigger
presses are also latched for gameplay. VBI is the sole producer of trigger
presses; the main loop atomically consumes trigger and SPACE latches, avoiding
duplicate jumps and lost keyboard events. Holding a button, landing, buffered-jump
execution and teleport completion do not replay the cue. There is no landing
sound. POKEY voice 2 carries these effects; voice 1 carries incidental events.
Jump is processed before teleport when both are pressed together. Airborne
teleports into open space preserve upward velocity and skip the support search,
so a jump can be followed immediately by a teleport. If an airborne target
needs wall correction, the search accepts nearby clear space without requiring
a floor, preserving upward velocity instead of rejecting a valid midair exit.

Title/gameplay music adapts the original Porter PICO-8 score, patterns 0..15, rather
than reusing an LK Avalon melody. `tools/make_music.py` preserves the original
pattern order, rests and note timing, transposing into POKEY's usable range.
Voices 3/4 provide a quiet bass and vibrato lead using VBI envelopes inspired
by the normal/vibrato instruments in Hans Kloss's `HK_PLAY.ASM`. The arrangement
loops after 64 seconds on PAL. It simplifies PICO-8 waveform/slide effects.
Music never changes AUDCTL or the effects channels. OPTION mutes all four
voices; music starts on the title, continues into gameplay, and pauses while muted or
on the end screen.

The Porter launcher applies 20ms latency and 20ms extra buffering to Altirra's
shared persistent audio profile and unmutes it. Previous settings were 80ms,
100ms and muted. Restart through `../run-emulator.sh` to use the rebuilt game
and these settings. Hardware input sampling and host playback still have their
normal frame/buffer latency; neither depends on landing or teleport completion.

Optional regression checks (requires `py65`, after building):

```sh
python3 tools/test_runtime.py
```

These execute the assembled 6502 routines against a VBXE/POKEY register model
to check asset uploads, alternating framebuffers, restart, sound envelopes,
interrupt-driven press feedback with the main loop stopped, no held/completion
replays, short presses, atomic keyboard latches, all jump/teleport combinations,
200-row display bounds, sprite-border clipping, later-room airborne UP
teleports, title music, a full music loop, channel isolation, startup audio reset
and mute. They do not
replace emulator checks of video/audio timing or host audio-buffer latency.

Original PICO-8 game: [Blue Makes Games](https://blue-makes-games.itch.io/porter).
Atari version: astrofor. Artwork generated with the built-in image generation
tool; the art direction is recorded in `assets/title-prompt.txt`.

## Build and run

From the Porter project directory, use the one-command launcher:

```sh
./run-emulator.sh
```

It regenerates the Atari data, rebuilds the XEX, and opens it with the
workspace Altirra VBXE profile.
