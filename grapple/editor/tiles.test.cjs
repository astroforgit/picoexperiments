/*
 * Browser-free checks for the terrain tiles and hazards added by
 * grapple/design/make_tiles.py.
 *
 * Two things can go wrong here and neither shows up as a crash. The art can
 * drift out of the one-bit contract the depth tint relies on, and the tile ids
 * can drift apart across the four files that have to agree on them -- the
 * generator, the game's tileset, the stage's spawn table and the editor
 * palette. A tile registered in three of the four fails silently: it draws but
 * never collides, or spawns nothing, or is thrown away on load.
 *
 *     node grapple/editor/tiles.test.cjs
 */
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const zlib = require("node:zlib");

const ROOT = path.join(__dirname, "..");
const ART = path.join(ROOT, "bin", "assets");

const WALL_TILES = [19, 20, 21, 22, 23];
const HAZARD_TILES = { 24: "sawblade", 25: "flamevent" };

// --- minimal PNG reader, RGBA and palette, bit depth 8: the same subset the
// rest of this project's art uses.
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
      const left = x >= channels ? out[y * stride + x - channels] : 0;
      const up = y > 0 ? out[(y - 1) * stride + x] : 0;
      const upLeft = x >= channels && y > 0
        ? out[(y - 1) * stride + x - channels] : 0;
      let value = line[x];
      if (filter === 1) value += left;
      else if (filter === 2) value += up;
      else if (filter === 3) value += Math.floor((left + up) / 2);
      else if (filter === 4) {
        const p = left + up - upLeft;
        const dl = Math.abs(p - left);
        const du = Math.abs(p - up);
        const dul = Math.abs(p - upLeft);
        value += dl <= du && dl <= dul ? left : du <= dul ? up : upLeft;
      }
      out[y * stride + x] = value & 0xff;
    }
  }
  const data = Buffer.alloc(width * height * 4);
  for (let i = 0; i < width * height; i += 1) {
    if (channels === 4) {
      out.copy(data, i * 4, i * 4, i * 4 + 4);
    } else {
      const index = out[i];
      data[i * 4] = palette[index * 3];
      data[i * 4 + 1] = palette[index * 3 + 1];
      data[i * 4 + 2] = palette[index * 3 + 2];
      data[i * 4 + 3] = alpha && index < alpha.length ? alpha[index] : 255;
    }
  }
  return { width, height, data };
}

/* Classify one pixel as the art's three legal states. The tilemap is tinted by
 * depth at runtime, so a pixel carrying a colour of its own would come out
 * wrong in every zone but the one it was drawn for. */
function classify(image, x, y) {
  const i = (y * image.width + x) * 4;
  const [r, g, b, a] = image.data.subarray(i, i + 4);
  if (!a) return "clear";
  if (!r && !g && !b) return "fill";
  if (r === 255 && g === 255 && b === 255) return "ink";
  return `${r},${g},${b}`;
}

function tile(image, index, cols = 8) {
  const ox = (index % cols) * 16;
  const oy = Math.floor(index / cols) * 16;
  const cells = [];
  for (let y = 0; y < 16; y += 1) {
    cells.push([]);
    for (let x = 0; x < 16; x += 1) cells[y].push(classify(image, ox + x, oy + y));
  }
  return cells;
}

const world = decodeRgba(path.join(ART, "world.png"));
assert.equal(world.width, 128, "world.png must stay eight tiles wide");
assert.equal(world.height, 64, "world.png should be four tile rows");

let inked = 0;
for (const index of [...WALL_TILES, ...Object.keys(HAZARD_TILES).map(Number)]) {
  const cells = tile(world, index);
  const flat = cells.flat();
  flat.forEach(state => assert.ok(["fill", "ink", "clear"].includes(state),
    `tile ${index} has an out-of-gamut pixel: ${state}`));
  const ink = flat.filter(s => s === "ink").length;
  assert.ok(ink > 0, `tile ${index} carries no decoration`);
  inked += ink;

  // Terrain fills its cell edge to edge; a hole in a wall tile shows as a gap
  // in the silhouette that the outline filter then draws an edge around.
  if (WALL_TILES.includes(index)) {
    assert.ok(!flat.includes("clear"), `wall tile ${index} has transparent pixels`);
  }
}

