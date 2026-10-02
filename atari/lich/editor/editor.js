'use strict';
/* Lich King Editor — edits the game description (game.json) of the Atari
 * VBXE port.  The default is the original cartridge; exporting it unchanged
 * rebuilds exactly the original game (tools/make_data.py).
 * Library carts (.p8) are parsed here: their monsters (stats, 4 animation
 * frames) and maps can be converted into the Lich King format. */

const PAL = [[0, 0, 0], [29, 43, 83], [126, 37, 83], [0, 135, 81], [171, 82, 54], [95, 87, 79],
  [194, 195, 199], [255, 241, 232], [255, 0, 77], [255, 163, 0], [255, 255, 39], [0, 231, 88],
  [41, 173, 255], [131, 118, 156], [255, 119, 168], [255, 204, 170]];
const PAL_CSS = PAL.map(c => `rgb(${c[0]},${c[1]},${c[2]})`);
const BUILTIN_ENTS = 25;
const T_WALL = 48;
const FLOOR_TILES = [1, 32, 33, 34, 36, 37, 38, 40, 41, 42];
const STORE_KEY = 'lich-editor-game';

let G = null;               // the game being edited
let tab = 'rules';
let animFrame = 0;
const animated = [];        // {canvas, draw(frame)}

// ------------------------------------------------------------------ helpers
function h(tag, attrs = {}, ...kids) {
  const e = document.createElement(tag);
  for (const [k, v] of Object.entries(attrs || {})) {
    if (k === 'class') e.className = v;
    else if (k === 'style') e.style.cssText = v;
    else if (k.startsWith('on')) e.addEventListener(k.slice(2), v);
    else if (v === true) e.setAttribute(k, '');
    else if (v !== false && v != null) e.setAttribute(k, v);
  }
  for (const k of kids.flat()) {
    if (k == null || k === false) continue;
    e.append(k instanceof Node ? k : document.createTextNode(String(k)));
  }
  return e;
}
const clone = o => JSON.parse(JSON.stringify(o));
function status(msg, bad) {
  const s = document.getElementById('status');
  s.textContent = msg;
  s.className = bad ? 'err' : '';
}
function save() {
  try { localStorage.setItem(STORE_KEY, JSON.stringify(G)); } catch (e) { /* storage may be unavailable */ }
}
function changed(msg) {
  save();
  if (msg) status(msg);
}
function numInput(obj, key, opts = {}) {
  const inp = h('input', { type: 'number', value: obj[key], step: opts.step || 1,
    min: opts.min, max: opts.max, style: opts.width ? `width:${opts.width}px` : null });
  inp.addEventListener('change', () => {
    let v = Number(inp.value);
    if (Number.isNaN(v)) return;
    if (opts.min != null) v = Math.max(opts.min, v);
    if (opts.max != null) v = Math.min(opts.max, v);
    if (!opts.float) v = Math.round(v);
    obj[key] = v;
    inp.value = v;
    changed();
    if (opts.after) opts.after(v);
  });
  return inp;
}
function textInput(obj, key, opts = {}) {
  const inp = h('input', { value: obj[key], class: opts.cls || 'wide' });
  const check = () => {
    const bad = opts.glyphs && !textOk(inp.value);
    inp.classList.toggle('bad', bad);
    inp.title = bad ? 'contains a character the game font cannot draw, or is too long' : '';
    return !bad;
  };
  inp.addEventListener('input', check);
  inp.addEventListener('change', () => { obj[key] = inp.value; changed(); if (opts.after) opts.after(); });
  check();
  return inp;
}
// glyph check, like make_data.enc: "^x" is a capital / symbol, else "c "
const GLYPH_SET = new Set(GLYPH_KEYS);
function glyphCount(s) {
  let n = 0;
  for (let i = 0; i < s.length; i++) {
    const key = s[i] === '^' ? s.slice(i, ++i + 1) : s[i] + ' ';
    if (!GLYPH_SET.has(key)) return -1;
    n++;
  }
  return n;
}
const textOk = s => { const n = glyphCount(s); return n >= 0 && n <= 46; };

// ------------------------------------------------------------------ sheets
const sheets = { 1: new Uint8Array(128 * 128), 2: new Uint8Array(128 * 64) };
let sprCache = new Map();
function loadSheets() {
  for (const [page, rows] of [[1, G.sheet], [2, G.sheet2]]) {
    const px = sheets[page];
    rows.forEach((r, y) => { for (let x = 0; x < 128; x++) px[y * 128 + x] = parseInt(r[x], 16); });
  }
  sprCache = new Map();
}
function setPixel(page, x, y, c) {
  sheets[page][y * 128 + x] = c;
  const rows = page === 1 ? G.sheet : G.sheet2;
  rows[y] = rows[y].slice(0, x) + c.toString(16) + rows[y].slice(x + 1);
  const n = (page === 1 ? 0 : 256) + (y >> 3) * 16 + (x >> 3);
  for (const k of [...sprCache.keys()]) if (k.startsWith(n + ':')) sprCache.delete(k);
}
// sprite n (0..383) as an 8x8 canvas; pal: optional colour map (16 entries)
function sprite(n, pal) {
  const key = n + ':' + (pal ? pal.join('') : '');
  let c = sprCache.get(key);
  if (c) return c;
  c = document.createElement('canvas');
  c.width = c.height = 8;
  const ctx = c.getContext('2d');
  const img = ctx.createImageData(8, 8);
  const page = n >= 256 ? 2 : 1;
  const m = n & 255;
  const px = sheets[page];
  const sx = (m % 16) * 8, sy = (m >> 4) * 8;
  if (sy < (page === 1 ? 128 : 64)) {
    for (let y = 0; y < 8; y++) for (let x = 0; x < 8; x++) {
      const v = px[(sy + y) * 128 + sx + x];
      if (!v) continue;
      const col = PAL[pal ? pal[v] : v];
      const o = (y * 8 + x) * 4;
      img.data[o] = col[0]; img.data[o + 1] = col[1]; img.data[o + 2] = col[2]; img.data[o + 3] = 255;
    }
  }
  ctx.putImageData(img, 0, 0);
  sprCache.set(key, c);
  return c;
}
function spriteBlank(n) {
  const page = n >= 256 ? 2 : 1, m = n & 255, px = sheets[page];
  const sx = (m % 16) * 8, sy = (m >> 4) * 8;
  if (sy >= (page === 1 ? 128 : 64)) return false;
  for (let y = 0; y < 8; y++) for (let x = 0; x < 8; x++) if (px[(sy + y) * 128 + sx + x]) return false;
  return true;
}
function spriteCanvas(n, scale = 3, pal) {
  const c = h('canvas', { class: 'px', width: 8 * scale, height: 8 * scale });
  const ctx = c.getContext('2d');
  ctx.imageSmoothingEnabled = false;
  ctx.drawImage(sprite(n, pal), 0, 0, 8 * scale, 8 * scale);
  return c;
}
// an animated preview of frames (array of sprite numbers)
function animCanvas(framesFn, scale = 3) {
  const c = h('canvas', { class: 'px', width: 8 * scale, height: 8 * scale });
  const ctx = c.getContext('2d');
  ctx.imageSmoothingEnabled = false;
  const draw = f => {
    const fr = framesFn();
    ctx.clearRect(0, 0, c.width, c.height);
    if (fr.length) ctx.drawImage(sprite(fr[f % fr.length]), 0, 0, 8 * scale, 8 * scale);
  };
  draw(0);
  animated.push({ canvas: c, draw });
  return c;
}
setInterval(() => {
  animFrame++;
  for (let i = animated.length - 1; i >= 0; i--) {
    if (!animated[i].canvas.isConnected) { animated.splice(i, 1); continue; }
    animated[i].draw(animFrame);
  }
}, 160);

