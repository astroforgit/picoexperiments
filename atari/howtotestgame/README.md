# Testing an Atari VBXE game in this repo

This guide is for coding agents and people working on the Atari XL/XE + VBXE
games here. The examples come from Star Fisher (`atari/roof/game`), but the
same tools and techniques work for the other ports.

## 1. Build first, and read the label file

```bash
cd atari/roof/game
./build.sh   # Python asset/sound generators, then:
             # mads star-fisher.asm -o:star-fisher.xex -t:star-fisher.lab -l:star-fisher.lst
```

- `star-fisher.lab` lists every assembler label and constant. Tests load it
  with `load_labels()` and look up addresses by upper-case name, for example
  `L['SILENCE_LEFT']` or `L['RENDER']`. Never hard-code addresses.
- `star-fisher.lst` is the listing. Use it to count cycles or to find the
  address of an instruction you want to patch.
- Put build-time checks in the source. Use `.if * > $7800` / `.error "..."`
  in the asm and `assert` in the Python generators (for example, an assert
  that the audio banks don't overlap the audited VRAM ranges). Then a bad
  memory map fails the build instead of silently corrupting memory.

## 2. The headless emulator

### `atari/lair/tools/emu.py`, class `Atari`

The 6502 runs under py65, plus just enough of the machine to run these games:

- the OS vertical blank, or the game's own NMI handler when the OS is off;
- joystick, trigger and keyboard registers;
- POKEY register writes;
- VBXE: the MEMAC window at $9000, 512 KB of VRAM, palettes, the blitter
  (modes 0/1) and the XDL.

| Call / field | What it does |
|---|---|
| `a=Atari('game.xex'); a.boot()` | Loads the XEX segment by segment and runs each INI routine, like a real loader |
| `a.run_frames(n, inputs=None)` | Runs n PAL frames of 32,760 CPU cycles each |
| `a.call(addr)` | Runs one subroutine until it returns |
| `a.screenshot(path, scale)` | Renders the current XDL and framebuffer to a PNG. With `None`, returns the image (for hashing) |
| `a.mem.ram` | CPU RAM (bytearray) |
| `a.vram` | VBXE memory (numpy uint8, 512 KB, starts as random junk like real hardware) |
| `a.xdl_writes` | Log of `(frame, reg, value)` for every XDL address write, i.e. every frame presentation |
| `a.pokey_log` | POKEY registers, one entry per frame |
| `a.memac_on()`, `a.bank` | Current MEMAC state |

### `atari/roof/game/tools/pcm_emu.py`, class `PcmAtari`

This subclass adds:

- POKEY timer 1 interrupts at the real rate, `(AUDF1+1)*28` cycles, honouring
  IRQEN, STIMER and the CPU I flag;
- a log of every volume-only DAC write with its CPU cycle, in
  `a.pcm[0xD203]`, `a.pcm[0xD205]` and `a.pcm[0xD207]` (entries are
  `(cycle, level)`);
- `a.irqs`, the number of interrupts taken, and `a.period()`, the cycles per
  sample;
- VCOUNT (`$D40B`) following the PAL beam, with the vertical blank at line 248.

Minimal script:

```python
import sys
from pathlib import Path
ROOT = Path('atari/roof/game').resolve()
sys.path.insert(0, str(ROOT / 'tools'))
from pcm_emu import PcmAtari          # also puts lair/tools on sys.path
from emu import load_labels, FRAME_CYCLES

L = load_labels(ROOT / 'star-fisher.lab')
a = PcmAtari(ROOT / 'star-fisher.xex'); a.boot(); r = a.mem.ram
a.run_frames(2)                       # let main() and its init run first
print(r[L['STATE']], r[L['SOUND_ACTIVE']])
a.screenshot(ROOT / 'screenshots/check.png', scale=2)
```

## 3. Techniques that work well

### Drive input like a player

- Joystick and trigger: `a.set_input(stick=15, trig=1)`. The stick bits are
  active-low, so 15 means centred.
- A key press:

  ```python
  def tap(code):
      a.kbcode = code; a.skstat = 0xfb; a.run_frames(8)
      a.kbcode = 255;  a.skstat = 255;  a.run_frames(8)
  tap(0x0c)   # Return
  ```

- Navigating real menus with key presses catches bugs that poking state
  directly hides.

### Force rare states through labels

- To skip a long wait, poke the counter. For example,
  `r[L['SILENCE_LEFT']] = 1` skips a 15 s pause. To make a particular sound
  load next, set `LOAD_CLIP` and `LOAD_STATE`.
- Run 1–2 frames after `boot()` before poking. `main` and its init routines
  (such as `sound_init`) overwrite anything you set earlier.
- Patch immediate operands at runtime to try variants without rebuilding.
  For example, `r[L['PCM_ON'] + 1] = audf` changes the sample rate loaded by
  `lda #PCM_AUDF`.

### Call routines in isolation

Set the state you want, call the routine, then check exact pixels:

```python
r[L['BUFFER']] = 2; r[L['DRAW_BANK']] = 0xa0
a.call(L['RENDER'])
addr = (r[L['BUFFER']] << 16) + y * 320 + x
assert a.vram[addr] == 248
```

### Compare against a golden reference computed in Python

- For audio, compute the expected levels with the same converter the build
  uses (`samples.levels`, plus any page padding). Then sum the three DAC logs
  sample by sample and require an exact match:

  ```python
  ch = [[v for _, v in a.pcm[x][start:]] for x in (0xD203, 0xD205, 0xD207)]
  assert [sum(t) for t in zip(*ch)] == expected
  ```

- For graphics, compare `a.vram` regions with the generated `assets/vram.bin`
  or with images built by the asset scripts.

### Snapshot memory to prove nothing was corrupted

- Copy VRAM after boot (`boot = a.vram.copy()`), then play a long scripted
  session: menus, popup, casting, sound on/off.
- Assert that nothing changed outside the ranges the game is supposed to
  draw into (framebuffers, menu cache, XDLs, blitter command):

  ```python
  mask = np.ones(len(a.vram), bool)
  for start, end in dynamic_ranges: mask[start:end] = False
  assert not np.flatnonzero((a.vram != boot) & mask).size
  ```

- VRAM starts with random junk, so any stray write shows up.
  `tools/test_vram_audio.py` is a full example.

### A/B runs to prove a feature costs nothing

- Run the same input script twice, once with the feature forced on and once
  forced off.
- Compare `xdl_writes` (which frame each present happened on) and screenshot
  hashes every few frames.
- If they're identical, the feature never cost a frame or changed the
  picture. This is how background sample loading was shown to be free.

### Timing analysis

- **Interrupt jitter:** take the gaps between logged DAC write cycles. A gap
  of two periods or more means POKEY dropped a sample, because its interrupt
  flag holds only one pending event. Assert
  `max(gaps) < 2 * a.period()`.
- **CPU cost:** count the game's update counter (`TICKS`) over N frames, with
  and without the feature, or at different sample rates.
- **Waits:** compute them from cycles, not seconds × 50:
  `frames = len(samples) * a.period() // FRAME_CYCLES + margin`.

### Build variants in a temporary copy

- Copy `tools/`, `gen/`, `assets/`, the `.asm` files and `build.sh` into a
  `tempfile.TemporaryDirectory()`.
- Write a modified `editor-scene.json` there, run `build.sh`, and load that
  copy's `.lab` and `.xex`.
- Never edit the user's project to make a test variant. The `build()` helper
  in `tools/test_sound.py` and `tools/test_vram_audio.py` does this.

## 4. Emulator caveats

- **Frames are short.** An emulated frame is 32,760 cycles, about 8% fewer
  than real PAL's 35,568. Time-based waits need margins, and CPU-cost
  measurements are slightly pessimistic.
- **Not modelled:**
  - ANTIC display DMA (these games turn it off);
  - exact blitter timing (approximated);
  - real POKEY analogue output.
- **VCOUNT** exists only in `PcmAtari`, not in the base `emu.py`.
- **OS ROM area:** the RAM under the OS ROM is plain RAM in the emulator.
- **Init order:** pokes made before `main` runs are lost (see section 3).
- **Unmodelled behaviour:** if correctness depends on it, also check in the
  full emulator or on real hardware.

## 5. The full emulator, for eyes and ears

```bash
cd atari/roof/game && ./run.sh   # build, then atari-vbxe-toolkit/scripts/run-xex.sh
```

Use it for subjective checks: sound quality and noise, flicker, input feel,
pacing. Headless tests can't judge those. Write down what you checked,
because there's no automated record.

## 6. Editor and browser tests

- **Editor test:** `python3 tools/test_editor.py` starts `editor/serve.py` on
  a spare port, in an isolated temp copy of the game. It then drives
  `editor/browser.test.cjs` with Playwright: editing, saving and building.
  Finally it boots the built XEX in the emulator to check the edits reached
  the game.
- **Playwright in this WSL box** (no root needed):

  ```bash
  export PLAYWRIGHT_MODULE=/home/marcin/tmp/suneditor/node_modules/playwright
  export CHROMIUM_PATH=/home/marcin/.cache/ms-playwright/chromium-1140/chrome-linux/chrome
  # missing libs: apt-get download libatk1.0-0 libatk-bridge2.0-0 libgbm1 libatspi2.0-0 libwayland-server0
  # then dpkg -x each into a scratch dir and:
  export LD_LIBRARY_PATH=<dir>/usr/lib/x86_64-linux-gnu
  ```

- **Server endpoints:** call them directly, for example:

  ```python
  req = urllib.request.Request('http://127.0.0.1:8791/api/sound-usage',
        data=json.dumps(sound).encode(), headers={'Content-Type': 'application/json'})
  print(json.load(urllib.request.urlopen(req)))
  ```

- **Visual check:** a short Playwright script that opens a tab, waits for a
  known text, and saves a full-page screenshot. Then look at the PNG. This
  catches layout problems the DOM assertions miss.

## 7. Running the suite

These live in `atari/roof/game/tools/`, and each prints `PASS ...` lines and
exits non-zero on failure:

- `test_sound.py`: legacy loop and synth modes
- `test_random_sound.py`: random one-shots, pauses, mute/resume, sample timing
- `test_vram_audio.py`: VBXE sound storage, corruption checks, A/B frame check
- `test_windows.py`, `test_fishing.py`, `test_sky.py`, `test_display.py`,
  and more
- `test_editor.py`: needs Playwright (section 6)

They're independent, so run them in parallel with logs:

```bash
for t in test_sound test_random_sound test_vram_audio test_windows; do
  (python3 tools/$t.py > /tmp/$t.log 2>&1; echo "EXIT $?" >> /tmp/$t.log) &
done; wait; tail -n 3 /tmp/test_*.log
```

Report failures honestly, and say which ones predate your change. At the
time of writing, `test_fishing.py` and `test_game.py` expected a four-row
menu, and `test_sky.py` imported a removed `scene_model` function. Both
problems predate the VBXE sound work.

## 8. Working rules

- **Uncommitted work:** the tree often has a lot of it. Never reset, stash or
  overwrite it. Check `git status` and `git diff` before editing.
- **User's processes:** don't kill them, for example the editor on :8791.
  `pkill -f <pattern>` can also match your own shell command and kill it.
- **Scratch files:** put throwaway scripts in a scratch directory, not in
  the repo. Add lasting tests to `tools/` with a docstring saying what they
  prove.
- **New tests:** when you add a feature, add a test that proves its claim.
  Assert exact values rather than "something happened", and include one
  check that would fail if the feature were broken.
