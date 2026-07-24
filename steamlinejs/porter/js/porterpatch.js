const { MAP_HEX_TOP, MAP_HEX_SHARED, FLAG_HEX } = window.PORTERPATCH_DATA;

const canvas = document.getElementById('game');
const ctx = canvas.getContext('2d');
const spritesheet = document.getElementById('spritesheet');
ctx.imageSmoothingEnabled = false;

const SCALE = 2;
const TILE = 8;
const ROOM_TILES = 16;
const ROOM_PX = ROOM_TILES * TILE;
const GRAVITY = 0.6;
const FRICTION = 0.5;
const JUMP = 3.7;
const FLAG = { SOLID: 0, HAZARD: 2, BLOCK: 3, NO_TELE: 4 };
const SPR = {
  PLAYER_IDLE: 1, PLAYER_RUN_START: 3, PLAYER_RUN_END: 6, PLAYER_JUMP: 7,
  PLAYER_FALL: 8, PLAYER_TRANSITION: 9, TELE_MARKER: 16, TELE_BLOCKED: 17,
  TELE_ARROW_H: 33, COIN: 48, TELE_ARROW_V: 49, SWITCH: 69, SWITCH_DOWN: 70,
  ROCK: 74, FEATHER: 75, KEY: 85, KEY_USED: 86, PLATFORM: 89,
};

const LEVELS = [
  { start: [4, 8], coin: [13, 7], next: [19, 9] },
  { start: [19, 9], coin: [27, 10], next: [35, 10] },
  { start: [35, 10], coin: [44, 6], next: [51, 3] },
  { start: [51, 3], coin: [53, 11], next: [72, 13] },
  { start: [72, 13], coin: [74, 3], next: [83, 6] },
  { start: [83, 6], coin: [93, 3], next: [99, 11] },
  { start: [99, 11], coin: [98, 2], next: [115, 10] },
  { start: [115, 10], coin: [124, 1], next: [5, 19] },
  { start: [5, 19], coin: [14, 22], next: [19, 26] },
  { start: [19, 26], coin: [30, 25], next: [36, 21] },
  { start: [36, 21], coin: [38, 28], next: [49, 28] },
  { start: [49, 28], coin: [62, 19], next: [66, 25] },
  { start: [66, 25], coin: [66, 30], next: [82, 24] },
  { start: [82, 24], coin: [82, 29], next: [99, 19] },
  { start: [99, 19], coin: [109, 18], next: [114, 26] },
  { start: [114, 26], coin: [125, 24], next: [3, 43] },
  { start: [3, 43], coin: [3, 33], next: [18, 45] },
  { start: [18, 45], coin: [19, 34], next: [33, 43] },
  { start: [33, 43], coin: [33, 33], next: [50, 44] },
  { start: [50, 44], coin: [54, 33], next: [67, 43] },
  { start: [67, 43], coin: [67, 35], next: [81, 35] },
  { start: [81, 35], coin: [81, 42], next: [99, 44] },
  { start: [99, 44], coin: [98, 38], next: [115, 44] },
  { start: [115, 44], coin: [114, 33], next: [5, 54] },
  { start: [5, 54], coin: [5, 58], next: [18, 56] },
  { start: [18, 56], coin: [29, 53], next: [35, 56] },
  { start: [35, 56], coin: [35, 61], next: [51, 52] },
  { start: [51, 52], coin: [50, 55], next: [83, 61] },
  { start: [83, 61], coin: null, next: null },
];

const ui = {
  stats: document.getElementById('stats'),
  level: document.getElementById('level'),
  time: document.getElementById('time'),
  deaths: document.getElementById('deaths'),
  teleports: document.getElementById('teleports'),
  startButton: document.getElementById('start-btn'),
};

const keyMap = {
  ArrowLeft: 'left', KeyA: 'left', ArrowRight: 'right', KeyD: 'right',
  ArrowUp: 'up', KeyW: 'up', ArrowDown: 'down', KeyS: 'down',
  KeyZ: 'jump', KeyC: 'jump', Space: 'teleport', KeyX: 'teleport', Enter: 'teleport',
};
const rawKeys = { left: false, right: false, up: false, down: false, jump: false, teleport: false };
const input = {
  down: { left: false, right: false, up: false, down: false, jump: false, teleport: false },
  pressed: { left: false, right: false, up: false, down: false, jump: false, teleport: false },
};

function clearInput() {
  for (const key of Object.keys(rawKeys)) {
    rawKeys[key] = false;
    input.down[key] = false;
    input.pressed[key] = false;
  }
}

