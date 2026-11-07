'use strict';
const assert=require('node:assert/strict'),sim=require('../simulation/campaign-sim.js'),data=require('../greenhaven-unit-balance.json');
const shop={gold:24,army:[],levels:{barracks:2,chapel:0,archery:0,lodge:0,tower:0}};
assert(!sim.canAffordRecruit(data,shop));shop.gold=25;assert(sim.canAffordRecruit(data,shop));
shop.levels.barracks=3;shop.gold=59;assert(!sim.canAffordRecruit(data,shop));shop.gold=60;assert(sim.canAffordRecruit(data,shop));
shop.levels.lodge=1;shop.gold=20;assert(sim.canAffordRecruit(data,shop));shop.gold=19;assert(!sim.canAffordRecruit(data,shop));
shop.levels={barracks:2,chapel:3};shop.gold=14;assert(!sim.canAffordRecruit(data,shop));shop.gold=15;assert(sim.canAffordRecruit(data,shop));
const run=sim.simulateCampaign(data,{strategy:'mounted',seed:1,trace:true});assert.equal(run.gameOver,true);assert(run.army.every(id=>!id));assert(run.blockedReason.includes('GAME OVER'));
console.log('PASS: highest unlocked recruit tiers, affordable alternative family, exact cost, Chapel discount and explicit campaign game-over status.');
