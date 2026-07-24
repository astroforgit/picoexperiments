pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

-- hack*match
-- by deadpixl

-- start libs
function create_notif()
	-- properties
	local this={}
	
	this.bg_color=8
	this.text_color=7
	this.subtext_color=this.text_color
	
	this.text=""
	this.subtext=""
	
	this.displaytime=0
	
	-- methods
	this.set_bg_color=function(val)
		this.bg_color=val
		return(this)
	end
	
	this.set_text_color=function(val)
		this.text_color=val
		return(this)
	end
	
	this.set_subtext_color=function(val)
		this.subtext_color=val
		return(this)
	end
	
	this.set_text=function(val)
		this.text=val
		return(this)
	end
	
	this.set_subtext=function(val)
		this.subtext=val
		return(this)
	end
	
	this.show=function(frames)
		this.displaytime=frames
		return(this)
	end
	
	this.hide=function()
		this.displaytime=0
		return(this)
	end
	
	this.draw=function()
		if this.displaytime>0 then
			this.displaytime-=1
			rectfill(0,128-7,128,128,this.bg_color)
			print(this.text,1,128-6,this.text_color)
			print(this.subtext,128-swidth(this.subtext),128-6,this.subtext_color)
		end
	end
	
	return(this)
end

function create_menu(title)
	-- properties
	local this={}

	this.bg_color=1

	this.item_color=this.bg_color
 this.item_selected_color=7
 this.item_text_color=7
 this.item_selected_text_color=0
	this.item_height=9
 this.items={}

 this.title=title
 this.title_color=0
	this.title_text_color=7
 this.title_height=11

	this.sel_index=0
	this.draw_index=0
	this.draw_limit=(128-this.title_height)/this.item_height
 this.current_key=0
	
	-- methods
	this.set_bg_color=function(val)
		this.bg_color=val
		return(this)
	end

 this.set_item_color=function(val)
  this.item_color=val
  return(this)
 end

 this.set_item_selected_color=function(val)
  this.item_selected_color=val
  return(this)
 end
	
 this.set_item_text_color=function(val)
  this.item_text_color=val
  return(this)
 end

 this.set_item_selected_text_color=function(val)
  this.item_selected_text_color=val
  return(this)
 end
	
	this.set_title=function(val)
		this.title=val
		return(this)
	end

 this.set_title_color=function(val)
  this.title_color=val
  return(this)
 end

 this.set_title_text_color=function(val)
  this.title_text_color=val
  return(this)
 end

 this.get_item=function(key)
  for item in all(this.items) do
   if item.key == key then return(item) end
  end
 end
	
	this.add_item=function(label,action)
		-- properties
  local new_item={}

  new_item.key=current_key
		new_item.label=label
		new_item.action=action
  new_item.props={}

  new_item.set_prop=function(key,val)
   new_item.props.key=val
   return(new_item.props.key)
  end

  new_item.get_prop=function(key)
   return(new_item.props.key)
  end

  this.current_key+=1
		
		return(add(this.items,new_item))
	end
	
	this.del_item=function(label)
		for item in this.items do
			if item.label==label then
			 del(this.items,item)
			 return(this)
   end
		end
	end
	
	this.select=function(item)
		item.action(this,item)
		return(this)
	end
	
	this.update=function()
		-- process button presses
		if btnp(î) then
			this.sel_index-=1
			
			if this.sel_index >= #this.items then
				this.sel_index=#this.items
			elseif this.sel_index < 0 then
				this.sel_index=0
			end
		elseif btnp(É) then
			this.sel_index+=1
			
			if this.sel_index == #this.items then
				this.sel_index=#this.items-1
			elseif this.sel_index < 0 then
				this.sel_index=0
			end
		elseif btnp(ó) then
			this.select(this.items[this.sel_index+1])
		end
		
		-- scroll list down?
		if this.sel_index>=this.draw_index+this.draw_limit then
			this.draw_index+=1
		end
		
		-- scroll list up?
		if this.sel_index<this.draw_index then
			this.draw_index-=1
		end

  return(this)
	end
	
	this.draw=function()
		-- draw background
		cls(this.bg_color)
		
		-- draw title
		rectfill(0,0,128,this.title_height-1,this.title_color)
		print(this.title,hcenter(this.title),(this.title_height/2)-2,this.title_text_color)
		
		-- draw items
		local limit
		if #this.items > this.draw_limit then
			limit=this.draw_limit
		else
			limit=#this.items
		end
		
		local item_index=1
		for i=this.draw_index+1,this.draw_index+limit,1 do
			local fill_col
			local label_col
			
			if this.sel_index==i-1 then
				fill_col=this.item_selected_color
				label_col=this.item_selected_text_color
			else
				fill_col=this.item_color
				label_col=this.item_text_color
			end
			
			rectfill(0,this.title_height+(this.item_height*(item_index-1)),128,(this.title_height+(this.item_height*(item_index-1)))+this.item_height-1,fill_col)
			print(this.items[i].label,3,this.title_height+(this.item_height*(item_index-1))+(this.item_height/2)-2,label_col)
			
			item_index+=1
		end
		
		return(this)
	end
	
	return(this)
