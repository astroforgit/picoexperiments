"use strict";

/*
 * Convert the original 16x16 RGBA hero frames to 32x32 VBXE pixels.  The
 * browser game is intentionally two-colour, so palette indexes remain stable:
 * zero is transparent, 20 is red, and 21 is white.
 */
var fs = require("fs");
var path = require("path");
var zlib = require("zlib");

function paeth(a, b, c) {
  var p = a + b - c;
  var pa = Math.abs(p - a);
  var pb = Math.abs(p - b);
  var pc = Math.abs(p - c);
  return pa <= pb && pa <= pc ? a : (pb <= pc ? b : c);
}

function decodeRgbaPng(filename) {
  var png = fs.readFileSync(filename);
  var offset = 8;
  var width = 0;
  var height = 0;
  var idat = [];
  var type;
  var length;
  var chunk;
  var raw;
  var pixels;
  var rgbaPixels;
  var bytesPerPixel = 0;
  var colorType = 0;
  var palette;
  var transparency;
  var source = 0;
  var rowBytes;
  var previous;
  var current;
  var y;
  var x;
  var filter;
  var value;

  if (png.toString("ascii", 1, 4) !== "PNG") {
    throw new Error("Not a PNG: " + filename);
  }
  while (offset < png.length) {
    length = png.readUInt32BE(offset);
    type = png.toString("ascii", offset + 4, offset + 8);
    chunk = png.subarray(offset + 8, offset + 8 + length);
    offset += length + 12;
    if (type === "IHDR") {
      width = chunk.readUInt32BE(0);
      height = chunk.readUInt32BE(4);
      colorType = chunk[9];
      bytesPerPixel = colorType === 6 ? 4 :
        (colorType === 4 ? 2 : (colorType === 3 ? 1 : 0));
      if (chunk[8] !== 8 || bytesPerPixel === 0 || chunk[12] !== 0) {
        throw new Error("Expected an 8-bit RGBA, grayscale-alpha, or indexed PNG");
      }
    } else if (type === "PLTE") {
      palette = Buffer.from(chunk);
    } else if (type === "tRNS") {
      transparency = Buffer.from(chunk);
    } else if (type === "IDAT") {
      idat.push(chunk);
    }
  }

  raw = zlib.inflateSync(Buffer.concat(idat));
  rowBytes = width * bytesPerPixel;
  pixels = Buffer.alloc(rowBytes * height);
  previous = Buffer.alloc(rowBytes);
  for (y = 0; y < height; y += 1) {
    filter = raw[source++];
    current = pixels.subarray(y * rowBytes, (y + 1) * rowBytes);
    for (x = 0; x < rowBytes; x += 1) {
      value = raw[source++];
      if (filter === 1) {
        value = (value + (x >= bytesPerPixel ?
          current[x - bytesPerPixel] : 0)) & 255;
      } else if (filter === 2) {
        value = (value + previous[x]) & 255;
      } else if (filter === 3) {
        value = (value + (((x >= bytesPerPixel ?
          current[x - bytesPerPixel] : 0) +
          previous[x]) >> 1)) & 255;
      } else if (filter === 4) {
        value = (value + paeth(x >= bytesPerPixel ?
          current[x - bytesPerPixel] : 0,
          previous[x], x >= bytesPerPixel ?
          previous[x - bytesPerPixel] : 0)) & 255;
      } else if (filter !== 0) {
        throw new Error("Unsupported PNG filter " + filter);
      }
      current[x] = value;
    }
    previous = Buffer.from(current);
  }
  if (colorType === 3) {
    if (!palette) {
      throw new Error("Indexed PNG is missing its palette");
    }
    rgbaPixels = Buffer.alloc(width * height * 4);
    for (x = 0; x < width * height; x += 1) {
      var paletteIndex = pixels[x];
      rgbaPixels[x * 4] = palette[paletteIndex * 3];
      rgbaPixels[x * 4 + 1] = palette[paletteIndex * 3 + 1];
      rgbaPixels[x * 4 + 2] = palette[paletteIndex * 3 + 2];
      rgbaPixels[x * 4 + 3] = transparency &&
        paletteIndex < transparency.length ? transparency[paletteIndex] : 255;
    }
    pixels = rgbaPixels;
  } else if (bytesPerPixel === 2) {
    rgbaPixels = Buffer.alloc(width * height * 4);
    for (x = 0; x < width * height; x += 1) {
      rgbaPixels[x * 4] = pixels[x * 2];
      rgbaPixels[x * 4 + 1] = pixels[x * 2];
      rgbaPixels[x * 4 + 2] = pixels[x * 2];
      rgbaPixels[x * 4 + 3] = pixels[x * 2 + 1];
    }
    pixels = rgbaPixels;
  }
  return {width: width, height: height, pixels: pixels};
}

