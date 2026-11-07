'use strict';
const tileMatch={active:false,source:null,target:null,zoom:1,grid:true,history:[],panel:null,image:null};
function matchMessage(text){tileMatch.message=text;if(tileMatch.panel)tileMatch.panel.querySelector('[data-match-message]').textContent=text;}
function matchSourceData(key='mockup'){return key==='mockup'?MATCH_REFERENCE:MATCH_ATLASES[key];}
function matchSourceId(s){return `MF-${(s.atlas||'mockup').toUpperCase()}-C${s.x+1}-R${s.y+1}`;}
function matchLayoutId(floor){let h=2166136261;for(const c of floor.tiles.join(''))h=Math.imul(h^c.charCodeAt(0),16777619);return (h>>>0).toString(16).padStart(8,'0');}
function matchEnter(cx,cy,atlas='mockup'){
 tileMatch.active=true;tileMatch.source={x:cx,y:cy,atlas};tileMatch.target=null;
 matchMessage('Matching mode — click scenery on the level map, then press Match.');matchRefresh();tileMatch.redraw?.();
}
function matchExit(){tileMatch.active=false;tileMatch.target=null;matchMessage('Matching ended. Normal map controls restored.');matchRefresh();tileMatch.redraw?.();}
function matchTarget(event,inspectOnly=false){
 if(!tileMatch.active&&!inspectOnly)return;
 const {canvas:c,floor,size}=tileMatch.context,r=c.getBoundingClientRect();
 const px=(event.clientX-r.left)*c.width/r.width/size,py=(event.clientY-r.top)*c.height/r.height/size;
 const x=Math.floor(px),y=Math.floor(py);if(x<0||x>=128||y<0||y>=32)return;
 const {tiles,ents}=tileMatch.context.previewGame?bakedGamePreview(tileMatch.context.previewGame):bakeFloor(floor),entity=ents.find(e=>e.i===y*128+x);
 let n=entity?G.monsters[entity.id-1].anim:tiles[y*128+x],kind=entity?'furniture':'terrain';
 const below=ents.find(e=>e.i===(y+1)*128+x),base=below?G.monsters[below.id-1].anim:tiles[(y+1)*128+x],upper=G.overhangs?.[base];
 if(y<31&&upper?.enabled){const rows=artTile(upper.top>=256?G.sheet2:G.sheet,upper.top&255);if(rows[Math.floor((py-y)*8)]?.[Math.floor((px-x)*8)]!=='0'){n=upper.top;kind='upper furniture';}}
 const character=G.monsters.some(m=>!m.prop&&entFrames(m).includes(n));
 const editable=Number.isInteger(n)&&n>=1&&n<=383&&!character;
 const raw=floorGet(floor,x,y),layout=matchLayoutId(floor);
 const id=`SPR-${String(n).padStart(3,'0')} / LEVEL-${lab.depth}-${layout}-X${x}-Y${y}`;
 tileMatch.target={n,x,y,kind:character?'character':kind,game:G,editable,id,raw,entityId:entity?.id};
 matchMessage(`${id} · ${tileMatch.target.kind}${entity?` · entity ${entity.id}`:''}. ${tileMatch.active?(editable?'Press Match to replace every use of this sprite.':'This element is read-only in matching mode.'):'ID selected. Copy the details on the right to discuss this element.'}`);
 matchRefresh();tileMatch.redraw?.();
}
function matchApply(){
 const s=tileMatch.source,t=tileMatch.target;if(!tileMatch.active||!s||!t||!t.editable||t.game!==G)return;
 const n=t.n,page=n>=256?'sheet2':'sheet',old=artTile(G[page],n&255),prior=G.reference_matches?.[n];
 const data=matchSourceData(s.atlas),rows=data.cells[s.y*data.cols+s.x];
 tileMatch.history.push({n,old,prior:prior?clone(prior):null,game:G,style:G.art_style});if(tileMatch.history.length>20)tileMatch.history.shift();
 artPut(G[page],n&255,rows);
 G.reference_matches||={};G.reference_matches[n]={source:data.source,source_sha256:data.sha256,reference_id:matchSourceId(s),column:s.x,row:s.y,crop:[s.x*data.cell,s.y*data.cell,data.cell,data.cell],target:n};
 G.art_style='mixed';G.art_revision=CURRENT_ART_REVISION;loadSheets();if(typeof playSyncArtwork==='function')playSyncArtwork();
 changed(`Matched reference tile ${s.x+1},${s.y+1} to sprite ${n}. Saved to editor and export.`);matchMessage('Matched and saved. Select another tile, Undo last match, or Exit matching to restore normal map controls.');matchRefresh();tileMatch.redraw?.();
}
function matchUndo(){
 const last=tileMatch.history.pop();if(!last||last.game!==G)return;
 const page=last.n>=256?'sheet2':'sheet';artPut(G[page],last.n&255,last.old);
 if(typeof play!=='undefined'&&play.game)artPut(play.game.g[page],last.n&255,last.old);

 if(last.prior)G.reference_matches[last.n]=last.prior;else if(G.reference_matches)delete G.reference_matches[last.n];
 G.art_style=last.style;loadSheets();changed('Last tile match undone.');matchMessage('Last match undone.');if(typeof playSyncArtwork==='function')playSyncArtwork();matchRefresh();tileMatch.redraw?.();
}
function matchDrawOverlay(ctx,size){
 const t=tileMatch.target;if(t){ctx.strokeStyle='#ffec27';ctx.lineWidth=2;ctx.strokeRect(t.x*size+1,t.y*size+1,size-2,size-2);}
}
function matchRefresh(){
 const p=tileMatch.panel;if(!p?.isConnected)return;
 p.querySelector('[data-match-apply]').disabled=!tileMatch.active||!tileMatch.source||!tileMatch.target?.editable;
 p.querySelector('[data-match-exit]').disabled=!tileMatch.active;p.querySelector('[data-match-undo]').disabled=!tileMatch.history.length;
 p.querySelector('[data-match-mode]').textContent=tileMatch.active?'MATCHING · SELECT A MAP TILE':'Reference tile matcher';
 const preview=p.querySelector('[data-match-preview]');preview.replaceChildren();
 if(tileMatch.source){const s=tileMatch.source,d=matchSourceData(s.atlas);preview.append(h('span',{},matchSourceId(s)),artPreview(d.cells[s.y*d.cols+s.x]));}
 if(tileMatch.target){const n=tileMatch.target.n;preview.append(h('span',{},`→ Sprite ${n}`),artPreview(artTile(n>=256?G.sheet2:G.sheet,n&255)));}
 const ids=[];
 if(tileMatch.source){const s=tileMatch.source,d=matchSourceData(s.atlas);ids.push(`Source: ${matchSourceId(s)}; ${d.source}; SHA256 ${d.sha256}; crop ${s.x*d.cell},${s.y*d.cell},${d.cell},${d.cell}`);}
 if(tileMatch.target){const t=tileMatch.target;ids.push(`Map: ${t.id}; ${t.kind}; raw tile ${t.raw}${t.entityId?`; entity ${t.entityId}`:''}; seed ${lab.seed}`);}
 p.querySelector('[data-match-ids]').value=ids.join('\n');
 p.querySelector('[data-copy-ids]').disabled=!ids.length;
 for(const cv of p.querySelectorAll('canvas[data-source]')){
  const key=cv.dataset.source,d=matchSourceData(key),ctx=cv.getContext('2d'),im=tileMatch.images?.[key];ctx.imageSmoothingEnabled=false;ctx.clearRect(0,0,cv.width,cv.height);if(im?.complete&&im.naturalWidth)ctx.drawImage(im,0,0);
  if(tileMatch.grid){ctx.strokeStyle='#ffffff50';ctx.lineWidth=key==='mockup'?2:.25;for(let x=0;x<=d.width;x+=d.cell){ctx.beginPath();ctx.moveTo(x,0);ctx.lineTo(x,d.height);ctx.stroke();}for(let y=0;y<=d.height;y+=d.cell){ctx.beginPath();ctx.moveTo(0,y);ctx.lineTo(d.width,y);ctx.stroke();}}
  const s=tileMatch.source;if(s&&(s.atlas||'mockup')===key){ctx.strokeStyle='#ffec27';ctx.lineWidth=key==='mockup'?8:1;const inset=ctx.lineWidth/2;ctx.strokeRect(s.x*d.cell+inset,s.y*d.cell+inset,d.cell-2*inset,d.cell-2*inset);}
 }

}
function levelMatchPanel(){
 const p=h('aside',{class:'panel reference-panel','aria-label':'Reference tile matcher'});tileMatch.panel=p;
 function sourceCanvas(key){const d=matchSourceData(key),cv=h('canvas',{width:d.width,height:d.height,class:'reference-map px','data-source':key,style:`width:${key==='mockup'?tileMatch.zoom*100:100}%`,'aria-label':d.name+' — click a tile'});
 cv.addEventListener('click',e=>{const r=cv.getBoundingClientRect(),x=Math.min(d.cols-1,Math.max(0,Math.floor((e.clientX-r.left)/r.width*d.cols))),y=Math.min(d.rows-1,Math.max(0,Math.floor((e.clientY-r.top)/r.height*d.rows)));matchEnter(x,y,key);});
 tileMatch.images||={};if(!tileMatch.images[key]){const im=new Image();im.onload=matchRefresh;im.src=d.image;tileMatch.images[key]=im;if(key==='mockup')tileMatch.image=im;}return cv;}
 const cv=sourceCanvas('mockup');
 const ids=h('textarea',{'data-match-ids':true,readonly:true,rows:4,'aria-label':'Selected element IDs',style:'width:100%;box-sizing:border-box'});
 const copy=h('button',{'data-copy-ids':true,disabled:true,onclick:async()=>{ids.select();try{await navigator.clipboard.writeText(ids.value);matchMessage('Selection details copied. Paste them into the chat.');}catch{matchMessage('Selection details selected. Press Ctrl+C to copy.');}}},'Copy selection IDs');
 const zoom=h('select',{'aria-label':'Reference zoom'},...[1,2,3,4].map(n=>h('option',{value:n,selected:n===tileMatch.zoom},`${n*100}%`)));zoom.addEventListener('change',()=>{tileMatch.zoom=+zoom.value;cv.style.width=`${tileMatch.zoom*100}%`;});
 p.append(h('h3',{'data-match-mode':true},'Reference tile matcher'),h('p',{class:'note'},'1. Click a reference tile. 2. Click scenery on the level map. 3. Press Match. Changes apply to all uses of that sprite; collision and game rules stay unchanged.'),h('div',{class:'actions'},h('label',{},'Zoom ',zoom),h('label',{class:'chk'},h('input',{type:'checkbox',checked:tileMatch.grid,onchange:e=>{tileMatch.grid=e.target.checked;matchRefresh();}}),'Grid')),h('div',{class:'reference-scroll'},cv),h('p',{'data-match-message':true,role:'status'},tileMatch.message||'Select a reference tile, then a tile on the level map.'),ids,copy,h('div',{'data-match-preview':true,class:'actions'}),h('div',{class:'actions'},h('button',{class:'primary','data-match-apply':true,disabled:true,onclick:matchApply},'Match'),h('button',{'data-match-undo':true,disabled:true,onclick:matchUndo},'Undo last match'),h('button',{'data-match-exit':true,disabled:true,onclick:matchExit},'Exit matching')),h('p',{class:'note'},'Minifantasy by Krishna Palacio · non-commercial license. The screenshot is sampled on its 80 px grid and converted to the game palette. For tall props, match the upper and bottom tiles separately.'));
 p.append(h('h3',{},'More source tiles'),h('p',{class:'note'},'Original 8×8 atlas cells, including unused scene tiles. Click any cell to show its ID and use Match. Large objects are split into individual cells; columns and rows in source IDs start at 1. Map coordinates start at 0.'));
 for(const [key,d] of Object.entries(MATCH_ATLASES))p.append(h('h4',{},d.name),h('div',{class:'reference-scroll'},sourceCanvas(key)));
 requestAnimationFrame(matchRefresh);return p;
}
