'use strict';
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto');
const root=path.resolve(__dirname,'..'),sim=require('../simulation/campaign-sim.js'),config=require('../greenhaven-unit-balance.json');
const difficulty=require('../difficulty.json');
// Levels differ only in enemy groups (Easy enemies, Medium/Hard mediumEnemies/hardEnemies)
// plus the native gold transform: starting gold, and each table reward +/- reward>>n.
const level=l=>d=>{d.startingGold=l.startingGold;const r=x=>l.rewardShift>0?x+(x>>l.rewardShift):l.rewardShift<0?x-(x>>-l.rewardShift):x;for(const g of d.encounterConfig.regions){g.replayReward=r(g.replayReward);for(const s of g.stages)s.reward=r(s.reward);}};
const experiments=difficulty.levels.map((l,i)=>({id:'difficulty-'+l.name.toLowerCase(),difficulty:i,description:`${l.name}: starting gold ${l.startingGold}, reward shift ${l.rewardShift}; ${['Easy','Medium','Hard'][i]} enemy groups`,edit:level(l)}));
const result={title:'Prince and the Nymph',credit:'Author: astrofor',configHash:crypto.createHash('sha256').update(JSON.stringify(config)).digest('hex'),model:'Five fixed shopping/tactical bots, all 256 native encounter seeds. Completion frequencies are not human win rates. Native campaign execution is checked separately. Failed rigid purchase plans do not prove a human softlock.',experiments:[]};
for(const experiment of experiments){
 const data=structuredClone(config);experiment.edit(data);const runs=[];
 for(const strategy of Object.keys(sim.strategies))for(let seed=0;seed<256;seed++)runs.push(sim.simulateCampaign(data,{strategy,seed,difficulty:experiment.difficulty}));
 const summary=sim.summarize(runs).map(s=>({...s,gameOvers:runs.filter(r=>r.strategy===s.strategy&&r.gameOver).length,strategyStops:runs.filter(r=>r.strategy===s.strategy&&!r.completed&&!r.gameOver).length}));
 result.experiments.push({id:experiment.id,description:experiment.description,summary});
 console.log(experiment.id,summary.map(s=>`${s.strategy}: ${s.completed}/${s.runs}`).join(' | '));
}
// Guard rail: each level must be no easier than the one before it for the fixed bots.
const all=id=>result.experiments.find(e=>e.id===id).summary.map(x=>x.completionRate);
const mean=id=>all(id).reduce((a,b)=>a+b,0)/all(id).length;
const means=difficulty.levels.map(l=>mean('difficulty-'+l.name.toLowerCase()));
if(!(means[0]>=means[1]&&means[1]>=means[2]))throw Error('Difficulty levels are out of order: '+means.join(' / '));
result.difficulty={levels:difficulty.levels,meanPlanCompletion:Object.fromEntries(difficulty.levels.map((l,i)=>[l.name.toLowerCase(),means[i]]))};
result.decision='Stats come from the playtested editor balance. Difficulty changes only the enemy groups. The fixed bots never farm or adapt per region, so their completion rates understate a human player; use them to compare levels, not as win rates.';
fs.writeFileSync(path.join(__dirname,'balance-audit.json'),JSON.stringify(result,null,2)+'\n');

// Native replays run at the game's default level.
const options=strategy=>({strategy,seed:1,difficulty:difficulty.default,trace:true});
for(const [name,strategy] of [['native-campaign-plan','ranged'],['native-defeat-plan','mounted']])fs.writeFileSync(path.join(__dirname,name+'.json'),JSON.stringify({config,options:options(strategy),run:sim.simulateCampaign(config,options(strategy))},null,2)+'\n');
