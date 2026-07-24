pico-8 cartridge // http://www.pico-8.com
version 5
__lua__

shot_vertices={
{2.000000,-0.0,-2.000000},
{2.000000,-0.0,2.000000},
{-2.000000,-0.0,2.000000},
{-2.000000,-0.0,-2.000000},
{-0.000000,2.5,0.000000},
{0.000000,-2.5,-0.000000}
}
shot_faces={
{1,5,2},
{2,5,3},
{3,5,4},
{5,1,4},
{3,4,6},
{2,3,6},
{4,1,6},
{1,2,6}
}


turret_vertices={
{2.747511,6.558030,-5.351725},
{2.747511,-5.441971,-12.279927},
{18.747511,-1.441969,-5.351725},
{2.747512,-5.441969,1.576480},
{-13.252489,-1.441971,-5.351724},
{-10.222631,0.945693,0.327391},
{-2.222631,4.457002,2.243300},
{-2.222631,-2.469187,2.410318},
{6.384320,4.465038,2.576536},
{14.384319,0.953730,0.660626},
{6.384321,-2.461151,2.743555},
{-3.077082,4.938764,6.660899},
{-3.077082,-2.737460,6.846004},
{-11.943400,1.047216,4.537517},
{6.461912,4.947670,7.030220},
{15.328228,1.056124,4.906838},
{6.461913,-2.728554,7.215326}
}

turret_faces={
{2,3,4},
{1,3,2},
{11,7,8},
{7,11,9},
{10,9,15},
{9,11,17},
{9,10,1},
{4,3,10},
{17,16,15},
{11,10,16},
{8,7,12},
{1,2,5},
{2,4,5},
{5,4,8},
{1,5,6},
{13,12,14},
{6,8,13},
{7,6,14},
{1,7,9},
{4,11,8},
{7,1,6},
{16,10,15},
{10,3,1},
{15,9,17},
{11,4,10},
{17,11,16},
{13,8,12},
{6,5,8},
{14,6,13},
{12,7,14}
}

torment_vertices={
{-0.348621,-0.019078,-5.032013},
{-0.348621,1.980922,-9.032013},
{3.455606,-0.019078,-2.268081},
{7.259832,1.980922,-3.504149},
{2.002520,-0.019078,2.204055},
{4.353661,1.980922,5.440124},
{-2.699762,-0.019078,2.204055},
{-5.050903,1.980922,5.440123},
{-4.152847,-0.019078,-2.268082},
{-7.957072,1.980922,-3.504150},
{-0.348621,3.980922,-5.032013},
{3.455606,3.980922,-2.268081},
{2.002520,3.980922,2.204055},
{-2.699762,3.980922,2.204055},
{-4.152847,3.980922,-2.268082}
}

torment_faces={
{1,2,4},
{3,4,6},
{5,6,8},
{2,10,15},
{9,10,2},
{7,8,10},
{1,3,7},
{12,11,14},
{10,8,14},
{8,6,13},
{6,4,12},
{4,2,11},
{3,1,4},
{5,3,6},
{7,5,8},
{11,2,15},
{1,9,2},
{9,7,10},
{7,9,1},
{3,5,7},
{14,13,12},
{11,15,14},
{15,10,14},
{14,8,13},
{13,6,12},
{12,4,11}
}

zoomer_vertices={
{1.161961,0.521333,-3.994603},
{1.161961,0.521333,1.374165},
{-1.161961,0.521333,1.374165},
{-1.161961,0.521333,-3.994604},
{0.773907,1.763463,-0.836191},
{0.773907,1.763463,0.285228},
{-0.773907,1.763463,0.285228},
{-0.773907,1.763463,-0.836192},
{1.000000,0.000000,-3.620438},
{1.000000,0.000000,1.000000},
{-1.000000,0.000000,1.000000},
{-1.000000,0.000000,-3.620439},
{-1.716297,0.808794,0.204816},
{-1.012243,1.030897,0.206808},
{-1.153786,0.515251,-3.295648},
{1.716297,0.808794,0.204816},
{1.012243,1.030897,0.206808},
{-1.167539,0.524385,0.207306},
{1.153786,0.515251,-3.295648},
{1.167539,0.524385,0.207306}
}


zoomer_faces={
{3,4,12},
{5,8,7},
{1,5,6},
{2,6,7},
{3,7,8},
{5,1,4},
{9,10,11},
{2,3,11},
{4,1,9},
{1,2,10},
{16,19,17},
{15,18,13},
{13,14,15},
{14,13,18},
{19,16,20},
{17,20,16},
{11,3,12},
{6,5,7},
{2,1,6},
{3,2,7},
{4,3,8},
{8,5,4},
{12,9,11},
{10,2,11},
{12,4,9},
{9,1,10}
}

pyramid_vertices={
{0.000000,-4.000000,-4.000000},
{3.5,-4.000000,2.000000},
{0.000000,4.000000,0.000000},
{-3.5,-4.000000,2.00000}
}

pyramid_faces={
{1,2,4},
{1,3,2},
{4,3,1},
{2,3,4}
}


big_rock_vertices={
{0.000000,-10.000000,0.000000},
{7.236000,-4.472150,5.257200},
{-2.706079,-2.216542,6.928495},
{-8.944250,-4.472150,0.000000},
{-2.763850,-4.472150,-8.506400},
{7.236000,-4.472150,-5.257200},
{2.763850,4.472150,8.506400},
{-5.665311,3.411935,5.257200},
{-6.445330,4.175265,-3.976876},
{2.763850,4.472150,-8.506400},
{7.557767,5.314968,0.643572},
{-0.959917,12.239807,0.000000}
}

big_rock_faces={
{1,2,3},
{2,1,6},
{1,3,4},
{1,4,5},
{1,5,6},
{2,6,11},
{3,2,7},
{4,3,8},
{5,4,9},
{6,5,10},
{2,11,7},
{3,7,8},
{4,8,9},
{5,9,10},
{6,10,11},
{7,11,12},
{8,7,12},
{9,8,12},
{10,9,12},
{11,10,12}
}

giant_rock_vertices={
{0.000000,-18.000000,0.000000},
{16.690252,-9.389086,11.023746},
{-4.974930,-8.049870,15.311522},
{-19.138968,-10.261346,-0.523785},
{-4.974930,-8.049870,-15.311522},
{13.024800,-8.049870,-9.462960},
{4.974930,3.108228,15.311522},
{-13.024800,8.049870,9.462960},
{-13.024800,8.049870,-9.462960},
{4.974930,8.049870,-15.311522},
{16.099649,8.049870,0.000000},
{0.000000,10.067924,0.000000},
{13.329679,3.217197,10.312168},
{-3.515671,13.628293,-9.490557},
{13.202229,-17.651743,2.396376},
{-13.702534,-7.345936,-16.446442},
{-14.729494,-16.835247,8.275730}
}

giant_rock_faces={
{1,2,3},
{5,4,16},
{1,4,5},
{1,5,6},
{2,6,11},
{3,2,7},
{4,3,8},
{1,3,17},
{6,5,10},
{10,9,14},
{3,7,8},
{4,8,9},
{5,9,10},
{6,10,11},
{7,11,12},
{8,7,12},
{9,8,12},
{2,1,15},
{11,10,12},
{2,11,13},
{11,7,13},
{7,2,13},
{9,12,14},
{12,10,14},
{1,6,15},
{6,2,15},
{4,9,16},
{9,5,16},
{3,4,17},
{4,1,17}
}



screen_faces={}

k_x=1
k_y=2
k_z=3

k_tx=4
k_ty=5
k_tz=6
k_sx=7
k_sy=8

k_object=10

k_z_clip=.5

cam_x=0
cam_y=0
cam_z=0
cax=0
cay=0
caz=0

cam_vx=0
cam_vy=0
cam_vz=0

cvax=0
cvay=0
cvaz=0

--count=0


k_min_speed=.3
cur_speed=k_min_speed
k_acel_speed=.2
k_acel_fric=.98
k_max_speed=1.5

k_angle_acel = .0005
k_angle_friction = .98

--cam_dir_x=0
--cam_dir_y=0
--cam_dir_z=1

k_screen_scale=64
k_x_center=64
k_y_center=64

k_min_x=5
k_max_x=122
k_min_y=21
k_max_y=104

k_max_z=250

k_world_width = 200
k_player_world_width = 230
out_of_bounds=false

k_min_rad=3


hit_object=nil
hit_face=nil


player_score=0

fire_shot=false

collided_object=nil
k_collide_damage=8

power_draining=false
k_draining_damage=.2

laser_power=.2

k_max_ship_power=100
ship_power=k_max_ship_power
k_power_regen = .1

k_asteroid_type=1
k_zoomer_type=2
k_rubble_type=3
k_giant_asteroid_type=4
k_torment_type=5
k_turret_type=6
k_shot_type=7

k_title_mode=1
k_play_mode=2
k_game_over_mode=3

game_mode=k_title_mode
wait_frame=0

rx={}
ry={}
rz={}
scrx={}
scry={}

delta_matrix={{1,0,0,0},
			   {0,1,0,0},
			   {0,0,1,0},
			   {0,0,0,1}}

camera_matrix={{1,0,0,0},
			   {0,1,0,0},
			   {0,0,1,0},
			   {0,0,0,1}}
			   
