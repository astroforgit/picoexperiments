# Industrial Area music

Disabled at the user's request. The current build does not include the music
player, module, or interrupt hook, and the launcher no longer forces NTSC.
Combat sound effects are restored. The supplied SAP/RMT/XEX files and the
experimental integration sources are retained but not used by the game.

The following notes describe the previous experiment, not the current build.

The user-supplied `../Double_Dragon_Industrial_A.rmt` now plays throughout
gameplay, looping using its original RMT song jump. The matching SAP header credits
`<?> (Fragmare)` and names the tune “Double Dragon - Industrial Area”. The
source file is unchanged. This replaces the earlier no-music requirement.

The tune starts on a new game, pauses with gameplay, and is silent on the title,
game-over and victory screens. M/OPTION mutes all four channels; unmuting resumes
the music. A campaign restart restarts the tune. All stages currently use this
one track. Combat beeps are disabled: this SAP uses all four voices and shared
POKEY control/filter settings, so overlaying the old effects would damage it.

The SAP is TYPE B, NTSC, FASTPLAY 262, INIT $0C80, PLAYER $0603. The build keeps
its original player at $0390-$0B60, relocates its OS-overlapping variables from
$0280-$038F to $A280-$A38F, and relocates the RMT module from $4000 to $A400.
The wrapper initializes the player directly with the new module pointer and
saves/restores its $CB-$DD workspace around calls. BASIC is disabled before use.
An immediate VBI hook calls the player once, preserves CPU registers, flags and
zero page, then chains the previous OS VBI. A lock prevents the interrupt from
entering the player while restart initializes it. No music calls or sound-register
writes remain in the game update/render path.

The game launcher explicitly selects NTSC, matching the composition. Music now
advances at NTSC VBI cadence even when rendering is slow. The previous
render-driven catch-up loop, including double updates on PAL, has been removed.
If the XEX is manually loaded in PAL, playback is steady at 50 Hz but slower
than intended; select NTSC for the intended tempo and POKEY clock. Combat still
runs at 30 Hz in either mode. The shared launcher defaults remain unchanged for
other games; only Double Dragon requests NTSC explicitly.

`tools/make_music.py` checks the SAP hash and verifies that the supplied RMT
matches before relocating
instruction operands, instrument/track pointers and song jumps. Normal builds
need no new Python dependency. `tools/test_music.py` uses the existing py65 test
dependency to compare 4,000 POKEY register frames against the original SAP,
then unpacks the supplied standalone music XEX and checks that it contains the
same player and module. Integration tests exercise actual NMI/VBI entry and OS
chaining, registers, flags, OS/zero-page preservation, init locking,
pause/mute/resume/restart, and periodic interrupts during renderer execution.
This is CPU/register-level verification, not an emulator listening test.

```sh
bash build.sh
python3 tools/test_music.py
python3 tools/test_runtime.py
```
