pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--a dream's command
--an rpg by jusiv

--all assets and code by
--henry stadolnik
--find me on twitter: @jusiv_

function init_ability()
 attack,spell,action = {"poke"},{"glimmer"},{"flee"}
end

function setup()
n1,title,title_menu,intro,intro_text,i_progress,battle = -1,true,{"new game"},false,{"every night","i have the same dream","","i'm adrift","in an empty void","","below me, an island","rises from the darkness","","it's the island","my village calls home","","","as it drifts closer,","i can hear a voice","","","","it comes from","everywhere","and nowhere","all at once","","","it speaks in a tongue","that nothing in this","world can utter","yet i can understand","it perfectly","","the voice calls my name","it beckons me","","","","it commands me to seek","the island's heart","","","","","no one in our village","has dared venture out","deeper than the forest","","the island remains a","wild, dangerous place","","besides, what the sea","does not provide, we","get from the mainland","","but i must go","","i cannot resist it","any longer","","the voice is calling me","i have to know why","","i have to journey","to the heart","of this island",""},0,0
zone,wait,b_wait,notice,mcguff,complete,rel_wait = n1,0,40,0,0,false,0
doors = {2,12.5,8.75,0, 3,4.5,12.75,0, 4,3.5,29.75,n1, 9,13.5,39.75,n1, 11,14.5,15.75,0, 12,2.5,39.75,n1, 13,9.5,16.75,0, 14,11.5,29.75,n1, 28,113.5,35.75,6, 44,68.5,4.75,1, 51,60.5,33.75,4, 60,51.5,14.75,3, 68,44.5,33.75,7, 74,86.5,6.75,5, 86,74.5,36.75,4, 100,120.5,25.75,6, 113,28.5,33.5,7, 120,100.5,8.75,5}
interact,talk,text = 0,{"game saved and health restored!","what!? you're venturing out?","these old legs would never dare","wander into that forest!","i've always thought of dreams","as ominous things. are you sure","you want to head out?","...zzzzzzzz...   ...no fish...","  ...been waiting all day...","        ...zzzzzzzzz...","oh no oh no what am i gonna do?","my boat drifted out of reach","and i don't wanna get wet...","enshrined here lies the","sealing stone, our world's","last hope in dire times.","if the evil imprisoned on","this isle breaks free, use","the stone to put it to rest.","you obtained:","the sealing stone","","[it's an eerie golden idol.","as you examine it, a booming,","familiar voice startles you.]","at long last, you have arrived!","i am known as mol'ojar, and i","was the voice in your dreams.","this place is the island's","heart which i commanded you","to seek.","now you, my puppet, shall earn","the honor of being the one to","free me of this prison!","[you feel unseen tendrils of","something enter your mind...]","","[against your will, you reach","out and touch the idol.","it crumbles away instantly!]","thanks to your efforts and the","power of the sealing stone,","the vile mol'ojar has once","again been sealed away in","eternal slumber.","","with any luck, you shall be the","last to fall prey to its","influence.","","thanks for playing!","","","you've subdued mol'ojar for the","moment, though you have a","nagging sense that the vile","thing won't stay down for long.","","you're not sure you could do it","again when it comes back.","","thanks for playing!","(want a better ending?","search the island!)","",""},{},{}

p_x,p_y,p_face,p_frame,p_hpmax,p_hp,level,xp,xp_next,status,diz,still = 1.75,30.75,3,0,16,16,1,0,5,0,false,0
-- -1=dead, 0=normal, 1=poison, 2=dizzy, 3=panic

e_id,e_name,e_hp,e_hpmax,e_xp,e_res_atk,e_res_spl = 1,{"","ballcrab","grumpsnail","hornmole","sunbloom","shroompuff","battlebug","lurkworm","zippermaw","ominous statue","watcher","boiling chorus","coiled blessing","mol'ojar"},1,{1,10,9,14,12,16,18,20,22,28,25,32,28,50},{0, 2,2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 0},{0, 0,2, 0, 0, 0, 4,n1, 3, 6,n1, 6, 1,10},{0,n1,0, 0, 2, 3,n1, 4, 1, 0, 7, 4, 8,12}

b_mode = n1 -- -2=start, -1=trans., 0=p. turn, 1=trans., 2=p. skill, 3=trans., 4=e. turn
p_hurt,e_hurt,e_skl,damage,heal,tab,sel,r_wait = 0,0,0,0,0,0,0,0

idle,lwr,tab_rot,tab_dir,tab_flip,s_lwr,b_back = 0,64,0,0,1,0,true

pop_list,pop_id,pop_wait,pop_wait2,pops_dmg,pops_heal,parts = {"miss...","ok!","solid!","great!","amazing!","epic!","escape failed...","escape succesful!","poisoned!","dizzied!","panicked!","victory!"},0,0,0,{},{},{}

init_ability()

s_id,s_list,s_var1,s_var2,s_var3,s_var4,src = 0,{},0,0,0,0,stat"102"

--check for save
if dget"8" == 1 then add(title_menu,"continue") end
end
-->8
--actors

function add_actors()
 actors = {}
 add_actor(1,2,29,112,false,48)
 add_actor(1,34,7,112,false,48)
 add_actor(1,52,14,112,false,48)
 add_actor(1,69,4,112,false,48)
 add_actor(1,85,6,112,false,48)
 add_actor(1,100,10,112,false,48)
 add_actor(1,29,33,112,false,48)
 add_actor(2,10,10.5,115,true,32)
 add_actor(3,8.4,19,116,false,32)
 add_actor(4,13,30.8,118,false,32)
 add_actor(5,13,41.8,120,true,32)
 add_actor(6,41,36,124,false,1)
 add_actor(7,47,36,124,false,1)
 --items
 if mcguff == 0 then 
  add_actor(8,44,38,123,false,1)
 end
 add_actor(9,28,37,122,false,1)
end


function add_actor(itype,x,y,sp,mir,fmax)
 a={itype = itype, -- 1=save, 2+=talk
   x = x,
   y = y,
   sp = sp,
   mir = mir,
   f = 0,
   fmax = fmax}
 
 add(actors,a)
end


function update_actor(a)
 a.f = (a.f+1)%a.fmax
 if a.itype == 8 and mcguff != 0 then del(actors,a) end
end


function check_prox(a,num)
 return abs(p_x-a.x-0.3) < num and abs(p_y-a.y-0.4) < num
end


function draw_actor(a)
 if (zone < 0 and check_prox(a,6) != true) or (a.itype == 9 and (interact >= 14 or battle == 2)) then
    return
 end
 local x,y,ff,m = 8*(a.x-p_x+8)-2,8*(a.y-p_y+8)-3,flr(a.f/16),false
 if a.mir then
    ff = 0
    if a.f > a.fmax/2 then m = true end
 end
 spr(a.sp+ff,x,y,1,1,m)
end


function draw_actor1(a)
 if a.y < p_y then draw_actor(a) end
end


function draw_actor2(a)
 if a.y >= p_y then draw_actor(a) end
end


function check_itype(a)
 if check_prox(a,1.2) then
    interact = a.itype
 end
end

-- < vfx functions >

function add_part(char,clr,x,y,dx,dy,ddx,ddy,tmax)
 pt={char = char,
    clr = clr,
    x = x,
    y = y,
    dx = dx,
    dy = dy,
    ddx = ddx,
    ddy = ddy,
    t = 0,
    tmax = tmax}
  
 add(parts,pt)
end


function move_part(pt)
 if pt.t > pt.tmax then
    del(parts,pt)
 end
 pt.x += pt.dx
 pt.y += pt.dy
 pt.dx += pt.ddx
 pt.dy += pt.ddy
 pt.t += 1
end


function draw_part(pt)
 print(pt.char,pt.x,pt.y,pt.clr)
end


function popup(id)
 pop_id,pop_wait = id,40
 if pop_id > #pop_list then pop_id = #pop_list end
 if id < 7 then snd(4+id)
 elseif id == 7 then snd(5)  --fail
 elseif id == 8 then --succeed
    music(n1)
    snd(10)
 elseif id == 12 then snd(12) --victory
 end
end


function popup_num(target,hurt,num)
 local pd_x,pd_y = 58,40
 if target == 0 then
    pd_x,pd_y = 80,80
    if not hurt then pd_x += 8 end
 end
 if hurt then
    add(pops_dmg,pd_x)
    add(pops_dmg,pd_y)
    add(pops_dmg,num)
 else
    add(pops_heal,pd_x)
    add(pops_heal,pd_y)
    add(pops_heal,num)
 end
 pop_wait2 = 20
end


function pops_clear()
 if #pops_dmg > 0 then
    for i=1,#pops_dmg do
       del(pops_dmg,pops_dmg[i])
    end
 end
 if #pops_heal > 0 then
    for i=1,#pops_heal do
       del(pops_heal,pops_heal[i])
    end
 end
end


function part_psn()
 for i=0,4 do
    add_part("†",3+8*ri2(),47+rnd"32",50+rnd"20",2,3,0,-0.05,10+rint(10))
 end
end


function part_psn2()
 for i=0,6 do
    add_part("†",3+8*ri2(),85+rnd"15",105+rnd"10",0,-2,0,0.1,10+rint(10))
 end
end


function part_diz()
 for i=0,5 do
    add_part("",12+ri2(),59+rnd"3",47+rnd"3",3,-0.7,-0.15,0.7,14)
 end
end


function part_diz2()
 local d = rnd"30"
 for i=0,2 do
    d += 10
    add_part("’",12+ri2(),87+rnd(6),102+rnd(6),cos(d/30),sin(d/30),0.1*cos(0.4+d/30),0.1*sin(0.4+d/30),10+rint(10))
 end
end

function part_pan()
 for i=0,3 do
    add_part("ˆ",8+6*ri2(),80+rnd"20",90+rnd"20",rnd"1",rnd"1",0,0,10+rint(10))
 end
end

function part_spl_player(num)
 local n = num*3+3
 for i=0,n do
    add_part("",9+3*ri2(),48+rnd"24",80+rnd"20",0,-5,0,-0.2,25)
 end
end

function part_bubble()
 for i=0,4 do
    add_part("†",6+7*ri2(),272-8*p_x+rnd"32",400-8*p_y,0,-0.5,0,-0.05,5+rint(7))
 end
end

function part_cure()
 for i=0,10 do
    local d = rnd"30"/30
    add_part("‡",7+7*ri2(),82+rnd"36",104+rnd"4",cos(d)/2,sin(d)/2,-0.02*cos(d),-0.02*sin(d),20+rint(10))
 end
end

-->8
--utility
function osc_sin(pos,mag,ofst)
 return pos+mag*sin(((idle+ofst)%50)/50)
end


function rint(num)
 return flr(rnd(num))
end

function ri2()
 return rint(2)
end


function snd(n)
 sfx(n,0)
end


function save_data()
 p_hp,status = p_hpmax,0
 dset(0,p_x)
 dset(1,p_y)
 dset(2,level)
 dset(3,xp)
 dset(4,xp_next)
 dset(5,p_hpmax)
 dset(6,mcguff)
 dset(7,zone)
 --create save
 dset(8,1)
end


function load_data()
 p_x,p_y,level,xp,xp_next,p_hpmax,mcguff,zone = dget"0",dget"1",dget"2",dget"3",dget"4",dget"5",dget"6",dget"7"
 init_ability()
 unlock_skills()
 p_hp,status,battle,lwr,rel_wait = p_hpmax,0,0,64,25
 zone_music()
