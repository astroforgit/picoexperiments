"use strict";

/*
 * Assets tab: every animation the VBXE game ships, shown in the colours the
 * Atari actually displays, plus a workshop for designing a replacement hero.
 *
 * The colour classifiers below mirror grapple/atari/generate_assets.js exactly.
 * That is the point of the tab: what you see here is what the port draws, so a
 * sprite can be judged before spending a build on it.
 */
const GrappleAssets = (() => {

const SHEETS = {
  player: {src: "../bin/assets/player.png", fw: 16, fh: 16, cols: 5},
  mover: {src: "../bin/assets/mover.png", fw: 16, fh: 16, cols: 1},
  spikes: {src: "../bin/assets/spikes.png", fw: 16, fh: 16, cols: 1},
  cannon: {src: "../bin/assets/cannon.png", fw: 16, fh: 16, cols: 1},
  cannonball: {src: "../bin/assets/cannonball.png", fw: 10, fh: 10, cols: 1},
  thwomp: {src: "../bin/assets/thwomp.png", fw: 16, fh: 16, cols: 3},
  checkpoint: {src: "../bin/assets/checkpoint.png", fw: 16, fh: 16, cols: 2}
};

// VBXE palette entries from grapple-vbxe.asm. Index 20/17/18 belong to the
// hero alone; 21 and 22 are shared by every other asset.
const VBXE = {
  0: null,
  16: "#ffb499",   // hero skin, only used by four-region sheets
  17: "#28bcd4",   // hero suit
  18: "#565c88",   // hero boots
  19: "#ff0000",   // thwomp marking
  20: "#ff5628",   // hero hair
  21: "#ffffff",   // shared white
  22: "#000000"    // shared dark
};

const PLAYER_BOOT_ROWS = 3;

/* Region markers, matching playerMarker() in generate_assets.js. */
function playerMarker(r, g, b) {
  if (r > 240 && g < 16 && b < 16) return 20;   // hair
  if (g > 240 && r < 16 && b < 16) return 18;   // legs
  if (b > 240 && r < 16 && g < 16) return 16;   // skin
  if (r > 240 && g > 240 && b > 240) return 17; // top
  return 0;
}

/*
 * One classifier per asset, each matching its branch in generate_assets.js.
 * `row` and `bottom` are the source-pixel row and the frame's lowest opaque
 * row, which is how the port decides where the hero's boots start.
 */
const CLASSIFY = {
  // Two-colour sheets date from before the green and blue region markers, so
  // they keep the older reading where the lowest rows become boots.
  player(r, g, b, a, row, bottom, regions) {
    if (a === 0) return 0;
    if (regions) return playerMarker(r, g, b);
    if (r > 240 && g < 16) return 20;
    return row >= bottom - (PLAYER_BOOT_ROWS - 1) ? 18 : 17;
  },
  mover(r, g, b, a) { return a === 0 ? 0 : (r > 200 ? 21 : 22); },
  spikes(r, g, b, a) { return a === 0 ? 0 : 21; },
  cannon(r, g, b, a) { return a === 0 ? 0 : (r > 200 ? 21 : 22); },
  cannonball(r, g, b, a) { return a === 0 ? 0 : (r > 200 ? 21 : 22); },
  thwomp(r, g, b, a) {
    if (a === 0) return 0;
    if (r > 200 && g < 80 && b < 80) return 19;
    return r + g + b > 600 ? 21 : 22;
  },
  checkpoint(r, g, b, a) { return a === 0 ? 0 : 21; }
};

/*
 * Selectable heroes. Each carries the palette generate_assets.js emits for
 * its sheet, so the tab shows what that character looks like on the Atari
 * rather than what the default one does. Mirrors PLAYER_PALETTES there.
 */
const CHARACTERS = [
  {
    name: "Classic hero",
    src: "../bin/assets/player.png",
    // The browser game's own two colours; top and legs share the white, so
    // the derived boots stay invisible.
    palette: {16: "#ffffff", 17: "#ffffff", 18: "#ffffff", 20: "#ff0000"}
  },
  {
    name: "PixelCharacterV1 · flowing hair",
    src: "../design/PixelCharacterV1/player-pixelv1.png",
    palette: {16: "#ffb499", 17: "#e2e2e2", 18: "#405230", 20: "#4894ff"}
  }
];

// Source frame order the port packs into player-assets.bin. The slot index is
// what choose_hero_frame stores in hero_frame.
const ATARI_SLOTS = [0, 1, 2, 3, 5, 6, 7, 8, 9, 11, 12, 13, 14, 15, 17, 18];

const CATALOGUE = [
  {
    key: "player", sheet: "player", title: "Hero",
    blurb: null,   // set per sheet, since the two kinds read differently
    bin: "player-assets.bin", bytes: 16384,
    animations: [
      {name: "idle", frames: [0, 1, 2, 3], fps: 12},
      {name: "run", frames: [5, 6, 7, 8, 9], fps: 12},
      {name: "jump", frames: [11, 12], fps: 12},
      {name: "fall", frames: [13, 14], fps: 12},
      {name: "grapple_horiz", frames: [17, 18], fps: 16},
      {name: "dead", frames: [15], fps: 8}
    ]
  },
  {
    key: "mover", sheet: "mover", title: "Moving brick",
    blurb: "One frame. The port animates position, never artwork.",
    bin: "mover-assets.bin", bytes: 1024,
    animations: [{name: "static", frames: [0], fps: 0}]
  },
  {
    key: "spikes", sheet: "spikes", title: "Spikes",
    blurb: "One frame, never animated. The port walks the source at 90 degrees " +
      "to build all four rotations instead of storing them.",
    bin: "spike-assets.bin", bytes: 4096,
    animations: [{name: "static", frames: [0], fps: 0}]
  },
  {
    key: "cannon", sheet: "cannon", title: "Cannon",
    blurb: "One frame, rotated the same way as spikes.",
    bin: "cannon-assets.bin", bytes: 4096,
    animations: [{name: "static", frames: [0], fps: 0}]
  },
  {
    key: "cannonball", sheet: "cannonball", title: "Cannonball",
    blurb: "A 10x10 source, drawn as 20x20 and padded to a page.",
    bin: "cannonball-assets.bin", bytes: 512,
    animations: [{name: "static", frames: [0], fps: 0}]
  },
  {
    key: "thwomp", sheet: "thwomp", title: "Thwomp",
    blurb: "Three frames chosen by state, not by a timer: asleep, woken, attacking.",
    bin: "thwomp-assets.bin", bytes: 3072,
    animations: [{name: "states", frames: [0, 1, 2], fps: 2}]
  },
  {
    key: "checkpoint", sheet: "checkpoint", title: "Checkpoint",
    blurb: "Two frames: flag low before activation, high after.",
    bin: "checkpoint-assets.bin", bytes: 2048,
    animations: [{name: "low / high", frames: [0, 1], fps: 1.5}]
  }
];

// Workshop palette. A new hero is authored in the same two source colours the
// pipeline already understands, so a finished sheet needs no generator change.
// Pen values are regions, not colours; the character's palette renders them.
const PEN_REGION = {1: 20, 2: 17, 3: 18, 4: 16};
const PEN_LABEL = {1: "Hair", 2: "Top", 3: "Legs", 4: "Skin", 0: "Erase"};
const PEN_EXPORT = {
  1: [255, 0, 0, 255],       // hair
  2: [255, 255, 255, 255],   // top
  3: [0, 255, 0, 255],       // legs
  4: [0, 0, 255, 255]        // skin
};

const state = {
  open: false,
  loaded: false,
  vbxeColours: true,
  sheets: {},          // key -> {frames: [grid], w, h}
  workshop: null,      // {frames: {index -> grid}}
  penValue: 1,
  character: 0,
  editingFrame: 0,
  presets: {}
};

// ---------------------------------------------------------------- loading

function loadImage(src) {
  return new Promise((resolve, reject) => {
    const image = new Image();
    image.onload = () => resolve(image);
    image.onerror = () => reject(new Error(`could not load ${src}`));
    image.src = src;
  });
}

/*
 * Slice raw RGBA into per-frame grids of VBXE palette indices. Kept free of
 * the DOM so the same code can be checked against the real build output.
 */
function classifySheet(key, data, width, height) {
  const def = SHEETS[key];
  const classify = CLASSIFY[key];
  const image = {width, height};
  const perRow = Math.max(1, Math.floor(image.width / def.fw));
  const count = perRow * Math.max(1, Math.floor(image.height / def.fh));
  // A sheet that uses the green or blue markers describes its own regions.
  let regions = false;
  if (key === "player") {
    for (let at = 0; at < data.length && !regions; at += 4) {
      if (!data[at + 3]) continue;
      const marker = playerMarker(data[at], data[at + 1], data[at + 2]);
      regions = marker === 18 || marker === 16;
    }
  }
  const frames = [];
  for (let index = 0; index < count; index += 1) {
    const ox = (index % perRow) * def.fw;
    const oy = Math.floor(index / perRow) * def.fh;
    let bottom = -1;
    for (let y = 0; y < def.fh; y += 1) {
      for (let x = 0; x < def.fw; x += 1) {
        if (data[((oy + y) * image.width + ox + x) * 4 + 3] !== 0) bottom = y;
      }
    }
    const grid = [];
    for (let y = 0; y < def.fh; y += 1) {
      const row = [];
      for (let x = 0; x < def.fw; x += 1) {
        const at = ((oy + y) * image.width + ox + x) * 4;
        row.push(classify(data[at], data[at + 1], data[at + 2], data[at + 3],
          y, bottom, regions));
      }
      grid.push(row);
    }
    frames.push({grid, empty: bottom < 0});
  }
  return {frames, fw: def.fw, fh: def.fh, regions};
}

/* DOM wrapper: pull pixels off an <img>, then classify them. */
function sliceSheet(key, image) {
  const canvas = document.createElement("canvas");
  canvas.width = image.width;
  canvas.height = image.height;
  const context = canvas.getContext("2d", {willReadFrequently: true});
  context.drawImage(image, 0, 0);
  const data = context.getImageData(0, 0, image.width, image.height).data;
  return classifySheet(key, data, image.width, image.height);
}

function character() { return CHARACTERS[state.character]; }

async function loadAll() {
  const keys = Object.keys(SHEETS);
  const sources = keys.map(key =>
    key === "player" ? character().src : SHEETS[key].src);
  const images = await Promise.all(sources.map(loadImage));
  keys.forEach((key, index) => {
    state.sheets[key] = sliceSheet(key, images[index]);
  });
  state.loaded = true;
}

/* Swap the hero sheet alone; the other assets do not change with her. */
async function loadCharacter() {
  const image = await loadImage(character().src);
  state.sheets.player = sliceSheet("player", image);
  applyPreset(state.workshop?.preset || "hero");
}

// ---------------------------------------------------------------- drawing

function paintGrid(canvas, grid, scale, colours) {
  const height = grid.length;
  const width = grid[0].length;
  canvas.width = width * scale;
  canvas.height = height * scale;
  const context = canvas.getContext("2d");
  context.imageSmoothingEnabled = false;
  context.clearRect(0, 0, canvas.width, canvas.height);
  for (let y = 0; y < height; y += 1) {
    for (let x = 0; x < width; x += 1) {
      const colour = colours[grid[y][x]];
      if (!colour) continue;
      context.fillStyle = colour;
      context.fillRect(x * scale, y * scale, scale, scale);
    }
  }
}

/* Browser view keeps the original two-colour art; VBXE view shows the port. */
function coloursFor(key) {
  if (state.vbxeColours) {
    return key === "player" ? Object.assign({}, VBXE, character().palette) : VBXE;
  }
  // Source view: the markers as they are actually painted in the sheet.
  return {0: null, 16: "#0000ff", 17: "#ffffff", 18: "#00ff00", 20: "#ff0000",
    21: "#ffffff", 22: "#000000"};
}

/* Pen swatches use the current character's palette too. */
function penColours() {
  const palette = Object.assign({}, VBXE, character().palette);
  const out = {0: null};
  Object.entries(PEN_REGION).forEach(([pen, index]) => {
    out[pen] = palette[index];
  });
  return out;
}

// ---------------------------------------------------------------- workshop

function cloneGrid(grid) { return grid.map(row => row.slice()); }

/* Palette index -> pen value, the inverse of PEN_REGION. */
const REGION_PEN = {20: 1, 17: 2, 18: 3, 16: 4};

function heroBaseline() {
  const frames = {};
  const regions = state.sheets.player.regions;
  ATARI_SLOTS.forEach(index => {
    const source = state.sheets.player.frames[index];
    frames[index] = source.grid.map(row => row.map(v => {
      if (v === 0) return 0;
      // A two-colour sheet has no legs or skin of its own: its boots were
      // derived from row position at build time, so they fold back into the
      // top and the sheet exports exactly as it was authored.
      if (!regions) return v === 20 ? 1 : 2;
      return REGION_PEN[v] || 2;
    }));
  });
  return frames;
}

/* How many pens the current sheet can express. */
function penValues() {
  return state.sheets.player && state.sheets.player.regions ?
    [1, 2, 3, 4, 0] : [1, 2, 0];
}

function gridBounds(grid) {
  let top = -1;
  let bottom = -1;
  grid.forEach((row, y) => {
    if (row.some(v => v !== 0)) {
      if (top < 0) top = y;
      bottom = y;
    }
  });
  return {top, bottom};
}

function edgeX(grid, y, side) {
  const xs = [];
  grid[y].forEach((v, x) => { if (v !== 0) xs.push(x); });
  if (!xs.length) return null;
  return side === "min" ? Math.min(...xs) : Math.max(...xs);
}

/*
 * Starting points, not finished characters. Each is additive: it only writes
 * into empty pixels, so it cannot damage the original poses, which are the
 * part worth keeping.
 */
const PRESETS = {
  hero: {label: "Current hero", apply: grid => grid},
  ponytail: {
    label: "Ponytail",
    apply(grid, flare) {
      const out = cloneGrid(grid);
      const {top} = gridBounds(grid);
      if (top < 0) return out;
      for (let i = 0; i < 3; i += 1) {
        const y = top + 1 + i;
        if (y >= grid.length) break;
        const a = edgeX(grid, y, "min");
        if (a === null) continue;
        for (let k = 1; k < 2 + flare; k += 1) {
          const ty = i > 1 ? y + 1 : y;
          if (ty < out.length && a - k >= 0 && out[ty][a - k] === 0) {
            out[ty][a - k] = 1;
          }
        }
      }
      return out;
    }
  },
  pack: {
    label: "Backpack",
    apply(grid, flare) {
      const out = cloneGrid(grid);
      const {top, bottom} = gridBounds(grid);
      if (top < 0) return out;
      for (let y = top + 4; y < Math.min(top + 9, bottom); y += 1) {
        const a = edgeX(grid, y, "min");
        if (a === null) continue;
        const reach = y < top + 7 ? 2 : 1;
        for (let k = 1; k <= reach; k += 1) {
          if (a - k >= 0 && out[y][a - k] === 0) out[y][a - k] = 2;
        }
      }
      return out;
    }
  },
  crest: {
    label: "Crest",
    apply(grid, flare) {
      const out = cloneGrid(grid);
      const {top} = gridBounds(grid);
      if (top < 0) return out;
      const b = edgeX(grid, top, "max");
      if (b !== null && top - 1 >= 0) {
        for (let k = 0; k < 2; k += 1) {
          if (b - k >= 0 && out[top - 1][b - k] === 0) out[top - 1][b - k] = 1;
        }
      }
      for (let y = top + 1; y < Math.min(top + 3 + flare, grid.length); y += 1) {
        const a = edgeX(grid, y, "min");
        if (a !== null && a - 1 >= 0 && out[y][a - 1] === 0) out[y][a - 1] = 1;
      }
      return out;
    }
  }
};

// Run frames flare the trailing shapes so motion reads at 16x16.
const FLARE = {5: 1, 6: 2, 7: 3, 8: 2, 9: 1};

function applyPreset(name) {
  const preset = PRESETS[name];
  const base = heroBaseline();
  const frames = {};
  ATARI_SLOTS.forEach(index => {
    frames[index] = preset.apply(base[index], FLARE[index] || 0);
  });
  state.workshop = {frames, preset: name};
}

/* Build the 80x64 sheet generate_assets.js expects, in its two colours. */
function exportSheetRGBA(frames) {
  const image = {data: new Uint8ClampedArray(80 * 64 * 4), width: 80, height: 64};
  const source = frames || state.workshop.frames;
  ATARI_SLOTS.forEach(index => {
    const grid = source[index];
    const ox = (index % 5) * 16;
    const oy = Math.floor(index / 5) * 16;
    for (let y = 0; y < 16; y += 1) {
      for (let x = 0; x < 16; x += 1) {
        const value = grid[y][x];
        if (!value) continue;
        const rgba = PEN_EXPORT[value];
        const at = ((oy + y) * 80 + ox + x) * 4;
        image.data[at] = rgba[0];
        image.data[at + 1] = rgba[1];
        image.data[at + 2] = rgba[2];
        image.data[at + 3] = rgba[3];
      }
    }
  });
  return image;
}

function exportSheetCanvas() {
  const raw = exportSheetRGBA();
  const canvas = document.createElement("canvas");
  canvas.width = 80;
  canvas.height = 64;
  const context = canvas.getContext("2d");
  const image = context.createImageData(80, 64);
  image.data.set(raw.data);
  context.putImageData(image, 0, 0);
  return canvas;
}

function download(name, href) {
  const link = document.createElement("a");
  link.download = name;
  link.href = href;
  document.body.appendChild(link);
  link.click();
  link.remove();
}

// ---------------------------------------------------------------- rendering

const animators = [];

function buildCatalogue(container) {
  container.textContent = "";
  CATALOGUE.forEach(entry => {
    const sheet = state.sheets[entry.sheet];
    const card = document.createElement("article");
    card.className = "asset-card";
    const blurb = entry.blurb !== null ? entry.blurb : (sheet.regions ?
      "A four-region sheet: red marks hair, white the top, green the legs " +
      "and blue the skin, and the port gives each its own palette entry." :
      "A two-colour sheet: red is her hair and white her body. The port " +
      "turns the lowest three rows of every frame into boots.");
    card.innerHTML =
      `<header><h3>${entry.title}</h3>` +
      `<span class="asset-bin">${entry.bin} · ${entry.bytes.toLocaleString()} B</span></header>` +
      `<p class="hint">${blurb}</p>`;
    const anims = document.createElement("div");
    anims.className = "asset-anims";
    entry.animations.forEach(animation => {
      const block = document.createElement("div");
      block.className = "asset-anim";
      const title = document.createElement("div");
      title.className = "asset-anim-title";
      title.innerHTML = `<strong>${animation.name}</strong>` +
        `<span>${animation.frames.length} frame${animation.frames.length > 1 ? "s" : ""}` +
        `${animation.fps ? ` · ${animation.fps} fps` : ""}</span>`;
      const live = document.createElement("canvas");
      live.className = "asset-live";
      const strip = document.createElement("div");
      strip.className = "asset-strip";
      animation.frames.forEach(index => {
        const frame = sheet.frames[index];
        if (!frame) return;
        const cell = document.createElement("figure");
        const canvas = document.createElement("canvas");
        paintGrid(canvas, frame.grid, 3, coloursFor(entry.sheet));
        const caption = document.createElement("figcaption");
        const slot = ATARI_SLOTS.indexOf(index);
        caption.textContent = entry.sheet === "player" && slot >= 0 ?
          `${index} → slot ${slot}` : `${index}`;
        cell.append(canvas, caption);
        strip.append(cell);
      });
      block.append(title, live, strip);
      anims.append(block);
      animators.push({canvas: live, sheet: entry.sheet, animation});
    });
    card.append(anims);
    container.append(card);
  });
}

function buildWorkshop(root) {
  root.textContent = "";
  const presetRow = document.createElement("div");
  presetRow.className = "workshop-presets";
  Object.entries(PRESETS).forEach(([name, preset]) => {
    const button = document.createElement("button");
    button.textContent = preset.label;
    button.dataset.preset = name;
    button.className = state.workshop?.preset === name ? "active" : "";
    button.addEventListener("click", () => {
      applyPreset(name);
      buildWorkshop(root);
    });
    presetRow.append(button);
  });

  const preview = document.createElement("div");
  preview.className = "workshop-preview";
  [{name: "idle", frames: [0, 1, 2, 3], fps: 12},
   {name: "run", frames: [5, 6, 7, 8, 9], fps: 12}].forEach(animation => {
    const block = document.createElement("div");
    const canvas = document.createElement("canvas");
    canvas.className = "asset-live";
    const label = document.createElement("span");
    label.textContent = animation.name;
    block.append(canvas, label);
    preview.append(block);
    animators.push({canvas, workshop: true, animation});
  });

  const pens = document.createElement("div");
  pens.className = "workshop-pens";
  const swatches = penColours();
  penValues().forEach(value => {
    const button = document.createElement("button");
    button.textContent = PEN_LABEL[value];
    if (swatches[value]) {
      button.style.borderLeft = `6px solid ${swatches[value]}`;
    }
    button.className = state.penValue === value ? "active" : "";
    button.addEventListener("click", () => {
      state.penValue = value;
      buildWorkshop(root);
    });
    pens.append(button);
  });

  const frameSelect = document.createElement("select");
  ATARI_SLOTS.forEach((index, slot) => {
    const option = document.createElement("option");
    option.value = String(index);
    option.textContent = `frame ${index} · slot ${slot}`;
    if (index === state.editingFrame) option.selected = true;
    frameSelect.append(option);
  });
  frameSelect.addEventListener("change", () => {
    state.editingFrame = Number(frameSelect.value);
    buildWorkshop(root);
  });

  const editor = document.createElement("canvas");
  editor.className = "workshop-canvas";
  const scale = 14;
  const redraw = () => paintGrid(editor,
    state.workshop.frames[state.editingFrame], scale, penColours());
  redraw();
  let painting = false;
  const paintAt = event => {
    const rect = editor.getBoundingClientRect();
    const x = Math.floor((event.clientX - rect.left) / rect.width * 16);
    const y = Math.floor((event.clientY - rect.top) / rect.height * 16);
    if (x < 0 || x > 15 || y < 0 || y > 15) return;
    state.workshop.frames[state.editingFrame][y][x] = state.penValue;
    redraw();
  };
  editor.addEventListener("pointerdown", event => {
    painting = true;
    editor.setPointerCapture(event.pointerId);
    paintAt(event);
  });
  editor.addEventListener("pointermove", event => { if (painting) paintAt(event); });
  editor.addEventListener("pointerup", () => { painting = false; });

  const exportRow = document.createElement("div");
  exportRow.className = "workshop-actions";
  const pngButton = document.createElement("button");
  pngButton.className = "primary";
  pngButton.textContent = "Export player.png";
  pngButton.addEventListener("click", () => {
    download("player.png", exportSheetCanvas().toDataURL("image/png"));
  });
  const jsonButton = document.createElement("button");
  jsonButton.textContent = "Export frames JSON";
  jsonButton.addEventListener("click", () => {
    const payload = JSON.stringify({frames: state.workshop.frames}, null, 1);
    download("hero-frames.json",
      "data:application/json," + encodeURIComponent(payload));
  });
  exportRow.append(pngButton, jsonButton);

  const help = document.createElement("p");
  help.className = "hint";
  const regions = state.sheets.player && state.sheets.player.regions;
  help.innerHTML = regions ?
    "Exported sheets use the pipeline's region markers: red hair, white " +
    "top, green legs, blue skin. Save it beside the character and build it " +
    "with <code>grapple/atari/run-character.sh &lt;sheet&gt;</code>, which " +
    "leaves the default build alone." :
    "Exported sheets use the pipeline's own two colours: pure red for hair, " +
    "white for body. Drop the file over " +
    "<code>grapple/bin/assets/player.png</code> and run " +
    "<code>grapple/atari/build.sh</code> — boots, palette packing and the " +
    "run cycle all follow automatically, with no generator change.";

  root.append(presetRow, preview, pens, frameSelect, editor, exportRow, help);
}

function tick(time) {
  animators.forEach(item => {
    const {animation} = item;
    const count = animation.frames.length;
    const step = animation.fps ?
      Math.floor(time / 1000 * animation.fps) % count : 0;
    const index = animation.frames[step];
    let grid = null;
    if (item.workshop) {
      grid = state.workshop.frames[index];
    } else {
      const frame = state.sheets[item.sheet].frames[index];
      grid = frame && frame.grid;
    }
    if (!grid) return;
    paintGrid(item.canvas, grid, 4,
      item.workshop ? penColours() : coloursFor(item.sheet));
  });
  if (state.open) requestAnimationFrame(tick);
}

// ---------------------------------------------------------------- lifecycle

async function open() {
  const view = document.querySelector("#assetsView");
  const workspace = document.querySelector(".workspace");
  const status = document.querySelector("#assetsStatus");
  state.open = true;
  workspace.hidden = true;
  view.hidden = false;
  document.querySelectorAll("[data-view-tab]").forEach(button => {
    button.classList.toggle("active", button.dataset.viewTab === "assets");
  });
  if (!state.loaded) {
    status.textContent = "Loading sprite sheets…";
    try {
      await loadAll();
    } catch (error) {
      status.textContent = `Could not load sprites: ${error.message}`;
      return;
    }
    applyPreset("hero");
  }
  refresh();
  requestAnimationFrame(tick);
}

/* Rebuild both panes against the current character and colour mode. */
function refresh() {
  animators.length = 0;
  buildCatalogue(document.querySelector("#assetGallery"));
  buildWorkshop(document.querySelector("#assetWorkshop"));
  const sheet = state.sheets.player;
  document.querySelector("#assetsStatus").textContent =
    `${character().name} · ${sheet.regions ? "four-region" : "two-colour"} sheet`;
}

function close() {
  state.open = false;
  document.querySelector("#assetsView").hidden = true;
  document.querySelector(".workspace").hidden = false;
  document.querySelectorAll("[data-view-tab]").forEach(button => {
    button.classList.toggle("active", button.dataset.viewTab === "map");
  });
}

function init() {
  document.querySelectorAll("[data-view-tab]").forEach(button => {
    button.addEventListener("click", () => {
      if (button.dataset.viewTab === "assets") open(); else close();
    });
  });
  const picker = document.querySelector("#assetCharacter");
  if (picker) {
    CHARACTERS.forEach((entry, index) => {
      const option = document.createElement("option");
      option.value = String(index);
      option.textContent = entry.name;
      picker.append(option);
    });
    picker.addEventListener("change", async () => {
      state.character = Number(picker.value);
      const status = document.querySelector("#assetsStatus");
      status.textContent = `Loading ${character().name}…`;
      try {
        await loadCharacter();
      } catch (error) {
        status.textContent = `Could not load ${character().name}: ${error.message}`;
        return;
      }
      refresh();
    });
  }

  // Deep link, so a review or a screenshot can land straight on a character.
  const query = new URLSearchParams(location.search);
  const wanted = (query.get("hero") || "").toLowerCase();
  if (wanted) {
    const found = CHARACTERS.findIndex(entry =>
      entry.name.toLowerCase() === wanted);
    if (found >= 0) {
      state.character = found;
      if (picker) picker.value = String(found);
    }
  }
  if (query.get("view") === "assets") open();
  const toggle = document.querySelector("#assetVbxeColours");
  if (toggle) {
    toggle.addEventListener("change", () => {
      state.vbxeColours = toggle.checked;
      if (state.open) refresh();
    });
  }
}

if (typeof document !== "undefined") {
  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
}

return {
  get isOpen() { return state.open; },
  open, close, state, PRESETS, ATARI_SLOTS, CATALOGUE, CLASSIFY, SHEETS, VBXE,
  CHARACTERS, loadCharacter, penValues,
  FLARE, exportSheetCanvas, exportSheetRGBA, classifySheet, applyPreset,
  heroBaseline, setSheets(sheets) { state.sheets = sheets; state.loaded = true; }
};
})();

if (typeof window !== "undefined") window.GrappleAssets = GrappleAssets;
if (typeof module !== "undefined") module.exports = GrappleAssets;