const state = {
  mode: 'start',
  spritesLoaded: spritesheet.complete && spritesheet.naturalWidth > 0,
  levelIndex: 0,
  timerFrames: 0,
  deaths: 0,
  teleports: 0,
  frame: 0,
  room: null,
  particles: [],
};

const player = {
  x: 0, y: 0, w: 8, h: 8, spawnX: 0, spawnY: 0,
  dx: 0, dy: 0, maxDx: 1.5, maxDy: 3, acc: 0.6,
  flip: false, running: false, onGround: false, canTeleport: false,
  initJumping: false, sprite: SPR.PLAYER_IDLE, runFrame: SPR.PLAYER_RUN_START,
  runAnim: 0, coyoteFrames: 0, jumpBufferFrames: 0, idleBlink: 0,
  transitionFrames: 0,
};

spritesheet.addEventListener('load', () => { state.spritesLoaded = true; });
spritesheet.addEventListener('error', () => console.error('Failed to load spritesheet:', spritesheet.currentSrc || spritesheet.src));

document.addEventListener('keydown', (event) => {
  const action = keyMap[event.code];
  if (!action) return;
  rawKeys[action] = true;
  event.preventDefault();
  if (state.mode === 'start' && (action === 'jump' || action === 'teleport')) startGame();
  if (state.mode === 'ending' && action === 'teleport') resetToTitle();
});

document.addEventListener('keyup', (event) => {
  const action = keyMap[event.code];
  if (!action) return;
  rawKeys[action] = false;
  event.preventDefault();
});

ui.startButton.addEventListener('click', startGame);

function startGame() {
  clearInput();
  state.mode = 'playing';
  state.levelIndex = 0;
  state.timerFrames = 0;
  state.deaths = 0;
  state.teleports = 0;
  state.particles.length = 0;
  loadLevel(0);
  ui.startButton.style.display = 'none';
  ui.stats.style.display = 'block';
  syncUi();
}

function resetToTitle() {
  clearInput();
  state.mode = 'start';
  state.levelIndex = 0;
  state.room = null;
  state.particles.length = 0;
  ui.startButton.style.display = 'block';
  ui.stats.style.display = 'none';
}

function syncUi() {
  ui.level.textContent = String(state.levelIndex + 1);
  ui.deaths.textContent = String(state.deaths);
  ui.teleports.textContent = String(state.teleports);
  const totalSeconds = Math.floor(state.timerFrames / 60);
  const minutes = Math.floor(totalSeconds / 60);
  const seconds = String(totalSeconds % 60).padStart(2, '0');
  ui.time.textContent = `${minutes}:${seconds}`;
}

function parseByteRows(rows) {
  return rows.map((row) => {
    const bytes = [];
    for (let i = 0; i < row.length; i += 2) bytes.push(parseInt(row.slice(i, i + 2), 16));
    return bytes;
  });
}

function buildFullMap() {
  const top = parseByteRows(MAP_HEX_TOP);
  const shared = [];
  for (let row = 0; row < MAP_HEX_SHARED.length; row += 2) {
    const out = [];
    for (const line of [MAP_HEX_SHARED[row], MAP_HEX_SHARED[row + 1]]) {
      for (let i = 0; i < line.length; i += 2) {
        const pair = line[i + 1] + line[i];
        out.push(parseInt(pair, 16));
      }
    }
    shared.push(out);
  }
  return [...top, ...shared];
}

const FULL_MAP = buildFullMap();
const TILE_FLAGS = Array.from({ length: FLAG_HEX.length / 2 }, (_, index) => parseInt(FLAG_HEX.slice(index * 2, index * 2 + 2), 16));

function hasFlag(tile, flag) {
  return ((TILE_FLAGS[tile] || 0) & (1 << flag)) !== 0;
}

function mod(value, divisor) {
  return ((value % divisor) + divisor) % divisor;
}

function localPx(originTile, tile, pixelOffset = 0) {
  return tile * TILE - originTile * TILE + pixelOffset;
}

function levelStartPx(levelIndex, room) {
  const [startTileX, startTileY] = LEVELS[levelIndex].start;
  if (levelIndex === 0) {
    return {
      x: localPx(room.originX, startTileX, -4),
      y: localPx(room.originY, startTileY, -12),
    };
  }
  return {
    x: localPx(room.originX, startTileX, 0),
    y: localPx(room.originY, startTileY, -8),
  };
}

