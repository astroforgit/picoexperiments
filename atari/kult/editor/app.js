'use strict';
const $=id=>document.getElementById(id), C=PixelCore;
const PALETTES={warm:['#10151b','#616e81','#b8baaa','#f5e9ba'],gray:['#0b0e12','#555b64','#a6adb7','#f5f5f5'],blue:['#071926','#23516b','#58a9b5','#e2f7ef'],green:['#07190c','#245c2c','#73a942','#d7f4a1']};
const sessions={};let state=null,request=0,tool='pencil',ink=3,stroke=null,clip=null,lastPoint=null,saveTimer,previewFrame=0,lastPreview=0;
function status(message,error=false){$('status').textContent=message;$('status').classList.toggle('error',error);}
function asset(){return state?.reference.assets.find(a=>a.id===state.selected);}
function colours(a=asset()){const p=PALETTES[$('previewPalette').value];return a.bpp===1?[p[0],p[3]]:p;}
function decode(b64){return Uint8Array.from(atob(b64),c=>c.charCodeAt(0));}
function snapshot(){return Object.fromEntries(Object.entries(state.banks).map(([k,v])=>[k,v.slice()]));}
function documentFor(s=state){return {format:'kult-cetas-editor',version:1,game:s.reference.game,edits:C.changes(s.original,s.banks)};}
function draft(){try{localStorage.setItem('pixel-workshop-'+state.reference.game,JSON.stringify(documentFor()));$('saveState').textContent='Draft saved in this browser · originals untouched';}catch(e){$('saveState').textContent='Draft storage unavailable — save a project file';}}
function scheduleSave(){clearTimeout(saveTimer);saveTimer=setTimeout(draft,250);}
function finish(before,message){
 const delta=[];for(const [bank,data] of Object.entries(state.banks))for(let i=0;i<data.length;i++)if(data[i]!==before[bank][i])delta.push([bank,i,before[bank][i],data[i]]);
 if(!delta.length)return;
 state.undo.push(delta);if(state.undo.length>100)state.undo.shift();state.redo=[];
 refresh();renderLibrary();scheduleSave();status(message||`${delta.length} byte${delta.length===1?'':'s'} changed`);
}
function edit(fn,message){if(!state)return;const before=snapshot();fn();finish(before,message);}
function history(redo){const from=redo?state.redo:state.undo,to=redo?state.undo:state.redo;if(!from.length)return;const delta=from.pop();for(const [bank,at,old,value] of delta)state.banks[bank][at]=redo?value:old;to.push(delta);refresh();renderLibrary();scheduleSave();status(redo?'Redone':'Undone');}
function download(data,name,type){const url=URL.createObjectURL(new Blob([data],{type})),link=document.createElement('a');link.href=url;link.download=name;link.click();setTimeout(()=>URL.revokeObjectURL(url),1000);}
function draw(target,a,scale=1,grid=false){
 const aspect=a.bpp===2?2:1,w=a.width*aspect*scale,h=a.height*scale;
 target.width=w;target.height=h;const ctx=target.getContext('2d'),colors=colours(a);ctx.imageSmoothingEnabled=false;
 for(let y=0;y<a.height;y++)for(let x=0;x<a.width;x++){ctx.fillStyle=colors[C.pixel(state.banks[a.bank],a,x,y)];ctx.fillRect(x*aspect*scale,y*scale,aspect*scale,scale);}
 if(grid&&scale>=6){ctx.strokeStyle='#0005';ctx.lineWidth=1;ctx.beginPath();for(let x=0;x<=a.width;x++){ctx.moveTo(x*aspect*scale+.5,0);ctx.lineTo(x*aspect*scale+.5,h);}for(let y=0;y<=a.height;y++){ctx.moveTo(0,y*scale+.5);ctx.lineTo(w,y*scale+.5);}ctx.stroke();}
}
function renderCanvas(){if(!state)return;const a=asset(),stage=$('stage'),aspect=a.bpp===2?2:1;let z=$('zoom').value;
 if(z==='fit')z=Math.max(1,Math.min(24,Math.floor(Math.min((stage.clientWidth-50)/(a.width*aspect),(stage.clientHeight-50)/a.height))));
 draw($('editor'),a,Number(z),$('grid').checked);drawPreview();
}
function drawPreview(){if(!state)return;let a=asset();if($('animate').checked){const frames=a.animation||(state.reference.game==='kult'?['player-0-0','player-1-0','player-2-0','player-3-0']:['sprite-5428','sprite-54fe','sprite-5601','sprite-56d7']);a=state.reference.assets.find(a=>a.id===frames[previewFrame%frames.length])||a;}
 const scale=Math.max(1,Math.min(4,Math.floor(Math.min(180/(a.width*(a.bpp===2?2:1)),140/a.height))));draw($('preview'),a,scale);
}
function swatches(){const a=asset(),colors=colours(a);ink=Math.min(ink,colors.length-1);$('swatches').replaceChildren();colors.forEach((color,i)=>{const b=document.createElement('button');b.style.background=color;b.className=ink===i?'selected':'';b.title=`Colour ${i} (key ${i+1})`;b.setAttribute('aria-label',`Colour ${i}`);b.setAttribute('aria-pressed',ink===i);b.innerHTML=`<span>${i+1}</span>`;b.onclick=()=>{ink=i;swatches();};$('swatches').append(b);});}
function renderLibrary(){if(!state)return;const q=$('search').value.toLowerCase(),category=$('category').value;
 const assets=state.reference.assets.filter(a=>(category==='All assets'||a.category===category)&&a.name.toLowerCase().includes(q));$('assetCount').textContent=assets.length;$('assetList').replaceChildren();
 for(const a of assets){const b=document.createElement('button');b.className='asset'+(state.selected===a.id?' selected':'');b.setAttribute('aria-label',a.name);b.setAttribute('aria-pressed',state.selected===a.id);b.setAttribute('role','listitem');const cn=document.createElement('canvas'),label=document.createElement('span');label.textContent=a.name;
 const aspect=a.bpp===2?2:1,scale=Math.max(1,Math.min(3,Math.floor(76/(a.width*aspect))));draw(cn,a,scale);cn.style.width=Math.min(a.width*aspect*scale,82)+'px';cn.style.height='auto';cn.style.maxHeight='54px';cn.style.objectFit='contain';b.append(cn,label);b.onclick=()=>select(a.id);$('assetList').append(b);}
}
function select(id){endStroke();state.selected=id;previewFrame=0;$('animate').checked=false;refresh();renderLibrary();}
function refresh(){if(!state)return;const a=asset();$('assetName').textContent=a.name;$('assetCategory').textContent=`${state.reference.game} / ${a.category}`;$('assetInfo').textContent=`${a.width} × ${a.height} pixels · ${a.bpp===1?'2':'4'} colours · ${a.width*a.height*a.bpp/8} bytes`;
 const changes=C.changes(state.original,state.banks),count=Object.values(changes).reduce((n,d)=>n+Object.keys(d).length,0);$('dirty').textContent=count?`${count} changed bytes`:'Original';$('dirty').classList.toggle('changed',!!count);$('undo').disabled=!state.undo.length;$('redo').disabled=!state.redo.length;$('paste').disabled=!clip;$('alignments').hidden=!(a.group&&a.shift===0);
 $('assetNote').textContent=a.category==='Enemy sprites'?'All four source frames are editable. Kult generates horizontal alignment copies from these pixels at runtime; no manual alignment update is needed.':a.group?'Edit alignment 0, then use Update alignment copies to regenerate the other three horizontal positions. Each frame is independent.':a.category==='Sprites'?'This is a decoded game sprite. Dimensions, origin and collision headers stay intact. Some sprite pointers are shared between object types.':a.category==='Pictures'?'Full introduction image. Export stores an ordinary load segment on the disk; the original loader reads it without decompression.':a.category==='Game tiles'?'These 8 × 16 tiles are drawn by the game’s tile blitter. Changes affect every use of the tile.':'Character graphics are shared by every screen location that uses this character.';
 $('palettePanel').hidden=state.reference.palettes.length===0;renderPalettes();swatches();renderCanvas();
}
function renderPalettes(){const box=$('gamePalettes');box.replaceChildren();for(const p of state.reference.palettes){const label=document.createElement('label');label.textContent=p.name;const input=document.createElement('input');input.setAttribute('aria-label',p.name);input.value=Array.from(state.banks[p.bank].slice(p.offset,p.offset+p.size),v=>v.toString(16).padStart(2,'0').toUpperCase()).join(' ');input.onchange=()=>{const values=input.value.trim().split(/\s+/);if(values.length!==p.size||values.some(v=>! /^[\da-f]{2}$/i.test(v))){status('Enter five hexadecimal colour bytes, e.g. 00 0C 00 00 00',true);renderPalettes();return;}edit(()=>values.forEach((v,i)=>state.banks[p.bank][p.offset+i]=parseInt(v,16)),'Menu palette changed');};label.append(input);box.append(label);}}
async function switchGame(game){endStroke();if(state){clearTimeout(saveTimer);draft();}const id=++request;$('loading').hidden=false;document.querySelector('main').hidden=true;
 document.querySelectorAll('[data-game]').forEach(b=>b.classList.toggle('active',b.dataset.game===game));
 try{if(!sessions[game]){const response=await fetch('/api/project/'+game);if(!response.ok)throw Error(await response.text());const reference=await response.json(),original=Object.fromEntries(Object.entries(reference.banks).map(([k,v])=>[k,decode(v)]));const s={reference,original,banks:Object.fromEntries(Object.entries(original).map(([k,v])=>[k,v.slice()])),selected:game==='kult'?'player-0-0':'sprite-5428',undo:[],redo:[]};
 try{const saved=localStorage.getItem('pixel-workshop-'+game);if(saved){const changes=C.validateProject(JSON.parse(saved),reference);for(const [bank,delta] of Object.entries(changes))for(const [at,value] of Object.entries(delta))s.banks[bank][at]=value;}}catch(e){status('Saved draft could not be restored: '+e.message,true);}
 sessions[game]=s;}
 if(id!==request)return;state=sessions[game];$('category').replaceChildren(...['All assets',...new Set(state.reference.assets.map(a=>a.category))].map(c=>new Option(c,c)));$('category').value=asset().category;$('search').value='';$('zoom').value='fit';$('animate').checked=false;$('loading').hidden=true;document.querySelector('main').hidden=false;refresh();renderLibrary();status(`${game==='kult'?'Kult':'CETAS'} ready · ${state.reference.assets.length} editable assets`);
 }catch(e){if(id===request){$('loading').textContent='Unable to load assets: '+e.message;status(e.message,true);}}
}
function point(event){const a=asset(),r=$('editor').getBoundingClientRect();return [Math.max(0,Math.min(a.width-1,Math.floor((event.clientX-r.left)*a.width/r.width))),Math.max(0,Math.min(a.height-1,Math.floor((event.clientY-r.top)*a.height/r.height)))];}
function applyPoint(x,y,erase=false){const a=asset(),bank=state.banks[a.bank],color=erase||tool==='erase'?0:ink;
 if(tool==='pick'){ink=C.pixel(bank,a,x,y);swatches();return;}
 if(tool==='fill'){C.fill(bank,a,x,y,color);return;}C.paint(bank,a,x,y,color);
}
function endStroke(){if(!stroke)return;const before=stroke;stroke=null;lastPoint=null;finish(before);}
$('editor').onpointerdown=e=>{if(!state||e.button>2)return;e.preventDefault();$('editor').focus();const [x,y]=point(e);stroke=snapshot();lastPoint=[x,y];$('editor').setPointerCapture(e.pointerId);applyPoint(x,y,e.button===2);renderCanvas();if(tool==='fill'||tool==='pick')endStroke();};
$('editor').onpointermove=e=>{if(!state)return;const [x,y]=point(e);$('coordinates').textContent=`Pixel ${x}, ${y} · colour ${C.pixel(state.banks[asset().bank],asset(),x,y)}`;if(stroke&&lastPoint){C.line(...lastPoint,x,y,(x,y)=>applyPoint(x,y,!!(e.buttons&2)));lastPoint=[x,y];renderCanvas();}};
$('editor').onpointerup=endStroke;$('editor').onpointercancel=endStroke;$('editor').onlostpointercapture=endStroke;$('editor').oncontextmenu=e=>e.preventDefault();
for(const b of document.querySelectorAll('[data-tool]'))b.onclick=()=>{endStroke();tool=b.dataset.tool;document.querySelectorAll('[data-tool]').forEach(b=>{b.classList.toggle('selected',b.dataset.tool===tool);b.setAttribute('aria-pressed',b.dataset.tool===tool);});};
for(const b of document.querySelectorAll('[data-game]'))b.onclick=()=>switchGame(b.dataset.game);
$('undo').onclick=()=>history(false);$('redo').onclick=()=>history(true);
$('flipX').onclick=()=>edit(()=>C.transform(state.banks[asset().bank],asset(),(x,y)=>[asset().width-1-x,y]),'Flipped horizontally');
$('flipY').onclick=()=>edit(()=>C.transform(state.banks[asset().bank],asset(),(x,y)=>[x,asset().height-1-y]),'Flipped vertically');
$('shiftL').onclick=()=>edit(()=>C.transform(state.banks[asset().bank],asset(),(x,y)=>[x+1,y]),'Shifted left');
$('shiftR').onclick=()=>edit(()=>C.transform(state.banks[asset().bank],asset(),(x,y)=>[x-1,y]),'Shifted right');
$('clear').onclick=()=>edit(()=>C.putPixels(state.banks[asset().bank],asset(),new Array(asset().width*asset().height).fill(0)),'Cleared asset · Undo restores it');
$('reset').onclick=()=>edit(()=>{const a=asset();state.banks[a.bank].set(state.original[a.bank].slice(a.offset,a.offset+a.width*a.height*a.bpp/8),a.offset);},'Restored original asset');
$('copy').onclick=()=>{const a=asset();clip={width:a.width,height:a.height,bpp:a.bpp,data:C.pixels(state.banks[a.bank],a)};$('paste').disabled=false;status('Pixels copied');};
$('paste').onclick=()=>{const a=asset();if(!clip||clip.width!==a.width||clip.height!==a.height||clip.bpp!==a.bpp){status('Paste needs the same dimensions and colour depth',true);return;}edit(()=>C.putPixels(state.banks[a.bank],a,clip.data),'Pasted pixels');};
$('category').onchange=renderLibrary;$('search').oninput=renderLibrary;$('zoom').onchange=renderCanvas;$('grid').onchange=renderCanvas;$('previewPalette').onchange=()=>{refresh();renderLibrary();};$('animate').onchange=drawPreview;window.addEventListener('resize',renderCanvas);
$('saveProject').onclick=()=>{if(!state)return;endStroke();download(JSON.stringify(documentFor(),null,2),state.reference.game+'-project.json','application/json');draft();status('Project downloaded — open it to continue editing later');};
$('openProject').onclick=()=>{if(state)$('projectFile').click();};
$('projectFile').onchange=async e=>{const file=e.target.files[0];e.target.value='';if(!file||!state)return;const s=state;try{if(file.size>2_000_000)throw Error('Project exceeds 2 MB');const doc=JSON.parse(await file.text());if(state!==s)throw Error('Game changed while opening project');const changes=C.validateProject(doc,state.reference);edit(()=>{state.banks=Object.fromEntries(Object.entries(state.original).map(([k,v])=>[k,v.slice()]));for(const [bank,delta] of Object.entries(changes))for(const [at,value] of Object.entries(delta))state.banks[bank][at]=value;},'Project opened');}catch(e){status(e.message,true);}};
$('exportGame').onclick=async()=>{if(!state)return;endStroke();const game=state.reference.game,edits=documentFor().edits;$('exportGame').disabled=true;status('Building and verifying edited game…');try{const r=await fetch('/api/export/'+game,{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify(edits)});if(!r.ok)throw Error(await r.text());download(await r.arrayBuffer(),game+'-edited.'+(game==='kult'?'xex':'atr'),'application/octet-stream');status('Edited '+game+' downloaded · original file unchanged');}catch(e){status(e.message,true);}finally{$('exportGame').disabled=false;}};
$('exportPng').onclick=()=>{if(!state)return;const a=asset(),canvas=document.createElement('canvas');draw(canvas,a);canvas.toBlob(blob=>{download(blob,a.id+'.png','image/png');},'image/png');};
$('importPng').onclick=()=>{if(state)$('pngFile').click();};
$('pngFile').onchange=async e=>{const file=e.target.files[0];e.target.value='';if(!file||!state)return;const s=state,a=asset();let url;try{if(file.size>8_000_000)throw Error('PNG exceeds 8 MB');const magic=new Uint8Array(await file.slice(0,8).arrayBuffer());if(magic.join(',')!=='137,80,78,71,13,10,26,10')throw Error('Choose a PNG image');url=URL.createObjectURL(file);const image=new Image();image.src=url;await image.decode();if(image.width>4096||image.height>4096)throw Error('Image is too large (maximum 4096 × 4096)');if(state!==s||asset()!==a)throw Error('Asset changed during import');const cn=document.createElement('canvas');cn.width=a.width;cn.height=a.height;const ctx=cn.getContext('2d');ctx.imageSmoothingEnabled=false;ctx.drawImage(image,0,0,a.width,a.height);const data=ctx.getImageData(0,0,a.width,a.height).data,palette=colours(a).map(hex=>hex.slice(1).match(/../g).map(v=>parseInt(v,16))),pixels=[];for(let i=0;i<data.length;i+=4){let best=0,distance=Infinity;if(data[i+3]>=128)palette.forEach((rgb,c)=>{const d=rgb.reduce((n,v,k)=>n+(v-data[i+k])**2,0);if(d<distance){best=c;distance=d;}});pixels.push(best);}edit(()=>C.putPixels(state.banks[a.bank],a,pixels),'PNG imported and mapped to '+palette.length+' colours');}catch(e){status(e.message,true);}finally{if(url)URL.revokeObjectURL(url);}};
document.addEventListener('keydown',e=>{if(!state||/INPUT|SELECT|TEXTAREA/.test(e.target.tagName))return;if((e.ctrlKey||e.metaKey)&&e.key.toLowerCase()==='z'){e.preventDefault();history(e.shiftKey);return;}if((e.ctrlKey||e.metaKey)&&e.key.toLowerCase()==='y'){e.preventDefault();history(true);return;}if(e.ctrlKey||e.metaKey)return;const tools={b:'pencil',f:'fill',e:'erase',i:'pick'};if(tools[e.key.toLowerCase()])document.querySelector(`[data-tool="${tools[e.key.toLowerCase()]}"]`).click();if(/^[1-4]$/.test(e.key)){ink=Math.min(Number(e.key)-1,2**asset().bpp-1);swatches();}});
function animate(time){if(state&&$('animate').checked&&time-lastPreview>1000/Number($('fps').value)){lastPreview=time;previewFrame++;drawPreview();}requestAnimationFrame(animate);}requestAnimationFrame(animate);
window.addEventListener('pagehide',()=>{endStroke();if(state)draft();});
switchGame('kult');

