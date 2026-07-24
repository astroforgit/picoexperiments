pico-8 cartridge // http://www.pico-8.com
version 18
__lua__


k_display_adr=0x6000
k_screen_1_adr=0x0000
k_screen_2_adr=0x2000
k_screen_len=0x2000


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

pico_color_index={
{0,0},
{1,1},
{2,2},
{3,3},
{4,4},
{5,5},
{6,6},
{7,7},
{8,8},
{9,9},
{10,10},
{11,11},
{12,12},
{13,13},
{14,14},
{15,15}}

k_max_color_dist = .5
function add_new_colors()
	for c1=1,16 do
		for c2=c1,16 do
			
			if(color_compare(pico_palette[c1],pico_palette[c2])<k_max_color_dist)then
				new_color = vec3_scale(vec3_add(pico_palette[c1],pico_palette[c2]),.5)
				add(pico_palette,new_color)
				add(pico_color_index,{c1-1,c2-1})
			end
		end
	end
end


function color_compare(rgb1,rgb2)
	--use ccir luminosity
	local luma1 = rgb1[1]*.299+rgb1[2]*.587+rgb1[3]*.114
	local luma2 = rgb2[1]*.299+rgb2[2]*.587+rgb2[3]*.114
	local lumadiff=luma1-luma2
	local diff = vec3_sub(rgb1,rgb2)
	return abs((diff[1]*diff[1]*0.299 + diff[2]*diff[2]*.587 + diff[3]*diff[3]*.114)*.75+lumadiff*lumadiff)
end	




function init_palette_dist()
	palette_dist={}
	
	for fc=0,#pico_palette-1  do
		palette_dist[fc]={}
		for bc=fc,#pico_palette-1 do
		
			local  c1=pico_palette[fc+1]
			local  c2=pico_palette[bc+1]
		    
			local dx=c2[1]-c1[1]
			local dy=c2[2]-c1[2]
			local dz=c2[3]-c1[3]
			
			local c_dist = sqrt(dx*dx+dy*dy+dz*dz)
			
			--local c_dist = color_compare(c1,c2)
			
			
			local inv_dist=1/c_dist
			local ldx=dx*inv_dist
			local ldy=dy*inv_dist
			local ldz=dz*inv_dist
			
			local luma = color_compare(c1,c2)
			
			palette_dist[fc][bc]={c_dist,ldx,ldy,ldz,luma}
		end
	end
end


function find_mix(target_color)
	
	local min_dist=100
	local pico_palette=pico_palette
	
	local best_fc = 0
	local best_bc = 0
	local best_mix = 1
	
	local palette_dist=palette_dist
	local pico_color_index=pico_color_index
	
	for fc=0,#pico_palette-1  do
	
		local p_dist=palette_dist[fc]
		for bc=fc,#pico_palette-1 do
		
		
			local cur_dist=p_dist[bc]
			local c_dist=cur_dist[1]
			local luma = cur_dist[5]
				
			if(luma<.8)then	
			
				local  c1=pico_palette[fc+1]
				local  c2=pico_palette[bc+1]
				
				
				local ldx=cur_dist[2]
				local ldy=cur_dist[3]
				local ldz=cur_dist[4]
				
						
				local vx,vy,vz = target_color[1]-c1[1],target_color[2]-c1[2],target_color[3]-c1[3]
				local mix = mid(0,1,(vx*ldx+vy*ldy+vz*ldz)/c_dist)
				
				--mix=mid(0,1,mix/c_dist)
				local scale=c_dist*mix
				
			
				local rx,ry,rz=c1[1]+scale*ldx,c1[2]+scale*ldy,c1[3]+scale*ldz	
					
				
					
				local dist=color_compare({rx,ry,rz},target_color)
				
				--local dx,dy,dz=target_color[1]-rx,target_color[2]-ry,target_color[3]-rz
				--local dist=dx*dx+dy*dy+dz*dz
				--
				dist+=luma*.015
				--dist+=color_compare(c1,c2)*.02
				if(dist<min_dist)then
					best_fc=fc
					best_bc=bc
					best_mix=16-flr(mix*15)
					min_dist=dist
				end
				
			end

			
		end
	end
	
	return pico_color_index[best_bc+1][1],pico_color_index[best_fc+1][1],pico_color_index[best_bc+1][2],pico_color_index[best_fc+1][2],best_mix
	
	--return {set_color_and_pattern(pico_color_index[best_bc+1][1],pico_color_index[best_fc+1][1],best_mix),
	--		set_color_and_pattern(pico_color_index[best_bc+1][2],pico_color_index[best_fc+1][2],best_mix)}
	
end

function set_color_and_pattern(c1,c2,mix)
	local color = bor(0x1000,shl(c2,4))
	local color = bor(color,c1)
	return bor(color,gray_patterns[ flr(mix)])
end





function reset_nibble_index()
	nibble_index=0
end


function write_left(n,adr)
	local left_mask =  0b11110000
	local right_mask = 0b00001111
	
	local init_value=peek(adr)
	init_value=band(init_value,right_mask)
	n=band(left_mask,shl(n,4))
	poke(adr,bor(n,init_value))
	
end

function write_right(n,adr)
	local left_mask =  0b11110000
	local right_mask = 0b00001111
	
	local init_value=peek(adr)
	init_value=band(init_value,left_mask)
	n=band(right_mask,n)
	poke(adr,bor(n,init_value))
	
end

function read_left(n,adr)
	local left_mask =  0b11110000
	local right_mask = 0b00001111
	
	local init_value=peek(adr)
	init_value=band(init_value,left_mask)
	init_value=shr(init_value,4)
	return init_value
	
	
end

function read_right(n,adr)
	local left_mask =  0b11110000
	local right_mask = 0b00001111
	
	local init_value=peek(adr)
	init_value=band(init_value,right_mask)
	return init_value
	
	
end


function write_nibble(n)
	
	if(nibble_index%1==0)then
		write_left(n,flr(nibble_index))
	else
		write_right(n,flr(nibble_index))
	end
	

	nibble_index+=.5
end

function write_nibbles(a)
	for n in all(a)do
		write_nibble(n)
	end
end

function read_nibble()
	
	local v
	if(nibble_index%1==0)then
		v=read_left(n,flr(nibble_index))
	else
		v=read_right(n,flr(nibble_index))
	end
	
	
	nibble_index+=.5
	return v
end

function save_nibbles()
	cstore( 0, 0, flr(nibble_index+.5))--,"output.p8")--, "output.p8")
end

