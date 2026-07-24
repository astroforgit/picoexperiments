pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--aurora railway
--by jusiv

--[[
made from 12/19/2018 to 1/6/2018
for the gdc dev chill jam run by
worcester polytechnic
institute's game development
club.

all assets and code by
j. henry stadolnik iv

to follow my work, check out my
twitter: @jusiv_

(c) 2018 j. henry stadolnik iv

]]

function _init()
 --cartdata("jusiv_aurora")
 score = 0
 --highscore = dget(0)
 
 idle = 0
 m_idle = 0
 wait = 0
 
 timer = 0 --timer for game
 
 cs_play = false --in cutscene?
 cs_wait = 0 --cutscene wait
 cs_trig = 0 --cs trigger time
 
 part = 0
 --[[
 structure
 0.  title
 1.  train platform
 ~2.  > catch ticket
 ~3.  board train
 4.  > find seat
 5.  get seated
 6.  > window gazing, part 1
 7.  seatmate talk, part 1
 8.  > window gazing, part 2 (snow)
 9.  seatmate talk, part 2
 10. disembark
 11. end
 ]]
 
 
 --palette
 pal_id = 0 --0=norm, 1=dk1, 2=dk2, 3=bk
 pal_wait = 0 --for fade in
 dpal1 = {   0, 1, 1,
          2, 2,13, 6,
          2, 4, 9, 3,
          13,5, 8}
 dpal2 = {   0, 0, 0,
          1, 1, 5, 5,
          1, 2, 4, 1,
          5, 2, 2}
 aurora = {3,11,10,9,14,2,1}
 
 --player
 p_x = 38--98
 p_y = 116--86
 p_frame = 0
 p_dir = 0
 --  1
 -- 2+0
 --  3
 
 arrowprompt = 15
 
 --window game
 p_jump = 0
 p_jumpwait = 0
 p_fwait = 0 --delay before falling(?)
 p_land = true
 p_stun = 0
 p_combo = 0
 p_combotimer = 0
 p_fade = 0
 p_lastramp = false
 canrock = false
 canramp = false
 collide = false
 
 
 --train windows
 --windows stored per car in string
 --format: #### (0=dark, 1=lit)
 windows1 = {}
 windows2 = {}
 bitstring(windows1,3,4)
 bitstring(windows2,5,4)
 --sprites to use for each window
 winspr = {21,22,22,23}
 
 train_x = 1
 stranger = 0
 
 --text
 --[[
 char ids:
  1 player
  2 conductor
  3 stranger
  4 ???
  5 mother
  
 emotes:
  0 none
  1 shock
  2 happy
  3 nervous
  4 laugh
 ]]
 t_scene = 0
 c_color = {7,11,12,12,14}
 lmax = 21 --max # chars per line
 t_lines = {} --text lines
 t_max = 0 --full char length of lines
 t_wait = 0 --countdown of line reveal
 c_talk = 2 --char talking: 0=none, 1-5=character
 talksound = {18,17,20,20,19}
 kword = {"grandson"}
 -- ^ indicate these in text with `#, where # is string id
 lcount = 0 --position in scene
 --[[
 alt train boarding
          --scene 1 (part 1a): train platform
          {"2 0 last call for the train to frostport!",
											"1 1 aaa sorry i'm coming",
											"1 3 sorry, didn't mean to run so late but, y'know...",
	   							"2 0 quite alright, sir. may i see your ticket?",
											"1 0 just a moment! let me-",
											"1 1 oh no!"},
          --scene 2 (part 1b): train platform
          {"1 3 ok, here you go",
											"2 0 thank you. hurry on board now!"},
 --]]
 lines = {--scene 1 (part 1a): engineer call
          {"2 0 last call for the final train to frostport!",
											"1 1 aaa hold up, i'm coming!"},
										--scene 2 (part 1b): meet engineer
										{"1 3 sorry, didn't mean to run so late but, y'know...",
	   							"2 0 quite alright, sir. but please, hurry on aboard if you plan to ride with us tonight.",
											"1 2 yes, thank you mister!"},
          --scene 3 (part 4a): on train
		        {"1 0 (ok, just gotta find a seat)"},
		        --scene 4 (part 4b): locked
		        {"1 0 (seems to be locked)"},
		        --scene 5 (part 4c): occupied
		        {"1 3 (definitely occupied)"},
		        --scene 6 (part 4d): enter
		        {"1 0 (oof, chilly over here...)",
		         "1 0 (did someone leave a window open?)",
		         "1 3 (well, nothing else seems available so i guess i don't have a choice.)"},
		        --scene 7 (part 5a): noticing stranger
		        {"1 1 (oh, there's someone in here already!)",
		         "1 0 (i think he's asleep...)",
		         "1 3 (welp i'll try not to wake him.)"},
		        --scene 8 (part 5b): musing
		        {"1 0 (well, that was more stress than it needed to be, but at least i'm here.)",
		         "1 3 (prooobably shouldn't mention i almost missed the train to mom...)",
		         "1 3 (she's certainly dealing with plenty as it is.)",
		         "1 2 (well, it'll be good to see her again, at least.)",
		         "1 0 (...)",
		         "1 3 (hopefully...)"},
		        --scene 9 (part 5c): window start
		        {"1 3 (oh no...)",
		         "1 0 (frostport is still a long ways off)",
		         "1 0 (and i just realized i completely forgot to bring anything to do.)",
		         "1 3 (ugh, why am i like this?)",
		         "1 0 (welp, might as well kill time scene sledding...)"},
		        --scene 10 (part 6a): chasing intro
		        {"1 0 (scene sledding is simple enough - just imagine a guy zooming along the scenery)",
		         "1 0 (if you can make them jump off something like a ramp, that boosts your combo.)",
		         "1 0 (but if they go 3 seconds without jumping then they lose it.)",
		         "1 3 (maybe not exactly the most exciting game imaginable)",
		         "1 0 (but at least it's something to do.)"},
		        --scene 11 (part 6b): stranger intro
		        {"3 0 scene sledding, are we now?",
		         "1 1 huh? what?"},
		        --scene 12 (part 7a): stranger talk
		        {"1 0 oh, you're awake.",
		         "1 3 yeah, i guess i was.",
		         "3 0 not too many kids do that nowadays, you know.",
		         "3 0 always so busy with their gadgets, letting the world slip by...",
		         "1 3 i mean... to be honest i was just doing it because i had nothing else to do.",
		         "3 0 well, that is precisely what it's for!",
		         "3 0 that, and keeping your mind busy."},
		        --scene 13 (part 7b): who taught you
		        {"3 0 say, who taught you about scene sledding?",
		         "1 0 my grandpa.",
		         "3 0 ah yes, i could have guessed.",
		         "1 3 ...",
		         "3 0 you alright there?",
		         "1 0 oh yeah i'm fine.",
		         "1 3 it's just...",
		         "1 0 i'm on my way to his funeral.",
		         "3 0 ah.",
		         "3 0 you have my condolences.",
		         "3 0 no death is easy to take, but especially not a grandparent.",
		         "1 3 yeah, thanks."},
		        --scene 14 (part 7c):
		        {"1 3 (did he fall asleep again?)",
		         "1 0 (fine by me, i guess.)"},
		        --scene 15 (part 8a):
		        {"1 0 (welp, back to this.)",
		         "1 2 (but hey, looks like it's snowing now, too!)",
		         "1 0 (oh yeah, and there's another rule i forgot: rocks break your combo.)",
		         "1 0 (so don't let the guy hit those."},
          --scene 16 (part 8b):
          {"3 0 if you don't mind me asking, were you close?",
           "1 1 huh?",
           "1 0 oh."},
		        --scene 17 (part 9a): how close were you
		        {"1 3 i mean... not really.",
		         "1 0 never saw him more than once a year.",
		         "1 0 and even when i did we didn't talk all that much.",
		         "1 3 it's not like i disliked him, we just didn't connect very well.",
		         "3 0 i see.",
		         "3 0 you know, almost everyone has relatives like that.",
		         "3 0 it's not necessarily your fault.",
		         "1 0 yeah, i know.",
		         "1 3 there are some people it feels like you *should* be close with, though.",
		         "1 3 i feel like i never got the chance to miss him.",
		         "3 0 oh? are you sure that's something you'd actually want?",
		         "1 0 i dunno it just feels... wrong.",
		         "1 0 like my mom's taken it kinda hard.",
		         "1 3 but here i am almost perfectly fine.",
		         "1 0 i feel like there should be a void where he was.",
		         "1 3 but i can't find it.",
		         "3 0 well, of course she'd take it harder than you. he was her father, after all.",
		         "3 0 you don't have to miss everyone equally.",
		         "1 0 if i don't miss him how can i really say i loved him?",
		         "3 0 there's a lot more to love than just a yes or no.",
		         "3 0 you can love people to different degrees and for different things.",
		         "3 0 and maybe you didn't love your grandpa as much as some other people.",
		         "3 0 that's perfectly okay.",
		         "3 0 the fact that you're worried about this shows that you did care about him",
		         "3 0 in some way.",
		         "3 0 it's still love, any way you slice it.",
		         "1 0 i suppose that makes sense.",
		         "1 3 i'm just... worried what he'd think.",
		         "1 3 if he knew i can't seem to find it in me to miss him.",
		         "3 0 now, don't worry about that."},
		        --scene 18 (part 9b)
		        {"4 0 i don't blame you for it at all.",
		         "1 1 grandpa???",
		         "4 0 i need to go now.",
		         "4 0 but it's good to hear you're doing alright without me.",
		         "4 0 and i'm glad you still remember scene sledding.",
		         "4 0 now, keep your mother company for me, alright?",
		         "1 1 wait, don't-"},
		        --scene 19 (part 9c)
		        {"1 0 go..."},
		        --scene 20 (part 9d)
		        {"1 2 grandpa?"},
		        --scene 21 (part 9d)
		        {"1 0 if you can still hear me, i just want to say thank you.",
		         "1 0 and yes, i'll do whatever i can to help her."},
		        --scene 22 (part 10)
		        {"1 2 hey mom!",
		         "5 0 hey sweetie.",
		         "5 0 how was the train ride?"}
		        }
		        
	--actors
	aurora_y = 38
	maxbump = 25
	maxsnow = 25
	a_aurora = {}
	a_abump = {}
	a_snow = {}
	a_ramp = {}
	a_rock = {}
	a_lump = {}
	a_ice = {}
	depth = {}
	
	--[[
	for i=0,8 do
	  add_aurora(16*i)
	end
	--]]
	for i=0,64 do
	   add_aurora(2*i)
	end
	for i=0,maxbump do
	   add_abump(rnd(131))
	end
	for i=0,7 do
	   add_lump(flr(rnd(60)-4),59+flr(rnd(15)))
	   add_lump(70+flr(rnd(60)),59+flr(rnd(15)))
	end
	
	music(4)
end

src = stat(102)
-->8
--actors

--’ aurora
function add_aurora(x)
 local a={}
 a.x = x
 a.y = aurora_y
 add(a_aurora,a)
end

function upd_aurora(a)
 --a.y += 0.125*sign(aurora_y-a.y)
 a.y += (aurora_y-a.y)/16
 --]]
 for i=1,#a_abump do
    local b = a_abump[i]
    --if colliding with bump
    if mid(a.x,b.x-b.r,b.x+b.r) == a.x then
       a.y += b.ofs
       --local xx = flr(b.x-a.x)
       --a.y = 34-flr(abs(sqrt(xx*xx-b.r*b.r)))
    end
 end
end

function draw_aurora(a)
 local yy = a.y
 for i=1,#aurora do
    local yy2 = yy-3-i/2
    rect(a.x,yy,a.x+1,yy2,aurora[i])
    yy = yy2
 end
 --print(a.y,a.x,40,7)
end

function add_abump(x)
 local a={}
 a.x = x
 a.dx = flr(1+rnd(2))/4
 a.y = aurora_y
 a.tm = 120+flr(rnd(240))
 a.t = flr(rnd(a.tm))
 a.rm = 1+rnd(4)
 a.r = rnd(a.rm)
 a.ofs = 0.125
 a.hit = false
 if flr(rnd(2)) == 0 then
    a.ofs *= -1
 end
 add(a_abump,a)
end

function upd_abump(a)
 a.x -= a.dx
 if a.x < -4 then
    del(a_abump,a)
 end
 a.t = (a.t+1)%a.tm
 a.r = 1+abs(a.rm*cos(a.t/a.tm))
end

--debug
function draw_abump(a)
 circ(a.x,a.y,a.r,8)
 print(a.r*a.r,a.x,a.y+4)
end


--’ snow
function add_snow()
 local a={}
 a.x = 131
 a.y = rnd(128)
 a.r = rnd(1.5)
 a.dx = 2+rnd(4)
 add(a_snow,a)
end

function upd_sn0w(a)
 local dx = a.dx
 if part > 9 then dx = dx/4 end
 a.x -= dx
 if a.x < -4 then
    del(a_snow,a)
 end
 a.y += rnd(0.5)-0.125
end

function draw_snow(a)
 circ(a.x,a.y,a.r,6)
end


--’ ramp
function add_ramp(x,yy)
 local a={}
 a.x = x
 a.y = yy
 a.w = 1
 --decide type
 a.sp = 195+2*flr(rnd(3))
 a.draw = function(a)
    spr(a.sp,a.x-2,a.y-7,2,1)
    --rect(a.x,a.y-7,a.x+16,a.y,10)
 end
 add(a_ramp,a)
end

function upd_ramp(a)
 a.x -= 1
 if a.x < -16 then
    del(a_ramp,a)
 end
end


--’ rock
function add_rock(x,yy)
 local a={}
 a.x = x
 a.y = yy
 a.w = 1
 a.sp = 213+flr(rnd(2))
 a.hit = false
 if flr(rnd(2)) == 0 then
    a.w = 2
    a.sp = 227+2*flr(rnd(2))
 end
 a.draw = function(a)
    spr(a.sp,a.x,a.y-8*a.w+1,a.w,a.w)
    --rect(a.x,a.y-8*a.w+1,a.x+8*a.w,a.y,8)
 end
 add(a_rock,a)
end

function upd_rock(a)
 a.x -= 1
 if a.x < -8*a.w then
    del(a_rock,a)
 end
end


--’ lump
function add_lump(x,y)
 local a={}
 a.x = x
 a.y = y
 a.sp = 211+flr(rnd(2))
 a.draw = function(a)
    spr(a.sp,a.x,a.y-7)
 end
 add(a_lump,a)
end

function upd_lump(a)
 a.x -= 1
 if a.x < -8 then
    del(a_lump,a)
 end
end


function make_wplayer()
 local p={}
 p.y = flr(p_y)
 p.sp = 201
 if p_stun > 0 then
    p.sp = 205
 elseif p_jump > 0 then
    p.sp = 203
 end
 p.draw = function(p)
    if p_fade%4 == 0 and p_stun%4 == 0 then
       if p_combo > 0 then
          local cc = 3
          if idle%50 > 25 then
             cc = 11
          end
          pal(8,cc)
       else
          pal(8,0)
       end
       rect(p_x-7,p.y,p_x-4,p.y,5)
       spr(p.sp,p_x-16,p.y-7-p_jump,2,1)
    end
 end
 return p
end


--„ sort
function asort(a)
 local bucket = depth[flr(a.y-58)]
 add(bucket,a)
end

function acollide(a)
 if not a.hit and
    mid(a.y,p_y-3,p_y+2) == a.y and
    mid(a.x,p_x-10,p_x-3) == a.x and
    p_jump < a.w*8 then
    collide = true
    a.hit = true
 end
end


--’ ice
function add_ice()
 local a={}
 a.x = 131
 a.y = 77
 a.r = 3+rnd(3)
 a.c1 = 7
 a.c2 = 12
 if flr(rnd(2)) == 0 then
    a.c1 = 12
    a.c2 = 1
    a.y += 6
 end
 add(a_ice,a)
end

function upd_ice(a)
 a.x -= 1
 if a.x < -4 then
    del(a_ice,a)
 end
end

function draw_ice(a)
 circfill(a.x,a.y,a.r,a.c1)
 circfill(a.x,a.y+18,a.r,a.c2)
end
-->8
--main
function sign(n)
 if n < 0 then
    return -1
 elseif n > 0 then
    return 1
 else
    return 0
 end
end


function interact()
 local check = (wait <= 0 and (btnp(4) or btnp(5)))
 if check then
    wait = 15
 end
 return check
end


function bitstring(list,items,bits)
 for i=1,items do
    local str = ""
    --generate string
    for j=1,bits do
       local new = ""
       if flr(rnd(2)) == 0 then
          new = "0"
       else
          new = "1"
       end
       str = str..new
    end
    add(list,str)
 end
end


--cutscene
function cs_start(wait,trig)
 cs_wait = wait
 cs_trig = trig
 cs_play = true
end


--player
function move_player()
 --input
 local dx = 0
 local dy = 0
 if btn(0) then dx -= 0.5 end
 if btn(1) then dx += 0.5 end
 if btn(2) then dy -= 1 end
 if btn(3) then dy += 1 end
 
 --re-orient
 if dx != 0 then
    p_frame = (p_frame+1)%32
    if dx > 0 then
       p_dir = 0
    else
       p_dir = 2
    end
 else
    p_frame = 0
    if dy < 0 then
       p_dir = 1
    elseif dy > 0 then
       p_dir = 3
    end
 end
 
 --move
 local xbnd = 20
 if part == 4 then
    xbnd = 2
 end
 p_x = mid(p_x+dx,xbnd,120-xbnd)
end


--window game
function window_game()
 local dx = 0
 local dy = 0
 
 --stun recover
 if p_stun > 0 then
    p_stun -= 1
    
 --input
 else
    if btn(0) then dx -= 0.5 end
    if btn(1) then dx += 0.5 end
    if btn(2) then dy -= 1 end
    if btn(3) then dy += 1 end
 end
 
 p_x = mid(p_x+dx,8,126)
 p_y = mid(p_y+dy,60,78)
 if p_jumpwait > 0 then
    p_jumpwait -= 1
    p_jump += 1
 elseif p_fwait > 0 then
    p_fwait -= 1
 elseif p_jump > 0 then
    p_jump -= 0.5
    if p_jump <= 3 then
       p_land = true
    end
 end
 
 --ramp collision
 local ramp = false
 collide = false
 foreach(a_ramp,acollide)
 if collide and p_land then
    --p_jump += 1
    p_jumpwait = 12
    p_fwait = 10
    ramp = true
    p_land = false
 end
 
 --rock collision
 collide = false
 foreach(a_rock,acollide)
 if collide then
    p_stun = 30
    p_combo = 0
    p_combotimer = 0
    ramp = false
    sfx(24)
 end
 
 --track combo
 if t_scene == 0 then
 			timer += 1
    if p_combotimer > 0 then
       p_combotimer -= 1
       if p_combotimer <= 0 then
          p_combo = 0
          sfx(25)
       end
    end
    if ramp then
       p_lastramp = true
    else
       if p_lastramp then
          p_combo += 1
          if p_combo%10 == 0 then
             sfx(23)
          elseif p_combo%5 == 0 then
             sfx(22)
          else
             sfx(21)
          end
          score += 1
          p_combotimer = 180
       end
       p_lastramp = false
    end
 end
end

function reset_wgame()
 p_x = 12
 p_y = 69
 p_jump = 0
 p_fwait = 0
 p_stun = 0
 p_fade = 60
 p_combo = 0
 p_combotimer = 0
 p_lastramp = false
 a_rock = {}
 a_ramp = {}
 arrowprompt = 15
 timer = 0
end


--main
function _update60()
 idle = (idle+1)%400
 m_idle = (m_idle+1)%100
 
 --input wait
 if wait > 0 then
    wait -= 1
 end
 
 --fade in
 if p_fade > 0 then
    p_fade -= 1
 end
 if pal_wait > 0 then
    pal_wait -= 1
    if pal_wait%10 == 0 then
       pal_id -= 1
    end
 end
 
 --[[train noise
 if mid(part,4,9) == part then
    if flr(idle/10)%10 == 0 then
       sfx(13)
    end
 end
 --]]
 
 --title
 if part == 0 then
    if interact() then
       --start opening cutscene
       part = 1
       cs_start(420,360)
       sfx(15)
       music(-1,2000)
    end
    
 --gameplay
 elseif t_scene == 0 then
    --cutscene
    if cs_play then
       if cs_wait > 0 then
          cs_wait -= 1
          
          --fade out
          if cs_wait <= 20 and
             cs_wait%10 == 0 then
             pal_id += 1
          end
          
          --general update
          if part == 1 then
             if mid(cs_trig,240,0) == cs_trig then
                p_frame = (p_frame+1)%32
             end
             --climb stairs
             if cs_trig == 240 then
                p_y -= 0.25
             end
             --walk right
             if cs_trig == 240 or
                cs_trig == 230 then
                p_x += 0.5
             --walk up
             elseif cs_trig == 210 or
                    cs_trig == 0 then
                if p_y > 63 then
                   p_y -= 0.5
                   p_dir = 1
                else
                   p_frame = 0
                end
             --walk left
             elseif cs_trig == 90 then
                if p_x > 60 then
                   p_x -= 0.5
                else
                   p_frame = 0
                end
             end
          elseif part == 4 then
             local outside = (p_y > 48)
             --walk horizontally
             if p_x != 44 then
                local dr = sign(44-p_x)
                if dr > 0 then
                   p_dir = 0
                else
                   p_dir = 2
                end
                p_x += 0.5*dr
             --walk vertically
             else
                p_dir = 1
                if outside then
                   p_y -= 0.5
                end
             end
             --animate
             if outside then
                p_frame = (p_frame+1)%32
             else
                p_frame = 0
             end
          --stranger conversation 2
          elseif part == 9 then
             if cs_trig == 480 then
                if cs_wait%10 == 1 then
                   stranger += 1
                end
             end
             if cs_trig == 360 then
                if cs_wait%10 == 0 and
                   stranger > -2 then
                   stranger -= 1
                end
             end
          --disembark
          elseif part == 10 then
             if cs_trig == 90 then
                if cs_wait > 270 then
                   train_x += 1
                elseif cs_wait > 210 then
                   train_x += 0.75
                elseif cs_wait > 150 then
                   train_x += 0.5
                else
                   train_x += 0.25
                end 
             elseif cs_trig == 30 then
                if p_y <= 72 and cs_wait < 70 then
                   p_y += 0.5
                   p_frame = (p_frame+1)%32
                else
                   p_frame = 0
                end
             end
          end
          
          --progress
          if cs_wait <= cs_trig then
             --boarding train
             if part == 1 then
                if cs_trig == 360 then
                   t_scene = 1
                   nextline()
                   cs_trig = 240
                elseif cs_trig == 240 then
                   cs_trig = 230
                elseif cs_trig == 230 then
                   cs_trig = 210
                   p_dir = 1
                elseif cs_trig == 210 then
                   cs_trig = 90
                   p_dir = 2
                elseif cs_trig == 90 then
                   t_scene = 2
                   nextline()
                   cs_trig = 0
                end
             
             --first inside room
             elseif part == 5 then
                if cs_trig == 210 then
                   t_scene = 8
                   nextline()
                   cs_trig = 90
                elseif cs_trig == 90 then
                   t_scene = 9
                   nextline()
                   cs_trig = 0
                end
             
             --stranger conversation 1
             elseif part == 7 then
                if cs_trig == 180 then
                   t_scene = 13
                   nextline()
                   cs_trig = 30
                elseif cs_trig == 30 then
                   t_scene = 14
                   nextline()
                   cs_trig = 0
                end
                
             --stranger conversation 2
             elseif part == 9 then
                if cs_trig == 480 then
                   t_scene = 18
                   nextline()
                   cs_trig = 360
                elseif cs_trig == 360 then
                   t_scene = 19
                   nextline()
                   cs_trig = 240
                elseif cs_trig == 240 then
                   t_scene = 20
                   nextline()
                   cs_trig = 120
                elseif cs_trig == 120 then
                   t_scene = 21
                   nextline()
                   cs_trig = 0
                end
             
             --disembark
             elseif part == 10 then
                if cs_trig == 90 then
                   p_x = 60
                   p_y = 63
                   p_dir = 3
                   p_frame = 0
                   cs_trig = 30
                elseif cs_trig == 30 then
                   t_scene = 22
                   nextline()
                   cs_trig = 0
                end    
             end
          end
       else
          --end cutscene
          if part == 1 then
             part = 4
             cs_play = false
             p_x = 118
             p_y = 53
             p_dir = 2
             t_scene = 3
             nextline()
             arrowprompt = 15
             --sfx(26)
          elseif part == 4 then
             part = 5
             t_scene = 7
             nextline()
             cs_start(360,210)
          elseif part == 5 then
             part = 6
             cs_play = false
             t_scene = 10
             nextline()
             reset_wgame()
          elseif part == 6 then
             part = 7
             t_scene = 12
             nextline()
             cs_start(300,180)
          elseif part == 7 then
             part = 8
             cs_play = false
             t_scene = 15
             nextline()
             reset_wgame()
          elseif part == 8 then
             part = 9
             t_scene = 17
             nextline()
             cs_start(510,480)
          elseif part == 9 then
             part = 10
             p_x = 200
             p_y = 200
             cs_start(420,90)
             a_ramp = {}
             a_rock = {}
             sfx(26)
          elseif part == 10 then
             part = 11
             cs_play = false
             music(4,2000)
          end
          pal_wait = 25
       end
       
    --actual gameplay
    else
       if arrowprompt >= 15 then
          if btn(0) or btn(1) or btn(2) or btn(3) then
             arrowprompt = 14
          end
       elseif arrowprompt > 0 then
          arrowprompt -= 1
       end
       if part == 2 then
          --catch minigame
          move_player()
       elseif part == 4 then
          --train exploration
          move_player()
          if interact() then
             if p_x == mid(40,48,p_x) then
                t_scene = 6
                nextline()
                cs_start(90+2*abs(p_x-44),0)
                -- ^ time varies to account for repositioning
                p_dir = 1
                p_frame = 0
             elseif p_x == mid(104,112,p_x) then
                t_scene = 4
                nextline()
                p_dir = 1
                p_frame = 0
             elseif p_x == mid(8, 16,p_x) or
                    p_x == mid(72,80, p_x) then
                t_scene = 5
                nextline()
                p_dir = 1
                p_frame = 0
             end
          end
       elseif part == 6 then
          --window minigame 1
          window_game()
          if t_scene == 0 then
             canramp = true
          end

          --[[debug
          if interact() then
             score = 15
          end
          --]]
          
          if score >= 15 or timer > 2400 then
             t_scene = 11
             nextline()
             cs_start(30,30)
          end
       elseif part == 8 then
          --window minigame 2
          window_game()
          if t_scene == 0 then
             canrock = true
          end

          --[[debug
          if interact() then
             score = 30
          end
          --]]
          
          if score >= 30 or timer > 2400 then
             t_scene = 16
             nextline()
             cs_start(30,30)
          end
       elseif part == 11 then
          if aurora_y < 79 then
             aurora_y += 1
          end
       end
    end
 
 --dialogue
 elseif pal_id <= 0 then
    -- ^ only advance after fade
    if t_wait > 0 then
       if t_wait%10 == 0 then
          sfx(talksound[c_talk])
       end
       t_wait -= 1
    elseif t_scene > 0 and interact() then
       nextline()
    end
 end
 
 --aurora
 foreach(a_abump,upd_abump)
 if #a_abump < maxbump then
    add_abump(131)
 end
 foreach(a_aurora,upd_aurora)
 --snow
 if part == mid(part,8,10) then-- or part == 9 then
    if #a_snow < maxsnow and idle%4 == 0 then
       add_snow()
    end
    foreach(a_snow,upd_sn0w)
 end
 --terrain
 if part > 4 and part < 10 then
    foreach(a_ramp,upd_ramp)
    foreach(a_rock,upd_rock)
    foreach(a_lump,upd_lump)
    foreach(a_ice,upd_ice)
    if flr(rnd(10)) == 0 then
       add_ice()
    end
    if flr(rnd(20)) == 0 then
       local yy = 61+flr(rnd(17))
       local terr = flr(rnd(3))
       if terr == 0 then
          if canrock then 
             add_rock(131,yy)
          end
       elseif terr == 1 then
          if canramp then
             add_ramp(131,yy)
          end
       else
          add_lump(131,yy)
       end
    end
 end
 
 if (part <= 4 or part == 10) and cs_wait == 80 then
    --door sound
    sfx(29)
 end
end
-->8
--text
function insert(txt1,pos,txt2)
 return sub(txt1,1,pos-1)..txt2..sub(txt1,pos+2,#txt1)
end


function splittext(text)
 local txt = text
 local t = {tonum(sub(txt,1,1)),
 				       tonum(sub(txt,3,3))} --char, emote, lines
 local pos = 5
 local count = 0 --char
 local split = pos --last line break
 local space = pos --last space pos
 while pos < #txt do
 	  local c = sub(txt,pos,pos)
 	  --insert keyword (use `#)
    if c == "`" then
       txt = insert(txt,pos,kword[tonum(sub(txt,pos+1,pos+1))])
       c = sub(txt,pos,pos)
 	  end
 	  --mark word break
 	  if c == " " or c == "-" then
 	  			space = pos
 	  end
 	  --break line at word break
 	  if count > lmax then
 	     local len = pos-space
 	     add(t,sub(txt,split,space))
 	     split = space+1
 	     --count = -1
 	     count = len
 	  end
 	  pos += 1
 	  count += 1
 end
 add(t,sub(txt,split,pos))
 return t
