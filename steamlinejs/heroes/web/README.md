# Heroes of Lowrez — portable hex-battle prototype

This is a deliberately small web prototype for a future Atari XL/XE + VBXE
implementation. Open `index.html` in a browser or serve this directory with any
static web server.

Run the portable rules smoke test with:

```sh
node test-engine.js
```

## Rules

- The board is a fixed 7×6 odd-row-offset hex grid.
- Yellow units are heroes; red units are enemies.
- Heroes activate in a fixed order and are selected automatically.
- Every hero may move through up to two open hexes in any direction.
- A range-2 hero may move two hexes at once, which ends that hero's turn, or
  move one hex and take one final action: another one-hex move, an attack, or
  Skip. After the first step, remaining adjacent destinations use a stronger
  dark highlight.
- A hero may also attack without moving, or skip before or after movement.
- After the final hero acts, the enemy phase runs automatically.
- The knight attacks adjacent enemies. The archer has range 3.
- Trees block movement.
- **Skip hero** passes the current hero without moving or attacking.
- Enemies take a deterministic move or attack during their phase.
- **1 / 2** selects the previous or next battle (wrapping at the ends).

## Battles and enemies

The prototype contains four table-driven encounters. Enemy identities found in
the original compiled bundle include minibeast, skeleton, ogre, bat, warlock,
and imp. Minibeasts, bats, imps, and shield-bearing skeleton warriors use
melee attacks; ogres are slow, durable heavy hitters. Only bow-bearing skeleton
archers and the warlock have range 3. In the final battle the warlock summons
one imp at the start of every enemy phase.
Exact original stat values were not recoverable, so the byte-sized HP, damage,
range, and movement values are conservative approximations.
- Defeat all enemies to win.

## Porting model

`engine.js` contains all gameplay rules and has no browser dependencies. It uses:

- integer cell and unit IDs;
- fixed-size `Uint8Array`/`Int8Array` state;
- numeric enums instead of strings in the state;
- bounded loops and deterministic enemy decisions;
- no classes, recursion, allocation during a turn, timers, or floating point.

For a 6502/VBXE port, each typed array can become a byte array and each exported
engine function can become a subroutine. The board fits in 42 bytes and the seven
unit fields fit in 56 bytes with the current eight-unit cap.

`app.js` is the replaceable platform layer. It translates pointer/keyboard input
to cell IDs and draws a 320×200 indexed-palette-style screen. In an Atari port,
replace this file with joystick/console-key input and VBXE blitter routines while
keeping the same state layout and action rules.

The renderer uses four numeric visual states: idle, walk, melee attack, and
ranged attack. Walk uses eight small position steps with a one-pixel footfall;
melee uses a short lunge/slash; ranged attacks move a small arrow sprite; hits
flash and defeated units disappear at the end of the action. Input is locked
while the engine's fixed-size event queue plays player and enemy actions in
order, then the already-selected next hero receives control. These states do
not alter combat results and can become frame-counter-driven VBXE blitter
sequences later.

`assets/heroes-sprites-8bit.png` is the 192×64, 13-colour runtime sprite sheet
derived from the supplied original-game screenshots. It contains six 32×64
frames: knight, archer, demon, skeleton, conifer, and dead tree. The larger
transparent and chroma-key source sheets are retained alongside it.

`assets/terrain-8bit.png` contains 32×32 grass and dirt tiles based on the two
original battle backgrounds. Reachable and hovered hexes are rendered as
separate dark passes over this texture, based on `../image.png`: reachable
ground is visibly darker, and mouse hover adds a second, stronger dark pass
even when a unit or tree occupies the cell. No bright ring or persistent grid
is drawn. `assets/selection-8bit.png` is retained as an unused exploration
asset.

## Original-game findings

Published information and developer comments establish that the original is a
mouse-controlled, hex-based turn strategy with this wider loop:

- earn gold, recruit and upgrade a team, fight for larger rewards, then face the
  warlock;
- progress is saved before battles, so losing a battle is recoverable;
- troop losses are expected and should be offset by the battle reward;
- trees are placed randomly and block tactical options;
- Space skips the current battle turn;
- the opening encounter is an intentionally unwinnable prelude;
- the final warlock summons one imp every turn.

The original author also confirmed that automatic skipping for a completely
blocked unit was planned but was not implemented in the jam version.

Suggested Atari mapping:

- joystick: move board cursor;
- fire: select/confirm;
- SELECT: skip active hero;
- OPTION: restart battle.
