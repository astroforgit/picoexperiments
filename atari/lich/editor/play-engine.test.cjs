const test=require('node:test');
const assert=require('node:assert/strict');
const {Game,Random,generate}=require('./play-engine.js');
const fs=require('node:fs'),path=require('node:path');
const data=()=>JSON.parse(fs.readFileSync(path.join(__dirname,'../data/game.json')));
function fixture(placements=[],edit=()=>{}){
 const g=data();edit(g);const raw=Array.from({length:32},()=>Array(128).fill(0));
 for(let y=1;y<12;y++)for(let x=1;x<18;x++)raw[y][x]=(x===1||y===1||x===17||y===11)?48:1;
 raw[5][5]=g.params.tile_start;raw[9][15]=g.params.tile_exit;
 for(const [id,x,y] of placements)raw[y][x]=g.monsters[id-1].code;
 g.floors=[{name:'test',tiles:raw.map(r=>r.map(v=>v.toString(16).padStart(2,'0')).join(''))}];g.floor_plan=Array(15).fill(0);
 return new Game(g,{seed:42});
}
const mob=(g,id)=>g.entities.find(e=>e.id===id);
test('all eight generated floors: repeatable, bounded, populated, source data unchanged',()=>{
 const g=data(),before=JSON.stringify(g);
 for(let seed=1;seed<=30;seed++)for(let depth=1;depth<=8;depth++){
   const run=new Game(g,{seed,depth});assert.equal(run.state,'playing');assert.ok(run.entities.length<=224);
   assert.equal(run.entities.filter(e=>e===run.hero).length,1);
   if(depth===8&&seed!==19)assert.ok(mob(run,g.params.boss_id));
   else if(depth<8)assert.ok(run.map.includes(g.params.tile_exit));
 }
 assert.deepEqual(generate(g,5,new Random(42)),generate(g,5,new Random(42)));
 assert.equal(JSON.stringify(g),before);
});
test('blocked movement does not spend a turn; doors open on bump and block sight',()=>{
 const g=fixture([[7,6,5]]);
 assert.equal(g.los(g.hero,{x:7,y:5},4),false);
 g.act(1);assert.equal(g.hero.x,5);assert.equal(g.turn,1);assert.equal(mob(g,7),undefined);
 assert.equal(g.los(g.hero,{x:7,y:5},4),true);g.act(1);assert.equal(g.hero.x,6);
 g.hero.x=2;g.hero.y=2;const t=g.turn;assert.equal(g.act(0),false);assert.equal(g.turn,t);
});
test('awareness costs a turn before chase; melee uses fixed damage and equips without a turn',()=>{
 const g=fixture([[3,6,5]]);const ghoul=mob(g,3);
 g.act(4);assert.equal(ghoul.logic,'chase');assert.equal(g.hero.hp,6);
 g.itemAction(0,'equip');assert.equal(g.turn,1);assert.equal(g.damage(g.hero),4);
 g.act(1);assert.equal(ghoul.hp,2);assert.equal(g.hero.hp,5);
 g.act(1);assert.equal(g.hero.xp,1);assert.equal(g.hero.hp,5);assert.equal(mob(g,3),undefined);
});
test('poison ticks at end of hero turn; paralysis decrements at end of same turn',()=>{
 const g=fixture([[22,6,5],[23,5,6]],x=>{x.params.paralyze_chance=1;});
 mob(g,22).logic=mob(g,23).logic='chase';g.act(4);
 assert.equal(g.hero.poison,2);assert.equal(g.hero.paralysis,1);assert.equal(g.hero.hp,4);
 const x=g.hero.x;g.act(0);assert.equal(g.hero.x,x);
});
test('ranged bolts confuse along a clear row and blink changes positions',()=>{
 const g=fixture([[14,8,5],[15,5,6]]);mob(g,14).logic=mob(g,15).logic='chase';
 g.act(4);assert.equal(g.hero.confusion,1);assert.ok(g.events.some(e=>e.type==='bolt'));
 const imp=mob(g,15);assert.ok(imp.x!==5||imp.y!==6);assert.ok(g.map[imp.y*128+imp.x]);
});
test('slow skips movement, not melee attacks; still never moves',()=>{
 const g=fixture([[3,6,5]],x=>{x.monsters[2].abilities=['slow','still'];});const e=mob(g,3);e.logic='chase';
 g.act(4);g.act(4);assert.equal(g.hero.hp,4);assert.equal(e.x,6);
});
test('summoning, pouncing, theft, blindness and hunter awareness',()=>{
 const summon=fixture([[3,8,5]],x=>{x.monsters[2].abilities=['summon'];});mob(summon,3).logic='chase';summon.act(4);assert.ok(mob(summon,2));
 const pounce=fixture([[3,8,5]],x=>{x.monsters[2].abilities=['pounce'];});mob(pounce,3).logic='chase';pounce.act(4);assert.equal(mob(pounce,3).x,6);
 const steal=fixture([[3,6,5]],x=>{x.monsters[2].abilities=['steal_weapon','blind'];});steal.itemAction(0,'equip');mob(steal,3).logic='chase';steal.act(4);assert.equal(steal.hero.weapon,null);assert.equal(steal.hero.hp,6);steal.act(4);assert.equal(steal.blind,4);
 const hunter=fixture([[3,15,8]],x=>{x.monsters[2].abilities=['hunter'];});hunter.act(4);assert.equal(mob(hunter,3).logic,'chase');
});
test('food spends a turn, cursed weapons cannot be removed, well removes curse',()=>{
 const g=fixture([[25,6,5]]);g.hero.hp=3;g.itemAction(1,'use');assert.equal(g.hero.hp,4);assert.equal(g.turn,1);
 const w=g.inventory[0];w.trait=2;g.itemAction(0,'equip');assert.equal(g.itemAction(0,'unequip'),false);assert.equal(g.itemAction(0,'discard'),false);
 g.act(1);assert.ok(g.modal);g.modal=null;g.act(1);assert.equal(w.trait,1);assert.equal(mob(g,25).used,true);assert.equal(g.itemAction(0,'unequip'),true);
});
test('altar identifies; anvil consumes cursed food and enchants a normal weapon',()=>{
 const g=fixture([[9,6,5],[20,5,6]]);g.inventory[1].identified=false;g.tried.add(9);g.act(1);assert.equal(g.inventory[1].identified,true);
 g.itemAction(0,'equip');g.inventory[1].trait=2;g.tried.add(20);g.rng.chance=()=>true;g.act(3);
 assert.equal(g.inventory[1],null);assert.ok(g.hero.weapon.status>=2);assert.ok(g.hero.weapon.status<=5);
});
test('spikes fire once, stairs retain inventory and hero stats, boss death wins',()=>{
 const g=fixture([[13,6,5]]);g.act(1);assert.equal(g.hero.hp,1);g.act(0);g.act(1);assert.equal(g.hero.hp,1);
 const weapon=g.inventory[0];g.hero.x=14;g.hero.y=9;g.act(1);assert.equal(g.depth,2);assert.equal(g.hero.hp,1);assert.equal(g.inventory[0],weapon);
 const boss=fixture([[24,6,5]]);mob(boss,24).hp=1;boss.act(1);assert.equal(boss.state,'won');
});
test('zero-HP enemies cannot attack after poison; death ends player input',()=>{
 const g=fixture([[3,6,5]]),e=mob(g,3);e.hp=1;e.poison=1;e.logic='chase';g.act(4);assert.equal(g.hero.hp,6);
 g.hero.poison=10;g.hero.hp=1;g.act(4);assert.equal(g.state,'dead');const t=g.turn;assert.equal(g.act(4),false);assert.equal(g.turn,t);
});
test('XP levels restore health; cursed weapons wear and break',()=>{
 const g=fixture([[3,6,5]]);g.hero.xp=4;g.hero.hp=2;mob(g,3).hp=1;g.act(1);assert.equal(g.hero.level,2);assert.equal(g.hero.hp,9);
 const w=fixture([[3,6,5]]);w.inventory[0].trait=2;w.itemAction(0,'equip');w.act(1);assert.equal(w.hero.weapon,null);assert.equal(w.inventory[0],null);
});
test('invalid room settings fail rather than hang',()=>{
 const g=data();g.move_weights=[0,0,0,0];assert.throws(()=>generate(g,1,new Random(1)),/weight/);
 g.move_weights=[1,3,1,1];g.params.room_w_min=200;assert.throws(()=>generate(g,1,new Random(1)),/dimensions/);
});
test('matches captured VBXE entities, HP, map and fog over five joystick moves',()=>{
 const crypto=require('node:crypto'),ref=require('./fixtures/vbxe-melee.json');
 const g=fixture([[2,6,5],[3,8,5],[13,5,6],[7,5,4]]);
 const hash=arr=>crypto.createHash('sha256').update(Buffer.from(arr)).digest('hex');
 ref.states.forEach((s,i)=>{
   const entities=g.entities.filter(e=>e.hp>0).map(e=>[e.id,e.x,e.y,e.hp]).sort((a,b)=>a[0]-b[0]||a[1]-b[1]||a[2]-b[2]);
   assert.deepEqual(entities,s.entities,`entities at checkpoint ${i}`);assert.equal(g.hero.hp,s.hp);
   assert.equal(hash(g.map),s.mapHash,`map at checkpoint ${i}`);assert.equal(hash(g.fog),s.fogHash,`fog at checkpoint ${i}`);
   if(i<ref.directions.length)g.act(ref.directions[i]);
 });
});