var source = decodeRgbaPng(path.join(__dirname, "..", "bin", "assets",
  "player.png"));
var originalFrames = [0, 1, 2, 3, 5, 6, 7, 8, 9, 11, 12, 13, 14, 15, 17, 18];
var output = Buffer.alloc(originalFrames.length * 1024);

originalFrames.forEach(function (frame, slot) {
  var frameX = (frame % 5) * 16;
  var frameY = Math.floor(frame / 5) * 16;
  var y;
  var x;
  var sourceOffset;
  var paletteIndex;
  for (y = 0; y < 32; y += 1) {
    for (x = 0; x < 32; x += 1) {
      sourceOffset = ((frameY + (y >> 1)) * source.width +
        frameX + (x >> 1)) * 4;
      if (source.pixels[sourceOffset + 3] === 0) {
        paletteIndex = 0;
      } else if (source.pixels[sourceOffset] > 240 &&
          source.pixels[sourceOffset + 1] < 16) {
        paletteIndex = 20;
      } else {
        paletteIndex = 21;
      }
      output[slot * 1024 + y * 32 + x] = paletteIndex;
    }
  }
});

fs.writeFileSync(path.join(__dirname, "player-assets.bin"), output);
console.log("Generated player-assets.bin (" + output.length + " bytes, " +
  originalFrames.length + " original frames)");

var moverSource = decodeRgbaPng(path.join(__dirname, "..", "bin", "assets",
  "mover.png"));
if (moverSource.width !== 16 || moverSource.height !== 16) {
  throw new Error("Expected a 16x16 mover sprite");
}
var moverOutput = Buffer.alloc(1024);
for (var moverY = 0; moverY < 32; moverY += 1) {
  for (var moverX = 0; moverX < 32; moverX += 1) {
    var moverOffset = ((moverY >> 1) * 16 + (moverX >> 1)) * 4;
    var moverColor = 0;
    if (moverSource.pixels[moverOffset + 3] !== 0) {
      moverColor = moverSource.pixels[moverOffset] > 200 ? 21 : 22;
    }
    moverOutput[moverY * 32 + moverX] = moverColor;
  }
}
fs.writeFileSync(path.join(__dirname, "mover-assets.bin"), moverOutput);
console.log("Generated mover-assets.bin (" + moverOutput.length + " bytes)");

var spikeSource = decodeRgbaPng(path.join(__dirname, "..", "bin", "assets",
  "spikes.png"));
if (spikeSource.width !== 16 || spikeSource.height !== 16) {
  throw new Error("Expected a 16x16 spike sprite");
}

/*
 * Pre-rotate the original art in all four tile orientations. This keeps the
 * 6502 renderer small and preserves the exact rotation stored by Pyxel Edit.
 */
var spikeOutput = Buffer.alloc(4 * 1024);
for (var spikeRot = 0; spikeRot < 4; spikeRot += 1) {
  for (var spikeY = 0; spikeY < 32; spikeY += 1) {
    for (var spikeX = 0; spikeX < 32; spikeX += 1) {
      var destX = spikeX >> 1;
      var destY = spikeY >> 1;
      var sourceX;
      var sourceY;
      if (spikeRot === 0) {
        sourceX = destX;
        sourceY = destY;
      } else if (spikeRot === 1) {
        sourceX = destY;
        sourceY = 15 - destX;
      } else if (spikeRot === 2) {
        sourceX = 15 - destX;
        sourceY = 15 - destY;
      } else {
        sourceX = 15 - destY;
        sourceY = destX;
      }
      var spikeOffset = (sourceY * 16 + sourceX) * 4;
      spikeOutput[spikeRot * 1024 + spikeY * 32 + spikeX] =
        spikeSource.pixels[spikeOffset + 3] === 0 ? 0 : 21;
    }
  }
}
fs.writeFileSync(path.join(__dirname, "spike-assets.bin"), spikeOutput);
console.log("Generated spike-assets.bin (" + spikeOutput.length + " bytes)");

