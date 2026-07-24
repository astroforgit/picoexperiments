pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--bob of thunder
--by axnjaxn

cartdata("axnjaxn_bobthunder")

function nilf() end

function printfont(s, x, y, c, sh, wx, wy, ignore_colors)
   if (sh) printfont(s,x+1,y+1,sh,nil,wx,wy,true)

   local cx,ch,p,st=x
   if (c) p = pal(11, c)
   wx = wx or 1
   wy = wy or 1
   for i=1,#s do
      ch=ord(s,i)-32
      if ch==-22 then
         y+=8*wy
         cx=x
      elseif ch==222 then
         st=not st
      elseif ch>=96 then
         if (not ignore_colors) pal(11, ch-96)
      else
         sspr(ch%21*6,ch\21*8+72,6,8,cx,y,wx*6,wy*8)
         if (st) line(cx,y+4,cx+wx*6-1,y+4,11)
         cx+=6*wx
      end
   end
   if (c) pal(11, p)
end

function clsn(a, b)
   return a.x<b.x+b.w and b.x<a.x+a.w and a.y<b.y+b.h and b.y<a.y+a.h
end

-->8
--logo and title
function _init()
   memcpy(0x4400,0x2000,0x1000)
   f=0
   _update = update_title
   _draw = draw_title
   sparks={}
   has_save=dget(63,0)>0
end

function update_title()
   for s in all(sparks) do
      s.x+=s.dx+rnd(2)-1
      s.y+=s.dy+rnd(2)-1
      s.ctr-=1
      if (s.ctr <= 0) del(sparks,s)
   end
   if btnp(4) then
      play(21)
      if menu then
         if menu == 1 then
            if has_save and not confirm then
               confirm = true
               return nil
            else
               play(29)
               crawl()
               dset(63,0)
            end
         end
         init_game()
      end
      if (f>=180) menu=0
      f=max(f,180)
   end
   if (btnp(5)) menu=nil
   if (btnp()&0xf>0 and menu) menu=(menu+1)%2
   if (menu and not has_save) menu=1
end

function draw_title()
   f+=1

   cls()
   memcpy(0x4300,0x5f44,8)
   srand(0)
   for i=1,30 do
      pset((rnd(128)-(1+rnd())*f)%128,rnd(128),rnd(3)+5)
   end
   memcpy(0x5f44,0x4300,8)

   camera(-64,-64)
   if (f==30 or f==60 or f==90) sfx(49)
   if (f>=30) printfont("Bob",-33,-24,10,9,2,2)
   if (f>=60) printfont(" of",-3,-24,7,6,2,2)
   if (f>=90) printfont("THUNDER",-42,-8,p and 12 or 7,7,2,2)

   if (f == 120) cls(7) flip() play(21) sfx(48)

   if f>=90 and f <=140 then
      for i=1,5 do
         local s={x=rnd(84)-42,y=rnd(16)-8,ctr=20}
         local th=atan2(s.x/5,s.y)
         s.dx=cos(th)/2
         s.dy=sin(th)/2
         add(sparks,s)
      end
      p = not p
   elseif f>=150 then
      p = true
   end

   local c={1,12,12,7}
   for s in all(sparks) do
      pset(s.x,s.y,c[s.ctr\5+1])
   end

   if (f >= 90 and f<120) printfont("THUNDER",-42,-8,0,1,2,2)
   if (f >= 120) printfont("AXNJAXN 2021",-36,56,6,1)

   if menu then
      printfont("Continue", -24, 16, has_save and 7 or 5, 1)
      printfont(has_save and not confirm and menu==1 and "You sure?" or "New Game", -24, 24, 7, 1)
      spr(20, 3*sin(t())-36, 16+8*menu, 1, 1, true)
   else
      local cs,i={0,1,5,13,6,7,7},4.5-3*cos(f/30)
      local c=cs[i\1]
      if (f >= 180) printfont("Press ",-21,16,c) print("\142",15,18,c)
   end

   camera()
end

-->8
--game engine
function load_data()
   if dget(63) == 0 then --no data
      for i=0,63 do dset(i,0) end
      dset(63,0xff)
      dset(1,20)
      dset(4,104)
      dset(5,80)
   end

   current_room = dget(0)
   hp = dget(1)
   money = dget(2)
   has_hammer = dget(3)&0x80>0
   has_drill = dget(3)&0x40>0
   has_hat = dget(3)&0x20>0
   restorex = dget(4)
   restorey = dget(5)
   key_map = dget(6)
   lock_map = dget(9)
   keys=0
   for i=0,15 do
      keys += (key_map>>i)&1
      keys -= (lock_map>>i)&1
   end
end

function save_data()
   local v=current_room<=31
   dset(0, min(current_room,31))
   dset(1, v and hp or max(hp,10))
   dset(2, money)
   dset(3, (has_hammer and 0x80 or 0)|(has_drill and 0x40 or 0)|(has_hat and 0x20 or 0))
   dset(4, v and restorex or 57)
   dset(5, v and restorey or 41)
   dset(6, key_map)
   dset(9, lock_map)
end

function mark_checkpoint(bits)
   dset(12, dget(12)|bits)
end

function has_checkpoint(bits)
   return dget(12)&bits>0
end

function kl_mask(t, mp, room, no)
   for i=1,#t do
      if (t[i]==room+no/16) return 1<<(i-1)
   end
end

key_index = {4,2,15,20,27,29}
lock_index = {2,9,0x9.1,24,30,31}

function has_key(room, keyno)
   return key_map&kl_mask(key_index, key_map, room, keyno)>0
end

function is_unlocked(room, lockno)
   return lock_map&kl_mask(lock_index, lock_map, room, lockno)>0
end

function init_game()
   facing = {
      {[0]=9.5,11.5,10.5,12.5,10.5},
      {[0]=9,11,10,12,10},
      {[0]=16,17,18,17,18.5},
      {[0]=1,2,3,2,3.5}
   }
   xoffset = {-1,1,0,0}
   yoffset = {0,0,-1,1}
   hammer_gfx = {20,20.5,19,19.5}

   player = nil
   hammer = nil
   load_data()
   player = build(restorex,restorey,6,6,nil,{s=238,si=0,facing=4})

   _update = update_game
   _draw = draw_game

   load_room(current_room)
end

function copy_room(src, srcstr, dst, dststr)
   for i=0,11 do
      memcpy(dst, src, 16)
      src += srcstr
      dst += dststr
   end
end

function transition(transition_type, door)
   local doors={
      [7]={8,57,33},
      [8]={7,57,15},
      [18]={19,9,25},
      [19]={18,106,40},
      [0x13.1]={20,18,48},
      [20]={19,113,25},
      [24]={25,56,79},
      [25]={24,56,50}
   }

   local next_room
   if transition_type == 0 then
      next_room,player.x,player.y = unpack(doors[current_room | (door.doorno>>4)])
   else
      next_room = peek(0x5200+4*current_room+transition_type-1)
   end
   prev_room = current_room

   -- store previous room's state
   copy_room(0x2000,128,0x4300,16)
   local temp = entities
   for entity in all(temp) do
      entity.x += 128
   end

   -- instantiate new room
   load_room(next_room)
   copy_room(0x4300,16,0x2010,128)

   if transition_type != 0 then
      local x,y=xoffset[transition_type],yoffset[transition_type]

      player.x -= x*123
      player.y -= y*92

      -- play animation
      local t
      for i=0,16 do
         t = {128+i*8*x,
              i*6*y,
              x*(i*8-128),
              y*(i*6-96)}

         rpal()
         cls()
         --old room
         camera(t[1],t[2])
         temp,entities=entities,temp
         draw_room(16)
         --new room
         camera(t[3], t[4])
         temp,entities=entities,temp
         draw_room(0)

         camera()
         draw_hud()
         flip()
      end

      player.x += x*5
      player.y += y*5
   end

   restorex,restorey=player.x,player.y
   save_data()
end

function find_entity(id)
   for entity in all(entities) do
      if (entity.id==id) return entity
   end
end

function join(a, b)
   for k,v in pairs(b) do
      a[k]=v
   end
end

function build(x,y,w,h,update,cont)
   local entity = {x=x,y=y,w=w,h=h}
   entity.update = update
   join(entity,cont)
   return entity
end

function replace(from,to)
   for r=0,11 do
      for c=0,15 do
         if (mget(c,r)==from) mset(c,r,to)
      end
   end
end

function del_entity(id)
   del(entities, find_entity(id))
end

