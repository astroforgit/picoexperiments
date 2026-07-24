pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--happy challah days by mboffin
--pico-8 advent 2018 day #2

function _init()
	menuitems()
	var_setup()
	intro()
		
	dbg=false
 music(0)

 dlg_active=false
 map_setup()
 make_player()

	setup_day()
 load_inv()
 load_player_position()
end

function _update()
 if (not game_over and not dlg_active) then
  update_map()
  move_player()
  check_win_lose()
 elseif (game_over) then
  if (btnp(ó)) extcmd("reset")
 end
end

function _draw()
 cls()
 if (not game_over) then
  draw_map()
  draw_player()
  draw_dialog()
  draw_inventory()
  if (game_win) draw_win()  
 	if (dbg) draw_debug()
 else
  draw_win_lose()
 end
end

function draw_debug()
	print(day,mapx*8,mapy*8,7)
	print(dget(0),mapx*8,mapy*8+6,7)
	print(game_win,mapx*8,mapy*8+12,7)
end

function setup_day()
	if (stat(80)>2018 or (stat(80)==2018 and stat(81)==12 and stat(82)>=9)) then
		day=8
	else
		day=mid(1,stat(82)-1,8)
	end
	day=8
	
	if (day>1) setup_day1()
	if (day>2) setup_day2()
	if (day>3) setup_day3()
	if (day>4) setup_day4()
	if (day>5) setup_day5()
	if (day>6) setup_day6()
	if (day>7) setup_day7()

	ppl[ppl_boy1].d=day
	ppl[ppl_boy2].d=day
	ppl[ppl_girl5].d=day
	ppl[ppl_girl9].d=day
	ppl[ppl_william].d=day

end

function menuitems()
	menuitem(1,"back to calendar",function() load("#pico8adventcalendar2018") end)
	menuitem(2,"reset progress",reset_progress)
end

function reset_progress()
	dset(0,0)
	dset(1,0)
	dset(2,0)
	dset(63,xy(1,22))
	extcmd("reset")
end

function var_setup()
 mapx=0
 mapy=0
	dlg=""
	game_win=false
	game_over=false
	inv_update=false

 wall=1 --10000000
 key=2  --01000000
 door=3 --11000000
 anim1=4 --00100000
 anim2=5 --10100000
 lose=6 --01100000
 win=7 --11100000
 reset=8 --00010000
 sign=9 --10010000
 btn_up=10 --01010000
 btn_dn=12 --00110000
 anim3=17 --10001000
 anim4=19 --11001000
 spike1=21	--10101000
 spike2=22 --01101000
 gameover=254 --01111111
 
	s_grass=119
	s_fence1=112
	s_fence2=113
	s_fence3=114
	s_fence4=115
	s_dirt=121
	s_gate1=125
	s_gate2=126
	s_btnspikeup=54
	s_btnspikedn=55
	s_btndown=53
	s_bridgeh1=49
	s_bridgeh2=50

 --day 1
	ppl_mom    =xy( 3, 21)
	ppl_ari    =xy(18,  8)
	ppl_sarah  =xy( 5, 39)
	ppl_trader =xy( 7,  8)
	ppl_cat1	  =xy( 3, 33)
	ppl_cat2	  =xy(27, 29)
	ppl_cat3	  =xy(62,  5)
	ppl_chicken=xy(59,  4)
	ppl_boy1	  =xy(11, 28)
	ppl_girl1	 =xy( 9, 35)
	ppl_girl2	 =xy(11, 35)
	ppl_baker  =xy(12,  2)
 --day 2
	ppl_eli    =xy(19, 23)
	ppl_david  =xy(43, 28)
	ppl_jason  =xy(61,  3)
	ppl_lea    =xy(26, 29)
	ppl_boy2   =xy(30, 25)
	ppl_mary   =xy(41,  7)
	ppl_mark   =xy(36,  7)
	ppl_girl3  =xy(38, 24)
	ppl_girl4  =xy(40, 24)
	ppl_john   =xy(28, 61)
 --day 3
	ppl_simon  =xy(35, 40)
	ppl_wendy  =xy(35, 39)
	ppl_jacob  =xy(37, 39)
	ppl_stanley=xy(37, 40)
	ppl_olly   =xy( 8, 57)
	ppl_girl5  =xy(20, 45)
	ppl_girl6  =xy(22, 45)
 --day 4
	ppl_james  =xy(42, 51)
	ppl_sam				=xy(55, 56)
	ppl_erin   =xy(57, 41)
	ppl_daniel =xy(61, 35)
	ppl_zoe    =xy(49, 40)
	ppl_mason  =xy(52, 21)
	ppl_adam   =xy(60, 19)	
 --day 5
 ppl_girl7  =xy(74,  7)
 ppl_girl8  =xy(76,  7)
 ppl_helen  =xy(89,  3)
 ppl_elliot =xy(91, 21)
 ppl_thomas =xy(88, 25)
 ppl_nina   =xy(84, 30)
 ppl_richard=xy(71, 29)
 --day 6
 ppl_will   =xy(69, 41)
 ppl_pig    =xy(67, 41)
 ppl_corey  =xy(93, 55)
 ppl_sandra =xy(69, 53)
 ppl_laura  =xy(86, 55)
 ppl_cat4   =xy(87, 54)
 ppl_bryan  =xy(88, 55)
 ppl_dylan  =xy(102,52)
 ppl_girl9  =xy(73, 44)
 ppl_girl10 =xy(75, 44)
 --day 7
 ppl_joseph =xy(84, 40)
 ppl_samuel =xy(101,17)
 ppl_paul   =xy(100, 8)
 ppl_jerry  =xy(109, 5)
 --day 8
 ppl_mom2   =xy(118, 8)
 ppl_mom3   =xy(118,54)
 ppl_sheep  =xy(114,54)
 ppl_william=xy(122,37)
 ppl_zep    =xy(122,43)
 
 --day 1
 sgn_orchard =xy(24, 8)
 sgn_home    =xy( 4, 20)
 sgn_bakery  =xy( 8, 20)
 sgn_recipe  =xy(11, 22)
 sgn_bookshop=xy( 4, 26)
 sgn_secret1 =xy(13, 42)
 sgn_step1   =xy( 0, 10)
 
 --day 2
 sgn_step2   =xy(56,  6)
 sgn_berry   =xy(42,  6)
 sgn_school		=xy(42, 12)
 sgn_donuts  =xy(37,  6)
 --day 3
 sgn_stanley =xy(41, 41)
 sgn_wendy   =xy(35, 41)
 sgn_jacob   =xy(29, 41)
 sgn_simon   =xy(23, 41)
 sgn_olly    =xy( 9, 56)
 sgn_step3   =xy( 9, 53)
 --day 4
 sgn_james   =xy(41, 51)
 sgn_sam     =xy(58, 54)
 sgn_school2 =xy(55, 37)
 sgn_matzo   =xy(53, 20)
 sgn_step4   =xy(62, 49)
 --day 5
 sgn_helen   =xy(90,  2)
 sgn_mill    =xy(92, 20)
 sgn_step5   =xy(68, 27)
 --day 6
 sgn_luckylab=xy(70, 38)
 sgn_lake    =xy(70, 53)
 sgn_will    =xy(86, 53)
 sgn_corey   =xy(93, 53)
 sgn_step6   =xy(64, 36)
 --day 7
 sgn_joseph  =xy(87, 38)
 sgn_store   =xy(101, 7)
 sgn_step7   =xy(96, 24)
 --day 8
 sgn_william =xy(121,36)
 sgn_picocafe=xy(121,42)
 
end

function setup_day1()
	ppl[ppl_ari].d=2
	mset(24,13,s_dirt)
	mset(25,13,s_dirt)
	mset(23,12,s_gate2)
	mset(26,12,s_gate2)
end

function setup_day2()
	ppl[ppl_david].d=2
	mset(42,29,s_grass)
	mset(43,29,s_grass)
	mset(44,29,s_grass)
	mset(45,29,s_grass)
	mset(42,30,s_grass)
	mset(43,30,s_grass)
	mset(44,30,s_dirt)
	mset(45,30,s_grass)
end

function setup_day3()
	ppl[ppl_john].d=2
	mset(28,62,s_btndown)
	mset(30,57,s_btnspikedn)
	mset(30,58,s_btnspikedn)
	mset(30,59,s_btnspikedn)
	mset(30,60,s_btnspikedn)
end

function setup_day4()
	ppl[ppl_adam].d=2
	mset(60,18,s_dirt)
	mset(61,18,s_dirt)
	mset(63,18,s_dirt)
	mset(62,19,s_dirt)
	mset(63,19,s_dirt)
end

function setup_day5()
	ppl[ppl_richard].d=2
	mset(70,29,s_btndown)
	mset(72,30,s_btnspikedn)
	mset(73,30,s_btnspikedn)
	mset(74,30,s_btnspikedn)
	mset(75,30,s_btnspikedn)
end

function setup_day6()
	ppl[ppl_dylan].d=2
	mset(102,50,s_gate2)
	mset(105,50,s_gate2)
	mset(103,51,s_dirt)
	mset(104,51,s_dirt)
end

function setup_day7()
 ppl[ppl_jerry].d=2
 mset(111,06,s_bridgeh1)
 mset(111,07,s_bridgeh2)
end

function intro()
daynumber="2"
::_::
if (btnp()>0) goto donewithintro
cls()
f=4-abs(t()-4)
for z=-3,3 do
 for x=-1,1 do
  for y=-1,1 do
   b=mid(f-rnd(.5),0,1)
   b=3*b*b-2*b*b*b
   a=atan2(x,y)-.25
   c=8+(a*8)%8
   if (x==0 and y==0) c=7
   u=64.5+(x*13)+z
   v=64.5+(y*13)+z
   w=8.5*b-abs(x)*5
   h=8.5*b-abs(y)*5
   if (w>.5) rectfill(u-w,v-h,u+w,v+h,c) rect(u-w,v-h,u+w,v+h,c-1)
  end
 end
end
 
if rnd()<f-.5 then
 ?daynumber,69-#daynumber*2,65,2
end
 