$('alignments').onclick=()=>edit(()=>{const a=asset(),src=C.pixels(state.banks[a.bank],a);for(const other of state.reference.assets.filter(b=>b.group===a.group&&b.shift>0)){C.putPixels(state.banks[other.bank],other,src.map((_,i)=>i%a.width<other.shift?0:src[i-other.shift]));}},'Updated all three alignment copies');

$('enemyGallery').onclick=()=>{
 if(!state)return;endStroke();$('galleryCards').replaceChildren();
 $('galleryNote').textContent=state.reference.game==='kult'?'All 32 wave-referenced enemy designs, with four animation frames each, plus effect set 33. Select a frame to edit it.':'Every non-player object type from the sprite pointer table. Types can share graphics. Columns are horizontal-position variants, not necessarily animation frames. Select a sprite to edit it.';
 for(const group of state.reference.collections){
  const card=document.createElement('section');card.className='gallery-card';const title=document.createElement('h3');title.textContent=group.name;card.append(title);
  const row=document.createElement('div');row.className='gallery-frames';
  group.ids.forEach((id,i)=>{const a=state.reference.assets.find(a=>a.id===id);if(!a)return;const b=document.createElement('button');b.title=a.name;b.setAttribute('aria-label',a.name);const c=document.createElement('canvas');draw(c,a,Math.max(1,Math.min(3,Math.floor(96/(a.width*2)))));const label=document.createElement('span');label.textContent=(group.kind==='animation'?'Frame ':'Variant ')+(i+1);b.append(c,label);b.onclick=()=>{$('gallery').close();$('category').value=a.category;$('search').value='';select(id);};row.append(b);});card.append(row);$('galleryCards').append(card);
 }
 $('gallery').showModal();
};
$('closeGallery').onclick=()=>$('gallery').close();
