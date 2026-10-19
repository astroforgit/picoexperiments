'use strict';
// Full-resolution story pages live on D1:, never in the gameplay asset banks.
const fs=require('fs'),assert=require('assert/strict'),crypto=require('crypto');
module.exports=function({convert,indexed,palette,font}) {
 const scenes=JSON.parse(fs.readFileSync('story-content.json','utf8'));
 assert.equal(scenes.length,4);
 const pages=scenes.map((scene,i)=>{
  const rgba=convert([scene.image,'-filter','Box','-resize','320x144!','-depth','8','rgba:-']);
  const pixels=Buffer.alloc(64000,1);indexed(rgba).copy(pixels);
  pixels.fill(2,144*320,145*320);
  function text(value,x0,y0){
   assert(x0+value.length*6<=320);
   for(let j=0;j<value.length;j++)for(let y=0;y<7;y++)for(let x=0;x<5;x++)
    if(font[(value.charCodeAt(j)-32)*48+y*6+x])pixels[(y0+y)*320+x0+j*6+x]=3;
  }
  scene.lines.forEach((s,j)=>text(s,10,149+j*9));
  fs.writeFileSync(`generated/story-${i+1}.bin`,pixels);
  const rgb=Buffer.alloc(64000*3);
  for(let j=0;j<64000;j++)for(let c=0;c<3;c++)rgb[j*3+c]=palette[pixels[j]][c];
  convert(['-size','320x200','-depth','8','rgb:-',`generated/story-${i+1}.png`],rgb);
  return pixels;
 });
 const sectorCount=1440,dataBytes=3*128+(sectorCount-3)*256;
 const disk=Buffer.alloc(16+dataBytes),signature=Buffer.concat([
  Buffer.from('GHSTORY1'),crypto.createHash('sha256').update(Buffer.from(palette.flat())).digest().subarray(0,4),
  crypto.createHash('sha256').update(Buffer.concat(pages)).digest().subarray(0,4)]);
 disk.writeUInt16LE(0x296,0);disk.writeUInt16LE((dataBytes/16)&65535,2);disk.writeUInt16LE(256,4);disk[6]=(dataBytes/16)>>16;
 signature.copy(disk,16);
 const sectors=pages.map((page,i)=>{const start=4+i*250;page.copy(disk,16+384+(start-4)*256);return start;});
 fs.writeFileSync('generated/heroes-story.atr',disk);
 fs.writeFileSync('generated/story-content.inc',
  `signature dta ${[...signature].join(',')}\nsector_lo dta ${sectors.map(s=>s&255).join(',')}\nsector_hi dta ${sectors.map(s=>s>>8).join(',')}\n`);
 fs.writeFileSync('generated/story-layout.json',JSON.stringify({width:320,height:144,colors:256,pageBytes:64000,sectorCount,sectors,signature:[...signature]},null,2)+'\n');
 console.log('Story disk: four full-resolution 320x144 pictures; no resident picture data.');
};
