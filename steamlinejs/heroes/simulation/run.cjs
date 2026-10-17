'use strict';
const fs=require('node:fs'),path=require('node:path'),sim=require('./campaign-sim.js');
const args=process.argv.slice(2),arg=(name,fallback)=>{const i=args.indexOf(name);return i<0?fallback:args[i+1];};
const count=Number(arg('--seeds','200')),output=path.resolve(arg('--output',path.join(__dirname,'results'))),source=path.resolve(arg('--config',path.join(__dirname,'../greenhaven-unit-balance.json')));
if(!Number.isInteger(count)||count<1||count>10000)throw Error('--seeds must be 1-10000');
const data=JSON.parse(fs.readFileSync(source)),clone=x=>JSON.parse(JSON.stringify(x));
const experiments=[
 {id:'baseline',name:'Current editor preset',data},
 {id:'early-practice',name:'Replay the cleared opening encounter for 20 gold at any later point',data,options:{earlyPractice:true,practiceReward:20}},
 {id:'scout-hp',name:'Scout HP 3 to 4',data:(()=>{const d=clone(data);d.players.find(u=>u.id==='lodge-1').hp=4;return d;})()},
 {id:'scout-damage',name:'Scout damage 1 to 2',data:(()=>{const d=clone(data);d.players.find(u=>u.id==='lodge-1').damage=2;return d;})()},
 {id:'cheap-fourth-slot',name:'Fourth slot cost 40 to 15',data:(()=>{const d=clone(data);d.chapel.costs[0]=15;return d;})()},
 {id:'practice-demon3',name:'Early practice plus Demon HP 4 to 3 (candidate)',data:(()=>{const d=clone(data);d.enemies.find(u=>u.id==='demon').hp=3;return d;})(),options:{earlyPractice:true,practiceReward:20}},
 {id:'candidate-pathfinding',name:'Candidate with pathfinding enemy AI',data:(()=>{const d=clone(data);d.enemies.find(u=>u.id==='demon').hp=3;return d;})(),options:{earlyPractice:true,practiceReward:20,enemyPolicy:'pathfinding'}},
 {id:'candidate-cavalry3',name:'Early practice, Demon HP 3, Cavalry damage 3',data:(()=>{const d=clone(data);d.enemies.find(u=>u.id==='demon').hp=3;d.players.find(u=>u.id==='lodge-3').damage=3;return d;})(),options:{earlyPractice:true,practiceReward:20}},
 {id:'candidate-cavalry3-pathfinding',name:'Cavalry candidate with pathfinding enemy AI',data:(()=>{const d=clone(data);d.enemies.find(u=>u.id==='demon').hp=3;d.players.find(u=>u.id==='lodge-3').damage=3;return d;})(),options:{earlyPractice:true,practiceReward:20,enemyPolicy:'pathfinding'}},
 {id:'enemy-pathfinding',name:'Current preset with pathfinding enemy AI (sensitivity check)',data,options:{enemyPolicy:'pathfinding'}},
 {id:'practice-pathfinding',name:'Early practice with pathfinding enemy AI',data,options:{earlyPractice:true,practiceReward:20,enemyPolicy:'pathfinding'}},
 {id:'practice-reckless',name:'Early practice with less careful player movement',data,options:{earlyPractice:true,practiceReward:20,playerPolicy:'reckless'}}
];
fs.mkdirSync(output,{recursive:true});fs.writeFileSync(path.join(output,'config.json'),JSON.stringify(data,null,2)+'\n');
const results=[];
const selectedExperiments=experiments.filter(e=>!arg('--only','')||arg('--only','').split(',').includes(e.id));if(!selectedExperiments.length)throw Error('No matching experiment IDs');
for(const experiment of selectedExperiments){const runs=[];for(const strategy of Object.keys(sim.strategies))for(let seed=1;seed<=count;seed++)runs.push(sim.simulateCampaign(experiment.data,{strategy,seed,...experiment.options}));
 const summary=sim.summarize(runs),compact=runs.map(({battles,events,...run})=>run);
 const result={id:experiment.id,name:experiment.name,options:experiment.options||{},summary,runs:compact};results.push(result);fs.writeFileSync(path.join(output,experiment.id+'.json'),JSON.stringify(result,null,2)+'\n');
 console.log(experiment.id,summary.map(r=>`${r.strategy}: ${(100*r.completionRate).toFixed(1)}% (${r.meanFights.toFixed(1)} fights, ${r.meanReplays.toFixed(1)} replays)`).join(' | '));
}
const examples=[];for(const strategy of Object.keys(sim.strategies))for(const id of ['baseline','practice-demon3']){const e=experiments.find(e=>e.id===id);const failed=results.find(e=>e.id==='baseline')?.runs.find(r=>r.strategy===strategy&&!r.completed);const seed=failed?.seed||1;examples.push({experiment:id,...sim.simulateCampaign(e.data,{strategy,seed,...e.options,trace:true})});}
const candidate=clone(data);candidate.enemies.find(u=>u.id==='demon').hp=3;candidate.preset='simulation-candidate-practice-demon3';candidate.simulationSettings={earlyPractice:true,practiceReward:20};fs.writeFileSync(path.join(output,'candidate.json'),JSON.stringify(candidate,null,2)+'\n');
const payload={source,count,model:'7x6 hex individual combat; fixed damage; native-style enemy movement; player bot with pathfinding and focus fire; full army recovery; exact editor unit prices, building gates, unlock thresholds, weighted encounters and rewards',results:results.map(({runs,...r})=>r),examples};
fs.writeFileSync(path.join(output,'summary.json'),JSON.stringify(payload,null,2)+'\n');
fs.writeFileSync(path.join(output,'examples.json'),JSON.stringify(examples,null,2)+'\n');
const columns=['experiment','strategy','runs','completed','completionRate','meanFights','meanReplays','meanDefeats','meanDraws','meanRounds','meanGold','meanSpent'];
fs.writeFileSync(path.join(output,'summary.csv'),columns.join(',')+'\n'+results.flatMap(e=>e.summary.map(r=>columns.map(k=>k==='experiment'?e.id:r[k]).join(','))).join('\n')+'\n');
