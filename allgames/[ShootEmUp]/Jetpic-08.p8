pico-8 cartridge // http://www.pico-8.com
version 30
__lua__
--jetpic-o8
--by coffeebat
poke(0x5600,unpack(split"8,8,10,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,63,63,63,63,63,63,63,0,0,0,63,63,63,0,0,0,0,0,63,51,63,0,0,0,0,0,51,12,51,0,0,0,0,0,51,0,51,0,0,0,0,0,51,51,51,0,0,0,0,48,60,63,60,48,0,0,0,3,15,63,15,3,0,0,62,2,2,2,2,0,0,0,0,0,32,32,32,32,62,0,34,20,8,62,8,62,8,0,0,0,0,24,0,0,0,0,0,0,0,0,0,8,16,0,0,0,0,0,0,12,4,0,0,0,10,10,0,0,0,0,0,4,10,4,0,0,0,0,0,0,0,0,0,0,0,0,8,8,8,8,8,0,8,0,0,36,36,0,0,0,0,0,0,34,127,34,34,127,34,0,8,63,9,63,40,63,8,0,0,35,19,8,4,50,49,0,0,12,18,12,82,33,94,0,12,12,0,0,0,0,0,0,16,8,8,8,8,8,16,0,4,8,8,8,8,8,4,0,0,20,8,62,8,20,0,0,0,8,8,62,8,8,0,0,0,0,0,0,0,8,8,4,0,0,0,124,0,0,0,0,0,0,0,0,0,12,12,0,64,32,16,8,4,2,1,0,62,97,81,73,69,67,62,0,24,20,16,16,16,16,126,0,62,65,64,62,1,1,127,0,62,65,64,48,64,65,62,0,16,24,20,18,17,127,16,0,127,1,1,63,64,65,62,0,62,1,1,63,65,65,62,0,127,64,32,16,8,8,8,0,62,65,65,62,65,65,62,0,62,65,65,126,64,64,62,0,0,0,8,0,0,8,0,0,0,0,8,0,0,8,8,4,32,16,8,4,8,16,32,0,0,0,126,0,126,0,0,0,2,4,8,16,8,4,2,0,62,65,32,16,8,0,8,0,62,81,105,121,1,1,30,0,0,0,60,64,124,66,124,0,2,2,2,62,66,66,62,0,0,0,60,2,2,2,60,0,64,64,64,124,66,66,124,0,0,0,60,66,62,2,124,0,56,4,4,12,4,4,4,0,0,0,124,66,66,124,64,60,2,2,2,30,34,34,34,0,0,8,0,12,8,8,28,0,16,0,16,16,16,16,18,12,2,2,10,6,6,10,18,0,4,4,4,4,4,4,24,0,0,22,42,42,42,42,42,0,0,0,30,34,34,34,34,0,0,0,28,34,34,34,28,0,0,0,62,66,66,62,2,2,0,0,62,33,33,62,32,96,0,0,56,4,4,4,4,0,0,0,60,2,60,64,60,0,0,4,14,4,4,4,24,0,0,0,34,34,34,34,28,0,0,0,34,34,20,20,8,0,0,0,34,34,42,42,20,0,0,0,34,20,8,20,34,0,0,0,34,34,34,60,32,28,0,0,126,32,24,4,126,0,60,4,4,4,4,4,60,0,1,2,4,8,16,32,64,0,30,16,16,16,16,16,30,0,8,20,34,0,0,0,0,0,0,0,0,0,0,0,30,0,16,8,0,0,0,0,0,0,62,65,65,65,127,65,65,0,63,65,63,65,65,65,63,0,62,65,1,1,1,65,62,0,31,33,65,65,65,33,31,0,127,1,1,63,1,1,127,0,127,1,1,63,1,1,1,0,62,65,1,1,113,65,62,0,65,65,127,65,65,65,65,0,127,8,8,8,8,8,127,0,64,64,64,64,65,65,62,0,33,17,9,7,9,17,33,0,1,1,1,1,1,1,127,0,65,119,73,65,65,65,65,0,65,67,69,73,81,97,65,0,62,65,65,65,65,65,62,0,63,65,65,65,63,1,1,0,62,65,65,65,69,73,62,0,63,65,65,65,63,33,65,0,62,1,1,62,64,65,62,0,127,8,8,8,8,8,8,0,65,65,65,65,65,65,62,0,34,34,34,34,34,20,8,0,65,65,65,65,65,93,34,0,65,34,20,8,20,34,65,0,65,34,20,8,8,8,8,0,127,32,16,8,4,2,127,0,28,4,3,4,4,4,28,0,8,8,8,0,8,8,8,0,28,16,96,16,16,16,28,0,0,0,76,51,0,0,0,0,0,0,0,0,0,0,0,0,127,127,127,127,127,127,127,0,85,42,85,42,85,42,85,0,24,36,60,126,90,60,60,102,62,127,99,99,119,127,62,0,17,68,17,68,17,68,17,0,4,12,124,62,31,24,16,0,28,58,97,97,65,34,28,0,0,99,119,127,62,28,8,0,42,28,54,119,54,28,42,0,28,28,62,93,28,20,20,0,8,28,62,127,62,42,58,0,62,127,103,99,103,127,62,0,62,99,81,65,99,127,62,0,8,120,8,8,8,15,7,0,62,127,99,107,99,127,62,0,8,20,42,93,42,20,8,0,0,0,0,85,0,0,0,0,62,127,115,99,115,127,62,0,8,28,127,28,54,34,0,0,127,34,20,8,20,34,127,0,62,127,119,99,99,127,62,0,0,10,4,0,80,32,0,0,17,42,68,0,17,42,68,0,62,127,107,119,107,127,62,0,127,0,127,0,127,0,127,0,85,85,85,85,85,85,85,0"))
cartdata("jetpico8")
function _init()
fillp()
diff=1
rocket_intensity=0
--do not drip too hard.
drip=false
--i have warned you.
music(0)
cursor(39,64)
title_parallax=-8
change_state(4)
gameversion="1.0"
menu_main={
"\fcstart game", start_submenu,
"\fbcredits", show_credits,
"\fasound test", trans_st,
"\f8delete all data (!)",ask_data,
}
menu_st={
"\f8title theme", p_titlesong,
"\faingame song 1", p_ingame1song,
"\fbingame song 2",p_ingame2song,
"\fcingame song 3",p_ingame3song,
"\f8highscore theme",p_highsong,
"\fagame over theme",p_gosong,
"\fbgo back",trans_realtitle1,
}
menu_play={
"\f9normal", start_game_hard,
'\fe"can i play daddy?"', start_game_easy,
"\f7go back",	reset_menu,
}
menu_askdata={
"\f8yes, delete it all.", restart_data,
"\f7no, go back", reset_menu,
}
menu.entries=menu_main
noshake=false
autoshoot=false
scanlines=false
noshake_display="yes"
autoshoot_display="no"
spcshptype=0
level=0

func=nil
trans=false

menu.start()
player={
 sp=17,
 x=59,
 y=122,
 w=8,
 h=16,
 flp=false,
 dx=0,
 dy=0,
 max_dx=2,
 max_dy=3,
 acc=0.1,
 boost=1.5,
 anim=0,
 running=false,
 floating=false,
 falling=false,
 landed=false,
 linked=false,
 weapon=false,
 invcsc=120,
 tempinvc=0,
 invc=true,
 lifes=3,
}

dust={}

spcshphitbox={
	x=80,
	y=0,
	w=8,
	h=128
}

spcshpb={
 sp=64+spcshptype,
	x=80,
	y=112,
	w=8,
	h=8,
	col=7,
 update=function(self)
	if not cutscene then
		if fuelcounter>=1 then
			self.col=14
	 else
	  self.col=7
		end
	end
	end
	}
spcshpm={
	sp=48+spcshptype,
	x=64,
	y=56,
	w=8,
	h=8,
	col=7,
	onplace=false,
	linked=false,
	falling=false,
	pick=false,
	update=function(self)
	update_spcshp(self,spcshpb,2,0)
	end
}
spcshpe={	
 sp=32+spcshptype,
	x=24,
	y=40,
	w=8,
	h=8,
	col=7,
	onplace=false,
	linked=false,
	falling=false,
	pick=false,
	update=function(self)
	update_spcshp(self,spcshpb,3,1)
	if self.onplace and
	(self.y-8)<spcshpm.y then
	self.y=spcshpm.y-8
	end
	end
}
highscoretext={
x=128,
y=8,
endcorner=-(-32*4*3),
counter=1,
}

ingamemusic={8,16,40}

--object stuff
--spcshpcounter=0
--fallspeed=0.5
spcshpcounter,
fallspeed,
wpn_ammo,
autowpn_cooldown,
fuelcounter,
cutstate,
fadeadd,
fadesize,
goverlasts,
govertemplasts,
ingametimer,
minutes,
seconds
=unpack(split"0,0.5,0,0,0,0,0.002,-1,2,0,0,0,0")
spcshpcutscene=false

fuel={}
--fuelcounter=0

thr={}
--wpn_ammo=0
--autowpn_cooldown=0

enemy={}
ball_enemy={}
plane_enemy={}
ufo_enemy={}
meteor={}
spawn_enemies()

--cutscenes?
cutscene=false
--cutstate=0

--transition
--fadesize=-1
ballfade={}
fadestate=false

--fadeadd=0.002

--game over stuff
--goverlasts=2
--govertemplast=0
gover=false
goverset=false

--timer
--ingametimer=0
--minutes=0
--seconds=0
showtime=nil
stop_time=false
zerotimer=nil

ex_emitters={}

 gravity=0.15
 friction=0.2

	--stars
 stars={}
 star_cols={5,6,7,13,5,6,7,13}
 warp_factor=1

 -- create starfield
 for i=1,#star_cols do
  for j=1,10 do
   local s={
    x=rnd(128),
    y=rnd(128),
    z=i,
    c=star_cols[i]
   }
   add(stars,s)
  end 
 end

