"use strict";
// Reachability check: searches joystick macro-actions over AtariPhysics from the
// entrance/each checkpoint to the next one. Usage:
//   node reachability.js [world.json] [sectionIndexes, e.g. 6,7,8]   (EXP=n sets the budget)
// FAIL means "not found within budget", not proof of impossibility.
const Game = require("./atari-physics.js");

const box = (x, y, left, top, width, height) => ({x: Math.floor(x) + left, y: Math.floor(y) + top, w: width, h: height});
class FastGame extends Game {
  hazards() {
    if (!this._static) {
      this._static = [
        ...this.spikes.map(s => ({name:"Spikes",bounds:box(s.x,s.y,-7,-7,14,14)})),
        ...this.cannons.map(c => ({name:"Cannon",bounds:box(c.x,c.y,-7,-7,14,14)})),
        ...this.lava.map(l => ({name:"Lava",bounds:box(l.x,l.y,0,0,16,16)}))];
    }
    const out = this._static.slice();
    for (const m of this.movers) out.push({name:"Moving brick",bounds:box(m.x,m.y,-6,-6,12,12)});
    for (const t of this.thwomps) out.push({name:"Thwomp",bounds:this.thwompBox(t)});
    for (const b of this.balls) out.push({name:"Cannonball",bounds:box(b.x,b.y,-4,-4,8,8)});
    return out;
  }
}
function cloneGame(g) {
  const c = Object.create(FastGame.prototype); c._static = g._static;
  c.cells = g.cells; c.start = g.start; c.respawn = g.respawn; c.checkpoint = g.checkpoint;
  c.deaths = g.deaths; c.ticks = g.ticks; c.message = g.message;
  c.player = {...g.player}; c.hook = g.hook ? {...g.hook} : null;
  c.cooldown = g.cooldown; c.waterPhase = g.waterPhase; c.inWater = g.inWater; c.frame = g.frame;
  c.movers = g.movers.map(m => ({...m})); c.thwomps = g.thwomps.map(t => ({...t}));
  c.cannons = g.cannons.map(x => ({...x})); c.spikes = g.spikes; c.checkpoints = g.checkpoints;
  c.lava = g.lava; c.balls = g.balls.map(b => ({...b})); c.camera = g.camera;
  return c;
}
const KEYS = [{up:true},{right:true},{down:true},{left:true},{}];
const HOLD = [3,8,16,30];
const REST = [3,10,25];

class Heap {
  constructor(){this.a=[];}
  push(n){const a=this.a;a.push(n);let i=a.length-1;while(i>0){const p=(i-1)>>1;if(a[p].f<=a[i].f)break;[a[p],a[i]]=[a[i],a[p]];i=p;}}
  pop(){const a=this.a;const top=a[0];const last=a.pop();if(a.length){a[0]=last;let i=0;for(;;){let l=2*i+1,r=l+1,m=i;if(l<a.length&&a[l].f<a[m].f)m=l;if(r<a.length&&a[r].f<a[m].f)m=r;if(m===i)break;[a[m],a[i]]=[a[i],a[m]];i=m;}}return top;}
  get size(){return this.a.length;}
}

