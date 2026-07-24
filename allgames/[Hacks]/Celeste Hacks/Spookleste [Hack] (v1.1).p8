pico-8 cartridge // http://www.pico-8.com
version 30
__lua__
--~evercore~
--a celeste classic mod base
--v3.7 stable

--original game by:
--matt thorson + noel berry

--cart by: taco360
--based on meep's smalleste
--and akliant's hex loading
--with help from gonengazit

-- [data structures]

function vector(x,y)
  return {x=x,y=y}
end

function rectangle(x,y,w,h)
  return {x=x,y=y,w=w,h=h}
end

-- [globals]

objects,got_fruit,
freeze,delay_restart,sfx_timer,music_timer,
ui_timer=
{},{},
0,0,0,0,-99

-- [entry point]

function _init()
  frames,start_game_flash=0,0
  music(40,0,7)
  load_level(0)
end

function begin_game()
  max_djump,deaths,frames,seconds,minutes,music_timer,time_ticking=1,0,0,0,0,0,true
  music(0,0,7)
  load_level(1)
end

function is_title()
  return lvl_id==0
end

-- [effects]

function rnd128()
  return rnd(128)
end

clouds={}
for i=0,16 do
  add(clouds,{
    x=rnd128(),
    y=rnd128(),
    spd=1+rnd(4),
  w=32+rnd(32)})
end

particles={}
for i=0,24 do
  add(particles,{
    x=rnd128(),
    y=rnd128(),
    s=flr(rnd(1.25)),
    spd=0.25+rnd(5),
    off=rnd(1),
    c=6+rnd(2),
  })
end

dead_particles={}

-- [player entity]

player={
  init=function(this)
    this.grace,this.jbuffer=0,0
    this.djump=max_djump
    this.dash_time,this.dash_effect_time=0,0
    this.dash_target_x,this.dash_target_y=0,0
    this.dash_accel_x,this.dash_accel_y=0,0
    this.hitbox=rectangle(1,3,6,5)
    this.spr_off=0
    this.solids=true
  end,
  update=function(this)
    if pause_player then
      return
    end

    -- horizontal input
    local h_input=btn(‘) and 1 or btn(‹) and-1 or 0

    -- spike collision / bottom death
    if spikes_at(this.x+this.hitbox.x,this.y+this.hitbox.y,this.hitbox.w,this.hitbox.h,this.spd.x,this.spd.y) or this.y>lvl_ph then
      kill_player(this)
    end

    -- on ground checks
    local on_ground=this.is_solid(0,1)

    -- landing smoke
    if on_ground and not this.was_on_ground then
      this.init_smoke(0,4)
    end

    -- jump and dash input
    local jump,dash=btn(Ž) and not this.p_jump,btn(—) and not this.p_dash
    this.p_jump,this.p_dash=btn(Ž),btn(—)

    -- jump buffer
    if jump then
      this.jbuffer=4
    elseif this.jbuffer>0 then
      this.jbuffer-=1
    end

    -- grace frames and dash restoration
    if on_ground then
      this.grace=6
      if this.djump<max_djump then
        psfx(54)
        this.djump=max_djump
      end
    elseif this.grace>0 then
      this.grace-=1
    end

    -- dash effect timer (for dash-triggered events, e.g., berry blocks)
    this.dash_effect_time-=1

    -- dash startup period, accel toward dash target speed
    if this.dash_time>0 then
      this.init_smoke()
      this.dash_time-=1
      this.spd=vector(appr(this.spd.x,this.dash_target_x,this.dash_accel_x),appr(this.spd.y,this.dash_target_y,this.dash_accel_y))
    else
      -- x movement
      local maxrun=1
      local accel=this.is_ice(0,1) and 0.05 or on_ground and 0.6 or 0.4
      local deccel=0.15

      -- set x speed
      this.spd.x=abs(this.spd.x)<=1 and
      appr(this.spd.x,h_input*maxrun,accel) or
      appr(this.spd.x,sign(this.spd.x)*maxrun,deccel)

      -- facing direction
      if this.spd.x~=0 then
        this.flip.x=(this.spd.x<0)
      end

      -- y movement
      local maxfall=2

      -- wall slide
      if h_input~=0 and this.is_solid(h_input,0) and not this.is_ice(h_input,0) then
        maxfall=0.4
        -- wall slide smoke
        if rnd(10)<2 then
          this.init_smoke(h_input*6)
        end
      end

      -- apply gravity
      if not on_ground then
        this.spd.y=appr(this.spd.y,maxfall,abs(this.spd.y)>0.15 and 0.21 or 0.105)
      end

      -- jump
      if this.jbuffer>0 then
        if this.grace>0 then
          -- normal jump
          psfx(1)
          this.jbuffer=0
          this.grace=0
          this.spd.y=-2
          this.init_smoke(0,4)
        else
          -- wall jump
          local wall_dir=(this.is_solid(-3,0) and-1 or this.is_solid(3,0) and 1 or 0)
          if wall_dir~=0 then
            psfx(2)
            this.jbuffer=0
            this.spd.y=-2
            this.spd.x=-wall_dir*(maxrun+1)
            if not this.is_ice(wall_dir*3,0) then
              -- wall jump smoke
              this.init_smoke(wall_dir*6)
            end
          end
        end
      end

      -- dash
      local d_full=5
      local d_half=3.5355339059 -- 5 * sqrt(2)

      if this.djump>0 and dash then
        this.init_smoke()
        this.djump-=1
        this.dash_time=4
        has_dashed=true
        this.dash_effect_time=10
        -- vertical input
        local v_input=btn(”) and-1 or btn(ƒ) and 1 or 0
        -- calculate dash speeds
        this.spd=vector(h_input~=0 and
          h_input*(v_input~=0 and d_half or d_full) or
          (v_input~=0 and 0 or this.flip.x and-1 or 1)
        ,v_input~=0 and v_input*(h_input~=0 and d_half or d_full) or 0)
        -- effects
        psfx(3)
        freeze=2
        -- dash target speeds and accels
        this.dash_target_x=2*sign(this.spd.x)
        this.dash_target_y=(this.spd.y>=0 and 2 or 1.5)*sign(this.spd.y)
        this.dash_accel_x=this.spd.y==0 and 1.5 or 1.06066017177 -- 1.5 * sqrt()
        this.dash_accel_y=this.spd.x==0 and 1.5 or 1.06066017177
      elseif this.djump<=0 and dash then
        -- failed dash smoke
        psfx(9)
        this.init_smoke()
      end
    end

    -- animation
    this.spr_off+=0.25
    this.spr=not on_ground and (this.is_solid(h_input,0) and 5 or 3) or -- wall slide or mid air
    btn(ƒ) and 6 or -- crouch
    btn(”) and 7 or -- look up
    1+(this.spd.x~=0 and h_input~=0 and this.spr_off%4 or 0) -- walk or stand

    --move camera to player
    --this must be before next_level
    --to avoid loading jank
    move_camera(this)

    -- exit level off the top (except summit)
    if this.y<-4 and lvl_id>31 then
    		load_level(lvl_id==32 and 8 or lvl_id==33 and 16 or 30)
    elseif lvl_id==8 and this.x>121 and this.y>56 and this.y<72 then
						load_level(32)
				elseif lvl_id==16 and this.x<-1 and this.y>24 and this.y<48 then
						load_level(33)
				elseif lvl_id==30 and this.x>121 and this.y>88 and this.y<112 then
						load_level(34)
				elseif lvl_id==31 then
						
    elseif this.y<-4 and levels[lvl_id+1] then
      next_level()
				end
    -- was on the ground
    this.was_on_ground=on_ground
  end,

  draw=function(this)
    -- clamp in screen
    if this.x<-1 or this.x>lvl_pw-7 then
      this.x=clamp(this.x,-1,lvl_pw-7)
      this.spd.x=0
    end
    -- draw player hair and sprite
    set_hair_color(this.djump)
    draw_hair(this,this.flip.x and-1 or 1)
    draw_obj_sprite(this)
    unset_hair_color()
  end
}

function set_hair_color(djump)
  	pal(15,(djump==1 and 11 or djump==2 and (11+flr((frames/3)%2)*4) or 13))
			pal(3,(djump==1 and 3 or djump==2 and (8+flr((frames/3)%2)*4) or 12))
end

function draw_hair(obj,facing)
  local last=vector(obj.x+4-facing*2,obj.y+(btn(ƒ) and 4 or 3))
  for i,h in pairs(obj.hair) do
    h.x+=(last.x-h.x)/1.5
    h.y+=(last.y+0.5-h.y)/1.5
    circfill(h.x,h.y,clamp(4-i,1,2),8)
    last=h
  end
end

function unset_hair_color()
  pal(8,8)
end

-- [other entities]

player_spawn={
  init=function(this)
    sfx(4)
    this.spr=3
    this.target=this.y
    this.y=min(this.y+48,lvl_ph)
    cam_x=clamp(this.x,64,lvl_pw-64)
    cam_y=clamp(this.y,64,lvl_ph-64)
    this.spd.y=-4
    this.state=0
    this.delay=0
  end,
  update=function(this)
    -- jumping up
    if this.state==0 then
      if this.y<this.target+16 then
        this.state=1
        this.delay=3
      end
      -- falling
    elseif this.state==1 then
      this.spd.y+=0.5
      if this.spd.y>0 then
        if this.delay>0 then
          -- stall at peak
          this.spd.y=0
          this.delay-=1
        elseif this.y>this.target then
          -- clamp at target y
          this.y=this.target
          this.spd=vector(0,0)
          this.state=2
          this.delay=5
          this.init_smoke(0,4)
          sfx(5)
        end
      end
      -- landing and spawning player object
    elseif this.state==2 then
      this.delay-=1
      this.spr=6
      if this.delay<0 then
        destroy_object(this)
        init_object(player,this.x,this.y)
      end
    end
    move_camera(this)
  end,
  draw=function(this)
    set_hair_color(max_djump)
    draw_hair(this,1)
    draw_obj_sprite(this)
    unset_hair_color()
  end
}

