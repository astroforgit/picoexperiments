/* Live four-wave attack: actual pilot speed, delayed reactions, no consumables. */
(function(root){
const Encounter=typeof module!=='undefined'?require('./flight-core.js').Encounter:root.FlightWorkshop.Encounter;
function encounter(data,pattern,gap=5){
 const project=JSON.parse(JSON.stringify(data.project));project.boss.pattern=pattern;project.firing.mode=2;
 const e=new Encounter(project,data.sine,0,0,{bossPreview:true,loop:false});
 Object.assign(e.ai,{phase:4,timer:0,cooldown:0,art:0});e.bossWarmup=9;e.bossClock=29;e.bossX=88;e.bossTop=32;e.attackCycle=gap===5?-1:0;e.invulnerable=0;
 return e;
}
function trace(data,pattern,gap){
 const e=encounter(data,pattern,gap),frames=[],births=[];let cycle=e.attackCycle;
 for(let t=0;t<400;t++){
  e.invulnerable=999;e.update();
  if(e.attackCycle!==cycle){births.push(t);cycle=e.attackCycle;}
  frames.push(e.hostile.map(b=>[b.x,b.y]));
  if(e.ai.phase===6)return {frames,births};
 }
 throw Error('Curtains failed to clear');
}
function hit(x,y,bullets,padding=2){return bullets.some(([bx,by])=>bx-x>=-8-padding/2&&bx-x<20+padding/2&&by-y>=-16-padding&&by-y<16+padding);}
function route(trace,x,start,reaction=6){
 let states=new Set([start]);const history=[];
 for(let tick=0;tick<trace.frames.length;tick++){
  const waiting=trace.births.some(b=>tick>=b&&tick<b+6+reaction),parents=new Map();
  for(const y of states)for(const dy of waiting?[0]:[0,-6,6]){
   const next=Math.max(0,Math.min(112,y+dy));
   if(!parents.has(next)&&!hit(x,next,trace.frames[tick]))parents.set(next,y);
  }
  if(!parents.size)return null;
  history.push(parents);states=new Set(parents.keys());
 }
 let y=states.values().next().value;const path=[];
 for(let tick=history.length-1;tick>=0;tick--){path[tick]=y;y=history[tick].get(y);}
 return path;
}
function replay(data,pattern,gap,x,start,path,draw){
 const e=encounter(data,pattern,gap);e.player={x,y:start};
 for(const y of path){e.update({up:y<e.player.y,down:y>e.player.y});if(draw)draw(e);if(e.hits)throw Error(`Replay hit: pattern ${pattern}, gap ${gap}, X ${x}, Y ${start}`);}
 if(e.ai.phase!==6)throw Error('Replay did not reach boss return');
 return e;
}
function verify(data,draw){
 const scenarios=[];
 for(let pattern=0;pattern<=6;pattern++)for(const gap of [1,5]){
  const t=trace(data,pattern,gap);
  if(JSON.stringify(t.births)!==JSON.stringify([18,78,138,198]))throw Error('Unexpected four-wave timing');
  for(const x of [12,48,60])for(const start of [0,56,112]){
   const path=route(t,x,start,6);if(!path)throw Error(`No delayed-reaction route: ${pattern}/${gap}/${x}/${start}`);
   replay(data,pattern,gap,x,start,path,draw);
   scenarios.push({pattern,gap,x,start,updates:path.length,reactionUpdates:6});
  }
 }
 return {scenarios,passable:scenarios.length,formationGameUpdates:38,spawnUpdates:[18,78,138,198],revealDelayUpdates:6,reactionSecondsAt17:6/17,shipPixelsPerUpdate:6,rushPixelsPerUpdate:12};
}
const api={encounter,trace,route,replay,verify};if(typeof module!=='undefined')module.exports=api;else root.BossWaveSafety=api;
})(globalThis);
