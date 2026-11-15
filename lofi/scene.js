'use strict';
(() => {
  const canvas = document.querySelector('#landscape');
  const ctx = canvas.getContext('2d', { alpha: false });
  ctx.imageSmoothingEnabled = false;
  const TAU = Math.PI * 2;
  const LOOP = 24;
  const C = { sky: '#55516f', rose: '#a37c91', peach: '#d2a3a0', far: '#6b6483', mountain: '#4b4b6b', ridge: '#373e5b', tree: '#252e42', dark: '#182633', water: '#52546c', gold: '#f5ca89' };
  let seed = 357;
  function random() { seed = (Math.imul(seed, 1664525) + 1013904223) >>> 0; return seed / 4294967296; }
  const stars = Array.from({length: 38}, () => [random()*320, random()*52, random()*TAU]);
  const ripples = Array.from({length: 165}, () => [random()*320, 104+random()*66, 2+random()*11, random()*TAU]);
  const grass = Array.from({length: 145}, () => [random()*320, 156+random()*24, 2+random()*6, random()*TAU]);
  const flecks = Array.from({length: 100}, () => [random()*104, random()*30]);
  const rect = (x,y,w,h,color) => { ctx.fillStyle=color; ctx.fillRect(Math.floor(x),Math.floor(y),Math.ceil(w),Math.ceil(h)); };
  function poly(points,color) { ctx.fillStyle=color;ctx.beginPath();points.forEach(([x,y],i)=>i?ctx.lineTo(Math.round(x),Math.round(y)):ctx.moveTo(Math.round(x),Math.round(y)));ctx.closePath();ctx.fill(); }
  function pine(x,y,s,color) {
    rect(x-s*.06,y-s*.76,s*.12,s*.8,color);
    for(let i=0;i<4;i++) { const yy=y-s+i*s*.19;const w=s*(.15+i*.065);poly([[x,yy],[x-w,yy+s*.38],[x+w,yy+s*.38]],color); }
  }
  function cloud(x,y,w,phase) {
    const dx=3*Math.sin(phase);
    rect(x+dx,y,w,2,'#c49aa5');rect(x+5+dx,y-2,w*.62,2,'#bb92a1');rect(x-8+dx,y+2,w+15,1,'#a78499');
  }
  function draw(seconds) {
    const p=((seconds%LOOP)+LOOP)%LOOP/LOOP*TAU;
    // All motion uses integer harmonics of the same phase: an exact 24-second loop.
    rect(0,0,320,180,C.sky);
    for(let y=28;y<103;y++) {
      const t=(y-28)/75;
      const a=[85,81,111],b=[211,158,153];
      rect(0,y,320,1,`rgb(${a.map((v,i)=>Math.round(v+(b[i]-v)*t)).join(',')})`);
    }
    stars.forEach(([x,y,o])=>{ctx.globalAlpha=.25+.45*(.5+.5*Math.sin(p+o));rect(x,y,1,1,'#f4d8c5');});ctx.globalAlpha=1;
    // A tiny crescent, cut out against the upper sky.
    poly([[255,17],[259,17],[262,20],[262,25],[259,28],[254,28],[251,25],[251,21]],'#f0d7bd');
    poly([[254,16],[259,16],[262,20],[262,24],[258,24],[254,21]],C.sky);
    cloud(20,35,42,p);cloud(179,48,51,p+1);cloud(85,22,24,p+2);
    poly([[0,87],[25,67],[39,74],[69,40],[90,62],[107,57],[145,92],[174,76],[202,43],[220,63],[236,55],[275,87],[300,67],[320,83],[320,110],[0,110]],C.far);
    poly([[37,76],[69,40],[66,58],[75,57],[87,72],[69,62],[61,69],[57,66]],'#8c7e96');
    poly([[174,76],[202,43],[197,60],[203,58],[212,69],[202,64],[193,68]],'#97869b');
    poly([[0,96],[30,79],[57,94],[96,72],[112,77],[147,98],[184,81],[210,93],[253,69],[282,87],[305,80],[320,90],[320,116],[0,116]],C.mountain);
    poly([[0,103],[26,96],[53,106],[92,94],[125,106],[176,100],[212,109],[260,94],[296,101],[320,95],[320,117],[0,117]],C.ridge);
    for(let i=0;i<65;i++) pine(i*5+2,111+Math.sin(i)*2,6+(i*7%9),C.ridge);
    rect(0,111,320,69,C.water);
    for(let y=112;y<180;y++) {ctx.globalAlpha=(y-111)/69*.55;rect(0,y,320,1,'#28394c');}ctx.globalAlpha=1;
    rect(116,112,125,1,'#a88796');rect(149,114,56,1,'#8f788e');
    // Broken ribbons of reflected dusk.
    ripples.forEach(([x,y,w,o])=>{
      const shift=Math.sin(p*2+o)*3;
      ctx.globalAlpha=.17+.16*(.5+.5*Math.sin(p+o));
      rect(x+shift,y,w,1,y<129?'#d6a2a2':'#9d95b0');
    });ctx.globalAlpha=1;
    // Far wooded headland and its dark reflection.
    poly([[246,109],[273,104],[303,104],[320,99],[320,123],[282,119],[253,116]],'#273849');
    for(let i=0;i<13;i++)pine(258+i*6,111,12+(i*13%18),'#303c50');
    ctx.globalAlpha=.25;poly([[250,118],[320,120],[320,140],[289,131],[279,135],[270,126]],'#182b3c');ctx.globalAlpha=1;
    // Bank, low stone foundation and the cabin.
    poly([[0,116],[25,112],[54,118],[86,124],[110,132],[119,140],[103,148],[67,151],[28,145],[0,149]],'#283a3e');
    poly([[0,125],[33,122],[61,128],[88,132],[103,139],[87,143],[48,139],[0,141]],'#49514a');
    rect(29,113,63,17,'#26313a');rect(31,111,60,16,'#53605c');
    for(let i=0;i<12;i++)rect(33+i*5,119+(i%2)*4,3,1,'#798071');
    poly([[27,88],[58,70],[91,88],[91,116],[27,116]],'#72564e');
    rect(34,90,52,25,'#805e51');
    for(let y=92;y<116;y+=4){rect(28,y,62,1,'#5d4947');rect(35,y+1,49,1,'#916954');}
    poly([[19,90],[56,65],[64,65],[99,89],[94,93],[59,73],[24,94]],'#29313f');
    poly([[25,88],[57,68],[61,68],[93,89],[87,87],[59,73],[30,91]],'#48505b');
    for(let i=0;i<5;i++)rect(35+i*5,84-i*3,17,1,'#60606a');
    rect(76,67,7,16,'#4a464e');rect(75,65,9,3,'#6a6062');rect(78,68,2,11,'#7d6c6b');
    // Smoke rises and fades; each puff is invisible at the wrap boundary.
    for(let i=0;i<6;i++) {
      const u=((p/TAU+i/6)%1);ctx.globalAlpha=Math.sin(u*Math.PI)*.23;
      const x=78+Math.sin(u*5+i)*3+u*9,y=63-u*25;
      rect(x,y,3+u*6,3,'#d5c3c2');rect(x+2,y-2,2+u*4,2,'#d5c3c2');
    }ctx.globalAlpha=1;
    rect(38,94,16,16,'#342f36');rect(40,95,12,13,C.gold);rect(40,95,12,2,'#ffe2a3');rect(45,95,2,13,'#755047');rect(40,101,12,2,'#755047');rect(37,109,18,2,'#b18b69');
    rect(64,93,14,23,'#413638');rect(66,95,10,20,'#a07855');rect(67,96,8,9,'#edb976');rect(70,96,1,9,'#9a704d');rect(73,109,1,1,'#f5d69a');
    rect(27,115,66,3,'#a08362');rect(58,118,24,3,'#6c6657');rect(56,121,28,2,'#8d8064');
    ctx.globalAlpha=.1;poly([[39,111],[53,111],[72,138],[35,135]],'#f8c47f');ctx.globalAlpha=1;
    // Warm reflections are staggered, gently oscillating stripes.
    for(let i=0;i<17;i++) {
      const y=131+i*2, x=46+Math.sin(p*2+i*.9)*3;
      ctx.globalAlpha=(1-i/19)*.45;
      rect(x-i*.45,y,9+i*.65,1,i%3?'#dfac78':'#f7d597');
    }ctx.globalAlpha=1;
    // Wooden dock with perspective, posts and a little lantern.
    poly([[80,133],[94,130],[153,143],[139,148]],'#493e3e');
    poly([[80,131],[94,128],[153,140],[139,145]],'#8c7763');
    for(let i=0;i<12;i++){let x=84+i*5;rect(x,132+(x-84)*.2,1,4,'#50484a');}
    rect(91,134,3,12,'#3c383d');rect(141,143,3,12,'#34343d');rect(142,143,1,10,'#806855');
    rect(88,121,2,11,'#3d3740');rect(86,120,6,1,'#342f38');rect(87,121,4,5,'#f4c782');rect(88,121,2,4,'#ffdf9a');rect(86,126,6,1,'#3e3540');
    // Seated figure, scarf, dangling legs, and a mug.
    rect(129,128,7,7,'#292d3e');rect(132,124,5,5,'#c5957a');rect(131,122,6,3,'#34303c');rect(131,124,2,3,'#34303c');
    poly([[130,129],[135,129],[138,136],[133,139],[127,136]],'#a8786d');rect(130,129,6,2,'#d6a07f');rect(128,135,9,3,'#464351');
    rect(133,137,3,7,'#292e3e');rect(138,137,3,6,'#313548');rect(133,144,4,2,'#1a2836');rect(138,143,4,2,'#1a2836');rect(136,133,3,2,'#c5957a');rect(141,134,2,3,'#ddd0b5');
    // Foreground silhouettes frame the open lake.
    poly([[0,149],[23,144],[53,151],[82,150],[116,159],[164,163],[208,158],[242,153],[277,155],[320,144],[320,180],[0,180]],'#202f36');
    poly([[0,166],[42,158],[74,164],[111,164],[146,171],[208,165],[256,162],[289,157],[320,157],[320,180],[0,180]],'#182932');
    flecks.forEach(([x,y])=>rect(x,147+y,1,1,'#2d3c3e'));
    grass.forEach(([x,y,h,o])=>{const s=Math.round(Math.sin(p+o));poly([[x,y],[x-2+s,y-h],[x+1,y-2],[x+3+s,y-h*.6],[x+2,y+2]],'#263c3e');});
    pine(7,155,89,'#1c2c38');pine(22,148,59,'#233440');pine(310,158,88,'#1d2d39');pine(293,155,51,'#263743');
    // Fireflies follow closed paths and never jump at the loop seam.
    for(let i=0;i<10;i++) {
      const x=36+i*26+Math.sin(p+i*2)*4,y=149+Math.cos(p*2+i)*5;
      const glow=Math.pow(.5+.5*Math.sin(p*2+i*1.7),4);
      ctx.globalAlpha=glow*.12;rect(x-1,y-1,3,3,'#f8d994');ctx.globalAlpha=glow*.85;rect(x,y,1,1,'#f8d994');
    }ctx.globalAlpha=1;
  }
  const pause = document.querySelector('#pause');
  const reduced = window.matchMedia('(prefers-reduced-motion: reduce)');
  let paused=reduced.matches, elapsed=0, last=null;
  function sync() {pause.textContent=paused?'Play':'Pause';pause.setAttribute('aria-pressed',String(paused));}
  function toggle() {paused=!paused;sync();}
  pause.addEventListener('click',toggle);
  document.addEventListener('keydown',event=>{if(event.code==='Space'&&event.target===document.body){event.preventDefault();toggle();}});
  document.querySelector('#fullscreen').addEventListener('click',async()=>{
    try { if(document.fullscreenElement)await document.exitFullscreen();else await document.querySelector('.scene').requestFullscreen(); }
    catch {document.querySelector('#status').textContent='Fullscreen is unavailable in this browser.';}
  });
  document.addEventListener('visibilitychange',()=>{last=null;});
  reduced.addEventListener('change',event=>{paused=event.matches;sync();});
  function frame(now) {if(last!==null&&!paused&&!document.hidden)elapsed+=(now-last)/1000;last=now;draw(elapsed);requestAnimationFrame(frame);}
  // A deterministic rendering hook for screenshots and checking the loop seam.
  window.stillwater={draw,loopSeconds:LOOP};
  sync();requestAnimationFrame(frame);
})();
