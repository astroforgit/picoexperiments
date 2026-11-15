#!/usr/bin/env node
'use strict';

// Checks bimbaj.xex: segment structure, RUN address, and that the INIT-staged
// chunks put every level and story page from bimbaj.json under the OS ROM.
const fs = require('fs');
const path = require('path');
const format = require('./bimbaj-format');

const root = __dirname;
const project = JSON.parse(fs.readFileSync(path.join(root, 'bimbaj.json'), 'utf8'));
const compiled = format.compile(project);
if (compiled.errors.length) throw new Error(compiled.errors.map(error => error.message).join('\n'));

const labels = {};
for (const line of fs.readFileSync(path.join(root, 'bimbaj.lab'), 'utf8').split('\n')) {
    const parts = line.trim().split(/\s+/);
    if (parts.length === 3 && parts[0] === '00') labels[parts[2].toLowerCase()] = parseInt(parts[1], 16);
}

const xex = fs.readFileSync(path.join(root, 'bimbaj.xex'));
if (xex.length < 8 || xex[0] !== 0xff || xex[1] !== 0xff) {
    throw new Error('Output is not an Atari segmented executable');
}

// Load like DOS: main memory is flat, the bank is RAM under $C000-$FFFF.
const memory = new Uint8Array(0x10000);
const bank = new Uint8Array(0x10000);
let offset = 2;
let runAddress = null;
let segmentCount = 0;
let initCount = 0;
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
    if (start >= 0xc000) throw new Error(`Segment at $${start.toString(16)} would load into the OS ROM`);
    memory.set(xex.subarray(offset, offset + length), start);
    offset += length;
    segmentCount++;
    if (start <= 0x02e2 && end >= 0x02e3) {
        const init = memory[0x02e2] | (memory[0x02e3] << 8);
        if (init !== labels.bank_loader) throw new Error(`Unexpected INIT address $${init.toString(16)}`);
        const stage = labels.bank_stage;
        const destination = memory[stage] | (memory[stage + 1] << 8);
        const size = memory[stage + 2] | (memory[stage + 3] << 8);
        const windowOk = format.BANK_WINDOWS.some(([low, high]) => destination >= low && destination + size <= high);
        if (!windowOk) throw new Error(`Bank chunk $${destination.toString(16)}+${size} is outside the ROM windows`);
        bank.set(memory.subarray(stage + 4, stage + 4 + size), destination);
        memory.fill(0, stage, stage + 4 + size);
        initCount++;
    }
    if (start <= 0x02e0 && end >= 0x02e1) runAddress = memory[0x02e0] | (memory[0x02e1] << 8);
}

if (offset !== xex.length) throw new Error('Trailing or malformed XEX data');
if (runAddress !== 0x2000) {
    throw new Error(`Expected RUN address $2000, got ${runAddress === null ? 'none' : '$' + runAddress.toString(16)}`);
}
if (!initCount) throw new Error('No bank INIT segments found');

const word = (lo, hi, index) => memory[labels[lo] + index] | (memory[labels[hi] + index] << 8);
const same = (address, bytes, what) => {
    const actual = [...bank.subarray(address, address + bytes.length)];
    if (actual.some((value, index) => value !== bytes[index])) throw new Error(`${what} differs under the ROM`);
};
compiled.levels.forEach((level, index) => {
    same(word('level_ptr_lo', 'level_ptr_hi', index), level.bytes, `Level ${index + 1} (${level.name})`);
});
const pages = compiled.breaks.flatMap(pause => pause.pages);
pages.forEach((page, index) => same(word('story_page_lo', 'story_page_hi', index), page.bytes, `Story page ${index + 1}`));
compiled.breaks.forEach((pause, index) => {
    if (memory[labels.story_break_level + index] !== pause.after) throw new Error(`Story break ${index + 1} level differs`);
});

console.log(`Verified: ${compiled.levels.length} levels, ${pages.length} story page(s) in ${compiled.breaks.length} break(s), ` +
    `${compiled.used}/${compiled.capacity} bank bytes, ${segmentCount} XEX segments, RUN $${runAddress.toString(16)}, ${xex.length} bytes.`);
