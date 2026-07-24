pico-8 cartridge // http://www.pico-8.com
version 29
__lua__

cls()
--split str [separator] [convert_numbers] 
	


function build_num_table(s,zero)
	local t={}
	local offset=0
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


function color_compare(rgb1,rgb2)
	--use ccir luminosity
	local luma1 = rgb1[1]*.299+rgb1[2]*.587+rgb1[3]*.114
	local luma2 = rgb2[1]*.299+rgb2[2]*.587+rgb2[3]*.114
	local lumadiff=luma1-luma2
	local diff = vec3_sub(rgb1,rgb2)
	return abs((diff[1]*diff[1]*0.299 + diff[2]*diff[2]*.587 + diff[3]*diff[3]*.114)*.75+lumadiff*lumadiff)
end	

function get_ordered_pixel(x,y,color)
	local k_bscale=.5
	local k_contrast=.35
	local bayer_threshold= bayer[x%8+1][y%8+1]/64*k_bscale-k_bscale/2
	local red_target =	 	mid(color[1]*(1+k_contrast)-k_contrast/2 + bayer_threshold ,0,1)
	local green_target = 	mid(color[2]*(1+k_contrast)-k_contrast/2 + bayer_threshold ,0,1)
	local blue_target =     mid(color[3]*(1+k_contrast)-k_contrast/2 + bayer_threshold ,0,1)
	local closest_i=0
	local dist=100
	for i, palette_color in pairs(pico_palette) do
		local d = color_compare({red_target,green_target,blue_target},palette_color)--vec3_length(vec3_sub(rgb,))
		if(d<dist)then closest_i=i dist=d end
	end
	return closest_i

end

-----------------quick color---------------------------------------------------
function load_quick_color()
	memcpy(0x2000,0x0000,128)
end
load_quick_color()

function put_quick_color(x,y,v)
	local v=band(shl(v,4),0xffff)+0x2000
	local offset=x\2+y*64
	poke(offset,@v)
	poke(offset+64,@(v+64))

end 

t1=stat(1)
for i=0,127,2 do
	for j=0,127, 2 do
		 put_quick_color(i,j,mid(sin(j/64)*.5+i/127,0,1))
	end
end

--------------------------misc utility
function normalize(x,y,z)
	local length=1/sqrt(x*x+y*y+z*z)
	return x*length,y*length,z*length
end


function vec3_dot(a,b)
	return a[1]*b[1]+a[2]*b[2]+a[3]*b[3]
end

function vec3_unit(v)
	local x1=shr(v[1],2)
	local y1=shr(v[2],2)
	local z1=shr(v[3],2)
	local inv_dist=1/sqrt(x1*x1+y1*y1+z1*z1)
	return {x1*inv_dist,y1*inv_dist,z1*inv_dist}
end

function vec3_length(v)
	local x1=shr(v[1],2)
	local y1=shr(v[2],2)
	local z1=shr(v[3],2)
	return sqrt(x1*x1+y1*y1+z1*z1)
end

function vec3_abs(v)
	return {abs(v[1]),abs(v[2]),abs(v[3])}
end

function vec3_max(v,d)
	return {max(v[1],d),max(v[2],d),max(v[3],3)}

end

function vec3_flr(a)
	return {flr(a[1]),flr(a[2]),flr(a[3])}
end

function vec3_flip(a)
	return {-a[1],-a[2],-a[3]}
end

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

----------------------------------matrix functions----------------------


function create_identity()
	return{{1,0,0},{0,1,0},{0,0,1}}
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

return {{src1[1][1] * src2[1][1] + src1[1][2] * src2[2][1] + src1[1][3] * src2[3][1] , 
	     src1[1][1] * src2[1][2] + src1[1][2] * src2[2][2] + src1[1][3] * src2[3][2]  , 
         src1[1][1] * src2[1][3] + src1[1][2] * src2[2][3] + src1[1][3] * src2[3][3]  , 
       }, 
       {src1[2][1] * src2[1][1] + src1[2][2] * src2[2][1] + src1[2][3] * src2[3][1]   ,
        src1[2][1] * src2[1][2] + src1[2][2] * src2[2][2] + src1[2][3] * src2[3][2]  , 
        src1[2][1] * src2[1][3] + src1[2][2] * src2[2][3] + src1[2][3] * src2[3][3]  , 
        },
       {src1[3][1] * src2[1][1] + src1[3][2] * src2[2][1] + src1[3][3] * src2[3][1]  , 
        src1[3][1] * src2[1][2] + src1[3][2] * src2[2][2] + src1[3][3] * src2[3][2]   ,
        src1[3][1] * src2[1][3] + src1[3][2] * src2[2][3] + src1[3][3] * src2[3][3]   ,
        }}

end

function transform_vector(v,m)

	--local inv_w= 1/(v[1]*m[1][4]+v[2]*m[2][4]+v[3]*m[3][4]+v[4]*m[4][4])

	return (v[1]*m[1][1]+v[2]*m[2][1]+v[3]*m[3][1]),
		   (v[1]*m[1][2]+v[2]*m[2][2]+v[3]*m[3][2]),
		   (v[1]*m[1][3]+v[2]*m[2][3]+v[3]*m[3][3])

end

function vec3_transform(v,m)
	return {(v[1]*m[1][1]+v[2]*m[2][1]+v[3]*m[3][1]),
		   (v[1]*m[1][2]+v[2]*m[2][2]+v[3]*m[3][2] ),
		   (v[1]*m[1][3]+v[2]*m[2][3]+v[3]*m[3][3] )}
end

function inverse_matrix(m)
	local invdet = 1/(m[1][ 1] * (m[2][ 2] * m[3][ 3] - m[3][ 2] * m[2][ 3]) -
					  m[1][ 2] * (m[2][ 1] * m[3][ 3] - m[2][ 3] * m[3][ 1]) +
				      m[1][ 3] * (m[2][ 1] * m[3][ 2] - m[2][ 2] * m[3][ 1]))


	return{{(m[2][ 2] * m[3][ 3] - m[3][ 2] * m[2][ 3])*invdet,
			(m[1][ 3] * m[3][ 2] - m[1][ 2] * m[3][ 3])*invdet,
			(m[1][ 2] * m[2][ 3] - m[1][ 3] * m[2][ 2])*invdet},{
			(m[2][ 3] * m[3][ 1] - m[2][ 1] * m[3][ 3])*invdet,
			(m[1][ 1] * m[3][ 3] - m[1][ 3] * m[3][ 1])*invdet,
			(m[2][ 1] * m[1][ 3] - m[1][ 1] * m[2][ 3])*invdet},{
			(m[2][ 1] * m[3][ 2] - m[3][ 1] * m[2][ 2])*invdet,
			(m[3][ 1] * m[1][ 2] - m[1][ 1] * m[3][ 2])*invdet,
			(m[1][ 1] * m[2][ 2] - m[2][ 1] * m[1][ 2])*invdet}}
