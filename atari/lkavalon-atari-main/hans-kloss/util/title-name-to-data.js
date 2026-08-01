#!/usr/bin/env node

'use strict';

const fs = require('fs');

const [inputFont, outputFont, outputMap] = process.argv.slice(2);
if (!inputFont || !outputFont || !outputMap) {
  console.error('Usage: node title-name-to-data.js INPUT.FNT OUTPUT.FNT OUTPUT.DTA');
  process.exit(1);
}

const LETTERS = {
  A: ['01110', '10001', '10001', '11111', '10001', '10001', '10001'],
  G: ['01110', '10001', '10000', '10111', '10001', '10001', '01110'],
  H: ['10001', '10001', '10001', '11111', '10001', '10001', '10001'],
  L: ['10000', '10000', '10000', '10000', '10000', '10000', '11111'],
  N: ['10001', '11001', '11001', '10101', '10011', '10011', '10001'],
  O: ['01110', '10001', '10001', '10001', '10001', '10001', '01110'],
  R: ['11110', '10001', '10001', '11110', '10100', '10010', '10001'],
  S: ['01111', '10000', '10000', '01110', '00001', '00001', '11110'],
  Y: ['10001', '10001', '01010', '00100', '00100', '00100', '00100'],
  Z: ['11111', '00001', '00010', '00100', '01000', '10000', '11111']
};

const source = fs.readFileSync(inputFont);
if (source.length !== 1030 || source[0] !== 0xff || source[1] !== 0xff) {
  throw new Error(`${inputFont} is not the expected 1 KB Atari XEX font.`);
}

const font = Buffer.from(source);
const pixels = Array.from({ length: 16 }, () => new Uint8Array(256));
const text = 'HANS RZYGOL';
const pixelWidth = 15;
const letterGap = 3;
const wordGap = 12;
const totalWidth = 10 * pixelWidth + 8 * letterGap + wordGap;
let cursorX = Math.floor((256 - totalWidth) / 2);

for (const character of text) {
  if (character === ' ') {
    cursorX += wordGap;
    continue;
  }
  const glyph = LETTERS[character];
  glyph.forEach((row, y) => {
    [...row].forEach((bit, x) => {
      if (bit === '0') return;
      for (let dy = 0; dy < 2; dy++) {
        for (let dx = 0; dx < 3; dx++) pixels[1 + y * 2 + dy][cursorX + x * 3 + dx] = 1;
      }
    });
  });
  cursorX += pixelWidth + letterGap;
}

// These codes are used by the unchanged two-line author credit beneath the logo.
const authorCodes = new Set([
  0x00, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3a,
  0x40, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49, 0x4a,
  0x4b, 0x4c, 0x4d, 0x4e, 0x4f, 0x50, 0x51, 0x52, 0x53, 0x54, 0x55,
  0x56, 0x57, 0x58, 0x59, 0x5a, 0x5b, 0x64, 0x65, 0x70, 0x71
]);
const freeCodes = Array.from({ length: 128 }, (_, value) => value).filter(value => !authorCodes.has(value));
const tileMap = Buffer.alloc(64);
const tiles = new Map();

for (let tileY = 0; tileY < 2; tileY++) {
  for (let tileX = 0; tileX < 32; tileX++) {
    const rows = [];
    for (let y = 0; y < 8; y++) {
      let value = 0;
      for (let x = 0; x < 8; x++) value |= pixels[tileY * 8 + y][tileX * 8 + x] << (7 - x);
      rows.push(value);
    }
    const key = rows.join(',');
    if (!tiles.has(key)) {
      const code = freeCodes[tiles.size];
      if (code === undefined) throw new Error('The replacement logo needs too many character glyphs.');
      tiles.set(key, code);
      rows.forEach((value, y) => { font[6 + code * 8 + y] = value; });
    }
    tileMap[tileY * 32 + tileX] = tiles.get(key);
  }
}

fs.writeFileSync(outputFont, font);
fs.writeFileSync(outputMap, tileMap);
console.log(`Generated HANS RZYGOL logo using ${tiles.size} character glyphs.`);
