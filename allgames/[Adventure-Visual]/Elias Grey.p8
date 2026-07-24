pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--draw

function _draw()
 if game.flash then
  game.flash=false
  rectfill(0,0,127,127,game.flash_color)
  return
 elseif game.ended then
  rectfill(0,0,127,127,0)
  return
 end
 
 if game.shake then
  camera()
  local half=game.shake_amnt/2
  camera(rnd(game.shake_amnt)-half,rnd(game.shake_amnt)-half)
  game.shake_amnt-=game.shake_decay
  if game.shake_amnt<=0 then
   game.shake=false
   camera()
  end
 end
 
 draw_bg()
 draw_jewels()
 draw_renderables()
 draw_actions()
 
 if game.ending=="grave" then
  game.grave_t+=1
  if game.grave_t<30 then
   local vert=64*(1-(30-game.grave_t)/30)
   rectfill(
    game.grave.x,
    game.grave.y-vert,
    game.grave.x,
    game.grave.y+vert,
    7)
  else
   local hor=64*(1-(60-game.grave_t)/30)
   rectfill(
    game.grave.x-hor,
    0,
    game.grave.x+hor,
    127,
    7)
  end
  game.rose:draw()
 end
 
 draw_dialogue()
 
 if game.debug then
  for r in all(game.renderables) do
   circ(r.x,r.y,1,8)
  end
 
  local wipe_text_1=""
  local wipe_text_2=""
  for i=1,#debug do
   local txt=debug[i]
   if txt==nil then
    txt="nil"
   end
   
   txt=txt..""
   wipe_text_1=""
   wipe_text_2=""
   for x=1,#txt do
    wipe_text_1=wipe_text_1.."0"
    wipe_text_2=wipe_text_2.."1"
   end
   
   local x=2
   local y=2+(i-1)*8
   print(wipe_text_1,x,y,0)
   print(wipe_text_2,x,y,0)
 	 print(txt,x,y,8)
  end
	end
end

function draw_bg()
 rectfill(0,0,128,128,game.bg_color)
end

function draw_jewels()
 for stone in all(game.room.stones) do
  if stone.jewel_pos!=nil then
   if stone.read==false then
    circ(stone.jewel_pos[1],stone.jewel_pos[2],1,stone.color)
   end
  end    
 end
end

function draw_renderables()
 for i=1,#game.renderables do
  --if game.renderables[i]!=nil then
   game.renderables[i]:draw()
  --end
 end
end

function draw_actions()
 if game.act_text_1!=nil and #game.act_text_1>0 then
  spr(2,20,118)
  print(game.act_text_1,30,120,game.font_colors.normal)
 end
 
 if game.act_text_2!=nil and #game.act_text_2>0 then
  spr(3,80,118)
  print(game.act_text_2,90,120,game.font_colors.normal)
 end
end

function draw_dialogue()
 if game.dialogue!=nil then
  draw_dbg()
  draw_dtxt()  
 end
end

function draw_dbg()
 local p=game.d_box.padding
 local b=p-game.d_box.border_w
 rectfill(
  game.d_box.left-p,
  game.d_box.top-p,
  game.d_box.right+p,
  game.d_box.bottom+p,
  game.d_box.border_color)
 
 rectfill(
  game.d_box.left-b,
  game.d_box.top-b,
  game.d_box.right+b,
  game.d_box.bottom+b,
  game.d_box.color)
end

function draw_dtxt()
 local ch_count=0
 local ti_prog=game.d_box.ti_progress
 for i=1,#game.d_box.lines do
  local txt=game.d_box.lines[i]..""
  if game.d_box.type_in then
   if ti_prog<ch_count then
    txt=""
   elseif ch_count+#txt>ti_prog then
    txt=sub(txt,1,ti_prog-ch_count)
    end
   ch_count+=#txt
  end
  
  print(	
   txt,
   game.d_box.left,
   game.d_box.top+(i-1)*7,
   game.d_box.font_color)
 end
end

function split(string)
 local words={}
 local word=""
 for i=1,#string do
  local char=sub(string,i,i)
  if char==" " then
   add(words,word)
   word=""
  else
   word=word..char
  end
 end
 add(words,word)
 return words
end

function quick_sort_by_y(array,p,r)
 if 0<r-p then
  local q=partition_by_y(array,p,r)
  quick_sort_by_y(array,p,q-1)
  quick_sort_by_y(array,q+1,r)
 end
end

function partition_by_y(array,p,r)
 local q=p
 for i=p,r-1 do
  if array[i].y<=array[r].y then
   swap(array,i,q)
   q+=1
  end
 end
 swap(array,r,q)
 return q
end

function swap(array,first,second)
 local temp=array[first]
 array[first]=array[second]
 array[second]=temp
end
-->8
--init

