pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- winterwood
-- by jusiv

--[[
this was made in parts of 
october and december 2020 for 
the 2020 pico-8 advent calendar

the polytex function used is by
freds72 (@fsouchu on twitter)

all other code and assets were created
by henry "jusiv" stadolnik

to follow my work, check out my
twitter: @jusiv_

(c) 2020 j. henry stadolnik iv

controls
- move: ”ƒ‹‘
- rotate: Ž—

music tracks
--0.  title/ending
--5.  forest
--11. whiteout
--12. safe
]]

poke(0x5f2c,3)

function _init()
 --title
 show_title,title_trans,show_intro,ending = true,-40,false,false
 music"0"
 
 --camera and player
 cam_x,cam_y,cam_angle,cam_d,cax,cay = 915,410,325,0,0,0
 p_x,p_y,p_dx,p_dy,p_s = 960,356,0,0,4 --p_s is hitbox side length
 p_sp,p_sm,p_f = 1,false,0
 p_d,p_cam_d,p_show_d,p_new_d,p_new_d_wait = 0,1,1,1,0
 p_lock,p_stuck,p_rotwait,p_inside,inside_fade = true,false,0,false,0 --whether player is indoors
 respawn_x,respawn_y,respawn_trans,respawn_warp,respawn_time = 280,256,0,10,35
 fade_trans,fade_time = 0,10 --fade transition
 
 --dog
 play_whistle,whistletime,whistletimemax = false,0,30
 dog_start,dog_done,dog_wait,dog_waitmax = false,false,0,90
 dtarget,dtarget_x,dtarget_y,dbarkwait,dbarktime,dbarktimemax = 0,0,0,0,0,30
 dtargets = {104,13, 94,7, 101,18, 101,2, 106,11, 117,13} --pairs
 
 --actors
 smoke_wait,snow_clock,snow_wait,snow_pal = 5,0,2,0
 triggers,walls,planes,props,tprops,parts,trees,smoke = {},{},{},{},{},{},{},{},{}
 buckets,bucket_count = {},96
 
 --trees
 for y=0,55 do
  for x=0,127 do
   if mget(x,y) == 102 then
    add_tree(x+0.5,y+0.5,8,2.5+rnd(1.5))
    mset(x,y,33)
   elseif mget(x,y) == 238 then
    add_tree(x+0.5,y+0.5,6,1.5+rnd(1))
    mset(x,y,33)
   elseif mget(x,y) == 237 then
    add_tree(x+0.5,y+0.5,4,1+rnd(0.4))
    mset(x,y,33)
   end
  end
 end
 
 --house
 local hx1,hy1,hx2,hy2 = 115,39,120,45
 local hxm,hym = (hx1+hx2)/2,(hy1+hy2)/2
 -- left
 add_wall(hx1,hy1,0, hx1,hy2,2, 
           5,62, 6,2)
 -- front
 add_wall(hx1,hy2,0, hx2,hy2,4, 
           0,60, 5,4)
 add_tree(hx1+1.25,hy2+0.5,3,1,true)
 add_tree(hx2-1.25,hy2+0.5,3,1,true)
 -- right
 add_wall(hx2,hy2,0, hx2,hy1,2, 
           5,62, 6,2)
 -- back
 add_wall(hx2,hy1,0, hx1,hy1,2,
           5,60, 5,2)
 add_wall(hx2,hy1,2, hx1,hy1,4, 
           0,60, 5,2) 
 -- roof
 add_roof(hxm,hy1-0.5, hxm,hym,
           hx1-0.5,hy1-0.5, hx1-0.5,hym,
           2,4, 12,58, 3.5,3)
 add_roof(hxm,hym, hxm,hy2+0.5,
           hx1-0.5,hym, hx1-0.5,hy2+0.5, 
           2,4, 12,58, 3.5,3)
 add_roof(hxm,hy2+0.5, hxm,hym,
           hx2+0.5,hy2+0.5, hx2+0.5,hym,
           2,4, 12,58, 3.5,3)
 add_roof(hxm,hym, hxm,hy1-0.5,
           hx2+0.5,hym, hx2+0.5,hy1-0.5,
           2,4, 12,58, 3.5,3) 
 -- decor
 --  bed 
 add_dplane(119,39, 120,39,
            119,40.5, 120,40.5,
            0.375, 14,56.5, 1,1.5)
 add_dwall(119,40.5,0, 119,39,0.375,
            16,60, 1.5,0.375)
 add_dwall(119,39,0, 120,39,0.375,
            14,56, 1,0.375)
 add_dwall(120,39,0, 120,40.5,0.375,
            16,60, 1.5,0.375)
 add_dwall(120,40.5,0, 119,40.5,0.375,
            14,56, 1,0.375)
 --  chair
 add_dplane(115.5,40, 117,40,
            115.5,40.75, 117,40.75,
            0.25, 15,57.25, 1,0.75)
 add_dwall(117,40.125,0, 117,40.75,0.25,
            15,57.375, 0.375,0.25)
 add_dwall(115.5,40.75,0, 115.5,40.125,0.25,
            15,57.375, 0.375,0.25)
 add_dwall(117,40.75,0, 115.5,40.75,0.25,
            15,57.75, 1,0.25) 
 add_dwall(115.5,40.125,0.25, 117,40.125,0.75,
            15,57.25, 1,0.375)
 add_dwall(117,40.125,0.25, 115.5,40.125,0.75,
            15,57.25, 1,0.375)
 --  table
 add_dplane(115,43, 116,43,
            115,44, 116,44,
            0.5, 18,60, 1,1)
 add_dplane(116,43.15, 116.6,43.15,
            116,43.85, 116.6,43.85,
            0.25, 18,60, 1,1)
 --  sink
 add_dplane(120,43, 120,44,
            119.5,43, 119.5,44,
            0.5, 16,60.5, 1,0.5)
 add_dplane(120,44, 120,44.5,
            119.5,44, 119.5,44.5,
            0.5, 10.5,60, 0.5,0.5)
 add_dwall(120,43,0, 120,44.5,0.5,
            16,60, 1.5,0.5)
 add_dwall(119.5,43,0, 120,43,0.5,
            17.5,60, 0.5,0.5)
 add_dwall(119.5,44.5,0, 119.5,43,0.5,
            16,60, 1.5,0.5)
 add_dwall(120,44.5,0, 119.5,44.5,0.5,
            17.5,60, 0.5,0.5)
 --  bookshelf
 add_dplane(117,39, 118,39,
            117,39.5, 118,39.5,
            1, 17,60.5, 1,0.5)
 add_dwall(118,39.5,0, 117,39.5,1,
            20,60, -1,1)
 add_dwall(118,39,0, 118,39.5,1,
            10.5,61, 0.5,1)
 add_dwall(117,39,0, 118,39,1,
            19,60, 1,1)
 add_dwall(117,39.5,0, 117,39,1,
            10.5,61, 0.5,1)
 --  coat rack
 add_tprop(116,44.5, 115,44.5, 0,1,
           15,56, 1,1, 2,true)
 --  photos
 add_dwall(115,39.625,0.875, 115,40,1.375,
           12.625,56, 0.375,0.5)
 add_dwall(118.75,45,1.125, 119.25,45,1.625,
           10.5,60.5, 0.5,0.5)
 add_dwall(120,42.125,1, 120,41.5,1.5,
           12,56, 0.625,0.5)
 --  fireplace base
 add_dplane(115,42.5, 115,41.5,
            115.25,42.5, 115.25,41.5,
            1, 12,58, 1,0.25)
 add_dwall(115.25,41.5,0, 115.25,42.5,1,
            13,56, 1,1)
 add_dwall(115,41.5,0, 115.25,41.5,1,
            10,61, 0.25,1)
 add_dwall(115,42.5,0, 115,41.5,1,
            13,57, 1,1)
 add_dwall(115.25,42.5,0, 115,42.5,1,
            10,61, 0.25,1)
 --  fireplace shaft
 add_dwall(115.25,41.75,1, 115.25,42.25,2,
            10,60, 0.5,1)
 add_dwall(115,41.75,1, 115.25,41.75,2,
            10.25,61, 0.25,1)
 add_dwall(115,42.25,1, 115,41.75,2,
            10,60, 0.5,1)
 add_dwall(115.25,42.25,1, 115,42.25,2,
            10.25,61, 0.25,1)
 --  chimney
 --   left
 add_rooftop(117.25,41.75, 117.25,42.25,
             117.25,41.75, 117.25,42.25,
             4,5, 10,60, 0.5,1, 48)
 --   front
 add_rooftop(117.25,42.25, 117.75,42.25,
             117.25,42.25, 117.75,42.25,
             4,5, 10,60, 0.5,1, 48)
 --   right
 add_rooftop(117.75,41.75, 117.75,42.25,
             117.75,41.75, 117.75,42.25,
             4,5, 10,60, 0.5,1, 48)
 --   back
 add_rooftop(117.25,41.75, 117.75,41.75,
             117.25,41.75, 117.75,41.75,
             4,5, 10,60, 0.5,1, 48)
 --   top
 add_rooftop(117.25,41.75, 117.75,41.75,
             117.25,42.25, 117.75,42.25,
             5,5, 10.5,60, 0.5,0.5, 64)
 -- signs
 add_tprop(9.5,12, 9.5,13, 0,1.5,
           12,56.5, 1,1.375, 4)
 add_tprop(10.5,7.5, 11.5,7.5, 0,1,
           11,60, 1,1, 2)
 add_tprop(16,23, 16,24, 0,1,
           11,60, 1,1, 2)
 add_tprop(23,43, 23,42, 0,1,
           11,60, 1,1, 2)
 add_tprop(45,35, 46,35, 0,1,
           11,60, 1,1, 2)
 add_tprop(71,45.5, 72,45.5, 0,1,
           11,60, 1,1, 2)
 -- trees
 add_tree(110,12.5,4,1.2)
 add_tree(112,11,6,2)
 -- triggers
 add_message(35.5,31.5, 3,3,{12,13,14,15},0)
 add_message(98,22,     3,2,{16,17,18,19,20,21},1)
 add_message(117.5,41.5,  1.5,1.5,{24,25,26,27,28,29,30,31,32,33,34,35},2)
 -- npcs
 add_dog({118,18, 121,23, 119,29, 118,36, 113,39, 113.5,46.5, 117.25,46, 118,42})
 add_jones(117.5,41.5)
 
 --sprites
 spr_broken_ice = {}
 spr_broken_ice[0b0000]=36 --0 neighbors
 spr_broken_ice[0b0100]=21 --1 neighbor
 spr_broken_ice[0b1000]=22
 spr_broken_ice[0b0001]=37
 spr_broken_ice[0b0010]=38
 spr_broken_ice[0b1100]=23 --2 neighbors
 spr_broken_ice[0b0011]=39
 spr_broken_ice[0b0101]=24
 spr_broken_ice[0b0110]=25
 spr_broken_ice[0b1001]=40
 spr_broken_ice[0b1010]=41
 spr_broken_ice[0b1011]=53 --3 neighbors
 spr_broken_ice[0b0111]=54
 spr_broken_ice[0b1110]=55
 spr_broken_ice[0b1101]=56
 spr_broken_ice[0b1111]=57 --4 neighbors

 --text
 lmax,text_change,text_wait,text_delay,text_mute = 14,true,15,0,2
 text_queue,text_lines,text_y,img_y,img_show = {1},{},64,-16,false
 dialogue = {
  --title (1)
  "00press Ž or —",
  --intro (2-7)
  "01mr. jones and his dog always rest at the bench by my house.",
  "02whenever she'd wander off, he'd call her back with his trusty whistle.",
  "03but one winter day, i noticed he left his whistle behind.",
  "04a snowstorm was coming, and i couldn't bear the thought",
  "05of him stuck searching for it out in the freezing cold.",
  "06so i decided to bring it to him myself.",
  --area 1: forest (8-11)
  "00mr. jones lives in a cabin by the lake in these woods.",
  "00the trail seems to be marked so i'll be fine.",
  "00...unless the snow's covered parts of it.",
  "00”ƒ‹‘: move/Ž—: rotate",
  --area 2: lake (12-15)
  "00alright, i made it to the lake!",
  "07the hill mr. jones lives on is on the other side.",
  "00it looks like i'll have to walk across though...",
  "00but at least it looks mostly frozen?",
  --freezing (16-21)
  "00oh man oh man what am i gonna do now?",
  "00i can't see anything in this storm...",
  "00but i'll freeze to death if i stay out here!",
  "00...",
  "03wait, the dog whistle!",
  "08i should be close, perhaps his dog can hear it from here!",
  -- (wait here w/ sfx)
  --dog (22-23)
  "20*bark!*",
  "00that sounded like her! maybe i can follow her to safety!",
  --ending (24-35)
  "11millie, there you are girl!",
  "10don't scare an old man like that, running off into the storm!",
  "15oh! i'm sorry, i nearly missed you there!",
  "10what brings you all the way out here in this weather?",
  "03i was worried you'd be out there looking for this, mr. jones.",
  "02you dropped it at the bench you stop at by my house.",
  "10oh!!! and here i thought i'd lost it for good under all this snow!",
  "10thank you kindly for trekking out here to bring it back!",
  "10but oh,/you must be freezing now...",
  "10why don't you stay a bit and i'll fix you some hot cocoa as thanks!",
  "09 t h e ~ e n d",
  }
