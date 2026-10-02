'use strict';
const fs=require('fs'),path=require('path');const root=path.resolve(__dirname,'..');
const source=path.resolve(process.argv[2]||path.join(root,'../../greenhaven-unit-balance.json'));
const d=JSON.parse(fs.readFileSync(source));const c=JSON.parse(fs.readFileSync(path.join(root,'content.json')));
if(!Number.isInteger(d.startingGold)||d.startingGold<0||d.startingGold>65535)throw Error('Invalid starting gold');
for(const b of c.buildings){
 if(b.id==='chapel'&&d.chapel){b.costs=d.chapel.costs;continue;}
 const rows=[1,2,3].map(t=>d.players.find(u=>u.id===`${b.id}-${t}`));if(rows.some(u=>!u))throw Error('Missing tiers: '+b.id);
 for(const u of rows)for(const key of ['hp','damage','move','shootRange','recruit','buildingCost'])if(!Number.isInteger(u[key])||u[key]<(key==='shootRange'?0:1))throw Error(`Invalid ${u.id} ${key}`);
 b.units=rows.map(u=>u.id==='lodge-3'?'CAVALRY':u.name.toUpperCase());
 for(const key of ['hp','damage','move','shootRange'])b[key]=rows.map(u=>u[key]);
 b.range=rows.map(u=>Math.max(1,u.shootRange));b.recruitCosts=rows.map(u=>u.recruit);b.costs=rows.map(u=>u.buildingCost);
}
for(const e of c.enemies){const u=d.enemies.find(u=>u.id===e.id);if(!u)throw Error('Missing enemy '+e.id);Object.assign(e,u);e.range=e.id==='warlock'?3:Math.max(1,e.shootRange);}
c.startingGold=d.startingGold;c.baseArmyCapacity=3;c.buildings[3].support=true;c.buildings[3].effects=['UNLOCK ARMY SLOT 4','UNLOCK ARMY SLOT 5','RECRUITS COST 10 LESS'];
fs.writeFileSync(path.join(root,'content.json'),JSON.stringify(c,null,2)+'\n');console.log('Imported balance; Chapel now unlocks slots and discounts recruitment.');
