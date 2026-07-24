pico-8 cartridge // http://www.pico-8.com
version 8
__lua__




------------------------------------------------------------begin hex string data handling--------------------------------

hex_string_data = "0123456789abcdef"
char_to_hex = {}
for i=1,#hex_string_data do
	char_to_hex[sub(hex_string_data,i,i)]=i-1
end

function read_byte(string)
	return char_to_hex[sub(string,1,1)]*16+char_to_hex[sub(string,2,2)]
end

function read_2byte_fixed(string)
	local a=read_byte(sub(string,1,2))
	local b=read_byte(sub(string,3,4))
	local val =a*256+b
	return val/256
end

cur_string=""
cur_string_index=1
function load_string(string)
	cur_string=string
	cur_string_index=1
end

function read_vector()
	v={}
	for i=1,3 do
		text=sub(cur_string,cur_string_index,cur_string_index+4)
		value=read_2byte_fixed(text)
		v[i]=value
		cur_string_index+=4
	end
	return v
end

function read_face()
	f={}
	for i=1,3 do
		text=sub(cur_string,cur_string_index,cur_string_index+2)
		value=read_byte(text)
		f[i]=value
		cur_string_index+=2
	end
	return f
end		

function read_uv()
	uv={}
	--for i=1,2 do
		text=sub(cur_string,cur_string_index,cur_string_index+4)
		value=read_2byte_fixed(text)
		uv[1]=value*128
		cur_string_index+=4
		text=sub(cur_string,cur_string_index,cur_string_index+4)
		value=read_2byte_fixed(text)
		uv[2]=128-value*128
		cur_string_index+=4
	--end
	return uv
end

function read_texture_face()
	f={}
	for i=1,3 do
		text=sub(cur_string,cur_string_index,cur_string_index+2)
		value=read_byte(text)
		f[i]=value
		cur_string_index+=2
		
		text=sub(cur_string,cur_string_index,cur_string_index+2)
		value=read_byte(text)
		f[i+6]=value
		cur_string_index+=2
		
		
		
	end
		
	--print(f[1]..","..f[4].."/"..f[2]..","..f[5].."/"..f[3]..","..f[6])
	
	return f
end		

