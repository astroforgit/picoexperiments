'use strict';
// Extract the exact indexed pixels used by the native VBXE renderer.
const fs=require('node:fs'),path=require('node:path');
const root=path.resolve(__dirname,'..'),base=path.join(root,'atari/city/generated');
const vram=fs.readFileSync(path.join(base,'vram.bin'));
const defs=fs.readFileSync(path.join(base,'hero-animation.inc'),'utf8');
const values=name=>defs.match(new RegExp('^'+name+' dta (.+)$','m'))[1].split(',').map(Number);
const layout=require(path.join(base,'hero-animation-layout.json'));
const palette=values('hero_palette'),mapping=values('hero_set');
const read=(addr,size)=>vram.subarray(addr-0x20000,addr-0x20000+size);
const encode=b=>Buffer.from(b).toString('base64');
const frames=layout.addresses.map((addr,index)=>{
 const input=read(addr,layout.lengths[index]),pairs=[];let i=0;
 while(input[i]){const token=input[i++];if(token<128)for(let n=0;n<token;n++)pairs.push(input[i++]);else if(token<192)for(let n=0;n<token-127;n++)pairs.push(0);else {const value=input[i++];for(let n=0;n<token-191;n++)pairs.push(value);}}
 if(pairs.length!==448)throw Error('Invalid native frame '+index);
 const set=Math.floor(index/6)*16;return encode(pairs.flatMap(v=>[palette[set+(v>>4)],palette[set+(v&15)]]));
});
const content=require(path.join(root,'atari/city/content.json'));
const art={palette:encode(fs.readFileSync(path.join(base,'palette.bin'))),maps:[0x44000,0x60000,0x6a000,0x74000].map(a=>encode(read(a,320*128))),hexes:Array.from({length:5},(_,i)=>encode(read(0x3e400+i*768,768))),obstacles:Array.from({length:3},(_,i)=>encode(read(0x3f300+i*896,896))),font:encode(read(0x30000+15*56*64,96*48)),frames,units:Object.fromEntries([...content.buildings.flatMap(b=>[1,2,3].map(t=>b.id+'-'+t)),...content.enemies.map(e=>e.id)].map((id,i)=>[id,mapping[i]]))};
fs.writeFileSync(path.join(__dirname,'combat-art.js'),'/* Generated from Atari VBXE build; run node simulation/export-combat-art.cjs to refresh. */\nwindow.GreenhavenCombatArt='+JSON.stringify(art)+';\n');
const htmlPath=path.join(root,'unit-editor.html');
const html=fs.readFileSync(htmlPath,'utf8');
if(html.includes('<script id="combat-native-art">'))fs.writeFileSync(htmlPath,html.replace(/(<script id="combat-native-art">\n)[\s\S]*?(\n<\/script>)/,(_,a,b)=>a+fs.readFileSync(path.join(__dirname,'combat-art.js'),'utf8')+b));
console.log(`Exported four native battlefields, ${frames.length} fighter frames, masks, obstacles and font.`);
