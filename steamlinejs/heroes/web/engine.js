/*
 * Portable battle rules.
 *
 * This file intentionally has no DOM, Canvas, animation, promises, classes,
 * maps, or floating-point game logic. State is stored in fixed-size typed
 * arrays and all public actions use integer cell/unit IDs. That maps closely
 * to byte arrays and subroutines in a future 6502 implementation.
 */
(function (root) {
  "use strict";

  var COLS = 7;
  var ROWS = 6;
  var CELL_COUNT = COLS * ROWS;
  var MAX_UNITS = 12;
  var MAX_EVENTS = 24;
  var BATTLE_COUNT = 4;

  var TEAM_HERO = 0;
  var TEAM_ENEMY = 1;

  var UNIT_KNIGHT = 0;
  var UNIT_ARCHER = 1;
  var UNIT_MINIBEAST = 2;
  var UNIT_SKELETON = 3;
  var UNIT_OGRE = 4;
  var UNIT_BAT = 5;
  var UNIT_WARLOCK = 6;
  var UNIT_IMP = 7;
  var UNIT_SKELETON_ARCHER = 8;

  var TERRAIN_OPEN = 0;
  var TERRAIN_TREE = 1;

  var PHASE_HERO = 0;
  var PHASE_ENEMY = 1;
  var PHASE_WON = 2;
  var PHASE_LOST = 3;

  var EVENT_MOVE = 1;
  var EVENT_MELEE = 2;
  var EVENT_RANGED = 3;
  var EVENT_SUMMON = 4;

  /*
   * Enemy names come from the original bundle. Exact numeric stats were not
   * recoverable, so these compact values preserve each unit's visible role.
   */
  var TYPE_HP = new Uint8Array([5, 3, 3, 3, 6, 2, 7, 2, 2]);
  var TYPE_DAMAGE = new Uint8Array([2, 2, 1, 1, 3, 1, 2, 1, 1]);
  var TYPE_RANGE = new Uint8Array([1, 3, 1, 1, 1, 1, 3, 1, 3]);
  var TYPE_MOVE = new Uint8Array([2, 2, 2, 1, 1, 2, 1, 2, 1]);

  var terrain = new Uint8Array(CELL_COUNT);
  var unitType = new Uint8Array(MAX_UNITS);
  var unitTeam = new Uint8Array(MAX_UNITS);
  var unitCell = new Uint8Array(MAX_UNITS);
  var unitHP = new Uint8Array(MAX_UNITS);
  var unitActed = new Uint8Array(MAX_UNITS);
  var unitMoved = new Uint8Array(MAX_UNITS);
  var unitMoveLeft = new Uint8Array(MAX_UNITS);
  var unitAlive = new Uint8Array(MAX_UNITS);
  var moveDistance = new Uint8Array(CELL_COUNT);
  var moveQueue = new Uint8Array(CELL_COUNT);
  var eventType = new Uint8Array(MAX_EVENTS);
  var eventUnit = new Uint8Array(MAX_EVENTS);
  var eventFromCell = new Uint8Array(MAX_EVENTS);
  var eventToCell = new Uint8Array(MAX_EVENTS);
  var eventTarget = new Uint8Array(MAX_EVENTS);
  var eventTargetDied = new Uint8Array(MAX_EVENTS);

  var unitCount = 0;
  var phase = PHASE_HERO;
  var selectedUnit = -1;
  var turnNumber = 1;
  var messageCode = 0;
  var messageValue = 0;
  var eventCount = 0;
  var battleNumber = 1;

  /* Odd-row offset neighbours, clockwise from east. */
  var EVEN_DX = new Int8Array([1, 0, -1, -1, -1, 0]);
  var ODD_DX = new Int8Array([1, 1, 0, -1, 0, 1]);
  var DY = new Int8Array([0, 1, 1, 0, -1, -1]);

  function cellOf(col, row) {
    if (col < 0 || col >= COLS || row < 0 || row >= ROWS) {
      return -1;
    }
    return row * COLS + col;
  }

  function cellCol(cell) {
    return cell % COLS;
  }

  function cellRow(cell) {
    return (cell / COLS) | 0;
  }

  function neighbour(cell, direction) {
    var row = cellRow(cell);
    var col = cellCol(cell);
    var dx = (row & 1) ? ODD_DX[direction] : EVEN_DX[direction];
    return cellOf(col + dx, row + DY[direction]);
  }

  function distance(a, b) {
    var ar = cellRow(a);
    var br = cellRow(b);
    var aq = cellCol(a) - ((ar - (ar & 1)) >> 1);
    var bq = cellCol(b) - ((br - (br & 1)) >> 1);
    var ax = aq;
    var az = ar;
    var ay = -ax - az;
    var bx = bq;
    var bz = br;
    var by = -bx - bz;
    var dx = abs(ax - bx);
    var dy = abs(ay - by);
    var dz = abs(az - bz);
    return max3(dx, dy, dz);
  }

  function abs(value) {
    return value < 0 ? -value : value;
  }

  function max3(a, b, c) {
    var result = a > b ? a : b;
    return result > c ? result : c;
  }

  function unitAt(cell) {
    var i;
    for (i = 0; i < unitCount; i += 1) {
      if (unitAlive[i] && unitCell[i] === cell) {
        return i;
      }
    }
    return -1;
  }

  function isOpen(cell) {
    return cell >= 0 &&
      terrain[cell] === TERRAIN_OPEN &&
      unitAt(cell) < 0;
  }

  function clearEvents() {
    eventCount = 0;
  }

  function pushEvent(type, unit, fromCell, toCell, target, targetDied) {
    if (eventCount >= MAX_EVENTS) {
      return;
    }
    eventType[eventCount] = type;
    eventUnit[eventCount] = unit;
    eventFromCell[eventCount] = fromCell;
    eventToCell[eventCount] = toCell;
    eventTarget[eventCount] = target < 0 ? 255 : target;
    eventTargetDied[eventCount] = targetDied ? 1 : 0;
    eventCount += 1;
  }

  /*
   * Bounded breadth-first search using reusable byte arrays. A return value of
   * 255 means that the target is blocked or cannot be reached in two steps.
   */
  function movementCost(startCell, targetCell) {
    var head = 0;
    var tail = 0;
    var current;
    var next;
    var direction;

    if (startCell === targetCell) {
      return 0;
    }
    if (!isOpen(targetCell)) {
      return 255;
    }

    moveDistance.fill(255);
    moveDistance[startCell] = 0;
    moveQueue[tail] = startCell;
    tail += 1;

    while (head < tail) {
      current = moveQueue[head];
      head += 1;
      if (moveDistance[current] >= 2) {
        continue;
      }
      for (direction = 0; direction < 6; direction += 1) {
        next = neighbour(current, direction);
        if (next >= 0 &&
            moveDistance[next] === 255 &&
            (next === targetCell || isOpen(next))) {
          moveDistance[next] = moveDistance[current] + 1;
          if (next === targetCell) {
            return moveDistance[next];
          }
          moveQueue[tail] = next;
          tail += 1;
        }
      }
    }
    return 255;
  }

  function addUnit(type, team, cell) {
    var id = unitCount;
    if (id >= MAX_UNITS) {
      return -1;
    }
    unitType[id] = type;
    unitTeam[id] = team;
    unitCell[id] = cell;
    unitHP[id] = TYPE_HP[type];
    unitActed[id] = 0;
    unitMoved[id] = 0;
    unitMoveLeft[id] = TYPE_MOVE[type];
    unitAlive[id] = 1;
    unitCount += 1;
    return id;
  }

  function init(requestedBattle) {
    var i;
    if (requestedBattle >= 1 && requestedBattle <= BATTLE_COUNT) {
      battleNumber = requestedBattle;
    }
    terrain.fill(TERRAIN_OPEN);
    unitType.fill(0);
    unitTeam.fill(0);
    unitCell.fill(0);
    unitHP.fill(0);
    unitActed.fill(0);
    unitMoved.fill(0);
    unitMoveLeft.fill(0);
    unitAlive.fill(0);

    unitCount = 0;
    addUnit(UNIT_KNIGHT, TEAM_HERO, cellOf(1, 2));
    addUnit(UNIT_ARCHER, TEAM_HERO, cellOf(0, 4));

    if (battleNumber === 1) {
      terrain[cellOf(3, 1)] = TERRAIN_TREE;
      terrain[cellOf(2, 3)] = TERRAIN_TREE;
      terrain[cellOf(5, 4)] = TERRAIN_TREE;
      addUnit(UNIT_MINIBEAST, TEAM_ENEMY, cellOf(5, 1));
      addUnit(UNIT_MINIBEAST, TEAM_ENEMY, cellOf(6, 3));
      addUnit(UNIT_OGRE, TEAM_ENEMY, cellOf(4, 4));
    } else if (battleNumber === 2) {
      terrain[cellOf(3, 1)] = TERRAIN_TREE;
      terrain[cellOf(3, 4)] = TERRAIN_TREE;
      addUnit(UNIT_SKELETON, TEAM_ENEMY, cellOf(5, 0));
      addUnit(UNIT_SKELETON_ARCHER, TEAM_ENEMY, cellOf(6, 2));
      addUnit(UNIT_SKELETON_ARCHER, TEAM_ENEMY, cellOf(5, 5));
    } else if (battleNumber === 3) {
      terrain[cellOf(3, 0)] = TERRAIN_TREE;
      terrain[cellOf(2, 3)] = TERRAIN_TREE;
      terrain[cellOf(4, 4)] = TERRAIN_TREE;
      addUnit(UNIT_BAT, TEAM_ENEMY, cellOf(5, 0));
      addUnit(UNIT_BAT, TEAM_ENEMY, cellOf(6, 3));
      addUnit(UNIT_OGRE, TEAM_ENEMY, cellOf(5, 5));
      addUnit(UNIT_MINIBEAST, TEAM_ENEMY, cellOf(4, 2));
    } else {
      terrain[cellOf(3, 1)] = TERRAIN_TREE;
      terrain[cellOf(3, 4)] = TERRAIN_TREE;
      addUnit(UNIT_SKELETON_ARCHER, TEAM_ENEMY, cellOf(5, 0));
      addUnit(UNIT_WARLOCK, TEAM_ENEMY, cellOf(6, 2));
      addUnit(UNIT_SKELETON_ARCHER, TEAM_ENEMY, cellOf(5, 5));
    }

    phase = PHASE_HERO;
    selectedUnit = 0;
    turnNumber = 1;
    messageCode = 2; /* First hero selected automatically. */
    messageValue = 0;
    clearEvents();
  }

  function canUnitAct(id) {
    return id >= 0 &&
      id < unitCount &&
      unitAlive[id] &&
      unitTeam[id] === TEAM_HERO &&
      !unitActed[id] &&
      phase === PHASE_HERO;
  }

  function attack(attacker, defender) {
    var damage = TYPE_DAMAGE[unitType[attacker]];
    var defenderDied = unitHP[defender] <= damage;
    if (unitHP[defender] <= damage) {
      unitHP[defender] = 0;
      unitAlive[defender] = 0;
      messageCode = 5; /* Unit defeated. */
      messageValue = defender;
    } else {
      unitHP[defender] -= damage;
      messageCode = 4; /* Damage dealt. */
      messageValue = damage;
    }
    pushEvent(
      TYPE_RANGE[unitType[attacker]] > 1 ? EVENT_RANGED : EVENT_MELEE,
      attacker,
      unitCell[attacker],
      unitCell[defender],
      defender,
      defenderDied
    );
    unitActed[attacker] = 1;
    checkResult();
    if (phase === PHASE_HERO) {
      advanceHeroSelection(attacker + 1);
    } else {
      selectedUnit = -1;
    }
  }

  function tryPlayerAction(targetCell) {
    var targetUnit;
    var range;
    if (!canUnitAct(selectedUnit)) {
      return 0;
    }

    targetUnit = unitAt(targetCell);
    if (targetUnit >= 0 && unitTeam[targetUnit] === TEAM_ENEMY) {
      range = TYPE_RANGE[unitType[selectedUnit]];
      if (distance(unitCell[selectedUnit], targetCell) <= range) {
        attack(selectedUnit, targetUnit);
        return 1;
      }
      messageCode = 7; /* Out of range. */
      return 0;
    }

    if (unitMoveLeft[selectedUnit] > 0 &&
        isOpen(targetCell) &&
        movementCost(unitCell[selectedUnit], targetCell) <=
          unitMoveLeft[selectedUnit]) {
      range = movementCost(unitCell[selectedUnit], targetCell);
      pushEvent(EVENT_MOVE, selectedUnit, unitCell[selectedUnit],
        targetCell, -1, 0);
      unitCell[selectedUnit] = targetCell;
      unitMoved[selectedUnit] = 1;
      unitMoveLeft[selectedUnit] -= range;
      messageCode = 3; /* Moved; attack or skip. */
      messageValue = 0;
      if (unitMoveLeft[selectedUnit] === 0) {
        targetUnit = selectedUnit;
        unitActed[selectedUnit] = 1;
        advanceHeroSelection(targetUnit + 1);
      }
      return 1;
    }

    messageCode = 6; /* Invalid destination. */
    return 0;
  }

  function selectOrAct(cell) {
    var id;
    clearEvents();
    if (phase !== PHASE_HERO || cell < 0 || cell >= CELL_COUNT) {
      return 0;
    }

    id = unitAt(cell);
    if (id >= 0 && unitTeam[id] === TEAM_HERO) {
      if (id === selectedUnit) {
        messageCode = 2; /* Active hero confirmed. */
      } else {
        messageCode = 12; /* Wait for this hero's turn. */
      }
      messageValue = id;
      return 1;
    }

    if (selectedUnit >= 0) {
      return tryPlayerAction(cell);
    }
    messageCode = 1;
    return 0;
  }

  function advanceHeroSelection(startId) {
    var id;
    if (phase !== PHASE_HERO) {
      return;
    }
    for (id = startId; id < unitCount; id += 1) {
      if (unitAlive[id] &&
          unitTeam[id] === TEAM_HERO &&
          !unitActed[id]) {
        selectedUnit = id;
        messageCode = 2;
        messageValue = id;
        return;
      }
    }
    selectedUnit = -1;
    endTurn();
  }

  function skipActiveHero() {
    var nextId;
    clearEvents();
    if (!canUnitAct(selectedUnit)) {
      return 0;
    }
    nextId = selectedUnit + 1;
    unitActed[selectedUnit] = 1;
    advanceHeroSelection(nextId);
    return 1;
  }

  function closestLivingUnit(fromCell, team) {
    var best = -1;
    var bestDistance = 127;
    var i;
    var d;
    for (i = 0; i < unitCount; i += 1) {
      if (unitAlive[i] && unitTeam[i] === team) {
        d = distance(fromCell, unitCell[i]);
        if (d < bestDistance) {
          bestDistance = d;
          best = i;
        }
      }
    }
    return best;
  }

  function enemyAct(id) {
    var target = closestLivingUnit(unitCell[id], TEAM_HERO);
    var bestCell = -1;
    var bestDistance = 127;
    var direction;
    var step;
    var startCell = unitCell[id];
    var next;
    var d;

    if (target < 0) {
      return;
    }

    if (distance(unitCell[id], unitCell[target]) <=
        TYPE_RANGE[unitType[id]]) {
      attack(id, target);
      return;
    }

    for (step = 0; step < TYPE_MOVE[unitType[id]]; step += 1) {
      bestCell = -1;
      bestDistance = distance(unitCell[id], unitCell[target]);
      for (direction = 0; direction < 6; direction += 1) {
        next = neighbour(unitCell[id], direction);
        if (isOpen(next)) {
          d = distance(next, unitCell[target]);
          if (d < bestDistance) {
            bestDistance = d;
            bestCell = next;
          }
        }
      }
      if (bestCell < 0) {
        break;
      }
      unitCell[id] = bestCell;
      if (bestDistance <= TYPE_RANGE[unitType[id]]) {
        break;
      }
    }

    if (unitCell[id] !== startCell) {
      pushEvent(EVENT_MOVE, id, startCell, unitCell[id], -1, 0);
    }
    unitActed[id] = 1;
  }

  function summonWarlockImp() {
    var id;
    var direction;
    var cell;
    var imp;
    for (id = 0; id < unitCount; id += 1) {
      if (unitAlive[id] && unitType[id] === UNIT_WARLOCK) {
        for (direction = 0; direction < 6; direction += 1) {
          cell = neighbour(unitCell[id], direction);
          if (isOpen(cell)) {
            imp = addUnit(UNIT_IMP, TEAM_ENEMY, cell);
            if (imp >= 0) {
              pushEvent(EVENT_SUMMON, imp, cell, cell, -1, 0);
            }
            return;
          }
        }
      }
    }
  }

  function endTurn() {
    var i;
    if (phase !== PHASE_HERO) {
      return 0;
    }

    selectedUnit = -1;
    phase = PHASE_ENEMY;
    if (battleNumber === BATTLE_COUNT) {
      summonWarlockImp();
    }
    for (i = 0; i < unitCount && phase === PHASE_ENEMY; i += 1) {
      if (unitAlive[i] && unitTeam[i] === TEAM_ENEMY) {
        enemyAct(i);
      }
    }

    checkResult();
    if (phase === PHASE_ENEMY) {
      for (i = 0; i < unitCount; i += 1) {
        unitActed[i] = 0;
        unitMoved[i] = 0;
        unitMoveLeft[i] = TYPE_MOVE[unitType[i]];
      }
      turnNumber += 1;
      phase = PHASE_HERO;
      advanceHeroSelection(0);
      messageCode = 9; /* New turn. */
      messageValue = turnNumber;
    }
    return 1;
  }

  function checkResult() {
    var heroCount = 0;
    var enemyCount = 0;
    var i;
    for (i = 0; i < unitCount; i += 1) {
      if (unitAlive[i]) {
        if (unitTeam[i] === TEAM_HERO) {
          heroCount += 1;
        } else {
          enemyCount += 1;
        }
      }
    }
    if (enemyCount === 0) {
      phase = PHASE_WON;
      selectedUnit = -1;
      messageCode = 10;
    } else if (heroCount === 0) {
      phase = PHASE_LOST;
      selectedUnit = -1;
      messageCode = 11;
    }
  }

  function getState() {
    return {
      cols: COLS,
      rows: ROWS,
      cellCount: CELL_COUNT,
      maxUnits: MAX_UNITS,
      unitCount: unitCount,
      phase: phase,
      selectedUnit: selectedUnit,
      turnNumber: turnNumber,
      messageCode: messageCode,
      messageValue: messageValue,
      eventCount: eventCount,
      eventType: eventType,
      eventUnit: eventUnit,
      eventFromCell: eventFromCell,
      eventToCell: eventToCell,
      eventTarget: eventTarget,
      eventTargetDied: eventTargetDied,
      battleNumber: battleNumber,
      battleCount: BATTLE_COUNT,
      terrain: terrain,
      unitType: unitType,
      unitTeam: unitTeam,
      unitCell: unitCell,
      unitHP: unitHP,
      unitActed: unitActed,
      unitMoved: unitMoved,
      unitMoveLeft: unitMoveLeft,
      unitAlive: unitAlive
    };
  }

  var api = {
    COLS: COLS,
    ROWS: ROWS,
    CELL_COUNT: CELL_COUNT,
    MAX_EVENTS: MAX_EVENTS,
    TEAM_HERO: TEAM_HERO,
    TEAM_ENEMY: TEAM_ENEMY,
    UNIT_KNIGHT: UNIT_KNIGHT,
    UNIT_ARCHER: UNIT_ARCHER,
    UNIT_GOBLIN: UNIT_MINIBEAST,
    UNIT_BRUTE: UNIT_OGRE,
    UNIT_MINIBEAST: UNIT_MINIBEAST,
    UNIT_SKELETON: UNIT_SKELETON,
    UNIT_OGRE: UNIT_OGRE,
    UNIT_BAT: UNIT_BAT,
    UNIT_WARLOCK: UNIT_WARLOCK,
    UNIT_IMP: UNIT_IMP,
    UNIT_SKELETON_ARCHER: UNIT_SKELETON_ARCHER,
    TERRAIN_OPEN: TERRAIN_OPEN,
    TERRAIN_TREE: TERRAIN_TREE,
    PHASE_HERO: PHASE_HERO,
    PHASE_ENEMY: PHASE_ENEMY,
    PHASE_WON: PHASE_WON,
    PHASE_LOST: PHASE_LOST,
    EVENT_MOVE: EVENT_MOVE,
    EVENT_MELEE: EVENT_MELEE,
    EVENT_RANGED: EVENT_RANGED,
    EVENT_SUMMON: EVENT_SUMMON,
    BATTLE_COUNT: BATTLE_COUNT,
    TYPE_HP: TYPE_HP,
    TYPE_DAMAGE: TYPE_DAMAGE,
    TYPE_RANGE: TYPE_RANGE,
    TYPE_MOVE: TYPE_MOVE,
    init: init,
    getState: getState,
    cellOf: cellOf,
    cellCol: cellCol,
    cellRow: cellRow,
    neighbour: neighbour,
    distance: distance,
    movementCost: movementCost,
    unitAt: unitAt,
    selectOrAct: selectOrAct,
    skipActiveHero: skipActiveHero,
    endTurn: endTurn
  };

  root.HexBattle = api;
  if (typeof module !== "undefined" && module.exports) {
    module.exports = api;
  }
}(typeof globalThis !== "undefined" ? globalThis : this));