k_color_depth=15
function init_rgb_cube()
	
	cls(7)
	reset_nibble_index()
	poke(0x5f34, 1)

	rgb_cube={}
	local k_color_depth=k_color_depth

	pr_rainbow("rebuilding palette",64,115,0)
	
	local len=(k_color_depth+1)*(k_color_depth+1)*(k_color_depth+1)
	local index=0
	for r_target=0,k_color_depth do
		rgb_cube[r_target]={}
		for g_target=0,k_color_depth do
			rgb_cube[r_target][g_target]={}
			for b_target=0,k_color_depth do
				local target_color={r_target/k_color_depth,g_target/k_color_depth,b_target/k_color_depth}
				
				local c1,c2,c3,c4,p = find_mix(target_color)
				local pattern_1 = set_color_and_pattern(c1,c2,p)
				local pattern_2 = set_color_and_pattern(c3,c4,p)
				

				
				rgb_cube[r_target][g_target][b_target]={pattern_1,pattern_2}
				
				local cx=g_target*4+r_target*2+16
				local cy=b_target*4+r_target*2+16
				
				rectfill(cx,cy,cx+3,cy+3,rgb_cube[r_target][g_target][b_target][1])
				
				--rectfill(cx+64,cy,cx+64+3,cy+3,rgb_cube[r_target][g_target][b_target][2])
				--fillp()
				
				--flip()
				index+=1
				
			end
			
			fillp()
				print_box("progress:"..flr(index/len*100).."%",64,4,0)
			
		end
			
			
			flip()
			
	end
	
	--save_nibbles()
end


function load_rgb_cube(mode)
	reset_nibble_index()
	if(mode==k_high_mode)nibble_index=0
	if(mode==k_low_mode)nibble_index=10241
	--nibble_index=10241
	
	
	poke(0x5f34, 1)

	rgb_cube={}
	local k_color_depth=k_color_depth

	for r_target=0,k_color_depth do
		rgb_cube[r_target]={}
		for g_target=0,k_color_depth do
			rgb_cube[r_target][g_target]={}
			for b_target=0,k_color_depth do
				local target_color={r_target/k_color_depth,g_target/k_color_depth,b_target/k_color_depth}
				
				local c1 = read_nibble()
				local c2 = read_nibble()
				local c3,c4
				if(mode==k_high_mode)then
					c3 = read_nibble()
					c4 = read_nibble()
				else
					c3=c1
				    c4=c2
				end
				local p = read_nibble()

				

				local pattern_1 = set_color_and_pattern(c1,c2,p)
				local pattern_2 = set_color_and_pattern(c3,c4,p)
				
				rgb_cube[r_target][g_target][b_target]={pattern_1,pattern_2}
				
				--local cx=g_target*4+r_target*2
				--local cy=b_target*4+r_target*2
				
				--rectfill(cx,cy,cx+3,cy+3,rgb_cube[r_target][g_target][b_target][1])
				--
				--rectfill(cx+64,cy,cx+64+3,cy+3,rgb_cube[r_target][g_target][b_target][2])

			end
		end
	end
	
	--pause()
end

function new_ray(o,d)
	nr={}
	nr.origin=o
	nr.direction=d
	return nr
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


function	vec3_cross(p,a,b)
	 a[1]-=p[1]
	 a[2]-=p[2]
	 a[3]-=p[3]
	 b[1]-=p[1]
	 b[2]-=p[2]
	 b[3]-=p[3]
	return {a[2]*b[3]-a[3]*b[2],a[3]*b[1]-a[1]*b[3],a[1]*b[2]-a[2]*b[1]}
end
 
 function distance(x1,y1,z1,x2,y2,z2)
	local dx=x2-x1
	local dy=y2-y1
	local dz=z2-z1
	
	return sqrt(dx*dx+dy*dy+dz*dz)
 end
 
 function normalize(x,y,z)
     local x1=x
     local y1=y
     local z1=z
     
     local inv_dist=1/sqrt(x1*x1+y1*y1+z1*z1)
     
     return x1*inv_dist,y1*inv_dist,z1*inv_dist
     
 end
 
 function    vector_dot(ax,ay,az,bx,by,bz)
     return ax*bx+ay*by+az*bz
 end
     
 function vector_direction(ax,ay,az,bx,by,bz)

	return normalize(bx-ax,by-ay,bz-az )
 end
 

	 
 function    vector_cross_3d(px,py,pz,ax,ay,az,bx,by,bz)
 
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
 
 function    vector_cross(ax,ay,az,bx,by,bz)
 
     
     local dx=ay*bz-az*by
     local dy=az*bx-ax*bz
     local dz=ax*by-ay*bx
     return dx,dy,dz
 end








k_width=127
k_scale=127/k_width

function new_image()
	image={}
	r,g,b=1,1,1
	for i=0,k_width do
		image[i]={}
		for j=0,k_width do
			image[i][j]={r,g,b}
		end
	end
end



function update_image(x1,y1,x2,y2)
	local image=image
	local rgb_cube=rgb_cube
	local screen_a=k_screen_1_adr
	local screen_b=k_screen_2_adr
	
	local y_offset=y1*64
	local copy_length=(y2-y1+1)*64
	
	if(cur_frame%2==0)then
		screen_a,screen_b=screen_b,screen_a
	end
	
	for i=x1,x2 do
		local image_col=image[i]
		for j=y1,y2 do
			local c=image_col[j]
			local cr=min(band(shl(c[1],4),0xffff),15)
			local cg=min(band(shl(c[2],4),0xffff),15)
			local cb=min(band(shl(c[3],4),0xffff),15)
			if(cur_frame%2==0)then
				pset(i,j,rgb_cube[cr][cg][cb][2])
				else
				pset(i,j,rgb_cube[cr][cg][cb][1])
				end
			
		end
	end

	memcpy(screen_b+y_offset,k_display_adr+y_offset,copy_length)
	memcpy(k_display_adr+y_offset,screen_a+y_offset,copy_length)
	

	for i=x1,x2 do
		local image_col=image[i]
		for j=y1,y2 do
			local c=image_col[j]
			local cr=min(band(shl(c[1],4),0xffff),15)
			local cg=min(band(shl(c[2],4),0xffff),15)
			local cb=min(band(shl(c[3],4),0xffff),15)
			if(cur_frame%2==0)then
				pset(i,j,rgb_cube[cr][cg][cb][1])
				else
				pset(i,j,rgb_cube[cr][cg][cb][2])	
				end
			
		end
	end
	
	memcpy(screen_a+y_offset,k_display_adr+y_offset,copy_length)
	memcpy(k_display_adr+y_offset,screen_b+y_offset,copy_length)
	--we get flicker if we don't copy the screen back to the same place
	
end

function draw_screen()

	--memcpy(k_display_adr,k_screen_1_adr,k_screen_len)

	if(cur_frame%2==0)then
		memcpy(k_display_adr,k_screen_1_adr,k_screen_len)
	else
		memcpy(k_display_adr,k_screen_2_adr,k_screen_len)
	end
end



function smoothstep(h1,h2,t)
	t=mid(t,0,1)
	t=(t*t*(3-2*t))
	return (h2-h1)*t+h1
end

k_max_brush_radius=11
k_min_brush_radius=.7
k_max_brush_hardness=6
k_min_brush_hardness=.05
brush_hardness=.5
brush_radius=6
brush_step=4

k_pixel_mode=1
k_airbrush_mode=2
k_star_mode=3
k_pen_mode=4
k_spray_mode=5
brush_mode=k_airbrush_mode

cur_r=0
cur_g=0
cur_b=0

