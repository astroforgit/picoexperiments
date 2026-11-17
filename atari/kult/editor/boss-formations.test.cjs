const assert=require('node:assert/strict');const {Encounter,validate,formations}=require('./flight-core.js');
(async()=>{const d=await(await fetch('http://127.0.0.1:8772/api/diabolic')).json();assert.equal(formations.length,6);assert.deepEqual(formations,d.bossFormations);
for(let pattern=1;pattern<=6;pattern++){const p=structuredClone(d.project);p.boss.pattern=pattern;assert.equal(validate(p,d.catalog).boss.pattern,pattern);}
for(const pattern of [-1,7,1.5,true]){const p=structuredClone(d.project);p.boss.pattern=pattern;assert.throws(()=>validate(p,d.catalog));}
for(const dx of [-9,-8,-7,0,18,19,20,21])for(const dy of [-17,-16,-15,0,14,15,16,17]){const e=new Encounter(d.project,d.sine,0,0,{bossPreview:true,loop:false});e.player={x:40,y:56};e.invulnerable=0;e.hostile=[{boss:true,x:40+dx,y:56+dy}];e.update();assert.equal(e.hits>0,dx>=-8&&dx<20&&dy>=-16&&dy<16,`Collision edge ${dx}/${dy}`);}
console.log('Six preset schemas, invalid settings and 64 native collision boundary cases passed.');})().catch(e=>{console.error(e);process.exitCode=1;});
