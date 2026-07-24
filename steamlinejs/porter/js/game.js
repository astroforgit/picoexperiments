// Porter Patch JS - Accurate Version
const canvas = document.getElementById('game');
const ctx = canvas.getContext('2d');
const spritesheet = document.getElementById('spritesheet');

const TILE = 8;
const GRAVITY = 0.6;
const MAX_DX = 1.5;
const JUMP = 3.7;

// Input
const keys = { left: false, right: false, up: false, down: false, fire: false };
document.addEventListener('keydown', e => {
    if (e.code === 'ArrowLeft') keys.left = true;
    if (e.code === 'ArrowRight') keys.right = true;
    if (e.code === 'ArrowUp') keys.up = true;
    if (e.code === 'ArrowDown') keys.down = true;
    if (e.code === 'Space' || e.code === 'KeyZ' || e.code === 'KeyX') keys.fire = true;
});
document.addEventListener('keyup', e => {
    if (e.code === 'ArrowLeft') keys.left = false;
    if (e.code === 'ArrowRight') keys.right = false;
    if (e.code === 'ArrowUp') keys.up = false;
    if (e.code === 'ArrowDown') keys.down = false;
    if (e.code === 'Space' || e.code === 'KeyZ' || e.code === 'KeyX') keys.fire = false;
});

let spritesLoaded = spritesheet.complete && spritesheet.naturalWidth > 0;
spritesheet.addEventListener('load', () => {
    spritesLoaded = true;
});
spritesheet.addEventListener('error', () => {
    spritesLoaded = false;
    console.error('Failed to load spritesheet:', spritesheet.currentSrc || spritesheet.src);
});

const particles = [];
let shake = 0;

function addParticle(x, y, dx, dy, life, size) {
    particles.push({ x, y, dx, dy, life, maxLife: life, size });
}

function updateParticles() {
    for (let i = particles.length - 1; i >= 0; i--) {
        const p = particles[i];
        p.x += p.dx; p.y += p.dy; p.dy += 0.15; p.size *= 0.9; p.life--;
        if (p.life <= 0) particles.splice(i, 1);
    }
}

// Draw sprite from 128x128 sheet (16x16 grid of 8x8 sprites)
function spr(s, x, y, flip = false) {
    if (!spritesLoaded) return;
    const sx = (s % 16) * 8;
    const sy = Math.floor(s / 16) * 8;
    ctx.save();
    if (flip) { ctx.scale(-1, 1); ctx.drawImage(spritesheet, sx, sy, 8, 8, -(x + 8), y, 8, 8); }
    else ctx.drawImage(spritesheet, sx, sy, 8, 8, x, y, 8, 8);
    ctx.restore();
}

// Player object
const player = {
    x: 28, y: 52, w: 8, h: 8,
    dx: 0, dy: 0,
    onGround: false, facing: 1, sprite: 1,
    canTeleport: false, startx: 28, starty: 52,
    animTimer: 0, running: false, jumping: false, falling: false, landedFlip: true
};

// Game objects
const rocks = [], feathers = [], coins = [], switches = [], platforms = [];

// Level data (extracted from PICO-8 map)
const map = new Array(64).fill(0).map(() => new Uint8Array(128).fill(0));

// Set up level geometry - Level 1 from original
function initMap() {
    // Clear map
    for (let y = 0; y < 64; y++) {
        for (let x = 0; x < 128; x++) {
            map[y][x] = 0;
        }
    }
    // Player starts at y=52 pixels, which is tile row 6 (floor(52/8)=6)
    // Need ground at tile row 6 for player to stand on
    for (let x = 0; x < 128; x++) {
        map[6][x] = 1; // ground at y=48-56 pixels
    }
    // Level 1 platforms (tile coordinates)
    for (let x = 6; x < 12; x++) map[6][x] = 1; // already ground
    for (let x = 20; x < 26; x++) map[6][x] = 1; // already ground
    // Additional platforms
    for (let x = 34; x < 40; x++) map[6][x] = 1;
    for (let x = 30; x < 36; x++) map[4][x] = 1; // y=32-40 pixels
    for (let x = 45; x < 51; x++) map[3][x] = 1; // y=24-32 pixels
    for (let x = 60; x < 66; x++) map[5][x] = 1; // y=40-48 pixels
    for (let x = 70; x < 76; x++) map[4][x] = 1;
    for (let x = 80; x < 86; x++) map[5][x] = 1;
}

