# Double Dragon: loader and VBXE compatibility

The original feedback suggested that the XEX might load onto the CPU stack or
below a loader's resident memory. Auditing the actual old executable found:

- Uploader: `$2000–$2054`.
- Asset staging: `$8000–$8FFF`, reused for 97 uploads.
- Runtime: `$3000–$7E70`.
- Low-memory records: only `$02E0–$02E3`, the normal Atari RUNAD/INITAD vectors.

There was no payload on the `$0100–$01FF` stack. However, the low uploader could
conflict with larger resident loaders. It also clobbered six zero-page bytes
and left a VBXE window mapped over loader RAM between INIT calls. The latter
failure was reproduced before the fix: the loader-handoff regression failed
with `INIT left a VBXE window mapped over loader RAM`. The reporter's actual
system and loader are unknown, so the precise cause of their failure remains
unconfirmed.

## Corrected load layout

| CPU address | Use |
|---|---|
| `$02E0–$02E3` | Standard RUNAD/INITAD vectors only |
| `$3000–$7E70` | Runtime code/data |
| `$8000–$8FFF` | Reused 4 KB upload staging |
| `$9000–$90E3` | Upload/detection/preparation routines |
| `$B000–$BFFF` | Software-selected VBXE window, with BASIC disabled |

No payload loads below `$3000`. Every upload preserves A/X/Y/P, its scratch
bytes `$CB–$D0`, and PORTB. It clears MEMAC-A and MEMAC-B before returning to
the loader. The final preparation INIT selects normal RAM before runtime
segments are loaded, preventing writes into a selected RAMBO bank. The
renderer initializes both the MEMAC configuration and bank selection.
Inherited blitter interrupts are disabled; the renderer polls completion.

`build.sh` runs `tools/verify_xex.py`, which checks the segment bounds and the
97-upload-plus-preparation INIT sequence. `generated/xex-layout.txt` contains
the complete load-address inventory.

## Specification and supported configurations

References checked:

- [VBXE FX 1.26 specification, local copy](../../../atari-vbxe-toolkit/docs/vbxe-fx-1.26-pl.pdf),
  pp. 6, 27–30, 41 and 46–47: version detection, register locations and MEMAC.
- Avery Lee's [Altirra Hardware Reference Manual](https://www.virtualdub.org/downloads/Altirra%20Hardware%20Reference%20Manual.pdf),
  VBXE/MEMAC sections, cross-checked with local Altirra 4.40 source.

VBXE hardware registers are at `$D640–$D65F` or `$D740–$D75F`. This is separate
from the software-configured CPU window and bank numbers inside 512 KB VRAM.
The game configures a CPU-only 4 KB window with MEMAC_CONTROL `$B8`; BASIC must
be disabled because ROM takes precedence over MEMAC at `$B000`.

Detection requires CORE_VERSION `$10` and `(MINOR_REVISION & $70) == $20`.
The RAMBO flag at bit 7 does not change compatibility. Both register pages are
checked, even if the first contains an incompatible core. This supports the
FX 1.2x register family, including 1.26a/g and 1.26r. GTIA-only cores lack the
required blitter/overlay; pre-1.20 FX cores use an incompatible MEMAC interface.
These and unknown core families are rejected instead of being driven with the
wrong register layout. This is not a port to the Atari 5200.

Use a standard multi-INIT XEX loader with free application RAM from `$3000`
upward. The game requires exclusive use of VBXE VRAM; it cannot coexist with
an active RAM disk/resident code occupying that VRAM. Compatibility with every
DOS, cartridge or resident-driver combination is not claimed.

## Automated verification

```sh
bash build.sh
python3 tools/test_vbxe_compat.py
python3 tools/test_runtime.py
```

The compatibility test executes the assembled 6502 uploader and runtime, with
XEX records written through the memory model rather than directly into RAM.
It models MEMAC base, size, aligned bank selection, enable bits, MEMAC-B,
BASIC/OS priority, and RAMBO aliasing. It boots FX 1.20, 1.24, 1.26 and 1.26r at
both D600/D700, with inherited windows, BASIC initially enabled, selected
RAMBO banks, and loader scratch writes between INIT calls. Every configuration
checks all 97 uploads, title/start, movement and rendering. The detector is
also checked against incompatible cores and a decoy at the other register page.
Unsupported cores reach the error screen without VBXE writes or blitter use.

Results are in `generated/vbxe-compatibility-results.txt`. Gameplay, scrolling,
combat and campaign regression results are in `generated/test-results.txt`.
The CPU model does not test electrical timing or real SIO/DOS implementations.
Physical hardware and the reporter's unknown loader have not been tested.

Altirra 4.40 PAL smoke checks also reached gameplay and responded to keyboard
start/combat/pause on FX 1.26 at D600, FX 1.26r at D700 with 320K RAMBO,
and FX 1.20 at D700. Captures are `generated/compat-*-*.png`. These checks
used separate test profiles and did not change the user's persistent profile.