function update_brush_mask()
	brush_mask={}
	local int_brush_radius=flr(brush_radius)
	brush_radius=mid(brush_radius,k_max_brush_radius,k_min_brush_radius)

	
	if(brush_mode==k_airbrush_mode or brush_mode==k_spray_mode)then
			local brush_radius2=brush_radius*brush_radius
		for i=-int_brush_radius,int_brush_radius do
			brush_mask[i]={}
			for j=-int_brush_radius,int_brush_radius do
				local dist=i*i+j*j
				local t=brush_radius2/dist*.1
				
				local b=smoothstep(0,1,t)*brush_hardness
				if(dist>brush_radius2)b=0
			
				brush_mask[i][j]=b
			end
		end
		
		brush_step=brush_radius*.3
		
	elseif(brush_mode==k_pixel_mode)then
		local brush_radius2=brush_radius*brush_radius
		for i=-int_brush_radius,int_brush_radius do
			brush_mask[i]={}
			for j=-int_brush_radius,int_brush_radius do
				
			
				brush_mask[i][j]=0
				if(i>-brush_radius and i<brush_radius and j>-brush_radius and j<brush_radius)then
					brush_mask[i][j]=1
				end
			end
		end
		
		brush_step=brush_radius*.25
		
	elseif(brush_mode==k_star_mode)then
			local brush_radius2=brush_radius*brush_radius
		for i=-int_brush_radius,int_brush_radius do
			brush_mask[i]={}
			for j=-int_brush_radius,int_brush_radius do
				local dist=i*i+j*j
				local angle=atan2(i,j)
				
				local t=brush_radius2/dist*.1
				local val=(sin(6*angle+.25)*.4+.6)
				t*=val*.4
				
				local b=smoothstep(0,1,t)*brush_hardness
				if(dist>brush_radius2*val*1.5)b=0
			
				brush_mask[i][j]=b
			end
		end
		
		brush_step=brush_radius*.5
		
	elseif(brush_mode==k_pen_mode)then
			local brush_radius2=brush_radius*brush_radius
		for i=-int_brush_radius,int_brush_radius do
			brush_mask[i]={}
			for j=-int_brush_radius,int_brush_radius do
				local x=i
				local y=j
				local a=.125
				
				
				x,y=y*cos(a)+x*sin(a),x*cos(a)-y*sin(a)
				y*=3
				
				
				
				local dist=x*x+y*y
				
				local t=brush_radius2/dist*.1
				
				local b=smoothstep(0,1,t)*brush_hardness
				if(dist>brush_radius2)b=0
			
				brush_mask[i][j]=b
			end
		end
		
		brush_step=brush_radius*.25
	end
end

function new_image_mask()
	image_mask={}
	for i=0,127 do
		image_mask[i]={}
		for j=0,127 do
			image_mask[i][j]=1
			
			--if(i>40 and i<90)image_mask[i][j]=j/127
			--if(j>50 and j<75)image_mask[i][j]=sin(i/127)*.5+.5
		end
	end
end

function render_image_mask()
	local image_mask=image_mask
	fillp()
	for j=0,127,2 do

		for i=0,127,2 do
			local b=image_mask[i][j]
			--if(b<.75)pset(i,j,14)
			if(rnd(b)<.1)pset(i,j,8)
			
			

		end
	end
end



function handle_brush()



	local image=image
	local image_mask=image_mask
	local brush_mask=brush_mask

	
	if(btn(1))then brush_color_r,brush_color_g,brush_color_b=0,0,0 end
	
	if(not mouse_down)then tx=flr(mouse_x/k_scale) ty=flr(mouse_y/k_scale) end
	
	
	if(mouse_down)then
		
		
		--local mdx=mouse_x-wx
		--local mdy=mouse_y-wy
		local cycles=1
		if(brush_radius<8)cycles=2
		if(brush_radius<6)cycles=3
		if(brush_radius<4)cycles=6
		if(brush_radius<=1)cycles=24
		
		for i=1,cycles do move_brush() end
		
		
	end
end

function move_brush()
	local mdx,mdy=vector_direction(tx,ty,0,mouse_x,mouse_y,0)
		local m_dist=distance(tx,ty,0,mouse_x,mouse_y,0)
		
		m_dist=min(m_dist,brush_step)
		
		tx+=mdx*m_dist
		ty+=mdy*m_dist
		
		wx=flr(tx)
		wy=flr(ty)
		
		--local wx=flr(mouse_x/k_scale)
		--local wy=flr(mouse_y/k_scale)
		
		
		
	stamp_brush(tx,ty)
end


function stamp_brush(wx,wy)

		if(brush_radius<=1)wx+=k_min_brush_radius wy+=k_min_brush_radius

		wx=flr(wx)
		wy=flr(wy)
		
		
		local int_brush_radius = flr(brush_radius)

		local x1=wx-int_brush_radius
		local y1=wy-int_brush_radius
		local x2=wx+int_brush_radius
		local y2=wy+int_brush_radius
		
		x1=mid(x1-0,1,k_width)
		y1=mid(y1-0,1,k_width)
		x2=mid(x2+0,1,k_width)
		y2=mid(y2+0,1,k_width)
		
		for dx=-int_brush_radius,int_brush_radius do
			local brush_col=brush_mask[dx]
			local px=dx+wx
			local image_col=image[px]
			local image_mask_col=image_mask[px]
			for dy=-int_brush_radius,int_brush_radius do
				
				
				
				local py=dy+wy
				
				if(px>0 and px<k_width and py>0 and py<k_width)then
					
					if(image_col==nil)then
						cls()
						print(px.." "..py,0)
					pause()
					end
					
					local pix=image_col[py]
					
					
					
					local image_mask_opacity=image_mask_col[py]
					local target_opacity=mid(brush_col[dy]*image_mask_opacity,0,1)
					if(brush_mode==k_spray_mode)target_opacity*=rnd(1)*.1
					
					
					
					local background_opacity=1-target_opacity

					local r,g,b=pix[1],pix[2],pix[3]
					
					r=r*background_opacity+target_opacity*cur_r/k_color_depth
					g=g*background_opacity+target_opacity*cur_g/k_color_depth
					b=b*background_opacity+target_opacity*cur_b/k_color_depth
					
					--r=smoothstep(r,brush_color_r,bm)
					--g=smoothstep(g,brush_color_g,bm)
					--b=smoothstep(b,brush_color_b,bm)

					image_col[py]={r,g,b}
				end
			
			end
		end
		
		x1=mid(wx-int_brush_radius,0,k_width)
		y1=mid(wy-int_brush_radius,0,k_width)
		x2=mid(wx+int_brush_radius,0,k_width)
		y2=mid(wy+int_brush_radius,0,k_width)
		

		update_image(x1,y1,x2,y2)

end

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
end

function update_mouse()
	mouse_x=stat(32)
	mouse_y=stat(33)
	last_mouse_down=mouse_down
	if(stat(34)==1)then
		mouse_down=true
		if(not last_mouse_down) mouse_down_x=mouse_x mouse_down_y=mouse_y
	else
		mouse_down=false
	end
	last_mouse_x=mouse_x
	last_mouse_y=mouse_y
	
end

function draw_mouse()
	fillp()
	circ(mouse_x,mouse_y,brush_radius,9)
	pset(mouse_x,mouse_y,9)
