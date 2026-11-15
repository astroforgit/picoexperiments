const assert=require('node:assert/strict'),fs=require('node:fs');
const {Encounter,validate}=require('./flight-core.js');
(async()=>{const d=await (await fetch('http://127.0.0.1:8772/api/diabolic')).json();const p=validate(d.project,d.catalog);
assert.equal(d.catalog.ships.length,5);assert.equal(d.catalog.enemies.length,99);
p.firing={mode:2,interval:12,speed:2};const e=new Encounter(p,d.sine);let shots=0;for(let i=0;i<500;i++){e.update();shots=Math.max(shots,e.hostile.length);}assert.ok(shots>0&&shots<=4);
p.firing.mode=0;const off=new Encounter(p,d.sine);for(let i=0;i<200;i++)off.update();assert.equal(off.hostile.length,0);
const bad=structuredClone(p);bad.slots[0]='missing';assert.throws(()=>validate(bad,d.catalog));
console.log('Editor project validation, shooting preview and disabled-fire checks passed.');})().catch(e=>{console.error(e);process.exitCode=1;});
