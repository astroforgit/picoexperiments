'use strict';
// Enemy skins are independent of the environment art style and never import stats.
function setMonsterArtwork(style,keepCustom=false) {
  if(!['original',MONSTER_ART.id].includes(style))throw new Error('Unknown monster artwork.');
  const tiles=style==='original'?MONSTER_ART.original:MONSTER_ART.tiles;
  let replaced=0,kept=0;
  for(const entry of MONSTER_ART.entries) {
    const monster=G.monsters[entry.id-1],targets=Array.from({length:4},(_,i)=>entry.base+i);
    // Preserve relocated monsters and any other entities reusing these slots.
    const shared=G.monsters.some((m,i)=>i!==entry.id-1&&entFrames(m).some(n=>targets.includes(n)));
    if(!monster||monster.prop||monster.anim!==entry.base||shared){kept++;continue;}
    if(keepCustom&&targets.some(n=>{
      const current=artTile(G.sheet,n).join('');
      return current!==MONSTER_ART.original[n].join('')&&current!==MONSTER_ART.tiles[n].join('');
    })){kept++;continue;}
    for(const n of targets)artPut(G.sheet,n,tiles[n]);replaced++;
  }
  G.monster_art_style=style;G.monster_art_revision=MONSTER_ART.id;
  loadSheets();changed(`${style==='original'?'Original':'Guest'} monster sprites applied to ${replaced} enemies${kept?`; ${kept} customized enemies kept`:''}. Stats and abilities unchanged. Apply edits & restart in Play.`);
  return {replaced,kept};
}
function monsterArtPreview(entry,original=false) {
  const canvas=h('canvas',{class:'px',width:32,height:32}),ctx=canvas.getContext('2d');
  const tiles=original?MONSTER_ART.original:MONSTER_ART.tiles;
  const draw=frame=>{
    const rows=tiles[entry.base+frame%4];ctx.clearRect(0,0,32,32);
    rows.forEach((r,y)=>[...r].forEach((c,x)=>{if(c!=='0'){ctx.fillStyle=PAL_CSS[parseInt(c,16)];ctx.fillRect(x*4,y*4,4,4);}}));
  };
  draw(0);animated.push({canvas,draw});return canvas;
}
const monstersViewBeforeSkins=VIEWS.monsters;
VIEWS.monsters=()=>{
  const panel=h('section',{class:'panel art-panel'},h('h2',{},'Monster appearance'),
    h('p',{class:'note'},'Guest animations from Crocolike, The Demon Within, BulbaRogue and Porklike. These replace existing Lich King sprites only: names, HP, attack, range, sight, abilities, XP and spawning stay unchanged. The role names below still identify their Lich King behavior.'),
    h('div',{class:'actions'},
      h('button',{class:G.monster_art_style===MONSTER_ART.id?'primary':'',onclick:()=>{setMonsterArtwork(MONSTER_ART.id);render();}},'Use guest monster sprites'),
      h('button',{class:G.monster_art_style==='original'?'on':'',onclick:()=>{setMonsterArtwork('original');render();}},'Use original monster sprites')),
    h('p',{class:'note'},'Applies independently of the dungeon artwork. Custom or relocated enemy art is kept during automatic upgrades. In Play, use “Apply edits & restart”.'));
  const table=h('table',{class:'lab-table'},h('tr',{},...['Lich King role','Original','Guest','Sprite source','HP','Attack','Abilities'].map(t=>h('th',{},t))));
  for(const entry of MONSTER_ART.entries){
    const m=G.monsters[entry.id-1];if(!m)continue;
    table.append(h('tr',{},h('td',{},m.name.replace(/\^([a-z])/g,(_,c)=>c.toUpperCase())),h('td',{},monsterArtPreview(entry,true)),h('td',{},monsterArtPreview(entry)),
      h('td',{},`${entry.cart} · ${entry.name}`),h('td',{},m.hp),h('td',{},m.atk),h('td',{},m.abilities.join(', ')||'—')));
  }
  panel.append(h('div',{class:'scroll'},table));return h('div',{},panel,monstersViewBeforeSkins());
};
if(G.monster_art_revision!==MONSTER_ART.id)setMonsterArtwork(MONSTER_ART.id,true);
render();
