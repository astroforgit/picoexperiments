# Autonomous improvement passes

## Baseline review

References: the nearby Sulka and Porter assembly ports, Porter's POKEY player,
and `atari-vbxe-toolkit` probe and emulator helpers.

The first real Altirra 4.40 PAL screenshot confirmed working VBXE graphics but
revealed a three-digit timer (incorrect text offsets). Code review found that
simulation time depended on completed renders, sprite address calculation took
time proportional to screen Y, Sven was always drawn in front, START restarted
every held frame, and the winning collection tone could stay on indefinitely.
The original CPU model did not validate those cases.

## Proposed implementation

1. Correct HUD columns; use actual OS clock deltas with a fixed 50 Hz simulation
   on PAL and NTSC; test skipped frames and clock wrap.
2. Replace repeated address addition with row tables, and draw actors by their
   foot Y coordinate so they overlap properly.
3. Use a common artwork scale, original idle sprites, and the supplied smoke
   disappearance sequence. Keep collection non-explicit and retain asset credits.
4. Add a ready screen, pause, held WASD movement, edge-triggered START/R restart,
   and finite sound envelopes with a mute control.
5. Strengthen the CPU/blitter harness, then exercise the finished XEX in the
   local persistent Altirra profile and save screenshots and reproducible checks.

Results are recorded in `TESTING.md` after verification. No other game project
or persistent emulator device configuration is changed.

## Pass 2: model and real-emulator checks

The expanded assembled-code suite passed both register addresses and simulated
video rates, including clock wrap, held controls, smoke completion, finite
terminal audio, and depth order. A local Altirra PAL playthrough reached 8/8 and
replayed. The renderer now takes approximately 5,556 modeled CPU cycles for
all nine actors, excluding VBXE DMA and raster waiting.

The longer real-time test then caught an error in both the implementation and
the original test fixture: GTIA PAL is `$01`, not `$00`. Testing the whole byte
for zero incorrectly selected the NTSC rate on PAL. A 45-second wall-time wait
only consumed about 38 game seconds. The local cc65 `_gtia.h` confirms PAL
`$01` and NTSC `$0E`; detection now masks `$0E` before selecting the rate. The
fixture now uses those actual register values. The emulator timing scenarios
are repeated after this correction, rather than accepting the model pass.

`verify.sh`, pinned test/build requirements, and the PowerShell playthrough and
timing scripts make the review/build/test/inspect cycle repeatable. Input stress
also exercises 400 deterministic mixed-input steps per register/video combination.

## Pass 3: final emulator regression

With PAL detection corrected, the ten-second timing observation consumes eleven
integer timer ticks over 10.642 wall seconds. Pause preserves the entire game
area and HUD pixel-for-pixel over 10.668 seconds. Waiting through the complete
countdown reaches `00` and the loss message, and Space replays successfully.
The final keyboard playthrough collects all eight sheep with 58 seconds left,
finishes the disappearance effects, displays the win message, and replays.

All four assembled-code configurations and missing-VBXE handling pass on the
final executable. `TESTING.md` records its hash, evidence, commands, and the
remaining real-hardware/NTSC/D700/audio-listening limits. No further gameplay
features are needed for this pass; the resulting build is ready for review.
