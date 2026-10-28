'use strict';
function overhangFor(g,n){const p=g.overhangs?.[n];return p?.enabled?p:null;}
function installTallProps(){
 if(G.overhang_revision==='tall-v1')return;
 G.overhangs||={};
 for(const [key,p] of Object.entries(TALL_PROPS_PACK)){
  const busy=G.monsters.some(m=>entFrames(m).includes(p.top))||artTile(G.sheet2,p.top-256).some(row=>/[1-9a-f]/.test(row));
  const known=ART_STYLES.some(pack=>pack.tiles[key]?.join('')===artTile(G.sheet,+key).join(''));
  if(busy||G.overhangs[key]||!known)continue;
  artPut(G.sheet2,p.top-256,p.topRows);artPut(G.sheet,+key,p.baseRows);
  G.overhangs[key]={top:p.top,enabled:true,name:p.name};
 }
 G.overhang_revision='tall-v1';loadSheets();save();
}
const furnitureBeforeOverhang=VIEWS.pieces;
VIEWS.pieces=()=>{
 const box=h('section',{class:'panel'},h('h2',{},'Tall props and depth overlap'),h('p',{class:'note'},'Each prop is 1 tile wide × 2 tiles tall. Paint its base in Floors & maps. Only the bottom cell is solid; the upper image overlaps characters walking behind it. Apply edits & restart in Play after editing these settings.'));
 const cv=h('canvas',{width:192,height:160,class:'px','aria-label':'Tall prop overlap preview'});let previewKey=Object.keys(G.overhangs||{})[0],position=0;
 function preview(){const c=cv.getContext('2d');c.imageSmoothingEnabled=false;c.fillStyle='#20242b';c.fillRect(0,0,192,160);if(!previewKey)return;const p=G.overhangs[previewKey],x=80,y=80;const heroY=[48,64,112][position];c.strokeStyle='#ff7777';c.strokeRect(x,y,32,32);
  const drawHero=()=>c.drawImage(sprite(G.monsters[0].anim),x,heroY,32,32);
  if(heroY<y)drawHero();c.drawImage(sprite(+previewKey),x,y,32,32);if(p.enabled)c.drawImage(sprite(p.top),x,y-32,32,32);if(heroY>=y)drawHero();
 }
 const add={base:68,top:376};
 box.append(h('div',{class:'actions'},h('label',{},'Base tile ',numInput(add,'base',{min:1,max:255,width:65})),h('label',{},'Upper sprite ',numInput(add,'top',{min:0,max:383,width:65})),h('button',{onclick:()=>{
   if(G.overhangs?.[add.base])return status('That base already has an upper tile.',true);
   if(G.monsters.some(m=>!m.prop&&entFrames(m).includes(add.base)))return status('Choose scenery or furniture, not a character animation.',true);
   G.overhangs||={};G.overhangs[add.base]={top:add.top,enabled:true,name:`Tall tile ${add.base}`};
   if(!G.monsters.some(m=>m.prop&&m.anim===add.base))G.flags[add.base]|=1;
   changed('Tall prop added. Paint its base tile in Floors & maps; restart Play to apply.');render();
 }},'Add tall prop')));
 const rows=h('div',{class:'actions'});
 for(const [key,p] of Object.entries(G.overhangs||{})){
  const cb=h('input',{type:'checkbox',checked:p.enabled,onchange:e=>{p.enabled=e.target.checked;changed();preview();}});
  const top=numInput(p,'top',{min:0,max:383,width:70});top.addEventListener('change',preview);
  rows.append(h('div',{class:'panel'},h('button',{onclick:()=>{previewKey=key;preview();}},p.name||`Tile ${key}`),h('label',{class:'chk'},cb,'Tall'),h('p',{class:'note'},`Solid base tile ${key} · footprint 1×1`),h('label',{},'Upper sprite ',top)));
 }
 const pos=h('select',{'aria-label':'Preview character position'},...['Behind','Under upper tile','In front'].map((s,i)=>h('option',{value:i},s)));pos.addEventListener('change',()=>{position=+pos.value;preview();});
 box.append(rows,h('div',{class:'row'},cv,pos));preview();return h('div',{},box,furnitureBeforeOverhang());
};
installTallProps();render();
