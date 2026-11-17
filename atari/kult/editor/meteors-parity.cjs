// Native test supplies real 6502 positions, including scroll compensation.
const assert=require('node:assert/strict');
const {Encounter}=require('./flight-core.js');
const data=JSON.parse(require('node:fs').readFileSync(0,'utf8'));
for(const trace of data.traces){
 const p=structuredClone(data.project);p.encounters[0][0]=trace.kind;
 const e=new Encounter(p,data.sine,0,0,{loop:false});
 for(const frame of trace.frames){
  e.update();
  assert.deepEqual(e.enemies.map(a=>a.visible?[a.x,a.y]:null),frame);
 }
}
console.log('Native/browser meteor positions match for all four directions.');
