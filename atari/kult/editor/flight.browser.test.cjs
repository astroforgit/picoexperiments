const assert=require('node:assert/strict'),fs=require('node:fs/promises');
const {chromium}=require(process.env.PLAYWRIGHT_MODULE||'playwright');
(async()=>{const url='http://127.0.0.1:8772',initial=(await (await fetch(url+'/api/diabolic')).json()).project;let applied=false;
const browser=await chromium.launch({headless:true});try{
 const page=await browser.newPage({viewport:{width:1440,height:1100}}),errors=[];page.on('pageerror',e=>errors.push(e.message));
 await page.goto(url+'/flight/');await page.waitForSelector('#workspace:not([hidden])');
 assert.equal(await page.locator('#ship option').count(),5);assert.equal(await page.locator('#design option').count(),36);
 await page.selectOption('#ship','ship-2');await page.selectOption('#design','enemy-0');await page.fill('#param0','-3');await page.locator('#param0').dispatchEvent('change');await page.fill('#hp','4');await page.locator('#hp').dispatchEvent('change');await page.fill('#fireInterval','12');await page.locator('#fireInterval').dispatchEvent('change');
 await page.locator('#flight').focus();const before=await page.evaluate(()=>encounter.player.x);await page.keyboard.down('ArrowRight');await page.waitForTimeout(240);await page.keyboard.up('ArrowRight');assert.ok(await page.evaluate(()=>encounter.player.x)>before);
 await page.click('#pause');const tick=await page.evaluate(()=>encounter.tick);await page.waitForTimeout(150);assert.equal(await page.evaluate(()=>encounter.tick),tick);await page.click('#pause');
 let wait=page.waitForEvent('download');await page.click('#save');const saved=await wait;const json=JSON.parse(await fs.readFile(await saved.path(),'utf8'));assert.equal(json.ship,'ship-2');assert.equal(json.slots[json.waves[0][0][0]],'enemy-0');assert.equal(json.motions[json.waves[0][0][1]][0],-3);
 wait=page.waitForEvent('download');await page.click('#export');const xex=await wait;assert.equal((await fs.readFile(await xex.path())).length,35097);
 await page.click('#apply');applied=true;await page.waitForFunction(()=>document.querySelector('#status').textContent.startsWith('Applied.'),{timeout:30000});const current=(await (await fetch(url+'/api/diabolic')).json()).project;assert.equal(current.ship,'ship-2');
 await page.screenshot({path:'/home/marcin/tmp/pico/atari/kult/editor/flight-preview.png',fullPage:true});
 await page.setInputFiles('#projectFile',{name:'project.json',mimeType:'application/json',buffer:Buffer.from(JSON.stringify(initial))});await page.waitForFunction(id=>document.querySelector('#ship').value===id,initial.ship);
 await page.setViewportSize({width:390,height:844});await page.screenshot({path:'/tmp/kult-flight-mobile.png',fullPage:true});assert.equal(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),true);
 assert.deepEqual(errors,[]);console.log('Flight editor: selectors, native path editing, controls, pause, JSON roundtrip, XEX download, local apply, animated previews and mobile layout passed.');
}finally{if(applied){const r=await fetch(url+'/api/diabolic/apply',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify(initial)});assert.ok(r.ok,await r.text());}await browser.close();}})().catch(e=>{console.error(e);process.exitCode=1;});
