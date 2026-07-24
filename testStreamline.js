
const S = require('/home/marcin/PhpstormProjects/tmp/pico/steamlinejs/streamline.js');
let state = S.parseLevel(S.LEVELS[0]);
function dump(label) {
  console.log('--- ' + label + ' ---  Player: ' + state.px + ',' + state.py);
  for(let y=0;y<state.h;y++){
    let r='';
    for(let x=0;x<state.w;x++){
      const t=state.cells[y][x];
      const map=['.','#','@','<','>','^','v','B','P','C','E','X'];
      r += (y===state.py && x===state.px) ? '@' : (t < map.length ? map[t] : '?');
    }
    console.log('   ' + r);
  }
}
dump('init');
S.move(state,1); dump('R1');
S.move(state,1); dump('R2');
S.move(state,0); dump('U1');
S.move(state,0); dump('U2');
S.move(state,1); dump('R3');
S.move(state,1); dump('R4');
S.move(state,1); dump('R5');
S.move(state,0); dump('U3');
S.move(state,1); dump('R6');
S.move(state,0); dump('U4');
