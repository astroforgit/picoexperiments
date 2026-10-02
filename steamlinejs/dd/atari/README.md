# Double Dragon — Atari XL/XE + VBXE

The source-versus-Atari feature checklist and implementation order are in
[PARITY.md](PARITY.md). Original terrain queries now have a tested native
component, but are not yet integrated into the playable XEX.

**Full-source conversion is in progress.** See [SOURCE-PORT.md](SOURCE-PORT.md)
for the recovered original engine, native graphics routines and their checks.
The XEX and launcher described below still run the earlier adaptation; they
have not yet been replaced by a complete port. Background music is disabled;
only short combat sound effects remain.

A playable native 6502 adaptation using graphics decoded from the supplied
`../double-dragon-snes-main/double-dragon-snes-main` source. Load
**`double-dragon-vbxe.xex`** on an Atari XL/XE with 64 KB RAM and a 512 KB
VBXE FX 1.2x core. Both `$D600` and `$D700` register locations are detected. Standard and
RAMBO/shared-memory FX 1.2x cores are supported; incompatible core families
are rejected with an error message.
PAL and NTSC use the same 30 Hz game simulation.

## What is implemented

- Four scrolling stages: streets, industrial area, caves and hideout. Each
  contains four adjacent source rooms, making a 1,024-pixel-wide playfield.
- Clear an encounter to unlock the camera, follow `GO RIGHT`, fight the next
  group, and walk through the right edge of the final room to leave the stage.
- Three enemy waves per stage, 36 enemies total, with a tougher Abobo in the
  final wave of each stage.
- Billy's walking, punches, kicks and jumping kicks; enemies use depth lanes,
  flanking, committed attack windups and recovery windows. Williams can guard
  frontal swings, Linda can sidestep, and Abobo has short hit stun/heavy blows.
- Guards cover the swing's impact; blocked punches can trigger a windup-based
  counterattack. Missed enemy swings leave longer recovery openings.
- Close-range grab-and-throw against stunned/recovering Williams or Linda;
  other enemies can interrupt the hold. Abobo cannot be grabbed.
- Directional hit boxes and a separate depth axis, hit stun, damage immunity,
  health, three lives, score, stage timers, game over and campaign victory.
- Title screen, pause, restart and sound toggle.
- Supplied Billy, Williams, Linda and Abobo tile artwork and animation poses.
- Double-buffered 320×200 graphics, VBXE blitter sprites sorted by depth,
  ANTIC status text and short POKEY combat effects. No background music.

This is **an adaptation, not a complete faithful port of the NES/SNES engine**.
The campaign uses 16 decoded source rooms with newly written encounter rules.
The camera advances to the right and locks during combat. This does not yet
reproduce every original level section, its complete room routing or vertical
scrolling. Terrain/platform collision, weapons, original grapple/throw rules,
climbing, experience/unlock progression, exact enemy AI, cutscenes, two-player
modes, the complete original soundtrack and SNES/MSU features are not implemented. Background
platforms and scenery are decorative. Combat timings, palettes and audio are
adapted. The source game and neighboring conversions are left unchanged.

## Controls

| Action | Joystick 0 | Keyboard |
|---|---|---|
| Move on the fighting plane | Directions | W/A/S/D |
| Punch | Fire | Space |
| Kick toward an enemy | Left/right + fire | A/D + Space |
| Jump kick | Up + fire | W + Space |
| Grab and throw a vulnerable enemy | Down + fire | S + Space |
| Start / retry | Fire | Space |
| Pause / resume | SELECT | P |
| Restart campaign | START | R |
| Toggle sound | OPTION | M |

Hold fire to repeat attacks. Line up with an enemy vertically before attacking;
punch/kick/jump-kick damage is 1/2/3. Ordinary enemy hits cost 2 of Billy's 12
health; Abobo hits for 5. Leave the attack lane or cross behind an enemy during
its windup, then counter during recovery. A grounded directional attack turns
Billy without stepping forward. Only the high portion of a jump evades grounded
strikes; launch and landing are vulnerable, with recovery before another jump.
Billy can move during a jumping attack. On keyboards
where Atari key combinations are limited, use joystick input for simultaneous
movement and attacks; the emulator's joystick mapping also works.

