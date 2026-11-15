const assert=require('node:assert/strict');const {Game,moveTable}=require('./engine.js'),data=require('./assets.json'),fixtures=require('./motion-fixtures.json');
let samples=0;for(const f of fixtures){const [x,y,phase]=f.initial,e={x,y,phase,alive:true};for(const state of f.samples){moveTable(e,data.paths[f.type]);assert.deepEqual([e.x,e.y,e.phase,e.alive],state,`type ${f.type}`);samples++;}}
for(const ids of Object.values(data.types))for(const id of ids)assert.ok(data.sprites[id],id);
const g=new Game(data);g.start();g.update({right:true,fire:true});assert.ok(g.player.x>4);assert.equal(g.shots.length,1);g.fire();assert.equal(g.shots.length,1);g.pause();const tick=g.tick;g.update();assert.equal(g.tick,tick);g.pause();g.update({pulse:true});assert.equal(g.pulses,2);g.update({pulse:true});assert.equal(g.pulses,2);
g.invulnerable=0;g.hit();assert.equal(g.lives,2);g.hit();assert.equal(g.lives,2);
// Traverse the entire real script with object slots freed between updates.
for(let chapter=0;chapter<data.chapters.length;chapter++){
 g.start(chapter);for(let i=0;i<100000&&g.mode==='playing';i++){g.invulnerable=999;for(const e of g.enemies)g.destroy(e);g.hostile=[];g.update();}assert.equal(g.mode,'won',`checkpoint ${chapter} stalls`);assert.ok(g.spawned>0);
}
g.start();g.lives=1;g.invulnerable=0;g.hit();assert.equal(g.mode,'gameover');g.start();assert.equal(g.lives,3);
console.log(`${samples} 6502 movement comparisons; all sprite references; one-shot limit; pulse latch; damage; pause; complete script and all checkpoints passed.`);
