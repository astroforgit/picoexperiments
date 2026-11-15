#!/usr/bin/env node
'use strict';
// ANTIC 4 artwork. Each screen row has its own RAM font, allowing large tiles
// without the 128-character limit of a shared font. Pixel 3 can be blue or
// copper per character; display-list interrupts add vertical colour shading.
// Every designs/*.txt file is one switchable board design. The campaign's
// "design" field picks the one built into the game; the editor gets them all.
const fs = require('fs');
const path = require('path');
const N = 24;
const ELEMENTS = ['floor','floor','ring','boulder','pause','spiral','trap','portal',
 'arrow_up','arrow_right','arrow_up','arrow_right','lock','key','lock_open'];

function loadDesign(file){
 const design={id:path.basename(file,'.txt'),sprites:{},small:{}};
 let tile=null,width=12;
 for(const raw of fs.readFileSync(file,'utf8').split('\n')){
  const line=raw.trim();
  if(!line||line.startsWith('#'))continue;
  const [key,...values]=line.split(/\s+/);
  if(key==='tile'){tile=design.sprites[values[0]]=[];width=12;continue;}
  if(key==='small'){tile=design.small[values[0]]=[];width=4;continue;}
  if(tile){
   if(line.length!==width||!/^[.0-3]+$/.test(line))throw Error(`${file}: rows here are ${width} characters of . 0 1 2 3`);
   tile.push(line);continue;
  }
  if(key==='name'||key==='about')design[key]=line.slice(key.length).trim();
  else if(key==='elephant')design.roles=values.map(Number);
  else design[key]=values.map(v=>parseInt(v.replace('$',''),16));
 }
 for(const key of ['background','floor','light','blue','copper','status','roles'])
  if(!design[key])throw Error(`${file}: missing ${key}`);
 for(const [name,rows] of Object.entries(design.sprites))
  if(rows.length!==N)throw Error(`${file}: tile ${name} needs ${N} rows`);
 for(const [name,rows] of Object.entries(design.small))
  if(rows.length!==8)throw Error(`${file}: small ${name} needs 8 rows`);
 const drawn=Object.keys(design.sprites).length;
 if(drawn&&!ELEMENTS.every(name=>design.sprites[name]))throw Error(`${file}: needs every tile or none`);
 return design;
}
const designs=fs.readdirSync(path.join(__dirname,'designs')).filter(name=>name.endsWith('.txt')).sort()
 .map(name=>loadDesign(path.join(__dirname,'designs',name)))
 .sort((a,b)=>(b.id==='classic')-(a.id==='classic'));
// Native 12-column rows become the 24-pixel source: each ANTIC pixel is 2 wide.
const expand=rows=>rows.map(row=>[...row].flatMap(c=>c==='.'?[-1,-1]:[+c,+c]));

