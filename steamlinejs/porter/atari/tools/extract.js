#!/usr/bin/env node
/*
 * Porter Patch PICO-8 -> Atari/VBXE asset builder.
 *
 * This deliberately reads the decoded cartridge data rather than the old
 * conversion's room files.  The result contains the complete 128x64 map.
 * Graphics are expanded from 8x8 to 12x12 (nearest-neighbour 3:2 scale) and
 * only sprites used by the map/game are retained.
 */
'use strict';

const fs = require('fs');
const path = require('path');

const ROOT = path.resolve(__dirname, '..');
const PORTER = path.resolve(ROOT, '..');
const OLD = path.join(PORTER, 'atariold');
const OUT = path.join(ROOT, 'data');
fs.mkdirSync(OUT, {recursive: true});

const dataJs = fs.readFileSync(path.join(PORTER, 'js', 'porterpatch-data.js'), 'utf8');
const shim = {window: {}};
new Function('window', dataJs).call(shim, shim.window);
const {MAP_HEX_TOP, MAP_HEX_SHARED, FLAG_HEX} = shim.window.PORTERPATCH_DATA;

function bytes(row) {
  const result = [];
  for (let i = 0; i < row.length; i += 2) result.push(parseInt(row.slice(i, i + 2), 16));
  return result;
}

const rows = MAP_HEX_TOP.map(bytes);
for (let r = 0; r < MAP_HEX_SHARED.length; r += 2) {
  const row = [];
  // Shared map RAM is encoded as PICO-8 sprite nibbles.
  for (const line of [MAP_HEX_SHARED[r], MAP_HEX_SHARED[r + 1]]) {
    for (let i = 0; i < line.length; i += 2) row.push(parseInt(line[i + 1] + line[i], 16));
  }
  rows.push(row);
}
while (rows.length < 64) rows.push(new Array(128).fill(0));
if (rows.length !== 64 || rows.some(r => r.length !== 128)) throw new Error('bad map dimensions');

const world = Buffer.from(rows.flat());
fs.writeFileSync(path.join(OUT, 'world.dat'), world);

const flags = Buffer.alloc(256);
for (let i = 0; i < 256 && i * 2 < FLAG_HEX.length; i++) {
  flags[i] = parseInt(FLAG_HEX.slice(i * 2, i * 2 + 2), 16);
}
fs.writeFileSync(path.join(OUT, 'tile_flags.dat'), flags);

// The old extractor already faithfully decoded the PNG to PICO palette indices.
const oldShapes = fs.readFileSync(path.join(OLD, 'data', 'shapes.spr'));
if (oldShapes.length !== 256 * 64) throw new Error('bad source sprite sheet');

const runtimeSprites = [
  0, 1, 3, 4, 5, 6, 7, 8, 9, 13, 16, 17, 18, 19, 20, 21, 22, 23,
  32, 33, 34, 35, 36, 37, 38, 39, 40, 46, 47, 48, 49, 50, 51, 52,
  53, 54, 55, 56, 58, 59,
  60, 61, 69, 70, 74, 75, 78, 79, 85, 86, 87, 88, 89, 90, 91, 92,
  93, 94, 95, 103, 104, 105, 119, 120, 121, 122, 123, 124, 125, 126
];
const used = new Set([...world, ...runtimeSprites]);
const ids = [...used].sort((a, b) => a - b);
const packed = Buffer.alloc(ids.length * 144);
const offsets = new Array(256).fill(0);

for (let n = 0; n < ids.length; n++) {
  const id = ids[n];
  offsets[id] = n * 144;
  for (let y = 0; y < 12; y++) {
    for (let x = 0; x < 12; x++) {
      const sx = Math.floor(x * 2 / 3);
      const sy = Math.floor(y * 2 / 3);
      packed[n * 144 + y * 12 + x] = oldShapes[id * 64 + sy * 8 + sx];
    }
  }
}
fs.writeFileSync(path.join(OUT, 'sprites12.dat'), packed);

