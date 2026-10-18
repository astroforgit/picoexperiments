'use strict';
const assert = require('node:assert/strict');
const a = require('../editor-balance.js');
const d = require('../greenhaven-unit-balance.json');
assert.deepEqual(a.validate(d), []);
const bands = a.difficultyBands(d);
for (let r = 1; r < 4; r++) assert(bands[r].min > bands[r - 1].max, JSON.stringify(bands));
let state = a.createCampaign(d);
assert(a.isUnlocked(d,state,0));
for(let r=1;r<4;r++){assert(!a.isUnlocked(d,state,r));assert.throws(()=>a.beginEncounter(d,state,r));}
for(let r=0;r<4;r++){
 for(let win=0;win<3;win++){
  state = a.beginEncounter(d,state,r);
  const encounter = structuredClone(state.pending.encounter), gold = state.gold;
  assert.equal(encounter.stage,win+1);
  if(r===3&&win===2)assert.equal(encounter.victory,'Defeat the Warlock');else assert(encounter.enemies.every(u=>u.id!=='warlock'));
  const lost = a.recordResult(d,state,'defeat');assert.equal(lost.gold,gold);assert.equal(lost.wins[r],win);
  assert.deepEqual(a.beginEncounter(d,lost,r).pending.encounter,encounter);
  const retreat = a.recordResult(d,lost,'retreat');assert.equal(retreat.gold,gold);assert.equal(retreat.wins[r],win);
  assert.deepEqual(a.beginEncounter(d,retreat,r).pending.encounter,encounter);
  state=a.recordResult(d,state,'victory');assert.equal(state.gold,gold+encounter.reward);assert.equal(state.wins[r],win+1);
  assert.throws(()=>a.recordResult(d,state,'victory'));
  if(r<3)assert.equal(a.isUnlocked(d,state,r+1),win===2);
 }
 const gold=state.gold, wins=structuredClone(state.wins);
 state=a.beginEncounter(d,state,r);assert(!state.pending.encounter.replay);assert.equal(state.pending.encounter.stage,3);
 state=a.recordResult(d,state,'victory');assert.equal(state.gold,gold+d.encounterConfig.regions[r].stages[2].reward+10);wins[r]++;assert.deepEqual(state.wins,wins);
}
assert.deepEqual(state.wins,[4,4,4,4]);
const custom=structuredClone(d);custom.encounterConfig.progression.winsRequired=[6,4,5,3];
state=a.createCampaign(custom);
for(let i=0;i<6;i++){
 state=a.beginEncounter(custom,state,0);assert.equal(state.pending.encounter.stage,Math.floor(i*3/6)+1);state=a.recordResult(custom,state,'victory');assert.equal(a.isUnlocked(custom,state,1),i===5);
}
state.gold=65530;state=a.beginEncounter(custom,state,0);state=a.recordResult(custom,state,'victory');assert.equal(state.gold,65535);
custom.encounterConfig.progression.winsRequired[0]=0;assert(a.validate(custom).length);
console.log('PASS: strictly increasing region strength bands, sequential locks, 12 campaign victories, defeat/retreat/retry, single rewards, replay limits, custom thresholds and gold saturation.');