// ------------------------------------------------------------------ game model
function entFrames(m) {
  if (m.prop) return [m.anim];
  return [0, 1, 2, 3].map(i => m.anim + i);
}
function codeToEntity() {
  const map = new Map();
  for (let i = G.monsters.length; i >= 1; i--) map.set(G.monsters[i - 1].code, i);
  return map;
}
function newGame(g) {
  G = g;
  for (const k of Object.keys(DEFAULT_GAME)) if (!(k in G)) G[k] = clone(DEFAULT_GAME[k]);
  for (const k of Object.keys(DEFAULT_GAME.params)) if (!(k in G.params)) G.params[k] = DEFAULT_GAME.params[k];
  loadSheets();
  document.getElementById('gamename').textContent = G.name || '';
  save();
}
// free page-1 cells usable as map codes for new monsters
function freeCodes() {
  const used = new Set(G.monsters.map(m => m.code));
  G.monsters.forEach(m => { if (m.anim < 256) for (const f of entFrames(m)) used.add(f); });
  [G.params.tile_start, G.params.tile_exit, 0].forEach(t => used.add(t));
  const out = [];
  for (let n = 1; n < 256; n++) if (!used.has(n) && spriteBlank(n)) out.push(n);
  return out;
}
// a free run of 4 cells on page 2 (sprite numbers 256..383)
function freePage2Slot() {
  const used = new Set();
  G.monsters.forEach(m => { if (m.anim >= 256) for (let i = 0; i < 4; i++) used.add(m.anim + i); });
  for (let n = 256; n <= 256 + 124; n += 4) {
    let ok = true;
    for (let i = 0; i < 4; i++) if (used.has(n + i) || !spriteBlank(n + i)) ok = false;
    if (ok) return n;
  }
  return -1;
}

// ------------------------------------------------------------------ .p8 parsing
function parseP8(name, text) {
  const sec = {};
  let cur = null;
  for (const line of text.split(/\r?\n/)) {
    const m = line.match(/^__(\w+)__$/);
    if (m) { cur = m[1]; sec[cur] = []; } else if (cur) sec[cur].push(line);
  }
  const gfx = new Uint8Array(128 * 128);
  (sec.gfx || []).slice(0, 128).forEach((r, y) => {
    for (let x = 0; x < 128 && x < r.length; x++) gfx[y * 128 + x] = parseInt(r[x], 16) || 0;
  });
  const flags = new Array(256).fill(0);
  (sec.gff || []).slice(0, 2).forEach((r, y) => {
    for (let i = 0; i < 128; i++) flags[y * 128 + i] = parseInt(r.slice(i * 2, i * 2 + 2), 16) || 0;
  });
  const map = new Uint8Array(128 * 32);
  (sec.map || []).slice(0, 32).forEach((r, y) => {
    for (let x = 0; x < 128; x++) map[y * 128 + x] = parseInt(r.slice(x * 2, x * 2 + 2), 16) || 0;
  });
  const cart = { name, gfx, flags, map, lua: sec.lua ? sec.lua.join('\n') : '' };
  cart.monsters = extractMonsters(cart);
  cart.overrides = defaultOverrides(cart);
  return cart;
}
function splitTop(s) {
  const out = [];
  let depth = 0, q = null, cur = '';
  for (let i = 0; i < s.length; i++) {
    const c = s[i];
    if (q) { cur += c; if (c === q && s[i - 1] !== '\\') q = null; continue; }
    if (c === '"' || c === "'") { q = c; cur += c; continue; }
    if ('({['.includes(c)) depth++;
    if (')}]'.includes(c)) depth--;
    if (c === ',' && depth === 0) { out.push(cur.trim()); cur = ''; continue; }
    cur += c;
  }
  if (cur.trim()) out.push(cur.trim());
  return out;
}
const strArg = e => { const m = e && e.match(/"([^"]*)"/); return m ? m[1] : null; };
const nums = s => s.split(',').map(v => Number(v.trim()) || 0);
function extractMonsters(cart) {
  const lua = cart.lua;
  const get = name => {
    // name=explode("...") / explodeval("...") on its own, or inside a multiple assignment
    const re = new RegExp(`(^|\\n)\\s*${name}\\s*=\\s*(explode(val)?)\\(?\\s*"([^"]*)"`);
    const m = lua.match(re);
    if (m) return { kind: m[2], s: m[4] };
    for (const line of lua.split('\n')) {
      const eq = line.indexOf('=');
      if (eq < 0) continue;
      const lhs = line.slice(0, eq);
      if (!/^[\s\w,]+$/.test(lhs) || !lhs.includes(',')) continue;
      const names = lhs.split(',').map(s => s.trim());
      const idx = names.indexOf(name);
      if (idx < 0) continue;
      const vals = splitTop(line.slice(eq + 1));
      const v = vals[idx];
      if (!v) return null;
      const kind = (v.match(/^(explode2d|explodeval|explode)/) || [])[1];
      return { kind, s: strArg(v) };
    }
    return null;
  };
  const out = [];
  const nameT = get('mob_name');
  const aniT = get('mob_ani');
  if (!aniT || aniT.s == null) return out;
  const hpT = get('mob_hp'), atkT = get('mob_atk'), losT = get('mob_los');
  const minfT = get('mob_minf'), specT = get('mob_spec'), typeT = get('mob_type'), planT = get('mob_plan');
  const brainT = get('mob_brain');
  const brains = brainT ? nums(brainT.s) : [];
  // specials of the Lazy Devs games, and the AI types of Porklike
  const specMap = { stun: 'stun', 'stun?': 'stun', curse: 'curse', slow: 'slow', scared: 'flee', vamp: 'vampire',
    stealitm: 'steal_item', stealeqp: 'steal_weapon' };
  const brainMap = { 3: 'still', 4: 'summon', 5: 'pounce', 6: 'hunter' };
  const porklike = cart.name.startsWith('Porklike');
  let frames;
  if (aniT.kind === 'explodeval') frames = nums(aniT.s).map(b => [b, b + 1, b + 2, b + 3]);
  else frames = aniT.s.split(',').map(f => f.split('|').map(Number));
  const names = nameT ? nameT.s.split(',') : null;
  const hp = hpT ? nums(hpT.s) : [];
  const atk = atkT ? nums(atkT.s) : [];
  const los = losT ? nums(losT.s) : [];
  const minf = minfT ? minfT.s.split(',').map(v => v.trim() === '' ? 1 : Number(v)) : [];
  const spec = specT ? specT.s.split(',') : [];
  const types = typeT ? typeT.s.split(',') : [];
  const plan = planT ? planT.s.split('|').map(r => nums(r)) : null;
  for (let i = 1; i < frames.length; i++) {
    if (types.length && types[i] !== 'ai' && types[i] !== 'we') continue;
    let depth = minf[i] != null ? minf[i] : 1;
    if (plan) {
      const f = plan.findIndex(r => r.includes(i + 1));
      depth = f >= 0 ? f + 1 : 99;
    }
    const sp = (spec[i] || '').trim();
    const fr = frames[i].slice(0, 4);
    while (fr.length < 4) fr.push(fr[fr.length - 1]);
    out.push({
      src: cart.name, index: i + 1,
      name: (names && names[i] ? names[i] : `${cart.name.split(' ')[0].toLowerCase()} ${i + 1}`).slice(0, 20),
      hp: Math.max(1, Math.min(127, hp[i] != null ? hp[i] : 2)),
      atk: Math.max(0, Math.min(99, atk[i] != null ? atk[i] : 1)),
      sight: Math.max(1, Math.min(8, los[i] != null && los[i] > 0 ? los[i] : 4)),
      range: 1,
      depth: Math.max(1, Math.min(99, depth < 1 ? 1 : depth)),
      abilities: [...new Set([specMap[sp], brainMap[brains[i]],
        porklike && i + 1 === 4 ? 'blind' : null, porklike && i + 1 === 6 ? 'invisible' : null].filter(Boolean))],
      spec: sp || (brainMap[brains[i]] ? `AI ${brainMap[brains[i]]}` : ''),
      frames: fr,
      col: mainColour(cart, fr[0]),
    });
  }
  return out;
}
function cartPixel(cart, n, x, y) {
  return cart.gfx[(((n >> 4) * 8) + y) * 128 + (n % 16) * 8 + x];
}
function mainColour(cart, n) {
  const cnt = new Array(16).fill(0);
  for (let y = 0; y < 8; y++) for (let x = 0; x < 8; x++) cnt[cartPixel(cart, n, x, y)]++;
  cnt[0] = 0;
  return cnt.indexOf(Math.max(...cnt));
}
function cartSprite(cart, n, scale = 3) {
  const c = h('canvas', { class: 'px', width: 8 * scale, height: 8 * scale });
  drawCartSprite(c.getContext('2d'), cart, n, 0, 0, scale);
  return c;
}
function drawCartSprite(ctx, cart, n, dx, dy, scale) {
  for (let y = 0; y < 8; y++) for (let x = 0; x < 8; x++) {
    const v = cartPixel(cart, n, x, y);
    if (!v) continue;
    ctx.fillStyle = PAL_CSS[v];
    ctx.fillRect(dx + x * scale, dy + y * scale, scale, scale);
  }
}
// tile conversion: flag 0 = solid wall (Lazy Devs engine), 0 = void, else floor;
// known special tiles of Porklike are mapped to their Lich King equivalents.
function defaultOverrides(cart) {
  const o = {};
  if (cart.name.startsWith('Porklike')) {
    o[14] = 'exit'; o[15] = 'start'; o[80] = 'spikes'; o[81] = 'spikes'; o[63] = 'doorh'; o[7] = 'floor';
  }
  return o;
}
const TARGETS = ['void', 'floor', 'wall', 'start', 'exit', 'spikes', 'doorh', 'doorv', 'pot', 'chest'];
function targetCode(t) {
  switch (t) {
    case 'void': return 0;
    case 'floor': return 1;
    case 'wall': return T_WALL;
    case 'start': return G.params.tile_start;
    case 'exit': return G.params.tile_exit;
    case 'spikes': return G.monsters[12].code;
    case 'doorh': return G.monsters[6].code;
    case 'doorv': return G.monsters[7].code;
    case 'pot': return G.monsters[3].code;
    case 'chest': return G.monsters[4].code;
  }
  return 0;
}
function convertTile(cart, t, solidBit) {
  if (cart.overrides[t]) return targetCode(cart.overrides[t]);
  if (t === 0) return 0;
  return (cart.flags[t] >> solidBit) & 1 ? T_WALL : 1;
}