To throw, face a stunned or recovering Williams/Linda within 18 horizontal
pixels and eight depth pixels, then press down + fire. Billy holds for ten
ticks and throws behind himself for four damage plus knockdown. He remains
vulnerable during the hold. A failed grab still costs the attack's time;
ready enemies and Abobo cannot be grabbed. Existing poses are reused.

## Build and run

Requirements: MADS 2.x, Python 3.8+, Pillow 10.4.0. The generated assets and
ready-to-run XEX are included. No ROM download or SNES compiler is needed.

```sh
cd steamlinejs/dd/atari
python3 -m pip install -r requirements.txt
bash build.sh
```

`build.sh` regenerates assets from the local source, assembles the executable,
checks XEX load addresses and writes `double-dragon-vbxe.sha256`. Set `MADS` to override the assembler
path. Listings and symbols are in `generated/`.

To build and launch the workspace's persistent Altirra profile from WSL:

```sh
bash run-emulator.sh
```

Use VBXE FX 1.26 (standard or RAMBO/shared-memory), joystick port 0.
Without a compatible core, the program displays
`VBXE FX 1.2X REQUIRED AT D600 OR D700`. The game owns the full 512 KB VRAM;
extended RAM is disabled during gameplay.

## Verification

```sh
bash build.sh
python3 tools/test_runtime.py
python3 tools/test_vbxe_compat.py
```

The test requires py65, included in `requirements.txt`. It executes the assembled
6502 program and checks XEX loading, all VRAM uploads, framebuffer bounds,
double buffering, input, pause, directional/depth hit boxes, damage, respawn,
PAL/NTSC timing and both VBXE pages. It compares scroll output across room
boundaries and rebuilt stage graphics against the decoded source panoramas.
The old input-only jump-kick bot must now lose: it checks that continuous jumping
no longer trivializes combat. Separate, explicitly positioned combat fixtures
check all 12 waves, four stage exits and campaign victory. These fixtures are
not a complete gameplay playthrough. `tools/test_combat.py` checks the enemy
decisions, attack phases, damage, guarding, jump vulnerability and death handling.
Reports and model-rendered screenshots go in `generated/`.

The model does not emulate raster timing, ANTIC, POKEY synthesis or VBXE bus
contention. `generated/altirra-*.png` are separate captures from Altirra 4.40;
`generated/runtime-*.png` are from the automated model. Hardware has not been
tested. See `DEVELOPMENT.md` for the asset formats and memory layout.

The earlier scrolling build was checked in Altirra 4.40 PAL: start, movement, punching,
clearing the first wave, the `GO RIGHT` prompt, scrolling into the next room
and pause. `generated/altirra-wave-cleared.png` and
`generated/altirra-scrolled.png` capture that progression. The guarded Windows
helper `tools/check_altirra.ps1 -ProcessId <PID> -ScrollCheck` repeats it on
a freshly launched game, aborting if Altirra loses focus. Those captures predate
the combat rebalance; the rebalance has been checked in the assembled-6502 model.
See [COMBAT.md](COMBAT.md) for the tuning and its source references.

## Loader compatibility update

The uploader has moved from `$2000` to `$9000`; no payload now loads below
`$3000`. INIT calls preserve loader scratch pointers and CPU registers, restore
PORTB, and unmap VBXE memory before returning. The game explicitly initializes
its memory windows instead of relying on loader/power-on settings.

[COMPATIBILITY.md](COMPATIBILITY.md) documents the reported stack concern,
the reproduced loader-handoff bug, the corrected memory layout, specification
references, supported cores, and test results. Use a standard XEX loader that
processes INITAD between segments and provides free application RAM from
`$3000` upward. A loader that ignores INIT cannot load this streamed XEX.
