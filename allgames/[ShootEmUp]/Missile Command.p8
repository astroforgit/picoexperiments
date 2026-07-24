pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
-- missile command 0.80
-- 2021 paul hammond

-- debug
version="0.80"
debug_stats=false

-- cartridge data
cartdata("phammond_missilecommand_2p8")

-- constants
hiscorechars="abcdefghijklmnopqrstuvwxyz0123456789.-?*"

-- enums
gs_titles=0 -- game state
gs_modeselect=1
gs_demo=2
gs_game=3
gs_hiscore=4

mm_arcade=0 -- machine mode
mm_tournament=1
mm_chaos=2

s_levelstart=-1 -- session state
s_levelclear=-3
s_playing=0
s_gameover=9

ps_normal=0 -- player state 
ps_dying=1
ps_dead=99

cs_normal=0 -- city state
cs_exploding=1

et_bomb=0 -- enemy type
et_plane=1
et_smartbomb=2
et_sattelite=3

-- sfx and music
sfx_nofire=0
sfx_fire=1 
sfx_levelstart=2 
sfx_explode1=3
sfx_theend=4
sfx_flyer=5
sfx_bonuscity=6
sfx_startup=7
sfx_blip=8
sfx_blop=9
sfx_explode2=40
sfx_smartbomb=41

music_titles=0
music_hiscore=48

-- other
rainbow={1,0,7,10,2,8,12,11}

-- mode
machinemode=mm_arcade

-- titles
title_x=0
title_text="paul hammond 2021 (@paulhamx) è based on the 1980 atari game by dave theurer è inspired by 'missile commander' by tony temple"
lastscore=nil

-- support
supports_lockedmouse=false

function _init()
 -- enable keyboard and mouse with locking
 --poke(24365,1)
 poke(0x5f2d,0x5)
 
 -- create default high score tables
 highscores={}
 highscores[0]=highscoretable_create("arcade",{"pal",7500,"fin",7495,"luc",7330,"sop",7250})
 highscores[1]=highscoretable_create("tournament",{"pal",5500,"fin",5495,"rac",5330,"luc",5250}) 
 highscores[2]=highscoretable_create("chaos",{"pal",3500,"sop",3495,"fin",3330,"luc",3250})
 
 -- reset defaults
 --data_save()
 
 -- load data
 data_load()

 -- splash
 splash()

 -- initialise
 reset_titles()
 lastscore=longnum_create(0)
end

function reset_titles()
 flash=false
 flashcounter=0
 rainbowcounter=0
 state=gs_titles
 titlecounter=0

 -- clear sfx and music
 sfx(-1)
 music(-1)
 
 -- palette
 pallevel(1)

 -- transition
 transition:start()
 
 -- title story
 int_title:start()
end

function reset_newgame()
 state=gs_game
 lasthiscoretableindex=nil
 music(-1)
 game_reset()
end

