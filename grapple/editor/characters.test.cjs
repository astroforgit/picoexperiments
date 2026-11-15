// Character selection must reach the real playtest and export its palette.
const assert = require('node:assert/strict');
const {chromium} = require(process.env.PLAYWRIGHT_MODULE || 'playwright');
(async () => {
  const browser = await chromium.launch({headless:true, channel:process.env.BROWSER_CHANNEL || 'chrome'});
  try {
    const page = await browser.newPage({viewport:{width:1440,height:1000}});
    const errors=[];
    page.on('pageerror', e=>errors.push(e.message));
    await page.goto((process.env.EDITOR_URL || 'http://127.0.0.1:8090/grapple/editor/')+'?view=assets');
    await page.waitForFunction(()=>GrappleAssets.state.loaded && GrappleAssets.state.workshop);
    const world = await page.evaluate(()=>JSON.stringify(serializeMap()));
    assert.equal(await page.locator('#assetCharacter option').count(),6);
    for (const index of [2,3,4,5,1,0]) {
      await page.selectOption('#assetCharacter',String(index));
      await page.waitForFunction(()=>!document.querySelector('#assetCharacter').disabled);
      const report=await page.evaluate(async()=>{
        const a=GrappleAssets;
        const canvas=await a.playerCanvas();
        const pixels=canvas.getContext('2d').getImageData(0,0,80,64).data;
        const used=new Set();
        for(let i=0;i<pixels.length;i+=4)if(pixels[i+3])used.add('#'+[...pixels.slice(i,i+3)].map(x=>x.toString(16).padStart(2,'0')).join(''));
        return {name:a.CHARACTERS[a.state.character].name,
          used:[...used],allowed:Object.values(a.CHARACTERS[a.state.character].palette),
          frames:a.ATARI_SLOTS.filter(s=>!a.state.sheets.player.frames[s].empty).length};
      });
      assert.equal(report.frames,16);
      assert.ok(report.used.every(c=>report.allowed.includes(c)));
      if(index>=2) assert.equal(report.used.length,4);
      // Check the actual game drawImage source, not just the helper canvas.
      await page.evaluate(()=>{
        window.heroPixels=null;
        window.originalDrawImage=CanvasRenderingContext2D.prototype.drawImage;
        CanvasRenderingContext2D.prototype.drawImage=function(source,...args){
          if(this.canvas.id==='playCanvas' && source instanceof HTMLCanvasElement && source.width===80){
            window.heroPixels=[...source.getContext('2d').getImageData(0,0,80,64).data];
          }
          return originalDrawImage.call(this,source,...args);
        };
      });
      await page.click('#assetPlaytest');
      await page.waitForFunction(()=>GrapplePlaytest.isOpen && heroPixels);
      const used=await page.evaluate(()=>{
        const out=new Set();for(let i=0;i<heroPixels.length;i+=4)if(heroPixels[i+3])out.add('#'+heroPixels.slice(i,i+3).map(x=>x.toString(16).padStart(2,'0')).join(''));
        return [...out];
      });
      assert.deepEqual(used.sort(),report.used.sort());
      await page.click('#pausePlay');
      await page.click('#stepPlay');
      if(index===2 && process.env.SCREENSHOT_PATH)await page.screenshot({path:process.env.SCREENSHOT_PATH});
      await page.click('#closePlay');
      await page.evaluate(()=>{CanvasRenderingContext2D.prototype.drawImage=originalDrawImage;});
      assert.equal(await page.evaluate(()=>JSON.stringify(serializeMap())),world);
    }
    await page.selectOption('#assetCharacter','3');
    await page.waitForFunction(()=>!document.querySelector('#assetCharacter').disabled);
    const downloadPromise=page.waitForEvent('download');
    await page.getByRole('button',{name:'Export palette JSON',exact:true}).click();
    const download=await downloadPromise;
    assert.equal(download.suggestedFilename(),'player.palette.json');
    const fs=require('fs');
    const palette=JSON.parse(fs.readFileSync(await download.path(),'utf8'));
    assert.equal(palette[20],'#ff79bd');
    // Workshop edits also reach gameplay; original art remains untouched.
    await page.evaluate(()=>GrappleAssets.state.workshop.frames[0][0][0]=1);
    assert.deepEqual(await page.evaluate(async()=>[...(await GrappleAssets.playerCanvas()).getContext('2d').getImageData(0,0,1,1).data]),[255,121,189,255]);
    await page.click('[data-view-tab="map"]');
    await page.click('#playMap');
    await page.waitForFunction(()=>GrapplePlaytest.isOpen);
    await page.click('#closePlay');
    assert.deepEqual(errors,[]);
    console.log('PASS: six hero selections, all 16 poses, display palettes in actual playtest, workshop edits, palette export, map isolation');
  } finally {await browser.close();}
})().catch(e=>{console.error(e);process.exit(1);});