function sliceRoom(originX, originY) {
  return Array.from({ length: ROOM_TILES }, (_, y) => FULL_MAP[originY + y].slice(originX, originX + ROOM_TILES));
}

function createRoom(levelIndex) {
  const level = LEVELS[levelIndex];
  const [startTileX, startTileY] = level.start;
  const originX = Math.floor(startTileX / ROOM_TILES) * ROOM_TILES;
  const originY = Math.floor(startTileY / ROOM_TILES) * ROOM_TILES;
  const tiles = sliceRoom(originX, originY);
  const room = {
    originX, originY, tiles,
    switches: [], rocks: [], feathers: [], keys: [], platforms: [],
    coin: level.coin ? { x: localPx(originX, level.coin[0]), y: localPx(originY, level.coin[1]), w: 8, h: 8, collected: false } : null,
    clock: null,
    switchState: 'red',
    greenBlocksActive: true,
    endBounds: levelIndex === LEVELS.length - 1
      ? { x1: localPx(originX, 87), x2: localPx(originX, 90), y1: localPx(originY, 58), y2: localPx(originY, 61) }
      : null,
  };

  for (let y = 0; y < ROOM_TILES; y++) {
    for (let x = 0; x < ROOM_TILES; x++) {
      const tile = tiles[y][x];
      const px = x * TILE;
      const py = y * TILE;
      if (tile === SPR.SWITCH) {
        room.switches.push({ x: px, y: py, w: 8, h: 8, sprite: SPR.SWITCH, pressed: false });
        tiles[y][x] = 0;
      } else if (tile === SPR.ROCK) {
        room.rocks.push({ x: px, y: py, startX: px, startY: py, w: 8, h: 8, dy: 0, landed: true });
        tiles[y][x] = 0;
      } else if (tile === SPR.FEATHER) {
        room.feathers.push({ x: px, y: py, startX: px, startY: py, w: 8, h: 10, dy: 0 });
        tiles[y][x] = 0;
      } else if (tile === SPR.KEY) {
        room.keys.push({ x: px, y: py, w: 8, h: 8, sprite: SPR.KEY, collected: false });
        tiles[y][x] = 0;
      } else if (tile === SPR.PLATFORM) {
        room.platforms.push({ x: px, y: py, w: 8, h: 8, sprite: SPR.PLATFORM, collide: true, crumbleTimer: 0 });
        tiles[y][x] = 0;
      } else if (tile === 119) {
        room.clock = { x, y, sprite: 119, timer: 0 };
      }
    }
  }

  return room;
}

function loadLevel(levelIndex) {
  state.levelIndex = levelIndex;
  state.room = createRoom(levelIndex);
  state.particles.length = 0;

  const start = levelStartPx(levelIndex, state.room);
  player.x = start.x;
  player.y = start.y;
  player.spawnX = player.x;
  player.spawnY = player.y;
  player.dx = 0;
  player.dy = 0;
  player.flip = false;
  player.running = false;
  player.onGround = false;
  player.canTeleport = false;
  player.initJumping = false;
  player.sprite = SPR.PLAYER_IDLE;
  player.runFrame = SPR.PLAYER_RUN_START;
  player.runAnim = 0;
  player.idleBlink = 0;
  player.coyoteFrames = 0;
  player.jumpBufferFrames = 0;
  player.transitionFrames = 0;
  syncUi();
}

function sampleTile(tx, ty) {
  if (!state.room || tx < 0 || ty < 0 || tx >= ROOM_TILES || ty >= ROOM_TILES) return 0;
  return state.room.tiles[ty][tx];
}

function collideMap(obj, aim, flag) {
  let x1 = 0, y1 = 0, x2 = 0, y2 = 0;
  const { x, y, w, h } = obj;
  if (aim === 'left') { x1 = x; y1 = y + 3; x2 = x + 2; y2 = y + h - 1; }
  else if (aim === 'up_right') { x1 = x + w - 3; y1 = y + 3; x2 = x + w - 1; y2 = y + 3; }
  else if (aim === 'right') { x1 = x + w - 3; y1 = y + 3; x2 = x + w - 1; y2 = y + h - 1; }
  else if (aim === 'up') { x1 = x + 2; y1 = y + 1; x2 = x + w - 2; y2 = y + 2; }
  else if (aim === 'tall_up') { x1 = x + 2; y1 = y - 1; x2 = x + w - 2; y2 = y + 2; }
  else if (aim === 'down') { x1 = x + 2; y1 = y + h; x2 = x + 6; y2 = y + h; }
  else if (aim === 'inside') { x1 = x + w - 4; y1 = y + h - 5; x2 = x + w - 4; y2 = y + h - 5; }
  else if (aim === 'block') { x1 = x + 3; y1 = y + h - 4; x2 = x + w - 3; y2 = y + h - 4; }
  const points = [
    [Math.floor(x1 / TILE), Math.floor(y1 / TILE)],
    [Math.floor(x1 / TILE), Math.floor(y2 / TILE)],
    [Math.floor(x2 / TILE), Math.floor(y1 / TILE)],
    [Math.floor(x2 / TILE), Math.floor(y2 / TILE)],
  ];
  return points.some(([tx, ty]) => hasFlag(sampleTile(tx, ty), flag));
}

