'use strict';
const fs = require('fs'), path = require('path');
const source = JSON.parse(fs.readFileSync(path.join(__dirname, 'world.json')));
const world = structuredClone(source), old = source.layers[0].tiles;
// Keep the entrance and four rows of each repeated, empty shaft run.
const rows = []; let run = 0;
for (let y = 0; y < 238; y++) {
  const row = old.slice(y*12,y*12+12);
  const emptyShaft = row.slice(2,10).every(c=>c.tile === -1);
  run = emptyShaft ? run+1 : 0;
  if (y <= 16 || !emptyShaft || run <= 4) rows.push(y);
}
const cells = Array.from({length:2880}, (_,i)=>({x:i%12,y:Math.floor(i/12),index:i,tile:1,rot:0,flipX:false}));
rows.forEach((oldY,y)=>old.slice(oldY*12,oldY*12+12).forEach((c,x)=>{
  cells[y*12+x] = {...c, x,y,index:y*12+x,id:c.id || `source-${oldY*12+x}`};
}));
const checkpoints = cells.filter(c=>c.tile===11);
// Open a generous alternate route connecting the original checkpoint sequence.
const route = new Set();
function clear(x,y) { if(x>=2 && x<=9 && y>=10 && y<rows.length) route.add(y*12+x); }
let start = {x:4,y:10};
for (const cp of checkpoints) {
  for(let y=start.y;y<=cp.y;y++) for(let x=Math.max(2,start.x-1);x<=Math.min(9,start.x+1);x++) clear(x,y);
  for(let y=cp.y-2;y<=cp.y;y++) for(let x=Math.min(start.x,cp.x)-1;x<=Math.max(start.x,cp.x)+1;x++) clear(x,y);
  start=cp;
}
for(const i of route) if(cells[i].tile!==11) cells[i].tile=-1;
// Remove hazards immediately adjacent to the alternate route; retain side challenges.
for(const c of cells) {
 if([13,14,16,17,18].includes(c.tile)) {
   let near=false;
   for(let dy=-2;dy<=2;dy++) for(let dx=-2;dx<=2;dx++) if(route.has((c.y+dy)*12+c.x+dx)) near=true;
   if(near) c.tile=-1;
 }
 if(c.tile===13)c.speed=32;
 if(c.tile===14)c.bulletSpeed=150;
 if(c.tile===17)c.speed=100;
 if(c.tile<0) {delete c.id;delete c.speed;delete c.bulletSpeed;}
}
world.layers[0].tiles=cells;
world.grappleEditor={version:3,target:'atari-vbxe',name:'Grapple Gentle Descent',source:'steamlinejs/world.json',finishRow:checkpoints.at(-1).y,removedRows:238-rows.length};
fs.writeFileSync(path.join(__dirname,'world-gentle-descent.json'),JSON.stringify(world,null,2)+'\n');
console.log(world.grappleEditor);
console.log(Object.fromEntries([11,13,14,16,17,18].map(t=>[t,cells.filter(c=>c.tile===t).length])));