var cannonSource = decodeRgbaPng(path.join(__dirname, "..", "bin", "assets",
  "cannon.png"));
if (cannonSource.width !== 16 || cannonSource.height !== 16) {
  throw new Error("Expected a 16x16 cannon sprite");
}
var cannonOutput = Buffer.alloc(4 * 1024);
for (var cannonRot = 0; cannonRot < 4; cannonRot += 1) {
  for (var cannonY = 0; cannonY < 32; cannonY += 1) {
    for (var cannonX = 0; cannonX < 32; cannonX += 1) {
      var cannonDestX = cannonX >> 1;
      var cannonDestY = cannonY >> 1;
      var cannonSourceX;
      var cannonSourceY;
      if (cannonRot === 0) {
        cannonSourceX = cannonDestX;
        cannonSourceY = cannonDestY;
      } else if (cannonRot === 1) {
        cannonSourceX = cannonDestY;
        cannonSourceY = 15 - cannonDestX;
      } else if (cannonRot === 2) {
        cannonSourceX = 15 - cannonDestX;
        cannonSourceY = 15 - cannonDestY;
      } else {
        cannonSourceX = 15 - cannonDestY;
        cannonSourceY = cannonDestX;
      }
      var cannonOffset = (cannonSourceY * 16 + cannonSourceX) * 4;
      var cannonColor = 0;
      if (cannonSource.pixels[cannonOffset + 3] !== 0) {
        cannonColor = cannonSource.pixels[cannonOffset] > 200 ? 21 : 22;
      }
      cannonOutput[cannonRot * 1024 + cannonY * 32 + cannonX] = cannonColor;
    }
  }
}
fs.writeFileSync(path.join(__dirname, "cannon-assets.bin"), cannonOutput);
console.log("Generated cannon-assets.bin (" + cannonOutput.length + " bytes)");

var cannonballSource = decodeRgbaPng(path.join(__dirname, "..", "bin",
  "assets", "cannonball.png"));
if (cannonballSource.width !== 10 || cannonballSource.height !== 10) {
  throw new Error("Expected a 10x10 cannonball sprite");
}
/* 20x20 art followed by zero padding to two complete VBXE pages. */
var cannonballOutput = Buffer.alloc(512);
for (var ballY = 0; ballY < 20; ballY += 1) {
  for (var ballX = 0; ballX < 20; ballX += 1) {
    var ballOffset = ((ballY >> 1) * 10 + (ballX >> 1)) * 4;
    var ballColor = 0;
    if (cannonballSource.pixels[ballOffset + 3] !== 0) {
      ballColor = cannonballSource.pixels[ballOffset] > 200 ? 21 : 22;
    }
    cannonballOutput[ballY * 20 + ballX] = ballColor;
  }
}
fs.writeFileSync(path.join(__dirname, "cannonball-assets.bin"),
  cannonballOutput);
console.log("Generated cannonball-assets.bin (" + cannonballOutput.length +
  " bytes including page padding)");

var thwompSource = decodeRgbaPng(path.join(__dirname, "..", "bin", "assets",
  "thwomp.png"));
