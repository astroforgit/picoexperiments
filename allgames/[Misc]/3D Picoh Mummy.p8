pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- 3d picoh mummy
-- road software 2018
-- build 27, mmamjam release, 15/10/18

function startup()
  -- adam hack these is you need to test game over, level skip easier etc
  start_lives=5
  allow_cheat=false
  -- and jury out on this (set on to allow down arrow to move backwards)
  allow_reverse=true

  -- start at the splash screen
  dpage=0
end



function splash_draw()
  cls(0)

  local x=16
  local y=24
  sspr(79,24,24,35, x,y,24,35)
  sspr(104,24,24,35, x+24,y,24,35)
  sspr(81,59,24,35, x+48,y,24,35)
  sspr(106,59,24,35, x+72,y,24,35)

  ctxt("proudly presents",76,6)
  ctxt("for #mmamjam",84,8)
  ctxt("3d picoh mummy",92,10)
  ctxt("road software 2018",108,5)
  
  press_x()
end



function intro_draw()
  cls(0)
  title("3d picoh mummy",15)

  local bs=10
  local be=85
  draw_side_2(be+7,70,true)
  bctxt("plunder the tombs of",26,10,bs,be)
  bctxt("the great egyptian",32,10,bs,be)
  bctxt("royal families...",38,10,bs,be)

  bctxt("but be mindful of",58,10,bs,be)
  bctxt("the inhabitants...",64,10,bs,be)

  ctxt("use the cursors to explore,",88,9)
  ctxt("and — to look behind/around",94,9)
  print("Ž ",43,104,9)
  if game_music then
    print(" off",60,104,9)
  else
    print(" on",60,104,9)
  end
  press_x()
end


function start_game_draw()
  cls(0)
  ptitle()
  ctxt("the entrance to tomb "..p.level,22,9)

  local xpos=12
  print("score              : "..padl(tostr(p.score),5,"0"),xpos,32,10)
  print("tombs raided       : "..padl(tostr(p.tombs),5),xpos,48,6)
  spr(13,1,59)
  print("mummies vanquished : "..padl(tostr(p.mmycount),5),xpos,60,6)
  spr(14,1,69)
  print("explorers consumed : "..padl(tostr(p.lostcount),5),xpos,70,6)
  spr(15,1,79)
  print("treasures found    : "..padl(tostr(p.tcount),5),xpos,80,6)

  ctxt("ready to explore...",95,9)
  press_x()
end


