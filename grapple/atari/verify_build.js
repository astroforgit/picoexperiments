"use strict";

var fs = require("fs");
var path = require("path");
var buildDir = process.env.BUILD_DIR || __dirname;
var xex = fs.readFileSync(path.join(buildDir, "grapple-vbxe.xex"));
var labels = fs.readFileSync(path.join(buildDir, "grapple-vbxe.lab"), "utf8");
var assets = fs.readFileSync(path.join(buildDir, "player-assets.bin"));
var moverAssets = fs.readFileSync(path.join(buildDir, "mover-assets.bin"));
var spikeAssets = fs.readFileSync(path.join(buildDir, "spike-assets.bin"));
var cannonAssets = fs.readFileSync(path.join(buildDir, "cannon-assets.bin"));
var cannonballAssets = fs.readFileSync(path.join(buildDir,
  "cannonball-assets.bin"));
var thwompAssets = fs.readFileSync(path.join(buildDir, "thwomp-assets.bin"));
var checkpointAssets = fs.readFileSync(path.join(buildDir,
  "checkpoint-assets.bin"));
var packedAssets = fs.readFileSync(path.join(buildDir, "assets-packed.bin"));
var moverData = fs.readFileSync(path.join(buildDir, "mover-data.bin"));
var cannonData = fs.readFileSync(path.join(buildDir, "cannon-data.bin"));
var spikeData = fs.readFileSync(path.join(buildDir, "spike-data.bin"));
var thwompData = fs.readFileSync(path.join(buildDir, "thwomp-data.bin"));
var checkpointData = fs.readFileSync(path.join(buildDir,
  "checkpoint-data.bin"));
var checkpointTeleportData = fs.readFileSync(path.join(buildDir,
  "checkpoint-teleport-data.bin"));
var lavaData = fs.readFileSync(path.join(buildDir, "lava-data.bin"));
var levelConstants = fs.readFileSync(path.join(buildDir,
  "level-constants.asm"), "utf8");
var worldMap = fs.readFileSync(path.join(buildDir, "world-map.bin"));
var originalWorld = JSON.parse(fs.readFileSync(process.env.WORLD_PATH || path.join(__dirname, "..", "bin",
  "assets", "world.json"), "utf8"));