end

----------------------------------raymarching functions---------------------



--color modes
k_normal_render=1
k_quick_render=2
k_high_render=3
render_mode=k_normal_render

function generate_ray(sx,sy)

	local cam_vx,cam_vy,cam_vz=vec3_transform({1,0,0},view_matrix),vec3_transform({0,1,0},view_matrix),vec3_transform({0,0,1},view_matrix)
	local vx=shr(sx-64,6)	
	local view_vx=vec3_scale(cam_vx,vx)	
	local vx2=vx*vx
	local vy=shr(sy-64,6)			
	local view_vy=vec3_scale(cam_vy,vy)		
	local ray_dir=vec3_unit(vec3_add(vec3_add(view_vx,view_vy),cam_vz))
	return cam_x,cam_y,cam_z,ray_dir[1],ray_dir[2],ray_dir[3]
end

function update_camera()
	view_matrix=create_identity()
	view_matrix=matrix_multiply(view_matrix,create_x_rotate(cam_ax))
	view_matrix=matrix_multiply(view_matrix,create_y_rotate(cam_ay))
	view_matrix=matrix_multiply(view_matrix,create_z_rotate(cam_az))
end

cur_col=0
function render_scene()
	--flip()
	local cam_x,cam_y,cam_z,skip_step,step1=cam_x,cam_y,cam_z,skip_step,skip_step-1
	local px,py,pz,depth
	update_camera()
	--local cam_vx,cam_vy,cam_vz=vec3_transform({1,0,0},view_matrix),vec3_transform({0,1,0},view_matrix),vec3_transform({0,0,1},view_matrix)

	if(render_mode!=k_high_render)then
		for sx=0,127,skip_step do
			cur_col=sx
			--local vx=shr(sx-64,6)	
			--local view_vx=vec3_scale(cam_vx,vx)	
			--local vx2=vx*vx

			for sy=0,127,skip_step do		
				--local vy=shr(sy-64,6)			
				--local view_vy=vec3_scale(cam_vy,vy)		
				--local ray_dir=vec3_unit(vec3_add(vec3_add(view_vx,view_vy),cam_vz))
				
				
				
				if(render_mode==k_normal_render)then
				
				--local rgb = trace_ray(cam_x,cam_y,cam_z,ray_dir[1],ray_dir[2],ray_dir[3])
				local cam_x,cam_y,cam_z,rx,ry,rz=generate_ray(sx,sy)
				local rgb = trace_ray(cam_x,cam_y,cam_z,rx,ry,rz)

				for i=0,step1 do
					for j=0,step1 do
						local color = get_ordered_pixel(sx+i,sy+j,rgb)
						sset(sx+i,sy+j,color)
					end 
				end
				
				elseif(render_mode==k_quick_render)then
					local cam_x,cam_y,cam_z,rx,ry,rz=generate_ray(sx,sy)
					local v= quick_trace_ray(cam_x,cam_y,cam_z,rx,ry,rz)
					for i=0,step1,2 do
						for j=0,step1,2 do
						put_quick_color(sx+i,sy+j,v)
						end
					end
				end
				

				if(stat(1)>.75)yield()
				end	
		end
	elseif(render_mode==k_high_render)then
		--anti-aliasing
		--2x2 sample per pixel
		for sx=0,127 do
			cur_col=sx
			

			for sy=0,127 do
				
				local avg_rgb={0,0,0}
				for i=0,.5,.5 do
					for j=0,.5,.5 do
			

						local cam_x,cam_y,cam_z,rx,ry,rz=generate_ray(sx+i,sy+j)
	
						local rgb = trace_ray(cam_x,cam_y,cam_z,rx,ry,rz)
						avg_rgb = vec3_add(avg_rgb,rgb)
					end
				end
				avg_rgb=vec3_div(avg_rgb,4)
				local color = get_ordered_pixel(sx,sy,avg_rgb)
				sset(sx,sy,color)
				if(stat(1)>.75)yield()
			end
		end
	
	
	end
	

end

function fill_rgb(x1,y1,x2,y2,rgb)
	rectfill(x1,y1,x2,y2,shades[7][ band(shl((rgb[1]*.25+rgb[2]*.6+rgb[3]*.15),8),0xffff)])
end	



