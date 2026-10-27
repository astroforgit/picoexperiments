'use strict';
// Appearance edits patch the running renderer's data, never the simulation state.
const PLAY_ART_GROUPS = [
  ['walls','Walls',[...Array.from({length:16},(_,i)=>48+i),2,3,35,39,43],[48,54,60]],
  ['stairs','Stairs',[16,17],[16,17]],
  ['floors','Floor patterns',[1,32,33,34,36,37,38,40,41,42],[32,33,34]],
  ['doors','Doors & gates',[4,5,6,7,8,9],[4,7,9]],
  ['chests','Chests',[12,13],[13,12]],
  ['shelves','Shelves',[14,15],[14,15]],
  ['tables','Tables & chairs',[65,66,67,69,73,74,81,82,83,85,89,90],[65,66,69]],
  ['altar','Altar',[25],[25]],
  ['statues','Statues',[68,84],[68,84]],
  ['tombs','Tombs',[70,86],[70,86]],
  ['pots','Pots & urns',[26,27,28,29,72,88],[27,29,72]],
  ['candles','Candles',[71,75,87,91],[71,75]],
  ['well','Well',[21,22],[21,22]],
  ['anvil','Anvil',[23,24],[23,24]],
  ['iron','Grilles & levers',[64,80,30,31],[64,30,31]],
  ['traps','Spikes',[46,47],[46,47]],
  ['all','Entire environment',Object.keys(CRYPT_ART.original).map(Number),[54,16,25]],
];
let playArtGroup='walls';
function playArtApply(pack,group) {
  for(const n of group[2]) {
    const rows=pack.tiles[n];if(!rows)continue;
    artPut(G.sheet,n,rows);
    if(play.game)artPut(play.game.g.sheet,n,rows);
  }
  G.art_style=group[0]==='all'?pack.id:'mixed';
  G.art_revision=DIABOLIC_ART.id;
  if(play.game){play.game.g.art_style=G.art_style;play.game.g.art_revision=G.art_revision;play.sprites=playSprites(play.game.g);}
  play.titleSprites=playSprites(G);loadSheets();
  changed(`${group[1]}: ${pack.name}. Artwork saved and applied live; your run continues.`);
  playDraw(performance.now());
}
function playArtPanel() {
  const panel=h('aside',{class:'panel play-art-panel','aria-label':'Live artwork'});
  const select=h('select',{'aria-label':'Artwork category'},...PLAY_ART_GROUPS.map(([id,name])=>h('option',{value:id,selected:id===playArtGroup},name)));
  const choices=h('div',{class:'play-art-choices'}),current=h('div',{class:'play-art-current'});
  function refresh(){
    const group=PLAY_ART_GROUPS.find(g=>g[0]===playArtGroup);
    const sheet=play.game?.g.sheet||G.sheet;
    current.replaceChildren(h('span',{},'In game now'),...group[3].map(n=>artPreview(artTile(sheet,n))));
    choices.replaceChildren(...ART_STYLES.slice().reverse().map(pack=>{
      const selected=group[2].every(n=>artTile(sheet,n).join('')===pack.tiles[n]?.join(''));
      return h('button',{class:'play-art-choice'+(selected?' selected':''),'aria-pressed':String(selected),
        'aria-label':`${group[1]}: ${pack.name}`,onclick:()=>{playArtApply(pack,group);refresh();}},
        h('span',{class:'play-art-thumbs'},...group[3].map(n=>artPreview(pack.tiles[n]))),
        h('span',{},pack.name),h('span',{class:'note'},selected?'Active':'Apply live'));
    }));
  }
  select.addEventListener('change',()=>{playArtGroup=select.value;refresh();});
  panel.append(h('h3',{},'Live artwork'),h('p',{class:'note'},'Choose walls or an object, then click a style. Changes appear instantly and are saved to the editor. Mix styles freely.'),select,current,choices,h('p',{class:'note'},'Updates every instance of this object, including broken/open states. Walls keep all connected variants. Your position, health and inventory stay as they are.'));
  refresh();return panel;
}