function load_room(room_no)
   reload()
   decompress(0x4400,room_no)
   current_room = room_no
   bgcolor = room_no > 24 and 134 or 139

   entities = {}
   blocks={}
   local v, f, entity
   local ow = function(t)
      join(entity,t)
   end

   local grow = function(i)
      entity.x-=i
      entity.y-=i
      entity.w+=2*i
      entity.h+=2*i
   end

   local keyno,lockno,signno,doorno=0,0,0,0

   local nextid,x,y=1
   for r=0,11 do
      for c=0,15 do
         v = mget(c,r)
         f = fget(v) & 0x3f
	 x,y = 8*c,8*r
         entity=build(x,y,8,8,nilf,{s=v,id=nextid})
         if f == 1 then
            ow({update=update_hoparound,onhit=onhit_enemy,s0=48,s1=49,ds=0.25,ctr=0,dmg=1,hp=1})
         elseif f == 2 then
            ow({update=update_patroller,onhit=onhit_enemy,s0=50,s1=51,ds=0.25,dmg=2,hp=2,dx=4*(v-50.5),dy=0})
            grow(-1)
         elseif f == 3 then
            ow({update=update_goblin,onhit=onhit_enemy,s0=52,s1=53,ds=0.25,dmg=2,hp=2,facing=4,ctr=0})
         elseif f == 4 then
            ow({update=update_snake,onhit=onhit_enemy,s0=54,s1=55,ds=0.25,dmg=3,hp=2,ctr=1})
         elseif f == 5 then
            ow({update=update_crabber,dmg=3,y0=y,missile=true})
         elseif f == 6 then
            ow({update=update_sentry,draw=draw_sentry,ctr=0,v=v})
         elseif f == 7 then
            ow({update=update_launcher,ctr=0,s=0,facing=v-89})
         elseif f == 8 then
            ow({update=update_flapper,onhit=onhit_enemy,s0=59,s1=61,ds=0.25,dx=3,dy=1,dmg=2,hp=1})
         elseif f == 9 then
            ow({update=update_robot,onhit=onhit_robot,fct=rnd(60)\1+40,dmg=1,hp=3,s0=62,s1=63,ds=0.25})
         elseif f == 10 then
            ow({update=update_item,pickup=pickup_heart})
         elseif f == 11 then
            ow({update=update_item,pickup=pickup_coin})
         elseif f == 12 then
            ow({update=update_sign,s=0,signno=signno})
            grow(1)
	    signno+=1
         elseif f == 13 then
            ow({update=update_item,pickup=pickup_ljessnir})
            if (has_hammer) entity=nil v=0 nextid+=1
         elseif f == 14 then
            ow({update=update_item,pickup=pickup_flower,s=0})
         elseif f == 15 then
            ow({update=nilf,peg=true,s=0})
            if (v==68) ow({draw=draw_peg})
         elseif f == 16 then
            ow({update=update_switch,onhit=onhit_switch,s=0})
            grow(2)
         elseif f == 17 then
            ow({update=update_block,box=build(x-1,y-1,10,10),ctr=0})
            add(blocks,entity)
         elseif f == 18 then
            ow({update=update_item,pickup=pickup_key,keyno=keyno})
            if (has_key(room_no,keyno)) entity=nil v=0 nextid+=1
            keyno+=1
	 elseif f == 19 then
	    ow({update=update_lock,s=0,lockno=lockno})
            grow(1)
	    if (is_unlocked(room_no,lockno)) entity=nil v=0 nextid+=1
	    lockno+=1
         elseif f == 20 then
            ow({update=update_door,s=0,doorno=doorno})
            doorno+=1
         elseif f == 21 then
            ow(build(x-4,y-4,16,16,update_bomb))
         elseif f == 23 then
            local pal={[2]=3,[14]=11}
            if (room_no == 17 or room_no == 22) pal={[2]=13,[14]=12}
            ow({update=update_npc,draw=draw_npc,signno=signno,pal=pal})
            grow(1)
            signno+=1
         elseif f == 24 then
            ow({update=update_stone,draw=draw_stone,box=build(x-1,y-1,10,10),dx=0,dy=0,f=0,ctr=0})
            add(blocks,entity)
         elseif f == 25 then
            ow({update=update_item,pickup=pickup_drill})
            if (has_drill) entity=nil v=0 nextid+=1
         elseif f == 26 then
            ow({update=update_item,pickup=pickup_hat})
            if (has_hat) entity=nil v=0 nextid+=1
         else
            entity=nil
         end
         if entity then
            add(entities,entity)
            nextid += 1
            if ((entity.s and entity.s>0) or entity.draw) v=0
            if (entity.v) v = entity.v
         end
         mset(c,r,v)
      end
   end

   hammer = nil
   flingx,flingy=0,0
   iframes=0

   --overrides
   if room_no==2 then
      if (is_unlocked(2,0)) onhit_switch(find_entity(9))
   elseif room_no == 3 and (player.y<=8 or prev_room==6) then
      entities[1].x+=8
      entities[6].x=16
      entities[6].y=24
   elseif room_no == 4 then
      if not has_key(4,0) then
         entities[5].signno=0
         entities[5].update = function(e)
            update_sign(e)
            update_item(e)
         end
      end
   elseif room_no == 6 then
      entities[1].post = function()
         mset(14,3,0)
         del_entity(2)
         mark_checkpoint(4)
      end
      if (not has_checkpoint(2) or has_checkpoint(4)) del_entity(1)
      if (has_checkpoint(4)) mset(14,3,0) del_entity(2)
   elseif room_no == 7 then
      if (has_checkpoint(1)) mset(7,2,0) toggle_door(entities[3])
      entities[8].peglist={4,7}
      entities[9].peglist={5}
   elseif room_no == 8 then
      bgcolor=132
      entities[2].callback = function(entity)
         for i=4,7 do
            if (find_entity(i)) return nil
         end
         mset(3,1,32)
         mset(3,5,0)
      end
      entities[2].post = function() mark_checkpoint(2) end
      if (has_checkpoint(2)) del_entity(2)
   elseif room_no == 12 and (player.x<=16 or prev_room==13) then
      entities[2].y = 72
   elseif room_no == 14 and ((player.y<=16 and not prev_room) or prev_room==17) then
      for b in all(blocks) do
         del(entities,b)
         del(blocks,b)
      end
   elseif room_no == 15 then
      local fn = function(entity)
         local t,u = {3,8,12,6},{4,11,13,9}
         if entity.ctr == 0 then
            entity.ctr = 12
            local i = entity.i
            toggle_pegs({t[i+1],u[i+1]})
            i = (i + 1) % 4
            toggle_pegs({t[i+1],u[i+1]})
            entity.i = i
         end
         entity.ctr -= 1
      end
      add(entities, build(0,0,0,0,fn,{s=0,i=0,ctr=0}))
   elseif room_no == 17 then
      entities[1].post = function() mark_checkpoint(8) end
      if (has_checkpoint(8)) del_entity(1)
   elseif room_no == 18 then
      entities[14].peglist={20,21,23,25}
   elseif room_no == 19 then
      bgcolor = 132
      replace(0,89)
      for i=3,9,3 do mset(i,1,0) end
   elseif room_no == 21 then
      entities[7].peglist={5,6}
   elseif room_no == 22 then
      v=dget(12)&0x30
      if v == 0 then
         entities[13].post = function()
            mark_checkpoint(0x10)
            load_room(22)
            player.hitsign = find_entity(13) --prevent this from looping
            player.hitsign.signno+=1
         end
      elseif v == 0x30 then
         replace(31,26)
         entities[13].signno+=1
      end
      if v == 0x10 then
         entities[8].update = function(entity)
            update_bomb(entity)
            if (entity.ctr == 0) mark_checkpoint(0x20)
         end
      else
         for e in all(entities) do
            if (e.update==update_bomb) del(entities,e)
         end
      end
      if (key_map < 0xf) del_entity(13)
   elseif room_no == 23 then
      entities[1].post = function(entity)
         hp = 20
         money = 25
      end
      if (not has_checkpoint(16)) del_entity(1)
   elseif room_no == 24 then
      entities[1].update = function(entity)
         if is_unlocked(24,0) then
            toggle_door(entity)
            entity.update = update_door
         end
      end
      entities[1].update(entities[1])
   elseif room_no == 27 then
      find_entity(3).peglist={2}
      find_entity(6).peglist={4}
      find_entity(7).peglist={5}
   elseif room_no == 28 then
      add(entities, build(0,0,0,0,
                          function(entity)
                             if (player.x > 8) del(entities, entity) mset(0,3,29)
                          end,
                          {draw=nilf}))
   elseif room_no == 32 then
      showtextbox(0, function() play(13) end)
      textboxes[32]="\138Hrungnir:\135\nBack for more?\nSuit yourself."
   elseif room_no == 34 then
      find_entity(2).peglist={4,5}
      find_entity(8).peglist={6,7}
   elseif room_no == 35 then
      entities[1].s=32
   end

   if room_no > 32 then
      play(13)
   elseif room_no > 24 then
      play(30)
   elseif room_no >= 9 then
      play(6)
   else
      play(21)
   end

   if room_no >= 32 and room_no <= 34 then
      add(entities, build(36,32,16,16,
                          update_hrungnir,
                          {
                             draw=draw_hrungnir,
                             onhit=onhit_hrungnir,
                             dmg=20,
                             phase=room_no - 31,
                             s=100,
                             t=t(),
                             hist={},
                             particles={},
                             ctr=0
      }))
   end
end

function issolid(x,y,fl)
   if (not fl) fl=0x80
   if (x<0 or x>=128 or y<0 or y>=96 or fget(mget(x\8,y\8))&fl>0) return true
   for block in all(blocks) do
      if (x>=block.x and x<block.x+block.w and y>=block.y and y<block.y+block.h) return true
   end
end

function move(entity, dx, dy, facing)
   local x0,y0,x1,y1,fl,hit = entity.x,entity.y,entity.w,entity.h,entity.missile and 0x80 or 0xc0
   x1+=x0-1
   y1+=y0-1

   local mx = function()
      local x,s = (dx < 0) and x0 or x1, sgn(dx)
      for d=dx,s,-s do
         if (not (issolid(x+d,y0,fl) or issolid(x+d,y1,fl))) break
         dx=d-s
         hit = true
      end
   end

   if facing <= 2 then --horizontal facing
      mx()
   end
   local y,s = (dy < 0) and y0 or y1, sgn(dy)
      for d=dy,s,-s do
         if (not (issolid(x0,y+d,fl) or issolid(x1,y+d,fl))) break
         dy=d-s
         hit = true
      end
   if facing > 2 then --vertical facing
      mx()
   end
   entity.x+=dx
   entity.y+=dy
   return hit
end

function get_facing(dx,dy)
   local x,y,facing = abs(dx),abs(dy),1
   local sum=x+y
   if (y>x) facing=3 dx=dy
   if (dx>0) facing+=1
   return facing,sum
end

function update_game()
   --player
   local dx,dy=flingx,flingy
   flingx,flingy=abs(flingx)\2*sgn(flingx),abs(flingy)\2*sgn(flingy)

   if flingx|flingy==0 then
      local last,faced
      for i=1,4 do
         if btn(i-1) then
            last = i
            dx += xoffset[i]
            dy += yoffset[i]
            if (player.facing == i) faced = true
         end
      end
      local si,i,s=(player.si+.5)%4,0
      if last then
         if (not faced) player.facing=last si=0
         i=si\1+1
      else
         si=1
      end
      s = facing[player.facing][i]
      player.si=si
      player.s=s\1
      player.fx=s&.5>0
   end
   move(player,dx,dy,player.facing)

   if btnp(4) and has_hammer and not hammer then
      hammer = build(player.x,player.y,6,6,nil,
                     {s=19,
                      missile=true,
                      out=true,
                      facing=player.facing})
      was_out = true
      sfx(42)
   end

   --hammer
   update_hammer()

   --drill
   if btn(5) and has_drill and money>0 then
      dx,dy=xoffset[player.facing]*2,yoffset[player.facing]*2
      local entity = build(player.x+3*dx,player.y+3*dy,6,6,nil,{missile=true})
      if (not drill) sfx(47)
      drill={}
      local done
      repeat
         local out
         if (hammer) out=hammer.out
         add(drill, build(entity.x,entity.y))
         for e in all(entities) do
            if clsn(e,entity) and e.onhit then
               e.onhit(e, false)
               done = true
            end
         end
         if (hammer) hammer.out=out
      until done or move(entity,dx,dy,player.facing)
      for b in all(blocks) do
         if clsn(entity,b.box) then
            del(blocks,b)
            b.draw=nil,
            join(b,{s=129,s0=128,s1=133,ds=1,
                    update=function(entity)
                       if (entity.s==128) del(entities,entity)
                    end
            })
         end
      end
      money -= 1
   else
      drill=nil
      sfx(47,-2)
   end

   --hat
   if has_hat then
      regen_mp = regen_mp and regen_mp+1 or 0
      if (regen_mp>=120) money=min(money+1,25) regen_mp = 0
   end


   --entities
   for entity in all(entities) do
      entity.update(entity)
      if (hammer and clsn(entity, hammer) and entity.onhit) entity.onhit(entity, true)
      if (entity.dmg and clsn(player,entity)) dodamage(entity)
   end

   if player.x <= 0 then
      transition(1)
   elseif player.x + player.w >= 127 and current_room < 32 then
      transition(2)
   elseif player.y <= 0 then
      transition(3)
   elseif player.y + player.h >= 96 then
      transition(4)
   end

   iframes-=1
   if (hp<=0) die()
end

function rpal()
   pal()
   pal(0,bgcolor,1)
