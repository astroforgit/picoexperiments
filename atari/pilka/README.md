# Pilka — Retro Fans League / Atari XL/XE + VBXE

Work-in-progress native 6502 conversion of the supplied `arlasoc.d64`.
Players, goalkeepers and the ball use the original C64 sprites. Pitch geometry
and match rules come from the C64 game. Grass pixels come from the supplied
Amiga SWOS 25/26 archive. Pitch advertising is replaced by pixel-art flowers and Atari Fuji symbols.
POKEY football effects are enabled; music remains disabled.

## Build and launch

```sh
./build.sh
./run.sh
```

`build.sh` produces `pilka.xex`. It requires MADS, Python 3, py65, Pillow and
NumPy. `run.sh` uses the existing workspace Atari VBXE toolkit / Altirra profile.
Target: PAL Atari XL/XE, 64 KB RAM, VBXE FX 1.2x with 512 KB VRAM. The loader
probes `$D600` and `$D700`. NTSC match timing has not been validated.

## Retro Fans League

The XEX opens the league menu. Use joystick 1 to navigate and fire to confirm.
Start a league by choosing one of eight clubs. Friendly opens the match
settings with pitch, length, and each side's controller, formation, shirt
and strength. Friendly is the only match type on this screen; there is no
Mode selector or player preview. The separate Classic Game entry is removed.
Continue League resumes the current season in memory. Credits is the last
main-menu item and opens a modal credit panel; Fire or Escape closes it and
returns to Credits. The main-menu footer reads GAME BY ASTROFOR, with V1.0.0 on the right. The panel
credits Amiga Sensible World of Soccer as a major inspiration and Arlasoft
Soccer by Arlasoft as the C64 game that inspired this project.

Choosing or continuing a league opens a club menu. Use up/down and fire for
Play Next Match, League Table, View Squads, Match Schedule, Last Results,
Match Options, Difficulty or Main Menu. At season end Play Next Match becomes Final Table. Escape returns
one level from every menu, including Friendly settings. Holding Escape only
moves back once.

The table labels wins, draws, losses and points. Scores appear beside their
teams. Squad numbers are shirt numbers and the squad is a read-only list of
the starting eleven and five reserves. During a match,
joystick 1 controls the chosen club at home or away.

**Match Options**, inside the league menu, sets pitch and duration for league
matches. Defaults are Random pitch and 3 minutes. **Difficulty** is a ten-step
Easy–Hard slider controlled by left/right. Easy gives your club strength 10;
Hard gives it strength 1. CPU opponents use their season-assigned strength.
The slider shows only its numeric strength value, 10 at Easy through 1 at
Hard, and defaults to step 5
(your strength 6), applies at home and away, and persists while continuing
the season. Fire or Escape returns to the league menu. Friendly has
its own pitch and duration settings. On the Friendly screen, use up/down to
select an option, left/right to change it and Fire to start. Escape returns
to the main menu; SELECT and left+Fire also work. Holding OPTION at startup
opens Friendly settings directly.

The four main menu choices each have their own football illustration, with a
separate illustration in Match Options. The built-in image generator produced
the six-panel source sheet from a prompt for a floodlit trophy, footballers
duelling for the ball, a tactics clipboard with boots, a whistle and ball,
a classic cup with joysticks, and a team lineup, in retro football pixel art.
The build reduces the panels to a shared 16-colour palette.

Atari Fuji FC, C64 SID United, Amiga Boing Athletic, ZX Spectrum Rainbow,
Amstrad CPC City, BBC Micro Owls, Apple II Orchard, and IBM PC United play
14 home-and-away rounds (56 fixtures). The league plays out the user's
match in Arlasoft and simulates the other three matches in the round.
Standings use points, goal difference, then goals scored. Teams level
on all three share the title. The scorer line uses the last touch for
played goals when it belongs to the scoring club and credits the forwards
for simulated goals.

The first build has fixed starting lineups and club-level formation and shirt
settings. Reserve selection, individual abilities, and disk saves are future
work. Reset or reload clears the season.

## Implementation

The C64 6502 program is retained at its own addresses, rather than rewritten
as a different football simulation. `analysis/arlasoc-disassembly.txt` contains
reachable assembly reconstructed from execution coverage and branch traversal;
it is not a high-level C decompilation. `gen/patches.json` records hardware
operand changes. The bridge supplies input, frame interrupts and VBXE drawing.

Memory:

- `$C000-$CFFF` is a permanent MEMAC-A window on VRAM `$7C000`, so the game's
  two screens are VRAM and the blitter can read them. While a picture is
  built, the window shows VRAM `$7D000` instead: the renderer (`src/render.asm`).
