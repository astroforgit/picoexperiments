'use strict';
// Upgrade saved environment art once per art revision, preserving user-painted
// tiles. Explicit selection of any style persists across reloads.
const CURRENT_ART_REVISION='live-depth-v1';
const ART_STYLES = [
  {id:'original',name:'Original artwork',tiles:CRYPT_ART.original},
  CRYPT_ART, CROCO_ART, DEMON_ART, DIABOLIC_V1_ART, DIABOLIC_ART, MYSTIC_ART, CHROMA_ART, MINIFANTASY_ART, ALCHEMY_ART, IMPORTED_DUNGEON_ART, MATCHED_MASONRY_ART,
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
  G.art_style=style;G.art_revision=CURRENT_ART_REVISION;loadSheets();
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
    h('p',{class:'note'},'Mystic Acid adapts the supplied PetricakeGames atlas into slate masonry, mint edges and plum furniture. Diabolic Crypt restores the original Lich King walls, stairs and furniture with charcoal masonry, charred brown oak, a blood-red altar, a horned idol and engraved tombs. All styles retain the same tile IDs and collision rules.'),
    h('div',{class:'actions'},...ART_STYLES.slice().reverse().map(pack=>h('button',{
      class:G.art_style===pack.id?'primary':'',onclick:()=>{setArtwork(pack.id);render();}
    },'Use '+(pack.id==='original'?'original artwork':pack.name)))),
    h('p',{class:'note'},'These buttons replace environment tiles only. Maps, rules, heroes, enemies and weapons are preserved. Use “Apply edits & restart” in Play after changing artwork.'));
  for(const pack of ART_STYLES)panel.append(h('div',{class:'art-samples'},h('strong',{},pack.name),...[48,54,16,13,15,22,25,27,68,70,75].map(n=>{
    const c=artPreview(pack.tiles[n]);c.title=`Tile ${n}`;return c;
  }),pack.credit?h('p',{class:'note'},pack.credit):null));
  return h('div',{},panel,spriteViewBeforeArt());
};
function restoreBundledArtwork(keepCustom=false) {
  for(const key of Object.keys(CRYPT_ART.original)){
    const n=Number(key),old=artTile(G.sheet,n).join('');
    if(keepCustom&&old!==artTile(DEFAULT_GAME.sheet,n).join('')&&!ART_STYLES.some(p=>p.tiles[key]?.join('')===old))continue;
    artPut(G.sheet,n,artTile(DEFAULT_GAME.sheet,n));
  }
  G.overhangs||={};
  for(const [key,def] of Object.entries(DEFAULT_GAME.overhangs||{})){
    // Additional user monsters may occupy the optional upper-art slots.
    if(G.monsters.some(m=>entFrames(m).includes(def.top)))continue;
    if(keepCustom&&G.overhangs[key]&&JSON.stringify(G.overhangs[key])!==JSON.stringify(def))continue;
    G.overhangs[key]=clone(def);
    artPut(def.top>=256?G.sheet2:G.sheet,def.top&255,artTile(def.top>=256?DEFAULT_GAME.sheet2:DEFAULT_GAME.sheet,def.top&255));
  }
  G.art_style=DEFAULT_GAME.art_style;G.art_revision=CURRENT_ART_REVISION;
  loadSheets();changed('Latest dungeon artwork applied. Your game progress and rules are unchanged.');
  if(typeof playSyncArtwork==='function')playSyncArtwork();
}
if(G.art_revision!==CURRENT_ART_REVISION)restoreBundledArtwork(true);
render();

// Upgrade only unchanged tiles from the exported matching session. Newer hand
// edits and additional reference matches take precedence over this migration.
if(G.matched_masonry_revision!==MATCHED_MASONRY_ART.id&&G.reference_matches?.['1']?.column===8&&G.reference_matches?.['1']?.row===9){
 let updated=0;
 for(const [key,rows] of Object.entries(MATCHED_MASONRY_ART.migration_tiles)){
  const n=+key,current=artTile(G.sheet,n).join('');if(current!==MATCHED_MASONRY_ART.migration_before[key].join('')&&!MATCHED_MASONRY_ART.migration_history.some(pack=>current===pack[key]?.join('')))continue;
  artPut(G.sheet,n,rows);updated++;
  if(G.reference_matches?.[key])G.reference_matches[key].adaptation='Connected wall face above matched paving.';
 }
 G.matched_masonry_revision=MATCHED_MASONRY_ART.id;if(updated){G.art_style='mixed';loadSheets();save();}render();
}