end


function flag(x,y,flag)
 return fget(mget(flr(x),flr(y)),flag)
end


function toggleback()
 b_back = not b_back
end


function skip_intro()
 i_progress,still = 9,0
end
-->8
--main
function act()
 if rel_wait > 0 then
    return false
 else
    return btnp"4" or btnp"5"
 end
end

function p_move()
 local dx,dy,move = 0,0,true
 --get input
 if btn"2" or btn"3" then
    if btn"2" then
       dy -= 0.125
       p_face = 2
    else
       dy += 0.125
       p_face = 3
    end
 elseif btn"0" or btn"1" then
    if btn"0" then
       dx -= 0.125
       p_face = 0
    else
       dx += 0.125
       p_face = 1
    end
 else
    move = false
    p_frame = 0
 end
 --move
 if flag(p_x+dx,p_y+dy,0) then
    dx,dy = 0,0
 end
 if dx != 0 or dy != 0 then
    p_frame = (p_frame+0.25)%4
    p_x += dx
    p_y += dy
    --door
    if flag(p_x,p_y,7) then
       local x = flr(p_x)
       p_face,p_frame,notice,wait = 3,0,2,10
       for i=1,#doors/4 do
          local id = i*4
          if x == doors[id-3] then
             p_x,p_y,zone = doors[id-2],doors[id-1],doors[id]
          end
       end
       if zone > 0 then zone_music() end
    end
    --change zone
    local tile = mget(flr(p_x),flr(p_y))
    if zone > 0 and tile == 13 then
       zone = 0
       zone_music()
    elseif zone != 1 and (tile == 26 or tile == 42 or tile == 80) then
       if zone == 0 then
          zone = 1
          zone_music()
       else
          zone = 1
       end
    elseif zone != 2 and (tile == 24 or tile == 40) then
       zone = 2
    elseif zone != 3 and (tile == 94 or tile == 109) then
       zone = 3
    end
    --start battle
    if b_wait > 0 then b_wait -= 1
    elseif rint(60) == 0 then
       if flag(p_x,p_y,1) then
          b_start(false)
       end
    end
 end
 if move then
    if still > 736 then still -= 32
    else still = 0
    end
 elseif still < 800 then still += 8
 end
end


function zone_music()
 local m = 39
 if zone <= 0 then m = 31
 elseif zone <= 3 then m = 21
 elseif zone == 5 then m = 17
 end
 music(m,1500)
end


function game_over()
 p_hp,pop_id,status,wait = 0,0,n1,180
 snd(n1)
 music"0"
end


function unlock_skills()
 if level >= 2 and #action == 1 then add(action,"recover") end
 if level >= 3 and #attack == 1 then add(attack,"bonk") end
 if level >= 4 and #spell == 1 then add(spell,"spark") end
 if level >= 5 and #attack == 2 then add(attack,"bash") end
 if level >= 6 and #spell == 2 then add(spell,"shine") end
 if level >= 7 and #attack == 3 then add(attack,"crush") end
 if level >= 8 and #spell == 3 then add(spell,"radiance") end
end


function dialogue()
 text = {}
 for i=0,2 do
    add(text,talk[interact*3-4+i])
 end
 wait = 40
 snd(26)
end


-- < basic functions >

function _init()
 cartdata("jusiv_adc_v2")
 menuitem(2, "change backdrop", toggleback)
 setup()
 music"2"
end


function _update()
 if rel_wait > 0 then rel_wait -= 1 end
 idle = (idle+1)%200
 if complete then
    if act() then
       setup()
    end
    return
 end
 foreach(parts,move_part)
 --title screen
 if title then
    if wait > 0 then
       wait -= 1
    --change
    elseif btn(2) or btn(3) then
       sel = (sel+1)%#title_menu
       wait = 5
       snd(40)
    --select 
    elseif act() then
       snd(41)
       if sel == 1 then
          load_data()
          still = 700
       else
          intro,still,wait,mcguff = true,1,100,0
          music(27,1500)
          menuitem(1,"skip intro",skip_intro)
       end
       title,sel = false,0
       add_actors()
    end
    return
 end
 --intro
 if intro then
    if i_progress == 0 then
       still += 1
       if still >= 20 then
          i_progress,wait = 1,310
       end
    elseif i_progress >= 9 then
       still -= 0.25
       if still <= 0 then
          intro = false
          save_data()
          zone_music()
          menuitem(1)
       end
    else
       if act() and wait < 270 then
          wait = min(wait,30)
       end
       if wait <= 0 then
          i_progress += 1
          wait = 310
       elseif mid(wait,31,240) != wait then wait -= 1
       end
    end
    return
 end
 --game over
 if status < 0 then
    if status > -9 then status -= 0.1
    elseif wait <= 0 and (btn(4) or btn(5)) then
       load_data()
    end
 end
 --final sequence
 if interact >= 15 then
    still += 1
    part_bubble()
    if still >= 128 then
       b_start(true)
    end
 end
 --not in battle
 if battle == 0 then
    foreach(actors,update_actor)
    --show notif
    if notice > 0 then
       if notice == 1 and lwr > 0 then lwr -= 8 end
       if wait > 0 then
          if wait == 10 and notice == 2 then snd(25)
          elseif wait == 30 and notice == 1 then snd(24)
          end
          wait -= 1
       --close notif
       elseif act() or notice == 2 then
          if interact > 8 and interact <= 14 then
             interact += 1
             if interact <= 14 then dialogue()
             else
                notice = 0
                music"1"
             end
          else
             if interact == 8 then mcguff = 1 end
             notice = 0
          end
          still = 0
       end
       return
    end
    
    if lwr < 64 then lwr += 8 end
    if interact < 14 then
       p_move()
       --interact
       interact = 0
       foreach(actors,check_itype)
       if interact > 0 then
          if act() then
             if interact == 1 then
                save_data()
                text = {talk[1]}
                snd(27)
             else
                dialogue()
             end
             wait,notice = 30,3
          end
       end
    end
 --in battle
 else
    if pop_wait > 0 then pop_wait -= 1
    else pop_id = 0 end
    if pop_wait2 > 0 then pop_wait2 -= 1
    else pops_clear() end
    if battle == 4 and wait == 100 then
       popup(12)
    end
    if p_hurt > 0 then p_hurt -= 1 end
    if e_hurt > 0 then e_hurt -= 1 end
    if p_hp > 0 and (battle > 2 or battle == -0.5) then
       wait -= 1
       if s_lwr >= 0 then s_lwr -= 8 end
       if wait == 15 then
          if e_id > 13 then
             complete = true
             rel_wait = 150
             music"2"
          else battle = -0.5
          end
       elseif wait <= 0 then battle_end()
       end
    --if battle starting
    elseif b_mode == -2 then
       wait -= 1
       if wait <= 0 then
          parts,wait,b_mode = {},10,n1
       end
    --if changing to player turn
    elseif b_mode == n1 then
       lwr -= 8
       if lwr <= 0 then
          diz = false
          --resolve damage
          if damage > 0 then
             popup_num(0,true,damage)
             p_hp -= damage
             damage,p_hurt = 0,10
          end
          if heal > 0 then popup_num(1,false,heal) end
          e_hp += heal
          if e_hp > e_hpmax[e_id] then e_hp = e_hpmax[e_id] end
          --reduce cooldown
          if r_wait > 0 then r_wait -= 1 end
          --change phase
          heal,b_mode = 0,0
       end
    --if menu open
    elseif b_mode == 0 then
       if wait > 0 then
          wait -= 1
          if tab_dir != 0 then
   	         tab_rot += tab_dir
             if abs(tab_rot) >= 8 then 
                tab,tab_flip = (3+tab+tab_dir)%3,n1
                tab_dir *= n1
             end
          end
       else
          tab_dir,tab_rot,tab_flip = 0,0,1
          local len = 0
          if tab == 0 then len = #attack
          elseif tab == 1 then len = #spell
          elseif tab == 2 then len = #action end
          if p_hp > 0 then
             --change tab
             if btn"0" or btn"1" then
                if btn"0" then tab_dir = n1
                else tab_dir = 1 end
                sel = 0
                wait = 16
                snd(2)
             --change selection
             elseif btn"2" or btn"3" then
                if btn"2" then sel = (sel+len-1)%len
                else sel = (sel+1)%len end
                wait = 5
                snd(1)
             --select
             elseif act() then
                pick_skill()
                pops_clear()
             end
          end
       end
    --menu closing / skill
    elseif b_mode < 3 then
       if wait > 0 then wait -= 1 end
       if b_mode == 1 then
          lwr += 8
          s_lwr += 8
          if lwr >= 64 then b_mode = 2 end
       end   
       if s_id < 4 then skl_atk()
       elseif s_id < 8 then skl_spl()
       elseif s_id == 8 then skl_flee()
       elseif s_id == 9 then skl_rest()
       end
    --change to enemy turn
    elseif b_mode == 3 then
       if s_lwr > -8 then s_lwr -= 8
       else
          wait -= 1
          if wait == 30 then
             if s_id < 4  then snd(17)
             elseif s_id < 8 then snd(21)
             end
          elseif wait <= 0 then
             --resolve damage
             if status == 2 and rint(2) == 0 then
                damage = flr(damage/2)
                diz = true
                part_diz2()
                part_diz2()
                snd(22)
             end
             if s_id < 4 then damage -= e_res_atk[e_id]
             elseif s_id < 8 then damage -= e_res_spl[e_id]
             end
             if s_id < 8 then
                if damage < 0 then damage = 0 end
                popup_num(1,true,damage)
                if damage > 0 then
                   e_hp -= damage
                   if e_hp <= 0 then
                      e_hp = 0
                      if p_hp > 0 then
                         wait = 140
                         battle = 4
                         music(1)
                      end
                      e_hurt = 250
                   else e_hurt = 15
                   end
                   damage = 0
                end
             end
             if heal > 0 then popup_num(0,false,heal) end
             p_hp += heal
             if status == 1 then
                local newhp = flr(p_hp*0.75)
                popup_num(0,true,p_hp-newhp)
                p_hp,p_hurt = newhp,5
                part_psn2()
                snd(23)
             end
             if p_hp > p_hpmax then p_hp = p_hpmax end
             heal = 0
             --change phase
             if battle < 3 then
                wait,b_mode = 70,4
             end
          end
       end
    --enemy turn
    else
       enemy_turn()
    end
 end
 -- die
 if p_hp <= 0 and status >= 0 then
    game_over()
 end
end
-->8
--combat
function b_start(boss)
 if boss then
    e_id,battle = 14,2
 else
    e_id,battle = 2*zone+ri2(),1
 end
 snd(0)
 music(6,500)
 interact,e_hp,b_mode,wait,p_hurt,e_hurt,r_wait,pop_id,pop_wait,pops_dmg,pops_heal,pop_wait2,diz = 0,e_hpmax[e_id],-2,8,0,0,3,0,0,{},{},0,false
end


function pick_skill()
   s_id = sel+4*tab
   if (s_id == 8 and battle == 2) or (s_id == 9 and r_wait > 0) then
      snd(11)
   else
      s_list,s_var1,s_var2,s_var3,s_var4,b_mode = {},0,0,0,0,1
      snd(3)
   end
