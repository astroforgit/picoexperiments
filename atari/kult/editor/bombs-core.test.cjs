const assert=require('node:assert/strict');
const {Encounter}=require('./flight-core.js');
(async()=>{const d=await(await fetch('http://127.0.0.1:8772/api/diabolic')).json();
for(const kind of [0,1,2,3,4]){const p=structuredClone(d.project);p.encounters[0][0]=kind;p.waves[0][0][3]=8;const e=new Encounter(p,d.sine);e.hostile.push({x:100,y:100,dy:0});e.update({bomb:true});assert.equal(e.bombs,2);assert.equal(e.shields,3);assert.equal(e.hostile.length,0);if(!kind)assert.ok(e.enemies.every(v=>v.hp===0));else if(kind===4)assert.equal(e.bossHP,48);else assert.ok(e.enemies.every(v=>v.hp===8));for(let i=0;i<4;i++)e.update({bomb:true});assert.equal(e.bombs,2);e.update({});e.update({bomb:true});assert.equal(e.bombs,1);}
console.log('Independent bomb stock, hold protection, enemy damage and meteor immunity passed.');})().catch(e=>{console.error(e);process.exitCode=1;});
