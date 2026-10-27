'use strict';
// Upgrade saved environment art once per art revision, preserving user-painted
// tiles. Explicit selection of any style persists across reloads.
const ART_STYLES = [
  {id:'original',name:'Original artwork',tiles:CRYPT_ART.original},
  CRYPT_ART, CROCO_ART, DEMON_ART, DIABOLIC_V1_ART, DIABOLIC_ART,
];
function artTile(sheet,n) {const x=n%16*8,y=Math.floor(n/16)*8;return sheet.slice(y,y+8).map(row=>row.slice(x,x+8));}
function artPut(sheet,n,rows) {const x=n%16*8,y=Math.floor(n/16)*8;rows.forEach((r,i)=>{sheet[y+i]=sheet[y+i].slice(0,x)+r+sheet[y+i].slice(x+8);});}
function setArtwork(style,keepCustom=false) {
  const chosen=ART_STYLES.find(p=>p.id===style);if(!chosen)throw new Error('Unknown artwork style.');
  let changedTiles=0,kept=0;
  for(const [key,rows] of Object.entries(chosen.tiles)) {
    const n=Number(key),old=artTile(G.sheet,n).join('');
    if(keepCustom&&!ART_STYLES.some(p=>p.tiles[key]?.join('')===old)){kept++;continue;}
    if(old!==rows.join('')){artPut(G.sheet,n,rows);changedTiles++;}
  }
  G.art_style=style;G.art_revision=DIABOLIC_ART.id;loadSheets();
  changed(`${chosen.name}: ${changedTiles} tiles updated${kept?`; ${kept} custom tiles kept`:''}. In Play, apply edits & restart to see the new art.`);
  return {changedTiles,kept};
}
function artPreview(rows) {
  const cv=h('canvas',{width:40,height:40,class:'px'}),ctx=cv.getContext('2d');
  rows.forEach((row,y)=>{[...row].forEach((c,x)=>{ctx.fillStyle=PAL_CSS[parseInt(c,16)];ctx.fillRect(x*5,y*5,5,5);});});return cv;
}
const spriteViewBeforeArt=VIEWS.sprites;
VIEWS.sprites=()=>{
  const panel=h('section',{class:'panel art-panel'},h('h2',{},'Dungeon artwork'),
    h('p',{class:'note'},'Diabolic Crypt restores the original Lich King walls, stairs and furniture with charcoal masonry, charred brown oak, a blood-red altar, a horned idol and engraved tombs. All styles retain the same tile IDs and collision rules.'),
    h('div',{class:'actions'},...ART_STYLES.slice().reverse().map(pack=>h('button',{
      class:G.art_style===pack.id?'primary':'',onclick:()=>{setArtwork(pack.id);render();}
    },'Use '+(pack.id==='original'?'original artwork':pack.name)))),
    h('p',{class:'note'},'These buttons replace environment tiles only. Maps, rules, heroes, enemies and weapons are preserved. Use “Apply edits & restart” in Play after changing artwork.'));
  for(const pack of ART_STYLES)panel.append(h('div',{class:'art-samples'},h('strong',{},pack.name),...[48,54,16,13,15,22,25,27,68,70,75].map(n=>{
    const c=artPreview(pack.tiles[n]);c.title=`Tile ${n}`;return c;
  })));
  return h('div',{},panel,spriteViewBeforeArt());
};
if(G.art_revision!==DIABOLIC_ART.id)setArtwork(DIABOLIC_ART.id,true);
render();