- `$F000-$F7FF` (the C64's VIC-only character set) holds the interrupt, the
  VBXE access routines and the relocated formation tables; `$CC00-$CFFF`
  (unused sprite patterns) holds the game-loop hooks; `$C900-$CBFF` the
  relocated menu table. Variables are at `$DC10` and `$DC40`.
- The C64 game keeps data in the RAM *under its I/O area* and reads it with
  I/O banked out: the menu table (`$D780`) and the 35-byte formation records
  (`$DA7D-$DEFF`, and `$C980,$CA80..$CF80,$D080`). The Atari has hardware,
  colour RAM and bridge variables at those addresses, so the build moves the
  data and points the game's two readers at the copies (`tools/build.py`).

League VRAM uses three 4 KiB pages. Code at `$71000` runs through MEMAC-A.
Names, immutable tables and menu text at `$79000`, and state and menu cells
at `$7B000`, use MEMAC-B. The
existing character renderer draws league menus. The loader stages the CPU
RAM image in framebuffer 0 and restores it before clearing that framebuffer.
It uploads the game and renderer banks separately to `$7C000` and `$7D000`.
The build checks that uploaded ranges do not overlap. Six 4 KiB pages at
`$5D000`, `$5E000`, `$72000`, `$7A000`, `$7E000` and `$7F000` hold the
menu pictures. The renderer appends artwork to the same blit list as the
menu frame.

Timing: the Atari VBI plays the C64 raster interrupt (`$922E`). The game loop
is hooked where it has just sorted its sprite list (`$973C`): there the scroll
position, visible screen, sprites and ball are one consistent state, exactly
what the C64 shows in the next frame. The frame wait consumes one VBI per
loop; if the loop falls behind, pictures are skipped until it has caught up,
so game speed stays at one iteration per frame. The game's time-sliced screen
copy reads a C64-equivalent raster line derived from VCOUNT.

Renderer (one picture per game loop when the blitter keeps up):

- The character layer is a 40x25-cell ring in VRAM. A C64 coarse scroll (the
  game copies its screen shifted by one cell and flips `$D018`) only moves the
  ring origin (hook at `$1269`); nothing is copied.
- The blitter XORs the C64 screen with the characters last drawn and ORs the
  result into 25 row flags and 5x25 eight-column flags. The CPU visits only
  flagged cells and queues an 8x8 tile blit for each. Colour RAM is plain RAM,
  so the CPU compares it: all rows in the menu, one rotating row in a match
  (there, colours only change together with characters).
- One blitter list then draws the picture into the hidden framebuffer: queued
  tiles, the layer through the C64's 38-column/24-row window with fine scroll
  (up to four pieces of the ring), sprites, and for sprites with C64 "behind
  foreground" priority the foreground pixels again on top. The VBI shows the
  picture once the blitter has finished, and loads the palette entries that
  follow VIC registers at the same moment.
- Tile pixels use palette indices in which foreground colours occupy bits 3-7
  and background colours bits 0-2, so "foreground only" is a transparent blit
  with AND mask `$F8`. Every background-colour pixel carries one of three
  grass shades; the palette maps them to the SWOS grass on the pitch and to
  the plain C64 background colour elsewhere (menu).
- Advertising text cells (pitch colour, characters `$D9`+) are replaced by the
  generated strip, chosen by map column so it scrolls with the pitch.

Amiga-style dressing (match only, pitch colour 9; `tools/build_assets.py`):
crowd characters take several colours per pixel pair, the stand structure
(yellow multicolour 1 on the C64) is shown grey, and the pitch has mowing
stripes: on every second band of four map rows, pitch characters use a second
tile set with lighter grass (VRAM `$74000`). Stripes and advertising depend on
the map position, not only on the character, so each cache entry also records
the light-stripe flag, cells brought in by a coarse scroll are checked against
it, and a jump of the map position (`$E80E/$E80F`) redraws everything.

Colours: each of the 16 C64 colours is shown as a 12-bit Amiga colour, taken
from the SWOS game palette where it has a counterpart (`AMIGA12` in
`tools/build_assets.py`); the graphics themselves are unchanged.

C64 sprite frames 32-127 are converted at build time to 24x21 VRAM images
(one per 512 bytes at `$60000`). The 23 multiplexed sprites come from the
game's tables (`$9F`, `$E4`, `$CD`, `$B6`); the first `$FF` Y entry ends the
list. A sprite is behind the foreground when bit 6 of its colour is set and
the game has patched its multiplexer slot (mask `$8E8D`, slot = list index
mod 7), as the C64 raster code does. The ball is VIC sprite 7 and is drawn last. Sprite-colour pixels are
stored as `$FF`, and the blit's AND mask turns them into palette entry
`$60` + the sprite's C64 colour. The menu's expanded sprites use blitter zoom.

## Reproducing analysis and asset extraction

```sh
python3 tools/extract_c64.py
7z x -aos -oamiga SensibleWorldOfSoccer2526_v2.3.lha
python3 tools/extract_swos.py
python3 tools/preview_swos.py
python3 tools/coverage.py
./build.sh
python3 tools/test_league.py     # league, half-time, result, standings
python3 tools/test_league_navigation.py # parent menus, held Escape and explicit league choices
python3 tools/test_league_art.py # illustrated menus, options and Classic Game return
python3 tools/test_port.py       # original menu, match start, formation data
python3 tools/test_renderer.py   # every picture against a C64 rendering
python3 tools/speed.py           # cycles per frame by routine
```

The RNC1/RNC2 extractors validate compressed and decoded CRCs. All 34 graphics
files have passed those checks. Four player sheets are exported as indexed
pixels; pitch map 1 is also decoded to a full-pitch preview.

The headless models in `tools/reference` are adapted from the sibling `gg`
conversion. `nmos.py` adds the LAX instructions used by this game to py65.
The Atari model runs each blitter list at once and models only its duration;
it rejects CPU writes to VRAM a running list uses. It does not replace
testing in Altirra or on real hardware.

## Sources

- C64 game: the user-supplied `arlasoc.d64` (Arlasoft Soccer).
- Amiga grass pixels: the user-supplied `SensibleWorldOfSoccer2526_v2.3.lha`.
- SWOS layouts and palette: `SWOS-RE-main/SWOS-RE-main`.
- VBXE bridge/loader and headless model references: sibling `../gg` project.
- RNC decoder adaptations: ScummVM, GPL-3.0-or-later; see decoder file headers.
- Flowers and Atari-symbol banner pixel patterns: `tools/make_banners.py`.

No source archives or sibling projects are modified by the build.

## Validation

`tools/test_credits.py` checks the author footer, Credits popup text, safe
directional input, Fire/Escape return, and unchanged season state.

`tools/test_league.py` navigates the league, accelerates the match clock at
the engine's update point, and checks the real half-time and full-time
transitions. It exercises both controller assignments, goal attribution,
friendly isolation, and the season routines across all 56 results.
Use `--page d7` to repeat against VBXE at `$D700`.

`tools/test_renderer.py` plays a match and compares every picture shown with
an independent C64 rendering of the state the renderer sampled (advertising
cells excluded). Latest runs: four input scripts, 3,000-4,000 PAL frames
each, at `$D600` and `$D700`: about 13,000 pictures, no differing pixel, one
game-loop iteration per frame, 0.91-1.0 pictures per frame. `tools/test_port.py`
checks boot, menu navigation, match start, that the formation records the
game reads equal the C64 data, and two-channel POKEY configuration, at both register pages.

Not validated: this renderer in Altirra or on real hardware (it relies on
MEMAC-A at `$C000` with the OS ROM off, code executed from VRAM, blitter OR/XOR
modes and a zero destination step), NTSC timing, complete matches and every
menu mode. Blitter speed in the model is an estimate, so the real picture
rate may differ. Sound balance and pitch still need listening in Altirra or on hardware.

League menu safety: Fire on the table, squads, fixtures and results returns
to the club menu. Only Play Next Match starts league play. Selecting a club
for a new season while a season exists asks before deleting results; Cancel
is selected initially. Cancel (or Escape from this confirmation) resumes
the current league menu, just like Continue League. Continue retains the current season in VBXE memory.
This is session storage, not a disk save, and does not survive rebooting.

During a match, Escape pauses play and opens a confirmation over the pitch.
Escape resumes; Fire stops the match and returns to the main menu. In a
league match this records a 0–3 loss for your club, completes the round,
and retains the season for Continue League. Friendly and Classic matches
are abandoned without changing the league. The confirmation warns of a
league forfeit and the match clock is frozen while it is open.

`python3 tools/test_match_cancel.py` checks pause/resume, home and away
forfeits, friendly isolation and Classic cancellation (`--page d7` supported).

The pause overlay uses one additional 4 KiB VRAM page at `$73000` for code
and monochrome artwork. It backs up the covered pixels in the idle
framebuffer, restores them on resume, and forces the next game render to
refresh that framebuffer. It does not change the roster or season allocation.

The league and Classic menus use the compact font and shadow pixels from the supplied
Amiga `CHARSET.RAW`, with dark green panels, red selection bars, cream text
and gold headings. Classic Game uses the same menu font and colours; match glyphs retain their
original assets. The narrow SWOS I and 1 use full-width forms to avoid false word
breaks in the fixed-width Atari menu grid. The menu font is stored in spare VRAM beside the boot staging code,
advertising tiles and character layer; it does not reduce season capacity.
`tools/menu_style.py` generates these tiles and the renderer lookup tables.

The title uses the selected Compact football classic artwork, converted by
`tools/title_art.py` from `assets/title-classic-source.png` to ivory, green
and gold. The main menu displays the two-line title at (60,12), 200x56 pixels,
with options below it and a smaller football illustration beside them.
Submenus and Friendly settings use a 208x16 one-line header at (56,8).
The 100x28 main bitmap occupies unused list-bank space at `$70500`; the
compact header uses `$77300-$77FFF`, beyond the light-pitch tiles accessed
by the renderer (characters 0-202). The loader stages that header with the
light tiles so startup preserves it. Credits also greet Marbed and his
Atari Super Soccer.

`tools/test_friendly_menu.py` checks the four-entry menu, fixed Friendly mode,
option wrapping, removed previews and league isolation when cancelling.

`tools/test_league_options.py` checks defaults, all ten slider positions,
endpoint clamping, and engine strength values for home and away matches.

At each new season, all eight clubs receive a persistent 1–10 strength.
The weighted draw is `1,2,3,4,4,5,5,5,5,5,6,6,7,8,9,10`, so 5 is most
likely and 4–6 cover most draws. A hardware-random/frame-counter seed varies
new seasons. Continue preserves strengths; cancelling replacement never
rerolls them. The player's in-match strength still follows Difficulty.

CPU fixtures use each side's strength against its opponent plus two random
0–15 form rolls. Goals are `clamp(floor((attack - defence + roll1 + roll2 -
10) / 4), 0, 5)`. The random generator advances twice per roll to reduce
adjacent-roll correlation. Stronger clubs tend to win, but draws and upsets
remain possible. Results feed the existing points/goal-difference table.
`tools/test_league_simulation.py` checks rating distributions, score bounds,
strength effects and upsets across every nonzero random seed.

## Football sound effects

The 50 Hz POKEY engine uses two channels: kicks/referee whistles/menu clicks
on channel 1 and goal celebration noise on channel 2. There is no continuous
match ambience or crowd swell on kicks. Whistles take priority over kicks.
Full-time uses a longer pulsed whistle; goals trigger a crowd roar followed by
a celebration fade. Pausing mutes match sounds; menus have quiet input clicks.

Crowd frequency, volume and ramp settings were extracted from the supplied
`alter/Atari_Soccer_VBXE_R90.xex` routine at VRAM `$6AEC0`. Provenance and
its SHA-256 are in `assets/sound/alter-crowd.json`; rerun
`python3 tools/extract_alter_sound.py` to extract them again. Normal builds use
that small JSON file and do not require the alternate XEX. The event handling
is adapted to our engine; the alternate game's music engine is not imported.

The supplied Amiga SWOS source uses separate kick, foul/game-state whistle
and crowd events. This version follows that approach with synthesized POKEY
effects, not copied Amiga PCM samples, chants or speech. The original disabled
SID player stays disabled. Its kick/whistle request bytes are consumed by the
new engine; the crowd/state byte used by game logic is preserved.

Audio code occupies spare space at `$CD00` in the pause VRAM bank (`$73000`),
with one resident goal flag and a small bank-switch bridge. It allocates no new
VRAM bank and preserves both graphics mappings and zero-page pointers.
`python3 tools/test_sound.py` checks the assembled engine at both VBXE pages,
including duration, priorities, crowd ramps, menu/pause muting and bank safety.
These are register-level headless checks, not a listening test.

## TNFS / SD XEX loading

The XEX is intended for standard segment loaders, including FujiNet PicoBoot,
with 64 KB Atari RAM and a VBXE FX 1.2x core. It has no direct TNFS or SD access:
the device/OS loads the file, and each INIT copies a staged block into VBXE.

A packaging bug previously added a second initial `FFFF` marker in front of
the one already emitted by MADS. PicoBoot skips exactly one initial marker,
so the duplicate is interpreted as the first load address. The actual
PicoBoot code reproduces a BRK at `$0001` within the first two XEX sectors.
The build now emits exactly one marker and asserts this invariant.

`tools/test_disk_loader.py --picoboot /path/to/picoboot.bin` runs the actual
FujiNet 6502 loader against simulated 128/256-byte SIO sectors at both VBXE
addresses. It reproduces the old failure, reaches RUN with the corrected
file, and compares every byte of uploaded VRAM against direct XEX loading.
The script pins the upstream binary URL and SHA-256. Download that binary
from the URL in the script; it is not bundled here. Results are recorded in
`analysis/disk-loader-test.json`. Physical TNFS/SD hardware and OS interrupt
timing still need a user test; this does not establish compatibility with
every SD cartridge loader or firmware.
