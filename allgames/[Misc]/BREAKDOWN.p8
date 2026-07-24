pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- [breakdown]
-- by doczi_dominik
-- title screen music by @gruber

cartdata("doczidominik_breakdown")

-- toggle whether block sel. returns to other end
-- when going off screen (lik pac-man)
menuitem(1, "toggle sel. wrap", function()
 if (block_wrap == 0) block_wrap=1 else block_wrap=0
 dset(3, block_wrap)
end)

-- toggle screenshake + other effects
menuitem(2, "toggle shake fx", function()
 if (shake_fx == 0) shake_fx=1 else shake_fx=0
 dset(4, shake_fx)
end)

-- toggle music
menuitem(3, "toggle music", function()
 if music_on == 0 then
  music(-1)
  music_on=1
 else
  if state == "title" then 
   music(13)
  elseif state == "game" then
   music(last_note)
  end
  music_on=0
 end
end)

-- skip various icons and hints when playing for
-- first time
menuitem(4, "skip tutorial", function()
 tutorial_level=6
end)

-- reset all highscores
menuitem(5, "reset hiscores!?!", function()
 scoreatk_best=0
 timeatk_bestmin=0
 timeatk_bestsec=0
 dset(0,0)
 dset(1,0)
 dset(2,0)
end)

-- [[functions]]

-- horizontally center text
function hcenter(t)
 return 64-#tostr(t)*2
end

-- token-friendly flr(rnd(n))
function frnd(n)
 return flr(rnd(n))
end

-- token-friendly ceil(rnd(n))
function crnd(n)
 return ceil(rnd(n))
end

-- takes 3 numbers, an clamps it to either min or max
-- e.g clamp(3,5,100) --> 5
--     clamp(70,5,100) --> 100
function clamp(val, min, max)
 if abs(val-max) > abs(val-min) then
  return min
 else
  return max
 end
end

-- text scaling function by @gradualgames
function scale_text(text,tlx,tly,sx,sy,col)
 -- print text to screen, then store their
 -- pixels in an array
 local pixels={}
 print(text,0,0,7)
 for y=0,7 do
  for x=0,#tostr(text)*8-1 do
   local col=pget(x,y)
   if col!=0 then
    add(pixels,{x,y})
   end
  end
 end

 print(text,0,0,0)

 -- loop through the array and draw them
 for pixel in all(pixels) do
  local x=pixel[1]
  local y=pixel[2]
  local nx=x*sx+tlx
  local ny=y*sy+tly
  rectfill(nx,ny,nx+sx,ny+sy,col)
 end
end

-- handles screenshake
function screenshake()
 local shakex=5-rnd(10)
 local shakey=5-rnd(10)
 
 shakex*=screenshaking
 shakey*=screenshaking

 camerax=shakex
 cameray=shakey
  
 screenshaking*=0.5
 
 if (shake_fx == 0) camera(camerax,cameray) else camera(0,0)
end

-- same as screenshake, except it returns values
-- instead of affecting the camera
function hudshake()
 local shakex=2

 shakex*=hud_shaking

 hud_shaking*=0.5

 if (shake_fx == 0) return shakex else return 0
end

-- print text with outlines
function outline(s,x,y,c1,c2)
	for i=0,2 do
	 for j=0,2 do
	  if not(i==1 and j==1) then
	   print(s,x+i,y+j,c1)
	  end
	 end
	end
	print(s,x+1,y+1,c2)
end

-- [[animations]]

-- animation coroutine handler
function handle_animations()
 for an in all(animations) do
  if costatus(an) != "dead" then
   coresume(an)
  else
   del(animations, an)
  end
 end

 drawparticles()
 draw_explosions()
end

-- animation when a block is fully built
function block_created_an(_x,_y, _pal)
 local c=cocreate(function()
  local frames=0
  local x,y=_x,_y
  local w,h=_x+15,_y+9
  local colors=_pal

  while frames < 20 do
   -- update
   x-=1
   y-=0.5
   w+=1
   h+=0.5

   frames+=1
   -- draw
   if (frames == 1) rectfill(x,y,w,h,7)
   rect(x,y,w,h,colors[frames])
   yield()
  end
 end)

 add(block_animations, c)
end

-- animation when a ball hits a block
function block_destroyed_an(_x,_y,_col)
 local c=cocreate(function()
  local rad=12

  while rad > 0 do
   -- update
   rad-=1
   -- draw
   clip(_x-8,_y-4,16,10)
   circfill(_x, _y, rad, colors[_col])
   circfill(_x, _y+1, rad, colors[_col])
   circfill(_x-1, _y, rad, colors[_col])
   clip()
   yield()
  end
 end)

 add(block_animations, c)
 if (state == "game") sfx(6)
end

-- explosion for exploding balls
function add_explosion(_x,_y)
 add(explosions, {
  x=_x-20,
  y=_y-20,
  x2=_x+20,
  y2=_y+20,
  rad=1,
 })

 local x1,x2,y1,y2,ang

 for i=0,8 do
  x1=_x+rnd(20)-10
  y1=_y+rnd(20)-10

  ang=rnd()

  x2=x1+sin(ang)*6
  y2=y1+cos(ang)*6

  smoke_particle(x1,y1,{9,9,4,4,2},10,50,-i*3)
  smoke_particle(x2,y2,{12,5,6,5,1},10,30,-i*3-1)
  smoke_particle(_x+10,_y+10,{0},50,6,0)
 end

 whitescreen_timer=5
 screenshaking=50
end

-- destroy blocks in a radius
function update_explosions()
 for e in all(explosions) do
  for y=1,4 do
   for x=1,8 do
    local bl=blocks[y][x]

    if bl.x+15 >= e.x and bl.x <= e.x2
     and bl.y+9 >=e.y and bl.y <= e.y2
    then
     bl.state=1
     bl.build_y=bl.y+9
    end
   end
  end
  if e.rad < 200 then
   e.rad+=10
  else
   del(explosions, e)
  end
 end
end

-- draw a huge circle going off
function draw_explosions()
 for e in all(explosions) do
  circ(e.x+20, e.y+20, e.rad, 7)
  circ(e.x+20, e.y+20, e.rad-1, 6)
  pset(e.x, e.y, 12)
 end
end

-- particle system by @krystman, used for actual
-- explosion image
function smoke_particle(_x,_y,_c,_r,_life,_age)
 add(particles,{
  x=_x,
  y=_y,
  dx=-0.2+rnd(0.4),
  dy=-rnd(0.7),
  r=_r, --radius
  age=_age or 0,
  maxage=_life,
  col=_c --color
 })
end

function updateparticles()
 for p in all(particles) do
  if p.age >= p.maxage
   or p.y > 128
   or p.y < 0
   or p.x > 128
   or p.x < 0
  then
   del(particles,p)
  else
   if p.age>=0 then
    p.x+=p.dx
    p.y+=p.dy
   end
   p.age+=1
  end
 end
end

