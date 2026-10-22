'use strict';
const fs=require('fs'),path=require('path');process.chdir(path.resolve(__dirname,'..'));
const c=JSON.parse(fs.readFileSync('content.json'));
let out=[];function bytes(n,a){out.push(n+' dta '+a.join(','));}
function ptr(n,a){bytes(n+'_lo',a.map(s=>'<'+s));bytes(n+'_hi',a.map(s=>'>'+s));}
const names=c.enemies.map(e=>e.name.toUpperCase());
for(const k of ['hp','damage','range','move','shootRange'])bytes('type_'+(k==='shootRange'?'shoot_range':k),[...c.buildings.flatMap(b=>b[k]),...c.enemies.map(e=>e[k])]);
const allNames=[...c.buildings.flatMap(b=>b.units),...names];ptr('type_name',allNames.map((_,i)=>'type_name_'+i));
allNames.forEach((s,i)=>out.push(`type_name_${i} dta c'${s}',0`));
bytes('type_summon',[...Array(15).fill(255),...c.enemies.map(e=>e.id==='warlock'?15+c.enemies.findIndex(e=>e.id==='skeleton'):255)]);
const col=i=>i%7,row=i=>Math.floor(i/7),ax=i=>col(i)-Math.floor(row(i)/2);
const dist=(a,b)=>Math.max(Math.abs(ax(a)-ax(b)),Math.abs(row(a)-row(b)),Math.abs(ax(a)+row(a)-ax(b)-row(b)));
const cell=(x,y)=>x<0||x>6||y<0||y>5?255:y*7+x;
bytes('cell_x_lo',Array.from({length:42},(_,i)=>40+32*col(i)+16*(row(i)%2)));
bytes('cell_y',Array.from({length:42},(_,i)=>54+18*row(i)));
bytes('cell_col',Array.from({length:42},(_,i)=>col(i)));
bytes('cell_row',Array.from({length:42},(_,i)=>row(i)));
const nb=[];for(let i=0;i<42;i++){const x=col(i),y=row(i),o=y%2;nb.push(cell(x+1,y),cell(x+o,y+1),cell(x+o-1,y+1),cell(x-1,y),cell(x+o-1,y-1),cell(x+o,y-1));}
bytes('neighbour_table',nb);ptr('neighbour_row',Array.from({length:42},(_,i)=>'[neighbour_table+'+i*6+']'));
// Static obstacles match battle.start; bit 7 encodes blocked line of sight.
const blocked=new Set([10,31]);
function cube(i){return [ax(i),-ax(i)-row(i),row(i)];}
function roundCube(v){let r=v.map(Math.round),d=v.map((x,i)=>Math.abs(x-r[i]));let k=d.indexOf(Math.max(...d));r[k]=-r[(k+1)%3]-r[(k+2)%3];return r;}
function occluded(a,b){
 const n=dist(a,b),u=cube(a),v=cube(b);
 for(let i=1;i<n;i++)for(const e of [-0.000001,0.000001]){
  const q=roundCube(u.map((x,k)=>x+(v[k]-x)*i/n+(k===2?-2*e:e)));
  if(blocked.has(cell(q[0]+Math.floor(q[2]/2),q[2])))return true;
 }return false;
}
const ds=[];for(let i=0;i<42;i++)for(let j=0;j<42;j++)ds.push(dist(i,j)|(occluded(i,j)?128:0));bytes('distance_table',ds);
ptr('distance_row',Array.from({length:42},(_,i)=>'[distance_table+'+i*42+']'));
bytes('cursor_offsets',[0,42,84,126]);
bytes('cursor_neighbours',Array.from({length:168},(_,n)=>{const i=n%42,d=Math.floor(n/42);return d===0?(i<7?i:i-7):d===1?(i>=35?42:i+7):d===2?(col(i)?i-1:i):(col(i)<6?i+1:i);}));
// Compile the same weighted 32-bit seed hash used by the editor for native seeds 0..255.
const config=c.encounterConfig;
if(!config)throw Error('Import the editor balance before building.');
const variants=[],contracts=[];
for(const [r,region] of config.regions.entries())for(const [stage,e] of region.stages.entries()){
 const start=variants.length;for(const v of e.variants)variants.push(v);
 const total=e.variants.reduce((n,v)=>n+v.weight,0);
 if(total<=0)throw Error('No enabled variants');
 const picks=Array.from({length:256},(_,seed)=>{
  let state=(seed^Math.imul(r+1,0x9e3779b1)^Math.imul(stage+1,0x85ebca6b))>>>0;
  state=Math.imul(state^state>>>16,0x7feb352d)>>>0;
  state=Math.imul(state^state>>>15,0x846ca68b)>>>0;state=(state^state>>>16)>>>0;
  let pick=state/4294967296*total;
  return start+e.variants.findIndex(v=>{pick-=v.weight;return pick<0;});
 });contracts.push({...e,picks,name:region.name.toUpperCase()+(c.endlessLairs?'':' '+(stage+1))});
}
if(variants.length>255)throw Error('Too many variants');
ptr('contract_name',contracts.map((_,i)=>'contract_name_'+i));contracts.forEach((e,i)=>out.push(`contract_name_${i} dta c'${e.name}',0`));
ptr('seed_ptr',contracts.map((_,i)=>'seed_'+i));contracts.forEach((e,i)=>bytes('seed_'+i,e.picks));
// One enemy table per difficulty; the game adds difficulty_group_base[level] to the seeded group.
const groupKeys=['enemies','mediumEnemies','hardEnemies'];
if(variants.length*3>256)throw Error('Too many groups for three difficulty tables');
const encounters=groupKeys.flatMap(key=>variants.map(v=>v[key]||v.enemies)).map(list=>list.flatMap((id,i)=>{const n=c.enemies.findIndex(u=>u.id===id);if(n<0||i>4)throw Error('Invalid encounter');return [15+n,[6,13,20,27,34][i]];}));
// The three group tables live beside the release UI at $A000; $6000-$7FFF is full.
const main=out;out=[];
bytes('difficulty_group_base',[0,1,2].map(k=>k*variants.length));
ptr('enemy_ptr',encounters.map((_,i)=>'enemies_'+i));encounters.forEach((a,i)=>bytes('enemies_'+i,[...a,255]));
fs.writeFileSync('generated/battle-groups.inc',out.join('\n')+'\n');out=main;
const rewards=contracts.map(e=>e.reward);
bytes('reward_lo',rewards.map(v=>v&255));bytes('reward_hi',rewards.map(v=>v>>8));
bytes('wins_required',config.progression.winsRequired);
bytes('practice_lo',config.regions.map(e=>e.replayReward&255));
bytes('practice_hi',config.regions.map(e=>e.replayReward>>8));
const thresholds=config.progression.winsRequired;
bytes('stage_for_win',thresholds.flatMap(n=>Array.from({length:10},(_,w)=>Math.min(2,Math.floor(w*3/n)))));
// Ability IDs remain stable: Vampire uses the existing dark sprite set.
bytes('type_ability',[...Array(15).fill(0),...c.enemies.map(e=>({dark:1,zombie:2,skeleton:3,ogre:4,imp:5,warlock:6}[e.id]||0))]);
// Title ENEMY INFO page: one enemy per special ability, in campaign order.
const info=['skeleton','zombie','dark','ogre','imp','warlock'].map(id=>{const n=c.enemies.findIndex(e=>e.id===id);if(n<0)throw Error('Missing enemy '+id);return n;});
bytes('info_type',info.map(n=>15+n));
ptr('info_name',info.map((_,i)=>'info_name_'+i));
info.forEach((n,i)=>out.push(`info_name_${i} dta c'${c.enemies[n].name.toUpperCase()}',0`));
// Difficulty levels shared with release/audit-balance.cjs; Medium is the release balance.
const difficulty=JSON.parse(fs.readFileSync('../../difficulty.json'));
if(difficulty.levels.length!==3||difficulty.levels[1].startingGold!==c.startingGold)throw Error('Medium difficulty must keep the release starting gold');
for(const l of difficulty.levels)if(!Number.isInteger(l.startingGold)||l.startingGold<0||l.startingGold>65535||!Number.isInteger(l.rewardShift)||Math.abs(l.rewardShift)>7||!/^[A-Z]{1,6}$/.test(l.name))throw Error('Invalid difficulty level');
out.push(`DEFAULT_DIFFICULTY = ${difficulty.default}`);
const duel=JSON.parse(fs.readFileSync('../../duel.json'));
// Duel: one random enemy; 32 weighted slots so the game indexes them with RANDOM & 31.
const duelTypes=duel.enemies.map(e=>c.enemies.findIndex(u=>u.id===e.enemy));
if(duelTypes.some(n=>n<0)||![6,13,20,27,34].includes(duel.cell)||duel.enemies.some(e=>!Number.isInteger(e.weight)||e.weight<1||!Number.isInteger(e.reward)||e.reward<1||e.reward>255)||duel.enemies.reduce((n,e)=>n+e.weight,0)!==32||duel.enemies.some(e=>e.enemy==='warlock'))throw Error('Invalid duel.json');
out.push(`DUEL_CELL = ${duel.cell}`);
bytes('duel_type',duelTypes.map(n=>15+n));bytes('duel_reward',duel.enemies.map(e=>e.reward));
bytes('duel_pick',duel.enemies.flatMap((e,i)=>Array(e.weight).fill(i)));
bytes('start_gold_lo',difficulty.levels.map(l=>l.startingGold&255));bytes('start_gold_hi',difficulty.levels.map(l=>l.startingGold>>8));
bytes('reward_bonus_shift',difficulty.levels.map(l=>Math.max(0,l.rewardShift)));
bytes('reward_cut_shift',difficulty.levels.map(l=>Math.max(0,-l.rewardShift)));
ptr('difficulty_label',difficulty.levels.map((_,i)=>'difficulty_label_'+i));
difficulty.levels.forEach((l,i)=>out.push(`difficulty_label_${i} dta c'LEVEL: ${l.name}',0`));
fs.writeFileSync('generated/battle-content.inc',out.join('\n')+'\n');
// Release version from ../../VERSION, shown on the title screen.
const version=fs.readFileSync('../../VERSION','utf8').trim();
if(!/^[0-9]+\.[0-9]+$/.test(version))throw Error('VERSION must look like 1.2');
fs.writeFileSync('generated/version.inc',`s_version dta c'V${version}',0\n`);
console.log(`Exported 28 fighter types, ${encounters.length} weighted encounters, seed tables and monster abilities.`);