object_matrix={{1,0,0,0},
			   {0,1,0,0},
			   {0,0,1,0},
			   {0,0,0,1}}


world_vertex_list={}
world_face_list={}


star_list={}
			 
double_color_list=	{{0,0,0,0,0,0,0,0,0,0},
					 {0,0,0,0,0,0,0,0,0,0},

					{0,0,1,1,1,1,13,13,12,12},
					{0,0,0,1,1,1,1,13,13,12},
					
					{2,2,2,2,8,8,14,14,14,15},
					{0,1,1,2,2,8,8,8,14,14},
					
					{1,1,1,1,3,3,11,11,10,10},
					{0,1,1,1,1,3,3,11,11,10},
					
					{1,1,2,2,4,4,9,9,10,10},
					{0,1,1,2,2,4,4,9,9,10},
					
					{0,0,1,1,5,5,13,13,6,6},
					{0,0,0,1,1,5,5,13,13,6},
					
					{1,1,5,5,6,6,6,6,7,7},
					{0,1,1,5,5,6,6,6,6,7},
					
					{5,5,6,6,7,7,7,7,7,7},
					{0,5,5,6,6,7,7,7,7,7},
					
					{2,2,2,2,8,8,14,14,15,15},
					{0,2,2,2,2,8,8,14,14,15},
					
					{2,2,4,4,9,9,15,15,7,7},
					{0,2,2,4,4,9,9,15,15,7},
					
					{4,4,9,9,10,10,7,7,7,7},
					{0,4,4,9,9,10,10,7,7,7},
					
					{1,1,3,3,11,11,10,10,7,7},
					{0,1,1,3,3,11,11,10,10,7},
					
					{13,13,13,12,12,12,6,6,7,7},
					{0,5,13,13,12,12,12,6,6,7},
					
					{1,1,5,5,13,13,6,6,7,7},
					{0,1,1,5,5,13,13,6,6,7},
					
					{2,2,2,2,14,14,15,15,7,7},
					{0,2,2,2,2,14,14,15,15,7},
					
					{4,4,9,9,15,15,7,7,7,7},
					{0,4,4,9,9,15,15,7,7,7}
					}

object_list={}
function new_object(vertices,faces,x,y,z,ax,ay,az,base_color,static,type)
	object={}
	
	object.type=type
	
	object.vertex_list=vertices
	object.face_list=faces
	
	object.x=x
	object.y=y
	object.z=z
	
	object.tx=x
	object.ty=y
	object.tz=z
	
	object.ax=ax
	object.ay=ay
	object.az=az
	
	object.vx=0
	object.vy=0
	object.vz=0
	
	object.vax=0
	object.vay=0
	object.vaz=0
	
	object.created_frame=cur_frame
	
	object.hp=nil
	
	object.life=-1
	
	object.sx=0
	object.sy=0
	object.sradius=0
	
	object.static=static
	
	object.base_color=base_color
	
	object.score=0
	
	if(static)then color_object(object,true) end --color the object once if static
	
	object.radius=0
	for vertex in all(vertices) do
		object.radius=max(object.radius,vertex[k_x]*vertex[k_x]+vertex[k_y]*vertex[k_y]+vertex[k_z]*vertex[k_z])
	end
	object.radius=sqrt(object.radius)
	
	
	
	add(object_list,object)
	return(object)
	
end

function update_torment(object)

	lead=90

	dx=object.x-(cam_x+cam_vx*lead)
	dy=object.y-(cam_y+cam_vy*lead)
	dz=object.z-(cam_z+cam_vz*lead)
	
	--dist=sqrt(dx*dx+dy*dy+dz*dz)
	
	dist=max(abs(dx),abs(dy))
	dist=max(abs(dist),abs(dz))
	
	
	
	dx/=dist
	dy/=dist
	dz/=dist
	acel=.15
	
	if(dist>10)then
	
		
		object.vx+=-acel*dx
		object.vy+=-acel*dy
		object.vz+=-acel*dz
	
	else
		object.vx+=acel*dx
		object.vy+=acel*dy
		object.vz+=acel*dz
		
		
		sfx(15)
		
	end
	
	dx=object.x-(cam_x)
	dy=object.y-(cam_y)
	dz=object.z-(cam_z)
	
	--dist=sqrt(dx*dx+dy*dy+dz*dz)
	
	dist=max(abs(dx),abs(dy))
	dist=max(abs(dist),abs(dz))
	
	if(dist<30)then
		power_draining=true
	end
	
	--temp=sqrt(object.vx*dx+object.vy*object.vy+object.vz*object.vz)
	
	temp=max(abs(object.vx),abs(object.vy))
	temp=max(abs(temp),abs(object.vz))
	--
	if(temp>2)then
		object.vx*=2/temp
		object.vy*=2/temp
		object.vz*=2/temp
		

	end
	
end


function update_asteroid(object)
	if(object.x>k_world_width)then object.vx=-object.vx end
	if(object.x<-k_world_width)then object.vx=-object.vx end
	
	if(object.y>k_world_width)then object.vy=-object.vy end
	if(object.y<-k_world_width)then object.vy=-object.vy end
	
	if(object.z>k_world_width)then object.vz=-object.vz end
	if(object.z<-k_world_width)then object.vz=-object.vz end
end


function update_turret(object)
	
	dx=object.x-cam_x
	dy=object.y-cam_y
	dz=object.z-cam_z
	
	object.ax=0
	object.az=0
	
	ay=atan2(dx,dz)
	ax=atan2(dz,dy)
	
	object.ay=-ay+.25
	--object.ax=ax
	
	if( cur_frame%60==0 )then
		lead=30

		dx=object.x-(cam_x+cam_vx*lead)
		dy=object.y-(cam_y+cam_vy*lead)
		dz=object.z-(cam_z+cam_vz*lead)
		
		dist=max(abs(dx),abs(dy))
		dist=max(abs(dist),abs(dz))
		
		dx=dx/dist*1
		dy=dy/dist*1
		dz=dz/dist*1
		
		if(dist<150)then
		shot=new_shot(object.x,object.y,object.z,-dx,-dy,-dz)
		sfx(16)
		end
	end
	
end

function update_object(object)
	
	if(object.type==k_torment_type)then update_torment(object) end
	if(object.type==k_asteroid_type or object.type==k_giant_asteroid_type)then update_asteroid(object) end
	if(object.type==k_turret_type)then update_turret(object) end
	
	
	
	object.x+=object.vx
	object.y+=object.vy
	object.z+=object.vz
	
	object.ax+=object.vax
	object.ay+=object.vay
	object.az+=object.vaz
	
	
	
	
	if(object.life!=-1)then
		
		
		if(object.life==0)then
			del(object_list,object)
			
		end
		
		object.life-=1
		
	end
	
	
		if(object.hp!=nil and object.hp<=0)then
			
			player_score+=object.score
			play_explode()
			
			if(object.type == k_asteroid_type or object.type==k_torment_type or object.type==k_turret_type)then	
				for i=1,3 do
					new_rubble(object.x,object.y,object.z)
					--p.hp=2
					
				end
			end
			
			
			
			if(object.type == k_giant_asteroid_type)then
				for i=1,3 do
					new_rubble(object.x,object.y,object.z)
				end
				
				for i=1,2 do
					p=new_asteroid(object.x,object.y,object.z)
					p.base_color=4
				end
				
			end
			
			
			del(object_list,object)
			populate_world()
		end
	

end


function color_object(object,static)
	color_faces(object.vertex_list,object.face_list,object.base_color,static)
end


function	transform_objects()

	--load the camera transform
	
	
	for object in all(object_list) do
	
		--move object centroid
		--object.tx,object.ty,object.tz = rotate_point(object.x-cam_x,object.y-cam_y,object.z-cam_z,camera_matrix)
		object.tx,object.ty,object.tz = rotate_point(object.x-cam_x,object.y-cam_y,object.z-cam_z,camera_matrix)
		
		object.sx=(object.tx*k_screen_scale)/-object.tz+k_x_center
		object.sy=(object.ty*k_screen_scale)/-object.tz+k_y_center
		
		object.sradius=object.radius*k_screen_scale/object.tz
		--circ(object.sx,object.sy,object.sradius,8)
		
		--print(object.radius,sx+20,sy+20,9)

		--object.tx, object.ty, object.tz = rotate_point(object.x,object.y,object.z)
		--if(cur_frame%10==0) then color_faces(object.vertex_list,object.face_list,object.base_color) end
	end
	
	

end



