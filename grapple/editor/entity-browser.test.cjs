const assert=require('assert/strict');
const {chromium}=require(process.env.PLAYWRIGHT_MODULE || 'playwright');
(async()=>{
const b=await chromium.launch({headless:true});const page=await b.newPage();const errors=[];page.on('pageerror',e=>errors.push(e.message));
await page.goto(process.env.EDITOR_URL || 'http://127.0.0.1:8090/grapple/editor/?world=/steamlinejs/world.json');
await page.waitForFunction(()=>mapCells.some(c=>c.tile===17));
const count=await page.evaluate(()=>mapCells.filter(c=>c.tile===13).length);assert.equal(count,8);
for(const tile of [13,17]){
 await page.evaluate(tile=>{const c=mapCells.find(c=>c.tile===tile);selectedEntityIndex=c.index;selectedTile=tile;updateEntityInspector();},tile);
 await page.fill('#entityId',`test-brick-${tile}`);await page.locator('#entityId').dispatchEvent('change');
 await page.fill('#entitySpeed',tile===13?'80':'100');await page.locator('#entitySpeed').dispatchEvent('change');
 if(tile===13)await page.selectOption('#entityDirection','3');
 const result=await page.evaluate(()=>{const c=currentSettingsCell();const saved=serializeMap();const loaded=validateAndNormalizeMap(saved).cells[c.index];return {c,loaded};});
 assert.equal(result.c.id,`test-brick-${tile}`);assert.equal(result.c.speed,tile===13?80:100);assert.deepEqual(result.c,result.loaded);
 if(tile===13)assert.equal(result.c.rot,3);
 await page.evaluate(()=>{undo();redo();});
 assert.equal(await page.inputValue('#entityId'),`test-brick-${tile}`);
}
const ids=await page.evaluate(()=>mapCells.filter(c=>c.tile>=0).map(c=>c.id));assert.equal(new Set(ids).size,ids.length);
assert.deepEqual(errors,[]);console.log('PASS: editor IDs, mover direction/speed, chase speed, undo/redo and JSON round-trip');await b.close();
})().catch(e=>{console.error(e);process.exit(1)});