function trace_ray(x,y,z,vx,vy,vz,count)


	local count= count or 0
	
	--	if(count>5)return {1,1,1}
	local depth,light_x,light_y,light_z=0,light_x,light_y,light_z

	--local dist=0
	--local px,py,pz = x,y,z
	
	local sky_blend = mid(-vy,0,1)
	local mix_sky_color=vec3_add(vec3_scale(sky_color,1-sky_blend),vec3_scale(sky_color2,sky_blend))
	local rgb-- = {1,1,1}
	--local spec={0,0,0}
	
	for i=0,500 do
		
		local px,py,pz=x+vx*depth,y+vy*depth,z+vz*depth
		local dist,obj=scene_sdf(px,py,pz)
		--local dist=dm[1]
		
		if(dist<0.001)then
			local m=material_list[obj.material]
			
			
			local color=m.color
			
			if(m.pattern!=nil) color=get_pattern(px,py,pz,m.pattern)

			if(m.noshade==true)then
				rgb=color
				
			else	
				local mirror=m.mirror
				
				--local nx,ny,nz=estimate_normal(px,py,pz)
				--inline estimate normal
				local nx=dist-scene_sdf(px-.03,py,pz)
				local ny=dist-scene_sdf(px,py-.03,pz)
				local nz=dist-scene_sdf(px,py,pz-.03)
				local length=1/sqrt(nx*nx+ny*ny+nz*nz)
				nx*=length
				ny*=length
				nz*=length
				
				--handle refraction
				

				local diffuse = mid(nx*light_x+ny*light_y+nz*light_z,0,1)*.5+.5
				
				
				if(m.specularity!=nil)then
					local gloss = m.gloss or 4
					local shiny = m.shiny or .75
					local scale=2*(nx*light_x+ny*light_y+nz*light_z)
					--local specular = mid(((light_x-nx*scale)*vx+(light_y-ny*scale)*vy+(light_z-nz*scale)*vz*.8),0,1)^gloss*m.specularity
					local specular = mid(((light_x-nx*scale)*vx+(light_y-ny*scale)*vy+(light_z-nz*scale)*vz)*shiny,0,1)^gloss*m.specularity
					spec={specular,specular,specular}
				end

				local shadow = soft_shadow(px,py,pz,light_x,light_y,light_z)
				--inline soft shadow (not worth inlining)
				if(m.subsurface!=nil and count<4)shadow=shadow*(1-m.subsurface)+m.subsurface
				
				local occlusion = ambient_occlusion(px,py,pz,nx,ny,nz)
				--inline occlusion not worth it

				 rgb=vec3_scale(color,(diffuse*occlusion))
				 
				 
				 
				 
				 rgb=vec3_scale(rgb,(.3+.7*shadow))
				
				
				
				if(m.transparent!=nil and m.transparent>0 and count<12)then
					--m.color={1,1,1}
					--m.transparent=1
					--m.n=1.5
					--trace until we exit an object
					--this will not work if the object is intersecting something!
					local int_depth,px,py,pz=-.05, px,py,pz
	
	
					local t_vec=  {vx,vy,vz}
					--if(m.n==nil)m.n=1
					if(m.n!=nil)t_vec=refract_vector_v2(1,m.n,{nx,ny,nz},{vx,vy,vz})
					
					for i=0,20 do
					 --lpx,lpy,lpz=px-vx*int_depth,py-vy*int_depth,pz-vz*int_depth
					 --lpx,lpy,lpz = transform_vector({lpx,lpy,lpz},obj.t_matrix)
					 
					  lpx,lpy,lpz=px-t_vec[1]*int_depth,py-t_vec[2]*int_depth,pz-t_vec[3]*int_depth
					  tlpx,tlpy,tlpz=lpx,lpy,lpz
					 if(obj.t_matrix!=nil)tlpx,tlpy,tlpz=transform_vector({lpx+obj.x,lpy+obj.y,lpz+obj.z},obj.t_matrix)
					--	
					-- if(obj.t_matrix!=nil) 
					 local int_dist=obj.sdf(tlpx,tlpy,tlpz,obj.params)
					 int_depth+=int_dist
					 if(int_dist>.001)break
					end
					--
					--px,py,pz=lpx,lpy,lpz
					
					local tnx,tny,tnz=estimate_normal(lpx,lpy,lpz)
					if(m.n!=nil)e_vec=  refract_vector_v2(m.n,1,vec3_flip({tnx,tny,tnz}),t_vec)
					local clear_rgb
					if(e_vec==false)then
						--total internal reflection
						--yeah just gonna fake this and continue straight through
						clear_rgb=(trace_ray(lpx+tnx*.01,lpy+tny*.01,lpz+tnz*.01,t_vec[1],t_vec[2],t_vec[3],count+1))
					else
						clear_rgb=(trace_ray(lpx+tnx*.01,lpy+tny*.01,lpz+tnz*.01,e_vec[1],e_vec[2],e_vec[3],count+1))
					end
						clear_rgb = vec3_mult(clear_rgb,color)
						rgb=vec3_add(vec3_scale(rgb,1-m.transparent),vec3_scale(clear_rgb,m.transparent))
					
				end

				 
				
				--if mirror (mirror is expensive)
				if(mirror!=nil and mirror>0 and count<6)then
					local reflect = vec3_sub({vx,vy,vz},vec3_scale({nx,ny,nz}, 2*vec3_dot({nx,ny,nz},{vx,vy,vz})))
					local rgb2=trace_ray(px+nx*.1,py+ny*.1,pz+nz*.1,reflect[1],reflect[2],reflect[3],count+1)
					rgb=vec3_add(vec3_scale(rgb,1-mirror),vec3_scale(rgb2,mirror))
				end

				if(m.subsurface!=nil and count<4)then
				 	rgb=vec3_add(vec3_scale(rgb,1-m.subsurface),vec3_scale(trace_ray(px+vx*.1,py+vy*.1,pz+vz*.1,vx,vy,vz,count+1),m.subsurface))
				 	--rgb=vec3_mult(rgb,trace_ray(px+vx*.1,py+vy*.1,pz+vz*.1,vx,vy,vz,count+1))
					end
				rgb=vec3_add(rgb,spec)

			end
				--end shading
			
			
			--apply fog
			local fog_amount=1-mid(2-2^(depth/50),0,1)
			
			local sun_ammount= mid(vec3_dot({vx,vy,vz},{light_x,light_y,light_z}),0,1)
			bg_color=vec3_add(vec3_scale(mix_sky_color,1-sun_ammount),vec3_scale(sun_color,sun_ammount))
			rgb=vec3_add(vec3_scale(rgb,1-fog_amount),vec3_scale(bg_color,fog_amount))
			
			
			
			
			

			return rgb
			
		end

		depth+=dist
	
		if(depth>100)break
		
	end
	

	
	local sun_ammount= mid(vec3_dot({vx,vy,vz},{light_x,light_y,light_z}),0,1)
	sun_ammount=sun_ammount*sun_ammount
	return vec3_add(vec3_scale(mix_sky_color,1-sun_ammount),vec3_scale(sun_color,sun_ammount))
	
end

function quick_trace_ray(x,y,z,vx,vy,vz)

	local depth=0

	for i=0,128 do
		
		local px,py,pz=x+vx*depth,y+vy*depth,z+vz*depth
	
		local dist,obj=scene_sdf(px,py,pz)

		if(dist<0.001)then

			--return depth%1
			
			local nx,ny,nz=dist-scene_sdf(px-.03,py,pz),dist-scene_sdf(px,py-.03,pz),dist-scene_sdf(px,py,pz-.03)
			local length=1/sqrt(nx*nx+ny*ny+nz*nz)
			nx*=length
			ny*=length
			nz*=length
			return  mid(nx*light_x+ny*light_y+nz*light_z,0,1)*.5+.5,obj
			
			
		end

		depth+=dist
		if(depth>50)break
		
	end
	
	return abs(.5-vy*.5),nil
end





function refract_vector_v2(n1,n2,normal,i)
	local n=n1/n2
	local cosi=-vec3_dot(normal,i)
	local sint2 = n*n*(1-cosi*cosi)
	if(sint2>1)return i -- in case of tir, just keep going
	return vec3_add(vec3_scale(i,n),vec3_scale(normal,n*cosi-sqrt(1-sint2)))
	

end


function soft_shadow(x,y,z,vx,vy,vz)
	local res,t=1,0.25
	for s=0,8 do
		local h=scene_sdf(x+vx*t,y+vy*t,z+vz*t)
		if(h<.01)return 0
		res = min(res,2.0*h/t)
		t+=h
		if(t>50)return res
	
	end
	return res

end

