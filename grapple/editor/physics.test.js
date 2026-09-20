"use strict";
const test = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const Game = require("./atari-physics.js");
const blank = () => Array.from({length:2880},(_,i)=>({x:i%12,y:Math.floor(i/12),index:i,tile:-1,rot:0}));
const authored = () => JSON.parse(fs.readFileSync(path.join(__dirname,"../bin/assets/world.json"))).layers[0].tiles;

test("PAL fixed point gravity, terminal velocity, and full-speed water",()=>{
  for(const [y,ticks] of [[300,10],[1100,10]]) {
    const g=new Game(blank(),{x:80,y});
    for(let i=0;i<10;i++)g.tick();
    assert.equal(g.player.vy,ticks*164/256);
    assert.equal(g.player.y,y+164/256*ticks*(ticks+1)/2);
  }
  const g=new Game(blank(),{x:80,y:300});
  for(let i=0;i<50;i++)g.tick();
  assert.equal(g.player.vy,8);
});
test("hook priorities, speed, frozen launch, release momentum and water independence",()=>{
  const g=new Game(blank(),{x:80,y:300});
  g.tick({right:true}); assert.equal(g.hook.x,104); assert.equal(g.player.x,80);
  g.tick({right:true,down:true}); assert.equal(g.hook.dir,1);
  g.hook.pulling=true;
  g.tick({right:true}); assert.equal(g.player.vx,7);
  g.tick({}); assert.equal(g.hook,null); assert.equal(g.player.vx,7);
  const wet=new Game(blank(),{x:80,y:1100});
  wet.tick({right:true}); assert.equal(wet.hook.x,104);
  wet.tick({right:true}); assert.equal(wet.hook.x,128);
  const priority=new Game(blank(),{x:80,y:300});
  priority.tick({left:true,right:true,up:true,down:true}); assert.equal(priority.hook.dir,2);
});
test("lava breaks a hook and prevents held-input refiring for 35 simulation ticks",()=>{
  const cells=blank();cells[19*12+7].tile=18;
  const g=new Game(cells,{x:80,y:300});
  g.tick({right:true});assert.equal(g.hook,null);assert.equal(g.cooldown,35);
  for(let i=0;i<35;i++){g.tick({right:true});assert.equal(g.hook,null);}
  assert.equal(g.cooldown,0);
});
test("checkpoint death and manual respawn reset actors without mutating the map",()=>{
  const cells=blank();cells[20*12+5].tile=11;cells[21*12+5].tile=18;
  const before=JSON.stringify(cells),g=new Game(cells,{x:72,y:312});
  g.tick(); assert.equal(g.checkpoint,245); assert.deepEqual(g.respawn,{x:72,y:319});
  g.player.y=333;g.tick();assert.equal(g.deaths,1);assert.equal(g.player.y,319);
  g.reset();assert.equal(g.checkpoint,245);assert.equal(g.player.y,319);
  assert.equal(JSON.stringify(cells),before);
  g.restart();assert.equal(g.checkpoint,null);assert.equal(g.player.y,312);
});
test("authored thwomp chamber: offscreen left attack, occlusion and right/down/left chase",()=>{
  const g=new Game(authored(),{x:24,y:672});
  const thwompAt=(x,y)=>g.thwomps.find(t=>t.x===x&&t.y===y);
  g.camera=614;g.moveThwomps();let left=thwompAt(24,568);
  assert.equal(left.state,1);assert.equal(left.dir,2);
  g.player={x:24,y:900};g.reset();g.player={x:24,y:900};g.moveThwomps();
  left=thwompAt(24,568);assert.equal(left.state,0);
  g.reset();g.player={x:136,y:512};
  let top=thwompAt(104,504);
  for(let i=0;i<20;i++)g.moveThwomps();
  assert.equal(top.x,136);assert.equal(top.state,2);
  g.player={x:136,y:672};
  for(let i=0;i<65;i++)g.moveThwomps();
  assert.equal(top.y,664);
  g.player.x=72;for(let i=0;i<40;i++)g.moveThwomps();
  assert.equal(top.x,24);assert.equal(top.dir,3);
});
test("mover speed overrides and cannon launch obey the Atari tick quantization",()=>{
  const cells=blank();cells[20*12+5]={...cells[245],tile:13,speed:100,rot:3};
  cells[20*12+8]={...cells[248],tile:14,bulletSpeed:250,rot:0};
  const g=new Game(cells,{x:32,y:310});g.moveMovers();assert.equal(g.movers[0].x,74);
  g.cannons[0].timer=0;g.moveCannons();assert.equal(g.balls.length,1);
  const velocity=Math.round(250/Math.SQRT2/50*256)/256;
  assert.equal(g.balls[0].vx,-velocity+20/256);assert.equal(g.balls[0].vy,-velocity+41/256);
});
