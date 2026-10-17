const assert=require('node:assert/strict');
const fs=require('node:fs');
const root=require('node:path').resolve(__dirname,'..');
const api=require(root+'/editor-balance.js');
const data=JSON.parse(fs.readFileSync(root+'/greenhaven-unit-balance.json'));
const clone=x=>JSON.parse(JSON.stringify(x));
assert.deepEqual(api.validate(data),[]);
for(let r=0;r<4;r++)for(let s=0;s<3;s++)for(let seed=0;seed<1000;seed++){
 const a=api.generate(data,r,s,seed),b=api.generate(data,r,s,seed);
 assert.deepEqual(a,b);assert(a.enemies.length>=1&&a.enemies.length<=5);
 assert.equal(new Set(a.enemies.map(x=>x.cell)).size,a.enemies.length);
 assert(a.enemies.every(x=>!a.terrain.includes(x.cell)&&!a.playerCells.includes(x.cell)));
 if(r===3&&s===2)assert.equal(a.victory,'Defeat the Warlock');else assert(a.enemies.every(x=>x.id!=='warlock'));
}
let c=clone(data);c.encounterConfig.regions[0].stages[0].variants.forEach(x=>x.weight=0);assert(api.validate(c).length);
c=clone(data);c.encounterConfig.regions[0].stages[0].variants[0].enemies=['unknown'];assert(api.validate(c).length);
c=clone(data);c.encounterConfig.regions[0].stages[0].variants[0].weight=0;for(let seed=0;seed<200;seed++)assert.notEqual(api.generate(c,0,0,seed).variant,0);
c=clone(data);c.encounterConfig.regions[0].stages[0].variants[0].weight=8;const count=[0,0,0];for(let seed=0;seed<10000;seed++)count[api.generate(c,0,0,seed).variant]++;assert(count[0]>7700&&count[0]<8300);
assert.equal(api.generate(data,0,2,0,true).reward,30);assert.throws(()=>api.generate(data,0,0,0,true));
assert.equal(api.generate(data,0,0,0xffffffff).seed,0xffffffff);
console.log('PASS: 12,000 deterministic encounters, valid deployments, boss constraints, disabled groups, weighted frequencies, replay rewards and seeds.');

const html=fs.readFileSync(root+'/unit-editor.html','utf8');
assert.equal(html.match(/<script id="encounter-rules">\n([\s\S]*?)\n<\/script>/)[1], fs.readFileSync(root+'/editor-balance.js','utf8'));
const defaults=JSON.parse(html.match(/<script id="initial-data" type="application\/json">([\s\S]*?)<\/script>/)[1]);
assert.deepEqual(defaults,data);
const legacy=JSON.parse(html.match(/<script id="legacy-data" type="application\/json">([\s\S]*?)<\/script>/)[1]);
assert.deepEqual(api.validate(legacy),[]);
const crypto=require('node:crypto');
const backup=root+'/backups/before-balance-2026-10-17/';
for(const [file,hash] of Object.entries(JSON.parse(fs.readFileSync(backup+'checksums.json'))))assert.equal(crypto.createHash('sha256').update(fs.readFileSync(backup+file)).digest('hex'),hash);
assert.equal(crypto.createHash('sha256').update(fs.readFileSync(root+'/atari/city/content.json')).digest('hex'),JSON.parse(fs.readFileSync(backup+'checksums.json'))['atari/city/content.json']);
console.log('PASS: standalone editor/data parity, legacy configuration, exact backup hashes and untouched native content.');
