const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const lab = require('./encounter.js');
const game = () => JSON.parse(fs.readFileSync(path.join(__dirname, '../data/game.json')));
test('fixed damage, first strike, XP and no mutation', () => {
  const g = game(), original = JSON.stringify(g);
  const rat = lab.simulate(g, [2]);
  assert.equal(rat.outcome, 'victory'); assert.equal(rat.hp, 6); assert.equal(rat.turn, 1);
  const ghoul = lab.simulate(g, [3]);
  assert.equal(ghoul.hp, 5); assert.equal(ghoul.turn, 2);
  assert.equal(JSON.stringify(g), original);
});
test('kills level up and refill HP using the real XP table', () => {
  const r = lab.simulate(game(), Array(5).fill(2), { mode: 'sequence' });
  assert.equal(r.outcome, 'victory'); assert.equal(r.level, 2); assert.equal(r.hp, 9);
});
test('groups retaliate together; sequential fights do not', () => {
  assert.equal(lab.simulate(game(), [3, 3], { mode: 'group' }).hp, 2);
  assert.equal(lab.simulate(game(), [3, 3], { mode: 'sequence' }).hp, 4);
});
test('poison, paralysis and unsupported abilities are explicit', () => {
  const g = game(); g.monsters[21].hp = 100;
  const r = lab.simulate(g, [22]); assert.equal(r.outcome, 'defeat');
  assert.ok(r.log.some(e => e.message.includes('Poison')));
  g.params.paralyze_chance = 1;
  assert.ok(lab.simulate(g, [23]).log.some(e => e.message.includes('cannot act')));
  assert.deepEqual(lab.simulate(g, [14]).warnings, ['bolt']);
});
test('seeds are reproducible and zero damage cannot loop forever', () => {
  const g = game();
  assert.deepEqual(lab.simulate(g, [23], { seed: 90 }), lab.simulate(g, [23], { seed: 90 }));
  g.monsters[0].atk = 0; g.monsters[1].atk = 0;
  assert.equal(lab.simulate(g, [2]).outcome, 'turn limit');
});
test('designs have starts, exits or bosses and reproducible legal enemy placements', () => {
  const g = game();
  for (let d = 1; d <= 8; d++) {
    const f = lab.sampleFloor(g, d, 42);
    assert.deepEqual(f, lab.sampleFloor(g, d, 42));
    assert.equal(f.tiles.length, 32); assert.ok(f.tiles.every(r => r.length === 256));
    const codes = f.tiles.flatMap(row => row.match(/../g).map(n => parseInt(n, 16)));
    assert.equal(codes.filter(n => n === g.params.tile_start).length, 1);
    if (d < 8) assert.equal(codes.filter(n => n === g.params.tile_exit).length, 1);
    else assert.ok(lab.roster(g, f).some(e => e.id === g.params.boss_id));
    assert.equal(lab.roster(g, f).length, g.budget[d - 1] + 1 + Math.max(0, g.mimic_offset[d - 1] + 1) + (d === 8 ? 1 : 0));
  }
  assert.notDeepEqual(lab.sampleFloor(g, 4, 1), lab.sampleFloor(g, 4, 2));
});
test('empty eligible pool is bounded; invalid encounter IDs are rejected', () => {
  const g = game(); g.monsters.forEach(m => m.depth = 99);
  assert.equal(lab.roster(g, lab.sampleFloor(g, 1, 0)).length, 0);
  assert.throws(() => lab.simulate(g, [999]));
});
