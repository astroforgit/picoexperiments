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
 const sprite=page.locator('#spriteCanvas'),r=await sprite.boundingBox();await page.mouse.click(r.x+r.width*.25,r.y+r.height*.5);let edited=(await page.evaluate(()=>StarEditor.getScene())).assets.at(-1);assert.equal(edited.pixels[0],250);
 await page.keyboard.press('Control+z');assert.equal((await page.evaluate(()=>StarEditor.getScene())).assets.at(-1).pixels[0],252);
 await page.keyboard.press('Control+Shift+z');assert.equal((await page.evaluate(()=>StarEditor.getScene())).assets.at(-1).pixels[0],250);
 await page.click('#closeSprite');await page.selectOption('#gameStar',editedId);
 // Sky controls persist, undo, validate, and drive the native build.
 await page.click('[data-tab="sky"]');
 for(const [id,value] of Object.entries({onePixelStars:12,twoPixelStars:7,twinklePercent:60,meteorProbability:100})){await page.fill('#'+id,String(value));await page.locator('#'+id).blur();}
 assert.deepEqual((await page.evaluate(()=>StarEditor.getScene())).sky,{onePixelStars:12,twoPixelStars:7,twinklePercent:60,meteorProbability:100,starColor:'ivory',starRgb:[200,220,255]});
 await page.click('#undo');assert.equal((await page.evaluate(()=>StarEditor.getScene())).sky.meteorProbability,30);await page.click('#redo');
 await page.selectOption('#starColor','moon');assert.equal((await page.evaluate(()=>StarEditor.getScene())).sky.starColor,'moon');
 assert.deepEqual((await page.evaluate(()=>StarEditor.getPalette())).slice(246*3,247*3),[246,232,204],'moon tone previews in slot 246');
 await page.click('#undo');await page.click('#redo');
 await page.click('[data-tab="fishing"]');
 await page.fill('[data-scenario="attack"][data-field="catch"]','60');await page.locator('[data-scenario="attack"][data-field="catch"]').blur();
 await page.fill('[data-scenario="interest"][data-field="weight"]','50');await page.locator('[data-scenario="interest"][data-field="weight"]').blur();
 await page.uncheck('#springGauge');
 let fishing=(await page.evaluate(()=>StarEditor.getScene())).fishing;assert.equal(fishing.scenarios.attack.catch,60);assert.equal(fishing.scenarios.interest.weight,50);assert.equal(fishing.springGauge,false);
 await page.locator("#floatRows details").filter({has:page.locator('[data-scenario="sideTake"]')}).locator("summary").click();
 await page.fill('[data-scenario="sideTake"][data-field="catch"]','101');await page.locator('[data-scenario="sideTake"][data-field="catch"]').blur();assert.equal((await page.evaluate(()=>StarEditor.getScene())).fishing.scenarios.sideTake.catch,50);
 await page.click('[data-tab="sound"]');await page.waitForFunction(()=>/^Samples/.test(document.getElementById('sampleUsage').textContent));
 await page.selectOption('#windMode','synth');await page.fill('#wind-volume','9');await page.locator('#wind-volume').blur();await page.selectOption('#windMode','recorded');
 await page.click('#addClip');await page.fill('[data-clip="3"] [data-field="perTenMinutes"]','30');await page.locator('[data-clip="3"] [data-field="perTenMinutes"]').blur();
 await page.fill('[data-clip="3"] [data-field="gain"]','300');await page.locator('[data-clip="3"] [data-field="gain"]').blur();
 await page.selectOption('#sampleRate','15');
 let sound=(await page.evaluate(()=>StarEditor.getScene())).sound;assert.equal(sound.wind.volume,9);assert.equal(sound.samples.wind.mode,'recorded');assert.equal(sound.samples.clips.length,4);assert.equal(sound.samples.clips[3].perTenMinutes,30);assert.equal(sound.samples.clips[3].gain,100);assert.equal(sound.samples.rate,15);
 // Dragging on the close-up selects exactly what plays.
 await page.waitForFunction(f=>document.getElementById('soundPicker').dataset.ready===f,sound.samples.clips[3].file,{timeout:60000});
 const before=sound.samples.clips[3];const wave=await page.locator('#waveDetail').boundingBox();await page.mouse.move(wave.x+wave.width*.3,wave.y+20);await page.mouse.down();await page.mouse.move(wave.x+wave.width*.7,wave.y+20,{steps:5});await page.mouse.up();
 const after=(await page.evaluate(()=>StarEditor.getScene())).sound.samples.clips[3];assert(after.start!==before.start||after.length!==before.length,'drag selects a new region');assert(after.length>=.1&&after.length<=8);
 const previewResponse=page.waitForResponse(r=>r.url().endsWith('/api/sample-preview'));await page.click('#playSelected');assert.equal((await previewResponse).status(),200);await page.waitForFunction(()=>/Playing .* as the Atari plays it/.test(document.getElementById('status').textContent));
 await page.click('#stopSound');
 await page.click('[data-tab="sky"]');
 await page.fill('#onePixelStars','97');await page.locator('#onePixelStars').blur();assert.equal((await page.evaluate(()=>StarEditor.getScene())).sky.onePixelStars,12);
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
