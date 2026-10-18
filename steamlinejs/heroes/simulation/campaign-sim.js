/* Stats-only model of the editor preset; no native game or emulator is executed. */
(function(root){
'use strict';
const rules=typeof module!=='undefined'&&module.exports?require('../editor-balance.js'):root.GreenhavenBalance;
const copy=x=>JSON.parse(JSON.stringify(x));
const cell=(x,y)=>x<0||x>6||y<0||y>5?-1:y*7+x;
const row=i=>Math.floor(i/7), ax=i=>i%7-Math.floor(row(i)/2);
const distance=(a,b)=>Math.max(Math.abs(ax(a)-ax(b)),Math.abs(row(a)-row(b)),Math.abs(ax(a)+row(a)-ax(b)-row(b)));
const neighbours=Array.from({length:42},(_,i)=>{const x=i%7,y=row(i),o=y%2;return [cell(x+1,y),cell(x+o,y+1),cell(x+o-1,y+1),cell(x-1,y),cell(x+o-1,y-1),cell(x+o,y-1)].filter(n=>n>=0);});
function cube(i){return [ax(i),-ax(i)-row(i),row(i)];}
function roundCube(v){let r=v.map(Math.round),d=v.map((x,i)=>Math.abs(x-r[i])),k=d.indexOf(Math.max(...d));r[k]=-r[(k+1)%3]-r[(k+2)%3];return r;}
function clear(a,b,trees){const n=distance(a,b),u=cube(a),v=cube(b);for(let i=1;i<n;i++)for(const e of [-0.000001,0.000001]){const q=roundCube(u.map((x,k)=>x+(v[k]-x)*i/n+(k===2?-2*e:e)));if(trees.has(cell(q[0]+Math.floor(q[2]/2),q[2])))return false;}return true;}
const DIST=Array.from({length:42},(_,i)=>Array.from({length:42},(_,j)=>distance(i,j)));
const defaultTrees=new Set([10,31]);
const SHOT=Array.from({length:42},(_,i)=>Array.from({length:42},(_,j)=>clear(i,j,defaultTrees)));
function flood(start,blocked){const dist=Array(42).fill(999),prev=Array(42).fill(-1),q=[start];dist[start]=0;for(let k=0;k<q.length;k++)for(const n of neighbours[q[k]])if(!blocked.has(n)&&dist[n]===999){dist[n]=dist[q[k]]+1;prev[n]=q[k];q.push(n);}return {dist,prev};}
function pathTo(from,to,prev){const p=[];for(let c=to;c!==from;c=prev[c]){if(c<0)throw Error('Invalid movement path');p.push(c);}return p.reverse();}
function simulateBattle(data,army,encounter,options={}){
 const abilities=data.monsterAbilitiesVersion===1;
 const limit=options.maxRounds||60,trace=options.trace?[]:null,units=[];
 const trees=new Set(encounter.terrain||[10,31]);
 const normalTerrain=trees.size===2&&trees.has(10)&&trees.has(31);
 const visible=(a,b)=>normalTerrain?SHOT[a][b]:clear(a,b,trees);
 const emit=event=>{if(trace)trace.push({...event,round});};
 army.forEach((id,i)=>{if(!id)return;const u=data.players.find(x=>x.id===id);if(!u)throw Error('Unknown player '+id);units.push({...copy(u),team:0,armySlot:i,cell:(encounter.playerCells||[0,7,14,21,28])[i],slot:units.length});});
 for(const enemy of encounter.enemies)units.push({...copy(enemy),team:1,slot:units.length});
 if(units.length>12||army.length>5||new Set(units.map(u=>u.cell)).size!==units.length||units.some(u=>trees.has(u.cell)))throw Error('Illegal deployment');
 for(const u of units){u.maxHp=u.hp;u.spawned=0;u.raised=false;u.summoned=false;u.charge=null;}
 const initialUnits=options.trace?copy(units):null;
 const blocked=(self)=>new Set([...trees,...units.filter(u=>u.hp>0&&u!==self).map(u=>u.cell)]);
 const canHit=(u,c,t)=>DIST[c][t.cell]<=Math.max(1,u.shootRange)&&visible(c,t.cell);
 let round=0,winner=null,moves=0,attacks=0,summons=0,healing=0,conversions=0,preparations=0,hops=0,deadWarlock=false;
 const check=()=>{if(deadWarlock||!units.some(u=>u.team===1&&u.hp>0))winner='victory';else if(!units.some(u=>u.team===0&&u.hp>0))winner='defeat';return winner;};
 function hit(u,t,bonus=0){
  const before=t.hp;let damage=u.damage+bonus;
  if(abilities&&u.family==='archery'&&t.id==='skeleton')damage=Math.max(1,damage-1);
  t.hp=Math.max(0,t.hp-damage);attacks++;emit({action:'attack',actor:u.slot,unit:u.name,target:t.slot,targetName:t.name,damage:Math.min(before,damage),hpBefore:before,hpAfter:t.hp,from:u.cell,to:t.cell});
  if(t.hp===0&&t.id==='warlock')deadWarlock=true;
  if(abilities&&t.hp===0&&t.team===0&&u.id==='zombie'&&!u.raised&&conversions<2){
   const slot=t.slot,cell=t.cell;Object.assign(t,copy(data.enemies.find(e=>e.id==='zombie')),{damage:Math.min(9,data.enemies.find(e=>e.id==='zombie').damage+(encounter.escalation?.damageBonus||0)),team:1,slot,cell,hp:2,maxHp:2,raised:true,spawned:round,summoned:false,charge:null});conversions++;emit({action:'raise',actor:u.slot,target:slot,to:cell,hp:2});
  }
  if(abilities&&u.id==='dark'&&before>0&&u.hp<u.maxHp){u.hp++;healing++;emit({action:'heal',actor:u.slot,hpAfter:u.hp,amount:1});}
  if(abilities&&u.id==='imp'){
   const to=neighbours[u.cell].find(c=>!blocked(u).has(c)&&DIST[c][t.cell]>DIST[u.cell][t.cell]);
   if(to!==undefined){move(u,to);hops++;emit({action:'hop',actor:u.slot,to});}
  }
  check();
 }
 function move(u,to){const from=u.cell;u.cell=to;moves++;emit({action:'move',actor:u.slot,unit:u.name,from,to});}
 function heroAct(u){
  const foes=units.filter(v=>v.team===1&&v.hp>0),walls=blocked(u),reachable=flood(u.cell,walls);
  let best=null;
  for(let c=0;c<42;c++)if(reachable.dist[c]<u.move||c===u.cell)for(const t of foes)if(canHit(u,c,t)){
   const killing=t.hp<=u.damage,threat=t.id==='warlock'?15:t.damage+(t.shootRange>0?1:0);
   const score=(t.id==='warlock'?1000:0)+(killing?100:0)+Math.min(u.damage,t.hp)*10+threat-reachable.dist[c]*0.1;
   if(!best||score>best.score)best={score,c,t};
  }
  if(best){for(const c of pathTo(u.cell,best.c,reachable.prev))move(u,c);hit(u,best.t);return;}
  // Search a route to a hex from which an enemy can be attacked. Living units block travel.
  const goals=[];for(let c=0;c<42;c++)if(!walls.has(c)&&foes.some(t=>canHit(u,c,t)))goals.push(c);
  const toGoal=Array(42).fill(999),q=goals.slice();for(const c of goals)toGoal[c]=0;
  for(let k=0;k<q.length;k++)for(const n of neighbours[q[k]])if(!walls.has(n)&&toGoal[n]===999){toGoal[n]=toGoal[q[k]]+1;q.push(n);}
  let destination=u.cell,bestScore=Infinity;
  for(let c=0;c<42;c++)if(reachable.dist[c]<=u.move){
   let score=toGoal[c]*100+Math.min(...foes.map(t=>DIST[c][t.cell]))+reachable.dist[c]*0.01;
   if(options.playerPolicy==='reckless')score=Math.min(...foes.map(t=>DIST[c][t.cell]))*100+reachable.dist[c]*0.01;
   if(score<bestScore){bestScore=score;destination=c;}
  }
  if(destination!==u.cell)for(const c of pathTo(u.cell,destination,reachable.prev))move(u,c);
  else emit({action:'skip',actor:u.slot,unit:u.name});
 }
 function enemyAct(u){
  if(u.id==='warlock'){
   if(abilities&&(round<2||units.filter(v=>v.summoned&&v.hp>0).length>=2))return;
   const reused=abilities?units.find(v=>v.team===1&&v.hp<=0):null;
   if(units.length>=12&&!reused){emit({action:'summon-blocked',reason:'12 allocated slots; dead slots are not reused',actor:u.slot});return;}
   const walls=blocked(null);for(let c=0;c<42;c++)if(!walls.has(c)&&DIST[u.cell][c]<=3){const demon=data.enemies.find(x=>x.id===(abilities?'skeleton':'demon')),slot=reused?reused.slot:units.length;const summonHP=abilities?Math.min(99,demon.hp+(encounter.escalation?.hpBonus||0)):demon.hp;
    const summonDamage=abilities?Math.min(9,demon.damage+(encounter.escalation?.damageBonus||0)):demon.damage;
    const summoned={...copy(demon),hp:summonHP,damage:summonDamage,maxHp:summonHP,team:1,cell:c,slot,spawned:abilities?round:0,summoned:true,raised:false,charge:null};if(reused)Object.assign(reused,summoned);else units.push(summoned);summons++;emit({action:'summon',actor:u.slot,unit:u.name,summoned:slot,to:c});return;}
   return;
  }
  if(abilities&&u.id==='ogre'&&u.charge!==null){const marked=u.charge;u.charge=null;const t=units.find(v=>v.team===0&&v.hp>0&&v.cell===marked);if(t&&DIST[u.cell][marked]<=1)hit(u,t,2);return;}
  for(let ap=u.move;ap>0;ap--){
   const heroes=units.filter(v=>v.team===0&&v.hp>0);if(!heroes.length)return;
   let target=heroes[0];for(const t of heroes)if(DIST[u.cell][t.cell]<DIST[u.cell][target.cell])target=t;
   if(canHit(u,u.cell,target)){if(abilities&&u.id==='ogre'){u.charge=target.cell;preparations++;emit({action:'prepare',actor:u.slot,to:target.cell,bonus:2});}else hit(u,target);return;}
   const walls=blocked(u);let next=u.cell,best=DIST[u.cell][target.cell];
   if(options.enemyPolicy==='pathfinding'){
    const route=flood(u.cell,walls);let candidates=[];
    for(let c=0;c<42;c++)if(route.dist[c]<999&&canHit(u,c,target))candidates.push(c);
    candidates.sort((a,b)=>route.dist[a]-route.dist[b]||a-b);
    if(candidates.length){const path=pathTo(u.cell,candidates[0],route.prev);if(path.length)next=path[0];}
   }else for(const c of neighbours[u.cell])if(!walls.has(c)&&DIST[c][target.cell]<best){next=c;best=DIST[c][target.cell];}
   if(next!==u.cell)move(u,next);
  }
 }
 for(round=1;round<=limit;round++){
  for(const u of units.filter(u=>u.team===0))if(u.hp>0){heroAct(u);if(check())break;}
  if(winner)break;
  // Dynamic slots include converted soldiers; new undead wait until the next round.
  for(let i=0;i<units.length;i++)if(units[i].team===1&&units[i].hp>0&&(!abilities||units[i].spawned!==round)){enemyAct(units[i]);if(check())break;}
  if(winner)break;
 }
 return {initialUnits:options.trace?initialUnits:undefined,finalUnits:options.trace?copy(units):undefined,outcome:winner||'draw',rounds:Math.min(round,limit),moves,attacks,summons,healing,conversions,preparations,hops,survivors:units.filter(u=>u.team===0&&u.hp>0).map(u=>({id:u.id,hp:u.hp,slot:u.armySlot})),enemiesRemaining:units.filter(u=>u.team===1&&u.hp>0).length,trace};
}
const STRATEGIES={
 infantry:{name:'Infantry',families:['barracks','barracks','barracks']},
 ranged:{name:'Archers',families:['archery','archery','archery']},
 mounted:{name:'Mounted',families:['lodge','lodge','lodge']},
 casters:{name:'Casters',families:['tower','tower','tower']},
 mixed:{name:'Mixed army',families:['archery','lodge','tower']}
};
function shoppingPlan(strategy){
 const families=STRATEGIES[strategy].families,steps=[];
 for(let i=0;i<3;i++){
  if(i>0)steps.push({kind:'build',family:'chapel',level:i});
  if(families[i]!=='barracks'&&!families.slice(0,i).includes(families[i]))steps.push({kind:'build',family:families[i],level:1});
  steps.push({kind:'recruit',id:families[i]+'-'+(families[i]==='barracks'?2:1)});
 }
 const specialized=[...new Set(families)];
 for(let tier=2;tier<=3;tier++)for(const family of [...specialized.filter(f=>f!=='barracks'),'barracks']){
  if(family==='barracks'&&tier===2)continue;
  steps.push({kind:'build',family,level:tier});
  for(let slot=0;slot<5;slot++)if((slot<2?'barracks':families[slot-2])===family)steps.push({kind:'upgrade',slot,id:family+'-'+tier});
 }
 return steps;
}
function purchase(data,shop,action){
 const next=copy(shop),byId=id=>data.players.find(u=>u.id===id);let cost,label;
 if(action.kind==='build'){
  const current=next.levels[action.family]||0;
  if(action.level!==current+1)throw Error('Building levels must be bought in sequence');
  cost=action.family==='chapel'?data.chapel.costs[action.level-1]:byId(action.family+'-'+action.level).buildingCost;label=`${action.family} building level ${action.level}`;
 }else if(action.kind==='recruit'){
  const unit=byId(action.id),capacity=data.chapel.capacityByLevel[next.levels.chapel||0];
  if(!unit||next.army.filter(Boolean).length>=capacity||(next.levels[unit.family]||0)!==unit.tier)throw Error('Recruitment is locked or capacity is full');
  cost=Math.max(1,unit.recruit-((next.levels.chapel||0)===3?data.chapel.recruitDiscount:0));label=`Recruit ${unit.name}`;
 }else if(action.kind==='upgrade'){
  const old=byId(next.army[action.slot]),unit=byId(action.id);
  if(!old||!unit||old.family!==unit.family||unit.tier!==old.tier+1||(next.levels[unit.family]||0)<unit.tier)throw Error('Illegal fighter upgrade');
  cost=unit.recruit-old.recruit;label=`Upgrade slot ${action.slot+1}: ${old.name} to ${unit.name}`;
 }else throw Error('Unknown purchase');
 if(!Number.isInteger(cost)||cost<1)throw Error('Invalid price');
 if(next.gold<cost)return null;
 next.gold-=cost;
 if(action.kind==='build')next.levels[action.family]=action.level;
 else if(action.kind==='recruit'){const empty=next.army.findIndex(id=>!id),slot=action.slot??(empty<0?next.army.length:empty);if(slot<0||slot>=data.chapel.capacityByLevel[next.levels.chapel||0]||next.army[slot])throw Error('Recruit slot is unavailable');next.army[slot]=action.id;}
 else next.army[action.slot]=action.id;
 return {shop:next,event:{action:action.kind,label,cost,goldBefore:shop.gold,goldAfter:next.gold,army:next.army.slice()}};
}
function simulateCampaign(data,options={}){
 options={...(data.simulationSettings||{}),...options};
 const strategy=options.strategy||'mixed',seed=options.seed===undefined?1:options.seed,maxFights=options.maxFights||45;
 if(!STRATEGIES[strategy])throw Error('Unknown strategy');
 const errors=rules.validate(data);if(errors.length)throw Error(errors[0]);
 let state=rules.createCampaign(data);state.seed=seed>>>0;
 let shop={gold:state.gold,army:['barracks-2','barracks-2'],levels:{barracks:2,chapel:0,archery:0,lodge:0,tower:0}},plan=shoppingPlan(strategy),planIndex=0;
 const ledger=[],battles=[],events=options.trace?[]:null,replacements=[];let farming=false,blockedReason=null;const failedArmies=new Set();
 const record=event=>{if(events)events.push(event);};
 for(let fight=0;fight<maxFights;fight++){
  // Replace casualties in their original slots before continuing planned upgrades.
  while(replacements.length){
   const missing=replacements[0],tier=shop.levels[missing.family],id=missing.family+'-'+tier;
   const bought=purchase(data,shop,{kind:'recruit',id,slot:missing.slot});if(!bought)break;
   shop=bought.shop;replacements.shift();ledger.push({...bought.event,replacement:true,beforeFight:fight+1});record({type:'purchase',...bought.event,replacement:true,beforeFight:fight+1});
  }
  if(!shop.army.some(Boolean)){blockedReason='All soldiers are dead and there is not enough gold to recruit a replacement.';break;}
  while(!replacements.length&&planIndex<plan.length){const action=plan[planIndex];if(action.kind==='upgrade'){const old=data.players.find(u=>u.id===shop.army[action.slot]),target=data.players.find(u=>u.id===action.id);if(old&&old.family===target.family&&old.tier>=target.tier){planIndex++;continue;}}const bought=purchase(data,shop,action);if(!bought)break;shop=bought.shop;ledger.push({...bought.event,beforeFight:fight+1});record({type:'purchase',...bought.event,beforeFight:fight+1});planIndex++;}
  state.gold=shop.gold;
  if(options.nativeSeedCycle)state.seed&=255;
  let region=state.wins.findIndex((w,r)=>w<rules.progression(data).winsRequired[r]);
  if(region<0)break;
  let attemptedRegion=region;
  let practice=false;
  if(farming){
   if(data.endlessLairs)attemptedRegion=Math.max(0,region-1);
   else if(options.earlyPractice&&state.wins[0]>0){practice=true;attemptedRegion=0;}
   else if(region===0){blockedReason='Opening region cannot be cleared with this purchase path; no cleared region is available to farm.';break;}
   else attemptedRegion=region-1;
  }
  if(practice){const e=rules.generate(data,0,0,state.seed);e.reward=options.practiceReward??20;e.replay=true;state.pending={regionIndex:0,encounter:e};}
  else state=rules.beginEncounter(data,state,attemptedRegion);
  const encounter=copy(state.pending.encounter),before=copy(shop);
  const battle=simulateBattle(data,shop.army,encounter,{trace:options.trace,playerPolicy:options.playerPolicy,enemyPolicy:options.enemyPolicy,maxRounds:options.maxRounds});
  const entry={fight:fight+1,region:attemptedRegion,regionName:encounter.region,stage:encounter.stage,variant:encounter.variant,seed:encounter.seed,enemies:encounter.enemies.map(u=>u.id),replay:encounter.replay||(data.endlessLairs&&state.wins[attemptedRegion]>=rules.progression(data).winsRequired[attemptedRegion]),army:before.army,goldBefore:before.gold,...battle};
  if(data.permanentCasualties){
   const living=new Set(battle.survivors.map(u=>u.slot));entry.casualties=[];
   for(let slot=0;slot<shop.army.length;slot++)if(shop.army[slot]&&!living.has(slot)){
    const id=shop.army[slot],unit=data.players.find(u=>u.id===id);entry.casualties.push({slot,id});replacements.push({slot,family:unit.family});shop.army[slot]=null;
   }
  }
  if(battle.outcome==='victory'){
   state=rules.recordResult(data,state,'victory');shop.gold=state.gold;entry.reward=encounter.reward;farming=false;
  }else{
   state=rules.recordResult(data,state,'defeat');state=rules.recordResult(data,state,'retreat');entry.reward=0;
   if(farming){blockedReason='The fallback replay is also unwinnable with this army.';battles.push(entry);record({type:'battle',...entry,goldAfter:shop.gold});break;}
   const failureKey=JSON.stringify([shop.army,encounter.enemies.map(u=>u.id)]);
   if(planIndex>=plan.length&&failedArmies.has(failureKey)){blockedReason='This fully upgraded party repeatedly loses the same enemy group; further farming cannot upgrade it.';battles.push(entry);record({type:'battle',...entry,goldAfter:shop.gold});break;}
   failedArmies.add(failureKey);farming=true;
  }
  entry.goldAfter=shop.gold;battles.push(entry);record({type:'battle',...entry});
  if(state.wins.every((w,r)=>w>=rules.progression(data).winsRequired[r]))break;
 }
 const completed=state.wins.every((w,r)=>w>=rules.progression(data).winsRequired[r]);
 return {strategy,seed,completed,wins:state.wins,fights:battles.length,victories:battles.filter(b=>b.outcome==='victory').length,defeats:battles.filter(b=>b.outcome==='defeat').length,draws:battles.filter(b=>b.outcome==='draw').length,replays:battles.filter(b=>b.replay).length,rounds:battles.reduce((n,b)=>n+b.rounds,0),gold:shop.gold,earned:battles.reduce((n,b)=>n+(b.reward||0),0),spent:ledger.reduce((n,e)=>n+e.cost,0),army:shop.army,levels:shop.levels,blockedReason:completed?null:blockedReason||'Fight budget reached.',ledger:options.trace?ledger:undefined,battles:options.trace?battles:battles.map(({trace,...b})=>b),events};
}
function summarize(runs){
 return Object.keys(STRATEGIES).map(strategy=>{const group=runs.filter(r=>r.strategy===strategy),n=group.length;if(!n)return null;
 const mean=k=>group.reduce((s,r)=>s+r[k],0)/n;
 return {strategy,name:STRATEGIES[strategy].name,runs:n,completed:group.filter(r=>r.completed).length,completionRate:group.filter(r=>r.completed).length/n,meanFights:mean('fights'),meanReplays:mean('replays'),meanDefeats:mean('defeats'),meanDraws:mean('draws'),meanRounds:mean('rounds'),meanGold:mean('gold'),meanSpent:mean('spent'),reached:group.reduce((out,r)=>out.map((v,i)=>v+(r.wins[i]>0?1:0)),[0,0,0,0]),failures:group.filter(r=>!r.completed).reduce((out,r)=>{out[r.blockedReason]=(out[r.blockedReason]||0)+1;return out;},{})};}).filter(Boolean);
}
const api={simulateBattle,simulateCampaign,summarize,purchase,shoppingPlan,strategies:STRATEGIES,distance,clear,neighbours};
if(typeof module!=='undefined'&&module.exports)module.exports=api;else root.GreenhavenSimulation=api;
})(typeof window!=='undefined'?window:globalThis);
