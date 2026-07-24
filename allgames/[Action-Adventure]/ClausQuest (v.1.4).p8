pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
				--clausquest v.1.4 (updated december 2020) by david svensson 
    
   	--using a modified template of "advanced micro platformer" by @mhughson
    --and "the lich king" by @dollarone 
    --music stems from "9 songs" by @robbyduguay


    --sfx
    snd=
    {
      jump=0,
      hit=1,
      attack=2,
      drink=3,
      damage=4,
      jump2=5,
      pickup=6,
      open_lock=7,
      found_key=8,
      locked=9,
    }

    --music tracks
    mus=
    {
      new_game=10,
    }

    function top_message(msg) 
      message = msg
      message_time=200
    end

    function found_item(consumable)
      local found = false
      for item in all(found_items) do
        if(item.frame == consumable.frame)found=true
      end
      if(not found) then
        add(found_items,consumable)
      end
    end





    --math
    --------------------------------

    --point to box intersection.
    function intersects_point_box(px,py,x,y,w,h)
      if flr(px)>=flr(x) and flr(px)<=flr(x+w) and
            flr(py)>=flr(y) and flr(py)<=flr(y+h) then
      --if px>=x and px<=(x+w) and
      --      py>=y and py<=(y+h) then

        return true
      else
        return false
      end
    end

    --box to box intersection
    function intersects_box_box(
      x1,y1,
      w1,h1,
      x2,y2,
      w2,h2)

      local xd=x1-x2
      local xs=w1*0.5+w2*0.5
      if abs(xd)>=xs then return false end

      local yd=y1-y2
      local ys=h1*0.5+h2*0.5
      if abs(yd)>=ys then return false end
      
      return true
    end

    --check if pushing into side tile and resolve.
    --requires self.dx,self.x,self.y, and 
    --assumes tile flag 0 == solid
    --assumes sprite size of 8x8
    function collide_side(self)

      local offset=self.w/3+1.2

      for i=-(self.w/3),(self.w/3),2 do
      --if self.dx>0 then
        if fget(mget((self.x+(offset))/8,(self.y+i)/8),0) then
          self.dx=0
          self.x=(flr(((self.x+(offset))/8))*8)-(offset)
          return true
        end
      --elseif self.dx<0 then
        if fget(mget((self.x-(offset))/8,(self.y+i)/8),0) then
          self.dx=0
          self.x=(flr((self.x-(offset))/8)*8)+8+(offset)
          return true
        end
    --  end
      end
      --didn't hit a solid tile.
      return false
    end

    --check if pushing into floor tile and resolve.
    --requires self.dx,self.x,self.y,self.grounded,self.airtime and 
    --assumes tile flag 0 or 1 == solid
    function collide_floor(self)
      --only check for ground when falling.
      if self.dy<0 then
        return false
      end
      local landed=false
      --check for collision at multiple points along the bottom
      --of the sprite: left, center, and right.
      for i=-(self.w/3),(self.w/3),2 do
        local tile=mget((self.x+i)/8,(self.y+(self.h/2))/8)
        if fget(tile,0) or (fget(tile,1) and self.dy>=0) then
          self.dy=0
          self.y=(flr((self.y+(self.h/2))/8)*8)-(self.h/2)
          self.grounded=true
          self.airtime=0
          landed=true
        end
      end
      return landed
    end

    --check if pushing into roof tile and resolve.
    --requires self.dy,self.x,self.y, and 
    --assumes tile flag 0 == solid
    function collide_roof(self)
      --check for collision at multiple points along the top
      --of the sprite: left, center, and right.
      for i=-(self.w/3),(self.w/3),2 do
        if fget(mget((self.x+i)/8,(self.y-(self.h/2))/8),0) then
          self.dy=0
          self.y=flr((self.y-(self.h/2))/8)*8+8+(self.h/2)
          self.jump_hold_time=0
        end
      end
    end

    --make 2d vector
    function m_vec(x,y)
      local v=
      {
        x=x,
        y=y,
        
      --get the length of the vector
        get_length=function(self)
          return sqrt(self.x^2+self.y^2)
        end,
        
      --get the normal of the vector
        get_norm=function(self)
          local l = self:get_length()
          return m_vec(self.x / l, self.y / l),l;
        end,
      }
      return v
    end

    --square root.
    function sqr(a) return a*a end

    --round to the nearest whole number.
    function round(a) return flr(a+0.5) end


    --utilities
    --------------------------------

    --print string with outline.
    function printo(str,startx,starty,col,col_bg)
      print(str,startx+1,starty,col_bg)
      print(str,startx-1,starty,col_bg)
      print(str,startx,starty+1,col_bg)
      print(str,startx,starty-1,col_bg)
      print(str,startx+1,starty-1,col_bg)
      print(str,startx-1,starty-1,col_bg)
      print(str,startx-1,starty+1,col_bg)
      print(str,startx+1,starty+1,col_bg)
      print(str,startx,starty,col)
    end

    --print string centered with 
    --outline.
    function printc(
      str,x,y,
      col,col_bg,
      special_chars)

      local len=(#str*4)+(special_chars*3)
      local startx=x-(len/2)
      local starty=y-2
      printo(str,startx,starty,col,col_bg)
    end















    --objects
    --------------------------------

    --make the player
    function m_player(x,y)

      local p=
      {
        health=5,
        maxhealth=5,
        hurting=false,
        countdown=0,
        shake_ticks=15,
        shake_force=10,
        shake_ticks_damage=10,
        shake_force_damage=3,
        blood_color=8,
        blood_amount=40,
        blood_countdown=20,
        weapon_pickup_timeout=0,
        type="player",
        x=x,
        y=y,

        dx=0,
        dy=0,

        w=8,
        h=8,
        
        max_dx=1,--max x speed
        max_dy=2,--max y speed

        jump_speed=-1.8, --jump veloclity
        acc=0.05, --acceleration
        dcc=0.8, --decceleration
        air_dcc=1,--(was 2) air decceleration
        grav=0.2, --(was 0.15) gravity 
        
        --helper for more complex
        --button press tracking 
        jump_button=
        {
          update=function(self)
            --start with assumption
            --not a new press.
            self.is_pressed=false
            if btn(5) then
              if not self.is_down then
                self.is_pressed=true
              end
              self.is_down=true
              self.ticks_down+=1
            else
              self.is_down=false
              self.is_pressed=false
              self.ticks_down=0
            end
          end,
          
          --state
          is_pressed=false,--pressed this frame
          is_down=false,--currently down
          ticks_down=0,--how long down
        },

        jump_hold_time=0,--how long jump is held
        min_jump_press=5,--min time jump can be held
        max_jump_press=15,--max time jump can be held

        jump_btn_released=true,--can we jump again?
        grounded=false,--on ground

        airtime=0,--time since grounded
        



        --animation definitions.
        --use with set_anim()
        anims=
        {
          ["stand"]=
          {
            ticks=1,--how long is each frame shown.
            frames={2},--what frames are shown.
          },
          ["walk"]=
          {
            ticks=5,
            frames={3,4,5,6},
          },
          ["jump"]=
          {
            ticks=1,
            frames={1},
          },
          ["slide"]=
          {
            ticks=1,
            frames={7},
          },
          ["death"]=
          {
            ticks=1,
            frames={32},
          },
          
        },

        weapons= 
        {
          [24]=
          {
            weapon_start=
            {
              x=0,
              y=-2,
            },
            weapon_end= 
            {
              x=2,
              y=0,
            },
          },
          [12]=
          {
            weapon_start=
            {
              x=1,
              y=-5,
            },
            weapon_end= 
            {
              x=6,
              y=1,
            },
          },
          [28]=
          {
            weapon_start=
            {
              x=2,
              y=-5,
            },
            weapon_end= 
            {
              x=6,
              y=2,
            },
          },
        },

        attack_anims= 
        {
          ["rest"]= --stand still attack
          {
            ticks=1,
            frames={0},
          },
          ["attack"]= --moving attack
          {
            ticks=5,
            frames={0,1,2,3},--{25,26,27,28,27,26},
          },
        },
        curanim="walk",--currently playing animation
        curframe=1,--current frame of animation.
        animtick=0,--ticks until next frame should show.
        attack_animtick=0,
        curattack_anim="rest",
        curattack_frame=1,
        flipx=false,--show sprite be flipped.
        curweapon=24, --starting weapon
        flip_mod=0, --just here to make collide_side compile
        
        weapon_length=10,
        weapon_offset=1,
        weapon_minus_offset=0,
        dead=false,

        reset_weapon_pickup_timeout=function(self)
          self.weapon_pickup_timeout=120
        end,

        --request new animation to play.
        set_anim=function(self,anim)
          if(anim==self.curanim)return--early out.
          local a=self.anims[anim]
          self.animtick=a.ticks--ticks count down.
          self.curanim=anim
          self.curframe=1
        end,
        set_attack_anim=function(self,attack_anim)
          if(attack_anim==self.curattack_anim)return--early out.
          local a=self.attack_anims[attack_anim]
          self.attack_animtick=a.ticks--ticks count down.
          self.curattack_anim=attack_anim
          self.curattack_frame=1
        end,





    --damage player 

        take_damage=function(self)
          self.health-=1
          sfx(snd.damage)
          if self.health < 1 then
            self:die()
          else
            self.hurting=true
            self.countdown=hurtcountdown
          end
        end,
        die=function(self)
          self:set_anim("death")
          self.dead=true
          explode(self.blood_color,flr(rnd(20))+self.blood_amount,self.blood_countdown+flr(rnd(10)),self.x+4, self.y+4)
        end,

        --call once per tick.
        update=function(self)
          if(self.weapon_pickup_timeout>0) then
            self.weapon_pickup_timeout=self.weapon_pickup_timeout-1
          end
          if self.hurting then
            if self.countdown == 0 then
              self.hurting=false
            else
              self.countdown-=1
            end
          end
          








          --track button presses
          local bl=btn(0) --left
          local br=btn(1) --right

          if self.dead then
            if collide_floor(self) then
              self.grounded=true
            else
              self.dy+=self.grav
              self.dy=mid(-self.max_dy,self.dy,self.max_dy)
              self.y+=self.dy
            end
            return
          end
          
          
          --move left/right
          if bl==true then
            self.dx-=self.acc
            br=false--handle double press
          elseif br==true then
            self.dx+=self.acc
          else
            if self.grounded then
              self.dx*=self.dcc
            else
              self.dx*=self.air_dcc
            end
          end

          --limit walk speed
          self.dx=mid(-self.max_dx,self.dx,self.max_dx)
          
          --move in x
          self.x+=self.dx
          
          --hit walls
          collide_side(self)


          if(btn(4) and self.curattack_anim=="rest") then
            self:set_attack_anim("attack")
            sfx(snd.attack)
          end

          --jump buttons
          self.jump_button:update()
          
          --we allow jump if:
          --  on ground
          --  recently on ground
          --  pressed btn right before landing
          --also, jump velocity is
          --not instant. it applies over
          --multiple frames.
          if self.jump_button.is_down then
            --is player on ground recently.
            --allow for jump right after 
            --walking off ledge.
            local on_ground=(self.grounded or self.airtime<5)
            --was btn presses recently?
            --allow for pressing right before
            --hitting ground.
            local new_jump_btn=self.jump_button.ticks_down<10
            --is player continuing a jump
            --or starting a new one?
            if self.jump_hold_time>0 or (on_ground and new_jump_btn) then
              if(self.jump_hold_time==0)sfx(snd.jump)--new jump snd
              self.jump_hold_time+=1
              --keep applying jump velocity
              --until max jump time.
              if self.jump_hold_time<self.max_jump_press then
                self.dy=self.jump_speed--keep going up while held
              end
            end
          else
            self.jump_hold_time=0
          end
          
          --move in y
          self.dy+=self.grav
          self.dy=mid(-self.max_dy,self.dy,self.max_dy)
          self.y+=self.dy

          --floor
          if not collide_floor(self) then
            self:set_anim("jump")
            self.grounded=false
            self.airtime+=1
          end

          --roof
          collide_roof(self)

          --handle playing correct animation when
          --on the ground.
          if self.grounded then
            if br then
              if self.dx<0 then
                --pressing right but still moving left.
                self:set_anim("slide")
              else
                self:set_anim("walk")
              end
            elseif bl then
              if self.dx>0 then
                --pressing left but still moving right.
                self:set_anim("slide")
              else
                self:set_anim("walk")
              end
            else
              self:set_anim("stand")
            end
          end

          --flip
          if br then
            self.flipx=false
            self.weapon_offset=1
            self.weapon_length=self.curweapon
            self.weapon_minus_offset=0
          elseif bl then
            self.flipx=true
            self.weapon_offset=-1
            self.weapon_length=-1-self.curweapon
            self.weapon_minus_offset=-1
          end

          --anim tick
          self.animtick-=1
          if self.animtick<=0 then
            self.curframe+=1
            local a=self.anims[self.curanim]
            self.animtick=a.ticks--reset timer
            if self.curframe>#a.frames then
              self.curframe=1--loop
            end
          end

          self.attack_animtick-=1
          if self.attack_animtick<=0 then
            self.curattack_frame+=1
            local a=self.attack_anims[self.curattack_anim]
            self.attack_animtick=a.ticks--reset timer
            if self.curattack_frame>#a.frames then
              self.curattack_frame=1--loop
              self:set_attack_anim("rest")
            end
          end
        end,

        --draw the player
        draw=function(self)
          local a=self.anims[self.curanim]
          local frame=a.frames[self.curframe]
          if(self.hurting and ticks%2==0)frame=16
          spr(frame,
            self.x-(self.w/2),
            self.y-(self.h/2),
            self.w/8,self.h/8,
            self.flipx,
            false)
          local a=self.attack_anims[self.curattack_anim]
          local attack_frame=a.frames[self.curattack_frame]
          local offset = 8
          if (self.flipx) then
            offset = -8
          end
          spr(attack_frame + self.curweapon,
            self.x+offset-(self.w/2),
            self.y-(self.h/2),
            self.w/8,self.h/8,
            self.flipx,
            false)
          if(attack_frame+self.curweapon==47) then 
            spr(63,
            self.x+offset+offset-(self.w/2),
            self.y-(self.h/2),
            self.w/8,self.h/8,
            self.flipx,
            false)
          end
        end,
      }

      return p
    end






    --make a monster
    function m_monster(x,y,base_frame,color)

      local p=
      {
        health=1,
        max_health=3,
        hurting=false,
        countdown=0,
        type="monster",
        x=x,
        y=y,

        dx=0,
        dy=0,

        w=8,
        h=8,

        max_dx=0.8,--max x speed
        max_dy=1.5,--max y speed

        jump_speed=-1.2,--jump veloclity
        acc=0.04,--acceleration
        dcc=0.8,--decceleration
        air_dcc=1,--air decceleration
        grav=0.1, --gravity

        shake_ticks=10,
        shake_force=0,
        blood_color=8,
        blood_amount=5,
        blood_countdown=10,
        
        jump_hold_time=0,--how long jump is held
        min_jump_press=5,--min time jump can be held
        max_jump_press=15,--max time jump can be held

        jump_btn_released=true,--can we jump again?
        grounded=false,--on ground

        airtime=0,--time since grounded
        base_frame=base_frame,
        last_frame=0,
        --animation definitions.
        --use with set_anim()
        anims=
        {
          ["stand"]=
          {
            ticks=10,--how long is each frame shown.
            frames={2},--what frames are shown.
          },
          ["walk"]=
          {
            ticks=10,
            frames={3,4,5,6},--{self.base_frame+2, self.base_frame+3, self.base_frame+4, self.base_frame+5},--{19,20,21,22},
          },
          ["jump"]=
          {
            ticks=5,
            frames={1},--17
          },
          ["slide"]=
          {
            ticks=10,
            frames={7},--23
          },
        },

        curanim="stand",--currently playing animation
        curframe=1,--curent frame of animation.
        animtick=0,--ticks until next frame should show.
        attack_animtick=0,
        flipx=false,--show sprite be flipped.
        flip_mod=1,
        hurting=false,
        countdown=-1,
        
        --request new animation to play.
        set_anim=function(self,anim)
          if(anim==self.curanim)return--early out.
          local a=self.anims[anim]
          self.animtick=a.ticks--ticks count down.
          self.curanim=anim
          self.curframe=1
        end,
        
        set_jump_speed=function(self,jump_speed)
          self.jump_speed=speed
        end,
        set_acc=function(self,acceleration)
          self.acc=acceleration
        end,
        set_max_dx=function(self,speed)
          self.max_dx=speed     
        end,
        set_max_dy=function(self,speed)
          self.max_dy=speed
        end,
        set_grav=function(self,gravity)
          self.set_grav=gravity
        end,




        kill=function(self)
        end,



        --call once per tick.
        update=function(self)
          if self.hurting then
            if self.countdown == 0 then
              self.hurting=true
            else
              self.countdown-=1
            end
          end
      
          local br=false
          local bl=false

          if(abs(p1.x - self.x) < 16*8) then
            if(p1.dead) then
              if(self.base_frame!=192) then
                bl=true
              end
            elseif(p1.x > self.x) and (flr(rnd(30)) > 2) then
              br=true
            elseif (p1.x < self.x) and (flr(rnd(30)) > 2) then
              bl=true
            end
          end

          
          --move left/right
          if bl==true then
            self.dx-=self.acc
            br=false--handle double press
          elseif br==true then
            self.dx+=self.acc
          else
            if self.grounded then
              self.dx*=self.dcc
            else
              self.dx*=self.air_dcc
            end
          end

          --limit walk speed
          self.dx=mid(-self.max_dx,self.dx,self.max_dx)
          
          --move in x
          if(self.base_frame!=-1) self.x+=self.dx
          
          --hit walls
          collide_side(self)

          if (self.health>0 and not p1.dead and flr(rnd(30)) == 1) then
            local on_ground=(self.grounded or self.airtime<5)
            --was btn presses recently?
            --allow for pressing right before
            --hitting ground.
            
            --is player continuing a jump
            --or starting a new one?
            if self.jump_hold_time>0 or (on_ground) then
              if(abs(p1.x-self.x)<10*8 and abs(p1.y-self.y)<8*8 and self.base_frame>0) then
                sfx(snd.jump2) --new jump snd
              end
              if(self.jump_hold_time==0) then
                self:set_anim("jump")
              end
              self.jump_hold_time+=1
              --keep applying jump velocity
              --until max jump time.
              if self.jump_hold_time<self.max_jump_press then
                self.dy=self.jump_speed--keep going up while held
              end
            end
          else
            self.jump_hold_time=0
          end
          
          --move in y
          self.dy+=self.grav
          self.dy=mid(-self.max_dy,self.dy,self.max_dy)
          if(self.base_frame!=-1)self.y+=self.dy

          --floor
          if not collide_floor(self) then
            self.grounded=false
            self.airtime+=1
          end

          --roof
          collide_roof(self)

          --handle playing correct animation when
          --on the ground.
          if self.health>0 and self.grounded and self.curanim!="jump" then
            if br then
              if self.dx<0 then
                --pressing right but still moving left.
                self:set_anim("slide")
              else
                self:set_anim("walk")
              end
            elseif bl then
              if self.dx>0 then
                --pressing left but still moving right.
                self:set_anim("slide")
              else
                self:set_anim("walk")
              end
            else
              self:set_anim("stand")
            end
          end

          --flip
          if br then
            self.flipx=false
            self.flip_mod=1
          elseif bl then
            if(self.base_frame!=-1) then 
              self.flipx=true
              self.flip_mod=-1
            end
          end

          --anim tick
          self.animtick-=1
          if self.animtick<=0 then
            self.curframe+=1
            local a=self.anims[self.curanim]
            self.animtick=a.ticks--reset timer
            if self.curframe>#a.frames then
              self.curframe=1--loop
              self:set_anim("stand")
            end
          end
        end,












        --draw the monster
        draw=function(self)
          local a=self.anims[self.curanim]
          local frame=a.frames[self.curframe]
          if(self.base_frame==-1) then
            frame=49
            flipx=false
          end

          
          if(self.base_frame==192) then
            spr(self.base_frame+frame,   self.x-8*self.flip_mod, self.y-20,1,1,self.flipx)

          else
          spr(self.base_frame+frame,
            self.x-(self.w/2),
            self.y-(self.h/2),
            self.w/8,self.h/8,
            self.flipx,
            false)
          end
          self.last_frame = frame
        end,
      }

      return p
    end




    --make a monster
    function m_breakable(x,y,frame)

      --todo: refactor with m_vec.
      local p=
      {
        x=x,
        y=y,

        type="breakable",
        shake_ticks=2,
        shake_force=0,
        blood_color=6,
        blood_amount=10,
        blood_countdown=10,

        dead=false,
        base_frame=frame,

        update=function(self)
        end,

        kill=function(self)
          self.dead=true
        end,
        draw=function(self)
          if not self.dead then
            spr(self.base_frame,x,y)
          end
        end,
      }
      return p
    end



    --make a monster
    function m_consumable(x,y,frame)

      --todo: refactor with m_vec.
      local p=
      {
        x=x,
        y=y,

        frame=frame,
        
        draw=function(self)
          if self.x==32*8 then
            spr(self.frame,self.x,self.y)
          elseif(self.frame==125 or self.frame==126 or self.frame==127 or self.frame==111) then
            spr(self.frame,self.x-12,self.y)
          else
            spr(self.frame,self.x,self.y)
          end
        end,
      }
      return p
    end
        

    --make the camera.
    function m_cam(target)
      local c=
      {
        tar=target,--target to follow.
        pos=m_vec(target.x,target.y),
        
        --how far from center of screen target must
        --be before camera starts following.
        --allows for movement in center without camera
        --constantly moving.
        pull_threshold=8,

        --min and max positions of camera.
        --the edges of the level.
        pos_min=m_vec(64,64),
        pos_max=m_vec(1000,200),
        
        shake_remaining=0,
        shake_force=0,

        update=function(self)

          self.shake_remaining=max(0,self.shake_remaining-1)
          
          --follow target outside of
          --pull range.
          if self:pull_max_x()<self.tar.x then
            self.pos.x+=min(self.tar.x-self:pull_max_x(),4)
          end
          if self:pull_min_x()>self.tar.x then
            self.pos.x+=min((self.tar.x-self:pull_min_x()),4)
          end
          if self:pull_max_y()<self.tar.y then
            self.pos.y+=min(self.tar.y-self:pull_max_y(),4)
          end
          if self:pull_min_y()>self.tar.y then
            self.pos.y+=min((self.tar.y-self:pull_min_y()),4)
          end

          --lock to edge
          if(self.pos.x<self.pos_min.x)self.pos.x=self.pos_min.x
          if(self.pos.x>self.pos_max.x)self.pos.x=self.pos_max.x
          if(self.pos.y<self.pos_min.y)self.pos.y=self.pos_min.y
          if(self.pos.y>self.pos_max.y)self.pos.y=self.pos_max.y
        end,

        cam_pos=function(self)
          --calculate camera shake.
          local shk=m_vec(0,0)
          if self.shake_remaining>0 then
            shk.x=rnd(self.shake_force)-(self.shake_force/2)
            shk.y=rnd(self.shake_force)-(self.shake_force/2)
          end
          return self.pos.x-64+shk.x,self.pos.y-64+shk.y
        end,

        pull_max_x=function(self)
          return self.pos.x+self.pull_threshold
        end,

        pull_min_x=function(self)
          return self.pos.x-self.pull_threshold
        end,

        pull_max_y=function(self)
          return self.pos.y+self.pull_threshold
        end,

        pull_min_y=function(self)
          return self.pos.y-self.pull_threshold
        end,
        
        shake=function(self,ticks,force)
          self.shake_remaining=ticks
          self.shake_force=force
        end
      }
      return c
    end


    --make a particle
    function m_particle()

      local p=
      {
        x=-128,
        y=-128,
        color=13,
        direction_x=0,
        direction_y=0,
        speed=0,
        dead=true,
        countdown=0,

        --call once per tick.
        update=function(self)
          if not self.dead then
            if self.countdown==0 then
              self.dead=true
            else
              self.countdown -= 1
            end
            self.x+=self.direction_x/2
            self.y+=self.direction_y/2
          end
        end,

        --draw the player
        draw=function(self)
          if not self.dead then
            circfill(self.x, self.y, 0, self.color)
          end
        end,

        set_color=function(self, col)
          self.color = col
        end,

        set_direction=function(self, xdir, ydir)
          self.direction_x = xdir
          self.direction_y = ydir
        end,

        set_countdown=function(self, count)
          self.countdown = count
          if(count>0)self.dead=false
        end,
        set_pos=function(self, x1, y1)
          self.x=x1
          self.y=y1
        end,
      }
      return p
    end

    --game flow
    --------------------------------
    --reset the game to its initial
    --state. 
    --use this instead of init()

    ---player starting position
    function reset()
      ex=0
      ey=0
      ticks=0
      hurtcountdown=30
      p1=m_player(6*8,6*8)
      cam=m_cam(p1)
      palt(0,false) 
      palt(11, true)
      monsters = {}




--spawn monsters & stuff

      -- chests global 
      add(monsters, m_breakable(8*86,8*5,98)) --castle 
      add(monsters, m_breakable(8*123+4,8*6,98)) --dark dave
      add(monsters, m_breakable(8*89+4,8*26,98)) --lava tunnel right 


      -- snakes castle 
      add(monsters, m_monster(123*8,8*6,32,2))
      add(monsters, m_monster(120*8,8*9,32,2)) 
      add(monsters, m_monster(127*8,6*8,32,2))


--bat castle
      local monster=m_monster(98*8,1*8,223,2) --bat
              monster:set_max_dx(0.7)
              monster:set_max_dy(0.08)
              monster:set_grav(0)
                      add(monsters, monster)

      local monster=m_monster(88*8,2*8,223,2) --bat
              monster:set_max_dx(0.7)
              monster:set_max_dy(0.08)
              monster:set_grav(0)
                      add(monsters, monster)



      
      -- bats kongo level
      local monster=m_monster(15*8,20*8,223,2) --bat
              monster:set_max_dx(0.5)
              monster:set_max_dy(0.1)
              monster:set_grav(0)
                      add(monsters, monster)
        
      local monster=m_monster(13*8,18*8,223,2) --bat
                monster:set_max_dx(0.7)
                monster:set_max_dy(0.3)
                monster:set_grav(0)
                      add(monsters, monster)



      add(monsters, m_monster(107*8,5*8,48,2)) --goblin imp white door 
      
      add(monsters, m_monster(70*8,5*8,48,2)) --goblin imp castle entrance 

      add(monsters, m_monster(75*8,9*8,48,2)) --goblin imp castle entrance




  -- bridge bat 
      local monster=m_monster(40*8,8*3,223,6) --bat
                monster:set_max_dx(0.5)
              monster:set_max_dy(0.2)
              monster:set_grav(0)
        add(monsters, monster)

              local monster=m_monster(58*8,8*3,223,6) --bat
                monster:set_max_dx(0.7)
              monster:set_max_dy(0.1)
              monster:set_grav(0)
        add(monsters, monster)




      -- goblin bridge
          
          add(monsters, m_monster(45*8,8*9,48,6))
            monster:set_max_dx(0.6)
            monster:set_max_dy(0.4)

                  add(monsters, m_monster(55*8,8*9,48,6))
                    monster:set_max_dx(0.5)
                    monster:set_max_dy(0.4)



      -- big reggae papas entrance
      local monster=m_monster(8*40,8*30,48,13) --fucked up enemy, spawn in lava
        add(monsters, monster)
      
      add(monsters, m_monster(8*8,8*19,48,13)) --goblin imp 

      add(monsters, m_monster(8*22,8*19,48,13)) --goblin imp 


      monster.anims=
        {
          
          ["stand"]=
          {
            ticks=10,
            frames={2},
          },
          ["walk"]=
          {
            ticks=10,
            frames={3,4,5,6},
          },
          ["jump"]=
          {
            ticks=5,
            frames={1},
          },
          ["slide"]=
          {
            ticks=10,
            frames={7},
          },
        }




      consumables = {}



    --boss dark dave
      local monster=m_monster(125*8,4*8,239,13)
        monster:set_max_dx(0.6)     
      add(monsters, monster)


    --boss sensitive steve
      local monster=m_monster(76*8,18*8,247,2)
        monster:set_max_dx(0.6)
      add(monsters, monster)


    --boss grand wizard johannes
      local monster=m_monster(41*8,22*8,215,2)
        monster:set_max_dx(0.2)
        monster:set_max_dy(0.06)
      add(monsters, monster)


    --boss big reggae papa
      add(monsters, m_monster(2*8,28*8,199,13))
      add(monsters, monster)





      
    --lava caves boss room 
      local monster=m_monster(43*8,20*8,207,2) --flying eye 
      monster:set_max_dy(0.05)
      monster:set_max_dx(0.8)
      add(monsters, monster)

      local monster=m_monster(45*8,22*8,207,2) --flying eye 
      monster:set_max_dy(0.07)
      monster:set_max_dx(0.4)
      add(monsters, monster)

      local monster=m_monster(49*8,25*8,207,2) --flying eye 
      monster:set_max_dy(0.08)
      monster:set_max_dx(0.8)
      add(monsters, monster)



    --before gold key 
      local monster=m_monster(23*8,27*8,55,2) --zombie
        monster:set_max_dx(0.3)
        monster:set_max_dy(0.8)
        monster:set_grav(2)
      add(monsters, monster)

    --lava caves right
      local monster=m_monster(8*93,8*29,55,6) --zombie
                  monster:set_max_dx(0.5)
                  monster:set_max_dy(0.8)
                  monster:set_grav(2)
                add(monsters, monster)

              local monster=m_monster(8*96,8*28,55,6) --zombie
                  monster:set_max_dx(0.2)
                  monster:set_max_dy(0.8)
                  monster:set_grav(2)
                add(monsters, monster)



      --hidden axe
      add(consumables,m_consumable(94*8,9*8,48))
      add(consumables,m_consumable(94*8,9*8,255))
      
      --steves mace 
      add(consumables,m_consumable(8*64,17*8,12)) 
      
    
      
      --steves level 
      local monster=m_monster(116*8,21*8,16,2)
        monster:set_max_dx(0.7)
      add(monsters, monster)--skeleton

            local monster=m_monster(121*8,21*8,16,2)
        monster:set_max_dx(0.5)
      add(monsters, monster)--skeleton

      
      --steves room
      local monster=m_monster(86*8,19*8,16,2) 
        monster:set_max_dx(0.3)
      add(monsters, monster)--skeleton


      local monster=m_monster(92*8,18*8,16,2)
              monster:set_max_dx(0.3)
            add(monsters, monster)--skeleton



      local monster=m_monster(8*94,8*19,55,6) --zombie steve level
              monster:set_max_dx(0.2)
              monster:set_max_dy(0.8)
              monster:set_grav(2)
             add(monsters, monster)
      
      local monster=m_monster(8*102,8*16,55,6) --zombie steve level
              monster:set_max_dx(0.4)
              monster:set_max_dy(0.8)
              monster:set_grav(2)
             add(monsters, monster)


    --spikes lava grotto
      for i=39,52 do
        add(monsters, m_monster(8*i+4,8*30+4,-1,6))
      end
     
      for i=56,57 do 
        add(monsters, m_monster(8*i+4,8*30+4,-1,6))
      end 
     
     for i=61,63 do 
        add(monsters, m_monster(8*i+4,8*30+4,-1,6))
      end 


      for i=70,72 do 
        add(monsters, m_monster(8*i+4,8*30+4,-1,6))
      end 

     for i=77,79 do 
        add(monsters, m_monster(8*i+4,8*30+4,-1,6))
     end 

    for i=101,102 do 
        add(monsters, m_monster(8*i+4,8*30+4,-1,6))
     end 
     
     for i=106,120 do 
        add(monsters, m_monster(8*i+4,8*30+4,-1,6))
     end 
     
      for i=125,126 do 
      add(monsters, m_monster(8*i+4,8*30+4,-1,6))
     end 
     

     
     --spikes dark daves lair 
       for i=77,80 do 
      add(monsters, m_monster(8*i+4,8*11+4,-1,6))
     end
     
        for i=89,90 do 
      add(monsters, m_monster(8*i+4,8*9+4,-1,6))
     end 
     
         for i=97,98 do 
      add(monsters, m_monster(8*i+4,8*9+4,-1,6))
     end 
     
     --single spike below silver door
      add(monsters, m_monster(8*102+4,8*10+4,-1,6))

     --spikes steves crypt 
       for i=65,66 do 
      add(monsters, m_monster(8*i+4,8*19+4,-1,6))
     end


      particles = {}
      
      for i=0,100 do
        add(particles, m_particle())
      end

      inventory = {}
      
      item_names = {
      [12]="morgenstjerne",
      [24]="crappy sword",
      [28]="markgrens secret axe",
      [112]="key to dark daves lair",
      [113]="sensitive steves key",
      [114]="grand wizard johannes key",
      [97]="big reggae papas key",
      [116]="health potion"
      }


      --visible potion 1 lava caves 
      add(consumables, m_consumable(8*41+2,8*22,116))

      --visible potion 2 kongo 
      add(consumables, m_consumable(8*22,8*22,116))
      

      
      --locks & keys 
      add(consumables, m_consumable(8*65-4,8*3-1,112)) --silver key
      add(consumables, m_consumable(8*104+8,8*5,126)) --silver lock 
      
      add(consumables, m_consumable(8*120-2,8*16-2,113)) --blue key
      add(consumables, m_consumable(75*8+8,18*8,125)) --blue lock
      
      add(consumables, m_consumable(8*123+1,8*29-1,114)) --red key
      add(consumables, m_consumable(66*8+8,27*8,127)) --red lock

      add(consumables, m_consumable(8*13+2,8*28-1,97)) --gold key
      add(consumables, m_consumable(8*6+9,19*8,111)) --gold lock


      door_countdown=-11
      door_interval=30
      message_time=0
      message = ""
      score = 0
      found_items = {}

      ticks_per_tick=1
      ending_countdown=-1
      doors = { {6,19}, {104,5}, {66,27}, {75,18} }
      music(mus.new_game)

      for door in all(doors) do
        mset(door[1],door[2],119)
      end

      intro_text = { 
        " clausquest v.1.4\n                \n                  \n                  ",
        "     \n     \n    ",
        "     \n     \n     \n",
        "", 
      }
      end_slide_number=0
    end











    --p8 functions
    --------------------------------

    function _init()
        cartdata("clausquest")
      -- only display intro once
      slide_number=1
      reset()
    end

    function _update60()
      if(ticks>100 and ticks<2000) and (ticks%200==0) and slide_number<4 then
        slide_number+=1
      end

      if(ending_countdown==0 and (ticks%200==0) and end_slide_number<15) then
        end_slide_number+=1
      end


      ticks+=1
      if((p1.dead or end_slide_number>12) and btnp(3))reset()

      if ending_countdown==0 then
        return
      elseif ending_countdown>0 then
        ending_countdown -= 1
      end

      if(ticks%ticks_per_tick!=0) then
        return
      end
      
      p1:update()
      
      local unlocked_door=false
      local need_key="locked"

      for consumable in all(consumables) do
        if (abs(consumable.x - p1.x) < 11*8) and (abs(consumable.y - p1.y) < 12*8) and intersects_point_box(p1.x,p1.y,consumable.x, consumable.y,7,7) then
          if consumable.frame==116 then
            top_message("found " .. item_names[consumable.frame])
            if (p1.health<p1.maxhealth) then
              p1.health+=1
              sfx(snd.drink)
            else
              sfx(snd.drink)
            end
            del(consumables, consumable)
          elseif consumable.frame==112 or consumable.frame==113 or consumable.frame==114 or consumable.frame==97 then
            top_message("found " .. item_names[consumable.frame])
            add(inventory, consumable)
            found_item(consumable)
            del(consumables, consumable)        
            sfx(snd.found_key)        
          elseif consumable.frame==48 or consumable.frame==255 then
            explode(6,flr(rnd(20))+10,5+flr(rnd(10)), consumable.x,consumable.y)
            del(consumables,consumable)
            for c2 in all(consumables) do
              if c2.frame==48 or c2.frame==255 then
                add(consumables,m_consumable(c2.x+3,c2.y+1,28))           
                explode(6,flr(rnd(20))+10,5+flr(rnd(10)),c2.x,c2.y)
                del(consumables,c2)
              end
            end

          elseif consumable.frame==126 then
            need_key="dark daves"
            for inv in all(inventory) do
              if inv.frame==112 then
                if (consumable.x==87*8+4) then
                  mset(105,4,120)
                end
                mset(consumable.x/8-1, consumable.y/8,120)
                del(consumables, consumable)
                unlocked_door = true
              end
            end
          elseif consumable.frame==125 then
            need_key="sensitive steves"
            for inv in all(inventory) do
              if inv.frame==113 then
                mset(consumable.x/8-1, consumable.y/8,120)
                del(consumables, consumable)
                unlocked_door = true
              end
            end
          elseif consumable.frame==127 then
            need_key="grand wizard johannes"
            for inv in all(inventory) do
              if inv.frame==114 then
                local t=-1
                if(consumable.x==32*8)t=0
                mset(flr(consumable.x/8) + t, consumable.y/8,120)
                unlocked_door = true
                for c in all(consumables) do
                  if(c.frame==127 and c.y==consumable.y)del(consumables,c)
                end
                del(consumables, consumable)
              end
            end
          elseif consumable.frame==111 then
            need_key="big reggae papas"
            for inv in all(inventory) do
              if inv.frame==97 then
                local t=-1
                if(consumable.x==32*8)t=0
                mset(flr(consumable.x/8) + t, consumable.y/8,120)
                unlocked_door = true
                for c in all(consumables) do
                  if(c.frame==111 and c.y==consumable.y)del(consumables,c)
                end
                del(consumables, consumable)
              end
            end
          elseif p1.weapon_pickup_timeout==0 and (
            consumable.frame==12 or
            consumable.frame==24 or
            consumable.frame==28)then
              top_message("found " .. item_names[consumable.frame])
              found_item(consumable)
              --local temp = p1.curweapon
              p1.curweapon, consumable.frame = consumable.frame,p1.curweapon
              --consumable.frame=temp
              p1:reset_weapon_pickup_timeout()
              sfx(snd.pickup)
          end
        end
      end

      if need_key != "locked" then
        if unlocked_door then
          top_message("door unlocked!")
          door_countdown=door_interval
          sfx(snd.open_lock)
        else
          if(message_time==0)sfx(snd.locked)
          top_message("need " .. need_key .. " key")
        end
      end








      for monster in all(monsters) do   
        if (abs(monster.x - p1.x) < 11*8) and (abs(monster.y - p1.y) < 12*8)then
          if not(monster.base_frame==192 and (abs(monster.y - p1.y) > 5*8))then
            monster:update()
            if(monster.base_frame==240) then
              music(mus.boss)
            end
          end







          local a=p1.weapons[p1.curweapon]  

          -- >hack due to crown at the end
          if (monster.base_frame>255) then
          elseif (monster.base_frame==192) then
            if(not p1.dead and not p1.hurting and monster.curanim=="jump") then 
              if( monster.dy>0 and intersects_point_box(p1.x,p1.y,monster.x,monster.y+3,8,4)) or
                ( monster.last_frame==0  and intersects_point_box(p1.x+4,p1.y+4,monster.x+8*monster.flip_mod,monster.y-20,9,9)) or
                ( monster.last_frame==4  and intersects_point_box(p1.x+4,p1.y+4,monster.x+12*monster.flip_mod,monster.y-18,9,9)) or
                ( monster.last_frame==8  and intersects_point_box(p1.x+4,p1.y+4,monster.x+16*monster.flip_mod,monster.y-9,9,9)) or
                ( monster.last_frame==12 and intersects_point_box(p1.x+4,p1.y+4,monster.x+16*monster.flip_mod,monster.y-4,9,9)) then

                sfx(snd.boss_attack)
              end
            end
      
            if( p1.curattack_anim == "attack" and
              intersects_point_box(p1.x + p1.weapon_minus_offset + (p1.weapon_offset * 4) + (p1.weapon_offset * a["weapon_start"].x), p1.y + 1 + a["weapon_start"].y, monster.x,monster.y-16,6,3) or
                intersects_point_box(p1.x + p1.weapon_minus_offset + (p1.weapon_offset * 4) + (p1.weapon_offset * a["weapon_end"].x),  p1.y + 1 + a["weapon_end"].y, monster.x,monster.y-16,6,3) )
                and not monster.hurting then
              cam:shake(15,3)
              




              -- if monster is dead
              if (monster:take_damage()) then
                for i=1,10 do
                  explode(monster.blood_color,10,30,
                    p1.x + p1.weapon_minus_offset + (p1.weapon_offset * 4) + (p1.weapon_offset * a["weapon_start"].x + flr(rnd(24))-12), 
                    p1.y + 1 + a["weapon_start"].y + flr(rnd(10))-5)
                end
              end
            end





          elseif(not p1.dead and not p1.hurting and monster.type == "monster" and intersects_point_box(p1.x,p1.y,monster.x-4,monster.y-4,7,6)) then
            p1:take_damage()
            cam:shake(p1.shake_ticks_damage,p1.shake_force_damage)
          elseif monster.base_frame == -1 then
            for m in all(monsters) do   
              if  m.base_frame != -1 and intersects_point_box(monster.x + 4, monster.y+4, m.x,m.y,7,7) then
                sfx(snd.hit)
                cam:shake(m.shake_ticks,m.shake_force)
                explode(m.blood_color,flr(rnd(20))+m.blood_amount,m.blood_countdown+flr(rnd(10)),monster.x+4,monster.y+4)
                del(monsters, m)
              end
            end
            





          elseif p1.curattack_anim == "attack" then
            
            if intersects_point_box(p1.x + p1.weapon_minus_offset + (p1.weapon_offset * 4) + (p1.weapon_offset * a["weapon_start"].x), p1.y + 1 + a["weapon_start"].y, monster.x-4,monster.y-4,7,7) 
              or intersects_point_box(p1.x + p1.weapon_minus_offset + (p1.weapon_offset * 4) + (p1.weapon_offset * a["weapon_end"].x),  p1.y + 1 + a["weapon_end"].y, monster.x-4,monster.y-4,7,7) then

                if(monster.base_frame==98) then
                  add(consumables, m_consumable(monster.x+1,monster.y-1,116))
                end
              sfx(snd.hit)
              cam:shake(monster.shake_ticks, monster.shake_force)
              explode(monster.blood_color,flr(rnd(20))+monster.blood_amount,monster.blood_countdown+flr(rnd(10)),monster.x,monster.y)
          
              del(monsters, monster)
              monster:kill()
            end
          end
        end
      end





      for party in all(particles) do
        party:update()
      end

      cam:update()

      if(door_countdown>=0) then
        door_countdown-=1
      end
      if door_countdown==0 then
        for i=122,120,-1 do
          for door in all(doors) do
            if(mget(door[1],door[2])==i) then
              mset(door[1],door[2],i+1)
              door_countdown=door_interval
            end
          end
        end
      end

      if (message_time>0) then
        message_time-=1
      end

    end

    function explode(color,amount,countdown,x,y)
      local i=0
      local directions = {-1,0,1,-1,0,1,-1,0,1}

      for party in all(particles) do
        if party.dead then
          party:set_color(color)
          party:set_pos(x + directions[flr(i/3%3)+1]*3, y + directions[i%3+1]*3)
          party:set_countdown(countdown)
          party:set_direction(directions[flr(i/3)%3+1]*(flr(rnd(3))+1),directions[i%3+1]*(flr(rnd(3))+1))

          i+=1
        end
        if i==amount then
          return
        end
      end
    end











    function _draw()

      cls(0)
      camera(cam:cam_pos())

      map(0,0,0,0,128,128)


    --place and animate torches 

      if (ticks%30<10) then
    --first frame 
        --castle 
        spr(80, 8*57+4, 8*7)
        spr(80, 84*8, 3*8)
        spr(80, 88*8, 3*8)

        --boss room dark dave
        spr(80, 8*114+5, 8*5-1)
        spr(80, 8*118+5, 8*5-1)
        
            --steves crypt
            spr(80, 8*87-1, 17*8) --throne room
            spr(80, 8*92+1, 17*8) --throne room
              
                  --kongo
                  spr(80, 3*8, 17*8)
                  spr(80, 9*8, 17*8)

    --second frame
      elseif (ticks%30<20) then
        spr(81, 8*57+4, 8*7)
        spr(81, 84*8, 3*8)
        spr(81, 88*8, 3*8)

        --boss room dark dave
        spr(81, 8*114+5, 8*5-1)
        spr(81, 8*118+5, 8*5-1)
        
                    --steves
            spr(81, 8*87-1, 17*8)
            spr(81, 8*92+1, 17*8)
              
                    --kongo
                  spr(81, 3*8, 17*8)
                  spr(81, 9*8, 17*8)
                  
    --third frame
      elseif (ticks%30<30) then
        spr(82, 8*57+4, 8*7)
        spr(82, 84*8, 3*8)
        spr(82, 88*8, 3*8)

        --boss room dark dave
        spr(82, 8*114+5, 8*5-1)
        spr(82, 8*118+5, 8*5-1)
        
                    --steves crypt
            spr(82, 8*87-1, 17*8)
            spr(82, 8*92+1, 17*8)
              
                  --kongo
                  spr(82, 3*8, 17*8)
                  spr(82, 9*8, 17*8)
                end




      for consumable in all(consumables) do
        consumable:draw()
    end

      


--place and animate campfire

      if (ticks%27<9) then
    --first frame 
        --claus spawn campfire
        spr(64, 8*8, 8*6)
  --steves zombie campfire
        spr(64, 8*102, 8*22)


    --second frame
      elseif (ticks%27<18) then
        --claus spawn campfire
        spr(108, 8*8, 8*6)
  --steves zombie campfire
        spr(108, 8*102, 8*22)

                  
    --third frame
          elseif (ticks%27<27) then
        --claus spawn campfire
        spr(124, 8*8, 8*6)
  --steves zombie campfire
        spr(124, 8*102, 8*22)
end



--place and animate horses mane

      if (ticks%42<14) then
    --first frame 
        spr(235, 8*9, 8*5)

    --second frame
      elseif (ticks%42<28) then
        spr(78, 8*9, 8*5)
                  
    --third frame
          elseif (ticks%42<42) then
        spr(136, 8*9, 8*5)
end


--place and animate first creek beginning

      if (ticks%42<14) then
    --first frame 
        spr(42, 8*15, 8*7)

    --second frame
      elseif (ticks%42<28) then
        spr(43, 8*15, 8*7)
                  
    --third frame
          elseif (ticks%42<42) then
        spr(44, 8*15, 8*7)
end


--place and animate second creek beginning

      if (ticks%42<14) then
    --first frame 
        spr(42, 8*25, 8*10)

    --second frame
      elseif (ticks%42<28) then
        spr(43, 8*25, 8*10)
                  
    --third frame
          elseif (ticks%42<42) then
        spr(44, 8*25, 8*10)
end



    --place and animate lava 

      if (ticks%45<15) then
    --first frame 

              for i=70,72 do
                add(spr(180, 8*i, 30*8))
              end 

              for i=77,79 do
                add(spr(180, 8*i, 30*8))
              end 

              for i=106,109 do
                add(spr(180, 8*i, 30*8))
              end 

              for i=113,115 do
                add(spr(180, 8*i, 30*8))
              end 

              for i=119,120 do
                add(spr(180, 8*i, 30*8))
              end 

              for i=125,126 do
                add(spr(180, 8*i, 30*8))
              end 

              for i=39,52 do
                add(spr(180, 8*i, 30*8))
              end 

              for i=101,102 do
                add(spr(180, 8*i, 30*8))
              end 

              for i=56,57 do
                add(spr(180, 8*i, 30*8))
              end 

              for i=61,63 do
                add(spr(180, 8*i, 30*8))
              end 



      elseif (ticks%45<30) then
    --second frame

              for i=70,72 do
                add(spr(181, 8*i, 30*8))
              end 

              for i=77,79 do
                add(spr(181, 8*i, 30*8))
              end 

              for i=106,109 do
                add(spr(181, 8*i, 30*8))
              end 

              for i=113,115 do
                add(spr(181, 8*i, 30*8))
              end 

              for i=119,120 do
                add(spr(181, 8*i, 30*8))
              end 

              for i=125,126 do
                add(spr(181, 8*i, 30*8))
              end 

              for i=39,52 do
                add(spr(181, 8*i, 30*8))
              end 

              for i=101,102 do
                add(spr(181, 8*i, 30*8))
              end 

              for i=56,57 do
                add(spr(181, 8*i, 30*8))
              end 

              for i=61,63 do
                add(spr(181, 8*i, 30*8))
              end 

      elseif (ticks%45<45) then
    -- third frame

              for i=70,72 do
                add(spr(182, 8*i, 30*8))
              end 

              for i=77,79 do
                add(spr(182, 8*i, 30*8))
              end 

              for i=106,109 do
                add(spr(182, 8*i, 30*8))
              end 

              for i=113,115 do
                add(spr(182, 8*i, 30*8))
              end 

              for i=119,120 do
                add(spr(182, 8*i, 30*8))
              end 

              for i=125,126 do
                add(spr(182, 8*i, 30*8))
              end 

              for i=39,52 do
                add(spr(182, 8*i, 30*8))
              end

              for i=101,102 do
                add(spr(182, 8*i, 30*8))
              end 

              for i=56,57 do
                add(spr(182, 8*i, 30*8))
              end 

              for i=61,63 do
                add(spr(182, 8*i, 30*8))
              end 
            end 



--place and animate water 

      if (ticks%45<15) then
    --first frame 
              for i=1,27 do
                add(spr(193, 8*i, 30*8))
              end 


          elseif (ticks%45<30) then
        --second frame
              for i=1,27 do
                add(spr(194, 8*i, 30*8))
              end 

      elseif (ticks%45<45) then
            -- third frame
                  for i=1,27 do
                add(spr(195, 8*i, 30*8))
              end
            end



--place and animate first creek stream 

    --first frame 
      if (ticks%42<14) then
              for i=8,28 do
                add(spr(45, 15*8, i*8))
              end 

    --second frame
      elseif (ticks%42<28) then
              for i=8,28 do
                add(spr(46, 15*8, i*8))
              end 

    -- third frame
      elseif (ticks%42<42) then
              for i=8,28 do
           add(spr(47, 15*8, i*8))
        end 
      end 



      --place and animate second creek stream 

    --first frame 
      if (ticks%42<14) then
              for i=11,29 do
                add(spr(45, 25*8, i*8))
              end 

    --second frame
      elseif (ticks%42<28) then
              for i=11,29 do
                add(spr(46, 25*8, i*8))
              end 

    -- third frame
      elseif (ticks%42<42) then
              for i=11,29 do
           add(spr(47, 25*8, i*8))
        end 
      end 




--place and animate first splash zone

      if (ticks%42<14) then
    --first frame 
        spr(70, 8*15, 8*29)

    --second frame
      elseif (ticks%42<28) then
        spr(143, 8*15, 8*29)
                  
    --third frame
          elseif (ticks%42<42) then
        spr(238, 8*15, 8*29)
end


--place and animate second splash zone 

      if (ticks%42<14) then
    --first frame 
        spr(70, 8*25, 8*29)

    --second frame
      elseif (ticks%42<28) then
        spr(143, 8*25, 8*29)
                  
    --third frame
          elseif (ticks%42<42) then
        spr(238, 8*25, 8*29)
end










      for monster in all(monsters) do
        if (abs(monster.x - p1.x) < 10*8 and abs(monster.y - p1.y) < 14*8) then
          if monster.base_frame == 0 then
            pal(13,2)
            pal(6,13)
            pal(0,2)
          end
          monster:draw()
          if monster.base_frame == 0 then
            pal(13,13)
            pal(0,0)
            pal(6,6)
          end
        end
      end








      p1:draw()
      
      --woods trees
        
          spr(101, 3*8, 4*8)
          spr(117, 3*8, 5*8)
          spr(117, 3*8, 6*8)
          
              spr(101, 21*8, 4*8)
              spr(117, 21*8, 5*8)
              spr(117, 21*8, 6*8)
                
                  spr(101, 27*8, 7*8)
                  spr(117, 27*8, 8*8)
                  spr(117, 27*8, 9*8) 

      --castle entrance
      spr(146, 60*8, 7*8)
      spr(146, 60*8, 8*8)
      spr(132, 60*8, 9*8)
        spr(133, 61*8, 7*8)
        spr(132, 61*8, 8*8)
        spr(41, 61*8, 9*8)
          spr(133, 60*8, 6*8)
          spr(133, 61*8, 6*8)
            spr(133, 60*8, 7*8)
            spr(133, 61*8, 7*8)

--in front of waterfall kongo level
      spr(93, 15*8, 29*8)
      spr(92, 25*8, 29*8)


      local a=p1.weapons[p1.curweapon]  

      for party in all(particles) do
        party:draw()
      end

      camera(0,0)

      
      if(message_time>0) then
        printc(message,64,8,6,0,0)
      end

      if (p1.dead) then
        printc("for helvede, claus!\npress down to try again",106,30,6,0,0)
      elseif (ending_countdown==0 and end_slide_number>0) then
        printc(ending_text[end_slide_number],170,50,6,0,0)
        if (end_slide_number>12) then
          if (dget(0) == score and flr(ticks/50)%2==0) then
            printc("highscore: " .. dget(0),170,30,6,0,0)
          end
        end

    
      elseif (slide_number<5) then
        printc(intro_text[slide_number],170,30,6,0,0)
      end


      local tst = 0

      while tst < p1.health do
        spr(176, tst*8, 120)
        tst+=1
      end
      while tst < 5 do
        spr(177, tst*8, 120)
        tst+=1
      end
      while tst < 16 do
        spr(0, tst*8, 120)
        tst+=1
      end
      tst = 6
      for i in all(inventory) do
        spr(i.frame, tst*8, 120)
        tst+=1
      end
    end
__gfx__
00000000bbb9999bbbb9999bbbbb9999bbbb9999bbbb9999bbbb9999bbbb999988888888888888886666776667777767bbbb6bbb777b6bbb77bbbbbbbbbb6bbb
00000000bbb9fffbbbb9fffbbbbb9fffbbbb9fffbbbb9fffbbbb9fffbbbbfff988888666777888886667777777767677bbbdd1bbb77771bbbb77bbbbbbbdd1bb
00000000bbbf0f0bbbbf0f0bbbbbf0f0bbbbf0f0bbbbf0f0bbbbf0f0bbbb0f0f88866677777778886767776677777677bb6d61dbbb67d1dbbbb777bbbb6d61db
00000000bbbffffbbbbffffbbbbbffffbbbbffffbbbbffffbbbbffffbbbbffff8866666776677788867776d666677778bbb111bbbbb111bbbbbb777bbbb111bb
00000000bfdd111bbbd1111bbbfdd111bbbdd111bbbbd111bbbbd111bbbd111186666dd76dd677788666ddddddd67778bb4bdbbbbb4bdbbbbbbb676bbb4bdbbb
00000000bbb11111bbdf1111bbbb1111bbbf1111bbbbdf11bbbbddf1bbbf11118666ddd7dddd6778886676dd666777881fbbbbbb1fbbbbbb1f44161b1fbbbbbb
00000000bbb11112bbb1111bbbbb1111bbbb1111bbbb1111bbbb1111bbbb1111666d67d76d67d77788866677777778884bbbbbbb4bbbbbbbbbbbd1db4bbbbbbb
00000000bb4bbbbbbbb4bb2bbbbbb42bbbbb2b4bbbb2bbb4bbbb2b4bbbbbb4b26676dd7676ddd7778888866677688888bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbb7777bb067770bb067770bb067770bb067770bb067770bb06777abbb077760b7bbbbbb7777bbbb7bbbbbbbbbbbbbbbbddd6bbbb7777bbbbb77bbbbbbbbbbbb
bbb7777bb07070bbb07070bbb07070bbb07070bbb07070bbb07070aabbb07070b67bbbbbbb7777bbb77bbbbbbbbbb7bbbddd6bbbbbb777b7bbb777bbbbbbbbbb
bbb7777bbb07760bbb07760bbb07760bbb07760bbb07760bbb07760ab006770bb67bbbbbbbb767bbbb777bbbbbbb67bbb4bd6bbbbbbbddd7bbbb777bbbbbbbbb
bbb7777bb022d07bb022d0bbb022d0bbb022d0bbb022d0bbb022d0aa0220d0bbb67bbbbbbbb67bbbbbb7777bbbb67bbbb4b6bbbbbbb4bd6bbbbb7ddbbbbbbbbb
bb77777b02e8260b02e8260b02e8260b02e8260b02e8260b02e826aa2e82760b999bbbbbb967bbbbbb9b7777b967bbbbb4bbbbbbbb4b77bb1f444ddb1f444ddb
bb777777028820bb0288207b0288207b0288207b0288207b02882a7a288260701fbbbbbb1f9bbbbb1f96677b1f9bbbbb1fbbbbbb1fbbbbbbbbb7ddd7bbbbbddb
bbb7777bb022d0bbb022d0bbb022d0bbb022d0bbb02260bbb022d0ab02260d0bb9bbbbbb9bbbbbbbbb9bbbbb9bbbbbbbb4bbbbbb4bbbbbbbbbbb777bbbb6dddb
bbb7bb7b07060bbbb07060bbb070060bbb0760bbb0d0070bb07060bbb070060bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb666b
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0000076500000000bbbbbbbbbbbbbbbbbbbbbcbbbc1111cbb111111bb111111b
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb000bbb000bb00007776067760006bbbbbb66bcbbbb66bbbbbb6bcddddcbb111111bb111111b
bbbbbbbbbbb000bbbbbbbbbbbbbbbbbbbbbbbbbbbbb000bbbbbb0222bb02220b000007070707005076bbbbc776bbcb77c6bbbb77b1cccc1bbc1111cbb111111b
bb9999bbbb022200bbb000bbb000bbbbbbb000bbbb022200bbb02a2ab0a2a220000057600077505576cccc677611116776111167b111111bbcddddcbb111111b
bb9fffbb0b222a2a0b022200022200bb0b0222000b222a2abbb02222b022222200550006700000006d1111666dcccc666d111166b111111bb1cccc1bb111111b
bbf0f0bb202e022220222a2a0202220020222a2a202e02220b022e00bb0000e20777656777006776d111111ddccccccddc1111cdb111111bb111111bbc1111cb
bbf8ffbb22e0b000202e022220b22a2a202e022222e0b0002022e0bbbbbb0e220070707070607070b111111bb111111bbcddddcbb111111bb111111bbcddddcb
888888b8b2e0bbbbb2e0b0000bb02222b2e0b000b2e0bbbbb2200bbbbb02222b0576050676000675b111111bb111111bb1cccc1bb111111bb111111bb1cccc1b
bbbbbbbbbb000bbbbb000bbbbb000bbbbb000bbbbb000bbbbb000bbbbb000bbbb03330bbb03330bbb03330bbb03330bbb03330bbb03330bbbb03330b11111111
bbbbbbbb00ddd0bb00ddd0bb00ddd0bb00ddd0bb00ddd0bb00ddd0bb00ddd0bb0993330b0993330b0993330b0993330b0993330b0993330bb033399011111111
bbbbbbbbdd1ddd0bdd1ddd0bdd1ddd0bdd1ddd0bdd1ddd0bdd1ddd0bdd1ddd0b093030bb093030bb093030bb093030bb093030bb093030bbbb03039011111111
bbbbbbbb011ada0b011ada0b011ada0b011ada0b011ada0b011ada0b011ada0bb099390bb099390bb099390bb099390bb099390bb099390bb093990b11111111
bbbbbbbbb011ddd0b011ddd0b011ddd0b011ddd0d011ddd0b011ddd0b011ddd00dd399300dd399300dd399300dd399300dd399300dd399300d39993011111111
bbbbbbbbd3311d0b03311d0b03311d0bd3311d0b03311d0b03311d0bd3311d0b0111990b0111990b0111990b0111990b0111990b0111990b0119910b11111111
bbbbbbbb003330bbd03330bbd03330bb003330bbb03330bbd03330bb003330bb011111500111110b0111110b0111110b0111110b0111110b0111110b11111111
bbbbbbbbbd0001bbb0d010bbbb0d10bbb100d0bbb01d0bbbb0d010bbbb0d010b3000000b0300050bb03050bb0500030b500030bbb03500bbb030050b11111111
bbbbbbbb6777677677677777777777dbb677777776676777bc1111cb499005401166d16d6d1666d16d16d000d100000000c7cd000000c00000000020aa0000aa
bbbbabbb6677677676667776766777677667767767777677bcddddcb99940490d1ddd1dddd16dd106d1dd1006d100000007cd0c00007c000000002220aa00aa0
bbb89bbbd67766676676666d66dddd66666ddd6666777666b1cccc1b944009906d10111111011100d1101100dd100000077ccd000007d0000000002200a0aa00
bbb9a8bb1d66d67776ddddd1dd0044d66dd004dd66d66777b111111b45000050dd1000000006d0001100b0b06d10bbb07c07ccd0007ccd000000000200aaa000
bb89f8bbb1dddd67ddd111bb0440994dd0049940d11dddddb111111b0009900001101100000dd1000001b0b0d10000b0007cd0cd07c7cd000000000200aaa000
bb9a798bbb111dd1111bbbbb499049940990449911bb111bb161111b950940900000110000001100d100bbb010000bb077cccd00000cd0c0000000220aa0aa00
b8a77a98bbbbb11bbbbbbbbb0590544094400094bbbbbbbbb111666b9945094000000000000000006d1000b0610000b0007cccd0007ccd0000000002aa000aa0
897777f8bbbbbbbbbbbbbbbb0050050094440000bbbbbbbb7666766b540000000000000000000000dd1000b0d100bbb0c7c00ccd7c0cccd000000000a00000aa
bbbbbbbbbbb8bbbbbbbbbbbb00009950bbbbbbbb022222222222222222222222888888800888888800000011000000014444444444444444666d166d0000001d
bbb8bbbbbbbbbbbbbbbbbbbb04500940b0bbb0bb00222222888888882222222288888800008888880b0001d60bb001d600005500005500006ddd166d00bb01d6
bbb8bbbbbbb8bbbbbbb8bbbb99540450060b060b00022222222222222222222288888000000888880b0001d6b0b0011dbbbb05400450bbbb11110ddd0b0001dd
bb8fbbbbbbb88bbbbb8fbbbb999400000650060b00002222222222222222222288880000000088880b00001db0000001bbbbb054450bbbbb000000110bbb01d6
bbba8bbbbb87abbbbba78bbb599009500650065000000222888888882222222288800000000008880b0d61110b0001d6bbbbbb0000bbbbbb000000000b00001d
bb444bbbbb444bbbbb444bbb04005990065076500000002222222222222222228800000000000088001dd1d600b001d6bbbbbbbbbbbbbbbb0000000000bb0001
bbb4bbbbbbb4bbbbbbb4bbbb004099407d556d500000000288888888222222228000000000000008001101ddbbb0001dbbbbbbbbbbbbbbbb0000000000000016
bbb4bbbbbbb4bbbbbbb4bbbb099044006dd56dd500000000888888882222222200000000000000000000001100000001bbbbbbbbbbbbbbbb000000000000001d
aa0000aabb0a90bbbbbbbbbbbbbbbbbbbbb00bbbbbb0c0bb8888888800000000000000000022222002222e0010000000bbbb9bbb0000000000000000bbbbbbbb
0aa00aa0b0a9990bb000000bbbbbbbbbbb0650bbbb07c0bb888888880000022002e000000022222002222e006d1000b0bbbbbbbb0000000000000000bbbbbbbb
00a0aa00b0a090bb04444420bbb000bbb066650bbb07d0bb8888888800002220022e00000022222002222e00dd100b0bbbbbfbbb0000000000000000bbbbbbbb
00aaa000bb0a990b44444222bb05660bbb0650bbb07ccd0b88888888000222200222e0000022222002222e001100000bbbb9abbb000010000006d000bbbbbbbb
00aaa000bbb0a0bb4aa44222b0566660bb0650bb07c7cd0b88888888000222200222e0000022222002222e006d10000bbb87abbb11000000011dd000bbb9abbb
0aa0aa00bbb090bba99aa999b0565560b066650bbb0ccbd0888888880022222002222e000022222002222e006d1000b0bb9af8bb66d0001166611011bbb9abbb
aa000aa0bb0a90bb44444222b0566660b066650bb07ccd0b888888880022222002222e000000000000000000dd100bbbb8a7a9fbddd166d16ddd166dbbbbbbbb
a00000aab0a990bb44444222b0566660b066650b7c0cccd0888888880022222002222e00000000000000000011000000897777981111ddd1111111ddbbbbbbbb
bbb00bbbbb0000bbbb0000bbbbbbbbbbbbb00bbbb0c7cd0b0222222255dd6bbb5bdb6bbb5bdb6bbb55dd6bbb5bdb6bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bb06d0bbb0ccdd0bb0ee880bbbbbbbbbbb0940bbb07cdbdb008888885bdb6bbb55dd6bbb5bdb6bbb5bdb6bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b0600d0bb0c00d0bb0e0080bbbbbbbbbbb0dd0bb077ccd0b000222225bdb6bbb5bdb6bbb55dd6bbbbbbbbbbbbbbbbbbbbbbb9bbbbbbbbbbbbbbbbbbbbbbbbbbb
bb0660bbbb0cc0bbbb0880bbbbbb00bbbb06d0bb7cb7ccd00000222255dd6bbb5bdb6bbb5bdb6bbbbbbbbbbbbbbbbbbbbbb8a8bbbbbbbbbbbbbbbbbbbbbbbbbb
bbb060bbbbb0c0bbbbb080bbbbb0650bb06e8d0bb07ccbcc000008885bdb6bbb55dd6bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb979bbbbbdcbbbbbb67bbbbbb28bbb
bbb060bbbb0dc0bbbbb080bbb056650bb06e8d0b77cccd0b000000225bdb6bbb5bdb6bbbbbbbbbbbbbbbbbbbbbbbbbbbbb8faf8bbbbdcbbbbbb67bbbbbb28bbb
bb0d60bbbbb0c0bbbb0e80bb0666650bb068850b007cccd00000000855dd6bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb9a77a9bbbbbbbbbbbbbbbbbbbbbbbbb
bb0660bbbb0dc0bbb0e880bb0666650bb0d5550bc7cbbccd000000005bdb6bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb89777798bbbbbbbbbbbbbbbbbbbbbbbb
1666166dd16616668888888800000011000007600000000066dd1d6d01100150000000001c111cc1b22212220000111202211000220222122122022bb111111b
1d6d16ddd1d61dd6888888880000006d01017776011111116dd101dd015d001100000202111111111111011101012900001000001101110110110112b111111b
01dd1dd111dd01dd88888888000001dd0101070701111111dd11d011015161010000022211111111100000000012a000000211000000000101000012bc1111cb
0011110100110110888888880001011101016761011111111100000001516d5100000022111111112101110101199000000210000100000000001001bcddddcb
00000d6100101d600000008800000066000000060000000010010000015d6d510000000211111111210110000129200000020010000001000000001261cccc1b
00001dd00000110001110088111001dd07776167110111116d000000011d6d5100000002111111112100000019220000000012110000000000000012b161161b
00001100000000000111008866dd06d10070717011011111dd100000015d6d5100000002111111111001000012000000000000120000000000010000b676111b
0000000000000000011100006ddd1dd1067611161101111111000000015d6d510000000011111111210110002000000000000000000000000000001266666667
d1000000166d166d000000001661bbb18888888866d000006616616d05d6dd55015d6d512210210000120122200000000000000200020000000200000000012b
6610000016d1166d010111111dd1bbb1888888886dd10000661dd16d01111111015d6d5199912100001219992210110000110122002020000000200000000012
6d000b001dd166d101011111111bbbbb88888888dd110000dd10011d015d6d51015d6d51a92100010000129a2210110001110122002020000020200000000129
d1000b000011dd1001011111bbbbbbbb888888881100000001100011015d6d51015d6d5121002200002201292110111001110112000200000002000000000012
10000b0066d0000000000000bbbbbbbb00000088d000001000000066015d6d51015d6d5122102100001200121000011000100001000200000000000000000012
6d100b00d6d1000001101111bbbbbbbb011100886611000100100166015d6d51015d6d51a9210000000012992022000000002202002020000000000000000129
dd1000001111000001101111bbbbbbbb011100886d16111d000001dd015d6d51015d6d51992101100001199a201011000011010200202000000000000000129a
110000000000000001101111bbbbbbbb01110000dd1dd16d0000001d015d6d51015d6d5122102110000201992000110000110002000200000000000000000129
0000000053331333333115333311335153331333d666d66d666d166d66d1666d2212222b22102200002201222001100000011002100000002000000000000012
0000000055331355333533533335553333535335dd66dd6d6ddd1ddd6d1dd66d11011012a99121000012199a2201100000011022201000001100000000001122
00011000153311333351331335511135315333511dd61111dd111111d101ddd100001029a92100000000129a2100000000000012210000000101000000001200
000110000155153355113515511113515115511001dd1d661166d1666d1011100010001292100000000001292110001000100012921000000212100000012000
0000000000001153110050111000035110011000001111dd11ddd16d110000000000001222101000000000122000000000000002210000000022210000112000
0110111000000005000000000000003000000000000001116d1116dd000000000000012991000000000012292010010000000100921000000000210001220000
06d166d100000000000000000000030000000000000000006dd11dd1000000000000129a21000000000001290210000000000102a22100000000021012000000
1dd1ddd1000000000000000000000000000000000000000011111111000000000000012910000000000000120020000000000220911000000000002220000000
0000000000000000aaaaaaaab1222122bbbbbbbbbbbbbbbbbbbbbbbb015d6d510000000021110000000000000000000000011122000000000000000000000000
0088088000dd0dd0aaaaaaaa11011001bbbbbbbbbbbbbbbbbbbbbbbb015d6d510000000002910000000000000000000000001200000000000000000001111111
088888e80dddddddaaaaaaaa21000000bbbbbbbbbbbbbbbbbbbbbbbb015d6d510100110000291100000000000010000000112000000010000000000001111111
088888e80dddddddaaaaaaaa92100100bbbbbbbbbbbbbbbbbbb8bbbb015d6d510000110000092210000000000100001000012000010000000000000001111111
00888e8000ddddd0aaaaaaaa210000008888bbbbbbbbb888bb8988bb015d6d51010000000002a210010000000101110001002000000000100000000000000000
00088800000ddd00aaaaaaaa921000009f99888888888999889f9988015d6d511201100000002291100110001001100111210000011000001111010001110011
000080000000d000aaaaaaaaa2210000faff99999f999fff99faff99011111112212211100000021202111020022102121000000122101102222121101110011
0000000000000000aaaaaaaa91100000aaaafffffafffaaaffaaaaff05d6dd552992992100000002000222200000000200000000222102219922292201110000
aaaaaaaa1c111cc1c111cc111c1cc11caa0000aa99000099aa0000aa990000990705555bbb055550bb055550bb055550070555507055550bb0555570b0b0b0b0
aaaaaaaa1111111111111111111111110aa00aa0099009900aa00aa0099009900605555bb0755550b0755550b0755550060555507755550bb0555560b0b0b0b0
0a000a0011111111111111111111111100a0aa000090990000a0aa000090990006050f0bb0650f0bb0650f0bb0650f0b06050f0b0770f0bbbb0f0560bbbbbbbb
0a0a00a011111111111111111111111100aaa0000099900000aaa00000999000999ffff0b06ffff2b06ffff0b06ffff0999ffff00777ff2002fff999bbbbbbbb
0a000aa011111111111111111111111100aaa0000099900000aaa000009990000f22222f0999222209992222099922220f22222202777720022222f0bbbbbbbb
0aaa0a001111111111111111111111110aa0aa00099099000aa0aa0009909900bb022220b0f2222fb0f2222fb0f2222fbb02222fb02777700f22220bbbbbbbbb
0a00a0aa111111111111111111111111aa000aa099000990aa000aa099000990bb055551bb055550bb055550bb055550bb055550b0557777b055550bbbbbbbbb
aaaaa000111111111111111111111111a00000aa90000099a00000aa90000099b050000bbb05001bbbb0510bbbb1050bbb10005bb50b0777bb0501bbbbbbbbbb
2808028b2808028b2808028b2808028b2808028b2808028b2808028bbbbbbbbb55550b4455550b4455550b4455550b4455550b4455550b44b0555544048a9840
08288880082822800828228008282280082822800828888008288880bbbbbbbb055550440555504405555044055550440555504405555044055550440489a840
0288ff80028888800288888002888880028888800288ff800288ff80bbbbbbbb050f0b4b050f0b4b050f0b4b050f0b4bf50f0b4b050f0b4bb0f0504b048a9840
288f71f8288f71f8288f71f82888888828888888288f71f828871ff8bbbbbbbbf56f604b056f604bf56f604bf56f604b556f604ba56f604b06f6504b0489a840
028f12f2028f12f2028f12f2028f12f2028f12f2028f12f202812ff2bbbbbbbb556665f0556665f0556665f0556665f0056665f00aaa65f0566655f002eeee20
0228ff800228ff800228ff800228ff80022888800228ff800228ff80bbbbbbbb0566504bf566504b0566504b0566504b0566504b056aaaa0f566504b04222240
b002880bb002880bb002880bb002880bb002880bb002880bb002880bbdb1bbbb0556504b0556504b0556504b0556504b0556504b05565aaa0565504b04444440
bbb000bbbbb000bbbbb000bbbbb000bbbbb000bbbbb000bbbbb000bbbdd1bbbb55550b4b55550b4b55550b4b55550b4b55550bbb555550aa5555004b04000040
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb2ddddbbbbbbbbbbbdddddddb00000000000000002222200000000000b111111bbbbbbbbb
bbbbbbbb111bbbb1111bbbb1111bbbb1111bbbb1111bbbb1bbbbbbbb2dd0dddbbbbbbbbbdddddddb00000000000000200222000000000000b111111bbbbbbbbb
bb1112bbbe11bb11be11bb11be11bb11be11bb11be11bb11bb1112bb2ddddddbbbbbbbbbbbbb1bdb00000000000000220000000003300000b111161bbbbbbbbb
b11a2a1bbee11112bee11112bee11112bee11112bee11112b11a2a1b2dddbbbbbbbbbbbbbbbb1bbd00000000000000220000000030030000b171111bb0bbbb0b
112111e1bbe1a2abbbe1a2abbbe1a2abbbe1a2abbbe1a2ab112111e12ddddddddbbbbbbbbbbb1bbd00000000000000020000000003030000b111111b04000040
12bbbbeebbb2111bbbb2111bbbb2111bbbb2111bbbb2111b12bbbbee2dddddddddddddb2bbbb1bbd20020000000000020000000000030030bc1111cb04044040
1bbbbbbebbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb1bbbbbbe2ddddddddddddddbbbbb1bbd22002000000000220000000000300300bcddddcb04488440
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb2ddddddddddddddbbbbb2bb222022000000000020000000000300300b66676660489a840
1111070b11110bbb11110bbb1111070b1111770b111170bbb011110bb1ddddddbb0a90a0bb0a90a0bb0a90a0bb0a90a04e4a90a0e0ba90a0bb0a90a0bbbbbbbb
0111160b011110bb011110bb0111160b01111770011117bb011110bbb11dddddbb0aaaa04b4aaaa04b4aaaa04b4aaaa0e7eaaaa00e0aaaa04b4aaaa0bbbbbbbb
010f060b010f0bb0010f0bb0010f060b010f0677010f077bb0f010b0b1bdbbbbbb06070b4e46070b4e46070b4e46070b0e06070bbeee070b4e407060bbbbbbbb
01fff55001fff00701fff00701fff55001fff55701fff07b0fff1007b1bdbbbbbbb07760b4b07760b4b07760b4b07760b4b07760b0eee760b406770bbb0bbbbb
11111f0b111115601111156011111f0b11111f0b1111107711111560b1bdbbbbb0222244b402220bb402220bb402220b0702220bbb0eee0bb402220bb050bb0b
f44940bbf4494f50f4494f50f44940bbf44940bbf4494166f4494f50b1bdbbbb447444e0b722220bb722220bb722220bb422220bbb2eeee00722220b05750050
0111150b0111100b0111100b011110bb011110bb01111077011110bbb1bdbbbbbb022244b4022220b4022220b4022220b4022220bb20eeeeb402222057650575
400000bb04005bbbb0450bbb05040bbb50004bbbb50407bbb04050bbb2b2bbbbb02220bbb4222220b4222220b4222220b0222220b2222ee7b422222056665765
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000101010000000000000000000000000000000000000100010101010100010101010101010000000000010000000000000101020201010000000000000000000000010001010200000000000000010101010000020202
0101000100000102000101010101010001010001000101000001010101000001010101010101010101010101010101010000010100000000010101010101010000010101000000000200000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
00000000000000000000005557575757575757575757575757575757575757575757575757575757575757575757575757575757575757575757579285859000a06d6e6da06e6d6d6ea06e6d6e6da06da06d6e6da06d6e6d6ea06e6d6d6ea06d6ea06d6d6e6d6da06d6d6d6d00006d6d6e6da06ea0a06d6ea06e6d6e6d6ea000
0000000000000000000000007656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656928585905a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000004b5f00000000000000000000000000000000004b
00000000000000000000000000596666585966666666666666666666585966666666666666666666666658596666666666666666666666666666669285854b5b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000905f00000000000000000000000000000000006b
0000000000000000000000000000595800005966665859666666665800005966666666666666666666580000596666666608096666666666666666928585905b000000676800000000006768000000000067680000000000000000006768000000000086805e8148960000004b5b00006768000067680000676800000000004b
004d0000000000000000d700000000000000005958650059666658000000005958596666666666665800000000596666660a0b6666666666669494bfbfbf4b5b91a700696a0000000000696a0000000000696a000000000000000000696a00000000009000006d6d83000000905b0000696a0000696a0000696a000000000090
004c4d00000000000000e7e8ea000000000000000075650059580000000000000000596666666658000000000000596666666666665859666692858585859583000000696a0000000000696a0000000000696a000000000000000000696a000000005c4b005b0000000000006b5f0000696a0000696a0000696a000000ef004b
004c4c00650000000000f7e9ec0000000000000065757500000000000000000000000059666658000000000000000059666666665800005966928500303000000000000000005e81a7000000000000000000005c86495e81960000000000000000000090005f000086488148005b0000696a0000696a0000696a000000df0090
004145424145424145424145424145cf42414542414543000000006500000000000000005958000000000000000000005966665800000000599285003030000000000000000000000000000000a581a5a70000004b0000005b000086960000000000004b005b0000956da06ea0830000696a0000696a0000696a0080a581a54b
0000000000000000000000000000003000000000000053000000657500650000000000000000000000000000000000000059580000000000009285003030000000000000000000000000000000000000000000006b0000005f0000905f00008696000090005b0000000000000000000000000000000000000000000000000090
000000000000000000000000000000300000000000004700000075756575000000000000000000000000000000000000000063006473006300842900303000000000000000000000000000000000000000000000900000005b54544b5b0000905b54546b005f000000000000000000000000000000000000000000000000004b
00000000000000000000000000000030000000000000004142cf4241454245439193a5a6a75ea5a6a5a793a6a7a5a7444145424145424145424145424142805e81a7a5a7915e48a5815e49489600000000868148000000000081a70000a5a7000080a700005b54ff00000000000000008648495e80a74881805e48965d000090
000000000000000000000000000000300000000000000000003000000000005300000097000000970000009700000053000000000000000000000000000000000000000000000000000000005b5454545490000000000000000000000000000000000000000048495e91485e5e49488600000000000000000000005b0000006b
0000000000000000000000000000003000000000000000000030000000000047000000980000009800000098000000530000000000000000000000000000000000000000000000000000000000485e80480000000000000000000000000000000000000000000000000000000000000000000000000000000000005f00000090
00000000000000000000000000000030000000000000000000300000000000534d00009800000098000000984d0000470000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005b0000006b
00000000000000000000000000000030000000000000000000300000000000474c004d980000009800004d984c4d0053000000000000000000000000000000000000000000000000000000006d6e6ea06e6da06e6da06d6da06d6e6da06da06d6ea06d6e6da06d6ea06d6e6da06e6d6e6da06d6e6d6ea06d6d00005b0000004b
5b5e495e4990005fa1a4a1a35e495e30000000000000000000300000000000534c4d4c9800000098004d4c984c4c4d530000000000000000000000000000006e6d6d6e6da06e6da06d6e005b00000000000000970000000000000000000097009700000000000000000000000000000000000000000000000090005f0000006b
5f000000004b005b0000000000000030a06e6d6ea0a06d6ea0300000000000000000000000000000000000000000000000000000000000000000000000005b00000000000000000000006b5f0000000000000098000000000000000000009800980000000000000000000000000000000000000000000000006b005b00000090
5b000000006b005f0000000000000030000000000000000000300000000000000000bcaebabb0000000000000000000000000000000000000000000000005f0000000000000000000000958300000000000000980087000000000000000098009800000000000000000000000000008700005c865e48815e5e00005f0000006b
5b0000000095a0830000000000000030000000000000000000305e5ea1a2a35e805e00000000aebabcaebdbabdbdbb0000000000000000000000000000000081960000000000000000000000000000000000009800980000ef0000ef0000980098000000000000000000000000000098000000956d6da06e6da06d830000004b
5f0000000000000000ed0000000000300000000000000000003000000000000000000000000000000000009d9d9d00aebabd00000000000000000000000000005b545486819600005c865e485e5e8196000028b729b70000df0000df0028b729b700000000000000000000870000009800000000000000000000000000000090
5b0000008648a1a2a3a49600000000300000000000000000003000000000000000000000000000000000009d009d000000008cbbbd000000000000000000000000485e00005b000000900000000000005e48495e5e81a748a7485e815e495e48a79600000000000000000098000000980000000000000000000000000000006b
5f0000006b0000000000009600000030000000000000000000300000000000000000000000000000ef000000009d0000000000009dae000000bd00000000000000000000005a0000004b000000000000000000000000000000000000000000000000960000000000000000b7000000b70000000000000000000000000028294b
5b00000095a06e6d0000000080819630000000000000000000300000000000000000000000000000df000000009e0000000000009d00ab009f00aebdba00000000000000009c0000009b000000000000000000000000ba0000000000bdbd000000000096000000000086815e805e4881914849815e5e86485e4981495e815e00
5f000000000000006b00000000005f30000000a181a1a480a730000000000000000000000000008a8d8d8e0000000000000000009d008cbd8b00009d00b9be8b8c00000000ac000000ab00000000b8be0000000000af00aebabdbdbc0000ab00000000005ea748808100000000b8ba000000b800000000000000000000000000
5a00000000000000956d000000005b300000000000000000003000000000000000000000000000aebabbbc0000000000000000009e0000000000009d00000000009b0000bbbc0000008c0000008b0000ae000000ac0000009d009d0000008c000000000000000000000000b88b009daebd8b00b9bcae0000b8bbbd0000000000
5f0000000000000000004b0000005b300000000000000000003000000000000000ed000000000000000000000000000000000000000000000000009e00000000009b009c0000000000008cbabc000000008cbabbbc0000009d009e00000000aebdbabd00000000babbbd8b0000009d009d00000000008c8b009d8cbabcb90000
5b0000000000000000006b00006e835d00000000000000000030000000000086a1a4960000000000000000000000000000000000000000000000000000000000008cbdbc0000000000000000000000000000000000000000000000000000000000009daebdb88b0000000000000000009d00000000000000009d009d0000ad00
5f0000000000ef0000004b005f000030000000000000ed00003000000000004b00000096000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008a8d8d8e0000000000009d009d00000000000000000000009e00000000000000009e00000000b900
5b0000000000df0000004b005b0000300000000000864896003000000000006b000000008e00000000b38d8d8d8d8d8d8d8da800000000000000b38da8000000b38d8d8d8e000000000000000000000000000000000000008cbabbbc0000000000009e0000000000000000000000000000000000b38da80000000000000000ad
5b5d5c86a1a2a3965d5c6b005b5d5ccf5c5d5c5d5c90005b5dcf5d5c86a35e0000000000008e000000b9beb8bebeb8b8beb88b0000b38da8000099009a0000009900000000a8000000b38d8da8000000b38d8d8d8e000000000000000000008a8d8e000000000000000000000000b38da800000099009a000000000000000099
5f89898989898989898989898989898989898989898989898989898990000000000000000000a8000000000000000000000000000099009a000099009a00000099000000009a0000009900009a00000099000000008e00000000000000008a0000008d8da80000b38da80000000099009a00000099009a0000b38d8da8000099
5b3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f6b000000000000000000aab2b2b2b2b2b2b2b2b2b2b2b2b2b2a900aab2b2a900aab2b2b2a900000000aab2b2b2a90000aab2b2b2a900000000008d8d8d8d8d8d8d8d000000000000aab2b2a900aab2b2b2b2a900aab2b2b2a900aab2b2a90000aab2b2a9
__sfx__
010e0000250112b000330003d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011800000061500400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000106141a005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000a00001041028211282100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000e00001802318003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00100000185271a504000000000000000000002470000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012000000c53418534245343053400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011800002d7353972523104232042330423404235042350428204285022450215502215022d502211032100321000214002110021200212022130221402215022160221702214052150421604217042140421304
011000001042018211182100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000106001a005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01060000182000c4000940007400054000040000400004000c4000c4000c4000c4000c4000c4000c4000c4000c4000c4000c4000c4000c4000c4000c4000c6000020000200242000c20000200000000000000000
011000000f200002000030028100101001c100281002810024000180000c0001000010100102000c2000020000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001040018200182000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000265021a500265021a500265022650226502295022950200000000000000000000000000000024502265021a500265021a500265022650226502245022450200000000000000000000000000000024502
0110000011000110000c0000010011000306001850000000110000020011000002001100000000185000000011000002001100000200110000000018500000001100000200110000020011000110003560000000
011000000720005200042000320003200022000220000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200
0110000011000110000c0000010011000306001850000000110000020011000002001100000000185000010011000002001100000200110000000018500000001100000200110000020011000110003560035600
011000000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400006000020000400242000040000200004000000000400
011000001870024700247002470016700227002270022700187002470024700247001670022700227002270018700247002470024700167002270022700227000700007000060000600005000050000400004000
014800202170021700217002270024700247001f7001f7002070020700207001f7001d7001f7001c7001c7002170021700217002270024700247001c7001c7001d7001f700207002270024700247002470024700
012400200e100151000e100151000e100151000e100151000c100131000c100131000c100131000c100131000f100161000f100161000f100161000f100161000e100151000e100151000c100131000c10013100
011200200c1000960009600096001f6000960009600096000c1000960009600096000060009600096000e7000c1000960009600096001f6000960009600096000c1000960009600096000060009600096000e700
014800200c5000c5000c5000c50010500105001050010500115001150011500115001350013500135001350011500115001150011500135001350013500135001450014500145001450013500135001350013500
013400200573405730057300573507734077300773007735087340873008730087350c7340c7300c7300c73505734057300573005735077340773007730077350d7340d7300d7300d7350c7340c7300c7300c735
014800200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
013200202000020000200002000020000200002000020000200002000020000200001e0001e0001c0001c00023000230002300023000210002100020000200001c0001c0001c0001c0001c0001c0001c0001c000
0132002025000250002500025000230002300021000210002800028000280002800027000270002300023000250002500025000250001e0001e0001e0001e0002300023000230002300023000230002300023000
0132002010100171001910014100101001710019100141000f10014100171001b1000f10014100171001b1000d1001010015100141000d1001010017100191000d1001010015100141000d100101001710019100
0102002015100191001c1001910015100191001c1001910014100191001b10017100121001410015100191001e1001910015100191001210014100151001910017100141001010012100171001e1001b10017100
013200202370023700237002370023700237002370023700237002370023700237002170021700207002070028700287002870028700257002570023700237002070020700207002070020700207002070020700
0132002028700287002870028700287002870028700287002c7002c7002c7002c7002a7002a70028700287002a7002a7002a7002a700257002570025700257002870028700287002870027700277002770027700
0119002001600016000160001600016000160004600076000b60012600166001b6002060028600306003560038600336002d6002960025600206001c6001860012600106000c6000860004600026000260001600
011e00200c505155351853517535135051553518535175350050015535185351a5350050515535185351a53500505155351c5351a53500505155351c5351a53500505155351a5351853500505155351a53518535
000f0020001630020000143002000f635002000020000163001630010000163002000f635001000010000163001630010000163002000f635002000010000163001630f63500163002000f635002000f60300163
003c002000000090550b0550c055090550c0550b0550b0050b0050c0550e055100550e0550c0550b0550000000000090550b0550c0550e0550c0551005510005000000e0551005511055100550c0551005510005
013c00200921409214092140921409214092140421404214022140221402214022140221402214042140421409214092140921409214092140921404214042140221402214022140221402214022140421404214
013c00200521405214052140521404214042140721407214092140921409214092140b2140b214072140721405214052140521405214042140421407214072140921409214092140921409214092140921409214
013c00202150024500285000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011400181860000000000001860018600186001860000000186001860018600000001860000000000001860000000000001860018600186001860018600186000000000000000000000000000000000000000000
010f00200c0730000018605000000c0730000000000000000c0730000000000000000c0730000000000000000c0730000000000000000c0730000000000000000c0730000000000000000c073000000000000000
013c0020025000250004500055000450004500055000750005500055000750007500045000450000500005000250002500045000550004500045000550007500055000550007500095000a500095000750009500
013c00201a50026300155001a5001c500000001a5001c5001d5001c5001a500185001a5000000000000000001a5002100021500180001c5000000018500000001a500000001c500000001a500000000000000000
011e00200550005500025000000002500050000550005500025000000002500000000450004500045000000005500055000250000000025000000005500055000250000000025000000007500075000750000000
013c00200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011400201d1001a1001a1001d1001a1001a1001c1001c1001d1001a1001a1001d1001a1001a1001f1001f1001d1001a1001a1001d1001a1001a1001c1001c1001d1001a1001a1001d1001a1001a1001f1001f100
011e0020091001500009100000000920015000091000000009100000000920000000071000710007100000000910000000091000000009200000000910000000091000000009200000000c2000c2000020000000
015000200700007000050000500003000030000500005000030000300005000050000200002000030000300007000070000500005000030000300005000050000300003000050000500007000070000700007000
01280020131001a1001f1001a10011100181001d100181000f100161001b100161000e100151001a100151000f100161001b1001610011100181001d100181000e100151001a100151001f1001a100131000e100
01280020227002270021700227001f7001f7001f7001f7002470024700227002270021700217001d7001d7001f7001f7002170022700217002170022700247002670026700267002670000000000000000000000
012800202770027700267002470024700247002470024700267002670024700267002270022700227002270024700247002270021700217002170021700217001f7001f7001f7001f7001f7001f7001f7001f700
015000200f0000f0000e0000e000070000700005000050000c0000c000060000600007000090000a0000e0000f0000f0000e0000e000070000700005000050000c0000a000090000200007000070000700007000
012800200f100161001b100161000e100151001a10015100131001a1001f1001a10011100181001d100181000f100161001b100161000e100151001a10015100131001a1001f1001a100131001a1001f1001a100
012800201a5001a500185001a500135001350013500135001b5001b5001a5001a500185001850015500155001650016500185001a50018500185001a5001b500155001550015500155001f5001f5001f5001f500
012800201f5001f5001d5001b500155001550015500155001d5001d5001b5001d5001a5001a5001a5001a5001b5001b5001a5001a50018500185001550015500165001650016500165001a5001a5001a5001a500
013c00201000000500000001000009000000000e0000e0001000000000000001000000000000000e0000e00011000000000000011000000000000010000100001100000000000001100000000000000400004000
011e00201810018500000001710017500000001510015500000001010010100101000000000000000000000015100000000000010100000000000011500115001150011500111001110011100111000000000000
00180020071350e1350a1350e135071350e1350a1350e135071350e1350a1350e135071350e1350a1350e135051350c135081350c135051350c135081350c135051350c135081350c135051350c135081350c135
00180020071350e1350a1350e135071350e1350a1350e135071350e1350a1350e135071350e1350a1350e135081350f1350c1350f135081350f1350c1350f135081350f1350c1350f135081350f1350c1350f135
00180020081350f1350c1350f135081350f1350c1350f135081350f1350c1350f135081350f1350c1350f135071350e1350a1350e135071350e1350a1350e135071350e1350a1350e135071350e1350a1350e135
001800201303015030160301603016030160351303015030160301603016030160351603015030160301a03018030160301803018030180301803018030180350000000000000000000000000000000000000000
001800201303015030160301603016030160351303015030160301603016030160351603015030160301a0301b0301b0301b0301b0301b0301b0301b0301b0350000000000000000000000000000000000000000
001800201b1301a1301b1301b1301b1301b1351b1301a1301b1301b1301b1301b1351b1301a1301b1301f1301a130181301613016130161301613016130161350000000000000000000000000000000000000000
001800201b1301a1301b1301b1301b1301b1351b1301a1301b1301b1301b1301b1351b1301a1301b1301f1301d1301d1301d1301d1301d1301d1301d1301d1350000000000000000000000000000000000000000
__music__
01 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
01 1d 42 43 44
00 18 42 43 44
00 22 42 43 44
00 22 42 43 44
00 22 42 23 44
00 22 23 21 44
00 22 23 43 44
00 22 42 24 44
00 22 21 24 44
00 22 25 43 44
00 22 23 43 44
00 22 23 21 44
00 22 23 24 44
00 22 23 24 44
00 22 25 43 44
00 22 42 43 44
00 22 42 43 44
00 22 28 43 44
00 22 28 43 44
00 22 28 24 44
00 22 28 23 44
00 22 28 23 44
00 22 28 25 44
00 22 28 21 44
00 41 28 21 44
00 41 28 21 44
00 41 42 21 44
00 2d 42 43 44
00 39 42 43 44
00 3a 42 43 44
00 3b 42 43 44
00 39 3c 43 44
00 3a 3d 43 44
00 3b 3e 43 44
00 3b 3f 43 44
00 39 3c 43 44
00 3a 3d 43 44
00 3b 3e 43 44
00 3b 3f 43 44
00 39 3c 43 44
00 3a 3d 43 44
00 3b 3e 43 44
00 3b 3f 43 44
00 39 42 43 44
00 3a 42 43 44
00 3b 42 43 44
02 3b 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