end

function draw_hud()
   rpal()
   rectfill(0,96,127,127,1)
   spr(45, 2, 98)
   rectfill(18,101,118,104,5)
   if (hp>0) rectfill(17,100,17+5*hp,103,8)
   rectfill(18,111,118,114,5)
   if (money>0) rectfill(17,110,17+4*money,113,9)
   spr(47, 2, 108)
   printfont("Items", 2, 118, 7, 5)
   local x = 42
   if (has_hammer) spr(19,x,118) x+=10
   if (has_drill) spr(72,x,118) x+=10
   if (has_hat) spr(134,x,118) x+=10
   for i=1,keys do
      spr(44,x,118)
      x += 10
   end
end

function hatpal()
   return has_hat and {[1]=5,[2]=4,[4]=1,[14]=9} or {[2]=10,[14]=10}
end

function draw_room(offs)
   rpal()
   map(offs,0,offs*8,0,16,12)

   --entities
   for entity in all(entities) do
      if entity.blink then
         entity.blink=max(entity.blink-1,0)
         if (entity.blink%2>0) palt(0xffff)
      end
      if entity.draw then
         entity.draw(entity)
      else
         spr(entity.s,entity.x+entity.w/2-4,entity.y+entity.h/2-4,1,1,entity.fx,entity.fy)
         if entity.ds then
            entity.s+=entity.ds
            if (entity.s>=entity.s1+1) entity.s = entity.s0
         end
      end
      palt()
   end

   --hammer
   rpal()
   if (hammer) spr(hammer.s, hammer.x-1, hammer.y-1, 1, 1, hammer.fx, hammer.fy)

   --drill
   if drill then
      local f = player.facing>2 and 75 or 140
      pal(1,12)
      if (has_hat) pal({[1]=9,[12]=9,[7]=10})
      for d in all(drill) do
         spr(f+rnd({0,0,1,1,2}),d.x-1,d.y-1)
      end
      palt(0xc008)
      for d in all(drill) do
         spr(f+rnd({0,0,1,1,2}),d.x-1,d.y-1)
      end
      rpal()
   end

   --player
   split_spr(player.s,player.x-1,player.y-1,
             hatpal(),
             {[2]=13,[14]=12},
             player.fx)
end

function split_spr(s,x,y,ptop,pbot,fx)
   pal(ptop)
   spr(s,x,y,1,1,fx)
   pal(pbot)
   sspr(s%16*8,s\16*8+4,8,4,x,y+4,8,4,fx)
   rpal()
end

function draw_game()
   rpal()
   cls(0)
   draw_room(0)
   draw_hud()
end

function update_hammer()
   if hammer then
      local facing=hammer.facing
      if hammer.out then
         dx = xoffset[facing]*4
         dy = yoffset[facing]*4
      else
         if (was_out) was_out=false sfx(56)
         dx = player.x - hammer.x
         dy = player.y - hammer.y
         facing = get_facing(dx,dy)
         dx = mid(-4,dx,4)
         dy = mid(-4,dy,4)
      end
      if (move(hammer, dx, dy, facing)) hammer.out = false
      local s = hammer_gfx[facing]
      hammer.s=s\1
      hammer.fx=s%1>0
      hammer.fy=hammer.fx
      hammer.facing=facing
      if (not hammer.out and clsn(hammer,player)) hammer = nil
   end
end

function onhit_enemy(entity)
   local t = time()
   if (entity.hittime and entity.hittime + 0.25 > t) return nil
   entity.hittime = t
   entity.hp -= 1
   if entity.hp <= 0 then
      del(entities, entity)
      local x,y,r=entity.x+entity.w/2-4,entity.y+entity.h/2-4,rnd()

      if r<.5 then
         --drop a pickup
         entity = build(x,y,8,8,update_item,{s=45,pickup=pickup_heart})
         if (r<.25) entity.s=47 entity.pickup=pickup_coin
         add(entities, entity)
      end

      add(entities, build(x,y,8,8,update_spark,{draw=draw_spark,ctr=5}))
   else
      entity.blink = 6
   end
   if (hammer) hammer.out = false
end

function dodamage(entity)
   if (iframes>0) return nil
   if entity.update == update_flare then
      if (not flareon) hp+=entity.dmg
      flareon=false
   end
   hp=max(0,hp-entity.dmg)
   sfx(hp>0 and 43 or 44)
   local th=atan2(player.x+player.w/2-entity.x-entity.w/2,player.y+player.h/2-entity.y-entity.h/2)
   flingx,flingy=(6*cos(th))&0xffff,(6*sin(th))&0xffff
   iframes=10
end

function die()
   for j=1,4 do
      for i in all({9,16,0x9.0001,1}) do
         draw_game()
         player.s=j==4 and 6 or i
         player.fx=i==0x9.0001
         flip()
         flip()
      end
   end
   local x=player.x
   player.x=128
   draw_game()
   pal(hatpal())
   spr(7,x-1,player.y-1)
   for i=1,15 do flip() end
   init_game()
   if(restorex) player.x,player.y=restorex,restorey
end

function update_item(entity)
   if (clsn(entity,player)) entity.pickup(entity) del(entities, entity)
end

function update_hoparound(entity)
   entity.ctr -= 1
   if (entity.ctr<=0) entity.dx,entity.dy=0,0
   if entity.ctr<=-16 then
      local facing = rnd(4)\1+1
      entity.dx,entity.dy = 2*xoffset[facing],2*yoffset[facing]
      entity.ctr = 8
   end
   move(entity, entity.dx, entity.dy, 0)
end

function update_patroller(entity)
   if (move(entity, entity.dx, entity.dy, 0)) entity.dx*=-1 entity.dy*=-1
end

function update_goblin(entity)
   local dx,dy = player.x - entity.x + 1,player.y - entity.y + 1
   local facing,sum = get_facing(dx,dy)
   if (sum<32) dx,dy=0,0
   local x,y=rnd(3)-1,rnd(3)-1
   dx = mid(-1,dx+x\1,1)
   dy = mid(-1,dy+y\1,1)
   move(entity, dx, dy, facing)
   entity.ctr = (entity.ctr + 1) % 30
   if entity.ctr == 0 then
      local f=facing%2==0
      add(entities, build(entity.x+1,entity.y+1,6,6,update_arrow,
                          {dx=3*xoffset[facing],
                           dy=3*yoffset[facing],
                           s=138+facing\3,
                           fx=f,
                           fy=f,
                           dmg=2,
                           missile = true}))
   end
end

function update_arrow(entity)
   if (move(entity, entity.dx, entity.dy, 0)) del(entities,entity)
end

function update_snake(entity)
   local dx = player.x - entity.x + 1
   local dy = player.y - entity.y + 1
   local speed = max(abs(dx),abs(dy)) < 24 and 3 or 1

   entity.ctr -= 1
   if entity.ctr == 0 then
      entity.facing=1+rnd(4)\1
      entity.ctr = 45
   end
   dx=speed*xoffset[entity.facing]
   dy=speed*yoffset[entity.facing]
   if (move(entity, dx, dy, entity.facing)) entity.ctr = 1
end

function update_crabber(entity)
   if entity.down then
      if (move(entity,0,entity.dy,4)) entity.dy = -abs(entity.dy)
      if (entity.y <= entity.y0) entity.down = false
   else
      if (abs(player.x - entity.x - entity.w / 2) < 16) entity.dy,entity.down = 3,true
   end
end

function update_sentry(entity)
   if (entity.spark) return nil
   if not entity.boxes then
      entity.boxes = {
         build(0,entity.y,entity.x,entity.h),
         build(entity.x+entity.w,entity.y,127,entity.h),
         build(entity.x,0,entity.w,entity.y),
         build(entity.x,entity.y+entity.h,entity.w,127)
      }
   end
   for i=1,4 do
      if clsn(entity.boxes[i],player) then
         entity.spark = build(entity.x+1, entity.y+1, 6, 6,
                              update_sentryshot,
                              {dx=xoffset[i]*8,
                               dy=yoffset[i]*8,
                               s=68,
                               s0=68,
                               s1=69,
                               ds=1,
                               dmg=20,
                               parent=entity,
                               missile = true})
         add(entities, entity.spark)
      end
   end
end

function update_launcher(entity)
   if (entity.bulletman) return nil

   entity.ctr += 1
   if entity.ctr >= 75 then
      entity.ctr = 0
      local dx = 8*(entity.facing-1.5)
      entity.bulletman = build(entity.x+(dx<0 and 0 or 8), entity.y, 8, 6,
                               update_bulletman,
                               {s=58,
                                dx=dx,
                                fx=dx<0,
                                parent=entity})
      add(entities, entity.bulletman)
   end
end

function update_bulletman(entity)
   if move(entity, entity.dx, 0, 1) then
      add(entities,build(entity.x-4,entity.y-4,16,16,update_boom,
                         {draw=draw_boom,
                          ctr=0,
                          dmg=3}))
      entity.parent.bulletman=nil
      del(entities, entity)
   end
end

function draw_sentry(entity)
   local t={{1,1},{1,9},{9,10},{1,9}}
   entity.ctr=(entity.ctr+1)%20
   split_spr(57,entity.x,entity.y,t[entity.ctr\5+1])
   rpal()
end

function update_sentryshot(entity)
   for i=1,2 do
      if (move(entity, entity.dx\2, entity.dy\2, 0)) del(entities,entity) entity.parent.spark=nil
   end
end

function update_robot(entity)
   local dx,dy=entity.x-player.x,entity.y-player.y
   local th=atan2(dx,dy)

   entity.fct-=1
   if entity.fct<=0 then
      entity.fct = rnd(60)\1+40
      add(entities, build(entity.x+1,entity.y+1,6,6,update_arrow,
                          {s=70,s0=70,s1=71,ds=1,dx=-2*cos(th)\1,dy=-2*sin(th)\1,dmg=2,missile=true}))
   end

   if not entity.x1 then
      th+=rnd({-0.125,0.125})
      local d=sqrt(dx*dx+dy*dy)
      d=max(d-8*rnd({-2,0,1,2}),32)
      join(entity,{x0=entity.x,
                   y0=entity.y,
                   x1=d*cos(th)+player.x,
                   y1=d*sin(th)+player.y,
                   ctr=32})
   end

   local a=entity.ctr>>5
   local b=1-a
   dx,dy = a*entity.x0+b*entity.x1-entity.x,a*entity.y0+b*entity.y1-entity.y
   entity.ctr -= 1
   if (move(entity,dx\1,dy\1,dx>dy and 1 or 3) or entity.ctr<0) entity.x1 = nil
end

function onhit_robot(entity)
   onhit_enemy(entity)
   if (entity.hp<=0 and entity.peglist) toggle_pegs(entity.peglist)
end

function update_flapper(entity)
   update_patroller(entity)
   entity.fx = entity.dx<0
   entity.dy = (2*sin(t())+0.5)\1
end

function toggle_peg(entity)
   if entity.draw then
      entity.draw=nil
   else
      entity.draw=draw_peg
   end
   mset(entity.x\8,entity.y\8,entity.draw and 0 or 34)
