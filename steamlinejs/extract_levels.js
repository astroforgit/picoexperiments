#!/usr/bin/env node
// Streamline level extractor
// Reads steamline.js, finds the 5 base64-encoded level groups,
// base64-decodes + zlib-inflates + Haxe-unserializes them, then
// prints each level as ASCII art and writes JSON.

const fs = require('fs');
const path = require('path');
const zlib = require('zlib');

// --- Locate the JS bundle ---
const JS_PATH = path.join(__dirname, 'steamline.js');
const OUT_DIR = path.join(__dirname, 'extracted');
if (!fs.existsSync(OUT_DIR)) fs.mkdirSync(OUT_DIR, { recursive: true });

const src = fs.readFileSync(JS_PATH, 'utf8');

// --- Extract the 5 base64 group strings (cases 0..4) ---
// Match: case N:c="<base64>";break;
const groupRe = /case\s+(\d+):c="([A-Za-z0-9+/=]+)";/g;
const groups = {};
let m;
while ((m = groupRe.exec(src)) !== null) {
    const idx = parseInt(m[1], 10);
    groups[idx] = m[2];
}

const groupNames = ['Basics', 'Force', 'Trials', 'Dual', 'Scale'];
console.log('Found groups:', Object.keys(groups).map(k => `${k}=${groupNames[k]}`).join(', '));

// --- Minimal Haxe Unserializer ---
class HaxeUnserializer {
    constructor(buf) {
        this.buf = buf;
        this.pos = 0;
        this.length = buf.length;
        this.cache = [];   // object/array references
        this.scache = [];  // string references
    }
    unserializeEnumByIdx(enumName, idx) { return enumName + '#' + idx; }
    unserializeEnumBody(ctor) {
        if (this.get(this.pos++) !== 58) throw new Error('Invalid enum body');
        const argc = this.readDigits();
        const args = [];
        for (let i = 0; i < argc; i++) args.push(this.unserialize());
        return { __enum: ctor.split('#')[0], name: ctor.split('#').slice(1).join('#') || ctor, args };
    }
    get(i) { return this.buf.charCodeAt(i); }
    readDigits() {
        let a = 0, neg = false, c = this.pos;
        for (;;) {
            const d = this.buf.charCodeAt(this.pos);
            if (d !== d) break; // NaN
            if (d === 45) {     // '-'
                if (this.pos !== c) break;
                neg = true;
            } else if (d < 48 || d > 57) break;
            else a = a * 10 + (d - 48);
            this.pos++;
        }
        if (neg) a *= -1;
        return a;
    }
    readString() {
        // 'y' is handled separately. Here we just read the length-prefixed URI-encoded string body.
        const len = this.readDigits();
        if (this.get(this.pos++) !== 58) throw new Error('Invalid string length marker');
        if (this.length - this.pos < len) throw new Error('Invalid string length');
        const s = this.buf.substr(this.pos, len);
        this.pos += len;
        return decodeURIComponent(s.split('+').join(' '));
    }
    unserialize() {
        const code = this.get(this.pos++);
        switch (code) {
            case 110: return null;                          // 'n'
            case 116: return true;                          // 't'
            case 102: return false;                         // 'f'
            case 122: return 0;                             // 'z'
            case 105: return this.readDigits();             // 'i'
            case 100: {                                    // 'd' float
                const start = this.pos;
                for (;;) {
                    const b = this.buf.charCodeAt(this.pos);
                    if ((b >= 43 && b < 58) || b === 101 || b === 69) this.pos++;
                    else break;
                }
                return parseFloat(this.buf.substr(start, this.pos - start));
            }
            case 121: {                                    // 'y' string
                const s = this.readString();
                this.scache.push(s);
                return s;
            }
            case 97: {                                     // 'a' array
                const a = [];
                for (;;) {
                    const b = this.buf.charCodeAt(this.pos);
                    if (b === 104) { this.pos++; break; }   // 'h' end
                    if (b === 117) {                         // 'u' null-fill
                        this.pos++;
                        const skip = this.readDigits();
                        a.length = a.length + skip;
                        a[a.length - 1] = null;
                    } else {
                        a.push(this.unserialize());
                    }
                }
                return a;
            }
            case 104: return null;                          // 'h' stray (shouldn't happen at top)
            case 111: {                                    // 'o' object
                const o = {};
                for (;;) {
                    if (this.pos >= this.length) throw new Error('Invalid object');
                    if (this.buf.charCodeAt(this.pos) === 103) { this.pos++; break; } // 'g' end
                    const k = this.unserialize();
                    if (typeof k !== 'string') throw new Error('Invalid object key');
                    o[k] = this.unserialize();
                }
                return o;
            }
            case 82: {                                     // 'R' string reference
                const idx = this.readDigits();
                if (idx < 0 || idx >= this.scache.length) throw new Error('Invalid string reference');
                return this.scache[idx];
            }
            case 114: {                                    // 'r' object reference
                const idx = this.readDigits();
                if (idx < 0 || idx >= this.cache.length) throw new Error('Invalid reference');
                return this.cache[idx];
            }
            case 119: {                                    // 'w' enum (with name)
                const enumName = this.unserialize();
                const ctor = this.unserialize();
                if (this.get(this.pos++) !== 58) throw new Error('Invalid enum format'); // ':'
                const argc = this.readDigits();
                const args = [];
                for (let i = 0; i < argc; i++) args.push(this.unserialize());
                return { __enum: enumName, name: ctor, args };
            }
            case 106: {                                    // 'j' enum (with index)
                const enumName = this.unserialize();
                this.pos++; // ':'
                const idx = this.readDigits();
                const ctor = this.unserializeEnumByIdx(enumName, idx);
                const v = this.unserializeEnumBody(ctor);
                return v;
            }
            case 113: {                                    // 'q' IntMap
                const m = new Map();
                while (this.buf.charCodeAt(this.pos) !== 104) {
                    const k = this.readDigits();
                    m.set(k, this.unserialize());
                    if (this.buf.charCodeAt(this.pos) === 58) this.pos++; // ':'
                }
                this.pos++; // 'h'
                return m;
            }
            case 99: {                                     // 'c' class instance
                const className = this.unserialize();
                const o = { __class: className };
                for (;;) {
                    if (this.pos >= this.length) throw new Error('Invalid class object');
                    if (this.buf.charCodeAt(this.pos) === 103) { this.pos++; break; } // 'g' end
                    const k = this.unserialize();
                    if (typeof k !== 'string') throw new Error('Invalid class field key');
                    o[k] = this.unserialize();
                }
                return o;
            }
            default:
                throw new Error(`Unknown opcode ${code} (${String.fromCharCode(code)}) at ${this.pos - 1}`);
        }
    }
}

