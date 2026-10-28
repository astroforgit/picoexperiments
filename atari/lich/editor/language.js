'use strict';
function setGameLanguage(code,keepCustom=false){
 const pack=GAME_LANGUAGES[code];if(!pack)return;
 const known=(kind,key,value)=>Object.values(GAME_LANGUAGES).some(p=>(key===null?p[kind]:p[kind][key])===value);
 for(const kind of ['texts','windows'])for(const [key,value] of Object.entries(pack[kind])){
  if(keepCustom&&!Object.values(GAME_LANGUAGES).some(p=>JSON.stringify(p[kind][key])===JSON.stringify(G[kind][key])))continue;
  G[kind][key]=clone(value);
 }
 if(!keepCustom||known('name',null,G.name))G.name=pack.name;
 for(const kind of ['monsters','items'])G[kind].forEach((entry,i)=>{if(pack[kind][i]!==undefined&&(!keepCustom||known(kind,i,entry.name)))entry.name=pack[kind][i];});
 G.language=code;save();
}
const textsBeforeLanguage=VIEWS.texts;
VIEWS.texts=()=>{
 const actions=h('div',{class:'actions'});
 for(const code of ['pl','en'])actions.append(h('button',{class:G.language===code?'primary':'',onclick:()=>{setGameLanguage(code);render();}},code==='pl'?'Polski':'English'));
 return h('div',{},h('section',{class:'panel'},h('h2',{},'Game language / Język gry'),h('p',{class:'note'},'Changes game text, story and names. Restart Play to use the selected language.'),actions),textsBeforeLanguage());
};
if(!G.language)setGameLanguage('pl',true);
