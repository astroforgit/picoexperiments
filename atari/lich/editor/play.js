'use strict';
const play = { game:null, seed:1, depth:1, level:1, inventory:false, cursor:0, menu:false, action:0, started:0, moveAt:0, camera:null, sound:false, audio:null, canvas:null, ui:null, lastInput:0, paused:false };
const PLAY_DARK=[0,0,1,5,1,1,13,6,4,4,9,3,13,5,1,1];
const playClean=s=>String(s).replace(/\^([a-z])/g,(_,c)=>c.toUpperCase()).replace(/\^\*/g,'★');
function playFont(ctx,text,x,y,color=7,shadow=null) {
  const x0=x;
  for(let i=0;i<String(text).length;i++) {
    const ch=String(text)[i];if(ch==='\n'){y+=7;x=x0;continue;}
    const key=ch==='^'?ch+String(text)[++i]:ch+' ',g=PLAY_FONT[key]||PLAY_FONT['? '];if(!g)continue;
    if(shadow!==null){ctx.fillStyle=PAL_CSS[shadow];g.pixels.forEach((v,k)=>{if(v)ctx.fillRect(x+k%3,y+Math.floor(k/3)+1,1,1);});}
    ctx.fillStyle=PAL_CSS[color];g.pixels.forEach((v,k)=>{if(v)ctx.fillRect(x+k%3,y+Math.floor(k/3),1,1);});x+=g.width;
  }
}
function playTextWidth(text) {let n=0;for(let i=0;i<text.length;i++){const key=text[i]==='^'?text[i]+text[++i]:text[i]+' ';n+=(PLAY_FONT[key]||PLAY_FONT['? ']).width;}return n;}
function playWindow(ctx,lines,x=8,y=24,w=112,cursor=-1) {
  const height=lines.length*7+6;ctx.fillStyle=PAL_CSS[1];ctx.fillRect(x,y,w,height);
  ctx.strokeStyle=PAL_CSS[9];ctx.strokeRect(x+.5,y+.5,w-1,height-2);ctx.fillStyle=PAL_CSS[2];ctx.fillRect(x,y+height-1,w,1);
  ctx.save();ctx.beginPath();ctx.rect(x+2,y+2,w-4,height-4);ctx.clip();
  lines.forEach((line,i)=>{const px=x+(cursor>=0?10:4);if(cursor===i)playFont(ctx,'>',x+3,y+3+i*7,10);playFont(ctx,line,px,y+3+i*7,cursor===i?10:7,2);});ctx.restore();
}
function playSprites(g) {
  const cache=new Map();return (n,pal)=>{
    const key=n+':'+(pal?pal.join(','):'');if(cache.has(key))return cache.get(key);
    const c=document.createElement('canvas');c.width=c.height=8;const ctx=c.getContext('2d'),img=ctx.createImageData(8,8);
    const page=n>=256?g.sheet2:g.sheet,base=n&255,sx=(base%16)*8,sy=(base>>4)*8;
    for(let y=0;y<8;y++)for(let x=0;x<8;x++) {const v=parseInt(page[sy+y]?.[sx+x]||'0',16);if(!v)continue;const col=PAL[pal?pal[v]:v],k=(y*8+x)*4;img.data.set([...col,255],k);}
    ctx.putImageData(img,0,0);cache.set(key,c);return c;
  };
}
function playSound(id) {
  if(!play.sound)return;
  try {
    play.audio ||= new (window.AudioContext||window.webkitAudioContext)();const audio=play.audio;audio.resume();
    const effect=PLAY_SFX[id];if(!effect)return;
    const step=Math.max(1,effect.speed)/128,now=audio.currentTime;
    // Cartridge pitches and timing; browser oscillators approximate POKEY timbres.
    effect.notes.forEach(([pitch,wave,volume,fx],i)=>{
      if(!volume||i*step>2)return;
      const osc=audio.createOscillator(),gain=audio.createGain(),start=now+i*step,duration=step*.9;
      osc.type=['triangle','sawtooth','sawtooth','square','square','sine','triangle','sawtooth'][wave];
      const hz=65.406*Math.pow(2,pitch/12);osc.frequency.setValueAtTime(hz,start);
      if(fx===2)osc.frequency.exponentialRampToValueAtTime(hz*1.05,start+duration);
      if(fx===3)osc.frequency.exponentialRampToValueAtTime(Math.max(20,hz*.2),start+duration);
      gain.gain.setValueAtTime(volume/7*.025,start);gain.gain.exponentialRampToValueAtTime(.0001,start+duration);
      osc.connect(gain).connect(audio.destination);osc.start(start);osc.stop(start+duration+.01);
    });
  } catch { play.sound=false; }
}
function playStart() {
  try {
    const game=new LichPlay.Game(G,{seed:play.seed,depth:play.depth});
    if(play.level>1){const h=game.hero;h.level=play.level;h.xp=game.g.xp_req[h.level]||0;h.atk+=(h.level-1)*game.p.lvl_atk;h.maxHp+=(h.level-1)*game.p.lvl_hp;h.hp=h.maxHp;}
    if(play.depth===1&&play.level===1)game.modal=game.g.windows.ml_intro;
    play.game=game;play.sprites=playSprites(game.g);play.inventory=play.menu=false;play.paused=false;play.camera={x:game.hero.x,y:game.hero.y};play.started=performance.now();play.moveAt=0;
    playSound(53);render();play.canvas?.focus();status('Play mode uses a snapshot of your edits. Apply edits & restart to reload them.');
  } catch(e){status(`Cannot start: ${e.message}`,true);}
}
function playAfterAction(oldTurn) {
  const g=play.game;if(!g)return;
  if(g.turn!==oldTurn){play.moveAt=performance.now();play.lastInput=play.moveAt;}
  if(g.state==='dead')playSound(51);else if(g.state==='won')playSound(6);
  else if(g.events.some(e=>e.type==='hit'))playSound(59);else if(g.turn!==oldTurn)playSound(62+g.turn%2);
  playRefresh();
}
function playCommand(cmd) {
  const g=play.game;
  if(!g){if(cmd==='select'||cmd==='inventory')playStart();return;}
  if(play.paused){if(cmd==='pause')play.paused=false;playRefresh();return;}
  if(cmd==='pause'){play.paused=true;playRefresh();return;}
  if(g.modal){if(['select','close','inventory'].includes(cmd)){g.modal=null;playRefresh();}return;}
  if(g.state!=='playing'){if(cmd==='select')playStart();return;}
  if(play.inventory){
    if(cmd==='close'||cmd==='left'){if(play.menu)play.menu=false;else play.inventory=false;}
    else if(cmd==='up') {if(play.menu)play.action=Math.max(0,play.action-1);else play.cursor=Math.max(0,play.cursor-1);}
    else if(cmd==='down') {if(play.menu)play.action=Math.min(1,play.action+1);else play.cursor=Math.min(7,play.cursor+1);}
    else if(cmd==='select'||cmd==='inventory') {
      const it=g.inventory[play.cursor];
      if(it&&!play.menu){play.menu=true;play.action=0;}
      else if(it){const before=g.turn;const action=play.action===1?'discard':it.type===1?(g.hero.weapon===it?'unequip':'equip'):'use';g.itemAction(play.cursor,action);play.menu=false;if(g.turn!==before)play.inventory=false;playAfterAction(before);}
    }
    playRefresh();return;
  }
  if(cmd==='inventory'||cmd==='select'){play.inventory=true;play.menu=false;play.cursor=0;playSound(36);playRefresh();return;}
  const direction=['left','right','up','down','wait'].indexOf(cmd);if(direction>=0){const before=g.turn;try{g.act(direction);}catch(e){play.paused=true;status(`Play paused: ${e.message}`,true);}playAfterAction(before);}
}
function playDraw(now) {
  const c=play.canvas;if(!c?.isConnected)return;const ctx=c.getContext('2d');ctx.imageSmoothingEnabled=false;ctx.fillStyle='#000';ctx.fillRect(0,0,128,128);
  const g=play.game;
  if(!g){
    const spr=play.titleSprites;
    for(let y=0;y<16;y++)for(let x=0;x<16;x++)ctx.drawImage(spr(PLAY_TITLE[y][x]),x*8,y*8);
    for(let y=0;y<2;y++)for(let x=0;x<5;x++)ctx.drawImage(spr(139+x+y*16),44+x*8,27+y*8);
    ctx.save();ctx.beginPath();ctx.rect(0,50,128,33);ctx.clip();playFont(ctx,G.windows.ml_story.join('\n'),16,86-Math.floor(now/230)%150,6,2);ctx.restore();
    playFont(ctx,G.texts.s_embark,46,104,12,5);playFont(ctx,G.texts.s_credit1,26,115,5,1);playFont(ctx,G.texts.s_credit2,26,122,5,1);return;
  }
  const h=g.hero,progress=Math.min(1,Math.max(0,(now-play.moveAt)/240)),spr=play.sprites;
  const camera=play.camera;
  if(h.x<camera.x-2)camera.x=h.x+2;else if(h.x>camera.x+2)camera.x=h.x-2;
  if(h.y<camera.y-2)camera.y=h.y+2;else if(h.y>camera.y+2)camera.y=h.y-2;
  const ox=(camera.x-8)*8+4,oy=(camera.y-8)*8+4;
  for(let y=Math.max(0,Math.floor(oy/8));y<Math.min(32,Math.ceil((oy+128)/8));y++)for(let x=Math.max(0,Math.floor(ox/8));x<Math.min(128,Math.ceil((ox+128)/8));x++) {
    const i=y*128+x;if(g.fog[i]!==2&&g.map[i])ctx.drawImage(spr(g.map[i],g.fog[i]===1?PLAY_DARK:LIT),x*8-ox,y*8-oy);
  }
  for(const e of g.entities) {
    if(g.fog[e.y*128+e.x]===2)continue;
    if(e!==h&&g.has(e,'invisible')&&((e.x-h.x)**2+(e.y-h.y)**2)>1)continue;
    const px=Math.round((e.oldX+(e.x-e.oldX)*progress)*8-ox),py=Math.round((e.oldY+(e.y-e.oldY)*progress)*8-oy);
    if(px < -8||px>128||py < -8||py>128)continue;
    const frame=e.prop?0:Math.min(3,Math.floor((now-play.moveAt)/(e===h?100:166)));
    let n=e.anim+frame;if(g.state==='won'&&g.has(e,'boss'))n=g.p.boss_dead_sprite;if(e===h&&g.state==='dead')n=g.p.death_sprite+Math.min(3,Math.floor((now-play.moveAt)/250));
    const pal=g.fog[e.y*128+e.x]===1?PLAY_DARK:null;
    ctx.save();ctx.translate(px+(e.dir===-1?8:0),py);if(e.dir===-1)ctx.scale(-1,1);ctx.drawImage(spr(n,pal),0,0);
    if(e.weapon&&e.hp>0)ctx.drawImage(spr(e.weapon.spr+frame),1,0);ctx.restore();
    if(e.paralysis)playFont(ctx,'...',px+1,py-6,10);else if(e.confusion)playFont(ctx,'?',px+4,py-6,10);
  }
  if(now-play.moveAt<700)for(const e of g.events) {
    if(e.x===undefined||g.fog[e.y*128+e.x]!==0)continue;
    if(e.type==='hit')playFont(ctx,(e.amount>0?'+':'')+e.amount,e.x*8-ox,e.y*8-oy-4-Math.floor((now-play.moveAt)/100),e.amount>0?11:8,1);
    if(e.type==='notice')playFont(ctx,'!',e.x*8-ox,e.y*8-oy-5,10,1);
    if(e.type==='bolt'&&now-play.moveAt<250){ctx.strokeStyle=PAL_CSS[10];ctx.beginPath();ctx.moveTo(e.x*8-ox+4,e.y*8-oy+4);ctx.lineTo(e.tx*8-ox+4,e.ty*8-oy+4);ctx.stroke();}
  }
  ctx.drawImage(spr(174),1,0);ctx.drawImage(spr(175),9,0);ctx.drawImage(spr(190),1,8);ctx.drawImage(spr(191),9,8);
  playFont(ctx,'[*]',17,6,12,5);playFont(ctx,'^f'+g.depth,110,2,7,1);
  playWindow(ctx,[' '],0,115,128);ctx.drawImage(spr(149),7,118);playFont(ctx,`${h.hp}/${h.maxHp}`,17,118);
  ctx.drawImage(spr(165),44,118);ctx.drawImage(spr(166),52,118);playFont(ctx,''+g.damage(h),58,118);
  ctx.drawImage(spr(181),74,118);ctx.drawImage(spr(182),82,118);playFont(ctx,`${h.level} (${h.xp}/${g.g.xp_req[h.level+1]??'—'})`,86,118);
  if(play.inventory){
    playWindow(ctx,[g.text('s_backpack')],16,2,96);
    const lines=g.inventory.map(it=>it?(it===h.weapon?'$ ':'')+g.itemName(it):g.text('s_empty','###'));
    playWindow(ctx,lines,16,12,96,play.cursor);
    if(play.menu){const it=g.inventory[play.cursor];const command=it?.type===1?(h.weapon===it?'s_unequip':'s_equip'):'s_use';playWindow(ctx,[g.text(command),g.text('s_discard')],35,25+play.cursor*6,70,play.action);}
  }
  if(g.modal)playWindow(ctx,g.modal,5,12,118);
  if(play.paused)playWindow(ctx,['^paused','','^press ^p to resume'],18,46,92);
  if(g.state==='dead')playWindow(ctx,['^you died','',...wrapPlayText(`Killed by ${g.killer}`,25),`on floor ${g.depth}.`,'','^x / ^enter: retry'],14,30,100);
  if(g.state==='won')playWindow(ctx,[...g.g.windows.ml_win,'','^x / ^enter: new run'],4,15,120);
}
function wrapPlayText(s,n) {const lines=[];let line='';for(const word of s.split(' ')){if((line+' '+word).length>n){lines.push(line);line=word;}else line+=(line?' ':'')+word;}if(line)lines.push(line);return lines;}
function playRefresh() {
  if(!play.ui?.isConnected)return;
  const {summary,bag,log,message}=play.panels,g=play.game;
  if(!g){summary.textContent='A JavaScript port using the current game data.';bag.replaceChildren();log.replaceChildren();message.textContent='Press Enter or click Embark.';return;}
  const h=g.hero;summary.replaceChildren(...[['Floor',g.depth],['HP',`${h.hp} / ${h.maxHp}`],['Attack',g.damage(h)],['Level',h.level],['XP',`${h.xp} / ${g.g.xp_req[h.level+1]??'max'}`],['Turns',g.turn]].map(([k,v])=>hElementStat(k,v)));
  message.textContent=play.paused?'Paused.':g.modal?'Read the message on the game screen; press Enter to close.':play.inventory?'Backpack: ↑↓ select, Enter use/equip, C close.':g.state==='dead'?'You died. Press Enter to retry this seed.':g.state==='won'?'Victory! Press Enter for a new run.':'Arrow keys / WASD move and interact. X opens backpack.';
  bag.replaceChildren(...g.inventory.map((it,i)=>{
    const row=hElementRow(it,i,g);return row;
  }));
  log.replaceChildren(...g.messages.slice(-14).map(e=>hElementLog(e)));log.scrollTop=log.scrollHeight;
}
function hElementStat(k,v){return h('div',{},h('span',{class:'note'},k),h('strong',{},v));}
function hElementLog(e){return h('div',{},h('span',{class:'note'},`${e.turn} · `),playClean(e.message));}
function hElementRow(it,i,g){
  const row=h('div',{class:'play-item'},h('span',{class:'note'},i+1));
  if(!it){row.append(h('span',{class:'note'},'Empty'));return row;}
  row.append(h('span',{},(it===g.hero.weapon?'⚔ ':'')+playClean(g.itemName(it))));
  const command=it.type===1?(it===g.hero.weapon?'unequip':'equip'):'use';
  for(const action of [command,'discard'])row.append(h('button',{class:'small',disabled:g.state!=='playing'||!!g.modal||play.paused,onclick:()=>{const before=g.turn;g.itemAction(i,action);playAfterAction(before);play.canvas?.focus();}},action));return row;
}
VIEWS.play=()=>{
  const box=h('div',{class:'play-page'});play.ui=box;
  box.append(h('div',{class:'play-heading'},h('div',{},h('h2',{},'Play Curse of the Lich King'),h('p',{class:'note'},'Test the current game data. Use Live artwork to change walls and objects instantly. Other edits take effect when you restart.'))));
  const controls=h('div',{class:'actions lab-controls'},
    labField('Seed',numInput(play,'seed',{min:0,max:4294967295})),
    labField('Starting floor (test)',numInput(play,'depth',{min:1,max:G.params.last_floor})),
    labField('Hero level (test)',numInput(play,'level',{min:1,max:50})),
    h('button',{class:'primary',onclick:playStart},play.game?'Apply edits & restart':'Embark'),
    h('button',{onclick:()=>{play.seed=(play.seed+1)>>>0;playStart();}},'New seed & restart'),
    h('button',{onclick:()=>{playCommand('pause');play.canvas?.focus();}},'Pause / resume'),
    h('label',{class:'chk'},h('input',{type:'checkbox',checked:play.sound,onchange:e=>{play.sound=e.target.checked;if(play.sound)playSound(34);}}),'Sound'),
    h('button',{onclick:()=>play.canvas?.requestFullscreen?.()},'Fullscreen'));
  box.append(controls);
  const canvas=h('canvas',{width:128,height:128,class:'px play-screen',tabindex:0,'aria-label':'Playable game. Arrow keys or WASD move, X backpack, C close, P pause.'});play.canvas=canvas;
  if(!play.game)play.titleSprites=playSprites(G);
  canvas.addEventListener('keydown',e=>{
    const keys={ArrowLeft:'left',a:'left',ArrowRight:'right',d:'right',ArrowUp:'up',w:'up',ArrowDown:'down',s:'down',x:'select',v:'select',m:'select',Enter:'select',' ':'select',c:'close',z:'close',Escape:'close',n:'close',p:'pause','.':'wait'};
    const cmd=keys[e.key]||keys[e.key.toLowerCase()];if(!cmd||e.ctrlKey||e.metaKey||e.altKey)return;
    e.preventDefault();if(e.repeat&&(!['left','right','up','down','wait'].includes(cmd)||performance.now()-play.lastInput<135))return;
    playCommand(cmd);
  });
  canvas.addEventListener('pointerdown',()=>canvas.focus());
  const message=h('p',{class:'note',role:'status'}),summary=h('div',{class:'play-stats'}),bag=h('div'),log=h('div',{class:'play-log',tabindex:0,'aria-label':'Game event log'});
  play.panels={summary,bag,log,message};
  const pad=h('div',{class:'play-pad'});
  for(const [label,cmd] of [['↑','up'],['←','left'],['↓','down'],['→','right'],['X · backpack / select','select'],['C · close','close'],['Wait · .','wait']])pad.append(h('button',{onclick:()=>{playCommand(cmd);play.canvas?.focus();}},label));
  const view=h('div',{class:'play-display'},canvas,message,pad,h('p',{class:'note'},'Move into enemies to attack and into props to interact. Collect supplies, equip weapons, descend eight floors and defeat Raq’zul. Waiting with “.” is an editor convenience.'));
  const side=h('aside',{class:'play-sidebar panel'},summary,h('h3',{},'Backpack'),bag,h('h3',{},'Recent events'),log);
  box.append(h('div',{class:'play-layout'},view,playArtPanel(),side));
  box.append(h('details',{class:'panel play-details'},h('summary',{},'Port fidelity and testing'),
    h('p',{class:'note'},'Gameplay follows the VBXE assembly and original cartridge: room drift and doors, furniture, floor budgets, fog, enemy awareness and pursuit, all 19 abilities, fixed damage, status timing, XP, cursed and enchanted items, altar, anvil, well, traps, floor transitions and victory. Custom maps, sprites, stats, texts and rules use the editor data snapshot.'),
    h('p',{class:'note'},'Differences: seeded browser RNG replaces POKEY entropy, so layouts and random outcomes are not byte-identical. Browser animation, camera, sound timbres and modal timing approximate VBXE. Sound uses the cartridge notes with browser oscillators; music is omitted as in the Atari port. Gates/levers retain the source’s blocking behavior.'),
    h('button',{disabled:!play.game,onclick:()=>{
      const f=clone(play.game.rawFloor);f.name=`Playtest floor ${play.game.depth} seed ${play.game.seed}`;
      G.floors.push(f);curFloor=G.floors.length-1;G.floor_plan[play.game.depth-1]=curFloor;changed('Starting layout saved and assigned to its floor.');tab='floors';render();
    }},'Save starting layout as custom floor')));
  requestAnimationFrame(()=>{playRefresh();playDraw(performance.now());});return box;
};
TABS.unshift(['play','▶ Play']);
if(location.hash==='#play')tab='play';
setInterval(()=>{
  if(tab!=='play'||!play.canvas?.isConnected)return;
  const now=performance.now(),g=play.game;
  if(!play.paused&&g?.state==='playing'&&!g.modal&&!play.inventory&&g.hero.paralysis>0&&now-play.lastInput>650)playCommand('wait');
  playDraw(play.paused?play.moveAt+240:now);
},1000/30);
render();