if (thwompSource.width !== 48 || thwompSource.height !== 16) {
  throw new Error("Expected a 48x16 three-frame thwomp sprite");
}
var thwompOutput = Buffer.alloc(3 * 1024);
for (var thwompFrame = 0; thwompFrame < 3; thwompFrame += 1) {
  for (var thwompY = 0; thwompY < 32; thwompY += 1) {
    for (var thwompX = 0; thwompX < 32; thwompX += 1) {
      var thwompOffset = ((thwompY >> 1) * thwompSource.width +
        thwompFrame * 16 + (thwompX >> 1)) * 4;
      var thwompColor = 0;
      if (thwompSource.pixels[thwompOffset + 3] !== 0) {
        var thwompRed = thwompSource.pixels[thwompOffset];
        var thwompGreen = thwompSource.pixels[thwompOffset + 1];
        var thwompBlue = thwompSource.pixels[thwompOffset + 2];
        thwompColor = thwompRed > 200 && thwompGreen < 80 &&
          thwompBlue < 80 ? 20 :
          (thwompRed + thwompGreen + thwompBlue > 600 ? 21 : 22);
      }
      thwompOutput[thwompFrame * 1024 + thwompY * 32 + thwompX] =
        thwompColor;
    }
  }
}
fs.writeFileSync(path.join(__dirname, "thwomp-assets.bin"), thwompOutput);
console.log("Generated thwomp-assets.bin (" + thwompOutput.length +
  " bytes, three original frames)");

var checkpointSource = decodeRgbaPng(path.join(__dirname, "..", "bin",
  "assets", "checkpoint.png"));
if (checkpointSource.width !== 32 || checkpointSource.height !== 16) {
  throw new Error("Expected a 32x16 two-frame checkpoint sprite");
}
var checkpointOutput = Buffer.alloc(2 * 1024);
for (var checkpointFrame = 0; checkpointFrame < 2; checkpointFrame += 1) {
  for (var checkpointY = 0; checkpointY < 32; checkpointY += 1) {
    for (var checkpointX = 0; checkpointX < 32; checkpointX += 1) {
      var checkpointOffset = ((checkpointY >> 1) * checkpointSource.width +
        checkpointFrame * 16 + (checkpointX >> 1)) * 4;
      checkpointOutput[checkpointFrame * 1024 + checkpointY * 32 +
        checkpointX] = checkpointSource.pixels[checkpointOffset + 3] === 0 ?
        0 : 21;
    }
  }
}
fs.writeFileSync(path.join(__dirname, "checkpoint-assets.bin"), checkpointOutput);
console.log("Generated checkpoint-assets.bin (" + checkpointOutput.length +
  " bytes, low and high frames)");

/* Pack two palette codes per byte for safe storage below the VBXE CPU window. */
var assetCode = {0: 0, 20: 1, 21: 2, 22: 3};
var unpackedAssets = Buffer.concat([output, moverOutput, spikeOutput,
  cannonOutput, cannonballOutput, thwompOutput, checkpointOutput]);
var packedAssets = Buffer.alloc(unpackedAssets.length >> 1);
for (var packedIndex = 0; packedIndex < packedAssets.length;
    packedIndex += 1) {
  var firstCode = assetCode[unpackedAssets[packedIndex * 2]];
  var secondCode = assetCode[unpackedAssets[packedIndex * 2 + 1]];
  if (firstCode === undefined || secondCode === undefined) {
    throw new Error("Asset contains a palette index that cannot be packed");
  }
  packedAssets[packedIndex] = (firstCode << 4) | secondCode;
}
fs.writeFileSync(path.join(__dirname, "assets-packed.bin"), packedAssets);
console.log("Generated assets-packed.bin (" + packedAssets.length +
  " bytes from " + unpackedAssets.length + " VBXE pixels)");

/*
 * Keep the original 12x240 level layout, but reduce each cell to the data the
 * scrolling game needs. Tiles 1..10 are the browser game's solid world
 * tiles. Entity positions are emitted separately below.
 */
var world = JSON.parse(fs.readFileSync(path.join(__dirname, "..", "bin",
  "assets", "world.json"), "utf8"));
if (world.tileswide !== 12 || world.tileshigh !== 240 ||
    world.layers.length !== 1) {
  throw new Error("Expected the original 12x240 single-layer world map");
}

var sourceTiles = world.layers[0].tiles;
var worldMap = Buffer.alloc(world.tileswide * world.tileshigh);
if (sourceTiles.length !== worldMap.length) {
  throw new Error("Unexpected world tile count: " + sourceTiles.length);
}

sourceTiles.forEach(function (cell, index) {
  worldMap[index] = cell.tile >= 1 && cell.tile <= 10 ? cell.tile : 0;
});

