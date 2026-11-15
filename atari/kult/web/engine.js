/* Native browser reconstruction. No Atari hardware emulation. */
(function(root){
'use strict';
const W=512,H=256,STEP=1/50;
const clamp=(n,a,b)=>Math.max(a,Math.min(b,n));
function motionPoints(sine,motion,phase){
 const p=phase.slice(),out=[];
 for(let i=0;i<8;i++){
  out.push([(sine[p[2]]+sine[p[3]])&127,(sine[p[0]]+sine[p[1]])&127]);
  for(let j=0;j<4;j++)p[j]=(p[j]+motion[j+4])&255;
 }
 for(let j=0;j<4;j++)phase[j]=(phase[j]+motion[j])&255;
 return out;
}
class Game{
 constructor(data){this.data=data;this.mode='title';this.events=[];this.tick=0;this.stage=0;this.score=0;this.lives=3;this.bombs=3;this.weapon=1;this.player={x:36,y:112};this.scroll=0;this.enemies=[];this.shots=[];this.hostile=[];this.pickups=[];this.effects=[];this.wave=0;this.boss=null;}
 start(stage=0){this.stage=clamp(stage|0,0,7);this.score=0;this.lives=3;this.bombs=3;this.weapon=1;this.tick=0;this.kills=0;this.mode='playing';this.events=[];this.loadStage();}
 loadStage(){this.scroll=0;this.wave=0;this.waveAge=0;this.wait=60;this.player={x:36,y:112};this.invulnerable=150;this.cooldown=0;this.bombHeld=false;this.enemies=[];this.shots=[];this.hostile=[];this.pickups=[];this.effects=[];this.boss=null;this.guardianDefeated=false;this.banner=130;this.events.push('stage');}
 pause(){if(this.mode==='playing')this.mode='paused';else if(this.mode==='paused')this.mode='playing';}
 spawnWave(){
  const record=this.data.stages[this.stage].waves[this.wave++];this.record=record;this.phase=[0,0,0,0];this.waveAge=0;
  this.enemies=Array.from({length:8},(_,i)=>({i,design:record[0],x:W+40+i*20,y:40+i*22,hp:1+Math.floor(this.stage/3),alive:true}));
 }
 burst(x,y,big=false){this.effects.push({x,y,age:0,big});this.events.push('explode');}
 destroy(e){if(!e.alive)return;e.alive=false;this.score+=100*(this.stage+1);this.kills++;this.burst(e.x,e.y);
  if(this.kills%12===0)this.pickups.push({x:e.x,y:e.y,kind:this.kills%36===0?'life':this.kills%24===0?'bomb':'weapon',age:0});
 }
 hit(){if(this.invulnerable>0||this.mode!=='playing')return;this.lives--;this.weapon=Math.max(1,this.weapon-1);this.burst(this.player.x+32,this.player.y,true);this.invulnerable=150;this.hostile=[];this.player={x:36,y:112};if(this.lives<=0){this.mode='gameover';this.events.push('end');}}
 fire(){if(this.cooldown>0||this.shots.length>=6)return;this.cooldown=9;
  const spread=this.weapon===3?[-38,0,38]:this.weapon===2?[-22,22]:[0];
  for(const vy of spread){if(this.shots.length>=6)break;this.shots.push({x:this.player.x+66,y:this.player.y+15,vx:420,vy,alive:true});}this.events.push('shot');
 }
 bomb(){if(!this.bombs)return;this.bombs--;for(const e of this.enemies)this.destroy(e);this.hostile=[];if(this.boss)this.boss.hp=Math.max(0,this.boss.hp-18);this.effects.push({x:256,y:128,age:0,big:true,flash:true});this.events.push('bomb');}

 update(input={}){
  if(this.mode!=='playing')return;
  this.tick++;this.banner=Math.max(0,this.banner-1);this.invulnerable=Math.max(0,this.invulnerable-1);this.cooldown=Math.max(0,this.cooldown-1);
  let dx=(input.right?1:0)-(input.left?1:0),dy=(input.down?1:0)-(input.up?1:0),len=Math.hypot(dx,dy)||1;
  this.player.x=clamp(this.player.x+dx/len*3,0,W-80);this.player.y=clamp(this.player.y+dy/len*3,0,H-32);
  if(input.target){this.player.x=clamp(this.player.x+clamp(input.target.x-this.player.x-40,-6,6),0,W-80);this.player.y=clamp(this.player.y+clamp(input.target.y-this.player.y-16,-6,6),0,H-32);}
  if(input.fire)this.fire();if(input.bomb&&!this.bombHeld)this.bomb();this.bombHeld=!!input.bomb;
  this.scroll=Math.min(512*32-W,this.scroll+1.35);
  this.effects=this.effects.filter(e=>++e.age<30);
  if(!this.boss&&!this.guardianDefeated){
   this.waveAge++;
   if(this.enemies.length&&this.tick%3===0){const pts=motionPoints(this.data.sine,this.data.motions[this.record[1]],this.phase);const entry=Math.max(0,512-this.waveAge*5),exit=Math.max(0,(this.waveAge-280)*4);
    for(const e of this.enemies){e.x=pts[e.i][0]*3.5+entry-exit;e.y=clamp(pts[e.i][1]*1.8,4,H-36);}
   }
   if(this.waveAge>410)this.enemies=[];
   this.enemies=this.enemies.filter(e=>e.alive);
   if(!this.enemies.length&&--this.wait<=0){if(this.wave<48){this.spawnWave();this.wait=35;}else{this.boss={x:360,y:64,hp:60+this.stage*12,maxHp:60+this.stage*12,age:0};this.banner=100;this.hostile=[];}}
  }
  if(this.boss){const b=this.boss;b.age++;b.y=64+Math.sin(b.age/65)*46;
   if(b.age%65===0){for(const vy of [-70,0,70])this.hostile.push({x:b.x,y:b.y+64,vx:-150-this.stage*8,vy});}
   if(b.hp<=0){this.score+=3000*(this.stage+1);this.burst(b.x+64,b.y+64,true);this.boss=null;this.guardianDefeated=true;this.wait=140;this.banner=140;this.events.push('clear');}
  }
  if(this.guardianDefeated&&--this.wait<=0){if(this.stage===7){this.mode='won';this.events.push('end');}else{this.stage++;this.bombs=Math.min(5,this.bombs+1);this.loadStage();}return;}
  for(const s of this.shots){s.x+=s.vx*STEP;s.y+=s.vy*STEP;
   for(const e of this.enemies){if(e.alive&&s.alive&&s.x>e.x&&s.x<e.x+32&&s.y>e.y&&s.y<e.y+32){s.alive=false;if(--e.hp<=0)this.destroy(e);}}
   if(this.boss&&s.alive&&s.x>this.boss.x&&s.x<this.boss.x+128&&s.y>this.boss.y&&s.y<this.boss.y+128){s.alive=false;this.boss.hp--;this.events.push('hit');}
  }
  this.shots=this.shots.filter(s=>s.alive&&s.x<W+20&&s.y>0&&s.y<H);
  for(const s of this.hostile){s.x+=s.vx*STEP;s.y+=s.vy*STEP;if(Math.abs(s.x-(this.player.x+40))<19&&Math.abs(s.y-(this.player.y+16))<10)this.hit();}
  this.hostile=this.hostile.filter(s=>s.x>-10&&s.y>-10&&s.y<H+10);
  for(const e of this.enemies)if(e.alive&&Math.abs(e.x+16-(this.player.x+40))<26&&Math.abs(e.y+16-(this.player.y+16))<20)this.hit();
  if(this.boss&&this.player.x+60>this.boss.x&&this.player.y+24>this.boss.y&&this.player.y+8<this.boss.y+128)this.hit();
  for(const p of this.pickups){p.x-=1.4;p.age++;if(Math.abs(p.x-(this.player.x+40))<32&&Math.abs(p.y-(this.player.y+16))<26){p.age=999;if(p.kind==='weapon')this.weapon=Math.min(3,this.weapon+1);if(p.kind==='bomb')this.bombs=Math.min(5,this.bombs+1);if(p.kind==='life')this.lives=Math.min(5,this.lives+1);this.score+=250;this.events.push('pickup');}}
  this.pickups=this.pickups.filter(p=>p.x>-30&&p.age<600);
 }
}
const api={Game,motionPoints,W,H,STEP};if(typeof module!=='undefined')module.exports=api;else root.Kult=api;
})(typeof globalThis!=='undefined'?globalThis:this);
