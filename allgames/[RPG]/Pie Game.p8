pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
-- pie game
-- by droodlebean
-- setup

function _init()
 tog=0
 part={}
 ink=0
 finale=-1
 
 player_setup()
 box_setup()
 text_setup()
 push_setup()
 event_setup()
 chicken_setup()
 reset_basement()
 draw_map()
 blob_setup()
end

function text_setup()
	t={clock=1}
	
	text=nil
	t_table={}
	t_num=1
	icon=64
	
	
	popup("interact--—     pie recipe--Ž")
	
 bank={}
 add_bank(8,3,{"66:home sweet.    \n...         \nwouldn't you say?"})
 add_bank(99,7,{"66:chicken house!\nbeware!","102:i hate getting ahold\nof eggs in this town."})
 add_bank(10,24,{"you can't get back\nto sleep."})
 add_bank(10,25,{"you can't get back\nto sleep."})
 add_bank(8,20,{"you quicklly wash your\nhands."})
 add_bank(118,5,{"the sink is full of\nsome sort of tea...","100:benzy has interesting\ntaste."})
 add_bank(117,5,{"there is a single\nextremely large tea\nbag on this shelf.","102:smells like...\nbacon?"})
 add_bank(8,37,{"96:welcome to my place\nof purchasing! what\ncan i get you?","100:well, i'm working on\nmaking a pie, but i'm\nlow on ingredients.","96:well isn't it your\nlucky day! i've got a\npair of running shoes,","96:a wooden sword, and\na bag of sugar!","102:only one of those is\nan ingredient in pie.","96:you never know!"})

 add_bank(74,7,{"72:here lies mable,\nthere was such a thing\nas to many sweaters."})
 add_bank(69,4,{"72:here rests mizzix,\nwho had far too many\nknives."})
 add_bank(72,4,{"72:rest in piece rob,\n'two ballons will be\nplenty'"})
 add_bank(74,4,{"72:forever gone, jophrey,\nunfortunately the\nonly necromancer."})
 add_bank(69,7,{"72:here lies boffin,\nhe never could stand\nspicy food."})
 add_bank(71,7,{"72:rest in piece mandy,\ni wish you returned my \nvacuum cleaner."})
 add_bank(77,28,{"72:this grave is marked\nonly with a spiral\nrose.","102:..."})

 add_bank(59,7,{"66:benzy's gift shop"})
 add_bank(123,11,{"there's a strangley\ncomplex depression in\nthe matress...","100:is *that* what benzy\nlooks like?"})
 add_bank(123,12,{"there's a strangley\ncomplex depression in\nthe matress...","100:is *that* what benzy\nlooks like?"})
 add_bank(7,20,{"...","you don't remember\nbuying most of these."})
 add_bank(6,20,{"one of these books is\ntitled 'juice!' in\nbold green letters."})
 add_bank(5,36,{"there's a bottle of\nblack flakes labled\n'snake powder'","...       \nit's obviously \npepper."})
 add_bank(6,36,{"one of these is a \nbook on...","100:mummificaation?","96:it's a skill every\ngentalman should\nlearn!","102:......."})
 add_bank(10,36,{"102:are these...?","96:fingers! the good\nkind. they're on sale\nif you like!","100:thanks, no. i don't\nthink i'd like\nfingers in my pie.","96:suit yourself!"})
 
 add_bank(4,9,{"there are some letters\ncarved in the base of\nthis tree.","...","102:'cool beans.'"})
 add_bank(114,19,{"there is a pile of\nforeign coinage here."})
 add_bank(115,19,{"a glass jar labled\n'swear jar'.","it's overflowing with\nbird seed."})
 add_bank(122,19,{"looks like a set of\nrussian nesting dolls\npainted like chickens."})
 add_bank(123,19,{"a framed photo of an\negg."})
 add_bank(124,19,{"it's a model of a\nwooden chair.","100:it's sample sized!"})
 add_bank(116,19,{"there's a book titled\n'a practical guide to\nspotting secret rocks'","102:this doesn't seem like\na good time to be\nreading."})
end

function add_bank(x,y,messages)
 bank[x+y*128]=messages
end

function get_text(input)

 if (not text) t_num=0

 if input then
  t.clock=0
  t_num+=1
  t_table=split(input[t_num],":")
  if t_table then
   if #t_table==2 then
		  text=t_table[2]
		  icon=t_table[1]
		 else
		  text=t_table[1]
		  icon=64
		 end
		 sfx(0)
   pl.state=33
		else
		 text=nil
		end
	end
	
 if not text 
 and sw.clock<1 then
  pl.state=1
 end
end
-->8
-- game loop

function _update()
	if finale==-1 then
	 if (btn(—)) music(0,0,0) finale=0
	elseif finale<4 then
	 -- chicken
	 if (camx/8==112 and camy/8==16) chicken_update()
	 -- player
	 if (not agro) player_update()
	 
	elseif finale==4 then
	 if btn(—) then
	  get_text({"199:the pie was excellent.\nand everyone thought\nit was very good.",
	   "199:the end."
	  })
	  if (text==nil) finale=5 ink=0
	 end
	elseif finale==5 then
	 text="thanks for playing!"
	 icon=201
	end
	
	endgame()
end

function _draw()
	if finale>-1 then
	 cls()
	 draw_map()
	 draw_push_block()
	 
	 if (camx/8~=112 or camy/8~=32) draw_player()
	 draw_chicken()
	 
	 draw_sword()
	 if (ink>0) ink_screen()
	 
	 particle_update()
	 
	 text_box()
	 
	 draw_menu()
	 draw_popup()
	else
	 cls()
	 local blobx=rnd(16)
	 for d=0,8 do
	  add_blob(blobx+d*16,128)
	 end
	 draw_blobs()
	 circfill(65,193,21,2)
	 circfill(65,192,21,9)
	 print("pie game",50,181,8)
	 print("pie game",50,180,15)
	 print("[ press — ]",42,200,8)
	 print("[ press — ]",42,199,15)
	end

end

function ink_screen()
	if ink<15 then
	 for x=camx,camx+127 do
	  for y=camy,camy+127 do
	   local pi=pget(x,y)-ink
	   if (pi<0) pi=0
	   pset(x,y,pi)
	  end
	 end
  ink+=3
 else
  rectfill(camx,camy,camx+127,camy+127,0)
  pl.x=114*8  pl.y=33*8
 end  
end

function endgame()
 if all_ingredients() then
	 if (finale==0 and text==nil) finale=1 
	 if finale==1 then
	  get_text({"100:hey, it looks like\ni've got everything i\nneed to make that pie!",
	  })
	  finale=2
	 elseif finale==2 then
	  if btnp(—) then
		  get_text({"100:hey, it looks like i've\ngot everything to make\nthat pie!",
		  "your thoughts turn to\nthe fistfull of butter\nin your pocket.",
		  "briefly. you stop \nthinking about it.\nvery hard.",
		  "100:i'll just work my way\nback home."
		  })
		  if (text==nil) finale=3
	  end
	 end
	end
end
-->8
-- player

--[[ states:
1-idle
17-walk
33-interact
]]

function player_setup()
 pl={
  sp=1,
  x=64, --64
  y=184, --184
  dx=0,
  dy=0,
  spd=1,
  flp=false,
  state=1,
  state2=1,
  clock=0,
  tap=0
 }
 sw={
  sp=48,
  x=0,
  y=0,
  dx=0,
  dy=0,
  flpx=false,
  flpy=false,
  clock=0
 }
 inv={
	 apple=0,
	 sugar=0,
	 butter=0,
	 egg=0,
	 flour=0,
	 
	 coin=0,
	 shoes=0
 }
 sword=false
 tap_clock=0
 run_clock=0
 incheck=false
 
 finale=-1
end

function player_update()

 water()
 if pl.state~=33 then
  if (inv.shoes~=0) double_tap()
  pl.state=1
	 step(‘,1,0)
	 step(‹,-1,0)
	 step(”,0,-1)
	 step(ƒ,0,1)
	 step_sfx()
	end
	
	if btn(—) 
	and incheck
	and (finale==0 or finale==3) then
	 interact()
	end
	incheck=false
 if (not btn(—)) incheck=true

end

function draw_player()
 player_animate()
 spr(pl.sp,pl.x,pl.y,1,1,pl.flp)
 if (fget(mget((pl.x+4)/8,(pl.y+4)/8),4)) spr(210,pl.x,pl.y)
end

function step(aim,x,y)
 if btn(aim) then
  pl.state=17
  
	 for r=1,pl.spd do -- speed
	 
	  pl.dx+=1*x  pl.dy+=1*y
	  box_update()
	  
	  if (map_col(pl.dx,pl.dy,0)) pl.dx=0  pl.dy=0
	  
	  pl.x+=pl.dx  pl.y+=pl.dy
	  pl.dx=0      pl.dy=0

	 end
 end
