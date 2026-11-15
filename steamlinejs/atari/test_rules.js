#!/usr/bin/env node
'use strict';

// Replays the original game's reference traces through bimbaj-rules.js, the
// rules the editor uses for playtesting and solving.
const path = require('path');
const { execFileSync } = require('child_process');
const { Game, solve } = require('./bimbaj-rules');

const cases = JSON.parse(execFileSync('node', [path.join(__dirname, 'reference_trace.js')], { maxBuffer: 1 << 28 }));
let checks = 0;
cases.forEach((testCase, caseIndex) => {
    const rows = testCase.text.split('\n');
    let game = new Game(rows);
    testCase.states.forEach((expected, step) => {
        const action = expected.action;
        if (action === 6) game = new Game(rows);
        else if (action === 5) game.undo();
        else if (action === 4) game.switchPlayer();
        else game.input(action);
        const actual = {
            paths: game.paths, active: game.won() ? 0 : game.active, moves: game.moves.length,
            won: game.won() ? 1 : 0, key: game.keyCollected(),
        };
        const wanted = { ...expected };
        delete wanted.action;
        if (JSON.stringify(actual) !== JSON.stringify(wanted)) {
            throw new Error(`case ${caseIndex}, step ${step}, action ${action}:\n${JSON.stringify(actual)}\n!=\n${JSON.stringify(wanted)}`);
        }
        checks++;
    });
});
console.log(`PASS: ${checks} actions match the original Player across ${cases.length} cases.`);

// The solver finds the bonus board's two-move route.
solve(['........E', '....#....', '....#....', '....#....', '....#....', '....#....', '..#####..', '....#....', '@........'], {
    onDone(result) {
        if (!result.solved || result.moves.length !== 2) throw new Error('Solver failed on the bonus board');
        console.log('PASS: solver finds shortest solutions.');
    },
});
