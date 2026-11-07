// The same cycle-based POKEY emulator used by the local Atari sound tool.
// Feed register-only frames through a tiny SAP player: no music is loaded.
import {ASAP,ASAPSampleFormat} from './vendor/asap.js';
const PAL_CLOCK=1773447,FRAME_CYCLES=312*114;
export function registerSap(frames){
 if(frames.length>6000)throw Error('Audio preview is too long.');
 // INIT $2000: pointer=$2100; normal 64kHz POKEY clock; enable noise counters.
 const init=[0xa9,0,0x85,0xf0,0xa9,0x21,0x85,0xf1,0xa9,0,0x8d,8,0xd2,0xa9,3,0x8d,15,0xd2,0x60];
 // PLAYER $2020: one flag + eight AUDF/AUDC bytes; zero flag means silence.
 const player=[0xa0,0,0xb1,0xf0,0xf0,0x1a,0xc8,0xa2,0,0xb1,0xf0,0x9d,0,0xd2,0xc8,0xe8,0xe0,8,0xd0,0xf5,0x18,0xa5,0xf0,0x69,9,0x85,0xf0,0x90,2,0xe6,0xf1,0x60,0xa9,0,0x8d,1,0xd2,0x8d,3,0xd2,0x8d,5,0xd2,0x8d,7,0xd2,0x60];
 const body=new Uint8Array(0x100+frames.length*9+1);body.set(init);body.set(player,0x20);
 frames.forEach((regs,i)=>{if(regs.length!==4||regs.some(c=>c.length!==2||c.some(v=>!Number.isInteger(v)||v<0||v>255)))throw Error('Expected four POKEY register pairs.');body[0x100+i*9]=1;body.set(regs.flat(),0x101+i*9);});
 const header=new TextEncoder().encode('SAP\r\nAUTHOR ""\r\nNAME "Star Fisher effects"\r\nDATE "2026"\r\nTYPE B\r\nINIT 2000\r\nPLAYER 2020\r\nFASTPLAY 312\r\n');
 const end=0x2000+body.length-1,out=new Uint8Array(header.length+6+body.length);out.set(header);out.set([255,255,0,0x20,end&255,end>>8],header.length);out.set(body,header.length+6);return out;
}
export function render(frames,rate=44100){
 if(!frames.length)return new Float32Array();
 const asap=new ASAP(),sap=registerSap(frames);asap.setSampleRate(rate);asap.load('effects.sap',sap,sap.length);asap.playSong(0,-1);
 const count=Math.ceil(frames.length*FRAME_CYCLES/PAL_CLOCK*rate),pcm=new Uint8Array(count*2),out=new Float32Array(count);
 const written=asap.generate(pcm,pcm.length,ASAPSampleFormat.S16_L_E),view=new DataView(pcm.buffer);
 for(let i=0;i<written/2;i++)out[i]=view.getInt16(i*2,true)/32768;
 return out;
}
let context,source;
export function play(samples,rate=44100,loop=false){
 stop();context??=new AudioContext({sampleRate:rate});context.resume();
 const buffer=context.createBuffer(1,samples.length,rate);buffer.copyToChannel(samples,0);
 source=context.createBufferSource();source.buffer=buffer;source.loop=loop;source.connect(context.destination);source.start();return samples.length/rate;
}
// 4-bit volume-only levels (0-15) at the POKEY timer rate, sample-and-hold to 44.1 kHz.
export function pcm(levels,rate,repeat=1,out=44100,maximum=15){
 const n=Math.floor(levels.length*repeat*out/rate),y=new Float32Array(n);
 for(let i=0;i<n;i++)y[i]=(levels[Math.floor(i*rate/out)%levels.length]/maximum-.5);
 return y;
}
export async function playEncoded(bytes){
 stop();context??=new AudioContext({sampleRate:44100});context.resume();
 const buffer=await context.decodeAudioData(bytes);source=context.createBufferSource();source.buffer=buffer;source.connect(context.destination);source.start();return buffer.duration;
}
export function stop(){try{source?.stop();}catch{}source=null;}
// Match sound.asm's single LFSR, VBI ordering, pitch variation and effect delay.
export function nightFrames(preview,seconds,{windOnly=false}={}){
 const frames=[];let seed=0x5b,phase=0,wobble=0,fx=null,at=0,shift=0,lastA=0,lastB=0;
 const random=()=>{seed=((seed<<1)^((seed&128)?29:0))&255;return seed;};
 for(let f=1;f<=Math.round(seconds*50);f++){
  phase=(phase+preview.wind.speed*16)&65535;const i=(phase>>8)&63;
  if(f%4===0)wobble=(random()&15)%(preview.wind.flutter+1);
  let a=[lastA,0],b=[lastB,0];
  // An effect remains active for its terminating zero record, too.
  if(fx){if(at<fx.length){const [f1,c1,f2,c2]=fx[at++];a=[(f1+shift)&255,c1];b=[(f2+shift)&255,c2];lastA=a[0];lastB=b[0];}else fx=null;}
  if(f%50===0&&!fx&&!windOnly){const r=random(),j=preview.chances.findIndex(c=>r<c);if(j>=0){fx=preview.effects[preview.order[j]];at=0;shift=(random()&15)%(preview.variation[j]+1);}}
  frames.push([a,b,[0,0],[Math.min(255,preview.wind.freq[i]+wobble),preview.wind.volume[i]?0x80|preview.wind.volume[i]:0]]);
 }
 return frames;
}
export function windFrames(wind,count){return nightFrames({wind},count/50,{windOnly:true}).map(f=>f[3]);}