let spriteAsm = '; generated: VBXE address of each compact 12x12 sprite\n';
spriteAsm += `SPRITE_DATA_SIZE = ${packed.length}\n`;
spriteAsm += `SPRITE_DATA_PAGES = ${Math.ceil(packed.length / 256)}\n`;
spriteAsm += 'sprite_addr_lo\n\tdta ' + offsets.map(v => `<${v}`).join(',') + '\n';
spriteAsm += 'sprite_addr_hi\n\tdta ' + offsets.map(v => `>${v}`).join(',') + '\n';
fs.writeFileSync(path.join(OUT, 'sprite_addr.inc.asm'), spriteAsm);

const checkpoints = [
  [13,7,19,9],[27,10,35,10],[44,6,51,3],[53,11,72,13],
  [74,3,83,6],[93,3,99,11],[98,2,115,10],[124,1,5,19],
  [14,22,19,26],[30,25,36,21],[38,28,49,28],[62,19,66,25],
  [66,30,82,24],[82,29,99,19],[109,18,114,26],[125,24,3,43],
  [3,33,18,45],[19,34,33,43],[33,33,50,44],[54,33,67,43],
  [67,35,81,35],[81,42,99,44],[98,38,115,44],[114,33,5,54],
  [5,58,18,56],[29,53,35,56],[35,61,51,52],[50,55,83,61]
];
let cpAsm = '; generated checkpoint/coin data, coordinates in tiles\n';
cpAsm += `COIN_COUNT = ${checkpoints.length}\n`;
for (const [name, index] of [['coin_tile_x', 0], ['coin_tile_y', 1], ['coin_next_x', 2], ['coin_next_y', 3]]) {
  cpAsm += `${name}\n\tdta ${checkpoints.map(c => c[index]).join(',')}\n`;
}
fs.writeFileSync(path.join(OUT, 'checkpoints.inc.asm'), cpAsm);

const objects = {rocks: [], feathers: []};
for (let y = 0; y < 64; y++) {
  for (let x = 0; x < 128; x++) {
    const t = rows[y][x];
    if (t === 74) objects.rocks.push([x, y]);
    if (t === 75) objects.feathers.push([x, y]);
  }
}
let objAsm = '; generated moving-object start positions\n';
for (const [name, list] of Object.entries(objects)) {
  objAsm += `${name.toUpperCase()}_COUNT = ${list.length}\n`;
  objAsm += `${name}_start_x\n\tdta ${list.length ? list.map(p => p[0]).join(',') : '0'}\n`;
  objAsm += `${name}_start_y\n\tdta ${list.length ? list.map(p => p[1]).join(',') : '0'}\n`;
}
fs.writeFileSync(path.join(OUT, 'objects.inc.asm'), objAsm);

// Hide moving objects in the tile map. They are rendered and updated as actors.
for (let i = 0; i < world.length; i++) {
  if (world[i] === 74 || world[i] === 75) world[i] = 0;
}
fs.writeFileSync(path.join(OUT, 'world.dat'), world);

// Native PICO-8 palette, 8-bit RGB accepted by VBXE.
const palette = [
  [0x00,0x00,0x00],[0x1d,0x2b,0x53],[0x7e,0x25,0x53],[0x00,0x87,0x51],
  [0xab,0x52,0x36],[0x5f,0x57,0x4f],[0xc2,0xc3,0xc7],[0xff,0xf1,0xe8],
  [0xff,0x00,0x4d],[0xff,0xa3,0x00],[0xff,0xec,0x27],[0x00,0xe4,0x36],
  [0x29,0xad,0xff],[0x83,0x76,0x9c],[0xff,0x77,0xa8],[0xff,0xcc,0xaa]
];
let palAsm = '; generated PICO-8 RGB palette\npico_palette\n';
for (const rgb of palette) palAsm += '\tdta ' + rgb.map(v => `$${v.toString(16).padStart(2, '0')}`).join(',') + '\n';
fs.writeFileSync(path.join(OUT, 'palette.inc.asm'), palAsm);

console.log(`world: ${world.length} bytes, sprites: ${ids.length} (${packed.length} bytes)`);
console.log(`rocks: ${objects.rocks.length}, feathers: ${objects.feathers.length}, checkpoints: ${checkpoints.length}`);
