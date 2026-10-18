'use strict';
const fs=require('node:fs'),path=require('node:path'),sim=require('./campaign-sim.js');
const output=path.resolve(process.argv[2]||path.join(__dirname,'results-abilities'));fs.mkdirSync(output,{recursive:true});
const config=require('../greenhaven-unit-balance.json'),runs=[],examples=[];
for(const enabled of [false,true]){
 const data=JSON.parse(JSON.stringify(config));data.monsterAbilitiesVersion=enabled?1:0;
 for(const strategy of Object.keys(sim.strategies)){
  for(let seed=0;seed<256;seed++){
   const run=sim.simulateCampaign(data,{strategy,seed,trace:enabled&&seed===1});
   if(enabled&&seed===1)examples.push(run);
   const metrics={healing:0,conversions:0,preparations:0,hops:0,summons:0};for(const battle of run.battles)for(const k of Object.keys(metrics))metrics[k]+=battle[k];
   const {battles,events,ledger,...compact}=run;runs.push({abilities:enabled,...compact,...metrics});
  }
  console.log(enabled?'Abilities on':'Abilities off',strategy,sim.summarize(runs.filter(r=>r.abilities===enabled&&r.strategy===strategy))[0].completionRate);
 }
}
const summaries=[false,true].flatMap(enabled=>sim.summarize(runs.filter(r=>r.abilities===enabled)).map(s=>({abilities:enabled,...s})));
const payload={model:'Stats-only fixed shopping bots; native-style greedy enemy AI; all 256 native starting seeds; permanent casualties; surviving fighters recover HP; paid replacements; not hardware execution or measured human win rates.',config,summaries,runs,examples};
fs.writeFileSync(path.join(output,'monster-abilities-results.json'),JSON.stringify(payload,null,2)+'\n');
const esc=s=>String(s).replaceAll('&','&amp;').replaceAll('<','&lt;').replaceAll('>','&gt;');
const rows=summaries.map(s=>`<tr><td>${s.abilities?'On':'Off (old monster rules)'}</td><td>${s.name}</td><td>${s.completed}/${s.runs} (${(s.completionRate*100).toFixed(1)}%)</td><td>${s.meanFights.toFixed(1)}</td><td>${s.meanDefeats.toFixed(1)}</td><td>${s.meanReplays.toFixed(1)}</td></tr>`).join('');
const examplesHTML=examples.map(r=>`<details><summary>${sim.strategies[r.strategy].name}, seed ${r.seed}: ${r.completed?'completed':'stopped'} after ${r.fights} fights</summary><p>Gold: 50 + ${r.earned} earned − ${r.spent} spent = ${r.gold}. ${esc(r.blockedReason||'')}</p><h3>Purchases</h3><pre>${esc(JSON.stringify(r.ledger,null,2))}</pre>${r.battles.map(b=>`<details><summary>${b.regionName} ${b.stage}: ${b.outcome}, ${b.rounds} rounds, +${b.reward} gold</summary><pre>${esc(JSON.stringify(b,null,2))}</pre></details>`).join('')}</details>`).join('');
const totals=runs.filter(r=>r.abilities).reduce((a,r)=>{for(const k of Object.keys(a))a[k]+=r[k];return a;},{healing:0,conversions:0,preparations:0,hops:0,summons:0});
const html=`<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width"><title>VBXE v3 monster ability simulation</title><style>body{font:16px/1.5 system-ui;background:#101b19;color:#e6efdf;max-width:1100px;margin:30px auto;padding:20px}a{color:#aee5c2}table{width:100%;border-collapse:collapse}td,th{text-align:left;padding:10px;border-bottom:1px solid #466052}details{border:1px solid #466052;padding:12px;margin:10px 0}summary{cursor:pointer}pre{white-space:pre-wrap;font-size:12px;max-height:600px;overflow:auto}</style><h1>VBXE v3: monster abilities</h1><p>2,560 simulated campaigns: five shopping strategies × 256 starting seeds × abilities on/off. Benchmark target: reach three victories in each lair; the actual game continues indefinitely. Both configurations use permanent casualties, paid replacements, identical prices, stats, weighted pools, unlocks and endless escalating lairs.</p><p>${esc(payload.model)} These results replace the older simulation report for v3. Native ability behavior is checked separately by executing the assembled 6502 code on both supported VBXE register pages.</p><p><a href="heroes-vbxe-v3.xex">Download v3 game</a> · <a href="greenhaven-balance-editor.html">Open editor</a> · <a href="monster-abilities-results.json">Full results JSON</a></p><table><thead><tr><th>Abilities</th><th>Buying strategy</th><th>Completed</th><th>Mean fights</th><th>Mean defeats</th><th>Mean return visits</th></tr></thead><tbody>${rows}</tbody></table><h2>Ability activity across 1,280 campaigns</h2><pre>${esc(JSON.stringify(totals,null,2))}</pre><p>Vampire uses the Dark artwork. Zombie kills create 2 HP undead next round, capped at two conversions, without chain conversion. Skeletons resist arrows. Ogres prepare a marked-cell strike. Imps hop after attacks. Warlocks summon at most two living skeletons from round 2, which act next round.</p><h2>Five complete example logs</h2>${examplesHTML}</html>`;
fs.writeFileSync(path.join(output,'monster-abilities-report.html'),html);
console.log(JSON.stringify(summaries.map(s=>({abilities:s.abilities,strategy:s.strategy,rate:s.completionRate})),null,2));