if (xex.length < 12000 || xex[0] !== 255 || xex[1] !== 255) {
  throw new Error("Invalid or unexpectedly small XEX");
}
// MADS permits multiple ORG segments to overlap. Reject that explicitly so
// growing code/tables cannot silently overwrite packed graphics or the map.
var loaded = Buffer.alloc(65536);
var memory = Buffer.alloc(65536);
for (var offset = 0; offset < xex.length;) {
  if (offset + 2 > xex.length) throw new Error("Truncated XEX header");
  var first = xex.readUInt16LE(offset);
  offset += 2;
  if (first === 65535) continue;
  if (offset + 2 > xex.length) throw new Error("Truncated XEX segment");
  var last = xex.readUInt16LE(offset);
  offset += 2;
  if (last < first || offset + last - first + 1 > xex.length) {
    throw new Error("Invalid XEX segment length");
  }
  for (var address = first; address <= last; address += 1) {
    if (loaded[address]) throw new Error("Overlapping XEX segments at $" + address.toString(16));
    loaded[address] = 1;
    memory[address] = xex[offset++];
  }
}
var symbols = {};
labels.trim().split(/\r?\n/).forEach(function (line) {
  var fields = line.trim().split(/\s+/);
  if (fields.length === 3) symbols[fields[2].toLowerCase()] = parseInt(fields[1], 16);
});
[["lava_map", "lava-map.bin", 2880],
 ["map_row_lo", "map-row-offsets.bin", 480],
 ["terrain_colors", "terrain-colors.bin", 240]].forEach(function (entry) {
  var bytes = fs.readFileSync(path.join(buildDir, entry[1]));
  var start = symbols[entry[0]];
  if (bytes.length !== entry[2] || start === undefined ||
      !memory.subarray(start, start + bytes.length).equals(bytes)) {
    throw new Error("Missing or damaged terrain table: " + entry[1]);
  }
});
if (assets.length !== 16384) {
  throw new Error("Unexpected hero asset size: " + assets.length);
}
if (moverAssets.length !== 1024) {
  throw new Error("Unexpected mover asset size: " + moverAssets.length);
}
if (spikeAssets.length !== 4096 || cannonAssets.length !== 4096 ||
    cannonballAssets.length !== 512 || thwompAssets.length !== 3072 ||
    checkpointAssets.length !== 2048 || packedAssets.length !== 15616) {
  throw new Error("Unexpected hazard or packed asset size");
}
var unpackTable = [0, 20, 21, 22, 17, 18, 19, 16];
var unpackedAssets = Buffer.alloc(packedAssets.length * 2);
packedAssets.forEach(function (value, index) {
  unpackedAssets[index * 2] = unpackTable[value >> 4];
  unpackedAssets[index * 2 + 1] = unpackTable[value & 15];
});
if (!unpackedAssets.equals(Buffer.concat([assets, moverAssets, spikeAssets,
    cannonAssets, cannonballAssets, thwompAssets, checkpointAssets]))) {
  throw new Error("Packed VBXE graphics do not reproduce the source assets");
}
var moverDirections = {0: 2, 1: 3, 2: 0, 3: 1};
var originalMovers = originalWorld.layers[0].tiles.filter(function (cell) {
  return cell.tile === 13;
});
var expectedMovers = Buffer.alloc(originalMovers.length * 6);
originalMovers.forEach(function (cell, index) {
  var y = cell.y * 16 - 8;
  var speed = Math.max(8, Math.min(200, Math.round(Number(cell.speed) || 64)));
  var step = Math.round(speed / 50 * 256);
  expectedMovers[index * 6] = cell.x * 16 - 8;
  expectedMovers[index * 6 + 1] = y & 255;
  expectedMovers[index * 6 + 2] = y >> 8;
  expectedMovers[index * 6 + 3] = moverDirections[cell.rot];
  expectedMovers[index * 6 + 4] = step & 255;
  expectedMovers[index * 6 + 5] = step >> 8;
});
if (!moverData.equals(expectedMovers)) {
  throw new Error("Mover positions, directions, or speeds differ from world.json");
}
var originalCannons = originalWorld.layers[0].tiles.filter(function (cell) {
  return cell.tile === 14;
});
var expectedCannons = Buffer.alloc(originalCannons.length * 9);
originalCannons.forEach(function (cell, index) {
  var x = cell.x * 16 - 8;
  var y = cell.y * 16 - 8;
  var direction = ((Number(cell.rot) || 0) % 4 + 4) % 4;
  var speed = Math.max(50, Math.min(500,
    Math.round(Number(cell.bulletSpeed) || 350)));
  var component = Math.round(speed / Math.SQRT2 / 50 * 256);
  var negative = (-component) & 65535;
  var positive = component & 65535;
  var vx = direction === 0 || direction === 3 ? negative : positive;
  var vy = direction === 0 || direction === 1 ? negative : positive;
  expectedCannons[index * 9] = x;
  expectedCannons[index * 9 + 1] = y & 255;
  expectedCannons[index * 9 + 2] = y >> 8;
  expectedCannons[index * 9 + 3] = direction;
  expectedCannons[index * 9 + 4] = Math.round(x * 50 / 160);
  expectedCannons[index * 9 + 5] = vx & 255;
  expectedCannons[index * 9 + 6] = vx >> 8;
  expectedCannons[index * 9 + 7] = vy & 255;
  expectedCannons[index * 9 + 8] = vy >> 8;
});
if (!cannonData.equals(expectedCannons)) {
  throw new Error("Cannon positions, directions, or bullet speeds differ from world.json");
}

