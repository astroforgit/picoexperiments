const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');
const MCH = require('./mch.js');
function fixture(columns = 40) {
  const b = new Uint8Array(columns * 30 * 9 + 1200); b[0] = 5;
  for (let c = 0; c < 5; c++) b.fill(c * 32, columns * 270 + c * 240, columns * 270 + (c + 1) * 240);
  return b;
}
const b = fixture(); b[1] = 0x1b; b[9] = 128; b[10] = 255;
let image = MCH.decode(b, 40);
assert.deepEqual([...image.pixels.slice(0, 8)], [0, 32, 64, 96, 128, 128, 128, 128]);
b[10800 + 240 + 1] = 42; b[2] = 0x40;
assert.equal(MCH.decode(b, 40).pixels[160], 42, 'scanline palette');
for (const width of [32, 40, 48]) assert.equal(MCH.decode(fixture(width), width).width, width * 4);
assert.throws(() => MCH.decode(b.slice(1), 40));
assert.throws(() => MCH.decode(b, 32));
const bad = b.slice(); bad[9] = 1; assert.throws(() => MCH.decode(bad, 40));
assert.throws(() => MCH.convert(image, -1, 0, null, c => [c,c,c]));
const small = MCH.decode(fixture(32), 32);
assert.equal(MCH.convert(small, 0, 0, null, c => [c,c,c]).cells.length, 880);

// Exercise the actual editor's XEX reader, planner, writer and history.
const noop = () => {};
const element = () => ({ addEventListener: noop, setAttribute: noop, classList: { toggle: noop }, getContext: () => ({}) });
const context = vm.createContext({ MCH, Uint8Array, Int32Array, console,
  document: { getElementById: element, createElement: element, addEventListener: noop },
  location: { protocol: 'file:' }, fetch: async () => { throw Error('offline'); }, setTimeout: noop });
const html = fs.readFileSync(__dirname + '/index.html', 'utf8');
vm.runInContext(html.match(/<script>\s*([\s\S]*?)<\/script>/)[1], context);
context.original = new Uint8Array(fs.readFileSync(__dirname + '/../Zorro (1985)(Datasoft)(US).xex'));
context.testImage = MCH.decode(fixture(), 40);
vm.runInContext(`
loadXex(original.slice());
refreshAll = () => {}; refreshThumbs = () => {}; updateButtons = () => {};
`, context);
for (const testImage of [MCH.decode(fixture(),40), require('./g2f.js').decode(require('./g2f.fixture.cjs')())]) {
context.testImage = testImage;
for (let r = 0; r < 21; r++) {
  context.testRoom = r;
  const result = vm.runInContext(`(() => {
    const before = file.slice();
    const plan = planMch(testImage, 0, 0, false, testRoom);
    if (plan.errors.length) throw Error(plan.errors.join(' '));
    checkpoint(); plan.writes.forEach(([a,b]) => poke(a,b));
    const edited = file.slice();
    const map = decodeMap(roomMapAddr(testRoom)).cells;
    restore(undoStack, redoStack);
    const undone = file.slice(); restore(redoStack, undoStack);
    const redone = file.slice(); loadXex(edited.slice());
    const reloaded = decodeMap(roomMapAddr(testRoom)).cells;
    loadXex(before.slice()); undoStack=[]; redoStack=[];
    return {before, edited, undone, redone, map, reloaded};
  })()`, context);
  assert.equal(result.map.length, 880);
  assert.ok(result.map.every(v => v >= 0 && v < 128));
  assert.deepEqual(result.before, result.undone);
  assert.deepEqual(result.edited, result.redone);
  assert.deepEqual(result.map, result.reloaded);
  assert.equal(result.edited.length, result.before.length);
}
}
// Noise must exceed the tile budget, and planning/rejection must not write bytes.
context.noise = { width:160, height:176, background:0, pixels:Uint8Array.from({length:28160}, (_, i) => ((Math.imul(i + 1, 2654435761) >>> ((i % 19) + 1)) & 3) * 32) };
const rejected = vm.runInContext(`(() => {
  const before = file.slice();
  const p = planMch(noise,0,0,false,5);
  return { errors:p.errors, before, after:file.slice() };
})()`, context);
assert.ok(rejected.errors.some(e => e.includes('unique tiles')));
assert.deepEqual(rejected.before, rejected.after);
console.log('MCH decoding, conversion, invalid inputs, MCH and G2F imports into all 21 rooms, undo/redo and XEX reload passed.');
