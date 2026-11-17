const assert=require('node:assert/strict');
const {Encounter}=require('./flight-core.js');
function moved(p,dx,dy){return [p.x+(dx>0&&p.x<100?3:dx<0&&p.x>=3?-3:0),Math.max(0,Math.min(112,p.y+dy*6))];}
(async()=>{
 const [d,lab]=await Promise.all(['/api/diabolic','/api/boss-lab'].map(async u=>(await fetch('http://127.0.0.1:8772'+u)).json()));
 assert.equal(lab.matchesBuild,true);assert.deepEqual(require('./boss-formations.js'),d.bossFormations);assert.equal(lab.scenarios.length,126);
 for(const s of lab.scenarios){
  if(lab.patterns)Object.assign(s,lab.patterns[s.pattern]);assert.ok(s.passable);
  const p=structuredClone(d.project);p.boss.pattern=s.pattern;
  const idle=new Encounter(p,d.sine,0,0,{curtainOnly:true,loop:false,bossPreview:true});idle.player={x:s.start[0],y:s.start[1]};
  const pilot=new Encounter(p,d.sine,0,0,{curtainOnly:true,loop:false,bossPreview:true});pilot.player={x:s.start[0],y:s.start[1]};
  for(let t=0;t<s.frames.length;t++){
   idle.invulnerable=999;idle.update();
   assert.deepEqual(idle.hostile.map(b=>[b.lane,b.x,b.y]).sort((a,b)=>a[0]-b[0]),s.frames[t],`CPU/browser mismatch ${s.pattern}/${s.start}/${t+1}`);
   const target=s.route[t];let input;
   for(const dx of [-1,0,1])for(const dy of [-1,0,1]){const next=moved(pilot.player,dx,dy);if(next[0]===target[0]&&next[1]===target[1])input={left:dx<0,right:dx>0,up:dy<0,down:dy>0};}
   assert.ok(input,'Route requires a legal joystick move');pilot.invulnerable=0;pilot.update(input);
   assert.deepEqual([pilot.player.x,pilot.player.y],target);assert.equal(pilot.hits,0,`Browser pilot collision ${s.pattern}/${s.start}/${t+1}`);
  }
 }
 console.log('126 native bullet traces and full joystick escape routes match the browser simulation.');
})().catch(e=>{console.error(e);process.exitCode=1;});
