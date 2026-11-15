'use strict';
const $=id=>document.getElementById(id),canvas=$('game'),ctx=canvas.getContext('2d');
let game,data,images,best=0,last=0,accumulator=0,lastMode='',audio,muted=true,pointer=null,pendingBomb=false;
const keys=new Set(),touch={fire:false,bomb:false};
try{best=Number(localStorage.getItem('kult-web-best'))||0;}catch{}
$('best').textContent=String(best).padStart(6,'0');
for(let i=0;i<8;i++)$('stage').add(new Option(`SECTOR ${String(i+1).padStart(2,'0')}`,i));
const palette=['#030611','#665d83','#b0b5cf','#e5e6f4'];
function sprite(pixels,w,h){const c=document.createElement('canvas');c.width=w*4;c.height=h*2;const g=c.getContext('2d');for(let y=0;y<h;y++)for(let x=0;x<w;x++){const p=pixels[y*w+x];if(p){g.fillStyle=palette[p];g.fillRect(x*4,y*2,4,2);}}return c;}
function prepare(){const s=data.guardianMap,c=document.createElement('canvas');c.width=c.height=128;const g=c.getContext('2d');for(let i=0;i<16;i++)if(s[i])g.drawImage(sprite(data.guardianTiles[s[i]-1],8,16),(i%4)*32,Math.floor(i/4)*32);
 images={player:Array.from({length:4},(_,frame)=>KultSpace.ship(frame)),enemies:data.enemies.map(set=>set.map(p=>sprite(p,8,16))),guardian:c};}