let design;
function canvas(floor = true, transparent = false) {
 const p = Array.from({length:N},()=>Array(N).fill(transparent ? -1 : 0));
 // Shared art is drawn in classic colours; roles map them onto the design.
 const put=(x,y,c)=>{x=Math.round(x);y=Math.round(y);if(x>=0&&x<N&&y>=0&&y<N)p[y][x]=c<0?c:design.roles[c];};
 const rect=(x0,y0,x1,y1,c)=>{for(let y=y0;y<=y1;y++)for(let x=x0;x<=x1;x++)put(x,y,c);};
 const ellipse=(cx,cy,rx,ry,c)=>{for(let y=0;y<N;y++)for(let x=0;x<N;x++)if(((x-cx)/rx)**2+((y-cy)/ry)**2<=1)put(x,y,c);};
 const line=(x0,y0,x1,y1,c,width=1)=>{const steps=Math.max(Math.abs(x1-x0),Math.abs(y1-y0));for(let i=0;i<=steps;i++){const t=steps?i/steps:0;rect(Math.round(x0+(x1-x0)*t),Math.round(y0+(y1-y0)*t),Math.round(x0+(x1-x0)*t)+width-1,Math.round(y0+(y1-y0)*t)+width-1,c);}};
 if(floor){
  if(design.sprites.floor)expand(design.sprites.floor).forEach((row,y)=>row.forEach((c,x)=>{p[y][x]=c;}));
  else{
   // Quiet slate inlay: no bright bars competing with the puzzle pieces.
   rect(0,0,23,23,1);line(0,23,23,23,0);line(23,0,23,23,0);
   put(3,5,0);put(17,16,0);
  }
 }
 return {p,put,rect,ellipse,line};
}
function onFloor(p){
 const floor=canvas().p;
 return p.map((row,y)=>row.map((c,x)=>c<0?floor[y][x]:c));
}
function buildTiles(){
const tiles=[];
for(let type=0;type<15;type++){
 if(design.sprites.floor){
  let p=expand(design.sprites[ELEMENTS[type]]);
  if(type===10)p=p.slice().reverse();
  if(type===11)p=p.map(row=>row.slice().reverse());
  tiles.push(onFloor(p));
  continue;
 }
 const a=canvas(),{rect,ellipse,line,put}=a;
 switch(type){
 case 2:
  ellipse(12,12,10,10,0);ellipse(12,11,9,9,3);ellipse(12,11,7,7,2);ellipse(12,11,5,5,0);
  line(7,5,10,3,2);line(11,3,15,3,2);break;
 case 3:
  ellipse(12,12,11,11,0);ellipse(11,11,10,10,3);
  line(5,5,9,3,2);line(6,7,10,5,2);line(15,18,18,16,0);line(17,19,20,17,0);break;
 case 4:
  rect(5,4,9,19,0);rect(14,4,18,19,0);rect(5,4,8,17,3);rect(14,4,17,17,3);
  line(5,4,8,4,2);line(14,4,17,4,2);break;
 case 5:
  ellipse(12,12,9,9,3);ellipse(12,12,6,6,0);rect(12,2,21,10,1);
  line(6,7,8,5,2);line(12,6,19,6,3,2);line(18,3,21,6,3);line(18,9,21,6,3);break;
 case 6:
  ellipse(12,12,10,10,0);ellipse(12,11,8,8,3);
  line(8,7,15,14,0,3);line(15,7,8,14,0,3);line(6,5,10,3,2);break;
 case 7:
  ellipse(12,12,10,10,0);ellipse(12,11,9,9,3);ellipse(12,11,6,7,2);
  ellipse(12,12,4,5,0);ellipse(12,11,2,3,3);line(6,5,10,3,2);break;
 case 8:case 9:case 10:case 11:{
  rect(10,10,13,19,0);rect(9,8,12,18,3);
  for(let y=3;y<11;y++)rect(11-(y-3),y,11+(y-3),y,3);
  line(10,4,6,8,2);
  for(let n=0;n<type-8;n++)a.p=a.p[0].map((_,x)=>a.p.map(row=>row[x]).reverse());
  break;
 }
 case 12:case 14:
  ellipse(type===14?15:12,8,6,6,0);ellipse(type===14?15:12,8,4,4,2);
  ellipse(type===14?15:12,8,2,3,1);if(type===14)rect(16,8,22,12,1);
  rect(5,10,19,20,0);rect(5,10,18,18,3);line(6,10,17,10,2);
  ellipse(12,14,2,2,0);rect(11,15,12,17,0);break;
 case 13:
  ellipse(9,8,6,6,0);ellipse(8,7,5,5,3);ellipse(8,7,2,2,0);
  rect(10,10,13,20,0);rect(10,9,12,19,3);rect(12,15,17,17,3);rect(12,19,16,20,3);
  line(5,4,7,3,2);break;
 }
 tiles.push(a.p);
}
for(let mask=0;mask<16;mask++){
 const a=canvas(),{rect,ellipse,line}=a;
 // Thick, shaded trunk with wrinkles; the same width at bends and straights.
 ellipse(12,12,6,6,0);
 if(mask&1)rect(6,0,17,12,0);if(mask&2)rect(12,6,23,17,0);
 if(mask&4)rect(6,12,17,23,0);if(mask&8)rect(0,6,12,17,0);
 ellipse(11,11,5,5,3);
 if(mask&1)rect(7,0,16,12,3);if(mask&2)rect(12,7,23,16,3);
 if(mask&4)rect(7,12,16,23,3);if(mask&8)rect(0,7,12,16,3);
 if(mask&1){line(8,0,8,8,2);line(12,3,15,3,1);}
 if(mask&2){line(15,8,23,8,2);line(20,12,20,15,1);}
 if(mask&4){line(8,15,8,23,2);line(12,20,15,20,1);}
 if(mask&8){line(0,8,8,8,2);line(3,12,3,15,1);}
 if([0,1,2,4,8].includes(mask)){
  const t=canvas(false, true);
  if(mask!==0){t.rect(6,12,17,23,0);t.rect(7,12,16,23,3);t.line(8,17,8,23,2);}
  // Broad flared rim, thick outline, rim highlight and two curved nostrils.
  t.ellipse(12,10,10,9,0);t.ellipse(11,9,9,8,3);
  t.line(6,4,9,2,2);t.line(10,2,14,2,2);t.line(4,6,4,10,2);
  t.ellipse(8,10,2,4,0);t.ellipse(15,10,2,4,0);
  t.ellipse(7,8,1,2,3);t.ellipse(14,8,1,2,3);
  let p=t.p;
  for(let n=0;n<({0:0,4:0,8:1,1:2,2:3}[mask]);n++)p=p[0].map((_,x)=>p.map(row=>row[x]).reverse());
  const floor=canvas().p;
  tiles.push(p.map((row,y)=>row.map((c,x)=>c<0?floor[y][x]:c)));
 }else tiles.push(a.p);
}
tiles.push(...faces(11));
return tiles;
}
// A compact elephant seen from above. Ears, eyes and forehead rotate as one
// sprite; the background never rotates. Symmetric 10-pixel ports meet every
// straight/bend without the old extra nose strip tearing the face apart.
// The face mirrors around column cx: 11 for the large tile, which samples the
// odd source columns, and 11.5 for the smaller tiles, which sample both edges.
function faces(cx){
 const a=canvas(false,true),m=x=>2*cx-x;
 a.ellipse(4,9,4,7,0);a.ellipse(m(4),9,4,7,0);
 a.ellipse(4,9,3,6,3);a.ellipse(m(4),9,3,6,3);
 a.ellipse(cx,9,7.5,8,0);a.ellipse(cx,9,6.5,7,3);
 a.rect(Math.ceil(cx-2),3,Math.floor(cx+2),3,2);
 a.rect(6,7,8,10,2);a.rect(m(8),7,m(6),10,2);
 a.rect(7,8,8,10,0);a.rect(m(8),8,m(7),10,0);
 a.line(5,12,7,15,2);a.line(m(5),12,m(7),15,2);
 a.rect(6,15,17,23,0);a.rect(7,14,16,23,3);
 a.line(8,15,8,23,2);a.line(12,18,16,18,1);
 const floor=canvas().p;
 // Down, left, up, right. The up face mirrors the down face vertically
 // instead of rotating it: ANTIC 4 pixels are 2:1, and only the sideways
 // faces may cross the pixel grid. A rotated up face lost its ears and eyes.
 const rotate=p=>p[0].map((_,x)=>p.map(row=>row[x]).reverse());
 const down=a.p,left=rotate(down),up=down.slice().reverse(),right=rotate(rotate(left));
 return [down,left,up,right].map(face=>face.map((row,y)=>row.map((c,x)=>c<0?floor[y][x]:c)));
}
// Per design: the 24-pixel source tiles, plus the faces for the smaller zooms.
const built=new Map(designs.map(d=>{design=d;return [d.id,buildTiles()];}));
const smallFaces=new Map(designs.map(d=>{design=d;return [d.id,faces(11.5)];}));
// Regression: every rotated face has exactly one centered trunk port.
// Check artwork, not merely the renderer's chosen tile number.
for(let direction=0;direction<4;direction++){
 const face=built.get('classic')[31+direction];
 const edges=[face[23],face.map(r=>r[0]),face[0],face.map(r=>r[23])];
 for(let edge=0;edge<4;edge++)for(let i=0;i<24;i++){
  const coloured=edges[edge][i]===2||edges[edge][i]===3;
  const expected=edge===direction && i>=7 && i<=16;
  if(coloured!==expected)throw Error(`Broken elephant port: direction ${direction}, edge ${edge}, pixel ${i}`);
 }
}
// Square display tiles: ANTIC 4 pixels are twice as wide as they are tall.
// Sample to 4x8, 8x16 and 12x24 mode pixels, displayed as 8x8, 16x16, 24x24.
// The large tile takes every odd source column (exactly 2:1). The smaller
// tiles spread their samples from the first to the last source pixel, which
// keeps the floor's edge lines and samples mirror-symmetric shapes evenly.
function samplePixels(p,width,height){
 if(width*2===N)return Array.from({length:height},(_,y)=>Array.from({length:width},(_,x)=>p[y][2*x+1]));
 const at=(i,n)=>Math.round(i*(N-1)/(n-1));
 return Array.from({length:height},(_,y)=>Array.from({length:width},(_,x)=>p[at(y,height)][at(x,width)]));
}
// The smallest zoom has hand-drawn 4x8 tiles: shrinking the large art to a
// quarter of its width left blobs. Trunks run two pixels wide through the
// middle columns and four rows tall across them, square on screen.
const SMALL_SHARED=designs.find(d=>d.id==='classic').small;
function smallTiles(d){
 // A design's own small floor; a sampled divider line would fill a quarter.
 const floor=d.small.floor?d.small.floor.map(r=>[...r].map(Number)):samplePixels(built.get(d.id)[0],4,8);
 const own=name=>d.small[name]?{rows:d.small[name],raw:true}:{rows:SMALL_SHARED[name],raw:false};
 const grid=name=>{const {rows,raw}=own(name);return rows.map(r=>[...r].map(c=>c==='.'?-1:raw?+c:d.roles[+c]));};
 const flipv=g=>g.slice().reverse(),fliph=g=>g.map(r=>r.slice().reverse());
 const merge=g=>g.map((r,y)=>r.map((c,x)=>c<0?floor[y][x]:c));
 const trunk=mask=>{
  const g=Array.from({length:8},()=>Array(4).fill(-1));
  const body=(x0,y0,x1,y1)=>{for(let y=y0;y<=y1;y++)for(let x=x0;x<=x1;x++)g[y][x]=d.roles[3];};
  body(1,2,2,5);
  if(mask&1)body(1,0,2,1);if(mask&4)body(1,6,2,7);
  if(mask&8)body(0,2,0,5);if(mask&2)body(3,2,3,5);
  // Single-ended pieces are the flared, two-nostril tip.
  const tip={4:['....','3333','3003','3333','.33.','.33.','.33.','.33.'],
   8:['....','..33','3330','3333','3333','3330','..33','....']};
  const art=tip[mask]?tip[mask]:mask===1?tip[4].slice().reverse():mask===2?tip[8].map(r=>[...r].reverse().join('')):null;
  return art?art.map(r=>[...r].map(c=>c==='.'?-1:d.roles[+c])):g;
 };
 const element={2:'ring',3:'boulder',4:'pause',5:'spiral',6:'trap',7:'portal',8:'arrow_up',9:'arrow_right',
  10:'arrow_up',11:'arrow_right',12:'lock',13:'key',14:'lock_open'};
 const tiles=[];
 for(let type=0;type<15;type++){
  if(!element[type]){tiles.push(floor);continue;}
  let g=grid(element[type]);
  if(type===10)g=flipv(g);
  if(type===11)g=fliph(g);
  tiles.push(merge(g));
 }
 for(let mask=0;mask<16;mask++)tiles.push(merge(trunk(mask)));
 const down=grid('face_down'),left=grid('face_left');
 tiles.push(...[down,left,flipv(down),fliph(left)].map(merge));
 return tiles;
}
function nativeTiles(id,cols,rows){
 if(cols===1)return smallTiles(designs.find(d=>d.id===id));
 const tiles=built.get(id).slice();
 if(cols<3)tiles.splice(31,4,...smallFaces.get(id));
 return tiles.map(p=>samplePixels(p,cols*4,rows*8));
}
const SIZES=[['small',1,1],['medium',2,2],['large',3,3]];
const campaign=JSON.parse(fs.readFileSync(path.join(__dirname,'bimbaj.json'),'utf8'));
const chosen=designs.find(d=>d.id===(campaign.design||'classic'));
if(!chosen)throw Error(`bimbaj.json: unknown design ${campaign.design}`);
const tiles=built.get(chosen.id);
const out=[`; Generated by generate_tiles.js from the ${chosen.name} design. Three zoom sizes, 35 tiles each.`];
for(const [name,cols,rows] of SIZES){
 const pixels=nativeTiles(chosen.id,cols,rows);
 out.push(`tile_${name}_lo`, '        dta '+tiles.map((_,i)=>`<tile_${name}_${i}`).join(','));
 out.push(`tile_${name}_hi`, '        dta '+tiles.map((_,i)=>`>tile_${name}_${i}`).join(','));
 for(let i=0;i<tiles.length;i++){
  const bytes=[];
  for(let cy=0;cy<rows;cy++)for(let cx=0;cx<cols;cx++)for(let y=0;y<8;y++){
   let b=0;for(let x=0;x<4;x++){
    b=(b<<2)|pixels[i][cy*8+y][cx*4+x];
   }bytes.push(b);
  }
  out.push(`tile_${name}_${i}`);
  for(let k=0;k<bytes.length;k+=16)out.push('        dta '+bytes.slice(k,k+16).map(b=>'$'+b.toString(16).padStart(2,'0')).join(','));
 }
}
fs.writeFileSync(path.join(__dirname,'tiles.inc'),out.join('\n')+'\n');