function	render_objects()
	world_vertex_list={}
	world_face_list={}
	
	--because we are using bubble sort, we get a huge speed boost if the list is already
	--partially sorted. (and a nasty speed hit if the list is backwards!)
	--so we initially sort the objects. there are only a few. this way, the faces that are loaded into the face
	--list are already somewhat in order.
	--also the objects are not likely to change order quickly (could even run a partial sort maybe)
	sort_objects(object_list)
	
	vertex_index=0
	face_index=1
	
	
	
	for object in all(object_list) do
		--use the "bounding sphere" to check if the object is somewhat visible in z and
		--in the view frustrum (sp)
		--also check if the object radius is large enough to be worth drawing
		if(object.tz+object.radius>k_z_clip and object.tz<k_max_z
		and (object.sx+object.sradius>k_min_x and object.sx-object.sradius<k_max_x)
		and (object.sy+object.sradius>k_min_y and object.sy-object.sradius<k_max_y)
		and (object.sradius>k_min_rad)
		)then
		

				--transform points in objects
				generate_transform(object.ax,object.ay,object.az,object_matrix)			
				for vertex in all(object.vertex_list) do
					p1x=vertex[k_x]
					p1y=vertex[k_y]
					p1z=vertex[k_z]
					p1x,p1y,p1z = rotate_point(p1x,p1y,p1z,object_matrix)
					
					vertex[k_tx]=p1x+object.x
					vertex[k_ty]=p1y+object.y
					vertex[k_tz]=p1z+object.z
				end
				
				--wasteful to handle camera transform every time
				--but currently only about .5% framerate hit for 6 objects
				--generate_transform(cax,cay,caz)
				--handle camera rotation
				for i=1, #object.vertex_list do
				
				
					world_vertex_list[vertex_index+i]={}
					--load the translated object vectors into k_x,k_y,k_z
					--load the camera rotated object vectors  into k_tx,k_ty,k_tz
				
					p1x=object.vertex_list[i][k_tx]
					p1y=object.vertex_list[i][k_ty]
					p1z=object.vertex_list[i][k_tz]
					
					world_vertex_list[vertex_index+i][k_x]=p1x
					world_vertex_list[vertex_index+i][k_y]=p1y
					world_vertex_list[vertex_index+i][k_z]=p1z
					
					p1x,p1y,p1z= rotate_point(p1x-cam_x,p1y-cam_y,p1z-cam_z,camera_matrix)
					
					sx=(p1x*k_screen_scale)/-p1z+k_x_center
					sy=(p1y*k_screen_scale)/-p1z+k_y_center
					
					object.vertex_list[i][k_sx]=sx
					object.vertex_list[i][k_sy]=sy
					
					
					
					world_vertex_list[vertex_index+i][k_tx]=p1x
					world_vertex_list[vertex_index+i][k_ty]=p1y
					world_vertex_list[vertex_index+i][k_tz]=p1z
					world_vertex_list[vertex_index+i][k_sx]=sx
					world_vertex_list[vertex_index+i][k_sy]=sy
					
					
				end
				
				for i=1, #object.face_list do
				
					--world_face_list[face_index+i]={}
				
					--check the face_normal
					p1x=object.vertex_list[object.face_list[i][1]][k_sx]
					p1y=object.vertex_list[object.face_list[i][1]][k_sy]
					p2x=object.vertex_list[object.face_list[i][2]][k_sx]
					p2y=object.vertex_list[object.face_list[i][2]][k_sy]
					p3x=object.vertex_list[object.face_list[i][3]][k_sx]
					p3y=object.vertex_list[object.face_list[i][3]][k_sy]
					
					
					
					
					
					--only add the face to the world if we can see it
					if( ((p1x<k_max_x and p1x>k_min_x) or (p2x<k_max_x and p2x>k_min_x) or (p3x<k_max_x and p3x>k_min_x))
						and ((p1y<k_max_y and p1y>k_min_y) or (p2y<k_max_y and p2y>k_min_y) or (p3y<k_max_y and p3y>k_min_y))
						and (world_vertex_list[object.face_list[i][1]+vertex_index][k_tz]>k_z_clip
						or world_vertex_list[object.face_list[i][2]+vertex_index][k_tz]>k_z_clip
						or world_vertex_list[object.face_list[i][3]+vertex_index][k_tz]>k_z_clip)
						and cross_product_2d(p1x,p1y,p2x,p2y,p3x,p3y))then
						--temp=object.face_list[i]
						--object.face_list[i][4]=7
						
							if(  (abs(p1x-p2x) + abs(p1y-p2y) + abs(p1x-p3x) + abs(p1y-p3y) )>6) then
						
						
									world_face_list[face_index]={}
									world_face_list[face_index][1]=object.face_list[i][1]+vertex_index
									world_face_list[face_index][2]=object.face_list[i][2]+vertex_index
									world_face_list[face_index][3]=object.face_list[i][3]+vertex_index
									
									world_face_list[face_index][k_object]=object
									
									
									if(object.static==false)then
										color_face(world_vertex_list,world_face_list[face_index],object.base_color,true)
									else
										world_face_list[face_index][4]=object.face_list[i][4]
										world_face_list[face_index][5]=object.face_list[i][5]
									end
									face_index+=1
							end
						
						
					else

					end
						
				end
				
				vertex_index+=#object.vertex_list


		end
	end

end

function lerp(a,b,alpha)
  return a*(1.0-alpha)+b*alpha
end
function clamp(v)
  return max(-1,min(128,v))
  
end





function generate_transform(xa,ya,za,cur_matrix)

	
	sx=sin(xa) sy=sin(ya) sz=sin(za)
	cx=cos(xa) cy=cos(ya) cz=cos(za)
	
	
	
	cur_matrix[1][1]=cz*cy
	cur_matrix[2][1]=-sz
	cur_matrix[3][1]=cz*sy
	cur_matrix[1][2]=cx*sz*cy+sx*sy
	cur_matrix[2][2]=cx*cz
	cur_matrix[3][2]=cx*sz*sy-sx*cy
	cur_matrix[1][3]=sx*sz*cy-cx*sy
	cur_matrix[2][3]=sx*cz
	cur_matrix[3][3]=sx*sz*sy+cx*cy
	

end

function rotate_point(x,y,z,cur_matrix)
	bx=x---cam_x
	by=y---cam_y
	bz=z---cam_z
	
	tx=(bx)*cur_matrix[1][1]+(by)*cur_matrix[2][1]+(bz)*cur_matrix[3][1]
	ty=(bx)*cur_matrix[1][2]+(by)*cur_matrix[2][2]+(bz)*cur_matrix[3][2]
	tz=(bx)*cur_matrix[1][3]+(by)*cur_matrix[2][3]+(bz)*cur_matrix[3][3]
	
	
	return tx,ty,tz
end

function matrix_multiply( m1, m2 )
    if #m1[1] ~= #m2 then       -- inner matrix-dimensions must agree
        return nil      
    end 
 
    local res = {}
 
    for i = 1, #m1 do
        res[i] = {}
        for j = 1, #m2[1] do
            res[i][j] = 0
            for k = 1, #m2 do
                res[i][j] = res[i][j] + m1[i][k] * m2[k][j]
            end
        end
    end
 
    return res
end

function	matrix_inverse( m )
	local det = m[1][1]* (m[2][2] * m[3][3]- m[3][2] * m[2][3]) -
                m[1][2]* (m[2][1] * m[3][3]- m[2][3] * m[3][1]) +
                m[1][3]* (m[2][1] * m[3][2]- m[2][2] * m[3][1])
	local invdet=2/det
		
	minv={{},{},{}}	
		
		minv[1][1] = (m[2][2] * m[3][3] - m[3][2] * m[2][3]) * invdet
		minv[1][2] = (m[1][3] * m[3][2] - m[1][2] * m[3][3]) * invdet
		minv[1][3] = (m[1][2] * m[2][3] - m[1][3] * m[2][2]) * invdet
		minv[2][1] = (m[2][3] * m[3][1] - m[2][1] * m[3][3]) * invdet
		minv[2][2] = (m[1][1] * m[3][3] - m[1][3] * m[3][1]) * invdet
		minv[2][3] = (m[2][1] * m[1][3] - m[1][1] * m[2][3]) * invdet
		minv[3][1] = (m[2][1] * m[3][2] - m[3][1] * m[2][2]) * invdet
		minv[3][2] = (m[3][1] * m[1][2] - m[1][1] * m[3][2]) * invdet
		minv[3][3] = (m[1][1] * m[2][2] - m[2][1] * m[1][2]) * invdet

		return minv
end
			 
			 
		
function color_shade(color,brightness)
	return double_color_list[ (color+1)*2-1 ][flr(brightness*10)] , double_color_list[ (color+1)*2 ][flr(brightness*10)] 
end

function	vector_cross_3d(px,py,pz,ax,ay,az,bx,by,bz)
	local d={}
	 ax-=px
	 ay-=py
	 az-=pz
	 bx-=px
	 by-=py
	 bz-=pz
	
	
	local dx=ay*bz-az*by
	local dy=az*bx-ax*bz
	local dz=ax*by-ay*bx
	return dx,dy,dz
end

function normalize(x,y,z)
	valmax=max(abs(x),abs(y))
	valmax=max(valmax,abs(z))

	return mid(x/valmax,-1,1),mid(y/valmax,-1,1),mid(z/valmax,-1,1)
end

function	cross_product_2d(p0x,p0y,p1x,p1y,p2x,p2y)

	
	return ( ( (p0x-p1x)*(p2y-p1y)-(p0y-p1y)*(p2x-p1x)) > 0 )
	
	
end


--if static = true then use non-translated faces (for landscape)
--otherwise use translated faces to recalculate colors

