/* Browser approximation of grapple-vbxe.asm, using its PAL per-tick values.
 * No DOM dependency: the same engine runs in the editor and in Node tests.
 * Positions/velocities retain 8 fractional bits; collision uses integer pixels.
 */
(function (root) {
  "use strict";
  const TUNING = Object.freeze({hz: 50, width: 160, height: 100, worldHeight: 3824,
    gravity: 164 / 256, pull: 7, terminal: 8, hook: 24, drag: 102 / 256,
    waterTop: 984, waterBottom: 1608, breakTicks: 35,
    thwompStart: 3, thwompAcceleration: 1, thwompMax: 10, thwompSleep: 35,
    ballGravity: 41 / 256, ballDrag: 20 / 256, ballLimit: 8});
  const VECTORS = [[0,-1], [1,0], [0,1], [-1,0]];
  const clamp = (n, low, high) => Math.max(low, Math.min(high, n));
  const drag = (n, amount) => Math.sign(n) * Math.max(0, Math.abs(n) - amount);
  const speed = (n, fallback, low, high) => clamp(Math.round(Number(n) || fallback), low, high);
  const box = (x, y, left, top, width, height) => ({x: Math.floor(x) + left,
    y: Math.floor(y) + top, w: width, h: height});
  const overlap = (a, b) => a.x < b.x + b.w && a.x + a.w > b.x &&
    a.y < b.y + b.h && a.y + a.h > b.y;
  const contains = (b, x, y) => x >= b.x && x < b.x + b.w && y >= b.y && y < b.y + b.h;

  class AtariPhysics {
    constructor(cells, start = {x: 56, y: 152}) {
      // Playtesting is a snapshot. Moving actors and flags never mutate edits.
      this.cells = cells.map(c => ({...c}));
      this.start = {...start};
      this.respawn = {...start};
      this.checkpoint = null;
      this.deaths = 0;
      this.ticks = 0;
      this.message = "Ready";
      this.reset();
    }
    entities(tile) {
      return this.cells.filter(c => c.tile === tile).map(c => ({...c,
        entityId: c.id, id: c.y * 12 + c.x, x: c.x * 16 - 8, y: c.y * 16 - 8}));
    }
    reset(reason) {
      if (reason) { this.deaths++; this.message = reason; }
      this.player = {...this.respawn, vx: 0, vy: 0, faceLeft: false};
      this.hook = null;
      this.cooldown = 0;
      this.waterPhase = 0;
      this.inWater = false;
      this.frame = 0;
      this.movers = this.entities(13).map(c => ({...c, dir: [2,3,0,1][c.rot],
        step: Math.round(speed(c.speed, 64, 8, 200) / 50 * 256) / 256}));
      this.thwomps = this.entities(17).map(c => ({...c, dir: 0, state: 0, timer: 0, maxSpeed: Math.max(1, Math.min(10, Math.round((Number(c.speed) || 500) / 50))), speed: 0}));
      this.cannons = this.entities(14).map(c => ({...c, timer: Math.round(c.x * 50 / 160),
        step: Math.round(speed(c.bulletSpeed, 350, 50, 500) / Math.SQRT2 / 50 * 256) / 256}));
      this.spikes = this.entities(16);
      this.checkpoints = this.entities(11);
      this.lava = this.entities(18).map(c => ({...c, x: c.x - 8, y: c.y - 8}));
      this.balls = [];
      this.updateCamera();
    }
    restart() {
      this.respawn = {...this.start};
      this.checkpoint = null;
      this.deaths = this.ticks = 0;
      this.message = "Restarted from test start";
      this.reset();
    }
    tileAt(x, y) {
      const col = Math.floor((x + 16) / 16), row = Math.floor((y + 16) / 16);
      return this.cells[row * 12 + col]?.tile ?? -1;
    }
    solid(x, y) {
      if (x < 0 || x >= 160 || y < 0 || y >= 3824) return true;
      const tile = this.tileAt(x, y);
      return tile >= 1 && tile <= 10;
    }
    hitsMap(b) {
      return this.solid(b.x, b.y) || this.solid(b.x + b.w - 1, b.y) ||
        this.solid(b.x, b.y + b.h - 1) || this.solid(b.x + b.w - 1, b.y + b.h - 1);
    }
    playerBox() { return box(this.player.x, this.player.y, -4, -12, 8, 12); }
    thwompBox(t) { return box(t.x, t.y, -8, -8, 16, 16); }
    canSpawn(x, y) {
      const b = box(x, y, -4, -12, 8, 12);
      return !this.hitsMap(b) && !this.hazards().some(h => overlap(b, h.bounds));
    }
    updateCamera() { this.camera = clamp(Math.floor(this.player.y) - 50, 0, 3724); }
    input(keys) {
      // Match joystick precedence and retain an existing hook while held.
      const held = [!!keys.up, !!keys.right, !!keys.down, !!keys.left];
      if (this.hook && !held[this.hook.dir]) this.hook = null;
      const dir = held[2] ? 2 : held[0] ? 0 : held[1] ? 1 : held[3] ? 3 : -1;
      if (!this.hook && dir >= 0 && !this.cooldown) {
        this.hook = {x: Math.floor(this.player.x), y: Math.floor(this.player.y) - 6,
          dir, pulling: false};
        this.player.vx = this.player.vy = 0;
      }
      if (dir === 3) this.player.faceLeft = true;
      if (dir === 1) this.player.faceLeft = false;
    }
    advanceHook() {
      const h = this.hook;
      if (!h || h.pulling) return;
      const [dx, dy] = VECTORS[h.dir];
      for (let i = 0; i < TUNING.hook; i++) {
        h.x += dx; h.y += dy;
        if (this.solid(h.x, h.y)) { h.pulling = true; return; }
        if (this.tileAt(h.x, h.y) === 18) {
          this.hook = null; this.cooldown = TUNING.breakTicks; return;
        }
      }
    }
    movePlayer() {
      const p = this.player;
      this.inWater = Math.floor(p.y) > 984 && Math.floor(p.y) - 12 < 1608;
      if (this.cooldown) this.cooldown--;
      if (this.hook) {
        const [dx, dy] = VECTORS[this.hook.dir];
        p.vx = this.hook.pulling ? dx * TUNING.pull : 0;
        p.vy = this.hook.pulling ? dy * TUNING.pull : 0;
      } else p.vy = Math.min(TUNING.terminal, p.vy + TUNING.gravity);
      if (p.vx && (this.solid(Math.floor(p.x) - 4, Math.floor(p.y)) ||
          this.solid(Math.floor(p.x) + 3, Math.floor(p.y)))) p.vx = drag(p.vx, TUNING.drag);
      // Atari rolls back a blocked axis rather than sliding to its edge.
      const oldX = p.x; p.x += p.vx;
      if (this.hitsMap(this.playerBox())) { p.x = oldX; p.vx = 0; }
      const oldY = p.y; p.y += p.vy;
      if (this.hitsMap(this.playerBox())) { p.y = oldY; p.vy = 0; }
      this.advanceHook();
    }
    moveMovers() {
      for (const m of this.movers) {
        if (m.y - this.camera < -32 || m.y - this.camera >= 132) continue;
        const oldX = m.x, oldY = m.y, [dx,dy] = VECTORS[m.dir];
        m.x += dx * m.step; m.y += dy * m.step;
        if (this.hitsMap(box(m.x, m.y, -6, -6, 12, 12))) {
          m.x = oldX; m.y = oldY; m.dir ^= 2;
        }
      }
    }
    seesPlayer(t, dir) {
      const p = this.playerBox(), [dx,dy] = VECTORS[dir];
      let x = t.x, y = t.y;
      for (let i = 0; i < 500; i++) {
        x += dx * 8; y += dy * 8;
        if ((dir === 0 && y <= p.y + p.h - 1) || (dir === 1 && x >= p.x) ||
            (dir === 2 && y >= p.y) || (dir === 3 && x <= p.x + p.w - 1)) return true;
        if (this.solid(x,y) || this.thwomps.some(other => other !== t &&
            contains(this.thwompBox(other), x,y))) return false;
      }
      return false;
    }
    blockedThwomp(t) {
      const bounds = this.thwompBox(t);
      return this.hitsMap(bounds) || this.thwomps.some(other => other !== t &&
        overlap(bounds, this.thwompBox(other)));
    }
    moveThwomps() {
      const p = this.playerBox();
      for (const t of this.thwomps) {
        // No viewport culling: blocks must enter from the offscreen shafts.
        if (t.state === 2) {
          if (!t.timer || --t.timer === 0) t.state = 0;
        } else if (t.state === 0) {
          let dir = -1;
          if (t.y >= p.y && t.y < p.y + p.h) {
            if (t.x < p.x) dir = 1;
            else if (t.x >= p.x + p.w) dir = 3;
          } else if (t.x >= p.x && t.x < p.x + p.w) dir = t.y < p.y ? 2 : 0;
          if (dir >= 0 && this.seesPlayer(t, dir)) {
            t.dir = dir; t.state = 1; t.speed = Math.min(TUNING.thwompStart, t.maxSpeed);
          }
        } else {
          t.speed = Math.min(t.maxSpeed, t.speed + TUNING.thwompAcceleration);
          const oldX = t.x, oldY = t.y, [dx,dy] = VECTORS[t.dir];
          t.x += dx * t.speed; t.y += dy * t.speed;
          if (this.blockedThwomp(t)) {
            t.x = oldX; t.y = oldY;
            for (let i = 0; i < TUNING.thwompMax; i++) {
              t.x += dx; t.y += dy;
              if (this.blockedThwomp(t)) { t.x -= dx; t.y -= dy; break; }
            }
            t.state = 2; t.timer = TUNING.thwompSleep; t.speed = 0;
          }
        }
      }
    }
    moveCannons() {
      for (const c of this.cannons) {
        if (c.y - this.camera < -120 || c.y - this.camera >= 120) continue;
        if (c.timer > 0) c.timer--;
        if (!c.timer) {
          if (this.balls.length < TUNING.ballLimit) {
            const [dx,dy] = [[-1,-1],[1,-1],[1,1],[-1,1]][c.rot];
            this.balls.push({x:c.x + dx * 7, y:c.y + dy * 7,
              vx:dx * c.step, vy:dy * c.step});
          }
          c.timer = 50;
        }
      }
      this.balls = this.balls.filter(b => {
        b.vx = drag(b.vx, TUNING.ballDrag); b.vy += TUNING.ballGravity;
        b.x += b.vx; b.y += b.vy;
        return !this.solid(Math.floor(b.x), Math.floor(b.y));
      });
    }
    checkpointBox(c) {
      return c.rot & 1 ? box(c.x,c.y,0,-8,16,16) : box(c.x,c.y,-8,-16,16,16);
    }
    hazards() {
      return [
        ...this.movers.map(m => ({name:"Moving brick",bounds:box(m.x,m.y,-6,-6,12,12)})),
        ...this.thwomps.map(t => ({name:"Thwomp",bounds:this.thwompBox(t)})),
        ...this.spikes.map(s => ({name:"Spikes",bounds:box(s.x,s.y,-7,-7,14,14)})),
        ...this.cannons.map(c => ({name:"Cannon",bounds:box(c.x,c.y,-7,-7,14,14)})),
        ...this.lava.map(l => ({name:"Lava",bounds:box(l.x,l.y,0,0,16,16)})),
        ...this.balls.map(b => ({name:"Cannonball",bounds:box(b.x,b.y,-4,-4,8,8)}))];
    }
    tick(keys = {}) {
      this.input(keys);
      this.moveMovers(); this.moveThwomps(); this.moveCannons(); this.movePlayer();
      const body = this.playerBox();
      const cp = this.checkpoints.find(c => c.id !== this.checkpoint && overlap(body,this.checkpointBox(c)));
      if (cp) {
        this.checkpoint = cp.id; this.respawn = {x:cp.x,y:cp.y + 7};
        this.message = `Checkpoint · row ${Math.floor(cp.id / 12)}`;
      }
      const hit = this.hazards().find(h => overlap(body,h.bounds));
      if (hit) this.reset(hit.name);
      this.updateCamera(); this.frame++; this.ticks++;
    }
  }
  AtariPhysics.TUNING = TUNING;
  AtariPhysics.overlap = overlap;
  if (typeof module !== "undefined" && module.exports) module.exports = AtariPhysics;
  else root.AtariPhysics = AtariPhysics;
})(typeof globalThis !== "undefined" ? globalThis : this);
