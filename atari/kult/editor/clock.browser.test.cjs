const assert=require('node:assert/strict');
const {chromium}=require(process.env.PLAYWRIGHT_MODULE||'playwright');
(async()=>{const browser=await chromium.launch({headless:true});try{
 const page=await browser.newPage({viewport:{width:1280,height:1000}}),errors=[];page.on('pageerror',e=>errors.push(e.message));
 await page.goto('http://127.0.0.1:8772/flight/');await page.waitForSelector('#workspace:not([hidden])');
 const report=await page.evaluate(()=>{
  const results=[];
  for(const kind of [0,1,2,3,4,6,7]){
   const p=structuredClone(project);p.encounters[0][0]=kind;p.firing.mode=0;
   const a=new FlightWorkshop.Encounter(p,payload.sine,0,0,{loop:false}),b=new FlightWorkshop.Encounter(p,payload.sine,0,0,{loop:false});
   a.invulnerable=b.invulnerable=999;
   for(let t=0;t<20;t++){b.update({clock:true,right:true},.02);if(t%3===2)a.update({},.02);}
   results.push({kind,same:JSON.stringify(a.enemies.map(e=>[e.x,e.y]))===JSON.stringify(b.enemies.map(e=>[e.x,e.y])),boss:a.bossX===b.bossX,ship:b.player.x,stock:b.clocks});
  }
  const p=structuredClone(project);p.encounters[0][0]=1;p.firing.mode=0;
  const normalFire=new FlightWorkshop.Encounter(p,payload.sine,0,0,{loop:false});
  const slowFire=new FlightWorkshop.Encounter(p,payload.sine,0,0,{loop:false});
  for(const e of [normalFire,slowFire])e.invulnerable=999;
  for(let t=0;t<12;t++){normalFire.update({fire:true},.02);slowFire.update({fire:true,clock:true},.02);}
  const firingMatches=JSON.stringify(normalFire.shots)===JSON.stringify(slowFire.shots);
  const s=new FlightWorkshop.Encounter(p,payload.sine,0,0,{loop:false});s.invulnerable=999;s.shots=[{x:0,y:120}];s.hostile=[{x:110,y:0,dy:0}];
  for(let t=0;t<6;t++)s.update({clock:true},.02);
  const bullets=[s.shots[0].x,s.hostile[0].x];
  for(let t=0;t<94;t++)s.update({clock:true},.02);
  const afterTwoSeconds=s.slowRemaining;
  for(let t=0;t<60;t++)s.update({clock:true},.02);
  const heldStock=s.clocks,duration=s.slowRemaining;
  s.clocks=0;s.pickups=[{type:'Clock',x:s.player.x+2,y:s.player.y}];s.update({},.02);
  return {firingMatches,afterTwoSeconds,results,bullets,heldStock,duration,pickup:s.clocks,icons:payload.pickups.map(p=>p.name)};
 });
 for(const r of report.results){assert.ok(r.same&&r.boss,JSON.stringify(r));assert.equal(r.ship,72);assert.equal(r.stock,2);}
 assert.ok(report.firingMatches);assert.ok(report.afterTwoSeconds>1&&report.afterTwoSeconds<1.04);assert.deepEqual(report.bullets,[36,104]);assert.equal(report.heldStock,2);assert.equal(report.duration,0);assert.equal(report.pickup,1);assert.ok(report.icons.includes('Clock'));
 await page.locator('#flight').focus();const stock=await page.evaluate(()=>encounter.clocks);await page.keyboard.down('z');await page.waitForTimeout(150);await page.keyboard.up('z');assert.equal(await page.evaluate(()=>encounter.clocks),stock-1);
 await page.goto('http://127.0.0.1:8772/web/');await page.waitForFunction(()=>typeof game!=='undefined'&&game);
 await page.locator('#game').focus();await page.keyboard.press('x');await page.waitForTimeout(100);
 assert.equal(await page.evaluate(()=>game.encounter.clocks),2);assert.ok(await page.evaluate(()=>game.encounter.slowRemaining>0));
 await page.screenshot({path:'/tmp/kult-clock-game.png',fullPage:true});assert.deepEqual(errors,[]);
 console.log('Clock: one-third-speed hazards, normal player shots and ship, duration, pickups, HUD and real keyboard controls passed.');
}finally{await browser.close();}})().catch(e=>{console.error(e);process.exitCode=1;});
