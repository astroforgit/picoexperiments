pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--inspiration
--by altrix studios

player={}
offset={}
pending_ins=0
playing=false
menu=false
intro=true
inv_view=false
speaking=0
interacting=0
speech={}
inv={}
particles={}
cs_timer=0
cs_state=0


function _init()
 sfx(0)
 pal(5,0,1)
 pal(6,0,1)
 pal(7,0,1)
end

function _update60()
 if intro then
  icount+=1
 elseif menu then
  menu_ctrl()
 elseif playing then
  game_ctrl()

  if (pending_ins>0) inspire()
  if (#particles>0) part_system()
  if cs_state==11 and cs_timer<650 then
   cs_timer+=1
  end
 end
end

function _draw()
 cls()

 if intro then
  logo()
 elseif menu then
  menu_draw()
 elseif playing then
  game_draw()
 end
end
-->8
--main functions

function game_ctrl()
 if btn(2) then
  if move_check(2) then
   player.y-=1
  else door_check(2) end
 elseif btn(3) then
  if move_check(3) then
   player.y+=1
  else door_check(3) end
 end

 if btn(0) and move_check(0) then
  player.x-=1
 elseif btn(1) and move_check(1) then
  player.x+=1
 end

 if btnp(4) then
  if cs_timer==650 then
   game_start()
  elseif interacting>0 or speaking>0 then
   nextline()
  elseif not inv_view then
   try_interact()
  end
 end

 if btnp(5) and cs_timer==0 then
  sfx(3)
  inv_view=not inv_view
 end

 if not (btn(0) or btn(1) or btn(2) or btn(3))
 then 
  player.c=0 
 else
  screen_move()
 end
end

function move_check(d)
 if (interacting>0) return false
 if (speaking>0) return false
 if (inv_view) return false
 if (cs_timer>0) return false

 local t1,t2
 local px,py=player_tile()
 player.c+=1

 if d==0 then
  player.d=true
  if (player.x%8==0) px-=1
  t1=mget(px,py)
  t2=mget(px,py+1)
 elseif d==1 then
  player.d=false
  t1=mget(px+1,py)
  t2=mget(px+1,py+1)
 elseif d==2 then
  if (player.y%8==0) py-=1
  t1=mget(px,py)
  t2=mget(px+1,py)
 elseif d==3 then
  t1=mget(px,py+1)
  t2=mget(px+1,py+1)
 end

 if player.x%8==0 or player.y%8==0 then t2=t1 end

 --if wall in way, return false
 --else return true
 return not (fget(t1,0) or fget(t2,0))
end

function door_check(d)
 local x,y=player_tile()

	if (d==3) y+=1
	if (d==2) y-=1

 for k,v in pairs(doors) do
	 if (v.x==x or v.x==x+1) and v.y==y then
		 sfx(2)
			player.x=v.t.x
			player.y=v.t.y
   offset.x+=v.t.ox
   offset.y+=v.t.oy
		end
	end
end

function player_tile()
 return
 flr(player.x/8)+offset.x,
 flr(player.y/8)+offset.y
end

function screen_move()
 if player.x>124 then
  player.x=-4
  offset.x+=16
 elseif player.x<-4 then
  player.x=124
  offset.x-=16
 end

 if player.y>116 then
  player.y=-4
  offset.y+=16
 elseif player.y<-4 then
  player.y=116
  offset.y-=16
 end
end

function game_draw()
 --draw map
 map(0+offset.x,0+offset.y,0,0,16,16)

 --items
 for v in all(objects) do
  if v.sp>0 and v.ox==offset.x and v.oy==offset.y then
   spr(v.sp,v.x,v.y)
  end
 end

 --npcs
 for v in all(npcs) do
  if v.sp>0 and v.ox==offset.x and v.oy==offset.y then
   local f=v.x>player.x
   spr(v.sp,v.x,v.y,1,1,f)
  end
 end

 --player
 local ps=1
 if (player.c%20>=10) ps=2

 spr(ps,player.x,player.y,1,1,player.d)

 --inspiration bar
 rectfill(0,120,127,127,0)
 spr(48,0,120)
 for i=0,7 do
  spr(49,8+16*i,120,2,1)
 end
 spr(51,120,120)

 if player.i<126 then
  rectfill(1+player.i,121,126,126,13)
 end

 --speech
 if #speech>0 then
  local main_y,name_y=103,95
  if player.y>88 then
   main_y=0
   name_y=16
  end

  rectfill(0,main_y,127,main_y+16,0)
  rect(0,main_y,127,main_y+16,7)
  print(speech[1],2,main_y+2,7)
  print(speech[2],2,main_y+10,7)
  if speaking>0 and speech[3]!="" then
   rectfill(0,name_y,34,name_y+8,0)
   rect(0,name_y,34,name_y+8,7)
   print(speech[3],2,name_y+2,7)
  end
 end

 --notepad
 if inv_view then
  draw_pad()
  print("i need ideas!",23,15,0)
  if player.i==126 then
   line(22,17,60,17,0)
  end

  print("i have:",23,31,0)

  for k,v in pairs(inv) do
   print(v,23,31+k*8,0)
  end
 end

 --particles
 for p in all(particles) do
  pset(p.x,p.y,1)
 end

 --end cutscene elements
 rectfill(160-cs_timer,0,160,127,0)

 local str1="and so he developed a game..."
 local str2="...about developing a game..."
 local str3="...and you've just finished it."
 local str4="press z to play again"

 if cs_timer>230 then
  print(str1,2,16,7)
 elseif cs_timer>215 then
  print(str1,2,16,6)
 elseif cs_timer>200 then
  print(str1,2,16,5)
 end

 if cs_timer>370 then
  print(str2,2,36,7)
 elseif cs_timer>355 then
  print(str2,2,36,6)
 elseif cs_timer>340 then
  print(str2,2,36,5)
 end

 if cs_timer>510 then
  print(str3,2,56,7)
 elseif cs_timer>495 then
  print(str3,2,56,6)
 elseif cs_timer>480 then
  print(str3,2,56,5)
 end

 if cs_timer==650 then
  print(str4,20,76,7)
 elseif cs_timer>635 then
  print(str4,20,76,6)
 elseif cs_timer>620 then
  print(str4,20,76,5)
 end
end

function game_start()
 menu=false
 playing=true
 player={x=32,y=32,i=0,c=0,d=false}
 offset={x=0,y=0}
 cs_timer=0
 cs_state=0

 --reset objects
 for a in all(objects) do
  a.cs=0
 end

 objects[3].is=1
 objects[5].sp=112
 objects[6].sp=114
 objects[7].is=2
 objects[8].is=2

 --reset npcs
 for a in all(npcs) do
  a.cs=0
 end

 npcs[1].is=3
 npcs[2].is=1
 npcs[3].is=1
 npcs[4].is=3
 npcs[7].is=1
 npcs[8].is=1
 npcs[9].is=1
end

function menu_ctrl()
 if btnp(4) then
  if cs_state==1 then
   game_start()
  else
   cs_state=1
   sfx(3)
  end
 end
end

function menu_draw()
 rectfill(0,0,127,127,4)
 draw_pad()

 if cs_state==0 then
  print("inspiration.",42,23,5)
  print("an ld45 entry",40,31,5)
  print("press z to start",34,70,5)
 elseif cs_state==1 then
  print("`start with nothing'?",23,23,5)
  print("how do i make a",23,39,5)
  print("game from that?",23,47,5)
  print("maybe a walk will",23,63,5)
  print("give me an idea...",23,71,5)

  print("press z to continue",23,87,5)
 end

 spr(13,98,38)
 rect(99,46,104,95,9)
 rectfill(100,46,103,95,10)
 spr(45,98,96)
end

function draw_pad()
 rectfill(20,8,107,115,7)
 for i=20,108,8 do
  line(20,i,107,i,12)
 end
 for i=22,107,8 do
  spr(15,i,4)
 end
end
-->8
--misc stuff

function inspire()
 player.i+=0.2
 pending_ins-=0.2
 if (player.i%0.4==0) spawn_particle()

 if player.i>126 then
  objects[2].cs=2
  interacting=20
  speech={
  "i've spent enough time",
  "looking for inspiration.",
  "i need to head back home and",
  "try and start programming..."}
 elseif player.i>0 then
  objects[2].cs=1
 end
end

function spawn_particle()
 local d=rnd()
 local mag=0.3+rnd()

 add(particles,{
  x=1+player.i,
  y=121+flr(rnd(6)),
  vx=cos(d)*mag,
  vy=sin(d)*mag,
  l=20+flr(rnd(9))
 })
end

function part_system()
 for p in all(particles) do
  p.x+=p.vx
  p.y+=p.vy
  p.l-=1

  if (p.l==0) del(particles,p)
 end
end
-->8
--interactions

objects={
{x=96,y=24,ox=0,oy=0,cs=0,is=0,i=0,sp=0},
{x=24,y=24,ox=0,oy=0,cs=0,is=0,i=0,sp=0},
{x=40,y=32,ox=0,oy=16,cs=0,is=1,i=11,sp=0},
{x=80,y=64,ox=32,oy=16,cs=0,is=0,i=0,sp=0},
{x=72,y=88,ox=48,oy=16,cs=0,is=0,i=0,sp=112},
{x=56,y=80,ox=64,oy=16,cs=0,is=0,i=0,sp=114},
{x=56,y=72,ox=64,oy=0,cs=0,is=2,i=10,sp=0},
{x=24,y=40,ox=48,oy=0,cs=0,is=2,i=10,sp=0},
{x=32,y=40,ox=80,oy=0,cs=0,is=0,i=0,sp=0},
{x=88,y=8,ox=32,oy=0,cs=0,is=0,i=0,sp=0}
}

npcs={
{x=32,y=32,ox=16,oy=16,cs=0,is=3,i=18,sp=0},
{x=40,y=32,ox=48,oy=16,cs=0,is=1,i=15,sp=53},
{x=104,y=96,ox=64,oy=16,cs=0,is=1,i=12,sp=54},
{x=32,y=104,ox=0,oy=16,cs=0,is=3,i=20,sp=55},
{x=88,y=24,ox=64,oy=0,cs=0,is=0,i=0,sp=0},
{x=88,y=72,ox=80,oy=0,cs=0,is=0,i=0,sp=56},
{x=80,y=48,ox=16,oy=0,cs=0,is=1,i=10,sp=0},
{x=32,y=80,ox=16,oy=0,cs=0,is=1,i=15,sp=52},
{x=64,y=40,ox=80,oy=0,cs=0,is=1,i=15,sp=0}
}

doors={
{x=12,y=12,t={
 x=96,y=40,ox=0,oy=16}
},
{x=12,y=20,t={
 x=96,y=88,ox=0,oy=-16}
},
{x=58,y=5,t={
 x=56,y=72,ox=32,oy=0}
},
{x=87,y=10,t={
 x=80,y=48,ox=-32,oy=0}
},
{x=37,y=6,t={
 x=72,y=88,ox=-16,oy=0}
},
{x=25,y=12,t={
 x=40,y=56,ox=16,oy=0}
}
}

function try_interact()
 local x1,x2,y1,y2=
 player.x-16,player.x+24,
 player.y-16,player.y+24

 for k,v in pairs(objects) do
  if v.x>=x1 and v.x<=x2
  and v.y>=y1 and v.y<=y2 
  and v.ox==offset.x and v.oy==offset.y
  then interact(k,v) end
 end

 for k,v in pairs(npcs) do
  if v.x>=x1 and v.x<=x2
  and v.y>=y1 and v.y<=y2 
  and v.ox==offset.x and v.oy==offset.y 
  then talk(k,v) end
 end
end

function nextline()
 for i=1,2 do
  del(speech,speech[1])
 end
 if (speaking>0) del(speech,speech[1])

 if #speech==0 then
  local t={}
  if speaking>0 then
   t=npcs[speaking]
   speaking=0
  elseif interacting>0 then
   if interacting!=20 then
    t=objects[interacting]
   else
    t={cs=1,is=2}
   end
   interacting=0
  end

  if t.cs==t.is and t.i>0 then
   pending_ins=t.i
   sfx(1)
   t.is=-1
  end

  if (cs_state==10) cs_state=11
 end
end
-->8
--speech

function interact(i,obj)
 local s=obj.cs
 interacting=i
 if i==1 then
  speech={
  "there's a sticky note",
  "stuck to my wardrobe...",
  "`remember to get dressed",
  "and eat during the compo!'",
  "good thing i wrote myself",
  "this little reminder...",
  "...otherwise i'd actually",
  "forget to do those things..."}
 elseif i==2 then
  if s==0 then
  speech={
  "...nope.",
  "still no ideas.",
  "i need to go for a walk.",
  "maybe that'll inspire me."}
  elseif s==1 then
  speech={
  "i'm still not ready",
  "to start developing.",
  "i need a clear concept...",
  "some clear inspiration..."}
  elseif s==2 then
  cs_state=10
  speech={
  "i got so many ideas from",
  "walking around town...",
  "but i still have no idea what",
  "i should actually make...",
  "...",
  "...wait a second.",
  "i have no code, no ideas...",
  "i'm starting from nothing too!",
  "that's it! i know just what to",
  "make for ludum dare now!"}
  end
 elseif i==3 then
  if s==0 then
  obj.cs+=1
  speech={
  "looks like my tree's grown",
  "some good apples this year.",
  "hmmm...",
  "hang on a minute...",
  "trees start from nothing and",
  "grow to be huge, right?",
  "maybe i could make a game",
  "about growing a tree...?",
  "how would the gameplay",
  "work though? hmmm..."}
  else
  speech={
  "how would a game about",
  "growing a tree work...?",
  "maybe i should look",
  "for another idea."}
  end
 elseif i==4 then
  speech={
  "`east to the park,",
  "north to the king's arms'...",
  "let's see if anything",
  "there inspires me..."}
 elseif i==5 and s==0 then
  obj.cs=1
  obj.sp=0
  npcs[1].cs=2
  add(inv,"dollar")
  speech={
  "oh hey, a dollar!",
  "someone must've dropped it.",
  "this should be enough for",
  "a glass of lemonade...",
  "[you obtained a dollar!",
  "don't spend it all at once!]"}
 elseif i==6 and s==0 then
  obj.cs=1
  obj.sp=0
  objects[7].cs=1
  objects[8].cs=1
  add(inv,"empty can")
  speech={
  "tsk, tsk... who dropped",
  "their empty soda can here?",
  "i'll go find a trash bin",
  "to put this in.",
  "[you obtained a worthless",
  "piece of trash! hooray...?]"}
 elseif i==7 or i==8 then
  if s==1 then
  objects[7].cs=2
  objects[8].cs=2
  del(inv,"empty can")
  speech={
  "[you put the can in the",
  "trash, where it belongs.]",
  "there. i've done my bit to",
  "help the environment.",
  "...you know, this can started",
  "with nothing in it...",
  "...okay, yeah, now i'm just",
  "grasping at straws."}
  else
  speech={
  "it's a trash can. not the most",
  "exciting thing in the world."}
  end
 elseif i==9 then
  speech={
  "a storage closet. probably",
  "full of janitorial supplies.",
  "not getting any ideas from",
  "staring at this thing..."}
 elseif i==10 then
  speech={
  "how come there are so many",
  "roadworks going on today?",
  "i can't really go anywhere",
  "with the roads blocked up..."}
 end
end

function talk(i,obj)
 local s=obj.cs
 speaking=i
 if i==1 then
  if s==0 then
  obj.cs+=1
  speech={
  "hey mister! you wanna",
  "buy some lemonade?",
  "chelsea",
  "i'm saving up to buy",
  "a new games console!",
  "chelsea",
  "what a noble goal!",
  "i'd love to buy a glass!",
  "me",
  "...ah, hang on. i don't",
  "have any change...",
  "me",
  "awww... well come back",
  "if you find some!",
  "chelsea"}
  elseif s==1 then
  speech={
  "still no change?",
  "awww...",
  "chelsea"}
  elseif s==2 then
  obj.cs+=1
  npcs[4].cs=2
  del(inv,"dollar")
  add(inv,"lemonade")
  speech={
  "here you go, young miss!",
  "one lemonade, please!",
  "me",
  "gee, thanks, mister!",
  "here you go!",
  "chelsea",
  "[you received a fresh glass",
  "of ice-cold lemonade!]",
  "",
  "hmm... you know, this",
  "gives me an idea!",
  "me",
  "maybe a tycoon game where",
  "you start with nothing...",
  "me",
  "what's a `tycoon game'?",
  "is it like fortnite?",
  "chelsea",
  "uhh... never mind.",
  "good luck with your stall!",
  "me",
  "thanks, mister!",
  "come again soon!",
  "chelsea"}
  elseif s==3 then
  speech={
  "next time you have change,",
  "buy some more lemonade!",
  "chelsea"}
  end
 elseif i==2 then
  if s==0 then
  obj.cs+=1
  speech={
  "oh, hey, clair, how's your",
  "twitch channel going?",
  "me",
  "it's great! i've got, like,",
  "a thousand followers now!",
  "clair",
  "i never thought it would",
  "get this popular!",
  "clair",
  "well, sure it would!",
  "everyone loves retro games!",
  "me",
  "i guess... hey,",
  "speaking of games...",
  "clair",
  "it's ludum dare weekend.",
  "how come you're out here?",
  "clair",
  "i'm looking for inspiration.",
  "and you know what...",
  "me",
  "going from zero followers to",
  "a world-famous channel...",
  "me",
  "that could actually make",
  "an interesting entry!",
  "me",
  "if you're making a game about",
  "me, i want royalties!",
  "clair",
  "that's not how ludum dare",
  "works and you know it, clair.",
  "me"}
  elseif s==1 then
  speech={
  "if you're making a game about",
  "me, i want royalties!",
  "clair",
  "that's not how ludum dare",
  "works and you know it, clair.",
  "me"}
  end
 elseif i==3 then
  if s==0 then
  obj.cs+=1
  speech={
  "oh, hey. what are you up to",
  "all the way back here?",
  "me",
  "why, i'm feeding the",
  "ducks, of course!",
  "margaret",
  "but there are no ducks",
  "in this pond...",
  "me",
  "not yet! but if they know",
  "someone's here to feed them...",
  "margaret",
  "...they're bound to",
  "start flocking here!",
  "margaret",
  "i'm not sure how sound",
  "that logic is, but...",
  "me",
  "`if you build it, they",
  "will come'... hmmm...",
  "me",
  "got something on your",
  "mind, have you?",
  "margaret",
  "why not sit for a while",
  "and feed the birds?",
  "margaret",
  "sorry, i've got things to",
  "be getting on with.",
  "me",
  "it was nice talking",
  "with you, though!",
  "me",
  "stop by again soon,",
  "won't you?",
  "margaret"}
  elseif s==1 then
  speech={
  "oh, hello again. i do hope",
  "the ducks come by soon...",
  "margaret"}
  end
 elseif i==4 then
  if s==0 then
  obj.cs+=1
  speech={
  "oi, mate! don't suppose",
  "you could spare a drink?",
  "matt",
  "doin' these roadworks",
  "has me parched, innit?",
  "matt",
  "sure, i'll see what",
  "i can get you.",
  "me",
  "ah, cheers, mate.",
  "much appreciated.",
  "matt"}
  elseif s==1 then
  speech={
  "you get me that drink yet?",
  "i'm dyin' out 'ere, innit?",
  "matt"}
  elseif s==2 then
  obj.cs+=1
  del(inv,"lemonade")
  speech={
  "here, how about a",
  "glass of lemonade?",
  "me",
  "ah, cheers!",
  "you're a legend, mate.",
  "matt",
  "gulp... gulp... gulp...",
  "",
  "matt",
  "...ahhh.",
  "yeah, i needed that.",
  "matt",
  "it's thankless work,",
  "this, you get me?",
  "matt",
  "people get bare mad `coz we",
  "shut down the roads, innit?",
  "matt",
  "but if we weren't shuttin'",
  "'em down to fix 'em...",
  "matt",
  "there'd be no roads left,",
  "you get me?",
  "matt",
  "yeah, i... get you, i guess.",
  "it's a necessary evil.",
  "me",
  "(hmm... maybe a city-builder?",
  "start with an empty field...",
  "me",
  "...then build your way",
  "up to a metropolis...?)",
  "me",
  "you alright there, mate?",
  "yer lookin' a bit lost, innit.",
  "matt",
  "i'm alright, thanks. just got",
  "some stuff on my mind.",
  "me",
  "ah, well, i can't help ya",
  "there. i'm just a builder.",
  "matt",
  "cheers again for the drink!",
  "see you around, alright?",
  "matt"}
  elseif s==3 then
  speech={
  "cheers again for the drink!",
  "see you around, alright?",
  "matt"}
  end
 elseif i==5 then
  if s==0 then
  obj.cs+=1
  speech={
  "a friend of ours suggested we",
  "take a picnic here in the park",
  "marlon",
  "it's actually pretty relaxing,",
  "eating out here in the open.",
  "marlon",
  "you should try it sometime,",
  "get some fresh air.",
  "marlon",
  "maybe i will when i don't",
  "have so much stuff to do.",
  "me",
  "then why are you out here",
  "instead of doing that stuff?",
  "sandra",
  "i need some inspiration.",
  "i'm kinda stuck for ideas.",
  "me",
  "oh, you're an artist, huh?",
  "right, that makes sense.",
  "sandra",
  "well, take your time, then,",
  "and see what comes to you.",
  "sandra",
  "that's the plan.",
  "hope you enjoy your picnic!",
  "me",
  "we will, thanks.",
  "see you around!",
  "marlon"}
  elseif s==1 then
  speech={
  "how's the hunt for",
  "inspiration going?",
  "marlon",
  "i've got some ideas, but...",
  "nothing i can use yet.",
  "me",
  "alright, good luck, man!",
  "hope it all works out!",
  "marlon"}
  end
 elseif i==7 then
  if s==0 then
  obj.cs+=1
  speech={
  "you doing okay?",
  "you look kinda lost.",
  "bethany",
  "yeah, i'm just stuck for",
  "ideas for my game jam.",
  "me",
  "say, i don't suppose you",
  "could come up with anything?",
  "me",
  "what comes to mind when i say,",
  "`start with nothing'?",
  "me",
  "uhh...",
  "this pub, oddly enough.",
  "bethany",
  "after my dad passed away,",
  "it ended up in my hands.",
  "bethany",
  "i had no idea how to run a",
  "pub. i was learning as i went.",
  "bethany",
  "i started with no skills,",
  "and... well, here i am.",
  "bethany",
  "five years later, and this",
  "place gets more business--",
  "bethany",
  "--than it did while",
  "my dad was in charge",
  "bethany",
  "does that help at all?",
  "sorry if it doesn't...",
  "bethany",
  "no, no, that did help.",
  "thanks, bethany.",
  "me",
  "hey, no problem.",
  "glad to hear it.",
  "bethany",
  "let me know how your game",
  "goes, i'd love to play it.",
  "bethany",
  "sure thing, bethany.",
  "okay, see you around!",
  "me"}
  elseif s==1 then
  speech={
  "while you're here, why not",
  "grab a beer or two to go?",
  "bethany",
  "sorry, bethany.",
  "i left my wallet at home.",
  "me",
  "oh, sure thing.",
  "have fun being sober, then.",
  "bethany"}
  end
 elseif i==8 then
  if s==0 then
  obj.cs+=1
  speech={
  "you doing okay, vance?",
  "...is your wife doing okay?",
  "me",
  "she's stable... but she's",
  "still in the hospital.",
  "vance",
  "i have no idea when they're",
  "even gonna let me see her...",
  "vance",
  "...let alone when she's gonna",
  "get outta there and come home.",
  "vance",
  "...you ever think about how",
  "relationships work?",
  "vance",
  "you start with two strangers,",
  "with no mutual feelings...",
  "vance",
  "...and then there's a spark.",
  "just this tiny little spark.",
  "vance",
  "and it turns into this...",
  "raging inferno.",
  "vance",
  "but, like... fires always",
  "go out, you know?",
  "vance",
  "from nothing, to an inferno,",
  "then... back to nothing.",
  "vance",
  "you get what i'm trying",
  "to say, right?",
  "vance",
  "i get that you've had a",
  "few too many beers, vance...",
  "me",
  "but that's... actually quite",
  "an interesting thought.",
  "me",
  "a relationships between two",
  "people starts from nothing...",
  "me",
  "thanks for talking about this",
  "with me, vance.",
  "me",
  "i hope things get better for",
  "you... and your wife, too.",
  "me",
  "thanks, dude. you're like...",
  "a genuine saint.",
  "vance",
  "yeah, yeah, miss me with that",
  "`you're my best pal' stuff.",
  "me",
  "no, seriously, you are!",
  "...uhh, i think...",
  "vance",
  "i'll go tell bethany",
  "to cut you off.",
  "me",
  "i already have!",
  "",
  "bethany"}
  elseif s==1 then
  speech={
  "remember what i told you.",
  "it starts with a spark--",
  "vance",
  "--then it grows to an",
  "inferno, then it burns out.",
  "vance",
  "never... *hic*...",
  "never forget that.",
  "vance"}
  end
 elseif i==9 then
  if s==0 then
  obj.cs+=1
  speech={
  "there must be hundreds of",
  "bottlecaps in this jar...",
  "me",
  "yup. been collecting 'em ever",
  "since i started work here.",
  "scott",
  "every single one of 'em, i",
  "found right here in the park.",
  "scott",
  "shame, isn't it? so many",
  "people littering the place...",
  "scott",
  "at first, i collected 'em to",
  "show how bad the litter was.",
  "scott",
  "now i've grown to like the",
  "look and feel o' the things.",
  "scott",
  "you collect anything?",
  "bottlecaps? stamps? pokemon?",
  "scott",
  "i actually do collect pokemon,",
  "now that you mention it.",
  "me",
  "(that's right...",
  "this could fit the theme too!)",
  "me",
  "(collections are something",
  "that start from nothing...)",
  "me",
  "alright, i'm gonna head off.",
  "i've got things to do.",
  "me",
  "pokemon to catch? alrighty.",
  "see you around!",
  "scott"}
  elseif s==1 then
  speech={
  "how's your pokemon collectin'",
  "coming along? catch a good'un?",
  "scott",
  "uhh... yeah.",
  "it's going just fine, thanks.",
  "me",
  "if you find any bottletops,",
  "bring 'em to me, ya hear?",
  "scott",
  "sure, i'll keep an eye out.",
  "see you later!",
  "me"}
  end
 end
end
-->8
--altrix logo

icount=0

function logo()
 if icount>48 then
  pal()
 elseif icount>32 then
  pal(7,6,1)
  pal(6,5,1)
 elseif icount>16 then 
  pal(7,5,1)
 end

 spr(78,55,44,2,3)
 print ("altrix",51,71,7)

 if icount>=180 then 
  intro=false
  menu=true
 end
end
__gfx__
00000000004444000044440099949994bbbbbbbb666d666d55555555aaaa0000aaaa0000aaaaaaaa77ee77ee77e447ee66666666000550000000000006000000
00000000004fff00004fff0099949994bbb3bbbb666d666d55555555aaa0000aaaa0000aaaa9aaaa77ee77ee774e74ee66666666000550000000000006000000
0070070000fbfb0000fbfb0099949994bbbbbbbb666d666d55555555aa0000aaaa0000aaaaaaaaa4ee88ee88e444444866666666000550000000000006000000
0007700000ffff0000ffff0099944444bbbbbbbbdddddddd55555555a0000aaaa0000aaaaaaaaaaaee88ee88e49999486666666600ff5f000000000006000000
0007700000cccc0000cccc0099949994b3bbbbbb666d666d555555555655555555555565a4aaaaaa77ee77ee7499994e6666666600ffff000000000006000000
0070070000fcccf000cfcc0099949994bbbbbbbb666d666d555555555755555555555575aaaaaaaa77ee77ee774444ee6666666600ffff000000000006000000
00000000001111000011110099949994bbbbbb3b666d666d555555555755555555555575aaaaaa9aee88ee88ee88ee88666666660ffffff00000000056500000
00000000001001000001100044449994bbbbbbbbdddddddd555555555755555555555575aaaaaaaaee88ee88ee88ee88666666660ffffff00000000005000000
bbb77bbbbbb77bbb4444444499949994bbbbbbbbbbbbbbbb7777777777777777bbbbbbbbbbbbbbbb77ee77ee77ee77ee0000000009aaaa900000000000000000
bb7776bbbb7776bb4424242499949994bbbbbb333333bbbb7747747774747477bbbbbb333333bbbb774444ee772222ee0000000009aaaa900000000000000000
bb7776bbbb7776bb4242424499949994bbbb33bbbb333bbb7474774747744747bbbb33bbbb333bbbee444488ee4422280000000009aaaa900000000000000000
66777666bb7776bb4444444499944444bb333bbbbbb333bb7777777777777777bb333bbbbbb333bbee404088ee0404280000000009aaaa900000000000000000
66777666b37776bbb3b44bbb99949994b333bbbbb88bb33b73bbbbbbbaaaabb7b333bbbbbb3bb33b774444ff7744442e0000000009aaaa900000000000000000
bb7776bbbb7776bbbbb44bbb99949994b3bbb88bb88bbb3b7bbbbbbbbafffbb7b3bb33bbbbbbbb3b7700004f748888e20000000009aaaa900000000000000000
bb77763bbb77763bbbb44b3b999499943bbbb88bbbbbbb337bbbaa3bafcfcb373bbb3bbbbbbbbb33ee400088ee8884880000000009aaaa900000000000000000
bb6666bbbb6666bbbbb44bbb444499943bbbbbb3bbbbbbb37bbaaabbbffffbb73bbbbbb3bbbbbbb3ee111118e40000880000000009aaaa900000000000000000
bbb77bbbbbb77bbbbbbbbbbb6669966d3bbbbb3bbb88bb3b7777aa77777777773bbbbb3bbbbbbb3b44424442222222224442444209aaaa900000000000000000
bb7776bbbb7776bbbb83bbbb6669966db3b88b3bbb88b3bb7777777777777777b3b3bb3bbbbbb3bb44424442222222224442444209aaaa900000000000000000
bb7776bbbb7776bbb878bbbb6699996dbb38833bbbb33bbb7777777777777777bb33333bbbb33bbb44424442222222229999999909aaaa900000000000000000
667776bbbb777666bb8bbbbbdd7997ddbbbb3333333bbbbb7777777777777777bbbb3333333bbbbb4442222222222222994994990dddddd00000000000000000
667776bbb3777666b3bbb7bb6777777db3bbbbb443bbbbbb6363333333333636b3bbbbb443bbbbbb4442444222222222949499490dddddd00000000000000000
bb7776bbbb7776bbbbbb7a7b6977779dbbbbbbb44bbbbbbb6363333333333636bbbbbbb44bbbbbbb444244422222222299999999088888800000000000000000
bb77763bbb77763bbbbbb73b6499994dbbbbbbb44bbbbb3b6333333333333336bbbbbbb44bbbbb3b444244422222222244424442088888800000000000000000
bb6666bbbb6666bbbbbbbbbbdd4444ddbbbbbb4444bbbbbb6333333333333336bbbbbb4444bbbbbb222244422222222222224442008888000000000000000000
566666666666666666666666666666650088880000eeee000066660000aaaa00001111004477774244cccc4244aaaa4244777742000000000000000000000000
66ccccc11111111cccccccc111111166008fff000eefff00006fff0000aaaaa000111110477777724cccccc24aaaff4247737772000000000000000000000000
6cccccc11111111cccccccc11111111600f3f3000efcfc0006f4f40000f3f30000f4f400777777774cccccc24aacfc4277737777000000000000000000000000
6ccccccc11111111cccccccc1111111600ffff000effff0000ffff0000ffff0000f666007777777741cccc124affff2277377777000000000000000000000000
6ccccccc11111111cccccccc11111116007777000eeeee0000aaaa00009999000011610057777775451111524a11114257373375000000000000000000000000
6cccccccc11111111cccccccc111111600f777f000feeef000faaaf000f999f000f111f0527777255452454544f111f252777725000000000000000000000000
66ccccccc11111111cccccccc111116600cccc0000cccc0000444400001111000055550052522525445555424411114252522525000000000000000000000000
5666666666666666666666666666666500c00c0000c00c00004444000010010000500500522222252252454222f24f4252222225000000000000000000000000
cccccccc777777772222222266666666222222222222222222222222dddd5ddd55555555555555555555555500000000dddd5ddd000000000000000550000000
cccccccc77777777222222226cccccc6222222222444444224444442dddd5ddd55555555555555555555555500000000dddd5ddd000000000000000660000000
cccccccc77777777222222226ccc7cc6222222222444444224444442dddd5ddd55666666666666666666665500000000dddd5ddd000000000000005775000000
cccccccc77777777222222226cc7ccc6222222222444444224444442555555555566666666666666666666550000000055555555000000000000006776000000
cccccccc77777777299299946cc7ccc699942992244aa442244444425ddddddd556666666666666666666655000000005dd88ddd000000000000057667500000
cccccccc77777777299299946c7cccc699942992244aa442244444425ddddddd556666666666666666666655000000005d8888dd000000000000067557600000
cccccccc77777777299499946cccccc69994999224444442244444425ddddddd556666666666666666666655000000005d6886dd000000000000576006750000
cccccccc777777772444999466666666444499922444494224944442555555555566666666666666666666550000000055655655000000000000675005760000
cccccccccccccccc4777777777777774bb6666bb2444444224444442666666665566666666666666666666552222222222622622222222220005760000675000
cccccccccccccccc4777777777777774b6dddd6b2444444224444442644444465566666666666666666666552222222222266222222222220006750000576000
cccccccccccccccc4777777777777774b655556b2444444224444442644444465566666666666666666666552222222222222222222222220057600000067500
00000000c000cccc4bbbbbbbbbbbbbb4b366663b2444444224444442644444465566666666666666666666552222222222222222222222220067500000057600
05555550c0b0cccc4777777777777774b333333b2444444224444442644449465566666666666666666666552dd2dddddddddddddddd2dd20000077777700000
05555550c000cccc4777777777777774b333333b2444444224444442644444465566666666666666666666552dd2dddddddddddddddd2dd20000077777700000
05555550c000cccc4bbbbb3bbbbbbb34b333333b2444444224444442644444465566666666666666666666552dddddddddddddddddddddd20000067777600000
00000000c000cccc4bbbbbbbbbbbbbb4bb3333bb2222222222222222644444465566666666666666666666552dddddddddddddddddddddd20000057777500000
22200222205022224444444411111111444444445555555555555555666666665566666666666666666666550000000000000000000000000000006776000000
22000022200022224444444411111111444444445dddddd55dddddd5622222265566666666666666666666550000000000000000000000000000005775000000
22222222222222220000000011111111444444445dddddd55dddddd5622222265566666666666666666666550000000000000000000000000000000660000000
22222222222222220a0000a011111111444444445dddddd55dddddd5622222265566666666666666666666550000000000000000000000000000000550000000
9994999499949994a00a0a0a11111111444444445dddddd55dddddd5622226265566666666666666666666550000000000000000000000000000000000000000
99949994999499940000000011111111444444445dddddd55dddddd5622222265566666666666666666666550000000000000000000000000000000000000000
99949994999499944444444411111111444444445dddddd55dddddd5622222265555555555555555555555550000000000000000000000000000000000000000
44449994444499944444444411111111444444445dddd6d55d6dddd5622222265555555555555555555555550000000000000000000000000000000000000000
00000000cccccccc0000000011111111444444445dddddd55dddddd5000000000000000000000000000000000000000000000000000000000000000000000000
00000000ccc7cccc0000000011111111444444445dddddd55dddddd5000000000000000000000000000000000000000000000000000000000000000000000000
03333330cccccccc088088dd11111111444444445dddddd55dddddd5000000000000000000000000000000000000000000000000000000000000000000000000
03bbbb30cccccccc087878d011111111444444445dddddd55dddddd5000000000000000000000000000000000000000000000000000000000000000000000000
03bbbb30c7cccccc088788d011111111444444445dddddd55dddddd5000000000000000000000000000000000000000000000000000000000000000000000000
03333330cccccccc088808d011111111444444445dddddd55dddddd5000000000000000000000000000000000000000000000000000000000000000000000000
00000000cccccc7c0000000055555555777777775dddddd55dddddd5000000000000000000000000000000000000000000000000000000000000000000000000
00000000cccccccc0000000055555555777777775555555555555555000000000000000000000000000000000000000000000000000000000000000000000000
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
0000000000000001010000010000000001010101010101010101000000000000010100010101010101010001010000000000000000000000000100000100000001010101010101010101010001000000010101010101010101010101010100000101010101010101010101000000000000010001010101000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000211010101010102023070806062321202110101010101010101010101010101010101010101010101010101010101020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0041414141414141414141414141410000000000000000000000000000000000110404040404040405060607080504111104040404040404040404040404040404040404040404181904040404040411000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0041405051404040404040404546410000000000000000000000000000000000110448494949494a05060606060504111104041819040404484949494a040404040418190404042829040a0a0a181911000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0041426061440303030303035556410000004141414141414141414141410000110468696969696a05060606060504111104042829040404686969696a040404040428290404040404041a0b1b282911000000414141414141414141410000000000000000000000000000000000000000000000000000000000000000000000
004103030303030303030303030341000000412b2b2b2b2b2b2b2b2b2b4100001104646464646464050606060605041111040404040404046363636363040404040404040404042204040a0a0a04041100000041656647474c474747410000000000000000000000000000000000000000000000000000000000000000000000
004103030303030303030303030341000000412a2a3a2a2a2b2a3b2a2a4100001104644364626464050606060605041111040454045253047373577373040404040404525304040404040404040404110000004175760c5b5c5d0c0c410000000000000000000000000000000000000000000000000000000000000000000000
004103030303030303030303030341000000412a3a393a2a2b2b2b2b2b410000110474747457747405060606060504111104040909090909090909090909090909090909090909040404040404040411000000410c0c0c0c0c0c0c0c410000000000000000000000000000000000000000000000000000000000000000000000
004103030303030303030303030341000000412a2a3a2a2a3a3a3a3a3a410000110405050505050505060606060504111104040409090909090909090909090909090909090909090904040404040411000000410c0c0c0c0c0c0c0c410000000000000000000000000000000000000000000000000000000000000000000000
004103030303030303030303030341000000412a2a2a2a2a2a2a2a2a2a410000110405060606060606060606060504111104040404090909090971710404040404040404040409090909040418190411000000410c0c0c0c0c0c0c0c410000000000000000000000000000000000000000000000000000000000000000000000
004103030303030303030303030341000000412a2a3a2a2a2a2a2a3a2a410000110405060606060606060606060504111104040404040909097171717171040404040404040404540909090428290411000000410c0c0c0c0c0c0c0c410000000000000000000000000000000000000000000000000000000000000000000000
004103030303030303030303030341000000412a3a3c3a2a2a2a3a393a410000110405060606060606060606060504111118190404040909097171717171040404040404040404040409090404040411000000414141415941414141410000000000000000000000000000000000000000000000000000000000000000000000
004103030303030303030303030341000000412a2a3a2a2a2a2a2a3a2a410000110405060606060606060606060504111128290418190409090971717104040404041819040404040409090904040411000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
004141414141414141414141134141000000414141414141412c414141410000110405060606060505050505050504212004040428291819090909040404040404042829041819040404090904220411000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000110405060606060504040404040404040418190404042829040909090404040404040404042829040404090904040411000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000110405060606060504040404040404040428291819040404040409090904040404040404040404040404090904040411000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2110101010101010104849494949494a211010101010104849494949494a1010200405060606060504040404040404040418192829040404040404090904040404040404040404040404090904040411000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1104040404040404046869696969696a110404040404046869696969696a0404040405060606060504040404181904040428290404040404040404090904040404040404040404040404090904040411000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1104040404040404044747474747474711040404040404474747474747470404040405060606060504040404282904040404040404041819040409090904040404041819040404040404090904040411000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1104040414150404044743474747434711040416170404474347474743470404040405060606060504040404040404040404040404042829040409090404040404042829041819040409090904040411000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1104040424250404044747475747474711040426270404474747674747470404040405060606060509090909090909090909090909045253040909090404040404040404042829040409090404040411000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1104040404040404040404220522040404040404040404040404050404040404040405060606060509090909090909090909090909090909090909040404040404040404040404040909090404040411000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1104040404040404040404220522040404040404040404040404050404040404042205060606060504040404040404040404181909090909090904041819040404040418190404090909041819040411000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1105050505050505050505050505050505050505050505050505050505050505050505060606060504120404041819040404282904090909090418192829040404040428290409090904042829040411000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1105060606060606060606060606060606060606060606060606060606060606060606060606060504040404042829040404040404040909090428290404040404040404040909090404040404040411000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1105060606060606060606060606060606060606060606060606060606060606060606060606060504040404040404040418197171040909090904040404040404525309090909040404717104040411000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1105060606060606060606060606060606060606060606060606060606060606060606060606060504040404181904040428297171040409090909090909090909090909090904047171717104040411000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1105060606060606060606060606060606060606060606060606060606060606060606060606060504041819282904040404717171710404090909090909090909090909040404717171717104040411000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1105060606060505050505050505050505050505050505050505050505050505050505050505050504042829040404040404717171717104040404040404040404040404040404717171717104040411000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1123070806060504040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404047171710404040411000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1105060607082321101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000300000201005010080200b0200e0301103014040170401a0501d0501f060200602107021070210702107021070210702107021070200601f0601d0501a0501704014040110300e0300b020080200501002010
00020000081700b1700e17011170121000200003000030000c1700f17012170151701410016100181001a1001017013170161701917017000190001f1002110014170171701a1701d1702d00033000370003d000
0002000006650096500b6500d6500d600000000000000000000001e6501e6501e6501e65018600176001760000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000086100761006620066200563005630056400564006650086500c650116501865026650316503a650040000000001600066500365001650146001b6000000000000000000000000000000000000000000
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
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