// The design's colour registers. Floor, blue and copper step per character
// row of a tile; the board DLIs load them.
const hex=v=>'$'+v.toString(16).toUpperCase().padStart(2,'0');
fs.writeFileSync(path.join(__dirname,'theme.inc'),[
 `; Generated by generate_tiles.js from the ${chosen.name} design. Do not edit.`,
 `THEME_BACKGROUND = ${hex(chosen.background[0])}`,
 `THEME_LIGHT = ${hex(chosen.light[0])}`,
 `THEME_STATUS = ${hex(chosen.status[0])}`,
 `gradient_blue dta ${chosen.blue.map(hex).join(',')}`,
 `gradient_copper dta ${chosen.copper.map(hex).join(',')}`,
 `gradient_stone dta ${chosen.floor.map(hex).join(',')}`,
 ''].join('\n'));

// Approximate NTSC colours for Atari palette values (YIQ).
function atariRgb(c){
 const hue=c>>4,lum=(c&0x0E)/14;
 let y=0.06+lum*0.88,i=0,q=0;
 if(hue){const angle=-0.35+(hue-1)*(2*Math.PI/15);i=0.24*Math.cos(angle);q=0.24*Math.sin(angle);}
 const channel=v=>Math.max(0,Math.min(255,Math.round(v*255))).toString(16).padStart(2,'0');
 return '#'+channel(y+0.956*i+0.621*q)+channel(y-0.272*i-0.647*q)+channel(y-1.106*i+1.703*q);
}
// Attribute $80 (tile_attributes in bimbaj.asm) selects copper for colour 3.
const attributes=[0,0,0,0x80,0x80,0,0x80,0,0x80,0x80,0x80,0x80,0x80,0x80,0x80];
const copper=tiles.map((_,i)=>(attributes[i]||0)===0x80);

