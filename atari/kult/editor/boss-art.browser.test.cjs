const assert=require('node:assert/strict');
const {chromium}=require(process.env.PLAYWRIGHT_MODULE||'playwright');
(async()=>{const browser=await chromium.launch({headless:true});try{
 const p=await browser.newPage({viewport:{width:1280,height:1000}}),errors=[];p.on('pageerror',e=>errors.push(e.message));
 await p.goto('http://127.0.0.1:8772/flight/');await p.waitForSelector('#workspace:not([hidden])');
 assert.equal(await p.locator('#bossGallery button').count(),4);assert.equal(await p.locator('#bossDesign option').count(),4);
 assert.equal(await p.locator('#bossDesign option[value="boss-original-dragon"]').count(),0);
 const ids=await p.locator('#bossDesign option').evaluateAll(es=>es.map(e=>e.value));
 for(const id of ids){
  await p.selectOption('#bossDesign',id);await p.click('#testBoss');
  assert.equal(await p.evaluate(()=>encounter.project.boss.design),id);
  assert.equal(await p.locator('#bossGallery button[aria-pressed="true"]').count(),1);
  const result=await p.evaluate(()=>{const r=renderer,a=r.assets.get(project.boss.design);return {size:[a.width,a.height],frames:a.frames.length,pixels:a.frames.map(f=>f.reduce((n,p)=>n+p,0))};});
  assert.deepEqual(result.size,[64,64]);assert.equal(result.frames,4);assert.ok(result.pixels.every(n=>n>100));
 }
 await p.reload();await p.waitForSelector('#workspace:not([hidden])');assert.equal(await p.locator('#bossDesign').inputValue(),ids.at(-1));
 await p.selectOption('#bossDesign','boss-iron-manta');
 const popupEvent=p.waitForEvent('popup');await p.click('#openSimulator');const popup=await popupEvent;await popup.waitForFunction(()=>typeof game!=='undefined'&&game);assert.equal(await popup.evaluate(()=>project.boss.design),'boss-iron-manta');
 await p.locator('.boss-art').screenshot({path:'/tmp/kult-boss-candidates-editor.png'});
 assert.deepEqual(errors,[]);console.log('Four animated boss choices, persistence, native-sized frames and browser handoff passed.');
}finally{await browser.close();}})().catch(e=>{console.error(e);process.exitCode=1});
