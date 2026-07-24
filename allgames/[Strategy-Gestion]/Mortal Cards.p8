pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
--Mortal Cards
--the RoboZ, for Dorian

--todo: 
--spurious sfx playing sometimes, after end

--final release:

--blood and particles
--shadows
--shuffle anim at new stage
--improve and simplify anim system
--goro head
--more difference in anims and more frames

--different super / fatalities

left,right,up,down,fire1,fire2=0,1,2,3,4,5
black,dark_blue,dark_purple,dark_green,brown,dark_gray,light_gray,white,red,orange,yellow,green,blue,indigo,pink,peach = 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
color_mask = green

--„--

dx=20
tw=20
hp=4
vp=16

title_top = {{1+dx,64,1+dx,1,124+dx,1,124+dx,64},

{hp,60-vp, hp,vp, 13,vp+4, tw,vp,  tw,60-vp }, --m
{hp,60-vp, hp,vp, tw,vp, tw,60-vp, hp,60-vp}, --o
{hp,60-vp, hp,vp, tw,vp, tw,32,    hp,32, tw,60-vp}, --r
{tw/2+hp/2,60-vp,tw/2+hp/2,vp, hp,vp, tw,vp}, 
{hp,60-vp, hp,vp, tw,vp, tw,60-vp, tw,32, hp,32}, --a
{hp,vp,hp,60-vp, tw,60-vp}  --l
}

title_bottom = {{1+.5*dx,0, 1+.5*dx,60, 124+.5*dx,60, 124+.5*dx,0},
    
    {tw,60-vp, hp,60-vp, hp,vp, tw,vp}, --c
    {hp,60-vp, hp,vp, tw,vp, tw,60-vp, tw,32, hp,32}, --a
    {hp,60-vp, hp,vp, tw,vp, tw,32,    hp,32, tw,60-vp}, --r
    {hp,60-vp, hp,vp, tw,vp+hp, tw,60-vp-hp, hp,60-vp}, --d
    {tw,vp, hp,vp, hp,32, tw,32, tw,60-vp, hp,60-vp}, --s
}

torso_frame = {{128}, {130}, {132}, {134}, {138}, {136}, {128,137}, {142,137}, {175,137}, {175,129}, {142,129}, {143,129},
                {136,136}, {128,128}, {142,142},{138,0,0,0},{128,140},{128,141},
                {128,140},{128,141},{143,140},{143,141},{175,140},{175,141}
}

leg_frame   = {{160}, {162}, {164}, {168}, {173}, {164,163}, {160,163}, {186,187,188}, {168,170,171,0}, {160,170,171,0}, {166}}

pose_frames = {{1,1},{1,2},{1,3},{1,4},{1,5},{1,6},{1,7},{1,8},{1,9},
               {2,1},{2,2},{2,3},{2,4},{2,5},{2,6},
                     {3,2},{3,3},
               {4,1},{4,2},               { 4,5},{4,6},{4,7},
                     {5,2},{5,3},         { 5,5},
               {6,1},{6,2},         { 6,4},   --6,1 and 6,4 are the same almost, maybe remove one of the leg frames
               {7,1},{7,2},         { 7,4},
               {8,1},{8,2},         { 8,4},
               {9,1},{9,2},         { 9,4},
               {10,1},{10,2},{10,3},{10,4},{10,5},{10,6},{10,7},       {10,9},
               {11,1},{11,2},{11,3},{11,4},{11,5},{11,6},{11,7},{11,8},{11,9},
               {12,1},{12,2},{12,3},       {12,5},{12,6},{12,7},{12,8},{12,9},
               {0,11},{1,10},{4,3},{13,4},{14,4},{15,4},
               {16,1},{16,2},{16,3},
               {17,1},{17,2},{17,3},{17,4},{17,5},{17,6},{17,7},{17,8},{17,9},
               {18,1},{18,2},{18,3},{18,4},{18,5},{18,6},{18,7},{18,8},{18,9},
               {19,1},{19,2},{19,3},{19,4},{19,5},{19,6},{19,7},{19,8},{19,9},
               {20,1},{20,2},{20,3},{20,4},{20,5},{20,6},{20,7},{20,8},{20,9}
}

skorpion_torso_offs = {   [3]= 2,  [4]= 1,  [5]= 1,  [6]= 1,  [8]=-1,  [9]= 1,
                [12]= 2, [13]= 2, [14]= 2, [16]= 4,
                [17]= 5, [18]=-1, [19]=-1, [21]=-1, [22]=-1,
                [40]= 2, [41]= 2, [42]= 1, [43]= 2, [44]= 1, [45]= 1, [48]= 2,
                [49]= 1, [50]= 2, [51]= 1, [53]=-2, [57]= 1, [58]= 1, [59]= 1, [61]=-2,
                [66]= 1, [67]= 1, [68]= 1
}

liukang_torso_offs = {    [2]=-2,  [3]= 1,  [4]= 1,  [5]=-4,
                [10]=-2, [11]=-4, [13]=-1, [14]=-6, [16]=-1,
                [17]= 2, [18]=-1, [19]=-3, [20]=-4, [22]=-3,
                [23]=-2, [24]= 2, [25]=-5, [26]=-1, [39]=-2,
                [40]= 1, [42]=-4, [47]=-2, [48]= 2, [49]= 1,
                [50]=-4, [56]=-1, [57]= 1, [58]=-4, [61]=-2,[64]=-1
}

y_offs = {   [2]=4,  [8]=8,   [11]=4,   [16]=4,   [19]=4,  [23]=4, [27]=4, [30]=4,
            [33]=4,  [36]=4,  [39]=4,  [47]=4,  [53]=8, [56]=4, [61] = 8, [100]=4,} 

raiden_hat = {[ 3]= 2, [ 4]= 1,  [5]= 1, [ 6]= 1, [ 8]=-1,
              [ 9]= 1, [10]=-3, [11]=-3, [12]=-2, [13]=-2,
              [14]=-2 ,[15]=-4, [16]= 1, [17]= 2, [18]=-3,
              [19]=-3, [20]=-2, [21]=-3, [22]=-3, [23]= 4, [24]= 4, [25]= 4,
              [40]= 2, [41]= 2, [42]= 1, [43]= 2, [44]= 1, [45]= 1, [48]= 2, [49]= 1,
              [50]= 2, [51]= 1, [53]=-2, [57]= 1, [58]= 1, 
              [59]= 1, [61]=-3, [65]=-3
}

skorpion= 1
subzero = 2
liukang = 3
raiden  = 4
cage    = 5
reptile = 6
goro    = 7

heroes     ={  skorpion,   subzero,   liukang,  raiden,       cage,  reptile,  goro}
names      ={"skorpion","sub-zero","liu kang","raiden","johnny cage","reptile","goro"}
small_names={"SKORPION","SUB-ZERO","LIU KANG","RAIDEN",       "CAGE","REPTILE","GORO"}
portrait   ={28,31,28,66,32,35,31}
port_colors={13,2,8,12,3,4}
sp_color   ={ 3, 5, 1, 6, 2, 4, 8}

skorpion_anims = {
    { 1, 2, -8, 8,56}, --g
    { 1, 2,-16,16,56}, --l
    { 1,58,52,-54,54,59}, --m
    { 1, 3,-17,17,57}, --h
    { 1,47,23,24,-17,17,57}, --u
    { 1,12,14,10,10,12}, --bh
    { 1, 2,11,11,11,12}, --bl
    { 1, 3,48,-25, 25,25, 3}, --sp
    { 1,18,20,65,22}, --hh
    { 1, 2,19,19, 2}, --hl
    { 1,55,32,31,28,28,28,28}, --win
    { 1,32,36,63,63,63,63,63}, --lose
    { 1, 4, 57, 3, 4}, --idle
}

reptile_anims = {
    { 38,47, -53, 53,47}, --g
    { 38,56,-16,16,47}, --l
    { 38,50,52,-62,62,59}, --m
    { 38,57,-17,17,48}, --h
    { 38,18,19,24,-17,17,57}, --u
    { 38,12,14,10,10,12}, --bh
    { 38,47,11,11,11,12}, --bl
    { 38,40,48,-25,25,25, 40}, --sp
    { 38,18,20,21,22}, --hh
    { 38, 2,19,19, 2}, --hl
    { 38,32,35,37,37,37,37,37}, --win
    { 38,35,36,63,63,63,63,63}, --lose
    { 38,41,48,49,41}, --idle
}

subzero_anims = {
    { 38,47,- 61, 61,47}, --g
    { 38,56,-16,16,47}, --l
    { 38,50,52,-62,62,59}, --m
    { 38,57,-17,17,48}, --h
    { 38,47,23,24,-17,17,57}, --u
    { 38,12,14,10,10,12}, --bh
    { 38,47,11,11,11,12}, --bl
    { 38,40,48,-25, 25,25, 40}, --sp
    { 38,18,20,21,22}, --hh
    { 38, 2,19,19, 2}, --hl
    { 38,46,32,31,28,28,28,28}, --win
    { 38,32,36,63,63,63,63,63}, --lose
    { 38, 49, 49, 57, 49}, --idle
}

raiden_anims = {
    { 99,47,- 61, 61,47}, --g
    { 99, 100,-16,16,56}, --l
    { 99,50,52,-62,62,59}, --m
    { 99, 101,-17,17,57}, --h
    { 99,18,19,24,-17,17,57}, --u
    { 99,12,14,10,10,12}, --bh
    { 99, 100,11,11,11,12}, --bl
    { 99, 101,48,-25, 25,25, 101}, --sp
    { 99,18,20,65,22}, --hh
    { 99, 100,19,19, 100}, --hl
    { 99,55,68,67,66,66,66,66}, --win
    { 99,32,36,63,63,63,63,63}, --lose
    { 99, 93, 57, 101, 102}, --idle
}