// ------------------------------------------------------------------ floors
function blankFloor(name) {
  return { name, tiles: new Array(32).fill('00'.repeat(128)) };
}
function floorGet(f, x, y) { return parseInt(f.tiles[y].slice(x * 2, x * 2 + 2), 16); }
function floorSet(f, x, y, v) {
  const r = f.tiles[y];
  f.tiles[y] = r.slice(0, x * 2) + v.toString(16).padStart(2, '0') + r.slice(x * 2 + 2);
}
function floorRLE(f) {
  const raw = [];
  for (let y = 0; y < 32; y++) for (let x = 0; x < 128; x++) raw.push(floorGet(f, x, y));
  let n = 0;
  for (let i = 0; i < raw.length;) {
    let k = 1;
    while (i + k < raw.length && raw[i + k] === raw[i] && k < 255) k++;
    n += (k >= 4 || raw[i] === 0xfe) ? 3 : k;
    i += k;
  }
  return n;
}
// what the game makes of a floor: auto_tile, entities, wall_fix
function bakeFloor(f) {
  const t = [];
  for (let y = 0; y < 32; y++) for (let x = 0; x < 128; x++) t.push(floorGet(f, x, y));
  const at = (x, y) => (x < 0 || y < 0 || x > 127 || y > 31) ? 0 : t[y * 128 + x];
  const wallish = v => (G.flags[v] & 0x80) !== 0;
  const out = t.slice();
  for (let y = 0; y < 32; y++) for (let x = 0; x < 128; x++) {
    if (t[y * 128 + x] !== T_WALL) continue;
    let nt = 0;
    if (wallish(at(x - 1, y))) nt |= 2;
    if (wallish(at(x + 1, y))) nt |= 4;
    if (wallish(at(x, y - 1))) nt |= 1;
    if (wallish(at(x, y + 1))) nt |= 8;
    out[y * 128 + x] = T_WALL + nt;
  }
  const c2e = codeToEntity();
  const ents = [];
  for (let i = 0; i < out.length; i++) {
    const id = c2e.get(out[i]);
    if (out[i] !== G.params.tile_start && id) { ents.push({ i, id }); out[i] = 1; }
  }
  for (let y = 0; y < 31; y++) for (let x = 0; x < 128; x++) {
    if (!wallish(out[y * 128 + x])) continue;
    const j = (y + 1) * 128 + x, v = out[j];
    if (v === 1) out[j] = 2;
    else if (v === 0) out[j] = 3;
    else if (v >= 32 && v < 43 && (v & 3) !== 3) out[j] = v | 3;
  }
  return { tiles: out, ents };
}
const LIT = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 1, 15];
function drawFloor(ctx, f, scale, opts = {}) {
  const { tiles, ents } = bakeFloor(f);
  ctx.fillStyle = '#000';
  ctx.fillRect(0, 0, ctx.canvas.width, ctx.canvas.height);
  ctx.imageSmoothingEnabled = false;
  const s = 8 * scale;
  for (let i = 0; i < tiles.length; i++) {
    const v = tiles[i];
    if (!v) continue;
    ctx.drawImage(sprite(v, LIT), (i % 128) * s, (i >> 7) * s, s, s);
  }
  for (const e of ents) {
    const m = G.monsters[e.id - 1];
    ctx.drawImage(sprite(m.anim), (e.i % 128) * s, (e.i >> 7) * s, s, s);
  }
  if (opts.grid) {
    ctx.strokeStyle = 'rgba(255,255,255,.06)';
    ctx.beginPath();
    for (let x = 0; x <= 128; x++) { ctx.moveTo(x * s + .5, 0); ctx.lineTo(x * s + .5, 32 * s); }
    for (let y = 0; y <= 32; y++) { ctx.moveTo(0, y * s + .5); ctx.lineTo(128 * s, y * s + .5); }
    ctx.stroke();
  }
  return ents.length;
}

// ------------------------------------------------------------------ library
let libCarts = null;
function library() {
  if (!libCarts) libCarts = LIBRARY.map(c => parseP8(c.name, c.p8));
  return libCarts;
}
function addLibraryMonster(lm, cart) {
  if (G.monsters.length >= META.maxEntities) return status(`at most ${META.maxEntities} entity types`, true);
  const slot = freePage2Slot();
  if (slot < 0) return status('the second sprite page is full', true);
  const codes = freeCodes();
  if (!codes.length) return status('no free map code left (an empty cell of sprite page 1 is needed)', true);
  for (let i = 0; i < 4; i++) {
    const n = slot + i - 256, sx = (n % 16) * 8, sy = (n >> 4) * 8;
    for (let y = 0; y < 8; y++) for (let x = 0; x < 8; x++) setPixel(2, sx + x, sy + y, cartPixel(cart, lm.frames[i], x, y));
  }
  G.monsters.push({
    name: lm.name, anim: slot, code: codes[0], col: lm.col, prop: false, hp: lm.hp, atk: lm.atk,
    range: lm.range, sight: lm.sight, depth: Math.min(lm.depth, G.params.last_floor), itemchance: 0,
    abilities: lm.abilities.slice(), from: `${cart.name} #${lm.index}`,
  });
  changed(`added ${lm.name} from ${cart.name} as entity ${G.monsters.length}`);
  render();
}

