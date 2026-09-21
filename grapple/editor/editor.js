"use strict";

const COLS = 12;
const ROWS = 240;
const TILE_SIZE = 16;
const editorQuery = new URLSearchParams(location.search);
const requestedWorld = editorQuery.get("world") || "";
const requestedRevision = editorQuery.get("revision") || "";
const AUTOSAVE_KEY = "grapple-level-editor-autosave-v1" + requestedWorld +
  (requestedRevision ? `:${requestedRevision}` : "");
const DEFAULT_MOVER_SPEED = 64;
const DEFAULT_CANNON_SPEED = 350;
let selectedChaseSpeed = 500;
const entityId = document.querySelector("#entityId");
const VBXE_TILE_IDS = new Set([-1, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,
  13, 14, 16, 17, 18]);
const TILE_DEFS = [
  {id: -1, name: "Empty", kind: "empty"},
  {id: 1, name: "Wall 1", kind: "wall"},
  {id: 2, name: "Wall 2", kind: "wall"},
  {id: 3, name: "Wall 3", kind: "wall"},
  {id: 4, name: "Wall 4", kind: "wall"},
  {id: 5, name: "Wall 5", kind: "wall"},
  {id: 6, name: "Wall 6", kind: "wall"},
  {id: 7, name: "Wall 7", kind: "wall"},
  {id: 8, name: "Wall 8", kind: "wall"},
  {id: 9, name: "Wall 9", kind: "wall"},
  {id: 10, name: "Wall 10", kind: "wall"},
  {id: 11, name: "Checkpoint", kind: "entity"},
  {id: 13, name: "Moving brick", kind: "entity"},
  {id: 14, name: "Cannon", kind: "entity"},
  {id: 16, name: "Spikes", kind: "entity"},
  {id: 17, name: "Thwomp", kind: "entity"},
  {id: 18, name: "Lava", kind: "entity"}
];
const LEGACY_LAVA = [
  {x: 2.5, y: 124.25, width: 5, height: 2.5},
  {x: 2.5, y: 134.25, width: 5, height: 2.5},
  {x: 8.25, y: 144.25, width: 2, height: 6},
  {x: -0.25, y: 148.25, width: 2, height: 6}
];

const canvas = document.querySelector("#mapCanvas");
const ctx = canvas.getContext("2d");
const minimap = document.querySelector("#minimap");
const miniCtx = minimap.getContext("2d");
const scroller = document.querySelector("#canvasScroller");
const paletteElement = document.querySelector("#palette");
const statusElement = document.querySelector("#status");
const countsElement = document.querySelector("#counts");
const cursorElement = document.querySelector("#cursorPosition");
const rotationElement = document.querySelector("#rotationText");
const selectionElement = document.querySelector("#selectionName");
const visibleRowElement = document.querySelector("#visibleRow");
const fileInput = document.querySelector("#fileInput");
const entitySettings = document.querySelector("#entitySettings");
const entitySettingsTitle = document.querySelector("#entitySettingsTitle");
const entityDirection = document.querySelector("#entityDirection");
const entitySpeed = document.querySelector("#entitySpeed");
const entitySpeedLabel = document.querySelector("#entitySpeedLabel");
const entitySettingsHint = document.querySelector("#entitySettingsHint");
const tileset = new Image();
tileset.src = "../bin/assets/world.png";

let zoom = 2;
let selectedTile = 1;
let selectedRotation = 0;
let activeTool = "brush";
let showGrid = true;
let showTracks = true;
let mapCells = createBlankCells();
let selectedMoverSpeed = DEFAULT_MOVER_SPEED;
let selectedCannonSpeed = DEFAULT_CANNON_SPEED;
let selectedEntityIndex = null;
let undoStack = [];
let redoStack = [];
let activeChanges = null;
let pointerDown = false;
let strokeStart = null;
let lastCell = null;
let dirty = false;

function createBlankCells() {
  return Array.from({length: COLS * ROWS}, (_, index) => ({
    x: index % COLS,
    tile: -1,
    y: Math.floor(index / COLS),
    flipX: false,
    index,
    rot: 0
  }));
}

function cloneCell(cell) {
  const clone = {x: cell.x, tile: cell.tile, y: cell.y, flipX: !!cell.flipX,
    index: cell.index, rot: normalizeRotation(cell.rot)};
  if (clone.tile >= 0) clone.id = String(cell.id || `brick-${cell.index}`);
  if (clone.tile === 17) clone.speed = Math.max(50, Math.min(500, Math.round((Number(cell.speed) || 500) / 50) * 50));
  if (clone.tile === 13) clone.speed = normalizeSpeed(cell.speed,
    DEFAULT_MOVER_SPEED, 8, 200);
  if (clone.tile === 14) clone.bulletSpeed = normalizeSpeed(cell.bulletSpeed,
    DEFAULT_CANNON_SPEED, 50, 500);
  return clone;
}

function normalizeRotation(value) {
  const number = Number(value) || 0;
  return ((Math.round(number) % 4) + 4) % 4;
}

function normalizeSpeed(value, fallback, minimum, maximum) {
  const number = Math.round(Number(value));
  return Number.isFinite(number) ? Math.max(minimum, Math.min(maximum, number)) :
    fallback;
}