liukang_anims = {
    { 1, 2,-61,61, 2}, --g                1
    { 1,47,-16,16,56}, --l                2
    { 1,50,64,-62,62, 5}, --m             3
    { 1, 49,-17,17, 3}, --h               4
    { 1,56,23,24,-17,17,57}, --u          5
    { 1,12,14,10,10,12}, --bh            6
    { 1, 2,11,11,11,12}, --bl            7
    { 1, 3,48,-25,25,58,55}, --sp         8
    { 1,18,20,65,3}, --hh                9
    { 1, 2,19,19, 2}, --hl              10
    { 1,55,41,31,28,28,28,28}, --win    11
    { 1,38,27,63,63,63,63,63}, --lose   12
    { 1, 46, 48, 49, 4}, --idle         13
}

cage_anims = {
    { 99, 100,-61,61, 100}, --g                1
    { 99,47,-16,16,56}, --l                2
    { 99,50,64,-62,62, 5}, --m             3
    { 99, 49,-17,17, 3}, --h               4
    { 99,56,23,24,-17,17,57}, --u          5
    { 99,12,14,10,10,12}, --bh            6
    {99, 100,11,11,11,12}, --bl            7
    { 99, 101,48,-25,25,58,55}, --sp         8
    { 99,18,20,65,3}, --hh                9
    { 99, 2,19,19, 2}, --hl              10
    { 99,55,37,32,35,35,35,35}, --win    11
    { 99,38,27,63,63,63,63,63}, --lose   12
    { 99, 1, 3, 1, 102}, --idle         13
}

goro_anims = {
    { 1}, --g
    { 1, 16,-27,27,16,2}, --m --{ 1}, --l

    {1},--{ 1, 16,-27,27,16,2}, --m 
    { 1, 17,-28,28,3}, --h 

    { 2,19,20,14,-28,28,3}, --u
    
    { 1,12,13,10,10,12}, --bh
    { 1, 2,11,11,11,12}, --bl

    { 1}, --sp
    
    { 1,18,20,65,22}, --hh
    { 1, 2,19,19, 2}, --hl    
    { 1,18,69,71,71,71,71}, --win
    { 1,2,11,19,19,19,19,19}, --lose

    { 1, 3, 4, 13, 12} --idle
}

goro_torso_offs = {  [3]= 2,  [4]= 2,  [5]= 1,  [6]= 1,  [8]=-1,  [9]= 1, 
                    [12]= 2, [13]= 2, [14]= 2, [16]= -2,
                    [17]= 0, [18]=-1, [19]=-1, [21]=-1, [22]=-1, [27]= 3, [28]=5,
                    [40]= 2, [41]= 2, [42]= 1, [43]= 2, [44]= 1, [45]= 1, [48]= 2,
                    [49]= 1, [50]= 2, [51]= 1, [53]=-2, [57]= 1, [58]= 1, [59]= 1, [61]=-2,
                    [69]= 0, [70]= -1, [71]= 3
}

dmg_table={ { 0, 9,-2, 1,-3, 1, 0,-3},
            { 9, 0, 9, 2,-3, 1, 0,-3},
            { 2, 9, 0,-2,-3, 0, 2,-3},
            {-1,-2, 2, 0,-3, 0, 0,-3},
            { 3, 3, 3, 3, 0, 1, 1,-3},
            {-1,-1, 0, 0,-1, 0, 0,-3},
            { 0, 0,-2, 0,-1, 0, 0,-3},
            { 3, 3, 3, 3, 3, 3, 3, 0}            
}

rank = {"g","l","m","h","u","bl","bh","s"}
full_rank = {"gRND","lOW","mID","hIGH","uPP","bLKl","bLKh","sPCL"}

pl_card_offset = -8

max_cards = 5
max_hlt   = 6
draw_hlt_scale = 7
max_auto_play_timer = 240

sp_radius = 0
sp_max_radius = 8

ms_time = 0


function animate()	
    pl_anim_tik=(pl_anim_tik+1)%anim_step --tick fwd
    if pl_anim_tik==0 then
        pl_a_frm +=1
        if pl_a_frm == #anims[pl_anim]+1 then
            --to idle!
            if pl_anim!=11 and pl_anim!= 12 then
                 pl_anim=13 pl_a_frm=1
            else 
                pl_a_frm -=1
            end   
            return false
        end
    end
    return true	
end

function animate_opp()	
    opp_anim_tik=(opp_anim_tik+1)%anim_step --tick fwd
    if opp_anim_tik==0 then
        opp_a_frm +=1
        if opp_a_frm == #anims[opp_anim]+1 then
            --to idle!
           if opp_anim!=11 and opp_anim!= 12 then
                opp_anim=13 opp_a_frm=1
            else 
                opp_a_frm -=1
            end
            return false
        end
    end
    return true	
end

function cloud_add(xpos,ypos)
    local c={}
    c.parts={}
    c.w=0

    local lr=0

    for p=1,4 do
        local r = flr(8+rnd(24-16))
        c.parts[p] = {}			
        c.parts[p].r = r
        c.parts[p].x = lr+r
        c.parts[p].y = flr(.25*-r+rnd(r)/2)
        c.w += lr
        lr=flr(1.5*r)
    end

    if xpos == -1 then
        c.x=-c.w
    elseif xpos ==-128 then
        c.x=-xpos
    else
        c.x= xpos
    end

    if ypos == -1 then
        c.y=-flr(c_max_r*.5)
    elseif ypos ==-128 then
        c.y=-ypos
    else
        c.y= ypos
    end

    c.s =  c.parts[1].r/2
    add(clouds,c)
end

function cloud_update()	
	for cloud in all(clouds) do
		local sp = cloud.s/10		
			cloud.x+=sp
			if (cloud.x > 128) del(clouds,cloud) cloud_add(-1,rnd(128))		
	end
end

function cloud_draw()
	for cloud in all(clouds) do		
        for p=1,4 do
			local cp = cloud.parts[p]
			
			circfill(cloud.x + cp.x, cloud.y + cp.y, cp.r-1, cloud_c1)
        end

        for p=1,4 do
			local cp = cloud.parts[p]
			circfill(cloud.x + cp.x + 2, cloud.y + cp.y + 2, cp.r,cloud_c2)	
			
        end
	end
end

function draw_hat(frm,x,y,flip)
    if(frm==63) return
    local sp,oy = 93,0
    if(y_offs[frm]) oy=y_offs[frm]\2

    if ((frm<66 or frm >90)and (frm < 26 or frm >37)) sp = 77 

    local x_of,y_of=5,-1
    if(flip) x_of=3 
   
    if raiden_hat[frm] then         
        if flip then 
            x_of-= raiden_hat[frm]
        else 
            x_of+= raiden_hat[frm]
        end       
    end      

    spr(sp,x+x_of,y+y_of+oy,1,1,flip)
end

function draw_hlt_bars()
    y=8

    print_s("round "..round,256,y+2,white)

    rectfill(0,y+0,draw_hlt_scale*max_hlt+4,y+9,indigo)
    rectfill(1,y+1,draw_hlt_scale*max_hlt+4,y+9,dark_gray)
    rectfill(2,y+2,2+draw_hlt_scale*max_hlt,y+7,red)
    if(player_draw_hlt>0) rectfill(2,y+2,2+player_draw_hlt,y+7,green)

    s=small_names[pl_id]
    print_s(s,4,y+2,yellow)

    rectfill(127-draw_hlt_scale*max_hlt-4,y,127,y+9,indigo)
    rectfill(127-draw_hlt_scale*max_hlt-3,y+1,127,y+9,dark_gray)
    rectfill(127-2-draw_hlt_scale*max_hlt,y+2,125,y+7,red)
    if(opponent_draw_hlt>0) rectfill(127-2-opponent_draw_hlt,y+2,125,y+7,green)

    s=small_names[opp_id].." "
    print_s(s,512,y+2,yellow)
end

function draw_covered_card(x,y)
    spr(64,x,y-8,2,1)
    spr(68,x,y,2,1)
    spr(68,x,y+8,2,1,true,true)
    spr(66,x,y+16,2,1)
end

