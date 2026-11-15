const assert=require('node:assert/strict');
const {chromium}=require(process.env.PLAYWRIGHT_MODULE||'playwright');
(async()=>{
 const browser=await chromium.launch({headless:true,executablePath:process.env.CHROMIUM_PATH});
 try{
 const page=await browser.newPage({viewport:{width:1440,height:1100}}),errors=[];page.on('pageerror',e=>errors.push(e.message));
 const url=process.env.GAME_URL||'http://127.0.0.1:8772/cetas-web/';await page.goto(url);await page.waitForFunction(()=>!document.querySelector('#start').disabled);
 const startBox=await page.locator('#start').boundingBox(),screenBox=await page.locator('#screen').boundingBox();assert.ok(startBox.y>=screenBox.y&&startBox.y+startBox.height<=screenBox.y+screenBox.height,'Start button must fit inside playfield');await page.screenshot({path:'/tmp/cetas-web-title.png'});await page.click('#start');await page.waitForFunction(()=>game.mode==='playing');
 const x=await page.evaluate(()=>game.player.x);await page.keyboard.down('ArrowRight');await page.waitForTimeout(220);await page.keyboard.up('ArrowRight');assert.ok(await page.evaluate(()=>game.player.x)>x);
 await page.keyboard.down('Space');await page.waitForTimeout(250);assert.ok(await page.evaluate(()=>game.shots.length)>0);await page.keyboard.up('Space');
 await page.keyboard.press('KeyP');assert.equal(await page.evaluate(()=>game.mode),'paused');const tick=await page.evaluate(()=>game.tick);await page.waitForTimeout(100);assert.equal(await page.evaluate(()=>game.tick),tick);await page.click('#start');
 await page.evaluate(()=>{document.dispatchEvent(new KeyboardEvent('keydown',{code:'KeyX'}));document.dispatchEvent(new KeyboardEvent('keyup',{code:'KeyX'}));});await page.waitForFunction(()=>game.pulses===2);assert.equal(await page.evaluate(()=>game.pulses),2);
 await page.click('#sound');assert.equal(await page.locator('#sound').getAttribute('aria-pressed'),'true');
 await page.waitForFunction(()=>game.enemies.length>0);await page.waitForTimeout(2400);await page.screenshot({path:'/tmp/cetas-web-playing.png'});
 // A real session snapshot exposes any automatic early terrain deaths.
 console.log('Natural flight snapshot:',await page.evaluate(()=>({mode:game.mode,lives:game.lives,wave:game.spawned,tick:game.tick})));
 await page.selectOption('#stage','3');await page.click('#restart');assert.equal(await page.evaluate(()=>game.chapter),3);assert.equal(await page.evaluate(()=>game.lives),3);
 await page.evaluate(()=>{game.score=12345;});await page.waitForFunction(()=>document.querySelector('#best').textContent==='012345');await page.reload();await page.waitForFunction(()=>!document.querySelector('#start').disabled);assert.equal(await page.locator('#best').textContent(),'012345');
 await page.evaluate(()=>{game.start();game.invulnerable=0;game.lives=1;game.hit();});await page.waitForFunction(()=>document.querySelector('#overlayTitle').textContent==='Signal lost.');await page.click('#start');assert.equal(await page.evaluate(()=>game.mode),'playing');
 await page.evaluate(()=>{window.dispatchEvent(new Event('blur'));});await page.waitForFunction(()=>game.mode==='paused');
 await page.setViewportSize({width:390,height:844});await page.screenshot({path:'/tmp/cetas-web-mobile.png'});assert.equal(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),true);
 await page.click('#start');const box=await page.locator('#game').boundingBox();await page.mouse.move(box.x+box.width*.6,box.y+box.height*.5);await page.mouse.down();await page.waitForTimeout(180);await page.mouse.up();assert.ok(await page.evaluate(()=>game.player.x)>4);
 await page.locator('#touchFire').dispatchEvent('pointerdown',{pointerId:1});await page.waitForTimeout(80);assert.equal(await page.evaluate(()=>touch.fire),true);await page.locator('#touchFire').dispatchEvent('pointercancel',{pointerId:1});assert.equal(await page.evaluate(()=>touch.fire),false);
 assert.deepEqual(errors,[]);console.log('Browser start, movement, firing, pulse, pause, sound, stage selection, score persistence, game-over restart, blur pause, mobile layout and pointer controls passed.');
 }finally{await browser.close();}
})().catch(e=>{console.error(e);process.exitCode=1;});
