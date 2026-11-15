(function(root){
'use strict';
const STEP=1/50,W=640,H=384,clamp=(v,a,b)=>Math.max(a,Math.min(b,v)),signed=v=>v>127?v-256:v;
function moveTable(e,path){let i=e.phase>=path.length?path.repeat:e.phase;const x=(e.x+path.dx[i])&255;if(x>=path.xmax){e.alive=false;return;}e.x=x;const y=(e.y+path.dy[i])&255;if(y>=path.ymax||y<path.ymin){e.alive=false;return;}e.y=y;e.phase=i+1;}
class Game{
 constructor(data){this.data=data;this.mode='title';this.player={x:4,y:100};this.enemies=[];this.shots=[];this.hostile=[];this.effects=[];this.tick=0;this.score=0;this.lives=3;this.pulses=3;this.spawned=0;this.chapter=0;this.events=[];this.seed=12345;}
 random(){this.seed=(Math.imul(this.seed,1664525)+1013904223)>>>0;return this.seed/4294967296;}
 start(chapter=0){const c=this.data.chapters[clamp(chapter|0,0,this.data.chapters.length-1)];this.cursor=c.cursor;this.delay=c.delay;this.wait=50;this.loopCount=0;this.loopStart=0;this.burstCount=0;this.ending=false;this.mode='playing';this.chapter=chapter|0;this.tick=0;this.score=0;this.lives=3;this.pulses=3;this.spawned=0;this.kills=0;this.seed=12345;this.player={x:4,y:100};this.enemies=[];this.shots=[];this.hostile=[];this.effects=[];this.events=['start'];this.invulnerable=150;this.cooldown=0;this.pulseHeld=false;this.banner=120;}
 pause(){if(this.mode==='playing')this.mode='paused';else if(this.mode==='paused')this.mode='playing';}
 sprite(e){const id=e.type===1?this.data.player[Math.floor(this.tick/7)%4]:this.data.types[e.type]?.[Math.floor(e.x)&3];return this.data.sprites[id]||this.data.sprites[this.data.types[13][0]];}
 box(e){const s=this.sprite(e),h=s.header;return {x:e.x+signed(h[0])+Math.min(h[3],s.width/3),y:e.y-s.height+Math.min(h[4],s.height/3),w:Math.max(2,Math.min(h[5]||s.width*.6,s.width)),h:Math.max(2,Math.min(h[6]||s.height*.6,s.height))};}
 overlap(a,b){return a.x<b.x+b.w&&a.x+a.w>b.x&&a.y<b.y+b.h&&a.y+a.h>b.y;}
 effect(x,y,big=false){this.effects.push({x,y,age:0,big});this.events.push('explode');}
 destroy(e){if(!e.alive)return;e.alive=false;this.score+=e.type===12?5000:100;this.kills++;this.effect(e.x,e.y,e.type===12);if(this.kills%25===0){this.pulses=Math.min(5,this.pulses+1);this.events.push('pickup');}}
 hit(){if(this.invulnerable||this.mode!=='playing')return;this.effect(this.player.x,this.player.y,true);this.lives--;this.invulnerable=150;this.player={x:4,y:100};this.hostile=[];if(this.lives<=0){this.mode='gameover';this.events.push('end');}}
 fire(){if(this.cooldown||this.shots.length)return;this.cooldown=6;this.shots.push({type:6,x:this.player.x+24,y:this.player.y-8,alive:true});this.events.push('shot');}
 pulse(){if(!this.pulses)return;this.pulses--;for(const e of this.enemies){if(e.type===12)e.hp-=12;else this.destroy(e);}this.hostile=[];this.effects.push({x:0,y:0,age:0,flash:true});this.events.push('pulse');}
 spawn(record){const [type,health,x,y,death,phase]=record;this.enemies.push({type,x:x||40+Math.floor(this.random()*120),y:y||30+Math.floor(this.random()*129),phase,vy:0,hp:type===12?48:Math.max(1,health),maxHp:type===12?48:Math.max(1,health),death,age:0,alive:true});this.spawned++;}
 script(){if(this.ending)return;if(this.wait>0){this.wait--;return;}const s=this.data.script;
  for(let budget=0;budget<64;budget++){
   if(this.cursor>=s.length){this.ending=true;return;}const op=s[this.cursor];
   if(op===255){this.delay=s[this.cursor+1];this.cursor+=2;}
   else if(op===254){this.loopCount=s[this.cursor+1];this.loopStart=this.cursor+2;this.cursor+=2;}
   else if(op===253){if(--this.loopCount>0)this.cursor=this.loopStart;else this.cursor++;}
   else if(op===252){if(this.enemies.some(e=>e.alive))return;this.cursor++;this.chapter=Math.max(this.chapter,this.data.chapters.findIndex(c=>c.cursor===this.cursor));this.banner=100;}
   else if(op===251){this.burstCount=s[this.cursor+1];this.cursor+=2;}
   else if(op===250){const address=s[this.cursor+1]+256*s[this.cursor+2];this.cursor+=3;if(address===0xabde){this.ending=true;return;}this.banner=150;}
   else if(op===0){this.ending=true;return;}
   else{if(this.enemies.filter(e=>e.alive).length>=5)return;this.spawn(s.slice(this.cursor,this.cursor+6));this.cursor+=6;}
   if(this.burstCount>0){this.burstCount--;continue;}this.wait=this.delay;return;
  }
 }
 update(input={}){
  if(this.mode!=='playing')return;this.tick++;this.invulnerable=Math.max(0,this.invulnerable-1);this.cooldown=Math.max(0,this.cooldown-1);this.banner=Math.max(0,this.banner-1);
  this.player.x=clamp(this.player.x+((input.right?1:0)-(input.left?1:0))*1,0,124);this.player.y=clamp(this.player.y+((input.down?1:0)-(input.up?1:0))*2,28,174);
  if(input.target){this.player.x=clamp(this.player.x+clamp(input.target.x/4-18-this.player.x,-2,2),0,124);this.player.y=clamp(this.player.y+clamp(input.target.y/2+11-this.player.y,-4,4),28,174);}
  if(input.fire)this.fire();if(input.pulse&&!this.pulseHeld)this.pulse();this.pulseHeld=!!input.pulse;
  this.effects=this.effects.filter(e=>++e.age<25);
  // The original object routines advance once per scheduler visit; render at 50 Hz.
  if(this.tick%2===0){
   for(const e of this.enemies){if(!e.alive)continue;e.age++;
    const path=this.data.paths[e.type];if(path)moveTable(e,path);
    else if(e.type===13){const dx=e.x-this.player.x;e.x+=dx>=16?-Math.floor(dx/16):-4;e.y+=Math.floor((this.player.y-12-e.y)/8);if(e.x<0||e.y<0||e.y>=160)e.alive=false;}
    else if(e.type===15){const i=e.phase++%16;let sum=e.x+this.data.sway[i];e.x=(sum+255+(sum>255?1:0))&255;if(Math.abs(this.player.x-e.x)<32)e.vy=-4;e.y=(e.y+e.vy)&255;if(e.x>=164||e.y>=191)e.alive=false;}
    else{e.x-=2;if(e.x<0)e.alive=false;}
    if([9,12,16].includes(e.type)&&e.age%40===0&&e.x<155){const dx=this.player.x-e.x,dy=this.player.y-10-e.y,len=Math.hypot(dx,dy)||1;this.hostile.push({type:13,x:e.x,y:e.y,vx:dx/len*1.8,vy:dy/len*1.8,alive:true});}
    if(e.hp<=0)this.destroy(e);
    // Bound persistent WIP objects so a missed target cannot block a checkpoint forever.
    if(e.age>650&&e.type!==12)e.alive=false;
   }
   this.script();
  }
  for(const s of this.shots){s.x+=4;for(const e of this.enemies){if(s.alive&&e.alive&&this.overlap({x:s.x,y:s.y-3,w:7,h:5},this.box(e))){s.alive=false;if(--e.hp<=0)this.destroy(e);else this.events.push('hit');}}}
  this.shots=this.shots.filter(s=>s.alive&&s.x<166);
  const playerBox=this.box({...this.player,type:1});
  for(const e of this.enemies)if(e.alive&&this.overlap(playerBox,this.box(e)))this.hit();
  for(const b of this.hostile){b.x+=b.vx;b.y+=b.vy;if(this.overlap(playerBox,{x:b.x,y:b.y-3,w:3,h:3})){this.hit();b.alive=false;}}
  this.hostile=this.hostile.filter(b=>b.alive&&b.x>0&&b.x<170&&b.y>0&&b.y<192);this.enemies=this.enemies.filter(e=>e.alive);
  if(this.ending&&!this.enemies.length&&!this.hostile.length&&this.mode==='playing'){this.mode='won';this.events.push('clear');}
 }
}
const api={Game,moveTable,STEP,W,H};if(typeof module!=='undefined')module.exports=api;else root.Cetas=api;
})(typeof globalThis!=='undefined'?globalThis:this);
