const assert=require('node:assert/strict'),fs=require('node:fs'),d=require('../greenhaven-unit-balance.json'),native=require('../atari/city/content.json'),rules=require('../editor-balance.js');
assert.deepEqual(rules.validate(d),[]);assert.deepEqual(d.encounterConfig,native.encounterConfig);
const html=fs.readFileSync(__dirname+'/../unit-editor.html','utf8');assert.deepEqual(JSON.parse(html.match(/<script id="initial-data" type="application\/json">(.*?)<\/script>/s)[1]),d);
let pure=0,mages=0;
for(const [r,region] of d.encounterConfig.regions.entries())for(const [s,stage] of region.stages.entries()){
 const fixed={'skeleton-guard':'skeleton','sniper-ambush':'sniper'}[stage.kind];
 for(const [difficulty,key] of ['enemies','mediumEnemies','hardEnemies'].entries()){
  if(fixed){assert.equal(stage.variants.length,1);assert.deepEqual(stage.variants[0][key],Array(5).fill(fixed));continue;}
  assert(stage.variants.some(v=>v[key].includes('evil-nymph')));
  if(r===3&&s===region.stages.length-1){assert(stage.variants.every(v=>v[key].includes('warlock')));continue;}
  const group=stage.variants.find(v=>v[key].every(id=>id==='evil-nymph'));assert(group);assert.deepEqual(group[key],Array(difficulty+2).fill('evil-nymph'));
  if(r===2)for(const v of stage.variants.filter(v=>v!==group))assert(v[key].includes('ogre-mage'));
 }
 if(!fixed&&!(r===3&&s===region.stages.length-1))pure++;
 if(r===2)mages+=stage.variants.filter(v=>v.enemies.includes('ogre-mage')).length;
}
assert.equal(pure,10);assert.equal(mages,9);
console.log('PASS: 10 Nymph-only groups (2/3/4), mixed Nymph groups in all eligible stages, 9 Cave groups with Ogre Mages, protected skeleton/sniper rosters and boss; editor/native parity.');

assert.equal(d.enemies.find(u=>u.id==='evil-nymph').hp,3);assert.equal(native.enemies.find(u=>u.id==='evil-nymph').hp,3);
for(const region of d.encounterConfig.regions)for(const [i,stage] of region.stages.entries()){
 if(stage.variants.length===1)continue;
 const total=stage.variants.reduce((n,v)=>n+v.weight,0),nymph=stage.variants.filter(v=>v.enemies.includes('evil-nymph')).reduce((n,v)=>n+v.weight,0);
 assert.equal(nymph/total,i===0?.1:.25);
}
console.log('PASS: Nymph HP 3; stage-one Nymph probability 10%, later random stages 25%.');