end

function step_sfx()
 if btn(‘)
 or btn(‹)
 or btn(”)
 or btn(ƒ) then
  pl.tap+=1
  if pl.tap>=5 then
   pl.tap=0
   sfx(2)
  end
 else
  pl.tap=4
 end
end

function player_animate()

 -- reset timer on state change
 if pl.state~=pl.state2 then
  pl.clock=0
 end
 pl.state2=pl.state
 
 -- local variables
 local state=pl.state
 local spd=1
 local loop=true
 
 -- animation data
 if state==1 then
  spd=2
 elseif state==17 then
  spd=5
 elseif state==33 then
  spd=5 loop=false
 end
 
 -- up timer, and change sprite
 pl.clock+=spd
 local clock=pl.clock
 
 if clock>40 then
  if loop==true then
   pl.clock=0
  else
   pl.clock=99
 end
 
 elseif clock>30 then
  pl.sp=pl.state+3
 elseif clock>20 then
  pl.sp=pl.state+2
 elseif clock>10 then
  pl.sp=pl.state+1
 else
  pl.sp=pl.state
 end
 
 -- flip character
 if btn(‘) then
  pl.flp=false
 end
 if btn(‹) then
  pl.flp=true
 end
 
end
-->8
-- map / menu

function draw_map()

  mapx=flr((pl.x+4)/128)*16
  mapy=flr((pl.y+4)/128)*16
  camx=mapx*8
  camy=mapy*8
  camera(camx,camy)
  
  toggle_tiles()
  map(0,0,0,0,128,48)
  
end

function map_col(dx,dy,flag)
 
 local x1=flr((pl.x+dx)/8)
 local y1=flr((pl.y+dy+3)/8)
 local x2=flr((pl.x+dx+7)/8)
 local y2=flr((pl.y+dy+7)/8)
 
 if fget(mget(x1,y1),flag) 
 or fget(mget(x1,y2),flag)
 or fget(mget(x2,y1),flag)
 or fget(mget(x2,y2),flag) then
  return true
 end
 
end

function draw_menu()

 local x1=camx+32  local y1=camy+32
 local x2=camx+96  local y2=camy+96
 
 if btn(Ž) then
 
  rectfill(x1,y1,x2,y2,15)
  rect(x1+1,y1+1,x2-1,y2-1,9)
  
  print("homade apple \npie recipe:",x1+4,y1+4,2)
  
  print("apples-----"..inv.apple.."/8",x1+4,y1+20,2)
  print("sugar------"..inv.sugar.."/2",x1+4,y1+26,2)
  print("butter-----"..inv.butter.."/1",x1+4,y1+32,2)
  print("egg--------"..inv.egg.."/1",x1+4,y1+38,2)
  print("flour------"..inv.flour.."/1",x1+4,y1+44,2)
  print("money------"..inv.coin.."$",x1+4,y1+55,2)
 end
end

function popup(script)
 pop=script
	pclock=90
	popy=3
end

function draw_popup()
 local y=camy+128
 if pclock>0 then
  if pclock>80 then
   popy-=1
  elseif pclock>10 then
  else
   popy+=1
  end
  rectfill(camx,y+popy,camx+128,y+popy+6,8)
  line(camx+1,y+popy-1,camx+126,y+popy-1)
  print(pop,camx+2,y+popy+1,7)
  pclock-=1
 else
  popy=3
 end
end

function toggle_tiles()
 if tog>20 then
  tog=0
	 for x=0,15 do
	  for y=0,15 do
	   local x2=x+camx/8  
	   local y2=y+camy/8
	   if get_flag(x2,y2)==35 then
	    mset(x2,y2,mget(x2,y2)+192)
	   elseif get_flag(x2,y2)==67 then
	    mset(x2,y2,mget(x2,y2)-192)
	   end
	   
	   if mget(x2,y2)==74
	   or mget(x2,y2)==75 then
	    local r=flr(rnd(8))
	    if (r==0 or r==1) mset(x2,y2,75)
	    if (r==2) mset(x2,y2,74)
	   end
	  end
	 end
	end
	tog+=1
end

function get_flag(x,y)
 return fget(mget(x,y))
end

-- double tap to run
function double_tap()
 if move_keys() and dtap then
  if tap_clock>0 then
   tap_clock=-40
  else
  if (tap_clock>-100) tap_clock=6
  end
 end
 
 dtap=true
 if (move_keys()) dtap=false
 
 if (tap_clock>0) tap_clock-=1
 pl.spd=1
 if tap_clock<0 then
  pl.spd=2 
  tap_clock+=1
  local spec=flr(rnd(2))
  if (spec~=0 and move_keys()) add_particle(32,pl.x,pl.y+4)
 end
end

function move_keys()
 if btn(‘)
 or btn(‹)
 or btn(”)
 or btn(ƒ) then
  return true
 end
end

function all_ingredients()
 if  inv.apple>=8
 and inv.sugar>=2
 and inv.butter>=1
 and inv.flour>=1
 and inv.egg>=1 then
  return true
 end
end
-->8
-- interact / sword

function box_setup()
 bx=0
 by=0
 aimx=0
 aimy=0
end

function box_update()
 bx=flr((pl.x+4)/8) 
 by=flr((pl.y+4)/8)
 aimx=pl.dx
 aimy=pl.dy
 bx+=aimx
 by+=aimy
end

function interact()
 
 if sword==true 
 and not fget(mget(bx,by),1)  
 and sw.clock<1
 and pl.state~=33 then
  -- do a sword
  sfx(6)
  pl.state=33
  sw.clock=13
	 
	end
	
	
	get_text(bank[bx+by*128]) 
	get_event()
 

end



-- sword
function draw_sword()
 if sw.clock>0 then
  
  sw.x=pl.x+sw.dx
  sw.y=pl.y+sw.dy
  if sw.clock<10 then
   spr(sw.sp,sw.x,sw.y,1,1,sw.flpx,sw.flpy)
  end
  
  sw.clock-=1
  
  if (sw.clock==0) pl.state=1

  -- run chop
  if fget(mget(bx,by),3)
	 and sw.clock==9 then
	  chop()
  end
  
 else
 -- set the aim of the sword
  sw.dx=aimx*8
  sw.dy=aimy*8
  sw.sp=48
  
  if (aimy~=0) sw.sp=49
  
  if aimx<0 then
   sw.flpx=true
  else
   sw.flpx=false
  end
  
  if aimy>0 then
   sw.flpy=true
  else
   sw.flpy=false
  end
  
 end
end
-->8
-- text / particles

function text_box()

 local x1=camx+6   local y1=camy+96
 local x2=camx+121 local y2=camy+120
 
 if text~=nil then
  rectfill(x1,y1,x2,y2,15)
  rect(x1+1,y1+1,x2-1,y2-1,9)
  
  rect(x2-19,y1+5,x2-4,y2-4,5)
  spr(icon,x2-20,y1+4,2,2)
 
	 local sub_text=sub(text,1,t.clock)
	 if (t.clock<70) t.clock+=1
	 
	 print(sub_text,x1+4,y1+4,2)
 
 else
  t.clock=1
 end
 
end

-- particles

function particle_update()
 for p in all(part) do
  p:update()
 end
 for p in all(part) do
  p:draw()
 end
end

function add_particle(sp,x,y)
 add(part,{
  sp=sp,
  x=x,
  y=y,
  dx=(rnd(2)-1)/2,
  dy=(rnd(2)-1)/2,
  life=8+flr(rnd(5)),
  
  draw=function(self)
   spr(self.sp,self.x,self.y)
  end,
  
  update=function(self)
   self.y+=self.dy
   self.x+=self.dx
   
   self.life-=1
   
   if (self.life<0) del(part,self)
  end
 })
end
-->8
-- events

function get_event()
--location based
 if (levent(8,26))  door(56,24)
 if (levent(7,2))   door(64,200)
 if (levent(58,6))  door(64,41*8)
 if (levent(8,42))  door(464,56)
 if (levent(11,36)) apple_shelf()
 if (levent(61,5))  secret_door(984,32)
 if (levent(123,3)) door(488,48)
 if (levent(4,40))  door(912,48)
 if (levent(114,5)) door(32,328)
 if (levent(102,7)) door(928,224) chicken_setup()
 if (levent(116,29))door(816,64)
 if (levent(76,42)) secret_door(872,312) reset_basement()
 if (levent(109,38))door(608,328)
 if (levent(103,19))door(592,224)
 if (levent(74,29)) door(824,160)
 if (levent(100,28))coffee()