function migrateLegacyLava(cells, rectangles) {
  rectangles.forEach((rect, index) => {
    const values = [rect.x, rect.y, rect.width, rect.height].map(Number);
    if (!values.every(Number.isFinite) || values[2] <= 0 || values[3] <= 0) {
      throw new Error(`Invalid legacy lava rectangle ${index + 1}`);
    }
    const left = values[0] + 1;
    const top = values[1] + 1;
    for (let y = 0; y < ROWS; y += 1) {
      for (let x = 0; x < COLS; x += 1) {
        if (x + .5 < left || x + .5 >= left + values[2] ||
            y + .5 < top || y + .5 >= top + values[3]) continue;
        const cell = cells[y * COLS + x];
        cell.tile = 18;
        cell.rot = 0;
        cell.flipX = false;
        delete cell.speed;
        delete cell.bulletSpeed;
      }
    }
  });
}

function validateAndNormalizeMap(data) {
  if (!data || data.tileswide !== COLS || data.tileshigh !== ROWS ||
      !Array.isArray(data.layers) || !data.layers[0] ||
      !Array.isArray(data.layers[0].tiles) ||
      data.layers[0].tiles.length !== COLS * ROWS) {
    throw new Error("Expected a 12 × 240 map with one complete tile layer.");
  }
  const normalized = createBlankCells();
  const seen = new Set();
  data.layers[0].tiles.forEach((cell, position) => {
    const x = Number.isInteger(cell.x) ? cell.x : position % COLS;
    const y = Number.isInteger(cell.y) ? cell.y : Math.floor(position / COLS);
    if (x < 0 || x >= COLS || y < 0 || y >= ROWS) {
      throw new Error(`Tile coordinate outside the map: ${x}, ${y}`);
    }
    const index = y * COLS + x;
    if (seen.has(index)) throw new Error(`Duplicate tile coordinate: ${x}, ${y}`);
    seen.add(index);
    const sourceTile = Number(cell.tile);
    const tile = Number.isInteger(sourceTile) && VBXE_TILE_IDS.has(sourceTile) ?
      sourceTile : -1;
    normalized[index] = cloneCell({
      x, y, index,
      tile,
      flipX: !!cell.flipX,
      rot: normalizeRotation(cell.rot),
      id: cell.id,
      speed: cell.speed,
      bulletSpeed: cell.bulletSpeed
    });
  });
  const hasLavaTiles = normalized.some(cell => cell.tile === 18);
  const editorData = data.grappleEditor;
  if (!hasLavaTiles && editorData && Array.isArray(editorData.lava)) {
    migrateLegacyLava(normalized, editorData.lava);
  } else if (!hasLavaTiles && !editorData) {
    migrateLegacyLava(normalized, LEGACY_LAVA);
  }
  for (const cell of normalized) {
    if (cell.tile >= 0 && !cell.id) cell.id = `brick-${cell.index}`;
  }
  const ids = normalized.filter(c => c.tile >= 0).map(c => c.id);
  if (new Set(ids).size !== ids.length) throw new Error("Duplicate brick ID; IDs must be unique.");
  return {cells: normalized};
}

function serializeMap() {
  return {
    layers: [{tiles: mapCells.map(cloneCell), number: 0, name: "Layer 0"}],
    tileswide: COLS,
    tilewidth: TILE_SIZE,
    tileheight: TILE_SIZE,
    tileshigh: ROWS,
    grappleEditor: {
      version: 3,
      target: "atari-vbxe"
    }
  };
}

function tileDefinition(id) {
  return TILE_DEFS.find(tile => tile.id === id) || TILE_DEFS[0];
}

function fallbackColor(id) {
  if (id < 0) return "#080a11";
  if (id <= 10) return ["#421d30", "#512238", "#602740", "#6e2d48"][id % 4];
  return {11: "#69d98a", 12: "#a68cff", 13: "#ff3157", 14: "#ff8a3d",
    15: "#db4fff", 16: "#f7f4fa", 17: "#59bfe8", 18: "#ff6a00"}[id] || "#fff";
}

function drawDirectionArrow(target, x, y, size, rotation) {
  /* Mover rot 0/1/2/3 maps to down/left/up/right in the game. */
  const vectors = [[0, 1], [-1, 0], [0, -1], [1, 0]];
  const [dx, dy] = vectors[normalizeRotation(rotation)];
  const cx = x + size / 2;
  const cy = y + size / 2;
  const length = size * .31;
  const ex = cx + dx * length;
  const ey = cy + dy * length;
  target.save();
  target.strokeStyle = "#54e8ff";
  target.fillStyle = "#54e8ff";
  target.lineWidth = Math.max(2, size / 12);
  target.beginPath();
  target.moveTo(cx - dx * length * .55, cy - dy * length * .55);
  target.lineTo(ex, ey);
  target.stroke();
  target.translate(ex, ey);
  target.rotate(Math.atan2(dy, dx));
  target.beginPath();
  target.moveTo(0, 0);
  target.lineTo(-size * .18, -size * .11);
  target.lineTo(-size * .18, size * .11);
  target.closePath();
  target.fill();
  target.restore();
}