end
-- end libs

left,right,up,down,fire1,fire2=0,1,2,3,4,5
black,dark_blue,dark_purple,dark_green,brown,dark_gray,light_gray,white,red,orange,yellow,green,blue,indigo,pink,peach=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

emitters={}
score=0
high_score=0
menu_counter=30
white_text=false
offset=0
num_macthed_mem=0
speed_increase=60*20

function swidth(s)
    s=tostr(s)
    return #s*4
end

function hcenter(s)
  return 64-#s*2
end
 
function vcenter(s)
  return 61
end

function print_bg(text, x, y, color, bg_color)
    if not x then x=0 end
    if not y then y=0 end
    if not color then color=white end
    if not bg_color then bg_color=black end

    local width=(#text*4)

    for i=1,#text do
        if sub(text,i,i)=="!" then width-=1 end
    end

    rectfill(x-1,y-1,x+width-1,y+5,bg_color)
    print(text,x,y,color)
end

function print_shadow(text,x,y,color)
    text=tostr(text)

    print(text,x+1,y+1,dark_blue)
    print(text,x,y,color)
end

function vector(x,y)
    local v={}
    v.x=x
    v.y=y
    return(v)
end

function vector_add(v1,v2)
    local v={}
    v.x=v1.x+v2.x
    v.y=v1.y+v2.y
    return(v)
end

function vector_sub(v1,v2)
    local v={}
    v.x=v1.x-v2.x
    v.y=v1.y-v2.y
    return(v)
end

function vector_mul(v1,v2)
    local v={}
    v.x=v1.x*v2.x
    v.y=v1.y*v2.y
    return(v)
end

function vector_div(v1,v2)
    local v={}
    v.x=v1.x/v2.x
    v.y=v1.y/v2.y
    return(v)
end

function vector_rnd()
    local v={}
    v.x=rnd(2)-1
    v.y=rnd(2)-1
    return(v)
end

function create_emitter(x,y,amount,freq,type,col1,col2,min_size,max_size,min_life,max_life,triggers)
    -- properties
    local this={}
    this.particles={}
    this.pos={}
    this.amount=amount
    this.freq=freq
    this.freq_timer=0
    this.type=type
    this.pos.x=x
    this.pos.y=y
    this.min_size=min_size
    this.max_size=max_size
    this.col1=col1
    this.col2=col2
    this.min_life=min_life
    this.max_life=max_life
    this.triggers=triggers
    this.destroy=false

    if this.amount==nil then this.amount=5 end
    if this.freq==nil then this.freq=1 end
    if this.type==nil then this.type=0 end
    if this.col==nil then this.col=white end
    if this.min_size==nil then this.min_size=1 end
    if this.max_size==nil then this.max_size=3 end
    if this.min_life==nil then this.min_life=30 end
    if this.max_life==nil then this.max_life=120 end
    if this.triggers==nil then this.triggers=-1 stop("setting to -1") end

    -- methods
    this.create_particle=function(acc,col)
        -- properties
        local p={}
        p.pos={}
        p.pos=this.pos
        p.original_force=acc
        p.size=rnd(flr(this.max_size+1))+this.min_size
        p.col=col
        p.type=this.type
        p.destroy=false
        p.life=flr(rnd(this.max_life+1))+this.min_life
        p.life_timer=p.life

        -- physics
        p.acc=acc
        p.vel=vector(0,0)

        -- methods
        p.apply_force=function(v)
            p.acc=vector_add(p.acc,v)
            return(p)
        end

        p.update=function()
            if p.original_force==nil then p.original_force=p.acc end

            p.vel=vector_add(p.acc,p.vel)
            p.pos=vector_add(p.vel,p.pos)
            p.acc=vector(0,0)

            p.life_timer-=1

            if p.life_timer<=0 then
                p.destroy=true
            end
        end

        p.draw=function()
            if p.type==0 then
                -- ellipse
                circfill(p.pos.x,p.pos.y,p.size,p.col)
            else
                -- rect
                rectfill(p.pos.x-(p.size/2),p.pos.y-(p.size/2),p.pos.x+(p.size/2),p.pos.y+(p.size/2),p.col)
            end
        end

        return(p)
    end

    this.update=function()
        if this.triggers<0 then stop("<0") end
        if this.freq_timer==0 and this.triggers!=0 then
            this.freq_timer=this.freq
            if this.triggers>0 then this.triggers-=1 end

            for i=1,this.amount do
                local force=vector_mul(vector_rnd(),vector(1.2,1.2))
                local rndcol=rnd()
                if rndcol>0.15 then
                    rndcol=this.col1
                else
                    rndcol=this.col2
                end

                add(this.particles,this.create_particle(force,rndcol))
            end
        else
            this.freq_timer-=1
        end
        
        for particle in all(this.particles) do
            particle.apply_force(vector_mul(particle.original_force,vector(-0.015,-0.015)))
            particle.update()
            if particle.destroy then del(this.particles,particle) end
        end

        if #this.particles==0 and this.triggers==0 then this.destroy=true end
    end

    this.draw=function()
        for particle in all(this.particles) do
            particle.draw()
        end
    end

    return(this)
end

function create_grid()
    -- properties
    local this={}
    this.pos={}
    this.width=7
    this.height=10
    this.buffer=128-(this.width*16)
    this.pos.x=this.buffer/2
    this.pos.y=-16
    this.offset=0
    this.starting_frequency=20
    this.update_frequency=this.starting_frequency
    this.update_timer=0

    for x=1,this.width,1 do
        for y=1,this.height,1 do
            this[x]={}
            this[x][y]={}
        end
    end

    -- methods
    this.create_piece=function(type)
        -- properties
        local piece={}
        piece.type=type
        piece.flood=-1
        piece.matched=false

        -- methods
        piece.update=function(x,y)
            if ((y-1)*16)+this.offset>=112 and piece.type>=0 then
                game_over=true
            end
        end

        piece.draw=function(x,y)
            palt(0,false)
            if piece.type>=0 then sspr(piece.type*16,0,16,16,((x-1)*16)+(this.buffer/2),((y-2)*16)+this.offset) end
            palt()
        end

        piece.check_match=function(x,y,flood)
            local res=0
            this[x][y].flood=flood

            -- check up
            if y-1>=1 then
                if this[x][y-1].type==this[x][y].type and this[x][y-1].flood!=flood then
                    res+=1
                    res+=this[x][y].check_match(x,y-1,flood)
                end
            end

            -- check down
            if y+1<=this.height then
                if this[x][y+1].type==this[x][y].type and this[x][y+1].flood!=flood then
                    res+=1
                    res+=this[x][y].check_match(x,y+1,flood)
                end
            end
            
            -- check left
            if x-1>=1 then
                if this[x-1][y].type==this[x][y].type and this[x-1][y].flood!=flood then
                    res+=1
                    res+=this[x][y].check_match(x-1,y,flood)
                end
            end

            -- check right
            if x+1<=this.width then
                if this[x+1][y].type==this[x][y].type and this[x+1][y].flood!=flood then
                    res+=1
                    res+=this[x][y].check_match(x+1,y,flood)
                end
            end

            return(res)
        end

        piece.check=function(x,y)
            local flood=rnd()
            this[x][y].flood=flood
            return(piece.check_match(x,y,flood)+1)
        end

       return(piece)
    end

    this.shift=function()
        for x=1,this.width,1 do
            for y=this.height,2,-1 do
                this[x][y]=this[x][y-1]
            end
        end

        local continue=false
        while continue==false do
            continue=true
            for x=1,this.width,1 do
                this[x][1]=this.create_piece(flr(rnd(4)))
            end

            for x=1,this.width,1 do
                if this[x][1].check(x,1)>=4 then continue=false end
            end
        end
    end

    this.collapse=function()
        for x=1,this.width,1 do
            for y=2,this.height,1 do
                if this[x][y].type>=0 and this[x][y-1].type<0 then
                    for y2=1,this.height,1 do
                        if this[x][y2].type<0 then
                            local piece_1=this[x][y]
                            local piece_2=this[x][y2]

                            grid[x][y]=piece_2
                            grid[x][y2]=piece_1

                            return(true)
                        end
                    end
                end
            end
        end

        return(false)
    end

    this.init=function()
        for x=1,this.width,1 do
            for y=1,this.height,1 do
                this[x][y]=this.create_piece(-1)
            end
        end
    end

    this.update=function()
        -- increment offset
        if this.update_timer==0 or (btn(down) and fast_drop_enabled) then
            this.offset+=1
            this.update_timer=this.update_frequency
            if this.offset>=16 then
                this.shift()
                this.offset=0
            end
        else
            this.update_timer-=1
        end

        local collapsed=true
        local num_matched=0

        while collapsed==true do
            collapsed=false
            
            -- check if anything has matched
            for x=1,this.width,1 do
                for y=1,this.height,1 do
                    if this[x][y].type>=0 then
                        if this[x][y].check(x,y)>=4 then
                            this[x][y].matched=true
                            num_matched+=1
                        end
                    end
                end
            end

            -- remove matched pieces
            for x=1,this.width,1 do
                for y=1,this.height,1 do
                    if this[x][y].matched then
                        local col2
                        if this[x][y].type==0 then col2=yellow
                        elseif this[x][y].type==1 then col2=pink
                        elseif this[x][y].type==2 then col2=blue
                        else col2=red end

                        if particles_enabled then add(emitters,create_emitter(((x-1)*16)+(this.buffer/2)+8,((y-2)*16)+this.offset+8,1,1,0,white,col2,0,1,40,60,3)) end
                        
                        this[x][y]=this.create_piece(-1)
                    end
                end
            end

            -- collapse floating pieces after removing matched pieces
            if num_matched>0 then
                while this.collapse() do collapsed=true end

                -- play sound effect
                if flr(num_matched/4)>=2 then
                    if sfx_enabled then sfx(14) end
                    mult_timer=120
                    num_matched_mem=num_matched
                else
                    if sfx_enabled then sfx(13) end
                end

                -- apply screen shake
                if shake_enabled then offset=0.2 end
            end
        end

        -- increase score
        score+=num_matched*10*flr(num_matched/4)
        this.update_frequency=this.starting_frequency-speed
    end

    this.draw=function()
        for x=1,this.width,1 do
            for y=1,this.height,1 do
                this[x][y].update(x,y)
                this[x][y].draw(x,y)
            end
        end
    end

    return(this)
end

function create_player()
    -- properties
    local this={}
    this.x=4
    this.holding=grid.create_piece(-1)

    -- methods
    this.grab=function()
        if this.holding.type<0 then
            for y=grid.height,1,-1 do
                if grid[this.x][y].type>=0 then
                    this.holding=grid[this.x][y]
                    grid[this.x][y]=grid.create_piece(-1)
                    return
                end
            end
        else
            for y=1,grid.height,1 do
                if grid[this.x][y].type<0 then
                    grid[this.x][y]=this.holding
                    this.holding=grid.create_piece(-1)
                    return
                end
            end
        end
    end

    this.swap=function()
        if this.holding.type<0 then
            for y=grid.height,2,-1 do
                if grid[this.x][y].type>=0 and grid[this.x][y-1].type>=0 then
                    local piece_1=grid[this.x][y]
                    local piece_2=grid[this.x][y-1]

                    grid[this.x][y]=piece_2
                    grid[this.x][y-1]=piece_1

                    return
                end
            end
        else
            for y=grid.height,1,-1 do
                if grid[this.x][y].type>=0 then
                    local piece_1=grid[this.x][y]
                    local piece_2=this.holding

                    grid[this.x][y]=piece_2
                    this.holding=piece_1

                    return
                end
            end
        end
    end
    
    this.update=function()
        if btnp(left) then
            this.x=mid(1,this.x-1,grid.width)
        end

        if btnp(right) then
            this.x=mid(1,this.x+1,grid.width)
        end

        if btnp(fire1) then
            this.swap()
        elseif btnp(fire2) then
            this.grab()
        end
    end

    this.draw=function()
        sspr(64,0,16,16,grid.buffer/2+((this.x-1)*16),112)
        if this.holding.type>=0 then sspr(this.holding.type*16,0,16,16,((this.x-1)*16)+(grid.buffer/2),120) end
    end

    return(this)
end

function init_game()
    game_over=false
    white_text=false
    mult_timer=-1
    score=0
    emitters={}
    speed_increase_timer=speed_increase
    speed=0

    -- init grid
    grid=create_grid()
    grid.init()
    grid.shift()

    -- init player
    player=create_player()
end

function return_to_menu(restart_music)
    -- return to menu
    if music_enabled and restart_music then music(0) end
    menu_counter=30
    white_text=false
    _upd=update_menu
    _drw=draw_menu

    -- update high score
    if score>high_score then
        high_score=score
        dset(0,high_score)
    end
end

function bton(v)
    if v then return 1 else return 2 end
end

function ntob(v)
    if v==1 then return true else return false end
end

function toggle_music()
    -- toggle music and disable
    music_enabled=not music_enabled
    if not music_enabled then music(-1) else music(0) end

    -- show notification
    local str
    if music_enabled then str="on" else str="off" end
    notif.set_text("music "..str)
    notif.show(120)

    -- save to cartdata
    dset(1,bton(music_enabled))
end

function toggle_sfx()
    -- toggle sfx
    sfx_enabled=not sfx_enabled

    -- show notification
    local str
    if sfx_enabled then str="on" else str="off" end
    notif.set_text("sfx "..str)
    notif.show(120)

    -- save to cartdata
    dset(2,bton(sfx_enabled))
end

function toggle_shake()
    -- toggle shake
    shake_enabled=not shake_enabled

    -- show notification
    local str
    if shake_enabled then str="on" else str="off" end
    notif.set_text("screen shake "..str)
    notif.show(120)

    -- save to cartdata
    dset(3,bton(shake_enabled))
end

function toggle_particles()
    -- toggle particles
    particles_enabled=not particles_enabled

    -- show notification
    local str
    if particles_enabled then str="on" else str="off" end
    notif.set_text("particles "..str)
    notif.show(120)

    -- save to cartdata
    dset(4,bton(particles_enabled))
end

function toggle_fast_drop()
    -- toggle fast drop
    fast_drop_enabled=not fast_drop_enabled
    
    -- show notification
    local str
    if fast_drop_enabled then str="on" else str="off" end
    notif.set_text("fast drop "..str)
    notif.show(120)

    -- save to cartdata
    dset(5,bton(fast_drop_enabled))
end

function _init()
    -- cart data
    cartdata("deadpixl_hackmatch_1")
    high_score=dget(0)
    if high_score==nil then high_score=0 end

    -- load options
    if dget(1)==0 then music_enabled=true else music_enabled=ntob(dget(1)) end
    if dget(2)==0 then sfx_enabled=true else sfx_enabled=ntob(dget(2)) end
    if dget(3)==0 then shake_enabled=true else shake_enabled=ntob(dget(3)) end
    if dget(4)==0 then particles_enabled=true else particles_enabled=ntob(dget(4)) end
    if dget(5)==0 then fast_drop_enabled=true else fast_drop_enabled=ntob(dget(5)) end

    -- custom menu item
    menuitem(1,"return to title",function() return_to_menu(true) end)

    -- create options menu
    opts=create_menu("options")

    opts.add_item("return to title",function() return_to_menu(false) end)
    opts.add_item("toggle music",toggle_music)
    opts.add_item("toggle sfx",toggle_sfx)
    opts.add_item("toggle screen shake",toggle_shake)
    opts.add_item("toggle particles",toggle_particles)
    opts.add_item("toggle fast drop",toggle_fast_drop)

    -- create notification for options menu
    notif=create_notif()

    -- init game options
    init_game()

    -- init menu
    _upd=update_menu
    _drw=draw_menu

    if music_enabled then music(0) end
end

function update_options()
    opts.update()

    if btnp(fire1) then
        notif.hide()
        _upd=update_menu
        _drw=draw_menu
    end
end

function update_menu()
    if menu_counter<=0 then
        menu_counter=30
        white_text=not white_text
    else
        menu_counter-=1
    end

    if btnp(fire1) then
        _upd=update_options
        _drw=draw_options
    elseif btnp(fire2) then
        if music_enabled then music(8) end
        init_game()
        _upd=update_playing
        _drw=draw_playing
    end
end

function update_playing()
    grid.update()
    player.update()
    
    -- update particles
    for emitter in all(emitters) do
        emitter.update()
        if emitter.destroy then del(emitters,emitter) end
    end

    -- increase speed
    if speed_increase_timer<=0 then
        speed_increase_timer=speed_increase
        speed+=1
    else
        speed_increase_timer-=1
    end

    -- check if game over
    if game_over then
        if score>high_score then
            high_score=score
            dset(0,high_score)
        end
        
        btn_lock=60
        _upd=update_game_over
        _drw=draw_game_over
    end
end

function update_game_over()
    if btn_lock>0 then btn_lock-=1 end

    if menu_counter<=0 then
        menu_counter=30
        white_text=not white_text
    else
        menu_counter-=1
    end

    if btn_lock>0 then return end

    if btnp(fire1) then
        if music_enabled then music(0) end
        return_to_menu()
    elseif btnp(fire2) then
        init_game()
        if music_enabled then music(8) end
        _upd=update_playing
        _drw=draw_playing
    end
end

function _update60()
    _upd()
end

function draw_options()
    cls()
    opts.draw()
    notif.draw()
end

function draw_menu()
    cls()

    -- sprites
    map(0,0,-3,4,15,8)
    map(0,8,-11,60,15,8)
    
    spr(10,9*8,3,4,4)

    -- border lines
    line(0,0,0,127,white)
    line(127,0,127,127,white)
    line(0,0,127,0,white)
    line(0,127,127,127,white)

    -- text
    local str="co ltd 1996"
    print(str,hcenter(str)+27,118,2)

    local str="wéndernet  ver."
    print(str,6*8,(6*8)+7)
    
    local col
    if white_text then col=white else col=red end

    local str="press ó to start"
    print_shadow(str,hcenter(str),72,col)

    local col
    if white_text then col=red else col=white end

    local str="press é for options"
    print_shadow(str,hcenter(str),82,col)

    -- high score
    local str="high score: "
    print_shadow(str,64-35,92,pink)

    local str=tostr(high_score)
    print_shadow(str,(64+35)-swidth(str),92,pink)
end

function screen_shake()
    local fade = 0.8
    local offset_x=16-rnd(32)
    local offset_y=16-rnd(32)
    offset_x*=offset
    offset_y*=offset

    camera(offset_x,offset_y)
    offset*=fade

    if offset<0.05 then
        offset=0
    end
end

function draw_playing()
    cls()

    -- screen shake
    screen_shake()

    -- draw lines on either side
    line((grid.buffer/2)-2,0,(grid.buffer/2)-2,128,white)
    line(128-(grid.buffer/2)+1,0,128-(grid.buffer/2)+1,128,white)

    -- draw aiming line
    for y=109,0,-3 do
        pset(grid.buffer/2+((player.x-1)*16)+8,y,dark_blue)
        pset(grid.buffer/2+((player.x-1)*16)+7,y,dark_blue)
    end

    -- draw main elements
    grid.draw()
    player.draw()

    -- draw score
    local str="score: "..score
    print_shadow(str,hcenter(str),2,15)

    -- multiplier text
    if mult_timer>=0 then
        local pos_x
        local pos_y=128-9
        
        local str="x"..tostr(flr(num_matched_mem/4))
        
        if player.x>=4 then
            pos_x=3+(grid.buffer/2)
        else
            pos_x=128-swidth(str)-4-(grid.buffer/2)
        end

        print_shadow(str,pos_x,pos_y,rnd(14)+1)

        mult_timer-=1
    end

    -- draw particle effects
    for emitter in all(emitters) do
        emitter.draw()
    end
end

function draw_game_over()
    cls()

    -- border lines
    line(0,0,0,127,white)
    line(127,0,127,127,white)
    line(0,0,127,0,white)
    line(0,127,127,127,white)

    local str="game over!"
    print_shadow(str,hcenter(str),vcenter(str)-10,white)

    local str="score: "
    print_shadow(str,64-35,vcenter(str)+10,red)

    local str="high score: "
    print_shadow(str,64-35,vcenter(str)+20,red)

    local str=score
    print_shadow(str,(64+35)-swidth(str),vcenter(str)+10,pink)

    local str=high_score
    print_shadow(str,(64+35)-swidth(str),vcenter(str)+20,pink)

    local col1
    local col2
    if white_text then col1=pink else col1=white end
    if white_text then col2=white else col2=pink end

    local str="é: menu"
    print_shadow(str,3,128-8,col1)
    
    local str="ó: play again"
    print_shadow(str,128-swidth(str)-6,128-8,col2)
end

function _draw()
    _drw()
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000077777777777700000000000077777777777770000000000000000000000000
00aaaaaaaaaaa70000eeeeeeeeeee70000ccccccccccc70000888888888887000e677776666dde800000000006666776666d6667000000000000000000000000
0aa5555557775a700ee5555557775e700cc5555557775c7008855555577758700e677766666dde60000000000e556776666dd851000000000000000000000000
0a555555555557a00e555555555557e00c55555cc55557c0085555555555578001177766666dd110000000000e556766666dd851000000000000000000000000
0a555555555555a00e5e55555555e5e00c5555c55c5555c008588888888885800e51111111111660000000000e556766666d6851000000000000000000000000
0a55aaaaaaaa55a00e55e55ee55e55e00c555c5555c555c008585555555585800e577766666d5660000000000e556766666de851000000000000000000000000
0a555555555555a00e555e5ee5e555e00c55c555555c55c008585558855585800e577766666d5660000000000e11111111111111000000000000000000000000
0a55aaaaaaaa55a00e55555ee55555e00c5c55555555c5c008585558855585800e577766666d5660000000000e55676666dde851000000000000000000000000
0a555555555555a00e55555ee55555e00c5c55555555c5c008585558855585800e577765566d5660000000000e55676666dde851000000000000000000000000
0a55aaaaaaaa55a00e55555ee55555e00c55c555555c55c008585555555585800e577758856d5660000000000e55676666dde851000000000000000000000000
0a555555555555a00e555e5ee5e555e00c555c5555c555c008585558855585800e577588885d5680000000000e55676666dde851000000000000000000000000
0a55aaaaaaaa55a00e55e55ee55e55e00c5555c55c5555c0085855555555858000677588885d5e00000000000e55676666dde851000000000000000000000000
0a555555555555a00e5e55555555e5e00c55555cc55555c008588888888885800057765885dd1500000000000e55676666dde851000000000000000000000000
0a555555555555a00e555555555555e00c555555555555c0085555555555558002217665561222e0000000000e55676666dde851000000000000000000000000
0aaaaaaaaaaaaaa00eeeeeeeeeeeeee00cccccccccccccc00888888888888880e220000000000225000000000e55676666deee51000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000002200000000000022000000000022222222222220000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000008800000111121212000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000008dd5000016dddddd1000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000008dd551111116111111000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000088510665001dddd777000076000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000077511065565011117666700566600000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000788510855556501515566611511600000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000285100858856505155551111511500000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000881000458851500500551100055100000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000110000455551200510507700000116000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000220000165512000510065600000568600000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000022000221d12000051006560000008d660000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000220221100000005000006100000005d10000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000200202000007655200001100000000110000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000200008000060002000002200000000220000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000e0000000550000000200000000020000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000000020000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000008770008770008888787700008887787700087700088770000888888880000eee0eee0000eee0eee000eeeeeeee0eeeeeeeeee00000000000000000000
000000088700088700088eee887000088eeee7000088700088e70000000000000000eee0eee0000eee0eee00eeeeeeeee0eeeeeeeeee00000000000000000000
00000088e00088e00088e00088e00088e0000000088e00088e000000000000000000eee0eee0000eee00000eeeeeeeeee0eeeeeeeeee00000000000000000000
00000088e00088e00088e00088e00088e0000000088e00088e000000000000000000eee0eee0000eee0eee0eee00000000eee000000000000000000000000000
0000088e00088e00088e00088e00088e0000000088e00088e0000000000000000000eee0eee0000eee0eee0eee00000000eee000000000000000000000000000
0000088e00088e00088e00088e00088e0000000088e00088e0000000000000000000eee0eee0000eee0eee0eee00000000eee000000000000000000000000000
000088e00088e00088e00088e00088e0000000088e00088e00000000000000000000eee0eee0000eee0eee0eee00000000eee000000000000000000000000000
000088e00088e00088e00088e00088e0000000088e0088e000000000000000002000222022200002220222022200000000222000000000000000000000000000
00088888888e00088888888e00088e000000008888888e0000000000000000022000222022200002220222022200000000222222200000000000000000000000
00088eee888e00088eee888e00088e0000000088eee8e00000000000000000222000222022200002220222022200000000222000000000000000000000000000
0088e00088e00088e00088e00088e0000000088e0008e00000000000000002222000222022200002220222022200000000222000000000000000000000000000
0088e00088e00088e00088e00088e0000000088e0008e00000000000000022222000222002222222220222022200000000222000000000000000000000000000
088e00088e00088e00088e00088888888e0088e000088e0000000000000222222000222000222222220222002220000000222200000000000000000000000000
088e00088e00088e00088e000eeeeeeee000eee0000eee0000000000002222222222222000022222220222000222222220222222222200000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000008888877887888770008887887700088888887877000888878770008770008770000000000000000000000000000000000000000000000000000000000
000000088eee888eee888700088eee887000eee8888eee700088eeee700008870008870000000000000000000000000000000000000000000000000000000000
00000088e00088e00088e00088e00088e000000888e00000088e0000000088e00088e00000000000000000000000000000000000000000000000000000000000
00000088e00088e00088e00088e00088e00000088e000000088e0000000088e00088e00000000000000000000000000000000000000000000000000000000000
0000088e00088e00088e00088e00088e00000088e000000088e0000000088e00088e000000000000000000000000000000000000000000000000000000000000
0000088e00088e00088e00088e00088e00000088e000000088e0000000088e00088e000000000000000000000000000000000000000000000000000000000000
000088e00088e00088e00088e00088e00000088e000000088e0000000088e00088e0000000000000000000000000000000000000000000000000000000000000
000088e00088e00088e00088e00088e00000088e000000088e0000000088e00088e0000000000000000000000000000000000000000000000000000000000000
00088e00088e00088e00088888888e00000088e000000088e0000000088888888e00000000000000000000000000000000000000000000000000000000000000
00088e00088e00088e00088eee888e00000088e000000088e0000000088eee888e00000000000000000000000000000000000000000000000000000000000000
0088e00088e00088e00088e00088e00000088e000000088e0000000088e00088e000000000000000000000000000000000000000000000000000000000000000
0088e00088e00088e00088e00088e00000088e000000088e0000000088e00088e000000000000000000000000000000000000000000000000000000000000000
088e00088e00088e00088e00088e00000088e000000088888888e0088e00088e0000000000000000000000000000000000000000000000000000000000000000
0eee000eee000eee000eee000eee000000eee0000000eeeeeeee000eee000eee0000000000000000000000000000000000000000000000000000000000000000
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000007f7f7f7f7f7f7f7f7f000000007f7f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000007f7f7f7f7f7f7f7f000000007f7f7f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000404142434445467f7f00000000007f7f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000505152535455007f00007f7f00007f7f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000007f7f606162636465666768007f7f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000007f7f707172737475767778007f7f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000007f7f474747474747474747007f7f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000474747474747474747007f7f7f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000007f7f7f7f7f7f7f7f7f007f7f7f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000007f7f0000000000007f7f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000007f7f00000000007f7f7f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000007f7f00000000007f7f7f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000007f7f0000000000007f7f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000007f7f7f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000048494a4b4c4d7f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000005758595a5b5c5d7f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000005758000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000006768000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000575857580000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000676867680000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000057585758575800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000067686768676800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
012300001f5551f5001f5002155522555225002250022500225002250022500225002155521500215001d5551f5551f5001f5001f5001f5001f5001f5001f5551f5551f5001f5001f5001d5001d5001d5551f500
012300001f55500000000002155522555000000000000000245002150000000245002455521555000001d5551f555000000000000000000001d5551a5551d5551f5550000000000000001f555000001f55500000
012300000775513700077551370007755137000775513700057551370005755137000575513700057551370007755137000775513700077551370007755077550775513700077551370007755137000775500000
012300001a5201a5201a5201a5201a5201a5201a5201a52018520185201852018520185201852018520185201a5201a5201a5201a5201a5201a5201a5201a5201a5251a5001a5351a5001a5451a5001a5351a500
012300001352013520135201352013520135201352013520115201152011520115201152011520115201152013520135201352013520135201352013520135201352513500135351350013545135001353513500
012300001a12513125161251a12513125161251a125131251812511125151251812511125151251812515125161251a12513125161251a12513125161251a12513125161251a12513125161251a1251312516125
012300001352013520135201352013520135201352013520115201152011520115201152011520115201152013520135201352013520135201352013520135201352013520135201352013520135201352013520
010d00001f1351f1001d1351d1001f1350c0001a1350c0001f1350c0001d1350c0001f1350c0001a1350c0001d1351f1351f10022135221000c0000c0000c0001d1351f1351f10022135221000c0001f1351d135
010d0000070300703013030130300703007030130301303007030070301303013030070300703013030130300a0300a03016030160300a0300a03016030160300503005030110301103005030050301103011030
010d00000703007030130301303007030070301303013030070300703013030130300703007030130301303000030000300c0300c03000030000300c0300c03002030020300e0300e03002030020300e0300e030
010d00000c773000000000000000136450000000000000000c773000000000000000136450000000000000000c773000000000000000136450000000000000000c77300000000000000013645000000000000000
010d00001f1451f1001f1001f1001f200000001f1451f1001a2001f2001f1451f1001f2001f1001f1451f100241451810000000241000000000000221451a1000000000000221451a10000000000001d1451d100
010d00001f1451f1001f1001f1001f200000001f1451f1001a2001f2001f1451f1001f2001f1001f1451f1001814518100000002410000000000001a1451a10000000000001a1451a10000000000001d1451d100
010600002b55729557265572b50029500265002b50700507005070050700507005070050700507005070050700507005070050700507005070050700507005070050700507005070050700507005070050700507
010600002b5572955726557305572e5572b5572b50700507005070050700507005070050700507005070050700507005070050700507005070050700507005070050700507005070050700507005070050700507
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
01 00 02 43 44
00 01 02 43 44
00 00 02 03 04
00 01 02 03 04
00 05 06 03 44
00 05 06 03 44
00 05 06 02 44
02 05 06 02 03
01 07 08 43 44
00 07 09 43 44
00 07 08 43 44
00 07 09 43 44
00 07 08 0a 44
00 07 09 0a 44
00 07 08 0a 44
00 07 09 0a 44
00 0b 09 0a 44
00 0c 09 0a 44
00 0b 09 0a 44
02 0c 09 0a 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