function _init()
 debug={}
 --music(0,8)
 game=
 {
  ended=false,
  t=0,
  debug=false,
  bg_color=5,
  act_text_1="",
  act_text_2="",
  interaction=nil,
  font_colors=
  {
   normal=7
  },
  interact=nil,
  interactables={},
  renderables={},
  collidables={},
  bounds=
  {
   max={x=123,y=127},
   min={x=4,y=12}
  },
  player=
  {
   has_rose=false,
   x=60,
   y=100,
   w=8,
   h=6,
   speed=1.5,
   facing=3,
   moving=false,
   first_facing=-1,
   act_dist=6,
   weapon=nil,
   bloodied=false,
   d_offset={x=-4,y=-14},
   stand_side_sprite=make_sprite(23,1,2,false),
   walk_t=0,
   walk_side_clip=make_clip(
    {
     make_sprite(25,1,2,false),
     make_sprite(24,1,2,false),
     make_sprite(25,1,2,false),
     make_sprite(26,1,2,false)
    },
    {0,6,14,20},
    28
   ),
   stand_front_sprite=make_sprite(11,1,2,false),
   walk_front_clip=make_clip(
    {
     make_sprite(12,1,2,false),
     make_sprite(13,1,2,false),
     make_sprite(12,1,2,false),
     make_sprite(14,1,2,false)
    },
    {0,6,14,20},
    28
   ),
   stand_back_sprite=make_sprite(43,1,2,false),
   walk_back_clip=make_clip(
    {
     make_sprite(44,1,2,false),
     make_sprite(45,1,2,false),
     make_sprite(44,1,2,false),
     make_sprite(46,1,2,false)
    },
    {0,6,14,20},
    28
   ),
   sit_clip=make_clip(
    {
     make_sprite(51,1,2,false),
     make_sprite(52,1,2,false),
     make_sprite(53,1,2,false),
     make_sprite(51,1,2,false),
     make_sprite(53,1,2,false),
     make_sprite(51,1,2,false),
     make_sprite(53,1,2,false),
     make_sprite(54,1,2,false),
     make_sprite(55,1,2,false),
     make_sprite(54,1,2,false),
     make_sprite(55,1,2,false),
    },
    {0,60,70,85,
    120,165,
    180,195,
    230,245,
    260},
    300
   ),
   draw=
    function(self)
     if game.debug then
      rectfill(
       self.x-4,
       self.y-12,
       self.x+4,
       self.y,
       3)
      act_point=get_act_point()
      circfill(
       act_point[1],
       act_point[2],
       1,
       2)
     else
      if game.ending=="cat" then
       local sprite=self.sit_clip:get_sprite(game.t)
       sprite:draw(self.x+self.d_offset.x,self.y+self.d_offset.y)
       return
      end
      
      if self.facing==0 or self.facing==1 then
       --side
       if self.moving then
        self.walk_t+=1
        local sprite=self.walk_side_clip:get_sprite(self.walk_t)
        sprite.flip=self.facing==0
        sprite:draw(
         self.x+self.d_offset.x,
         self.y+self.d_offset.y)
       else
        self.stand_side_sprite.flip=self.facing==0
        self.stand_side_sprite:draw(
        self.x+self.d_offset.x,
        self.y+self.d_offset.y)
       end
            
      elseif self.facing==2 then
       --up
       if self.moving then
        self.walk_t+=1
        local sprite=self.walk_back_clip:get_sprite(self.walk_t)
        sprite:draw(
         self.x+self.d_offset.x,
         self.y+self.d_offset.y)
       else
        self.stand_back_sprite:draw(
         self.x+self.d_offset.x,
         self.y+self.d_offset.y)
        
       end     
      else
       --down
       if self.moving then
        self.walk_t+=1
        local sprite=self.walk_front_clip:get_sprite(self.walk_t)
        sprite:draw(
         self.x+self.d_offset.x,
         self.y+self.d_offset.y)
       else
        self.stand_front_sprite:draw(
         self.x+self.d_offset.x,
         self.y+self.d_offset.y)
 	     end     
      end
     end
   	end
  },
  cat=
  {
   dead=false,
   x=40,
   y=100,
   w=8,
   h=6,
   speed=0.5,
   facing=0,
   first_facing=-1,
   status="",
   stand_sprite=make_sprite(4,1,1,false),
   d_offset={x=-4,y=-6},
   facing_right=true,
   particles={},
   particle_life=0.4,
   moving=false,
   walk_clip=make_clip(
    {
     make_sprite(5,1,1,false),
     make_sprite(6,1,1,false)
    },
    {0,10},
    20
   ),
   sit_clip=make_clip(
    {
     make_sprite(56,1,1,false),
     make_sprite(57,1,1,false),
     make_sprite(58,1,1,false),
     make_sprite(57,1,1,false),
    },
    {0,30,50,70},
    90
   ),
   walk_t=0,
   act_label_1=
    function(self)
     return "pet"
    end,
   act_label_2=
    function(self)
     if game.player.weapon!=nil and game.cat.poisoned!=true and game.cat.dead==false then
      return "kill"
     else
      return nil
     end
    end,
   act_1=
    function(self)
     game.player.moving=false
     if self.dead then
      game:set_dialogue({"..."},"speech")
     else
      if rnd(1)>0.5 then
       sfx(1)
      else
       sfx(0)
      end
      game:set_dialogue({"*meow*"},"speech")
     end
    end,
   act_2=
    function(self)
     if game.player.weapon!=nil and game.cat.dead==false then
      if game.player.weapon=="gun" then
       self:kill()
       
       game.flash=true
       game.flash_color=7
       
       game.shake=true
       game.shake_amnt=10
       game.shake_decay=0.6
       
       sfx(2)
       
       local splat_dir=game.dirs[game.player.facing+1]
       game.room.blood={}
       for i=1,80 do
        local dx=8*(splat_dir[1]+rnd(1)-0.5)
        local dy=8*(splat_dir[2]+rnd(1)-0.5)

        add(game.room.blood,
        {
         x=self.x,
         y=self.y,
         dx=dx,
         dy=dy,
         ddx=dx*(-0.1),
         ddy=dy*(-0.1),
         draw=
          function(p)
           circ(p.x,p.y,0,8)
          end,
         update=
          function(p)
           p.x+=p.dx
           p.y+=p.dy
           if p.ddx==0 and p.ddy==0 and p.dx==0 and p.dy==0 then
            return
           end
           
           if abs(p.dx+p.ddx)>=abs(p.dx) then
            p.dx=0
            p.ddx=0
           end
           if abs(p.dy+p.ddy)>=abs(p.dy) then
            p.dy=0
            p.ddy=0
           end
           
           p.dx+=p.ddx
           p.dy+=p.ddy
           
           p.x=clamp(p.x,8,120)
           p.y=clamp(p.y,16,122)
           
           if p.ddx==0 and p.ddy==0 then
            for thing in all(game.collidables) do
             if col({p.x,p.y},thing) then
              del(game.room.blood,p)
              del(game.renderables,p)
             end
            end
           end
           
          end
        })
       end
       for p in all(game.room.blood) do
        add(game.renderables,p)
       end
      elseif game.player.weapon=="knife" then
       game.flash=true
       game.flash_color=8

       sfx(3,0)
       sfx(1,1)
 
       if self.bleeding then
        self:kill()
        self.bleeding=false
       else
        game.room.blood={}
        self.speed/=2
        self.bleeding=true
        self.bleed_t=0
       end
      elseif game.player.weapon=="poison" then
       if self.poisoned then
        return
       end
       sfx(4,0)
       sfx(1,1)
       self.speed/=2
       self.poisoned=true
       self.poison_t=0
      end
     end
    end,
   kill=
    function(self)
     self.dead=true
     self.speed=0
     self.stand_sprite=make_sprite(7,1,1,false)
     self.moving=false  
    end,
   draw=
    function(self)
     if game.ending=="cat" then
      pal(8,0)
      local sprite=self.sit_clip:get_sprite(game.t)
      sprite:draw(self.x+self.d_offset.x,self.y+self.d_offset.y)
      pal()
      return
     end
      
     self.stand_sprite.flip=self.facing_right==false
     pal(8,0)
     if self.moving then
      self.walk_t+=1
      local sprite=self.walk_clip:get_sprite(self.walk_t)
      sprite.flip=self.facing_right==false
      sprite:draw(
       self.x+self.d_offset.x,
       self.y+self.d_offset.y)
     else
      self.stand_sprite:draw(
      self.x+self.d_offset.x,
      self.y+self.d_offset.y)
     end
     pal()

     if self.poisoned and self.dead!=true then
      self:update_particles()
      self:draw_particles()
      self.poison_t+=1
      if self.poison_t%45==0 then
       sfx(0)
      elseif self.poison_t>=240 then
       self:kill()
      end
     elseif self.bleeding then
      self.bleed_t-=1
      if self.bleed_t<=0 then
       local can_spawn=true
       for thing in all(game.collidables) do
        if col({self.x,self.y},thing)==true then
         can_spawn=false
        end
       end
       
       if can_spawn then
        local new_blood=
        {
         x=self.x,
         y=self.y,
         draw=
          function(self)
           circ(self.x,self.y,0,8)
          end,
         update=
          function(self)
          end
        }
        add(game.room.blood,new_blood)
        add(game.renderables,new_blood)
       end
       
       self.bleed_t=rnd(20)
      end
     end
    end,
  update_particles=
   function(self)
    if game.t%8==0 then
     self:add_particle()
    end
    
    for p in all(self.particles) do
     p.t+=1
     p.x+=sin(p.t/15)*p.amp
     p.y-=p.dy
     p.life-=1
     if p.life<=0 then
      del(self.particles,p)
     end
    end
   end,
  add_particle=
   function(self)
    local new_p=
    {
     x=self.x-4+rnd(8),
     y=self.y+2,
     t=rnd(30),
     dy=0.2+rnd(0.3),
     amp=0.5+rnd(0.5),
     size=rnd(1.2),
     color=2
    }
    new_p.life=self.particle_life/new_p.dy*30
    
    add(self.particles,new_p)
   end,
  draw_particles=
   function(self)
    for p in all(self.particles) do
     circ(p.x,p.y,p.size,p.color)
    end
   end
  },
  dirs=
  {
   {-1,0},
   {1,0},
   {0,-1},
   {0,1}
  },
  rooms=make_rooms(),
  control_state="move",
  set_room=
   function(self,room)
    self.room=room
    self.renderables={self.player}
    self.interactables={}
    if self.cat.dead==false then
     add(self.renderables,self.cat)
     add(self.interactables,self.cat)
				end
				self.collidables={}

    self.cat.x=self.player.x
    self.cat.y=self.player.y

    if room.blood!=nil then
     for p in all(room.blood) do
      add(self.renderables,p)
     end
    end
    
    if game.cat.bleeding then
     room.blood={}
    end

    for stone in all(room.stones) do
     add(self.renderables,stone)
     add(self.interactables,stone)
     add(self.collidables,stone)
    end
    
    for wall in all(room:make_walls()) do
     add(self.renderables,wall)
     add(self.collidables,wall)
    end
    
    room:init()
    quick_sort_by_y(self.renderables,1,#self.renderables)
   end,
  set_dialogue=
   function(self,text_set,style)
    self.player.moving=false
    self.dialogue=text_set
    self.dialogue_i=1
    self.control_state="read"
    self.d_box:set_style(style)
   end,
  set_ending_dialogue=
   function(self,text_set)
    self:set_dialogue(text_set,"speech")
    self.control_state="ending"
    self.d_box.top=10
    self.d_box.bottom=50
   end,
  d_box=
  {
   left=24,
   top=70,
   right=104,
   bottom=102,
   ch_max=20,
   color=0,
   font_color=7,
   align="center",
   padding=5,
   border_w=2,
   border_color=7,
   set_style=
    function(self,style)
     if style=="sign" then
      self.type_in=false
 	    self.align="center"
     elseif style=="speech" then
      self.type_in=true
      self.align="left" 
     end
     
     game:reset_lines()
    end,
   type_in=false,
   ti_interval=1,
   ti_progress=0,
   ti_max=0
  },
  reset_lines=
   function(self)
    if self.dialogue!=nill then
     self:set_lines(self.dialogue[self.dialogue_i])
    end
   end,
  set_lines=
   function(self,msg)
    self.d_box.ti_progress=0
    self.d_box.ti_max=#msg
    --wrap the words
    local lines={}
    local words=split(msg)
    
    local line_len=#words[1]
    local m_line=words[1]
    for i=2,#words do
     local word=words[i]
     if line_len+#word < game.d_box.ch_max then
      m_line=m_line.." "..word
      line_len+=1+#word
     else
      add(lines,m_line)
      m_line=word
      line_len=#word
     end
    end
    add(lines,m_line)
    
    --pad the words
    for i=1,#lines do
     local m_line=lines[i]
     local padding=0
   
     if game.d_box.align=="center" then
      padding=(game.d_box.ch_max-#lines[i])/2
     elseif game.d_box.align=="right" then
      padding=game.d_box.ch_max-#lines[i]
     end
   
     for x=1,padding do
       m_line=" "..m_line
     end
     
     lines[i]=m_line
    end
    self.d_box.lines=lines
   end
 }
 
 game:set_room(game.rooms[1])
end
-->8
--update

function _update()
 game.t+=1
 if game.control_state=="move" then
  game.player.moving=move_player()
  update_act()
  
  if game.player.moving then
   quick_sort_by_y(game.renderables,1,#game.renderables)
  end
 end

 update_cat()
 if game.cat.dead then
  update_blood()
 end
 if game.room.blood!=nil then
  game.room:collide_with_blood()
 end
  
 if game.dialogue!=nil then
  update_dialogue()
 else
  check_act()
 end
 
 if game.ending_t!=nil and game.ending_t>0 then
  game.ending_t-=1
  if game.ending_t<=0 then
   game.ended=true
  end
 end
end

function move_player()
 if btn(game.player.facing)==false then
  game.player.first_facing=-1
 end
 
 local moved=false
 for i=0,3 do
  if btn(i) then
   try_set_facing(i)
   local next_x=game.player.x+game.dirs[i+1][1]
   local next_y=game.player.y+game.dirs[i+1][2]
 
   if check_collisions({next_x,next_y})==false then
    game.player.x+=game.dirs[i+1][1]
    game.player.y+=game.dirs[i+1][2]
 
    moved=true
   end
  end
 end
 
 if game.player.x<game.bounds.min.x 
  and game.room.exits.west!=nil 
  and game.room.exits.west.locked==false then
  game.player.x=game.bounds.max.x-1
  game:set_room(game.room.exits.west)
 elseif game.player.x>game.bounds.max.x 
  and game.room.exits.east!=nil 
  and game.room.exits.east.locked==false then
  game.player.x=game.bounds.min.x+1
  game:set_room(game.room.exits.east)
 end

 if game.player.y<game.bounds.min.y 
  and game.room.exits.north!=nil 
  and game.room.exits.north.locked==false then
  game.player.y=game.bounds.max.y-1
  game:set_room(game.room.exits.north)
 elseif game.player.y>game.bounds.max.y 
  and game.room.exits.south!=nil 
  and game.room.exits.south.locked==false then
  game.player.y=game.bounds.min.y+1
  game:set_room(game.room.exits.south)
 end
 
 game.player.x=clamp(
  game.player.x,
  game.bounds.min.x,
  game.bounds.max.x)
 game.player.y=clamp(
  game.player.y,
  game.bounds.min.y,
  game.bounds.max.y)
  
 return moved
end

function try_set_facing(x)
 if game.player.first_facing==-1 then
  game.player.first_facing=x
  game.player.facing=x
 end
end

function clamp(x,x_min,x_max)
 local clamped=max(x_min,x)
 clamped=min(clamped,x_max)
 return clamped
end

function check_collisions(point)
 for c in all(game.collidables) do
  if col(point,c) then
   return true
  end
 end
 return false
end

function repel(pusher,slider)
 local xdiff=slider.x-pusher.x
 local ydiff=slider.y-pusher.y
 local halfw=(pusher.w+slider.w)/2
 local halfh=(pusher.h+slider.h)/2

 local colx=abs(xdiff) < halfw
 local coly=abs(ydiff) < halfh

 local penx=halfw-abs(xdiff)
 local peny=halfh-abs(ydiff)

 if colx and coly then
  if colx and penx>peny then
   if xdiff<0 then
    slider.x=pusher.x-halfw
   else
    slider.x=pusher.x+halfw
   end
  
  elseif coly then
   if ydiff<0 then
    slider.y=pusher.y-halfh
   else
    slider.y=pusher.y+halfh
   end
  end  
 end
end

function update_cat()
 if game.cat.dead then
  return
 end
 
 local p_diff=
 {
  x=game.player.x-game.cat.x,
  y=game.player.y-game.cat.y
 }
 local mag=sqrt(p_diff.x*p_diff.x+p_diff.y*p_diff.y)
 
 if mag>8 then
  p_diff.x/=mag
  p_diff.y/=mag
  
  if mag>20 then
   p_diff.x*=2
   p_diff.y*=2
  end
  
  game.cat.x+=p_diff.x*game.cat.speed
  game.cat.y+=p_diff.y*game.cat.speed
  game.cat.moving=true
  game.cat.facing_right=p_diff.x>0
 else
  game.cat.moving=false
  game.cat.move_t=0
 end
end

function update_blood()
 if game.room.blood!=nil then
  for p in all(game.room.blood) do
   p:update()
  end
 end
end

function update_act()
 local thing=find_interactable(get_act_point())
 game.interact=thing
 if thing!=nil then
  game.act_text_1=thing:act_label_1()
  game.act_text_2=thing:act_label_2()
 else
  game.act_text_1=nil
  game.act_text_2=nil
 end
end

function find_interactable(point)
 for thing in all(game.interactables) do
  if col(point,thing) then
   return thing
  end
 end
 
 return nil
end

function col(point,thing)
 return abs(point[1]-thing.x)<=thing.w and abs(point[2]-thing.y)<=thing.h/2
end

function check_act()
 if game.interact!=nil then
  if btnp(4) then
   game.interact:act_1() 
  elseif btnp(5) then
   game.interact:act_2()
 	end 
 end
end

function update_dialogue()
 local d=game.d_box
 if d.ti_max>d.ti_progress and game.t%d.ti_interval==0 then
  game.d_box.ti_progress+=1
 end
 
 if btnp(4) then
  if d.type_in and d.ti_max>d.ti_progress then
   game.d_box.ti_progress=d.ti_max
  else
   game.dialogue_i+=1
   game.d_box.ti_progress=0
   if game.dialogue_i>#game.dialogue then
    game.dialogue=nil
    if game.control_state=="read" then
     game.control_state="move"
    elseif game.control_state=="ending" then
     game.ending_t=120
    end
    
    local thing=game.interaction
    if thing!= nil and thing.read==false then
     thing.read=true
     game.room:check_unlock()
    end
   else
    game:reset_lines()
   end
  end
 end
end
-->8
--interactions

function get_act_point()
 --facing cursor offset
 local fco=game.dirs[game.player.facing+1]
 return
 {
  game.player.x+fco[1]*game.player.act_dist,
  game.player.y+fco[2]*game.player.act_dist
 }
end
-->8
--rooms

function make_room(stones,exits)
 return
 {
  locked=false,
  stones=stones,
  exits=exits,
  init=
   function(self)
   end,
  check_unlock=
   function(self)
    local locked=false
    for stone in all(self.stones) do
     if stone.read==false then
      locked=true
     end
    end
    
    for room in all(self.exits:get()) do
     if room!=nil then
      room.locked=locked
     end
    end
    
    if locked==false then
     local cat_pos={x=game.cat.x,y=game.cat.y}
     game:set_room(game.room)
     game.cat.x=cat_pos.x
     game.cat.y=cat_pos.y
     quick_sort_by_y(game.renderables,1,#game.renderables)
    end
   end,
  make_walls=
   function(self)
    local walls={}
    add_range(walls,self:make_wall(self.exits.north,1))
    add_range(walls,self:make_wall(self.exits.south,2))
    add_range(walls,self:make_wall(self.exits.east,3))
    add_range(walls,self:make_wall(self.exits.west,4))
    return walls
   end,
  make_wall=
   function(self,room,i) 
    local walls={}
    if room!=nil and room.locked==nil then
     return walls
    end
    
    local is_vertical=i>2
    local start=
    {
     x=game.bounds.min.x,
     y=game.bounds.min.y
    }
    if i==2 then
     start.y=game.bounds.max.y
    elseif i==3 then
     start.x=game.bounds.max.x
    end
    
    if room==nil then
     for j=0,7 do
      local x=start.x
      local y=start.y
      if is_vertical then
       y+=16*j
      else
       x+=16*j
      end
      
      add(walls,make_fence(x,y,is_vertical))
     end
    else
     for j in all({0,1,2,5,6,7}) do
      local x=start.x
      local y=start.y
      if is_vertical then
       y+=16*j
      else
       x+=16*j
      end
      
      add(walls,make_fence(x,y,is_vertical))
     end
     
     local x1=start.x
     local y1=start.y
     local x2=x1
     local y2=y1
     if is_vertical then
      y1+=16*3
      y2+=16*4
     else
      x1+=16*3
      x2+=16*4
     end
     
     if room.locked==true then
      add(walls,make_gate(x1,y1,is_vertical,false))
      add(walls,make_gate(x2,y2,is_vertical,true))
     else
     end
    end
   
    return walls
 	 end,
 	collide_with_blood=
 	 function(self)
   	for p in all(self.blood) do
  	  if col({p.x,p.y},game.player) then
      del(game.renderables,p)
      del(game.room.blood,p)
      
      if game.player.bloodied==false then
       game.player.bloodied=true
       game.player.stand_side_sprite.i+=64
       game.player.stand_front_sprite.i+=64
       game.player.stand_back_sprite.i+=64
       for anim in all({game.player.walk_side_clip,game.player.walk_back_clip,game.player.walk_front_clip}) do
        for frame in all(anim.frames) do
         frame.sprite.i+=64
        end
       end
      end
     end
    end
 	 end
 }
end

function make_fence(x,y,is_vertical)
 local fence=
 {
  x=x,
  y=y,
  draw=
   function(self)
    pal(8,0)
    self.sprite:draw(
     self.x+self.d_offset[1],
     self.y+self.d_offset[2])
    pal()
   end
 }
 if is_vertical then
  fence.w=6
  fence.h=16
  fence.d_offset={-4,-12}
  fence.sprite=make_sprite(20,1,2,false)
 else
  fence.w=12
  fence.h=6
  fence.d_offset={-8,-12}
  fence.sprite=make_sprite(16,2,2,false)
 end

 return fence
end

function make_gate(x,y,is_vertical,is_flip)
 local gate=
 {
  x=x,
  y=y,
  draw=
   function(self)
    pal(8,0)
    self.sprite:draw(
     self.x+self.d_offset[1],
     self.y+self.d_offset[2]) 
    pal()
   end
 }
 if is_vertical then
  gate.w=8
  gate.h=16
  gate.d_offset={-4,-12}
  gate.sprite=make_sprite(21,1,2,false)
 else
  gate.w=12
  gate.h=6
  gate.d_offset={-8,-12}
  gate.sprite=make_sprite(18,2,2,is_flip)
 end

 return gate
end

function make_clip(sprites,times,wrap_t)
 if #sprites!=#times then
  return {}
 end
 
 local output=
 {
  frames={},
  wrap_t=wrap_t,
  get_sprite=
   function(self,t)
    t=t%self.wrap_t
    for i=0,#self.frames-1 do
     local frame=self.frames[#self.frames-i]
     if frame.t<=t then
      return frame.sprite
     end
    end
   end
 }
 
 for i=1,#times do
  add(output.frames,{t=times[i],sprite=sprites[i]})
 end
 
 return output
end

function make_sprite(i,w,h,flip)
 return
 {
  i=i,
  w=w,
  h=h,
  flip=flip,
  draw=
   function(self,x,y)
    spr(
     self.i,
     x,
     y,
     self.w,
     self.h,
     self.flip)
   end
 }
end

function make_exits(room_n,room_s,room_e,room_w)
 return
 {
  north=room_n,
  south=room_s,
  east=room_e,
  west=room_w,
  get=function(self)
   local e={}
   e[1]=self.north
   e[2]=self.south
   e[3]=self.east
   e[4]=self.west
   return e
  end
 }
end

function make_stone(x,y,sprite,text,end_text,color,j_pos)
 return
 {
  jewel_pos=j_pos,
  x=x,
  y=y,
  w=8,
  h=6,
  read=false,
  color=color,
  sprite=sprite,
  text=text,
  ending_text=end_text,
  particle_life=0.4,
  particles={},
  act_label_1=
   function(self)
    return "read"
   end,
  act_label_2=
   function(self)
    if game.player.has_rose then
     return "place"
    end
   end,
  act_1=
   function(self)
    if game.ending!=nil then
     return
    end
    game:set_dialogue(self.text,"sign")
    game.interaction=self
    game.player.moving=false
   end,
  act_2=
   function(self)
    if game.player.has_rose then
     game.player.has_rose=false
     local rose=make_rose()
     rose.x=self.x
     rose.y=self.y+5
     game.rose=rose
     game:set_ending_dialogue(self.ending_text)
     game.ending="grave"
     game.grave=self
     game.grave_t=0
     game.shake=true
     game.shake_amnt=4
     game.shake_decay=0.05
     --music(-1,8)
     sfx(5,2)
    end
   end,
  draw=
   function(self)
    spr(self.sprite,self.x-4,self.y-6)
    
    if self.read==false then
     self:update_particles()
     self:draw_particles()
    end
   end,
  update_particles=
   function(self)
    if game.t%8==0 then
     self:add_particle()
    end
    
    for p in all(self.particles) do
     p.t+=1
     p.x+=sin(p.t/15)*p.amp
     p.y-=p.dy
     p.life-=1
     if p.life<=0 then
      del(self.particles,p)
     end
    end
   end,
  add_particle=
   function(self)
    local new_p=
    {
     x=self.x-4+rnd(8),
     y=self.y+2,
     t=rnd(30),
     dy=0.2+rnd(0.3),
     amp=0.5+rnd(0.5),
     size=rnd(1.2),
     color=self.color
    }
    new_p.life=self.particle_life/new_p.dy*30
    
    add(self.particles,new_p)
   end,
  draw_particles=
   function(self)
    for p in all(self.particles) do
     circ(p.x,p.y,p.size,p.color)
    end
   end
 }
end

function make_rooms()
 --first room
 local room1_stones=
 {
  make_stone(60,80,1,
  {
   "here lies elias grey, a man with so much potential.",
   "though his intentions were good, he eventually succumbed to slothfulness."
  },
  {
   "you're suddenly a teenager again.",
   "time hasn't changed - just your body. you've been given a second chance to live your life.",
   
  },10)
 }
 room1_stones[1].act_2=
  function(self)
  end
 room1_stones[1].act_label_2=
  function(self)
   return nil
  end
 
 local room2_stones=
 {
  make_stone(110,105,1,
  {
   "here lies the book you wanted to write.",
   "it grew in fits and starts, living in the margins of your life - weekends and stolen afternoons.",
   "what was written, you weren't happy with. you buried the rest out of mercy."
  },
  {
   "a book appears in your hands, hot to the touch.",
   "the writing inside is your own, and it's brilliant.",
   "you quickly find a publisher and it becomes a best seller.",
   "you've never felt so accomplished. a few people even recognize you in public.",
   "in the years that follow you dedicate yourself to your writing,",
   "but you never recapture the magic of that first book..."
  },15,{40,20}),
  make_stone(35,30,1,
  {
   "here lies the choir solo you would have had if you'd stuck with it.",
   "it touched the hearts of complete strangers, and left your vocal teacher speechless.",
   "if you listen closely you can almost hear it now...",
   "an outpouring of your heart that shall never be."
  },
  {
   "a song fills your mind.",
   "you find yourself humming along with unusual precision.",
   "it's like your voice is following a well-hewn path with no chance of straying.",
   "returning home, you impress a number of local musicians, who ask you to be their vocalist.",
   "you humbly oblige.",
   "your band grows in popularity with you as its new face, and you eventually publish an album.",
   "though it sells well and your band continues to be popular,",
   "you never manage to convince them to perform any songs you've written yourself."
  },14,{44,20}),
  make_stone(20,40,1,
  {
   "here lie all of the dinner parties you wanted to have with your friends.",
   "they were re-planned, rescheduled, and eventually forgotten,",
   "imploding under the weight of your expectations.",
   "you never knew how to cook anyhow."
  },
  {
   "you are overwhelmed with ideas for creative get-togethers.",
   "your friends are delighted, and the events you put on become the envy of your neighborhood.",
   "your social circles expand to nearby towns as you attract more interesting people into your life,",
   "but your interactions are somehow shallower than you'd hoped they'd be,",
   "and you long for the friendships of your youth."
  },13,{48,20}),
  make_stone(80,65,1,
  {
   "here lies your dream project - a game that would change people's lives.",
   "the nights and weekends you fed were never enough. it just got hungrier.",
   "when it was clear you'd never have enough resources to provide it,",
   "you locked it in a cage and let it wither out of your sight."
  },
  {
   "a flash drive appears in your hand with a sizzling glow.",
   "you rush home to find that it contains your finished game -",
   "a technical wonder that is as epic as it is personal.",
   "it's a critical and financial success that grants you 15 minutes of fame and a respectable fan base.",
   "you struggle to please them with the games that follow, though, and you fade into obscurity."
  },12,{52,20}),
  make_stone(80,30,1,
  {
   "here lies the joy you gave others as an entertainer.",
   "you worked so hard to make people laugh, to feel, to think.",
   "the trouble was that you had no voice, and therefore nothing to say.",
   "you buried this one silently on a sunday afternoon. nobody came to the funeral."
  },
  {
   "you suddenly know exactly who you are and what you have to offer the world.",
   "when you speak, people listen. when you joke, they laugh. when you entertain, they applaud.",
   "you're the life of every party, and for a time this makes you feel less alone,",
   "but at times you feel over-extended with nobody to talk to.", 
   "becoming everyone's joy and role-model prevents you from being able to relate to them anymore."
  },11,{56,20}),
  make_stone(25,100,1,
  {
   "here lies the life you tried to build with someone special.",
   "the towers you built would always crumble and wash away with the tide.",
   "with this dream you buried your heart."
  },
  {
   "your heart is warm as the rose begins to pulsate with an intoxicating heat.",
   "returning home, you contact someone who seemed perfect for you once, but whose affections had faded with time.",
   "your conversations are playful and exciting, eventually leading to each other's arms.",
   "you find happiness in this rekindled love, but worry that something has changed too much.",
   "it's as if your partner has been replaced by an imposter.",
   "you feel guilty about it, but are never quite able to shake the idea."
  },8,{60,20}),
  make_stone(95,80,1,
  {
   "here lies your engineering career, with which you would fix the world's biggest problems.",
   "people were skeptical that this one was viable to begin with.",
   "that didn't make burying it hurt any less."
  },
  {
   "you are suddenly surrounded by bright young interns looking to you for guidance.",
   "you regail them with your practical wisdom gained from years of solving tough problems with hard data.",
   "your suggestions are definitive, and fellow scientists talk about you with hushed reverence.",
   "with that respect comes wealth, and you are able to have a pretty comfortable life.",
   "but solving the big problems didn't leave any room for the small things,",
   "and you struggle to find someone to share your life with."
  },9,{64,20}),
  make_stone(50,90,1,
  {
   "here lie the diets and exercise plans you started, only to abandon in the woods.",
   "they offered you fitness, but demanded more than you were willing to give.",
   "most died of starvation trying to escape the forest."
  },
  {
   "you are suddenly holding a protein shake.",
   "god, you look so good.",
   "returning home, you even land a modeling gig.",
   "people treat you a lot better, and your love life is out of this world.",
   "the lack of scarcity in dating options affects the way you treat people, though.",
   "you find yourself not really liking who you are on the inside, and opt to keep people at arm's length.",
   "i suppose it really is lonely at the top."
  },10,{68,20}),
  make_stone(70,100,1,
  {
   "here lie the children you thought you'd have.",
   "one was a scientist, another an artist.",
   "they filled your home with energy and warmth.",
   "you carved their names on a sacred tree and wished on a star.",
   "that star has fallen, now."
  },
  {
   "a small hand touches yours and when you look down, you see them - your kids.",
   "born of oak and star dust, they are dark skinned with silver hair.",
   "you see yourself in their eyes.",
   "as they grow, their brilliance abounds and they become suspicious of their origins.",
   "they achieve greatness in their vocations, but that greatness keeps them busy.",
   "though they love you, they relate to each other so much better than they do to you.",
   "after they move out their visits become brief and seldom, leaving you alone once more."
  },7,{72,20}),
  make_stone(100,50,1,
  {
   "here lies all the globe trekking you were going to do.",
   "though exciting and enriching, the trips were also quite expensive.",
   "weighed down by doubt, they sunk into the mire."
  },
  {
   "a passport appears in your hands, filled with visas and all the money you could possibly need.",
   "you spend the coming years travelling the world, seldom sleeping in the same country for two nights in a row.",
   "you taste all the world has to offer, and start journaling and photographing your experiences.",
   "your heart belongs to the whole world, and you love every culture you encounter.",
   "never staying in any one place doesn't allow you to plant any roots, though,",
   "and you struggle to find a place that truly feels like home."
  },4,{76,20})
 }
 
 local entrance=make_room({},{})
 local room1=make_room(room1_stones,{})
 local room2=make_room(room2_stones,make_exits(room1,nil,nil,nil))
 local sac=make_room({},{})
 local exitroom=make_room({},{})
 entrance.exits=make_exits(room1,{},{},{})
 room1.exits=make_exits(nil,entrance,room2,nil)
 room2.exits=make_exits(sac,nil,nil,room1)
 room2.locked=true
 sac.exits=make_exits(exitroom,room2,nil,nil)
 sac.locked=true
 exitroom.exits=make_exits({},sac,{},{})
 exitroom.locked=true
 
 room1.init=
  function(self)
   local fountain=make_obj(60,60,65,2,3,false,{-8,-20},10,14)
   
   local bush_1=make_obj(110,30,85,2,2,false,{-8,-10},10,10)
   local bush_2=make_obj(108,110,85,2,2,false,{-8,-10},10,10)
   
   add_range(game.renderables,{fountain,bush_1,bush_2})
   add_range(game.collidables,{fountain,bush_1,bush_2})
  end

 room2.init=
  function(self)
   local fountain=make_obj(100,30,65,2,3,false,{-8,-20},10,14)
   
   local bush_1=make_obj(20,20,85,2,2,false,{-8,-10},10,10)
   local bush_2=make_obj(90,110,85,2,2,false,{-8,-10},10,10)
   
   add_range(game.renderables,{fountain,bush_1,bush_2})
   add_range(game.collidables,{fountain,bush_1,bush_2})
  end

 
 entrance.init=
  function(self)
   local birch_1=make_obj(128,80,130,2,4,true,{-16,-24},6,20)
   local birch_2=make_obj(0,60,132,2,4,false,{0,-24},6,20)
   local birch_3=make_obj(128,100,132,2,4,true,{-16,-24},6,20)
   local birch_6=make_obj(0,40,132,2,4,false,{0,-24},6,20)
   
   local stump_1=make_obj(8,100,134,4,4,false,{-8,-24},20,20)
   local stump_2=make_obj(120,25,134,4,4,true,{-24,-24},20,20)
   
   local bush_1=make_obj(70,130,170,4,2,false,{-16,-16},20,20) 
   local bush_2=make_obj(5,128,170,4,2,false,{-16,-16},20,20) 
   local bush_3=make_obj(110,128,170,4,2,true,{-16,-16},20,20) 
   local bush_4=make_obj(40,132,170,4,2,false,{-16,-16},20,20) 
   
   local gate_1=make_obj(48,17,80,1,2,false,{-4,-12},8,6,8)
   local gate_2=make_obj(72,17,80,1,2,true,{-4,-12},8,6,8)
   
   add_range(game.renderables,{birch_2,birch_3,birch_1,stump_1,stump_2,birch_6,bush_1,bush_2,bush_3,bush_4,gate_1,gate_2})
   add_range(game.collidables,{birch_2,birch_3,birch_1,stump_1,stump_2,birch_6,bush_1,bush_2,bush_3,bush_4,gate_1,gate_2})
  end
 
 exitroom.init=
  function(self)
   local seat=
   {
    x=64,
    y=64,
    w=32,
    h=32,
    d_offset={x=-16,y=0},
    draw=
     function(self)
      spr(192,
       self.x+self.d_offset.x,
       self.y+self.d_offset.y,
       4,
       3)
     end,
    act_label_1=
     function(self)
      if game.ending==nil and game.cat.dead==false then
       return "sit"
      else
       return nil
      end
     end,
    act_label_2=
     function(self)
      return nil
     end,
    act_2=
     function(self)
     end,
    act_1=
     function(self)
      if game.ending!=nil or game.cat.dead then
       return
      end
      
      game.ending="cat"
      game.player.moving=false
      game.player.x=self.x
      game.player.y=self.y+8
      game.cat.x=game.player.x
      game.cat.y=game.player.y+0.1
      quick_sort_by_y(game.renderables,1,#game.renderables)
      game:set_ending_dialogue({
       "you sit here for a while, pondering the things that could have been.",
       "at least now you've buried them for good.",
       "you've found your comfort, and you wouldn't trade it for the world."
      })
     end
   }
   local tree_1=make_obj(20,24,128,2,4,false,{-8,-24},16,16)
   local tree_2=make_obj(70,16,128,2,4,false,{-8,-24},16,16)
   local tree_3=make_obj(90,24,128,2,4,true,{-8,-24},16,16)
   
   local birch_1=make_obj(0,80,130,2,4,false,{0,-24},6,20)
   local birch_2=make_obj(0,60,132,2,4,false,{0,-24},6,20)
   local birch_3=make_obj(0,100,132,2,4,false,{0,-24},6,20)
   local birch_4=make_obj(25,10,132,2,4,true,{0,-24},6,20)
   local birch_5=make_obj(41,10,132,2,4,false,{0,-24},6,20)
   local birch_6=make_obj(128,50,132,2,4,true,{-16,-24},6,20)
   
   local stump_1=make_obj(8,40,134,4,4,false,{-8,-24},20,20)
   local stump_2=make_obj(120,15,134,4,4,true,{-24,-24},20,20)
   local stump_3=make_obj(125,85,134,4,4,true,{-24,-24},20,20)
   
   add_range(game.renderables,{seat,tree_1,birch_2,birch_3,birch_1,stump_1,birch_4,birch_5,stump_2,stump_3,birch_6,tree_2,tree_3})
   add_range(game.collidables,{tree_1,birch_2,birch_3,birch_1,stump_1,birch_4,birch_5,stump_2,stump_3,birch_6,tree_2,tree_3})
   add(game.interactables,seat)
  end
 
 sac.init=
  function(self)
   if self.spirit==nil then
    local spirit=make_stone(60,50,1,
    {
     "i sense that you walk a dark path...",
     "the veil is thinner here. tonight, your fate can be altered. but...",
     "it will require a sacrifice.",
     "i offer you the tools of my trade. if you have not the will, you may leave this place forever."
    },0)
    self.spirit=spirit
    
    spirit.sprite=make_sprite(22,1,2,false)
    spirit.d_offset={x=-4,y=-12}
    spirit.w=24
    spirit.h=64
    spirit.particle_life=0.6
    spirit.draw=
     function(self)
      self:update_particles()
      self:draw_particles()
  
      self.d_offset.y+=sin(game.t/120)*0.1
      pal(8,0)
      self.sprite:draw(
       self.x+self.d_offset.x,
       self.y+self.d_offset.y)
      pal()
     end
    spirit.act_label_1=
     function(self)
      return "talk"
     end
    spirit.act_1=
     function(self)
      if self.read then
       if game.cat.dead then
        if game.room.blood!=nil and #game.room.blood>0 then
         game:set_dialogue(
         {
          "this is sacred ground. you may leave the animal, but its blood must be cleansed."
         },"speech")
        elseif self.rose_granted==nil and game.player.has_rose==false then
         self.rose_granted=true
         game:set_dialogue(
         {
          "place this rose on the tombstone of that which you seek, and all shall be redeemed."
         },"speech")
         local rose=make_rose()
         add(game.renderables,rose)
         add(game.interactables,rose)
        else
         game:set_dialogue(
         {
          "..."
         },"speech")
        end
       else
        game:set_dialogue(
        {
         "you must choose...",
         "part with your companion, or put all you wanted to rest?"
        },"speech")
       end
       game.interaction=self
      else
       game:set_dialogue(self.text,"speech")
       self.h=24
       self.w=12
       game.interaction=self
      end
     end
    spirit.act_label_2=
     function(self)
      return nil
     end
   elseif self.spirit.read and game.player.weapon==nil then
    self.gun=make_stone(40,65,10,{},0)
    self.knife=make_stone(60,65,9,{},0)
    self.poison=make_stone(80,65,8,{},0)
   
    self.gun.act_label_1=
     function(self)
      return "take"
     end
    self.knife.act_label_1=self.gun.act_label_1
    self.poison.act_label_1=self.knife.act_label_1
    
    self.gun.act_label_2=
     function(self)
      return nil
     end
    self.knife.act_label_2=self.gun.act_label_2
    self.poison.act_label_2=self.gun.act_label_2
    
    self.gun.draw=
     function(self)
      pal(8,0)
      spr(self.sprite,self.x-4,self.y-6)      
      pal()
      
      if self.particle_t==nil then
       self.particle_t=0
      else
       self.particle_t+=1
       if self.particle_t<30 then
        self:update_particles()
        self:draw_particles()
       end
      end
     end
    self.knife.draw=self.gun.draw
    self.poison.draw=self.gun.draw
    
    self.gun.act_1=
     function(self)
      game.player.weapon="gun"
      game.room:hide_weapons()
     end
    self.poison.act_1=
     function(self)
      game.player.weapon="poison"
      game.room:hide_weapons()
     end
    self.knife.act_1=
     function(self)
      game.player.weapon="knife"
      game.room:hide_weapons()
     end
    add(game.renderables,self.gun)
    add(game.interactables,self.gun)

    add(game.renderables,self.knife)
    add(game.interactables,self.knife)

    add(game.renderables,self.poison)
    add(game.interactables,self.poison)
   end
       
   add(game.renderables,self.spirit)
   add(game.interactables,self.spirit)
   add(game.collidables,self.spirit)
  
   local bush_1=make_obj(110,65,85,2,2,false,{-8,-10},10,10)
   local bush_2=make_obj(15,65,85,2,2,false,{-8,-10},10,10)
   
   add_range(game.renderables,{bush_1,bush_2})
   add_range(game.collidables,{bush_1,bush_2})
  
   self.hide_weapons=
    function(self)
     del(game.renderables,self.gun)
     del(game.interactables,self.gun)
 
     del(game.renderables,self.knife)
     del(game.interactables,self.knife)
 
     del(game.renderables,self.poison)
     del(game.interactables,self.poison)
    end
  end
 
 return {entrance,room1,room2,sac,exitroom}
end

function add_range(table1,table2)
 for e in all(table2) do
  add(table1,e)
 end
end

function make_rose()
 local rose=make_stone(60,65,0,{},0)
 rose.act_label_2=
  function(self)
   return nil
  end
 rose.act_label_1=
  function(self)
   return "take"
  end
 rose.act_1=
  function(self)
   del(game.renderables,self)
   del(game.interactables,self)
   game.player.has_rose=true
  end
 rose.draw=
  function(self)
   spr(self.sprite,self.x-4,self.y-6)
  end
 return rose
end

function make_obj(x,y,i,i_w,i_h,flip,d_offset,w,h,b_swap)
 local thing=
 {
  x=x,
  y=y,
  sprite=make_sprite(i,i_w,i_h,flip),
  d_offset=d_offset,
  w=w,
  h=h,
  b_swap=b_swap,
  draw=
   function(self)
    if b_swap!=nil then
     pal(b_swap,0)
    end
    self.sprite:draw(self.x+d_offset[1],self.y+d_offset[2])
    if b_swap!=nil then
     pal()
    end
   end
 }
 return thing
end
__gfx__
0000000000666d000000000000000000000000000000000000000000000000000007700000000040000000000004440000044400000000000000000000000000
00888000066666d00077770000777700000000000000000000000000000000000006600000000014000000000044440000444400000044400000444000000000
082828006666666d075555700757757000000000000000000000000000000000006006000004411000006000004fff00004fff00000444400004444000000000
088222006555556d077757700775577000008080000080800000808000000000060000600006640000064440004cfc00004cfc000004fff00004fff000000000
008880006666666d077577700775577000008a8000008a8000008a800000000062722226006656400066644400ffff0000ffff000004cfc00004cfc000000000
00b000006555556d0755557007577570008888e0008888e0008888e000000888622222260665600006660604000ff000000ff000000ffff0000ffff000000000
0bb330006666666d0d7777d00d7777d00888880008888800088888000088888006222260065600006860000000333300003333000000ff000000ff0000000000
0b3000006666666d00dddd0000dddd0080800800808000808008080088888e880066660066600000060000000333333003333330000333300003333000000000
00000000000000000000000000000a000008111080800a00f000000f000444400000000000044440000000000333333003333330003333330033333300000000
0000001000000000000a08000080aaa0001881808800aaa00f8888f0004444000004444000444400000444400334a4300334a4f00033333f0033333300000000
010001110000100000aaa08008008a000111888008088a000881188000444ff00044440000444ff0004444000ff111f00ff1110000ff4a40000ff4af00000000
1110081800011100008a888008800800081808008080880008d88d800044fcf000444ff00044fcf000444ff00001110000011100000011100000111000000000
81800888000818000008000880008080088808000808080000888800000ffff00044fcf0000ffff00044fcf00001110000011100000011100001111000000000
8880008000088800000800080000808800801800888008000d8888d0000ff000000ffff0000ff000000ffff00001110000011100000011100001111000000000
080008880000800000808008000800800081110008808080d888808000333300000ff00000333300000ff0000004440000044400000011400004411000000000
0808808088008000008080008008008000881800080080808808880d003333300033330000333300003333000000000000000000000044000000044000000000
088000800088888008008008800800800088880008080080088808080333333000333330003333f0003333300044400000444000000000000000000000000000
8800008000008008880080080008008800808000080808808080808803334a3003333330003ffa00003333300044440000444400000444000004440000000000
080008880000800008008008000800800080800008808080088088800ff111f003344a3f0001110000f443ff0044440000444400000444400004444000000000
08088080880080000800800880080080008180000880880000888800000111000ff11100000111000001110000c4440000c44400000444400004444000000000
0880008000888880080080008008008000111000080808a0008888000001110000011100000111000011111000f4440000f44400000c4440000c444000000000
880000800000800888008008800800880081800008008aaa0008800000011100001111100001110000111110000ff000000ff000000f4440000f444000000000
0800000000008000080080088008008000888000088808a0000080000001140000440110000114000011044000333300003333000000ff000000ff0000000000
00000000000000000888888888888880000881000080800800000000000440000000044000044000004400000333333003333330000333300003333000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333300333333000f333330003333300000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003344430033444f000f3333f0003333f00000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ff111f00ff1110000004440000ff44000000000
00000000000000000000000000044400000444000004440000000000000000000080800000808000008080000001110000011100000011100000111000000000
0000000000000000000000000044440000444400004444000000000000000000008a8880008a8880008a88800001110000011100000011100001111000000000
000000000000000000000000004fff00004fff00004fff00000444000004440000e8888800e8888000e888800001110000011100000011100001111000000000
000000000000000000000000004cfc00004cfc00004cfc0000444400004444000000000800000080000008800004440000044400000011400004411000000000
00000000000000000000000000ffff0000ffff0000ffff00004fff00004fff000000000000000000000000000000000000000000000044000000044000000000
000000000000006600000000000ff000000ff000000ff0000045f5000045f5000000000000000000000000000004440000044400000000000000000000000000
0000000000000666d600000000333300003333000033330000ffff0000ffff000000000000000000000000000044440000444400000044400000444000000000
000000000000066d66dd00000333333003333f00033333000333333003333300000000000000000000000000004fff00004fff00000444400004444000000000
000000000000006666d6d000033333f00333330003333f00033333f003333f00000000000000000000000000004cfc00004cfc000004fff00004fff000000000
0000000000000066dd66d0000ff333000ff333000ff333000ff333000ff3330000000000000000000000000000f8ff0000f8ff000004cfc00004cfc000000000
00000000000000066666d0000004a4000004a4000004a4000004a4000004a400000000000000000000000000000ff000000ff000000f8ff0000f8ff000000000
0000000000000006dd66d000004111100041111000411110004111100041111000000000000000000000000000333300003333000000ff000000ff0000000000
0000000000000066ddddd00000411110004111100041111000411110004111100000000000000000000000000333333003333330000333300003333000000000
800000100000066666dc000000000000000000000000000000000000000444400000000000044440000000000333333003333330003333330033333300000000
888001110000066ddddc000000000000000000000000000000000000004444000004444000444400000444400834a4300834a480008333380083333300000000
80888818000000666ddc00000000000000000000000000000330000000444ff00044440000444ff00044440008f1118008f11100008f4a400008f4a800000000
8008088000000006660cc000000000000000000000000003323300000044fcf000444ff00044fcf000444ff00001110000011100000011100000111000000000
88080888000000066d00c00000000000000000000000333233333300000ff8f00044fcf0000ff8f00044fcf00001110000011100000011100001111000000000
80880808000066666d66c00000000000000000000033222333223300000ff000000ff8f0000ff000000ff8f00001110000011100000011100001111000000000
8008880800666cc66dccc6600000000000000000003212322221232000333300000ff00000333300000ff0000008440000084400000011400008411000000000
880808880666ccc66d1ccc6600000000000000000333231223322110003333300033330000333300003333000000000000000000000084000000044000000000
8088080806666cccc111ddd600000000000000003332232333221222033333300033333000333380003333300044400000444000000000000000000000000000
800888080666666666666ddd0000000000000000032132233332222208334a30033333300088fa00003338300044440000444400000444000004440000000000
880808880dd666666666dddd0000000000000000012223333122221108f1118008344a38000111000084438f0044440000444400000444400004444000000000
08880808000d666666dddd00000000000000000000223322222321100001110008f11100000111000001110000c4440000c44400000444400004444000000000
0008880800006666ddddddd0000000000000000000012221220110000001110000011100000111000011111000f4440000f44400000c4440000c444000000000
0000088800666666666ddddd0000000000000000000011104200000000011100001111100001110000111110000ff000000ff000000f4440000f444000000000
00000088000666666666dd00000000000000000000000004004200000001140000440110000114000011044000333300003333000000ff000000ff0000000000
00000008000006666666600000000000000000000000000000000000000840000000084000084000008400000333333003333330000333300003333000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333300333333000f333330003333300000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000334448003344480008333380003333800000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f8111800f81110000004440000f844000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001110000011100000011100000111000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001110000011100000011100001111000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001110000011100000011100001111000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004480000044800000011800004411000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044000000048000000000
0000044244424000f000000000000000f00000000000000000000000000000000000000000000000000000000000000220000000000000000000000000000000
0000044224424000ff00000000000000ff0000000000000000000000000000000000000000000000000000000000002222000000000000000000000000000000
0000044424444000fff0000000000000fff000000000000000000000000000000000000000000000000000000000002222220000000000000000000000000000
0000044424444000fff0000000000000fff00000000000002000000000000000000000000000000000022200000002b2222520000bbb00000000000000000000
00000424244244005ff00000000000005ff000000000000042000000000000000000000000000000000b2220000002b2222522bbbbb222000000000000000000
0000042444222400fff0000000000000fff000000000000042400000000000000000000000000000000b222200002bb2222552bbbb2222200000000000000000
0000042444242400fff0000008000000fff0000fffffb00042400000000000000000000000000000002bb2222202bbb222252bb2222222220000000000000000
0000042444242400ff50000a80000000fff00ff000000000422400000000000000000000000000000022bb222555bbb22225bb22222225520000000000000000
000004244422240055f0000088000000ffffffff000000004424000000000000000000000000000000222b22225552222222b222222255500000000000000000
0000442444242400fff0000088000000ffff0000fb000000442440000000000000000000000000000022b22222255522b2222222222550000000000000000000
0000444444422400fff0000f99ffb000fff00000000000004244440000000000000000000000000000002bb22225555bb2222222222520000000000000000000
0000444444224400fff00ff000000000ff5000000000000044444220000000000000000000000000000002bb22225555b22222222bbbbb200000000000000000
0004444444244000ffffffff0000000055f0000000000000444442444000000000000000000000000222222bbb22255552222222bbbbbbb20000000000000000
0004442444440000ffff0000fb000000fff0000000000000444444444400000000000000000000002b222552222222255522222bbbbb22220000000000000000
0042422424440000fff0000000000000fff0000000000000444244422440000000000000000000002bb2222552222222552222222bb222000000000000000000
0024424224400000ff50000000000000fff000000000000024424444424420000000000000000000022b22225552222222222222222220000000000000000000
0024424242440000f550000000000000fff000000000000022442444424444200000000000000000000000000000000000000000000000000000000000000000
0024224442220000fff0000000000000fff000000000000042442224444244442000000000000000000000000000000000000000000000000000000000000000
0024244444242000fff0000000000000f55000000000000042444244424444444400000000000000000000000000000000000000000000000000000000000000
0444242442244000fff0000000000000fff000000000000042442244422244224442000000000000000000000000000000000000000000000000000000000000
2244242442244400ff50000000000000fff000000000000042442244444244442244203030000000000000000000000000000000000000000000000000000000
2440042443043440f5f0000000000000fff000000000000044443043440444444224400300000000000000000000000000000000000000000000000000000000
4003342443300343fff0000000000000fff000000000000044443300443000000422400000000000000000000000000000000000000000000000000000000000
4333042243333334fff0000000000000fff00000000000004444333334440330000245000000000000000000000000000dd00000000000000000000000000000
0030004220003330fff0000000000000fff00000000000000442000333040330300044000000000000000dddd3333000d3333000000000000000000000000000
0000003440000000fff0000000000000f550000000000000044400000000403330004440000000000000d3333333333333333333300000000000000000000000
000033344300000055f00000000000005ff00000000000000044400000004003000000003000000000d3d333333333333333dd33333000000000000000000000
0000003333430000fff0000000000000fff0000000000000000344300000000000000033300000000d33333333333333333dd333333000000000000000000000
0000000033330000fff0000000000000fff000000000000000033444400000000000003300000000033333333333333333dd3333333330000000000000000000
0000000003000000ff00000000000000ff000000000000003000300044003303000000030000000000333333333333d333d33333333333000000000000000000
00000000000000000000000000000000000000000000000033000000000000300000000000000000dd33333333333ddd33333333333333300000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000003333333333333ddd3333333333333330000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000008000000000e0a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000e0bbb000e00000333000bb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000bb00000bb000bbb0000b0000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0008b00033bb00033bbb3300083e00b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0bbb00000bb333bbbbbbbb3300bb300b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000bb333bbbbb33bbbbbb00b0300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300bb33bbbbb33bb33bb3bb0e00b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0b000bbb3bb3bbbbbbbbbbbbb30b00b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0bb00bbbbbb333bb333bb33333bb0800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00b0a0b33bbbbb3333bbbbbbbbb00b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b000000033bbbbbbbbbbbbbbb300bb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eb800000033bbbbbbbbbb333300bb00b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0bb00bbb00033333bbbbbbb000000bb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00bb00bbbb00000bbbb00000000bb800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000a000bb0000000b00a0bbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000bbbb000000bbbb00b00e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000008bb000e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
0001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0003030303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
010900002e5102f5312f5512f5512f5512e5512d51100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010b00002f5102f5512e5512d51100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012a00003067500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001845300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010700001c5561a5561a5561c556000000000000000000001c5561a5561a5561c5561c5001c5001c5001a5001c5561a5561a5561c556000000000000000000001c5561a5561a5561c55600000000000000000000
013700000045100451304513043130411304150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012800000975409751097510974109731097210971109715077540775107751077510775107731077210772504754047510475104751047510475104741047450575405751057510575105741057410574105735
012800000973409731097310973109731097310973109735077340773107731077310773107731077310773504734047310473104731047310473502734027350073400731007310073100731007310073100735
0128000018530185350000000000000000000000000000000c550155501154010540105311053110521105250e5500e5550c5500c5510c5510c5410c5310c5350000000000000000000000000000000000000000
012800000c5500c55513550135550c5000c50013550135550b5500b55513550135550050000500135501355509540095451354013545005000050013540135450b5500b555135401354507500075001354013545
012800000c5500c55513520135250c5000c500135201352509550095551353013535000000000013520135250b5500b5551352013525000000000013520135250c5500c555135301353500000000000000000000
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00 41 06 43 44
00 06 09 43 44
00 0a 07 43 44
00 41 09 43 44
00 09 07 43 44
02 0a 07 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
