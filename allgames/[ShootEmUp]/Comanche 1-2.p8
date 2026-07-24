pico-8 cartridge // http://www.pico-8.com
version 15
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
	return (read_byte(sub(string,1,2))*256+read_byte(sub(string,3,4)))/256
end
function load_string(string)
	cur_string=string
	cur_string_index=1
end

function read_vector()
	v={}
	for i=1,3 do
		v[i]=read_2byte_fixed(sub(cur_string,cur_string_index,cur_string_index+4))
		cur_string_index+=4
	end
	return v
end

function read_face()
	f={}
	for i=1,3 do
		f[i]=read_byte(sub(cur_string,cur_string_index,cur_string_index+2))
		cur_string_index+=2
	end
	return f
end		

function read_vector_string(string)
	vector_list={}
	load_string(string)
	while(cur_string_index<#string)do
		add(vector_list,read_vector())
	end
		return vector_list
end

function read_face_string(string)
	face_list={}
	load_string(string)
	while(cur_string_index<#string)do
		add(face_list,read_face())
	end
		return face_list
end
--face[1]->face[3]=vertex index
--face[4]=face color

function read_color_face_string(string)
	face_list={}
	load_string(string)
	--read to first material
	while(cur_string_index<#string)do
		cur_string_index+=1
		local face_color = char_to_hex[sub(cur_string,cur_string_index,cur_string_index)]
		cur_string_index+=1
		while(sub(cur_string,cur_string_index,cur_string_index)!='m' and cur_string_index<#string) do
			face=read_face()			
			face[4]=face_color
			add(face_list,face)
		end
	end
	return face_list
end
------------------------------------------------------------end hex string data handling--------------------------------
-------------------------------------begin 3d utility functions----------------------------------

function normalize(x,y,z)
	local x1=shr(x,2)
	local y1=shr(y,2)
	local z1=shr(z,2)
	local inv_dist=1/sqrt(x1*x1+y1*y1+z1*z1)
	return x1*inv_dist,y1*inv_dist,z1*inv_dist
end

function	vector_dot(ax,ay,az,bx,by,bz)
	return ax*bx+ay*by+az*bz
end

function	vector_cross_3d(px,py,pz,ax,ay,az,bx,by,bz)
	 ax-=px
	 ay-=py
	 az-=pz
	 bx-=px
	 by-=py
	 bz-=pz
	return ay*bz-az*by,az*bx-ax*bz,ax*by-ay*bx
end

function	cross_product_2d(p0x,p0y,p1x,p1y,p2x,p2y)
	return ( ( (p0x-p1x)*(p2y-p1y)-(p0y-p1y)*(p2x-p1x)) < 0 )
end

function check_triangle_intersect(x1,y1,x2,y2,x3,y3,px,py)
	if(cross_product_2d(px,py,x1,y1,x2,y2))return false
	if(cross_product_2d(px,py,x2,y2,x3,y3))return false
	if(cross_product_2d(px,py,x3,y3,x1,y1))return false	
	return true
end

function isleft(ax,ay,bx,by,cx,cy)
     return ((bx - ax)*(cy - ay) - (by - ay)*(cx - ax))
end

function facing(ax,ay,avx,avy,bx,by)
	nx=shr(ax-bx,3)
	ny=shr(ay-by,3)
	l=sqrt(nx*nx+ny*ny)
	nx/=l
	ny/=l
	
	return nx*avx+ny*avy
end

function rand_dir()
	return rnd(2)-1
end
---------------------------begin gryphon 3d library---------------------------------------------------------------------
obj_list={}

function load_obj(obj_vertices,obj_faces,x,y,z)
	obj={t_vertices={},vertices=obj_vertices,base_faces=obj_faces,faces={},
	normals={},t_normals={},radius=0,ax=0,ay=0,az=0,x=x,y=y,z=z,
	visible=true,mat={{1,0,0,0},{0,1,0,0},{0,0,1,0},{0,0,0,1}}}
	
	for i=1,#obj_vertices do
		obj.t_vertices[i]={}
			for j=1,3 do
				obj.t_vertices[i][j]=obj.vertices[i][j]
			end
	end

	for i=1,#obj_faces do
		obj.faces[i]={}
		for j=1,#obj_faces[i] do
			obj.faces[i][j]=obj_faces[i][j]
		end
	end

	for i=1,#obj.faces do
		local face=obj.faces[i]
		local p1=obj.t_vertices[face[1]]
		local p2=obj.t_vertices[face[2]]
		local p3=obj.t_vertices[face[3]]

		nx,ny,nz = vector_cross_3d(p1[1],p1[2],p1[3],p2[1],p2[2],p2[3],p3[1],p3[2],p3[3])
		nx,ny,nz = normalize(nx,ny,nz)
		
		obj.normals[i]={nx,ny,nz}
		obj.t_normals[i]={}
	end


	add(obj_list,obj)
	return obj
end



--reset rotation matrix to unit vector
function reset_obj(obj)
	obj.mat={{1,0,0,0},{0,1,0,0},{0,0,1,0},{0,0,0,1}}
end

function rotate_obj_x(obj,xa)
	local cx = cos(xa)
	local sx = sin(xa)
	local mat=obj.mat
	obj.mat=	{{mat[1][1],mat[2][1]*cx+mat[3][1]*sx,-mat[2][1]*sx+mat[3][1]*cx},
				 {mat[1][2],mat[2][2]*cx+mat[3][2]*sx,-mat[2][2]*sx+mat[3][2]*cx},
				 {mat[1][3],mat[2][3]*cx+mat[3][3]*sx,-mat[2][3]*sx+mat[3][3]*cx}}
end

function rotate_obj_y(obj,xa)
	local cx = cos(xa)
	local sx = sin(xa)
	local mat=obj.mat
	obj.mat=	{{mat[1][1]*cx-mat[3][1]*sx,mat[2][1],mat[1][1]*sx+mat[3][1]*cx},
				 {mat[1][2]*cx-mat[3][2]*sx,mat[2][2],mat[1][2]*sx+mat[3][2]*cx},
				 {mat[1][3]*cx-mat[3][3]*sx,mat[2][3],mat[1][3]*sx+mat[3][3]*cx}}
end

function rotate_obj_z(obj,xa)
	local cx = cos(xa)
	local sx = sin(xa)
	local mat=obj.mat
	obj.mat=	{{mat[1][1]*cx+mat[2][1]*sx,-mat[1][1]*sx+mat[2][1]*cx,mat[3][1]},
				 {mat[1][2]*cx+mat[2][2]*sx,-mat[1][2]*sx+mat[2][2]*cx,mat[3][2]},
				 {mat[1][3]*cx+mat[2][3]*sx,-mat[1][3]*sx+mat[2][3]*cx,mat[3][3]}}
end

function transform_obj(obj)
		--rotate_obj(obj,obj.ax,obj.ay,obj.az)
		local mat=obj.mat
		for i=1, #obj.vertices do
			local t_vertex=obj.t_vertices[i]
			local vertex=obj.vertices[i]
			t_vertex[1]  = vertex[1]*mat[1][1]+vertex[2]*mat[2][1]+vertex[3]*mat[3][1]
			t_vertex[2]  = vertex[1]*mat[1][2]+vertex[2]*mat[2][2]+vertex[3]*mat[3][2]
			t_vertex[3]  = vertex[1]*mat[1][3]+vertex[2]*mat[2][3]+vertex[3]*mat[3][3]
		end
		for i=1, #obj.normals do
			local t_vertex=obj.t_normals[i]
			local vertex=obj.normals[i]
			t_vertex[1]   = vertex[1]*mat[1][1]+vertex[2]*mat[2][1]+vertex[3]*mat[3][1]
			t_vertex[2]   = vertex[1]*mat[1][2]+vertex[2]*mat[2][2]+vertex[3]*mat[3][2]
			t_vertex[3]   = vertex[1]*mat[1][3]+vertex[2]*mat[2][3]+vertex[3]*mat[3][3]
			--t_vertex[1],t_vertex[2],t_vertex[3]=rotate_point(vertex[1],vertex[2],vertex[3])
		end
end

function rotate_point(x,y,z)	
	return (x)*mat00+(y)*mat10+(z)*mat20,(x)*mat01+(y)*mat11+(z)*mat21,(x)*mat02+(y)*mat12+(z)*mat22
end

function cam_transform_obj(obj)
	--this was extra/a waste before, but now it's necessary to fold in
	--the fakery with landscape tilt and pitch
	local sinphi = sin(-phi+.25)
	local cosphi = cos(-phi+.25)
		for i=1, #obj.vertices do
			local vertex=obj.t_vertices[i]
			vertex[1]+=obj.x - cam_x
			vertex[2]+=obj.y - cam_y
			vertex[3]+=obj.z - cam_z
			--vertex[1],vertex[2],vertex[3]=rotate_cam_point(vertex[1],vertex[2],vertex[3])
			vertex[1],vertex[3] = -vertex[1]*sinphi+vertex[3]*cosphi ,  vertex[1]*cosphi+vertex[3]*sinphi
		end
end

function check_visibility(obj)
	--transform and project the origin of the obj and see if it's visible
	--then we can save time on expensive stuff.
	obj.visible=false
	local sinphi = sin(-phi+.25)
	local cosphi = cos(-phi+.25)
	local x=obj.x-cam_x
	local y=obj.y-cam_y
	local z=obj.z-cam_z
	x,z=-x*sinphi+z*cosphi ,  x*cosphi+z*sinphi
	local sx = 64*x/z+64
	local sy = -64*y/z+64
	--really this should be done with cross product
	--to measure distance from frustum...but eh it works
	if(z>-10 and z<300)then
		if(sx>-15 and sx<143) then
			if(sy>-15 and sy<143) then
				obj.visible=true
			end
		end
	end
end

function quicksort(t, start, endi)
   start, endi = start or 1, endi or #t
  --partition w.r.t. first element
  if(endi - start < 1) then return t end
  local pivot = start
  for i = start + 1, endi do
    if t[i].zp <= t[pivot].zp then
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

function render_obj(obj)
	--project all points in obj to screen space
	--it's faster to go through the array linearly than to use a for all()
	local tilt_delta=-sin(tilt_angle)
	local tilt_start=tilt_delta*64
	for i=1, #obj.t_vertices do
		local vertex=obj.t_vertices[i]
		vertex[4] = 64*vertex[1]/vertex[3]+64
		vertex[5] = -64*(vertex[2])/vertex[3]+64+tilt_start-tilt_delta*vertex[4]+vertex[3]*pitch_slope
	end
	for i=1,#obj.faces do
	--for face in all(obj.faces) do
		local face=obj.faces[i]
		local p1=obj.t_vertices[face[1]]
		local p2=obj.t_vertices[face[2]]
		local p3=obj.t_vertices[face[3]]
		local p1x,p1y,p1z=p1[1],p1[2],p1[3]
		local p2x,p2y,p2z=p2[1],p2[2],p2[3]
		local p3x,p3y,p3z=p3[1],p3[2],p3[3]
		local cz=(p1z+p2z+p3z)/3
		local cx=(p1x+p2x+p3x)/3
		local cy=(p1y+p2y+p3y)/3
		local z_paint= -cx*cx-cy*cy-cz*cz
		face[6]=z_paint
		if((p1z<300 or p2z<300 or p3z<300))then
			if(p1z> 1 and p2z> 1 and p3z> 1)then
			--simple option -- no clipping required
					local s1x,s1y = p1[4],p1[5]
					local s2x,s2y = p2[4],p2[5]
					local s3x,s3y = p3[4],p3[5]
					if( (s3x>0 or s2x>0 or s1x>0) and (s3x<128 or s2x<128 or s1x<128))then
						--only use backface culling on simple option without clipping
						--check if triangles are backwards by cross of two vectors
						if(( (s1x-s2x)*(s3y-s2y)-(s1y-s2y)*(s3x-s2x)) > 0)then
							local normal = obj.t_normals[i]
							add(triangle_list,{p1x=s1x,
												p1y=s1y,
												p2x=s2x,
												p2y=s2y,
												p3x=s3x,
												p3y=s3y,
												tz=cz,
												zp=z_paint,
												color_code=color_ramp[face[4]][ flr((mid( normal[1]*light1_vx+normal[2]*light1_vy+normal[3]*light1_vz,0,1)*(1-.1)+.1)*128)],parent=obj})
							
						end
					end
					
			end
		end
	end
end

function draw_triangle_list()
	for i=1,#triangle_list do
		local t=triangle_list[i]
		vert_trifill( t.p1x,t.p1y,t.p2x,t.p2y,t.p3x,t.p3y,t.tz, t.color_code)
	end
end

function update_3d()
	for obj in all(obj_list) do
			check_visibility(obj)
			if(obj.visible)then
				transform_obj(obj)
				cam_transform_obj(obj)
			end
	end
end

function draw_3d()
	triangle_list={}
	for obj in all(obj_list) do		
		if(obj.visible)then
			render_obj(obj) 
		end
	end
		quicksort(triangle_list)
		draw_triangle_list()
end
----------------------------------------new map system---------------------------------------------------------------
--maps remade with a better looping noise function
--right now using smoothstep for lerping, this could cause ripples
--but seems to be looking okay for now
local map_width=128

function smoothstep(h1,h2,t)
	t=mid(t,0,1)
	t=(t*t*(3-2*t))
	return (h2-h1)*t+h1
end

function pause(dur)
	while(dur>0)do dur-=1 flip() end
end
map_array_list={}

function smooth_loop_noise(x,y,freq)
	--cls()
	x%=map_width
	y%=map_width
	srand(rand_start)
	local step_width=map_width/freq
	--make a new noise array if we don't have one at this freq already
	if(map_array_list[freq]==nil)then
		--generate temp array
		map_array_list[freq]={}
		for i=0,freq-1 do
			--map_array_list[freq][i]={}
			local malfi=map_array_list[freq]
			malfi[i]={}
			for j=0,freq-1 do
				malfi[i][j]=rnd(1)
			end
		end
	end
	local left_cell=flr(x/step_width)
	local right_cell=(left_cell+1)%freq
	local top_cell=flr(y/step_width)
	local bot_cell=(top_cell+1)%freq
	local xt=(x/step_width)-flr(x/step_width)
	local yt=(y/step_width)-flr(y/step_width)
	local um=smoothstep(map_array_list[freq][left_cell][top_cell],map_array_list[freq][right_cell][top_cell],xt)
	local bm=smoothstep(map_array_list[freq][left_cell][bot_cell],map_array_list[freq][right_cell][bot_cell],xt)
	return smoothstep(um,bm,yt)
end
----------------------------------------begin landscape 3d functions-------------------------------------------------

function map_function(x,y)

	--return sin(x/32)*10+cos(y/32)*10+20
	
	return mid(0,300,smooth_loop_noise(x,y,6)^3*70+smooth_loop_noise(x,y,15)^2*30+smooth_loop_noise(x,y,64)*2-10)
	--return h

end
light1_vx,light1_vy,light1_vz=normalize(.125,.25,.1)
map={}
b_map={}


function init_map()
	for x=0,map_width do
		map[x]={}
		b_map[x]={}
		local lmapx=map[x]
		local lb_mapx=b_map[x]
		for y=0,map_width do
			local h=map_function(x,y)
			ax=x+.1
			local az=y
			local ay=map_function(ax,az)
			local bx=x
			local bz=y+.1
			local by=map_function(bx,bz)
			local ep=.1
			local nx = map_function(x+ep,y)-map_function(x-ep,y)
			local ny = ep
			local nz = map_function(x,y+ep)-map_function(x,y-ep)
			nx,ny,nz = normalize(nx,ny,nz)
			local brightness= flr(( mid(0,1,vector_dot(light1_vx,light1_vy,light1_vz,nx,ny,nz))*.75+.25)    *128)
			lmapx[y]=h
			lb_mapx[y]=brightness
			local color=11
			if(h<14)color=4
			if(h<3)color=12
			rectfill(x,y,x,y,color_ramp[color][brightness])
			color=11
			if(h<30)color=3
			if(h<16)color=1
			if(h<3)color=0
			sset(shr(x,2),shr(y,2)+16,color)
		end
		rectfill(0,10,127,19,color_ramp[7][flr(x/2)])
		rectfill(0,9,127,17,color_ramp[7][x])
		rectfill(0,8,127,9,color_ramp[7][mid(0,127,(x*2))])
		center_text("building world",64,11,0x0077)
		
		if(x%4==0)flip()
		
	end
	--clean up
	for freq,map_array in pairs(map_array_list)do
		for index,row in pairs(map_array) do
			del(map_array,index)
		end
		del(map_array_list,freq)
	end
end

function center_text(text,x,y,c)
	x=x-#text/2*4
	print(text,x,y,1)
	print(text,x+1,y,1)
	print(text,x,y-1,1)
	print(text,x,y+1,1)
	print(text,x,y,c)
end


function height_function(mx,my)
	local y=shr(my,3) local x=shr(mx,3) local ix=band(x,127)local  ix1=ix+1 local iy=band(y,127) local iy1=iy+1
	local lmix = map[ix] local lmix1 = map[ix1]
	local ul = band(lmix[iy]    ,0xffff.0000) local ur = band(lmix1[iy]  ,0xffff.0000)
	local ll = band(lmix[iy1]  ,0xffff.0000) local lr = band(lmix1[iy1],0xffff.0000)
	local bul= shl(band(lmix[iy],0x0000.ffff),16) local bur= shl(band(lmix1[iy],0x0000.ffff),16)
	local bll= shl(band(lmix[iy1],0x0000.ffff),16) local blr= shl(band(lmix1[iy1],0x0000.ffff),16)
	local dx = band(x,0x0000.ffff) local  um=(ur-ul)*dx+ul local lm=(lr-ll)*dx+ll
	local dy = band(y,0x0000.ffff) local  bum=(bur-bul)*dx+bul local blm=(blr-bll)*dx+bll
	local brightness = band(0x00ff,(blm-bum)*dy+bum)
	return (lm-um)*dy+um, brightness
end

function render_land()
	local rsinphi = sin(phi)
	local rcosphi = cos(phi)
	local max_step=30
	local min_step=2.5
	local x_step=2
	local pix_width=x_step-1
	local max_distance = 250
	local fade_dist = 100
	local x_scale=x_step/128
	local tilt_delta=sin(tilt_angle)*x_step
	local l_color_ramp = color_ramp
	local screen_step=3
	
	for i=0,30 do
		z_table[i]={}
	end
	
	 local z = cam_y+5
	 local cycle=0
	 for i=0,127,2 do z_table[0][i]=128 end 
		z_table[0][128]=max_distance
	local temp_screen_step= shr(screen_step,3)
	local tilt_start=-tilt_delta*32
	local hy=90+tilt_start+pitch_slope*200
	
	rectfill(0,0,127,127,color_ramp[9][15])

	--nice sunset fill. Unhide if there is speed left
	for hx=0,127, 4 do
		for gy=0,10 do
			rectfill(hx,hy-12*gy,hx+3,hy-12*(gy+1),color_ramp[9][(14-gy)*3+4])
		end
	
		hy+=tilt_delta*2
	end
	while (z < max_distance)do
		cycle+=1
		if(z<50)then
			z_step = (screen_step*z*z/(screen_step*z+64*cam_y))
		else
		--if we would get an overflow then divide everything by 8 (shr 3) and then multiply the result by 8
			local temp_z = shr(z,3)
			z_step = (temp_screen_step*temp_z*temp_z/(temp_screen_step*temp_z+shr(64,3)*shr(cam_y,3)))
			z_step = shl(z_step,3)
		end
		local dz = max(z_step,min_step)
		 
		local pitch_delta=z*pitch_slope
		 
		local last_row=z_table[cycle-1]
		local cur_row=z_table[cycle]
		--code base started from:
		--see: https://github.com/s-macke/voxelspace
		--then I did strange things to it :-/
		local cosphiz=rcosphi*z
		local sinphiz=rsinphi*z
		local pleft_x = -cosphiz - sinphiz + cam_x
		local pleft_y = sinphiz - cosphiz + cam_z	
		local pright_x = cosphiz - sinphiz + cam_x
		local pright_y = -sinphiz - cosphiz + cam_z
		local dx = (pright_x - pleft_x) *x_scale
		local dy = (pright_y - pleft_y) *x_scale
		local tilt_start=-tilt_delta*64/x_step
		for i=0,127,2 do
			local qy=shr(pleft_y,3) local qx=shr(pleft_x,3) local ix=band(qx,127) local ix1=ix+1  local iy=band(qy,127) local iy1=iy+1
			local lmix = map[ix] local lmix1 = map[ix1]
			local ul = band(lmix[iy]    ,0xffff.0000) local ur = band(lmix1[iy]  ,0xffff.0000)
			local ll = band(lmix[iy1]  ,0xffff.0000) local lr = band(lmix1[iy1],0xffff.0000)
			local qdx = band(qx,0x0000.ffff) local um=(ur-ul)*qdx+ul local lm=(lr-ll)*qdx+ll
			local qdy = band(qy,0x0000.ffff)
			local hf =(lm-um)*qdy+um
			local height_on_screen = 64*(-hf + cam_y)/z + 70 + tilt_start + pitch_delta
			local last_max=last_row[i]

			if(height_on_screen<last_max)then
				
				local blmix = b_map[ix] local blmix1=b_map[ix1]
				local bul= blmix[iy] local bur= blmix1[iy]
				local bll= blmix[iy1]  local blr= blmix1[iy1]
				local bum=(bur-bul)*qdx+bul local blm=(blr-bll)*qdx+bll
				local color=11
				if(hf<14)color=4
				if(hf<3)color=12
				local brightness = flr((blm-bum)*qdy+bum)
				if(z>fade_dist)brightness*=1-.9*(z-fade_dist)/(max_distance-fade_dist) brightness=flr(brightness)
				rectfill(i,height_on_screen,i+pix_width,last_max,l_color_ramp[color][brightness])
			end
			cur_row[i]=min(height_on_screen,last_max)
			pleft_x+= dx
			pleft_y+= dy
			tilt_start+=tilt_delta
		end
		cur_row[128]=z
		z +=dz
	end
	cur_cycles=cycle
end
--hacked my trifill function to fill left to right 
--and to use the z-table for clipping with ground

function vert_trifill( y1,x1,y2,x2,y3,x3,tz, color_code)
		  local x1=band(x1,0xffff)
		  local x2=band(x2,0xffff)
		  local y1=band(y1,0xffff)
		  local y2=band(y2,0xffff)
		  local x3=band(x3,0xffff)
		  local y3=band(y3,0xffff)
		  local t,b
		  local nsx,nex
		  
		  local cycle=1
		  while(z_table[cycle][128]<tz and (cycle<cur_cycles))do
			cycle+=1
		  end
		 local slice=z_table[cycle-1]
		 local max_h
		  --sort y1,y2,y3
		  if(y1>y2)then
			y1,y2=y2,y1
			x1,x2=x2,x1
		  end
		  
		  if(y1>y3)then
			y1,y3=y3,y1
			x1,x3=x3,x1
		  end
		  
		  if(y2>y3)then
			y2,y3=y3,y2
			x2,x3=x3,x2		  
		  end
		  
		 if(y1!=y2)then 		 
			local delta_sx=(x3-x1)/(y3-y1)
			local delta_ex=(x2-x1)/(y2-y1)
			if(y1>0)then
				nsx=x1
				nex=x1
				min_y=y1
			else --top edge clip
				nsx=x1-delta_sx*y1
				nex=x1-delta_ex*y1
				min_y=0
			end
			max_y=min(y2,128)
			for y=min_y,max_y-1 do
				max_h=slice[flr(y/2)*2]
				t=min(nsx,nex)
				b=max(nsx,nex)
			if(t<max_h)rectfill(y,t,y,min(b,max_h),color_code)
			nsx+=delta_sx
			nex+=delta_ex
			end
    
		else --where top edge is horizontal
			nsx=x1
			nex=x2
		end
		if(y3!=y2)then
			local delta_sx=(x3-x1)/(y3-y1)
			local delta_ex=(x3-x2)/(y3-y2)
			min_y=y2
			max_y=min(y3,128)
			if(y2<0)then
				nex=x2-delta_ex*y2
				nsx=x1-delta_sx*y1
				min_y=0
			end
			if(nex<nsx)nex,nsx=nsx,nex delta_ex,delta_sx=delta_sx,delta_ex
			 for y=min_y,max_y do
    
				max_h=slice[flr(y/2)*2]
				if(nsx<max_h)rectfill(y,nsx,y,min(nex,max_h),color_code)
				nex+=delta_ex
				nsx+=delta_sx
			 end
		else --where bottom edge is horizontal
			max_h=slice[shl(band(shr(band(y3,0x007f),1),0x007f),1)]
			if(nsx<max_h)rectfill(y3,nsx,y3,min(nex,max_h),color_code)
		end
end
f=64



function check_all_triangle_intersect(cross_x,cross_y)
	for index,t in pairs(triangle_list) do
		if(check_triangle_intersect(t.p1x,t.p1y,t.p2x,t.p2y,t.p3x,t.p3y,cross_x,cross_y))return t.parent	
	end
	return false
end

function project_point(px,py,pz)
	px+=-cam_x
	pz+=-cam_z
	py+=-cam_y
	local mx =    -px*csinphi+pz*ccosphi
	local mz =     px*ccosphi+pz*csinphi
	--local tilt_delta=-sin(tilt_angle)
	if(mz>0)then
		local tilt_start=tilt_delta*64
		local sx = 64*mx/mz+64
		local sy = -64*py/mz+64
		sy=sy+tilt_start-tilt_delta*sx+mz*pitch_slope
		--pset(sx,sy,0x0088)
		return sx,sy,mz,60/mz
	end
	return false
end

	gray_patterns={	 0b0.1000000000000000,
					 0b0.1000000000100000,
					 0b0.1000000010100000,
					 0b0.1010000010100000,
					 0b0.1010010010100000,
					 0b0.1010010010100001,
					 0b0.1010010010100101,
					 0b0.1010010110100101,
					 0b0.1110010110100101,
					 0b0.1110010110110101,
					 0b0.1110010111110101,
					 0b0.1111010111110101,
					 0b0.1111010111110111,
					 0b0.1111110111110111,
					 0b0.1111110111111111,
					 0b0.1111111111111111}

pico_palette={
{0,0,0},
{.11,.17,.33},
{.49,.15,.33},
{0,.53,.32},
{.67,.32,.21},
{.37,.34,.31},
{.76,.76,.78},
{1,.95,.91},
{1,0,.3},
{1,.64,0},
{1,.93,.15},
{0,.89,.21},
{.16,.68,1},
{.51,.46,.61},
{1,.47,.66},
{1,.80,.67}
}


function init_color_ramp()
	color_ramp={}
	for i=1, #pico_palette do
		pico_palette[i][4]=(pico_palette[i][1]+pico_palette[i][2]+pico_palette[i][3])/3
	end
	shade_list={{0,1,1}          ,
				{0,1,1}           ,
				{0,1,2,2}         ,
				{0,1,3,11,7,7}     ,
				{0,1,2,4,9,7,7}     ,
				{0,1,5,6,7,7}       ,
				{0,1,5,13,6,7,7}    ,
				{0,1,5,13,6,7,7}  ,
				{0,1,2,8,14,14}   ,
				{0,1,2,4,9,7,7}     ,
				{0,1,2,4,9,10,7,7},
				{0,1,3,11,7,7}    ,
				{0,1,12,12}      ,
				{0,1,13,6,7,7}      ,
				{0,1,13,6,7,7}      ,
				{0,1,8,14,7,7}    ,
				{0,1,14,15,7,7}   }
	--shade_list={0,1,2,4,9,15,15}
	for c=0,15 do
			color_ramp[c]={}
		for n=0,127 do
			target_shade = n/128
			i=1
			local rr=pico_palette[shade_list[c+1][i]+1][4]
			while(rr<=target_shade and i<#shade_list[c+1])do
				i+=1
				rr=pico_palette[shade_list[c+1][i]+1][4]
			end
			local right_color=shade_list[c+1][i]
			local left_color=shade_list[c+1][i-1]
			local lr=pico_palette[left_color+1][4]
			local span=rr-lr
			local delta=target_shade-lr
			local bright= delta/span
			color = bor(0x1000,shl(right_color,4))
			color = bor(color,left_color)
			color_ramp[c][n] = bor(color,gray_patterns[ flr(bright*16)])
		end
	end
	
end
turn_speed=.0006
camera_speed=.13
camera_a=.15
k_friction=.97
turn_friction=.95
	ship_v=4
	cam_vx=0
	cam_vy=0
	cam_vz=0
	cam_vphi=0
	pitch_slope=0

	is_firing=false

	mouse_mode=false
function handle_buttons()
	is_firing=false
	
	if(btnp(4,1))then
		if(mouse_mode)then mouse_mode=false else mouse_mode=true end
	end
	if(mouse_mode)then
		mouse_x=stat(32)
		mouse_y=stat(33)
		
		cam_vphi+=(mouse_x-64)/64*turn_speed
		cam_vy+=(mouse_y-64)/64*.2
	end

	if(btn(0))cam_vphi+=-turn_speed 
	if(btn(1))cam_vphi+=turn_speed  
	cam_vphi*=turn_friction
	tilt_angle=cam_vphi*5
	phi+=cam_vphi
	cam_vx*=k_friction
	cam_vz*=k_friction
	cam_vy*=k_friction
	cam_nx=-sin(phi)
	cam_nz=-cos(phi)
	--cam_vy-=.03
	if(btn(4)) then
		if(missile_timer<=0 and missile_count>0)then
			missile_count-=1
			new_missile(cam_x-cam_nz*(missile_count-1.5)*10,cam_y-9,cam_z+cam_nx*(missile_count-1.5)*10,phi,5)

			missile_timer=missile_delay
			sfx(11,3)
		end
	end
	
	--for i=0,4 do
	--			new_particle(cam_x+cam_nz*(i-2.5)*10+cam_nx*20,cam_y,cam_z-cam_nx*(i-2.5)*10+cam_nz*20,0,0,0, 1, 0x0077,1)
	--end
	
	missile_timer-=1
	missile_timer=max(0,missile_timer)
	missile_count=mid(0,4,missile_count)
	
	if(cur_frame%240==0)missile_count+=1
	
	cam_vx+=cam_nx*camera_speed*.5 cam_vz+=cam_nz*camera_speed*.5
	

	if(btn(2))cam_vy+=-.15
	if(btn(3))cam_vy+=.15
	pitch_slope=cam_vy*.025
	local nh=height_function(cam_x+cam_nx*60,cam_z+cam_nz*60)
	local nd=(nh-cam_y+15)*.03
	if(cam_y<nh+30)cam_y=nh+30
	if(cam_y<0)cam_y=0
	if(cam_y>150)cam_y=150
	
	if(btn(5) or stat(34)>0)then
		
		hit = check_all_triangle_intersect(64+rnd(4)-2,64+rnd(4)-2)
		cam_x+=rnd(1)-.5
		cam_y+=rnd(1)-.5
		cam_z+=rnd(1)-.5
		--cam shake!!
		is_firing=true
		if(cur_frame%4==0)then
			if(hit) then 
				sfx(8,0,0,3)
			else
				sfx(7,0,0,3)
			end
		end
		if(hit and cur_frame%2==0)then		
			local cx=rand_dir()
			local cy=rand_dir()
			local cz=rand_dir()
			local c=flr(rnd(60)+30)
			new_particle(hit.x,hit.y,hit.z,  cx,cy,cz,5,color_ramp[7][c-15],10)
			new_particle(hit.x,hit.y+1,hit.z,  cx,cy,cz,3,color_ramp[7][c],10)
			hit.life-=1
		end
	end
	
	cam_x+=cam_vx
	cam_y+=cam_vy
	cam_z+=cam_vz
	
	if(cam_x<0)then cam_x+=1024 for enemy in all(enemy_list)do enemy.x+=1024 end end
	if(cam_x>=1024)then cam_x-=1024 for enemy in all(enemy_list)do enemy.x-=1024 end end
	if(cam_z<0)then cam_z+=1024 for enemy in all(enemy_list)do enemy.z+=1024 end end
	if(cam_z>=1024)then cam_z-=1024 for enemy in all(enemy_list)do enemy.z-=1024 end end
	
end
particle_list={}

function new_particle(x,y,z,vx,vy,vz,s,c,life)
	p={x=x,y=y,z=z,vx=vx,vy=vy,vz=vz,s=s,c=c,life=life}
	add(particle_list,p)
	return p
end

function draw_particles()
	for i,p in pairs(particle_list) do
		lx,ly,lz,ls = project_point(p.x,p.y,p.z)
		if(lx!=false) then
			local size=ls*p.s
			if(lx+size>0 and lx-size<127 and lz<150) then
			circfill(lx,ly,size,p.c)
			end
		end		
		p.x+=p.vx
		p.y+=p.vy
		p.z+=p.vz
		p.life-=1
		if(p.life==0)del(particle_list,p)
	end
end

function draw_sprite(px,py,w,h,x,y,z,scale)
	local lx
	local ly
	local ls
	lx,ly,lz,ls=project_point(x,y,z)
	if(not lx)return false
	if(lx<0 or lx>127)return false
	if(lz>200)return false
	ls*=scale
	local sw=flr(w*ls)
	local sh=flr(h*ls)
	local dpx=1/ls
	local sx=lx-flr(sw/2)
	local cycle=1
	while(z_table[cycle][128]<lz and (cycle<cur_cycles))do
		cycle+=1
	end
	local slice=z_table[cycle-1]
	local max_h=slice[flr(lx/2)*2]
	if(ly<max_h)sspr(px,py,w,h,sx,ly,sw,sh)
end
enemy_list={}
k_flier=1
k_copter=2
k_bomber=3
k_missile=4

lark_v="0001000fdf170601000f030cfa01000f030c0001059dfc080da6fe6d08dff255fe6d08e00da6fe9608dff255fe9608e0"
lark_f="m9020403060103050201mc010402030401md010203080301020701"

copter_base_v="ff11fcaaf7a2019efcaaf7a20558fcaa005efb58fcaa005eff1aff0af5c80196ff0af5c8026303c8005efe4c03c8005e0058001d0ae5015602f90ae5ff5902f90ae5"
copter_base_f="m904090b09030amc050807060703060507080504md010203050602080b0a05010403070a04030904010301050202060307080a08040bme090a0b"

copter_blade_v="00e60544018c0cf804f70064ff0f0460006400e60544ff3dffd30544ff3df3c104f70064ffd30544018c01aa04600064"
copter_blade_f="m7050607030605010802080402040102070603"

bomber_v="0000fde2f41f0527fde201d80000ff9006a2fad8fde201d8000001ee01d814000104037a15f3fd43013e1380feadf9b7110c0017013e15800223013eec000104037aeef30017013eec80feadf9b7ea0cfd43013eea800223013e0000fe1af1570423fe1afc4bfbdcfe1afc4b000001dcfc4b"
bomber_f="m60211130405130908010c04010401020209010d0c0102010801040d0c0d04080902050213120413m80304020f0d0e0a0809060a09070a06080a070205030305040b0f0e0c0f0b0d0f0c0b0e0c0c0e0d090807060907mc101311131012"

missile_v="00000000fb000000ff180362fee3000001bd011c000001bd000000e70362"
missile_f="m9030204050304mf010203010504010402030501"


function new_enemy(type,x,y,z)
	enemy={}
	
	
	if(type==k_flier)then
		enemy=load_obj(read_vector_string(lark_v),read_color_face_string(lark_f),x,y,z)
		enemy.type=k_flier
		enemy.speed=3
		enemy.turn_speed=.001
		enemy.dist=120
		enemy.turn_dir=10
		enemy.life=10
		enemy.score=5
	end
	
	if(type==k_missile)then
		enemy=load_obj(read_vector_string(missile_v),read_color_face_string(missile_f),x,y,z)
		enemy.type=k_missile
		enemy.dist=0
		enemy.turn_speed=.003
		enemy.speed=1.5
		enemy.turn_dir=0
		enemy.life=150
		enemy.score=0
	end
	
	if(type==k_bomber)then
		enemy=load_obj(read_vector_string(bomber_v),read_color_face_string(bomber_f),x,y,z)
		enemy.type=k_bomber
		enemy.speed=1
		enemy.turn_speed=.0005
		enemy.dist=180
		enemy.life=40
		enemy.turn_dir=15
		enemy.score=20
	end
	
	if(type==k_copter)then
		enemy=load_obj(read_vector_string(copter_base_v),read_color_face_string(copter_base_f),x,y,z)
		enemy.type=k_copter
		enemy.speed=1.5
		enemy.turn_speed=.0005
		enemy.dist=120
		enemy.turn_dir=10
		enemy.life=20
		enemy.blade={}
		enemy.blade=load_obj(read_vector_string(copter_blade_v),read_color_face_string(copter_blade_f),x,y,z)
		enemy.blade.life=200
		enemy.score=10
	end
	
	enemy.vx=0
	enemy.vy=0
	enemy.vz=0
	enemy.vax=0
	enemy.vay=0
	enemy.vaz=0
	
	
	add(enemy_list,enemy)
	return enemy
end

missile_list={}
function new_missile(x,y,z,ay,speed)
	missile=load_obj(read_vector_string(missile_v),read_color_face_string(missile_f),x,y,z)
	missile.ay=ay
	missile.vx=cam_nx*speed
	missile.vz=cam_nz*speed
	missile.life=30
	add(missile_list,missile)
	return missile
end

function update_missile()
	for index,missile in pairs(missile_list) do
		missile.x+=missile.vx
		missile.z+=missile.vz
		missile.life-=1
		
		reset_obj(missile)
		rotate_obj_y(missile,-missile.ay)
	
		if(missile.life<=0)then
			delete_object(missile)
		end
		
		for i,enemy in pairs(enemy_list)do
			local d=abs(enemy.x-missile.x)+abs(enemy.y-missile.y)+abs(enemy.z-missile.z)
			if(d<30)then
				--new_particle(enemy.x,enemy.y,enemy.z,0,0,0,2,0x0088,30)
				enemy.life-=21
				missile.life=0
				
				for i=1,10 do
					new_particle(missile.x,missile.y,missile.z,  rand_dir(),rand_dir(),rand_dir(),6,color_ramp[9][flr(rnd(60)+20)],10)
				end
			end
			
		end
	
	end
end


function update_enemies()
	
	for index ,enemy in pairs(enemy_list) do
		enemy.dx=-sin(enemy.ay)
	    enemy.dz=-cos(enemy.ay)
		local dist=abs(enemy.x-cam_x)+abs(enemy.z-cam_z)
		
		enemy.vx=enemy.dx*enemy.speed
	    enemy.vz=enemy.dz*enemy.speed
		
		if(enemy.type==k_missile)then
			enemy.vy=(-enemy.y+cam_y)*.05
		end
		
		if(enemy.y<height_function(enemy.x,enemy.z)+20)enemy.vy+=.1
		if(enemy.y>height_function(enemy.x,enemy.z)+60)enemy.vy+=-.1
		enemy.vy*=.98
		
		local turn_dir=isleft(0,0,enemy.vx,enemy.vz,shr(cam_x-enemy.x,3),shr(cam_z-enemy.z,3))
		
		
		if(dist>enemy.dist)then
			if(turn_dir<-enemy.turn_dir)then
				enemy.vay+=-enemy.turn_speed
			elseif(turn_dir>enemy.turn_dir)then
				enemy.vay+=enemy.turn_speed
			end
		else
			if(turn_dir<0)then
				enemy.vay+=enemy.turn_speed*1.5
			else
				enemy.vay+=-enemy.turn_speed*1.5
			end
		end
		enemy.vay*=.99
		enemy.vay=mid(enemy.vay,-.008,.008)
		enemy.ay+=enemy.vay
		enemy.x+=enemy.vx
		enemy.y+=enemy.vy
		enemy.z+=enemy.vz
		if(enemy.y>150)enemy.y=150 enemy.vy=0
		
		--if(enemy.x<0)enemy.x+=1028
		--if(enemy.x>=1028)enemy.x-=1028
		--if(enemy.z<0)enemy.z+=1028
		--if(enemy.z>=1028)enemy.z-=1028
		
		if(enemy.x-cam_x>600)  enemy.x-=1200
		if(enemy.x-cam_x<-600) enemy.x+=1200
		if(enemy.z-cam_z>600)  enemy.z-=1200
		if(enemy.z-cam_z<-600) enemy.z+=1200
		
		--enemy.z%=1028
		--enemy.x%=1028
		
		reset_obj(enemy)
		rotate_obj_x(enemy,enemy.vy*.05)
		rotate_obj_z(enemy,enemy.vay*10)
		rotate_obj_y(enemy,-enemy.ay)
		
		if(enemy.type==k_copter)then
			enemy.blade.x=enemy.x
			enemy.blade.y=enemy.y
			enemy.blade.z=enemy.z
			reset_obj(enemy.blade)
			rotate_obj_x(enemy.blade,enemy.vy*.05)
			rotate_obj_z(enemy.blade,enemy.vay*10)
			rotate_obj_y(enemy.blade,cur_frame/20)
			
			if(cur_frame%12==0 and ((cur_frame>200 or cur_frame<0)) )then
				if(abs(cam_x-enemy.x)+abs(cam_y-enemy.y)<100)then
					if(facing(enemy.x,enemy.z,enemy.dx,enemy.dz,cam_x,cam_z)<-.75)then
						new_particle(enemy.x+enemy.dx*10,enemy.y,enemy.z+enemy.dz*10,enemy.dx*3,0,enemy.dz*3,2,color_ramp[8][flr(rnd(60)+20)],30)
						is_hit=true
						player_health-=.5
						sfx(11,1)
					end
				end
			end
		end
		
		if(enemy.type==k_bomber and cur_frame%100==0)then
				m= new_enemy(k_missile,enemy.x,enemy.y,enemy.z)
				m.ay=enemy.ay
				m.vx=enemy.vx
				m.vz=enemy.vz
		end
		
		if(enemy.type==k_missile)then
			if(cur_frame%2==0)new_particle(enemy.x,enemy.y,enemy.z,  0,0,0,1,color_ramp[10][flr(rnd(60)+20)],10)
			enemy.life-=1
			
			if(abs(cam_x-enemy.x)+abs(cam_y-enemy.y)+abs(cam_z-enemy.z)<15)then
				enemy.life=-1
				for i=1,10 do
					new_particle(cam_x+cam_vx*8,cam_y,cam_z+cam_vz*8,  rand_dir(),rand_dir(),rand_dir(),4,color_ramp[9][flr(rnd(60)+20)],10)
				end
				is_hit=true
				player_health-=2
				sfx(10,2)
			end
			
		end
		
		if(enemy.life<=0)then
			for i=1,20 do
				new_particle(enemy.x,enemy.y,enemy.z,  rand_dir(),rand_dir(),rand_dir(),6,color_ramp[9][flr(rnd(60)+20)],10)
			end
			if(enemy.type!=k_missile)sfx(9,2)
			score+=enemy.score
			if(enemy.type==k_copter)delete_object(enemy.blade)
			
			del(enemy_list,enemy)
			delete_object(enemy)
		end
		
		
	end
	
	
end

function delete_object(object)
	object.faces={}
	object.vertices={}
	object.t_vertices={}
	object.t_normals={}
	del(obj_list,object)
end

billboard_list={}
function new_billboard(i,w,h,x,z)
	billboard={x=x,y=height_function(x,z)+2,z=z,i=i,w=w,h=h}
	add(billboard_list,billboard)
	return billboard
end

function draw_billboards()
	for index, p in pairs(billboard_list)do
		if(abs(p.x-cam_x)<200 and abs(p.z-cam_z)<200)then
		draw_sprite(p.i%16*8,flr(p.i/16)*8,p.w,p.h,p.x,p.y,p.z,1)
		end
	end
end



start_delay=0
function new_game()
	triangle_list={}
	init_map()
	obj_list={}
	enemy_list={}
	
	score=0
	phi=0
	cam_x=0
	cam_y=60
	cam_z=60
	tilt_angle=0
	pitch_angle=0
	max_player_health=20
	player_health=max_player_health
	missile_count=4
	missile_timer=0
	missile_delay=30
	cur_frame=0
	hit_timer=0
	hit_delay=4
	

	start_delay=60
	
	z_table={}

	for i=1,4 do
		gen_enemy()
	end

	for i=1,30 do
		placed=false
		while(not placed)do
			x=rnd(1024)
			y=rnd(1024)
			if(height_function(x,y)>10)placed=true
		end
		new_billboard(3,8,16,x,y)
	end
end

function gen_enemy()
	i=flr(rnd(5))
	if(i==0)new_enemy(k_copter,rnd(1024),40,rnd(1024))
	if(i==1)new_enemy(k_bomber,rnd(1024),40,rnd(1024))
	if(i==2)new_enemy(k_flier,rnd(1024),40,rnd(1024))
	if(i==3)new_enemy(k_flier,rnd(1024),40,rnd(1024))
	if(i==5)new_enemy(k_copter,rnd(1024),40,rnd(1024))
end


screen_map={}

function init_fire()
	for x=-1,64 do
		screen_map[x]={}
		for y=0,65 do
			screen_map[x][y]=0
		end
	end
	for x=-1,64 do screen_map[x][64]=rnd(128) end
end

function draw_fire()
	local lcolor_ramp=color_ramp[9]
	for x=-1+cur_frame%4,64,4 do screen_map[x][64]=rnd(200) end
	for x=0,63 do
			local x2=x*2
			local x2n=x2+1			
			local screen_mapx=screen_map[x]
			local screen_mapx1=screen_map[x+1]
			local screen_mapx2=screen_map[x-1]
		for y=0,63 do
			local y2=y*2+4
			v=(screen_mapx[y+2]+screen_mapx[y+1]+screen_mapx2[y+1]+screen_mapx1[y+1])*.240
			screen_mapx[y]=v
			rectfill(x2,y2,x2n,y2+1,lcolor_ramp[ flr(v) ])
		end
	end
end

function draw_title()
	cls()
	palt(0,false)
	palt(14,true)
	draw_fire()
	sspr(40,0,88,83,sin(cur_frame/300)*4+37,10+sin(cur_frame/160)*6)
	sspr(18,20,21,62,sin(cur_frame/300)*4+16,10+sin(cur_frame/160)*6+20)
	sspr(6,20,12,12,sin(cur_frame/300)*4+4,10+sin(cur_frame/160)*6+20)
	
	sspr(64,86,64,19,0,99)
	sspr(64,106,64,20,64,99)
	--print(stat(1),0,0,0x0077)
	if( flr(cur_frame/20)%2==0 )then
		print("'z' or 'x' to start",24,122,0x0011)
		print("'z' or 'x' to start",24,121,0x0077)
	end
	
	lx=cur_frame/2%300-64
	print("z: fire missile",lx,0,0x0077)
	print("x: fire mini gun",lx,8,0x0077)
	print("tab: mouse yoke",lx,16,0x0077)
end

function draw_hud()
		local cx=0
		local cy=0
		if(is_firing and cur_frame%4==0)cx+=rand_dir() cy+=rand_dir()
		
		--if(btn(4,1))is_hit=true-- player_health-=1

		
		if(is_hit)hit_timer=hit_delay
		hit_timer-=1
		hit_timer=max(0,hit_timer)
		
		if(hit_timer>0)then
			for i=cur_frame%2,127,2 do
				
				rectfill(0,i,127,i,color_ramp[9][flr(60+sin(cur_frame/10)*20)])
				
			end
			cx+=rand_dir() cy+=rnd(4)
		else

		end
		
		if(is_firing)then
			if(gl!=-20)then gl=-20 else gl=148 end
			
	
			for i=-20,148,168 do
				circfill(i+rnd(4),128,30,color_ramp[10][flr(60+sin(cur_frame/5)*10)])
				circfill(i+rnd(4),128,27,color_ramp[10][flr(80+sin(cur_frame/5)*10)])
				circfill(i+rnd(4),128,25,color_ramp[10][flr(100+sin(cur_frame/5)*10)])
				circfill(i+rnd(4),128,22,0x00aa)
				--circfill(148+rnd(4),128,30,color_ramp[10][flr(60+sin(cur_frame/5)*10)])
				--circfill(148+rnd(4),128,27,color_ramp[10][flr(80+sin(cur_frame/5)*10)])
				--circfill(148+rnd(4),128,25,color_ramp[10][flr(100+sin(cur_frame/5)*10)])
				--circfill(148+rnd(4),128,22,0x00aa)
			end
		end
		
		if(score>0)center_text(score.."000",64,2,0x0077)
		if(mouse_mode)print("mouse enabled",0,0,0x0077)line(2,mouse_y,6,mouse_y,0x0077)line(125,mouse_y,121,mouse_y,0x0077)line(mouse_x,50,mouse_x,54,0x0077)line(mouse_x,72,mouse_x,76,0x0077)
		sspr(0,59,18,69,0,60+cy)
		sspr(18,82,11,46,18,83+cy)
		sspr(29,96,35,32,29,97+cy)
		
		sspr(0,59,18,69,110,60+cy,18,69,true)
		sspr(18,82,11,46,99,83+cy,11,46,true)
		sspr(29,96,35,32,64,97+cy,35,32,true)
		
		for i=0,missile_count-1 do
			rectfill(i*3+33,115+cy,i*3+34,116+cy,0x0088)
		end
		--sset(shr(x,2),shr(y,2)+16,color_ramp[11][brightness])
		local ulx=(cam_x/32)
		local uly=(cam_z/32)
		
		clip(55,105+cy,18,18)

		
		
		
		
		sspr(0,16,32,32,55+ulx,105+uly+cy)
		sspr(0,16,32,32,55+ulx-32,105+uly+cy)
		sspr(0,16,32,32,55+ulx,105+uly-32+cy)
		sspr(0,16,32,32,55+ulx-32,105+uly-32+cy)
		
		line(64,104+cy,64,122+cy,0x00bb)
		line(55,113+cy,73,113+cy,0x00bb)
		
		clip()

		
		rectfill(83,107,96,118,0x0000)
		tot_bar=player_health/max_player_health*32
		n1=mid(0,8,tot_bar-24)
		n2=mid(0,8,tot_bar-16)
		n3=mid(0,8,tot_bar-8  )
		n4=mid(0,8,tot_bar  )
		
		rectfill(84,117+cy,85,117-n4+cy,0x0088)
		rectfill(87,117+cy,88,117-n3+cy,0x0088)
		rectfill(90,117+cy,91,117-n2+cy,0x0088)
		rectfill(93,117+cy,94,117-n1+cy,0x0088)
		
		
		spr(1,56+cx,56+cy,2,2)
		if(hit)circfill(64-cx,64-cx,1,0x0088)pset(64-cx,64-cx,0x00aa)
		
end


k_title=1
k_play=2
k_end=3
function _init()
	poke(0x5f2d, 1) --enable mouse
	poke(0x5f34, 1) -- set fill pattern mode
	init_color_ramp()

	rand_start=stat(85)
	init_fire()
	game_mode=k_title
	music(0)
end

function _update()
	if(game_mode==k_title)then

		if(start_delay<=0)then
			if(btnp(4)or btnp(5))then
				game_mode=k_play
				music(-1,30)
				new_game()
			end
		end
		start_delay-=1
		start_delay=max(0,start_delay)
	end
	if(game_mode==k_play)then
		is_hit=false
		handle_buttons()
		
		if(#enemy_list<3)then
			gen_enemy()
		end
		
		update_enemies()
		update_missile()
		update_3d()
		csinphi = sin(-phi+.25)
		ccosphi = cos(-phi+.25)
		tilt_delta=-sin(tilt_angle)
		
		if(is_hit)then
			cam_x+=rand_dir()
			cam_y+=rand_dir()
			cam_z+=rand_dir()
		end
		
		if(player_health<0)then
			new_particle(cam_x+rand_dir(),cam_y+rand_dir(),cam_z+rand_dir(),  rand_dir(),rand_dir(),rand_dir(),1,color_ramp[9][flr(rnd(60)+20)],15)
			player_health-=1
			cam_y-=.5
			phi+=.01
			cam_y=max(0,cam_y)
			
			if(player_health<-30)game_mode=k_title sfx(12,3) music(0,1800) reload(0,0,3136)
		end
	
	end
	
	
end
cur_frame=0

function _draw()
	cur_frame+=1
	if(game_mode==k_play)then
		
		cls(0)
		--clip(0,0,128,117)
		render_land()
		draw_3d()
		draw_particles()
		draw_billboards()
		--draw_mini_map()

		
		
		--if(is_hit)then
		--	rect(0,0,127,116,0x0082)
		--	sine_xshift(cur_frame,5,10,1,0,120,2)
		--end
		--clip()
		--ph=max(0,player_health)/20*127
		--rectfill(0,118,127,123,0x00cc)
		--rectfill(0,119,125,119,0x0077)
		--rectfill(0,118,ph,123,0x0088)
		--rectfill(0,119,ph,119,0x00ee)
		--rectfill(0,122,ph,122,0x0022)
		--rect(0,117,127,124,0x0011)
		
		draw_hud()
		
		--print(stat(1),0,0,7)
		--print(#obj_list,0,8,8)
		
	end
	
	if(game_mode==k_title)then
		draw_title()
	end
	
	
end
__gfx__
0123eeeeeeeeeeeeeeeeeeeeeeee3eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee1111eeeeeeeeeeeeeeeeeeeee
4567eeeeeeeeeeeeeeeeeeeeeee333eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee1115551eeeeeeeeeeeeeeeeeeee
89abeeeeeeeeeeeeeeeeeeeeeee313eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee111555511eeeeeeeeeeeeeeeeeeeee
cdefeeeeeeeeeeeeeeeeeeeeee33313eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee115555551eeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeee33333eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee1115555511eeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeee7eeee7eeeeeee33133eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee11155555511eeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeee7eeeeee7eeeee3313133eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee11555555111eee111111eeeeeeeeeeeeeeeeeeee
eeeeeeeee77e7eeeeee7e77ee1333333eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee111555551111001115555551eeeeeeeeeeeeeeeeeee
eeeeeeeeeeee7eeeeee7eeeee3131333eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee111555555110000055555511111eeeeeeeeeeeeeeeeeee
eeeeeeeeeeeee7eeee7eeeeee1313133eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee1155555511100055555555111eeeeeeeeeeeeeeeeeeeee11
eeeeeeeeeeeeeeeeeeeeeeee33131313eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee1115555111100055555551111eeeeeeeeeeeeeeeeeeee111167
eeeeeeeeeeeeeeeeeeeeeeeee1313131eeebeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee11555555000055555555111eeeeeeeeeeeeeeeeeeee1111767671
eeeeeeeeeeeeeeeeeeeeeeeeeee111eeeeebeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee11155555000555555551111eeeeeeeeeeeeeeeeeee1111676761111e
eeeeeeeeeeeeeeeeeeeeeeeeeee554eebeebeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee1115555550555555551111eeeeeeeeeeeeeeeeeee1111767671111eeeee
eeeeeeeeeeeeeeeeeeeeeeeeeee444eeebebebeeeeeeeeeeeeeeeeeeeeeeeeeee1111555555055555551111eeeeeeeeeeeeeeeeeee1111676761111eeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeee45544eebebebeeeeeeeeeeeeeeeee1111111111105555555555555111eeeeeeeeeeeeeeeeeeee111166666111eeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee115555555515555555555551111eeeeeeeeeeeeeeeeeee11116661676661eeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee11155555555555555555551111eeeeeeeeeeeeeeeeeee1111666661116776661eeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee1115555555555555000055111eeeeeeeeeeeeeeeeeee1111666661111ee16776661eeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee155555555555555550000111eeeeeeeeeeeeeeeeee1111666661111eeeeee167766661eeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee11111111555555555555555555551eeeeeeeeeeeeeeeeee0116661111eeeeeeeeeee1677666d1eeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeee111111111555555555000055555555555555551eeeeeeeeeeeeeeeeeee1111eeeeeeeeeeeeeee1677666dd1eeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeee11111111555555555555000000000055500000000000001eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee16776666d1eeeeeeeeeeee
eeeeeeeeeeeee11111111555555555555555550000000000000000000000000000011eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee1776666dd1eeeeeeeeeee
eeeeeeeeee1115555555555555555111000005555555500000000000066666666d6111eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee16776666d1eeeeeeeeeee
eeeeeee1115555555555111111111000055555551111110000000677777777777777d1eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee167766666d1eeeeeeeeee
eeeeee15555511111111eeeeeeeee55555555111eeeee10000677766666666666677dd1eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee167766666d1eeeeeeeeee
eeeeeee11111eeeeeeeee1111555555551111eeeeeeee11177766666666666666666dd1eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee166776666dd1eeeeeeeee
eeeeeeeeeeeeeeeeeeee1555555551111eeeeeeeeeeeee17667777777777777666666dddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee1667766666d1eeeeeeeee
eeeeeeeeeeeeeeeeee11555551111eeeeeeeeeeeeeeeee1777ddddddddddddd7766666ddd1eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee1677666666d1eeeeeeee
eeeeeeeeeeeeeeeee1555111eeeeeeeeeeeeeeeeeeeee1ddddd77777777777ddd766666d6d1eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee1677666666d1eeeeeeee
eeeeeeeeeeeeeeeee111eeeeeeeeeeeeeeeeeeeeeeee1dd6777666666667777ddd766666ddd1eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee1667766666d1eeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee111111111111111666777ddd766666d6d61eeeeeeeeeeeeeeeeeeeeeeeeeeeeeee1677666666d1eeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee11ccccccccccccc551666777ddd766666d6ddd1eeeeeeeeeeeeeeeeeeeeeeeeeeeee1677666666d1eeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee11cccc77777777555ccc1666777ddd76666666d6dd11eeeeeeeeeeeeeeeeeeeeeeeeee16777666d6d11eeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee1ccc7777777cc55cc77ccddd6677dddd76666666d6dddd1eeeeeeeeeeeeeeeeeeeeeee1dd66676d6d6dd1eeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee11cc7777ccccc55cccccccccd1d6777ddd76666666666dddd11eeeeeeeeeeeeeeeeeeee1dd6777776d666d1eeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee1ccc777cccc555cccccccccccc1d6677dddd76666666666d6ddd1eeeeeeeeeeeeeeeeee1dd67777d6dd557671eeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee155555555555cccccccccccccccc1d6777ddd766666666666d6ddd11eeeeeeeeeeeeeeee1d6777766d500057671eee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee1cc777ccccc5c55cccccccccccccc1d6677dddd76666666666666d6dd1eeeeeeeeeeeeee116677766dd0100055551ee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee1cc777cccccc5ccc55ccccccccccccc1d6677ddd766666666666666d6dd11eeeeeeeeeeee1d677766dd51010055551ee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee1c777cccccc5cccccc55ccccccccccc1d6677dddd766666666666666d6ddd1eeeeeeeeee1d6777766d510001055551ee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeee1cc77ccccccc5cccccccc5cccccccccd1d6677dddd7666666666666666d6ddd1eeeeeeeee1d67776d6d500000055551ee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeee1cc77ccccccc5cccccccccc55ccccccdcd1d677dddd7666666666666666666d6d11eeeeeee1d677766dd5000010055511e
eeeeeeeeeeeeeeeeeeeeeeeeeeeeee1c77ccccccc5ccccccccccccc5ccccccdc1d6677dd777777777777766666666d6d11eeeee1dd67776ddd5000001055511e
eeeeeeeeeeeeeeeeeeeeeeeeeeeee1c77cccccccc5ccccccccccccc5cccccdcd1d667777ddddddddddddd777776666dddd111111d6677766dd0000000055551e
eeeeeeeeeeeeeeeeeeeeeeeeeeeee1c77ccccccc5ccccccccccccccc5cccdcd1ddd677dd6666666666666ddddd77777dddd1dd666667766dd50000001055551e
eeeeeeeeeeeeeeeeeeeeeeeeeeeee1c7777777cc5cccccccccccccccc5cdcdc1dd667766666666666666666666ddddd77777766666677666d50000010055551e
eeeeeeeeeeeeeeeeeeeeeeeeeeee1cccccccccc5ccccccccccccccccc5dcdc00dd66776666666666666666666666666dddddd7777777766dd50000001055551e
eeeeeeeeeeeeeeeeeeeeeeeeeeee1c111111111ccccccccccccccccccd5d11650066776666666666666666666666666666666ddddd677666d50000010055651e
eeeeeeeeeeeeeeeeeeeeeeeeeeee1555666666611cccccccccccccccdc51666665006666666666666666666666666666666666666dd7766dd50000001055551e
eeeeeeeeeeeeeeeeeeeeeeeeeeee16666666666661cccccccccccdcdc11665666655066666666656565656565656566666666666666d6666d50000010055651e
eeeeeeeeeeeeeeeeeeeeeeeeeee1666666666666661cdcdcccdcdcdc1666666665650666656565656565656565656555555555555666d666d50000001055551e
eeeeeeeeeeeeeeeeeeeeeeeeee166666666666666661cdcdcdcdcd1166656666565650565656565555555555555555555555555555555566550000010055651e
eeeeeeeeeeeeeeeeeeeeeeeeee16555666666666655611dcdcdc116666666565656560656555555555500000000000000055555555555555550000001055651e
eeeeeeeeeeeeeeeeeeeeeeeee55dd7d7d66666665556661dc111666665665656565650555555500000055555555555555500000005555555550000010056651e
eeeeeeeeeeeeeeeeeeeeeeee167d7d7d75566666666666600666666566656565555505555000055555555555000000555555555550000055550000001056551e
eeeeeeeeeeeeeeeeeeeeeeee17d7d7d7ddd56666666666666066656666565555555505000555555550000000555000000000005555555500050000010056551e
eeeeeeeeeeeeeeeeeeeeeee17d7ddddddddd566666666666660666656565555500550055555555000050505000001010101010000055555555500010056551ee
0eeeeeeeeeeeeeeeeeeeee17d7dddddddddd566666666665666056565655550055505555555500505050500001010101010101010101010555510101056551ee
60eeeeeeeeeeeeeeeeeeeedd7dddddddddddd5666666566665606565555500550050555555005050505000101010101010101010101010101050101056551eee
660eeeeeeeeeeeeeeeeee1d7ddddddddddddd5666566665656560555555055005550555500505050500001010101010101010101010101010555000556551eee
6660eeeeeeeeeeeeeeeee17ddddddddddddddd56666565656565005550050055550555005050505050101010101010101010101010101010155555556551eeee
d660eeeeeeeeeeeeeeee10aaa0dddddddddddd56565656565550055005505555550500505050505050010101010101010101011101010101015555565551eeee
5d660eeeeeeeeeeeeeeeaa9a9aaddddddddddd056565655555550505500555555500505050505050001010101010101010111ee11010101010105555551eeeee
55d660eeeeeeeeeeeee1a9a9a9a0ddddddddd5d55655555555550550055555555000505050505050010101010101010111eeeeee155101010101555551eeeeee
55d6660eeeeeeeeeeee19a9a9a9adddddddd5d555555555555550505555555555050505050505050101010101011111eeeeeeeeee1555555555555551eeeeeee
555d660eeeeeeeeeeee1a9a9a9aa0dd5d5d5d5d5555555555550555555555555005050505050500101010101111eeeeeeeeeeeeeeee1111111111111eeeeeeee
5555d660eeeeeeeeee1a9a9a9a99ad5d5d5d5d55555555555550555555555550505050505050500010111111eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
55555d660eeeeeeeee19a9a9a9a945d5d5d5d5d55555555555505555555050005050505050500011111eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
55555d6660eeeeeeee1a9a9a99999d5d5d5d5d5555555555550555550505000505005051111111eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
555555d660eeeeeeeee19999999945d5d5d5d5555555555555055550505505551111111eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
5555555d660eeeeeeee1999999945d5d5d5d5d55555555555505050551111111eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
55555555d660eeeeeeee19494949d5d5d5d5d555555555555050505111eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
15555555d6660eeeeeee1494945d5d5d5d5d5555555555050505051eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
115555555d660eeeeeeeee1949d5d5d05050505555505050505051eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
0115555555d660eeeeeeeeeee1000000050505050505050505011eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e0115555555d660eeeeeeee1155500000050505050500055511eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
ee011555555d6660eeeee1155500000000050505050055111eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eee011555555d660eeee10050000110000005050501111eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeee011555555d660eee10605111ee111111111111eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeee011555555d660eee1111eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeee01155555d6660eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeee01155555d660eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeee01155555d660eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeee01155555d660eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeee0115555d6660eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7777777eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeee0115555d660eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee77ccccccc1eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeee0115555d660eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7ccccccccc1eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeee0115555d660eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7ccccc1111eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeee011555d6660eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7cccc11eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeee011555d6660eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7cccc1eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeee011555d660eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7cccc1eeeeeeeeeeeeeee7eeeeeeeeeeeeeeeeeeeeeeeeee7eeeeee
eeeeeeeeeeeeeeeee011555d660eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7cccc1eeeeee77777eee7c1ee77777777eeeeee777e77ee7c1ee777
eeeeeeeeeeeeeeeeee011555d660eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7cccc1eeeee77ccccc1ee7cc17cccccccc1eee77ccc1cc1e7cc1eccc
eeeeeeeeeeeeeeeeeee011555d660eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7cccc1eeee7cccccccc1ecccccccccccccc1e7cccccccc1ecccccccc
eeeeeeeeeeeeeeeeeeee011555d0000000000000000000000000000000000000eeeeeeee7777deeeeecccc1cccc1ecccc1cccc1cccc1ecccc1cccc1ecccc1ccc
eeeeeeeeeeeeeeeeeeeee011500dddddddddddddddddddddddddddddddddddddeeeeeeeeaaaa9eeeee777d0777d07777d07777d777dee777d0777d077777d777
eeeeeeeeeeeeeeeeeeeeee010666666666666666666666666666666666666666eeeeeee444445eeeeaaaa9aaaa90aaaa9aaaa99aaa9eaaaa9aaaa90aaaa90aaa
eeeeeeeeeeeeeeeeeeeeeee06666111111111111111111111111111111111111eeeeeee44445eeeee4445044450044445444454445ee44450444500444454445
eeeeeeeeeeeeeeeeeeeeee066611555555555555555555555555555555555555eeeeeee44445eeee44445444450444450444504445e444454444504444504445
eeeeeeeeeeeeeeeeeeeeee066155566666666666666666665555566666666666eeeeee44445eeeee444504444444444544445444444444504444444444544444
eeeeeeeeeeeeeeeeeeeee06661566ddddddddddddddddddd66556dddddddddddeeeeee44445eee4444444444444444504445e444444444444444444445e44444
eeeeeeeeeeeeeeeeeeeee066d556d5555555555555555555d6156d1111111111eeeeee144444445e14444444454444544445e44445ee44444444544445e44445
eeeeeeeeeeeeeeeeeeeee066d5065566666666666666666556156d1000000000eeeeeee1111111eee11111111e1111e1111ee1111eee11111111e1111ee1111e
eeeeeeeeeeeeeeeeeeeee066d50656ddddddddddddddddd156156d1000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeee066d50656dd1111111111111dd156156d1000000000eeeeeeeeeeeeeeee7777eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeee066d50656d100000000000006d156156d1000000000eeeeeeeeeeeeeee7cccc1eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeee066d50656d100bbbbbbbbb006d156156d1000000000eeeeeeeeeeeeeee7cccc1eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeee0666d50656d1000000b0000006d156156d1000000000eeeeeeeeeeeeee7cccc1eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeee066d550656d10000bbbbb00006d156156d1000000000eeeeeeeeeeeeee7cccc1eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeee0d66d500656d1000bb000bb0006d156156d1000000000eeeeeeeeeeeee7cccc1eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeee00d66d000656d1000b00000b0006d156156d1000000000eeeeeeeeeeeee7cccc1eeeeeeeeeeeeeeeeeeeeeeeeeeeeee77eeeeeeeeeeeee
eeeeeeeeeeeeeeeee0dd66d5050656d1000bbbbbbb0006d156156d1000000000eeeeeeeeeeeee7ccc1eeeeeeeeeeeeeeeeeeeeeeeeeeeeee7cc1eeeeeeeeeeee
eeeeeeeeeeeeee000d666dd5000656d10bb0bb0bb0bb06d156156d1000000000eeeee777777e7cccc1cc1eeee777777eeee777777eeeeee7cc1ee777777eeeee
eeeeeeeeeee000ddd6666d55050656d10bb0bb0bb0bb06d156156d10000000001eee7cccccc17cccccccc1ee7cccccc1ee7cccccc1eeee7cc1ee7cccccc1eeee
eeeeeeee000ddd666666dd55000656d100000000000006d156156d1000000000c1e7ccccccc7ccccccccc1e7ccccccc1eee7ccccc1eee7cc1eeeeeeecccc1eee
eeeee000ddd66666666dd5500e0656dd6666666666666dd156156d1000000000c1eccc1ccc17cccc0cccc1eccc1cccc1eeeeeccc1eeeecc1eeeeeeeecccc1eee
ee000ddd666677666ddd5510ee0656ddddddddddddddddd156156d1000000000d077777ddde7777d0777d07777d7777deeeee777deee77deeeeeeeecccc1eeee
00ddd6666776666ddd555110ee0656d661d661d661d661d156156d100000000090aaa99eeeeaaaa9aaaa90aaaaaaaa9eeeeeaaa9eeeaa9eeeeeee77777deeeee
dd6666777666dddd5555110eee0656d601d601d601d681d156156d1000000000044445eeeee44445444504444444445eeeee4445ee445eeeeeeeaaaa9eeeeeee
6667777666dddd55555110eeee0656d111d111d111d111d156156d1000000000044445eeee4444504445044445eeeeeeeee44445e445eeeeeee4445eeeeeeeee
77776666ddd5555555110eeeee0656ddddddddddddddddd156156d166666666644445eeeee444454444444445eeeeeeeeee4445e445eeeeeee4445eeeeeeeeee
776666ddd55555555110eeeeee065511111111111111111556156ddddddddddd44445eee444445e4444444445eee445eeee4445e11eeeeeeee4445eeeeeeeeee
666dddd555555555110eeeeeeee0655555555555555555555615511111111111e4444444544445e44445e444444455eeee44445eeeeeeeeeee44444445eeeeee
6dddd5555555555110eeeeeeeeee065111511151115111511111555555555555e1111111e1111ee1111ee1111111eeeeee1111eeeeeeeeeeee1111111eeeeeee
dd555555555555110eeeeeeeeeee0651dd51dd51dd51dd511555111111111111eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
d555555555555110eeeeeeeeeeee0651dd51dd51dd51dd511555555555555555eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
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
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
011000001b723040131b713035001b7130401302013062001b713050131b723035001b7132052320713207131b723040131b713035001b7130401302013062001b713050131b723035001b713205232271322713
011000001061528605286150360511605166051061502605106152861510605286151160516605106150260510615286052861503605116051660510615026051061528615106052861511605166051061502605
01100000051541d004031541c004001541f00412004120040515403154001541100411004110041100411004051541d004031541c004001541f00412004120040515403154001541100411004110041100411004
01100000071551f005051551e005021552100514005140050715505155021551300513005130051300513005071551f005051551e005021552100514005140050715505155021551300513005130051300513005
011000000f152270020d152260020a152290021c0021c0020f1520d1520a1521b0021b0021b0021b0021b0020f152270020d152260020a152290021c0021c0020f1520d1520a1521b0021b0021b0021b0021b002
0110000029731297312973129731247312473124731247312b7312b7312b7312b7312673126731267312673129731297312973129731247312473124731247312d7312d7312d7312d73129731297312973129731
0110000029722297222972229722247222472224722247222b7222b7222b7222b7222672226722267222672229722297222972229722247222472224722247222d7222d7222d7222d72229722297222972229722
010500000c7530c633114001140000000000000000000000112000000011100000000000011000110000000000000000001160000000000000000000000000000000011700167000000012700000001470000000
010500001976319633196001e4000d0000d0000d0000d0001e2000d0001e1000d0000d0001e0001e0000d0000d0000d0001e6000d0000d0000d0000d0000d0000d0001e700237000d0001f7000d000217000d000
010600000061100621006210062105631056310562105621096110961109611116110961111611000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0106000003631036310363103631086310863108631086310c6310c6310c621146210c61114611146110300003000030000300003000030000300003000030000300003000030000300003000030000300003000
010200000061100611006110061100611006110061100611006111061110611106110461104611046110020100201002010020100201002010020100201002010020100201002010020100201002010020100201
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
00 00 42 43 44
00 00 01 43 44
01 00 01 02 44
00 00 01 03 44
00 00 01 02 44
00 00 01 03 44
00 00 01 05 44
02 00 01 06 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
