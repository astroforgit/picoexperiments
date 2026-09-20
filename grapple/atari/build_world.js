"use strict";
// Build in a separate directory so custom worlds never overwrite the default game.
const fs = require('fs'), path = require('path'), cp = require('child_process');
const source = path.resolve(process.argv[2] || path.join(__dirname, '../../steamlinejs/world.json'));
const destination = path.resolve(process.argv[3] || 'build/world');
const name = process.argv[4] || 'grapple-world-vbxe';
if (!/^[a-z0-9-]+$/.test(name)) throw Error('Use a simple lowercase build name');
fs.mkdirSync(destination, {recursive: true});
const env = {...process.env, WORLD_PATH: source, BUILD_DIR: destination};
function run(command, args, cwd = __dirname) {
  const result = cp.spawnSync(command, args, {cwd, env, stdio: 'inherit'});
  if (result.error) throw result.error;
  if (result.status !== 0) process.exit(result.status || 1);
}
run(process.execPath, [path.join(__dirname, 'generate_assets.js')]);
for (const file of ['grapple-vbxe.asm', 'fidelity.asm'])
  fs.copyFileSync(path.join(__dirname, file), path.join(destination, file));
run('mads', ['grapple-vbxe.asm', '-o:grapple-vbxe.xex', '-t:grapple-vbxe.lab', '-l:grapple-vbxe.lst'], destination);
run(process.execPath, [path.join(__dirname, 'verify_build.js')]);
fs.copyFileSync(source, path.join(destination, 'world.json'));
fs.copyFileSync(path.join(destination, 'grapple-vbxe.xex'), path.join(destination, name + '.xex'));
console.log('Built ' + path.join(destination, name + '.xex'));