// ------------------------------------------------------------------ tabs
const TABS = [
  ['rules', 'Rules'], ['monsters', 'Monsters'], ['items', 'Items'], ['floors', 'Floors & maps'],
  ['sprites', 'Sprites'], ['pieces', 'Furniture'], ['texts', 'Texts'], ['export', 'Export'],
];
function render() {
  const nav = document.getElementById('tabs');
  nav.replaceChildren(...TABS.map(([id, label]) =>
    h('button', { class: id === tab ? 'active' : '', onclick: () => { tab = id; history.replaceState(null, '', '#' + id); render(); } }, label)));
  const main = document.getElementById('main');
  main.replaceChildren(VIEWS[tab]());
}
const VIEWS = {};

// ---- rules
VIEWS.rules = () => {
  const box = h('div');
  box.append(h('p', { class: 'note' },
    'Rules of the level generator and the game. Chances are 0..1. The defaults are the original ' +
    'cartridge; "Export" writes them to game.json for tools/make_data.py.'));
  const grid = h('div', { class: 'grid2' });
  for (const p of META.params) {
    const inp = numInput(G.params, p.key, p.kind === 'chance'
      ? { step: 0.01, min: 0, max: 1, float: true } : { min: 0, max: 255 });
    const dflt = DEFAULT_GAME.params[p.key];
    grid.append(h('div', { class: 'param' },
      h('div', {}, h('div', {}, p.key), h('div', { class: 'd' }, p.desc + (G.params[p.key] !== dflt ? ` (original ${dflt})` : ''))), inp));
  }
  box.append(h('h2', {}, 'Parameters'), grid);

  const nf = META.maxFloors;
  const perFloor = (key, label, min, max) => h('tr', {}, h('td', {}, label),
    ...Array.from({ length: nf }, (_, i) => h('td', {}, numInput(G[key], i, { min, max, width: 46 }))));
  box.append(h('h2', {}, 'Per floor'),
    h('p', { class: 'note' }, 'Monster budget: monsters placed on the floor (the original uses the experience needed for the next level). ' +
      'Mimic offset: extra mimics = offset + 1 when positive. Treasure rooms: chest rooms in the room pool.'),
    h('div', { class: 'scroll' }, h('table', {},
      h('tr', {}, h('th', {}, 'floor'), ...Array.from({ length: nf }, (_, i) => h('th', {}, i + 1))),
      perFloor('budget', 'monster budget', 0, 200),
      perFloor('mimic_offset', 'mimic offset', -128, 20),
      perFloor('treasure_rooms', 'treasure rooms', 0, 8))));

  const listField = (key, label, note) => {
    const inp = h('input', { class: 'wide', value: G[key].join(',') });
    inp.addEventListener('change', () => {
      const v = inp.value.split(',').map(s => Math.round(Number(s.trim()))).filter(n => !Number.isNaN(n));
      if (!v.length) return;
      G[key] = v; changed();
    });
    return h('div', { class: 'param' }, h('div', {}, h('div', {}, label), h('div', { class: 'd' }, note)), inp);
  };
  box.append(h('h2', {}, 'Lists'), h('div', { class: 'grid2' },
    listField('floor_weights', 'floor_weights', 'room floor style picked from this list (0 plain, 1..3 styles)'),
    listField('move_weights', 'move_weights', 'room drift weights: left, right, up, down'),
    listField('xp_req', 'xp_req', 'total experience needed for level 1, 2, 3...'),
    listField('start_items', 'start_items', 'item ids in the backpack at the start')));
  return box;
};

// ---- monsters
VIEWS.monsters = () => {
  const box = h('div');
  box.append(h('p', { class: 'note' },
    'Entity types of the game. Monsters have 4 animation frames (sprite .. sprite+3); sprites 256..383 are the ' +
    'second sprite page used by imported monsters. "Code" is the map value that places the entity on a floor. ' +
    'Props (pots, chests, doors...) keep their built-in behaviour; their sprite and item chance can be changed.'));
  const t = h('table');
  t.append(h('tr', {}, ...['id', 'anim', 'name', 'sprite', 'code', 'colour', 'hp', 'atk', 'range', 'sight',
    'from floor', 'item chance', 'abilities', ''].map(s => h('th', {}, s))));
  G.monsters.forEach((m, i) => {
    const id = i + 1;
    const abil = h('td');
    if (!m.prop && id !== 1) {
      for (const a of META.abilities) {
        const cb = h('input', { type: 'checkbox', checked: m.abilities.includes(a) });
        cb.addEventListener('change', () => {
          m.abilities = META.abilities.filter(x => x === a ? cb.checked : m.abilities.includes(x));
          changed();
        });
        abil.append(h('label', { class: 'chk', title: META.abilityDesc[a] }, cb, a));
      }
    } else abil.append(h('span', { class: 'tag' }, m.role || (m.prop ? 'prop' : '')));
    const colSel = h('select', {}, ...PAL_CSS.map((c, k) => h('option', { value: k, selected: m.col === k, style: `background:${c}` }, k)));
    colSel.addEventListener('change', () => { m.col = Number(colSel.value); changed(); });
    t.append(h('tr', {},
      h('td', {}, id, id > BUILTIN_ENTS ? h('span', { class: 'tag new' }, 'new') : null),
      h('td', {}, animCanvas(() => entFrames(m), 3)),
      h('td', {}, textInput(m, 'name', { glyphs: true, cls: '' }), m.from ? h('div', { class: 'note' }, m.from) : null),
      h('td', {}, numInput(m, 'anim', { min: 0, max: 383, width: 56 })),
      h('td', {}, numInput(m, 'code', { min: 1, max: 255, width: 56 })),
      h('td', {}, colSel),
      h('td', {}, numInput(m, 'hp', { min: 1, max: 127, width: 50 })),
      h('td', {}, numInput(m, 'atk', { min: 0, max: 99, width: 50 })),
      h('td', {}, numInput(m, 'range', { min: 0, max: 8, width: 44 })),
      h('td', {}, numInput(m, 'sight', { min: 0, max: 8, width: 44 })),
      h('td', {}, numInput(m, 'depth', { min: 0, max: 99, width: 50 })),
      h('td', {}, numInput(m, 'itemchance', { min: 0, max: 10, width: 44 })),
      abil,
      h('td', {}, id > BUILTIN_ENTS ? h('button', { class: 'small', onclick: () => {
        G.monsters.splice(i, 1); changed(`removed ${m.name}`); render();
      } }, 'remove') : null)));
  });
  box.append(h('div', { class: 'scroll' }, t));
  box.append(h('p', { class: 'note' }, 'Item chance: 0..10 tenths (props). From floor: first floor the monster ' +
    'appears on (99 = never randomly). Abilities: ' + META.abilities.map(a => `${a} (${META.abilityDesc[a]})`).join(', ') + '.'));

  // library
  box.append(h('h2', {}, 'Monsters from other games'));
  box.append(h('p', { class: 'note' }, 'Stats and the first 4 animation frames read from the carts. "Add to game" ' +
    'copies the frames to the second sprite page and adds a new entity type (they then appear on floors from ' +
    '"from floor" on, like the original monsters). Their special mechanics become abilities. ' +
    'Use "Load a .p8" to read any other cart.'));
  const loadBtn = h('label', { class: 'btn' }, 'Load a .p8 cart', h('input', { type: 'file', accept: '.p8', hidden: true,
    onchange: e => loadCartFile(e.target.files[0]) }));
  box.append(loadBtn);
  for (const cart of library()) {
    box.append(h('h3', {}, `${cart.name} — ${cart.monsters.length} monsters`));
    if (!cart.monsters.length) { box.append(h('p', { class: 'note' }, 'no monster table found')); continue; }
    const lt = h('table');
    lt.append(h('tr', {}, ...['', 'name', 'hp', 'atk', 'sight', 'from floor', 'abilities', ''].map(s => h('th', {}, s))));
    for (const lm of cart.monsters) {
      const c = h('canvas', { class: 'px', width: 24, height: 24 });
      const ctx = c.getContext('2d');
      animated.push({ canvas: c, draw: f => { ctx.clearRect(0, 0, 24, 24); drawCartSprite(ctx, cart, lm.frames[f % 4], 0, 0, 3); } });
      lt.append(h('tr', {}, h('td', {}, c), h('td', {}, lm.name), h('td', {}, lm.hp), h('td', {}, lm.atk),
        h('td', {}, lm.sight), h('td', {}, lm.depth), h('td', {}, lm.abilities.join(', ')),
        h('td', {}, h('button', { class: 'small', onclick: () => addLibraryMonster(lm, cart) }, 'Add to game'))));
    }
    box.append(h('div', { class: 'scroll' }, lt));
  }
  return box;
};
function loadCartFile(file) {
  if (!file) return;
  const r = new FileReader();
  r.onload = () => {
    const cart = parseP8(file.name.replace(/\.p8$/, ''), r.result);
    library().push(cart);
    status(`${cart.name}: ${cart.monsters.length} monsters`);
    render();
  };
  r.readAsText(file, 'latin1');
}

