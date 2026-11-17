/* Shared monochrome renderer: current Atari sprites and actual 256×32 HUD art. */
(function(root){'use strict';
class Renderer{
 constructor(canvas,payload){this.canvas=canvas;this.g=canvas.getContext('2d');this.data=payload;this.cache=new Map();this.assets=new Map([...payload.catalog.ships,...payload.catalog.enemies,...payload.catalog.bosses,...payload.catalog.projectiles,...payload.pickups,{id:'guardian',width:64,height:64,frames:[payload.guardian]}].map(a=>[a.id,a]));this.panel=document.createElement('canvas');this.panel.width=256;this.panel.height=32;this.pg=this.panel.getContext('2d');}
 sprite(id,frame=0){const key=id+':'+frame;if(this.cache.has(key))return this.cache.get(key);const a=this.assets.get(id),c=document.createElement('canvas');c.width=a.width;c.height=a.height;const g=c.getContext('2d');g.fillStyle='#e6e6e6';a.frames[frame%a.frames.length].forEach((v,i)=>{if(v)g.fillRect(i%a.width,Math.floor(i/a.width),1,1);});this.cache.set(key,c);return c;}
 draw(e,{trails=false,hud=true,bossGuide=false}={}){
  const g=this.g,frame=Math.floor(e.tick/3)%4;g.imageSmoothingEnabled=false;g.fillStyle='#000';g.fillRect(0,0,this.canvas.width,this.canvas.height);g.save();g.beginPath();g.rect(0,0,512,256);g.clip();
  for(let i=0;i<56;i++){const z=i<8?2:i<24?1:0,x=((i*137.51-e.tick*[1,3,7][z])%512+512)%512,y=(i*79.43)%256,light=Math.round([50,105,190][z]+Math.sin(e.tick*.07+i)*15);g.fillStyle=`rgb(${light},${light},${light})`;g.beginPath();g.arc(x,y,1.4,0,Math.PI*2);g.fill();}
  if(trails){g.strokeStyle='#444';for(const a of e.enemies){g.beginPath();a.trail.forEach(([x,y],i)=>i?g.lineTo(x*4+16,y*2+16):g.moveTo(x*4+16,y*2+16));g.stroke();}}
  if(bossGuide&&e.attack){const y=e.attack.gapRow*32;g.fillStyle='rgba(90,220,140,.08)';g.fillRect(0,y,352,64);g.strokeStyle='#39875b';g.strokeRect(0,y,352,64);}
  if(e.attack&&['warning','charging'].includes(e.attack.state)){
   const head=e.enemies[0];g.strokeStyle='#fff';g.beginPath();g.arc(head.x*4,(head.y+16)*2,8+e.tick%4,0,Math.PI*2);g.stroke();
   g.fillStyle='#d8dfe8';g.font='10px monospace';g.fillText('FIND THE OPENING',12,16);
  }
  if(bossGuide)for(const b of e.hostile)if(b.boss&&b.trail){g.strokeStyle='#596a80';g.beginPath();b.trail.forEach(([x,y],i)=>i?g.lineTo(x*4+16,y*2+16):g.moveTo(x*4+16,y*2+16));g.stroke();}
  if(bossGuide){const bullets=e.hostile.filter(b=>b.boss);if(bullets.length){const left=Math.min(...bullets.map(b=>b.x))*4,right=Math.max(...bullets.map(b=>b.x))*4+32,top=Math.min(...bullets.map(b=>b.y))*2,bottom=Math.max(...bullets.map(b=>b.y))*2+32;g.strokeStyle='#72859b';g.setLineDash([3,4]);g.strokeRect(left,top,right-left,bottom-top);g.setLineDash([]);}}
  const enemy=e.kind===5?'boss-insect-queen':e.kind===4?(e.project.boss?.design||'boss-bone-dragon'):e.kind?'redesign-14':e.project.slots[e.record[0]];
  if(e.boss&&e.bossVisible){g.drawImage(this.sprite(enemy,e.options.curtainOnly?(e.age>>2)&3:e.ai.frame),Math.round(e.bossX*4),Math.round(e.bossTop*2),128,128);}
  else if(!e.boss)for(const a of e.enemies)if(a.visible&&a.hp>0)g.drawImage(this.sprite(e.kind===7?(a.i<2?'redesign-14':e.project.slots[e.record[0]]):enemy,e.kind===7?(a.i<2?0:frame&1):frame),Math.round(a.x*4),Math.round(a.y*2),32,32);
  if(e.shieldTicks||!e.invulnerable||e.tick%4<2)g.drawImage(this.sprite(e.project.ship,frame),e.player.x*4,e.player.y*2,80,32);
  g.fillStyle='#fff';for(const b of e.shots)g.fillRect(b.x*4,b.y*2,8,2);
  for(const b of e.hostile){if(b.boss){g.drawImage(this.sprite(b.art==='orb'?'boss-orb':b.art==='meteor'?'redesign-14':'original-17',b.art==='orb'||b.art==='meteor'?0:2+((e.bossClock>>2)&1)),Math.round(b.x*4),Math.round(b.y*2),32,32);}else if(b.style){for(let y=0;y<8;y++)for(let x=0;x<8;x++)if(this.data.playerBullet[y]&(128>>x))g.fillRect(Math.round(b.x*4)+x*4,Math.round(b.y*2)+y*2,4,2);}else g.fillRect(Math.round(b.x*4),Math.round(b.y*2),16,8);}
  if(e.shieldTicks){g.strokeStyle='#fff';g.lineWidth=2;g.beginPath();g.ellipse(e.player.x*4+40,e.player.y*2+16,44,20,0,0,Math.PI*2);g.stroke();}
  for(const p of e.pickups){const index=p.type==='Shield'?4:Number(p.type.slice(-1))-1;g.drawImage(this.sprite(this.data.pickups[index].id),p.x*4,p.y*2,32,32);}
  g.restore();if(hud)this.hud(e);
 }
 hud(e){const g=this.pg;g.fillStyle='#000';g.fillRect(0,0,256,32);g.fillStyle='#e6e6e6';this.data.hud.forEach((b,i)=>{for(let bit=0;bit<8;bit++)if(b&(128>>bit))g.fillRect((i%32)*8+bit,Math.floor(i/32),1,1);});
  const digit=(n,x,y)=>{for(let row=0;row<8;row++){const b=this.data.digits[n*8+row];for(let bit=0;bit<8;bit++)if(b&(128>>bit))g.fillRect(x+bit,y+row,1,1);}};
  String(e.score).padStart(8,'0').slice(-8).split('').forEach((n,i)=>digit(Number(n),80+i*8,12));digit(e.sector+1,112,23);digit(Math.max(0,3-e.hits),168,5);digit(e.bombs,200,5);digit(e.shields,232,5);
  for(const y of [[8],[4,11],[2,8,14],[1,5,10,14]][e.weapon-1])for(const x of [2,7,12])g.fillRect(40+x,8+y,1,1);
  for(const y of [12,20])g.fillRect(e.tick&2?8:10,y,e.tick&2?4:2,1);
  if(e.boss&&e.bossHP>0)for(let i=0;i<8;i++){g.strokeStyle='#e6e6e6';g.strokeRect(184+i*8+.5,22.5,5,5);if(i<Math.ceil(e.bossHP/e.bossMaxHP*8))g.fillRect(185+i*8,23,4,4);}
  this.g.drawImage(this.panel,0,256,512,64);
 }
}
root.DiabolicRenderer=Renderer;
})(globalThis);