function draw_revealed_card(rk,x,y,flip)
    pal_tint(black)
    spr(64,x,y-8,2,1)
    spr(64,x,y+16,2,1,false,true)
    pal_default()
    spr(96+2*(rk-1),x,y,2,2,flip)
    print(rank[rk],x+16-4*#rank[rk],y+17,dark_purple)
end    

function draw_opponent_hand()
    --local x_c_ofs=0
    pal(13,port_colors[opp_id])
    rk = opponent_hand[1]
    
    for i=2,#opponent_hand do
        local x_c_ofs=0
        x=127-4 -2*(4+i)
        y=112
        local max_o = 10 + 2*(4-#opponent_hand)
        if(i==#opponent_hand and pl_card_offset>0) x_c_ofs = min(pl_card_offset/2,max_o)
        draw_covered_card(x-x_c_ofs,y-i)
    end
    
    pal_default()

    x= 127-32
    y= 128-16+pl_card_offset
    
    draw_revealed_card(rk,x,y,true)
    print(full_rank[rk],x+1,y-6,dark_purple)
end    

function draw_player_hand()    
    local x_c_ofs
    
    for i=1,#player_hand do
        
        x=1+17*(i-1)
        y=112
        
        if i==pl_selected_card then
             y+= pl_card_offset
             x_c_ofs =  0
        elseif pl_card_offset > 0 and i > pl_selected_card then
           x_c_ofs =  min(pl_card_offset,17)
        else 
            x_c_ofs =  0
        end

        local rk = player_hand[i]

        draw_revealed_card(rk,x-x_c_ofs,y,false)

        if i==pl_selected_card then
            print(full_rank[rk],x+1-x_c_ofs,y-6,dark_purple)
        else
            print(rank[rk],x+1-x_c_ofs,y-6,dark_purple)
        end
    end      
end

function draw_player(id,x,y,flip) 
    set_char(id)
    
    local anim_frame = anims[pl_anim][pl_a_frm]

    if(anim_frame<0) anim_frame=-anim_frame do_hit(true)    
    
    if(y_offs[anim_frame]) y+=y_offs[anim_frame]
    if(y_offs[anim_frame]==4 and (id == liukang or id == cage)) y+=2 --move this in update
  
    draw_torso(id,anim_frame,x,y,flip)
    draw_legs(id,anim_frame,x,y,flip)
    pal_default()
    
    if (id==raiden) draw_hat(anim_frame,x,y)
end

function draw_opponent(id,x,y,flip) 
    set_char(id)
    local anim_frame = anims[opp_anim][opp_a_frm]
    if(anim_frame<0) anim_frame=-anim_frame do_hit(false) --move this in update

    if id != goro then
        if(y_offs[anim_frame]) y+=y_offs[anim_frame]
        if(y_offs[anim_frame]==4 and (id == liukang or id == cage)) y+=2    --move this in update
   end
    draw_torso(id,anim_frame,x,y,flip)
    draw_legs(id,anim_frame,x,y,flip)
    pal_default()
    
    if (id==raiden) draw_hat(anim_frame,x,y,flip)
end

function draw_legs(pl_id,frm,x,y,flip)
    local l_offs=16
    y=y+l_offs

    if pl_id==liukang or pl_id == cage then
        sp_off= 64
    elseif pl_id == goro then
        sp_off= -128
    else
        sp_off =0
    end
    local l_frm = pose_frames[frm][2]

    if #leg_frame[l_frm] == 1 then
        spr(leg_frame[l_frm][1]+sp_off,x,y,2,2,flip)
    elseif #leg_frame[l_frm] == 2 then
        if flip then f_x=8 else f_x=0 end
        spr(leg_frame[l_frm][1]+sp_off,x+f_x  ,y,1,2,flip)
        spr(leg_frame[l_frm][2]+sp_off,x+8-f_x,y,1,2,flip)
    else
        if flip then f_x,f_x1,f_x2=8,0,-8 else f_x,f_x1,f_x2=0,8,16 end
        spr(leg_frame[l_frm][1]+sp_off,x+f_x,  y,1,1+#leg_frame[l_frm]-3,flip)
        spr(leg_frame[l_frm][2]+sp_off,x+f_x1, y,1,1,flip)
        spr(leg_frame[l_frm][3]+sp_off,x+f_x2, y,1,1,flip)
    end
    --print_s("legs: "..l_frm,x,16,7)
end

function draw_torso(pl_id,frm,x,y,flip)
    local ox,oy=0,0

    if pl_id==liukang or pl_id == cage then
        sp_off= 64
        torso_offs = liukang_torso_offs
    elseif pl_id == goro then
        sp_off= -128
        torso_offs = goro_torso_offs 
    else
        sp_off=0
        torso_offs = skorpion_torso_offs
    end

    if(torso_offs[frm]) ox=torso_offs[frm]
    if (flip) ox=-ox
    if(y_offs[frm]) oy=y_offs[frm]\2

    local t_frm = pose_frames[frm][1]

    if flip then gx=6 else gx = 2 end
    if ((frm== 69 or frm == 71)and pl_id == goro) y-=4 spr(14,x+ox+gx,y+oy+16,1,1,flip)
    
    if t_frm != 0 then
        if #torso_frame[t_frm] == 1 then
            spr(torso_frame[t_frm][1]+sp_off,x+ox,y+oy,2,2,flip)
        elseif  #torso_frame[t_frm] == 2 then
            if flip then f_x=8 else f_x=0 end
            spr(torso_frame[t_frm][1]+sp_off,x+ox+f_x,y+oy,1,2,flip)
            if torso_frame[t_frm][2]==torso_frame[t_frm][1] then
                spr(torso_frame[t_frm][2]+sp_off,x+ox+8-f_x,y+oy,1,2,not flip)
            else
                spr(torso_frame[t_frm][2]+sp_off,x+ox+8-f_x,y+oy,1,2,flip)
            end
        elseif  #torso_frame[t_frm] == 4 then
            spr(torso_frame[t_frm][1]+sp_off,x+ox-8,y+oy,4,2,flip)        
        end
        

        goro_torso(pl_id,frm,x,y,flip,ox,oy)

        --print_s("torso: "..t_frm,x,8,7)
    end  
end

function goro_torso(pl_id,frm,x,y,flip,ox,oy)
    if pl_id==goro and frm < 69 then              
        if ((frm >17 and frm<23)or frm==65) oy+=2
        if frm<10 or frm>17 then 
            if flip then
                spr(47,x+ox+16,y+oy,1,2,flip)
            else
                spr(47,x+ox-8,y+oy,1,2,flip)
            end
        end
       
       if ((frm >17 and frm<23)or frm>64) oy-=4

       if frm!=26 and frm!=27 and frm!=28 and frm!=16 and frm!=17 then
        if flip then
            if (frm>9 and frm<16) ox+=1
            spr(15,x+ox-8,y+oy,1,2,flip)
        else
            if (frm>9 and frm<16) ox-=1
            spr(15,x+ox+16,y+oy,1,2,flip)
        end
    end
    end 
end

function draw_statue(statue,y)    
    if (statue == goro) statue = 0
    pal(10,7)
    pal(15,7)
    pal(9,6)
    pal(14,6)
    pal(4,13)
    pal(0,5)
    pal(8,6)
    pal(2,5)
    pal(12,5)
    pal(3,6)        
    if(statue == cage) palt(2,true)  pal(1,13)      
    
    map(4*statue,12,88,y,4,4)
    if(statue == raiden) spr(136,96+8,y,1,2,flip) spr(93,96+4,y)
    
    pal_default()
end    

function draw_title()
    local x=-1
    local voff = 65
    for v in all(title_top) do 
        if x<0 then col1=white col2=dark_gray else col1=yellow col2=orange end
        for p=1,#v-2,2 do   
            line(x*dx+v[p]+2,v[p+1]+2-(voff-title_dy),x*dx+v[p+2]+2,v[p+3]+2-(voff-title_dy),black)
            line(x*dx+v[p]+1,v[p+1]+2-(voff-title_dy),x*dx+v[p+2]+1,v[p+3]+2-(voff-title_dy),black)
            line(x*dx+v[p]+2,v[p+1]+1-(voff-title_dy),x*dx+v[p+2]+2,v[p+3]+1-(voff-title_dy),black)

            line(x*dx+v[p]+1,v[p+1]+1-(voff-title_dy),x*dx+v[p+2]+1,v[p+3]+1-(voff-title_dy),col2)
            line(x*dx+v[p],v[p+1]+1-(voff-title_dy),x*dx+v[p+2],v[p+3]+1-(voff-title_dy),col2)
            line(x*dx+v[p]+1,v[p+1]-(voff-title_dy),x*dx+v[p+2]+1,v[p+3]-(voff-title_dy),col2)
            
            line(x*dx+v[p],v[p+1]-(voff-title_dy),x*dx+v[p+2],v[p+3]-(voff-title_dy),col1)
        end
        x+=1
    end
   
    x=-0.5
    voff = 128
    for v in all(title_bottom) do 
        if x<0 then col1=white col2=dark_gray else col1=yellow col2=orange end
        for p=1,#v-2,2 do
            line(x*dx+v[p]+2,v[p+1]+2+(voff-title_dy),x*dx+v[p+2]+2,v[p+3]+2+(voff-title_dy),black)
            line(x*dx+v[p]+1,v[p+1]+2+(voff-title_dy),x*dx+v[p+2]+1,v[p+3]+2+(voff-title_dy),black)
            line(x*dx+v[p]+2,v[p+1]+1+(voff-title_dy),x*dx+v[p+2]+2,v[p+3]+1+(voff-title_dy),black)

            line(x*dx+v[p]+1,v[p+1]+1+(voff-title_dy),x*dx+v[p+2]+1,v[p+3]+1+(voff-title_dy),col2)
            line(x*dx+v[p],v[p+1]+1+(voff-title_dy),x*dx+v[p+2],v[p+3]+1+(voff-title_dy),col2)
            line(x*dx+v[p]+1,v[p+1]+(voff-title_dy),x*dx+v[p+2]+1,v[p+3]+(voff-title_dy),col2)
            
            line(x*dx+v[p],v[p+1]+(voff-title_dy),x*dx+v[p+2],v[p+3]+(voff-title_dy),col1)                                               
        end
        x+=1
    end    
end


function draw_stage()
    if stage >= 3 then       
       
        cls(1)      
        cloud_c2 = dark_blue
        cloud_c1 = blue
        cloud_draw()

        if (phase =="ending") clip(0,statue_y+32,127,127)
        
        draw_statue(dget(0),40)

        if (phase =="ending") clip()

        map(0,0,0,0,16,12)        
        stage_y = 58
    elseif stage == 2 then
        cls(2)
        cloud_c2 = dark_purple
        cloud_c1 = orange
        fillp(0b1010111101011111.1)
        cloud_draw()
        rectfill(0,66,127,127,black)
        fillp()
        map(16,0,0,0,16,12)
        stage_y = 46
    elseif stage == 1 then
        cls(12)
        cloud_c2 = white
        cloud_c1 = light_gray
        cloud_draw()        
        rectfill(0,44,127,127,1)
        pal(6,13)
        pal(5,2)
        pal(13,5)
        pal(7,6)
        map(32,0,0,0,16,12)
        line(0,80,127,80,1)
        pal_default()
        stage_y = 58
    end
end


function set_pl_anim(anim)
    pl_anim = anim
    pl_a_frm = 1               
    pl_anim_tik = 0
end    

function set_opp_anim(anim)
    opp_anim = anim
    opp_a_frm = 1        
    opp_anim_tik = 0
end    

function do_hit(player)

    if hit<0 and player==false then 
        --player hit
        set_pl_anim(9)

        if hit==-3 then
            sfx(3)
            intensity = 3
            if (opp_anim == 8) sp_radius = 1
        else
            sfx(0) --stop("A")
        end

        player_hlt+=hit                    
        if(player_hlt<=0) player_hlt = 0

        hit=0

    elseif hit==9 and player==true then 
        --both hit with attack frame, we do it only once on palyer to avoid double damage
        
        sfx(2)         
        player_hlt-=1
        opponent_hlt-=1        
        if(player_hlt<=0) player_hlt = 0     
        if(opponent_hlt<=0) opponent_hlt = 0    

        hit=0

    elseif hit>0 and player==true then 
        --hit opponent

        opp_anim = 9
        opp_a_frm = 1        
        opp_anim_tik = 0

        if hit==3 then 
            intensity = 3
            sfx(3)
            if (pl_anim == 8) sp_radius = 1
        else 
            sfx(0)-- stop("B")
        end

        opponent_hlt-=hit                    
        if(opponent_hlt<=0) opponent_hlt = 0

        hit=0

    elseif hit ==0 then 
        sfx(1)       
    end    
end

function increase_wins()
    if player_hlt<opponent_hlt then
        opponent_wins+=1
    elseif player_hlt > opponent_hlt then
        player_wins+=1
    end
end

function _init()    
    cartdata("mortal_cards")    
    pl_anim_tik=0
    opp_anim_tik=0
    anim_step=3

    anims = skorpion_anims
    pl_id = 1
    stage = 0
    
    intensity = 0
    shake_control = 5
    music(2)
    --for select screen
    set_pl_anim(13)
    pal_default()
    title_dy=0
    _update = t_update
    _draw = t_draw
    statue_y=0
end

function init_decks()
    player_cards, opponent_cards = {}, {}
    for i=1,7 do 
        add(player_cards,i)add(player_cards,i)
        
       if (i==1 or i==3) and opp_id == goro then 
            add(opponent_cards,i+1)add(opponent_cards,i+1)
        else
            add(opponent_cards,i)add(opponent_cards,i)    
        end
    end    

    add(player_cards,8)

    if opp_id != goro then 
        add(opponent_cards,8)
    else         
        add(opponent_cards,5)
    end

    round=1
end

function init_opponent_hand()
    opponent_hand={}
    for i=1,5 do
        local c=flr(rnd(#opponent_cards))+1
        add(opponent_hand,opponent_cards[c])
        del(opponent_cards,opponent_cards[c])
    end
    opponent_hlt= max_hlt
    opponent_draw_hlt = draw_hlt_scale*opponent_hlt

    set_opp_anim(13)
end

function init_player_hand()
    player_hand={}
    for i=1,5 do
        local c=flr(rnd(#player_cards))+1
        add(player_hand,player_cards[c])
        del(player_cards,player_cards[c])
    end
    player_hlt = max_hlt
    player_draw_hlt = draw_hlt_scale*player_hlt

    set_pl_anim(13)

    pl_selected_card = 1
end

function new_round()
    music(2)
    init_opponent_hand()
    init_player_hand()
    phase = "deal"
    auto_play_timer = max_auto_play_timer
    --particles
    effects = {}
    fire_width = 3   
    fire_amount = 8            
    fatality=false
    deal_t=0
end

function new_stage(r)
    if (not r) stage+= 1

    if stage == 5 then 
        phase ="ending" 
        statue_y=-32       
    else
        clouds={}
        for i=1,8 do cloud_add(rnd(128),rnd(64)) end
        
        player_wins=0
        opponent_wins=0
    
        if (stage >= 4) then opp_id = goro else
        opp_id = heroes[stage]
        end
   
        init_decks()
        new_round()    
    end
end


function pal_default()
    pal()
    palt(0,false)
    palt(color_mask,true)
end

function pal_liukang()
    pal({[1]=0,[2]=0,[3]=0,[12]=15})
end

function pal_cage()
    palt(2,true)
    pal({[1]=14, [3]=15, [8]=4, [12]=1})
end

function pal_skorpion()
    pal({[1]=14, [3]=15, [2]=4, [8]=9, [12]=0})
end

function pal_raiden()
    pal({[0]=7 ,[2]=4 ,[3]=0 ,[4]=13 ,[5]=13 ,[8]=9 ,[9]=6 ,[10]=6 ,[12]=0})
end

function pal_reptile()
    pal({[1]=14, [2]=3, [3]=15, [4]=5, [8]=11, [9]=3, [10]=11, [12]=0})
end

function pal_subzero()
    pal({[1]=14, [2]=13, [3]=15, [4]=3, [8]=12 ,[9]=13 ,[10]=12,[12]=0})
end

function pal_tint(col)
	for i=1,15 do pal(i,col) end
end

function print_s(s,x,y,c)
    if x \ 256 ==1  then x -= 192+2*#s elseif x \ 512 == 1 then x -= 384+4*#s end
    ?s,x+1,y,0
    ?s,x,y+1,0
    ?s,x+1,y+1,0
    ?s,x,y,c
    return x
end

function set_char(char)
    pal_default()
    if char == skorpion then
        anims = skorpion_anims pal_skorpion()
    elseif char == subzero then
        anims = subzero_anims pal_subzero()
    elseif char == liukang then
        anims = liukang_anims pal_liukang()
    elseif char == raiden then
        anims =  raiden_anims pal_raiden()
    elseif char == cage then
        anims = cage_anims pal_cage()
    elseif char == reptile then
        anims = reptile_anims pal_reptile()
    elseif char == goro then 
        anims = goro_anims pal_default()
    end
end

function shake()
    shake_x=rnd(intensity) - (intensity /2)
    shake_y=rnd(intensity) - (intensity /2)

    --ease shake and return to normal
    intensity *= .75
    if intensity < .3 then intensity = 0 shake_x=0 shake_y=0 end
end

function f_draw()

    camera( shake_x, shake_y )
    pal_default()
    draw_stage()
    camera()

    if phase != "ending" then
        y=1
        s=player_wins.." wins"
        print_s(s,1,y,yellow)
        s=opponent_wins.." wins"
        print_s(s,512,y,yellow)

        draw_hlt_bars()
    else
    
        draw_statue(pl_id,statue_y)

        print_s(names[pl_id].." is the new",256,24,yellow)
        print_s("mortal cards champion!",256,32,yellow)      

    end

    rectfill(0,127-17-15,127,127,dark_green)
        rect(1,127-17-14,126,126,green)

    if phase == "deal" then
        
        --print_s(tostr(deal_t),60,40,white)
                
        if deal_t>0 then
            for i=1,#player_hand do            
                x=1 + deal_t*(17*(i-1))
                y=112 
                draw_covered_card(x,y)
            end

            pal(13,port_colors[opp_id])
            for i=2,#opponent_hand do
                local x_c_ofs=0
                x=127-4 +deal_t*(-2*(4+i))
                y=112                
                draw_covered_card(x,y-i)
            end

            x=127-4 +deal_t*(-2*(4+5))            
            local max_o = 10           
            
            draw_covered_card(x-deal_t*max_o,y-8)
            pal_default()
        end

        print_s("fight!",256,24,yellow)

    elseif phase =="end" then 

        if player_hlt==opponent_hlt then
            s="draw"
        elseif player_hlt > opponent_hlt then
            s=names[pl_id].." wins"
            --set win anim
            if (pl_anim!= 11) set_pl_anim(11) set_opp_anim(12)
        else
            s=names[opp_id].." wins"
            --set lose anim
            if (pl_anim!= 12) set_pl_anim(12) set_opp_anim(11)
        end  
        
        y=24
        print_s(s,256,y,white)
        if (fatality)   print_s("fatality!",256,y+16,red)

        if opponent_wins==2 then
             print_s("game over",256,y+8,red)
        elseif player_wins<2 and round == 3 then 
            print_s("rematch",256,y+8,yellow)
        end

    elseif phase != "ending" then
        s=tostr(auto_play_timer\30+1)        

        if (phase == "fatality")  s="8" print_s("finish him!",256,32,red)
        
        print_s(s,256,1,red)

        if #player_hand>0 then
        draw_player_hand()
        end       

        if #opponent_hand>0 then
        draw_opponent_hand()
        end    
    end

        camera( shake_x, shake_y )
        
        pl_x=46
        y=stage_y
        draw_player(pl_id,pl_x,y,false)

        opp_x=66
        y=stage_y
        draw_opponent(opp_id,opp_x,y,true)

        if (phase=="end") draw_fx()

        if sp_radius>0 then 
            if pl_anim == 8 then
                if pl_id == raiden then draw_raiden_special(y) else 
                    circfill(opp_x-4,stage_y+12,sp_radius,(sp_radius%2)*sp_color[pl_id]+7)
                end
            else
                if opp_id == raiden then
                    draw_raiden_special(y)
                else
                    circfill(opp_x-2,stage_y+12,sp_radius,(sp_radius%2)*sp_color[opp_id]+7)
                end
            end
            sp_radius+=1
            if (sp_radius>sp_max_radius) sp_radius = 0
        end    

    camera()

    --draw_title()
end

function draw_raiden_special(y)
    local r=rnd(2*8)-8
                line(pl_x+12,y+16,pl_x+10+8,y+16+r,white)
                local r2=rnd(2*8)-8
                line(pl_x+10+8,y+16+r, opp_x,y+16+r2,white)                
                line(opp_x,y+16+r2,opp_x+8,y+16,white)

                local r=rnd(2*8)-8
                line(pl_x+12,y+16,pl_x+10+8,y+16+r,blue)
                local r2=rnd(2*8)-8
                line(pl_x+10+8,y+16+r, opp_x,y+16+r2,blue)                
                line(opp_x,y+16+r2,opp_x+8,y+16,blue)
end                

function f_update()

    ms_time = flr(time()*1000)
    cloud_update()
    --run shake when intensity high
    if intensity > 0 then shake() end

    set_char(pl_id)
    animate()
    set_char(opp_id)
    animate_opp()    
    
    if phase == "deal" then
        deal_t+=0.125
        if(deal_t > 1) phase = "player"

    elseif phase == "ending" then
        
        if statue_y<40 then 
            statue_y+=4 
            if (statue_y>40) statue_y =40
            if(statue_y == 40) intensity = 3 --particles!
        else

            if (btnp(fire1)) run()
        end

    elseif phase == "animation" then    

        if (pl_card_offset >-8) pl_card_offset+=4
        if pl_card_offset > 24+4 then
            del(player_hand,  player_hand[pl_selected_card])
            del(opponent_hand,opponent_hand[1])
            pl_card_offset = -8
            if(pl_selected_card>#player_hand) pl_selected_card-=1
        end

        if player_draw_hlt == draw_hlt_scale*player_hlt
            and opponent_draw_hlt == draw_hlt_scale*opponent_hlt then
            
            if pl_card_offset == -8 and pl_anim == 13 and opp_anim == 13 then

                if player_hlt==0 or opponent_hlt==0 then
                    if #player_hand == 0 or fatality then
                        increase_wins()
                        phase = "end"
                        sfx(4)
                    else--if opponent_hlt==0 then                     
                       phase = "fatality"
                       music(0)
                       auto_play_timer = 40
                    end
                else
                    phase = "player"
                    auto_play_timer = max_auto_play_timer
                end 
            end

        else          
            if (player_draw_hlt>0 and player_draw_hlt> draw_hlt_scale*player_hlt) player_draw_hlt-=1
            if (opponent_draw_hlt>0 and opponent_draw_hlt> draw_hlt_scale*opponent_hlt) opponent_draw_hlt-=1
        end
        
    elseif phase == "end" then        
        update_fx()
        if btnp(fire1) then
            round+=1
            if round<= 3 and player_wins<2 and opponent_wins<2 then                
                new_round()
            elseif player_wins == 2 or fatality then
                new_stage()
            elseif opponent_wins == 2then                 
                --@todo: game over
                run()
            else                 
                new_stage("repeat")                
            end
        end       
        
    elseif phase == "fatality" then        
        
        if player_hlt==0 then 
            auto_play_timer -=1
            if auto_play_timer == 0 then
                
                if opp_id==liukang then
                    set_opp_anim(5)
                elseif opp_id==cage then
                    set_opp_anim(3)
                else
                    set_opp_anim(8)
                end

                hit = -3
                pl_card_offset = -7
                fatality=true
                blood(pl_x+8,stage_y+24,fire_width,nul,fire_amount)            
                phase = "animation"        
            end    
        elseif btnp(fire1) then
            --while #player_hand> 0 do del(player_hand,player_hand[1]) end
            
            if pl_id==liukang then 
                set_pl_anim(5)
            elseif pl_id==cage then
                set_pl_anim(3)            
            else
                set_pl_anim(8)
            end

            hit = 3
            pl_card_offset = -7
            fatality=true
            blood(opp_x+8,stage_y+24,fire_width,nul,fire_amount)            
            phase = "animation"
        end        

    elseif phase == "player" then
        
        auto_play_timer-=1   

        if #player_hand==0 then
        
            increase_wins()
            phase = "end" 
            sfx(4)
        
        elseif btnp(fire1) or auto_play_timer == 0 then
        
            sfx(4)
        --    if #player_hand>0 then 
                
                local pl_frm = player_hand[pl_selected_card]
                local opp_frm = opponent_hand[1]
                
                hit = dmg_table[pl_frm][opp_frm]
              
                set_pl_anim(pl_frm)
                set_opp_anim(opp_frm)            

                pl_card_offset = -7

                phase = "animation"
            --end
        elseif btnp(left) then 
            sfx(4)
            pl_selected_card-=1 if(pl_selected_card<1) pl_selected_card=#player_hand
        elseif btnp(right) then
            sfx(4)
            pl_selected_card+=1 if(pl_selected_card>#player_hand) pl_selected_card=1
        end
    end
    
end

function t_update()
    local w = 250
    ms_time = flr(time()*1000)
    if ms_time<w+125 then  t_col = black
    elseif ms_time<w+250 then t_col = dark_blue
    elseif ms_time<w+350 then t_col = dark_gray
    elseif ms_time<w+450 then t_col = light_gray
    elseif ms_time<w+550 then t_col = white
    elseif ms_time>w+1250 and title_dy< 64 then 
        title_dy+=8 if(title_dy>=64) sfx(3)
    elseif title_dy>=64 and btnp(fire1) then 
        sfx(4)
        music(0)
        _update = s_update _draw= s_draw
    end
end 

function t_draw()
    if title_dy==64 then 
        cls(red)
        rectfill(0,0,127,64,dark_purple)
        fillp(0xA5A5+0x0.8)
        rectfill(0,0,127,32,dark_gray)
        rectfill(0,64,127,96,dark_purple)
        fillp()
        
        print_s("#rndgamejam edition",256,5,white)

        if(ms_time%1000 < 500) print_s("press Ž to start ",256,117,green)
        for i=0,7 do draw_covered_card(-16+(i*18+ms_time\100)%143 ,55) end
    else 
        cls(black) end
    if title_dy==0 then
        print_s("tHErOBOz PRESENTS",256,61,t_col) 
    else
              
      draw_title()        
        
    end    
end    

function s_update()
    ms_time = flr(time()*1000)

    animate(pl_anim)

    if btnp(fire1) then
        sfx(4)
        srand(ms_time)

        del(heroes,heroes[pl_id])

        --todo: remove
        del(heroes,cage)

        del(heroes,heroes[n])
        n = flr(rnd(#heroes-1))+1
        del(heroes,heroes[n])

        _update = f_update
        _draw = f_draw

        new_stage()

    elseif btnp(left) then
        sfx(5)
        pl_id-=1 if(pl_id<1) pl_id=#heroes-1

    elseif btnp(right) then
        sfx(5)
        pl_id+=1 if(pl_id>#heroes-1) pl_id=1

    end
end

function s_draw()
    
    local x_pad=20
    local py = 26

    cls(dark_gray)

    --draw bg

    --grain
    for y=0,127,2 do
        srand(y)
        for x=0,127,2 do
            if(rnd(4)>3) pset(x,y,indigo)
            if(rnd(4)<1) pset(x,y,black)
        end
    end

    rectfill(3,py-5,125,py+29,dark_gray)
    rect(3,py-5,125,py+29,light_gray)
    rect(3,py-6,125,py+28,black)
    --

    print_s("choose your fighter",256,8,yellow)
    print_s(names[pl_id],256,98,yellow)

    for x= 0,5 do
        rectfill(x_pad*x+6,py,x_pad*x+16+6,py+24,port_colors[x+1])

        set_char(x+1)

        prx,pry = x_pad*x+6,py+9
        draw_torso(x+1,portrait[x+1],prx,pry,false)
        pal_default()
        if (x+1==raiden) draw_hat(portrait[x+1],prx,pry)        
        if (x==pl_id-1 and ms_time%500 < 250) rect(x_pad*x+5,py-1,x_pad*x+16+7,py+25,yellow)
    end

    x=56
    y=62
    draw_player(pl_id,x,y)
    if(ms_time%1000 < 500) print_s("press Ž to fight ",256,117,green)
end

function add_fx(x,y,die,dx,dy,grav,grow,shrink,r,col)
    local fx={
        x=x,
        y=y,
        t=0,
        die=die,
        dx=dx,
        dy=dy,
        grav=grav,
        grow=grow,
        shrink=shrink,
        r=r,
        c=0,
        col=col
    }
    add(effects,fx)
end

-- blood effect
function blood(x,y,w,c_table,num)
    for i=0, num do
        --settings
        add_fx(
            x+rnd(w)-w/2,  -- x
            y+rnd(w)-w/2,  -- y
            30+rnd(10),-- die
            rnd(w)-w/2, -- dx
            -5.5,       -- dy
            true,     -- gravity
            false,     -- grow
            true,      -- shrink
            2,         -- radius
            red    -- color_table
        )
    end
end

function update_fx()
    for fx in all(effects) do
        --lifetime
        fx.t+=1
        if fx.t>fx.die or fx.y > 127-17-15-fx.dy then
             del(effects,fx)
             if player_hlt==0 then
                blood(pl_x+8,stage_y+24,fire_width,nul,0)
            else                
                blood(opp_x+8,stage_y+24,fire_width,nul,0)
            end
        end
     
            fx.c=fx.col   

        --physics
        if fx.grav then fx.dy+=.5 end
        if fx.grow then fx.r+=.1 end
        if fx.shrink then fx.r-=.1 end

        --move
        fx.x+=fx.dx
        fx.y+=fx.dy
    end
end

function draw_fx()
    for fx in all(effects) do
        --draw pixel for size 1, draw circle for larger
        if fx.r<=1 then
            pset(fx.x,fx.y,fx.c)
        else
            circfill(fx.x,fx.y,fx.r,fx.c)
        end
    end
end
__gfx__
bbbbbb49994990bbbbbbbbb4994990bbbbbbbbbb2424904bb05524994bbbbbbbbbbb244222bbbbbbbbbbbbbbbbbbb0d5bbbbbbbbbbbbbbbb00224444bbbbbbbb
bb044994942440bbbbb04499442440bbbbbbbbb49994294bbb52059984449999bbb2424908bbbbbbbbbbbbbbbbbb0d550bbbbbbbbbbbbbbb02244444bbbbbbbb
b9949999992290bbbb994999942290bbbbb044944499240bbbb2408049944999bb49994294bbbbbbbbbbbbbbbbbb05000bbbbbbbbbbbbbbb02222444bbbbbbbb
94944494494290bbb9494449444290bbb2944944499920bbbbb4020299449442b944499240bbbbbbbbbbbbbbbbbbb2224bbbbbbbbbbbbbbb00000249bb4bbbbb
422222499994999994222224994449bb242922224999940bbb94400029492422924494920bbbb44bbbbbbbbbbbbbb022429bbbbbbbbbbbbbbbbbbbbbb92044bb
9940000499944449499400004994449b4420024002999494b9244442444900bb2444499949944494bbbbbbbbbbbbb452259999bbbbbbbbbbbbbbbbbb949922bb
4442992249944494444429922494444b240bb229402444994999994422224bbb2444444444444244bbbbbbbbbbb220284449994944bbbbbbbbbbbbbb94440bbb
444444402944420b004444440244444bb04444499402444244444994422220bb0242444442224b42bbbbbbbb42200002022442449440bbbbbbbbbbbb222249bb
0244992222440bbb4024499222240bbbbb0444994220040b4222244442222244249244222bbbbbbbbbb02222299200200229922249949bbbbbbbbbbbbbbbbbbb
494992422444bbbb449499242244bbbbbb920444222244bb02200224222202490994220200bb29bbbb0244944449200002999922494499bbbbbbbbbbbbbbbbbb
4004202222440bbb4400420222440bbbbb992444244444bb2200002222249999424990220992449bb024444422202202242499b02404490bbbbbbbbbbbbbbbbb
449444202244944b44494442022444bbbb494442222444299902000022444299024499429444444bb2444422000024222444440b0b00490bbbbbbbbb940bbbbb
4449200024424442044492000222444bbb02220024444449249422222224029404444444444424bbbb242200044004422424444944404924bbbbbbbb420bbbbb
0499442024002424b0499442020024bbbbbb02224422424492220b222224044022444444442bbbbbbbbb0002449402442222222440442444bbbbbbbb44220bbb
b404094029bb0492bb40409402bbbbbbbbbbbb0242200b0420224902224420bb0242242420bbbbbbbbbb0244242200224420bb2220002949bbbbbbbb94bbbbbb
bb808494090bb02bbbb80849400bbbbbbbbbb4e202200bbb0299402242220bbbb00202020bbbbbbbbbb0222222000222224bbbbbb20bb49bbbbbbbbbb020bbbb
bb880002009bbbbbb02224494022bbbbbbbbb4e8224004bbbbbbbbbbbbbbbbbbbbbbbbb449044bbbbbbbbbbbbbbbb900009bbbbbbbbbb04220490bbbbbbbbbbb
bb4802990009bbbbbb222200400bbbbbbbbbbb882290440bbbbbbbbbbbbbbbbbbbbbbbb444240bbbbbbbbbbbbbbb90000009bbbbbbbbbb2220440bbbbbbbbbbb
bb48022900940bbbbb409200000bbbbbbbbbbb822292444bbbbbbbbbbbbbbbbbbbbbbbb444244bbbbbbbbbbbbbb0490000940bbbbbbbbb2220440bbbbbbbbbbb
bbb4024900494bbbbb00244402220bbbbbbbbb8202400440bbbbbbbbbbbbbbbbbbbbbbb2442440bbbbbbbbbbbbb4940000494bbbbbbbbb0202440bbbbbbbbbbb
bbb02244000440bbbb80822400022bbbbbbbbb22024b0044bbbbbbbbbbbbbbbbbbbbbb02440044bbbbbbbbbbbb044000000440bbbbbbbb220244bbbbbbbbbbb2
bbb040490b0242bbbb08042220002bbbbbbbbb22020bb024bbbbbbbbbbbbbbbbbbbbb22224b024bbbbbbbbbbbb2420b00b0242bbbbbbbb022224bbbbbbbbbb04
bbb04494bbb042bbbbb8009044022bbbbbbbbb2222bb2224bbbbbbbbbbbbbbbbbbbb442244b224bbbbbbbbbbbb240bbbbbb042bbbbbbb0442244bbbbbbbbbb24
bb092444b04242bbbbb80020240220bbbbbbb04422b22220bbbbbbbbbbbbbbbbbbb65222220220bbbbbbbbbbbb24240bb04242bbbbbb0652222bbbbbbbbbbb02
b042224bb02242bbbbbb0b02040240bbbbbb422022002220bbbbbbbbbbbbbbbbbbb52522002220bbbbbbbbbbbb24220bb02242bbbbbb6525220bbbbbbbbbbbb0
b020240bbb2244bbbbbbb924424440bbbbb9200022b0402bbbbbbbbbbbbbbbbbbb605552b0002bbbbbbbbbbbbb4422bbbb2244bbbbb4605552bbbbbbbbbbbbb2
b6d020bbbb2494bbbb0692022206d0bbbb69200bbbb0620bbbbbbbbbbbbbbbbbbb44ddd0b0d20bbbbbbbbbbbbb4942bbbb2494bbbb9244ddd0bbbbbbbbbbbb24
b6dddbbbbb0dd6bb46662000b00d540bb06544bbbbb0650bbbbbbbbbbbbbbbbbbb244d6bb0d50bbbbbbbbbbbbb6dd0bbbb0dd6bbbbb0244d6bbbbbbbbbbbbb24
065dbbbbbb0d644b2d5522bbbb0054444d550bbbbbb0dd0bbbbbbbbbbbbbbbbbbb24449bb05d0bbbbbbbbbbbb446d0bbbb0d644bbbbb24444bbbbbbbbbbbbbb2
446bbbbbbb0d6444255bbbbbbbbbbb004d55bbbbbbb9d44bbbbbbbbbbbbbbbbbbb22449bb454dbbbbbbbbbbb4446d0bbbb0d6444bbbb22444bbbbbbbbbbbbbb0
4442bbbbbbbd0040422bbbbbbbbbbbbb00220bbbbbb20444bbbbbbbbbbbbbbbbbbb42440b20444bbbbbbbbbb0400dbbbbbbd0040bbb0242440bbbbbbbbbbbbbb
099490bbbbbbbbbbb2440bbbbbbbbbbbb24944bbbbbb2224bbbbbbbbbbbbbbbbbbbb24442bb224bbbbbbbbbb7777777777777777bbbbb224442bbbbbbbbbbbbb
bb500000000005bb50dd1d11d111dd0550dd111d11d1dd05ddddddddbbbbb777777bbbbbbbbbbbbbbbbbbdd666dbbbbbb676d5dbbb49abbbbbbbbbbbbbbbbbbb
b50000000000005b50dd111d11d1dd0550dd11d11d11dd055d5d55d5bbbb76666667bbbbbbbbbbbbbbb5d666676ddbbbb67655dbb49a9a9bbbbbbbbbbbbbbbbb
500dddddddddd00550dd11d11d11dd0550dd1d11d111dd05ddddd6d6bbbb6d6556d6bbbb55555555bb5d666676666dbbb676d5dbb4494bbbbbbbbbbbbbbbbbbb
50dddddddddddd0550dd11111111dd0550dd111d11d1dd0566666666bbb7667dd7667bbbd5d5d5d5b5d6d6d7676d66dbb7776d6b494dbcbbbbbbbbbbbbbbbbbb
50dd11111111dd0550dddddddddddd0550dd11d11d11dd0556d55dd5bbb6667777666bbbddddddddbdd66d5676d5666b6666ddddbbbdbbbbbbbbbbbbbbbbbbbb
50dd111d11d1dd05500dddddddddd00550dd1d11d111dd056666d666bb766666666667bbd5d5d5d55d6665665d5d666ddd5d5d56bbbbdbbbbbbbbbbbbbbbbbbb
50dd11d11d11dd05b50000000000005b50dd111d11d1dd05ddddd6d6bb66d6d6d6d666bb52525252d5d6d656d6d66766d6d6d6d6bbbbbbbbbbbbbbbbbbbbbbbb
50dd1d11d111dd05bb500000000005bb50dd11d11d11dd055656d565777777777777777725252525dd666d6d666d667666666666bbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbb8bbbbbbbbbbbbbfbbbbbbbbbbbbbbbbbbb6666d6666666666666666666b676d5dbd5d666d66766d66666666666bbb44bbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbdfdbbbbbfffbbbbbbb5dbbbbbbbbb666666666655555555555566b67655dbdd6dd66d6676666655555555b4999a9bbbbbbbbbbbbbbbbb
bbbbbbbbbbbb8bbb555fff55555efe55bbbb5dbbbbbbbbbbd6d6d66667dddddddddddd76b676d5db5ddd6d6666666d6ddddddddd494949a4bbbbbbbbbbbbbbbb
bbb8bbbbbbb8b88b55defed555dfffd5bbb56bbbbb6bbbbb5d5555d567d6d6d6d6d6d676b67655dbbd55d66d6d666ddbd6d6d6d6440cc404bbbbbbbbbbbbbbbb
bbbbbbbbbb888bbbdddfffdd5d66f649bbb6dbbbbbd5bbbb666666566766666666666676b676d5dbb5dd6d666676d6db66666666b40ee04bbbbbbbbbbbbbbbbb
bb8b8bbbbb8888b8dd76f649d7764999bb56dbbbbbb65bbb6d6d66666766666666666676b67655dbbb5dd66676666dbb66666666bbd00dbbbbbbbbbbbbbbbbbb
b88bbbbbbbbbbbbbd776499d7777499dbb6dbbbbbbb5dbbbddddd6dd6777777777777776b676d5dbbbb5ddd6666ddbbb77777777bbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbb7777494777774947b5d5bbbbbbbb55bb5555d5556666666666666666b67655dbbbbbb5dddddbbbbb66666666bbbbbbbbbbbbbbbbbbbbbbbb
00000000000000000000000000000000000000000000000000004444000000080000000000000008000044440000000a000000000000000000044440000000dc
000000000000000000000000000000000044440000000000000044ef000ff00800000444400ff008000044efe000000a000000000000000000044ef0000000cc
000000000000000000000000000000000044ef000000000000004eff05d9f00800000444e009f00800004eff9650000a00000000000000000004eff000000dc6
00000000000000000000000000000000004eff000000000000000eff5660000800000444e0d6600800000effd660000a00000000000000000000eff000000ccc
00044440000000000000444400000000000eff00000000080005dd6d66500000000000ef6d66500800005666d660000a00004444000000000005d6d000f00cc6
00044ef000000000000044ef0000000000566d650000900800566666500000000000056666500008000566666650000a000044efe0000000005666666ff0dc67
0004eff00000000000004eff000000000566666d5119f00800ff6665000000000000d666d50000080006ff665000000a00004eff9650000000d666d6dd9cc677
0000eff00000000000000eff0000000006ff66d5111fe00800f9d660000000000000d666d000000800069f560000000a00000effd660000000666ddd6ff0dc67
00016dd500000000000156d6dd6ff008069f55111110000000dd5d600000000000000d66d0000008000dd5d60000000000015666d660000a00d6d50000f00cc6
00d6666650000000005d66666669f0080051111100000000000111500000000000000151100000080000111500000000005d66666650000a0011150000000cc6
0666d6666500000000d6ff6650000008001151000000000000015150000000000000011110000008000015150000000000d6ff665000000a0015150000000dc6
fdd5666d6d00000000d69fd600000008001110000000000000015150000000000000015110000008000015150000000000d69fd60000000a00151500000000c6
ef1111155e00000800055115500000000051000000000000001101100000000000001151150000080001101100000000000551155000000a01101100000000cc
005111111500000800011111150000000011000000000000001500150000000000001100150000080001500150000000000111111500000a01500150000000c6
05112001115f00080f1115111100000000110000000000000010001100000000000011001100000800010001100000000f1115111100000a01000110000000cc
0551e000112ef0080e1151011ef0000000e900000000000000ef000ef00000000000ef00eef00008000ef000ef0000000e1151011ef0000a0ef000ef000000dc
bbbbbb0500bbbbbbbbb0500bbfeebbbbbbbb500bbbbbbbbbbbbb0500bbbbbbbbbcfbbbb5000bbbbbbbbbbbbbbbbb0bbb00bbbbbb00bbbbbbbbbbbb05bbbbbb05
bbbbbb5500bbbbbbbbb5000bbf55bbbbbbb05000bbbbbbbbbbbb55000bbbbbbbbcecbbb0ee0bbbbbbbbbbbbbbb0000bb00bbbbbb00bbbbbbbbbbbb55bbbbbb50
bbbbeb500eebbbbbbbb500ebbcfebbbbbbb05000bbbbbbbbbbbb500e0bbbbbbbccecbbb0ff0bbbbbbbbbbbbbbb4000bb0ebbbbbb0ebbbbbbbbbbbb50bbbbbb50
bbcccf00efebbbbbbbb00efebcebbbbbbbb050ebbbbbbbbbbbbb00eeebbbbbbbcecbbb50494bbbbbbbbbbbbbbb4000fbefebbbbbefbbbbbbbbbbbb00bbbbbb00
b1ccce50499bbbbbbbb004991ccbbbbbbb0550ebbbbbbbeebbbb50449bbbbbbbcc1bbb50490bbbbbbbbbbbbbaa40009b499bbbbb499bbbbbbbbbbb50bbbbbb50
311694004949bbbbbbaa339413cbbbbbbb9904909bbcc4cfbbb090490abbbbbb313aa940000bbbbbbbbbbbb0a0000bbb494bbbbb494bbbbbbbbb9400bbbb94e0
3110990004aaabbbb4a113111cbbbbbbb9a0044431cccccebbbaa900aa4bbbbbb119a9940000aabbbbbbbb0a90000bbb049bbbbb049bbbbbbbb49900bbb49ccf
100a994009aa9bbbb9a9101119bbbbbbbaa0413331cccbbbbb913940991ccccbbb0aa999000aaaabbbbbbbaaa4310bbb09a9bbbb09a9bbbbbb1a9940bbb1ccce
bb99a9900aaa4bbbb4a4400409bbbbbb49a0411331cbbbbbbb911390491ccecebbbaaa94000aaa9bbbbbbbaa99931bbb0aaabbbb0a9abbbbbb19a990bb311c94
bb49aa900aa99bbbb4a9400499bbbbbbeaa0944449bbbbbbbb113990094bbbecbbb99a94004aa10bbbbbb0aa999330bb0aa99bbb0aa99bbfbb19aa90bb131999
bbb49aa40a4440bbbb99940449bbbbbb49409aa994bbbbbbbb4104a9994bbbbbbbb09aa9009913bbbbbbbaaa999330bb0a444bbb0aa443ceb1149444bb114944
bbbb4aa909a413bbbb4a990449bbbbbb449099409bbbbbbbbbcc449aa90bbbbbbbbb4a99009903cbbbbbba90000130bb09a413bb09a431ceb33ccef4bbb40444
bbbb4a490a4011bbbbb4a4949abbbbbbe49490040bbbbbbbbccc0499a99bbbbbbbbbba444990bccbbbbbba00000431bb0a401cbf0a4111cbb11ccce4bbbb0049
bbbbb904999bbccbbbbb00499abbbbbbcc940004bbbbbbbbbcc00049aaabbbbbbbbbb4999944bcebbbbb0400009013bb999bcccf99901cbbbbccc444bbbbb004
bbbb4044990bbccbbbbb0099990bbbbbcc44004bbbbbbbbbeecb000499a0bbbbbbbbb0499aa0bccebbbb1400004913cf990bbceb990bbbbbbbbb4044bbbbb004
bbbb00099a0bbcfebbbb00099a0bbbbbe400044bbbbbbbbbffbb000009a0bbbbbbbbb4999944bbecbbb014000009c4ec9a0bbbbb9a0bbbbbbbbb0009bbbbb049
bbbb00099a00bbbbbbbb000094000bbbbbbbb0000494bbbbbbbbbbbbbbbbbbbbbbbbb00999900bbb990000000000bbccbbbbbbbbbbbbb0000004bbbbbbbbbbb5
bbbb00099a00bbbbbb000004990000bbbbbbbb000449bbbbbbbbbbbbbbbbbbbbbbbb000999900bbb9400000004494cccbbbbbbbbbbbbbb000000bbbbbbbbbbb0
bbbb00099a000bbbb00000099a00000bbbbbbb000049bbbbbbbbbbb44bbbbbbbbbbb000499900bbb9400000000444cccbb8bb8bbbbbbbb0000000bbbbbbbbbb0
bbb0000499000bbb000000049900000bbbbbb000004abbbbbbbbbbb00bbbbbbbbbbb000499900bbb99000000bbbbbbbbbbb88bbbbbbbbb00000000bbbbbbbb50
bbb0000494000bbb000000049900000bbbbbb0000094bbbbbbbb44994990bbbbbbbb0000b0000bbb4990bbbbbbbbbbbbbb8bb8bbbbbbbb00000000bbbbbbbb50
bbb0000bbb0000bbb000bbb4994b000bbbbbb0000040bbbbbbee0009990eebbbbbbb0000b0000bbbb449bbbbbbbbbbbbbbbbbbbbbbbbbbb000000bbbbbbb4940
bb0000bbbb0000bbb000bbb444bb002bbbbb00000000bbbbe4fe0009999effe0bbbb000bbb000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb02000bbbbbbb9a990
bb0000bbbbb000bbb200bbbbbbbb020bbbb00000bb00bbbb0ebbb004400bb4e4bbb0000bbb000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb002000bbbbbb0aaa90
bb0000bbbbb000bbb002bbbbbbbb00bbbbb0000bbb00bbbbbbbb0000000bbbbbbbb0000bbb000bbbbbbb0044400bbbbbbbbbbbbbbbbbbcc22000bbbbbb1a9a90
bb000bbbbbbb028bbbc2bbbbbbbbc2bbbbb022bbbb00bbbbbbbb00000000bbbbbbb020bbbb0002bbbb0000999000000bbbbbbbbbbbbbbc22b000bbbbbb1aaa90
bb022bbbbbbb028bbcccbbbbbbbbcccbbbc028bbbb088bbbbbbb00000000bbbbbbb082bbbbb088bbb0000099a00000000bbbbbbbbbbbbccbbb088bbbbb319a99
bb022bbbbbbb022bcccbbbbbbbbbbcccbcc28bbbbb082bbbbbbb880bb0880bbbbbb08bbbbbb028bb00000099a000000000bbbbbbbbbbbccbbb082bbbbc3049a9
bbcc8bbbbbbb02cbbbbbbbbbbbbbbbbbbc22bbbbbb082bbbbbbb280bbb0820bbbbb08bbbbbb028bb00000099900000550002bbbbbbbbbccbbb082bbbbccb0994
bbccbbbbbbbbbccbbbbbbbbbbbbbbbbbbccbbbbbbbc8bbbbbbbcccbbbbbccccbbbbc8bbbbbbb28bb0000004990bb000000c282bbbbbbbbbbbbc8bbbbbecb4499
bcccbbbbbbbbbcccbbbbbbbbbbbbbbbbbccbbbbbbbcccbbbbbbcccbbbbbcccbbbbcccbbbbbbbccbb0000004440bbbbbbb0cc22ccbbbbbbbbbbcccbbbbccb4aa9
bccbbbbbbbbbbbccbbbbbbbbbbbbbbbbbccbbbbbbbbcccbbbbbbccbbbbbcbbbbbcccbbbbbbbbcccbb02200bbbbbbbbbbbbbcccccbbbbbbbbbbbcccbbcebb0499
bbbbbb0000bbbbbbbbbbbbbbbbbb0feebbbbb000bbbbbbbbbbbbbb2bbbbbbbbbbbbbbb200bbbbbbbbbbbbbbbb2bbbbbb00bbbbbb00bbbbbbbbbbbb00bbbbbb00
bbbbbb0001bbbbbbbbbbb2000bbb00e4bbbbb800bbbbbbbbbbbbb0000bbbbbbbbbbbbb0840bbbbbbbbbbbbbb000bbbbb01bbbbbb01bbbbbbbbbbbb00bbbbbb00
bbbbb200ccbbbbbbbbbb280ccbbbc4ebbbbb2000cbbbbbbbbbbb20088bbbbbbbbbbbb0eee0bbbbbbbbbbbbb00800bbbbccbbbbbbccbbbbbbbbbbe200bbbbb200
bbbbbb85ffbbbbbbbbbbb00ff0befcbbbbbbb004fbbbbbbbbbb220eccbbbbbbbbbbbb8ccccbbbbbbbbbbbb2800ecbbbbffbbbbbbffbbbbbbbbbcef85bbbbbb85
bbbbbb11febbbbbbbbbbb0fef4fff0bbbbbbb110ebbb0cfebbbbb0fffbbbbbbbbbbbbb0ff0bbbbbbbbbbbbb000ffbbbbfebbbbbbfebbbbbbbffcce11bbbbbb11
bbbb0ffeef0bbbbbbbbbb244f4ff0bbbbbbef4ef00eeffcebbbbb14efbbbbbbbbbbbbb0eee4bbbbbbbbbbbee114bbbbbef0bbbbbef0bbbbbffe4effebbbb0ffe
bbbffffffff0bbbbbbbbb1effef0bbbbbbfffeeefffffebbbbbbb4144e4bbbbbbbb0ffe44feff0bbbbbbbefffffbbbbbfff0bbbbfff0bbbbffe0ffffbbbbefff
bb0ffefffffebbbbbbbbbffefebbbbbbb0fefe4ffeee0bbbbbbefe4eefe4effbbb0fffffefffefebbbbb0ffffef0bbbbfffebbbbfffebbbbe40ffeffbbbfffff
bb0ffeffeffebbbbbbbbbffeefbbbbbbbfeefefeffebbbbbbbbfefeffff44c4eb4ffeeffefff4effbbb0effffffffbbbeffebbbbeffebbbbbbbb4effbb0ffeff
bbfef4efefef0bbbbbbbbefeff0bbbbbffe0ffee4ebbbbbbbbeffefffefbbbe4fffee4fe4fefcffebbbffeffffeefb4eefef0bbbffff4bbbbbbbb4efbbefe4ff
bbffeeefffef0bbbbbbbb4f4ff4bbbbbfe0b0feee0bbbbbbbbfe04efffebbbbbee0fe4fffff0fcebbbb0eefffe44ffe4ffef0bbbffefebbfbbbbb4efbbff40ef
bbf4ee4cffeeebbbbbbbb0ffffebbbbbee4bbfeefbbbbbbbbbf4444efffbbbbbbecffefeffe4febbbbbbe4ffe444efceffeeebbbffeef0efbbbbb44ebfe4b44e
bbbb0fceefe4f0bbbbbbbbffef4bbbbbbc4bbfeefbbbbbbbbfe404effefbbbbbbbbee0feefe4ebbbbbbb04ff44000efcefe4c0bfef4efc4bbbbb04eecffb04ee
bbbb0d0e44bb4cbbbbbbbb0fef0bbbbbb0445d500bbbbbbbbce0b04efefbbbbbbbbbb04eef40bbbbbbbbb0e4ee0bb04044bb4eef440be4bbbbbb0d0e4cbb0d0e
bbbbd500000b0f0bbbbbbb0d0005bbbbbbe055000bbbbbbbec0bb004effbbbbbbbbbbd000000bbbbbbbbb0e400bbbb0b000bbf0b000bbbbbbbbbd500ffbbd500
bbbb5000000b4efbbbbbbb050000bbbbbb0ed5000bbbbbbbffbbb0d00000bbbbbbbbb5000000bbbbbbbbb5e000bbbbbb000bbbbb000bbbbbbbbb5000ebbb5000
bbbb0000000bbbbbbbb550000bbbbbbbbbbbbb500000bbbbbbbbbbbbbbbbbbbbbbbbb5000000bbbb000005522bbbbb67bbbbbbbbd00000000bbbbbbbbbbbbb00
bbbb00000000bbbbbb500000000bbbbbbbbbbb050000bbbbbbbbbbbbbbbbbbbbbbbbb0000000bbbb0000001313331677bbbbbbbb500000000132bbbbbbbbbb00
bbbb00000000bbbbb5000000000bbbbbbbbbbbb00000bbbbbbbbbbbbbbbbbbbbbbbb50000000bbbb000000133333175bbb8bb8bb0000000003333bbbbbbbb082
bbbb00000000bbbbb00000000112bbbbbbbbbb500000bbbbbbbbbbbbbbbbbbbbbbbb50000000bbbb0000005bbbbbbbbbbbb88bbb5000000021333bbbbbbbb2f4
bbbb000000000bbbb00000000132bbbbbbbbbb000000bbbbbbbbbbbbbbbbbbbbbbbb0000b0000bbbbbbbbbbbbbbbbbbbbb8bb8bb0000bbbbbbb11bbbbbbbb8ef
bbbb0000b0000bbbbb000000b1132bbbbbbbbb0000002bbbbbbbbbbbbbbbbbbbbbbb5000b0000bbbbbbbbbbbbbbbbbbbbbbbbbbb0000bbbbbb051bbbbbbbbb0e
bbb21000b0000bbbb5611010bb112bbbbbbbbb0000012bbbbbbbbbb044bbbbbbbbbb2000bb012bbbbbbbbbbbbbbbbbbbbbbbbbbb0000bbbbbb0605bbbbbbefe4
bb22111bbb3112bbb751311bbbb13bbbbbbbb21100132bbb44bbb4eeeee0bbbebbbb211bbb131bbbbbbbbbbbbbbbbbbbbbbbbbbb511bbbbbbbb077bbbbb0ffff
bb21131bbb3332bb060b11bbbbb1500bbbbb213100332bbb4cee4400004eeec4bbbb233bbb133bbbbbbb05500000bbbbbbbbbbbb233bbbbbbbbb77bbbbbfffff
bb2311bbbb1332bb050bbbbbbbb67677bbbb1331bb332bbbb444000000004440bbbb331bbb233bbbbb005500000002bbbbbbbbbb233bbbbbbbbbbbbbbb4fffef
b2131bbbbbb132bbbbbbbbbbbbbbbbbbbb1133bbbb131bbbbbbb000000000bbbbbbb33bbbbb33bbbb005000000001133bbbbbbbb233bbbbbbbbbbbbbb0ffefff
b213bbbbbbb113bbbbbbbbbbbbbbbbbbb1311bbbbb213bbbbbb23100001312bbbbbb31bbbbb33bbb000000000000133331bbbbbbb33bbbbbbbbbbbbbb4fe4ffe
b131bbbbbbbb11bbbbbbbbbbbbbbbbbb611bbbbbbbb11bbbbb21110bb01112bbbbbb11bbbbb11bbb00000000000013333311bbbbb33bbbbbbbbbbbbbbcebb0fe
b11bbbbbbbbb110bbbbbbbbbbbbbbbbb761bbbbbbb5150bb771111bbbb211167bbb55bbbbbbb1bbb0000000bbbbbb222133311bbb11bbbbbbbbbbbbbbfcbb0fe
b61bbbbbbbbb7570bbbbbbbbbbbbbbbb777bbbbbbb67776b06712bbbbbbb1170bb6770bbbbb077bb000000bbbbbbbbbbbb211567b60bbbbbbbbbbbbbffebbd00
777bbbbbbbbbb077bbbbbbbbbbbbbbbb577bbbbbbb055bbbb07bbbbbbbbbbb70bb670bbbbbbb677bbb0565bbbbbbbbbbbbb56776777bbbbbbbbbbbbbeebbb500
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5900000000000000000000000000005900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5900000000000000000000000000005900000000000000000000000000000000005900000000000000000000000059000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5900004a4b000000000000000000005900000000000000000000000000000000005900000000000000000000000059000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5900005a5b000000000000000000005900000000000000000000000000000000005900000000000000000000000059000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5900000000000000000000000000005900000000000000000000000000000000575c5800004748000047480000575c580000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5900000000000000000000000000005900000000000000000000000000000000495253525249494949494952535252490000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
59000000000000000000000000000059000000000000000000000000000000005c585c5c58464646464646575c5c575c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5900474800000000000000000000005949494949494949494949494949494949535253524949494949494952535352520000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4c49575849575849495758495758494c464646464646464646464646464646465c5c585c5c5846464646575c5c575c5c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4646464646464646464646464646464600590000005900000000590000005900464646464646464646464646464646460000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5656565656565656565656565656565655595454555955545555595554545955565656565656565656565656565656560000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a0b0c0d00888900008f890000c8c9000088000000cec90000af890000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a1b1c1d00989900009f990000d8d9000098000000ded90000bf990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
002b2c0000a8a90000a8a90000e8e90000a8a90000e8e90000a8a90000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
003b3c0000b8b90000b8b90000f8f90000b8b90000f8f90000b8b90000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
010100001160012600146101a630256502c650306502f6402f6402a640266401f6401a633136130c6000760000600006000160001600016000160001600016000160001600016000160001600006000060000600
000100000000000000000000120002400024220342204430044300444004440044400143300400014000140001400014000140002400024000020000200004000000000000000000000000000000000000000000
000100001160012600146101a630256502c650306502f6402f6402a640266401f6401a633136130c600076000060000600166501b6501f650216502e65034650356503265021650136500f650006000060000600
0002000000000006000f6102c6303b6403f6503f6503f6503f6503f6503f6503e6402363339600326001d60300000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000001000030010324253502b3502c3502c35025350103200032324100241002c1002d100271001d1000f1000f1000b1001e000180000000015100000000000000000000000000000000000000000000000
0001000000000000003c6243c6203b623000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012000000053002530005340000000530025300053400000001400253000534000000014002530005340000000530025400053002540005300254000534000000013002130001300213000130021300054400100
012000000013002130001340000000130021300013400000005300254000530025400053002540001340000000130021300013002130001300213000144000000053002540005300254000530025400054400000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010e00000f4400f445002000f4400f445004000f4400f445004000f4400f4450d4400040012440124450f44200400004000f4400f445004000f4400f445004000f4400f4450d440004000a4400a4451900017000
010e00000f4300f435004000f4300f435004000f4300f435004000f4300f4350d430004001243012430132311f233034051f2201f2201f225132311f233212212122221222212222122221225070000000000000
010e00000704007040070300704505040050400203002045070400704007030070450504005040020300204507040070400703007045050400504002030020450704007040070300704505040050400203002045
010e00001363013632136350000000000000000000000000000000000000000000000000000000136301363313630136321363500000000000000000000000000000000000000000000000000000000000000000
010e00000c420004000c420004000f420004000c42010400134200040011420114000f4200f400114200f4001142000400114200040014420004001142010400184200040011420114000f4200f4001143000000
000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000d00000404004043000000000000000000000000000000000000000000000000000000000000000000000000000040400404500000000000000000000000000000000000000000000000000000000000000000
010d00000404004043000000000000000000000000000000000000000000000000000000000000000000000004040040450000000000000000000000000000000000000000000000000000000000000000000000
010e00000064304005020050064300000000000064300000000000064300000000000064300000000000000000000000000000000000000000000007000070000700007005050400504002030020450000000000
010e00000064300000000000064300000000000064300000000000064300000000000064300000000000000000000000000000007040070400700007040050400504002000020050000000000000000000000000
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
00 0a 42 00 00
02 0b 42 43 44
00 15 12 43 44
01 18 10 19 44
00 17 11 19 44
00 41 12 13 44
00 41 12 13 44
00 14 12 13 44
02 14 12 13 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
