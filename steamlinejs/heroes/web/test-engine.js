"use strict";

var game = require("./engine.js");

function assert(condition, message) {
  if (!condition) {
    throw new Error(message);
  }
}

function nearestEnemy(state, hero) {
  var target = -1;
  var bestDistance = 127;
  var enemy;
  var distance;
  for (enemy = 0; enemy < state.unitCount; enemy += 1) {
    if (state.unitAlive[enemy] &&
        state.unitTeam[enemy] === game.TEAM_ENEMY) {
      distance = game.distance(state.unitCell[hero], state.unitCell[enemy]);
      if (distance < bestDistance) {
        bestDistance = distance;
        target = enemy;
      }
    }
  }
  return target;
}

function moveOrAttack(state, hero) {
  var target = nearestEnemy(state, hero);
  var targetDistance;
  var bestCell = -1;
  var bestDistance;
  var direction;
  var cell;
  var distance;

  if (target < 0) {
    return false;
  }

  targetDistance = game.distance(state.unitCell[hero], state.unitCell[target]);
  if (targetDistance <= game.TYPE_RANGE[state.unitType[hero]]) {
    return game.selectOrAct(state.unitCell[target]) === 1;
  }

  bestDistance = targetDistance;
  for (direction = 0; direction < 6; direction += 1) {
    cell = game.neighbour(state.unitCell[hero], direction);
    if (cell >= 0 &&
        state.terrain[cell] === game.TERRAIN_OPEN &&
        game.unitAt(cell) < 0) {
      distance = game.distance(cell, state.unitCell[target]);
      if (distance < bestDistance) {
        bestDistance = distance;
        bestCell = cell;
      }
    }
  }
  if (bestCell >= 0) {
    return game.selectOrAct(bestCell) === 1;
  }
  return false;
}

function run() {
  var state;
  var hero;
  var actions = 0;

  game.init();
  state = game.getState();
  assert(state.unitCount === 5, "battle must start with five units");
  assert(game.distance(game.cellOf(0, 0), game.cellOf(1, 0)) === 1,
    "horizontal cells must be neighbours");
  assert(game.distance(game.cellOf(1, 2), game.cellOf(1, 3)) === 1,
    "offset-row cells must be neighbours");
  assert(state.selectedUnit === 0, "first hero must be selected automatically");
  assert(game.TYPE_MOVE[state.unitType[0]] === 2,
    "knight must have a two-cell move");
  assert(game.TYPE_MOVE[state.unitType[1]] === 2,
    "archer must have a two-cell move");
  assert(game.movementCost(state.unitCell[0], game.cellOf(3, 2)) === 2,
    "two-cell destination must be reachable");
  assert(game.selectOrAct(game.cellOf(3, 2)) === 1,
    "active knight must move two cells");
  state = game.getState();
  assert(state.eventCount === 1 &&
      state.eventType[0] === game.EVENT_MOVE &&
      state.eventUnit[0] === 0,
    "knight movement event must be recorded");
  assert(state.selectedUnit === 1 && state.unitActed[0] === 1,
    "a direct two-cell move must finish the knight automatically");
  assert(game.selectOrAct(game.cellOf(2, 4)) === 1,
    "active archer must move two cells");
  state = game.getState();
  assert(state.turnNumber === 2 && state.selectedUnit === 0,
    "enemy phase and next ordered hero turn must start automatically");
  assert(state.eventCount >= 2 &&
      state.eventType[0] === game.EVENT_MOVE &&
      state.eventUnit[0] === 1 &&
      state.unitTeam[state.eventUnit[1]] === game.TEAM_ENEMY,
    "the final move and enemy actions must be recorded in order");

  game.init();
  assert(game.selectOrAct(game.cellOf(2, 2)) === 1,
    "knight must be able to spend one movement step");
  state = game.getState();
  assert(state.selectedUnit === 0 && state.unitMoveLeft[0] === 1,
    "one-step movement must leave one adjacent movement step");
  assert(game.selectOrAct(game.cellOf(3, 2)) === 1,
    "knight must be able to spend its remaining movement step");
  state = game.getState();
  assert(state.unitMoveLeft[0] === 0 &&
      state.unitActed[0] === 1 && state.selectedUnit === 1,
    "the second movement action must finish the hero automatically");

  game.init();
  assert(game.selectOrAct(game.cellOf(2, 2)) === 1 &&
      game.skipActiveHero() === 1 &&
      game.getState().selectedUnit === 1,
    "skip must finish a hero after its first movement action");

  game.init();
  assert(game.skipActiveHero() === 1,
    "knight must be skippable before moving");
  assert(game.selectOrAct(game.cellOf(1, 4)) === 1,
    "archer must be able to make a one-step move before attacking");
  assert(game.selectOrAct(game.cellOf(4, 4)) === 1,
    "archer must be able to attack after moving");
  state = game.getState();
  assert(state.unitHP[4] === game.TYPE_HP[state.unitType[4]] -
      game.TYPE_DAMAGE[game.UNIT_ARCHER],
    "move-plus-attack must damage the target");

  game.init();
  assert(game.skipActiveHero() === 1 &&
      game.getState().selectedUnit === 1,
    "skip must advance from the first hero to the second");
  assert(game.skipActiveHero() === 1 &&
      game.getState().turnNumber === 2 &&
      game.getState().selectedUnit === 0,
    "skipping the last hero must run enemies and start the next round");

  game.init(4);
  state = game.getState();
  assert(state.battleNumber === 4 && state.battleCount === 4,
    "battle four must be selectable");
  assert(game.TYPE_RANGE[game.UNIT_SKELETON] === 1,
    "skeleton warriors must only attack in melee");
  assert(game.TYPE_RANGE[game.UNIT_SKELETON_ARCHER] === 3,
    "only skeleton archers may fire arrows");
  assert(game.skipActiveHero() === 1 && game.skipActiveHero() === 1,
    "both heroes must be skippable in the warlock battle");
  state = game.getState();
  assert(state.unitCount === 6,
    "the warlock must summon one imp at the start of its enemy phase");
  assert(state.eventType[0] === game.EVENT_SUMMON,
    "the imp summon must be the first enemy animation event");

  game.init();
  while (game.getState().phase === game.PHASE_HERO && actions < 100) {
    actions += 1;
    state = game.getState();
    hero = state.selectedUnit;
    if (hero < 0 || !moveOrAttack(state, hero)) {
      game.skipActiveHero();
    }
  }

  state = game.getState();
  assert(state.phase === game.PHASE_WON || state.phase === game.PHASE_LOST,
    "reference strategy must reach a terminal battle state");
  console.log("PASS: move-plus-attack, skip timing, enemy phase, battles, " +
    "and terminal state");
}

run();
