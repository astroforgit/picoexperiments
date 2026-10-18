'use strict';
const assert=require('node:assert/strict'),sim=require('../simulation/campaign-sim.js'),data=require('../greenhaven-unit-balance.json');
assert.equal(data.permanentCasualties,true);
const run=sim.simulateCampaign(data,{strategy:'infantry',seed:1,trace:true});
assert(run.battles.some(b=>b.outcome==='victory'&&b.casualties.length),'Victories must retain casualties');
assert(run.battles.some(b=>b.casualties.length));assert(run.ledger.some(p=>p.replacement),'Replacements must be bought');
assert.equal(run.gold,data.startingGold+run.earned-run.spent);
let army=['barracks-2','barracks-2'];
for(const event of run.events){
 if(event.type==='purchase'){army=event.army.slice();if(event.replacement)assert(event.cost>0);}
 else {
  assert.deepEqual(event.army,army);
  const living=new Set(event.survivors.map(u=>u.slot));
  for(let slot=0;slot<army.length;slot++)if(army[slot]&&!living.has(slot))army[slot]=null;
 }
}
assert.deepEqual(run.army,army);assert(!run.completed&&run.gameOver&&run.blockedReason.includes('GAME OVER'));
// A spare army slot remains empty until paid for; discount applies to replacement recruits.
const shop={gold:100,army:['barracks-2',null,'archery-2'],levels:{barracks:3,archery:2,chapel:3,lodge:0,tower:0}};
const replaced=sim.purchase(data,shop,{kind:'recruit',id:'barracks-3',slot:1});assert.equal(replaced.event.cost,50);assert.deepEqual(replaced.shop.army,['barracks-2','barracks-3','archery-2']);assert.equal(shop.army[1],null);
assert.throws(()=>sim.purchase(data,shop,{kind:'recruit',id:'barracks-3',slot:0}));
const encounter={enemies:[{...data.enemies[0],cell:6}],terrain:[10,31],playerCells:[0,7,14,21,28]};
const b=sim.simulateBattle(data,[null,'barracks-2'],encounter,{trace:true});assert.equal(b.initialUnits[0].cell,7);assert.equal(b.survivors[0].slot,1);
console.log('PASS: permanent deaths after wins/losses, paid replacements in original slots, discount, immutable purchases, vacancy deployment, campaign bankruptcy and complete money accounting.');
