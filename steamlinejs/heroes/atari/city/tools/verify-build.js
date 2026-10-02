"use strict";
const fs=require("fs"),path=require("path");
process.chdir(path.resolve(__dirname,".."));
const assert=require("assert/strict");
const labels=Object.fromEntries(fs.readFileSync("generated/city-vbxe.lab","utf8").split("\n").map(l=>l.trim().split(/\s+/)).filter(p=>p.length===3).map(p=>[p[2].toLowerCase(),parseInt(p[1],16)]));
const data=fs.readFileSync("city-vbxe.xex");
assert.equal(data.readUInt16LE(0),65535);
let i=2,uploads=0,init=0,run;
while(i<data.length){
  const start=data.readUInt16LE(i);i+=2;if(start===65535)continue;
  const end=data.readUInt16LE(i);i+=2;const n=end-start+1;
  assert(n>0&&i+n<=data.length,"Malformed XEX segment");
  if(start===0x6000){assert.equal(n,4096);uploads++;}
  else if(start===0x2e2){assert.equal(n,2);init++;}
  else if(start===0x2e0){assert.equal(n,2);run=data.readUInt16LE(i);}
  else assert((start>=0x2000&&end<0x6000)||(start===0x7000&&end<0x8000)||(start===0x8000&&end===0x83ff),"Unexpected CPU memory region");
  i+=n;
}
assert.equal(uploads,95);assert.equal(init,96);assert.equal(run,labels.main);
assert(labels.code_end<=0x6000);assert.equal(fs.statSync("generated/palette.bin").size,768);
assert.equal(fs.statSync("generated/vram.bin").size,389120);
const c=JSON.parse(fs.readFileSync("content.json","utf8"));
assert.equal(c.buildings.length,5);assert(c.startingGold>=0&&c.startingGold<=65535);
const units=new Set();
for(const b of c.buildings){
  assert(b.x>=0&&b.x+56<=320&&b.y>=16&&b.y+64<=158);
  assert.equal(b.recruitCosts.length,3);
  for(let t=0;t<3;t++){
    assert(Number.isInteger(b.recruitCosts[t])&&b.recruitCosts[t]>0&&b.recruitCosts[t]<=65535);
    if(t)assert(b.recruitCosts[t]>b.recruitCosts[t-1]);
    assert(b.costs[t]>0&&b.costs[t]<=65535);
    assert(!units.has(b.units[t]));units.add(b.units[t]);
    assert(b.hp[t]>0&&b.hp[t]<100&&b.damage[t]>0&&b.damage[t]<100&&b.range[t]>0&&b.range[t]<10);
  }
}
console.log(`PASS: ${data.length}-byte XEX, 95 graphics uploads, safe CPU regions, four recruit lines plus support Chapel, duplicate troops allowed.`);

const regions=[
 [0x20000,64000,'city'],[0x30000,53760,'buildings'],[0x3d200,4608,'font'],
 [0x3e400,3840,'hex masks'],[0x3f300,2688,'obstacles'],[0x40000,4480,'troops'],
 [0x44000,40960,'forest'],[0x50000,64000,'encounters'],
 [0x60000,40960,'catacombs'],[0x6a000,40960,'caves'],[0x74000,40960,'ruins']
];
for(let j=0;j<regions.length;j++){
 const [start,size,name]=regions[j];assert(start+size<=0x7f000,name+' overlaps VBXE commands');
 if(j)assert(regions[j-1][0]+regions[j-1][1]<=start,name+' overlaps previous asset');
}
assert(labels['battle.unit_hp']!==labels['battle.unit_type'],'Battle data must not be stripped by assembler');
assert(labels['battle.draw']>0 && labels['battle.start']>0);
console.log('PASS: all battle/city graphics fit without overlap below the reserved VBXE command bank.');

const anim=JSON.parse(fs.readFileSync('generated/hero-animation-layout.json'));
const allocations=regions.map(([a,n,name])=>[a,a+n,name]);
for(const a of anim.idleCaches||[])allocations.push([a,a+896,'idle sprite cache']);
allocations.push([anim.cache[0],anim.cache[0]+anim.cache[1],'decoded hero cache']);
anim.addresses.forEach((a,i)=>{
 assert((a>>12)===((a+anim.lengths[i]-1)>>12),'Compressed pose crosses aperture bank');
 allocations.push([a,a+anim.lengths[i],'hero pose '+i]);
});
allocations.sort((a,b)=>a[0]-b[0]);
for(let i=0;i<allocations.length;i++){
 assert(allocations[i][1]<=0x7f000);
 if(i)assert(allocations[i-1][1]<=allocations[i][0],allocations[i][2]+' overlaps');
}
console.log('PASS: compressed hero frames and decode cache are disjoint from all scenery/UI banks.');
