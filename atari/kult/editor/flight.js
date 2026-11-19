'use strict';
const $=id=>document.getElementById(id),clone=v=>JSON.parse(JSON.stringify(v));
let payload,project,encounter,paused=false,last=0,acc=0,images=new Map(),busy=false;
let campaign=null,renderer,clipboard=null,wavePlans=[],mapFrame=40,mapClock=0,mapLast=0,measuredBulletWaves=[];
const keys=new Set(),storageKey='kult-diabolic-flight-encounters-v1';
function status(message,error=false){$('status').textContent=message;$('status').classList.toggle('error',error);}
function persist(){try{localStorage.setItem(storageKey,JSON.stringify(project));status('Draft saved in this browser. Apply to local game when ready.');}catch{status('Browser storage unavailable; save a project file.',true);}}
function options(select,items,value){select.replaceChildren(...items.map(([id,name])=>new Option(name,id)));select.value=String(value);}
function sprite(asset,frame){const key=asset.id+':'+frame;if(images.has(key))return images.get(key);const c=document.createElement('canvas');c.width=asset.width;c.height=asset.height;const g=c.getContext('2d');g.fillStyle='#e6e6e6';asset.frames[frame].forEach((p,i)=>{if(p)g.fillRect(i%asset.width,Math.floor(i/asset.width),1,1);});images.set(key,c);return c;}
function asset(kind,id){return payload.catalog[kind].find(v=>v.id===id);}
function record(){return project.waves[Number($('sector').value)][Number($('wave').value)];}
function restart(){campaign=null;encounter=new FlightWorkshop.Encounter(project,payload.sine,Number($('sector').value),Number($('wave').value),{drops:payload.drops});$('previewTitle').textContent=`Sector ${Number($('sector').value)+1} · Wave ${Number($('wave').value)+1}`;}
function showWave(){$('bossDesign').value=project.boss.design;$('bossPattern').value=project.boss.pattern;$('bossDifficulty').value=project.boss.difficulty;const kind=project.encounters[Number($('sector').value)][Number($('wave').value)];$('encounter').value=kind;const w=record();options($('slot'),project.slots.map((id,i)=>[i,`${i+1} · ${asset('enemies',id).name}`]),w[0]);$('motion').value=w[1];$('drop').value=w[2];$('hp').value=w[3];$('design').value=project.slots[w[0]];showPath();restart();timeline();}
function showPath(){project.motions[record()[1]].forEach((n,i)=>$('param'+i).value=n);}
function changed(reset=true){persist();if(reset)restart();timeline();}
function drawAsset(id,thing,frame){const c=$(id),g=c.getContext('2d');g.clearRect(0,0,c.width,c.height);g.imageSmoothingEnabled=false;const scale=Math.min(thing.width===40?4:5,(c.width-8)/thing.width,(c.height-8)/thing.height);g.drawImage(sprite(thing,frame),(c.width-thing.width*scale)/2,(c.height-thing.height*scale)/2,thing.width*scale,thing.height*scale);}
function drawFrames(id,thing){const c=$(id),g=c.getContext('2d');g.clearRect(0,0,c.width,c.height);g.imageSmoothingEnabled=false;const cell=c.width/4,scale=Math.min((cell-8)/thing.width,(c.height-8)/thing.height);for(let f=0;f<4;f++)g.drawImage(sprite(thing,f),f*cell+(cell-thing.width*scale)/2,4,thing.width*scale,thing.height*scale);}