spring={
  init=function(this)
    this.dy,this.delay,this.hide_in,this.hide_for=0,0,0,0
  end,
  update=function(this)
    local hit=this.player_here()
    if this.delay>0 then
      this.delay-=1
    elseif this.hide_for>0 then
      this.hide_for-=1
      if this.hide_for<=0 then
        this.delay=0
      end
    elseif hit then
      hit.y,hit.spd.y,hit.dash_time,hit.dash_effect_time,this.dy,this.delay,hit.djump=this.y-4,-3,0,0,4,10,max_djump
      hit.spd.x*=0.2
      local below=this.check(fall_floor,0,1)
  				if below then
  						break_fall_floor(below)
						end
						psfx(8)
    end
    this.dy*=0.75
    -- begin hiding
    if this.hide_in>0 then
      this.hide_in-=1
      if this.hide_in<=0 then
        this.hide_for=60
      end
    end
  end,
  draw=function(this)
    local dy=flr(this.dy)
    if this.hide_for<=0 then
    		sspr(0,16,8,8-dy,this.x,this.y+dy)
    else
      sspr(0,0,8,8-dy,this.x,this.y+dy)
   	end
  end
}

side_spring={
	 init=function(this)
		  this.dx,this.dir,this.hide_in,this.hide_for=0,this.is_solid(-1,0) and 1 or -1,0,0
	 end,
	 update=function(this)
		  local hit=this.player_here()
    if this.hide_for>0 then
      this.hide_for-=1
      if this.hide_for<=0 then
        this.delay=0
      end
				elseif hit then
			   hit.x,hit.spd.x,hit.spd.y,hit.dash_time,hit.dash_effect_time,this.dx,hit.djump=this.x+this.dir*4,this.dir*3,-1.5,0,0,4,max_djump
			   psfx(8)
      local side=this.check(fall_floor,1,0)
  				if side then
  						break_fall_floor(side)
						end
		  end
		  this.dx*=0.75
		  -- begin hiding
    if this.hide_in>0 then
      this.hide_in-=1
      if this.hide_in<=0 then
        this.hide_for=60
      end
    end
	 end,
	 draw=function(this)
		  local dx=flr(this.dx)
		  if this.hide_for<=0 then
		    sspr(8,16,8-dx,8,this.x+dx*(this.dir-1)/-2,this.y,8-dx,8,this.dir==1)
		  else
		  		sspr(0,0,8-dx,8,this.x+dx*(this.dir-1)/-2,this.y,8-dx,8,this.dir==1)
				end
	 end
}

balloon={
  init=function(this)
    this.offset=rnd(1)
    this.start=this.y
    this.timer=0
    this.hitbox=rectangle(-1,-1,10,10)
  end,
  update=function(this)
    if this.spr==20 then
      this.offset+=0.01
      this.y=this.start+sin(this.offset)*2
      local hit=this.player_here()
      if hit and hit.djump<max_djump then
        psfx(6)
        this.init_smoke()
        hit.djump=max_djump
        this.spr=0
        this.timer=60
      end
    elseif this.timer>0 then
      this.timer-=1
    else
      psfx(7)
      this.init_smoke()
      this.spr=20
    end
  end,
  draw=function(this) 
    if this.spr==20 then
      spr(90+this.offset*8%3,this.x,this.y+6)
      draw_obj_sprite(this)
    end
  end
}

fall_floor={
  init=function(this)
    this.state=0
  end,
  update=function(this)
    -- idling
    if this.state==0 then
      if this.check(player,0,-1) or this.check(player,-1,0) or this.check(player,1,0) then
        break_fall_floor(this)
      end
      -- shaking
    elseif this.state==1 then
      this.delay-=1
      if this.delay<=0 then
        this.state=2
        this.delay=60--how long it hides for
        this.collideable=false
      end
      -- invisible, waiting to reset
    elseif this.state==2 then
      this.delay-=1
      if this.delay<=0 and not this.player_here() then
        psfx(7)
        this.state=0
        this.collideable=true
        this.init_smoke()
      end
    end
  end,
  draw=function(this)
    if this.state~=2 then
      if this.state~=1 then
        spr(34,this.x,this.y)
      else
        spr(37-this.delay/5,this.x,this.y)
      end
    end
  end
}

function break_fall_floor(obj)
  if obj.state==0 then
    psfx(15)
    obj.state=1
    obj.delay=15--how long until it falls
    obj.init_smoke()
    local hit=obj.check(spring,0,-1) or obj.check(side_spring,-1,0)
    if hit then
      hit.hide_in=15
    end
  end
end

smoke={
  init=function(this)
    this.spd=vector(0.3+rnd(0.2),-0.1)
    this.x+=-1+rnd(2)
    this.y+=-1+rnd(2)
    this.flip=vector(maybe(),maybe())
  end,
  update=function(this)
    this.spr+=0.2
    if this.spr>=101 then
      destroy_object(this)
    end
  end
}

fruit={
  if_not_fruit=true,
  init=function(this)
    this.start=this.y
    this.off=0
    this.spr=flr(rnd(8)+70)
  end,
  update=function(this)
    check_fruit(this)
    this.off+=0.025
    this.y=this.start+sin(this.off)*2.5
  end
}

fly_fruit={
  if_not_fruit=true,
  init=function(this)
    this.start=this.y
    this.step=0.5
    this.sfx_delay=8
    this.spr=flr(rnd(5)+72)
  end,
  update=function(this)
    --fly away
    if has_dashed then
      if this.sfx_delay>0 then
        this.sfx_delay-=1
        if this.sfx_delay<=0 then
          sfx_timer=20
          sfx(14)
        end
      end
      this.spd.y=appr(this.spd.y,-3.5,0.25)
      if this.y<-16 then
        destroy_object(this)
      end
      -- wait
    else
      this.step+=0.05
      this.spd.y=sin(this.step)*0.5
    end
    -- collect
    check_fruit(this)
  end,
  draw=function(this)
    draw_obj_sprite(this)
    for ox=-6,6,12 do
      spr((has_dashed or sin(this.step)>=0) and 114 or (this.y>this.start and 116 or 115),this.x+ox,this.y-2,1,1,ox==-6)
    end
  end
}

function check_fruit(this)
  local hit=this.player_here()
  if hit then
    hit.djump=max_djump
    sfx_timer=20
    sfx(13)
    got_fruit[lvl_id]=true
    init_object(lifeup,this.x,this.y)
    destroy_object(this)
  end
end

lifeup={
  init=function(this)
    this.spd.y=-0.25
    this.duration=30
    this.x-=2
    this.y-=4
    this.flash=0
  end,
  update=function(this)
    this.duration-=1
    if this.duration<=0 then
      destroy_object(this)
    end
  end,
  draw=function(this)
    this.flash+=0.5
    ?"1000",this.x-2,this.y,7+this.flash%2
  end
}

fake_wall={
  if_not_fruit=true,
  update=function(this)
    this.hitbox=rectangle(-1,-1,18,18)
    local hit=this.player_here()
    if hit and hit.dash_effect_time>0 then
      hit.spd=vector(sign(hit.spd.x)*-1.5,-1.5)
      hit.dash_time=-1
      for ox=0,8,8 do
        for oy=0,8,8 do
          this.init_smoke(ox,oy)
        end
      end
      init_fruit(this,4,4)
    end
    this.hitbox=rectangle(0,0,16,16)
  end,
  draw=function(this)
    sspr(0,32,16,16,this.x,this.y)
  end
}

function init_fruit(this,ox,oy)
  sfx_timer=20
  sfx(16)
  init_object(fruit,this.x+ox,this.y+oy,flr(rnd(8)+70))
  destroy_object(this)
end

key={
  if_not_fruit=true,
  update=function(this)
    local was=flr(this.spr)
    this.spr=38.5+sin(frames/30)
    if this.spr==39 and this.spr~=was then
      this.flip.x=not this.flip.x
    end
    if this.player_here() then
      sfx(23)
      sfx_timer=10
      destroy_object(this)
      has_key=true
    end
  end
}

chest={
  if_not_fruit=true,
  init=function(this)
    this.x-=4
    this.start=this.x
    this.timer=20
  end,
  update=function(this)
    if has_key then
      this.timer-=1
      this.x=this.start-1+rnd(3)
      if this.timer<=0 then
        init_fruit(this,0,-4)
      end
    end
  end
}

platform={
  init=function(this)
    this.x-=4
    this.hitbox.w=16
    this.last=this.x
    this.dir=this.spr==51 and-1 or 1
  end,
  update=function(this)
    this.spd.x=this.dir*0.65
    if this.x<-16 then this.x=lvl_pw
    elseif this.x>lvl_pw then this.x=-16 end
    if not this.player_here() then
      local hit=this.check(player,0,-1)
      if hit then
        hit.move(this.x-this.last,0,1)
      end
    end
    this.last=this.x
  end,
  draw=function(this)
    spr(51,this.x,this.y-1,2,1)
  end
}

message={
  draw=function(this)
    this.text=" -spookleste mountain-#this memorial to those# spooked on the climb "
    if this.check(player,4,0) then                                 
      if this.index<#this.text then
        this.index+=0.5
        if this.index>=this.last+1 then
          this.last+=1
          sfx(35)
        end
      end
      local _x,_y=8,96
      for i=1,this.index do
        if sub(this.text,i,i)~="#" then
          rectfill(_x-2,_y-2,_x+7,_y+6,7)
          ?sub(this.text,i,i),_x,_y,0
          _x+=5
        else
          _x=8
          _y+=7
        end
      end
    else
      this.index=0
      this.last=0
    end
  end
}

big_chest={
  init=function(this)
    this.state=0
    this.hitbox.w=16
  end,
  draw=function(this)
    if this.state==0 then
      local hit=this.check(player,0,8)
      if hit and hit.is_solid(0,1) then
        music(-1,500,7)
        sfx(37)
        pause_player=true
        hit.spd=vector(0,0)
        this.state=1
        this.init_smoke()
        this.init_smoke(8)
        this.timer=60
        this.particles={}
      end
		    spr(96,this.x,this.y,1,1)
      spr(96,this.x+8,this.y,1,1,true)
    elseif this.state==1 then
      this.timer-=1
      flash_bg=true
      if this.timer<=45 and #this.particles<50 then
        add(this.particles,{
          x=1+rnd(14),
          y=0,
          h=32+rnd(32),
        spd=8+rnd(8)})
      end
      if this.timer<0 then
        this.state=2
        this.particles={}
        flash_bg=false
        new_bg=true
        init_object(orb,this.x+4,this.y+4)
        pause_player=false
      end
      foreach(this.particles,function(p)
        p.y+=p.spd
        line(this.x+p.x,this.y+8-p.y,this.x+p.x,min(this.y+8-p.y+p.h,this.y+8),7)
      end)
    end
    spr(112,this.x,this.y+8,1,1)
    spr(112,this.x+8,this.y+8,1,1,true)
  end
}