function intersect(a1, a2, b1, b2) {
  return Math.max(a1, a2) > Math.min(b1, b2) && Math.min(a1, a2) < Math.max(b1, b2);
}

function sprCollide(a, b) {
  return intersect(a.x + 2, a.x + 6, b.x + 2, b.x + 6) && intersect(a.y + 2, a.y + 6, b.y + 2, b.y + 6);
}

function collideSprite(obj, aim, obj2) {
  let x1 = 0, y1 = 0, x2 = 0, y2 = 0;
  const { x, y, w, h } = obj;
  if (aim === 'left') { x1 = x; y1 = y + 2; x2 = x + 2; y2 = y + 7; }
  else if (aim === 'right') { x1 = x + 5; y1 = y + 2; x2 = x + 7; y2 = y + 7; }
  else if (aim === 'up') { x1 = x + 2; y1 = y; x2 = x + 5; y2 = y + 1; }
  else if (aim === 'tall_up') { x1 = x + 2; y1 = y - 1; x2 = x + 7; y2 = y + 1; }
  else if (aim === 'down') { x1 = x + 2; y1 = y + h; x2 = x + 6; y2 = y + h; }
  else if (aim === 'feather_up') { x1 = x; y1 = y + 1; x2 = x + w; y2 = y + 2; }
  else if (aim === 'feather_down') { x1 = x; y1 = y + 6; x2 = x + w; y2 = y + 6; }
  else if (aim === 'switch') { x1 = x + 1; y1 = y + 6; x2 = x + 7; y2 = y + 8; }
  else if (aim === 'inside') { x1 = x + 2; y1 = y + 4; x2 = x + 6; y2 = y + 4; }
  else if (aim === 'plat_up') { x1 = x + 2; y1 = y + 5; x2 = x + 5; y2 = y + 6; }
  else if (aim === 'plat_down') { x1 = x + 2; y1 = y + 10; x2 = x + 6; y2 = y + 10; }
  return intersect(x1, x2, obj2.x + 2, obj2.x + 7) && intersect(y1, y2, obj2.y + 1, obj2.y + 8);
}

function addParticle(x, y, dx, dy, life, size, color = '#fff') {
  state.particles.push({ x, y, dx, dy, life, maxLife: life, size, color });
}

function burst(x, y, count, color = '#fff') {
  for (let i = 0; i < count; i++) addParticle(x, y, Math.random() * 2 - 1, Math.random() * 2 - 1, 10 + Math.random() * 8, 1 + Math.random() * 3, color);
}

function updateParticles() {
  for (let i = state.particles.length - 1; i >= 0; i--) {
    const p = state.particles[i];
    p.x += p.dx;
    p.y += p.dy;
    p.dy += 0.08;
    p.size *= 0.95;
    p.life -= 1;
    if (p.life <= 0 || p.size <= 0.2) state.particles.splice(i, 1);
  }
}

function toggleSwitchTiles() {
  for (let y = 0; y < ROOM_TILES; y++) {
    for (let x = 0; x < ROOM_TILES; x++) {
      const tile = state.room.tiles[y][x];
      if (state.room.switchState === 'red') {
        if (tile === 88) state.room.tiles[y][x] = 87;
        if (tile === 71) state.room.tiles[y][x] = 72;
      } else {
        if (tile === 87) state.room.tiles[y][x] = 88;
        if (tile === 72) state.room.tiles[y][x] = 71;
      }
    }
  }
  state.room.switchState = state.room.switchState === 'red' ? 'blue' : 'red';
}

function setGreenBlocks(active) {
  state.room.greenBlocksActive = active;
  for (let y = 0; y < ROOM_TILES; y++) {
    for (let x = 0; x < ROOM_TILES; x++) {
      if (!active && state.room.tiles[y][x] === 104) state.room.tiles[y][x] = 103;
      if (active && state.room.tiles[y][x] === 103) state.room.tiles[y][x] = 104;
    }
  }
}