function drawTile(target, cell, x, y, size, grid) {
  target.fillStyle = "#080a11";
  target.fillRect(x, y, size, size);
  if (cell.tile === 18) {
    target.fillStyle = "#ff6a00";
    target.fillRect(x + 1, y + 1, size - 2, size - 2);
  } else if (cell.tile >= 1 && cell.tile <= 10) {
    target.fillStyle = fallbackColor(cell.tile);
    target.fillRect(x, y, size, size);
    target.fillStyle = "rgba(255,255,255,.055)";
    target.fillRect(x, y, size, Math.max(1, size / 10));
  } else if (cell.tile >= 11 && tileset.complete && tileset.naturalWidth) {
    const sourceX = (cell.tile % 8) * TILE_SIZE;
    const sourceY = Math.floor(cell.tile / 8) * TILE_SIZE;
    target.save();
    target.translate(x + size / 2, y + size / 2);
    target.rotate(cell.rot * Math.PI / 2);
    target.scale(cell.flipX ? -1 : 1, 1);
    target.imageSmoothingEnabled = false;
    target.drawImage(tileset, sourceX, sourceY, TILE_SIZE, TILE_SIZE,
      -size / 2, -size / 2, size, size);
    target.restore();
  } else if (cell.tile >= 1) {
    target.fillStyle = fallbackColor(cell.tile);
    target.fillRect(x + 1, y + 1, size - 2, size - 2);
  }
  if (cell.tile === 13) drawDirectionArrow(target, x, y, size, cell.rot);
  if (grid) {
    target.strokeStyle = "rgba(151,158,182,.20)";
    target.lineWidth = 1;
    target.strokeRect(x + .5, y + .5, size - 1, size - 1);
  }
}

function configureCanvas() {
  const size = TILE_SIZE * zoom;
  canvas.width = COLS * size;
  canvas.height = ROWS * size;
  ctx.imageSmoothingEnabled = false;
}

function renderAll() {
  const size = TILE_SIZE * zoom;
  ctx.fillStyle = "#080a11";
  ctx.fillRect(0, 0, canvas.width, canvas.height);
  mapCells.forEach(cell => drawTile(ctx, cell, cell.x * size, cell.y * size,
    size, showGrid));
  renderOverlays();
  renderMinimap();
  updateCounts();
}

function renderCell(index) {
  const cell = mapCells[index];
  const size = TILE_SIZE * zoom;
  drawTile(ctx, cell, cell.x * size, cell.y * size, size, showGrid);
}

function pointHitsLevel(canvasX, canvasY) {
  const col = Math.floor(canvasX / TILE_SIZE);
  const row = Math.floor(canvasY / TILE_SIZE);
  if (col < 0 || col >= COLS || row < 0 || row >= ROWS) return true;
  const tile = mapCells[row * COLS + col].tile;
  return (tile >= 1 && tile <= 10) || tile === 18;
}

function drawCannonTrack(cell) {
  const directions = [[-1, -1], [1, -1], [1, 1], [-1, 1]];
  const [dirX, dirY] = directions[normalizeRotation(cell.rot)];
  const normal = Math.SQRT1_2;
  let x = (cell.x + .5) * TILE_SIZE + dirX * normal * 10;
  let y = (cell.y + .5) * TILE_SIZE + dirY * normal * 10;
  const bulletSpeed = normalizeSpeed(cell.bulletSpeed, DEFAULT_CANNON_SPEED,
    50, 500);
  let vx = dirX * normal * bulletSpeed;
  let vy = dirY * normal * bulletSpeed;
  const step = .04;
  ctx.save();
  ctx.strokeStyle = "rgba(255,174,74,.92)";
  ctx.lineWidth = Math.max(1.5, zoom);
  ctx.setLineDash([4 * zoom, 4 * zoom]);
  ctx.beginPath();
  ctx.moveTo(x * zoom, y * zoom);
  for (let time = 0; time < 3; time += step) {
    if (vx > 0) vx = Math.max(0, vx - 200 * step);
    else if (vx < 0) vx = Math.min(0, vx + 200 * step);
    vy += 400 * step;
    x += vx * step;
    y += vy * step;
    ctx.lineTo(x * zoom, y * zoom);
    if (pointHitsLevel(x, y)) break;
  }
  ctx.stroke();
  ctx.restore();
}

function renderOverlays() {
  if (showTracks) mapCells.filter(cell => cell.tile === 14).forEach(drawCannonTrack);
}

function renderMinimap() {
  const cellW = minimap.width / COLS;
  const cellH = minimap.height / ROWS;
  miniCtx.fillStyle = "#080a11";
  miniCtx.fillRect(0, 0, minimap.width, minimap.height);
  mapCells.forEach(cell => {
    if (cell.tile < 1) return;
    miniCtx.fillStyle = fallbackColor(cell.tile);
    miniCtx.fillRect(cell.x * cellW, cell.y * cellH,
      Math.ceil(cellW), Math.ceil(cellH));
  });
  mapCells.filter(cell => cell.tile === 13).forEach(cell => {
    miniCtx.fillStyle = "#54e8ff";
    miniCtx.fillRect(cell.x * cellW + cellW / 3, cell.y * cellH,
      Math.max(2, cellW / 3), Math.max(2, cellH));
  });
  renderMinimapViewport();
}

