const assert=require('node:assert/strict'),sim=require('../simulation/campaign-sim.js'),base=require('../greenhaven-unit-balance.json');
const copy=x=>structuredClone(x),e=id=>copy(base.enemies.find(u=>u.id===id));
// Two Nymphs charm different fighters. Only the dead owner's fighter returns.
let d=copy(base);d.players.find(u=>u.id==='tower-3').damage=99;
let encounter={enemies:[{...e('evil-nymph'),cell:1},{...e('evil-nymph'),cell:29}],playerCells:[0,28,14],terrain:[10,31]};
let it=sim.createBattle(d,['barracks-1','barracks-1','tower-3'],encounter),s=it.next().value;
for(let i=0;i<3;i++)s=it.next({kind:'skip'}).value;
assert(!s.trace.some(e=>e.action==='charm'));
while(s.phase==='enemy')s=it.next().value;
for(let i=0;i<3;i++)s=it.next({kind:'skip'}).value;
assert.equal(s.phase,'enemy');assert.equal(s.units[0].team,1);assert.equal(s.units[0].hp,3);assert.equal(s.units[0].charmedBy,3);
s=it.next().value;assert.equal(s.units[1].team,1);assert.equal(s.units[1].charmedBy,4);
s=it.next().value;assert.equal(s.round,3);assert.equal(s.active,2);assert(!s.trace.some(e=>e.action==='attack'&&e.round===1));
s=it.next({kind:'attack',cell:1}).value;
assert.equal(s.units[0].team,0);assert.equal(s.units[0].hp,3);assert.equal(s.units[0].charmedBy,null);assert.equal(s.units[1].team,1);assert.equal(s.units[1].charmedBy,4);assert(s.trace.some(e=>e.action==='release'&&e.target===0));
while(s.phase==='enemy')s=it.next().value;
assert(s.trace.some(e=>e.action==='attack'&&e.actor===1&&e.round===3));
// All fighters enchanted counts as defeat but surviving soldiers stay in campaign army.
it=sim.createBattle(base,['barracks-1'],{enemies:[{...e('evil-nymph'),cell:1}],playerCells:[0],terrain:[10,31]});it.next();let step=it.next({kind:'skip'});while(!step.done)step=it.next(step.value.phase==='player'?{kind:'skip'}:undefined);assert.equal(step.value.outcome,'defeat');assert.equal(step.value.survivors.length,1);assert.equal(step.value.survivors[0].hp,3);
// Ogre Mage uses normal ranged damage immediately, no heavy-strike preparation.
it=sim.createBattle(base,['barracks-3'],{enemies:[{...e('ogre-mage'),cell:2}],playerCells:[0],terrain:[10,31]});it.next();s=it.next({kind:'skip'}).value;const shot=s.trace.find(e=>e.action==='attack');assert.equal(shot.damage,2);assert.equal(shot.from,2);assert(!s.trace.some(e=>e.action==='prepare'));
console.log('PASS: no-damage charm, separate Nymph ownership, release, delayed enemy action, surviving charmed soldiers, and Ogre Mage ranged magic.');
// Across repeated turns, one owner cannot accumulate enchanted fighters.
const limited=copy(base);limited.players.find(u=>u.id==='barracks-1').hp=99;limited.players.find(u=>u.id==='barracks-1').damage=0;
const capped=sim.simulateBattle(limited,['barracks-1','barracks-1','barracks-1'],{enemies:[{...e('evil-nymph'),cell:1}],playerCells:[0,7,14],terrain:[10,31]},{trace:true,maxRounds:8});
assert.equal(capped.trace.filter(e=>e.action==='charm').length,1);
assert.equal(capped.finalUnits.filter(u=>u.hp>0&&u.charmedBy!=null).length,1);
assert(capped.trace.some(e=>e.action==='attack'&&e.actor===3&&e.damage===0));
console.log('PASS: one living enchanted creature per Nymph across repeated turns, no damage while occupied.');

// Five steps to attack range: approach three, then move two and enchant.
it=sim.createBattle(base,['barracks-1'],{enemies:[{...e('evil-nymph'),cell:6}],playerCells:[0],terrain:[]});it.next();s=it.next({kind:'skip'}).value;
assert.equal(s.units[1].cell,3);assert(!s.trace.some(e=>e.action==='charm'));
s=it.next().value;s=it.next({kind:'skip'}).value;
assert.equal(s.units[1].cell,1);assert.equal(s.units[0].charmedBy,1);
assert.equal(s.trace.filter(e=>e.round===2&&e.action==='move').length,2);
console.log('PASS: halfway approach, next-turn movement plus immediate enchantment.');

// Killing the last Nymph releases its survivor and ends immediately.
it=sim.createBattle(d,['barracks-1','tower-3'],{enemies:[{...e('evil-nymph'),cell:1}],playerCells:[0,14],terrain:[10,31]});let end=it.next();
while(!end.done&&end.value.round<3)end=it.next(end.value.phase==='player'?{kind:'skip'}:undefined);
assert.equal(end.value.units[0].charmedBy,2);
end=it.next({kind:'attack',cell:1});assert(end.done);assert.equal(end.value.outcome,'victory');assert.equal(end.value.enemiesRemaining,0);assert.equal(end.value.survivors.length,2);assert.equal(end.value.finalUnits[0].team,0);
console.log('PASS: final Nymph death immediately wins and restores the enchanted survivor.');