--sprite based
 if (sevent(59)) oven()
 if (sevent(79)) sword_get()
 if (sevent(31)) pick("apple")
 if (sevent(91)) pick("coin")
 if (sevent(77)) shop_item("sugar")
 if (sevent(76)) shop_item("shoes")
 if (sevent(92)) shop_item()
 if (sevent(60)) push_block()
 if (sevent(22)) sword_fan()
 if (sevent(214))sword_fan()
 if (sevent(21)) old_man()
 if (sevent(213))old_man()
 if (sevent(5))  princess()
 if (sevent(53)) princess()
 if (sevent(197))princess()
 if (sevent(245))princess()
 if (sevent(209))pick("egg")
-- chests
 if (sevent(123)) then
  if levent(123,13) then
   get_text({"this box if full of...\nbutter?","this fills youe mind\nwith questions...","what kind? it's far to\norange to be normal\nbutter.","what is it's pupose?\nin a box at the foot\nof the bed?","it apears untouched,\na flawless golden\nplane of butter","it does however,\nsmell delicious.","you brace yourself\nand scoop a handfull\ninto your pocket.","100:.........","..."})
   if (not text) pick("butter")
  elseif levent(98,29) then
   pick("flour")
  else
   pick("coin")
  end
 end
end

function sevent(tile)
	 if (mget(bx,by)==tile) return true
end

function levent(x,y)
 if (bx==x) and (by==y) then
  return true
 end
end

--:: event functions ::--------
function oven()
 if finale<3 then
  get_text({"100:a pie making oven if\ni've ever seen one."
  })
 elseif finale==3 then
  get_text({"100:alright! let's do this.",
  "that day you make pie\nvery good. some would\nsay the best.",
  "you set the pie \ncarefully into the\noven.",
  "checking the cooking\ntime again, you decide\nthat it's nap time.",
  "setting your alarm,\nyou stretch and take\na well deserved nap."
  })
  if (text==nil) ink=8 finale=4
 end
end

function door(x,y)
 bx=0
 sfx(1)
 pl.x=x
 pl.y=y
end

function pick(var)
 sfx(5)
 pl.state=33
 inv[var]+=1
 mset(bx,by,mget(bx,by)-1)
 popup("* "..var.." get!")
end

function sword_get()
 sfx(5)
 pl.state=33
 sword=true
 mset(bx,by,mget(bx,by)-1)
 popup(" use sword to break bushes--—")
end

function chop()
 sfx(7)
 for l=0,3 do
  add_particle(32,bx*8,by*8)
 end
 if (mget(bx,by)==39) flowers-=1
 mset(bx,by,mget(bx,by)-1)
 
 if (levent(28,28)) poof(39,20,25)
 if (levent(20,25)) poof(39,25,19)
 if (levent(25,19)) poof(39,27,25) poof(39,19,19)
 if (levent(27,25)) poof(39,22,28) poof(39,21,18)
 if (levent(19,19)) poof(39,19,25) poof(39,29,21)
end

function poof(tile,x,y)
 for l=1,10 do
	 add_particle(16,x*8,y*8)
	end
	mset(x,y,tile)
end

function secret_door(x,y)
 if mget(bx,by)~=106 then
  sfx(8)
  poof(106,bx,by)
 else
  door(x,y)
 end
end

function shop_item(item)
 if inv.coin>0 then
  inv.coin-=1
  sfx(8)
  poof(41,bx,by)
  if inv[item] then
   inv[item]+=1
   if item=="shoes" then
    popup("double tap move to run")
   else
    popup("* "..item.." get!")
   end
  else
   sword_fan_var+=1
   popup("* toy sword get!")
  end
 else
  get_text({"96:it doesn't look like\nyou have any money...","100:whoops, yeah. i'll\ncome back later."})
 end
end

function get(item)
 popup("* "..item.." get!")
 sfx(8)
 inv[item]+=1
end

function coffee()
 get_text({"there's a cup of coffe\nhere. it looks cold\nand dusty.",
 "102:* sip",
 "100:yep, cold and dusty.",
 "\^h* you got the zoomies!"
 })
 if (text==nil) tap_clock=-300
end
-- :: npcs :: -------
function event_setup()
 sword_fan_var=0
 flowers=14 --14
 princess_var=0
 app_shelf_var=0
end

function sword_fan()
 if sword_fan_var==0 then
  get_text({"98:dang, swords are \nawsome.",
  "100:awsome, yeah, cool...\ncould you scoot over?",
  "98:i wish i had \na sword...",
  "102:..........."})
 elseif sword_fan_var==1 then
  get_text({"100:hey, kid. how would \nyou like a sword?",
  "98:whoah, a real sword!?",
  "64:* you hand over the\ntoy sword",
  "98:hyah! wha! thanks\nmister!"})
  if (text==nil) poof(61,bx,by) sfx(8)
 end
end

function old_man()
 if flowers>0 then
  get_text({"70:achooo!",
  "100:are you alright?",
  "70:there's too many \nflowers here!\nmy alergies hate it.",
  "100:do you want me too\nget you some-",
  "70:since you offered,\nyou could destroy all\nthese flowers!",
  "102:destroy all of the\nflowers.",
  "70:yep! there's a juicy\napple with your name\non it if you do!",
  "102:...        \ni'll get to it."})
 elseif flowers==0 then
  get_text({"70:what's this feeling...\ni think my allergies\nhave cleared up!",
  "70:that must mean you\ndid it! you vanquished\nmy alergenic enemies!",
  "203:now i can reval my\ntrue form!",
  "203:hahahaha!\nhahahahahahaha!\nhahahahahahahahahahaha!",
  "102:......",
  "70:oh, yes. what do i owe\nyou?",
  "100:ummm... an apple?",
  "203:* he holds out a hand\nand the very universe\nwarps around it.",
  "203:* starting with the\ncore, layer by layer,\na perfect apple forms.",
  "203:* you can almost taste\nit's perfect curviture.",
  "70:here you go kiddo,\nbring me back a slice\nof pie when your done!",
  "100:...alright.\nthank you sir!"
  })
 if (text==nil) get("apple") flowers=-1
 elseif flowers==-1 then
  get_text({"203:yes, yes i think this\nsuits me very well.",
  "100:..."
  })
 end
end

function apple_shelf()
 if app_shelf_var==0 then
  get_text({"there's a dusty apple\non this shelf...\nlooks ripe.",
  "102:i'll just be\ntaking this..."
  })
  if (text==nil) get("apple") app_shelf_var+=1
 end
end

function princess()
 if princess_var==0 then
  get_text({"100:i wasn't going to\nrescue a princess\ntoday, but here we are.",
  "68:i don't need to be\nrescued, thanks for\nthe thought though.",
  "68:this *seemed* like\na quiet place to\nenjoy my bag of sugar.",
  "100:oh, i'm actually \nlooking for sugar-"
  })
  if (text==nil) prin_poof(19,41)
 elseif princess_var==1 then
  get_text({"68:oh, you again. it\nlooks like you took\nthe ornemental sword.",
  "68:i preffered this area\nwith the sword... i'll\ngo find somwhere else.",
  "100:wait!\ncan i borrow some-",
  })
  if (text==nil) prin_poof(75,27)

 elseif princess_var==2 then
  get_text({"100:don't vanish again!!\ndo you have any more\nsugar in that bag!",
  "68:geeze dude, alright.\nwhat do you need sugar\nfor anyway?",
  "100:i'm making a pie,\nan apple pie.",
  "102:turned out i was a\nlittle short in the\ningredient departmrnt.",
  "68:well, i'm glad i can\nhelp...",
  "68:i assume you'll lend\nme a slice of pie in\nreturn?",
  "100:oh! sure! i'll save\nyou a slice." 
  })
  if (text==nil) princess_var+=1 get("sugar")
 elseif princess_var==3 then
  get_text({"68:i'll be looking\nforward to that pie.",
  "100:i'll get to it!"
  })
 end
end

function prin_poof(x,y)
 princess_var+=1
 sfx(8)
 poof(12,bx,by)
 poof(53,x,y)
end
-->8
-- push puzzles / chicken

function push_setup()
 pb={
  x=0,
  y=640,
  dx=0,
  dy=0
 }
end

function push_block()
 if fget(mget(bx+aimx,by+aimy),2) then
  sfx(6)
  pb.x=bx*8     pb.y=by*8
  pb.dx=3*aimx  pb.dy=3*aimy
  pb.x+=aimx*2  pb.y+=aimy*2
  mset(bx,by,61)
 end
end