end

function toggle_pegs(peglist)
   for i in all(peglist) do
      toggle_peg(find_entity(i))
   end
end

function toggle_all_pegs()
   for e in all(entities) do
      if (e.peg) toggle_peg(e)
   end
end

function update_switch(entity)
   if (clsn(player,entity) and btnp(4)) onhit_switch(entity)
end

function onhit_switch(entity)
   local t = time()
   if (entity.hittime and entity.hittime + 0.5 > t) return nil
   entity.hittime = t
   local c,r=(entity.x+2)\8,(entity.y+2)\8
   mset(c,r,mget(c,r) == 32 and 33 or 32)
   toggle_pegs(entity.peglist)
   if (not entity.peglist) toggle_all_pegs()
   sfx(55)
end

function update_block(entity)
   entity.dx=0
   entity.dy=0
   update_stone(entity)
end

function pickup_key(entity)
   keys += 1
   key_map|=kl_mask(key_index, key_map, current_room, entity.keyno)
   sfx(57)
end

function update_lock(entity)
   if entity.ctr then
      entity.ctr -= 1
      entity.y -=1
      if (entity.ctr <= 0) del(entities,entity)
   elseif clsn(entity,player) and keys>0 then
      mset((entity.x+1)\8,(entity.y+1)\8,0)
      join(entity,{s=43,s0=0,s1=43,ds=43,ctr=10})
      keys -= 1
      lock_map|=kl_mask(lock_index, lock_map, current_room, entity.lockno)
      sfx(58)
   end
end

function toggle_door(entity)
   local c,r = entity.x\8,entity.y\8
   mset(c,r,mget(c,r)==137 and 29 or 137)
end

function update_door(entity)
   if (clsn(player,entity)) transition(0, entity)
end

function update_bomb(entity)
   for e in all(entities) do
      if (e.spark and clsn(entity, e.spark)) or (e.update==update_arrow and clsn(entity,e)) then
         join(entity,{spark=entity,update=update_boom,draw=draw_boom,ctr=0,dmg=3})
         if (current_room==7) mset(7,2,0) toggle_door(find_entity(3)) mark_checkpoint(1)
         replace(31,26)
         break
      end
   end
end

function update_boom(entity)
   entity.ctr+=1
   if (entity.ctr==1) sfx(49)
   if (entity.ctr>=8) del(entities,entity)
end

function update_npc(entity)
   update_sign(entity)
   if (entity.callback) entity.callback(entity)
end

function draw_npc(entity)
   pal(entity.pal)
   spr(1, entity.x+1, entity.y+1)
   rpal()
end

function update_stone(entity)
   local dx,dy = entity.dx,entity.dy
   if clsn(player,entity.box) then
      entity.ctr = 0
      if (player.x==entity.x+entity.w and player.facing==1) dx=-1 dy=0
      if (player.x+player.w==entity.x and player.facing==2) dx=1 dy=0
      if (player.y==entity.y+entity.h and player.facing==3) dy=-1 dx=0
      if (player.y+player.h==entity.y and player.facing==4) dy=1 dx=0
   end
   entity.ctr = (entity.ctr + 1) % 3
   if (entity.ctr>0 and move(entity,dx,dy,0)) dx,dy=0,0
   entity.dx,entity.dy=dx,dy
   entity.box.x=entity.x-1
   entity.box.y=entity.y-1
end

function draw_stone(entity)
   entity.f=(entity.f+1)%4
   if (entity.dx + entity.dy == 0) entity.f = 0
   local f,g=entity.f>1,0
   if (f) pal(7,6) g=1
   spr(128,entity.x-g,entity.y-g,1,1,f,f)
   rpal()
end

function draw_boom(entity)
   local s,x,y=64+entity.ctr\2,entity.x,entity.y
   spr(s,x,y)
   spr(s,x+8,y,1,1,true)
   spr(s,x,y+8,1,1,false,true)
   spr(s,x+8,y+8,1,1,true,true)
end

function draw_peg(entity)
   sspr(16,16,8,3,entity.x,entity.y+5,8,3)
end

function update_spark(entity)
   entity.ctr-=1
   if (entity.ctr<=0) del(entities,entity)
end

function draw_spark(entity)
   pal({[10]=14,[11]=8})
   spr(73+(entity.ctr\2)%2,entity.x,entity.y)
   rpal()
end

function update_sign(entity)
   if clsn(entity,player) then
      if player.hitsign != entity then
         player.hitsign = entity
         showtextbox(entity.signno, entity.post)
      end
   elseif player.hitsign == entity then
      player.hitsign = nil
   end
end

function pickup_ljessnir(entity)
   showtextbox(0)
   has_hammer = true
end

function pickup_flower(entity)
   mset(entity.x\8,entity.y\8,25)
end

function pickup_heart(entity)
   hp = min(20,hp+2)
   sfx(45)
end

function pickup_coin(entity)
   money = min(25,money+2)
   sfx(46)
end

function pickup_drill(entity)
   showtextbox(0)
   has_drill = true
end

function pickup_hat(entity)
   showtextbox(0)
   has_hat = true
end

function update_hrungnir(entity)
   entity.ctr+=1
   local dx,dy,hist=32+4*entity.phase+(4*entity.phase)*sin(.5*(t()-entity.t))-entity.x,0,entity.hist
   add(hist, player.y-8)
   if #hist>=30 then
      local y=max(deli(hist,1),40)
      if (y >= 52) y=80
      dy=mid(-1,y-entity.y,1)
   end
   if entity.hit then
      entity.s = 104
      entity.x -= 2

      if entity.phase == 3 then
         music(-1,300)
         entity.update = nilf
         entity.hit=false
         for i=0,90 do
            if min(i,60)%5 == 0 then
               add(entities, build(entity.x+rnd(16)-8,entity.y+rnd(16)-8,16,16,
                                   update_boom,
                                   {draw=draw_boom,ctr=0}))
            end

            for e in all(entities) do
               e.update(e)
            end
            update_hammer()
            draw_game()
            flip()
         end
         del(entities,entity)
      end
   else
      move(entity,dx,dy,0)
      if (entity.ctr == 4) entity.s = 100
      if (entity.ctr == 54) entity.s = 104
      if (entity.ctr == 58) entity.s = 102
      if entity.ctr >= 60 then
         local x,y = entity.x+7,entity.y
         dx,dy = player.x-x,player.y-7-y
         new_flare(x,y,8,8*dy/max(dx,1))
         entity.ctr = 0
         sfx(48)
         flareon = true
      end
   end
   if not hammer then
      entity.vuln = false
   elseif hammer.x<16 then
      entity.vuln = true
   end
end

function draw_hrungnir(entity)
   pal(entity.pal)
   entity.pal = nil
   spr(entity.s, entity.x, entity.y, 2, 2)
   rpal()
   local x,y
   for i=1,5 do
      x,y=entity.x+rnd(16),entity.y+rnd(16)
      if (pget(x,y)>0) add(entity.particles,{x=x,y=y,ctr=8})
   end
   for p in all(entity.particles) do
      pset(p.x,p.y,rnd{7,8,9})
      p.y-=1+rnd()
      p.ctr-=1
      if (p.ctr<=0) del(entity.particles,p)
   end
   if entity.hit then
      for i=0,.75,.25 do
         spr(85,entity.x+4+8*cos(t()+i),entity.y-8+4*sin(t()+i))
      end
   end
end

function onhit_hrungnir(entity, is_hammer)
   if entity.vuln and is_hammer then
      add(entities,build(hammer.x,hammer.y,6,6,update_boom,
                         {dmg=3,
                          draw=draw_boom,
                          ctr=0}))
      entity.hit=true
      entity.onhit=nilf
      replace(37,0)
   else
      entity.pal = {12,12,12,12,12,12,12,12,12,12,12,12,12,12,12}
      local c = current_room
      if (not hitfirst) current_room=32 showtextbox(1) current_room=c
      hitfirst=true
   end

   if (is_hammer) hammer.out = false
end

function new_flare(x,y,dx,dy)
   local entity=build(x,y,8,16,update_flare,{s=106,dx=dx,dy=dy,draw=draw_flare,ctr=10,dmg=3})
   move(entity,dx,dy\1,0)
   if (entity.x<120) add(entities,entity)
end

function update_flare(entity)
   entity.ctr -= 1
   if (entity.ctr < 0) del(entities,entity)
   if (entity.ctr == 5) new_flare(entity.x,entity.y,entity.dx,entity.dy)
   if (entity.ctr % 2 == 0) entity.s = 106+rnd(4)
end

function draw_flare(entity)
   spr(entity.s,entity.x,entity.y,1,2)
end
-->8
--music handlers
function play(song)
   if (song != playing) playing=song music(song, 300, 3)
end

-->8
--script
function paginate(s,k)
   local pages,nl,i={},0,1
   while i<=#s do
      if sub(s,i,i)=="\n" then
         nl+=1
         if (nl>=k) add(pages,sub(s,1,i-1)) s=sub(s,i+1) nl=0 i=0
      end
      i+=1
   end
   add(pages,s)
   return pages
end

function showtextbox(signno, post)
   page = 1
   signno = current_room | (signno >> 4)
   pages = paginate(textboxes[signno],3)
   _draw = function()
      draw_game()
      rectfill(0,96,127,127,1)
      printfont(pages[page],1,97,7,5)
      if (time() % 2 > 1) pal(7,5) spr(136, 120, 120) rpal() spr(136, 119, 119)
   end
   _update = function()
      if btnp(4) or btnp(5) then
         page += 1
         if page > #pages then
            _draw,_update = draw_game, update_game
            if (current_room == 35) credits()
            if (post) post()
         end
      end
   end
end