function render(){if(!encounter)return;const frame=Math.floor(encounter.tick/3)%4,ship=asset('ships',project.ship),enemy=encounter.kind===4?asset('bosses',project.boss.design):asset('enemies',encounter.kind&&encounter.kind!==7?'redesign-14':project.slots[record()[0]]);
 for(const c of $('bossGallery').querySelectorAll('canvas')){const a=asset('bosses',c.dataset.id),g=c.getContext('2d');g.clearRect(0,0,128,128);g.imageSmoothingEnabled=false;g.drawImage(sprite(a,(encounter.age>>2)&3),0,0,128,128);c.parentElement.setAttribute('aria-pressed',String(a.id===project.boss.design));}
 drawFrames('bossFrames',asset('bosses',project.boss.design));
 drawAsset('shipPreview',ship,frame);drawAsset('enemyPreview',enemy,encounter.kind===4?(encounter.age>>2)&3:frame);drawFrames('shipFrames',ship);drawFrames('enemyFrames',enemy);
 $('previewTitle').textContent=`Sector ${encounter.sector+1} · Wave ${encounter.wave+1}`;
 renderer.draw(encounter,{trails:$('trails').checked,bossGuide:$('bossGuide').checked});
 $('playbackStatus').textContent=campaign?`Sector ${encounter.sector+1} · Wave ${encounter.wave+1} / 48 · ${campaign.mode==='playing'?'Playing sequence':campaign.mode==='won'?'Sector complete':'Flight ended — restart to try again'}`:'Looping selected wave';
 $('hits').textContent=(encounter.kind===4?`Boss HP: ${encounter.bossHP} · `:encounter.kind===7?'2 meteors + 6 shootable enemies · ':encounter.kind?'Indestructible meteors · ':'')+`Bombs: ${encounter.bombs}/3 · Shields: ${encounter.shields}/3 · Clocks: ${encounter.clocks}/3${encounter.slowRemaining?' · 1/3 SPEED':''} · Hits to ship: ${encounter.hits} · Enemy shots: ${encounter.hostile.length}/${encounter.boss?8:4}${encounter.boss&&!encounter.options.curtainOnly?' · '+['Entering','Straight orbs','Sine orbs','Retreating','Four curtain waves','Meteor shower','Returning','Clearing the sky','Entering'][encounter.ai.phase]:''}${encounter.attack?' · '+FlightWorkshop.formations[encounter.attack.pattern-1].name+' · '+encounter.attack.state:''}`;
 if($('originalGallery').open)for(const c of $('originalGrid').querySelectorAll('canvas')){const a=asset('enemies',c.dataset.id),ctx=c.getContext('2d');ctx.clearRect(0,0,64,64);ctx.imageSmoothingEnabled=false;ctx.drawImage(sprite(a,frame),0,0,64,64);}
 if($('gallery').open)for(const c of $('galleryGrid').querySelectorAll('canvas')){const a=asset('enemies',c.dataset.id),ctx=c.getContext('2d');ctx.clearRect(0,0,64,64);ctx.imageSmoothingEnabled=false;ctx.drawImage(sprite(a,frame),0,0,64,64);}
}
function loop(time){if(!last)last=time;acc+=Math.min(.15,(time-last)/1000);last=time;while(acc>=.06){if(encounter&&!paused){(campaign||encounter).update({left:keys.has('ArrowLeft'),right:keys.has('ArrowRight'),up:keys.has('ArrowUp'),down:keys.has('ArrowDown'),fire:!!campaign||keys.has('ControlLeft')||keys.has('ControlRight'),clock:keys.has('KeyZ')||keys.has('KeyX')||keys.has('KeyC'),shield:keys.has('Space'),bomb:keys.has('ShiftLeft')||keys.has('ShiftRight')});if(campaign){const previous=encounter;encounter=campaign.encounter;highlightWave();if(previous!==encounter)$('waveTimeline').children[encounter.wave].scrollIntoView({block:'nearest',inline:'nearest'});}}acc-=.06;}render();renderWavePlans(time);requestAnimationFrame(loop);}
function download(blob,name){const a=document.createElement('a'),url=URL.createObjectURL(blob);a.href=url;a.download=name;a.click();setTimeout(()=>URL.revokeObjectURL(url),1000);}
async function submit(apply){if(busy)return;busy=true;$('apply').disabled=$('export').disabled=true;status('Building and checking the Atari executable…');try{FlightWorkshop.validate(project,payload.catalog);const r=await fetch('/api/diabolic/'+(apply?'apply':'export'),{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify(project)});if(!r.ok)throw Error(await r.text());if(apply){await r.json();status('Applied. Restart diabolic/run-emulator.sh to play your selections.');}else{download(await r.blob(),'kult-diabolic-custom.xex');status('Verified Atari executable downloaded.');}}catch(e){status(e.message,true);}finally{busy=false;$('apply').disabled=$('export').disabled=false;}}
// Capture the actual simulator's unopposed movement, including meteor entry/drain.
function captureWave(sector,wave){
 const sim=new FlightWorkshop.Encounter(project,payload.sine,sector,wave,{loop:false,bulletWaves:measuredBulletWaves}),frames=[];
 const limit=sim.meteor?240:sim.kind===4?160:150;
 for(let i=0;i<limit;i++){sim.invulnerable=999;sim.update();frames.push(sim.enemies.map(e=>({x:e.x,y:e.y,visible:e.visible})));if(sim.complete)break;}
 return {frames,kind:sim.kind,enemyId:project.slots[sim.record[0]],id:sim.kind===4?project.boss.design:sim.kind?'redesign-14':project.slots[sim.record[0]]};
}
function drawWavePlan(canvas,plan,index){
 const g=canvas.getContext('2d'),scale=canvas.width/512,frame=plan.frames[index];if(!frame)return;
 g.save();g.scale(scale,scale);g.imageSmoothingEnabled=false;g.fillStyle='#05070b';g.fillRect(0,0,512,256);
 g.strokeStyle='#151c25';g.lineWidth=1;for(let x=0;x<512;x+=64){g.beginPath();g.moveTo(x,0);g.lineTo(x,256);g.stroke();}for(let y=0;y<256;y+=64){g.beginPath();g.moveTo(0,y);g.lineTo(512,y);g.stroke();}
 const count=plan.kind===4?1:8;
 for(let n=0;n<count;n++){
  g.strokeStyle=n===0?'#78899d':'#354252';g.lineWidth=n===0?1.5:1;g.beginPath();let prev=null;
  for(let i=Math.max(0,index-60);i<=index;i++){const e=plan.frames[i][n];if(!e.visible){prev=null;continue;}const x=e.x*4+(plan.kind===4?64:16),y=e.y*2+(plan.kind===4?32:16);if(prev&&Math.abs(e.y-prev.y)<40&&Math.abs(e.x-prev.x)<40)g.lineTo(x,y);else g.moveTo(x,y);prev=e;}g.stroke();
  const e=frame[n];if(!e.visible)continue;const x=e.x*4,y=e.y*2;
  g.drawImage(sprite(asset(plan.kind===4?'bosses':'enemies',plan.kind===7&&n>=2?plan.enemyId:plan.id),plan.kind===4?((index+1)>>2)&3:plan.kind===7?(n<2?0:Math.floor(index/3)%2):Math.floor(index/3)%4),x,y-(plan.kind===4?32:0),plan.kind===4?128:32,plan.kind===4?128:32);
  const previous=plan.frames[Math.max(0,index-2)][n],dx=e.x-previous.x,dy=e.y-previous.y;
  if(previous.visible&&Math.hypot(dx,dy)>.1&&Math.abs(dy)<40){const angle=Math.atan2(dy*2,dx*4),cx=x+(plan.kind===4?64:16)+Math.cos(angle)*24,cy=y+(plan.kind===4?32:16)+Math.sin(angle)*24;g.strokeStyle='#c2cedd';g.beginPath();g.moveTo(cx-7*Math.cos(angle-.6),cy-7*Math.sin(angle-.6));g.lineTo(cx,cy);g.lineTo(cx-7*Math.cos(angle+.6),cy-7*Math.sin(angle+.6));g.stroke();}
 }
 g.globalAlpha=.5;g.drawImage(sprite(asset('ships',project.ship),0),16,112,80,32);g.restore();
}
function renderWavePlans(time){
 if(!wavePlans.length)return;
 if(time-mapLast<80)return;mapLast=time;
 const selected=Number($('wave').value),plan=wavePlans[selected];
 if($('animateWaveMap').checked){mapClock+=1;mapFrame=(mapFrame+1)%plan.frames.length;$('waveTime').value=mapFrame;}
 drawWavePlan($('waveMap'),plan,mapFrame);
 $('waveMapTime').textContent=`${(mapFrame*.06).toFixed(1)} s / ${((plan.frames.length-1)*.06).toFixed(1)} s · ${plan.kind===4?'Sub-boss entrance and movement':plan.kind?({1:'Meteors from above',2:'Meteors from below',3:'Meteors from the right',6:'Alternating top / bottom lanes',7:'Two meteors and six enemies from the right'}[plan.kind]):'Eight-enemy formation'}`;
 const bounds=$('waveTimeline').getBoundingClientRect();for(const c of $('waveTimeline').querySelectorAll('canvas')){const r=c.getBoundingClientRect();if(r.right<bounds.left||r.left>bounds.right)continue;const i=Number(c.dataset.wave),p=wavePlans[i];drawWavePlan(c,p,$('animateWaveMap').checked?(40+mapClock)%p.frames.length:Math.min(mapFrame,p.frames.length-1));}
}
function showBossRanges(){const profiles=measuredBulletWaves=FlightWorkshop.measureBulletWaves(project,payload.sine);$('bossRange').textContent='Six trigonometric curtains use the original sine table. Each has one 32-pixel opening, slow formation, and a 12-pixel/update average rush (twice ship speed). A new wave forms every 60 game updates while the previous guards pass.';options($('bossPattern'),[[0,'Rotate all six'],...FlightWorkshop.formations.map((f,i)=>[i+1,f.name])],project.boss.pattern);return profiles;}
function timeline(){
 showBossRanges();
 const sector=Number($('sector').value),selected=Number($('wave').value),names=['Formation','Meteors ↓','Meteors ↑','Meteors ←','Sub-boss','Reserved','Meteors ↓↑','Meteors + enemies ←'];
 wavePlans=project.waves[sector].map((_,i)=>captureWave(sector,i));mapFrame=40;mapClock=0;$('waveTime').max=wavePlans[selected].frames.length-1;$('waveTime').value=mapFrame;$('waveMapTitle').textContent=`Sector ${sector+1} · Wave ${selected+1} flight plan`;
 $('waveTimeline').replaceChildren(...project.waves[sector].map((w,i)=>{const b=document.createElement('button'),c=document.createElement('canvas'),title=document.createElement('strong'),description=document.createElement('span');b.type='button';b.dataset.wave=i;b.setAttribute('aria-pressed',String(i===selected));b.setAttribute('aria-label',`Wave ${i+1}: ${names[project.encounters[sector][i]]}`);c.width=256;c.height=128;c.dataset.wave=i;const kind=project.encounters[sector][i];drawWavePlan(c,wavePlans[i],40);title.textContent=`${String(i+1).padStart(2,'0')} · ${names[kind]}`;description.textContent=`Path ${w[1]+1} · HP ${w[3]}`;b.append(c,title,description);b.onclick=()=>selectWave(i);return b;}));
 $('previousWave').disabled=$('moveEarlier').disabled=selected===0;$('nextWave').disabled=$('moveLater').disabled=selected===47;highlightWave();
}
function selectWave(i){$('wave').value=Math.max(0,Math.min(47,i));showWave();$('waveTimeline').children[Number($('wave').value)].scrollIntoView({block:'nearest',inline:'nearest'});}
function highlightWave(){for(const b of $('waveTimeline').children)b.classList.toggle('playing',!!campaign&&campaign.encounter.wave===Number(b.dataset.wave));}
function moveWave(offset){const sector=Number($('sector').value),from=Number($('wave').value),to=from+offset;if(to<0||to>47)return;for(const rows of [project.waves,project.encounters])[rows[sector][from],rows[sector][to]]=[rows[sector][to],rows[sector][from]];selectWave(to);persist();}
function mount(){
 options($('bossDesign'),payload.catalog.bosses.map(b=>[b.id,b.name]),project.boss.design);
 $('bossDesign').onchange=()=>{project.boss.design=$('bossDesign').value;changed();};
 for(const b of payload.catalog.bosses){const button=document.createElement('button'),canvas=document.createElement('canvas'),label=document.createElement('span');canvas.width=canvas.height=128;canvas.dataset.id=b.id;label.textContent=b.name;button.setAttribute('aria-pressed',String(b.id===project.boss.design));button.append(canvas,label);button.onclick=()=>{$('bossDesign').value=b.id;$('bossDesign').dispatchEvent(new Event('change'));};$('bossGallery').append(button);}

 for(const [id,key] of [['bossPattern','pattern'],['bossDifficulty','difficulty']])$(id).onchange=()=>{project.boss[key]=Number($(id).value);changed();};
 $('testCurtain').onclick=()=>{restart();encounter=new FlightWorkshop.Encounter(project,payload.sine,Number($('sector').value),Number($('wave').value),{bossPreview:true,drops:payload.drops});Object.assign(encounter.ai,{phase:4,timer:0,cooldown:0,art:0});encounter.bossWarmup=9;encounter.bossClock=29;encounter.bossX=88;encounter.bossTop=32;paused=false;$('pause').textContent='Pause';$('flight').focus();};
 $('testBoss').onclick=()=>{restart();encounter=new FlightWorkshop.Encounter(project,payload.sine,Number($('sector').value),Number($('wave').value),{bossPreview:true,drops:payload.drops});paused=false;$('pause').textContent='Pause';$('flight').focus();};
 $('waveTime').oninput=()=>{$('animateWaveMap').checked=false;mapFrame=Number($('waveTime').value);mapLast=0;renderWavePlans(performance.now());};
 renderer=new DiabolicRenderer($('flight'),payload);
 $('previousWave').onclick=()=>selectWave(Number($('wave').value)-1);$('nextWave').onclick=()=>selectWave(Number($('wave').value)+1);
 $('moveEarlier').onclick=()=>moveWave(-1);$('moveLater').onclick=()=>moveWave(1);
 $('copyWave').onclick=()=>{clipboard={record:clone(record()),kind:project.encounters[Number($('sector').value)][Number($('wave').value)]};$('pasteWave').disabled=false;status('Wave copied. Select a destination and paste to replace it.');};
 $('pasteWave').onclick=()=>{if(!clipboard)return;const s=Number($('sector').value),w=Number($('wave').value);project.waves[s][w]=clone(clipboard.record);project.encounters[s][w]=clipboard.kind;showWave();persist();};
 $('waveTimeline').onkeydown=e=>{if(e.key==='ArrowRight'||e.key==='ArrowLeft'){e.preventDefault();selectWave(Number($('wave').value)+(e.key==='ArrowRight'?1:-1));$('waveTimeline').children[Number($('wave').value)].focus();}};
 $('playWaves').onclick=()=>{campaign=new FlightWorkshop.Campaign(project,payload.sine,Number($('sector').value),Number($('wave').value),{sectorOnly:true,drops:payload.drops});encounter=campaign.encounter;paused=false;$('pause').textContent='Pause';$('flight').focus();};
 $('loopWave').onclick=()=>{restart();paused=false;$('pause').textContent='Pause';$('flight').focus();highlightWave();};
 $('openSimulator').onclick=()=>{try{localStorage.setItem('kult-diabolic-simulator-draft',JSON.stringify(project));window.open(`/web/?draft=1&sector=${$('sector').value}&wave=${$('wave').value}`,'_blank');}catch(e){status('Could not store draft: '+e.message,true);}};

 options($('sector'),Array.from({length:8},(_,i)=>[i,`Sector ${i+1}`]),0);options($('wave'),Array.from({length:48},(_,i)=>[i,`Wave ${i+1}`]),0);options($('motion'),Array.from({length:32},(_,i)=>[i,`Path ${String(i+1).padStart(2,'0')}`]),0);options($('drop'),Array.from({length:32},(_,i)=>[i,`Pattern ${i+1}`]),0);
 options($('ship'),payload.catalog.ships.map(v=>[v.id,v.name]),project.ship);options($('design'),payload.catalog.enemies.map(v=>[v.id,v.name]),project.slots[0]);
 const labels=['Y phase A','Y phase B','X phase A','X phase B','Y spacing A','Y spacing B','X spacing A','X spacing B'];
 labels.forEach((name,i)=>{const label=document.createElement('label'),input=document.createElement('input');label.textContent=name;input.type='number';input.min=-128;input.max=127;input.id='param'+i;input.addEventListener('change',()=>{if(!input.checkValidity())return input.reportValidity();project.motions[record()[1]][i]=Number(input.value);changed();});label.append(input);$('parameters').append(label);});
 $('encounter').onchange=()=>{project.encounters[Number($('sector').value)][Number($('wave').value)]=Number($('encounter').value);changed();};
 for(const id of ['sector','wave'])$(id).onchange=showWave;
 $('ship').onchange=()=>{project.ship=$('ship').value;changed(false);};
 $('slot').onchange=()=>{record()[0]=Number($('slot').value);showWave();changed();};
 $('design').onchange=()=>{project.slots[record()[0]]=$('design').value;showWave();changed();};
 $('motion').onchange=()=>{record()[1]=Number($('motion').value);showPath();changed();};
 $('drop').onchange=()=>{record()[2]=Number($('drop').value);changed();};
 $('hp').onchange=()=>{if(!$('hp').checkValidity())return $('hp').reportValidity();record()[3]=Number($('hp').value);changed();};
 $('resetPath').onclick=()=>{project.motions[record()[1]]=clone(payload.defaults.motions[record()[1]]);showPath();changed();};
 for(const [id,key] of [['fireMode','mode'],['fireInterval','interval'],['fireSpeed','speed']]){$(id).value=project.firing[key];$(id).onchange=()=>{if(!$(id).checkValidity())return $(id).reportValidity();project.firing[key]=Number($(id).value);changed();};}
 $('pause').onclick=()=>{paused=!paused;$('pause').textContent=paused?'Resume':'Pause';};$('restart').onclick=restart;
 $('save').onclick=()=>download(new Blob([JSON.stringify(project,null,2)],{type:'application/json'}),'kult-diabolic-project.json');$('open').onclick=()=>$('projectFile').click();
 $('projectFile').onchange=async()=>{try{const file=$('projectFile').files[0];if(!file)return;const next=FlightWorkshop.validate(JSON.parse(await file.text()),payload.catalog);project=next;$('ship').value=project.ship;for(const [id,key] of [['fireMode','mode'],['fireInterval','interval'],['fireSpeed','speed']])$(id).value=project.firing[key];showWave();persist();status('Project loaded. Apply to local game to rebuild the Atari version.');}catch(e){status(e.message,true);}finally{$('projectFile').value='';}};
 $('loadApplied').onclick=async()=>{try{const r=await fetch('/api/diabolic');if(!r.ok)throw Error('Could not load the current game');const data=await r.json();project=FlightWorkshop.validate(clone(data.project),payload.catalog);$('ship').value=project.ship;for(const [id,key] of [['fireMode','mode'],['fireInterval','interval'],['fireSpeed','speed']])$(id).value=project.firing[key];showWave();persist();status('Loaded the current Atari game settings.');}catch(e){status(e.message,true);}};
 $('apply').onclick=()=>submit(true);$('export').onclick=()=>submit(false);
 $('useRedesigns').onclick=()=>{project.slots=Array.from({length:32},(_,i)=>`redesign-${i}`);showWave();persist();status('All 32 redesigns selected. Apply to local game to save.');};
 for(let i=0;i<32;i++){const card=document.createElement('article'),title=document.createElement('h3'),pair=document.createElement('div');card.className='enemy-comparison';title.textContent=`Enemy ${String(i+1).padStart(2,'0')}`;pair.className='enemy-pair';card.append(title,pair);for(const [prefix,label] of [['original','Original'],['redesign','Redesigned']]){const button=document.createElement('button'),canvas=document.createElement('canvas'),caption=document.createElement('span');canvas.width=canvas.height=64;canvas.dataset.id=`${prefix}-${i}`;caption.textContent=label;button.title=`Use ${label.toLowerCase()} enemy ${i+1} in slot ${i+1}`;button.append(canvas,caption);button.onclick=()=>{project.slots[i]=canvas.dataset.id;record()[0]=i;showWave();changed();};pair.append(button);}$('originalGrid').append(card);}
 for(const a of payload.catalog.enemies){const b=document.createElement('button'),c=document.createElement('canvas'),label=document.createElement('span');c.width=c.height=64;c.dataset.id=a.id;label.textContent=a.name;b.append(c,label);b.onclick=()=>{$('design').value=a.id;$('design').dispatchEvent(new Event('change'));};$('galleryGrid').append(b);}
 $('flight').addEventListener('keydown',e=>{if(['ArrowLeft','ArrowRight','ArrowUp','ArrowDown','Space','ControlLeft','ControlRight','ShiftLeft','ShiftRight','KeyZ','KeyX','KeyC'].includes(e.code)){e.preventDefault();keys.add(e.code);}});$('flight').addEventListener('keyup',e=>keys.delete(e.code));$('flight').addEventListener('blur',()=>keys.clear());window.addEventListener('blur',()=>keys.clear());
 $('workspace').hidden=false;showWave();status('Ready. Choose a ship or enemy, then apply your changes to the Atari game.');requestAnimationFrame(loop);
}
fetch('/api/diabolic').then(r=>{if(!r.ok)throw Error('Start the local editor server and reload.');return r.json();}).then(data=>{payload=data;project=FlightWorkshop.validate(clone(data.project),data.catalog);try{const draft=localStorage.getItem(storageKey);if(draft)project=FlightWorkshop.validate(JSON.parse(draft),data.catalog);}catch{}mount();}).catch(e=>status(e.message,true));