function updateClock() {
  if (!state.room.clock) return;
  state.room.clock.timer += 1;
  if (state.room.clock.timer < 16) return;
  state.room.clock.timer = 0;
  state.room.clock.sprite += 1;
  if (state.room.clock.sprite > 126) state.room.clock.sprite = 119;
  state.room.tiles[state.room.clock.y][state.room.clock.x] = state.room.clock.sprite;
  if (state.room.clock.sprite === 119 || state.room.clock.sprite === 123) toggleSwitchTiles();
}

function updateObjects() {
  for (const s of state.room.switches) {
    const touching = collideSprite(s, 'switch', player);
    s.sprite = touching ? SPR.SWITCH_DOWN : SPR.SWITCH;
    if (touching && !s.pressed) {
      toggleSwitchTiles();
      burst(s.x + 4, s.y + 6, 6, '#ff6666');
    }
    s.pressed = touching;
  }

  for (const r of state.room.rocks) {
    r.dy += GRAVITY;
    if (collideMap(r, 'down', FLAG.SOLID)) {
      if (!r.landed) burst(r.x + 4, r.y + 8, 6, '#ddd');
      r.dy = 0;
      r.landed = true;
      r.y -= mod(r.y + r.h + 1, TILE) - 1;
    } else {
      r.landed = false;
    }
    if (r.dy > 4) r.dy = 4;
    r.y += r.dy;
  }

  for (const f of state.room.feathers) {
    f.dy -= GRAVITY;
    if (collideMap(f, 'up', FLAG.SOLID)) f.dy = 0;
    if (f.dy < -1) f.dy = -1;
    f.y += f.dy;
    if (collideSprite(f, 'feather_up', player) && !collideMap(player, 'up', FLAG.SOLID) && !player.initJumping) player.dy += f.dy;
    if (state.frame % 6 === 0) addParticle(f.x + 1 + Math.random() * 6, f.y + 4, 0, Math.random() + Math.min(f.dy, 0), 8, 1.6, '#ffffff');
  }

  for (const p of state.room.platforms) {
    if (!p.collide) continue;
    if (collideSprite(p, 'tall_up', player)) {
      p.crumbleTimer += 1;
      if (p.crumbleTimer >= 9 && p.sprite < 92) {
        p.crumbleTimer = 0;
        p.sprite += 1;
        addParticle(p.x + 1 + Math.random() * 6, p.y + 4, 0, Math.random(), 12, 2, '#ffcf7d');
        if (p.sprite >= 92) p.collide = false;
      }
    } else {
      p.crumbleTimer = 0;
    }
  }

  for (const k of state.room.keys) {
    if (!k.collected && sprCollide(k, player)) {
      k.collected = true;
      k.sprite = SPR.KEY_USED;
      setGreenBlocks(false);
      burst(k.x + 4, k.y + 4, 10, '#8dff7a');
    }
  }
}

function computeTeleportPreview() {
  const preview = { x: player.x, y: player.y, w: 8, h: 8, xAdj: 0, yAdj: 0, arrow: SPR.TELE_ARROW_H };
  if (input.down.up) {
    preview.y -= 32;
    preview.yAdj = -32;
    preview.arrow = SPR.TELE_ARROW_V;
  } else if (input.down.down) {
    preview.y += 32;
    preview.yAdj = 32;
    preview.arrow = SPR.TELE_ARROW_V;
  } else if (player.flip) {
    preview.x -= 32;
    preview.xAdj = -32;
  } else {
    preview.x += 32;
    preview.xAdj = 32;
  }
  return preview;
}

function attemptTeleport() {
  if (!input.pressed.teleport || !player.canTeleport || collideMap(player, 'inside', FLAG.NO_TELE)) return;
  const preview = computeTeleportPreview();
  if (collideMap(preview, 'right', FLAG.SOLID)) {
    const offset = mod(preview.x, TILE);
    if (offset === 2) preview.xAdj -= 1;
    else if (offset === 3) preview.xAdj -= 2;
    else if (offset === 4) preview.xAdj -= 3;
  }
  if (collideMap(preview, 'left', FLAG.SOLID)) {
    const offset = mod(preview.x, TILE);
    if (offset === 4) preview.xAdj += 3;
    else if (offset === 5) preview.xAdj += 2;
    else if (offset === 6) preview.xAdj += 1;
  }
  if (collideMap(preview, 'down', FLAG.SOLID)) {
    const offset = mod(preview.y, TILE);
    if (offset === 3) preview.yAdj -= 1;
    else if (offset === 4) preview.yAdj -= 2;
  }
  if (collideMap(preview, 'up', FLAG.SOLID) && mod(preview.y, TILE) === 4) preview.yAdj += 1;
  burst(player.x + 4, player.y + 4, 8, '#d5b4ff');
  player.x += preview.xAdj;
  player.y += preview.yAdj;
  burst(player.x + 4, player.y + 4, 6, '#d5b4ff');
  state.teleports += 1;
  syncUi();
}