textboxes = {
   [0]="Sorry you had to miss\nthe birth of your\nchild, Bob!\nHere's a Starbucks\ngift card.\n\nAnyway, be careful\nup ahead. Looks like\nThor may have let\njust a few of his\nbrother's monsters\nloose last night.\nShouldn't be too\nhard to get in\nand get the power\nturned back on for\neverybody up there.\n\nBetter get to work!\n -Odin",
   "\138Acquired Ljessnir!\135\n\n\nWhosoever holds this\nhammer, if they be\nworthy,\nshall earn a modest\nhourly wage, per\nthe contract.",
   0,0,
   "\138Acquired a key!\135\n\n\nThis item can open\nmost locks before\ndisintegrating\nfor seemingly no\nreason other than\ntradition.",
   "<- 12m\nCompletely stationary\nwater (very rare)\n-> 22m\nBowyer's workshop",
   "\138Bowyer:\135\nThanks again for\nthe help earlier!\nIt looks like the\ngoblins tossed my\nkey over the fence,\nBut that won't be a\nproblem. I'll just\nget out my trusty\nstandard hook in\n25 thousandths and\na wiper insert...\nClick on 1...\n2 is binding...\nand... got it open!\nThat's all I have for\nnow, and as always,\nhave a nice day.",
   [0x6.1]="L.P. Bowyer & Co.\nDon't pick us,\nwe'll pick you.",
   [0x6.2]="\"When they finally\nfigure out how to\nget inside,\nmake it say 'Gotcha!'\nThey'll love that.\"\n-My Dad, probably.",
   "WARNING:\nDamaged pipes ahead.\n\nFor after-hours\nor holiday access,\ncall Bob's cell at\n(All of the paper\nslips are already\ntorn off below...)",
   "\138Bowyer:\135\nHey, thanks for the\nhelp! The goblins\nstole some of my bows\nand arrows, so I've\nbeen down here\nwaiting for somebody\nto come give me a\nhand.\nDrop by my workshop\nlater if you need\nanything!",
   0,0,0,0,0,
   "Coming soon to\nTGI Freyja's!\n\nBottomless drinking\nhorns! (Pants are\nstill required)",
   0,
   "\138Acquired a Cool Hat!\135\n\n\nYou think you look\npretty ace in this,\n\nbut it smells kind\nof like burnt rubber?",
   "\138Tailor:\135\nI'm so glad to see\nyou, Bob!\nI didn't think I'd\never get out of here.\nIn hindsight,\nI'm not sure why I\nput the switch so\nclose to the skulls.\nWhat do you mean?\nOf course I put all\nthe skulls there.\nHalloween is only\nten months away!\n\nLet me know when\nyou're ready to go\ninto the utility shed\nand I'll help you\nget inside!",
   0,0,
   "Posted: Please stop\ndropping keys into\nall the puzzles!\nAlso, whoever keeps\nrestocking all the\nempty rooms,\nwhere are you getting\nall these snakes?\n-The Mgmt.",
   "\138Acquired Electric\nDrill!\135\n\nThe battery's dead,\nbut it has a coin\nslot in the side.\nThis looks powerful\nenough to break solid\nblocks into pieces:\nEye protection\nis advised, Asgard\nnot required.",
   "<- 30m Utility shed\n-> 12m Picnic area",
   [0x16.1]="\138Tailor:\135\nHey, Bob!\n\nLooks like you might\nhave some trouble\nwith this wall, huh?\nI think this\nsituation calls for\nMORE POWER!",
   [0x16.2]="\138Taylor:\135\nHo ho ho ho ho--\nThat was fun!",
   "\138Bowyer:\135\nThe tailor told me\nyou were about to go\ninto the utility shed\nand get the power\nworking again.\nFeel free to take\na rest here whenever\nyou need one.\nI hope you find the\nshed comically easy\nto open.\n(You feel refreshed!)",
   "Utility Shed\nKEEP OUT",
   [31]="Keep out? I'm Thor,\ndammit. YOU keep out.\nI'm the \254god of thud\n\254god of thnu\ngod of thundre\254\nI'm Mr. Zap!\n...\n\n\n(The note trails off\nas though Thor got\nbored of writing.)",
   [32]="\138Hrungnir:\135\nWelcome to your doom,\nThor, son of Odin!\nI-- wait,\nyou're not Thor.\n\nThat booze-soaked\nmoron must have\nalready wandered off.\nWell, I guess I'll\njust let you get\nback to--\nHEY, HOLD IT!\n\n\nI recognize that\nhammer on your belt.\n\nYou're the one who\nwalked all over my\ndaffodils way back\nat the beginning\nof the game!\n\nOh, that does it!\nPrepare to die, you\ninconsiderate slob!",
   [0x20.1]="\138Hrungnir:\135\nGive up, you blue-\ncollar nobody!\nYou think you can\nhurt me when I see\nyour attacks coming?",
   [35]="It's the main\nelectrical panel.\n\nOh! Looks like it's\nonly a tripped\nbreaker.\n*Click*\n\n\n...\n\n\nI should really start\ncharging by the hour."
}

function ctprintable(ln)
   local ct=0
   for i=1,#ln do
      if (ord(ln,i)<128) ct+=1
   end
   return ct
end

function center(lines,y,c,s)
   for i=1,#lines do
      printfont(lines[i],
                64-3*ctprintable(lines[i]),
                9*i+y,c,s)
   end
end

function credits()
   pal(11,0,1)

   camera(-64,-64)
   for rad=90,0,-2 do
      for y=0,64 do
         x=sqrt(rad*rad-y*y)
         line(-64,y,-x,y,11)
         line(64,y,x,y)
         line(-64,-y,-x,-y)
         line(64,-y,x,-y)
      end
      flip()
   end
   pal()
   camera()

   play(0)

   local lines,ctr = paginate("\138BOB \135OF \140THUNDER\n\n\135A Game by\nBrian Jackson\nfor Toy Box Jam 2\n\n\134Inspired by\n\134Adept Software's\n\134God of Thunder\n\n\140Art and Music\n\140Contributed By:\135\n\nGruber\nTom Hall\nToby Hefflin\nLafolie\nSmelly Fishsticks\nAlice Stenger\n\n\140Special thanks to:\135\n\n\136<3\135 Emahlea\nTim Jackson\nThe Immortal\n Albatross Crew\n\n\nThanks for playing!",1),0
   while true do
      if (ctr>=400) ctr=400 music(-1,3000)
      ctr=ctr+.25
      cls()
      center(lines,142-ctr,7)
      flip()
   end
end

function crawl()
   local lines = paginate("In the land\nof Midgard,\nnone is so mighty as\nTHOR!\n\nAfter a mead-filled\nnight on the town,\nthe Odinson tends\nto leave a trail\nof damage \nand disrepair\nin his wake.\n\nYou are Bob,\ncontractor\nto the gods,\nmender of fences,\nand entry on several\nspeed-dials across\nthe nine realms.\n\nThe power's out\nin Vilahalla,\nwhere Thor spent\nall weekend partying,\nand your voicemail's\nfilling up with\nwork requests.\nTime to put on your\nsteel-toed boots\nand defrost\nyour pickup:\nit's going to be\na long day.",1)

   local ctr=-130
   while ctr<320 do
      ctr += (btn()&0x30>0) and 1 or .25
      cls()
      center(lines,-ctr,7,1)
      flip()
   end
   music(-1,1000)
   for i=1,30 do flip() end
