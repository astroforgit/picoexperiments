const assert=require('node:assert/strict'),C=require('./core.js');
for(const bpp of [1,2])for(const flipY of [false,true]){
 const a={offset:3,width:8,height:3,bpp,flipY},b=new Uint8Array(20).fill(0xa5),before=b.slice(),n=8*3*bpp/8;
 for(let y=0;y<3;y++)for(let x=0;x<8;x++)C.paint(b,a,x,y,(x+y)%(1<<bpp));
 for(let y=0;y<3;y++)for(let x=0;x<8;x++)assert.equal(C.pixel(b,a,x,y),(x+y)%(1<<bpp));
 assert.deepEqual(b.slice(0,3),before.slice(0,3));assert.deepEqual(b.slice(3+n),before.slice(3+n));
 const pixels=C.pixels(b,a);C.transform(b,a,(x,y)=>[7-x,y]);C.transform(b,a,(x,y)=>[7-x,y]);assert.deepEqual(C.pixels(b,a),pixels);
 C.transform(b,a,(x,y)=>[x+1,y]);C.transform(b,a,(x,y)=>[x-1,y]);assert.deepEqual(C.pixels(b,a),pixels);
}
// Bottom-to-top sprite layout and a bounded connected flood fill.
const a={bank:'ram',offset:1,width:4,height:2,bpp:2,flipY:true},b=new Uint8Array([77,0,0,88]);
C.paint(b,a,0,0,3);assert.deepEqual([...b],[77,0,192,88]);C.fill(b,a,1,1,2);assert.deepEqual([...b],[77,170,234,88]);
let visited=[];C.line(0,0,4,4,(x,y)=>visited.push([x,y]));assert.deepEqual(visited,[[0,0],[1,1],[2,2],[3,3],[4,4]]);
const ref={game:'kult',banks:{ram:''},assets:[a],palettes:[]};
const doc={format:'kult-cetas-editor',version:1,game:'kult',edits:{ram:{1:10}}};assert.equal(C.validateProject(doc,ref),doc.edits);
for(const edits of [{ram:{0:2}},{ram:{1:256}},{ram:{1:1.1}},{unknown:{1:2}}])assert.throws(()=>C.validateProject({...doc,edits},ref));
console.log('Packed pixels, bottom-up rows, bounded edits, fill, transforms and project validation passed.');