function draw_push_block()
 local x=pb.x/8
 local y=pb.y/8
 
 if mget(x,y)~=63 then
  spr(60,pb.x,pb.y)
 end
 
 if (pb.dx>0) pb.x+=2 pb.dx-=1
 if (pb.dx<0) pb.x-=2 pb.dx+=1
 
 if (pb.dy>0) pb.y+=2 pb.dy-=1
 if (pb.dy<0) pb.y-=2 pb.dy+=1
 
 if x==flr(x)
 and	y==flr(y) then
  if mget(x,y)==62 then
   sfx(8)
   poof(63,x,y)
  elseif mget(x,y)==61 then
   mset(x,y,60)
   pb.x=-8
   pb.y=-8
  end
 end
end

function reset_basement()
 reset_puzzle(32,96,102,35)
 reset_puzzle(24,96,102,22)
 pb.x=-8
 pb.y=-8
end

function reset_puzzle(x1,y1,x2,y2)
 for x=0,4 do
  for y=0,6 do
   local pi=sget(x1+x,y1+y)
   if (pi~=0) mset(x2+x,y2+y,pi+59)
  end
 end
end

function water()
 if fget(mget((pl.x+4)/8,(pl.y+4)/8),4) then
  if (not map_col(0,-1,0)) pl.y-=1
 end
end

function chicken_setup()
 ch={
  sp=224,
  x=960,
  y=216,
  dx=0,
  dy=0,
  a=0,
  spd=5
 }
 chclock=0
 agro=false
 cap=12
end

function chicken_update()
 local disx=pl.x-ch.x
 local disy=pl.y-ch.y
 
 if agro then
  ch.dx=cos(ch.a)*ch.spd
  ch.dy=sin(ch.a)*ch.spd
  ch.x+=ch.dx
  ch.y+=ch.dy

  if abs(disx)<8
  and abs(disy)<8 then
   if (not text) get_text({"104:\^wscreee!"})
  end
  if btn(—)
  and text then
   
   door(816,64) 
   chicken_setup()
   text=nil
  end
 else
  chclock+=1
  if chclock>cap then
   if ch.sp==224 then
    ch.sp=225
    cap=40
   elseif ch.sp==225 then
    ch.sp=224
    cap=rnd({25,25,60})
   end
   chclock=0
  end
  
  if ch.sp==225
  and chclock>4
	 and move_keys() then
	  sfx(13)
	  agro=true
	  ch.sp=226
	  ch.a=atan2(disx,disy)
	 end
 end
 
end

function draw_chicken()
 spr(ch.sp,ch.x,ch.y)
end
-->8
-- touchies

function blob_setup()
 blob={}
end

function draw_blobs()
 for b in all(blob) do
  b:draw()
 end
end

function add_blob(x,y)
 add(blob,{
  x=x,
  y=y+128,
  s=2+rnd(1),
  draw=function(self)
   self.x+=rnd(2)-1
   self.y-=1
   self.s-=0.05
   circfill(self.x,self.y,1.5,2)
   circfill(self.x,128+(256-self.y),1.5,2)
   if (self.s<1) del(blob,self)
  end
 })
