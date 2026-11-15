const assert=require('node:assert/strict');
const {Game,motionPoints}=require('./engine.js'),data=require('./assets.json'),fixtures=require('./motion-fixtures.json');
for(const {motion,samples} of fixtures){const phase=[0,0,0,0];for(const expected of samples)assert.deepEqual(motionPoints(data.sine,data.motions[motion],phase),expected,`6502 motion ${motion}`);}
assert.equal(data.stages.length,8);for(const stage of data.stages){assert.equal(stage.waves.length,48);assert.equal(stage.columns.length,512);for(const col of stage.columns){assert.equal(col.length,8);for(const tile of col)assert.ok(data.tiles[tile]);}for(const w of stage.waves)assert.ok(data.motions[w[1]]&&data.enemies[w[0]]);}
const g=new Game(data);g.start();
for(let i=0;i<80;i++)g.update({fire:true,right:true});assert.ok(g.wave>0);assert.ok(g.shots.length<=6);assert.ok(g.player.x>36);
g.pause();const tick=g.tick;g.update({fire:true});assert.equal(g.tick,tick);g.pause();
const e={alive:true,x:140,y:100,hp:1};g.enemies=[e];g.player={x:50,y:84};g.shots=[{x:139,y:110,vx:100,vy:0,alive:true}];g.tick=0;g.update();assert.equal(e.alive,false);assert.equal(g.score,100);
g.enemies=[{alive:true,x:100,y:100}];const bombs=g.bombs;g.update({bomb:true});assert.equal(g.bombs,bombs-1);g.update({bomb:true});assert.equal(g.bombs,bombs-1);
g.pickups=[{x:g.player.x+40,y:g.player.y+16,kind:'weapon',age:0}];g.update();assert.equal(g.weapon,2);
g.invulnerable=0;g.hit();assert.equal(g.lives,2);g.hit();assert.equal(g.lives,2);
// Exercise every sector transition and the win condition without UI shortcuts.
for(let stage=0;stage<8;stage++){
 g.start(stage);g.wave=48;g.wait=0;g.update();assert.ok(g.boss);g.boss.hp=0;g.update();assert.ok(g.guardianDefeated);for(let i=0;i<141;i++)g.update();assert.equal(stage===7?g.mode:g.stage,stage===7?'won':stage+1);
}
g.start();g.invulnerable=0;g.lives=1;g.hit();assert.equal(g.mode,'gameover');g.start();assert.equal(g.lives,3);assert.equal(g.mode,'playing');
// The space variant must have no invisible collision from archived terrain.
g.start();g.invulnerable=0;g.wait=99999;g.player.y=224;
for(let i=0;i<200;i++)g.update({right:true});assert.equal(g.lives,3);
console.log(`Passed ${fixtures.reduce((n,f)=>n+f.samples.length,0)} original-CPU motion comparisons, map coverage, shooting, damage, pickups, pause, all sector transitions and win/restart.`);
