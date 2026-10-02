'use strict';
const fs=require('fs'),path=require('path');process.chdir(path.resolve(__dirname,'..'));
const c=JSON.parse(fs.readFileSync('content.json'));
const out=[];function bytes(n,a){out.push(n+' dta '+a.join(','));}
function ptr(n,a){bytes(n+'_lo',a.map(s=>'<'+s));bytes(n+'_hi',a.map(s=>'>'+s));}
const names=c.enemies.map(e=>e.name.toUpperCase());
for(const k of ['hp','damage','range','move','shootRange'])bytes('type_'+(k==='shootRange'?'shoot_range':k),[...c.buildings.flatMap(b=>b[k]),...c.enemies.map(e=>e[k])]);
const allNames=[...c.buildings.flatMap(b=>b.units),...names];ptr('type_name',allNames.map((_,i)=>'type_name_'+i));
allNames.forEach((s,i)=>out.push(`type_name_${i} dta c'${s}',0`));
bytes('type_summon',[...Array(15).fill(255),...c.enemies.map(e=>e.id==='warlock'?15+c.enemies.findIndex(e=>e.id==='demon'):255)]);
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
// Three contracts per region; duplicate individual enemies are intentional.
const encounters=c.encounters.map(e=>e.enemies.flatMap((id,i)=>[15+c.enemies.findIndex(u=>u.id===id),[6,13,20,27,34][i]]));
ptr('contract_name',c.encounters.map((_,i)=>'contract_name_'+i));c.encounters.forEach((e,i)=>out.push(`contract_name_${i} dta c'${e.name}',0`));
for(const a of encounters){if(a.length>10||a.length%2)throw Error('Enemy count');const cells=a.filter((_,i)=>i%2);if(new Set(cells).size!==cells.length)throw Error('Overlapping enemies');}
ptr('enemy_ptr',encounters.map((_,i)=>'enemies_'+i));encounters.forEach((a,i)=>bytes('enemies_'+i,[...a,255]));
const rewards=c.encounters.map(e=>e.reward),bonus=[0,0,0,0];
bytes('reward_lo',rewards.map(v=>v&255));bytes('reward_hi',rewards.map(v=>v>>8));bytes('bonus_lo',bonus.map(v=>v&255));bytes('bonus_hi',bonus.map(v=>v>>8));bytes('practice',[50,80,100,150]);
fs.writeFileSync('generated/battle-content.inc',out.join('\n')+'\n');
console.log('Exported 28 fighter types, 12 encounters and 7x6 hex geometry.');
