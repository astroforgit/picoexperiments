// Optional UI smoke test: npm-installed playwright or PLAYWRIGHT_MODULE path.
// CDP_URL can point at an existing isolated browser; otherwise launch Chromium.
const assert = require("node:assert/strict");
const {chromium} = require(process.env.PLAYWRIGHT_MODULE || "playwright");
(async () => {
  const browser = process.env.CDP_URL ? await chromium.connectOverCDP(process.env.CDP_URL) :
    await chromium.launch({headless:true});
  const context = await browser.newContext({viewport:{width:1440,height:1000}});
  const page = await context.newPage();
  const errors=[];page.on("pageerror",error=>errors.push(error.message));
  await page.goto(process.env.EDITOR_URL || "http://127.0.0.1:8090/grapple/editor/");
  await page.waitForFunction(()=>!document.querySelector("#playMap").disabled);
  const original=await page.evaluate(()=>JSON.stringify(serializeMap()));
  assert.match(await page.locator("#buildStatus").innerText(),/match/);
  await page.click("#playMap");
  await page.waitForFunction(()=>GrapplePlaytest.isOpen && GrapplePlaytest.game.ticks>0);
  await page.keyboard.down("ArrowRight");await page.waitForTimeout(180);await page.keyboard.up("ArrowRight");
  await page.click("#pausePlay");
  const tick=await page.evaluate(()=>GrapplePlaytest.game.ticks);
  await page.waitForTimeout(90);
  assert.equal(await page.evaluate(()=>GrapplePlaytest.game.ticks),tick);
  await page.click("#stepPlay");
  assert.equal(await page.evaluate(()=>GrapplePlaytest.game.ticks),tick+1);
  await page.check("#playHitboxes");
  await page.selectOption("#playStart","1");
  assert.notEqual(await page.evaluate(()=>GrapplePlaytest.game.checkpoint),null);
  await page.click("#resetPlay");
  await page.click("#closePlay");
  assert.equal(await page.evaluate(()=>JSON.stringify(serializeMap())),original,"play must not mutate the map");

  // Enter a chamber directly from its visible editor cell.
  await page.fill("#jumpRow","29");await page.click("#jumpButton");
  await page.click("#playHere");
  const spot=await page.evaluate(()=>{
    const r=canvas.getBoundingClientRect();return {x:r.left+5.5*32,y:r.top+32.5*32};
  });
  await page.mouse.click(spot.x,spot.y);
  if (!await page.evaluate(()=>GrapplePlaytest.isOpen)) {
    console.log("Pick diagnostic",spot,await page.evaluate(()=>({status:statusElement.textContent,tool:activeTool,rect:canvas.getBoundingClientRect().toJSON(),zoom})));
    if(process.env.SCREENSHOT_PATH) await page.screenshot({path:process.env.SCREENSHOT_PATH});
  }
  await page.waitForFunction(()=>GrapplePlaytest.isOpen);
  assert.deepEqual(await page.evaluate(()=>GrapplePlaytest.game.start),{x:72,y:510});
  await page.click("#pausePlay");
  if(process.env.SCREENSHOT_PATH) await page.screenshot({path:process.env.SCREENSHOT_PATH});
  await page.click("#editAtPlayer");
  assert.match(await page.locator("#status").innerText(),/Editing near playtest row/);
  assert.equal(await page.evaluate(()=>JSON.stringify(serializeMap())),original);

  // Painting, undo and redo remain available after exiting the playtest.
  await page.click('[data-tile="18"]');
  await page.mouse.click(spot.x,spot.y);
  assert.notEqual(await page.evaluate(()=>JSON.stringify(serializeMap())),original);
  await page.click("#undo");
  assert.equal(await page.evaluate(()=>JSON.stringify(serializeMap())),original);
  await page.click("#redo");
  assert.notEqual(await page.evaluate(()=>JSON.stringify(serializeMap())),original);
  const downloadPromise=page.waitForEvent("download");await page.click("#exportMap");
  const download=await downloadPromise;assert.equal(download.suggestedFilename(),"world.json");
  assert.deepEqual(errors,[],"browser console errors");
  console.log("PASS: play, pause, step, checkpoint respawn, picked start, edit return, undo/redo, export and map isolation");
  await context.close();await browser.close();
})().catch(error=>{console.error(error);process.exit(1);});
