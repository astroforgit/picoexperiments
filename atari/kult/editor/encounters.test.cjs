const assert=require('node:assert/strict');
const {Encounter,validate}=require('./flight-core.js');
(async()=>{const d=await(await fetch('http://127.0.0.1:8772/api/diabolic')).json();
for(const k of [1,2,3]){const p=validate(d.project,d.catalog);p.encounters[0][0]=k;const e=new Encounter(p,d.sine);for(let t=0;t<190;t++)e.update({fire:true});assert.equal(e.hostile.length,0);assert.ok(e.enemies.every(x=>x.hp===p.waves[0][0][3]));}
const p=validate(d.project,d.catalog);p.encounters[0][0]=4;const e=new Encounter(p,d.sine);let max=0;for(let t=0;t<200;t++){e.update();max=Math.max(max,e.hostile.length);}assert.equal(max,8);assert.equal(e.enemies[0].x,88);assert.equal(e.enemies[3].x,112);assert.equal(e.enemies[4].y-e.enemies[0].y,16);console.log('Meteor immunity and boss formation/barrage preview passed.');})().catch(e=>{console.error(e);process.exitCode=1});
