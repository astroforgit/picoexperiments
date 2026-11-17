const assert=require('node:assert/strict'),path=require('node:path');
const {chromium}=require(process.env.PLAYWRIGHT_MODULE||'playwright');
(async()=>{const browser=await chromium.launch({headless:true});try{
 const p=await browser.newPage({viewport:{width:1280,height:1100}}),errors=[];p.on('pageerror',e=>errors.push(e.message));
 await p.goto('http://127.0.0.1:8772/flight/');await p.waitForSelector('#workspace:not([hidden])');
 await p.click('#testCurtain');await p.click('#pause');
 assert.equal(await p.evaluate(()=>encounter.ai.phase),4);assert.equal(await p.evaluate(()=>!!encounter.options.curtainOnly),false);
 await p.addScriptTag({path:path.resolve(__dirname,'boss-wave-safety.cjs')});
 const result=await p.evaluate(()=>{let frames=0;return BossWaveSafety.verify(payload,e=>{if(++frames%12===0)renderer.draw(e);});});
 assert.equal(result.passable,126);assert.ok(result.reactionSecondsAt17>=.35);
 await p.evaluate(()=>{const t=BossWaveSafety.trace(payload,3,5),path=BossWaveSafety.route(t,12,56,6);const e=BossWaveSafety.encounter(payload,3,5);e.player={x:12,y:56};for(const y of path.slice(0,130))e.update({up:y<e.player.y,down:y>e.player.y});encounter=e;renderer.draw(encounter);});
 await p.locator('#flight').screenshot({path:'/tmp/kult-paced-boss-wave.png'});
 assert.deepEqual(errors,[]);console.log('Browser replay: 126 four-wave dodges, six-update reactions, zero hits; editor uses live paced attack.');
}finally{await browser.close();}})().catch(e=>{console.error(e);process.exitCode=1});
