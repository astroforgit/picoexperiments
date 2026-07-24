pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- alfredo's stupendous surprise  (bandersnatch edition)
-- by paul nicholas

-- a remake of "alfredo's stupendous surprise"
-- by tom hall & john romero
-- (from softdisk #98, 1989)

_t=0

-- fields
screens = {
 title=0, house_start=1, space=2, sign=3, land=4, jump=5, jump_death=5.5, stairs=6, 
 cliff=7, shredder=8, drink=9, fire=10, switch=11, cellar=12, pendulum=13,
 house_end=14, final=15
}
messages={}

function _init()
 ninjoe = create_player()
 change_screen(screens.title)
 --change_screen(screens.house_start) 
 --change_screen(screens.space)
 --change_screen(screens.sign)
 --change_screen(screens.land)
 --change_screen(screens.jump)
 --change_screen(screens.jump_death)
 --change_screen(screens.stairs)
 --change_screen(screens.cliff) 
 --ninjoe.safe=true
 --change_screen(screens.shredder)
 --change_screen(screens.drink)
 --ninjoe.drink = 2
 --change_screen(screens.fire)
 --change_screen(screens.switch)
 --change_screen(screens.cellar)
 --change_screen(screens.pendulum)
 --change_screen(screens.house_end)
end

function init_screen(screen) 
 if screen == screens.title then
  ninjoe = create_player()
  ninjoe.puzzled=true
  music(33)

 elseif screen == screens.house_start then  
  music(-1)
  ninjoe.puzzled=false
  ninjoe.x=-8
  ninjoe.cor = cocreate(function(self)   
   self:set_anim("walk")
   for i=1,100 do
    circfill(i,50,4,8)
    flip()
   end
   move_to(self,self.x+30,self.y,.25)
   self:set_anim("idle")
   wait(50)
   self:set_anim("cheer")
   self:set_message("a BIRTHDAY CAKE!",self.x-20,self.y-20,12)
   wait(100)
   self:set_message("a BIRTHDAY CAKE!\nhOW NICE.",self.x-20,self.y-20,12)
   wait(100)
   self:set_anim("idle")
   self:set_message("i THINK I'LL GO BLOW\nOUT THE CANDLES.",self.x-20,self.y-20,12)
   wait(150)
   self:clear_message()
   self:set_anim("walk")
   move_to(self,self.x+5,self.y,.25)
   baby_cake:set_message("       /\nhELP, MOMMY!",baby_cake.x-40,baby_cake.y+25,14)
   self:set_anim("walk")
   move_to(self,self.x+20,self.y,.25)
   move_to(momma_cake,0,momma_cake.y,4)
   baby_cake:clear_message()
   self.flipx = true
   self:set_anim("idle")
   momma_cake:set_message("sTOP RIGHT THERE,\nBUSTER!\n  /",momma_cake.x+20,momma_cake.y-20,14)
   wait(150)
   momma_cake:clear_message()
   self:set_message("bUT I WAS JUST GOING\nTO BLOW OUT THE\nCANDLES.\n    /",self.x-5,self.y-38,12)
   wait(150)
   self:clear_message()
   wait(50)
   momma_cake:set_message("i'LL BLOW you OUT!\n  /",momma_cake.x+20,momma_cake.y-13,14)
   wait(150)
   momma_cake:clear_message()
   momma_cake.blow=true
   sfx(17)
   self:set_anim("fast_roll")
   move_to(self,130,-10,2)
   change_screen(screens.space)
  end)
 -- house (real)
 house = m_obj(80,48)
 house.draw = draw_house
 house.cor = cocreate(function(self)
  -- do nothing (for now)
 end)
 -- baby cake
 baby_cake = m_msg_obj(120,66)
 -- mommy cake
 momma_cake = m_map_obj(-32,48, 48,16, 4,4)
 momma_cake.draw=function(self)
  pal(6,14)
  self:_draw()
  pal()
  rectfill(self.x+4,self.y+20,self.x+27,self.y+27,7)
  --
  line(self.x+26, self.y+18, self.x+29, self.y+19, 0)
  rectfill(self.x+27, self.y+21, self.x+29, self.y+23, 0)
  print("-",self.x+29, self.y+25,0)
  for i=0,3 do
   spr(71+rnd(2),self.x+i*8,self.y+1)
  end
  -- blowing?
  if self.blow then
   print("è",self.x+28, self.y+25,0)
   spr(34+rnd(2), self.x+32+rnd(4), self.y+25+rnd(4)-2)
  end
 end

 elseif screen == screens.space then
  printh("screen == screens.space")  
  dot = m_msg_obj(80,75)  
  dot.draw=function(self)
   self:_draw()
   if self.moving then 
    zspr(_t%10<5 and 133 or 149, 1,1, self.x,self.y, 0.5)
   else
    zspr(149, 1,1, self.x,self.y, 0.5)
   end
  end
  dot.cor = cocreate(function(self)
   self:set_message("yIPES!",self.x-20,self.y-20,12)
   wait(150)
   self:clear_message()
   -- "jump"
   sfx(17)
   self.moving=true
   do_jump(self,1.0,-1.5,self.y+100,.025)
   self.x=20
   self.y=130
   do_jump(self,0.5,-2.0,75,.025)
   sfx(9)
   self.moving=false
   wait(50)
   change_screen(screens.sign)
  end)

 elseif screen == screens.sign then
  ninjoe.x=-8
  ninjoe.y=0
  ninjoe.cor = cocreate(function(self)
   wait(100)
   self:set_anim("fast_roll")
   do_jump(self,5,0,150,.035)
   change_screen(screens.land)
  end)

 elseif screen == screens.land then
  ninjoe = create_player()
  ninjoe.x=-8
  ninjoe.y=0
  ninjoe.cor = cocreate(function(self)
   wait(50)
   self:set_anim("fast_roll")
   sfx(9)
   do_jump(self,1.75,0,80,.055)
   sfx(3)
   self:set_anim("die")
   wait(150)
   self:set_anim("idle")
   wait(100)
   self:set_anim("walk")
   move_to(self,self.x+60,self.y,.5)
   change_screen(screens.jump)
  end)

 elseif screen == screens.jump then
  ninjoe.x=-8
  ninjoe.y=80
  ninjoe.cor = cocreate(function(self)
   self:set_anim("walk")
   move_to(self,self.x+48,self.y,.5)   
   self:set_anim("idle")
   wait(50)
   self.puzzled=true
   wait(50)
   set_question(
     "jump into hole", 
     "jump over hole",
     function()
      -- into
      ninjoe.cor = cocreate(function(self)
       self:set_anim("jump")
       sfx(7)
       do_jump(ninjoe,0.475,-1,ninjoe.y+10,.055)
       self:set_anim("fall")
       sfx(9)
       move_to(self,self.x,150,2)
       change_screen(screens.jump_death)
      end)
     end,
     function()
      -- over
      ninjoe.cor = cocreate(function(self)
       self:set_anim("jump")
       sfx(7)
       do_jump(ninjoe,1,-1,ninjoe.y,.055)
       self:set_anim("idle")
       wait(50)
       self.flipx = true
       wait(100)
       self.flipx = false
       wait(100)
       self:set_anim("run")
       move_to(self,140,self.y,.75)
       change_screen(screens.stairs)
      end)
     end)
  end)

 elseif screen == screens.jump_death then
  ninjoe.y=-8
  ninjoe.cor = cocreate(function(self)
   self:set_anim("fall")
   move_to(self,self.x,61,2)
   sfx(3)
   self:set_anim("idle")   
  end)
  -- anvil
  anvil = m_obj(98,61)  
  anvil.draw=function(self)
    --self:_draw()
    spr(121,self.x+11,self.y,1,1,false,true)
    sspr(56,56,8,8,self.x,self.y,8,6,false,true)
    pal(5,6)
    pal(1,6)
    pal(2,6)
    spr(120,self.x+7,self.y,1,1,false,true)
    pal()
  end

 elseif screen == screens.stairs then
  ninjoe.x=-8
  ninjoe.y=80
  ninjoe.cor = cocreate(function(self)
   self:set_anim("run")
   move_to(self,self.x+68,self.y,.75)
   self:set_anim("idle")
   self:set_anim("jump")
   sfx(7)
   do_jump(ninjoe,0.25,-2, 56,.055)
   self:set_anim("idle")
   wait(25)
   self:set_anim("jump")
   sfx(7)
   do_jump(ninjoe,0.25,-2, 40,.055)
   self:set_anim("idle")
   wait(25)
   self:set_anim("jump")
   sfx(7)
   do_jump(ninjoe,0.25,-2, 24,.055)
   self:set_anim("idle")
   wait(25)
   self:set_anim("walk")
   move_to(self,self.x+30,self.y,.5)
   change_screen(screens.cliff)
  end)

 elseif screen == screens.cliff then
  ninjoe.x=-8
  ninjoe.y=24
  ninjoe.cor = cocreate(function(self)
   self:set_anim("walk")
   move_to(self,self.x+36,self.y,.5)   
   self:set_anim("idle")
   wait(50)
   self.puzzled=true
   wait(50)
   set_question(
     "fall into chasm", 
     "jump across",
     function()
      -- into
      ninjoe.cor = cocreate(function(self)
       self:set_anim("jump")
       sfx(7)
       do_jump(ninjoe,0.475,-1,ninjoe.y+10,.055)
       self:set_anim("fall")
       move_to(self,self.x,150,2)
       ninjoe.safe=true
       change_screen(screens.shredder)
      end)
     end,
     function()
      -- over
      ninjoe.cor = cocreate(function(self)
       self:set_anim("jump")
       sfx(7)
       do_jump(ninjoe,1,-1,ninjoe.y+16,.055)
       self:set_anim("cheer")
       wait(50)
       -- create alert symbol (wile coyote style!)
       alert_mark=m_obj(ninjoe.x,ninjoe.y-8)
       alert_mark.cor = cocreate(function(self)
        wait(75)
        move_to(self,self.x,150,3)
       end)
       alert_mark.draw=function(self)
        sprintxy("!",self.x,self.y, 12,0,0)
       end
       self:set_anim("fall")
       sfx(9)
       move_to(self,self.x,300,2)
       change_screen(screens.shredder)
      end)
     end)
  end)

 elseif screen == screens.shredder then
   if ninjoe.safe then
    -- "safe" anim
    ninjoe.x=44 -- good
    ninjoe.y=-8
    ninjoe.cor = cocreate(function(self)
     self:set_anim("fall")
     move_to(self,self.x,84,2)
     self:set_anim("idle")   
     airbag.bounce1=25
     airbag.bounce2=1.25
     self:set_anim("roll")
     sfx(3)
     do_jump(ninjoe,-.25,-1.5,ninjoe.y,.055)
     sfx(3)
     do_jump(ninjoe,.4,-1.25,ninjoe.y,.055)
     airbag.bounce1=35
     airbag.bounce2=1.25
     sfx(3)
     do_jump(ninjoe,-.35,-1,ninjoe.y,.055)
     self:set_anim("jump")
     sfx(3)
     do_jump(ninjoe,0.75,-1.5,88,.055)
     self:set_anim("idle")
     wait(50)
     airbag.bounce1=1
     airbag.bounce2=0
     self.flipx = true
     wait(100)
     self.flipx = false
     wait(100)
     self:set_anim("run")
     move_to(self,140,self.y,.75)
     change_screen(screens.drink)
    end)
  else
   -- "death" anim
   ninjoe.x=70 -- bad
   ninjoe.y=-8
   ninjoe.cor = cocreate(function(self)
    self:set_anim("fall")    
    move_to(self,self.x,40,2)
    sfx(17)
    sfx(18)
    wait(100)
    ninjoe.draw=function(self)
     local off=sin(_t/20)*1.1
     palt(7,true)
     spr(169,self.x-off,self.y+off/2)
     spr(169,self.x+off,self.y-off/2)
     pal()
    end
    move_to(self,self.x,88,0.4)
    self:play_dead()
   end)
  end
  -- shredder
  shredder = m_map_obj(56,32, 48,20, 5,2)
  shredder.draw=function(self)
    palt(0,false)
    self:_draw()
    pal()
    printo("shredder",59,38,8)    
  end
  -- airbag
  airbag = m_obj(24,88)  
  airbag.bounce=0
  airbag.bounce1=1
  airbag.bounce2=1
  airbag.draw=function(self)
    clip(8,72,64,24)
    local bounce=sin(_t/airbag.bounce1)*airbag.bounce2
    circfill(29-bounce/2,94, 8, 7)
    circfill(58+bounce/2,94, 8, 7)
    map(48,22, 28,88.5+bounce, 5,2)    
    print("a",29-bounce/1.5,89,0)
    print("i",34-bounce/3,89.75+max(bounce/2,0),0)
    print("r",38,90+bounce/2,0)
    print("b",46,90+bounce/2,0)
    print("a",51+bounce/3,89.75+max(bounce/2,0),0)
    print("g",56+bounce/1.5,89,0)
    clip()
  end

 elseif screen == screens.drink then
  ninjoe.x=-8
  ninjoe.y=88
  ninjoe.cor = cocreate(function(self)
   self:set_anim("walk")
   move_to(self,self.x+40,self.y,.5) 
   self:set_anim("idle")
   wait(50)   
   self.puzzled=true
   wait(50)
   set_question(
     "left bottle", 
     "right bottle",
     function()
      ninjoe.cor = cocreate(function(self)
       -- jump to left drink
       self.drink=1
       self:set_anim("jump")
       sfx(7)
       do_jump(ninjoe,0.5,-1.4,ninjoe.y-6,.055)
       self:set_anim("idle")
       wait(50)
       self.x+=1       
       wait(50)
       self.x-=1
       self:set_message("tHIS STUFF TASTES LIKE...",self.x-40,self.y-20,12)
       wait(100)
       self:set_message("  lIGHTER fLUID! vECCH!",self.x-40,self.y-20,12)
       wait(150)
       self:clear_message()
       wait(50)
       sfx(14)
       self:set_message("bURP!",self.x-10,self.y-20,12)
       wait(150)
       self:clear_message()
       wait(50)
       self:set_message("eXCUSE ME.",self.x-10,self.y-20,12)
       wait(150)
       self:clear_message()
       --
       self:set_anim("jump")
       do_jump(ninjoe,1.0,-1.1,88,.055)
       self:set_anim("idle")
       wait(50)
       self:set_anim("walk")
       move_to(self,150,self.y,.5)
       change_screen(screens.fire) 
      end)
     end,
     function()
      ninjoe.cor = cocreate(function(self)
       -- jump to right drink
       self.drink=2
       self:set_anim("jump")
       sfx(7)
       do_jump(ninjoe,0.92,-1.81,ninjoe.y-6,.055)
       self:set_anim("idle")
       self.flipx = true
       wait(50)
       self.x-=1
       wait(50)
       self.x+=1       
       self:set_message("tHIS STUFF TASTES LIKE...",self.x-70,self.y-20,12)
       wait(100)
       self:set_message(" cARBONATED mILK! vECCH!",self.x-70,self.y-20,12)
       wait(150)
       self:clear_message()
       wait(50)
       sfx(14)
       self:set_message("bURP!",self.x-10,self.y-20,12)
       wait(150)
       self:clear_message()
       wait(50)
       self:set_message("eXCUSE ME.",self.x-10,self.y-20,12)
       wait(150)
       self:clear_message()
       --
       self.flipx = false
       self:set_anim("jump")
       do_jump(ninjoe,0.25,-0.75,88,.055)
       self:set_anim("idle")
       wait(50)
       self:set_anim("walk")
       move_to(self,150,self.y,.5)
       change_screen(screens.fire) 
      end)
     end,
     "wHICH SHOULD I DRINK?\n      /")
  end)

 elseif screen == screens.fire then
  ninjoe.x=-8
  --ninjoe.x=48
  ninjoe.y=88
  sfx(63)
  ninjoe.cor = cocreate(function(self)
   self:set_anim("walk")
   move_to(self,self.x+48,self.y,.5) 
   self:set_anim("idle")
   wait(100)
   sfx(14)
   self:set_message("bURP!",self.x-20,self.y-10,12)
   wait(150)
   self:clear_message()
   if self.drink == 1 then
    -- "death"
    self.burn_count=0
    self.fire_frame=0
    self.draw=function(self)     
     clip(self.x,self.y+self.burn_count-1,8,10-self.burn_count)
     spr(128,self.x,self.y)
     clip()
     -- anim 1
     palt(1,true)
     palt(13,true)
     palt(5,true)     
     if(_t%6==0) self.fire_frame=(self.fire_frame+1)%3
     local fframes={[0]=10,9,4}
     for i=0,2 do
      if (self.fire_frame!=i) palt(fframes[i],true)
     end
     palt(0,true)
     spr(178,self.x,self.y+self.burn_count-8)
     pal()
     -- anim 1
     palt(1,true)
     palt(13,true)
     palt(5,true)     
     for i=0,2 do
      if ((self.fire_frame+2)%3!=i) palt(fframes[i],true)
     end
     palt(0,true)
     spr(178,self.x+2,self.y+self.burn_count-8,1,1,true)
     pal()
    end
   else
    -- "safe"
    self:set_message("eXCUSE ME.",self.x-37,self.y-10,12)
    wait(150)
    self:clear_message()
    self:set_anim("walk")
    move_to(self,150,self.y,.5)
    change_screen(screens.switch)
   end
  end)
  -- fire
  fire_frame=0

 elseif screen == screens.switch then
  weight=nil
  weight_anim_count=nil
  ninjoe.x=-8
  ninjoe.y=88
  ninjoe.switch=0
  ninjoe.cor = cocreate(function(self)
   self:set_anim("walk")
   move_to(self,self.x+79,self.y,.5) 
   self:set_anim("idle")
   wait(100)
   self.puzzled=true
   wait(50)
   set_question(
    "flip switch up", 
    "flip switch down",
    function()
     ninjoe.cor = cocreate(function(self)
      -- switched "up" (dead)
      self.switch=1
      sfx(11)
      mset(42,27,8)
      drop_weight()
      -- dead
      move_to(ninjoe,ninjoe.x-15,ninjoe.y,.5) 
      weight.done=true
      ninjoe.x=-8
      wait(100)
      ninjoe.x=56
      ninjoe:play_dead()
     end)
    end,
    function()
     ninjoe.cor = cocreate(function(self)
      -- switched "down" (safe)
      self.switch=2
      sfx(11)
      drop_weight()
      -- safe!
      move_to(self,self.x-10,self.y,.5) 
      self.hole_opened=true
      self:set_anim("idle")
      wait(5)
      self:set_anim("fall")
      sfx(9)
      move_to(self,self.x,200,2)
      change_screen(screens.cellar)
     end)
    end,
    "wHICH WAY SHOULD I\n FLIP THE SWITCH?\n             \\",
    -50,-20)
  end)


 elseif screen == screens.cellar then
  ninjoe.x=48
  ninjoe.y=-8  
  ninjoe.flipx=false
  ninjoe.cor = cocreate(function(self)
   self:set_anim("fall")
   move_to(self,self.x,80,2)
   sfx(3)
   self:set_anim("die")
   wait(150)
   self:set_anim("idle")
   wait(100)
   self:set_anim("walk")
   move_to(self,140,self.y,.5)
   change_screen(screens.pendulum)
  end)

 elseif screen == screens.pendulum then
  ninjoe.x=-8
  ninjoe.y=80
  ninjoe.cor = cocreate(function(self)
   self:set_anim("walk")
   move_to(self,15,self.y,.5)
   self:set_anim("idle")
   wait(50)
   self.puzzled=true
   wait(100)
   self.puzzled=false
  end)
  -- pendulum
  pendulum = m_obj(64,24)
  pendulum.sx=0
  pendulum.sy=0
  pendulum.draw=function(self)
   if not pendulum.stopped then
    self.sx=self.x+56*sin(.15*sin(t()/2))
    self.sy=self.y+56*cos(.15*sin(t()/2))
   end
   local col=9
   line(self.x,self.y,self.sx,self.sy,col)
   circfill(self.sx,self.sy,7,col)
   circfill(self.sx,self.sy,6,7)
   circfill(self.sx+1,self.sy,6,col)
  end

 elseif screen == screens.house_end then
  death_house=nil
  glove=nil
  ninjoe.x=-8
  ninjoe.y=80
  ninjoe.cor = cocreate(function(self)  
   self:set_anim("walk")
   move_to(self,20,self.y,.5)
   self:set_anim("idle")
   wait(50)
   self:set_message("mY HOUSE!",self.x-10,self.y-18,12)
   wait(50)
   sfx(48)
   self:set_message("mY HOUSE!\naT LAST.",self.x-10,self.y-18,12)
   wait(150)
   self:clear_message()
   self:set_anim("walk")
   move_to(self,self.x+24,self.y,.5)
   self:set_anim("idle")
   self:set_message("wAIT A MINUTE...",self.x-30,self.y-12,12)
   wait(100)
   self:clear_message()   
   set_question(
    "yes", 
    "no. too easy",
    function()
    ninjoe.cor = cocreate(function(self)
      -- yes ("win" = dead!)
      self:set_anim("walk")
      move_to(self,74,self.y,.5)
      move_to(self,self.x+4,self.y-3,.5)
      self:set_anim("idle")
      wait(50)
      self:set_message("hOME SWEET\n   HOME...",self.x-40,self.y-15,12)      
      wait(150)
      self:clear_message()
      wait(20)
      ninjoe.x+=1
      ninjoe.arm_out=true
      sfx(11)
      wait(75)
      ninjoe.arm_out=false
      ninjoe.y=150
      explode_house()      
     end)     
    end,
    function()
     ninjoe.cor = cocreate(function(self)
      -- no (dead)      
      self:set_anim("walk")
      self.flipx=true
      move_to(self,self.x-16,self.y,.5)
      self:set_anim("idle")
      self:set_message("nOW i FEEL SAFE.",self.x-24,self.y-12,12)
      wait(100)
      self:clear_message()
      drop_glove_and_more()
     end)
    end,
    "sHOULD i GO\nTO MY HOUSE?\n     /",
    -15,-20)
  end)
  -- house (real)
  house = m_obj(80,56)
  house.draw = draw_house
  house.cor = cocreate(function(self)
   -- do nothing (for now)
  end)
 



 elseif screen == screens.final then

 end
end

function explode_house()
 local sprites={34,35,71,72,116}
 house.explode_count=0
 house.exploded=true
 house.cor = cocreate(function(self)
  move_to(self,self.x,self.y+45,.25)
  house.explode_count=nil
  ninjoe.x=100
  ninjoe.y=76
  ninjoe.win=true
  music(7)
  ninjoe:play_dead()
 end)
 house.draw=function(self)
  draw_house(self)
  if house.exploded then
   srand(5)
   for i=1,48,4 do
    spr(34+rnd(2),house.x+i+rnd(4)-2,84+rnd(4)-2)
   end
  end
  if house.explode_count then
   srand(flr(house.explode_count))
   house.explode_count+=0.5
   for i=1,flr(house.explode_count) do
    spr(sprites[irnd(#sprites)],self.x-5+rnd(50),self.y-10+rnd(40))
   end
   -- play explosion
   if (irnd(10)==1) sfx(6)
  end
 end
 
end

function draw_house(obj)
 clip(obj.x,obj.y, 56,32)
 if not obj.death then 
  -- cake
  pal(6,14)
  spr(42,obj.x+39,obj.y+20)
  for i=0,2 do
   pset(obj.x+40+i*2,obj.y+18,8+rnd(2))
   pset(obj.x+40+i*2,obj.y+19,2)
  end
 end
 pal()
 -- house
 spr(191,obj.x,obj.y+27)
 spr(191,obj.x+4,obj.y+25)
 palt(0,false)
 pal(1,6)
 pal(12,5)
 pal(7,0)
 if obj.death then
  pal(6,8)
 else
  pal(6,4)
 end
 pal(5,2)
 map(10,6, obj.x,obj.y, 7, 4)
 pal()
 rectfill(obj.x+16,obj.y+16,obj.x+36,obj.y+23,0)
 clip()
end

function drop_glove_and_more()
 -- glove
 glove = m_obj(27,-30)
 glove.draw=function(self)
  local scale=1
  zspr(64,1,1,self.x+3,self.y-3,scale,false,true)
  --
  pal(7,8)
  pal(11,8)
  pal(3,2)
  zspr(86,1,1,self.x+0,self.y-6,scale)
  pal()
  zspr(94,1,1,self.x,self.y,scale)--,false,fy)
 end
 glove.cor = cocreate(function(self)  
  sfx(9)
  move_to(self,self.x,80,3)
  sfx(6)
 end)

 -- "death" house
 death_house = m_obj(8,-35)
 death_house.draw = draw_house
 death_house.death=true
 death_house.cor = cocreate(function(self)
  wait(100)
  sfx(9)
  move_to(self,self.x,56,3)
  sfx(6)
  wait(5)
  sfx(6)
  wait(150)
  ninjoe.y-=32
  ninjoe:play_dead()
 end)
end


function drop_weight()
 -- --------------------------------
 -- pre weight-drop
 --
 wait(100)
 ninjoe.puzzled=true
 wait(100)
 ninjoe.puzzled=false
 ninjoe.flipx=true
 wait(50)
 ninjoe:set_message("hMMM...",ninjoe.x-30,ninjoe.y-10,12)
 wait(150)
 ninjoe:clear_message()
 ninjoe.flipx=false
 wait(50)
 ninjoe:set_message("nOTHING HAPPENED.",ninjoe.x-45,ninjoe.y-10,12)
 wait(150)
 ninjoe:clear_message()
 ninjoe.flipx=true
 wait(50)
 ninjoe:set_anim("walk")
 move_to(ninjoe,ninjoe.x-5,ninjoe.y,.5) 

 -- --------------------------------
 -- drop wright
 --
 weight_anim_count=0
 -- weight
 -- (x,y,map_x,map_y,map_w,map_h)
 weight = m_map_obj(40,-20, 48,24, 5,3)
 weight.update=function(self)
  self:_update()
   -- sequence actions???   
  end
  weight.draw=function(self)
    pal(7,6)
    self:_draw()
    pal()
    print(" 16\ntons",self.x+12,self.y+11,0)
  end
  weight.cor = cocreate(function(self)
   move_to(self,self.x,72,3)   
   sfx(15)
  end)
end

function create_player()
 local anims={
  ["idle"]={
	 ticks=16,--how long is each frame shown.
	 frames={128,129},--what frames are shown.
  },
  ["run"]={
    ticks=6,
		frames={144,145,146,147},
  },
  ["walk"]={
    ticks=12,
		frames={144,145,146,147},
  },
	["jump"]={
		ticks=16,
		frames={130,131,131,131,131,131,130},
	},
  ["fall"]={
	 ticks=16,
	 frames={163,164},
	},
  ["cheer"]={
	 ticks=16,
	 frames={131},
	},
  ["fast_roll"]={
	 ticks=2,
	 frames={148,149,133},
	},
  ["roll"]={
	 ticks=8,
	 frames={148,149,133},
	},
  ["die"]={
	 ticks=16,
	 frames={134},
	},
 }

 local player = m_anim_obj(58,72,
   anims,
   "idle")
 
 player.play_dead = function(self)
  -- todo: play death anim
  self.death_count=0
  -- redefine draw
  self.draw=function(self)
   clip(self.x,self.y,8,8)   
   spr(52,self.x,self.y+8-(min(self.death_count,8)))   
   sspr(0,58,8,4,self.x-3,self.y+6,8,3)
   clip()
  end
  while self.death_count != nil do  
   self.death_count+=.25   
   if (ninjoe.death_count==25) sfx(45)
   yield()
  end
 end

 return player
end

function set_question(option1, option2, func1, func2, quest, xoff, yoff)
 -- ask player (speech dialog)
 ninjoe.puzzled=false
 wait(50)
 ninjoe:set_message(quest or ("wHAT SHOULD I DO?".."\n      /"),
   ninjoe.x + (xoff or -16),
   ninjoe.y + (yoff or -14),
   12) 
 wait(150)
 ninjoe:clear_message()
 ninjoe.puzzled=false
 
 -- set the question
 question = {
    option1=option1,
    option2=option2,
    func1=func1,
    func2=func2,    
    sel_option=0,
    time=127, -- full width of time
    disp_mode=1, -- 1=slide_in, 0=question, -1=slide_out
    top=127,
    update=function(self)
     if self.disp_mode==1 then
      -- slide-in
      self.top -= 1
      if self.top<=110 then
       -- move to next mode
       self.disp_mode=0
      end
     elseif self.disp_mode==0 then
      -- question mode
      self.time -= 0.25
      if self.time>0 then
       if (btnp(0)) self.sel_option=1
       if (btnp(1)) self.sel_option=2
       if (btnp(4) or btnp(5)) self.time=0.25 -- skip
      elseif self.time==0 and self.sel_option==0 then 
       self.sel_option=1 --auto-select      
      elseif self.time<=-10 or btnp(5) then
       -- move to next mode
       self.disp_mode=-1
      end

     elseif self.disp_mode==-1 then
      -- slide-out
      self.top += 1
      if self.top>157 then
       -- time's up!      
       if (self.sel_option==1) func1()
       if (self.sel_option==2) func2()
       -- kill q
       question=nil
      end
     end
    end,
    draw=function(self)
     local fadecols={0,1,5}
     local fadecol=(self.time<=0) and fadecols[flr((self.time+10)/3)+1] or nil
     local x1=30
     local x2=97
     local len1=min(#self.option1,16)
     local w1=len1*4
     local len2=min(#self.option2,16)
     local w2=len2*4
     local sy=self.top+14
     rectfill(0,self.top,127,127,0)     
     if (self.time>0) line(63-self.time/2,self.top,63+self.time/2,self.top,7)
     print(self.option1,x1-w1/2,self.top+6,
      self.sel_option==1 and 7 or (fadecol or 5))
     print(self.option2,x2-w2/2,self.top+6,
      self.sel_option==2 and 7 or (fadecol or 5))
     if self.sel_option then
      if self.sel_option==1 then
       local ramp=len1/3
       line(x1-w1/2,sy,x1+w1/2,sy,1)
       line(x1-w1/2+ramp,sy,x1+w1/2-ramp,sy,5)
       line(x1-w1/2+ramp*2,sy,x1+w1/2-ramp*2,sy,6)
       line(x1-w1/2+ramp*4,sy,x1+w1/2-ramp*4,sy,7)
      elseif self.sel_option==2 then
       local ramp=len2/3
       line(x2-w2/2,sy,x2+w2/2,sy,1)
       line(x2-w2/2+ramp,sy,x2+w2/2-ramp,sy,5)
       line(x2-w2/2+ramp*2,sy,x2+w2/2-ramp*2,sy,6)
       line(x2-w2/2+ramp*4,sy,x2+w2/2-ramp*4,sy,7)
      end
     end
    end,
  }  
end


-->8
-- update tab
-------------------------------
function _update60()

 if trans_count then
  trans_count+=1
  return
 end

 -- update timecode (used of all sequencing)
 _t+=1

 if curr_screen == screens.title then
  if (btnp(4) or btnp(5)) change_screen(screens.house_start)

 elseif curr_screen == screens.house_start then    
  ninjoe:update()
  
 elseif curr_screen == screens.space then  
  dot:update()

 elseif curr_screen == screens.sign then
  ninjoe:update()

 elseif curr_screen == screens.land then
  ninjoe:update()

 elseif curr_screen == screens.jump then
  ninjoe:update()
  if (question) question:update()
 
 elseif curr_screen == screens.jump_death then
  ninjoe:update()
  anvil:update()
  if _t==30 then
   anvil.cor = cocreate(function(self)
    do_jump(self,-.625,-2.05,64,.055)
    sfx(6)
    self.y=200
    ninjoe.y=64
    ninjoe:play_dead()
   end)
  end

 elseif curr_screen == screens.stairs then
  ninjoe:update() 

 elseif curr_screen == screens.cliff then
  ninjoe:update()
  if (question) question:update()
  if (alert_mark) alert_mark:update()

 elseif curr_screen == screens.shredder then
  ninjoe:update()
    
 elseif curr_screen == screens.drink then
  ninjoe:update()
  if (question) question:update()

 elseif curr_screen == screens.fire then
  ninjoe:update()
  if ninjoe.burn_count then
   ninjoe.burn_count+=.025
   if flr(ninjoe.burn_count)==9 then
    ninjoe.cor = cocreate(function(self)
     self.burn_count=nil
     self:play_dead()
    end)
   end
  end

 elseif curr_screen == screens.switch then
  ninjoe:update()
  if (question) question:update()
  if (weight) weight:update()
  if (weight_anim_count) weight_anim_count+=1

 elseif curr_screen == screens.cellar then
  ninjoe:update() 

 elseif curr_screen == screens.pendulum then
  ninjoe:update() 
  pendulum:update()  
  -- run?
  -- if (btnp(0)) ninjoe.x-=1
  -- if (btnp(1)) ninjoe.x+=1
  if _t>300 
   and not ninjoe.has_run 
   and (btnp(4) or btnp(5)) 
  then
   ninjoe.has_run = true
   ninjoe.cor = cocreate(function(self)
    self:set_anim("run")
    move_to(self,100,self.y,1.25)
    self:set_anim("idle")
    wait(50)
    ninjoe.flipx=true
    wait(50)
    ninjoe.flipx=false
    wait(50)
    self:set_anim("walk")
    move_to(self,130,self.y,.5)
    change_screen(screens.house_end)
   end)
  end
  -- collision
  if not pendulum.stopped and 
   pendulum.sy>74 and
   (ninjoe.x+2>pendulum.sx-6 and ninjoe.x+6<pendulum.sx+2) 
  then
   ninjoe.cor = cocreate(function(self)
    pendulum.stopped=true
    ninjoe:play_dead()
   end)
  end

 elseif curr_screen == screens.house_end then
  ninjoe:update()
  house:update()
  if (glove) glove:update()
  if (death_house) death_house:update()
  if (question) question:update()
 
 elseif curr_screen == screens.final then

 end

 -- applies to all screens
 if ninjoe.death_count
  and ninjoe.death_count>25 
  and (btnp(4) or btnp(5)) then
  if ninjoe.win then
   -- exit to title
   change_screen(screens.title)
  else
   -- restart game   
   change_screen(screens.land)
  end
  ninjoe.death_count=nil
  ninjoe.win=nil
 end

end -- fn


-->8
--draw tab
-------------------------------
function _draw()

 bypass=do_bypass
  
 -- bail out if in screen transition mode
 -- (just draw the transition)
 if trans_mode and not bypass then
  printh("here!")
  draw_trans()
  trans_mode=false
  return
 end

 cls()
 if curr_screen == screens.title then
  sprintc("alfredo's",2,7,0,0)
  sprintc("stupendous",3,7,0,0)
  sprintc("surprise",4,7,0,0)
  printc("bandersnatch edition",42,8)
  map(112,16, 0,0, 32, 32)  
  ninjoe:draw()
  
  printo("press a\n  key", 86,59,0,7)

  printc("sTORY BY tOM hALL",94,6)  
  rect(0,91,127,117,4)
  printc("pROGRAMMING: pAUL nICHOLAS",102,6)
  printc("(oRIG BY jOHN rOMERO,tOM hALL)",110,6)
  
 elseif curr_screen == screens.house_start then
  baby_cake:draw()  
  spr(191,80,75)
  spr(191,84,73)
  palt(0,false)
  house:draw()
  map(0,10, 0,80, 16, 1)
  ninjoe:draw()
  if (momma_cake) momma_cake:draw()

 elseif curr_screen == screens.space then
  srand(5)
  local cols={1,5}
  for i=1,150 do
   pset(rnd(128),rnd(128),cols[irnd(3)])
  end
  map(17,0, 8,0, 32, 32)
  dot:draw()

 elseif curr_screen == screens.sign then
  map(32,0, 0,0, 32, 32)
  sprintxy("alfredo's",32,52, 8,7,7)
  sprintxy("deadly",32,64, 8,7,7)
  sprintxy("decisions",32,76, 8,7,7)
  pal(5,8)
  pal(6,8)
  pal(7,0)
  zspr(126,1,1,88,60,2)
  pal()
  ninjoe:draw()

 elseif curr_screen == screens.land then
  map(48,0, 0,0, 32, 32)
  ninjoe:draw()
  if ninjoe.curanim=="die" then
   srand(flr(_t/4))
   for i=1,4 do
    pset(ninjoe.x-4+rnd(10),ninjoe.y-4+rnd(5),10)
   end
  end

 elseif curr_screen == screens.jump then
  map(64,0, 0,0, 32, 32)
  ninjoe:draw()
  if (question) question:draw()

 elseif curr_screen == screens.jump_death then
  map(64,16, 0,0, 32, 32)
  -- seesaw
  if (_t<30) line(56,56, 115,70, 4) --up
  if (_t>=30 and _t<32) line(58,63, 117,63, 4) --mid
  if (_t>=32) line(56,71, 115,56, 4) --down
  ninjoe:draw()
  anvil:draw()

 elseif curr_screen == screens.stairs then
  map(80,0, 0,0, 32, 32)
  ninjoe:draw()

 elseif curr_screen == screens.cliff then
  pal(9,4)
  pal(7,0)
  pal(10,0)
  map(96,0, 0,0, 32, 32)
  pal()
  ninjoe:draw()
  if (question) question:draw()
  if (alert_mark) alert_mark:draw()

 elseif curr_screen == screens.shredder then
  pal(9,4)
  pal(7,0)
  pal(10,0)
  map(112,0, 0,0, 32, 32)
  pal()
  airbag:draw()
  ninjoe:draw()
  shredder:draw()

 elseif curr_screen == screens.drink then
  map(0,16, 0,0, 32, 32)
  ninjoe:draw()
  fillp(0b111100001111)
  line(64,84,67,87,120)
  line(84,87,87,84,120)
  fillp()
  if (question) question:draw()

 elseif curr_screen == screens.fire then
  map(16,16, 0,0, 32, 32)  
  printo("refinery\nexcess\nburn-off",92,44,0,7)
  ninjoe:draw()
  -- fire
  local frames={
   [0]={53,17},
   {56,17},
   {59,17}
  }
  if (_t%4==0) fire_frame=(fire_frame+1)%3
  map(frames[fire_frame][1], 
      frames[fire_frame][2],
      40,48,
      3,5)

 elseif curr_screen == screens.switch then 
  map(32,16, 0,0, 32, 32)  
  printo("flip\nme",100,75,0,7)
  -- idle switch?
  if ninjoe.switch==0 then
   pal(8,6)
   pal(2,5)
   pal(14,7)
   pal(6,7)
   pal(7,0)
   spr(7,80,88)
   pal()
  end
  -- hole?
  if ninjoe.hole_opened then
    rectfill(48,96,71,104,0)  
  else 
   rectfill(0,104,127,127,0)  
  end
  -- trapdoor
  if weight_anim_count==nil 
   or weight_anim_count<=0 then
  -- closed
   line(33,32, 86,32, 4)
   line(33,33, 86,33, 4)
  elseif weight_anim_count>0 and weight_anim_count<5 then
   -- mid (left)
   line(33,32, 50,49, 4)
   line(34,32, 50,48, 4)
   -- mid (right)
   line(86,32, 69,49, 4)
   line(85,32, 69,48, 4)
  elseif weight_anim_count>=5 then
   -- open (left)
   line(33,32, 33,56, 4)
   line(34,32, 34,56, 4)
   -- open (right)   
   line(86,32, 86,56, 4)
   line(85,32, 85,56, 4)  
  end
  if (not weight or not weight.done) ninjoe:draw()
  -- weight
  clip(0,32,128,64)  
  if (weight) weight:draw()
  clip()
  if (weight and weight.done) ninjoe:draw()  
  if (question) question:draw()

 elseif curr_screen == screens.cellar then
  map(80 ,16, 0,0, 32, 32)
  ninjoe:draw()
  if ninjoe.curanim=="die" then
   srand(flr(_t/4))
   for i=1,4 do
    pset(ninjoe.x-4+rnd(10),ninjoe.y-4+rnd(5),10)
   end
  end

 elseif curr_screen == screens.pendulum then
  map(96 ,16, 0,0, 32, 32)
  pendulum:draw()  
  ninjoe:draw()
  -- instructions
  if _t>300 and not ninjoe.has_run then
   local y=104
   rectfill(23,y,101,y+19,7)
   rect(22,y-1,102,y+20,0)
   rect(21,y-2,103,y+21,7)
   printc("pRESS A KEY WHEN",y+4,8)
   printc("aLFREDO SHOULD RUN.",y+11,8)
  end

 elseif curr_screen == screens.house_end then
  if (ninjoe.death_count==nil) ninjoe:draw()
  if (glove) glove:draw()
  if (death_house) death_house:draw()
  if (ninjoe.death_count) ninjoe:draw()
  if (ninjoe.arm_out)  print("|",ninjoe.x+6,ninjoe.y+4,0) print("-",ninjoe.x+8,ninjoe.y+1,13)
  house:draw()
  map(0,10, 0,88, 16, 1)
  rectfill(0,96,127,127,0) 
  if (question) question:draw()

 elseif curr_screen == screens.final then
 end
 
 -- applies to all screens!
 if ninjoe.puzzled then  
  sprintxy("?",ninjoe.x,ninjoe.y-8, 12,0,0)
 end

 if ninjoe.death_count
  and ninjoe.death_count>25 then  
  if ninjoe.win then
   rectfill(23,25,101,61,7)
   rect(22,24,102,62,0)
   rect(21,23,103,63,7)
   printc("the end",28,8)
   printc("aLFREDO GOT TO",35,0)
   printc("HIS HOUSE!",41,0)
   printc("cONGRATULATIONS!",47,12)
   printc("pRESS TO QUIT",53,0)
  else
   rectfill(23,25,101,55,7)
   rect(22,24,102,56,0)
   rect(21,23,103,57,7)
   printc("the end",28,8)
   printc("aLFREDO DID NOT",35,0)
   printc("gET TO HIS HOUSE",41,0)
   printc("pRESS TO TRY AGAIN",47,0)
  end
 end

end -- fn
------------------------------

trans_mode=false
target_screen=nil

function change_screen(screen)
 trans_mode=true
 target_screen=screen
end

function draw_trans()
 local speed=6
 -- fade out
 for i=0,127,speed do
  for l=0,127,2 do
   line(0,l,i,l,0)
   line(127,l+1,127-i,l+1,0)
  end
  flip()
 end

-- reset timecode
 _t=0
 -- stop any loops
 sfx(63,-2)

 -- init new screen
 init_screen(target_screen)
 -- change screen
 curr_screen = target_screen

 -- fade out
 for i=127,0,-speed do
  do_bypass=true
  _draw() 
  do_bypass=false
  for l=0,127,2 do
    line(0,l,i,l,0)
    line(127,l+1,127-i,l+1,0)
  end
  flip()
 end
end


-- anim/obj related
--------------------------------

function do_jump(self,dx,dy,land_y,gravity)
local g = gravity or .075
 repeat
  dy+=gravity
  self.x+=dx
  self.y+=dy
  yield()
 until dy>0 and self.y>land_y
 self.y = land_y
end

-- fixed sqrt to avoid overflow
-- https://www.lexaloffle.com/bbs/?tid=29528
function dist(x1,y1,x2,y2)
 return abs(sqrt(((x1-x2)/1000)^2+((y1-y2)/1000)^2)*1000)
end

function move_to(self,tx,ty,speed)
 -- move to new position
 local distance = dist(self.x, self.y, tx, ty)
 --local distance = sqrt((tx - self.x) ^ 2 + (ty - self.y) ^ 2)
 local step_x = speed * (tx - self.x) / distance
 local step_y = speed * (ty - self.y) / distance 
 for i = 0, distance/speed-1 do
  self.x+=step_x
  self.y+=step_y
  yield()
 end
 self.x,self.y = tx, ty
end

function wait(cycles)
 for i=0,cycles do
  yield()
 end
end

function _set_anim(self,anim)
 if(anim==self.curanim)return--early out.
 local a=self.anims[anim]
 self.animtick=a.ticks--ticks count down.
 self.curanim=anim
 self.curframe=1
 self.spr=a.frames[self.curframe]
end

function _update_anim(self)
--anim tick
 self.animtick-=1
 if self.animtick<=0 then
  self.curframe+=1
  local a=self.anims[self.curanim]
  self.animtick=a.ticks--reset timer
  if self.curframe>#a.frames then
   self.curframe=1--loop
  end
  -- store the spr frame
  self.spr=a.frames[self.curframe]
  
 end
end

function _update_cor(self)
  if self then
    if self.cor and costatus(self.cor) != 'dead' then
      assert(coresume(self.cor, self))
    else
      self.cor = nil
    end
  end
end

function m_map_obj(x,y,map_x,map_y,map_w,map_h)
 local new_obj = m_msg_obj(x,y)
 new_obj.map_x=map_x -- 
 new_obj.map_y=map_y --
 new_obj.map_w=map_w -- 
 new_obj.map_h=map_h --
 new_obj.update=function(self) 
  _update_cor(self)
 end
 new_obj.draw=function(self)
  -- base msg draw
  self:__draw()
  
  -- draw sprite
  map(
   self.map_x, self.map_y,
	 self.x,
	 self.y,
	 self.map_w,self.map_h)  
 end
 new_obj.__draw=new_obj._draw -- preserve base draw
 new_obj._draw=new_obj.draw -- allow easy overloading
 return new_obj
end

function m_anim_obj(x,y,anims,curanim)
 local new_obj = m_msg_obj(x,y)
 new_obj.spr=anims[curanim].frames[1]
 new_obj.spr_w=1 -- defaults
 new_obj.spr_h=1 --
 new_obj.anims=anims --animation definitions.
 new_obj.curanim=curanim --currently playing animation
  new_obj.curframe=1 --curent frame of animation.
	new_obj.animtick=0 --ticks until next frame should show.
 new_obj.set_anim=_set_anim
 new_obj.update_anim=_update_anim 
 new_obj.update=function(self) 
  _update_anim(self)
  _update_cor(self)
 end
 new_obj.draw=function(self)
  -- base msg draw
  self:__draw()

  -- draw sprite
  spr(self.spr,
	 self.x,
	 self.y,
	 self.spr_w,self.spr_h,
	 self.flipx,
	 false)
 end
 new_obj.__draw=new_obj._draw -- preserve base draw
 new_obj._draw=new_obj.draw -- allow easy overloading
 return new_obj
end

function m_msg_obj(x,y)
 local new_obj = m_obj(x,y) 
 new_obj.set_message = function(self,text,x,y,col)
  new_obj.msg_x=x
  new_obj.msg_y=y
  new_obj.msg_text=text
  new_obj.msg_col=col
 end
 new_obj.clear_message = function(self)
  new_obj.msg_text=nil
 end
 new_obj.update=function(self)
  _update_cor(self)
 end
 new_obj.draw = function(self)
  if self.msg_text then 
  printo(self.msg_text,
	 self.msg_x,
	 self.msg_y,
   self.msg_col,1)
  end
 end  
 new_obj._draw=new_obj.draw -- allow easy overloading
 -- init message
 new_obj.cor = cocreate(function(self)
  wait(self.duration)
 end)
 return new_obj
end


function m_obj(x,y)
 local new_obj = {
  x=x,
  y=y,
  z=1, -- defaults  
  cor=nil, -- coroutine support  
  update_cor=_update_cor,
  update=function(self)
    _update_cor(self)
  end,
 }
 new_obj._update=new_obj.update -- allow easy overloading
 return new_obj
end

function irnd(num)
 return flr(rnd(num))+1
end

--https://www.lexaloffle.com/bbs/?tid=2429
function zspr(n,w,h,dx,dy,dz,fx,fy)
 local sx = 8 * (n % 16)
 local sy = 8 * flr(n / 16)
 local sw = 8 * w
 local sh = 8 * h
 local dw = sw * dz
 local dh = sh * dz
 sspr(sx,sy,sw,sh,dx,dy,dw,dh,fx,fy)
end


-->8
-- support library
-------------------------------

----------------------------
-- sets up ascii tables
-- by yellow afterlife
-- https://www.lexaloffle.com/bbs/?tid=2420
-- btw after ` not sure if 
-- accurate
function setup_asciitables()
 chars=" !\"#$%&'()*+,-./0123456789:;<=>?@abcdefghijklmnopqrstuvwxyz[\\]^_`|ÄÄÅÇÉÑÖÜáàâäãéåçéèêëíìîïñóòô~"
 -- '
 s2c={}
 c2s={}
 for i=1,#chars do
  c=i+31
  s=sub(chars,i,i)
  c2s[c]=s
  s2c[s]=c
 end
end
---------------------------
function asc(_chr)
 return s2c[_chr]
end
---------------------------
function chr(_ascii)
 return c2s[_ascii]
end

-- for ord and chr, sprint
 setup_asciitables()


-- scroll tile
-- see that water tile?
-- this scrolls it down by 1
function scroll_tile(_tile)
 local temp
 local sheetwidth=64 -- bytes
 local spritestart=0 -- starts at mem address 0x0000
 local spritewide=4 -- 8 pixels=four bytes
 local spritehigh=sheetwidth*8 -- how far to jump down
 local startcol=_tile%16
 local startrow=flr(_tile/16)
 
 if (_tile>255) return
 -- save bottom row of sprite
 temp=peek4(spritestart+(startrow*sheetwidth*8)+(7*sheetwidth)+startcol*spritewide) -- 7th row
 for i=6,0,-1 do
  poke4(spritestart+(startrow*sheetwidth*8)+((i+1)*sheetwidth)+startcol*spritewide,peek4(spritestart+(startrow*sheetwidth*8)+(i*sheetwidth)+startcol*spritewide)) 
 end
 --now put bottom row on top!
 poke4(spritestart+(startrow*sheetwidth*8)+startcol*spritewide,temp) 
end 

-------------------------------
-- print string s at x y with
-- color c and outline 1al
function print6(_s,_x,_y,_c,_o)
end
-------------------------------
-- collision detection function;
-- returns true if two boxes overlap, false if they don't;
-- x1,y1 are the top-left coords of the first box, while w1,h1 are its width and height;
-- x2,y2,w2 & h2 are the same, but for the second box.
function checkcollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

-------------------------------
function printc(_str,_y,_c)
 len=#_str
 where=63-(len*2)
 if (where<0) where=0
 print(_str,where,_y,_c)
end
-------------------------------
function printo(str, x, y, c0, c1)
for xx = -1, 1 do
 for yy = -1, 1 do
 print(str, x+xx, y+yy, c1)
 end
end
print(str,x,y,c0)
end
-------------------------------
-- sprite print
-- _c = letter color
-- _c2 = line color
-- _c3 = background color of font
-- collapse all these sprite
-- printing routines into one
-- function if you want!
function sprint(_str,_x,_y,_c,_c2,_c3)
 local i, num
 palt(0,false) -- make sure black is solid
 if (_c != nil) pal(7,_c) -- instead of white, draw this
 if (_c2 != nil) pal(6,_c2) -- instead of light gray, draw this
 if (_c3 != nil) pal(5,_c3) -- instead of dark gray, draw this
 -- make color 5 and 6 transparent for font plus shadow on screen
  
 for i=1,#_str do
  num=asc(sub(_str,i,i))+160
  spr(num,(_x+i-1)*8,_y*8)
 end
 pal()
end
-------------------------------
-- sprite print centered on x
function sprintc(_str,_y,_c,_c2,_c3)
 local i, num
 _x=63-(flr(#_str*8)/2)
 palt(0,false) -- make sure black is solid
 if (_c != nil) pal(7,_c) -- instead of white, draw this
 if (_c2 != nil) pal(6,_c2) -- instead of light gray, draw this
 if (_c3 != nil) pal(5,_c3) -- instead of dark gray, draw this
 -- make color 5 and 6 transparent for font plus shadow on screen
  
 for i=1,#_str do
  num=asc(sub(_str,i,i))+160
  spr(num,_x+(i-1)*8,_y*8)
 end
 pal()
end
-------------------------------
-- sprite print at x,y pixel coords
function sprintxy(_str,_x,_y,_c,_c2,_c3)
 local i, num
 palt(0,false) -- make sure black is solid
 if (_c != nil) pal(7,_c) -- instead of white, draw this
 if (_c2 != nil) pal(6,_c2) -- instead of light gray, draw this
 if (_c3 != nil) pal(5,_c3) -- instead of dark gray, draw this
 -- make color 5 and 6 transparent for font plus shadow on screen
  
 for i=1,#_str do
  num=asc(sub(_str,i,i))+160
  spr(num,_x+(i-1)*8,_y)
 end
 pal()
end
-------------------------------
-- double-sized sprite print at x,y pixel coords
function dsprintxy(_str,_x,_y,_c,_c2,_c3)
 local i, num,sx,sy
 palt(0,false) -- make sure black is solid
 if (_c != nil) pal(7,_c) -- instead of white, draw this
 if (_c2 != nil) pal(6,_c2) -- instead of light gray, draw this
 if (_c3 != nil) pal(5,_c3) -- instead of dark gray, draw this
 -- make color 5 and 6 transparent for font plus shadow on screen
 -- (btw you can use this technique
 -- just to draw sprites bigger)
 for i=1,#_str do
  num=asc(sub(_str,i,i))+160
  sy=flr(num/16)*8
  sx=(num%16)*8
  sspr(sx,sy,8,8,_x+(i-1)*16,_y,16,16)
 end
 pal()
end
-------------------------------
function draw_rwin(_x,_y,_w,_h,_c1,_c2)
 -- would check screen bounds but may want to scroll window on?
 if (_w<12 or _h<12) return(false) -- min size
 -- okay draw inside
 rectfill(_x+3,_y+1,_x+_w-3,_y+_h-1,_c1) -- x big middle bit
 line(_x+2,_y+3,_x+2,_y+_h-3,_c1) -- x left edge taller
 line(_x+1,_y+5,_x+1,_y+_h-5,_c1) -- x left edge shorter
 line(_x+_w-2,_y+3,_x+_w-2,_y+_h-3,_c1) -- x right edge taller
 line(_x+_w-1,_y+5,_x+_w-1,_y+_h-5,_c1) -- x right edge shorter
 --now the border left side
 line(_x,_y+5,_x,_y+_h-5,_c2) -- x longest leftmost edge
 line(_x+1,_y+3,_x+1,_y+4,_c2) -- x 2 left top
 line(_x+1,_y+_h-4,_x+1,_y+_h-3,_c2) -- x 2 left btm
 pset(_x+2,_y+2,_c2)  -- x 1 top dot
 pset(_x+2,_y+_h-2,_c2)  -- x 1 btm dot
 line(_x+3,_y+1,_x+4,_y+1,_c2)  -- x 2 top curve
 line(_x+3,_y+_h-1,_x+4,_y+_h-1,_c2)  -- x 2 btm curve
 --now the border right side
 line(_x+_w,_y+5,_x+_w,_y+_h-5,_c2) -- x longest leftmost edge
 line(_x+_w-1,_y+3,_x+_w-1,_y+4,_c2) -- x 2 left top
 line(_x+_w-1,_y+_h-4,_x+_w-1,_y+_h-3,_c2) -- x 2 left btm
 pset(_x+_w-2,_y+2,_c2)  -- x 1 top dot
 pset(_x+_w-2,_y+_h-2,_c2)  -- x 1 btm dot
 line(_x+_w-3,_y+1,_x+_w-4,_y+1,_c2)  -- x 2 top curve
 line(_x+_w-3,_y+_h-1,_x+_w-4,_y+_h-1,_c2)  -- x 2 btm curve
 -- top and bottom!
 line(_x+5,_y,_x+_w-5,_y,_c2) -- x top
 line(_x+5,_y+_h,_x+_w-5,_y+_h,_c2) -- x bottom
end
-------------------------------
-- draw simple rectangular window
-- with a frame
function draw_win(_x,_y,_w,_h,_c1,_c2)
 rectfill(_x,_y,_x+_w,_y+_h,_c1)
 rect(_x,_y,_x+_w,_y+_h,_c2)
end
------------------------------
--map collide by enargy
function issolid(x,y,flag)
 local tx = flr(x/tw)
 local ty = flr(y/th)
 tileid = mget(tx,ty)
 return fget(tileid,flag)
end
__gfx__
00012000606660666066606660666066606660666066606616666661feeeeee87bbbbbb30000004000000030000300000b0dd030777777674f9f4fff7999a999
07d1257000000000000000000000000000000000007777006d6666d6e8888882b3333331040000000300000003000030d3000b0d76777777fffff9f49999979a
057d57d0666066606660566060333306608888066676d75062444426e8811882b33773310000040000000300000003b0000b030077777677ff4fffff99a99999
22566d11000000000000000000333300008888000077770064222246e8866882b3366531000400000003000000b00bb0b0030000777677779fff9ff999997997
11d6652206660666066605666033330660888806067d675664442446e8877282b3355131400000003000000030b30b003000dd0b677777774fffff9fa9999979
0d75d750000000000000000000331300008818000077770064222a96e8822182b33113310000000400000003003b00030b00000377777776ff4fffff999a9999
07521d70660666066606660660331306608818066605550664424446e8888882b33333310400000003000000030b00000300b00076777777ff9ff9ff99999799
0002100000000000000000000033330000888800000000006422224682222222311111110000400000003000000030000dd030b077776777f9ffff4f979999a9
111c111c7ccc7cc70000000005500550005070500500700000dddd00656565650d0aa000000aa000760000000766660006566650777777500007a90000000070
11c111c177ccc7cc000000000765676005076005000760050dddddd0666666650df99f000df99f0006500000766550000666666576666650000a0000000006d6
1c111c11c77ccc7c00000000076007605076660050766700dddddddd662226650de11e000de11e0700650000664500000659405676565650000aa90000006d60
c111c111cc77ccc7076007600765676050766605007676000555555066666665d55660070d66660200065006650450000009400076666650000a00000006d000
111c111c7cc77ccc07656760076007600766767007667670066666606655566509066602d5d6609200006560650045000009400076565650000a0000076d0000
11c111c1c7cc77cc0760076000000000576676655761166506dd6c6066111665000cc092090cc00200000650600004500009400076565650007aa9007dd6d000
1c111c11cc7cc77c1765676100000000766767667610016606dd6c606611166500c11c0200c11c000000604500000045000940000766650000a00a006d06d000
c111c1117cc7cc771d211d2100000000565655656610016606dd6660cc444ccc044004400440044000060004000000040009400000555000009aa900076d0000
0bb3b3b030bbb0030150051001500510940000499999999994000049000099997667060000065000d777777dd55550000076dc0000999900000000000007d000
bb3b3b350bbb3300157556511575515194544449444444444444444400094444641605000065d650566666657665d650075555d0094444900000000000766d00
b3b33333bb3bbb305757651557576515945555490550055004555550009440006666666065616560566666657661656001c6dc109444444900000000076666d0
b3333335b3b3b33505766650057656509400004904500450045004500944000011111156006176d011111155766176d007cc6d50999aa9990000000000044000
0b4334503bbb3b3505666650056565509400004904500450045004509945400076d176d57661110076d176d57661110007cc6d50955aa5590007d00000094000
0009450033b3b355575665155516551594544449045004500454445094405400656165606161d650656165607661d65007cc6d509544444900766d0000094000
0009450003335550156551511155515194555549444444444455554494000544d650d65064616560d650d6507661656007cc6d5095444449076666d000094000
095454540033350301500510015005109400004999999999940000499400004900000000766176d000000000d55176d00066d500999999990004400000094000
000990000777770000077000007dd500007665000554455000007000067666500007000099999999750705607776777677777776777777767777777677777776
049aa94075666660007667000007500007666650554444550000770000565100007a900090040405565656507665766576666665766666657766665576666665
49a99a940065d56000077000077665507666666545444454000076700067650007aaa90094444445057775007665766576555565766776657676656576666665
9a9aa9a900666660076666707766665576565565455a9554000077770067650007aaa90090004005767766606555655576566765767665657667566576666665
9a9aa9a900655d60765555677666666576666665411a911407007000006765000a99990094444445057665007677767776566765767665657667566576666665
49a99a94006666606500005676666665765565654445544476666667006765007556559095555555565656506576657676577765766556657676656576666665
049aa940006777775650056577666655766666654444444407666670006765000aaaa90000055000750605606576657676666665766666657766665576666665
00499400005555500567765007766550655555555444444500777700067666500000000005064005000000005565556565555555655555556555555565555555
00000000000005d9007a4200000000000000000900009999900a000000000000000000000049400000040000a7a9999900076000000000000001000000000000
0e82e82000555d5507a9942000000000000909aa009999aa09000a900009000009009090049a94000049400004a994400007610000111000001c10000eeeee20
e788888205d6d5550a999940000000000000aaaa09a9aaaa00009000008aa800008aa80049a7a940049a9400097999400007610001ccc10001c7c1007262626c
e88888825d7ddd500a99994000000009090a9a9a099a9909a000000000a77a9009a77a009a777a9449a7a94009a99990707765071c777c1001c7c10015252520
0888882056dddd500a9999400000a09a00a9a9a999a997900090000009a77a0000a77a9049a7a940049a9400099a99407667665601ccc10001c7c10002e50000
0088820055ddd5500ae999400000099a09aa9a7799a970000a000000008aa800008aa800049a940000494000009994007676656500111000001c10005e200000
000820000555550007fe9420000099a70aa9a7779aa090000900000000009000090900900049400000040000000a900007655651000000000001000025200000
0000000000555000007942000009aa779aaa97779aa90000000000000000000000000000000400000000000007a9994000766510000000000000000000000000
000550000005500005677650000550000567765000ddd0000000000000033000060aa05065656565757575751111111111111111111111112888888212888821
00566500005666000567765000566500567777650d666d0003333330033bb33006aa00505dddddd66060606015555555555555555555555188eeee88288ee882
0567765066677760567777650567765067766776d67666d033bbbb3333b77b3306a00a506d5555d5575757571565505050505050505556518ea77ae888eaae88
5677776577777776567777655675576577655677d66666d03b7777b33b7777b30600aa505d5cc6d6060606061555550505050505050555518e7777e88ea77ae8
6777777677777777677557765675576556500565dd666d503b7777b33b7777b3060aa0506d5cc6d5757575751555505050505050505555518e7777e88ea77ae8
77777777666775577777777705677650050000500dddd50033bbbb3333b77b3306aa00505d5666d6606060601555550505050505050555518ea77ae888eaae88
56666665005677505666666500566500000000000055500003333330033bb33006a00a506dddddd55757575715655050505050505055565188eeee88288ee882
05555550000566000555555000055000000000000000000000000000000330000600aa5055555555060606061555555555555555555555512888888212888821
00aaaa000007000000dddd0000dddd000022220050222205bb0bb0bb0b0bb0b00000bbb000000000000990003bb1000000666000000770000076660000766600
0a999940000e00000d7cc7d00d7cc7d0552882550528825003abba30b3abba3b000b1b1ba000bbb000007900b3b3b10006000600007755000702826007282060
a979979400e88000d70cc07dd77cc77d22588522225885220bbbbbb00bbbbbb00a0bbbbbb00b1b1b009a9990bb3bbb1060700060077665500602825006282050
a71991740e111800d77cc77dd70cc07d271881722708807203baab3003baab30b00b3707b00bbbbb0979a99913b3b3b160000060775555550066550000665500
a9999994e8191880dccccccddccccccd2888888228888882b003300b00033000b00bbb00b00b370799a999790bbb3bb160000060775e275507d75d6007d75d60
a992299408111820dcc11ccddcc11ccd28881882288188820b3bb3b00b3bb3b0bb0bbbb0bb0bb3309997aa9901b3b3b106000600775227557d7dd5d67d7dd5d6
b30880d5008882000dccccd00dceecd0028888299288882000bbbb00b0bbbb0b0bb0bbbbbbb0bbbb0999a990001bbb3000666000777776557d7dd5d57d7dd5d5
ff0ee0660008200000dddd0000dddd0099222290092222990bb33bb000b33b0000bbbbb00bbbbbb0009a99000001110b00000000055555500665565006655650
08000080a00700b00056650000077000004aa4000077770000777700000000076776d7765000000000d7cd0009aaaa900000567700a7777d0000700000077000
0000000007a00bba056766500076650044a77a4407666670000666700000007676675665650000000d77ccd09a1aa1a9000567760a6666dd0000670000700700
00880800077bba7b5676666500766500aa7777aa71166117a0776657000007667667566566500000d777cccd9a5aa5a905677775a7777d5d0000667007000070
8008e808b0b7aab067666666007665004aa77aa4712662177a6666660000766676675665666500007777cccc9aaaaaa95677775076666d5d6665666770000007
008ee80000ba7ab0666666660076650004a77a40066116606d666666000766667667566566665000dcccdddd09affa900567777676666d5d6665666700077000
000888000b7b77ab56666665007665004a7aa7a405666650d05661150076666676675665666665000dccddd09a9aa9a95677766576666d5d0000667000700700
000000800ab0b7aa05666650076666504aa44aa4006116000006665007666666766756656666665000dcdd00a900009a6777655076666dd00000670007000070
08008000ab0000a00056650006555550aa4004aa0056650000665000766666666552155666666665000dd0009a9009a9776650006ddddd000000700070000007
2002821000028210202000000006822d02822222020220d000000000000000000000000000000000007665000076650005555555555555555555555055677655
0211111122111111022282100026cdcd1111110002200d0000000000000000000000000000000000075006500750065055666666666666666666665556555565
11ddcdcd01ddcdcd001111110216ddddddcdcddd21ddd00002000000000000000000000000000000065006500650000056676767676767676767766556677665
006ddddd106ddddd66ddcdcd0016dddd66666d0081cddd0022ddd000000000000000000000000000766666657666666556777777777777777777776556677665
006d5ddd006d5ddd600ddddd0015ddd066dddd001ddddd008dddd000002282000202820002222200766166657663666556777676767676767676776555677655
0065111d0065111d0005ddd00052111056d111111c66d1111dddd1000221166600211110002282dd766166657663666556766676666666666767766556555565
00520010005200100552211100520010052200000d6661001d66611100666c10011dddd000111110766666657666666556776756666666667577666556677665
0502001005020010500200100502001000502000000552221d666222666dddc066666666666dddd0655555556555555556766665555555555667766556677665
0028210020000000002821002200000002228200005000000000000000000000c0c6cc0000777700056650000000000056677665555575555566765555555555
02111110222821000211111002282100221116660205002002022210202221000cccccc0071111605600650007a00a7056776665565755665555555556677665
d21ddcd60111111021ddcdcd0111111000666c10022560220022822102282210cdd7d7d071111115607006000a9009a056677665565757676565565655555555
d1dd66660ddddcd0666ddddd0dddcdc0066dddcd101d5682011111111111111006ddddd071100115600006000000000056776665575757777576755757777775
00d66d00066dddd06066dd00066dddd05555dd0011ddd62206ddcdcd0ddcdcd00d665ddd71100115560065000000000056677665575756766557675675555557
202211000066dd00001221000066dd00021dd00000dd661260d5dddd6d5dddd000c5ccc071111115056694500a90000056776665565756666565565655677655
02000010002212000110020000221100200100000dd6dc116552ddd16522dd11005c00c0061111500000094507a0000056677665565755665555555556776665
0000000100012000000000200002100000100000d000c1105220011152220001050c00c000555500000000940000000056776665555575555567665556677665
0028226000000000628210000022000022000000222200001112000006822d0026822d0077777777002820000077770056776675555755555677666556776665
002222600028220026111100081d0000820d0000228110001112800026cdcd0016cdcd0000000000028e8200076566d056676756665575656577666556677665
061221600022222006dcdc00621d0000612d000011dcd00011dc600016dddd0006dddd000600600608e7e8007665666d56777667676575657667766555776655
06d11dd0061221160ddddd00611c0200611c0200d66665d5dddd656506dddd0006dddd000000000008eee8007665556d56677777777575757777766575555557
0dd1d1d00dd11ddd05dddd006cdd52016cdd5201dddd0d00ddd6060005ddd00005ddd00000500500028e82007666666d56667676767575756767666557777775
005111000dd1d1dd522dd0d0d66d5211d6665211211100001112000005221110052211100000000000282000076666d056666666666575656666666555555555
0015000000551110220100000d6652100dd6521020001000100020005002000150020001010100100028200000dddd0055666666665575656666665556677665
00105000001051000110000000dd510000dd51002000010010000200500000005000000000000000002820000000000005555555555755555555555055555555
062281100000000000400000202821000028210000282100000000000000000000000000000000007777777711111100566666660015d0005666666500000000
6d6dcdc00000122240900040111111102111111021111110030100000606330000003300000000007555555717777610655115510015d0006666666600000000
506dddd0000dd18090a040900ddbdbd00ddbdbd01ddbdbd003013300663138300031383000077000756556571777610065155551001d50006000000601111110
506dddd0000ddd11a00090a40666dddd1666dddd0666dddd00313830633313300633133000766700755555571776610051155551000d15006000000605555550
5006ddd000ddddd10405a00900d5dd0000d5dd0000d5dd00003313303331301363313013005665007555555717667610655115110001d5006000000605555550
00021111002d6dd00905004a005111000052110000521100033130131110000011100000000550007565565716116761655551510001d0006000000605155150
000200010222166d0a5000900520001005002000052201001110000010000000100000000000000075555557010016716555515100105d006000000605111150
0002000020011006dd1110a05020000050010000500001001000000000000000000000000000000077777777000001105111111500150d000000000005111150
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
55555555555775555775775557757755555775555775577557777555555775555557755555577555775557755557755555555555555555555555555555555775
55555555555770555770770577777775557777755770770057777055555770555577005555557755577577005557705555555555555555555555555555557700
55555555555770555500500557707700577770005507700555770775555500555577055555557705777777755777777555555555577777755555555555577005
55555555555500555555555577777775550777755577077557707700555555555577055555557705577077005557700055775555550000005555555555770055
55555555555775555555555557707700577777005770077057707705555555555557755555577005770057755557705555770555555555555577555557700555
55555555555500555555555555005005550770055500550055775775555555555555005555550055500555005555005557700555555555555577055555005555
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
55777755555775555777775557777755555777755777777555777755577777755577775555777755555775555557755555557755555555555577555557777755
57700775557770555500077555000775557707705770000057700005550007705770077557700775555770555557705555577005557777555557755555000775
57705770555770555577770055577700577007705777775557777755555577005577770055777770555500555555005555770055555000055555775555577700
57705770555770555770000555550775577777705500077557700775555770055770077555500770555775555557755555577555557777555557700555550005
55777700557777555777777557777700550007705777770055777700555770555577770055777700555770555557705555557755555000055577005555577555
55500005555000055500000055000005555555005500000555500005555500555550000555500005555500555577005555555005555555555550055555550055
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
55777755557777555777775555777755577777555577777555777775557777555775577555777755555577755775577557755555575555755775577555777755
57700775577007755770077557700775577007755770000057700000577000055770577055577005555557705770770057705555577557705777577057700775
57707770577777705777770057705500577057705777775557777755577077755777777055577055555557705777700557705555577777705777777057705770
57705000577007705770077557705775577057705770000557700005577057705770077055577055577557705770775557705555577777705770777057705770
55777775577057705777770055777700577777005577777557705555557777005770577055777755557777005770577555777775577007705770577055777700
55500000550055005500000555500005550000055550000055005555555000055500550055500005555000055500550055500000550055005500550055500005
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
55777755557777555777775555777775577777755775577557755775577557755775577557755775577777755777775557755555577777555557755555555555
57700775577007755770077557700000555770005770577057705770577777705577770055777700550077005770000555775555550077055577775555555555
57777700577057705777770055777755555770555770577057705770577777705557700555577005555770055770555555577555555577055770077555555555
57700005577077005770077555500775555770555770077055777700577007705577775555577055557700555770555555557755555577055500550055555555
57705555557707755770577057777700555770555577770055577005570055705770077555577055577777755777775555555775577777055555555557777775
55005555555005005500550055000005555500555550000555550055550555505500550055550055550000005500000555555500550000055555555555000000
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
__gff__
000101010181010001000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000c0000040400000000000000000000000000000000000000000000000000000000000c0c00000000000000000001000000000000000001000000
0000000000000000000001010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f09000000000000000200000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f09000000000000000200000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f0f09000000000000000200000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f0900000000790000770200000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003c3c3c0c0b0c0b0c0000000000000000000000000f09000000005b5c5c5c5d00000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c0b000000000000000000000000000000000000000000000000000000000000000000000000000000000000003b00000000000c0b0000000000000000000000000f09000000005b5c5c5c5d00000000
00000000000000000000001010101010100000000000000000000000000000000000000d0d0d0d0d0d0d0d0d0d0d0000000a0b000000000000000000000000000000000000000000000000000000000000000000000000000000003c3c3c00000000000f09000000000000bcbcbcbcbc0f090000000000000000000202020202
00000000000000000000770201010101010000000000000000000000000000000000000d0d0d0d0d0d0d0d0d0d0d000000000a0b0000000000000000000000000000000000000000000000000000000000000000000000000000003b000000000000000f0900000000000002000000000f090000000000000000000000000000
00000000000000000000000200000000010000000000000000000000770d0d0d0000000d0d0d0d0d0d0d0d0d0d0d00000000000a0b0000000000000000000000000000000000000000000000000000000000000000000000003c3c3c000000000000000f0900000000000002000000000f090000000000000000000000000000
0000000000000000000000020101010101000000000000000000770d0d0d0d0d0000000d0d0d0d0d0d0d0d0d0d0d0000000000000b0000000000000000000000000000000000000000000000000000000000000000000000003b00000000000000000f090000000000000002000000000f090000000000000000000000000000
bcbcbcbcbcbcbcbcbcbcbcbcbcbcbcbc0000000000000000000d100d0d0d10100000000d0d0d0d0d0d0d0d0d0d0d0000000000000a0b00000000000000000000000000000000000000000000000000000000000000000000003b00000000000000000f090000000000000002000000000f090000000000000000000000000000
00000000000000000000000000000000000000000000000010101010100d0d100000000000000000240000000000000000000000000cbcbcbcbcbcbcbcbcbcbcbcbcbcbcbcbc3d00003dbcbcbcbcbcbcbcbcbcbcbcbcbcbcbcbc00000000000000000f090000000000000002000000000f090000000000000000000000000000
000000000000000000000000000000000000000000000010100d0d0d0d0d0d0d0000000000000000240000000000000000000000000000000000000000000000000000000000020000020000000000000000000000000000000000000000000000000f0900000000000000020000000000bcbcbcbcbcbcbcbcbcbcbcbcbcbcbc
0000000000000000000000000000000000000000000000100d0d0d0d0d10100d0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c000000000000000000000000000000000000000000000200000200000000000000000000000000000000000000000000000f090000000000000000020000000000000000000000000000000000000000
000000000000000000000000000000000000000000001010100d0d0d0d10101000000000000000000000000000000000000000000000000000000000000000000000000000000200000200000000000000000000000000000000000000000000000f090000000000000000020000000000000000000000000000000000000000
00000000000000000000000000000000000000000000101010100d0d1010100d00000000000000000000000000000000000000000000000000000000000000000000000000000200000200000000000000000000000000000000000000000000000f090000000000000000020000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000200000000000000000000bc000000bc000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007373737300437400004e0000490000003f3f3f3f3f3f3d00003d3f3f3f3f3f3f00000000bc000000bc000000000000000000000000000000790000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008c8d8d8e0048464974744843487400003b00000000000000000000000000003b02020202bc000000bc02020202020202020202020202025b5d7900000000000000000000000000000000000000000000
0000000202020202020202020202020202020202020202020202020202020202020202025b5c5c5c5c5c5d0202020202ac8d8dae0000744848467474474600003b00000000000000000000000000003b020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000002000000000000000000000000000000ac8d8d9e8d8dae0000bd00bd00000000000000000000000000000000005b5c5c5c5d43744900484648437400003b00000000000000000000000000003b020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000200000000000000000000000000000000000073000000000d0d0d0d0d000000000000000000000000000000005b5c5c5c5d00464900000000494600003b00000000000000000000000000003b020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020200000000000000000000000000000000000000000000000d0d0d0d0d000000000000000000000000000000000d0d0d0d0000000000000000000000003b00000000000000000000000000003b020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000d0d0d0d0d000000000000000000000000000000000d0d0d0d0000000000000000000000003b00000000000000000000000000003b0200000000000000000000000000000000000000000000000000000000000000000000000000000000000d0d0d0d0d00
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000be000000000000000000000000003b00000000000000000077790000003b0200000000000000000000000000000000000000000000000000000000000000000000000000000000000d0d0d0d0d00
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d0d0d0000770d79000000000000000000000000bcbcbcbcbcbcbcbcbcbcbcbcbcbcbcbc020000000000000000000000000000000000000000000000000000000000000000000000000000000000000024000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d0d0d00770d0d0d790000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000bcbcbcbcbcbcbcbcbcbcbcbcbcbcbcbc
00000000000000bf330033bf0000000000000000000000000000000000000000000000000000000000000700003700000000000000000000000000000000000000000000000000000000000000000000bcbcbcbcbcbcbcbcbcbcbcbcbcbcbcbcbcbcbcbcbcbcbcbcbcbcbcbcbcbcbcbc00000000000000000000000000000000
bcbcbcbcbcbcbcbcbcbcbcbcbcbcbcbcbcbcbcbcbcbcbcbcbcbcbcbcbcbcbcbcbcbcbcbcbcbcbcbcbcbcbcbcbcbcbcbc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000bc000000bc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000bc000000bc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000bc000000bc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100002e1502e1502f1502f1502f150351503715000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
000200002e5502e5503555035550166003a5503a55037500345003350034500385000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000200001c620385503455031550305502e5502d5501d6201d6201d6001d600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000006500065000650006551305014050140501405014050140501405013050110500e0500b0500905008050070500605005050050500505006050070500105001030010230000000000000000000000000
000400000024000231062002100000240002310022100213190001a00023000280000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300002a750267502a7500070032750377003970039700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
0004000036630236701f6711c6511b6511b6511a6511a6511a630176310e631066310463102631016310063100631006110061100611006110061100611006110061101600006000060000300003000030000300
000200000b3240d331103411c341233412634127341293412c3312e32500300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
000700180062307623000000762300623000000000000623076230000007623006230000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00050000307342b751237511d75117751127510d75108751037310271501713007050c7000a700077000670004700027000170000700007000070000700007000070000700017000070000700007000070000700
000200002f3402f3412f33136334363413634136331363313632136321363213631136315383003f3000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
00010000312502b250252502025019250122500e2500e6300e6300e6351520010200072000420000200002000d20009200082000820000200002000120026100121001e100061000d10019100251000c10024100
0006000019150201501c150231502313519130201301c130231302312519120201201c120231202311519110201101c1102311023115001000010000100001000010000100001000010000100001000010000100
000900000b6500b6500b6531c6001c6501c650156300e630096300763005610036100161001615000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400001c6301c630232541c35120353173501b3501935422230246002460025600266002660027600156000f6000b6000760006600056000460004600046000020000200002000020000200002000020000200
0003000028630286301e6501a650186501664014640106400f6400c630096300663005630026100161001610016102750020500235002c5002e50022500295002e500325001f5002a5002d500265002a5001c500
000300000863111631206003365032651306512a651226511a651136410d641086410463101631006110061500000000000000000000000000000000000000000000000000000000000000000000000000000000
0003000017630106300e6500e6301063213652186521e6522a6523663236632306323062221622126220661200612006120161200612006150060000600006000060000600006000060000600006000060000600
010c00001125411255052550000000000112541125505255000000000011254112550525500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100000705005050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200000205004050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010300000005002050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010f000005135051050c00005135091351c0150c1351d0150a1351501516015021350713500000051350000003135031350013500000021351b015031351a0150513504135000000713505135037153c7001b725
010f00000c03300000300152401524615200150c013210150c003190151a01500000246153c70029515295150c0332e5052e5150c60524615225150000022515297172b71529014297152461535015295151d015
010f000007135061350000009135071351f711000000510505135041350000007135051351c0151d0150313503135021350000005135031350a1050a135000000113502135031350413505135000000a13500000
010f00000c033225152e5153a515246152b7070a145350150c003290153200529005246152501526015220150c0331e0251f0252700524615225051a0152250522015225152201522515246150a7110a0001d005
011400000c0330253502525020450e6150252502045025250c0330253502525020450e6150252502045025250c0330252502045025350e6150204502535025250c0330253502525020450e615025250204502525
011400001051512515150151a5151051512515150151a5151051512515150151a5151051512515150151a5151051512515170151c5151051512515170151c5151051512515160151c5151051512515160151c515
011400001c5151e5151a515150151c5151e5151a015155151c5151e5151a515150151c5151e5151a015155151c5151e51517015230151c5151e51517015230151c5151e515165151c0151c5151e515160151c515
011400000c0330653506525060450e6150652506045065250c0330653506525060450e6150652506045065250c0330952509045095350e6150904509535095250c0330953509525090450e615095250904509525
0114000020515215151c5151901520515215151c0151951520515215151c5151901520515215151c0151951520515215151c0151901520515215151c01525515285152651525515210151c5151a5151901515515
01180000021100211002110021120e1140e1100e1100e1120d1140d1100d1100d1120d1120940509110091120c1100c1100c1100c1120b1110b1100b1100b1120a1100a1100a1100a11209111091100911009112
01180000117201172011722117221d7201d7201d7221d7221c7211c7201c7201c7201c7221c72218720187221b7211b7201b7201b7201b7221b7221d7221d7221a7201a7201a7201a7201a7221a7221672016722
011800001972019720197221972218720187201872018720147201472015720157201f7211f7201d7201d7201c7201c7201c7221c7221a7201a7201a7221a7251a7201a7201a7221a72219721197201972219722
011800001a7201a7201a7221a7221c7201c7201c7221c7221e7201e7202172021720247212472023720237202272022720227202272022722227221f7201f7202272122720227202272221721217202172221722
0118000002114021100211002112091140911009110091120e1140e1100c1100c1120911209110081100811207110071100711007112061110611006110061120111101110011100111202111021100211002112
0118000020720207202072220722217202172021722217222b7212b72029720297202872128720267202672526720267202672026720267222672228721287202672026720267202672225721257202572225722
010e00000c0231951517516195150c0231751519516175150c0231951517516195150c0231751519516175150c023135151f0111f5110c0231751519516175150c0231e7111e7102a7100c023175151951617515
010e000000130070200c51000130070200a51000130070200c51000130070200a5200a5200a5120a5120a51200130070200c51000130070200a51000130070200c510001300b5200a5200a5200a5120a5120a512
010e00000c0231e5151c5161e5150c0231c5151e5161c5150c0231e5151c5161e5150c0231c5151e5161c5150c0230c51518011185110c0231c5151e5161c5150c0231e7111e7102a7100c023175151951617515
010e0000051300c02011010051300c0200f010051300c02011010051300c0200f0200f0200f0120f0120f012061300d02012010071300e02013010081300f0201503012020140101201015030120201401012010
018800000074400730007320073200730007300073200732007300073200730007320073000732007320073200732007300073000730007320073000730007300073200732007300073000732007300073200732
01640020070140801107011060110701108011070110601100013080120701106511070110801707012060110c013080120701106011050110801008017005350053408010070110601100535080170701106011
018800000073000730007320073200730007300073200732007300073200730007320073000732007320073200732007300073000730007320073000730007300073200732007300073000732007300073200732
0164002006510075110851707512060110c0130801207011060110501108017070120801107011060110701108011075110651100523080120701108017005350053408012070110601100535080170701106511
010a000024045270352d02523045260352c02522045250352b02522035250352b02522035250252b01522725257252b71522715257152b71522715257152b7151700017000170001700017000130000c00000000
010a000021705247052a7052072523715297151f72522715287151f71522715287151f71522715287151f71522715287151f71522715287151f70522705287051770017700177001770017700137000c70000700
010c00000f51014510185101b510205102451011510165101a5101d510225102651013510185101c5101f5102451028510285102851028510285102851028515240042450225504255052650426502265050e500
010c000014730187301b730207302473027730167301a7301d730227302673029730187301c7301f73024730287302b730307403073030730307303072030715247042470225704257052670426702267050e700
011200000843508435122150043530615014351221502435034351221508435084353061512215054250341508435084350043501435306150243512215034351221512215084350843530615122151221524615
011200000c033242352323524235202351d2352a5111b1350c0331b1351d1351b135201351d135171350c0330c0332423523235202351d2351b235202352a5110c03326125271162c11523135201351d13512215
0112000001435014352a5110543530615064352a5110743508435115152a5110d43530615014352a511084150d4350d4352a5110543530615064352a5110743508435014352a5110143530615115152a52124615
011200000c033115152823529235282352923511515292350c0332823529216282252923511515115150c0330c033115151c1351d1351c1351d135115151d1350c03323135115152213523116221352013522135
0112000001435014352a5110543530615064352a5110743508435115152a5110d435306150143502435034350443513135141350743516135171350a435191351a1350d4351c1351d1351c1351d1352a5011e131
011200000c033115152823529235282352923511515292350c0332823529216282252923511515115150c0330c033192351a235246151c2351d2350c0331f235202350c033222352323522235232352a50130011
011600000042500415094250a4250042500415094250a42500425094253f2050a42508425094250a425074250c4250a42503425004150c4250a42503425004150c42500415186150042502425024250342504425
011600000c0330c4130f54510545186150c0330f545105450c0330f5450c41310545115450f545105450c0230c0330c4131554516545186150c03315545165450c0330c5450f4130f4130e5450e5450f54510545
0116000005425054150e4250f42505425054150e4250f425054250e4253f2050f4250d4250e4250f4250c4250a4250a42513425144150a4250a42513425144150a42509415086150741007410074120441101411
011600000c0330c4131454515545186150c03314545155450c033145450c413155451654514545155450c0230c0330c413195451a545186150c033195451a5451a520195201852017522175220c033186150c033
010b00200c03324510245102451024512245122751127510186151841516215184150c0031841516215134150c033114151321516415182151b4151d215224151861524415222151e4151d2151c4151b21518415
010200002067021670316602f65031650336503365033650386503f6503f650326502f6502f650006002f6502e6502d650006002b650296502760024650216001e65019600116500a60000630066000161000010
010200000e6510c6530a6520b653056530000000000000000e6510c6530a652000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110000013535000002b5070000037535000001f507000002b5350000000000000001f53500000000000000013505000002b5070000037535000001f507000002b5350000000000000001f535000000000000000
011000200062200622006220062202622026220262202622006220062200622006220262202622026220262200622006220062200622026220262202622026220062200622006220062202622026220262202622
__music__
00 16 17 43 44
00 16 17 43 44
01 16 17 43 44
00 16 17 43 44
00 18 19 43 44
02 18 19 43 44
00 1a 42 43 44
01 1a 1b 43 44
00 1a 1b 43 44
00 1a 1c 43 44
00 1a 1c 43 44
02 1d 1e 43 44
01 1f 20 43 44
00 1f 21 43 44
00 1f 20 43 44
00 1f 21 43 44
00 22 23 43 44
02 1f 24 43 44
01 25 26 43 44
00 25 26 43 44
02 27 28 43 44
00 29 2a 43 44
03 2b 2c 43 44
04 2d 2e 43 44
04 2f 30 43 44
01 31 32 43 44
00 31 32 43 44
00 33 34 43 44
02 35 36 43 44
01 37 38 43 44
00 39 3a 43 44
00 37 3b 43 44
02 39 3b 43 44
03 3e 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
