(function () {
  "use strict";

  var game = HexBattle;
  var canvas = document.getElementById("game");
  var ctx = canvas.getContext("2d", { alpha: false });
  var cursorCell = game.cellOf(1, 2);
  var hoverCell = -1;
  var spriteSheet = new Image();
  var terrainSheet = new Image();
  var spritesReady = false;
  var terrainReady = false;
  var ANIM_NONE = 0;
  var ANIM_WALK = 1;
  var ANIM_MELEE = 2;
  var ANIM_RANGED = 3;
  var ANIM_SUMMON = 4;
  var animationKind = ANIM_NONE;
  var animationUnit = -1;
  var animationTarget = -1;
  var animationFromCell = 0;
  var animationToCell = 0;
  var animationStarted = 0;
  var animationDuration = 1;
  var animationNow = 0;
  var animationPreviousSelected = -1;
  var animationBaseCell = new Uint8Array(12);
  var animationBaseAlive = new Uint8Array(12);
  var animationEventType = new Uint8Array(24);
  var animationEventUnit = new Uint8Array(24);
  var animationEventToCell = new Uint8Array(24);
  var animationEventTarget = new Uint8Array(24);
  var animationEventTargetDied = new Uint8Array(24);
  var animationEventCount = 0;
  var animationEventIndex = 0;
  var unitFacing = new Int8Array(12);
  var idleAnimationNow = 0;
  var idleAnimationStep = -1;
  var IDLE_BOB = [0, -1, -2, -1, 0, 1, 0, 0];

  var HEX_RADIUS = 13;
  var GRID_X = 62;
  var GRID_Y = 24;
  var COL_STEP = 27;
  var ROW_STEP = 21;
  var SPRITE_CELL_W = 32;
  var SPRITE_CELL_H = 64;

  unitFacing.fill(-1);
  unitFacing[0] = 1;
  unitFacing[1] = 1;

  spriteSheet.addEventListener("load", function () {
    spritesReady = true;
    render();
  });
  spriteSheet.src = "assets/heroes-sprites-8bit.png";

  terrainSheet.addEventListener("load", function () {
    terrainReady = true;
    render();
  });
  terrainSheet.src = "assets/terrain-8bit.png";

  var COLOR = {
    sky: "#17293a",
    ground: "#365d45",
    groundAlt: "#3d684b",
    grid: "#1b3429",
    treeDark: "#18382d",
    treeLight: "#63a65d",
    hero: "#e6d36a",
    heroDark: "#96743d",
    enemy: "#d95763",
    enemyDark: "#743744",
    white: "#f5f1c7",
    black: "#111827",
    blue: "#6fc3df",
    move: "#87c66b",
    attack: "#ed6973",
    used: "#65717a",
    panel: "rgba(35, 71, 49, 0.82)",
    panelLine: "#a7d58a"
  };

  var MESSAGE = [
    "",
    "SELECT A HERO",
    "CHOOSE MOVE OR TARGET",
    "MOVED - ATTACK OR SKIP",
    "DAMAGE DEALT",
    "ENEMY DEFEATED",
    "BLOCKED",
    "OUT OF RANGE",
    "HERO ALREADY ACTED",
    "YOUR TURN",
    "VICTORY! PRESS R",
    "DEFEAT! PRESS R",
    "WAIT FOR ACTIVE HERO"
  ];

  function centerX(cell) {
    var row = game.cellRow(cell);
    return GRID_X + game.cellCol(cell) * COL_STEP + (row & 1) * 13;
  }

  function centerY(cell) {
    return GRID_Y + game.cellRow(cell) * ROW_STEP;
  }

  function animationProgress() {
    var elapsed;
    if (animationKind === ANIM_NONE) {
      return 1;
    }
    elapsed = animationNow - animationStarted;
    if (elapsed <= 0) {
      return 0;
    }
    if (elapsed >= animationDuration) {
      return 1;
    }
    return elapsed / animationDuration;
  }

  function captureAnimationBase(state) {
    var id;
    for (id = 0; id < state.maxUnits; id += 1) {
      animationBaseCell[id] = state.unitCell[id];
      animationBaseAlive[id] = state.unitAlive[id];
    }
  }

  function beginQueuedAnimation(timestamp) {
    var eventType = animationEventType[animationEventIndex];
    animationUnit = animationEventUnit[animationEventIndex];
    animationTarget = animationEventTarget[animationEventIndex];
    if (animationTarget === 255) {
      animationTarget = -1;
    }
    animationToCell = animationEventToCell[animationEventIndex];
    if (eventType === game.EVENT_SUMMON) {
      animationBaseCell[animationUnit] = animationToCell;
    }
    animationFromCell = animationBaseCell[animationUnit];
    animationKind = eventType === game.EVENT_MOVE ? ANIM_WALK :
      (eventType === game.EVENT_RANGED ? ANIM_RANGED :
        (eventType === game.EVENT_SUMMON ? ANIM_SUMMON : ANIM_MELEE));
    animationDuration = animationKind === ANIM_WALK ? 280 :
      (animationKind === ANIM_RANGED ? 320 :
        (animationKind === ANIM_SUMMON ? 420 : 240));
    animationStarted = timestamp;
    animationNow = timestamp;
    if (centerX(animationToCell) < centerX(animationFromCell)) {
      unitFacing[animationUnit] = -1;
    } else if (centerX(animationToCell) > centerX(animationFromCell)) {
      unitFacing[animationUnit] = 1;
    }
  }

  function queueAnimations(state, previousSelected) {
    var event;
    animationEventCount = state.eventCount;
    animationEventIndex = 0;
    animationPreviousSelected = previousSelected;
    for (event = 0; event < animationEventCount; event += 1) {
      animationEventType[event] = state.eventType[event];
      animationEventUnit[event] = state.eventUnit[event];
      animationEventToCell[event] = state.eventToCell[event];
      animationEventTarget[event] = state.eventTarget[event];
      animationEventTargetDied[event] = state.eventTargetDied[event];
    }
    beginQueuedAnimation(performance.now());
    requestAnimationFrame(advanceAnimation);
  }

  function advanceAnimation(timestamp) {
    animationNow = timestamp;
    if (animationProgress() < 1) {
      render();
      requestAnimationFrame(advanceAnimation);
      return;
    }

    if (animationKind === ANIM_WALK) {
      animationBaseCell[animationUnit] = animationToCell;
    } else if (animationKind === ANIM_SUMMON) {
      animationBaseAlive[animationUnit] = 1;
    }
    if (animationTarget >= 0 &&
        animationEventTargetDied[animationEventIndex]) {
      animationBaseAlive[animationTarget] = 0;
    }

    animationEventIndex += 1;
    if (animationEventIndex < animationEventCount) {
      beginQueuedAnimation(timestamp);
      render();
      requestAnimationFrame(advanceAnimation);
      return;
    }

    animationKind = ANIM_NONE;
    animationUnit = -1;
    animationTarget = -1;
    animationEventCount = 0;
    syncCursorToNextHero(animationPreviousSelected);
    render();
  }

  function performAction(cell) {
    var before;
    var selected;
    var result;
    var after;
    if (animationKind !== ANIM_NONE) {
      return 0;
    }

    before = game.getState();
    selected = before.selectedUnit;
    captureAnimationBase(before);
    result = game.selectOrAct(cell);
    after = game.getState();
    if (result && after.eventCount > 0) {
      queueAnimations(after, selected);
    } else {
      syncCursorToNextHero(selected);
    }
    return result;
  }

  function performSkip() {
    var before;
    var selected;
    var result;
    var after;
    if (animationKind !== ANIM_NONE) {
      return 0;
    }
    before = game.getState();
    selected = before.selectedUnit;
    captureAnimationBase(before);
    result = game.skipActiveHero();
    after = game.getState();
    if (result && after.eventCount > 0) {
      queueAnimations(after, selected);
    } else {
      syncCursorToNextHero(selected);
    }
    return result;
  }

  function hexPath(x, y, inset) {
    var r = HEX_RADIUS - inset;
    ctx.beginPath();
    ctx.moveTo(x - r, y);
    ctx.lineTo(x - (r >> 1), y - 11 + inset);
    ctx.lineTo(x + (r >> 1), y - 11 + inset);
    ctx.lineTo(x + r, y);
    ctx.lineTo(x + (r >> 1), y + 11 - inset);
    ctx.lineTo(x - (r >> 1), y + 11 - inset);
    ctx.closePath();
  }

  function drawPixelText(text, x, y, color, align) {
    ctx.fillStyle = color;
    ctx.font = "bold 8px monospace";
    ctx.textAlign = align || "left";
    ctx.textBaseline = "top";
    ctx.fillText(text, x, y);
  }

  function drawBackground() {
    var x;
    var y;
    ctx.fillStyle = "#42864b";
    ctx.fillRect(0, 0, 320, 200);
    if (terrainReady) {
      for (y = 0; y < 200; y += 32) {
        for (x = 0; x < 320; x += 32) {
          ctx.drawImage(terrainSheet, 0, 0, 32, 32, x, y, 32, 32);
        }
      }
    }
  }

  function isActionCell(cell, state) {
    var selected = state.selectedUnit;
    var occupant;
    if (selected < 0 || state.unitActed[selected]) {
      return 0;
    }
    occupant = game.unitAt(cell);
    if (occupant >= 0 && state.unitTeam[occupant] === game.TEAM_ENEMY &&
        game.distance(state.unitCell[selected], cell) <=
          game.TYPE_RANGE[state.unitType[selected]]) {
      return 2;
    }
    if (state.unitMoveLeft[selected] > 0 &&
        occupant < 0 &&
        state.terrain[cell] === game.TERRAIN_OPEN &&
        game.movementCost(state.unitCell[selected], cell) <=
          state.unitMoveLeft[selected]) {
      return 1;
    }
    return 0;
  }

  function drawBoard(state) {
    var cell;
    var x;
    var y;
    var action;
    for (cell = 0; cell < state.cellCount; cell += 1) {
      x = centerX(cell);
      y = centerY(cell);
      action = isActionCell(cell, state);

      if (action) {
        hexPath(x, y, 0);
        ctx.fillStyle = action === 1 &&
          state.selectedUnit >= 0 &&
          state.unitMoved[state.selectedUnit] ?
            "rgba(7, 28, 14, 0.34)" : "rgba(10, 36, 18, 0.25)";
        ctx.fill();
      }

      if (cell === hoverCell) {
        hexPath(x, y, 0);
        ctx.fillStyle = "rgba(5, 24, 12, 0.20)";
        ctx.fill();
      }

      if (state.terrain[cell] === game.TERRAIN_TREE) {
        drawTree(x, y, cell);
      }
    }
  }

  function drawSprite(frame, x, y, width, height) {
    ctx.drawImage(
      spriteSheet,
      frame * SPRITE_CELL_W, 0, SPRITE_CELL_W, SPRITE_CELL_H,
      x - (width >> 1), y - (height >> 1), width, height
    );
  }

  function drawTree(x, y, cell) {
    if (spritesReady) {
      drawSprite((cell & 1) ? 5 : 4, x, y - 4, 30, 48);
      return;
    }
    ctx.fillStyle = COLOR.treeDark;
    ctx.fillRect(x - 2, y + 1, 4, 8);
    ctx.fillStyle = COLOR.treeLight;
    ctx.fillRect(x - 5, y - 6, 10, 7);
    ctx.fillRect(x - 8, y - 2, 16, 5);
    ctx.fillStyle = "#417c48";
    ctx.fillRect(x + 2, y - 5, 4, 4);
  }

  function drawUnits(state) {
    var id;
    var shouldDraw;
    var progress = animationProgress();
    for (id = 0; id < state.unitCount; id += 1) {
      shouldDraw = animationKind !== ANIM_NONE ?
        animationBaseAlive[id] : state.unitAlive[id];
      if (animationKind === ANIM_SUMMON &&
          id === animationUnit && progress > 0.34) {
        shouldDraw = 1;
      }
      if (shouldDraw) {
        ctx.save();
        if (animationKind === ANIM_SUMMON && id === animationUnit) {
          ctx.globalAlpha = progress < 0.34 ? 0 :
            (progress - 0.34) / 0.66;
        }
        if (id === animationTarget &&
            animationEventTargetDied[animationEventIndex] &&
            progress > 0.58) {
          ctx.globalAlpha = 1 - ((progress - 0.58) / 0.42);
        }
        drawUnit(id, state);
        ctx.restore();
      }
    }
  }

  function drawActionCursor(state) {
    var x;
    var y;
    if (hoverCell < 0 || isActionCell(hoverCell, state) !== 2) {
      return;
    }
    x = centerX(hoverCell);
    y = centerY(hoverCell) - 3;
    ctx.strokeStyle = COLOR.attack;
    ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.moveTo(x - 10, y - 7);
    ctx.lineTo(x - 10, y - 11);
    ctx.lineTo(x - 6, y - 11);
    ctx.moveTo(x + 10, y - 7);
    ctx.lineTo(x + 10, y - 11);
    ctx.lineTo(x + 6, y - 11);
    ctx.moveTo(x - 10, y + 7);
    ctx.lineTo(x - 10, y + 11);
    ctx.lineTo(x - 6, y + 11);
    ctx.moveTo(x + 10, y + 7);
    ctx.lineTo(x + 10, y + 11);
    ctx.lineTo(x + 6, y + 11);
    ctx.stroke();
  }

  function unitDrawPosition(id, state) {
    var cell = animationKind !== ANIM_NONE ?
      animationBaseCell[id] : state.unitCell[id];
    var x = centerX(cell);
    var y = centerY(cell);
    var progress;
    var eased;
    var amount;
    var bobFrame;

    if (animationKind === ANIM_NONE &&
        state.phase === game.PHASE_HERO &&
        id === state.selectedUnit &&
        !state.unitActed[id]) {
      y += IDLE_BOB[((idleAnimationNow / 110) | 0) & 7];
    }

    if (id !== animationUnit || animationKind === ANIM_NONE) {
      return { x: x, y: y };
    }

    progress = animationProgress();
    if (animationKind === ANIM_WALK) {
      eased = progress * progress * (3 - 2 * progress);
      x = centerX(animationFromCell) +
        (centerX(animationToCell) - centerX(animationFromCell)) * eased;
      y = centerY(animationFromCell) +
        (centerY(animationToCell) - centerY(animationFromCell)) * eased;
      bobFrame = (progress * 8) | 0;
      if (bobFrame === 1 || bobFrame === 3 ||
          bobFrame === 5 || bobFrame === 7) {
        y -= 1;
      }
    } else if (animationKind !== ANIM_SUMMON) {
      amount = progress < 0.5 ? progress * 2 : (1 - progress) * 2;
      if (animationKind === ANIM_MELEE) {
        x += (centerX(animationToCell) - x) * amount * 0.28;
        y += (centerY(animationToCell) - y) * amount * 0.28;
      } else {
        x -= unitFacing[id] * amount;
      }
    }
    return { x: x, y: y };
  }

  function drawUnit(id, state) {
    var type = state.unitType[id];
    var team = state.unitTeam[id];
    var position = unitDrawPosition(id, state);
    var x = position.x;
    var y = position.y;
    var main = team === game.TEAM_HERO ? COLOR.hero : COLOR.enemy;
    var dark = team === game.TEAM_HERO ? COLOR.heroDark : COLOR.enemyDark;
    var maxHP = game.TYPE_HP[type];
    var hp;

    if (state.unitActed[id] && id !== animationUnit) {
      main = COLOR.used;
      dark = "#48515a";
    }

    ctx.fillStyle = "rgba(7, 12, 18, 0.45)";
    ctx.fillRect(x - 7, y + 6, 14, 3);

    if (spritesReady) {
      drawUnitSprite(unitSpriteFrame(type), x, y - 5, 28, 46,
        team === game.TEAM_HERO ?
          unitFacing[id] < 0 : unitFacing[id] > 0);
      if (type === game.UNIT_SKELETON_ARCHER) {
        ctx.fillStyle = "#b8c5c7";
        ctx.fillRect(x - 3, y - 16, 7, 6);
        ctx.fillStyle = "#28343b";
        ctx.fillRect(x - 2, y - 14, 2, 2);
        ctx.fillRect(x + 2, y - 14, 2, 2);
      }
      if (state.unitActed[id] && id !== animationUnit) {
        ctx.fillStyle = "rgba(25, 35, 48, 0.5)";
        ctx.fillRect(x - 10, y - 15, 20, 23);
      }
    } else {
      ctx.fillStyle = dark;
      ctx.fillRect(x - 5, y - 4, 10, 11);
      ctx.fillStyle = main;
      ctx.fillRect(x - 4, y - 6, 8, 9);
    }

    ctx.fillStyle = COLOR.black;
    ctx.fillRect(x - 7, y + 10, 14, 2);
    ctx.fillStyle = team === game.TEAM_HERO ? COLOR.blue : COLOR.attack;
    for (hp = 0; hp < state.unitHP[id]; hp += 1) {
      ctx.fillRect(x - 6 + hp * (12 / maxHP), y + 10, 2, 2);
    }

  }

  function drawUnitSprite(frame, x, y, width, height, flip) {
    ctx.save();
    ctx.translate(x, y);
    if (flip) {
      ctx.scale(-1, 1);
    }
    ctx.drawImage(
      spriteSheet,
      frame * SPRITE_CELL_W, 0, SPRITE_CELL_W, SPRITE_CELL_H,
      -(width >> 1), -(height >> 1), width, height
    );
    ctx.restore();
  }

  function unitSpriteFrame(type) {
    if (type === game.UNIT_KNIGHT) {
      return 0;
    }
    if (type === game.UNIT_ARCHER) {
      return 1;
    }
    if (type === game.UNIT_SKELETON_ARCHER) {
      return 1;
    }
    if (type === game.UNIT_SKELETON) {
      return 3;
    }
    return 2;
  }

  function drawAnimationEffects() {
    var progress;
    var fromX;
    var fromY;
    var toX;
    var toY;
    var projectileProgress;
    var x;
    var y;
    if (animationKind === ANIM_SUMMON) {
      progress = animationProgress();
      toX = centerX(animationToCell);
      toY = centerY(animationToCell) - 3;
      ctx.fillStyle = progress < 0.5 ? COLOR.attack : COLOR.white;
      ctx.fillRect(toX - 7, toY - 1, 15, 2);
      ctx.fillRect(toX, toY - 8, 2, 15);
      if (progress > 0.22 && progress < 0.72) {
        ctx.fillRect(toX - 4, toY - 5, 2, 2);
        ctx.fillRect(toX + 4, toY + 4, 2, 2);
      }
      return;
    }
    if (animationKind !== ANIM_MELEE && animationKind !== ANIM_RANGED) {
      return;
    }

    progress = animationProgress();
    fromX = centerX(animationFromCell);
    fromY = centerY(animationFromCell) - 3;
    toX = centerX(animationToCell);
    toY = centerY(animationToCell) - 3;

    if (animationKind === ANIM_RANGED && progress > 0.18) {
      projectileProgress = (progress - 0.18) / 0.58;
      if (projectileProgress > 1) {
        projectileProgress = 1;
      }
      x = fromX + (toX - fromX) * projectileProgress;
      y = fromY + (toY - fromY) * projectileProgress;
      ctx.fillStyle = COLOR.white;
      ctx.fillRect(x - 2, y, 5, 1);
      ctx.fillStyle = COLOR.heroDark;
      ctx.fillRect(x - 3, y - 1, 1, 3);
    }

    if (animationKind === ANIM_MELEE &&
        progress > 0.30 && progress < 0.62) {
      ctx.strokeStyle = COLOR.white;
      ctx.lineWidth = 1;
      ctx.beginPath();
      ctx.moveTo(toX - 4, toY - 5);
      ctx.lineTo(toX + 4, toY + 3);
      ctx.stroke();
    }

    if (progress > 0.64 && progress < 0.86) {
      ctx.fillStyle = "rgba(255, 245, 196, 0.82)";
      ctx.fillRect(toX - 5, toY - 1, 11, 2);
      ctx.fillRect(toX, toY - 6, 2, 11);
    }
  }

  function drawHud(state) {
    var selected = animationKind !== ANIM_NONE ?
      animationUnit : state.selectedUnit;
    var name = "";
    var move = 0;
    var damage = 0;
    var hp = 0;
    var maxHP = 0;

    ctx.fillStyle = COLOR.panel;
    ctx.fillRect(0, 168, 320, 32);
    ctx.fillStyle = COLOR.panelLine;
    ctx.fillRect(0, 168, 320, 1);

    drawPixelText(MESSAGE[state.messageCode], 8, 154,
      state.phase === game.PHASE_LOST ? COLOR.attack : COLOR.white);

    if (selected >= 0) {
      name = unitName(state.unitType[selected]);
      move = state.unitMoveLeft[selected];
      damage = game.TYPE_DAMAGE[state.unitType[selected]];
      hp = state.unitHP[selected];
      maxHP = game.TYPE_HP[state.unitType[selected]];
    }

    drawPixelText("SKIP", 7, 179, COLOR.white);
    drawPixelText("STEP " + move, 57, 179, COLOR.move);
    drawPixelText("SWORD " + damage, 120, 179, COLOR.white);
    drawPixelText("HEART " + hp + "/" + maxHP, 197, 179, COLOR.attack);
    drawPixelText("FLAG", 312, 179, COLOR.white, "right");
    drawPixelText("B" + state.battleNumber + " T" +
      state.turnNumber + " " +
      (selected >= 0 && state.unitMoved[selected] ?
        (state.unitMoveLeft[selected] ? "M1/ATK " : "ATK ") : "") + name,
      312, 154,
      COLOR.hero, "right");
  }

  function countLiving(state, team) {
    var total = 0;
    var i;
    for (i = 0; i < state.unitCount; i += 1) {
      if (state.unitAlive[i] && state.unitTeam[i] === team) {
        total += 1;
      }
    }
    return total;
  }

  function unitName(type) {
    return [
      "KNIGHT", "ARCHER", "MINIBEAST", "SKELETON",
      "OGRE", "BAT", "WARLOCK", "IMP", "SKEL ARCHER"
    ][type];
  }

  function render() {
    var state = game.getState();
    ctx.imageSmoothingEnabled = false;
    canvas.style.cursor = animationKind === ANIM_NONE &&
      hoverCell >= 0 && isActionCell(hoverCell, state) === 2 ?
        "crosshair" : "default";
    drawBackground();
    drawBoard(state);
    drawUnits(state);
    drawActionCursor(state);
    drawAnimationEffects();
    drawHud(state);
  }

  function advanceIdleAnimation(timestamp) {
    var step = ((timestamp / 110) | 0) & 7;
    idleAnimationNow = timestamp;
    if (animationKind === ANIM_NONE && step !== idleAnimationStep) {
      idleAnimationStep = step;
      render();
    }
    requestAnimationFrame(advanceIdleAnimation);
  }

  function closestCell(px, py) {
    var best = -1;
    var bestDistance = 100000;
    var cell;
    var dx;
    var dy;
    var d;
    for (cell = 0; cell < game.CELL_COUNT; cell += 1) {
      dx = px - centerX(cell);
      dy = py - centerY(cell);
      d = dx * dx + dy * dy;
      if (d < bestDistance) {
        bestDistance = d;
        best = cell;
      }
    }
    return bestDistance <= 225 ? best : -1;
  }

  function eventPosition(event) {
    var rect = canvas.getBoundingClientRect();
    return {
      x: ((event.clientX - rect.left) * 320 / rect.width) | 0,
      y: ((event.clientY - rect.top) * 200 / rect.height) | 0
    };
  }

  function moveCursor(dx, dy) {
    var col = game.cellCol(cursorCell) + dx;
    var row = game.cellRow(cursorCell) + dy;
    if (animationKind !== ANIM_NONE) {
      return;
    }
    if (col < 0) { col = 0; }
    if (col >= game.COLS) { col = game.COLS - 1; }
    if (row < 0) { row = 0; }
    if (row >= game.ROWS) { row = game.ROWS - 1; }
    cursorCell = game.cellOf(col, row);
    hoverCell = cursorCell;
    render();
  }

  function syncCursorToNextHero(previousSelected) {
    var state = game.getState();
    if (state.phase === game.PHASE_HERO &&
        state.selectedUnit >= 0 &&
        state.selectedUnit !== previousSelected) {
      cursorCell = state.unitCell[state.selectedUnit];
    }
  }

  canvas.addEventListener("pointerdown", function (event) {
    var point = eventPosition(event);
    var cell;
    canvas.focus();

    if (point.x < 48 && point.y >= 168) {
      performSkip();
      render();
      return;
    }

    cell = closestCell(point.x, point.y);
    if (cell >= 0 && animationKind === ANIM_NONE) {
      cursorCell = cell;
      hoverCell = cell;
      performAction(cell);
      render();
    }
  });

  canvas.addEventListener("pointermove", function (event) {
    var point;
    var cell;
    if (animationKind !== ANIM_NONE) {
      return;
    }
    point = eventPosition(event);
    cell = closestCell(point.x, point.y);
    canvas.style.cursor = cell >= 0 &&
      isActionCell(cell, game.getState()) === 2 ? "crosshair" : "default";
    if (cell !== hoverCell) {
      hoverCell = cell;
      if (cell >= 0) {
        cursorCell = cell;
      }
      render();
    }
  });

  canvas.addEventListener("pointerleave", function () {
    canvas.style.cursor = "default";
    if (hoverCell !== -1) {
      hoverCell = -1;
      render();
    }
  });

  canvas.addEventListener("keydown", function (event) {
    var handled = true;
    if (event.key === "ArrowLeft") {
      moveCursor(-1, 0);
    } else if (event.key === "ArrowRight") {
      moveCursor(1, 0);
    } else if (event.key === "ArrowUp") {
      moveCursor(0, -1);
    } else if (event.key === "ArrowDown") {
      moveCursor(0, 1);
    } else if (event.key === "Enter") {
      performAction(cursorCell);
      render();
    } else if (event.key === " " ||
        event.key === "e" || event.key === "E") {
      if (animationKind === ANIM_NONE) {
        performSkip();
        render();
      }
    } else if (event.key === "r" || event.key === "R") {
      restart();
    } else if (event.key === "1") {
      changeBattle(-1);
    } else if (event.key === "2") {
      changeBattle(1);
    } else {
      handled = false;
    }
    if (handled) {
      event.preventDefault();
    }
  });

  document.getElementById("end-turn").addEventListener("click", function () {
    if (animationKind === ANIM_NONE) {
      performSkip();
      render();
    }
    canvas.focus();
  });

  document.getElementById("restart").addEventListener("click", restart);
  document.getElementById("previous-battle").addEventListener(
    "click", function () { changeBattle(-1); }
  );
  document.getElementById("next-battle").addEventListener(
    "click", function () { changeBattle(1); }
  );

  function changeBattle(direction) {
    var state;
    var next;
    if (animationKind !== ANIM_NONE) {
      return;
    }
    state = game.getState();
    next = state.battleNumber + direction;
    if (next < 1) {
      next = state.battleCount;
    } else if (next > state.battleCount) {
      next = 1;
    }
    game.init(next);
    hoverCell = -1;
    cursorCell = game.getState().unitCell[0];
    render();
    canvas.focus();
  }

  function restart() {
    animationKind = ANIM_NONE;
    animationUnit = -1;
    animationTarget = -1;
    animationEventCount = 0;
    animationEventIndex = 0;
    hoverCell = -1;
    unitFacing.fill(-1);
    unitFacing[0] = 1;
    unitFacing[1] = 1;
    game.init();
    cursorCell = game.cellOf(1, 2);
    render();
    canvas.focus();
  }

  game.init();
  render();
  requestAnimationFrame(advanceIdleAnimation);
}());