var originalSpikes = originalWorld.layers[0].tiles.filter(function (cell) {
  return cell.tile === 16;
});
var expectedSpikes = Buffer.alloc(originalSpikes.length * 4);
originalSpikes.forEach(function (cell, index) {
  var y = cell.y * 16 - 8;
  expectedSpikes[index] = cell.x * 16 - 8;
  expectedSpikes[originalSpikes.length + index] = y & 255;
  expectedSpikes[originalSpikes.length * 2 + index] = y >> 8;
  expectedSpikes[originalSpikes.length * 3 + index] = cell.rot;
});
if (!spikeData.equals(expectedSpikes)) {
  throw new Error("Spike positions or rotations differ from the original map");
}
var spikeStart = symbols.spike_initial;
if (spikeStart === undefined ||
    !memory.subarray(spikeStart, spikeStart + spikeData.length).equals(spikeData)) {
  throw new Error("Generated spike table is missing or damaged in the XEX");
}
var originalThwomps = originalWorld.layers[0].tiles.filter(function (cell) {
  return cell.tile === 17;
});
var expectedThwomps = Buffer.alloc(originalThwomps.length * 4);
originalThwomps.forEach(function (cell, index) {
  var y = cell.y * 16 - 8;
  expectedThwomps[index * 4] = cell.x * 16 - 8;
  expectedThwomps[index * 4 + 1] = y & 255;
  expectedThwomps[index * 4 + 2] = y >> 8;
  expectedThwomps[index * 4 + 3] = Math.max(1, Math.min(10, Math.round((Number(cell.speed) || 500) / 50)));
});
if (!thwompData.equals(expectedThwomps)) {
  throw new Error("Thwomp positions differ from the original map");
}
var originalCheckpoints = originalWorld.layers[0].tiles.filter(function (cell) {
  return cell.tile === 11;
});
var expectedCheckpoints = Buffer.alloc(originalCheckpoints.length * 4);
originalCheckpoints.forEach(function (cell, index) {
  var y = cell.y * 16 - 8;
  expectedCheckpoints[index * 4] = cell.x * 16 - 8;
  expectedCheckpoints[index * 4 + 1] = y & 255;
  expectedCheckpoints[index * 4 + 2] = y >> 8;
  expectedCheckpoints[index * 4 + 3] = cell.rot;
});
if (!checkpointData.equals(expectedCheckpoints)) {
  throw new Error("Checkpoint positions or rotations differ from the map");
}
var expectedCheckpointTeleports = Buffer.alloc(originalCheckpoints.length * 4);
originalCheckpoints.forEach(function (cell, index) {
  var towardCentre = cell.x >= originalWorld.tileswide / 2 ? -1 : 1;
  var candidates = [[cell.x + towardCentre, cell.y], [cell.x, cell.y],
    [cell.x - towardCentre, cell.y], [cell.x, cell.y - 1],
    [cell.x, cell.y + 1]];
  var destination = candidates.find(function (candidate) {
    var x = candidate[0], y = candidate[1];
    return x >= 1 && x < originalWorld.tileswide - 1 && y >= 0 &&
      y < originalWorld.tileshigh &&
      originalWorld.layers[0].tiles[y * originalWorld.tileswide + x].tile === -1;
  });
  if (!destination) throw new Error("Checkpoint lacks a safe teleport cell");
  var y = destination[1] * 16 - 1;
  expectedCheckpointTeleports[index * 4] = destination[0] * 16 - 8;
  expectedCheckpointTeleports[index * 4 + 1] = y & 255;
  expectedCheckpointTeleports[index * 4 + 2] = y >> 8;
});
if (!checkpointTeleportData.equals(expectedCheckpointTeleports)) {
  throw new Error("Checkpoint teleport destinations differ from world.json");
}
var checkpointTeleportStart = symbols.checkpoint_teleport;
if (checkpointTeleportStart === undefined ||
    !memory.subarray(checkpointTeleportStart,
      checkpointTeleportStart + checkpointTeleportData.length)
      .equals(checkpointTeleportData)) {
  throw new Error("Checkpoint teleport table is missing or damaged in the XEX");
}
var defaultLava = [
  {x: 2.5, y: 124.25, width: 5, height: 2.5},
  {x: 2.5, y: 134.25, width: 5, height: 2.5},
  {x: 8.25, y: 144.25, width: 2, height: 6},
  {x: -0.25, y: 148.25, width: 2, height: 6}
];
var configuredLava = originalWorld.grappleEditor &&
  Array.isArray(originalWorld.grappleEditor.lava) ?
  originalWorld.grappleEditor.lava : defaultLava;