orb={
  init=function(this)
    this.spd.y=-4
  end,
  draw=function(this)
    this.spd.y=appr(this.spd.y,0,0.5)
    local hit=this.player_here()
    if this.spd.y==0 and hit then
      music_timer=45
      sfx(51)
      freeze=10
      destroy_object(this)
      max_djump=2
      hit.djump=2
    end
    spr(79,this.x,this.y)
    for i=0,0.875,0.125 do
      circfill(this.x+4+cos(frames/30+i)*8,this.y+4+sin(frames/30+i)*8,1,7)
    end
  end
}

flag={
  init=function(this)
    this.x+=4
    this.score=0
    this.crown=false
    this.offset=2
    this.start=this.y
    for _ in pairs(got_fruit) do
      this.score+=1
    end
  end,
  update=function(this)
  		if this.score<7 or this.score==7 then
  				this.spr=118
  		elseif this.score<14 or this.score==14 then
  				this.spr=119
  		elseif this.score<21 or this.score==21 then
  				this.spr=120
  		end
    		--this.spr=117
    		--this.crown=true
  				--this.offset+=0.01
      --this.y=this.start+sin(this.offset)*2
    if not this.show and this.player_here() then
      sfx(55)
      sfx_timer,this.show,time_ticking=30,true,false
    end
  end,
  draw=function(this)
    draw_obj_sprite(this)
    if this.show then
      rectfill(32,2,96,31,0)
      if this.crown then
    				rectfill(18,2,114,38,0)
    				?"you are spook king!",20,32,7
    		end
      spr(21,55,6)
      ?"x"..this.score,64,9,7
      draw_time(49,16)
      ?"deaths:"..deaths,48,24,7
    end
  end
}

psfx=function(num)
  if sfx_timer<=0 then
    sfx(num)
  end
end

-- [tile dict]
tiles={
  [1]=player_spawn,
  [37]=key,
  [51]=platform,
  [52]=platform,
  [32]=spring,
  [33]=side_spring,
  [23]=chest,
  [20]=balloon,
  [34]=fall_floor,
  [21]=fruit,
  [22]=fly_fruit,
  [64]=fake_wall,
  [103]=message,
  [96]=big_chest,
  [118]=flag
}

-- [object functions]

function init_object(type,x,y,tile)
  if type.if_not_fruit and got_fruit[lvl_id] then
    return
  end

  local obj={
    type=type,
    collideable=true,
    solids=false,
    spr=tile,
    flip=vector(false,false),
    x=x,
    y=y,
    hitbox=rectangle(0,0,8,8),
    spd=vector(0,0),
    rem=vector(0,0),
  }

  function obj.is_solid(ox,oy)
    return (oy>0 and not obj.check(platform,ox,0) and obj.check(platform,ox,oy)) or
    obj.is_flag(ox,oy,0) or
    obj.check(fall_floor,ox,oy) or
    obj.check(fake_wall,ox,oy)
  end

  function obj.is_ice(ox,oy)
    return obj.is_flag(ox,oy,4)
  end

  function obj.is_flag(ox,oy,flag)
    return tile_flag_at(obj.x+obj.hitbox.x+ox,obj.y+obj.hitbox.y+oy,obj.hitbox.w,obj.hitbox.h,flag)
  end

  function obj.check(type,ox,oy)
    for other in all(objects) do
      if other and other.type==type and other~=obj and other.collideable and
        other.x+other.hitbox.x+other.hitbox.w>obj.x+obj.hitbox.x+ox and
        other.y+other.hitbox.y+other.hitbox.h>obj.y+obj.hitbox.y+oy and
        other.x+other.hitbox.x<obj.x+obj.hitbox.x+obj.hitbox.w+ox and
        other.y+other.hitbox.y<obj.y+obj.hitbox.y+obj.hitbox.h+oy then
        return other
      end
    end
  end

  function obj.player_here()
    return obj.check(player,0,0)
  end

  function obj.move(ox,oy,start)
    for axis in all({"x","y"}) do
      obj.rem[axis]+=axis=="x" and ox or oy
      local amt=flr(obj.rem[axis]+0.5)
      obj.rem[axis]-=amt
      if obj.solids then
        local step=sign(amt)
        local d=axis=="x" and step or 0
        for i=start,abs(amt) do
          if not obj.is_solid(d,step-d) then
            obj[axis]+=step
          else
            obj.spd[axis],obj.rem[axis]=0,0
            break
          end
        end
      else
        obj[axis]+=amt
      end
    end
  end

  function obj.init_smoke(ox,oy)
    init_object(smoke,obj.x+(ox or 0),obj.y+(oy or 0),98)
  end

  add(objects,obj)

  if obj.type.init then
    obj.type.init(obj)
  end

  return obj
end

function destroy_object(obj)
  del(objects,obj)
end

function kill_player(obj)
  sfx_timer=12
  sfx(0)
  deaths+=1
  destroy_object(obj)
  dead_particles={}
  for dir=0,0.875,0.125 do
    add(dead_particles,{
      x=obj.x+4,
      y=obj.y+4,
      t=2,
      dx=sin(dir)*3,
      dy=cos(dir)*3
    })
  end
  delay_restart=15
end

-- [room functions]

function next_level()
  local next_lvl=lvl_id+1
  if next_lvl==13 then
  		music(20,500,7)
  elseif next_lvl==12 or next_lvl==22 or next_lvl==31 then --wind music
    music(30,500,7)
  end
  load_level(next_lvl)
end

function load_level(lvl)
  has_dashed=false
  has_key=false

  --remove existing objects
  foreach(objects,destroy_object)

  --reset camera speed
  cam_spdx=0
  cam_spdy=0

  local diff_room=lvl_id~=lvl

  --set level index
  lvl_id=lvl

  --set level globals
  local tbl=get_lvl()
  lvl_x,lvl_y,lvl_w,lvl_h,lvl_title=tbl[1],tbl[2],tbl[3]*16,tbl[4]*16,tbl[5]
  lvl_pw=lvl_w*8
  lvl_ph=lvl_h*8

  --reload map
  --level title setup
  if not is_title() then
    if diff_room then reload() end
    ui_timer=5
  end

  --chcek for hex mapdata
  if diff_room and get_data() then
    --replace old rooms with data
    for i=0,get_lvl()[3]-1 do
      for j=0,get_lvl()[4]-1 do
        replace_room(lvl_x+i,lvl_y+j,get_data()[i*tbl[4]+j+1])
      end
    end
  end

  -- entities
  for tx=0,lvl_w-1 do
    for ty=0,lvl_h-1 do
      local tile=mget(lvl_x*16+tx,lvl_y*16+ty)
      if tiles[tile] then
        init_object(tiles[tile],tx*8,ty*8,tile)
      end
    end
  end
end

-- [main update loop]

function _update()
  frames+=1
  if time_ticking then
    seconds+=frames\30
    minutes+=seconds\60
    seconds%=60
  end
  frames%=30

  if music_timer>0 then
    music_timer-=1
    if music_timer<=0 then
      music(10,0,7)
    end
  end

  if sfx_timer>0 then
    sfx_timer-=1
  end

  -- cancel if freeze
  if freeze>0 then
    freeze-=1
    return
  end

  -- restart (soon)
  if delay_restart>0 then
    cam_spdx,cam_spdy=0,0
    delay_restart-=1
    if delay_restart==0 then
      load_level(lvl_id)
    end
  end

  -- update each object
  foreach(objects,function(obj)
    obj.move(obj.spd.x,obj.spd.y,0)
    if obj.type.update then
      obj.type.update(obj)
    end
  end)

  -- start game
  if is_title() then
    if start_game then
      start_game_flash-=1
      if start_game_flash<=-30 then
        begin_game()
      end
    elseif btn(Ž) or btn(—) then
      music(-1)
      start_game_flash,start_game=50,true
      sfx(38)
    end
  end
end

-- [drawing functions]

function _draw()
  if freeze>0 then
    return
  end

  -- reset all palette values
  pal()

  -- start game flash
  if is_title() and start_game then
    local c=start_game_flash>10 and (frames%10<5 and 7 or 10) or (start_game_flash>5 and 2 or start_game_flash>0 and 1 or 0)
    if c<10 then
      for i=1,15 do
        pal(i,c)
      end
    end
  end

  --set cam draw position
  draw_x=is_title() and 0 or round(cam_x)-64
  draw_y=is_title() and 0 or round(cam_y)-64
  camera(draw_x,draw_y)

  --local token saving
  local xtiles=lvl_x*16
  local ytiles=lvl_y*16

  -- draw bg color
  cls(flash_bg and frames/5 or new_bg and 14 or 0)

  -- bg clouds effect
  if not is_title() then
    foreach(clouds,function(c)
      c.x+=c.spd-cam_spdx
      rectfill(c.x+draw_x,c.y+draw_y,c.x+c.w+draw_x,c.y+16-c.w*0.1875+draw_y,new_bg and 13 or 1)
      if c.x>128 then
        c.x=-c.w
        c.y=rnd(120)
      end
    end)
  end

  -- draw bg terrain
  map(xtiles,ytiles,0,0,lvl_w,lvl_h,4)

  -- platforms
  foreach(objects,function(o)
    if o.type==platform then
      draw_object(o)
    end
  end)

  -- draw terrain
  map(xtiles,ytiles,0,0,lvl_w,lvl_h,2)

  -- draw objects
  foreach(objects,function(o)
    if o.type~=platform then
      draw_object(o)
    end
  end)

  -- particles
  foreach(particles,function(p)
    p.x+=p.spd-cam_spdx
    p.y+=sin(p.off)-cam_spdy
    p.off+=min(0.05,p.spd/32)
    rectfill(p.x+draw_x,p.y%128+draw_y,p.x+p.s+draw_x,p.y%128+p.s+draw_y,p.c)
    if p.x>132 then
      p.x=-4
      p.y=rnd128()
    elseif p.x<-4 then
      p.x=128
      p.y=rnd128()
    end
  end)

  -- dead particles
  foreach(dead_particles,function(p)
    p.x+=p.dx
    p.y+=p.dy
    p.t-=0.2
    if p.t<=0 then
      del(dead_particles,p)
    end
    rectfill(p.x-p.t,p.y-p.t,p.x+p.t,p.y+p.t,14+5*p.t%2)
  end)

  -- draw level title
  if ui_timer>=-30 then
    if ui_timer<0 then
      draw_ui(draw_x,draw_y)
    end
    ui_timer-=1
  end

  -- credits
  if is_title() then
    ?spr(95,88,56)
    ?spr(94,40,56)
    ?sspr(72,48,8,16,28,40)
    ?sspr(80,48,8,16,36,40)
    ?sspr(88,48,8,16,44,40)
    ?sspr(88,48,8,16,52,40)
    ?sspr(96,48,8,16,60,40)
    ?sspr(104,48,8,16,68,40)
    ?sspr(120,48,8,16,76,40)
    ?sspr(72,48,8,16,84,40)
    ?sspr(112,48,8,16,92,40)
    ?sspr(120,48,8,16,100,40)
    
    pset(71,39,2)
    pset(71,38,2)
    pset(70,37,6)
    pset(69,36,6)
    pset(68,35,6)
    pset(67,36,6)
    pset(66,37,13)
    pset(65,38,13)
    pset(64,39,13)
    
    pset(76,41,2)
    pset(77,42,2)
    
    pset(87,59,1)
    pset(86,58,1)
    pset(86,57,2)
    pset(86,56,2)
    pset(86,55,2)
    pset(86,54,2)
    pset(85,53,2)
    pset(84,52,2)
    
    pset(48,56,2)
    pset(49,55,2)
    pset(50,54,2)
    pset(51,54,2)
    pset(52,53,2)
    pset(53,52,2)
    
    ?"Ž/—",55,80,5
    ?"matt thorson",42,96,5
    ?"noel berry",46,102,5
    ?"mod by expl0zion",34,108,5
  end