// ---- items
VIEWS.items = () => {
  const box = h('div');
  box.append(h('p', { class: 'note' }, 'Type 0 = food/drink (heal, max hp), 1 = weapon (attack; the sprite is the ' +
    'first of 4 frames held by the hero). "Found in": chests give weapons, pots food, shelves drinks ' +
    '(chosen among the items whose "from floor" is reached).'));
  const t = h('table');
  t.append(h('tr', {}, ...['id', 'icon', 'name', 'type', 'sprite', 'atk', 'heal', 'max hp', 'from floor', 'found in', ''].map(s => h('th', {}, s))));
  G.items.forEach((it, i) => {
    const sel = h('select', {}, ...['pot', 'shelves', 'chest'].map(v => h('option', { selected: it.found === v }, v)));
    sel.addEventListener('change', () => { it.found = sel.value; changed(); });
    t.append(h('tr', {}, h('td', {}, i + 1),
      h('td', {}, it.type === 1 ? animCanvas(() => [0, 1, 2, 3].map(k => it.spr + k)) : ''),
      h('td', {}, textInput(it, 'name', { glyphs: true, cls: '' })),
      h('td', {}, numInput(it, 'type', { min: 0, max: 1, width: 40, after: render })),
      h('td', {}, numInput(it, 'spr', { min: 0, max: 252, width: 56 })),
      h('td', {}, numInput(it, 'atk', { min: 0, max: 60, width: 46 })),
      h('td', {}, numInput(it, 'heal', { min: 0, max: 60, width: 46 })),
      h('td', {}, numInput(it, 'hpmax', { min: 0, max: 60, width: 46 })),
      h('td', {}, numInput(it, 'depth', { min: 1, max: 99, width: 46 })),
      h('td', {}, sel),
      h('td', {}, i >= 15 ? h('button', { class: 'small', onclick: () => { G.items.splice(i, 1); changed(); render(); } }, 'remove') : null)));
  });
  box.append(t, h('p', {}, h('button', { onclick: () => {
    if (G.items.length >= META.maxItems) return status(`at most ${META.maxItems} items`, true);
    G.items.push({ name: 'new item', type: 0, spr: 0, atk: 0, heal: 3, hpmax: 0, depth: 1, found: 'pot' });
    changed(); render();
  } }, 'Add item')));
  return box;
};

