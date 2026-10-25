// Run against serve.py with EDITOR_URL; PLAYWRIGHT_MODULE and CHROMIUM_PATH are optional.
const assert = require('node:assert/strict');
const { chromium } = require(process.env.PLAYWRIGHT_MODULE || 'playwright');
(async () => {
  const browser = await chromium.launch({ headless: true, executablePath: process.env.CHROMIUM_PATH });
  try {
    const page = await browser.newPage();
    const errors = []; page.on('pageerror', e => errors.push(e.message));
    await page.goto(process.env.EDITOR_URL || 'http://127.0.0.1:8765');
    if (page.url().startsWith('file:')) await page.setInputFiles('#fileInput', require('node:path').join(__dirname, '../Zorro (1985)(Datasoft)(US).xex'));
    await page.waitForFunction(() => !document.querySelector('#importMchBtn').disabled);
    const before = await page.evaluate(() => Array.from(file));
    const bytes = Buffer.alloc(12000); bytes[0] = 5;
    for (let c = 0; c < 5; c++) bytes.fill(c * 32, 10800 + c * 240, 10800 + (c + 1) * 240);
    const upload = buffer => page.setInputFiles('#mchInput', { name:'test.mch', mimeType:'application/octet-stream', buffer });
    await upload(bytes);
    await page.getByRole('button', {name:'Cancel', exact:true}).click();
    assert.deepEqual(await page.evaluate(() => Array.from(file)), before);
    await upload(bytes);
    await page.getByRole('button', {name:'Apply to room', exact:true}).click();
    assert.equal(await page.locator('dialog').count(), 0);
    assert.equal(await page.evaluate(() => decodeMap(roomMapAddr(room)).cells.length), 880);
    const after = await page.evaluate(() => Array.from(file));
    assert.notDeepEqual(after, before);
    await page.click('#undoBtn');
    assert.deepEqual(await page.evaluate(() => Array.from(file)), before);
    await page.click('#redoBtn');
    assert.deepEqual(await page.evaluate(() => Array.from(file)), after);
    await upload(Buffer.from('invalid'));
    assert.equal(await page.getByRole('button', {name:'Apply to room', exact:true}).isDisabled(), true);
    await page.getByRole('button', {name:'Cancel', exact:true}).click();
    assert.deepEqual(await page.evaluate(() => Array.from(file)), after);
    // An image with two alternating tiles fits the tile budget but overflows the map.
    for (let cell=0; cell<1200; cell++) bytes.fill(cell % 2 ? 0x55 : 0, cell*9+1, cell*9+9);
    await upload(bytes);
    assert.equal(await page.getByRole('button', {name:'Apply to room', exact:true}).isDisabled(), true);
    assert.match(await page.locator('dialog [role=status]').innerText(), /Map needs/);
    await page.getByRole('button', {name:'Cancel', exact:true}).click();
    assert.deepEqual(await page.evaluate(() => Array.from(file)), after);
    const native = require('./g2f.fixture.cjs')();
    const zipped = Buffer.concat([Buffer.from('G2FZLIB'), require('node:zlib').deflateSync(native)]);
    for (const buffer of [native, zipped]) {
      const previous = await page.evaluate(() => Array.from(file));
      await page.setInputFiles('#mchInput', {name:'native.G2F',mimeType:'application/octet-stream',buffer});
      assert.equal(await page.locator('#mchWidth').isDisabled(), true);
      assert.equal(await page.locator('#mchX').inputValue(), '1');
      await page.getByRole('button', {name:'Apply to room',exact:true}).click();
      const imported = await page.evaluate(() => Array.from(file));
      assert.notDeepEqual(imported, previous);
      await page.click('#undoBtn');
      assert.deepEqual(await page.evaluate(() => Array.from(file)),previous);
    }
    await page.setInputFiles('#mchInput', {name:'bad.g2f',mimeType:'application/octet-stream',buffer:Buffer.from('G2FZLIBbad')});
    assert.match(await page.locator('#status').innerText(), /Invalid or unsupported G2F/);
    assert.equal(await page.locator('dialog').count(),0);
    assert.deepEqual(await page.evaluate(() => Array.from(file)), after);
    // Native drag and drop follows the image importer rather than the XEX reader.
    await page.evaluate(data => {
      const transfer = new DataTransfer();
      transfer.items.add(new File([new Uint8Array(data)], 'dropped.g2f'));
      document.dispatchEvent(new DragEvent('drop', {dataTransfer:transfer,bubbles:true,cancelable:true}));
    }, Array.from(zipped));
    await page.getByRole('button', {name:'Cancel',exact:true}).click();
    assert.deepEqual(errors, []);
    console.log('Browser MCH/G2F preview, apply, cancel, undo, compressed projects, drop, malformed input and map overflow passed.');
  } finally { await browser.close(); }
})().catch(e => { console.error(e); process.exitCode=1; });