end

function draw_object(obj)
  (obj.type.draw or draw_obj_sprite)(obj)
end

function draw_obj_sprite(obj)
  spr(obj.spr,obj.x,obj.y,1,1,obj.flip.x,obj.flip.y)
end

function draw_time(x,y)
  rectfill(x,y,x+32,y+6,0)
  ?two_digit_str(minutes\60)..":"..two_digit_str(minutes%60)..":"..two_digit_str(seconds),x+1,y+1,7
end

function draw_ui(draw_x,draw_y)
  rectfill(24+draw_x,58+draw_y,104+draw_x,70+draw_y,0)
  if lvl_title then
    ?lvl_title,64-#lvl_title*2+draw_x,62,7
  else
    local level=lvl_id*100
    ?level.." m",52+(level<1000 and 2 or 0)+draw_x,62+draw_y,7
  end
  draw_time(4+draw_x,4+draw_y)
end

function two_digit_str(x)
  return x<10 and "0"..x or x
end

-- [helper functions]

function round(x)
  return flr(x+0.5)
end

function clamp(val,a,b)
  return max(a,min(b,val))
end

function appr(val,target,amount)
  return val>target and max(val-amount,target) or min(val+amount,target)
end

function sign(v)
  return v~=0 and sgn(v) or 0
end

function maybe()
  return rnd(1)<0.5
end

function tile_flag_at(x,y,w,h,flag)
  for i=max(0,x\8),min(lvl_w-1,(x+w-1)/8) do
    for j=max(0,y\8),min(lvl_h-1,(y+h-1)/8) do
      if fget(tile_at(i,j),flag) then
        return true
      end
    end
  end
end

function tile_at(x,y)
  return mget(lvl_x*16+x,lvl_y*16+y)
end

function spikes_at(x,y,w,h,xspd,yspd)
  for i=max(0,x\8),min(lvl_w-1,(x+w-1)/8) do
    for j=max(0,y\8),min(lvl_h-1,(y+h-1)/8) do
      local tile=tile_at(i,j)
      if (tile==16 and ((y+h-1)%8>=6 or y+h==j*8+8) and yspd>=0) or
        (tile==17 and y%8<=2 and yspd<=0) or
        (tile==18 and x%8<=2 and xspd<=0) or
        (tile==19 and ((x+w-1)%8>=6 or x+w==i*8+8) and xspd>=0) then
        return true
      end
    end
  end
end
-->8
--scrolling level stuff

--level table
--strings follow this format:
--"x,y,w,h,title"
levels={
  [0]="-1,-1,1,1",--title screen
  "0,0,1,1",
  "1,0,1,1",
  "2,0,1,1",
  "3,0,1,1",
  "4,0,1,1",
  "5,0,1,1",
  "6,0,1,1",
  "7,0,1,1",
  "0,1,1,1",
  "1,1,1,1",
  "2,1,1,1",
  "3,1,1,1",
  "4,1,1,1",
  "5,1,1,1",
  "6,1,1,1",
  "7,1,1,1",
  "0,2,1,1",
  "1,2,1,1",
  "2,2,1,1",
  "3,2,1,1",
  "4,2,1,1",
  "5,2,1,1",
  "6,2,1,1",
  "7,2,1,1",
  "0,3,1,1",
  "1,3,1,1",
  "2,3,1,1",
  "3,3,1,1",
  "4,3,1,1",
  "5,3,1,1",
  "6,3,1,1,summit",
  "0,0,1,1,secret candy",
  "0,0,1,1,secreter candy",
  "0,0,1,1,secretest candy",
}

--mapdata table
--printh(get_room(),"@clip")
--rooms separated by commas
mapdata={
		[17]="00000000000000004228292929290b29000000000000455642280b2929292929000000000000443742383929290b29290000000000000000444242282929290b000000000000005354424228292929290000000000000044425242280b29292900000000000000004242423839393939000000101010105442423711111111110000561819191a42524242530000000000003738392929190909090a00000000000044424238392a1111111100000000000000425243132b0000000000200000000000444200133b00000000541b0000000001004200004200000044422b0000400018191a12005253200056522b5300181a28292a125642421b4242372b4200",
		[18]="3a00000038393939293939393939293911001400111111112b11111111112b1100000000000000003b00000000003a00000000000000000011000000000011000000140000100000000000100000000000000000130c12531400130c12001400420000540011544253000011000000004253424253004242000000000000000042424242425242430000000000001400425200444242423753530000100000004300000000444242424253131b1200000000000000000042424242132b1200000001000000101010104252133b12000019191a10101809090a37424243000000290b2919192a34004442424200000000292929290b2a00000042424300000000",
		[19]="0000000000000000130c0000383939290000000000000010100c0000004442280000000000001308090a00170000373800000000000000001308090a5300001110000000000000000000130c374200101b5354000000000000000011444253183b425253100000000000001054424238110044421b1000000000131b42425211100054423b1b00000000133b444243101b424243112b530000000011004442183b424200102b42540000001000424238114437521b2b42375300001b54424311000042423b2b43004252003b4252001000004300112b0000444200004242001801000000543b250000425300424300381a000000524253000044423742000011",
		[20]="292a0044425229292939393939393939293a0000004438393a000043000052432a1200000000000000000000000044002a0d0e0e0e0e0e0e0e0e0e0f100000142919191919191919191919191a120000290b292929292939393939392a12000039393939290b2a42430044373b1200141919191a38393a14000056430000000029290b2a5242440000004400000000002939292a4300000000000054000000002a01383a1400000000000042530000002a2200000000000053000052420000002a5300000000000042000042424300002a4243000000005442430042420000002a4200000000004252005442370000002a525300000000424200424242530000",
		[21]="00000000000000443742430038393929000000000000100000440000004442380000000000130c1200200000000044420000001000001100130c1200000014420000130c12000000001100000000004400000011000000100000000000000000000000000000130c120000140000000000010000000000110000000000000000000c1010101010101010101010100014000809090909090909090909090a1200000c42524242420c42424242421b1200001144424237421144425244423b120000000043144442000042140042420000004556000042425442425300424314000044424242434442425242424200000000000052420000004442374200000000",
		[22]="3e3e3e3f2d2e2e2e2f2c0000002c2d2e000000003d3e3e3e3f2c0000002c2d2e0000000000000000003c0000002c3d3e000000000000000000000000003c00000000000000000000530000000000000000000000530000564200005400000000000054454242564242424242530000005653424242423743000044374254555642424244524242000000000042424242424243004242430060000054424242445242000044425900000065424243000042425300004218191a18191a4200005437430000000c38393a280b2a421d1e1e4200010000181919192929291a2d2e2e1e1e1e1e1f28290b292929292a2d2e2e2e2e2e2e2f2829292929290b2a2d2e2e",
		[23]="290b29292a12000000000000282929292929290b2a1254000000000028290b29292929393a1242430010100c2829292929293a424242423754181919292929290b2a42424252424242383939290b2929292a4242374400444242430038393939292a5242430000000044000000000000292a4242530000000000000000000000292a42430000000000000000000000000b2a0000000000000000000000000000292a0000000000005300000000000000393a00000000000042430000000000000000000000000000420000455600000000000065010000544200004437000000000000180a00005242530000420016000000002b1d1f00424242000042530000",
		[24]="2a42424228290b2929290b29292929292a425242383939393939393929290b292a3743004243000000004442382929292a4300004400101010000042522829292a00000000101d1e1f0000444228290b2a101010101d2e2e2f00001318292929291919191a3d3e3e3f0000132829292929290b29291a425243000013280b292929292929292a37440000001328292929290b2929292a43000010101028292929292929290b2a00001318191a38290b2939393939393a0000132829291a38292952424243000000001328290b291a383942430000000053001328292929291919420159660054420013282929290b29291919191a374252531328292929292929",
		[25]="29292929292a12111111383939292a002929290b292a12000000111111282a0029292929292a12000000000044282a55290b2939393a12000000100042282a4329292a18191a120054551b1244282a5229292a280b2a120044522b1220282a4339393a38392a122000422b1222383a0042000000442b101b00442b1200373753430010000038092a120038090909090900131b120044522b120000004442531325132b120000422b101010100042521300133b12000044380909090a0042431353001100000000111111111100440013424300000100170000000000000000133755455418191a10101010100020001342524242282929191919191a00220013",
		[26]="0b2939393939393929293939393a4242393a425500000042283a12444237425242425243000010443b120054421b43004237440000131b0043000000522b00004243000000132b0000000054422b00005200000000132b0000000000442b00174253455653132b1010101010102819194242524208093909090909090929290b430044000037424242430000132829290000000000004442524242551829292910101010100000424300434228292929191919191a10100c12000044383929293939393939090a1100000000111138295301590000444200000000000000422819191a5300374253000000002554373829292a42544252420000000000524242",
		[27]="292929292929292929290b29393a12422929290b292939393939292a1111005229292929293a11111111383a00000042393929292a1200000000131b00005442191a38393a1200000000132b42530044292919191a1200000000132b4300000029290b292a1200001000132b12000000292929292a1200131b00132b12000000393939392a1214132b00132b00000000000000003b1200132b53132b1400000000000054420000132b42133b0000000000000037524300132b4242420000000000000000420000132b4252430000000000000056425500132b0044425500000001005442424300133b000052430000001a003742420000005200004237000000",
		[28]="3939393939292a4242000013282929294301000054282a5243000013283939390909090a42282a42170000132b42444442425242422829191a1200133b4325005242433743280b292a1200000000000042430000002829292a12000000000000421010101028290b2a1200000000000042080909093939292a1200001000000043111111111113282a1220131b12000000000000000013282a1222132b12000000000000000013282a1010102b1200001010101053001028291919193a1200001919191a425208393939393a120000002929292a004242005437424400140054290b292a0044424242524300000000422929292a222242524200000000005442",
		[29]="290b29292929290b0b2929292a5242283939393939393939393939292a3742381542430044425242423742282a0044520037001000434442431044383a0054420044130c12541442130c1200100000420000001100444242001100130c12104400000000000010375545100011130c140000000000130c4242521b1214001100001000000000114442423b1200000000130c12100000001000431100000000540011130c1200131b1200000000000042010000110000132b12000000004556421a5300000000133b12000000004437422a4200000000001100000053544252422a5253200000000000005442424242372a42371b530000000055424252424242",
		[30]="290b2929393a424243282939393929292929393a1111374217383a524242280b292a1111000052181a12000025372829292a1200000044383a12005256422829292a120000000011110000445244280b292a12000000000000000000431328290b2a101010100000001400000013382929291a18191a1200000000000000132839393a38393a12000010100000001328111111111111001010181a100000132812010000000013181929390a120013381222000000001328293a11110000001110101010000013383a110054001454351919191a120000111100005200534235290b292a12140000530000425442425229290b2a120000545200544237425242",
		[31]="0000000000000000000000000000000000000000000054000000000000000000000000000000370000530000000000000000000054004200005200000000000000000000425542000037005300000000000000004252420000425542000000000000000044424276004252430000000000000000004242181a424253540000000000005652421829291a424252560000000000444218290b29291a3742420000454556424328292929292a43004456004237425200383929290b2a00000042000044425365181a2829393a0c000042000000181919292a383a18191a4253425501003829290b2919192929291a37524218191a282929292929290b292919191a",
		[32]="2a004442383939292939393939390b292a000042524242383a424252080a28292a0054424243001111004242424228292a564243000000000000444242523839291a4200000000101000004242434442292a4253150000181a12005642000000292a4242450000282a12004243000000292919191919190b2a120042001318190b292929393939393a124437551328293939393a4237424300000043001328294242424242424300000000000013280b5242444253000010100000000013282942000043000000181a1200000013282943010000000000282a1200000013282919191a10101010282a1200200013282929290b19191919292a12002200132829",
		[33]="2a4242424242522839393929290b29292a5242434342422b42424338393939392a4243001044423b0000000044420c182a4400001b56421100000000004237282a0015002b43000000000000004442282a0000002b1010101010080a12001328291919190b1919191919191a12000028290b3939392939393939392a12000028292a080a422b0c4252080a2b12001328292a4252423b424442420c2b12001328393a4242431143000044422b1200132852424342000000000000433b120013284300004400100000545300110000002800010000001b0000443742554500002819191a00002b0000224442424253202829292a00002b00005442424242521829",
		[34]="1111282a111111111138393a000000285642383a4255000000111111004556284242111144420014001010105442522852431400563743001318191a0044422842001010004400001328292a001542284313181a101010101038393a000044280013282a080909090909090a101010380013282a1211111111111113181919190013282a120000001400001328290b291413282a1200001010100013282929290013282a12001318191a1213383939390056282a12141328292a1200111111110052383a12001328292a12455600011354421111540013280b2a1244424322134237554542001328292a1242431010104442425242551328292a124213181919",
}

