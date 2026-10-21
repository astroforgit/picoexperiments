'use strict';
// Single-file release: boot loader + story pictures + the game XEX on one ATR.
const fs=require('fs'),assert=require('assert/strict'),cp=require('child_process');
cp.execFileSync('mads',['boot.asm','-o:generated/boot.bin'],{stdio:'inherit'});
const boot=fs.readFileSync('generated/boot.bin'),xex=fs.readFileSync('city-vbxe.xex');
const story=fs.readFileSync('generated/heroes-story.atr');
const layout=JSON.parse(fs.readFileSync('generated/story-layout.json'));
assert(boot.length<=256,'Boot loader exceeds sectors 1-2');
assert.equal(boot[1],2);
// The loader stops at a segment starting at $0000.
const stream=Buffer.concat([xex,Buffer.from([0,0])]);
const sectorCount=layout.xexSector+Math.ceil(stream.length/256)-1;
const dataBytes=384+(sectorCount-3)*256;
assert(sectorCount<65536);
const disk=Buffer.alloc(16+dataBytes);
story.copy(disk,0,0,Math.min(story.length,16+384+(layout.xexSector-4)*256));
disk.writeUInt16LE((dataBytes/16)&65535,2);disk[6]=(dataBytes/16)>>16;
disk.fill(0,16,16+256);boot.copy(disk,16);
stream.copy(disk,16+384+(layout.xexSector-4)*256);
fs.writeFileSync('city-vbxe.atr',disk);
console.log(`Single-disk release: city-vbxe.atr, ${sectorCount} sectors, game from sector ${layout.xexSector}.`);
