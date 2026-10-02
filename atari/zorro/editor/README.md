# Zorro editor

A browser editor for `../Zorro (1985)(Datasoft)(US).xex`. It changes the
game data in place and saves a new XEX that runs on a real Atari or in
Altirra. All addresses come from the disassembly in `../decompiled`.

```
./run.sh            # starts serve.py and opens http://localhost:8765
```

With the server running, the editor loads the game by itself and has
**Run in Altirra**, which saves `zorro_edited.xex` here and starts it. Next
time, the editor opens `zorro_edited.xex`, so your work continues. Delete
that file to start again from the original. You can also open
`index.html` directly in a browser, open the XEX with **Open XEX** and use
**Save XEX** to download the result.

## What you can edit

| Tab | What it changes |
|---|---|
| Tiles | Paint the room's 40 × 22 map with its 8×8 tiles, edit tile pixels, and change the room's four colours |
| Objects | Start position, room and active flag of the 58 objects (for a new game) |
| Collision | The rectangles the game tests Zorro and the objects against: move, resize, or type exact values |
| Exits | Where each exit is and which room and position it leads to |
| Sprites | Pixels of the 107 sprites the game uses |

Undo and redo cover every change (Ctrl+Z, Ctrl+Y).

## Limits

The editor only changes bytes that already exist. It never moves data or
makes the file bigger, so:

- each room's map is packed again (run-length) after every stroke, and a
  stroke that would no longer fit in the room's space in the file is
  refused. The meter under the room shows how full the map is;
- sprites keep their size, rooms keep their number of rectangles and exits,
  and tile sets keep their number of tiles;
- several rooms share data: rooms 13-19 share two maps and one tile set,
  most town rooms share a palette, and some rectangle tables overlap. The
  editor says so where it matters, because changing one changes all of them.

Some objects (platforms, the soldier, money bags) are placed by the game
when a room loads, so moving their start position has no effect. The
meaning of each collision rectangle type is not fully known. Colours are an
approximation of the NTSC palette.