function _update60()
 -- support 
 if not supports_lockedmouse then
  if (stat(38)!=0 or stat(39)!=0) supports_lockedmouse=true
 end
 
 -- counters
 flashcounter=(flashcounter+1)%60
 flash=flashcounter<30
 rainbowcounter=(rainbowcounter+0.5)%#rainbow
 rainbowcolour1=rainbow[1+rainbowcounter]
 rainbowcolour2=rainbow[1+(rainbowcounter+4)%#rainbow]
 
 -- rainbow colour (brown)
 pal(4,rainbowcolour1)
 
 -- get last key pressed
 lastkey=kb()

 -- update
 if state==gs_titles then
  update_titles()
 elseif state==gs_demo then
  update_demo()
 elseif state==gs_modeselect then
  update_modeselect()
 elseif state==gs_hiscore then
  update_hiscore()
 else
  update_game()
 end

 -- transition
 transition:update()

 -- quit game?
 if (lastkey=="q") gameover=true
end

function update_game()
 game_update()

 -- game over?
 if gameover then
  lastscore=player.score
  
  -- high score?
  if highscores[machinemode]:ishighscore(lastscore) then
   reset_hiscore()
  else
   reset_titles()
  end
 end
end

function update_hiscore()
 -- select letter
 if btnp(2) then
  hiscorecharindex+=1
 elseif btnp(3) then
  hiscorecharindex-=1 
 end
 if hiscorecharindex<1 then
  hiscorecharindex=#hiscorechars
 elseif hiscorecharindex>#hiscorechars then
  hiscorecharindex=1
 end
 
 hiscoreinitials[hiscoreinitialindex]=sub(hiscorechars,hiscorecharindex,hiscorecharindex)
 
 -- next letter/ finish
 if btnfire() then
  --sfx
  sfx(sfx_blip)
  
  -- advance  
  hiscoreinitialindex+=1
  hiscorecharindex=1
  
  -- done?
  if hiscoreinitialindex==4 then
   -- get high score table
   lasthiscoretableindex=machinemode  
   local h=highscores[machinemode]
   
   -- get initials
   local initials=""
   for i=1,3 do initials=initials..hiscoreinitials[i] end
   
   -- add to table
   lasthighscoreindex=h:addscore(initials,lastscore)

   -- save
   data_save()
   
   -- straight to demo mode so high score will be displayed
   reset_demo()
   music(music_titles)
  end
 end
end

function update_titles()
 -- title story
 int_title:update()

 -- controls
 if (btnp(4)) reset_demo()
 if (btnfire()) reset_modeselect()
 
 -- music
 if (titlecounter==90 or (titlecounter<90 and state!=gs_titles)) music(music_titles)
 
 -- counters
 titlecounter+=1
 
 -- change mode?
 if (not int_title.active) reset_demo()
end

function _draw()
 -- draw
 if state==gs_titles then
  draw_titles()
 elseif state==gs_modeselect then
  draw_modeselect()
 elseif state==gs_demo then
  draw_demo()  
 elseif state==gs_hiscore then
  draw_hiscore()  
 else
  game_draw()
 end

 -- transition
 transition:draw()

 -- debug
 if debug_stats then
  camera(0,0)
  rectfill(0,0,60,16,10)
  ? "cpu: "..(100*(stat(1)/2)).."%",0,0,1
  ? "mem: "..stat(0),0,6
  ? "fps: "..stat(7),0,12
  camera()
 end
end

function draw_titles()
 -- title story
 int_title:draw()
end

function reset_demo()
 state=gs_demo
 titlecounter=0
 demohighscoretableindex=-1
 if (lasthiscoretableindex) demohighscoretableindex=lasthiscoretableindex
 game_reset()
 transition:start()
end

function reset_hiscore()
 state=gs_hiscore
 hiscoreinitials={"","",""}
 hiscoreinitialindex=1
 hiscorecharindex=1
 
 transition:start()
 
 -- clear sfx
 sfx(-1)
  
 -- music
 music(music_hiscore)
end

function reset_modeselect()
 state=gs_modeselect
 previewlevel=nil
 --menumousey=0
 menuselectedcounter=0
 transition:start()
 --music(music_modeselect)
 game_reset()
end

function update_modeselect()
 -- initialise
 local oldmode=machinemode

 -- preview
 if (previewlevel!=nil) game_update()

 -- controls
 if(btnfire()) reset_newgame()
 if(btnp(4)) reset_titles()
 
 if btnp(2) then
  machinemode-=1
  sfx(sfx_blip)
 end
 if btnp(3) then
  machinemode+=1
  sfx(sfx_blip)
 end
 
 -- finalise
 machinemode=mid(0,machinemode,2)
 if oldmode!=machinemode then
  data_save()
  menuselectedcounter=30
 end

 -- scroll text
 title_x+=0.5
 if (title_x>150+#title_text*5) title_x=0

 -- counters
 menuselectedcounter=move(menuselectedcounter,0,2)
end

function draw_hiscore()
 cls(0)
 
 -- game (i.e., background from previous game)
 game_draw_arena()
 
 -- last score
 printcw(lastscore:tostring(),1,8,true)
 
 -- initials
 for i=1,3 do
  local x=44+i*8
  if i==hiscoreinitialindex and flash then
   prints("\^w\^i"..hiscoreinitials[i],x,32,8)
  else
   prints("\^w"..hiscoreinitials[i],x,32,8)
  end
 end
 
 -- help text
 printcw("great score",50,1,true)
 printc("enter your initials",60,1,true)
 printc("use î and É to change letters",70,1,true)
 printc("press any fire button to select",80,1,true)
end

function draw_modeselect()
 cls(0)
 
 -- demo game
 game_draw() 
 
 -- last score
 if (lastscore:hasvalue()) printcw(lastscore:tostring(),1,8,true) 
 
 -- menu
 camera(0,-12)
 --printcw("choose game mode",0,10)
 
 local modes={"arcade","tournament","chaos"}
 local info={"bonus city every \f810000\f1 pts","no bonus cities","tournament level \f815\f1"}
 
 for i=0,2 do
  if i==machinemode then
   printcw("\#8"..modes[i+1],14+i*10,0)
  else
   printcw(modes[i+1],14+i*10,8)
  end
 end
 
 printc(info[machinemode+1],54,1)
 glitchrect(0,54,127,8,menuselectedcounter)
 camera()
 
 -- controls
 --[[
 if time()%6<3 then
  printc("trackball and a,s,d to fire",76,10)
 else
  printc("or \f8ó\fa for slow center fire",76,10) 
 end
 ]]--
 if (flash) printc("ó start",88,7,true)
 
 -- scroll text
 prints(title_text,128-title_x,123,1,10)
end

function drawlogo(py)
 local d=56/(120*8)
 for i=0,17 do tline(4,py+i,124,py+i,0,i*d,d,0) end
 for i=18,36 do tline(4,8+py+i,124,8+py+i,0,i*d,d,0) end
end

function update_demo()
 -- demo game
 game_update()
 
 -- controls
 if (btnfire()) reset_modeselect()
 
 -- counters
 titlecounter+=1
 if titlecounter>600 then
  demohighscoretableindex+=1
  if (demohighscoretableindex==3) demohighscoretableindex=0
  titlecounter=0
 end
 
 -- restart demo?
 if #enemies==0 and #explosions==0 and gstatecount>2000 then
  game_reset() 
 end
end

function draw_demo()
 -- demo game
 game_draw()
 
 -- last score
 if (lastscore:hasvalue()) printcw(lastscore:tostring(),1,8,true)
 
 -- hi-scores
 if demohighscoretableindex!=-1 then
  if titlecounter<150 then
   camera(300-titlecounter*2,-16)
  elseif titlecounter>450 then
   camera((450-titlecounter)*2,-16)
  else
   camera(0,-16)
  end
  
  -- hi-score table
  local hst=highscores[demohighscoretableindex]
  
  printcw(hst.name,4,9,true)
  printcw("high scores",11,11,true)
  
  for i=1,#hst.items do
   local c=3
   
   if demohighscoretableindex==lasthiscoretableindex and i==lasthighscoreindex and flash then
    c=9
   end
   
   local h=hst.items[i]
   prints("\^w"..h.name,20,17+i*7,c)
   local sc=h.value:tostring()
   prints("\^w"..sc,108-8*#sc,17+i*7,c)
  end
  
  camera()  
 end
 
  -- controls
  if (flash) printc("ó start",82,7,true)

--[[
 if (levelpal==nil) levelpal=1
 pallevel(levelpal)
 if (btnp(2)) levelpal+=1
 if (btnp(3)) levelpal-=1
 print(levelpal,0,0,7) 
]]--
end

function btnfire()
 return btnp(5) or lastkey=="a" or lastkey=="s" or lastkey=="d"
end

function splash()
 local p,s=0,""
 
 for i=1,220 do
  if i==1 then
   s="shall we play a\n\ngame?"
   p=0
  elseif i==100 then
   s="how about global\n\nthermonuclear\n\nwar?"
   p=0
  end

  cls(0)
  print("\^w"..sub(s,1,p),4,4,8)
  flip()
  
  if (p<=#s) sfx(sfx_blip)
  p+=0.5
  
  -- get last key pressed
  lastkey=kb()
 
  -- quick exit?
  if (btnfire()) break
 end
end

function data_save()
 local pos=0
 
 -- machine mode
 dset(pos,machinemode)
 pos+=1
 
 -- hi-score tables
 for i=0,2 do
  local h=highscores[i]
  pos+=h:dset(pos)
 end
end

function data_load()
 local pos=0
 
 local s=""
 for i=1,63,5 do
  --s=s..chr(dget(i))
  s=s..chr(dget(i+2))
  s=s..chr(dget(i+3))
  s=s..chr(dget(i+4))
  s=s..","
 end
 
 -- machine mode
 machinemode=dget(pos)
 pos+=1
 
 -- high scores
 if dget(pos)==0 then
  -- not yet saved
 else
  -- load
  for i=0,2 do
   local h=highscores[i]
   pos+=h:dget(pos)
  end
 end
end
-->8
-- game

-- refs:
-- * http://www.retrogamedeconstructionzone.com/2019/11/missilie-command-deep-dive.html
-- * https://arcadeblogger.com/2021/01/02/missile-command-arcade-world-record-footage/
-- * https://strategywiki.org/wiki/missile_command/walkthrough

function game_reset()
 bonuscities=0
 bonusscore=0
 citycount=0
 gameover=false
 level=iif(machinemode==mm_chaos and state==gs_game,14,0)
 
 -- randomise
 srand(time())
 
 -- objects
 bases={}
 cities={}
 intermissions={}
 player=player_create(0)
 intermission=nil
 
--add(intermissions,int_gameover) 
 
 -- create cities
 for i=1,6 do
  local c=city_create(({20,34,46,71,85,100})[i],({113,114,115,113,112,113})[i])
  add(cities,c)
 end
 
 -- create bases
 for i=1,3 do
  local b=base_create(i,({7,60,112})[i],115)
  add(bases,b)
 end

  -- state
 game_resetlevel(true)
end

function game_resetlevel()
 -- advance to next level
 level+=1
 levelresolved=1+(level-1)%255
 --printh(levelresolved)
 
 -- general
 allout=false
 leveltime=0
 missilecount=30
 missileoutcounter=0
 shakecount=0
 
 -- objects
 enemies={}
 explosions={}
 missiles={}
 
 -- reset bases
 for b in all(bases) do base_reset(b) end

 -- make all active cities visible (hidden in end of level sequence)
 for c in all(cities) do c.visible=true end
 
 -- pick targets (3 bases, 3 cities, shuffled)
 targets={}
 nexttarget=flr(rnd(6))
 for b in all(bases) do add(targets,b) end
 for c in all(cities) do c.targetted=false end
 
 while(#targets<6) do
  local c=cities[1+flr(rnd(6))]
  
  if not c.targetted then
   -- ensure active cities are the primary targets
   if c.active or #targets-3>=citycount then
    c.targetted=true
    add(targets,c)
   end
  end
 end
 
 for i=1,12 do
  local n=1+flr(rnd(6))
  targets[n],targets[1]=targets[1],targets[n]
 end
 
 -- initialise level
 local lev=iif(levelresolved<16,levelresolved,13+levelresolved%3)
 levelbombs=({12,15,18,12,16,15,18,12,16,20,23,16,17,22,24})[lev]
 levelbombsinterval=180
 levelbombsintervalcounter=levelbombsinterval
 
 levelsmartbombs=({0,0,0,0,0,1,1,2,3,4,4,5,5,6,6})[lev]
 levelsmartbombinterval=360 -- max interval
 levelsmartbombintervalcounter=levelsmartbombinterval
 
 levelflyerinterval=180
 levelflyerintervalcounter=levelflyerinterval
 
 --levelspeed=({22,14,9.5,7,6,5,4,3.75,3.5})[min(levelresolved,9)]
 --levelspeed=({20,13,9.5,7,6,5,4,3.75,3.5})[min(levelresolved,9)]
 levelspeed=({19,12,9,7,6,5,4,3.75,3.5})[min(levelresolved,9)]

 scoremultiplier=({1,1,2,2,3,3,4,4,5,5,6})[min(levelresolved,11)]
 
 wavecounter=0

 -- finalise
 player_resetlevel(player)
 game_setstate(s_levelstart)

 -- palette
 pallevel(level)

 -- transition
 if (state==gs_game) transition:start()
end

function game_setstate(s,c)
 gamestate=s
 gstatecount=c or 0
end

function game_update()
 -- intermission?
 -- note: may be a queue of intermissions to show
 if #intermissions>0 then
  if intermission then
   if intermission.active then
    intermission:update()
   else
    del(intermissions,intermission)
    intermission=nil
    
    -- time for new level or game over?
    if #intermissions==0 then
     if gamestate==s_gameover then
      gameover=true
     else
      game_resetlevel()     
     end
    end
   end
  else
   intermission=intermissions[1]
   intermission:start()
  end
  
  return
 end

 -- explosions
 for e in all(explosions) do
  explosion_update(e)
  if (not e.active) del(explosions,e)
 end 

 -- enemies
 local flyercount=0
 
 for e in all(enemies) do 
  enemy_update(e)
  
  -- count flyers
  if (e.type==et_plane or e.type==et_sattelite) flyercount+=1
  
  if allout then
   if (e.active) enemy_update(e)
   if (e.active) enemy_update(e)
  end
  
  if not e.active then
   -- cancel looped sfx?
   if e.type==et_plane or e.type==et_sattelite then
    gsfx(-1,3)
   elseif e.type==et_smartbomb then
    gsfx(-1,2)
   end
  
   del(enemies,e)  
  end
 end

  -- run fast if no cities or missiles left
  if citycount==0 or (missilecount==0 and #missiles==0 ) then
   allout=true
   
   -- count targets remaining
   local targetcount=0
   for e in all(targets) do
    if (e.active) targetcount+=1
   end
   printh("targetcount="..targetcount)
   
   -- no point playing out the level any more?
   if (targetcount==0 or citycount==0) and missilecount==0 and #missiles==0 then
    levelbombs=0
    levelsmartbombs=0
   end
  end
 
 -- cities
 for c in all(cities) do city_update(c) end

 -- bases
 for b in all(bases) do base_update(b) end
 
 -- missiles
 for m in all(missiles) do
  missile_update(m)
  if (not m.active) del(missiles,m)
 end 
  
 -- update player (since player is really just a pointer)
 player_update(player)
   
 if gamestate==s_levelstart then
  -- ###########
  -- level start
  -- ###########
  if state==gs_demo then
   -- start playing immediately in demo mode
   game_setstate(s_playing)
  elseif gstatecount==5 then
   -- sfx
   gsfx(sfx_levelstart)
  elseif gstatecount>120 then
   -- play
   game_setstate(s_playing)
  end
 elseif gamestate==s_playing then
  -- #######
  -- playing
  -- #######
  if gstatecount==1 then
  end
  
  -- next wave of bombs?
  if levelbombs>0 then
   if levelbombsintervalcounter>=levelbombsinterval or #enemies<2 then
    levelbombsintervalcounter=0
    wavecounter+=1
    local wavesize=4
    if wavecounter>3 then
     if wavecounter<7 then
      wavesize=1
     else
      wavesize=flr(rnd(4))
     end
    end
    
    for i=1,wavesize do 
     if (levelbombs>0 and #enemies<8) enemy_addbomb() 
    end
    
    if wavecounter>1 then
     if wavecounter%2==1 then
      levelbombsinterval*=2
     else
      levelbombsinterval/=2
     end
    end
   else
    levelbombsintervalcounter+=1
   end
  end
   
  -- add flyer?
  if flyercount==0 and levelresolved>1 and levelbombs>0 then
   if levelflyerintervalcounter>=levelflyerinterval and #enemies<8 then
    levelflyerintervalcounter=0
    enemy_addflyer()
   else
    levelflyerintervalcounter+=1
   end
  end
  
  -- add smart bomb?
  if levelsmartbombs>0 then
   if levelsmartbombintervalcounter>=levelsmartbombinterval and #enemies<8 then
    levelsmartbombintervalcounter=rnd((levelsmartbombinterval-30)/2)
    enemy_addsmartbomb()
   else
    levelsmartbombintervalcounter+=1
   end
  end  
  
  -- time
  leveltime+=1/60

  -- level clear?
  if levelbombs<=0 and levelsmartbombs<=0 and #enemies==0 and #explosions==0 then
   if state==gs_demo then
    -- don't complete the level, just wait
   else
    game_setstate(s_levelclear)
   end
  end
 elseif gamestate==s_levelclear then
  -- ###########
  -- level clear
  -- ###########
  if citycount==0 and bonuscities==0 then
   -- game over
   game_setstate(s_gameover)
  else
   -- end of level bonus
   add(intermissions,int_levelclear)
  end
 elseif gamestate==s_gameover then
  -- #########
  -- game over
  -- #########
  add(intermissions,int_gameover)
 end
 
 -- counters
 gstatecount+=1
 if (shakecount>0) shakecount-=1
end

function game_draw()
 -- intermission?
 if #intermissions>0 then 
  if (intermission and intermission.active) intermission:draw()
  return
 end
  
 -- arena
 game_draw_arena()

 -- score panel
 if (state==gs_game) game_draw_scorepanel()
 
 -- finalise
 camera()
 clip()
  
 -- messages
 if state==gs_demo then
  -- demo messages
  prints("\^wdefend",12,94,1,true,0)
  prints("\^wcities",68,94,1,true,0)
  if gstatecount%60>10 then
   for c in all(cities) do spr(32,c.x,104) end
  end
  
  for b in all(bases) do
   local y=b.y-6+cos(time())*4
   pal(1,0)
   spr(63,b.x,y)
   pal(1,1)
   print(({"A","S","D"})[b.index],b.x+2,y+1,0)
  end
 elseif state==gs_game then
  -- game messages
  if gamestate==s_levelstart then
   local s=""..level
   print("\^wattack wave \f8"..level,64-((12+#s)*8)/2,42,1)
   print("\^w"..scoremultiplier.." \f1x points",24,66,8)
  end
 end
end

function game_draw_arena()
 if shakecount==4 then
  cls(7)
 else
  cls(0)
 end
 
 -- shake
 if shakecount>0 and gamestate==s_playing then
  camera(-shakecount/2+rnd(shakecount),-shakecount/2+rnd(shakecount))
 end

 -- map
 map(0,4,0,114,16,2)
  
 -- cities
 for c in all(cities) do city_draw(c) end

 -- nothing else if in hi-score entry
 if (state==gs_hiscore) return
 
 -- bases
 for b in all(bases) do base_draw(b) end

 -- enemies (not smart bombs)
 for e in all(enemies) do 
  if (e.type!=et_smartbomb) enemy_draw(e)
 end
 
 -- missiles
 for m in all(missiles) do missile_draw(m) end

 -- explosions
 -- note: drawing in reverse order looks more like the original
 for i=#explosions,1,-1 do
  e=explosions[i]
  explosion_draw(e)
 end

  -- enemies (smart bombs)
 for e in all(enemies) do 
  if (e.type==et_smartbomb) enemy_draw(e)
 end

 -- player
 if ((gamestate==s_playing or gamestate==s_levelstart) and state!=gs_modeselect) player_draw(player)
 
 -- finalise
 camera()
end

function game_draw_scorepanel()
 camera(0,0)
 printcw(player.score:tostring(),1,8,true)
end


-- enemy
function enemy_addbomb(x,y,threaded,fromflyer)
 -- defaults
 if (x==nil) x=4+flr(rnd(120))
 if (y==nil) y=0
 
 -- decrease counters
 if (threaded==nil and not fromflyer) levelbombs-=1
 
 -- find a target
 local target=entity_getnexttarget()
 
 local s={
  type=et_bomb,
  active=true,
  x=flr(x),
  y=flr(y),
  w=1,
  h=1,
  startx=x,
  starty=y,
  target=target,
  targetx=target.x+4,
  targety=target.y+3,
  distance=0,
  moves=0,
  threaddistance=0,
  scorevalue=25
 }
 
 -- thread?
 -- note: threading will only occur if there are less than 8 enemies on screen at thread time
 if not threaded and not fromflyer and rnd(100)<15 then
  s.threaddistance=0.25+rnd(0.5)
 end
 
 -- calculate length from start to finish
 s.length=sqrt(abs(s.startx-s.targetx)^2+abs(s.starty-s.targety)^2)
 
 -- calculate speed to lerp
 s.speed=((100/levelspeed)/60)*(1/s.length)
 
 -- add
 add(enemies,s)
end

function enemy_addsmartbomb(x,y)
 -- defaults
 if (x==nil) x=4+flr(rnd(120))
 if (y==nil) y=0
 
 -- decrease counters
 levelsmartbombs-=1
 
 -- find a target
 local target=entity_getnexttarget()
 
 local s={
  type=et_smartbomb,
  active=true,
  x=x,
  y=y,
  w=3,
  h=3,
  target=target,
  targetx=target.x+4,
  targety=target.y+3,
  scorevalue=125
 }
 
 -- speed
 --s.speed=0.25*(5/levelspeed)
 s.speed=0.4*(5/levelspeed)

 -- sfx (looped)
 gsfx(sfx_smartbomb,2)

 -- add
 add(enemies,s) 
end

function enemy_addflyer()
 local dir=iif(rnd(1)<0.5,1,-1)
 local t=iif(rnd(1)<0.5,et_plane,et_sattelite)
 
 -- altitude is based on level
 local ymin=min(30,10+level*2)
 local ymax=ymin+30

 local s={
  type=t,
  active=true,
  dir=dir,
  x=iif(dir==-1,129,-8),
  y=ymin+rnd(ymax-ymin),
  w=6,
  h=6,
  scorevalue=100,
  sprite=iif(t==et_plane,23,24),
  speed=iif(t==et_plane,0.2,0.3),
  bombs=flr(rnd(min(flr(level/3),3)))
 }
 
 -- sfx (looped)
 gsfx(sfx_flyer,3)
 
 -- add
 add(enemies,s) 
end

function enemy_draw(s)
 if s.type==et_bomb then
  -- ====
  -- bomb
  -- ====
  entity_drawmissiletrail(s,8)
 elseif s.type==et_smartbomb then
  -- ==========
  -- smart bomb
  -- ==========
  spr(22,s.x,s.y)
 elseif s.type==et_plane or s.type==et_sattelite then
  -- =====
  -- flyer
  -- =====
  spr(s.sprite,s.x,s.y,1,1,s.dir==-1)
 end
end

function enemy_update(s)
 if s.type==et_bomb then
  -- ====
  -- bomb
  -- ====
  if s.distance!=1 then
   -- move towards target
   s.distance=min(s.distance+s.speed,1)
   s.x=lerp(s.startx,s.targetx,s.distance)
   s.y=lerp(s.starty,s.targety,s.distance)
   
   -- thread
   -- note: must still respect max 8 enemies limit
   if s.threaddistance>0 and s.distance>s.threaddistance then
    s.threaddistance=0
    if s.y<60 then
     for i=1,1+flr(rnd(3)) do
      if (#enemies<8) enemy_addbomb(s.x,s.y,true)
     end
    end
   end
   
   s.moves+=1
  else
   -- destroy target
   explosions_add(s.x,s.y)
   s.active=false
   s.target:destroy()
  end 
 elseif s.type==et_smartbomb then
  -- ==========
  -- smart bomb
  -- ==========
  local dy=s.targety-s.y
  local dx=(s.targetx-s.x)/dy
 
  if s.y>=s.targety then
   -- destroy target
   s.active=false
   
   if abs(s.x-s.target.x)<8 then
    s.target:destroy()
   else
    explosions_add(s.x,s.y)
   end
  else
   -- avoid explosions
   local smartmoves=0
   
   for e in all(explosions) do
    local disty=abs(e.y-(s.y+s.h/2))

    -- only avoids if close vertically 
    --if disty<min(e.r+4,10) then
    if disty<min(e.r+3,10) then
     local distx=e.x-(s.x+s.w/2)
     
     --if abs(distx)<e.r+4 then
     if abs(distx)<e.r+3 then
      local movedist=s.speed*-sgn(distx)*1.1
      smartmoves+=movedist      
      s.x+=movedist
      if (smartmoves>=s.speed) break
     end
    end
   end

   -- fall (slow descent if being smart)
   s.y+=s.speed*iif(smartmoves>0,-0.4,1)
   
   -- home in on target
   if (not smartmove) s.x+=mid(-0.5,s.speed*dx,0.5)
  end
 elseif s.type==et_plane or s.type==et_sattelite then
  -- =====
  -- flyer
  -- =====
  s.x+=s.dir*s.speed
  
  if s.x<-32 or s.x>160 then
   s.active=false
  else
   -- drop bomb?
   -- note: only very rarely can thread
   if s.x>8 and s.x<120 and s.bombs>0 and rnd(mid(80,200-levelresolved*10,200))<1 and #enemies<8 then
    enemy_addbomb(flr(s.x+4),flr(s.y+4),nil,rnd(10)<8)
    s.bombs-=1
   end
  end
 end
end


-- entity
function entity_setstate(s,st,c)
 s.state=st
 s.statecount=c or 0
end

function entity_drawmissiletrail(s,c)
 -- must draw full line and clip otherwise we get pixel shifting as line gets longer
 local cx,cy,cw,ch

 -- line
 if s.startx<s.targetx then
  cx=0
  cw=s.x+2
 else
  cx=s.x-2
  cw=127
 end
 if s.starty<s.targety then
  cy=0
  ch=s.y+1
 else
  cy=s.y
  ch=127
 end 
 clip(cx,cy,cw,ch)
 line(s.startx,s.starty,s.targetx,s.targety,c)
 clip()
  
 -- pointer to destination for bombs
 --[[
 if s.starty<s.targety then
  local x,y=s.x,s.y
  for i=2,25-s.moves/4 do
   pset(x+0.5,y+0.5,2)
   x=lerp(s.startx,s.targetx,s.distance+i/50)
   y=lerp(s.starty,s.targety,s.distance+i/50)
  end
 end
 ]]--
 
 -- tip
 pset(s.x+0.5,s.y+0.5,4)
end

function entity_getnexttarget()
 nexttarget=(nexttarget+1)%6
 return targets[1+nexttarget]
end


-- player
function player_create()
 local s={
  active=true,
  w=tile_size,
  h=tile_size,
  input={index=0},
  score=longnum_create()
 }

 return s
end

function player_resetlevel(s)
 s.visible=true
 s.x=64
 s.y=56
 
 s.demopausecounter=0

 entity_setstate(s,ps_normal)
end

function player_draw(s)
 -- active?
 if (not s.visible) return
 
 -- demo mode level complete?
 if (state==gs_demo and #enemies==0 and #explosions==0) return
 
 spr(6,s.x-2,s.y-2) 
end

function player_update(s)
 -- input
 local i=s.input
 input_update(i)
 
 if state==gs_demo then
  -- demo mode
  if #enemies>0 and s.demopausecounter<30 then
   local e=enemies[1]
   local tx,ty
   
   if e.type==et_bomb then
    tx,ty=lerp(e.startx,e.targetx,e.distance+0.07),lerp(e.starty,e.targety,e.distance+0.07)
   else
    tx,ty=e.x+e.dir*16,e.y
   end

   -- move
   local speed=0.4+level/5
   s.x=move(s.x,tx,speed)
   s.y=move(s.y,ty,speed)
   
   -- fire?
   if s.demopausecounter==0 then
    if abs(s.x-tx)<3 and abs(s.y-ty)<3 then
     if s.x<43 then
      base_fire(bases[1],s.x,s.y,false)
     elseif s.x<86 then
      base_fire(bases[2],s.x,s.y,true)
     else
      base_fire(bases[3],s.x,s.y,false)
     end
     
     s.demopausecounter=60
    end
   end
  end
  
  if (s.demopausecounter>0) s.demopausecounter-=1  
 else
  -- mouse/trackball
  if supports_lockedmouse then
   s.x+=i.mousemovedx/11
   s.y+=i.mousemovedy/11
  elseif i.mousemoved then
   s.x=i.mousex
   s.y=i.mousey
  end
  if (i.right) s.x+=2
  if (i.left) s.x-=2
  if (i.up) s.y-=2
  if (i.down) s.y+=2
  
  -- fire?
  if gamestate==s_playing then
   if (lastkey=="a") base_fire(bases[1],s.x,s.y,false)
   if (lastkey=="s") base_fire(bases[2],s.x,s.y,true)
   if (lastkey=="d") base_fire(bases[3],s.x,s.y,false)
   if i.fire1 or i.mouseclick then
    -- controller firing is always from center base
    if bases[2].missiles<4 then
     if bases[1].missiles>bases[3].missiles then
      bases[2].missiles+=1
      bases[1].missiles-=1
     elseif bases[3].missiles!=0 then
      bases[2].missiles+=1
      bases[3].missiles-=1
     end
    end
    base_fire(bases[2],s.x,s.y,false,true)
   end
  end
 end

 -- contrain player position
 s.x=mid(s.x,0,127)
 s.y=mid(s.y,0,104)
 
 -- counters
 s.statecount+=1
end

function player_scoreadd(s,v)
 if(state==gs_demo) return
 
 -- score multiplier
 v*=scoremultiplier
 
 -- bonus city?
 if machinemode==mm_arcade then
  bonusscore+=v
  if bonusscore>=10000 then
   bonusscore-=10000
   bonuscities+=1
  end
 end
 
 s.score:add(v)
end


-- base
function base_create(index,x,y)
 local s={
  index=index,
  x=x,
  y=y,
  w=7,
  h=1,
  destroy=base_destroy
 }
 
 base_reset(s)

 return s
end

function base_reset(s)
 s.active=true
 s.missiles=10

 entity_setstate(s,cs_normal)
end

function base_draw(s)
 local x=s.x+3
 
 for i=1,s.missiles do
  spr(7,x+({0,-2,2,-4,0,4,-6,-2,2,6})[i],s.y+({0,3,3,6,6,6,9,9,9,9})[i])
 end
 
 if s.missiles==0 then
  print("out",x-4,122,1)
 elseif s.missiles<4 then
  print("low",x-4,122,1)
 end
end

function base_update(s)
 -- active?
 s.active=s.missiles>0
end

function base_fire(s,targetx,targety,fast,dumb)
 if s.missiles>0 then
  gsfx(sfx_fire)
  s.missiles-=1
  missilecount-=1
  
  missile_add(s,targetx,targety,fast,dumb)
 else
  gsfx(sfx_nofire)
 end
end

function base_destroy(s)
 if s.active then
  s.active=false
  missilecount-=s.missiles
  s.missiles=0
  explosions_add(s.x+s.w/2,s.y+s.h/2,false)
  shakecount=5
 end
end


-- city
function city_create(x,y)
 local s={
  x=x,
  y=y,
  w=8,
  h=8,
  destroy=city_destroy
 }
 
 city_reset(s)

 return s
end

function city_reset(s)
 s.active=true
 citycount+=1

 entity_setstate(s,cs_normal)
end

function city_draw(s)
 -- active?
 if (not s.active or not s.visible) return

 spr(8,s.x,s.y) 
 
 --if (s.targetted) rect(s.x,s.y,s.x+s.w-1,s.y+s.h-1,8)
end

function city_update(s)
 -- counters
 s.statecount+=1
end

function city_destroy(s)
 if s.active then
  s.active=false
  citycount-=1
  shakecount=5
 end
 
 explosions_add(s.x+s.w/2,s.y+s.h/2,false,true) 
end



-- missile
function missile_add(frombase,targetx,targety,fast,dumb)
 local s={
  active=true,
  startx=frombase.x+4,
  starty=frombase.y-1,
  x=frombase.x,
  y=frombase.y,
  w=1,
  h=1,
  targetx=targetx,
  targety=targety,
  distance=0,
 }
 
 -- calculate length from start to finish
 s.length=sqrt(abs(s.startx-s.targetx)^2+abs(s.starty-s.targety)^2)
 
 -- calculate speed to lerp
 s.speed=1.7*(1/s.length)
 if(fast) s.speed*=2.1 -- middle base fires faster
 if(dumb) s.speed*=1.4 -- dumb, i.e., using mouse button or x
 
 add(missiles,s)
end

function missile_update(s)
 if s.distance!=1 then
  -- move towards target
  s.distance=min(s.distance+s.speed,1)
  s.x=lerp(s.startx,s.targetx,s.distance)
  s.y=lerp(s.starty,s.targety,s.distance)
 else
  -- explode
  explosions_add(s.x,s.y,true)
  s.active=false
 end
end

function missile_draw(s)
 if s.distance!=1 then
  -- move towards target
  pal(7,rainbowcolour1)
  spr(33,s.targetx-1,s.targety-1)
  pal(7,7)
 
  entity_drawmissiletrail(s,1)
 end
end


-- explosion
function explosions_add(x,y,player,startlarge)
 local s={
  active=true,
  x=x,
  y=y,
  player=player,
  r=1.5,
  maxr=0,
  d=0.25,--0.15,--5,
  c=7,
  pause=0
 }
 
 -- start large, e.g. to obscure city?
 if (startlarge) s.r=4
 
 add(explosions,s)
 
 -- sfx
 -- note: always on the same channel to stop the sound becomming too messy
 gsfx(iif(time()%2<1,sfx_explode1,sfx_explode2),1)
end

function explosion_update(s)
 -- expand and contract
 if s.pause>0 then
  s.pause-=1
 else
  s.r+=s.d
  if (s.r>s.maxr) s.maxr=s.r
  if s.r>8 and s.d>0 then
   s.d*=-0.65
   s.pause=12
  elseif s.r<=0 then
   s.active=false
  end
 end

 -- hit enemies?
 for e in all(enemies) do
  if e.active then
   if rectoverlapscircle(e,s) then
    explosions_add(e.x+e.w/2,e.y+e.h/2)
    e.active=false
    
    -- score
    player_scoreadd(player,e.scorevalue)
   end
  end
 end
end

function explosion_draw(s)
 if (s.y<100) circfill(s.x,s.y,5,0)--s.maxr,0)
 circfill(s.x,s.y,s.r,rainbowcolour1)
end

-->8
-- helper

function dsetstr(pos,s)
 for i=1,#s do
  dset(pos,ord(sub(s,i,i)))
  pos+=1
 end
 
 return #s
end

function dgetstr(pos,l)
 local s=""
 
 for i=1,l do
  s=s..chr(dget(pos))
  pos+=1
 end
 
 return s
end

function gsfx(s,c)
 if (state==gs_game) sfx(s,c)
end

function lerp(a,b,t) 
 return a*(1-t)+b*t
end

function kb(k)
 if k==nil then
  if stat(30) then
   return stat(31)
  else
   return ""
  end
 else
  return stat(30) and stat(31)==k
 end
end

function iif(c,t,f)
 if c then
  return t
 else
  return f
 end
end

function move(c,d,s)
 s=s or 1
 if (c<d) return min(c+s,d)
 if (c>d) return max(c-s,d)
 return c
end

function printc(s,y,c,shad,sc)
 -- detect wide characters
 local offx=0
 for i=1,#s do
  local o=ord(sub(s,i,i))
  if o>134 then
   offx+=3
  elseif o<20 then
   offx-=4
  end
 end

 local x=64-offx-#s*2
 if shad then
 	prints(s,x,y,c,sc)
 else
	 ? s,x,y,c
	end
end

function printcw(s,y,c,shad,sc)
 -- detect wide characters
 local offx=0
 for i=1,#s do
  local o=ord(sub(s,i,i))
  if o>134 then
   offx+=4
  elseif o<20 then
   offx-=8
  end
 end

 local x=64-offx-#s*4
 if shad then
 	prints("\^w"..s,x,y,c,sc)
 else
	 ? "\^w"..s,x,y,c
	end
end

function prints(s,x,y,c,sc)
 for y1=-1,1 do
  for x1=-1,1 do
   ? s,x+x1,y+y1,sc or 0
  end
 end

	? s,x,y,c
end

function rectsoverlap(e1,e2,e1offsetx,e1offsety)
 if (e1offsetx==nil) e1offsetx=0
 if (e1offsety==nil) e1offsety=0
 return (e1.x+e1offsetx)<e2.x+e2.w and e2.x<e1.x+e1.w+e1offsetx and (e1.y+e1offsety)<e2.y+e2.h and e2.y<e1.y+e1.h+e1offsety
end

function rectoverlapscircle(r,c)
 local cx=abs(c.x-r.x-(r.w/2))
 local xdist=(r.w/2)+c.r
 if (cx>xdist) return false
 
 local cy=abs(c.y-r.y-r.h/2)
 local ydist=(r.h/2)+c.r
 if (cy>ydist) return false
 
 if (cx<=r.w/2 or cy<= r.h/2) return true
 
 local xcornerdist=cx-r.w/2
 local ycornerdist=cy-r.h/2
 local xcornerdistsq=xcornerdist^2
 local ycornerdistsq=ycornerdist^2
 local maxcornerdistsq=c.r^2
 
 return xcornerdistsq+ycornerdistsq<=maxcornerdistsq
end

function pad0(n,l)
 local s="0000000000"..n
 return sub(s,#s-l+1)
end


-- long number
function longnum_create(v)
 local s={
  low=0,
  high=0,
  
  add=function(self,v)
   self.low+=v
   if self.low>10000 then
    self.high+=1
    self.low-=10000
   end
  end,
  
  compareto=function(self,b) 
   if self.high==b.high and self.low==b.low then
    return 0
   elseif self.high>b.high or (self.high==b.high and self.low>b.low) then
    return 1
   else
    return-1
   end
  end,
  
  tostring=function(self)
   local s=""
   if (self.high!=0) s=tostr(self.high)
   s=s..pad0(self.low,4)
   
   -- remove leading zeros
   while(#s>1 and sub(s,1,1)=="0") do
    s=sub(s,2)
   end
   
   return s
  end,
  
  dset=function(self,pos)
   dset(pos,self.low)
   dset(pos+1,self.high)
   
   return 2
  end,
  
  dget=function(self,pos)
   self.low=dget(pos)
   self.high=dget(pos+1)
  end,
  
  hasvalue=function(self)
   return self.low!=0 or self.high!=0
  end
 }
 
 -- default value
 if (v) s:add(v)
 
 return s
end


-- input
function input_update(s)
 -- direction
 s.up=btn(2)
 s.down=btn(3)
 s.left=btn(0)
 s.right=btn(1)
 s.fire1=btnp(5)
 
 
 s.mousex=mid(1,stat(32)-1,128)
 s.mousey=mid(1,stat(33)-1,128)
 s.mousedown=band(stat(34),1)==1
 s.mouseclick=s.old_mousedown and not s.mousedown-- and abs(s.mousedownx-s.mousex)<3 and abs(s.mousedowny-s.mousey)<3
 --s.mousedown_right=band(stat(34),2)==2
 
 --[[
 if not s.mousedown then
  s.mousedownx=-1
  s.mousedowny=-1
 elseif not s.old_mousedown then
  s.mousedownx=s.mousex
  s.mousedowny=s.mousey
 end
 ]]--
 
 s.mousemoved=(s.old_stat32!=nil and (s.old_stat32!=stat(32) or s.old_stat33!=stat(33)))
 
 s.old_mousedown=s.mousedown
 s.old_stat32=stat(32)
 s.old_stat33=stat(33)
 
 -- locked mouse details
 s.mousemovedx=stat(38)
 s.mousemovedy=stat(39)
end
-->8
-- effects

-- transition
transition={
 active=false,
 value=0,
 
 start=function(self) 
  self.active=true
  self.value=128
 end,
 
 draw=function(self)
  if self.active then
   fillp(0b0101101001011010.1)
   circfill(64,64,self.value,0)
   fillp()
   if (self.value>8) circfill(64,64,self.value-8,0)
  end
 end,
 
 update=function(self)
  if self.active then
   self.value-=3
   if (self.value<=0) self.active=false
  end 
 end
}

function glitchrect(x,y,w,h,intensity)
 if (intensity==nil) intensity=10
 
 for y2=y,y+h-1 do
  for i=1,intensity do
   local x2=x+flr(rnd(w))
   local c=pget(x2,y2)
   --pset(x2+1,y2,c)
   line(x2-1,y2,x2+1,y2,c)
  end
 end
end
-->8
-- levels
function pallevel(level)
--level=13
 local levelmod=1+(level-1)%20--level-1
 --local div2=levelmod\2
 
 local bg=({0,0,0,0,0,0,0,0,0,0,
            140,140,142,142,136,136,10,10,138,138})[levelmod]
 local ground=({10,10,10,10,140,140,140,140,137,137,
                10,10,10,10,140,140,140,140,137,137})[levelmod]
 
 local bomb=({8,8,11,11,10,10,8,8,137,137,
              10,10,141,141,138,138,140,140,9,9})[levelmod]

 -- missile (also city, missile dump)
 local missile=({140,140,140,140,11,11,11,11,140,140,
                 129,129,136,136,10,10,137,137,139,3})[levelmod]

 local cityalt=({12,12,12,12,10,10,10,10,10,10,
                 14,14,8,8,142,137,8,8,8,8})[levelmod]
                 
 --if (level>=20 and level<40) bomb,missile=missile,bomb

 pal(0,bg,1)
 pal({missile,trail,3,4,5,6,7,bomb,9,ground,11,cityalt,13,14,15},1)
 poke(0x5f2e,1)
end
-->8
-- 2d utils

-- @gamecactus
-- https://www.lexaloffle.com/bbs/?pid=64614
function draw_polygon148(points,c)
    local xl,xr,ymin,ymax={},{},129,0xffff
    for k,v in pairs(points) do
        local p2=points[k%#points+1]
        local x1,y1,x2,y2=v.x,flr(v.y),p2.x,flr(p2.y)
        if y1>y2 then
            y1,y2,x1,x2=y2,y1,x2,x1
        end
        local d=y2-y1
        for y=y1,y2 do
            local xval=flr(x1+(x2-x1)*(d==0 and 1 or (y-y1)/d))
            xl[y],xr[y]=min(xl[y] or 32767,xval),max(xr[y] or 0x8001,xval)
        end
        ymin,ymax=min(y1,ymin),max(y2,ymax)
    end
    for y=ymin,ymax do
        rectfill(xl[y],y,xr[y],y,c)
    end
end

function make_octagon(x,y,size,r)
 local obj={}
 for i=0,7 do
  add(obj,{x=x+sin(i/8+r)*size,y=y+cos(i/8+r)*size})
 end

 return obj
end

-->8
-- intermissions

-- ###########
-- level clear
-- ###########
int_levelclear={
 active=false,
 
 start=function(self)
  local s=self 
  
  s.active=true
  s.counter=0
  s.citycounter=0
  s.missilecounter=0
  s.bonuscity=false
  
  -- sfx
  --sfx(sfx_levelcleared)
 end,
 
 draw=function(self)
  local s=self
  
  -- arena
  game_draw_arena()
  game_draw_scorepanel()
  
  -- text
  print("\^wbonus points",20,32,1)
  
  -- missile bonus
  if s.missilecounter>0 then
   local x=10
   print("\^w"..(s.missilecounter*5*scoremultiplier),x,48,8)
   for i=0,s.missilecounter-1 do
    spr(7,x+34+i*4,49)
   end
  end
  
  -- cities bonus
  if s.citycounter>0 then
   local x=10
   print("\^w"..(s.citycounter*100*scoremultiplier),x,64,8)
   for i=0,s.citycounter-1 do spr(8,x+34+i*9,61) end
  end
  
  -- bonus city
  if (s.bonuscity) print("\^wbonus city",24,80,1)
  
 end,
 
 update=function(self)
  local s=self 
  
  -- counters
  if s.missilecounter<missilecount and s.counter%4==1 then
   s.missilecounter+=1
   player_scoreadd(player,5)
   
   -- sfx
   sfx(sfx_blop)
  end
  
  if s.missilecounter==missilecount and s.citycounter<citycount and s.counter%15==1 then
   s.citycounter+=1
   player_scoreadd(player,100)
   
   -- hide next city
   for c in all(cities) do
    if c.active and c.visible then
     c.visible=false
     break
    end
   end
   
   -- sfx
   sfx(sfx_blop)
  end
  
  if s.counter==150 and bonuscities>0 and citycount<6 then
   s.bonuscity=true
   bonuscities-=1
   
   -- sfx
   sfx(sfx_bonuscity)
  end
  
  s.counter+=1
  
  -- done?
  if s.counter>=300 then
   s.active=false
   
   -- replace random city
   if s.bonuscity then
    while(true) do
     local i=1+flr(rnd(6))
     if not cities[i].active then
      cities[i].active=true
      citycount+=1
      break
     end
    end
   end
  end
 end
}


-- #########
-- game over
-- #########
int_gameover={
 active=false,
 
 start=function(self)
  local s=self 
  
  s.active=true
  s.counter=0
  s.d=1
  s.r=0
  s.paused=0
  
  pallevel(1)
  
  -- sfx
  --gsfx(sfx_theend)
 end,
 
 draw=function(self)
  local s=self
  
  cls(8)
  
  -- explosion
  if s.paused>0 then
   s.paused-=1
  else
   s.r+=0.375*s.d
   
   if s.r>=58 then
    s.d=-2
    s.paused=100
   end
  end
  if (s.r>0) draw_polygon148(make_octagon(64,64,s.r,(1/360)*90),4)
  
  -- the end
  if s.d<0 then
   camera(-12,-52)
   for y=1,24 do
    tline(0,y,108,y,8,(y-1)/24,1/24)
   end
   camera()
  end
  
 end,
 
 update=function(self)
  local s=self 
  
  -- sfx
  if (s.r>1 and s.counter%30==10 and rnd(1)<0.8) gsfx(sfx_explode1)
  
  -- done?
  if s.d<0 and s.r<=0 and s.counter>=360 then
   s.active=false
  end
  
  -- counter
  s.counter+=1  
 end
}


-- ###########
-- title story
-- ###########
int_title={
 
 start=function(self)
  local s=self 
  
  self.active=true
  s.circles={}
  s.counter=0
  srand(1)
  
  -- sfx
  sfx(sfx_startup)
 end,
 
 draw=function(self) 
  local s=self
  
  if (not s.active) return
  
  cls(0)
  
  -- logo
  if s.counter>120 then
   pal(11,rainbowcolour2)
  else
   pal(11,8)
  end
  drawlogo(32)
  pal(11,11)

  -- circles
  for c in all(s.circles) do
   circfill(c.x,c.y,c.r,c.c)
  end
  
  -- controls
  if (flash) printc("ó start",104,7,true)
  
 end,
 
 update=function(self)
  local s=self
  
  if (not s.active) return

  -- circles
  if s.counter>120 and s.counter%2==1 and #s.circles<160 then
   add(s.circles,{x=rnd(128),y=20+rnd(82),r=1,maxr=2+rnd(4),ttl=0})
  end
  
  for c in all(s.circles) do
   c.r=min(c.r+0.5,c.maxr)
   c.ttl+=1
   c.c=rainbowcolour1
   if (c.ttl>=15) c.c=0
  end  
 
  -- counter
  s.counter+=1
  
  -- complete?
  if (s.counter>=540) s.active=false
 end
}

-->8
-- high score table

function highscoretable_create(name,items)
 local s={
  name=name,
  items={}
 }

 -- parse items
 for i=1,#items,2 do
  local item={name=items[i],value=longnum_create(items[i+1])}
  add(s.items,item)
 end
 
 -- is this value a high score?
 s.ishighscore=function(self,v)
  for i in all(self.items) do
   if (i.value:compareto(v)==-1) return true
  end
  
  return false
 end
 
 -- add a score to the table and return the 1-based index
 s.addscore=function(self,n,v)
  local newitem={name=n,value=v}
  local foundindex=-1
  
  for i=1,#self.items do
   if self.items[i].value:compareto(v)==-1 then
    foundindex=i
    add(self.items,newitem,i)
    break
   end
  end
  
  -- truncate
  if (foundindex!=-1) del(s.items,s.items[#s.items])
 
  return foundindex
 end
 
 -- save to data
 s.dset=function(self,pos)
  local l=0
  
  for i in all(self.items) do
   dsetstr(pos,i.name)
   i.value:dset(pos+3)   
   pos+=5
   l+=5
  end
  
  return l
 end
 
 -- get from data
 s.dget=function(self,pos)
  local l=0
  
  for i in all(self.items) do
   i.name=dgetstr(pos,3)  
   i.value:dget(pos+3)
   pos+=5
   l+=5
  end
  
  return l
 end
 
 -- printh
 --[[
 s.printh=function(self)
  for i in all(self.items) do
   printh(i.name..":"..i.value:tostring())
  end
 end
 ]]--

 return s
end
__gfx__
000000000011223300000000000000000000000000000000001000000100000000000000aaaaaaaa0000000aa00000000000000aa000000000000000a000000a
000000000011223300000000000000000000000000000000001000001110000000000000aaaaaaaa000000aaaa000000000000aaaa00000000000000aa0000aa
007007004455667700777707777007770077770000077770111110001010000001000000aaaaaaaa00000aaaaaaaaaaaaaaaaaaaaaa0000000000000aaaaaaaa
000770004455667707707700770077000770770000070070001000000000000001100100aaaaaaaa0000aaaaaaaaaaaaaaaaaaaaaaaa000000000000aaaaaaaa
000770008899aabb07777700770077000770770770777770001000000000000001c10110aaaaaaaa000aaaaaaaaaaaaaaaaaaaaaaaaaa000000aa000aaaaaaaa
007007008899aabb07700000770077000770770000770070000000000000000011c1c1c0aaaaaaaa00aaaaaaaaaaaaaaaaaaaaaaaaaaaa0000aaaa00aaaaaaaa
00000000ccddeeff0770000777707777077770000077777000000000000000001cccccc1aaaaaaaa0aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa00aaaaaa0aaaaaaaa
00000000ccddeeff000000000000000000000000000000000000000000000000cc1c11ccaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
00000aa000aa0000000000000000000000000000000000000400000000000000000000000bb000bb0bbbbbb000bbbbb000bbbbb00bbbbbb00bb000000bbbbbb0
0000aaaaaaaaa000000000000000000000000000000000004840000000880000400000040bbb0bbb000bb0000bb000bb0bb000bb000bb0000bb000000bb00000
000aaaaaaaaaaa00000000000000000000000000000000000400000080088000080880800bbbbbbb000bb0000bb000000bb00000000bb0000bb000000bb00000
000aaaaaaaaaaa00000000000000000000000000000000000000000088888880008484000bbbbbbb000bb00000bbbbb000bbbbb0000bb0000bb000000bbbbb00
00aaaaaaaaaaaaa0000000000000000000000000000000000000000088888888008888000bb0b0bb000bb000000000bb000000bb000bb0000bb000000bb00000
0aaaaaaaaaaaaaaa000000000000000000000000000000000000000000888000080880800bb000bb000bb0000bb000bb0bb000bb000bb0000bb000000bb00000
0aaaaaaaaaaaaaaa0000000000000aaaaaaaa000000000000000000088880000400000040bb000bb0bbbbbb000bbbbb000bbbbb00bbbbbb00bbbbbb00bbbbbb0
aaaaaaaaaaaaaaaaaaaaaaaa000aaaaaaaaaaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000888007070000000000000000000000000000000000000000000000000000000000000000bbbb000bbbbb00bb000bb0bb000bb000bbb000bb000bb0bbbbb00
00088800070000000000000000000000000000000000000000000000000000000000000000bb00bb0bb000bb0bbb0bbb0bbb0bbb00bb0bb00bbb00bb0bb00bb0
0088888070700000000000000000000000000000000000000000000000000000000000000bb000000bb000bb0bbbbbbb0bbbbbbb0bb000bb0bbbb0bb0bb000bb
0008880000000000000000000000000000000000000000000000000000000000000000000bb000000bb000bb0bbbbbbb0bbbbbbb0bb000bb0bbbbbbb0bb000bb
0000800000000000000000000000000000000000000000000000000000000000000000000bb000000bb000bb0bb0b0bb0bb0b0bb0bbbbbbb0bb0bbbb0bb000bb
00000000000000000000000000000000000000000000000000000000000000000000000000bb00bb0bb000bb0bb000bb0bb000bb0bb000bb0bb00bbb0bb00bb0
000000000000000000000000000000000000000000000000000000000000000000000000000bbbb000bbbbb00bb000bb0bb000bb0bb000bb0bb000bb0bbbbb00
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000006666600888880800808888000088880800080888000000001111000
00000000000000000000000000000000000000000000000000000000000000000000000066666660008000800808000000080000880080800800000017777100
00000000000000000000000000000000000000000000000000000000000000000000000066666660008000800808000000080000808080800080000017777710
00000000000000000000000000000000000000000000000000000000000000000000000066666660008000888808880000088800800880800080000017777771
00000000000000000000000000000000000000000000000000000000000000000000000066666660008000800808000000080000800080800080000017777771
00000000000000000000000000000000000000000000000000000000000000000000000056666650008000800808000000080000800080800800000017777771
00000000000000000000000000000000000000000000000000000000000000000000000055555550008000800808888000088880800080888000000017777771
00000000000000000000000000000000000000000000000000000000000000000000000005555500000000000000000000000000000000000000000001111110
77777777777777777000000000000777777000000000000000000777777700000000000000000000000000000000000000000000000000000000000000000000
70000000000000007000000000000777707000000000000000007777777770000000000000000000000000000000000000000000000000000000000000000000
70070070070777007000000000077777707770000000000000007007770070000000000000000000000000000000000000000000000000000000000000000000
70770070070700707000000000070777707070000000000000007007770070000000000000000000000000000000000000000000000000000000000000000000
70070070070700707000000000070777707070000000000000077007770077000000000000000000000000000000000000000000000000000000000000000000
70070070070777007000000000007777077700000000000000077770707777000000000000000000000000000000000000000000000000000000000000000000
70070070070700007000000000000077770000000000000000007777777770000000000000000000000000000000000000000000000000000000000000000000
70777077770700007000000000000007700000000000000000000070707000000000000000000000000000000000000000000000000000000000000000000000
70000000000000007000000000000007700000000000000000000707070700000000000000000000000000000000000000000000000000000000000000000000
77777777777777777000000000000077070000000000000000000777777700000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000777707000000000000000000077777000000000000000000000000000000000000000000000000000000000000000000000
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
0000000000000000e502c70202028612320202021286d286d202373702c702020286363232320202023232320202020302860237020237c786d2d28636323232
0000000000000000860237020237c786020286020202323232360232323236860202373702c7860202030202323232e502323232020202863602c78636323232
0000000000000000023232320202860237023702c786363232320232320202023232023232320202860237370202c78636323232e50202023232320202860237
0000000000000000320202163202023232320202863602c786363232320202163202023232320202863204323286c78636023232020202323232020202323232
0000000000000000c716328632323202024232420202323232d2d2d2320232023286c73202420232860212163246323202323286c73202320232860202023232
000000000000000086c702c78646e5e5e53602c78602620302863232328602024646d202028632323286c7860202023286163286020246d2020286163286c786
000000000000000032328632323602323286323232863286c786020232328632863232328632320232323202323286323232863286c786020202328632323286
000000000000000032323286c786368632323286160232863202168632323286c786020202328632863232328632320232863202323286323232863286c78602
0000000000000000328632320232863202323286323232863286c786020232328632323286160232863202168632323286c78602020232863232328616023286
0000000000000000c786368602863232328632320232863202323286323232863286c732860202863232863232328602020232863202020286323232863286c7
00000000000000000202023232863232020202420232323286c71212121232020286c7e5020202033637e536023237c732320202028632323236023702023202
00000000000000003232863632371202323232363237c736028602023202163202023236028632023237c702323712e50202123202023237c702323232361232
0000000000000000c7e5e53632020212320237c71602323202020262020216860232e50237c7e502861636028636028632323237c70286323202020286020202
0000000000000000420237c732860202023232320286323232e5423686328737c702860202423686360242028632323202020286020202c70212863232021632
00000000000000004202020203028636024202020286e502028602c73232320212860232323202021686020286323232c7e53686e53686020286020202c73602
00000000000000000202c7368636123237020237120202c702028616320232360232370202373236320202c70202863202020216320202023262373702320286
1632c786328632323202320202023286020232323286323202863202320232c786320202023202320202023286020202320286020202863232320232c7863202
0242320232023286123286020202863202020232c78632021632023286e53232328632021632c786320232023202320232323202023286323202028616860202
c786163202323232028616320202028632020232860202c78602023236023242860232021232860232864202c786020232020212023202320203023202428616
02c732863232328632020332023202320232020202320202863202033202c732860202328632024216320232020202163202023202c732860202328612020202
16320202023287323202c7163286e5e532360287020202c702020232323286323232e5020232323286323232020202c702323232020286360216360286020232
323202c7023236861202021286363202c70232323716e5e51637323202c702023237360286323232020232323286360237320202c787023237163286e5020286
163237320287c787040437262686020286262637040487c78702023702020242023202028602d6c787040437260404860402d2d202048626040437040487c702
020237e58602320202320286e537020202c70332023702328602620286323202023232860203d6c702163286168632020232861686163202c703363286323242
028632424232860242323286323603c7323202023232860232d2d2863242d6c73232320202028602021216020286020202323232c712323286e53686123232c7
e5e5e562e5020237c7023232863286123286123232328632323237c702020286023286323602860232863236028602320237c702323286323286323202328616
86323237123237c702028602370286360286020202860202863602860237c70202328602028632020232328602023286320232860202320286d202c702320286
0202860202d2023286020232323202023286323232860202c702328632023286323242328632863602320286020202328602c7020286320202328632d2863202
86d232863202020286023286328602c702028636861603323202860216020286328602c702328602d202328632d2020232020232863602d20286328602c70232
8602023202861602863202860286324232320286328602c70202860202863286d2d2d232320232860202868632d2d2d286328602c70232328602860202863632
8632023202861632868602c702020232323286d202864686d2d2d2323246d2860202c7e5e503e5e5020202c7121232e5e5020202c73262023202023202420202
023202860202024646d2d2c732020232420202028632024232d28602020286e5020202c7163286123203860202378602123202c7320202324286320202324202
32028602370286024232323242323202c732420232028632423632d28637020286023242164202c73232023232861232360286024232323242323202c7320242
32028632024232860232360286023242164202c732020202428632020232420232360286024232323242323202c71632861232360286023242164202c732d2d2
32028632d2d232020232360286e5020202c732d2d232028632d2d23202033236028612323232c7121232360286320202863202024232c732860232360232e502
028612323232c732860302020232024202028632360286320202023286024232c732c7e502033736023703e5e5c7040402040402020437020262020237040402
02040202260402c704020402040202040237028602370204020402040202040404020202c704020202040202040202378637020204020204040202260402c716
32873232320432861216020332320202c786d2e50202028602d20202d20242d24242328632323286c78602024216324232863242863202863202863232860202
3286c786024242163242328632040404878732863287324232323286c786424242163242328602423604040242020202420286c7863242124232868704043287
120404323286c786020204048742870404048604024287873202423204024204040486c73232860404424242040404863286323232041232323286c732028604
42424242420404860442e50242020202423286c73286123232328626040402163204043286c732860242024202420242028602163286324236024286c7121204
021686033286323716c78602d20203020203020203020203020202d20202d20202d20262d286c786320232324232324232324232324232320232320232320232
320286c78632320232320232320232320232d6c786023232023232023232023232023232023232023232023232023286c7863202323202323202323202323202
32320232320232320232320286c723c733c743c723c733c743c723c786023232423232423232423232423232423232423232423232423286c743c786e5e5e5e5
020286c732c7e502020237e5020237e5020202c703c736323637e5020237363236c736320404873286328726873286328704043236c736324242873286328736
873286328742423236c736323232020486320216023286040232323236c7e5020404860404360404860404e502c70202023204048704868604e5048686048704
0432020202c70202023242428704863232048704d6c70202023232320204863242428704d6c7e504048632323202040402323232860404e5c702023204048704
868602020226020202868604870404320202c70202324242870486e5e58604874242320202c70202323232020486e5e58604023232320202c702020303020486
86020262e50203038686040203020202c7168602861212323286028616c7323237e5e5e502020237323232c716323703360262e502033712c712323232378616
3286371216c736024236868702020287863602423602c702020286323236863232423232863632328636c786160202863202861632860232860202163286c786
360286323237123237323286e586c78602020302868702323732020287420232378702328602d6c7861242323732423232320232373242123286c78636023287
32371632873237328732e586c7873286e537e50237e586323232c78716863202371232323237023286323232878732c787420202328632323786320242324202
328637323286020232024232c73232420202860232328632028732870232863232028602320202d6c73232320202860202028612328602020286323602c71632
8632323286e502863232328612c762e5d2d236d2d202460232024203420242c703328602028604020242020486324232423202020232863287320286c7041632
04863202323286320232021686863232020286c70416320486023202328632d2d2023242323286023232d20286c7e50202860202028612323286020242020286
c78612878602020286d2d232023242323202023232023232c786320202328602328632024232028632420232323204040202323232c786324202320242328632
32023202863232324286e50242c78602163202860202320202863242323286d202420232863232c7863202863202023286020232033286323232428602323202
42863242c786324202320242878602020232328632423202028632428632023202c786021632028636328632020203328632868616c786320202320202328636
d28602420232868602323202020242c702324202320242328602020286024202320232863602863232c742123286020202860232023204868602863232028632
42c7e502028632020232023204020286020286323242863202c7620232030303033236423642e536c73202324632861216371632020202c70202323632863236
d236370202d20202d20202c702024236328632863232323716423232023232023232c732323236328632863242323716324232320232320232c7868636023286
32863202323736323242323202323202c786863602868632863232323736023232423232023232c78686e502028632020237e532324232320232c73232323632
32328632020237e502323242323202c72626040432323712328602023232423232c7e5e537324286320202028602020232320232c742e5020202328637320202
3202020286e502c7123232328616040412323286323286c7e502020286e5363236320286c742e5020286368687860202421632420286c71212121232878632c7
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
191a1b1c1d1e1f003a3b3c3d3e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
292a2b2c2d2e2f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a0f0d120000121011121314120a0f0d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0909090909090909090909090909090900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
01040000180501804018030180202b70029500276002670026600267002750027600287002b5002c6002e7002d6002970025500206001d70017500126000c7000760003700005000060000700005000060000700
630400003d6403c6403a64038640366303463032630306302f6302b62028620266202462022610206101e6001c60019600186001460013600106000f6000d6000c60009600076000070000700007000070000700
a908000030752247510e7312675130752247510e7312675130752247510e7312675130752247510e7312675130752247510e7312675130752247510e731267510070000700007000070000700007000070000700
0304000011670116701167011670116701267012670116701167012670126601166011660116601066010660116601166011650106500e6500d6300b630096300863006630046200362003620016200060001600
1a120000096700c6700e6700f6700f6700f6700e6700c6600b6600b6500c6600e6700f6700f6700d6700c6600b6600a6600b6500c6500c6600b66008650076500765006640086300a6400b650096400562003610
210c0008247201f731247201f731247201f731247201f73112700127011370115701197011b7011e7012170123701237011e701137010a7010370100701007010070100701007010070100701007010070100701
190900003154528545225452954522545265452b5453454521545255452254529545215452c545215452754520545285452c545235451f5452e5452b54524545205451c5452854532545225451c5452a5451a545
01040000147551675518755197551b7551d7551f7552175525755287552b7552f75532755367553a7553c7552b7553074533745347452c7252f72534725367252d725347153771537715347052d7050070500705
010100002453010515005051850500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505
01010000290501c02000005000001d000040000000000005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
01050000140571605718057190571b0571d0571f0572105725057280572b0572f05732057360573a0573c0572b0573004733047340472c0272f02734027360272d027340173701737017340072d0070000700007
010200003055500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505
1b1100000e5521552210542115220e5421552210532115220e5421552210532115220e532155121052211512135520c5220e54210522135420c5220e532105221f742187221a7321c7221f732187121a7221c712
031100000a752117220c7420e7220a742117220c7320e7220a742117220c7320e7220a732117120c7220e712137520e7221574216722137420e7221573216722137420e7221573216722137320e7121572216712
651100000251002521025310254102551025610257102571025710257102561025510254102531025210251109510095210953109541095510956109571095710957109571095610955109541095310952109511
651100000a5100a5210a5310a5410a5510a5610a5710a5710a5710a5710a5610a5510a5410a5310a5210a51107510075210753107541075510756107571075710757107571075610755107541075310752107511
631100001a3301a3301a3301a3301a3301a3301a3301a3301a3201a3201a3221a3221c3421c3321d3321d3321c3321c3321c3321c3321c3321c3221d3321d3321d3321d3321d3321d3221f3321f3321f3321f322
63110000213302133021330213302133221322163311633016330163301633016330163321633216322163220a3250a3250a3250a3250a3250a3250a3250a3250a3350a3350a3350a33516345163451635516355
63110000213352133521725217152933529335297252971528335283352872528715293352933529725297152233522335227252271529335293352972529715283352833528725287151d3351d3351d7251d715
0711000016325163251632516325223152231522315223150a3150a31516315223152e3253a325163251631513555135551355513555135551355513555135551555515555155551555516555165550a5650a565
c71100001a3351a3351a3351a3351a3351a3351a3351a3351a3251a3251a3251a3251c3451c3351d3351d3351c3351c3351c3351c3351c3351c3251d3351d3351d3351d3351d3351d3251f3351f3351f3351f325
671100000a7650a76516775167750a7650a76516775167750a7650a76516775167750a7650a765167751677507765077651377513775077650776513775137750776507765137751377507765077651377513775
c11100001a3351a3451a3451a3451a3451a3451a3451a3451a3351a3351a3351a3351c3551c3451d3451d3451c3451c3451c3451c3451c3451c3451a3451a3451a3451a3451a3451a34518345183451834518335
c1110000213452134521345213452134521335163451634516345163451634516345163451634516335163351f3351f3351f3351f3351f3351f33521335213352134521345213452134516355163551636516365
0111000002765027650e7750e77502765027650e7750e77502765027650e7750e77502765027650e7750e77509765097651577515775097650976515775157750976509765157751577509765097651577515775
631100001535015350153501534015340153401533015330153321532215322153121334013330113401132013350133501334013340133321333213322133121034010330103201134011330113201334013330
631100000e3500e3400e3320e3320e3220e312163501634016330163301632216322163221632216312163121c7001c700137001370015700157001870018700187001870020700207001b7001b7001d7001d700
311100001554215522165421652213542135221554215522115421152213542135221053210522115321152215532155221653216522135321352215532155221152211512135221351210522105121152211512
491100001a5421a5421a5421a5421a5321a5321a5321a5321a5221a5221a5221a5221a5121a5121a5121a51226511265112651126511265112651126511265112651226512265122651226512265122651226512
011000001805518055180551804518045180451803518035180351802518025180251801518015180151801518000180001800018000187001870018700187001870018700187001870018700187001870018700
1f130000091750915509175091550916509155151450913507175131550717507155071650715513145071350217502155021750e155021650e1550214502135111750515511175051551116511055131651f045
1f1300000917515155091750915509165091552114509135131750715507175071551f1650715513145071350e1750215526775021551a765021550e145021351d77505155111751d755051651d755131651f745
031300000433504325183551832517355173251835510355103351032518355183251735517325183550e3550e3350e32518355183251735517325183550c3350c3550c3251035511355103450e3450c3350e335
010a00000e7000e7000e7000e7001170011700117001170015700157001570015700187001870018700187000e7000e7000e7000e700117001170011700117001570015700157001570018700187001870018700
010a00001770017700177001770017700177001770017700177001770017700177001370013700137001370013700137001370013700137001370013700137001370013700137001370013700137001370013700
010a000013500135001350013500135001350013500135001a5001a5001a5001a5001a5001a5001a5001a50018500185001850018500185001850018500185001750017500175001750017500175001750017500
010a00001550015500155001550015500155001550015500155001550015500155001150011500115001150011500115001150011500115001150011500115001150011500115001150011500115001150011500
010a00000e7000e7000e7000e7001170011700117001170014700147001470014700187001870018700187000e7000e7000e7000e700117001170011700117001470014700147001470018700187001870018700
010a00000b7000b7000b7000b7000c7000c7000c7000c7000f7000f7000f7000f700137001370013700137000b7000b7000b7000b7000c7000c7000c7000c7000f7000f7000f7000f70013700137001370013700
010a00000b7000b7000b7000b7000c7000c7000c7000c70010700107001070010700137001370013700137000b7000b7000b7000b7000c7000c7000c7000c7001070010700107001070013700137001370013700
070400000b6720b6720b6720b6720c6720e67210672106720f6720e6720f6620d6620d6620d6620d6620f6620e6620d6620d6520d6520b6520a63209632076320763206632056220562204622026120060201602
610800082423034241242303424124230342412423034241112001120011200112001120011200112001120014200142001420014200142001420014200142001820018200182001820018200182001820018200
010a00001555215552155521554215542155421553215532155321552215522155221d7521d7521d7521d7421d7421d7421d7321d7321d7321d7221d7221d7221d7121d7121d7121d7121d7121d7121d7121d712
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011300001f7501f7222175021722287502872224750247221d7501d7222175021722247502472226750267221d7501d72220750207222475024722267502672224750247221c7201c71218720187120c7100c712
011300001c7221c7221c7221c7221c7221c7221c7221c7221872218722187221872218722187221872218722207222072220722207221a7221a7221a7221a7220c7220c7220c7220c7220c7220c7220c7220c722
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010a00002403523735210151f71523025217251f0151d715217151f7151d7151c7151f7151d7151c7151a7150c7350b73509715077150b7250972507715057150971507715057150471507715057150471502715
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011600000c7320c7221073210722137321372215732157220e7320e7221173211722157321572218732187221073210722137321372217732177221a7321a7221173211722157321572218732187221c7321c722
011600002d7322d7322d7222d7222d7122d7122b7322b7322b7322b7322b7222b7222b7222b7222b7122b7122b7122b7122b7122b7122b7122b7122b7122b7122973229722297222971228732287222872228712
011600002473224732247322473224722247222472224722247122471224712247122471224712247122471224012240122401224012240122401224012240120070200702007020070200702007020070200702
011600002173221732217222172221712217121f7321f7321f7321f7321f7221f7221f7221f7221f7121f7121f7121f7121f7121f7121f7121f7121f7121f7121d7321d7221d7221d7121c7321d7221c7221c712
0116000018745187351872518725187351872518715187150c0250c0250c0150c0150c0150c0150c0150c01518705187051870518705187051870518705187051870518705187051870518705187051870518705
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 0c 0e 43 44
00 0d 0f 43 44
00 0c 0e 43 44
00 0d 0f 43 44
00 0c 0e 10 44
00 0d 0f 11 44
00 0c 0e 12 44
00 0d 0f 13 44
00 0c 0e 19 44
00 0d 0f 1a 44
00 0c 0e 1b 44
00 0d 0f 1c 44
00 41 0e 18 44
00 41 0f 15 44
00 41 0e 18 44
00 41 0f 15 44
00 41 0e 43 44
00 41 0f 43 44
00 41 0e 43 44
02 41 0f 43 44
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
01 1e 20 43 44
02 1f 20 43 44
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
