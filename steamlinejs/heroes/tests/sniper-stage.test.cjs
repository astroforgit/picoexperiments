const assert=require('node:assert/strict'),fs=require('node:fs'),rules=require('../editor-balance.js'),data=require('../greenhaven-unit-balance.json');
assert.equal(data.encounterConfig.regions[3].stages.length,4);assert.equal(data.encounterConfig.progression.winsRequired[3],4);
for(let difficulty=0;difficulty<3;difficulty++)for(let seed=0;seed<256;seed++){
 const e=rules.generate(data,3,2,seed,false,difficulty);assert.deepEqual(e.enemies.map(u=>u.id),Array(5).fill('sniper'));assert.equal(e.victory,'Defeat all enemies');assert(rules.generate(data,3,3,seed,false,difficulty).enemies.some(u=>u.id==='warlock'));
}
let state=rules.createCampaign(data);state.wins=[3,3,3,2];state=rules.beginEncounter(data,state,3);assert.equal(state.pending.encounter.stage,3);state=rules.recordResult(data,state,'victory');state=rules.beginEncounter(data,state,3);assert.equal(state.pending.encounter.stage,4);assert.equal(state.pending.encounter.victory,'Defeat the Warlock');
const bad=structuredClone(data);bad.encounterConfig.regions[3].stages[2].variants[0].hardEnemies[0]='warlock';assert(rules.validate(bad).length);
const generated=fs.readFileSync(__dirname+'/../atari/city/generated/battle-content.inc','utf8');assert(generated.includes('FINAL_CONTRACT = 12'));const table=generated.match(/stage_for_win dta (.+)/)[1].split(',').map(Number);assert.deepEqual(table.slice(30,35),[0,1,2,3,3]);
console.log('PASS: all 768 sniper seeds/difficulties, fixed roster validation, Snipers-before-Warlock progression and native stage table.');
