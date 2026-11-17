const assert=require('node:assert/strict');
const {chromium}=require(process.env.PLAYWRIGHT_MODULE||'playwright');
(async()=>{const browser=await chromium.launch({headless:true});try{
 const page=await browser.newPage(),errors=[];page.on('pageerror',e=>errors.push(e.message));
 await page.goto('http://127.0.0.1:8772/flight/');await page.waitForSelector('#workspace:not([hidden])');await page.click('#testBoss');
 assert.equal(await page.evaluate(()=>!!encounter.options.curtainOnly),false);
 const results=await page.evaluate(()=>{
  paused=true;const results=[];
  for(const guardian of [false,true]){
   const e=new FlightWorkshop.Encounter(project,payload.sine,0,0,{bossPreview:!guardian,guardian,aiSeed:0x5d,loop:false});const phases=new Set(),art=new Set();
   for(let t=0;t<1600;t++){e.invulnerable=999;e.update();renderer.draw(e);phases.add(e.ai.phase);for(const b of e.hostile)art.add(b.art);}
   results.push({phases:[...phases],art:[...art]});
  }return results;
 });
 for(const r of results){for(const phase of [1,2,3,4,5,6,7,8])assert.ok(r.phases.includes(phase));assert.deepEqual(r.art.sort(),['curtain','meteor','orb']);}
 assert.deepEqual(errors,[]);console.log('Both boss controllers and all projectile types render through complete browser cycles.');
}finally{await browser.close();}})().catch(e=>{console.error(e);process.exitCode=1});