// ---- floors & maps
let curFloor = 0, brush = 1, tool = 'paint', mapScale = 2, libSel = 0, libRect = null;
VIEWS.floors = () => {
  const box = h('div');
  box.append(h('p', { class: 'note' }, 'Every floor is generated, unless the plan gives it a hand-made map. ' +
    'Maps are 128×32 tiles: paint floor, walls (they take their shape when the game builds the floor), the start ' +
    `(tile ${G.params.tile_start}) and the stairs down (tile ${G.params.tile_exit}), props and monsters. ` +
    'Maps of other games can be converted below.'));
  // plan
  const plan = h('table');
  plan.append(h('tr', {}, h('th', {}, 'floor'), ...Array.from({ length: G.params.last_floor }, (_, i) => h('th', {}, i + 1))));
  plan.append(h('tr', {}, h('td', {}, 'map'), ...Array.from({ length: G.params.last_floor }, (_, i) => {
    const s = h('select', {}, h('option', { value: -1 }, 'generated'),
      ...G.floors.map((f, k) => h('option', { value: k, selected: G.floor_plan[i] === k }, f.name)));
    s.addEventListener('change', () => { G.floor_plan[i] = Number(s.value); changed(); });
    return h('td', {}, s);
  })));
  box.append(h('h2', {}, 'Floor plan'), h('div', { class: 'scroll' }, plan));

  // map list
  const bytes = G.floors.reduce((a, f) => a + floorRLE(f), 0);
  box.append(h('h2', {}, 'Hand-made maps ', h('span', { class: bytes > META.floorBytes ? 'err' : 'note' },
    `(${bytes} of ${META.floorBytes} bytes used)`)));
  const list = h('div', { class: 'row' });
  G.floors.forEach((f, k) => list.append(h('button', { class: k === curFloor ? 'on' : '', onclick: () => { curFloor = k; render(); } }, f.name)));
  list.append(h('button', { onclick: () => { G.floors.push(blankFloor(`map ${G.floors.length + 1}`)); curFloor = G.floors.length - 1; changed(); render(); } }, '+ New map'));
  box.append(list);
  const f = G.floors[curFloor];
  if (f) box.append(mapEditor(f));
  box.append(libraryMaps());
  return box;
};
function paletteGroup(label, codes) {
  return h('div', {}, h('h3', {}, label), h('div', { class: 'palette' }, ...codes.map(c => {
    const id = codeToEntity().get(c);
    const spr = id && c !== G.params.tile_start ? G.monsters[id - 1].anim : c;
    const cv = spriteCanvas(spr, 3, id ? null : LIT);
    cv.title = id ? `${G.monsters[id - 1].name} (code ${c})` : `tile ${c}`;
    if (c === brush) cv.classList.add('sel');
    cv.addEventListener('click', () => { brush = c; tool = 'paint'; render(); });
    return cv;
  })));
}
function mapEditor(f) {
  const wrap = h('div', { class: 'row' });
  const side = h('div', { class: 'col', style: 'width:300px' });
  const name = textInput(f, 'name', { cls: '', after: render });
  side.append(h('div', {}, 'Name ', name),
    h('div', {}, ...['paint', 'rect', 'pick'].map(t => h('button', { class: tool === t ? 'on small' : 'small', onclick: () => { tool = t; render(); } }, t)),
      ' zoom ', ...[1, 2, 3].map(z => h('button', { class: mapScale === z ? 'on small' : 'small', onclick: () => { mapScale = z; render(); } }, `${z}×`))),
    h('div', {}, h('button', { class: 'small', onclick: () => {
      G.floors.push(clone(f)); G.floors[G.floors.length - 1].name = f.name + ' copy'; curFloor = G.floors.length - 1; changed(); render();
    } }, 'duplicate'), ' ', h('button', { class: 'small', onclick: () => {
      if (!confirm(`Delete ${f.name}?`)) return;
      G.floors.splice(curFloor, 1);
      G.floor_plan = G.floor_plan.map(v => v === curFloor ? -1 : v > curFloor ? v - 1 : v);
      curFloor = 0; changed(); render();
    } }, 'delete'), ' ', h('button', { class: 'small', onclick: () => {
      if (!confirm('Clear the map?')) return; f.tiles = blankFloor('').tiles; changed(); render();
    } }, 'clear')));
  const c2e = codeToEntity();
  const ents = G.monsters.map((m, i) => i + 1).filter(id => id !== 1);
  side.append(paletteGroup('Ground', [0, ...FLOOR_TILES, T_WALL, G.params.tile_start, G.params.tile_exit,
    G.params.tile_anvil_deco, G.params.tile_altar_deco]));
  side.append(paletteGroup('Props', ents.filter(id => G.monsters[id - 1].prop).map(id => G.monsters[id - 1].code)));
  side.append(paletteGroup('Monsters', ents.filter(id => !G.monsters[id - 1].prop).map(id => G.monsters[id - 1].code)));
  const info = h('div', { class: 'note' });
  side.append(h('div', { class: 'note' }, `brush: ${brush} ${c2e.get(brush) ? '(' + G.monsters[c2e.get(brush) - 1].name + ')' : ''}`), info);

  const s = 8 * mapScale;
  const cv = h('canvas', { class: 'px', width: 128 * s, height: 32 * s });
  const ctx = cv.getContext('2d');
  const redraw = () => {
    const n = drawFloor(ctx, f, mapScale, { grid: mapScale > 1 });
    const { tiles } = bakeFloor(f);
    const starts = tiles.filter(v => v === G.params.tile_start).length;
    const exits = tiles.filter(v => v === G.params.tile_exit).length;
    info.replaceChildren(`${n} entities, ${starts} start, ${exits} stairs, ${floorRLE(f)} bytes`,
      starts !== 1 ? h('div', { class: 'err' }, 'a floor needs exactly one start tile') : '');
  };
  let down = null;
  const cell = e => {
    const r = cv.getBoundingClientRect();
    return [Math.floor((e.clientX - r.left) / s), Math.floor((e.clientY - r.top) / s)];
  };
  const apply = (x0, y0, x1, y1) => {
    for (let y = Math.min(y0, y1); y <= Math.max(y0, y1); y++) for (let x = Math.min(x0, x1); x <= Math.max(x0, x1); x++) {
      if (x >= 0 && y >= 0 && x < 128 && y < 32) floorSet(f, x, y, brush);
    }
  };
  cv.addEventListener('mousedown', e => {
    const [x, y] = cell(e);
    if (tool === 'pick') { brush = floorGet(f, x, y); tool = 'paint'; render(); return; }
    down = [x, y];
    if (tool === 'paint') { apply(x, y, x, y); redraw(); }
  });
  cv.addEventListener('mousemove', e => {
    const [x, y] = cell(e);
    cv.title = `${x},${y}: ${floorGet(f, x, y)}`;
    if (down && tool === 'paint') { apply(x, y, x, y); redraw(); }
  });
  window.onmouseup = e => {
    if (down && tool === 'rect') { const [x, y] = cell(e); apply(down[0], down[1], x, y); redraw(); }
    if (down) changed();
    down = null;
  };
  redraw();
  wrap.append(side, h('div', { class: 'mapwrap', style: 'flex:1;min-width:300px' }, cv));
  return wrap;
}
function libraryMaps() {
  const box = h('div');
  box.append(h('h2', {}, 'Maps of other games'));
  const carts = library();
  const cart = carts[libSel] || carts[0];
  const sel = h('select', {}, ...carts.map((c, i) => h('option', { value: i, selected: i === libSel }, c.name)));
  sel.addEventListener('change', () => { libSel = Number(sel.value); libRect = null; render(); });
  const bit = h('input', { type: 'number', value: cart.solidBit ?? 0, min: 0, max: 7, style: 'width:44px' });
  bit.addEventListener('change', () => { cart.solidBit = Number(bit.value); render(); });
  box.append(h('div', { class: 'row' }, h('div', {}, 'Cart ', sel), h('div', {}, 'wall = sprite flag ', bit),
    h('label', { class: 'btn' }, 'Load a .p8 cart', h('input', { type: 'file', accept: '.p8', hidden: true, onchange: e => loadCartFile(e.target.files[0]) }))));
  box.append(h('p', { class: 'note' }, 'Drag a rectangle on the cart\'s map (Porklike: 16×16 rooms; floor 0 at the top left, ' +
    'the win room next to it, the gate vaults after). Tiles convert by their flags: void → nothing, the wall flag → wall, ' +
    'others → floor; the table below overrides single tiles (stairs, start, traps...). Then copy it into the current map at x, y.'));
  // cart map
  const sc = 2;
  const cv = h('canvas', { class: 'px', width: 128 * 8 * sc, height: 32 * 8 * sc });
  const ctx = cv.getContext('2d');
  const draw = () => {
    ctx.fillStyle = '#000'; ctx.fillRect(0, 0, cv.width, cv.height);
    for (let y = 0; y < 32; y++) for (let x = 0; x < 128; x++) {
      const t = cart.map[y * 128 + x];
      if (t) drawCartSprite(ctx, cart, t, x * 8 * sc, y * 8 * sc, sc);
    }
    ctx.strokeStyle = 'rgba(255,255,255,.15)';
    for (let x = 0; x <= 128; x += 16) { ctx.beginPath(); ctx.moveTo(x * 16 + .5, 0); ctx.lineTo(x * 16 + .5, cv.height); ctx.stroke(); }
    ctx.beginPath(); ctx.moveTo(0, 256.5); ctx.lineTo(cv.width, 256.5); ctx.stroke();
    if (libRect) {
      ctx.strokeStyle = '#ff77a8'; ctx.lineWidth = 2;
      const [x0, y0, x1, y1] = libRect;
      ctx.strokeRect(x0 * 16, y0 * 16, (x1 - x0 + 1) * 16, (y1 - y0 + 1) * 16);
      ctx.lineWidth = 1;
    }
  };
  let d0 = null;
  const cellOf = e => { const r = cv.getBoundingClientRect(); return [Math.floor((e.clientX - r.left) / 16), Math.floor((e.clientY - r.top) / 16)]; };
  cv.addEventListener('mousedown', e => { d0 = cellOf(e); libRect = [...d0, ...d0]; draw(); });
  cv.addEventListener('mousemove', e => {
    if (!d0) return;
    const [x, y] = cellOf(e);
    libRect = [Math.min(d0[0], x), Math.min(d0[1], y), Math.max(d0[0], x), Math.max(d0[1], y)];
    draw();
  });
  cv.addEventListener('mouseup', () => { d0 = null; render(); });
  draw();
  box.append(h('div', { class: 'mapwrap' }, cv));
  // overrides of the tiles in the selection
  if (libRect) {
    const [x0, y0, x1, y1] = libRect;
    const used = new Set();
    for (let y = y0; y <= y1; y++) for (let x = x0; x <= x1; x++) used.add(cart.map[y * 128 + x]);
    const ot = h('div', { class: 'palette', style: 'max-width:100%' });
    const solid = cart.solidBit ?? 0;
    for (const t of [...used].sort((a, b) => a - b)) {
      const s = h('select', {}, h('option', { value: '' }, `auto (${t === 0 ? 'void' : (cart.flags[t] >> solid) & 1 ? 'wall' : 'floor'})`),
        ...TARGETS.map(v => h('option', { selected: cart.overrides[t] === v }, v)));
      s.addEventListener('change', () => { if (s.value) cart.overrides[t] = s.value; else delete cart.overrides[t]; });
      ot.append(h('div', { class: 'panel', style: 'padding:4px' }, cartSprite(cart, t, 3), h('div', { class: 'note' }, `tile ${t}`), s));
    }
    const tx = h('input', { type: 'number', value: 4, min: 0, max: 127, style: 'width:56px' });
    const ty = h('input', { type: 'number', value: 4, min: 0, max: 31, style: 'width:56px' });
    box.append(h('h3', {}, `selection ${x1 - x0 + 1}×${y1 - y0 + 1} — tile conversion`), ot,
      h('p', {}, 'Copy into ', G.floors[curFloor] ? `"${G.floors[curFloor].name}"` : 'a new map', ' at x ', tx, ' y ', ty, ' ',
        h('button', { class: 'primary', onclick: () => {
          if (!G.floors[curFloor]) { G.floors.push(blankFloor(`${cart.name} ${G.floors.length + 1}`)); curFloor = G.floors.length - 1; }
          const f = G.floors[curFloor];
          const ox = Number(tx.value), oy = Number(ty.value);
          for (let y = y0; y <= y1; y++) for (let x = x0; x <= x1; x++) {
            const dx = ox + x - x0, dy = oy + y - y0;
            if (dx >= 0 && dy >= 0 && dx < 128 && dy < 32) floorSet(f, dx, dy, convertTile(cart, cart.map[y * 128 + x], solid));
          }
          changed(`copied ${x1 - x0 + 1}×${y1 - y0 + 1} tiles of ${cart.name} into ${f.name}`);
          render();
        } }, 'Copy into map')));
  }
  return box;
}