end
__gfx__
00000000077777000777770000000000000000003377777767777776777777775555555594444449666666661009400133333333333333333333333310094001
0000000077888770778887700777770007777700377eeee77722227774444427ffffffff5d6666d5669999660900004033333333333333b33331133309000040
0070070078dddd7778dddd77778887707788877037eeee777222222774fff427ffffffff26666661664444660a9009403333333333333333331001330a900940
0007700077d6766777d6766778dddd7778dddd7737eeee777200027774999427ffffffff2d6666d166455466000aa000333333333b3333333109901300099000
0007700078d6766778d6766777d6766777d6766737cfca7772a1a27674fff427ffffffff222111116645546610aaaa01333333333b333b333099990310999901
0070070077dddd7777dddd7778d6766778d6766737fffa777211127674444427dddddddd222222116644446600aaaa003333333333333b331099990100999900
0000000007ddd77007ddd77077dddd7777dddd7737aeeaa77222227777742777d55dd55d22222221665dd5660aa9a99033333333333333330aa999400aa99940
000000000767757007677570076dd570076dd57037dedee77222222737bb2b73dddddddd22222221666666660a9a994033333333333333330999944009999440
00000000077777000777700007777000077777003377777757777775333333335555555522221111669999665dddddd533333333333333331009400110094001
007ff70077888770778877777788777777888770397555577745447733333333fff66fff2222211166444466dd6666dd33333333333333330900004009000040
0ff7ff7078dddd7778d6766778d6766778dddd77347414177444444733333d33ff8ddcff9444444966455466d666666d3b3333b3333333330a9994400a999440
0f777ff077d6766778d6766778d6766777d676673476666777ffff7733333333f555555f5555555566999966d66dd66d333333b3333b33330aa999400aa99940
0ffffff078d6766777da1a7777da1a7778d6766739766667571f1f7533dd3333ffffffff5555555566999966d66dd66d33333333333333331009400110094001
07fff66077dddd7778dddd7078dddd7077dddd773973667757ffff7533dd3333dddddddd5dddddd566444466d666666d33b333333b333b330900004000000040
0066660076ddd77077ddd57076ddd77007ddd570347d7d745771117533333333d55dd55d66666666665dd566dd6666dd33b333333b333b330a9994400e809440
00000000777757000767777077775700076777703151111157d77d7533333333dddddddd66666666666666665dddddd533333333333333330aa9994008809940
00000000000000000777770007777000077777003333333333333333333333339999999966666666666666665555555533333333333333331009400110094001
000000000777770077888770778877777788877039999999333333333337f733449944946666666666777776555555553dd33dd33ddd3dd31100001111000011
0007f0007788877078dddd7778d6766778dddd773444444433333333333f9f33999999996666d66667755576555555553ddd3d3333dd3dd31100001111000011
007ff70078dddd7777d6766778d6766777d6766734555555333333333337f73399999999666ddd6667585176555555553ddd3333333333333110011331100113
00f6f60077d6766778d6766777da1a7778d6766739999999333333333333b333499499446666d666674442766666d66633333dd33ddd3dd333333333333333b3
000f600078d67667776dd57776dddd5776dddd5739999999333b33333333bb339999999966666666671f1276666666663d3d3dd33ddd3d33333333333b3333b3
0000000077d6d57707ddd57077ddd77777ddd777344444443333b3333333b333444444446666666667fff276666666663ddd3dd33d3d3dd33333333333333333
0000000007675770076777700767570007675700315111113333333333333333d5dddd5d66666666675112766666666633333333333333333333333333333333
00000000007777003777777333333333333333337777773333333333333333333300003399999999d777777dffffffff5cccccc5555555555555555555555555
07777770077c677077eeee7730000033330000037eeee773333333333300303330aa99039999999974444447d5d55d5d5c7777c555555555511111155dddddd5
77dccc7707cc66707e2222e700eee003300eee0377eeee7333333333309a04030aaaa9404444444474222247ffffffff5c7777c5555555555dddddd55d6666d5
d5dcccc707cc6670722222270eeede0330eeed0377eeee733333353309a44901099a49904882551474222247f55ff55f5c7777c5555555555d6666d55d6666d5
d5d6666707cc6670722552270edddd0330eede0377acfc733334333309999401109999014444444474444447ffffffff5c7777c5555555555d6666d55d6666d5
77d6667707dddd70725255270deddd0330dded0377afff733533435310a4449009a4499043c5555474242247dddddddd5cccccc5555555555d6666d55d6666d5
0777777007755770722222270ddd3d03303ddd037aaeea7333333333040940400099990043c115a474242247d111111d51111115555555555d6666d55dddddd5
00000000007dd7007222222733333333333333337eeded733333333310000001100000014444444474444447dddddddd55555555555555555555555555555555
ddddddddddddddddddddddddddddddddddddddeeeeeeeeedddddddddddddddddddddddddddddddddcccccccccccccccc666666667777777633333333337dd733
ddd7777777777ddddddddd4442ddddddddddaaaaaeeeeeddddd5555555555dddddddddddddddddddcccccccccccccccc667777667fffff763dd33dd337755773
dd677777777776ddd444444442dddddddddaaaaaaaaeeedddd555555555555dddddddd2222eeddddc7cccccccccccccc667827777f777f773dd3ddd337dddd73
dd777777777777ddd44ffff44444442dddddffaaaafaeddddd555555555555dddddd22222222eeddccccc7cccccccccc677682877f7eeff73333333377cc6677
dd776676677677ddd449ffffffff442dddddfffffffaedddddd6666444466ddddddd22222222eeddcccc7c7ccccccccc778768777f7e77f73dddddd37dcc66d7
dd777676676677ddd44fff9ffff9442dddddfcffffcaadddddd4444444444dddddd2252252522eedcccccccccccccccc782826777f77e7973d1111d37dcc66d7
dd777777777777ddd44f99f9ffff442ddddafff8ffffadddddd44554455444ddddd2255222522eedcccccccccccccccc766667767f7ee7f73dddddd37dddddd7
dd677777777776ddd44fffff99ff422dddda9ffffff9adddddd44444444464ddddd2222222222eedcccccccccccccccc777777667f9f99973666666376666667
ddd7777777777dddd4444fffffff442dddda999ff999adddddd6664446666dddddd22522255222ed333333333333333366777766333333333330033333333333
dddddddd6776ddddd44444444444442dddeee99ff99eeeddddd6664446666dddddd2252525522eed99999993999999936774277633333333300d200333333333
dddddddddddddddddddddd444444442ddde7eeeffeee7eddddd6666666666dddddd2222222222eed444444434444444367442276333333300ddd222003333333
dddddd677ddddddddddddd4442ddddddddeeeeefeeeeeeddddd6666677666ddddddd222222222eed5555554355555543674422763333300ddd2d222220033333
dddddd777ddddddddddddbb442dddddddddf9eeeeee9fddddddd66666666ddddddd222222222bbed99999993999999936744227633300ddd2ddd222222200333
ddd77d776ddddddddddddbbb4bbdddddddaf9eeeeee9fadddddd3b3223b3ddddddbb222b222bbbed999999939999999367555576300ddd2ddd2d222222222003
ddd76ddddddddddd3333333333333333ddafff7777fffaddddddb3b22b3bdddd33333333333333334444444344444443677227760ddd2ddd2ddd222222222220
dddddddddddddddd3333333333333333dda99eeeeee99adddddd3b3223b3dddd3333333333333333111115131a711513667557660d2ddd2ddd2d222222222220
dd222222222222dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd2444444266666655556666660ddd2ddd2ddd222222222220
d222222222222222ddd44444dddddddddddddddddddddddddddddddddddddddddd8dddd8dddddddd4666666455dddd5555dddd550d2ddd2dddd0022222222220
2222255555222222ddd4444444444ddd666667777dddddddddddddddddddddddd8dd99d8d88dd8dd45ddddd466666655556666660ddd2dddd006600222222220
2225511111552222ddd2222244444ddd6d6d7d7d66766ddd6666677776676ddddddd299888dddd8d4dd666645ddddd5555ddddd50d2dddd00dd555d002222220
2251111111115222dd44444222222ddd6d6d7d7d6d6d66666d6d7d7d6d7d6666ddddd298888ddddd4555ddd466666655556666660dddd0066666666660022220
2511111111111522dd42fff4444444dd6d7d7d6d7d6d66666d6d7d7d6d6d6666dd922228aa88dddd4dddd6645ddddd5665ddddd50dd00555ddddddddd6d00220
2511aa1111111152ddddf1ffffff24dd6d7d7d6d6d6d6d666d7d7d6d7d6d6d668dd99988aaa8dd88455555d46666666666666666000666666666666666666000
2511aa1111111152ddddfff1f1ffdddd7d7d6d7d6d6d6d6d6d7d7d6d6d6d6d6d88d88888aaa8d888244444425ddddd6666ddddd530ddddddd777777ddddddd03
2511111111aa1152ddddff18ffffdddd7d7d6d6d6d6d6d6d7d7d6d7d6d6d6d6d888888888888888877777777666666663333333330d666667444444766666d03
2511111111aa1152dddddffffffddddd77667666666d6d667d7d6d6d6d6d6d668828888888888828799aa997677777763000003330ddd6dd742222475dddd503
251111a1a1111152dddddddffdddddfd111111111666666677667666666666668888888998888888795aa5977744457700eee00330d666667422224766666503
2251111a11111522d111111ff11dd11d1aa1111aa1111ddd1111111111111ddd288888897899888279111197794444970eeede0330d565dd74444447ddd56503
2225111111115222d1dd11111111d1dd1aa1111aa1111ddd11aa1111aa111ddd82888994447982887a1111977a5545970edddd03330666667424224766666033
2222551115552222d1fdd111611111dd111111111111dddd111111111111dddd282289749922282279999997799aa9970d5ddd03330d55dd74242247ddd55033
2222225552222222ddddd116111ddddddddddddddddddddddddddddddddddddd222222244422222279444597795aa5970ddd3d03330ddddd74444447dddd5033
2222222522222222ddddd121111ddddddddddddddddddddddddddddddddddddd2222222299222222795455977955559733333333333333333333333333333333
00000000000000000000000000000000f0f0f0f0f0f0f0f08383f0f0f0f0f0f0f0f0f0f0c0c0c0c0c0c0c0c0c0f0f0f0b0f0f0f0f0c0c0c0c0c0c0c0c0c0f0f0
f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0b4b4b4e1e1f0f0f0f0000000000000b1929292b1000000000000000000000000000000000000000000
00000000000000000000000000000000f0f0f0becee1e1e17383e1e1e1f0f0f0f0f0f0f0c0c051a5c0c0c0c0c0f0f0b0f0f0f0f0e1c0c0c0c0c0c0c1c0e0f0f0
b0f0f0e1e1e1e1f0f0f0becee1e1e1e1f0f0f0e1e1e1e1b4b4b4e2e2e1f0f0f0000000000000b1929292b1000000000000000000000000000000000000000000
00000000000000000000000000000000f0f0e1ddfd8e9ee263738ee2e2e1f0f0f0f0f0f0c0c0c0c0c072c0c1c0f0f0f0f0e1e1e1e2c0c0d0c0c0c0c0e0f0f0b0
f0f0e1e2e2e2e2e1e1e1ddfd9e8e9ee2e1e1e10cf2e2e2b4b4a44fc0e2e1f0f0000000000000b1929292b1000000000000000000000000000000000000000000
00000000b1b1b1b1b1b1b1b1b1000000f0f0f2defe8383c0c0c0c083c0e2f0f0f0f0f0f0e0c0d0c0c0c0c0c0c0f0f0f0f0e2e2f2c0c0c0c0c0c0c0c0f0f0b0f0
f0e1e2c0c0c0c0e2e2e2defe83c0c0c0e2e2e2c0c0c07fb4b4b44fd0c0e2f0f000000000b1b1b16ee35eb1b1b100000000000000000000000000000000000000
00000000b19393b2b2b29393b1000000f0f0c0c0c0c0c0c0c0c0c0c0c0c0e1e1e1f0f0f0f0e0c0c0c0c0c043e0f0f0f0f0c0d3d3d3d3d3d3c0c0c0e0f0f0f0f0
f0e2c052a5c0c0d0c0c06383737383c0c0c0c0c0c0afb4b4b49fc0c0c0c0f0f000000000b1b2b292d392b2b2b100000000000000000000000000000000000000
00000000b192929260929292b1000000f0f0c0c0c1c0c0c0c0c0c0c1e0c0f2e2e2f0f0f0f0f0e0e0e0e0e0e0f0f0f0becec0d3c0c0c0c0d3c0c0c0f0f0f0f0f0
f0d0c0c0c0c0c0c0c0c0c0c0638383838373c063c0afb4a4b44fc0c0d143f0f000000000b192d3d3d3d3d392b1b1b100000000003d9292929292923d00000000
000000b1b192c4929292d492b1000000f0f0e0c08383c0c083c0c0c0e1c0c0c0c0e1f0f0f0f0f0f0f0f0f0f0f0e1e1ddfdc0d3c0d3c3c1d3c0c0e0f0f0f0f0f0
f0c0c0c0c0c0c0c0c0c0c0c0c0c08373838383c0c0afb4b4b46fc0c0c073f0f000000000b192d3d3d3d3d392b2c6b100000000009292a192a292929200000000
000000b1b292929292929292b1000000f0f0e1c0c0c0c083f473c2c0e2c0c0c0c0e2e1e1e1e1f0f0f0f0f0e1e1e2e2defec0d3c0d3d3c0d3c0e0f0f0f0f0f0f0
f0c072c0c0c0d1c0c0c0c1c0c0c0c063838373c0c0afb4b4b4b44fc063e0f0f000000000b192d3d3d3d3d3929292b1000000000092924d1f9292929200000000
000000b1a69292929292c592b1000000f0f0e2c063c0c0c2e361c0c0c0c0c0c0c0c0e28e9e8ee1e1f0e1e1e2e2c033c0c0c0d3e0c3d3c0d3c0e1f1f0f0f0f0b0
f0c0c0c0c0c0c0c0c0c0c0c0c0c1c0c0c0c0c0c0c0c08fb4b4b44f7383f0f0f000000000b192d3d3d3d3d3929292b100000000003d9292929292923d00000000
000000b19292929292929292b1000000f0f0c0c0c0c0c0c3c0d3c0c0e0c0c0c0c0c0c0c0c083e2e2e1e2e2c0c0c0c0c1c0c0d3e1c0d3c0d333e2f2f0f0f0b0f0
f0e0e0c0d0c0c0c0c0d1c0c062c0c0c0c0c0c0c0c0c0afb4b4a44f8383f0f0f000000000b192d3d3d3d3d392b1b1b10000000000000000000000000000000000
000000b1b1b1b1b1a3b1b1b1b1000000f0f0c0c0c0c0c0d3d3d3c0c0f0e0c0c0c0c0c0c0c0c0c0c00cd0c0c0d3d3d3c0c0c0d3f2c0d3c0d3e3c0e0f0f0b0f0f0
f0f0befcc0638383c0c0c062c762dcfcc0c0c0c0c0c0afb4b4b44fe0e0f0f0f000000000b192929292929292b100000000000000000000000000000000000000
00000000000000000000000000000000f0f0e08383c0c0c1c0c0c0e0f0f0c0c0c0c0c0c0c0c0c0c0e3d3d3c0d3c0d3d3d3d3d3d3d3d3c0c0e0e0f0f0b0f0f0f0
f0f0bfdf838383838383c0c062c0ddfd83638383c0c1afb4b4b4e0f0f0f0f0f000000000b1b1b1b1b1b1b1b1b100000000000000000000000000000000000000
00000000000000000000000000000000f0f0f0e0e07363c0c0c0e0f0f0f0e0e0e0c0c0d1c033c0e0e0c0d3d3d3c0c1c0c0c0c0c0c0c0c0c1f0f0f0f0f0f0f0f0
f0f0f0f0e0e0e0e0e0e0e0c0d0c0defe7383838383c0afa4b4b4f0f0f0f0f0f00000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000f0f0f0f0f0e0e0e0e0e0f0f0f0f0f0f0f0e0e0e0e0e0e0f0f0e0c0c0e0e0e0e0dcfce0e0e0e0e0e0f0f0f0f0f0f0f0f0
f0f0f0f0f0f0b0f0f0f0f0e0e0e0e0e0e0e0e0e0e073afb4a4b4f0f0f0f0f0f00000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0e0e0f0f0f0f0bfdff0f0f0f0f0f0f0f0f0f0f0f0f0f0
f0f0f0f0f0b0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0e0e02c2c2cf0f0f0f0f0f00000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0
f0f0f0f0b0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f02c2c2cf0f0f0f0f0f00000000000000000000000000000000000000000000000000000000000000000
10094001cccccccccccccccc003000000030000033333333666666665555555555555555dddddddddddddddddddddddddddddddd300000000000000000000003
10000011c00000cccccccccc0020000000200000337777736777777655555d5d5555555511ddd5555555ddddddd5555555555ddd0aaaaaaaaaaaaaaaaaaaaaa0
00eee00100eee00ccccccccc1111100011111000377eee777722227755555ddd55555555d1dd555555555ddddd555555555555dd0aaaaaaaaaaaaaaaaaaaaaa0
0eeede030eeede0ccccccccc212120001212100037eeeee772222227555d55d55d555555d1d5585855551ddddd166644446661dd0aaaaaaaaaaaaaaaaaaaaaa0
0edddd030edddd0ccccccccc112110001212100037eeee77720002775555555555555555dfd55585555111dddd167774477761dd0aaaaaaaaaaaaaaaaaaaaaa0
0deddd037deddd7ccccccccc212120002111200037cfca7772a1a2765555d555d5555555ddd44444455111dddd147774477741dd077777777777777777777770
0ddd3d03c77777cccccccccc211120002212200077fffaa7721112775559f999f9555555ddd4eeeeee4211ddddd44444444444dd09aa9aa99aa99aa99aa9aa40
33333333cccccccccccccccc00000000000000007ededaa77222222755499929f9455555ddd4fffff1422dddddd66444466664dd099999999999999999999940
66666666666666660000000000000000999999993333333355555555ff492999294fffffddd41f11ff422ddd7dd6666666666ddd099999999999999999949940
66666666667777660000000000000000440947743977777757777775ff4999299949ffffddd4fff8ff422dddddd6677777766dd7099a99999999999999999940
6666d666677ff77600000000060000009079f7793475555777454477ff49999999499fffddd42fffff422d11dd766677776667dd099999999999999999999940
4444444447ffff7400000000000000009779f7a93474141774444447ff44444444499fffddd4222ff2422dfd7d776666666677d7099999999999999999999940
4122222447ffff7400000000000006604774ff4a3976666777ffff77ff67d7d5d5d99fffdfd4211ff1422ddd777e3b3223b37777099999999999999999999940
4222111447ffff7470000007000006609999999939766667571f1f75fff9999999999fffd1dd11199111dddd7744b3b22b3b4477099999999999999999999940
4444444444444444c777777c0000000044444444347d667457ffff75ffff99999999ffffd1dd1119911111117e443b3223b344e7099949999994499999949940
2244242222442422cccccccc00000000d5dddd5d3151111157d11d75ffffffffffffffffd1dd11199111ddddeee3332222333eee099999999999999999999940
66666666666666660000000055555555555555556666666666666666100940011000000110000001667777761000000000000001094494499449944994494440
66666666677777660777770059999999999999956666666666666666110000111100001110aa9901677555760aaaaaaaaaaaaaa0044444444444444444444440
67777776774487667788877754444444444444456dddddddddddddd611000011109a04010aaaa940675851760aaaaaaaaaaaaaa0044454444445544444454440
4784447479414774798a888754555555555555456d666666666666d63110011309a44901099a4990674442760aaaaaaaaaaaaaa0000000000000000000000000
4744447477444474728a882769999999999999966d666666666666d6333333330999940110999901671f12760aaaaaaaaaaaaaa0311111112112121121120113
47444474474444747988827769999999999999966d666666666666d63533435310a4449009a4499067fff2760777777777777770304444444444444444440113
44444444444444447777779764444444444444466dddddddddddddd63334333304094040009999006721127609aa9aa99aa9aa40304244200000000000000133
22442422224424220000077761511111111115166555555555555556333333331000000110000001675775760999999999999940304444203333333333333333
99999999999999997777777710000001c333333333333333c33333333333333ccccccccccccccccc3333333c0999999999999999999499400944944994499449
44994474449f7f94799aa99717777771c333333337777733ccc3333333333ccc3cccccccccccccc33333333c099a999999999999999999400444444444444444
977779c999997f99795aa59777444577cc33333377eee773ccccc333333ccccc3cccccccccccccc3333333cc0940049999400499994004400444544444455444
97ff7999999999997911119779444497cc3333337eeeee73cccccc3333cccccc33cccccccccccc33333333cc0409904994099049940990400000000000000000
47777944499499447a1111977a554597cc33333377eeee73cccccc3333cccccc33cccccccccccc33333333cc0099990440999904409999003111111111111111
999999999999999979999997799aa997cc33333377acfc73ccccccc33ccccccc333cccccccccc333333333cc0099990440999904409999003111111110444444
444444444444444479444597795aa597c33333337aafff77ccccccc33ccccccc33333cccccc333333333333c0aa999400aa999400aa999403311111110244240
d5dddd5dd5dddd5d7954559779555597c33333337aadede7cccccccccccccccc3333333cc33333333333333c0999944009999440099994403333333330244440
__gff__
0000000000232303010301010000010100000000002323000303010100000103000000000001000801002300000000000000030101230009090303030304050000000000000000000000101003030103000000000000000000000103030101010000000000000000000003030301010100000000000000000000010303010301
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010100004343000000000000010101010300000143430101010000000101010101000101010100090943010103010101030103004300000000000101010103
__map__
0f0f1e1e1e1e5d5e5f1e0f0f0f0f0b0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0fc2c2c20f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f00000000000000000000000000000000
0f0f2e2e1e2e6d6e6f2e1e1e1e0b0f0f0f0f0b0f0f0f1e1e1e1e0f0f0f0f0b0f0f1e1e1e1e1e1e0f0f0f0f0f0f0f0b0f0f0f0f0f0f0b0f0f1e1e0f0f0f0f0f0f0f1e1e1e1e1e1e1e1e1e1e0f0f0f0f1e1e1e1e1e1e1e1ec2c2c21e1e1e1e1e1e0febceec0f0f0f0f0f0f0febceec0f0f00000000000000000000000000000000
0f0f0c1d2f387d7e7f0d2e2fc01e0f0f0f0b0f1e1e1f2e2e2f2e1e1e1e0b0f0f0fe9e82e2ec02e1e1e1e1e1e0f0b0f0f0febec0f0b1e1e1fe9e81e1e1e1e1e0f0fe72e2e2f2e2e2e2e2f2e1e1e1e1e2e2e2e2e2e2e2e2e4b4b4a2e2e2e2e2e2e1edddedf0f0f0f0f0f0f0ffbfcfd0f0f000000000000000000001b1b1b1b1b00
0f1e0e0c0c0c0c2d070c0c0c0c2e0f0f0b0f0f2f2e2e0c1c0c0c2e2e2e1e0f0f0f38361c0c0c362e2e2e2e2e1e0f0f0f0ffbfd0b0fe72ee738372e2e2e2f2e1e1e0c0c0c0c0c0c0c0c0c0c2e2e2e2e0c0ccdcecf0c0cfa4b4b4bf40c0c0c0c0c2efeffef1e1e1e1e0f0f0f0f0f0f0f0f000000000000000000001b6b2b2b1b00
0f2e1e0c0c0c0c2c170c0c0c0c0c0f0f0f0f1e0ccdcf0c0c0c0c0c38362e0f0f0f380c0c0e0c0c0c0d0c0c362e0f0f0f0f0f0f0f0f0e3637385d5e5f0c0c0c2e2e0c0c330c320c0c320c320c340c0c0c1ddddedf0c0cfa4b4b4bf60c0c0c0c0c0c0c0c0c2e2e2e2e1e1e0f0f0f0f0f0f001b1b1b1b1b1b1b1b001b2929291b00
0f0c2f0c0c1d0c2c0c0c0c0c0e0c0f0f0f0f2e0cdddf0c0c0c0e0c0c38381e1e1e0c0c0c1f0c27050c37380e0e0f0f0f0f0f0f0f0f0f380c0c6d6e6f0c7c0c0c0c0c0c270c2d0c0c2c0c170c2c0c0c0c0cedeeef0c0cfa4b4b4a4bf40c1d0c0c0c0c0c1c0c5d5e5f2e2e1e0f0f0f0f0f001b6b2b2b3918081b001b2929291b00
0f0c0c0c0c0c0c0c0c0c0c1d1f0c0f0f0f0f0d0cedef0c0c1c1f0c363837e92e2e0c0c0c2e0c0c1d0e0e0e0f0f0f0f1e1e1e1e0f0f0f0c0c0c7d7e7f0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0cf84b4bc1f40c0c0c0c0c0c0c0c0c6d6e6f0c0c2e0f0f0f0f0f001b2929292929291b001b29297b1b00
0f0e0ccdcecf0c2c0c0c0d0c2e0c1e1e1e1e0c0c0c0c0c0c0c2e0c38383838360c0c0d0c0c0c0e0e0febceec1e1e1e2e2e2e2e1e0f0f0e0c0c0c2c070c0c0c0c0c0c0c0c0c320c320c0c320c0c0c0c0c0c0c170c0c0c0dfa4b4b4bf40c0c0c0c0c0c0c070c7d7e7f0c0c0c0f0f0f0f0f001b2929292929291b001b1b1b1b1b00
0f1e0cdddedf0c1c170c0c0c0c0c2f2e2e2e0c0c0c0c0c0c0c0c0c0c37380e0e0e0c0c0c0e0e0b0f0fdddedf2f2f2e0c0c0c362e0f1e1e0c0c0c2d0c0c0c1c0c0c0c0c0c0c2c0c170c0c2c0c0c2d2d2c2d2c0c0c2d0c0cfa4b4b4bf40c2d0d0c0c0c0c0c0c0c2c0c0c0c0c0febceec0f001b2929292929291b00000000000000
0f2f0cfeffef0c0c0c2c2c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c380f0f0f1dcdceec0b0f1e1eedeeef0c0c0c0c0c255b0c1e2e2e0c0c0c0c2c2c0c2c2c0c2c2c0c0c0c0c0c0c0c0c0c2c0c0c2c171c2c2c170c2cfa4a4b4bf40c2c2d0c2c0c0c2c2c0c170c0c270c0ffbfcfd0f001b2929292929291b1b1b1b1b000000
0f0c0c0c0c0c0c0c0c0c0c0c0c2d2c2d0c2d0c0c170c0c0c0c0c0c0c1c360f0f0f0efbfcfd1e1e2f2e0c0c0c0c0c0c0c1d0c0c38e9380c0c0d0c0c0ccdcf2c0c0c0c2c0c2d2d2c0c2d2c0c0c2d170c0c0c0c0c0c0c0c0cfa4b4b4bf4171c0c170c0c0c0c0c0c0c0d0c0c0e0f0f0f0f0f001b2929292929292b2b2b2b1b000000
0f0c0c0c383738380c0c1d0c0c0c0c0c0c0c0c1c0c0c0c0c0c0d0c0e0c0e0f0f0f0f0f0f0f2e2e0c0c0c0d0c0c0c0c0c0c0c0c383837360c0c0c0c0cdddf0c0c0c0c1d0c0c2c170c0c0c0c2d0c0c0c0c0c0c0c0c0c0c0cf74b4b4bf40c0c0c0c0c0c0c0c0c0c0c0c0c0e0f0f0f0f0f0f001b291a29292929292929091b000000
0f0e0e0c0c383637380c0c0c0c0c0c0c0c0c0c1d0c0c2c171c0c0c1e0c0f0f0b0f0f0f0f1e0c0c0c0c0c0c0c0c0c0c0c0c3637370e0e0e0c0c0c0c0cedef0c0c0c0c0c0c2c2d1c0c0c0c0c0c0c0d0c0c0c0c0e0e0c0cfa4b4b4a4bf40d0c0c0c0ccdcf0e0e0e0e0e0e0f0f0f0f0f0f0f001b2928f0292929292929191b000000
0f0f0b0e0e0e0c0c0c0c0c0c0c0c0e0e0e38380c0c0c2c0c0c0c0c2e1d0f0b0f0f0f0f1e2f0c0c0c0c0c0c0c0c0c0c0e0e0e0e0e0f0b0f0e0e0e330c0c0c0c0e0e0c0c0c0c2c0c0c0c0c0e0e0e0e0e0e0e0e0f0b0e0efa4b4b4bf90c0c0c0e0e0efbfd0f0f0f0f0f0f0f0f0f0f0f0f0f001b29290a2929292929297b1b000000
0f0b0f0f0f0f0e0e0e0e0e0e0e0e0f0f0f0e0e0e0e0c0c170c0e0e0e0e0b0f0f0f0f0f2e0c0c0c0c0c0c0c0c0e0e0e0f0f0f0f0febceec0f0f0f0e0e0e0e0e0f0f0e0c0c0c0c0c0c0e0e0f0f0f0f0f0f0f0f0b0f0f0f0e4b4b4b0e0e0e0e0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f001b1b1b1b1b1b1b1b1b1b1b1b000000
0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0c2d2c0c0f0f0f0f0f0f0f0f0f0f0c0c0c0c0c1d0c0e0e0f0f0f0f0b0f0f0bfbfcfd0f0f0f0f0f0f0b0f0f0f0f0c0c2c0c0c0c0f0f0f0f0f0f0f0f0f0b0f0f0f0f0f4a4b4b0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f00000000000000000000000000000000
000000000000000000000000000000000f0f1e1e1e0c2d2c0c1e1e1e1e0f0f0f0f1e1e0c0c0c0c0c0c0c0f0f0f0f0f0b0f0f0f0f0f0f0f0f0f0f0f0f0b0f0f0f0f0f0c0c2d2d0c0c0f0f1e1e1e1e1e0f0f0f0f0f0f0f0f4b4b4b0f0f0f0f0b0f0000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000f0fc02f2e0c2d2c0c2e2e2f2e1e0f0f0f2e2e0c0c0c0c0c0c0c1e1e1e0f0b0f0f0f0f0f0f0f0f0f0febceec0f0f0f0f1e1e0c0c0c0c0c0c1e1e2e2f2e2e2e1e1e0f0f0f0f0b0f4b4bc10f0f0f0b0f0f0000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000f0f0c0d0c0c2d170c0c0c0c0c2e1e1e1e0c0c0c0c0c0c0c0c0c2e2e2e1e0f0f0f0f1e1e0f0f0f0f0ffbfcfd0f1e1e1e2e2e1d0c2d0c0c0c2e2e0c0c0c0c0c2e2f0f0f0f0b0f0f4b4b4b0febceec0f0f0000000000001b1b1b1b1b0000000000001b1b1b1b1b1b1b1b1b1b1b1b1b0000
00000000001b1b1b1b1b1b1b000000000f0f0c0c0c0c2d2c0c0c0c0c1d0c2e2e2e0c0c0c0d0c0c0c0c0c0c330c2e1e1e1e1e2e2e1e1e1e1e1e1e1e1e1e2e2e2e0c0c1c0c2d2d1c0c0c0c0c0c1c0c0c0c0c1e1e0b0f0f0fc1c14b0ffbfcfd0f0f0000000000001b6b2b2b1b0000000000001b393939e3e42b2b7a3939391b0000
00000000001b393918083b1b000000000f0f0c0c0c2c2d2c1c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c1c0c2e2e2e2e0c0c2e2e2e2e2e2f2e2e2e0c0c0c0c0c0c0c0c2c0c0c0c0c0c0c0c0c0c0c0c2e2e1e0f0f0f4b4b4a0f0f0f0f0f0f0000000000001b2929291b0000000000001b29292929292929292929291b0000
00000000001b29292929291b000000000f0f0c2c2d2c2d2c2d2c2d2c170c2d0c0c0c0c2d2c2c2c2d17170c0c0c0c0c0c0c0d0c0c0c0d0c0c0c0c0c0c0c0c0c0c0c0c2c2d0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c2e0f0f0f4b4bc10f0f0f0f0f0f0000000000001b2929291b0000000000001b7b1a292929292929291a291b0000
00000000001b29292929291b000000000f0f0c0c2d2c0c2c2d172d2c2d2c0c0c2d2c2d2c0c172d2c2c2c0c0c2c0c0c2c0c0c0c0c0c0c0c0c0c1d0c0c0c0c0c2c2c0c2d0c0c0c0c0c0c0e0e0e0e0c0c0c0c255a0c0f0f0f4b4b4b0f0f0f0b0f0f000000001b1b1be63ee51b1b1b000000001b2828292929291a28f029291b0000
00000000001b1a292929291b000000000f0f0e0c0c0c0c170c2d0d0c0c0c0c0c0c0c0c0c0c0c0c0c2d172d2c2d2d17170c2c0c0c2d0c0c17172c2d2d2c0c2c2d2d0c0c0c0c1d0c0c0e0f0f0f0f0e0c0c0c0c0c1d0f0f0f4bc14b0f0f0b0f0f0f000000001b2b2b293d292b2b1b000000001b0a292929291b7a290a29291b0000
00000000001bf0292929091b000000000f0f1e0c0c0c0c0c2d2c0c0c0c0c0c0e0e0c0c0c0c1c0c0c0c1d0c0c0c170c2c2d2d0c2d172c2d0c2d2d0c170c0c0c0c0c0c0c0c0c0c0c0c0f0f0f0f0f0f0e0e1c0c0c0e0f0f0f4a4b4b0f0b0f0f0f0f000000001b293d3d3d3d3d291b000000001b29292929291b29292929291b0000
00000000001b0a292929191b000000000f0f2e0c0c0c0c0c0c2c0c0c0c0c0e0f0f0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c170c0c0c0c0c0c0c0c0c0c0c0c0c0e0f0f0f1e1e1e0f0f0e0e0e0f0f0f0fc1c14b0f0f0f0f0f0f000000001b293d3d3d3d3d291b000000001b292928281a1bd0292929d01b0000
00000000001b1b1b3a1b1b1b000000000f0f38380c0c1d0c170c0c0c0c0c0f0f0f0ccdcecf0c0c0c0c0c0c0c0c1c0c0c0c0c0c0c0c0c0c0c0c2c2d0c0ccdcf0c0c0c0c0c0e0e0e0f0f0f1e2e2e2e0f0f0f0f0f0f0f0f0f4b4b4b0f0f0f0f0f0f001b1b1b1b293d3d3d3d3d291b000000001b2929290a291bd0292929d11b0000
000000000000000000000000000000000f0f0e0e0c0c0c0c0c0c0c0c0c0c0f0f0f0cdddedf0c0c0c0c0c0c0c0c0c0c0d0c0c0c1d0ccdcecf0c0c2c0c0cdddf0c0c0c0e0e0f0f0f0f0f1e2f0c0c1d1e0f0f0f0f0f0b0f0f4bc1c10f0f0f0f0f0f001be3e42b293d3d3d3d3d291b000000001b1a292929291bd0292929d01b0000
000000000000000000000000000000000f0f0f0f380d0c370c0c360c270c0f0f0f0cfeffef0c0c0c0c0c0c330c0c0c0c0c0c0c0c0cdddedf0c0c170c1dedef0c0c0e0f0f0f0f0f0f0f2e0c0c0c322e0f0f0f0febec0f0f4b4b4a0f0f0f0f0b0f001b2929f1293d3d3d3d3d291b000000001b29292929291bd0292929d01b0000
000000000000000000000000000000000f0f0f0f0e0e0e0e360c0e0e0e0e0f0f0f0e0c0c0c0c0c0c0c0c0c0c0c0c0e0e0e0e0e0c0cfeffef0c0c2d0c0c0c0c0c0e0f0f0f0f0f0f0f0b0e6a0c0c2c0c0f0f0f0bfbfd0f0fc14b4b0f0febceec0f001b7b2929292929292929291b000000001b1b1b3a1b1b1b1b1b1b1b1b1b0000
000000000000000000000000000000000f0f0f0f0f0f0f0f38370f0f0f0f0f0f0f0f0e0e0c0c0c0c0c0c0c0c0c0e0f0f0f0f0f0e0c0c1c0c0c0c0c0c0c0c0e0e0f0f0f0f0f0f0f0b0f0f0e0e0e0e0e0f0f0f0f0f0f0f0f4b4bc10f0ffbfcfd0f001b1b1b1b1b1be629e51b1b1b00000000000000000000000000000000000000
000000000000000000000000000000000f0f0f0f0f0f0f0f38380f0f0f0f0f0f0f0f0f0f0c0c0c0c0c0c0c0c0c0f0f0f0f0b0f0f0e0c0c0c0c0c0c0c0c0c0f0f0f0f0f0f0f0f0b0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f4a4b4b0f0f0f0f0f0f0000000000001b2929291b000000000000000000000000000000000000000000
__sfx__
00040c000e121141010e121101010a1210d1010b141001010b1512b10112131001010010100101001010010100101001010010100101001010010100101001010010100101001010010100101001010010100101
000404000f6510260116651110011200112001216012160117601136010d601116010e601210011f0011f001230011c0010000100001000010000100001000010000100001000010000100001000010000100001
00040300086200a610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6420002019425204251d4252042519425204251d4252042519425204251d4252042519425204251d42520425164251d4251a4251d425164251d4251a4251d425174251d4251a4251d425184251d4251a4251d425
984000000d3100d3100d3100d3100d3100d3100d3100d3100e3100e3100e3100e3100e3100e3100e3100e31014310143101631016310183101831016310163101131011310113101131010310103101031010310
000c00000a3250a30514311133011c301204051d4052040519405204051d4052040519405204051d40520405164051d4051a4051d405164051d4051a4051d405174051d4051a4051d405184051d4051a4051d405
0004000006750046100b750017200161001610006100b7000870011700147001c7000770027700277002770006700067000570005700047000470000000000000000000000000000000000000000000000000000
0003000009637066370962709627096170b6170961706617056170061700617026170461702617056170261702607026070260702607026070260702607026070000700007000070000700007000070000700007
000f0a00120321503217032150321703217022170221701217012110020d0021600211002080020c0020d00200002000020000200002000020000200002000020000200002000020000200002000020000200002
0020000019425204251d4252042519425204251d4252042519425204251d4252042519425204251d42520425164251d4251a4251d425164251d4251a4251d425174251d4251a4251d425184251d4251a4251d425
0405010008055126051440512605114051260514405126050d405144051440514405114051440514405144050d405144051440514405114051440514405144050d40514405144051440511405144050000514405
0405010009055126051440512605114051260514405126050d405144051440514405114051440514405144050d405144051440514405114051440514405144050d40514405144051440511405144050000514405
0405010005055126051440512605114051260514405126050d405144051440514405114051440514405144050d405144051440514405114051440514405144050d40514405144051440511405144050000514405
11010000370162f01636016320163601632016320163301635016330162f016330163402635026310363104632046340562905631066330663407630076330763807630076340762f07633076330762e07633076
0010002019120051001e1001b1001e120051001a12005100191200510005100041001e120041001a120041001912004100031001d1001e1201e1001a120031001912003100031001910018120031000410004100
901000100b4400b4400b4400b440104401044010440104400a4400a4400a4400a4400d4400b4400d4400d44000400004000040000400004000040000400004000040000400004000040000400004000040000400
001000002155021550225502255028500285002955029550265502655023550245002455024550000002150021550215502255022550285002850029550295502655026550235502355023500235000000021500
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
03 03 04 43 44
01 41 0f 43 44
01 0e 0f 43 44
01 41 42 10 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
