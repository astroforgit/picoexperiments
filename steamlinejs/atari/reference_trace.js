#!/usr/bin/env node
'use strict';
// Execute the recovered game's actual Player methods as the test oracle.
const fs = require('fs');
const vm = require('vm');
const path = require('path');
const source = fs.readFileSync(path.join(__dirname,'../orggame/orggame.js'),'utf8');
const names=['EMPTY','START','END','WALL','PAUSE','RESET','TRAP','PORTAL','FORCER','LOCK','KEY'];
const S=Object.fromEntries(names.map((n,i)=>[n,[n,i]]));
const dirs=['UP','RIGHT','DOWN','LEFT'].map((n,i)=>[n,i]);
const context={S,k:{},ea:Object.fromEntries(dirs.map(d=>[d[0],d]))};
vm.createContext(context);
vm.runInContext(source.slice(source.indexOf('    var Nh = function'),source.indexOf('    var Kb = function')),context);
const chars='.@E#PRX%^>v<LK';
const types=[...names.slice(0,8).map(n=>S[n]),...dirs.map(d=>['FORCER',8,d]),S.LOCK,S.KEY];
function grid(text) {
 const rows=text.split('\n'),w=rows[0].length,h=rows.length;
 const g={players:[],active:0,moves:[],getPlayerIndex(p){return this.players.indexOf(p)},
  getCell(x,y){return x>=0&&x<w&&y>=0&&y<h?this.cells[y*w+x]:null},
  hasBody(x,y){return this.players.some(p=>p.hasBody(x,y))},
  isKeyCollected(){return this.players.some(p=>p.path.some(c=>c.type===S.KEY))},
  getOtherPortal(c){return [...this.cells].sort((a,b)=>a.x-b.x||a.y-b.y).find(a=>a!==c&&a.type===S.PORTAL)},
  registerMove(p){this.moves.push(p)},
  undoLastMove(){const p=this.moves.pop();if(!p)return false;this.active=this.players.indexOf(p);return p.undo(false)},
 };
 g.cells=[...rows.join('')].map((c,i)=>({i,x:i%w,y:Math.floor(i/w),type:types[chars.indexOf(c)],
  getX(){return this.x},getY(){return this.y},getType(){return this.type},
  isNavigable(){return this.type!==S.WALL&&(this.type!==S.LOCK||g.isKeyCollected())},
  stopsMovement(){return [S.WALL,S.PAUSE,S.TRAP,S.END].includes(this.type)},
 }));
 for(let x=0;x<w;x++)for(let y=0;y<h;y++)if(g.getCell(x,y).type===S.START)g.players.push(new context.Nh(g,g.getCell(x,y)));
 return g;
}
const campaign=Object.values(JSON.parse(fs.readFileSync(path.join(__dirname,'../orggame/extracted/all_levels.json'),'utf8'))).flat();
const scenarios=[
 ['@P.RE',[1,1,3,5,1,1]],
 ['@..X.E',[1,1,3,5]],
 ['@K.L.E',[1,5,1]],
 ['@.%#%..E',[1,5,1]],
 ['@.v.\n##.E',[1,1,5,5]],
 ['..@.\n@..E',[1,4,1,5,5]],
 ['@..E\n@..E',[1,1,5,4]],
 ['@.%#%P.E',[1,3,1,5]],
 ['@R>v\nE.^<',[1,2,5]],
];
let seed=123456789;
const random=()=>{seed^=seed<<13;seed^=seed>>>17;seed^=seed<<5;return seed>>>0};
const cases=[...campaign.map((text,level)=>({text,level,actions:Array.from({length:180},()=>random()%7)})),
 ...scenarios.map(([text,actions])=>({text,level:0,actions}))];
for(const c of cases){
 let g=grid(c.text);c.states=[];
 for(let a of c.actions){
  // Restart won puzzles, and keep randomized traces within finite Atari storage.
  if(g.players.every(p=>p.onEnd())||g.players.some(p=>p.path.length>180))a=6;
  if(a===6)g=grid(c.text);
  else if(a===5)g.undoLastMove();
  else if(a===4)g.active=(g.active+1)%g.players.length;
  else {const p=g.players[g.active];if(p.canUndo(dirs[a]))g.undoLastMove();else if(p.move(dirs[a])){
    if(p.onEnd()&&!g.players.every(p=>p.onEnd()))g.active=g.players.findIndex(q=>!q.onEnd());
  }}
  c.states.push({action:a,paths:g.players.map(p=>Array.from(p.path,c=>c.i)),active:g.players.every(p=>p.onEnd())?0:g.active,
    moves:g.moves.length,won:g.players.every(p=>p.onEnd())?1:0,key:g.isKeyCollected()});
 }
 delete c.actions;
}
process.stdout.write(JSON.stringify(cases));
