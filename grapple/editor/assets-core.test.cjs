/*
 * Browser-free checks for the Assets tab's core.
 *
 * The tab claims to show what the Atari draws. That is only worth anything if
 * its classifiers agree with grapple/atari/generate_assets.js, so this test
 * compares them against the real *-assets.bin the build produces. Run
 * grapple/atari/build.sh first.
 *
 *     node grapple/editor/assets-core.test.cjs
 *
 * To check an alternative hero, point both variables at the build that
 * run-character.sh produced for it:
 *
 *     PLAYER_SHEET=../design/PixelCharacterV1/player-pixelv1.png \
 *         BUILD_DIR=../atari/builds/player-pixelv1 \
 *         node grapple/editor/assets-core.test.cjs
 */
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const zlib = require("node:zlib");

const assets = require("./assets.js");
const ART = path.join(__dirname, "..", "bin", "assets");
const BUILD = process.env.BUILD_DIR || path.join(__dirname, "..", "atari");

// --- minimal PNG reader: bit depth 8, colour types 6 (RGBA) and 3 (palette),
// which is everything this project's art uses.
function decodeRgba(file) {
  const png = fs.readFileSync(file);
  let pos = 8;
  let width = 0;
  let height = 0;
  let colourType = 0;
  let palette = null;
  let alpha = null;
  const idat = [];
  while (pos < png.length) {
    const length = png.readUInt32BE(pos);
    const type = png.toString("ascii", pos + 4, pos + 8);
    const body = png.subarray(pos + 8, pos + 8 + length);
    if (type === "IHDR") {
      width = body.readUInt32BE(0);
      height = body.readUInt32BE(4);
      assert.equal(body[8], 8, `${file}: only bit depth 8 is supported`);
      colourType = body[9];
    } else if (type === "PLTE") palette = body;
    else if (type === "tRNS") alpha = body;
    else if (type === "IDAT") idat.push(body);
    else if (type === "IEND") break;
    pos += 12 + length;
  }
  const channels = colourType === 6 ? 4 : 1;
  const raw = zlib.inflateSync(Buffer.concat(idat));
  const stride = width * channels;
  const out = Buffer.alloc(height * stride);
  for (let y = 0; y < height; y += 1) {
    const filter = raw[y * (stride + 1)];
    const line = raw.subarray(y * (stride + 1) + 1, (y + 1) * (stride + 1));
    for (let x = 0; x < stride; x += 1) {
      const a = x >= channels ? out[y * stride + x - channels] : 0;
      const b = y > 0 ? out[(y - 1) * stride + x] : 0;
      const c = x >= channels && y > 0 ? out[(y - 1) * stride + x - channels] : 0;
      let value = line[x];
      if (filter === 1) value += a;
      else if (filter === 2) value += b;
      else if (filter === 3) value += (a + b) >> 1;
      else if (filter === 4) {
        const p = a + b - c;
        const pa = Math.abs(p - a);
        const pb = Math.abs(p - b);
        const pc = Math.abs(p - c);
        value += (pa <= pb && pa <= pc) ? a : (pb <= pc ? b : c);
      }
      out[y * stride + x] = value & 255;
    }
  }
  if (colourType === 6) return {width, height, data: out};
  const rgba = Buffer.alloc(width * height * 4);
  for (let i = 0; i < width * height; i += 1) {
    const index = out[i];
    rgba[i * 4] = palette[index * 3];
    rgba[i * 4 + 1] = palette[index * 3 + 1];
    rgba[i * 4 + 2] = palette[index * 3 + 2];
    rgba[i * 4 + 3] = alpha && index < alpha.length ? alpha[index] : 255;
  }
  return {width, height, data: rgba};
}

function sheetFor(key) {
  const file = key === "player" && process.env.PLAYER_SHEET ?
    path.resolve(process.env.PLAYER_SHEET) :
    path.join(ART, path.basename(assets.SHEETS[key].src));
  const {width, height, data} = decodeRgba(file);
  return assets.classifySheet(key, data, width, height);
}

/* The port doubles every source pixel to 32x32 before packing. */
function doubled(grid) {
  const out = Buffer.alloc(32 * 32);
  for (let y = 0; y < 32; y += 1) {
    for (let x = 0; x < 32; x += 1) {
      out[y * 32 + x] = grid[y >> 1][x >> 1];
    }
  }
  return out;
}

