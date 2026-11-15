# Running the Speed games

All existing launchers now use the isolated standard-Atari configuration
introduced for Babajaga. Existing commands remain the same:

```sh
/home/marcin/tmp/pico/atari/speed/orgmazarun
/home/marcin/tmp/pico/atari/speed/race/run.sh
/home/marcin/tmp/pico/atari/speed/grandprix/run.sh
```

Race and Grand Prix still accept `auto` (self-driving build) and `rebuild`
(build then play). Missing builds are built automatically as before.

All three delegate to `run-standard.sh`, which reuses
`../babajaga/run-emulator.sh`. They share **../babajaga/altirra-standard.ini**:

- Atari 800XL, 64 KB, PAL, BASIC off, one POKEY, no expansion devices/VBXE.
- Initial speed 100%, turbo off, audio latency 80 ms plus 100 ms extra buffer.
- Arrow keys / left Ctrl for joystick port 1, plus gamepad and numpad mappings.

The INI is created from Babajaga's standard defaults if missing. Changes made
in a standard emulator window persist there after normal exit and apply to
all these games. It never loads or writes your normal VBXE registry profile.
For Grand Prix's two-player mode, configure a second controller in this
separate profile. Avoid several simultaneous instances playing music.

To inspect a launch without opening Altirra:

```sh
./orgmazarun -PrintCommand
./race/run.sh auto -PrintCommand
./grandprix/run.sh -PrintCommand
```

This uses the existing Windows Altirra installation from WSL. Game sources,
artwork and binaries are not changed by this launcher migration.
