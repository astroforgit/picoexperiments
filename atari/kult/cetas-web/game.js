'use strict';
const $=id=>document.getElementById(id),canvas=$('game'),ctx=canvas.getContext('2d');
let game,data,images,best=0,last=0,accumulator=0,lastMode='',audio,muted=true,pointer=null,pendingBomb=false;
const keys=new Set(),touch={fire:false,bomb:false};
try{best=Number(localStorage.getItem('cetas-web-best'))||0;}catch{}
$('best').textContent=String(best).padStart(6,'0');
const palette=['#081425','#426c9c','#8fc9eb','#edf4ff'];
function sprite(pixels,w,h){const c=document.createElement('canvas');c.width=w*4;c.height=h*2;const g=c.getContext('2d');for(let y=0;y<h;y++)for(let x=0;x<w;x++){const p=pixels[y*w+x];if(p){g.fillStyle=palette[p];g.fillRect(x*4,y*2,4,2);}}return c;}
function prepare(){images=Object.fromEntries(Object.entries(data.sprites).map(([id,s])=>[id,sprite(s.pixels,s.width,s.height)]));const title=$('titleArt').getContext('2d');title.imageSmoothingEnabled=false;title.drawImage(sprite(data.title,160,192),0,0,320,192);for(const c of data.chapters)$('stage').add(new Option(c.name,$('stage').options.length));}
function audioReady(){try{if(!audio)audio=new (window.AudioContext||window.webkitAudioContext)();if(audio.state==='suspended')audio.resume().catch(()=>{});}catch{muted=true;}}
function sound(name){if(muted||!audio)return;const now=audio.currentTime,o=audio.createOscillator(),g=audio.createGain();const spec={shot:[480,110,.055,.035],explode:[110,25,.2,.06],pulse:[65,15,.55,.09],pickup:[480,960,.16,.05],start:[220,440,.35,.035],clear:[440,880,.4,.05],hit:[180,90,.04,.025],end:[150,30,.6,.06]}[name];if(!spec)return;o.type=name==='pickup'?'sine':'square';o.frequency.setValueAtTime(spec[0],now);o.frequency.exponentialRampToValueAtTime(spec[1],now+spec[2]);g.gain.setValueAtTime(spec[3],now);g.gain.exponentialRampToValueAtTime(.001,now+spec[2]);o.connect(g);g.connect(audio.destination);o.start(now);o.stop(now+spec[2]);o.onended=()=>{o.disconnect();g.disconnect();};}
function start(){if(!game)return;audioReady();keys.clear();pointer=null;pendingBomb=false;touch.fire=touch.bomb=false;game.start(Number($('stage').value));lastMode='';canvas.focus();}
function setOverlay(){if(game.mode===lastMode)return;lastMode=game.mode;const mode=game.mode;$('overlay').hidden=mode==='playing';$('pause').disabled=!['playing','paused'].includes(mode);$('pause').textContent=mode==='paused'?'▶ Resume':'Ⅱ Pause';$('stateLabel').textContent=mode==='playing'?'FLIGHT IN PROGRESS':mode==='paused'?'FLIGHT PAUSED':'READY WHEN YOU ARE';
 if(mode==='title')return;
 const title=mode==='paused'?'Hold your position.':mode==='won'?'Transmission complete.':'Signal lost.';
 $('overlayTitle').textContent=title;$('overlayKicker').textContent=mode==='won'?'MISSION COMPLETE':mode==='paused'?'SYSTEM ON STANDBY':'MISSION ENDED';$('overlayText').textContent=mode==='paused'?'Take a breath. Your flight is waiting.':`Final score ${String(game.score).padStart(6,'0')} · Phase ${game.chapter+1}`;$('start').textContent=mode==='paused'?'Resume flight →':'Fly again →';$('startHint').textContent=mode==='paused'?'P OR ENTER TO RESUME':'ENTER TO RESTART';
}
function drawObject(e,alpha=1){const id=e.type===1?data.player[Math.floor(game.tick/7)%4]:data.types[e.type]?.[Math.floor(e.x)&3],s=data.sprites[id];if(!s)return;ctx.globalAlpha=alpha;const offset=s.header[0]>127?s.header[0]-256:s.header[0];ctx.drawImage(images[id],Math.round((e.x+offset)*4),Math.round((e.y-s.height)*2));ctx.globalAlpha=1;}
function draw(){ctx.imageSmoothingEnabled=false;ctx.fillStyle=palette[0];ctx.fillRect(0,0,640,384);
 // Decorative starfield is a browser addition; the recovered game clears its background.
 for(let i=0;i<65;i++){ctx.fillStyle=i%3?'#203a55':'#38546a';const x=((i*137-game.tick*(i%3+1)*.35)%640+640)%640;ctx.fillRect(x,(i*73)%384,i%3?1:2,1);}
 for(const e of game.enemies){drawObject(e);if(e.type===12){ctx.fillStyle='#324761';ctx.fillRect(e.x*4,(e.y-game.sprite(e).height)*2-8,90,3);ctx.fillStyle='#88c7ff';ctx.fillRect(e.x*4,(e.y-game.sprite(e).height)*2-8,90*e.hp/e.maxHp,3);}}
 for(const s of game.shots)drawObject(s);for(const s of game.hostile)drawObject(s);
 if(game.mode==='title'||game.invulnerable%12<7)drawObject({...game.player,type:1});
 for(const e of game.effects){if(e.flash){ctx.fillStyle=`rgba(180,220,255,${Math.max(0,.35-e.age/60)})`;ctx.fillRect(0,0,640,384);}else drawObject({type:8,x:e.x,y:e.y},1-e.age/25);}
 $('score').textContent=String(game.score).padStart(6,'0');if(game.score>best){best=game.score;$('best').textContent=String(best).padStart(6,'0');try{localStorage.setItem('cetas-web-best',best);}catch{}}
 $('sector').textContent=`${String(game.chapter+1).padStart(2,'0')} / ${String(game.spawned).padStart(2,'0')}`;$('lives').textContent='● '.repeat(Math.max(0,game.lives))||'—';$('power').textContent=String(game.pulses).padStart(2,'0');
 $('notice').textContent=game.mode==='playing'&&game.banner>0?`PHASE ${String(game.chapter+1).padStart(2,'0')}`:'';setOverlay();
}
function input(){return {up:keys.has('ArrowUp')||keys.has('KeyW'),down:keys.has('ArrowDown')||keys.has('KeyS'),left:keys.has('ArrowLeft')||keys.has('KeyA'),right:keys.has('ArrowRight')||keys.has('KeyD'),fire:keys.has('Space')||touch.fire,pulse:pendingBomb||keys.has('KeyX')||touch.bomb,target:pointer};}
function frame(t){if(!last)last=t;accumulator+=Math.min((t-last)/1000,.1);last=t;while(accumulator>=Cetas.STEP){game.update(input());pendingBomb=false;accumulator-=Cetas.STEP;}for(const event of game.events.splice(0))sound(event);draw();requestAnimationFrame(frame);}
$('start').onclick=()=>{if(game?.mode==='paused'){game.pause();canvas.focus();}else start();};$('restart').onclick=start;
$('pause').onclick=()=>{game?.pause();keys.clear();pointer=null;pendingBomb=false;touch.fire=touch.bomb=false;};
$('sound').onclick=()=>{muted=!muted;if(!muted)audioReady();$('sound').textContent=muted?'Sound off':'Sound on';$('sound').setAttribute('aria-pressed',String(!muted));};
$('full').onclick=async()=>{try{if(document.fullscreenElement)await document.exitFullscreen();else if(document.querySelector('.cabinet').requestFullscreen)await document.querySelector('.cabinet').requestFullscreen();else $('stateLabel').textContent='FULLSCREEN UNAVAILABLE';}catch{$('stateLabel').textContent='FULLSCREEN UNAVAILABLE';}};
document.addEventListener('keydown',e=>{if(/SELECT|INPUT|TEXTAREA/.test(e.target.tagName))return;if(['ArrowUp','ArrowDown','ArrowLeft','ArrowRight','Space','KeyX','KeyP','Escape','Enter'].includes(e.code))e.preventDefault();if(e.repeat)return;if(e.code==='Enter'){if(game?.mode==='paused')game.pause();else if(game?.mode!=='playing')start();}else if(e.code==='KeyP'||e.code==='Escape'){game?.pause();keys.clear();}else{keys.add(e.code);if(e.code==='KeyX'&&game?.mode==='playing')pendingBomb=true;}});
document.addEventListener('keyup',e=>keys.delete(e.code));
function blur(){keys.clear();pointer=null;pendingBomb=false;touch.fire=touch.bomb=false;if(game?.mode==='playing')game.pause();}
window.addEventListener('blur',blur);document.addEventListener('visibilitychange',()=>{if(document.hidden)blur();});
function steer(e){const b=canvas.getBoundingClientRect();pointer={x:(e.clientX-b.left)/b.width*640,y:(e.clientY-b.top)/b.height*384};}
canvas.addEventListener('pointerdown',e=>{if(game?.mode!=='playing')return;e.preventDefault();canvas.setPointerCapture(e.pointerId);steer(e);});canvas.addEventListener('pointermove',e=>{if(canvas.hasPointerCapture(e.pointerId))steer(e);});for(const event of ['pointerup','pointercancel','lostpointercapture'])canvas.addEventListener(event,()=>pointer=null);
for(const [id,key] of [['touchFire','fire'],['touchBomb','bomb']]){const b=$(id);b.onpointerdown=e=>{e.preventDefault();b.setPointerCapture(e.pointerId);touch[key]=true;if(key==='bomb'&&game?.mode==='playing')pendingBomb=true;audioReady();};for(const event of ['pointerup','pointercancel','lostpointercapture'])b.addEventListener(event,()=>touch[key]=false);}
fetch('assets.json').then(r=>{if(!r.ok)throw Error('Asset request failed');return r.json();}).then(d=>{data=d;prepare();game=new Cetas.Game(data);$('start').disabled=false;$('start').textContent='Start flight →';requestAnimationFrame(frame);}).catch(e=>{$('overlayTitle').textContent='Unable to load game';$('overlayText').textContent='Start the local server and reload this page. '+e.message;$('start').textContent='Assets unavailable';});