// Canvas is not positioned relative to the scroller's offsetParent. Measure
// its inset in scroll coordinates so row jumps and the overview agree.
function canvasScrollOffset() {
  return canvas.getBoundingClientRect().top - scroller.getBoundingClientRect().top + scroller.scrollTop;
}

function renderMinimapViewport() {
  const size = TILE_SIZE * zoom;
  const canvasTop = canvasScrollOffset();
  const top = Math.max(0, scroller.scrollTop - canvasTop) / size;
  const rowsVisible = scroller.clientHeight / size;
  miniCtx.save();
  miniCtx.strokeStyle = "#ff3157";
  miniCtx.lineWidth = 2;
  miniCtx.strokeRect(1, top * 2, minimap.width - 2,
    Math.max(4, rowsVisible * 2));
  miniCtx.restore();
  const first = Math.max(0, Math.floor(top));
  const last = Math.min(ROWS - 1, Math.ceil(top + rowsVisible));
  visibleRowElement.textContent = `Rows ${first}–${last}`;
}

function buildPalette() {
  paletteElement.replaceChildren();
  TILE_DEFS.forEach(definition => {
    const button = document.createElement("button");
    button.type = "button";
    button.dataset.tile = String(definition.id);
    button.title = definition.kind === "entity" ? "Entity tile" : definition.name;
    const preview = document.createElement("canvas");
    preview.width = 32;
    preview.height = 32;
    preview.className = "tile-preview";
    const label = document.createElement("span");
    label.textContent = definition.name;
    button.append(preview, label);
    button.addEventListener("click", () => selectTile(definition.id));
    paletteElement.append(button);
    drawTile(preview.getContext("2d"), {tile: definition.id, rot: 0,
      flipX: false}, 0, 0, 32, false);
  });
  updatePaletteSelection();
}

function refreshPalettePreviews() {
  paletteElement.querySelectorAll("button").forEach(button => {
    const preview = button.querySelector("canvas");
    drawTile(preview.getContext("2d"), {tile: Number(button.dataset.tile),
      rot: 0, flipX: false}, 0, 0, 32, false);
  });
}

function selectTile(id) {
  selectedTile = id;
  selectedEntityIndex = null;
  if (id === -1) setTool("eraser");
  else if (activeTool === "eraser" || activeTool === "pick") setTool("brush");
  updatePaletteSelection();
}

function updatePaletteSelection() {
  paletteElement.querySelectorAll("button").forEach(button => {
    button.classList.toggle("active", Number(button.dataset.tile) === selectedTile);
  });
  selectionElement.textContent = tileDefinition(selectedTile).name;
  if (selectedTile === 13) {
    rotationElement.textContent = `${selectedRotation * 90}° · moves ${
      ["down", "left", "up", "right"][selectedRotation]}`;
  } else if (selectedTile === 14) {
    rotationElement.textContent = `${selectedRotation * 90}° · fires ${
      ["up-left", "up-right", "down-right", "down-left"][selectedRotation]}`;
  } else {
    rotationElement.textContent = `${selectedRotation * 90}°`;
  }
  updateEntityInspector();
}

function directionNames(tile) {
  return tile === 13 ? ["Down", "Left", "Up", "Right"] :
    tile === 14 ? ["Up-left", "Up-right", "Down-right", "Down-left"] :
    ["0°", "90°", "180°", "270°"];
}

function currentSettingsCell() {
  if (selectedEntityIndex === null) return null;
  const cell = mapCells[selectedEntityIndex];
  return cell && cell.tile >= 0 ? cell : null;
}

function updateEntityInspector() {
  const cell = currentSettingsCell();
  const tile = cell ? cell.tile : selectedTile;
  const visible = tile >= 0;
  entitySettings.hidden = !visible;
  if (!visible) return;
  entityId.value = cell ? cell.id : "Assigned when painted";
  entityId.disabled = !cell;
  entityDirection.closest("label").hidden = tile === 17;
  entitySpeed.closest("label").hidden = ![13,14,17].includes(tile);
  entitySpeed.step = tile === 17 ? "50" : "1";
  const names = directionNames(tile);
  entityDirection.replaceChildren(...names.map((name, rotation) => {
    const option = document.createElement("option");
    option.value = String(rotation);
    option.textContent = name;
    return option;
  }));
  const rotation = cell ? cell.rot : selectedRotation;
  entityDirection.value = String(normalizeRotation(rotation));
  if (tile === 13) {
    entitySettingsTitle.textContent = "Moving brick settings";
    entitySpeedLabel.textContent = "Movement speed";
    entitySpeed.min = "8";
    entitySpeed.max = "200";
    entitySpeed.value = String(cell ? cell.speed : selectedMoverSpeed);
  } else if (tile === 17) {
    entitySettingsTitle.textContent = "Chasing brick settings";
    entitySpeedLabel.textContent = "Maximum chase speed";
    entitySpeed.min = "50"; entitySpeed.max = "500";
    entitySpeed.value = String(cell ? cell.speed : selectedChaseSpeed);
  } else {
    entitySettingsTitle.textContent = tile === 14 ? "Cannon settings" : "Brick settings";
    entitySpeedLabel.textContent = "Bullet speed";
    entitySpeed.min = "50";
    entitySpeed.max = "500";
    entitySpeed.value = String(cell ? cell.bulletSpeed : selectedCannonSpeed);
  }
  entitySettingsHint.textContent = cell ?
    `Editing placed entity at column ${cell.x}, row ${cell.y}.` :
    "These values are used for newly painted entities. Pick a placed entity to edit it.";
}