end
-->8
--actors

-- ’ handling special tiles
function break_ice(mx,my)
 --set to 1x1 hole
 mset(mx,my,36) --set to 1x1 pit
 --update neighbors
 if flag(mx,my-1,7) then
  update_broken_ice(mx,my-1)
 end
 if flag(mx,my+1,7) then
  update_broken_ice(mx,my+1)
 end
 if flag(mx-1,my,7) then
  update_broken_ice(mx-1,my)
 end
 if flag(mx+1,my,7) then
  update_broken_ice(mx+1,my)
 end
 update_broken_ice(mx,my)
end

function update_broken_ice(mx,my)
 --bit order: ”ƒ‹‘
 local bits = 0b0000
 if flag(mx,my-1,7) then
  bits = bor(bits,0b1000)
 end
 if flag(mx,my+1,7) then
  bits = bor(bits,0b0100)
 end
 if flag(mx-1,my,7) then
  bits = bor(bits,0b0010)
 end
 if flag(mx+1,my,7) then
  bits = bor(bits,0b0001)
 end
 mset(mx,my,spr_broken_ice[bits])
 rsfx(18)
end

function crack1_ice(mx,my)
 mset(mx,my,18+16*flr(rnd(3)))
 rsfx(11)
end

function crack2_ice(mx,my)
 mset(mx,my,mget(mx,my)+1)
 rsfx(11)
end

-- ’ creating actors
function add_message(mx,my,mw,mh,msg_set,scene)
 local p = {
  x=mx*8,
  y=my*8,
  w=mw*4,
  h=mh*4,
  msg=msg_set,
  scene=scene,
  effect=show_message
 }
 add(triggers,p)
end


function make_prop(x,y,w,h,sp)
 --makes a sprite prop
 local p={
 	sp=sp,
 	sm=false,
 	x=x*8,
 	y=y*8,
 	w=w,
 	h=h,
 	rx=0,
 	ry=0,
 	shad=draw_shadow,
 	draw=draw_sprite,
 }
 return p
end

function add_prop(x,y,w,h,sp)
 --makes and adds a sprite prop
 add(props,make_prop(x,y,w,h,sp))
end

function add_dog(mcoords)
 --makes the dog
 local p=make_prop(mcoords[1],mcoords[2],1,1,68)
 p.draw,p.upd = draw_npc,upd_dog
 p.pathcoords = mcoords --pairs
 p.pathindex,p.f,p.d,p.cam_d,p.door = 1,0,1,1,false
 add(parts,p)
end

function add_jones(x,y)
 --makes mr. jones
 local p=make_prop(x,y,1,1,84)
 p.draw,p.upd,p.f,p.d,p.cam_d = draw_npc,upd_jones,0,1,1
 add(parts,p)
end

function add_tree(x,y,r,h,outonly)
 --makes a sprite prop
 --outonly is optional
 local p={
 	x=x*8,
 	y=y*8,
 	r=r,
 	a=rnd(0.25)-0.125,
 	z=h*8,
 	rx=0,
 	ry=0,
  leaftex={},
  leafverts={},
 	shad=draw_circshadow,
 	draw=draw_tree,
 	outonly=outonly or false
 }
 for i=0,3 do
  add(p.leaftex,11+flr(rnd(9)))
 end
 add(trees,p)
end

function add_tprop(x1,y1,x2,y2,z1,z2,tx,ty,tw,th,radius,inside)
 --makes a 3d plane prop
 local p={
 	x1=x1*8,
 	y1=y1*8,
 	x2=x2*8,
 	y2=y2*8,
 	z1=z1*8,
 	z2=z2*8,
 	tx=tx,
 	ty=ty,
 	tw=tw,
 	th=th,
		rxfar=0,
		ryfar=0,
		rxnear=0,
		rynear=0,
 	r=radius,
 	inside=inside or false,
 	flipped=false,--whether draw direction reversed
 	shad=draw_circshadow2,
 	draw=draw_tprop,
 }
 add(tprops,p)
end


function make_wall(x1,y1,z1,x2,y2,z2,tx,ty,tw,th)
 --makes a vertical plane quad
 local p={
  x1=x1*8,--start 3d coord
  y1=y1*8,
  z1=z1*8,
  x2=x2*8,--end 3d coord
  y2=y2*8,
  z2=z2*8,
  tx=tx,--start texture coord
  ty=ty,
  tw=tw,--texture dimensions
  th=th,
  normal=-atan2(x2-x1,y2-y1),--precompute normal
  verts={},
  flipped=false,--whether draw direction reversed
  shad=draw_none,
  draw=draw_wall,
 }
 return p
end

function add_wall(x1,y1,z1,x2,y2,z2,tx,ty,tw,th)
 add(walls,make_wall(x1,y1,z1,x2,y2,z2,tx,ty,tw,th))
end

function add_dwall(x1,y1,z1,x2,y2,z2,tx,ty,tw,th)
 -- make a decorative indoor wall
 local p = make_wall(x1,y1,z1,x2,y2,z2,tx,ty,tw,th)
 p.iswall,p.draw = true,draw_deco
 add(walls,p)
end

function make_plane(x1,y1,x2,y2,
                   x3,y3,x4,y4,
                   z1,z2,tx,ty,tw,th,
                   roof,sortshift)
 -- plane with optional slope 
 --   1+-----+2 <-z2
 --   /     /:      
 -- 3+-----+4'  <-z1
 local p={
  x1=x1*8,--upper coord 1
  y1=y1*8,
  x2=x2*8,--upper coord 2
  y2=y2*8,
  x3=x3*8,--lower coord 1
  y3=y3*8,
  x4=x4*8,--lower coord 2
  y4=y4*8,
  z1=z1*8,--z range
  z2=z2*8,
  tx=tx,--start texture coord
  ty=ty,
  tw=tw,--texture dimensions
  th=th,
  isroof=roof,
  sortshift=sortshift or 0,
  verts={},
  shad=draw_none,
  draw=draw_roof,
 }
 return p
end

function add_roof(x1,y1,x2,y2,
                   x3,y3,x4,y4,
                   z1,z2,tx,ty,tw,th)
 add(planes,make_plane(x1,y1,x2,y2,
                   x3,y3,x4,y4,
                   z1,z2,tx,ty,tw,th,
                   true,8))
end

function add_rooftop(x1,y1,x2,y2,
                   x3,y3,x4,y4,
                   z1,z2,tx,ty,tw,th,shift)
 add(planes,make_plane(x1,y1,x2,y2,
                   x3,y3,x4,y4,
                   z1,z2,tx,ty,tw,th,
                   true,shift))
end

function add_dplane(x1,y1,x2,y2,
                   x3,y3,x4,y4,
                   z,tx,ty,tw,th)
 -- make a decorative indoor plane
 local p = make_plane(x1,y1,x2,y2,
                   x3,y3,x4,y4,
                   z,z,tx,ty,tw,th,
                   false)
 p.iswall,p.draw = false,draw_deco
 add(planes,p)
end

function add_player()
 local respawn = respawn_trans > 0
 local p = {
  sp=p_sp+p_f,
  sm=p_sm,
  w=1,
  h=1,
  rx=32,
  ry=respawn and 34 or 32,
  -- skip draw if respawning (ternary)
  shad=(respawn or show_title) and 
       draw_none or draw_shadow,
  -- skip draw if underwater (ternary)
  draw=(show_title or (respawn and (p_f >= 4 or respawn_trans <= respawn_warp))) and 
       draw_none or draw_sprite
  }
 add(buckets[32],p)
end

function add_footprint(d)
 --calculate position
 local offset,aa = 1.5,cam_angle/360
 if p_f == 2 then
  offset *= -1
 end
 if p_cam_d%2 == 0 then
  offset /= 2
 end
 local pos_x = cam_x+offset*cos(aa)-0.5*sin(aa)
 local pos_y = cam_y+offset*sin(aa)-0.5*cos(aa)
  
 --only create if on snow
 if pixel_color(pos_x,pos_y) == 7 then
  local p={
   x=pos_x,
   y=pos_y,
   d=d,
   l=1.5,
   c=6,
   t=40,
   rx=0,
   ry=0,
   shad=draw_ray,
   draw=draw_none,
   upd=upd_footprint
  }
  add(parts,p)
  rsfx(8)
 else
  rsfx(15)
 end
end

function add_snow()
 local ir,ia,z = 4+rnd(120),rnd(1),64+rnd(20)
 local p={
  x=p_x+ir*cos(ia),
  y=p_y+ir*sin(ia),
  zm=z,
  z=z,
  zs=0.05+rnd(0.7),--fall speed
  ds=rnd(0.2),--drift speed
  da=rnd(1),--drift direction
  r=rnd(2),
  c=6+rnd(1.3),
  rx=0,
  ry=0,
  shad=draw_none,
  draw=draw_snow,
  upd=upd_snow
 }
 add(parts,p)
end


function add_smoke()
 local z1=40+rnd(10)
 local p={
  x=940,
  y=336,
  zm=z1+rnd(20),
  z=z1,
  zs=0.05+rnd(0.2),--rise speed
  ds=rnd(0.2),--drift speed
  da=rnd(1),--drift direction
  r=rnd(2),
  rx=0,
  ry=0,
  shad=draw_none,
  draw=draw_smoke,
 }
 add(smoke,p)
end

-- ’ update actors
function upd_footprint(p)
 p.t -= 1
 if p.t <= 0 then
  del(parts,p)
 end
end

function upd_snow(p)
 p.z -= p.zs
 p.x += p.ds*cos(p.da)
 p.y += p.ds*sin(p.da)
 p.da += rnd(0.03)
 if p.z < 0 then
  del(parts,p)
 end
end

function upd_smoke(p)
 p.z += p.zs
 p.x += p.ds*cos(p.da)
 p.y += p.ds*sin(p.da)
 p.da += rnd(0.05)
 if p.z > p.zm then
  p.r -= 0.2
  p.zs -= rnd(0.02)
  if p.r <= 0 then
   del(smoke,p)
  end
 else
  p.r += rnd(0.1)
  p.zs += rnd(0.01)
 end
end