function level_completed_draw()
  cls(0)
  -- level already incremented....
  ptitle()
  ctxt("you completed tomb "..p.level-1,22,9)
  ctxt("...but the next tomb awaits",40,9)

  -- mums already has an extra mummy in for the next tomb, hence confusing count
  local status="all is quiet..."
  if #mums==2 then
    status="an angry mummy follows..."
  elseif #mums>2 then
    status="and "..(#mums-1).." mummies follow..."
  end
  ctxt(status,80,5)

  press_x()
end


function highscore_draw()
  cls()
  title("3d picoh mummy",15)

  ctxt("all-time best",22,9)
  
  print("score",20,32,5)
  print("tombs",48,32,5)
  print("explorer",76,32,5)
  local yline=46
  for x=1,5 do
    score=high[x]
    print(padl(tostr(x),2),5,yline,5)
    print(padl(tostr(score.score),5,"0"),20,yline,6)
    print(score.tombs,56,yline,6)
    print(score.name,76,yline,6)
    yline=yline+10
  end
  press_x()
end



function pyr_completed_draw()
  cls(0)
  ptitle()
  ctxt("looted of all it's treasures",22,9)

 -- extra lives message etc in time  
  ctxt("but, there are many, many more",60,5)
  ctxt("pyramids to loot in egypt...",66,5)

  ctxt(pup_msg1,90,9)
  ctxt(pup_msg2,96,9)
  press_x()
end


function game_over_draw()
  cls(0)
  ptitle()
  ctxt("your whole team has been lost...",22,9)

  local xpos=12
  print("score              : "..padl(tostr(p.score),5,"0"),xpos,32,10)

  print("pyramids visited   : "..padl(tostr(p.pcount),5),xpos,42,6)
  print("tombs raided       : "..padl(tostr(p.tombs),5),xpos,48,6)
  print("steps taken        : "..padl(tostr(p.steps),5),xpos,54,6)
  print("mummies vanquished : "..padl(tostr(p.mmycount),5),xpos,60,6)
  print("explorers consumed : "..padl(tostr(p.lostcount),5),xpos,66,6)
  print("scrolls abandoned  : "..padl(tostr(p.scount),5),xpos,72,6)
  print("treasures found    : "..padl(tostr(p.tcount),5),xpos,78,6)

  if hs.active then
    ctxt("...but you made the record books",90,9)
    local ofs=45 - 5
    for n=1,8 do
      if n==hs.pos then 
        print(get_hsprv(-1), ofs+(5*n), 98, 2)
        print(get_hsprv(1), ofs+(5*n), 108, 2)
        print(hs.name[n], ofs+(5*n), 103, 10)
      else
        print(hs.name[n], ofs+(5*n), 103, 9)
      end
    end
    --print("^", ofs+(5*hs.pos), 108, 10)
    ctxt("press — to submit score", 120, 15) -- extra space to overcome width of special 'x' char
  else
    ctxt("game over",98, 9)
    press_x()
  end
end


function draw_map()
  local col=0
  for x=1,13 do
    for y=2,12 do
      if (x==p.xp) and (y==p.yp) then
        col=7
      else
        col=getmapclr(gmap[y][x])
      end
      if (p.fd==1) then -- up
        pset(110-p.xp+x, 10-p.yp+y, col)
      elseif (p.fd==3) then -- down
        pset(110+p.xp-x, 10+p.yp-y, col)
      elseif (p.fd==2) then -- right
        pset(110-p.yp+y, 10+p.xp-x, col)
      else -- left
        pset(110+p.yp-y, 10-p.xp+x, col)
      end      
    end
  end      
  local ch="n"
  if (p.fd==2) ch="e"
  if (p.fd==3) ch="s"
  if (p.fd==4) ch="w"
  if debug then
    print(p.facedir,123,2,1)
  else
    print(ch,123,2,1)
  end
end


function draw_dashboard()
  rectfill(4,2,96,19,1)
  print("score:",6,4,15)
  print(padl(tostr(p.score),5,"0"),30,4,12)
  
  if p.immortal then
    print("!",52,4,12)
  end
  for i=1,p.lives do -- lives
    sspr(man.x, man.y,
      man.width, man.height,
      5+((i-1)*(man.width+1)), 11, 
      man.width, man.height)
  end

  local mcount=0
  if debug then
    for i=1,#mums do -- mummies in play
      if not mums[i].dead then
        mcount+=1
        print(mums[i].dir,88-((mcount-1)*(mummy.width+1)),11,0)
      end
    end
  else
    for i=1,#mums do -- mummies in play
      if (not mums[i].dead) mcount+=1
    end
    -- simple count or draw mummies?
    if mcount>5 then
      rectfill(57,10,94,18,7)
      print("oh mummy!",59,12,0)
    else
      mcount=0
      for i=1,#mums do -- mummies in play
        if (not mums[i].dead) then 
          mcount+=1
          if (mums[i].type==2) then
            pal(10,12,0)
            pal(9,7,0)
          end
          sspr(mummy.x, mummy.y, mummy.width, mummy.height,
            88-((mcount-1)*(mummy.width+1)),11, mummy.width, mummy.height)
          pal()
        end
      end
    end
  end
  
  if p.key then 
    sspr(key.x, key.y,
      key.width, key.height,
      68, 3, key.width, key.height) -- key
  end
  if p.scroll then 
    sspr(scroll.x, scroll.y,
      scroll.width, scroll.height,
      78, 3, scroll.width, scroll.height) -- scroll
  end
  if p.royal then 
    sspr(royal.x, royal.y,
      royal.width, royal.height,
      88, 3, royal.width, royal.height) -- royal
  end
end


function _draw()
  if dpage==0 then
    splash_draw()
  elseif dpage==1 then
    intro_draw()
  elseif dpage==2 then
    start_game_draw()
  elseif dpage==3 then
    game_draw()
  elseif dpage==4 then
    level_completed_draw()
  elseif dpage==5 then
    pyr_completed_draw()
  elseif dpage==6 then
    game_over_draw()
  elseif dpage==7 then
    highscore_draw()
  end
end


function _update()
  if playing_reveal then
    reveal_timer-=1
    if reveal_timer<1 then
      playing_reveal=false
      sfx(-2,3)
    end
  end

  if dpage==3 then
    game_update()
  elseif dpage==6 then
    game_over_update()
  else
    static_update()
  end
end


function static_update()
  -- special case for screen 1/7 (flip between welcome and high scores)
  static+=1
  if (static>350) then 
    static=0
    if (dpage==1) then 
      dpage=7
      return
    elseif dpage==7 then 
      dpage=1
      return
    end
  end

  if btnp(4,0) and dpage==1 then
    game_music=not game_music
    save_highs()
    if game_music then 
      play_last_music()
    else
      music(-1,400) -- don't call music off as it will break 'last music'
    end
  end

  if btnp(5,0) then
    while (btn(5,0)) do
    end
    next_states()
  end
end


function next_states()
  static=0

  if (dpage==0) then -- splash to welcome
    music_on(mus_intro)
    dpage=1
    return
  end

  -- starting the overall game
  if dpage==1 then
    music_off()
    init_game()
    dpage=2
    return
  end

  if dpage==2 then
    music_off()
    dpage=3
    return
  end

-- 3 = handled in _update

  -- going from level completed to next level
  if dpage==4 then
    music_off()
    dpage=3
    return
  end

  -- going from pyramid-completed to new pyramid
  if dpage==5 then
    music_off()
    p.pcount=safe_inc(p.pcount)
    if (p.pcount>#pyr) p.pcount=1 -- safety on the off chance
    p.level=1
    mums={}
    init_level()
    dpage=2    
    return
  end

-- 6 = handled in _update

  if dpage==7 then
    dpage=1
    return
  end
end  


function set_hspos(inc)
  hs.pos=hs.pos+inc
  for i=1,#hs.chars do
    if (hs.chars[i]==hs.name[hs.pos]) hs.chr=i
  end
end

function get_hsprv(i)
  local c=hs.chr+i
  if c<1 then 
    return hs.chars[#hs.chars]
  elseif c>#hs.chars then
    return hs.chars[1]
  else
    return hs.chars[c]
  end
end

function set_hschr(inc)
  hs.chr=hs.chr+inc
  if hs.chr<1 then hs.chr=#hs.chars
  elseif hs.chr>#hs.chars then hs.chr=1
  end
  hs.name[hs.pos]=hs.chars[hs.chr]
end



function game_over_update()
  if hs.active then
    if btnp(0,0) and (hs.pos>1) then set_hspos(-1)
    elseif btnp(1,0) and (hs.pos<8) then set_hspos(1)
    elseif btnp(2,0) then set_hschr(1)
    elseif btnp(3,0) then set_hschr(-1)
    elseif btnp(5,0) then
      while (btn(5,0)) do
      end
      hs.active=false
      p.name=""
      for i=1,8 do
        p.name=p.name..hs.name[i]
      end
      input_hiscore()
    end
  else
    if btnp(5,0) then
      while (btn(5,0)) do
      end
      dpage=7
      music_off()
      music_on(mus_intro)
    end
  end
end



function reset_hs()
  hs={}
  hs.chars={"."," ","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r",
           "s","t","u","v","w","x","y","z","0","1","2","3","4","5","6","7","8","9",
           "!","&","+","=","-","*"}
  hs.name={" "," "," "," "," "," "," "," "}
  for i=1,8 do
    if i<=#p.name then
      hs.name[i]=sub(p.name,i,i)
    else
      hs.name[i]=" "
    end
  end
  hs.active=false
  hs.pos=1
  hs.chr=3
  set_hspos(0)
end



function game_draw()
  pal()
  cls(0)

  -- fix the view area
  clip(view.lx,view.sy,view.rx,view.ey)
  -- move the camera, if we need to
  if shake>0 then
    local jx=shake
    local jy=shake
    if (rnd(1)<0.5) jx=jx*-1
    if (rnd(1)<0.5) jy=jy*-1
    if (shake>1) or (rnd(1)>0.35) then 
        camera(jx, jy)
    end
  end

  -- draw the horizon, colour the floor and sky (not really used at the moment)
  rectfill(view.lx,view.sy,view.rx,63,col_sky)
  rectfill(view.lx,64,view.rx,view.ey,col_floor_clear)
  line(view.lx,64,view.rx,64,col_edge)
  line(view.lx,65,view.rx,65,col_edge)

  -- now we loop through our arrays, telling us what is in front of us;

  -- depth starts at 6, effectively away on the horizon
  for z=zdepth,1,-1 do
    local tp=z+1 -- we draw the cells 'in front' of us rather than starting 'with' us
    -- grab the h array (helpers) for this position - we need both cells to get all vertices we need
    local g1=h[z]
    local g2=h[z+1]

    -- left hand side
    local tile=gettile(lscr[tp])
    local clr=getclr(tile)
    -- floor
    fillp(texture_floor)
    rectfill(view.lx, g1.by, g1.lx, g2.by, clr)
    for x=g1.lx, g2.lx do
      line(g1.lx, g1.by, x, g2.by, clr)
    end
    -- facing walls
    if (tile<1) or (tile>2) then
      if tile!=0 then
        fillp(texture_face_side)
      else
        fillp()
      end
      rectfill(view.lx, g1.ty, g1.lx, g1.by, clr)
    end
    -- slopes
    if (tile<1) or (tile>2) then
      fillp(texture_side)
      rectfill(g1.lx, g2.by, g2.lx, g2.ty, clr) -- middle rect
      for x=g1.lx, g2.lx do
        line(g1.lx, g1.by, x, g2.by, clr) -- top triangle
        line(g1.lx, g1.ty, x, g2.ty, clr) -- bottom triangle
      end
    end

    -- right hand side
    tile=gettile(rscr[tp])
    clr=getclr(tile)
    -- floor
    fillp(texture_floor)
    rectfill(view.rx, g1.by, g1.rx, g2.by, clr)
    for x=g1.rx, g2.rx, -1 do
      line(g1.rx, g1.by, x, g2.by, clr)
    end
    -- facing walls
    if (tile<1) or (tile>2) then
      if tile!=0 then
        fillp(texture_face_side)
      else
        fillp()
      end
      rectfill(view.rx, g1.ty, g1.rx, g1.by, clr)
    end
    -- slopes
    if (tile<1) or (tile>2) then
      fillp(texture_side)
      rectfill(g1.rx, g2.by, g2.rx, g2.ty, clr)
      for x=g1.rx, g2.rx, -1 do
        line(g1.rx, g1.by, x, g2.by, clr)
        line(g1.rx, g1.ty, x, g2.ty, clr)
      end
      fillp()
    end

    -- central cells
    tile=gettile(mscr[tp])
    clr=getclr(tile)
    fillp(texture_floor)
    -- floor
    rectfill(g2.lx, g1.by, g2.rx, g2.by, clr)
    for y=g2.by, g1.by do
      line(g1.lx, g1.by, g2.lx, y, clr)
      line(g1.rx, g1.by, g2.rx, y, clr)
    end
    -- facing walls
    if (tile<1) or (tile>2) then
      fillp(texture_face_on)
      rectfill(g1.lx, g1.ty, g1.rx, g1.by, clr)
    end

    fillp()

    -- now need to draw characters, if required!
    -- presently not drawing off to the left or right - to come back and do??
    --[[
    sprite=getsprite(lscr[tp])
    sprite=getsprite(rscr[tp])
    ]]

    
    local type=getsprite(mscr[tp])
    if (type!=0) then
      if (type==2) then
        pal(10,12,0)
        pal(9,7,0)
      end
      -- which way is the mummy facing?
      local dr=decode_dir(mscr[tp])
      local face_on=(abs(dr - p.facedir) == 2)
      local face_same=(dr==p.facedir)
      local face_side=not (face_same or face_on)
        
      if (face_side==false) and (z<7) then
        sspr(
          txt[z].x, txt[z].y, 
          txt[z].width, txt[z].height,
          g1.lx+txt[z].xoff,
          g1.by-txt[z].yoff-txt[z].height,
          txt[z].width, txt[z].height, not face_on)

        if (txt[z].patch==true) and (not face_on) then
          sspr(
            txt[z].patchx, txt[z].patchy,
            txt[z].patchwidth, txt[z].patchheight,
            g1.lx+txt[z].xoff+txt[z].pxoff,
            (g1.by-txt[z].yoff-txt[z].height)+txt[z].pyoff,
            txt[z].patchwidth, txt[z].patchheight, not face_on)
        end    
      elseif (face_side==true and z<7) then
        -- which way is the mummy facing, compared to us?
        local left = 
          (p.facedir==3 and dr==2) or
          (p.facedir==1 and dr==4) or
          (p.facedir==2 and dr==1) or
          (p.facedir==4 and dr==3)
        -- we draw left as flipped and right as normal
        if z==1 then
          draw_side_1(g1.lx+txt[z].xoff, g1.by-txt[z].yoff, left)
        elseif z==2 then
          draw_side_2(g1.lx+txt[z].xoff, g1.by-txt[z].yoff, left)
        elseif z==3 then
          draw_side_3(g1.lx+txt[z].xoff, g1.by-txt[z].yoff, left)
        elseif z==4 then
          draw_side_4(g1.lx+txt[z].xoff, g1.by-txt[z].yoff, left)
        elseif z==5 then
          draw_side_5(g1.lx+txt[z].xoff, g1.by-txt[z].yoff, left)
        elseif z==6 then
          rectfill(g1.lx+txt[z].xoff, g1.by-txt[z].yoff-txt[z].height, 
            g1.lx+txt[z].xoff+txt[z].width, g1.by-txt[z].yoff, 10)      
        end
      end
      pal()
    end
  end

  camera(0,0)
  clip()

  -- clean up from any camera shake
  rectfill(0,0,127,20, col_border)
  rectfill(0,20,3,127,col_border)
  rectfill(124,20,127,127,col_border)
  rectfill(0,126,127,127,col_border)

  draw_dashboard()
  draw_map()

  -- show fram rate, longer across screen, more work being done
  line(1,127,126*stat(1),127,0)

  if p.fading then
    if frame%3==0 then
      p.fade_loop+=1
    end

    for i=16,1,-1 do
      if i-p.fade_loop>0 then
        pal(pal_to_black[i],pal_to_black[i-p.fade_loop],1)
      else
        pal(pal_to_black[i],0,1)
      end
    end
  end

end



function game_update()
  frame+=1
  if (frame>=10) frame=0

  if p.dying then
    p.dying_timer+=1
    shake=1+(p.dying_timer%4)
    if p.dying_timer<100 then
      if p.dying_timer % 10 == 1 then
        play_sfx(sfx_scream)
      end
    else
      sfx(-1) -- stop sound?
      shake=0
      
      p.lives-=1
      if p.lives>0 then
        p.xp=startx
        p.yp=starty
        p.fd=3
        p.facedir=3
        p.dying=false
        p.dying_timer=0
        return
      end

      p.fading=true
      p.fade_loop=0
      p.dying=false
      p.dying_timer=0
    end
    return
  end

  if p.fading then 
    if p.fade_loop>15 then
      p.fading=false
      p.dying=false
      p.dying_timer=0
      game_over()
    end
    return
  end

  move_player()
  move_mums()
  calc_shake()

  -- leave footsteps
  local m=gmap[p.yp][p.xp]
  m=band(m,0b11111100) -- clear last 2 bits
  gmap[p.yp][p.xp] = m + 2

  -- load ready for the next draw
  get_scr()
end


function calc_shake()
  if (shake>0) shake-=1

  -- trying to calculate crow-flies distance to the mummy
  for i=1,#mums do
    if mums[i].dead==false and mums[i].frames==0 and mums[i].speed>0 then
      if (mums[i].dist>=0) then
        shake=max(1+shake_limit-mums[i].dist,shake)
      end
    end
  end
  -- now set the global shake value
  shake=min(shake, shake_limit)
end


function test_move(mmy)
  local nx=mmy.x
  local ny=mmy.y
  if (mmy.dir==1) ny-=1
  if (mmy.dir==2) nx+=1
  if (mmy.dir==3) ny+=1
  if (mmy.dir==4) nx-=1

  -- if bad position, change direction
  if (nx==startx and ny==starty) or nx<1 or nx>12 or ny<1 or ny>11 then
    return false
  else
    local t=band(gmap[ny][nx],0b00001111)
    if t<1 or t>2 then
    return false
    end
  end
  return true
end


function make_move(mmy)
  local nx=mmy.x
  local ny=mmy.y
  if (mmy.dir==1) ny-=1
  if (mmy.dir==2) nx+=1
  if (mmy.dir==3) ny+=1
  if (mmy.dir==4) nx-=1
  
  mmy.x=nx
  mmy.y=ny
end


function move_mums()
  for i=1,#mums do
    if not mums[i].dead then
    
    mums[i].frames+=mums[i].speed
    if mums[i].frames>=mums[i].max then
      -- reset counter
      mums[i].frames=0

      -- remove from the map
      remove_mummy(mums[i])
      local dir_save=mums[i].dir

      if mums[i].type!=2 then
        if not test_move(mums[i]) then
          change_dir(mums[i])
        end
      else
      -- this is where to add the 'be clever' movement stuff
        local old=mums[i].dir
        -- if player visible to mummy (line of sight, not behind or occluded etc) then change dir
        smart_mmy_move(mums[i])
        if not test_move(mums[i]) and (old==mums[i].dir) then -- we needed to change but didn't see the player
          change_dir(mums[i]) -- standard random change
        end   
      end

      -- don't make a physical move if we're just turning around, this gives us gameplay element of
      -- mummy slowing turning
      if dir_save==mums[i].dir and test_move(mums[i]) then 
        make_move(mums[i])
      end

      -- put back on map
      add_mummy(mums[i])
    end

    -- update distance to player - this can change even if mummy didn't move!
    local diffx=abs(mums[i].x - p.xp)
    local diffy=abs(mums[i].y - p.yp)
    local dist=(diffx ^ 2) + (diffy ^ 2)
    mums[i].dist=flr(sqrt(dist)+0.5)

    -- and move if the mummy moved, and is near enough, play footsteps
    if mums[i].frames==0 and mums[i].dist<7 and mums[i].dist>0 and mums[i].speed>0 then
      -- we use distance to choose the sound (sets volume)
      play_sfx(mums[i].dist)
    end

    if mums[i].dist==0 and p.immortal==false then
      if p.scroll then
        p.mmycount=safe_inc(p.mmycount)
        p.scroll=false
        play_sfx(sfx_usescroll)
        mums[i].speed=0
        mums[i].dead=true
        remove_mummy(mums[i])
      else
        p.lostcount=safe_inc(p.lostcount)
        mums[i].speed=0
        mums[i].dead=true
        remove_mummy(mums[i])
        p.dying_timer=0
        p.fade_loop=0
        p.fading=false
        p.dying=true
      end
    end
  end
  end
end



function can_look(mmy, dirt)
  local nx=mmy.x
  local ny=mmy.y
  if (dirt==1) ny-=1
  if (dirt==2) nx+=1
  if (dirt==3) ny+=1
  if (dirt==4) nx-=1
  
  if ((nx==startx) and (ny==starty)) or nx<1 or nx>12 or ny<1 or ny>11 then
   return false
  end

  -- can we 'see' in this direction?
  local t=band(gmap[ny][nx],0b00001111)
  -- not if it's an impass tile or the 'doorway'
  return (t==1 or t==2)
end



function smart_mmy_move(mmy)

  -- we don't see the player if he's at the start position
  if xp==startx and yp==starty then
    return
  end

  -- or simply too far away
  if (mmy.dist>6) return

  local did_see=false

  -- what are our surroundings?
  local chkup=can_look(mmy, 1)
  local chklt=can_look(mmy, 2)
  local chkdn=can_look(mmy, 3)
  local chkrt=can_look(mmy, 4)

  -- take away any 'behind'
  if (mmy.dir==1) chkdn=false
  if (mmy.dir==2) chkrt=false
  if (mmy.dir==3) chkup=false
  if (mmy.dir==4) chklt=false

  if (chkup and (mmy.x==p.xp) and (mmy.y>=p.yp)) then mmy.dir=1 did_see=true end
  if (chklt and (mmy.y==p.yp) and (mmy.x<=p.xp)) then mmy.dir=2 did_see=true end
  if (chkdn and (mmy.x==p.xp) and (mmy.y<=p.yp)) then mmy.dir=3 did_see=true end
  if (chkrt and (mmy.y==p.yp) and (mmy.x>=p.xp)) then mmy.dir=4 did_see=true end

  if did_see then
    play_sfx(sfx_guard)
  end
end


function change_dir(mmy)
  -- simple flip or actual change?
  --if rnd(1)<0.3 then
    if rnd(1)<0.5 then
      mmy.dir+=1
    else
      mmy.dir-=1
    end
    if (mmy.dir>4) mmy.dir=1
    if (mmy.dir<1) mmy.dir=4
--[[  else 
    -- temp simple flip cheat
    mmy.dir=mmy.dir+2
    if (mmy.dir==5) mmy.dir=1
    if (mmy.dir==6) mmy.dir=2
  --[[end]]
  mmy.change=false
end




-- inc a variable without overflowing
function safe_inc(value,amount)
  local a=amount or 1
  if value < (32767-a) then
    return value+a
  else
    return value
  end
end


function remove_mummy(mum)
  local t = gmap[mum.y][mum.x]
  -- remove mummy and direction
  t = band(t, 0b00001111)
  gmap[mum.y][mum.x]=t
end


function add_mummy(mum)
  local t = gmap[mum.y][mum.x]
  -- remove any stray info
  t = band(t, 0b00001111)
  -- add in direction and mummy flag
  t = encode_dir(mum.dir) + t
  -- now the sprite type 1..3
  if (mum.type==1) then t=t+16
  elseif (mum.type==2) then t=t+32
  elseif (mum.type==3) then t=t+48
  end
  gmap[mum.y][mum.x]=t
end


function encode_dir(dir)
  if dir==1 then return 0
  elseif dir==2 then return 64
  elseif dir==3 then return 128
  else return 192
  end
end


function decode_dir(tile)
  local t=band(tile,0b11000000)
  if t==0 then return 1
  elseif t==64 then return 2
  elseif t==128 then return 3
  else 
    return 4  
  end
end





function move_player()
  local glance=btn(5,0)
  p.facedir=p.fd
  local got=false

  -- test glance first
  if btn(1,0) and btn(5,0) then
      p.facedir+=1
      if (p.facedir>4) p.facedir=1
      got=true
  elseif btn(0,0) and btn(5,0) then
      p.facedir-=1
      if (p.facedir<1) p.facedir=4
      got=true
  else
    if (btnp(1,0)) p.fd+=1 
    if (btnp(0,0)) p.fd-=1 
    if (p.fd>4) p.fd=1
    if (p.fd<1) p.fd=4
  end

  local ox=p.xp
  local oy=p.yp

  if btnp(2,0) then
    if (p.fd==1) p.yp-=1
    if (p.fd==2) p.xp+=1
    if (p.fd==3) p.yp+=1
    if (p.fd==4) p.xp-=1
    if p.xp<1 or p.xp>12 or p.yp<1 or p.yp>11 or gmap[p.yp][p.xp]<1 or gmap[p.yp][p.xp]>2 then
      p.xp=ox
      p.yp=oy
    end
  end

  if btnp(3,0) and allow_reverse then
    if (p.fd==1) p.yp+=1
    if (p.fd==2) p.xp-=1
    if (p.fd==3) p.yp-=1
    if (p.fd==4) p.xp+=1
    if p.xp<1 or p.xp>12 or p.yp<1 or p.yp>11 or gmap[p.yp][p.xp]<1 or gmap[p.yp][p.xp]>2 then
      p.xp=ox
      p.yp=oy
    end
  end

  if btn(5,0) and not got then
    p.facedir=(2+p.fd)%4
    if (p.facedir==0) p.facedir=4
  end

  if btnp(4,0) and allow_cheat then
    p.key=true
    p.scroll=true
    p.royal=true
  end

  if (p.xp!=ox) or (p.yp!=oy) then 
    p.steps=safe_inc(p.steps)
    complete_step_and_check()
  end

  if p.xp==startx and p.yp==starty then
    if p.key and p.royal then
      handle_completed()
    end
  end
end



function handle_completed()
  -- clean up removed mummies
  for mmy in all(mums) do
    if (mmy.dead==true) then 
      del(mums,mmy)
    end
  end
  if (p.scroll==true) p.scount=safe_inc(p.scount)
  p.tombs=safe_inc(p.tombs)
  p.level+=1

  if p.level>5 then
    if p.lives<5 then
      p.lives+=1
      pup_msg1="these legendary exploits bring"
      pup_msg2="another explorer to your team"
    else
      p.score=p.score+125
      pup_msg1="as a reward for your endeavours,"
      pup_msg2="you receive a black-market bonus"
    end
    music_on(mus_intro)
    dpage=5
    return
  else
    dpage=4
    init_level()
    music_mums()
    return
  end
end


function complete_step_and_check()
  -- we've just completed a move
  p.steps=safe_inc(p.steps)
  -- check to see if we just boxed-off a chest...
  -- cheating, using fact that chests are in x>=3, x<=11 and y>=4, y<=10
  local tile=0
  local intile=0
  for x=3,11 do
    for y=4,10 do
      tile=band(gmap[y][x],0b00001111)
      -- unopened chest?
      if tile>2 and tile!=map_opened then
        -- so, are the 8 spaces around it travd?      
        local cleared=true
        for p= x-1, x+1 do
          for q= y-1, y+1 do
            -- only examine bit 2 (maps to 2 in the tile)
            intile=band(gmap[q][p],0b00000010)
            -- don't check the centre
            if (p!=x) or (q!=y) then
              cleared=cleared and (intile==map_trav)
            end
          end
        end
        if cleared then
          opened_chest(x,y)
        end
      end
    end
  end
end


-- we have just opened this chest
function opened_chest(x,y)
  local tile=band(gmap[y][x],0b00001111)
  gmap[y][x]=map_opened
  play_sfx(sfx_reveal)

  if tile==map_key then
    p.key=true
    play_sfx(sfx_key)
  elseif tile==map_scrl then
    p.scroll=true
    play_sfx(sfx_scroll)
    --p.scount=safe_inc(p.scount)
  elseif tile==map_royal then
    p.royal=true
    p.score = safe_inc(p.score,50)
    play_sfx(sfx_royal)
  elseif tile==map_guard then
    spawn_guard(x,y)
    play_sfx(sfx_guard)
  elseif tile==map_trsr then
    p.score = safe_inc(p.score,5)
    p.tcount=safe_inc(p.tcount)
    play_sfx(sfx_treasure)
  else
    -- empty chest
    play_sfx(sfx_nothing)
  end
end

function play_last_music()
  if (game_music and last_music!=0) music(last_music)
end

function music_on(track)
  -- game_music only affects opening tune
  if ((dpage>1) and (dpage<7)) or track!=mus_intro then
    music(track) 
  elseif (game_music) then music(mus_intro)
  end

  last_music=track
end


function music_off()
  last_music=0
  music(-1,750)
  playing_reveal=false
  sfx(-1)
end


function music_mums()
  music_off()
  local c=max(#mums,0)
  c=min(c,5)
  play_sfx(c+22,3)
end


function play_sfx(sound)
  if sound==sfx_reveal then
    reveal_timer=reveal_delay -- true even if one already playing
    if not playing_reveal then
      playing_reveal=true
      sfx(sfx_reveal,3)
    end
  else
    sfx(sound)
  end
end


function gettile(tile)
  return band(tile, 0b00001111)
end


-- returns 0 or the sprite id
function getsprite(tile)
  local t=band(tile, 0b00110000)
  if t>=16 then return t%15
  else return 0
  end
end


function game_over()
  pal() -- just in case
  music_off()
  if p.score>high[5].score then
    reset_hs()
    hs.active=true
  end
  music_on(mus_funeral)
  dpage=6
end




function init_level()
 dying=false
 fading=false
 fade_loop=0
 dying_timer=0
 shake=0
 playing_reveal=false

 p.xp=startx
 p.yp=starty
 p.fd=3 -- 1n, 2e, 3s, 4w
 p.facedir=p.fd
 p.key=false
 p.scroll=false
 p.royal=false

 frame=0
 
 -- reset the map
 init_map()
 -- existing mummies into the map
 for mmy in all(mums) do
   add_mummy(mmy)
 end
 -- add another, if it's not silly
 if (#mums<12) spawn_mummy()
end



function init_map()
 gmap={
  {0,0,0,0,0,0,0,0,0,0,0,0,0},
  {0,0,0,0,0,1,0,0,0,0,0,0,0},
  {0,1,1,1,1,1,1,1,1,1,1,1,0},
  {0,1,3,1,3,1,3,1,3,1,3,1,0},
  {0,1,1,1,1,1,1,1,1,1,1,1,0},
  {0,1,3,1,3,1,3,1,3,1,3,1,0},
  {0,1,1,1,1,1,1,1,1,1,1,1,0},
  {0,1,3,1,3,1,3,1,3,1,3,1,0},
  {0,1,1,1,1,1,1,1,1,1,1,1,0},
  {0,1,3,1,3,1,3,1,3,1,3,1,0},
  {0,1,1,1,1,1,1,1,1,1,1,1,0},
  {0,0,0,0,0,0,0,0,0,0,0,0,0}
    }
 
  -- now set the goodies
  set_chest(map_guard)
  set_chest(map_key)
  set_chest(map_royal)
  set_chest(map_scrl)
  for x=1,10 do
    set_chest(map_trsr)
  end
end         


function set_chest(tile)
  local done=false
  local x=0
  local y=0
  while (done==false) do
    x=1+ flr(rnd(13))
    y=1+ flr(rnd(12))
    -- only place if this is a chest tile
    if gmap[y][x]==map_chest then
      gmap[y][x]=tile
      done=true
    end
  end
end         



function init_game()
 debug=false
 p.immortal=false
 p.lives=start_lives
 p.tcount=0
 p.scount=0
 p.score=0
 p.steps=0
 p.fade_loop=0
 p.fading=false
 p.dying=false
 p.dying_timer=0
 p.lostcount=0
 p.mmycount=0
 p.level=1
 p.pcount=1
 p.tombs=0

 mums={}
 
 init_level()
end


function debug_mummy(x,y,dirt)
 local m={}
 m.max=mum_timer+flr(rnd(5))
 m.frames=m.max
 m.dist=100
 m.x=x
 m.y=y
 m.dir=dirt
 m.speed=1
 m.type=1
 m.dead=false
 add(mums, m)
 add_mummy(m)
end

function spawn_mummy()
 local m={}
 m.max=mum_timer+flr(rnd(5))
 m.frames=m.max
 m.dist=100
 repeat
   -- using knowledge of grid to reduce range here, and avoid starting cell
    m.x=2+flr(rnd(11))
    m.y=3+flr(rnd(9))
 -- can't be on a chest tile, can't be in start location
 until (not (m.x==startx and m.y==starty)) and ((gmap[m.y][m.x]==1) or (gmap[m.y][m.x]==2))
 m.dir=1+flr(rnd(4))
 m.speed=1
 m.type=1
 m.dead=false
 add(mums, m)
 add_mummy(m)
end  

function spawn_guard(x,y)
 local m={}
 m.max=mum_timer+flr(rnd(10))
 m.frames=m.max
 m.dist=100
 m.x=x
 m.y=y
 m.dir=1+flr(rnd(4))
 m.speed=1
 m.type=2
 m.dead=false
 add(mums, m)
 add_mummy(m)
end  

function create_depth(y,scale,lx,rx,ty,by)
 local d={}
 d.y=y
 d.scale=scale
 d.lx=lx
 d.rx=rx
 d.ty=ty
 d.by=by
 add(h,d)
end


function _init()
 cartdata("road_software_3dpicoh_mummy_internalv01")
 menuitem(4,"reset high scores",function() clear_highs() end)
 store_flag=40  -- increement/change this to cause it to not see saved data
 p={}
 p.name="player-1"
 game_music=true
 mus_intro=7
 mus_funeral=6

 -- not used, but saved to cart data for future
  game_speed=2
  game_diff=2
  game_sound=true
 --
 
 create_ascii()
 load_highs()
 setup_pyrs()
 reset_hs()
 reveal_timer=0
 reveal_delay=80
 next_sfx=0
 playing_reveal=false
 last_music=0

 startx=6
 starty=2
 dpage=0
 mum_timer=20
 shake_limit=4
 static=0

 pup_msg1="" -- god i can't believe i'm hacking it like this. sorry, everyone
 pup_msg2=""

 sfx_reveal=10 
 sfx_key=15
 sfx_scroll=14
 sfx_royal=16
 sfx_guard=11
 sfx_treasure=13
 sfx_nothing=21
 sfx_scream=8
 sfx_usescroll=18
 
 col_border=15
 col_sky=0
 col_floor_trav=12
 col_floor_clear=0
 col_edge=1
 col_opened=2
 level_colours={3,5,8,14,3}
 pal_to_black={0,1,2,4,5,13,8,3,9,14,6,12,15,11,10,7}
 
 map_edge=0
 map_clr=1
 map_trav=2
 map_chest=3
 map_trsr=4
 map_key=5
 map_royal=6
 map_scrl=7
 map_guard=8
 map_opened=15

 h={}
 create_depth(29, 90, 4, 123, 26, 122)
 create_depth(48, 64, 30, 97, 43, 96)
 create_depth(60, 32, 46, 81, 53, 80)
 create_depth(63, 15.2, 53, 74, 58, 73)
 create_depth(64, 8, 58, 69, 62, 68)
 create_depth(64, 4, 61, 66, 63, 65)
 create_depth(64, 4, 63, 64, 64, 64)

 key={}
 key.x=104
 key.y=9
 key.height=6
 key.width=8
 
 royal={}
 royal.x=120
 royal.y=9
 royal.height=6
 royal.width=8
 
 scroll={}
 scroll.x=112
 scroll.y=9
 scroll.height=6
 scroll.width=8
 
 man={}
 man.x=113
 man.y=0
 man.height=8
 man.width=6

 mummy={}
 mummy.x=104
 mummy.y=0
 mummy.height=8
 mummy.width=8


 -- tidy this up once the numbers are set in stone, pre-calc xoff etx
 txt={}
 local t={} -- 1
 t.height=95
 t.width=47
 t.xoff=36
 t.yoff=4
 t.x=0
 t.y=0
 t.patch=true
 t.patchwidth=22
 t.patchheight=8
 t.patchx=89
 t.patchy=16
 t.pxoff=12
 t.pyoff=10
 add(txt,t)

 local t={} -- 2
 t.height=55
 t.width=24
 t.xoff=21
 t.yoff=3
 t.x=52
 t.y=0
 t.patch=true
 t.patchwidth=12
 t.patchheight=5
 t.patchx=111
 t.patchy=17
 t.pxoff=6
 t.pyoff=6
 add(txt,t)

local t={} -- 3
 t.height=24
 t.width=12
 t.xoff=11
 t.yoff=2
 t.x=77
 t.y=0
 t.patch=true
 t.patchwidth=5
 t.patchheight=3
 t.patchx=122
 t.patchy=18
 t.pxoff=5
 t.pyoff=1
 add(txt,t)

local t={} -- 4
 t.height=12
 t.width=7
 t.xoff=7
 t.yoff=2
 t.x=91
 t.y=0
 t.patch=false
 t.patchwidth=0
 t.patchheight=0
 t.patchx=0
 t.patchy=0
 t.pxoff=0
 t.pyoff=0
 add(txt,t)

local t={} -- 5
 t.height=5
 t.width=3
 t.xoff=5
 t.yoff=1
 t.x=98
 t.y=0
 t.patch=false
 t.patchwidth=0
 t.patchheight=0
 t.patchx=0
 t.patchy=0
 t.pxoff=0
 t.pyoff=0
 add(txt,t)

local t={} -- 6
 t.height=2
 t.width=1
 t.xoff=2
 t.yoff=0
 t.x=102
 t.y=0
 t.patch=false
 t.patchwidth=0
 t.patchheight=0
 t.patchx=0
 t.patchy=0
 t.pxoff=0
 t.pyoff=0
 add(txt,t)

local t={} -- 7 - never drawn, but for safety
 t.height=1
 t.width=1
 t.xoff=1
 t.yoff=0
 t.x=0
 t.y=0
 t.patch=false
 t.patchwidth=0
 t.patchheight=0
 t.patchx=0
 t.patchy=0
 t.pxoff=0
 t.pyoff=0
 add(txt,t)


 zdepth=6
 lscr={}
 rscr={}
 mscr={}

 view={}
 view.lx=4
 view.rx=123
 view.sy=21
 view.ey=125

 -- various textures
 texture_face_side=0b0101101001011010 --23130
 texture_face_on = 0 -- solid
 texture_side = 0
 texture_floor=0b1111000011110000

 startup()
end


function getclr(col)
  if col==0 then return col_edge
  elseif col==1 then return col_floor_clear
  elseif col==2 then return col_edge --- col_floor_trav
  elseif col==map_opened then return col_opened
  else return level_colours[p.level]
  end
end


-- we want to fudge a few 'first person' view colours on the map itself
function getmapclr(col)
  if debug then
    if col==0 then return col_edge
    elseif col>=20 then return 15  
    elseif (col==map_clr) then return col_floor_clear
    elseif (col==map_trav) then return col_floor_trav
    elseif (col==map_chst) then return 15
    elseif col==map_trsr then return 10
    elseif col==map_key then return 6
    elseif col==map_scrl then return 9
    elseif col==map_royal then return 13
    elseif col==map_guard then return 8
    elseif col==map_opened then return col_opened
    else return level_colours[p.level]
    end
  end

  local cl=band(col,0b00001111)
  if (cl==0) then return col_edge
  elseif (cl==1) then return col_floor_clear
  elseif (cl==2) then return col_floor_trav
  elseif (cl==map_opened) then return col_opened
  else return level_colours[p.level]
  end
end


function getcol(x,sy,ey,d)
  ret={}
  for l=sy,ey,d do
    add(ret,gmap[l][x])
  end
  while #ret<zdepth+1 do
    add(ret,0)
  end
  return ret 
end


function getrow(y,sx,ex,d)
  ret={}
  for l=sx,ex,d do
    add(ret,gmap[y][l])
  end
  while #ret<zdepth+1 do
    add(ret,0)
  end
  return ret 
end


function get_scr()
  lscr={}
  rscr={}
  mscr={}
  
  local sy=p.yp
  local sx=p.xp
  local ey=p.yp
  local ex=p.xp
  
  if (p.facedir==1) then
     ey=1
     d=-1
     lscr=getcol(p.xp-1,sy,ey,d)
     mscr=getcol(p.xp,sy,ey,d)
     rscr=getcol(p.xp+1,sy,ey,d)
  elseif (p.facedir==3) then
     ey=11
     d=1
     lscr=getcol(p.xp+1,sy,ey,d)
     mscr=getcol(p.xp,sy,ey,d)
     rscr=getcol(p.xp-1,sy,ey,d)
  elseif (p.facedir==2) then
     ex=13
     d=1
     lscr=getrow(p.yp-1,sx,ex,d)
     mscr=getrow(p.yp,sx,ex,d)
     rscr=getrow(p.yp+1,sx,ex,d)
  elseif (p.facedir==4) then
     ex=1
     d=-1
     lscr=getrow(p.yp+1,sx,ex,d)
     mscr=getrow(p.yp,sx,ex,d)
     rscr=getrow(p.yp-1,sx,ex,d)
  end
 -- now we have 3 arrays 'facing' the right way      
end


function draw_side_1(x,y,f)
  if f then
    sspr(24,0,24,94,x,y-93,24,94, f)
    sspr(0,96,7,31,x+24,y-93,7,31, f)
    sspr(8,95,9,31,x+22,y-63,9,31, f)
    sspr(18,95,25,33,x+23,y-32,25,33, f)
  else
    sspr(24,0,24,94,x+24,y-93,24,94, f)
    sspr(0,96,7,31,x+17,y-93,7,31, f)
    sspr(8,95,9,31,x+17,y-63,9,31, f)
    sspr(18,95,25,33,x,y-32,25,33, f)
  end  
end

function draw_side_2(x,y,f)
  if f then
    sspr(64,0,13,54,x,y-53,13,54, f)
    sspr(50,56,5,29,x+13,y-53,5,29, f)
    sspr(56,56,16,26, x+12, y-25, 16, 26, f)
  else
    sspr(64,0,13,54,x+15,y-53,13,54, f)
    sspr(50,56,5,29,x+10,y-53,5,29, f)
    sspr(56,56,16,26, x, y-25, 16, 26, f)
  end
end

function draw_side_3(x,y,f)
  if f then
    sspr(83,0,6,24,x,y-23,6,24,f)
    sspr(73,56,5,24,x+6,y-22,5,24,f)
  else
    sspr(83,0,6,24,x+5,y-23,6,24,f)
    sspr(73,56,5,24,x,y-22,5,24,f)
  end
end

function draw_side_4(x,y,f)
  if f then
    sspr(93,0,4,12,x,y-11,4,12,f)
    sspr(51,86,2,3,x+4,y-2,2,3,f)
  else
    sspr(93,0,4,12,x+2,y-11,4,12,f)
    sspr(51,86,2,3,x,y-2,2,3,f)
  end
end

function draw_side_5(x,y,f)
  sspr(54,86,3,5,x,y-4,3,5,f)
end




function padl(text,length,char)
  local c = char or " "
  local r = text
  while #r<length do
    r=c..r
  end
  return r
end


function padr(text,length,char)
  local c = char or " "
  local r=text
  while #r<length do
    r=r..c
  end
  return r
end


function title(text,colour)
  ctxt(text, 6, colour)
end


function ptitle()
  title("pyramid of "..pyr[p.pcount].name,15)
end


function ctxt(text,ypos,colour)
  local pos = flr((128 - (4*#text)) / 2)
  print(text, pos, ypos, colour)
end

-- centre text within a left/right 'block' (pixels)
function bctxt(text,ypos,colour,bstart,bend)
  local width=bend-bstart
  local pos = flr((width - (4*#text)) / 2)
  print(text, bstart+pos, ypos, colour)
end


function press_x()
  ctxt("press — ",120,15) -- extra space to overcome width of special 'x' char
end


function add_pyr(name)
  local p={}
  p.name=name
  add(pyr,p)
end


function setup_pyrs()
  pyr={}
  -- scope here to vary mummies, treasure, textures etc per pyramid at later date
  add_pyr("giza")
  add_pyr("djoser")
  add_pyr("teti")
  add_pyr("meidum")
  add_pyr("khafre")
  add_pyr("menkaure")
  add_pyr("userkaf")
  add_pyr("sahure")
  add_pyr("neferefre")
  add_pyr("nyuserre")
end



function load_highs()
  -- ever been saved?
  if dget(0)!=store_flag then
    clear_highs()
    return
  end

  high={}
  for x=1,5 do
    score={}
    score.score=0
    score.tombs=1
    score.name="        "
    add(high,score)
  end
  game_sound=num_to_bool(dget(1))
  game_music=num_to_bool(dget(2))
  game_diff=dget(3)
  game_speed=dget(4)

  ofs=5
  for x=0,4 do
    tstr=""
    for y=0,7 do
      f=dget(ofs+(y+(x*12)))
      tstr=tstr..chr(f) 
    end
    high[1+x].name=tstr
    high[1+x].tombs=dget(ofs+(8+(x*12)))
    high[1+x].score=dget(ofs+(9+(x*12)))
  end

end


function create_ascii()
  local chars=" !\"#$%&'()*+,-./0123456789:;<=>?@abcdefghijklmnopqrstuvwxyz[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"
  -- '
  s2c={}
  c2s={}
  for i=1,95 do
   c=i+31
   s=sub(chars,i,i)
   c2s[c]=s
   s2c[s]=c
  end
end

function chr(i)
 return c2s[i]
end

function ord(s,i)
 return s2c[sub(s,i or 1,i or 1)]
end


function save_highs()
  dset(0,store_flag) -- indicate we've saved data
  dset(1,bool_to_num(game_sound))
  dset(2,bool_to_num(game_music))
  dset(3,game_diff)
  dset(4,game_speed)

  ofs=5
  for x=0,4 do
    tstr=high[1+x].name.."        "  -- need to have 8 chars
    tstr=sub(tstr,1,9)
    for y=0,7 do
--      print(ofs+(y+(x*12)), sub(tstr,1+y,1+y))
      dset(ofs+(y+(x*12)), ord(tstr,1+y))
    end
    dset(ofs+(8+(x*12)), high[1+x].tombs)
    dset(ofs+(9+(x*12)), high[1+x].score)
  end
end

function bool_to_num(bool)
  if bool then return 1
  else return 0
  end
end

function num_to_bool(num)
  return (num==1)
end


function clear_highs()
  cls()
  high={}
  for x=1,5 do
    score={}
    score.score=100 + ((5-x)*50)
    score.tombs = flr(score.score/100)
    score.name="king tut"
    add(high,score)
  end

  game_speed=2
  game_diff=2
  game_sound=true
  game_music=true

  save_highs()
end


function input_hiscore()
  -- pop through the table, insert high score in the right place
  for x=1,5 do
    if high[x].score<p.score then
      -- bubble them down
      if x<5 then
        for y=5,max(x,2),-1 do
          high[y].score=high[y-1].score
          high[y].level=high[y-1].tombs
          high[y].name=high[y-1].name
        end
      end
      -- it goes here
      high[x].score=p.score
      high[x].level=p.tombs
      high[x].name=p.name   
      break
    end
  end
  save_highs()
end



__gfx__
000000000000000000009999999900000000000000000000000000000000009999000000000000a000999000a00a0000a00a00a0a00aa00a00ccc00099999999
00000000000000000555555555595aa000000000000000000000000000005555555a00000000005a0a55a50a500a0990900a00a0a0aaaa0a00a9190099aaaa99
00a5a50000000000aaaaaaaaaaa5aaaa000000000005a5a00000a5a0000aaaaaaa55500000a5a09009898900a0090aa0a0aaa000a0aaaa0a00c990009a98c9a9
00a5a5a00000000aaaaaaaaaaaaa5aaaa000000000a5a5a00000a5a000555555aaaaaa0000a5a0a0095aa500900aa9aaa00a00000a0aa0a000acc000a090909a
00a5a5a0000000aaa5555555555555555500000000a5a5a00000aa5a00aaaaaa555555000a5aa05a05a5590aa000aa9900a0a00000aaaa0000caa900a909090a
00a5a5a5a00000555aaaaaaaaaaaaaaaaa000000a5a5a5a00000aaa000aaaaaaaaaaaa0000aaa00a005aa00a0000aaaa0000000000aaaa0000ccc0009ac98ca9
005a5a5aa00000aaaaaaaaaa5555555555000000aa5a5a500000aaa000555555aaaaaa0000aaa00950a5a0a900000aa00000000000a00a0009c00c0099aaaa99
00aaaaaaa000005555555555aaaaaaaaaa000000aaaaaaa00000a55000995759555555000055a000a9aa59a000000aa0000000000aa00aa00090099099999999
00aaaaaa00000aaaaaaaaaaaaaaaaaaaaaa000000aaaaaa0000059900099585995859900009950000599aa0000009aaa00000000cccccccccccccccccccccccc
00aaaaaa00000aaaaaaaaaa555555555555000000aaaaaa000005990009995555555550000aaa0000aa599000000a00a00000000cccccccccccccccccccccccc
00aaaaaa000005555555555aaaaaaaaaaaa000000aaaaaa00000a55000555aaaaa5aaa00005550000aaa5a000000a00900000000cccccaaccc0cc0cccacccaac
00aaaaaa0000099999555995aaaaaaaaaaa000000aaaaaa000005aa000aaa55555aa550000aa5000059995000009a00aa0000000caaaacacc10aa01ccaaaaaac
00aaa555000009999577759955555555555000000555aaa00000a5aa00aaaaaaaa5599000aa5a000005a50000000000000000000ccaccaacc10aa01cc999999c
00055999000009999578759999578759999000000999550000000a550005555555599000055500000995a9000000000000000000cacacccccc0cc0ccccaccacc
000a599990000999957775999957775999900000a555aa00000005995000aa55aaaa000059990000aaa5a5500000000000000000cccccccccccccccccccccccc
000a599990000999995555555555555555500000aaaaaa0000000095aa0000aa5500000aa590000059905aa00000000000000000cccccccccccccccccccccccc
000aa5555000059999555aaaaaaaaaaaaaa0000055555a000000005aa5a5a555a55995aa5a0000009a00099005555555555aaaaaaaaaaaa00000000000000000
000aa5a5a0000a5555aaaaaaaaaaaaaaaaa00000aa5aa500000000005a595a5aaaa59555a00000059a0000a50aaaaaaaaaa5aaaaaaaaaaa555555aaaaaa00000
00055aa5a0000aaaaaaaaaaa5555555555500000aa5aa500000000000a5595aaa55595aa0000000a5000005a0aaaaaaaaaaa55555555555aaaaaa555555a55a5
000aaa5aa000055555555555aaaaaa5999900000a5aa5a000000000005aa59555aa5555500000009900000aa0aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
000aa55aaa000aaaaaaaaaaaaaaa55999990000aa5aa5a000000000000a5a5999555aa0000000000a00000500aaaaaaaaaaaaaaaaaaaaaaaaa555555555a5aa5
00005a5aaa0000aaaaaaaaaaaaa599999900000a5aa5a000000000000000a5599999900000000000500000a00aaaaaaaa55555555555555555aaaaa5aaa00000
0000aaa5550000055555555555555999900000055555a0000000000000005aa559995000000000059000009a05aaaa555aaaaaaaaaaaaaa00000000000000000
0000aa5599000000aaaa5aaaaaaaa55900000009999950000000000000005a599555a0000000009aa00000a5aa5555aaaaaaaaaaaaaaaaa00000000000000000
0000a599955000000aa5a55aaaaaaaa0000000a599999000000000000000a5555aaaa00000000000000000000000000000000000000000000000000000000000
000009995aa5a0000000aaa5555500000000a5a5999900000000000000005aaaaaaaa00000000000000000000000000000000000000000000000000000000000
00000095aa5aa5a000005aaaaaaa500000a5a5aa59900000000000000000955555a5500000000000000000000000000000000000000000000000000000000000
00000005aa5a5aa5aa55a55aaa55aa5995a5a5aaa500000000000000000099999955a00000000000000000000000000000000000000000000000000000000000
00000000aa5a5aa55aaa5aa555aaa5995aa5aa5aa0000000000000000000555555aa500000000000000000000000000000000000000000000000000000000000
000000000a5a5a5995aaa5aaaaaaa5995aa5aaa500000000000000000000a5a5aa59900000000000000000000000000000000000000000000000000000000000
00000000005a5a55995aaa555aaaa5995aaa5aa000000000000000000000a5a5a559900000000000000000000055555550055000000555555555000000000005
00000000000a5a5a59955aaaa55555995aaaa50000000000000000000000595a5aa55000000000000000000005ddddddd5dd5000005ddddddddd50000000005d
0000000000005a5aa599955aaaaaa555555550000000000000000000000999a50555a500000000000000000005cccccccccc500005ccccccccccc500000005cc
0000000000000a55aa59999555aaaaaaaaaa0000000000000000000000aa55a000999900000000000000000005cccccccccc50005ccccccccccccc5000005ccc
00000000000000a55aa559999955555aaaa0000000000000000000000055aa0000999550000000000000000005cccccccccc50005cccccccccccccc50005cccc
0000000000000005a55aa5555999999555000000000000000000000005999a0000055aaa000000000000000005cccccccccc5050cccccccc555ccccc5005cccc
0000000000000000aaa55aaaa5555999900000000000000000000000aa5990000000aa55a0000000000000000566666666555050666666650056666650056666
0000000000000000aa5aa55aaaaaa559900000000000000000000000aa5590000000a59950000000000000000577777775000050777777500057777750577777
000000000000000055aaaa5555aaaaa5500000000000000000000000aaaa00000000059950000000000000000577117750000050117775000057117750577771
0000000000000000aaaaa599995555aaa000000000000000000000095550000000000055aa000000000000000511111750000050111115000051111150511111
000000000000000055aa5999995aaa55a0000000000000000000000599000000000000aa5a000000000000000511111150000000511115000511111150511111
0000000000000000aa55555555aaaaaa50000000000000000000000a59000000000000aa5a000000000000000511111150000000511111555111eeeee0511111
0000000000000000aaaaaaaaa5555555a0000000000000000000000aa5000000000000aaa500000000000000052222225000000005222222222eeeeee0522222
0000000000000000555aaaaaaaaaaaaaa0000000000000000000000aaa000000000000aa5a0000000000000005dddddd5000000005dddddddeeeedee505ddddd
0000000000000000099555aaaaaaa5550000000000000000000000005500000000000055a0000000000000000577777750000000005777777eee75ee00057777
0000000000000000099999555555595a00000000000000000000000099500000000000aaa000000000000000055555555000000000055555eee550ee00005555
000000000000000009999999999995aa00000000000000000000000055a00000000000555000000000000000000000000ee000000eee000eeeeeeeeeeeee00ee
00000000000000000999999999555aaa000000000000000000000000aa500000000000aaa00000000000000000000000eee333e0eeeee33eeeeeeeeeeeee33ee
00000000000000000555555555aaaaa50000000000000000000000005a90000000000055a00000000000000000000000eee33ee0ee3ee33eee33eee33eee3ee3
00000000000000000a5aa5aa5aaaa559000000000000000000000000a5990000000005995000000000000000000000333eee3ee0333ee3eee333ee333ee33ee3
00000000000000000aa5aa5aa5aa59990000000000000000000000095a59000000000a599500000000000000000003333eeeeee0333eeeeee33eee3eeee3eee3
00000000000000000aa5aaa5aa559999000000000000000000000a5995a5000000000a555a550000000000000000000000eeeee00eeeeeeee00eeeeeeeeeeeee
00000000000000000aa55aaa5aaa5999000000000000000000005a55995a0000000005aaa595a000000000000333333eeeeeeee0eee333ee333eeee33eee3eee
0000000000000000555995aaa55aa5599000000000000000009955aa590000000000000a59555a000000000333333333eeee33e0ee333eee3333333333333333
000000000000000099995a5a0aa5aaa5500000000000000000995aa0000000000000000000aaa50000000033333333333333333033333ee33333333333333333
00000000000000099555aaa000aa55aaa50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000555a5aaa00000599555990000000000000000009900000000000055aa000000a00033333333333333333333330333333333333333333333333
00000000000000aaaaa5aa000009999999900000000000000000995000000000000aa5aa00000500333333333333333333333330333333333333333333333333
00000000000005555aaa5000000099999555000000000000000995a000000000000aaa5500000a03333333333333333333333330333333333333333333333333
000000000000999995aa0000000005555aaaa0000000000000555aa0000000000000559900000a00000000000000000000000000000000000000000000000000
0000000000005999995a000000000aaaaaaaa0000000000000aa5a50000000000000995500000500000000000000000000000000000000055555500000000000
00000000000aa5999950000000000055555aaa000000000000aaa5a0000000000000599900000900000000000000000000000000000000051111500000000000
0000000000aaa59999500000000000aaaaa555a00000000000aa5aa0000000000000a55500005500000000000000000000000000000000051111500000000000
0000000000aaaa55990000000000000aaa599950000000000055aa5000000000000aaaaa0000aa00000000000000000000000000000000051111500000000000
000000000aaaa5aa5000000000000000aa5999990000000000aa5590000000000005aaaa0000a50000000000000000000000000000000005dddd500000000000
000000000aaaa5aaa000000000000000a5999999000000000055aa5000000000000a555a0000590005555555555555000000055550555555dddd500000000000
000000005aaa5aaa0000000000000000059995555000000000aa5aa000000000000599900000a5000ddddddddddddd5000005dddd0dddddddddd500000000000
0000000095aa5a50000000000000000000995aa5a000000000a5a5500000000000aa59900000aa000ccccccccccccc500005ccccc0cccccccccc500000000000
00000000995555a000000000000000000055aaa5a000000000595aa00000000095a5a50000005a000ccccccccccccc50005cccccc0cccccccccc500000000000
00000000599999000000000000000000000aaa5aa00000000009955000000005995aaa000000a5000ccccccccccccc5005ccccccc0cccccccccc500000000000
00000000a55999000000000000000000000aaa5aa000000000005aa0000000aa5995a00000005a000cccc555cccccc5005ccccccc0c555cccccc500000000000
00000000aaa555000000000000000000000555a5a00000000000a5500000a5aa599500000000a500066650056666665056666666605005666666500000000000
00000000aaaaa5000000000000000000000aa5aa5000000000055aa000a5aa5aa00000000000aa00077500057777775057777777500005777117500000000000
0000000055555a000000000000000000000aa5aaa0000000000aa5a00a595a500000000000005000015000057771115057777775000005771111500000000000
00000000aaaaaa000000000000000000000aa5aaa000000000aaaa50aaa5950000000000000aa000015000051111115051111115000005111111500000000000
00000000aaaaa5000000000000000000000aaa555000000000aaa590055950000000000000a50000015000511111115051111115000051111111500000000000
00000000055559000000000000000000000555aa0000000000555990099990000000000009a00000011555111111115005111111505511111111500000000000
0000000009999950000000000000000000aaaaaa0000000000aaa55000559900000000000a500000022222222222225005222222202222222222500000000000
00000000099955a0000000000000000000aaaaaa0000000000aaaaa0000a59000000000000a000000dddddddd5dddd50005dddddd0dddddddddd500000000000
000000000555aaa000000000000000000055555a0000000000555a50000aa550000000000000000007777775505777500005e777707777777777500000000000
000000000aaaaaa0000000000000000000aaaaa50000000000aaa5500000aaa0000000000000000005555550eee555500e0eee5550eeeee55555500000000000
000000000aaaaa500000000000000000005aaaaa00000000000aaaa000000aa00000000000000000000e000eeeeee0000eeeee00e0e00ee00000000000000000
0000000005aaa590000000000000000000955aaa000000000005555000000000000000000000000003ee33ee333ee333ee33ee33e033ee000000000000000000
000000000a5559900000000000000000009995aa000000000009999000000000000000000000000003ee3eee33eee333ee3ee33ee0eee33ee000000000000000
000000000aaa599900000000000000000599995500000000000995500000000000000000000000000ee33ee333ee333ee33e33eee0e333ee3000000000000000
0000000005aaa59900000000000000000a59999900000000000000000000000000000000000000000eeeeee33eeeeeeee3eeee33e0eeee333300000000000000
00000000995aaa5900000000000000000aa59999500000000000a00a0000000000000000000000000eee0eeeee0eeeee00eee00000eeee000000000000000000
000000599995aaa500000000000000000aaa5955aaa00000000a000a000000000000000000000000033333333333333333333333303333333333330000000000
00000aa599995aa500000000000000000aa555aaa55500000000a00aa00000000000000000000000033333333333333333333333303333333333333300000000
0005aa555999955a00000000000000000a5aa5a55995aa000000000a000000000000000000000000033333333333333333333333303333333333333330000000
009955aaa59995aa00000000000000000a5aa559995aaaa0000000a0a00000000000000000000000000000000000000000000000000000000000000000000000
9995a5aaaa59900000000000000000000000a599995555aaa0000000000000000000000000000000033333333333333333333333303333333333333333333000
995aa5aaaa50000000000000000000000000009995aaaa5aa0000000000000000000000000000000033333333333333333333333303333333333333333333330
995aaa5a0000000000000000000000000000000005aaaaa5a0000000000000000000000000000000033333333333333333333333303333333333333333333333
00aaaa0000000000000000000000000000000000000aaaa000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000aaaaaaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000099905555955000000000000000000000aaaaaaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00009950aaaa599000000000000000000000aaaaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000995a0aaaaa5900000000000000000000055555a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00995aa0555aaa500000000000000000000099999500000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05555550aaa5aaa00000000000000000000999999500000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0aa5aaa0aaaa55a00000000000000000000555599900000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0aaa5aa0aaa599550000000000000000000aa5559900000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaaaa5a0aa599990000000000000000000aaa5aa5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaaa5550a599999900000000000000000aaa5aaaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aa55aaa05555555000000000000000005aaa5aaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55aaaaa0aaaaaaa0000000000000005995555aa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaaaa550aaaaaaa00000000000000aa599995a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaaa5990555555a000000000000a5aa5999950000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aa55a5509999995000000000005a5aaa599500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55aaaaa09999999000000000095a5aaaa55000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaaaa5505999999900000000995a5aaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a5555aa0a5555550000000a5995aa5aa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
59999550aaaaaaa000000aa59995a5a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99995aa055aaaaa0000aaaa59995a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0955a5a0aa5555a000aaaa5559950000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00aaa5a0aaaaaa5000aaa5a555900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000aaa5055aaa5a000055aaaa5500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000a5a0095555a5000aaaaaaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000aa0099995aa5000555aaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000a0099995aa5a0099955aa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000009500999995a5000099995500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00099950095599955000055999900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
005555a005aa599990000aa559990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0aaaaa500aaa5559900000aaa5990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaaaa5a00aaaaaa5000000aaaa550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaa55aa0000000000000000aaaaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
555595500000000000000000aaaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
0001000038050380503705034050320502b05026050220501e0501c0501b0501a0501a0501b0501e05020050240502a050320503505035050310502b050230501f0501c050190501605013050100500e0500b050
01010000010700107001070000000000000000000000c1000d1000e1000f100111001210013100141001510015100000000000000000000000000000000000000000000000000000000000000000000000000000
000100000106001060010500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000105001050010400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000103001030010200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000102001020010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000101001010010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200033425302623364533f10300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003
000100003420000001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100000000000000000000000000000000000
000100041271101121011113f10100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001
010700000111301123021230313304143041430314308143071530715307153061530515303143021430214302143031430313304133031330410304103031030210303103000030000300003000030000300003
010400000111301123011230113301143011420114302142051530215202153021520515302142021430214202143021420213302162021630213202123021230215302153061530615306153061530000300003
000100002e050290502805026050250502405023050230502305023050250502705028050290502b0502f0502e0502c0002c00000000000000000000000000000000000000000000000000000000000000000000
0010000000000270002d0002b00027000210001900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010f00002907729074290742907400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010f00002907729074290742907400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01a000000c30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0006000018050120500e0500b05007050040500205001050010500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011300002753227532275322953229532295322b5322b5322b5322b5322b5322b5322b5322b5322c5322c5322c5322b5322b5322b532295322953229532275322753227532265322653226532245322453224535
011300000353203532035320553205532055320753207532075320753207532075320753207532085320853208532075320753207532055320553205532035320353203532025320253202532005320053200535
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01080020010530000300003000030000301003010430c103000030000300003000030000300003010030000301053000030000301003000030000301043000030000300003000030000301003000030000300003
00070020010530000300003000030000301003010430c103000030000300003000030000300003010030000301053000030000301003000030000301043000030000300003000030000301003000030000300003
00060020010530000300003000030000301003010430c103000030000300003000030000300003010030000301053000030000301003000030000301043000030000300003000030000301003000030000300003
00050020010530000300003000030000301003010430c103000030000300003000030000300003010030000301053000030000301003000030000301043000030000300003000030000301003000030000300003
00040020010530000300003000030000301003010430c103000030000300003000030000300003010030000301053000030000301003000030000301043000030000300003000030000301003000030000300003
00030020010530000300003000030000301003010430c103000030000300003000030000300003010030000301053000030000301003000030000301043000030000300003000030000301003000030000300003
012000001a145001051a1451b1451a145001051a1451b1451e1451f1451e1451b1451a1451a1451a1450000026145181052614522145211450010522145211451e1451f1451e1451b1451a1451a1451a14500005
012000001a625006051a6251a6251a625006051a6251a6251a625006051a6251a6251a625006051a6251a6251a625006051a6251a6251a625006051a6251a6251a625006051a6251a6251a625006051a6251a625
012000000231202431023120231202312024310231202312023120243102312023120231202431023120231202312024310231202312023120243102312023120231202431023120231202312024310231202312
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
03 16 42 43 44
03 17 42 43 44
03 18 42 43 44
03 19 42 43 44
03 1a 42 43 44
03 1b 42 43 44
04 14 13 43 44
03 1c 1d 1e 44
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
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