function ambient_occlusion(x,y,z,nx,ny,nz)
	local steps,delta,a,weight = 3,.5,0,.75
	for i=1,steps do
		d=i/steps*delta
		a+=weight*(d-scene_sdf(x+nx*d,y+ny*d,z+nz*d))
		weight*=.5
	end
	return mid(1-a,0,1)
end


function union(dm1,dm2)
	if(dm1<dm2)return dm1
	return dm2
end



function estimate_normal(px,py,pz)

	local d,nx,ny,nz=scene_sdf(px,py,pz)
	local nx,ny,nz=d-scene_sdf(px-.03,py,pz),d-scene_sdf(px,py-.03,pz),d-scene_sdf(px,py,pz-.03)
	local length=1/sqrt(nx*nx+ny*ny+nz*nz)
	return nx*length,ny*length,nz*length

end

---------------------------------------------------------------------------------
function init_rand_list()
	rand_list={}
	for i=0,0xfff do
		local v=rnd(1)
		rand_list[i]=v
	end
end


function cubic_interpolate_2d_noise(x,y,scale)
	x/=scale
	y/=scale
	

	local xl=band(x,0xffff)--flr(x)
	local xr=xl+1
	local xl1,xr1=(xl-1)*31,(xr+1)*31
	
	xl*=31
	xr*=31

	
	
	
	local yl=band(y,0xffff)--flr(y)
	local yr=yl+1
	local yl1,yr1=(yl-1)*37,(yr+1)*37

	
	yl*=37
	yr*=37

	local dx,dy=band(x,0x.ffff),band(y,0x.ffff)--%1
	
	local rand_list=rand_list
	
	
	local a,b,c,d=rand_list[band(xl1+yl1,0x0fff)],rand_list[band(xl+yl1,0x0fff)],rand_list[band(xr+yl1,0x0fff)],rand_list[band(xr1+yl1,0x0fff)]--rand_3d(xl,yl,zl)
	

		local mu2,a0=dx*dx,d-c-a+b
		local m=(a0*dx*mu2+(a-b-a0)*mu2+(c-a)*dx+b)

	
	
	a=rand_list[band(xl1+yl,0x0fff)]--rand_3d(xl,yl,zl)
	b=rand_list[band(xl+yl,0x0fff)]--rand_3d(xl,yl,zl)
	c=rand_list[band(xr+yl,0x0fff)]--rand_3d(xl,yl,zl)
	d=rand_list[band(xr1+yl,0x0fff)]--rand_3d(xl,yl,zl)
		
		 a0=d-c-a+b
		local n=(a0*dx*mu2+(a-b-a0)*mu2+(c-a)*dx+b)
	
	a=rand_list[band(xl1+yr,0x0fff)]--rand_3d(xl,yl,zl)
	b=rand_list[band(xl+yr,0x0fff)]--rand_3d(xl,yl,zl)
	c=rand_list[band(xr+yr,0x0fff)]--rand_3d(xl,yl,zl)
	d=rand_list[band(xr1+yr,0x0fff)]--rand_3d(xl,yl,zl)
	

		 a0=d-c-a+b
		local o=(a0*dx*mu2+(a-b-a0)*mu2+(c-a)*dx+b)
	
	 a=rand_list[band(xl1+yr1,0xfff)]--rand_3d(xl,yl,zl)
	 b=rand_list[band(xl+yr1,0xfff)]--rand_3d(xl,yl,zl)
	 c=rand_list[band(xr+yr1,0xfff)]--rand_3d(xl,yl,zl)
	 d=rand_list[band(xr1+yr1,0xfff)]--rand_3d(xl,yl,zl)
		
	a0=d-c-a+b
	local p=(a0*dx*mu2+(a-b-a0)*mu2+(c-a)*dx+b)

	 mu2=dy*dy
	 a0=p-o-m+n
	return(a0*dy*mu2+(m-n-a0)*mu2+(o-m)*dy+n)
	
	
end




---------------------------------------------------------------------------------
function sphere_sdf(px,py,pz,params)

	return sqrt(px*px+py*py+pz*pz)-params[1]
	--return abs(px)+abs(py)+abs(pz)-1
end


function plane_sdf(px,py,pz,params)
	return -(py)
end

function box_sdf(px,py,pz,params)

	local qx,qy,qz=abs(px)-params[1],abs(py)-params[2],abs(pz)-params[3]
	local lx,ly,lz=max(qx,0),max(qy,0),max(qz,0)

	
	return vec3_length( {lx,ly,lz})+ min(max(qx,max(qy,qz))-.5,0)
	
end

function cone_sdf(px,py,pz,params)

	local r,h=params[1],params[2]
	local qx,qy=sqrt(px*px+pz*pz),py
	local tipx,tipy=qx,qy-h
	local mdirl = sqrt(h*h+r*r)
	local mdirx,mdiry=h/mdirl,r/mdirl
	local mantle = tipx*mdirx+tipy*mdiry
	local d = max(mantle,-qy)
	local projected = tipx*mdiry-tipy*mdirx
	if(qy>h and projected<0)then
		d=max(d,sqrt(tipx*tipx+tipy*tipy))
	end
	
	if(qx>r and projected>sqrt(h*h+r*r))then
		local dx=qx-r
		local dy=qy
		d=max(d,sqrt(dx*dx+dy*dy))
	end
	
	
	
	return d
end




function box_cheap_sdf(px,py,pz,params) 
	return max(max(abs(px)-params[1],abs(py)-params[2]),abs(pz)-params[3])
end

function cylinder_sdf(px,py,pz, params)
	local d = sqrt(px*px+pz*pz) - params[1]
	return max(d, abs(py) - params[2])
	
end

function torus_sdf(px,py,pz,params)
	local length=sqrt(px*px+pz*pz)
	local qx=length-params[1]
	local qy=py
	return sqrt(qx*qx+qy*qy)-params[2]
	
end

function sponge_sdf(px,py,pz,params)
	local d=box_cheap_sdf(px,py,pz,{1,1,1})
	local s=params[1]*2--params[1]
	local scale=params[2]*3.75*2
	--local scale=4
	
	for i=1,flr(params[3]*4+.5) do
		local ax,ay,az=(px*s)%2-1,(py*s)%2-1,(pz*s)%2-1

		s*=scale 
		
		local rx,ry,rz=abs(1-scale*abs(ax)),abs(1-scale*abs(ay)),abs(1-scale*abs(az))

		
		 da = max(rx,ry)
		 db = max(ry,rz)
		 dc = max(rz,rx)
		 c= (min(da,min(db,dc))-1)/s
		 d=max(d,c)
		
	
	end
	
	return d
	
end