function editSelectedEntity(mutator, message) {
  const cell = currentSettingsCell();
  if (!cell) return false;
  const before = cloneCell(cell);
  mutator(cell);
  const after = cloneCell(cell);
  mapCells[cell.index] = after;
  undoStack.push({type: "cells", changes: [{index: cell.index, before, after}]});
  if (undoStack.length > 100) undoStack.shift();
  redoStack = [];
  setDirty(true);
  saveAutosave();
  renderAll();
  updateHistoryButtons();
  updatePaletteSelection();
  setStatus(message);
  return true;
}

function setTool(tool) {
  activeTool = tool;
  document.querySelectorAll("#toolGrid button").forEach(button => {
    button.classList.toggle("active", button.dataset.tool === tool);
  });
  canvas.style.cursor = tool === "pick" ? "copy" : "crosshair";
}

function cellFromEvent(event) {
  const rect = canvas.getBoundingClientRect();
  const x = Math.floor((event.clientX - rect.left) * canvas.width / rect.width /
    (TILE_SIZE * zoom));
  const y = Math.floor((event.clientY - rect.top) * canvas.height / rect.height /
    (TILE_SIZE * zoom));
  if (x < 0 || x >= COLS || y < 0 || y >= ROWS) return null;
  return {x, y, index: y * COLS + x};
}

function recordChange(index, tile, rot) {
  const current = mapCells[index];
  const nextTile = tile;
  if (nextTile === 18 && current.tile !== 18 &&
      mapCells.filter(cell => cell.tile === 18).length >= 85) {
    setStatus("VBXE supports at most 85 lava tiles");
    return;
  }
  const nextRot = nextTile < 0 ? 0 : normalizeRotation(rot);
  const nextSpeed = nextTile === 13 ? selectedMoverSpeed : nextTile === 17 ? selectedChaseSpeed : undefined;
  const nextBulletSpeed = nextTile === 14 ? selectedCannonSpeed : undefined;
  if (current.tile === nextTile && current.rot === nextRot && !current.flipX &&
      current.speed === nextSpeed && current.bulletSpeed === nextBulletSpeed) return;
  if (!activeChanges.has(index)) activeChanges.set(index, cloneCell(current));
  if (nextTile >= 0 && (current.tile !== nextTile || !current.id)) {
    const used = new Set(mapCells.map(c => c.id));
    let id = `brick-${index}`, suffix = 1;
    while (used.has(id)) id = `brick-${index}-${suffix++}`;
    current.id = id;
  }
  if (nextTile < 0) delete current.id;
  current.tile = nextTile;
  current.rot = nextRot;
  current.flipX = false;
  if (nextTile === 13 || nextTile === 17) current.speed = nextSpeed;
  else delete current.speed;
  if (nextTile === 14) current.bulletSpeed = nextBulletSpeed;
  else delete current.bulletSpeed;
  if (selectedEntityIndex === index && nextTile < 0) {
    selectedEntityIndex = null;
  }
  renderCell(index);
}

function paintLine(from, to, tile, rot) {
  let x0 = from.x;
  let y0 = from.y;
  const dx = Math.abs(to.x - x0);
  const sx = x0 < to.x ? 1 : -1;
  const dy = -Math.abs(to.y - y0);
  const sy = y0 < to.y ? 1 : -1;
  let error = dx + dy;
  while (true) {
    recordChange(y0 * COLS + x0, tile, rot);
    if (x0 === to.x && y0 === to.y) break;
    const twice = 2 * error;
    if (twice >= dy) { error += dy; x0 += sx; }
    if (twice <= dx) { error += dx; y0 += sy; }
  }
}

function fillRegion(start, tile, rot) {
  const source = mapCells[start.index];
  const sourceTile = source.tile;
  const sourceRotation = source.rot;
  if (sourceTile === tile && sourceRotation === rot) return;
  activeChanges = new Map();
  const queue = [start.index];
  const visited = new Uint8Array(COLS * ROWS);
  while (queue.length) {
    const index = queue.pop();
    if (visited[index]) continue;
    visited[index] = 1;
    const cell = mapCells[index];
    if (cell.tile !== sourceTile || cell.rot !== sourceRotation) continue;
    recordChange(index, tile, rot);
    const x = index % COLS;
    const y = Math.floor(index / COLS);
    if (x > 0) queue.push(index - 1);
    if (x < COLS - 1) queue.push(index + 1);
    if (y > 0) queue.push(index - COLS);
    if (y < ROWS - 1) queue.push(index + COLS);
  }
  commitChanges();
}

