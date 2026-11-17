const assert=require('node:assert/strict');
const {chromium}=require(process.env.PLAYWRIGHT_MODULE||'playwright');
(async()=>{const browser=await chromium.launch({headless:true});try{
 const page=await browser.newPage({viewport:{width:1440,height:1100}}),errors=[];
 page.on('pageerror',e=>errors.push(e.message));await page.goto('http://127.0.0.1:8772/flight/');
 await page.waitForSelector('#workspace:not([hidden])');await page.selectOption('#wave','11');
 assert.equal(await page.locator('#encounter').inputValue(),'7');
 await page.click('#pause');
 const result=await page.evaluate(()=>{
  const sim=new FlightWorkshop.Encounter(project,payload.sine,0,11,{loop:false});
  for(let i=0;i<60;i++)sim.update();
  renderer.draw(sim);const active=sim.enemies.filter(e=>e.visible);
  sim.update({bomb:true});
  const bombHP=sim.enemies.map(e=>e.hp);
  return {kind:sim.kind,rocks:active.filter(e=>e.i<2).length,enemies:active.filter(e=>e.i>=2).length,bombHP};
 });
 assert.equal(result.kind,7);assert.equal(result.rocks,2);assert.ok(result.enemies>0);
 assert.ok(result.bombHP.slice(0,2).every(h=>h>0));assert.deepEqual(result.bombHP.slice(2),[0,0,0,0,0,0]);
 await page.screenshot({path:'/tmp/kult-mixed-wave-editor.png',fullPage:true});assert.deepEqual(errors,[]);
 console.log('Mixed wave selector, combined sprites, simulator and bomb immunity passed.');
}finally{await browser.close();}})().catch(e=>{console.error(e);process.exitCode=1;});