if f>=1 then
 for j=0,1 do
  for i=1,f*50-50 do
   x=cos(i/50)
   y=sin(i/25)-abs(x)*(.5+sin(t()))
   circfill(65+x*8,48+y*3-j,1,2+j*6)
  end
 end
 
 for i=1,20 do
  ?sub("pico-8 advent calendar",i),17+i*4,90,mid(-1-i/20+f,0,1)*7
 end
end
 
if (t()==8) goto donewithintro
 
flip()
goto _
::donewithintro::
end

function xy(x,y) return x+y*128 end

function draw_win()
	local msg1="  happy hanukkah!  "
	local msg2="thanks for playing!"

	local x=mapx*8+26
	local y=mapy*8+20

	for i=1,#msg1 do
	 local x2=x+4*(i-1)
	 local y2=y+sin(t()+i*(1/#msg1))*4

		for s=-1,1 do for t=-1,1 do
 		print(sub(msg1,i,i),x2+s,y2+t,0)
 		print(sub(msg2,i,i),x2+s,y2+8+t,0)		
		end end
	 	
		print(sub(msg1,i,i),x2,y2,ceil(rnd(8)+7))
		print(sub(msg2,i,i),x2,y2+8,ceil(rnd(8)+7))
	end
	
end
-->8
--map code

function map_setup()
 timer=0
 anim_time=30
 
 init_signs()
 init_people()
end

function update_map()
 if (timer<0) then
  toggle_tiles()
  timer=anim_time
 end
 timer-=1
end

function draw_map()
 map(0,0,0,0,128,64)

 mapx=flr(p.x/16)*16
 mapy=flr(p.y/16)*16

 camera(mapx*8,mapy*8)	
end

function is_tile(tile_type,x,y)
 tile=mget(x,y)
 return fget(tile)==tile_type
end

function get_key(x,y)
 p.keys+=1
 swap_tile(x,y)
 sfx(1)
end

function open_door(x,y)
 p.keys-=1
 swap_tile(x,y)
 sfx(2)
end

function swap_tile(x,y)
 tile=mget(x,y)
 mset(x,y,tile+1)
end

function unswap_tile(x,y)
 tile=mget(x,y)
 mset(x,y,tile-1)
end

function add_sign(id,l,msg,t)
 local s={}
 s.msg=msg
 s.l=l
 s.t=t and t or "sign"
 signs[id]=s
end

function init_signs()
	signs={}
	add_sign(sgn_orchard,1,"ari's olive orchard")
	add_sign(sgn_home,1,"home")
	add_sign(sgn_bakery,1,"grateful bread bakery")
	add_sign(sgn_berry,1,"berry delicious fruit shop")
	add_sign(sgn_recipe,5,
		"    í holiday recipe í    \n       challah bread\n\nsalt, oil, eggs, yeast,     \nflour, water, and sugar")
	add_sign(sgn_bookshop,1,"what the dickens bookshop")
	add_sign(sgn_donuts,1,"fried and true doughnuts")
	add_sign(sgn_secret1,1,"well, aren't you clever. :)")
	local challah="í challah bread í step "
	add_sign(sgn_step1,5,
		challah.."1\n\nheat the water over low heat\nin a small pan until warm.\nthen remove from heat.","recipe note")
	add_sign(sgn_step2,8,
		challah.."2\n\ndump flour into big bowl and\nmake a well in the center.\nadd yeast, 1/2 cup of water,\nand a bit of sugar to the  \nwell. let it sit until it's \nfoamy. (about 10 mins)","recipe note")
	add_sign(sgn_step3,12,
		challah.."3\n\nput the rest of the water,\nwater, sugar, and 3 eggs in\nanother bowl. stir. add salt\nand stir again. add it to\nthe flour a bit at a time.\nwhen it's sticky, dump onto\nfloured surface and knead\nuntil smooth and elastic.\nadd flour as needed to keep\nit from sticking.","recipe note")
	add_sign(sgn_step4,10,
		challah.."4\n\nknead the dough into a ball.\noil the inside of a large\nbowl. cover the outside of\nthe dough ball with oil from\nthe bowl. cover with a damp\ncloth. let it sit in a warm\nplace until double in size.\n(about 1 to 1.5 hours.)","recipe note")
	add_sign(sgn_step5,9,
		challah.."5\n\nline 2 pans with parchment\npaper. punch down the dough\nand turn it into a floured\nsurface. divide the dough\n4 portions. work with one\nportion at a time and keep\nthe rest covered.","recipe note")
	add_sign(sgn_step6,11,
		challah.."6\n\ndivide each portion into 3  \npieces and roll them into a \n1ft long rope. braid them,  \npinching the ends to seal   \nthem. repeat until you have \nfour braided loaves. cover  \nwith a damp cloth and let   \nstand until double in size. \n(about half an hour.)","recipe note")
	add_sign(sgn_step7,7,
		challah.."7\n\npreheat oven to 350f. beat\nthe last egg and brush it\nover the top of the challah\nloaves. bake loaves until\ngolden brown. (20-30 mins)","recipe note")
	add_sign(sgn_school,1,"pico people kindergarten")
	add_sign(sgn_stanley,1,house("stanley"))
	add_sign(sgn_wendy,1,house("wendy"))
	add_sign(sgn_jacob,1,house("jacob"))
	add_sign(sgn_simon,1,house("simon"))
	add_sign(sgn_olly,1,house("olly"))
	add_sign(sgn_sam,1,house("sam"))
	add_sign(sgn_james,1,house("james"))
	add_sign(sgn_school2,1,"pico people middle school")
	add_sign(sgn_matzo,1,"mason's matzo shop")
	add_sign(sgn_helen,1,house("helen and elliot"))
	add_sign(sgn_mill,1,"flour mill")
 add_sign(sgn_luckylab,1,"lucky lab brew pub")
 add_sign(sgn_will,1,house("will"))
 add_sign(sgn_corey,1,house("corey"))
	add_sign(sgn_joseph,1,house("joseph"))
	add_sign(sgn_store,1,"general store")
	add_sign(sgn_william,1,house("william"))
	add_sign(sgn_picocafe,1,"pico pico cafe")
end

function house(name)
	return "ä "..name.."'s house ä"
end
-->8
--player code

function make_player()
 p={}
 p.x=1 --starting position
 p.y=22
 p.sprite=1
 p.keys=0
 p.d=false
end

function move_player()
 newx=p.x
 newy=p.y

 if (btnp(ã)) newx-=1
 if (btnp(ë)) newx+=1
 if (btnp(î)) newy-=1
 if (btnp(É)) newy+=1
 
 if (btnp(ã)) p.d=true
 if (btnp(ë)) p.d=false
 
 interact(newx,newy)
 check_movement(newx,newy)
end

function draw_player()
 spr(p.sprite,p.x*8,p.y*8,1,1,p.d)
end

function check_movement(x,y)	
 if (fget(mget(x,y),0)) then
  sfx(0)
 else
  local new_pos_x=mid(0,x,127)
  local new_pos_y=mid(0,y,63)
  --only save if moving
  if (new_pos_x!=p.x or new_pos_y!=p.y) save_player_position(new_pos_x,new_pos_y)
  p.x=new_pos_x
  p.y=new_pos_y
 end
end

function interact(x,y)
 if (is_tile(sign,x,y)) then
 	read_sign(x,y)
 elseif (is_person(x,y)) then
 	talk(x,y)
 elseif (is_tile(btn_up,x,y)) then
  flip_flop(x,y)
 elseif (is_tile(anim2,x,y) or is_tile(spike1,x,y)) then
 	move_to_reset()
 elseif (is_tile(gameover,x,y)) then
  game_win=true
 end
end

function load_player_position()
 p.x=dget(63)%128
	p.y=flr(dget(63)/128)
end

function save_player_position(x,y)
	dset(63,y*128+x)
end
-->8
--dialog/sign code

function draw_dialog()
  if (co_dlg and costatus(co_dlg)!="dead") then
   coresume(co_dlg)
  else
   co_dlg=nil
  end
end

function set_dlg(msg,lines,title)
	dlg=msg
	dlg_title=title
	dlgh=14+lines*6--6+lines*6
	co_dlg=cocreate(show_dialog)
end

function show_dialog()
 dlg_active=true
 dlgx=mapx*8+4
 dlgy=mapy*8+(p.y%16>=9 and 4+dlgh or 124)-dlgh

	for i=1,#dlg,2 do
	 draw_dlg_box(dlgx,dlgy,dlgh,sub(dlg,1,i),dlg_title)
		if (btnp(ó)) break
		sfx(4)
		yield()
	end
	
 draw_dlg_box(dlgx,dlgy,dlgh,dlg,dlg_title) 
	yield()
	
	while (not btnp(ó)) do
	 draw_dlg_box(dlgx,dlgy,dlgh,dlg,dlg_title)
	 if (btnp(ó)) then
	  break
	 end
	 yield()
	end
	dlg_active=false
end

function draw_dlg_box(x,y,h,msg,title)
	--title
	line(x+5,y,x+7+#title*4,y,7)
	line(x+4,y+1,x+4,y+7,7)
	line(x+8+#title*4,y+1,x+8+#title*4,y+7,4)
	line(x+9+#title*4,y+2,x+9+#title*4,y+7,0)
	rectfill(x+5,y+1,x+7+#title*4,y+7,15)
	print(title,x+7,y+2,2)

	--ó
	line(x+115,y+1,x+115,y+7,4)
	line(x+103,y+1,x+103,y+7,7)
	line(x+104,y,x+114,y,7)
	line(x+116,y+2,x+116,y+7,0)
	rectfill(x+104,y+1,x+114,y+7,15)
	print("ó",x+106,y+2,btn(ó) and 7 or 2)

 --message
	rectfill(x+1,y+9,x+118,y+h-1,15)
	line(x+1,y+8,x+118,y+8,7)
	line(x,y+9,x,y+h-1,7)
	line(x+1,y+h,x+118,y+h,4)
	line(x+119,y+9,x+119,y+h-1,4)
	line(x+120,y+10,x+120,y+h,0)
	line(x+2,y+h+1,x+119,y+h+1,0)
	pset(x+119,y+h,0)
	print(msg,dlgx+4,dlgy+12,1)
end

function read_sign(x,y)
 local s=signs[y*128+x]
	set_dlg(s.msg,s.l,s.t)
end
-->8
--animation code

function toggle_tiles()
 for x=mapx,mapx+15 do
  for y=mapy,mapy+15 do
   if (is_tile(anim1,x,y) or is_tile(anim3,x,y)) then
    if (is_tile(anim1,x,y)) sfx(3)
    swap_tile(x,y)
   elseif (is_tile(anim2,x,y) or is_tile(anim4,x,y)) then
    if (is_tile(anim2,x,y)) sfx(3)
    unswap_tile(x,y)
   end
  end
 end
end

function flip_flop()
 for x=mapx,mapx+15 do
  for y=mapy,mapy+15 do
   if (is_tile(spike1,x,y) or is_tile(btn_up,x,y)) then
    swap_tile(x,y)
    sfx(3)
   elseif (is_tile(spike2,x,y) or is_tile(btn_dn,x,y)) then
    unswap_tile(x,y)
    sfx(3)
   end
  end
 end 
end
-->8
--win/lose code

function check_win_lose()
 if (is_tile(win,p.x,p.y)) then
  game_win=true
  game_over=true
 elseif (is_tile(lose,p.x,p.y)) then
  game_win=false
  game_over=true
 end
end

function draw_win_lose()
 camera()
 if (game_win) then
  print("í you win! í",37,64,7)
 else
  print("game over! :(",38,64,7)
 end
 print("press ó to play again",20,72,5)
end

function move_to_reset()
 for x=mapx,mapx+15 do
  for y=mapy,mapy+15 do
   if (is_tile(reset,x,y)) then
    p.x=x
    p.y=y
    sfx(5)
   end
  end
 end
end

-->8
--inventory

function load_inv()
	setup_inv()

	if (cartdata("advent_challah")) then
		local inv_dat=dget(0)
		for i=7,0,-1 do
			if (inv_dat>=2^i) then
				inv[i+1].has=true
				inv_dat-=2^i
			end
		end
		inv_dat=dget(1)
		for i=7,0,-1 do
		 if (inv_dat>=2^i) then
			 trade[i+1].has=true
			 inv_dat-=2^i
			end
		end
		inv_dat=dget(2)
		for i=7,0,-1 do
		 if (inv_dat>=2^i) then
			 trade[i+9].has=true
			 inv_dat-=2^i
			end
		end 
		
		load_player_position()
	else
	 save_player_position(p.x,p.y)
	end
	
	if (trade[1].has) then --ribbon
		get_ribbon()
	end
	if (trade[3].has) then --berry
		get_berries()
	end
	if (trade[4].has) then --jam
		get_jam()
	end
	if (trade[2].has) then --donut
		get_doughnut()
	end
	if (trade[6].has) then --invite
		get_invite()
	end
	if (trade[7].has) then --soup
		get_soup()
	end
	if (trade[8].has) then --popcorn
		get_popcorn()
	end
	if (trade[9].has) then --game
	 get_game()
	end
	if (trade[11].has) then --coin
	 get_money()
	end
	if (trade[10].has) then --soda
	 get_soda()
	end
	if (trade[12].has) then --change
	 get_change()
	end

	
	if (inv[1].has) then --salt
 	ppl[ppl_mom].d=2
 	ppl[ppl_sarah].d=2
 	ppl[ppl_trader].d=3
 end 

 if (inv[3].has) then --eggs
 	ppl[ppl_mom].d=2
 	ppl[ppl_eli].d=3
 	ppl[ppl_mary].d=3
 	ppl[ppl_mark].d=3
 	ppl[ppl_jason].d=3
 end
 
 if (inv[2].has) then --oil
 	ppl[ppl_mom].d=2
 	ppl[ppl_olly].d=3
 	ppl[ppl_jacob].d=3
 	ppl[ppl_wendy].d=3
 	ppl[ppl_stanley].d=3
 	ppl[ppl_simon].d=3
 end
 
 if (inv[4].has) then --yeast
 	ppl[ppl_mom].d=2
 	ppl[ppl_james].d=3
 	ppl[ppl_mason].d=3
 end
 
 if (inv[5].has) then --flour
 	ppl[ppl_mom].d=2
 	ppl[ppl_helen].d=3
 	ppl[ppl_elliot].d=3
 end
 
 if (inv[6].has) then --water
  ppl[ppl_mom].d=2
  ppl[ppl_will].d=3
  ppl[ppl_corey].d=3
 end
 
 if (inv[7].has) then --sugar
 	ppl[ppl_mom].d=2
 	ppl[ppl_joseph].d=2
 	ppl[ppl_samuel].d=4
 	ppl[ppl_paul].d=1
 end
 
	check_all()

end

function check_all()
 if (dget(0)==255) then
 	ppl[ppl_mom].d=3
 	ppl[ppl_mom2].d=3
 	mset(117,46,s_grass)
 	mset(118,45,s_fence4)
	elseif (dget(0)==127) then
	 ppl[ppl_mom].d=3
	 ppl[ppl_mom2].d=2
	end
end


function setup_inv()
	inv={}
	inv[1]=new_item("salt",12,false)
	inv[2]=new_item("oil",28,false)
	inv[3]=new_item("eggs",44,false)
	inv[4]=new_item("yeast",60,false)
	inv[5]=new_item("flour",14,false)
 inv[6]=new_item("water",30,false)
	inv[7]=new_item("sugar",46,false)
 inv[8]=new_item("challah",62,false)

	trade={}
	trade[1]=new_item("ribbon",13,false)	
 trade[2]=new_item("donut",29,false)	
 trade[3]=new_item("berry",45,false)	
 trade[4]=new_item("jam",61,false)	
 trade[5]=new_item("dreidel",15,false)	
 trade[6]=new_item("invite",31,false)	
 trade[7]=new_item("soup",47,false)	
 trade[8]=new_item("popcorn",63,false)	
 trade[9]=new_item("game",56,false)	
 trade[10]=new_item("soda",51,false)	
 trade[11]=new_item("coin",35,false)	
 trade[12]=new_item("change",35,false)	
 trade[13]=new_item("pico8",122,false)	
 trade[14]=new_item("",29,false)	
 trade[15]=new_item("",29,false)	
 trade[16]=new_item("",29,false)	
end
function new_item(n,s,h)
	local i={}
	i.name=n
	i.sprite=s
	i.has=h
	return i
end
function save_inv()
 local inv_save=0
	for i=0,7 do
		if (inv[i+1].has) inv_save+=2^i
	end
	dset(0,inv_save)
	
	local trade_save=0
	for i=0,7 do
		if (trade[i+1].has) trade_save+=2^i
	end
	dset(1,trade_save)
	trade_save=0
	for i=0,7 do
		if (trade[i+9].has) trade_save+=2^i
	end
	dset(2,trade_save)
	
end

function draw_inventory()
 if (not dlg_active) then
  if (btn(é)) then 
   show_inventory() 
   inv_update=false
  end
  if (inv_update==true and (t()%1<0.5)) then
  	print("é",mapx*8+3,mapy*8+121,0)
  	print("é",mapx*8+2,mapy*8+120,7)
  end
 end
end

function show_inventory()
 invx=mapx*8+10
 invy=mapy*8+8

 rectfill(invx,invy,invx+108,invy+100,0)
 print("á inventory á",invx+24,invy+4,7)

	
	for i=1,7,2 do
		local item1=inv[i]
		local item2=inv[i+1]
		
	 palt(3,true)
		if (item1.has) then
 		spr(item1.sprite,invx+16,invy+12+i*8)
		 print(item1.name,invx+30,invy+14+i*8,6)
		else
			for j=1,15 do pal(j,1) end
 		spr(item1.sprite,invx+16,invy+12+i*8)
		end
		pal()
		palt(3,true)
		if (item2.has) then
 		spr(item2.sprite,invx+60,invy+12+i*8)
		 print(item2.name,invx+74,invy+14+i*8,6)
		else
			for j=1,15 do pal(j,1) end
 		spr(item2.sprite,invx+64,invy+12+i*8)
		end
 	pal()
		
	end

 palt(3,true)
 local misc_pos=invx+16
	for i=1,16 do
		if (trade[i].has) then
		 spr(trade[i].sprite,misc_pos,invy+84)
		 misc_pos+=12
		end
	end
	palt()
end

function has_trade(id)
	for i=1,#trade do
		if (trade[i]==id) return true
	end
	return false
end

function new_inv()
 save_inv()
 sfx(2)
 inv_update=true
end


function get_ribbon()
	ppl[ppl_sarah].d=2
	ppl[ppl_trader].d=2
	trade[1].has=true
end

function get_salt()
	trade[1].has=false
	inv[1].has=true
	if (ppl[ppl_mom].d==1) ppl[ppl_mom].d=2
	ppl[ppl_trader].d=3
end

function get_berries()
 trade[3].has=true
 ppl[ppl_mary].d=2
 ppl[ppl_eli].d=2
end

function get_jam()
	trade[4].has=true
	trade[3].has=false
	ppl[ppl_eli].d=3
	ppl[ppl_mary].d=3
	ppl[ppl_mark].d=2
end

function get_doughnut()
	trade[4].has=false
	trade[2].has=true
	ppl[ppl_mark].d=3
	ppl[ppl_mary].d=3
	ppl[ppl_eli].d=3
	ppl[ppl_jason].d=2
end

function get_eggs()
	trade[2].has=false
	inv[3].has=true
	ppl[ppl_jason].d=3
end

function get_invite()
	trade[6].has=true
	ppl[ppl_olly].d=2
	ppl[ppl_jacob].d=2
	ppl[ppl_simon].d=2
	ppl[ppl_wendy].d=2
	ppl[ppl_stanley].d=2
end

function get_oil()
	trade[6].has=false
	inv[2].has=true
	ppl[ppl_olly].d=3
	ppl[ppl_jacob].d=3
	ppl[ppl_simon].d=3
	ppl[ppl_wendy].d=3
	ppl[ppl_stanley].d=3
end

function get_soup()
	trade[7].has=true
	ppl[ppl_james].d=2
	ppl[ppl_mason].d=2
end

function get_yeast()
	trade[7].has=false
	inv[4].has=true
	ppl[ppl_james].d=3
	ppl[ppl_mason].d=3
end

function get_popcorn()
	trade[8].has=true
	ppl[ppl_helen].d=2
	ppl[ppl_elliot].d=2
end

function get_flour()
	trade[8].has=false
	inv[5].has=true
	ppl[ppl_helen].d=3
	ppl[ppl_elliot].d=3
end

function get_game()
	trade[9].has=true
	ppl[ppl_will].d=2
	ppl[ppl_corey].d=2
end

function get_water()
 trade[9].has=false
 inv[6].has=true
 ppl[ppl_will].d=3
 ppl[ppl_corey].d=3
end

function get_money()
 trade[11].has=true
 ppl[ppl_joseph].d=2
 ppl[ppl_samuel].d=2
 ppl[ppl_paul].d=2
end

function get_soda()
	trade[11].has=false
	trade[10].has=true
	ppl[ppl_joseph].d=2
	ppl[ppl_samuel].d=3
	ppl[ppl_paul].d=1
end

function get_change()
	trade[10].has=false
	trade[12].has=true
	ppl[ppl_joseph].d=2
	ppl[ppl_samuel].d=4
	ppl[ppl_paul].d=3
end

function get_sugar()
	trade[12].has=false
	inv[7].has=true
	ppl[ppl_paul].d=1
end

function get_challah()
	inv[8].has=true
end
-->8
--people

function init_people()
	ppl={}

	add_ppl(ppl_mom,"mom",
	{"hi, honey! happy hanukkah!  \nthe bakery posted a holiday \nrecipe for challah! find me \nthe ingredients, and we'll  \nmake some for hanukkah!",
	 "that's a good start! let me \nknow when you have all of   \nthe ingredients!",
	 "you have everything! meet me\nover the bridge past the    \ngeneral store."})

	add_ppl(ppl_ari,"ari",
	{"i'm supposed to be at the   \ngate to let people through, \nbut i need to get the olives\nharvested from this orchard.\ni'll open it tonight and you\ncan go on through tomorrow!",
	 "these olives make the best  \noil. i love hanukkah because\nit's tradition to serve food\nmade with oil. like brisket,\nchallah, latkes, and even   \ndoughnuts!"})

	add_ppl(ppl_sarah,"sarah",
	{"hi! you're making challah?  \nooh! if i give you a bit of \nribbon, will you let me have\nsome when you're done?",
	 "don't forget to come get me \nwhen the challah is ready!"})

	add_ppl(ppl_trader,"trader",
	{"i'm only here for a day, but\nif you can find me a bit of \nribbon, i'll trade with you \nfor some salt!",
	 "oh, you found some ribbon!  \njust what i was looking for!\nwant to trade for some salt?",
	 "i'm all done trading today. \nthanks again for the ribbon!"})

	add_ppl(ppl_cat1,"cat",
	{"Ç *meow* Ç"})
	add_ppl(ppl_cat2,"cat",ppl[ppl_cat1].l)
	add_ppl(ppl_cat3,"cat",ppl[ppl_cat1].l)
	add_ppl(ppl_cat4,"laura's cat",ppl[ppl_cat1].l)
	add_ppl(ppl_chicken,"chicken",
	{"*cluck* *cluck*"})

	add_ppl(ppl_girl1,"girl",
	{"latkes are my favorite!"})

	add_ppl(ppl_girl2,"girl",
	{"save me some challah bread!"})

	add_ppl(ppl_boy1,"boy",
	{"tonight is the first night  \nof hanukkah! i'm so excited!",
	 "tonight is the second night \nof hanukkah! i'm so excited!",
	 "tonight is the third night  \nof hanukkah! i'm so excited!",
	 "tonight is the fourth night \nof hanukkah! i'm so excited!",
	 "tonight is the fifth night  \nof hanukkah! i'm so excited!",
	 "tonight is the sixth night  \nof hanukkah! i'm so excited!",
	 "tonight is the seventh night\nof hanukkah! i'm so excited!",
	 "tonight is the last night   \nof hanukkah! i'm so excited!"})
 add_ppl(ppl_boy2,"boy",ppl[ppl_boy1].l)

	add_ppl(ppl_baker,"jerry the baker",
	{"i was taking a nice walk in \nthe forest, but i seem to   \nhave mislaid my recipe notes\nfor challah bread. oh well! \nhopefully someone finds them\nuseful!"})

	add_ppl(ppl_eli,"eli",
	{"bah! go away!",
	 "bah! go aw--oh, berries? for\nme? from mary? well, shucks.\nisn't that sweet of her.    \nhere, take this jam. i just \njust love making jam, but i \nhaven't had enough berriers \nfor a while.",
	 "can't talk now. i've got to \nfinish this gift for mary.  \nisn't she just the sweetest?"})
	
	add_ppl(ppl_david,"david",
	{"sorry, but the road is too  \novergrown with trees! it'll \ntake me the rest of the day \nto get all this cleared out.\ncome back tomorrow!",
  "phew! that was a lot of work\ngetting those trees cleared!\nhopefully it'll be a few    \nyears before it needs to be \ncut down again!"})

 add_ppl(ppl_jason,"jason",
 {"eggs, eggs, eggs. all i eat \nare eggs! what i wouldn't   \ngive to have something sweet\nlike a doughnut. i'd get one\nmyself, but after building  \nthe maze, i couldn't find my\nway back out!",
  "doughnuts! i've been stuck  \neating eggs since i built   \nthe maze and accidentally   \ntrapped myself here. would  \nyou trade me that doughnut  \nfor some eggs?",
  "mmm... that doughnut was so \nyummy. i really should get  \nto work taking down the maze\nso i can eat something other\nthan eggs."})

	add_ppl(ppl_lea,"lea",
	{"i bet mr. eli wouldn't be   \nsuch a grump if he had a    \ngood hobby."})

	add_ppl(ppl_mary,"mary berry",
	{"oh, dear. sounds like eli's \nbeing a grump again. here.  \ntake these berries to him.  \nthat always cheers him up!  \nif he tries to refuse, tell \nhim it's hanukkah and this  \nis my gift to him.",
	 "now, now. no dilly-dallying.\nget yourself over to eli and\nbring him those berries.",
	 "did eli like the berries? i \nhope so! i hope he brings me\na gift for hanukkah too!"})

	add_ppl(ppl_mark,"mark",
	{"i've been looking to make   \nfruit-filled doughnuts, but \ni don't have anything to put\nin them! let me know if you \nfind anything i can use.",
	 "oh, that'll do nicely! here,\nhave a fruit-filled doughnut\nto go!",
	 "i'm all out of doughtnuts   \ntoday. sorry!"})

 add_ppl(ppl_girl3,"girl",
  {"i always lose at dreidel!"})
 add_ppl(ppl_girl4,"girl",
  {"i always win at dreidel!"})

	add_ppl(ppl_john,"john",
	{"i keep trying to get this   \nbutton to work, but it just \nwon't budge! my brother is  \ncoming tomorrow with oil to \nfix it. it's funny you know,\nbecause of hanukkah. oil for\nthe food and oil for the    \nbutton! haha!",
	 "i got the button fixed! you \nshouldn't have any problem  \nwith crossing anymore."})

	add_ppl(ppl_stanley,"stanley",
 {"we're trying to figure out a\nhanukkah present for olly. i\nknow he doesn't like parties\nmuch, but i hope he'll come \nto ours.",
  "olly wants us to visit him  \nfor hanukkah? tell him of   \ncourse we will join him!    \nyou're making challah bread?\nyou should join us! here's  \nsome oil you can use for the\nrecipe! see you soon!",
  "don't forget the challah!"})

	add_ppl(ppl_wendy,"wendy",
	{"do you have any ideas for a \npresent for olly? i know he \nlikes cooking. maybe a new  \nrecipe book?",
  "olly wants us to visit him  \nfor hanukkah? tell him of   \ncourse we will join him!    \nyou're making challah bread?\nyou should join us! here's  \nsome oil you can use for the\nrecipe! see you soon!",
	 "see you at the party!"})

	add_ppl(ppl_jacob,"jacob",
	{"i am usually pretty good at \nfiguring out gifts for my   \nfriends, but olly is a tough\nnut to crack. maybe you can \nfind out from him what he   \nwants? will you ask him?",
  "olly wants us to visit him  \nfor hanukkah? tell him of   \ncourse we will join him!    \nyou're making challah bread?\nyou should join us! here's  \nsome oil you can use for the\nrecipe! see you soon!",
	 "see you soon!"})

	add_ppl(ppl_simon,"simon",
	{"i hope we can figure out a  \nhanukkah gift for olly. he's\nsuch a good friend, but we  \ndon't see him very often.",
  "olly wants us to visit him  \nfor hanukkah? tell him of   \ncourse we will join him!    \nyou're making challah bread?\nyou should join us! here's  \nsome oil you can use for the\nrecipe! see you soon!",
	 "see you at olly's!"})

	add_ppl(ppl_olly,"olly",
	{"oh, hi. it gets so lonely   \nhere in the forest. what i'd\nlove more than anything is  \nif my friends came to visit \nme here for hanukkah. would \nyou bring them this invite? \nthank you so much!",
	 "let me know what they say!",
	 "they said yes? oh wonderful!\nyou're invited too, ya know.\nsee you at the party!"})

 add_ppl(ppl_girl5,"girl",
  ppl[ppl_boy1].l)
 add_ppl(ppl_girl6,"girl",
 {"i once ate 23 latkes!"})

	add_ppl(ppl_james,"james",
	{"well, hello! happy hanukkah!\nsince you're passing through\nthis way, i was wondering if\nyou would be willing to take\nthis batch of soup up to my \nfriend mason. he runs the   \nmatzo shop. he loves using  \nmy soup for matzo ball soup!",
	 "don't dally now! the soup   \nwill get cold!",
	 "thanks so much for bringing \nmason the soup!"})
	
 add_ppl(ppl_sam,"sam",
 {"ever hear of herding cats?  \nya. it's no joke. it really \nis that hard."})

 add_ppl(ppl_erin,"erin",
 {"have you seen daniel or zoe?\nwe're playing hide and seek \nand they're really good."})

 add_ppl(ppl_daniel,"daniel",
 {"shhh! don't tell erin where \ni am! hehe!"})

 add_ppl(ppl_zoe,"zoe",
 {"go! go! you'll give away my \nhiding spot! we're playing  \nhide and seek!"})

	add_ppl(ppl_mason,"mason",
	{"happy hanukkah! i'd offer   \nyou some matzo ball soup but\ni'm fresh out of soup!",
	 "oh, thank you! i just ran   \nout of soup and here you are\nwith more! james makes the  \nbest soup. this is a matzo  \nshop, so i don't have a lot \nof use for yeast. you're    \nwelcome to help yourself to \nwhat i have!",
	 "mmm! you should try this    \nmatzo ball soup! it is just \ndelicious!"})

	add_ppl(ppl_adam,"adam",
	{"would you look at this? all \nthese rocks came crashing   \ndown last night! it'll take \nme all day to clear this up!\ncome back tomorrow if you   \nare trying to come through.",
	 "that was not easy! those    \nrocks were so heavy! but at \nleast the path is clear now!"})

	add_ppl(ppl_richard,"richard",
	{"i gave my brother oil to fix\nthe other button, but now   \nthis one is stuck! maybe i  \ncan see if he has any left. \ncome back tomorrow and i    \nshould have it fixed.",
	 "whew! got the button fixed! \nyou can go on through now.  \nthe spikes should stay down \nwhile you walk over them... \ni hope..."})

 add_ppl(ppl_girl7,"girl",
 {"hanukkah is fun, but purim  \nis my favorite holiday."})
 add_ppl(ppl_girl8,"girl",
 {"the menorah is so pretty on \nthe last night of hanukkah!"})

 add_ppl(ppl_helen,"helen",
 {"i made popcorn at lunchtime \nfor my husband elliot. but  \nthen the silly goose forgot \nto bring it with him when he\nwent back to the mill! will \nyou bring it to him for me?",
  "don't forget now! he's down \nat the mill.",
  "thanks so much for bringing \nelliot his popcorn! it will \nhelp tide him over until it \nis time for dinner."})

 add_ppl(ppl_elliot,"elliot",
 {"i'm so hungry! my wife helen\nmade me popcorn for lunch,  \nbut i forgot to bring it    \nwith me back to work! i'll  \nhave nothing to snack on in \nthe afternoon.",
  "oh, thanks so much! i can't \nbelieve i left this at home!\nhere, as a thanks, take this\nbag of flour.",
  "mmm... popcorn... mmm..."})

 add_ppl(ppl_thomas,"thomas",
 {"ç i had a little dreidel ç\nç i made it out of clay! ç\nç when it's dry & ready, ç\nçwith dreidel i will play!ç"})

 add_ppl(ppl_nina,"nina",
 {"you're making challah? ooh! \ncan i have some when you're \nall done making it?"})

	add_ppl(ppl_will,"will",
	{"hey, can you do me a favor? \nmy friend corey and i are   \norganizing a big game night.\nhe's putting together the   \ngames and food while i get  \nrsvp's. i made this game and\nthought it'd be fun to play.\ncan you bring it to corey?",
	 "don't forget to bring the   \ngame to corey!",
	 "thanks so much for bringing \nthat to corey! game night is\ngoing to be so much fun!"})

	add_ppl(ppl_corey,"corey",
	{"heya! my friend will and i  \nare organizing a game night.\ncan you see if he has any   \ngames?",
	 "rad! thanks for bringing me \nwill's game! i think we have\nenough games and food now. i\nhave a few extra bottles of \nwater. would you like one?",
	 "don't forget to come to out \ngame night! lots of people  \nwill be there and it'll be a\nlot of fun."})

 add_ppl(ppl_dylan,"dylan",
 {"hmm... this gate seems to be\nstuck. i need to get it open\nbefore will's game night. if\nyou come back tomorrow, i'll\nhave it fixed by then.",
  "i got the gate fixed!"})
  
 add_ppl(ppl_sandra,"sandra",
 {"i like to come here and get \nsome peace and quiet while i\ndraw comics."})

	add_ppl(ppl_laura,"laura",
	{"i had some good ideas for   \ngames we can play at game   \nnight! i can't wait!"})

	add_ppl(ppl_bryan,"bryan",
	{"will and corey are pretty   \ngood at this games thing.   \nthey should start a company!"})

	add_ppl(ppl_pig,"pig",{"*oink!* *oink!*"})

 add_ppl(ppl_girl9,"girl",
  ppl[ppl_boy1].l)
 add_ppl(ppl_girl10,"girl",
 {"i hope they have latkes at  \ngame night!"})

	add_ppl(ppl_samuel,"samuel",
	{"i forgot my money at home!  \nwill you go get it from my  \ndad so i can buy something  \nto drink?",
	 "thanks for getting my money!\ni'm stuck here until i catch\nsomething, though. will you \nbuy me a soda at the store  \nand bring it here?",
	 "a soda! i'm so thirsty! i   \nreally appreciate your help \ntoday. you can keep all the \nchange. maybe you can get   \nsomething at the store.",
	 "i love fishing!"})
	
	add_ppl(ppl_joseph,"joseph",
	{"will you bring this money to\nmy son? he went fishing, but\nhe forgot to bring his money\nwith him to buy a snack.",
	 "hopefully my son catches a  \nfish today! i want to make  \ngefilte fish for hanukkah!"})

 add_ppl(ppl_paul,"paul",
 {"i can't give away things for\nfree. sorry! come back when \nyou've got some money.",
  "a soda? sure thing! here you\ngo. enjoy! happy hanukkah!",
  "sugar? sure, i have that.   \nhere you go!"})

	add_ppl(ppl_jerry,"jerry",
	{"the bridge is out! i'll have\nto get some more wood to fix\nit. come back tomorrow and  \nit should be all fixed.",
	 "i got the bridge fixed! you \ncan go on over."}) 

	add_ppl(ppl_mom2,"mom",
	{"hi, honey! looks like you're\na few ingredients short of  \nwhat we need to make challah\nbread! come see me when you \nhave all the ingredients!",
	 "you got all the ingredients!\nhooray! now we'll have some \nyummy challah bread for our \nhanukkah feast! bring this  \nloaf of challah bread down  \nto the clearing and we'll   \ncelebrate! don't dally now!",
	 "i'll meet you down at the   \nclearing! don't forget to   \nbring the challah!"})

	add_ppl(ppl_mom3,"mom",
	{"happy hanukkah!"})
	
	add_ppl(ppl_sheep,"sheep",
	{"i know i'm just a sheep, but\ni feel it's my duty to tell \nyou that you can reset this \ngame by pressing enter and  \nchoosing to reset progress. \nbye! i mean...baaa! ya! baa!"})

	add_ppl(ppl_william,"william",ppl[ppl_boy1].l)
	
	add_ppl(ppl_zep,"zep",
	{"hello! thanks for visiting!"})	
end

function add_ppl(id,n,lines)
	local person={}
	person.n=n
	person.i=itm
	person.d=1
	person.l=lines
	ppl[id]=person
end

function is_person(x,y)
	return ppl[y*128+x]!=nil
end

function talk(x,y)
	local id=xy(x,y)
	if (ppl[id]) then
		local person=ppl[id]

		set_dlg(person.l[person.d],ceil(#person.l[person.d]/29),person.n)

 	if (id==ppl_mom) then

 	elseif (person.n=="ari") then
 		
 	elseif (id==ppl_trader) then

 	 if (trade[1].has) then
 	 	get_salt()
 	 	new_inv()
	   check_all()
 	 end

 	elseif (person.n=="sarah") then
 		
 		--get ribbon
 		if (person.d==1) then
 			get_ribbon()
 	 	new_inv()
 		end 	
 		
 	elseif (person.n=="mary berry") then
 	 if (person.d==1) then
 	 	get_berries()
 	 	new_inv()
 	 end
 	elseif (person.n=="eli") then
 	 if (person.d==2) then
 	 	get_jam()
 	 	new_inv()
 	 end
 	elseif (person.n=="mark") then
 	 if (person.d==2) then
 	 	get_doughnut()
 	 	new_inv()
 	 end	
  elseif (person.n=="jason") then
  	if (person.d==2) then
  		get_eggs()
  		new_inv()
	   check_all()
  	end
  elseif (person.n=="olly") then
   if (person.d==1) then
   	get_invite()
   	new_inv()
   end
  elseif (person.n=="simon" or person.n=="jacob" or person.n=="wendy" or person.n=="stanley") then
   if (person.d==2) then
   	get_oil()
   	new_inv()
	   check_all()
   end
  elseif (person.n=="james") then
  	if (person.d==1) then
  		get_soup()
  		new_inv()
  	end
  elseif (person.n=="mason") then
   if (person.d==2) then
    get_yeast()
    new_inv()
	   check_all()
   end
  elseif (person.n=="helen") then
   if (person.d==1) then
   	get_popcorn()
   	new_inv()
   end
  elseif (person.n=="elliot") then
   if (person.d==2) then
   	get_flour()
   	new_inv()
	   check_all()
   end
  elseif (person.n=="will") then
   if (person.d==1) then
   	get_game()
   	new_inv()
   end
  elseif (person.n=="corey") then
   if (person.d==2) then
   	get_water()
   	new_inv()
	   check_all()
   end
  elseif (person.n=="samuel") then
  	if (person.d==3) then
  	 get_change()
  	 new_inv()
  	end
  elseif (person.n=="joseph") then
   if (person.d==1) then
   	get_money()
   	new_inv()
   end
  elseif (person.n=="paul") then
  	if (person.d==2) then
  		get_soda()
  		new_inv()
  	elseif (person.d==3) then
  		get_sugar()
  		new_inv()
	   check_all()
  	end
  elseif (id==ppl_mom2) then
   if (person.d==2) then
    get_challah()
    new_inv()
    check_all()
   end
  elseif (id==ppl_zep) then
   if (not trade[13].has) then
    trade[13].has=true
    new_inv()
   end
  end
 	
	end
end


__gfx__
0000000000aaa0043330033333333333444444454544444444444444944444444111111111111111330303333303033333555533388338833333333333354333
000000000aaaaa043306603333333333454544454445454445454544a54544444521111111111114001033370010333333d67c33888888883333333333354333
007007000af1f10433d0013333333333444545454545444444454445c5444544444545421145444400007773000077773d6116c3888888883333333333354333
00077000aaffff0433d6613333333333454545444545454449494949c9494949454542111111454437777777377777773d61667328822882337733333444fff3
0007700011cfc11f33d001333333333345444545454445444a4a4a4a1a4a4a4a454445454544454437777777377777773d611663322ee223377f77333454f4f3
00700700f0ccc004330660333333333344454445444544444c4c4c4c1c4c4c4c444544454445444437777777377777773d66166333eeee33f7777f733445f4f3
000000000111110433d001333333333345454544454545444c4c4c4c1c4c4c4c454545444545454437373737373737373d6116733ee33ee3f777f7733344ff33
000000001411140433d6613333333333444544444444444441212121112121214445444444444444303030303030303035dd7773ee3333ee36ff76f73334f333
333fff33333333334444444444444444333333333333333345444544454544443003300333333333333344433333333333dccc33333333333334433333333333
33fffff33333333345454544454544443333333333333333454545454545454406600660333333334334747333334443333dc3333322223333666c3333333333
331f1f4333b33333444544454544454433333333333333334445444545444544d001d0013333333344444499433474733dc97cc3322ee22333367333f777777f
33f4f453333333b3454545454545454433333333333333334545454444454544d661d661333333334444544344444499d49aa7ac3222222333dcc73376777767
3945459933333333454445444445444433333333333333334444444444444444d661d661333333335445443344445443d49aaa7c3f2222f33dc7cc7377688677
f354599f33333333444544454544454433333333333333335555555555555555d661d661333333333554433354454433d499aaac34ffff433dcc7c7377728777
3311111333b33333454545444545444433333333333333331411111111111214d661d661333333333a33a333355443333d499ac3334444333dcccc63f777777f
3343334333333333444445454444454433333333333333331433333333333314300330033333333333a33a3333a33a3333dddd333333333333ddd63333333333
3333333311111111111111113333333333333333333333333333333333333333333e33e3333e33e333333343333333433333333333bb3b333333333333733733
3333333311cc11111155511133aaa73336775443333333333033303336333633e33eeee33e3eeee3333336043333360433333333322222233333333337117133
3333333311111111155655113a99777367544f4433333b330503050306030603e33e0e03e33e0e033333644463336444333f733328f888f23333333331744713
3333333311111111155565113a9777a3754f44f13b33333330333033303330333eeeeeee3eeeeeee645554433455544333f77733288888823337733319444441
3333333311111111125555513a7779a35444f442333333333333333333333333eeeeeeeeeeeeeeee345544433455444333f77763288f88823367773321944417
333333331cc11cc1c255655c377799a344f44427333333333033303336333633eeeeee33eeeeee33444444434444444333f7776332888f233d6677d325111166
33333333111111111c2255c1337aaa33144f427633333b330503050306030603e3e3e3e3e3e3e3e3434343434343434333f776d33328823331ddddd322666667
333333331111111111cccc1133333333311227633333333330333033303330330303030303030303535353535353535333366d33333223333311113332266673
64444446666166614444444433666333333333333333333333333333333333335dd52c9533333333333333333333333333333333355666633333333333a7a933
54444445555255524141114136650633333333333333333336333633303330335555292536666633393339399333393933333333336ee633333354433f9a9793
44444444444444444444444431666133336666333333333306030603050305035dd52c9536dd6d639333399993333999333333333588876333544f44a9afafa9
64444446414114141144141431ddd1333666666333666633303330333033303355559c25366666639333379793333797337f33333588e863354f44f166777777
5444444544444444444444443166d533356666533666666333333333333333335dd5555536ddd663994949999949499937f4ff333528e8635444f4423d6d6d63
44444444114141146664666435dd6133335555333366663336333633303330335555d5553666666339494993394949934ffff4f33528886344f444233e7e7e73
644444464444444455525552316dd1333333333333333333060306030503050315d5555136d6dd63399999933999999346f64ff335228863144f42333e7e7e73
54444445141144145555555533ddd33333333333333333333033303330333033311111133666666393939393939393933644664f33555533311223333e7e7e73
10000000000006666660000133355533333555333355533333444336336663333333333333333333333333333333333333333333333444333333333333444333
044fffffffff6f1111f6f4403344445333ffff5335444433344444663666663333aaa3333322233333333333333333333332223333444443333aaa3334444433
044f111111111f0000f1f44033141453331f1f533541413334f1f13666f1f1333aaaaa3332222233333333333333333333222223331f1f4333ffffa336414133
044f555555555f0000f5f4403344444333fffff3344444333fffff3466ffff34aaf1f1332241413333777733333333333314142233ffff43331f1fa336444433
044f444444444f0000f4f44039799799fc7cc7cc577777544444444f2ddfdd2fccffff33ee4444333733337333333333334444ee39aaaa9933ffff2226666623
044f444444444ffffff4f44043777794337777cf45556533f5556534fddddd34f54464c345dd6de373333337733333373ed6dd54f346445f3246445f45666634
044f4444444441111114f44033777793337777c33999993334444434366666343ccccc3f3eeeee34333333333733337343eeeee333999993f322222332266633
044f4444444445555554f44033433343334333433433343335333533d4ddd4d4cfcccfc3e4eee4e333333333337777333e4eee4e33f333f33343334335333533
044f4444444444444444f440335553331111111111111111111111113ff33ff33ff33ff333333333333333333333330000333333334443333300033338877333
044ffffffffffffffffff44035555533111111111111111111111111ff1ff11ff11ff1ff3333333333333a33333300333100333334ffff333000003338888883
04411111111111111111144035f1f133111111111111111111111111f11111111111111f333333b33333a9a3330013333333003334f1f13300f1f13339f1f133
044555555555555555555440377fff331111111cc11cc11cc11111113f111cc11cc111f333b33bb333333a333011353133133103354f4f3300ffff3339ffff33
0444444444444444444444405577775311111cc11cc11cc11cc111113f11c11cc11c11f333bb3b3333a333330153333311333310dd5454d388999983e99999e3
000000000000000000000000f247773f1111c11111111111111c1111f11c11111111c11f333b33333a9a33330513313333331330f1d5453ff544643ff599993f
044444444444444444444440355555331111c1fff11ff11fff1c1111f11c11111111c11f3333333333a33333053113333533311031111133388888333dd99933
00000000000000000000000034333433111c11f33ff33ff33f11c1113f11c111111c11f333333333333333330533333133135350343334333433343334333433
0fffffff04444440fffffff044444444111c11f3331113333f11c1113f11c111111c11f311111111111111110553533311333550333333333344433333344433
0000000005555550000000004ffffff01111c11f31556133f11c1111f11c11111111c11f11111111111111113051331333331503330000333444443333444443
0100000105444450100000104f0ff0f01111c11f31555613f11c1111f11c11111111c11f1cc11cc1111cc11130551133531155033013320344f1f133331f1f43
0400000405444450400000404f0f0ff0111c11f3125655613f11c1113f11c11cc11c11f3111111111111111133055555555550330133332044ffff3333ffff43
04fffff40544a4504fffff404ffffff0111c11f3125565513f11c1113f111cc11cc111f311111111111111c13330001555000333053535302288882335525555
000000000544045000000000400000001111c11f12555551f11c1111f11111111111111f111111111cc11111355505000040555305535350f544643ff352555f
044444440544445044444440333453331111c11f31255513f11c1111ff1ff11ff11ff1ff1111cc11111111115555054544405555015555503222223333111113
10000000100000010000000130045333111c11f3001111333f11c1113ff33ff33ff33ff311111111111111113355200000025533500000033433343333133313
30033003332001333320013333300333111c11f33ff33ff33f11c111333333331111111144344443333333333333333333333333300330033330033333200133
0ff00ff0330ff033330ff033330ff0331111c1fff11ff11fff1c111133333333111111114444445433383333333330000003333306600660330ff033330ff033
200120013320013333200133332001331111c11111111111111c11113333333311111111345444443397f3333335044454505333d001d00133d0013333d00133
2441244133244133332441333324413311111cc11cc11cc11cc111113333333311111111444444443a777e333355050000405533d661d66133d6613333d66133
244124413324413333200133332001331111111cc11cc11cc111111133333333111111114444454333b7d3333355054544405533d661d66133d0013333d00133
2441244133244133330ff033330ff033111111111111111111111111333333331111111144444444333c33333355000000005533d661d661330ff033330ff033
24412441332441333320013333200133111111111111111111111111333333331111111134454444333333333355044444405533d661d66133d0013333d00133
300330033330033333244133332441331111111111111111111111113333333311111111444433443333333333352000000253333003300333d6613333d66133
a646777777979797777777959577668746b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c69797b6c6b6c6b5c5b6c69797b6c6b6c6b6c6b6c6b6
b5c5b6c6b5c5b5c5569797565656b5c5b6c6b6c6b6c6b6c6b6c6b6c6b6c6d6d6b6c677777777777777777777b5c5b5c5b5c57795779797777777779577b6c6b5
874677a37777979777779595777766874785b5c5b5c5b5c5b5c5a5a59595959595959595a5a5b5c5b5c537979777b5c5c5b6c6b5c59797d6b5c5b5c5b5c5b5c5
b6c6b5c5b6c6b6c656979756b5c5b6c6c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c57777777795779777779577b6c6b6c6b6c67777779797957795777777b5c5b6
874695119577777777777777777766878746b6c6b6c6b6c6b6c6777557575757575757578577b6c6b6c627979777b6c6c6b5c5b6c69797d6b6c6b6c6b6c6b6c6
b5c5b6c69595959577979777b6c6b5c5c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c677779577567777777777b5c5b5c5b5c5779577959797777777041424b6c6b5
96469595957777977794a4c477776687874785b5c5b5c5b5c57777669687878787a68796467777b5c5d62797977777b5c5b6c6b5c59797d6041424b5c5e4b5c5
b6c6a5a5a5a5a577779777777777b6c6b5c595777777777777777777772777777777777777777777977777b6c6b6c6b6c6777777779797779577051525b5c5b6
87478595959577777777777777776687878746b6c6b6c6b6c67777668787a68796878787467777b6c6d627979777a5b6c6b5c5b6c69797d6051525b6c695b6c6
9395a5041424a577777797777795b5c5b6c677a5041424a577a5777795277795777756777795779797779577b5c5b5c5b5c57777779797777736061626b6c6b5
228746a5777777977777777777116687878746a5a57777777777777655555555555555558677777777d62797977777b5c5b6c6b5c59797360616269595b5c5b5
c595a5051525a577777777777777b6c6b5c577a5051525a57777957777277777777795777777779797777777b6c6b6c6b6c67795779797777777359777b5c5b6
87874677a577777777a5755757576787878746a5959595959595959595959595959595959595959595952797977777b6c6b5c5b6c69797959597959595b6c6b6
c695a50616263677779777957777b5c5b6c677a506162636777777770707777777777777777777979777567795b5c5b5c5777777779797979797979795b6c6b5
8796467777847777755767878787a687878746950414249595950414249595950414247495d404142495279797a577b5c5b6c6b5c597979797979595b5c5b5c5
b5c595a597a57777777777777777b6c6b5c577a5a597a5a5777777779797979797979797979797979777777777b6c6b6c6957777779797777795777777b5c5b6
874586777777777766a687962287878787874695051525959595051525959595051525359534051525952797977777b6c68495b6c697979595959595b6c6b6c6
b6c6957797777777777777777777b5c5b6c67777359797977777977777979797979797979797979797779577b5c5b5c5b5c57795779797779577041424b6c6b5
8746b5c5b5c57775678787455555658787874695061626360707061626360707061626360707061626361797977795b5578595959597979595c49595b5c5b5c5
b5c5778277f57777779577779577b6c6b5c57777777777777777777707077777777795777777779797777777b6c6b6c6b6c67777779777777777051525b5c5b6
8746b6c6b6c67567879687469536668787874695a597a5a5a5a5a597a5a5a5a5a597a5a5a5a5a597a577a597979595b6874785957797979595959595b6c6b6c6
b6c6779597777777777777777777b5c5b6c67777b5c577a57777b5c57737775677777777779577979777775677b5c5b5c5779577777777777736061626b6c6b5
874695b5c5756787a68787469577668787874695779797979797979797979797979797979797979797979797979595b587a6478577979795959595b5c5b5c5b5
c5b5c57777777777779577777777b6c6b5c5a577b6c677777777b6c67727779577777777777777979777777777b6c6b6c6777777777797777777019777b5c5b6
a646a5b6c66687224555558677116687878746777777777797979797979797979797979797979797979797979795d6b69687874677979777957795b6c6b6c6b6
c6b6c677779577777794a4c47777b5c5b6c67777777777777777777777277777777777567777779797777777b5c5b5c5b5c57795779777779777979777b6c6b5
87469595a56696874656951111a566878787467794a4c477979777b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b587878746779797957795b5c5b5c5b5c5
b5c5b5c577777777777777777777b6c6b5c57777779577777777a57777277777779577777777779797779577b6c6b6c6b6c677777777777777777777777777b6
874757575767878747575757575767878787467795777777979777b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b687879646779797777777b6c6b6c6b6c6
b6c6b6c677779577957777777777b5c5b6c6b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c57797977777b5c5b5c5b5c5b5c50707d70707b5c5b5c5b5c5b5c5
878787878787228787a687878787878787874677779595779797b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5878787467797977777b5c5b5c5b5c5b5
c5b5c59577777777777777777777b6c6b5c5b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c67797977756b6c6b6c6b6c6b6c67777777777b6c6b6c6b6c6b6c6
8787878787878787878787878787878787874677777777779797b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c666878787878787467797977777b6c6b6c6b6c6b6
c6b6c69577777777777777777777b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c577979777b5c5b5c5b5c5b5c5d67777777777d6b5c5b5c5b5c5b5
87878787878787878787878787878787878746777777777797977777d6b5c5b5c5b5c5b5c5d6041424b5c5d6669687a68787a6467797977777777795779593b5
c5d6957775575757578577777777b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c677979777b6c6b6c6b6c6b6c677777777207777b6c6b6c6b6c6b6
8787455555555555555555555555555555558677777777779797777777b6c6b6c6b6c6b6c6d6051525b6c67766878787968787467797977737070707070707b6
c67777756787878787478577777777b5c5377777777777b5c577957777773777777777b5c5d677979777d6b5c5b5c5b5c5b5c50707910707b5c5b5c5b5c5b5c5
658746b5c5b5c5b5c5b5c5b5c5b5c5777777777777777777979777777777b5c5b5c5b5c5b5c506162636f47776555555555555867797977727a57777777795b5
c57775678787878787874677777777b6c6279504142477b6c695041424772777957777b6c60707d7d70707b6c6b6c6b6c6b6c677a341b077b6c6b6c6b6c6b6c6
668746b6c6b6c6b6c6b6c6b6c6b6c67777b2777777a07777979777777777b6c6b6c6b6c6b6c677977777777777777777777777777797977727a37704142477b6
c695668745555565878746777777777777277705152595777777051525772777777777777777d59797777777b5c5b5c5b5c577777777777777a5777777b5c5b5
668746b5c5a5a5a5a593b5c577a2777777777777777777779797777777b5c5b5c5b5c5777777779797979797979797979797979797979777277777051525b3b5
c595664586e59566878746777777777777070706162636070707061626360777777795777777779797777777b6c6b6c6b6c67777957777777777779577b6c6b6
668746b6c6a5041424a5b6c6b5c57777b5c5777777a277779797777777b6c6b6c6b6c677777777979797979797979797979797979797977717773606162677b6
c67766469595956687874677777777777777a5a597a5a5a377a5a597a5a5777795777777779577979777777795b5c5b5c577b07777777421310277777777b5c5
668746b5c5a5051525a5b5c5b6c6b5c5b6c67777777777779797777777d6b5c5b5c57777777777979777777777777777777777777777777777777777777777b5
c5776647570357678745867777777777777777779777e6a4f677779777d4777777777777777777979777777777b6c6b6c67777777777844050e47777b277b6c6
678746b6c6a506162636b6c6b5c5b6c6b5c577b077777777979777777777b6c6b6c6777777777797977777777557575757575785070777647777b395777795b6
c6957665870387874586777797779797979797979797979797979797979797979797979797979797977795777795b5c5d6957777b177f46070d4777777b5c5b5
878746b5c5a5a597d4a5b5c5b6c6b5c5b6c6b5c577777777979777777777637777777777777777979777777766968787a6228746777777a577777777a5a377b5
c5777776550355558677777777979797979797979797979797979797979797979797979797979797977777779595b6c6b5c577a57777d580904477a577b6c6b6
878746b6c69595959595b6c6b5c5b6c6b5c5b6c6777777779797979797976397979797979797979797777777668787878787964677957777777777b3777777b6
c6d67795777777959577957777777777777777777777777777777777777777777777777777777777777795959595b5c5b6c677777777946171c477777795b5c5
658746b5c595b2959595b5c5b6c6b5c5b6c6b5c57777a07797979797979763979797979797979797977777776687a6878787874677a37777a39577a577a395b5
c5b5c5b5c5b5c5b5c5b5c57777777777777777777775575757575757575757575757857777779577957795959595b6c6b5c5778277777777777777a27777b6c6
668746b6c69595959595b6c6d695b6c69595b6c67777777777777777777763777777777777777777777777776622878787a62246a57795777777b377777777b6
c6b6c6b6c6b6c6b6c6b6c695777777777777755757678787a687878787968787a687475757575757859595959595b5c5b6c677777777a17777b0777777d6b5c5
668746b5c5a2959595959595959595959595957777777777777777d6d4d6b5c5b5c5b5c5b5c5b5c5b5c5b5c56687879687878746b5c5b5c5b5c5b5c5b5c5b5c5
b5c5b5c5b5c5b5c5b5c5b5c577777777755767a687968787878787878787878787968787878787a6475785959595b6c6b5c595779577777777777777b5c5b6c6
678746b6c695959595959595959595959595777777777777777777d643d6b6c6b6c6b6c6b6c6b6c6b6c6b6c66687228787879646b6c6b6c6b6c6b6c6b6c6b6c6
b6c6b6c6b6c6b6c6b6c6b6c67775575767878787878787878787878787878787878787a687878787878747575785b5c5b6c6b5c57777b5c57795b5c5b6c6b5c5
878746b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5d66696878787878746d6b5c5b5c5b5c5b5c5b5c5b5
c5b5c5b5c5b5c5b5c5b5c5b5c566a68787968787878787a6878796878787a6878787878787879687878796878746b6c6b5c5b6c6b5c5b6c6b5c5b6c6b5c5b6c6
__gff__
00001516010101010101111310001e00010001010a0001011516111300001a00fe010100120804051113111314001c00000000000a0c1516000911131600120001010101010101010101111301010101010101010101010101000001010101010101010901010101010101010101010101010101010101000100000101010101
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
5c6b6c5b5c6b6c5b5c6b6c6b6c5b5c6b6c5b5c6b6c5b5c6b6c5b5c6b6c66787878787878787878787878646b6c6b6c6b6c6b6c6b6c6b6c6b6c5b5c4041425b5c6b6c5b5c6b6c5b5c5b5c5b5c5b5c5b5c5b5c6b6c59595940414259595959596b6c6755567869227878786a786922787878787869787878787878787878787878
6c5b5c6b6c5b5c6b6c59597b7c6b6c5b5c6b6c5b5c6b6c5b5c6b6c59596678786a78787878696a78785468777777775b5c77272777772677266b6c5051526b6c5b5c6b6c5b5c6b6c6b6c6b6c6b6c6b6c6b6c5b5c59595950515259595959595b5c5b5c6756786a78697878787878787878787878787878786a78697878787878
5c6b6c5b5c6b6c7759595977445b5c6b6c5b5c6b6c5b5c6b6c595959596678545555555555555555556877777777776b6c275b5c5b5c7726775b5c6061625b5c6b6c5b5c6b6c5959775977597777775959596b6c70707060616263707070706b6c6b6c5967555678787878786a78786a78227878786978787878786a78787878
6c5b5c6b6c77775959595977776b6c5b5c6b6c5b5c6b6c5b5c595959596621645b5c595959595959595959797979797979256b6c6b6c2677266b6c1111436b6c5b5c6b6c6d5959777777777777777777777777595a5a5a5a79475a5a5a5a5a5b5c6d595959596755555555555555567869545555555555555555567878786978
5c6b6c777759595a595959117777776b6c5b5c6b6c5b5c6b6c595959596678646b6c4041425959404142597979797979795b5c77772727272773111b111111736b6c5b5c595977777979797979797979797979797979797979797977775b5c6b6c59595959595959597777777777667878647759777759777777675678227878
6c5b5c775959595959595a597759775b5c6b6c5b5c6b6c5b5c595959596678645b5c505152595950515259797977775b5c6b6c775b5c65656572111111113a725b5c6b6c595977797979797979797979797979797979797979797979776b6c5b5c5940414259595977777777774f666a7864777759774041427759667878786a
5c6b6c595a595959591177777777776b6c5b5c6b6c4041426c595959596678646b6c606162635960616263797977776b6c2626266b6c777739707070797070706b6c5b5c59777979797777777777777777777777775a5a5a5a797979775b5c6b6c59505152595977777779777979317831317979797750515259776756697878
6c5b5c59595a595959595977775a7777776b6c5b5c50515259595959596621646d595a794459595a794759797977775b5c2777276d27276d6d6d6d3636365b5c5b5c6b6c777979797777494a4c777777777777775a5a5b5c5a5a7979776b6c5b5c59606162635959797777797979327832327979797760616277777766787878
5c6b6c5959592a455a777777597777117777466b6c60616263707070706678646d59597979797979797979797977776b6c2626266d776d6d77346d3636366b6c6b6c5b5c777979777777777759775775757575585a5a6b6c5a5a7979775b5c6b6c595a7943595959777777777777666a7864777979774779777777596756786a
6c5b5c77775a595959775a7777771177777777777777777777777777776678646d59595959595959595959797977775b5c7727776d275b5c275b5c2727275b5c5b5c6b6c77797977597777777757767878786a74585a5a5a5a5a7979776b6c5b5c5959795959597777597777777766225468777979797979775b5c7777675678
396b6c7777595959777777777777777777797979797979797979775a776678646d57757575585940414259797977776b6c2626266d276b6c276b6c2727276b6c6b6c6d7777797977772b775957767869782278787475585a5a7779797777776b6c595979795979777777777777776678645b5c7779797979776b6c7777776756
775b5c59595977777777777777777777797979797979797979797777776621747576545556645950515259797977775b5c2777276d7727272727277777775b5c5b5c77777979797777777777662278787878787878786477777779797777775b5c595959597777777777777777577654686b6c77597779795b5c5b5c59777767
776b6c59597759777777777711777777777777777777777779797777776678545556645a66645960616263797977776b6c26265b5c6d5b5c775b5c5b5c266b6c6b6c77777979777777597757767878787878786978787458777779797979776b6c777759775977775977777757766a645b5c5b5c777779796b6c6b6c7777775b
7777777777777777775a77777777777777117777777773707d7d7073776678646d6674757664775a795a77797977775b5c266d6b6c776b6c6d6b6c6b6c265b5c5b5c77777979775977775776787878787878787878787864777779797979775b5c7777777777777777775775767854686b6c6b6c77777779775b5c5b5c77776b
7b7c77115a7777777777777777777777777777117777717779797771776621646d67555555687777797979797977776b6c772626262626262626772727776b6c6b6c777979797777777766787878786a7878787878786a645b5c5b5c5979776b6c77597777777777775776787854685b5c5b5c7759777777776b6c6b6c77775b
5b5c7777777777777773707070705775757575757575587779797757757654686d5b5c5b5c5b5c77777777797977775b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c77777979777759775776786978787878787878782278646b6c6b6c6d79595b5c777777775977775776787822646d6b6c6b6c777777797777775b5c5b5c776b
6b6c77777711777777725b5c5b5c66786a7878786a786477797777666922645b5c6b6c6b6c6b6c77777777797977776b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c6b6c7779797977777777667878787878227869787878787874585b5c5b5c79596b6c777777777777776678787854685b5c5b5c77775977777759776b6c6b6c7757
5c7777777777797777716b6c6b6c66787878697878786477777777666a69646b6c77777777777777777777797977775b5c5a5a5a5a5a5959777777656579656565797979772a777757767878227878787878787822787878646b6c6b6c796d5b5c7777777746775776786a78646d6b6c6b6c777777777777775b5c5b5c577576
6c40414277777777774041425b5c66786978786a7878647777797766226a64777777777777777777777777797977776b6c5a4041425a59597777797965657965797979777777777766787878786978787878787878786a78744041426d796d6b6c7777775775757678787878645b5c5b5c77777759777759776b6c6b6c666978
5c50515277777977775051526b6c6678545555555555687777777767555568777777777777777777777777797977775b5c5a5051525a5977777977794579656579797777777777577678787878787878787878787878787869505152783078696d59775776786a787869786a646b6c6b6c77597777772a775b5c595775767878
6c60616263777977636061625b5c6678645a4041425a737779777773777777777777777979797979797979797977776b6c5a60616263597777777777777979656577777777577576787869787878787822787878787878785460616263796d5b5c7777666a7878227878787874585b5c773a7777777777776b6c5776786a786a
5c5a794777777977775a795a6b6c6669645a5051525a727779797772777777777777777979797979797979797977775b5c5a5a79445a7777777757757575757575757575757678786a787878787878786a78787869787878645a79445a79596b6c777766787878787878787878646b6c5b5c77777777775b5c57767854555555
6c77797979797979797979635b5c6678645a6061625a727779797772777777777777777979777777777777797977776b6c595979777759777757767878787878787878787878787878787878786978787878787878787854685979797979595b5c777766227878787878787878645b5c6b6c77775977776b6c66695468595b5c
5c77777759797979597777776b6c6678645a5a535a5a727779797772777777777777777979777777777777797977775b5c77597777597777577678786978786a78786a787878786978787878787878787878227878787864597777595979596b6c775966787878787878786a78646b6c5b5c777777775b5c577678645b5c6b6c
6c40414259797979594041425b5c667864707077707071777979777177777777777777797977484a4c7777797977776b6c7777797777777766697878787878787878787878787878787878787878787878787878787854687777595959795b5c39777767566978787822787854685b5c6b6c597777776b6c666a78646b6c5b5c
5c50515259797979595051526b6c666a646d6d776d6d77777979777777774d777777777979777777777777797977775b5c59777777777777667878786a787878787878785455555555555669782278786978786a785468774e77777779796b6c5b5c7777675678786a78785468596b6c772b777759775b5c6678787458596b6c
6c60616263797979776061625b5c6678646d77777777777779797979797979797979797979777777777b7c79777b7c6b6c77777777777777675678697878786a7854555568595959777767555555555555555555556859775977777979795b5c6b6c77597767555678545568775b5c5b5c77777777776b6c6756787874757575
5c5a795a59797979775a795a6b6c6678645b5c77777977797979797979797979797979797977775b5c7777777977775b5c77777777777977776756787878785455685b5c39595b5c777777597777775977777777777777777777797979776b6c5b5c77777777776755687777596b6c6b6c7759777759775b5c66786978787869
6c777979797979797979794d77776669646b6c77777777777777777777777777777777777777776b6c7b7c46777b7c6b6c7777777777777777776755555555685b5c6b6c5b5c6b6c777979797979797979797979797979797979797977775b5c6b6c7777775977777777777777775b5c5b5c77777777796b6c675556786a7878
5c77775b5c7979795b5c77775b5c6678646d5b5c5b5c77777777493a77777777777777775b5c5b5c5b5c5b5c5b5c5b5c5c7777777779777777775b5c5b5c5b5c6b6c5b5c6b6c3445777979797979797979797979797979797979797777776b6c5b5c7777777777777777777777776b6c6b6c775977797777775b5c675556786a
6c77776b6c7979796b6c77776b6c6678646d6b6c6b6c6d777777777777777777777777776b6c6b6c6b6c6b6c6b6c6b6c6c5b5c7777797977776d6b6c6b6c6b6c5b5c6b6c5b5c65653636363665655b5c6d7759774877597777775977776d5b5c6b6c77777777777777777777775b5c5b5c77777777777977776b6c5b5c675556
75581177777979797777777777776678645b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c5b5c79795b5c5b5c6b6c5b5c79795b5c5b5c5b5c5b5c5b6b6c5b5c6b6c65656579796565656b6c5b5c5b5c5b5c5b5c5b5c5b5c5b5c6b6c5b5c777777777777777777776d6b6c6b6c6d7777777979775977776b6c5b5c67
__sfx__
010400000c03300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003
000600002f05000000340503405034050340403404034020340100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007000016070160701d0702407000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000700001961438614006040060400604006040060400604006040060400604006040060400604006040060400604006040060400604006040060400604006040060400604006040060400604006040060400604
010200000d52200502005020050200502005020050200502005020050200502005020050200502005020050200502005020050200502005020050200502005020050200502005020050200502005020050200502
01030000270212c0413006131061320713207131061300612c0412702100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001
0114001800140005351c7341c725247342472505140055352173421725287342872504140045351f7341f725247342472502140025351d7341d72524734247250000000000000000000000000000000000000000
011400180c043287252b0152f72534015377253061528725290152d72530015377250c0432f7253001534725370153c725306152b7252d01532725370153b7250000000000000000000000000000000000000000
0114001809140095351f7341f7252473424725091400953518734187251f7341f72505140055351f7341f7252473424725051400553518734187251f7341f7250000000000000000000000000000000000000000
0114001802140025351f7341f725247342472504140045351f7341f725247342472505140055352b7242b715307243071507140075352b7242b71534724347150000000000000000000000000000000000000000
011400180c0433772534015307252f0152d725306152d7252f0153072534015377250c0433772534015307252f0152d725306152d7252f0153072534015377250000000000000000000000000000000000000000
011400180c0433c7253701534725300152f725306152f7253001534725370153c7250c0433c7253701534725300152f725306152f7253001534725370153c7250000000000000000000000000000000000000000
011400180c043287252b0152f725340153772530615287252901530725370153c7250c043287252901530725370153c72530615287252901530725370153c7250000000000000000000000000000000000000000
011400180c003287052b0052f705340053770530605287052900530705370053c7050c0032f7053000534705370053c705306052b7052d00532705370053b7050000000000000000000000000000000000000000
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
01 06 07 43 44
00 06 07 43 44
00 08 0a 43 44
00 08 0b 43 44
02 09 0c 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
