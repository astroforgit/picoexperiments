# Local references

Paths are relative to the repository root unless stated otherwise.

## Emulator

Known Windows executable:

```text
C:\Users\grzeg\OneDrive\Desktop\atari\emulator\Altirra64.exe
```

WSL view of the same path:

```text
/mnt/c/Users/grzeg/OneDrive/Desktop/atari/emulator/Altirra64.exe
```

Installed Altirra help:

```text
C:\Users\grzeg\OneDrive\Desktop\atari\emulator\Altirra.chm
```

## VBXE documentation

- Toolkit copy: `atari-vbxe-toolkit/docs/vbxe-fx-1.26-pl.pdf`
- Original project copy:
  `steamlinejs/atari/vbxe/docs/vbxe-fx-1.26-pl.pdf`

The PDF is in Polish and documents the FX 1.26 register interface.

## Example VBXE programs

- `steamlinejs/atari/streamline-vbxe.asm`
- `steamlinejs/atari/streamline-vbxe.xex`
- `steamlinejs/atari/vbxe/examples/cosmic-abyss.asm`
- `grapple/atari/grapple-vbxe.asm`
- `grapple/atari/grapple-vbxe.xex`
- `atari-vbxe-toolkit/probe/vbxe-probe.asm`

## Important VBXE detection convention

Programs in this repository probe the identification value at `$D640` first
and `$D740` second. A value of `$10` identifies the VBXE FX register block.
Once detected, register operands are relocated to the correct page when the
program supports both configurations.

## Useful Altirra command-line switches

| Switch | Meaning |
|---|---|
| `/run <image>` | Load and run an Atari executable |
| `/w` | Start windowed |
| `/nosi` | Start a separate instance |
| `/noautoprofile` | Do not switch profile based on image type |
| `/profile:<name>` | Select a named persistent profile |
| `/portable` | Create/use persistent `Altirra.ini` |
| `/portabletemp` | In-memory temporary settings; avoid for persistence |
| `/debug` | Start in debugger mode |
| `/debugcmd:<command>` | Execute an Altirra debugger command |

