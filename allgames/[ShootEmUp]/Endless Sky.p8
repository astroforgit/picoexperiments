pico-8 cartridge // http://www.pico-8.com
version 7
__lua__



k_title_mode = 1
k_flight_mode = 2
k_wall_cast_mode = 3
k_level_select = 4
k_warp_mode=5
k_game_over_mode=6

game_mode=k_title_mode

---------------------------------------------------------flight_code--------------------------
camera_x = 64
camera_y = 10
camera_z = 64
f=80 -- focal length
x_scale=2
--z_scale=2
--z_scale = 2

floor_y=0

shift_h=0

k_fast=1
k_slow=2
render_mode=k_fast
h_step = 4
v_step = 1

camera_angle = .25

rotation_speed =.01


player={}

sprite_list={}


step_size = 1

cur_level = 0

moving=false

screen_center_x=64
screen_center_y=64
screen_height=112
screen_width=120
screen_start_x=8
screen_start_y=75

ship_shadow_y=300




frame_num=0


function clear_actors()
	k_ring_type=1
	k_building_type=2
	k_shot_type=3
	k_enemy_type=4
	k_turret_type=5
	k_diamond_type=5.1
	k_light_bulb_type=5.2
	k_flotsam_type=7
	k_zither_type=7.1
	k_bruiser_type=7.2
	k_particle_type=6
	k_scenery_type=8
	k_player_type=9
	actor_list={}
	shot_list={}
	enemy_list={}
	building_list={}
	particle_list={}
	scenery_list={}
end	

function new_actor(x,y,z,index,type,width,height,scale,flip)
	a={}
	a.x=x
	a.y=y
	a.z=z
	a.h=1
	a.vx=0
	a.vy=0
	a.vz=0
	a.health=100
	if(scale==nil) then a.scale=1 else a.scale=scale end
	a.index=index
	if(width==nil) then a.width=16 else a.width=width end
	if(height==nil) then a.height=16 else a.height=height end
	if(flip==nil) then a.flip=false else a.flip=flip end
	a.type=type
	add(actor_list,a)
	return a
end

k_player_shot=11
k_enemy_shot=10
function new_shot(x,y,z,vx,vy,vz,index)

	

	the_shot=new_actor(x,y,z,index,k_shot_type,8,8,scale)
	
	the_shot.vx=vx
	the_shot.vy=vy
	the_shot.vz=vz
	
	--if(index==k_enemy_shot)then
	--	
	--	the_shot.vx=(player.x-x)/dist*3
	--	the_shot.vy=(player.y-y)/dist*3
	--	the_shot.vz=(player.z-z)/dist*3
	--end
	add(shot_list,the_shot)
	return the_shot
	--the_shot.vz=vz
end

function unit_vector(x1,y1,z1,x2,y2,z2)
	x1/=100
	y1/=100
	z1/=100
	x2/=100
	y2/=100
	z2/=100

	local dist=sqrt((x2-x1)^2+(y2-y1)^2+(z2-z1)^2)
	dist=max(.1,dist)

	local x=(x2-x1)/dist
	local y=(y2-y1)/dist
	local z=(z2-z1)/dist
	return x,y,z
end

function new_turret(x,y,z)
	the_turret=new_actor(x,y,z,41,k_turret_type,8,16,1.5)
	the_turret.health=30
	add(enemy_list,the_turret)
end

function new_diamond(x,y,z)
	the_turret=new_actor(x,y,z,40,k_diamond_type,8,16,1.5)
	the_turret.health=30
	add(enemy_list,the_turret)
end

function new_light_bulb(x,y,z)
	the_turret=new_actor(x,y,z,38,k_light_bulb_type,16,16,1.5)
	the_turret.health=30
	add(enemy_list,the_turret)
end




function new_flotsam(x,y,z)
	the_flotsam=new_actor(x,y,z,43,k_flotsam_type,16,8,1)
	the_flotsam.health=10
	add(enemy_list,the_flotsam)
end

function new_zither(x,y,z)
	the_zither=new_actor(x,y,z,59,k_zither_type,16,8,1)
	the_zither.health=20
	add(enemy_list,the_zither)
end

function new_bruiser(x,y,z)
	the_bruiser=new_actor(x,y,z,96,k_bruiser_type,32,16,1)
	the_bruiser.health=60
	add(enemy_list,the_bruiser)
end

function new_scenery(x,y,z,index)
	the_scenery=new_actor(x,y,z,index,k_scenery_type,16,16,1)
	add(scenery_list,the_scenery)
end

function new_building(x,y,z,index,width,height)
	the_building=new_actor(x,y,z,index,k_building_type,width,height,2)
	add(building_list,the_building)
end

function new_particle(x,y,z,index,life)
	the_particle=new_actor(x,y,z,index,k_particle_type,8,8,1)
	the_particle.life=life
	add(particle_list,the_particle)
end

function draw_actor(actor)


			actor.h =draw_sprite_3d(actor.x,actor.y,actor.z,actor.index,actor.width,actor.height,actor.flip,actor.scale)
		

		


	
end

function draw_actors()
	for actor in all(actor_list) do
		draw_actor(actor)
		
		if( (actor.x-player.x)/x_scale>k_world_width )actor.x-=k_world_width*x_scale*2
		if( (actor.x-player.x)/x_scale<-k_world_width )actor.x+=k_world_width*x_scale*2
		if( (actor.z-player.z)/x_scale>k_world_width )actor.z-=k_world_width*x_scale*2
		if( (actor.z-player.z)/x_scale<-k_world_width )actor.z+=k_world_width*x_scale*2
		
	end
end

function sort_actors(a)
  for i=1,#a do
     j = i
    while j > 1 and a[j-1].h > a[j].h do
      a[j],a[j-1] = a[j-1],a[j]
      j = j - 1
    end
  end
end

