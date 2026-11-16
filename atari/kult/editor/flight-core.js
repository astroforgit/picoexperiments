(function(root){'use strict';
const native=typeof module!=='undefined'?require('../web/engine.js'):root.Kult;
function validate(p,lib){
 const int=(v,a,b)=>Number.isInteger(v)&&v>=a&&v<=b;
 if(!p||p.version!==1||!lib.ships.some(a=>a.id===p.ship))throw Error('Unknown project or ship');
 if(!Array.isArray(p.slots)||p.slots.length!==32||p.slots.some(id=>!lib.enemies.some(a=>a.id===id)))throw Error('Invalid enemy slots');
 if(!Array.isArray(p.waves)||p.waves.length!==8||p.waves.some(s=>!Array.isArray(s)||s.length!==48||s.some(w=>!Array.isArray(w)||w.length!==4||w.some((v,i)=>!int(v,i===3?1:0,i===3?16:31)))))throw Error('Invalid wave data');
 if(!Array.isArray(p.motions)||p.motions.length!==32||p.motions.some(m=>!Array.isArray(m)||m.length!==8||m.some(v=>!int(v,-128,127))))throw Error('Invalid movement data');
 if(p.encounters===undefined)p={...p,encounters:Array.from({length:8},()=>Array(48).fill(0))};
 if(!Array.isArray(p.encounters)||p.encounters.length!==8||p.encounters.some(s=>!Array.isArray(s)||s.length!==48||s.some(n=>!int(n,0,4))))throw Error('Invalid encounter types');
 if(!p.firing||!int(p.firing.mode,0,2)||!int(p.firing.interval,12,180)||!int(p.firing.speed,1,4))throw Error('Invalid firing settings');
 if(p.boss===undefined)p={...p,boss:{pattern:0,difficulty:1}};
 if(!p.boss||!int(p.boss.pattern,0,3)||!int(p.boss.difficulty,0,2))throw Error('Invalid boss attack settings');
 return JSON.parse(JSON.stringify(p));
}
class Encounter{
 constructor(project,sine,sector=0,wave=0,options={}){this.options=options;this.weapon=1;this.weaponHeld=false;this.score=0;this.project=project;this.sine=sine;this.sector=sector;this.wave=wave;this.player={x:12,y:56};this.hits=0;this.tick=0;this.bombs=3;this.bombHeld=false;this.shields=3;this.shieldTicks=0;this.shieldHeld=false;this.reset();}
 get kind(){if(this.options.bossPreview)return 4;if(this.options.guardian)return 5;return this.project.encounters?.[this.sector]?.[this.wave]||0;}
 reset(){this.attack=null;this.attackCycle=-1;this.bombSuppress=0;this.complete=false;this.bossHP=this.options.guardian?100:this.record[3]*8;this.bossMaxHP=this.bossHP;this.rewarded=false;this.pickups=[];this.collected=[];this.age=0;this.phase=[0,0,0,0];this.enemies=Array.from({length:this.options.guardian?16:8},(_,i)=>({i,x:160,y:i*14,hp:this.record[3],trail:[],meteorY:128,wait:i?i*16+24:0}));this.shots=[];this.hostile=[];this.cooldown=0;this.invulnerable=40;this.fireClock=0;this.enemyIndex=0;}
 get record(){return this.project.waves[this.sector][this.wave];}
 update(input={}){
  if(this.complete)return;
  if(input.weapon&&!this.weaponHeld)this.weapon=this.weapon%4+1;
  this.weaponHeld=!!input.weapon;
  this.tick++;this.age++;this.cooldown=Math.max(0,this.cooldown-1);this.invulnerable=Math.max(0,this.invulnerable-1);
  this.shieldTicks=Math.max(0,this.shieldTicks-1);
  if(input.shield&&!this.shieldHeld&&!this.shieldTicks&&this.shields>0){this.shields--;this.shieldTicks=17;}
  this.shieldHeld=!!input.shield;
  if(input.bomb&&!this.bombHeld&&this.bombs>0){this.bombs--;this.hostile=[];this.bombSuppress=12;if(this.kind>=4)this.bossHP=Math.max(0,this.bossHP-16);else if(!this.kind)for(const e of this.enemies)e.hp=0;}
  this.bombHeld=!!input.bomb;
  this.player.x=Math.max(0,Math.min(100,this.player.x+((input.right?1:0)-(input.left?1:0))*3));
  this.player.y=Math.max(0,Math.min(112,this.player.y+((input.down?1:0)-(input.up?1:0))*4));
  const points=native.motionPoints(this.sine,this.project.motions[this.record[1]].map(n=>n&255),this.phase);
  const entry=Math.max(0,96-this.age*6),exit=Math.max(0,(this.age-100)*4);
  for(const e of this.enemies){e.x=points[e.i%8][0]+entry-exit;e.y=points[e.i%8][1];
   if(this.kind>0&&this.kind<4){
    if(e.meteorY<128){e.meteorY+=[2,4,6,3,5,4,7,5][e.i];if(e.meteorY>=128){e.meteorY=128;e.wait=32;}}
    else if(this.age<192){if(e.wait>0)e.wait--;else e.meteorY=0;}
    e.visible=e.meteorY<128;e.x=[20,68,105,40,88,12,58,115][e.i];e.y=e.meteorY;
   }
   else if(this.kind>=4){e.x=Math.max(88,128-this.age*2)+(e.i%4)*8;e.y=48+Math.floor(e.i/4)*16;e.visible=this.bossHP>0;}
   else e.visible=e.hp>0;
e.trail.push([e.x,e.y]);if(e.trail.length>28)e.trail.shift();}
  if(input.fire&&!this.cooldown){for(const y of [[8],[4,11],[2,8,14],[1,5,10,14]][this.weapon-1])this.shots.push({x:this.player.x+20,y:this.player.y+y});this.cooldown=4;}
  for(const b of this.shots){b.x+=6;for(const e of this.enemies)if(e.visible&&b.x>=e.x&&b.x<e.x+8&&b.y>=e.y&&b.y<e.y+16){if(!this.kind)e.hp--;else if(this.kind>=4)this.bossHP=Math.max(0,this.bossHP-1);b.x=999;break;}}
  this.shots=this.shots.filter(b=>b.x<128);
  if(!this.kind)for(const e of this.enemies)if(e.hp<=0)e.visible=false;
  if(this.kind>=4&&this.bossHP<=0)for(const e of this.enemies)e.visible=false;
  for(const e of this.enemies)if(e.visible&&this.player.x<e.x+8&&this.player.x+20>e.x&&this.player.y<e.y+16&&this.player.y+16>e.y&&!this.invulnerable&&!this.shieldTicks){this.hits++;this.invulnerable=40;}
  const f={...this.project.firing};if(this.kind)f.mode=0;if(this.kind>=4)this.bossAttack();
  if(f.mode&&++this.fireClock>=f.interval){this.fireClock=0;this.enemyIndex=this.kind>=4?(this.enemyIndex===0?4:0):(this.enemyIndex+1)&7;const e=this.enemies[this.enemyIndex];
   if(this.hostile.length<4&&e.visible&&e.x>=24&&e.x<120&&e.y+8<124)this.hostile.push({x:e.x,y:e.y+8,style:!this.kind&&(this.record[0]&1)&&!this.hostile.some(b=>b.style)?1:0,dy:f.mode===2?Math.sign(this.player.y-e.y):0});
  }
  for(const b of this.hostile){if(b.boss){b.age++;b.x-=b.speed;const phase=((this.attack.pattern===3?Math.floor(b.age/2):b.age)+b.lane*4)&15;const curve=[2,2,1,1,0,-1,-2,-2,-2,-2,-1,-1,0,1,2,2][phase];if(b.age>0)b.y+=b.aim+curve+(this.attack.pattern===1?[0,-1,1,0][b.lane]:0);}else{b.x-=f.speed;b.y+=b.dy;}if(b.x+2>=this.player.x&&b.x<this.player.x+20&&b.y+2>=this.player.y&&b.y-2<this.player.y+16){if(!this.invulnerable&&!this.shieldTicks){this.hits++;this.invulnerable=40;}b.x=-99;}}
  this.hostile=this.hostile.filter(b=>b.x>=0&&b.y>=0&&b.y<125);
  for(const e of this.enemies)if(!this.kind&&e.hp<=0&&!e.defeated){e.defeated=true;this.score+=100;const award=this.options.drops?.[this.record[2]]?.[e.i];if(award)this.pickups.push({x:e.x,y:e.y,type:award===5?'Shield':`Weapon ${award}`});}
  if(this.kind>=4&&this.bossHP<=0&&!this.rewarded){this.rewarded=true;this.score+=1000;this.pickups=this.kind===5?[]:[{x:80,y:32,type:'Weapon 2'},{x:96,y:60,type:'Weapon 3'},{x:112,y:88,type:'Shield'}];}
  for(const p of this.pickups){p.x-=2;if(p.x<this.player.x+20&&p.x+8>this.player.x&&p.y<this.player.y+16&&p.y+16>this.player.y){this.collected.push(p.type);if(p.type==='Shield')this.shields=Math.min(3,this.shields+1);else this.weapon=Number(p.type.slice(-1));p.x=-100;}}
  this.pickups=this.pickups.filter(p=>p.x>-8);
  if((!this.kind&&this.age>=150)||(this.kind>0&&this.kind<4&&this.age>=192&&this.enemies.every(e=>!e.visible))||(this.kind>=4&&this.rewarded&&!this.pickups.length)){if(this.options.loop===false)this.complete=true;else this.reset();}
 }
 bossAttack(){
  const setting=this.project.boss||{pattern:0,difficulty:1};
  this.bombSuppress=Math.max(0,this.bombSuppress-1);
  if(this.bossHP<=0||!this.project.firing.mode){this.hostile=[];this.attack=null;return;}
  // Captured aim is fixed for each train; bullets never home on the ship.
  const cycle=Math.floor((this.age-1)/192),phase=(this.age-1)%192;
  if(cycle!==this.attackCycle){this.attackCycle=cycle;const pattern=setting.pattern||cycle%3+1;
   this.attack={pattern,target:this.player.y+8,phase:0,state:'warning'};
  }
  const a=this.attack;a.phase=phase;a.state=phase<24?'warning':(phase<56||phase>=80&&phase<112)?'firing':this.hostile.length?'draining':'rest';
  const train=phase>=24&&phase<56?phase-24:phase>=80&&phase<112?phase-80:-1;
  if(train<0||train%8||this.bombSuppress||this.hostile.length>=4)return;
  const lane=Math.floor(train/8),head=this.enemies[0],y=head.y+16;
  this.hostile.push({boss:true,x:head.x,startX:head.x,y,age:-1,lane,aim:Math.sign(a.target-y),speed:2+setting.difficulty,style:0,dy:0});

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
  for(const key of ['player','hits','tick','bombs','bombHeld','shields','shieldHeld','shieldTicks','weapon','weaponHeld','score'])next[key]=e[key];
 }
}
const api={validate,Encounter,Campaign};if(typeof module!=='undefined')module.exports=api;else root.FlightWorkshop=api;
})(globalThis);