function commitChanges() {
  if (!activeChanges || activeChanges.size === 0) {
    activeChanges = null;
    return;
  }
  const changes = [];
  activeChanges.forEach((before, index) => changes.push({
    index, before, after: cloneCell(mapCells[index])
  }));
  undoStack.push({type: "cells", changes});
  if (undoStack.length > 100) undoStack.shift();
  redoStack = [];
  activeChanges = null;
  setDirty(true);
  saveAutosave();
  renderAll();
  updateHistoryButtons();
  setStatus(`${changes.length} cell${changes.length === 1 ? "" : "s"} changed`);
}

function applyHistory(action, direction) {
  action.changes.forEach(change => {
    mapCells[change.index] = cloneCell(change[direction]);
  });
  renderAll();
  updateEntityInspector();
  setDirty(true);
  saveAutosave();
}

function undo() {
  const action = undoStack.pop();
  if (!action) return;
  applyHistory(action, "before");
  redoStack.push(action);
  updateHistoryButtons();
  setStatus("Undid last edit");
}

function redo() {
  const action = redoStack.pop();
  if (!action) return;
  applyHistory(action, "after");
  undoStack.push(action);
  updateHistoryButtons();
  setStatus("Redid edit");
}

function updateHistoryButtons() {
  document.querySelector("#undo").disabled = undoStack.length === 0;
  document.querySelector("#redo").disabled = redoStack.length === 0;
}

function setDirty(value) {
  dirty = value;
  document.title = `${dirty ? "• " : ""}Grapple Level Editor`;
}

function setStatus(message) {
  statusElement.textContent = message;
}

function updateCounts() {
  const solids = mapCells.filter(cell => cell.tile >= 1 && cell.tile <= 10).length;
  const lava = mapCells.filter(cell => cell.tile === 18).length;
  const entities = mapCells.filter(cell => [11, 13, 14, 16, 17].includes(
    cell.tile)).length;
  countsElement.textContent = `${solids} solid · ${entities} entities · ${lava} lava tiles`;
  updateBuildStatus();
}

function updateBuildStatus() {
  const limits = [[13, "Moving bricks", 31], [14, "Cannons", 28],
    [16, "Spikes", 63], [17, "Thwomps", 23], [11, "Checkpoints", 63], [18, "Lava", 85]];
  const details = document.querySelector("#buildDetails");
  details.replaceChildren();
  let problems = 0;
  for (const [tile, name, required] of limits) {
    const count = mapCells.filter(c => c.tile === tile).length;
    const valid = tile === 18 ? count <= required : count >= 1 && count <= required;
    if (!valid) problems++;
    const line = document.createElement("div");
    line.className = `limit-row${valid ? "" : " invalid"}`;
    const label = document.createElement("span"); label.textContent = name;
    const value = document.createElement("span"); value.textContent = `${count} / ${tile === 18 ? "0–" : "1–"}${required}`;
    line.append(label, value); details.append(line);
  }
  const note = document.createElement("p");
  note.textContent = "Atari supports these ranges; the combined tables must also fit native memory. The build checks this. Browser playtests accept other counts.";
  details.append(note);
  const status = document.querySelector("#buildStatus");
  status.classList.toggle("warning", problems > 0);
  status.textContent = problems ? `${problems} entity counts need attention for the Atari build. Playtesting is available.` :
    "Entity counts match the Atari build.";
}

function saveAutosave() {
  try { localStorage.setItem(AUTOSAVE_KEY, JSON.stringify(serializeMap())); }
  catch (error) { setStatus(`Autosave unavailable: ${error.message}`); }
}

function loadCells(cells, message) {
  mapCells = cells;
  selectedEntityIndex = null;
  undoStack = [];
  redoStack = [];
  setDirty(false);
  configureCanvas();
  renderAll();
  updateHistoryButtons();
  updateEntityInspector();
  setStatus(message);
  document.querySelector("#playMap").disabled = false;
  scroller.scrollTop = 0;
}

async function loadOriginal() {
  const response = await fetch(new URLSearchParams(location.search).get("world") || "../bin/assets/world.json", {cache: "no-store"});
  if (!response.ok) throw new Error(`HTTP ${response.status}`);
  const level = validateAndNormalizeMap(await response.json());
  loadCells(level.cells, "Loaded VBXE world.json");
}

function exportMap() {
  const text = JSON.stringify(serializeMap(), null, 4) + "\n";
  const blob = new Blob([text], {type: "application/json"});
  const url = URL.createObjectURL(blob);
  const link = document.createElement("a");
  link.href = url;
  link.download = "world.json";
  link.click();
  setTimeout(() => URL.revokeObjectURL(url), 1000);
  setDirty(false);
  setStatus("Exported VBXE world.json — copy it into grapple/bin/assets and rebuild");
}

function confirmAction(title, message) {
  const dialog = document.querySelector("#confirmDialog");
  document.querySelector("#dialogTitle").textContent = title;
  document.querySelector("#dialogMessage").textContent = message;
  dialog.showModal();
  return new Promise(resolve => {
    dialog.addEventListener("close", () => resolve(dialog.returnValue === "confirm"),
      {once: true});
  });
}

function jumpToRow(row) {
  const bounded = Math.max(0, Math.min(ROWS - 1, Math.round(Number(row) || 0)));
  document.querySelector("#jumpRow").value = bounded;
  scroller.scrollTop = canvasScrollOffset() + bounded * TILE_SIZE * zoom;
  renderMinimap();
}

