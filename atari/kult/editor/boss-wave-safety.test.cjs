const assert=require('node:assert/strict'),fs=require('node:fs');const safety=require('./boss-wave-safety.cjs');
(async()=>{const data=await(await fetch('http://127.0.0.1:8772/api/diabolic')).json();const report=safety.verify(data);assert.equal(report.passable,126);
// Negative control: no vertical movement must not satisfy the alternating openings.
for(let p=0;p<=6;p++){const t=safety.trace(data,p,5);assert.equal(safety.route(t,12,56,400),null);}
fs.writeFileSync('/tmp/kult-live-wave-safety.json',JSON.stringify(report,null,2));console.log(`${report.passable} live four-wave routes: full pilot speed, six-update reaction delay, two-pixel clearance, no bomb/shield; replayed without hits.`);
})().catch(e=>{console.error(e);process.exitCode=1});