function color_face(vertex_list,face,base,static)
	if(static==nil or static==false) then
			nx,ny,nz = vector_cross_3d(vertex_list[face[1]][k_tx],vertex_list[face[1]][k_ty],vertex_list[face[1]][k_tz],
								vertex_list[face[2]][k_tx],vertex_list[face[2]][k_ty],vertex_list[face[2]][k_tz],
								vertex_list[face[3]][k_tx],vertex_list[face[3]][k_ty],vertex_list[face[3]][k_tz])
		else
			nx,ny,nz = vector_cross_3d(vertex_list[face[1]][k_x],vertex_list[face[1]][k_y],vertex_list[face[1]][k_z],
								vertex_list[face[2]][k_x],vertex_list[face[2]][k_y],vertex_list[face[2]][k_z],
								vertex_list[face[3]][k_x],vertex_list[face[3]][k_y],vertex_list[face[3]][k_z])
		end
	
		nx,ny,nz = normalize(nx,ny,nz)
		-- print(nx.." "..ny.." "..nz,10,i*8+8,8) 
		-- flip()
		
		face[4],face[5]=color_shade(base, mid( (ny+nx+nz)/3,0,.7)+.2 )
end


function color_faces(vertex_list, face_list,base,static)
	--if(static==nil)then static=false end
	--base=flr(rnd(15)+1)
	for i=1,#face_list do
		
		--face[6]=vector_cross_3d(p,a,b)
		
		--vector_cross_3d(2,3,4,1,2,3,5,6,4)
		
		--print(vertex_list[face_list[i][1]][k_x],50,50,7)
		--while(true)do flip() end
		if(static==nil or static==false) then
			nx,ny,nz = vector_cross_3d(vertex_list[face_list[i][1]][k_tx],vertex_list[face_list[i][1]][k_ty],vertex_list[face_list[i][1]][k_tz],
								vertex_list[face_list[i][2]][k_tx],vertex_list[face_list[i][2]][k_ty],vertex_list[face_list[i][2]][k_tz],
								vertex_list[face_list[i][3]][k_tx],vertex_list[face_list[i][3]][k_ty],vertex_list[face_list[i][3]][k_tz])
		else
			nx,ny,nz = vector_cross_3d(vertex_list[face_list[i][1]][k_x],vertex_list[face_list[i][1]][k_y],vertex_list[face_list[i][1]][k_z],
								vertex_list[face_list[i][2]][k_x],vertex_list[face_list[i][2]][k_y],vertex_list[face_list[i][2]][k_z],
								vertex_list[face_list[i][3]][k_x],vertex_list[face_list[i][3]][k_y],vertex_list[face_list[i][3]][k_z])
		end
	
		nx,ny,nz = normalize(nx,ny,nz)
		-- print(nx.." "..ny.." "..nz,10,i*8+8,8) 
		-- flip()
		
		face_list[i][4],face_list[i][5]=color_shade(base, mid( (ny+nx+nz)/3,0,.7)+.2 )
		--=color_shade(4,(nz+ny)/2+.2)
		
		
		
		
		
		--c1=color_shade(w_array[wz][wx].color,x_bright)
		--c2=color_shade(w_array[wz][wx].color,z_bright)
		
	end
end

