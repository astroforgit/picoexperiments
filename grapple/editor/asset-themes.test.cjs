const assert=require('node:assert/strict');
const {chromium}=require(process.env.PLAYWRIGHT_MODULE||'playwright');
(async()=>{
  const browser=await chromium.launch({headless:true,channel:process.env.BROWSER_CHANNEL||'chrome'});
  try{
    const page=await browser.newPage({viewport:{width:1440,height:1000}});
    const errors=[];page.on('pageerror',e=>errors.push(e.message));
    await page.goto(process.env.EDITOR_URL||'http://127.0.0.1:8090/grapple/editor/?view=assets');
    await page.waitForFunction(()=>GrappleAssets.state.loaded&&GrappleAssets.state.workshop);
    const map=await page.evaluate(()=>JSON.stringify(serializeMap()));
    await page.selectOption('#assetCharacter','4');
    await page.waitForFunction(()=>!document.querySelector('#assetCharacter').disabled);
    assert.equal(await page.inputValue('#assetTheme'),'goth');
    await page.evaluate(()=>GrappleAssets.state.workshop.frames[0][0][0]=1);
    const signatures={};
    for(const theme of ['scifi','surreal','goth','blackmetal','classic']){
      await page.selectOption('#assetTheme',theme);
      await page.waitForFunction(()=>!document.querySelector('#assetTheme').disabled);
      assert.equal(await page.inputValue('#assetCharacter'),'4');
      assert.equal(await page.evaluate(()=>GrappleAssets.state.workshop.frames[0][0][0]),1,'theme switch preserves painting');
      signatures[theme]=await page.evaluate(async()=>{
        const canvases=await GrappleAssets.playtestCanvases();
        window.themeCanvases=canvases;
        const fingerprint=c=>{
          const data=c.getContext('2d').getImageData(0,0,c.width,c.height).data;
          let hash=2166136261;for(const value of data)hash=Math.imul(hash^value,16777619)>>>0;
          return hash;
        };
        const out={};
        for(const [key,c]of Object.entries(canvases))if(key!=='player')out[key]={hash:fingerprint(c),size:[c.width,c.height]};
        return out;
      });
      const expected={mover:[16,16],spikes:[16,16],cannon:[16,16],cannonball:[10,10],thwomp:[48,16],checkpoint:[32,16]};
      for(const key in expected)assert.deepEqual(signatures[theme][key].size,expected[key]);
      const links=await page.locator('.asset-card a').evaluateAll(as=>as.slice(1).map(a=>a.href));
      assert.ok(links.every(href=>href.includes(theme==='classic'?'/bin/assets/':({scifi:'/SciFi/',surreal:'/Surreal/',goth:'/GothPunk/',blackmetal:'/BlackMetal/'}[theme]))));
      // Capture exact canvas identities passed to the game renderer.
      await page.evaluate(()=>{
        window.rendered=new Set();
        window.originalThemeDraw=CanvasRenderingContext2D.prototype.drawImage;
        CanvasRenderingContext2D.prototype.drawImage=function(source,...args){
          if(this.canvas.id==='playCanvas')for(const [key,c]of Object.entries(themeCanvases))if(source===c)rendered.add(key);
          return originalThemeDraw.call(this,source,...args);
        };
      });
      await page.click('#assetPlaytest');
      await page.waitForFunction(()=>GrapplePlaytest.isOpen);
      // Move the test camera to real actors; the map snapshot is never painted.
      for(const list of ['movers','spikes','cannons','thwomps','checkpoints']){
        await page.evaluate(async list=>{
          const actor=GrapplePlaytest.game[list][0];
          await GrapplePlaytest.open({x:72,y:actor.y+16});
        },list);
      }
      await page.evaluate(async()=>{
        // Real cannon firing, with a start offset from its hazard box.
        const cannon=GrapplePlaytest.game.cannons[0];
        await GrapplePlaytest.open({x:72,y:cannon.y+16});
        const g=GrapplePlaytest.game;
        g.cannons[0].timer=1;
      });
      if(await page.locator('#stepPlay').isDisabled())await page.click('#pausePlay');
      await page.click('#stepPlay');
      await page.waitForFunction(()=>rendered.has('cannonball'));
      const rendered=await page.evaluate(()=>[...rendered]);
      for(const key of ['mover','spikes','cannon','cannonball','thwomp','checkpoint'])assert.ok(rendered.includes(key),`${theme} ${key} reaches actual game renderer`);
      await page.click('#closePlay');
      await page.evaluate(()=>CanvasRenderingContext2D.prototype.drawImage=originalThemeDraw);
      assert.equal(await page.evaluate(()=>JSON.stringify(serializeMap())),map);
    }
    for(const key of Object.keys(signatures.classic)){
      const hashes=Object.values(signatures).map(s=>s[key].hash);
      assert.equal(new Set(hashes).size,5,`${key}: five distinct artworks`);
    }
    // Failed theme loads leave the previous sheets and workshop intact.
    await page.route('**/SciFi/cannonball.png',route=>route.abort());
    await page.selectOption('#assetTheme','scifi');
    await page.waitForFunction(()=>!document.querySelector('#assetTheme').disabled);
    assert.equal(await page.inputValue('#assetTheme'),'classic');
    assert.match(await page.locator('#assetsStatus').innerText(),/Could not load asset theme/);
    await page.unroute('**/SciFi/cannonball.png');
    await page.selectOption('#assetTheme','goth');
    await page.waitForFunction(()=>!document.querySelector('#assetTheme').disabled);
    if(process.env.SCREENSHOT_PATH)await page.screenshot({path:process.env.SCREENSHOT_PATH});
    await page.setViewportSize({width:900,height:850});
    const bounds=await page.locator('#assetTheme').boundingBox();
    assert.ok(bounds.x>=0&&bounds.x+bounds.width<=900,'theme picker fits narrow viewport');
    assert.deepEqual(errors,[]);
    console.log('PASS: five distinct complete themes, native sheet dimensions, all six companion assets in actual playtest, real cannonball firing, workshop preservation, map isolation and failed-load recovery');
  }finally{await browser.close();}
})().catch(e=>{console.error(e);process.exit(1);});
