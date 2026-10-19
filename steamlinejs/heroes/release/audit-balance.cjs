'use strict';
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto');
const root=path.resolve(__dirname,'..'),sim=require('../simulation/campaign-sim.js'),config=require('../greenhaven-unit-balance.json');
const experiments=[{id:'release',description:'Current release, unchanged unit/economy values',edit:()=>{}},{id:'scout-experiment',description:'Review only: Scout HP4 and damage2; not adopted',edit:d=>Object.assign(d.players.find(u=>u.id==='lodge-1'),{hp:4,damage:2})}];
const result={title:'Prince and the Nimf',credit:'Everything by astrofor',configHash:crypto.createHash('sha256').update(JSON.stringify(config)).digest('hex'),model:'Five fixed shopping/tactical bots, all 256 native encounter seeds. Completion frequencies are not human win rates. Native campaign execution is checked separately. Failed rigid purchase plans do not prove a human softlock.',experiments:[]};
for(const experiment of experiments){
 const data=structuredClone(config);experiment.edit(data);const runs=[];
 for(const strategy of Object.keys(sim.strategies))for(let seed=0;seed<256;seed++)runs.push(sim.simulateCampaign(data,{strategy,seed}));
 const summary=sim.summarize(runs).map(s=>({...s,gameOvers:runs.filter(r=>r.strategy===s.strategy&&r.gameOver).length,strategyStops:runs.filter(r=>r.strategy===s.strategy&&!r.completed&&!r.gameOver).length}));
 result.experiments.push({id:experiment.id,description:experiment.description,summary});
 console.log(experiment.id,summary.map(s=>`${s.strategy}: ${s.completed}/${s.runs}`).join(' | '));
}
result.decision='Keep existing game prices/stats. The Scout buff fails to resolve the weak fixed buying plans and would narrow the difference from Ranger. A full native ranged campaign passes without free troops, injected gold or forced victories. Recommend keeping replacement money and treating early expensive specialization as a risk. Further human balance testing remains valuable.';
fs.writeFileSync(path.join(__dirname,'balance-audit.json'),JSON.stringify(result,null,2)+'\n');

for(const [name,strategy] of [['native-campaign-plan','ranged'],['native-defeat-plan','mounted']])fs.writeFileSync(path.join(__dirname,name+'.json'),JSON.stringify({config,options:{strategy,seed:1,trace:true},run:sim.simulateCampaign(config,{strategy,seed:1,trace:true})},null,2)+'\n');
