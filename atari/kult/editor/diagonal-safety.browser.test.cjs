const assert=require('node:assert/strict'),fs=require('node:fs');
const {chromium}=require(process.env.PLAYWRIGHT_MODULE||'playwright');
(async()=>{const report=JSON.parse(fs.readFileSync(process.argv[2]||'/tmp/kult-diagonal-safety.json','utf8'));const browser=await chromium.launch({headless:true});try{
 const page=await browser.newPage(),errors=[];page.on('pageerror',e=>errors.push(e.message));
 await page.goto('http://127.0.0.1:8772/web/');await page.waitForFunction(()=>typeof game!=='undefined'&&game);
 const results=await page.evaluate(report=>report.routes.map(test=>{
  const p=structuredClone(project);p.encounters[0][0]=8;
  const e=new FlightWorkshop.Encounter(p,payload.sine,0,0,{loop:false});e.player={x:test.start[0],y:test.start[1]};e.invulnerable=0;
  for(let tick=0;tick<test.route.length;tick++){
   const [x,y]=test.route[tick];e.update({left:x<e.player.x,right:x>e.player.x,up:y<e.player.y,down:y>e.player.y});
   if(e.player.x!==x||e.player.y!==y)throw Error(`Player movement mismatch at ${tick}`);
   const actual=e.enemies.filter(a=>a.visible).map(a=>[a.i,a.x,a.y]);
   if(JSON.stringify(actual)!==JSON.stringify(report.frames[tick]))throw Error(`Meteor mismatch at ${tick}`);
   if(tick===50)renderer.draw(e,{trails:true});
  }
  return {hits:e.hits,complete:e.complete,stock:[e.bombs,e.shields,e.clocks]};
 }),report);
 for(const r of results){assert.equal(r.hits,0);assert.equal(r.complete,true);assert.deepEqual(r.stock,[3,3,3]);}
 await page.screenshot({path:'/tmp/kult-diagonal-preview.png'});assert.deepEqual(errors,[]);
 console.log(`${results.length} native routes replayed in the browser with no hits or consumables.`);
}finally{await browser.close();}})().catch(e=>{console.error(e);process.exitCode=1;});
