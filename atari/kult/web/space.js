/* Browser-only art: seeded parallax space and the Diabolic interceptor. */
(function(root){
'use strict';
const W=512,H=256;
let seed=0x4b554c54;
function random(){seed=(Math.imul(seed,1664525)+1013904223)>>>0;return seed/4294967296;}
function canvas(w,h){const c=document.createElement('canvas');c.width=w;c.height=h;return c;}
const stars=Array.from({length:155},()=>({x:random()*W,y:random()*H,z:.15+random()*.85,phase:random()*6.28}));
let nebula,planet;
function prepare(){
 nebula=canvas(1024,400);const n=nebula.getContext('2d');
 for(let i=0;i<60;i++){const x=random()*1024,y=190+Math.sin(x/165)*90+(random()-.5)*100,r=35+random()*130,g=n.createRadialGradient(x,y,0,x,y,r);g.addColorStop(0,i%3===0?'rgba(65,31,100,.10)':'rgba(23,46,89,.085)');g.addColorStop(1,'rgba(0,0,0,0)');n.fillStyle=g;n.fillRect(x-r,y-r,r*2,r*2);}
 planet=canvas(150,150);const p=planet.getContext('2d');p.save();p.beginPath();p.arc(75,75,58,0,Math.PI*2);p.clip();const g=p.createRadialGradient(110,40,2,56,82,95);g.addColorStop(0,'#4a405f');g.addColorStop(.38,'#23243b');g.addColorStop(.75,'#0d1121');g.addColorStop(1,'#060912');p.fillStyle=g;p.fillRect(0,0,150,150);
 p.globalAlpha=.14;for(let i=0;i<28;i++){p.strokeStyle=i%2?'#a294b0':'#040610';p.lineWidth=1+random()*4;p.beginPath();p.ellipse(70,25+i*4,78,6,-.2,0,Math.PI*2);p.stroke();}p.restore();p.strokeStyle='#7783a040';p.lineWidth=1;p.beginPath();p.arc(75,75,58,-1.5,.4);p.stroke();
}
function background(ctx,game){
 if(!nebula)prepare();const t=game.tick,camX=(game.player.x-216)/216,camY=(game.player.y-112)/112;
 ctx.fillStyle='#030611';ctx.fillRect(0,0,W,H);
 // Distant clouds and planet barely move; nearby stars race past the cockpit.
 const drift=(t*.035)%1024;ctx.globalAlpha=.85;ctx.drawImage(nebula,-drift-camX*2,-75-camY*2);ctx.drawImage(nebula,1024-drift-camX*2,-75-camY*2);ctx.globalAlpha=1;
 ctx.drawImage(planet,365-(t*.013)%850-camX*3,4-camY*3);
 for(const s of stars){const depth=s.z*s.z,px=((s.x-t*(.06+depth*1.1)-camX*depth*9)%W+W)%W,py=((s.y-camY*depth*10)%H+H)%H;
  const bright=.2+depth*.65+.08*Math.sin(t*.015+s.phase);ctx.globalAlpha=bright;ctx.fillStyle=s.z>.8?'#cedaf9':s.z>.5?'#8998c2':'#566083';
  ctx.fillRect(Math.floor(px),Math.floor(py),s.z>.9?2:1,1);
  if(s.z>.92){ctx.globalAlpha=.12;ctx.fillRect(px+2,py,3+depth*5,1);}
 }
 ctx.globalAlpha=1;
 // Broad perspective rays remain very faint behind the actual combat.
 const glow=ctx.createRadialGradient(425,128,4,425,128,230);glow.addColorStop(0,'rgba(55,43,85,.10)');glow.addColorStop(1,'rgba(0,0,0,0)');ctx.fillStyle=glow;ctx.fillRect(0,0,W,H);
}
function ship(frame){
 const c=canvas(80,32),g=c.getContext('2d');g.imageSmoothingEnabled=false;
 function poly(points,fill,stroke){g.beginPath();points.forEach(([x,y],i)=>i?g.lineTo(x,y):g.moveTo(x,y));g.closePath();g.fillStyle=fill;g.fill();if(stroke){g.strokeStyle=stroke;g.lineWidth=1;g.stroke();}}
 // Twin ember engines, animated independently of the original helicopter art.
 const flame=frame%2?2:5;
 poly([[18,10],[flame,12],[11,14],[18,14]],'#e13e54');poly([[18,18],[flame,20],[11,22],[18,22]],'#e13e54');
 g.fillStyle='#ffbf8b';g.fillRect(10+frame%3,11,8,2);g.fillRect(10+frame%3,19,8,2);
 // Swept bat wings and forward-facing, claw-like horns.
 poly([[18,14],[8,3],[29,6],[42,9],[56,6],[72,1],[65,10],[51,15]],'#241b37','#65516f');
 poly([[18,18],[8,29],[29,26],[42,23],[56,26],[72,31],[65,22],[51,17]],'#241b37','#65516f');
 poly([[23,12],[14,6],[36,11],[49,13],[62,9],[68,5],[63,12],[48,17]],'#49304a');
 poly([[23,20],[14,26],[36,21],[49,19],[62,23],[68,27],[63,20],[48,15]],'#36263f');
 poly([[17,12],[34,8],[51,11],[60,13],[76,16],[60,19],[51,21],[34,24],[17,20],[22,16]],'#30283e','#8b6580');
 poly([[27,14],[37,11],[53,14],[65,16],[48,18],[29,18]],'#635166');
 poly([[34,13],[48,13],[56,16],[44,16]],'#f04358');g.fillStyle='#ffb294';g.fillRect(39,13,7,1);
 g.strokeStyle='#e95061';g.beginPath();g.moveTo(28,8);g.lineTo(40,11);g.moveTo(28,24);g.lineTo(40,21);g.moveTo(59,9);g.lineTo(67,5);g.moveTo(59,23);g.lineTo(67,27);g.stroke();
 g.fillStyle='#080c18';g.fillRect(18,11,5,4);g.fillRect(18,18,5,4);g.fillStyle='#ff755b';g.fillRect(18,12,2,2);g.fillRect(18,19,2,2);
 return c;
}
root.KultSpace={background,ship};
})(window);