function upd_dog(p)
 local pindex,pcoords,moving = p.pathindex*2,p.pathcoords,false
 --bark anim
 if dbarktimemax-dbarktime < 5 then
  p.sp,p.f = 67,0
 elseif dbarktime > 10 then
  p.sp,p.f = 68,0
 --walk or sit
 else
  -- if at end of path, look at player
  if pindex > #pcoords then
   local lx,ly=p_x-p.x,p_y-p.y
   local lookd = atan2(lx,-ly)*4
   if lookd >= 3.5 then
    p.d = 0
   else
    p.d = max(0,flr(lookd+0.5))
   end
  -- otherwise, advance along path
  else
   local x,y,nx,ny,spd = p.x,p.y,8*pcoords[pindex-1],8*pcoords[pindex],2
   if x != nx and y != ny then
    local dx,dy = nx-x,ny-y
    local dst,da = 128*dist(dx/128,dy/128),atan2(dx,dy)
    if dst < spd then
     p.x,p.y = nx,ny
    else
     local pdx,pdy=spd*cos(da),spd*sin(da)
     p.x += pdx
     p.y += pdy
     --update angle
     local newd = atan2(pdx,-pdy)*4
     if newd >= 3.5 then
      p.d = 0
     else
      p.d = max(0,flr(newd+0.5))
     end
     moving = true
    end
    --make door sound when passing through
    if not p.door and flag(p.x\8,p.y\8,2) then
     sfx"25"
     p.door = true
    end
   else
    -- wait for player to approach
    local pdx,pdy = p_x-x,p_y-y
    local pdst = 128*dist(pdx/128,pdy/128)
    if pdst < 24 or (dog_done and p.pathindex < 7 and p_x >= 960 and p_y > 312) then
     -- bark and move if approached
     -- or if player goes around far side of house
     p.pathindex += 1
     bark()
     -- block off backtracking
     if p.pathindex == 4 then
      p_stuck = true
     end
    end
   end
  end
  --update sprite
  p.cam_d = (p.d+cam_d)%4
  if p.cam_d == 1 then
   p.sp = 68
  elseif p.cam_d == 3 then
   p.sp = 72
  else
   p.sp = 76
  end
  p.sm = (p.cam_d == 2)
  if moving then
   p.f = (p.f+0.5)%4
  else
   p.f = 0
  end
 end
 p.sp += p.f
end

function upd_jones(p)
 --[[look at player
 local lx,ly=p_x-p.x,p_y-p.y
 local lookd = atan2(lx,-ly)*4
 if lookd >= 3.5 then
  p.d = 0
 else
  p.d = max(0,flr(lookd+0.5))
 end
 --]]
 --change sprite
 p.cam_d = (p.d+cam_d)%4
 if p.cam_d == 1 then
  p.sp = 84
 elseif p.cam_d == 3 then
  p.sp = 86
 else
  p.sp = 88
 end
 p.sm = (p.cam_d == 2)
 --idle animation
 p.f = (p.f+0.125)%2
 p.sp += p.f
end

function show_message(p)
 text_queue,text_change,p_rotwait = p.msg,true,24
 --freeze
 if p.scene == 1 then
  snow_pal,text_delay,p_stuck,dog_start,play_whistle,text_mute = 4,45,true,true,true,1
  music(11,2000)
 elseif p.scene == 2 then
  ending = true
 end
 del(triggers,p)
end

-- ’ sort actors
-- cax=cos(cam_angle),cay=sin(cam_angle)
function map_to_screen(p)
 local xpos,ypos = p.x-cam_x,p.y-cam_y
 p.rx = xpos*cax+ypos*cay+32
 p.ry = ypos*cax-xpos*cay+32
 --queue for rendering
 if mid(p.rx,-16,80) == p.rx and
    mid(p.ry,0,bucket_count) == p.ry then
  add(buckets[flr(p.ry)+1],p)
 end
end

function smoke_to_screen(p)
 local xpos,ypos = p.x-cam_x,p.y-cam_y
 p.rx = xpos*cax+ypos*cay+32
 p.ry = ypos*cax-xpos*cay+32
 --queue for rendering
 add(buckets[bucket_count],p)
end

function tree_to_screen(p)
 local xpos,ypos,z,r = p.x-cam_x,p.y-cam_y,p.z,p.r
 local brx = xpos*cax+ypos*cay+32
 local bry = ypos*cax-xpos*cay+32
 --cancel early if not drawing
 if mid(brx,-r,64+r) != brx or
    bry < -r or bry-z > 64 then
  return
 end
 --calculate tree positions
 p.rx,p.ry = brx,bry
 local order = {2,3,1,0} --sort order of leaves
 for i=0,3 do
  local id,ang = order[1+(cam_d+i)%4],p.a+i/4
  local xp,yp = xpos+r*cos(ang),ypos-r*sin(ang)
  p.leafverts[id+1] = make_v(
    xp*cax+yp*cay+32,
    yp*cax-xp*cay+32,0,
    p.leaftex[i+1],61)
 end
 --queue for rendering
 add(buckets[mid(1,flr(bry),bucket_count)],p)
end

function tprop_to_screen(p)
 --get camera-based coords
 local x1,y1,x2,y2 = p.x1-cam_x,p.y1-cam_y,p.x2-cam_x,p.y2-cam_y
 --calculate screen coords
 local rx1 = (x1*cax+y1*cay+32)
 local ry1 = (y1*cax-x1*cay+32)
 local rx2 = (x2*cax+y2*cay+32)
 local ry2 = (y2*cax-x2*cay+32)
 --determine draw direction
 if ry1 <= ry2 then
  p.rxfar,p.ryfar,p.rxnear,p.rynear,p.flipped = rx1,ry1,rx2,ry2,false
 else
  p.rxfar,p.ryfar,p.rxnear,p.rynear,p.flipped = rx2,ry2,rx1,ry1,true
 end
 --queue for rendering if on-screen
 if max(ry1,ry2)-p.z1+p.r >= 0 and min(ry1,ry2)-p.z2 < 64 then
  add(buckets[mid(1,bucket_count,flr((ry1+ry2)/2))],p)
 end
end

function wall_to_screen(p)
 --get camera-based coords
 local x1,y1,x2,y2,z1,z2,tx,ty,tw,th = p.x1-cam_x,p.y1-cam_y,p.x2-cam_x,p.y2-cam_y,p.z1,p.z2,p.tx,p.ty,p.tw,p.th
 --calculate screen coords
 local rx1 = x1*cax+y1*cay+32
 local ry1 = y1*cax-x1*cay+32
 local rx2 = x2*cax+y2*cay+32
 local ry2 = y2*cax-x2*cay+32
 --determine depth
 local sorty,endy = ry1,ry2
 if ry1 > ry2 then
  -- y2 is far y
  sorty,endy = ry2,ry1
 end
 --render if on-screen
 if endy > 0 and sorty-z2 < 64 then
  --store rendering verts
  p.verts = {make_v(rx1,ry1,z2,tx,ty),--v1
             make_v(rx2,ry2,z2,tx+tw,ty),--v2
             make_v(rx2,ry2,z1,tx+tw,ty+th),--v4
             make_v(rx1,ry1,z1,tx,ty+th)}--v3
  --queue for rendering
  add(buckets[mid(1,bucket_count,flr(sorty))],p)
 end
end

function plane_to_screen(p)
 --get camera-based coords
 local x1,y1,x2,y2,x3,y3,x4,y4,z1,z2,tx,ty,tw,th = p.x1-cam_x,p.y1-cam_y,p.x2-cam_x,p.y2-cam_y,p.x3-cam_x,p.y3-cam_y,p.x4-cam_x,p.y4-cam_y,p.z1,p.z2,p.tx,p.ty,p.tw,p.th
 --calculate screen coords
 local rx1 = x1*cax+y1*cay+32
 local ry1 = y1*cax-x1*cay+32
 local rx2 = x2*cax+y2*cay+32
 local ry2 = y2*cax-x2*cay+32
 local rx3 = x3*cax+y3*cay+32
 local ry3 = y3*cax-x3*cay+32
 local rx4 = x4*cax+y4*cay+32
 local ry4 = y4*cax-x4*cay+32
 --determine depth
 --based on lowest vertex on screen
 local botneary = ry4
 if ry3 > ry4 then
  botneary = ry3
 end
 --store rendering verts
 p.verts = {make_v(rx1,ry1,z2,tx,ty),--v1
            make_v(rx2,ry2,z2,tx+tw,ty),--v2
            make_v(rx4,ry4,z1,tx+tw,ty+th),--v4 
            make_v(rx3,ry3,z1,tx,ty+th)}--v3
 --queue for rendering
 if p.isroof then
  -- sort by near bottom coord
  -- +8 offset ensures player won't overlap roof
  add(buckets[mid(1,bucket_count,flr(botneary+p.sortshift))],p)
 else
  -- sort by far top coord
  add(buckets[mid(1,bucket_count,flr(min(ry1,ry2,ry3,ry4)))],p)
 end
end


-- ’ drawing actors
function draw_none(p)
end

function draw_shadow(p)
 ovalfill(p.rx-4*p.w,p.ry-3,
          p.rx+4*p.w-1,p.ry,
          6)
end

function draw_circshadow(p)
 circfill(p.rx,p.ry,p.r*0.8,6)
end

function draw_circshadow2(p)
 circfill((p.rxfar+p.rxnear)/2,(p.ryfar+p.rynear)/2,p.r,6)
end

function draw_snow(p)
 if not p_inside then
  circ(p.rx,p.ry-p.z,p.r*(p.z/p.zm),p.c)
 end
end

function draw_smoke(p)
 if not p_inside then
  fillp(0b0101101001011010.1)
  circfill(p.rx,p.ry-p.z,p.r,13)
  fillp()
 end
end

function draw_sprite(p)
 spr(p.sp,
     p.rx-8*p.w+4,
     p.ry-8*p.h,
     p.w,p.h,
     p.sm,false)
end

function draw_npc(p)
 --only draw if player in same
 --space (indoors vs outdoors)
 if flag(p.x\8,p.y\8,1) == p_inside then
  draw_sprite(p)
 end
end

function draw_pixel(p)
 pset(p.rx,p.ry,p.c)
end

function draw_ray(p)
 local aa = -(p.d+cam_angle/360)
 line(p.rx,p.ry,
      p.rx+p.l*cos(aa),
      p.ry+p.l*sin(aa),
      p.c)
end

function draw_tprop(p)
 --if indoors only draw indoors
 if p.inside and (show_title or title_trans > 0 or not p_inside) then
  return
 end
 
 local xf,yf,xn,yn,z1,z2,tx = p.rxfar,p.ryfar,p.rxnear,p.rynear,p.z1+1,p.z2+1,p.tx
 local len = dist(p.x2-p.x1,p.y2-p.y1)
 local texx,texstepx,texstepy = tx,((p.tw)/(len/8))/8,p.th/(z2-z1)
 --draws based on furthest coord
 if p.flipped then
  texx = tx+p.tw-0.125
  texstepx *= -1 --reverse step direction
 end
 -- draw tline plane
 local stepx,stepy= (xn-xf)/len,(yn-yf)/len
 for i=0,len-1 do
  local xx,yy = xf+stepx*i,yf+stepy*i+2
  tline(xx,yy-z2, xx,yy-z1,
        texx+texstepx*i,p.ty,0,texstepy)
 end
end

function draw_wall(p)
 -- back/frontface culling
 local asum = abs(cam_angle/360+p.normal)%1
 local show,fading = min(asum,1-asum) <= 0.25,inside_fade > 0 and not p.isprop
 if p_inside then
  -- invert culling indoors
  show = not show
 end
 -- override regular drawing rule if fading
 if fading then
   -- back walls never fade
   if not (show ~= p_inside) then
    fading = false
   end
   show = true
 end
 -- draw plane
 if show then
  --draw as textured polygon
  polytex(p.verts,fading)
 end
end

function draw_roof(p)
 --don't draw if player indoors
 local fading = inside_fade > 0
 if p_inside and not fading then
  return
 end
 --draw as textured polygon
 polytex(p.verts,fading)
end

function draw_tree(p)
 --skip if outdoors only and inside
 if p.outonly and p_inside then
  return
 end
 
 local x1,y1,z,r = p.rx,p.ry,p.z,p.r
 local texstepx,texstepy = 1/r,3/z
 rect(x1,y1,x1,y1-z,3)
 circfill(x1,y1-2,r/2)
 for i=1,4 do
  local v = p.leafverts[i]
  local x2,y2,tx,ty = v.x,v.y,v.u+1,v.v
  -- draw tline plane
  local stepx,stepy = (x2-x1)/r,(y2-y1)/r
  for j=1,r do
   local xx,yy = x1+stepx*j,y1+stepy*j
   tline(xx,yy-z, xx,yy,
         tx-texstepx*j,ty,0,texstepy)
  end
 end