end


function skl_atk()
 local width = 4+2*s_id
 --initialize
 if b_mode == 1 then
    if s_var3 == 0 then
       for i=0,s_id+1 do add(s_list,width+8+rint(70-2*width)) end
       s_var3 = 1
    end
    return
 end
 --update
 if wait <= 0 then
    --panic status speeds up sliders
    s_var2 = (s_var2+s_id+flr(status/3)+2)%80
    --end
    if s_var3 > 1 then
       b_mode,damage,wait = 3,3*s_var1,60
       popup(1+flr(5*s_var1/(s_id+2)))
       return
    --get input
    elseif btnp(4) or btnp(5) then
       if abs(s_list[s_var1+1]-s_var2) <= width then
          wait,s_var2 = 10,0
          s_var1 += 1
          if s_var1 > s_id+1 then s_var3 = 3 end
          snd(4)
       else
          wait,s_var3 = 20,2
          snd(11)
       end
    end
 end
end


function draw_skl_atk()
 if s_var3 == 0 then return end
 --draw window
 local c = 6
 if status == 3 then c = 14 end
 box(21,127-s_lwr,106,143+8*#s_list-s_lwr,c,5)
 print("stop the sliders!",31+3*sin(idle/50),130-s_lwr,7)
 if idle%25 < 10 then color"6" end
 print("Ž",osc_sin(60,1.5,10),136+8*#s_list-s_lwr)
 --draw sliders
 local width = 4+2*s_id
 for i=0,#s_list-1 do
    if s_var3 == 3 then color(8+(i+flr(idle/5))%8)
    else color"13" end
    local yy = 8*i-s_lwr
    rect(24,138+yy,103,140+yy)
    if i < s_var1 then color"11"
    elseif s_var3 == 2 then color"8"
    else color"10" end
    rectfill(24+s_list[i+1]-width,137+8*i-s_lwr,24+s_list[i+1]+width,141+8*i-s_lwr)
    if s_var1 == i then line(24+s_var2,136+8*i-s_lwr,24+s_var2,142+8*i-s_lwr,7) end
 end
end


function skl_spl()
 --panic status speeds up timer
 local panic = 0
 if status == 3 then panic = 1 end
 --initialize
 if b_mode == 1 then
    if s_var4 == 0 then
       s_var1,s_var2,s_var3,s_var4 = ri2(),rint(5),160,1
    end
    return
 end
 --update
 if wait <= 0 then
    s_var3 -= 1+(s_id+panic-3)/2
    if s_var3 <= 0 then s_var4 = 3 end
    if s_var4 > 1 then
       s_var1,b_mode,wait = #s_list,3,60
       damage = (s_id-3)*s_var1
       popup(1+s_var1)
       return
    --get input
    elseif btnp(4) or btnp(0) then
       wait = 5
       if s_var1 == 0 then
          spl_rune()
       else
          s_var4 = 2
          snd(11)
          wait += 30
       end
    elseif btnp(5) or btnp(1) then
       wait = 5
       if s_var1 == 1 then
          spl_rune()
       else
          s_var4 = 2
          snd(11)
          wait += 30
       end
    end
 end
end


function spl_rune()
 add(s_list,s_var2)
 if #s_list >= 5 then
    s_var4,wait = 3,15
 end
 s_var1 = ri2()
 s_var2 = (s_var2+1+rint(4))%5
 snd(4)
end


function draw_skl_spl()
 if s_var4 == 0 then return end
 local scale = 28+4*cos(idle/25)
 local xpos = 0
 if s_var4 < 2 and wait > 0 then
    if btn"4" or btn"0" then
       xpos -= 8
       scale *= 0.8
    elseif btn"5" or btn"1" then
       xpos += 8
       scale *= 0.8
    end
 end
 --draw window
 local c = 6
 if status == 3 then c = 14 end
 box(21,127-s_lwr,106,177-s_lwr,c,5)
 print("match the color!",33+3*sin(idle/50),130-s_lwr,7)
 if s_var4 == 2 then color"2"
 else color"9" end
 local ofst = 3.5*cos(idle/50)
 circ(35+ofst,154-s_lwr,7)
 print("‹",32+ofst,152-s_lwr)
 if s_var4 == 2 then color"2"
 else color"12" end
 circ(93-ofst,154-s_lwr,7)
 print("‘",90-ofst,152-s_lwr)
 --draw timer
 rectfill(23,137-s_lwr,104,141-s_lwr,0)
 rectfill(24,138-s_lwr,24+s_var3/2,140-s_lwr,10)
 --draw rune
 if s_var4 == 2 then pal(7,8)
 elseif s_var4 == 3 then pal(7,8+(flr(idle/5))%8)
 else pal(7,9+3*s_var1) end
 sspr(8+8*s_var2,24,8,8,65+xpos-scale/2,155-s_lwr-scale/2,scale,scale)
 pal()
 --draw collected runes
 for i=1,#s_list do
    if s_var4 == 3 then pal(7,8+(flr(i+idle/5))%8) end
    spr(49+s_list[i],36+8*i,osc_sin(168-s_lwr,1.5,i*4))
    pal()
 end
end


function skl_flee()
 --initialize
 if b_mode == 1 then
    if s_var4 == 0 then
       s_list,s_var1,s_var3,s_var4 = {"‹","‘","”","ƒ"},1+rint(4),120,1
    end
    return
 end
 --update
 if wait <= 0 then
    --check if limit reached
    if s_var2 >= 12 and s_var4 < 2 then
       s_var4,wait = 3,10
       return
    end
    --update timer
    if s_var4 < 2 then
       s_var3 -= 1
       --panic status speeds up timer
       if status == 3 then s_var3 -= 0.5 end
    end
    if s_var3 <= 0 then s_var4 = 2 end
    if s_var4 == 2 then
       --fail
       b_mode = 3
       popup(7)
       return
    elseif s_var4 == 3 then
       --succeed
       b_mode,battle,e_id,wait = 3,3,1,50
       popup(8)
       return
    --get input
    else
       for i=0,5 do
          if btnp(i) then
             if s_var1 == i+1 then
                wait = 4
                if s_var2 < 12 then s_var2 += 1 end
                if rint(3) == 0 then s_var1 = 1+rint(4) end
                snd(14)
             else
                snd(15)
             end
          end
       end
    end
 end
end


function draw_skl_flee()
 if s_var4 == 0 then return end
 local xpos = 2*sin(idle/50)
 --draw window
 local c = 6
 if status == 3 then c = 14 end
 box(16,127-s_lwr,111,178-s_lwr,c,5)
 print("mash the button shown!",21+1.5*xpos,130-s_lwr,7)
 --draw timer
 rectfill(33,137-s_lwr,94,140-s_lwr,0)
 rectfill(34,138-s_lwr,34+s_var3/2,139-s_lwr,10)
 --draw meter
 rectfill(47,143-s_lwr,80,175-s_lwr,0)
 rectfill(48,174-s_var2*2.5-s_lwr,79,174-s_lwr,8+flr(s_var2/4))
 circfill(63,159-s_lwr+xpos,8,0)
 if wait > 0 and s_var4 < 2 then color(3)
 else color(5) end
 circfill(63,159-s_lwr+xpos,7)
 circ(63,159-s_lwr+xpos,7,6)
 rectfill(62,158-s_lwr+xpos,64,160-s_lwr+xpos,0)
 if s_var4 == 3 then color(8+flr(idle/5)%8)
 else color(7) end
 print(s_list[s_var1],60,157-s_lwr+2*sin(idle/50))
end


function skl_rest()
 if b_mode == 1 then
    if s_var4 == 0 then
       s_var2,s_var3,s_var4 = 1-2*ri2(),120,1
    end
    return
 end
 if wait <= 0 then
    if s_var3 > 0 then s_var3 -= 1
    else s_var4 = 2 end
    if s_var4 > 1 then
       b_mode = 3
       local res = flr(abs(s_var2)/5)
       if res < 5 then
          if res < 2 then
             status = 0
             part_cure()
          end
       else res = 5 end
       heal = flr(p_hpmax/(2*(res+1)))+1
       popup(6-res)
       r_wait = 3
       return
    else
       if s_var2 == 0 then s_var2 = 1-2*ri2() end
       if btn"4" or btn"0" then s_var2 -= 2 end
       if btn"5" or btn"1" then s_var2 += 2 end
       --panic status makes meter tilt faster
       if status == 3 then s_var2 += s_var2*0.12
       else s_var2 += s_var2*0.1 end
    end
    if abs(s_var2) >= 50 then
       if abs(s_var2) == s_var2 then s_var2 = 50
       else s_var2 = -50 end
       s_var4 = 2
    end
 end
end


function draw_skl_rest()
 if s_var4 == 0 then return end
 --draw window
 local c = 6
 if status == 3 then c = 14 end
 box(21,127-s_lwr,106,177-s_lwr,c,5)
 print("keep it balanced!",32+3*sin(idle/50),130-s_lwr,7)
 --draw timer
 rectfill(23,137-s_lwr,104,141-s_lwr,0)
 rectfill(24,138-s_lwr,24+s_var3/2,140-s_lwr,10)
 --draw meter
 circfill(63,162-s_lwr,14,13)
 rectfill(42,163-s_lwr,84,176-s_lwr,5)
 local res = flr(abs(s_var2)/5)
 if res > 5 then res = 5 end
 line(63,162-s_lwr,63-18*sin(s_var2/200),162-s_lwr-18*cos(s_var2/200),11-res)
 if idle%25 >= 10 then color(7)
 else color(6) end
 print("‹",36+3*cos(idle/50),167-s_lwr)
 print("‘",86-3*cos(idle/50),167-s_lwr)
end

function enemy_turn()
 if wait > 0 then
    local r1,r2,r3 = ri2(),rint(3),rint(4)
    if wait == 30 then
       --pick skill
       e_skl = 1
       if battle == 2 then
          if r2 == 0 then e_skl += r3 end
       elseif r3 == 0 then
          if e_id == 6 or e_id == 8 or e_id == 11 or e_id == 12 then
             e_skl = 2
          elseif e_id == 5 or e_id == 9 or e_id == 13 then
             e_skl = 3
          end
       elseif r2 == 0 then
          if e_id == 11 then e_skl = 3
          elseif e_id == 12 or e_id == 13 then e_skl = 4
          end
       end
       --play sound
       snd(16+e_skl)
    elseif wait == 10 then
       --enemy skill
       if e_skl == 1 then
          if e_id == 2 then
             damage = 2
          elseif e_id == 3 or e_id == 5 then
             damage = 1+r1
          elseif e_id == 4 or e_id == 6 then
             damage = 2+r1
          elseif e_id == 7 then
             damage = 3+r1
          elseif e_id == 8 or e_id == 11 then
             damage = 2+r2
          elseif e_id == 9 then
             damage = 4+r1
          elseif e_id == 10 then
             damage = 3+r2
          elseif e_id == 12 then
             damage = 4+r3
          elseif e_id == 13 then
             damage = rint(7)
          else damage = 2+rint(6)
          end
       else status_effect(e_skl-1)
       end
    end
    wait -= 1
 else 
    e_skl,b_mode = 0,-1
    return
 end
end


function status_effect(num)
 --poison, dizzy, or panic
 status = num
 popup(8+num)
end


function battle_end()
 if p_hp > 0 then
    zone_music()
    battle,b_wait,lwr,still = 0,60,64,300
    xp += e_xp[e_id]
    --level up
    if xp >= xp_next then
       level += 1
       xp -= xp_next
       xp_next = 1+flr(xp_next*1.5)
       p_hpmax += 2
       p_hp,status,notice,wait = p_hpmax,0,1,30
       unlock_skills()
    end
 end
end


function draw_atk(player,clr,y)
 if wait <= 30 then
    local ofst = 0
    if player then
       ofst = 24-y
       pal(8,clr)
    end
    if wait > 25 then
       sspr(48,8,8,8,59,63-ofst,24,24,false,player)
    elseif wait > 20 then
       sspr(56,8,8,8,59,63-ofst,24,24,false,player)
       sspr(48,8,8,8,37,63-ofst,24,24,true,player)
    elseif wait > 15 then
       sspr(48,8,8,8,59,63-ofst,24,24,false,player)
       sspr(56,8,8,8,37,63-ofst,24,24,true,player)
    elseif wait > 10 then
       sspr(48,8,8,8,37,63-ofst,24,24,true,player)
    end
    pal()
 end
end


function draw_spl(id)
 --id: 0-3=player, 4=poison, 5=dizzy, 6=panic
 if wait <= 0 then return
 elseif wait <= 30 and wait%5 == 0 then
    if id == 4 then part_psn()
    elseif id == 5 then
       if wait > 20 then part_diz()
       elseif wait <=16 then part_diz2() end
    elseif id == 6 then
       for i=0,2 do
          line(63,49+i,90,100+i,8+6*ri2())
       end
       if wait <= 18 then part_pan() end
    else part_spl_player(id)
    end
 end
end
-->8
--draw
function notify_level()
 local str = "level up!"
 local ofst = 1.5*lwr
 box(20,42-ofst,106,85-ofst,6,5)
 rect(19,41-ofst,107,86-ofst,7)
 for i=1,#str do
    print(sub(str,i,i),59-4*#str+i*8+2.5*cos(((50+i-idle)%50)/25),45-ofst,8+(flr((idle+2*i)/2))%6)
 end
 str = "you are now level "..level
 print(str,64-2*#str,53-ofst,7)
 str = "hp: "..(p_hpmax-2).." -> "..p_hpmax
 print(str,64-2*#str,61-ofst)
 if wait <= 0 then
    if idle%25 < 10 then color"6"
    else color"7" end
    print("Ž",osc_sin(60,1.5,10),77-ofst)
 end
 if level == 2 then str = "recover"
 elseif level == 3 then str = "bonk"
 elseif level == 4 then str = "spark"
 elseif level == 5 then str = "bash"
 elseif level == 6 then str = "shine"
 elseif level == 7 then str = "crush"
 elseif level == 8 then str = "radiance"
 else return end
 str = "new skill: "..str
 print(str,64-2*#str,69-ofst,12)
end


function show_stats(ypos)
 local yy = 73+ypos/2
 local xpos = osc_sin(yy,1.5,5)
 local sp = 48
 if battle == 0 then
    box(yy-5,87+ypos,128,128,6)
    rectfill(yy-4,88+ypos,128,ypos+120,5)
    if mcguff == 1 then
       spr(123,yy+40,105+ypos)
    end
 end
 if status > 0 then
    pal(7,10)
    if status == 1 then
       pal(8,3)
       pal(14,11)
    else sp = 36+status
    end
 end
 spr(sp,xpos,90+ypos)
 color(7)
 if p_hp <= p_hpmax/5 then pal(7,8) end
 print("hp: "..p_hp.."/"..p_hpmax,xpos+10,92+ypos)
 pal()
 print("level: "..level,osc_sin(yy,1.5,45),99+ypos)
 local nxp,exp = xp,e_xp[e_id]
 if battle == 4 and pop_id != 12 and wait < 100 then
    nxp += exp
 end
 print("xp: "..nxp.."/"..xp_next,osc_sin(yy,1.5,35),106+ypos)
 if pop_id == 12 then
    print("+"..exp,yy-12,106+ypos,10)
 end
end


function box(x1,y1,x2,y2,c1,c2)
 rectfill(x1,y1,x2,y2,c2)
 rect(x1,y1,x2,y2,c1)
end


function pressz(x,y,c1,c2)
 if flr(idle/50)%2 == 0 then
    rectfill(x+2,y,x+4,y+3,c2)
    print("Ž",x,y,c1)
 end
end


function draw_intro(xpos)
 for i=0,32 do
    local ii = 5*i
    local ofst = 136-xpos+4.5*sin((idle+10*i)/100)
    print("„",ofst-27,ii,12)
    rectfill(ofst-12,ii,128,ii+5)
    print("„",ofst,ii,13)
    rectfill(ofst+15,ii,128,ii+5)
 end
 ofst = 200-xpos
 local ofst2,r = 108,0
 if i_progress >= 9 then
    r += 48*cos((still-5)/60)
    if still < 10 then
       ofst,ofst2 = 63,63
       if still <= 5 then
          r = -13-61*sin(max(0,still/20))
       end
    else
       ofst,ofst2 = 53+still,63+46*(still-10)/10
    end
 end
 if still > 0 then r += 2.5*sin(idle/50) end
 circfill(ofst,ofst2,13+r,1)
 circfill(ofst,ofst2,10+r*0.6,0)
 spr(1,ofst-4,ofst2-4)
 if i_progress > 0 then
    color"7"
    if wait < 10 or wait > 300 then return
    elseif wait < 30 or wait > 280 then color(6) end
    for i=1,#intro_text do
       for i=1,8 do
          print(intro_text[i+(i_progress-1)*8],34,10*i)
       end
    end
    if mid(wait,31,240) == wait then
       print("Ž",119,121,6)
       pressz(119,120,7,13)
    end
 end
end


function fillscreen(trans)
 if trans == 1 then fillp(0b0101101001011010.1)
 elseif trans != 2 then fillp(0b0111110101111101.1)
 end
 rectfill(0,0,127,127)
 fillp()
end


function battleback()
 local ofst = 2.5*sin(idle/100)
 if b_back then
    if p_hp <= p_hpmax/5 then color"2"
    else color"1" end
    rectfill(-10,-10,137,137)
    for i=0,8 do
       for k=0,20 do
          circfill(20*i+idle/5-35+ofst,10*k-ofst,abs(13*cos(((idle/2+5*k+12.5*i)%50)/50)),0)
       end
    end
    for k=0,8 do
       for i=0,20 do
          circfill(10*i+ofst,20*k+idle/5-35-ofst,abs(10*cos(((idle/2+5*i+12.5*k+25)%50)/50)))
       end
    end
 else
    rectfill(-10,-10,137,137,0)
    if p_hp <= p_hpmax/10 then color"2"
    else color"1" end
    rectfill(5,5,122,122)
    rect(8,8,119,119,0)
    rectfill(12,12,115,115)
 end
end


function grayscale()
 pal(1,0)
 pal(8,13)
 pal(9,13)
 for i=2,4 do
    pal(i,5)
 end
 for i=10,15 do
    pal(i,6)
 end
end

function _draw()
 if not (src == 0 or src == "www.lexaloffle.com" or src == "v6p9d9t4.ssl.hwcdn.net") then
    rectfill(0,113,128,128,8)
    print("please play this game on\njusiv.itch.io/a-dreams-command",2,115,7)
    return
 end
 camera()
 pal()
 cls()
 if complete then
    local ii = 13*mcguff
    for i=54,66 do
       print(talk[i-ii],2,i*8-414,7)
    end
    if rel_wait <= 0 then
       print("Ž",60,122,6)
       pressz(60,121,7,0)
    end
    return
 end
 local ofst,str,xx,yy,xx2,yy2 = 0,"talk? Ž",still*8-32,0,0,0
 if title or intro then
    if i_progress < 9 then
       if still < 20 then
          battleback()
          print("a    ream's    ommand",22,30,7)
          print("a game by @jusiv_",31,122)
          circfill(35,32,5)
          circfill(75,32,5)
          print("d         c",34,30,1)
          color"7"
          for i=1,#title_menu do
             if sel+1 == i then print(">",44+cos((idle%25)/50),66+6*i) end
             ofst = flr(((idle-3*i+50)%50)/45)-1
             print(title_menu[i],50+ofst,66+6*i)
          end
       else xx = 128
       end
       if intro then draw_intro(xx) end
       return
    end
 end
 if battle < 1 or b_mode == -2 then
    --draw world
    pal(10,0)
    if zone >= 0 and zone < 4 then color(12)
    else color"0" end
    rectfill(0,0,128,128)
    xx = flr(p_x)-5
    yy = flr(p_y)-5
    xx2 = -8*(p_x-flr(p_x))
    yy2 = -8*(p_y-flr(p_y))
    if zone < 0 then
       map(xx,yy,xx2+22,yy2+25,11,11)
    else
       map(xx-3,yy-4,xx2-2,yy2-6,18,18)
    end
    pal()
    --draw actors
    foreach(actors,draw_actor1)
    local id,xflip = 1+flr(p_frame),false
    if still > 750 then
       if idle/100 >= 1 then id = 125
       else id = 1
       end
    elseif p_face == 2 then
       id += 4
    elseif p_face < 2 then
       id += 8
       if p_face == 0 then xflip = true end
    end
    spr(id,59,59,1,1,xflip)
    foreach(actors,draw_actor2)
    --draw final
    if interact >= 15 or battle == 2 then
       if mcguff == 1 and still >= 64 then
          local pos = osc_sin(49,1.5,0)+max(0,24-still/4)
          circ(62,pos+4,10+3*sin(still/8),3)
          spr(123,59,pos)
       end
       palt(7,true)
       sspr(96,96,32,still/4,275-8*p_x,401-8*p_y-still/4)
       palt()
    end
    --draw parts
    foreach(parts,draw_part)
    --draw popups
    ofst = flr(idle/25)%2
    if interact > 0 and interact <= 9 then
       if interact == 1 then str = "save? Ž"
       elseif interact >= 6 then str = "inspect? Ž"
       end
       local l = #str*4
       box(-1,119,9+l,128,6,5)
       print(str,1,122)
       pressz(l-3,121,7,5)
    end
    if notice == 3 and b_mode != -2 then
       box(-1,106,128,128,6,5)
       for i=1,#text do
          print(text[i],2,103+6*i,7)
       end
       if wait <= 0 then
          print("Ž",120,122,6)
          pressz(120,121,7,5)
       end
    elseif notice == 1 or lwr < 64 then notify_level()
    elseif notice == 0 and still >= 700 then show_stats(214-still/4)
    end
    --draw battle trans
    if b_mode == -2 then
       local scl = 8*wait
       rectfill(scl,scl,128-scl,128-scl,0)
    end
    --draw intro closing
    if intro then
       draw_intro(still*8-32)
    end
 end
 --if in battle
 if battle > 0 and b_mode > -2 then
    --screenshake
    if p_hurt >= 0 then
       p_hurt -= 1
       camera(rnd(2)-1,rnd(2)-1)
    end
    battleback()
    --draw enemy
    if e_id > 1 then
       xx,yy = 47,24+sin(idle/50)*2*e_hp/e_hpmax[e_id]
       if e_hurt > 0 then
          e_hurt -= 1
          xx += rnd(4)-2
          yy += rnd(4)-2
       end
       --if attacking
       if e_skl > 0 then yy += 5 end
       --if dead
       if e_hp <= 0 then
          grayscale()
          color(8)
       else color(7) end
       if e_id > 13 then
          sspr(96,96,32,32,xx-16,yy-8,64,64)
       else
          sspr(16*((e_id-2)%6),96+16*flr(e_id/8),16,16,xx,yy,32,32)
       end
       pal()
       str = "hp: "..e_hp.."/"..e_hpmax[e_id]
       print(str,osc_sin(64-#str*2,2,10),9)
       str = e_name[e_id]
       print(str,osc_sin(64-#str*2,2,35),2,7)
    end
    --draw enemy skill
    if e_skl == 1 then draw_atk(false,8,0)
    elseif e_skl > 1 then draw_spl(e_skl+2)
    end
    --draw player skill
    if b_mode == 3 and battle < 3 then
       if s_id < 4 then
          if s_id > 2 then draw_atk(true,4,6) end
          if s_id > 1 then draw_atk(true,9,4) end
          if s_id > 0 then draw_atk(true,15,2) end
          draw_atk(true,10,0)
       elseif s_id < 8 then draw_spl(s_id-4)
       end
    end
    --draw particles
    foreach(parts,draw_part)
    --draw player stats
    show_stats(lwr/4)
    --draw menu
    if b_mode < 2 then
       ofst = 0
       if abs(tab_rot) > 2 then ofst = abs(tab_rot)-2 end
       box(7,92+lwr,65-6*ofst,126-4*ofst+lwr,6,5)
       for i=0,2 do
          local ang = (2-i)/3+tab_flip*tab_rot/48
          local scale = 10+6*cos(ang)
          if i == 2 then pal(6,7) end
          sspr(16*((tab+i+1)%3),8,16,16,17-scale/2+10*sin(ang),osc_sin(81+lwr,2,4*i)+3*cos(ang),scale,scale)
       end
       pal()
       color"7"
       if tab_dir == 0 then
          xx = osc_sin(29,2.5,35)
          if tab == 0 then
             print("attacks",xx,95+lwr)
             for i=1,#attack do
                if sel+1 == i then print(">",10+cos((idle%25)/50),96+6*i+lwr) end
                ofst = flr(((idle-3*i+50)%50)/45)-1
                print(attack[i],16+ofst,96+6*i+lwr)
             end
          elseif tab == 1 then
             print("spells",xx,95+lwr)
             for i=1,#spell do
                if sel+1 == i then print(">",10+cos((idle%25)/50),96+6*i+lwr) end
                ofst = flr(((idle-3*i+50)%50)/45)-1
                print(spell[i],16+ofst,96+6*i+lwr)
             end
          else
             str = ""
             print("actions",xx,95+lwr)
             for i=1,#action do
                if sel+1 == i then print(">",10+cos((idle%25)/50),96+6*i+lwr,7) end
                ofst = flr(((idle-3*i+50)%50)/45)-1
                color"13"
                str = ""
                if i == 1 and battle == 2 then
                   ofst = -1
                   str = "can't "
                elseif i != 2 or r_wait <= 0 then
                   color"7"
                end
                print(str..action[i],16+ofst,96+6*i+lwr)
             end
             if r_wait > 0 and #action >= 2 then
                --draw cooldown
                str = "wait "..r_wait.." turn"
                if r_wait > 1 then str = str.."s" end
                print(str,9,114+lwr,6)
                print("to use recover",9,120)
             end
          end
       end
    end
    --draw minigames
    if b_mode > 0 and b_mode < 4 then
       if s_id < 4 then draw_skl_atk()
       elseif s_id < 8 then draw_skl_spl()
       elseif s_id == 8 then draw_skl_flee()
       elseif s_id == 9 then draw_skl_rest()
       end
    end
    --draw popups
    local c = 0
    if pop_wait > 0 then
       if pop_id > 0 then
          local p = pop_list[pop_id]
          if pop_id > 8 and pop_id < 12 then c -= 4
          elseif pop_id == 12 then c = 1 end
          for i=0,2 do
             if pop_wait > 2*i and pop_wait <= 50-2*i then
                print(p,64-#p*2,67-i+2*sin(idle/25),8+i+c)
             end
          end
       end
    end
    if pop_wait2 > 0 then
       local x,y,n = 0,0,""
       c = 8
       if #pops_dmg > 2 then
          for i=1,flr(#pops_dmg/3) do
             x,y,n = pops_dmg[i*3-2],pops_dmg[i*3-1]+pop_wait2/10,"-"..pops_dmg[i*3]
             --change color if dizzy
             if diz and x < 70 then c = 13 end
             box(x-2,y-2,x+4*#n,y+6,6,c)
             print(n,x,y,c-1)
          end
       end
       if #pops_heal > 2 then
          for i=1,flr(#pops_heal/3) do
             x,y,n = pops_heal[i*3-2],pops_heal[i*3-1]+pop_wait2/10,"+"..pops_heal[i*3]
             box(x-2,y-2,x+4*#n,y+6,6,11)
             print(n,x,y,7)
          end
       end
    else
       pops_clear()
    end
 end
 --draw game over
 if status < 0 then
    color"2"
    if status > -4 then
       fillscreen(0)
    elseif status > -8 then
       fillscreen(1)
    else
       fillscreen(2)
       print("you have perished",31,61,8)
       if status <= -9 and wait <= 0 then
          print("Ž",61,102)
          pressz(61,101,14,2)
       end
    end
 --draw end transition
 elseif battle > 2 or abs(battle) == 0.5 then
    if battle > 0 then color"6"
    else color"5" end
    if wait <= 25 then
       if wait > 20 then fillscreen(0)
       elseif wait > 15 then fillscreen(1)
       elseif wait > 10 then fillscreen(2)
       elseif wait > 5 then fillscreen(1)
       else fillscreen(0)
       end
    end
 end
 --print(interact.." "..battle,1,1,7)
end
__gfx__
00000000009999000099990000999900009999000099990000999900009999000099990000999900009999000099990000999900c94cc94cd555555dcd9944dc
0000000009ff999909ff999909ff999909ff999999999990999999909999999099999990099999000999990009999900099999009445944599444444d944445d
007007000fcffcf00fcffcf00fcffcf00fcffcf0099999900999999009999990099999900999fc000999fc000999fc000999fc004445444544444444444ff445
000770000ffffff00ffffff00ffffff00ffffff00f9999f00f9999f00f9999f00f9999f0099fff00099fff00099fff00099fff0044454445d444444d44ffff45
000770000dffffd00dffffd00dffffd00dffffd00dffffd00dffffd00dffffd00dffffd000d6d00000d6d00000d6d00000d6d00044454445d555555d44ffff45
00700700d0dddd0d06dddd10d0dddd0d01dddd60d0dddd0d01dddd60d0dddd0d06dddd1000d6d00000dd600000d6d000006dd1004ff54ff599444444544ff445
000000000011110006111110001111000111116000111100001111600011110006111110001110000011100000111000001110005ff55ff54444444455444455
000000000010010000000d000010010000d000000010010000d000000010010000000d00000d000000d01000000d00000010d000d55dd55dd444444d55555555
066666666666666006666666666666600666666666666660000000000000000033333333b3b3333b7f7fffffccccccccccccccccccccccccd555555dcddccddc
664444444444446666dddddddddddd666633333333333366000000000000000033b33333fb7bb3bff77fffffcccccc4cccc5ccccccccccccdd5555ddcccccccc
64488888888884466ddccccccccccdd6633bbbbbbbbbb3360000000800000008333b3333ff77fbffff77ffffcccccc44ccc155cccccccccccddddddccccccccc
64887777777888466dccc777777cccd663bbbbb77bbbbb36000000800000008833333333f7f7fffff7f7ffffcccccc44c55555515cccccccccddddcccccccccc
64878888878878466dcc77ccccc7ccd663bb77b77b77bb360000088000008880b3333333ff7f7fffff7f7fffccccc54555551515151ccccccccccccccccccccc
64888777788778466dc77cc7777cccd663bb77777777bb36000088000088880033333b33fff7777ffff7777fcccc5515515551515151cccccccccccccccccccc
64887887887778466dc77c777777ccd663bbb777777bbb3600888000888880003333bb33ffff7f77ffff7f77cc5555555111111511111ccccccccccccccccccc
64888888877788466dc77c7777777cd663b7777bb7777b3688800000888000003333333377fffff777fffff7c5551511115444111111111ccccccccccccccccc
64888878777888466dc77c7777777cd663b7777bb7777b3600aaaa000000a0a0333333337f7ffffbc947ffffccc44c155441144441c44ccccccccd4411dccccc
64888877878888466dc77cc777c77cd663bbb777777bbb360acccca00aaadada333333b3f77fffb394457fffcccc4454441221444544cccccccccd5511dccccc
64888887788888466dc777cccc777cd663bb77777777bb36acaaaacaa999d9da33333333ff77ffb344457fffccccc44941222214544ccccccccccd5dd1dccccc
64888878778888466dcc77777777ccd663bb77b77b77bb36aca5daa0a9ceeca033333333f7f7fb3344457fffcccccc94412aa21545cccccccccccd5dd1dccccc
64888788888888466dccc777777cccd663bbbbb77bbbbb36aca5ada0a9deeda033b33333ff7f7bb344457fffcccccd99412aa21451dcccccccccccdccdcccccc
64488888888884466ddccccccccccdd6633bbbbbbbbbb336acaaada0a9e889a03b3b3333fff777b34ff5777fcccccd944122291555dccccccccccccccccccccc
664444444444446666dddddddddddd6666333333333333660acdda000ae289a033b3333bffff7f7b5ff57f77cccccd994122221451dccccccccccccccccccccc
06666666666666600666666666666660066666666666666000aaa00000aaaa003333333377fffffbd557fff7cccccd945122221551dccccccccccccccccccccc
077707700000000000000000000000000000000000000000ccccccccccccccccbb33b33b33333b3b7f7fffffc77fffff7f7fffffccccccccccccc4cccccccccc
7eee7ee70777777000007770070000700777077007000770cc55555555555cccfbbb333333bb33bff77fffffcc7fffffc77fffffcc777cc7cccc447ccccccccc
7e888e870000007000007070070070700707007007770070c4445555f55544ccff77b3b3333b3bbfff77ffffccc7ffffcc77ffffc777f77fccc44c7ccccccccc
78e888870070707000007770077770700000077007777070cc444444ff4444ccf7f7fb33b3333bfff7f7ffffccc7ffffcccc77ffc7f7ffffcc44cc7ccccccccc
7e8888870070700007770000000000700770000007077770ccd444444f444dccff7f7fb333b3bfffff777fffcc7f7fffcccccc7f7f7f7fffc49ccc7ccccccccc
078888700070700007070000000700700700707007007770cccdddddddfddcccfff777b33bfbb77ff7ccc77fcc77777fcccccc7f7ff7777f459fcd7dcccccccc
007887000770700007770000000777700770777007700070ccccccccccddccccffff7f7bbbff7f777cccccc7cc7f7f77ccccccc77fff7f77cc5cccdccccccccc
000770000000000000000000000000000000000000000000cccccccccccccccc77fffffbb7fffff7ccccccccc7fffff7ccccccc7c7fffff7cc5ccccccccccccc
7f7fffff7ccccccc7f7ffff77f7ffffb66666666666666666666666d000011d66d10100000000000000000000dddddd033333333335353333333333355575555
f77dddfff7ccc7c7f77fff7cf77ffbb36ddd666dd66dd66dd666dddd000101d66d1100000000000000000000dd6666dd33bbbb33335555b33336333b55777555
ffd666dff77c7f7fff77ff7cff77fb3366ddddddddddddddddddddd5000011d66d1010000000000000000000d665566d3b4444b333355d33336d363355776755
f7d6d6dff7f7fffff7f7f7ccf7fbb3336ddddddddd66dddddddddd55000101d66d1100000001010101010000d655556d3345554b33555333366dd6d355767d55
fd5d66dfff7f7fffff7f77ccffb3b33b6ddddddddddddddddd55ddd5000011d66d1010000000101010101000d650056d335aa543b3555533b6d666d355766d55
fd5dddfffff7777fff77ccccffb333336d66ddddddddddddddddddd5000101d66d1100000001011111110000d650056d345aa543335d533b36666dd355766d55
ffff7f77ffff7f7777ccccccfb333b336ddddddddddddd66ddddddd5000011d66d101000000011dddd101000d650056d345aa54433355533336dddd355766d55
77fffff777fffff7ccccccccb3b333336ddddddddddddddddddddd55000101d66d110000000101d66d11000066500566445aa544335533333333333355766d55
7f7fffff7f7fffffccc777ccbf7fffff66dddddddd6666ddddd55dd56666666600000000000011d66d101000333334333333333b3333b3333333333355766d55
f7733ffff77fffffcc7fff7c3b7fffff6dddd66dd611115ddddddd55dddddddd00000000000101dddd110000993343b3b39433333333333333b3833355766d55
ff33333fff77ffff7777fff73b77ffff66dddddd61111115ddddddd5111111110000000000001111111010003493434433344333535553553833f33355766d55
f737fffff7f7fffff7f7fff73bf7ffff6ddddddd611aa115ddddddd5010101010101010100010101010100003349445333334345d555555388e3333b55766d55
f33f733fff7f7fffff7f7f7cb3bf7fff6ddddddd611aa115dddddd551010101010101010000010101010100033394533994344533555d555e8833e8355766d55
fff7337ffffb7b7ffff7777c33b7777f66dd66dd611aa115d55ddd55000000001111111100000000000000003339453b33444453555335353f33388356766dd5
fff33f77fbb3b3b7ffff7f7c3bff7f776ddddddd611aa115ddddddd500000000dddddddd00000000000000003b39455533394533333333b3333b3f33566666d5
77fffff7b333333b77fffff7bffffff76ddddddd611aa115dddddd550000000066666666000000000000000033394553333945b33b333333333333335566dd55
15111151505550557f7ffff7bf7fffffdddddddd44244424442244446666666666666666000011d66d1010003339453333394533333353335557655555555555
1515515155000555f77ffff73b7fffffddddd66d2444444444444244ddddddd66ddddddd000101d66d110000339445333b394533333535b35557d555ddd5ddd5
1511115150555055ff77ff7c3b77ffffdddddddd4422424424444444111111d66d111111000011d66d101000b394453333944533b35555335576d65555555555
5155551505555500f7f7f7cc33b7ffffdd66dddd4422442244244444010101d66d110101010101d66d110101339445b33394453335d5555555776655dd5dddd5
1511115150555055ff7f77ccb3bf7fffdddddddd4444442244442244101011d66d101010101011d66d1010103b944533339445b3555555535556d55555555555
1515515155000555fff7777c333bb77fdddddddd4244244442442242000101d66d110000111111d66d111111b944445b3b94445b3355d5355557d5555ddd5ddd
1511115150555055ffff7f7c3333bb77ddd66ddd4442444424444444000011d66d101000ddddddd66ddddddd3b4b45b3b94b4b5b333553335567d65555555555
515555150555550077fffff73b3333bbdddddddd4244424444444424000101d66d110000666666666666666633b3bb333bb3b3b33b35353355666655ddddd5d5
000000000000000000000000006ff60000555500005555000eeee00000eeee00002222005666666500900900000000000077770000999900d955555dd555559d
0007a00000077000000a7000066ff660095ff55005ff5550effffe000eeeffe002ff2f2066666666000aa0000000000007556570099999904494444446774944
0077a70000a77a00007a77000f1ff1f059f3ff300f3ff3f0f55f55000efffff00ffcffc06666666609a44a90000a30000766667009ff9999449feeeeee67f944
0aaaa770077aa770077aaaa00ffffff05ffffff00ffffff0ffffff000f55f5500ffffff0d666666d009aa90000ab3300075556700f55f550d494fffeefff494d
077aaaa0077aa7700aaaa770066f66605effffe00effffe08ffff80008ffff800bffffb0dddddddd0099990000ab3300076666700dffffd0d59555ffff55595d
007a770000a77a000077a700026666200eeeee200eeeeee088884800888848800bb333b0dddddddd000990000abbb330075655700dddddd04494444444444944
000a7000000770000007a000001111200ed6d6200e6d6de04882240048822400006666b01dddddd10a0990a00bbbb33007666670001111004444444444444444
0000000000000000000000000010010000d6d600006d6d00020020000200020000600600511111150949949000bb33000077770000100100d444444dd444444d
9575757575a50000000074e7f78675a5000000000000000000009485b485a400000000000000000000009485b485a400000000000000000000009485b485a400
9485858585858585a400000000000000000000000000000000000000000000000000000000000000000000000000004464464464000074060606a69606060684
00000000000000000000957575a50000000000000000000000947416161684a40000000000000000000074161616840000000000000000000000745666568494
9666665666565666840000000000000000000000000000000000000000000000000000000000000000000000000000454454646500007406e106060606e10684
000000000000000000000000000000000000000000000000009496161616a6a40000000000000000948596161616a685a400000000000000000095765686a574
66565686766666568400000000000000000000000000000000000000000000000000000000000000000000000000944545556565a40074060606867606060684
0000000000000000000000000000000000000000000000009474161616161684a400000000000000741616161616161684000000000000009485859656849496
668675a574666686a594b4a400000000000000000000000000000000000000000000000000000000000000000000740606060606840095760686a595757575a5
00000000000000000000000000000000000000000000000094961616161616a6a40000000000000074971616e116169784000000000000007456666666847466
66a6a494965686a5949666a6a40000000000000000000000000000000000000000000000000000000000000000949606e106e106a6a4949606a6a40000000000
0094b485a40000000000000000000000000000000000000074161616971616168400000000000000741616161616161684000000000000007466566686a57456
566684745666a685965666668400000000000000000000000000000000000000000000000000000000000000007406060606060606a696060606840000000000
9496f0e0a6a400000000009485b485a400000000000000007416161616161616840000000000000074e1e1169716e1e1840000000000000074665656a6859666
5686a57466565666566656668400000000000000000000000000000000000000000000000000000000000000007406e106e106e106060606e106840000000000
74e0e0e0e084000000000074e0f0e0a6a400000000000000741616e1e1e1161684000000000000009575761616168675a5000000000000009576666656665656
668400957575765666568675a5000000000000000000000000000000000000000000000000000000000000000074060606060606068676060606840000000000
74e0f2e2e084000000009496e0e0e0e0840000000000000074e1e1f3f3f3e1e18400000000000000000074e1e1e1840000000000000000000095757575757575
75a50000000095757575a5000000000000000000000000000000000000000000000000000000000000000000009575757575757575a595757575a50000000000
74e06373e0840000000074f3e2e0e7f7840000000000000074f3f3f3f3f3f3f38400000000000000000095757575a50000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
74e0e0e7f784000000007473f3e08675a5000000000000009576f3f3f3f3f386a500000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9575757575a50000000095757575a50000000000000000009574f3f3f3f3f384a500000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000009576f3f3f386a50000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000009595757575a5a50000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000009500a500000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000007770007777077770000000000000000000000000000000000000000077777770000000000000000000000000000000000000
00077770777700000000000000777670007dd707dd70000000077770777700000000077777700000077775575570000000000000000000000000000000000000
0007d5707d5700000000000007766d70007d7777d777000000779977799770000007778888777000776775775770000000000000000777777777000000000000
0007557075570000000000007766d570007dd544dd5770000079ff999ff97700007788e888887700766782dd8277000000000000077744444447770000000000
000774777477000000000007766d577000777444455577000779faaeaaf99770077888888e888700766722dd2217770000000000774444444444477000000000
00077488847700000000077766dd570000074a4455a55700079f9ea888eaf9700788ee888888e7007f777dddd511d77000000007744422dd2dd4447700000000
07778888888770000000776666d55700000749a449a55700079faa8448aaf9700788ee88e882270075f776565ef11d770000007744dd25665662444700000000
77ee8888888470000077766d6dd557000007444ee5555700079fae888aeaf97007888888822277007477719eeee91dd700000074426655655565244770777000
7eeee88888427000077666d6dd557700007774622655770007799aaeaaa997700778822224777000744755f9999f55d700000074255655111555524270727000
78e8e88888427770776dddddd555700007745155555177700079fff9aff977000077794449970000774551effffe15d700777774255551111156524277727000
778824884422ee7776d555555d5570000745551111112470007799939997700000007799999700000747719eeee915d707722774255561111166524277227000
07774444222eeee77d8822288555700007656521111452700007733333570000000007f1c1970000074771f9999f1dd7072222749256611611dd242272227000
00774222224e8e877d898289855770000777424422455570000078bb8b370000000077f1119770000774715ffff51d7707227774492dd5166122422272277000
00784217124488777752222215117700000722422256567000007bbbbb37000000007fff99947000007477511115d770072277744499222dd2442a2272227770
007872777278777007751111111117000007772227227770000073777757000000007f97774470000077775777757700072227774a444999444aaa2777222277
007777707777000000777777777777000000077777777000000077700777000000007777077770000000077700777000072222274aaa444444aaa22707722227
0000000000000000000000000000000000077777000000000007770007770000007777700000000000000000077770000772222272aaa2444422227700777227
00007777777000000007777777000000000767d777000000007767707767700007794477000000000777777007dd700000772222242224444442277077772227
00777fffff7770000007ee7e97700000000766666700000000766d77766d770007888447000000000711227777277770077777222744444444aa277774772277
077fffffffff77000077e8e88977000000077768677000000076dddddddd57700786284700777770072772722117dd70779994722c4aa4444aa2777442722270
77ffffffff9f9770007e28929e970000000007d666777000077dd999edd55570077885477779447707dd7ddd7777727079444442d2c2aa244222774427722770
7dffffffd9f99970007e9999e897000000007755d678700007dd9aaa9e5d5570007775547994845777777dadd22112707447444d2dd422444422774277c2dc77
7cd9ff9dc79999700076d6d928977000000076655d87700007de9a1a9ee55570077999444988685772d7dd22dd7777777747742cddcd44444422cc427cdd2cc7
779ffff97779997000796d6d999e7000000076d58887000007dd9aaa9e55557007948445486228577177d222ad7211270777742cccd4444442222c2222cddcc7
07792297779494700077444499ee7700000076558987000007ddd999e555557007986855558885577122da2ddd22772700074227cdd4444422222dc2222ccc77
00777777444947700007754999eee7000000766aa8870000077dd5dd5d55577007482685994555777777dddd27777dd70007227cccd244222222d2dc22277770
000077242444770000775599997e97000000775557770000007d52d52552270007448859984457700712272727d77777007722cccddd2222222dddccc2277000
0007722242777000007554499ee79700000007d757000000007722222222770007745594868855700717772711277770007c2d2cdcd2d2d2d2d2dcdc2d2c7000
0007222777700000007574447ee77700000077d757700000000772722272700000774548226285700727d7177777dd70007cd2dccdcddd2dcdddcdcdd2dc7000
00072277000000000077774579e77000000776666d77000000007772727270000774454488885577072dd71712277d70007ccdcdccccdcdcdcccccccddcc7000
000772270000000000007557779970000007666d65d7000000000077727770000744455445555557077777111722dd700077ccccc77ccccccc77777cccc77000
00007777000000000000777707777000000777777777000000000000777000000777777777777777000007777777777000077777777777777770007777770000
__gff__
0000000000000000000000000000000000000000000000000202020101010101000000000000000002020001800101010000000000000101020202020202010101020202010101010101018080020101020202020180010101010101010202010200020201020201010101010102010200000000000000000001000000000101
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f444545463f3f3f3f3f3f3f3f3f3f3f3f3f3f3f44463f3f0000000000000000000000000044454600000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3e3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3d4141414141523f3d41523f3f44463f3f3f3f3f3f3f3f3f444664563f3f3f3f3f3f3f3f3f3f3f3f3f3f4455563f3f0000000000004545460000000054645600000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f0d0f0d0d0d0f0d3f3e3f3f3f3f3f3f3f3f3d4141414141501a1a1a1a1a40411a501a4141545641523f3f3f3f3f3d415456645641523f3d4141523f3f3f3f3f3f3d544556523f0000000000006464564545454554645645454545454545454545454545454545454546000000000000000000000000000000000000000000
3f3f1f1e1f1f1f0e36370e3f3f3f3f3f3d41411a1a1a1a1a1a1a51511a1a4051511a1a1a1a1a54561a1a41523f3f3d1a43545664561a50411a1a1a1a523f3f3f3f3f44545556463f0000000000006464566464646454645664646464444545466464646464646464644445450000000000000000000000000000000000000000
3f3f3f3f3f3f0d0f0d0d0f0d3f3f3f3f3b1a1a401a51515151432828631a295c1863515151511a1a1a511a1a523f3b294454566456511a1a1a1a1a1a4041523f3f3f3c1a1a1a423f0000000000006464566464646454645664646464546464566464646464646464645464640000000000000000000000000000000000000000
0f3f3f3f3f3f1f1e1f1f1e1f3f3f3f3d1a1a515143281828182818184e63436c4e5b5c4e18286351435b631a1a411a43545456645646635151511a1a1a1a623f3f3f3f3c0e423f3f0000000000006464566464646454555664646464546464566464644445466464645464640000000000000000000000000000000000000000
1e3f3f3f3f3f3f3f3f3f3f1b1c1d3f3b1a2928182818281818182828184e5b5e5e6b6c5b285b18285e6b5e635151434e54545664565618181818631a1a50423f3f3f3f3f0e3f3f000000000000006464566f6f6f6e6f6f6f6e6f6f6f546464566f4f6e5464566e4f6f5464640000000000000000000000000000000000000000
3f3f36373f3f3f3e3f3f3f2b2c2d3f3c3a1a193828282818284e281818186c5b6d5d6d6b5c6b5b5e5e5c5e185e5e5e5e5e5e5c4e5e18184e181818631a623f3f3d523f3f0e3f3f000000000000004545466f44466f6e6f6e6f44466f546464566e5f5f5455565f5f6e5464640000000000000000000000000000000000000000
3f3f3f0f0d0d0f0d3f3f3e2e0e2f3f3f3f3b1a1a382818181818284e1818186b4d5b5c4e6c4e6c5e4e6c5e5e5e5c5e44465e6c5b18444628181818391a1a414150623f3f0e3f3f00000000000000646456795456794f6f4f79545679546464566f6f6f6f6f6f6f6f6f5464640000000000000000000000000000000000000000
3f3f3f1e1f1f0e36370d0f3f0e3f3e3f3f3b1a1a1a193818182818285b28185e4d6c6b5e5e5c5e5e5e5e44465e6c5b54565e5e6b4e545628281818531a1a1a1a1a623f3f0e3f3f000000000000006464566f4f6f6f5f6f5f6f6f4f6f54444545466f6f6e6f6e6f6f444545450000000000000000000000000000000000000000
3f3f3f1b1c1d0e3f3f1f0e3f0e0d0d3f3f3b1a1a1a1a2918181818186c5e6d5d6d6d4e5c5e6b4e5c4e5e546445466b54565e5e5e5e54565e28181863511a1a1a1a423f3f0e3f3f000000000000006464566f5f6f6f6f6f6f6f6f5f6f6f54646456796f6f6f6f6f79546464640000000000000000000000000000000000000000
3f36372b2c2d0f0d0d0d0f0d0f1f1f3f3f3c1a1a1a1a1a1938182818184e5e5e5c4d5e6b4e6d5c6c5e5e444564564546565e4e5c5e5e18281818184e28531a1a423f3f3f0e3f3f000000000000006464566f6f6f6f6e6f6e6f6f6f6f6f546464566f6f6e6f6e6f6f546464640000000000000000000000000000000000000000
3f3f0f2e0e2f0e1f36371e1f0e3f3f3f3f3f3b1a1a1a1a1a2918281818284e5b6c4d5b5e6d6d6b5b5e44466464444656564e5b6b5c4e5e181818185e18531a423f3f3f3f0e3f3f000000000000004545466f6f6f6f6f6f6f6f6f6f6f44454664566f6f6f6f6f6f6f546464640000000000000000000000000000000000000000
3f3f1e3f0f0d0f3f3f3f3f3f0e1b1c1d3f3f3b1a501a1a1a291818281828186c5e4d6b4e4d5c4e6b5e54566444544546565e6b4c6c5e4e5c18182818391a623f3f3f3f3d0e523f000000000000006464566e6f6e6f6f6f6f6f6e6f6e54645664566f6f4f6f4f6f6f546464640000000000000000000000000000000000000000
3f3f3f3f1e1f1e3f1b1c1d3f0e2b2c2d3f3f3c1a1a1a1a401a381818281828185c6d5d5d6d6c6d5d6d5d5d6d5e5464566d5d5d6d6d5e4e6b5b4e1828631a623f3f3f3f3c1a623f000000000000006464565f6f6f6f6f796f6f6f6f5f54645664566f6f5f4f5f6f6f546464640000000000000000000000000000000000000000
3f3f3f3f3f3f3f3f2b2c2d3f0e2e0e2f3e3f3f3b1a1a1a1a1a291818182828186c4e5b5c6d5d6d4e5b5e5c4d5e5e6d5d6d4e5e5e5e4e18186c4e4e185e531a523f3f3f3d1a623f000000000000006464566f6f6e6f6f6f6f6f6e6f6f54645664566f6f6f5f6f6f6f544445450000000000000000000000000000000000000000
3f3f3f3f3f3f3f3e2e0e2f3f0f0d0f0d0d0d0d2a1a1a1a1a1a1a19381818282828286c6b5b5e6d5c6b4e6b6d5d5d6d5c4e284e4e4e1818281828284e4e63511a4141411a3a423f000000000000006464566f6f6f6f6f6f6f6f6f6f6f6f6e4f6e4f6e6f6f6f6f6f6f6f5464640000000000000000000000000000000000000000
36373f3f3f3f0d0f0d0f3f3f0e1f1e1f1f1f1f3c3a3a1a1a1a1a1a1a382818181818184e6c5c4e6c18184e4e5e5c5b6b182839191938181818181818284e5c531a3a3a423f3f3f000000000000004545466f4f6f6f6e6f6e6f6f4f6f6f6f5f6f5f6f6f6f6f6f6f6f6f5464640000000000000000000000000000000000000000
0f36373f3f3f1f0e1f1e36370e3f3f3f3f3f3f3f3f3f3b1a1a1a1a1a1a38181818181828186b1839191919384e6c6b3919191a1a1a1a19191938181818286b53623f3f3f3f3f3f000000000000006464566f5f6f6f6f6f6f6f6f5f6f6f6f6f6e6f6f6f6f6e6f6f6f6f5464640000000000000000000000000000000000000000
1e3f3f3f3f3f3f0f0d0d0d0d0f3f3f3f3f3f3f3f3f3d1a501a1a1a1a1a291828282818183919191a1a1a1a291839191a1a1a1a1a1a1a1a1a1a29181828183940423f0000000000000000000000006464566f6f6f6f6f6f6f6f6f6f6f6f4f6f5f6f4f6f6f6f6f6f44454545450000000000000000000000000000000000000000
3f3f3f3f3f3f3f1e1f1f1f1f1e3f3f3f3f0f3f3f3f3b401a1a1a3a3a1a1a1919381839191a1a3a3a1a1a1a1a191a1a1a1a501a3a3a3a3a3a1a1a191938391a423f3f000000000000000000000000644445466f6f6f6f6f6f6f6f6f6f6f5f6f6f6f5f6f6f6f6f6f54646464640000000000000000000000000000000000000000
00000000000000000000000000000000001e3f3f3f3c3a3a3a423f3f3b501a1a1a191a1a3a423f3d1a1a1a1a1a3a401a1a1a423f3f3f3f3f3b1a1a1a1a1a1a41523f0000000000000000000000006454645645454545454545454545454545454545454545454554646464640000000000000000000000000000000000000000
00000000000000000000000000000000000000003f3f3f3f3f3f3f3f3c3a3a3a3a3a3a423f3f3f3c3a3a3a3a423f3c3a3a423f3f3f3f3f3f3c3a3a3a3a3a3a3a423f0000000000000000000000006454645664646464646464646464646464646464646464646454646464640000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f0000000000000000000000006454645664646464646464646464646464646464646464646454646464640000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006454645664646464646464646464646464646464646464646454646464640000000000000000000000494b4a000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000476048000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004969606a4a495858584a
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000476060606a6960606048
4958584b584a00000000494b58584a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000047601e606060601e6048
470e0e0f0e4800000000470f0e0e6a4a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000047606060686760606048
470e0e0e0e4800000000470e2f3f3e48000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000595757575a596760685a
477e7f0e0e4800000000470e0e0e0f48000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000444546000000495858584a4969606a4a
__sfx__
000900001305121551265612b5712f5702f5602f7402f7322f7202f7122f7002f7022f7002f7022f7002f7021c000227001d700197002370023700207000000016700227001d7001970023700237002070000000
000a000018564185551e700197002370023704207050000016700227001f700197002370023704207050000016700227001e700197002370023704207050000016700227001d7001970023700237042070500000
000a00001461414615147641475523700257042270500000177002270020700197001c70025704227051570017700227001f700197002370025704227050000017700227001d7001970023700257042270500000
000c00001f56022555227052270523700257000e6000e6030e6000e6001f700386031c70025700227000e6030e6000e6001e700197000e6030e6030e6000e6030e6000e6001d700386032370025700227000e603
000a00000e613175501a53016500125060f1051c5000c1040f1050c1040c1040f1051c5000c1040d1051e0001c5000c1040f1051c5000c1040f1051c5000c1040f1050c1040c1040f1051110411104111051e000
000c00000e6110e6130b5620b552065620655206552065050f1050c1040c1040f1051c5000c1040d1051e0001c5000c1040f1051c5000c1040f1051c5000c1040f1050c1040c1040f1051110411104111051e000
000c0000125401a550205502355023540235351c5000c1040a1050c1040c1040a1051c5000c1040d1051e0001c5000c1040a1051c5000c1040a1051c5000c1040a1050c1040c1040a105111040a1040a1051e000
000c0000125401b550225502555027540275351c5000c1040a1050c1040c1040a1051c5000c1040d1051e0001c5000c1040a1051c5000c1040a1051c5000c1040a1050c1040c1040a105111040a1040a1051e000
000c0000125401b550235502755029540295351c5000c1040a1050c1040c1040a1051c5000c1040d1051e0001c5000c1040a1051c5000c1040a1051c5000c1040a1050c1040c1040a105111040a1040a1051e000
000c0000155401d54022550255502870027550295602955029545295050c1040a1051c5000c1040d1051e0001c5000c1040a1051c5000c1040a1051c5000c1040a1050c1040c1040a105111040a1040a1051e000
000c0000155401d5402255025550165501f54024540285502b5002b5502b5402b5352b5000c1000d1001e0001c5001850022500205002550029500285002950029500295002950029500111000a1000a1001e000
000a00000e6130c5600954016500125060f1051c5000c1040f1050c1040c1040f1051c5000c1040d1051e0001c5000c1040f1051c5000c1040f1051c5000c1040f1050c1040c1040f1051110411104111051e000
000c00001e0342104124051270512705027052270452700527060270602506025060290602906024060240601e031210412405127051270502705227055270002706027060250602506027060290602506025060
001200000d5500d5540d5551150011550115541155515500155501555415555197000d5000c5500c5540c5551150010550105541055515500145501455414555177000d552095520655205552055520555205555
000600000a6131254414500270002700027002270052700027000270002500025000290002900024000240001e000210002400027000270002700227005270002700027000250002500027000290002500025000
00060000086130654004554270002700027002270052700027000270002500025000290002900024000240001e000210002400027000270002700227005270002700027000250002500027000290002500025000
000400000661306612066150660305613056120561506605086130861208615066030761307612076150660504613046120461506603036130361203615066050a6130a6120a6150660308613086120861506605
000a000022653276512d651326502c653266552360222600226001260012600190002300023004200050000016000220001e000190002300023004200050000016000220001d0001900023000230042000500000
000c00000a054127710c05414771070540e771090541177106051220001f000190002300023004200050000016000220001e000190002300023004200050000016000220001d0001900023000230042000500000
0007000016051190511d0512005122051210511e0511b05118051180512f55433555305043055434555335052f554335552f504105030e5030e5030e5000e5030e5000e5001d500385032350025500225000e503
000a000010430144401a45021450134301944420455284501b4301e440254502d4501a40025404224051540017400224001f400194002340025404224050040017400224001d4001940023400254042240500400
000c0000140501805021750217551d5561f5561c556205561d5501c5550c7000e7051c7000c7040d7051e7001c7000c7000e7051c7000c7000e7051c7000c7040e7050c7040c7000e7051170410704107051e700
00060000186541c6531d0511c0511805114051127551275011750220001f000190002300023004200050000016000220001e000190002300023004200050000016000220001d0001900023000230042000500000
000a00000a05412771070540e7710905411771060511170006000220001f000190002300023004200050000016000220001e000190002300023004200050000016000220001d0001900023000230042000500000
000e0000167641a5601c555187641f560215651b7541a5501d5502656021560265602655026740267350050016500225001e500195002350023500205000050016500225001d5001950023500235002050000500
000800001e614216231e61421623216150a7051c7000c7000a7050c7040c7000a7051c7000c7040d7051e7001c7000c7000a7051c7000c7000a7051c7000c7000a7050c7040c7000a705117040a7040a7051e700
000800001c114021051d1141c1041c1141c1051d1141d1140e1000e1001f100381031c10025100221000e1030e1000e1001e100191000e1030e1030e1000e1030e1000e1001d100381032310025100221000e103
000f0000237512375123550285502a555265002a5000000016700227001f700197002370023700207000000016700227001e700197002370023700207000000016700227001d7001970023700237002070000000
010f0000044000243405430084300843006435064000344403430034210342103411034150340502700017140171503700027200472504700047200672505700067300873506700087300a735087040a7300c735
000f00001c7000c7200e7251c7000c7300e7351c7000c7300e7350c7040c7300e7351c7000c7340d7351e7001c7000c7200e7251c7000c7300e7351c7000c7340e7350c7040c7300e7351170410734107351e700
000f00001c7000c7200a7251c7000c7300a7351c7000c7300a7350c7040c7300a7351c7000c7340d7351e7001c7000c7200a7251c7000c7300a7351c7000c7300a7350c7040c7300a735117040a7340a7351e700
000f00000e6000e6001e7001970023700257000e6000e6130e6000e6001f700386131c70025700227000e6130e6000e6001e700197000e6130e6130e6000e6130e6000e6001d700386132370025700227000e613
000f00000440004424044000440004424064250640004424074200c420044251540001400154001540001400014001540001400014001540013400024000f400134000140013400134000140013400134000f400
000f00000440003424044000440003424054250640003424054200a4200c4250f4200f425154001540000400134001540013400134001540013400134000f400134001540013400134001540013400134000f400
000f00000440003424044000440003424074250640003424074200c4200f42011420114200c4200c4100c4150f40515400134001340015400134001340005434034351540005434034351540008434084350f400
000f0000044000243405430084300843006435064000343407400014040140415400014000141415400024000240401410014000140401400134000140403434034351540003434034351540008434084350f400
00180000187221872418724187221b7221b7241b7241b722167221672416724167221d7221d7241d7241d722187221872418724187221b7221b7241b7241b722167221672416724167221d7221d7241d7241d722
001800001a5001a500195441d500195451954519545225001954022500195441d5001d5001d5051c5001a5001a5001a500195441d500195451954519545225001b54017500175441c5001f500235002350023500
001800001a5001a500195441d5001954519545195452250017540225001b5441d5001d5001d5051c5001a5001a5001a500195441d500195451954519545225001b540175001b5441c50018540235002350023500
001800001a5001a500195041d500195051950519505225001b542175001b5441c50018542185021a5001a5001a5001a5001b500175001b5041c500185001b5041b5541b5551b5001b5541b5551b5041855418555
000d00001c3141c315003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
00100000280752a075280752e075270052a0542a0552a0442a0452d10000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
000f00001445012404144241645012434184251841004404074000c400044051540015400154001540000400134001540013400134001540013400134000f400134001540013400134001540013400134000f400
001c00000203502050090500505002000020500200002050050501d00002034040450305004044020550205002055090500505002000020500200005050030500000002050000000205000000020500405002055
001c00000150001500015000150501530015000153001500025000253002500025350250011500115001150001500015000150001535015000153001500015000353003533035300350503535035000350003500
001c00000030000300003000a324093220d3000c3000a3200c32209320143000a3000a31500300093120b31500300003000a324093220030009320103200e3200f32000300033140a31008312093100030000300
000f00000163501500016150161509605046150161500000016350000001615016150960504615016150000001635000000161501615096050461501615000000163500000016150161509605046150161500000
000f0000195041c50010524135241e504105241352419504195041c50010524135241e504105241452419504195041c50010524135241e504105241352419504195041c50010524135241e504115241552419504
000f0000170501701017050000001701017050200001a0502000018050000001705000000170001700017000170501701017050170001701017050000001a050180501d0501a0501805015000150001500015000
000f00001505015010150501800015010150501700018050170001705000000150501700017000000001500015050150101505000000150101505015000187401871018740150001a7401a740000001500015000
000f00001f7501f7401f7301f7201f7101f7151f735000001d7501d7401d7301d7201d7101d7151d735000001f7501f7401f7301f7201f7101f7151f735000001c7501c7401c7301c7201c7101c7151c73500000
000f00001f55021540225301f5201f5101f5151f535005001d5501f540215301d5201d5101d5151d535005001f5501f5401f5301f5201f5101f5151f535005001c5501c5401c5301c5201c5101c5151c53500500
011800000c4000c4000c4000c3000c4140c4100c4100c3100c3100c3100c4100c4100c4100a4100a4100a4150c4000c4000c4000c3000c4140c4100c4100c3100c3100c3100c4100c4100c4100a4100a4100a415
011800000a4000a4000a4000a3000a4140a4100a4100a3100a3100a3100a4100a4100a4100841008410084150a4000a4000a4000a3000a4140a4100a4100a3100a3100a3100a4100a4100a410084100841008415
01180000197000d7001570019700197400d700157001970019740207401b7401b70016730167251670519700197000070000700187001974000700007001870019740177401b7401b70013730137250070000700
01180000177000d7001570019700177400d7001570019700187401a7451a7401b7001473014725167051970019700007000070018700177400070000700187001574013745137401b70011730117250070000700
001800000661406611066110661006610066110661106611066150660506600066000660006600066000660006614066110661106610066100661106611066110661506605066000660006600066000660006600
001800000000024000240000000024000240000000015720157201a7301a7301770017730177201771500000157141a7201a7201770017720177101771500000157141a7101a7101770017710177101771500000
001800000000024000240000000024000240000000013720137201873018730177001773017720177150000013714187201872017700177201771017715000001371418710187101770017710177101771500000
0018000015724157201a7301a73019730197301573015700157301a73019730157301570015700157301a73019730157301570015700177301c7301b730177301b7001b700177301c7301b730177301770000000
00180000157301a73019730157301770015700137201972017720137201770015700117201172017720177201572015720117201172511705177000f7140f7100f710157101571013710137100f7100f7100f715
00140000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a200122001620014214212212223514214212112221500000
0014000000000000000000000000000000000000000000000000007314083240e3100a315000000000000000000000000000000000000000000000000000000000000073140e3200831507315000000000000000
0014000002720017000272000700047200271000700027150070003304033050b3040b30500700007000271001720017000172000700037200171000700017150070000700007000070000700007000270003710
__music__
04 41 42 43 0d
03 41 42 43 10
01 41 42 43 24
00 41 42 25 24
00 41 42 26 24
02 41 42 27 24
00 41 42 43 1d
01 41 42 43 1e
00 41 42 1f 1d
00 41 42 1f 1e
00 41 20 1f 1d
00 41 21 1f 1e
00 41 20 1f 1d
00 41 22 1f 1e
00 41 23 43 1d
00 41 23 23 1e
02 41 1c 1c 1c
01 41 42 43 2b
00 41 42 2c 2b
00 41 2d 2c 2b
02 41 42 2c 2b
00 41 42 43 2e
01 41 42 2f 2e
00 41 30 2f 2e
00 41 31 2f 2e
00 41 32 43 2e
02 41 32 33 2e
01 41 42 43 34
00 41 42 43 35
00 41 42 36 34
02 41 42 37 35
01 41 42 43 38
00 41 42 39 38
00 41 42 3a 38
00 41 42 39 38
00 41 42 3a 38
00 41 42 3b 38
02 41 42 3c 38
02 41 42 3c 38
01 41 42 43 3f
00 41 42 43 3f
00 41 42 3e 3f
02 41 42 3d 3f
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
