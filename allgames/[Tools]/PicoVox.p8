pico-8 cartridge // http://www.pico-8.com
version 30
__lua__

build_version = "A2"

function build_num_table(s,zero)
	local t,offset={},0
	if(zero)offset=-1
	for i,row_string in pairs(split(s,"|",false)) do
		t[i+offset]=split(row_string,",",true)
	end
	return t
end

-------------------------rgb system

bayer=build_num_table([[
0,32,8,40,2,34,10,42|
48,16,56,24,50,18,58,26|
12,44,4,36,14,46,6,38|
60,28,52,20,62,30,54,22|
3,35,11,43,1,33,9,41|
51,19,59,27,49,17,57,25|
15,47,7,39,13,45,5,37|
63,31,55,23,61,29,53,21
]])


pico_palette=build_num_table([[
0x.00,0x.00,0x.00|
0x.1d,0x.2b,0x.53|
0x.7e,0x.25,0x.53|
0x.00,0x.87,0x.51|
0x.ab,0x.52,0x.36|
0x.5f,0x.57,0x.4f|
0x.c2,0x.c3,0x.c7|
0x.ff,0x.f1,0x.e8|
0x.ff,0x.00,0x.4d|
0x.ff,0x.a3,0x.00|
0x.ff,0x.ec,0x.27|
0x.00,0x.e4,0x.36|
0x.29,0x.ad,0x.ff|
0x.83,0x.76,0x.9c|
0x.ff,0x.77,0x.a8|
0x.ff,0x.cc,0x.aa
]],true)




function get_ordered_pixel(x,y,c)

	local closest_i,dist=0,100
	local k_offset= shr(bayer[x%8+1][y%8+1],7)-.55 -- ordered dither array with an offset
	
	local red_target,green_target,blue_target =	 	mid(sqrt(c[1]+k_offset)*1.27 ,0,1),mid(sqrt(c[2]+k_offset)*1.27 ,0,1), mid(sqrt(c[3]+k_offset)*1.27 ,0,1)
	for i, palette_color in pairs(pico_palette) do
		local d = color_compare({red_target,green_target,blue_target},palette_color)
		if(d<dist)then closest_i=i dist=d end
	end
	return closest_i
end

function color_compare(rgb1,rgb2)

	local luma1,luma2 = rgb1[1]*.299+rgb1[2]*.587+rgb1[3]*.114, rgb2[1]*.299+rgb2[2]*.587+rgb2[3]*.114
	local lumadiff=luma1-luma2
	local diff = vec3_sub(rgb1,rgb2)
	return (diff[1]*diff[1]*0.299 + diff[2]*diff[2]*.587 + diff[3]*diff[3]*.114)*.75+lumadiff*lumadiff*.25
end	

cur_error_row={}
next_error_row={}
for i=-1,128 do cur_error_row[i]={0,0,0} next_error_row[i]={0,0,0} end

function correct_gamma(c)
	return {mid(sqrt(c[1]) ,0,1),mid(sqrt(c[2]) ,0,1), mid(sqrt(c[3]) ,0,1)}
end

function get_fs_pixel(x,y,c)
	y=flr(y)
	local dir=1
	local start=0
	--if(x%2==0)dir=-1 start=127
	

	--c=vec3_add(c,cur_error_row[x])
	
	local closest_i,dist=0,100
	local target =	correct_gamma(vec3_add(c,cur_error_row[y]))-- 	correct_gamma(c)
	for i, palette_color in pairs(pico_palette) do
		local d = color_compare(target,correct_gamma(palette_color))--color_compare(target,palette_color)
		if(d<dist)then closest_i=i dist=d end
	end
	
	local error=vec3_sub(target,pico_palette[closest_i])
	cur_error_row[y+dir] = vec3_add(  cur_error_row[y+dir]    ,vec3_scale(error,7/15))
	next_error_row[y-dir]=vec3_add(   next_error_row[y-dir]   ,vec3_scale(error,3/15))
	next_error_row[y]  =  vec3_add( next_error_row[y]     ,vec3_scale(error,5/15))
	next_error_row[y+dir]=vec3_add(   next_error_row[y+dir]   ,vec3_scale(error,1/15))
	--
	if(y==127)then
		cur_error_row,next_error_row=next_error_row,cur_error_row
		for i=-1,128 do next_error_row[i]={0,0,0} end
	end
	return closest_i
end

function get_closest_pixel(x,y,c)
	local closest_i,dist=0,100
	for i, palette_color in pairs(pico_palette) do
		local d = color_compare(c,palette_color)
		if(d<dist)then closest_i=i dist=d end
	end
	return closest_i
end

 --get_ordered_pixel = get_closest_pixel
 
--------------------------misc utility
function normalize(x,y,z)
	local length=1/sqrt(x*x+y*y+z*z)
	return x*length,y*length,z*length
end


function vec3_dot(a,b)
	return a[1]*b[1]+a[2]*b[2]+a[3]*b[3]
end

function vec3_unit(v)
	local x1,y1,z1=v[1],v[2],v[3]
	local inv_dist=1/sqrt(x1*x1+y1*y1+z1*z1)
	return {x1*inv_dist,y1*inv_dist,z1*inv_dist}
end

function vec3_length(v)
	local x1=shr(v[1],2)
	local y1=shr(v[2],2)
	local z1=shr(v[3],2)
	return sqrt(x1*x1+y1*y1+z1*z1)
end

--function vec3_abs(v)
--	return {abs(v[1]),abs(v[2]),abs(v[3])}
--end
--
--function vec3_max(v,d)
--	return {max(v[1],d),max(v[2],d),max(v[3],3)}
--
--end
--
--function vec3_flr(a)
--	return {flr(a[1]),flr(a[2]),flr(a[3])}
--end

--function vec3_flip(a)
--	return {-a[1],-a[2],-a[3]}
--end

function vec3_sub(a,b)
	return {a[1]-b[1],a[2]-b[2],a[3]-b[3]}
end
function vec3_add(a,b)
	return {a[1]+b[1],a[2]+b[2],a[3]+b[3]}
end
function vec3_scale(a,s)
	return {a[1]*s,a[2]*s,a[3]*s}
end

function vec3_div(a,s)
	return {a[1]/s,a[2]/s,a[3]/s}
end

function vec3_mult(a,b)
	return {a[1]*b[1],a[2]*b[2],a[3]*b[3]}
end


function pause(t)
	for i=1,t do
		flip()
	end
end

function freeze()
	while(true) do flip() end
end