/* The keyline is the whole readability budget of a 16x16 sprite: white exactly
 * where a transparent pixel touches the fill, and nowhere else. Anything looser
 * and the silhouette stops separating from the cave behind it. */
let frames = 0;
for (const [index, name] of Object.entries(HAZARD_TILES)) {
  const sheet = decodeRgba(path.join(ART, `${name}.png`));
  assert.equal(sheet.height, 16, `${name}.png should be one row of frames`);
  assert.equal(sheet.width % 16, 0, `${name}.png is not a whole number of frames`);
  const count = sheet.width / 16;
  assert.ok(count >= 2, `${name}.png has nothing to animate`);

  const seen = new Set();
  for (let frame = 0; frame < count; frame += 1) {
    const cells = tile(sheet, frame, count);
    for (let y = 0; y < 16; y += 1) {
      for (let x = 0; x < 16; x += 1) {
        const state = cells[y][x];
        assert.ok(["fill", "ink", "clear"].includes(state),
          `${name} frame ${frame} has an out-of-gamut pixel: ${state}`);
        if (state === "fill") continue;
        const touchesFill = [[x - 1, y], [x + 1, y], [x, y - 1], [x, y + 1]]
          .some(([nx, ny]) => nx >= 0 && nx < 16 && ny >= 0 && ny < 16 &&
            cells[ny][nx] === "fill");
        assert.equal(state === "ink", touchesFill,
          `${name} frame ${frame} breaks the keyline at ${x},${y}`);
      }
    }
    seen.add(cells.flat().join(""));
    frames += 1;
  }
  assert.equal(seen.size, count, `${name}.png repeats a frame`);

  // The tile the level designer places has to be one of the sprite's own
  // frames, or the editor shows something the game never draws.
  const placed = tile(world, Number(index)).flat().join("");
  const sheetFrames = Array.from({ length: count },
    (_, f) => tile(sheet, f, count).flat().join(""));
  assert.ok(sheetFrames.includes(placed),
    `tile ${index} does not match any ${name} frame`);
}

// --- the four files that have to agree on the ids.
function read(file) {
  return fs.readFileSync(path.join(ROOT, file), "utf8");
}

const collision = read("src/assets.ts")
  .match(/collisionIndices:\s*\[([^\]]*)\]/)[1]
  .split(",").map(n => Number(n.trim()));
WALL_TILES.forEach(id => assert.ok(collision.includes(id),
  `tile ${id} is drawn as terrain but does not collide`));
Object.keys(HAZARD_TILES).forEach(id => assert.ok(!collision.includes(Number(id)),
  `hazard tile ${id} must not be solid terrain`));

const stages = read("src/stages.ts");
Object.keys(HAZARD_TILES).forEach(id => assert.match(stages,
  new RegExp(`^\\s*${id}:\\s*\\(x, y, tile\\)`, "m"),
  `tile ${id} spawns nothing`));
WALL_TILES.forEach(id => assert.doesNotMatch(stages,
  new RegExp(`^\\s*${id}:\\s*\\(x, y, tile\\)`, "m"),
  `terrain tile ${id} should not spawn an entity`));

const editor = read("editor/editor.js");
const declared = new Set(Array.from(editor.matchAll(/\{id:\s*(-?\d+),/g),
  m => Number(m[1])));
[...WALL_TILES, ...Object.keys(HAZARD_TILES).map(Number)].forEach(id => {
  assert.ok(declared.has(id), `tile ${id} is missing from the editor palette`);
});
const browserOnly = editor
  .match(/BROWSER_ONLY_TILE_IDS = new Set\(\[([^\]]*)\]/)[1]
  .split(",").map(n => Number(n.trim()));
[...WALL_TILES, ...Object.keys(HAZARD_TILES).map(Number)].forEach(id => {
  assert.ok(browserOnly.includes(id),
    `tile ${id} is not flagged browser-only, so the editor will offer it to ` +
    "the Atari build, which has no art for it");
});

console.log(`PASS: ${WALL_TILES.length} terrain tiles and ` +
  `${Object.keys(HAZARD_TILES).length} hazards over ${frames} frames ` +
  `(${inked} decoration pixels), ids agree across generator, game and editor`);
