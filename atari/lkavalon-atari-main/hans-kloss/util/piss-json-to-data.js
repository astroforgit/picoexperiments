#!/usr/bin/env node
'use strict';

const fs = require('fs');

const inputPath = process.argv[2];
const outputPath = process.argv[3];

if (!inputPath || !outputPath) {
  console.error('Usage: node util/piss-json-to-data.js INPUT.json OUTPUT.DTA');
  process.exit(2);
}

const sprite = JSON.parse(fs.readFileSync(inputPath, 'utf8'));

if (sprite.format !== 'hans-kloss-piss-sprite-v1' || sprite.width !== 8 || sprite.height !== 32 || sprite.frameCount !== 6) {
  throw new Error('Unsupported sprite export: expected hans-kloss-piss-sprite-v1, 8x32, six frames');
}

const output = [];

for (const direction of ['right', 'left']) {
  const frames = sprite.frames && sprite.frames[direction];
  if (!Array.isArray(frames) || frames.length !== 6) {
    throw new Error(`Direction ${direction} must contain six frames`);
  }

  for (let frameIndex = 0; frameIndex < frames.length; frameIndex++) {
    const frame = frames[frameIndex];
    for (const planeName of ['plane2', 'plane3']) {
      const plane = frame && frame[planeName];
      if (!Array.isArray(plane) || plane.length !== 32) {
        throw new Error(`${direction} frame ${frameIndex + 1} ${planeName} must contain 32 bytes`);
      }
      for (const value of plane) {
        if (!Number.isInteger(value) || value < 0 || value > 255) {
          throw new Error(`${direction} frame ${frameIndex + 1} ${planeName} contains an invalid byte`);
        }
        output.push(value);
      }
    }
  }
}

if (output.length !== 768) throw new Error(`Internal error: expected 768 bytes, got ${output.length}`);

fs.writeFileSync(outputPath, Buffer.from(output));
console.log(`Wrote ${output.length} bytes to ${outputPath}`);
