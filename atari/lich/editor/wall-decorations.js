'use strict';
// Cosmetic overlays: do not consume entity slots or change collision/map data.
function wallDecorations(tiles,game){
 if(game.wall_decorations===false)return [];
 const result=[];
 for(let y=0;y<31;y++)for(let x=1;x<127;x++){
  const n=tiles[y*128+x];
  // Only broad front faces: leave side walls, corners and door openings clear.
  if(n!==54&&n!==55)continue;
  const below=tiles[(y+1)*128+x];if(![2,35,39,43].includes(below))continue;
  if((x+2*y)%5!==2)continue;
  result.push({x,y,type:(Math.floor((x+2*y)/5)+y)%2?'banner':'torch'});
 }
 return result;
}
function drawWallDecorations(ctx,tiles,game,scale=1,ox=0,oy=0,fog=null){
 for(const d of wallDecorations(tiles,game)){
  const visibility=fog?.[d.y*128+d.x];if(visibility===2)continue;
  const px=d.x*8-ox,py=d.y*8-oy;
  if((px+8)*scale<0||px*scale>=ctx.canvas.width||(py+15)*scale<0||py*scale>=ctx.canvas.height)continue;
  const rows=WALL_DECOR_ART[d.type];
  for(let y=0;y<rows.length;y++)for(let x=0;x<8;x++){
   const n=parseInt(rows[y][x],16);if(!n)continue;
   // The 12-pixel ornament ends before the walkable floor strip.
   ctx.fillStyle=PAL_CSS[visibility===1?[0,0,1,5,1,1,13,6,4,4,9,3,13,5,1,1][n]:n];
   ctx.fillRect((px+x)*scale,(py+y)*scale,scale,scale);
  }
 }
}