function update_actors()
	for shot in all(shot_list) do
	
		shot.x+=shot.vx
		shot.y+=shot.vy
		shot.z+=shot.vz
	
		
			dist=(abs(shot.x-player.x)+abs(shot.y-player.y)+abs(shot.z-player.z))
			if(dist>300)then
				del(actor_list,shot)
				del(shot_list,shot)
				return false
			end
			
			if(shot.index!=k_player_shot)then
				--c,h=get_map_pix(x,y) 
				--if(shot.y+2<h)del(actor_list,shot)del(shot_list,shot) return false
				if(dist<6)then
					del(actor_list,shot)
					del(shot_list,shot)
					new_particle(shot.x,shot.y,shot.z,12,2)
					player.health-=5
					sfx(0,-1)
					return false
				end
			end
			
			if(shot.index==k_player_shot)then
				--c,h=get_map_pix(x,y) 
				--if(shot.y+2<h)del(actor_list,shot)del(shot_list,shot) return false
				for enemy in all(enemy_list) do
				
				
					dist=(abs(shot.x-enemy.x)+abs(shot.y-enemy.y)+abs(shot.z-enemy.z))
					if(dist<12)then
						enemy.health-=10
						del(actor_list,shot)
						del(shot_list,shot)
						new_particle(shot.x,shot.y,shot.z,12,2)
						sfx(1,-1)
					end
				end
			end
	end
	
	for enemy in all(enemy_list) do
		
		dist=(abs(player.x-enemy.x)+abs(player.y-enemy.y)+abs(player.z-enemy.z))
		
		if(dist<150)then
		
			enemy.x+=enemy.vx
			enemy.y+=enemy.vy
			enemy.z+=enemy.vz
			
			
		
			if(enemy.type==k_turret_type)then
				if(cur_frame%30==0)then
					vx,vy,vz = unit_vector(enemy.x,enemy.y+2,enemy.z,player.x,player.y,player.z)
					new_shot(enemy.x,enemy.y+2,enemy.z,vx*1.5,vy*1.5,vz*1.5,10)
					sfx(2,-1)
				end
			end
			if(enemy.type==k_diamond_type)then
				if(cur_frame%50==0 or cur_frame%52==0 or cur_frame%54==0)then
					vx,vy,vz = unit_vector(enemy.x,enemy.y+2,enemy.z,player.x,player.y,player.z)
					new_shot(enemy.x,enemy.y+2,enemy.z,vx*1.5,vy*1.5,vz*1.5,27)
					sfx(2,-1)
				end
			end
			if(enemy.type==k_light_bulb_type)then
				if(cur_frame%40==0 or cur_frame%41==0 or cur_frame%42==0)then
					vx,vy,vz = unit_vector(enemy.x,enemy.y+2,enemy.z+rnd(20)-10,player.x+rnd(20)-10,player.y+rnd(20)-10,player.z)
					new_shot(enemy.x,enemy.y+2,enemy.z,vx*1,vy*1,vz*1,26)
					sfx(2,-1)
				end
			end
			
			if(enemy.type==k_flotsam_type)then
				if(cur_frame%10==0)then
					x,y,z = unit_vector(enemy.x,enemy.y,enemy.z,player.x+rnd(80)-40,player.y+rnd(80)-40,player.z+rnd(80)-40)
					enemy.vx=x*1
					enemy.vy=y*1
					enemy.vz=z*1
				end
			end
			
			if(enemy.type==k_zither_type)then
					if(cur_frame%5==0)then
					x,y,z = unit_vector(enemy.x,enemy.y,enemy.z,player.x+player.dv_x*13+rnd(5)-2.5,player.y+rnd(5)-2.5,player.z+player.dv_z*13+rnd(5)-2.5)
					enemy.vx=x*.75
					enemy.vy=y*.75
					enemy.vz=z*.75
					end
					
					if(dist<20 and cur_frame%10==0)then
						vx,vy,vz = unit_vector(enemy.x,enemy.y,enemy.z,player.x,player.y,player.z)
						new_shot(enemy.x,enemy.y,enemy.z,vx,vy,vz,27)
						sfx(3,-1)
					end	
				
			end
			
			if(enemy.type==k_bruiser_type)then
					if(cur_frame%5==0)then
					x,y,z = unit_vector(enemy.x,enemy.y,enemy.z,player.x+player.dv_x*13+rnd(5)-2.5,player.y+rnd(5)-2.5,player.z+player.dv_z*13+rnd(5)-2.5)
					enemy.vx=x*.5
					enemy.vy=y*.5
					enemy.vz=z*.5
					end
					
					if(dist<25 and cur_frame%12==0)then
						
						
						off_x=-sin(player.angle+.25)*4.5
						off_z=cos(player.angle+.25)*4.5
						
						vx,vy,vz = unit_vector(enemy.x+off_x,enemy.y,enemy.z+off_z,player.x,player.y,player.z)
						new_shot(enemy.x+off_x,enemy.y,enemy.z+off_z,vx*1,vy*1,vz*1,27)
						vx,vy,vz = unit_vector(enemy.x-off_x,enemy.y,enemy.z-off_z,player.x,player.y,player.z)
						new_shot(enemy.x-off_x,enemy.y,enemy.z-off_z,vx*1,vy*1,vz*1,27)
						sfx(3,-1)
					end	
				
			end
			
			
			if(enemy.health<=0)then
				del(enemy_list,enemy)
				del(actor_list,enemy)
				new_particle(enemy.x,enemy.y,enemy.z,12,3)
				sfx(4,-1)
			end
		end
	end
	
	for building in all(building_list) do
		dist=(abs(building.x-player.x)+abs(building.y-player.y)+abs(building.z-player.z))
		--if(dist<12)then
		--	game_mode = k_wall_cast_mode
		--	
		--end
	end
	
	for particle in all(particle_list) do
		if(particle.life!=-1)then --permanent particle
			particle.life-=1
			if(particle.life==0)then
				del(particle_list,particle)
				del(actor_list,particle)
			end
		end
	end
end


k_world_width=150
k_world_height=150
world_map={}
world_color_map={}


function init_world_values(seed)
	srand(seed)
	map_smoothness=flr(rnd(5))+2
	map_color=flr(rnd(15))
	water_color=flr(rnd(15))
	sky_color=flr(rnd(15))
	map_freq=flr(rnd(40))+10
	map_exp=rnd(.3)+2
	
	
	

end