function draw_scene()
	
	n=0
	
	sort_start=1--max(#world_face_list-80,1)

	partial_sort_triangles(world_face_list,sort_start,#world_face_list)
	for i=sort_start,#world_face_list do
	
	
	
	front_1=world_vertex_list[world_face_list[i][1]][k_tz]>k_z_clip
	front_2=world_vertex_list[world_face_list[i][2]][k_tz]>k_z_clip
	front_3=world_vertex_list[world_face_list[i][3]][k_tz]>k_z_clip
	
		
		if( front_1 and
			front_2 and
			front_3) then
			--triangle is fully visible
			
			n+=1
			
				p1x=world_vertex_list[world_face_list[i][1]][k_sx]
				p1y=world_vertex_list[world_face_list[i][1]][k_sy]
				p2x=world_vertex_list[world_face_list[i][2]][k_sx]
				p2y=world_vertex_list[world_face_list[i][2]][k_sy]
				p3x=world_vertex_list[world_face_list[i][3]][k_sx]
				p3y=world_vertex_list[world_face_list[i][3]][k_sy]
				
				
				
				--if(cross_product_2d(p1x,p1y,p2x,p2y,p3x,p3y))then
				solid_trifill( p1x,
								p1y,
								p2x,
								p2y,
								p3x,
								p3y,
								world_face_list[i][4], world_face_list[i][5],world_face_list[i][k_object],i)
			
			--end
		
		elseif(front_1 or front_2 or front_3)then
		
			--check if one of the vertices pierced the screen
			--if( in_view(p1x,p1y) )
				collided_object=world_face_list[i][k_object]
				
				
		else
			--face is fully out of view
		
		end
		
		--line(scrx[face_list[i][1]],scry[face_list[i][1]],scrx[face_list[i][2]],scry[face_list[i][2]],7)
		--line(scrx[face_list[i][2]],scry[face_list[i][2]],scrx[face_list[i][3]],scry[face_list[i][3]],7)
		--line(scrx[face_list[i][3]],scry[face_list[i][3]],scrx[face_list[i][1]],scry[face_list[i][1]],7)

	end

	print(n,0,0,8)
	
end

function in_view(x,y)
	
	if(x>k_min_x and x<k_max_x and y>k_min_y and y<k_max_y) then
		return true
	end
		return false

end



-- written by nusan
-- taken from pico8 3d renderer http://www.lexaloffle.com/bbs/?tid=2731&autoplay=1#pp
-- by orange451
-- pattern fill features added by electricgryphon
function solid_trifill( x1,y1,x2,y2,x3,y3, color1,color2, object, face )


		  -- order triangle points so that y1 is on top
		  
		  x1=flr(x1)
		  x2=flr(x2)
		  y1=flr(y1)
		  y2=flr(y2)
		  x3=flr(x3)
		  y3=flr(y3)
		  
		  
		  if(y2<y1) then
			if(y3<y2) then
			  local tmp = y1
			  y1 = y3
			  y3 = tmp
			  tmp = x1
			  x1 = x3
			  x3 = tmp
			else
			  local tmp = y1
			  y1 = y2
			  y2 = tmp
			  tmp = x1
			  x1 = x2
			  x2 = tmp
			end
		  else
			if(y3<y1) then
			  local tmp = y1
			  y1 = y3
			  y3 = tmp
			  tmp = x1
			  x1 = x3
			  x3 = tmp
			end
		  end

		  y1 += 0.001 -- offset to avoid divide per 0

		  local miny = min(y2,y3)
		  local maxy = max(y2,y3)

		  local fx = x2
		  if(y2<y3) then
			fx = x3
		  end

		  local d12 = (y2-y1)
		  if(d12 != 0) d12 = 1.0/d12
		  local d13 = (y3-y1)
		  if(d13 != 0) d13 = 1.0/d13

		  local cl_y1 = clamp(y1)
		  local cl_miny = clamp(miny)
		  local cl_maxy = clamp(maxy)

		  for y=flr(cl_y1),cl_miny,1 do
			local sx = lerp(x1,x3, (y-y1) * d13 )
			local ex = lerp(x1,x2, (y-y1) * d12 )
			
			if(y%2==0)then
				rectfill(sx,y,ex,y,color1)
			else
				rectfill(sx,y,ex,y,color2)
			end
			
			if(object!=nil and y==64 and (min(sx,ex)<=64 and max(ex,sx)>=64 ) )then
				hit_object=object
				hit_face=face
			end
			
			--memset(0x6000+(y)*64+flr(sx/2),15,flr(sx-ex)/2)
			
			
			--memset(0x6000+(y-2)*64+flr(sx/2),15,32)
		  end
		  
		  local sx = lerp(x1,x3, (miny-y1) * d13 )
		  local ex = lerp(x1,x2, (miny-y1) * d12 )

		  local df = (maxy-miny)
		  if(df != 0) df = 1.0/df
		  
		  
	
		  for y=flr(cl_miny),cl_maxy,1 do
			local sx2 = lerp(sx,fx, (y-miny) * df )
			local ex2 = lerp(ex,fx, (y-miny) * df )
			
			if(y%2==0)then
				rectfill(sx2,y,ex2,y,color1)
			else
				rectfill(sx2,y,ex2,y,color2)
			end
			
			if(object!=nil and y==64 and (min(sx2,ex2)<=64 and max(ex2,sx2)>=64) )then
				hit_object=object
				hit_face=face
			end
			
			
		  end
end

function check_in_triangle(sx,sy,ax,ay,bx,by,cx,cy)

	


	as_x = sx-ax
    as_y = sy-ay

    s_ab = (bx-ax)*as_y-(by-ay)*as_x > 0

    if((cx-ax)*as_y-(cy-ay)*as_x > 0 == s_ab) then return false end

    if((cx-bx)*(sy-by)-(cy-by)*(sx-bx) > 0 != s_ab) then return false end

    return true

end

function z_centroid(n)
	return(world_vertex_list[world_face_list[n][1]][6]+world_vertex_list[world_face_list[n][2]][6]+world_vertex_list[world_face_list[n][3]][6])/3
end

function z_min(n)
	return( min(vertex_list[face_list[n][1]][6],vertex_list[face_list[n][2]][6],vertex_list[face_list[n][3]][6]))
end


function partial_sort_triangles(a,start,finish)
  --for i=1,#a do
  for i=start,finish do
     j = i
   while j > 1 and z_centroid(j-1) < z_centroid(j) do --vertex_list[a[j-1][1]][6] > vertex_list[a[j][1]][6] do
   --while j > 1 and z_min(j-1) < z_min(j) do --vertex_list[a[j-1][1]][6] > vertex_list[a[j][1]][6] do
      a[j],a[j-1] = a[j-1],a[j]
      j = j - 1
    end
  end
end


--k_sort_stages=40
function sort_triangles(a)
  --for i=1,#a do
  for i=1,#a do
     j = i
   while j > 1 and z_centroid(j-1) < z_centroid(j) do --vertex_list[a[j-1][1]][6] > vertex_list[a[j][1]][6] do
   --while j > 1 and z_min(j-1) < z_min(j) do --vertex_list[a[j-1][1]][6] > vertex_list[a[j][1]][6] do
      a[j],a[j-1] = a[j-1],a[j]
      j = j - 1
    end
  end
end

function sort_objects(a)
  --for i=1,#a do
  for i=1,#a do
     j = i
   while j > 1 and a[j-1].tz < a[j].tz do --vertex_list[a[j-1][1]][6] > vertex_list[a[j][1]][6] do
   --while j > 1 and z_min(j-1) < z_min(j) do --vertex_list[a[j-1][1]][6] > vertex_list[a[j][1]][6] do
      a[j],a[j-1] = a[j-1],a[j]
      j = j - 1
    end
  end
end



function	handle_buttons()
	--if(btn(1))then caz+=.005 end
	--if(btn(0))then caz+=-.005 end
	--camera_angle=mid(camera_angle,-.125,.125)
	
	--if(btn(2)) then cax+=.005 end
	--if(btn(3)) then	cax+=-.005	end
	
	cax*=k_angle_friction
	cay*=k_angle_friction
	caz*=k_angle_friction
	

	
	if(btn(0)) then	caz+=-k_angle_acel 	end

	if(btn(1)) then	caz+=k_angle_acel	end
	

	
	if(btn(2)) then cax+=k_angle_acel end
	if(btn(3)) then cax+=-k_angle_acel end
	
	
	


	
	if(btn(4))then
	
		if(ship_power>25)then
			ship_power-=laser_power*2
			if(not fire_shot) then music(11,120,3) end
			fire_shot=true
			
		else
		fire_shot=false
		music(-1)
		end
	else
		fire_shot=false
		music(-1)
	end
	
		if(btn(5)) then
		
		cur_speed+=k_acel_speed
		
		--cam_x+=sin(cay+.5)*.4
		--cam_z+=cos(cay+.5)*.4
	end
	
	
	
	cur_speed*=k_acel_fric
	cur_speed=mid(cur_speed,k_min_speed,k_max_speed)
	

	
	--generate_transform(-cax,-cay,-caz)
	--generate_inverse_transform(-cax,-cay,-caz)
	--cam_dir_x,cam_dir_y,cam_dir_z=rotate_point(0,0,.5)
	--
	--cam_x+=cam_dir_x
	--cam_y+=cam_dir_y
	--cam_z+=cam_dir_z
	

	
	
end

k_star_number = 50
k_star_dist  = 100
function initialize_stars()
	
	for i=1, k_star_number do
		a1=rnd(1)
		a2=rnd(1)
		
		px=k_star_dist*cos(a1)
		temp=k_star_dist*sin(a1)
		py=temp*sin(a2)
		pz=temp*cos(a2)
		
		star_list[i]={}
		star_list[i][k_x]=px
		star_list[i][k_y]=py
		star_list[i][k_z]=pz
		
		star_list[i][4]=rnd(2)
		
		temp=flr(rnd(4))
		if(temp==0)then star_list[i][5] = 1
		elseif(temp==1)then star_list[i][5] = 5
		elseif(temp==2)then star_list[i][5] = 6
		else star_list[i][5] = 7 end
		
	
	end
	


end

function draw_stars()
	
	for i=1, #star_list do
		
		
		
		p1x,p1y,p1z = rotate_point(star_list[i][k_x],star_list[i][k_y],star_list[i][k_z],camera_matrix)
		
		if(p1z>k_z_clip)then
			
			sx=(p1x*k_screen_scale)/-p1z+k_x_center
			sy=(p1y*k_screen_scale)/-p1z+k_y_center
		
			circfill(sx,sy,star_list[i][4],star_list[i][5])
		end
	end

end

function draw_cockpit()

	palt(14,true)
	palt(0,false)

	spr(64,0,128-32,8,4)
	spr(64,64,128-32,8,4,true,false)
	
	spr(0,0,0,8,4)
	spr(0,64,0,8,4,true,false)
	
	for y=32,128-40,8 do
		spr(64,0,y)
		spr(64,128-8,y,1,1,true,false)
	end	
	
	palt()
	
end

function redraw_cockpit()

	palt(14,true)
	palt(0,false)

	spr(64,0,128-32,8,2)
	spr(64,64,128-32,8,2,true,false)
	
	spr(0,0,0,8,4)
	spr(0,64,0,8,4,true,false)
	
	--for y=24,128-40,8 do
	--	spr(32,0,y)
	--	spr(32,128-8,y,1,1,true,false)
	--end	
	
	palt()

end

function draw_laser_beam()
	-- [n [fade_len [channel_mask]]]
	for i=1,5 do
	
		temp=flr(rnd(4))
		
		if(temp==0)then c=2
		elseif(temp==1)then c=8
		elseif(temp==2)then c=9
		else  c=8
		end
	
		line(50-rnd(6),100,k_x_center-0-rnd(2),k_y_center+2,c)
		line(74+rnd(6),100,k_x_center-0+rnd(2),k_y_center+2,c)
	end
	
end

function handle_collide()
	if(collided_object!=nil)then
		for i=1, 15 do
			ly=flr(rnd(k_max_y-k_min_y)+k_min_y)
			rectfill(k_min_x,ly,k_max_x,ly+2,7)
		end
		
		ship_power-=k_collide_damage
		sfx(14)
		
		if(collided_object.type==k_asteroid_type or collided_object.type==k_giant_asteroid_type )then
			collided_object.hp=-1
		end
		
		
	end
	collided_object=nil
end

function handle_drain()
	if(power_draining)then
		for i=1, 15 do
			ly=flr(rnd(k_max_y-k_min_y)+k_min_y)
			rectfill(k_min_x,ly,k_max_x,ly+2,8)
		end
		
		ship_power-=k_draining_damage
		

		
		
	end
end


k_simp_map_width = 10
k_simp_map_extent = 200
function draw_simple_map()
	center_x = 64
	center_y = 112
	
	rectfill(center_x-k_simp_map_width,center_y-k_simp_map_width,center_x+k_simp_map_width,center_y+k_simp_map_width,0)
	
	
	step=1
	start=cur_frame%step+1
	
	
	for i=start,#object_list,step do
		ox=object_list[i].sx-k_x_center
		oy=object_list[i].sy-k_y_center
		
		scale= k_simp_map_width/k_simp_map_extent
		view_extend = 64*scale
		
		rect(-view_extend+center_x,-view_extend+center_y,view_extend+center_x,view_extend+center_y,3)
		
		if(ox>-k_simp_map_extent and ox<k_simp_map_extent and oy>-k_simp_map_extent and oy<k_simp_map_extent
		   and object_list[i].tz>0) then
		   
		   
		   
			ox*=scale
			oy*=scale
			
			color=3
			if(object_list[i].type==k_giant_asteroid_type)then color=11 end
			if(object_list[i].type==k_asteroid_type)then color=3 end
			if(object_list[i].type==k_torment_type)then color=8 end
			if(object_list[i].type==k_turret_type)then color=12 end
			
			pset(ox+center_x,oy+center_y,color)
		end
		
		pset(center_x,center_y,12)
	end
end

k_max_dist=1000
function check_shot()
	
	if(hit_object!=nil) then
		
		if(hit_object.hp!=nil) then
			hit_object.hp-=laser_power
			
				p1x=world_vertex_list[world_face_list[hit_face][1]][k_sx]
				p1y=world_vertex_list[world_face_list[hit_face][1]][k_sy]
				p2x=world_vertex_list[world_face_list[hit_face][2]][k_sx]
				p2y=world_vertex_list[world_face_list[hit_face][2]][k_sy]
				p3x=world_vertex_list[world_face_list[hit_face][3]][k_sx]
				p3y=world_vertex_list[world_face_list[hit_face][3]][k_sy]
				
				
				
				--if(cross_product_2d(p1x,p1y,p2x,p2y,p3x,p3y))then
				solid_trifill( p1x,
								p1y,
								p2x,
								p2y,
								p3x,
								p3y,
								8, world_face_list[hit_face][5])
			
		end
			
	end
	
	hit_object=nil
	

end


function draw_crosshairs()

	line(k_x_center-10,k_y_center,k_x_center-4,k_y_center,5)
	line(k_x_center+10,k_y_center,k_x_center+4,k_y_center,5)

end

k_power_length=40
k_power_start=15
function draw_top_hud()

	if(ship_power/k_max_ship_power>.3) then c1=1 c2=3 c3=11 else
		c1=1 c2=4 c3=9
	end
	
	
	rectfill(k_power_start-2,9,k_power_start+k_power_length*(ship_power/k_max_ship_power)+2,15,c1)
	rectfill(k_power_start-1,10,k_power_start+k_power_length*(ship_power/k_max_ship_power)+1,14,c2)
	rectfill(k_power_start,11,k_power_start+k_power_length*(ship_power/k_max_ship_power),13,c3)

	print(player_score,80,10,11)
	--print(count,100,10,11)
end

function new_asteroid(x,y,z)

	
	asteroid=new_object(big_rock_vertices,big_rock_faces,rnd(2*k_world_width)-k_world_width,rnd(2*k_world_width)-k_world_width,rnd(2*k_world_width)-k_world_width,rnd(1),rnd(1),rnd(1),6,false,k_asteroid_type)
	
	if(x!=nil)then asteroid.x=x end
	if(y!=nil)then asteroid.y=y end
	if(z!=nil)then asteroid.z=z end
	
	asteroid.vax=rnd(.01)-.005
	asteroid.vay=rnd(.01)-.005
	asteroid.vaz=rnd(.01)-.005
	asteroid.hp=3
	
	asteroid.vx=rnd(1)-.5
	asteroid.vy=rnd(1)-.5
	asteroid.vz=rnd(1)-.5
	
	asteroid.score=10
	return asteroid
end

function new_giant_asteroid(x,y,z)

	
	asteroid=new_object(giant_rock_vertices,giant_rock_faces,rnd(2*k_world_width)-k_world_width,rnd(2*k_world_width)-k_world_width,rnd(2*k_world_width)-k_world_width,rnd(1),rnd(1),rnd(1),4,false,k_giant_asteroid_type)
	
	if(x!=nil)then asteroid.x=x end
	if(y!=nil)then asteroid.y=y end
	if(z!=nil)then asteroid.z=z end
	
	asteroid.vax=rnd(.01)-.005
	asteroid.vay=rnd(.01)-.005
	asteroid.vaz=rnd(.01)-.005
	asteroid.hp=5
	
	asteroid.vx=rnd(1)-.5
	asteroid.vy=rnd(1)-.5
	asteroid.vz=rnd(1)-.5
	
	asteroid.score=15
	return asteroid
end


function new_torment(x,y,z)

	
	torment=new_object(torment_vertices,torment_faces,rnd(2*k_world_width)-k_world_width,rnd(2*k_world_width)-k_world_width,rnd(2*k_world_width)-k_world_width,rnd(1),rnd(1),rnd(1),2,false,k_torment_type)
	
	if(x!=nil)then toment.x=x end
	if(y!=nil)then toment.y=y end
	if(z!=nil)then toment.z=z end
	--torment.vax=rnd(.01)-.005
	--torment.vay=rnd(.01)-.005
	--torment.vaz=rnd(.01)-.005
	torment.hp=1
	torment.vx=rnd(1)-.5
	torment.vy=rnd(1)-.5
	torment.vz=rnd(1)-.5
	
	torment.score=40
end


function new_turret(x,y,z)

	
	turret=new_object(turret_vertices,turret_faces,rnd(2*k_world_width)-k_world_width,rnd(2*k_world_width)-k_world_width,rnd(2*k_world_width)-k_world_width,rnd(1),rnd(1),rnd(1),12,false,k_turret_type)
	
	if(x!=nil)then turret.x=x end
	if(y!=nil)then turret.y=y end
	if(z!=nil)then turret.z=z end
	--torment.vax=rnd(.01)-.005
	--torment.vay=rnd(.01)-.005
	--torment.vaz=rnd(.01)-.005
	turret.hp=2
	turret.score=50
	
	
end

function new_shot(x,y,z,vx,vy,vz)

	
	shot=new_object(shot_vertices,shot_faces,rnd(2*k_world_width)-k_world_width,rnd(2*k_world_width)-k_world_width,rnd(2*k_world_width)-k_world_width,rnd(1),rnd(1),rnd(1),10,false,k_shot_type)
	
	if(x!=nil)then shot.x=x end
	if(y!=nil)then shot.y=y end
	if(z!=nil)then shot.z=z end
	
	if(vx!=nil)then shot.vx=vx end
	if(vy!=nil)then shot.vy=vy end
	if(vz!=nil)then shot.vz=vz end
	
	--torment.vax=rnd(.01)-.005
	--torment.vay=rnd(.01)-.005
	--torment.vaz=rnd(.01)-.005
	shot.hp=nil
	shot.life=250
	shot.radius=8
	
	
end

function new_rubble(x,y,z)
		p=new_object(pyramid_vertices,pyramid_faces,x,y,z,rnd(1),rnd(1),rnd(1),6,false,k_rubble_type)
		p.vx=rnd(.5)-.25
		p.vy=rnd(.5)-.25
		p.vz=rnd(.5)-.25
		
		p.vax=rnd(.1)-.05
		p.vay=rnd(.1)-.05
		p.vay=rnd(.1)-.05
		
		p.life=250
end

function print_message(the_string,y)
	local i
	--center string
	local width = 4*#the_string
	local x = flr(( 128-width)/2)-4	
	--draw window
	rectfill(x,y-4,x+width+6,y+8,0)
	rect(x,y-4,x+width+6,y+8,3)
	
		
	print(the_string,x+4,y,11)	
		

	
end

k_world_limit=30
function populate_world()
	--count the real objects in the world (not rubble or shots)
	count=0
	for object in all(object_list) do
		if(object.type!=k_rubble_type or object.type!=k_shot_type) then
			count+=1
		end
	end
	
	for i=1,k_world_limit-count do
		
		v=rnd(100)
		if(v<70)then new_asteroid()
		elseif(v<90)then new_giant_asteroid()
		elseif(v<95)then new_torment()
		else new_turret()
		end
	end
	
end

function shadow_text(text,x,y,c1,c2)
	print(text,x+1,y,c2)
	print(text,x-1,y,c2)
	print(text,x,y-1,c2)
	print(text,x,y+1,c2)
	
	print(text,x+1,y-1,c2)
	print(text,x-1,y+1,c2)
	print(text,x+1,y-1,c2)
	print(text,x-1,y+1,c2)
	
	print(text,x,y,c1)
	
	
	
	for j=0,3 do
	char=flr(cur_frame/5+j*4)%#text+1
	print(sub(text,char,char),x+4*(char-1),y,6)
	
	char=flr(cur_frame/5+1+j*4)%#text+1
	print(sub(text,char,char),x+4*(char-1),y,13)
	
	char=flr(cur_frame/5-1+j*4)%#text+1
	print(sub(text,char,char),x+4*(char-1),y,13)
	end
	
end

function draw_title()
	cls()
	
	generate_transform(0,.003,0,delta_matrix)
	camera_matrix = matrix_multiply(  camera_matrix, delta_matrix)
	
	draw_stars()
	
	spr(128,0,32,16,8)
	
	shadow_text("x to start",80,120,5,1)
	
	shadow_text("music: robby duguay",5,8,5,1)
	shadow_text("code + gfx: electric gryphon",5,16,5,1)
	
end

function draw_game_over()
	cls()
	
	generate_transform(0,.003,0,delta_matrix)
	camera_matrix = matrix_multiply(  camera_matrix, delta_matrix)
	
	draw_stars()
	
	print_message("game over",64)
	
	print("x to start",80,120,7)
end


function play_explode()
	sfx(10,-1,flr(rnd(10)))
	sfx(11,-1,flr(rnd(10)))
end

function _init()
	cls()
	--init_z_buffer()
	
	initialize_stars()
	
	
	--car1=new_object(zoomer_vertices,zoomer_faces,0,0,0,0,0,0,15,false)
	--car2=new_object(zoomer_vertices,zoomer_faces,0,0,0,0,0,0,12,false)
	
	--car3=new_object(zoomer_vertices,zoomer_faces,0,4,0,0,0,0,12,false)
	--car4=new_object(zoomer_vertices,zoomer_faces,-3,0,8,0,0,0,12,false)
	

	
	--for i=1,5 do
	--cur_gate=new_object(zoomer_vertices,zoomer_faces,rnd(100)-50,rnd(100)-50,rnd(100)-50,rnd(1),0,0,flr(rnd(15))+1,false)
	--end
	
	asteroid={}
	
	for i=1,30 do
		populate_world()
	end
	
	
	

	
--	howl=new_object(howler_vertices,howler_faces,0,0,0,0,0,0,15,false)
	
	--color_faces()
	--generate_stars()
	
	draw_cockpit()
	
	music(0)
end



function _update()


	if(game_mode==k_play_mode)then

		power_draining=false
		hit_object=nil
		hit_face=nil
		
		ship_power+=k_power_regen
		ship_power=min(ship_power,k_max_ship_power)
		
		
		handle_buttons()
		
		for object in all(object_list) do
			update_object(object)
		end
		
		generate_transform(cax,cay,caz,delta_matrix)
		camera_matrix = matrix_multiply(  camera_matrix, delta_matrix)
		
		unspin = matrix_inverse( camera_matrix)
		
		
		--focus.x=ux+cam_x
		--focus.y=uy+cam_y
		--focus.z=uz+cam_z
		
		cam_vx,cam_vy,cam_vz = rotate_point(0,0,cur_speed,unspin)
		
		cam_x+=cam_vx
		cam_y+=cam_vy
		cam_z+=cam_vz
		--cam_x+=vx
		--cam_y+=vy
		--cam_z+=-vz
		
		out_of_bounds=false
		if(cam_x>k_world_width or cam_x<-k_world_width or cam_y>k_world_width or cam_y<-k_world_width
		or cam_z>k_world_width or cam_z<-k_world_width)then out_of_bounds=true end
		
		if(cam_x>k_player_world_width)then cam_x=-k_world_width end
		if(cam_x<-k_player_world_width)then cam_x=k_world_width end
		
		if(cam_y>k_player_world_width)then cam_y=-k_world_width end
		if(cam_y<-k_player_world_width)then cam_y=k_world_width end
												  
		if(cam_z>k_player_world_width)then cam_z=-k_world_width end
		if(cam_z<-k_player_world_width)then cam_z=k_world_width end
	
		
	
		if(ship_power<=0)then
			game_mode=k_game_over_mode
			wait_frame=cur_frame
		end
	
	end
	
	
	
	if(game_mode==k_title_mode)then
		if(cur_frame-wait_frame>20 and btn(5))then
			cls()
			draw_cockpit()
			game_mode=k_play_mode
			
			player_score=0
			ship_power=k_max_ship_power
		end
	end
	
	if(game_mode==k_game_over_mode)then
		if(cur_frame-wait_frame>20 and btn(5))then
			cls()
			game_mode=k_title_mode
			wait_frame=cur_frame
			music(0,120,3)
		end
	end
	
end

cur_frame=0
function _draw()

	cur_frame+=1

	if(game_mode==k_play_mode)then
		--draw_stars()
		
		
		--if(cur_frame%100==0)then color_faces() end
		
		
		

		
		transform_objects()	
		render_objects()
		
		
		
		--color_object(car1,false)
		--color_object(car2,false)
		--color_object(car3,false)
		--color_object(car4,false)
		
		rectfill(k_min_x,k_min_y,k_max_x,k_max_y,0)
		clip(k_min_x,k_min_y,k_max_x-k_min_x+1,k_max_y-k_min_y+1)
		
		palt()
		
		draw_stars()
		draw_scene()
		
		
		-- draw_large_map()
		
		if(fire_shot)then
			draw_laser_beam()
		end
		
		if( out_of_bounds)then
			if( flr(cur_frame/20)%4==1) then print_message("out of field",40) 
			elseif( flr(cur_frame/20)%4==3) then print_message("prepare teleport",40) 
			end
		end
		
		handle_collide()
		handle_drain()
		
		if(fire_shot)then
			check_shot()
		end
		
		draw_crosshairs()
		
		
		
		clip()
			
		
		redraw_cockpit()
		draw_simple_map()
		draw_top_hud()
		
		finish_frame()
	end
	
	if(game_mode==k_title_mode)then
		draw_title()
	end
	
	if(game_mode==k_game_over_mode)then
		draw_game_over()
	end
	
	--print(stat(1),0,0,8)
end

function finish_frame()

	--we use our triangle rasterizer to scan for hits... so have to 
	--wait until the end of the frame to figure out if we have hit something
	
	
	
	
	--if(hit_object!=nil) then
	--	del(object_list,hit_object)
	--end
	
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111111111111111111111111111111111111111111111111111111111110000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111111111111111111111111111111111111111111111111111111111110000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111115555555555555555555555555555555555555555555555555555550000000000000000000000000000000000000000000000000000000000000000
00000000666666666666666666666666666666666666666666666666666666660000000000000000000000000000000000000000000000000000000000000000
11111155555555555555555555555555555555555555555555555555555555560000000000000000000000000000000000000000000000000000000000000000
0000055d666500000000000000000000000000000000000000000000000556660000000000000000000000000000000000000000000000000000000000000000
11111555dd0000000000000000000000000000000000000000000000000055560000000000000000000000000000000000000000000000000000000000000000
000055d6600000000000000000000000000000000000000000000000000005660000000000000000000000000000000000000000000000000000000000000000
1111555dd00000000000000000000000000000000000000000000000000005560000000000000000000000000000000000000000000000000000000000000000
00005d66000000000000000000000000000000000000000000000000000005660000000000000000000000000000000000000000000000000000000000000000
111555dd000000000000000000000000000000000000000000000000000005560000000000000000000000000000000000000000000000000000000000000000
0005dd66000000000000000000000000000000000000000000000000000005660000000000000000000000000000000000000000000000000000000000000000
111555dd000000000000000000000000000000000000000000000000000005560000000000000000000000000000000000000000000000000000000000000000
0005dd66000000000000000000000000000000000000000000000000000005660000000000000000000000000000000000000000000000000000000000000000
111555dd111111111111111111111111111111111111111111111111111111110000000000000000000000000000000000000000000000000000000000000000
000ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0000000000000000000000000000000000000000000000000000000000000000
11dddddddddd66666666666666666666666666666666666666666666666666660000000000000000000000000000000000000000000000000000000000000000
00dddd666666dddddddddddddddddddddddddddddddddddddddddddddddddddd0000000000000000000000000000000000000000000000000000000000000000
11dddddd66ddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000
00dd6666dddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000
11dddd6ddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000
00d666ddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000
11ddd6dddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000
00d66dddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000
11dd6ddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000
00d6dddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000
11d6ddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000
00d6ddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000
11d6ddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000
00d66eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeddddddddddddddddddddddddddd0000000000000000000000000000000000000000000000000000000000000000
11d6deeeeeeeeeeeeeeeeeeeeeeeeeeeedddd5555555555555555555555555550000000000000000000000000000000000000000000000000000000000000000
00d66eeeeeeeeeeeeeeeeeeeeeeeedddd55555555555555555555555555555550000000000000000000000000000000000000000000000000000000000000000
11d6deeeeeeeeeeeeeeeeeeeeeddd555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00d66eeeeeeeeeeeeeeeeeeddd555555500001111111111110555555555555550000000000000000000000000000000000000000000000000000000000000000
11d6deeeeeeeeeeeeeeeddd555555550055555555555555505511111111111110000000000000000000000000000000000000000000000000000000000000000
00d66eeeeeeeeeeeeddd555555566501110000000000111105100000000000000000000000000000000000000000000000000000000000000000000000000000
11d6deeeeeeeeed66ddd555556665055550555555550555505100000000000000000000000000000000000000000000000000000000000000000000000000000
00d666eeeeedddddd555555566650111110500000050111105100000000000000000000000000000000000000000000000000000000000000000000000000000
11d66dddddd666d5550055566650555555050bb00050555505100000000000000000000000000000000000000000000000000000000000000000000000000000
00dd66666dddd5550005556666501111110500000050111105100000000000000000000000000000000000000000000000000000000000000000000000000000
11ddd66dddd555501055567665055555550500bb0050555505100000000000000000000000000000000000000000000000000000000000000000000000000000
005dddddd55550010555567665011111110500000050111105100000000000000000000000000000000000000000000000000000000000000000000000000000
1155ddd5555001105555676650555555550566666650555505100000000000000000000000000000000000000000000000000000000000000000000000000000
0005555550000005d555676650111111110555555550111105100000000000000000000000000000000000000000000000000000000000000000000000000000
111055500111105d5556776650555555550000000000555505100000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000005dd5556776501111111111111111111111105100000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111105dd55567766505555555550000000000555505100000000000000000000000000000000000000000000000000000000000000000000000000000
000000000005ddd55567766501111111110555555550111105100000000000000000000000000000000000000000000000000000000000000000000000000000
11111111105ddd555677766505555555550500000050555505100000000000000000000000000000000000000000000000000000000000000000000000000000
0000000005ddddd5567776650111111111050bb00050111105100000000000000000000000000000000000000000000000000000000000000000000000000000
111111105ddddd555677766505555555550500000050555505100000000000000000000000000000000000000000000000000000000000000000000000000000
00000005ddddddd55667766650111111110500bb0050111105100000000000000000000000000000000000000000000000000000000000000000000000000000
11111055ddddd5555667766650555555550500000050555505100000000000000000000000000000000000000000000000000000000000000000000000000000
0000055dd66dddd55566776665011111110566666650111105100000000000000000000000000000000000000000000000000000000000000000000000000000
111055ddddddd5555566676665055555550555555550555505100000000000000000000000000000000000000000000000000000000000000000000000000000
00055dd666dddddd5556666666501111110000000000111105100000000000000000000000000000000000000000000000000000000000000000000000000000
10555ddddddd55555556666666650055555555555555555505566666666666660000000000000000000000000000000000000000000000000000000000000000
0555dd666dddddddd555666666665500111111111111111110555555555555550000000000000000000000000000000000000000000000000000000000000000
555ddddddddd55555555566666666655000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55dd6666ddddddddddd5556666666666555555555555555555555555555555550000000000000000000000000000000000000000000000000000000000000000
5ddddddddddd55555555555666666666666666666666666666666666666666660000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000005d777500000001f70000000000000000000000001f7000000000d7d00000000000000000000000000000000000000000
0000000000000000000000000000000d7777776000000d77500000000000000000000000d7710000000177d00000000000000000000000000000000000000000
000000000000000000000000000000677777777d0000067750000000000000000000000067750000000577650000000000000000000000000000000000000000
00000000000000000000000000000d777d5567770000077651000000000000000000000077651000000d77d50000000000000000000000000000000000000000
00000000000000000000000000000777555557775000577650000000000000000000000577650000000677550000000000000000000000000000000000000000
0000000000000000000000000000d77d551007775000577d50000000000000000000000577d5000000077f510000000000000000000000000000000000000000
0000000000000000000000000000d77d500006765000677777710000001d777d1000000677550000001776500000000005677750000000000567710000000000
00000000000000000000000000006775500001d5500077777775000005777777750000077751000000577d500000000067777776000000016777750000000000
00000000000000000000000000007765000000555001777777650000d7777777770000177650000000d77d500000001f777777775000001f7777650000000000
00000000000000000000000000057765000000050005776555551005777d55d77750005776500000006775500000006776d556776000006776d5551000000000
000000000000000000000000000177f500000000000d77d5555500067755555677d000d77d5000000077f5100000057765555d77750005776555550000000000
000000000000000000000000000177760000000000067755000000177655500677d50067755000000577650000000d77d5500177650006775550000000000000
000000000000000000000000000067777765000000077755000000577d50001777510077751000000577d5000000067655000577650007775500000000000000
00000000000000000000000000005777777750000017765000000067755005777d500177650000000677d500000000d550000d77d50017765000000000000000
000000000000000000000000000005677777750000577650000000677777777765500577d50000000f7751000000005d67777777550057765000000000000000
000000000000000000000000000000555d777d0000d77d50000000777777777d55500d77d50000000776500000000067777777775100d77d5000000000000000
0000000000000000000000000000000555d776100067755000000577777776555500067755000000577650000000067777777776500067755000000000000000
00000000000000000000000000000000005776500077651000000d77d55555555000077650000000d77d50000000d77fd555d77d500077751000000000000000
0000000000000000000000000015000000d775500577650000000d7755555555000057765000000067755000000077755555677d500177650000000000000000
00000000000000000000000005771000006775500577d50000000777510001775000577d50000000f7751000000d77d55100f775500577d50000000000000000
0000000000000000000000000d775000007775100677d5000000177650000d77d000677d5000000177650000000d77d500017765100677d50000000000000000
0000000000000000000000000677d0000d7765000677d5000000577f500017775100677d5000000577650000000677d5000d7765000677550000000000000000
0000000000000000000000000d777500d77755000d77f500000017776005f77d5100d77f5000000177760000000d77750067775500077f500000000000000000
00000000000000d67765000005777777777d55000577777500000f77777777655000577777500000677776000005777777777d55005776500000000000000000
00000000000057777777500000d7777777d55000006777760000057777777d555000067777600000577777100000d7777777555000577d500000000000000000
000000000001777777777000001d7777d5551000000d77655000005677765555000000d7765500000567765000001d7777d55510005765500000000000000000
00000000000777655d777d0000055555555000000005555550000015555555500000005555550000005555510000055555555000000555100000000000000000
0000000000d7765555d7760000001555550000000000155500000000555550000000000155500000000555500000001555550000000155000000000000000000
000000000077755100d7760000050000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000177651000577550017750000057700000057d0000000567775000000000056777500000000015777d10000000000000000000000000000000000000
0000000005776500000d55100577d000006771000007760000016777777600000001677777760000000577777775000000000000000000000000000000000000
000000000d77d100000055000677d10000777500005776100017777777775000001777777777500000d777777776000000000000000000000000000000000000
000000000677550000001000067750000177650000d77d5000f776555677600000f776555677600005777d55d777500000000000000000000000000000000000
000000000677d00000000000077651000577d50000677510057765555d777100057765555d7771000677d5555677d00000000000000000000000000000000000
000000000d77f50000000000577650000677410000f775000d775550057765000d77555005776500177655100d77d00000000000000000000000000000000000
0000000005777777d0000000577d50000677510001776500077651000d77d500077651000d77d500577d50000677510000000000000000000000000000000000
000000000067777776100000677d0000077650000577d50017765001d777550017765001d7775500d77d50000777500000000000000000000000000000000000
00000000000d77777760000077755000577650000d77d50057777777777551005777777777755100677500001776500000000000000000000000000000000000
00000000000155567770000077650000577d500006775100d777777776d55000d777777776d5500077f50000577d500000000000000000000000000000000000
0000000000000555777500057765000067751000077f50006777777fd55500006777777fd5550005776500006775500000000000000000000000000000000000
00000000000000006775000d77d5000077750000577650007765555555500000776555555550000577d500006775100000000000000000000000000000000000
0000000050000000776500067751000077650000577d500177655555551000017765555555100006775100007765000000000000000000000000000000000000
00000006760000057765000777500005776500006775500577d5000067f0000577d5000067f0000f775000057765000000000000000000000000000000000000
000000177600000d77d500177650000d77d5000077751006774100007760000677410000776000177650000d77d5000000000000000000000000000000000000
000000577650001f775100577f50001777d100057765000677d1000677d5000677d1000677d500577650001f7751000000000000000000000000000000000000
0000000777d005677650000777d00577777500d77755000d777501d77755000d777501d7775500d777d005777d50000000000000000000000000000000000000
00000006777777776550000677777777777777777d51000577777777755100057777777775510067777777776550000000000000000000000000000000000000
00000001777777765510000177777776d7777777d5500000677777765550000067777776555000f7777777765510000000000000000000000000000000000000
00000000567776d555000000567776d55df777d5551000000d777665550000000d77766555000177667776d55500000000000000000000000000000000000000
00000000055555551000000005555555115555555000000005555555500000000555555550000577655555551000000000000000000000000000000000000000
00000000001555500000000000155550000555510000000000055551000000000005555100000d77551555500000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000677510000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000776500000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000001776500000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000775500000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000055100000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000055000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
010101010101010101090b010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100090b090b0100003e00000100000000000001010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000100000000000100000000000001212128282821212121010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0900000000000100000000000100003100000001212121212121212121010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0b00310000000101400000420100310031000040212121212121212121010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0931003100000000000000000000310031000021212121212121212121010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0b00310000000000000000000000003100002121212121212121212121010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000000003434343400000000000042212121212121282828010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0300000000000000003434343400000000000003212121212121010101010101010101030101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000000003434343400000000000001212121212121402a2a2a2a2a2a2a2a2a2a01000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01000000000000000034343434000000000000012121212121212a2a2a2325252525242a2a01000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01000000000000000000000000000000000000012121212121212a2a2a2325252525242a2a01000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000000000000000000000000000001362828282836422a2a2a2a2a2a2a2a2a2a01000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101402121420101010101010101010101010101010101010301014031314201000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000121212121010505050505050505050d0d0d0d0d0d0d0d0d0d0d0d31310d0d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000121222121010521223a3a3a3a3a050d313131310d3131313131313131310d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000012121212101052221222122213a050d313131310d3131313131313131310d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000321212121212121222122212207050d313131310d313131310d313131310d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000121222121212122212221222107050d0d0d31310d313131310d313131310d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000012121212101052122212221223a050d3131313131313131310d313131310d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000001212121210105222122213a3a3a050d3131313131313131310d313131310d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000101010101010505260505050505050d0d0d31310d0d0d0d0d0d0d0d0d0d0d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000d3131313131310d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000d3131313131310d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000d2b2b2b2b2b2b0d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000d2b2b2b2b2b2b0d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000d2b2b2b2b2b2b0d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000d2b2b2b2b2b2b0d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000d0d2c2c2c2c0d0d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
011800200c0351004515055170550c0351004515055170550c0351004513055180550c0351004513055180550c0351104513055150550c0351104513055150550c0351104513055150550c035110451305515055
010c0020102451c0071c007102351c0071c007102251c007000001022510005000001021500000000001021013245000001320013235000001320013225000001320013225000001320013215000001320013215
003000202874028740287302872026740267301c7401c7301d7401d7401d7401d7401d7301d7301d7201d72023740237402373023720267402674026730267201c7401c7401c7401c7401c7301c7301c7201c720
0030002000040000400003000030020400203004040040300504005040050300503005020050200502005020070400704007030070300b0400b0400b0300b0300c0400c0400c0300c0300c0200c0200c0200c020
00180020176151761515615126150e6150c6150b6150c6151161514615126150d6150e61513615146150e615136151761517615156151461513615126150f6150e6150a615076150561504615026150161501615
00180020010630170000000010631f633000000000000000010630000000000000001f633000000000000000010630000000000010631f633000000000000000010630000001063000001f633000000000000000
001800200e0351003511035150350e0351003511035150350e0351003511035150350e0351003511035150350c0350e03510035130350c0350e03510035130350c0350e03510035130350c0350e0351003513035
011800101154300000000001054300000000000e55300000000000c553000000b5630956300003075730c00300000000000000000000000000000000000000000000000000000000000000000000000000000000
003000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01240020051450c145051450c145051450c145051450c145071450e145071450e145071450e145071450e1450d145141450d145141450d145141450d145141450c145071450c145071450c145071450c14507145
0004000012650156501865018640196301963018650176501564013640106300d6200961004610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400000461004620046200362002630036200562006630086300863007630056300563005620056100563000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000242002430024400244002440024400242002420024100241001420014300144001440014500143001430014200142001420014300143001440014500145001450014400144001420014200141001410
000200000332003320033300333003320033200331003310033200332003320033300333003330033300333003330033300332003310033100331002320023300234002330023300432005310053100531005320
000300000a6700967014770127700f7700e7700c7700b7700a7700977003340023400234000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000070300a0200f0200f02016020190200940004400024000140001400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001c57019570205302053020530125701357000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
003000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
01 08 00 43 44
00 08 01 43 00
00 03 01 43 00
00 02 03 05 00
00 02 03 05 00
00 03 42 43 00
00 08 01 43 00
00 03 04 05 00
00 03 02 05 00
00 03 02 05 00
02 08 01 07 06
00 0c 0d 43 44
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
