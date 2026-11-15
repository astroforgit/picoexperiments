const assert = require('node:assert/strict');
const zlib = require('node:zlib');
const G2F = require('./g2f.js');
const MCH = require('./mch.js');
const fixture = require('./g2f.fixture.cjs');
const bytes = fixture();
const image = G2F.decode(bytes);
assert.equal(image.width, 168);
assert.equal(image.height, 240);
assert.deepEqual([...image.pixels.slice(4, 12)], [0,16,32,48,0,16,32,64]);
assert.equal(image.pixels[168 + 5], 42, 'per-scanline colour change');
assert.equal(image.pixels[168 * 8 + 4], 48, 'second character set');
assert.equal(image.pixels[168 * 2 + 12], 80, 'player overlay');
for (const options of [{level:0},{level:9},{strategy:zlib.constants.Z_FIXED}]) {
  const compressed = Buffer.concat([Buffer.from('G2FZLIB'), zlib.deflateSync(bytes, options)]);
  assert.deepEqual(G2F.decode(compressed), image);
}
for (const width of [32,40,48]) assert.equal(G2F.decode(fixture(width)).pixels.length, 168 * 240);
assert.throws(() => G2F.decode(bytes.subarray(0, 100)), /Invalid or unsupported/);
assert.throws(() => G2F.decode(Buffer.from('G2FZLIBbroken')), /Invalid or unsupported/);
assert.throws(() => G2F.decode(Buffer.alloc(1024*1024+1)), /limit/);
const bad = bytes.slice(); bad[0]=31; assert.throws(() => G2F.decode(bad));
const crop = MCH.convert(image,1,0,null,c=>[c,c,c]);
assert.equal(crop.cells.length,880);
// Optional real upstream samples, kept outside the repository.
if (process.env.G2F_EXAMPLES) {
  const fs = require('node:fs');
  for (const name of fs.readdirSync(process.env.G2F_EXAMPLES).filter(n=>/\.g2f$/i.test(n))) {
    const data=fs.readFileSync(process.env.G2F_EXAMPLES+'/'+name);
    const raw=data.subarray(0,7).toString()==='G2FZLIB' ? zlib.inflateSync(data.subarray(7)) : data;
    assert.deepEqual(G2F.decode(data),G2F.decode(raw),name);
    console.log('Decoded real project:', name);
  }
}
console.log('Native G2F pixels, inverse, fonts, DLI colours, player, widths, zlib variants and malformed input passed.');