function get_lvl()
  return split(levels[lvl_id])
end

function get_data()
  return split(mapdata[lvl_id],",",false)
end

--not using tables to conserve tokens
cam_x=0
cam_y=0
cam_spdx=0
cam_spdy=0
cam_gain=0.25

function move_camera(obj)
  --set camera speed
  cam_spdx=cam_gain*(4+obj.x+0*obj.spd.x-cam_x)
  cam_spdy=cam_gain*(4+obj.y+0*obj.spd.y-cam_y)

  cam_x+=cam_spdx
  cam_y+=cam_spdy

  if cam_x<64 or cam_x>lvl_pw-64 then
    cam_spdx=0
    cam_x=clamp(cam_x,64,lvl_pw-64)
  end
  if cam_y<64 or cam_y>lvl_ph-64 then
    cam_spdy=0
    cam_y=clamp(cam_y,64,lvl_ph-64)
  end
end

--replace mapdata with hex
function replace_room(x,y,room)
  for y_=1,32,2 do
    for x_=1,32,2 do
      local offset=4096+(y<2 and 4096 or-4096)
      local hex=sub(room,x_+(y_-1)*16,x_+(y_-1)*16+1)
      poke(offset+x*16+y*2048+(y_-1)*64+x_/2,"0x"..hex)
    end
  end
end

--[[
 
short on tokens?
everything below this comment
is just for grabbing data
rather than loading it
and can be safely removed!
 
--]]

--returns mapdata string of level
--printh(get_room(),"@clip")
function get_room(x,y)
  local reserve=""
  local offset=4096+(y<2 and 4096 or 0)
  y=y%2
  for y_=1,32,2 do
    for x_=1,32,2 do
      reserve=reserve..num2hex(peek(offset+x*16+y*2048+(y_-1)*64+x_/2))
    end
  end
  return reserve
end

--convert mapdata to memory data
function num2hex(number)
  local resultstr=""
  while number>0 do
    local remainder=1+number%16
    number\=16
    resultstr=sub("0123456789abcdef",remainder,remainder)..resultstr
  end
  return #resultstr==0 and "00" or #resultstr==1 and "0"..resultstr or resultstr