end

function draw_deco(p)
 --only draw if player indoors
 if not p_inside then
  return
 end
 --draw as textured polygon
 if p.iswall then
  draw_wall(p)
 else
  polytex(p.verts,false)
 end
end
-->8
--main
function dist(dx,dy,dz)
 -- dz is optional
 local z = dz or 0
 return sqrt(dx*dx+dy*dy+z*z)
end


function make_v(x,y,z,u,v)
 return {x=x,y=y,z=z,u=u,v=v}
end


function pixel_color(x,y)
 local pos_sp = mget(x\8,y\8)
 return sget(8*(pos_sp%16)+flr(x)%8,
 												8*(pos_sp\16)+flr(y)%8)
end


function flag(mx,my,f)
 return fget(mget(mx,my),f)
end

function collide(x,y,f,every)
 --handle player hitbox collisions
 local ss = p_s/16
 local f1 = flag(x-ss,y-ss,f)
 local f2 = flag(x+ss,y-ss,f)
 local f3 = flag(x-ss,y+ss,f)
 local f4 = flag(x+ss,y+ss,f)
 if every then
  --if every check detects the flag 
  return f1 and f2 and f3 and f4
 else
  --if any checks detect the flag
  return f1 or f2 or f3 or f4
 end
end

function canmove(x,y)
 local mx,my = x/8,y/8
 -- stop at walls
 if collide(mx,my,0) or (p_stuck and collide(mx,my,3)) then
  return false
 -- prevent crossing from inside
 -- to outside unless on doorway
 elseif not collide(mx,my,2) then
  if p_inside then
   -- walking inside
   -- allow movement if entirely on floor
   return collide(mx,my,1,true)
  else
   -- walking outside
   -- allow movement if not on floor
   return not collide(mx,my,1)
  end
 end
 -- otherwise, allow movement
 return true
end


function startfade(n)
 fade_time = n or fade_time
 fade_trans = fade_time
end


function next_dog(wait)
 dtarget += 1
 local d2 = dtarget*2
 if d2 <= #dtargets then
  dtarget_x = dtargets[d2-1]*8
  dtarget_y = dtargets[d2]*8
  dbarkwait = wait or 5
 else
  dog_done = true
  p_stuck = false
  --prevent backtracking
  fset(224,0,true)
 end
end

function rsfx(n)
 sfx(n+flr(rnd"3"))
end

function bark()
 dbarktime = dbarktimemax
 rsfx(21)
end

function whistle()
 whistletime,play_whistle = whistletimemax,false
 sfx"24"
end


