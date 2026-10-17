/* Browser controls for the stats-only simulator. Results never change the editor draft. */
(function(root){
'use strict';
function mount(getData,getErrors){
 const sim=root.GreenhavenSimulation,host=document.getElementById('campaign-simulator');
 if(!host)return;
 const make=(tag,text)=>{const n=document.createElement(tag);if(text!==undefined)n.textContent=text;return n;};
 const intro=make('p','Simulate buying, building upgrades, fighter upgrades, random encounters and tactical hex moves using a copy of the current editor values. Surviving fighters recover HP after battle. Killed or converted soldiers are permanently lost; replacements must be bought. Purchases follow fixed strategies; these are bot outcomes, not measured human win rates.');intro.className='note';host.append(intro);
 const bar=make('div');bar.className='encounter-bar';
 const strategy=make('select');strategy.setAttribute('aria-label','Simulation strategy');for(const [id,v] of Object.entries(sim.strategies)){const o=make('option',v.name);o.value=id;strategy.append(o);}strategy.value='mixed';
 const seed=make('input');seed.type='number';seed.min=0;seed.max=4294967295;seed.step=1;seed.value=1;seed.setAttribute('aria-label','Simulation starting seed');
 const count=make('input');count.type='number';count.min=1;count.max=200;count.step=1;count.value=50;count.setAttribute('aria-label','Simulation seeds per strategy');
 const candidateLabel=make('label'),candidate=make('input');candidate.type='checkbox';candidateLabel.append(candidate,document.createTextNode(' Test without monster abilities'));
 const once=make('button','Run one campaign'),compare=make('button','Compare abilities on/off'),download=make('button','Export simulation JSON');download.disabled=true;
 bar.append(strategy,make('label','Seed'),seed,make('label','Seeds per strategy'),count,candidateLabel,once,compare,download);host.append(bar);
 const status=make('p','Ready. One campaign shows every purchase, encounter and tactical action. Comparison runs five shopping strategies against both configurations.');status.className='note';status.setAttribute('role','status');status.setAttribute('aria-live','polite');host.append(status);
 const result=make('div');result.className='note';host.append(result);let lastResult=null,running=false;
 const snapshot=()=>JSON.parse(JSON.stringify(getData()));
 const modified=data=>{const d=JSON.parse(JSON.stringify(data));d.monsterAbilitiesVersion=0;return d;};
 const options=()=>({earlyPractice:true,practiceReward:20});
 function valid(){const errors=getErrors();if(errors.length)throw Error('Fix the editor configuration first: '+errors[0]);if(!seed.validity.valid||!count.validity.valid||seed.value===''||count.value==='')throw Error('Use an integer seed and 1–200 seeds per strategy.');}
 function busy(value){running=value;once.disabled=compare.disabled=value;download.disabled=value||!lastResult;}
 function table(headers,rows){const wrap=make('div');wrap.className='table-wrap';const t=make('table'),h=make('thead'),tr=make('tr'),body=make('tbody');for(const x of headers)tr.append(make('th',x));h.append(tr);for(const row of rows){const r=body.insertRow();for(const x of row)r.insertCell().textContent=x;}t.append(h,body);wrap.append(t);return wrap;}
 function showCampaign(run,data){
  result.replaceChildren();
  result.append(make('h3',`${sim.strategies[run.strategy].name} · seed ${run.seed} · ${run.completed?'Campaign completed':'Campaign stopped'}`),make('p',`${run.fights} fights, ${run.defeats} defeats, ${run.draws} round-limit draws, ${run.replays} practice/replay fights. Gold ${data.startingGold} start + ${run.earned} earned − ${run.spent} spent = ${run.gold} remaining.`));
  if(run.blockedReason)result.append(make('p',run.blockedReason));
  result.append(make('p','Wins by region: '+run.wins.join(' / ')+'. Final army: '+run.army.map(id=>id?data.players.find(u=>u.id===id).name:'Empty slot').join(', ')));
  for(const event of run.events){
   if(event.type==='purchase'){result.append(make('p',`Before fight ${event.beforeFight}: ${event.replacement?'Replacement: ':''}${event.label}, ${event.cost} gold (${event.goldBefore} → ${event.goldAfter}).`));continue;}
   const detail=make('details');detail.append(make('summary',`Fight ${event.fight}: ${event.regionName}, stage ${event.stage}${event.replay?' practice/replay':''} — ${event.outcome}; ${event.rounds} rounds; +${event.reward} gold; balance ${event.goldAfter}`));
   detail.append(make('p',`Seed ${event.seed}. Enemies: ${event.enemies.join(', ')}. Army: ${event.army.map(id=>id?data.players.find(u=>u.id===id).name:'Empty slot').join(', ')}.`));
   if(event.casualties?.length)detail.append(make('p','Permanently lost: '+event.casualties.map(c=>`${data.players.find(u=>u.id===c.id).name} (slot ${c.slot+1})`).join(', ')+'.'));
   detail.append(table(['Round','Fighter','Action','Detail'],event.trace.map(e=>[e.round,e.unit||`Unit ${e.actor+1}`,e.action,e.action==='move'?`hex ${e.from} → ${e.to}`:e.action==='attack'?`${e.targetName}: ${e.hpBefore} → ${e.hpAfter} HP`:e.action==='summon'?`Undead at hex ${e.to}`:e.action==='heal'?`+${e.amount} HP`:e.action==='raise'?`Soldier ${e.target} becomes a 2 HP zombie`:e.action==='prepare'?`Heavy strike targets hex ${e.to}`:e.action==='hop'?`Retreat to hex ${e.to}`:e.reason||''])));
   result.append(detail);
  }
 }
 once.addEventListener('click',()=>{
  if(running)return;
  try{valid();busy(true);status.textContent='Simulating campaign…';const data=candidate.checked?modified(snapshot()):snapshot(),opts=candidate.checked?options():{};
   const run=sim.simulateCampaign(data,{strategy:strategy.value,seed:Number(seed.value),trace:true,...opts});lastResult={model:'stats-only bot simulation',config:data,options:opts,run};showCampaign(run,data);status.textContent='Simulation complete. Active editor values were kept.';
  }catch(error){status.textContent=error.message;}finally{busy(false);}
 });
 compare.addEventListener('click',async()=>{
  if(running)return;
  try{valid();busy(true);const data=snapshot(),n=Number(count.value),start=Number(seed.value),runs=[],total=n*10;let done=0;
   for(const variant of ['current','candidate'])for(const id of Object.keys(sim.strategies))for(let i=0;i<n;i++){
    const run=sim.simulateCampaign(variant==='candidate'?modified(data):data,{strategy:id,seed:(start+i)>>>0,...(variant==='candidate'?options():{})});
    const {battles,events,...compact}=run;runs.push({variant,...compact});done++;
    if(done%5===0){status.textContent=`Simulated ${done} / ${total} campaigns…`;await new Promise(resolve=>setTimeout(resolve,0));}
   }
   const summaries=['current','candidate'].flatMap(variant=>sim.summarize(runs.filter(r=>r.variant===variant)).map(r=>({variant,...r})));
   lastResult={model:'stats-only bot simulation',config:data,candidateChanges:{monsterAbilitiesVersion:0},seedStart:start,seedsPerStrategy:n,summaries,runs};result.replaceChildren();result.append(table(['Configuration','Strategy','Completed','Mean fights','Mean replays','Mean defeats','Mean draws'],summaries.map(r=>[r.variant==='current'?'Abilities on':'Abilities off',r.name,`${r.completed}/${r.runs} (${(r.completionRate*100).toFixed(1)}%)`,r.meanFights.toFixed(1),r.meanReplays.toFixed(1),r.meanDefeats.toFixed(1),r.meanDraws.toFixed(1)])));
   status.textContent=`Finished ${total} campaigns. Compared the current rules with classic monster behavior. Both use the same prices, stats and practice rewards. Editor values were kept.`;
  }catch(error){status.textContent=error.message;}finally{busy(false);}
 });
 download.addEventListener('click',()=>{if(!lastResult)return;const url=URL.createObjectURL(new Blob([JSON.stringify(lastResult,null,2)+'\n'],{type:'application/json'})),a=make('a');a.href=url;a.download='greenhaven-simulation.json';document.body.append(a);a.click();a.remove();setTimeout(()=>URL.revokeObjectURL(url),1000);});
}
root.GreenhavenSimulationUI={mount};
})(window);
