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
 return JSON.parse(JSON.stringify(p));
}
class Encounter{
 constructor(project,sine,sector=0,wave=0){this.project=project;this.sine=sine;this.sector=sector;this.wave=wave;this.player={x:12,y:56};this.hits=0;this.tick=0;this.shields=3;this.shieldTicks=0;this.shieldHeld=false;this.reset();}
 get kind(){return this.project.encounters?.[this.sector]?.[this.wave]||0;}
 reset(){this.bossHP=this.record[3]*8;this.rewarded=false;this.pickups=[];this.collected=[];this.age=0;this.phase=[0,0,0,0];this.enemies=Array.from({length:8},(_,i)=>({i,x:160,y:i*14,hp:this.record[3],trail:[],meteorY:128,wait:i?i*16+24:0}));this.shots=[];this.hostile=[];this.cooldown=0;this.invulnerable=40;this.fireClock=0;this.enemyIndex=0;}
 get record(){return this.project.waves[this.sector][this.wave];}
 update(input={}){
  this.tick++;this.age++;this.cooldown=Math.max(0,this.cooldown-1);this.invulnerable=Math.max(0,this.invulnerable-1);
  this.shieldTicks=Math.max(0,this.shieldTicks-1);
  if(input.shield&&!this.shieldHeld&&!this.shieldTicks&&this.shields>0){this.shields--;this.shieldTicks=17;}
  this.shieldHeld=!!input.shield;
  this.player.x=Math.max(0,Math.min(100,this.player.x+((input.right?1:0)-(input.left?1:0))*3));
  this.player.y=Math.max(0,Math.min(112,this.player.y+((input.down?1:0)-(input.up?1:0))*4));
  const points=native.motionPoints(this.sine,this.project.motions[this.record[1]].map(n=>n&255),this.phase);
  const entry=Math.max(0,96-this.age*6),exit=Math.max(0,(this.age-100)*4);
  for(const e of this.enemies){e.x=points[e.i][0]+entry-exit;e.y=points[e.i][1];
   if(this.kind>0&&this.kind<4){
    if(e.meteorY<128){e.meteorY+=[2,4,6,3,5,4,7,5][e.i];if(e.meteorY>=128){e.meteorY=128;e.wait=32;}}
    else if(this.age<192){if(e.wait>0)e.wait--;else e.meteorY=0;}
    e.visible=e.meteorY<128;e.x=[20,68,105,40,88,12,58,115][e.i];e.y=e.meteorY;
   }
   else if(this.kind===4){e.x=Math.max(88,128-this.age*2)+(e.i%4)*8;const t=this.age&63;e.y=40+Math.floor((t<32?t:63-t)/2)+Math.floor(e.i/4)*16;e.visible=this.bossHP>0;}
   else e.visible=e.hp>0;
e.trail.push([e.x,e.y]);if(e.trail.length>28)e.trail.shift();}
  if(input.fire&&!this.cooldown){this.shots.push({x:this.player.x+20,y:this.player.y+8});this.cooldown=4;}
  for(const b of this.shots){b.x+=6;for(const e of this.enemies)if(e.visible&&b.x>=e.x&&b.x<e.x+8&&b.y>=e.y&&b.y<e.y+16){if(!this.kind)e.hp--;else if(this.kind===4)this.bossHP=Math.max(0,this.bossHP-1);b.x=999;break;}}
  this.shots=this.shots.filter(b=>b.x<128);
  if(this.kind)for(const e of this.enemies)if(e.visible&&this.player.x<e.x+8&&this.player.x+20>e.x&&this.player.y<e.y+16&&this.player.y+16>e.y&&!this.invulnerable&&!this.shieldTicks){this.hits++;this.invulnerable=40;}
  const f={...this.project.firing};if(this.kind>0&&this.kind<4)f.mode=0;if(this.kind===4){f.interval=3;if((this.age&63)>=40||this.bossHP<=0)f.mode=0;}
  if(f.mode&&++this.fireClock>=f.interval){this.fireClock=0;this.enemyIndex=this.kind===4?(this.enemyIndex===0?4:0):(this.enemyIndex+1)&7;const e=this.enemies[this.enemyIndex];
   if(this.hostile.length<4&&e.visible&&e.x>=24&&e.x<120&&e.y+8<124)this.hostile.push({x:e.x,y:e.y+8,style:!this.kind&&(this.record[0]&1)&&!this.hostile.some(b=>b.style)?1:0,dy:f.mode===2?Math.sign(this.player.y-e.y):0});
  }
  for(const b of this.hostile){b.x-=f.speed;b.y+=b.dy;if(b.x>=this.player.x&&b.x<this.player.x+20&&b.y>=this.player.y&&b.y<this.player.y+16){if(!this.invulnerable&&!this.shieldTicks){this.hits++;this.invulnerable=40;}b.x=-99;}}
  this.hostile=this.hostile.filter(b=>b.x>=0&&b.y>=0&&b.y<125);
  if(this.kind===4&&this.bossHP<=0&&!this.rewarded){this.rewarded=true;this.pickups=[{x:80,y:32,type:'Weapon 2'},{x:96,y:60,type:'Weapon 3'},{x:112,y:88,type:'Shield'}];}
  for(const p of this.pickups){p.x-=2;if(p.x<this.player.x+20&&p.x+8>this.player.x&&p.y<this.player.y+16&&p.y+16>this.player.y){this.collected.push(p.type);if(p.type==='Shield')this.shields=Math.min(3,this.shields+1);p.x=-100;}}
  this.pickups=this.pickups.filter(p=>p.x>-8);
  if((!this.kind&&this.age>=150)||(this.kind>0&&this.kind<4&&this.age>=192&&this.enemies.every(e=>!e.visible))||(this.kind===4&&this.rewarded&&!this.pickups.length))this.reset();
 }
}
const api={validate,Encounter};if(typeof module!=='undefined')module.exports=api;else root.FlightWorkshop=api;
})(globalThis);