function height_map_sdf(px,py,pz,params)

	local d=cubic_interpolate_2d_noise(px+params[4]*40,pz,3.5)*params[1]*2
	+cubic_interpolate_2d_noise(px+params[5]*90,pz,1.25)*params[2]*.175*2
	+cubic_interpolate_2d_noise(px,pz+params[6]*500,.25)*params[3]*.025*2
	d=d*d*6
	
	return (-py-d+3)*.40
end

sdf_list={
{sdf=box_cheap_sdf,name="box",params={"w","h","d"}},
{sdf=sphere_sdf,name="sphere",params={"r"}},
{sdf=torus_sdf,name="torus",params={"r1","r2"}},
{sdf=cylinder_sdf,name="cylinder",params={"r1","h"}},
{sdf=plane_sdf,name="plane",params={}},
{sdf=cone_sdf,name="cone",params={"r","h"}},
{sdf=sponge_sdf,name="sponge",params={"a","b","c"}},
{sdf=height_map_sdf,name="terrain",params={"o1","o2","o3","tx","ty","tz"}},

}


function subtract(sdf1,sdf2)
	return(max(sdf1,-sdf2))
end


a=.3
sa=sin(a)
ca=cos(a)
function get_pattern(px,py,pz,pattern)
	
	if(pattern=="tile")then
		local u,v=px*ca-pz*sa,pz*ca+px*sa
		 u=flr(u/1.5)
		 v=flr(v/1.5)
		if( (u+v)%2==0)then
			return {1,1,1}
		else
			return {.2,.2,.2}
		end
	elseif( pattern=="wood")then
			px+=sin(px*2)*.05
			py+=sin(py*2.5)*.02
			
		local d=sin(sqrt(px*px+py*py)*7)*.5+.5
		d=d^3
		--d=flr(d+.5)
			
		return vec3_add(vec3_scale({.7,.5,.3},1-d),vec3_scale({.5,.3,.15},d))
	end


end





material_list={
{color={1,1,1},specularity=.5,gloss=2,shiny=.5},
{color={1,.25,.25},specularity=.9,gloss=2,shiny=.5},
{color={.20,.7,.25},specularity=.9,gloss=2,shiny=.5},
{color={.20,.35,1},specularity=.9,gloss=2,shiny=.5},
{color={.75,.75,0},specularity=.9,gloss=2,shiny=.5},
{color={.25,.75,1},specularity=.9,gloss=2,shiny=.5},
{color={.5,0,1},specularity=.9,gloss=2,shiny=.5},
{color={1,.5,0},specularity=.9,gloss=2,shiny=.5},
{color={.05,.05,.05},specularity=.5,gloss=2,shiny=.5},
{color={1,1,1},specularity=.5,gloss=2,shiny=.5,mirror=.75},
{color={.125,.125,.125},specularity=.5,gloss=2,shiny=.5,mirror=.75},
--{color={1,.7,.7},transparent=.6,mirror=.2,n=1.5},
{color={0,0,1},specularity=.5,gloss=4,shiny=.8,pattern="wood"},
{color={.5,.5,.5},specularity=.5,gloss=4,shiny=.75,pattern="tile",noshade=false,mirror=.25},
{color={1,1,1},specularity=.5,gloss=2,shiny=.5,transparent=1,n=1.5},
}




object_list={}
function new_object(sdf_index,material,x,y,z,ax,ay,az,params)
	obj={sdf_index=sdf_index,material=material,x=x,y=y,z=z,ax=ax,ay=ay,az=az,params=params}
	update_object(obj)
	add(object_list, obj)
	return obj
end

function update_object(object)
	object.sdf=sdf_list[object.sdf_index].sdf
	object.t_matrix=matrix_multiply(matrix_multiply(create_x_rotate(object.ax),create_y_rotate(object.ay)),create_z_rotate(object.az))
end


k_preview_steps=5
function generate_obj_points(obj)
	

	local w,h,d,y_offset,v_list=1,1,1,0,{}

		
	if(obj.sdf_index==1)then
		w = obj.params[1]
		h=obj.params[2]
		d=obj.params[3]
	elseif(obj.sdf_index==2)then
		w=obj.params[1]
		h,d=w,w
		
	elseif(obj.sdf_index==3)then
		w=obj.params[1]+obj.params[2]
		h=obj.params[2]
		d=w
	elseif(obj.sdf_index==4)then
		h=obj.params[2]
		w=obj.params[1]
		d=w
	elseif(obj.sdf_index==5)then
		w=1
		h=0
		d=1
	elseif(obj.sdf_index==6)then
		w=obj.params[1]
		h=obj.params[2]/2
		d=w
		y_offset=h
	end
	
	for i=-1,1,2 do
		for j=-1,1,2 do
			for k=-1,1,2 do
				add(v_list,{i*w,j*h+y_offset,k*d})
			end
		end
	end

	return v_list
end

--line_list={{1,2},{2,4},{4,3},{3,1},  {5,6},{6,8},{8,7},{7,5}}
face_list={
{{1,2},{2,4},{4,3},{3,1}},
{{5,6},{6,8},{8,7},{7,5}},
{{1,5},{2,6},{3,7},{4,8}}
}

function preview_objects()
	
	local view_matrix=create_identity()
	view_matrix=matrix_multiply(view_matrix,create_x_rotate(cam_ax))
	view_matrix=matrix_multiply(view_matrix,create_y_rotate(cam_ay))
	view_matrix=matrix_multiply(view_matrix,create_z_rotate(cam_az))
	view_matrix=inverse_matrix(view_matrix)
	
	
	--for k,obj in pairs(object_list) do
	
	
	for k,obj in pairs(object_list)do
		
		local draw_color=12
		local inv_mat=inverse_matrix(obj.t_matrix)

		local vector_list= generate_obj_points(obj)
		local t_vecs={}
				for i,p in pairs(vector_list)do
					px,py,pz=transform_vector(p,inv_mat)
					px,py,pz=px-cam_x-obj.x,py-cam_y-obj.y,pz-cam_z-obj.z
					px,py,pz=transform_vector({px,py,pz},view_matrix)
					
					
					
					local sx,sy=px/pz*64+64,py/pz*64+64
					add(t_vecs,{px,py,pz,sx,sy})
					
				end
				
			
				
				for i, face in pairs(face_list)do
				
					--check winding
				
					if( obj==current_object)then draw_color=12 fillp(0b0101101001011010.1)
					else draw_color=1 fillp(0b0011001111001100.1) end
					for j, cur_line in pairs(face) do
						local sx1,sy1=t_vecs[cur_line[1]][4],t_vecs[cur_line[1]][5]
						local sx2,sy2=t_vecs[cur_line[2]][4],t_vecs[cur_line[2]][5]
						if(t_vecs[cur_line[1]][3]>.05 and t_vecs[cur_line[2]][3]>.05 )line(sx1,sy1,sx2,sy2,draw_color)
					end				
			end
	end
	fillp()	
	