test('disabled roster excludes procedural, custom-map, pot and summoned enemies',()=>{
 const data0=data();
 data0.monsters.forEach((m,i)=>{if(i&&!m.prop)m.enabled=false;});
 for(const depth of [1,4,8]){
  const run=new Game(data0,{seed:1,depth});
  assert.ok(run.entities.every(e=>e.id===1||e.prop||e.id===data0.params.boss_id));
 }
 const custom=fixture([[2,6,5]],g=>{g.monsters[1].enabled=false;});
 assert.equal(mob(custom,2),undefined);assert.equal(custom.tile(6,5),1);
 const pot=fixture([[4,6,5]],g=>{g.monsters[1].enabled=false;g.monsters[2].enabled=false;g.params.pot_mob_chance=1;g.monsters[3].itemchance=0;});
 pot.act(1);assert.equal(mob(pot,2),undefined);assert.equal(mob(pot,3),undefined);
 const summon=fixture([[3,7,5]],g=>{g.monsters[2].abilities=['summon'];g.monsters[g.params.summon_id-1].enabled=false;});
 for(let i=0;i<8;i++)summon.act(4);
 assert.equal(mob(summon,summon.p.summon_id),undefined);
});

test('additive bestiary preserves original definitions and has unique new slots and codes',()=>{
 const g=data();assert.equal(g.monsters.length,40);
 assert.equal(new Set(g.monsters.map(m=>m.code)).size,40);
 const added=g.monsters.filter(m=>m.catalog_key);assert.equal(added.length,15);
 assert.equal(new Set(added.flatMap(m=>[m.anim,m.anim+1,m.anim+2,m.anim+3])).size,60);
 assert.ok(added.every(m=>m.anim>=256&&m.anim+3<384&&!m.abilities.includes('boss')));
 const seen=new Set();for(let depth=1;depth<=8;depth++)for(let seed=1;seed<=15;seed++){
   const run=new Game(g,{depth,seed});run.entities.forEach(e=>seen.add(e.id));
 }
 added.forEach(m=>assert.ok(seen.has(g.monsters.indexOf(m)+1),m.name+' must be spawnable'));
});
