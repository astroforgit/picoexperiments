pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
--hobobot
--by gradual games
--gradualgames@gmail.com

--a tiny puzzle game where you
--re-assemble a disassembled
--robot.

function _init()

 bh=create_bh()
 dbg=""
 dbgrcts={}
 --show_dbgrects=true
 --show_rects=true
 --show_epts=true
 --show_stats=true

 levels={
  {0,0},
  {1,0},
  {3,0},
  {2,0},
  {4,0},
  {5,0},
  {1,1},
  {4,1},
  {0,1},
  {2,1},
  {6,1},
  {3,1},
  {6,0},
  {7,1},
  {7,0},
  {5,1}
 }
 cartdata("gradualgames_hobobot")
 level=dget(0) == 0 and 1 or dget(0)
 last_level=16
 --max falling velocity for
 --all entities.
 max_v=5

 init_title()

end

function _update()

 update()

end

function _draw()

 draw()

end

--init state

function init_title()

 title_yo=0

 menuitem(1)

 update=update_title
 draw=draw_title

 cls()
 pause_frames(16)
 fade_in()
 music(0)

end

function update_title()

 if btnp(Ž) or btnp(—) then
  fade_out()
  init_main()
 end

end

function draw_title()

 cls()
 camera()
 pixels=
  get_text_pixels("hobobot")
 cls()
 for y=-8,120,8 do
  for x=0,120,8 do
   spr(86,x,y+title_yo)
  end
 end
 title_yo+=.5
 if (title_yo==8) title_yo=0
 scale_text(pixels,4,19,4.5,5,6)
 printc("by gradual games",48,6)
 printc("press z or x",6*18,6)
 local hx,hy=60,68
 spr(1,hx,hy)
 spr(8,hx-4,hy+8,2,1)
 spr(4,hx-7,hy+8,1,1,true)
 spr(4,hx+7,hy+8,1,1)
 spr(12,hx-2,hy+16)
 spr(12,hx+2,hy+16)
 spr(67,hx,hy+24)
 spr(67,hx-8,hy+24)
 spr(67,hx+8,hy+24)

end

--main state

function init_main()

 menuitem(
  1,
  "restart level",
  function()
   init_main()
  end)

 menuitem(
  2,
  "reset progress",
  function()
   dset(0,1)
   level=1
   init_main()
  end)

-- menuitem(
--  2,
--  "reset stat_time",
--  function()
--   stat_time=time()
--  end)

-- menuitem(
--  2,
--  "win game",
--  function()
--   init_finish()
--  end)

 update=update_main
 draw=draw_main
 id=0
 ntts={}
 p_ntts={}
 platforms={}
 stat_moves=0
 stat_time=time()
 particles={}
 counter=0

 reload()

 init_camera()

 --load all controllable
 --contraptions. each gets
 --assigned an id for later
 --associating with switches.
 load_gates()
 load_conveyors()
 load_elevators()
 load_pulleys()
 load_telepods()
 --switches must be last since
 --they rely on ids assigned
 --to all controllable contraptions.
 load_switches(33,create_switch)
 load_switches(40,create_pswitch)
 load_pieces()

 --initialize selected player
 --entity
 p_i=2
 select_player()

 --wait til no buttons pressed
 wait_nbtn=false

 p_ntt.state=0
 c_on=true
 c_num=48

 fade_in()
 music(2)

end