function respawn() {
  state.deaths += 1;
  syncUi();
  burst(player.x + 4, player.y + 4, 16, '#ff9d6e');
  loadLevel(state.levelIndex);
}

function updatePlayer() {
  if (player.transitionFrames > 0) {
    player.transitionFrames -= 1;
    player.sprite = SPR.PLAYER_TRANSITION;
    if (player.transitionFrames === 0 && state.levelIndex + 1 < LEVELS.length) loadLevel(state.levelIndex + 1);
    return;
  }

  const wasGrounded = player.onGround;
  attemptTeleport();

  player.dy += GRAVITY;
  player.dx *= FRICTION;
  player.running = false;

  if (input.down.left) {
    player.dx -= player.acc;
    player.running = true;
    player.flip = true;
  }
  if (input.down.right) {
    player.dx += player.acc;
    player.running = true;
    player.flip = false;
  }

  if (!player.onGround) player.coyoteFrames += 1;
  else player.coyoteFrames = 0;
  if (input.pressed.jump && !player.onGround) player.jumpBufferFrames = 6;
  else if (player.jumpBufferFrames > 0) player.jumpBufferFrames -= 1;

  if ((input.pressed.jump && player.onGround) || (input.pressed.jump && player.coyoteFrames < 3) || (player.jumpBufferFrames > 0 && player.onGround)) {
    player.initJumping = true;
    player.dy = 0.3 - JUMP;
    player.onGround = false;
    player.jumpBufferFrames = 0;
    burst(player.x + 4, player.y + 8, 6, '#f4f4f4');
  }
  if (player.dy > 0) player.initJumping = false;

  const rockLeft = state.room.rocks.some((r) => collideSprite(player, 'left', r));
  const rockRight = state.room.rocks.some((r) => collideSprite(player, 'right', r));
  const rockDown = state.room.rocks.some((r) => collideSprite(player, 'down', r));
  const rockUp = state.room.rocks.some((r) => collideSprite(player, 'up', r));
  const insideRock = state.room.rocks.some((r) => collideSprite(player, 'inside', r));
  const platLeft = state.room.platforms.some((p) => p.collide && collideSprite(player, 'left', p));
  const platRight = state.room.platforms.some((p) => p.collide && collideSprite(player, 'right', p));
  const platDown = state.room.platforms.some((p) => p.collide && collideSprite(player, 'plat_down', p));
  const platUp = state.room.platforms.some((p) => p.collide && collideSprite(player, 'plat_up', p));
  const featherDown = state.room.feathers.some((f) => collideSprite(player, 'feather_down', f));

  const wallFix = collideMap(player, 'up_right', FLAG.SOLID) && mod(player.x, TILE) === 2;

  if (player.dy > 0) {
    player.onGround = false;
    player.dy = Math.min(player.dy, player.maxDy);
    if (collideMap(player, 'down', FLAG.SOLID) || rockDown || platDown || featherDown) {
      if (!featherDown && !wallFix) {
        player.onGround = true;
        player.dy = 0;
        player.canTeleport = true;
      }
      if (featherDown) {
        player.onGround = false;
        if (!collideMap(player, 'tall_up', FLAG.SOLID)) player.dy = 0;
      }
      if (!featherDown) {
        if (!rockDown) {
          if (!collideMap(player, 'up', FLAG.SOLID)) player.y -= mod(player.y + player.h + 1, TILE) - 1;
        } else {
          player.y -= mod(player.y + player.h + 1, TILE) - 3;
        }
      }
    }
  } else if (player.dy < 0) {
    if (collideMap(player, 'up', FLAG.SOLID) || rockUp || platUp) {
      if (!wallFix) player.dy = 0;
    }
  }

  if (player.dx < 0) {
    player.dx = Math.max(player.dx, -player.maxDx);
    if (collideMap(player, 'left', FLAG.SOLID) || rockLeft || platLeft) {
      player.dx = 0;
      if (!rockLeft && mod(player.x + player.w + 1, TILE) > 4) player.x += mod(player.x + player.w, TILE) - 6;
    }
  } else if (player.dx > 0) {
    player.dx = Math.min(player.dx, player.maxDx);
    if (collideMap(player, 'right', FLAG.SOLID) || rockRight || platRight) {
      player.dx = 0;
      if (!rockRight) player.x -= mod(player.x + player.w + 1, TILE) - 2;
    }
  }

  player.x += player.dx;
  player.y += player.dy;
  if (player.dx > -0.5 && player.dx < 0.5) player.dx = 0;

  if (!wasGrounded && player.onGround) burst(player.x + 4, player.y + 8, 5, '#f0f0f0');

  if (collideMap(player, 'inside', FLAG.HAZARD) || collideMap(player, 'block', FLAG.BLOCK) || rockUp || insideRock || player.x < 0 || player.x > ROOM_PX || player.y < 0 || player.y > ROOM_PX) {
    respawn();
    return;
  }

  if (state.room.coin && !state.room.coin.collected && sprCollide(state.room.coin, player)) {
    state.room.coin.collected = true;
    burst(state.room.coin.x + 4, state.room.coin.y + 4, 12, '#ffd85b');
    player.transitionFrames = 24;
  }

  if (state.room.endBounds) {
    const b = state.room.endBounds;
    const inZone = player.x > b.x1 && player.x < b.x2 && player.y > b.y1 && player.y < b.y2;
    if (inZone && input.pressed.teleport) state.mode = 'ending';
  }

  animatePlayer();
}

