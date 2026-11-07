'use strict';
function monsterVariantKey(m,id){return m.catalog_key||'lich-'+id;}
function monsterVariantFrames(m){return entFrames(m).map(n=>artTile(n>=256?G.sheet2:G.sheet,n&255));}
function monsterVariantPreview(frames){
 const canvas=h('canvas',{class:'px',width:32,height:32}),ctx=canvas.getContext('2d');
 const draw=f=>{ctx.clearRect(0,0,32,32);frames[f%frames.length].forEach((r,y)=>[...r].forEach((c,x)=>{if(c!=='0'){ctx.fillStyle=PAL_CSS[parseInt(c,16)];ctx.fillRect(x*4,y*4,4,4);}}));};
 draw(0);animated.push({canvas,draw});return canvas;
}
function chooseMonsterVariant(m,id,kind){
 const key=monsterVariantKey(m,id),pack=MONSTER_VARIANTS[key],targets=entFrames(m);
 if(!pack||targets.length!==4)return status('This monster needs four animation frames.',true);
 if(G.monsters.some(other=>other!==m&&entFrames(other).some(n=>targets.includes(n))))return status('These animation slots are shared. Assign separate slots in Advanced settings before changing this monster.',true);
 const current=monsterVariantFrames(m);
 if(!['base','alternate'].some(k=>JSON.stringify(current)===JSON.stringify(pack[k]))){
  G.monster_sprite_custom||={};G.monster_sprite_custom[key]=current;
 }
 const frames=kind==='custom'?G.monster_sprite_custom?.[key]:pack[kind];if(!frames)return;
 targets.forEach((n,k)=>artPut(n>=256?G.sheet2:G.sheet,n&255,frames[k]));
 loadSheets();
 // Update pixels only when the same monster/slot mapping is present in the run.
 if(typeof play!=='undefined'&&play.game){
  const live=play.game.g.monsters[id-1];
  if(live&&monsterVariantKey(live,id)===key&&JSON.stringify(entFrames(live))===JSON.stringify(targets)&&!play.game.g.monsters.some((other,i)=>i!==id-1&&entFrames(other).some(n=>targets.includes(n)))){
   targets.forEach((n,k)=>artPut(n>=256?play.game.g.sheet2:play.game.g.sheet,n&255,frames[k]));play.sprites=playSprites(play.game.g);
  }
 }
 changed(`${m.name}: ${kind==='base'?'current design':kind==='custom'?'custom artwork':pack.label} selected. Stats unchanged.`);render();
}
function monsterVariantChoices(m,id){
 const key=monsterVariantKey(m,id),pack=MONSTER_VARIANTS[key];if(!pack)return h('span',{class:'note'},'Custom monster');
 const current=JSON.stringify(monsterVariantFrames(m));
 const options=[['base','Original',pack.base],['alternate',pack.label,pack.alternate]];
 if(G.monster_sprite_custom?.[key])options.push(['custom','My custom art',G.monster_sprite_custom[key]]);
 return h('div',{class:'monster-variant-choices'},...options.map(([kind,label,frames])=>h('button',{
   class:'small monster-variant'+(current===JSON.stringify(frames)?' primary':''),'aria-pressed':String(current===JSON.stringify(frames)),
   'aria-label':`${m.name}: ${kind} sprite`,onclick:()=>chooseMonsterVariant(m,id,kind)
 },monsterVariantPreview(frames),h('span',{},label))));
}
