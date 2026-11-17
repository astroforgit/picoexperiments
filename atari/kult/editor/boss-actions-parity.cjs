const assert=require('node:assert/strict'),fs=require('node:fs');const {Encounter}=require('./flight-core.js');
const data=JSON.parse(fs.readFileSync(0,'utf8'));
for(const trace of data.traces){const e=new Encounter(data.project,data.sine,0,0,{loop:false,bossPreview:!trace.guardian,guardian:trace.guardian,aiSeed:trace.seed});
 let reachable=new Set([12*128+56]);
 for(let t=0;t<trace.frames.length;t++){e.invulnerable=999;e.update();const actual=[e.ai.phase,e.ai.timer,e.bossX,e.bossTop+16,e.ai.frame,e.ai.art,e.ai.direction,e.hostile.map(b=>[b.lane,b.x,b.y]).sort((a,b)=>a[0]-b[0])];assert.deepEqual(actual,trace.frames[t],`Native/browser action mismatch: main=${trace.guardian}, tick=${t}`);
 const [phase,,bossX,coreY,,,,bullets]=actual,visible=[1,2,3,6,8].includes(phase)&&bossX<128,next=new Set();
 for(const pos of reachable){const x=Math.floor(pos/128),y=pos%128;for(const dx of [-3,0,3])for(const dy of [-6,0,6]){const xx=dx>0?(x<100?x+3:x):Math.max(0,x+dx),yy=Math.max(0,Math.min(112,y+dy));
  if(visible&&xx+20>bossX&&xx<bossX+32&&yy+16>coreY-16&&yy<coreY+48)continue;
  if(bullets.some(([,bx,by])=>bx-xx>=-8&&bx-xx<20&&by-yy>=-16&&by-yy<16))continue;next.add(xx*128+yy);
 }}reachable=next;assert.ok(reachable.size,`No unaided escape through full boss sequence at tick ${t}`);
}
}
console.log('Complete boss-action state, movement and projectile traces match native CPU execution.');
