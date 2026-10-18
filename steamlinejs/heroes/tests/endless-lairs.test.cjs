'use strict';
const assert=require('node:assert/strict'),a=require('../editor-balance.js'),d=require('../greenhaven-unit-balance.json');
let s=a.createCampaign(d);let prior=null;
for(let i=0;i<100;i++){
 s.seed=1;s=a.beginEncounter(d,s,0);const e=s.pending.encounter;
 assert.equal(e.replay,false);assert.equal(e.stage,Math.min(3,i+1));assert.equal(e.escalation.hpBonus,Math.min(90,Math.max(0,i-2)));
 if(prior&&i>=3){assert(e.enemies[0].hp>=prior.enemies[0].hp);assert(e.reward>=prior.reward);}
 const before=s.wins[0],retry=a.beginEncounter(d,a.recordResult(d,s,'defeat'),0);assert.deepEqual(retry.pending.encounter,e);
 prior=e;s=a.recordResult(d,s,'victory');assert.equal(s.wins[0],before+1);assert.equal(a.isUnlocked(d,s,1),i>=2);
}
s.wins[0]=255;s=a.beginEncounter(d,s,0);s=a.recordResult(d,s,'victory');assert.equal(s.wins[0],255);assert(a.isUnlocked(d,s,1));
console.log('PASS: 100 advancing encounters, repeated victories after unlock, same-seed stronger enemies, increasing rewards, retry preservation and safe storage cap.');