end



function draw_color_picker()
	
	--if(cur_frame%50==0)cur_b+=1 cur_b%=16
	--
	--if(cur_frame%15==0)cur_g+=1 cur_g%=16
	--if(cur_frame%75==0)cur_r+=1 cur_r%=16
	
	fillp()
	--cls(7)
	
	
	local ps=5
	local pal_x1 = 5
	local pal_y1 = 13
	local pal_x2 =pal_x1+ps*(k_color_depth+1)+1
	local pal_y2 =pal_y1+ps*(k_color_depth+1)+1
	
	rect(pal_x1,pal_y1,pal_x2,pal_y2,0)
	

	for r=0,k_color_depth do
		for g=0,k_color_depth do
		 local x=r*ps+pal_x1+1
		 local y=g*ps+pal_y1+1
		 
		 if(cur_frame%2==0)then
		 rectfill(x,y,x+ps-1,y+ps-1,rgb_cube[r][g][cur_b][1])
		 else
		 rectfill(x,y,x+ps-1,y+ps-1,rgb_cube[r][g][cur_b][2])
		 end
		end
	end
	
	local b_ps=ps
	local b_pal_x1=pal_x2+2
	local b_pal_y1=pal_y1
	local b_pal_x2=b_pal_x1+2*ps+1
	local b_pal_y2=b_pal_y1+(k_color_depth+1)*ps+1

	rect(b_pal_x1,b_pal_y1,b_pal_x2,b_pal_y2,0)
	
	for b=0,k_color_depth do
		local y=b*ps+b_pal_y1+1
	
		if(cur_frame%2==0)then
		 rectfill(b_pal_x1+1,y,b_pal_x1+ps*2,y+ps-1,rgb_cube[cur_r][cur_g][b][1])
		 else
		 rectfill(b_pal_x1+1,y,b_pal_x1+ps*2,y+ps-1,rgb_cube[cur_r][cur_g][b][2])
		 end
		 
	end
	
	local gray_ps=ps
	local gray_pal_x1=b_pal_x2+2
	local gray_pal_y1=pal_y1
	local gray_pal_x2=gray_pal_x1+2*ps+1
	local gray_pal_y2=gray_pal_y1+(k_color_depth+1)*ps+1
	
	rect(gray_pal_x1,gray_pal_y1,gray_pal_x2,gray_pal_y2,0)
	
	for b=0,k_color_depth do
		local y=b*gray_ps+gray_pal_y1+1
	
		if(cur_frame%2==0)then
		 rectfill(gray_pal_x1+1,y,gray_pal_x1+ps*2,y+ps-1,rgb_cube[b][b][b][1])
		 else
		 rectfill(gray_pal_x1+1,y,gray_pal_x1+ps*2,y+ps-1,rgb_cube[b][b][b][2])
		 end
		 
	end
	
		--rect(x,y,x+ps*2-1,y+ps-1,rgb_cube[cur_r][cur_g][b][2])
	
	local p_click=click_in_rect(pal_x1,pal_y1,pal_x2,pal_y2)
	if(p_click==k_down)then
		cur_r=flr((mouse_x-pal_x1-1)/(ps))
		cur_g=flr((mouse_y-pal_y1-1)/(ps))
	end
	
	local b_click=click_in_rect(b_pal_x1,b_pal_y1,b_pal_x2,b_pal_y2)
	if(b_click==k_down)then
		cur_b=flr((mouse_y-b_pal_y1-1)/(b_ps))
	end
	
	local gray_click=click_in_rect(gray_pal_x1,gray_pal_y1,gray_pal_x2,gray_pal_y2)
	if(gray_click==k_down)then
		cur_b=flr((mouse_y-b_pal_y1-1)/(b_ps))
		cur_g=cur_b
		cur_r=cur_b
	end
	
	fillp()
	rect(pal_x1+ps*cur_r+1,pal_y1+ps*cur_g+1,pal_x1+ps*(cur_r+1),pal_y1+ps*(cur_g+1),7)
	rect(b_pal_x1+1,cur_b*ps+b_pal_y1+1,b_pal_x1+ps*2,cur_b*ps+b_pal_y1+ps-1,7)
	
	
	
	local last_radius=brush_radius
	brush_radius=lerp(k_min_brush_radius,k_max_brush_radius,size_slider.position)
	if(brush_radius!=last_radius)update_brush_mask()
	
	
	local last_hardness=brush_hardness
	brush_hardness=lerp(k_min_brush_hardness,k_max_brush_hardness,hardness_slider.position)
	if(brush_hardness!=last_hardness)update_brush_mask()
	

	
	--draw_brush pattern
	
	local brush_x=105
	local brush_y=106	
	
	rectfill(brush_x-k_max_brush_radius,brush_y-k_max_brush_radius,brush_x+k_max_brush_radius,brush_y+k_max_brush_radius,7)
	--local brush_radius=flr(brush_radius)
	
	local int_radius=flr(brush_radius)
	
	for i=-int_radius,int_radius do
		for j=-int_radius,int_radius do
					local target_opacity=mid(brush_mask[i][j]*2.5,0,1)
					if(brush_mode==k_spray_mode)target_opacity*=rnd(1)*.5
					local background_opacity=1-target_opacity
					local r,g,b=1,1,1
					
					r=r*background_opacity+target_opacity*cur_r/k_color_depth
					g=g*background_opacity+target_opacity*cur_g/k_color_depth
					b=b*background_opacity+target_opacity*cur_b/k_color_depth

					local color = rgb_cube[flr(r*k_color_depth)][flr(g*k_color_depth)][flr(b*k_color_depth)]
					pset(i+brush_x,j+brush_y,color[cur_frame%2+1])
		end
	end
		--fillp()
		--rect(brush_x-k_max_brush_radius,brush_y-k_max_brush_radius,brush_x+k_max_brush_radius,brush_y+k_max_brush_radius,6)
	print_center("z:paint",105,122,6)
	
end


function lerp(h1,h2,t)
	t=mid(t,0,1)
	return (h2-h1)*t+h1
end


k_none=0
k_click=1
k_hover=2
k_down=3
function click_in_rect(x1,y1,x2,y2)
	local state=k_none
	if(mouse_x>x1 and mouse_x<x2 and mouse_y>y1 and mouse_y<y2)then
		state=k_hover
		if(not mouse_down and last_mouse_down)then
			state=k_click
		elseif(mouse_down)then
			state=k_down
		end
	end
	return state
end



function new_text_button(ui,label,x,y,func)
	b={}
	b.label=label
	b.x=x
	b.y=y
	b.w=#label*	4+2
	b.h=8
	b.selected=false
	b.hover=false
	b.draw_func=draw_text_button
	b.click_func=func
	b.down_func=null_function
	add(ui,b)
	return b
end
function draw_text_button(b)
	outline_button(b)
	print(b.label,b.x+2,b.y+2,7)
end

function new_icon_button(ui,icon,x,y,func)
	b={}
	b.x=x
	b.y=y
	b.w=8
	b.h=8
	b.icon=icon
	b.selected=false
	b.hover=false
	b.draw_func=draw_icon_button
	b.click_func=func
	b.down_func=null_function
	add(ui,b)
	return b
