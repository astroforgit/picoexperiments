'use strict';
const fs=require('node:fs'),path=require('node:path'),sim=require('./campaign-sim.js');
const args=process.argv.slice(2),arg=(name,fallback)=>{const i=args.indexOf(name);return i<0?fallback:args[i+1];};
const source=path.resolve(arg('--config',path.join(__dirname,'../greenhaven-unit-balance.json'))),data=JSON.parse(fs.readFileSync(source));
const candidate=arg('--candidate','none');
if(!['none','practice','cavalry'].includes(candidate))throw Error('--candidate must be none, practice or cavalry');
const options={...(data.simulationSettings||{}),strategy:arg('--strategy','mixed'),seed:Number(arg('--seed','1')),trace:true};
if(!Number.isInteger(options.seed)||options.seed<0||options.seed>4294967295)throw Error('Seed must be an unsigned 32-bit integer');
if(candidate!=='none'){options.earlyPractice=true;options.practiceReward=20;data.enemies.find(u=>u.id==='demon').hp=3;}
if(candidate==='cavalry')data.players.find(u=>u.id==='lodge-3').damage=3;
const run=sim.simulateCampaign(data,options),text=JSON.stringify({config:data,options,run},null,2)+'\n',output=arg('--output','');
if(output){fs.writeFileSync(path.resolve(output),text);console.log(`${run.strategy}, seed ${run.seed}: ${run.completed?'completed':'stopped'}, ${run.fights} fights, ${run.spent} gold spent, ${run.gold} remaining. Trace saved to ${output}`);}else process.stdout.write(text);