function audioReady(){try{if(!audio)audio=new (window.AudioContext||window.webkitAudioContext)();if(audio.state==='suspended')audio.resume().catch(()=>{});}catch{muted=true;}}
function sound(name){if(muted||!audio)return;const now=audio.currentTime,o=audio.createOscillator(),g=audio.createGain();const spec={shot:[480,110,.055,.035],explode:[110,25,.2,.06],bomb:[65,15,.55,.09],pickup:[480,960,.16,.05],stage:[220,440,.35,.035],clear:[440,880,.4,.05],hit:[180,90,.04,.025],end:[150,30,.6,.06]}[name];if(!spec)return;o.type=name==='pickup'?'sine':'square';o.frequency.setValueAtTime(spec[0],now);o.frequency.exponentialRampToValueAtTime(spec[1],now+spec[2]);g.gain.setValueAtTime(spec[3],now);g.gain.exponentialRampToValueAtTime(.001,now+spec[2]);o.connect(g);g.connect(audio.destination);o.start(now);o.stop(now+spec[2]);o.onended=()=>{o.disconnect();g.disconnect();};}
function start(){if(!game)return;audioReady();keys.clear();pointer=null;pendingBomb=false;touch.fire=touch.bomb=false;game.start(Number($('stage').value));lastMode='';canvas.focus();}
function setOverlay(){if(game.mode===lastMode)return;lastMode=game.mode;const mode=game.mode;$('overlay').hidden=mode==='playing';$('pause').disabled=!['playing','paused'].includes(mode);$('pause').textContent=mode==='paused'?'▶ Resume':'Ⅱ Pause';$('stateLabel').textContent=mode==='playing'?'FLIGHT IN PROGRESS':mode==='paused'?'FLIGHT PAUSED':'READY WHEN YOU ARE';
 if(mode==='title')return;
 const title=mode==='paused'?'Hold your position.':mode==='won'?'All sectors cleared.':'Signal lost.';
 $('overlayTitle').textContent=title;$('overlayKicker').textContent=mode==='won'?'MISSION COMPLETE':mode==='paused'?'SYSTEM ON STANDBY':'MISSION ENDED';$('overlayText').textContent=mode==='paused'?'Take a breath. Your flight is waiting.':`Final score ${String(game.score).padStart(6,'0')} · Sector ${game.stage+1}`;$('start').textContent=mode==='paused'?'Resume flight →':'Fly again →';$('startHint').textContent=mode==='paused'?'P OR ENTER TO RESUME':'ENTER TO RESTART';
}
function draw(){ctx.imageSmoothingEnabled=false;KultSpace.background(ctx,game);
 const frame=Math.floor(game.tick/6)%4;
 for(const e of game.enemies)if(e.alive)ctx.drawImage(images.enemies[e.design][frame],Math.round(e.x),Math.round(e.y));
 if(game.boss){const b=game.boss;ctx.drawImage(images.guardian,b.x,Math.round(b.y));ctx.fillStyle='#303e33';ctx.fillRect(b.x,b.y-8,128,3);ctx.fillStyle='#e4c47b';ctx.fillRect(b.x,b.y-8,128*b.hp/b.maxHp,3);}
 if(game.mode==='title'||game.invulnerable%12<7)ctx.drawImage(images.player[frame],Math.round(game.player.x),Math.round(game.player.y));
 ctx.fillStyle='#fff5b2';for(const s of game.shots)ctx.fillRect(s.x,s.y-1,12,3);
 ctx.fillStyle='#ed9274';for(const s of game.hostile){ctx.fillRect(s.x-3,s.y-3,6,6);ctx.fillStyle='#fff0bc';ctx.fillRect(s.x-1,s.y-1,2,2);ctx.fillStyle='#ed9274';}
 for(const p of game.pickups){ctx.fillStyle='#dce58d';ctx.fillRect(p.x-10,p.y-10,20,20);ctx.fillStyle='#152016';ctx.font='bold 14px monospace';ctx.textAlign='center';ctx.fillText({weapon:'W',bomb:'P',life:'+'}[p.kind],p.x,p.y+5);}
 for(const e of game.effects){if(e.flash){ctx.fillStyle=`rgba(238,242,180,${Math.max(0,.35-e.age/70)})`;ctx.fillRect(0,0,512,256);}else{const size=e.big?2:1;ctx.globalAlpha=1-e.age/30;const img=images.enemies[32][Math.min(3,Math.floor(e.age/7))];ctx.drawImage(img,e.x,e.y,32*size,32*size);ctx.globalAlpha=1;}}
 $('score').textContent=String(game.score).padStart(6,'0');if(game.score>best){best=game.score;$('best').textContent=String(best).padStart(6,'0');try{localStorage.setItem('kult-web-best',best);}catch{}}
 $('sector').textContent=`${String(game.stage+1).padStart(2,'0')} / ${String(game.wave).padStart(2,'0')}`;$('lives').textContent='● '.repeat(Math.max(0,game.lives))||'—';$('power').textContent=String(game.bombs).padStart(2,'0')+' / '+['','I','II','III'][game.weapon];
 $('notice').textContent=game.mode==='playing'&&game.banner>0?(game.guardianDefeated?'SECTOR CLEAR':game.boss?'GUARDIAN APPROACHING':`SECTOR ${String(game.stage+1).padStart(2,'0')}`):'';setOverlay();
}
function input(){return {up:keys.has('ArrowUp')||keys.has('KeyW'),down:keys.has('ArrowDown')||keys.has('KeyS'),left:keys.has('ArrowLeft')||keys.has('KeyA'),right:keys.has('ArrowRight')||keys.has('KeyD'),fire:keys.has('Space')||touch.fire,bomb:pendingBomb||keys.has('KeyX')||touch.bomb,target:pointer};}
function frame(t){if(!last)last=t;accumulator+=Math.min((t-last)/1000,.1);last=t;while(accumulator>=Kult.STEP){game.update(input());pendingBomb=false;accumulator-=Kult.STEP;}for(const event of game.events.splice(0))sound(event);draw();requestAnimationFrame(frame);}
$('start').onclick=()=>{if(game?.mode==='paused'){game.pause();canvas.focus();}else start();};$('restart').onclick=start;
$('pause').onclick=()=>{game?.pause();keys.clear();pointer=null;pendingBomb=false;touch.fire=touch.bomb=false;};
$('sound').onclick=()=>{muted=!muted;if(!muted)audioReady();$('sound').textContent=muted?'Sound off':'Sound on';$('sound').setAttribute('aria-pressed',String(!muted));};
$('full').onclick=async()=>{try{if(document.fullscreenElement)await document.exitFullscreen();else if(document.querySelector('.cabinet').requestFullscreen)await document.querySelector('.cabinet').requestFullscreen();else $('stateLabel').textContent='FULLSCREEN UNAVAILABLE';}catch{$('stateLabel').textContent='FULLSCREEN UNAVAILABLE';}};
document.addEventListener('keydown',e=>{if(/SELECT|INPUT|TEXTAREA/.test(e.target.tagName))return;if(['ArrowUp','ArrowDown','ArrowLeft','ArrowRight','Space','KeyX','KeyP','Escape','Enter'].includes(e.code))e.preventDefault();if(e.repeat)return;if(e.code==='Enter'){if(game?.mode==='paused')game.pause();else if(game?.mode!=='playing')start();}else if(e.code==='KeyP'||e.code==='Escape'){game?.pause();keys.clear();}else{keys.add(e.code);if(e.code==='KeyX'&&game?.mode==='playing')pendingBomb=true;}});
document.addEventListener('keyup',e=>keys.delete(e.code));
function blur(){keys.clear();pointer=null;pendingBomb=false;touch.fire=touch.bomb=false;if(game?.mode==='playing')game.pause();}
window.addEventListener('blur',blur);document.addEventListener('visibilitychange',()=>{if(document.hidden)blur();});
function steer(e){const b=canvas.getBoundingClientRect();pointer={x:(e.clientX-b.left)/b.width*512,y:(e.clientY-b.top)/b.height*256};}
canvas.addEventListener('pointerdown',e=>{if(game?.mode!=='playing')return;e.preventDefault();canvas.setPointerCapture(e.pointerId);steer(e);});canvas.addEventListener('pointermove',e=>{if(canvas.hasPointerCapture(e.pointerId))steer(e);});for(const event of ['pointerup','pointercancel','lostpointercapture'])canvas.addEventListener(event,()=>pointer=null);
for(const [id,key] of [['touchFire','fire'],['touchBomb','bomb']]){const b=$(id);b.onpointerdown=e=>{e.preventDefault();b.setPointerCapture(e.pointerId);touch[key]=true;if(key==='bomb'&&game?.mode==='playing')pendingBomb=true;audioReady();};for(const event of ['pointerup','pointercancel','lostpointercapture'])b.addEventListener(event,()=>touch[key]=false);}
fetch('assets.json').then(r=>{if(!r.ok)throw Error('Asset request failed');return r.json();}).then(d=>{data=d;prepare();game=new Kult.Game(data);$('start').disabled=false;$('start').textContent='Start flight →';requestAnimationFrame(frame);}).catch(e=>{$('overlayTitle').textContent='Unable to load game';$('overlayText').textContent='Start the local server and reload this page. '+e.message;$('start').textContent='Assets unavailable';});