name_a={"deco","meno","centi","proximus ","fa","ne","ho","ur ","maginar ","lano ","epsilon ","ga","kli","kano","kato","neco"}
name_b={"mi","fla","klo","ri","paxe","ba","ra","taru","rexo","ne","vi","kriso"}
name_c={"n","ro","dian","p","k","rian","rn","st"," ceti"," vi"," ii"," iii", " iv"}
function rand_select(list)
	return  list[flr(rnd(#list))+1]
end

function create_name(seed)
	srand(seed)

	name_string=""
	name_string=name_string..rand_select(name_a)..rand_select(name_b)..rand_select(name_c)
	

	return name_string
	
end

function init_world_map(seed)
	cls()
	world_name = create_name(seed)
	
	init_world_values(seed)
	
	
	
	world_map=new_map(k_world_width,k_world_height)
	world_color_map=new_map(k_world_width,k_world_height)
	
	local noise_base = new_map(map_freq,map_freq)
	noise_map(noise_base,30)
	
	smooth_map(noise_base,1,map_smoothness)
	
	zoom_map(noise_base,world_map)
	
	exp_map(world_map,map_exp) --2

	--smooth_map(world_map,1,1)
	--smooth_map(world_color_map,1,10)

	
	
	----smooth_map(world_color_map,2)
	----

	
	clamp_map(world_map,-20,30)
	
	
	
	
	shade_map(world_map,world_color_map,map_color)
	
	--draw border lines
	--for i=1,#world_color_map do
	--	world_color_map[i][1]=8
	--end	
	--for i=1,#world_color_map[1] do
	--	world_color_map[1][i]=11
	--end
	
	clip_map(world_map,2,40)
	
	h=300
	while(h>3)do
		x=rnd(k_world_width*x_scale*2)-k_world_width*x_scale
		z=rnd(k_world_width*x_scale*2)-k_world_width*x_scale
		c,h=get_map_pix(x,z)
	end
	
	clear_actors()
	player=new_player(x,h+10,z)
	init_actors(seed)
	camera_angle=player.angle
end

function init_actors(seed)
	srand(seed)
	flyer_count = flr(rnd(5))+1
	turret_count = flr(rnd(5))+1
		--set flyer_type
	

	
	t=flr(rnd(3))
	for i=1,turret_count do
		x=rnd(k_world_width*x_scale*2)-k_world_width*x_scale
		z=rnd(k_world_width*x_scale*2)-k_world_width*x_scale
		c,h=get_map_pix(x,z)	
		
		if(t==0) new_turret(x,h+2,z) 
		if(t==1) new_diamond(x,h+2,z)
		if(t==2) new_light_bulb(x,h+2,z)
		


	end
	
	t=flr(rnd(3))
	for i=1,flyer_count do
		x=rnd(k_world_width*x_scale*2)-k_world_width*x_scale
		z=rnd(k_world_width*x_scale*2)-k_world_width*x_scale
		c,h=get_map_pix(x,z)	
		
		if(t==0) new_flotsam(x,h+2,z) 
		if(t==1) new_zither(x,h+10,z)
		if(t==2) new_bruiser(x,h+10,z)
		

		
	end
	
	t=flr(rnd(4))
	if(t==0)scenery=13
	if(t==1)scenery=45
	if(t==2)scenery=8
	if(t==3)scenery=36
	for i=0,10 do
		x=rnd(k_world_width*x_scale*2)-k_world_width*x_scale
		z=rnd(k_world_width*x_scale*2)-k_world_width*x_scale
		c,h=get_map_pix(x,z)
		
		new_scenery(x,h+2,z,scenery)
		
	end
	
	h=300
	dist=200
	while(h>3 and dist>15)do
		x=rnd(k_world_width*x_scale*2)-k_world_width*x_scale
		z=rnd(k_world_width*x_scale*2)-k_world_width*x_scale
		c,h=get_map_pix(x,z)
		dist=(abs(x-player.x)+abs(h-player.y)+abs(z-player.z))
	end
	new_building(x,h+4,z,32,32,16)
end

color_list=	{{0,1,1,5,13},
			 {0,1,13,13,12},
			 {0,2,2,13,13},
			 {1,1,3,11,10},
			 {1,2,4,4,15},
			 {0,1,5,13,7},
			 {1,5,6,6,7},
			 {5,6,7,7,7},
			 {2,2,8,14,15},
			 {2,4,9,9,15},
			 {4,9,10,7,7},
			 {1,3,11,10,7},
			 {5,13,12,6,7},
			 {1,5,13,6,7},
			 {2,2,14,15,7},
			 {4,9,15,7,7}}

function shade_lookup(color,value)
	local value=flr(value*5+.5)
	local value=mid(1,value,5)
	local color=mid(0,color,15)
	return color_list[color+1][value]
	
end
			 
function shade_map(height_map,dest_map,color)
	for i=1,#height_map do
		for j=1,#height_map do
			
			slope_x,slope_y=gradient_map(height_map,i,j)
			
			
			c=shade_lookup(color,slope_x/2+.2+ (1/max(slope_x,.1))*.005)
			if(height_map[i][j]<1) c=water_color
			
			--if(c==9) c=12
			
			dest_map[i][j]=c
			
			
		end
	end
end

function new_map(width,height)
	temp={}
	for i=1,width do
			temp[i]={}
		for j=1,height do

			temp[i][j]=0
		end
	end
	return temp
end


function noise_map(the_map,amplitude)
	for i=1,#the_map do
		for j=1,#the_map do
			v=(rnd(amplitude))
			the_map[i][j]+=v-amplitude/2
			
			
		end
	end
end

function smooth_map(the_map,smoothness,cycles)

	local new_map={}
	
	for k=1,cycles do
	
		for i=1,#the_map do
			new_map[i]={}
			for j=1,#the_map[i] do
				local c=0
				local v=0
				
				--c=(the_map[i][j]+the_map[i+1][j]+the_map[i+1][j+1]+the_map[i][j+1])/4
				--new_map[i][j]=c
				
				for ii=-smoothness,smoothness do
					for jj=-smoothness,smoothness do
						x=(i+ii)%#the_map+1
						y=(j+jj)%#the_map+1
						
						if(jj!=0 or ii!=0)then
							q=(jj^2+ii^2)
							c+=the_map[x][y]/q
							v+=1/q
							--c+=the_map[x][y]
							--v+=1
						else
							c+=the_map[x][y]/smoothness
							v+=1/smoothness
						end
						
						
						
					end
					
					
				end
				c/=v
				new_map[i][j]=c
			end
		end
		
		for i=1,#the_map do
			for j=1,#the_map do
				the_map[i][j]=new_map[i][j]
			end
		end
	
	end

end

function lerp_map(the_map,x,y)

	

	local int_x=flr(x)
	local int_y=flr(y)
	
	int_x=(int_x-1)%#the_map+1
	int_y=(int_y-1)%#the_map[1]+1
	
	local frac_x=1-(x-flr(x))
	local frac_y=1-(y-flr(y))
	
	
	
	local int_x2=int_x%#the_map+1
	local int_y2=int_y%#the_map[1]+1	
	
	local val=0
	
	val+=frac_x*frac_y*the_map[int_x][int_y]
	val+= (1-frac_x)*frac_y*the_map[int_x2][int_y]
	val+=frac_x*(1-frac_y)*the_map[int_x][int_y2]
	val+=(1-frac_x)*(1-frac_y)*the_map[int_x2][int_y2]
	
	return val
end

function gradient_map(the_map,x,y)

	

	local int_x=flr(x)
	local int_y=flr(y)
	
	local int_x=(int_x-1)%#the_map+1
	local int_y=(int_y-1)%#the_map[1]+1
	
	
	local int_x2=int_x%#the_map+1
	local int_y2=int_y%#the_map[1]+1	
	
	

	
	local slope_x = the_map[int_x2][int_y]-the_map[int_x][int_y]
	local slope_y = the_map[int_x][int_y2]-the_map[int_x][int_y]
	
	return slope_x,slope_y
	
end

function zoom_map(source_map,target_map)
--interpolate resize the source map into the target map

	local x_scale=#target_map/#source_map
	local y_scale=#target_map[1]/#source_map[1]
	
	for i=1,#target_map do
		for j=1,#target_map do
			--c=the_map[i][j]
			local c=lerp_map(source_map,i/x_scale+1,j/y_scale+1)
			target_map[i][j]=c
		end
	end


end



function copy_map(source_map,target_map)
	for i=1,#source_map do
		for j=1,#source_map do
			target_map[i][j]=source_map[i][j]
		end
	end
end

function scale_map(the_map,scale)
	for i=1,#the_map do
		for j=1,#the_map do
			the_map[i][j]*=scale
		end
	end
end

function shift_map(the_map,shift)
	for i=1,#the_map do
		for j=1,#the_map do
			the_map[i][j]+=shift
		end
	end
end

function exp_map(the_map,exponent)
	for i=1,#the_map do
		for j=1,#the_map do
			the_map[i][j]=the_map[i][j]^exponent
		end
	end
end

function clip_map(the_map,low,high)
	for i=1,#the_map do
		for j=1,#the_map do
			the_map[i][j]=mid(the_map[i][j],low,high)
		end
	end
end

function clamp_map(the_map,lower,upper)

	local cur_lower=32767
	local cur_upper=-32767
	for i=1,#the_map do
		for j=1,#the_map do
			cur_lower=min(the_map[i][j],cur_lower)
			cur_upper=max(the_map[i][j],cur_upper)
		end
	end
	
	local cur_scale = cur_upper-cur_lower


	local scale=(upper-lower)/cur_scale
	
	shift_map(the_map,-cur_lower)
	scale_map(the_map,scale)

	
end

function draw_map(the_map)

	cls()
	for i=1,#the_map do
		for j=1,#the_map do
			c=the_map[i][j]
			--c=lerp_map(the_map,i/10+1,j/10+1)
			pset(i,j+40,c)
		end
	end

	
end

x_heights={}
clip_x_heights={}
x_heights_b={}
z_buffer={}
function clear_x_heights()

	if(render_mode==k_fast) then
		for i=screen_start_x+(cur_frame%2*2),screen_width, h_step do
			x_heights[i]=300
			z_buffer[i]={}
		end
	else
		for i=screen_start_x,screen_width do
		x_heights[i]=300
		z_buffer[i]={}
		end
	end
end



function new_player(x,y,z)

	p={}
	p.vx=0
	p.vz=0
	p.angle = .25
	p.vangle = 0
	p.x=x
	p.y=y
	p.z=z
	p.engines=false
	p.vy=0
	p.actor=new_actor(x,y,z,0,k_player_type,16,16,1,false)
	--p.cross = new_actor(x,y,z,28,k_particle_type,8,8,-1,false)
	p.actor.scale=-1
	
	p.speed = 0
	p.acel = .05
	p.max_speed = 3
	p.turn_acel = .001
	p.y_acel=.1
	p.dv_x=1
	p.dv_z=0
	
	p.health=100
	p.warp=0
	
	
	p.color = {2,13,7}
	
	

	return p
end




function low_res_mode()
	poke(0x5f2c,1)
	screen_center_x=32
	screen_center_y=64
	screen_height=120
	screen_width=64
	screen_start_y=70
	
	v_step=1
	h_step=1
	
end

function pause(t)
	--flip the screen and draw for t frames
	for i=0,t do flip() end
end

--return the color and the height from the sprite 8 to the south
function get_map_pix(x,y)

	x=flr((x/x_scale)%k_world_width+1)
	y=flr((y/x_scale)%k_world_width+1)
	
	cx=(x/2)%16+8
	cy=(y/2)%16
	

		c=world_color_map[x][y]

	
	return c,world_map[x][y]
	--return sget(cx,cy),world_map[x][y]
end





function plot_3d(px,py,pz)
	
	cc=cos(-camera_angle)
	cs=sin(-camera_angle)
	

	px = px - camera_x
	pz = pz - camera_z
	py = -py + camera_y
	
	mx = px*cc-pz*cs
	mz = flr(pz*cc+px*cs)

		
	
	sx = f*mx/mz+screen_center_x+screen_start_x-1
	
	
	tilt=-(sx-screen_center_x)*player.vangle*20
	
	sy = f*py/mz+screen_center_y+tilt
	h = .5*f/mz



	return sx,sy,h,mz
end

function find_x_index(the_index)
	return (the_index%16*8)
end

function find_y_index(the_index)
	return (flr(the_index/16)*8)
end

function draw_sprite_3d(px,py,pz,index,width,height,sprflip,scale,offset_x,offset_y)
	x,y,h,z = plot_3d(px,py,pz)
	if(scale==nil)scale=1
	if(offset_x==nil)offset_x=0
	if(offset_y==nil)offset_y=0
	x=flr(x)+offset_x
	y=flr(y)+offset_y
	
	
	if(scale!=-1)then
	scale_factor=h*scale
	else
	scale_factor=1
	end
	
	
	new_width=flr(width*scale_factor)
	new_height=flr(height*scale_factor)
	
	--if( sy<screen_height+16 and sy>screen_start_y) then
	
	
	
	
	left_ext=flr(x-new_width/2)
	right_ext=left_ext+new_width-1
	top_ext=flr(y-new_height/2)
	bottom_ext=top_ext+new_height
	
	if(right_ext<screen_start_x or left_ext>screen_width ) then return -1
	end
	--or
	--	top_ext>screen_height or bottom_ext<screen_start_y
	if( (h*scale>.3 and h*scale<2) or scale==-1)then
	
	spr_ul_x=find_x_index(index)
	spr_ul_y=find_y_index(index)
	

		for sx=left_ext,right_ext,1 do
			min_sy=255
			int_sx=flr(sx/2)*2
			if(z_buffer[int_sx]!=nil)then
				for z_value,y_value in pairs(z_buffer[int_sx]) do
					if(z_value<z)then
						min_sy=min(min_sy,y_value)
					end
				end
				--block out what is hidden
				if(min_sy>top_ext)then
					dest_h=flr(min(min_sy,bottom_ext)-top_ext)
					source_h=flr(dest_h/scale_factor+.5)
					percent=(sx-left_ext)/new_width
					
					if(not sprflip)then
						sspr(flr(spr_ul_x+percent*width),spr_ul_y,1,source_h,sx,top_ext,1,dest_h)
					else
						sspr(flr(spr_ul_x+(1-percent)*width)-1,spr_ul_y,1,source_h,sx,top_ext,1,dest_h)
					end
					
				end
				
				
			end
		end

	--pset(x,y,8)
	end
	
	
	
	return h
end




function quick_cast_map_3d()

			clear_x_heights()
			local cc=cos(camera_angle)
			local cs=sin(camera_angle)					
		local sy=screen_start_y	
		local sy=screen_height
		
		ship_shadow_y=300
		
		if(render_mode==k_fast) then
			for clear_x=screen_start_x+(cur_frame%2*2),screen_width, h_step do
					rectfill(clear_x,0,clear_x+1,127,sky_color)
			end
		else
			rectfill(0,0,127,127,sky_color)
		end
		
		
	
	while sy>screen_start_y do
			local px
			local pz=f*(camera_y)/(sy-screen_center_y)			
			local pe=-pz*screen_center_x/f
			local px=pe
			local h=f/pz			
			local sx=screen_start_x
			if(render_mode==k_fast)sx+=(cur_frame%2*2)		
			local dpx = h_step*pz/f			
			local cona = pz*cs-camera_x
			local conb = pz*cc+camera_z
			
			
			if(render_mode==k_fast) px+=dpx*(cur_frame%2)/2		
			

		while sx< (screen_width) do			
			local tilt=-(sx-screen_center_x)*player.vangle*20
			
			px+=dpx
			local mx = (px*cc-cona)--/x_scale
			local mz = (conb+px*cs)--/x_scale			
			local c,height= get_map_pix(mx,mz)			
			local block_height=sy-height/pz*f +tilt	
			
			
			
			
			--find ship shadow height
			if( (sx==screen_center_x or sx==screen_center_x+2) and pz>40 and ship_shadow_y==300) then
					ship_shadow_y=block_height
					--rectfill(sx,block_height-1,sx+1,block_height+1,7)
			end
			
			--draw the column only if we are higher up the screen
			if(block_height<=x_heights[sx])then

				rectfill(sx,x_heights[sx]-1,sx+1,block_height,c)
				
				
			--	if(sx%2==0 and sy%4==2) then
			----debug map projection vs sprite projection
			--		pset(sx,block_height,8)
			--		x,y = plot_3d(mx,height,mz)
			--		pset(x,y,0)
			--	end
			end
			
			
			
			--if we have a local dip, where the last height is higher than both the
			--current and the one from two frames ago:
			if((x_heights[sx]<block_height and x_heights_b[sx]>x_heights[sx]) or (sy-2*v_step<screen_start_y and block_height<x_heights[sx]) )then
				--rectfill(sx,block_height,sx+h_step,block_height-1,7)
				--add this value to the z buffer list a this sx
				z_buffer[sx][pz]=block_height
			end
			
			--store the last screen height for use next frame
			x_heights_b[sx]=x_heights[sx]
			
			--store the current screen height (if higher) for use next frame
			x_heights[sx]=min(block_height,x_heights[sx])						
			sx+=h_step
			
				
				
			

		end
		
		sy+=-v_step		
	end
	
	--for sx=screen_start_x,screen_width do
	--	for z_depth,y_val in pairs(z_buffer[sx]) do
	--		rectfill(sx,y_val,sx+1,y_val-1,z_depth/50)
	--	end
	--end
	
	
end

k_button_cool_down=5
button_cool_down=0
k_shot_cool_down=10
shot_cool_down=0
function handle_buttons()
	
	player.engines=false

	if(btn(4)) then 
		player.speed+=player.acel
		player.engines=true
	end
	
	if(shot_cool_down>0)shot_cool_down-=1
	
	if(btn(5)) then
		if(shot_cool_down<=0)then
		
			ox=player.dv_x*3
			oy=player.vy*2.5
			oz=player.dv_z*3
		
			s=new_shot(player.x+ox*.5,player.y+oy*.5-1,player.z+oz*.5,0,0,0,11)
			s.vx=player.vx*1--+ox--+vx*.25
			s.vz=player.vz*1--+oz--+vz*.25
			s.vy=player.vy+oy*.5--+vy*.25
			
			s.vx += -1*sin(player.angle+player.vangle*5)*2.5
			s.vz += 1*cos(player.angle+player.vangle*5)*2.5
			
			sfx(3,-1)
			shot_cool_down=k_shot_cool_down
			
	--			player.cross.x=player.x+(player.dv_x*3+player.vx*1.5)*5
	--player.cross.z=player.z+(player.dv_z*3+player.vz*1.5)*5
	--player.cross.y=player.y+(player.vy*2.5
			
		end
	end
	
	
	if(btn(2)) player.vy-=player.y_acel--.2
	
	if(btn(3))  player.vy+=player.y_acel--.2
	
	if(btn(0))  player.vangle-=player.turn_acel  
	if(btn(1))  player.vangle+=player.turn_acel  
	
	
	if(button_cool_down>0)button_cool_down-=1
	if(btn(2,1)) start_warp() --"e" key
	if(btn(4,1)and button_cool_down<=0) toggle_render_mode() button_cool_down=k_button_cool_down
	

end


function handle_movement()
	player.angle+=player.vangle
	
	player.dv_x = -1*sin(player.angle)
	player.dv_z = 1*cos(player.angle)
	
	player.vx = player.dv_x * player.speed
	player.vz = player.dv_z * player.speed
	
	player.x+=player.vx
	player.z+=player.vz
	
	player.y+=player.vy
	
	
	player.vangle*=.9
	
	player.vy*=.95
	if(player.engines==false and game_mode!=k_warp_mode) player.speed*=.95
	
	if(player.y>50 and game_mode!=k_warp_mode) player.vy-=.5
	
	if(player.speed>player.max_speed)then player.speed=player.max_speed end
	
	shift=false
	if( (player.x)/x_scale>k_world_width )player.x-=k_world_width*x_scale*2 shift=true
	if( (player.x)/x_scale<-k_world_width )player.x+=k_world_width*x_scale*2 shift=true
	if( (player.z)/x_scale>k_world_width )player.z-=k_world_width*x_scale*2 shift=true
	if( (player.z)/x_scale<-k_world_width )player.z+=k_world_width*x_scale*2 shift=true
	
	
end

function handle_camera()
	
	camera_angle= (camera_angle+player.angle)/2
	camera_x=player.x - player.dv_x*f/2	
	camera_z=player.z - player.dv_z*f/2	
	camera_y=player.y/2+16

end



function draw_background()
	palt(0,false)
	palt(14,true)
	
	--cls()
	clip(screen_start_x,32,screen_width-screen_start_x,screen_height-32)
	--rectfill(0,0,127,127,sky_color)
	
	quick_cast_map_3d()

end

function draw_player()	

	player_index=0
	player_flip=false
	if(player.vy>=0)then
		if(player.vangle>.002)player_index=2
		if(player.vangle<-.002)player_index=2 player_flip=true
	end
	
	if(player.vy<0)then
		player_index=4
		if(player.vangle>.002)player_index=6
		if(player.vangle<-.002)player_index=6 player_flip=true
	end
	
	
	x,y=plot_3d(player.x,player.y,player.z)
	
	--shadow_height=clip_x_heights[screen_center_x]
	color,ground_height = get_map_pix(player.x,player.z)
	mono_palate(shade_lookup(color,.4))
	spr(player_index,x-8,ship_shadow_y+4,2,2,player_flip)
	
	if(ground_height>player.y)then player.y=ground_height end
	
	
	palt()
	pal()
	
	
	y=flr(y)

	
	
	pal()
	
	player.actor.index=player_index
	player.actor.flip=player_flip
	player.actor.x=player.x
	player.actor.y=player.y
	player.actor.z=player.z

	--player.cross.x=player.x+(player.dv_x*3+player.vx*1.5)*5
	--player.cross.z=player.z+(player.dv_z*3+player.vz*1.5)*5
	--player.cross.y=player.y+(player.vy/2)*5

end		

function center_text(text,x,y,c)
	print(text,x-#text/2*4,y,c)
end

function draw_hud()
	center_text(world_name,64,8,7)
	rect(screen_start_x-1,31,screen_width,screen_height,7)
	
	rectfill(7,16,120,26,0)
	rect(7,16,120,26,7)
	print("shld "..flr(player.health).."%",10,19,7)
	print("warp "..flr(player.warp).."%",64,19,7)
end

function toggle_render_mode()
	if(render_mode==k_fast) then
		render_mode=k_slow
		h_step=2
	else
		render_mode=k_fast
		h_step=4
	end
end

function mono_palate(color)
	
	palt()
	for i=1,15 do
		pal(i,color)
	end

end

function start_warp()
	game_mode=k_warp_mode
	warp_speed=0
	warp_time=0
	sfx(6,-1)
end



stars_x={}
stars_y={}
for i=1,400 do stars_x[i]=rnd(127)-64 stars_y[i]=rnd(217)-64 end

function draw_warp_mode()
		warp_time+=1
		--handle_buttons()
		--handle_sound()
	

		if(warp_time<100)then
		
			player.speed+=.05 player.y+=.25 +warp_time/100
			
			
			
		
			
			
			handle_movement()
			handle_camera()	
			

			
			draw_background()
			--update_actors()
			--update_player()
			
			
			
			pal()
			draw_player()
			sort_actors(actor_list)
			draw_actors()
			
			if(warp_time>40 and warp_time<=120)then
				for i=1,min((warp_time-20)*5,500) do
				x1=rnd(128)
				y1=rnd(128)
				rectfill(x1,y1,x1+10,y1,7)
				
				end
			end
		end
		
		if(warp_time>100 and warp_time<=110) then
			clip(screen_start_x,32,screen_width-screen_start_x,screen_height-32)
			rectfill(0,0,127,127,7)
		end
		
		if(warp_time>110 and warp_time<=120) then
			clip(screen_start_x,32,screen_width-screen_start_x,screen_height-32)
			rectfill(0,0,127,127,6)
		end
		
		if(warp_time>120 and warp_time<=130) then
			clip(screen_start_x,32,screen_width-screen_start_x,screen_height-32)
			rectfill(0,0,127,127,5)
		end
		
		if(warp_time>130 and warp_time<=200) then
			clip(screen_start_x,32,screen_width-screen_start_x,screen_height-32)
			rectfill(0,0,127,127,0)
		end
			
		if(warp_time>200 and warp_time<=210) then
			clip(screen_start_x,32,screen_width-screen_start_x,screen_height-32)
			rectfill(0,0,127,127,5)
		end
		
		if(warp_time>210 and warp_time<=220) then
			clip(screen_start_x,32,screen_width-screen_start_x,screen_height-32)
			rectfill(0,0,127,127,6)
		end
		
		if(warp_time>220 and warp_time<=230) then
			clip(screen_start_x,32,screen_width-screen_start_x,screen_height-32)
			rectfill(0,0,127,127,7)
		end
		
		if(warp_time>230) then
			game_mode=k_flight_mode
			srand()
			world_seed=world_seed+1
			init_world_map(world_seed)
		end
			
		if(warp_time>100 and warp_time<=230) then
			clip(screen_start_x,32,screen_width-screen_start_x,screen_height-32)
			--rectfill(0,0,127,127,0)
			angle=warp_time/500
			c=cos(angle)
			s=sin(angle)
			
			scale=1.5*(warp_time-100)/100+1
			
			for i=1,#stars_x do
				x=c*stars_x[i]-s*stars_y[i]
				y=s*stars_x[i]+c*stars_y[i]
			
				pset(x*scale+64,y*scale+64,7)
				
			end
		end
		
		

		
		
		 --project_world()
		
		clip()
		
			
	
	--draw_hud()

	--print(stat(1),100,32,7)
	--print(warp_time,100,42+1,0)
	--print(warp_time,100,42,7)
	
	
end

title_frame=0
function draw_title_mode()
			title_frame+=1
			player.speed=.4
			player.vangle=.01*sin(title_frame/500+cos(title_frame/230)*.25)
			handle_movement()
			handle_camera()	
			

			draw_background()
			
			draw_player()
			sort_actors(actor_list)
			draw_actors()
			clip()
			
			--center_text(world_name,64,8,7)
			rect(screen_start_x-1,31,screen_width,screen_height,7)
	
			rectfill(7,11,120,26,0)
			rect(7,11,120,26,7)
			
			spr(70,32,10,8,2)
			
			rectfill(20,40,107,65,0)
			rect(20,40,107,65,7)
			center_text("z: thrust x: fire",64,45,7)
			center_text("kill enemies to warp",64,55,7)
			
			rectfill(20,95,107,107,0)
			rect(20,95,107,107,7)
			center_text("z/x: start",64,99,7)

			
end


function handle_title_buttons()
	if(button_cool_down>0)button_cool_down-=1
	if( (btn(4) or btn(5)) and button_cool_down<=0 ) start_warp() button_cool_down=k_button_cool_down
	
end

function update_player()
	player.warp=(((flyer_count+turret_count)-#enemy_list)/(flyer_count+turret_count-1))*100
	if(player.warp>=100) start_warp()
	if(player.health<=0) game_mode=k_title_mode explode_player() _init()
end

function explode_player()
	--_draw()
	clip(screen_start_x,32,screen_width-screen_start_x,screen_height-32)
	sfx(5,-1)
	for i=0,50 do
			color=8+flr(rnd(3))
			
		for j=0,50 do
			len=100*(.75+rnd(.25))*i/50
			x,y,h=plot_3d(player.x,player.y,player.z)
			
			angle=rnd(1)
			
			line(x,y,x+cos(angle)*len,y+sin(angle)*len,color)
			line(x,y,x+cos(angle)*len*.5,y+sin(angle)*len*.5,0)
		end
	flip()
	end
end

function _init()
	cur_frame=0
	
	--sb_init()
	
	world_seed=flr(rnd(100))
	init_world_map(world_seed)
	cls()
	
	
	

	
	
	
end


playing_music=false
function _update()
	

	if(game_mode==k_flight_mode)then
		handle_buttons()
		handle_movement()
		handle_camera()	
		
		update_actors()
		--update_player()
	end
	if(game_mode==k_title_mode)then
		handle_title_buttons()
	end





end






function _draw()
	cur_frame+=1
	if(game_mode==k_flight_mode) then
	

		
		--handle_sound()
		
		draw_background()
		
		
		
		
		pal()
		
		sort_actors(actor_list)
		
		
		draw_player()
		draw_actors()
		
		 --project_world()
		
		clip()
		
			
	
	draw_hud()

	--print(stat(1),100,32,7)
			update_player()
	end
	
	if(game_mode==k_warp_mode) draw_warp_mode()
	if(game_mode==k_title_mode) draw_title_mode()

	

	
	
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008000008000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000099900000eee00000808080000000000510000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000009aaa9000e222e0000008000005100000510005500000000
000000000000000000000000000000000000000000000000000000000000000000000000000000009afffa90e2eae2e000889880005510000551005100000000
000000077000000000000007700000000000000000000000000000000000000000000000000000009afefa90e2aaa2e000008000005510000151555100000000
000000777700000000000077770000000000000770000000000000077000000000000000000000009afffa90e2eae2e000808080000455000045510000000000
0000007dd70000000000667dd70000000000007777000000000000777700000000000006d000000009aaa9000e222e0008000008000551000045100000000000
006665dddd566600666665dddd5600000000007dd70000000066657dd700000000000067750000000099900000eee00000000000000041000041000000000000
666665d66d566666577555d66d566600066666d66d666660577555d66d660000000006777d500000000000000000000000000000000045100551000000000000
5775556996555775199155699655566657755569965557751991556996556660000006776d500000000000000000000000070000000045554510000000000000
1991005995001991011000599500577519910059950019910110005995055775000006776d56d00000cccc000008800000070000000004555100000000000000
01100005500001100000000550001991011000055000011000000005500019910006d6776d5765000cd77dc00082280000000000000000451000000000000000
00000000000000000000000000000110000000000000000000000000000001100067d6776d576d50c777777c0082280077000770000000451000000000000000
00000000000000000000000000000000000000000000000000000000000000000067d6776d576d500cd77dc00008800000000000000000451000000000000000
00000000000000000000000000000000000000000000000000000000000000000067d6776d566d5000cccc000000000000070000000004451100000000000000
0000000000000000000000000000000000000000000000000000000000000000001111776d111110000000000000000000070000000005555500000000000000
00000007777777777777777770000000000000000000000000007777777700000002ff0000777700000000000000066666600000000000bb0bb0000000000000
00007777777777777777777777550000000fffe0fffe00000005ccccccc150000022ff0007666670000000000006677777766000000b0bbbbbb0b00000000000
000776666777777777777776666550000fffefe0fffe00000005ccccccc15000022eeff07667766700000000006777777777760000bbbbbb3bbbbb0000000000
007766666666666666666666666655000fffefe0fffefffe0005ccccccc15000022eeff07679976700000000067777777777776000bbb3b33bb33bb000000000
007761111116661111666111111655000fffeee0eeeefffe0005ccccccc1500022e77eff66799766000000006777666666666776000b33bbbbbb33b000000000
007761111116611111166111111655000eeeefffe045fffe0000dddddddd000022e77eff66799766000000006766dd1bb1dd667600bbbb33bbb33bb000000000
0077611111166111111661111116550000ffffffe045eeee000000011000000022e77eff666776dd0000000066001dd11dd100660b33bb3333b3bb3000000000
0077666666666122221666666666550000ffffffeffe0000000000076000000022e77eff666666dd00000000600001dddd1000060b33333033333b0000000000
00777777777771222217777777775500ffeffeeeeffe0000000000076000000022e77eff06666dd0000000000000000000000000003049000331330000000000
06666666666666666666666666666660ffeeee55fffe0000000001111110000022e77eff0666ddd0000000000007777777777000000004900450000000000000
000dddd111111111111111111dddd000eee00455eeee00000000177766d1000022e77eff0ddddd10000000000777777777777770000004444500000000000000
000000d111111111111111111d00000000000045100000000000177766d1000022e77eff01dddd1000000000777ee662266ee777000000495000000000000000
000000dd7711111111111d111d0000000000004510000000000177766ddd1000022eeff001dddd10000000007668862882688667000000495000000000000000
000000dd7777666666dddd111d000000000000451000000000017776dddd1000022eeff0011dd110000000001555662882665551000000495000000000000000
000000dd7777666666dddd111d000000000004451100000000155776ddd551000022ff00001dd100000000000111555225551110000000495500000000000000
000000dd7777666666dddd111d000000000005555500000000111111111111000022ff0000011000000000000001111111111000000001111100000000000000
11111111dddddddd55555555666666661115d111dd5551dd00000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111dddddddd55555555666666661115d111dd5551dd00000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111dddddddd50000005600000061115d111ddd51ddd00000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111dddddddd50b00005600000061115d111ddd51ddd00000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111dddddddd5000000560bbb0061115d111dd5555dd0000000000000000000d77777000000000000000000000000000000d777000000000000000000000
11111111dddddddd50000005600000061115d111dd5775dd0000000000000000000d70d7000000000000000000000000000000d7000000000000000000000000
11111111dddddddd500bbb0560bbb0061115d111dd5775dd0000000000000000000d70d7000000000000000000000000000000d7000000000000000000000000
11111111dddddddd5000000560000006155555d1dd5775dd0000d77700d77000d7770d600d77700d77700d7770000000d7770d70000000000000000000000000
11111111dddddddd50bb000560000006155665d1dd5555dd000d7dd70d70d70d70d70d70d7dd70d70000d7000000000d70000d70777700d77000000000000000
11111111dddddddd50000005600bbb0611566d11ddd51ddd000d7d770d70d70d70d70d70d7d770d77770d7777000000d77770d7770d70d700000000000000000
11111111dddddddd5000000560000006155555d1ddd51ddd00d77000dd7d70d70d70d60d77000000d77000d7700000000d770d7d770d7d700000000000000000
11111111dddddddd555555556666666611555d11ddd51ddd00d77770d70d70d77770d70d77770d77770d7777000000d777707700d770d7000000000000000000
11111111dddddddd555555556666666611111111ddd51ddd00000000000000000000000000000000000000000000000000000000000d70000000000000000000
11111111dddddddd555555556666666611111111dd5551dd0000000000000000000000000000000000000000000000000000000d777700000000000000000000
55555555666666665555555566666666555555556655516600000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555666666665555555566666666555555556655516600000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000005555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000777757777665777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000077766577777766566777000000770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000776665777777776656667700000677000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00007766665777777776656666770000667700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077666555555555555555566677000666770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00755556dddeeddddddeeddd65555700655557000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
005aaaa511111dddddd111115aaaa5005aaaa5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
005aaaa500000111111000005aaaa5005aaaa5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00155551000000000000000015555100155551000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00011110000000000000000001111000011110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000012000000120000a20000000000d2e2000000007200000000000000000000000000000000000000000000000000020202020202
0202020202020202020202020202020202020202020202020202020202026161616161612232f1c3d31020d2021261616161616171f110101010100202020202
00000000000000000000000000620000006200000000000000a20000000000720000000000000000000000000000000000000000000000000000020202020202
0202020202020202020202020202020202020202020202020202020202026161616161616171f1109210d102126161616161612333f110101010100202020202
00000000000000000000000000006200000062000000000000000000000022000000000000000000000000000000000000000000000000000000020202020202
0202020202020202020202020202020202020202020202020202020202026161616161616171f1109210d151616161616161233382f210101010100202020202
000000000000000000000000000000620000006200000000a200000000a222000000000000000000000000000000000000000000000000000000020202020202
0202020202020202020202020202020202020202020202020202020202021361616161616171f1109210d151616161616123338282f010101010100202020202
00000000000000000000000000000000000000006242424242420000000000920000000000000000000000000000000000000000000000000000020202020202
0202020202020202020202020202020202020202020202020202020202025161616161616171f1109210d151616161616171e3f3f01010101010100202020202
020202020202020202020202020202020202020202020202020262424252a2529202020202020202020202020202020202020202020202020202020202020202
0202020202020202020202020202020202020202020202020202020202025161616161616171f1e3f310d151616161616171c3d3f11010101010100202020202
02020202020202020202020202020202020202020202020202020202026252522202020202020202020202020202020202020202020202020202020202020202
0202020202020202020202020202020202020202020202020202020202025161616161616171f1c3d310d1516161616161718282f11010101010100202020202
02020202020202020202020202020202020202020202020202020202020262427202020202020202020202020202020202020202020202020202020202020202
0202020202020202020202020202020202020202020202020202020202025161616161616171f1109210d1516161616161718282f11010101110100202020202
02020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202
0202020202020202020202020202020202020202020202020202020202025161616161616171f1109210d1516161616161718282f11010101010100202020202
02020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202
0202020202020202020202020202020202020202020202020202020202025161616161616171f1109210d151616161616171e3f3f11010100202020202020202
02020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202
0202020202020202020202020202020202020202020202020202020202025161616161616171f110e3f3d151616161616171c3d3101010100202020202020202
02020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202
0202020202020202020202020202020202020202020202020202020202025161616161616171f110c3d3d15161616161617182f2101010100202020202020202
02020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202
0202020202020202020202020202020202020202020202020202020202025161616161616171f1109210d1516161616161223282f21010100202020202020202
02020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202
0202020202020202020202020202020202020202020202020202020202025161616161616171f1109210d151616161616161223282f2e0e00202020202020202
02020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202
0202020202020202020202020202020202020202020202020202020202025161616161616171f1109210d1031361616161616122328282820202020202020202
02020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202
0202020202020202020202020202020202020202020202020202020202025161616161616171f1e3f31010d00313616161616161226060600202020202020202
02020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202
0202020202020202020202020202020202020202020202020202020202025161616161616171f1c3d3101010d003136161616161616161610202020202020202
02020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202
0202020202020202020202020202020202020202020202020202020202025161616161616171f110921010e3f3d003136161616161616161616161612232f192
02020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202
0202020202020202020202020202020202020202020202020202020202025161616161616171f110929292c3d310d0031361616161616161616161616171f192
02020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202
0202020202020202020202020202020202020202020202020202020202025161616161616171f2e0e0109210101010d00362626262626213616161616171f192
02020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202
0202020202020202020202020202020202020202020202020202020202025161616161616171828282e3f31010101010e2e2e2e2e2e2d003136161616171f192
02020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202
0202020202020202020202020202020202020202020202020202020202025161616161616122328282c3d39292e3f31010101010e3f310d0516161616171f192
02020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202
0202020202020202020202020202020202020202020202020202020202025161616161616161223282f1101010c3d39292e3f392c3d39292516161616171f192
02020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202
0202020202020202020202020202020202020202020202020202020202020313616161616161612232f2e0e0e0e0e0e0e0c3d3e0e0e0d202126161616171f192
02020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202
0202020202020202020202020202020202020202020202020202020202028203136161616161616122606060606060606060606060606012616161616171f192
02020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202
0202020202020202020202020202020202020202020202020202020202028282031361616161616161616161616161616161616161616161616161616171f192
10e3f341c1d1031361616161612232f2929292929292606060606060606060606060606060606060606060606060606060606060606060606060606060606060
3282828292921261616161616161020202020202020202020202020202028282820313616161616161616161616161616161616161616161616161612333f292
10c3d340c110d0031361616161612260606060606012616161616161616173836161616161616161616161616161616161616161616161616161616161616161
226060609212616161616161616102020202020202020202020202020202e2e2e2d0031361616161616161616161616161616161616161616161612333828292
10e3f331c11010d00313616161616161616161616161616161616161616193a361616161616161616153616161615361616161616161616173b3836161616161
61616161616161616161616161610202020202020202020202020202020210101010d00362626262626262626262626262626262626262626262623382828292
10c3d331c1101010d0031361616161616161616161616161616161616161616161616161616161616161616161616161616161616161616193b3a36161616161
6161616161616161616161616123020202020202020202020202020202021010101010e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e292
10e3f3e3f310101010d0036262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262626262
62626262626262626262626262330202020202020202020202020202020210101010101010101010101010101010101010101010101010101010101092929292
10c3d3c3d39292929292929292929292929292929292929292929292929292929292929292929292929292929292929292929292929292929292929292929292
92929292929292929292929292920202020202020202020202020202020292929292929292929292929292929292929292929292929292929292929292101010
__gff__
0000000000000000000000000000000000000000000000000000000000000000121212120000121212121200000000001212121200001212121212000000000005000500050000000000000000000000000000000000000000000000000000001200120000120000121200001212000012001200001200001212000012120000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000004040404040400000000140404040404040404040404040404040402020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020293e3f2929293e3f29292929292929292929292929292929292901010101010101
0000004044004400404000000040000000000000000000000000000000402020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020013c3d0101013c3d01010101010101010101010101010101012901010101010101
0000004000000000004040000040000000000000000000000000000000402020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020013e3f010101010101010101010101010101010101010101012901010101010101
4040404000000000000040400040000000000000000000000000000000400000000000000000000000000000000000000000000000000000000020202020202020202020202020202020202020202020202020202020202020202020202020013c3d0101010101010e0e0e0e0e0e010101010101010101013e3f010101010101
44000000000000000000004200400000000000000000000000000000004000000000000000000000000000000000000000000000000000000000202020202020202020202020202020202020202020202020202020202020202020202020200e0e290e0e0e0e0e2d2828282828282f0101010101010101013c3d29293e3f0101
4400000000000000000000420040000000000042424242420000000000400000000000000000000000000000000000000000000000000000000020202020202020202020202020202020202020202020202020202020202020202020202020060606060606060606060606060623282f0101010101010101010101013c3d0101
440000000000000000000042004000000000004200000042000000000040000000000000000000000000000000000000000000000000000000002020202020202020202020202020202020202020202020202020202020202020202020202016363616161616161616161616162223282f010101010101010111010101290101
40404040000000000000404000400000000000420000004200000000004000000000000000000000000000000000000000000000000000000000202020202020202020202020202020202020202020202020202020202020202020202020201636361616161616161616161616162223282f0101010111010111110101290101
0000004000000000004040000040000000000042424242420000000000400000000000000000000000000000000000000000000000000000000020202020202020202020202020202020202020202020202020202020202020202020202020163636161616161616161616161616162223282f01010101011101010101290101
000000404400440040400000004000000000000000000000000000000040000000000000000000000000000000000000000000000000000000002020202020202020202020202020202020202020202020202020202020202020202020202016363616161616161616161616161616162223282f010101010101011101290101
00000040404040404000000000400000000000000000000000000000004000000000000000000000000000000000000000000000000000000000202020202020202020202020202020202020202020202020202020202020202020202020201636361616161616161616161616161616162223282f0101010101110101290101
0000000000000000000000000040000000000000000000000000000000400000000000000000000000000000000000000000000000000000000020202020202020202020202020202020202020202020202020202020202020202020202020262626262626262626262631161616161616162223281f01010101010101290101
00000000000000000000000000404040404040404040404040404040404000000000000000000000000000000000000000000000000000000000202020202020202020202020202020202020202020202020202020202020202020202020202e2e292e2e2e2e2e2e2e0d30311616161616161622231f01010101010101290101
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000202020202020202020202020202020202020202020202020202020202020202020202020200b0b2901010101010101010d303116161616161616171f01010101010101290101
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020202020202020202020202020202020202020202020202020202020202020202020202020040329013e3f3e3f3e3f01010d3031161616161616171f01010101010101290101
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020202020202020202020202020202020202020202020202020202020202020202020202020141329293c3d3c3d3c3d0101010d30311616161616171f01010101010101290101
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020202020202020202020202020202020202020202020202020202020202020202020202020040304032c010101013e3f0101010d151616161616171f01010101010101293e3f
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002020202020202020202020202020202020202020202020202020202020202020202020202014131413142c0101013c3d0101011d151616161616171f01010101010101013c3d
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000202020202020202020202020202020202020202020202020202020202020202020202020200403040304032c0101013e3f01011d151616161616172f01010101010101010129
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020202020202020202020202020202020202020202020202020202020202020202020202020141314131413142c0b013c3d01012d15161616161617281f010101010101010129
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000202020202020202020202020202020202020202020202020202020202020202020202020200403040304030403041c0101011d2021161616161622231f010101010101010129
00000000000000000000000000000000000000000000282900000000000000000000000000000000000000000000000000000000000000000000202020202020202020202020202020202020202020202020202020202020202020202020201413141314131413141c0101011d1516163226311616171f010101010101010129
00000000000000000000000000000000000000000000210000000000000000000000000000000000000000000000000000000000000000000000202020202020202020202020202020202020202020202020202020202020202020202020202b2b0a0303043e3f2b010101011d1516161724151616171f010101010101010129
00000000000000000000000000000000000000000028000000000000000000000000000000000000000000000000000000000000000000000000202020202020202020202020202020202020202020202020202020202020202020202020200101010a13143c3d01010101011d1516161724151616171f010101010101010129
0000000000000000000000000000000000000000280000002900000000000000000000000000000000000000000000000000000000000000000020202020202020202020202020202020202020202020202020202020202020202020202020010101012b2b2b2901010101011d1516161724151616171f010101010101010129
00000000000000000000000000000000000000280000000000232323232329000000000000000000000000000000000000000000000000000000202020202020202020202020202020202020202020202020202020202020202020202020202f0101010101012901010101011d1516161724151616171f010101010101010129
000000000000000000000000000000000000002100002a00002b2c0000000029000000000000000000000000000000000000000000000000000020202020202020202020202020202020202020202020202020202020202020202020202022232f01010101013e3f0e0e0e0e2d1516161724151616171f010101010101010129
00000000000000000000000000000000000000210000002b0606092a0000000029000000000000000000000000000000000000000000000000002020202020202020202020202020202020202020202020202020202020202020202020201622232f0e0e0e2d3c3d28282828281516161724151616171f010101010101010129
00000000000000000000000000000000000028002a00002d070a09002b2c2a002200000000000000000000000000000000000000000000000000202020202020202020202020202020202020202020202020202020202020202020202020161622232828282828292e2e2e2e0d1516162206211616171f010101010101010129
000000000000000000000000000000000028000000000c0d2d0a09002d2e0000220000000000000000000000000000000000000000000000000020202020202020202020202020202020202020202020202020202020202020202020202016161622232828280f290b0b0b0b0b0d31161616161632331f010101010101010129
000000000000000000000000000000000021002a00000e00002d2e0000000000220000000000000000000000000000000000000000000000000020202020202020202020202020202020202020202020202020202020202020202020202016161616222328281f29130303030c2d151616161616170f01010101010101010129
00000000000000000000000000000000002100000000000000002b2c002a0000220000000000000000000000000000000000000000000000000020202020202020202020202020202020202020202020202020202020202020202020202016161616162223281f3e3f2b2b2b2d20211616161616171f01010101010101010129
__sfx__
000800000b65006770031000110004600037002930021300313001d3001f30023300302002d300283000d0000d0000d0000f000260000f0000f0000f0000f0000f0000f0000d0001200015000100000700003000
000a000024645122150a6051370512705127050850514405082051430514505081051440514205083051450508405141051430508205144051410508505143050810514505144050820514305141050850514405
0004000002432080050c2021b2021f205182021b2021f2022020224204272051d20529203272032420227202242021f2020c2021f2020c2021b2021d2021f2021d202222021f2021b2011d20218201242021f201
000900000f57300500006000060024605006000c303186000c403005000060000600246050060000600186000c303005000060000600246050060000600186000c30300500186010060024605246040060000600
0010000028665176450c625046050a405004050a4050c405004050a4050c405004050a4050c4051140513405004050c4050a405004050a405004050a4050c405004050c40516405004051640518405114050c405
000b000023677226571e6571b657186571666713667116670f6670c6570a647096470863706637056270462703627046270362703627036270262702627026270262702627026270262702627026270262701627
000e0000015270252603526055270652507526095470a5460c5460d5470f56510566125671354613647106460f6370e6360c6270c6260c6260b6260a627096270962607617076160761707616066150661706616
01100000004750c4750c475004750c475004750c475184750047518475004750c47518475004750c47518475004750c4750c475004750c475004750c475184750047518475004750c47518475004750c47518475
011000001b175161701617518170161751617113170161751617116170181751d1711d170181751b1711f1701f1751d1701d1711d1751d1701d1711d1751b1701d1711d17016175131710c1700f1750f1700f171
01100000001750c075000750c175000750c175000750c175030750f175030750f175030750f175030750f075001750c0750c1750c075001750c075001750c075031750f075031750f075031750f0750517511075
011000000837514275143750817514275083751417514275083751417508275143750817514275143750817514275143750817514275083751417508275143750817514275143750817514275083751417508275
01100000182751b2750c2721b2751d2750c2721b275222721f273222731b27211273132752227524275222710c2711b2751b275182731d275182771d275242752227218275182722b2752e272272751d27211271
0110000018772247752477218775247721877522772247751b77224775247721b775247721b77322775247721d77322775227721f773227751d7721b775227721a77522772227731a775227721a7752277224775
01100000297752977329775297712b7752b7732777527771267732677526773267752277522773227751f7711d7751d7731d7751d7711d7751d7731b7751b7711f7731f7751f7731f77118775187731877518771
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000462004620046200562005610056100462004620036200362003620036100361003610036100362002620026200261002610026200262002620026200262002620026100261002620036200362003620
000100000232002320023200232002320023200232002320023300233002320033200332003320033200332003320033300333003320033200232002320023200232002330023300233002320023200232002320
000100000523006230062300624005230052200522006220062300624005240052400524004230042200522004220042300424004240052400524005230052200522005230052300624006240052400423004230
000100000534005340043400434004330043300433005330053300533005340053400534005340053400534005330053300533005330053300533005340053300533006330063300633006330063300733007340
000100000623006230062300523005230052300523005230052300523005230062300623007230072300723006230062300623006230072300723007230072200722007230062300523007230082300823007230
000300000746007460064400732006320000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000205701f5701c5700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500001863019630196301a6401b6401b6401b6401b6401b6401b6401a640196401963018630176301663015630156301463014630146301463014630146301462015620156201462017620186201963019630
000500000f6200b6300c6300d6300f63010630126301463016630166301563013630106300e6300d6300d6300c6300c6300c6300c6300e6301063014630166301763018630186301763016630156401464013640
000500002d6302d6302e6302f6302f6302f6303163031630316303163031630316303163031630326303263032630326303263031630316303163031630316303163031630316303163031630316303162030620
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 01 03 05 44
00 01 42 03 05
01 07 04 03 02
00 07 04 03 02
00 01 0a 03 02
00 0a 0a 03 0b
00 07 04 03 0b
00 07 04 03 02
00 0c 09 03 44
00 0d 09 03 44
00 09 07 0c 0b
02 03 0c 0d 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
03 0f 10 11 44
03 0f 12 13 44
03 16 17 18 44
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
00 05 42 43 44
