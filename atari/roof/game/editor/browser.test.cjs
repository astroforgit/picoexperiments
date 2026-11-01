const assert=require('node:assert/strict');
const {chromium}=require(process.env.PLAYWRIGHT_MODULE||'playwright');
(async()=>{
 const browser=await chromium.launch({headless:true,executablePath:process.env.CHROMIUM_PATH,args:['--no-sandbox']});
 try{
 const page=await browser.newPage({viewport:{width:1440,height:1050}}),errors=[];
 page.on('pageerror',e=>errors.push(e.message));page.on('dialog',d=>d.accept());
 await page.goto(process.env.EDITOR_URL||'http://127.0.0.1:8792');await page.waitForFunction(()=>window.StarEditor);
 const initial=await page.evaluate(()=>StarEditor.getScene());
 assert.equal(await page.locator('#screen').getAttribute('width'),'320');
 const exact=await page.evaluate(()=>{const c=document.getElementById('screen').getContext('2d').getImageData(0,0,320,240).data,p=StarEditor.getPixels(),pal=StarEditor.getPalette();return p.every((v,i)=>c[i*4]===pal[v*3]&&c[i*4+1]===pal[v*3+1]&&c[i*4+2]===pal[v*3+2]);});assert(exact,'canvas must use exact palette RGB values');
 async function clickPixel(x,y,button='left'){const r=await page.locator('#screen').boundingBox();await page.mouse.click(r.x+(x+.5)*r.width/320,r.y+(y+.5)*r.height/240,{button});}
 await clickPixel(266,214);let s=await page.evaluate(()=>StarEditor.getScene());assert(s.windows[0].pixels.some(p=>p[0]===266&&p[1]===214));
 await page.click('#undo');assert.deepEqual(await page.evaluate(()=>StarEditor.getScene()),initial);
 await page.click('#redo');await clickPixel(266,214,'right');assert.equal((await page.evaluate(()=>StarEditor.getScene())).windows[0].pixels.length,initial.windows[0].pixels.length);
 await page.click('#focusWindow');assert.equal(await page.locator('#zoom').inputValue(),'8');await page.waitForFunction(()=>document.getElementById('viewport').scrollLeft>1000);await clickPixel(266,215);assert((await page.evaluate(()=>StarEditor.getScene())).windows[0].pixels.some(p=>p[0]===266&&p[1]===215));await page.click('#undo');
 await page.selectOption('#zoom','2');await page.evaluate(()=>{document.getElementById('viewport').scrollTo(0,0)});
 await page.click('#addWindow');await page.fill('#windowName','Test facade');await page.locator('#windowName').blur();await page.selectOption('#windowMode','steady');await clickPixel(200,200);
 assert.equal((await page.evaluate(()=>StarEditor.getScene())).windows.length,7);
 await page.click('[data-tab="library"]');await page.click('[data-category="moons"]');
 const source=page.locator('[data-asset="moon-crescent"]');
 await source.dragTo(page.locator('#screen'),{targetPosition:{x:160*2,y:60*2}});
 await page.waitForFunction(()=>StarEditor.getScene().stamps.length===1);
 let st=(await page.evaluate(()=>StarEditor.getScene())).stamps[0];assert.equal(st.assetId,'moon-crescent');
 await page.locator('#screen').focus();await page.keyboard.press('ArrowRight');assert.equal((await page.evaluate(()=>StarEditor.getScene())).stamps[0].x,st.x+1);
 await page.click('#duplicateStamp');assert.equal((await page.evaluate(()=>StarEditor.getScene())).stamps.length,2);await page.click('#undo');assert.equal((await page.evaluate(()=>StarEditor.getScene())).stamps.length,1);
 await page.click('[data-tab="library"]');await page.click('[data-category="stars"]');await page.locator('[data-asset="star-pin"]').dblclick();await page.waitForSelector('#spriteDialog[open]');
 await page.click('#copySprite');const editedId=await page.evaluate(()=>StarEditor.getScene().assets.at(-1).id);
 const sprite=page.locator('#spriteCanvas'),r=await sprite.boundingBox();await page.mouse.click(r.x+r.width*.75,r.y+r.height*.75);let edited=(await page.evaluate(()=>StarEditor.getScene())).assets.at(-1);assert.equal(edited.pixels[3],250);
 await page.keyboard.press('Control+z');assert.equal((await page.evaluate(()=>StarEditor.getScene())).assets.at(-1).pixels[3],0);
 await page.keyboard.press('Control+Shift+z');assert.equal((await page.evaluate(()=>StarEditor.getScene())).assets.at(-1).pixels[3],250);
 await page.click('#closeSprite');await page.selectOption('#gameStar',editedId);
 // Export and import are round trips, not a lossy screenshot format.
 const project=await page.evaluate(()=>StarEditor.getScene());
 const downloadPromise=page.waitForEvent('download');await page.click('#exportBtn');const download=await downloadPromise;assert.equal(download.suggestedFilename(),'star-fisher-project.json');
 await page.setInputFiles('#importFile',{name:'project.json',mimeType:'application/json',buffer:Buffer.from(JSON.stringify(project))});assert.deepEqual(await page.evaluate(()=>StarEditor.getScene()),project);
 await page.setInputFiles('#importFile',{name:'invalid.json',mimeType:'application/json',buffer:Buffer.from('{"version":99}')});assert.match(await page.locator('#status').innerText(),/Invalid/);assert.deepEqual(await page.evaluate(()=>StarEditor.getScene()),project);
 const saveResponse=page.waitForResponse(r=>r.url().endsWith('/api/save'));await page.click('#saveBtn');assert.equal((await saveResponse).status(),200);await page.waitForFunction(()=>document.getElementById('savedState').textContent==='Saved project');
 const buildResponse=page.waitForResponse(r=>r.url().endsWith('/api/build'),{timeout:120000});await page.click('#buildBtn');const br=await buildResponse;assert.equal(br.status(),200,await br.text());await page.waitForFunction(()=>document.getElementById('status').textContent.includes('Build complete'),null,{timeout:120000});
 assert.equal(await page.locator('#nativeView').getAttribute('class'),'active');
 await page.click('#editView');await page.click('[data-tab="library"]');await page.click('[data-category="comets"]');
 if(process.env.SCREENSHOT_PATH)await page.screenshot({path:process.env.SCREENSHOT_PATH});
 await page.reload();await page.waitForFunction(()=>window.StarEditor);assert.deepEqual(await page.evaluate(()=>StarEditor.getScene()),project,'saved project persists');
 assert.deepEqual(errors,[]);console.log('PASS exact palette canvas, zoomed painting/erase, undo/redo, new windows, drag/drop, nudge, duplicate, sprite edit, project import/export, save, native build and reload');
 }finally{await browser.close();}
})().catch(e=>{console.error(e);process.exit(1)});
