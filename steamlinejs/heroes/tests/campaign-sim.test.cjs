'use strict';
const assert=require('node:assert/strict'),fs=require('node:fs');
const sim=require('../simulation/campaign-sim.js'),rules=require('../editor-balance.js'),data=require('../greenhaven-unit-balance.json');
const clone=x=>JSON.parse(JSON.stringify(x));
const generated=fs.readFileSync(__dirname+'/../atari/city/generated/battle-content.inc','utf8');
const table=generated.match(/^distance_table dta ([^\n]+)/m)[1].split(',').map(Number);
for(let a=0;a<42;a++)for(let b=0;b<42;b++){assert.equal(sim.distance(a,b),table[a*42+b]&127);assert.equal(sim.clear(a,b,new Set([10,31])),!(table[a*42+b]&128));}
let encounter={enemies:[{...data.enemies.find(u=>u.id==='minibeast'),cell:1}],terrain:[10,31],playerCells:[0]};
let battle=sim.simulateBattle(data,['barracks-2'],encounter,{trace:true});assert.equal(battle.outcome,'victory');assert.equal(battle.rounds,2);assert.equal(battle.survivors[0].hp,3);
for(const event of battle.trace.filter(e=>e.action==='attack'))assert.equal(event.hpBefore-event.hpAfter,event.damage);
const bossData=clone(data);bossData.players[0].shootRange=9;bossData.players[0].damage=99;
encounter={enemies:[{...data.enemies.find(u=>u.id==='warlock'),cell:6},{...data.enemies[0],cell:34}],terrain:[10,31],playerCells:[0]};
battle=sim.simulateBattle(bossData,['barracks-1'],encounter,{trace:true});assert.equal(battle.outcome,'victory');assert.equal(battle.enemiesRemaining,1);
const slow=clone(data);slow.players[0].hp=99;slow.players[0].damage=1;slow.enemies.find(u=>u.id==='warlock').hp=99;
encounter={enemies:[{...slow.enemies.find(u=>u.id==='warlock'),cell:6}],terrain:[10,31],playerCells:[28]};
battle=sim.simulateBattle(slow,['barracks-1'],encounter,{trace:true,maxRounds:6});assert(battle.summons>0);assert(battle.finalUnits.length<=12);
assert(battle.trace.some(e=>e.action==='summon'));const firstSummon=battle.trace.find(e=>e.action==='summon');assert(battle.trace.some(e=>e.actor===firstSummon.summoned&&e.round>firstSummon.round));
let shop={gold:50,army:['barracks-2','barracks-2'],levels:{barracks:2,chapel:0,archery:0,lodge:0,tower:0}};
const bought=sim.purchase(data,shop,{kind:'recruit',id:'barracks-2'});assert.equal(bought.shop.gold,25);assert.equal(shop.gold,50);assert.equal(bought.shop.army.length,3);
assert.throws(()=>sim.purchase(data,bought.shop,{kind:'recruit',id:'barracks-2'}));assert.throws(()=>sim.purchase(data,shop,{kind:'build',family:'tower',level:2}));
assert.equal(sim.purchase(data,shop,{kind:'build',family:'barracks',level:3}),null);
shop.gold=200;shop=sim.purchase(data,shop,{kind:'build',family:'barracks',level:3}).shop;
const upgraded=sim.purchase(data,shop,{kind:'upgrade',slot:0,id:'barracks-3'});assert.equal(upgraded.event.cost,35);assert.throws(()=>sim.purchase(data,shop,{kind:'recruit',id:'barracks-2'}));
for(const strategy of Object.keys(sim.strategies))for(let seed=1;seed<=12;seed++){
 const r=sim.simulateCampaign(data,{strategy,seed,trace:true});assert.deepEqual(r,sim.simulateCampaign(data,{strategy,seed,trace:true}));assert.equal(r.gold,data.startingGold+r.earned-r.spent);
 for(const b of r.battles){assert.equal(b.reward>0,b.outcome==='victory');if(b.replay)assert(b.region<3||r.wins[3]===3);const actions=new Map();const positions=new Map(b.initialUnits.map(u=>[u.slot,u.cell]));const hp=new Map(b.initialUnits.map(u=>[u.slot,u.hp]));const teams=new Map(b.initialUnits.map(u=>[u.slot,u.team]));
  for(const e of b.trace){
   if(e.action==='move'){assert(sim.neighbours[e.from].includes(e.to));assert.equal(positions.get(e.actor),e.from);assert(![...positions].some(([id,c])=>id!==e.actor&&hp.get(id)>0&&c===e.to));positions.set(e.actor,e.to);}
   if(e.action==='attack'){hp.set(e.target,e.hpAfter);if(teams.get(e.actor)===0){const k=e.round+':'+e.actor;assert(!actions.has(k));actions.set(k,true);const moves=b.trace.filter(m=>m.action==='move'&&m.round===e.round&&m.actor===e.actor).length;assert(moves<data.players.find(u=>u.id===b.initialUnits[e.actor].id).move);}}
   if(e.action==='raise'){hp.set(e.target,2);teams.set(e.target,1);}
   if(e.action==='heal')hp.set(e.actor,e.hpAfter);
   if(e.action==='summon'){teams.set(e.summoned,1);positions.set(e.summoned,e.to);hp.set(e.summoned,data.enemies.find(u=>u.id==='skeleton').hp);}
  }
 }
}
const legacy=clone(data);legacy.permanentCasualties=false;legacy.endlessLairs=false;const mounted=sim.simulateCampaign(legacy,{strategy:'mounted',seed:1,earlyPractice:true,trace:true});assert(mounted.battles.some(b=>b.replay&&b.region===0));
console.log('PASS: all 1764 native geometry/shot pairs, fixed damage, boss victory, delayed skeleton summoning, purchase legality, 60 deterministic campaigns, gold conservation, movement occupancy and attack/AP limits.');

const page=fs.readFileSync(__dirname+'/../unit-editor.html','utf8');
for(const [id,file] of [['campaign-sim-rules','campaign-sim.js'],['campaign-sim-ui','editor-simulation.js']])assert.equal(page.match(new RegExp('<script id="'+id+'">\\n([\\s\\S]*?)\\n<\\/script>'))[1],fs.readFileSync(__dirname+'/../simulation/'+file,'utf8'));
console.log('PASS: simulator and UI embedded in standalone editor match their tested source files.');