canvas.addEventListener("contextmenu", event => event.preventDefault());
canvas.addEventListener("pointerdown", event => {
  const cell = cellFromEvent(event);
  if (!cell) return;
  if (activeTool === "test") {
    if (event.button === 2) window.GrapplePlaytest.chooseHere();
    else window.GrapplePlaytest.pick(cell);
    return;
  }
  canvas.setPointerCapture(event.pointerId);
  if (activeTool === "pick") {
    const picked = mapCells[cell.index];
    selectedTile = picked.tile;
    selectedRotation = picked.rot;
    selectedEntityIndex = picked.tile >= 0 ?
      picked.index : null;
    if (picked.tile === 17) selectedChaseSpeed = picked.speed;
    if (picked.tile === 13) selectedMoverSpeed = picked.speed;
    if (picked.tile === 14) selectedCannonSpeed = picked.bulletSpeed;
    setTool(picked.tile < 0 ? "eraser" : "brush");
    updatePaletteSelection();
    setStatus(`Picked ${tileDefinition(picked.tile).name}`);
    return;
  }
  if (activeTool === "fill") {
    fillRegion(cell, event.button === 2 ? -1 : selectedTile, selectedRotation);
    return;
  }
  pointerDown = true;
  strokeStart = cell;
  lastCell = cell;
  activeChanges = new Map();
  const erase = event.button === 2 || activeTool === "eraser";
  recordChange(cell.index, erase ? -1 : selectedTile, selectedRotation);
});

canvas.addEventListener("pointermove", event => {
  const cell = cellFromEvent(event);
  if (cell) cursorElement.textContent = `Column ${cell.x} · Row ${cell.y}`;
  if (!pointerDown || !cell || (lastCell && cell.index === lastCell.index)) return;
  let target = cell;
  if (event.shiftKey && strokeStart) {
    const dx = Math.abs(cell.x - strokeStart.x);
    const dy = Math.abs(cell.y - strokeStart.y);
    target = dx >= dy ? {x: cell.x, y: strokeStart.y} : {x: strokeStart.x, y: cell.y};
    target.index = target.y * COLS + target.x;
  }
  const erase = (event.buttons & 2) !== 0 || activeTool === "eraser";
  paintLine(lastCell || target, target, erase ? -1 : selectedTile, selectedRotation);
  lastCell = target;
});

function finishStroke() {
  if (!pointerDown) return;
  pointerDown = false;
  strokeStart = null;
  lastCell = null;
  commitChanges();
}
canvas.addEventListener("pointerup", finishStroke);
canvas.addEventListener("pointercancel", finishStroke);

document.querySelectorAll("#toolGrid button").forEach(button => {
  button.addEventListener("click", () => setTool(button.dataset.tool));
});
document.querySelector("#rotate").addEventListener("click", () => {
  const nextRotation = (selectedRotation + 1) % 4;
  if (!editSelectedEntity(cell => { cell.rot = nextRotation; },
      "Updated entity direction")) selectedRotation = nextRotation;
  else selectedRotation = nextRotation;
  updatePaletteSelection();
});
entityDirection.addEventListener("change", event => {
  const rotation = normalizeRotation(event.target.value);
  selectedRotation = rotation;
  editSelectedEntity(cell => { cell.rot = rotation; }, "Updated entity direction");
  updatePaletteSelection();
});
entityId.addEventListener("change", () => {
  const id = entityId.value.trim();
  if (!id || mapCells.some(c => c.index !== selectedEntityIndex && c.id === id)) {
    setStatus("Choose a nonempty, unique brick ID"); updateEntityInspector(); return;
  }
  editSelectedEntity(c => { c.id = id; }, "Updated brick ID");
});
entitySpeed.addEventListener("change", event => {
  const cell = currentSettingsCell();
  const tile = cell ? cell.tile : selectedTile;
  if (tile === 13) {
    const speed = normalizeSpeed(event.target.value, selectedMoverSpeed, 8, 200);
    selectedMoverSpeed = speed;
    editSelectedEntity(target => { target.speed = speed; },
      "Updated moving brick speed");
  } else if (tile === 17) {
    const speed = Math.max(50, Math.min(500, Math.round((Number(event.target.value) || 500) / 50) * 50));
    selectedChaseSpeed = speed;
    editSelectedEntity(target => { target.speed = speed; }, "Updated chasing brick speed");
  } else if (tile === 14) {
    const speed = normalizeSpeed(event.target.value, selectedCannonSpeed, 50, 500);
    selectedCannonSpeed = speed;
    editSelectedEntity(target => { target.bulletSpeed = speed; },
      "Updated cannon bullet speed");
  }
  updateEntityInspector();
});
document.querySelector("#zoom").addEventListener("change", event => {
  const previousSize = TILE_SIZE * zoom;
  const row = Math.max(0, scroller.scrollTop - canvasScrollOffset()) / previousSize;
  zoom = Number(event.target.value);
  configureCanvas();
  renderAll();
  requestAnimationFrame(() => jumpToRow(row));
});
document.querySelector("#showGrid").addEventListener("change", event => {
  showGrid = event.target.checked;
  renderAll();
});
document.querySelector("#showTracks").addEventListener("change", event => {
  showTracks = event.target.checked;
  renderAll();
});
document.querySelector("#jumpButton").addEventListener("click", () =>
  jumpToRow(document.querySelector("#jumpRow").value));