function drawparticles()
 for p in all(particles) do
  local agemult=1
  local color

  agemult=(p.age-5)/p.maxage
  agemult=1-(agemult*agemult)
  agemult=mid(0,agemult,1)
  
  color=p.col[mid(#p.col,p.age,1)]

  if (not time_stopped) fillp(0xedb7)
  circfill(p.x,p.y,p.r*agemult,color)
  fillp()
 end
end

function puft(_x,_y,_c,_life)
 for i=1,4 do
  smoke_particle(_x,_y,_c,2,_life)
 end
end

-- vhs like effect when time is stopped by whiteoutlabs.com
function screenglitch()
 if glitch_on then
  local p={7,13,5}
  local c=p[crnd(3)]

  for i=0,5,4 do
   local height=frnd(128)
   for h=0,100,2 do
    pset(frnd(128), height, c)
   end 
  end
 end

 if glitch_frames > 30 and glitch_frames < 50 then
  glitch_on=true
 elseif glitch_frames > 70 and glitch_frames < 80 then
  glitch_on=true
 elseif glitch_frames > 100 and glitch_frames < 110 then
  glitch_on=true
 else
  glitch_on=false
 end
 glitch_frames+=1
end

-- [[functions: title screen]]

-- update background dots
function update_title_bgdots()
 for b in all(title_bgdots) do
  if b.rad < 0 then
   b.color=colors[crnd(4)]
   b.x_offset=10-frnd(5)
   b.y_offset=10-frnd(5)
  end
  b.rad=sin((title_frames+b.y-b.x)/120)*15
 end
end

-- draw background dots
function draw_title_bgdots()
 for b in all(title_bgdots) do
  circfill(b.x+b.x_offset,b.y+b.y_offset,b.rad,b.color)
 end
end

-- displays your best score depending on gamemode selected
function title_score_display(_score)
 local y=59+sin(title_frames/70)*8
 outline(title_hiscore_str,hcenter(title_hiscore_str),y,0,7)

 if type(_score) == "string" or _score < 10000 then
  scale=3
 else
  scale=2
 end

 local score_x=65-#tostr(_score)*6
 for i=-1,2 do
  for j=-1,3 do
   if (not (i == 1 and j == 1)) scale_text(_score, score_x+i, y+8+j, scale, scale, 0)
  end
 end
 scale_text(_score, score_x, y+9, scale, scale, 1)
 scale_text(_score, score_x, y+8, scale, scale, 12)
end

-- [[functions: game]]

-- check if player lost, if yes
-- clear table, set gameover to true
function check_lose()
 local prepare=function()
  for y=1,4 do
   for x=1,8 do
    if (blocks[y][x].state < 3 or gamemode == 1) blocks[y][x].state=0
   end
  end
  results_setbonusblocks()
 end

 if flr(hud_y) == 10 then
  if gamemode == 0 then
   if (wave.timer == 0 and not gameover) prepare() gameover=true
  else
   if (not checkblocks() and not gameover) prepare() timer_color=8 gameover=true
  end
 end
end

-- gets called once a second
-- dictates max ball types
-- 0 - normal
-- 1 - burning
-- 2 - explosive
function new_wave()
 wave.current+=1
 local current_wave=wave.current

 if 1 <= current_wave and current_wave <=3 then
  wave.maxballtype=0
 elseif current_wave <= 4 and current_wave <= 7 then
  wave.maxballtype=1
 else
  wave.maxballtype=2
 end
end

-- check if all blocks are on at the same time
function check_fullgrid()
 if (time_stopped) return false
 for y=1,4 do
  for x=1,8 do
   if (blocks[y][x].state < 3) return false
  end
 end

 if cangetbomb then
  score+=10
  for y=1,4 do
   for x=1,8 do
    local bl=blocks[y][x]

    fullgrid_an(bl.x, bl.y, x, y)
   end
  end
  sfx(15)
  cangetbomb=false
 end
end

-- gets called every second, adds
-- to your score depending on blocks currently on
function calculate_scoreatk_score()
 local score=0
 
 for y=1,4 do
  for x=1,8 do
   if (blocks[y][x].state==3) score+=5-1*y
  end
 end
 
 return score
end

-- gets called when you press Ž
function use_bomb()
 if bombs > 0 then
  last_note=stat(24)
  sfx(-1)
  music(-1)
  sfx(28)
  screenshaking=7
  time_stopped=true
  bombs-=1
 end
end

-- hud falling animation
function hud_intro()
 if hud_y < 10 or hud_vy!=0 then
  if hud_y+hud_vy < 10 then
   hud_vy+=0.1
  else
   if (abs(ceil(hud_vy)) > 1) sfx(1) screenshaking=flr(hud_vy)/8
   hud_vy=-hud_vy/2
  end
  hud_y+=hud_vy
 else
  if (countdown == 120 and music_on == 0) music(0)
  return true
 end
end

-- decreases timestop timer, various fx, etc.
function timestop_update()
 if time_stopped then
  if timestop_timer < 45 then
   timestop_timer+=0.25
   for i=1,16 do
    pal(i-1, blackwhite[i])
   end

   local pal={7,7,7,7,6,6,6,6,5,5,5,5}
   if (gamemode == 0) puft(85-timestop_timer, hud_y+29, pal, 12) else puft(100-timestop_timer*1.63, hud_y+29, pal, 12)
  else
   pal()
   timestop_timer=0
   glitch_frames=0
   sfx(-1)
   if (music_on == 0) music(last_note)
   time_stopped=false
  end
 end
end

-- draw countdown hud
function draw_prehud()
 scale_text("0"..ceil(countdown/20), hud_x, hud_y, 5, 5, 1)

 rect(40,hud_y+27,85,hud_y+28,1)

 if hud_vy == 0 and flr(hud_y) == 10 then
  for c=1,10 do
   local color

   if (12-ceil(countdown/10) == c) color=12 else color=1
   print(sub("get ready!",c,c), 40+c*4, score_y, color)
  end

  draw_tutorial()
 end
end

-- draw hud for score attack gamemode
function draw_scoreatkhud()
 if wave.timer < 6 then
  if (bombs == 0) bomb_sprite=54 bomb_color=2 else bomb_sprite=53 bomb_color=8
  if not time_stopped then
   timer_color=8
   blackwhite[14]=8
  end
 else
  if (bombs == 0) bomb_sprite=38 bomb_color=1 else bomb_sprite=52 bomb_color=12
  if not time_stopped then
   timer_color=1
   blackwhite[14]=12
  end
 end

 if wave.timer < 10 then
   scale_text("0"..wave.timer, hud_x, hud_y, 5, 5, timer_color)
 else
  scale_text(wave.timer, hud_x, hud_y, 5, 5, 1)
 end
end

-- draw hud for time attack gamemode
function draw_timeatk_hud()
 if gameover then
  if (bombs < 4) bomb_sprite=54 else bomb_sprite=53
  if not time_stopped then
   timer_color=8
   blackwhite[14]=8
   if (bombs > 0) bomb_color=8 else bomb_color=2
  end
 else
  if (bombs < 4) bomb_sprite=38 else bomb_sprite=52
  if not time_stopped then
   timer_color=1
   blackwhite[14]=12
   if (bombs > 0) bomb_color=12 else bomb_color=1
  end
 end

 if wave.minutes < 10 then
  scale_text("0"..wave.minutes, hud_x-15, hud_y+2, 4, 4, timer_color)
 else
  scale_text(wave.minutes, hud_x-15, hud_y+2, 4, 4, timer_color)
 end

 scale_text(":", hud_x+12, hud_y+2, 4, 4, timer_color)

 if wave.seconds < 10 then
  scale_text("0"..wave.seconds, hud_x+23, hud_y+2, 4, 4, timer_color)
 else
  scale_text(wave.seconds, hud_x+23, hud_y+2, 4, 4, timer_color)
 end

 rect(26,hud_y+27,100,hud_y+28,timer_color)
end

function scoreatk_score()
 if not time_stopped then
  wave.timer-=1 
  if (wave.timer > 3 ) hud_shaking=2 else hud_shaking=3
 end
 score+=calculate_scoreatk_score()
end

function timeatk_score()
 if not time_stopped then
  if wave.seconds < 59 then
   wave.seconds+=1
  else
   wave.seconds=0
   wave.minutes+=1
  end
  hud_shaking=2
 end
end

-- update icons/hints when playing for first time
function update_tutorial()
 if tutorial_level == 0 then
  if (btn(0) or btn(1)) tutorial_level=1
 elseif tutorial_level == 1 then
  if (btnp(5)) tutorial_level=2
 elseif tutorial_level == 2 then
  if (btnp(5) and ysel != 4) tutorial_level=3
 elseif tutorial_level == 3 then
  if (tutorial_frames < 200) tutorial_frames+=1 else tutorial_level=4
 elseif tutorial_level == 4 then
  if (bombs > 0) tutorial_level=5
 elseif tutorial_level == 5 then
  if (btnp(4)) tutorial_level=6
 end
 dset(5, tutorial_level)
end

-- draw said icons/hints
function draw_tutorial()
 if tutorial_level == 0 then
  spr(132,34,111,2,2)
  spr(134,68,111,2,2)
 elseif tutorial_level == 1 then
  for x=1,8 do
   if (x != 4) spr(128,blocks[4][x].x,blocks[4][x].y,2,2)
  end
 elseif tutorial_level == 2 then
  for x=1,8 do
   local bl=blocks[3][x]

   if (bl.state == 1) spr(130,bl.x,bl.y,2,2)
  end
 elseif tutorial_level == 3 then
  print("fill the grid!",36,67,1)
 elseif tutorial_level == 5 then
  print("Ž",hud_x,hud_y+30,12)
 end
end

-- [[functions: blocks]]
function move_selection()
 if btnp(0) then
  if xsel > 1 then 
   xsel-=1
  else
   if (block_wrap == 1) xsel=8
  end
 end
 
 if btnp(1) then
  if xsel < #blocks[ysel]then
   xsel+=1
  else
   if (block_wrap == 1) xsel=1
  end
 end
 
 if btnp(2) then
  if (xsel > 8) xsel=8
  if ysel > 1 then 
   ysel-=1
  else
   if (block_wrap == 1) ysel=4
  end
 end
 
 if btnp(3) then
  if (xsel > 8) xsel=8
  if ysel < 4 then
   ysel+=1
  else
   if (block_wrap == 1) ysel=1
  end
 end
end

function set_blocks()
 -- check if any balls overlap with selected block
 local checkballs=function()
  if (#balls == 0) return true
  for ba in all(balls) do
   if (inside_block(ba.x+ba.vx, ba.y+ba.vy, blocks[ysel][xsel].x, blocks[ysel][xsel].y)) return false

   return true
  end
 end
 
 if (checkballs()) blocks[ysel][xsel].state=2

 if ysel > 1 then
  if (blocks[ysel-1][xsel].state == 0) blocks[ysel-1][xsel].state=1

  if ysel%2 == 0 then
   if (xsel < 8 and blocks[ysel-1][xsel+1].state == 0) blocks[ysel-1][xsel+1].state=1
  else
   if (xsel > 1 and blocks[ysel-1][xsel-1].state == 0) blocks[ysel-1][xsel-1].state=1
  end
 end
end

-- draw selection animation
function draw_block_selection()
 local bl=blocks[ysel][xsel]

 if (block_selected_sprite < #block_selection_sprites) block_selected_sprite+=1 else block_selected_sprite=1
 
 if not time_stopped then
  if bl.state == 3 then
   pal(15, muted_colors[ysel])
  else
   pal(15, colors[ysel])
  end
 end

 if ysel == 3 and not time_stopped then
  pal(14, 5)
 else
  pal(14, 7)
 end

 if (block_intro_x > 3 or block_intro_y < 4) spr(block_selection_sprites[block_selected_sprite], bl.x, bl.y, 2, 2)
end

-- draw "shining" animation
function fullgrid_an(_x,_y, _block_x, _block_y)
 local c=cocreate(function()
  local frames=1
  local dots={}
  local sprites={39,41,43,45,64,66,68,70,72,74,76,78,96,98,100,102,104} 
  local thissprite=1
  local bl_state

  while frames < 51 do
   bl_state=blocks[_block_y][_block_x].state
   -- iterate through sprites
   if (frames%3 == 0 and thissprite < 17) thissprite+=1

   -- add dots
   if frames%15 == 0 and #dots < 2 then
    add(dots, {
     frames=1,
     sprite=106,
     x=_x+frnd(6)*2,
     y=_y+frnd(3)*2
    })
   end

   for d in all(dots) do
    --update dots
    if d.sprite < 111 then
     if (d.frames%6 == 0) d.sprite+=1
     d.frames+=1
    else
     del(dots, d)
    end
    --draw dots
    if (bl_state == 3) spr(d.sprite, d.x, d.y)
   end

   frames+=1

   if (bl_state == 3) spr(sprites[thissprite], _x, _y, 2, 2)
   yield()
  end
  if (_block_x == 1 and _block_y == 1 and not time_stopped) bombs+=1
  cangetbomb=true
  yield()
 end)

 add(animations, c)
end

-- draw block intro, return true if done
function block_intro()
 if block_intro_done then
  return true
 else
  if block_intro_frames%3 == 0 then
   local x=block_intro_x
   local y=block_intro_y

   if (y == 4) blocks[y][x].state=1 else blocks[y][x].state=0
   block_created_an(blocks[y][x].x, blocks[y][x].y, {7,7,7,7,7,6,6,6,6,6,5,5,5,5,5,1,1,1,1,1})
   sfx(7)

   if x == 8 and y == 1 then
    blocks[4][4].state = 2
    block_intro_done=true
   end

   if x < 8 then
    block_intro_x+=1
   else
    block_intro_y-=1
    block_intro_x=1
   end
  end
 end
 block_intro_frames+=1
end

-- function for checking if any blocks are on in time attack
function checkblocks()
 for y=1,4 do
  for x=1,8 do
   if (blocks[y][x].state == 3) return true
  end
 end

 return false
end

-- [[functions: balls]]

-- return true if a ball is inside a block
function inside_block(bx,by,tx,ty)
 if (bx+5 < tx) return false
 if (bx+1 > tx+15) return false
 if (by+5 < ty) return false
 if (by+1 > ty+9) return false

 return true
end

-- angle calculation function by @krystman
function deflx_ballbox(bx,by,bdx,bdy,tx,ty)
 -- calculate wether to deflect the ball
 -- horizontally or vertically when it hits a box
 local tw,th=15,9
 if bdx == 0 then
  -- moving vertically
  return false
 elseif bdy == 0 then
  -- moving horizontally
  return true
 else
  -- moving diagonally
  -- calculate slope
  local slp = bdy / bdx
  local cx, cy
  -- check variants
  if slp > 0 and bdx > 0 then
   -- moving down right
   cx = tx-bx
   cy = ty-by
   if cx<=0 then
    return false
   elseif cy/cx < slp then
    return true
   else
    return false
   end
  elseif slp < 0 and bdx > 0 then
   -- moving up right
   cx = tx-bx
   cy = ty+th-by
   if cx<=0 then
    return false
   elseif cy/cx < slp then
    return false
   else
    return true
   end
  elseif slp > 0 and bdx < 0 then
   -- moving left up
   cx = tx+tw-bx
   cy = ty+th-by
   if cx>=0 then
    return false
   elseif cy/cx > slp then
    return false
   else
    return true
   end
  else
   -- moving left down
   cx = tx+tw-bx
   cy = ty-by
   if cx>=0 then
    return false
   elseif cy/cx < slp then
    return false
   else
    return true
   end
  end
 end
 return false
end

-- add ball trail particle
function add_ball_part(_x,_y,_pal)
 local p={
  x=_x+4-frnd(5),
  y=_y+3,
  timer=1,
  pal=_pal,
  color=1
 }

 add(ball_particles, p)
end

function update_ball_parts()
 for p in all(ball_particles) do
  if p.timer < 40 then
   p.timer+=1
   if (p.timer % 10 == 0) p.color+=1
  else
   del(ball_particles, p)
  end
 end
end

function draw_ball_parts()
 for p in all(ball_particles) do
  circfill(p.x, p.y, 4-p.color, p.pal[p.color])
 end
end

-- add ball starting ("blast off") particle
function add_ball_circle(_x,_y)
 local c={
  x=_x,
  y=_y,
  rad=0,
  current_col=0,
  timer=0
 }

 add(ball_start_circles, c)
end

function update_ball_circles()
 for c in all(ball_start_circles) do
  if c.timer < 20 then
   c.timer+=1
   if (c.timer%4 == 0) c.current_col+=1
   c.rad+=0.5
  else
   del(ball_start_circles, c)
  end
 end
end

function draw_ball_circles()
 for c in all(ball_start_circles) do
  local palette={7,10,9,1}

  circ(c.x, c.y, c.rad, palette[c.current_col])
 end
end

-- [[functions: results]]
-- replace blocks with "fake" bonus blocks, store them in an array
function results_setbonusblocks()
 for y=1,4 do
  for x=1,8 do
   if (blocks[y][x].state == 3) add(results_bonus_blocks, {x=x, y=y})
  end
 end
end

-- calculate/animate score attack results
function results_calc_scoreatk()
 if results_score < score then
  results_score=mid(0,results_score+15,score)
  sfx(11)
  if (results_frames%2 == 0 and results_score_y == 24) results_score_y=20
 else
  if results_bonus_text_y < 44 then
   results_bonus_text_y+=1
   results_bonus_y+=1

   results_bombs_text_y+=1
   results_bombs_y+=1
  else
   if #results_bonus_blocks > 0 then
    if results_frames%5 == 0 then
     bl=blocks[results_bonus_blocks[1].y][results_bonus_blocks[1].x]

     results_bonus+=50
     results_bonus_y=41

     block_destroyed_an(bl.x+8, bl.y+4, results_bonus_blocks[1].y)
     block_created_an(bl.x, bl.y, {7,7,7,7,7,6,6,6,6,6,5,5,5,5,5,1,1,1,1,1})
     bl.state=0
     del(results_bonus_blocks, results_bonus_blocks[1])
    end
    sfx(11)
   else
    if results_bombs_text_y < 65 then
     results_bombs_text_y+=1
     results_bombs_y+=1
    else
     if results_bombs < bombs*500 then
      if results_frames%5 == 0 then
       results_bombs+=500
       results_bombs_y=61
      end
      sfx(11)
     elseif (results_bombs == bombs*500 and results_bombs_y == 65) or bombs == 0 then
      results_frames=0
      results_state="display"
     end
    end
   end
   if (results_bombs_y < 65) results_bombs_y+=1
  end
  if (results_bonus_y < 44) results_bonus_y+=1
 end
 if (results_score_y < 24) results_score_y+=1
end

-- calculatr/animate time attack results
function results_calc_timeatk()
 if results_mins < wave.minutes and results_secs < wave.seconds then
  if results_secs < 59 then
   results_secs+=1
  else
   results_mins+=1
   results_secs=0
  end
  if (results_frames%2 == 0 and results_time_y == 24) results_time_y=20
 else
  if results_bombs_text_y < 44 then
   results_bombs_text_y+=1
   results_bombs_y+=1
  else
   if results_bombs < bombs*20 then
    if results_frames%5 == 0 then
     results_bombs+=20
     results_bombs_y=41
    end
   elseif (results_bombs == bombs*20 and results_bombs_y == 44) or bombs == 0 then
    results_frames=0
    results_state="display"
   end
  end
  if (results_bombs_y < 44) results_bombs_y+=1
 end
 if (results_time_y < 24) results_time_y+=1
end

-- add particle displayed when final score is displayed
function add_results_part(vx)
 local p={
  x=62+crnd(4),
  y=92+crnd(13),
  vx=vx,
  col=12,
  timer=0
 }

 add(results_particles, p)
end

function update_results_parts()
 for p in all(results_particles) do
  if p.timer < 80 then
   p.x+=p.vx
   p.timer+=1
   if (p.timer % 60 == 0) p.col=1
  else
   del(results_particles, p)
  end
 end
end

function draw_results_parts()
 for p in all(results_particles) do
  rect(p.x,p.y,p.x+1,p.y+1,p.col)
 end
end

-- display different scores for score attack
function results_scoreatk_display()
 -- bomb bonus display
 print("bomb bonus |",20,results_bombs_text_y,7)
 print(results_bombs,69,results_bombs_text_y, 1)
 if (results_bombs > 0) print(results_bombs, 69, results_bombs_y, 12)
 -- block bonus display
 rectfill(0,results_bonus_text_y,127,results_bonus_text_y+6,0)
 print("block bonus|",20,results_bonus_text_y,7)
 print(results_bonus,69,results_bonus_text_y,1)
 if (results_bonus > 0) print(results_bonus,69,results_bonus_y,12)

 -- score display
 rectfill(0,results_score_text_y,127,results_score_text_y+6,0)
 print("score|",44,results_score_text_y,7)
 print(results_score,69,results_score_text_y,1)
 if (results_score > 0) print(results_score,69,results_score_y,12)
end

-- final score display for score attack
function results_scoreatk_final()
 local final_score=results_score + results_bonus + results_bombs
 local score_x=65-#tostr(final_score)*6

 scale_text(final_score, score_x, 92, scale, scale, 1)
 scale_text(final_score, score_x, 91, scale, scale, 12)
 if (final_score > scoreatk_best) outline("new best score!!", 32, 79, 0, 12) else outline("final score", 42, 79, 0, 1)
end

-- final score display for time attack
function results_timeatk_final()
 local mins
 local secs
 local final_time

 if wave.minutes < 10 then
  mins="0"..wave.minutes
 else
  mins=wave.minutes
 end

 if wave.seconds < 10 then
  secs="0"..wave.seconds
 else
  secs=wave.seconds
 end

 final_time=mins..":"..secs

 scale_text(final_time, 35, 92, 3, 3, 1)
 scale_text(final_time, 35, 91, 3, 3, 12)

 if wave.seconds > timeatk_bestsec then
  if (wave.minutes >= timeatk_bestmin) outline("new best time!!", 34, 79, 0, 12) results_besttime=true
 else
  outline("final time", 44, 79, 0, 1) results_besttime=false
 end
end

-- [[functions: transition]]

-- (re)set transition variables
function reset_transition()
 transition_frames=0

 transition_color=8+frnd(4)
 transition_direction=frnd(2)
 transition_axis=frnd(2)

 -- dots for transition
 transition_dots={}
 for x=0,127,31 do
  for y=0,127,31 do
   local d={}

   d.x=x+(10-rnd(5)*2)
   d.y=y+(10-rnd(5)*2)
   
   if transition_axis == 0 then
    if (transition_direction == 1) d.rad=-x/5 else d.rad=-(124-x)/5
   else
    if (transition_direction == 1) d.rad=-y/5 else d.rad=-(124-y)/5
   end

   add(transition_dots, d)
  end
 end
end

-- stops all sound, sets next state and starts transition
function new_state(state)
 music(-1)
 sfx(-1)
 next_state=state
 sfx(0)
 do_transition=true
end

-- [[variables: misc.]]
state=nil
camerax,cameray=0,0
gamemode=0
tutorial_level=dget(5)
tutorial_frames=0
music_on=dget(6)

animations={}
block_animations={}
particles={}

glitch_on=false
glitch_frames=0

colors={8,9,10,11}
muted_colors={2,4,9,3}
blackwhite={0,5,5,5,5,5,6,7,5,6,7,6,6,12,5,5}
shake_fx=dget(4)
screenshaking=0
whitescreen_timer=0

scoreatk_best=dget(0)
timeatk_bestmin=dget(1)
timeatk_bestsec=dget(2)

-- [[variables: title screen]]
title_y=-120
title_frames=0
title_sel=0
title_str="1-min button mashing action"
title_char=0
title_hiscore_str="your highscore"
title_gamemode_y=95

title_bgdots={}
for y=0,127,42 do
 for x=0,127,42 do
  local b={
   x=x,
   y=y,
   x_offset=0,
   y_offset=0,
   rad=0,
   color=8+frnd(4)
  }

  add(title_bgdots, b)
 end
end
del(title_bgdots, title_bgdots[1])

-- [[variables: game + results]]

-- (re)set almost every variable
function start_game()
 hud_y=-100
 hud_vy=0
 hud_shaking=0

 gameover=false

 xsel,ysel=4,4
 wave={
  current=0,
  timer=60,
  minutes=0,
  seconds=0,
  frames=0,
  maxballtype=0
 }
 countdown=120
 cangetbomb=true
 explosions={}
 score=0
 bombs=0
 time_stopped=false
 timestop_timer=0
 last_note=8

 balls={}

 init_blocks()
 block_intro_x=1
 block_intro_y=4
 block_intro_done=false

 results_frames=0
 results_state="counting"
 results_line_x=0
 results_str_y=-56

 results_score=0
 results_score_y=10
 results_score_text_y=10

 results_besttime=false
 results_time_y=10
 results_time_text_y=10

 results_bonus=0
 results_bonus_y=10
 results_bonus_text_y=10

 results_bombs=0
 results_bombs_y=10
 results_bombs_text_y=10

 results_bonus_blocks={}
 results_bonus_blocks_checked=false

 results_particles={}

 results_nextgamemode=0
end


-- [[variables: blocks]]
block_selection_sprites={1,1,3,3,5,5,7,7,9,9,11,11,13,13,33,33}
block_selected_sprite=1
block_wrap=dget(3)
block_intro_x=1
block_intro_y=4
block_intro_frames=0
block_intro_done=false

-- [[variables: balls]]
ball_start_circles={}
ball_particles={}
ball_particle_colors={10,9,4,1}
ball_particle_colors_burning={8,8,2,1}
ball_particle_colors_explosive={7,6,6,1}

-- [[variables: transition]]
next_state="title"
do_transition=true
sfx(0)

reset_transition()
-->8
-- [[blocks: initialization]]

-- init blocks, wrapped in func.
-- for use in start_game()
function init_blocks()
 blocks={}
 for y=1,4 do
  blocks[y]={}
  for x=1,8 do
   local x_offset
   if (y%2 == 0) x_offset=0 else x_offset=-8

   local bl={}

   bl.x=x_offset+(x-1)*17
   bl.y=78+(y-1)*11
   bl.build_y=bl.y+9
   bl.state=4

   blocks[y][x]=bl
  end
 end
end

-- [[blocks: update]]
function update_blocks()
 for y=1,4 do
  for x=1,8 do
   local bl=blocks[y][x]

   if bl.state == 2 then
    for ba in all(balls) do
     if (inside_block(ba.x+ba.vx, ba.y+ba.vy, bl.x, bl.y)) bl.state=1 block_created_an(bl.x, bl.y, {8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,2,2,2,2}) del(balls, ba) sfx(6,0)
    end
    if bl.build_y > bl.y then
     bl.build_y=mid(bl.y, bl.build_y-0.3, bl.y+9) 
    else
     bl.state=3

     local outline_col=muted_colors[y]
     block_created_an(bl.x, bl.y, {7,7,7,7,7,6,6,6,6,6,5,5,5,5,5,outline_col,outline_col,outline_col,outline_col,outline_col})
    end
   elseif bl.state == 3 then
    if gamemode == 1 and countdown == 0 and not time_stopped then
     if bl.build_y < bl.y+9 then
      bl.build_y=mid(bl.y, bl.build_y+0.05, bl.y+9)
     else
      sfx(6,0)
      bl.state=1
     end
    end
   end
  end
 end
end

-- [[blocks: draw]]
function draw_blocks()
 -- blocks
 for y=1,4 do
  for x=1,8 do
   local bl=blocks[y][x]

   -- colors
   local build_color, border_color
   if bl.state == 0 then
    border_color=1
   elseif bl.state == 1 then
    border_color=muted_colors[y]
   elseif bl.state == 2 then
    border_color=colors[y]
    build_color=muted_colors[y]
   elseif bl.state == 3 then
    border_color=colors[y]
    build_color=colors[y]
   elseif bl.state == 4 then
    border_color=0
    build_color=0
   end

   if (bl.state > 1) rectfill(bl.x,bl.y+9,bl.x+15,bl.build_y,build_color)
   rect(bl.x,bl.y,bl.x+15,bl.y+9,border_color)
  end
 end

 for an in all(block_animations) do
  if costatus(an) != "dead" then
   coresume(an)
  else
   del(block_animations, an)
  end
 end
end
-->8
-- [[balls: initialization]]
function add_ball(_type)
 local ba={}

 ba.x=mid(4, frnd(43)*3, 120)
 ba.y=6
 ba.vx=nil
 ba.vy=nil
 if (frnd(2) == 0) ba.vx=1 else ba.vx=-1
 ba.timer=0
 ba.bounces=0
 ba.canbounce=0
 ba.type=_type or 0

 if ba.type == 0 then
  ba.vx,ba.vy=1*ba.vx,1
 elseif ba.type == 1 then
  ba.vx,ba.vy=1*ba.vx,1
 else
  ba.vx,ba.vy=0.5*ba.vx,0.5
 end

 if (#balls < 4) sfx(9)
 add(balls, ba)
end

-- [[balls: update]]
function update_balls()
 for ba in all(balls) do
  local next_x=ba.x+ba.vx
  local next_y=ba.y+ba.vy

  -- screen collision
  if (next_x+1 < 0 or next_x+5 > 127) ba.vx=-ba.vx
  if (next_y+5 > 127) ba.vy=-ba.vy

  if next_y < 0 then
   if ba.type == 1 or gameover or ba.bounces > 4 then
    if next_y < -60 then
     del(balls, ba)
    end
   else
    ba.vy=-ba.vy
   end
  end
  -- block collision
  for y=1,4 do
   for x=1,8 do
    local bl=blocks[y][x]

    if inside_block(next_x, next_y, bl.x, bl.y) and bl.state == 3 then
     if ba.type == 0 and ba.canbounce == 0 then
      if (deflx_ballbox(ba.x+1, ba.y+1, ba.vx, ba.vy, bl.x, bl.y)) ba.vx=-ba.vx else ba.vy=-ba.vy
      block_destroyed_an(bl.x+8, bl.y+4, y)
      bl.state=1
      bl.build_y=bl.y+9
      sfx(12)
      ba.canbounce=2
     elseif ba.type == 1 then
      block_destroyed_an(bl.x+8, bl.y+4, y)
      bl.state=1
      bl.build_y=bl.y+9
      sfx(13)
     elseif ba.type == 2 then
      add_explosion(ba.x, ba.y)
      del(balls, ba)
      sfx(14)
     end
     ba.bounces+=1
    end
   end
  end

  if ba.timer > 60 then
   ba.x=next_x
   ba.y=next_y
   if (ba.canbounce > 0) ba.canbounce-=1
  elseif ba.timer == 60 then
   screenshaking=2
   add_ball_circle(ba.x, ba.y)
   sfx(10)
  end

  ba.timer+=1
  if ba.timer%5 == 0 then
   local palette
   local y_offset

   if ba.type==0 then
    palette={10,9,4,2}
   elseif ba.type==1 then
    palette={8,8,2,1}
   else
    palette={7,6,6,5}
   end

   if (ba.timer < 60) y_offset=-3+frnd(5) else y_offset=0
   add_ball_part(ba.x, ba.y+y_offset, palette)
  end
 end
end

-- [[balls: draw]]
function draw_balls()
 for ba in all(balls) do
  if ba.type == 0 then
   spr(35, ba.x, ba.y)
  elseif ba.type == 1 then
   spr(36, ba.x, ba.y)
  elseif ba.type == 2 then
   spr(37, ba.x, ba.y)
  end
 end
end
-->8
-- [[title screen: update]]
function title_update()
 if 200 < title_y then
  update_title_bgdots()

  if title_frames%2 == 0 then
   if (title_char < #title_str) title_char+=1 sfx(3)
  end
 elseif 50 < title_y and title_y < 170 then
  screenshaking=0.2
  if (title_frames%5 == 0 and title_y < 150) sfx(1)
 elseif title_y == 174 then
  if (music_on == 0) music(13)
 end

 if btnp(0) and title_sel == 1 then
  title_sel=0
  title_str="1-min button mashing action"
  title_char=0
  title_hiscore_str="your highscore"
  sfx(2)
 elseif btnp(1) and title_sel == 0 then
  title_sel=1
  title_str="game over if board is empty"
  title_char=0
  title_hiscore_str="your best time"
  sfx(2)
 end
 if (btnp(5) or btnp(4)) gamemode=title_sel new_state("newgame")

 title_frames+=1
 title_y=mid(-120,title_y+3,201)
end

-- [[title screen: draw]]
function title_draw()
 if title_y > 200 then
  draw_title_bgdots()
  rectfill(11,29,118,46,0)
 end

 for c=1,9 do
  scale_text(sub("breakdown",c,c),c*12,mid(-150,title_y-8-c*12,30),3,3,12)
  scale_text(sub("breakdown",c,c),c*12,mid(-150,title_y-c*12,30),3,3,7)
 end
 outline("doczi_dominik,gruber ~ 2019", 10, 121, 0, 7)

 if 172 < title_y and title_y < 200 then
  cls(7)
 elseif 200 < title_y then
  --outline("score attack   time attack",12,95,0,7)
  for i=1,26 do
   outline(sub("score attack   time attack",i,i),8+i*4,95+sin((title_frames+i)/70)*8,0,7)
  end

  outline(sub(title_str,1,title_char), 10, 113, 9, 0)
  outline(sub(title_str,title_char+1,title_char+1), 10+(title_char*4), 110, 9, 0)

  if title_sel == 0 then
   for i=1,26 do
    outline(sub("score attack             ",i,i),8+i*4,95+sin((title_frames+i)/70)*8,0,9)
   end
   title_score_display(scoreatk_best)
  else
   for i=1,26 do
    outline(sub("               time attack",i,i),8+i*4,95+sin((title_frames+i)/70)*8,0,9)
   end

   local score_str
   local min_str
   local sec_str

   if (timeatk_bestsec < 10) sec_str="0"..timeatk_bestsec else sec_str=timeatk_bestsec
   if timeatk_bestmin > 0 then
    if (timeatk_bestmin < 10) min_str="0"..timeatk_bestmin

    score_str=min_str..":"..sec_str
   else
    score_str=sec_str
   end
   title_score_display(score_str)
  end
 end
end

-->8
-- [[game: update]]
function game_update()
 check_lose()
 if gameover and #balls == 0 then
  state="results"
 else
  if block_intro() then
   if hud_intro() then

    update_tutorial()

    if (gamemode == 0) running_check=wave.timer>0 else running_check=checkblocks()
    if running_check then
     move_selection()
     if (btnp(5) and blocks[ysel][xsel].state == 1) set_blocks()
  
     if countdown > 0 then
      countdown-=1
     else
      if wave.frames%(120-(frnd(3)*10)) == 0 and not time_stopped then
       if crnd(10) <= wave.current then
        add_ball(crnd(wave.maxballtype))
       else
        add_ball()
       end
      end
  
      check_fullgrid()

      -- timestop
      if (btnp(4)) use_bomb()
      timestop_update()
  
      wave.frames+=1
      if wave.frames%60 == 0 then
       if (gamemode == 0) scoreatk_score() else timeatk_score()
      end

      if (wave.frames%300 == 0 and not time_stopped) new_wave()
     end
    else
     music(-1)
     for b in all(balls) do
      if (b.vy > 0) b.vy=-b.vy
     end
    end
   end
  end

  -- objects
  if not time_stopped then
   update_explosions()

   update_ball_circles()
   update_balls()
   update_ball_parts()
  end

  update_blocks()
 end
end

-- [[game: draw]]
function game_draw()
 -- hud
 hud_x=45+hudshake()
 timer_color=1
 bomb_color=1
 bomb_sprite=38
 timestop_color=12
 score_y=hud_y+30

 if countdown > 0 then
  draw_prehud()
 else
  draw_tutorial()
  
  if (gamemode == 0) draw_scoreatkhud() else draw_timeatk_hud()

  if gameover then
   print("finish!", 50, score_y, 8)
  else
   spr(bomb_sprite,56,score_y)
    
   print(bombs,64,score_y, bomb_color)
  end
 end

 rect(40,hud_y+27,85,hud_y+28,timer_color)

 if time_stopped then
  if (gamemode == 0) rect(40,hud_y+27,85-timestop_timer,hud_y+28,13) else rect(26,hud_y+27,100-timestop_timer*1.63,hud_y+28,13)
  screenglitch()
 end

 -- objects
 draw_blocks()
 if (time_stopped) handle_animations()

 draw_ball_parts()
 draw_block_selection()

 draw_balls()
 draw_ball_circles()

 if (whitescreen_timer > 0) cls(7) whitescreen_timer-=1
 if (not time_stopped) handle_animations()
end
-->8
-- [[results: update]]
function results_update()
 if results_state == "counting" then
  if results_frames < 80 then
   hud_vy+=0.1
   hud_y-=hud_vy
  elseif 81 < results_frames and results_frames < 121 then
   results_line_x+=1
  elseif 122 < results_frames and results_frames < 260 then
   results_str_y+=2
   if (150 < results_frames and results_frames < 200 and results_frames%5 == 0) sfx(8)
  elseif 265 < results_frames and results_frames < 280 then
   if gamemode == 0 then
    results_score_y+=1
    results_score_text_y+=1
    results_bonus_y+=1
    results_bonus_text_y+=1
    results_bombs_y+=1
    results_bombs_text_y+=1
    results_time_y+=1
    results_time_text_y+=1
   else
    results_frames=301
   end
  elseif 300 < results_frames then
   if (gamemode == 0) results_calc_scoreatk() else results_frames=0 results_state="display"
  end
 else
  if results_frames == 21 then
   for y=2,3 do
    for x=3,6 do
     blocks[y][x].state=4
    end
   end
   screenshaking=30
  end

  if results_frames%20 == 0 then
   add_results_part(-0.5)
   add_results_part(0.5)
  end

  update_results_parts()

  if (results_bonus_y < 40) results_bonus_y+=1
  if (results_score_y < 24) results_score_y+=1

  if btnp(5) or btnp(4) then
   if (results_score + results_bonus + results_bombs > scoreatk_best) dset(0, results_score+results_bonus+results_bombs)
   if (results_besttime) dset(1,wave.minutes) dset(2,wave.seconds)

   if (btnp(5)) results_nextgamemode=0 else results_nextgamemode=1
   new_state("newgame")
  end
 end
 results_frames+=1
end

-- [[results: draw]]
function results_draw()
 if results_frames < 81 and (#results_bonus_blocks > 0 or gamemode == 1) and results_state == "counting" then
  game_draw()
 else
  if (gamemode == 0) results_scoreatk_display()
  -- results text
  rectfill(25,10,103,16,0)
  if (results_line_x > 0) line(64-results_line_x, 16, 64+results_line_x, 16, 12)
  for c=1,8 do
   print(sub("results!",c,c),44+c*4,mid(-100,results_str_y-6-c*8,10),1)
   print(sub("results!",c,c),44+c*4,mid(-100,results_str_y-3-c*8,10),12)
   print(sub("results!",c,c),44+c*4,mid(-100,results_str_y-c*8,10),7)
  end
 end

 draw_blocks()

 if results_state == "display" then
  if 20 < results_frames and results_frames < 30 then
   cls(7)
   sfx(1)
  elseif 31 < results_frames then
   if results_score+results_bonus < 10000 then
    scale=3
   else
    scale=2
   end

   draw_results_parts()
   circfill(64,98,8,0)

   if (gamemode == 0) results_scoreatk_final() else results_timeatk_final()
   
   outline("score atk —|Ž time atk",16,113,0,1)
  end
 end
 handle_animations()
end
-->8
-- [[transition: update]]
function transition_update()
 if transition_frames < 55 then
  for d in all(transition_dots) do
   if (d.rad < 28) d.rad+=1
  end
 elseif transition_frames == 55 then
  if next_state == "newgame" then
   if (state == "results") gamemode=results_nextgamemode
   start_game()
   state="game"
  else
   state=next_state
  end
  next_state=nil
 elseif 55 < transition_frames and transition_frames < 120 then
  for d in all(transition_dots) do d.rad-=0.5 end
 else
  if (state == "title") sfx(27)
  reset_transition()
  do_transition=false
 end
 transition_frames+=1
end

-- [[transition: draw]]
function transition_draw()
 for d in all(transition_dots) do
  circfill(d.x, d.y, d.rad, transition_color)
 end
end
-->8
-- [[mainloop: update]]
function _update60()
 if do_transition then
  transition_update()
 else
  if state == "title" then
   title_update()
  elseif state == "game" then
   game_update()
  elseif state == "results" then
   results_update()
  end
  updateparticles()
 end
end

-- [[mainloop: draw]]
function _draw()
 if (state != nil) cls()
 screenshake()
 if state == "title" then
  title_draw()
 elseif state == "game" then
  game_draw()
 elseif state == "results" then
  results_draw()
 end

 if (do_transition) transition_draw()
end
__gfx__
00000000fffeeeeffffeeeefffffeeeeffffeeeeeffffeeeeffffeeeeeffffeeeeffffeeeeeffffeeeeffffeeeeeffffeeeefffffeeeeffffeeeefff00000000
00000000f00000000000000fe00000000000000fe00000000000000ee00000000000000ee00000000000000ef00000000000000ef00000000000000f00000000
00f00f00e00000000000000fe00000000000000fe00000000000000fe00000000000000ef00000000000000ef00000000000000ef00000000000000e00000000
000ff000e00000000000000fe00000000000000fe00000000000000ff00000000000000ff00000000000000ef00000000000000ef00000000000000e00000000
000ff000e00000000000000ee00000000000000ff00000000000000ff00000000000000ff00000000000000ff00000000000000ee00000000000000e00000000
00f00f00e00000000000000ef00000000000000ef00000000000000ff00000000000000ff00000000000000fe00000000000000fe00000000000000e00000000
00000000f00000000000000ef00000000000000ef00000000000000ef00000000000000fe00000000000000fe00000000000000fe00000000000000f00000000
00000000f00000000000000ef00000000000000ef00000000000000ee00000000000000ee00000000000000fe00000000000000fe00000000000000f00000000
00000000f00000000000000ff00000000000000ee00000000000000ee00000000000000ee00000000000000ee00000000000000ff00000000000000f00000000
00000000feeeeffffeeeefffeeeeffffeeeeffffeeeffffeeeeffffeeeffffeeeeffffeeeffffeeeeffffeeeffffeeeeffffeeeefffeeeeffffeeeef00000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ffeeeeffffeeeeff00aaa000008880000077700001110010000000000000000000000000000000000000000000000000000000000000000000000000
00000000f00000000000000f0a666a000822280007aca70010001010000000000000000000000000000000000000000000000000000000000000000000000000
00000000f00000000000000fa67666a0827222807a7caa7010111010000000000000000000000000000000000000000000000000000000000000000000000000
00000000e00000000000000ea66656a0822252807ccccc7010001010000000000000000000000000000000000000000000000000000000000000000000000000
00000000e00000000000000ea65556a0825552807a9c9a7001110010000000000000000000000000000000000000000000000000000000000000000000000000
00000000e00000000000000e0a666a000822280007aca70000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000e00000000000000e00aaa000008880000077700000000000000000000000000000000000000000000000000000000000600000000000000000000000
00000000f00000000000000f00000000000000000000000000000000000000000000000000000000000000006000000000000000660000000000000000000000
00000000f00000000000000f000000000ccc00c00888008002220020000000000000000060000000000000006600000000000000666000000000000000000000
00000000ffeeeeffffeeeeff00000000c000c0c08000808020002020600000000000000066000000000000006660000000000000666600000000000000000000
00000000000000000000000000000000c0ccc0c08088808020222020000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000c000c0c08000808020002020000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000ccc00c00888008002220020000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000700000000000000067700000000000006677700000000000066777700000000000067777700000000000077777700000
00000000000000000000000000000000670000000000000066770000000000006667770000000000006677770000000000006777770000000000007777770000
00000000000000006000000000000000667000000000000066677000000000000666777000000000000667777000000000000677777000000000000777777000
00000000000000006600000000000000666700000000000066667700000000000066677700000000000066777700000000000067777700000000000077777700
60000000000000006660000000000000666670000000000006666770000000000006667770000000000006677770000000000006777770000000000007777770
66000000000000006666000000000000666667000000000000666677000000000000666777000000000000667777000000000000677777000000000000777777
66600000000000006666600000000000066666700000000000066667700000000000066677700000000000066777700000000000067777700000000000077777
66660000000000006666660000000000006666670000000000006666770000000000006667770000000000006677770000000000006777770000000000007777
66666000000000000666666000000000000666667000000000000666677000000000000666777000000000000667777000000000000677770000000000000777
66666600000000000066666700000000000066666700000000000066667700000000000066677700000000000066777700000000000067770000000000000077
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000007777770000000000007777770000000000007777700000000000007770000000000000007000000000000000000700000007000000000000000000000
00000000777777000000000000777777000000000000777700000000000000770000000000000000000000000070000000700000000000000000000000000000
00000000077777700000000000077777000000000000077700000000000000070000000000000000007000000707000077077000700070000000000000000000
00000000007777770000000000007777000000000000007700000000000000000000000000000000000000000070000000700000000000000000000000000000
00000000000777770000000000000777000000000000000700000000000000000000000000000000000000000000000000700000007000000000000000000000
00000000000077770000000000000077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000007770000000000000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000ccc00000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000c0c00000000000000000000000000000000000000000000000000000000000
000003333330000000000444444000000000033333300000000003333330000000cc000000000000000000000000000000000000000000000000000000000000
00003303303300000000440440440000000033300033000000003300033300000077700000000000000000000000000000000000000000000000000000000000
00003330033300000000444004440000000033000033000000003300003300000070700000000000000000000000000000000000000000000000000000000000
00003330033300000000444004440000000033000033000000003300003300000077000000000000000000000000000000000000000000000000000000000000
00003303303300000000440440440000000033300033000000003300033300000070700000000000000000000000000000000000000000000000000000000000
00000333333000000000044444400000000003333330000000000333333000000077700000000000000000000000000000000000000000000000000000000000
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
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000210000000000000000006d6b630a5b6e6f5d00001000000021000c022d626b6e2d206d6b630a5b6e6f5d
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010800000c3551334500000133551a345000001a35521345180030c0010c0010c00224002181000a7040a7040a7040213502735021350275502155027550216502765021650277502175027731e3021250312503
010d0000113730d353013630361400703007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703
010700002d02421722217150070300703007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703
010200001801018004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400001304511044090000700015045130440200002000170551505404000000000c05517054000000000028000280003470034700347003470000003000000000000000000000000000000000000000032100
010400003474428734347242872400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400001075404742107320473200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400001a5341a5341a5341a53421534000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010700001835300573005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000c0330e0000e0331100010033000001103300000114000d30001300002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000114430d3230133300213283002b30024300283002b30024300283002b30024300283002b30024300283002b3000000000000000000000000000000000000000000000000000000000000000000000000
010400001d03418034291342430000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001f05500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000042300423004231060010600106001060010600106000c60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01040000376762467337676246733767624673306762b673306762b673306762b67330675246753067324672306752467524675186750c6740067400000000000000000000000000000000000000000000000000
011000000a1402474224732247222472221600166000d6000c6000c6000c6000c600286002660023600216001f6001e6001d6001b6001a6001960018600176001660015600146001360012600126001160035600
010e00000000002065020000206502000020650200002065000050206502005020650200502065020050206500005020650200502065020050206502005020650000502065020050206502005020650200500065
010e0000007000043300000000000560005635000000000005600002330c000021000560005635000000e00005600004330e00000000056000563500000000000560000233000000410000000056350002000000
010e0000007000560000000000000560005600021000410000100056000c000021500560005600000000e00005600056000e00000000056000560000000000000560005600000000415000000056000000000000
010e0000007000560000000000000210002100041000410000100056000c000021500015100150000000e000056000e0000000005600056000020000000056000560000000021000215009151091510215000154
010e00000070005600000000e0530210002100041000410000100056000c000021500015100150000000e000056000e000000000c053001510c05300000056000560000000021000215009151091510215000154
010e000005455054553f52511435111250f4350c43511125034550345511125182551b255182551d2551112501455014552025511125111252025511125202550345520255224552325522455202461d4551b255
010e00000c0530c4451112518455306251425511255054450c0530a4353f52513435306251343518435054450c053111251b4353f525306251b4353f5251b4350c0331b4451d2451e445306251d2451844516245
010e00000145520255224552325522445202551d45503455034050345503455182551b455182551d455111250045520255224552325522455202461d4551b255014550145511125182551b455182551d45511125
010e00000c0531b4451d2451e445306251d245184450c05317200131253f52513435306251343518435014450c0431b4451d2451e445306251d245184451624511125111253f5251343530625134351843500455
010e0000004550045520455111251d125204551d1252912501455014552c455111251d1252c4551d12529125034552c2552e4552f2552e4552c2552945503455044552c2552e4552f2552e4552c246294551b221
010e00000c0530c0531b4551b225306251b4551b2250f4250c0530c05327455272253062527455272251b4250c0531b4451d2451e445306251d245184450c0530c0531b4451d2451e445306251d2451844500455
014b00000c15418151181500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
016400000017400170001750000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
01 10 42 43 44
00 10 42 43 44
00 10 11 12 44
00 10 11 12 44
00 10 42 12 44
00 10 12 43 44
00 10 13 43 44
00 10 13 43 44
01 10 13 11 44
00 10 11 13 44
00 10 11 13 44
00 10 11 13 14
02 10 11 13 14
01 15 16 43 44
00 15 16 43 44
00 15 16 43 44
00 15 16 43 44
00 17 18 43 44
00 17 18 43 44
02 19 1a 43 44
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
