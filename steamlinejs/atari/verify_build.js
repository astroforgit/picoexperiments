#!/usr/bin/env node
'use strict';

const fs = require('fs');
const path = require('path');

const root = __dirname;
const sourceLevels = JSON.parse(
    fs.readFileSync(path.join(root, '..', 'orggame', 'extracted', 'all_levels.json'), 'utf8'),
);
const expectedCounts = { Basics: 16, Force: 12, Trials: 8, Dual: 12, Scale: 8 };

let total = 0;
for (const [group, expected] of Object.entries(expectedCounts)) {
    const actual = sourceLevels[group] ? sourceLevels[group].length : 0;
    if (actual !== expected) throw new Error(`${group}: expected ${expected} levels, found ${actual}`);
    total += actual;
}
if (total !== 56) throw new Error(`Expected 56 levels, found ${total}`);

const include = fs.readFileSync(path.join(root, 'levels.inc'), 'utf8');
const labels = [...include.matchAll(/^level_(\d\d) /gm)].map(match => Number(match[1]));
if (labels.length !== 56 || labels.some((value, index) => value !== index)) {
    throw new Error('levels.inc does not contain the expected level_00..level_55 sequence');
}

const xex = fs.readFileSync(path.join(root, 'streamline-vbxe.xex'));
if (xex.length < 8 || xex[0] !== 0xff || xex[1] !== 0xff) {
    throw new Error('Output is not an Atari segmented executable');
}

let offset = 2;
let runAddress = null;
let segmentCount = 0;
while (offset + 4 <= xex.length) {
    let start = xex[offset] | (xex[offset + 1] << 8);
    offset += 2;
    if (start === 0xffff) {
        if (offset + 2 > xex.length) throw new Error('Truncated XEX marker');
        start = xex[offset] | (xex[offset + 1] << 8);
        offset += 2;
    }
    if (offset + 2 > xex.length) throw new Error('Truncated XEX segment');
    const end = xex[offset] | (xex[offset + 1] << 8);
    offset += 2;
    if (end < start) throw new Error(`Invalid XEX segment ${start.toString(16)}-${end.toString(16)}`);
    const length = end - start + 1;
    if (offset + length > xex.length) throw new Error('XEX segment extends beyond the file');
    if (start <= 0x02e0 && end >= 0x02e1) {
        const index = offset + (0x02e0 - start);
        runAddress = xex[index] | (xex[index + 1] << 8);
    }
    offset += length;
    segmentCount++;
}

if (offset !== xex.length) throw new Error('Trailing or malformed XEX data');
if (runAddress !== 0x2000) {
    throw new Error(`Expected RUN address $2000, got ${runAddress === null ? 'none' : '$' + runAddress.toString(16)}`);
}

console.log(`Verified: ${total} levels, ${segmentCount} XEX segments, RUN $${runAddress.toString(16)}, ${xex.length} bytes.`);
