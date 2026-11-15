const assert=require('node:assert/strict'),fs=require('node:fs'),rules=require('../editor-balance.js'),d=require('../greenhaven-unit-balance.json');
let optional=0;
for(let difficulty=0;difficulty<3;difficulty++)for(let seed=0;seed<256;seed++){
 let state=rules.createCampaign(d,difficulty);state.seed=seed;
 for(let wins=0;wins<3;wins++){
  state.wins[0]=wins;state.pending=null;
  const encounter=rules.beginEncounter(d,state,0).pending.encounter;
  assert(!encounter.enemies.every(u=>u.id==='evil-nymph'));
 }
 state.wins[0]=3;state.pending=null;
 const encounter=rules.beginEncounter(d,state,0).pending.encounter;
 if(encounter.enemies.every(u=>u.id==='evil-nymph'))optional++;
 assert.equal(encounter.reward,d.encounterConfig.regions[0].stages[2].reward);
}
assert(optional>0);
const groups=fs.readFileSync(__dirname+'/../atari/city/generated/battle-groups.inc','utf8');const seeds=groups.match(/^forest_optional_seed dta (.+)$/m)[1].split(',').map(Number);
const start=d.encounterConfig.regions[0].stages.slice(0,2).reduce((n,s)=>n+s.variants.length,0);
for(let seed=0;seed<256;seed++)assert.equal(seeds[seed],start+rules.generate(d,0,2,seed,false,0,3).variant);
console.log('PASS: no Nymph-only groups in the first three Forest victories across all seeds/difficulties; optional later, native optional seed parity.');
