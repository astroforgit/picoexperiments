const assert=require('node:assert/strict');
const fs=require('node:fs');
const {Encounter}=require('./flight-core.js');
const {project,sine}=JSON.parse(fs.readFileSync(0,'utf8'));
const e=new Encounter(project,sine,0,0,{loop:false,bossPreview:true});
e.player={x:40,y:48};
for(let dx=-30;dx<=30;dx++)for(let dy=-35;dy<=35;dy++){
 e.hits=0;e.invulnerable=0;e.slowRemaining=3;e.slowPhase=0;
 e.hostile=[{boss:true,art:'orb',x:40+dx,y:48+dy}];
 e.update({},0);
 assert.equal(e.hits,Number(dx>=1&&dx<14&&dy>=-7&&dy<8),`orb offset ${dx},${dy}`);
}
console.log('Round-shot collision bounds and near misses pass in the browser engine.');
