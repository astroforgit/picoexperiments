#!/usr/bin/env node

'use strict';

const fs = require('fs');

const [inputJson, inputFont, outputFont, outputMap] = process.argv.slice(2);
if (!inputJson || !inputFont || !outputFont || !outputMap) {
  console.error('Usage: node title-json-to-data.js INPUT.json ORIGINAL.FNT OUTPUT.FNT OUTPUT.DTA');
  process.exit(1);
}

const payload = JSON.parse(fs.readFileSync(inputJson, 'utf8'));
if (!['hans-rzygol-title-image-v1', 'hans-rzygol-title-image-v2'].includes(payload.format)) {
  throw new Error('Unsupported title-image JSON format.');
}
if (payload.width !== 128 || payload.height !== 128 || !Array.isArray(payload.pixels) ||
    payload.pixels.length !== 128 || payload.pixels.some(row => typeof row !== 'string' || !/^[0-4]{128}$/.test(row))) {
  throw new Error('Title image must contain 128 rows of 128 pixel values from 0 to 4.');
}

const pixels = Uint8Array.from(payload.pixels.join('').split('').map(Number));
const tiles = [];
const knownTiles = new Map();
const screenMap = Buffer.alloc(256);
let attributeConflicts = 0;

for (let tileY = 0; tileY < 8; tileY++) {
  for (let tileX = 0; tileX < 32; tileX++) {
    const tile = [];
    let usesColor3 = false;
    let usesColor4 = false;
    for (let y = 0; y < 16; y++) {
      for (let x = 0; x < 4; x++) {
        const value = pixels[(tileY * 16 + y) * 128 + tileX * 4 + x];
        usesColor3 ||= value === 3;
        usesColor4 ||= value === 4;
        tile.push(value === 4 ? 3 : value);
      }
    }
    if (usesColor3 && usesColor4) attributeConflicts++;
    const key = tile.join('');
    if (!knownTiles.has(key)) {
      knownTiles.set(key, tiles.length);
      tiles.push(tile);
    }
    screenMap[tileY * 32 + tileX] = knownTiles.get(key) | (usesColor4 ? 0x80 : 0);
  }
}

if (tiles.length > 128) throw new Error(`Title image needs ${tiles.length} character tiles; Atari supports 128.`);
if (attributeConflicts) {
  throw new Error(`${attributeConflicts} tiles mix colors 3 and 4; ANTIC mode 4 permits only one of them per tile.`);
}

const originalFont = fs.readFileSync(inputFont);
if (originalFont.length !== 2054 || originalFont[0] !== 0xff || originalFont[1] !== 0xff) {
  throw new Error(`${inputFont} is not the expected two-bank Atari XEX font.`);
}
const font = Buffer.alloc(2054);
originalFont.copy(font, 0, 0, 6); // Preserve the $5C00-$63FF XEX segment header.

tiles.forEach((tile, code) => {
  for (let bank = 0; bank < 2; bank++) {
    for (let y = 0; y < 8; y++) {
      let packed = 0;
      for (let x = 0; x < 4; x++) packed |= tile[(bank * 8 + y) * 4 + x] << (6 - x * 2);
      font[6 + bank * 1024 + code * 8 + y] = packed;
    }
  }
});

fs.writeFileSync(outputFont, font);
fs.writeFileSync(outputMap, screenMap);
console.log(`Generated title image: ${tiles.length}/128 tiles, ${attributeConflicts} color conflicts.`);
