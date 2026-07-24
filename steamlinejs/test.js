// Logic tests for the Streamline rules engine.
const {
    LEVELS, parseLevel, move, undo, won, resetState, sealBody,
    PLAYER, WALL, PAUSE, CLEAR, END, TRAP,
} = require('./streamline.js');

let pass = 0;
let fail = 0;

function check(condition, message) {
    if (condition) {
        pass++;
        console.log(`  PASS ${message}`);
    } else {
        fail++;
        console.log(`  FAIL ${message}`);
    }
}

function stateKey(s) {
    return JSON.stringify({
        px: s.px,
        py: s.py,
        path: s.path,
        history: s.history,
    });
}

function cloneState(s) {
    const copy = parseLevel(s.originalSrc);
    copy.px = s.px;
    copy.py = s.py;
    copy.path = s.path.map(point => point.slice());
    copy.history = s.history.slice();
    copy.undoStack = [];
    sealBody(copy);
    return copy;
}

function collisionKey(s) {
    return `${s.px},${s.py}:` + s.bodywall.map(row => row.join('')).join('');
}

function shortestSolution(source, limit = 100000) {
    const first = parseLevel(source);
    const queue = [{ state: first, depth: 0 }];
    const seen = new Set([collisionKey(first)]);
    for (let cursor = 0; cursor < queue.length && cursor < limit; cursor++) {
        const current = queue[cursor];
        if (won(current.state)) return current.depth;
        for (let direction = 0; direction < 4; direction++) {
            const next = cloneState(current.state);
            if (!move(next, direction)) continue;
            const key = collisionKey(next);
            if (seen.has(key)) continue;
            seen.add(key);
            queue.push({ state: next, depth: current.depth + 1 });
        }
    }
    return -1;
}

console.log('--- Sliding and win condition ---');
{
    const s = parseLevel(LEVELS[0]);
    check(move(s, 0), 'one up input performs a complete slide');
    check(s.px === 1 && s.py === 1, 'slide stops at the upper wall');
    check(move(s, 1), 'one right input reaches the portal');
    check(won(s), 'player wins on the end tile');
    check(s.history.length === 2, 'history records inputs, not traversed cells');
}

console.log('--- Body collision ---');
{
    const s = parseLevel(
`#######
#.....#
#.....#
#.@...#
#.....#
#######`);
    move(s, 1);
    move(s, 0);
    move(s, 3);
    move(s, 2);
    move(s, 1);
    const before = stateKey(s);
    check(!move(s, 0), 'sealed trail blocks re-entry');
    check(stateKey(s) === before, 'blocked input does not mutate state');
}

console.log('--- Trap transaction ---');
{
    const s = parseLevel(
`#######
#@..X.#
#######`);
    const before = stateKey(s);
    check(!move(s, 1), 'trap cancels the input');
    check(stateKey(s) === before, 'trap rolls back the entire slide');
    check(s.terrain[1][4] === TRAP, 'trap remains on its terrain layer');
}

console.log('--- Stop tile ---');
{
    const s = parseLevel(
`#######
#@.P..#
#######`);
    check(move(s, 1), 'player can slide onto a stop tile');
    check(s.px === 3 && s.py === 1, 'pause tile stops motion immediately');
    check(s.terrain[s.py][s.px] === PAUSE, 'pause terrain is preserved under player');
}

console.log('--- Clear tile ---');
{
    const s = parseLevel(
`########
#......#
#..C...#
#......#
#@.....#
########`);
    move(s, 0);
    move(s, 1);
    move(s, 2);
    move(s, 3);
    move(s, 0);
    check(move(s, 1), 'player can cross a clear tile');
    check(s.px === 6 && s.py === 2, 'clear does not incorrectly stop movement');
    check(s.path[0][0] === 3 && s.path[0][1] === 2, 'clear removes the earlier trail');
    check(s.bodywall[1][1] === 0, 'old sealed trail is removed');
    check(s.terrain[2][3] === CLEAR, 'clear terrain remains intact');
}

console.log('--- Undo and restart ---');
{
    const s = parseLevel(LEVELS[0]);
    const start = stateKey(s);
    move(s, 1);
    check(undo(s), 'undo is available after a successful slide');
    check(stateKey(s) === start, 'undo restores the complete previous input');
    check(!undo(s), 'undo reports false at the beginning');

    move(s, 0);
    move(s, 1);
    resetState(s);
    check(s.px === 1 && s.py === 6, 'restart restores the initial player position');
    check(s.history.length === 0 && s.undoStack.length === 0, 'restart clears both histories');
}

console.log('--- Layer integrity ---');
{
    const s = parseLevel(
`#####
#E.P#
#C@X#
#####`);
    check(s.terrain[1][1] === END, 'end tile parses correctly');
    check(s.terrain[1][3] === PAUSE, 'pause tile parses correctly');
    check(s.terrain[2][1] === CLEAR, 'clear tile parses correctly');
    check(s.terrain[2][3] === TRAP, 'trap tile parses correctly');
    check(s.cells[2][2] === PLAYER, 'player occupies the dynamic layer');
    check(s.cells[0][0] === WALL, 'wall occupies the terrain layer');
}

console.log('\n--- Level data ---');
check(LEVELS.length === 16, 'all 16 demake levels are present');
const solutionLengths = LEVELS.map(source => shortestSolution(source));
check(solutionLengths.every(length => length > 0), 'all 16 levels remain solvable');
console.log(`  shortest solutions: ${solutionLengths.join(', ')}`);

console.log(`\n=== ${pass} pass, ${fail} fail ===`);
process.exit(fail ? 1 : 0);