function initObjects() {
    coins.length = rocks.length = feathers.length = switches.length = platforms.length = 0;
    // Level 1 coins (from original PICO-8 map)
    coins.push({ x: 104, y: 56, w: 6, h: 6, collected: false });
    coins.push({ x: 216, y: 80, w: 6, h: 6, collected: false });
    coins.push({ x: 352, y: 48, w: 6, h: 6, collected: false });
    coins.push({ x: 424, y: 88, w: 6, h: 6, collected: false });
}

// Collision
function collides(obj) {
    const x1 = Math.floor(obj.x / TILE), y1 = Math.floor(obj.y / TILE);
    const x2 = Math.floor((obj.x + obj.w - 1) / TILE), y2 = Math.floor((obj.y + obj.h - 1) / TILE);
    for (let y = y1; y <= y2; y++) {
        for (let x = x1; x <= x2; x++) {
            if (x >= 0 && x < 128 && y >= 0 && y < 64 && map[y][x] === 1) return true;
        }
    }
    return false;
}

function objCollide(o1, o2) {
    return o1.x + o1.w > o2.x && o1.x < o2.x + o2.w && o1.y + o1.h > o2.y && o1.y < o2.y + o2.h;
}

// Teleport
function teleport() {
    if (!player.canTeleport) return;
    let tx = player.x, ty = player.y;
    if (keys.up) ty -= 24;
    else if (keys.down) ty += 24;
    else if (player.facing < 0) tx -= 24;
    else tx += 24;
    const test = { x: tx, y: ty, w: player.w, h: player.h };
    if (!collides(test)) {
        addParticle(player.x + 4, player.y + 4, (Math.random() - 0.5) * 2, (Math.random() - 0.5) * 2, 15, 3);
        player.x = tx; player.y = ty;
        document.getElementById('teleports').textContent = ++totalTeleports;
        player.canTeleport = false;
    }
}

// Game state
let gameState = 'start', gameTime = 0, totalDeaths = 0, totalTeleports = 0, currentLevel = 1;
const cam = { x: 0, y: 0 };

function update(dt) {
    if (gameState !== 'playing') return;
    gameTime += dt;
    document.getElementById('time').textContent = `${Math.floor(gameTime / 60)}:${(gameTime % 60).toString().padStart(2, '0')}`;

    // Animation timer
    player.animTimer += dt;

    // Track state changes
    const wasOnGround = player.onGround;

    // Player animation - match original PICO-8
    player.running = false;
    if (keys.left || keys.right) player.running = true;

    if (player.running && player.onGround && player.animTimer > 5) {
        player.animTimer = 0;
        player.sprite = (player.sprite === 3 || player.sprite === 6) ? 4 : player.sprite + 1;
        if (player.sprite > 6) player.sprite = 3;
    } else if (player.onGround && !player.running) {
        player.sprite = 1;
    }

    // Jump
    if (keys.up && player.onGround) {
        player.dy = -JUMP; player.onGround = false; player.sprite = 7;
        addParticle(player.x + 4, player.y + 8, player.facing > 0 ? -0.5 : 0.5, -0.3, 10, 3);
    }

    // Move
    if (keys.left) { player.dx -= 0.4; player.facing = -1; }
    if (keys.right) { player.dx += 0.4; player.facing = 1; }
    player.dx *= 0.85;
    if (player.dx > MAX_DX) player.dx = MAX_DX;
    if (player.dx < -MAX_DX) player.dx = -MAX_DX;

    // Teleport
    if (keys.fire) teleport();

    // Physics
    player.dy += GRAVITY;
    if (player.dy > 3) player.dy = 3;
    player.x += player.dx; player.y += player.dy;

    // Collision
    if (collides(player)) {
        if (player.dy > 0) {
            player.y = Math.floor(player.y / TILE) * TILE - player.h;
            player.dy = 0; player.onGround = true; player.canTeleport = true;
            addParticle(player.x + 4, player.y + 8, player.facing * 1, -0.1, 8, 2);
        } else if (player.dy < 0) player.dy = 0;
        if (player.dx > 0) player.x = Math.floor(player.x / TILE) * TILE - player.w;
        if (player.dx < 0) player.x = Math.ceil(player.x / TILE) * TILE;
    } else {
        player.onGround = false;
        if (player.dy > 0.5) player.sprite = 8; // falling
    }

    // Death
    if (player.y > 400) {
        totalDeaths++;
        document.getElementById('deaths').textContent = totalDeaths;
        player.x = player.startx; player.y = player.starty; player.dx = 0; player.dy = 0;
        shake = 10;
    }

    // Update objects
    for (const r of rocks) {
        r.dy += GRAVITY; r.y += r.dy;
        if (collides(r) && r.dy > 0) { r.y = Math.floor(r.y / TILE) * TILE - r.h; r.dy = 0; }
    }

    for (const c of coins) {
        if (!c.collected && objCollide(player, c)) {
            c.collected = true;
            addParticle(c.x + 3, c.y + 4, 0, -2, 15, 3);
        }
    }

    // Camera
    cam.x = Math.max(0, Math.min(128 * TILE - canvas.width, player.x - canvas.width / 2));
    cam.y = Math.max(0, Math.min(64 * TILE - canvas.height, player.y - canvas.height / 2));

    // Shake
    if (shake > 0) { shake *= 0.8; if (shake < 0.5) shake = 0; }

    updateParticles();
}

