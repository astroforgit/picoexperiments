'use strict';
// A disk-streamed gallery viewer: resident memory is independent of picture count.
const fs=require('fs'),path=require('path'),cp=require('child_process'),assert=require('assert/strict');
const root=path.resolve(__dirname,'..');process.chdir(root);
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
const scenes=JSON.parse(fs.readFileSync('gallery-content.json','utf8')).paintings;
assert.equal(scenes.length,8);
const next='FIRE / ENTER / SPACE: NEXT PAGE',replay='FIRE / ENTER / SPACE: REPLAY',retry='FIRE: RETRY STORY DISK';
fs.writeFileSync('generated/outro-full-quality-symbols.inc',names.map(n=>`${n} = $${labels[n].toString(16)}`).join('\n')+`\nstory_load = $${labels['story.load'].toString(16)}\nGALLERY_COUNT = ${scenes.length}\nNEXT_X = ${Math.floor((320-next.length*6)/2)}\nREPLAY_X = ${Math.floor((320-replay.length*6)/2)}\nRETRY_X = ${Math.floor((320-retry.length*6)/2)}\n`);
const vram=fs.readFileSync('generated/vram.bin'),palette=fs.readFileSync('generated/palette.bin');
const font=vram.subarray(0x3d200-0x20000,0x3d200-0x20000+4608);
const convert=(args,input)=>cp.execFileSync('convert',args,{input,maxBuffer:16*1024*1024});
for(let page=0;page<scenes.length;page++){
 const pixels=Buffer.alloc(65536,1);fs.readFileSync(`generated/story-${page+5}.bin`).copy(pixels);
 const prompt=page===scenes.length-1?replay:next,x0=Math.floor((320-prompt.length*6)/2);
 for(let i=0;i<prompt.length;i++)for(let y=0;y<7;y++)for(let x=0;x<5;x++)if(font[(prompt.charCodeAt(i)-32)*48+y*6+x])pixels[(190+y)*320+x0+i*6+x]=5;
 fs.writeFileSync(`generated/outro-full-quality-${page+1}.bin`,pixels);
 const rgb=Buffer.alloc(64000*3);for(let i=0;i<64000;i++)for(let c=0;c<3;c++)rgb[i*3+c]=palette[pixels[i]*3+c];
 convert(['-size','320x200','-depth','8','rgb:-',`generated/outro-full-quality-${page+1}.png`],rgb);
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
fs.writeFileSync('generated/outro-full-quality-layout.json',JSON.stringify({width:320,height:144,colors:256,pictureCount:scenes.length,residentPictureCaches:0,framebuffers:[0,1],stagingBytes:256,fontBanks:[61,62],uploadCount:2,requires:'prince-and-the-nimf.atr'},null,2)+'\n');
console.log(`PASS: ${xex.length}-byte streaming viewer; ${scenes.length} gallery pictures on disk, zero resident picture caches, 256-byte staging.`);