end
__gfx__
0000000000f330000f3300000f3300000ff3000000033f00000f00000f3300005dddd5dddddd5ddddd5dddd5222212225dddddd5033333333333333333333330
0000000009944990099449900994499009944990099449900003300009944990ddddd5dddddd5ddddd5ddddd55552dd5dddddddd333333335335353353353333
0000000099999999999999999999999999999999999999990994499099991919dd55125555512555512555dd52222255dd5551dd335531351151113511511333
000000009a9a19199a9a19199a9a19199a9a19199191a9a9999999999a9a1919d5111151111155111125111d12d55521d151115d351351112421411124214130
000000009a9a19199a9a19199a9a19199a9a19199191a9a99a9aa9a99a9aa9a9d5252222122222222212225d22555152d522221d251141521251414212514142
000000009a4aa9a99a4aa9a99a4aa9a99a4aa9a99a9aa4a99a9a19199a4aa9a9dd512d55512dd55512d551dd52511125dd2d55dd141421411414215114142111
0000000009499490094994900949949001499490094994109a4a191909499490dddd5ddddd5dddddd5dddddd55222225dddddddd021124214211242142112410
00000000001001000010001001000010000000100001000009499490001001005ddd5ddddd5dddddd5ddddd5111251115dddddd5001221141142211411422100
00000000ddd5ddd55500000000000ddd008888004494490000000000000000005ddd5dddddd5dddddd5dddd55dddddd503333330033333333333333333333330
00000000d6d5d6d5dd6000000006666d088888802442888800eeee0000000000dddd5dddddd5dddddd5ddddddddddddd33333333333333335335353353353333
00000000d660d660d6666000000006dd08788880224897790e7eee2009999990dd51255555125555512555dddd5115dd33551333335531351151113511511333
0060006006000600ddd0000000000055088888804eeee7997eeee22792222229d5112511111251111125111dd512211d35134130351351112421411124214130
00600060060006005500000000000ddd08888880e7eee2797eeee227922222290122222222222252222225200225222031124112312214121251451212114112
066d066d00000000dd6000000006666d08888880eeee22790eee2220994a9499dd5552d555551dd5551d5555dd52d55504141141241421411414214114142141
5d6d5d6d00000000d6666000000006dd00888800eeee22880022220092299229d555155555512d5551255551d512555121411410124124254211242142112422
5ddd5ddd00000000ddd000000000005500000000eee2220000000000922222295111125111112511112511105112511012122212041221141512211411122210
00000000000000004999999449999994499909940024444000024400000020000252222125222222222221200222122014121512141214122141151421411512
0000000000040000911111199111411991140919004000400004040000004000dd552d555551d5555552d552dd552d5521244121212421141421412114214121
0000000000095050911111199111911949400419004204200004020000004000d55125555512555555125551d551255101141140011411411114114211141140
04999940000905059111111994940419000000440004420000002000000040005511251111125111111251115511251144212211442141212421221124212211
00500500000905059111111991140949940000000000400000004000000040000222212222222252225222500225222025114142251141521251414212514142
0005500000095050911111199111911991400499002240000002400000002000dd5552d5552dd555552d5555dd52d55214142111141421411414215114142111
0050050000040000911111199114111991404119000240000000400000002000d5551255512d555551255551d512555102112410021124214211242142112410
00055000000000004999999449999994440049940044400000024000000040005111125111251111112511115112511120122124201221141142211411422124
2fff2fff2fff2fff2fff2fff00066066600666000050000000500005550550550222212222225222222122200222122014121512141214124121211421411512
4244442442442244422444420666666d666666600050050000d0000d00000500dd552d5555552dd55552d555dd552d5521244121212421141241452114214121
00004200000000000044000066ddddddd66d666605ddd0d0050dddd000500500d551255555512d5555125551d551255d01141140011411415112114111141140
0002400000000000000220006d666ddd6ddddd665000500d5000500d050000505111251111112551111251112511211d44212211442141211412422224212211
0022000000000000000024000000000000000000d0050005d005000555000005d2225222222222122252222dd125221d25114142251141521141141212514142
04400000000000000000042000000000000000000dddd0500d0ddd5000500500dd5512d555512d55512d55dddd1111dd14142114141421414212511414142111
2400000000000000000000420000000000000000d0000d000050050000555000ddddd5ddddd5dddddd5ddddddddddddd02112410021124211414242142112410
20000000000000000000000400000000000000005000050000000500005000005dddd5ddddd5dddddd5dddd55dddddd501421220001221142100124111422100
5dddd5dddd5dddd55505505555555055555550550000000000000000000000000000000000000000000000000449449000000000499249920bbb000000777700
ddddd5dddd5ddddd0000050000000550000005000000000000000000000770000449449000788700008888000244244000eeee0044424442b7bb300007000070
ddd512d5512d5ddd0000050000000500000005000000000080999a0700777700024424400777877008977980062422400e7eee2022202220bbbb3b0070770007
dd111251112511dd000005000000000000000500000000008689aa6700999900022422400887778008979980086944600eeee22049924992bbb33b007077bb07
d12222222221221d5505505555050000000050555550555596887a6a09999990044944900877788008997980082626600eeee220444244420333b300700bbb07
55d5552dd552d555005000000050000000000500000500009087770a0aaaaaa0024424400778777008977980088262800eee22202220222000bb3700700bbb07
dd55512d555255dd00500000050000000000005000050000000000000aaaaaa00224224000788700008888000828828000222200499249920000007007000070
d5111125111251dd0050000000000000000000000005000000000000000000000000000000000000000000000888888000000000444244420000000700777700
d12222122222225d5500005550000000000000055000000000000005000000000000000000ddd50000006000000060000006000010f330010000000000000000
dd2dd5552d5552dd000000000500000000000050050000000000000000000000000000000ddddd50000060000000600000060000099449900000000102000000
552d55512555125500000000000000000000050000000000000005000000000000000000055d5d50000600000000600000060000991991a90000002010200000
d1251111251112dd000005000000000000000500000500000000550000000000000000000ddddd500006000000006000000600009a1aa1a90000010000020000
dd5222221222221d00055055550550000005505555055055550500550005dddddddd50000d555d500006000000060000000060009a9119a90000010000010000
ddd1125125211ddd0050000000500500005000000050000000500000005dddddddddd5000ddddd500006000000060000000060009a4119a90000010000001000
ddddd5dddd5ddddd005000000050000000500000005000000050000000dddddddddddd0005d55d50000060000006000000006000094994900000000000000000
5dddd5dddd5dddd5005000000050000550500000005000000050000000d55555d5d55d000ddddd50000060000006000000006000001001000001000000000010
0000000005000000000000000000000070000000000000000052000000dddddddddddd0000000000000000000000000000020000000200060000000000000000
0099999905500500007700000770070006000007000000000500500000d55d5555d55d0000000000000000000000000000d00000000020600000000000000000
092222220055500000766070066700000000000000000000500ddd0000dddddddddddd000000000000000000000000000200000000000d000000000000000000
92244444005500000666677006600000000000000000060650ddddd000ddd555d55ddd0000000000000000000000000000000000000000000000000000000000
92444444055500050766667000006000000000000000006d500a7a0000dddddddddddd0006666600666666000666660066000660660000006666660066666600
922222220005505507766670000006700000000000000d60500a7a0000dddddddddddd0066666660666666606666666066006660660000006666666066666660
9222222205055550070767000007077007000060000006d0500ddd0000dd45ddd1445d0066000000660006606600066066066600660000000066000066000000
92222222005555000000000070000000000000000000d600500000000115544511454450ddddddd0ddddddd0dd000dd0ddddd000dd00000000dd0000dddd0000
9999949905555050000000000000000000000000900aa009004442000a1c88b003ea0878000000d0dddddd00dd000dd0dd0ddd00dd0000d000dd0000dd000000
9111119155550000000777770000000000000000a9a78a9a00099000a414c42b0e33a7b7ddddddd0dd000000ddddddd0dd00ddd0ddddddd000dd0000dddddd00
9142919155500000007766700000000000000000aaa88aaa0094420000499200ecc8a99b0ddddd00dd0000000ddddd00dd000dd0ddddddd000dd0000ddddddd0
9242229955505000076777000000000000000000aaaaaaaa0494442004944420c8844a9b00000000000000000000000000000000000000000000000000000000
92444499555500000776600007777700000000000000000044494422449444224c84492200000000000000000000000000000000000000000000000000000000
92422211055550000777700007777670077000000000000044444222444442224444422200000000000000000000000000000000000000000000000000000000
92429222055555500000000000000077007777700000000044442222444422224444222200000000000000000000000000000000000000000000000000000000
91424444555555550000000000000000000777770000000002222220022222200222222000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000a3000000839393939293939393939293000000000000000031c000008393939292a20044242592929293939393939393
00000000000000447324340083939392e3e3e3f3d2e2e2e2f2c2000000c2d2e292b09292a22100000000000082929292a22424248292b0929292b09292929292
000000000000000000000000000000001100410011111111b21111111111b211000000000000000101c000000044248292a3000000448393a300003400002534
0000000000000100004400000044248300000000d3e3e3e3f3c2000000c2d2e2929292b0a2214500000000008292b092a224252483939393939393939292b092
000000000000000000000000000000000000000000000000b30000000000a300000000000000318090a0007100007383a2210000000000000000000000004400
000000000031c0210002000000004424000000000000000000c3000000c2d3e392929293a3212434000101c082929292a2733400243400000000442483929292
00000000000000000000000000000000000000000000000011000000000011000000000000000000318090a035000011a2d0e0e0e0e0e0e0e0e0e0f001000041
000000010000110031c021000000412400000000000000000000000000c300009292a324242424734581919192929292a2340000440001010100002425829292
00000000000000000000000000000000000041000001000000000001000000000100000000000000000031c073240001929191919191919191919191a1210000
000031c021000000001100000000004400000000000000003500000000000000b0a22424242524242483939392b09292a20000000001d1e1f1000044248292b0
000000000000000000000000000000000000000031c02135410031c021004100b135450000000000000000114424358192b092929292929393939393a2210000
000000110000000100000000000000000000000035000065240000450000000092a22424734400442424340083939393a201010101d1e2e2f200003181929292
0000000000000000000000000000000024000045001145243500001100000000b32425350100000000000001452424839393939392b0a22434004473b3210041
00000000000031c021000041000000000000455424246524242424243500000092a2252434000000004400000000000092919191a1d3e3e3f300003182929292
000000000000000000000000000000002435242435002424000000000000000011004424b1010000000031b124242511919191a18393a3410000653400000000
001000000000001100000000000000006535242424247334000044732445556592a224243500000000000000000000009292b09292a124253400003182b09292
000000000000000000000000000000002424242424252434000000000000410001004524b3b10000000031b3442434019292b0a2252444000000440000000000
00c001010101010101010101010100412424244425242400000000002424242492a224340000000000000000000000009292929292a273440000003182929292
0000000000000000000000000000000024250044242424733535000001000000b124243411b235000000001100442481929392a2340000000000004500000000
00809090909090909090909090a0210024243400242434000600004524242444b0a2000000000000000000000000000092b0929292a234000001010182929292
00000000000000000000000000000000340000000044242424243531b1210000b324240001b224450000000100242483a21083a3410000000000002435000000
00c02425242424c02424242424b121002524000044249500000056242434000092a2000000000000350000000000000092929292b0a20000318191a18392b092
00000000000000000000000000000000000000000000002424242431b221000011447325b1b22473350000b145243411a2220000000000003500002524000000
00114424247324114424254424b321002424350000248191a18191a12400004593a300000000000024340000000000009393939393a3000031829292a1839292
00000000000000000000000000000000001000000001010101242531b321000000002424b3b23400242500b324250001a2350000000000002400002424340000
000000344144240000244100242400007334000000c08393a382b0a224d1e1e1000000000000000024000054650000002524243400000000318292b092a18393
000000000000000000000000000000009191a10101819090a0732424340000000000340011b200004424000024240081a2243400000000452434002424000000
00546500002424452424350024344100240010000081919191929292a1d2e2e20000005610000045240000447300000024340000000035003182929292929191
0000000000000000000000000000000092b0929191a2430044242424000000001000000045b352000024350024340083a2240000000000242500452473000000
00442424243444242425242424000000e1e1e1e1f18292b092929292a2d2e2e200000081a0000025243500002400610024109566004524003182929292b09292
0000000000000000000000000000000092929292b0a200000024243400000000a1000000252435000044247324000011a2253500000000242400242424350000
00000025240000004424732400000000e2e2e2e2f2829292929292b0a2d2e2e2000000b2d1f100242424000024350000919191a1732425353182929292929292
9292929292a22111111183939392a200b0929393939393939292939393a3242492929292929292929292b09293a32124939393939392a2242400003182929292
92b09292929292b0b0929292a225248292b0929293a3242434829293939392920000000000000000000000000000000000000000000000000000000000000000
929292b092a22100000011111182a20093a324550000002482a3214424732425929292b092929393939392a211110025341000004582a2253400003182939393
939393939393939393939392a2732483929293a3111173247183a325242482b00000000000004500000000000000000000000000000000000000000000000000
9292929292a22100000000004482a2552424253400000144b321004524b134009292929292a31111111183a300000024909090a02482a22471000031b2244444
512434004424252424732482a200442592a2111100002581a1210000527382920000000000007300003500000000000000000000000000000000000000000000
92b0929393a32100000001002482a234247344000031b1003400000025b2000093939292a2210000000031b1000045242424252424829291a1210031b3345200
007300010034442434014483a300452492a2210000004483a3210025652482920000000045002400002500000000000000000000000000000000000000000000
9292a28191a121004555b1214482a225243400000031b2000000004524b2000091a18393a3210000000031b224350044252434733482b092a221000000000000
004431c02145412431c021000100002492a221000000001111000044254482b00000000024552400007300350000000000000000000000000000000000000000
9292a282b0a221004425b2210282a234250000000031b2000000000044b2007192929191a1210000000031b2340000002434000000829292a221000000000000
000000110044242400110031c021014492a221000000000000000000343182920000000024252400002455240000000000000000000000000000000000000000
9393a38393a221020024b2212283a300243554653531b20101010101018291919292b092a2210000010031b22100000024010101018292b0a221000000000000
0000000000000173555401001131c041b0a201010101000000410000003183920000000044242467002425340000000000000000000000000000000000000000
2400000044b201b10044b22100737335242425248090939090909090909292b092929292a2210031b10031b2210000002480909090939392a221000001000000
000000000031c0242425b121410011009292a18191a1210000000000000031820000000000242481a12424354500000000000000000000000000000000000000
34000100008390a221008390909090903400440000732424243400003182929293939393a2214131b20031b2000000003411111111113182a2210231b1210000
00010000000011442424b321000000009393a38393a321000001010000003182000000652524819292a124242565000000000000000000000000000000000000
0031b121004425b221000000442435310000000000004424252424558192929200000000b3210031b23531b2410000000000000000003182a2212231b2210000
31c0210100000001003411000000004511111111111100010181a1010000318200000044248192b09292a1732424000000000000000000000000000000000000
5231b221000024b20101010100242531010101010100002434003424829292920000004524000031b22431b3000000000000000000003182a2010101b2210000
001131c0210031b121000000000000242110000000003181919293a02100318354546524348292929292a2340044650000000000000000000000000000000000
0031b32100004483909090a00024343191919191a10101c021000044839392920000007325340031b224242400000000010101013500018292919191a3210000
10000011000031b22100000000546524212200000000318292a3111100000011247324250083939292b0a2000000240000000000000000000000000000000000
35001100000000111111111100440031939393939390a01100000000111183920000000024000031b224253400000000919191a124258093939393a321000000
a1350000000031b321000000004473240101010100003183a311004500414553004424355681a1829293a3c00000240000000000000000000000000000000000
24340000100071000000000000000031351095000044240000000000000024820000006524550031b200442455000000929292a2002424004573244400410045
a2240000000000110000003545242524919191a1210000111100002500352453000081919192a283a38191a12435245500000000000000000000000000000000
735554458191a10101010101000200319191a1350073243500000000524573831000452424340031b30000253400000092b092a2004424242425340000000024
a225350200000000000045242424247392b092a22141000035000024452424251000839292b0929191929292a173252400000000000000000000000000000000
2425242482929291919191a1002200319292a224452425240000000000252424a1007324240000002500002473000000929292a2222224252400000000004524
a22473b13500000000552424252424249292b0a22100004525004524732425248191a182929292929292b092929191a100000000000000000000000000000000
__gff__
00000000000000000303030303030303020202020000000003030303030303030000000000000000030303030303030304040400000202040303030303030303000004040404020203000202020202020000040404040402020400000000020200040000000c0c02020202020202020200040000000000000002020202020202
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1a3829290b292939393939393a000028292a2829292a38393939292a42424228292929292929393a4252424238292929393939393a0000003839393939393939393a000000283939393a3839393929292929290b292929292929292a42422829290b2929292a4242424228290b2929292a4242424238393939290b2929292929
291a383939393a430000424300000028292a3839393a42420042282a44374228290b2929292a00444242434237280b294242424300000000424243000000000042370000003b4243000000004442380b29292929290b29293939393a4242282929290b29393a52424442383929290b292a425242424244444238393939392929
29291a0c37425200000044000000592829291a0c374243430042282a005452282929290b293a000043000044003829294252430000545556524200000000000052425366005442000000000000420028292939393939393a1819191a424228292929393a4242424300004442383929292a42424242430000444242425242280b
39393a424242430000000000650c0c280b292a42424300000044283a00004428293929292a0000000000000000003829430000000018191a424200000000000044424208090a43000000000000425328292a18191a0c181a3839393a424228290b2a12000000000000001600001328292a424242000000000042424242422829
1a404252424354425300000008091929290b2a430000000000002b00000000283a0038293a5965000000000000000038000016545438292a0c4253000000000000374242424300000000101054424238393a28292a37383a0c42424242522829292a12000000000000000000001328292a444242550014004442425242422829
2a54424242424243000000000000382929393a000000001000003b00000066280000003b18191a000000000000000000534556424242282a424300000000000044424243000000000000181a42004243424238393a4242430044004442422829293a123400000010100000003413380b2a104237000000005642424242422829
291909090a42420000000000005442282a0059005453001b00000000000018290015000028292a101010100000000061425242424252383a420000002222000000440000000010100000282a374243004242111111424200000000004418290b2a425300000013080a12000000004228291a4242545500544242424300443839
293a5242424300000000000000425228291a0c0c3743002b530000000045280b000000543839390909090a5545000071424242423742181a4300000000000000000000000000080a0054282a42420000524253000000444300000000003839392a373700000000424253000000004428293a4242425200424242530000002235
2a0000444200000000544254424242282929191a4253003b424553005642383900000042424242420c0c424242531819424300444242282a00000000000000000000000000000c37424238291a000000424242430000000000145455564242003a5242330000003752420000330000383a424242424256424242420000002235
3a00000042530000004237424208192929290b2a4242550c424242524242181900005442524237430000444252422829440000004252282a00000022220000000000000000001b42424442383a530000424300000000000000004442424243004442530000000044424300000000000042424252424242424242430000000044
000000544242526654424242524228290b29292a0044421b430044424208392900000044424242000000004237422829000000004442282a00000000000000000000000000003b424300004442425300420000005342530000000000424200000042430000004442420000000000000044424242423742424242554500000000
00000042524242181a420000444228293939292a0054422b00000000444242280000000000444210101010424242280b000000544242383a00000000000022220001650000000c430000000052420000420154424237424500000054424300000044423400000054523400000000003400004442424242424342424300000054
000154181a4244383a430010101028290042382a5452432b0000000000004438000000000000420819190a4344002829660154524243440000000000000000000909090a00000c00000000594442551719191a424242424253004542524259000054430000000042420000000000000000004442424443000045370020004442
191919292a4300181a101018191929290044523b4243002b10101000000054420001650000004442282a4300000028291919191a43000000000000002222000044420c5300540c0000540008090909092929291919191a4242424237424218193337000000003342370000003300000061000042520000000044425322000042
290b29292a1010282919192929290b29000144424255652819191a000000524219191a0000200044282a0000002028292929292a00000000222200000000000000520c4253421b25004255560c424242290b292929292a4442421819191929295442010000000056425300000000000071015642420022222200544200005442
292929292919192929292929292929291919191919191929290b2a5545564242290b2a00001b0000282a00000018292929290b2a22220000000000000000000000440c4237422b00544242420c424242292929290b292a000044282929290b294218191a0000004242420000000000001919191a425500000000424253004252
29393a0000002839393939393939292929292a42424242282939393939290b292939393939393939292a424242280b292929293a00000000000000000000002d2929393939393a38393939393a4243002a424342530000000000424238393939292929393a4242003829290b2929290b2929292a42524238393939393939290b
2a42420000002b404442424242422829290b2a42524242383a524243003839292a42000014544242383a4242522829290b292a0000000000000000000000002d292a00001400000000443742425253002a4215520c535900000000445242424229292a424242430013282939393939393939393a4242424242423742420c3829
3a42530000003b00004452420044282929292a424242420c42434400000044383a42101010424242000042004438292929292a0000000000000000000000002d292a00000000101000000043444243002a4254420c370c10101018191a42423729292a425242000013282a120044445242424242424300444200424252424238
4242374300000000000042425300280b29292a424300420c5500000000000000523718191a425243005437430044282939393a55000000000000000000001d2e292a53000000181a00000000001819192919191a18191a18191a28292a42424239393a424242000013383a120000004236424300000000004300444242424300
4242420014000000144442424200282929292a1b0000440c4300000000000000420829293a4344000000440010102829191a42420000615758610000001d2e2e292a42000054282a00001400002829292929292a38393a38393a28292a0c425219191a4243425500004243000000000036520010100020000000004243441400
425242000000000000005442430028290b292a3b0000004300000000000000544313282a425300000000001318192929292a52425500716768711d1e1e2e3e3e393a42530042282a10101010102829292929292a0c111111111128292a42424229292a00004442175443000000000000364313181a0022000000104255000000
4242425545000000455642520000383939393a0c0000000000000000001b42420013282a430000000000001338290b29293a424242531819191a2d2e2e3f000043004442524238390909090919290b29292929291a000000000038393a4237420b292a10101008090a10101010000000370013383a10101010101b4243000013
424242423743000000444242550000420909090a1010000000000000102b42520013383a0000000000000044423839292a44424237422829292a3d3e3f00000000140042424243000000000038392929292929292a55450000000c00004442422929390909091919191919090a5300004300130809090909090a2b5200000022
42430000440000000000524443005442424242080a0c0000000000000c2b4242000044430000101000000000424242382a0043004442280b29291a00000000005300544243000000000000000042383929290b292a5243000000220000455642393a37424313280b29292a42424200000000130c1111111111112b4200000022
42540000000000000000420000004242425237434400000000000000443b3742101010101010180a00000000444252332a0000000018292929292a001600000042424237000000000010000044524243292929292a42000000002200004418194242432500132829290b2a4242432000000000110000000000002b4300000013
52430000000000000054374300004252424242000000000000000000004442421909090909093a0000000000004242533a0000000038392929293a00000000004252424300000000130c120056424200393939393a4300000000000000003829424200000013383939292a5242002200000000000000001000003b0000000000
43000000000000000000440000004243424344000000000000000000000042443a425242424300000000000000374242000000001d1e1f28292a4253000000004200440000100000001100440c37436111111111000000000000000000003738424314000000111111383a4237550000000000100000541b0000110000000000
000001000000101010000000000044544400000000000000000000000044420042424300440000000000000000424242000000002d2e2f280b2a42420000000043000000130c1253000000004300007100000000000000000000000000004242420000000000000000111144424300000100001b5300522b0000000000000000
10100c10101018191a000000202000440001000000000000000000000000430043000000000000000000445556424300006501002d2e2f28292a423755545300016500000044524300100000000000180100000000000000545500000000445242554556000001000000005642000000181a003b4243422b0000000000000000
19191919191a280b2a1010100c0c1010001b5300002222000000222200000000000100000000222200000042425253540018191a2d2e2f28293a424242424300191a120000254253131b0000000017281a00000020000000424300000000004242423742550022222222224242530000383a531b3720423b0000000000000000
290b2929292a28292a18191919191919542b5200000000000000000000000000002222000000000000005442424242420028292a2d2e2f282a42424242424253292a120000544237132b0000001819292a0000001b000054420000000000004242524242425300000045564252420000191a522b4222421b0000000000000000
__sfx__
0002000036370234702f3701d4702a37017470273701347023370114701e3700e4701a3600c46016350084401233005420196001960019600196003f6003f6003f6003f6003f6003f6003f6003f6003f6003f600
0002000011070130701a0702407000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300000d07010070160702207000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000642008420094200b420224402a4503c6503b6503b6503965036650326502d6502865024640216401d6401a64016630116300e6300b62007620056100361010600106000060000600006000060000600
000400000f0701e070120702207017070260701b0602c060210503105027040360402b0303a030300203e02035010000000000000000000000000000000000000000000000000000000000000000000000000000
000300000977009770097600975008740077300672005715357003470034700347003470034700347003570035700357003570035700347003470034700337003370033700337000070000700007000070000700
00030000241700e1702d1701617034170201603b160281503f1402f120281101d1101011003110001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
00020000101101211014110161101a120201202613032140321403410000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
00030000070700a0700e0701007016070220702f0702f0602c0602c0502f0502f0402c0402c0302f0202f0102c000000000000000000000000000000000000000000000000000000000000000000000000000000
0003000005110071303f6403f6403f6303f6203f6103f6153f6003f6003f600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
011000200177500605017750170523655017750160500605017750060501705076052365500605017750060501775017050177500605236550177501605006050177500605256050160523655256050177523655
002000001d0401d0401d0301d020180401804018030180201b0301b02022040220461f0351f03016040160401d0401d0401d002130611803018030180021f061240502202016040130201d0401b0221804018040
00100000070700706007050110000707007060030510f0700a0700a0600a0500a0000a0700a0600505005040030700306003000030500c0700c0601105016070160600f071050500a07005050030510a0700a060
000400000c5501c5601057023570195702c5702157037570285703b5702c5703e560315503e540315303e530315203f520315203f520315103f510315103f510315103f510315103f50000500005000050000500
000400002f7402b760267701d7701577015770197701c750177300170015700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
00030000096450e655066550a6550d6550565511655076550c655046550965511645086350d615006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605
011000001f37518375273752730027300243001d300263002a3001c30019300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
011000002953429554295741d540225702256018570185701856018500185701856000500165701657216562275142753427554275741f5701f5601f500135201b55135530305602454029570295602257022560
011000200a0700a0500f0710f0500a0600a040110701105007000070001107011050070600704000000000000a0700a0500f0700f0500a0600a0401307113050000000000013070130500f0700f0500000000000
002000002204022030220201b0112404024030270501f0202b0402202027050220202904029030290201601022040220302b0401b030240422403227040180301d0401d0301f0521f0421f0301d0211d0401d030
0108002001770017753f6253b6003c6003b6003f6253160023650236553c600000003f62500000017750170001770017753f6003f6003f625000003f62500000236502365500000000003f625000000000000000
002000200a1400a1300a1201113011120111101b1401b13018152181421813213140131401313013120131100f1400f1300f12011130111201111016142161321315013140131301312013110131101311013100
001000202e750377502e730377302e720377202e71037710227502b750227302b7301d750247501d730247301f750277501f730277301f7202772029750307502973030730297203072029710307102971030710
000600001877035770357703576035750357403573035720357103570000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
001800202945035710294403571029430377102942037710224503571022440274503c710274403c710274202e450357102e440357102e430377102e420377102e410244402b45035710294503c710294403c710
0018002005570055700557005570055700000005570075700a5700a5700a570000000a570000000a5700357005570055700557000000055700557005570000000a570075700c5700c5700f570000000a57007570
010c00103b6352e6003b625000003b61500000000003360033640336303362033610336103f6003f6150000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c002024450307102b4503071024440307002b44037700244203a7102b4203a71024410357102b410357101d45033710244503c7101d4403771024440337001d42035700244202e7101d4102e7102441037700
011800200c5700c5600c550000001157011560115500c5000c5700c5600f5710f56013570135600a5700a5600c5700c5600c550000000f5700f5600f550000000a5700a5600a5500f50011570115600a5700a560
001800200c5700c5600c55000000115701156011550000000c5700c5600f5710f56013570135600f5700f5600c5700c5700c5600c5600c5500c5300c5000c5000c5000a5000a5000a50011500115000a5000a500
000c0020247712477024762247523a0103a010187523a0103501035010187523501018750370003700037000227712277222762227001f7711f7721f762247002277122772227620070027771277722776200700
000c0020247712477024762247523a0103a010187503a01035010350101875035010187501870018700007001f7711f7701f7621f7521870000700187511b7002277122770227622275237012370123701237002
000c0000247712477024772247722476224752247422473224722247120070000700007000070000700007002e0002e0002e0102e010350103501033011330102b0102b0102b0102b00030010300123001230012
000c00200c3320c3320c3220c3220c3120c3120c3120c3020c3320c3320c3220c3220c3120c3120c3120c30207332073320732207322073120731207312073020a3320a3320a3220a3220a3120a3120a3120a302
000c00000c3300c3300c3200c3200c3100c3100c3103a0000c3300c3300c3200c3200c3100c3100c3103f0000a3300a3201333013320073300732007310113000a3300a3200a3103c0000f3300f3200f3103a000
00040000336251a605000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
000c00000c3300c3300c3300c3200c3200c3200c3100c3100c3100c31000000000000000000000000000000000000000000000000000000000000000000000000a3000a3000a3000a3000a3310a3300332103320
001000000c3500c3400c3300c3200f3500f3400f3300f320183501834013350133401835013350163401d36022370223702236022350223402232013300133001830018300133001330016300163001d3001d300
000c0000242752b27530275242652b26530265242552b25530255242452b24530245242352b23530235242252b22530225242152b21530215242052b20530205242052b205302053a2052e205002050020500205
001000102f65501075010753f615010753f6152f65501075010753f615010753f6152f6553f615010753f61500005000050000500005000050000500005000050000500005000050000500005000050000500005
0010000016270162701f2711f2701f2701f270182711827013271132701d2711d270162711627016270162701b2711b2701b2701b270000001b200000001b2000000000000000000000000000000000000000000
00080020245753057524545305451b565275651f5752b5751f5452b5451f5352b5351f5252b5251f5152b5151b575275751b545275451b535275351d575295751d545295451d535295351f5752b5751f5452b545
002000200c2650c2650c2550c2550c2450c2450c2350a2310f2650f2650f2550f2550f2450f2450f2351623113265132651325513255132451324513235132351322507240162701326113250132420f2600f250
00100000072750726507255072450f2650f2550c2750c2650c2550c2450c2350c22507275072650725507245072750726507255072450c2650c25511275112651125511245132651325516275162651625516245
000800201f5702b5701f5402b54018550245501b570275701b540275401857024570185402454018530245301b570275701b540275401d530295301d520295201f5702b5701f5402b5401f5302b5301b55027550
00100020112751126511255112451326513255182751826518255182451d2651d2550f2651824513275162550f2750f2650f2550f2451126511255162751626516255162451b2651b255222751f2451826513235
00100010010752f655010753f6152f6553f615010753f615010753f6152f655010752f6553f615010753f61500005000050000500005000050000500005000050000500005000050000500005000050000500005
001000100107501075010753f6152f6553f6153f61501075010753f615010753f6152f6553f6152f6553f61500005000050000500005000050000500005000050000500005000050000500005000050000500005
002000002904029040290302b031290242b021290142b01133044300412e0442e03030044300302b0412b0302e0442e0402e030300312e024300212e024300212b0442e0412b0342e0212b0442b0402903129022
000800202451524515245252452524535245352454524545245552455524565245652457500505245750050524565005052456500505245550050524555005052454500505245350050524525005052451500505
000800201f5151f5151f5251f5251f5351f5351f5451f5451f5551f5551f5651f5651f575000051f575000051f565000051f565000051f555000051f555000051f545000051f535000051f525000051f51500005
000500000373005731077410c741137511b7612437030371275702e5712437030371275702e5712436030361275602e5612435030351275502e5512434030341275402e5412433030331275202e5212431030311
002000200c2750c2650c2550c2450c2350a2650a2550a2450f2750f2650f2550f2450f2350c2650c2550c2450c2750c2650c2550c2450c2350a2650a2550a2450f2750f2650f2550f2450f235112651125511245
002000001327513265132551324513235112651125511245162751626516255162451623513265132551324513275132651325513245132350f2650f2550f2450c25011231162650f24516272162520c2700c255
000300001f3302b33022530295301f3202b32022520295201f3102b31022510295101f3002b300225002950000000000000000000000000000000000000000000000000000000000000000000000000000000000
000b00002935500300293453037030360303551330524300243050030013305243002430500300003002430024305003000030000300003000030000300003000030000300003000030000300003000030000300
001000003c5753c5453c5353c5253c5153c51537555375453a5753a5553a5453a5353a5253a5253a5153a51535575355553554535545355353553535525355253551535515335753355533545335353352533515
00100000355753555535545355353552535525355153551537555375353357533555335453353533525335253a5753a5453a5353a5253a5153a51533575335553354533545335353353533525335253351533515
001000200c0600c0300c0500c0300c0500c0300c0100c0000c0600c0300c0500c0300c0500c0300c0100f0001106011030110501103011010110000a0600a0300a0500a0300a0500a0300a0500a0300a01000000
001000000506005030050500503005010050000706007030070500703007010000000f0600f0300f010000000c0600c0300c0500c0300c0500c0300c0500c0300c0500c0300c010000000c0600c0300c0100c000
0010000003625246150060503615246251b61522625036150060503615116253361522625006051d6250a61537625186152e6251d615006053761537625186152e6251d61511625036150060503615246251d615
00100020326103261032610326103161031610306102e6102a610256101b610136100f6100d6100c6100c6100c6100c6100c6100f610146101d610246102a6102e61030610316103361033610346103461034610
00400000302453020530235332252b23530205302253020530205302253020530205302153020530205302152b2452b2052b23527225292352b2052b2252b2052b2052b2252b2052b2052b2152b2052b2052b215
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 15 0a 43 44
00 0a 16 0c 44
00 0a 16 0c 44
00 0a 0b 0c 44
00 14 13 12 44
00 0a 16 0c 44
00 0a 16 0c 44
02 0a 11 12 44
00 41 42 43 44
00 41 42 43 44
01 18 19 1a 44
00 18 19 1a 44
00 1c 1b 1a 44
00 1d 1b 1a 44
00 1f 21 1a 44
00 1f 1a 21 44
00 1e 1a 22 44
02 20 1a 24 44
00 41 42 43 44
00 41 42 43 44
01 2a 27 29 44
00 2a 27 29 44
00 2f 2b 29 44
00 2f 2b 2c 44
00 2f 2b 29 44
00 2f 2b 2c 44
00 2e 2d 30 44
00 34 31 27 44
02 35 32 27 44
00 41 42 43 44
01 3d 42 43 44
00 3d 42 43 44
00 3d 42 43 44
02 3d 3e 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
01 38 3a 3c 44
02 39 3b 3c 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