function draw() {
    ctx.fillStyle = '#5a9';
    ctx.fillRect(0, 0, canvas.width, canvas.height);
    ctx.save();
    ctx.translate(shake, 0);

    // Map
    ctx.fillStyle = '#333';
    for (let y = 0; y < 64; y++) {
        for (let x = 0; x < 128; x++) {
            if (map[y][x] === 1) ctx.fillRect(x * TILE - cam.x, y * TILE - cam.y, TILE, TILE);
        }
    }

    // Objects - use sprites from spritesheet
    // Rock sprite 74
    for (const r of rocks) spr(74, r.x - cam.x, r.y - cam.y);
    
    // Feather sprite 75  
    for (const f of feathers) spr(75, f.x - cam.x, f.y - cam.y);
    
    // Coin sprite 48
    for (const c of coins) if (!c.collected) spr(48, c.x - cam.x, c.y - cam.y);

    // Particles
    ctx.fillStyle = '#fff';
    for (const p of particles) {
        ctx.globalAlpha = Math.min(1, p.life / p.maxLife);
        ctx.fillRect(Math.floor(p.x - cam.x), Math.floor(p.y - cam.y), p.size, p.size);
    }
    ctx.globalAlpha = 1;

    // Player - use sprite from sheet
    // Match original: 1=idle, 3-6=run, 7=jump, 8=fall
    const playerSpr = player.onGround && !player.running ? 1 : 
                      player.running && player.onGround ? player.sprite :
                      player.dy > 0 ? 8 : 7;
    spr(playerSpr, player.x - cam.x, player.y - cam.y, player.facing < 0);

    ctx.restore();

    if (gameState === 'start') {
        ctx.fillStyle = 'rgba(0,0,0,0.8)';
        ctx.fillRect(0, 0, canvas.width, canvas.height);
        ctx.fillStyle = '#fff';
        ctx.font = 'bold 16px monospace';
        ctx.fillText('PORTER PATCH', 80, 100);
        ctx.font = '12px monospace';
        ctx.fillText('Arrows: Move', 70, 130);
        ctx.fillText('Z/X/Space: Teleport', 55, 150);
        ctx.fillText('Up: Jump', 95, 170);
    }
}

let lastTime = 0;
function loop(ts) {
    const dt = Math.min(2, (ts - lastTime) / 16.667);
    lastTime = ts;
    update(dt);
    draw();
    requestAnimationFrame(loop);
}

initMap();
initObjects();
document.getElementById('start-btn').onclick = () => {
    gameState = 'playing';
    document.getElementById('start-btn').style.display = 'none';
    document.getElementById('stats').style.display = 'block';
    lastTime = performance.now();
    requestAnimationFrame(loop);
};
draw();