function animatePlayer() {
  if (player.transitionFrames > 0) {
    player.sprite = SPR.PLAYER_TRANSITION;
    return;
  }
  if (player.dy < -0.1) {
    player.sprite = SPR.PLAYER_JUMP;
    return;
  }
  if (!player.onGround && player.dy > 0.5) {
    player.sprite = SPR.PLAYER_FALL;
    return;
  }
  if (player.running) {
    player.runAnim += 1;
    if (player.runAnim >= 6) {
      player.runAnim = 0;
      player.runFrame += 1;
      if (player.runFrame > SPR.PLAYER_RUN_END) player.runFrame = SPR.PLAYER_RUN_START;
    }
    player.sprite = player.runFrame;
    return;
  }
  player.idleBlink += 1;
  player.sprite = player.idleBlink > 360 && player.idleBlink % 45 < 4 ? 32 : SPR.PLAYER_IDLE;
  if (player.idleBlink > 420) player.idleBlink = 0;
}

function advanceInput() {
  for (const key of Object.keys(input.down)) {
    input.pressed[key] = rawKeys[key] && !input.down[key];
    input.down[key] = rawKeys[key];
  }
}

function update() {
  advanceInput();
  if (state.mode === 'playing') {
    state.timerFrames += 1;
    updatePlayer();
    if (state.mode === 'playing') {
      updateObjects();
      updateClock();
      updateParticles();
    }
    syncUi();
  } else {
    updateParticles();
  }
  state.frame += 1;
}

function drawSprite(sprite, x, y, flip = false, scaleX = 1, scaleY = 1, alpha = 1) {
  if (!state.spritesLoaded) return;
  const sx = (sprite % 16) * 8;
  const sy = Math.floor(sprite / 16) * 8;
  ctx.save();
  ctx.globalAlpha = alpha;
  ctx.scale(SCALE, SCALE);
  if (flip) {
    ctx.translate(x + 8 * scaleX, y);
    ctx.scale(-1, 1);
    ctx.drawImage(spritesheet, sx, sy, 8 * scaleX, 8 * scaleY, 0, 0, 8 * scaleX, 8 * scaleY);
  } else {
    ctx.drawImage(spritesheet, sx, sy, 8 * scaleX, 8 * scaleY, x, y, 8 * scaleX, 8 * scaleY);
  }
  ctx.restore();
}

function drawParticles() {
  ctx.save();
  ctx.scale(SCALE, SCALE);
  for (const p of state.particles) {
    ctx.globalAlpha = Math.max(0, p.life / p.maxLife);
    ctx.fillStyle = p.color;
    ctx.fillRect(p.x, p.y, p.size, p.size);
  }
  ctx.restore();
  ctx.globalAlpha = 1;
}