const built = name => fs.readFileSync(path.join(BUILD, name));
let checked = 0;

// --- the hero: every packed slot must match the build byte for byte --------
const player = sheetFor("player");
const playerBin = built("player-assets.bin");
assert.equal(playerBin.length, 16384);
assets.ATARI_SLOTS.forEach((frame, slot) => {
  const mine = doubled(player.frames[frame].grid);
  const theirs = playerBin.subarray(slot * 1024, slot * 1024 + 1024);
  assert.ok(mine.equals(theirs),
    `hero frame ${frame} (slot ${slot}) differs from player-assets.bin`);
  checked += 1;
});

// The hero's own palette entries, and no others. A four-region sheet adds
// skin; a two-colour one derives boots and never carries it.
const heroUsed = new Set(playerBin);
assert.deepEqual([...heroUsed].sort((a, b) => a - b),
  player.regions ? [0, 16, 17, 18, 20] : [0, 17, 18, 20]);

// --- the assets packed one frame at a time ---------------------------------
[["mover", "mover-assets.bin", [0]],
 ["thwomp", "thwomp-assets.bin", [0, 1, 2]],
 ["checkpoint", "checkpoint-assets.bin", [0, 1]]].forEach(([key, bin, frames]) => {
  const sheet = sheetFor(key);
  const data = built(bin);
  frames.forEach((frame, slot) => {
    const mine = doubled(sheet.frames[frame].grid);
    const theirs = data.subarray(slot * 1024, slot * 1024 + 1024);
    assert.ok(mine.equals(theirs), `${key} frame ${frame} differs from ${bin}`);
    checked += 1;
  });
});

// Spikes and cannons are stored as four rotations the generator walks out of
// one frame, so compare the colours rather than the layout.
[["spikes", "spike-assets.bin"], ["cannon", "cannon-assets.bin"],
 ["cannonball", "cannonball-assets.bin"]].forEach(([key, bin]) => {
  const mine = new Set();
  sheetFor(key).frames.forEach(f => f.grid.forEach(r => r.forEach(v => mine.add(v))));
  const theirs = new Set(built(bin));
  assert.deepEqual([...mine].sort(), [...theirs].sort(),
    `${key} uses different palette indices than ${bin}`);
  checked += 1;
});

// --- the workshop export must be valid pipeline input ----------------------
const sheets = {};
Object.keys(assets.SHEETS).forEach(key => { sheets[key] = sheetFor(key); });
assets.setSheets(sheets);

/*
 * Every character must survive a round trip: load its sheet, take the
 * workshop's baseline, export, and get the original markers back. That is
 * what makes "edit here, build there" more than a claim. A two-colour sheet
 * folds its derived boots back into the top; a four-region sheet keeps all
 * four markers.
 */
let painted = 0;
assets.CHARACTERS.forEach(entry => {
  const file = path.resolve(__dirname, entry.src);
  if (!fs.existsSync(file)) {
    throw new Error(`character sheet missing: ${entry.name} at ${file}`);
  }
  const source = decodeRgba(file);
  const sheet = assets.classifySheet("player", source.data,
    source.width, source.height);
  assets.setSheets(Object.assign({}, sheets, {player: sheet}));

  const exported = assets.exportSheetRGBA(assets.heroBaseline());
  assert.equal(exported.data.length, 80 * 64 * 4);
  let seen = 0;
  assets.ATARI_SLOTS.forEach(frame => {
    const ox = (frame % 5) * 16;
    const oy = Math.floor(frame / 5) * 16;
    for (let y = 0; y < 16; y += 1) {
      for (let x = 0; x < 16; x += 1) {
        const i = ((oy + y) * 80 + ox + x) * 4;
        const a = exported.data[i + 3] > 0;
        const b = source.data[i + 3] > 0;
        assert.equal(a, b,
          `${entry.name} frame ${frame} coverage differs at ${x},${y}`);
        if (!b) continue;
        seen += 1;
        const mine = [exported.data[i], exported.data[i + 1], exported.data[i + 2]];
        const theirs = [source.data[i], source.data[i + 1], source.data[i + 2]];
        assert.deepEqual(mine, theirs,
          `${entry.name} frame ${frame} marker differs at ${x},${y}`);
      }
    }
  });
  // Four-region alternatives may intentionally use a much slimmer silhouette
  // than the classic two-colour hero, but must still contain substantial art.
  assert.ok(seen > (sheet.regions ? 600 : 800),
    `${entry.name}: the round trip must see real artwork`);
  painted += seen;

  // A four-region sheet offers four pens; a two-colour one only two.
  assert.deepEqual(assets.penValues(),
    sheet.regions ? [1, 2, 3, 4, 0] : [1, 2, 0],
    `${entry.name}: wrong pen set`);
  checked += 1;
});

