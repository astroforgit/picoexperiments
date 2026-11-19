const assert=require('node:assert/strict'),fs=require('node:fs');
const {chromium}=require(process.env.PLAYWRIGHT_MODULE||'playwright');
(async()=>{const report=JSON.parse(fs.readFileSync('/tmp/kult-wall-variants.json','utf8'));const browser=await chromium.launch({headless:true});try{
 const page=await browser.newPage(),errors=[];page.on('pageerror',e=>errors.push(e.message));
 await page.goto('http://127.0.0.1:8772/flight/');await page.waitForSelector('#workspace:not([hidden])');
 const routes=await page.evaluate(report=>report.flatMap(test=>test.routes.map(route=>{
  const p=structuredClone(project);p.boss.pattern=0;
  const e=new FlightWorkshop.Encounter(p,payload.sine,0,0,{curtainOnly:true,bossPreview:true,loop:false,rotationSeed:test.seed,gapSeed:test.gap});
  e.player={x:route.start[0],y:route.start[1]};e.invulnerable=0;
  for(let tick=0;tick<route.route.length;tick++){
   const [x,y]=route.route[tick];e.update({left:x<e.player.x,right:x>e.player.x,up:y<e.player.y,down:y>e.player.y});
   if(e.player.x!==x||e.player.y!==y)throw Error(`Movement mismatch ${test.variant}/${tick}`);
   const actual=e.hostile.map(b=>[b.lane,b.x,b.y]).sort((a,b)=>a[0]-b[0]);
   if(JSON.stringify(actual)!==JSON.stringify(test.frames[tick]))throw Error(`Projectile mismatch ${test.variant}/${tick}`);
  }
  return e.hits;
 })),report);assert.ok(routes.every(n=>n===0));
 await page.selectOption('#wave','20');for(let v=0;v<3;v++){await page.selectOption('#laserRoute',String(v));assert.equal(await page.evaluate(()=>encounter.laser.variant),v);}
 await page.selectOption('#wave','7');for(let v=0;v<12;v++){await page.selectOption('#wallRoute',String(v));assert.deepEqual(await page.evaluate(()=>[encounter.curtainRotation,encounter.curtainGap,encounter.options.curtainOnly]),[v%6,Math.floor(v/6),true]);}
 assert.deepEqual(errors,[]);console.log(`${routes.length} native wall routes replayed in Chromium; all 3 laser and 12 wall preview choices work.`);
}finally{await browser.close();}})().catch(e=>{console.error(e);process.exitCode=1;});
