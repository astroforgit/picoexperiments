'use strict';
const sim=require('./campaign-sim.js'),rules=require('../editor-balance.js'),data=require('../greenhaven-unit-balance.json'),rows=[];
for(let i=0;i<5;i++)for(let j=i+1;j<5;j++){
 const army=Array(5).fill('lodge-3');army[i]=army[j]='barracks-3';
 for(const ai of ['native','pathfinding']){const battle=sim.simulateBattle(data,army,rules.generate(data,3,2,1),{enemyPolicy:ai==='native'?undefined:ai});rows.push({army,ai,outcome:battle.outcome,rounds:battle.rounds});}
}
process.stdout.write(JSON.stringify(rows,null,2)+'\n');