end


function nextline()
 local sl = lines[t_scene]
 --advance dialogue
 lcount += 1
 --advance state if at end of dialogue
 if lcount > #sl then
    --progress
--hey!!! revise
    t_scene = 0
    lcount = 0
 else
    --grab line from scene
    t_lines = splittext(sl[lcount])
    t_max = #sl[lcount]-4 -- -4 accounts for char flag + space
    t_wait = t_max
    c_talk = t_lines[1]
 end
end


function printtext(tlist,y)
 local pos = 0
 local added = 0
 local pmax = t_max-t_wait
 local char = tlist[1]
 local emote = tlist[2]
 --text box
 rectfill(-4,y,131,131,0)
 rect(-4,y,131,127,5)
 --portrait
 local sp = 60+char*4
 if char > 4 then sp = 128 end
 spr(sp,1,y+2,4,4)
 if emote > 0 then
    spr(130+2*emote,11,y+14,2,1)
 end
 --cprint(c_names[char+1],63,y+1,c_color[char+1])
 color(c_color[char])
 for i=3,#tlist do
    local str = tlist[i]
    if added <= pmax then
       if added+#str > pmax then
          str = sub(str,1,pmax-added)
       end
       print(str,35,y+7*i-16)
       added += #str
    end
 end
 --advance indicator
 if t_wait <= 0 then
    spr(20,119,y+27)
    if m_idle >= 50 then
       pal(5,13)
       spr(20,119,y+26)
       pal(5,5)
    end
 end
