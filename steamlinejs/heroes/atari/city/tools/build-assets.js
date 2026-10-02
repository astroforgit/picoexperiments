"use strict";
// Mechanical export of raster art to Atari indexed pixels; no runtime PNG decoder.
const fs = require("fs"), path = require("path"), cp = require("child_process");
const root = path.resolve(__dirname, "..");
process.chdir(root);
fs.mkdirSync("generated", {recursive:true});
const content = JSON.parse(fs.readFileSync("content.json", "utf8"));
for (const b of content.buildings) {
  if (!Array.isArray(b.recruitCosts) || b.recruitCosts.length !== 3 ||
      b.recruitCosts.some((v,i,a)=>!Number.isInteger(v)||v<1||v>65535||(i>0&&v<=a[i-1]))) {
    throw Error(`Invalid recruitCosts for ${b.id}: use three increasing 16-bit prices`);
  }
}
function convert(args, input) {
  return cp.execFileSync("convert", args, {input, maxBuffer:32*1024*1024});
}
function rgba(file, w, h) {
  return convert([file, "-filter", "Box", "-resize", `${w}x${h}!`, "-depth", "8", "rgba:-"]);
}
const W=56, H=64, size=W*H;
const [aw,ah] = cp.execFileSync("identify",["-format","%w %h","assets/buildings-source.png"]).toString().split(" ").map(Number);
// Individual files are first-class replacement inputs. Never overwrite an artist's edit.
for (let type=0;type<5;type++) for (let tier=0;tier<3;tier++) {
  const file=`assets/${content.buildings[type].id}-${tier+1}.png`;
  if (fs.existsSync(file)) continue;
  const x=Math.round(type*aw/5), y=Math.round(tier*ah/3);
  const w=Math.round((type+1)*aw/5)-x, h=Math.round((tier+1)*ah/3)-y;
  const raw=convert(["assets/buildings-source.png","-crop",`${w}x${h}+${x}+${y}`,"+repage","-filter","Point","-resize",`${W}x${H}!`,"-depth","8","rgba:-"]);
  for(let i=0;i<raw.length;i+=4) {
    if(raw[i]>190 && raw[i+2]>170 && raw[i+1]<100 && raw[i]>raw[i+1]*1.8 && raw[i+2]>raw[i+1]*1.8) raw[i+3]=0;
  }
  convert(["-size",`${W}x${H}`,"-depth","8","rgba:-",file],raw);
}
if(!fs.existsSync("assets/city-background.png")) {
  convert(["assets/city-top-gate-source.png","-filter","Box","-resize","320x200!","assets/city-background.png"]);
}
const background=rgba("assets/city-background.png",320,200);
if(!fs.existsSync("assets/encounters-background.png")) {
  convert(["assets/encounters-return-source.png","-filter","Box","-resize","320x200!","assets/encounters-background.png"]);
}
const encounters=rgba("assets/encounters-background.png",320,200);
const sprites=content.buildings.flatMap(b=>[1,2,3].map(t=>rgba(`assets/${b.id}-${t}.png`,W,H)));
const [uw,uh]=cp.execFileSync("identify",["-format","%w %h","assets/units-source.png"]).toString().split(" ").map(Number);
for(let type=0;type<5;type++) for(let tier=0;tier<3;tier++) {
  const file=`assets/unit-${content.buildings[type].id}-${tier+1}.png`;
  if(fs.existsSync(file))continue;
  const x=Math.round(type*uw/5),y=Math.round(tier*uh/3);
  const w=Math.round((type+1)*uw/5)-x,h=Math.round((tier+1)*uh/3)-y;
  const raw=convert(["assets/units-source.png","-crop",`${w}x${h}+${x}+${y}`,"+repage","-filter","Point","-resize","32x28!","-depth","8","rgba:-"]);
  for(let i=0;i<raw.length;i+=4)if(raw[i]>190&&raw[i+2]>170&&raw[i+1]<100)raw[i+3]=0;
  convert(["-size","32x28","-depth","8","rgba:-",file],raw);
}
let portraits=content.buildings.flatMap(b=>[1,2,3].map(t=>rgba(`assets/unit-${b.id}-${t}.png`,32,28)));
// Replaceable battle panels and transparent enemy sprites.
function extractAtlas(source, cols, rows, names, w, h) {
  const [sw,sh]=cp.execFileSync('identify',['-format','%w %h',source]).toString().split(' ').map(Number);
  names.forEach((name,i)=>{
    const file=`assets/${name}.png`;if(fs.existsSync(file))return;
    const x=Math.round((i%cols)*sw/cols),y=Math.round(Math.floor(i/cols)*sh/rows);
    const cw=Math.round((i%cols+1)*sw/cols)-x,ch=Math.round((Math.floor(i/cols)+1)*sh/rows)-y;
    convert([source,'-crop',`${cw}x${ch}+${x}+${y}`,'+repage','-filter','Box','-resize',`${w}x${h}!`,file]);
  });
}
const mapNames=['battle-forest','battle-catacombs','battle-caves','battle-ruins'];
const enemyNames=['minibeast','wolf','bat','skeleton','zombie','bone-archer','ogre','warlock','imp'].map(n=>'enemy-'+n);
extractAtlas('assets/battlefields-source.png',2,2,mapNames,320,128);
extractAtlas('assets/battle-enemies-source.png',3,3,enemyNames,32,28);
const obstacleNames=['battle-tree','battle-pillar','battle-rock'];
extractAtlas('assets/battle-obstacles-source.png',3,1,obstacleNames,32,28);
const obstacleSprites=obstacleNames.map(n=>rgba(`assets/${n}.png`,32,28));
const battleMaps=mapNames.map(n=>rgba(`assets/${n}.png`,320,128));
const enemySprites=enemyNames.map(n=>rgba(`assets/${n}.png`,32,28));
const heroSets=['militia','spearman','swordsman','archer','wizard',...content.enemies.map(e=>e.id),'mounted-scout','mounted-ranger','mounted-cavalry'];
const heroFrames=heroSets.map(name=>Array.from({length:6},(_,f)=>rgba(`assets/medieval/${name}-${f}.png`,32,28)));
const heroMapping=[0,1,2,3,3,3,18,19,20,4,4,4,4,4,4,...content.enemies.map((_,i)=>5+i)];
portraits=heroMapping.slice(0,15).map(i=>heroFrames[i][0]);
// Each troop has a local 15-color palette plus transparent, allowing 4bpp
// compressed storage in otherwise unused VRAM gaps.
const heroPalettes=heroFrames.map(frames=>{
 const h=new Map();for(const raw of frames)for(let i=0;i<raw.length;i+=4)if(raw[i+3]>=128){const k=(raw[i]<<16)|(raw[i+1]<<8)|raw[i+2];h.set(k,(h.get(k)||0)+1);}
 const entries=[...h].sort((a,b)=>b[1]-a[1]).slice(0,15).map(([k])=>[(k>>16)&255,(k>>8)&255,k&255]);
 while(entries.length<15)entries.push(entries[0]);return [[0,0,0],...entries];
});
// Weighted median-cut palette shared by all art; 0 transparent, 1..7 UI colors.
const hist=new Map();
for(const raw of [background,encounters,...sprites,...portraits,...battleMaps,...enemySprites,...obstacleSprites,...heroFrames.flat()]) for(let i=0;i<raw.length;i+=4) if(raw[i+3]>=128) {
  const key=((raw[i]>>3)<<10)|((raw[i+1]>>3)<<5)|(raw[i+2]>>3);
  const e=hist.get(key)||[0,0,0,0];
  e[0]+=raw[i];e[1]+=raw[i+1];e[2]+=raw[i+2];e[3]++;hist.set(key,e);
}
const points=[...hist.values()].map(e=>[Math.round(e[0]/e[3]),Math.round(e[1]/e[3]),Math.round(e[2]/e[3]),e[3]]);
function box(p) {
  const ranges=[0,1,2].map(c=>Math.max(...p.map(x=>x[c]))-Math.min(...p.map(x=>x[c])));
  const axis=ranges.indexOf(Math.max(...ranges));
  return {p,axis,score:ranges[axis]*Math.sqrt(p.reduce((n,x)=>n+x[3],0))};
}
let boxes=[box(points)];
while(boxes.length<240) {
  boxes.sort((a,b)=>b.score-a.score);
  const b=boxes.shift(); if(b.p.length<2) {boxes.push(b);break;}
  b.p.sort((a,c)=>a[b.axis]-c[b.axis]);
  const half=b.p.reduce((n,x)=>n+x[3],0)/2;let n=0,k=0;
  while(k<b.p.length-1 && n<half)n+=b.p[k++][3];
  boxes.push(box(b.p.slice(0,k)),box(b.p.slice(k)));
}
const palette=[[0,0,0],[19,27,44],[244,193,85],[255,243,206],[137,156,161],[114,222,142],[246,116,106],[38,53,66],[79,204,235],[241,96,111],[91,105,100],[73,126,141],[182,227,236],[49,78,83],[124,105,78],[83,70,65],...boxes.map(b=>{
  const sum=b.p.reduce((n,x)=>n+x[3],0);
  return [0,1,2].map(c=>Math.round(b.p.reduce((n,x)=>n+x[c]*x[3],0)/sum));
})];
while(palette.length<256)palette.push([0,0,0]);
const cache=new Map();
function indexed(raw) {
  const out=Buffer.alloc(raw.length/4);
  for(let i=0;i<out.length;i++) {
    if(raw[i*4+3]<128)continue;
    const r=raw[i*4],g=raw[i*4+1],b=raw[i*4+2],key=(r<<16)|(g<<8)|b;
    let best=cache.get(key);
    if(best===undefined) {
      let dist=Infinity;best=16;
      for(let p=16;p<256;p++) {
        const c=palette[p],d=2*(r-c[0])**2+3*(g-c[1])**2+(b-c[2])**2;
        if(d<dist){dist=d;best=p;}
      }
      cache.set(key,best);
    }
    out[i]=best;
  }return out;
}
// Original 5x7 uppercase bitmap font, one transparent 6x8 cell per ASCII glyph.
const font={
 A:[14,17,17,31,17,17,17],B:[30,17,17,30,17,17,30],C:[14,17,16,16,16,17,14],D:[30,17,17,17,17,17,30],E:[31,16,16,30,16,16,31],F:[31,16,16,30,16,16,16],G:[14,17,16,23,17,17,15],H:[17,17,17,31,17,17,17],I:[14,4,4,4,4,4,14],J:[7,2,2,2,18,18,12],K:[17,18,20,24,20,18,17],L:[16,16,16,16,16,16,31],M:[17,27,21,21,17,17,17],N:[17,25,21,19,17,17,17],O:[14,17,17,17,17,17,14],P:[30,17,17,30,16,16,16],Q:[14,17,17,17,21,18,13],R:[30,17,17,30,20,18,17],S:[15,16,16,14,1,1,30],T:[31,4,4,4,4,4,4],U:[17,17,17,17,17,17,14],V:[17,17,17,17,17,10,4],W:[17,17,17,21,21,21,10],X:[17,17,10,4,10,17,17],Y:[17,17,10,4,4,4,4],Z:[31,1,2,4,8,16,31],
 "0":[14,17,19,21,25,17,14],"1":[4,12,4,4,4,4,14],"2":[14,17,1,2,4,8,31],"3":[30,1,1,14,1,1,30],"4":[2,6,10,18,31,2,2],"5":[31,16,16,30,1,1,30],"6":[14,16,16,30,17,17,14],"7":[31,1,2,4,8,8,8],"8":[14,17,17,14,17,17,14],"9":[14,17,17,15,1,1,14],
 ":":[0,4,4,0,4,4,0],"-":[0,0,0,31,0,0,0],"/":[1,1,2,4,8,16,16],"> ":[0,16,8,4,8,16,0],"+":[0,4,4,31,4,4,0],".":[0,0,0,0,0,12,12],"!":[4,4,4,4,4,0,4],"?":[14,17,1,2,4,0,4],"(":[2,4,8,8,8,4,2],")":[8,4,2,2,2,4,8]
};
font[">"]=font["> "];font["<"]=[0,1,2,4,2,1,0];
const glyphs=Buffer.alloc(96*48);
for(let ch=32;ch<128;ch++) for(let y=0;y<7;y++)for(let x=0;x<5;x++) {
  if(((font[String.fromCharCode(ch)]||[])[y]||0)&(16>>x))glyphs[(ch-32)*48+y*6+x]=3;
}
const vram=Buffer.alloc(0x5f000);indexed(background).copy(vram);
sprites.forEach((s,i)=>indexed(s).copy(vram,65536+i*size));glyphs.copy(vram,65536+15*size);
heroFrames.slice(0,5).forEach((frames,i)=>indexed(frames[0]).copy(vram,2*65536+i*32*28));
indexed(encounters).copy(vram,3*65536);
const battleAddresses=[0x44000,0x60000,0x6a000,0x74000];
battleMaps.forEach((s,i)=>indexed(s).copy(vram,battleAddresses[i]-0x20000));
// Former static enemy block is now compressed animation storage.
obstacleSprites.forEach((s,i)=>indexed(s).copy(vram,0x3f300-0x20000+i*32*28));
// Runtime UI geometry: five transparent, single-pixel hex outline masks.
// The dark edge shadow and brighter inner edge remain readable over textured art.
const hexColors=[10,8,9,2,13];
hexColors.forEach((color,n)=>{
 const buf=Buffer.alloc(32*24);
 const points=[[16,0],[31,6],[31,17],[16,23],[0,17],[0,6],[16,0]];
 for(let i=0;i<6;i++){
  const [ax,ay]=points[i],[bx,by]=points[i+1],steps=Math.max(Math.abs(bx-ax),Math.abs(by-ay));
  for(let t=0;t<=steps;t++){const x=Math.round(ax+(bx-ax)*t/steps),y=Math.round(ay+(by-ay)*t/steps);buf[y*32+x]=color;}
 }
 buf.copy(vram,0x3e400-0x20000+n*768);
});
// RLE tokens: 1..127 literal bytes, 128..191 transparent pairs,
// 192..255 repeated packed byte, 0 terminator. Decode one pose into $7E000.
function packHero(raw,pal){
 const pixels=[];for(let i=0;i<raw.length;i+=4){
  let best=0,score=Infinity;if(raw[i+3]>=128)for(let n=1;n<16;n++){
   const q=pal[n],d=(raw[i]-q[0])**2+(raw[i+1]-q[1])**2+(raw[i+2]-q[2])**2;
   if(d<score){score=d;best=n;}
  }pixels.push(best);
 }
 const pairs=[];for(let i=0;i<pixels.length;i+=2)pairs.push(pixels[i]*16+pixels[i+1]);
 const out=[];let i=0;
 while(i<pairs.length){
  let n=1;while(n<64&&i+n<pairs.length&&pairs[i+n]===pairs[i])n++;
  if(pairs[i]===0){out.push(128+n-1);i+=n;continue;}
  if(n>=3){out.push(192+n-1,pairs[i]);i+=n;continue;}
  const start=i++;
  while(i<pairs.length&&i-start<127&&pairs[i]!==0&&!(pairs[i]===pairs[i+1]&&pairs[i]===pairs[i+2]))i++;
  out.push(i-start,...pairs.slice(start,i));
 }out.push(0);return Buffer.from(out);
}
const gaps=[[0x2fa00,0x30000],[0x3fd80,0x40000],[0x41180,0x42000],[0x42000,0x43000],[0x43000,0x44000],[0x4e000,0x4f000],[0x4f000,0x50000],[0x5fa00,0x60000],[0x7e380,0x7f000]];
const frames=heroFrames.flatMap((fs,i)=>fs.map(raw=>packHero(raw,heroPalettes[i])));
const addresses=Array(frames.length),limits=gaps.map(g=>g[0]);
// Best-fit, largest first: frames never cross a 4K aperture boundary.
frames.map((f,i)=>i).sort((a,b)=>frames[b].length-frames[a].length).forEach(i=>{
 const choices=gaps.map((g,n)=>[n,g[1]-limits[n]-frames[i].length]).filter(x=>x[1]>=0).sort((a,b)=>a[1]-b[1]);
 if(!choices.length)throw Error('Battle animation VRAM full');const n=choices[0][0];
 addresses[i]=limits[n];frames[i].copy(vram,limits[n]-0x20000);limits[n]+=frames[i].length;
});
const idleCaches=[];
for(let i=0;i<8;i++){
 const n=gaps.findIndex((g,j)=>g[1]-limits[j]>=896);
 if(n<0)break;
 idleCaches.push(limits[n]);limits[n]+=896;
}
const hbytes=(n,a)=>`${n} dta ${a.join(',')}\n`;
if(idleCaches.length<2)throw Error('Insufficient idle cache memory');
let heroDefs=`IDLE_CACHE_COUNT = ${idleCaches.length}\n`+hbytes('hero_set',heroMapping.map(n=>n*6));
heroDefs+=hbytes('hero_palette_lo',heroMapping.map(n=>'<[hero_palette+'+n*16+']'));
heroDefs+=hbytes('hero_palette_hi',heroMapping.map(n=>'>[hero_palette+'+n*16+']'));
heroDefs+=hbytes('idle_cache_lo',idleCaches.map(a=>a&255));
heroDefs+=hbytes('idle_cache_hi',idleCaches.map(a=>(a>>8)&255));
heroDefs+=hbytes('idle_cache_bank',idleCaches.map(a=>a>>16));
heroDefs+=hbytes('hero_bank',addresses.map(a=>a>>12));
heroDefs+=hbytes('hero_src_lo',addresses.map(a=>a&255));
heroDefs+=hbytes('hero_src_hi',addresses.map(a=>0x90|((a>>8)&15)));
const paletteMap=heroPalettes.flatMap(p=>p.map((rgb,i)=>i?indexed(Buffer.from([...rgb,255]))[0]:0));
heroDefs+=hbytes('hero_palette',paletteMap);
fs.writeFileSync('generated/hero-animation.inc',heroDefs);
fs.writeFileSync('generated/hero-animation-layout.json',JSON.stringify({idleCaches,addresses,lengths:frames.map(f=>f.length),cache:[0x7e000,896]},null,2));
console.log(`Packed 126 full-body fighter frames into ${frames.reduce((n,f)=>n+f.length,0)} VRAM bytes.`);
fs.writeFileSync("generated/palette.bin",Buffer.from(palette.flat()));
fs.writeFileSync("generated/vram.bin",vram);
const bytes=(name,a)=>`${name}\n        dta ${a.join(",")}\n`;
const ptr=(name,a)=>bytes(name+"_lo",a.map(x=>"<"+x))+bytes(name+"_hi",a.map(x=>">"+x));
const strings=[],names=[],units=[];
content.buildings.forEach((b,i)=>{
  if(b.costs.length!==3||b.units.length!==3||b.startLevel<0||b.startLevel>3)throw Error("Invalid building");
  names.push(`name_${i}`);strings.push(`name_${i} dta c'${b.name}',0`);
  b.units.forEach((u,t)=>{units.push(`unit_${i}_${t}`);strings.push(`unit_${i}_${t} dta c'${u}',0`);});
});
const defs=[`START_GOLD = ${content.startingGold}`,`SPRITE_W = ${W}`,`SPRITE_H = ${H}`,`FONT_OFFSET = ${15*size}`,
bytes("initial_army",content.startingArmy),bytes("initial_levels",content.buildings.map(b=>b.startLevel)),bytes("plot_x",content.buildings.map(b=>b.x)),bytes("plot_y",content.buildings.map(b=>b.y)),
ptr("building_name",names),ptr("unit_name",units),
bytes("unit_price_lo",content.buildings.flatMap(b=>b.recruitCosts.map(c=>c&255))),bytes("unit_price_hi",content.buildings.flatMap(b=>b.recruitCosts.map(c=>c>>8))),
bytes("unit_family",content.buildings.flatMap((b,i)=>[i,i,i])),bytes("unit_tier",content.buildings.flatMap(b=>[1,2,3])),
bytes("cost_lo",content.buildings.flatMap(b=>b.costs.map(c=>c&255))),bytes("cost_hi",content.buildings.flatMap(b=>b.costs.map(c=>c>>8))),
...['hp','damage','range'].map(k=>bytes("unit_"+k,content.buildings.flatMap(b=>b[k]))),
bytes("sprite_lo",sprites.map((_,i)=>(i*size)&255)),bytes("sprite_hi",sprites.map((_,i)=>(i*size)>>8)),
bytes("portrait_lo",portraits.map((_,i)=>(heroMapping[i]*32*28)&255)),bytes("portrait_hi",portraits.map((_,i)=>(heroMapping[i]*32*28)>>8)),
bytes("glyph_lo",Array.from({length:96},(_,i)=>(15*size+i*48)&255)),bytes("glyph_hi",Array.from({length:96},(_,i)=>(15*size+i*48)>>8)),...strings];
fs.writeFileSync("generated/content.inc",defs.join("\n")+"\n");
const uploads=[];
for(let i=0;i<vram.length/4096;i++){
  fs.writeFileSync(`generated/bank-${i+32}.bin`,vram.subarray(i*4096,(i+1)*4096));
  uploads.push(`        org $6000\n        ins 'generated/bank-${i+32}.bin'\n        ini upload_chunk`);
}
fs.writeFileSync("generated/uploads.inc",uploads.join("\n")+"\n");
console.log("Exported background, 15 buildings, 15 unit portraits, shared palette and font.");