// ---- sprites
let sprPage = 1, sprSel = 0, penCol = 7;
VIEWS.sprites = () => {
  const box = h('div');
  box.append(h('p', { class: 'note' }, 'Page 1 is the cart\'s sprite sheet (sprites 0..255, also the map tiles); page 2 ' +
    '(256..383) holds imported monsters. Click a sprite, then draw with the palette. Flags (page 1): 0 blocks movement, ' +
    '1 blocks sight, 7 is a wall (walls join up).'));
  box.append(h('div', {}, ...[1, 2].map(p => h('button', { class: sprPage === p ? 'on' : '', onclick: () => { sprPage = p; sprSel = p === 1 ? 0 : 256; render(); } }, `Page ${p}`))));
  const rows = sprPage === 1 ? 128 : 64;
  const sc = 4;
  const cv = h('canvas', { class: 'px', width: 128 * sc, height: rows * sc });
  const ctx = cv.getContext('2d');
  const drawSheet = () => {
    ctx.imageSmoothingEnabled = false;
    ctx.fillStyle = '#000'; ctx.fillRect(0, 0, cv.width, cv.height);
    for (let n = 0; n < rows * 2; n++) ctx.drawImage(sprite((sprPage === 1 ? 0 : 256) + n), (n % 16) * 8 * sc, (n >> 4) * 8 * sc, 8 * sc, 8 * sc);
    const m = sprSel & 255;
    ctx.strokeStyle = '#ff77a8'; ctx.lineWidth = 2;
    ctx.strokeRect((m % 16) * 32 + 1, (m >> 4) * 32 + 1, 30, 30);
  };
  cv.addEventListener('click', e => {
    const r = cv.getBoundingClientRect();
    sprSel = (sprPage === 1 ? 0 : 256) + Math.floor((e.clientY - r.top) / 32) * 16 + Math.floor((e.clientX - r.left) / 32);
    render();
  });
  drawSheet();
  // pixel editor
  const ez = 24;
  const ed = h('canvas', { class: 'px', width: 8 * ez, height: 8 * ez });
  const ectx = ed.getContext('2d');
  const m = sprSel & 255, page = sprSel >= 256 ? 2 : 1;
  const sx = (m % 16) * 8, sy = (m >> 4) * 8;
  const drawEd = () => {
    for (let y = 0; y < 8; y++) for (let x = 0; x < 8; x++) {
      ectx.fillStyle = PAL_CSS[sheets[page][(sy + y) * 128 + sx + x]];
      ectx.fillRect(x * ez, y * ez, ez - 1, ez - 1);
    }
  };
  let painting = false;
  const paint = e => {
    const r = ed.getBoundingClientRect();
    const x = Math.floor((e.clientX - r.left) / ez), y = Math.floor((e.clientY - r.top) / ez);
    if (x < 0 || y < 0 || x > 7 || y > 7) return;
    setPixel(page, sx + x, sy + y, penCol);
    drawEd(); drawSheet();
  };
  ed.addEventListener('mousedown', e => { painting = true; paint(e); });
  ed.addEventListener('mousemove', e => { if (painting) paint(e); });
  ed.addEventListener('mouseup', () => { painting = false; changed(); });
  ed.addEventListener('mouseleave', () => { if (painting) changed(); painting = false; });
  drawEd();
  const pal = h('div', {}, ...PAL_CSS.map((c, k) => h('span', { class: 'swatch' + (k === penCol ? ' sel' : ''), style: `background:${c}`, title: k,
    onclick: () => { penCol = k; render(); } })));
  const flags = h('div');
  if (page === 1) {
    for (let b = 0; b < 8; b++) {
      const cb = h('input', { type: 'checkbox', checked: (G.flags[m] >> b) & 1 });
      cb.addEventListener('change', () => { G.flags[m] = cb.checked ? G.flags[m] | (1 << b) : G.flags[m] & ~(1 << b); changed(); });
      flags.append(h('label', { class: 'chk' }, cb, b));
    }
  }
  const users = G.monsters.filter(mm => entFrames(mm).includes(sprSel)).map(mm => mm.name);
  box.append(h('div', { class: 'row' }, h('div', { class: 'scroll' }, cv),
    h('div', { class: 'col panel' }, h('div', {}, `sprite ${sprSel}`, users.length ? ` — ${users.join(', ')}` : ''), ed, pal,
      page === 1 ? h('div', {}, 'flags ', flags) : null,
      h('div', {}, h('button', { class: 'small', onclick: () => { clip = []; for (let y = 0; y < 8; y++) for (let x = 0; x < 8; x++) clip.push(sheets[page][(sy + y) * 128 + sx + x]); status('copied'); } }, 'copy'), ' ',
        h('button', { class: 'small', onclick: () => { if (!clip) return; for (let y = 0; y < 8; y++) for (let x = 0; x < 8; x++) setPixel(page, sx + x, sy + y, clip[y * 8 + x]); changed('pasted'); render(); } }, 'paste'), ' ',
        h('button', { class: 'small', onclick: () => { for (let y = 0; y < 8; y++) for (let x = 0; x < 8; x++) setPixel(page, sx + x, sy + y, 0); changed('cleared'); render(); } }, 'clear')))));
  return box;
};
let clip = null;

// ---- furniture pieces
let pieceCol = 15;
VIEWS.pieces = () => {
  const box = h('div');
  box.append(h('p', { class: 'note' }, 'Ordinary rooms get 3×3 furniture pieces: piece = step × (floor-1) + random, so ' +
    'deeper floors use later pieces. Colour c places tile c+63 (+16 sometimes on deeper floors), 15 a wall, 0 nothing. ' +
    'Pieces 0 and 27 furnish the boss room.'));
  box.append(h('div', {}, 'colour ', ...PAL_CSS.map((c, k) => h('span', { class: 'swatch' + (k === pieceCol ? ' sel' : ''), style: `background:${c}`, title: k,
    onclick: () => { pieceCol = k; render(); } })), ` ${pieceCol} → ${pieceCol === 0 ? 'nothing' : pieceCol === 15 ? 'wall' : 'tile ' + (pieceCol + 63)}`));
  const grid = h('div', { class: 'row', style: 'margin-top:8px' });
  G.pieces.forEach((p, k) => {
    const c = h('canvas', { class: 'px', width: 72, height: 72 });
    const ctx = c.getContext('2d');
    const draw = () => {
      ctx.imageSmoothingEnabled = false;
      ctx.fillStyle = '#111'; ctx.fillRect(0, 0, 72, 72);
      for (let x = 0; x < 3; x++) for (let y = 0; y < 3; y++) {
        const v = p[x * 3 + y];
        if (!v) continue;
        ctx.drawImage(sprite(v === 15 ? T_WALL : v + 63, LIT), x * 24, y * 24, 24, 24);
      }
    };
    c.addEventListener('click', e => {
      const r = c.getBoundingClientRect();
      const x = Math.floor((e.clientX - r.left) / 24), y = Math.floor((e.clientY - r.top) / 24);
      p[x * 3 + y] = p[x * 3 + y] === pieceCol ? 0 : pieceCol;
      draw(); changed();
    });
    draw();
    grid.append(h('div', { class: 'panel col', style: 'align-items:center' }, c, h('span', { class: 'note' }, k)));
  });
  box.append(grid);
  return box;
};

