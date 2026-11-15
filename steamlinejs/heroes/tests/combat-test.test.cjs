'use strict';
const assert=require('node:assert/strict'),fs=require('node:fs');
const sim=require('../simulation/campaign-sim.js'),rules=require('../editor-balance.js'),base=require('../greenhaven-unit-balance.json');
const clone=x=>JSON.parse(JSON.stringify(x));
const encounter=(id,cell=1)=>({enemies:[{...base.enemies.find(u=>u.id===id),cell}],terrain:[10,31],playerCells:[0,7,14,21,28]});
assert.throws(()=>sim.createBattle(base,[],encounter('skeleton')));
assert.throws(()=>sim.createBattle(base,Array(6).fill('barracks-1'),encounter('skeleton')));
for(const hero of ['archery-1','archery-2','archery-3','tower-1','barracks-2']){
 const d=clone(base);d.enemies.find(u=>u.id==='bone-archer').hp=99;
 const e=encounter('bone-archer');e.enemies[0].hp=99;
 const it=sim.createBattle(d,[hero,'barracks-1'],e);let v=it.next().value;
 assert(v.legal.some(a=>a.kind==='attack'&&a.cell===1));
 v=it.next({kind:'attack',cell:1}).value;
 assert.equal(v.trace.find(e=>e.action==='attack').damage,hero.startsWith('archery-')?0:d.players.find(u=>u.id===hero).damage);
 assert.equal(v.active,1);assert.equal(v.remaining[0],undefined);
}
let it=sim.createBattle(base,['barracks-1','barracks-1'],encounter('ogre',34)),v=it.next().value;
const original=clone(v);v=it.next({kind:'move',cell:10}).value;assert.deepEqual(v,original);
v=it.next({kind:'select',slot:1}).value;assert.equal(v.active,1);
v=it.next({kind:'select',slot:0}).value;
const action=v.legal.find(a=>a.kind==='move'&&a.cost===1);const before=v.remaining[0];v=it.next(action).value;
assert.equal(v.remaining[0],before-1);assert.equal(v.units[0].cell,action.cell);
v=it.next({kind:'skip'}).value;assert.equal(v.active,1);
v=it.next({kind:'skip'}).value;assert.equal(v.phase,'enemy');
while(v.phase==='enemy')v=it.next().value;assert.equal(v.round,2);
let end=it.next({kind:'retreat'});assert(end.done);assert.equal(end.value.outcome,'retreat');
const e=encounter('warlock');e.enemies[0].hp=1;
it=sim.createBattle(base,['barracks-3'],e);it.next();end=it.next({kind:'attack',cell:1});assert(end.done);assert.equal(end.value.outcome,'victory');
// Every location/stage/difficulty supports five duplicate units and legal placement.
for(let r=0;r<4;r++)for(let s=0;s<base.encounterConfig.regions[r].stages.length;s++)for(let d=0;d<3;d++){
 const e=rules.generate(base,r,s,255,false,d);it=sim.createBattle(base,Array(5).fill('lodge-3'),e);v=it.next().value;
 assert.equal(v.units.filter(u=>u.team===0).length,5);assert.equal(new Set(v.units.map(u=>u.cell)).size,v.units.length);
 assert(v.legal.every(a=>!e.terrain.includes(a.cell)));it.return();
}
const html=fs.readFileSync(__dirname+'/../unit-editor.html','utf8');
for(const [id,file] of [['combat-test-ui','combat-test.js'],['combat-native-art','combat-art.js']])assert.equal(html.match(new RegExp('<script id="'+id+'">\\n([\\s\\S]*?)\\n</script>'))[1],fs.readFileSync(__dirname+'/../simulation/'+file,'utf8'));
console.log('PASS: interactive arrow immunity, magic/melee damage, illegal moves, unit switching, AP use, turn order, enemy turns, retreat, boss victory, 39 stage/difficulty setups and embedded UI parity.');
