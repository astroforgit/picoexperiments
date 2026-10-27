'use strict';
function installBestiary() {
  if(G.bestiary_revision==='additive-v1')return;
  for(const [key,rows] of Object.entries(MONSTER_ART.original)) {
    const n=Number(key);
    if(artTile(G.sheet,n).join('')===MONSTER_ART.tiles[key].join(''))artPut(G.sheet,n,rows);
  }
  let missing=0;
  for(const entry of BESTIARY_PACK) {
    if(G.monsters.some(m=>m.catalog_key===entry.key))continue;
    const slot=freePage2Slot(),code=freeCodes()[0];
    if(G.monsters.length>=META.maxEntities||slot<0||code===undefined){missing++;continue;}
    entry.frames.forEach((rows,k)=>artPut(G.sheet2,slot+k-256,rows));
    const {frames,key, ...stats}=clone(entry);
    G.monsters.push({...stats,anim:slot,code,prop:false,itemchance:0,enabled:true,catalog_key:key});
  }
  G.monster_art_style='original';G.monster_art_revision='additive-v1';
  if(!missing)G.bestiary_revision='additive-v1';
  loadSheets();save();
  if(missing)status(`${missing} bestiary entries could not fit. Existing custom monsters and sprites were kept.`,true);
}
// Estimate for sorting, not a combat guarantee: health, damage and ability threat.
function monsterPower(m) {
  const weights={poison:8,paralyze:10,bolt:10,blink:4,stun:6,curse:5,vampire:8,steal_item:3,steal_weapon:6,slow:-3,still:-3,pounce:5,summon:12,hunter:4,blind:5,invisible:5,boss:20,flee:-4,treasure:-4};
  return Math.max(1,m.hp+5*m.atk+Math.max(0,m.range-1)*2+m.abilities.reduce((n,a)=>n+(weights[a]||0),0));
}
const monsterAdvancedView=VIEWS.monsters;
VIEWS.monsters=()=>{
  const box=h('div',{},h('h2',{},'Monster roster — weakest to strongest'),
    h('p',{class:'note'},'Original Lich King creatures and additional monsters coexist. Use in game controls spawning, including custom maps and summons; apply edits & restart in Play. The final boss is required.'));
  const table=h('table',{class:'lab-table bestiary-table'},h('thead',{},h('tr',{},...['Use in game','Rank','Sprite','Monster','Source','Power','HP','Attack','First floor','Abilities'].map(x=>h('th',{},x)))));
  const body=h('tbody');table.append(body);
  const rows=G.monsters.map((m,i)=>({m,id:i+1})).filter(({m,id})=>id!==1&&!m.prop).sort((a,b)=>monsterPower(a.m)-monsterPower(b.m)||a.id-b.id);
  rows.forEach(({m,id},rank)=>{
    const required=id===G.params.boss_id;
    const input=(key,min,max)=>{const el=numInput(m,key,{min,max,width:64});el.addEventListener('change',()=>render());return el;};
    const cb=h('input',{type:'checkbox',checked:required||m.enabled!==false,disabled:required,'aria-label':`Use ${m.name} in game`,onchange:e=>{m.enabled=e.target.checked;changed(`${m.name}: ${m.enabled?'enabled':'disabled'}. Apply edits & restart in Play.`);}});
    body.append(h('tr',{'data-monster-id':id},h('td',{},cb,required?h('span',{class:'note'},'Required boss'):null),h('td',{},rank+1),h('td',{},animCanvas(()=>entFrames(m),4)),h('td',{},m.name.replace(/\^([a-z])/g,(_,c)=>c.toUpperCase())),h('td',{},m.from_source||m.from||'Lich King'),h('td',{},monsterPower(m)),h('td',{},input('hp',1,127)),h('td',{},input('atk',0,99)),h('td',{},input('depth',1,99)),h('td',{},m.abilities.join(', ')||'—')));
  });
  box.append(h('div',{class:'scroll'},table),h('p',{class:'note'},'Power = HP + 5 × attack + range and ability weights. This is a sorting estimate; use Encounters and Play for actual combat. Floor 99 means no random spawning (the original box and final boss have special placement).'));
  box.append(h('details',{},h('summary',{},'Advanced entity settings and cartridge library'),monsterAdvancedView()));return box;
};
installBestiary();render();
