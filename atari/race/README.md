# Bikini Race for Atari VBXE

This is a playable Atari XL/XE + VBXE adaptation of Assembler Bot's Pico-8
game. It uses the cartridge's three original 64×64 driving maps, starting
grids, and all 15 ordered waypoints on each course.
The original 3D car mesh is rendered into 16 heading views and recoloured for
each racer.
The blue barriers follow the cartridge's driving-wall boundaries on flat ground.
Their outlines are smoothed by at most three screen pixels, then drawn as one
continuous white-and-blue rail. The dirt texture and original start-line checker
remain.
Ramp tops and water areas are flat dirt, and cars have no jump movement.
The three original roads are selectable, with road 3 selected on startup.
Rivals follow driveable routes through the checkpoints at different speeds,
stay within the walls, react to impacts, and can win the race. The player's car
checks its center against the driving walls along each move. Barrier hits turn
the car along the rail and trim one speed step; car-to-car hits turn it two
heading steps and briefly stagger the rival.
Car sprites are clipped at the track view edges so they remain visible there.
Music, tournament, and advanced terrain physics have not been ported.
The required hardware is an Atari XL/XE with a VBXE FX 1.2x core at `$D600`
or `$D700`.

## Build and run

Run `./build.sh` in this directory, or `./atari/race/build.sh` from the repository
root. The result is `race-vbxe.xex`. The build requires MADS. To regenerate
the course, car, road, and font assets from the decompiled cartridge, run
`./build.sh --regenerate-assets`; that step also requires Python 3 and Pillow.

Build and launch in the configured Altirra profile with:

```sh
./atari/race/run-emulator.sh
```

The runner works from any current directory. It rebuilds the XEX, then uses
the repository's persistent Altirra VBXE profile.

## Controls

Use either Atari joystick port. On the menu, up/down selects a course and
fire or Space starts a four-lap race. During a race, up accelerates,
down brakes and reverses, left/right steers, and fire or Space uses limited nitro. Complete
the waypoints in order; the lap counter advances when you cross the start
waypoint. The first driver to complete the selected laps wins. Fire or Space
returns to the menu after finishing.

The source cartridge is `allgames/[Race]/Pico Off Road.p8`. `make_assets.py`
decodes the cartridge's course compression and writes `track*.bin` and
`course-data.asm`. It builds the aligned road art in `road-assets.bin` and
rasterizes the car mesh into `car-sprites.bin`.
It also generates safe rival routes from the driving maps and reduces the
illustrated `title-art-arcade-v2.png` to a full-width VBXE title scene with the
colorful game name embedded in the image. The menu shows only the track choice
and start prompt over a plain background.
The XEX loader places the car sprites in VBXE RAM, then reuses their Atari RAM
staging area for the track art. The program builds each selected track image
in VBXE RAM and scrolls a 320×160 view over it. The lower 40 lines show the
race status.
Two VBXE framebuffers alternate at vertical blank to keep the display steady.
