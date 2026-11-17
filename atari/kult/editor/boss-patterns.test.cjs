const assert=require('node:assert/strict');const {Encounter,validate,measureBulletWaves}=require('./flight-core.js');
(async()=>{const d=await(await fetch('http://127.0.0.1:8772/api/diabolic')).json();
assert.deepEqual(measureBulletWaves(d.project,d.sine),d.bulletWaves);
for(const pattern of [1,2,3,4,5,6])for(const difficulty of [0,1,2])for(const y of [0,28,56,84,112]){
 const p=validate(d.project,d.catalog);p.encounters[0][0]=4;p.boss={pattern,difficulty};const e=new Encounter(p,d.sine,0,0,{loop:false});e.player.y=y;let possible=new Set([y]),max=0;const born=[];
 for(let t=0;t<127;t++){if(t)e.player.x=100;e.invulnerable=999;e.update();max=Math.max(max,e.hostile.length);
 if(e.bossWarmup>0)assert.equal(e.hostile.length,0);
 for(const b of e.hostile)if(b.age===0){assert.equal(b.x,e.enemies[0].x);assert.equal(b.y,e.enemies[0].y+16);born.push(t);}
 possible=new Set([...possible].flatMap(y=>[-6,0,6].map(d=>Math.max(0,Math.min(112,y+d)))).filter(y=>!e.hostile.some(b=>b.x+8>12&&b.x<32&&b.y+16>y&&b.y<y+16)));
 assert.ok(possible.size,`No dodge route ${pattern}/${difficulty}/${y}/${t}`);assert.ok(e.hostile.length<=8);
 }
 assert.equal(max,8);assert.ok(born.length>=24);assert.ok(new Set(born).size>=6);
}
const p=validate(d.project,d.catalog);p.encounters[0][0]=4;
for(const pattern of [0,1,2,3,4,5,6])for(const difficulty of [0,1,2])for(const x of [12,48,64]){const idle=new Encounter({...p,boss:{pattern,difficulty}},d.sine,0,0,{loop:false});idle.player.x=x;for(let t=0;t<256;t++)idle.update();assert.ok(idle.hits>0);assert.equal(idle.enemies[0].x,88);assert.equal(idle.enemies[0].y,48);}
const e=new Encounter(p,d.sine);for(let t=0;t<50;t++)e.update();e.update({bomb:true});assert.equal(e.hostile.length,0);for(let t=0;t<10;t++){e.update();assert.equal(e.hostile.length,0);}e.bossHP=0;e.update();assert.equal(e.hostile.length,0);
console.log('90 route searches, measured source paths, eight-sprite formations and mouth-origin checks, 63 stationary-ship scenarios and bomb cleanup passed.');})().catch(e=>{console.error(e);process.exitCode=1;});
