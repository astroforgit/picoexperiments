'use strict';
const fs=require('fs'),path=require('path'),assert=require('assert/strict');
const {solve,describe}=require('../grapple/editor/reachability.js');
const Game=require('../grapple/editor/atari-physics.js');
const world=JSON.parse(fs.readFileSync(path.join(__dirname,process.argv[2] || 'world-gentle-descent.json')));
const cells=world.layers[0].tiles, checkpoints=cells.filter(c=>c.tile===11);
let game=new Game(cells), actions=[], sections=[];
for(const cp of checkpoints){
 const id=cp.y*12+cp.x;
 const result=solve(cells,game.player,g=>g.checkpoint===id,{game,targetY:cp.y*16,maxExpansions:10000});
 assert(result,`No continuous route to checkpoint ${id}`);
 game=result.game; actions.push(...result.path);
 sections.push({checkpoint:id,ticks:result.ticks,actions:describe(result.path)});
 console.log(`Reached ${id} in ${result.ticks} ticks; deaths ${game.deaths}`);
}
const replay=new Game(cells),keys=[{up:true},{right:true},{down:true},{left:true},{}],visited=new Set();
for(const [k,n]of actions)for(let t=0;t<n;t++){replay.tick(keys[k]);if(replay.checkpoint!==null)visited.add(replay.checkpoint);}
assert.equal(replay.deaths,0);assert.equal(visited.size,checkpoints.length);
const report={name:world.grappleEditor.name,ticks:replay.ticks,seconds:replay.ticks/50,deaths:0,checkpoints:visited.size,actions,sections};
fs.writeFileSync(path.join(__dirname,process.argv[3] || 'gentle-descent-playthrough.json'),JSON.stringify(report,null,2)+'\n');
console.log(`PASS: continuous replay, ${report.seconds}s, all ${visited.size} checkpoints, no deaths`);
