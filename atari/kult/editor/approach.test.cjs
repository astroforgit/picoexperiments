const assert=require('node:assert/strict');
const {Encounter}=require('./flight-core.js');
(async()=>{
 const d=await(await fetch('http://127.0.0.1:8772/api/diabolic')).json();
 for(const kind of [0,7]){
  const p=structuredClone(d.project);p.encounters[0][0]=kind;p.firing={mode:2,interval:12,speed:6};
  const e=new Encounter(p,d.sine,0,0,{loop:false});e.player={x:12,y:56};let born=0;
  for(let t=0;t<160;t++){
   e.invulnerable=999;const before=new Set(e.hostile);e.update();
   for(const b of e.hostile)if(!before.has(b)){
    born++;const enemy=e.enemies[e.enemyIndex];assert.ok(enemy.x-e.player.x>=52);
    assert.equal(b.style,0);if(kind===7)assert.ok(enemy.meteorY>=8&&enemy.meteorY<128);
    assert.equal(b.x,enemy.x-6);
    const ticks=Math.ceil((enemy.x-e.player.x)/6),delta=e.player.y-enemy.y;
    assert.equal(b.dy,Math.sign(delta)*Math.floor((Math.abs(delta)+Math.floor(ticks/2))/ticks));
   }
  }
  assert.ok(born>0,`No shots in wave kind ${kind}`);
 }
 console.log('Enemy distance gating, uniform bullet style, speed 6 and aimed direction passed.');
})().catch(e=>{console.error(e);process.exitCode=1;});