function drawRoom() {
  if (!state.room) return;
  for (let y = 0; y < ROOM_TILES; y++) {
    for (let x = 0; x < ROOM_TILES; x++) {
      const tile = state.room.tiles[y][x];
      if (tile !== 0) drawSprite(tile, x * TILE, y * TILE);
    }
  }
  if (state.room.coin && !state.room.coin.collected) drawSprite(SPR.COIN, state.room.coin.x, state.room.coin.y);
  for (const s of state.room.switches) drawSprite(s.sprite, s.x, s.y);
  for (const r of state.room.rocks) drawSprite(SPR.ROCK, r.x, r.y);
  for (const f of state.room.feathers) drawSprite(SPR.FEATHER, f.x, f.y);
  for (const k of state.room.keys) drawSprite(k.sprite, k.x, k.y);
  for (const p of state.room.platforms) drawSprite(p.sprite, p.x, p.y);
}

function drawTeleportPreview() {
  if (state.mode !== 'playing' || !player.canTeleport || player.transitionFrames > 0) return;
  const preview = computeTeleportPreview();
  const blocked = collideMap(player, 'inside', FLAG.NO_TELE);
  drawSprite(
    preview.arrow,
    preview.x + (preview.arrow === SPR.TELE_ARROW_V ? 0 : (preview.xAdj > 0 ? -5 : 6)),
    preview.y + (preview.arrow === SPR.TELE_ARROW_V ? (preview.yAdj > 0 ? -6 : 5) : 0),
    false,
    1,
    1,
    0.72,
  );

  ctx.save();
  ctx.scale(SCALE, SCALE);
  ctx.globalAlpha = 0.85;
  ctx.lineWidth = 1;
  ctx.strokeStyle = blocked ? '#ff6b6b' : '#f4f4f4';
  ctx.strokeRect(preview.x + 0.5, preview.y + 0.5, 7, 7);
  if (blocked) {
    ctx.beginPath();
    ctx.moveTo(preview.x + 1, preview.y + 1);
    ctx.lineTo(preview.x + 7, preview.y + 7);
    ctx.moveTo(preview.x + 7, preview.y + 1);
    ctx.lineTo(preview.x + 1, preview.y + 7);
    ctx.stroke();
  }
  ctx.restore();
}

function drawOverlay() {
  ctx.fillStyle = 'rgba(0,0,0,0.75)';
  ctx.fillRect(0, 0, canvas.width, canvas.height);
  ctx.fillStyle = '#fff';
  ctx.font = 'bold 26px monospace';
  ctx.fillText('PORTER PATCH', 30, 70);
  ctx.font = '14px monospace';
  if (state.mode === 'start') {
    ctx.fillText('Arrows / WASD: move + aim teleport', 20, 120);
    ctx.fillText('Z / C / Up: jump', 56, 145);
    ctx.fillText('X / Space / Enter: teleport', 28, 170);
    ctx.fillText('Collect every coin to reach the office.', 24, 205);
  } else if (state.mode === 'ending') {
    ctx.fillText('Clocked in.', 92, 118);
    ctx.fillText(`Time: ${ui.time.textContent}`, 76, 146);
    ctx.fillText(`Teleports: ${state.teleports}`, 56, 168);
    ctx.fillText(`Deaths: ${state.deaths}`, 76, 190);
    ctx.fillText('Press Enter / X to return to title', 18, 225);
  }
}

function draw() {
  ctx.fillStyle = '#0b0f16';
  ctx.fillRect(0, 0, canvas.width, canvas.height);
  drawRoom();
  drawTeleportPreview();
  drawParticles();
  if (state.room) drawSprite(player.sprite, player.x, player.y, player.flip);

  if (state.room?.endBounds && state.mode === 'playing') {
    const b = state.room.endBounds;
    const inZone = player.x > b.x1 && player.x < b.x2 && player.y > b.y1 && player.y < b.y2;
    if (inZone) {
      ctx.fillStyle = 'rgba(0,0,0,0.7)';
      ctx.fillRect(16, 208, 224, 28);
      ctx.fillStyle = '#fff';
      ctx.font = '14px monospace';
      ctx.fillText('Press X / Enter to clock in', 34, 227);
    }
  }

  if (state.mode === 'start' || state.mode === 'ending') drawOverlay();
}

let lastTime = 0;
let accumulator = 0;
const STEP = 1000 / 60;

function loop(timestamp) {
  if (!lastTime) lastTime = timestamp;
  accumulator += Math.min(100, timestamp - lastTime);
  lastTime = timestamp;
  while (accumulator >= STEP) {
    update();
    accumulator -= STEP;
  }
  draw();
  requestAnimationFrame(loop);
}

syncUi();
requestAnimationFrame(loop);