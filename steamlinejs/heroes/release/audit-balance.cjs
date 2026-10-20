'use strict';
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto');
const root=path.resolve(__dirname,'..'),sim=require('../simulation/campaign-sim.js'),config=require('../greenhaven-unit-balance.json');
const difficulty=require('../difficulty.json');
// Same transform as the native game: starting gold, and each table reward +/- reward>>n.
const level=l=>d=>{d.startingGold=l.startingGold;const r=x=>l.rewardShift>0?x+(x>>l.rewardShift):l.rewardShift<0?x-(x>>-l.rewardShift):x;for(const g of d.encounterConfig.regions){g.replayReward=r(g.replayReward);for(const s of g.stages)s.reward=r(s.reward);}};
const experiments=[{id:'release',description:'Current release, unchanged unit/economy values (MEDIUM difficulty)',edit:()=>{}},
 ...difficulty.levels.filter((_,i)=>i!==1).map(l=>({id:'difficulty-'+l.name.toLowerCase(),description:`${l.name}: starting gold ${l.startingGold}, reward shift ${l.rewardShift}; enemies unchanged`,edit:level(l)})),{id:'scout-experiment',description:'Review only: Scout HP4 and damage2; not adopted',edit:d=>Object.assign(d.players.find(u=>u.id==='lodge-1'),{hp:4,damage:2})}];
const result={title:'Prince and the Nimf',credit:'Everything by astrofor',configHash:crypto.createHash('sha256').update(JSON.stringify(config)).digest('hex'),model:'Five fixed shopping/tactical bots, all 256 native encounter seeds. Completion frequencies are not human win rates. Native campaign execution is checked separately. Failed rigid purchase plans do not prove a human softlock.',experiments:[]};
for(const experiment of experiments){
 const data=structuredClone(config);experiment.edit(data);const runs=[];
 for(const strategy of Object.keys(sim.strategies))for(let seed=0;seed<256;seed++)runs.push(sim.simulateCampaign(data,{strategy,seed}));
 const summary=sim.summarize(runs).map(s=>({...s,gameOvers:runs.filter(r=>r.strategy===s.strategy&&r.gameOver).length,strategyStops:runs.filter(r=>r.strategy===s.strategy&&!r.completed&&!r.gameOver).length}));
 result.experiments.push({id:experiment.id,description:experiment.description,summary});
 console.log(experiment.id,summary.map(s=>`${s.strategy}: ${s.completed}/${s.runs}`).join(' | '));
}
// Guard rails: Easy must be clearly kinder than Medium without being automatic for every
// plan; Hard must stay winnable for the best fixed plans.
const best=id=>Math.max(...result.experiments.find(e=>e.id===id).summary.map(x=>x.completionRate));
const all=id=>result.experiments.find(e=>e.id===id).summary.map(x=>x.completionRate);
const mean=id=>all(id).reduce((a,b)=>a+b,0)/all(id).length;
if(!(best('difficulty-easy')>=0.9&&mean('difficulty-easy')>mean('release')&&all('difficulty-easy').some(x=>x<0.9)))throw Error('EASY difficulty out of range');
if(!(best('difficulty-hard')>=0.15&&best('difficulty-hard')<best('release')&&mean('difficulty-hard')<mean('release')))throw Error('HARD difficulty out of range');
result.difficulty={levels:difficulty.levels,bestPlanCompletion:{easy:best('difficulty-easy'),medium:best('release'),hard:best('difficulty-hard')},meanPlanCompletion:{easy:mean('difficulty-easy'),medium:mean('release'),hard:mean('difficulty-hard')}};
result.decision='Keep existing game prices/stats. The Scout buff fails to resolve the weak fixed buying plans and would narrow the difference from Ranger. A full native ranged campaign passes without free troops, injected gold or forced victories. Recommend keeping replacement money and treating early expensive specialization as a risk. Further human balance testing remains valuable.';
fs.writeFileSync(path.join(__dirname,'balance-audit.json'),JSON.stringify(result,null,2)+'\n');

for(const [name,strategy] of [['native-campaign-plan','ranged'],['native-defeat-plan','mounted']])fs.writeFileSync(path.join(__dirname,name+'.json'),JSON.stringify({config,options:{strategy,seed:1,trace:true},run:sim.simulateCampaign(config,{strategy,seed:1,trace:true})},null,2)+'\n');
