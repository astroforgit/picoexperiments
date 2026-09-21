// Assets tab: catalogue, VBXE colour mapping, and the workshop export.
// Needs a served editor: EDITOR_URL, plus playwright via PLAYWRIGHT_MODULE.
const assert = require("node:assert/strict");
const {chromium} = require(process.env.PLAYWRIGHT_MODULE || "playwright");

(async () => {
  const browser = process.env.CDP_URL ?
    await chromium.connectOverCDP(process.env.CDP_URL) :
    await chromium.launch({headless: true});
  const context = await browser.newContext({viewport: {width: 1440, height: 1000}});
  const page = await context.newPage();
  const errors = [];
  page.on("pageerror", error => errors.push(error.message));
  await page.goto(process.env.EDITOR_URL ||
    "http://127.0.0.1:8091/grapple/editor/");

  await page.click('[data-view-tab="assets"]');
  await page.waitForFunction(() => window.GrappleAssets.state.loaded);
  assert.equal(await page.locator(".workspace").isVisible(), false,
    "the map view must hide while Assets is open");

  // Every catalogued character renders, with one strip per animation.
  const cards = await page.locator(".asset-card").count();
  assert.equal(cards, 7, "seven characters");
  const anims = await page.locator(".asset-anim").count();
  assert.equal(anims, 12, "twelve animations across the catalogue");
  assert.match(await page.locator("#assetsStatus").innerText(),
    /7 characters · 12 animations/);

  // The hero's six states, named as src/player.ts names them.
  const heroStates = await page.evaluate(() =>
    window.GrappleAssets.CATALOGUE[0].animations.map(a => a.name));
  assert.deepEqual(heroStates,
    ["idle", "run", "jump", "fall", "grapple_horiz", "dead"]);

  // The run cycle is the five frames the port plays.
  const run = await page.evaluate(() =>
    window.GrappleAssets.CATALOGUE[0].animations.find(a => a.name === "run").frames);
  assert.deepEqual(run, [5, 6, 7, 8, 9]);

  // Slicing must agree with generate_assets.js: the hero uses only her own
  // three palette entries, and every other asset only the shared pair.
  const used = await page.evaluate(() => {
    const out = {};
    for (const [key, sheet] of Object.entries(window.GrappleAssets.state.sheets)) {
      const set = new Set();
      sheet.frames.forEach(f => f.grid.forEach(r => r.forEach(v => set.add(v))));
      out[key] = [...set].sort((a, b) => a - b);
    }
    return out;
  });
  assert.deepEqual(used.player, [0, 17, 18, 20], "hair, suit and boots");
  for (const key of ["mover", "cannon", "cannonball", "thwomp"]) {
    assert.ok(used[key].every(v => [0, 21, 22].includes(v)), `${key}: ${used[key]}`);
  }
  for (const key of ["spikes", "checkpoint"]) {
    assert.ok(used[key].every(v => [0, 21].includes(v)), `${key}: ${used[key]}`);
  }

  // The export has to be something generate_assets.js can read unchanged, so
  // the untouched hero preset must reproduce player.png pixel for pixel.
  const roundTrip = await page.evaluate(async () => {
    window.GrappleAssets.applyPreset("hero");
    const mine = window.GrappleAssets.exportSheetCanvas()
      .getContext("2d").getImageData(0, 0, 80, 64).data;
    const image = new Image();
    image.src = "../bin/assets/player.png";
    await image.decode();
    const canvas = document.createElement("canvas");
    canvas.width = 80;
    canvas.height = 64;
    canvas.getContext("2d").drawImage(image, 0, 0);
    const original = canvas.getContext("2d").getImageData(0, 0, 80, 64).data;
    const isRed = (d, i) => d[i] > 240 && d[i + 1] < 16;
    let differences = 0;
    let painted = 0;
    for (const frame of window.GrappleAssets.ATARI_SLOTS) {
      const ox = (frame % 5) * 16;
      const oy = Math.floor(frame / 5) * 16;
      for (let y = 0; y < 16; y += 1) {
        for (let x = 0; x < 16; x += 1) {
          const i = ((oy + y) * 80 + ox + x) * 4;
          const a = mine[i + 3] > 0;
          const b = original[i + 3] > 0;
          if (a !== b || (a && isRed(mine, i) !== isRed(original, i))) {
            differences += 1;
          }
          if (b) painted += 1;
        }
      }
    }
    return {differences, painted};
  });
  assert.ok(roundTrip.painted > 1000, "the comparison must see real artwork");
  assert.equal(roundTrip.differences, 0,
    "hero preset must export exactly what the pipeline already consumes");

  // Presets are additive: they may add pixels, never remove or move them.
  const additive = await page.evaluate(() => {
    const base = {};
    window.GrappleAssets.applyPreset("hero");
    for (const [k, g] of Object.entries(window.GrappleAssets.state.workshop.frames)) {
      base[k] = g.map(r => r.slice());
    }
    const report = {};
    for (const name of ["ponytail", "pack", "crest"]) {
      window.GrappleAssets.applyPreset(name);
      let removed = 0;
      let added = 0;
      for (const [k, g] of Object.entries(window.GrappleAssets.state.workshop.frames)) {
        g.forEach((row, y) => row.forEach((v, x) => {
          const was = base[k][y][x];
          if (was !== 0 && v !== was) removed += 1;
          if (was === 0 && v !== 0) added += 1;
        }));
      }
      report[name] = {removed, added};
    }
    return report;
  });
  for (const [name, {removed, added}] of Object.entries(additive)) {
    assert.equal(removed, 0, `${name} must not disturb the original poses`);
    assert.ok(added > 0, `${name} must actually change the silhouette`);
  }

  // Painting a pixel in the workshop reaches the export.
  const edited = await page.evaluate(() => {
    window.GrappleAssets.applyPreset("hero");
    window.GrappleAssets.state.workshop.frames[0][0][0] = 1;
    const data = window.GrappleAssets.exportSheetCanvas()
      .getContext("2d").getImageData(0, 0, 1, 1).data;
    return [...data];
  });
  assert.deepEqual(edited, [255, 0, 0, 255], "hair exports as pure red");

  // Map shortcuts must not fire while the Assets tab owns the screen.
  const toolBefore = await page.evaluate(() => window.currentTool ?? null);
  await page.keyboard.press("f");
  assert.equal(await page.evaluate(() => window.currentTool ?? null), toolBefore);

  await page.click('[data-view-tab="map"]');
  assert.equal(await page.locator(".workspace").isVisible(), true);
  assert.equal(await page.evaluate(() => window.GrappleAssets.isOpen), false);

  assert.deepEqual(errors, []);
  console.log("PASS: assets catalogue, VBXE colours, preset safety and " +
    "player.png export round-trip");
  await browser.close();
})().catch(error => { console.error(error); process.exit(1); });
