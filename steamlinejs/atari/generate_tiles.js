#!/usr/bin/env node
'use strict';
// ANTIC 4 artwork. Each screen row has its own RAM font, allowing large tiles
// without the 128-character limit of a shared font. Pixel 3 can be blue or
// copper per character; display-list interrupts add vertical colour shading.
const fs = require('fs');
const path = require('path');
const N = 24;
function canvas(floor = true, transparent = false) {
 const p = Array.from({length:N},()=>Array(N).fill(transparent ? -1 : 0));
 const put=(x,y,c)=>{x=Math.round(x);y=Math.round(y);if(x>=0&&x<N&&y>=0&&y<N)p[y][x]=c;};
 const rect=(x0,y0,x1,y1,c)=>{for(let y=y0;y<=y1;y++)for(let x=x0;x<=x1;x++)put(x,y,c);};
 const ellipse=(cx,cy,rx,ry,c)=>{for(let y=0;y<N;y++)for(let x=0;x<N;x++)if(((x-cx)/rx)**2+((y-cy)/ry)**2<=1)put(x,y,c);};
 const line=(x0,y0,x1,y1,c,width=1)=>{const steps=Math.max(Math.abs(x1-x0),Math.abs(y1-y0));for(let i=0;i<=steps;i++){const t=steps?i/steps:0;rect(Math.round(x0+(x1-x0)*t),Math.round(y0+(y1-y0)*t),Math.round(x0+(x1-x0)*t)+width-1,Math.round(y0+(y1-y0)*t)+width-1,c);}};
 if(floor){
  // Quiet slate inlay: no bright bars competing with the puzzle pieces.
  rect(0,0,23,23,1);line(0,23,23,23,0);line(23,0,23,23,0);
  put(3,5,0);put(17,16,0);
 }
 return {p,put,rect,ellipse,line};
}
const tiles=[];
let rightFacingHead;
for(let type=0;type<15;type++){
 const a=canvas(type!==3),{rect,ellipse,line,put}=a;
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
{
 // A compact elephant seen from above. Ears, eyes and forehead rotate as one
 // sprite; the background never rotates. Symmetric 10-pixel ports meet every
 // straight/bend without the old extra nose strip tearing the face apart.
 const a=canvas(false,true);
 a.ellipse(5,9,4,7,0);a.ellipse(18,9,4,7,0);
 a.ellipse(5,9,3,6,3);a.ellipse(18,9,3,6,3);
 a.ellipse(11.5,9,7.5,8,0);a.ellipse(11.5,9,6.5,7,3);
 a.line(9,3,13,3,2);
 a.rect(6,7,8,10,2);a.rect(15,7,17,10,2);
 a.rect(7,8,8,10,0);a.rect(15,8,16,10,0);
 a.line(5,12,7,15,2);a.line(18,12,16,15,2);
 a.rect(6,15,17,23,0);a.rect(7,14,16,23,3);
 a.line(8,15,8,23,2);a.line(12,18,16,18,1);
 const floor=canvas().p;
 let face=a.p;
 for(let direction=0;direction<4;direction++){
  if(direction===3)rightFacingHead=face;
  tiles.push(face.map((row,y)=>row.map((c,x)=>c<0?floor[y][x]:c)));
  face=face[0].map((_,x)=>face.map(row=>row[x]).reverse());
 }
}
// Regression: every rotated face has exactly one centered trunk port.
// Check artwork, not merely the renderer's chosen tile number.
for(let direction=0;direction<4;direction++){
 const face=tiles[31+direction];
 const edges=[face[23],face.map(r=>r[0]),face[0],face.map(r=>r[23])];
 for(let edge=0;edge<4;edge++)for(let i=0;i<24;i++){
  const coloured=edges[edge][i]===2||edges[edge][i]===3;
  const expected=edge===direction && i>=7 && i<=16;
  if(coloured!==expected)throw Error(`Broken elephant port: direction ${direction}, edge ${edge}, pixel ${i}`);
 }
}
// Square display tiles: ANTIC 4 pixels are twice as wide as they are tall.
// Sample to 4x8, 8x16 and 12x24 mode pixels, displayed as 8x8, 16x16, 24x24.
function samplePixels(p,width,height){
 return Array.from({length:height},(_,y)=>Array.from({length:width},(_,x)=>
  p[Math.min(N-1,Math.floor((y+.5)*N/height))][Math.min(N-1,Math.floor((x+.5)*N/width))]));
}
function nativeTiles(cols,rows){
 const width=cols*4,height=rows*8;
 const result=tiles.map(p=>samplePixels(p,width,height));
 const right=samplePixels(rightFacingHead,width,height),floor=result[0];
 // Rotate the already sampled right-facing head counterclockwise. Rotating
 // the 24x24 source first selected different eye/ear pixels on ANTIC's 2:1
 // grid. Expand to display proportions, rotate, then sample the pixel pairs.
 // The transparent head alone rotates; the floor retains its own orientation.
 result[33]=Array.from({length:height},(_,y)=>Array.from({length:width},(_,x)=>{
  const colour=right[Math.floor((x+.5)*height/width)][width-1-Math.floor(y*width/height)];
  return colour<0?floor[y][x]:colour;
 }));
 return result;
}
const out=['; Generated by generate_tiles.js. Three zoom sizes, 35 tiles each.'];
for(const [name,cols,rows] of [['small',1,1],['medium',2,2],['large',3,3]]){
 const pixels=nativeTiles(cols,rows);
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

// A native-pixel atlas for reviewing the generated artwork in a browser.
const colours=['#080e19','#303030','#c4ccd2','#70bfd8'];
let svg='<svg xmlns="http://www.w3.org/2000/svg" width="960" height="480" viewBox="0 0 240 120"><rect width="240" height="120" fill="#080e19"/>';
const preview=nativeTiles(3,3);
for(let i=0;i<tiles.length;i++)for(let y=0;y<24;y++)for(let x=0;x<12;x++){
 const colour=preview[i][y][x];
 svg+=`<rect x="${(i%10)*24+x*2}" y="${Math.floor(i/10)*30+y}" width="2" height="1" fill="${colours[colour]}"/>`;
}
fs.writeFileSync(path.join(__dirname,'tiles-preview.svg'),svg+'</svg>');