end

function new_slider_button(ui,label,x,y,b_width,height,length,position,func)
	b={}
	b.x=x
	b.y=y
	b.w=length
	b.h=height
	b.label=label
	b.width=b_width
	b.position=position
	b.click_func=func
	b.draw_func=draw_slider_button
	b.down_func=slider_drag_function
	add(ui,b)
	return b
end

function draw_slider_button(b)
	rectfill(b.x,b.y,b.x+b.w,b.y+b.h,6)
	rect(b.x,b.y,b.x+b.w,b.y+b.h,0)
	
	local active_length=b.w-b.width
	
	local slider_x = lerp(b.x,b.x+active_length,b.position)
	rectfill(slider_x,b.y,slider_x+b.width,b.y+b.h,5)
	rect(slider_x,b.y,slider_x+b.width,b.y+b.h,0)
	print(b.label,slider_x+2,b.y+2,7)

end

function pixel_brush_click(b)
	deselect_buttons()
	b.selected=true
	
	brush_mode=k_pixel_mode
	update_brush_mask()
end

function airbrush_brush_click(b)
	deselect_buttons()
	b.selected=true
	
	brush_mode=k_airbrush_mode
	update_brush_mask()
end

function pen_brush_click(b)
	b.selected=true
	deselect_buttons()
	brush_mode=k_pen_mode
	update_brush_mask()
end

function star_brush_click(b)
	deselect_buttons()
	b.selected=true
	
	brush_mode=k_star_mode
	update_brush_mask()
end

function spray_brush_click(b)
	deselect_buttons()
	b.selected=true
	
	brush_mode=k_spray_mode
	update_brush_mask()
end

function slider_drag_function(b)
	local x_loc=mouse_x
	x_loc-=b.x
	b.position=(x_loc-b.width/2)/(b.w-b.width)
end

function outline_button(b)
	local c1=0
	local c2=5
	if(b.hover)c1=5 c2=6 
	if(b.selected)c=12 c2=8
	rectfill(b.x,b.y,b.x+b.w,b.y+b.h,c1)
	rect(b.x,b.y,b.x+b.w,b.y+b.h,c2)
end

function draw_icon_button(b)
	outline_button(b)
	spr(b.icon,b.x,b.y)
end





function deselect_buttons()
	for b in all(ui) do
		b.selected=false
	end
end

function about_click()
	cls(7)
	mode=k_splash_mode
	render_new_scene()
end

function clear_click()
	new_image()
	update_image(0,0,127,127)
end

function color_click()
	if(color_mode==k_high_mode)then
				color_mode=k_low_mode
				--init_palette_dist()
				--init_rgb_cube()
				reload(0,0,16385)
				load_rgb_cube(k_low_mode)
				update_image(0,0,127,127)
				--draw_screen()
		else
				color_mode=k_high_mode
				reload(0,0,16385)
				load_rgb_cube(k_high_mode)
				update_image(0,0,127,127)
				--draw_screen()
		end
end

function null_function()

end

function init_ui()	
	ui={}
	
	size_slider=new_slider_button(ui,"s",5,96,10,8,81,.5,null_function)
	
	size_slider.position=lerp(0,1,(brush_radius-k_min_brush_radius)/(k_max_brush_radius-k_min_brush_radius))
	
	hardness_slider=new_slider_button(ui,"h",b.x,b.y+b.h+2,10,8,81,.5,null_function)
	hardness_slider.position=lerp(0,1,(brush_hardness-k_min_brush_hardness)/(k_max_brush_hardness-k_min_brush_hardness))
	

	airbrush_brush_button=new_text_button(ui,"bsh",b.x,b.y+b.h+2,airbrush_brush_click)
	pixel_brush_button=new_text_button(ui,"pix",b.x+b.w+2,b.y,pixel_brush_click)
	pen_brush_button=new_text_button(ui,"pen",b.x+b.w+2,b.y,pen_brush_click)
	star_brush_button=new_text_button(ui,"str",b.x+b.w+2,b.y,star_brush_click)
	spray_brush_button=new_text_button(ui,"air",b.x+b.w+2,b.y,spray_brush_click)
	
	
	
	new_text_button(ui,"?",2,1,about_click)
	new_text_button(ui,"color",b.x+b.w+2,1,color_click)
	new_text_button(ui,"save",b.x+b.w+2	,1,save_image)
	new_text_button(ui,"load",b.x+b.w+2,b.y,load_image)
	new_text_button(ui,"export",b.x+b.w+2,b.y,export_image)
	new_text_button(ui,"clear",b.x+b.w+2,b.y,clear_click)
	
	if(brush_mode==k_airbrush_mode)airbrush_brush_button.selected=true
	if(brush_mode==k_pixel_mode)pixel_brush_button.selected=true
	if(brush_mode==k_pen_mode)pen_brush_button.selected=true
	if(brush_mode==k_star_mode)star_brush_button.selected=true
	if(brush_mode==k_spray_mode)spray_brush_button.selected=true
	
end


function draw_ui()
	fillp()
	for i,b in pairs(ui) do
			b.draw_func(b)
	
	end
end

function in_rect(mx,my,x,y,w,h)
	return(mx>=x and mx<=x+w and my>=y and my<=y+h)
end

function update_ui()
	for i,b in pairs(ui) do
		b.hover=false
		if(in_rect(mouse_x,mouse_y,b.x,b.y,b.w,b.h))then
			b.hover=true
			if(not mouse_down and last_mouse_down)b.click_func(b)
			if(mouse_down)b.down_func(b)
		end
	
	end
end


function pause()
	while(not btnp(4))do flip() end
end



----------------------------------------ray trace code-----------------------------------------------

function hit_sphere(center,radius,ray)
	local oc = vec3_sub(ray.origin,center)
	local a = vec3_dot(ray.direction,ray.direction)
	local b= 2*vec3_dot(oc,ray.direction)
	local c= vec3_dot(oc,oc)-radius*radius
	local d = b*b - 4*a*c
	if(d <0)return false

	local t= (-b-sqrt(d))/2.0*a	
	local isect=vec3_scale(ray.direction,t)
	local normal = vec3_unit(vec3_sub(isect,center))
	
	return t,normal
end

k_small_number = .0001
function hit_plane(normal,d,ray)
	if( vec3_dot(ray.direction,normal)>0)return false
	local div=vec3_dot(ray.direction,normal)
	if(abs(div)<k_small_number)return false
	local t = -(vec3_dot(ray.origin,normal)+d)/div
	
	if(t<0)return false
	return t,normal
end


object_list={}
k_sphere=1
k_plane=2

function new_sphere(center,radius,color)
	s={}
	s.center=center or {0,0,0}
	s.radius=radius or 1
	s.color=color or {1,1,1}
	s.type=k_sphere
	s.texture=0
	s.reflect=0
	add(object_list,s)
	return s
end

function new_plane(normal,distance,color)
	p={}
	p.normal=normal or {0,1,0}
	p.distance=distance or 1
	p.type=k_plane
	p.color=color or {1,1,1}
	p.texture=0
	p.reflect=0
	add(object_list,p)
	return p