end
-->8
--draw

function cprint(str,y,c)
 print(str,64-2*#str,y,c)
end


--palette
function blackpal()
 for i=0,16 do
    pal(i,0)
 end
end

function navypal()
 for i=0,16 do
    pal(i,1)
 end
end

function darkpal1()
 for i=1,14 do
    pal(i,dpal1[i])
 end
end

function darkpal2()
 for i=1,14 do
    pal(i,dpal2[i])
 end
end

function normpal()
 if pal_id == 0 then
    pal()
 elseif pal_id == 1 then
    darkpal1()
 elseif pal_id == 2 then
    darkpal2()
 elseif pal_id == 3 then
    blackpal()
 end
 pal(15,0)
end


--trapezoid
function trap(x1,y1,x2,y2,ybar,c)
 --[[
 draws a trapezoid
          
         w
      |-----|
      
      x1    x2
 ybar +-----+  -
      |     |  |
   y1 +     |  |h
            |  |
   y2       +  -
 
 --]]
 
 local w = x2-x1
 local h = y2-y1
 local dy = sign(h)
 h = abs(h)
 local dx = w/h
 
 for i=1,h do
    rectfill(x1+dx*(i-1),y1+i*dy,x1+dx*i,ybar,c)
 end
end


--player
function draw_player()
 blackpal()
 pdraw(-1,0)
 pdraw(1,0)
 pdraw(0,-1)
 normpal()
 pdraw(0,0)
end

function pdraw(xoff,yoff)
 local bsp = 12 -- body sprite
 local hsp = 3 --head sprite
 local mm = false
 if p_dir == 0 then
    mm = true
 elseif p_dir == 1 then
    bsp = 8
    hsp = 2
 elseif p_dir == 3 then
    bsp = 4
    hsp = 1
 end
 local pf = flr(p_frame/8)
 --body
 spr(bsp+pf,p_x+xoff,p_y+yoff,1,1,mm,false)
 --head
 spr(hsp,p_x+xoff,p_y-6+yoff,1,1,mm,false)
end


--train
function draw_cars(list,xtip,y)
 --read cars from list
 for i=1,#list do
    local windows = list[i]
    --for each car:
    --1. draw it
    xtip -= 36
    map(117,0,xtip,y,5,4)
    --2. light specified windows
    for j=1,#windows do
       if sub(windows,j,j) == "1" then
          spr(winspr[j],xtip+j*8,y+8)
       end
    end
 end
 return xtip
end

function draw_train(xtip,y,door,player)
	--note: door starts at xtip-184
 --rail
 rect(-4,y+25,132,y+25,2)
 rect(-4,y+27,132,y+27,5)
 spr(187,17,75)
 spr(187,34,75)
 spr(187,86,75)
 spr(187,103,75)
 --[[
 for i=1,17 do
    --failed connector bars
    rect(8*i-3,y+28,
         8*i-4,y+29,4)
 end
 --]]
 --engine
 xtip -= 48
 map(122,0,xtip,y,6,4)
 spr(151,xtip+11,y+22)
 spr(151,xtip+18,y+22)
 local ang = (xtip%12)/12
 local rad = 2.5
 local xoff = xtip+mid(-1,1,rad*cos(ang))
 local ypos = y+24-mid(-1,1,rad*sin(ang))
 line(xoff+13,ypos,
      xoff+20,ypos,6) --or use color 4 (brown)
 --cars, part 1
 xtip = draw_cars(windows1,xtip,y)
 --entry car
 xtip -= 52
 map(110,0,xtip,y,7,4)
 if player then
    draw_player()
 end
 spr(34+door,xtip+24,y+8,1,2)
 spr(34+door,xtip+32,y+8,1,2,true,false)
 --car3
 xtip = draw_cars(windows2,xtip,y)
end


--platform
function draw_platform(xtip,door,player)
 --platform
 rectfill(16,91,111,131,1)
 rectfill(16,79,111,90,5)
 rect(16,79,111,90,13)
 --stairs
 for i=0,4 do
    spr(171,96-8*i,91+4*i)
 end
 rect(102,90,111,94)
 rectfill(103,90,110,93,5)
 --train
 draw_train(xtip,49,door,player)
 spr(155,56,73)
 spr(155,64,73,1,1,true,false)
end


--engineer
function draw_engineer(xoff,yoff)
 spr(16,46+xoff,75+yoff)
 local sp = 18
 local mm = false
 if p_x > 56 then
    mm = true
 elseif p_x >= 38 then
    sp = 17
 end
 spr(sp,46+xoff,69+yoff,1,1,mm,false)
end


--building
function draw_building()
 rectfill(-4,110,131,131,1)
 rect(-4,110,131,119,13)
 rect(-4,105,43,110)
 rect(-4,100,15,105)
 rect(112,100,131,110)
 rectfill(-4,111,131,118,5)
 rectfill(-4,106,42,110)
 rectfill(-4,101,14,105)
 rectfill(113,101,131,110)
end


--mother 
function draw_mother(xoff,yoff)
 spr(8,60+xoff,82+yoff)
 spr(19,60+xoff,76+yoff)
end


--stranger
function draw_stranger(xoff,y)
 --body
 circfill(32+xoff,y+40,26,1)
 circfill(34+xoff,y+39,26)
 circfill(23+xoff,y+49,17)
 circfill(43+xoff,y+48,17)
 
 --head
 circfill(20+xoff,y+10,10,0)
 circfill(32+xoff,y,   22,1)
 circfill(20+xoff,y+8, 10)
 circfill(44+xoff,y+8, 10)
 
 --belly
 circfill(39+xoff,y+33,12,7)
 circfill(39+xoff,y+46,20)
 circfill(37+xoff,y+46,20)
 
 --wing
 circfill(12+xoff,y+40,7,0)
 circfill(15+xoff,y+34,7)
 circfill(21+xoff,y+29,5)
 circfill(8+xoff,y+45,4)
 circfill(10+xoff,y+45,4)
 circfill(7+xoff,y+47,3)
 circfill(11+xoff,y+40,6,1)
 circfill(14+xoff,y+34,7)
 circfill(21+xoff,y+27,6)
 circfill(8+xoff,y+44,4)
 circfill(6+xoff,y+47,2)
 pset(6+xoff,y+36)
 
 --left eye
 circfill(26+xoff,y,  5,6)
 circfill(26+xoff,y+2,5)
 circfill(27+xoff,y,  3,7)
 circfill(26+xoff,y+2,4)
 circfill(27+xoff,y+3,2,2)
 spr(32,20+xoff,y-8,2,1)
 
 --right eye
 circfill(49+xoff,y,  4,6)
 circfill(49+xoff,y+2,4)
 circfill(49+xoff,y,  3,7)
 circfill(49+xoff,y+2,3)
 circfill(49+xoff,y+3,2,2)
 sspr(0,16,14,8,43+xoff,y-8,12,8,true,false)
 
 --beak
 spr(208,26+xoff,y+4,2,1)
 spr(210,44+xoff,y+4)
 spr(48,35+xoff,y+3,2,1)
 
 --feet
 spr(224,10+xoff,y+56,2,2)
 sspr(0,112,16,16,54+xoff,y+50,13,16,true,false)
 pset(55+xoff,y+50,7)
end


--cabin
function draw_cabin()
 --walls
 rectfill(-4,-4,43,131,1)
 rectfill(44,-4,58,131,2)
 rectfill(120,-4,131,131)
 --window
 trap(59,12,119,16,-4,5)
 rectfill(59,12,63,74)
 trap(59,7,119,11,-4,2)
 trap(59,64,119,74,131,5)
 rectfill(114,15,119,73)
 trap(59,69,119,79,131,1)
 rect(59,69,60,69)
 trap(59,71,119,81,131,2)
 rect(59,71,60,71)
 --seat
 trap(-4,108,44,100,131,5)
 trap(44,100,64,106,131,5)
 trap(-4,128,64,115,131,1)
 pset(63,114)
 
 --draw stranger
 if stranger > -2 then
    if stranger == -1 then
       navypal()
    else
       blackpal()
    end
    draw_stranger(-3,41)
    draw_stranger(-1,41)
    draw_stranger(-2,40)
    draw_stranger(-2,42)

    if stranger == 0 then
       blackpal()
    elseif stranger == 1 then
       darkpal2()
    elseif stranger == 2 then
       darkpal1()
    elseif stranger == 3 then
       normpal()
    end
    draw_stranger(-2,41)
    normpal()
    spr(226,60,91)
 end
end


--main
function _draw()
 if not (src == 0 or src == "www.lexaloffle.com" or src == "jusiv.itch.io") then
    rectfill(0,113,128,128,8)
    print("please play this game on\njusiv.itch.io/aurora-railway",2,115,7)
    return
 end
 camera()
 normpal()
 cls()
 
 --scene
 if part != 4 then
    local ending = (part == 11)
    --land
    if not ending then 
       rectfill(-4,53,131,58,6)
       rectfill(-4,58,131,80,7)
       rectfill(-4,81,131,98,12)
       rectfill(-4,98,131,131,1)
       foreach(a_ice,draw_ice)
    end
    --aurora
    foreach(a_aurora,draw_aurora)
    --terrain and snow
    if not ending then
       --draw terrain
       -- clear buckets
       depth = {}
       for i=0,20 do
          add(depth,{})
       end
       -- sort
       foreach(a_ramp,asort)
       foreach(a_rock,asort)
       foreach(a_lump,asort)
       if part == 6 or part == 8 then
          asort(make_wplayer())
       end
       -- draw buckets
       for i=1,#depth do
          local bucket = depth[i]
          foreach(bucket,function(a) a:draw() end)
       end
       
       --draw snow
       foreach(a_snow,draw_snow)
    end
 end
 
 --train jostle
 if part == 4 or part == 5 or
    part == 7 or part == 9 then
    if flr(idle/10)%10 == 0 then
       camera(0,1)
    end
 end
 
 --train platform
 if part <= 3 then
    local door = 0
    if cs_wait == mid(30,90,cs_wait) then
       door = ceil(-2.5*sin((cs_wait-30)/120))
    end
    local inside = false
    if p_y <= 64 then
       inside = true
    end
    draw_platform(240,door,inside)
    --engineer
    blackpal()
    draw_engineer(-1,0)
    draw_engineer(1,0)
    draw_engineer(0,-1)
    normpal()
    draw_engineer(0,0)
    --player
    if not inside then draw_player() end
    --building
    draw_building()
    print("huddleville",18,93,14)
    
 --inside train
 elseif part == 4 then
    
    map(0,0,0,32, 16,4)
    local door = 0
    if cs_wait == mid(30,90,cs_wait) then
       door = ceil(-2.5*sin((cs_wait-30)/120))
    end
    local inside = (cs_play and cs_wait < 60)
    if inside then draw_player() end
    spr(172+door,40,40,1,2)
    spr(172+door,48,40,1,2,true,false)
    if not inside then draw_player() end
 
 --cabin
 elseif part == 5 or part == 7 or part == 9 then
    draw_cabin()
 
 --window minigame
 elseif part == 6 or part == 8 then
    if p_combo > 0 then
       cprint("combo "..p_combo.."!",4,11)
       rect(63-p_combotimer/6,10,
            63+p_combotimer/6,10)
    end
 --platform #2
 elseif part == 10 then
    local door = 0
    if cs_wait == mid(30,90,cs_wait) then
       door = ceil(-2.5*sin((cs_wait-30)/120))
    end
    local inside = false
    if p_y <= 64 then
       inside = true
    end
    draw_platform(train_x,door,inside)
    --player
    if not inside then draw_player() end
    --mother
    blackpal()
    draw_mother(-1,0)
    draw_mother(1,0)
    draw_mother(0,-1)
    normpal()
    draw_mother(0,0)
    --building
    draw_building()
    print("frostport",18,93,12)
 
 --ending
 elseif part == 11 then
    print("fin.",57,59,0)
    print("fin.",59,59)
    print("fin.",58,58)
    print("fin.",58,60)
    print("fin.",58,59,7)
    cprint("made by",109+79-aurora_y,1)
    cprint('henry "jusiv" stadolnik',115+79-aurora_y,1)
    cprint("(@jusiv_)",121+79-aurora_y,1)
 end
 
 camera()
 
 --title
 if part <= 1 then
    local yoff = 0
    if part == 1 then
       yoff = -420+cs_wait
    end
    spr(24,32,8+yoff,8,3)
    local cc = 13
    if idle%50 < 25 then
       cc = 5
    end
    cprint("> press z/x/c <",122-yoff,cc)
 elseif t_scene == 0 and
        (part == 4 or
         part == 6 or
         part == 8) then
    local cc = 13
    if idle%50 < 25 then
       cc = 5
    end
    cprint("(use arrow keys)",122+15-arrowprompt,cc)
 end
 
 
 
 --prompt
 if part == 4 and t_scene == 0 and not cs_play then
    for i=0,3 do
       local xx = 12+32*i
       if p_x == mid(xx-4,xx+4,p_x) then
          spr(20,xx,22)
          if m_idle >= 50 then
             pal(5,13)
             spr(20,xx,21)
             pal(5,5)
          end
       end
    end
 end

 --dialogue
 if t_scene > 0 and pal_id <= 0 then
    printtext(t_lines,92)
 end
 
 --debug
 pal(7,7)
 --print(part,1,1,7)
 --[[
 print("part: "..part,2,2,7)
 print("scene:"..t_scene,2,8)
 print("cwait:"..cs_wait,2,14)
 print("ctrig:"..cs_trig,2,20)
 print("idle: "..idle,2,26)
 --]]
 --print(stat(1),2,2,7)
 --foreach(a_abump,draw_abump)
 --print(#a_snow,2,8)
end
__gfx__
00000000000000000000000000000000001661000016610000166100001661000011110000111100001111000011110000011100000111000001110000011100
00000000000110000001100001100000016776100167761101677610116776100111111001111111011111101111111000611110006111100061111000611110
0070070001f1111001111110011111001177771101177761117777111677711011f11f110111111111f11f111111111006711110067111100671111006111110
00077000111ff111111111110f111110167777610117777017777771077771101f1111f1011f11f01f1111f10f11f11006711f100676111006711f1006116110
00077000116116111111111101611110f677776f066777600677776006777660011111100ff111100111111001111ff00676611006776f100676611006666110
00700700175995711111111199571110046666400066660004666640006666000411114000111400041111400041110000664100096411400066410004661490
00000000111111111111111101111110099009900000490009900990009400000990099000009900099009900099000000099000009004000009900000400900
00000000011111100111111000111100000000000000990000000000009900000000000000009900000000000099000000000000000000000000000000000000
00000000000000000000000000000000000000000555555555555555555555500000222220022220000222222222220000022222200022222222000022222200
00166100053333500033330000022200000000000552222555222255522225500002eeeee202ee200002ee2eeeeeee20002eeeeee202eeeeeeee2002eeeeee20
016776100a3333a000a33300022222e000000000052222225222222522222250002eeeeeee22ee200002ee2eeeeeeee202eeeeeeee22eeeeeeeee22eeeeeeee2
1177771113bbbb31bb3111101111222205500550052aaaa252aaaa252aaaa25002eee222eee2ee200002ee2ee2222eee2eee2222eee2ee22222ee2eee2222e92
1677776116511561015611101111111105555550052aaaa252aaaa252aaaa2502eee20002ee2ee200002ee2ee20002ee2ee200002ee2ee20002992e920222992
f677776f17344371043711101111111100555500052aaaa252aaaa252aaaa2502ee200002ee2ee200002ee2ee20002ee2ee20000299299202299929922aaaaa2
02666620111241114211111011111111000550000529aaa2529aaa2529aaa2502ee200002ee2ee200002ee2ee20022992992000029929922aaaa22aaaaaaaaa2
04400440011111100f11110001111110000000000529aaa2529aaa2529aaa2502ee200002ee2ee200002992992229999299200002aa2aaaaaaa222abbbb22bb2
00011111111110000005555500055555000555550005555555555555555555552ee202222992992000029929999aaaa22aa200002aa2aaaaaabb22bb22202bb2
001111111111110000055dd600055d60000556000005500055555ff44ff5555529922999999299200002aa2aaaaaaa222aa20022bbb2bb222bbbb2bb20002222
01111111111111000005ddd60005dd600005d600000500005555ffa44aff555529999999aaa2aa200002aa2aa222bbb22bbb22bbbb22bb20022bb22220002662
01111ddddddddd00000dddd6000ddd60000dd60000060000555fff4444fff5552aaaaa222aa2aa200002bb2bb2002bbb22bbbbbbb202bb200002222220002662
11dddddddddddd00000dddd6000ddd60000dd60000060000555ffffffffff5552aa222002aa2bb22222bbb2bb20002bb202bbbb2222222222222026620002662
1dddddddddddd000000dddd6000ddd60000dd60000060000555ffffffffff5552aa200002bb2bbbbbbbbb22bb200022222222220266226ddddd6226620002662
ddddd66666660000000dddd6000ddd60000dd60000060000555ffffffffff5552bb200002bb22bbbbbbb20222222000026620000266266222226626620002662
ddd6600000000000000dd6d6000d6d600006d60000060000555ffffffffff5552bb200002bb22222222222222662000026620000266266200026626622222662
00ffffff00000000000dd6d6000d6d600006d60000060000555ffffffffff5552bb200002222222002dd66dd26620000266200002662662000266226dd66d620
0fddddd5fff00000000dddd6000ddd60000dd60000060000555ffffffffff55522222220026ddd62022266222662000026620020266266222226620222662200
fdaaaaaaaaaa0000000dddd6000ddd60000dd60000060000555ffffffffff555266ddd6226622266200266202662000026620262266266ddddd6620002662000
daaaaaaaaaaaa000000dddd6000ddd60000dd60000060000a55ffffffffff5aa2662226626622266200266202662000026622662266266222226620002662000
5aaaaaaaaaaaa000000dddd6000ddd60000dd60000060000bb5222222222255b26622266266ddd66200266202662022226622662266266200026620002662000
f99aaaaaaaaa9000000dddd6000ddd60000dd600000600005552222222222555266ddd6226622266222266222662226626622662266266200026620002662000
0f999999f000000000055555000555550005555500055555dd555555555555dd26622266266202662ddd66dd266ddd66226dd66dd62266200026620002662000
0ff9999f00000000000ddddd000ddddd000ddddd000ddddd55dddddddddddd552222022222220222222222222222222222222222222222200022220002222000
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
d222222222222222222222222222222dd222222222222222222666666222222dd222222222222222222222222222222dd222222222222222222222222222222d
d200000000000000666000000000002dd200000000006666666333333600002dd200000000000000000000000000002dd200000000000000000000000000002d
d200000000000006111600000000002dd2000066666633333333bb333600002dd200000000000666666660000000002dd200000000000666666660000000002d
e200000000000661111160000000002de20006555333333bb33bbb333360002de200000000066000000006600000002de200000000066111111116600000002d
e200000000066101111116600000002de2006555333333bbbbbbb3333360002de200000006600000000000060000002de200000006611111111111160000002d
e200000006611101101111160000002ee2006555333333b33bb333333a60002ee200000060000000000000006000002ee200000061111111111111116000002e
e200000061111110011101116000002ee2006555333333333333bbbbbb36002ee200000600000000000000000600002ee200000611111111111111111600002e
e200000611111111111011111600002ee2006555a3333bbbbbbbbbbbb360002ee200006000000000000000000060002ee200006111111111111111111160002e
e200006111111111100111111160002ee20006555bbbbbbbbbbbbbb30060002ee200006000000000000000000060002ee200006111111111111111111160002e
e200006111111111111111111160002ee2000601003bbbbbbbb330000116002ee200060000000000000000000060002ee2000611111ddddd11111ddddd60002e
e200061111111111111111111160002ee2000611111ddd000000000d6116002ee200060000000000000000000006002ee20006111ddddddd11111dddddd6002e
9200061111111111111111111116002e92006111116776d0000000677616002e9200060000000000000000000006002e920006111dd66661111111666dd6002e
9200061111116661111111661116002e9200611111673561111111635616002e9200600000000000000000000006002e9200611111667761111111677616002e
92006111116677611111116776160029920061111167556111111165561600299200600000000000000000000006002992006111116722611111116226160029
9200611111677d6111111167d616002992006111116753111144111356160029920060000000000000000000000600299200611111672dddd1dd5ddd26160029
920061111167716111991167161600299200611111166111124441116116002992006000000000000000000000060029920061111116dd55ddaaaaa5d1160029
920061111116661111999916611600299200611111111111122444111116002992006000000000000000000000060029920061111111d555d19aaaa5d1160029
a2006111111111111149999111160029a2006111111111111022441111160029a2006000000000000000000000060029a200611111111ddd110991dd11160029
a2006111111111111104411111160029a2000611111111111100011111160029a2006000000000000000000000060029a2006111111111111111111111160029
a200061111111111111111111116002aa200061111111111111111111160002aa200600000000000000000000006002aa200611111111111111111111116002a
a200061111111111111111111160002aa200006111111111111111111160002aa200060000000000000000000006002aa200061111111111111111111116002a
a200006111111111111111111160002aa200000611111111111111111600002aa200006000000000000000000060002aa200006011111111111111111160002a
a200000611111111111111111600002aa200000060011111111111106000002aa200000600000000000000000600002aa200000600011111111111100600002a
a200000060011111111111106000002aa200000611111dd666666dd11600002aa200000600000000000000000600002aa2000006111111d666666dd11600002a
b2000000611111d666666dd16000002ab200006111116677777777661160002ab200006000000000000000000060002ab200006111111667777777661160002a
b200000611111667777777661600002ab200061111167777777777776116002ab200060000000000000000000006002ab200061111116777777777776116002a
b200006111116777777777776160002bb200061111177777777777777116002bb200060000000000000000000006002bb200061111117777777777777116002b
b200006111117777777777777160002bb200611111677777777777777611602bb200600000000000000000000000602bb200611111167777777777777611602b
b200061111167777777777777616002bb200611111777777777777777711602bb200600000000000000000000000602bb200611111177777777777777711602b
b222261111177777777777777716222bb222611111777777777777777711622bb222600000000000000000000000622bb222611111177777777777777711622b
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
dddddddddddddddddddddddddddddddd116661111111666111111111111111111111111111111111111111111111111122222222444444444444444444444444
d222222222226666222222222222222d16777611111677761666111111111661116661111111661111d11111111111d12222222244444444444444445ddd4444
d200000000662222666000000000002d677d161111197d1667d1611111116d166677611111116776111d111111111d112222222244444114411444445dddd444
d200000006222222222600000000002d677116111999711667116111111161166d77611111116d761dddd1111111ddd15252525244441111111144445ddddd44
e200000062222222222266666000002d677116119996711667776111999997766177611199116176111d111199999d112525252544441111111144445ddddd44
e200000622222222222221222600002d67777611992677766666111149991666166611119999166111d11111499911d12222222244441111111144445ddddd44
e20000062222e222222222222600002e16666611421666611111111142111111111111114999911111111111421111112222222244441111111144445ddddd44
e20006622e2eee22222212226000002e11111111044111111111111104411111111111110441111111111111044111112222222244441111111144445ddddd44
e2006212eeeeae22221222201600002e0000000000000000000000000ddd00000000522500522500522500000006666644444444444444444444444456dddd44
e2062212eae2e221222220011160002e002222222222222222222200d222d0000000d55d00d55d00d55d0000000ddddd44444444444444444444444456dddd44
e20622222e222222220000111160002e022222222222222222222220d2d2d00000000dd0000dd0000dd00000006666664444444444444aa44aa444445ddddd44
e200622222222200000111111160002e222222222222222222222222d222d00000000000000000000000000000dddddd444444444444aaaaaaaa44445ddddd44
9200060000000001111111111116002e2eeeeeeeeeeeeeeeeeeeeee20ddd000000000000000000000000000006666666444444444444aaaaaaaa44445ddddd44
9200061111111111111111111116002e999999999999999999999999000000000000000000000000000000000ddddddd444444444444aaaaaaaa44445ddddd44
92006111111111111111111111160029dddddddddddddddddddddddd000000000000000000000000000000006666666644444444444499aaaa9944445ddddd44
9200611111116661111111661116002901111111111111111111111000000000000000000000000000000000dddddddd444444444444999aa99944445ddddd44
9200611111667d6111111167d6160029055555555555555555555550000000005555555000000000d555d000000000d544444444444444444444444444444444
920061111167716111aaa1671616002905522225552222555222255000000000552225500d55d000ddddd0000000d5d54444ddd54444d5004444000044440000
a20061111116661111aaaa166116002905222222522222252222225000000000522222500dddd0000222000000d5d5d5444dddd5444dd5004445000044400000
a200611111111111114aaaa1111600290521111252111125211112500000000052aaa2555522555552250000d5d5d5dd44ddddd544ddd50044d5000044000000
a200061111111111110991111116002a0521111252111125211112500000000052aaa25ddd55dddd555d5000d5d5dd0044ddddd544ddd50044d5000044000000
a200061111111111111111111160002a0521111252111125211112500000000052aaa25dddddddddddddd000d5dd000044ddddd544ddd50044d5000044000000
a200006111111111111111111160002a052111125211112521111250000025525ddddd5daddaaaaaadddd500dd00000044ddddd544ddd50044d5000044000000
a200000611111111111111111600002a052111125211112521111250000000005111115dbbbbbddbbbdbd5000000000044ddddd544ddd50044d5000044000000
a200000060011111111111106000002a05dddddd5dddddd5dddddd5005dddddd5555555dddddddddddddd5000110011044dddd6544dd65004465000044000000
b2000000611111d666666dd16000002a051111115111111511111150051111115a5aaa5555555555555552000dd00dd044dddd6544dd65004465000044000000
b200000611111667777777661600002a0555555555555555555555500555555555bb5b5555555555555550000550055044ddddd544ddd50044d5000044000000
b200006111116777777777776160002b05aa5aaaa55aaaaaa5555550055555555555555222222222222225000550055044ddddd544ddd50044d5000044000000
b200006111117777777777777160002b555bbb5bbbbbb55bbbbb5b55055dddddddddddd5555555555555dd000000000044ddddd544ddd50044d5000044000000
b200061111167777777777777616002bd5555555555555555555555dd5dd1111111111dd55555555ddd5dd500000000044ddddd544ddd50044d5000044000000
b222261111177777777777777716222bddddddddddddddddddddddddddd111111111111dddddddddd5d55dd50000000044ddddd544ddd50044d5000044000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb55555555555555555555555555111111111111115555555555d555dd0000000044ddddd544ddd50044d5000044000000
11111111111222244222121100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000800000000000
21212121212122a44a22212100000000000000000000000000000000000000000000000000000000000000000000000000008880000000000088980000000000
12121212121222444422221200000000000000000000000016000000000000000000000000000000000088000000000000881198000000000817198000000000
22222222222222222222222200000000160000000000000166600000000000000016600000000000000811800000000008111748000000008111180000000000
222222222224242424242222000000016c000000000000f66c000000000000001f66c60000000000008117980000000008f11180000000008111118000000000
424242424242424444424242000001f66c00000000000f66c6000000000000ff666cc000000000008811118000000000811f1680000000089ff1168000000000
242424242424444444442424000ff66c6c600000000ff66cc6000000000fff66c66c6c000000000891ff16800000000891666800000000088166680000000000
444444444444444444444444fff66c6cc66c0000fff66cc6cc600000fff6666cc6c6cc6c00000000816668000000000088888000000000000888800000000000
00ffffff000000000fffff0000000000000000000016000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0fddddddf0000000fdddddf00000000000000000015d600000000000000000000000000000000000000000000000000000000000000000000000000000000000
fdd5555ddf000000dd555ddf00000000000000000f55660000000000000000000000000000000000000000000000000000000000000000000000000000000000
fd555555dd000000d55555df0000000000000000f55556000001d600000000000000000000000000000000000000000000000000000000000000000000000000
fd555555dd000000d55555df0000000000000000f555dd6000f55d00000000000000000000000000000000000000000000000000000000000000000000000000
fdd5555ddf000000dd555ddf0000000000000000f5ddd66d0f55dd60000000000000000000000000000000000000000000000000000000000000000000000000
0fddddddf0000000fdddddf00066600000000000fd6d6d660f565660000000000000000000000000000000000000000000000000000000000000000000000000
00ffffff000fffff0fffff000cc666600660c6601d6666001d666600000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000ff00220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000ff0000000faf02002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000faf00000f9af00002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000faafffff99af0000200000001dd60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000faa99999aaf00020000000155dd6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000f9aa99999aaf000022000001555550000000000001dddd6000000000000000000000000000000000000000000000000000000000000000000000000000000
fff999aa9999aaf00000000000f555d6600000000001ddddddd60000000000000000000000000000000000000000000000000000000000000000000000000000
a99999aa9999aaf00000000000f5555560000000000f55d66d660000000000000000000000000000000000000000000000000000000000000000000000000000
0a99999aa99aaaf00000000000f555555d0000000015555555dd0000000000000000000000000000000000000000000000000000000000000000000000000000
00aa999aa99aaaf00100000000f55555d600000000f555555d660000000000000000000000000000000000000000000000000000000000000000000000000000
000aa999aa9aaf40020100000f555dd55560000000f555dd55560000000000000000000000000000000000000000000000000000000000000000000000000000
0000aa99aa9aa9440e0200000f5555dd556000000f55555d6566d000000000000000000000000000000000000000000000000000000000000000000000000000
00000aa99aaaa994090d00000f555555556600000f5555666dd66000000000000000000000000000000000000000000000000000000000000000000000000000
000000aaaaaaa9900a0c00000f5555565d6600000f555ddd55666000000000000000000000000000000000000000000000000000000000000000000000000000
0000000aaaaaa9000b0b0000f555656666660000f555d6655666d000000000000000000000000000000000000000000000000000000000000000000000000000
000000000aaa9000000000001dd6d66666d00000fdd666d6666d0000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
c0c0c0c1c2c0c0c1c2c0c0c1c2c0c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009495959595960094959596009496000000
9dac8f9e8d00008e9dac8f9e8dac8f8e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a4162627a5a600a4a5a5a60015a8a9a9aa
9cbc9f9c9c00009c9cbc9f9c9cbc9f9c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a7b4b53637b5b6a7b4b5b5b6a7b7b8b9b9ba
8c8c8c8c8c8c8c8c8c8c8c8c8c8c8c8c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000999a0000989900999a989900000000999a
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
0001000014050120501605012050120500d0500f0501205016050140500f05023050180501a0501c0501d05024050230501a050170501a0500d0501c0501f0500c05010050110501605014050140500f05016050
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001400000b75110750177500b75110750177500430000000097510e75015750097510e7501575000000000000b75110750177500b75110750177500430000000097510e75015750097510e750157500000000000
001100000c0340e035170501571515050137151671514050180501c0501a0501d0501d0501d050240502305032034320350000032715016003271532715016000000000000000000000001600000000000000000
01120000340343403500000347150160034715347150a600016000160000000000000160000000000003603432021320250000032715016003271532715016000000000000000000000001600177041770017700
00120000397103b7103c71000000397103b7103c71500000397143b7103c7150000000000000000000000000397103b7103c71000000397103b7103c71500000397143b7103c7150000000000000000000000000
0012000039710387103671000000397103871036715000003971438710367150000000000000000000000000397103b7103671000000397103b7103771500000397143b710397150000000000000000000000000
011200002171421710217102171021710217102171021710217102171021710217102171021710217102171524714247102471024710247102471024710247102471024710247102471024710247102471024715
010b00000000003615026150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000d00002a524340253451534715347150a6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000d00002a52434024347150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000a00001715417154171041710500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000a00001814418144171041710500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c00002404424044000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c00003074430744000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c00001153411534000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000d00001d53021535285052900500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000d00001d53021530285352900500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000d00001d530215302d5352f53500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000a00003d6553d6203d625291300e131071250000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000a0000231300e131071250000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c0000000000000000000000001d054230512605126052260522605026052260522605026055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0018000025755297552c7552c7342c715257552573425715000000000000000000000000000000000000000023755277552a7552a7342a7152375523734237152570500000000000000000000000000000000000
011800001971019721197201972019720197201972019720197201972019720197201972019720197201971117710177211772017720177201772017720177201772017720177201772017720177201772017711
011200000261010625066000060010610026150060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
011000000361503615000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
01 41 42 43 08
00 41 42 43 09
00 41 42 0c 08
02 41 42 0c 09
01 41 42 43 1b
00 41 42 43 1b
00 41 42 1c 1b
02 41 42 1c 1b
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