document.querySelector("#jumpRow").addEventListener("keydown", event => {
  if (event.key === "Enter") jumpToRow(event.currentTarget.value);
});
document.querySelector("#undo").addEventListener("click", undo);
document.querySelector("#redo").addEventListener("click", redo);
document.querySelector("#exportMap").addEventListener("click", exportMap);
document.querySelector("#openMap").addEventListener("click", () => fileInput.click());
fileInput.addEventListener("change", async () => {
  const file = fileInput.files[0];
  if (!file) return;
  try {
    const level = validateAndNormalizeMap(JSON.parse(await file.text()));
    loadCells(level.cells, `Loaded ${file.name}`);
    saveAutosave();
  } catch (error) {
    setStatus(`Could not open map: ${error.message}`);
  } finally {
    fileInput.value = "";
  }
});
document.querySelector("#newMap").addEventListener("click", async () => {
  if (dirty && !await confirmAction("Start a new map?",
      "This clears the canvas. Export first if you want a separate copy.")) return;
  loadCells(createBlankCells(), "Created a blank 12 × 240 map", []);
  saveAutosave();
});
document.querySelector("#reloadOriginal").addEventListener("click", async () => {
  if (dirty && !await confirmAction("Reload the original map?",
      "Current edits will be replaced by grapple/bin/assets/world.json.")) return;
  try { await loadOriginal(); saveAutosave(); }
  catch (error) { setStatus(`Could not load original map: ${error.message}`); }
});

let overviewDragging = false;
function scrollFromOverview(event) {
  const rect = minimap.getBoundingClientRect();
  const targetRow = (event.clientY - rect.top) / rect.height * ROWS;
  const visibleRows = scroller.clientHeight / (TILE_SIZE * zoom);
  jumpToRow(targetRow - visibleRows / 2);
}
minimap.addEventListener("pointerdown", event => {
  overviewDragging = true;
  minimap.setPointerCapture(event.pointerId);
  scrollFromOverview(event);
});
minimap.addEventListener("pointermove", event => {
  if (overviewDragging) scrollFromOverview(event);
});
minimap.addEventListener("pointerup", () => { overviewDragging = false; });
minimap.addEventListener("pointercancel", () => { overviewDragging = false; });
minimap.addEventListener("wheel", event => {
  event.preventDefault();
  const current = Math.max(0, scroller.scrollTop - canvasScrollOffset()) /
    (TILE_SIZE * zoom);
  jumpToRow(current + Math.sign(event.deltaY) * 8);
}, {passive: false});
scroller.addEventListener("scroll", renderMinimap);
window.addEventListener("resize", renderMinimap);
window.addEventListener("keydown", event => {
  if (window.GrapplePlaytest?.isOpen || window.GrappleAssets?.isOpen ||
      document.querySelector("#confirmDialog").open) return;
  if (["INPUT", "SELECT", "TEXTAREA"].includes(document.activeElement.tagName)) return;
  if ((event.ctrlKey || event.metaKey) && event.key.toLowerCase() === "z") {
    event.preventDefault();
    event.shiftKey ? redo() : undo();
  } else if ((event.ctrlKey || event.metaKey) && event.key.toLowerCase() === "y") {
    event.preventDefault(); redo();
  } else if (!event.ctrlKey && !event.metaKey && !event.altKey &&
      !["INPUT", "SELECT"].includes(document.activeElement.tagName)) {
    const key = event.key.toLowerCase();
    if (key === "r") document.querySelector("#rotate").click();
    if (key === "b") setTool("brush");
    if (key === "e") setTool("eraser");
    if (key === "f") setTool("fill");
    if (key === "i") setTool("pick");
  }
});
window.addEventListener("beforeunload", event => {
  if (!dirty) return;
  event.preventDefault();
  event.returnValue = "";
});

tileset.addEventListener("load", () => { refreshPalettePreviews(); renderAll(); });
tileset.addEventListener("error", () => setStatus("Tileset unavailable; using editor colours"));

async function start() {
  configureCanvas();
  buildPalette();
  updateHistoryButtons();
  let autosave = null;
  try { autosave = localStorage.getItem(AUTOSAVE_KEY); } catch (_) {}
  if (autosave) {
    try {
      const level = validateAndNormalizeMap(JSON.parse(autosave));
      loadCells(level.cells, "Recovered browser autosave");
      const requestedRow = new URLSearchParams(location.search).get("row");
      if (requestedRow !== null) requestAnimationFrame(() => jumpToRow(requestedRow));
      return;
    } catch (_) { try { localStorage.removeItem(AUTOSAVE_KEY); } catch (_) {} }
  }
  try { await loadOriginal(); }
  catch (error) {
    loadCells(createBlankCells(), `Original map unavailable: ${error.message}`);
  }
  const requestedRow = new URLSearchParams(location.search).get("row");
  if (requestedRow !== null) requestAnimationFrame(() => jumpToRow(requestedRow));
}

start();