// A native-pixel atlas of the chosen design for reviewing it in a browser.
{
 const pick=(p,i,y)=>p===3?(copper[i]?chosen.copper:chosen.blue)[Math.floor(y/8)]
  :[chosen.background[0],chosen.floor[Math.floor(y/8)],chosen.light[0]][p];
 let svg=`<svg xmlns="http://www.w3.org/2000/svg" width="960" height="480" viewBox="0 0 240 120"><rect width="240" height="120" fill="${atariRgb(chosen.background[0])}"/>`;
 const preview=nativeTiles(chosen.id,3,3);
 for(let i=0;i<tiles.length;i++)for(let y=0;y<24;y++)for(let x=0;x<12;x++)
  svg+=`<rect x="${(i%10)*24+x*2}" y="${Math.floor(i/10)*30+y}" width="2" height="1" fill="${atariRgb(pick(preview[i][y][x],i,y))}"/>`;
 fs.writeFileSync(path.join(__dirname,'tiles-preview.svg'),svg+'</svg>');
}

// Every design at the game's native resolution for bimbaj-editor.html: one
// '0'-'3' digit per ANTIC pixel, rows of 4, 8 or 12 pixels per zoom size.
fs.writeFileSync(path.join(__dirname,'bimbaj-tiles.js'),
 '// Generated by generate_tiles.js. Do not edit.\nwindow.BIMBAJ_DESIGNS = '+JSON.stringify(designs.map(d=>{
  const entry={id:d.id,name:d.name,about:d.about,copper,colours:{
   background:atariRgb(d.background[0]),light:atariRgb(d.light[0]),status:atariRgb(d.status[0]),
   floor:d.floor.map(atariRgb),blue:d.blue.map(atariRgb),copper:d.copper.map(atariRgb)}};
  for(const [name,cols,rows] of SIZES)
   entry[name]=nativeTiles(d.id,cols,rows).map(p=>p.map(row=>row.join('')).join(''));
  return entry;
 }))+';\n');