highscoretexts={
{t="jetpic-08.a demake of ultimate's"},
{t=" production......thanks to the p"},
{t="ower of the spaceship, jetman ha"},
{t="s escaped from the hell of those"},
{t=" alien planets.now free to conti"},
{t="nue his space adventures, jetman"},
{t=", must search for a colony to ta"},
{t="ke him to safety..... good luck."}
}
toread=tostr(highscoretexts[highscoretext.counter].t)
toread2=tostr(highscoretexts[highscoretext.counter+1].t)
--wobdat="9100f14202681c857c03d39fa66f0600d250f6e087f9a7ffe901980199b8f8104d07691a9c0d0086e6a4d4a20380e1390b960020792e022408c024d4cc694adbd28baa006c016c1c709a93f10c8cba98449a04004271d2344d7bed5bf423aa25007b203187020a58e92515150abc382a342290d7ba6000e0242754db662d603a2a4c1a35203ad701d805eb17b25b086b01"
--wobdat="e000314302d424c50fec07d3093f0180b272cb6a03b003b248209a23d90ce46203d2540400b349610a1a00242149d38b5f70055c5406608f00885d029a1cb202e2050b8e2a7400c07cb48e4057690800b68a02e901c096517a00e6e026293ec81d3c64a219c8311804004cce01d883ad22c56e00f0552c3b002f240023574c7f20fb3bc88fe44d1300286c41a70b9d0e415f543300b0e84a03808eae0c00d6b100f924cf89f9474e3e1200746dc500e06c2b0660079ebf422505fa80a2ec404aeb86b22bd86e4769b435a80400766517d00424400060f5a517f000a0dc7b0000"
--wobdat="cb00314302d424c50fec07d3093f0180b272cb6a03b003b248209a23d90ce46203d2540400b349610a1a00242149d38b5f70055c5406608f00885d029a1cb202e2050b8e2a7400c07cb48e4057690800b68a02e901c096517a00e6e026293ec81d3c64a219c8311804004cce01d883ad22c56e00f0552c3b004f2440935740f33939b361d26f46f22726005b90921696a5a505966ddb140a4a9ba6ab08a4bb6880a66b2ba0ad960ed0296d25a052da0da8c50a00b4de028b0600b960310028068b060032e50380a1f20100"
--wobdat="2b02f14302b892358d06003e68320380e330cc0600ad6490a607200060bcd260480080fb0d0076bcd2a0410280d86e0040e31501406fd70000d82b02801eb10200dbb112801538322b11d33315d169529221a5713c8d4a939381120280163248a7ad36a756bf0118c1d7d750c68a14d000d1020d10002c65450224405ac014d00b340048ce8a54028024af6c00a0b405053c00c30480f366840450d1ca166801e9020ec0300190ca954a00a02a82ea08ab23b08eb0cc81b206ca5a0900963958f260c9b34202207fc1210018ca5a01006b5648f600a0952c01806a562400c304c0ee59a0024cd2c464348d9bc6cc233c4df36904b1c91b12368dcd66028ddf34369be605346f367f80f4679fa605a4e93f7b02bcf9dffc056e9a3e9ba6d32c60d36cfab3e917b8ffff9f9b409ecebff9df2cd03ffd9fa680feffe602f7d36c9a66c0f9e62fe0cdef6cba2095a6d94fb3699a01d2fff4ff05cca63f4d7f02a4d9ff69fad913204dff9f4d80697a9a17303d4d247e3a026453c04d0042488096af344733399a34004836cb800b02be4080a41900b89405291850d0bf8000691a00a852a9686631516d04003160894400000c968800e0172c600030dba502001b0f6cbb220010f20600455e0300a2af080078c52200e0311b1100b47c411704b168428b6cb0280140f3572400b0f18a00a0162d04004369090064d4020600c36a07a00442d7220d50851200a4acc501806b5b4820148800a0b62d1290a2342085060140715b84208810490000"
wobdat="8f02f14302b892358d06003e68320380e330cc0600ad6490a607200060bcd260480080fb0d0076bcd2a0410280d86e0040e31501406fd70000d82b02801eb10200dbb112801538322b11d33315d169529221a5713c8d4a939381120280163248a7ad36a756bf0118c1d7d750c68a14d000d1020d10002c65450224405ac014d00b340048ce8a54028024af6c00a0b405053c00c30480f366840450d1ca166801e9020ec0300190ca954a00a02a82ea08ab23b08eb0cc81b206ca5a0900963958f260c9b34202207fc1210018ca5a01006b5648f600a0952c01806a562400c304c0ee59a0024cd2c464348d9bc6cc233c4df36904b1c91b12368dcd66028ddf34369be605346f367f80f4679fa605a4e93f7b02bcf9dffc056e9a3e9ba6d32c60d36cfab3e917b8ffff9f9b409ecebff9df2cd03ffd9fa680feffe602f7d36c9a66c0f9e62fe0cdef6cba2095a6d94fb3699a01d2fff4ff05cca63f4d7f02a4d9ff69fad913204dff9f4d80697a9a17303d4d247e3a026453c04d0042488096af344733399a34004836cb800b02be4080a41900b89405291850d0bf8000691a00a852a9686631516d04003160894400000c968800e0172c600030dba502001b0f6cbb220010f20600455e0300a2af080078c52200e0311b1100b47c411704b168428b6cb0280140f3572400b0f18a00a0162d04004369090064d4020600c36a07a00442d7220d50851200a4acc501806b5b4820148800a0b62d1290a2342085060140715b8420881049002620b7289a411a266100307ca4aa4a03b0013846406662066c31b001c070915f6517c44061001e6095291041420030d31408482000d0658a01802e7300b0e32400087a820d0084960400414e06004e4d8108220068665a3000b85e0a12210400574ba91200"
str_to_mem(wobdat, 0x4300)
mywob = wob_load(0x4300)

score=0

--shake screen stuff
intensity = 0
shake_control = 5
 
--save stuff
highest_score=dget(0)
display_highestscore=tostr("highest score:"..highest_score)
yousure=false

introtime={
init=0,
lasts=180,
}

px9_decomp(0,0,2560,pget,pset)
balltransition()

--drops
one_up={}
diamond={}
gold={}
spawn_enemies()
end
function restart_data()
	for i=0,63 do
	dset(i,0)
	end
	restart_trans()
end

-->8
--misc functions
function collide_map(obj,aim,flag)
 --obj = table needs x,y,w,h
 --aim = left,right,up,down

 local x=obj.x  local y=obj.y
 local w=obj.w  local h=obj.h

 local x1=0	 local y1=0
 local x2=0  local y2=0

 if aim=="left" then
   x1=x-1  y1=y
   x2=x    y2=y+h-1

 elseif aim=="right" then
   x1=x+w-1    y1=y
   x2=x+w  y2=y+h-1

 elseif aim=="up" then
   x1=x+2    y1=y-1
   x2=x+w-3  y2=y

 elseif aim=="down" then
   x1=x+2      y1=y+h
   x2=x+w-3    y2=y+h
 end

 --pixels to tiles
 x1/=8    y1/=8
 x2/=8    y2/=8

 if fget(mget(x1,y1), flag)
 or fget(mget(x1,y2), flag)
 or fget(mget(x2,y1), flag)
 or fget(mget(x2,y2), flag) then
   return true
 else
   return false
 end

end

function limit_speed(num,maximum)
  return mid(-maximum,num,maximum)
end

