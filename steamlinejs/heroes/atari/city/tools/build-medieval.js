'use strict';
// Mechanical atlas cropping/downsampling for native 32x28 sprites.
const fs=require('fs'),path=require('path'),cp=require('child_process');
const root=path.resolve(__dirname,'..'),src=path.resolve(root,'../../assets/unit-previews');
const sheets=[['medieval-heroes-v2.png',[0,215,425,637,856,1095,1374],[0,220,454,683,910,1145],.115],['medieval-enemies-a-alpha.png',[0,224,447,670,893,1113,1374],[0,147,278,450,635,807,960,1145],.135],['medieval-enemies-b.png',[0,216,432,651,859,1093,1374],[0,225,378,560,755,956,1145],.115]];
sheets.push(['medieval-mounted.png',[0,295,585,876,1165,1468,1774],[0,285,579,887],.088]);
const names=[['militia','spearman','swordsman','archer','wizard'],['minibeast','wolf','bat','skeleton','zombie','bone-archer','ogre'],['warlock','imp','beast','dark','demon','sniper']];
names.push(['mounted-scout','mounted-ranger','mounted-cavalry']);
fs.mkdirSync(path.join(root,'assets/medieval'),{recursive:true});
sheets.forEach(([file,xs,ys,scale],sheet)=>names[sheet].forEach((name,row)=>{for(let f=0;f<6;f++){
 const x=xs[f],y=ys[row],w=xs[f+1]-x,h=ys[row+1]-y;
 const top=sheet===1&&row===6?5:0,bottom=sheet===1&&row===2?9:sheet===2&&row===2&&f===4?9:0;
 cp.execFileSync('convert',[path.join(src,file),'-crop',`${w}x${h-top-bottom}+${x}+${y+top}`,'+repage','-filter','Point','-resize',`${Math.round(w*scale)}x${Math.round((h-top-bottom)*scale)}!`,...((sheet===1||sheet===2)?['-flop']:[]),'-background','none','-gravity','south','-extent','32x28',path.join(root,`assets/medieval/${name}-${f}.png`)]);
}}));
console.log('Converted 21 medieval sprite sets, six poses each.');