function center_print(s,x,y,c)
	s=s..""
	print(s,x-#s*2,y,c)
end

function right_print(s,x,y,c)
	s=s..""
	print(s,x-#s*4,y,c)
end

function vertical_print(s,x,y,c)
	s=s.."" -- force a number to a string
	while(#s>=1)do
		local the_char=sub(s,1,1)
		s=sub(s,2)
		print(the_char,x,y,c)
		y+=6
	end
	
end

----------------------------------matrix functions----------------------


function create_identity()
	--return{{1,0,0},{0,1,0},{0,0,1}}
	return build_num_table[[1,0,0|0,1,0|0,0,1]]
end




function create_x_rotate(a)
	return{{1,0,0},
		   {0,cos(a),-sin(a)},
		   {0,sin(a),cos(a)},
		   }
end

function create_y_rotate(a)
	return{{cos(a),0,sin(a)},
	       {0,1,0},
		   {-sin(a),0,cos(a)},
   
		   }
end

function create_z_rotate(a)
	return{{cos(a),-sin(a),0},
		   {sin(a),cos(a),0},
		   {0,0,1}}
end


function matrix_multiply(src1,src2)

	local new_m={{},{},{}}
	for i=1,3 do
		for j=1,3 do
			local sum=0
			for k=1,3 do
				sum+=src1[i][k]*src2[k][j]
			end
			new_m[i][j]=sum
		end
	end
	return new_m

end

function transform_vector(v,m)

	--trasnform vector is used pretty often, so don't shave tokens
	return (v[1]*m[1][1]+v[2]*m[2][1]+v[3]*m[3][1]),
		   (v[1]*m[1][2]+v[2]*m[2][2]+v[3]*m[3][2]),
		   (v[1]*m[1][3]+v[2]*m[2][3]+v[3]*m[3][3])

end

function vec3_transform(v,m)
	--some functions like the vector in matrix form...
	
	return {(v[1]*m[1][1]+v[2]*m[2][1]+v[3]*m[3][1]),
		   (v[1]*m[1][2]+v[2]*m[2][2]+v[3]*m[3][2] ),
		   (v[1]*m[1][3]+v[2]*m[2][3]+v[3]*m[3][3] )}
end

dat= split("2,2,3,3,3,2,2,3,1,3,3,2,1,2,3,3,1,2,2,3,1,3,2,2,2,3,3,1,2,1,3,3,1,1,3,3,1,3,3,1,2,1,1,3,1,1,2,3,2,1,3,2,3,1,2,2,3,1,1,2,1,1,3,2,1,1,2,2,2,1,1,2")
function inverse_matrix(m)
	--I'm not feeling clever enough to reduce the token count here.
	

	local invdet = 1/(m[1][ 1] * (m[2][ 2] * m[3][ 3] - m[3][ 2] * m[2][ 3]) -
					  m[1][ 2] * (m[2][ 1] * m[3][ 3] - m[2][ 3] * m[3][ 1]) +
				      m[1][ 3] * (m[2][ 1] * m[3][ 2] - m[2][ 2] * m[3][ 1]))
	
	
	local k=1
	local new_m={{},{},{}}
	for i=1,3 do
		for j=1,3 do
			new_m[i][j]=(m[ dat[k] ][dat[k+1]]*m[ dat[k+2] ][dat[k+3]]-m[ dat[k+4] ][dat[k+5]]*m[ dat[k+6] ][dat[k+7]])*invdet
			k+=8
		end
	end
	return new_m

end

----------------------------------raymarching functions---------------------

k_direction_light=1
k_point_light=2
k_ambient_light=2
light_type=k_point_light


light_list={}
function new_light(light_type,x,y,z,rgb)
	if(light_type==k_direction_light) x,y,z=normalize(x,y,z)
	if(light_type==k_ambient_light)rgb=x

	return add(light_list,{light_type=light_type,x=x,y=y,z=z,rgb=rgb})
end

function update_light(light)
	light.x,light.y,light.z=normalize(light.x,light.y,light.z)
end

---------------------------------------------------------------------------------

function mix(d1,d2,h)
	return(d1*(1-h)+d2*h)
end


function update_camera()
	if(cam_zoom>.25)cam_zoom=.25
	
	cam_matrix=matrix_multiply(create_x_rotate(cam_ax),create_y_rotate(cam_ay))

	cam_h = vec3_transform({1,0,0},cam_matrix)
	cam_v = vec3_transform({0,1,0},cam_matrix)
	cam_d = vec3_transform({0,0,1},cam_matrix)
	

end

function init_scene()

	cam_x=0
	cam_y=0
	cam_z=0
	k_cam_height=30
	cam_ax=-30/360--30/360
	cam_ay=-.125
	cam_az=0
	cam_target={k_width/2,k_height-2,k_depth/2}
	cam_zoom=1/8
	update_camera()
	draw_cube() -- need to do this before we can use the nice draw function
	--spot=new_light(k_direction_light,.2,-1,-.75,{1,1,1})
	light_x,light_y,light_z=normalize(.2,-1,-.75)
	 init_vox_scene()
end


k_width = 16
k_height = 16
k_depth = 16
function init_vox_scene()

	vox_scene={}
	for i=0,k_width-1 do
		vox_scene[i]={}
		for j=0,k_height-1 do
			vox_scene[i][j]={}
			for k=0,k_depth-1 do
				local d1=i-k_width/2
				local d2=j-k_height/2
				local d3=k-k_depth/2
	
				vox_scene[i][j][k]=0
				
				--if( sqrt(d1*d1+d2*d2+d3*d3)<6) vox_scene[i][j][k]= 12

			    if(j==k_height-1)vox_scene[i][j][k]=7
			end
		end
	end



	--save_scene()

end

function clear_vox()
	vox_scene={}
	for i=0,k_width-1 do
		vox_scene[i]={}
		for j=0,k_height-1 do
			vox_scene[i][j]={}
			for k=0,k_depth-1 do
				vox_scene[i][j][k]=0
			end
		end
	end
end

code_string="in the beginning the universe was created. this has made a lot of people very angry and been widely regarded as a bad move"

function save_scene()
	local temp_zoom=cam_zoom
	
	flip()
	cls(0)
	print("pICOvOX "..build_version,1,120,7)
	right_print("eLECTRIC gRYPHON",127,120,7)
	--print("vERSION",1,80,7)
	--center_print(build_version,15,88,7)
	--
	--
	--vertical_print("eLECTRIC",106,40,7)
	--vertical_print("gRYPHON",114,43,7)

	
	--cam_zoom*=.5
	--update_camera()
	--iso_render(31,32,31+64,31+64)
	--rect(31,32,31+64,31+64,7)
	--
	--flip()
--	--freeze()
	--cam_zoom=temp_zoom
	
	
	--freeze()
	local v=0
	local mem_loc=0x6000
	
	poke(mem_loc,k_width)	mem_loc+=1
	poke(mem_loc,k_height)	mem_loc+=1
	poke(mem_loc,k_depth)	mem_loc+=1
	
	
	local count=0
	for k=0,k_depth-1 do
		for j=0,k_height-1 do
			for i=0,k_width-1 do
				v=vox_scene[i][j][k]
				v+=ord(sub(code_string,count%(#code_string)+1,count%(#code_string)+1))
				v=v%128
				--v=v+flr(rnd(128))
				--v=v%256
					--if(rnd(2)>1)v+=127
				poke(mem_loc,v)
				mem_loc+=1
				--if(mem_loc==0x6000+2048) mem_loc+=4096
				count+=1
			end
		end
	end
	extcmd("screen",1) 
	--freeze()
end


k_user_mem_loc = 0x4300
function check_import()
	local c=0
	local count=0
	srand(12)

	if( stat(121) ) then
		local img_width=read_serial_byte(true)
		local img_height=read_serial_byte(true)
		
		--cls()
		--print(img_width )
		--print(img_height)
		
		local x=0
		local y=0
		local z=0
		
		flip()
		for j=0,127 do
			for i=0,127 do			
				local v=read_serial_byte()
				pset(i,j,v)
			end
		end
		mem_loc=0x6000
		
		k_width =peek(mem_loc)	mem_loc+=1
		k_height = peek(mem_loc)	mem_loc+=1
		k_depth = peek(mem_loc)	mem_loc+=1
		
		for k=0,k_depth-1 do
			for j=0,k_height-1 do
				for i=0,k_width-1 do
				
					--if(rnd(2)>1)v+=127
				v=peek(mem_loc)
				v-=ord(sub(code_string,count%(#code_string)+1,count%(#code_string)+1))
				v=v%128
				--v=v-flr(rnd(128))
				--v=v%256
				vox_scene[i][j][k]=v
				mem_loc+=1
				--if(mem_loc==0x6000+2048) mem_loc+=4096
				count+=1
				end
			end
		end
		
		
		
		clear_serial()
		needs_redraw=true
		
		
	end
	
end

--trashes first 1-2 bytes of user memory area
function read_serial_byte(word)
	--if(not stat(121)) return false
	if(word!=nil)then
		serial(0x802, k_user_mem_loc, 2)
		return peek2(k_user_mem_loc)
	else
		serial(0x802, k_user_mem_loc, 1)
		return peek(k_user_mem_loc)		
	end
end

function clear_serial()
	while(stat(121))do
		 read_serial_byte()
	end
end

------------------------------------------




function vox_dda(px,py,pz,vx,vy,vz,max_depth)


	--for i=0,10 do
	--	for j=0,10 do
	--		rect(i*16,j*16,(i+1)*16,(j+1)*16,3)
	--		
	--	end
	--end
	
	

	local dir_x=1
	local dir_y=1
	local dir_z=1
	local itx,ity,itz
	if(vx<0)then  itx = band(px,0x.ffff)/abs(vx) dir_x=-1 else itx = (1-band(px,0x.ffff))/abs(vx) end
	if(vy<0)then  ity = band(py,0x.ffff)/abs(vy) dir_y=-1 else ity = (1-band(py,0x.ffff))/abs(vy) end
	if(vz<0)then  itz = band(pz,0x.ffff)/abs(vz) dir_z=-1 else itz = (1-band(pz,0x.ffff))/abs(vz) end

	
	local stx = 1/abs(vx)
	local sty = 1/abs(vy)
	local stz = 1/abs(vz)
	local tx=itx
	local ty=ity
	local tz=itz
	
	local cell_x=flr(px)
	local cell_y=flr(py)
	local cell_z=flr(pz)
	
	local cur_cell=0
	if(cell_x>=0 and cell_y>=0 and cell_z>=0 and cell_x<k_width and cell_y<k_height and cell_z<k_depth)then
	 cur_cell=vox_scene[cell_x][cell_y][cell_z]
	end

	
	local max_depth=max_depth or 80
	local done=false
	local depth=0
	
	local hit=false
	
	local side=1
	

	
	--rect(cell_x*16+1,cell_y*16+1,(cell_x+1)*16-1,(cell_y+1)*16-1,11)
	--		line(px*16,py*16,(px+vx*10)*16,(py+vy*10)*16,12)
	 
	
	--local sx=abs(vy/vx )
	--local sy=abs(vx/vy )
	--
	--step_x=0
	--step_y=0
	
		local n
		local t=0
	
	while(not done)do
		--rect(cell_x*16+1,cell_y*16+1,(cell_x+1)*16-1,(cell_y+1)*16-1,11)
		

		
		if(tx<ty)then
		
			if(tx<tz)then
				tx+=stx
				side=1
				cell_x+=dir_x
			else
				tz+=stz
				side=2
				cell_z+=dir_z
			end

			
		else
			
			if(ty<tz)then
				ty+=sty
				side=3
				cell_y+=dir_y
			else
				tz+=stz
				cell_z+=dir_z
				side=2
			end

			
		end
		
		
		
		if(cell_x>=0 and cell_y>=0 and cell_z>=0 and cell_x<k_width and cell_y<k_height and cell_z<k_depth)then
		local v=vox_scene[cell_x][cell_y][cell_z]
		if(v!=0 and v!=cur_cell)then
			--rect(cell_x*16+1,cell_y*16+1,(cell_x+1)*16-1,(cell_y+1)*16-1,8)
			--tx-=stx --go back to the previous intersection point
			--ty-=sty --go back to the previous intersection point
			--tz-=stz --go back to the previous intersection point
			
			
			
			
			if(side==1)then
				t=tx-stx
				if(vx<0) then
					n={1,0,0}
				else
					n={-1,0,0}
				end
			
			elseif(side==2)then
				t=tz-stz
				if(vz<0) then
					n={0,0,1}
				else
					n={0,0,-1}
				end
			elseif(side==3)then
				t=ty-sty
				if(vy<0) then
					n={0,1,0}
						else
					n={0,-1,0}
				end
			end
			
			return v,n,{px+t*vx,py+t*vy,pz+t*vz},t
			
			end
		end
	
		
	
		depth+=1
		if(depth>=max_depth)return false,n,{px+t*vx,py+t*vy,pz+t*vz},t
	end
	

	
	
end

--init_vox_scene()
--function test_dda()
--	
--	
--	
--	
--
--	
--	local a=-.05
--	
--	while(true)do
--	a+=.01
--	cls()
--	local vx=cos(a)
--	local vy=sin(a)
--	
--	vox_dda(4.5,4.9,0,vx,vy,0)
--	flip()
--	end
--	freeze()
--	
--end
--test_dda()



k_ambient=.4
function iso_render(start_x,start_y,end_x,end_y)
	skip_step=1
	
	local start_x=start_x or 0
	local start_y=start_y or 0
	local end_x=end_x or 127
	local end_y=end_y or 127
	
	
	--flip()
	local cam_matrix=matrix_multiply(create_x_rotate(cam_ax),create_y_rotate(cam_ay))
	local cam_h = vec3_transform({1,0,0},cam_matrix)
	local cam_v = vec3_transform({0,1,0},cam_matrix)
	local cam_d = vec3_transform({0,0,1},cam_matrix)	
	local cam_location=vec3_add(cam_target,vec3_scale(cam_d,-k_cam_height))
	
	

	local px,py,pz

	local depth
	local skip_step=skip_step
	local step1=skip_step-1
	local px,py,pz
	
	local v=0
	local nx,ny,nz
	for sx=start_x,end_x,skip_step do
		local v_h=vec3_scale(cam_h,shr(sx-64,6)/cam_zoom)
		for sy=start_y,end_y,skip_step do
			local v_v=vec3_scale(cam_v,shr(sy-64,6)/cam_zoom)
			local ray_start=vec3_add(cam_location,vec3_add(v_h,v_v))
			--local rgb,depth,px,py,pz = trace_ray(ray_start[1],ray_start[2],ray_start[3],cam_d[1],cam_d[2],cam_d[3])
			
			local rgb=trace_ray(ray_start,cam_d)
			local c = get_ordered_pixel(sx,sy,rgb)
						--
			pset(sx,sy,c)
		end
		if(stat(34)!=0 ) return false
	end
end


function vec3_lerp(v1,v2,a)
	local b=1-a
	return{v1[1]*a+v2[1]*b,v1[2]*a+v2[2]*b,v1[3]*a+v2[3]*b}
end


k_mirror_amount=.75
k_transparent_amount=.5
k_ambient=.4

function trace_ray(ray_start,ray_v,last_v)
	local v,n,p=vox_dda(ray_start[1],ray_start[2],ray_start[3],ray_v[1],ray_v[2],ray_v[3])
	
			--pset(sx,sy,12)
		
			if(v!=false)then
			
				local transparent=false
				if(v>15 and v<=32)transparent=true v=v%16
				
				local mirror=false
				local bright=false
				if(v>32 and v<=48)mirror=true v=v%16
				if(v>48)bright=true v=v%16
				
				
				local rgb_bright={0,0,0}
			--	pset(sx,sy,v)
				--rectfill(sx,sy,sx+step1,sy+step1,v)--pset(sx,sy,v)
				
				
		
				local 	light_vx,light_vy,light_vz=light_x,light_y,light_z
				--local diffuse = mid(nx*light_vx+ny*light_vy+nz*light_vz,0,1)*.8+.2
				--local diffuse = mid(vec3_dot({light_vx,light_vy,light_vz},n),0,1)
				local diffuse = (vec3_dot({light_vx,light_vy,light_vz},n)*.5+.5)^2 -- half lambert diffuse
		
				local half_dir = vec3_unit(vec3_add({-light_vx,-light_vy,-light_vz},cam_d))
				local specular = mid(0,1,-vec3_dot(half_dir,n))^4
				

				shadow=trace_shadow({p[1]+n[1]*.01,p[2]+n[2]*.01,p[3]+n[3]*.01},{light_vx,light_vy,light_vz})
				--shadow=vec3_lerp(shadow,{1,1,1},.5)
				if(mirror)shadow=vec3_lerp({1,1,1},shadow,k_mirror_amount)

				
				local material_color=pico_palette[v]
				
				rgb_bright=vec3_mult(vec3_scale(shadow,diffuse),material_color)
				rgb_bright=vec3_lerp(material_color,rgb_bright,k_ambient)
				
				
				local occlusion,glow = find_ambient_occlusion(p,n)
				
				rgb_bright=vec3_scale(rgb_bright,occlusion^.25*.5+.5)
				
				rgb_bright=vec3_add(rgb_bright,vec3_scale(glow,.2))
				
				
				if(bright) rgb_bright= vec3_lerp({pico_palette[v][1],pico_palette[v][2],pico_palette[v][3]},rgb_bright,.75)
				
				if(transparent)then
			
					local next_step_rgb = trace_ray({p[1]+ray_v[1]*.01,p[2]+ray_v[2]*.01,p[3]+ray_v[3]*.01},ray_v)
					next_step_rgb = vec3_mult(next_step_rgb,{pico_palette[v][1],pico_palette[v][2],pico_palette[v][3]})
					 next_step_rgb = vec3_scale(next_step_rgb,k_transparent_amount)
					local cur_step_rgb = vec3_scale(rgb_bright,k_transparent_amount)
					
					return vec3_add(cur_step_rgb,next_step_rgb)
				elseif(mirror)then
					local reflect = vec3_sub(ray_v,vec3_scale(n, 2*vec3_dot(n,ray_v)))
					local next_step_rgb = trace_ray({p[1]+reflect[1]*.01,p[2]+reflect[2]*.01,p[3]+reflect[3]*.01},reflect)
					next_step_rgb =  vec3_mult( rgb_bright,next_step_rgb)
					return vec3_lerp(next_step_rgb,rgb_bright,k_mirror_amount)
				else
				
				
					return rgb_bright
				end
						--c = get_ordered_pixel(sx,sy,rgb_bright)
						--
						--pset(sx,sy,c)
						
				
				
				 
				
			else -- no inteserction
				--local b = abs(vec3_dot(ray_v,vec3_unit(ray_start)))
				
				local b = get_sky_color(ray_start,vec3_scale(ray_v,-1))
				return {b,b,b}
		
				
			end
	end

--https://gamedev.stackexchange.com/questions/96459/fast-ray-sphere-collision-code
--heavily modified sphere intersect
function get_sky_color(p, d) 
	local m = vec3_sub(p,cam_target)
	local b= vec3_dot(m,d)
	local c = vec3_dot(m,m) - 2500
	local n = vec3_unit(vec3_sub(vec3_add(p, vec3_scale(d,-b - sqrt(b*b - c))),cam_target))
	return abs(n[2])*.75+abs(n[3])*.25
end



function trace_shadow(p,v,s)
	local shadow_dist,shadow,shadow_white ,shadow_hit,shadow_n,shadow_p,sd= s or 0,{1,1,1},{1,1,1},vox_dda(p[1],p[2],p[3],v[1],v[2],v[3])
	

	if(shadow_hit)then
		shadow_dist+=sd
		local shadow_fade= 1-mid(0,1,.05*shadow_dist)
		if(shadow_hit>48)return shadow_white
		if( (shadow_hit>=16 and shadow_hit<32))then
			--local next_shadow=trace_shadow(vec3_add(shadow_p,vec3_scale(v,.01)),v)
			--local rgb=pico_palette[shadow_hit%16]
			--shadow = vec3_mult(next_shadow,rgb)
			--shadow = vec3_lerp(shadow,shadow_white,shadow_fade)
			
			--merging to save tokens
			return vec3_lerp(vec3_mult(trace_shadow(vec3_add(shadow_p,vec3_scale(v,.01)),v),pico_palette[shadow_hit%16]),shadow_white,shadow_fade)
		else
			--we hit an opaque block
			return vec3_lerp({0,0,0},shadow_white,shadow_fade)
		
		end
	end
	return shadow
end

function find_ambient_occlusion(p,n)
	-- check the normal direction
	--find vector for u and for v
	local u
	local v
	
	local ud
	local vd
	
	local cx=flr(p[1])
	local cy=flr(p[2])
	local cz=flr(p[3])
	local bright=false
	--local cy=flr(p[2])
	--local cz=flr(p[3])x
	--local cz=flr(p[3])
	
	if( abs(n[1])==1)then
		u={0,0,1}
		ud=3
		v={0,1,0}
		vd=2
	elseif( abs(n[2])==1)then
		u={0,0,1}
		ud=3
		v={1,0,0}
		vd=1
	elseif( abs(n[3])==1)then
		u={1,0,0}
		ud=1
		v={0,1,0}
		vd=2
	end
	
	local min_d=1
	local d=1
	
	local glow_color={0,0,0}
	
	for i=-1,1 do
		for j=-1,1 do
		
			local tx=cx+u[1]*i +v[1]*j
			local ty=cy+u[2]*i +v[2]*j
			local tz=cz+u[3]*i +v[3]*j
		
			if(tx>=0 and tx<k_width and ty>=0 and ty<k_height and tz>=0 and tz<k_depth )then
				d=1
				--if( not (i==0 and j==0) )then --ignore center
				local v=vox_scene[tx][ty][tz]
				if(v>48)bright=true
				
				if(v!=0)then
				
					if(abs(i)!=abs(j))then
						--sides
						
						if(i<0)d=p[ud]%1
						if(i>0)d=1-p[ud]%1
						if(j<0)d=p[vd]%1
						if(j>0)d=1-p[vd]%1
					else
						--diags
						local diag_u,diag_v
						if(i<0)then
							diag_u=p[ud]%1
						else
							diag_u=1-p[ud]%1
						end
						if(j<0)then
							diag_v=p[vd]%1
						else
							diag_v=1-p[vd]%1
						end
				
						d=sqrt(diag_u*diag_u+diag_v*diag_v)
					
					end
					
					--min_color=vec3_mult(

				if(bright)glow_color=vec3_add(glow_color,vec3_scale({pico_palette[v%16][1],pico_palette[v%16][2],pico_palette[v%16][3]},1-d)) d=2
				min_d=min(min_d,d)
				end
			
			end
		end
	end
	


	
	return min_d,glow_color
	
end







--shade list has shadow,dark,mid,highlight
shade_list = build_num_table([[
[0]=0,0,0,1|
0,0,1,13|
0,1,2,4|
0,1,3,11|
1,2,4,9|
0,1,5,6|
0,5,6,7|
1,6,7,7|
2,4,8,14|
2,4,9,10|
4,9,10,15|
1,3,11,10|
1,13,12,7|
0,1,13,12|
2,13,14,15|
2,9,15,7
]],true)

--https://www.iquilezles.org/www/articles/volumesort/volumesort.htm
--how to do quick and easy volume sort
function draw_vox(high_qual)
	
	local vox_scene,shade_list,k_width,k_height,k_depth,splat_r= vox_scene,shade_list,k_width,k_height,k_depth,splat_r

	local cam_d = vec3_transform({0,0,-1},cam_matrix)
	
	local x_inc,y_inc,z_inc,x_start,y_start,z_start = 1,-1,1,0,0,0

	local x_ord,y_ord,z_ord = 1,3,2
	local i_lim,j_lim,k_lim=k_width-1,k_height-1,k_depth-1
	
	--cam_target={7.5,12,7.5}
	local cam_tx=cam_target[1]
	local cam_ty=cam_target[2]
	local cam_tz=cam_target[3]
	
	if(cam_d[1]<0)x_inc*=-1
	if(cam_d[3]<0)z_inc*=-1
	
	if(cam_d[2]>0)x_ord,y_ord,z_ord = 2,1,3 y_inc*=-1 k_lim,i_lim,j_lim=k_width-1,k_height-1,k_depth-1

	if(x_inc<0)x_start=k_width-1
	if(y_inc<0)y_start=k_height-1
	if(z_inc<0)z_start=k_depth-1
	
	local x_loc,y_loc,z_loc=x_start,y_start,z_start
	
	local cam_hx,cam_hy,cam_hz=cam_h[1],cam_h[2],cam_h[3]
	local cam_vx,cam_vy,cam_vz=cam_v[1],cam_v[2],cam_v[3]
	
	local min_draw=-splat_r*2
	local max_draw=127+splat_r*2
	local splat_d=splat_r*2


	local last_v=0
	palt(0,false)
	palt(14,true)
	pal(0,0)

	for j=0,j_lim do
		if(x_ord==2)x_loc=x_start
		if(y_ord==2)y_loc=y_start
		if(z_ord==2)z_loc=z_start
		
		for k=0,k_lim do
			
			
			
			if(x_ord==1)x_loc=x_start
			if(y_ord==1)y_loc=y_start
			if(z_ord==1)z_loc=z_start
			
			for i=0,i_lim do
				local v= vox_scene[x_loc][y_loc][z_loc]
				if(v>0)then
					local sx=(cam_hx*(x_loc-cam_tx+.5)+cam_hy*(y_loc-cam_ty+.5)+cam_hz*(z_loc-cam_tz+.5))*64*cam_zoom+64
					local sy=(cam_vx*(x_loc-cam_tx+.5)+cam_vy*(y_loc-cam_ty+.5)+cam_vz*(z_loc-cam_tz+.5))*64*cam_zoom+64
					
					if(sx>min_draw and sx<max_draw and sy>min_draw and sy<max_draw)then

							if(v!=last_v)then
							local the_shade=shade_list[v%16]
							fillp()
							pal(1,the_shade[1])
							pal(5,the_shade[2])
							pal(6,the_shade[3])
							pal(7,the_shade[4])
							
							if(v>15 and v<=32)fillp(0b0101101001011010.11)
							 if(v>32 and v<=48)fillp(0b1111000011110000.01)
							 if(v>48 and v<=64)fillp(0b0000010110100000.01)
							
							last_v=v
							end
							
							 

							
							if(not high_qual)then
							sspr(16-splat_r,16-splat_r,splat_d,splat_d,sx-splat_r,sy-splat_r)
							else

								splat_cube(sx,sy)
								--
							end
							
					end

				end
				
				if(x_ord==1)x_loc+=x_inc
				if(y_ord==1)y_loc+=y_inc
				if(z_ord==1)z_loc+=z_inc
			end
			
			if(x_ord==2)x_loc+=x_inc
			if(y_ord==2)y_loc+=y_inc
			if(z_ord==2)z_loc+=z_inc
			--flip()
		end
		if(x_ord==3)x_loc+=x_inc
		if(y_ord==3)y_loc+=y_inc
		if(z_ord==3)z_loc+=z_inc
		
	end
	pal()
	fillp()
end

cube_points=build_num_table([[
-0.5,0.5,0.5|
0.5,0.5,0.5|
0.5,-0.5,0.5|
-0.5,-0.5,0.5|
-0.5,0.5,-0.5|
0.5,0.5,-0.5|
0.5,-0.5,-0.5|
-0.5,-0.5,-0.5
]])


cube_faces=build_num_table([[
1,2,3,4,6|
8,7,6,5,5|
2,1,5,6,1|
4,3,7,8,7|
5,1,4,8,5|
2,6,7,3,6
]])


splat_r=8
function draw_cube()
	local cam_d = vec3_transform({0,0,-1},cam_matrix)
	local cam_hx,cam_hy,cam_hz,cam_vx,cam_vy,cam_vz=cam_h[1],cam_h[2],cam_h[3],cam_v[1],cam_v[2],cam_v[3]
	
	for i,p in pairs(cube_points)do
		p[5]=(cam_hx*(p[1])+cam_hy*(p[2])+cam_hz*(p[3]))*64*cam_zoom+16
		p[6]=(cam_vx*(p[1])+cam_vy*(p[2])+cam_vz*(p[3]))*64*cam_zoom+16
	end
	
	quad_list={}
	splat_r=32*cam_zoom*2
	rectfill(0,0,32,32,14)

	for i,face in pairs(cube_faces) do

		--local xa,ya= cube_points[face[1]][5],cube_points[face[1]][6]
		--local xb,yb=cube_points[face[2]][5],cube_points[face[2]][6]
		--local xc,yc = cube_points[face[3]][5],cube_points[face[3]][6]
		--local xd,yd = cube_points[face[4]][5],cube_points[face[4]][6]	
		local xa,ya,xb,yb,xc,yc,xd,yd = cube_points[face[1]][5],cube_points[face[1]][6],cube_points[face[2]][5],cube_points[face[2]][6],cube_points[face[3]][5],cube_points[face[3]][6],cube_points[face[4]][5],cube_points[face[4]][6]

		
		--local vxa=xb-xa
		--local vya=yb-ya
		--local vxb=xc-xb
		--local vyb=yc-yb
		----check winding
		----collapsed
		--if(vxa*vyb-vya*vxb>0)then
		
		--collapsed check winding see above
		if((xb-xa)*(yc-yb)-(yb-ya)*(xc-xb)>0)then
			draw_quad(xa,ya,xb,yb,xc,yc,xd,yd,face[5])
			add(quad_list,{xa-16,ya-16,xb-16,yb-16,xc-16,yc-16,xd-16,yd-16,face[5]})
		end
	
	end
	
	local src,dest=0x6000,0x0000
	for i=0,32 do
		memcpy(dest,src,16)
		dest+=64
		src+=64
	end
	
	rectfill(0,0,32,32,6)
	
end


function draw_quad(xa,ya,xb,yb,xc,yc,xd,yd,c)

	 p01_triangle_163(xa,ya,xb,yb,xd,yd,c)
	 p01_triangle_163(xb,yb,xc,yc,xd,yd,c)

	line(xa,ya,xb,yb,0)
	line(xc,yc)
	line(xd,yd)
	line(xa,ya)
end


--@p01
function p01_triangle_163(x0,y0,x1,y1,x2,y2,col)
 color(col)
 if(y1<y0)x0,x1,y0,y1=x1,x0,y1,y0
 if(y2<y0)x0,x2,y0,y2=x2,x0,y2,y0
 if(y2<y1)x1,x2,y1,y2=x2,x1,y2,y1
 col=x0+(x2-x0)/(y2-y0)*(y1-y0)
 p01_trapeze_h(x0,x0,x1,col,y0,y1)
 p01_trapeze_h(x1,col,x2,x2,y1,y2)
end
function p01_trapeze_h(l,r,lt,rt,y0,y1)
 lt,rt=(lt-l)/(y1-y0),(rt-r)/(y1-y0)
 if(y0<0)l,r,y0=l-y0*lt,r-y0*rt,0
 y1=min(y1,128)
 for y0=y0,y1 do
  rectfill(l,y0,r,y0)
 -- for i=l,r do sset(i,y0,13) end
  l+=lt
  r+=rt
 end
end

function splat_cube(sx,sy)
	local quad_list=quad_list
	for i,q in pairs(quad_list) do
		draw_quad(q[1]+sx,q[2]+sy,q[3]+sx,q[4]+sy,q[5]+sx,q[6]+sy,q[7]+sx,q[8]+sy,q[9])
	end
end

--function quick_box_sdf(px,py,pz,params) 
--	return max(max(abs(px)-params[1],abs(py)-params[2]),abs(pz)-params[3])
--end

--------------gui-------------------------------------------------------------
function init_mouse()
	poke(0x5f2d, 1) --enable mouse
	
	update_mouse()
	mouse_down_x=mouse_x
	mouse_down_y=mouse_y
	last_mouse_x=mouse_x
	last_mouse_y=mouse_y
	last_mouse_down=mouse_down
	last_right_mouse_down=right_mouse_down
	last_middle_mouse_down=middle_mouse_down
	tx=mouse_x
	ty=mouse_y
	last_click_time=0
	last_right_click_time=0
	last_middle_click_time=0
end

function update_mouse()
	last_mouse_x=mouse_x
	last_mouse_y=mouse_y
	mouse_x=stat(32)
	mouse_y=stat(33)
	
	last_mouse_down=mouse_down
	last_right_mouse_down=right_mouse_down
	last_middle_mouse_down=middle_mouse_down
	
	--if(stat(34)!=0)then
	--	cls()
	--	print(stat(34))
	--end
	
	
	if(band(stat(34),1)==1)then
		mouse_down=true
		if(not last_mouse_down) mouse_down_x=mouse_x mouse_down_y=mouse_y last_click_time=cur_frame
	else
		mouse_down=false
	end
	
	if(band(stat(34),2)==2)then
		right_mouse_down=true
		if(not last_right_mouse_down) last_right_click_time=cur_frame
	else
		right_mouse_down=false
	end
	
	if(band(stat(34),4)==4)then
		middle_mouse_down=true
		if(not last_middle_mouse_down) last_middle_click_time=cur_frame
	else
		middle_mouse_down=false
	end
	
end

k_left_mouse=1
k_right_mouse=2
k_middle_mouse=4

function mouse_click(b)
	if(b==nil or b==k_left_mouse) return(mouse_down==true and last_mouse_down==false)
	if(b==k_right_mouse)return(right_mouse_down==true and last_right_mouse_down==false)
	if(b==k_middle_mouse)return(middle_mouse_down==true and last_middle_mouse_down==false)
	
end

k_repeat_delay=15

function check_click_rect(x1,y1,x2,y2,rep)
	--check if last state was mouse down
	--and current state is mouse up
	--and mouse down and mouse up were both in rect
	if( in_rect(mouse_down_x,mouse_down_y,x1,y1,x2,y2))then
		if((last_mouse_down and not mouse_down) or (rep and mouse_down and cur_frame-last_click_time>k_repeat_delay ))then
			return in_rect(mouse_x,mouse_y,x1,y1,x2,y2)
		end
	end
	return false
end

function check_down_rect(x1,y1,x2,y2)
	return(mouse_down and in_rect(mouse_x,mouse_y,x1,y1,x2,y2))
end

function in_rect(x,y,x1,y1,x2,y2)
	if(x2<x1)x1,x2=x2,x1
	if(y2<y1)y1,y2=y2,y1
	return (x>=x1 and x<x2 and y>=y1 and y<y2)
end

function draw_mouse()

	
	
	line(mouse_x-2,mouse_y,mouse_x+2,mouse_y,4)
	line(mouse_x,mouse_y-2,mouse_x,mouse_y+2,5)
	pset(mouse_x,mouse_y,6)


end



k_this_vox=1
k_surface_vox=2
function find_vox(sx,sy,mode)
	local cam_matrix=matrix_multiply(create_x_rotate(cam_ax),create_y_rotate(cam_ay))
	local cam_h ,cam_v,cam_d,cx,cy,cz= vec3_transform({1,0,0},cam_matrix), vec3_transform({0,1,0},cam_matrix),vec3_transform({0,0,1},cam_matrix)
	
	local cam_location=vec3_add(cam_target,vec3_scale(cam_d,-k_cam_height))
	
	local v_v,v_h=vec3_scale(cam_v,shr(sy-64,6)/cam_zoom),vec3_scale(cam_h,shr(sx-64,6)/cam_zoom)
	local ray_start=vec3_add(cam_location,vec3_add(v_h,v_v))
	local v,n,p=vox_dda(ray_start[1],ray_start[2],ray_start[3],cam_d[1],cam_d[2],cam_d[3])

	if(v!=false)then
	
		if(mode==nil or mode==k_this_vox)then
		
			
			cx=flr(p[1]-n[1])
			cy=flr(p[2]-n[2])
			cz=flr(p[3]-n[3])
		elseif(mode==k_surface_vox)then
			cx=flr(p[1])
			cy=flr(p[2])
			cz=flr(p[3])
		end
			
		if(cx<k_width and cx>=0 and cy<k_height and cy>=0 and cz<k_depth and cz>=0)then
				return cx,cy,cz
		else
			return false
		end
	end
	return false
end


function frame_rect(x1,y1,x2,y2,cf,cl)
	rectfill(x1,y1,x2,y2,cf)
	rect(x1,y1,x2,y2,cl)
end

function sprite_button(s,x,y,active)
	if(in_rect(mouse_x,mouse_y,x,y,x+7,y+7))then
		rectfill(x-1,y-1,x+8,y+8,7)
	end
	if(active)frame_rect(x-1,y-1,x+8,y+8,5,7)
	if(check_click_rect(x,y,x+7,y+7))then
		frame_rect(x-1,y-1,x+8,y+8,5,8)
		spr(s,x,y)
		return true
	end
	spr(s,x,y)
	return false
	
end

function rect_button(x1,y1,x2,y2,cf,c1,active)
	frame_rect(x1,y1,x2,y2,cf,cl)
	if(in_rect(mouse_x,mouse_y,x1,y1,x2,y2))then
		rect(x1+1,y1+1,x2-1,y2-1,7)
	end
	if(active)then
		
		rect(x1+1,y1+1,x2-1,y2-1,7)
		rect(x1+1,y1+2,x2-1,y2-2,0)
	--	if(cf==7)rect(x1+1,y1+1,x2-1,y2-1,5)
	end
	
	if(check_click_rect(x1,y1,x2,y2))then
		rect(x1+1,y1+1,x2-1,y2-1,8)
		return true
	end
	
	return false
end


function text_button(x,y,text,cf,c1)

	local x2,y2=x+#text*4+2,y+8

	frame_rect(x,y,x2,y2,cf,cl)
	print(text,x+2,y+2,cl)
	
	if(in_rect(mouse_x,mouse_y,x,y,x2,y2))rect(x+1,y+1,x2-1,y2-1,7)
	if(check_click_rect(x,y,x2,y2))return true
	return false
	
end

k_paint_mode=1
k_add_mode=2
k_fill_mode=3
k_pan_mode=4
k_erase_mode=10
ground_on=true

k_solid_mode=0
k_transparent_mode=1
k_mirror_mode=2
k_bright_mode=3


mouse_mode = k_add_mode
color_mode = k_solid_mode
cur_color=8
function handle_ui()
	--if(check_click_rect(0,0,127,20))click_through=false
	--draw_window

	
	local do_render=false
	local do_anim=false
	local do_info=false
	--frame_rect(xloc,yloc,xloc+width,yloc+height,6,5)
	
	
	frame_rect(0,0,127,20,1,5)
	
	frame_rect(0,0,47,20,6,5)
	palt(0,false)
	palt(14,true)
	if(sprite_button(12,2,2,mouse_mode == k_add_mode))mouse_mode = k_add_mode
	if(sprite_button(13,11,2,mouse_mode == k_paint_mode))mouse_mode = k_paint_mode
	if(sprite_button(14,2,11,mouse_mode == k_fill_mode))mouse_mode = k_fill_mode
	if(sprite_button(07,11,11,mouse_mode == k_pan_mode))mouse_mode = k_pan_mode
	if(sprite_button(15,20,2))do_render=true 
	if(sprite_button(05,20,11))do_anim=true
	if(sprite_button(20,29,2))toggle_ground()
	if(sprite_button(21,38,2))save_scene()
	if(sprite_button(4,38,11))do_info=true
	
	frame_rect(47,0,67,20,6,5)
	palt(0,false)
	palt(14,true)
	if(sprite_button(8,49,2,color_mode==k_solid_mode))then color_mode=k_solid_mode if(cur_color!=0)then cur_color=cur_color%16+16*color_mode end end
	if(sprite_button(9,58,2,color_mode==k_transparent_mode))then color_mode=k_transparent_mode if(cur_color!=0)then cur_color=cur_color%16+16*color_mode end end
	if(sprite_button(10,49,11,color_mode==k_mirror_mode))then color_mode=k_mirror_mode if(cur_color!=0)then cur_color=cur_color%16+16*color_mode end end
	if(sprite_button(11,58,11,color_mode==k_bright_mode))then  color_mode=k_bright_mode if(cur_color!=0)then cur_color=cur_color%16+16*color_mode end end
	--
	frame_rect(67,yloc,127,20,6,5)
	for i=0,15 do
		local column,row=i%8,flr(i/8)
		local x,y=69+7*column,2+9*row

		if(rect_button(x,y,x+7,y+7,i,5,cur_color%16 == i))then
			if(i!=0)then
				cur_color=i+16*color_mode
			else
				cur_color=0 -- erase mode
				mouse_mode=k_add_mode
			end
			--if(i==0)then mouse_mode=k_erase_mode end
		end
		
		if(i==0)line(x+6,y+1,x+1,y+6,8)
	end
	
	if(sprite_button(6,29,11))then
		--if(modal_confirm("clear scene?"))init_vox_scene()
		if(handle_window(80,80,true,new_scene_func))then
			k_width=temp_scene_width
			k_height=temp_scene_height
			k_depth=temp_scene_depth
			cam_target={k_width/2,k_height-1,k_depth/2}
			init_vox_scene()
		end
			  camera_updated=true reload()

	end
	-- modal_content_func(data)
	if(do_render)render_scene()
	if(do_anim)then
		if(modal_confirm("render animation?\n...takes a while"))render_anim()

			camera_updated=true reload()

		
	end
	if(do_info)show_info()camera_updated=true reload()
end

function toggle_ground()
	if(ground_on)then
		for i=0,k_width-1 do
			for k=0,k_depth-1 do
				vox_scene[i][k_height-1][k]=0
			end
		end
		ground_on=false
		
	else
		for i=0,k_width-1 do
			for k=0,k_depth-1 do
				vox_scene[i][k_height-1][k]=7
			end
		end
		ground_on=true
	end
	camera_updated=true reload()
end

function digit_widget(v,x,y,max_v,min_v)
	frame_rect(x,y,x+10,y+8,7,0)
	print(v,x+2,y+2,12)
	if(text_button(x+12,y,"<",6,0))v= mid(min_v,max_v,v-1)
	if(text_button(x+20,y,">",6,0))v= mid(min_v,max_v,v+1)
	return v
end

temp_scene_width=k_width
temp_scene_height=k_height
temp_scene_depth=k_depth
function new_scene_func(data,w,h)
	local x1,y1=flr(64-w/2),flr(64-h/2)
	center_print("new scene",64,y1+6,0)
	print("width",x1+4,y1+16,0) temp_scene_width=digit_widget(temp_scene_width,x1+32,y1+14,4,32)
	print("height",x1+4,y1+26,0) temp_scene_height=digit_widget(temp_scene_height,x1+32,y1+24,4,32)
	print("depth",x1+4,y1+36,0) temp_scene_depth=digit_widget(temp_scene_depth,x1+32,y1+34,4,32)
	
	if(temp_scene_width*temp_scene_height*temp_scene_depth>8000)temp_scene_height-=1 print("height",x1+4,y1+26,8)
	
	print("warning:",x1+4,y1+50,0)
	print("will clear data",x1+4,y1+58,0)
end

info_text="\^w\^tpICOvOX\n\^-w\^-tversion "..build_version.."\n\nrequires mouse\n\n\^wtools\^-w\nblock: add blocks\nbrush: paint color\ncam: render\nfloor: toggle floor\ndisk: save\nbucket: fill color\nhand: pan\nloop: render anim\ndoc: clear scene\n?: info text\n\n\^wblocks\^-w\nsolid block\ntransparent block\nmirror block\nbright block\n\n\^wcolors\^-w\nselect color\nblack is erase\n\n\^wkeys\^-w\narrow keys rotate view\nz+arrow: pan\nshift+up/down: zoom\nx: quick render\n\n\^wmouse\^-w\nleft: add block\nright: del block\nmiddle: rotate\nscroll wheel: zoom\nshift+middle: look at"


function show_info()
	memcpy(0x0000,0x6000,128*64)
	local frame=0
	while(true)do
		memcpy(0x6000,0x0000,128*64)
		
		update_mouse()
		frame_rect(16,16,127-16,127-16,7,0)
		clip(18,18,127-36,78)
		
		
		
		print(info_text,19,18-(frame/1)%360+80,0)
		clip()
		if(text_button(48,98,"  ok  ",6,0))return true --init_vox_scene() camera_updated=true reload()  return true

		draw_mouse()
		flip()
		frame+=1
	end
end


function modal_confirm(s)
	memcpy(0x0000,0x6000,128*64)
	while(true)do
		memcpy(0x6000,0x0000,128*64)
		
		update_mouse()
		frame_rect(16,32,127-16,60,7,0)
		print(s,19,35,0)
		if(text_button(46,50,"yes",6,0))return true --init_vox_scene() camera_updated=true reload()  return true
		if(text_button(64,50,"no",6,0))return false --camera_updated=true reload() return false
		draw_mouse()
		flip()
	end
end

function modal_content_func(data,w,h)
	center_print(data,64,64-h/2+4,0)
end

function handle_window(w,h,show_ok,content_func,data)
	memcpy(0x0000,0x6000,128*64)
	while(true)do
		memcpy(0x6000,0x0000,128*64)
		
		update_mouse()
		frame_rect(64-w/2,64-h/2,64+w/2,64+h/2,7,0)

		if(text_button(64-w/2+4,64+h/2-12,"cancel",6,0))return false --init_vox_scene() camera_updated=true reload()  return true
		if(show_ok)then
			if(text_button(64+w/2-4*2-6,64+h/2-12,"ok",6,0))return true
		end--camera_updated=true reload() return false
		if(content_func!=nil)content_func(data,w,h)
		
		draw_mouse()
		flip()
	end
end

function render_scene()
	flip() 

	not_skip = iso_render()
	
	if(not_skip==nil)extcmd("screen",1)
	print("\#0render saved to desktop.",0,0,7)
	print("\#0click to return.")
	while(true)do
		 flip()
		if(stat(34)!=0 ) return false
	end
end


function render_anim()
	local k_length,cur_frame,start_ay=128,0,cam_ay
	extcmd("rec_frames")
	cls()
	--flip() 

	while (cur_frame<k_length)do
		cam_ay=start_ay+cur_frame/k_length
		update_camera()
		not_skip=iso_render()
		cur_frame+=1
		flip()
		if(stat(34)!=0 ) return false
	end
	if(not_skip==nil)then
	extcmd("video")
	cam_ay=start_ay
	update_camera()
	end

end


function fill_color(x,y,z,c)
	--if(x>=0 and y>=0 and z>=0 and x<k_width and y<k_height and z<k_depth)then
		local run_color = vox_scene[x][y][z]
		if(run_color==c)return false --trying to fill an already right vox
		recursive_fill(x,y,z,c,run_color)
	--end
end

function recursive_fill(x,y,z,c,run_color)
	if(x>=0 and y>=0 and z>=0 and x<k_width and y<k_height and z<k_depth)then
		if(vox_scene[x][y][z]!=run_color)return false
		
		vox_scene[x][y][z]=c
		
		
		
		recursive_fill(x+1,y,z,c,run_color)
		recursive_fill(x-1,y,z,c,run_color)
		recursive_fill(x,y+1,z,c,run_color)
		recursive_fill(x,y-1,z,c,run_color)
		recursive_fill(x,y,z+1,c,run_color)
		recursive_fill(x,y,z-1,c,run_color)
		
	end
	return false
end



function handle_mouse_draw()
	local cx,cy,cz
	if(mouse_y<20)return false
	
	if(mouse_click(k_right_mouse) or (cur_color==0 and mouse_click(k_left_mouse)))then
		cx,cy,cz=find_vox(mouse_x,mouse_y,k_this_vox)
		if(cx!=false)then
				vox_scene[cx][cy][cz]=0
				needs_redraw=true
				return true
		end
	end
	
	if(mouse_mode==k_paint_mode)then
		if(mouse_click(k_left_mouse) )then 
			cx,cy,cz =find_vox(mouse_x,mouse_y)
			--vox_scene[cx][cy][cz]=15
			if(cx!=false)then
				vox_scene[cx][cy][cz]=cur_color
				needs_redraw=true
				return true
			end
		end
	end
	
	if(mouse_mode==k_fill_mode)then
		if(mouse_click(k_left_mouse) )then 
			cx,cy,cz=find_vox(mouse_x,mouse_y)
			if(cx!=false)then
				fill_color(cx,cy,cz,cur_color)
				needs_redraw=true
					return true
			end
		end
	end
	
	if(mouse_mode==k_add_mode)then
		if(mouse_click(k_left_mouse) )then 
			--cls(6)
			cx,cy,cz =find_vox(mouse_x,mouse_y,k_surface_vox)
			--vox_scene[cx][cy][cz]=15
			if(cx!=false)then
				vox_scene[cx][cy][cz]=cur_color
				needs_redraw=true
				return true
			end
		end
	end
	
	if(mouse_mode==k_pan_mode)then
		if(mouse_click(k_left_mouse) )then 
			cx,cy,cz =find_vox(mouse_x,mouse_y)
			if(cx)then 
				cam_target={cx,cy,cz}
				camera_updated=true
			end
		end
		
		if(middle_mouse_down)then

			local rx=(mouse_x-64)/64*k_move_speed*1.5
			local ry=-(mouse_y-64)/64*k_move_speed*1.5
			cam_target=vec3_add(cam_target,vec3_scale(cam_h,rx))
			cam_target=vec3_add(cam_target,vec3_scale(cam_v,-ry))
		
			camera_updated=true
		
		end
	end
	
	--handle rotations
	if(middle_mouse_down and mouse_mode!=k_pan_mode and not btn(4,1) )then
		local rx=(mouse_x-64)/64*k_rotate_speed*1.5
		local ry=-(mouse_y-64)/64*k_rotate_speed*1.5
		
		cam_ay+=-rx
		cam_ax+=-ry
		camera_updated=true
	
	end
	
	if(mouse_click(k_middle_mouse) and btn(4,1) )then 
		cx,cy,cz =find_vox(mouse_x,mouse_y)
		if(cx)then 
			cam_target={cx,cy,cz}
			camera_updated=true
		end
	end
	
	return false
end

k_rotate_speed=.005
k_move_speed=.2
function handle_keys()
	

	
	if(btn(5))then flip() iso_render() while(btn(5))do flip() end end
	
	if(mouse_down and right_mouse_down)cam_target[1]+=-k_move_speed*cam_h[1] camera_updated=true

	
	if(btn(4,0))then
		if(btn(0))then
			cam_target=vec3_add(cam_target,vec3_scale(cam_h,-k_move_speed))
			--
			--cam_target[1]+=-k_move_speed*cam_h[1]
			--cam_target[2]+=-k_move_speed*cam_h[2]
			--cam_target[3]+=-k_move_speed*cam_h[3]
			camera_updated=true
		end
		if(btn(1))then
			cam_target=vec3_add(cam_target,vec3_scale(cam_h,k_move_speed))
			--cam_target[1]+=k_move_speed*cam_h[1]
			--cam_target[2]+=k_move_speed*cam_h[2]
			--cam_target[3]+=k_move_speed*cam_h[3]
			camera_updated=true
		end
		if(btn(2))then
			cam_target=vec3_add(cam_target,vec3_scale(cam_v,-k_move_speed))
			--cam_target[1]+=-k_move_speed*cam_v[1]
			--cam_target[2]+=-k_move_speed*cam_v[2]
			--cam_target[3]+=-k_move_speed*cam_v[3]
			camera_updated=true

			
		end
		if(btn(3))then
			cam_target=vec3_add(cam_target,vec3_scale(cam_v,k_move_speed))
			--cam_target[1]+=k_move_speed*cam_v[1]
			--cam_target[2]+=k_move_speed*cam_v[2]
			--cam_target[3]+=k_move_speed*cam_v[3]
			camera_updated=true
		
		end
		
		--if(btn(1))cam_target[1]+=-k_move_speed camera_updated=true
	elseif(btn(4,1))then
		if( btn(2))cam_zoom+=.005 camera_updated=true
		if(btn(3))cam_zoom+=-.005 camera_updated=true
	else
		if(btn(2))cam_ax+=k_rotate_speed camera_updated=true
		if(btn(3))cam_ax-=k_rotate_speed camera_updated=true
		if(btn(0))cam_ay-=k_rotate_speed camera_updated=true
		if(btn(1))cam_ay+=k_rotate_speed camera_updated=true
	end
	
	local scroll_v=stat(36)*.005
	
	if(scroll_v!=0)cam_zoom+=scroll_v camera_updated=true

	
	
end



-------------------------------------


function _init()

	cls(6)
	
	
	poke(0x5f34, 1) -- set fill pattern mode
	init_mouse()

	cur_frame=0
	init_scene()

	update_camera()
	camera_updated=true
	needs_redraw=false
	is_turning=false
	 
	
end

function _update()

	update_mouse()
	check_import()
	handle_keys()
end

frame_count=100
function _draw()

	fillp()

	if(camera_updated)then
		cls(6)
		update_camera()
		draw_cube()
		draw_vox()
		needs_redraw=true
	--	vox_splat()
	else
		if(needs_redraw)then
			cls(6)
		draw_vox(true)
		memcpy(0x0000+64*16,0x6000+64*16,128*64-64*16)
		needs_redraw=false
		end
		
	end
	
	if(not needs_redraw and not camera_updated)then
		memcpy(0x6000+64*16,0x0000+64*16,128*64-64*16)
	end

	camera_updated=false

	handle_ui()
	handle_mouse_draw()
	draw_mouse()

	cur_frame+=1
end

__gfx__
b3bb35bb5bb3bb33ccecececccecececee0000eeee0000eee00000eeee00000eeeeeeeee000000eeeeeeeeeeeeeeeeeeeee00eeeee000eeee00000eeee0000ee
b9ccbccbccbdccfcccccceeeccccceeee099990ee0dddd0ee066060ee0909090e000000e0cccc0eee000000ee000000eee0660eeee050eee0666000eee0aa0ee
bcb9cb7bbbbcb5cb7777777777777777e090090e0deeeed0e0660660e0909090e0fff20e0cddd000e0ddd50ee0ffff0ee066660eee050eee0666090e00555500
babbaebbebbabbae7777777777777777e00e090e0ee0eee0e066000000909090e0f8820e0cdcc020e0dd550ee0faaf0ee006600ee00000ee0555090e05500550
a100121a111111117777777777777777eee090eede00ee0de066866009999990e0f8820e0cdcc020e0d5560ee0faaf0ee000050ee04440eee000099005077050
508110120c21f1117777777777777777eee000eee00000dee068886009999990e0f2220e00000020e055660ee0ffff0ee000550ee00000eeeeeee09005066050
2ad1a1121d19d11d7777777777777777eee090eeee00ddeee066866000999990e000000eee022220e000000ee000000eee0050eee09990eeeeeee09005500550
3d1bd193111c17c17777777777777777eee000eeeee0eeeee0000000e000000eeeeeeeeeee000000eeeeeeeeeeeeeeeeeee00eeee00000eeeeeeee0000000000
043b5ab093114b25ccecececccecececeee00eee0000000ebcbacb8bbbbcb5cbbcbacb8bbbbcb5cbbcbacb8bbbbcb5cb7777777777777777bcbacb8bbbbcb5cb
8c13cc38c26cc1ccccccceeeccccceeeee0660ee06077060bbbbb1bb1bbbbbb1bbbbb1bb1bbbbbb1bbbbb1bb1bbbbbb17777777777777777bbbbb1bb1bbbbbb1
b3ab34bbbbc5db5b7777777777777777e066560e060000601100120f20f111111100120f20f111111100120f20f111111bbbbbb11100120f1100120f20f11111
b9ccbccbcccecc1c77777777777777770665666006666660116110110a11f111116110110a11f111116110110a11f11120f1111111611011116110110a11f111
bb6acbbb7bbcb4c7777777777777777700665650067777601e31e1121d2bd1a11e31e1121d2bd1a11e31e1121d2bd1a10a11f1111e31e1121e31e1121d2bd1a1
babbacbbcbbabbac7777777777777777e006650e067117603311c073111c17c13311c073111c17c13311c073111c17c11d2bd1a13311c0733311c073111c17c1
5111181d81d111187777777777777777ee0050ee06777760053b5ab0a3013b17053b5ab0a3013b17053b5ab0a3013b17111c17c1053b5ab0053b5ab0a3013b17
507210120981e1117777777777777777eee00eee000000005313cc37c17c13cc5313cc37c17c13cc5313cc37c17c13cca3013b175313cc375313cc37c17c13cc
4333cc31c31c33cc11ccbcc1cc1dccfc13bb36b25b35bb5bb3bb35bb5bb3bb33bc3bc39bb3bcb5c3ac3bccbcc3ec3ccc3accacc3cc3dcc0c34bb4cb3db39bb9d
b3eb3bbdbec3db3bbcbac38b1bbcb5c35c3bccb7cc6ccbccb9ccbccbccbdccfcb5bb5dbbcbb5bb5cbbcbb5bbbbdbabbbbcb9cb6bbbbcb4cb1cbbccb1cc6ccbcc
b8ccaccbccbcccfcb4bbbeb94b9bbbb3dbfbb6bbbecbcbbbbcb9cb7bbbbcb5cb2bbbccb1c73c7bccb4c75c7bccb6c77cbabbaebbebbabbaebbebb7bb7ebbdb7b
bbb5b76bb7bc7ccbbbb7bc7acb9b7bccb4c75c7bccb6c77cbabbaebbebbabbaebbebb7bb7ebbdbb7bb7cbbbbb7bbbab78b7bbb79cb9bb7bc79cb8b7bccb6c77c
00080d80c000080c80b000180e80e100180e80e100120a20a100121a11111111111111111111111100040b209000120a20a100120a20a100121a111111111111
11111111111111121e21e111121e21e100140a5071001507508110120c21f1111111111111121f21f111121f21f111121f21f111128fd1d10035065063003506
5063101d1c51d111151dd1b1111d2ad1c1121d2cd1b1121d2ad1a1121d19d11d00340a40b301341c50a30135183172112317c1b1111c19c171111c15c13111cc
11c11c11cc11c11c03343d40c303343b40a311342d31a3113d1bd193111c17c151111c13c11c11cc11c11c11cc11c11c043b4bb0b3023b29b093133537518313
ccececec113c17c14311cc11c11c11cc11c11c11cc11c11c043b5ab093114b2531cb13b5385363333516c19b11bc56b1ec13cc3dc1dcc1ccc6d1ac13cccee1dc
ccccceeeab12bb2ab1ab12bb3ad1bb15bc5bc19b335c37c18c13cc38c26cc1cc18ccacc1cc1bccdc15bb55b15b15bb56b16b353bb5d1ab35cb57b39c35cb4cb3
77777777d3ccc3cc18ccbcc1cc1dccfc35bb56b36b34bb4ab3ab34bbbbc5db5bbccbd3bb3bcdbac3ac5bcc58bcbcc5cbccc37cc3cccdcc1cb5bb59bb8bb5bbb8
77777777bbdb7bbbbdb6c57bbbcdbbc55cbccdbdcc7ccbccb9ccbccbcccecc1cb4bb4bbbbbb4bb4bbbbbbbbdbadb9b3b6bb8c95b6bbcb5c64b6bccb4c65c6bcc
77777777cb7ebc0c9bbbb6b96b9bbb95bbdbb6bb6cbbbbb6bb6acbbb7bbcb4c74b7bbcb4c74c7bccb5c76c7bccb7c78cabbba5bbcbbabbacbbcbb7bb7dbbcbb7
777777777bbb79cbabb7bc7acb9bb7bcb8c76c7bccb7c78cbabbacbbcbbabbacbbcbb7bb7dbbcbb7bb7bbbabb7bbb9b7ab7bbbbbb7cbb7bc78cb7bb7bcb6c78c
77777777a000080a809000180b80b100180c80c100180c205111181d81d111181d81d111181d81d100040920600012052051001205205110180e81f111181d81
7777777781d111181d219111121921910004084081002506507210120981e11112192191111219219111121921911112192191181d8cd1c10034074073003408
d0c5013207d1811115185191121d2bd1a1121d2ad191121d18d11d11dd11d11d00341740a301341a309401d31c5143113515d171112c18c172112c15d11d11dd
11d11d18cc8ec1ec014b1bb0b4014b3a40831233253153113d18c1a5115c18c162112c2421fc18cc8ec1ec18cc8ec1ec03393a90a3025b384183233536527313
d527318c515c17d1cc12cc2bc1bc12cc2bc1bc12cc2bc1bc043b48b08313b438419b23b538525b335d29b19c13cd37d1ac15ccc9d1bc1ccdc9d18c1ccecce1bc
043b27b15b12bb25b15b12bb35c2eb23bc3cd34c33cd57c36c35cc56c37c1ccd18ccacc1cc2cccdc14bb46b17b25bb53b24b25bb54c5eb55bc4bb3ac34cb3bc3
863ccdcbd39cc5cc58ccacc2cc2dccfc34bb46b37b34bb47b38b34bbb8d59b3bbdb4d35c3bcdb8dc6ccbcdb8dcaccbcdcbc356cccdcddcfcb4bb48bb8bb4bb48
bb8bb4bbb8db6bbbbdb4db7c3b6cb8c3763b6cb7c67c6cbc67bcdcc6cb7eccfc3b9bb7b3793b9bb7b379bbbebbebab9bbcb7c96b6bbcb8c67bbccfbdc76c7bcc
77bcccc7cb7eccec9bbbb8b98b9bbb97bbbbbbbf6bbb9bb6bb68bb7b7bbcb6c76b7bbcb6c76b7bccb7c78c7bccb9c79cabbba7bbabbabbaabbabbabb7abbbbb7
bbbab79b7bbbbab7bbb7bc79cb8bb7bc77cb6b7bccb9c7acbabbaabbabbabbaabbabbabb7abbbbb7bb7abb9bb7bb78bb7b7bbbbcb7db7bbb7ecb7bb7bc76cb5b
000809808000080880910018098091001809809100181981b111181b81b111181b81b111181b81b10022012012002201201200220181b110181c81b111181b81
b111181b81b111181b21121122112112000405405100240ad0c20122172141111214214111121421121122112112112281d1b1181d8ad1a1003404404301430d
d094004d1520ad11251ac1c2121d29d181121d28d17111dd11d11d11dd11d11d014b1eb0d403452c3094114515554501dd19d141112c19c18211dd11d11d11dd
11d11d18cc8cc1cc054b5cb0b4024b3a4085124325354512d33951ed11cd16d18c11cd2ad1dc18cc8cc1cc18cc8cc1cc045b59b094024b385585535538558523
3d3ad19d223c57d1bc12cc26c16c12cc26c16c12cc26c21c033938415b13b435415b23b42ab16d334d36d14d23cd36d2ac25cc57c27cc2cc26cc8c1ccecae19c
043b25b21b22bb21b21b24bb4ec2eb34dbbdd3ed45bcb5d5ec5ccdcfd5ac1ccd25cc9cc2cc8bccdc13b948b13b14bb54b4bb45bbb9d29b3bddb7d39d5bcdc9d5
7b5cbdc5d36c3ccdc5dc7ccccdc9dcbcb4bb45bb5bb4bb95b5cb4bbdbad46bbbddb1d356bcddbcdc6c3c6cccc3a6c3c6396cbcccce6dcccc3b9bbab3a93b9b99
b38b39bbb9d94b6bbdb5d66bbbcebac97c6bdcb6c69cc6cbaaccccc6cc7bccdc9bbbbab9ab9bbb9abb8bbbbeb9c99b36bbb6c6cb6bbcbbc6abc6cbb7c77c7bcc
78bcbc7bcc7acccc9bbbbab99bb9bbb8ba9bbbbfb9fb8bb6bb66bb5b7bbcb9c78b7bbc78bc8c7bccb8c79c7bccbac7bcabbbbaba9bbabba8bb8bbabb78bb9bb7
bbb8b7ab7bbbbbb7cb7bbc79cb7bb7bcb7b7ccb7bcb5c7bcbabba8bb8bbabba8bb8bbabb78bb9bb7bb78bb7bb7bb76bb5b7bbbbdb7eb7bbb7fb71b77bb71cb4b
0008078060000806807100180780b200280b80b210181b818111181981911118198191111819819100280b80b200281b80c21018088191111819819111181981
91111819819111181981f22122152252004401401400241520a401821581e211281e2242212214224212221e2242181d8ad191181d89d191004401401401441d
4094112408d272112d2bd1b2212518c188118c17c16811dd11d11d11dd21d1ed044b3e40d403440b459512432c5195114d17d14212c219d11d11dd21d1ed12c8
8dc19c18cc89c19c044b4cb0b4034439407452532d35c5515d58d1ed12dc2cd19c12cd8ac1ac18cc8ac1ac18cc8ac1ac044b4ab0941344334134535435416d53
5d3a429c525c27c54522cc21c21c22cc21c21c22cc21c21c044b47b07423b434425b344b5dd2ab25bd58d3bd55cd59d5bc58cccdd2ac2ccdc7c2bcc8cc8accbc
044b45b054344b45b37423b93cd37924cb58b4bc45cb4dc35c3cddc7d58c2ccdc4dc1dccddc1dc1d44bb41b41b44bb41b41b44bbc1d4db4cbdbcd47c336d5cc3
b6bcddc7d3666ccdc3d65ccccecaecbcb3b9369b6b49bb9cb5ab46bbbdd369bbdebcd3963b6dbdc3e63c6cbdec9cc9cc6adcbcc6cd6ccc9c3b9b9bb57b59bb98
b37b9bbd68b49b6bbdb7d69b366bc9d6bb6cbdb9c6ac6bcc6ccc7cc6cc78ccac9bbbbcb9cb9bbb9bbb6b9bbcbbc9ab6bbdbbd6db6bbc6ebc4cc6cbb6c78cc7cb
b9c7acc7cc79ccac9bbbbcb9bbabbbbbbabbbbbfb7cabbbbbf66b61b7bbcbbc7ab7bbc7abc7cc7cbb9c7ac7bccbbc7ccabbbbcbacbbabba6bb6bbabb76bb8bb7
bb77bb6b7bbbbdb7eb7bbc7bb66bb7bc76cb5bb7bcb4c7ccbabba6bb6bbabba6bb6bbabba6b78bb7bb77bb6bb7bb75bb4b77bb71b71b77bb71b71b77bb71b71b
00080580400028078072002807807200280880821118168161111816816111181781711118178171005806806500481920a80182198072111817817111181781
7111281b81b211281b81b221221a22a200480e80d401481d80b411281a81b221221922922122192292212289d181181d88d181181d87d171404403444403482d
50940245265162212d1ad178118c1ac198118c2881bc12c88cd1dd18dd8dc17c03493d90d41144114114515424556512d55881dd222c28d19d12dd29d19d18cd
8bc17c18cc87c17c03493b90b413443a41a454552cd5e5525d1ae1bd18dc8bc1ad18cc87c17c18cc87c18c18cc88c2cc034939909434454b53b434455cd3a435
4d56d23c25cd57d2bc28cc8cc2cc28cc8dc2dc58cc89c5ac034937907435493c93b433494cd2ab45bd46c37445cd4ac25cd5dccae2cc8ccd86cc8cc8cc89ccac
444b45b455445b35938444bd3cd399d4db48c47b44bc44c3564ccdccdd7ddcddc5eccdccdeccecbd349b4cb3a9349b49b37945b65d64bb3bedb9d596336e4dc3
b6bcedc7d95c6ccdc6d67ccccec8ec9c3b9bbeb3d949bb9ab4bb4bbfbce49bbbde98b3e63b6e6ec3e6366c6bc3966ccdc9d6bc6ccd6dcc6c59bb94b46b59bbb6
d9bb9bbd69b38946bb67b386366bc9d6bbbcdf68c67b6bcc6dcc4cc6cc75cc8c9bbbbeb9eb9bbb9db66b69bb98b6bb69bbbde6eb66bc6fc6db66bc6ac68b7bcc
bbc7ccc7cc77cc8c9abbadb9ab5abbb5dadbabbcadb69b6abb7cb6eb67bb7cb69bc7cb75bc6cb7bc75cb4b7bccbdc7ecabbbbebaebbabba4bb4b6abba6b78bb7
bb76bb5bb7bb74b66b67bb74b71b77bc79c77b77bc75c72baabba1ba1baabba1b72b7abba5b78b7abbaab7db77bb71b71b77bb71b71b77bb71b71b77bb71c73b
00280380320028038018008801801800881181411118148141111814814111181481411188118118004808807400480682720128168052112816816211281781
7211281781721128282212222221221202482e80d402481c809420241d22f221222f22122222212212222281d182181d87d161181d86d1bd04440d446402442a
40842124295292222d2bc2c212d82c819c12c82a81ac18dd8bd1bd18dd8bc15c02492c90b404454850741348378295225d29d14218dd8bc16212dd84d19c18cc
85c15c18cc85c15c05495a90a41445455545545546516d515e59d2bd22cd85c17d18dc85c28c28cc88c28c28cc88c29c0349389084434438447434444bd39445
dd56d44d24cd89c37d58cc87c57c8ccd89cc7cc8cc87cc8c034936906435495a93a4229b58d389334e57d3ae44cd4ccdadd4dccbd89c8ccdc8d87cc8cc88cc9c
249b47b279249b379364359d4bc3b934eb3ce346336ed6d3764ccecce49ccddeccec8dccdec8ec7d3399319319349b4eb3d933693693863369bad5b635665963
a63c6ecad69dccdec9ec5ccccec6ec7c3a9b9db389399b9ab3b9369bbce3794bbeb4e366396ccaf3d63c6f6ac386566cc5e6dc6ccecee60c99bb91b43b49bb95
b3569bbeb9e96b6bbeb5e67b69bc69d6ab69cbbce6bc66bc65c61c67cc7ec6bc99bba1b9fb9abb9cb65b69bb98b6abbbefa6d6db6abccaf6bb6cbf79b6ac67cb
bcc7dcc7cc75cc5c9abbadb9ab9abba7b94b6abba6b68babbfb4f75b67bb77b65b67cb76b68c77bc78c76b77bc73c71caabba1ba1baabba1ba1b7abba5b78b7a
bbaab7db77bb71b71b77bb71c7bb77bc79c76b77bc74c71caabba1ba1baabba1b72b7abba5b78b7abb7ab71b77bb71b71b77bb71b737777b74b757777b76b777
008801801800881180c802882c80a81188118118118811811811881181181188118118118811811800484540e802842d40c80188168118118811811811881181
18118811811811882182f222282f82f208482d80b402482a409812852d82e222282e82e222282f81ad12d82a81bd818c17c878818c87d19d4044084484024427
406422245782a5128d89c2b2188c28c28818dd89d19d18dd89d19d88cc81c81c02490a44a40444284545234829d2b4224d5782ed282c87c25218cd88c81c88cc
81c81c88cc81c81c05495990944455415415445541516e14e55ad1de18ec8dc26d28cc84c24c28cc84c25c88cc81c81c054927b4c42394394299239448d36445
dd5ce5bdd1de89c37ed8dcc9d8cc8ccdcbd8ac8ccdc9d88c444b4ab4a43549579384349d49d37934ed49d3ced3de286deddcdecde89c8cced7ecbdcddeebecdd
239954947b45b948d3d92369369286339e56f3de35e657646c3ceec9ed8dcdedcdec4dccdec4ec3d3399319319339991c3e9399c6cd3c9369dbae5965b6e6cc5
e6566ccbe3663c6ec4e66c6ccec7e69c399b97b389399b9ab36e596b97b5965bfeb3e98c6bde97c65c69cc68c57f66cdcae6ac6ccecbe6dc599b93b33999bd9e
c9db99bc9ac98bbbefbcf9acabcecaebafbcefc8fb5e6ccfc5f68c67cc7ac67c99bba1b9fb9abbbcf9cb9bbfa9c99b9abcb7f96c6abcc6fbafbcffc8f77b67bc
c6f78c67cc76c64c3a9ba4b9ab9abba7daebaabcadcabbaabcb8f75b7abcaac79b7cbf7bc7ab77bc78c75b77bc73c71caabba1ba1baabba1ba1b7abba5b78b7a
bbaab7db77bb71b71b677b74c7ab77bc78c76b77bc74c71caabba1ba1baabba1b72b7aab73ba5aa7aba4a7eb77bb71b737777b74b757777b75b767777b77b787
08888f80e802882d80b80288098858118811811811882181d812882d81d812882d81d812882d81d804884e80d804885c80a812882d81d812882d81d812882d81
d822282a82b222282b82b222281bc88804840b848440485881a815885a81a8188d2b817d12d827818d12d818c898818c18c88818dd86d17d04840884a4048458
816422485e8388228d28d278188c88c16818dd87d17d18dd87c81c88cc81c81c044447406440442c4484424425416e15e88ad2ad28dd8bc248288c83c81c88cc
81c81c88cc81c81c024927907444454c54a4444518e4a4414e27e1de484c85c25e88cc81c81c88cc81c81c88cc81c81c054946b4d423945c9495259d4ad25944
dd41d27612e687c29668dcc5e8cc8cce89c67d68dc87c68d43493794844349589354559d3be289d5d959e39e236eddedbddddecbe89c8ccec7e85c8ccec3ec1e
35995893893599589389356955959655695b95d64566d5e5d6d6ddc8e2762c6ec4ec1ecceec1ec1e939995b5a9349a4ca3c95b9ebae589396db8e496596c6ad5
a6566dc5e6cd6cdec6fceeccefcefcee499b96b469499b96d9ab59fbb8e47aabdea7d9ec9dcfcef9cc6adcccf6bdccefc8fc8e7ccec9e7ac999b95b45a49aba6
d9bb9abd99b77d6abda7d68b9acca9c66daccecbfa5dccffc1fc1f7ccecce7ec99ab94b94a4aaba7b47aaabdaada9babdfb7fa7daacca1ca1c7acca5c78c7acc
aac7dc676c73c71c9a9ba5b9599aaba4b6596a9ba6b6666a6b77b669679b75b666676b78c79b77bc77c75b677c73c737aaaba4ba4aaaaba4ba4a7aaba5b76aa7
ab76ba5a67ab75b657677b76b677677b78b6a7777c73c737aaaba4ba4aaaaba4b74a7aab75ba7a7abaaca7db77ab74b747777b75b767777b77b787777b79b7a7
08888d80c808888c80b880880788788188168858818815885881882581781288278178128827817804884b80b804884a80981288288188128828818812882882
622228278272222817c898818c19c88808894b807404484781982248588158228d2bd2a8228d19c8a8818c1ac89818dd84d14d18dd84d14d028948407824484b
82b4254856814e282d87d252288c88c26828dd86d27d28dd87e80c88cc81c81c084949404844585a84d445488ad485485d87d18e88cd88d8ac88cd8de8ec88ce
8fc81c88cc81c81c44444144144444414414444d2de4b448dd4bd2ae28ec8bc28e688c85c6488dce8dce4ee8ec84ce5e04493642f945495894a4249d4ad27944
de5ce45d226edbe89c8dced9e8ac8dce8ac67e68ec87c67e23993b92b923995b944d559e5b928625694b92e62466dce2b6dddec7e27e2ceec5e85ccedecaee3e
3499489399349999c5e9559f5bf589596d48635e4566cbe4c64c6ed9ec9ecdeeccee4eeceec3ee2e499b99b499349a49a39999bdb6e9cd99cd99c5df56fd6dd5
8f466dd4fc9e6ceec6e76d7ceec4e657499b98b48949ab99b4aa4baebae48a49aca6d9ac6add99c78d6dcfd5fc8f7cde6ae6ac66ce7be6bc999b96b96949ab98
b6899abda7d95babdfacda8cacdfdbfaac7adcc9f7bd7cdfc9f67667ec75c64e99aba6b9794aaba8b48aaabda8b6996b9fa8d78b6aaca6c65f6a6c78b6c6676c
7bc69667fc75c6479aaba7b97a9aaba6b96a6aaba7b69a6bafb8f68a67ab78b68f67fb78b69777ac76c677777c75c757aaaba6ba6aaaaba6ba6a7aaba6b77aa7
aba7a7cb77ab76b76a777b76b777777b78b797777c76c757aaaba6ba6aaaaba6ba6aa7ab79ba8a7aba7bb76a77ab76b757777b76b777777b78b797777b7ab7b7
08888b80b808888a8098808809889881881888888188188888818827821822882182182288218218048849808804882882182288218218228821821822882182
18228881818d818c1ac8a888dd81d81d08894a807804885782882588598298288d89c2c8288c8a828c828c89d81d88dd81d81d88dd81d81d0889498274244847
8274244888d5c8588d87d23888dd81d81d88dd81d81d88dd81e8ec88ce8ee8fc08494884d444484c84b444488bd484484d85d28e88cd86d88c88ce8ce8cc88ce
8de8ec88ce8fce6e48498c94d448492d9494289d2be299229e56e2de25ee8ec698688c88c678e8ec87ce7ee8ec87ce7e22992192192299219219259e5ce29944
de58e46e56e8dce27e8dced5e86c8dced6e86ce8ec87c69e2599569269459957945e45e947929659edd9e5795d9ed5e256ddeed1ed1e6c8ec7e658eceec6ee5e
349945936945a956947a599d95d236496d99d4e64466d1fdaeddefcaee7eeceec7ee6eceeecde65e499b3b9989349a46a3695a9d59f49a45af96c4af5dffdbf4
666ddf65e6ad6ceec9e77e7ceec6e76e999b99b4ba49ab9cb4ca49acacd96d5afda5d65daddfd8fa4c7ddf76d66d6cefc9f68e7ece7ce6ac999b98b9894aabab
b4ba699baada4baacda4c6a96a6da7d6a67adc7cd656676d7bd77c67ec77e7cc99aba8b9899a9ba8b6996a9baab6b99aac77b6a97a9ca7c68f6afc79b6e667fc
7ac68f677c78c6779aaba9b98a9aaba8b98a7a9ba8b6aa6aab7cb6ba67abfaf79b677b79b6b7677b7cc6a7777c77c777aaaba8ba8aaaaba8ba8aa7ab7aba9a7a
ba7ab78a77ab78b78a777b78b797777b79b7a7777c78c777aaaba9ba8aaaab78babaa7abaaa79b77ab78b78a77aba8b7a7777b78b797777b7ab7b7777b7bb7c7
0888898098088888807880881a88a881881a88a881882a88588288258848828824884828882e8838084887807408482788588288258858828824884882888482
8d28d889829d28d88a829c88dd81d81d0488468058048844823824885684b8288d89819e888c89c888888c87c86888dd81d81d88de8be8bd0889478474444846
8464444885d4a8488d86d42888de8de8dd88de8de8cd88ce8be8cc88ce8ce8dc08494684a424984a8289249887d86924e88bd66828ee8de89c88ce8ae8bc88ce
8be8cc88ce8dce8e48498994a448498a94b4289e6c84a448ed4be2ae26e86a828e688c8bc6a8e8ec89ce9ee8ec89ce9e28998d92d928994ee2e9249e4ae27924
9e54e4ce56e8678266e8ec89ce9ee8ec89ce9ee8ec89ceae449941923945995de4d94d9edce4a949ed4be4864668d9ee4eedeed4ee5eedeec5ee8eeceec7ee7e
499b4ea4e9449a9bd499499d95d46fe9ed45f4764dfe5afe8e6deec8ee9eeceec9ee8e6ceec9e68e93995b94ca45a99dd4da446a46f48a4afdabd4df4dffd9f4
6fedef64e66d6ceecce6be7ceec8e78e999b9bb9a949abaed4ea4aadaad46a9aeda4d66e6d9fa8d6be6dff76d67e67ed76c6be67ec7ae68c9a9babb9b99b9f9b
f98b9aada6d94a6aada6c6c96afd6896a666697cd67f666e7ee6e677ce79e7ac99ab9ab9aa9aabbaf9ba9aacaac99a6aada9d6ba7a9c69a686666a6bf6a66667
__gff__
c26c15151515151515151515151515156d351515156c34533453345353343453c29c28c28c27c26c25438439439439431539d38d37d36d35c59c28c27c26c25c84b5bb5cb5c93b93cd39d38d37d36c48dc6dc7dc8dcadcbdccb49b49b49b49b49db8db7db7db6db5dc7dc8dc9dcadcceceb48b48b48b48db9db9db8db7db7639
c96c95c95ecdc66c65b97b97b97b97ebcebcebbebbebbc96c96ca5c67c66c66c65b97b97b97b96b96b67b68b68b69b69b6aca6ca5c67c75c75b97b97ba7ba6fbcfbcb67b68b69b69b6ab6bb6bc75c75c75ba7ba7ba7ba7ba6ba6b76b77b77b78b78b79b79b79c76c76ba7ba7ba7ba7ba6b76b76b77b77b78b78b79b79b7ab7ab
__map__
b6676976c7b76c7aa9baba9baaa9baa97ab7aafb8a6baca6bad76bad76badf7fb7a6b7d76b7c76b7e76c7d77c7977c79aababaabaaaabaaaabaa7ababa7ab8a7bab77baa77baa77baa77fb877b7a77b7b77b7c77c7a77c7aaababaabaaaabaa7abaca7ab7a7ab877bab77baa77baa77baaa7b7b77b7a77b7b77b7c77b7d77b7e
808878088780886808860888c1888c2888928889828892888828888288888288a288878288b85887808468084628889288895888a5888a5888a818e6818e788c8a88c8988c8888c8788c8688dd188ed744881448814888348883488844888588d8888d8788d8688c8988c8888ed888ed888ed788ed788ed68098644844428958
498c8498e84e8c85e8888eda88ed988ed988ed888ed888ec988eca88eca88ecb8094528986859868598788d9a88d9884e4782ee982ee988ec788ec888ec988ec988eca8ded88ecea8494684947849478494882e9b829e944e8584eec86d8dd8ee8d8ee7c8eea668818eceb8eceb8eceb8599885998859988599884e9b44e9644
ee1648ebd6e8fd6e8cd6e898ecec8ecec8ecec8ecec8ecec4499144991449916489d4e9e644ea744fea648f9648f7deee8deee8deee9ceeebceeeaceee9ceee9499974999644a9b94e9b95e9899eda94e684efe44efe75efeadefe9defe9ecef6ecef7ecef8ecef85999c9599799d9994eae44fab49f95649fbd9fe9d9fe764e
f864ef466ee166ee166ee166ee1c7eea99b9d49a9894aada9d99649aa649a6649f5d6f9c66e9a66e97e7fd9e7fda66fecc7eecc7eeb76ec6a9b9da9b9c94aaaa9da9a9da896a9e66a9d66f9d66f9aa6e69a6e6b66fe676e6a77ec777ec777ec899baca9bada9baca9cacaada8aafd966a9866a9576dad66fa966fa566f7366f7
976d7e76c7e76c7da9bad9abac9abacaadabaacacaafb56aaa466aa166a7466a7766a7966a7c66771667716677177c7baabadaabacaabacaabac7abaca7ab7a7baca7bad77bac77bac76a7976a7b77b7c77c7c77c7c77c7caabadaabad7abaea7ab4a7ab57aaa977bad77bad77bac77a7477a77a7b7d77b7c77b7d77b7e77771
808858088580884808842888d2888d2888d2888c2888c2888c2888c5888e85884858845888e858842848d8488a48889488894888a4888b88d8b88d8a88d8988d8888c8a88c8988c8888c8788ed388ed3488844888548886488862898c48e8b28e8b28e8a28e8928e8888ed588ed488ed488ed388ed388ed22898828989849888
498a8498b84e8a84e8782e8588ed588ed588ed488ed488ed488ed388ee188ee18098384984849868498788d9b82e9782e9582ee682ee685ee582e6582e6582e6682e66668816688182995829958299582995849e7869898698b86e8a86e8b86e8d86e8e66881668818eced8ecede8ec58499a849998499898d9c849f784ea884
ef996e8c6e8e46e8e86e8eb8ecee8ecee8ecee8ecee8ecee8499d849a8849a8849a9e4e9ce4e9a94ee94e9eb4e9eddeeecdeeecdeeedceeedceeecceeebe6ed54999a4999849e9b94e9994e9699ed694ef94eaea4efe9aeded6eeea6eee86eee76eee5e6eee6eee24999c99d9d49f9c49f9a94ea8a9deca9dec96ee796ee996e
ec96eeee6fece6fef66ee166ee1c7eec49a9ea9d9d6999b6999969996a4ea796e9ce6f9ce6f99e6f96e7fd576eea76ee876ee577ed577ed499a9994aa694aa796a9896a9b96f987699b96f65a6ef8a6efae6ffa76efa76ef776e6677ec577ec6a9bafa9baf96aa496aa796aa996aab96faaa6eac769f6769fa6fffa76ffc76e7
a76e7b76e7d76e7fa9aad9aaa84aaad6a9ac6aaaa6aaa8a6fa876aaca6f76a6f78a6f7a76a7b76f7976f7c677796777baabafaabafaabae6aaae6aaaba6a756a7ab76aa876aa676a7576a7867a7b67a7d6777a6777c6777eaaaa1aaaa1aaaa17aaae7aaac7aaa97aaa777aa177aa177a7477a7777a7a77a7c777717777177771
888818888188881888818888188881888818888188881888818888188881888818888188881888814888a4888b4888c4888c8898d88e8d88e8b88e8928e8c28e8b28e8a28e8988ee188ee188ee188ee12898b2898b889888898a8898b88e8a88e8888e8688e8488e8288ee188ee188ee188ee188ee188ee18489988985889868
89878898884e8884e8588e8388ee188ee188ee188ee188ee188ee188ee188ee18899188991889838498588e9b88e9888e9586e8386e8486e8686e8886e8986e8b86e8c86e8e86e8f88991889918899186983869868698898eeb98eec8eee78eee98eeeb8eeed86ee98ecef8ecef8ecef84997899969899d98e9c98e9ae8e9be8
e998e9eb8e9ec8eeec8eeeeeeee1eeee1eeee1eeee1eeee18999a899999899b98e9998e9798ee596e87e4e96e4e94eeee1eeee1eeee1eeee1eeee1eeee1eeee18999c8999b89e9c9698794e9499ee19eee59eee89eeeaaeeedeefebeefebeefeaeefeaeefeaeefea4999f99e9d99e9a99e9799ea5a9eeda9eeae9feae9fe7e9f
e5eefe57eee87eee77eee5eeff1c7eef99a9e99f9d99f9ba9e99a9e9799fe6a9ee4eafedeafe9eafe5efff4e7fe97eee377ee177ee177ee199a9999a9699ead99fa999fa599ff1a7e95afef5e7f9b97fea77e977fef777fee76e7576e7676e7899aa199aa1a9fae97a9697a9997a9c97a9e779917f9f77f9fcffff16f7fd77fe
877fe877e7a77fe8a9aada9aaa9aaab9afac7a9abaafa6aaff1a7ff4a7ff67faf9a7ffca7ffe77ff177ff177e7d77e7faaaa1aaaa1aaaa17aaaf7aaac7aaa97aaa77aaa477aa177fad77a7777a7a77a7c77f7c7777177771aaaa1aaaa1aaaa17aaae7aaac7aaa97aaa777aa177aa177a7477a7777a7a77771777717777177771
0000100100100100100100100100111111111111111111111110f10d10b10910710410211111111111111111111111111130e30d10a10810510311111111111111111111111111111130c30b30b30a11111111111111111111131f31f31f31f31f30b30a30930831b31c31c31c31c31c31c31c31c31c31c31c30a30930830731
931931931931931931931931931a31a31ab0a307306306316316317317317317c19c18c18c17c16c15b09314314314314314314314314331c19c18c17c16c15c14331331331331331331331331c3cc3bc3ac17c16c15c14c13331331331b3cb3db3ec3fc3dc3cc3bc39c38c37c35c34c33b06b38b39b3ab3bb3bb3cb3dc3cc3a
c39c38c36c35c34c32b05b36b37b37b38b39b3ab3acbacb9cb8cb7cb6cb5cb3cc1b32b33b34b35b36b36cbdcbccbbcb9cb8cb7cb6cb5cb4cb3bb1bb1bb1bb1bb1cbecbdcbccbbcbacb9cb7cb6cb5cb4cb3bb1bb1bb1bb1bb1bb1bb1cbccbbcbacb9cb8cb7cb5cb4cb3bb1bb1bb1bb1bb1bb1bb1b73b74b74b75b75b76b76b77c
b400110e10b10920c20b80e80e11111111111111111111111150e10c10a10810610411111111111111111111111111111150d50d10910710510211111111111111111111111111111130c30b11111111111111111111131f31f31f31f31f31f31030b30a30931c31c31c31c31c31d31d31d31d31d31d31d31db0b31931a31a31
a31a31a31ac1cc1bc1ac19c18c17c16326317317317317317317317317c1bc1ac19c18c17c16c16c1531431431453d53d53d53d53d53ec1ac19c18c17c16c15c14331331331331331d3fd3ec3dc3cc3bc39c17c16c15c14c13331331b3cb3cb3db3ec3ec3dc3cc3ac39c38c36c35c34c32b15b38b39b3ab3bb3bb57b57c3bc3a
c39c37c36c35c33cc1b54b36b37b37b38b56b56cbbcbacb9cb8cb7cb5cb4cb3cc1b53b53b34b35dbedbdcbdcbbcbacb9cb8cb7cb6cb5cb4cb2bb1bb1bb1bb1bb1cbecbdcbccbbcbacb8cb7cb6cb5cb4cb3bb1bb1bb1bb1bb1b63b64b65b65b66cb9cb8cb6cb5cb4cb3bb1bb1bb1bb1bb1b73b74b74b75b75b75b76b76b77b77b
7820e20d20c20b20a20980d11111111111111111111111111120d20d20c10710510311111111111111111111111111111150c50b50b10610411111111111111111111111121021021050b50a11111111151f51f51f51f510510210210210e1de1d31d31d31d31d31d31d31dc1ec1dc1cc1bc1ad18d1832832831a31a31a31a31
a31b31bc1dc1cc1bc1ac19c18c17c16c15318318326326326326326326326c1ac19c18c17c16c15c1553b53b53b53b53b53b53b53bd3bd3ac19c18c17c16c15c1443d43d43d43dd3ed3dd3dd3cd3bc3ac39c17c16c15c14c13b1793eb58b58b59b59b59c3dc3bc3ac39c37c36c35c33cc1b56b57b57b57b57b58b58dbadb9c3a
c38c37c36c34cc1cc1b55b55b56b56b56dbcdbbdbbcbacb9cb8cb6cb5cb4cb3cc1b44b44b44dbedbddbdcbccbbcbacb9cb8cb7cb6cb4cb3cc1b94b94b94b93b64b64b65b66cbacb9cb8cb7cb6cb5cb4cb2ba4ba4ba4ba4b64b64b65b65b66b76b76b77b77b69cb4c72ba4ba4ba4ba4ba4b74b74b75b75b76b76b77b77b78b78b
7820c20c20b20a20920880c11111111111111121d21d21d21d20c20b20a20920820811121d21d21d21d21d21d21d21d21d50b50a50921d21d21d21d21d21d21d21d21d21d21d21d21d50a50950821d51c51c51c51d51d51d51d51d51ee1ce1ce1c51951a51a51a51a51a51bd1cd1bd1ad19d18d17329e1ce1c51851851832832
8328328328d1ac1bc1ac19c18c17c16c15327327538538538538538538538c1ac19c18c17c16c15c14539539539539539539d3bd3ad39d38c59c18c17c16c15c1443b43c43cb5ab5bd3cd3bd3ad39c59c58c57c56c25c24c23b59b59b59b59b59b5ab5a63c63cc3ac58c57c56c55dcedcfb57b58b58b58b58dbadbadb9db8db8
cb7cb6dccdcdcc1cc1b46b46b46b46dbcdbbdbadbacbacb8cb7cb6cb5cb4cc1cc1b45b95b95dbddbcdbcb66b67cbacb9cb8cb6cb5c64c63c73b95b95b95b94b65b65b66b66b67b68b68b69ca4c73c73c73ba5ba5ba5ba5ba4b74b75b75b76b76b77b77b78b78c74c73ba5ba5ba5ba5ba4b74b75b75b76b76b77b77b78b78b79b
7980d80d80c80c80c80b80b81e81e81e81e81e81e81e81e81e20b20a20920820720681e21a21a21a21a21a21a21a21a21a40b40b20921a21a21a21a21a21a21a21a21a21a21a21a21a50950850721a21a21a21a51a51a51a51a51be1ce1ce1be1b508507506517517518518d1ad19d19d18d17e1ce1be1be1b51551551551551
6329329d19d19d18d17d16c18c27c26c25536536536536536536536536c5cc2ac29c28c27c26c26c2543a43a43a43a43b43bd39d38d38c5ac59c27c27c26c25c24b5bb5bb5bb5bb5cb5cd3ad39d38c5ac59c58c56c25dccdcdb59b5ab5ab5ab5ab48db8db7db7db6c47dc9dcadcbdcddceb47b47b47b47b47dbadb9db8db8db7
c95c95dcbdccdcdc64b47b47b47b47dbbdbadbadb9ebbcb8c95c95c65c65c64c64b96b96b96b95ebdebdb67b67b68b69b69ca5ca4c65c74c74b96b96b95ba5b65b66b67b67b68b68b69b6ab6ac74c74c74ba6ba6ba6ba6ba5b75b76b76b76b77b77b78b78b79c75c75ba6ba6ba6ba6ba5b75b76b76b77b77b77b78b78b79b79b
7a80c80c80b80b80b80b80a81c81c81c81d81d81d81d81d81d20920920820720620581d81d81d21721721721721721721740a40920720621821821821821821821821821821821821840940921821821821821821832d32d32d32d32d32d32de1a41941941941a515515515515d18d17c2ac2ae1be1ae1ae1a51251251355155
__sfx__
7fbbfbab0936616e441c1460636727d430ba4139e5017e563ee532bb733ae562ce3109366299340c2460636727d430ba413965717e433b14636e50299332b25636a6326a341c2460736636d430ba423ae5027a53
80a80980299332b25636e532bd343c53707366369530ba423ae5028a533bd323765737d330b24737e5139d332b25707367379530ba423ae5028a533b1373765737d330b24737e5139d332b25737e533b90028250
214074071864001a421ac002825101a421ac002825101a431b800222302001504c002825101a421ac002260222011210121240222011210040262022011210121240222011210121240222011210121240222011
7c87c86c12d242c0151576212d252e01525372129672b8142e64121b71180042514212d20280151564212f642a8151c26202b632a8142c64208367066041554414d20071252513414565288153d52202b632a844
dc4dc5dc066141413303126364142413315f6318d252d5121d76111f651dc051d76111b230b36434e540c9230b36404f6434c651dc051d76111b651dd341cb6005a230b36434e540c9230b3641b76534e550d914
b9c98c972dd342cb730cf111964313e413ac112da331b76635e550cd31163750ab663ee542cb730cf111964313a513ac562ea532bb7139e440ce310936716a663c64606b6128d431be4139e5118e430ea532bb72
8ba8b78b0a3672a9342c64606b6128d431be4139e5018e430fa5336e512a9332b65636e542c9342c2560736737d431be423ae5128a530fa533bf7239a332b65636e542cd340c24707367379531be423ae5128a53
8198198138d330b64737e513ad332b65707b60389531be423ae5129a530ba4237e5038d331b64737e513ad332b65737e533c9001864000a41088000824001a4119c001864101a4119c001864101a411980018640
874054051864101a41198103877202a472f81038772220112101212402220112101212402220112101212402220112101212402220112100424130129262a0140476212f652c8152e26205a441cd200cb4008b60
1dd1dd1d01125280142866512f642a8150d6321236509a440ca4008367072251536414d230a1251524414567288153d5221236308a440ce3008367066140412303124354141d15414f61079251d5121d76111f65
d66d67ec11b231b76434e550d9231d35414f6011f651dc051d76111f651ec752db770ab230b36413e4139c111da311976514e453d02616765269352e9542cb720bf110924313e4039c111da311a765256261d626
6bb6bb6c2ea542cb720bf110924313e501ae561ee432bb6119e440ca4109767299343c65606b622ad432ba5139e5119e431ee432bb6119a333b266231662c9343c65606b622ad432be4139e5119e431fe433bf51
9ba9b78b36e552d9343c65607b60389532ba523ae5229a531fe433bf7138e570b26636e542dd341c64707b61389532ba523ae5229a531be4237e5039d331b25737e523bd333b26707b61399532ba523ae522aa53
82d82d8239d331b25737e523bd333b26737e543c9000824000a40078003853001a4018c000824101a4018c000866202a452d8000824001a4018c000866202a452d8101876202a452d8102837202a462e81018762
8744154f1876202a452e8102837202a462e8102835505a421a1041855505a23280141465205a431b9160e75222b6309a441ce4008b60082040412002124260143454214d632a8150d63208b6209a441ca4008b60
deddedde14d260d1250d36414f62089451d9201876403a440ca4008367072241547434e670f9251d75414f61079251d5141d3711df661ef652db751db232935515e421bd213666414f6115e662eb752db761df66
d69d6ad609f211964515e421ad450de311976615a350d52616766279660ee442cb710af113953313e4038c450de311a76625a352d53616f60299352ee442cb710af113953339e531ae443ce5109b6219e441d246
b8fb7fb73c26606b632bd433be5139e521ae432ce5109b6219a330b76636a662d9341c36606b642bd433ba5139a5237c123f9433bf7038a330b76636e552e9341c36607b61399533be523ae532aa532fa433bf70
6817817836e552ed342c25707b623a9533be523ae532aa532ba523ae5239d332b25737e533bd330b36707b623a9533be523ae532ba532ba5237e5139d332b25737e533bd330b36737e553d900385300024707800
85a85a8517c003853102a432b8103865202a432b8003853102a432b8103865202a432b8103865202a432c8100836202a442c8103865202a432b8103865202a442cc201864505a4119d201ca5008b6109e2028255
db44194d2825505a421a9163ce5008b620aa442ce4008b61082241440404121230141413222f6407a453d930183660aa441ce4008b60082241440404121011241d46414f6306a452dd201876504a450c94008b70
7ec8ec8e14e460f9252d36414b721ad261ea652db741bf663ee552db731bb213964515e411ad212666424d6415e660eb652db741bf663ee552cb7008f210924515e4119d450da411976716e670d3361637707b66
d6cd6dc609f11291331364737c451da411a767262260d24616f612a9353ea442cb7009f430bb6139e541be440cf5109b631ae441d25616f632c9351d76606b652cd430bf5139e531be440df421af70378331b376
7ab7ab7b2c37606b652dd433be512325636c123f9433b77737a542b27636a362113616406261613a9530bb623ae542ba533ca620ab632be572f93326a3621d343c65707b633b9530bb623ae542ba533be520af54
9829829837e533cd330c75707b633b9530bb623ae542ca533be523ae533ad333b65737e533cd330b76737e553e9002813000246068001813101246298101864202a41298101864202a412a8100864202a4129810
84e84e84298101864202a422a8102825202a42179101864205a4018d200824505a4018d200824508b630ba442ca5008b6209a202876404a450d9200836418f6209a450da40183670ba442ca5008b6109a2038774
d994a94a2876418f6108a450de301876606a451cd4008b61082241440404121019262e76424b74298161e24222377268450ed452db7119b213926414e450e9262e36424b7318d260e6352db7219f661ee452db71
cec7ec7e14e4319d2116264249731af662ea552db7219f661ee452c37707f213953515e4018d451da4119337091260ea552c37606b662ed342c37708f1119523136661ae452de4109f63272260fa553df622b935
6616616608f431bf6139a641de440cb611af6028e671623416f642d9352d77606b662ed431bb6139e541ca552da521af412b9310976616a3721136164062613121d430bb6123255368553da520af7436e572a566
7bb7bb7c1640636d362c9531bf623ae542ca530cf620ab642ba323a66626e362f1372776607b643c9531bf623ae552ca530cf620ab542ad333b26737e543dd331c36707b643c9531bf623ae552da530bb6226e50
9849848d37e543dd331b37737e563e9001852000245058103853202247278103853202247278103853202a40288103853202247278103853202247278103814202a4016d20281350524616d20281350524616920
94de4fe40ba452da5018f6108a443ce5008b620aa200836404a430b9203825418f620aa451de4018f6008a453c95008b6209a202876404a450c9200836418f6209a450da401876707a452d930183650922414404
c69479481e36424b73288163e53222376258161ed352d37717b212925414e430c9261e75424b7209d262e1352db7017f663ed352d37717b210964414e420b9271f36434b7318f660ea452db7017f663ed352c376
de6ee6fe156671be452de4119f7009d660ea452c37505b661e9342c37607f211913519f641be452de4134f71081263613426b722b9363e26626b752ed432bb7109b661de441cb6116e422bd670e65626b742c936
a6d76d7620d431bf6139e45269313954616e422b9310976616a36211361640626131219222a525256652ca550df5216a522a9323a26626e762d1372776636d332a9532bb723ae552da542cf6226a50299323a266
258258250775636d32299532bb723ae562da531a73626a50299322b26737e553dd332774636d30279532bb723ae562ea321a5272725638d321a25737e553dd332b37737531319001812002244258101852202245
9849d8bd0224525810281320224626810185220224525810185220224515d201dd5018f630aa452de4018f6008a201864404a40089200863418f640ca453da5018f6209a451da4018b600aa203825404a4209920
94a94be40ba452da5018f6108a450de301876706a200836404a430b9203e65406246279163e13222376258160dd302d375153241905414a730e9260e75424b72278162e13222375248160ed252d37515b2109644
6a944d9e0e35424b71089262e5222d37615f661ed252d37515b213914414e41099212f65424b7107d662e9352d37615f661ed252c37505b2129134146671ce453da5134f7209d662e13626376279360e64626b71
cf6df6f619f651ce453ee4134f71089363e53626b70299362e65626b732cd433bb7116645269313914616e412a9313e64626b722b9360e36626b752ed421932616645269313914616e412a9310976616e762a937
a7c7697621d422ae41246652da550db6226a50299323a26636f702a1370735636d3128d423a931296642ea321a13626a50299322a26636f302b1372764636d30269533bf723aa57239321a1362625729d321a257
8dd8dd8c0763636536259521ac022a25121e320a5272725638d321a25727a543dd3227707375313194018c000824101a4018c000824101a4018c000824101a4018c000824101a202813404245059201812404664
be8be89e18f640ba453da5018f6109a200863404247079202813428f640da450df5018f630aa452de4018f6108a201864404e400ca410eb6028b730aa461ea4006247289451da4018f6007a4119e4018e420aa41
9479489408a463e9302834529930182562d37313b413994018e4109a412e25424b7107a462ed202837423c663ec152d37313b4129d301864708a263e64424b70079261e1242d37413f663ec152d37321b2129134
6b9919631ea4124b70069261e9252d37421b761ec062e37121b2109524146661ce462ee412937716e460e12626375269362e53626b70299213dc7119b761ce463ee4129b7026a561e13626377279360e64626b72
8768767716644259313914616e412a9313fa463ef7027b773fd363e3772cd421af5139f751ce472fe4139f7016e471fd263e775279370f25636f742dd422ae412925716a561eb6226a5029d470f5163677526937
a7ca7d7726d423a93129254239321a1362667727a571fd1237773361370763636535249521ac022a25121a320a5272725638d321a25727a543dd373762636534319521ac022a25121e320a5272725638d321a257
8be8ae8917407375313194018c000824101a4018c000824101a4018c000824101a4018c000824101a201812404244049203ec7028b760da452df6018f650ca453de5018f620aa202813418e440da412ef6028b74
ae49e88e28b40279453da5018f6109a4129e5018e430ca410eb6028b730aa461ea402837706a300864606a412a94119e4018e420aa413ee5028b7108a463e9302837504a463e8102e37121b413994018e4109a41
e9de9ce907a462ed202837403a761ec062e37121b4129d301864708a410e24424377069260e9202e37121b761ec062e37121b4119d201864607e462ea412937716a761ec062e37121b761ec062e37121b4109124
7ba9da9b2ee412937716e460f9763ef762eb771ff663ef752df411ec7129b751ce463ee4129b7026a561fd563ef732ab772fa563ef722af4119c0139f761ce473fe412ab7127a770fa463ef7027b773e54727b72
9f7c763729e721ce472fe4139f7016e471fd263e77524b770e15727b733cd422ae412925716a561eb6217e7027a571fd073f77131f771e06727b753ed423a9312925413a571ff523af7127a571fd123777336d37
00100000319521ac022a25121e320a5272725638d321a25727a543dd322f37737531319521ac022a25121e320a5272725638d321a25727a543d53717407375313110000000000000000000000000000000000000
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
06 41 00 38 0b
03 00 28 0a 00
05 28 0a 00 18
06 1b 01 38 1b
03 01 38 1b 01
05 41 1c 01 44
04 1c 20 02 07
00 20 42 05 20
04 41 1b 01 44
06 1c 01 43 15
00 21 42 15 21
00 41 15 21 44
04 15 42 14 08
00 20 42 05 21
00 41 15 21 44
00 15 21 43 15
00 21 42 15 22
00 12 21 22 12
04 21 42 04 08
00 41 42 15 21
00 41 2b 43 35
04 2b 42 43 2c
02 41 42 2d 44
05 41 2e 43 1e
04 19 42 04 17
02 41 05 26 44
00 41 27 43 44
06 28 42 43 2c
03 41 3c 2a 44
05 1c 28 43 1e
00 19 42 15 44
00 41 15 43 44
00 15 42 43 15
02 41 42 43 2b
03 41 2c 29 44
05 1c 28 43 44
01 41 42 43 37
00 41 42 37 44
05 0d 42 43 44
02 41 42 43 14
01 41 3c 29 44
05 0c 27 43 44
01 05 42 43 37
02 41 04 38 44
05 0d 37 43 44
02 36 42 43 34
05 41 3d 43 44
06 41 42 43 1c
07 05 34 3b 44
03 34 3b 43 34
05 3b 42 43 44
03 35 42 43 34
05 41 42 43 44
06 41 42 43 2d
07 41 34 2b 44
03 34 2b 43 34
07 2d 37 43 44
03 36 42 43 34
05 41 42 43 44
07 0e 42 43 44
07 41 34 1b 44
03 34 1a 3b 23
07 3d 38 43 44
04 39 42 1c 17
