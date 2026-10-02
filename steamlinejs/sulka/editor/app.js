(function () {
  "use strict";

  const Format = window.SulkaFormat;
  const originals = Format.cloneLevels(window.SULKA_VBXE_LEVELS);
  const CELL = 30;
  const STORAGE_KEY = "sulka-vbxe-editor-v2";
  const STORAGE_REVISION_KEY = `${STORAGE_KEY}-built-in-revision`;
  const BUILT_IN_REVISION = Format.levelsSignature(originals);
  const tiles = [
    { char: ".", name: "Erase", color: "#687385", key: "0" },
    { char: "#", name: "Wall", color: "#b7c0cd", key: "1" },
    { char: "P", name: "Player", color: "#ff6b35", key: "2" },
    { char: "K", name: "Key", color: "#ffd25f", key: "3" },
    { char: "D", name: "Door", color: "#c184ff", key: "4" },
    { char: "d", name: "Door ↑", color: "#c184ff", key: "5" },
    { char: "N", name: "Nest", color: "#e8ba78", key: "6" },
    { char: "^", name: "Spikes ↑ ×2", color: "#ff6673", key: "7" },
    { char: "v", name: "Spikes ↓ ×2", color: "#ff6673", key: "8" },
    { char: ">", name: "Spike →", color: "#ff6673", key: "9" },
    { char: "<", name: "Spike ←", color: "#ff6673", key: "-" },
    { char: "s", name: "Spikes decor ×2", color: "#cf7a83", key: "S" },
    { char: "=", name: "Gravity line", color: "#75e8df", key: "=" },
    { char: "F", name: "Fly-spike", color: "#47d9d2", key: "F" }
  ];

  const canvas = document.querySelector("#map");
  const ctx = canvas.getContext("2d");
  const level06Missile = new Image();
  level06Missile.addEventListener("load", () => { if (current === 5) renderCanvas(); });
  level06Missile.src = "sojka-level06-missile-vbxe.png";
  const ui = Object.fromEntries([
    "level-list", "level-kicker", "level-title", "level-note", "palette",
    "selected-tool-name", "selected-tool-char", "cursor-position", "fly-editor",
    "fly-fields", "validation-badge", "validation-list", "undo", "redo",
    "reset-level", "reset-all", "save-state", "import-button", "file-input",
    "export-json", "export-asm", "toast"
  ].map((id) => [id, document.getElementById(id)]));

  let levels = loadSavedLevels();
  let current = 0;
  let selected = "#";
  let drawing = false;
  let strokeSaved = false;
  let lastCell = "";
  let undoStack = [];
  let redoStack = [];
  let toastTimer;

  function loadSavedLevels() {
    try {
      const saved = localStorage.getItem(STORAGE_KEY);
      const savedRevision = localStorage.getItem(STORAGE_REVISION_KEY);
      if (!saved || savedRevision !== BUILT_IN_REVISION) {
        localStorage.removeItem(STORAGE_KEY);
        localStorage.setItem(STORAGE_REVISION_KEY, BUILT_IN_REVISION);
        return Format.cloneLevels(originals);
      }
      const parsed = Format.parseJson(saved);
      if (Format.validateLevels(parsed).errors.length) throw new Error("Invalid saved maps");
      return parsed;
    } catch (error) {
      console.warn("Ignoring incompatible saved Sójka levels:", error);
      return Format.cloneLevels(originals);
    }
  }

  function save() {
    localStorage.setItem(STORAGE_KEY, Format.exportJson(levels));
    localStorage.setItem(STORAGE_REVISION_KEY, BUILT_IN_REVISION);
    ui["save-state"].textContent = "Saved locally";
  }

  function showToast(message) {
    clearTimeout(toastTimer);
    ui.toast.textContent = message;
    ui.toast.classList.add("visible");
    toastTimer = setTimeout(() => ui.toast.classList.remove("visible"), 2200);
  }

  function sameLevel(a, b) {
    return JSON.stringify(a) === JSON.stringify(b);
  }

  function snapshot() {
    return { index: current, level: Format.cloneLevels([levels[current]])[0] };
  }

  function pushUndo() {
    undoStack.push(snapshot());
    if (undoStack.length > 100) undoStack.shift();
    redoStack = [];
  }

  function restoreFromStack(from, to) {
    const entry = from.pop();
    if (!entry) return;
    to.push(snapshot());
    current = entry.index;
    levels[current] = entry.level;
    save();
    renderAll();
  }

  function setCurrent(index) {
    current = Math.max(0, Math.min(Format.LEVEL_COUNT - 1, index));
    renderAll();
  }

  function renderLevelList() {
    ui["level-list"].replaceChildren(...levels.map((level, index) => {
      const button = document.createElement("button");
      button.className = `level-button${index === current ? " active" : ""}${index === 12 ? " skipped" : ""}`;
      button.type = "button";
      button.title = index === 12 ? "Automatic transition slot" : `Open level ${index + 1}`;
      button.innerHTML = `<span class="level-number">${String(index + 1).padStart(2, "0")}</span><span class="level-name"></span><span class="level-status${sameLevel(level, originals[index]) ? "" : " changed"}"></span>`;
      button.querySelector(".level-name").textContent = level.name;
      button.addEventListener("click", () => setCurrent(index));
      return button;
    }));
  }

  function renderPalette() {
    ui.palette.replaceChildren(...tiles.map((tile) => {
      const button = document.createElement("button");
      button.type = "button";
      button.className = `palette-button${tile.char === selected ? " active" : ""}`;
      button.title = `${tile.name} (${tile.key})`;
      button.style.setProperty("--tile-color", tile.color);
      button.innerHTML = `<span class="tile-icon"></span><span class="tile-label"></span>`;
      button.querySelector(".tile-icon").textContent = tile.char === "." ? "×" : tile.char;
      button.querySelector(".tile-label").textContent = tile.name;
      button.addEventListener("click", () => selectTool(tile.char));
      return button;
    }));
  }

  function selectTool(char) {
    selected = char;
    const tile = tiles.find((entry) => entry.char === selected);
    ui["selected-tool-name"].textContent = tile.name;
    ui["selected-tool-char"].textContent = tile.char === "." ? "×" : tile.char;
    renderPalette();
  }

  function renderRulers() {
    const top = document.querySelector(".top-ruler");
    const left = document.querySelector(".left-ruler");
    top.replaceChildren(...Array.from({ length: Format.WIDTH }, (_, index) => {
      const span = document.createElement("span");
      span.textContent = index % 2 === 0 ? index : "";
      return span;
    }));
    left.replaceChildren(...Array.from({ length: Format.HEIGHT }, (_, index) => {
      const span = document.createElement("span");
      span.textContent = index;
      return span;
    }));
  }

  function triangle(x1, y1, x2, y2, x3, y3, color) {
    ctx.fillStyle = color;
    ctx.beginPath();
    ctx.moveTo(x1, y1); ctx.lineTo(x2, y2); ctx.lineTo(x3, y3); ctx.closePath(); ctx.fill();
  }

  function drawTile(char, x, y) {
    const left = x * CELL;
    const top = y * CELL;
    const pad = 4;
    if (char === ".") return;
    if (char === "#") {
      ctx.fillStyle = "#697586"; ctx.fillRect(left + 1, top + 1, CELL - 2, CELL - 2);
      ctx.fillStyle = "#929cab"; ctx.fillRect(left + 3, top + 3, CELL - 6, 4);
      ctx.fillStyle = "#4c5665"; ctx.fillRect(left + 3, top + CELL - 7, CELL - 6, 4);
    } else if (char === "P") {
      ctx.fillStyle = "#ff6b35"; ctx.fillRect(left + 7, top + 9, 16, 13); ctx.fillRect(left + 11, top + 6, 9, 18);
      ctx.fillStyle = "#ffb18f"; ctx.fillRect(left + 10, top + 9, 9, 4);
      ctx.fillStyle = "#11151d"; ctx.fillRect(left + 17, top + 10, 3, 3);
      triangle(left + 23, top + 13, left + 28, top + 16, left + 23, top + 18, "#ffd25f");
    } else if (char === "K") {
      ctx.strokeStyle = "#ffd25f"; ctx.lineWidth = 4; ctx.beginPath(); ctx.arc(left + 11, top + 10, 5, 0, Math.PI * 2); ctx.stroke();
      ctx.fillStyle = "#ffd25f"; ctx.fillRect(left + 14, top + 13, 4, 12); ctx.fillRect(left + 17, top + 20, 6, 4);
    } else if (char === "D" || char === "d") {
      ctx.save();
      if (char === "d") { ctx.translate(left + CELL, top + CELL); ctx.rotate(Math.PI); ctx.translate(-left, -top); }
      ctx.fillStyle = "#7e4dae"; ctx.fillRect(left + 6, top + 3, 18, 25);
      ctx.fillStyle = "#bc83ed"; ctx.fillRect(left + 9, top + 6, 12, 19);
      ctx.fillStyle = "#2a1f37"; ctx.fillRect(left + 17, top + 15, 3, 3); ctx.restore();
    } else if (char === "N") {
      ctx.strokeStyle = "#e8ba78"; ctx.lineWidth = 3;
      for (let offset = 0; offset < 4; offset += 1) { ctx.beginPath(); ctx.ellipse(left + 15, top + 17 + offset, 11 - offset, 5, 0, 0, Math.PI); ctx.stroke(); }
    } else if ("^v><s".includes(char)) {
      const color = char === "s" ? "#ad626d" : "#ff6673";
      if (char === "^" || char === "s") triangle(left + pad, top + CELL, left + CELL / 2, top + CELL / 2, left + CELL - pad, top + CELL, color);
      if (char === "v") triangle(left + pad, top, left + CELL - pad, top, left + CELL / 2, top + CELL / 2, color);
      if (char === ">") triangle(left + pad, top + pad, left + CELL - pad, top + CELL / 2, left + pad, top + CELL - pad, color);
      if (char === "<") triangle(left + CELL - pad, top + pad, left + pad, top + CELL / 2, left + CELL - pad, top + CELL - pad, color);
    } else if (char === "=") {
      ctx.fillStyle = "#47d9d2";
      for (let offset = 4; offset < CELL; offset += 9) ctx.fillRect(left + offset, top, 5, 5);
    } else if (char === "F") {
      ctx.fillStyle = "#47d9d2"; ctx.fillRect(left + 12, top + 4, 6, 22); ctx.fillRect(left + 4, top + 12, 22, 6);
      ctx.fillStyle = "#b5fffa"; ctx.fillRect(left + 13, top + 13, 4, 4);
    }
  }

  function drawFlyPaths(level) {
    const starts = Format.flyStarts(level);
    starts.forEach((start, index) => {
      const end = level.flies[index];
      if (!end) return;
      const sx = start.x * 3 + CELL / 2;
      const sy = start.y * 3 + CELL / 2;
      const ex = end.endX * 3 + CELL / 2;
      const ey = end.endY * 3 + CELL / 2;
      ctx.save(); ctx.strokeStyle = "rgba(71,217,210,.72)"; ctx.fillStyle = "#47d9d2"; ctx.lineWidth = 2; ctx.setLineDash([7, 6]);
      ctx.beginPath(); ctx.moveTo(sx, sy); ctx.lineTo(ex, ey); ctx.stroke(); ctx.setLineDash([]);
      ctx.beginPath(); ctx.arc(ex, ey, 5, 0, Math.PI * 2); ctx.fill();
      ctx.fillStyle = "#0c1118"; ctx.font = "bold 8px DM Mono, monospace"; ctx.textAlign = "center"; ctx.fillText(String(index + 1), ex, ey + 3); ctx.restore();
    });
  }

  function renderCanvas() {
    const level = levels[current];
    ctx.imageSmoothingEnabled = false;
    ctx.fillStyle = "#151b25"; ctx.fillRect(0, 0, canvas.width, canvas.height);
    if (current === 5 && level06Missile.complete && level06Missile.naturalWidth) {
      // Starting position of the larger visual-only Atari animation.
      ctx.drawImage(level06Missile, 10 * 3, 92 * 3, 168 * 3, 39 * 3);
    }
    drawFlyPaths(level);
    level.rows.forEach((row, y) => [...row].forEach((tile, x) => drawTile(tile, x, y)));
    ctx.strokeStyle = "rgba(119,136,156,.13)"; ctx.lineWidth = 1;
    for (let x = 0; x <= Format.WIDTH; x += 1) { ctx.beginPath(); ctx.moveTo(x * CELL + .5, 0); ctx.lineTo(x * CELL + .5, canvas.height); ctx.stroke(); }
    for (let y = 0; y <= Format.HEIGHT; y += 1) { ctx.beginPath(); ctx.moveTo(0, y * CELL + .5); ctx.lineTo(canvas.width, y * CELL + .5); ctx.stroke(); }
  }

  function renderFlyEditor() {
    const level = levels[current];
    const starts = Format.flyStarts(level);
    ui["fly-editor"].hidden = starts.length === 0;
    ui["fly-fields"].replaceChildren(...starts.map((start, index) => {
      const endpoint = level.flies[index] || { endX: start.x, endY: start.y };
      const card = document.createElement("div");
      card.className = "fly-card";
      card.innerHTML = `<div class="fly-card-title"><span>FLY ${index + 1}</span><span>START ${start.x}, ${start.y}</span></div><div class="fly-grid"><label>END X<input data-axis="endX" type="number" min="0" max="230" step="1" value="${endpoint.endX}"></label><label>END Y<input data-axis="endY" type="number" min="0" max="130" step="1" value="${endpoint.endY}"></label></div>`;
      card.querySelectorAll("input").forEach((input) => {
        input.addEventListener("change", () => {
          const max = input.dataset.axis === "endX" ? 230 : 130;
          const value = Math.max(0, Math.min(max, Math.round(Number(input.value) || 0)));
          if (level.flies[index][input.dataset.axis] === value) return;
          pushUndo(); level.flies[index][input.dataset.axis] = value; input.value = value; save(); renderAll();
        });
      });
      return card;
    }));
  }

  function renderValidation() {
    const result = Format.validateLevels(levels);
    const relevant = [...result.errors.map((text) => ({ text, type: "error" })), ...result.warnings.map((text) => ({ text, type: "warning" }))]
      .filter((item) => item.text.startsWith(`Level ${current + 1} `));
    const level = levels[current];
    const flat = level.rows.join("");
    const summary = `${[...flat].filter((tile) => tile === "K").length} keys · ${Format.flyStarts(level).length} flies · ${[...flat].filter((tile) => "^v><s".includes(tile)).length} spikes`;
    if (result.errors.length) { ui["validation-badge"].textContent = "BLOCKED"; ui["validation-badge"].className = "tag bad"; }
    else if (result.warnings.length) { ui["validation-badge"].textContent = "CHECK"; ui["validation-badge"].className = "tag warn"; }
    else { ui["validation-badge"].textContent = "READY"; ui["validation-badge"].className = "tag good"; }
    const items = relevant.length ? relevant : [{ text: summary, type: "ok" }, { text: "Map dimensions and fly data are export-safe.", type: "ok" }];
    ui["validation-list"].replaceChildren(...items.map((item) => {
      const li = document.createElement("li"); li.className = item.type; li.textContent = item.text; return li;
    }));
  }

  function renderAll() {
    const level = levels[current];
    ui["level-kicker"].textContent = `LEVEL ${String(current + 1).padStart(2, "0")} / ${Format.LEVEL_COUNT}`;
    ui["level-title"].textContent = level.name;
    ui["level-note"].textContent = level.note || "";
    ui.undo.disabled = undoStack.length === 0;
    ui.redo.disabled = redoStack.length === 0;
    renderLevelList(); renderPalette(); renderCanvas(); renderFlyEditor(); renderValidation();
  }

  function reconcileFlies(level, oldStarts, oldFlies) {
    const previous = oldStarts.map((start, index) => ({ ...start, ...(oldFlies[index] || { endX: start.x, endY: start.y }) }));
    level.flies = Format.flyStarts(level).map((start) => {
      const match = previous.find((fly) => fly.x === start.x && fly.y === start.y);
      return match ? { endX: match.endX, endY: match.endY } : { endX: start.x, endY: start.y };
    });
  }

  function brushCells(rows, x, y, char) {
    if (char !== ".") {
      if ("^vs".includes(char)) {
        const startX = Math.min(x, Format.WIDTH - 2);
        return [{ x: startX, y }, { x: startX + 1, y }];
      }
      if ("><".includes(char)) {
        const startY = Math.min(y, Format.HEIGHT - 2);
        return [{ x, y: startY }, { x, y: startY + 1 }];
      }
      return [{ x, y }];
    }

    const existing = rows[y][x];
    if ("^vs".includes(existing)) {
      let runStart = x;
      while (runStart > 0 && rows[y][runStart - 1] === existing) runStart -= 1;
      const pairStart = runStart + Math.floor((x - runStart) / 2) * 2;
      return [{ x: pairStart, y }, { x: pairStart + 1, y }]
        .filter((cell) => cell.x < Format.WIDTH && rows[cell.y][cell.x] === existing);
    }
    if ("><".includes(existing)) {
      let runStart = y;
      while (runStart > 0 && rows[runStart - 1][x] === existing) runStart -= 1;
      const pairStart = runStart + Math.floor((y - runStart) / 2) * 2;
      return [{ x, y: pairStart }, { x, y: pairStart + 1 }]
        .filter((cell) => cell.y < Format.HEIGHT && rows[cell.y][cell.x] === existing);
    }
    return [{ x, y }];
  }

  function paintCell(x, y, char) {
    if (x < 0 || x >= Format.WIDTH || y < 0 || y >= Format.HEIGHT) return;
    const level = levels[current];
    const cells = brushCells(level.rows, x, y, char);
    if (cells.every((cell) => level.rows[cell.y][cell.x] === char)) return;
    if (char === "F" && Format.flyStarts(level).length >= 2 && level.rows[y][x] !== "F") {
      showToast("VBXE supports at most two fly-spikes per room"); return;
    }
    if (!strokeSaved) { pushUndo(); strokeSaved = true; }
    const oldStarts = Format.flyStarts(level);
    const oldFlies = level.flies.map((fly) => ({ ...fly }));
    let rows = level.rows.slice();
    if (char === "P") rows = rows.map((row) => row.replace(/P/g, "."));
    cells.forEach((cell) => {
      rows[cell.y] = rows[cell.y].slice(0, cell.x) + char + rows[cell.y].slice(cell.x + 1);
    });
    level.rows = rows;
    reconcileFlies(level, oldStarts, oldFlies);
    save(); renderAll();
  }

  function eventCell(event) {
    const rect = canvas.getBoundingClientRect();
    return {
      x: Math.floor((event.clientX - rect.left) * canvas.width / rect.width / CELL),
      y: Math.floor((event.clientY - rect.top) * canvas.height / rect.height / CELL)
    };
  }

  function beginStroke(event) {
    if (event.button !== 0 && event.button !== 2) return;
    event.preventDefault(); drawing = true; strokeSaved = false; lastCell = "";
    canvas.setPointerCapture(event.pointerId);
    continueStroke(event);
  }

  function continueStroke(event) {
    const cell = eventCell(event);
    ui["cursor-position"].textContent = `COL ${String(cell.x).padStart(2, "0")} · ROW ${String(cell.y).padStart(2, "0")} · PX ${cell.x * 10},${cell.y * 10}`;
    if (!drawing) return;
    const key = `${cell.x},${cell.y}`;
    if (key === lastCell) return;
    lastCell = key;
    paintCell(cell.x, cell.y, event.buttons === 2 || event.button === 2 ? "." : selected);
  }

  function endStroke(event) {
    drawing = false; lastCell = "";
    if (event.pointerId !== undefined && canvas.hasPointerCapture(event.pointerId)) canvas.releasePointerCapture(event.pointerId);
  }

  function download(name, content, type) {
    const blob = new Blob([content], { type });
    const url = URL.createObjectURL(blob);
    const link = document.createElement("a"); link.href = url; link.download = name; link.click();
    setTimeout(() => URL.revokeObjectURL(url), 1000);
  }

  function exportAsm() {
    try { download("sulka-levels.asm", Format.exportAssembly(levels), "text/plain"); showToast("MADS level block exported"); }
    catch (error) { showToast(error.message.split("\n")[0]); }
  }

  function importFile(file) {
    const reader = new FileReader();
    reader.addEventListener("load", () => {
      try {
        const imported = file.name.toLowerCase().endsWith(".json") ? Format.parseJson(reader.result) : Format.parseAssembly(reader.result);
        const result = Format.validateLevels(imported);
        if (result.errors.length) throw new Error(result.errors.join("\n"));
        levels = imported; current = 0; undoStack = []; redoStack = []; save(); renderAll(); showToast("24 levels imported");
      } catch (error) { console.error(error); showToast(`Import failed: ${error.message.split("\n")[0]}`); }
      ui["file-input"].value = "";
    });
    reader.readAsText(file);
  }

  canvas.addEventListener("pointerdown", beginStroke);
  canvas.addEventListener("pointermove", continueStroke);
  canvas.addEventListener("pointerup", endStroke);
  canvas.addEventListener("pointercancel", endStroke);
  canvas.addEventListener("pointerleave", () => { if (!drawing) ui["cursor-position"].textContent = "COL — · ROW —"; });
  canvas.addEventListener("contextmenu", (event) => event.preventDefault());
  ui.undo.addEventListener("click", () => restoreFromStack(undoStack, redoStack));
  ui.redo.addEventListener("click", () => restoreFromStack(redoStack, undoStack));
  ui["reset-level"].addEventListener("click", () => {
    if (sameLevel(levels[current], originals[current])) return;
    pushUndo(); levels[current] = Format.cloneLevels([originals[current]])[0]; save(); renderAll(); showToast("Level restored");
  });
  ui["reset-all"].addEventListener("click", () => {
    if (!confirm("Restore all 24 original VBXE maps? This replaces every local edit.")) return;
    levels = Format.cloneLevels(originals); current = 0; undoStack = []; redoStack = []; save(); renderAll(); showToast("Original map set restored");
  });
  ui["export-asm"].addEventListener("click", exportAsm);
  ui["export-json"].addEventListener("click", () => { download("sulka-levels.json", Format.exportJson(levels), "application/json"); showToast("Editable JSON exported"); });
  ui["import-button"].addEventListener("click", () => ui["file-input"].click());
  ui["file-input"].addEventListener("change", () => { if (ui["file-input"].files[0]) importFile(ui["file-input"].files[0]); });

  document.addEventListener("keydown", (event) => {
    if (event.target.matches("input")) return;
    const modifier = event.ctrlKey || event.metaKey;
    if (modifier && event.key.toLowerCase() === "z") { event.preventDefault(); restoreFromStack(event.shiftKey ? redoStack : undoStack, event.shiftKey ? undoStack : redoStack); return; }
    if (modifier && event.key.toLowerCase() === "y") { event.preventDefault(); restoreFromStack(redoStack, undoStack); return; }
    if (event.key === "[") { setCurrent(current - 1); return; }
    if (event.key === "]") { setCurrent(current + 1); return; }
    const match = tiles.find((tile) => tile.key.toLowerCase() === event.key.toLowerCase());
    if (match) selectTool(match.char);
  });

  renderRulers(); selectTool(selected); renderAll();
})();