function update_main()

 update_bh(bh)

 if bup(bh,—) and bpressed(bh,Ž) then
  if (#p_ntts>1) sfx(6)
  p_i=(p_i+1)%#p_ntts
  select_player()
 end

 --clear debug rects
 dbgrcts={}

 --clear platform loads for
 --this frame
 for p in all(platforms) do
  p.ld={}
 end

 update_ntts()
 eject_ntts()
 postupdate_ntts()
 update_particles()
 counter+=1

 --show platform load counts
 --[[
 dbg=""
 for p in all(platforms) do
  dbg=dbg.." "..p.ld
 end
 --]]

end

function draw_main()

 cls()
 camera(cx,cy)

 map(shr(cx,3),shr(cy,3),cx,cy,16,16)
 draw_ntts()
 draw_particles()
 if c_on and p_ntt!=nil then
  spr(c_num,p_ntt.x,p_ntt.y-8-sin(time()*2))
  if p_ntt.update==update_leg and
     p_head and
     not p_body.head and
     counter&16==0 then
   local a=0
   if counter&4==0 then
    a=1
   end
   spr(14+a,p_head.x+2,p_head.y-5)
  end
 end

 print(dbg,cx+50,cy+50,6)
 if show_stats then
  bg_text("l: "..shr(cx,7).." "..shr(cy,7)
        .." m: "..stat_moves
        .." t: "..flr(time()-stat_time),
        cx+6,cy+122,6,0)
 end

end

function init_camera()

 local levelcoords=levels[level]
 levelx=levelcoords[1]
 levely=levelcoords[2]
 cx=levelx*128
 cy=levely*128

end

--win state

function init_win()
 music(1)
 menuitem(1)
 counter=128
 update=update_win
 draw=draw_win
 winmsg="fully assembled!"
 winboxw=80
 winboxh=40
 winx=cx-128
 winy=cy+center(winboxh,128)
 windestx=center(winboxw,128)
 wint=0
 wintimestat=flr(time()-stat_time)
end

function update_win()
 if counter==0 then
  counter=64
  update=update_next_level
  draw=function() end
 end
 counter-=1
 winx=ease(wint,30,cx-128,cx+windestx)
 if wint<30 then
  wint+=1
 end
end

function draw_win()
 draw_main()
 box(winx,winy,winboxw,winboxh,0,7)
 print(winmsg,winx+center(#winmsg*4,winboxw),winy+6,7)
 local levelmsg="level: "..level
 print(levelmsg,winx+center(#levelmsg*4,winboxw),winy+6*2,7)
 if (counter==75) sfx(6)
 if counter<=75 then
  local moves="moves: "..stat_moves
  print(moves,winx+center(#moves*4,winboxw),winy+6*4,7)
 end
 if (counter==50) sfx(6)
 if counter<=50 then
  local tme="time: "..wintimestat
  print(tme,winx+center(#tme*4,winboxw),winy+6*5,7)
 end
 --otlbg_text(winmsg,winx,winy,4,7,0,7)
end

--next level state

function update_next_level()
 if counter==0 then
  level+=1
  if level>last_level then
   init_finish()
   return
  else
   --only save up to last level
   dset(0,level)
  end
  fade_out()
  init_main()
 end
 counter-=1
end

--finish all level state

function init_finish()

 update=update_finish
 draw=draw_finish
 finishmsg="you completed all levels!"
 winx=cx-128
 winy=cy+64
 wint=0

end

function update_finish()

 if btnp(—) or btnp(Ž) then
  fade_out()
  run()
 end
 winx=ease(wint,30,cx-128,cx+center_text_x(finishmsg))
 if wint<30 then
  wint+=1
 end

end

function draw_finish()
 cls()
 draw_main()
 otlbg_text(finishmsg,winx,winy,4,7,0,7)
end

--this function wraps all button
--functions with two tests:
--one test to only perform the
--wrapped function if this ntt
--is the selected player ntt,
--and another test to wait until
--no buttons are pressed if the
--wait_nbtn flag is set. this is
--used when automatically transferring
--control between hobobot pieces.
function b_active(bf,ntt,b)

 if not wait_nbtn then
  if ntt==p_ntt then
   return bf(bh,b)
  end
  return false
 elseif btn()==0 then
  wait_nbtn=false
 end

end

--this function removes a player
--entity from the p_ntts table.
function remove_player(ntt)

 c_on=true
 del(p_ntts,ntt)
 if p_ntt==ntt then
  p_i=0
  select_player()
  wait_nbtn=true
 end

end

function select_player()
  if (p_ntt) p_ntt:reset()
  p_ntt=p_ntts[p_i+1]
  --make sure selected player
  --entity is the last in the
  --entities list so it is
  --brought forward when drawing.
  del(ntts,p_ntt)
  add(ntts,p_ntt)
end

-->8
--utility functions

--button names
bl,br,bu,bd,bo,bx=0,1,2,3,4,5

--creates a button history
function create_bh()

 local bh={}
 clear_bh(bh)
 return bh

end

--clears an existing button history
function clear_bh(bh)

 for i=0,5 do
  bh[i]={false,false}
 end

end

function update_bh(bh)

 for i=0,5 do
  rem(bh[i])
  if btn(i) then
   add(bh[i],true)
  else
   add(bh[i],false)
  end
 end

end

function copy_bh(bha,bhb)

 for i=0,5 do
  for j=1,2 do
   bhb[i][j]=bha[i][j]
  end
 end

end

function bpressed(bh,i)

 if bh[i][1]==false and
    bh[i][2]==true then
  return true
 else
  return false
 end

end

function breleased(bh,i)

 if bh[i][1]==true and
    bh[i][2]==false then
  return true
 else
  return false
 end

end

function bdown(bh,i)

 return bh[i][2]

end

function bup(bh,i)

 return not bh[i][2]

end

--table functions

--use alongside add for queue behavior
function rem(queue)
 if #queue > 0 then
  local v = queue[1]
  del(queue, v)
  return v
 else
  return nil
 end
end

--text functions

--adds carriage returns to string s, wrapping it to width l in characters
function wrap(s,l)

 local ws=""
 while l<=#s do
  ws=ws..sub(s,1,l).."\n"
  s=sub(s,l,#s)
 end
 ws=ws..s.."\n"
 return ws

end

--prints some text, then returns
--a table of pixel coords that
--can be used later for scaling
function get_text_pixels(text)

 local pixels={}
 print(text,0,0,7)
 for y=0,7 do
  for x=0,#text*8-1 do
   local col=pget(x,y)
   if col!=0 then
    add(pixels,{x,y})
   end
  end
 end
 return pixels

end

function scale_text(pixels,tlx,tly,sx,sy,col)

 for pixel in all(pixels) do
  local x=pixel[1]
  local y=pixel[2]
  local nx=x*sx+tlx
  local ny=y*sy+tly
  rectfill(nx+1,ny+1,nx+sx-1,ny+sy-1,col)
  pset(nx+1,ny+1,7)
  pset(nx+2,ny+1,7)
  pset(nx+1,ny+2,7)
  pset(nx+1,ny+3,7)
 end

end

function shadow_text(text,x,y,c1,c2)

 print(text,x-1,y-1,c1)
 print(text,x,y,c2)

end

function bg_text(text,x,y,fg,bg)

 rectfill(x-1,y-1,x+#text*4,y+6,c2)
 print(text,x,y,fg)

end

function box(x,y,w,h,i,o)
 local lx,rx,
       ty,by=
  x,x+w,
  y,y+h
 rectfill(lx+1,ty+1,rx-1,by-1,i)
 line(lx+1,ty,rx-1,ty,o)
 line(lx,ty+1,lx,by-1,o)
 line(lx+1,by,rx-1,by,o)
 line(rx,ty+1,rx,by-1,o)
end

function otlbg_text(text,x,y,m,o,i,t)

 local tw,th=#text*4,6

 local lx,rx,
       ty,by=
  x-m-1,x+tw+m-1,
  y-m-1,y+th+m-1

 rectfill(lx+1,ty+1,rx-1,by-1,i)
 line(lx+1,ty,rx-1,ty,o)
 line(lx,ty+1,lx,by-1,o)
 line(lx+1,by,rx-1,by,o)
 line(rx,ty+1,rx,by-1,o)
 print(text,x,y,t)

end

function center_text_x(text)
 return 64-(#text*2)
end

function printc(text,y,c)
 print(text,center_text_x(text),y,c)
end

function center(s,w)
 return (w/2)-(s/2)
end

--math functions

--return sign of v.
function sign(v)
 if v<0 then
  return -1
 else
  return 1
 end
end

--caps a value's magnitude
--preserving sign.
function cap(v,m)
 if abs(v)>m then
  return m*sign(v)
 else
  return v
 end
end

function rects_int(r1, r2)

 if r1[1] > r2[3] then
  return false
 end

 if r1[3] < r2[1] then
  return false
 end

 if r1[2] > r2[4] then
  return false
 end

 if r1[4] < r2[2] then
  return false
 end

 return true

end

--returns true if r1 is
--entirely within r2 inclusive.
function rect_in_rect(r1,r2)

 if (r1[1]<r2[1]) return false
 if (r1[3]>r2[3]) return false
 if (r1[2]<r2[2]) return false
 if (r1[4]>r2[4]) return false
 return true

end

--logical xor for flipping sprites
function xor(a,b)

 if a and b then return false end
 if a or b then return true end
 return false

end

--generic bubble sort. p is
--a function to extract a property
--to sort by.
function sort_by(t,p)

 local sorted=false
 while sorted==false do
  sorted=true
  for i=1,(#t-1) do
   local a=p(t[i])
   local b=p(t[i+1])
   if a>b then
    local c=t[i]
    t[i]=t[i+1]
    t[i+1]=c
    sorted=false
   end
  end
 end
 return t

end

function pause_frames(frames)
 for i=1,frames do
  flip()
 end
end

--graphics functions
function fade_in()
 for i=1,0,-.1 do
  fadepal(i)
  flip()
  _draw()
 end
end

function fade_out()
 for i=0,1,.1 do
  fadepal(i)
  flip()
  _draw()
 end
end

--found this fade code in
--khan's study hall cartridge.
function fadepal(perc)
 local p=flr(mid(0,perc,1)*100)

 local kmax,col,dpal,j,k
 dpal={0,1,1,2,1,13,6,
       4,4,9,3,13,1,13,14}

 for j=1,15 do
  col=j

  kmax=(p+(j*1.46))/22

  for k=1,kmax do
   col=dpal[col]
  end

  pal(j,col,1)
 end
end

--easing functions
function quad_out(t,d,b,c)
 t/=d
 return -c*t*(t-2)+b

end

function ease(t,d,start,target)
 return quad_out(t,d,start,target-start)
end

-->8
--entity functions

function create_ntt(x,y,update,draw)

 local ntt={
  state=0,
  update=update,
  draw=draw,
  post_xeject=ntt_post_xeject,
  alive=true,
  visible=false,
  anim=nil,
  fh=false,fv=false,
  x=x,y=y,
  tlx=0,tly=0,ptly=0,
  w=0,h=0,
  eleft={},eright={},edown={},eup={},
  resting=true,
  xv=0,yv=0,
  yt=0,
  xa=0,ya=0,
  weight=1
 }
 return ntt

end

function eject_ntt(ntt)

 for ep in all(ntt.eleft) do
  if test_map(ntt.x+ep[1],ntt.y+ep[2])==true then
   ntt.x=band(ntt.x+8,0xfff8)
   ntt:post_xeject()
  end
 end

 for ep in all(ntt.eright) do
  if test_map(ntt.x+ep[1],ntt.y+ep[2])==true then
   ntt.x=band(ntt.x,0xfff8)
   ntt:post_xeject()
  end
 end

 if ntt.yv>0 then
  for ep in all(ntt.edown) do
   local t=get_map(ntt.x+ep[1],ntt.y+ep[2])
   if fget(t,0)==true then
    ntt.y=band(ntt.y,0xfff8)
    ntt.yv=0
    ntt.resting=true
   end
   if fget(t,1)==true then
    ntt.x-=.3
   elseif fget(t,2)==true then
    ntt.x+=.3
   end
  end

  for o in all(platforms) do
   if ntt_int(ntt,o) then
    add(o.ld,ntt)
    ntt.y=o.y+
          o.pty-
          ntt.edown[1][2]
    ntt.yv=0
    ntt.resting=true
   end
  end
 end

 if ntt.yv<0 then
  for ep in all(ntt.eup) do
   if test_map(ntt.x+ep[1],ntt.y+ep[2])==true then
    ntt.y=band(ntt.y+8,0xfff8)
    ntt.yv=0
   end
  end
 end

end

function ntt_post_xeject(ntt)
end

function get_ntt_rect(ntt)

 return {ntt.x+ntt.tlx,
         ntt.y+ntt.tly,
         ntt.x+ntt.tlx+ntt.w,
         ntt.y+ntt.tly+ntt.h}

end

function ntt_int(ntt1,ntt2)

 local r1=get_ntt_rect(ntt1)
 local r2=get_ntt_rect(ntt2)
 return ntt1!=ntt2 and
        rects_int(r1,r2)

end

function ntt_int_type(ntt,t)

 for ontt in all(ntts) do
  if ntt_int(ntt,ontt) and
     ontt.update==t then
   return ontt
  end
 end
 return nil

end

function find_ntt_id(id)

 for ntt in all(ntts) do
  if ntt.id==id then
   return ntt
  end
 end

end

function move_ntt(ntt)
 ntt.x+=ntt.xv
 ntt.y+=ntt.yv

 ntt.xv+=ntt.xa
 ntt.yv+=ntt.ya
 ntt.yv=min(ntt.yv+ntt.yt,max_v)

 if ntt.y>cy+192 then
  music(-1)
  sfx(21)
  for i=1,32 do flip() end
  init_main()
 end
end

function draw_ntt(ntt)
 if ntt!=nil then
  draw_anim(
   ntt.anim,ntt.x,ntt.y,
   ntt.fh,ntt.fv)
 end
end

function draw_ntt_blo(ntt)
 pal(5,0)
 pal(6,0)
 pal(7,0)

 ntt.x-=1
 draw_ntt(ntt)

 ntt.x+=2
 draw_ntt(ntt)

 ntt.x-=1
 ntt.y-=1
 draw_ntt(ntt)

 ntt.y+=1
 pal()
 draw_ntt(ntt)
end

function draw_epts(ntt,epts)
 if ntt!=nil then
  for pt in all(epts) do
   pset(ntt.x+pt[1],
        ntt.y+pt[2],14)
  end
 end
end

function update_ntts()

 for ntt in all(ntts) do
  if ntt.alive==true then
   if ntt.update then
    ntt:update()
   end
  end
 end

end

function eject_ntts()

 for ntt in all(ntts) do
  eject_ntt(ntt)
 end

end

function postupdate_ntts()

 for ntt in all(ntts) do
  if ntt.alive==true then
   if ntt.post_update then
    ntt:post_update()
   end
  end
 end

end

function draw_ntts()

 for ntt in all(ntts) do
  if ntt.alive==true and
     ntt.visible==true then
   ntt.draw(ntt)
   if show_dbgrects then
    for r in all(dbgrcts) do
     rect(r[1],r[2],
          r[3],r[4],8)
    end
   end
   if show_rects then
    rect(ntt.x+ntt.tlx,
         ntt.y+ntt.tly,
         ntt.x+ntt.tlx+ntt.w,
         ntt.y+ntt.tly+ntt.h,8)
   end
   if show_epts then
    draw_epts(ntt,ntt.eup)
    draw_epts(ntt,ntt.eright)
    draw_epts(ntt,ntt.edown)
    draw_epts(ntt,ntt.eleft)
   end
  end
 end

end
-->8
--entities

--this function loads all of the
--pieces of the hobobot from the
--current map. this should be called
--after loading contraptions
--such as switches, conveyors,
--since those are parameterized
--by nearby tiles which may have
--the same numbers as the hobobot
--pieces.
function load_pieces()

 local ccelx,ccely=
  shr(cx,3),shr(cy,3)
 local pmapper={
  [1]={create_head,update_head},
  [2]={create_hand,update_hand},
  [8]={create_body,update_body},
  [10]={create_leg,update_leg}
 }
 for k,v in pairs(pmapper) do
  for y=0,15 do
   for x=0,15 do
    local mx,my=ccelx+x,ccely+y
    if mget(mx,my)==k then
     local ntt=
      v[1](mx*8,my*8,v[2])
     if ntt.update==update_head then
      p_head=ntt
     elseif ntt.update==update_body then
      p_body=ntt
     end
     add(ntts,ntt)
     if k!=1 and k!=8 then
      add(p_ntts,ntt)
     end
     mset(mx,my,0)
    end
   end
  end
 end

end

function reset_hand(ntt)
 ntt.anim=ntt.a_idle
 reset_anim(ntt.anim)
 ntt.state=ntt.s_main
end

function create_hand(x,y)

 local ntt=
  create_ntt(
   x,y,
   update_hand,
   draw_ntt_blo)

 --reset to main state
 ntt.reset=reset_hand

 --define names for all states
 ntt.s_main=0
 ntt.s_align=1
 ntt.s_switch=2

 --create all animations for the hand
 ntt.a_idle=create_anim(
  {
   create_8x8_frame(2)
  },
  1)

 ntt.a_walk=create_anim(
  {
   create_8x8_frame(3),
   create_8x8_frame(4),
   create_8x8_frame(5),
   create_8x8_frame(4),
  },
  4)

 ntt.a_on=create_anim(
  {
   create_8x8_frame(6),
   create_8x8_frame(7)
  },
  10)

 ntt.a_off=create_anim(
  {
   create_8x8_frame(7),
   create_8x8_frame(6)
  },
  10)

 local w,h=7,7
 ntt.w=w
 ntt.h=h
 ntt.xv=0
 ntt.ya=.1
 ntt.eright={{w,3}}
 ntt.edown={{3,8}}
 ntt.eleft={{0,3}}
 ntt.anim=ntt.a_idle
 ntt.visible=true

 return ntt

end

function update_hand(ntt)

 if ntt.state==ntt.s_main then
  if (p_ntt==ntt) c_num=48
  if b_active(bpressed,ntt,—) then
   local o=ntt_int_type(ntt,update_switch)

   if o then
    ntt.switch=o
    ntt.xv=0
    ntt.yv=0
    ntt.counter=5
    ntt.state=ntt.s_align
    return
   end
  end
  if b_active(bdown,ntt,‘) then
   ntt.xv=1
   ntt.anim=ntt.a_walk
   ntt.fh=false
  elseif b_active(bdown,ntt,‹) then
   ntt.xv=-1
   ntt.anim=ntt.a_walk
   ntt.fh=true
  else
   ntt.anim=ntt.a_idle
   ntt.xv=0
  end
 end

 if ntt.state==ntt.s_align then
  if (p_ntt==ntt) c_num=49
  if b_active(bpressed,ntt,—) then
   if (p_ntt==ntt) c_num=48
   ntt.anim=ntt.a_idle
   reset_anim(ntt.anim)
   ntt.state=ntt.s_main
   return
  end
  local dx=ntt.switch.x-ntt.x
  local dy=ntt.switch.y-ntt.y
  dx=shr(dx,2)
  dy=shr(dy,2)
  ntt.x+=dx
  ntt.y+=dy
  if abs(dx)<.1 and abs(dy)<.1 then
   if b_active(bpressed,ntt,‘) then
    ntt.switch.pright()
    stat_moves+=1
   elseif b_active(bpressed,ntt,‹) then
    ntt.switch.pleft()
    stat_moves+=1
   end
   ntt.x=ntt.switch.x
   ntt.y=ntt.switch.y
   if ntt.switch.pos==-1 then
    ntt.fh=true
   elseif ntt.switch.pos==1 then
    ntt.fh=false
   end
   ntt.anim=ntt.a_on
   reset_anim(ntt.anim)
   if ntt.switch.anim==ntt.switch.a_on then
    ntt.anim.frame=1
   else
    ntt.anim.frame=0
   end
  end
 end

 local o=ntt_int_type(ntt,update_body)
 if o then
  sfx(5)
  remove_player(ntt)
  del(ntts,ntt)
  add(o.hands,ntt)
  o.weight+=1
  ntt.anim=ntt.a_walk
  reset_anim(ntt.anim)
  ntt.anim.frame=1
  stat_moves+=1
  return
 end

 move_ntt(ntt)
 update_anim(ntt.anim)

end

function create_leg(x,y)

 local ntt=
  create_ntt(
   x,y,
   update_leg,
   draw_ntt_blo)

 --reset no-op
 ntt.reset=function(ntt) end

 --define names for all states
 ntt.s_main=0
 ntt.s_jump=1
 ntt.s_kicks=2
 ntt.s_kickf=3

 --create all animations
 ntt.a_idle=create_anim(
  {
   create_8x8_frame(10)
  },
  1)

 ntt.a_jump=create_anim(
  {
   create_8x8_frame(11),
   create_8x8_frame(10)
  },
  10)

 ntt.a_kick=create_anim(
  {
   create_8x8_frame(11),
   create_8x8_frame(13)
  },
  6)

 ntt.a_attached=create_anim(
  {
   create_8x8_frame(12)
  },
  1)

 local w,h=7,7
 ntt.w=w
 ntt.h=h
 ntt.xv=0
 ntt.ya=.3
 ntt.eup={{3,0}}
 ntt.eright={{w,3}}
 ntt.edown={{3,8}}
 ntt.eleft={{0,3}}
 ntt.anim=ntt.a_idle
 ntt.visible=true
 ntt.kicked=false

 return ntt

end

function update_leg(ntt)

 function start_jump()
   ntt.counter=5
   ntt.anim=ntt.a_jump
   reset_anim(ntt.anim)
   ntt.state=ntt.s_jump
  end

 function choose_direction(v)
  if ntt.fh==false then
   ntt.xv=v
  else
   ntt.xv=-v
  end
 end

 if ntt.state==ntt.s_main then
  if (p_ntt==ntt) c_num=48
  if ntt.resting==true then
   ntt.xv=0
   ntt.kicked=false
   if b_active(bpressed,ntt,—) then
    sfx(10)
    ntt.counter=5
    ntt.anim=ntt.a_kick
    reset_anim(ntt.anim)
    ntt.state=ntt.s_kicks
    return
   end
   if b_active(bdown,ntt,‹) then
    ntt.fh=true
    start_jump()
   elseif b_active(bdown,ntt,‘) then
    ntt.fh=false
    start_jump()
   end
  end
 end

 if ntt.state==ntt.s_jump then
  if ntt.counter==0 then
   sfx(11)
   choose_direction(.7)
   ntt.yv=-2.2
   ntt.resting=false
   ntt.anim=ntt.a_idle
   reset_anim(ntt.anim)
   ntt.state=ntt.s_main
  end
  ntt.counter-=1
 end

 if ntt.state==ntt.s_kicks then
  if ntt.counter==0 then
   choose_direction(3)
   ntt.yv=-1
   ntt.resting=false
   ntt.ya=0
   ntt.counter=5
   ntt.state=ntt.s_kickf
  end
  ntt.counter-=1
 end

 if ntt.state==ntt.s_kickf then
  if ntt.counter==0 then
   ntt.xv=0
   ntt.yv=0
   ntt.ya=.3
   ntt.anim=ntt.a_idle
   reset_anim(ntt.anim)
   ntt.state=ntt.s_main
  else
   local o=ntt_int_type(ntt,update_head)
   if o and not ntt.kicked then
    sfx(9,3)
    ntt.kicked=true
    o.yv=-2
    if ntt.fh==false then
     o.xv=6.2
    else
     o.xv=-6.2
    end
    generate_particles(10,o.x+3.5,o.y+3.5,7)
    stat_moves+=1
   end
  end
  ntt.counter-=1
 end

 local o=ntt_int_type(ntt,update_body)
 if o then
  sfx(5)
  remove_player(ntt)
  del(ntts,ntt)
  add(o.legs,ntt)
  o.weight+=1
  o.h=16
  o.edown={{2,16},{8,16}}
  if #o.legs==1 then o.y-=1 end
  ntt.anim=ntt.a_attached
  reset_anim(ntt.anim)
  ntt.anim.frame=0
  stat_moves+=1
  return
 end

 move_ntt(ntt)
 update_anim(ntt.anim)

end

function create_head(x,y)

 local ntt=
  create_ntt(
   x,y,
   update_head,
   draw_ntt_blo)

 --define names for all states
 ntt.s_main=0

 ntt.a_idle=create_anim(
  {
   create_8x8_frame(1)
  },
  1)

 ntt.w=7
 ntt.h=7
 ntt.ya=.1
 ntt.yt=0
 ntt.eup={{3,0}}
 ntt.eright={{8,3}}
 ntt.edown={{3,8}}
 ntt.eleft={{0,3}}
 ntt.anim=ntt.a_idle
 ntt.visible=true
 ntt.post_xeject=
  function(ntt)
   ntt.xv=-ntt.xv
  end

 return ntt

end

function update_head(ntt)

 ntt.xv=ntt.xv/1.1
 local o=ntt_int_type(ntt,update_body)
 if o then
  sfx(5)
  remove_player(ntt)
  del(ntts,ntt)
  o.head=ntt
  o.weight+=1
  stat_moves+=1
 end
 move_ntt(ntt)

end

function create_body(x,y)

 local ntt=
  create_ntt(
   x,y,
   update_body,
   draw_ntt)

 --define names for all states
 ntt.s_main=0

 --table for hands when attached
 ntt.hands={}
 --table for legs when attached
 ntt.legs={}

 ntt.a_idle=create_anim(
  {
   {{8,-3,0},
    {9,5,0}}
  },
  1)

 ntt.w=9
 ntt.h=7
 ntt.ya=.1
 ntt.yt=0
 ntt.eup={{4,0}}
 ntt.eright={{9,4}}
 ntt.edown={{4,8}}
 ntt.eleft={{0,4}}
 ntt.anim=ntt.a_idle
 ntt.visible=true
 ntt.draw=draw_body
 ntt.particleflags={}
 ntt.windelay=32

 --hard coding this just
 --for level 5,1.
 local lx,ly=cx/128,cy/128
 if lx==5 and ly==1 then
  ntt.x+=4
 end

 return ntt

end

function update_body(ntt)

 if ntt.head!=nil and
    #ntt.hands==2 and
    #ntt.legs==2 then
  ntt.windelay-=1
  if ntt.windelay==0 then
   init_win()
  end
 end

 move_ntt(ntt)

end

function body_particles(ntt,name,xo,yo)
 if not ntt.particleflags[name] then
  generate_particles(10,ntt.x+xo,ntt.y+yo,7)
  ntt.particleflags[name]=true
 end
end

function draw_body(ntt)

 draw_ntt(ntt)
 draw_ntt(ntt.head)
 if ntt.head!=nil then
  ntt.head.x=ntt.x+1
  ntt.head.y=ntt.y-8
  body_particles(ntt,"head",5,0)
 end
 local nhands=#ntt.hands
 local hand=nil
 if nhands>=1 then
  hand=ntt.hands[1]
  hand.x=ntt.x-6
  hand.y=ntt.y
  hand.fh=true
  draw_ntt(hand)
  body_particles(ntt,"hand1",0,4)
 end
 if nhands==2 then
  hand=ntt.hands[2]
  hand.x=ntt.x+8
  hand.y=ntt.y
  hand.fh=false
  draw_ntt(hand)
  body_particles(ntt,"hand2",10,4)
 end
 local nlegs=#ntt.legs
 if nlegs>=1 then
  leg=ntt.legs[1]
  leg.x=ntt.x-1
  leg.y=ntt.y+8
  leg.fh=false
  draw_ntt(leg)
  body_particles(ntt,"leg1",2,8)
 end
 if nlegs==2 then
  leg=ntt.legs[2]
  leg.x=ntt.x+3
  leg.y=ntt.y+8
  leg.fh=false
  draw_ntt(leg)
  body_particles(ntt,"leg2",7,8)
 end

end

--this function finds all switches
--in the current room (relative to the
--current camera at cx,cy) and spawns
--them.
--this function removes the switches
--from the map itself so that they become
--entities.
--this function requires a tile number
--and a create function, to allow loading
--different types of switches.
--each switch is parameterized by one
--tile immediately above it with the
--target entity id.
function load_switches(t,c)

 local ccelx,ccely=
  shr(cx,3),shr(cy,3)
 for y=0,15 do
  for x=0,15 do
   local mx,my=ccelx+x,ccely+y
   if mget(mx,my)==t then
    local ntt=c(mx*8,my*8)
    ntt.target=find_ntt_id(mget(mx,my-1))
    add(ntts,ntt)
    if (ntt.p) add(platforms,ntt)
    --clear original tile and gate
    --id parameter from map. the entity
    --now takes over drawing itself.
    mset(mx,my,0)
    mset(mx,my-1,0)
   end
  end
 end

end

function create_switch(x,y)

 local ntt=
  create_ntt(
   x,y,
   update_switch,
   draw_ntt)

 --define names for all states
 ntt.s_main=0

 --this variable represents
 --the switch's position, where
 ---1 is left, 0 is middle, and
 --1 is right
 ntt.pos=0

 local function select_anim()
  ntt.fh=false
  if ntt.pos==-1 then
   ntt.fh=true
   ntt.anim=ntt.a_on
  elseif ntt.pos==0 then
   ntt.anim=ntt.a_off
  elseif ntt.pos==1 then
   ntt.anim=ntt.a_on
  end
  reset_anim(ntt.anim)
 end

 ntt.pright=
  function()
   local npos=min(ntt.pos+1,1)
   if (npos!=ntt.pos) sfx(0)
   ntt.pos=npos
   select_anim()
   ntt.target.upos(ntt.pos)
  end

 ntt.pleft=
  function()
   local npos=max(ntt.pos-1,-1)
   if (npos!=ntt.pos) sfx(0)
   ntt.pos=npos
   select_anim()
   ntt.target.upos(ntt.pos)
  end

 ntt.a_off=create_anim(
  {
   create_8x8_frame(33)
  },
  1)

 ntt.a_on=create_anim(
  {
   create_8x8_frame(34)
  },
  1)

 ntt.anim=ntt.a_off
 ntt.visible=true
 ntt.state=ntt.s_main
 ntt.w=7
 ntt.h=7

 return ntt

end

function update_switch(ntt)

 if ntt.state==ntt.s_main then
 end

end

function load_gates()

 local ccelx,ccely=
  shr(cx,3),shr(cy,3)
 for y=0,15 do
  for x=0,15 do
   local mx,my=ccelx+x,ccely+y
   if mget(mx,my)==20 then
    add(ntts,
     create_gate(
      mx*8,my*8))
    mset(mx,my,0)
    mset(mx,my+1,0)
   end
  end
 end

end

function create_gate(x,y)

 local ntt=
  create_ntt(
   x,y,
   update_gate,
   draw_ntt)

 --assign an id
 ntt.id=id
 id+=1

 --define names for all states
 ntt.s_main=0
 ntt.s_pause=1

 ntt.upos=
  function(pos)
   if pos==0 then
    ntt.closed=true
   else
    ntt.closed=false
   end
   ntt.counter=10
   ntt.state=ntt.s_pause
  end

 ntt.go=0
 ntt.draw=gate_draw
 ntt.visible=true
 ntt.closed=true
 ntt.state=ntt.s_main

 return ntt

end

function update_gate(ntt)

 if ntt.state==ntt.s_main then
  if ntt.closed==true then
   ntt.go=max(0,ntt.go-1)
  else
   ntt.go=min(16,ntt.go+1)
  end
  local t=0
  if ntt.go==0 then t=16 end
  local mx=shr(ntt.x,3)
  local my=shr(ntt.y,3)
  mset(mx,my,t)
  mset(mx,my+1,t)
 end

 if ntt.state==ntt.s_pause then
  if ntt.counter==0 then
   if ntt.closed==true and ntt.go>0 then
    sfx(4)
   elseif ntt.closed==false and ntt.go<16 then
    sfx(3)
   end
   ntt.state=ntt.s_main
  end
  ntt.counter-=1
 end

end

function gate_draw(ntt)

  sspr(4*8,8+ntt.go,
       8,16-ntt.go,
       ntt.x,ntt.y,
       8,16-ntt.go,
       false,false)

end

function load_conveyors()

 local ccelx,ccely=
  shr(cx,3),shr(cy,3)
 for y=0,15 do
  for x=0,15 do
   local mx,my=ccelx+x,ccely+y
   if mget(mx,my)==37 then
    add(ntts,
     create_conveyor(
      mx*8,my*8))
    mset(mx,my,17)
    mset(mx+1,my,17)
    mset(mx+2,my,17)
   end
  end
 end

end

function create_conveyor(x,y)

 local ntt=
  create_ntt(
   x,y,
   update_conveyor,
   draw_ntt)

 --assign an id
 ntt.id=id
 id+=1

 --define names for all states
 ntt.s_main=0

 ntt.upos=
  function(pos)
   ntt.on=false
   if pos==-1 then
    ntt.on=true
    ntt.fliph=false
   elseif pos==1 then
    ntt.on=true
    ntt.fliph=true
   end
   local mx=flr(shr(ntt.x,3))
   local my=flr(shr(ntt.y,3))
   local t=17+pos
   for i=0,2 do
    mset(mx+i,my,t)
   end
  end

 --manually create an anim
 --only for the counting behavior
 --we have a custom draw function
 ntt.anim={
  frame=0,
  counter=0,
  speed=5,
  maxframes=2
 }
 reset_anim(ntt.anim)

 ntt.draw=draw_conveyor
 ntt.visible=true
 ntt.on=false
 ntt.fliph=false

 return ntt

end

function update_conveyor(ntt)

 if ntt.state==ntt.s_main then
 end
 if ntt.on then
  update_anim(ntt.anim)
 end

end

function draw_conveyor(ntt)

 local anim=ntt.anim
 if anim.frame==0 then
  spr(37,ntt.x,ntt.y,3,1,ntt.fliph)
 elseif anim.frame==1 then
  spr(53,ntt.x,ntt.y,3,1,ntt.fliph)
 end

end

function load_elevators()

 local ccelx,ccely=
  shr(cx,3),shr(cy,3)
 for y=0,15 do
  for x=0,15 do
   local mx,my=ccelx+x,ccely+y
   if mget(mx,my)==24 then
    local ntt=
     create_elevator(
      mx*8,my*8)
    local p1,p2=
     mget(mx,my-1),mget(mx+1,my-1)
    ntt.mdist=p1*8
    if p2!=0 then ntt.mdist*=-1 end
    add(ntts,ntt)
    add(platforms,ntt)
    mset(mx,my,0)
    mset(mx+1,my,0)
    mset(mx,my-1,0)
    mset(mx+1,my-1,0)
   end
  end
 end

end

function create_elevator(x,y)

 local ntt=
  create_ntt(
   x,y,
   update_elevator,
   draw_ntt)

 --assign an id
 ntt.id=id
 id+=1

 --define names for all states
 ntt.s_init=0
 ntt.s_main=1

 ntt.upos=
  function(pos)
   ntt.on=pos!=0
  end

 ntt.w=15
 ntt.h=1
 ntt.tly=-2
 ntt.pty=0
 ntt.ld={}
 ntt.draw=draw_elevator
 ntt.visible=true
 ntt.on=false
 ntt.dist=0

 return ntt

end

function update_elevator(ntt)

 if ntt.state==ntt.s_init then
  ntt.yv=sign(ntt.mdist)
  ntt.state=ntt.s_main
 end

 if ntt.state==ntt.s_main then
  if ntt.on==true then
   ntt.y+=ntt.yv
   ntt.dist+=abs(ntt.yv)
   if ntt.dist>=abs(ntt.mdist) then
    ntt.dist=0
    ntt.yv*=-1
   end
  end
 end

end

function draw_elevator(ntt)

 spr(24,ntt.x,ntt.y,2,1)

end

function create_pswitch(x,y)
 local ntt=
  create_ntt(
   x,y,
   function() end,
   draw_ntt)

 --assign an id
 ntt.id=id
 id+=1

 --define names for all states
 ntt.s_init=0
 ntt.s_main=1
 ntt.s_hasload=2

 ntt.upos=
  function(pos)
  end

 ntt.w=7
 ntt.h=0
 ntt.tly=5
 ntt.pty=6
 ntt.ld={}
 ntt.draw=draw_pswitch
 ntt.visible=true
 ntt.on=false
 ntt.p=true
 ntt.post_update=update_pswitch

 return ntt
end

function update_pswitch(ntt)

 if ntt.state==ntt.s_init then
  ntt.state=ntt.s_main
 end

 if ntt.state==ntt.s_main then
  if (ntt.pty>6) ntt.pty-=1
  if #ntt.ld>0 then
   sfx(7)
   ntt.target.upos(1)
   ntt.state=ntt.s_hasload
   stat_moves+=1
  end
 end

 if ntt.state==ntt.s_hasload then
  if (ntt.pty<7) ntt.pty+=1
  if #ntt.ld==0 then
   sfx(7)
   ntt.target.upos(0)
   ntt.state=ntt.s_main
  end
 end

end

function draw_pswitch(ntt)

 sspr(8*8,8*2+ntt.pty,8,2,
      ntt.x,ntt.y+ntt.pty,8,2)

end

function load_telepods()

 local ccelx,ccely=
  shr(cx,3),shr(cy,3)
 for y=0,15 do
  for x=0,15 do
   local mx,my=ccelx+x,ccely+y
   if mget(mx,my)==28 then
    local ntt=
     create_telepod(
      mx*8,my*8)
    add(ntts,ntt)
    add(platforms,ntt)
    mset(mx,my,0)
    mset(mx,my+1,0)
   end
  end
 end

end

function create_telepod(x,y)
 local ntt=
  create_ntt(
   x,y,
   function() end,
   draw_ntt)

 --assign an id
 ntt.id=id
 id+=1

 --define names for all states
 ntt.s_init=0
 ntt.s_main=1

 --create teleport animation
 ntt.a_tel=create_anim(
  {
   create_8x8_frame(29),
   create_8x8_frame(30),
   create_8x8_frame(45)
  },
  1)

 ntt.w=7
 ntt.h=0
 ntt.tly=13
 ntt.pty=14
 ntt.ld={}
 ntt.i={}
 ntt.ih={{},{}}
 ntt.draw=draw_telepod
 ntt.visible=true
 ntt.on=false
 ntt.p=true
 ntt.post_update=update_telepod
 ntt.animcnt=0
 ntt.teldelay=0

 return ntt
end

function update_telepod(ntt)

 --track intersections
 ntt.i={}
 for o in all(ntts) do
  local tr={ntt.x+2,ntt.y+3,
     ntt.x+5,ntt.y+11}
  local orct=get_ntt_rect(o)
  add(dbgrcts,tr)
  add(dbgrcts,orct)
  if rects_int(orct,tr) and
     ntt!=o then
   add(ntt.i,o)
  end
 end
 --track intersections history
 add(ntt.ih,ntt.i)
 rem(ntt.ih)

 if ntt.state==ntt.s_init then
  ntt.state=ntt.s_main
 end

 if ntt.state==ntt.s_main then
  if #ntt.i==1 then
   local piece=ntt.i[1]

   if ntt.ih[1][1]!=piece and
      ntt.ih[2][1]==piece and
      (piece.xv!=0 or
       piece.yv!=0) then
    if ntt.teldelay==0 then
     teleport(ntt,piece)
    end
   end
  end
 end

 if ntt.animcnt>0 then
  ntt.animcnt-=1
  update_anim(ntt.a_tel)
 end

 if ntt.teldelay>0 then
  ntt.teldelay-=1
 end

end

function teleport(ntt,piece)
 local tid=ntt.id
 local tp=nil
 while true do
  tid=(tid+1)%id
  tp=find_ntt_id(tid)
  if tp.post_update==update_telepod then
   break
  end
 end
 if tp then
  wait_nbtn=true
  sfx(1)
  ntt.animcnt=3
  tp.animcnt=3
  ntt.teldelay=32
  tp.teldelay=32
  reset_anim(ntt.a_tel)
  reset_anim(tp.a_tel)
  piece.x=tp.x
  piece.y=tp.y+
          tp.tly-
          piece.h
  piece.xv=0
  piece.yv=0
  tp.i={piece}
  tp.ih={tp.i,tp.i}
 end
end

function draw_telepod(ntt)

 if ntt.teldelay>0 then
  pal(11,8)
  pal(3,2)
 end

 sspr(8*12,8*1,8,16,
      ntt.x,ntt.y)
 if ntt.animcnt>0 then
  draw_anim(ntt.a_tel,ntt.x,ntt.y+4,false,false)
 end
 pal()

end

function load_pulleys()

 local ccelx,ccely=
  shr(cx,3),shr(cy,3)
 for y=0,15 do
  for x=0,15 do
   local lmx,my=ccelx+x,ccely+y
   if mget(lmx,my)==42 then
    local p=
     create_pulley(
      lmx*8,my*8)
    add(ntts,p)
    --now search for right pulley
    local rmx=lmx
    repeat
     rmx+=1
    until mget(rmx,my)==43
    --find and create pullyvator
    --from lmx and rmx
    p.pv={} --pulley's pullyvators
    local miny=p.y
    local maxy=miny
    for x in all({lmx-1,rmx}) do
     local y=my
     while true do
      y+=1
      if y*8>maxy then maxy=y*8 end
      if (mget(x,y)==26) break
      mset(x,y,0)
      mset(x+1,y,0)
     end
     --here x and y point to the
     --left side of a pullyvator
     local pv=create_pullyvator(x*8,y*8)
     add(p.pv,pv)
     add(ntts,pv)
     add(platforms,pv)
     mset(x,y,0)
     mset(x+1,y,0)
    end
    miny+=8
    --here we know miny and maxy
    --and can assign them to both
    --pullyvators.
    for pv in all(p.pv) do
     pv.miny=miny
     pv.maxy=maxy
    end
   end
  end
 end

end

function create_pulley(x,y)

 local ntt=
  create_ntt(
   x,y,
   function() end,
   draw_ntt)

 ntt.draw=draw_pulley
 ntt.post_update=
  update_pulley

 ntt.visible=true

 return ntt

end

function update_pulley(ntt)

 local pv1,pv2=
  ntt.pv[1],ntt.pv[2]

 if ldweight(pv1)>ldweight(pv2) then
  pv1.ys=1
  pv2.ys=-1
 elseif ldweight(pv1)<ldweight(pv2) then
  pv1.ys=-1
  pv2.ys=1
 else
  pv1.ys=0
  pv2.ys=0
 end

end

function draw_pulley(ntt)

 for y=ntt.y+8,ntt.pv[1].y,8 do
  sspr(8*10,8*3,8,8,ntt.x,y)
 end
 for y=ntt.y+8,ntt.pv[2].y,8 do
  sspr(8*11,8*3,8,8,ntt.pv[2].x,y)
 end

end

function ldweight(ntt)
 local weight=0
 for o in all(ntt.ld) do
  weight+=o.weight
 end
 return weight
end

function create_pullyvator(x,y)

 local ntt=
  create_ntt(
   x,y,
   update_pullyvator,
   draw_ntt)

 --assign an id
 ntt.id=id
 id+=1

 ntt.w=15
 ntt.h=1
 ntt.tly=-2
 ntt.pty=0
 ntt.ld={}
 ntt.draw=draw_pullyvator
 ntt.visible=true
 ntt.p=true
 ntt.ys=0

 return ntt

end

function update_pullyvator(ntt)

 ntt.y+=ntt.ys
 if ntt.y<ntt.miny then
  ntt.y=ntt.miny
 elseif ntt.y>ntt.maxy then
  ntt.y=ntt.maxy
 end

end

function draw_pullyvator(ntt)

 spr(26,ntt.x,ntt.y,2,1)

end

-->8
--animation functions

function create_anim(frames,speed)
 return {counter=speed,
         frame=0,
         maxframes=#frames,
         speed=speed,
         frames=frames}
end

function reset_anim(anim)
 anim.frame=0
 anim.counter=anim.speed
end

function draw_anim(anim,
                   x,
                   y,
                   fh,
                   fv)
 frame=anim.frames[anim.frame+1]
 for i,v in pairs(frame) do
  local num=v[1]
  local xoffset=v[2]
  local yoffset=v[3]
  spr(num,
      x+xoffset,
      y+yoffset,
      1,
      1,fh,fv)
 end
end

function update_anim(anim)
 if anim.counter==0 then
  anim.counter = anim.speed
  anim.frame=(anim.frame+1)%anim.maxframes
 else
  anim.counter-=1
 end
end

function create_8x8_frame(num)

 return {{num,0,0}}

end

-->8
--map functions

function get_map(x,y)

 local cel_x,cel_y=
  shr(x,3),shr(y,3)
 local ccel_x,ccel_y=
  shr(cx,3),shr(cy,3)

 if cel_x>=ccel_x and
    cel_y>=ccel_y and
    cel_x<ccel_x+16 and
    cel_y<ccel_y+16 then
  return mget(cel_x,cel_y)
 else
  return 0
 end

end

function test_map(x,y)

 return fget(get_map(x,y),0)

end
-->8
--particles

function generate_particles(num,x,y,c)

 for i=1,num do
  local particle={
   x=x,
   y=y,
   xv=rnd(1)-.5,
   yv=rnd(1)-.5,
   dur=flr(rnd(20)),
   c=c
  }
  add(particles,particle)
 end

end

function update_particles()

 for particle in all(particles) do
  particle.x+=particle.xv
  particle.y+=particle.yv
  particle.dur-=1
  if particle.dur<=0 then
   del(particles,particle)
  end
 end

end

function draw_particles()

 for particle in all(particles) do
  pset(particle.x,particle.y,particle.c)
 end

end
__gfx__
00000000006666000000000000000000000000000000000000000000000000000000066665500000066550000000000000665500005000000e8000000e000000
000000000676655000000000000660000000000000066000006660000005656000006676665500000665500000000000006655000655000008800000e8808000
00000000666655550000000000666600000660000066660006666660006565660006676666555000066550000665500000665500666550500880000008880000
000000006cc65cc50770000000600600006666000060060005556500006565660006676666555000066550000066550000665500066655550888000000800000
0000000066a65a550766500000060600006006000006060006666660006666660006666666555000066550000066550000665500006655550000000000000000
00000000666555550066650000006600000606000000660005556500006565600000666666550000066550000665500000665500006665500000000000000000
00000000661c1c550660605000050600000606000006050000666660006060600000666665550000665555506655550000655500000666000000000000000000
00000000061c1c506006060500500600000060000060050000000000000000000000066655500000665555500065555000666500000060000000000000000000
0000000000000000000000000000000006500650000000000000000000000000777777777777777c777777777777777e0333333000cccc000000000000000000
000000000000000000000000000000000650065000000000000000000000000077777777777777c177777777777777edbbbbbbbb0c7777c000cccc0000000000
000000000000000000000000000000000650065000000000000000000000000077cccccccccccc1177eeeeeeeeeeeedd00000000c777777c0c7777c000000000
000000000000000000000000000000000650065000000000000000000000000077cccccccccccc1177eeeeeeeeeeeedd00000000c777777c0c7777c000000000
000000000000000000000000000000000650065000000000000000000000000077cccccccccccc1177eeeeeeeeeeeedd00000000c777777c0c7777c000000000
000000000000000000000000000000000650065000000000000000000000000077cccccccccccc1177eeeeeeeeeeeedd00000000c777777c0c7777c000000000
00000000000000000000000000000000065006500000000000000000000000007c111111111111117edddddddddddddd000000000c7777c000cccc0000000000
0000000000000000000000000000000006500650000000000000000000000000c111111111111111eddddddddddddddd0000000000cccc000000000000000000
00000000000000000000000000000000065006500056656656656656656656000000000056656656006666566566660000000000000000000000000000000000
00000000000820000000000000000000065006500612125000000000052121600000000000000000061212600621216000000000000000000000000000000000
00000000000820000000000000000000065006506120012500c000c0521002160000000000000000512001255210021500000000000cc0000000000000000000
0000000000082000000000000000000006500650620110150c000c0051011026000000000000000062011016610110260000000000c77c000000000000000000
00000000000820000000888800000000065006506101102500c000c052011016000000000000000061011026620110160000000000c77c000000000000000000
00000000001551000015522200000000065006506210021500000000512001260000000000000000521002155120012500000000000cc0000000000000000000
000000000555555005555550000000000650065006212150000000000512126008888820000000006521215005121256bbbbbbbb000000000000000000000000
00000000444444444444444400000000111111110056656656656656656656006666655500000000605555000055550603333330000000000000000000000000
00000000000000000000000000000000000000010065665665665665665665000000000000000000600000000000000600000000000000000000000000000000
0000000000e00e000000000055555555555555510621215000000000051212600000000000000000500000000000000500000000000000000000000000000000
0ee888200e8008e000000000666666666666666162100215000c000c512001260000000000000000600000000000000600000000000000000000000000000000
0e888820888008880000000000000000000000016101102500c000c0520110160000000000000000600000000000000600000000000000000000000000000000
008882000280082000000000000000000000000162011015000c000c510110260000000000000000500000000000000500000000000000000000000000000000
00082000002002000000000055555555555555516120012500000000521002160000000000000000600000000000000600000000000000000000000000000000
00000000000000000000000066666666666666610612125000000000052121600000000000000000600000000000000600000000000000000000000000000000
00000000000000000000000000000000000000010065665665665665665665000000000000000000500000000000000500000000000000000000000000000000
7777777e7777777b0777777077777777888808888888088808888880030303010bbbbbb0cccccccc0cccccc0aaaaaaaaaaaaaaa9000000000000000000000000
777777e2777777b37766666d666666662222082282220822887888823bbbbbb0bb7bbbb311111111cc7cccc1a9999994aaaaaa94000000000000000000000000
77eeee2277bbbb33767666dd555555552222082282220822878888220b3b33b1b7bbbb3310101010c7cccc11a9999994aa999944000000000000000000000000
77eeee2277bbbb33766ddddd050000500000000000000000878888223b3bb3b0b7bbbb3300000000c7cccc11a9999994aa999944000000000000000000000000
77eeee2277bbbb33766ddddd005005000888888808888888888882220b33b3b1bbbbb33301010101ccccc111a9999994aa999944000000000000000000000000
77eeee2277bbbb33766ddddd000550000822222208222222888822223bbbbbb0bbbb333300000000cccc1111a9999994aa999944000000000000000000000000
7e2222227b33333376dddddd000550000822222208222222882222220bb3b3b1bb33333310101010cc111111a9999994a9444444000000000000000000000000
e2222222b33333330dddddd00050050000000000000000000222222010101010033333300000000001111110a444444494444444000000000000000000000000
11111110000000000111111000000000000000000000000000000000000000000000000000000000000000001111111000000000000000000000000000000000
11111100000000001100000000000000011110000000000000111110011000000110000000000000000000001000000000000000000000000000000000000000
11000000000000001010000000000000010000000000000001111000000001100000011000000000000000001000000000000000000000000000000000000000
11000000000000001000000000000000000000000000000001100000000000000000000000000000000000001000000000000000000000000000000000000000
11000000000000001000000000000000000000000000000001000000011000000110000000000000000000001000000000000000000000000000000000000000
11000000000000001000000000000000000111110000000001000000000000000000000000000000000000001000000000000000000000000000000000000000
10000000000000001000000000000000000100000000000000000000000001100000000000000000000000001000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111000000000000111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10000000000000001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10000000000000001010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000103010500010101010000000000000000000000000100000000000000000000000000050101000000000000000000000101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
5050505050505050505050505050505041414141414141414141414141414141424242424242424242424242424242424141414141414141414141414141414145444444444444444444444444444444474747474747474747474747470000474a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a42424242424242424242424242424242
5050505050505050505050505050505041505060000000000000000050505041425252626262626262626262525252424150506060020200000000000050504145545454545454545454545454545445475757580000000000000000140000474a4a4a4a4a4a4a56564a56565656564a425200000000000000000000001c0042
5050505050505050505050505050505041506000000000000000000000505041425262000000000000000000005252424150600040404040000000000860504145545400000000000000000000545445475758000000000000002800000800474a4a4a4a4a4a4a56004a56000000004a42622100002a292929292b000a2c0042
5050505050505050505050505050505041600000000000000000000000005041426200010000000000000000000052424160000060606060000000252627004145540000000000000000000000005445475800484748000048474747474747474a56565600004a00000000000000004a42424242003a000000001a1b42424242
4040404040404040404040404040404041000000000000000000000000000041426202210000000000000000000000424160000000000000000000606060004145000000000000000000000000000045470000585858000058585858585858474a56020000004a00000001000000004a42526214003a00000000000062626242
4050505050600000000000004040404041000200000000000000000000000041424242424200000000000000000000424160210000000000000000000000004145002100000000000000000000080045470000000000000002000a00000000474a4a4a4a00004a00004a28000a01004a42620224003a0000000000000a000042
4050505060000000000000004040404041414141410000000000000000000041425252620000000000000000000000424141414100000000252627000000004145434343434343000043464343434345470000000000000048474747480000474a56561400004a00004a4a4a4a4a4a4a42424242003a00000000000042424242
4050506000000000000000004040404041505060000000000800000000000041425262000000000800000002010021424150506000000000606060000001004145545454004654000000140000005445470000000100000058585858580000474a56020000004a000056565614564a4a42526200003a00000000000062626242
405060000000000000000000404040404150600000000025262700000000004142620000000025262700004242424242415060000000000000000000002100414554540000465400000024000002004547000000280a000000000000000001474a4a4a4a0000560000000000000a4a4a42620200003a00000000000000000042
4060000000000000000000004040404041600000000000606060000000000041420000000000626262000000525252424160000000252627000000004141414145540000004654000000434343434345470000484748000000000000004847474a56565600000000004a00004a4a4a4a42424242003a00000000000000000042
4000000000000000000000001460604041000000000000000000000000000041420000000000000000000000005252424100000000606060000000001400034145000000004654000000000001005445470000585858000000000200005858474a00000000004a00004a0000564a4a4a42526262003a00000100000000000042
400a0001000200022100080024000a4041000000000000000000000200010a4142000000000000000000000000005242410000000000000000000000240a214145000000004654000000000028000a45470000000000090100002100000000474a00000000004a0000560200004a4a4a42620000003a42424242000000000042
4040404040404040404040404040404041000000000000000000414141414141420000000000000000000000000000424100000000000000000000004141414145000000000000000000004643434345470000000000181948474747480000474a00000000004a0000002800004a4a4a42000000003a42424242000000000042
5050505050505050505050505050505041000000000000010000146060606041420000000000000000060100000000424100020000000000000000001400044145000200000000000000001400005445470000000000000058585858580000474a00000000004a0c014a4a000000564a42001c00003a42424242000000000042
50505050505050505050505050505050410000210000002100002400000a004142000a000000000a0018190000000042410021000100000000000000240a2141450a2100010000090100002400020045470c01000002000000000000000000474a00000000004a18004a4a080028004a42002c001a1b42424242000000080042
5050505050505050505050505050505041414141414141414141414141414141424242424242424242424242424242424141414141414141414141414141414145434343434343181943434343434345471819474747474747474747474747474900000000004a00004a49494949494943434343434343434343434343434343
4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a454444444444444444444444444444444b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b484848484848484848484848484848484b4a4b4a4b4a4b4a4b4a4b4a4b4a4b4a44444444444444444444444444444444424242424242424242424242424242424a4a4a565656565656565656564a4a4a
4a56565656565656565656565656564a455454545454545454545454545402454b5b5b5b5b015b5b5b5b085b5b5b5b4b48561c565656565656565656565656484a56565656565656565656565656564b44541454545454545454545454545444425252525252525201525252521c52424a4a5600000000000000000000564a4a
4a4a4a0000000000000000000056564a455401000000000008000000000021454b5b5b0025262700002526270000004b48562c0000002a29292b0000000800484b56560000000000000000000000004a4402240000000000000000000000004442525200020c000028000000002c02424a4a5600000000004a00000000004a4a
4a1c140000000000010000000000564a452526270000004646460000004343454b5b010060606000006060600000004b48424242421a1b00003b0042000000484a56000000000000000000000000004b444646000000000000000000000000444252004c4c18194b4b0000004c4c4c424a1c0000000000004a00000000001c4a
4a2c2400010000004a0000000000004a455454000000005454540000001400454b00210a00000000000000000000004b4856565656000000003b0042280600484b00000600002800000600000800004a4454540000000000000000000000004442001c52520000524b000000525252424a2c0002392a292929292b0002002c4a
4a4a4a00280000004a0000000000004a45540000000000000000000000240a454b4b4b1819004c00004c00000000004b4856565600000000003b0042421819484a4a4a18194a4a4a4a18194a4a4a4a4b4400000002000000000000000000004442002c00000000004b000000000000424a4a4a4a003a000100001a1b4a4a4a4a
4a5614004a4a00004a00000a0008004a454343000000000000000000004343454b5b5b0000004c02001400000000034b4856560000000000003b0056560000484b56565600565656560000565656564a4400004646464646002a2929292b0044424c4c4c000000004b000000000000424a4a5656003a4a4a4a4a000056564a4a
4a022400024a00004a004a4a4a4a4a4a455414000000000000000000005454454b5b000000004c28002400000000284b4856000000000000001a1b00000000484a56560000000000000000000000004b44000046545454541a1b4646463b004442525252000000004b000000000000424a4a0000003a56565656000000004a4a
4a4a4a00214a05014a004a4a4a4a4a4a450a24000000000000000000000200454b00000000004c4c4c4c000000004c4b480000000000424242420000000000484b56000000000000000000000000004a440000460000000000000000013b004442000000000000004b000000002800424a4a0000003a00080000000000004a4a
4a5614004a4a18194a0056565656564a454343000000000000000000004343454b0000000000606060600000004c604b4800001c00005656565600001c0000484a00010000000000000000001c00004b44000046080021000000000a213b004442000000000000004b0000004c4c4c424a4a0000003a4a4a4a4a000000004a4a
4a02240003560000560000000056564a455400000000000000000000000354454b00000000006000000000004c60604b4800002c02000000000000022c0000484b00280000000000000000002c00004a440000464646464600004646463b004442000000000000004b000000525252424a4a0000003a564a5656000000004a4a
4a4a4a0021000000000000000000564a450221000000000000000000002100454b000000000000000000004c6060004b480000404040400000404040400000484a4b4a49494b4a4b4a49494b4a4b4a4b440000545454545400005454543b004442000000000000004b000000000000424a4a0000003a004a0000000000004a4a
4a5656004a000000000000000000004a454343000000000000000000004343454b0000000000000000004c606000004b480000606060600000606060600000484b56560000565656560000565656564a440000000000000000000000003b004442000000000000004b000000000000424a1c0000003a00560000000000001c4a
4a000000560000000000000000001c4a455454000001000000000000005454454b00000000000000004c60600000004b48400000001c000000000000000040484a1c000000000000000000000000004b440000000000000000000000003b0044420000000000000014000000000000424a2c000a003a0000000000000a002c4a
4a0a0000000000000000000000282c4a455400000021000000000c01000000454b020200000a0a214c6060000000004b4860400a002c0000010000000a4060484b2c000200020001000a000a0000004a44090100000000010000000a003b0044420a0000010000002400000800000a424a4a4a4a1a1b0000000000004a4a4a4a
49494949494949494949494949494949454343434343434343431819434343454b4b4b00004b4b4b4b4b4b4b4b4b4b4b484848484848484848484848484848484a4b4a4b4a4b4a4b4a4b4a4b4a4b4a4b441819444444444443434444441a1b444242424242000000424242424242424249494949494949494949494949494949
__sfx__
000100000c6200c6300c6300c6300c6300c620016200261001600266002565025650236501e6501a65016650126500d6500665002650000000150001500015000150003500015000150000000000000000000000
0001000017050200502c05034050300502e0502b050280502505022050200501e0501c0501b050180501705016050150501405012050110500f0500f0500d0500c0500b0500a0500a05008050060500505002050
000f00001b0501a0501b0501a0501b0501d0501f0500000000000000002005000000000000000000000000002405022050200501f0501d0501f0501d0500000000000000001b0500000000000000000000000000
0001000006750067500675007750077500875008750087500875009750097500a7500a7500a7500b7500b7500c7500c7500c7500d7500d7500d7500e7500e7500e7500f7500f7500f75010750107501175000000
0001000010750107501075010750107500f7500f7500f7500f7500f7500e7500e7500d7500d7500d7500c7500c7500b7500b7500a7500a7500a7500a750097500975008750087500775006750057500575004750
0001000005050070500705008050090500b0500d0500e0501565023650396503f6500b400016000d4000f40011400126501340014400174000f6501a4001d40000000000000a6000000000000000000000000000
00030000200500d400064001940000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000008000080000d6000a6500d6000e6000f600076001160026600116003565001600016000d4000f400114001260013400144002b6000f6001a4001d40000000000000a6000000000000000000000000000
010a00000c055100551305510055130551805513055180551c055180551c0551f0551c0551f055240550000500005000050000500005000050000500005000050000500005000050000500005000000000000000
0001000004670385303845038520384203851038510385103851038510385103851038510385103c500293002c700273002730026300253002530025300000000000000000000000000000000000000000000000
000100002670024700227001f7001c700187000f7000570001700076000b60011600196000164002640076400b640116401864023640276402a6402d640306500000000000000000000000000000000000000000
000100002675024750227501f7501c750187500f7500575001750076000b60011600196000160002600076000b600116001860023600276002a6002d600306000000000000000000000000000000000000000000
0003001c3f71000000000000000000000000003a710000000000000000000000000000000000003f7100000000000000000000000000000003a71035700000003570000000000000000000000000000000000000
01100020004351300000435000000543500000074350000000435000000043500000054350000007435000000043500000004350000007435000000b435000000043500000004350000007435000000b43500000
01100000042250422500225002250422504225002250022504225042250022500225042250422500225002250b2250b22500225002250b2250b22500225002250b2250b22500225002250b2250b2250022500225
011000000062500000006250000015625156000062500000006251560000625000001562500000156251562500625000000062515600156250000000625000000062515600006250000015625156251562515625
0110000000435130000043500000054350000007435000000043500000004350000005435000000743500000094350000009435000000e435000001043500000094350000009435000000e435000001043500000
011000000c2250e2250c2250e2250c2250e2250c2250e2250c225102250c225102250c225102250c225102251522518225152251822515225182251522518225152251c225152251c225152251c225152251c225
011000000c5240c5220c5220c5220c5220c5220c5220c5220c5220c5220c5220c5220c5220c5220c5220c52217521175221752217522175221752217522175221752217522175221752217522175221752217522
01100000231201812023120181201f7001f7001f7001d700241201812024120181202470024700000000000026120181202612018120000000000000000000002812000000281200000028120281202612024120
01100000231201812023120181201f7001f7001f7001d70024120181202412018120247002470000000000001f120181201f120181200000000000000000000021120000002112000000211201f1201d1201c120
00020000160501505014050140501305013050120501205011050100500f0500f0500f0500f0500e0500e0500d0500c0500b0500b0500a0500a05009050080500705006050050500505003050020500205001050
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
02 0d 42 43 44
04 08 42 43 44
01 0d 0e 43 0f
00 0d 0e 43 0f
00 10 11 43 0f
00 10 11 43 0f
00 0d 0e 12 0f
00 0d 0e 12 0f
00 10 11 13 0f
00 10 11 14 0f
00 10 11 13 0f
02 10 11 14 0f
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