/* Search from `start` until `goal(game)` is true. Returns {ticks, path, expansions} or null. */
function solve(cells, start, goal, opts = {}) {
  const maxExp = opts.maxExpansions || 150000;
  const targetY = opts.targetY; // heuristic guidance
  const weight = opts.weight ?? 0.5;
  const root = opts.game ? cloneGame(opts.game) : new FastGame(cells, start);
  if (opts.checkpoint !== undefined) { root.checkpoint = opts.checkpoint; }
  const heur = g => targetY === undefined ? 0 : Math.abs(targetY - g.player.y) / 6;
  const key = g => {
    const p = g.player;
    return [Math.floor(p.x/6), Math.floor(p.y/6), g.hook ? g.hook.dir + (g.hook.pulling?4:0) : 9,
      g.cooldown ? 1 : 0, Math.round(p.vx), Math.min(8, Math.round(p.vy)), g.inWater?g.waterPhase:0,
      ...g.thwomps.filter(t => Math.abs(t.y - p.y) < 200).map(t => `${t.state}${Math.floor(t.x/16)}_${Math.floor(t.y/16)}`),
      ...g.movers.filter(m => Math.abs(m.y - p.y) < 120).map(m => `m${Math.floor(m.x/6)}_${Math.floor(m.y/6)}${m.dir}`),
      ...g.balls.length ? [`b${g.balls.length}`] : []].join(",");
  };
  const heap = new Heap();
  const seen = new Map();
  heap.push({g: root, t: 0, f: heur(root), path: []});
  seen.set(key(root), 0);
  let exp = 0, best = null;
  while (heap.size && exp < maxExp) {
    const node = heap.pop();
    exp++;
    if (opts.verbose && exp % 5000 === 0) console.log(`  exp ${exp} heap ${heap.size} best y ${node.g.player.y.toFixed(0)} t ${node.t}`);
    for (let k = 0; k < KEYS.length; k++) {
      const durations = k === 4 ? REST : HOLD;
      for (const d of durations) {
        const g = cloneGame(node.g);
        let died = false, ok = false, used = 0;
        for (let i = 0; i < d; i++) {
          const deaths = g.deaths;
          g.tick(KEYS[k]); used++;
          if (g.deaths !== deaths) { died = true; break; }
          if (goal(g)) { ok = true; break; }
        }
        if (died) continue;
        const t = node.t + used;
        const path = node.path.concat([[k, used]]);
        if (ok) return {ticks: t, path, expansions: exp, game: g};
        const kk = key(g);
        const prev = seen.get(kk);
        if (prev !== undefined && prev <= t) continue;
        seen.set(kk, t);
        heap.push({g, t, f: t * weight + heur(g), path});
      }
    }
  }
  return null;
}

function describe(path) {
  const names = ["UP","RIGHT","DOWN","LEFT","--"];
  return path.map(([k,d]) => `${names[k]}x${d}`).join(" ");
}
module.exports = {solve, describe, cloneGame};

if (require.main === module) {
  const fs = require("fs");
  const file = process.argv[2] || require("path").join(__dirname, "../bin/assets/world.json");
  const world = JSON.parse(fs.readFileSync(file));
  let cells = world.layers[0].tiles;
  // Mirror the editor's legacy lava migration when no tile-18 cells exist.
  if (!cells.some(c => c.tile === 18)) {
    const rects = [{x:2.5,y:124.25,width:5,height:2.5},{x:2.5,y:134.25,width:5,height:2.5},
      {x:8.25,y:144.25,width:2,height:6},{x:-0.25,y:148.25,width:2,height:6}];
    cells = cells.map(c => ({...c}));
    for (const r of rects) for (const c of cells)
      if (c.x+.5 >= r.x+1 && c.x+.5 < r.x+1+r.width && c.y+.5 >= r.y+1 && c.y+.5 < r.y+1+r.height) c.tile = 18;
  }
  const cps = cells.filter(c => c.tile === 11).sort((a,b) => a.y - b.y || a.x - b.x);
  let start = {x: 56, y: 152};
  let prevId = null;
  const only = process.argv[3] ? process.argv[3].split(",").map(Number) : null;
  const order = [...cps.map(c => ({c, id: c.y*12+c.x})), {c: null, id: null}];
  let index = 0;
  for (const {c, id} of order) {
    if (only && !only.includes(index)) { index++; if (c) start = {x: c.x*16-8, y: c.y*16-8+7}; prevId = id; continue; }
    const label = c ? `checkpoint ${index} at (${c.x},${c.y})` : "bottom of map";
    const goal = c ? g => g.checkpoint === id : g => g.player.y >= 3700;
    const t0 = Date.now();
    const res = solve(cells, start, goal, {targetY: c ? c.y*16 : 3800, checkpoint: prevId, maxExpansions: Number(process.env.EXP) || 40000, verbose: !!process.env.V});
    if (res) console.log(`OK  ${label}: ${res.ticks} ticks (${(res.ticks/50).toFixed(1)}s), ${res.expansions} exp, ${Date.now()-t0}ms\n    ${describe(res.path)}`);
    else console.log(`FAIL ${label}: unreachable within budget (${Date.now()-t0}ms)`);
    if (c) start = {x: c.x*16-8, y: c.y*16-8+7};
    prevId = id; index++;
  }
}
