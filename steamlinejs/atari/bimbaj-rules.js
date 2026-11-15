// Bimbaj movement rules for the editor's playtest and solver: a port of the
// original Streamline Player (orggame.js "grow.gl.Player"), which the Atari
// code is tested against. test_rules.js replays the reference traces here.
(function (root, factory) {
    if (typeof module === 'object' && module.exports) module.exports = factory();
    else root.BimbajRules = factory();
}(typeof self !== 'undefined' ? self : this, function () {
    'use strict';

    const CHARS = '.@E#PRX%^>v<LK';
    const T = { EMPTY: 0, START: 1, END: 2, WALL: 3, PAUSE: 4, RESET: 5, TRAP: 6, PORTAL: 7, LOCK: 12, KEY: 13 };
    const DX = [0, 1, 0, -1];
    const DY = [-1, 0, 1, 0];
    const forceDir = type => (type >= 8 && type <= 11 ? type - 8 : -1);

    class Game {
        constructor(rows) {
            this.rows = rows;
            this.width = rows[0].length;
            this.height = rows.length;
            this.cells = [...rows.join('')].map(char => CHARS.indexOf(char));
            // The original enumerates starts column by column.
            this.paths = [];
            for (let x = 0; x < this.width; x++) {
                for (let y = 0; y < this.height; y++) {
                    if (this.cells[y * this.width + x] === T.START) this.paths.push([y * this.width + x]);
                }
            }
            this.history = this.paths.map(path => [path.slice()]);
            this.moves = [];
            this.active = 0;
            // Portal pairing: the other portal in (x, y) order.
            this.portals = this.cells.map((type, i) => i).filter(i => this.cells[i] === T.PORTAL)
                .sort((a, b) => (a % this.width) - (b % this.width) || a - b);
        }

        cell(x, y) {
            return x >= 0 && x < this.width && y >= 0 && y < this.height ? y * this.width + x : -1;
        }

        keyCollected() {
            return this.paths.some(path => path.some(i => this.cells[i] === T.KEY));
        }

        navigable(i) {
            const type = this.cells[i];
            return type !== T.WALL && (type !== T.LOCK || this.keyCollected());
        }

        // Cells before a player's last spiral have been retracted.
        hasBody(i) {
            return this.paths.some(path => {
                let body = false;
                for (const cell of path) {
                    if (this.cells[cell] === T.RESET) body = false;
                    if (cell === i) body = true;
                }
                return body;
            });
        }

        bodyStart(player) {
            const path = this.paths[player];
            let start = 0;
            path.forEach((cell, index) => { if (this.cells[cell] === T.RESET) start = index; });
            return start;
        }

        head(player) {
            const path = this.paths[player];
            return path[path.length - 1];
        }

        onEnd(player) {
            return this.cells[this.head(player)] === T.END;
        }

        won() {
            return this.paths.every((_, player) => this.onEnd(player));
        }

        canUndo(player, dir) {
            const path = this.paths[player];
            const head = path[path.length - 1];
            const back = path[path.length - 2];
            return back !== undefined &&
                this.cell(head % this.width + DX[dir], Math.floor(head / this.width) + DY[dir]) === back;
        }

        moveOnce(player, dir) {
            const path = this.paths[player];
            const head = path[path.length - 1];
            if (this.cells[head] === T.END || this.cells[head] === T.TRAP) return false;
            const next = this.cell(head % this.width + DX[dir], Math.floor(head / this.width) + DY[dir]);
            if (next < 0 || !this.navigable(next) || this.hasBody(next)) return false;
            path.push(next);
            if (this.cells[next] === T.PORTAL) {
                const other = this.portals.find(i => i !== next);
                if (other !== undefined && this.navigable(other) && !this.hasBody(other)) path.push(other);
            }
            return true;
        }

        // Slide until something stops the tip; arrows turn it.
        move(player, dir) {
            if (this.canUndo(player, dir)) return false;
            let steps = 0;
            while (this.moveOnce(player, dir)) {
                steps++;
                const type = this.cells[this.head(player)];
                if ([T.WALL, T.PAUSE, T.TRAP, T.END].includes(type)) break;
                if (forceDir(type) >= 0) dir = forceDir(type);
            }
            if (!steps) return false;
            this.history[player].push(this.paths[player].slice());
            this.moves.push(player);
            return true;
        }

        undo() {
            const player = this.moves.pop();
            if (player === undefined) return false;
            this.active = player;
            this.history[player].pop();
            this.paths[player] = this.history[player][this.history[player].length - 1].slice();
            return true;
        }

        // One joystick press, as the Atari game handles it.
        input(dir) {
            const player = this.active;
            if (this.canUndo(player, dir)) return this.undo();
            if (!this.move(player, dir)) return false;
            if (this.onEnd(player) && !this.won()) this.active = this.paths.findIndex((_, p) => !this.onEnd(p));
            return true;
        }

        switchPlayer() {
            this.active = (this.active + 1) % this.paths.length;
        }

        clone() {
            const copy = Object.create(Game.prototype);
            Object.assign(copy, this);
            copy.paths = this.paths.map(path => path.slice());
            copy.history = this.paths.map(() => []);
            copy.moves = [];
            return copy;
        }
    }

    // Breadth-first search over trunk states for the fewest moves. Undo is
    // never needed; switching elephants is free. Runs in slices so the page
    // stays responsive; onProgress may return false to cancel.
    function solve(rows, { limit = 400000, onProgress, onDone }) {
        const start = new Game(rows);
        const key = game => game.paths.map(path => path.join(',')).join('|');
        const seen = new Map([[key(start), null]]);
        let frontier = [start];
        let depth = 0;
        let explored = 0;
        const finish = result => onDone(Object.assign({ explored }, result));
        if (start.won()) return finish({ solved: true, moves: [] });

        function trace(stateKey) {
            const moves = [];
            for (let entry = seen.get(stateKey); entry; entry = seen.get(entry.parent)) moves.unshift(entry.move);
            return moves;
        }

        let next = [];
        let index = 0;
        function step() {
            const until = Date.now() + 25;
            while (Date.now() < until) {
                if (index >= frontier.length) {
                    if (!next.length) return finish({ solved: false, complete: true });
                    frontier = next;
                    next = [];
                    index = 0;
                    depth++;
                }
                const game = frontier[index++];
                const parent = key(game);
                for (let player = 0; player < game.paths.length; player++) {
                    if (game.onEnd(player)) continue;
                    for (let dir = 0; dir < 4; dir++) {
                        const child = game.clone();
                        if (!child.move(player, dir)) continue;
                        const childKey = key(child);
                        if (seen.has(childKey)) continue;
                        seen.set(childKey, { parent, move: { player, dir } });
                        if (child.won()) return finish({ solved: true, moves: trace(childKey) });
                        next.push(child);
                    }
                }
                explored++;
                if (seen.size > limit) return finish({ solved: false, complete: false });
            }
            if (onProgress && onProgress({ explored, depth }) === false) return finish({ solved: false, cancelled: true });
            setTimeout(step, 0);
        }
        step();
    }

    return { CHARS, T, DX, DY, Game, solve };
}));
