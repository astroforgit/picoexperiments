/* Original code-drawn pixel sprites. No generated images or borrowed sprite frames.
   Pose 0..3 = walking, 4 = attack wind-up, 5 = strike, 6 = idle.
   Every roster ID owns a silhouette/equipment/palette definition. */
const PIXEL_UNITS={
 'barracks-1':{body:'#90744c',trim:'#c6b18a',weapon:'knife',hat:'hair',shield:'buckler'},
 'barracks-2':{body:'#316eb3',trim:'#d8b75d',weapon:'spear',hat:'helmet',shield:'round',armor:true},
 'barracks-3':{body:'#a32d48',trim:'#ffd477',weapon:'sword',hat:'plume',shield:'kite',armor:true,cape:true},
 'archery-1':{body:'#99764d',trim:'#bfa47b',weapon:'shortbow',hat:'cap',quiver:true},
 'archery-2':{body:'#388454',trim:'#d5bb71',weapon:'bow',hat:'hood',quiver:true,cape:true},
 'archery-3':{body:'#344d98',trim:'#e3dbea',weapon:'crossbow',hat:'feather',quiver:true,armor:true},
 'lodge-1':{body:'#478b86',trim:'#9de0b3',weapon:'knife',hat:'scarf',cape:true},
 'lodge-2':{body:'#677d36',trim:'#cfb26d',weapon:'axe',hat:'hood',cape:true,quiver:true},
 'lodge-3':{body:'#815a36',trim:'#e6d6b2',weapon:'doubleaxe',hat:'antlers',fur:true,large:true},
 'chapel-1':{body:'#d7c6a0',trim:'#8fbdb7',weapon:'candle',hat:'tonsure',robe:true},
 'chapel-2':{body:'#e8e0b6',trim:'#409b95',weapon:'staff',hat:'veil',robe:true,satchel:true},
 'chapel-3':{body:'#e2ce82',trim:'#ae3869',weapon:'mace',hat:'mitre',robe:true,cape:true,armor:true},
 'tower-1':{body:'#695896',trim:'#b1a2d6',weapon:'wand',hat:'hair',robe:true,satchel:true},
 'tower-2':{body:'#2456a0',trim:'#8dd9e5',weapon:'orb',hat:'hood',robe:true,cape:true},
 'tower-3':{body:'#503194',trim:'#f5cd62',weapon:'staff',hat:'point',robe:true,cape:true,beard:true},
 minibeast:{kind:'beast',body:'#9a6245',trim:'#e5aa72',small:true},
 wolf:{kind:'wolf',body:'#748ba3',trim:'#d7e2dd'},
 bat:{kind:'bat',body:'#493864',trim:'#b482aa'},
 skeleton:{body:'#cdc8a8',trim:'#ede8d3',weapon:'bow',hat:'skull',bones:true},
 zombie:{body:'#475e49',trim:'#8caa6a',weapon:'hands',hat:'bald',skin:'#829567',ragged:true},
 'bone-archer':{body:'#77705f',trim:'#e1d2b0',weapon:'crossbow',hat:'skullhood',bones:true,quiver:true,cape:true},
 ogre:{body:'#755334',trim:'#b79a5c',weapon:'club',hat:'bald',skin:'#98a064',large:true,fur:true},
 warlock:{body:'#382147',trim:'#c467eb',weapon:'staff',hat:'hornhood',robe:true,cape:true,skin:'#c0b2b5'},
 imp:{kind:'imp',body:'#cf6639',trim:'#ffc55b',small:true},
 beast:{kind:'beast',body:'#665084',trim:'#b89fc4'},
 dark:{body:'#283348',trim:'#a64075',weapon:'sword',hat:'hornhelm',shield:'kite',armor:true,cape:true},
 demon:{kind:'demon',body:'#a72c3f',trim:'#ea8354',weapon:'claw'},
 sniper:{body:'#454f36',trim:'#aecc79',weapon:'longbow',hat:'hood',quiver:true,cape:true,mask:true}
};
function drawPixelUnit(canvas,id,pose){
 const u=PIXEL_UNITS[id];if(!u)throw Error('Missing pixel design: '+id);
 const c=canvas.getContext('2d');c.clearRect(0,0,canvas.width,canvas.height);c.imageSmoothingEnabled=false;
 // Draw into integer coordinates for crisp pixel clusters at display resolution.
 c.save();c.translate(12,3);const ink='#111923',steel='#8298ad',light='#dce5e5',gold=u.trim,skin=u.skin||'#d5a77f';
 const walk=pose<4,wind=pose===4,strike=pose===5;
 const step=walk?[3,0,-3,0][pose]:0,bob=walk&&(pose===1||pose===3)?1:0;
 const rect=(x,y,w,h,col)=>{c.fillStyle=col;c.fillRect(Math.round(x),Math.round(y),w,h)};
 const poly=(pts,col)=>{c.fillStyle=col;c.beginPath();pts.forEach(([x,y],i)=>i?c.lineTo(x,y):c.moveTo(x,y));c.closePath();c.fill()};
 const line=(pts,col,width=2)=>{c.strokeStyle=col;c.lineWidth=width;c.lineJoin='miter';c.beginPath();pts.forEach(([x,y],i)=>i?c.lineTo(x,y):c.moveTo(x,y));c.stroke()};
 const limb=(pts,col,w=5)=>{line(pts,ink,w+2);line(pts,col,w);line(pts.map(([x,y])=>[x-1,y]),gold,1)};
 const eye=(x,y)=>{rect(x,y,3,2,'#f4df8c');rect(x+2,y,1,2,ink)};
 c.translate(0,bob);
 if(['wolf','beast','bat','imp','demon'].includes(u.kind)){
  if(u.kind==='wolf'){
   const leap=strike?6:0;c.translate(leap,0);
   poly([[9,49],[0,40],[3,52],[13,58]],ink);poly([[9,49],[2,43],[6,52],[14,55]],u.body);
   for(const [x,sg] of [[19,1],[42,-1]]){limb([[x,54],[x+step*sg,63],[x+step*sg+3,73]],u.body,4);rect(x+step*sg,72,9,3,ink)}
   poly([[9,48],[18,40],[42,43],[52,36],[60,40],[67,49],[57,55],[43,56],[20,60],[12,55]],ink);
   poly([[12,48],[21,43],[41,46],[52,39],[58,42],[62,49],[53,51],[40,53],[22,57],[15,53]],u.body);
   poly([[22,44],[37,46],[43,51],[25,51]],u.trim);poly([[46,42],[47,30],[54,40]],ink);poly([[49,40],[49,34],[52,41]],u.trim);eye(55,44);rect(63,48,5,3,ink);if(strike){rect(58,53,9,3,'#a2394b');rect(62,52,2,3,light)}
  }else if(u.kind==='bat'){
   const flap=walk?[0,-7,2,7][pose]:wind?-9:strike?7:0;
   for(const sign of [-1,1]){const X=x=>35+sign*x;poly([[35,42],[X(14),28+flap],[X(31),24+flap],[X(28),44],[X(21),38+flap],[X(17),50],[X(9),44],[35,56]],ink);poly([[35,43],[X(14),31+flap],[X(28),28+flap],[X(22),38],[X(17),46],[X(9),41],[35,52]],u.body);line([[35,44],[X(14),32+flap],[X(23),36+flap]],u.trim,2)}
   poly([[28,36],[27,24],[34,32],[40,25],[42,39],[43,55],[36,64],[29,55]],ink);rect(30,38,11,18,u.body);rect(32,41,3,2,'#ffb159');rect(38,41,3,2,'#ffb159');rect(33,48,2,3,light);rect(38,48,2,3,light);
  }else{
   const small=u.small,top=small?38:24,left=small?25:19,right=small?43:49;
   if(u.kind==='imp'||u.kind==='demon'){
    line([[left,57],[left-13,64],[left-17,52]],ink,5);line([[left,57],[left-13,64],[left-17,52]],u.body,3);
    if(!small)for(const sign of [-1,1])poly([[34,35],[34+sign*19,18],[34+sign*28,38],[34+sign*18,34],[34+sign*12,49]],'#4b263b');
   }
   limb([[left+5,57],[left+step,66],[left+step-2,74]],u.body,small?4:7);limb([[right-6,57],[right-step,66],[right-step+2,74]],u.body,small?4:7);
   poly([[left,top+8],[right-5,top+5],[right+2,58],[right-8,64],[left-3,57]],ink);poly([[left+2,top+10],[right-7,top+7],[right-2,56],[right-8,60],[left+1,55]],u.body);
   limb([[right-5,top+13],[right+5,wind?top-2:top+22],[strike?right+19:right+5,strike?top+9:top+28]],u.body,5);
   limb([[left+2,top+13],[left-5,top+23],[left-3,top+29]],u.body,4);
   poly([[left,top],[left+4,top-7],[right-7,top-7],[right+1,top+2],[right+4,top+10],[left+3,top+12]],ink);poly([[left+3,top],[left+6,top-4],[right-8,top-4],[right-2,top+3],[right,top+8],[left+5,top+9]],u.body);
   poly([[left+3,top-3],[left-1,top-14],[left+9,top-5]],gold);poly([[right-10,top-5],[right-3,top-14],[right-5,top-2]],gold);eye(right-10,top+1);rect(right-4,top+7,3,4,light);
   if(u.kind==='beast'){poly([[left+1,top+9],[left-6,top+17],[left+3,top+14],[left,top+23],[left+12,top+17]],gold);rect(left+4,72,7,3,gold)}
  }
 }else{
  const L=u.large?20:25,R=u.large?49:43,T=u.large?26:29;
  if(u.cape){poly([[L+3,25],[L-2,43],[L-8-step/2,68],[L+4,65],[L+9,69],[R-2,61],[R-5,28]],ink);poly([[L+4,29],[L+1,44],[L-4-step/2,64],[L+5,62],[L+9,65],[R-5,58]],u.body);line([[L+4,33],[L+2,56],[L-1,62]],gold,2)}
  if(u.quiver){poly([[L-5,28],[L+1,25],[L+3,52],[L-3,54]],'#574531');for(let i=0;i<3;i++){line([[L-4+i*2,32],[L-7+i*2,17]],'#c9b58c',1);line([[L-7+i*2,18],[L-10+i*2,16]],light,2)}}
  const legcol=u.bones?gold:u.armor?steel:'#564c46';
  limb([[L+5,54],[L+5+step,64],[L+3+step,73]],legcol,u.bones?3:5);limb([[R-4,54],[R-4-step,64],[R-2-step,73]],legcol,u.bones?3:5);
  rect(L+step,72,10,4,u.bones?gold:ink);rect(R-5-step,72,11,4,u.bones?gold:ink);
  if(u.robe){poly([[L+2,T],[R-3,T],[R+3,70],[R-3,72],[R-8,69],[L+5,73],[L-3,70]],ink);poly([[L+4,T+2],[R-5,T+2],[R,68],[R-5,69],[R-9,66],[L+5,70],[L,68]],u.body);line([[L+6,42],[L+4,68]],gold,2);line([[R-7,43],[R-4,67]],gold,2);rect(L,66,R-L,3,gold)}
  else{poly([[L,T],[R,T],[R+1,52],[R-3,59],[L+3,58],[L-2,51]],ink);poly([[L+2,T+2],[R-2,T+2],[R-1,51],[R-5,55],[L+4,54],[L,49]],u.body)}
  if(u.bones){rect(32,31,3,22,gold);for(let i=0;i<4;i++){line([[27,33+i*4],[33,35+i*4],[40,32+i*4]],gold,2)}rect(29,52,11,3,gold)}
  else{rect(L,48,R-L,3,'#463c34');rect(33,48,4,3,gold);line([[L+4,T+3],[L+4,43]],u.armor?light:gold,2);if(u.armor){rect(L-2,T,8,5,steel);rect(R-5,T,8,5,steel);rect(L-1,T,5,2,light)}}
  if(u.fur)for(let i=0;i<5;i++)poly([[L-3+i*6,T],[L+i*6,T-3],[L+4+i*6,T+7],[L+i*6,T+4]],gold);
  if(u.satchel){rect(L-4,47,9,13,'#624e39');rect(L-3,48,7,3,gold);line([[R-3,30],[L-2,47]],gold,2)}
  // Head and headgear are deliberately different across every building tier.
  rect(29,13,14,17,ink);rect(31,15,11,13,u.bones?gold:skin);rect(41,21,4,4,u.bones?gold:skin);rect(39,19,2,2,ink);rect(34,28,5,4,u.bones?gold:skin);
  if(u.bones){rect(32,17,4,4,ink);rect(39,17,3,4,ink);rect(37,22,2,2,ink);for(let x=33;x<42;x+=3)rect(x,26,1,3,ink)}
  const hat=u.hat;
  if(['hood','veil','hornhood','skullhood'].includes(hat)){poly([[27,24],[27,15],[33,9],[42,12],[45,18],[40,16],[33,16],[32,25],[37,30],[27,30]],u.body);line([[33,12],[41,14]],gold,2)}
  if(['helmet','plume','hornhelm'].includes(hat)){poly([[28,24],[28,14],[33,9],[39,9],[44,15],[44,19],[33,18],[33,26]],steel);line([[30,15],[33,11],[39,11]],light,2);rect(34,19,9,3,ink);rect(41,22,3,5,steel)}
  if(hat==='plume'){poly([[35,10],[34,5],[28,3],[21,7],[18,18],[23,14],[25,9],[32,8]],'#dd4760');line([[22,10],[27,6],[32,6]],'#ffac73',2)}
  if(['hornhood','hornhelm','antlers'].includes(hat)){for(const sg of [-1,1]){line([[35+sg*5,14],[35+sg*10,8],[35+sg*11,3]],gold,3);if(hat==='antlers')line([[35+sg*10,8],[35+sg*16,6],[35+sg*17,2]],gold,2)}}
  if(hat==='point')poly([[24,16],[31,10],[36,0],[40,11],[48,16]],u.body);
  if(hat==='mitre'){poly([[28,17],[29,8],[35,2],[42,8],[44,17]],gold);rect(34,7,3,10,u.trim);rect(30,11,11,2,u.trim)}
  if(['hair','tonsure','bald'].includes(hat)){rect(29,13,12,3,hat==='bald'?skin:'#674637');if(hat!=='bald')rect(29,16,3,10,'#674637');if(hat==='tonsure')rect(33,12,6,3,skin)}
  if(['cap','feather','scarf'].includes(hat)){poly([[27,17],[30,10],[41,11],[43,16],[48,17]],u.body);line([[29,16],[43,16]],gold,2);if(hat==='feather')poly([[31,12],[27,2],[32,5],[34,11]],light);if(hat==='scarf')poly([[29,25],[23,30],[19,40],[26,36],[32,28]],gold)}
  if(u.beard)poly([[32,25],[39,27],[43,24],[41,35],[36,41],[32,31]],light);
  if(u.mask)rect(33,23,10,5,'#252e2a');
  if(u.ragged){poly([[L,53],[L+3,62],[L+7,55],[L+10,61],[R,55]],u.body);rect(29,38,5,4,skin);rect(36,17,2,2,'#e6d973')}
  const handX=strike?56:wind?46:46,handY=strike?34:wind?17:43;
  limb([[R-2,T+4],[wind?R+7:R+3,wind?T-6:39],[handX,handY]],u.bones?gold:u.body,u.large?7:4);rect(handX-2,handY-2,5,5,u.bones?gold:skin);
  limb([[L+1,T+4],[L-3,41],[L+step/2,48]],u.bones?gold:u.body,4);
  if(u.shield){const sx=L-6,sy=37;if(u.shield==='kite'){poly([[sx-4,sy],[sx+9,sy-2],[sx+10,sy+14],[sx+3,sy+23],[sx-5,sy+12]],ink);poly([[sx-2,sy+2],[sx+7,sy],[sx+8,sy+13],[sx+3,sy+19],[sx-3,sy+11]],gold);poly([[sx,sy+4],[sx+5,sy+3],[sx+6,sy+12],[sx+3,sy+16],[sx-1,sy+10]],u.body);rect(sx+2,sy+5,2,10,light)}else{const w=u.shield==='buckler'?9:14;rect(sx-2,sy+1,w,14,ink);rect(sx,sy,w-2,16,gold);rect(sx+1,sy+2,w-4,12,u.body);rect(sx+3,sy+6,3,4,light)}}
  const w=u.weapon;
  c.save();c.translate(handX,handY);if(!w.includes('bow')){if(strike)c.rotate(Math.PI/2);else if(wind)c.rotate(.65);}
  if(['sword','knife','spear'].includes(w)){const len=w==='knife'?15:w==='spear'?(wind?27:38):29;line([[0,7],[0,-len]],ink,4);line([[0,5],[0,-len+6]],w==='spear'?'#ad8751':steel,2);poly([[-3,-len+7],[0,-len],[3,-len+7],[1,-len+15],[-1,-len+15]],light);if(w!=='spear')rect(-5,-5,11,3,gold)}
  else if(['axe','doubleaxe','club','mace','staff','wand','candle','orb'].includes(w)){const len=w==='wand'?18:w==='candle'?12:wind?23:32;line([[0,7],[0,-len]],ink,5);line([[0,6],[0,-len]],w==='staff'?gold:'#ad8250',2);
   if(w.includes('axe')){poly([[0,-30],[9,-34],[10,-21],[2,-24]],steel);line([[9,-32],[9,-23]],light,2);if(w==='doubleaxe')poly([[0,-30],[-9,-34],[-10,-21],[-2,-24]],light)}
   if(w==='club'){poly([[-5,-36],[5,-37],[7,-23],[2,-18],[-4,-22]],'#695641');rect(-4,-30,10,3,steel)}
   if(w==='mace'){rect(-5,-33,11,10,gold);rect(-3,-35,7,14,light)}
   if(['staff','wand','orb'].includes(w)){rect(-4,-len-5,9,9,gold);rect(-2,-len-3,5,5,u.trim);rect(-1,-len-3,2,2,light)}
   if(w==='candle'){rect(-3,-14,7,13,'#f1ddb2');poly([[-2,-15],[0,-24],[3,-18],[2,-14]],'#ffb956');rect(0,-19,2,4,'#fff1a0')}
  }else if(w.includes('bow')){
   const size=w==='shortbow'?15:w==='longbow'?29:23;
   if(w==='crossbow'){line([[-11,-8],[8,7]],gold,3);line([[9,-10],[-7,11]],steel,3);line([[-7,11],[8,7],[9,-10]],light,1)}
   else{line([[-2,-size],[5,-size/2],[6,0],[3,9],[-2,14]],gold,3);line([[-2,-size],[wind?-10:-2,-3],[-2,14]],light,1);if(wind||strike)line([[-12,-3],[17,-3]],'#e5d6b5',1)}
  }
  c.restore();
 }
 c.restore();
}
