const assert=require('node:assert/strict');
const {Encounter,validate}=require('./flight-core.js');
(async()=>{
 const d=await(await fetch('http://127.0.0.1:8772/api/diabolic')).json();
 for(const kind of [1,2,3,6]){
  const p=structuredClone(d.project);p.encounters[0][0]=kind;validate(p,d.catalog);
  const e=new Encounter(p,d.sine,0,0,{loop:false});
  const seen=new Set();
  for(let t=0;t<260;t++){
   e.update({fire:true});assert.equal(e.hostile.length,0);assert.equal(e.boss,false);
   const active=e.enemies.filter(a=>a.visible);
   for(const a of active){seen.add(a.i);assert.equal(a.x,kind===3?127-a.meteorY:[8,68,108,38,88,18,58,118][a.i]);assert.equal(a.y,kind===3?[0,64,112,32,96,16,80,48][a.i]:kind===2||(kind===6&&(a.i&1))?127-a.meteorY:a.meteorY);}
   for(let i=0;i<active.length;i++)for(const b of active.slice(i+1))assert.ok(Math.abs(active[i].x-b.x)>=8||Math.abs(active[i].y-b.y)>=16,'Meteor lanes overlap');
  }
  assert.equal(seen.size,8);assert.equal(e.complete,true);assert.equal(e.pickups.length,0);
 }
 console.log('Four meteor directions: edge entry, disjoint lanes, immunity, draining and completion passed.');
})().catch(e=>{console.error(e);process.exitCode=1});