function read_vector_string(string)
	vector_list={}
	load_string(string)
	while(cur_string_index<#string)do
		vector=read_vector()
		add(vector_list,vector)
	end
		return vector_list
end

function read_face_string(string)
	face_list={}
	load_string(string)
	while(cur_string_index<#string)do
		face=read_face()
		add(face_list,face)
	end
	
		
	
		return face_list
end

function read_uv_string(string)
	uv_list={}
	load_string(string)
	while(cur_string_index<#string)do
		uv=read_uv()
		add(uv_list,uv)
	end
		return uv_list
end

function read_texture_face_string(string)
	face_list={}
	load_string(string)
	while(cur_string_index<#string)do
		face=read_texture_face()
		add(face_list,face)
	end
	
	--pause()
		return face_list
end

------------------------------------------------------------end hex string data handling--------------------------------


-------------------------------------------------------------begin cut here-------------------------------------------------
------------------------------------------------------electric gryphon's 3d library-----------------------------------------
----------------------------------------------------------------------------------------------------------------------------

k_base_color=4
k_color_brightness=5

k_screen_scale=120
k_x_center=64
k_y_center=64



z_clip=-1.5
z_max=-50

k_min_x=0
k_max_x=128
k_min_y=0
k_max_y=128


cam_ax=0
cam_ay=0
cam_az=0
cam_x=0
cam_y=0
cam_z=15

	


light1_x=.1
light1_y=.35
light1_z=.2

--t_light gets written to
t_light_x=0
t_light_y=0
t_light_z=0

function init_light()
	light1_x,light1_y,light1_z=normalize(light1_x,light1_y,light1_z)
end

function update_light()
	t_light_x,t_light_y,t_light_z = rotate_cam_point(light1_x,light1_y,light1_z)
end

function normalize(x,y,z)
	local x1=shl(x,2)
	local y1=shl(y,2)
	local z1=shl(z,2)
	
	local inv_dist=1/sqrt(x1*x1+y1*y1+z1*z1)
	
	return x1*inv_dist,y1*inv_dist,z1*inv_dist
	
end

function	vector_dot_3d(ax,ay,az,bx,by,bz)
	return ax*bx+ay*by+az*bz
end
	
function	vector_cross_3d(px,py,pz,ax,ay,az,bx,by,bz)

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



k_colorize_static = 1
k_colorize_dynamic = 2
k_multi_color_static = 3
k_multi_color_dynamic = 4
k_preset_color = 5
k_texture = 6


function load_texture_object(object_vertices,object_uv,object_faces,x,y,z,ax,ay,az,obstacle)
	object=new_object()
	
	object.vertices=object_vertices
	object.uv=object_uv
	
	
		object.faces=object_faces
	

	
	object.radius=0
	
	--make local deep copy of translated vertices
	--we share the initial vertices
	for i=1,#object_vertices do
		object.t_vertices[i]={}
			for j=1,3 do
				object.t_vertices[i][j]=object.vertices[i][j]
			end
	end

	object.ax=ax or 0
	object.ay=ay or 0
	object.az=az or 0
	transform_object(object)
	
	set_radius(object)
	set_bounding_box(object)
	
	object.x=x or 0
	object.y=y or 0
	object.z=z or 0
	
	object.color = color or 8
	object.color_mode= k_texture
	
	object.obstacle = obstacle or false
	
	if(obstacle)add(obstacle_list,object)
	
	if(color_mode==k_colorize_static or color_mode==k_colorize_dynamic or color_mode==k_multi_color_static )then
		color_faces(object,color)
	end
	return object
end



function set_radius(object)
	for vertex in all(object.vertices) do
		object.radius=max(object.radius,vertex[1]*vertex[1]+vertex[2]*vertex[2]+vertex[3]*vertex[3])
	end
	object.radius=sqrt(object.radius)
end

function set_bounding_box(object)
	for vertex in all(object.t_vertices) do
	
		object.min_x=min(vertex[1],object.min_x)
		object.min_y=min(vertex[2],object.min_y)
		object.min_z=min(vertex[3],object.min_z)
		object.max_x=max(vertex[1],object.max_x)
		object.max_y=max(vertex[2],object.max_y)
		object.max_z=max(vertex[3],object.max_z)
	end

end

function intersect_bounding_box(object_a, object_b)
	return 
        ((object_a.min_x+object_a.x < object_b.max_x+object_b.x) and (object_a.max_x+object_a.x > object_b.min_x+object_b.x) and
         (object_a.min_y+object_a.y < object_b.max_y+object_b.y) and (object_a.max_y+object_a.y > object_b.min_y+object_b.y) and
         (object_a.min_z+object_a.z < object_b.max_z+object_b.z) and (object_a.max_z+object_a.z > object_b.min_z+object_b.z))
end

function new_object()
	object={}
	object.vertices={}
	object.faces={}
	
	object.t_vertices={}

	
	object.x=0
	object.y=0
	object.z=0
	
	object.rx=0
	object.ry=0
	object.rz=0
	
	object.tx=0
	object.ty=0
	object.tz=0
	
	object.ax=0
	object.ay=0
	object.az=0
	
	object.vax=0
	object.vay=0
	object.vaz=0
	
	object.vx=0
	object.vy=0
	object.vz=0
	
	object.sx=0
	object.sy=0
	object.radius=10
	object.sradius=10
	object.visible=true
	
	object.render=true
	object.background=false
	object.collision_x=true
	object.collision_y=false
	object.collision_down=false
	object.collision_up=false
	object.collision_left=false
	object.ring=false
	
	object.min_x=100
	object.min_y=100
	object.min_z=100
	
	object.max_x=-100
	object.max_y=-100
	object.max_z=-100
	
	object.vx=0
	object.vy=0
	object.vz=0

	object.age=0
	object.health=2
	
	object.mirror_y=false
	
	local sx=sin(object.ax)
	local sy=sin(object.ay)
	local sz=sin(object.az)
	local cx=cos(object.ax)
	local cy=cos(object.ay)
	local cz=cos(object.az)
	
	object.mat00=cz*cy
	object.mat10=-sz
	object.mat20=cz*sy
	object.mat01=cx*sz*cy+sx*sy
	object.mat11=cx*cz
	object.mat21=cx*sz*sy-sx*cy
	object.mat02=sx*sz*cy-cx*sy
	object.mat12=sx*cz
	object.mat22=sx*sz*sy+cx*cy
	
	
	add(object_list,object)
	return object

end

function delete_object(object)
	object.faces=nil
	object.vertices=nil
	del(object_list,object)
end




function draw_triangle_list()
	--for t in all(triangle_list) do
	for i=1,#triangle_list do
		local t=triangle_list[i]
		if(t.type==texture)affine_trifill( t.p1x,t.p1y,t.p2x,t.p2y,t.p3x,t.p3y, t.tx1,t.ty1,t.tx2,t.ty2,t.tx3,t.ty3 )
	end
end

function update_visible(object)
		object.visible=false

		local px,py,pz = object.x-cam_x,object.y-cam_y,object.z-cam_z
		object.tx, object.ty, object.tz =rotate_cam_point(px,py,pz)

		
		
		--frustum planes are set up in 3d init
		
		--use cross product to check the translated points distance from the frustum planes
		--if the object bounding sphere wouldn't poke through/show up, it's not visible
		dist_left = line_dist(0,0,fpxl,fpz,object.tx,object.tz)
		dist_right = -line_dist(0,0,fpxr,fpz,object.tx,object.tz)
		dist_back = object.tz
		if(dist_left>-object.radius and dist_right>-object.radius and dist_back<object.radius and dist_back-object.radius>z_max  )object.visible=true
		
end

function cam_transform_object(object)
	if(object.visible)then

		for i=1, #object.vertices do
			local vertex=object.t_vertices[i]

			vertex[1]+=object.x - cam_x
			vertex[2]+=object.y - cam_y
			vertex[3]+=object.z - cam_z
			
			vertex[1],vertex[2],vertex[3]=rotate_cam_point(vertex[1],vertex[2],vertex[3])
		
		end
	

	end
end

function transform_object(object)
	

		
	
	if(object.visible)then
		--generate_matrix_transform(object.ax,object.ay,object.az)
		for i=1, #object.vertices do
			local t_vertex=object.t_vertices[i]
			local vertex=object.vertices[i]	
			t_vertex[1],t_vertex[2],t_vertex[3]=rotate_object_point(object,vertex[1],vertex[2],vertex[3])
		end
		
		
		if(object.mirror_y)then
			for i=1, #object.vertices do
				local t_vertex=object.t_vertices[i]
				--local vertex=object.vertices[i]	
				--t_vertex[1],t_vertex[2],t_vertex[3]=rotate_point(vertex[1],vertex[2],vertex[3])
				t_vertex[3]=-t_vertex[3]
				t_vertex[1]=-t_vertex[1]
				t_vertex[2]=t_vertex[2]
			end
		end
	

	end
end

function generate_matrix_transform(xa,ya,za)

	local sx=sin(xa)
	local sy=sin(ya)
	local sz=sin(za)
	local cx=cos(xa)
	local cy=cos(ya)
	local cz=cos(za)
	
	mat00=cz*cy
	mat10=-sz
	mat20=cz*sy
	mat01=cx*sz*cy+sx*sy
	mat11=cx*cz
	mat21=cx*sz*sy-sx*cy
	mat02=sx*sz*cy-cx*sy
	mat12=sx*cz
	mat22=sx*sz*sy+cx*cy
end

function object_matrix_transform(object,xa,ya,za)

	local sx=sin(xa)
	local sy=sin(ya)
	local sz=sin(za)
	local cx=cos(xa)
	local cy=cos(ya)
	local cz=cos(za)
	
	local mat00=cz*cy
	local mat10=-sz
	local mat20=cz*sy
	local mat01=cx*sz*cy+sx*sy
	local mat11=cx*cz
	local mat21=cx*sz*sy-sx*cy
	local mat02=sx*sz*cy-cx*sy
	local mat12=sx*cz
	local mat22=sx*sz*sy+cx*cy
	tmat00,tmat10,tmat20=(mat00*object.mat00)+(mat10*object.mat01)+(mat20*object.mat02),(mat00*object.mat10)+(mat10*object.mat11)+(mat20*object.mat12),(mat00*object.mat20)+(mat10*object.mat21)+(mat20*object.mat22)
	tmat01,tmat11,tmat21=(mat01*object.mat00)+(mat11*object.mat01)+(mat21*object.mat02),(mat01*object.mat10)+(mat11*object.mat11)+(mat21*object.mat12),(mat01*object.mat20)+(mat11*object.mat21)+(mat21*object.mat22)
	tmat02,tmat12,tmat22=(mat02*object.mat00)+(mat12*object.mat01)+(mat22*object.mat02),(mat02*object.mat10)+(mat12*object.mat11)+(mat22*object.mat12),(mat02*object.mat20)+(mat12*object.mat21)+(mat22*object.mat22)
--3x3 Matrix Multiplication Result
	
	object.mat00,object.mat10,object.mat20=tmat00,tmat10,tmat20
	object.mat01,object.mat11,object.mat21=tmat01,tmat11,tmat21
	object.mat02,object.mat12,object.mat22=tmat02,tmat12,tmat22
	
end


function generate_cam_matrix_transform(xa,ya,za)

	
	local sx=sin(xa)
	local sy=sin(ya)
	local sz=sin(za)
	local cx=cos(xa)
	local cy=cos(ya)
	local cz=cos(za)
	
	cam_mat00=cz*cy
	cam_mat10=-sz
	cam_mat20=cz*sy
	cam_mat01=cx*sz*cy+sx*sy
	cam_mat11=cx*cz
	cam_mat21=cx*sz*sy-sx*cy
	cam_mat02=sx*sz*cy-cx*sy
	cam_mat12=sx*cz
	cam_mat22=sx*sz*sy+cx*cy

end

function	matrix_inverse()
	local det = mat00* (mat11 * mat22- mat21 * mat12) -
                mat01* (mat10 * mat22- mat12 * mat20) +
                mat02* (mat10 * mat21- mat11 * mat20)
	local invdet=2/det
		

		
		mat00,mat01,mat02,mat10,mat11,mat12,mat20,mat21,mat22=(mat11 * mat22 - mat21 * mat12) * invdet,(mat02 * mat21 - mat01 * mat22) * invdet,(mat01 * mat12 - mat02 * mat11) * invdet,(mat12 * mat20 - mat10 * mat22) * invdet,(mat00 * mat22 - mat02 * mat20) * invdet,(mat10 * mat02 - mat00 * mat12) * invdet,(mat10 * mat21 - mat20 * mat11) * invdet,(mat20 * mat01 - mat00 * mat21) * invdet,(mat00 * mat11 - mat10 * mat01) * invdet

		--uh yeah i looked this one up :-)
end

function rotate_point(x,y,z)	
	return (x)*mat00+(y)*mat10+(z)*mat20,(x)*mat01+(y)*mat11+(z)*mat21,(x)*mat02+(y)*mat12+(z)*mat22
end

function rotate_object_point(object,x,y,z)
	return (x)*object.mat00+(y)*object.mat10+(z)*object.mat20,(x)*object.mat01+(y)*object.mat11+(z)*object.mat21,(x)*object.mat02+(y)*object.mat12+(z)*object.mat22
end

function rotate_cam_point(x,y,z)
	return (x)*cam_mat00+(y)*cam_mat10+(z)*cam_mat20,(x)*cam_mat01+(y)*cam_mat11+(z)*cam_mat21,(x)*cam_mat02+(y)*cam_mat12+(z)*cam_mat22
end

function is_visible(object)

	if(object.tz+object.radius>z_max and object.tz-object.radius<z_clip and
	   object.sx+object.sradius>0 and object.sx-object.sradius<128 and
	   object.sy+object.sradius>0 and object.sy-object.sradius<128 )
	   then return true else return false end
end

function	cross_product_2d(p0x,p0y,p1x,p1y,p2x,p2y)
	return ( ( (p0x-p1x)*(p2y-p1y)-(p0y-p1y)*(p2x-p1x)) > 0 )
end

function line_dist(p0x,p0y,p1x,p1y,p2x,p2y)
	return ( (p0x-p1x)*(p2y-p1y)-(p0y-p1y)*(p2x-p1x))
end

function render_object(object)

	--project all points in object to screen space
	--it's faster to go through the array linearly than to use a for all()
	for i=1, #object.t_vertices do
		local vertex=object.t_vertices[i]
		vertex[4],vertex[5] = vertex[1]*k_screen_scale/vertex[3]+k_x_center,vertex[2]*k_screen_scale/vertex[3]+k_x_center
	end

	for i=1,#object.faces do
	--for face in all(object.faces) do
		local face=object.faces[i]
	
		local p1=object.t_vertices[face[1]]
		local p2=object.t_vertices[face[2]]
		local p3=object.t_vertices[face[3]]
		
		local p1x,p1y,p1z=p1[1],p1[2],p1[3]
		local p2x,p2y,p2z=p2[1],p2[2],p2[3]
		local p3x,p3y,p3z=p3[1],p3[2],p3[3]
		
		local uv1=object.uv[face[7]]
		local uv2=object.uv[face[8]]
		local uv3=object.uv[face[9]]
		
		--print(uv3[2])
		--flip()
		--while(true)do end
		
		local uv1x,uv1y=uv1[1],uv1[2]
		local uv2x,uv2y=uv2[1],uv2[2]
		
		--if(uv3==nil)uv3=uv2
		
		local uv3x,uv3y=uv3[1],uv3[2]
		
		
		
		
		
		
		local cz=.01*(p1z+p2z+p3z)/3
		local cx=.01*(p1x+p2x+p3x)/3
		local cy=.01*(p1y+p2y+p3y)/3
		local z_paint= -cx*cx-cy*cy-cz*cz
		
		
		
		
		if(object.background==true) z_paint-=1000 
		face[6]=z_paint
		

		if((p1z>z_max or p2z>z_max or p3z>z_max))then
			if(p1z< z_clip and p2z< z_clip and p3z< z_clip)then
			--simple option -- no clipping required

					local s1x,s1y = p1[4],p1[5]
					local s2x,s2y = p2[4],p2[5]
					local s3x,s3y = p3[4],p3[5]
		

					if( max(s3x,max(s1x,s2x))>0 and min(s3x,min(s1x,s2x))<128)  then
						--only use backface culling on simple option without clipping
						--check if triangles are backwards by cross of two vectors
						if(( (s1x-s2x)*(s3y-s2y)-(s1y-s2y)*(s3x-s2x)) < 0)then
						
							--faster to move new triangle function inline
							add(triangle_list,{p1x=s1x,	p1y=s1y,p2x=s2x,p2y=s2y,p3x=s3x,p3y=s3y,tz=z_paint,tx1=uv1x,ty1=uv1y,tx2=uv2x,ty2=uv2y,tx3=uv3x,ty3=uv3y,type=textured,parent=object})
						end
					end
					
			--not optimizing clipping functions for now
			--these still have errors for large triangles
			elseif(p1z< z_clip or p2z< z_clip or p3z< z_clip)then
			
			--either going to have 3 or 4 points
				p1x,p1y,p1z,p2x,p2y,p2z,p3x,p3y,p3z = three_point_sort(p1x,p1y,p1z,p2x,p2y,p2z,p3x,p3y,p3z)
				if(p1z<z_clip and p2z<z_clip)then
				

				
					local n2x,n2y,n2z = z_clip_line(p2x,p2y,p2z,p3x,p3y,p3z,z_clip)
					local n3x,n3y,n3z = z_clip_line(p3x,p3y,p3z,p1x,p1y,p1z,z_clip)
					

					
					local s1x,s1y = project_point(p1x,p1y,p1z)
					local s2x,s2y = project_point(p2x,p2y,p2z)
					local s3x,s3y = project_point(n2x,n2y,n2z)
					local s4x,s4y = project_point(n3x,n3y,n3z)

					
					if( max(s4x,max(s1x,s2x))>0 and min(s4x,min(s1x,s2x))<128)  then
						--new_triangle(s1x,s1y,s2x,s2y,s4x,s4y,z_paint,0,0,32,0,0,8)
						add(triangle_list,{p1x=s1x,	p1y=s1y,p2x=s2x,p2y=s2y,p3x=s4x,p3y=s4y,tz=z_paint,tx1=uv1x,ty1=uv1y,tx2=uv2x,ty2=uv2y,tx3=uv3x,ty3=uv3y,type=textured,parent=object})

					end
					if( max(s4x,max(s3x,s2x))>0 and min(s4x,min(s3x,s2x))<128)  then
						--new_triangle(s2x,s2y,s4x,s4y,s3x,s3y,z_paint,0,0,32,0,0,8)
						add(triangle_list,{p1x=s2x,	p1y=s2y,p2x=s4x,p2y=s4y,p3x=s3x,p3y=s3y,tz=z_paint,tx1=uv1x,ty1=uv1y,tx2=uv2x,ty2=uv2y,tx3=uv3x,ty3=uv3y,type=textured,parent=object})

					end
				else

				
					local n1x,n1y,n1z = z_clip_line(p1x,p1y,p1z,p2x,p2y,p2z,z_clip)
					local n2x,n2y,n2z = z_clip_line(p1x,p1y,p1z,p3x,p3y,p3z,z_clip)
					

					
					local s1x,s1y = project_point(p1x,p1y,p1z)
					local s2x,s2y = project_point(n1x,n1y,n1z)
					local s3x,s3y = project_point(n2x,n2y,n2z)
					
					--solid_trifill(s1x,s1y,s2x,s2y,s3x,s3y,face[k_base_color])
					if( max(s3x,max(s1x,s2x))>0 and min(s3x,min(s1x,s2x))<128)  then
						--new_triangle_texture(s1x,s1y,s2x,s2y,s3x,s3y,z_paint,0,0,32,0,0,8)
						add(triangle_list,{p1x=s1x,	p1y=s1y,p2x=s2x,p2y=s2y,p3x=s3x,p3y=s3y,tz=z_paint,tx1=uv1x,ty1=uv1y,tx2=uv2x,ty2=uv2y,tx3=uv3x,ty3=uv3y,type=textured})

					end
				end
				
				--print("p1",p1x+64,p1z+64,14)
				--print("p2",p2x+64,p2z+64,14)
				--print("p3",p3x+64,p3z+64,14)
				
			
			
			end
		end
		
	end


end

function three_point_sort(p1x,p1y,p1z,p2x,p2y,p2z,p3x,p3y,p3z)
	if(p1z>p2z) p1z,p2z = p2z,p1z p1x,p2x = p2x,p1x p1y,p2y = p2y,p1y
	if(p1z>p3z) p1z,p3z = p3z,p1z p1x,p3x = p3x,p1x p1y,p3y = p3y,p1y
	if(p2z>p3z) p2z,p3z = p3z,p2z p2x,p3x = p3x,p2x p2y,p3y = p3y,p2y
	
	return p1x,p1y,p1z,p2x,p2y,p2z,p3x,p3y,p3z
end

function quicksort(t, start, endi)
   start, endi = start or 1, endi or #t
  --partition w.r.t. first element
  if(endi - start < 1) then return t end
  local pivot = start
  for i = start + 1, endi do
    if t[i].tz <= t[pivot].tz then
      if i == pivot + 1 then
        t[pivot],t[pivot+1] = t[pivot+1],t[pivot]
      else
        t[pivot],t[pivot+1],t[i] = t[i],t[pivot],t[pivot+1]
      end
      pivot = pivot + 1
    end
  end
   t = quicksort(t, start, pivot - 1)
  return quicksort(t, pivot + 1, endi)
end



function z_clip_line(p1x,p1y,p1z,p2x,p2y,p2z,clip)
	if(p1z>p2z)then
		p1x,p2x=p2x,p1x
		p1z,p2z=p2z,p1z
		p1y,p2y=p2y,p1y
	end
	
	if(clip>p1z and clip<=p2z)then

	--	line(p1x+64,p1z+64,p2x+64,p2z+64,14)
		alpha= abs((p1z-clip)/(p2z-p1z))
		nx=lerp(p1x,p2x,alpha)
		ny=lerp(p1y,p2y,alpha)
		nz=lerp(p1z,p2z,alpha)
				
	--	circ(nx+64,nz+64,1,12)
		return nx,ny,nz
	else
		return false
	end
end

function project_point(x,y,z)
	return x*k_screen_scale/z+k_x_center,y*k_screen_scale/z+k_x_center
end

function project_radius(r,z)
	return r*k_screen_scale/abs(z)
end



function lerp(a,b,alpha)
  return a*(1.0-alpha)+b*alpha
end


function update_camera()	
	--cam_x=player.x
	--cam_y=player.y
	--cam_z=player.z

	--cam_ax=player.ax
	--cam_ay=player.ay
	--cam_az=player.az

	generate_cam_matrix_transform(cam_ax,cam_ay,cam_az)
end

function init_3d()
	
	init_light()
	object_list={}
	obstacle_list={}
	particle_list={}
	
	--object.sx,object.sy = project_point(object.tx,object.ty,object.tz)
		--object.sradius=project_radius(object.radius,object.tz)
		--object.visible= is_visible(object) 
		
		--setup left and right frustum planes--really just lines with unit length
		--these follow right on the edge of what is visible on the screen
		fpz=-1
		fpxl=-(k_x_center*fpz)/k_screen_scale	
		flen=sqrt(fpxl*fpxl+fpz*fpz)
		fpz/=flen
		fpxl/=flen
		fpxr=-fpxl
end

function update_3d()
	for object in all(object_list) do
			update_visible(object)
			transform_object(object)
			cam_transform_object(object)
			update_light()
	end
end

function draw_3d()
	triangle_list={}
	quicksort(object_list)
	
	
	for object in all(object_list) do
		
		if(object.visible and not object.background) then
			render_object(object) --sort_faces(object)
			--if(object.color_mode==k_colorize_dynamic or object.color_mode==k_multi_color_dynamic) color_faces(object,object.color)
		end
	end
	
	

		quicksort(triangle_list)
	
	
	
		draw_triangle_list()
	
end



function find_bounding_circle(object)
	object.sx,object.sy = project_point(object.tx,object.ty,object.tz)
	object.sradius=project_radius(object.radius,object.tz)
end

function check_triangle_intersect(x1,y1,x2,y2,x3,y3,px,py)
	local intersect=false
	
	cross1=cross_product_2d(px,py,x1,y1,x2,y2)
	cross2=cross_product_2d(px,py,x2,y2,x3,y3)
	cross3=cross_product_2d(px,py,x3,y3,x1,y1)
	
	if(cross1)return false
	if(cross2)return false
	if(cross3)return false
	
	--line(x1,y1,x2,y2,8)
	--line(x2,y2,x3,y3,8)
	--line(x3,y3,x1,y1,8)
	
	return true
	--cross_product_2d(p0x,p0y,p1x,p1y,p2x,p2y)
end

function check_all_triangle_intersect()
	for index,t in pairs(triangle_list) do
		if(check_triangle_intersect(t.p1x,t.p1y,t.p2x,t.p2y,t.p3x,t.p3y,cross_x,cross_y))return t.parent
	end
	return false
end



----------------------------------end copy-------------------------------------------------------
----------------------------------electric gryphon's 3d library----------------------------------
-------------------------------------------------------------------------------------------------


function affine_fill_line(start_x,stop_x,y,tx1,ty1,tx2,ty2)
	if(start_x>stop_x)then
		stop_x,start_x=start_x,stop_x
		tx1,tx2=tx2,tx1
		ty1,ty2=ty2,ty1
	end
	
	
	
	local x_len=(stop_x-start_x)
	local tx_step=(tx2-tx1)/(x_len)
	local ty_step=(ty2-ty1)/(x_len)
	
	
	
	--line(start_x,y-1,stop_x,y-1,1)
	local tx=tx1--+.5
	local ty=ty1--+.5
	
	if(start_x<0)tx=tx1+.5+(-start_x)*tx_step start_x=0
	if(stop_x>128)stop_x=128

	
	for i=0,stop_x-start_x do
		local c=sget(tx,ty)
		if(c!=14)pset(start_x,y,sget(tx,ty))
		
		start_x+=1
		tx+=tx_step
		ty+=ty_step
		
		
		
	end

end


				


function affine_trifill( x1,y1,x2,y2,x3,y3, tx1,ty1,tx2,ty2,tx3,ty3)

		  local x1=band(x1,0xffff)
		  local x2=band(x2,0xffff)
		  local y1=band(y1,0xffff)
		  local y2=band(y2,0xffff)
		  local x3=band(x3,0xffff)
		  local y3=band(y3,0xffff)

		  --sort y1,y2,y3
		  if(y1>y2)then
			y1,y2=y2,y1
			x1,x2=x2,x1
			
			ty1,ty2=ty2,ty1
			tx1,tx2=tx2,tx1
		  end
		  
		  if(y1>y3)then
			y1,y3=y3,y1
			x1,x3=x3,x1
			
			ty1,ty3=ty3,ty1
			tx1,tx3=tx3,tx1
		  end
		  
		  if(y2>y3)then
			y2,y3=y3,y2
			x2,x3=x3,x2		

			ty2,ty3=ty3,ty2
			tx2,tx3=tx3,tx2			
		  end

		
		  
			local a_span=y2-y1
			local b_span=y3-y1
			local c_span=y3-y2
			
			local tx_start = tx1
			local tx_end=tx1
			local ty_start=ty1
			local ty_end=ty1

			local delta_sx=(x3-x1)/(y3-y1)
			local delta_ex=(x2-x1)/(y2-y1)

			local 	nsx=x1
			local 	nex=x1

			local tx_start_step=(tx2-tx1)/a_span
			local ty_start_step=(ty2-ty1)/a_span
			
			local tx_end_step=(tx3-tx1)/b_span
			local ty_end_step=(ty3-ty1)/b_span
		if(y1!=y2)then --make sure top edge is not horizontal
			if(y2>127)y2=128
			for y=y1,y2-1 do
				affine_fill_line(nex,nsx,y,tx_start,ty_start,tx_end,ty_end)

				tx_start+=tx_start_step
				ty_start+=ty_start_step
				tx_end+=tx_end_step
				ty_end+=ty_end_step
				
				nsx+=delta_sx
				nex+=delta_ex
			end	
		else
			--top edge is horizontal
			nsx=x1
			nex=x2
			tx_start=tx2
			ty_start=ty2
			tx_end=tx1
			ty_end=ty1
		end
		
		tx_start_step=(tx3-tx2)/c_span
		ty_start_step=(ty3-ty2)/c_span

		delta_sx=(x3-x1)/(y3-y1)
		delta_ex=(x3-x2)/(y3-y2)
			if(y3>127)y3=128
			 for y=y2,y3 do
				
				affine_fill_line(nex,nsx,y,tx_start,ty_start,tx_end,ty_end)

				tx_start+=tx_start_step
				ty_start+=ty_start_step
				
				tx_end+=tx_end_step
				ty_end+=ty_end_step
				
				nex+=delta_ex
				nsx+=delta_sx
			 end
end

------------------------------------------------------------BEGIN GAME CODE-------
-----------------------------------------------------------------------------------

score={0,0,0,0,0,0,0,0,0,0}
score_buffer=0
streak=0
score_multiplier=1
bullets=8
max_bullets=8

k_max_time=30
time=k_max_time

k_start_screen=1
k_game_screen=2
k_score_screen=3
k_transition_screen=4
game_state=k_start_screen

cross_last_state=0
function update_crosshairs()
	cross_x=stat(32)
	cross_y=stat(33)
	cross_shoot=false
	cross_state=stat(34)
	if(cross_state==1 and cross_last_state!=1)then
		cross_shoot=true
	end
	cross_last_state=cross_state
end

function draw_crosshairs()
--	if(cross_shoot and bullets!=0)shoot_frames=3
--	if shoot_frames!=0 then
--	 shoot_frames-=1
--	 for i=1,#shoot_col do
--	  circ(cross_x-0.5+rnd(2),cross_y-0.5+rnd(2),(#shoot_col-i)/2,shoot_col[i])
--	 end
--	end
-- reload_col=10-reload_col
-- crosshair_col=16-crosshair_col
--	color(bullets==0 and reload_col 
--	                  or crosshair_col)
	c=7
	if(bullets<=0)c=8
	
	cross_y+=1
	circ(cross_x,cross_y,5,0)
	line(cross_x-7,cross_y,cross_x-2,cross_y,0)
	line(cross_x,cross_y-7,cross_x,cross_y-2,0)
	line(cross_x+2,cross_y,cross_x+7,cross_y,0)
	line(cross_x,cross_y+2,cross_x,cross_y+7,0)
	
	cross_y-=1
	circ(cross_x,cross_y,5,c)
	line(cross_x-7,cross_y,cross_x-2,cross_y,c)
	line(cross_x,cross_y-7,cross_x,cross_y-2,c)
	line(cross_x+2,cross_y,cross_x+7,cross_y,c)
	line(cross_x,cross_y+2,cross_x,cross_y+7,c)

end

can_v="0000ff48ff73000000b7ff73006dff48ffa8006d00b7ffa80088ff48001f008800b7001f003cff48007e003c00b7007effc3ff48007effc300b7007eff77ff48001fff7700b7001fff92ff48ffa8ff9200b7ffa8"
can_uv="0030001e0026001e00260001001e001e001e00010014001e00140001000c001e000c00010001001e000600310004002800090021003800010038001e0041001e0011002100180028003000010001000100160031000e003600410001"
can_f="02010402030304020604050506040806070708060a08090909090a080c0a020b0e0c0c0d0d0e0e0f02010c100e0f0d0e0b0b031105120113020103030303040205050505060407070707080609090b1409090c0a0812061504160c0d0a11081201130d0e020108120416020b020b0c0d08120b170c100d0e0b0b0d0c010d071509160b0b07150b0b05120b0b010d0311"

bottle_v="0000ff48ff730000014fff73006dff48ffa8006d014fffa80088ff48001f0088014f001f003cff48007e003c014f007effc3ff48007effc3014f007eff77ff48001fff77014f001fff92ff48ffa8ff92014fffa8000001c1ffa9004301c1ffca005401c10013002501c1004dffda01c1004dffab01c10013ffbc01c1ffca00000328ffc6002d0328ffdb00380328000c001903280034ffe603280034ffc70328000cffd20328ffdb"
bottle_uv="006e00260066002600660001005e0026005e000100560026004e0026004e0001004600260076002600760030006e0030006e0001007e00260076000100880001009000010094000800760050007e0030004e00300046003000560030005e003000660030008c001e0086001e00860018007e0050004e00500046005000560050005e005000660050006e00500056000100460001007e0001008600100084000800910010008c001100900014009100180090001e00880014"
bottle_f="02010402030303030402060405050604080608060a07090809080a070c090e0a150b0f0c0e0a0201010d0c0e0e0a0d0f0110031105120f0c150b1c130c0e1414150b0a0713151416080612171315060411181217040210191118040202010f0c161a1c1b1b1c150b14141b1d13151a1e1b1f121719201a1e11181821192010191722182110190f0c1623010d020103030505030306040724050508060724080609080b2509080c0902010e0a0f0c0d0f0e0a010d0b260c0e0d0f0b270d2801100729092a0b270729011005120e0a0c0e150b16230f0c1c1307290b2701100c090a0714160a0708061315080606041217060404021118101904020f0c192b182c172d1b1c1a2e192b1c13150b1b1d192b172d161a161a1b1c192b141613151b1f131512171a1e121711181920111810191821172210191623"

soda_v="0000ff4bff7000000101ff700070ff4bffa600700101ffa6008bff4b001f008b0101001f003eff4b0081003e01010081ffc1ff4b0081ffc101010081ff74ff4b001fff740101001fff8fff4bffa6ff8f0101ffa6"
soda_uv="00c6005800b8005800b8002900ac005800ac0029009e0058009e00290091005800910029008400580084002900b6007400a9007400a0006900d1005800c6002900e0005800d1002900a0006000a0006e0096007600be006900bc005e00a4005e00b0005800e0002900840066008900590096005800890071"
soda_f="02010402030304020604050506040806070708060a0809090a080c0a0b0b020c0e0d0c0e0e0f020101100c110e0f0d1203130514071501100201030303030402050505050604070707070806090909090a080b0b0416020c06170c0e0a1808190d120e0f01100b1a0c110d12020c0c0e0819020c081906170b1b0d1c011d0715091e0b1b0b1b011d0313031307150b1b"

revolver_v="ff9cfe01046eff9cfe01026e0063fe01026e0063fe01046eff9c000b0376ff9cff7e02510063ff7e02510063000b0376ff9c00aa023fffd1ffda01a9002effda01a9006300aa023f00000263feeeff48020bfeeeff1b0144feeeff9a00a500fbff9a00a5feee006500a500fb006500a5feee00e40144feee00b7020bfeeeffd1ff5f004cffd1000a001e002e000a001e002eff5f004cff9f014dfeedff9f014dfb930060014dfb930060014dfeedff9f020ffeedff9f020ffb930060020ffb930060020ffeedff9c012901ba0063012901baffc201a201b7003d01a201b7ffc202330265003d02330265ffc2024d0239003d024d0239ffc201f50185003d01f50185002eff35012bffd1ff35012bff9a00a500fb0000026300fb0000026300fbff48020b00fbff48020b00fbff1b014400fbff1b014400fb006500a500fb00e4014400fb00e4014400fb00b7020b00fb00b7020b00fb"
revolver_uv="0021009e002000b1000400b10026004c0011004c00110041001100940071009400710074007e0074004000b4004000be002400be007e0094007e00a8007100a8002c00980026004100310044003100490024008e004100ac004e00a1006900a60059005400640054006400700070005400700070007c0054007c0070006e0080005c007c005c0078003800540044005400440070005800bc005e00b1006e00b1004e005400590070004e0070005800ac005400b60034006e00340078000400780021003400210028002e00280004006100040058003400580034008100040081003400610004006e007e00b1007100b1005e0089005c0091005400910059009400560094005c0096005400960064009e0036008c002900860041009100410084006c00810049009e005800a100460078005100780051007c004800b6003900780046007c002400b4006e007400380070005900c6006600cc007400bc007100c6002e003400510089006c00910039007c"
revolver_f="06010202010307040305020607010807040305080109040a020b030c040d080e0c0f0910080707010b1106120a130b14050709150a110a16101711180d190e1a311b0e1a0f1c331d0f1c111e101f132018211722131835170b161323142436250d261527142815290d192f2a14241529382b0a16172c162d1f2e1b2f1a3020311c321b3321341d351c361b2f1c371d3820391f2e1e3a0c0f233b223c233d253e243f243f253e274027402940284129402b422a4339442b42253e0b111245234622462e450a11243f34472e48253e233d12492b4229402740264128412a43324a3447243f3944304b2b42324a2a43304b2b42304b2a432d4c164d194e0b162c4f192d1821194e164d0a502d4c2c51050706010103061207040206030207010403080e0508040a0152020b040d0508080e09100c1508070b11070406120b14060105070a11172c0a1611182f2a0d19311b311b0e1a331d331d0f1c101f115313201722182c13180b163554132336250e550d260f56142813571158382b15292f2a36251424382b0d26142811580d2611580f562d4f0a16162d1e3a1f2e1a301f5920311b33203921341c361a301b2f1d38213420391e3a09100c0f223c225a233d243f2641243f2740264127402841284129402a43375b3944253e0c150b112346091522460a11225a243f2e48375b253e1249253e2b422740243f26412a432a43324a243f2c512d4c194e182c0b16192d17221821164d0b5c0a502c51"



function handle_shot()
	
	if(cross_y>108)then
		bullets=max_bullets
		sfx(2)
	else


		if(bullets>0)then
			sfx(0)
			target=check_all_triangle_intersect()
			if(target!=false)then
				--target.z-=1
				
				find_bounding_circle(target)
				target.vax,target.vay=-(cross_y-target.sy)/target.sradius*.075,(cross_x-target.sx)/target.sradius*.075
				target.vx,target.vy=(cross_x-target.sx)/target.sradius*.1,(cross_y-target.sy)/target.sradius*.4
				target.vz+=-.02
				--target.vy+=.3
				target.active=true
				draw_shot()
				increase_score(60*score_multiplier)
				score_multiplier+=1
				sfx(1)
			else
				score_multiplier=1
			end
			
			new_sprite_particle((bullets-1)*13+2+6,108+8,rnd(1)-.5,-2,rnd(.2)-.1,20,12,16,80,0)
			bullets-=1
			--sspr(80,0,12,16,i*13+4,108)
		
			
		else
			sfx(3)
		end
	
	end
end

function update_objects()
	for index,object in pairs(object_list) do
		object.vax*=.98
		object.vay*=.98
		object.vaz*=.98
		object_matrix_transform(object,object.vax,object.vay,object.vaz)
		
		object.x+=object.vx
		object.y+=object.vy
		object.z+=object.vz
		
		if(object.active)then
			if(object.y>-8) then
				object.vy-=.015 
				else 
				delete_object(object)--object.y=-8 object.vy*=-.6  
				
				new_target()
				
			end
		end
	end
end

function new_target()
	local v=can_v
	local uv=can_uv
	local f=can_f
	
	n=rnd(1)
	if(n<.3)then
		
		v= soda_v
		uv=soda_uv
		f= soda_f
	elseif(n<.6)then
		v=bottle_v
		uv=bottle_uv
		f=bottle_f
	end
	
	
	target=load_texture_object(read_vector_string(v),read_uv_string(uv),read_texture_face_string(f),rnd(5)-2.5,-8,rnd(3)+4,0,.25,0,false)
	target.active=true
	target.vy=.4+rnd(.2)
	target.vx=rnd(.2)-.1
	target.vz=rnd(.1)-.05
	target.vax=rnd(.1)-.05
	target.vay=rnd(.05)-.025
	target.vaz=rnd(.05)-.025
end

text_particle_list={}
function new_text_particle(text,x,y,vx,vy,l,c)
	p={text=text,x=x,y=y,vx=vx,vy=vy,l=l,c=c}
	add(text_particle_list,p)
end
function update_text_particles()
	for i,p in pairs(text_particle_list) do
		p.x+=p.vx
		p.y+=p.vy
		p.vy+=.2
		p.l-=1
		if(p.l<0)del(text_particle_list,p)
	end
end

function print_2(text,x,y,c1,c2)
	x=x-#text*4/2
	print(text,x-1,y,c2)
	print(text,x+1,y,c2)
	print(text,x,y-1,c2)
	print(text,x,y+1,c2)
	print(text,x,y,c1)
end

function draw_text_particles()
	for i,p in pairs(text_particle_list) do
		print_2(p.text,p.x,p.y,p.c,0)
	end
end

particle_list={}
function new_particle(x,y,vx,vy,l,c)

	p={x=x,y=y,vx=vx,vy=vy,l=l,c=c}
	add(particle_list,p)
end

function update_particles()
	for i,p in pairs(particle_list) do
		p.x+=p.vx
		p.y+=p.vy
		p.vy+=.2
		p.l-=1
		if(p.l<0)del(particle_list,p)
	end
end

function draw_particles()
	for i,p in pairs(particle_list) do
		circfill(p.x,p.y,1,p.c)
	end
end

sprite_particle_list={}
function new_sprite_particle(x,y,vx,vy,va,l,w,h,sx,sy)
	p={x=x,y=y,vx=vx,vy=vy,l=l,va=va,w=w,h=h,sx=sx,sy=sy,a=0}
	add(sprite_particle_list,p)
end

function update_sprite_particles()
	for i,p in pairs(sprite_particle_list) do
		p.x+=p.vx
		p.y+=p.vy
		p.a+=p.va
		p.vy+=.2
		p.l-=1
		if(p.l<0)del(sprite_particle_list,p)
	end
end

function draw_sprite_particles()
	for i,p in pairs(sprite_particle_list) do
		draw_rotate_sprite(p.x,p.y,p.w,p.h,p.sx,p.sy,p.a)
	end
end


function draw_shot()
	for i=1,20 do
		c=8+flr(rnd(3))
		new_particle(cross_x,cross_y,rnd(4)-2,rnd(4)-2,20,c)
	end
	
	
	if(score_multiplier==2)then
		new_text_particle("yeah!",cross_x,cross_y,0,-3,20,8)
	elseif(score_multiplier==5)then
		new_text_particle("sweet!",cross_x,cross_y,0,-3,20,8)
	elseif(score_multiplier==8)then
		new_text_particle("on fire!",cross_x,cross_y,0,-3,20,8)
	end
	new_text_particle(score_multiplier.."x",cross_x,cross_y,rnd(2)-1,-3,20,9)
end

function draw_rotate_sprite(x,y,w,h,sx,sy,a)
	local ca=cos(a)
	local sa=sin(a)
	
	points={{-w/2,-h/2},{w/2,-h/2},{w/2,h/2},{-w/2,h/2}}
	tp={}
	
	for i,p in pairs(points) do
		tp[i]={
		p[1]*ca-p[2]*sa+x,
		p[2]*ca+p[1]*sa+y
		}
	end
	
	
	--for i=1,#tp-1 do
	--	line(tp[i][1],tp[i][2],tp[i+1][1],tp[i+1][2],8)
	--end
	
	affine_trifill( tp[1][1],tp[1][2],tp[2][1],tp[2][2],tp[3][1],tp[3][2], sx,sy,sx+w,sy,sx+w,sy+h)
	affine_trifill( tp[3][1],tp[3][2],tp[4][1],tp[4][2],tp[1][1],tp[1][2], sx+w,sy+h,sx,sy+h,sx,sy)
end




function draw_score(x,y)


	palt(14,true)
	for i=9,1,-1 do
		v=score[i]
		if(game_state==k_score_screen)then
			spr(v,x+#score*8-(i*8),y+sin( (cur_frame+i*12)/100)*4)
		else
			spr(v,x+#score*8-(i*8),y)
		end
		
	end
end

function update_score()
	if(score_buffer>0)then
		local d= flr(score_buffer/10)+1
		score_buffer-=d
		add_score(d)
	end
		if(score_buffer<0)score_buffer=0
end

function increase_score(value)
	score_buffer+=value
end

function add_score(value)
	--value=3
	
	--add_score={0,0,0,0,0,0,0,0,0,0}
	for i=1,9 do
		v=value%10
		value=flr(value/20)
		score[i]+=v
		while(score[i]>9)do
			score[i]-=10
			score[i+1]+=1
		end
	end
	
end

function draw_background()
	rectfill(0,0,127,127,9)
	rectfill(0,0,127,11,0)
	
	rectfill(0,108,127,127,0)
	
	rectfill(0,11,127,64,12)
	rectfill(0,11,127,18,1)
	rectfill(0,20,127,20,1)
	rectfill(0,22,127,22,1)
	
	rectfill(0,65,127,68,4)
	
	
	rectfill(0,70,127,70,4)
	rectfill(0,72,127,72,4)
	
	spr(12,25,60,1,2)
end

function draw_time()

	if(cur_frame%30==0)time-=1
	if(time<0)time=0

	--local time_val=time
	local tens = flr(time/10)
	local ones = time%10
	
	spr(tens,110,114)
	spr(ones,118,114)
	rect(107,111,127,124,4)
	rect(108,112,126,123,9)
end

function draw_hud()
	update_score()
	draw_score(20,0)
	
	--draw_bullet(80,80,cur_frame/200)
	
	for i=0,bullets-1 do
		sspr(80,0,12,16,i*13+2,110)
	end
	
	if(bullets==0)print_2("reload",64+sin(cur_frame/30)*4,116,10,4)
	
	draw_time()
end

function init_start_screen()
	revolver=load_texture_object(read_vector_string(revolver_v),read_uv_string(revolver_uv),read_texture_face_string(revolver_f),0,-2,-0,.1,.25,0,false)

end

scroller="-- code and graphics by electric gryphon -- thx felice for snd"
function draw_scroller()
	for i=1,#scroller do
		print(sub(scroller,i,i),(i*4-cur_frame)%(4*(#scroller+4)),115+sin( (cur_frame+i*3-20)/100)*3,2)
		print(sub(scroller,i,i),(i*4-cur_frame)%(4*(#scroller+4)),115+sin( (cur_frame+i*3-10)/100)*3,4)
		print(sub(scroller,i,i),(i*4-cur_frame)%(4*(#scroller+4)),115+sin( (cur_frame+i*3)/100)*3,9)
	end
end

function draw_start_screen()
	--cls(12)
	draw_background()
	update_3d()
	draw_3d()
	draw_particles()
	draw_crosshairs()
	print_2("click to start game",64,2,10,4)
	sspr(0,8,80,12,64-40,20)
	--draw_rotate_sprite(64,45,80,12,0,8,sin(cur_frame/100)*.2)
	draw_scroller()
end

function update_start_screen()
	revolver.vay=.01
	revolver.y=sin(cur_frame/100)*1-1
	--revolver.vax=.008
	update_objects()
	update_crosshairs()
	update_particles()
	if(cross_shoot)then
		game_state=k_game_screen
		delete_object(revolver)
		start_game()
	end
	
end

function init_score_screen()
		pause_time=cur_frame+100
		for obj in all(object_list)do
			delete_object(obj)
		end
		revolver1=load_texture_object(read_vector_string(revolver_v),read_uv_string(revolver_uv),read_texture_face_string(revolver_f),5,-3,-4,.1,.25,0,false)
		revolver2=load_texture_object(read_vector_string(revolver_v),read_uv_string(revolver_uv),read_texture_face_string(revolver_f),-5,-3,-4,.1,.25,0,false)

end

function draw_score_screen()
	--cls(12)
	draw_background()
	update_3d()
	draw_3d()
	draw_crosshairs()
	draw_score(20,45)
	clip()
	print_2("game over",64,2,10,4)
	print_2("final score",64,25,10,4)
	print_2("click to start game",64,112,10,4)
end

function update_score_screen()
	update_objects()
	update_crosshairs()
	revolver1.vay=.01
	revolver2.vay=-.01
	
	if(cross_shoot and cur_frame>pause_time)then
		game_state=k_start_screen
		delete_object(revolver1)
		delete_object(revolver2)
		init_start_screen()
	end
	
end




function start_game()
	new_target()
	new_target()
	new_target()
	time=k_max_time
	bullets=max_bullets
	
	score={0,0,0,0,0,0,0,0,0,0}
	score_buffer=0
	streak=0
	score_multiplier=1
		
end

function update_game()
end

function _init()
	poke(0x5f2d, 1) --enable mouse
	palt(0,false)
	palt(14,true)

	cur_frame=0
	init_3d() --need to call init_3d() to set up player, camera and lights
	
	init_start_screen()

end

function _update()
	cur_frame+=1
	
	if(game_state==k_game_screen)then
	
		update_crosshairs()
		
		

		--object_matrix_transform(can_1,(cross_y/127-.5)*.1,(cross_x/127-.5)*.1,0)
		if(cross_shoot)then
			--can_1.vax,can_1.vay=-(cross_y-can_1.sy)/128*.15,(cross_x-can_1.sx)/128*.15
			handle_shot()
		end
		update_objects()
		
		
		update_particles()
		update_sprite_particles()
		update_text_particles()
		if(time<=0)then
			game_state=k_score_screen
			init_score_screen()
		end
	elseif(game_state==k_start_screen)then
		update_start_screen()
	elseif(game_state==k_score_screen)then
		update_score_screen()
	end
	update_camera()
	
end





 

cur_frame=0



function _draw()
	--cls(1)
	
	if(game_state==k_game_screen)then
		update_3d()
		
		
		draw_background()
		clip(0,12,128,96)
		draw_3d()
		clip()
		--rectfill(0,95,127,127,6)
		
		draw_crosshairs()
		
		--
		--circ(can_1.sx,can_1.sy,can_1.sradius,8)

		--check_triangle_intersect(50,10,80,50,10,55,cross_x,cross_y)

		check_all_triangle_intersect()
		
		draw_particles()
		draw_text_particles()
		draw_sprite_particles()
		draw_hud()
	elseif(game_state==k_start_screen)then
		draw_start_screen()
	elseif(game_state==k_score_screen)then
		draw_score_screen()
	end
	--print(stat(1),0,0,8)
	--if(stat(1)>1)while(true)do end
end

__gfx__
4444444eee4444ee4444444e4444444e4444444e4444444e4444444e4444444e4444444e4444444eeeee0000eeeeeeeeeeeeeeeeeeeeeeaaaaeeeeee00000000
4999994eee4994ee4999994e4999994e4994994e4999994e4999994e4999994e4999994e4999994eeee00a900eeeeeeeeeeee33eeeeeeeaaaaeeeeee00000000
4aa4aa4eee4aa4ee4444aa4e4444aa4e4aa4aa4e4aa4444e4aa4444e4444aa4e4aa4aa4e4aa4aa4eee00aff900eeeeeeeeee3333eeeee999999eeeee00000000
4aa4aa4eee4aa4ee4aaaaa4ee4aaaa4e4aaaaa4e4aaaaa4e4aaaaa4eeee4aa4e4aaaaa4e4aaaaa4eee00aff900eeeeeee3ee3b33eee9944444499eee00000000
4994994eee4994ee4994444e4444994e4444994e4444994e4994994eeee4994e4994994e4444994ee009af99900eeeee3b3e3b33ee944777777449ee00000000
4999994eee4994ee4999994e4999994e4444994e4999994e4999994eeee4994e4999994e4999994ee009af99900eeeee3b3e3b33ee947777777749ee00000000
4444444eee4444ee4444444e4444444eeee4444e4444444e4444444eeee4444e4444444e4444444ee009af99900eeeee3b333b33e94777777777749e00000000
4444444eee4444ee4444444e4444444eeee4444e4444444e4444444eeee4444e4444444e4444444ee009af99400eeeee3b333b33e94777777777749e00000000
eee000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000eeeeeeeeeeeeeeeeeee000000ee009af99400eeeeee3bb3b33e94777777777749e00000000
eee0aaaa0eeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000eeeee0aaaa0eeeeeeeeeeeeeeeeeee0aaaa0ee009af99400eeeeeee333b33e94777777777749e00000000
eee099990ee0000eeee00000000000ee000e0000aaa0eeeee09990ee0000eee00000eeee0009990ee009af99400eeeeeeeee3b33e94777777777749e00000000
ee0009990e0aaaa0ee0aaaaaaaaaaa00aaa0aaaa99900eeee09990e0aaaa0e0aaaaa0ee0aaa9990ee009af99400eeeeeeeee3b33e94777777777749e00000000
e0aaa99900a9999a00a99999999999a099999999999aa0eee099900a9999a0099999a00a9999990ee009aa99400eeeeeeeee3b33ee947777777749ee00000000
0a99999900999099009990000999099009999099999990eee099900999099009909990099909990e000999994000eeeeeeee3b33ee944777777449ee00000000
099909990099999900999a000999999009990e0099900eeee099900999999000009990099909990e009999994400eeeeeeee3b33eee9944444499eee00000000
0999099900999000ee0999aa0999000009990ee09990eeeee099900999000009999990099909990e000000000000eeeeeeeee33eeeeee999999eeeee00000000
0999099900999099000009990999099009990ee099900eeee099900999099099909990099909990e000000000000000000000000000000000000000000000000
0999a999aa999a99aaaaa9990999a99aa999a0e0999aa0ee0a999aa999a99a999a999a9999a999a0000000000000000000000000000000000000000000000000
e09999999999999999999990e0999999999990ee099990ee09999999999999999999999999999990000000000000000000000000000000000000000000000000
ee000000000000000000000eee00000000000eeee0000eee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000055555000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000005555555555550000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000005555555555550000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000055555065555550000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000555550006555555000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000005555550006555555000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000005555555065555555500000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000005550655555506555500000000000000000000000000000000000000000000000000000000000000000000
00000000000000000444444444444444400000000005500065555000655500000000000000000000000000000000000000000000000000000000000000000000
00000000000000000444444444444444400000000005500065555000655500000000000000000000000000000000000000000000000000000000000000000000
0000000000000000044aaaaaaaaaaaa4440000000005550655065506555500000000000000000000000000000000000000000000000000000000000000000000
0000000000000000044a9999999999a4440000000005555550006555555000000000000000000000000000000000000000000000000000000000000000000000
0055555555555555544aaaaaaaaaaaa4400066660000555550006555555000000000000000000000000000000000000000000000000000000000000000000000
00555555555444445444444444444444400666666660555555065555550000000000000000000000000000000000000000000000000000000000000000000000
0444444444444444444444444444444440066eeee660555555555555566666660000000000000000000000000000000000000000000000000000000000000000
044999999999999444666660000000000066ee6ee666055555555555666666660000000000000000000000000000000000000000000000000000000000000000
0449aaaaaaaaaaa444466660000000000666ee66ee66000000000000665555660000000000000000000000000000000000000000000000000000000000000000
0449a444444449a44444666066665566666eee66ee66566655666650665665660000000000000000000000000000000000000000000000000000000000000000
04449a44444449a44444455066665566666666666666666655666650665555660000000000000000000000000000000000000000000000000000000000000000
00449a44444449a44444467064465566666565656565656665666650666666660000000000000000000000000000000000000000000000000000000000000000
066449a44444449a4444444444465566655555655565556666666650444444440000000000000000000000000000000000000000000000000000000000000000
066449a44444449a4444444444665566655666666666666666666650444444440000000000000000000000000000000000000000000000000000000000000000
0054449a4444449a4444444444665566655665666666556655666650444aa4440000000000000000000000000000000000000000000000000000000000000000
0055449a4444449a444444444466556665566565556666555566665044a99a440000000000000000000000000000000000000000000000000000000000000000
00554449a444449a444444444466556665565555556666555566665044a99a440000000000000000000000000000000000000000000000000000000000000000
00555449a44449a44444444444665566655555555566665555556650444aa4440000000000000000000000000000000000000000000000000000000000000000
005554449a449a444444444444665566655555555566665555555550444444440000000000000000000000000000000000000000000000000000000000000000
001111449a99a4444444444466665566655555555566665555555550444444440000000000000000000000000000000000000000000000000000000000000000
0011114444aa44444444446066665556655555555566665555555550444444440000000000000000000000000000000000000000000000000000000000000000
00111114444444444444466666665556655555555577775555555550444444440000000000000000000000000000000000000000000000000000000000000000
0055555544444444444466666666555565555555555555555555555044aaaa440000000000000000000000000000000000000000000000000000000000000000
0000500000044444444666666000005555555555555555555555550044a99a440000000000000000000000000000000000000000000000000000000000000000
0000000000044444446666666600000555555555555555555555550044a99a440000000000000000000000000000000000000000000000000000000000000000
0000000000000044406666666660000555555555555555555555550044a99a440000000000000000000000000000000000000000000000000000000000000000
0000000000000000000666666660000555555555555555555555550044a99a440000000000000000000000000000000000000000000000000000000000000000
0000000000000000000666666600000055555555555055555555550044a99a440000000000000000000000000000000000000000000000000000000000000000
0000000000000000000066660000000055555550000000005555550044a99a440000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000006000000055555000000000000055550044a99a440000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000066666000055500000000000000005550044a99a440000000000000000000000000000000000000000000000000000000000000000
0055555555555555555555556666660000000000000000000005555544a99a440000000000000000000000000000000000000000000000000000000000000000
0055555555555555555555556666666000000000000000005555555044a99a440000000000000000000000000000000000000000000000000000000000000000
0555555555555555555555556660065555555555555555555555555044a99a440000000000000000000000000000000000000000000000000000000000000000
0055555555555555555555556660555555555555555555555555555044a99a440000000000000000000000000000000000000000000000000000000000000000
0055555555555555555555556660055555555555555555555555555044a99a440000000000000000000000000000000000000000000000000000000000000000
0056565656565656565656567676665555555555555555555555555544aaaa440000000666600000000000000000000000000000000000000000000000000000
00656565656565656565656567666600000000000000005555555550444444440000066666666000000066666666000000000000000000000000000000000000
00666666666666666666666677766660000000000000005550550550444444440006666666666600006666666666600000000000000000000000000000000000
00666666666666666666666677706666000000000000000055000000004444440066666666666660006666666666660000000000000000000000000000000000
00676767676767676767676777705555666667766667777666776666665555000066666555556666066666666666666000000000000000000000000000000000
00767676767676767676767677705566666677766677777766777666666655000606665666665666666777766666666600000000000000000000000000000000
00676767676767676767676777705555666667766667777666776666665555000666656666776566667666655555666600000000000000000000000000000000
00777777777777777777555577765566666677766677777766777666666655000666656666776566667666566656566600000000000000000000000000000000
00777777777777777777555577765555666667766667777666776666665555000066656666776566667666565656566600000000000000000000000000000000
00676767676767676767676777765566666677766677777766777666666655000666656777776566667666566656566600000000000000000000000000000000
00767676767676767676767677765555666667766667777666776666665555000666656777776566667666655555666600000000000000000000000000000000
00676767676767676767676777765566666677766677777766777666666655000666665666665666666777766666666600000000000000000000000000000000
00666666666666666666666677765555666667766667777666776666665555000666666555556666666666666666666000000000000000000000000000000000
06666666666666666666666677765566666677766677777766777666666655000000666666666666006666666666660000000000000000000000000000000000
00656565656565656565656576765555666667766667777666776666665555000000666666666660000066666666000000000000000000000000000000000000
00565656565656565656565667665566666677766677777766777666666655000000000666600000000000066660000000000000000000000000000000000000
00000000000000000000000000005555666667766667777666776666665555000066666666666666666666666666666666666666666666666000000000000000
00000000000000000000000000007777777777777777777777777777777777000555555555555555555555555555555555555555555555555000000000000000
00000000000000000000000000000000000000000000000000000000000000000888888888888888888888888888888888888888888888888000000000000000
0000000000000000000000000000000000000000000000aaaaa00000000000000888888888888887877788888877888888888888888888888000000000000000
00000000000000000000000000000000007777777777777777777777777777700888888888888888888888888778888888888888888888888000000000000000
00000000000000000000000000000000005555555555550000000000000000000888888888888888877888888778888888887777777778888000000000000000
00000000044444444444444444000000004444444444444444444444444444440888888888888888788788888778888888888888888888888000000000000000
0000000004aaaaaaaa44aa4444000000004444444444444444444444444444440888888888888888777777888778888888887778788888888000000000000000
0000000004a999999a44a9a444000000004444444444444444444444444444440888888888888888888888888778888888888888888888888000000000000000
0000000004a999999a44a9a444000000004444444444444444444444444444440888888888888887777788888778888888887778877888888000000000000000
0000000004aaaaaaaa44aa4444000000004444444444488444488444444444440888888888888878788788888778888888888888888888888000000000000000
00000000044444444444444444000000004444444444488844888444444444440888888888888878877788888778888888887788888888888000000000000000
00000000000000000000000000000000004444444444488888888444444444440888888888888888888888888778888888888888888888888000000000000000
00000000000000000000000000000000004444444444488888888444444444440888888888887777777788887788888888887777788888888000000000000000
00000000000000000000000000000000004444444444488800888444444444440888888888888888888887887788888888888888888888888000000000000000
00000000000000000000000000000000004444444444488044088444444444440888888888888788778877887788888888888888888888888000000000660000
00000000000000000000000000000000004444444444400444400444444444440888888888887887887878887788888888888888888888888000000666600000
00006666660000000000000000000000004444444444444444444444444444440888877788887888778878887788888888888888788888888000000666000000
00066555566000000755557500000000004444444444444444444444444444440888888888888788888778887788888888888887778888888000006660000000
00665000056600000550055500000000004444444444444444444444444444440888877788888877777788877888888888888877777888888000000660000000
00650666675600000500005000000000006666666666666666666666666666660888887888888888888888888888888888888877777888888000000000000000
00650666675600000500005000000000006666666666666666666666666666660666666666666666666666666666666666666666666666666000000000000000
00650666675600000550055000000000004444444444444444444444444444440555555555555555555555555555555555555555555555555000000000000000
00650666675600000655556000000000004444444444444444444444444444440000000000000000000000000005555000000000000000000000000000000000
0066577775660000000000000000000000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa0000000000000000000000000000000000000000000000000000000000000000
00066555566000000000000000000000004444444444444444444444444444440000000000000000000000000000000000000000000000000000000000000000
00006666660000000000000000000000004444444444444444444444444444440000000000000000777777770000000000006666666660000000000000000000
00000000000000000000000000000000004444444447777777777774444444440000000000000077777777777700000000066666666660000000000000000000
00000000000000000000000000000000004444444447888888888874444444440000aa0000000777778888777770000000600000000666000000000000000000
666666666666666666666666666666666677774444478666666668744444777700aaaaaaa0000777788888877777000006000000000006600000000000000000
555555555555555555555555555555555500074444475770777775744444700000aaaaaaa0007777887777887777000060066000000000660000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb77774444477077707777744444777700aaaaaaa0007778877777788777000060006600000000660000000000000000
555555bbbbbbbbaaaaaaabbbbbbbbb5555000744444777555555777444447000000aaaaaa0007788777887778877000060000066000000660000000000000000
666665bbbbbbba8888888abbbbbbbb5666777744444755666666557444447777000aaaaaa0007788778888778877000060000006600000660000000000000000
000065bbbbbbba8778778abbbbbbbb56007777444447867766666874444477770000004440007788778888778877000060000006666000660000000000000000
666665bbbbbbba8888788abbbbbbbb56660007444447866767666874444470000004444440007788777887778877000060000006006000660000000000000000
666665bbbbbbbba88888abbbbbbbbb56667777444447867767676874444477770044555544007778877777788777000060000006600600660000000000000000
000065bbbbbbbbbaaaaabbbbbbbbbb56007777444447866666666874444477770045555554007777887777887777000060000000666606660000000000000000
666665bbbbbbbbbbbbbbbbbbbbbbbb56667707444447888888888874444470000045544554000777788888877770000060000000000006660000000000000000
555555bbbbbbbb77b7b77bbbbbbbbb55557777444447777777777774444477770045544554000077778888777700000060006666666666660000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb5555444445555555555554444455550045555554000007777777777000000060000666660006660000000000000000
66666666666666666666666666666666664444444444444444444444444444440004555544000007777777770000000066666666666666660000000000000000
55555555555555555555555555555555555555555555555555555555555555550004444440000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
00000000000000001ba5aaacab9c8a859cc2c6d3d5cdc3c8cce6e4dfdfded2c3b8aba3a6aee5ecece9e3dca19e9b97928d878079726a62594c3a0b0000000000000000000000000017a7acb0b2afa5acbec3c6d3d3c9bfc0c9e3e4dfe0e0decec3b9aba8ccecedece8e2daa09d9b97928c867f78716961584b39080000000000
000000000000000013a9aeb2b6b8babdc0c3c7d3cfc5bab5c6d2e4e0e0e1e1decec4b5c9efeeeeece7e0d89f9c9a96918b857e77706860564938050000000000000000000000000013aaaeb4b7babcbfc1c3c8d2ccc1b5adc3bfe3e1e0e2e3e4e4dde1efefefeeece6ded69e9c9995908a837d756e665e564836030000000000
000000000000000019a8afb4b8bbbdc0c1c3c8d0cabeb0a5bfbae3e1dfe3e5e7e9ebeef0f0f0efebe5ddd69d9b98948f89827b756d655d544634010000000000000000000000000036a6aeb3b8bbbebfc1c3c9cfc7bbada0afb7e2e1dfe3e6e9ebeef0f0f1f0efebe4dcd79c9a97938d87817a736c645c53452f000000000000
00000000000000006fa2acb2b7babdbfc1c2c9cfc6b8aa9c97b4e2e1dfe3e6eaedeff0f1f1f1efeae3dad59e9997928c868079726a635b51452300000000000000000000000000117e9fa9b0b5b9bbbdbfc1c9cec5b5a7988eb0e2e1dfe2e6e9edeeeff1f1f1eee9e2dbd59f9896908a847e787169615a504318000000000000
000000000000001b7f9ba7adb2b6b8babdc1cacec4b4a49586aae1e1dfe1e4e8ecedeff0f0f0ede8e1dad5af97948f89847d766f6860594f420b00000000000000000000000000378199a4aab0b3b6b7bcc1cacec4b3a292ae8fe1e1dfe0e2e6eaebedeeefeeebe7e0dad5d09e928d87827c756f675f584e3f04000000000000
00000000000000438297a2a7acb0b3b4bac1cbcec4b2a193bfa8e1e1dfdfe0e2e7eaececedeceae6e0dad5d1cac69286817a746e675f574e3b0300000000000000000000000000498496a0a6aaaeb1b3b9c2cccec4b2a093c0b2e1e1e0dedee0e4e7e9eaeaeae8e5e0dad6d1cdc6bf84807a746e665f564c3201000000000000
000000000000004b85969fa4a8acafb2b9c5ced0c5b29f92c0b3e2e2e0dedddde0e4e6e7e8e8e7e4dfdbd6d1cdc8c0a07f79746e665d564b2400000000000000000000000000003b85959fa3a7aaaeb1b9c7cfd2c7b29d92bfb8e3e3e1dfdddcdee2e4e5e7e7e6e3dfdbd6d2cec8c2b9807b756e655e554a1400000000000000
000000000000002485959ea3a6a9adb0b9c9d1d5c7d7d08cc0d9e5e4e2dfdddbdde0e2e4e5e6e5e2dfdbd7d2cec9c2b9977e766d655e55490800000000000000000000000000001586949da2a5a8acb0bbcbd3d7d0e9eacec1e7e6e5e3e0dddbdddfe0e2e4e5e4e2dfdbd7d3cfc9c2b8a889776c655c54400200000000000000
000000000000000a87929ba1a4a7abb0bccdd5dadfe8e9e6d5e7e7e6e4e0dddbdcdedfe2e4e4e3e1dedbd7d3cec8c2b5a994766b645d533001000000000000000000000000000000758f989ea3a6aab0becfd6dde3e8e9e9e9e8e9e7e5e1dcdadbdcdee1e3e3e2e1dedbd7d3cdc7bdaca48e726b635b51240000000000000000
000000000000000018928787a4a4a9afc1d2d8dee5eaeaeaeae9e9e8e5e2dcdadadbdde0e2e2e2e0dedad6d2cdc6a4a59f7d6d69625a4c1500000000000000000000000000000000000b00000299a8afc3d4dae0e7ebebebebeaeae9e6e2dcdadadbdcdee0e1e1dfddd9d6d1cca3999e9567686660593b060000000000000000
0000000000000000000000000072a4aec7d6dce3e9edededececebeae7e2dddad9dadbdcdfe0dfdedbd8d4cf9d8d9496716465635e5730010000000000000000000000000000000000000000007792aeccd9dfe5ecefefefeeededebe8e3ddd9d8d9d9d29387d5d9d9d6d0928d8c8a605d6062605c5329000000000000000000
00000000000000000000000000777aaed2dbe2e9eff0f2f1f0efefede9e3ddd9d8d8c9414855bbb6bcada392918d775c5c5d5e5e594b1a000000000000000000000000000000000000000000007879afd7dee6edf0f2f4f3f2f1f1eeeae4ddd9d7d69b474854bbb8b3aaa398928e685d5d5c5c5b564104000000000000000000
000000000000000000000000007a7ab5dbe2e9f0f2f5f7f5f5f3f3f0ebe6dedad8d298474759bab8b3aaa398918e5f5f5e5d5b59533700000000000000000000000000000000000000000000007b7bc1dee6ecf2f4f7f9f7f8f5f5f1ece7dfdad7d08c48476bbab8b2aba398918060605f5e5b574f3000000000000000000000
0000000000000000000000000d7c7ccadfe7edf2f6f7f9f9f9f7f7f3eee9e1dad7cf6949467fbab8b2aba39991726160605e5b554b2000000000000000000000000000000000000000000000107d7bcfdde4ecf1f6f6f8f8f8f7f7f5f0eae2dbd6cc60494692bbb7b2aba39a91696261605f5b55480900000000000000000000
000000000000000000000000267e7ad4dce8eff4f4f7fbf7f8f6f6f4f1ebe3dbd6c7664843b2bbb7b2aba49a92626261615f5b54410000000000000000000000000000000000000000000000387f7cd4e2e9f2f5f4fbfcf9fbf8f3f5f1ede4dcd4c3644744c4bbb8b2aba49a875f6161615f5b53380000000000000000000000
00000000000000000000000041817ed8e5ecf3f7f7fbfdfbfdfaf5f6eeebe4dcd2bc96414cc1bbb8b2aba49a715f6161615f5b522500000000000000000000000000000000000000000000004e8380dae7eef4f8f9fcfdfcfdfbf7f6ecece1d7d0bfac3a55c0bcb8b2aba49a62606161615f5b4e0a0000000000000000000000
000000000000000000000000658681d7e9edf5f7fafdfefdfefdf8f6ecece0d5cfbeb13673bfbcb8b3aca49a5e606162615f5a43000000000000000000000000000000000000000000000000648989dde7ecf4f8f9fdfefdfffdf8f6ecece0d5cdbfac06aec0bdb8b3aca49a58616262625f582c000000000000000000000000
000000000000000000000000668ba8dee2eff3fafcfdfcfcfefaf7f9eceae0d5cbbe872ec3c1bdb8b3aca58956616363625f5300000000000000000000000000000000000000000000000000688fc1dde8f1f4fafcfefcfefaf9f8faeeecded5c7bb8c6bc4c2beb8b3aca46c57626363615d3d00000000000000000000000000
0000000000000000000000006c93c6dde9f1f5fafcfefdfffcfdf9faf0ede5decabebabac6c3beb8b2aca346516364635f5b0b000000000000000000000000000000000000000000000000007498c4dee9f2f5f9fbfefefffdfdf8faf0ede6e0d1c1bec7c8c3beb9b2aca335476363625c410000000000000000000000000000
0000000000000000000000007b9dc3dce7f2f4f9fafdfefffdfdf7f9f0ece6e0d2c6caccc9c4bfb9b2aba2293364635f5c04000000000000000000000000000000000000000000000000000086a4c8dee7f1f2f8f9fdfdfffbfdf7f8efeae5dfd1cecfcecbc4bfb9b1aaa1090063605e1b000000000000000000000000000000
0000000000000000000000009aafcbe1ebf0f2f6f6fbfdfefefdf9f7f2ece8e0d6d4d3d1ccc5beb9b1a9a006003d5d2600000000000000000000000000000000000000000000000000000000a0b8ccdeeaf0f4f7f9fbfefefffdfaf6f2ede9e3ddd9d6d3cdc6bfb8b1a9a2010000000000000000000000000000000000000000
000000000000000000000001a7bdcedce7eff3f6f8fbfdfdfdfcf9f6f2edeae5e0dcd9d5cec6bfb8b0a89d000000000000000000000000000000000000000000000000000000000000000002aec0cedbe4edf2f4f7fafcfcfbfaf8f5f2eeebe7e3dedbd6cfc7bfb8b0a781000000000000000000000000000000000000000000
000000000000000000000002b0c0cfdae2eaf0f2f5f8fafbfaf8f7f4f2f0ece8e5e0ddd7d0c7bfb7afa66c000000000000000000000000000000000000000000000000000000000000000002b1c1cfd9e1e8eef1f4f7f9f9f8f8f6f4f2efedeae6e2ded8d0c8bfb8afa551000000000000000000000000000000000000000000
000000000000000000000002b1c1cfd8e0e7edf0f3f5f7f8f7f6f5f3f2efedeae7e3ded9d0c8bfb7aea42f000000000000000000000000000000000000000000000000000000000000000002b1c2cfd8e0e7ecf0f2f4f6f6f6f6f5f3f2efedeae7e3dfd9d0c8bfb7aea40e000000000000000000000000000000000000000000
000000000000000000000002b2c3ced9e1e8ecf0f2f4f6f6f6f5f5f3f1efedeae6e3ded8d0c8bfb7aea50b000000000000000000000000000000000000000000000000000000000000000002b3c3cfd9e2e9eef1f3f5f7f7f6f6f5f3f1efedeae6e2ded7cfc7bfb7aea507000000000000000000000000000000000000000000
000000000000000000000001b3c4d0dbe3eaeff2f5f7f8f8f7f6f5f3f1efedeae7e2ddd6cec6beb7aea800000000000000000000000000000000000000000000000000000000000000000000b1c5d2dce5ecf1f4f7f8f9f9f8f7f5f3f1efedeae7e2ddd5cdc5bdb6ad6500000000000000000000000000000000000000000000
000000000000000000000000a6c6d4dee7edf3f6f8f9fafaf9f8f6f4f2efedeae7e2dbd4cbc3bcb4aa090000000000000000000000000000000000000000000000000000000000000000000062c7d5e0e9eff4f7f9fbfbfbfaf8f7f5f2f0edebe6e1d9d1c8c0b9b53b0000000000000000000000000000000000000000000000
00000000000000000000000015c8d6e1eaf0f5f8fafbfcfcfbf9f8f5f3f0eeeae5dfd8cfc6c6791c00000000000000000000000000000000000000000000000000000000000000000000000000c4d6e3ebf2f5f8fafcfdfdfcfaf8f6f3f0eee9e3dcd5d08b100000000000000000000000000000000000000000000000000000
00000000000000000000000000b6d7e4ecf2f6f8fafcfefdfdfbf9f6f3f0ece8e1d9d44e00000000000000000000000000000000000000000000000000000000000000000000000000000000004ad8e4edf2f5f7fbfcfefefdfbf9f6f2efebe5e2a6070000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000cde3ebf1f4f6f9fcfdfefdfbf8f5f2eee9e87c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006ce3e8eef2f5f7fafcfdfcfaf8f5f1f2b6250000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000005dcbd4d7dae1f8fcfbf9f8f7f7d93300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000015191cfce9c3e000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100001064024640166300a6301c6200f61005610136100a610036100c61006610026100a610056100261007610046100161005610026100161004610016100361002610016100261001610016100161001610
000400001175013530211002a20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001304016640166401360014030156301563014600120201562015620186000000015600156000000000000146001460000000000001460014600000000000014600146000000000000000000000000000
000100001e6002a61032610396003f6002d6003f6403e6203c6103861034600296000160025600256002f6001d600276000000000000000000000000000000000000000000000000000000000000000000000000
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
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