end

function intersect_object(object,ray)
	if(object.type==k_sphere)t,normal=hit_sphere(object.center,object.radius,ray)
	if(object.type==k_plane)t,normal=hit_plane(object.normal,object.distance,ray)
	return t,normal
end

k_infinity = 500
function intersect_objects(ray)
	local min_t = k_infinity
	local min_normal={}
	local hit_object
	--local color=8
	for k,object in pairs(object_list) do
		local t, n = intersect_object(object, ray)
		--return t,n
		if(t!=false)then

				if(t<min_t and t>0)then
					min_t=t
					min_normal=n
					color=object.color
					hit_object=object
				end

		end

	end
	--if(min_t<=0)return false
	if(min_t>=k_infinity)return false
	return min_t,min_normal,hit_object--color,object
	
end

function render_ray(iray)
	local t,inormal,object=intersect_objects(iray)
	local bright=.5
	local color
	
		if(t!=false)then
				color=object.color
				local intersect_point=vec3_add(iray.origin,vec3_scale(iray.direction,t))
				local shadow_ray = new_ray(intersect_point,light_dir)
				local shadow_t,shadow_normal = intersect_objects(shadow_ray)

				local diffuse = vec3_dot(inormal,light_dir)
				diffuse=mid(diffuse,0,1)
				local spec_reflect = vec3_sub(light_dir,vec3_scale(inormal, 2*vec3_dot(inormal,light_dir)))
				local specular = vec3_dot(spec_reflect,iray.direction)
				specular=mid(specular,0,1)
				specular=specular^3
				
				local ambient = 0
				bright = (diffuse*.5+specular*.5)

				if(object.texture==1)then
					u,v=intersect_point[1]*ca-intersect_point[3]*sa,intersect_point[3]*ca+intersect_point[1]*sa
					u=flr(u/1.5)
					v=flr(v/1.5)
					if( (u+v)%2==0)then
						color=texture_color1
					else
						color=texture_color2
					end
				end
				
				
				
				if(shadow_t!=false)then
					local occlusion = 0--mid(shadow_t/.4,0,1)*.5
					bright*=occlusion --pset(i-1,j-1,15)
				end
				bright = (1-ambient)*bright+ambient

				
				if(object.reflect>0)then --reflective
					local reflect_direction = vec3_sub(iray.direction,vec3_scale(inormal, 2*vec3_dot(inormal,iray.direction)))
					local reflect_origin=intersect_point
					local reflect_ray=new_ray(reflect_origin,reflect_direction)
		
					reflect_color,reflect_bright=render_ray(reflect_ray)
					--bright*=rbright
					--color=rcolor
					
					color=  vec3_add( vec3_scale(color,1-object.reflect),vec3_scale(reflect_color,object.reflect))
					bright= (bright*(1-object.reflect))+(reflect_bright*object.reflect)
				end
				
				--return color,bright
				--step=1
				--rectfill(i,j,i+step-1,j+step-1,color_ramp[color][flr(bright*127)])
				
		else
				--sky color
				color=sky_color
				bright=1-mid(iray.direction[2],0,1)
				--bright=.5
				--rectfill(i,j,i+step-1,j+step-1,color_ramp[4][j])
		end
	return color,bright
end

function render_new_scene()
object_list={}
		
		for i=1,6 do
			local v=flr(rnd(3))
			ball_color={rnd(.8)+.2,rnd(.8)+.2,rnd(.8)+.2}
			ball=new_sphere({rnd(3)-1.5,rnd(2)-1,rnd(3)+2},rnd(.4)+.4,ball_color)
			ball.reflect=flr(rnd(4))/4
		end
		
		--new_sphere({-1,0,3},1,-2)
		--new_sphere({1,0,3},1,12)
		
		light_dir = vec3_unit({rnd(1)-.5,rnd(1),-rnd(1)+.25})
		ground=new_plane({0,1,0},1,{1,1,1})
		ground.texture=1
		ground.reflect=.15
		texture_color1={1,0,0}--{rnd(.8)+.2,rnd(.8)+.2,rnd(.8)+.2}
		texture_color2={1,1,1}--{rnd(.8),rnd(.8),rnd(.8)}
		sky_color={rnd(.8)+.5,rnd(.8)+.5,rnd(.8)+.5}
		
		pattern_angle=rnd(1)
		sa=sin(pattern_angle)
		ca=cos(pattern_angle)
	
	local step=1
		for j=0,127,1 do
			for i=0,127,1 do
				--computer primary ray direction
				local iray=new_ray({0,0,0},vec3_unit({(i-64)/64,(-j+64)/64,1}))
				local color,bright=render_ray(iray)

				color=vec3_scale(color,bright)

						image[i][j]=color
						

			end
			
			
			update_image(0,j,127,j)
			--if(j%4==0)then
				fillp()
				draw_splash()
				print_box("loading:"..flr(j/127*100).."%",64,80,0)
				flip()
				
				update_mouse()
				if(mouse_down)mode=k_paint_mode new_image() update_image(0,0,127,127) tx=mouse_x ty=mouse_y return false
			--end

		end
		
		
end


function rotate_point(point,centroid,a)
	local sa=sin(a)
	local ca=cos(a)
	

	local tp1=vec3_sub(point,centroid)
	tpr={tp1[1]*ca-tp1[3]*sa,tp1[2],tp1[3]*ca+tp1[1]*sa}
	tp1=vec3_add(tpr,centroid)
	return tp1
end
------------------------------------------------end ray trace code-------------------------------------------------