var lavaCells = originalWorld.layers[0].tiles.filter(function (cell) {
  return cell.tile === 18;
});
if (lavaCells.length === 0) {
  configuredLava.forEach(function (rect) {
    var left = Number(rect.x) + 1;
    var top = Number(rect.y) + 1;
    for (var y = 0; y < 240; y += 1) {
      for (var x = 0; x < 12; x += 1) {
        if (x + 0.5 >= left && x + 0.5 < left + Number(rect.width) &&
            y + 0.5 >= top && y + 0.5 < top + Number(rect.height)) {
          lavaCells.push({x: x, y: y});
        }
      }
    }
  });
}
lavaCells = lavaCells.filter(function (cell) {
  var x = cell.x * 16 - 16;
  var y = cell.y * 16 - 16;
  return x >= 0 && x < 160 && y >= 0 && y < 65535;
});
var expectedLava = Buffer.alloc(Math.max(1, lavaCells.length) * 3);
if (lavaCells.length === 0) {
  expectedLava[0] = 255;
  expectedLava[1] = 255;
  expectedLava[2] = 255;
} else {
  lavaCells.forEach(function (cell, index) {
    var x = cell.x * 16 - 16;
    var y = cell.y * 16 - 16;
    expectedLava[index * 3] = x;
    expectedLava[index * 3 + 1] = y & 255;
    expectedLava[index * 3 + 2] = y >> 8;
  });
}
if (!lavaData.equals(expectedLava)) {
  throw new Error("Lava tiles differ from world.json");
}
if (!levelConstants.includes("LAVA_COUNT = " + Math.max(1, lavaCells.length))) {
  throw new Error("Generated lava count does not match lava-data.bin");
}
if (worldMap.length !== 12 * 240) {
  throw new Error("Unexpected world map size: " + worldMap.length);
}
var expectedLavaMap = Buffer.alloc(2880);
lavaCells.forEach(function (cell) { expectedLavaMap[cell.y * 12 + cell.x] = 1; });
if (!fs.readFileSync(path.join(buildDir, "lava-map.bin")).equals(expectedLavaMap)) {
  throw new Error("Hook lava lookup differs from map hazards");
}
var expectedWorldMap = Buffer.from(originalWorld.layers[0].tiles.map(
  function (cell) { return cell.tile >= 1 && cell.tile <= 10 ? cell.tile : 0; }));
lavaCells.forEach(function (cell) {
  expectedWorldMap[cell.y * 12 + cell.x] = 0;
});
if (!worldMap.equals(expectedWorldMap)) {
  throw new Error("World map solids differ from world.json");
}
["main", "update_player", "start_grapple", "advance_hook",
  "detect_player_water", "apply_player_drag", "draw_water",
  "point_in_lava", "collide_player", "update_movers", "draw_movers", "update_thwomps",
  "draw_thwomps", "check_player_thwomps", "update_camera",
  "draw_checkpoints", "check_player_checkpoints",
  "update_cannons", "update_cannonballs", "draw_cannons",
  "draw_cannonballs", "check_player_cannonballs", "check_player_hazards",
  "select_next_checkpoint", "select_previous_checkpoint",
  "draw_map", "draw_spikes", "draw_lava", "draw_hero",
  "draw_grapple", "detect_vbxe", "upload_assets",
  "present_back_buffer"].forEach(function (name) {
  if (labels.toLowerCase().indexOf(name.toLowerCase()) < 0) {
    throw new Error("Missing required symbol: " + name);
  }
});
console.log("PASS: grapple-vbxe.xex (" + xex.length + " bytes)");
