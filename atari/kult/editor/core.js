/* Shared packed-pixel operations. Browser and Node tests use the same code. */
(function(root){
'use strict';
function location(a,x,y){
 if(!Number.isInteger(x)||!Number.isInteger(y)||x<0||y<0||x>=a.width||y>=a.height)throw Error('Pixel outside asset');
 const row=a.flipY?a.height-1-y:y, ppb=8/a.bpp;
 return [a.offset+row*(a.width/ppb)+Math.floor(x/ppb),(ppb-1-x%ppb)*a.bpp];
}
function pixel(bank,a,x,y){const [at,shift]=location(a,x,y);return (bank[at]>>shift)&((1<<a.bpp)-1);}
function paint(bank,a,x,y,color){const [at,shift]=location(a,x,y),mask=(1<<a.bpp)-1;bank[at]=(bank[at]&~(mask<<shift))|((color&mask)<<shift);}
function pixels(bank,a){return Array.from({length:a.width*a.height},(_,i)=>pixel(bank,a,i%a.width,Math.floor(i/a.width)));}
function putPixels(bank,a,p){if(p.length!==a.width*a.height)throw Error('Image dimensions differ');p.forEach((v,i)=>paint(bank,a,i%a.width,Math.floor(i/a.width),v));}
function transform(bank,a,fn){const src=pixels(bank,a);putPixels(bank,a,src.map((_,i)=>{let [x,y]=fn(i%a.width,Math.floor(i/a.width));x=(x+a.width)%a.width;y=(y+a.height)%a.height;return src[y*a.width+x];}));}
function fill(bank,a,x,y,color){const before=pixel(bank,a,x,y);if(before===color)return;const todo=[[x,y]];while(todo.length){const [x,y]=todo.pop();if(x<0||y<0||x>=a.width||y>=a.height||pixel(bank,a,x,y)!==before)continue;paint(bank,a,x,y,color);todo.push([x-1,y],[x+1,y],[x,y-1],[x,y+1]);}}
function line(x0,y0,x1,y1,visit){let dx=Math.abs(x1-x0),sx=x0<x1?1:-1,dy=-Math.abs(y1-y0),sy=y0<y1?1:-1,err=dx+dy;for(;;){visit(x0,y0);if(x0===x1&&y0===y1)break;const e=2*err;if(e>=dy){err+=dy;x0+=sx;}if(e<=dx){err+=dx;y0+=sy;}}}
function changes(original,banks){const out={};for(const key of Object.keys(banks)){const delta={};banks[key].forEach((v,i)=>{if(v!==original[key][i])delta[i]=v;});if(Object.keys(delta).length)out[key]=delta;}return out;}
function validateProject(doc,reference){
 if(!doc||doc.format!=='kult-cetas-editor'||doc.version!==1||doc.game!==reference.game)throw Error('Choose a project for the selected game');
 if(!doc.edits||typeof doc.edits!=='object'||Array.isArray(doc.edits))throw Error('Invalid project edits');
 const allowed={};Object.keys(reference.banks).forEach(k=>allowed[k]=new Set());
 for(const a of reference.assets)for(let i=0;i<a.width*a.height*a.bpp/8;i++)allowed[a.bank].add(a.offset+i);
 for(const p of reference.palettes)for(let i=0;i<p.size;i++)allowed[p.bank].add(p.offset+i);
 for(const [bank,delta] of Object.entries(doc.edits)){
  if(!allowed[bank]||!delta||typeof delta!=='object'||Array.isArray(delta))throw Error('Invalid project bank');
  for(const [key,value] of Object.entries(delta))if(!/^\d+$/.test(key)||!allowed[bank].has(Number(key))||!Number.isInteger(value)||value<0||value>255)throw Error('Project edits unknown bytes');
 }
 return doc.edits;
}
const api={pixel,paint,pixels,putPixels,transform,fill,line,changes,validateProject};
if(typeof module!=='undefined')module.exports=api;else root.PixelCore=api;
})(typeof window==='undefined'?globalThis:window);