end



--cam_mat = generate_matrix_transform(0,0,.1)
function scene_sdf(px,py,pz)

	local min_d=200
	local dm=0
	local min_dm=0
	local min_obj=nil
	for k,obj in pairs(object_list) do

		local lpx,lpy,lpz = transform_vector({px+obj.x,py+obj.y,pz+obj.z},obj.t_matrix)

		local d=obj.sdf(lpx,lpy,lpz,obj.params)
		if(d<min_d)min_d=d min_obj=obj
	end
	return min_d,min_obj

			
end

function update_light()

			light_x=1*sin(light_ay)*cos(light_ax)
			light_y=1*sin(light_ay)*sin(light_ax)
			light_z=1*cos(light_ay)
end

function init_scene()

	skip_step=2

	cam_x=0
	cam_y=-.5
	cam_z=-3
	
	cam_ax=0
	cam_ay=0
	cam_az=0
	
	light_ay=.4
	light_ax=-.2
	
	update_light()
	
	sky_color={1,1,.5}--{.3,.5,.8}
	sky_color2={.2,.5,1}--{.3,.5,.8}
	sun_color={.8,.7,.2}

	current_object = new_object( 2,5,0,0,0,0,0,0,{.75,.5,.5,.5,.5,.5,.5})
	--current_object = new_object( 2,4,0,0,0,0,0,0,{.5,.5,.5})
	--current_object = new_object( 5,1,0,-2,0,0,0,0,{.5,.5,.5})
	--new_object( 5,1,{0,0,0},create_identity(),{-.75})

	
end


--------------gui-------------------------------------------------------------
function init_mouse()
	poke(0x5f2d, 1) --enable mouse
	
	update_mouse()
	mouse_down_x=mouse_x
	mouse_down_y=mouse_y
	last_mouse_x=mouse_x
	last_mouse_y=mouse_y
	last_mouse_down=mouse_down
	tx=mouse_x
	ty=mouse_y
	last_click_time=0
end

function update_mouse()
	last_mouse_x=mouse_x
	last_mouse_y=mouse_y
	mouse_x=stat(32)
	mouse_y=stat(33)
	
	last_mouse_down=mouse_down
	if(stat(34)==1)then
		mouse_down=true
		if(not last_mouse_down) mouse_down_x=mouse_x mouse_down_y=mouse_y last_click_time=cur_frame
	else
		mouse_down=false
	end
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

	
	
	line(mouse_x-2,mouse_y,mouse_x+2,mouse_y,0)
	line(mouse_x,mouse_y-2,mouse_x,mouse_y+2,0)
	pset(mouse_x,mouse_y,6)


end

function redraw() render_routine = cocreate(render_scene)  end

function nothing()return false end
function set_1x1()skip_step=1 render_mode = k_normal_render redraw() end
function set_2x2()skip_step=2  redraw() end
function set_4x4()skip_step=4  redraw() end

function set_quick_mode()render_mode = k_quick_render if(skip_step<2)then skip_step=2 end redraw() end
function set_normal_mode()render_mode = k_normal_render redraw() end
function set_high_mode()render_mode = k_high_render skip_step=1 redraw() end
function toggle_outline()if(show_outline)then show_outline=false else show_outline=true end end

function hide_menus()show_menus=false end


function check_1x1()return(skip_step==1)end
function check_2x2()return(skip_step==2)end
function check_4x4()return(skip_step==4)end
function check_quick_mode()return(render_mode==k_quick_render)end
function check_normal_mode()return(render_mode==k_normal_render)end
function check_high_mode()return(render_mode==k_high_render)end
function check_show_outline()return(show_outline)end



render_menu={
x=0,y=0,
title="rend",
open=false,
list={
{"1x1",set_1x1,check_1x1},
{"2x2",set_2x2,check_2x2},
{"4x4",set_4x4,check_4x4},
{"quick",set_quick_mode,check_quick_mode},
{"normal",set_normal_mode,check_normal_mode},
{"high",set_high_mode,check_high_mode},
{"outline",toggle_outline,check_show_outline},
{"hide menus",hide_menus,nothing},

}
}

active_menu=1