// ---- texts
VIEWS.texts = () => {
  const box = h('div');
  box.append(h('p', { class: 'note' }, 'All texts use the cart\'s font: lowercase letters, digits and punctuation; ' +
    '"^a" is a capital A, "^^" a caret. At most 46 characters per line, 12 lines per window. Red = not drawable.'));
  const t = h('table');
  for (const k of Object.keys(G.texts)) t.append(h('tr', {}, h('td', { class: 'note' }, k), h('td', {}, textInput(G.texts, k, { glyphs: true }))));
  box.append(h('h2', {}, 'Messages'), t);
  for (const k of Object.keys(G.windows)) {
    const ta = h('textarea', { rows: G.windows[k].length + 1 }, G.windows[k].join('\n'));
    const check = () => ta.classList.toggle('bad', ta.value.split('\n').some(l => !textOk(l)) || ta.value.split('\n').length > 12);
    ta.addEventListener('input', check);
    ta.addEventListener('change', () => { G.windows[k] = ta.value.split('\n'); changed(); });
    check();
    box.append(h('h3', {}, k), ta);
  }
  return box;
};

// ---- export
function validate() {
  const errs = [], warns = [];
  if (G.monsters.length > META.maxEntities) errs.push(`${G.monsters.length} entity types (max ${META.maxEntities})`);
  if (G.items.length > META.maxItems) errs.push(`${G.items.length} items (max ${META.maxItems})`);
  const codes = new Map();
  G.monsters.forEach((m, i) => {
    if (!textOk(m.name)) errs.push(`monster ${i + 1}: name "${m.name}" cannot be drawn`);
    if (m.anim >= 256 && (m.anim & 255) > 124) errs.push(`monster ${i + 1}: second-page sprite too high`);
    if (!m.prop && m.anim < 256 && m.anim > 252) errs.push(`monster ${i + 1}: 4 frames do not fit`);
    if (codes.has(m.code)) warns.push(`${m.name} shares map code ${m.code} with ${codes.get(m.code)} (the lower id is placed)`);
    else codes.set(m.code, m.name);
  });
  G.items.forEach((it, i) => { if (!textOk(it.name)) errs.push(`item ${i + 1}: name cannot be drawn`); });
  for (const k of Object.keys(G.texts)) if (!textOk(G.texts[k])) errs.push(`text ${k} cannot be drawn`);
  for (const k of Object.keys(G.windows)) {
    if (G.windows[k].length > 12) errs.push(`window ${k}: more than 12 lines`);
    G.windows[k].forEach(l => { if (!textOk(l)) errs.push(`window ${k}: "${l}" cannot be drawn`); });
  }
  const bytes = G.floors.reduce((a, f) => a + floorRLE(f), 0);
  if (bytes > META.floorBytes) errs.push(`hand-made maps need ${bytes} bytes (max ${META.floorBytes})`);
  for (let i = 0; i < G.params.last_floor; i++) {
    const k = G.floor_plan[i];
    if (k == null || k < 0) continue;
    const f = G.floors[k];
    if (!f) { errs.push(`floor ${i + 1}: map ${k} missing`); continue; }
    const { tiles, ents } = bakeFloor(f);
    const starts = tiles.filter(v => v === G.params.tile_start).length;
    if (starts !== 1) errs.push(`floor ${i + 1} (${f.name}): ${starts} start tiles, exactly 1 needed`);
    const isLast = i + 1 === G.params.last_floor;
    if (!isLast && !tiles.includes(G.params.tile_exit)) warns.push(`floor ${i + 1} (${f.name}) has no stairs down`);
    if (isLast && !ents.some(e => e.id === G.params.boss_id)) warns.push(`floor ${i + 1} (${f.name}) has no boss: the game cannot be won`);
    if (ents.length > 200) errs.push(`floor ${i + 1}: ${ents.length} entities (max about 200)`);
  }
  if (!G.monsters[G.params.boss_id - 1]) errs.push('boss_id is not an entity');
  if (!G.monsters[G.params.mimic_id - 1]) errs.push('mimic_id is not an entity');
  return { errs, warns };
}
VIEWS.export = () => {
  const box = h('div');
  const { errs, warns } = validate();
  box.append(h('h2', {}, 'Check'),
    errs.length ? h('ul', { class: 'err' }, ...errs.map(e => h('li', {}, e))) : h('p', { class: 'okc' }, 'No errors.'),
    warns.length ? h('ul', { class: 'note' }, ...warns.map(e => h('li', {}, e))) : null);
  box.append(h('h2', {}, 'Build'), h('p', { class: 'note' },
    'Export game.json, put it into atari/lich/data/ and run ./build.sh (or ./run.sh). Without changes it builds ' +
    'exactly the original game.'), h('p', {}, h('button', { class: 'primary', onclick: exportGame }, 'Export game.json')));
  const diff = [];
  for (const k of Object.keys(G.params)) if (G.params[k] !== DEFAULT_GAME.params[k]) diff.push(`${k}: ${DEFAULT_GAME.params[k]} → ${G.params[k]}`);
  if (G.monsters.length !== DEFAULT_GAME.monsters.length) diff.push(`${G.monsters.length - DEFAULT_GAME.monsters.length} new monsters`);
  if (G.floors.length) diff.push(`${G.floors.length} hand-made maps`);
  box.append(h('h2', {}, 'Changes from the original'), diff.length ? h('ul', {}, ...diff.map(d => h('li', {}, d))) : h('p', { class: 'note' }, 'none (other than possibly sprites, texts and tables)'));
  return box;
};
function exportGame() {
  const { errs } = validate();
  if (errs.length && !confirm(`${errs.length} errors: the build will refuse it. Export anyway?`)) return;
  const blob = new Blob([JSON.stringify(G, null, 1)], { type: 'application/json' });
  const a = h('a', { href: URL.createObjectURL(blob), download: 'game.json' });
  document.body.append(a); a.click(); a.remove();
  status('exported game.json');
}

// ------------------------------------------------------------------ start
document.getElementById('btn-export').addEventListener('click', exportGame);
document.getElementById('btn-reset').addEventListener('click', () => {
  if (!confirm('Discard all changes and start from the original game?')) return;
  newGame(clone(DEFAULT_GAME)); render(); status('reset to the original game');
});
document.getElementById('openfile').addEventListener('change', e => {
  const file = e.target.files[0];
  if (!file) return;
  const r = new FileReader();
  r.onload = () => {
    try {
      const g = JSON.parse(r.result);
      if (g.format !== DEFAULT_GAME.format) throw new Error('not a lich-game file');
      newGame(g); render(); status(`opened ${file.name}`);
    } catch (err) { status(`${file.name}: ${err.message}`, true); }
  };
  r.readAsText(file);
});
let saved = null;
try { saved = JSON.parse(localStorage.getItem(STORE_KEY)); } catch (e) { saved = null; }
newGame(saved && saved.format === DEFAULT_GAME.format ? saved : clone(DEFAULT_GAME));
if (TABS.some(([id]) => '#' + id === location.hash)) tab = location.hash.slice(1);
render();
status(saved ? 'restored your last session (Reset to original to start over)' : 'original game loaded');