---------------------------------------------start zep 5x6 font
--https://lexaloffle.com/bbs/?tid=32877
fdat = [[  0000.0000! 739c.e038" 5280.0000# 02be.afa8$ 23e8.e2f8% 0674.45cc& 6414.c934' 2100.0000( 3318.c618) 618c.6330* 012a.ea90+ 0109.f210, 0000.0230- 0000.e000. 0000.0030/ 3198.cc600 fef7.bdfc1 f18c.637c2 f8ff.8c7c3 f8de.31fc4 defe.318c5 fe3e.31fc6 fe3f.bdfc7 f8cc.c6308 feff.bdfc9 fefe.31fc: 0300.0600; 0300.0660< 0199.8618= 001c.0700> 030c.3330? f0c6.e030@ 746f.783ca 76f7.fdecb f6fd.bdf8c 76f1.8db8d f6f7.bdf8e 7e3d.8c3cf 7e3d.8c60g 7e31.bdbch deff.bdeci f318.c678j f98c.6370k def9.bdecl c631.8c7cm dfff.bdecn f6f7.bdeco 76f7.bdb8p f6f7.ec60q 76f7.bf3cr f6f7.cdecs 7e1c.31f8t fb18.c630u def7.bdb8v def7.b710w def7.ffecx dec9.bdecy defe.31f8z f8cc.cc7c[ 7318.c638\ 630c.618c] 718c.6338^ 2280.0000_ 0000.007c``4100.0000`a001f.bdf4`bc63d.bdfc`c001f.8c3c`d18df.bdbc`e001d.be3c`f3b19.f630`g7ef6.f1fa`hc63d.bdec`i6018.c618`j318c.6372`kc6f5.cd6c`l6318.c618`m0015.fdec`n003d.bdec`o001f.bdf8`pf6f7.ec62`q7ef6.f18e`r001d.bc60`s001f.c3f8`t633c.c618`u0037.bdbc`v0037.b510`w0037.bfa8`x0036.edec`ydef6.f1ba`z003e.667c{ 0188.c218| 0108.4210} 0184.3118~ 02a8.0000`*013e.e500]]
cmap={}
for i=0,#fdat/11 do
 local p=1+i*11
 cmap[sub(fdat,p,p+1)]=
  tonum("0x"..sub(fdat,p+2,p+10))
end

function pr(str,sx,sy,col)
 local sx0=sx
 local p=1
 while (p <= #str) do
  local c=sub(str,p,p)
  local v 

  if (c=="\n") then
   -- linebreak
   sy+=9 sx=sx0 
  else
      -- single (a)
      v = cmap[c.." "] 
      if not v then 
       -- double (`a)
       v= cmap[sub(str,p,p+1)]
       p+=1
      end

   --adjust height
   local sy1=sy
   if (band(v,0x0.0002)>0)sy1+=2

   -- draw pixels
   for y=sy1,sy1+5 do
       for x=sx,sx+4 do
        if (band(v,0x8000)<0) pset(x,y,col) 
        v=rotl(v,1)
       end
      end
      sx+=6
  end
  p+=1
 end
end

function pr_center(string,sx,sy,c)
	pr(string,sx-6*#string/2,sy,c)
end

function pr_rainbow(string,sx,sy,c)
	

	pr_center(string,sx,sy-1,14)
	
	pr_center(string,sx,sy+1,2)
		pr_center(string,sx,sy,1)
	
end

function print_center(string,sx,sy,c)
	print(string,sx-4*#string/2,sy,c)
end

function print_box(string,sx,sy,c)
	x1=sx-4*#string/2-2
	y1=sy-2
	x2=x1+4*#string+2
	y2=sy+6
	
	rectfill(x1,y1,x2,y2,7)
	rect(x1,y1,x2,y2,1)
	print_center(string,sx,sy,c)
end
------------------------------------end font

function draw_splash()
		for i=0,30 do
			rectfill(i,17,127-i,28,i/2+cur_frame)
		end
		rectfill(14,17,127-15,28,7)
		rect(14,17,127-15,28,1)
		pr_rainbow("hypercolor paint",64,20,6)
		print_box("painting the future",64,30,1)
		
		print_box("click to start  'z': palette",64,111,0)
		print_box("'tab': toggle color mode",64,121,0)

end

function save_image()

	nibble_index=0
	for i=0,105 do
		for j=0,105 do
			local px=i+11
			local py=j+11
			
			local r=image[px][py][1]
			local g=image[px][py][2]
			local b=image[px][py][3]
			
			r=flr(r*k_color_depth+.5)
			g=flr(g*k_color_depth+.5)
			b=flr(b*k_color_depth+.5)
			
			write_nibbles({r,g,b})
			
			--cstore dest_addr source_addr len [filename]
		end
	end
	cstore(0,0,16854,"hyper_color_save.p8")
	reload(0,0,16854)
	update_image(0,0,127,127)
end


function load_image()

	nibble_index=0
	reload(0,0,16854,"hyper_color_save.p8")
	new_image()
	for i=0,105 do
		for j=0,105 do
			local px=i+11
			local py=j+11
			
			local r=read_nibble()/k_color_depth
			local g=read_nibble()/k_color_depth
			local b=read_nibble()/k_color_depth
			
			image[px][py]={r,g,b}
			

			
			--cstore dest_addr source_addr len [filename]
		end
	end

	reload(0,0,16854)
	update_image(0,0,127,127)
end

function export_image()

	cstore(k_screen_1_adr,k_screen_1_adr,k_screen_len,"hyper_color_export.p8")
	cstore(k_screen_2_adr,k_screen_2_adr,k_screen_len,"hyper_color_export.p8")


end

function import_image()

end





function _init()
	cur_frame=0
	cls()
	poke(0x5f34, 1)
	
	
	init_mouse()
	

	load_rgb_cube(k_high_mode)
	--init_palette_dist()
	--init_rgb_cube()
	

	
	
	new_image()
	new_image_mask()
	
	--render_new_scene()
	
	update_image(0,0,127,127)
	count=0
	update_brush_mask()
	
	if(mode==k_splash_mode)render_new_scene()
	
end






function _update60()

	--nothing goes in update because screen update needs to be tied to draw function
end

k_splash_mode = 3
k_paint_mode = 1
k_color_picker_mode = 2
mode=k_splash_mode--k_splash_mode

k_high_mode = 1
k_low_mode = 2
color_mode=k_high_mode
function _draw()
	cur_frame+=1
	--cls()
	update_mouse()
	
	if(mode==k_paint_mode)then
	draw_screen()
	handle_brush()
	--if(btnp(4)) mode=k_color_picker_mode init_ui()
	end
	
	
	if(mode==k_color_picker_mode)then
	draw_screen()
	draw_color_picker()
	draw_ui()
	update_ui()
	--if(btnp(4)) mode=k_paint_mode

	end
	
	if(btnp(4))then
		if(mode==k_color_picker_mode)then mode=k_paint_mode
		elseif(mode==k_paint_mode)then mode=k_color_picker_mode init_ui()
		elseif(mode==k_splash_mode)then mode=k_color_picker_mode init_ui() new_image() update_image(0,0,127,127) init_mouse()
		end
	end
	
	
	if(btn(4,1))then
		if(color_mode==k_high_mode)then
				color_mode=k_low_mode
				--init_palette_dist()
				--init_rgb_cube()
				reload(0,0,16385)
				load_rgb_cube(k_low_mode)
				update_image(0,0,127,127)
				--draw_screen()
		else
				color_mode=k_high_mode
				reload(0,0,16385)
				load_rgb_cube(k_high_mode)
				update_image(0,0,127,127)
				--draw_screen()
		end
	end
	
	--hit 'q' to bring up splash screen and spheres
	--if(btnp(5,1))then
	--	if(mode!=k_splash_mode)then
	--	
	--		mode=k_splash_mode
	--		
	--		
	--		
	--		render_new_scene()
	--	else
	--		mode=k_paint_mode
	--		new_image()
	--		update_image(0,0,127,127)
	--	end
	--end
	
	if(mode==k_splash_mode)then
		draw_screen()
		
		draw_splash()
				
		
		
		if(mouse_down)then
			mode=k_paint_mode
			new_image()
			update_image(0,0,127,127)
			init_mouse()
		end
	end

	--render_image_mask()
	
	--rectfill(0,120,64,127,0)
	--print(stat(1),0,122,8)
	--print("m:"..stat(0)/2048,28,122,9)
	--fillp()
	draw_mouse()
	
	
	

end


__gfx__
0000010010000001001000000110110011011011001101101100110110110011111111111111111100030e10a000010510110011011011001101101100110110
1111111111111111111111111111111100030b309000130b30c100130c30c100131c111111111111111111111111111111111111111111110003083070001306
307100130731c1101310111111131c31c111131c31d111131d31d111131d31d10033013013003301301300331130511113173171111317317111131731711113
18318111cc11c11c003311b0f3013b0e3353013317303311331131131133113113111c14311311cc11c11c11cc11c11c033b1db0c3013b1bb09330331a337331
3316c1b3113c18c163113c13c11c11cc11c11c11cc11c11c033b3bb0b3013b18b06331331c33c331331cc3b3313c3831cc13c31ec11c11cc31c1bc13cc3bc1bc
033b39b093313b3133133333313313333c3dc3b3133c37c15313cc35c15c13cc35c16c13cc36c16cb0b339b07313bb3ab1ab333b3ab3b33b3c3dc3a3333c37c3
5333cc31c31c33cc31c31c33cc31c31c13bb34b14b13bb35b15b333b35b15b33bc3bc39b33bc37c35b3bccbcc3ecc3cc37ccacc3cc3cccfc33bb31b31b33bb31
b31bb3bbb3c3eb3bbcbbc38b3bcb3bbc8c3bccb7c38ccbccb8ccaccbcccdcb3cb0b31ebbebb3bb3bbbabb3bb38cbcb3bcbb7cb7bbbbcb5cb1cbbccb1cb1ccbcc
b7ccaccbccbcccecbbbbb1bb1bbbbb31bbfbbbbcbecbcbbbbcbacb8bbbbcb5cb3bbbccb1cb1cbbccb1cb1cbbccb1ccecbbbbb1bb1bbbbbb1bb1bbbbbb1bb1b7b
bbb4b75bbbbcb6cb4bbbccb1cb1c7bccb3c74c7bccb5c75cbbbbb1bb1bbbbbb1bb1bb7bb70bbfbb7bb7ebbdb7bbbb6b77b7bbb78cbabb7bc79cb8b7bccb5c76c
00020e20c000020a209000110110110011011011001101101100120f20f11111111111111111111100050c50b000010410110011011011001101200111111111
1111111111111111111111111111111100130d30d100130d116110110a11f1111111111111111111111111111111111111111111111111110013083062002306
306210130b31e111131d31d111131e31e111131e31e111131e31e1121d2bd1a100340d40d3003d1e50c301351b3181111318c1b1111c19c171111c1531521123
15c11c11cc11c11c043b2eb0e3023b3d50b30133163113113311c073111c17c151111c14c11c11cc11c11c11cc11c11c053b5db0c3013b1ab093113b1bb1d311
3c1dc1a3113c18c153113c12c11c11cc11c11c11cc11c11c053b5ab0a3013b17b063113b2633c313d316c3a313c31bc353313c33c1cc13cc3cc1cc13cc3cc1cc
313b11b313313b11b313313b21b3d3353c5dc3b313cb3bc15313cc37c17c13cc17cc9cc1cc3bc17c13bb3bb1bb13bb3bb1bb13bb3bb38513cb37c19b13bc36c3
4333cc31c31c33cc11ccbcc1cc1dccfc13bb36b25b35bb5bb3bb35bb5bb3bb33bc3bc39bb3bcb5c3ac3bccbcc3ec3ccc3accacc3cc3dcc0c34bb4cb3db39bb9d
b3eb3bbdbec3db3bbcbac38b1bbcb5c35c3bccb7cc6ccbccb9ccbccbccbdccfcb5bb5dbbcbb5bb5cbbcbb5bbbbdbabbbbcb9cb6bbbbcb4cb1cbbccb1cc6ccbcc
b8ccaccbccbcccfcb4bbbeb94b9bbbb3dbfbb6bbbecbcbbbbcb9cb7bbbbcb5cb2bbbccb1c73c7bccb4c75c7bccb6c77cbabbaebbebbabbaebbebb7bb7ebbdb7b
bbb5b76bb7bc7ccbbbb7bc7acb9b7bccb4c75c7bccb6c77cbabbaebbebbabbaebbebb7bb7ebbdbb7bb7cbbbbb7bbbab78b7bbb79cb9bb7bc79cb8b7bccb6c77c
00080d80c000080c80b000180e80e100180e80e100120a20a100121a11111111111111111111111100040b209000120a20a100120a20a100121a111111111111
11111111111111121e21e111121e21e100140a5071001507508110120c21f1111111111111121f21f111121f21f111121f21f111128fd1d10035065063003506
5063101d1c51d111151dd1b1111d2ad1c1121d2cd1b1121d2ad1a1121d19d11d00340a40b301341c50a30135183172112317c1b1111c19c171111c15c13111cc
11c11c11cc11c11c03343d40c303343b40a311342d31a3113d1bd193111c17c151111c13c11c11cc11c11c11cc11c11c043b4bb0b3023b29b093133537518313
3d5ac1b3113c17c14311cc11c11c11cc11c11c11cc11c11c043b5ab093114b2531cb13b5385363333516c19b11bc56b1ec13cc3dc1dcc1ccc6d1ac13cccee1dc
13b42db1ab12bb2ab1ab12bb3ad1bb15bc5bc19b335c37c18c13cc38c26cc1cc18ccacc1cc1bccdc15bb55b15b15bb56b16b353bb5d1ab35cb57b39c35cb4cb3
ec3ccdced3ccc3cc18ccbcc1cc1dccfc35bb56b36b34bb4ab3ab34bbbbc5db5bbccbd3bb3bcdbac3ac5bcc58bcbcc5cbccc37cc3cccdcc1cb5bb59bb8bb5bbb8
b5ab5bbbbbdb7bbbbdb6c57bbbcdbbc55cbccdbdcc7ccbccb9ccbccbcccecc1cb4bb4bbbbbb4bb4bbbbbbbbdbadb9b3b6bb8c95b6bbcb5c64b6bccb4c65c6bcc
b6ccbcc7cb7ebc0c9bbbb6b96b9bbb95bbdbb6bb6cbbbbb6bb6acbbb7bbcb4c74b7bbcb4c74c7bccb5c76c7bccb7c78cabbba5bbcbbabbacbbcbb7bb7dbbcbb7
bbbbb78b7bbb79cbabb7bc7acb9bb7bcb8c76c7bccb7c78cbabbacbbcbbabbacbbcbb7bb7dbbcbb7bb7bbbabb7bbb9b7ab7bbbbbb7cbb7bc78cb7bb7bcb6c78c
00080b80a000080a809000180b80b100180c80c100180c205111181d81d111181d81d111181d81d100040920600012052051001205205110180e81f111181d81
d111181d81d111181d219111121921910004084081002506507210120981e11112192191111219219111121921911112192191181d8cd1c10034074073003408
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
1551551551d17d16c2ac29c28c27c27c26533533534534534534d5dc5dc5cc2ac29c28c28c27c26c25438439439439439439d38d37d36d35c59c28c27c26c25c84b5bb5cb5c93b93cd39d38d37d36c48dc6dc7dc8dcadcbdccb49b49b49b49b49db8db7db7db6db5dc7dc8dc9dcadcceceb48b48b48b48db9db9db8db7db7639
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
