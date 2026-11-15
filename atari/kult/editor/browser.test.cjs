const assert=require('node:assert/strict');
const {chromium}=require(process.env.PLAYWRIGHT_MODULE||'playwright');
const fs=require('node:fs/promises');
(async()=>{
 const browser=await chromium.launch({headless:true,executablePath:process.env.CHROMIUM_PATH});
 try{
 const page=await browser.newPage({viewport:{width:1440,height:1050}}),errors=[];page.on('pageerror',e=>errors.push(e.message));
 await page.goto(process.env.EDITOR_URL||'http://127.0.0.1:8772');await page.waitForSelector('main:not([hidden])');
 const bytes=()=>page.evaluate(()=>Array.from(state.banks[asset().bank].slice(asset().offset,asset().offset+asset().width*asset().height*asset().bpp/8)));
 const before=await bytes();const box=await page.locator('#editor').boundingBox();await page.mouse.move(box.x+5,box.y+5);await page.mouse.down();await page.mouse.move(box.x+box.width/3,box.y+box.height/4,{steps:12});await page.mouse.up();
 const painted=await bytes();assert.notDeepEqual(painted,before);await page.click('#undo');assert.deepEqual(await bytes(),before);await page.click('#redo');assert.deepEqual(await bytes(),painted);
 await page.click('#alignments');assert.match(await page.locator('#status').innerText(),/alignment/);
 const projectDownload=page.waitForEvent('download');await page.click('#saveProject');const saved=await projectDownload;const projectPath=await saved.path();const doc=JSON.parse(await fs.readFile(projectPath,'utf8'));assert.equal(doc.game,'kult');assert.ok(Object.keys(doc.edits.ram).length>0);
 await page.click('#clear');await page.setInputFiles('#projectFile',projectPath);await page.waitForFunction(()=>document.getElementById('status').textContent==='Project opened');assert.deepEqual(await bytes(),painted);
 // PNG round-trip uses logical pixels even though the exported preview has wide pixels.
 const pngDownload=page.waitForEvent('download');await page.click('#exportPng');const png=await pngDownload;const pngPath=await png.path();await page.click('#clear');await page.setInputFiles('#pngFile',pngPath);await page.waitForFunction(()=>document.getElementById('status').textContent.startsWith('PNG imported'));assert.deepEqual(await bytes(),painted);
 const exportDownload=page.waitForEvent('download');await page.click('#exportGame');const xex=await exportDownload;assert.equal(xex.suggestedFilename(),'kult-edited.xex');assert.equal((await fs.stat(await xex.path())).size,35097);
 await page.getByRole('button',{name:'CETAS',exact:true}).click();await page.waitForFunction(()=>document.getElementById('assetName').textContent==='Sprite $5428');const cetasBefore=await bytes();await page.click('#flipX');const flipped=await bytes();assert.notDeepEqual(flipped,cetasBefore);await page.click('#undo');assert.deepEqual(await bytes(),cetasBefore);
 await page.selectOption('#category','Pictures');await page.getByRole('listitem',{name:'Title screen',exact:true}).click();const picture=await bytes();await page.click('#clear');await page.click('#undo');assert.deepEqual(await bytes(),picture);
 const bad={format:'kult-cetas-editor',version:1,game:'cetas',edits:{game:{8192:0}}};await page.setInputFiles('#projectFile',{name:'bad.json',mimeType:'application/json',buffer:Buffer.from(JSON.stringify(bad))});await page.waitForFunction(()=>document.getElementById('status').classList.contains('error'));assert.deepEqual(await bytes(),picture);
 await page.click('#flipX');const atrDownload=page.waitForEvent('download');await page.click('#exportGame');const atr=await atrDownload;assert.equal(atr.suggestedFilename(),'cetas-edited.atr');assert.equal((await fs.stat(await atr.path())).size,92176);
 await page.getByRole('button',{name:'Kult',exact:true}).click();await page.waitForFunction(()=>document.getElementById('assetName').textContent.startsWith('Player frame'));assert.deepEqual(await bytes(),painted);
 await page.reload();await page.waitForSelector('main:not([hidden])');assert.deepEqual(await bytes(),painted);
 await page.click('#enemyGallery');assert.equal(await page.locator('.gallery-card').count(),33);assert.equal(await page.locator('.gallery-frames button').count(),132);
 await page.getByRole('button',{name:'Enemy 32 · frame 4',exact:true}).click();assert.equal(await page.evaluate(()=>asset().id),'enemy-31-3');
 const enemyBefore=await bytes();await page.click('#clear');assert.notDeepEqual(await bytes(),enemyBefore);await page.click('#undo');assert.deepEqual(await bytes(),enemyBefore);
 await page.check('#animate');await page.waitForTimeout(300);assert.deepEqual(await page.evaluate(()=>asset().animation),['enemy-31-0','enemy-31-1','enemy-31-2','enemy-31-3']);
 await page.click('#enemyGallery');await page.screenshot({path:'/tmp/kult-enemy-gallery.png'});await page.click('#closeGallery');
 await page.getByRole('button',{name:'CETAS',exact:true}).click();await page.waitForFunction(()=>state.reference.game==='cetas');
 await page.click('#enemyGallery');assert.equal(await page.locator('.gallery-card').count(),17);assert.ok(await page.locator('.gallery-frames button').count()>17);
 await page.locator('.gallery-frames button').first().click();assert.ok(await page.evaluate(()=>asset().objectTypes.includes(2)));
 await page.getByRole('button',{name:'Kult',exact:true}).click();await page.waitForFunction(()=>state.reference.game==='kult');
 await page.screenshot({path:process.env.EDITOR_SCREENSHOT||'/tmp/kult-workshop-tested.png'});
 await page.setViewportSize({width:520,height:900});await page.screenshot({path:'/tmp/kult-workshop-mobile.png'});assert.equal(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),true);
 assert.deepEqual(errors,[]);console.log('Browser paint/drag, undo/redo, alignment copies, project/PNG round-trip, exports, invalid edits, switching, draft restoration and narrow layout passed.');
 }finally{await browser.close();}
})().catch(e=>{console.error(e);process.exitCode=1;});