end
-->8
function decompress(src,room_no)
   local ptr = src+peek2(src+0xffe-2*room_no)
   local tree = {}
   local prev,symb,s,st
   local cell=0

   local dout = function(x)
      mset(cell%16,cell\16,x)
      cell+=1
   end

   for i=0,143 do tree[i]={val=i} end
   while true do
      symb,prev = peek(ptr),symb
      ptr += 1

      if (symb == 255) break

      st = tree[symb] and symb or prev
      s = {}
      while st do
         add(s, tree[st].val)
         st = tree[st].prev
      end
      
      for i=#s,1,-1 do dout(s[i]) end
      if (not tree[symb]) dout(s[#s])
      if (prev) add(tree, {prev=prev,val=s[#s]})
   end
end
__gfx__
00000000002ee200000000000002ee20002ee200002ee2000000000000000000002ee2000022ee00000000000022ee000022ee000022ee00022ee00000000000
0000000002222220002ee200002222220222222002222220002ee2000000000002222220022222200022ee00022222200222222002222220222222000022ee00
00000000047ff740022222200447ff74047ff760014ff4100222222000000000071ff170044447f002222220044447f0044447f0044447604441ff0002222220
00000000471ff17404ffff400471ff17471ff1644f1ff1f401ffff1000000000477ff774044f71f004444ff0044f71f0044f71f0044f716044ff1d0004441ff0
000000000ffffff0471ff17400ffffff0ffffd6d0fffffd04f1ff1f4002ee2000ffffff000fffff0044f71f000fffff000fffff000fffd6d0ff4d666044ff1f0
00000000002222000ffffff000222200002222d000222d6d0ffffff002222220002222000022220000fffff00022220000222200002222d002222d0000fffff0
0000000000eeee0000eeee0000eee40000eeee4000eeee6000eeee00011ff11000eeee0000eeee0000eeee0000eee400004eee0000eeee400eeee00000eeee00
000000000040040000400400004000000040040000400460004004004ffffff40040040000400400004004000040000000000400004004000400400000400400
00222200000000000222200006566650056000000bb3b3b030bbb0030000004000000030000300000b0dd0306566656665666566566666656566656677767776
0222222000222200222222000666666556500000bb3b3b350bbb3300040000000300000003000030d3000b0d55555555555555556d6666d65577775576657665
0444444002222220444444400659405666000000b3b33333bb3bbb300000040000000300000003b0000b0300666566656665d665624444266676d7d576657665
4f4444f404444440f4444f400009400066444444b3333335b3b3b335000400000003000000b00bb0b00300005555555555555555642222465577775565556555
0ffffff04f4444f4ffffff0000094000669999990b4334503bbb3b35400000003000000030b30b003000dd0b5666566656665d6664442446567d67d676777677
002222000ffffff00022220000094000565000000009450033b3b3550000000400000003003b00030b000003555555555555555564222a965577775565766576
00eeee0000eeee0004eeee00000940006660000000094500033355500400000003000000030b00000300b000665666566656665664424446665ddd5665766576
004004000040040000000400000940000000000009545454003335030000400000003000000030000dd030b05555555555555555642222465555555555655565
feeeeee87bbbbbb3000440004f9f4fff7999a99994000049000000076776d776500000005666666600766500007665000007a90000000000000005d9007a4200
e8888882b333333100499400fffff9f49999979a44444444000000767667566565000000655115510750065007500650000a00000e82e82000555d5507a99420
e8811882b337733100444200ff4fffff99a9999904555550000007667667566566500000651555510650065006500000000aa900e788888205d6d5550a999940
e8866882b3366531004942009fff9ff99999799704500450000076667667566566650000511555517666666576666665000a0000e88888825d7ddd500a999940
e8877282b3355131004992004fffff9fa999997904500450000766667667566566665000655115117661666576636665000a00000888882056dddd500a999940
e8822182b331133100494200ff4fffff999a999904544450007666667667566566666500655551517661666576636665007aa9000088820055ddd5500ae99940
e8888882b333333100499200ff9ff9ff999997994455554407666666766756656666665065555151766666657666666500a00a00000820000555550007fe9420
822222223111111100042200f9ffff4f979999a994000049766666666552155666666665511111156555555565555555009aa900000000000055500000794200
00dddd0000dddd000022220050222205bb0bb0bb0b0bb0b00000bbb00000000009aaaa9000777700007777000000000000000000000000000076660000766600
0d7cc7d00d7cc7d0552882550528825003abba30b3abba3b000b1b1ba000bbb09a1aa1a907666670000666700301000006063300000033000702826007282060
d70cc07dd77cc77d22588522225885220bbbbbb00bbbbbb00a0bbbbbb00b1b1b9a5aa5a971166117a07766570301330066313830003138300602825006282050
d77cc77dd70cc07d271881722708807203baab3003baab30b00b3707b00bbbbb9aaaaaa9712662177a6666660031383063331330063313300066550000665500
dccccccddccccccd2888888228888882b003300b00033000b00bbb00b00b370709affa90066116606d66666600331330333130136331301307d75d6007d75d60
dcc11ccddcc11ccd28881882288188820b3bb3b00b3bb3b0bb0bbbb0bb0bb3309a9aa9a905666650d05661150331301311100000111000007d7dd5d67d7dd5d6
0dccccd00dceecd0028888299288882000bbbb00b0bbbb0b0bb0bbbbbbb0bbbba900009a00611600000666501110000010000000100000007d7dd5d57d7dd5d5
00dddd0000dddd0099222290092222990bb33bb000b33b0000bbbbb00bbbbbb09a9009a900566500006650001000000000000000000000000665565006655650
000000000000000900009999900a0000000000000000000000099000000990000000000008000080a00700b00000000000111100001111009999999907777700
00000000000909aa009999aa09000a90000900000900909000970000000079000aaaaa900000000007a00bba00010000011cc110011cc1109004040575666660
000000000000aaaa09a9aaaa00009000008aa800008aa8000999a900009a99907969696700880800077bba7b001c100001c77c1001c77c10944444450065d560
00000009090a9a9a099a9909a000000000a77a9009a77a00999a97900979a999159595908008e808b0b7aab001c7c10001c77c101c7777c19000400500666660
0000a09a00a9a9a999a997900090000009a77a0000a77a9097999a9999a9997909a50000008ee80000ba7ab001c7c10001c77c101c7777c19444444500655d60
0000099a09aa9a7799a970000a000000008aa800008aa80099aa79999997aa995a900000000888000b7b77ab01c7c10001c77c1001c77c109555555500666660
000099a70aa9a7779aa09000090000000000900009090090099a99900999a99095900000000000800ab0b7aa001c1000011cc110011cc1100005500000677777
0009aa779aaa97779aa900000000000000000000000000000099a900009a99000000000008008000ab0000a00001000000111100001111000506400500555550
05555555555555555555555055677655111c111c004aa40077777776777777767777777677777776555555555555555500000000000009009400004999999999
5566666666666666666666555655556511c111c144a77a447666666576666665776666557666666556665666666566650000000000009a909454444944444444
566767676767676767677665566776651c111c11aa7777aa76555565766776657676656576666665656665666656665600000000000009009455554905500550
56777777777777777777776556677665c111c1114aa77aa47656676576766565766756657666666575777577775777570000090000e00b009400004904500450
56777676767676767676776555677655111c111c04a77a4076566765767665657667566576666665757775777757775700909a900eae03009400004904500450
5676667666666666676776655655556511c111c14a7aa7a476577765766556657676656576666665656665666656665609a9090000e003009454444904500450
567767566666666675776665566776651c111c114aa44aa476666665766666657766665576666665566656666665666500900b0000b003009455554944444444
56766665555555555667766556677665c111c111aa4004aa65555555655555556555555565555555555555555555555500b00300003003009400004999999999
56677665555575555566765555555555000022222222000000022222222000000000000000000000000000000000000000000000000000000000999994000049
56776665565755665555555556677665002244444444220002244444444220000002222222220000000200000002000000000000000000000009444494000044
56677665565757676565565655555555002444444449420002444400149120000224444444442200000220200000000000000000000200000094400094000450
56776665575757777576755757777775022444444444442022444440014142000244444444494200000000000000000000282000000220200944000094404500
56677665575756766557675675555557022444411144412022444444421442002244444444444420000000000028880020898000000820229945400009445000
56776665565756666565565655677655022444400114012022444444241141002244444444444420022288002289880000898080002820009440540000944400
56677665565755665555555556776665012244440014012012244422444420002244444001444120289888002289982002888888028820009400054400099444
56776665555575555567665556677665012222244441242011222224444420001224444400140120889998200228988202288898289988009400004900009999
5677667555575555567766655677666500112224422122100112111299a090001222224444412420288999820288989822888822899998209400004999990000
56676756665575656577666556677665000111122411200000111011100000000112222422112210028999980889998829999820899999804450004944499000
56777667676575657667766555776655000011124444200000110011000000000011111244442100089999980999998289999980289999820045044900444900
566777777775757577777665755555570000111499a0900000110011000000000000101499a09000289997980999998208979982088999980004549900054490
5666767676757575676766655777777500011200110000000122001200000000000010199a999000299779920897799008997798089977980000449000540449
56666666666575656666666555555555000114400140000001144012400000000000112244442000289777920297779008977790089777920004490005400049
55666666665575656666665556677665000002490119000000024901290000000000111122220000029777920097779000977790029777924444900044000049
05555555555755555555555055555555000000229a9000000000249a900000000000000000000000008979800089798000897980008979809999000094000049
00ddd000000000000066600000660000060000000000000005544550d777777d0777000056666665000000000007d00000000000000000000001100000000000
0d666d0000666600066666600666506066500000006000005544445556666665077770006d6666d600d0000000766d000011100001111110011cc11000000000
d67666d00666666006666060056650000500000000000000454444545666666507777700611111160d600000076666d001ccc10011cccc1111c77c1100000000
d66666d00666666066666666005506600000000000000000455a9554111111550777777061111116d6644444000440001c777c101c7777c11c7777c100000000
dd666d500666665050666665600566650060066000000000411a911476d176d50777770061111116766499990009400001ccc1001c7777c11c7777c100000000
0dddd50005666550066655550066566500006650000000604445544465616560077770006111111607600000000940000011100011cccc1111c77c1100000000
00555000005555000555555006650550660065000000005044444444d650d650077700006111111600700000000940000000000001111110011cc11000000000
00000000000000000055000000500000650000000600000054444445000000000000000061111116000000000009400000000000000000000001100000000000
0000000bb000bb0bb000000000b000bb0bb00bbb0000bb0000bb000bb000bb0bb0000000000000000000000000000bb00bbb0001bb000bbb000bbb00bb0bb000
0000000bb000bb0bb00b0b000bbbb0bb0bb0bbbbb000bb000bb00000bb00bb0bb0000000000000000000000000000bb0bb0bb00bbb00bb0bb0bb0bb0bb0bb000
0000000bb000bb0bb0bbbbb0bb0000000bb0bb00000bb0000bb00000bb000bbb000bb00000000000000000000000bbb0bb0bb000bb00000bb0000bb0bb0bb000
0000000bb0000000000b0b000bbb000bbb000bb0b00000000bb00000bb00bbbbb0bbbb00000000bbbbb00000000bbb00bb0bb000bb000bbb0000bb000bbbb000
0000000bb000000000bbbbb0000bb0bb0000bb0bb00000000bb00000bb000bbb000bb0000bb000000000000000bbb000bb0bb000bb00bb0000000bb0000bb000
0000000000000000000b0b00bbbb00bb0bb0bbbbb00000000bb00000bb00bb0bb00000000bb000000000bb0000bb0000bb0bb000bb00bb0000bb0bb0000bb000
0000000bb00000000000000000b000bb0bb00bbb0000000000bb000bb000bb0bb0000000bb0000000000bb0000bb00000bbb000bbbb0bbbbb00bbb00000bb000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbb00bbb00bbbbb00bbb000bbb00000000000000000bb0000000bb00000bbb000bbb000bbb00bbbb000bbb00bbbb00bbbbb0bbbbb00bbb00bb0bb0bbbb0000
bb0bb0bb0bb0bb0bb0bb0bb0bb0bb00bb0000bb00000bb000000000bb000bb0bb0bb0bb0bb0bb0bb0bb0bb0bb0bb0bb0bb0bb0bb0bb0bb0bb0bb0bb00bb00000
bb0000bb0000000bb0bb0bb0bb0bb00bb0000bb0000bb000bbbbb000bb00000bb0bbbbb0bb0bb0bb0bb0bb0000bb0bb0bb0000bb0000bb0000bb0bb00bb00000
bbbb00bbbb0000bb000bbb000bbbb0000000000000bb0000000000000bb000bb00bb0bb0bbbbb0bbbb00bb0000bb0bb0bbbb00bbbb00bb0bb0bbbbb00bb00000
000bb0bb0bb00bb000bb0bb0000bb00bb0000bb0000bb000bbbbb000bb000bb000bbbb00bb0bb0bb0bb0bb0000bb0bb0bb0000bb0000bb0bb0bb0bb00bb00000
bb0bb0bb0bb00bb000bb0bb0bb0bb00bb0000bb00000bb000000000bb000000000bb0000bb0bb0bb0bb0bb0bb0bb0bb0bb0bb0bb0000bb0bb0bb0bb00bb00000
0bbb000bbb000bb0000bbb000bbb00000000bb0000000bb0000000bb00000bb0000bbb00bb0bb0bbbb000bbb00bbbb00bbbbb0bb00000bbbb0bb0bb0bbbb0000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00bbb0bb0bb0bb0000b000b0b00bb00bbb00bbbb000bbb00bbbb000bbb00bbbbb0bb0bb0bb0bb0bb0bb0bb0bb0bb0bb0bbbbb00bbb00000bb00bbb000bbb0000
000bb0bb0bb0bb0000bb0bb0bb0bb0bb0bb0bb0bb0bb0bb0bb0bb0bb0bb00bb000bb0bb0bb0bb0bb0bb0bb0bb0bb0bb0bb0bb00bb000000bb000bb00bb0bb000
000bb0bbbb00bb0000bbbbb0bbbbb0bb0bb0bb0bb0bb0bb0bb0bb0bb00000bb000bb0bb0bb0bb0bb0bb00bbb00bb0bb0000bb00bb00000bbb000bb0000000000
000bb0bbb000bb0000bbbbb0bbbbb0bb0bb0bbbb00bb0bb0bbbb000bbb000bb000bb0bb0bb0bb0bbbbb000b0000bbbb00bbb000bb0000bbb0000bb0000000000
000bb0bbbb00bb0000bb0bb0bbbbb0bb0bb0bb0000bbbbb0bb0bb0000bb00bb000bb0bb0bbbbb0bbbbb00bbb00000bb0bb00000bb000bbb00000bb0000000000
bb0bb0bb0bb0bb0bb0bb0bb0bb0bb0bb0bb0bb0000bbbb00bb0bb0bb0bb00bb000bb0bb00bbb00bb0bb0bb0bb0bb0bb0bb0bb00bb000bb000000bb0000000000
0bbb00bb0bb0bbbbb0bb0bb0bb00b00bbb00bb00000bbbb0bb0bb00bbb0000bb000bbb0000b000b000b0bb0bb00bbb00bbbbb00bbb00bb00000bbb0000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000bb000000000bb0000000000000bb00000000bbb00000000bb00000bb000000bb0bb0000bbb00000000000000000000000000000000000000000000000
00000000bb00000000bb0000000000000bb0000000bb0bb0000000bb0000000000000000bb00000bb00000000000000000000000000000000000000000000000
000000000bb00bbb00bbbb000bbb000bbbb00bbb00bb00000bbbb0bbbb00bbb00000bbb0bb0bb00bb000bbbb00bbbb000bbb00bbbb000bbbb0bbbb000bbbb000
000000000000000bb0bb0bb0bb0bb0bb0bb0bb0bb0bbbb00bb0bb0bb0bb00bb000000bb0bbbb000bb000bbbbb0bb0bb0bb0bb0bb0bb0bb0bb0bb0bb0bb000000
0000000000000bbbb0bb0bb0bb0000bb0bb0bbbbb0bb0000bb0bb0bb0bb00bb000000bb0bbb0000bb000bbbbb0bb0bb0bb0bb0bb0bb0bb0bb0bb00000bbb0000
000000000000bb0bb0bb0bb0bb0bb0bb0bb0bb0000bb00000bbbb0bb0bb00bb000000bb0bbbb000bb000bbbbb0bb0bb0bb0bb0bb0bb00bbbb0bb0000000bb000
bbbbb00000000bbbb0bbbb000bbb000bbbb00bbbb0bb0000000bb0bb0bb0bbbb00bb0bb0bb0bb0bbbb00bb0bb0bb0bb00bbb00bbbb00000bb0bb0000bbbb0000
000000000000000000000000000000000000000000000000bbbb000000000000000bbb00000000000000000000000000000000bb00000000bb00000000000000
00000000000000000000000000000000000000000000bb00000bb00bb0000bb0b0b0b0b000000000000000000000000000000000000000000000000000000000
0bb0000000000000000000000000000000000000000bb000000bb000bb00bbbbb00b0b0000000000000000000000000000000000000000000000000000000000
bbbb00bb0bb0bb0bb0bb0bb0bbbbb0bb0bb0bbbbb00bb00000bbb000bb0000bb00b0b0b000000000000000000000000000000000000000000000000000000000
0bb000bb0bb0bb0bb0bbbbb00bbb00bb0bb0000bb0bbb0000bbb0000bbb00000000b0b0000000000000000000000000000000000000000000000000000000000
0bb000bb0bb0bbbbb0bbbbb000b000bb0bb000bb000bb000bbb00000bb00000000b0b0b000000000000000000000000000000000000000000000000000000000
0bb000bb0bb00bbb00bb0bb00bbb000bbbb00bb0000bb000bb000000bb000000000b0b0000000000000000000000000000000000000000000000000000000000
00bb000bbbb000b000b000b0bb0bb0000bb0bbbbb000bb00bb00000bb000000000b0b0b000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000bbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
009700000000000000000000000000000000000d008080000000008080948c8090908f000080808080919300120a950b01010202030304040586070808080909000000000f0000001900000000008c0c8080808040000000000087870e0e80808080808000000000000000000000808080808080000000000000000000008080
9800000000001a80001400008000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
160091929393169091179494969a9d009c9e9891a018a1a39791199d1a9f9715934f9aa0a1a5ad00ac929900aa92b3b5abb3a6008796c5c6c796ff169000929394909194941895160019989f009c9215a000a4a55c5da9923098ad925c135c5ca594aaaab5b993a2a79fa7979da09ea1a2bac4c69216ff5f90917f0094959416
96945e94189998952c009b969d009f965e15990015166e919025b02a5f7f16165e3395a532a8b7b222c1b0b0b27fa3a5ab955ea3c91900309acc9417ab21a2d2c9ca6f5f1fd9941f5f7eff6e5f2500255f959697255e009b9c9d189c5e9a299c9f9d9c1b9a00399c33a6a0a6adae9b1b9b1a00b19c292db29bad17bcaeb8a6b4
1c291b1c1bc9c7c99b161cc0a615b4d0ab0016cacbc8c9dac815ff545400001b9495969490929a9b9b1b9900189c002da3939fa29217929e91a8a5a4ac9aaa002ca2aca1aea09299a4a4b29c9f30a9a8ac17bd9cb317ac23cccdcecdac90d2d3d31bff5490901693946f5f975f9154009c9c94009491159d9d94930090a40035
a5a716a9aa4ea4a19baab6a0b0b700309db9babdb5bfc0c2a4bebf15b01b1b1ccacdcbcaff5f90919292255f1697989998005e00169e9e97a09f00011ba1a116539900ad1da31b1c1bb39fa4001b15981b1e1b1d1ba200189c15adadc2c5c8006f5fc9cdc518c40015d3c4c7c9c4d319dad3c833add4da194fd4cdd4151ae6e9
d4ff161b1e1c1b941b93959516009b9c9d9d1b9a9c505125529c189b1b9e602e1d7044a69caaa27222519b609f9c1a60390022b8ba9c70a65ec19b19b39b507200c621b9b2a1006021ce00cc9f9a1700c4395e39b92d00e3a09dc45ed9da9497989698ff546054929392705197515290002100949f909b019e9400a69e9160a6
17928954a717a890b19ea7a6afb27052259200b4acb7915072a4abb7c19034a4a0bea1aab6abb4b26030b134d2a734a19699a09491939153e35392509772ff0000159091935e005e9293006e5f7f9092966f9e15926e7e00a29b5fa7979f155e19906fab9a989017b09aba9616905e1a18933693199695b1b79a192ab5c8ba00
c500c1002aceba1ac6be1a90d30017b25f5fc1b9cf931816e8e9e8e50016ff255f919125001b90925f255e000036299c009444a0005e9b1aa1939ca31c9ca65f7fa4a01c1ba05e25389b3200179cb59c32999b9ba46e94172594a6006f91b13425209c22aec4bccc7ebeb4b5a6bda4bbdeb6c41b98e5907e5e30b2eb5e5c5d97
e5ce006e7e5d5cff1b1b1c7e00006f90971c90151b949d9e0015a1a19c00809e299ea2a4941800399f94151c94a6b09fab94209dad9eab2525b69da425af9fb594b394bf4400bcc7009cbc00ccc1b8d3b0bc9791da99da15ff1b909192931b009697983898959896349d9a9c329d9718979ca4a91b1615adaeada41b1516acb4
b3ac9d90afaf16b9a89d36be96a6a9a7bfc596911c7f966e9491ff16909192931b1b009798999a9600809a9f009ca19718999e97a2a0a4a8aa399a16a998aeafb100b300a597169ab9a0bb98a7aabfaaaf93c693ff5454255f932529299293931b90002f9d00a0002da2a29b54a119a1aaa0a6abaaa9a01c9caeaead0015b4a1
ad164e16b900b6b9b0b6b0bfb3bfa1c7c800caa016cfd0cfff5454009217921696979690929b9c00183800159a9d92369ca291a49c94a892181b44441b301aa7a3002239b89b1892ad92220039c19dbf001b22221ba4ad94aa002ca1902323002332d5d5b69054d4dedfdedce2e3e2ff159091929390181a1898999a98959919
9b979c159ba499959f9a59aa18a89d99975986599aaea9ab96189da1a5a29ba8bba291bca623232929c39c54cb549494ff5490919293912396979897165497000100a0a19a9c23a1a6a115239ba5a015a7a6abafb2b1b2a7abacb544399b9ca03944a0ba002100161b90b2255fcbcbc754b5a7cecacb25a0d3cc1bff00001592
2594959625919015299c9d909025150016169c1ba71b9fa09121901b36b022aa2125a4ae22b8b89044a498aaa9aa00440089beaec1bbbdc1c0c800c6001b39b2cd255f5f7fc7cdce5d005e00d3da985d6f97e594ff2590919293908f8f389698979617969596a0a09da0258959a7a859a1a88925a9af2929a89faba7a0a79faf
aa8f9db8258fa8a1b595baa732a9b9c7c5aa90a3c2c21794d292ff255f919293945e150098999a99155e9b9f30999e98a19f4ea29f2d2faa9b5e16af99905f7f2f9a5e8900809a292c5e2db6af16b1917eb5a89baaac9916a3a59fcba3cf9b16b294d691ff5f5f2516259091935f7f16545416009e00229e3800a3259e549f9e
a1a0ac00a6a89f6ea6a99e5e00b0b5209490252f00b6b06e5f7e9e2f2d2fb6bfb7b521a9c65ebec09e6f91cec9c015a79f34aebdca54d9cba929290048d89ee4a9c27f6e7e18545f15bb15957e156ff79bff549091929354001f2e0022009b9b179c9c97223922189fa69698a79ca59b972ea99c4ea79700150001aaa0b09db9
b4a7ac009ea8c1b99fbe001bc8aa1bcccdc9cece5c5d5cd25ccfd3d4d8ff5490919293540000949895969b9c949c00199ca19296189f159d90a19f019f979aaeae909ca89fabb3a59fa69bb89babb415901bb196151516c8541bc6cccdc8cf54ff54909192939027969798970000541b1f9fa0a11f1b9b9d9f56a2a0a49c9ea9
1fa8a3a5ad9f1b1db31f1ea5179b25bd2abd259bc254c2c5c51ac39b19c6c6bbc4c2bb0018ccac1bd6d7d8d8545d5cdd5cdcdedfe0ff1b1b009293949290915993999b009b989da0929c999a59a6a7a8a19ba8a69dad94acacaaaeabb2a5b1a7b3b1aea1a2b5b2991badb8b997c61b89c797ff1b1b00001b1c90949095969192
00360059002d59961c5151529c9ca02d9b00a672999b59a0ad515b92b3a9a3ada893a49aa960a9aa005a1b289c62a6cb5191b4adb79fb99f92909ca8cfb1969c60a0a0c3c31c70cce4a65299ff1b1b1c90919395921b2c1b009b9c9d9b91229a9e3e9e90a19b599da99d1b221c9eaa9fa200a4b09c919cab00bab7b3b69ba490
bfb092bbb0bc00c2c6bfa99359599097d195ff1b909192939000969798981c1b003b999f009c9f59599f9598a4a49d98a297a9a599adaeb0acb2a097a7989ea6b6b7a1bdb791beb81bff1b1c1b9293920096911c1c969b9c9b911b9da19693a29c94a0a53e00542e1f39a8a5abadaf9baaa1acaeb0a5b8b4005052a2b825a860
60c1541f2c95c5b1a390a7949f92ff1b1c1b92939200969191969a9a259c00959b9a5ea29f1ba10059006f5f2a5f7e9f9a3ba7a1a6a72d9aa996a0a9b796bd003ea5b3b3a09c5fc7c87fc234a896a9b900a3c59bd0d1a59194939a93ff1b901b1c91949554979899999322221b9d9f9e9d9e549300a7a8a9a722a51c1f1f002d
b10059b4aba5002aa8b2b54fb61badafb3bca9ac1c1caaa92f002fc6a1cfa0cc00c0939a9822cbcda5c0d65422a8ce9594a8931cff1c1b911b909292945498299898009d9e002f9b9a9c9f9e2f2598a854a5a5259daeacadafb1b200b0b4b3b6b89eaab7b825a829bba0c0c0c32f969595941bff1c1b911b9092399194549929
9999001b441b00a22f9c9b9da2a8a3259aa7a9a925a2b0aeb3b221ae36b4b1003bb3af2222b2bda8ab54c1c20025ab29bbc72fc9c9c7a3929492d392ff1c1b911b9092929454989998009c9d002f9a999c3e9e9f2598a754a5a525222225ababb000b3b19db3b5b6b4aeb9b6a9bdb125a99c3fb62fc2c2ba9c2f969595941bff
1b90901c919493900098999a9b1c9b9e9a1b98961b93a3a100a71b6e5facad5f7fa9981b5e1fb5b61f5eb1a8b4901e90b8ba1cb49bc0b2b27e9f6f9d00cb9f9ea7ce9b94d3a690ff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010103070200060109010401060101030501010601040502010301010101010101010b120a020101160901090c010d01010b0e0c0101010d110f01100e010f0101010101010e090101010101010101150101140101011817010a16010101011601011a1d1c0101191b01011c011a1b1e011919011e011c011f1d2001011e
2101010122010101230101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000800a3d0af409b5095d090f09ca0893084d08f307b60761071e07d20665061b06d5057c053105f004990455041b04d90388031f03bf0264020202a50163011b01cb0077003b000000
__sfx__
013d00200a6100f611156111c6112c6113161131611236111b6110d6110d6110c6110b6110a621096110861107611096110b6110161106611076110f611186111c61125611256111c61116611126110d61109611
0108080a1307014070180701806018050180401803018020180141801500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010b0809245701d5701c5701c5601c5501c5401c5301c5201c5100050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
010200280c31500000000000000000000000000f2250000000000000000c3000c415000000000000000000000c3000000000000000000c30000000000000741500000000000c2150000000000000000c30000000
010300280000000000246250000000000000000000000000246150000000000000000c30018625000000000018000180002430018000180001800024300180001800018000000000000000000000000000000000
011000010017000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01090004180701a07015070160700c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c000000000000000000000000000000000
0109000418070160701307011070295052650529505265052d505295052950526505225051f5051d505215052e5052b50528505245052d5052d5052850528505265052e5052b5052850524505215051d50521505
0114000020734200351c7341c0351973419535157343952520734200351c7341c0351953219035147341503121734210351c7341c0261973419035237341703521734395251c7341c03519734195351773717035
011400000c043090552072409055246151972315555090550c053090651972309565207242461509065155650c053060652072406065246151672306065125650c05306065167230656520724246150606515555
011400000c053021651e7240206524615197450e7650c05302165020651e7341e7350256524615020650e56501165010651e7240c05324615167230b0450d0650c05301165197440b56520724246150106515555
0114000020724200251c7241c02525742287421572439525207242a7422c7412c7322c72219025147242a74228742287451c7341e7421e7421e735237241702521724395251c7341c03519734195351773617035
0014000020724200251c7241c02525742287421572439525207242a7422c7412c7322c72219025147242f7422d7422d7452d734217422174221735237241702521724395251c7341c03519734195351773617035
010e000005455054553f52511435111250f4350c43511125034550345511125182551b255182551d2551112501455014552025511125111252025511125202550345520255224552325522455202461d4551b255
010e00000c0530c4451112518455306251425511255054450c0530a4353f52513435306251343518435054450c053111251b4353f525306251b4353f5251b4350c0331b4451d2451e445306251d2451844516245
010e00000145520255224552325522445202551d45503455034050345503455182551b455182551d455111250045520255224552325522455202461d4551b255014550145511125182551b455182551d45511125
010e00000c0531b4451d2451e445306251d245184450c05317200131253f52513435306251343518435014450c0431b4451d2451e445306251d245184451624511125111253f5251343530625134351843500455
010e0000004550045520455111251d125204551d1252912501455014552c455111251d1252c4551d12529125034552c2552e4552f2552e4552c2552945503455044552c2552e4552f2552e4552c246294551b221
010e00000c0530c0531b4551b225306251b4551b2250f4250c0530c05327455272253062527455272251b4250c0531b4451d2451e445306251d245184450c0530c0531b4451d2451e445306251d2451844500455
010d00000c0530445504255134453f6150445513245044550c0531344513245044553f6150445513245134450c0530445504255134453f6150445513245044550c0531344513245044553f615044551324513445
010d00000c0530045500255104453f6150045510245004550c0530044500245104553f6150045510245104450c0530045500255104453f6150045510245004550c0531044510245004553f615004551024500455
010d00000c0530245502255124453f6150245512245024550c0531244512245024553f6150245502255124450c0530245502255124453f6150245512245024550c0530244512245024553f615124550224512445
010d00002b5552a4452823523555214451f2351e5551c4452b235235552a445232352d5552b4452a2352b555284452a235285552644523235215551f4451c2351a555174451e2351a5551c4451e2351f55523235
010d000028555234452d2352b5552a4452b2352f55532245395303725536540374353b2503954537430342553654034235325552f2402d5352b2502a4452b530284552624623530214551f24023535284302a245
010d00002b5552a45528255235552b5452a44528545235452b5352a03528535235352b0352a03528735237352b0352a03528735237351f7251e7251c725177251f7151e7151c715177151371512715107150b715
011100000c3430035500345003353c6150a3300a4320a3320c3430335503345033353c6151333013432133320c3430735507345073353c6151633016432163320c3430335503345033353c6151b3301b4321b332
01110000162251b425222253751227425375122b5112e2251b4352b2402944027240224471f440244422443224422244253a512222253a523274252e2253a425162351b4352e4302e23222431222302243222232
011100000c3430535505345053353c6150f3301f4260f3320c3430335503345033353c6151332616325133320c3430735507345073353c6151633026426163320c3430335503345033353c6150f3261b3150f322
011100000f22522425272253f51227425375122b5112e2252724027232272222444024430244222b511224422b4422b23220241202322023220420204153a425162351b4351f4401f4321f2201d4401d4321d222
011100001d22522425272253f51227425375122b5112e225322403323133222304403043030422375112e44237442372322c2412c2322c2222c4202c4153a425162351b4352b4402b4322b220224402243222222
011100001f2401f4301f2201f21527425375122b5112e225162251b5112e2253a5122b425375122b5112e225162251b425225133021033410375223341027221162251b425222253751227425373112b3112e325
01110000182251f511242233c5122b425335122b5112e225162251b5112e2253a5122b425375122b5112e225162251b425225133021033410375223341027221162251b425222253751227425373112b3112e325
007800000c8410c8410c8400c8400c8400c8400c8400c8400c8400c8400c8400c8400c8400c8400c8400c84018841188401884018840188401884018840188402483124830248302483024830248302483024830
01780000269542694026930185351870007525075240752507534000002495424940249301d5241d7000c5250c5242952500000000002b525000001d5241d5250a5440a5450a5440a5201a7341a7350a0350a024
017800000072400735007440075500744007350072400715007340072500000057440575505744057350572405735057440575503744037350372403735037440375503744037350372403735037440373503704
017800000a0041f734219442194224a5424a5224a45265351a5341a5350000026934269421ba541ba501ba550c5340c5450c5540c555000001f9541f9501f955225251f5341f52522a2022a3222a452b7342b725
012000000dd650dd550dd450dd351075510745107351072500c5517d5517d4517d3517d2517d2510755107450dd650dd550dd450dd351075510745107351072500c5417d5517d4517d3517d2517d250dd250dd35
011d0c201072519d5519d4519d3519d251005510045100351002517d550f7350f7350f7250f72510725107251072519d3519d3519d2519d250b0250b0350b7350b0250b7250b72517d3517d350f7350f7350f725
0120000012d6512d5512d4512d351575515745157351572500c5510d5510d4510d3510d2510d25157551574512d6512d5512d4512d35157551574500c54157351572519d5519d4519d3519d2519d250dd250dd35
011d0c20107251ed351ed351ed351ed251503515035150251502517d35147351472514725147251572515725157251ed351ed351ed251ed2515025150351573515025157251572519d3519d350f7350f7350f725
0120000019d5519d450dd3501d551405014040147321472223d3523d450bd350bd551505015040157321572219d5519d450dd3501d551705019040197321972223d3523d450bd350bd551c0501e0401e7321e722
012000001ed551ed4512d3506d552105021040217322172228d4528d3528d2520050200521e0401e7321e7221ed551ed4512d3506d552105021040257322572228d5528d4528d3528d251c0401e0301e7221e722
00020000016100d6111c61131611146110c61108611056110261501601016050c600116001a600006000060000600006000060000600006000060000600006000000000000000000000000000000000000000000
000c00000c34300300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
001000001c1431c1331c1231c1131b1031a1030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00040000260452b035300253000500703007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703007030070300703
000400002152526535005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000100200a4133b2110a1133b4110b013302110b313302210a1133b2110a4133b2110a0133b2210a1133b211091133a211091133a6110a4133b2210a1133b2110a7133b2210a3133b2110a1133b2110a6133b411
000300000c343236450933520621063311b6210432116611023210f611013110a6110361104600036000260001600016000460003600026000160001600016000160004600036000260001600016000160001600
000200000c475152740f474186651646515264114540e6550d4550b24408445066440443502234014340062500424002240041500615000040000400004000040000400004000040000400004000040000400004
0114000020734200351c7341c0351973419535157343952520734200351c7341c0351953219035147341503121734210351c7341c0261973419035237341703521734395251c7341c03519734195351773717035
011400000c043090552072409055246151972315555090550c053090651972309565207242461509065155650c053060652072406065246151672306065125650c05306065167230656520724246150606515555
011400000c053021651e7240206524615197450e7650c05302165020651e7341e7350256524615020650e56501165010651e7240c05324615167230b0450d0650c05301165197440b56520724246150106515555
0114000020724200251c7241c02525742287421572439525207242a7422c7412c7322c72219025147242a74228742287451c7341e7421e7421e735237241702521724395251c7341c03519734195351773617035
0014000020724200251c7241c02525742287421572439525207242a7422c7412c7322c72219025147242f7422d7422d7452d734217422174221735237241702521724395251c7341c03519734195351773617035
000900000864514645070450654502204006050550005500266002460023600216001f6001d6001c6001a60018600176001660015600146000030000300003000030000300003000030000300003000030000300
000600001c36311000103331031310303107031070513005306041070310705000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00030000180251f535260452a55512604176011b6011f601226012560128601296012b601296012760124601216011f6011c601186011560113601116010f6010e60500500005000050000500005000050000500
00020000187551a5551c7551554517745195451273514535167350f52511725135250c7150e515107150060000600006000060000600006000060000600006000060000600006000060000600006000060000600
000100000c1500e0511105114051170511705014051120510f0510c15100100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 08 09 43 44
00 08 0a 43 44
00 0b 09 43 44
00 0c 0a 43 44
00 0b 09 43 44
02 0c 0a 43 44
01 0d 0e 43 44
00 0d 0e 43 44
00 0d 0e 43 44
00 0d 0e 43 44
00 0f 10 43 44
00 0f 10 43 44
02 11 12 43 44
01 13 42 43 44
00 14 42 43 44
00 15 42 43 44
00 13 42 43 44
00 13 16 43 44
00 14 16 43 44
00 15 17 43 44
02 13 18 43 44
00 19 42 43 44
00 19 42 43 44
01 19 1a 43 44
00 19 1a 43 44
00 1b 1c 43 44
00 1b 1d 43 44
00 19 1e 43 44
02 19 1f 43 44
03 20 21 22 23
01 24 25 43 44
00 24 25 43 44
00 26 27 43 44
00 24 28 43 44
00 24 28 43 44
02 26 29 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
