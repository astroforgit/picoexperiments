/* Playable encounter tests, using the shared combat engine and native indexed art. */
(function(root){
'use strict';
let opened=null,lastArmy=['barracks-1','barracks-1'];
const el=(tag,text)=>{const n=document.createElement(tag);if(text!==undefined)n.textContent=text;return n;};
const button=(text,action)=>{const b=el('button',text);b.type='button';b.onclick=action;return b;};
const copy=x=>JSON.parse(JSON.stringify(x));
const xy=c=>({x:40+32*(c%7)+16*(Math.floor(c/7)%2),y:54+18*Math.floor(c/7)});
function art(){
 const raw=root.GreenhavenCombatArt,bytes=s=>Uint8Array.from(atob(s),c=>c.charCodeAt(0)),pal=bytes(raw.palette);
 const sprite=(s,w,h)=>{const pixels=bytes(s),c=el('canvas');c.width=w;c.height=h;const ctx=c.getContext('2d'),im=ctx.createImageData(w,h);pixels.forEach((v,i)=>{im.data.set([pal[v*3],pal[v*3+1],pal[v*3+2],v?255:0],i*4);});ctx.putImageData(im,0,0);return c;};
 const font=bytes(raw.font);
 return {raw,pal,maps:raw.maps.map(s=>sprite(s,320,128)),hexes:raw.hexes.map(s=>sprite(s,32,24)),obstacles:raw.obstacles.map(s=>sprite(s,32,28)),frames:raw.frames.map(s=>sprite(s,32,28)),font};
}
let artwork;
function open(data,r,s,initialDifficulty=0,initialSeed=1){
 if(opened)opened.close();
 const errors=root.GreenhavenBalance.validate(data);if(errors.length){alert(errors[0]);return;}
 artwork=artwork||art();data=copy(data);
 const region=data.encounterConfig.regions[r],stage=region.stages[s],dialog=el('dialog');dialog.className='combat-test';opened=dialog;
 const title=el('h2',`${region.name} · Stage ${s+1}: ${stage.name}`);title.id='combat-test-title';dialog.setAttribute('aria-labelledby',title.id);
 const top=el('div');top.className='combat-top';top.append(title,button('Close',()=>dialog.close()));dialog.append(top);
 const setup=el('section'),battle=el('section');battle.hidden=true;
 setup.append(el('p','Choose 1–5 fighters. All player units and tiers are available for testing, with duplicates and no gold limit. Click an army slot to remove it.'));
 const options=el('div');options.className='combat-options';
 const difficulty=el('select');difficulty.setAttribute('aria-label','Combat difficulty');root.GreenhavenBalance.DIFFICULTIES.forEach((name,i)=>{const o=el('option',name);o.value=i;difficulty.append(o);});difficulty.value=initialDifficulty;
 const seed=el('input');seed.type='number';seed.min=0;seed.max=255;seed.value=Number(initialSeed)&255;seed.setAttribute('aria-label','Combat seed');
 const group=el('select');group.setAttribute('aria-label','Enemy group');let option=el('option','Seeded encounter');option.value='';group.append(option);stage.variants.forEach((v,i)=>{const o=el('option',v.name);o.value=i;group.append(o);});
 options.append(el('label','Difficulty'),difficulty,el('label','Seed (0–255)'),seed,el('label','Group'),group);setup.append(options);
 const roster=el('div');roster.className='combat-roster';const slots=el('div');slots.className='combat-slots';const enemyPreview=el('p');const feedback=el('p');feedback.setAttribute('role','status');
 let army=lastArmy.filter(id=>data.players.some(u=>u.id===id)),iterator,state,encounter,busy=false,closed=false,hover=-1,cursor=0,raf=0,transition=null;
 const canvas=el('canvas');canvas.width=320;canvas.height=200;canvas.tabIndex=0;canvas.setAttribute('aria-label','Combat battlefield. Arrow keys move the cursor, Enter acts, Space skips.');
 const ctx=canvas.getContext('2d');ctx.imageSmoothingEnabled=false;
 const status=el('p');status.setAttribute('role','status');const log=el('ol');log.className='combat-log';const tools=el('div');tools.className='combat-options';
 const skip=button('Skip unit (Space)',()=>act({kind:'skip'}));const retreat=button('Retreat',()=>act({kind:'retreat'}));const restart=button('Retry same battle',()=>start(false));const edit=button('Edit army',()=>{iterator=null;state=null;busy=false;battle.hidden=true;setup.hidden=false;renderArmy();});
 tools.append(skip,retreat,restart,edit);const unitButtons=el('div');unitButtons.className='combat-slots';battle.append(canvas,status,tools,unitButtons,el('p','Click a blue hex to move or a red hex to attack. Click another ready fighter to select it; double-click a ready fighter to skip its remaining turn. An attack ends its turn; moving uses the shown movement points. Enemy turns play automatically.'),log);
 const startButton=button('Start combat',()=>start(true));startButton.className='primary';
 function portrait(id){const c=el('canvas');c.width=32;c.height=28;c.getContext('2d').drawImage(artwork.frames[artwork.raw.units[id]],0,0);return c;}
 const picks=[];
 for(const u of data.players){const b=button('',()=>{if(army.length<5){army.push(u.id);renderArmy();}});b.className='combat-pick';b.setAttribute('aria-label',`Add ${u.name}`);b.append(portrait(u.id),el('strong',u.name),el('span',`Tier ${u.tier} · HP ${u.hp} · ATK ${u.damage} · Move ${u.move} · Range ${u.shootRange}`));roster.append(b);picks.push(b);}
 function renderArmy(){slots.replaceChildren();for(let i=0;i<5;i++){const id=army[i],u=data.players.find(u=>u.id===id),b=button(u?`${i+1}. ${u.name} ×`:`${i+1}. Empty`,()=>{army.splice(i,1);renderArmy();});b.disabled=!u;slots.append(b);}picks.forEach(b=>b.disabled=army.length>=5);startButton.disabled=!army.length;lastArmy=army.slice();}
 function getEncounter(){const n=Number(seed.value);if(!Number.isInteger(n)||n<0||n>255)throw Error('Choose a seed from 0 to 255.');const e=root.GreenhavenBalance.generate(data,r,s,n,false,Number(difficulty.value));if(group.value!==''){const index=Number(group.value),v=stage.variants[index];e.variant=index;e.name=v.name;e.enemies=root.GreenhavenBalance.groupEnemies(v,Number(difficulty.value)).map((id,i)=>({...copy(data.enemies.find(u=>u.id===id)),cell:[6,13,20,27,34][i]}));}return e;}
 function preview(){try{const e=getEncounter();enemyPreview.textContent=`Enemies: ${e.enemies.map(u=>`${u.name} (${u.hp} HP)`).join(', ')}. ${e.victory}.`;feedback.textContent='';}catch(e){feedback.textContent=e.message;}}
 for(const input of [difficulty,seed,group])input.addEventListener('change',preview);
 setup.append(el('h3','Your army'),slots,el('h3','Available units'),roster,enemyPreview,feedback,startButton);dialog.append(setup,battle);document.body.append(dialog);renderArmy();preview();dialog.showModal();
 function start(fresh){try{if(fresh)encounter=getEncounter();iterator=root.GreenhavenSimulation.createBattle(data,army,encounter);state=null;transition=null;busy=false;setup.hidden=true;battle.hidden=false;consume(iterator.next());canvas.focus();}catch(e){feedback.textContent=e.message;}}
 function consume(result){
  if(result.done){state={phase:'finished',round:result.value.rounds,units:result.value.finalUnits,active:-1,remaining:{},legal:[],trace:result.value.trace,outcome:result.value.outcome};busy=false;}
  else {state=result.value;busy=state.phase==='enemy';}
  refresh();
 }
 function refresh(){
  skip.disabled=busy||state?.phase!=='player';retreat.disabled=skip.disabled;restart.disabled=busy;edit.disabled=busy;
  if(!state)return;
  status.style.fontWeight=state.phase==='finished'?'700':'';
  status.style.color=state.phase==='finished'?'#ffe591':'';
  status.textContent=state.phase==='finished'?`${state.outcome.toUpperCase()} · ${state.round} rounds · ${state.units.filter(u=>(u.team===0||u.charmedBy!=null)&&u.hp>0).length}/${army.length} fighters survived. Test only; campaign and balance are unchanged.`:state.phase==='enemy'?`Round ${state.round} · Enemy turn`:`Round ${state.round} · ${state.units[state.active].name} · ${state.remaining[state.active]} movement points remaining`;
  unitButtons.replaceChildren();state.units.filter(u=>(u.team===0||state.phase==='finished'&&u.charmedBy!=null)&&u.hp>0).forEach(u=>{const b=button(`${u.name} · ${u.hp} HP${u.slot===state.active?' · selected':''}`,()=>act({kind:'select',slot:u.slot}));b.disabled=busy||state.remaining[u.slot]===undefined;unitButtons.append(b);});
  log.replaceChildren(...state.trace.slice(-8).map(e=>el('li',e.action==='attack'?`${e.unit} → ${e.targetName}: ${e.damage} damage (${e.hpAfter} HP left)`: e.action==='charm'?`${e.unit} enchanted ${e.targetName}`:e.action==='release'?`${e.unit} is free of enchantment`:`${e.unit||state.units[e.actor]?.name||'Unit'}: ${e.action}${e.action==='prepare'?' — heavy strike next turn':''}`)));
 }
 const delay=ms=>new Promise(resolve=>setTimeout(resolve,ms));
 async function act(command){
  if(busy||state?.phase!=='player')return;
  busy=true;skip.disabled=true;retreat.disabled=true;edit.disabled=true;restart.disabled=true;
  const currentIterator=iterator;
  try{
   let result=currentIterator.next(command);
   while(!closed&&iterator===currentIterator){
    const next=result.done?{units:result.value.finalUnits,trace:result.value.trace}:result.value;
    const newEvents=next.trace.slice(state.trace.length);
    transition={from:state.units,to:next.units,events:newEvents,start:performance.now()};
    if(newEvents.length)await delay(420);
    if(closed||iterator!==currentIterator)return;
    transition=null;consume(result);
    if(result.done||state.phase==='player')break;
    await delay(280);
    if(closed||iterator!==currentIterator)return;
    result=currentIterator.next();
   }
  }catch(e){busy=false;status.textContent='Combat error: '+e.message;edit.disabled=false;restart.disabled=false;}
 }
 function cellAt(x,y){let best=-1,score=Infinity;for(let c=0;c<42;c++){const p=xy(c),dx=Math.abs(x-p.x),dy=Math.abs(y-p.y);if(dx<=16&&dy<=12&&dy<=12-dx*6/16){const d=dx*dx+dy*dy;if(d<score){score=d;best=c;}}}return best;}
 function coords(e){const b=canvas.getBoundingClientRect();return {x:(e.clientX-b.left)*320/b.width,y:(e.clientY-b.top)*200/b.height};}
 function choose(c){if(state?.phase!=='player'||busy)return;cursor=c;const u=state.units.find(u=>u.hp>0&&u.cell===c);if(u?.team===0){act({kind:'select',slot:u.slot});return;}const action=state.legal.find(a=>a.cell===c);if(action)act(action);}
 canvas.onpointermove=e=>{if(state?.phase==='finished')return;const p=coords(e);hover=cellAt(p.x,p.y);};canvas.onpointerleave=()=>hover=-1;
 function pointerCell(p){
  // Hit the visible sprite as well as its ground hex, including its upper body.
  const ground=cellAt(p.x,p.y),foot=ground>=0?xy(ground):null;
  if(foot&&Math.abs(p.x-foot.x)<=10&&Math.abs(p.y-foot.y)<=4&&state?.units.some(u=>u.hp>0&&u.cell===ground))return ground;
  const units=(state?.units||[]).filter(u=>u.hp>0).sort((a,b)=>b.cell-a.cell);
  for(const u of units){const foot=xy(u.cell),x=Math.floor(p.x-foot.x+16),y=Math.floor(p.y-foot.y+24);
   if(x>=0&&x<32&&y>=0&&y<28&&artwork.frames[artwork.raw.units[u.id]].getContext('2d').getImageData(x,y,1,1).data[3])return u.cell;
  }
  return cellAt(p.x,p.y);
 }
 canvas.onclick=e=>{if(state?.phase==='finished')return;const p=coords(e);canvas.focus();if(p.y>=191){if(p.x<90)act({kind:'skip'});else if(p.x>230)act({kind:'retreat'});return;}const c=pointerCell(p);if(c>=0)choose(c);};
 canvas.ondblclick=async e=>{
  e.preventDefault();if(busy||state?.phase!=='player')return;
  const p=coords(e);if(p.y>=157)return;
  const c=pointerCell(p),u=state.units.find(u=>u.hp>0&&u.team===0&&u.cell===c);
  if(!u||state.remaining[u.slot]===undefined)return;
  if(state.active!==u.slot)await act({kind:'select',slot:u.slot});
  if(!busy&&state?.phase==='player'&&state.active===u.slot)act({kind:'skip'});
 };
 canvas.onkeydown=e=>{if(state?.phase==='finished')return;if(['ArrowLeft','ArrowRight','ArrowUp','ArrowDown','Enter',' '].includes(e.key))e.preventDefault();if(e.key==='ArrowLeft'&&cursor%7)cursor--;if(e.key==='ArrowRight'&&cursor%7<6)cursor++;if(e.key==='ArrowUp'&&cursor>=7)cursor-=7;if(e.key==='ArrowDown'&&cursor<35)cursor+=7;if(e.key==='Enter')choose(cursor);if(e.key===' ')act({kind:'skip'});};
 function color(i){return `rgb(${artwork.pal.slice(i*3,i*3+3).join(',')})`;}
 function rect(x,y,w,h,c){ctx.fillStyle=color(c);ctx.fillRect(x,y,w,h);}
 function text(str,x,y,c=3,max=52){str=String(str).toUpperCase().slice(0,max);ctx.fillStyle=color(c);for(let i=0;i<str.length;i++){const index=(str.charCodeAt(i)-32)*48;if(index<0||index>=artwork.font.length)continue;for(let py=0;py<8;py++)for(let px=0;px<6;px++)if(artwork.font[index+py*6+px])ctx.fillRect(x+i*6+px,y+py,1,1);}}
 function draw(now){
  if(closed)return;raf=requestAnimationFrame(draw);if(battle.hidden||!state)return;
  rect(0,0,320,200,1);ctx.drawImage(artwork.maps[r],0,28);text(region.name,8,4,3,32);text('ROUND '+state.round,214,4);rect(0,15,320,1,2);text(state.phase==='enemy'?'ENEMY TURN':busy?'ACTION':state.phase==='finished'?state.outcome:'CHOOSE MOVE OR TARGET',8,18);
  for(let c=0;c<42;c++){const p=xy(c),a=!busy&&state.legal.find(a=>a.cell===c);ctx.drawImage(artwork.hexes[a?(a.kind==='move'?1:2):0],p.x-16,p.y-12);}
  if(state.phase!=='finished'){const p=xy(hover>=0?hover:cursor);ctx.drawImage(artwork.hexes[3],p.x-16,p.y-12);}
  const t=transition?Math.min(1,(now-transition.start)/420):1;
  const units=transition?transition.from:state.units;
  for(let c=0;c<42;c++){
   const p=xy(c);if(encounter.terrain.includes(c))ctx.drawImage(artwork.obstacles[[0,1,2,1][r]],p.x-16,p.y-24);
   for(const u of units.filter(u=>u.hp>0&&u.cell===c)){
    const next=transition?.to.find(v=>v.slot===u.slot),to=next?xy(next.cell):p,moving=next&&next.cell!==u.cell;
    const attacking=transition?.events.some(e=>(e.action==='attack'||e.action==='charm')&&e.actor===u.slot);
    const frame=attacking?4+Math.floor(t*2)%2:moving?Math.floor(t*4)%4:0;
    const bob=u.slot===state.active&&!busy&&state.phase==='player'?Math.floor(now/300)%2:0;
    ctx.drawImage(artwork.frames[artwork.raw.units[u.id]+frame],Math.round(p.x+(to.x-p.x)*t)-16,Math.round(p.y+(to.y-p.y)*t)-24-bob);
   }
  }
  if(transition)for(const e of transition.events.filter(e=>e.action==='attack'||e.action==='charm')){const a=xy(e.from),b=xy(e.to);if(transition.from[e.actor]?.shootRange>0){rect(Math.round(a.x+(b.x-a.x)*t),Math.round(a.y-12+(b.y-a.y)*t),3,2,3);}if(t>.65)text(e.action==='charm'?'CHARM':'-'+e.damage,b.x-6,b.y-29,e.action==='charm'?2:6);}
  rect(0,157,320,1,2);rect(0,158,320,42,1);
  const focus=state.units.find(u=>u.hp>0&&u.cell===hover)||state.units[state.active]||state.units.find(u=>u.hp>0);
  if(focus){text(focus.name,8,159);text(focus.team?'ENEMY':state.remaining[focus.slot]!==undefined?'READY':'DONE',264,159);text('HEALTH',8,170);text('ATTACK',92,170);text('MOVE',172,170);text('SHOOT',248,170);text(`${focus.hp}/${focus.maxHp}`,8,180);text(focus.damage,92,180);text(`${state.remaining[focus.slot]||0}/${focus.move}`,172,180);text(focus.shootRange,248,180);}
  if(state.phase==='finished'){const alive=state.units.filter(u=>(u.team===0||u.charmedBy!=null)&&u.hp>0).length;text(`${state.outcome} - ${alive}/${army.length} SURVIVED`,8,192);}
  else{rect(7,191,80,9,7);rect(233,191,80,9,7);text('SKIP',20,192);text('FIRE: ACT',103,192);text('RETREAT',252,192);}
 }
 raf=requestAnimationFrame(draw);
 dialog.addEventListener('close',()=>{closed=true;cancelAnimationFrame(raf);dialog.remove();if(opened===dialog)opened=null;},{once:true});
}
root.GreenhavenCombatTest={open};
})(window);
