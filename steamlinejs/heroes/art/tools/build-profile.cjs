'use strict';
// Build in an isolated directory; never replace the user's current native executable.
const fs=require('node:fs'),path=require('node:path'),cp=require('node:child_process');
const root=path.resolve(__dirname,'../..'),profile=process.argv[2]||'classic',dest=path.resolve(process.argv[3]||path.join(root,'art/work/native-'+profile));
if(!['classic','vbxe-v2'].includes(profile))throw Error('Profile must be classic or vbxe-v2');
const source=path.join(root,'atari/city');
if(dest===source||source.startsWith(dest+path.sep)||dest.startsWith(source+path.sep))throw Error('Build destination must be isolated from source');
fs.mkdirSync(dest,{recursive:true});
for(const entry of fs.readdirSync(source,{withFileTypes:true})){
 if(['generated','city-vbxe.xex'].includes(entry.name))continue;
 fs.cpSync(path.join(source,entry.name),path.join(dest,entry.name),{recursive:true});
}
const env={...process.env,HEROES_ART_PROFILE:profile,HEROES_UNIT_SOURCE:path.join(root,'assets/unit-previews')};
// Make build.sh use the same supported Node executable as this script.
env.PATH=path.dirname(process.execPath)+path.delimiter+env.PATH;
cp.execFileSync('sh',['build.sh'],{cwd:dest,env,stdio:'inherit'});
console.log('Isolated '+profile+' executable: '+path.join(dest,'city-vbxe.xex'));
