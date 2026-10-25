/* Pure, deterministic planning model. No DOM and no mutation of game data. */
(function (root) {
  'use strict';
  function rng(seed) {
    let n = Number(seed) >>> 0;
    return () => { n += 0x6D2B79F5; let t = Math.imul(n ^ n >>> 15, 1 | n);
      t ^= t + Math.imul(t ^ t >>> 7, 61 | t); return ((t ^ t >>> 14) >>> 0) / 4294967296; };
  }
  const enemies = g => g.monsters.map((m, i) => ({ ...m, id: i + 1 })).filter(m => m.id !== 1 && !m.prop);
  const eligible = (g, depth) => enemies(g).filter(m => m.depth <= depth);
  function roster(g, floor) {
    const codes = new Map();
    for (let i = g.monsters.length - 1; i >= 0; i--) {
      codes.set(g.monsters[i].code, i + 1);
    }
    const result = [];
    floor.tiles.forEach((row, y) => {
      for (let x = 0; x < 128; x++) {
        const code = parseInt(row.slice(x * 2, x * 2 + 2), 16), id = codes.get(code);
        if (id > 1 && !g.monsters[id - 1].prop && code !== g.params.tile_start) result.push({ id, x, y });
      }
    });
    return result;
  }
  // A connected design layout, deliberately not an emulation of the Atari generator.
  function sampleFloor(g, depth, seed) {
    const random = rng(seed), pick = a => a[Math.floor(random() * a.length)];
    const p = g.params, tiles = Array.from({ length: 32 }, () => Array(128).fill(0));
    const cells = [], centers = [];
    const count = Math.max(2, Math.min(24, p.rooms_base + p.rooms_per_floor * depth));
    for (let i = 0; i < count; i++) {
      const col = i % 12, row = Math.floor(i / 12), x = 1 + col * 10, y = 1 + row * 15;
      const w = Math.max(5, Math.min(10, p.room_w_min + Math.floor(random() * p.room_w_rnd)));
      const height = Math.max(5, Math.min(14, p.room_h_min + Math.floor(random() * p.room_h_rnd)));
      for (let dy = 0; dy < height; dy++) for (let dx = 0; dx < w; dx++) {
        tiles[y + dy][x + dx] = !dx || !dy || dx === w - 1 || dy === height - 1 ? 48 : 1;
        if (dx && dy && dx < w - 1 && dy < height - 1) cells.push([x + dx, y + dy]);
      }
      centers.push([x + Math.floor(w / 2), y + Math.floor(height / 2)]);
    }
    for (let i = 1; i < centers.length; i++) {
      let [x, y] = centers[i - 1]; const [tx, ty] = centers[i];
      while (x !== tx) { tiles[y][x] = 1; x += Math.sign(tx - x); }
      while (y !== ty) { tiles[y][x] = 1; y += Math.sign(ty - y); }
      tiles[y][x] = 1;
    }
    const start = centers[0], end = centers.at(-1);
    tiles[start[1]][start[0]] = p.tile_start;
    tiles[end[1]][end[0]] = depth === p.last_floor ? g.monsters[p.boss_id - 1].code : p.tile_exit;
    const available = cells.filter(([x, y]) => tiles[y][x] === 1);
    for (let i = available.length - 1; i > 0; i--) {
      const j = Math.floor(random() * (i + 1)); [available[i], available[j]] = [available[j], available[i]];
    }
    const pool = eligible(g, depth);
    const place = (n, choices) => {
      if (!choices.length) return;
      for (let i = 0; i < n && available.length; i++) {
        const [x, y] = available.pop(); tiles[y][x] = pick(choices).code;
      }
    };
    // The source loops while mobs_placed <= budget (inclusive).
    place(Math.max(0, (g.budget[depth - 1] || 0) + 1), pool);
    place(Math.max(0, (g.mimic_offset[depth - 1] || 0) + 1), [g.monsters[p.mimic_id - 1]].filter(Boolean));
    return { name: `Floor ${depth} design · seed ${seed}`, tiles: tiles.map(row => row.map(n => n.toString(16).padStart(2, '0')).join('')) };
  }
  const unsupported = new Set(['bolt', 'blink', 'flee', 'summon', 'hunter', 'blind', 'invisible', 'pounce']);
  function simulate(g, ids, config = {}) {
    const p = g.params, random = rng(config.seed ?? 1);
    let level = Math.max(1, config.level || 1), xp = g.xp_req[level] || 0;
    let maxHp = g.monsters[0].hp + (level - 1) * p.lvl_hp;
    let hp = Math.min(maxHp, config.hp ?? maxHp), atk = g.monsters[0].atk + (level - 1) * p.lvl_atk;
    let weapon = Number(config.weaponAttack || 0), poison = 0, paralysis = 0, kills = 0;
    const mobs = ids.map(id => { const m = g.monsters[id - 1];
      if (!m || m.prop || id === 1) throw new Error('Encounter must contain enemy IDs.');
      return { ...m, hp: m.hp, maxHp: m.hp, used: false }; });
    const warnings = [...new Set(mobs.flatMap(m => m.abilities.filter(a => unsupported.has(a))))];
    const log = [], snapshots = [{ turn: 0, hp, maxHp, enemies: mobs.map(m => m.hp) }];
    const say = (turn, message) => { if (config.log !== false) log.push({ turn, message }); };
    let turn = 0;
    for (; turn < 300 && hp > 0 && mobs.some(m => m.hp > 0);) {
      turn++;
      if (poison > 0) { poison--; hp = Math.max(0, hp - 1); say(turn, 'Poison: −1 HP.'); }
      if (hp <= 0) break;
      if (paralysis > 0) { paralysis--; say(turn, 'Hero cannot act.'); }
      else {
        const m = mobs.find(m => m.hp > 0), damage = atk + weapon;
        m.hp = Math.max(0, m.hp - damage); say(turn, `Hero hits ${m.name} for ${damage}.`);
        if (!m.hp) {
          kills++; xp++; say(turn, `${m.name} defeated. +1 XP.`);
          while (level + 1 < g.xp_req.length && xp >= g.xp_req[level + 1]) {
            level++; atk += p.lvl_atk; maxHp += p.lvl_hp; hp = maxHp;
            say(turn, `Level ${level}: HP restored to ${maxHp}.`);
          }
        }
      }
      const active = config.mode === 'sequence' ? mobs.filter(m => m.hp > 0).slice(0, 1) : mobs.filter(m => m.hp > 0);
      // In sequence mode, the next opponent engages on the next turn after a kill.
      if (config.mode === 'sequence' && snapshots.at(-1).enemies.filter(v => v > 0).length > mobs.filter(m => m.hp > 0).length) active.length = 0;
      for (const m of active) {
        const has = a => m.abilities.includes(a);
        if (has('slow') && turn % 2 === 1) continue;
        let special = false;
        if (!m.used) {
          if (has('stun')) { paralysis = Math.max(paralysis, p.stun_turns); special = true; }
          else if (has('curse') || has('steal_item')) special = true;
          else if (has('steal_weapon') && weapon) { weapon = 0; special = true; }
          if (special) { m.used = true; say(turn, `${m.name} uses its first-hit special.`); }
        }
        if (!special) {
          const damage = has('boss') ? p.boss_near_atk : m.atk;
          if (has('boss')) m.hp = Math.min(m.maxHp, m.hp + p.boss_heal);
          hp = Math.max(0, hp - damage); say(turn, `${m.name} hits hero for ${damage}.`);
          if (has('vampire') && random() < p.vampire_chance) m.hp = Math.min(m.maxHp, m.hp + m.atk);
        }
        if (has('poison')) poison += p.poison_turns;
        if (has('paralyze') && random() < p.paralyze_chance) paralysis = p.paralyze_turns;
        if (!hp) break;
      }
      snapshots.push({ turn, hp, maxHp, enemies: mobs.map(m => m.hp) });
    }
    // Preserve poison deaths in the replay too.
    if (snapshots.at(-1).hp !== hp) snapshots.push({ turn, hp, maxHp, enemies: mobs.map(m => m.hp) });
    return { outcome: hp <= 0 ? 'defeat' : mobs.some(m => m.hp > 0) ? 'turn limit' : 'victory', hp, maxHp, turn, kills, level, warnings, log, snapshots };
  }
  const api = { rng, enemies, eligible, roster, sampleFloor, simulate };
  if (typeof module !== 'undefined' && module.exports) module.exports = api;
  else root.LichLab = api;
})(typeof globalThis !== 'undefined' ? globalThis : this);
