"use strict";
// Standalone quality test: use the game's palette/helpers but keep full-size
// ending pictures in three dedicated VRAM caches. The game build is untouched.
const fs=require('fs'),path=require('path'),cp=require('child_process'),assert=require('assert/strict');
const root=path.resolve(__dirname,'..');process.chdir(root);
const labels=Object.fromEntries(fs.readFileSync('generated/city-vbxe.lab','utf8').split('\n').map(s=>s.trim().split(/\s+/)).filter(p=>p.length===3).map(p=>[p[2].toLowerCase(),parseInt(p[1],16)]));
const game=fs.readFileSync('city-vbxe.xex'),core=Buffer.alloc(labels.code_end-0x2000);
for(let i=0;i<game.length;){const start=game.readUInt16LE(i);i+=2;if(start===65535)continue;const end=game.readUInt16LE(i);i+=2;const n=end-start+1;if(start>=0x2000&&end<0x6000)game.copy(core,start-0x2000,i,i+n);i+=n;}
fs.writeFileSync('generated/outro-full-quality-core.bin',core);
const names=['loader_init','upload_chunk','hardware_ok','upload_index','main','setup_antic','setup_xdl','blit_init','load_city_palette','front_bank','back_bank','render_bank','background_bank','enable_display','copy_background_cache','wait_blit','present_back_buffer','wait_frame','ch','skstat','kbcode','strig0'];
fs.writeFileSync('generated/outro-full-quality-symbols.inc',names.map(n=>{assert(Number.isInteger(labels[n]),n);return `${n} = $${labels[n].toString(16)}`;}).join('\n')+'\n');
const palette=fs.readFileSync('generated/palette.bin'),vram=fs.readFileSync('generated/vram.bin');
const font=vram.subarray(0x3d200-0x20000,0x3d200-0x20000+4608),cache=new Map();
const source=fs.readFileSync('outro.inc','utf8');
const lines=Array.from({length:9},(_,i)=>{const m=source.match(new RegExp(`^s_${i} dta c'([^']*)'`,'m'));assert(m);return m[1];});
const scenes=[{file:'father-reveal',lines:lines.slice(0,4)},{file:'wedding-ceremony',lines:lines.slice(4,6)},{file:'wedding-party',lines:lines.slice(6)}];
const convert=(args,input)=>cp.execFileSync('convert',args,{input,maxBuffer:16*1024*1024});
const uploads=[];
for(const [page,scene] of scenes.entries()){
 const raw=convert([`../../art/outro-v1/${scene.file}.png`,'-filter','Box','-resize','320x144!','-depth','8','rgba:-']);
 const pixels=Buffer.alloc(65536,1);
 for(let i=0;i<320*144;i++){
  const r=raw[i*4],g=raw[i*4+1],b=raw[i*4+2],key=(r<<16)|(g<<8)|b;let best=cache.get(key);
  if(best===undefined){let distance=Infinity;for(let p=16;p<256;p++){const d=2*(r-palette[p*3])**2+3*(g-palette[p*3+1])**2+(b-palette[p*3+2])**2;if(d<distance){distance=d;best=p;}}cache.set(key,best);}
  pixels[i]=best;
 }
 pixels.fill(2,144*320,145*320);
 function text(value,x0,y0,color){assert(x0+value.length*6<=320);for(let i=0;i<value.length;i++)for(let y=0;y<7;y++)for(let x=0;x<5;x++)if(font[(value.charCodeAt(i)-32)*48+y*6+x])pixels[(y0+y)*320+x0+i*6+x]=color;}
 scene.lines.forEach((s,i)=>text(s,10,149+i*9,3));
 const prompt='FIRE / ENTER / SPACE: '+(page===2?'REPLAY':'NEXT PAGE');text(prompt,Math.floor((320-prompt.length*6)/2),190,5);
 fs.writeFileSync(`generated/outro-full-quality-${page+1}.bin`,pixels);
 const rgb=Buffer.alloc(64000*3);for(let i=0;i<64000;i++)for(let c=0;c<3;c++)rgb[i*3+c]=palette[pixels[i]*3+c];
 convert(['-size','320x200','-depth','8','rgb:-',`generated/outro-full-quality-${page+1}.png`],rgb);
 for(let bank=0;bank<16;bank++){const id=32+page*16+bank,file=`generated/outro-full-bank-${id}.bin`;fs.writeFileSync(file,pixels.subarray(bank*4096,(bank+1)*4096));uploads.push(`        org $6000\n        ins '${file}'\n        ini upload_chunk`);}
}
fs.writeFileSync('generated/outro-full-quality-uploads.inc',uploads.join('\n')+'\n');
cp.execFileSync('mads',['outro-full-quality.asm','-x','-o:outro-full-quality-test.xex','-t:generated/outro-full-quality.lab','-l:generated/outro-full-quality.lst'],{stdio:'inherit'});
const xex=fs.readFileSync('outro-full-quality-test.xex');let count=0,inits=0;
for(let i=0;i<xex.length;){const start=xex.readUInt16LE(i);i+=2;if(start===65535)continue;const end=xex.readUInt16LE(i);i+=2;const n=end-start+1;assert(n>0&&i+n<=xex.length);if(start===0x6000){assert.equal(n,4096);count++;}if(start===0x2e2)inits++;i+=n;}
assert.equal(count,48);assert.equal(inits,50);
fs.writeFileSync('generated/outro-full-quality-layout.json',JSON.stringify({width:320,height:144,scale:1,colors:256,sourceBanks:[2,3,4],uploadCount:count},null,2)+'\n');
console.log(`PASS: ${xex.length}-byte standalone viewer, three 320x144 pictures, original shared 256-colour palette, 48 graphics uploads.`);
