/* JavaScript gameplay port of src/{level,entity,items,game}.asm and pico/lich.lua.
 * Rendering and UI are separate. RNG is deterministic (POKEY entropy is not emulated).
 */
(function(root) {
'use strict';
const DIR = [[-1,0],[1,0],[0,-1],[0,1]];
const copy = x => JSON.parse(JSON.stringify(x));
const dist = (a,b) => (a.x-b.x)**2 + (a.y-b.y)**2;
const floorTile = n => n === 1 || n === 2 || n >= 32 && n <= 44;
class Random {
  constructor(seed=1) { this.state = (Number(seed) >>> 0) || 1; }
  next() { let n = this.state; n ^= n << 13; n ^= n >>> 17; n ^= n << 5; this.state = n >>> 0; return this.state / 4294967296; }
  int(n) { return Math.floor(Math.floor(this.next()*256) * Math.max(0,n) / 256); }
  chance(p) { return this.next() < p; }
  pick(a) { return a[this.int(a.length)]; }
}
function generate(g, depth, rng) {
  const assigned = g.floors[g.floor_plan[depth-1]];
  if (assigned) return copy(assigned);
  const p=g.params, map=new Uint8Array(4096), rooms=[], pool=[];
  let placed=0, operations=0;
  const at=(x,y) => x>=0 && x<128 && y>=0 && y<32 ? map[y*128+x] : 0;
  const set=(x,y,v) => { if(x>=0 && x<128 && y>=0 && y<32) map[y*128+x]=v; };
  const onFloor=(x,y,v) => { if(!floorTile(at(x,y))) return false; set(x,y,v); return true; };
  const code=id => g.monsters[id-1]?.code || 0;
  const mobs=g.monsters.filter((m,i)=>i && !m.prop && m.enabled!==false && m.depth<=depth);
  const placeMob=(x,y,c) => { c = c || rng.pick(mobs)?.code; if(c && onFloor(x,y,c)) placed++; };
  const pot=()=>code(rng.int(2) ? 4 : 18);
  const make=(type,w,h) => {
    const r={type,x:12,y:12,w:p.room_w_min+rng.int(p.room_w_rnd),h:p.room_h_min+rng.int(p.room_h_rnd),oob:0,style:rng.pick(g.floor_weights)};
    if(w!==undefined) {r.w=w;r.h=h;}
    if(type==='boss') {r.w=p.boss_w;r.h=p.boss_h;}
    if(r.w<3 || r.h<3 || r.w>126 || r.h>30) throw new Error('Room dimensions must fit inside 128×32.');
    rooms.push(r); return r;
  };
  const position=r=>[r.x+1+rng.int(r.w-2),r.y+1+rng.int(r.h-2)];
  const piece=(index,x,y)=>{
    const cells=g.pieces[Math.max(0,Math.min(g.pieces.length-1,index))] || [];
    for(let dx=0;dx<3;dx++) for(let dy=0;dy<3;dy++) {
      const c=cells[dy*3+dx]; if(!c) continue;
      let t=c===15?48:c+63; if(t!==48 && rng.chance(depth/10)) t+=16;
      set(x+dx,y+dy,t);
    }
  };
  const roomCount=Math.max(2,p.rooms_base+p.rooms_per_floor*depth);
  const perRoom=Math.floor(.5+(g.budget[depth-1]||0)/roomCount)-1;
  make('entry',p.entry_min+rng.int(p.entry_rnd),p.entry_min+rng.int(p.entry_rnd)); make('storage');
  for(let i=2;i<roomCount;i++) make(rng.chance(p.storage_chance)?'storage':'ordinary');
  pool.push(depth<p.last_floor?'exit':'boss');
  for(let i=0;i<(g.treasure_rooms[depth-1]||0);i++) pool.push('treasure');
  if(depth>=p.shrine_from) pool.push('shrine');
  if(depth>=p.smithy_from) pool.push('smithy');
  if(depth>=p.pool_from) pool.push('pool');
  function place(r) {
    const {x,y,w,h,type}=r;
    if(x<0||y<0||x+w>127||y+h>31) {
      if(++r.oob>5) {pool.push(type);return true;} return false;
    }
    r.oob=0;
    for(let yy=y+1;yy<y+h-1;yy++) for(let xx=x+1;xx<x+w-1;xx++) if(at(xx,yy)) return false;
    const bg=[];
    for(let yy=y;yy<y+h;yy++) for(let xx=x;xx<x+w;xx++) {
      bg.push(at(xx,yy)); let t=1;
      if(r.style) t=rng.chance(p.floor_plain_chance)?1:28+4*r.style+rng.int(3);
      if(xx===x||yy===y||xx===x+w-1||yy===y+h-1) t=48;
      set(xx,yy,t);
    }
    if(rng.chance(p.deco_chance)) for(let i=Math.floor(rng.int(w)/2);i>0;i--) {
      const [xx,yy]=position(r); let c=pot(); if(rng.chance(p.body_chance)) c=code(21); onFloor(xx,yy,c);
    }
    if(depth>=p.spikes_from && rng.chance(p.spikes_chance)) for(let i=1+Math.floor(rng.int(w)/2);i>0;i--) onFloor(...position(r),code(13));
    const cx=x+Math.floor(w/2),cy=y+Math.floor(h/2);
    if(type==='entry') {set(cx,cy,p.tile_start);set(cx-1,cy-1,48);set(cx-1,cy,48);}
    else if(type==='exit') set(cx,cy,p.tile_exit);
    else if(type==='boss') {piece(27,x+2,y+2);piece(0,x+6,y+3);set(cx,cy,code(p.boss_id));}
    else if(type==='pool') set(cx,cy,code(25));
    else if(type==='smithy') {set(cx,cy,code(20));set(cx-1,cy,p.tile_anvil_deco);}
    else if(type==='shrine') {set(cx,cy,code(9));set(cx+1,cy,p.tile_altar_deco);}
    else if(type==='storage') {
      for(let i=rng.int(w);i>0;i--) set(...position(r),pot());
      for(let i=1;i<=w-2;i++) if(rng.chance(p.shelf_chance)) set(x+i,y+1,code(6));
    } else if(type==='treasure') {
      for(let i=1+rng.int(w);i>0;i--) set(...position(r),code(13)); set(cx,cy,code(5));
    } else if(w>=6&&h>=6) {
      for(let i=0;i<Math.floor((w-2)/5);i++) piece(p.piece_step*(depth-1)+rng.int(p.piece_rnd),x+1+rng.int(2)+i*4,y+2+rng.int(Math.max(0,h-7)));
    }
    const before=placed;
    if(type!=='entry') for(let i=0;i<perRoom;i++) placeMob(...position(r));
    let doors=0;
    for(const [x1,y1,x2,y2] of [[x+w-1,y,x+w-1,y+h-1],[x,y,x,y+h-1],[x,y+h-1,x+w-1,y+h-1],[x,y,x+w-1,y]]) {
      const sx=x1===x2?0:1,sy=1-sx,options=[];
      for(let i=0;i<Math.abs(x2-x1)+Math.abs(y2-y1)+1;i++) {
        const xx=x1+i*sx,yy=y1+i*sy;
        if(floorTile(at(xx+sy,yy+sx))&&floorTile(at(xx-sy,yy-sx))) options.push([xx,yy]);
      }
      doors+=options.length;
      if(options.length) set(...rng.pick(options),rng.chance(p.door_chance)?code(sx===1?7:8):1);
    }
    if(!doors&&type!=='entry') {
      let i=0;for(let yy=y;yy<y+h;yy++) for(let xx=x;xx<x+w;xx++) set(xx,yy,bg[i++]);
      pool.push(type);placed=before;
    }
    return true;
  }
  const weights=g.move_weights, total=weights.reduce((a,b)=>a+b,0);
  if(!total) throw new Error('At least one room movement weight must be positive.');
  while(rooms.length||pool.length) {
    if(++operations>250000) throw new Error('Generator could not place all rooms. Try another seed or smaller room counts/sizes.');
    if(!rooms.length) make(pool.shift());
    for(let i=0;i<rooms.length;) {
      const r=rooms[i]; if(place(r)) rooms.splice(i,1);
      else {let v=rng.next()*total,d=0;while(d<3&&v>=weights[d]) v-=weights[d++];r.x+=DIR[d][0];r.y+=DIR[d][1];i++;}
    }
  }
  function fill(target,c) {
    let attempts=0;
    while(placed<=target && ++attempts<100000) placeMob(rng.int(128),rng.int(32),c);
    if(placed<=target) throw new Error('Monster budget exceeds available floor space (or no eligible monsters).');
  }
  if(mobs.length) fill(g.budget[depth-1]||0);
  if(g.monsters[p.mimic_id-1]?.enabled!==false)fill(placed+(g.mimic_offset[depth-1]||0),code(p.mimic_id));
  return {name:`Generated floor ${depth}`,tiles:Array.from({length:32},(_,y)=>Array.from(map.slice(y*128,y*128+128),n=>n.toString(16).padStart(2,'0')).join(''))};
}
class Game {
  constructor(data, {seed=1,depth=1}={}) {
    this.g=copy(data);this.p=this.g.params;this.rng=new Random(seed);this.seed=seed;
    this.depth=depth;this.turn=0;this.uid=0;this.messages=[];this.events=[];this.inventory=Array(8).fill(null);this.tried=new Set();this.blind=0;
    this.hero=this.makeEntity(1,0,0);this.hero.level=1;this.hero.xp=0;this.hero.weapon=null;
    this.state='playing';
    for(const id of this.g.start_items) {const item=this.makeItem(id);if(item)this.giveItem(item,true);}
    this.newFloor();
  }
  say(message) {this.messages.push({turn:this.turn,message});if(this.messages.length>100)this.messages.shift();this.events.push({type:'message',message});}
  text(key,fallback='') {return this.g.texts[key]??fallback;}
  has(e,a) {return e.abilities.includes(a);}
  makeEntity(id,x,y) {
    const m=this.g.monsters[id-1];if(!m)throw new Error(`Missing entity ${id}`);
    return {...copy(m),id,uid:++this.uid,x,y,oldX:x,oldY:y,maxHp:m.hp,poison:0,confusion:0,paralysis:0,logic:m.prop?'prop':'wait',dir:1,
      walkable:id===13,used:false,trap:id===13,hasitem:this.rng.chance(m.itemchance/10),special:false,slow:false,cooldown:0,frame:0};
  }
  tile(x,y) {return x<0||x>127||y<0||y>31?0:this.map[y*128+x];}
  entity(x,y,mob=false) {return this.entities.find(e=>e.hp>0&&e.x===x&&e.y===y&&(!mob||!e.prop));}
  walkable(x,y,los=false) {
    if(x<0||x>127||y<0||y>31)return false;
    if((this.g.flags[this.tile(x,y)]||0)&(los?2:1))return false;
    if(los)return !this.entities.some(e=>e.hp>0&&e.x===x&&e.y===y&&(e.id===7||e.id===8));
    return !this.entities.some(e=>e.hp>0&&e.x===x&&e.y===y&&!e.walkable);
  }
  los(a,b,sight) {
    if(dist(a,b)>sight*sight)return false;if(dist(a,b)===1)return true;
    let x=a.x,y=a.y,dx=Math.abs(b.x-x),dy=Math.abs(b.y-y),sx=x<b.x?1:-1,sy=y<b.y?1:-1,err=dx-dy,first=true;
    while(x!==b.x||y!==b.y) {
      if(!first&&!this.walkable(x,y,true))return false;first=false;const e=err*2;
      if(e>-dy){err-=dy;x+=sx;}if(e<dx){err+=dx;y+=sy;}
    }return true;
  }
  newFloor() {
    const raw=generate(this.g,this.depth,this.rng);this.rawFloor=copy(raw);this.droppedEntities=0;
    this.map=raw.tiles.flatMap(r=>r.match(/../g).map(s=>parseInt(s,16)));this.fog=new Uint8Array(4096).fill(2);
    const wall=(x,y)=>(this.g.flags[this.tile(x,y)]||0)&128;
    for(let x=0;x<128;x++)for(let y=0;y<32;y++)if(this.tile(x,y)===48) {
      this.map[y*128+x]=48+(wall(x-1,y)?2:0)+(wall(x+1,y)?4:0)+(wall(x,y-1)?1:0)+(wall(x,y+1)?8:0);
    }
    this.entities=[];let starts=0;
    for(let x=0;x<128;x++)for(let y=0;y<32;y++) {
      const t=this.tile(x,y);
      if(t===this.p.tile_start) {this.hero.x=x;this.hero.y=y;this.hero.oldX=x;this.hero.oldY=y;this.entities.push(this.hero);starts++;}
      else {const i=this.g.monsters.findIndex(m=>m.code===t);if(i>=0) {if(this.g.monsters[i].enabled===false&&i+1!==this.p.boss_id){this.map[y*128+x]=1;continue;}if(i===0)throw new Error('Use the start tile, not a hero entity code, in custom maps.');if(this.entities.filter(e=>e!==this.hero).length>=223){this.droppedEntities=(this.droppedEntities||0)+1;continue;}this.entities.push(this.makeEntity(i+1,x,y));this.map[y*128+x]=1;}}
    }
    if(starts!==1)throw new Error('A playable floor needs exactly one start tile.');
    if(this.droppedEntities)this.say('Entity capacity reached: excess map codes remain as tiles, as in VBXE.');
    for(let x=0;x<128;x++)for(let y=0;y<31;y++)if(wall(x,y)) {
      const i=(y+1)*128+x,v=this.map[i];if(v===1)this.map[i]=2;else if(!v)this.map[i]=3;
      else if(v>=32&&v<=42&&(v&3)!==3)this.map[i]=v|3;
    }
    this.updateFog();this.say(`${this.text('s_floor','Floor ')}${this.depth}`);
  }
  updateFog() {
    const sight=this.blind?this.p.blind_sight:this.hero.sight;
    for(let i=0;i<4096;i++)if(this.fog[i]===0)this.fog[i]=1;
    for(let y=Math.max(0,this.hero.y-sight-1);y<=Math.min(31,this.hero.y+sight+1);y++)for(let x=Math.max(0,this.hero.x-sight-1);x<=Math.min(127,this.hero.x+sight+1);x++) {
      if(this.los(this.hero,{x,y},sight))this.fog[y*128+x]=0;
    }
  }
  damage(e) {return e.atk+(e.weapon?.atk||0);}
  hp(e,amount,source) {
    e.hp=Math.max(0,Math.min(e.maxHp,e.hp+amount));
    if(amount) this.events.push({type:'hit',uid:e.uid,x:e.x,y:e.y,amount});
    if(e===this.hero&&e.hp<=0) {this.state='dead';this.killer=source?.name||'poison';this.say(`${this.text('s_killedby','Killed by ')}${this.killer} ${this.text('s_onfloor','on floor ')}${this.depth}.`);}
    return e.hp===0;
  }
  status(e) {
    if(e.poison>0) {e.poison--;this.hp(e,-1,{name:this.text('s_poison','poison')});}
    if(e.paralysis>0)e.paralysis--;if(e.confusion>0)e.confusion--;
  }
  attack(a,d) {
    const killed=this.hp(d,-this.damage(a),a);
    this.say(`${a.name} → ${d.name}: ${this.damage(a)} damage.`);
    if(killed&&a===this.hero) {
      a.xp++;
      while(a.level+1<this.g.xp_req.length&&a.xp>=this.g.xp_req[a.level+1]) {
        a.level++;a.atk+=this.p.lvl_atk;a.maxHp+=this.p.lvl_hp;a.hp=a.maxHp;this.say(`${this.text('s_lvlup','Level up')} ${a.level}! HP restored.`);
      }
      if(this.has(d,'treasure')) {
        const pool=this.g.items.map((it,i)=>({it,id:i+1})).filter(v=>v.it.found==='pot');
        const item=this.makeItem(this.rng.pick(pool)?.id,3);if(item){item.identified=true;this.giveItem(item);}
      } else if(this.has(d,'boss')) {this.state='won';this.say("^raq'zul is defeated!");}
    }
    const w=a.weapon;
    if(w) {
      if(w.status===2)d.poison+=3;
      else if(w.status===3&&this.rng.chance(.5)&&!this.has(d,'boss')) {d.confusion+=5;d.logic='confused';}
      else if(w.status===4&&this.rng.chance(.3)&&!this.has(d,'boss')) {d.paralysis+=2;d.logic='paralyzed';}
      else if(w.status===5&&this.rng.chance(.3))this.hp(a,1,a);
      if(w.trait===2&&--w.atk<=0) {this.say(w.name+this.text('s_a_shattered',' shattered!'));w.trait=1;this.discard(w);}
    }
    return true;
  }
  move(e,dx,dy) {
    e.dir=dx<0?-1:dx>0?1:e.dir;const x=e.x+dx,y=e.y+dy;
    if(this.walkable(x,y)) {e.oldX=e.x;e.oldY=e.y;e.x=x;e.y=y;e.frame=0;this.events.push({type:'move',uid:e.uid});return true;}
    if(e===this.hero)return this.interact(x,y);return false;
  }
  act(direction) {
    if(this.state!=='playing'||this.modal)return false;
    this.events=[];for(const e of this.entities){e.oldX=e.x;e.oldY=e.y;}const h=this.hero;
    let spent=false;
    if(h.paralysis>0)spent=true;
    else {if(h.confusion>0)direction=this.rng.int(4);if(direction>=0&&direction<4)spent=this.move(h,...DIR[direction]);else if(direction===4)spent=true;}
    if(spent)this.finishTurn();return spent;
  }
  finishTurn() {
    this.turn++;
    if(this.state!=='playing')return;
    if(this.tile(this.hero.x,this.hero.y)===this.p.tile_exit) {
      if(this.depth<this.p.last_floor){this.depth++;this.newFloor();}else this.say('Defeat the boss to win.');return;
    }
    for(const e of [...this.entities]) {
      if(e===this.hero||e.prop||e.hp<=0)continue;this.status(e);if(e.hp>0)this.ai(e);if(this.state!=='playing')break;
    }
    if(this.state==='playing')for(const e of this.entities)if(e.hp>0&&e.trap&&!e.used) {
      const target=this.entity(e.x,e.y,true);if(target){this.hp(target,-e.atk,e);e.used=true;e.anim--;}
    }
    if(this.state==='playing')this.status(this.hero);
    if(this.blind>0)this.blind--;
    this.entities=this.entities.filter(e=>e.hp>0||e===this.hero);
    this.entities.sort((a,b)=>a.y-b.y);this.updateFog();
  }
  ai(e) {
    const h=this.hero,has=a=>this.has(e,a);
    if(e.logic==='paralyzed') {if(e.paralysis===0){e.logic='chase';this.awaken(e);}return;}
    if(e.logic==='confused') {
      const options=DIR.filter(([dx,dy])=>floorTile(this.tile(e.x+dx,e.y+dy)));if(options.length)this.move(e,...this.rng.pick(options));
      if(!e.confusion)e.logic='chase';return;
    }
    if(e.logic==='wait'){this.awaken(e);return;}
    if(e.logic==='flee'){this.flee(e);return;}
    let see=this.los(e,h,e.sight);
    if(see||has('hunter')){e.gx=h.x;e.gy=h.y;see=true;}
    if(has('summon')) {
      if(!this.los(e,h,e.sight)){e.logic='wait';return;}
      if(e.cooldown){e.cooldown--;this.flee(e);e.logic='chase';return;}
      const spot=DIR.map(([dx,dy])=>[e.x+dx,e.y+dy]).find(([x,y])=>this.walkable(x,y));
      if(spot){if(this.entities.length<224&&this.g.monsters[this.p.summon_id-1]?.enabled!==false)this.entities.push(this.makeEntity(this.p.summon_id,...spot));e.cooldown=this.p.summon_wait;}return;
    }
    const aligned=e.x===h.x||e.y===h.y;
    if(see&&aligned&&dist(e,h)<=e.range*e.range) {
      if(has('boss')) {e.atk=dist(e,h)===1?this.p.boss_near_atk:this.p.boss_far_atk;if(dist(e,h)===1)this.hp(e,this.p.boss_heal,e);}
      let special=false;
      if(!e.special) {
        if(has('stun')){h.paralysis=Math.max(h.paralysis,this.p.stun_turns);special=true;}
        else if(has('curse')){this.fog.fill(2);this.updateFog();special=true;}
        else if(has('steal_item')) {const item=this.rng.pick(this.inventory.filter(it=>it&&it!==h.weapon));if(item)this.discard(item);special=true;}
        else if(has('steal_weapon')&&h.weapon) {const w=h.weapon;w.trait=1;this.discard(w);special=true;}
        if(special){e.special=true;this.say(`${e.name} uses ${e.abilities.filter(a=>['stun','curse','steal_item','steal_weapon'].includes(a)).join(', ')}.`);}
      }
      if(!special){this.attack(e,h);if(has('vampire')&&this.rng.chance(this.p.vampire_chance))this.hp(e,e.atk,e);if(has('blind'))this.blind=this.p.blind_turns;}
      if(has('poison'))h.poison+=this.p.poison_turns;
      if(has('paralyze')&&this.rng.chance(this.p.paralyze_chance))h.paralysis=this.p.paralyze_turns;
      if(e.range>1&&has('bolt')&&(!has('boss')||dist(e,h)>1)){h.confusion+=this.p.confuse_turns;this.events.push({type:'bolt',x:e.x,y:e.y,tx:h.x,ty:h.y});}
      if(has('blink')&&e.hp>0)this.blink(e);
      return;
    }
    if(has('still'))return;
    if(has('slow')){e.slow=!e.slow;if(!e.slow)return;}
    if(has('pounce')&&see&&aligned) {
      const dx=Math.sign(h.x-e.x),dy=Math.sign(h.y-e.y);let x=e.x,y=e.y,n=0;
      while(n<9&&!(x+dx===h.x&&y+dy===h.y)&&this.walkable(x+dx,y+dy)){x+=dx;y+=dy;n++;}
      if(n>=2&&n<9&&x+dx===h.x&&y+dy===h.y){e.oldX=e.x;e.oldY=e.y;e.x=x;e.y=y;return;}
    }
    let best=Infinity,dir=this.rng.int(4);
    for(let i=0;i<4;i++){const [dx,dy]=DIR[i],pos={x:e.x+dx,y:e.y+dy};if(this.walkable(pos.x,pos.y)){const d=dist(pos,{x:e.gx,y:e.gy});if(d<best){best=d;dir=i;}}}
    this.move(e,...DIR[dir]);if(e.x===e.gx&&e.y===e.gy&&!has('hunter'))e.logic='wait';
  }
  awaken(e) {
    if(this.has(e,'hunter')||this.los(e,this.hero,e.sight)) {e.gx=this.hero.x;e.gy=this.hero.y;e.logic=this.has(e,'flee')?'flee':'chase';this.events.push({type:'notice',x:e.x,y:e.y});}
  }
  flee(e) {
    let best=0,dir=-1;for(let i=0;i<4;i++){const [dx,dy]=DIR[i],pos={x:e.x+dx,y:e.y+dy};if(this.walkable(pos.x,pos.y)&&dist(pos,this.hero)>best){best=dist(pos,this.hero);dir=i;}}
    if(dir>=0)this.move(e,...DIR[dir]);if(dist(e,this.hero)>e.sight**2)e.logic='wait';
  }
  blink(e) {
    for(let n=0;n<256;n++){const x=e.x+this.rng.int(7)-3,y=e.y+this.rng.int(7)-3;if(floorTile(this.tile(x,y))&&this.walkable(x,y)){e.oldX=e.x=x;e.oldY=e.y=y;e.logic='chase';this.events.push({type:'blink',x,y});return;}}
  }
  makeItem(id,trait) {
    const data=this.g.items[id-1];if(!data)return null;
    const it={...copy(data),id,atk:Math.floor(data.atk+this.rng.next()*.2*data.atk),trait:1,status:1,identified:this.depth<=this.p.ident_upto||this.rng.chance(this.p.ident_chance)};
    if(!trait){if(this.rng.chance(this.p.bless_chance)&&this.depth>=this.p.bless_from)trait=3;else if(this.rng.chance(this.p.curse_chance)&&this.depth>=this.p.curse_from)trait=2;}
    if(trait===3){it.trait=3;for(const k of ['heal','hpmax','atk'])if(it[k]>0)it[k]+=1+Math.floor(it[k]*this.rng.next()*.5);}
    else if(trait===2){it.trait=2;it.heal=it.hpmax=0;}
    if(this.depth>=this.p.enchant_from&&it.type===1&&this.rng.chance(it.trait===2?this.p.enchant_cursed:this.p.enchant_other))this.enchant(it);
    return it;
  }
  enchant(it) {it.status=this.rng.int(4)+2;it.atk=Math.floor(it.atk*.7);}
  itemName(it) {return it.identified?this.text('tr_'+it.trait)+it.name+this.text('st_'+it.status):this.text('s_mysterious','mysterious ')+it.name;}
  giveItem(it,silent=false) {const slot=this.inventory.indexOf(null);if(slot<0){this.say(this.text('s_a_carry','Backpack full.'));return false;}this.inventory[slot]=it;if(!silent)this.say(this.itemName(it));return true;}
  unequip() {const w=this.hero.weapon;if(!w)return true;if(w.trait===2){this.say(w.name+this.text('s_a_stuck',' is stuck!'));return false;}this.hero.maxHp-=w.hpmax;this.hero.weapon=null;return true;}
  discard(it) {if(it===this.hero.weapon&&!this.unequip())return false;const i=this.inventory.indexOf(it);if(i>=0)this.inventory[i]=null;return true;}
  itemAction(slot,action) {
    if(this.state!=='playing'||this.modal)return false;
    const it=this.inventory[slot];if(!it)return false;this.events=[];for(const e of this.entities){e.oldX=e.x;e.oldY=e.y;}
    if(action==='discard')return this.discard(it);
    if(action==='unequip')return this.unequip();
    if(it.type===1){if(this.unequip()){this.hero.weapon=it;it.identified=true;return true;}return false;}
    const h=this.hero;h.maxHp+=it.hpmax;let heal=it.heal;
    if(it.trait===2){const r=this.rng.next();if(r<.2)heal=5;else if(r<.4){h.poison+=3;this.say(this.text('s_a_poison'));}else if(r<.6){h.confusion+=4;this.say(this.text('s_a_dizzy'));}else if(r<.8){h.paralysis+=3;this.say(this.text('s_a_glup'));}else{heal=-1;this.say(this.text('s_a_rotten'));}}
    this.hp(h,heal,it);this.discard(it);this.finishTurn();return true;
  }
  interact(x,y) {
    const mob=this.entity(x,y,true);if(mob)return this.attack(this.hero,mob);
    const e=this.entity(x,y);if(!e||e.used)return false;
    const h=this.hero;
    if([9,20,25].includes(e.id)) {
      if(!this.tried.has(e.id)){this.tried.add(e.id);this.modal=this.g.windows[e.id===9?'ml_altar':e.id===20?'ml_anvil':'ml_well'];return false;}
      if(e.id===9){const it=this.rng.pick(this.inventory.filter(v=>v&&!v.identified));if(!it){this.say(this.text('s_a_noident'));return false;}it.identified=true;this.say(this.itemName(it));}
      if(e.id===25){if(!h.weapon||h.weapon.trait!==2){this.say(this.text('s_a_dip'));return false;}h.weapon.trait=1;e.used=true;e.anim=21;this.say(h.weapon.name+this.text('s_a_nocurse'));}
      if(e.id===20) {
        const w=h.weapon;if(!w){this.say(this.text('s_a_equip'));return false;}if(w.trait!==1||w.status!==1){this.say(this.text('s_a_untampered'));return false;}
        const foods=this.inventory.filter(it=>it&&it.type===0&&it.trait===2);if(!foods.length){this.say(this.text('s_a_food'));return false;}
        this.discard(this.rng.pick(foods));if(this.rng.chance(1-.05*w.atk)){this.enchant(w);this.say(this.itemName(w));}else{this.say(w.name+this.text('s_a_shattererd'));this.discard(w);}
      }return true;
    }
    if(e.id===7||e.id===8){e.hp=0;return true;}
    if([4,5,6,18,21].includes(e.id)) {
      const found=e.id===5?'chest':e.id===6?'shelves':'pot';let id;
      if(e.id===5||e.hasitem){const pool=this.g.items.map((it,i)=>({it,id:i+1})).filter(v=>v.it.found===found&&v.it.depth<=this.depth);id=this.rng.pick(pool)?.id;}
      else if(e.id!==6&&this.rng.chance(this.p.pot_mob_chance)&&this.entities.length<224){const id=this.rng.chance(this.p.pot_mob_a_chance)?this.p.pot_mob_a:this.p.pot_mob_b;if(this.g.monsters[id-1]?.enabled!==false)this.entities.push(this.makeEntity(id,x,y));}
      if(id&&!this.giveItem(this.makeItem(id)))return false;
      e.used=true;e.anim--;if([4,18,21].includes(e.id))e.walkable=true;return true;
    }
    // Gates and levers retain the original port's blocking behavior.
    return true;
  }
}
const api={Game,Random,generate,DIR,floorTile};
if(typeof module!=='undefined'&&module.exports)module.exports=api;else root.LichPlay=api;
})(typeof globalThis!=='undefined'?globalThis:this);
