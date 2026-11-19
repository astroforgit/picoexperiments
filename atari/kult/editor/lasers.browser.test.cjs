const assert=require('node:assert/strict'),fs=require('node:fs');
const {chromium}=require(process.env.PLAYWRIGHT_MODULE||'playwright');
(async()=>{const report=JSON.parse(fs.readFileSync('/tmp/kult-laser-safety.json','utf8'));const browser=await chromium.launch({headless:true});try{
 const page=await browser.newPage(),errors=[];page.on('pageerror',e=>errors.push(e.message));
 await page.goto('http://127.0.0.1:8772/web/');await page.waitForFunction(()=>typeof game!=='undefined'&&game);
 const results=await page.evaluate(report=>report.reports.flatMap(test=>test.routes.map(route=>{
  const p=structuredClone(project);p.encounters[0][0]=9;
  const e=new FlightWorkshop.Encounter(p,payload.sine,0,0,{loop:false,laserVariant:test.variant});e.player={x:12,y:route.start};e.invulnerable=0;
  for(let tick=0;tick<route.ys.length;tick++){
   const y=route.ys[tick];e.update({up:y<e.player.y,down:y>e.player.y},test.period/50);
   if(e.player.y!==y)throw Error(`Player movement mismatch at ${tick}`);
   const f=test.frames[tick];if(e.laser.phase!==f.phase||e.laser.index!==f.pattern)throw Error(`Laser mismatch at ${tick}: ${JSON.stringify(e.laser)} vs ${JSON.stringify(f)}`);
   if(tick===50)renderer.draw(e,{trails:true});
  }
  e.update({},test.period/50);
  return {hits:e.hits,complete:e.complete,stock:[e.bombs,e.shields,e.clocks]};
 })),report);
 for(const r of results){assert.equal(r.hits,0);assert.equal(r.complete,true);assert.deepEqual(r.stock,[3,3,3]);}
 assert.deepEqual(errors,[]);console.log(`${results.length} native laser routes replayed in browser without hits or consumables.`);
}finally{await browser.close();}})().catch(e=>{console.error(e);process.exitCode=1;});