function decodeGroup(b64) {
    // base64 decode -> zlib inflate (auto-handle zlib/raw/gzip header) -> UTF-8 string
    const raw = Buffer.from(b64, 'base64');
    let inflated;
    for (const fn of [zlib.inflateSync, zlib.inflateRawSync, zlib.gunzipSync, zlib.brotliDecompressSync]) {
        try { inflated = fn(raw); break; } catch (e) { /* try next */ }
    }
    if (!inflated) throw new Error('all inflate attempts failed');
    return new HaxeUnserializer(inflated.toString('utf8')).unserialize();
}

// --- Pretty-print one level as ASCII art ---
const TILE = {
    'EMPTY':  '.',
    'START':  '@',
    'END':    'E',
    'WALL':   '#',
    'PAUSE':  'P',
    'RESET':  'R',
    'TRAP':   'X',
    'PORTAL': '%',
    'FORCER': '*',         // direction encoded separately
    'LOCK':   'L',
    'KEY':    'K',
};

function levelToAscii(level) {
    // level.data is a 2D array: level.data[x][y] = { __enum, name, args }
    const w = level.getWidth ? level.getWidth() : level.data.length;
    const h = level.getHeight ? level.getHeight() : level.data[0].length;
    const rows = [];
    for (let y = 0; y < h; y++) {
        let row = '';
        for (let x = 0; x < w; x++) {
            const cell = level.data[x][y];
            const name = cell.name;
            let ch = TILE[name] || '?';
            if (name === 'FORCER' && Array.isArray(cell.args) && cell.args[0]) {
                const d = cell.args[0].name;
                ch = d === 'UP' ? '^' : d === 'DOWN' ? 'v' :
                     d === 'LEFT' ? '<' : d === 'RIGHT' ? '>' : '*';
            }
            if (x > 0) row += ' ';
            row += ch;
        }
        rows.push(row);
    }
    return rows.join('\n');
}

// --- Main ---
const summary = {};
let totalLevels = 0;

for (const idx of Object.keys(groups).map(Number).sort((a, b) => a - b)) {
    const name = groupNames[idx] || `Group ${idx}`;
    console.log(`\n=== Group ${idx} (${name}) ===`);
    let groupData;
    try {
        groupData = decodeGroup(groups[idx]);
    } catch (e) {
        console.error(`  ! Failed to decode group ${idx}: ${e.message}`);
        continue;
    }
    // groupData is an array of levels
    console.log(`  ${groupData.length} levels`);
    summary[name] = [];
    const outFile = path.join(OUT_DIR, `group_${idx}_${name.toLowerCase()}.txt`);
    const out = [];
    out.push(`# Streamline - Group ${idx}: ${name} (${groupData.length} levels)\n`);
    for (let i = 0; i < groupData.length; i++) {
        const lv = groupData[i];
        out.push(`\n--- Level ${i} ---`);
        out.push(levelToAscii(lv));
        summary[name].push(levelToAscii(lv).split('\n').map(r => r.replace(/ /g, '')).join('\n'));
        totalLevels++;
    }
    fs.writeFileSync(outFile, out.join('\n'), 'utf8');
    console.log(`  -> ${outFile}`);
    // Print a preview
    for (let i = 0; i < Math.min(3, groupData.length); i++) {
        console.log(`\n  Level ${i}:`);
        console.log(levelToAscii(groupData[i]).split('\n').map(l => '    ' + l).join('\n'));
    }
}

fs.writeFileSync(
    path.join(OUT_DIR, 'all_levels.json'),
    JSON.stringify(summary, null, 2)
);

console.log(`\nDone! ${totalLevels} levels extracted to ${OUT_DIR}`);
