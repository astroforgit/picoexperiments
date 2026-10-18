"use strict";
// Mechanical conversion to 160x72, 16-colour pictures, displayed at 2x scale.
// Store raw packed pixels in unused VRAM tails, then spare BASIC-off CPU RAM.
const fs=require('fs');
module.exports=function({convert,indexed,palette,vram,gaps,limits}){
 const names=['father-reveal','wedding-ceremony','wedding-party'];
 const available=gaps.map((g,i)=>[limits[i],g[1],true]).filter(g=>g[1]>g[0]);
 available.push([0xa000,0xc000,false]);
 const cpu=Buffer.alloc(8192),chunks=[],first=[],palettes=[],allocations=[];let cpuUsed=0;
 for(const [page,name] of names.entries()){
  const rgba=convert([`../../art/outro-v1/${name}.png`,'-filter','Box','-resize','160x72!','-dither','None','-colors','16','-depth','8','rgba:-']);
  const pixels=indexed(rgba),pal=[...new Set(pixels)];
  if(pal.length>16)throw Error('Outro palette exceeds sixteen colours');
  while(pal.length<16)pal.push(pal[0]);palettes.push(...pal);
  const packed=Buffer.alloc(pixels.length/2);
  for(let i=0;i<pixels.length;i+=2)packed[i/2]=pal.indexOf(pixels[i])*16+pal.indexOf(pixels[i+1]);
  fs.writeFileSync(`generated/outro-${page+1}.bin`,packed);
  const rgb=Buffer.alloc(320*144*3);
  for(let y=0;y<144;y++)for(let x=0;x<320;x++)for(let c=0;c<3;c++)rgb[(y*320+x)*3+c]=palette[pixels[(y>>1)*160+(x>>1)]][c];
  convert(['-size','320x144','-depth','8','rgb:-',`generated/outro-${page+1}.png`],rgb);
  first.push(chunks.length);let offset=0;
  while(offset<packed.length){
   const slot=available.find(g=>g[1]>g[0]);
   if(!slot)throw Error('Ending pictures exceed spare VRAM and BASIC-off RAM');
   const [address,end,isVram]=slot,n=Math.min(end-address,packed.length-offset);
   chunks.push({address,length:n,bank:isVram?(address>>12)|128:0,ptr:isVram?0x9000+(address&4095):address,page});
   if(isVram){packed.copy(vram,address-0x20000,offset,offset+n);allocations.push([address,address+n,`outro ${page+1}`]);}
   else{packed.copy(cpu,address-0xa000,offset,offset+n);cpuUsed=Math.max(cpuUsed,address-0xa000+n);}
   slot[0]+=n;offset+=n;
  }
 }
 const bytes=(name,a)=>`${name} dta ${a.join(',')}\n`;
 let defs=bytes('first_chunk',first)+bytes('picture_palette',palettes);
 for(const [name,values] of [['chunk_bank',chunks.map(c=>c.bank)],['chunk_lo',chunks.map(c=>c.ptr&255)],['chunk_hi',chunks.map(c=>c.ptr>>8)],['chunk_len_lo',chunks.map(c=>c.length&255)],['chunk_len_hi',chunks.map(c=>c.length>>8)]])defs+=bytes(name,values);
 fs.writeFileSync('generated/outro-content.inc',defs);
 fs.writeFileSync('generated/outro-cpu.bin',cpu.subarray(0,cpuUsed));
 fs.writeFileSync('generated/outro-layout.json',JSON.stringify({width:160,height:72,scale:2,colors:16,chunks,first,palettes,allocations,cpuStart:0xa000,cpuBytes:cpuUsed,vramBytes:allocations.reduce((n,a)=>n+a[1]-a[0],0)},null,2)+'\n');
 console.log(`Outro: ${allocations.reduce((n,a)=>n+a[1]-a[0],0)} spare VRAM bytes + ${cpuUsed}/8192 spare CPU bytes; battle assets unchanged.`);
};
