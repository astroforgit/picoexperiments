(function(root){'use strict';
const formations=typeof module!=='undefined'?require('./boss-formations.js'):root.BossFormations;
const laserPatterns=typeof module!=='undefined'?require('./laser-patterns.js'):root.LaserPatterns;
let nextLaserVariant=0,nextCurtainVariant=0;
const native=typeof module!=='undefined'?require('../web/engine.js'):root.Kult;
function validate(p,lib){
 const int=(v,a,b)=>Number.isInteger(v)&&v>=a&&v<=b;
 if(!p||p.version!==1||!lib.ships.some(a=>a.id===p.ship))throw Error('Unknown project or ship');
 if(!Array.isArray(p.slots)||p.slots.length!==32||p.slots.some(id=>!lib.enemies.some(a=>a.id===id)))throw Error('Invalid enemy slots');
 if(!Array.isArray(p.waves)||p.waves.length!==8||p.waves.some(s=>!Array.isArray(s)||s.length!==48||s.some(w=>!Array.isArray(w)||w.length!==4||w.some((v,i)=>!int(v,i===3?1:0,i===3?16:31)))))throw Error('Invalid wave data');
 if(!Array.isArray(p.motions)||p.motions.length!==32||p.motions.some(m=>!Array.isArray(m)||m.length!==8||m.some(v=>!int(v,-128,127))))throw Error('Invalid movement data');
 if(p.encounters===undefined)p={...p,encounters:Array.from({length:8},()=>Array(48).fill(0))};
 if(!Array.isArray(p.encounters)||p.encounters.length!==8||p.encounters.some(s=>!Array.isArray(s)||s.length!==48||s.some(n=>(!int(n,0,9)||n===5))))throw Error('Invalid encounter types');
 if(!p.firing||!int(p.firing.mode,0,2)||!int(p.firing.interval,12,180)||!int(p.firing.speed,1,8))throw Error('Invalid firing settings');
 if(p.boss===undefined)p={...p,boss:{pattern:0,difficulty:1}};
 if(p.boss&&p.boss.design===undefined)p={...p,boss:{...p.boss,design:'boss-bone-dragon'}};
 if(p.boss?.design==='boss-original-dragon')p={...p,boss:{...p.boss,design:'boss-insect-queen'}};
 if(!p.boss||!int(p.boss.pattern,0,formations.length)||!int(p.boss.difficulty,0,2))throw Error('Invalid boss attack settings');
 if(!lib.bosses?.some(b=>b.id===p.boss.design))throw Error('Unknown boss design');
 return JSON.parse(JSON.stringify(p));
}
// Reuse the game's actual enemy motion routine, measuring a complete phase cycle.
function measureBulletWaves(project,sine){
 const sources=[];project.waves[0].forEach((w,i)=>{if(sources.length<3&&!project.encounters[0][i]&&!sources.some(s=>s.motion===w[1]))sources.push({wave:i,motion:w[1]});});
 for(let motion=0;sources.length<3;motion++)if(!sources.some(s=>s.motion===motion))sources.push({wave:null,motion});
 return sources.map(source=>{const phase=[0,0,0,0],frames=[];
  for(let t=0;t<256;t++){const points=native.motionPoints(sine,project.motions[source.motion].map(v=>v&255),phase);frames.push(points);}
  const all=frames.flat(),bounds=[Math.min(...all.map(p=>p[0])),Math.min(...all.map(p=>p[1])),Math.max(...all.map(p=>p[0])),Math.max(...all.map(p=>p[1]))];
  const curve=[];let offset=0;
  for(let age=0;age<64;age++){const target=Math.round((frames[age>>1][0][1]-bounds[1])*36/Math.max(1,bounds[3]-bounds[1]))-18;offset+=Math.sign(target-offset);curve.push(offset+32);}
  return {...source,bounds,curve};
 });
}
function advanceBossShot(b){
 const approach=(v,target,step)=>v+Math.max(-step,Math.min(step,target-v));
 b.age++;
 if(b.age<=2)return;
 if(b.age<=18){
  b.x+=2;b.baseX=b.x;
  const row=b.lane<6?(b.lane<b.gapRow?b.lane:b.lane+2):(b.lane===6?b.gapRow-1:b.gapRow+2);
  b.targetY=row*16;b.y=approach(b.y,b.targetY,4);
 }else{
  b.baseX-=12;if(b.baseX<0){b.x=-99;return;}
  const shape=formations[b.pattern-1],phase=(((b.age-19)*(shape.doubleTime?16:8))+shape.phase)&255;
  const row=b.lane<6?(b.lane<b.gapRow?b.lane:b.lane+2):(b.lane===6?b.gapRow-1:b.gapRow+2),rowY=row*16;
  const xPhase=(phase+(rowY<<shape.rowShift)+shape.xPhase)&255;
  b.x=Math.max(0,b.baseX+(b.sine[xPhase]>>3)-3);
  b.targetY=Math.max(0,Math.min(112,rowY+(b.sine[phase]>>3)-3));b.y=approach(b.y,b.targetY,2);
 }
 b.trail??=[];b.trail.push([b.x,b.y]);if(b.trail.length>24)b.trail.shift();

}
class Encounter{
 constructor(project,sine,sector=0,wave=0,options={}){this.options=options;this.bulletWaves=options.bulletWaves||measureBulletWaves(project,sine);this.weapon=1;this.weaponHeld=false;this.score=0;this.project=project;this.sine=sine;this.sector=sector;this.wave=wave;this.player={x:12,y:56};this.hits=0;this.tick=0;this.bombs=3;this.bombHeld=false;this.shields=3;this.clocks=3;this.slowRemaining=0;this.clockHeld=false;this.slowPhase=0;this.shieldTicks=0;this.shieldHeld=false;this.reset();}
 get meteor(){return this.kind>0&&this.kind!==4&&this.kind!==5&&this.kind!==9;}
 get boss(){return this.kind===4||this.kind===5;}
 get kind(){if(this.options.bossPreview)return 4;if(this.options.guardian)return 5;return this.project.encounters?.[this.sector]?.[this.wave]||0;}
 get bossVulnerable(){return this.bossHP>0&&(this.options.curtainOnly||this.ai.phase===1||this.ai.phase===2);}
 get bossVisible(){return this.bossHP>0&&(this.options.curtainOnly||[1,2,3,6,8].includes(this.ai.phase))&&this.bossX<128;}
 reset(){this.ai={phase:0,timer:0,rng:this.options.aiSeed??0x5d,cooldown:0,art:1,frame:0,direction:0,wait:[]};this.bossX=this.options.curtainOnly?88:128;this.bossTop=32;this.bossWarmup=24;this.bossClock=29;this.attack=null;this.attackCycle=-1;this.curtainRotation=this.options.rotationSeed??1;this.curtainGap=this.options.gapSeed??0;this.curtainVisits=0;this.bombSuppress=0;this.complete=false;this.bossHP=this.options.guardian?100:this.record[3]*4;this.bossMaxHP=this.bossHP;const variant=this.options.laserVariant??(this.kind===9?nextLaserVariant++%3:0);this.laser={phase:1,index:variant*15,end:variant*15+15,variant,remaining:laserPatterns.warningFrames/50,started:false};this.rewarded=false;this.deathShots=[];this.deathStarted=false;this.pickups=[];this.collected=[];this.age=0;this.phase=[0,0,0,0];this.enemies=Array.from({length:8},(_,i)=>({i,x:160,y:i*14,hp:this.record[3],trail:[],meteorY:128,wait:i?i*16+24:0}));this.shots=[];this.hostile=[];this.cooldown=0;this.invulnerable=40;this.fireClock=0;this.enemyIndex=0;}
 get record(){return this.project.waves[this.sector][this.wave];}
 update(input={},dt=.06){
  if(this.complete)return;
  this.slowRemaining=Math.max(0,this.slowRemaining-dt);
  if(input.clock&&!this.clockHeld&&!this.slowRemaining&&this.clocks>0){this.clocks--;this.slowRemaining=3;this.slowPhase=0;}
  this.clockHeld=!!input.clock;
  const worldStep=!this.slowRemaining||((this.slowPhase=(this.slowPhase+1)%3)===0);
  if(input.weapon&&!this.weaponHeld)this.weapon=this.weapon%4+1;
  this.weaponHeld=!!input.weapon;
  this.tick++;if(worldStep)this.age++;this.cooldown=Math.max(0,this.cooldown-1);this.invulnerable=Math.max(0,this.invulnerable-1);
  this.shieldTicks=Math.max(0,this.shieldTicks-1);
  if(input.shield&&!this.shieldHeld&&!this.shieldTicks&&this.shields>0){this.shields--;this.shieldTicks=17;}
  this.shieldHeld=!!input.shield;
  if(input.bomb&&!this.bombHeld&&this.bombs>0){this.bombs--;if(!this.boss||this.ai.art!==2)this.hostile=[];this.bombSuppress=0;this.bossWarmup=25;this.bossClock=29;if(this.boss&&(this.options.curtainOnly||this.ai.phase<3))this.bossHP=Math.max(0,this.bossHP-16);else if(!this.kind||this.kind===7)for(const e of this.enemies)if(this.kind!==7||e.i>=2)e.hp=0;}
  this.bombHeld=!!input.bomb;
  if(input.right&&!input.left&&this.player.x<100)this.player.x+=3;
  if(input.left&&!input.right&&this.player.x>=3)this.player.x-=3;
  this.player.y=Math.max(0,Math.min(112,this.player.y+((input.down?1:0)-(input.up?1:0))*6));
  if(worldStep&&this.kind!==9){
  const points=native.motionPoints(this.sine,this.project.motions[this.record[1]].map(n=>n&255),this.phase);
  const entry=Math.max(0,96-this.age*6),exit=Math.max(0,(this.age-100)*4);
  for(const e of this.enemies){e.x=points[e.i%8][0]+entry-exit;e.y=points[e.i%8][1];
   if(this.kind===7){
    if(e.hp>0){
     if(e.meteorY<128)e.meteorY=Math.min(255,e.meteorY+[2,3,5,5,5,5,5,5][e.i]);
     else if(e.meteorY===128&&this.age>=[1,57,9,21,33,45,69,81][e.i])e.meteorY=0;
     if(e.meteorY>=128&&e.meteorY!==128)e.meteorY=255;
     // Mark an exact edge crossing as spent too; it must never respawn.
     if(e.meteorY===128&&e.started)e.meteorY=255;
     if(e.meteorY<128)e.started=true;
    }
    e.x=127-e.meteorY;e.y=[16,96,0,32,48,64,80,112][e.i];e.visible=e.hp>0&&e.meteorY<128;
   }
   else if(this.kind===8){
    if(e.meteorY<128)e.meteorY+=[2,5,5,5,4,5,3,3][e.i];
    else if(e.meteorY===128&&this.age>=[12,55,65,53,49,58,42,35][e.i])e.meteorY=0;
    const start=[127,127,107,107,87,87,67,67][e.i];
    if((e.meteorY!==128||e.started)&&e.meteorY>start)e.meteorY=255;
    if(e.meteorY<128)e.started=true;
    e.x=start-e.meteorY;e.y=e.i&1?127-e.meteorY:e.meteorY;e.visible=e.meteorY<128;
   }
   else if(this.meteor){
    if(e.meteorY<128){e.meteorY+=[2,4,6,3,5,4,7,5][e.i];if(e.meteorY>=128){e.meteorY=128;e.wait=32;}}
    else if(this.age<192){if(e.wait>0)e.wait--;else e.meteorY=0;}
    e.visible=e.meteorY<128;const up=this.kind===2||(this.kind===6&&(e.i&1));e.x=this.kind===3?127-e.meteorY:[8,68,108,38,88,18,58,118][e.i];e.y=this.kind===3?[0,64,112,32,96,16,80,48][e.i]:up?127-e.meteorY:e.meteorY;
   }
   else if(this.boss){e.x=this.bossX+(e.i%4)*8;e.y=this.bossTop+16+Math.floor(e.i/4)*16;e.visible=this.bossVulnerable;}
   else e.visible=e.hp>0;
e.trail.push([e.x,e.y]);if(e.trail.length>28)e.trail.shift();}
  }
  if(this.kind===9)this.laserUpdate(dt);
  if(input.fire&&!this.cooldown){for(const y of [[8],[4,11],[2,8,14],[1,5,10,14]][this.weapon-1])this.shots.push({x:this.player.x+20,y:this.player.y+y});this.cooldown=4;}
  for(const b of this.shots){b.x+=6;for(const e of this.enemies)if(e.visible&&b.x>=e.x&&b.x<e.x+8&&b.y>=e.y&&b.y<e.y+16){if(!this.kind||(this.kind===7&&e.i>=2))e.hp--;else if(this.boss)this.bossHP=Math.max(0,this.bossHP-1);b.x=999;break;}}
  this.shots=this.shots.filter(b=>b.x<128);
  if(!this.kind||this.kind===7)for(const e of this.enemies)if(e.hp<=0)e.visible=false;
  if(this.boss&&this.bossHP<=0)for(const e of this.enemies)e.visible=false;
  for(const e of this.enemies)if(e.visible&&this.player.x<e.x+8&&this.player.x+20>e.x&&this.player.y<e.y+16&&this.player.y+16>e.y&&!this.invulnerable&&!this.shieldTicks){this.hits++;this.invulnerable=40;}
  // Conservative contact envelope for the full 64x64 native tile artwork.
  if(this.boss&&this.bossVisible&&this.player.x+20>this.bossX&&this.player.x<this.bossX+32&&this.player.y+16>this.bossTop&&this.player.y<this.bossTop+64&&!this.invulnerable&&!this.shieldTicks){this.hits++;this.invulnerable=40;}
  const f={...this.project.firing};if(this.kind&&this.kind!==7)f.mode=0;if(this.kind===7){f.interval=8;f.speed=6;}if(worldStep&&this.boss){if(this.bossHP<=0)this.defeatBurst();else if(this.options.curtainOnly)this.curtainAttack();else this.bossActions();}
  if(worldStep&&f.mode&&++this.fireClock>=f.interval){this.fireClock=0;this.enemyIndex=this.boss?(this.enemyIndex===0?4:0):(this.enemyIndex+1)&7;if(this.kind===7){for(let n=0;n<6;n++){if(this.enemyIndex<2||this.enemyIndex>7)this.enemyIndex=2;const candidate=this.enemies[this.enemyIndex];if(candidate.visible&&candidate.meteorY>=8&&candidate.meteorY<128)break;this.enemyIndex++;}}
   const e=this.enemies[this.enemyIndex%8];
   if(this.hostile.length<4&&(this.kind!==7||(e.i>=2&&e.meteorY>=8&&e.meteorY<128))&&e.x-this.player.x>=52&&e.visible&&e.x>=24&&e.x<120&&e.y+8<124)this.hostile.push({x:e.x,y:e.y+8,style:0,dy:f.mode===2?Math.sign(this.player.y-e.y)*Math.floor((Math.abs(this.player.y-e.y)+Math.floor(Math.ceil((e.x-this.player.x)/f.speed)/2))/Math.ceil((e.x-this.player.x)/f.speed)):0});
  }
  for(const b of this.hostile){if(worldStep&&!b.boss){b.x-=f.speed;b.y+=b.dy;}if((b.boss&&b.art==='orb'?(b.x+6>this.player.x+6&&b.x+2<this.player.x+16&&b.y+12>this.player.y+4&&b.y+4<this.player.y+12):((b.boss?b.x+8>=this.player.x:b.x+2>this.player.x)&&b.x<this.player.x+20&&(b.boss?b.y+16>=this.player.y:b.y+2>this.player.y)&&b.y<this.player.y+16))){if(!this.invulnerable&&!this.shieldTicks){this.hits++;this.invulnerable=40;}if(!b.boss)b.x=-99;}}
  this.hostile=this.hostile.filter(b=>b.x>=0&&b.y>=0&&b.y<(b.boss?128:125));
  for(const e of this.enemies)if((!this.kind||(this.kind===7&&e.i>=2))&&e.hp<=0&&!e.defeated){e.defeated=true;this.score+=100;const award=!this.kind&&this.options.drops?.[this.record[2]]?.[e.i];if(award)this.pickups.push({x:e.x,y:e.y,type:award===7?'Bomb':award===6?'Clock':award===5?'Shield':`Weapon ${award}`});}
  if(this.boss&&this.bossHP<=0&&!this.rewarded){this.rewarded=true;this.score+=1000;this.pickups=this.kind===5?[]:[{x:80,y:32,type:'Weapon 2'},{x:96,y:60,type:'Weapon 3'},{x:112,y:88,type:'Shield'}];}
  for(const p of this.pickups){p.x-=2;if(p.x<this.player.x+20&&p.x+8>this.player.x&&p.y<this.player.y+16&&p.y+16>this.player.y){this.collected.push(p.type);if(p.type==='Clock')this.clocks=Math.min(3,this.clocks+1);else if(p.type==='Bomb')this.bombs=Math.min(3,this.bombs+1);else if(p.type==='Shield')this.shields=Math.min(3,this.shields+1);else this.weapon=Number(p.type.slice(-1));p.x=-100;}}
  this.pickups=this.pickups.filter(p=>p.x>-8);
  if((!this.kind&&this.age>=150)||(this.meteor&&this.age>=192&&this.enemies.every(e=>!e.visible))||(this.kind===8&&this.enemies.every(e=>e.meteorY===255))||(this.boss&&this.rewarded&&this.ai.phase===10&&!this.pickups.length)){if(this.options.loop===false)this.complete=true;else this.reset();}
 }
 get laserShape(){const route=laserPatterns.routes[this.laser.variant];return laserPatterns.shapes[route.steps[this.laser.index%15]];}
 get laserLines(){const shape=this.laserShape;if(!shape)return [];return [8,24,40,56,72,88,104,120].flatMap((y,i)=>shape.mask&(1<<i)?[{y,slope:!shape.type?0:shape.type===2&&(i&1)?-1:1}]:[]);}
 laserContact(){return this.laserLines.some(line=>{for(let col=Math.floor(this.player.x/4);col<=Math.floor((this.player.x+19)/4);col++){const y=line.y+line.slope*(col-16);if(y>=0&&y<125&&this.player.y<y+4&&this.player.y+16>y)return true;}return false;});}
 laserUpdate(dt){
  const l=this.laser;if(!l.started){l.started=true;return;}l.remaining=Math.max(0,l.remaining-dt);if(l.remaining<1e-8)l.remaining=0;
  if(l.remaining===0){
   if(l.phase===1){l.phase=2;l.remaining=laserPatterns.liveFrames/50;}
   else if(++l.index>=l.end){l.phase=3;if(this.options.loop===false)this.complete=true;else this.reset();return;}
   else{l.phase=1;l.remaining=laserPatterns.warningFrames/50;}
  }
  if(l.phase===2&&!this.invulnerable&&!this.shieldTicks&&this.laserContact()){
   this.hits++;this.invulnerable=40;l.phase=1;l.remaining=laserPatterns.warningFrames/50;
  }
 }
 defeatBurst(){
  this.hostile=[];
  if(!this.deathStarted){
   this.deathStarted=true;this.ai.phase=9;this.ai.timer=0;
   this.deathShots=Array.from({length:8},(_,i)=>({x:this.bossX+12,y:this.bossTop+24,dx:[-3,-2,0,2,3,2,0,-2][i],dy:[0,-4,-6,-4,0,4,6,4][i]}));
  }else if(this.ai.phase===9){
   if(++this.ai.timer>=24){this.deathShots=[];this.ai.phase=10;}
   else{for(const b of this.deathShots){b.x+=b.dx;b.y+=b.dy;}this.deathShots=this.deathShots.filter(b=>b.x>=0&&b.x<128&&b.y>=0&&b.y<128);}
  }
 }
 bossActions(){
  const a=this.ai,rand=()=>a.rng=(a.rng>>1)^((a.rng&1)?0xb8:0),count=()=>this.hostile.length;
  const clean=()=>{this.hostile=this.hostile.filter(b=>b.x>=0);};
  const orbs=()=>{for(const b of this.hostile){b.x-=4;b.age++;if(b.style===2)b.y=Math.max(0,Math.min(112,b.baseY+(this.sine[(b.age*8)&255]>>1)-14));}clean();};
  const rocks=()=>{for(let lane=7;lane>=0;lane--){let b=this.hostile.find(b=>b.lane===lane);if(b){b.progress+=[2,4,6,3,5,4,7,5][lane];if(b.progress>=128){this.hostile=this.hostile.filter(v=>v!==b);a.wait[lane]=32;continue;}}else if(a.phase===5&&this.project.firing.mode){if(a.wait[lane]>0){a.wait[lane]--;continue;}b={boss:true,art:'meteor',lane,progress:0,x:0,y:0};this.hostile.push(b);}else continue;
   b.x=a.direction===3?127-b.progress:[8,68,108,38,88,18,58,118][lane];b.y=a.direction===3?[0,64,112,32,96,16,80,48][lane]:a.direction===2||(a.direction===6&&(lane&1))?127-b.progress:b.progress;
  }};
  if(this.bossHP<=0){this.hostile=[];return;}
  if(a.phase===0){a.phase=8;this.bossX=128;this.bossTop=32;a.timer=0;a.cooldown=0;a.frame=0;a.art=1;this.hostile=[];}
  if(a.phase===1||a.phase===2){
   const i=a.timer&15;
   this.bossTop=[64,40,16,16,8,14,8,4,0,4,8,14,8,16,16,40][i];
   a.frame=[0,1,1,2,2,3,3,3,3,3,3,3,2,2,1,1][i];
   const limit=a.phase===2?3:6;let lane=0;while(lane<limit&&this.hostile.some(b=>b.lane===lane))lane++;
   if(this.project.firing.mode&&lane<limit&&(rand()&(a.phase===2?7:3))===0){
    const y=[103,80,56,40,32,22,16,12,8,12,16,22,32,40,56,80][i];
    this.hostile.push({boss:true,art:'orb',lane,x:this.bossX,y,baseY:y,age:0,style:a.phase});
   }
   orbs();
   if(++a.timer>=96){if(!this.options.guardian&&a.nextHazard){a.timer=0;a.cooldown=0;a.art=1;a.phase=1+(rand()&1);}else{a.phase=3;a.nextHazard=4+(rand()&1);}}
  }else if(a.phase===3){
   orbs();if(this.bossX<128)this.bossX+=2;else if(!count()){
    a.phase=a.nextHazard;a.timer=0;a.cooldown=0;this.bossWarmup=9;this.bossClock=29;this.attack=null;
    if(a.phase===4){const variant=this.options.curtainVariant===undefined?nextCurtainVariant++%12:(this.options.curtainVariant+this.curtainVisits++)%12;this.curtainRotation=variant%6;this.curtainGap=Math.floor(variant/6);this.attackCycle=-1;a.art=0;this.bossX=88;this.bossTop=32;}else{a.art=2;a.direction=[1,2,3,6][rand()&3];a.wait=Array.from({length:8},(_,i)=>i?i*16+24:0);}
   }
  }else if(a.phase===4){
   a.cooldown^=1;if(a.cooldown){const warming=this.bossWarmup>0;this.curtainAttack();clean();if(!warming&&++a.timer>=120)a.phase=7;}
  }
  else if(a.phase===5){rocks();if(++a.timer>=192)a.phase=7;}
  else if(a.phase===7){
   if(a.art===2)rocks();else{a.cooldown^=1;if(!a.cooldown)return;for(const b of this.hostile)advanceBossShot(b);clean();}
   if(!count()){a.phase=6;this.bossX=128;this.bossX-=2;}
  }else{
   this.bossX-=2;if(this.bossX===88){a.timer=0;a.cooldown=0;a.art=1;a.phase=1+(rand()&1);this.attack=null;}
  }
  for(const e of this.enemies){e.x=this.bossX+(e.i%4)*8;e.y=this.bossTop+16+Math.floor(e.i/4)*16;e.visible=this.bossVulnerable;}
 }
 curtainAttack(){
  const setting=this.project.boss||{pattern:0,difficulty:1};
  this.bombSuppress=Math.max(0,this.bombSuppress-1);
  if(this.bossHP<=0||!this.project.firing.mode){this.hostile=[];this.attack=null;return;}
  if(this.bossWarmup>0){this.bossWarmup--;this.bossClock=29;return;}
  const phase=this.bossClock=(this.bossClock+1)%30;
  if(phase===0||!this.attack){this.attackCycle++;const pattern=setting.pattern||(this.attackCycle+this.curtainRotation)%formations.length+1;
   this.attack={pattern,phase:0,state:'forming',gapRow:(this.attackCycle+this.curtainGap)%2===0?5:1,guardDelay:formations[pattern-1][setting.pattern?'soloGuards':'mixedGuards'][(this.attackCycle+this.curtainGap)%2===0?1:0]};
  }
  const a=this.attack;a.phase=phase;a.state=phase<=18?'forming':'rush';
  for(const b of this.hostile)advanceBossShot(b);
  for(let lane=0;lane<8;lane++)if(phase===(lane<6?0:a.guardDelay)&&!this.hostile.some(b=>b.lane===lane&&b.x>=0)){
   const head={x:88,y:48};this.hostile.push({boss:true,art:'curtain',x:head.x,y:head.y+16,lane,pattern:a.pattern,age:0,gapRow:a.gapRow,baseX:head.x,sine:this.sine});
  }

 }

}
// A session preserves the pilot's inventory when advancing through edited waves.
class Campaign{
 constructor(project,sine,sector=0,wave=0,options={}){this.project=project;this.sine=sine;this.options=options;this.mode='playing';this.encounter=new Encounter(project,sine,sector,wave,{...options,loop:false});}
 update(input={}){
  if(this.mode!=='playing')return;
  const e=this.encounter;e.update(input);
  if(e.hits>=3){this.mode='lost';return;}
  if(!e.complete)return;
  if(this.options.guardians&&e.wave===47&&e.kind!==5){
   const boss=new Encounter(this.project,this.sine,e.sector,47,{...this.options,guardian:true,loop:false});
   this.carry(e,boss);this.encounter=boss;return;
  }
  let sector=e.sector,wave=e.wave+1;
  if(wave===48){wave=0;sector++;}
  if(sector===8||(this.options.sectorOnly&&sector!==e.sector)){this.mode='won';return;}
  const next=new Encounter(this.project,this.sine,sector,wave,{...this.options,loop:false});
  this.carry(e,next);this.encounter=next;
 }
 carry(e,next){
  for(const key of ['player','hits','tick','bombs','bombHeld','shields','shieldHeld','shieldTicks','clocks','clockHeld','slowRemaining','slowPhase','weapon','weaponHeld','score'])next[key]=e[key];
 }
}
const api={laserPatterns,formations,validate,Encounter,Campaign,advanceBossShot,measureBulletWaves};if(typeof module!=='undefined')module.exports=api;else root.FlightWorkshop=api;
})(globalThis);