var moverDirections = {0: 2, 1: 3, 2: 0, 3: 1};
var moverCells = sourceTiles.filter(function (cell) { return cell.tile === 13; });
if (moverCells.length !== 6) {
  throw new Error("Expected six original mover entities");
}
var moverData = Buffer.alloc(moverCells.length * 6);
moverCells.forEach(function (cell, index) {
  var worldX = cell.x * 16 - 8;
  var worldY = cell.y * 16 - 8;
  var speed = Math.max(8, Math.min(200, Math.round(Number(cell.speed) || 64)));
  var speedStep = Math.round(speed / 50 * 256);
  moverData[index * 6] = worldX;
  moverData[index * 6 + 1] = worldY & 255;
  moverData[index * 6 + 2] = worldY >> 8;
  moverData[index * 6 + 3] = moverDirections[cell.rot];
  moverData[index * 6 + 4] = speedStep & 255;
  moverData[index * 6 + 5] = speedStep >> 8;
});
fs.writeFileSync(path.join(__dirname, "mover-data.bin"), moverData);
console.log("Generated mover-data.bin (" + moverCells.length +
  " VBXE movers with individual speeds)");

var cannonCells = sourceTiles.filter(function (cell) { return cell.tile === 14; });
if (cannonCells.length !== 3) {
  throw new Error("Expected three original cannon entities");
}
var cannonData = Buffer.alloc(cannonCells.length * 9);
cannonCells.forEach(function (cell, index) {
  var worldX = cell.x * 16 - 8;
  var worldY = cell.y * 16 - 8;
  var bulletSpeed = Math.max(50, Math.min(500,
    Math.round(Number(cell.bulletSpeed) || 350)));
  var component = Math.round(bulletSpeed / Math.SQRT2 / 50 * 256);
  var negative = (-component) & 65535;
  var positive = component & 65535;
  var direction = ((Number(cell.rot) || 0) % 4 + 4) % 4;
  var vx = direction === 0 || direction === 3 ? negative : positive;
  var vy = direction === 0 || direction === 1 ? negative : positive;
  cannonData[index * 9] = worldX;
  cannonData[index * 9 + 1] = worldY & 255;
  cannonData[index * 9 + 2] = worldY >> 8;
  cannonData[index * 9 + 3] = direction;
  cannonData[index * 9 + 4] = Math.round(worldX * 50 / 160);
  cannonData[index * 9 + 5] = vx & 255;
  cannonData[index * 9 + 6] = vx >> 8;
  cannonData[index * 9 + 7] = vy & 255;
  cannonData[index * 9 + 8] = vy >> 8;
});
fs.writeFileSync(path.join(__dirname, "cannon-data.bin"), cannonData);
console.log("Generated cannon-data.bin (" + cannonCells.length +
  " VBXE cannons with individual bullet speeds)");

var spikeCells = sourceTiles.filter(function (cell) { return cell.tile === 16; });
if (spikeCells.length !== 41) {
  throw new Error("Expected 41 original spike entities");
}
var spikeData = Buffer.alloc(spikeCells.length * 4);
spikeCells.forEach(function (cell, index) {
  var worldX = cell.x * 16 - 8;
  var worldY = cell.y * 16 - 8;
  spikeData[index * 4] = worldX;
  spikeData[index * 4 + 1] = worldY & 255;
  spikeData[index * 4 + 2] = worldY >> 8;
  spikeData[index * 4 + 3] = cell.rot;
});
fs.writeFileSync(path.join(__dirname, "spike-data.bin"), spikeData);
console.log("Generated spike-data.bin (" + spikeCells.length +
  " original spikes)");

var thwompCells = sourceTiles.filter(function (cell) { return cell.tile === 17; });
if (thwompCells.length !== 9) {
  throw new Error("Expected nine original thwomp entities");
}
var thwompData = Buffer.alloc(thwompCells.length * 3);
thwompCells.forEach(function (cell, index) {
  var worldX = cell.x * 16 - 8;
  var worldY = cell.y * 16 - 8;
  thwompData[index * 3] = worldX;
  thwompData[index * 3 + 1] = worldY & 255;
  thwompData[index * 3 + 2] = worldY >> 8;
});
fs.writeFileSync(path.join(__dirname, "thwomp-data.bin"), thwompData);
console.log("Generated thwomp-data.bin (" + thwompCells.length +
  " original thwomps)");

