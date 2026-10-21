'use strict';
// A disk-streamed gallery viewer: resident memory is independent of picture count.
const fs=require('fs'),path=require('path'),cp=require('child_process'),assert=require('assert/strict'),crypto=require('crypto');
const root=path.resolve(__dirname,'..');process.chdir(root);
assert(process.argv.slice(2).every(a=>a==='--artist'),'Usage: build-outro-full-quality.js [--artist]');
const artist=process.argv.includes('--artist');
const configFile=artist?'galleryartist-content.json':'gallery-content.json';
const scenes=JSON.parse(fs.readFileSync(configFile,'utf8')).paintings;
assert(scenes.length>0&&scenes.length<=12);
const pageOffset=artist?0:4;
const diskName=artist?'heroes-galleryartist-test.atr':'prince-and-the-nymph.atr';
const labels=Object.fromEntries(fs.readFileSync('generated/city-vbxe.lab','utf8').split('\n').map(s=>s.trim().split(/\s+/)).filter(p=>p.length===3).map(p=>[p[2].toLowerCase(),parseInt(p[1],16)]));
const game=fs.readFileSync('city-vbxe.xex'),parts=[];
for(let i=0;i<game.length;){const start=game.readUInt16LE(i);i+=2;if(start===65535)continue;const end=game.readUInt16LE(i);i+=2;const n=end-start+1;parts.push({start,end,data:game.subarray(i,i+n)});i+=n;}
for(const [name,start,end] of [['core',0x2000,labels.code_end],['runtime',0x6000,labels.runtime_data_end],['ui',0xa000,labels.release_ui_end]]){
 const output=Buffer.alloc(end-start);let copied=0;
 for(const p of parts)if(p.start>=start&&p.end<end&&(name!=='runtime'||p.data.length===end-start)){p.data.copy(output,p.start-start);copied+=p.data.length;}
 assert.equal(copied,output.length,name);fs.writeFileSync(`generated/outro-full-quality-${name}.bin`,output);
}
assert(labels.release_ui_end<=0xb800,'Viewer overlaps release helpers');
const names=['loader_init','upload_chunk','hardware_ok','upload_index','main','setup_antic','setup_xdl','blit_init','load_city_palette','front_bank','back_bank','render_bank','enable_display','wait_blit','present_back_buffer','wait_frame','ch','skstat','kbcode','strig0','draw_text','text_src','text_x','text_y'];
const next='FIRE / ENTER / SPACE: NEXT PAGE',replay='FIRE / ENTER / SPACE: REPLAY',retry='FIRE: RETRY STORY DISK';
fs.writeFileSync('generated/outro-full-quality-symbols.inc',names.map(n=>`${n} = $${labels[n].toString(16)}`).join('\n')+`\nstory_load = $${labels['story.load'].toString(16)}\nGALLERY_COUNT = ${scenes.length}\nGALLERY_PAGE_OFFSET = ${pageOffset}\nNEXT_X = ${Math.floor((320-next.length*6)/2)}\nREPLAY_X = ${Math.floor((320-replay.length*6)/2)}\nRETRY_X = ${Math.floor((320-retry.length*6)/2)}\n`);
const vram=fs.readFileSync('generated/vram.bin'),palette=fs.readFileSync('generated/palette.bin');
const font=vram.subarray(0x3d200-0x20000,0x3d200-0x20000+4608);
const convert=(args,input)=>cp.execFileSync('convert',args,{input,maxBuffer:16*1024*1024});
const colorCache=new Map();
function indexed(raw){
 const result=Buffer.alloc(raw.length/4);
 for(let i=0;i<result.length;i++){
  if(raw[i*4+3]<128)continue;
  const r=raw[i*4],g=raw[i*4+1],b=raw[i*4+2],key=(r<<16)|(g<<8)|b;
  let best=colorCache.get(key);
  if(best===undefined){let distance=Infinity;best=16;
   for(let p=16;p<256;p++){const d=2*(r-palette[p*3])**2+3*(g-palette[p*3+1])**2+(b-palette[p*3+2])**2;if(d<distance){distance=d;best=p;}}
   colorCache.set(key,best);
  }
  result[i]=best;
 }
 return result;
}
function caption(pixels,value,y){
 assert(/^[A-Z0-9 ,.'/-]+$/.test(value)&&value.length<=50,'Unsupported/long caption');
 for(let i=0;i<value.length;i++)for(let row=0;row<7;row++)for(let x=0;x<5;x++)
  if(font[(value.charCodeAt(i)-32)*48+row*6+x])pixels[(y+row)*320+10+i*6+x]=3;
}
const rawPages=[];
for(let page=0;page<scenes.length;page++){
 const pixels=Buffer.alloc(65536,1);
 if(artist){
  const raw=convert([scenes[page].image,'-filter','Box','-resize','320x144!','-depth','8','rgba:-']);
  indexed(raw).copy(pixels);pixels.fill(2,144*320,145*320);
  scenes[page].lines.forEach((line,i)=>caption(pixels,line,149+i*9));
 }else fs.readFileSync(`generated/story-${page+5}.bin`).copy(pixels);
 rawPages.push(Buffer.from(pixels.subarray(0,64000)));
 const prompt=page===scenes.length-1?replay:next,x0=Math.floor((320-prompt.length*6)/2);
 for(let i=0;i<prompt.length;i++)for(let y=0;y<7;y++)for(let x=0;x<5;x++)if(font[(prompt.charCodeAt(i)-32)*48+y*6+x])pixels[(190+y)*320+x0+i*6+x]=5;
 fs.writeFileSync(`generated/outro-full-quality-${page+1}.bin`,pixels);
 const rgb=Buffer.alloc(64000*3);for(let i=0;i<64000;i++)for(let c=0;c<3;c++)rgb[i*3+c]=palette[pixels[i]*3+c];
 convert(['-size','320x200','-depth','8','rgb:-',`generated/outro-full-quality-${page+1}.png`],rgb);
}
let sectors=JSON.parse(fs.readFileSync('generated/story-layout.json')).sectors;
if(artist){
 const sectorCount=4+scenes.length*250,dataBytes=384+(sectorCount-3)*256;
 const disk=Buffer.alloc(16+dataBytes);
 const signature=Buffer.concat([Buffer.from('GHSTORY1'),crypto.createHash('sha256').update(palette).digest().subarray(0,4),crypto.createHash('sha256').update(Buffer.concat(rawPages)).digest().subarray(0,4)]);
 disk.writeUInt16LE(0x296,0);disk.writeUInt16LE((dataBytes/16)&65535,2);disk.writeUInt16LE(256,4);disk[6]=(dataBytes/16)>>16;signature.copy(disk,16);
 sectors=rawPages.map((page,i)=>{const sector=4+i*250;page.copy(disk,16+384+i*64000);return sector;});
 fs.writeFileSync('generated/'+diskName,disk);
 // Only the standalone viewer's copied loader metadata changes. The game
 // executable, game disk and its eight-picture collection remain untouched.
 const file='generated/outro-full-quality-runtime.bin',runtime=fs.readFileSync(file);
 function patch(address,bytes){const offset=address-0x6000;assert(offset>=0&&offset+bytes.length<=runtime.length);bytes.copy(runtime,offset);}
 assert(scenes.length<=labels['story.sector_hi']-labels['story.sector_lo']);
 patch(labels['story.signature'],signature);
 patch(labels['story.sector_lo'],Buffer.from(sectors.map(s=>s&255)));
 patch(labels['story.sector_hi'],Buffer.from(sectors.map(s=>s>>8)));
 fs.writeFileSync(file,runtime);
}
const fonts=Buffer.from(vram.subarray(0x3d000-0x20000,0x3f000-0x20000));
for(let i=0;i<4608;i++)if(fonts[512+i])fonts[512+i]=5;
const uploads=[];
for(let i=0;i<2;i++){const file=`generated/outro-font-bank-${61+i}.bin`;fs.writeFileSync(file,fonts.subarray(i*4096,(i+1)*4096));uploads.push(`        org $6000\n        ins '${file}'\n        ini upload_chunk`);}
fs.writeFileSync('generated/outro-full-quality-uploads.inc',uploads.join('\n')+'\n');
for(const file of fs.readdirSync('generated'))if(/^outro-full-bank-\d+\.bin$/.test(file))fs.unlinkSync('generated/'+file);
cp.execFileSync('mads',['outro-full-quality.asm','-x','-o:outro-full-quality-test.xex','-t:generated/outro-full-quality.lab','-l:generated/outro-full-quality.lst'],{stdio:'inherit'});
const xex=fs.readFileSync('outro-full-quality-test.xex');let uploadsCount=0,inits=0;
for(let i=0;i<xex.length;){const start=xex.readUInt16LE(i);i+=2;if(start===65535)continue;const end=xex.readUInt16LE(i);i+=2;const n=end-start+1;assert(n>0&&i+n<=xex.length);if(start===0x6000&&n===4096)uploadsCount++;if(start===0x2e2)inits++;i+=n;}
assert.equal(uploadsCount,2);assert.equal(inits,4);
const metadata={width:320,height:144,colors:256,pictureCount:scenes.length,residentPictureCaches:0,framebuffers:[0,1],stagingBytes:256,fontBanks:[61,62],uploadCount:2,requires:diskName,configFile,pageOffset,sectors};
fs.writeFileSync('generated/outro-full-quality-layout.json',JSON.stringify(metadata,null,2)+'\n');
fs.copyFileSync('outro-full-quality-test.xex','../heroes-outro-full-quality-test.xex');
fs.copyFileSync('generated/outro-full-quality-layout.json','../outro-full-quality-test.json');
if(artist)fs.copyFileSync('generated/'+diskName,'../'+diskName);
console.log(`PASS: ${xex.length}-byte streaming viewer; ${scenes.length} gallery pictures on disk, zero resident picture caches, 256-byte staging.`);
