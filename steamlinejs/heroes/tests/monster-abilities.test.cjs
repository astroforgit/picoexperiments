'use strict';
const assert=require('node:assert/strict'),fs=require('node:fs'),sim=require('../simulation/campaign-sim.js'),rules=require('../editor-balance.js'),base=require('../greenhaven-unit-balance.json');
const clone=x=>JSON.parse(JSON.stringify(x));
function fight(id,hero='barracks-2',rounds=3,edit=()=>{}){const d=clone(base);for(const u of d.players){u.hp=99;u.damage=1;}for(const u of d.enemies)u.hp=99;edit(d);return sim.simulateBattle(d,[hero],{enemies:[{...d.enemies.find(u=>u.id===id),cell:1}],terrain:[10,31],playerCells:[0]},{trace:true,maxRounds:rounds});}
let b=fight('dark');assert(b.healing>0);for(const e of b.trace.filter(e=>e.action==='heal'))assert(e.hpAfter<=99);
b=fight('zombie','barracks-2',2,d=>d.players.find(u=>u.id==='barracks-2').hp=1);assert.equal(b.conversions,1);assert.equal(b.outcome,'defeat');const raised=b.trace.find(e=>e.action==='raise');assert(!b.trace.slice(b.trace.indexOf(raised)+1).some(e=>e.actor===raised.target&&e.action==='attack'&&e.round===raised.round));
b=fight('skeleton','archery-2',1,d=>d.players.find(u=>u.id==='archery-2').damage=2);assert.equal(b.trace.find(e=>e.action==='attack').damage,1);
b=fight('skeleton','tower-1',1,d=>d.players.find(u=>u.id==='tower-1').damage=2);assert.equal(b.trace.find(e=>e.action==='attack').damage,2);
b=fight('ogre');assert(b.preparations>0);assert(b.trace.some(e=>e.action==='attack'&&e.actor===1&&e.damage===5));assert(!b.trace.some(e=>e.action==='attack'&&e.actor===1&&e.round===1));
b=fight('imp',undefined,1);assert.equal(b.hops,1);
b=fight('warlock',undefined,5);assert(b.summons>=2);assert(b.finalUnits.filter(u=>u.summoned&&u.hp>0).length<=2);for(const e of b.trace.filter(e=>e.action==='summon')){assert(e.round>=2);assert(!b.trace.some(a=>a.action==='attack'&&a.actor===e.summoned&&a.round===e.round));}
// Every compiled native seed must select exactly the editor's group.
const generated=fs.readFileSync(__dirname+'/../atari/city/generated/battle-content.inc','utf8');let offset=0;
for(let region=0;region<4;region++)for(let stage=0;stage<3;stage++){
 const index=region*3+stage,table=generated.match(new RegExp('^seed_'+index+' dta ([^\\n]+)','m'))[1].split(',').map(Number);
 for(let seed=0;seed<256;seed++)assert.equal(table[seed],offset+rules.generate(base,region,stage,seed).variant);
 offset+=base.encounterConfig.regions[region].stages[stage].variants.length;
}
const native=require('../atari/city/content.json');assert.deepEqual(native.encounterConfig,base.encounterConfig);for(const e of base.enemies)assert.equal(native.enemies.find(u=>u.id===e.id).hp,e.hp);
console.log('PASS: simulator lifesteal, conversion delay, arrow resistance, Ogre windup, Imp hop, capped delayed summons, and all 3072 native/editor seed selections.');
