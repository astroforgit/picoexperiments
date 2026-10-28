'use strict';
const tileMatch={active:false,source:null,target:null,zoom:1,grid:true,history:[],panel:null,image:null};
function matchMessage(text){tileMatch.message=text;if(tileMatch.panel)tileMatch.panel.querySelector('[data-match-message]').textContent=text;}
function matchEnter(cx,cy){
 tileMatch.active=true;tileMatch.source={x:cx,y:cy};tileMatch.target=null;
 matchMessage('Matching mode — click scenery on the level map, then press Match.');matchRefresh();tileMatch.redraw?.();
}
function matchExit(){tileMatch.active=false;tileMatch.target=null;matchMessage('Matching ended. Normal map controls restored.');matchRefresh();tileMatch.redraw?.();}
function matchTarget(event){
 if(!tileMatch.active)return;
 const {canvas:c,floor,size}=tileMatch.context,r=c.getBoundingClientRect();
 const px=(event.clientX-r.left)*c.width/r.width/size,py=(event.clientY-r.top)*c.height/r.height/size;
 const x=Math.floor(px),y=Math.floor(py);if(x<0||x>=128||y<0||y>=32)return;
 const {tiles,ents}=tileMatch.context.previewGame?bakedGamePreview(tileMatch.context.previewGame):bakeFloor(floor),entity=ents.find(e=>e.i===y*128+x);
 let n=entity?G.monsters[entity.id-1].anim:tiles[y*128+x],kind=entity?'furniture':'terrain';
 const below=ents.find(e=>e.i===(y+1)*128+x),base=below?G.monsters[below.id-1].anim:tiles[(y+1)*128+x],upper=G.overhangs?.[base];
 if(y<31&&upper?.enabled){const rows=artTile(upper.top>=256?G.sheet2:G.sheet,upper.top&255);if(rows[Math.floor((py-y)*8)]?.[Math.floor((px-x)*8)]!=='0'){n=upper.top;kind='upper furniture';}}
 if(!Number.isInteger(n)||n<1||n>383){matchMessage('That cell is empty. Select existing scenery.');return;}
 if(G.monsters.some(m=>!m.prop&&entFrames(m).includes(n))){matchMessage('Select scenery rather than a character.');return;}
 tileMatch.target={n,x,y,kind,game:G};matchMessage(`Ready: reference ${tileMatch.source.x+1},${tileMatch.source.y+1} → ${kind} sprite ${n}. Match changes every use of this sprite.`);matchRefresh();tileMatch.redraw?.();
}
function matchApply(){
 const s=tileMatch.source,t=tileMatch.target;if(!tileMatch.active||!s||!t||t.game!==G)return;
 const n=t.n,page=n>=256?'sheet2':'sheet',old=artTile(G[page],n&255),prior=G.reference_matches?.[n];
 const rows=MATCH_REFERENCE.cells[s.y*MATCH_REFERENCE.cols+s.x];
 tileMatch.history.push({n,old,prior:prior?clone(prior):null,game:G,style:G.art_style});if(tileMatch.history.length>20)tileMatch.history.shift();
 artPut(G[page],n&255,rows);
 G.reference_matches||={};G.reference_matches[n]={source:MATCH_REFERENCE.source,source_sha256:MATCH_REFERENCE.sha256,column:s.x,row:s.y,crop:[s.x*80,s.y*80,80,80],target:n};
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
 const t=tileMatch.target;if(tileMatch.active&&t){ctx.strokeStyle='#ffec27';ctx.lineWidth=2;ctx.strokeRect(t.x*size+1,t.y*size+1,size-2,size-2);}
}
function matchRefresh(){
 const p=tileMatch.panel;if(!p?.isConnected)return;
 p.querySelector('[data-match-apply]').disabled=!tileMatch.active||!tileMatch.source||!tileMatch.target;
 p.querySelector('[data-match-exit]').disabled=!tileMatch.active;p.querySelector('[data-match-undo]').disabled=!tileMatch.history.length;
 p.querySelector('[data-match-mode]').textContent=tileMatch.active?'MATCHING · SELECT A MAP TILE':'Reference tile matcher';
 const preview=p.querySelector('[data-match-preview]');preview.replaceChildren();
 if(tileMatch.source)preview.append(h('span',{},'Source'),artPreview(MATCH_REFERENCE.cells[tileMatch.source.y*35+tileMatch.source.x]));
 if(tileMatch.target){const n=tileMatch.target.n;preview.append(h('span',{},`→ Sprite ${n}`),artPreview(artTile(n>=256?G.sheet2:G.sheet,n&255)));}
 const cv=p.querySelector('canvas.reference-map'),ctx=cv.getContext('2d');ctx.clearRect(0,0,cv.width,cv.height);if(tileMatch.image?.complete&&tileMatch.image.naturalWidth)ctx.drawImage(tileMatch.image,0,0);
 if(tileMatch.grid){ctx.strokeStyle='#ffffff35';ctx.lineWidth=2;for(let x=0;x<=2800;x+=80){ctx.beginPath();ctx.moveTo(x,0);ctx.lineTo(x,2160);ctx.stroke();}for(let y=0;y<=2160;y+=80){ctx.beginPath();ctx.moveTo(0,y);ctx.lineTo(2800,y);ctx.stroke();}}
 if(tileMatch.source){ctx.strokeStyle='#ffec27';ctx.lineWidth=8;ctx.strokeRect(tileMatch.source.x*80+4,tileMatch.source.y*80+4,72,72);}
}
function levelMatchPanel(){
 const p=h('aside',{class:'panel reference-panel','aria-label':'Reference tile matcher'});tileMatch.panel=p;
 const cv=h('canvas',{width:2800,height:2160,class:'reference-map px',style:`width:${tileMatch.zoom*100}%`,'aria-label':'Minifantasy mockup. Click a grid cell to select source artwork.'});
 cv.addEventListener('click',e=>{const r=cv.getBoundingClientRect(),x=Math.min(34,Math.max(0,Math.floor((e.clientX-r.left)/r.width*35))),y=Math.min(26,Math.max(0,Math.floor((e.clientY-r.top)/r.height*27)));matchEnter(x,y);});
 const zoom=h('select',{'aria-label':'Reference zoom'},...[1,2,3,4].map(n=>h('option',{value:n,selected:n===tileMatch.zoom},`${n*100}%`)));zoom.addEventListener('change',()=>{tileMatch.zoom=+zoom.value;cv.style.width=`${tileMatch.zoom*100}%`;});
 p.append(h('h3',{'data-match-mode':true},'Reference tile matcher'),h('p',{class:'note'},'1. Click a reference tile. 2. Click scenery on the level map. 3. Press Match. Changes apply to all uses of that sprite; collision and game rules stay unchanged.'),h('div',{class:'actions'},h('label',{},'Zoom ',zoom),h('label',{class:'chk'},h('input',{type:'checkbox',checked:tileMatch.grid,onchange:e=>{tileMatch.grid=e.target.checked;matchRefresh();}}),'Grid')),h('div',{class:'reference-scroll'},cv),h('p',{'data-match-message':true,role:'status'},tileMatch.message||'Select a reference tile, then a tile on the level map.'),h('div',{'data-match-preview':true,class:'actions'}),h('div',{class:'actions'},h('button',{class:'primary','data-match-apply':true,disabled:true,onclick:matchApply},'Match'),h('button',{'data-match-undo':true,disabled:true,onclick:matchUndo},'Undo last match'),h('button',{'data-match-exit':true,disabled:true,onclick:matchExit},'Exit matching')),h('p',{class:'note'},'Minifantasy by Krishna Palacio · non-commercial license. The screenshot is sampled on its 80 px grid and converted to the game palette. For tall props, match the upper and bottom tiles separately.'));
 if(!tileMatch.image){tileMatch.image=new Image();tileMatch.image.onload=matchRefresh;tileMatch.image.onerror=()=>matchMessage('Reference image could not load. Reload the editor.');tileMatch.image.src=MATCH_REFERENCE.image;}
 requestAnimationFrame(matchRefresh);return p;
}
