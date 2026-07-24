/* Streamline Demake - dependency-free Canvas edition.
 * Based on the PuzzleScript "Streamline Demake" by Francois van Niekerk.
 *
 * RULES (as written in typescriptversion.txt):
 *   [ > player trap ] -> cancel
 *     left  [ > player | no solid ] -> [ bodyleft  | > player bodyright ]
 *   + right [ > player | no solid ] -> [ bodyright | > player bodyleft  ]
 *   + up    [ > player | no solid ] -> [ bodyup    | > player bodydown  ]
 *   + down  [ > player | no solid ] -> [ bodydown  | > player bodyup    ]
 *   + [ player clear ] [ body     ] -> [ player clear ] []
 *   + [ player clear ] [ bodywall ] -> [ player clear ] []
 *   + [ moving player stop ] -> [ stationary player stop ]
 *
 *   [ body no bodywall no player ] -> [ body bodywall ]
 *
 *   WIN: all player on end
 *
 * Legend:
 *   . empty     @ player     # wall     P pause     C clear
 *   E end       X trap      (border is wall)
 *
 * Terrain and the moving line are stored on separate layers, matching
 * PuzzleScript collision layers. One input is one transaction: traps
 * cancel it completely and undo restores the state before the input.
 */

(function (root, factory) {
    if (typeof module === 'object' && module.exports) {
        // Node / test harness
        const noopWindow = { addEventListener: function () {} };
        const noopDoc = {
            getElementById: function () { return { getContext: function () { return {}; }, width: 0, height: 0, textContent: '', addEventListener: function () {} }; },
            addEventListener: function () {},
        };
        module.exports = factory(noopWindow, noopDoc);
    } else {
        // Browser
        root.Streamline = factory(root, root.document);
    }
})(typeof self !== 'undefined' ? self : (typeof window !== 'undefined' ? window : globalThis), function (window, document) {
    'use strict';

    // --- 16 levels (from streamlinejs/typescriptversion.txt) ---
    const LEVELS = [
`#######
#....e#
#...#.#
#.....#
#.#...#
#..#..#
#@....#
#######`,
`#######
#..#.e#
#.....#
#...#.#
#.....#
#.....#
#@...##
#######`,
`#######
#.#..e#
#.....#
#....##
#.#...#
#.....#
#@....#
#######`,
`#######
#....e#
#....##
##.#..#
#...#.#
#.#...#
#@.#..#
#######`,
`#######
#.#..e#
#...#.#
#.#..##
#....##
#..#..#
#@....#
#######`,
`#######
#..#.e#
#.....#
#....##
#.....#
#.....#
#@....#
#######`,
`#######
#..#.e#
#..#..#
#..#..#
#....##
#.....#
#@....#
#######`,
`#######
#....e#
#.....#
##...##
#..p..#
#.....#
#@....#
#######`,
`#######
#.#..e#
#...#.#
#....##
#...p.#
#.#...#
#@....#
#######`,
`#######
#....e#
##...##
#.....#
#.c.#.#
###.#.#
#@....#
#######`,
`#######
#...#e#
#.#...#
#.c..##
#...#.#
#.....#
#@....#
#######`,
`#######
#.....#
#..e..#
#..#..#
#.....#
#.#..p#
#@....#
#######`,
`#######
##....#
#...#.#
#....e#
#..x..#
#.....#
#@...x#
#######`,
`#########
#....#.e#
#..#....#
#.....x##
#.......#
#...p...#
##..x...#
#.......#
#@..#...#
#########`,
`#########
##....#e#
#...c...#
##....x##
#...#...#
#.#.....#
#....#..#
#.......#
#@......#
#########`,
`#########
#.....###
#.......#
#.x...#.#
#..#e...#
##...c.p#
#..#.#..#
#.......#
#@......#
#########`,
    ];

    // Tile IDs
    const EMPTY     = 0;
    const WALL      = 1;
    const PLAYER    = 2;
    const BODY_L    = 3;
    const BODY_R    = 4;
    const BODY_U    = 5;
    const BODY_D    = 6;
    const BODY_WALL = 7;
    const PAUSE     = 8;
    const CLEAR     = 9;
    const END       = 10;
    const TRAP      = 11;

    // Direction: 0=up, 1=right, 2=down, 3=left
    const DX = [0, 1, 0, -1];
    const DY = [-1, 0, 1, 0];
    const OPP = [2, 3, 0, 1];
    const BODY_OF_DIR = [BODY_U, BODY_R, BODY_D, BODY_L];

    function parseLevel(src) {
        const lines = src.split('\n').filter(l => l.length > 0);
        const h = lines.length, w = lines[0].length;
        const terrain = [];
        let px = 0, py = 0;
        for (let y = 0; y < h; y++) {
            const row = [];
            for (let x = 0; x < w; x++) {
                const c = lines[y][x];
                let t;
                switch (c) {
                    case '#': t = WALL; break;
                    case '.': t = EMPTY; break;
                    case 'E': case 'e': t = END; break;
                    case 'P': case 'p': t = PAUSE; break;
                    case 'C': case 'c': t = CLEAR; break;
                    case 'X': case 'x': t = TRAP; break;
                    case '@': t = EMPTY; px = x; py = y; break;
                    default:  t = EMPTY;
                }
                row.push(t);
            }
            terrain.push(row);
        }
        const state = {
            w, h, terrain, px, py,
            path: [[px, py]],
            cells: [],
            bodywall: [],
            originalSrc: src,
            history: [],
            undoStack: [],
            lastMove: null,
        };
        syncLayers(state);
        return state;
    }

    function inBounds(s, x, y) { return x >= 0 && y >= 0 && x < s.w && y < s.h; }

    function isSolid(s, x, y) {
        if (!inBounds(s, x, y)) return true;
        return s.terrain[y][x] === WALL || Boolean(s.bodywall[y][x]);
    }

    function syncLayers(s) {
        s.cells = s.terrain.map(row => row.slice());
        s.bodywall = Array.from({ length: s.h }, () => Array(s.w).fill(0));

        for (let i = 0; i < s.path.length - 1; i++) {
            const [x, y] = s.path[i];
            const [nx, ny] = s.path[i + 1];
            let dir = 0;
            if (nx > x) dir = 1;
            else if (ny > y) dir = 2;
            else if (nx < x) dir = 3;
            s.cells[y][x] = BODY_OF_DIR[dir];
            s.bodywall[y][x] = 1;
        }

        const headTerrain = s.terrain[s.py][s.px];
        if (headTerrain === EMPTY) s.cells[s.py][s.px] = PLAYER;
    }

    // Kept as part of the public test API. Dynamic path cells are already
    // sealed by syncLayers, so this simply re-synchronizes the layers.
    function sealBody(s) {
        syncLayers(s);
    }

    function snapshot(s) {
        return {
            px: s.px,
            py: s.py,
            path: s.path.map(([x, y]) => [x, y]),
            lastMove: s.lastMove,
        };
    }

    function restore(s, snap) {
        s.px = snap.px;
        s.py = snap.py;
        s.path = snap.path.map(([x, y]) => [x, y]);
        s.lastMove = snap.lastMove;
        syncLayers(s);
    }

    function clearTrail(s) {
        s.path = [[s.px, s.py]];
        syncLayers(s);
    }

    // One direction input is one transaction. Movement continues until a
    // solid cell or stop tile. A trap cancels the complete transaction.
    function move(s, d) {
        if (!Number.isInteger(d) || d < 0 || d > 3) return false;

        const before = snapshot(s);
        const traversed = [];
        let moved = false;

        while (true) {
            const nx = s.px + DX[d];
            const ny = s.py + DY[d];
            if (isSolid(s, nx, ny)) break;

            const tile = s.terrain[ny][nx];
            if (tile === TRAP) {
                restore(s, before);
                return false;
            }

            s.px = nx;
            s.py = ny;
            s.path.push([nx, ny]);
            traversed.push([nx, ny]);
            moved = true;
            syncLayers(s);

            // Clear removes the entire existing line, but does not stop motion.
            if (tile === CLEAR) clearTrail(s);

            if (tile === END || tile === PAUSE) break;
        }

        if (!moved) {
            restore(s, before);
            return false;
        }

        s.undoStack.push(before);
        s.history.push(d);
        s.lastMove = {
            direction: d,
            from: [before.px, before.py],
            to: [s.px, s.py],
            traversed,
            time: Date.now(),
        };
        syncLayers(s);
        return true;
    }

    function won(s) {
        return s.terrain[s.py][s.px] === END;
    }

    function undo(s) {
        if (s.undoStack.length === 0) return false;
        const previous = s.undoStack.pop();
        s.history.pop();
        restore(s, previous);
        s.lastMove = null;
        return true;
    }

    function resetState(s) {
        const fresh = parseLevel(s.originalSrc);
        s.terrain = fresh.terrain;
        s.px = fresh.px;
        s.py = fresh.py;
        s.path = fresh.path;
        s.history = [];
        s.undoStack = [];
        s.lastMove = null;
        syncLayers(s);
        return s;
    }

    // ============== RENDERING ==============
    const COLORS = {
        floor: '#121a2e',
        floorAlt: '#151f36',
        grid: '#26314d',
        wall: '#273451',
        wallEdge: '#3a496b',
        player: '#ff3d9a',
        playerHot: '#ff8dc5',
        end: '#ad5cff',
        pause: '#3fd8ff',
        clear: '#55f2c3',
        trap: '#ff5a72',
        body: '#ff3d9a',
        bodyCore: '#ffd0e6',
    };

    function roundedRect(ctx, x, y, w, h, r) {
        const radius = Math.min(r, w / 2, h / 2);
        ctx.beginPath();
        ctx.moveTo(x + radius, y);
        ctx.arcTo(x + w, y, x + w, y + h, radius);
        ctx.arcTo(x + w, y + h, x, y + h, radius);
        ctx.arcTo(x, y + h, x, y, radius);
        ctx.arcTo(x, y, x + w, y, radius);
        ctx.closePath();
    }

    function cellCenter(layout, x, y) {
        return [
            layout.offX + x * layout.cell + layout.cell / 2,
            layout.offY + y * layout.cell + layout.cell / 2,
        ];
    }

    function drawWall(ctx, x, y, size) {
        const gap = Math.max(1.5, size * 0.055);
        roundedRect(ctx, x + gap, y + gap, size - gap * 2, size - gap * 2, size * 0.16);
        ctx.fillStyle = COLORS.wall;
        ctx.fill();
        ctx.strokeStyle = COLORS.wallEdge;
        ctx.lineWidth = Math.max(1, size * 0.025);
        ctx.stroke();

        roundedRect(ctx, x + size * 0.14, y + size * 0.12, size * 0.72, size * 0.12, size * 0.06);
        ctx.fillStyle = 'rgba(255,255,255,.07)';
        ctx.fill();
    }

    function drawEnd(ctx, cx, cy, size, time, active) {
        const pulse = 1 + Math.sin(time * 0.004) * 0.07;
        ctx.save();
        ctx.translate(cx, cy);
        ctx.scale(pulse, pulse);
        ctx.shadowColor = COLORS.end;
        ctx.shadowBlur = size * (active ? 0.52 : 0.28);
        ctx.strokeStyle = COLORS.end;
        ctx.lineWidth = size * 0.09;
        ctx.beginPath();
        ctx.arc(0, 0, size * 0.27, 0, Math.PI * 2);
        ctx.stroke();
        ctx.shadowBlur = 0;
        ctx.strokeStyle = 'rgba(229,207,255,.75)';
        ctx.lineWidth = size * 0.035;
        ctx.beginPath();
        ctx.arc(0, 0, size * 0.15, time * 0.001, time * 0.001 + Math.PI * 1.35);
        ctx.stroke();
        ctx.restore();
    }

    function drawPause(ctx, cx, cy, size) {
        ctx.save();
        ctx.translate(cx, cy);
        ctx.rotate(Math.PI / 4);
        ctx.shadowColor = COLORS.pause;
        ctx.shadowBlur = size * 0.25;
        ctx.fillStyle = 'rgba(63,216,255,.18)';
        roundedRect(ctx, -size * 0.25, -size * 0.25, size * 0.5, size * 0.5, size * 0.08);
        ctx.fill();
        ctx.strokeStyle = COLORS.pause;
        ctx.lineWidth = size * 0.055;
        ctx.stroke();
        ctx.restore();
        ctx.fillStyle = COLORS.pause;
        ctx.fillRect(cx - size * 0.075, cy - size * 0.13, size * 0.055, size * 0.26);
        ctx.fillRect(cx + size * 0.02, cy - size * 0.13, size * 0.055, size * 0.26);
    }

    function drawClear(ctx, cx, cy, size, time) {
        const angle = -time * 0.0007;
        ctx.save();
        ctx.translate(cx, cy);
        ctx.rotate(angle);
        ctx.shadowColor = COLORS.clear;
        ctx.shadowBlur = size * 0.2;
        ctx.strokeStyle = COLORS.clear;
        ctx.lineWidth = size * 0.065;
        ctx.lineCap = 'round';
        ctx.beginPath();
        ctx.arc(0, 0, size * 0.24, Math.PI * 0.18, Math.PI * 1.72);
        ctx.stroke();
        ctx.fillStyle = COLORS.clear;
        ctx.beginPath();
        ctx.moveTo(size * 0.22, -size * 0.17);
        ctx.lineTo(size * 0.31, -size * 0.02);
        ctx.lineTo(size * 0.13, -size * 0.01);
        ctx.closePath();
        ctx.fill();
        ctx.restore();
    }

    function drawTrap(ctx, cx, cy, size) {
        ctx.save();
        ctx.translate(cx, cy);
        ctx.shadowColor = COLORS.trap;
        ctx.shadowBlur = size * 0.18;
        ctx.strokeStyle = COLORS.trap;
        ctx.lineWidth = size * 0.075;
        ctx.lineCap = 'round';
        ctx.beginPath();
        ctx.moveTo(-size * 0.2, -size * 0.2);
        ctx.lineTo(size * 0.2, size * 0.2);
        ctx.moveTo(size * 0.2, -size * 0.2);
        ctx.lineTo(-size * 0.2, size * 0.2);
        ctx.stroke();
        ctx.restore();
    }

    function render(canvas, s, time, effects) {
        const ctx = canvas.getContext('2d');
        if (!ctx || typeof ctx.fillRect !== 'function') return;
        const dpr = canvas._dpr || 1;
        const width = canvas._viewWidth || canvas.width / dpr;
        const height = canvas._viewHeight || canvas.height / dpr;
        const cell = Math.min(width / s.w, height / s.h);
        const layout = {
            cell,
            offX: (width - s.w * cell) / 2,
            offY: (height - s.h * cell) / 2,
        };
        time = Number.isFinite(time) ? time : 0;
        effects = effects || {};

        ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
        ctx.clearRect(0, 0, width, height);

        roundedRect(ctx, 0, 0, width, height, Math.min(24, cell * 0.35));
        ctx.fillStyle = '#0d1426';
        ctx.fill();

        for (let y = 0; y < s.h; y++) {
            for (let x = 0; x < s.w; x++) {
                const cx = layout.offX + x * cell;
                const cy = layout.offY + y * cell;
                ctx.fillStyle = (x + y) % 2 ? COLORS.floorAlt : COLORS.floor;
                ctx.fillRect(cx, cy, cell, cell);
                ctx.strokeStyle = COLORS.grid;
                ctx.globalAlpha = 0.25;
                ctx.lineWidth = 1;
                ctx.strokeRect(cx + 0.5, cy + 0.5, cell - 1, cell - 1);
                ctx.globalAlpha = 1;
            }
        }

        for (let y = 0; y < s.h; y++) {
            for (let x = 0; x < s.w; x++) {
                const t = s.terrain[y][x];
                const cx = layout.offX + x * cell;
                const cy = layout.offY + y * cell;
                const [mx, my] = cellCenter(layout, x, y);
                if (t === WALL) {
                    drawWall(ctx, cx, cy, cell);
                } else if (t === END) {
                    drawEnd(ctx, mx, my, cell, time, won(s));
                } else if (t === PAUSE) {
                    drawPause(ctx, mx, my, cell);
                } else if (t === CLEAR) {
                    drawClear(ctx, mx, my, cell, time);
                } else if (t === TRAP) {
                    drawTrap(ctx, mx, my, cell);
                }
            }
        }

        if (s.path.length > 1) {
            ctx.lineCap = 'round';
            ctx.lineJoin = 'round';
            ctx.beginPath();
            const [startX, startY] = cellCenter(layout, s.path[0][0], s.path[0][1]);
            ctx.moveTo(startX, startY);
            for (let i = 1; i < s.path.length; i++) {
                const [x, y] = cellCenter(layout, s.path[i][0], s.path[i][1]);
                ctx.lineTo(x, y);
            }
            ctx.shadowColor = COLORS.body;
            ctx.shadowBlur = cell * 0.34;
            ctx.strokeStyle = 'rgba(255,61,154,.38)';
            ctx.lineWidth = Math.max(5, cell * 0.34);
            ctx.stroke();
            ctx.shadowBlur = cell * 0.16;
            ctx.strokeStyle = COLORS.body;
            ctx.lineWidth = Math.max(3, cell * 0.19);
            ctx.stroke();
            ctx.shadowBlur = 0;
            ctx.strokeStyle = COLORS.bodyCore;
            ctx.globalAlpha = 0.58;
            ctx.lineWidth = Math.max(1, cell * 0.045);
            ctx.stroke();
            ctx.globalAlpha = 1;
        }

        const [hx, hy] = cellCenter(layout, s.px, s.py);
        const blockedPulse = effects.blockedAt && time - effects.blockedAt < 220
            ? Math.sin((time - effects.blockedAt) / 220 * Math.PI) * 0.12
            : 0;
        const radius = cell * (0.25 + blockedPulse);
        const headGradient = ctx.createRadialGradient(
            hx - radius * 0.35, hy - radius * 0.4, radius * 0.12,
            hx, hy, radius,
        );
        headGradient.addColorStop(0, '#fff2f8');
        headGradient.addColorStop(0.32, COLORS.playerHot);
        headGradient.addColorStop(1, COLORS.player);
        ctx.shadowColor = won(s) ? COLORS.end : COLORS.player;
        ctx.shadowBlur = cell * (won(s) ? 0.55 : 0.34);
        ctx.fillStyle = headGradient;
        ctx.beginPath();
        ctx.arc(hx, hy, radius, 0, Math.PI * 2);
        ctx.fill();
        ctx.shadowBlur = 0;
        ctx.fillStyle = 'rgba(255,255,255,.72)';
        ctx.beginPath();
        ctx.arc(hx - radius * 0.28, hy - radius * 0.32, radius * 0.19, 0, Math.PI * 2);
        ctx.fill();
    }

    // ============== APP ==============
    let state;
    let levelIdx = 0;
    let moveCount = 0;
    let animationFrame = 0;
    const effects = { blockedAt: 0, wonAt: 0 };

    function element(id) {
        return document.getElementById(id);
    }

    function setMessage(text, tone) {
        const message = element('msg');
        if (!message) return;
        message.textContent = text;
        message.dataset.tone = tone || '';
    }

    function updateHud() {
        const level = element('level');
        const moves = element('moves');
        const progress = element('progress-fill');
        if (level) level.textContent = `LEVEL ${String(levelIdx + 1).padStart(2, '0')} / ${LEVELS.length}`;
        if (moves) moves.textContent = String(moveCount).padStart(2, '0');
        if (progress) progress.style.width = `${((levelIdx + (won(state) ? 1 : 0)) / LEVELS.length) * 100}%`;
        const undoButton = element('undo-btn');
        if (undoButton) undoButton.disabled = !state || state.undoStack.length === 0;
    }

    function loadLevel(idx) {
        levelIdx = idx;
        state = parseLevel(LEVELS[idx]);
        moveCount = 0;
        effects.blockedAt = 0;
        effects.wonAt = 0;
        setMessage('Draw a path to the violet portal.');
        updateHud();
    }

    function nextLevel() {
        if (levelIdx + 1 < LEVELS.length) {
            loadLevel(levelIdx + 1);
            resize();
        } else {
            setMessage('All 16 levels complete — beautifully done.', 'win');
        }
    }

    function resize() {
        const canvas = element('canvas');
        if (!canvas || !state) return;
        const maxW = Math.min(760, Math.max(280, window.innerWidth - 48));
        const reserved = window.innerWidth < 700 ? 330 : 250;
        const maxH = Math.min(680, Math.max(280, window.innerHeight - reserved));
        const cell = Math.max(28, Math.min(86, Math.floor(Math.min(maxW / state.w, maxH / state.h))));
        const width = state.w * cell;
        const height = state.h * cell;
        const dpr = Math.min(2, window.devicePixelRatio || 1);
        canvas._viewWidth = width;
        canvas._viewHeight = height;
        canvas._dpr = dpr;
        canvas.style.width = `${width}px`;
        canvas.style.height = `${height}px`;
        canvas.width = Math.round(width * dpr);
        canvas.height = Math.round(height * dpr);
    }

    function tick(dir) {
        if (!state) return;
        if (won(state)) {
            nextLevel();
            return;
        }
        if (move(state, dir)) {
            moveCount++;
            setMessage('Keep the line moving.');
        } else {
            effects.blockedAt = performance.now();
            setMessage('That route is blocked.', 'blocked');
        }
        updateHud();
        if (won(state)) {
            effects.wonAt = performance.now();
            let best = moveCount;
            try {
                const key = `streamline-best-${levelIdx}`;
                const saved = Number(window.localStorage.getItem(key));
                best = saved > 0 ? Math.min(saved, moveCount) : moveCount;
                window.localStorage.setItem(key, String(best));
            } catch (e) { /* storage can be disabled */ }
            setMessage(`Portal reached in ${moveCount} moves · best ${best}. Press Enter to continue.`, 'win');
            updateHud();
        }
    }

    function restart() {
        if (!state) return;
        resetState(state);
        moveCount = 0;
        effects.blockedAt = 0;
        effects.wonAt = 0;
        setMessage('Level restarted.');
        updateHud();
    }

    function undoMove() {
        if (!state || !undo(state)) {
            setMessage('Nothing to undo.', 'blocked');
            return;
        }
        moveCount = Math.max(0, moveCount - 1);
        effects.wonAt = 0;
        setMessage('Last move restored.');
        updateHud();
    }

    function animate(time) {
        if (state) render(element('canvas'), state, time, effects);
        animationFrame = window.requestAnimationFrame(animate);
    }

    function bindControls() {
        document.querySelectorAll('[data-dir]').forEach(button => {
            button.addEventListener('click', () => tick(Number(button.dataset.dir)));
        });
        const undoButton = element('undo-btn');
        const resetButton = element('reset-btn');
        const nextButton = element('next-btn');
        if (undoButton) undoButton.addEventListener('click', undoMove);
        if (resetButton) resetButton.addEventListener('click', restart);
        if (nextButton) nextButton.addEventListener('click', nextLevel);

        const canvas = element('canvas');
        if (!canvas) return;
        let pointerStart = null;
        canvas.addEventListener('pointerdown', event => {
            pointerStart = [event.clientX, event.clientY];
            canvas.setPointerCapture(event.pointerId);
        });
        canvas.addEventListener('pointerup', event => {
            if (!pointerStart) return;
            const dx = event.clientX - pointerStart[0];
            const dy = event.clientY - pointerStart[1];
            pointerStart = null;
            if (Math.max(Math.abs(dx), Math.abs(dy)) < 18) return;
            tick(Math.abs(dx) > Math.abs(dy) ? (dx > 0 ? 1 : 3) : (dy > 0 ? 2 : 0));
        });
    }

    document.addEventListener('keydown', (e) => {
        if (!state) return;
        if (won(state) && (e.key === 'Enter' || e.key === ' ' || e.key === 'n' || e.key === 'N')) {
            nextLevel();
            e.preventDefault();
            return;
        }
        let dir = -1;
        switch (e.key) {
            case 'ArrowUp': case 'w': case 'W': dir = 0; break;
            case 'ArrowRight': case 'd': case 'D': dir = 1; break;
            case 'ArrowDown': case 's': case 'S': dir = 2; break;
            case 'ArrowLeft': case 'a': case 'A': dir = 3; break;
            case 'r': case 'R': restart(); e.preventDefault(); return;
            case 'u': case 'U': case 'Backspace': undoMove(); e.preventDefault(); return;
            case 'n': case 'N': nextLevel(); e.preventDefault(); return;
        }
        if (dir >= 0) { tick(dir); e.preventDefault(); }
    });

    window.addEventListener('resize', () => {
        if (state) resize();
    });

    // --- Boot (only in a real browser, not when run via require) ---
    try {
        const cv = element('canvas');
        if (cv) {
            const ctx2d = cv.getContext && cv.getContext('2d');
            if (ctx2d && typeof ctx2d.fillRect === 'function') {
                loadLevel(0);
                resize();
                bindControls();
                if (animationFrame) window.cancelAnimationFrame(animationFrame);
                animationFrame = window.requestAnimationFrame(animate);
            }
        }
    } catch (e) { /* not a browser */ }

    // Expose internals for testing
    return {
        LEVELS, parseLevel, move, undo, won, sealBody, resetState, render,
        BODY_L, BODY_R, BODY_U, BODY_D, BODY_WALL,
        PLAYER, WALL, PAUSE, CLEAR, END, TRAP, EMPTY,
        DX, DY, OPP, BODY_OF_DIR,
    };
});
