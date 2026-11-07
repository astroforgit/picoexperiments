'use strict';
let objectArtSelection=null,objectArtUndo=null,objectArtColor=7;
function editObjectSprite(n,label){objectArtSelection={n,label};tab='pieces';history.replaceState(null,'','#pieces');render();requestAnimationFrame(()=>document.querySelector('[data-object-painter]')?.scrollIntoView({block:'start'}));}
function objectArtPreview(n){
 const cv=h('canvas',{width:64,height:128,class:'px','aria-label':`Sprite ${n} appearance`}),ctx=cv.getContext('2d');ctx.imageSmoothingEnabled=false;
 ctx.fillStyle='#20242b';ctx.fillRect(0,0,64,128);ctx.drawImage(sprite(1,LIT),0,64,64,64);ctx.drawImage(sprite(n),0,64,64,64);
 const top=overhangFor(G,n);if(top)ctx.drawImage(sprite(top.top),0,0,64,64);return cv;
}
function objectPixelEditor(){
 const {n,label}=objectArtSelection,page=n>=256?2:1,local=n&255,sx=local%16*8,sy=(local>>4)*8;
 const panel=h('section',{class:'panel','data-object-painter':true},h('h3',{},`${label} — sprite ${n}`),h('p',{class:'note'},'Draw pixels below. Color 0 is transparent. Changes save automatically and affect every use of this sprite.'));
 const cv=h('canvas',{width:256,height:256,class:'px','aria-label':'Object pixel editor',style:'touch-action:none;cursor:crosshair'}),ctx=cv.getContext('2d');
 function draw(){const rows=artTile(page===1?G.sheet:G.sheet2,local);for(let y=0;y<8;y++)for(let x=0;x<8;x++){const c=parseInt(rows[y][x],16);ctx.fillStyle=c?PAL_CSS[c]:((x+y)%2?'#303743':'#454d59');ctx.fillRect(x*32,y*32,31,31);}}
 let painting=false;
 function paint(e){const r=cv.getBoundingClientRect(),x=Math.floor((e.clientX-r.left)/r.width*8),y=Math.floor((e.clientY-r.top)/r.height*8);if(x<0||x>7||y<0||y>7)return;setPixel(page,sx+x,sy+y,objectArtColor);draw();}
 function finish(){if(!painting)return;painting=false;changed('Object artwork saved.');if(typeof playSyncArtwork==='function')playSyncArtwork();render();}
 cv.addEventListener('pointerdown',e=>{if(e.button!==0)return;e.preventDefault();objectArtUndo={game:G,n,rows:artTile(page===1?G.sheet:G.sheet2,local)};painting=true;cv.setPointerCapture(e.pointerId);paint(e);});
 cv.addEventListener('pointermove',e=>{if(painting)paint(e);});cv.addEventListener('pointerup',finish);cv.addEventListener('pointercancel',finish);
 const palette=h('div',{class:'actions','aria-label':'Object colors'},...PAL_CSS.map((c,i)=>h('button',{title:i===0?'0 — transparent':`Color ${i}`,'aria-label':i===0?'Transparent':`Color ${i}`,'aria-pressed':String(objectArtColor===i),style:`width:28px;height:28px;padding:0;background:${c};border:2px solid ${objectArtColor===i?'white':'#626975'}`,onclick:()=>{objectArtColor=i;render();}},i===0?'×':'')));
 panel.append(h('div',{class:'row'},cv,h('div',{class:'col'},objectArtPreview(n),palette,h('button',{disabled:!objectArtUndo||objectArtUndo.game!==G,onclick:()=>{const u=objectArtUndo;artPut(u.n>=256?G.sheet2:G.sheet,u.n&255,u.rows);objectArtUndo=null;loadSheets();changed('Last object stroke undone.');if(typeof playSyncArtwork==='function')playSyncArtwork();render();}},'Undo last stroke'),h('button',{onclick:()=>{objectArtSelection=null;render();}},'Close pixel editor'))));draw();return panel;
}
const piecesBeforeObjectArt=VIEWS.pieces;
VIEWS.pieces=()=>{
 const box=h('section',{class:'panel'},h('h2',{},'Interactive objects — graphics'),h('p',{class:'note'},'Edit unused and used appearances separately. Previews include upper tiles where present. This changes artwork only; loot and interaction rules stay the same.'));
 if(objectArtSelection)box.append(objectPixelEditor());
 const cards=h('div',{class:'object-art-cards'});
 const specs=[[4,'Pot','Intact','Broken'],[18,'Second pot','Intact','Broken'],[5,'Chest','Closed','Open'],[6,'Bookcase / shelves','Unsearched','Searched'],[21,'Corpse','Unsearched','Searched'],[25,'Pool','Full','Depleted'],[13,'Spike trap','Armed','Triggered'],[9,'Altar','Appearance',null],[20,'Anvil','Appearance',null]];
 for(const [id,name,before,after] of specs){const m=G.monsters[id-1];if(!m)continue;const states=h('div',{class:'actions'});
  for(const [label,n] of [[before,m.anim],...(after?[[after,m.anim-1]]:[])]){const tile=h('div',{class:'col'},h('strong',{},label),objectArtPreview(n),h('button',{onclick:()=>editObjectSprite(n,`${name}: ${label}`)},`Edit ${label.toLowerCase()} · ${n}`));const top=overhangFor(G,n);if(top)tile.append(h('button',{onclick:()=>editObjectSprite(top.top,`${name}: ${label} upper`)},`Edit upper · ${top.top}`));states.append(tile);}
  cards.append(h('article',{class:'panel'},h('h3',{},name),states));
 }
 box.append(cards);return h('div',{},box,piecesBeforeObjectArt());
};
