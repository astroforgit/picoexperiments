# Celeste for Atari VBXE

This is an Atari XL/XE + VBXE port of *Celeste* (Classic) by Matt Thorson and Noel Berry. The
source is the PICO-8 cartridge `[Platform]/celeste.p8.png`. All 31 levels, the title screen,
objects, fruit, the memorial text, the summit screen, the timer and the death count are
ported. POKEY plays the sound effects; the music is switched off (see *Sound* below).

It needs an Atari XL/XE with a VBXE FX core at `$D600` or `$D700`.

## Build and run

```sh
./build.sh                    # MADS -> celeste.xex
./build.sh --regenerate-data  # also rebuild data/ and gen/ from the cartridge (Python 3)
./run-emulator.sh             # build, then start in the persistent Altirra VBXE profile
```

## Controls

| Action | Joystick | Keyboard |
| --- | --- | --- |
| Move, look up, crouch | joystick 0 | W A S D |
| Jump (also starts the game) | fire | O or X |
| Dash | button 2 or 3 of a 2-button joystick (Joy2B+ style, pins 5/9), or joystick 2 fire | P, SPACE, C or SHIFT |

The Atari keyboard reports only the most recently pressed key, so the game catches every key
press in the keyboard interrupt (ignoring the OS auto-repeat). O, X, P, SPACE and C act on
each press. W/A/S/D stay held until the keyboard is idle or the opposite direction is
pressed, so holding D and tapping O jumps to the right every time.

Each input counts only after it has been seen released once (Altirra holds OPTION while
booting). Joystick buttons 2 and 3 arrive on the paddle lines, whose resting level depends on
the joystick (Altirra's two-button joystick reads high when pressed, Joy2B+ sticks read low),
so a press is any change from the level the line had when the game started. Don't hold
these buttons while the game loads.

A dash always lasts the same time, as in the original; holding the button does not extend it.

## PICO-8 conversion

`scrip/pico_convert.py` decodes the cartridge. The decoded files are:

- `pico/cart.bin`: the raw 32K cartridge memory.
- `pico/celeste.p8`: the text cartridge, also in `allgames/[Platform]/celeste.p8`.
- `pico/celeste.lua`: the game code.
- `pico/celeste_gfx*.png`: the sprite sheet, also in
  `allgames_resources/[Platform]/celeste.png`.

`tools/make_data.py` turns `cart.bin` into:

- `data/gfx.bin`: the sprite sheet.
- `data/map.bin`: the 128×64 map.
- `data/stage.bin`: the font, circle masks and display lists.
- `data/sfx.bin`: the sound data.
- `gen/tables.asm`: sprite flags, sine tables and palettes.

## How it works

- **Game logic.** `src/objects.asm`, `src/types.asm` and `src/game.asm` translate the Lua
  closely, running at the original 30 ticks per second. PAL paces 3 ticks per 5 frames and
  NTSC 1 tick every 2 frames. Speeds and remainders use PICO-8's 16.16 fixed point with the
  cart's constants rounded as PICO-8 rounds them, so movement is exact. PICO-8 quirks are
  kept, such as `move_x` stepping one extra pixel and the player's update continuing after a
  death.
- **Coordinates.** Positions are stored as one byte holding the PICO-8 value + 64.
- **Display.** The display uses VBXE low-resolution mode at narrow width, which gives 128
  pixels, each 2 hi-res pixels wide. The XDL shows even rows on two lines and odd rows on
  one, 192 lines in total, so the screen appears square.
- **Framebuffers.** Two 256×256 framebuffers are shown alternately. The PICO screen sits at
  +64,+64 in each, so the blitter never needs clipping.
- **Rendering.** Each room's background and terrain map layers are drawn once into VRAM when
  the room loads. After that, each frame is one queued blitter list, built by
  `src/draw.asm` and `src/vbxe.asm`. The blitter draws while the next tick's logic runs, and
  the VBI shows the frame once the blitter is idle. List slots remember which kind of
  command they held, so only the fields that change get rewritten.
- **Speed.** The CPU averages at most 1.61 frames per tick across the rooms, measured with
  `tools/profile.py`. Loading a room costs a one-off pause of up to about 6 frames.

## Sound

`src/sound.asm` plays the cart's sound effects on POKEY channel 4 from the vertical blank.
It follows PICO-8's timing of 183/22050 s per speed step, with pitch, volume, noise, slide,
fade and arpeggio effects. The music player is in the same file but switched off with
`PLAY_MUSIC = 0` in `celeste.asm`; `SOUND = 0` silences everything.

## Testing tools

- `tools/emu.py`: a headless py65 Atari with enough VBXE emulation for testing. It emulates
  MEMAC, the blitter (with a timing model), the palette, and XDL screenshots. VRAM starts
  with random bytes, as on real hardware.
- `tools/pico_ref.py`: runs the original Lua with a PICO-8 shim (lupa) that is 16.16-exact
  for the physics.
- `tools/compare.py`: plays the same inputs on both, tick by tick. `--fuzz N` runs random
  inputs for N ticks in every room.
- `tools/profile.py`: measures CPU cycles per tick for each room.

`compare.py --fuzz 600` matches the original in all 31 rooms: player position, speed, deaths
and fruit on every tick.