--reduced character count
function add_new_dust(_x,_y,_dx,_dy,_l,_s,_g,_f)
add(dust, {
fade=_f,x=_x,y=_y,dx=_dx,dy=_dy,life=_l,orig_life=_l,rad=_s,col=0,grav=_g,draw=function(self)
pal()palt()circfill(self.x,self.y,self.rad,self.col)
end,update=function(self)
self.x+=self.dx self.y+=self.dy
self.dy+=self.grav self.rad*=0.9 self.life-=1
if type(self.fade)=="table"then self.col=self.fade[flr(#self.fade*(self.life/self.orig_life))+1]else self.col=self.fade end
if self.life<0then del(dust,self)end end})
end

function box_hit(o1,o2)
  
  hit=false
  local xd=abs((o1.x+(o1.w/2))-(o2.x+(o2.w/2)))
  local xs=o1.w*0.5+o2.w*0.5
  local yd=abs((o1.y+(o1.h/2))-(o2.y+(o2.h/2)))
  local ys=o1.h/2+o2.h/2
  if xd<xs and 
     yd<ys then 
    hit=true 
  end
  
  return hit
end

function add_exp(x,y)
    local e={
        parts={},
        x=x,
        y=y,
        offset={x=cos(rnd())*2
                                    ,y=sin(rnd())*2
        },
        age=0,
        maxage=20
    }
    for i=0,5 do
        add_exp_part(e)
    end
    add(ex_emitters,e)
end
function add_exp_part(e)
        local p={
            x=e.x+(cos(rnd())*5),
            y=e.y+(sin(rnd())*5),
            rad=0,
            age=0,
            maxage=5+rnd(10),
            c=rnd({15,8,9,10})
        }
        add(e.parts,p)
end
function update_explosions()
    for i=#ex_emitters,1,-1 do
        local e=ex_emitters[i]
        add_exp_part(e)
        for ip=#e.parts,1,-1 do
            local p=e.parts[ip]
            p.rad+=1
            p.age+=1
            if p.age+5>p.maxage then
                p.c=5
            end
            if p.age>p.maxage then
                del(e.parts,p)
            end       
        end
        e.age+=1
        if e.age>e.maxage then
            del(ex_emitters,e)
        end
    end
end

function draw_explosions()
    for e in all(ex_emitters) do
        for p in all(e.parts) do
            circfill(p.x,p.y,p.rad,p.c)
            circfill(p.x+e.offset.x
                                            ,p.y+e.offset.y
                                            ,p.rad-3,0)                                       
            circ(p.x+(cos(rnd())*5)
                            ,p.y+(sin(rnd())*5)
                                            ,1,0)                                                       
        end
    end
end

function draw_starfield()
 --adapted from
	--liquiddream
 -- move stars
 for s in all(stars) do
  -- move star, based on z-order depth
  s.y+=s.z*warp_factor/10
  -- wrap star around the screen
  if s.y>128 then
   s.y=0
   s.x=rnd(128)
  end
 end
 for s in all(stars) do
  pset(s.x,s.y,s.c)
 end
end

function update_table(table,function_type)
--function type table
--1==update
--2==draw
--3==delete
	if function_type==1 then
		for z in all(table) do
		 z:update()
		end
		elseif function_type==2 then
		for z in all(table) do
		 z:draw()
		end
		elseif function_type==3 then
		for z in all(table) do
		 del(table,z)
		end
	end
end

menu={}

function menu.draw()
 if menu.is_running then
  cursor(menu.x,menu.y)
  local i
  local j=0
  color(menu.entryclr)
  for i in all(menu.entries) do
   if j % 2 == 0 then
    print("		"..i)
   end
   j += 1
  end
  cursor(menu.x+(sin(t()+8))*2-4,menu.y+(menu.pos)*6)
  local oldclr = peek(0x5f25)
  color(menu.curclr)
  print(menu.cursym)
  pal(7,0+sin(t())*8)
		--spr(16,menu.x+(sin(t()+8))*2-2,menu.y+(menu.pos)*6-2)
		pal()
  color(oldclr)
 end
end

function menu.update()
 if menu.is_running then
  local dy=0
  menu.curclr=0+sin(t())*8
  if (btnp(”)) dy=-1
  if (btnp(ƒ)) dy=1
  if btnp(—) then
   menu.is_running=false
   menu.entries[2*(menu.pos+1)]()
  elseif btnp(Ž) then
   if menu.cancel != nil then
    menu.is_running=false
    menu.cancel()
   end
  end

  if dy!=0 then
   cursor(menu.x,
    menu.y+(menu.pos)*6)
   local oldclr = peek(0x5f25)
   color(menu.backclr)
   palt(menu.curclr, false)
   print("€")
   color(oldclr)
   palt()
   menu.pos += dy
   menu.pos %= #menu.entries/2
  end
 end
end

function menu.start()
 menu.curclr = menu.curclr or 7
 menu.cursym = menu.cursym or "\014\|fŒ"
 menu.backclr = menu.backclr or 0
 menu.x = peek(0x5f26)
 menu.y = peek(0x5f27)
 menu.entryclr = 7--peek(0x5f25)
 menu.pos = 0
 menu.is_running=true
end

function drawpattern(idx, x0, y0, x1, y1)
    local sprx = 8 * (idx % 16)
    local spry = 8 * flr(idx/16)
    for y=y0,y1,8 do
        local endy = min(y1, y+8)
        local sampleh = endy-y
        for x=x0,x1,8 do
            local endx = min(x1, x+8)
            local samplew = endx-x
            sspr(sprx, spry, samplew, sampleh, x, y, samplew, sampleh)
        end
    end
end

function scale_text(text,tlx,tly,sx,sy,col)
 print(text,0,0,col)
    for y=0,7 do
     for x=0,#text*8-1 do
      local col=pget(x,y)
      if col!=0 then
      local nx=x*sx+tlx
      local ny=y*sy+tly
      rectfill(nx,ny,nx+sx,ny+sy,col)
      end
     end
    end
    print(text,0,0,0)
end

function wob_draw(scn,sx,sy,q)

 sx=sx or 0
 sy=sy or 0
 q=q or flr(time()*6)
 
 local funcs={[0]=
  circfill,circ,
  function(x,y,r,c)
   line(x-r,y,x+r,y,c) end,
	 function(x,y,r,c)
	  line(x,y-r,x,y+r,c) end,
  function(x,y,r,c)
   rectfill(x-r,y-r,x+r,y+r,c)
   end,
  function(x,y,r,c) -- star
		 a=nrnd(1)
		 for j=0,4 do
		  line(x,y,x+cos(a+j/5)*r,
		       y+sin(a+j/5)*r, c)
		 end
		end,
	 function(x,y,r,c,i) -- spin
		 local dx=cos(i*0x0.08)*r
		 local dy=sin(i*0x0.08)*r
		 line(x-dx,y-dy,x+dx,y+dy,c)
		end
 }
 
 local rv
 function nrnd(m)
  rv=rotl(rv,3)
  rv*=0x2518.493b -- mashed
  return (rv%m)
 end

 -- seed wobble by time
 srand(q)
 
 local xx=rnd(1)-.5
 local yy=rnd(1)-.5
 
 for j=1,#scn do
  local crv=scn[j]
  
  local r,col,x0,y0=
  	crv.size,crv.col,
	  sx+crv[2] + xx,
	  sy+crv[3] + yy
	
  local x1,y1=x0,y0
  
  local shape,dotted,noise,pat=
	  crv.shape,
	  crv.dotted/3,
	  crv.noise/3,
	  crv.pat
	 
  if(dotted>0)dotted=max(1,flr(dotted*(1+r)/2))
  
  -- set pattern
  if((col/0x11)%1==0)pat+=0.5  
  fillp(pat)
  
  local sfunc=funcs[shape]
  
  -- random generator for noise
  -- seeded by curve number j
  rv=0x37f9.2407*j
  
  for i=2,#crv-1,2 do
   
   x0=x1 y0=y1
   x1=sx+crv[i]   +xx
   y1=sy+crv[i+1] +yy
   
   -- jump to another rnd
   -- offset closeby 
   -- (prevents crinkles)
   xx=xx*7/8+(rnd(1)-.5)/2
   yy=yy*7/8+(rnd(1)-.5)/2
   
   if (dotted>0) then
   
    -- one every nth point
    
    if ((i-2)/2)%dotted==0 then
     
     if (noise==0) then
      sfunc(x1,y1,r,col,i/2)
     else
     
     local mag=(r+2)*noise*2
     local smag=(r+1)*noise
     local r0=r-r*noise
     
     sfunc(
      x1 + nrnd(mag) - mag/2,
      y1 + nrnd(mag) - mag/2,
      r0 + nrnd(smag),
      col,i/2)
     end
    end
   elseif (shape==2) then
    -- wide brush (lettering)
    for i=flr(-r/2),flr(r+.5)/2 do
		   line(x0+i,y0,x1+i,y1,col)
		  end
   elseif (shape==3) then
    -- tall brush
    for i=flr(-r/2),flr(r+.5)/2 do
		   line(x0,y0+i,x1,y1+i,col)
		  end
   elseif (r<2) then
		  -- common
		  line(x0,y0,x1,y1,col)
		  if (r==1) then 
		  line(x0+1,y0,x1+1,y1,col)
		  line(x0,y0+1,x1,y1+1,col)
		  line(x0+1,y0+1,x1+1,y1+1,col)
		  end
		 else
		  -- cheap hack:
		  -- draw at control point
		  -- and at midpoint.
		  sfunc(x0,y0,r-1,col)
		  sfunc((x0+x1)/2,(y0+y1)/2,
		   r-1,col)
		 end   
  end
 end
 
 fillp()
 
end


-- decode

function wob_load(src)

 local src0=src
 src-=1 
 local bit,b=256,0
 local scn={}
 
 local function getval(bits)
  
  local val=0
  for i=0,bits-1 do
   --get next bit from stream
   if (bit==256) then
    bit=1
    src+=1
    byte=peek(src)
   end
   if band(byte,bit)>0 then
    val+=2^i
   end
   bit*=2
  end
  return val
 end
 
 local dat_len = getval(16)
 local lsize,lcol
 
 -- back color
 scn.back_col=getval(4)
 
 -- read state
 local col,size,shape,dotted,
       noise,pat=
       0,0,0,0,0,0
 
 -- read until out of data
 -- each item is >= 3 bytes
 while (src<src0+dat_len-3) do
 
  -- curve header (3 sections)
  -- 1. 
  local crv=add(scn,{0})
  
 -- {0} --dummy

  if (getval(1)==1) then
   col,size=getval(4),getval(5)
  end
  
  if (getval(1)==1) then
   shape,dotted,noise=
   getval(3),getval(4),getval(3)
  end

  -- set state
  crv.col,crv.size,crv.shape,
  crv.dotted,crv.noise,crv.pat=
  col,size,shape,dotted,noise,0
  
  -- use pattern
  if (getval(1)>0) then
   crv.pat=getval(16)
   crv.col+=getval(4)*16
  end
  
  -- 7 start x,y
  add(crv,getval(7))
  add(crv,getval(7))
  local x0,y0,has_segs,a=
   crv[2],crv[3],getval(1),0
  
  -- read segments
  
  while (has_segs>0) do
   local v=0
   
   if (getval(1)<1) then
    -- read non-zero da
    local neg=getval(1)
    v=1
    while(getval(1)<1 and v<8)
    do v+=1 end
    if (neg>0) v*=-1
   end
   
   if (v==8) then
    -- end of segment
    has_segs=0
   else
    -- add segment
    a+=v
    x0+=flr(.5+cos(a/16)*3)
    y0+=flr(.5+sin(a/16)*3)
    add(crv,x0)
    add(crv,y0)
   end
  end
 end

 return scn
end
-- for loading from string
-- copied from clipboard
function str_to_mem(str,dest)
 for i=1,#str,2 do
  poke(dest,
   tonum("0x"..sub(str,i,i+1)))
  dest+=1
 end
end
function balltransition()
	for i=0,128,8 do
	for z=0,128,8 do
	add(ballfade,{
		x=i,
		y=z,
		--col=(-(i+z*time())/8),
		--col=0,
		size=fadesize,
		update=function(self)
		self.size=fadesize
		if fadestate then
			if (fadesize<10) fadesize+=fadeadd	
			else
			if (fadesize>-1) fadesize-=fadeadd			
		end
		end,
		draw=function(self)
		circfill(self.x,self.y,self.size,0)
		end
		})
	end
	end
end

function transition()
	if func 
	and trans then
	if (fadesize>10) then
	func()
	func=nil
	trans=false
	fadestate=false
	else
	fadestate=true
	end
end
end

-- px9 decompress

-- x0,y0 where to draw to
-- src   compressed data address
-- vget  read function (x,y)
-- vset  write function (x,y,v)

function
	px9_decomp(x0,y0,src,vget,vset)

	local function vlist_val(l, val)
		-- find position
		for i=1,#l do
			if l[i]==val then
				for j=i,2,-1 do
					l[j]=l[j-1]
				end
				l[1] = val
				return i
			end
		end
	end

	-- bit cache is between 16 and 
	-- 31 bits long with the next
	-- bit always aligned to the
	-- lsb of the fractional part
	local cache,cache_bits=0,0
	function getval(bits)
		if cache_bits<16 then
			-- cache next 16 bits
			cache+=%src>>>16-cache_bits
			cache_bits+=16
			src+=2
		end
		-- clip out the bits we want
		-- and shift to integer bits
		local val=cache<<32-bits>>>16-bits
		-- now shift those bits out
		-- of the cache
		cache=cache>>>bits
		cache_bits-=bits
		return val
	end

	-- get number plus n
	function gnp(n)
		local bits=0
		repeat
			bits+=1
			local vv=getval(bits)
			n+=vv
		until vv<(1<<bits)-1
		return n
	end

	-- header

	local 
		w,h_1,      -- w,h-1
		eb,el,pr,
		x,y,
		splen,
		predict
		=
		gnp"1",gnp"0",
		gnp"1",{},{},
		0,0,
		0
		--,nil

	for i=1,gnp"1" do
		add(el,getval(eb))
	end
	for y=y0,y0+h_1 do
		for x=x0,x0+w-1 do
			splen-=1

			if(splen<1) then
				splen,predict=gnp"1",not predict
			end

			local a=y>y0 and vget(x,y-1) or 0

			-- create vlist if needed
			local l=pr[a]
			if not l then
				l={}
				for e in all(el) do
					add(l,e)
				end
				pr[a]=l
			end

			-- grab index from stream
			-- iff predicted, always 1

			local v=l[predict and 1 or gnp"2"]

			-- update predictions
			vlist_val(l, v)
			vlist_val(el, v)

			-- set
			vset(x,y,v)

			-- advance
			x+=1
			y+=x\w
			x%=w
		end
	end
end

function shake()
if not noshake then
    local shake_x=rnd(intensity) - (intensity /2)
    local shake_y=rnd(intensity) - (intensity /2)
    --offset the camera
    camera( shake_x, shake_y )
    --ease shake and return to normal
    intensity *= .9
    if intensity < .3 then 
        intensity = 0 
    end
end
end

function spawn_enemies()
if time()%levelvalues[level+1].spawntime[diff]==0
and not cutscene then
	for i=0,levelvalues[level+1].spawnammo[diff] do
	rnd({
	add_meteor,
	levelvalues[level+1].toadd
	})()
	end
end
for i=0,2 do
if time()%spawnextras[i+1].spawntime==0
and not cutscene then
	spawnextras[i+1].toadd()
end
end

end

function kill_player()
	add_exp(player.x,player.y)
	gover=true
	player.lifes-=1
	player.x=-32
	player.y=256
	intensity += shake_control
	sfx(43,3)
end

function hcenter(s)
	return 64-#s*2
end

function hcenter8(s)
	return 64-#s*2-(2*#s)
end

--a few extra aditions.. :)
function auto_shoot()
if autoshoot then
autoshoot_display="no"
else
autoshoot_display="yes"
end
autoshoot= not autoshoot
end
function no_shake()
if noshake then
noshake_display="yes"
else
noshake_display="no"
end
noshake= not noshake
end

function loop_object(obj)
		if (obj.x+8<0)	obj.x=128
  if (obj.x>128)	obj.x=0
end

function draw_idk(obj)
pal(7,obj.col)
spr(obj.sp,obj.x,obj.y,1,1,obj.flp)
pal()
end
-->8
--game
function update_game()
if (intensity>0) shake()
player_update()
player_animate()
update_explosions()
update_table(dust,1)
update_gover()
spawn_enemies()
spcshpb:update(spcshpb)
spcshpm:update(spcshpm)
spcshpe:update(spcshpe)
update_table(thr,1)
update_table(enemy,1)
update_table(ball_enemy,1)
update_table(plane_enemy,1)
update_table(ufo_enemy,1)
update_table(meteor,1)
update_table(fuel,1)
update_table(one_up,1)
update_table(diamond,1)
update_table(gold,1)
make_fuel()
update_cutscene()
end



function draw_game()
cls(0)
draw_starfield()
update_table(dust,2)
map(0,0)
if not player.flsh then 
if not drip then
spr(player.sp,player.x,player.y+8,1,1,player.flp)	spr(1,player.x,player.y,1,1,player.flp)
else
spr(player.sp+35,player.x,player.y+8,1,1,player.flp)	spr(1,player.x,player.y,1,1,player.flp)
end
end
update_table(enemy,2)
update_table(ball_enemy,2)
update_table(plane_enemy,2)
update_table(ufo_enemy,2)
update_table(meteor,2)
update_table(thr,2)
draw_explosions()
pal()
drawgeneric(spcshpb)
drawgeneric(spcshpm)
drawgeneric(spcshpe)
update_table(fuel,2)
update_table(one_up,2)
update_table(diamond,2)
update_table(gold,2)
camera()
draw_hud()
if (player.lifes<1)	print("game over!",44,59,8)
end

-->8
--player
function player_update()
if not gover
and not cutscene
then
  --physics
  player.dy+=gravity
  player.dx*=friction

  --controls
  if btn(‹) then
   player.dx-=player.acc
   player.running=true
   player.flp=true
  end
  if btn(‘) then
   player.dx+=player.acc
   player.running=true
   player.flp=false
  end

  --slide
  if player.running
  and not btn(‹)
  and not btn(‘)
  and not player.falling
  and not player.floating then
   player.running=false
   player.sp=17
  end

  --jump
  if btn(—)
  then
  	player.dy=-(player.boost)
  	player.landed=false
  	sfx(44,3)
  	if player.flp then
  		add_new_dust(player.x+6,player.y+10,rnd(2)-1,1,30,rnd(3)+1,0.05,{7,7,7,7,7,7,6,6,6,6,6,5,5,9,9,10,10,10,10,10,8,8,8,8})
  	else
  		add_new_dust(player.x,player.y+10,rnd(2)-1,1,30,rnd(3)+1,0.05,{7,7,7,7,7,7,6,6,6,6,6,5,5,9,9,10,10,10,10,10,8,8,8,8})
			end
  end
  
  if autoshoot then
  autowpn_cooldown+=1
  if autowpn_cooldown>=8 
  and wpn_ammo<4 then
			add_weapon(player.x,player.y,player.flp)
			wpn_ammo+=1
			sfx(45,3)
			autowpn_cooldown=0
		end
		end

		
		if btnp(Ž) 
		then
			if wpn_ammo<4 then
			add_weapon(player.x,player.y,player.flp)
			wpn_ammo+=1
			sfx(45,3)
			end
		end	
		
  
  --check collision up and down
  if player.dy>0 then
    player.falling=true
    player.landed=false
    player.floating=false

    player.dy=limit_speed(player.dy,player.max_dy)

    if collide_map(player,"down",0) then
     player.landed=true
     player.falling=false
     player.floating=false
     player.dy=0
     player.y-=((player.y+player.h+1)%8)-1
    end
  elseif player.dy<0 then
    	player.floating=true
    if collide_map(player,"up",0) then
     player.dy=0
    end
  end

  --check collision left and right
  if player.dx<0 then
    	player.dx=limit_speed(player.dx,player.max_dx)
    if collide_map(player,"left",0) then
     player.dx=0
    end
  elseif player.dx>0 then
    player.dx=limit_speed(player.dx,player.max_dx)

    if collide_map(player,"right",0) then
     player.dx=0
    end
  end

  player.x+=player.dx
  player.y+=player.dy

		--little speed hack
		if player.floating
		and not player.landed
		then
			player.acc=1.5
		else
			player.acc=0.9
		end
		
  --limit player to map
		loop_object(player)
  if (player.y<0)	player.y=0
  if (player.y>104) player.y=104
		
		if player.invc then
			player.tempinvc+=1
			player.flsh= not player.flsh
			if player.tempinvc>=player.invcsc then
				player.invc=false
				player.flsh=false
				player.tempinvc=0
			end
		end
		
end
end

function player_animate()
  if player.floating
  or player.falling then
   player.sp=21
  elseif player.running then
    if time()-player.anim>.05 then
      player.anim=time()
      player.sp+=1
      if player.sp>20 then
       player.sp=17
      end
    end
  else
  	player.sp=17
		end
end
-->8
--weapon object
function add_weapon(x,y,flp)
add(thr,{
	speed=2,
	templast=30,
	sp=5,
	x=x,
	y=y,
	w=8,
	h=8,
	flp=flp,
	anim=0,
 update=function(self)
  self.templast-=1
		if self.flp then
			self.x-=self.speed
		else
			self.x+=self.speed
		end
loop_object(self)
  if self.templast<0 then
    del(thr,self)
    wpn_ammo-=1
	end
	if time()-self.anim>.05 then
   self.anim=time()
   self.sp+=1
   if self.sp>7 then
     self.sp=5
   end
  end
  end,
  draw=function(self)
			pal(7,8+rnd(3))
			spr(self.sp,self.x,self.y+6,1,1,self.flp)
			pal()
  end
  })	
end
-->8
--dynamic hud
function draw_hud()
local plr_offset=16
local y=plr_offset
if not stop_time then
	if seconds>=60 then
		seconds=0
		minutes+=1
	end
	if flr(seconds)>9 then
		zerotimer=""
	else
		zerotimer="0"
	end
	if player.y<plr_offset then
		y=player.y
	end
	seconds+=(1/60)
	showtime=minutes..":"..zerotimer..flr(seconds)
end
--print("\^w\^t"..showtime,52,y-plr_offset+1,7)
print("\014"..showtime,hcenter8(tostr(showtime)),y-plr_offset+2,7)
--spr(16,16,y-plr_offset+2)
print("\014‚\015\|i\-h"..player.lifes,17,y-plr_offset+2,7)
print("score",94,y-plr_offset+2,7)
print(score,hcenter(tostr(score))+40,y-plr_offset+8,7)
end
-->8
--enemy and drops objects
function add_enemy()
add(enemy,{
    sp=8,
    score=15,
    x=rnd({127,-7}),
    y=rnd(112),
    dx=rnd({0.6+rnd(0.1),-(0.6+rnd(0.1))}),
    dy=0.4+rnd(0.1),
    w=8,
    col=rnd({8,11,12}),
    h=8,
    anim=0,
    flp=false,
    update=function(self)
        self.x+=self.dx
        self.y+=self.dy

          if self.y>112 
          or self.y<0
          or collide_map(self,"up",0) 
          or collide_map(self,"down",0) 
          then
            self.dy=-self.dy
          end
          
          if collide_map(self,"left",0)
          or collide_map(self,"right",0)
          then
            self.dx=-self.dx
          end
            
loop_object(self)
        
        if self.dx<0 then
        self.flp=true
        else
        self.flp=false
        end
        
        if time()-self.anim>.2 then
          self.anim=time()
          self.sp+=1
          if self.sp>9 then
            self.sp=8
          end
        end
      if box_hit(self,player)
      and not player.invc 
      then
							kill_player()
      end
			for b in all (thr) do		
      if box_hit(self,b) then
        add_exp(self.x,self.y)
        del(enemy,self)
        del(thr,b)
        sfx(43,3)
        intensity += 1
        wpn_ammo-=1
        score+=self.score
      end
      end
    end,
    draw=function(self)

draw_idk(self)
    end
	})	
end

--meteor enemy
function add_meteor()
add(meteor,{
    sp=10,
    x=-8 or 128,
    y=rnd(112),
    dx=rnd({0.6+rnd(0.2),-(0.6+rnd(0.2))}),
    dy=0.1+rnd(0.2),
    w=8,
    col=8+rnd(5),
    h=8,
    anim=0,
    update=function(self)
        self.x+=self.dx
        self.y+=self.dy
            
loop_object(self)
        
        if self.dx<0 then
        self.flp=true
        else
        self.flp=false
        end
        
        if time()-self.anim>.1 then
          self.anim=time()
          self.sp+=1
          if self.sp>11 then
            self.sp=10
          end
        end
      if box_hit(self,player) 
						and not player.invc
						then
							kill_player()
      end
      
      if collide_map(self,"down",0)
      or self.y>112
      or collide_map(self,"left",0)
      or collide_map(self,"right",0)
      or self.y<0
      or collide_map(self,"up",0) then
      	add_exp(self.x,self.y)
       del(meteor,self)
       sfx(43,3)
       intensity += 1
      end
    end,
    draw=function(self)
draw_idk(self)
    end
	})	
end

function add_ball_enemy()
add(ball_enemy,{
    sp=36,
    score=20,
    x=rnd({127,-7}),
    y=rnd(112),
    dx=rnd({0.4+rnd(0.1),-(0.4+rnd(0.1))}),
    dy=0.3+rnd(0.1),
    w=8,
    col=rnd({8,11,12}),
    h=8,
    anim=0,
    flp=false,
    flptime=5+flr(rnd(2)),
    update=function(self)
        self.x+=self.dx
        self.y+=self.dy
								if t()%self.flptime==0 then
					    self.dx=rnd({0.4+rnd(0.1),-(0.4+rnd(0.1))})
					    self.dy=0.3+rnd(0.1)
								end
          if self.y>112 
          or self.y<0
          or collide_map(self,"up",0) 
          or collide_map(self,"down",0) 
          then
            self.dy=-self.dy
          end
          
          if collide_map(self,"left",0)
          or collide_map(self,"right",0)
          then
            self.dx=-self.dx
          end
            
loop_object(self)
        
        if self.dx<0 then
        self.flp=true
        else
        self.flp=false
        end
        
        if time()-self.anim>.2 then
          self.anim=time()
          self.sp+=1
          if self.sp>37 then
            self.sp=36
          end
        end
      if box_hit(self,player)
      and not player.invc 
      then
							kill_player()
      end
			for b in all (thr) do		
      if box_hit(self,b) then
        add_exp(self.x,self.y)
        del(ball_enemy,self)
        del(thr,b)
        sfx(43,3)
        wpn_ammo-=1
        score+=self.score
        intensity += 1
      end
      end
    end,
    draw=function(self)

draw_idk(self)
    end
	})	
end

function add_plane_enemy()
add(plane_enemy,{
    sp=38,
    score=15,
    x=rnd({127,-7}),
    y=rnd(112),
    acc=0.05,
    dx=rnd({0.2+rnd(0.2),-(0.2+rnd(0.2))}),
    dy=0.2+rnd(0.1),
    w=8,
    col=rnd({6,7,12}),
    h=8,
    anim=0,
    flp=false,
    update=function(self)
        self.x+=self.dx
        self.y+=self.dy
        self.dx*=friction*4.3
        self.dy*=friction*4.5
								self.dx+=self.acc
								
        if self.y>112 
        or self.y<0
        or collide_map(self,"up",0) 
        or collide_map(self,"down",0) 
        then
          self.dy=-self.dy
        end
            
        if player.y>self.y then
        	self.dy+=self.acc
        elseif player.y<self.y then
        	self.dy-=self.acc
        end
        
loop_object(self)
        
        if self.dx<0 then
        self.flp=true
        else
        self.flp=false
        end
      if box_hit(self,player)
      and not player.invc 
      then
							kill_player()
      end
			for b in all (thr) do		
      if box_hit(self,b) then
        add_exp(self.x,self.y)
        del(plane_enemy,self)
        del(thr,b)
        sfx(43,3)
        wpn_ammo-=1
        score+=self.score
        intensity += 1
      end
      end
    end,
    draw=function(self)

draw_idk(self)
    end
	})	
end

function add_ufo_enemy()
add(ufo_enemy,{
    sp=39,
    score=35,
    x=rnd({127,-7}),
    y=rnd(112),
    acc=0.05,
    dx=rnd({0.2+rnd(0.2),-(0.2+rnd(0.2))}),
    dy=0.2+rnd(0.1),
    w=8,
    col=rnd({6,7,12}),
    h=8,
    anim=0,
    flp=false,
    flptime=5+flr(rnd(2)),
    update=function(self)
        self.x+=self.dx
        self.y+=self.dy
        self.dx*=friction*4.5
        self.dy*=friction*4.5
								self.dx+=self.acc

								if t()%self.flptime==0 then
					    self.dx=rnd({0.4+rnd(0.1),-(0.4+rnd(0.1))})
					    self.dy=0.3+rnd(0.1)
								end

        if self.y>112 
        or self.y<0
        or collide_map(self,"up",0) 
        or collide_map(self,"down",0) 
        then
          self.dy=-self.dy
        end
            
        if player.y>self.y then
        	self.dy+=self.acc
        elseif player.y<self.y then
        	self.dy-=self.acc
        end

        
loop_object(self)
        
        if self.dx<0 then
        self.flp=true
        else
        self.flp=false
        end
      if box_hit(self,player)
      and not player.invc 
      then
							kill_player()
      end
			for b in all (thr) do		
      if box_hit(self,b) then
        add_exp(self.x,self.y)
        del(ufo_enemy,self)
        del(thr,b)
        sfx(43,3)
        wpn_ammo-=1
        score+=self.score
        intensity += 1
      end
      end
    end,
    draw=function(self)

draw_idk(self)
    end
	})	
end

function add_1up()
add(one_up,{
	sp=16,
	x=8+rnd(104),
	y=0,
	w=8,
	h=8,
	falling=true,
	update=function(self)
			if self.falling then
				self.y+=fallspeed
				if collide_map(self,"down",0) then
					self.falling=false
				end
			end
			if box_hit(self,player)
			and not self.onplace then
				del(one_up,self)
				player.lifes+=1
				sfx(47,3)
			end
	end,
	draw=function(self)
		spr(self.sp,self.x,self.y)
	end
	})
end

function add_diamond()
add(diamond,{
	sp=23,
	x=8+rnd(104),
	y=0,
	w=8,
	h=8,
	score=40,
	falling=true,
	update=function(self)
			if self.falling then
				self.y+=fallspeed
				if collide_map(self,"down",0) then
					self.falling=false
				end
			end
			if box_hit(self,player)
			and not self.onplace then
				del(diamond,self)
				score+=self.score
				sfx(46,3)
			end
	end,
	draw=function(self)
		pal(7,0+sin(t())*8)
		spr(self.sp,self.x,self.y)
		pal()
	end
	})
end

function add_gold()
add(gold,{
	sp=25,
	x=8+rnd(104),
	y=0,
	w=8,
	h=8,
	score=30,
	falling=true,
	update=function(self)
			if self.falling then
				self.y+=fallspeed
				if collide_map(self,"down",0) then
					self.falling=false
				end
			end
			if box_hit(self,player)
			and not self.onplace then
				del(gold,self)
				score+=self.score
				sfx(46,3)
			end
	end,
	draw=function(self)
		spr(self.sp,self.x,self.y)
	end
	})
end
-->8
--game over
function update_gover()
	if gover then
		if not goverset then
			if player.lifes==0 then
			music(-1)
			music(32)
			stop_time=true
			goverset=true
			score+=minutes*100
			govertemplast=goverlasts*120
			else
			goverset=true
			govertemplast=goverlasts*60
			end
		end
		
		if spcshpm.linked
		and not spcshpm.onplace
		then
		spcshpm.linked=false
		spcshpm.falling=true
		end

		if spcshpe.linked
		and not spcshpe.onplace
		then
		spcshpe.linked=false
		spcshpe.falling=true
		end
		
		for b in all (fuel) do
			if b.linked
			and not b.onplace
			then
			b.linked=false
			b.falling=true
			end
		end
		
		govertemplast-=1
		
		if govertemplast<0 then
			if player.lifes<=0 then
				trans_highscore()				
			else
			player.x=59
			player.y=122
			player.linked=false
			player.invc=true
			gover=false
			govertemplast=0
			goverset=false
			end
		end
	end
end
	
	
-->8
--fuel,spaceships and restarting
function add_fuel()
add(fuel,{
	sp=22,
	x=8+rnd(104),
	y=0,
	w=8,
	h=8,
	onplace=false,
	linked=false,
	falling=true,
	onscreen=true,
	update=function(self)
			if self.linked then
			self.x=player.x+sin(t()+8)*8
			self.y=player.y+8+cos(t()+8)*8
			end
			if self.falling then
				self.y+=fallspeed
				if collide_map(self,"down",0) then
					self.falling=false
				end
					if box_hit(self,spcshpb) then
					self.falling=false
					self.onplace=true
					fuelcounter+=1
					del(fuel,self)
					self.onscreen=false
					end
			end
			if (box_hit(self,player)
			and not self.onplace) 
			and not player.linked then
				player.linked=true
				self.linked=true
			end
				if box_hit(spcshphitbox,player)
			 and not self.onplace
			 and self.linked==true
			 then
			 	self.x=spcshpb.x
					self.falling=true
					self.linked=false
					player.linked=false
				end
	end,
	draw=function(self)
		spr(self.sp,self.x,self.y)
	end
	})
end

function make_fuel()
	if spcshpcounter>=2
	and fuelcounter<3 
	then
		if time()%10==0 then
			add_fuel()
		end
	end
end
function update_cutscene()
	if (box_hit(spcshpb,player)
	or box_hit(spcshpm,player)
	or box_hit(spcshpe,player))
	and fuelcounter>=3
	or spcshpcutscene==true then
		sfx(44,3)
		music(-1,512)
		cutscene=true
		player.x=-32
		player.y=256
		player.flsh=true
		if cutstate==0 then
		spcshpcutscene=true
		if fallspeed<0.5 then
		fallspeed+=0.025
		end
		spcshpb.y-=fallspeed
		spcshpm.y-=fallspeed
		spcshpe.y-=fallspeed
		if not stop_time then
			score+=50
			stop_time=true
			rocket_intensity=0
			fallspeed=0
		end
		rocket_intensity+=0.003
		intensity += rocket_intensity
		if (spcshpm.y<0) fadestate=true
		add_new_dust(spcshpb.x+4,spcshpb.y+6,rnd(2)-1,1,30,rnd(3)+1,0.05,{7,7,7,7,7,7,6,6,6,6,6,5,5,9,9,10,10,10,10,10,8,8,8,8})
		if spcshpb.y<=-16 then
			cutstate+=1
			spcshpb.col=7
			spcshpm.col=7
			spcshpe.col=7
			fallspeed=1
			update_table(enemy,3)
			update_table(ball_enemy,3)
			update_table(plane_enemy,3)
			update_table(ufo_enemy,3)
			update_table(meteor,3)
			update_table(fuel,3)
		end
		end
		if cutstate==1 then
			fadestate=false
			if spcshpb.y>72 then
			if fallspeed>0.5 then
			fallspeed-=0.025
			end
			end
			if not collide_map(spcshpb,"down") then			
			spcshpb.y+=fallspeed
			spcshpm.y+=fallspeed
			spcshpe.y+=fallspeed
			rocket_intensity-=0.0025
			intensity += rocket_intensity
			add_new_dust(spcshpb.x+4,spcshpb.y+6,rnd(2)-1,1,30,rnd(3)+1,0.05,{7,7,7,7,7,7,6,6,6,6,6,5,5,9,9,10,10,10,10,10,8,8,8,8})
			elseif collide_map(spcshpb,"down") then
			music(rnd(ingamemusic))
			stop_time=false
			cutstate=0
			fallspeed=0.5
			sfx(43,3)
			intensity += shake_control
   add_exp(spcshpb.x+4,spcshpb.y)
			manage_level()
			end
		end
	end
end

function restart_game(total)
 player.invc=true
 player.flsh=false
 cutscene=false
	spcshpcutscene=false
	player.x,player.y,fuelcounter=unpack(split"59,100,0")
	if total then
		spcshpm.onplace=false
		spcshpm.linked=false
		spcshpm.falling=false
		spcshpm.pick=false
		spcshpe.onplace=false
		spcshpe.linked=false
		spcshpe.falling=false
		spcshpe.pick=false
		spcshpb.x,spcshpb.y,spcshpb.col,spcshpcounter,spcshpm.x,spcshpm.y,spcshpm.col,spcshpe.x,spcshpe.y,spcshpe.col=unpack(split"80,112,7,0,64,56,7,24,40,7")
	end
end

function update_spcshp(self,spc,fuelcnt,spccnt)
	if not spcshpcutscene then
	 if fuelcounter>=fuelcnt then
	  self.col=14
	 else
	  self.col=7
	 end
	 
	 if (self.y>128) self.y=104
	 
	if spcshpcounter==spccnt then
		if self.linked then
			self.x=player.x+sin(t()+8)*8
			self.y=player.y+8+cos(t()+8)*8
		 if not self.pick then
				self.pick=true
				sfx(46,3)
			end
		end
		if self.falling then
			self.y+=fallspeed
		end
			if box_hit(self,spc)  
			then
				self.falling=false
				self.y=spc.y-8
				self.x=spc.x
				self.onplace=true
				spcshpcounter+=1
			elseif collide_map(self,"down") then
				self.falling=false
			end
		if box_hit(self,player)
		and not self.onplace then
			self.linked=true
		end
		if box_hit(spcshphitbox,player)
		and not self.onplace
		and self.linked==true
		then
				self.x=spc.x
				self.falling=true
				self.linked=false
		end
	end
end
end

function drawgeneric(self)
    pal(7,self.col)
    spr(self.sp,self.x,self.y)
    pal()
end

function manage_level()
	if level%3==0 
	and level!=0
	then
	restart_game(true)
	level=0
	if spcshptype<3 then
	spcshptype+=1
	else
	spcshptype=0
	end
	else
	restart_game()
	level+=1
	end	
	spcshpb.sp=64+spcshptype
	spcshpm.sp=48+spcshptype
	spcshpe.sp=32+spcshptype
end
-->8
--state handling
function change_state(n)
	--0=game
	--1=menu
	--2=credits
	mainnumber=n
end

function _update60()
	if (mainnumber==0) update_game()
	if (mainnumber==1) update_menu()
	if (mainnumber==2) update_credits()
	if (mainnumber==3) update_score()
	if (mainnumber==4) update_full()
	if (mainnumber==5) update_st()
for z in all(ballfade) do
 z:update()
end
transition()
menuitem(1,"autoshoot:"..autoshoot_display, function() auto_shoot() end)
menuitem(2,"shake screen:"..noshake_display, function() no_shake() end)
menuitem(3,"toggle scanlines", function() scanlines=not scanlines end)
menuitem(4,'toggle "drip"', function() drip=not drip end)
end

function _draw()
	if (mainnumber==0) draw_game()
	if (mainnumber==1) draw_menu()
	if (mainnumber==2) draw_credits()
	if (mainnumber==3) draw_score()
	if (mainnumber==4) draw_full()
	if (mainnumber==5) draw_st()
for z in all(ballfade) do
 z:draw()
end
if (scanlines) then 
	fillp(˜\1|0b.011)
	else
	fillp()
end
end
-->8
--credits
function update_credits()
if (btnp(Ž)) menu.is_running=true trans_realtitle() music(0)
end

function draw_credits()
cls(mywob.back_col) 
--pal(0,1)
--scale_text("ultimate",28,14,2,2,12)
--print("original game by",32,0,7)
--print("play the game",32,26,11)
--print("this demake was made by",16,72,7)
--print("coffee bat :)",38,120,7)
--print("BTW PRESS \014Ž\015 TO GO BACK b)",10,116,7)
--print("credits to",16,32,7)
--print("&",24,48,7)
--print("SPECIAL\nTHX TO",8,38)
--print("tv guy",16,88)
--print("blameitontherobot",24,100)
wob_draw(mywob)
print("BTW PRESS \014Ž\015 TO GO BACK b)",10,116,7)
print("credits to",42,0,7)
print("\014&",16,48,7)
--pal()

end
-->8
--title screen
function update_menu()
	menu.update()
	update_table(dust,1)
	if title_parallax>=-1 then
	title_parallax=-8
	else
	title_parallax+=1
	end	
end

function draw_menu()
cls()
menu.draw()
update_table(dust,2)
rectfill(10,9,117,28,13)
scale_text("jetpic-o8",11,12,3,3,8)
scale_text("jetpic-o8",11,10,3,3,12)
drawpattern(14, -4, title_parallax, 4, 120)
drawpattern(12, 124, title_parallax, 128, 120)
drawpattern(3, title_parallax, 120, 136, 128)
print("original game by rare/a.c.g",10,104,7)
print("demake by coffeebat",26,112,7)
print("version:"..gameversion,8,0,8)
print("highest score:",hcenter("highest score:"),32,8)
print("\014"..highest_score,hcenter8(tostr(highest_score)),38,8)
if (yousure) print("are you sure? †.†",30,56,8)
if not drip then
spr(21,18,48+(sin(t()+8))*4+8,1,1)
spr(1,18,48+(sin(t()+8))*4,1,1)
else
spr(21+35,18,48+(sin(t()+8))*4+8,1,1)
spr(1,18,48+(sin(t()+8))*4,1,1)
end
add_new_dust(18,48+(sin(t()+6))*4+10,rnd(2)-1,1,30,rnd(3)+1,0.05,{7,7,7,7,7,7,6,6,6,6,6,5,5,9,9,10,10,10,10,10,8,8,8,8})
end

function start_submenu()
menu.is_running=true
menu.entries=menu_play
end

function reset_menu()
menu.is_running=true
menu.pos=0
yousure=false
menu.entries=menu_main
end

function start_game_easy()
	func=start_gamereal
	diff=1	
	trans=true
end

function start_game_hard()
	func=start_gamereal
	diff=2
	trans=true
end

function show_credits()
	func=show_creditsreal
	trans=true
end

function start_gamereal()
	music(rnd(ingamemusic))
	change_state(0)
	ingametimer=time()
end

function show_creditsreal()
	music(24)
	change_state(2)
end

function trans_highscore()
	func=goto_highscore
	trans=true
end

function	goto_highscore()
	change_state(3)
	music(-1)
	music(24)
end

function restart_trans()
	func=_init
	trans=true
end

function ask_data()
yousure=true
menu.is_running=true
menu.pos=1
menu.entries=menu_askdata
end

function trans_st()
	func=goto_st
	trans=true
	menu.is_running=true
end

function	goto_st()
	cursor(8,64)
	menu.start()
	change_state(5)
	music(-1,512)
end
-->8
--high score screen
function update_score()
	highscoretext.x-=1
	highscoretext.endcorner=384
	toread=tostr(highscoretexts[highscoretext.counter].t)
	toread2=tostr(highscoretexts[highscoretext.counter+1].t)
	if highscoretext.x+highscoretext.endcorner<0 then
	if highscoretext.counter<7 then
	highscoretext.counter+=1
	highscoretext.x=0
	elseif highscoretext.x+highscoretext.endcorner<(-32*4*3) then
	highscoretext.counter=1
	highscoretext.x=128
	end
	end
	display_highestscore=tostr("highest score:"..highest_score)
	if (btnp(Ž)) restart_trans()
	if (score>highest_score)	highest_score=score	newhigh=true
	dset(0,highest_score)
end

function draw_score()
	cls()
	map(16,0)
	spr(19,4*8,48,1,1,0)
	spr(1,4*8,40,1,1,0)
	spr(19,11*8,48,1,1)
	spr(1,11*8,40,1,1)
	pal(7,0+sin(t())*8)
	if newhigh then
	print("new high score!",36,32,7)
	end
	print("jetpic-o8",46,40,7)
	print("high score",44,48,7)
	pal()
	print("congratulations!",32,64)
	print("your score is",38,70)
	--add the text autocenter function...
	print("\014"..score,hcenter8(tostr(score)),78)
	print(display_highestscore,hcenter(tostr(display_highestscore)),97)
	--ye here...
	print("press \-e\014\|fŽ\015\|h/z to go back \-e\014\|fŒ\015",19,118)
	scale_text(toread,highscoretext.x,highscoretext.y,3,3,8)
	scale_text(toread2,highscoretext.x+highscoretext.endcorner,highscoretext.y,3,3,8)
end
-->8
--fullscreen title
function update_full()
	introtime.init+=1
	if introtime.init>introtime.lasts 
	or btnp(—) then
		trans_realtitle()
	end
end

function draw_full()
end

function trans_realtitle()	
	trans=true
	func=goto_realt
end

function	goto_realt()
	change_state(1)
	menu.entries=menu_main
	menu.pos=1
	cursor(39,64)
	menu.start()
end
-->8
--misc tables
levelvalues={
{
	toadd=add_enemy,
	spawntime={15,6},
	spawnammo={0,1},
},
{
	toadd=add_ball_enemy,
	spawntime={15,5},
	spawnammo={1,3},
},
{
	toadd=add_plane_enemy,
	spawntime={10,5},
	spawnammo={1,3},
},
{
	toadd=add_ufo_enemy,
	spawntime={8,3},
	spawnammo={0,2},
}
}

spawnextras={
--1up
{
spawntime=180+flr(rnd(30)),
toadd=add_1up,
},
--diamond
{
spawntime=60+flr(rnd(30)),
toadd=add_diamond,
},
--gold
{
spawntime=40+flr(rnd(30)),
toadd=add_gold,
}
}

-->8
--sound test menu
function update_st()
	cursor(24,64)
	menu.entries=menu_st
	menu.update()
end

function draw_st()
	cls(1)
	menu.draw()
	print("\014\fasound\n	test",44,6)
	spr(133,32,24,8,4,false)
	spr(144,80,64,5,4)
end

function trans_realtitle1()
menu.entries=menu_main
menu.is_running=true
trans_realtitle()
end

function p_song(s)
music(-1)
music(s)
menu.is_running=true
end

function p_titlesong()
p_song(0)
end

function p_highsong()
p_song(24)
end

function p_ingame1song()
p_song(8)
end

function p_ingame2song()
p_song(16)
end

function p_ingame3song()
p_song(40)
end

function p_gosong()
p_song(32)
end
__gfx__
000000000077770000a0aaaaa0aaaa0a0a00aa000000000000000000000000000007007007007000000777000077770000b0bbbbb0bbbb0b0b00bb0000000000
07000070067711000aaaaaaaaaaaaaaaaaaaaaa0007777707777077077707770007777000077770070777070077770700bbbbbbbbbbbbbbbbbbbbbb000000000
0070070006717770aaaaaa9aaaaa9aaaaaaaaaaa07770777070777770707077707777777777777700777707770777077bbbbbb3bbbbb3bbbbbbbbbbb00000000
0007700006771770aaaaa90aaaa909aa99aaaaa977777777777777777777777777707070077070777077770707777707bbbbb30bbbb303bb33bbbbb300000000
00077000667777709aaa909aaa90a09aaaaaaaa9770077777777077700707777077070777770707007777707707777073bbb303bbb30b03bbbbbbbb300000000
00700700656777000aaa909aa909aa0aa99aaa900077077007077770777777707777777007777777707770770777707703bb303bb30bbb03b33bbb3000000000
070000706500000009a9000a90909a099009a9000000000000000000000000000077770007777770077770707077707003b3000b30303b033003b30000000000
00000000657770000090000900000900000090000000000000000000000000000707007070007000707777000777770000300003000003000000300000000000
0007700065717170657171706571717065717170657171700ee00ee0007777000000000000000000000770000777777000bbbbb000aaaaa000b0bbbb0b00bb00
007007005671177756711777567117775671177756711777eeeeeeee0777777000000000000000000007700070000007030bbb00090aaa000bbbbbbbbbbbbbb0
007777006577770065777700657777006577770065777700ee2222ee707777070077770000aaaa000070070070077007003bbb30009aaa90bbb3bb3bbbbbbbbb
077777706607770066077700660777006607770066077770ee2eeeee70700707070077700aaaa9a0007007007007700700bb0b0000aa0900bb30b30b33bbb3bb
070770700607700006077000060770000607700006000770ee2222ee0700007070777777aa997aaa070000700700007000bb003000aa00903b0b303bbbbb303b
007777000000000000000000660000000000000000000777ee2eeeee0777777077777777a99999aa0700007070077007003b3300009a99000b3b303bbbb30b0b
007777000007700006607700666007700660770000000000eeeeeeee0077770077777777a99999aa7777777770000007000b0b00000a0a000bbbb3bb3bb0bbbb
0770077000077700066677700660077706667770000000000ee00ee00007700007777770aaaaaaa0770000770777777000bb0bb000aa0aa00bbbbbbb0bbbbbb0
000770000007770000077000000770000077770000000000000000000000000000000000000000000000000000000000000000000000000000a0aaaa0a00aa00
00077000007777700007700000077000070077700077770077700000000770000000000000000000000000000000000000000000000000000aaaaaaaaaaaaaa0
0007700000777070000700000077770070077777070777700777770000777700000000000000000000000000000000000000000000000000aaa9aa9aaaaaaaaa
0077770007777070007777000070070070777777700777777077707077777777000000000000000000000000000000000000000000000000aa90a90a99aaa9aa
00777700077770700077770000700700777777777777777777777777070770700000000000000000000000000000000000000000000000009a0a909aaaaa909a
00707700070070700077770000700700777777770777777000770000777777770000000000000000000000000000000000000000000000000a9a909aaaa90a0a
07700070077770700070000007700770077777700077770007777770077777700000000000000000000000000000000000000000000000000aaaa9aa9aa0aaaa
07700070070070700707777007000070007777000000000000000000000000000000000000000000000000000000000000000000000000000aaaaaaa0aaaaaa0
07700070077770700777777007077070657171706571717065717170657171706571717000000000000000000000000000000000000000000000000000000000
07707770070770707707070707777770567117775671177756711777567117775671177700000000000000000000000000000000000000000000000000000000
07707770070770707070707707777770657777006577770065777700657777006577770000000000000000000000000000000000000000000000000000000000
77707777070770707777777770777707660777006607770066077700660777006607777000000000000000000000000000000000000000000000000000000000
7770777707077070700707777077770706077000060770000607700006077000060008c000000000000000000000000000000000000000000000000000000000
77707777077070707007077770777707000000000000000022000000000000000000088800000000000000000000000000000000000000000000000000000000
777077770707707070070777770770770008c00002d08c0022d008c002d08c000000000000000000000000000000000000000000000000000000000000000000
77707777070770707777777777077077000888000222888002200888022288800000000000000000000000000000000000000000000000000000000000000000
77707777070770700707070777077077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77707777077777707777777777077077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77707777777777707007077777077077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77707777777777777777777777077077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07707770777770070700007077077077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77077077777770777770077770777707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000770000000000000070707707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77000077700077777770077770000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffff0ffffff0db14b950fc9633cffff7101effff312cffffffffb308cf0c8f81f303e56491f25e4e1a45ee9cef00f28f50cf00e10f301e66c7cf2cfff7b0f7
0879f38f98f18f98f58f8f58f72cfffff248b9f18ff308fff33c823e70ef5ab0ffff72c148f168f16832490f3c0ff746cff52487858f32487858ff5185823eff
00e32cf30e32cff58368fff3f1e90fff7382ff3d0758fff7127481fffff30348fff72148b22f30b4cffc1cffb602f48fb21fffe2cfffb7a80ffb5dfd0fc10e9f
3000746f940c3f103fc7404e1093b07c7089b1043f31fbd663d321ff73dfff341bf8fff7349fff3f698c180f3002f1ffffc3c91efff87873cfffb81e1efff648
25ef781e80ffff38681ff74e8070fff73680fffd0d0f13e4ef6efff41fd01ea8cf09833c2cfff5b1e3e72e3a3cb43cff82cf0107390f3f0f0f1f1715e1acb491
f25e4e1acfffffb85c1fffffffef1effff3120effffb08ffffffff74ae9b932cf897cfff73973c348fd8ffff6108311090f3948fffb643c2461e12cf025efff7
d2c200811a48b5e0efff6940468b01070f752efff4530c13809012123c52f8c870cfff1b4024340c12813c0d10f348fffb127101480852068b2c0cf31ef7c191
24e0087601216c7b02809010721ef7c1093208001e60779813001202348ffb3311001024832cf120c87680108ff372a102434280727394c80e10a48fd2cff34a
4040428123cb0e7a50480fd08f72cf423e06c04048b000f30f38800123c01e7c0f352082b0d081f19001a140cf51e11cfb140cf022c8010d2c7c18123c8c08f8
49841401a1610720c1c9148d280760483b0280b0908f8a4e000812ca0f5049f121108bf008f38c08e084835e00242420e81e30758f12c20280768274203e02c8
721f01e0c10c083014004803e4905ac140c043413c5124315e2e830ea94c7bc3f4893f8ceab134a3c342c20a4280836850c7c5e9f38ceabc1e26dde83d2000c3
af19105ea1c08b60c750cf04378403e8a3f16e90c357d3ea4e19b0024681200817700e80902cd484e2148ffd011268681f4082468293042cd0e73902cff76878
5260a42028161483242460c2cf7318fff8c840c11210717036c04e001ea0fb40311eff432211e00805e8070f41200fc010f9f8b44e9cc0c1400016411a6721ef
0e0258068730ef09571312eb6c778f2cc782c75f9bc700e0092cdc20a700148504807bfe8121eff42727d071905060c040413cf42e512060e024e102020ea022
f723c0812480320a0e1948c074e216ea1d9be222c117179582f71f3487682249001e9d5c55085e32cce988c12c38c110ab46703e0e1e90f1908200083871144c
1116c112120e80b070288c8f1872c3c2c14340cf8337ccc6822481f090d1b0f71fb0368080340d2e7915023592c11a58f343cff724781f180961fb0f0d238170
2c13c232c5cff12c2c8f8958f92c799110908b8171f562c142cd0c05216c203268f78b4e31a81d0124284379d4a10f2b090808170b13c61efbc48ba050002021
e9ccdc048384809070860566148b33758230560610ff8108ba01a49501ed8574243faf780945903e781e2d08580b02c1c182c1c2408351025f6ae400c5007f0f
06aac822c8b87803212556700a8f31c5c3a873c31d081f3e0801ac8869e4a908ffbbd91e7a087886846ea074033fff734271301e1068484048891c016c66c0ff
3fc02c534680b091ea2332807090913cffdd0f3c304960c58a10cf0703484e0ff76d39680b0702c9ab08f1601542cffb333a0a43c2cf1c0c3040b1fc4dffb161
24801acfc68f78d8a43fff6d16805e7f613e78a6419aff5f453c112cfdd2012582411efff38d706cfd4c6c0f0080635cffe9388e1cfc5541081186b4cffc76e0
2c3cfdc58d05840c6aef7e331ac148f5b580736010fff714e00b080f7b812300e00bd02ff7766321010fb76e1ac8674efff2cc48c020e7e8d809249834c8cfff
788d38070fbace803b08d12c8cfff11bf681f766490c851854efff5090766c0f325618d2bc109fffb0685878401e7e522340c7cffd5efd0f3339c08f8ffd3f68
b20ef7002061482ff77ec98781ff30626080010ff3f4480107401ef73040701acffdb84815acff902b0058fff708848f8ffd9cbcfff30e0210fffc0d2cffff0c
40effa980ffff5622cff5958fff72cffffff71300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000777777700000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000007555555577000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000075ddddddd55700000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000075dd555555dd570000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000075dd57777775dd57000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000075dd5700000075dd5700000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000075d57000000075aad570000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000075d57000000075aaa957000000000000000000000000000000000000000000000000000000000000000000
00000000000777700000000000007700000000000075d570000000075aa957000000000000000000000000000000000000000000000000000000000000000000
00000000007555570000000000075570000000000075d57000000000759257000000000000000000000000000070000000000000000000000000000000000000
00000000075aaaa5700000000075bb57000000000075d57000000000075270000000000000000000000000000757777000000000000000000000000000000000
00000000075a55a5700000000075b5b5700000000075d57770000000007270000000000000000000077770007585555700000000000000000000000000000000
00000000075a55a5700000000075b5570000000000075d5557000000007270000000000000000077722557775888577570000000000000000000000000000000
0000000075aa5aa570777700075bb5700000000000075ddaa5700000007270000000000000077722275d5555558aa57757000000000000000000000000000000
0000000075aa5aa577555577775bb57777700000000075daa57000000007270000000000777222777755d752855aab5757000000000000000000000000000000
000000770755755555dddd5557755775555700000000075daa570000000727770000777722277700007575228855bbb557000000000000000000000000000000
000007557077755ddd5555ddd557775cccc5700000000075995700000007722277772222777000000075522885555bbc57000000000000000000000000000000
0000758857075dd5555555555dd5775c55c57000000000752570000007722777222277770000000000755288558885ccc5700000000000000000000000000000
000075858575d55577777777555d575c55c570000000000772770007722770007777000000000000000758885888885c88570000000000000000000000000000
000075855775d57777777777775d55cc5cc570000000000007227772277000000000000000000000000075558855788588a57000000000000000000000000000
00075885775d5677777777777765d5cc5cc57000000000000077222770000000000000000000000000000755885567885aaa5700000000000000000000000000
00075885775d5677777777777765d555755700000000000000007770000000000000000000000000000000758876667885aa5700000000000000000000000000
00007557075a5677555555557765a577077000000000000000000000000000000000000000000000000000075887655888557000000000000000000000000000
0000077075aa6775555555555776aa57000000000000000000000000000000000000000000000000000000007588755885570000000000000000000000000000
0000000075aa6775555555775776aa57000000000000000000000000000000000000000000000000000000000758888855700000000000000000000000000000
0000000075aa6755555555575576aa57000000000000000000000000000000000000000000000000000000000075888557000000000000000000000000000000
0000000075aa6755555555555576aa57000000000000000000000000000000000000000000000000000000000007585570000000000000000000000000000000
0000000075aa6755555555555576aa57000000000000000000000000000000000000000000000000000000000000755700000000000000000000000000000000
0000000075aa6775555555555776aa57000000000000000000000000000000000000000000000000000000000000077000000000000000000000000000000000
00000000759a5675555555555765a957000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000075956777555555777659570000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000007556777777777777655700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000775777777777777577000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000007557777777755700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000775555555577000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000007777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
0000010101000000000000000101010000000000000000000000000000000101000000000000000000000000000001010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000c0d0d0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000c0d0e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000001e0d0d0d0d0d0d0d0d0d0d1f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000c0d0e00000000000000001c000000000000000000001c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000001c000000000000000000001c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000001c000000000000000000001c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000c0d0d0d0d0d0d0d0d0d0d0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000002e0303030303030303030303032f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000001d0000000000000000000000001d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02030303030303030303030303030304001d0000000000000000000000001d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
010800001f65307353070500703007020070101f653073531f6531335313050130201d6530535305050050201f65307353070500703007020070101f653073531f653133531f653133531f653133531f65313353
290800000735007350073300733007320073200731007312073100731207310073120731007312073100731207310073120731007312073500735007330073200c3500c3500c3300c32005350053500533005320
290800000532005322053200532205320053220532005322053200532205320053220532005322053200532203350033500335003350033500335003330033200535005350053500535005350053500533005320
0908000013250162501a2501f2501a23016220132101321013250162501a2501f2501a23016220132101321013250162501a2501f2501a23016220132101321013250162501a2501f2501a230162201321013210
19080000297502a7512b7512b7502b7522b7502b7522b750297502975029750297502675026750267502675024750247502675026750297502975024750257512675126750267502675024750247502275022750
09080000162501a2501d250222501d2301a2201621016210162501a2501d250222501d2301a2201621016210182501c2501f250242501f2301c2201821018210182501c2501f250242501f2301c2201821018210
1908000022750227512275122720227522275022752227202e7502f7513075130750307502e7502d7502b7503275032750327503275032750327503075030751307513075030750307502e7502e7502e7502e750
19080000307503175132751327503275032750327303272035750357503575035750327503275032750327502e7502e7502d7502d7502e7502e750297512a7512b7512b7502b7502b75029751297502975029750
190800002475024751247512475024750247502473024720257502575025750257502575025750257502575026750267502675026750267502675026751267512b7512b7502b7502b75029751297502975029750
050600000915009150092320922209150091500903209022092500925009132091220905009050092320922205150051500523205222051500515005032050220725007250070320702207150071500723207222
0506000021653093530905009030216530935309050090302d653153531505015030216530935309050090301865300353000500003018653003530005000030266530e3530e0500e0301a653023530205002030
010600002105021050240102401024050240502103021030280502802024030240102405024020280302801021050210202401024010260502602021030210102805028020260302601026050260202803028010
090600001f25020251212512125021240212402124021240232502325021240212402425024250232402324026250262502424024240282502825026240262402425024250282402824023250232502324023240
090600002325024251242502425024250242502425024250212502125024240242401c2501c25021240212401f2501f2501c2401c24021250212501f2401f240232502325021240212401f2501f2502324023240
050600000515005150052320522205150051500503205022052500525005132051220505005050052320522207150071500723207222071500715007032070220725007250070320702207150071500723207222
090600001a2501c2511d2511d2501d2501d2501d2501d2501f2501f2501d2401d24021250212501f2401f24024250242502124021240242502425024240242402825028250242402424028250242512325122251
050700001a6530e35302350023303e6251a6233e6251a623326531a3530e3500e3303e6251a6233e6251a6231a6530235302350023303e6251a6233e6251a623326531a3530e3500e330326531a3530e3500e330
090700001a2571d25721237262271a2571d25721237262271a2571d25721237262272125726237212572623726217262172621726217182571c2571f23724227182571c2571f23724227182571c2571f23724227
09070000212502125021230212221f2501f2501f2301f2201d2501d2501d2301d2221f2501f230212502125021250212502123021222242512425024250242502425024250242502425024250242502423024222
09070000262502625021250212501d2501d2301d2501d2501d2501d2501c2501c2501a2501a2501d2501d2501a2501a2501a2301a2201a2201a2201a2201a2202125023251242512425024250242502425024250
0507000023653173530b3500b3303f625236233f625236233b6532335317350173303f625236233f6252362323653173530b3500b3303f625236233f625236233b6532335317350173303b655236231765517623
090700001a2571f25723237262271a2571f25723237262271a2571f25723237262272323726227232372622726217262172621726217182571c2571f23724227182571c2571f23724227182571c2571f23724227
090700002325023250232502325023250232502325023250232502325023230232201f2501f2501f2501f2501f2501f2501f2501f2501f2501f2501f2301f2202125021250212502125021250212502123021220
090700001d2501d2501d2501d2501d2501d2501d2301d2201d2501d2501d2301d2201f2501f2501f2501f2501f2501f2501f2501f2501f2501f2501f2301f2201d2501d2501d2501d2501d2501d2501d2301d220
090700001a350183401d2501a240213501d340212502625026350283402425028240213502434021250182501a350183401d2501a240213501d34021250262502635028340242502824021350243402125018250
090700001a350263401f2501a240233501f340262502325026250262402335026340232401a3501f3401a3501a350263401f2501a240233501f340262502325026250262402335026340232401a3501f3401a350
010c00001a3761f3261a3761f3261a3761f3201f3101f3101a3761f3261f3101f3101a3761f3201a3762135621310213101a3762132621310213101a376213261a3761f3261f3101f3101a3761f3261f3101f310
010c00001a3121a3101a3121a3101a3121a3101a3221a3201a3201a3201a3301a3301a3301a3301a3401a3401a3521a3521a3401a3401a3301a3301a3201a3201a3121a3101a3121a3101a3121a3101a3121a310
010c00001731217310173121731017312173101732217320173201732017330173301733017330173401734017352173521734017340173301733017320173201731217310173121731017312173101731217310
010c00001a3761e3261a3761e3261a3761e3261e3101e3101a3761e3261e3101e3101a3761e3261a3761e3261e3101e3101a3761e3261e3101e3101a3761e3261a3761e3261e3101e3101a3761e3261e3101e310
010c00001a3121a3121a3121a3121a3121a3121a3121a3121a3121a3121a3121a3121a3121a3121a3121a3121a3121a3121a3121a3121a3121a3121a3121a3121a3121a3121a3121a3121a3121a3121a3121a312
010c00001731217312173121731217312173121731217312173121731217312173121731217312173121731217312173121731217312173121731217312173121731217312173121731217312173121731217312
010c00001031210310103121031010312103101032210320103201032010330103301033010330103401034010352103521034010340103301033010320103201031210310103121031010312103101031210310
010c00001031210312103121031210312103121031210312103121031210312103121031210312103121031210312103121031210312103121031210312103121031210312103121031210312103121031210312
010c00001f3121f3101f3121f3101f3121f3101f3221f3201f3201f3201f3301f3301f3301f3301f3401f3401f3521f3521f3401f3401f3301f3301f3201f3201f3121f3101f3121f3101f3121f3101f3121f310
010c00001831218310183121831018312183101832218320183201832018330183301833018330183401834018352183521834018340183301833018320183201831218310183121831018312183101831218310
010c00001f3121f3121f3121f3121f3121f3121f3121f3121f3121f3121f3121f3121f3121f3121f3121f3121f3121f3121f3121f3121f3121f3121f3121f3121f3121f3121f3121f3121f3121f3121f3121f312
010c00001831218312183121831218312183121831218312183121831218312183121831218312183121831218312183121831218312183121831218312183121831218312183121831218312183121831218312
010c00002131221310213122131021312213102132221320213202132021330213302133021330213402134021352213522134021340213302133021320213202131221310213122131021312213102131221310
010c00002131221312213122131221312213122131221312213122131221312213122131221312213122131221312213122131221312213122131221312213122131221312213122131221312213122131221312
050a00001a6530235302050020301a653023531a6530235302050020301a653023531a653023530205002030266530e3530203002030020300203002030020300203002030020300203002030020300202002010
090a00002125021250222512225021251212501f2501f2501d2501d2501d2501d2501c2501c2501c2501c2501a2501a2521a2501a2501a2501a2521a2501a2501a2501a2521a2501a2501a2301a2321a2201a210
1d0a00001d7502175024730217101d7502175024730217101c7502175024730217101c7502175024730217101a7501d7502173024710217501a7501d730217102471021710217102171021710217102171021710
110100001c3701a6701837017670153701367011370106700e3700c6700b370096700737005670043700267000340006400034000640003300063000330006300032000620003200062000310006100031000310
0b01000024652246522465224652246522465224652246522465224652246522465224652246522465224652246003060030600306001860018600186000c6000c6000c6000c6000c6000c6000c6000c6000c600
090100001d4721c4721b4721a472194721847217472164721544214442134321243211422104220f4220e42200000000000000000000000000000000000000000000000000000000000000000000000000000000
190808091d770297701d7102971029710000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
090400002275022740267502273029740267302e740297302e740297302e720297202e71000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
050c0000170561a0561f0561a056170561a0561f0561a056170561a0561f0561a056170561a0561f0561a0561a0561e056210561e0561a0561e056210561e0561a0561e056210561e0561a0561e056210561e056
090c00002b2102b2101f2501f2321f2501f2301a2501a2321f2501f2321a2501a2301f2501f232212502123021210212102125023251232302322023210232122321023212232102321223210232122325023230
050c0000286530732028653133203b6333b6131335313320286530732028653133203b6333b61313353133202865302320286530e3203b6333b6130e3530e3202865302320286530e3203b6333b6130e3530e320
050c00001c0561f056230561f0561c0561f056230561f0561a0561e056210561e0561a0561e056210561e056180561c0561f0561c056180561c0561f0561c0561a0561e056210561e0561a0561e056210561e056
090c00002425024250242302422024210242102425024230232502323021250212302325023230242502425024230242202525026251262502625026230262202425024250242302422023250232502323023220
050c0000286530432028653103203b6333b61310353103202865302320286530e3203b6333b6130e3530e3202865300320286530c3203b6333b6130c3530c3202865302320286530e3203b6333b6130e3530e320
090c0000242502425024230242202421024210242502423023250232302125021230232502323024250242502423024220252502625126230262202425024230232502323021250212301f2501f2302125021230
050c0000180561c0561f0561c056180561c0561f0561c056180561c0561f0561c056180561c0561f0561c0561a0561e056210561e0561a0561e056210561e0561a0561e056210561e0561a0561e056210561e056
090c00001f2101f2101f2101f2101f2101f2101f2101f210242502425026251262502425024250232502325023230232302322023220232122321223212232122425024250262512625024250242502b2502b250
050c00002865307320073120731207312073122865307320286530732007310073103b6333b61317610176102865309320093120931209312093122865309320286530932009310093103b6333b6131761017610
090c00002b2302b22228250282502823028220282502823026250262302622026210262502623026220262102325023230242502423023250232301f2501f2302125021230232502323021250212301f2501f230
050c0000286530b3200b3120b3123b6333b613286530b320286530932009310093103b6333b6132865309320286530732007312073123b6333b6132865307320286530932009310093103b6333b6132865309320
080c00002b2302b2222825028250282302822028250282302625026230262202621026250262302622026210232502323024250242302325023230242502423026250262302b2502b2302d2502d2302b2502b230
011000003075030725337503372535750357253675036725357503572533750337253075030750307303073030720307102e75532755307503075030730307303072030710307103071030710307103071030710
010800001a2501a2551a2501a25526250262502625026255212502125021250212502125021255202502025020250202551f2501f2501f2501f2551d2501d2501d2501d2551a2501a2551d2501d2551f2501f255
011000003175031750317503173031720317103375033750337503373033720337102c7502c7302c7202c71033750337503375033730337203371035750357503575035730357203571038750367503575033750
__music__
00 41 00 43 01
00 41 00 43 02
00 41 00 43 01
00 41 00 43 02
01 03 00 04 01
00 05 00 06 02
00 03 00 07 01
02 05 00 08 02
00 09 0a 43 44
00 09 0a 43 44
01 09 0a 0b 44
00 09 0a 0b 44
00 09 0a 0c 44
00 09 0a 0c 44
00 09 0a 0d 44
02 0e 0a 0f 44
01 10 11 12 44
00 10 11 13 44
00 14 15 16 44
00 14 15 17 44
00 10 11 18 44
00 10 11 18 44
00 14 15 19 44
02 14 15 19 44
01 1a 1b 1c 44
00 1d 1e 1f 44
00 1a 20 1c 44
00 1d 21 1f 44
00 1a 22 23 44
00 1d 24 25 44
00 1a 26 1b 44
02 1d 27 1e 44
00 28 29 2a 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
01 30 31 32 44
00 33 34 35 44
00 30 31 32 44
00 33 36 35 44
00 37 38 39 44
00 33 3a 3b 44
00 37 38 39 44
02 33 3c 3b 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