function draw_menu(menu)
	
	if(text_rect(menu.title,menu.x,menu.y,nil,1,0,7,menu.open))then
		if(menu.open)then menu.open=false else close_all() menu.open=true end
	end
	
	if(menu.open)then
		--find longest item
		local length=0
		for i,item in pairs(menu.list)do
			length=max(length,#(item[1])*4+2)
		end
		
		--rectfill(menu.x-1,menu.y-1,menu.x+length*4-1,menu.y+(#menu.list+1)*7-2,7)
		--rect(menu.x-2,menu.y-2,menu.x+length*4,menu.y+(#menu.list+1)*7-1,0)
		--print(menu.title,menu.x,menu.y,0)
		
		for i,item in pairs(menu.list)do
			local clicked=false
			--print(item[1],menu.x,menu.y+(i)*7,12)
			local highlight=7
			local selected=item[3]()
			if(selected)highlight=6
			clicked=text_rect(item[1],nil,nil,length,highlight,nil,nil)
			if(clicked)item[2]()
		end
	end
end

text_last_x=nil
text_last_y=nil
text_last_width=nil
function text_rect(text,x,y,width,c1,c2,c3,active,rep)
	local c1,c2,c3=c1 or 7,c2 or 0,c3 or 0
	if(active)c1,c3=13,7
	local x=x or text_last_x
	
	local y=y or text_last_y
	local width = width or #text*4+2
	if(x+width>127)x-=x+width-127
	local clicked=false
	
	local x2,y2=x+width,y+8
	
	if(check_click_rect(x,y,x2,y2,rep))c3=8 clicked=true
	frame_rect(x,y,x2,y2,c1,c2)
	 
	print(text,x+2,y+2,c3)
	text_last_x=x
	text_last_y=y+8
	
	return clicked
	
end
function frame_rect(x1,y1,x2,y2,c1,c2)
	rectfill(x1,y1,x2,y2,c1) rect(x1,y1,x2,y2,c2)
    if(check_down_rect(x1,y1,x2,y2))click_through=false
	end



function get_cur_obj(params)return current_object[params] end
function set_cur_obj(params,value) current_object[params]=value update_object( current_object) redraw() end

--function get_cur_params(i) return sdf_list[object_list[selected_object].sdf_index].params[i] end
function get_cur_params(n) return(current_object.params[n])end
 
function get_param_name(n) return(sdf_list[current_object.sdf_index].params[n])  end
function set_cur_params(n,value) current_object.params[n]=value redraw() end


object_loc_dialog={
x=44,y=0,
width=54,
open=false,
title="loc",
widgets={
	{text="x",get_value_func=get_cur_obj,set_value_func=set_cur_obj,params="x",step=.05},
	{text="y",get_value_func=get_cur_obj,set_value_func=set_cur_obj,params="y",step=.05},
	{text="z",get_value_func=get_cur_obj,set_value_func=set_cur_obj,params="z",step=.05},
	{text="ax",get_value_func=get_cur_obj,set_value_func=set_cur_obj,params="ax",loop=true,step=.01},
	{text="ay",get_value_func=get_cur_obj,set_value_func=set_cur_obj,params="ay",loop=true,step=.01},
	{text="az",get_value_func=get_cur_obj,set_value_func=set_cur_obj,params="az",loop=true,step=.01},
	}
}







function draw_dialog(dialog)
	local x,y=dialog.x,dialog.y
	if(text_rect(dialog.title,x,y,nil,1,0,7,dialog.open))then
		if(dialog.open)then dialog.open=false else close_all() dialog.open=true end
	end
	if(dialog.open)then
		for k,widget in pairs(dialog.widgets) do
			 draw_value_widget(widget,x,y+(k)*8,dialog.width)
		end
	end
end

function draw_value_widget(widget,x,y,width)
	
	local value=widget.get_value_func(widget.params)
	if(x+width>127)x-=x+width-127
	local text_value=(flr(value*100+.5)/100)..""
	frame_rect(x,y,x+width,y+8,7,0)
	print(widget.text,x+2,y+2,0)
	frame_rect(x+width-36,y,x+width-12,y+8,6,0)
	print(text_value,x+width-34,y+2,0)
	
	local update=false
	
	if(text_rect("<",x+width-12,y,nil,5,0,7,false,true))value-=widget.step  update=true
	if(text_rect(">",x+width-6,y,nil,5,0,7,false,true))value+=widget.step  update=true



	if(update)then
		if(widget.bound)value=mid(value,0,1)
		if(widget.loop)value%=1
	
		widget.set_value_func(widget.params,value)
		redraw()
		return true
	end
	return false
end

function draw_simple_widget(title,value,change,x,y,width,step,loop,bound)

	if(x+width>127)x-=x+width-127
	if(value==nil)value=0
	local text_value=(flr(value*100+.5)/100)..""
	frame_rect(x,y,x+width,y+8,7,0)
	print(title,x+2,y+2,0)
	frame_rect(x+width-36,y,x+width-12,y+8,6,0)
	print(text_value,x+width-34,y+2,0)
	update=false
	if(text_rect("<",x+width-12,y,nil,5,0,7,false,true))value-=step  update=true
	if(text_rect(">",x+width-6,y,nil,5,0,7,false,true))value+=step  update=true
	if(bound)value=mid(value,0,1)
	if(loop)value%=1
	
	return value,(change or update)
end

cam_open=false
function draw_cam_dialog()
	local x,y=60,0
	local width=65
	local update=false
	if(text_rect("cam",x,y,nil,1,0,7,cam_open))then
		if(cam_open)then cam_open=false else close_all() cam_open=true end
	end
	if(cam_open)then
		cam_x, update=draw_simple_widget("cam x",cam_x,update,x,y+8,width,.05)
		cam_y, update=draw_simple_widget("cam y",cam_y,update,x,y+16,width,.05)
		cam_z, update=draw_simple_widget("cam z",cam_z,update,x,y+24,width,.05)
		cam_ax,update=draw_simple_widget("cam ax",cam_ax,update,x,y+32,width,.01,true)
		cam_ay,update=draw_simple_widget("cam ay",cam_ay,update,x,y+40,width,.01,true)
		--cam_az,update=draw_simple_widget("cam az",cam_az,update,x,y+48,width,.01,true)
		if(update)then redraw() end
	end
end

function draw_rgb_widget(title,value,change,x,y,width)
	local update=change
	value[1], update=draw_simple_widget(title..":r",value[1],update,x,y,width,.02,false,true)
	value[2], update=draw_simple_widget(title..":g",value[2],update,x,y+8,width,.02,false,true)
	value[3], update=draw_simple_widget(title..":b",value[3],update,x,y+16,width,.02,false,true)
	return value, update
end

scene_open=false
function draw_scene_dialog()
	local x,y=76,0
	local width=65
	local update=false
	if(text_rect("scene",x,y,nil,1,0,7,scene_open))then
		if(scene_open)then scene_open=false else close_all() scene_open=true end
	end
	if(scene_open)then
		light_ax,update=draw_simple_widget("l ax",light_ax,update,x,y+8,width,.01,true)
		light_ay,update=draw_simple_widget("l ay",light_ay,update,x,y+16,width,.01,true)
		sky_color,update=draw_rgb_widget("sky1",sky_color,update,x,y+24,width)
		sky_color2,update=draw_rgb_widget("sky2",sky_color2,update,x,y+24+24,width)
		sun_color,update=draw_rgb_widget("sun",sun_color,update,x,y+24+48,width)

		
		if(update)then update_light() redraw() end
	end
end

material_open=false
function draw_material_dialog()
	local x,y=100,0
	local width=65
	local update=false
	if(text_rect("mat",x,y,nil,1,0,7,material_open))then
		if(material_open)then material_open=false else close_all() material_open=true end
	end
	if(material_open)then
		current_object.material,update=draw_simple_widget("mat",current_object.material,update,x,y+8,width,1,false)	
		current_object.material=(current_object.material-1)%#material_list+1
		local cur_matl=material_list[current_object.material]
		if(cur_matl.pattern==nil)then
			cur_matl.color,update=draw_rgb_widget("col",cur_matl.color,update,x,y+16,width)
			y+=40
		else
			text_rect("pattern: "..cur_matl.pattern,x,y+16,width,6,0,0)
			y+=24
		end
			cur_matl.specularity,update=draw_simple_widget("spec",cur_matl.specularity,update,x,y,width,.05,false)	
			cur_matl.gloss,update=draw_simple_widget("gloss",cur_matl.gloss,update,x,y+8,width,.05,false)	
			cur_matl.shiny,update=draw_simple_widget("shiny",cur_matl.shiny,update,x,y+16,width,.05,false)
			cur_matl.mirror,update=draw_simple_widget("refl",cur_matl.mirror,update,x,y+24,width,.05,false,true)	
			cur_matl.transparent,update=draw_simple_widget("trans",cur_matl.transparent,update,x,y+32,width,.05,false,true)	
			cur_matl.n,update=draw_simple_widget("ior",cur_matl.n,update,x,y+40,width,.05,false,false)	
			cur_matl.n=mid(cur_matl.n,1,2)
			--cur_matl.n=1.5
		

--{color={.125,.125,.125},specularity=.5,gloss=2,shiny=.5,mirror=.75},
		
		if(update)then  redraw() end
	end
end


param_open=false
function draw_params_dialog()
	local x,y,width = 20,0,54
	
	if(text_rect("param",x,y,nil,1,0,7,param_open))then
		if(param_open)then param_open=false else close_all() param_open=true end
	end
	
	
	if(param_open)then
		
			local sdf_num=current_object.sdf_index
			local cur_sdf_item = sdf_list[sdf_num]
		
			text_rect(cur_sdf_item.name,x,y+8,width,6,0,0)
			update=false
			if(text_rect("<",x+width-12,y+8,nil,5,0,7))sdf_num-=1 update=true
			if(text_rect(">",x+width-6,y+8,nil,5,0,7))sdf_num+=1 update=true
			
			for k,p in pairs(cur_sdf_item.params)do
				draw_value_widget({text=p,get_value_func=get_cur_params,set_value_func=set_cur_params,params=k,step=.05},x,y+8+k*8,width)
			end
			if(draw_value_widget({text="mat",get_value_func=get_cur_obj,set_value_func=set_cur_obj,params="material",step=1},x,y+8+(#cur_sdf_item.params+1)*8,width))update=true
			
			bottom=y+16+(#cur_sdf_item.params+1)*8
		

		if(text_rect("new",x,bottom,width/2,5,0,6))then
				current_object= new_object( 2,4,0,0,0,0,0,0,{.5,.5,.5,.5,.5,.5})
				update=true
			end
			if(text_rect("delete",x+width/2,bottom,width/2,5,0,6))then
				if(#object_list>1)then
					del(object_list,current_object)
					for obj in all(object_list)do
						current_object=obj
						redraw()
						return false
					end
					--not the best way
				end
				
				
				
			end
		
		
		if(update)then
				current_object.material=(current_object.material-1)%#material_list+1
				--sdf_num=(sdf_num%(#sdf_list))+1
				current_object.sdf_index=((sdf_num-1)%(#sdf_list))+1
				update_object( current_object)
				redraw()
			end
		
	end	

end


function close_all()
	param_open=false
	object_loc_dialog.open=false
	render_menu.open=false
	scene_open=false
	cam_open=false
	material_open=false
end

function select_object()
	if(click_through==false)return
	if(last_mouse_down==false and mouse_down==true)then
		local x,y,z,rx,ry,rz= generate_ray(mouse_x,mouse_y)
		local b,obj=quick_trace_ray(x,y,z,rx,ry,rz)
		if(obj!=nil)then current_object=obj
		else 
			-- do nothing
		end
		
	end

end




------------------------------------------------------------------------------

function _init()
	cls()
	srand(4)
	init_rand_list()
	show_outline=true
	init_mouse()

	cur_frame=0
	init_scene()
	show_menus=true
	render_routine = cocreate(render_scene)
	
end

function _update()
	click_through=true
	
end

function _draw()
	cur_frame+=1
	update_mouse()
	fillp()
	--flip()
	
	memcpy(0x6000,0x0000,128*64)
	
	if(btn(4))cam_ay+=.01
	
	
	coresume(render_routine)
	--if(costatus(render_routine)=="dead") render_routine = cocreate(render_scene)
	--
	
	if(show_menus)then
		 if(show_outline)then
			preview_objects()
		end

		--rectfill(127-32,127-6,127,127,1)
		--print(stat(1),127-31,127-5,7)

		
		draw_menu(render_menu)
		draw_dialog(object_loc_dialog)
		draw_scene_dialog()
		draw_cam_dialog()
		draw_material_dialog()
		draw_params_dialog()
		 select_object()
		if(cur_col<127-skip_step)	line(cur_col,127,cur_col-skip_step+1,127,5+cur_frame%3)
		
		 
		--draw_value_widget(widget_item,32,32)
		draw_mouse()
	else
		if(check_click_rect(0,0,127,127))show_menus=true
	end
end

__gfx__
0050505055d5d5d5dd6d6d6d66767677777777770050505055d5d5d5dd6d6d6d6676767777777777777777777777777777777777777777777777777777777777
0000055555555dddddddd66666666777777777770000055555555dddddddd6666666677777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
becbcbbbbcbacb8bbbbcb5cbbcbacb8bbbfbbbbcbecbcbbbbcbacb8bbbbcb5cbbcbacb8bbbbcb5cbbcbacb8bbbbcb5cbbcbacb8bbbbcb5cbbcbacb8bbbbcb5cb
ccb5c75cbbbbb1bb1bbbbbb1bbbbb1bbb3c74c7bccb5c75cbbbbb1bb1bbbbbb1bbbbb1bb1bbbbbb1bbbbb1bb1bbbbbb1bbbbb1bb1bbbbbb1bbbbb1bb1bbbbbb1
001101101100120f20f111111100120f11011011001101101100120f20f111111100120f20f111111100120f20f111111100120f20f111111100120f20f11111
d100130d116110110a11f1111161101100130d30d100130d116110110a11f111116110110a11f111116110110a11f111116110110a11f111116110110a11f111
31e111131e31e1121d2bd1a11e31e112e111131e31e111131e31e1121d2bd1a11e31e1121d2bd1a11e31e1121d2bd1a11e31e1121d2bd1a11e31e1121d2bd1a1
163113113311c073111c17c13311c07350b30133163113113311c073111c17c13311c073111c17c13311c073111c17c13311c073111c17c13311c073111c17c1
cc11c11c053b5ab0a3013b17053b5ab011c11c11cc11c11c053b5ab0a3013b17053b5ab0a3013b17053b5ab0a3013b17053b5ab0a3013b17053b5ab0a3013b17
13cb3bc15313cc37c17c13cc5313cc373c5dc3b313cb3bc15313cc37c17c13cc5313cc37c17c13cc5313cc37c17c13cc5313cc37c17c13cc5313cc37c17c13cc
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
1515151515151515151515151515151545345334534534533453345334533453c29c28c28c27c26c25438439439439431539d38d37d36d35c59c28c27c26c25c84b5bb5cb5c93b93cd39d38d37d36c48dc6dc7dc8dcadcbdccb49b49b49b49b49db8db7db7db6db5dc7dc8dc9dcadcceceb48b48b48b48db9db9db8db7db7639
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