// The alternate follows the classic phases without copying its silhouette:
// it must stay substantially slimmer and retain a long, independently moving
// hair ribbon in every gameplay slot.
const classicSource = decodeRgba(path.resolve(__dirname,
  assets.CHARACTERS[0].src));
const alternateSource = decodeRgba(path.resolve(__dirname,
  assets.CHARACTERS[1].src));
assets.ATARI_SLOTS.forEach(frame => {
  const ox = (frame % 5) * 16;
  const oy = Math.floor(frame / 5) * 16;
  let classicPixels = 0;
  let alternatePixels = 0;
  const hair = [];
  const regions = new Set();
  for (let y = 0; y < 16; y += 1) {
    for (let x = 0; x < 16; x += 1) {
      const at = ((oy + y) * 80 + ox + x) * 4;
      if (classicSource.data[at + 3]) classicPixels += 1;
      if (!alternateSource.data[at + 3]) continue;
      alternatePixels += 1;
      const rgb = [alternateSource.data[at], alternateSource.data[at + 1],
        alternateSource.data[at + 2]].join(",");
      regions.add(rgb);
      if (rgb === "255,0,0") hair.push([x, y]);
    }
  }
  assert.ok(alternatePixels < classicPixels * .7,
    `alternate hero frame ${frame} is not substantially slimmer`);
  assert.equal(regions.size, 4,
    `alternate hero frame ${frame} must retain all four character regions`);
  const xs = hair.map(point => point[0]);
  const ys = hair.map(point => point[1]);
  const hairSpan = Math.max(Math.max(...xs) - Math.min(...xs) + 1,
    Math.max(...ys) - Math.min(...ys) + 1);
  assert.ok(hairSpan >= 7,
    `alternate hero frame ${frame} needs visibly long hair`);
});
checked += 1;

// Back to the sheet that built the binaries for the preset checks.
assets.setSheets(sheets);

// --- presets add to the poses, never subtract from them --------------------
assets.applyPreset("hero");
const base = {};
Object.entries(assets.state.workshop.frames).forEach(([k, g]) => {
  base[k] = g.map(r => r.slice());
});
["ponytail", "pack", "crest"].forEach(name => {
  assets.applyPreset(name);
  let removed = 0;
  let added = 0;
  Object.entries(assets.state.workshop.frames).forEach(([k, g]) => {
    g.forEach((row, y) => row.forEach((v, x) => {
      if (base[k][y][x] !== 0 && v !== base[k][y][x]) removed += 1;
      if (base[k][y][x] === 0 && v !== 0) added += 1;
    }));
  });
  assert.equal(removed, 0, `${name} disturbed the original poses`);
  assert.ok(added > 0, `${name} changed nothing`);
  // A preset must still export as legal pipeline input: two colours only.
  const out = assets.exportSheetRGBA(assets.state.workshop.frames);
  for (let i = 0; i < out.data.length; i += 4) {
    if (!out.data[i + 3]) continue;
    const pixel = [out.data[i], out.data[i + 1], out.data[i + 2]].join(",");
    assert.ok(["255,0,0", "255,255,255", "0,255,0", "0,0,255"].includes(pixel),
      `${name} exported an out-of-gamut pixel: ${pixel}`);
  }
});

console.log(`PASS: ${checked} sprite groups match the build, ` +
  `${assets.CHARACTERS.length} characters round-trip ${painted} pixels, ` +
  "presets stay additive and in gamut");