function _update()
 --fade effect
 if fade_trans > 0 then
  if not ending or fade_trans > fade_time/2 then
   fade_trans -= 1
   if ending and fade_trans <= fade_time/2 then
    music(0,3000)
   end
  end
 end
 
 --advance title
 if show_title then
  if title_trans < 10 then
   title_trans += 1
  end
 elseif title_trans > 0 then
  title_trans -= 1
  if title_trans <= 0 then
   text_change = true
   text_queue = {2,3,4,5,6,7}
   show_intro = true
   p_x,p_y,cam_angle = 47,85,270
   music(5,1000)
  end
 end
 
 --display text
 local texttargety,imgtargety = 68,-16
 if not text_change and (not show_title or title_trans > 0) then
  texttargety = 74-6*#text_lines
  imgtargety = texttargety/2
 end
 if text_delay > 0 then
  text_delay -= 1
  if text_delay <= 0 and text_lines[1] == 0 then
   sfx"26"
  end
 else
  text_y += (texttargety-text_y)/2
  img_y += (imgtargety-img_y)/2
 end
 -- show dialogue can advance
 if text_y < texttargety+1 then
  text_wait += 1
  if text_wait > 45 then
   text_wait = 15
  end
 end
 -- advance to next dialogue
 if text_change and text_y > 63 then
  text_change = false
  if #text_queue > 0 then
   local nextline = text_queue[1]
   text_lines = splittext(dialogue[nextline])
   del(text_queue,nextline)
   img_show = #text_lines >= 2 and text_lines[2] > 0
   --fade out at ending
   if ending and #text_queue <= 1 then
    startfade(30)
   --play appropriate talk sound
   elseif text_mute <= 0 then
    if text_lines[1] == 0 then
     sfx"26"
    elseif text_lines[1] == 1 then
     sfx"27"
    end
   else
    text_mute -= 1
   end
  else
   text_lines = {}
   img_show = false
   -- end intro sequence
   if show_intro then
    show_intro,fade_trans,fade_time,p_lock,text_queue,text_change,text_delay,text_mute = false,15,30,false,{8,9,10,11},true,45,1
   end
   -- play whistle
   if play_whistle then
    whistle()
   end
  end
 end

 --actor updates
 for i=#triggers,1,-1 do
  local t = triggers[i]
  local x,y,w,h = t.x,t.y,t.w,t.h
  if mid(p_x,x-w,x+w) == p_x and
     mid(p_y,y-h,y+h) == p_y then
   t:effect()
  end
 end
 for i=#parts,1,-1 do
  parts[i]:upd()
 end
 snow_clock += 1
 while snow_clock > snow_wait do
  if #parts < 500 then
   add_snow()
  end
  snow_clock -= snow_wait
 end
 for i=#smoke,1,-1 do
  upd_smoke(smoke[i])
 end
 smoke_wait -= 1
 if smoke_wait <= 0 then
  add_smoke()
  smoke_wait = rnd(12)
 end
 
 --whistle
 if whistletime > 0 then
  whistletime -= 1
 end
 --dog
 if dbarktime > 0 then
  dbarktime -= 1
 end
 if dog_start and not dog_done and #text_lines <= 0 then
  --initialize dog after delay
  if dog_wait < dog_waitmax then
   dog_wait += 1
   if dog_wait >= dog_waitmax then
    text_queue = {22,23}
    text_change = true
    next_dog(40)
    bark()
   end
  --progress dog
  else
   if mid(p_x,dtarget_x-8,dtarget_x+8) == p_x and
      mid(p_y,dtarget_y-8,dtarget_y+8) == p_y then
    next_dog()
   end  
   dbarkwait -= 1
   if dbarkwait < 0 then
    dbarkwait = 90+flr(rnd(60))
    bark()
   end
  end
 end
 
 --physics
 local dx,dy,da = 0,0,0
 -- detect ice
 local p_acc,fric = 1.25,0.05
 if respawn_trans > 0 then
  fric = 0.25
 end
 if flag(p_x/8,p_y/8,4) then
  -- ice physics (oh boy)
  local vel = dist(p_dx,p_dy)
  p_acc = max(0.01,0.15-vel*0.1)
  if vel > 0 then
   local velscale = max(0,min(0.8,vel-fric))/vel
   p_dx *= velscale
   p_dy *= velscale
  end
 else
  -- no sliding
  p_dx = 0
  p_dy = 0
 end
 
 --input
 -- update rotate delay
 if p_rotwait > 0 then
  p_rotwait -= 1
 end
 -- advance title
 if show_title then
  if title_trans > 0 and (btnp"4" or btnp"5") then
   show_title,text_change,text_wait = false,true,0
   startfade(title_trans*2)
   sfx"28"
   music(-1,500)
  end
 -- ignore regular input and
 -- handle respawn transition
 elseif respawn_trans > 0 then
  respawn_trans -= 1
  if respawn_trans == respawn_warp*2 then
   startfade(respawn_warp*2)
  elseif respawn_trans == respawn_warp then
   if snow_pal > 0 then
    music"5"
   end
   p_x,p_y,p_sp,p_f,snow_wait,snow_pal = respawn_x,respawn_y,4,0,2,0
  end
 -- handle dialogue
 elseif #text_lines > 0 then
  if (btn"4" or btn"5") and p_rotwait <= 0 then
   if text_wait > 12 and (not ending or #text_queue > 1) then
    text_change,text_wait,p_rotwait = true,0,12
   end
  end
 -- handle movement and rotation
 elseif not p_lock then
  -- walk
  if btn"0" then dx -= 1 end
  if btn"1" then dx += 1 end
  if btn"2" then dy += 1 end
  if btn"3" then dy -= 1 end
  -- rotate
  if p_rotwait <= 0 then
   if btn"4" then da += 3 end
   if btn"5" then da -= 3 end
  end
 end
 
 --camera
 -- rotate camera
 cam_angle = (cam_angle+da+360)%360
 -- get camera orientation
 cam_d = cam_angle/90
 if cam_d > 3.5 then
  cam_d = 0
 else
  cam_d = max(0,flr(cam_d+0.5))
 end
 
 --move and animate
 local ca = cam_angle/360
 local step_x = cos(ca)*dx+sin(ca)*dy
 local step_y = cos(ca+.25)*dx+sin(ca+.25)*dy
 local step_l,step_d = dist(step_x,step_y),atan2(step_x,-step_y)
 if step_l > 0 then
  p_dx += p_acc*step_x/step_l
  p_dy += p_acc*step_y/step_l
  --set orientation
  p_d = step_d*4
  if p_d >= 3.5 then
   p_d = 0
  else
   p_d = max(0,flr(p_d+0.5))
  end
  --animate
  p_f = (p_f+0.25)%4
 elseif respawn_trans > respawn_warp then
  p_f = min(4,p_f+0.5)
 else
  p_f = 0
 end 
 -- detect collisions
 if not canmove(p_x+p_dx,p_y) then
  p_dx = 0
 end
 if not canmove(p_x,p_y+p_dy) then
  p_dy = 0
 end
 if not canmove(p_x+p_dx,p_y+p_dy) then
  p_dx,p_dy = 0,0
 end
 
 -- update player postion
 --  bounds should be 48 from each edge
 p_x,p_y = mid(47,1024,p_x+p_dx),mid(0,404,p_y+p_dy)
 -- update whether inside
 if inside_fade > 0 then
  inside_fade -= 1
 end
 local inside = flag(p_x\8,p_y\8,1)
 if p_inside != inside then
  p_inside,inside_fade = inside,4
  --play sound for using door
  sfx"25"
 end
 -- update checkpoint
 if mid(p_x,560,600) == p_x and p_y > 340 then
  respawn_x,respawn_y = 576,356
 end
 -- update snow intensity
 if not show_title and title_trans <= 0 then
  if dog_done then
   -- map 115,12 -> 920,96
   local snowdist = dist((904-p_x)/180,(96-p_y)/180)
   if snowdist > snow_wait then
    snow_wait = min(2,snowdist)
   end
   if snow_pal >= 4 then
     snow_pal = 3
     music(-1,1000)
    elseif snow_pal == 3 and snowdist > 0.4 then
     snow_pal = 2
    elseif snow_pal == 2 and snowdist > 0.6 then
     snow_pal = 1
     music(12,2000)
    elseif snow_pal == 1 and snowdist > 0.8 then
     snow_pal = 0
    end
  else
   -- map 108,22 -> 864,176
   local snowdist = dist((864-p_x)/225,(176-p_y)/225)
   if snowdist < snow_wait then
    snow_wait = max(0.9,snowdist)
    if snow_pal == 0 and snowdist < 0.9 then
     snow_pal = 1
     music(-1,1500)
    elseif snow_pal == 1 and snowdist < 0.7 then
     snow_pal = 2
    elseif snow_pal == 2 and snowdist < 0.4 then
     snow_pal = 3
    end
   end
  end
 end
 -- fall into water
 if respawn_trans <= 0 and flag(p_x/8,p_y/8,7) and pixel_color(p_x,p_y) == 1 then
  respawn_trans,p_f = respawn_time,0
  sfx"14"
 end
 -- get player percieved orientation
 p_cam_d = (p_d+cam_d)%4
 if p_cam_d != p_show_d then
  --update orientation with delay
  --to prevent 1-frame flicker
  if p_cam_d != p_new_d then
   p_new_d,p_new_d_wait = p_cam_d,0
  else
   p_new_d_wait += 1
   if p_new_d_wait > 1 then
    p_show_d = p_new_d
   end
  end
 else
  p_new_d_wait = 0
 end
 -- leave footprints
 if step_l != 0 and p_f%2 == 0 then
  add_footprint(step_d)
 end
 -- set player sprite
 if respawn_trans > respawn_warp then
  p_sp = 0
 elseif p_show_d == 1 then
  p_sp = 4
 elseif p_show_d == 3 then
  p_sp = 8
 else
  p_sp = 12
 end
 p_sm = (p_show_d == 2)
 -- lerp camera
 local camlerp = 2
 if show_title then
  camlerp = 12
 end
 cam_x += (p_x-cam_x)/camlerp
 cam_y += (p_y-cam_y)/camlerp
 
 --break ice
 for x=-1,1,1 do
  for y=-1,1,1 do
   local mx,my = (p_x+x)\8,(p_y+y)\8
   if flag(mx,my,6) then
    break_ice(mx,my)
   end
  end
 end
 --crack2 ice
 for x=-3,3,3 do
  for y=-3,3,3 do
   local mx,my = (p_x+x)\8,(p_y+y)\8
   if flag(mx,my,5) then
    crack2_ice(mx,my)
   end
  end
 end
 --crack1 ice
 for x=-5,5,5 do
  for y=-5,5,5 do
   local mx,my = (p_x+x)\8,(p_y+y)\8
   if mget(mx,my) == 20 then
    crack1_ice(mx,my)
   end
  end
 end
end
-->8
--text
function splittext(text)
 local txt = text
 --num 1 = box style (0 player, 1 jones, 2 dog)
 --num 2 = image (0 none, 1 bench)
 local t,pos = {tonum(sub(txt,1,1)),tonum(sub(txt,2,2))},3
 --current char, last line break,last space pos
 local ccount,splitpos,spacepos = 0,pos,pos
 while pos < #txt do
 	local c = sub(txt,pos,pos)
 	--mark word break
 	if c == " " or c == "-" then
 		spacepos = pos
 	end
 	--break line at /
 	if c == "/" then
 	 add(t,sub(txt,splitpos,pos-1))
 	 pos += 1
 	 splitpos,spacepos,ccount = pos,pos,-1
 	--break line at word break
 	elseif ccount > lmax then
 	 local len = pos-spacepos
 	 add(t,sub(txt,splitpos,spacepos))
 	 splitpos,ccount = spacepos+1,len-1
 	end
 	pos += 1
 	ccount += 1
 end
 add(t,sub(txt,splitpos,pos))
 return t
end
-->8
--drawing
function spal(c1,c2,c3,c4,c5,c8,
              c9,c10,c12,c13,c14,c15)
 pal(1,c1)
 pal(2,c2)
 pal(3,c3)
 pal(4,c4)
 pal(5,c5)
 pal(8,c8)
 pal(9,c9)
 pal(10,c10)
 pal(12,c12)
 pal(13,c13)
 pal(14,c14)
 pal(15,c15)
end

function _draw()
 cls"7"
 
 --snow palette swap
 if snow_pal == 1 then
  spal(5,5,13,13,5,13,
       6,10,6,13,6,6)
 elseif snow_pal == 2 then
  spal(13,13,13,13,13,13,
       6,10,6,13,6,6)
 elseif snow_pal == 3 then
  spal(6,6,6,6,6,6,
       6,7,6,6,6,6)
 elseif snow_pal == 4 then
  spal(6,6,7,6,7,6,
       7,7,7,6,6,6)
 end
 
 local ca = cam_angle/360
 cax,cay = cos(ca),sin(ca)
 local cdx,cdy = -cos(ca+.25)/8,-sin(ca+.25)/8
 --draw map
 for x=0,63 do
  tline(x,0,x,63,
        (cam_x+(x-32)*cax+32*cay)/8,
        (cam_y+(x-32)*cay-32*cax)/8,
        cdx,cdy)
 end
 --sort actors into buckets
 -- initialize buckets
 buckets = {}
 for i=0,bucket_count do
  add(buckets,{})
 end
 -- sort actors
 foreach(walls,wall_to_screen)
 foreach(planes,plane_to_screen)
 foreach(tprops,tprop_to_screen)
 foreach(trees,tree_to_screen)
 foreach(props,map_to_screen)
 foreach(parts,map_to_screen)
 foreach(smoke,smoke_to_screen)
 -- insert player
 add_player()
 
 --draw actor shadows
 if snow_pal < 4 then
  for i=1,#buckets do
   local b=buckets[i]
   for j=1,#b do
    b[j]:shad()
   end
  end
 end
 --draw actors from buckets
 for i=1,#buckets do
  local b=buckets[i]
  for j=1,#b do
   b[j]:draw()
  end
 end
 
 --reset snow palette change
 pal()
 
 --draw whistle
 if whistletime > 0 then
  local wfactor = 2-2*whistletime/whistletimemax
  for i=0,2 do
   local rw = 12*(wfactor-i/2)
   if rw > 0 and rw < 8 then
    circ(31,27,rw,15)
   end
  end
 end
 --draw bark
 if dog_start and not dog_done then
  local angb = atan2(dtarget_x-p_x,dtarget_y-p_y)
  local xb,yb = p_x+48*cos(angb)-cam_x,p_y+48*sin(angb)-cam_y
  local barkx = mid(0,63,xb*cax+yb*cay+32)
  local barky = mid(0,63,yb*cax-xb*cay+32)
  local bfactor = 2-2*dbarktime/dbarktimemax
  for i=0,2 do
   local rb = 8*(bfactor-i/2)
   if rb > 0 and rb < 8 then
    circ(barkx,barky,rb,9)
   end
  end
 end
 
 --draw intro background
 if show_intro then
  cls"7"
 end
 
 --draw title
 if (show_title and title_trans > -5) or title_trans > 0 then
  local titlef = title_trans*0.75-6
  local titley = -titlef*titlef+11.5
  ovalfill(6,titley+1,57,titley+20,6)
  oval(3,titley-2,60,titley+23)
  print("@jusiv_",19,titley-8)
  ovalfill(8,titley+3,55,titley+18,7)
  sspr(62,120,35,8,10,titley+6)
  sspr(92,120,10,8,44,titley+6)
 end
 
 --draw fade transiton
 if fade_trans > 0 then
  local ff = fade_trans/fade_time
  if ff < 0.15 then
   fillp(0b1111000011110000.1)
  elseif ff > 0.85 then
   fillp(0b0000111100001111.1)
  end
  rectfill(0,0,63,63,7)
  fillp()
 end
 
 --draw dialogue
 local tl,c1,c2 = #text_lines > 0,2,8
 if tl then
  local boxid,picid = text_lines[1],text_lines[2]
  if boxid == 1 then
   -- mr. jones
   c1,c2 = 3,11
  elseif boxid == 2 then
   -- dog
   c1,c2 = 5,13
  end
  if img_show then
   local ix1,iy1,ix2,iy2 = 8,img_y-14,56,img_y+15
   ovalfill(ix1-1,iy1-1,ix2+1,iy2+1,10)
   oval(ix1,iy1,ix2,iy2,9)
   ovalfill(ix1+3,iy1+3,ix2-3,iy2-3)
   ovalfill(ix1+5,iy1+5,ix2-5,iy2-5,10)
   ovalfill(ix1+7,iy1+7,ix2-7,iy2-7,7)
   if picid == 1 then
    if ending then
     -- i ran out of digits so
     -- this is a jank work-around
     spr(88,25,img_y-2)
     pset(31,img_y+2,4)
     spr(78,32,img_y-2,1,1,true,false)
     print("‡",30,img_y-6,8)
    else
     spr(93,30,img_y-2,2,1)
     spr(82,30,img_y-4)
     spr(78,22,img_y-2)
     print("‡",25,img_y-6,8)
    end
   elseif picid == 2 then
    if ending then
     -- same as above
     spr(93,25,img_y-3,2,1)
    else
     spr(83,38,img_y-4)
     spr(67,20,img_y-4,1,1,true,false)
     print("(",34,img_y-3,15)
     pset(37,img_y-1)
    end
   elseif picid == 3 then
    spr(109,24,img_y-7,2,2)
   elseif picid == 4 then
    ovalfill(ix1+9,iy1+8,ix2-9,iy2-8,12)
    spr(255,25,img_y-4)
    circ(36,img_y,1,7)
    pset(21,img_y+2)
    pset(40,img_y-2)
    pset(34,img_y+6)
    circ(31,img_y+4,1,6)
    pset(32,img_y-5)
    pset(43,img_y+3)
   elseif picid == 5 then
    if ending then
     -- same thing
     spr(12,24,img_y-3)
     spr(89,34,img_y-3,1,1,true,false)
     print("!",33,img_y-5,6)
    else
     spr(66,26,img_y-3)
     spr(68,34,img_y-3)
    end
   elseif picid == 6 then
    spr(4,29,img_y-4)
   elseif picid == 7 then
    ovalfill(ix1+9,iy1+8,ix2-9,iy2-8,12)
    ovalfill(ix1+14,iy2-16,ix2-9,iy2-12,3)
    print(":\"",34,img_y-3)
    print("':",40,img_y-2)
    print("\"",17,img_y)
    ovalfill(ix1+9,iy2-14,ix2-34,iy2-12,6)
    ovalfill(ix1+24,iy2-15,ix2-9,iy2-10)
    ovalfill(ix1+10,iy2-14,ix2-13,iy2-7,7)
    print("'",44,img_y+4)
    print("'",46,img_y+3)
    sspr(51,120,11,8,22,img_y-5)
   elseif picid == 8 then
    spr(67,29,img_y-4)
   elseif picid == 9 then
    ovalfill(ix1+9,iy1+8,ix2-9,iy2-8,14)
    rectfill(19,img_y,45,img_y+2,4)
    rect(20,img_y+3,44,img_y+3)
    rect(21,img_y+4,43,img_y+4)
    rect(24,img_y+5,40,img_y+5)
    spr(253,24,img_y-4)
    spr(253,33,img_y-5,1,1,true,false)
    print("made by @jusiv_",3,img_y-23,6)
    print("thx for playing!",1,img_y+20)
   end
  end
 end
 rectfill(0,text_y,63,64,c1)
 rect(-1,text_y,64,64,c2)
 local textx = 1
 if text_lines[2] == 9 then
  textx = 2
 end
 if tl then
  for i=3,#text_lines do
   print(text_lines[i],textx,text_y+6*i-16,7)
  end
  if (not ending or #text_queue > 1) and text_y < 58 and text_wait >= 10 then
   sspr(48,124,3,4,60,58+flr(text_wait/15)%2)
  end
 end
end
-->8
--imported

--[[
polytex: textured edge renderer

this function is the work of 
freds72 (@fsouchu on twitter).
it is used here with his
permission.

it is slightly modified to
interpret height (z) values 
correctly in my engine and to
have a fading effect.

forum source:
https://www.lexaloffle.com/bbs/?pid=76387#p
--]]
function polytex(v,fade)
	local p0,nodes=v[#v],{}
	local x0,y0,u0,v0=p0.x,p0.y-p0.z,p0.u,p0.v
	for i=1,#v do
		local p1=v[i]
		local x1,y1,u1,v1=p1.x,p1.y-p1.z,p1.u,p1.v
		local _x1,_y1,_u1,_v1=x1,y1,u1,v1
		if(y0>y1) x0,y0,x1,y1,u0,v0,u1,v1=x1,y1,x0,y0,u1,v1,u0,v0
		local dy=y1-y0
		local dx,du,dv=(x1-x0)/dy,(u1-u0)/dy,(v1-v0)/dy
		if(y0<0) x0-=y0*dx u0-=y0*du v0-=y0*dv y0=0
		local cy0=ceil(y0)
		-- sub-pix shift
		local sy,toggle = cy0-y0,true --whether to draw a given line
		x0+=sy*dx
		u0+=sy*du
		v0+=sy*dv
			
		for y=cy0,min(ceil(y1)-1,63) do
			--skip every other line if fading
			if fade then
 			toggle = not toggle
			end
			
			local x=nodes[y]
			if x and toggle then
				-- backup current edge values
				local a,au,av,b,bu,bv=x[1],x[2],x[3],x0,u0,v0
				if(a>b) a,au,av,b,bu,bv=b,bu,bv,a,au,av
				
				local x0,x1=ceil(a),min(ceil(b)-1,63)
				if x0<=x1 then
					local dab=b-a
					local dau,dav=(bu-au)/dab,(bv-av)/dab
					-- sub-pix shift
					local sa=x0-a
					au+=sa*dau
					av+=sa*dav
					tline(x0,y,x1,y,au,av,dau,dav)
			 end
			else
				nodes[y]={x0,u0,v0}
			end
			x0+=dx
			u0+=du
			v0+=dv
		end
		x0,y0,u0,v0=_x1,_y1,_u1,_v1
	end
end
__gfx__
0000000000000000000000000000000000000000000ee00000000000000ee00000000000000ee00000000000000ee00000000000000ee00000000000000ee000
00000000000000000000000000000000000ee00000888800000ee00000888800000ee00000888800000ee00000888800000ee00000888800000ee00000888800
000ee000000000000000000000000000008888000088880000888800008888000088880000888800008888000088880000888800008888000088880000888800
008888000000000000000000000000000088880000ffff000088880000ffff0000888800002222000088880000222200008888000024ff00008888000024ff00
00888800000ee00000c00c000000000000ffff00002e8ed000ffff000d8e8200002222000de8e8000022220000e8e8d00024ff0000e8e8000024ff0000e8e800
0dffffd000088000000cc00000dddd00008e8e000d211100008e8e00001112d000e8e800002111d000e8e8000d11120000e8e80000d1110000e8e80000111d00
008e8e0000effe0000dccd000dc00cd00d1111d0000002000d1111d0002000000d1111d0002000000d1111d000000200001d110002000020001d110002000020
00dddd00000dd000000dd00000dddd00002002000000000000200200000000000020020000000000002002000000000000022000000000000002200000000000
7777777777766777ccccc6cccc6cc6ccccccccccccc66cccd111111dc111111cccccc66ccc666ccccccccccccccccccccccccccc777777777777777777777777
7777777777667677ccc66ccccc61d6ccccccccccccd1d6cc6111111cd1111116cc6dd111111dddcccccccccccccccccccccccccc776c66777777777777777777
7667666777666677c6cc6ccccdd11d66ccccccccc611116cc111111cd11111d6c6111111111111dccccccccccccccccccccccccc76ccccc66cc677666ccc6777
66666766777666776c66cc6c6111116cccccccccc61111dcc111111d611111dcc11111111111111ccccccccccccccccccccccccc7cccccccccccccccccccc677
6776666777676777ccc666ccccd111dccccccccccd111116cd11111dcd11111cd1111111111111dccccccccccc666ccccccccccc76cccccccccccccccccccc67
6667676677676677cc6ccc66c6d16166cccccccccd11111cc61111dccd11111cd1111111111111d6cccccc77667777766ccccccc776ccccccccccccccccccc67
7777777777666777ccc6cccc66c66dcccccccccc6111111cccd1dd6c6d11111d1111111111111116ccccc6777777777777cccccc776ccccccccccccccccccc77
7777777777766677cc6ccccccc6ccccccccccccc61111116ccc66ccc6111111d1111111111111116ccccc77777777777776ccccc776ccccccccccccccccccc77
7777777777777777ccc6ccccccc6cc6cccc6dccccccd666d66c66ccc66ddc66cc111111111111116ccccc777cc666ccc776ccccc77ccccccccccccccccccc677
7777777777777777c6c6c6ccc6c6d66ccd111d6cccd111111d6dd6cc1d111111c1111111111111d6ccccc777c677776c77cccccc77ccccccccccccccccccc677
7777777777777777cc6c6ccccc6d1ccc61111116c611111111d1116c1111111161111111111111dcccccc677c777777676cccccc776cccccccccccccccccc667
7777777777777777ccc666cccdd116ccd1111116cd111111111111d6111111116d1111111111111cccccc6776777777676cccccc777ccccccccccccccccccc67
77777777777777776c666c666d111d66d111111d611111111111111611111111cd1111111111111ccccccc776777777676cccccc777ccccccccccccccccccc77
7777777777777777c66c6ccc666d1ddc6111111d6d111111111111dc11111111c6d11111111111dccccccc776777776c77cccccc776ccccccccccccccccccc77
7777777777777777cccc66cccccd66ccc6d111dcc6d116d11111d6cc111ddd11cc61ddd11111d6cccccccc77c67776cc776ccccc776ccccccccccccccccccc77
7777777777777777cccccc6ccc6cc66ccccd66ccccc66cc6d6c66cccddcc666cccc66c66c666ccccccccc677cc66cccc776ccccc77cccccccccccccccccccc67
9aaa99a92ffffff2c6ccccccc6cc6cccccc66ccc1111111111dd6ccc1111111c6111111111111111ccccc67777777777776ccccc776ccccccccccccccccccc67
ac7caada47667674cc6cccc6cc6cd6c6cc67776c111111111111d6d11111111cc111111111111111cccc6777777777777776cccc776cccccccccccccccccc677
a181aa2a47777774cc66cc6cc6d1dc6ccc67777c1111111111111111111111dccd11111111111111cccc6777766777677776cccc776cccccccccccccccccc677
9aaa99a999999999cccc66cccc1111ccc67777761111111111111111111111ccc611111111111111ccccc6766ccc66c6676ccccc776ccccccccccccccccccc67
0000000044444444c66c6ccccd11116c677777761111111111111111111111ccc611111111111111ccccc666ccccccccc66ccccc777cccccccccccccccccccc7
dddddddd200000026cc66ccc66d11dcc6777777c1111111111111111111111dcc111111111111111cccccccccccccccccccccccc7776c66cccccc6666ccccc67
5555555540000004ccc6c66cccd1d66cc77776cc111d6dd111111111111111dcd111111111111111cccccccccccccccccccccccc77777776667777777766c677
dddddddd40000004ccc6ccccc6c6cccccc66cccc6c6cc66c111111111111111cd111111111111111cccccccccccccccccccccccc777777777777777777777777
777777777777777700600cc600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7777777777777777dddd000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7777666666666777555d00c600000000000000000025520000000000002552000000000000255200000000000025520000000000000002500000220000002250
77677667766677775444300002155120002552000025520002255220021551200025520000255200022552200255552000002250000022510000255000002151
7766666666667677455430c0025155200215512000515500001551000055150002555520005d5500005555000055d500000021510d555555d0005151dd555555
776667666676667763333000005ee50000515500005555d00d5515000055550000555500005dd50000555500005dd5000d555555d05555000d55555500555500
7766667777666677011116000d555500005555d005222250005555000d2552000ddd5500022552200055ddd0005225000d555500050000500055550000055000
77676677776676770100010000522500005225000002200000522500000220000052250000055000005225000002200000500500000000000050050000000000
77676677776676770055500000555000005550000055500000055500000555000005550000055500000000000000000300000000000066666666d00055555677
776666777766667700544500005445000054450000544500005555000055550000554400005544000000000000000003000000000006666666666d0055555677
776667666676667700444400004444000044440000444400005555000055550000554400005544000000000300000003000000030006666666666d0055555577
776766666666667700455400099554000045540000455400004554000045540000444500004445000000000300000003000000330005ddddddddd50055555577
77776667766776770033330004333300003333000033330000333300003333000033330000333300000000030000003300000033000500000000050055555677
777666666666777704333300003334000433330000333340003333400433330000334300003333000000003300000033000003336666666666dddd0055555777
77777777777777770111114000111100001111400411110004111100001111400011110000141100000003350000033300000053dddddddddd500d0055555777
77777777777777770100100000100010001001000010010000100100001001000001100000011000000005330000033300000033d005000000d00d0055555677
55444444444444444444445544ffff4400000e000000000500001000500000005555666699999949000003330000005300000333000000000001100055555555
44444444444444444444444444f99f44544454e0000000150dd0101051000000d5dd611699999949000000530000033300003333000000000014410055559555
ff22222222222222222222ff22faaf224444544e000005446dd15110445000005555611644444444000003330000333300000533000000000141141055559555
ff55555555555555555555ff55faaf5525552450000014440dd0100044410000dd5d666699499999000033330003333300000333000000000149141055559555
55444444444444444444445544ffff440002050000052222000010002222500055559aa999499999000333330000533300003333000000000199210055555555
4444444444444444444444444444444400020000001555550000100055555100d5dda54a99499999000053330000333300033335000000001994100055555555
ff22222222222222222222ff22222222000200000544444400001000444444505555a34a44444444000333330033335300333333000000019991000055555555
ff55555555555555555555ff5555555500020000144444440001110044444441dd5d9aa99999994903333335033333330005333300000019f910000055555555
ff22222222222222222222ff22ffff2222ffff22dddddddd1111111115551555dd55eeee555555550053353300535533003333330000019f9410000055555555
ff55555555555555555555ff55f99f552f2222f2dddddddd5555555511111111555deeee55555555333333330333333303333333000019ff9100000055555555
55444444444444444444445544faaf44f244442f111111111555155555555555dd55eeeedddddddd033553333333333333333333000144f94100000055555555
44444444444444444444444444faaf44f544444f55555555111111115515551555d5eeee655555560533333305333333053333330019f4991000000055555555
ff22222222222222222222ff22ffff22f544444f155515555555555511111111dd55eeee6dddddd633333333333333330335533301fff9941000000055555555
ff55555555555555555555ff55555555f5444a4f111111115515551555555555555deeee6666666605553333005533330333333301944f910000000055555555
55444444444444444444445544444444f544444f555555551111111115551555dd55eeee76767667003333330333333305333333001999100000000055555555
44444444444444444444444444444444f544444f55155515555555551111111155d5d00d76676677000553330005533300005533000111000000000055555555
f7f7f6f7f7f5ee12de1212eedede02020202de1212dedede020401140266dede02021515d3c1e2b2e2e2a3f101eede5e234141e27e8e22e2e2e2e2e231e241e2
e2e261e2e2e2e2b27ef102d17ee2a1f30202020202020202020202020212ee1212deeede12de020202dede1212121212ee12de12126611661212de1212121212
f7f7f6f7f7f5121212dedede02020202026612dede12dede0211de11020114ee0402660202d2e2e2e2e2e2f20205d1c341214141412341e2e2e2b2e2e2e22341
4141e2e2e2e2e2e2e27ee17ee2e2a3b3e1f102020202020202020202ee121212ee121212eede020202ee12121212ee121212de12de021102ee1212de12de1212
f7f7f6f7f7f5dededeee020202020202dede12de1212126602050115026602ee11ee12de02d2e2e2e2e2e2a3f102d2e2e2e2e2414141e2e2e24141e2e2e2e2e2
e241412322e2e2e2e2e2e222e2e2e2e2e27ee1e1f102020202020202121266de1212dedede02020202de12ee121212de12de12deee021102dedede1212121212
f7f7f6f7f7f5de12660204020202dededeeeeededeee12de0202020202ee020215dedede02d34e2221e22322a3b3c3e2e241e2e2e2e2e2e241414141e2e2e243
e2e2e2e241214141e2e2e2e2e2e2e2e2e2e2e2e2a3f102020202020212ee1212deeede0202020202dede121212de1212dede66020202020202ee1212ee12de12
f7f7f6f7f7f512dede021102eede12ee020201146612dede02020202dedeeedeeede12dede66d223412141414121e2e2e2e2b2e2e2e2e241412241414141e2e2
e2e2e2e2e2e2e24141e2e2e2e2e241414141e2e2e2f2020202020202eede12eedede0202020202661212de121212ee12ee020202020202020202dede12de1212
f7f7f6f7f7f5de12ee02051402de660202020215dede12ee020202deee1212661212de121202d2e2e241414141414141e2e2e2e2e241414123e24121414141e2
e2e222e2e2e2e2e24141e241414141e2e24141e2e27ef102de02ee02121212dede02020202eede12de121212ee1212de02020202020202020202026612126612
f7f7f6f7f7f512de66de020514020202020202dede12de02020202de1212ee12dede6612de02d2e2e2e24141e241412221e2e241412241e2a1e3b1c1e22241e2
e2e2e2e2e24123e241414141e2e2e2e2e2e241428191a3e1b3f1de02ee12ee12de0202020202eedeee1266de121212660202020202020202020202dedede1212
f7f7f6f7f7f5de12dedeee0202021402deee66de12eede02020202eede1212de121212121212d3e2e2e2e2e2e2e2e241414141234141e2e2f21266c2b2e22341
e2e2e2e2e241e2e2e2414141e2e2e2b2e2e24252939391e2e2f2020212121266de02020202020202dede1212de12ee0202020296965f965f02020202de1212ee
f7f7f6f7f7f5eede1212de660202020266deeede12dede020202ee1212ee121212121212121266d2e2e2e2e2e2e2e2e2e241414141e2e2e27ef112d3c1e2e241
e2e2e2e2e2e2e2e2e24141e2e2e232e2e2e2e241825392e2e27ef102ee1212de12ee02020202020202de121212eede020202025f5f96965f02020202deee1212
f7f7f6f7f7f5de1212dede0202de0202020202dede6602020202dede12121212ee121212121212d2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e222e2a3e1e1c3e2e241
41e2e24121e2e2e2412241e243e2e2e223e2e2e24141e2e2e2e2a3f1dedeee12eede02020202020202de12de1212de02020202969696969602020202de12dede
f7f7f6f7f7f51212dede020202eeee0202020202eede02020202de12de12ee1212121212121212d2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2
41e2e2e241e2a1e3c141e2e2e2e2b2e2e243e241414141414141416e02eede121212de02020202020202de121212ee02020202969696969602020202ee121212
f7f7f6f7f7f5de1212de020202dedede020202dedeee02020202de6612de121212121212121212d3c1e2e2e2e2a1b1c1e2e2e2e2e2e2e2e2e2e2e2e2e242e241
41e2e2e2e2e2f202d3e3b1c121e2e2e2e2e24141e2e2e2e24141e2a3f1020266eedeee02020202020202de126612de020202025f9696965f0202ee02de661212
f7f7f6f7f7f5121212ee0202eede12eede66dedeee02020202dede12121212661212121212121212d3c1e2e2e2a266c2e2e2e2e2e2e2e2e2e2e2e28191e2e2e2
414141e2e2a1f3020202025e22412341e2e24141e241e2e2e2e2e2e27ef1020202020202020202020202ee12de12ee020202025f9696965f02020202de12deee
f7f7f6f7f7f512de12de1166de12de1212de12dede0202020266de12ee1212de121212121212121212d2e2e2e2a3b3c3e2e2e2e2e2e2e2e2e2e2e282937291e2
e2e24141416eee0202deded2e2e24141e2e241e2e241e2e2e241e2e2e2f2020202020202660202020202deee1212de02020202021297120202020202ee1212de
f7f7f6f7f7f51212deee11de12dede12de12deee02020202dede12121212d1b3f11212121212121212d3c1e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e25292e28262
e2e2e2e2e2a3f1de6602d18ee2e2e222e2b2e2e2414141e2e2e2e2e2b2f202020202020202020202020266de121266020202020202051402ee020202de12ee12
f7f7f6f7f7f5121266de02deee1212ee1212de02041502deeede126612d1c3a1f3121212121212121212c2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2
e2e2e2e2e2b27ef102d1c3e2e2e2e24132e2e2e223e24122e2e2e2e2a1f30202020202020202020202ee1212de12de02020414020202051402020202ee121212
f7f7f6f7f7f5ee1212de0202dedeeedede66de021102eede1212121212d3c1f212121212121212121212d2e2e2e2e2e2e2e2e2e2e2e2e2a1b1b1e3c1e2e2e2e2
e2a1b1e3e3c122f2eed3c143e2e2e2214123222141e2a1e34ee2e2a1f3020202020202020202020202de12de12eedeee0205150202020205140202eede1212de
f7f7f6f7f7f5021212eede0202020202eede02020202de12661212ee1212d3f312121212121212121212d3e3b1b1e3c1e2e2e2a1b1e3b1f3020202d3e3e3e3e3
e3f30202ded3e3f30202d3e3c1a1b1e3b1e3b1b1b1e3f366d3e3e3f3020202020202026602020202eedede12ee1212de0202020202020202110202de1212de12
f7f7f6f7f7f512de1212eedede6602020202020202eede121212ee1212ee1212121212121212121212120202020202d3e3e3b1f3020202020202020202020202
020202020202020202de0202d3f3de0202deee02de020202de020202de026602ee0202020202eede1212ee121212dedeee020266020202021102eedede1212ee
f7f7f6f7f7f51212de1212de12dedeeededeeededede1212de121212de1212121212121212121212121212121212121212121212121212121212121212121212
121212121212121212121212121212121212121212eede1212deeededede12dedeeedeeededede12de12121212121212dedede12deeede661166121212121212
f7f7f6f7f7f5de121212de121212ee121212126612deee121212661212ee12121212121212121212121212121212121212121212121212121212121212121212
1212121212121212121212121212121212121212de12de1212121212deee12de1212de121212126612126612ee121212de121212ee12dedeeedeee1212126612
f7f7f6f7f7f51212ee121202de1212126612de1212121212ee1212de121212121212121212121212121212121212121212121212121212121212121212121212
121212121212121212121212121212121212121212de12121212121212121212ee121212de12de1212121212de12de121212de121212eededeee1212de121212
f7f7f6f7f7f566121212ee121212ee121212121212ee661212de12ee121212121212121212121212121212121212121212121212121212121212121212121212
12121212121212121212121212121212121212121212de121212de121212ee1212121212121212de121212121212ee12de121212ee121212eededeee12121212
f7f7f6f7f7f5121212de1212ee1212de12ee1212de12121212121212121212121212121212121212121212121212121212121212121212121212121212121212
12121212121212121212121212121212121212121212121212121212121212121212ee1212121212121212121212de121212ee121212de1212deee12de121212
777777775d22dd214444444403ee2e66cccccccc776cccccccddd577ccccc6777776cccc4444444444444444eeeeeeee0eeeeee0dddddddddddddddd77777777
7777777712dd22d54444444400000000ccc5d5cc77cc55ccc5d55dd7ccccc6677776cccc4444444444444444e222222eeeffffee555555555555555577777777
7777777712dd22d54222222413de1eefcc55dd5c765ddd5ccddd5dd7ccccccc6676ccccc4222222222244224e6762a6eeffffffedd5555dddd5555dd77777777
777777775d22dd214111111400000000cdd5dddc7ddddddccddddd57cccccccccccccccc4111111111144114eeeeeeeeeffffffe555555555558855577777777
777777775d22dd21e444444e57575757cddddddc7ddd5d5cc5ddd567cccccccccccccccc76677677eeeeeeeee2b2dc2eeffffffed555555dd588885d77777777
7777777712dd22d5567677610000000065dddddc75ddd5ccccc55577cccccccccccccccc7667d6d7effffffee2b2dc9eeffffffe555555555589985577777777
7777777712dd22d5167767656767676775dddd5c775d5cccccccc677cccccccccccccccc7777ddd7effffffeeeeeeeeeeeffffeed555555dd59aa95d77777777
77777777e444444e12dd22d500000000775d5ccc776cccccccccc777cccccccccccccccc77777777eeeeeeeed000000d0eeeeee05555555555dddd5577777777
005617760007171717278646777777779eaecebe9999994900000000000000000000000000000000000000000000000000000000000000000000000000060000
00000000000000000000000000000000000000009999994900000000d0000000c0000c00000000c00000000000000000000c0000000666000000000006070700
5617371776073717372787a5b5c5a5b5c5a5b5c544444444000001111155000cc000cc0c00000cc00000000000000000000cc000006444600333333000707000
000000000000000000000000000000000000000099499999000011111522500cc000c0c0c00000cc000000c000000000000cc000667666703333333367000760
0717171727061616161626a6b6c6b6c6a6c6a6b69949999900011111524a250cc000cc0c0c0c00c00cc00c000c0c00c000ccc000607777703333333300707000
000000000000000000000000000000000000000099499999777022222444400cc0c0cc000cc0c0c0cc0c0c0c0c0c0c0c0c0cc000667777703355553306070600
0737473727063616163626a7b7c7c7a7b7b7c7a74444444477702a2a24a5900cc0c0cc0c0cc0c0c0ccc00c0c0c0c0c0c0c0cc000006777603355553300060000
0000000000000000000000000000000000000000999999490700222224954000ccccc00c0cc0c0c00ccc0c00c0c000c000cc0000000666003355553300000000
__gff__
0000000000000000000000000000000000003050109090909090101010101010000130509090909090901000101010100000305000909090909010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000100000200000000000100000000000000000104000000000001
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011111100100000000001010800000000000300000000000000000000
__map__
7f7f6f7f7f5f6621216621212121212121212166662121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121ed21ed2121212121212121212121212121ed212121212121212121212121
7f7f6f7f7f5f212121212121ee2121ee21662121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121211d1e1e1e1e1e1e1e1e1e1f21212121212121212121212121212121202020202020202020202020202021ed212121ed2121ee212121662121212121212121
7f7f6f7f7f5f21ee216621ed2121662121212121662121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212d25272727262e152e152f21212121212121212121212121ed20202020202020202020202020202020202021ed2121212121212121212121ee2121212121
7f7f6f7f7f5f2121212121216621212121ee2166212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212d2e2e2e2e2e2e172e172f212121212121212121212121212020202020202020202020202020202020202020ed2121ed2121212121ee2121212166212121
7f7f6f7f7f5fee21ee21eeed21ed216621212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212d2e2e152e242e172e172f212121212121212121212121ed2020202020202020202020202020202020202020212121212121212121ed2121ed2121ee2121
7f7f6f7f7f5f6621ee66edee2121eeee2121ee21ed2121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212d152e172e2e2e172e172f21212121212121212121212120202020202020202020202020202020202020202020ee2121212121ee2121212121212121ed21
7f7f6f7f7f5f21ee20202020ee6620206621212121ee212121ed212121212121212121212121212121212121212121212121212121212121212121212121212121212d2827292e152e172e172f21212121212121212121ee2120202020202020202020202020202020202020202020212121ed212121211d1f6621212121ee21
7f7f6f7f7f5f6620202020202020202020ee21ee212121ed2121212121212121212121212121212121212121212121212121212121212121212121212121212121212d2e2e2e2e172e172e172f2121212121212121212121212020202020202020202020202020202020202020202021ed21212121211d3c3a1e1f21ee212121
7f7f6f7f7f5f2020202040101010104120662121216621212121212121212121212121212121212121212121212121212121212121212121212121212121212121212d152e242e172e172e172f2121212121212121212121ed202020202020202020202020202020202020202020202121ed2121ee213d3e1c2b2f212121ed21
7f7f6f7f7f5f104110105120202020112020edee212121ee2166212121212121212121212121212121212121212121212121212121212121212121212121212121212d172e2e2e172e172e172f2121212121212121212121212020202020202020202020202020202020202020202066edeeed21212121ed3d1c2f21212121ee
7f7f6f7f7f5f40105120202066ed20504120ee2121ed21212121216621212121212121212121212121212121212121212121212121212121212121212121212121212d2827192e172e172e172f2121212121212121212121ed20202020202020202020202020202020202020202020e0e0e0edeeedee2121212d2feeed212121
7f7f6f7f7f5f512020202020ed21ee201120ed66ededee21edee21ed21212121212121212121212121212121212121212121212121212121212121212121212121212d2e2e172e172e2836292f21212121212121212121212120202020202020202020202020202020202020202020e0e020202020ededee213d3f2121216621
7f7f6f7f7f5f202020212020ee21ee201120ed21ee2020662121ee2121212121212121212121212121212121212121212121212121212121212121212121212121212d2527292e162e2e162e2f21212121212121212121ed2120202020202020202020202020202020202020202020e0e02020202020ed212121ee21ee212121
7f7f6f7f7f5fee2020202020ed21ed20112020ee20202020edee212121212121212121212121212121212121212121212121212121212121212121212121212121213d3e3e3e3e3e3e3e3e3e3f2121212121212121ed21212120202020202020202020202020202020202020202020e0e02020202020206621ee212121212121
7f7f6f7f7f5f66ed2020206621ee2020112040101010412020ed21ed6621212121212121212121212121212121211d3b1e1e3b1e1f2121212121212121212121212121212121212121212121212121212121212121212121212020202020202020202020202020202020202020202066eded21ed202020ed212121662121ed21
7f7f6f7f7f5f212166edee2121ed2020501051202020202020662121212121212121212121212121211d1e3b3b3b3c2e2e2e2e2ee73b1e1f2121212121212121212121212121212121212121212121212121212121212121ee202020202020202020202020202020202020202020202121ed66edee2020edee21ed2121ed2121
7f7f6f7f7f5fee21212121ed2166ee20202020ee2020202020edee21ed212121212121212121211d1e3c2e2e2e2e2e2e2e2e2e2e2e2e2e2f2121212121212121212121212121212121212121212121212121212121212121212020202020202020202020202020202020202020202021ed212120ed2020eeed2121ee21212121
7f7f6f7f7f5f212166212121ed21eded66edee21ededee11662121edee212121212121212121212c2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2a212121212121212121212121212121212121212121212121212121212121212121202020202020202020202020202020202020202020202121ee21eded202020edee212121ed21ed
7f7f6f7f7f5fee2121eded2121ed212121ee21ee21eeed20ed21ee2121ed2121212121212121212d2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e3a1f2121212121212121212121212121212121212121212121212121212121212121202020202020202020202020202020202020202020ed21212121ee20202020ed21ee2166212121
7f7f6f7f7f5f21ed21ed21ed212121212121212121ed2020ed212121ed2121212121ed212121212d2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2a2121212121212121212121212121212121212121212121212121212121212121ee202020202020202020202020202020202020202021662121eded20202020662121212121ee21
7f7f6f7f7f5fed21ee2121ededeeed21ed21ee21eded2011206621ed21ed212121212121ed211de8242e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2a2121211d1e1e1f212121212121212121212121212121212121212121212121212120202020202020202020202020202020202020202121212121eeed202020efed21ed212121ed
7f7f6f7f7f5f66212121edee202066ee2121212121ee20202020ee21212121ed21212121211d3c1836262e2e2e2e2e2e2e2e2e2e2e2e2e2e2f2121212c2e2e3a1e1e1f21212121212121212121212121212121212121212121212120202020202020202020202020202020202021212121ee2121ededeeefefeeeded21ed2121
7f7f6f7f7f5f21ed21edee20202020edee212121eded20112020ed2166212121ed2121ee212d2535372e2e2e2e2e2e2e2e2e2e2e2e2e2e2ee71f21212d2e2e2e2e2ee71e1f2121212121212121212121212121212121212121212121ed2020202020202020202020202020ee21212121212121ed21ee2166ef2020eeed212121
7f7f6f7f7f5f212121ed2020404120202066ededee2020112020edee21ed212121212121212d2e2e28262e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2f211d3c2e2e2e2e2e2e2e2a21212121212121212121212121212121212121212121212121ee66ed20206621212121ed2121212121212121662121ed21eded20202020ed6621ee
7f7f6f7f7f5fee212166202011512020202020202040105120ee21edee21212121662121213d3e1c2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2fee2d2e2e2e2e2e2e2e2e3a1f2121212121212121212121212121212121212121212121662121edefefed21ee212121ed2121212121ed2121ee2121eeed2020202020ed212121
7f7f6f7f7f5f21edee21ee2051202020202020202051202020edee21212121ed21212121ee201d3c12142e2e2e2e2e2e2e2e2e2e2e2e2e2e2ee71e3c2e2e2e2e2e2e2e2e2e3a3b1e1e3b1e3b1f2020202020202020202121662121ee212121eeed202020ee2121662121212121ee2121212121edeeed2020202020ee2121ed21
7f7f6f7f7f5fee2121eded202020edee11662020202020eeeeee21eded21ed2121ed2121edede5331422322e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e3a1e1e1f2020202020202021212121212166212166ed202020ed212121ee21ed212121ed21ed212121662020202020edee212121
7f7f6f7f7f5fed2121ed21eeedeeeeed5041edeeedeeeded21216621ed212121ed21ed21ee512c2e2e2e1214142e2e2e18192e2e2e2e2e2e1414141414142e2e2e2e2e2e2e2e1a3e3e3e1c2e2e2e2e3a1f20202020202020212121ee2121ed2121eded202020eded21212121216621212121ed21ed2020202020ed2121ed6621
7f7f6f7f7f5f21ed2121ed21ed21ed21ed2020eeed21ed21662121ed21ed21ed662121ee201de82e2e2e2e2214142e2e28372e242e2e2e141414143222142e2e2e2e2e2e2e2e2a2020203d3e3e1c2e2e2f202020202020202021662121ee21212121eded20202020ed6621ed21212121662121eeee202020206621ee21212121
7f7f6f7f7f5f2121ee2121edee2121ee20202020ee21ee2121ed21212121ee2121edeeed1d3c2e2e2e2e2e1a3ee42e2e2e162e2e2e2e1414121414141414142e2e2e2e2e2e1a3f20ed202020202d2e2e2f202020202020202020202020212121212121eeed202020ed21ee21212121ed21ed21ed2020112020edee21ed212121
7f7f6f7f7f5fee2121216621216621ed20202020eded21edededed66ee21ed21ededee20e52e2e2e23141a3fed3d1c2e2e2e2e1a3e1c141414142e2e2e14122e25192e242e2f2020202020ed1d3c2e1a3f202020202020202020202020662121ed2121212166202020ed212121ee212121eeeded20202020eeed212121ee6621
7f7f6f7f7f5f21ee21ed21ed21eded2020202066ed2121eeee202020ededee21662040102c2e2e2e2e222f2020663d1c2e2e2e3a1f2c14142e2e2e2e2e2e142e2e16152e2e3a3b1e1f20ee202d2e2e2f202020202020202020202020202121212121ed21eded202020ed2166212121ed212121eeee201120eded21ed21212121
__sfx__
000100002e05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100002465000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000900002b2402b2512c2512a25000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00040000121541b161151601714500102001020010200102001020010200102001020010200102001020010200102001020010200102001020010200102001020010200102001020010200102001020010200102
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800001461300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800001861300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800000f61300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300002b6252a600296002c62026600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300002b6252a6002c6132c60526605266200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300002e6232a600256452560026600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010a00001b63221655160500804103010010100070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
000300000561504600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
000300000861504600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
000300000261504600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
010800002d61333670346723463234612026150260000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
010800002961333670326722c6322b612026150260000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
010800002e613326702d6722d6322f612056150460000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
00040000141541d1611d1601814500102001020010200102001020010200102001020010200102001020010200102001020010200102001020010200102001020010200102001020010200102001020010200102
00040000121541d1611f1601714500102001020010200102001020010200102001020010200102001020010200102001020010200102001020010200102001020010200102001020010200102001020010200102
00040000161541f1611e1601814500102001020010200102001020010200102001020010200102001020010200102001020010200102001020010200102001020010200102001020010200102001020010200102
000a0000295442b5512b5512b5412b5312b5212b5102b515005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000c00001f61521104000001a6331a625000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000f00002304523045230452700500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00100000105551055510555125050d500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000f00002f7552975534755317552f705000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000f00002f7552d705347553375537701397253b74500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00140000275552750527555000002a555000052a55500000255552750525555000002c555000052c55500000275552750527555000002a555000052a55500000255552750525555000002c555000052c55500000
001400002f7542f7502f7502f7550000000000000000000000000000000000000000000000000031754317552c7542c7502c7502c755000000000000000000000000000000000000000000000000000000000000
001400002f7542f7502f7502f7550000000000000000000000000000002c755287552f7540000031750317552c7542c7502c7502c755000000000000000000000000000000000000000000000000000000000000
0014000028754287502875028755000000000000000000000000000000000000000000000000002c7542c75523754237502375023755000000000000000000000000000000000000000000000000000000000000
001400002875428750287502875500000000000000000000000002370023740287302c73000000277542775523754237502375023755297342973029730297350000000000000000000000000000000000000000
001400000202405024020240402402024050240202404024020240502402024040240202405024020240402401724047240172402724017240472401724027240172404724017240272401724047240172402724
001400002275422755000001c5541c555000002275422755000002275500000007002275522755227552275422755000001955419555000002275422755007002275500000007002275500000227352275522755
00140000295052f5052f5052c5052c505295052c50529505315052b5053150531505315052c5052950529505295052f5052f505275052c5052b50529505295050050500505005050050500505005000050029505
00140000295052f5052f5052c5052c505295052c50529505315052b5053150531505315052c5052950529505295052f5052f5052c5052c505315052f505295050050500505005050050500505005000050029505
0018000027505000002950500000305050000035505000002750500000295050000030505000003550500000275050000025505000002e505000003150500000275050000025505000002e505000003150500000
0018000027525000002952500000305250000035525000002752500000295250000030525000003552500000275250000025525000002e52500000315250000027525000002b5250000030525000003352500000
00180000275250000029525000000000000000355250000027525000002952500000305250000035525000002752500000255250000000000000003152500000275250000025525000002e525000003152500000
001800002752427525295242952500000000003052430525000000000035524355250000000000000000000027524275252952429525000000000030524305250000000000355243552500000000000000000000
001800002752427525255242552500000000002e5242e525000000000031524315251e50523505215052d5052752427525255242552500000000002e5242e525305000000031524315251e50523505215052d505
001800002471427711297212972129721297212972129721297212972129721297252972129725297152971524714257112572125721257212572125721257212572125721257212572525721257252571525715
0018000024714277112972129721297212972129721297212972129721297212972529721297252d7152e71524714257112572125721257212572125721257212572125721257212572525721257252a71529705
001800002a715297052e7552e7352e7252e715000000000000000000000000000000000000000000000000002a715297052c7552c7352c7252c71500000000000000000000000000000000000000000000000000
011800000000000000247150000029725000000000000000000000000000000000000000000000000000000000000000002471500000257250000000000000000000000000000000000000000000000000000000
0018000000000000002471500000297252d7152e71500000000000000000000000000000000000000000000000000000002471500000257252a7152a715000000000000000000000000000000000000000000000
001c00002772427725297242972500700007003072430725007000070035724357250070000700007000070027724277252972429725007000070030724307250070000700357243572500700007000070000700
001c00002772427725257242572500700007002e7242e725007000070031724317251e70523705217052d7052772427725257242572500700007002e7242e725307000070031724317251e70523705217052d705
001c000027725007002972500700307050070035725007002772500700297250070030725007003572500700277250070025725007002e70500700317250070027725007002b7250070030725007003372500700
001c000027725007002972500700307250070035725007002772500700297250070030725007003572500700277250070025725007002e72500700317250070027725007002b7250070030725007003372500700
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001400001a5201d5201f5201f52500000295242952029525000001d5241d5201d5251a5001a5001a500000001a5201d5201f52022525000002952429520295250000000000000000000000000000000000000000
001400001c555235551c5552d550305502b50000500265001e55523555215552d5552d545000002d530005001c555235551c5552d550305502b50000500265001e55523555215552d5552d545000002d53000500
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 41 42 43 1e
01 41 42 1f 1e
00 41 42 20 1e
00 41 42 21 1e
02 41 42 22 1e
01 41 42 43 2a
00 41 42 43 2b
00 41 42 2f 2a
00 41 42 30 2b
00 41 42 2c 29
02 41 42 2d 28
03 41 42 43 23
01 41 42 43 31
00 41 42 43 32
00 41 42 43 33
02 41 42 43 34
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
