const assert=require('node:assert/strict');
const {chromium}=require(process.env.PLAYWRIGHT_MODULE||'playwright');
(async()=>{const browser=await chromium.launch({headless:true});try{
 const page=await browser.newPage(),errors=[];page.on('pageerror',e=>errors.push(e.message));
 await page.goto('http://127.0.0.1:8772/web/');await page.waitForFunction(()=>typeof game!=='undefined'&&game);
 const results=await page.evaluate(()=>[false,true].map(guardian=>{
  const e=new FlightWorkshop.Encounter(project,payload.sine,0,0,{loop:false,bossPreview:!guardian,guardian});
  e.bossX=88;e.bossTop=32;e.bossHP=0;e.player={x:100,y:56};e.invulnerable=0;
  e.update();const count=e.deathShots.length,startPhase=e.ai.phase;
  renderer.draw(e);e.update();const spread=new Set(e.deathShots.map(b=>b.x+','+b.y)).size;
  for(let i=0;i<24;i++)e.update();
  return {guardian,count,startPhase,spread,hits:e.hits,endPhase:e.ai.phase,remaining:e.deathShots.length};
 }));
 for(const r of results){assert.equal(r.count,8);assert.equal(r.startPhase,9);assert.equal(r.spread,8);assert.equal(r.hits,0);assert.equal(r.endPhase,10);assert.equal(r.remaining,0);}
 await page.click('#sound');
 await page.evaluate(async()=>{for(const name of ['shot','pickup','hit','explode','bomb','end']){sound(name);await new Promise(r=>setTimeout(r,140));}});
 assert.deepEqual(errors,[]);console.log('Both boss defeat bursts render, spread, expire harmlessly; revised sound cues play without errors.');
}finally{await browser.close();}})().catch(e=>{console.error(e);process.exitCode=1;});
