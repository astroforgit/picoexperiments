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
      if (chunk[8] !== 8 || chunk[9] !== 6 || chunk[12] !== 0) {
        throw new Error("Expected an 8-bit, RGBA, non-interlaced PNG");
      }
    } else if (type === "IDAT") {
      idat.push(chunk);
    }
  }

  raw = zlib.inflateSync(Buffer.concat(idat));
  rowBytes = width * 4;
  pixels = Buffer.alloc(rowBytes * height);
  previous = Buffer.alloc(rowBytes);
  for (y = 0; y < height; y += 1) {
    filter = raw[source++];
    current = pixels.subarray(y * rowBytes, (y + 1) * rowBytes);
    for (x = 0; x < rowBytes; x += 1) {
      value = raw[source++];
      if (filter === 1) {
        value = (value + (x >= 4 ? current[x - 4] : 0)) & 255;
      } else if (filter === 2) {
        value = (value + previous[x]) & 255;
      } else if (filter === 3) {
        value = (value + (((x >= 4 ? current[x - 4] : 0) +
          previous[x]) >> 1)) & 255;
      } else if (filter === 4) {
        value = (value + paeth(x >= 4 ? current[x - 4] : 0,
          previous[x], x >= 4 ? previous[x - 4] : 0)) & 255;
      } else if (filter !== 0) {
        throw new Error("Unsupported PNG filter " + filter);
      }
      current[x] = value;
    }
    previous = Buffer.from(current);
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