var checkpointCells = sourceTiles.filter(function (cell) {
  return cell.tile === 11;
});
if (checkpointCells.length !== 11) {
  throw new Error("Expected eleven original checkpoint entities");
}
var checkpointData = Buffer.alloc(checkpointCells.length * 4);
checkpointCells.forEach(function (cell, index) {
  var worldX = cell.x * 16 - 8;
  var worldY = cell.y * 16 - 8;
  checkpointData[index * 4] = worldX;
  checkpointData[index * 4 + 1] = worldY & 255;
  checkpointData[index * 4 + 2] = worldY >> 8;
  checkpointData[index * 4 + 3] = cell.rot;
});
fs.writeFileSync(path.join(__dirname, "checkpoint-data.bin"), checkpointData);
console.log("Generated checkpoint-data.bin (" + checkpointCells.length +
  " original checkpoints)");

/* Editor format v2 stores lava as ordinary tile-18 cells. Legacy rectangle
 * metadata is rasterized using the same cell-centre rule as the editor. */
var defaultLava = [
  {x: 2.5, y: 124.25, width: 5, height: 2.5},
  {x: 2.5, y: 134.25, width: 5, height: 2.5},
  {x: 8.25, y: 144.25, width: 2, height: 6},
  {x: -0.25, y: 148.25, width: 2, height: 6}
];
var lavaCells = sourceTiles.filter(function (cell) { return cell.tile === 18; });
if (lavaCells.length === 0) {
  var sourceLava = world.grappleEditor &&
    Array.isArray(world.grappleEditor.lava) ? world.grappleEditor.lava : defaultLava;
  sourceLava.forEach(function (rect, index) {
    var values = [rect.x, rect.y, rect.width, rect.height].map(Number);
    if (!values.every(Number.isFinite) || values[2] <= 0 || values[3] <= 0) {
      throw new Error("Invalid legacy lava rectangle " + (index + 1));
    }
    var left = values[0] + 1;
    var top = values[1] + 1;
    for (var lavaY = 0; lavaY < world.tileshigh; lavaY += 1) {
      for (var lavaX = 0; lavaX < world.tileswide; lavaX += 1) {
        if (lavaX + 0.5 >= left && lavaX + 0.5 < left + values[2] &&
            lavaY + 0.5 >= top && lavaY + 0.5 < top + values[3]) {
          lavaCells.push({x: lavaX, y: lavaY, tile: 18});
        }
      }
    }
  });
}
var lavaRects = lavaCells.map(function (cell) {
  return [cell.x * 16 - 16, cell.y * 16 - 16, 16, 16];
}).filter(function (rect) {
  return rect[0] >= 0 && rect[0] < 160 && rect[1] >= 0 && rect[1] < 65535;
});
if (lavaRects.length > 85) {
  throw new Error("VBXE supports at most 85 lava tiles; found " +
    lavaRects.length);
}
lavaCells.forEach(function (cell) {
  worldMap[cell.y * world.tileswide + cell.x] = 0;
});
fs.writeFileSync(path.join(__dirname, "world-map.bin"), worldMap);
console.log("Generated world-map.bin (" + worldMap.length + " bytes, " +
  worldMap.reduce(function (count, tile) { return count + (tile !== 0); }, 0) +
  " solid tiles)");
var storedLava = lavaRects.length ? lavaRects : [[255, 65535, 16, 16]];
var lavaData = Buffer.alloc(storedLava.length * 3);
storedLava.forEach(function (rect, index) {
  lavaData[index * 3] = rect[0];
  lavaData[index * 3 + 1] = rect[1] & 255;
  lavaData[index * 3 + 2] = rect[1] >> 8;
});
fs.writeFileSync(path.join(__dirname, "lava-data.bin"), lavaData);
fs.writeFileSync(path.join(__dirname, "level-constants.asm"),
  "; Generated by generate_assets.js\nLAVA_COUNT = " + storedLava.length + "\n");
console.log("Generated lava-data.bin (" + lavaRects.length + " lava tiles)");
