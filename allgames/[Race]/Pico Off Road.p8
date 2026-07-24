pico-8 cartridge // http://www.pico-8.com
version 30
__lua__
-- pico off road
-- by assembler bot (2021)
function lz77_decomp(x0,y0,w,h,src,vset)
	local i,d=1,{}
	while i<=#src do
		local c=ord(src,i)
		if c<48 then
			add(d,c-32)
		else
			local ofs,run=w,c-46
			if c>=94 then
				run-=29
			end
			if run>=103 then
				run-=101
			else
				i+=1
				ofs=ord(src,i)-31
				if ofs>=63 then
					ofs-=29
				end
			end
			local pos=#d-ofs
			for j=1,run do
				add(d,d[pos+j])
			end
		end
		i+=1
	end
	for i=0,w*h-1 do
		vset(i%w+x0,i\w+y0,d[i+1])
	end
end



hpi=1.57075
pi=3.1415
pi2=6.283

cos1 = cos function cos(angle) return cos1(angle/(pi2)) end
sin1 = sin function sin(angle) return -sin1(angle/(pi2)) end
atan21 = atan2 function atan2(x,y) return atan21(x,-y)*pi2 end

function isometry(x,y,z)
	return x+511-z/2, z/2-y
end

function clamp(a,min_value,max_value)
	return min(max(a,min_value), max_value)
end

function rotate(x,y,angle)
	local c=cos(angle)
	local s=sin(angle)
	return x*c-y*s,x*s+y*c
end

function rotatesincos(x,y,s,c)
	return x*c-y*s,x*s+y*c
end

function cross(x1,y1,z1,x2,y2,z2)
	return y1*z2-z1*y2, z1*x2-x1*z2, x1*y2-y1*x2
end

function dot(x1,y1,z1,x2,y2,z2)
	return x1*x2+y1*y2+z1*z2
end

function normalize(x,y,z)
	local d=1/sqrt(x*x+y*y+z*z)
	return x*d,y*d,z*d
end

function normalize2d(x,y)
	local d=1/sqrt(x*x+y*y)
	return x*d,y*d
end

function lerp(a,b,t)
	return a+(b-a)*t
end


function project_vertices(vertices_in, vertices_out, offset_x,offset_y)
	for i=1,#vertices_in do
		vertices_out[i]={x=flr(vertices_in[i].x+0.5*vertices_in[i].z)+offset_x,y=flr(vertices_in[i].y-0.5*vertices_in[i].z)+offset_y}
	end
end

function sort_triangles(vertices,triangles)
	local triangles_count=#triangles/4
	for i=0,triangles_count-2 do
		local z1=(vertices[triangles[1+i*4]].z+vertices[triangles[2+i*4]].z+vertices[triangles[3+i*4]].z)/3
		local best_i=i
		local best_z=z1
		for j=i+1,triangles_count-1 do
			local z2=(vertices[triangles[1+j*4]].z+vertices[triangles[2+j*4]].z+vertices[triangles[3+j*4]].z)/3
			if z2>best_z then
				best_i=j
				best_z=z2
			end
		end
		if best_i~=i then
			for j=0,3 do
				triangles[1+i*4+j],triangles[1+best_i*4+j]=triangles[1+best_i*4+j],triangles[1+i*4+j]
			end
		end
	end
end

function cull_triangles(vertices,triangles,dir_x,dir_y,dir_z)
	local out={}
	local triangles_count=#triangles/4
	for i=0,triangles_count-1 do
		local nx,ny,nz = calc_triangle_normal(vertices,triangles,i)
		if dot(nx,ny,nz,dir_x,dir_y,dir_z) < 0 then
			for j=1,4 do
				add(out,triangles[j+i*4])
			end
		end
	end
	return out
end

function calc_triangle_normal(vertices,triangles,idx)
	local i1=triangles[1+idx*4]
	local i2=triangles[2+idx*4]
	local i3=triangles[3+idx*4]
	return cross(vertices[i3].x-vertices[i1].x,vertices[i3].y-vertices[i1].y,vertices[i3].z-vertices[i1].z,vertices[i2].x-vertices[i1].x,vertices[i2].y-vertices[i1].y,vertices[i2].z-vertices[i1].z)
end

function draw_triangles(vertices2d,triangles)
	local triangles_count=#triangles/4
	for i=0,triangles_count-1 do
		draw_triangle(vertices2d[triangles[1+i*4]],vertices2d[triangles[2+i*4]],vertices2d[triangles[3+i*4]],triangles[4+i*4]-1)
	end
end

function draw_triangle(v1,v2,v3,colour)
	local x1,y1,x2,y2,x3,y3=v1.x,v1.y,v2.x,v2.y,v3.x,v3.y
	if x1==x2 and y1==y2 then
		pset(x1,y1,color)
		return
	end

	if y2<y1 then
		x1,y1,x2,y2=x2,y2,x1,y1
	end
	if y3<y2 then
		x2,y2,x3,y3=x3,y3,x2,y2
	end
	if y2<y1 then
		x1,y1,x2,y2=x2,y2,x1,y1
	end
	
	local y=y1
	local dxl=(x2-x1)/(y2-y1)
	local dxr=(x3-x1)/(y3-y1)
	local xl,xr=x1,x1
	
	while y<y2 do
		rectfill(xl,y,xr,y,colour)
		xl+=dxl
		xr+=dxr
		y+=1
	end
	
	xl=x2
	dxl=(x3-x2)/(y3-y2)
	while y<=y3 do
		rectfill(xl,y,xr,y,colour)
		xl+=dxl
		xr+=dxr
		y+=1
	end
end



transparent_patterns={
	0b1111111111111111.1,
	0b0101111101011111.1,
	0b0101111001011110.1,
	0b0101101001011010.1,
	0b0101100001011000.1,
	0b0101000001010000.1,
	0b0100000001000000.1,
	0b0000000000000000.1
}

function set_transparent_pattern(alpha)
	fillp(transparent_patterns[ceil(clamp(alpha*(#transparent_patterns-1),0,#transparent_patterns-1))+1])
end

function draw_sprite4(sx,sy,sw,sh,dx,dy)
	for ry=0,sh-1 do
		for rx=0,sw-1 do
			local c=sget(rx+sx,ry+sy)
			if c~=0 then
				rectfill(dx+rx*4,dy+ry*4,dx+rx*4+3,dy+ry*4+3,c)
			end
		end
	end
end

function printo(text,x,y,c)
	local d={0,0,-1,1,0,0}
	for j=1,4 do
		print(text, x+d[j+2], y+d[j], 0)
	end
	print(text, x, y, c)
end

function time_str(t)
	return tostr(num_to_str2(t\60)..":"..num_to_str21(t%60))
end

function num_to_str2(n)
	return tostr(n\10)..flr(n%10)
end

function num_to_str21(n)
	local tenths=flr((n%10)*10)
	return tostr(n\10)..tenths\10 .."."..tenths%10
end

function lap_to_str(lap)
	if lap==-1 then
		return ""
	end
	return "l"..(lap+1)
end

function draw_progress(x1,y1,x2,v,c1,c2)
	local y2=y1+3
	line(x1+1,y1,x2-1,y1,0)
	line(x1+1,y2,x2-1,y2,0)
	line(x1,y1+1,x1,y2-1,0)
	line(x2,y1+1,x2,y2-1,0)
	
	x1+=1
	x2-=1
	local x=flr(x2-(x2-x1)*v)
	if x>=x2 then return end
	
	line(x,y1+1,x2,y1+1,c1)
	line(x,y1+2,x2,y1+2,c2)
end




racing_map1=[[ˆ^:ÛÓÏ^<ùzû;ùùû:ùûû9ùüû.˜¯ùr»»›^ ﬁﬂc!««ùbû'›û#ú#›ùmû&ú ››ùb°&ô û#ú"ù*Ì®"c#≤(Ω^ ù*û ® ú"∆∆⁄’”æ^#”‘’”^ c#a(ù&û"ù!›¶%∆∆›ù_≈ù0ß ú ù_≈ù)‡‡ù%ú!ù^≈≈Ωù(··ù$ú"ù@ú ù)í!ù"g"ù^Ωù$ì'ù"b#ÛÓπ#º Ìh"c#a(ú ù#û"ù8f5ùzƒù%û!›‡‡›…ùgΩƒƒù)··›…û(ù)”^"æ^)p Ωû º%ù ›ú ››ù2√ù4Ωù*ú!£ t   ù,û"ù0ΩÅ&ˆú%ù   Ωù+”û"ù;ˆú$›ú!ù-û"ù-`!Å'ˆú$›ú!ù.û!ù-ô'ù"^%ù3ã,k0û%›ú ùvˆ›^ ùmû&ù≤û$˘‡^ ˘ùnü#˙·^ ˙ù@Ì(û)›^ ˆù-¬¬¨$ÈÁ^$Ë‘’µ!a$¡¡ù:¬¬â%–Œ^$œù)¡¡”º#ù3ú'ù3ú ù9ú'‘’ù'∞&ú"ù#ú ù1à&ù2ú"ù+›ù*ú&ù2ú#ù#û!ù!ÀÀù?º$ú$ù*ÀÀ›⁄’º"ÃÃ§'º ÌÓÈÁ^$Ëù%ª ÷÷÷ù$û ú"ù$ÃÃu%d7ù ◊◊◊ù(ú!ù#ú ù_`!º%ˆú"ù"ú!ùl^#ÛÓÏÏú!ù@÷÷÷Ö)ù'µ*ù7◊◊◊ù3û"ù?^#º'ù∫û"ù•÷^!Ö*ùh◊^!ù6û=¿¿É"Ñ+ù(ÕÕÏÌ©!§.î#””û$ù4ÕÕ””‘’â%”øg&f'û#º+ù%ú!ù$Ω`!ù e"û/ù2ú"ù$ë"ù _0û!ù+Ïù"ú#ê)ù3û!ù2ú(Ω`"øe$û/ù,Ïù!Ö/øØ'é-ù0Ä:]]
waypoints_racing_map1=15
starts_racing_map1=split('3763,3954,3760,3951,3959,3768,3962,3771')
racing_map2=[[Ï^ˇºìÈÁ^"Ëº!ÌÓº@«”^*–Œ^"œs!‘’y+”»»ù0û+ù5Ω^ »»”ù/”û)‘’ù4ú#Ωù1û)ù9ú ù3û(ù8ú!ù4û'ù6”ú#ù4¥&ÌÓÈÁ^"Ëk#å'»®#ù.Ô÷÷÷¥1Ü-ú!à Ôû-◊◊◊”∆∆û_à ∂1∆∆””ù^† µ1ú!””≈≈5ù<ú+ùkú,ùlú+ù5Ô÷÷÷ª6ú(ù5◊◊◊ù7∫ ª!ù8Ïª:∫ ª!ùsô$ùŸ÷÷÷Ôùv◊◊◊º+Ò^"ÔÔ∑ `%ÔÔr!ù2ª/ù#ÒÒÿ^'∞#ùaû%ùù…^"ì*d'ù!æ^ ΩΩΩù^Ìù/õ!ú!û#Óù/”^#ù&ÚÛ¢(õ"ù#ƒƒù$Ì¢+“^#Ï”¬¬”‘ÿÿÿŸ⁄b ¡¡ù-ƒƒ¢ ÿ’”””‘b!`#√√”–Œ^#œù'ΩΩ¡¡ÿù,ú"ùb¡¡ΩΩù)ú%ù(¢#ù1ÿÿú!ù)ú&ù#`"ù8ú"ù$ÿù"ú%ù_¡¡ÿù,ƒƒ¥!a"ù8Ï^ ÌÒÒú ã"ù#c-ÓÉ!á"g%Í—^"ÍËù$õ#ù>e'”^"µ#í!ù:Òù/ ^"ù4å/ù<◊^#ùa”^"m-n(°0ÌÓa#º Àù ÷÷÷Ôº&æ^#ù1Ω^"º ‘’a#ô Àû ◊◊◊ù^Ãû#Ωù)û"””å'ù9û#ô#ù%û#ù_Ωû%ù*û"ù'≥$ù2û#ô#ù'û!ù&Ô÷÷µ ÷÷Ôù2û$ù,û ù&◊◊µ ◊◊ù3Ω¥"ÌÓa#_1≥$z1ù&b9ù’∂6≤(¿Ω^#∏5ÕÕû4∫"ΩΩ¿û$ù4ÕÕÖ"b&øl+ô û$ù3ú)Ω`!ù e"ù'û$ù2ú)¶#ù p)ù!û#ù1ú/ù2û"ù2à*`"øe$∂+¿¿”ù1Ñ-¨ ø∞&é1qf]]
waypoints_racing_map2=15
starts_racing_map2=split('3764,3955,3761,3952,3960,3769,3963,3772')
racing_map3=[[Ò^^Ï^7ùzû_ùñû@Óùóû2ê"Ìùiæ««ÿ^$’æ^ ‘j%”^$Ω»»Ω^ û5ÿû!ñ ù5ú$ù7û!ú"ù3ú$ù.û%ñ û%ù1ú%”ù6ò æ«™"Óº!Ìµ$j"ÏÏú$ù0û$ÿû ææ™$d(ù$”ù>ú!ÿù6Ïõ#”ù0û"Ù€^ ææù7ò `"ù4ı‹^ ÿÿÿù>û1†!ÿÿæææÿ∆∆ê&Ìù*ú&û w ≥#Ω^!≈ù$õ ú ÿ^ ’ß ææ‘h!j ó(¢$w s ö"ú ù%ó ú#ùg≈≈”ù&ú!ææùaú%Ωù&ú õ!ùfú ù&ú ÿû#ùcú!ù#ÏÒú"ê$ùc¢!ù$^(ÓØ"Ìj)Ï£&w#s$ù'û*™/ÏÏ…^$l$ù.c=ù%û)ƒùd”^'ù(û!ù2”√√è(h1ó ΩΩû!ù3û>ù"û!ù4û=ù#û ù5û<ù!ó1ù'”√n-≥!ë7ù.â)ùzû&º"ÌÓùk ^$ñ<ù*û)ù%û)ÁÁËÌÓÆ2æ^"¬¬Æ-≤#ÌÓÈÁ^!ŒŒœ‘’w#¡¡v!ù+¬¬ææï(†'‘’–Œ^#ù%ú!ù-ú!ùaú"ù,ú7ù)º"ú#ù+ú"ù4””ù*ú$ù*ú;ù*ú%ù)ú#û7ù#ÁÁËë ú%ù)h.¶&Ç#ÈÁ^!x2û<xhùÉÀÀùp”ÃÃº#û%ù4÷^ Ôπ2û,ù4◊^ π3û+ù4∏4π"û*ùm”Ã∑1ù_Ô÷^ ∑3ù_◊^ ù=Ω^#É2∑6ùgû4ÒÒÓ∑ ¿¿ù>ÕÕπ/ÌÒÒÿÿ’ò!û$ù7ÕÕ§#™"øi$‘ÿ^ ù"û$ù6ú&Ω`!ù e"ù(û#ù5ú&£#ù ¨"ù)û"ù4ú,ù3û ”ù3ú(Ω`"øe$ù#π&û ù1ú(•$ø≠$ù ÒÒÓë1q`ÌÒÒ]]
waypoints_racing_map3=15
starts_racing_map3=split('3763,3954,3760,3951,3959,3768,3962,3771')



tiles_w=64
tiles_h=64

function tiles_init(compressed_map,waypoints_count,start_indexes)
	tiles_type={}
	tiles_height={}
	tiles_waypoints={}
	
	waypoints={}
	for i=1,waypoints_count do
		add(waypoints,{})
	end

	dec={}
	local i=1
	while i<=#compressed_map do
		local c=ord(compressed_map,i)
		if c>=189 then
			add(dec,c)
			i+=1
		else
			local ofs=c-93
			c=ord(compressed_map,i+1)
			local l=c-32+3
			if l>=65 then
				l-=29
			end
			
			local start=#dec-ofs;
			for j=1,l do
				add(dec,dec[start+j])
			end
			i+=2
		end
	end
	
	local tile,height
	for i=1,#dec do
		local v,waypoint=dec[i],-1
		if v==189 then 
			tile=11
		elseif v==190 then
			tile=12
		elseif v<=205 then
			tile=11
			local tx,tz=tile_index_to_position(#tiles_type-1)
			waypoint=v-191
			add(waypoints[waypoint+1],tx)
			add(waypoints[waypoint+1],tz)
		elseif v<=230 then
			tile = (v-206)%5 + 1
			height = (v-206)\5*8
		else
			tile = (v-231)%5 + 1 + 5
			height = (v-231)\5*8
		end
		
		add(tiles_waypoints,waypoint)
		add(tiles_type,tile)
		add(tiles_height,height)
	end

	build_collision_solutions()
		
	tile_height_func={
		tile_flat,
		tile_ascend_px,
		tile_ascend_mx,
		tile_ascend_pz,
		tile_ascend_mz,
		tile_flat,
		tile_ascend_px,
		tile_ascend_mx,
		tile_ascend_pz,
		tile_ascend_mz,
		tile_flat,
		tile_flat_rough,
	}
	
	start_positions={}
	for i=1,#start_indexes do
		local x,z=tile_index_to_position(start_indexes[i])
		add(start_positions,x)
		add(start_positions,z)
	end
end

function build_collision_solutions()
	tile_cs={}
	for z=0,tiles_h-1 do
		for x=0,tiles_w-1 do
			local sx,sz=collision_solution(x,z,"11111111112202121120001011210111")
			add(tile_cs,sx)
			add(tile_cs,sz)
		end
	end
	
	local filtered_solution={}
	for z=0,tiles_h-1 do
		for x=0,tiles_w-1 do
			local sx,sz=collision_solution_filter(x,z)
			add(filtered_solution,sx)
			add(filtered_solution,sz)
		end
	end
	
	tile_cs=filtered_solution
end

function collision_solution(x,z,cmbn)
	local t=tiles_type[x+z*tiles_w+1]
	if not tile_is_obstacle(t) then
		return 0,0
	end
	
	local mx=tile_is_obstacle_number(get_tile_type(x-1,z))
	local px=tile_is_obstacle_number(get_tile_type(x+1,z))
	local mz=tile_is_obstacle_number(get_tile_type(x,z-1))
	local pz=tile_is_obstacle_number(get_tile_type(x,z+1))
	
	local index=1+mx+px*2+mz*4+pz*8
	return ord(cmbn,(index-1)*2+1)-49,ord(cmbn,(index-1)*2+2)-49
end

function collision_solution_filter(x,z)
	local t=tiles_type[x+z*tiles_w+1]
	if not tile_is_obstacle(t) then
		return 0,0
	end
	
	local sx,sz=get_collision_solution(x,z)
	if sx~=0 or sz~=0 then
		return sx,sz
	end
	
	local dx,dz
	dx,dz=get_collision_solution(x-1,z)
	sx+=dx sz+=dz
	dx,dz=get_collision_solution(x+1,z)
	sx+=dx sz+=dz
	dx,dz=get_collision_solution(x,z-1)
	sx+=dx sz+=dz
	dx,dz=get_collision_solution(x,z+1)
	sx+=dx sz+=dz
	
	if sx==0 and sz==0 then
		return 0,0
	end
	
	return normalize2d(sx,sz)
end

function get_tile_type(tx,tz)
	return tiles_type[tilec_rot(tx,tiles_w)+tilec_rot(tz,tiles_h)*tiles_w+1]
end

function get_collision_solution(tx,tz)
	local index=(tilec_rot(tx,tiles_w)+tilec_rot(tz,tiles_h)*tiles_w)*2+1
	return tile_cs[index],tile_cs[index+1]
end

function sample_collision_solution(x,z)
	local index=(tilec_rot(flr(x/8),tiles_w)+flr(z/8)*tiles_w)*2+1
	local sx,sz=tile_cs[index],tile_cs[index+1]
	if sx==nil or sz==nil then
		return 0,0
	end
	return sx,sz
end

function sample_tile_map(x,z)
	local tx=tilec_rot(flr(x/8),tiles_w)
	local tz=clamp(flr(z/8),0,tiles_h-1)
	local index=tx+tz*tiles_w+1
	return tiles_type[index],tile_height_func[tiles_type[index]](x%8,z%8)+tiles_height[index],tiles_waypoints[index]
end

function tilec_rot(x,w)
	if x<0  then x+=w end
	if x>=w then x-=w end
	return x
end

function tile_flat(x,z)
	return 0
end
function tile_flat_rough(x,z)
	return ((x>>1)^(z>>1))&1
end
function tile_ascend_px(x,z)
	return x
end
function tile_ascend_mx(x,z)
	return 7-x
end
function tile_ascend_pz(x,z)
	return z
end
function tile_ascend_mz(x,z)
	return 7-z
end

function tile_is_obstacle(t)
	return t>=6 and t<=10
end

function tile_is_obstacle_number(t)
	if tile_is_obstacle(t) then return 1 else return 0 end
end

function tile_is_dirt(t)
	return t==11
end

function height_is_water(y)
	return y<2
end

function tile_index_to_position(index)
	local x=index%tiles_w
	local z=index\tiles_w
	if x>=z\2 then
		x-=tiles_w
	end
	return x*8+4,z*8+4
end








sprite_map_w=64
sprite_map_h=32
sprite_map_x=0
sprite_map_y=0
second_sprite_map_x=64
second_sprite_map_y=0

function sprite_map_init(tx,ty)
	sprite_map_x=tx
	sprite_map_y=ty
	for y=0,sprite_map_h-1 do
		for x=0,sprite_map_w-1 do
			local sprite=mget(tx+x,ty+y)
			if sprite>=64 and fget(sprite,1) then
				mset(tx+x,ty+y,sprite-64)
				mset(second_sprite_map_x+x,second_sprite_map_y+y,sprite)
			else
				mset(second_sprite_map_x+x,second_sprite_map_y+y,0)
			end
		end
	end
end

function sprite_map_draw(ofs_x,ofs_y)
	map(sprite_map_x,sprite_map_y,ofs_x,ofs_y,64,32)
end

function second_sprite_map_draw(ofs_x,ofs_y)
	map(second_sprite_map_x,second_sprite_map_y,ofs_x,ofs_y,64,32)
end




function shadows_init(shading)
	local shadow_color=split(shading)
	for i=0,255 do
		poke(0x4300|i,shadow_color[(i&0xf)+1]|(shadow_color[((i>>4)&0xf)+1]<<4))
	end
end

function draw_shade(x1,y1,x2,y2,x3,y3,x4,y4)
	y1=flr(y1)
	y2=flr(y2)
	y3=flr(y3)
	y4=flr(y4)
	
	shade_edge(x1,y1,x2,y2)
	shade_edge(x2,y2,x3,y3)
	shade_edge(x3,y3,x4,y4)
	shade_edge(x4,y4,x1,y1)
	
	local min_y=clamp(min(y1,min(y2,min(y3,y4))),0,127)
	local max_y=clamp(max(y1,max(y2,max(y3,y4))),0,127)
	
	for y=min_y,max_y do
		local xl=peek(0x4400+y)\2
		local xr=peek(0x4480+y)\2
		local scanline=0x6000+y*64
		for x=xl,xr do
			poke(scanline+x,peek(0x4300|peek(scanline+x)))
		end
	end
end

function shade_edge(x1,y1,x2,y2)
	if y1<y2 then
		local dx=(x2-x1)/(y2-y1)
		while y1<=y2 do
			if y1>=0 and y1<=127 then
				poke(0x4400|y1,clamp(x1,0,127))
			end
			x1+=dx
			y1+=1
		end
	elseif y1>y2 then
		local dx=(x1-x2)/(y1-y2)
		while y2<=y1 do
			if y2>=0 and y2<=127 then
				poke(0x4480|y2,clamp(x2,0,127))
			end
			x2+=dx
			y2+=1
		end
	elseif y1>=0 and y1<=127 then
		x1=clamp(x1,0,127)
		x2=clamp(x2,0,127)
		if x1<x2 then
			poke(0x4400|y1,x1)
			poke(0x4480|y1,x2)
		else
			poke(0x4400|y1,x2)
			poke(0x4480|y1,x1)
		end
	end
end


car_min,car_vscale=-2.1209,0.0215
car_verticesc=[[^}^Üxeàxpègèxeñx^°^ôx:ñx/è7èx:àxkÇx^}xpèxkúx^°x4úx/èx4Çx˘q∂ˇêº(vº$Ü∑˘qâˇêÉ(vÉ$ÖàwíÉznµznâwíºΩqÉΩíºΩíÉΩqºΩ?¥ä_∞ä_éΩ?äˇqÉˇqº¬}â˘}â˘}∂¬}∂ Öé xé x± Ö±wqÉwqºç?äç?¥(íÉ(íº Öë |ë |≠ Ö≠ íé í±^}¿^Ü«pè¿eà«gè«^°¿eñ«^ô«/è¿:ñ«7è«:à«kÇ«^}«pè«kú«^°«4ú«/è«4Ç«’}¿’Ü«Áè¿‹à«ﬂè«’°¿‹ñ«’ô«√è¿Œñ«Ãè«Œà«‚Ç«’}«Áè«‚ú«’°«»ú«√è«»Ç«’}’Üx‹àxÁèﬂèx‹ñx’°’ôxŒñx√èÃèxŒàx‚Çx’}xÁèx‚úx’°x»úx√èx»Çxæe∂æ^∂æeàæ^à¡iØ≈dØ¡iè≈dè‹và◊{è‹vØ‹v∂◊{Ø‹vèﬁíºﬁíÉ^íÉ^íºÿr∂ÿrØœs∂œrØ◊qè◊qàŒràÕqè]]
car_trianglesc=[[o6p+dra+8fe+4`f+:m6+>p=+bqc+=rb+>qo+a`@+a@d+@8e+o:6+dqr+84f+:lm+>op+brq+=pr+>cq+ ,- #,  #/. &/# &10 )1& )32  3) !," ,$" $/% /'% '1( 1*( *3+ 3!+ =c> `rp @qd hji wux {á} }áâ }äÄ Ääã ÄåÉ Éåç Éé{ {éà ~à| á~ äâ ÇäÅ Çåã ÖåÑ Öéç |éÜ èõë ëõù ëûî îûü î†ó ó†° ó¢è è¢ú íúê ìõí ìûù ñûï ñ†ü ô†ò ö°ô ê¢ö £Ø∞ ¶Ø£ ¶≤± ©≤¶ ©¥≥ ¨¥© ¨∂µ £∂¨ §Ø• Øß• ß≤® ≤™® ™¥´ ´µ≠ µÆ≠ ∂§Æ #., &0/ )21  -3 !-, ,.$ $./ /0' '01 12* *23 3-! =bc `ar @oq hgj wvu {àá }âä Äãå Éçé ~áà âá Åä Çãä ÇÑå Öçå ÖÜé |àé èúõ ëùû îü† ó°¢ íõú ìùõ ìïû ñüû ñò† ô°† ö¢° êú¢ ¶±Ø ©≥≤ ¨µ¥ £∞∂ §∞Ø Ø±ß ß±≤ ≤≥™ ™≥¥ ´¥µ µ∂Æ ∂∞§ 7mn';l:'æŒ∫'æ∏º'º… ' ¬¡'Œƒø'76m';kl'æÕŒ'æ∫∏'º∏…' …¬'ŒÕƒ'∆e9#»6t#e59#^p?#«o<#`g@#≈`^#o_<#8i4#8gh#;:s#67t#7zt#;yk#vlk#xzn#wlv#uzx#4j`#5f≈#@∆_#s:«#?p»#6»p#«:o#ef5#^`p#`jg#≈f`#o@_#8hi#8@g#7nz#;sy#yuk#uvk#mwn#wxn#wml#uyz#4ij#@e∆#$'*&ÇÅ&ñïì&ß™≠&æªΩ&ºÃª&∫œπ&æ–Õ&∏À…& √Ã&Õ¿ƒ&!"$&$%'&'(*&*+!&!$*&~|&|Ü&ÜÖ&ÖÑ&ÑÇ&ìíô&íêô&êöô&ôòì&òñì&§•ß&ß®™&™´≠&≠Æ§&§ß≠&æºª&º Ã&∫Œœ&æΩ–&∏∑À& ¡√&Õ–¿&]]

function car_mesh_init()
	car_vertices={}
	for i=1,#car_verticesc,3 do
		add(car_vertices,{x=car_min+car_vscale*decode_v(car_verticesc,i),y=car_min+car_vscale*decode_v(car_verticesc,i+1),z=car_min+car_vscale*decode_v(car_verticesc,i+2)})
	end
	
	car_triangles={}
	for i=1,#car_trianglesc do
		add(car_triangles,decode_v(car_trianglesc,i)+1)
	end
end

function decode_v(arr,i)
	local v=ord(arr,i)-32
	if v>=62 then
		v-=29
	end
	return v
end


presorted_count=16

function car_rendering_init()
	transformed_vertices={}
	projected_vertices={}
	sorted_triangles={}

	for i=0,presorted_count-1 do
		local yaw=(i+0.5)*pi2/presorted_count
		car_transform(car_vertices, transformed_vertices, yaw,0,0,1)

		local triangles=cull_triangles(transformed_vertices,car_triangles,-0.5,0.5,1)
		sort_triangles(transformed_vertices,triangles)
		add(sorted_triangles,triangles)
	end
end

function car_draw(pos_x,pos_y,yaw,pitch,roll,scale)
	car_transform(car_vertices, transformed_vertices, yaw,pitch,roll,scale)
	project_vertices(transformed_vertices,projected_vertices,pos_x,pos_y)

	local yaw_index=flr((yaw+0.3*abs(pitch)+abs(roll)*0.2)/pi2*presorted_count)%presorted_count+1
	draw_triangles(projected_vertices,sorted_triangles[yaw_index])
end

function transformation(vec,yaw_sin,yaw_cos,pitch_sin,pitch_cos,roll_sin,roll_cos,scale)
	local x,y,z=vec.x,vec.y,vec.z
	if roll_sin ~= 0 then
		z,y=rotatesincos(z,y,roll_sin,roll_cos)
	end
	if pitch_sin ~= 0 then
		x,y=rotatesincos(x,y,pitch_sin,pitch_cos)
	end
	x,z=rotatesincos(x,z,yaw_sin,yaw_cos)
	return {x=x*scale,y=y*scale,z=z*scale}
end

function car_transform(vertices_in, vertices_out, yaw, pitch, roll, scale)
	local yaw_sin=sin(yaw)
	local yaw_cos=cos(yaw)
	local pitch_sin=sin(pitch)
	local pitch_cos=cos(pitch)
	local roll_sin=sin(roll)
	local roll_cos=cos(roll)

	for i=1,#vertices_in do
		vertices_out[i]=transformation(vertices_in[i],yaw_sin,yaw_cos,pitch_sin,pitch_cos,roll_sin,roll_cos,scale)
	end
end



car_max_speed_forward=4
car_nitro_speed_increase=2
car_max_speed_reverse=-1
car_turn_speed=0.1
car_inertia=0.95
car_gravity=-0.2
car_half_width=4
car_half_length=8
car_terrain_slip=0.85
car_dirt_slip=0.96
car_scale=5
car_colors_default={
	{8,2, "red hurricane"},
	{11,3,"green devil"},
	{12,1,"blue lightning"},
	{10,9,"yellow thunder"},
	{6,13,"silver blaze"}
}

default_throttle=1
difficulty_levels={
	{n="easy",t=0.8},
	{n="medium",t=0.9},
	{n="hard",t=1},
	{n="extreme",t=1.1},
}

player_color=1
waypoint_order=1
cars_count=4
laps_count=4
start_time=0
difficulty=1

function cars_init()
	particles={}
	frame=0

	local start_ofs=1
	if waypoint_order<0 then
		start_ofs=9
	end

	car_sorting=split("1,2,3,4")

	car_colors={}
	add(car_colors,car_colors_default[player_color])
	for i=2,4 do
		if i==player_color then
			add(car_colors,car_colors_default[1])
		else
			add(car_colors,car_colors_default[i])
		end
	end

	cars={}
	for i=1,cars_count do
		local cx=start_positions[start_ofs+  (i-1)*2]
		local cz=start_positions[start_ofs+1+(i-1)*2]
		local t,cy=sample_tile_map(cx,cz)
		add(cars,{x=cx,y=cy,z=cz,yaw=hpi+hpi*waypoint_order,speed=0,speed_y=0,throttle=0,nitro=0,breaking=0,in_air=false,slip=0,slip_x=0,slip_z=0,colour=i,last_waypoint=0,next_waypoint=0,next_x=0,next_z=0,nitro_remains=100,nitro_max=100,lap=-1,is_ai=i>1})
		car_simulate(cars[#cars])
	end
	
	start_time=time()+3.5
end

function cars_update()
	if time()<start_time then return end

	frame+=1
	particles_update()

	car_player(cars[1])
	car_simulate(cars[1])
	
	for i=2,cars_count do
		car_ai(cars[i])
		car_simulate(cars[i])
	end
end

function car_input(car,left,right,throttle,rev,nitro)
	if car.in_air then
		car.throttle=0
		return
	end

	if left then
		car.yaw+=car_turn_speed
		if car.yaw>=pi2 then
			car.yaw-=pi2
		end
	end
	
	if right then
		car.yaw-=car_turn_speed
		if car.yaw<0 then
			car.yaw+=pi2
		end
	end

	if nitro and car.nitro_remains>0 then
		car.nitro=car_nitro_speed_increase
		car.nitro_remains-=1
	else
		car.nitro=0
	end
	
	if throttle then
		car.throttle=default_throttle
	elseif rev then
		car.throttle=-default_throttle
	else
		car.throttle=0
	end
end

function car_next_waypoint(car)
	if car.last_waypoint==car.next_waypoint then
		local nw=(car.next_waypoint + #waypoints + waypoint_order)%#waypoints
		local wps=waypoints[nw+1]
		local index=flr(rnd(#wps\2))*2+1
		car.next_waypoint=nw
		car.next_x=wps[index]
		car.next_z=wps[index+1]
	end
end

function car_player(car)
	car_input(cars[1],btn(0),btn(1),btn(2) or btn(5),btn(3),btn(4))
	car_update_lap(car,car.last_waypoint,car.next_waypoint)
	car_next_waypoint(car)
end

function car_ai(car)
	car_update_lap(car,car.last_waypoint,car.next_waypoint)
	car_next_waypoint(car)

	local dir_x=car.next_x-car.x
	local dir_z=car.next_z-car.z
	local dst_yaw = atan2(-dir_x,dir_z)
	car.dst_yaw=dst_yaw
	
	car.dst_distance=dir_x*dir_x+dir_z*dir_z

	local delta_yaw=dst_yaw-car.yaw
	if delta_yaw> pi then delta_yaw-=pi2 end
	if delta_yaw<-pi then delta_yaw+=pi2 end
	
	car_input(car,delta_yaw>0.1,delta_yaw<-0.1,abs(delta_yaw)<0.5,false,car.dst_distance>6400)

	local next_wps=waypoints[car.next_waypoint+1]
	local index=flr(rnd(#next_wps\2))*2+1
	local ndir_x=next_wps[index]-car.x
	local ndir_z=next_wps[index+1]-car.z
	
	if (ndir_x*ndir_x+ndir_z*ndir_z)<car.dst_distance then
		car.next_x=next_wps[index]
		car.next_z=next_wps[index+1]
	end
end

function car_update_lap(car,last_waypoint,next_waypoint)
	if next_waypoint==0 and last_waypoint==next_waypoint then
		car.lap+=1
		if car.lap>=laps_count then
			sfx(56)
			set_finish_time()
			set_state(3)
		end
	end
end

function set_finish_time()
	if cars[1].finish_time==nil then
		for i=1,cars_count do
			local car=cars[i]
			local ft=t()-start_time
			if car.lap>=laps_count then
				car.finish_time=ft
			else
				local dir_x=car.next_x-car.x
				local dir_z=car.next_z-car.z
				local t_dist=sqrt(dir_x*dir_x+dir_z*dir_z)*0.1
				car.finish_time=ft+t_dist+(laps_count-car.lap-1)*#waypoints*5
				while car.next_waypoint~=0 do
					car.next_waypoint=(car.next_waypoint + #waypoints + waypoint_order)%#waypoints
					car.finish_time+=5
				end
			end
		end
	end
end

function car_simulate(car)
	local was_air=car.in_air
	local prc=0
	local prs=146

	local inertia = car_inertia
	if car.in_air then inertia = 1 end
	local max_speed = car_max_speed_forward
	if car.is_ai then max_speed *= difficulty_levels[difficulty].t end
	car.speed = clamp(car.speed*inertia + car.throttle + car.nitro, car_max_speed_reverse, max_speed + car.nitro)

	local speed=car.speed
	if not car.in_air then
		speed*=(1-abs(car.pitch)*0.4)
		
		if height_is_water(car.y) then
			speed = min(speed,2)
			prs=150
			prc=2
		end
	end
	
	local dir_x=-cos(car.yaw)
	local dir_z= sin(car.yaw)
	local right_x=-dir_z
	local right_z= dir_x

	local move_x = lerp(dir_x,car.slip_x,car.slip)
	local move_z = lerp(dir_z,car.slip_z,car.slip)
	move_x,move_z = normalize2d(move_x,move_z)

	car.slip_x = move_x
	car.slip_z = move_z

	local new_x = car.x + move_x * speed
	local new_z = car.z + move_z * speed

	local fwd_x=dir_x*car_half_length
	local fwd_z=dir_z*car_half_length

	local f_x=new_x+fwd_x
	local f_z=new_z+fwd_z
	local b_x=new_x-fwd_x
	local b_z=new_z-fwd_z

	if speed>=0 then
		local f_t,f_h=sample_tile_map(f_x,f_z)
		if tile_is_obstacle(f_t) then
			local sol_x,sol_z=sample_collision_solution(f_x,f_z)
						
			if sol_x~=0 or sol_z~=0 then
				local tf_x=flr(f_x/8)
				local tf_z=flr(f_z/8)
				while tf_x==flr(f_x/8) and tf_z==flr(f_z/8) do
					f_x+=sol_x
					f_z+=sol_z
				end
			else
				car.screen_x,car.screen_y=isometry(car.x,car.y,car.z)
				car.in_air=false
				return
			end
			
			dir_x,dir_z=normalize2d(f_x-b_x,f_z-b_z)
			
			right_x=-dir_z
			right_z= dir_x
			
			fwd_x=dir_x*car_half_length
			fwd_z=dir_z*car_half_length
			
			car.yaw = atan2(-dir_x,dir_z)
			
			new_x = f_x-fwd_x
			new_z = f_z-fwd_z

			b_x=new_x-fwd_x
			b_z=new_z-fwd_z
			
			if not car.in_air then
				car.speed  = min(car.speed,1.8)
				car.speed_y = max(car.speed_y,0)
			end
		end
	else
		local b_t,b_h=sample_tile_map(b_x,b_z)
		if tile_is_obstacle(b_t) then
			return
		end
	end

	car.x=new_x
	car.z=new_z

	right_x*=car_half_width
	right_z*=car_half_width

	local fr_x=f_x+right_x
	local fr_z=f_z+right_z
	local fl_x=f_x-right_x
	local fl_z=f_z-right_z
	local br_x=b_x+right_x
	local br_z=b_z+right_z
	local bl_x=b_x-right_x
	local bl_z=b_z-right_z

	local fr_t,fr_y,fr_w = sample_tile_map(fr_x,fr_z)
	local fl_t,fl_y,fl_w = sample_tile_map(fl_x,fl_z)
	local br_t,br_y,br_w = sample_tile_map(br_x,br_z)
	local bl_t,bl_y,bl_w = sample_tile_map(bl_x,bl_z)
	
	local f_y = (fr_y+fl_y)*0.5
	local b_y = (br_y+bl_y)*0.5
	local r_y = (fr_y+br_y)*0.5
	local l_y = (fl_y+bl_y)*0.5

	car.sfr_x,car.sfr_y=isometry(fr_x,fr_y,fr_z)
	car.sfl_x,car.sfl_y=isometry(fl_x,fl_y,fl_z)
	car.sbr_x,car.sbr_y=isometry(br_x,br_y,br_z)
	car.sbl_x,car.sbl_y=isometry(bl_x,bl_y,bl_z)

	car.speed_y = clamp(car.speed_y+car_gravity,-4,4)
	local phys_y=car.y+car.speed_y
	local new_tile_type = fr_t
	local new_y = (f_y+b_y)*0.5
	
	if phys_y>new_y then
		car.in_air=true
		car.y=phys_y
		car.roll*=0.95
		car.pitch=max(car.pitch-0.03,-0.4)
		car.slip=0
	else
		if tile_is_dirt(new_tile_type) then
			car.slip=car_dirt_slip
		else
			car.slip=car_terrain_slip
		end
		
		car.in_air=false
		car.speed_y=new_y-car.y
		car.y=new_y
		car.tile_type=new_tile_type
	
		car.pitch=clamp((f_y-b_y)/car_half_length*0.5,-0.5,0.5)
		car.roll=clamp((l_y-r_y)/car_half_width*0.5,-0.5,0.5)
	end

	car.screen_x,car.screen_y=isometry(car.x,car.y,car.z)

	if was_air and not car.in_air then
		prc+=4
	end
	
	if not car.in_air and abs(car.speed)>0.8 and (car.slip>0.9 or car.speed>car_max_speed_forward) then
		prc+=1
	end
	
	for i=1,prc do
		add(particles,{s=prs,x=flr(car.screen_x-11+rnd(10)),y=flr(car.screen_y-11+rnd(10))})
	end
	
	if fr_w~=-1 then car.last_waypoint=fr_w end
	if fl_w~=-1 then car.last_waypoint=fl_w end
	if br_w~=-1 then car.last_waypoint=br_w end
	if bl_w~=-1 then car.last_waypoint=bl_w end
end

function particles_update()
	if frame%4==0 then
		for i=1,#particles do
			local p=particles[i]
			if p==nil then break end
			if p.s==149 or p.s==153 then
				deli(particles,i)
			else
				p.s+=1
			end
		end
	end
end

function cars_draw(ofs_x,ofs_y)
	for i=1,cars_count do
		local car=cars[i]
		local x=car.screen_x-ofs_x
		local y=car.screen_y-ofs_y
		if x>-8 and x<136 and y>-8 and y<136 then
			draw_shade(
				car.sfr_x-ofs_x,car.sfr_y-ofs_y,
				car.sfl_x-ofs_x,car.sfl_y-ofs_y,
				car.sbl_x-ofs_x,car.sbl_y-ofs_y,
				car.sbr_x-ofs_x,car.sbr_y-ofs_y
			)
		end
	end

	palt()
	for i=1,#particles do
		local p=particles[i]
		spr(p.s,p.x-ofs_x,p.y-ofs_y)
	end

	for i=1,cars_count-1 do
		if cars[car_sorting[i]].screen_y > cars[car_sorting[i+1]].screen_y then
			car_sorting[i],car_sorting[i+1]=car_sorting[i+1],car_sorting[i]
		end
	end

	for i=1,cars_count do
		local car=cars[car_sorting[i]]
		local colors=car_colors[car.colour]
		pal(11,colors[1])
		pal(3,colors[2])
		
		local x=car.screen_x-ofs_x
		local y=car.screen_y-ofs_y
		if x>-8 and x<136 and y>-8 and y<136 then
			car_draw(x,y,car.yaw,car.pitch,car.roll,car_scale)
		end
	end
	
	pal(11,11)
	pal(3,3)
end




map_ofs_x=0
map_ofs_y=0

track=1

car_controls=1

tracks={
	{u=0x2000,d=0x2800,rm=racing_map1,wp=waypoints_racing_map1,st=starts_racing_map1},
	{u=0x1800,d=0x1840,rm=racing_map2,wp=waypoints_racing_map2,st=starts_racing_map2},
	{u=0x2040,d=0x2840,rm=racing_map3,wp=waypoints_racing_map3,st=starts_racing_map3}
}

function game_init()
 --music(-1)
 local t=tracks[track]
 pal(5,132,1)
 pal(15,143,1)
 
 for i=0,1920,128 do
	reload(0x2000+i,t.u+i,64)
	reload(0x2800+i,t.d+i,64)
 end
 
 shadows_init("0,0,2,3,5,1,6,7,8,4,4,11,1,13,14,4")
 tiles_init(t.rm,t.wp,t.st)
 sprite_map_init(0,0)
 car_rendering_init()
 cars_init()
end

function game_update()
 cars_update()

 if car_controls==1 then
  local new_ofs_x=cars[1].screen_x-64
  local new_ofs_y=cars[1].screen_y-64
  map_ofs_x=max(0,min(384,new_ofs_x))
  map_ofs_y=max(0,min(128,new_ofs_y))
 else
  debug_screen_controls()
 end
end

function game_draw()
 palt(0,false)
 sprite_map_draw(-map_ofs_x,-map_ofs_y)
 cars_draw(map_ofs_x,map_ofs_y)
 palt(0,true)
 second_sprite_map_draw(-map_ofs_x,-map_ofs_y)

 if btn(ó) and car_controls==0 then
 	tiles_draw(map_ofs_x,map_ofs_y,not btn(é))
 end

	game_ui_draw()
end



prevcountdown=-1
function game_ui_draw()
	local t=time()-start_time

	if t>=0 then
		printo(time_str(t),64-12,2,7)

		for j=0,cars_count-1 do
			local ls=lap_to_str(cars[j+1].lap)
			if j==0 then
				ls=ls.."/"..laps_count
			end
			printo(ls,2,2+j*6,car_colors[cars[j+1].colour][1])
		end
		
		for j=0,cars_count-1 do
			draw_progress(128-32,2+j*3,126,cars[j+1].nitro_remains/cars[j+1].nitro_max,car_colors[cars[j+1].colour][1],car_colors[cars[j+1].colour][2])
		end
	end

	if t<1 then
		t=-t+1
		set_transparent_pattern(t-flr(t))
		local sx=3
		if time()>=start_time then
			sx=9
		end
		local countdown=3-flr(t)
		draw_sprite4(countdown*3,64-6,sx,6, 64-(sx*4)/2,64-24/2)
		fillp()
		
		if countdown>prevcountdown then
			if countdown==3 then
				sfx(55)
			else
				sfx(54)
			end
		end
		prevcountdown=countdown
	end
end




title_image=[[ ± ú£'''±±=±6¥ˇŸ1¿&±µ…'3≈5√2)109(ˇ¬3µ5≤&1π2#3(6–ˇΩ5¥∏6.5◊5,ˇº=*ˇˇˇ√&≥2#3(≤&ˇ»1≈2"6)72©ª©ö3˝2$e2@_7q:sv¨9ª(6 7Ω>2@_8q9srª<Ö'¡>2^_˘5…5¡3—722"^/bsÄª7-¬bmes6 7•b0ºñª3˝?ó`08õ¯''–:^=‡éª4˚5¡6Ω2 h^^Ö62y9Ú6/Ω?ö@Èi^@ª3¸6$6‘8/:Ú5`2„Çªı`Ñ1∂4 Õ')2 1Û5'824z^/9s?q@Ñ4$2ª@¶µ*∑4'∂136¶@/9`2x*∑=Ñ1¸3Ñ4#∑*∑2'6òaÛ;ª;/`sc02¡b^∂*1Ù1˛6'µ23º</:`7h?Ñm^4®1ª4Û3'42=ª</:`7h?Ñ2Ò4ï4'2›1®3›3'∏3¸'7‚8‰π=/:`7h?Ñ5Ç'e^:Ω5¡ÑªdÑ4ö=^9ª1´*1˛2#5œ101/;@;/:`9hbÑ4ò7Õ=®3ı6 ;0:©=/:`9uaÑ:ó?0≥]]
car_image=[[ ± ±£ˇˇˇˇˇˇˇÓ+r §π#d!4"6?'ü∫##!b 1ª++9<+õΩgπ'µ<◊1Ωñæg∫2ª1´>Ÿ+%%îΩ1ªd∫3ª#¬ñΩh∫2ª≥@‹+íΩ+hª3÷#+√!≥éΩiª1 2¶_ªµ%'äæ+#fª2æ1Ÿ#«3Ω%áΩ++i∫3ª1•`ﬂ≤ äΩqª#«!≤âΩ+#oª!cª181µÑΩ+lª3Ÿ#+Œ~Ω1éa"#^!36v Å∂_«'+''4∑_‘c3fΩi¨:Ä1≤''6∆d `:…4¢;ˇ5"7Ö4+3∫7‘{ »'%u ''∂7’Ú!y %∂Ä ∆%''!%eÚ%!%%+'5 µxπ:Î«$$≥!a µ+1_4!¥>íπ2>$4±<ª6æ«'' !µ&'4 1‚%9ë^æ=–1‰3Å 1é1ÙŒ2ï2!!≥:ª¡>Ã5ª6Ω≈%''!%ƒ%3#¥%+'3 #≤1»2ª3èmΩ6ª1Ω $$4ª2¨@¬¥#$5 2+4∫5íbΩ5‘>f∆''1û?∏2 2Œ¥+'5 1·:ª1⁄∆6√9g $$¥6¨6¥7ı≥$5 2”;ª≤hΩ>Ê∆''¥:∫:!#16'5 1b+æ3ì^µ4ª2¯!%%2ï3Ê∆$1∑dˇ#2÷:¨2ª$1 3ëø1Ÿ;"3π%$4Ω1Â≈x 2ª%3ª5æ3Ø2µ4#<!!1Ω1∫1!1r1«√1›#!g!3¯7∫1è1∏1ì%2¬∏7$<¡+3d1ˇÃ9õ`*3˚2Æ3,2!5Œ35≤8´3µ#7#≤5j&2t≥&&∆#h!6›¥:ª2◊$%!=ª:√+3È∏!''^ª≤kΩ∑:ª'1à1ë1–1…7´? 4Û&!$4˙_∫¥1g ∏%2É2Ø1π≤2¡1ú$$!2ª6#≤+9 4Û%1a$≤a∫2Ω4ú#%2®4Æ6$121⁄1ﬁ2·6√1l≤$4ª2 ;Ø+2¿5g6Û2∫À 7g5#5%1‘819å%&!!1è$2√2Ã3Ô;∞Ω1Ù1Ω‘1Ë3ú:Ω5#:ª1¥'≤$1%6/h!%&2i’9Ô7¬7,9<2æ'1ê6¡9ì%!%1ª$%€4†_î2‘%&1∏$1"$''¥5ƒ5±@ì%&&$&&!‹f0≥1⁄1Ω!2π3Ã^∑;Ω&!$2ÛÏ9„¥'!%$'4Ω3ªŒ%≤1Ωb‡eΩb„%$&1µ$$2Ω&%3Àcó∏$&$%%fª≈c‚3≠!'1∫5, 7Ω2 Ú6Ω$%1∏1∫'3îag<î2cﬂe„≤$$&!&1ë$∂pîgª_Ωf‰1µ$$2¬¥iïrª@Ωh„2Ω2"2ªlñr?oª8„1∑ôª<æo‰3∫ñªö‰±:ˇˇˇˇˇˇˇˇÒ]]

title_items={
	{l=function() player_color=player_color%#car_colors_default+1 end,r=function() player_color=(player_color+#car_colors_default-2)%#car_colors_default+1 end,un=function() pal(11,car_colors_default[player_color][1],1) pal(3,car_colors_default[player_color][2],1) return "car color" end},
	{l=function() difficulty=(difficulty+#difficulty_levels-2)%#difficulty_levels+1 end,r=function() difficulty=difficulty%#difficulty_levels+1 end,un=function() return difficulty_levels[difficulty].n end},
	{n="tournament",e=function() tour=split("0,0,0,0") track=1 waypoint_order=1 laps_count=4 cars_count=4 set_state(2) end},
	{n="single race",e=function() tour=nil menu_tracks() end}
}
title_sel=1

track_items={
	{n="track 1",e=function() track=1 menu_setup() end},
	{n="track 2",e=function() track=2 menu_setup() end},
	{n="track 3",e=function() track=3 menu_setup() end}
}
track_sel=1

setup_items={
	{l=function() laps_count=max(laps_count-1,1) end,r=function() laps_count=min(laps_count+1,20) end,un=function() return "laps "..laps_count end},
	{l=function() waypoint_order*=-1 end,r=function() waypoint_order*=-1 end,un=function() if waypoint_order==1 then return "reverse off" else return "reverse on" end end},
	{l=function() cars_count=max(cars_count-1,1) end,r=function() cars_count=min(cars_count+1,4) end,un=function() return "opponents "..(cars_count-1) end},
	{n="start!",e=function() set_state(2) end}
}
setup_sel=1

menu=nil
menu_get_sel=nil
menu_set_sel=nil
menu_enter=nil
menu_back=nil

function title_init()
	pal(split("0,8,2,13,5,6,7,9,132,4,8,129,1,140,12"),1)
	
	car_rendering_init()
	shadows_init("0,0,2,3,5,1,6,7,8,4,4,11,0,12,13,14")
	
	lz77_decomp(0,0,128,32,title_image,sset)
	lz77_decomp(0,32,128,64,car_image,sset)
	
	for y=0,4+8 do
		for x=0,15 do
			poke(0x2000 + x+y*128,x+y*16)
		end
	end
	
	menu_title()
	music(0)
end

function title_update()
	menu_update()
end

function title_draw()
	local center_x,center_y=64,45
	for i=0,127 do
		local f=(((i>>4)+time()*2)*4) & 7
		local c
		if f>3 then
			c=15-(f&3)
		else
			c=12+(f&3)
		end
		
		line(center_x,center_y,i,127,c)
		line(center_x,center_y,127-i,0,c)
		line(center_x,center_y,0,i,c)
		line(center_x,center_y,127,127-i,c)
	end
	
	map(0,0,0,4-4*abs(sin(time()*5)),16,4)
	map(0,4,0,32,16,8)
	
	if time()>2.5 then
		menu_draw(title_items,title_sel)
	else
		printo("by assembler bot (2021)",18,120,7)
	end
end


function menu_title()
	menu_init(title_items,function() return title_sel end, function(val) title_sel=val end, function() end)
end

function menu_tracks()
	menu_init(track_items,function() return track_sel end, function(val) track_sel=val end, function() menu_title() end)
end

function menu_setup()
	menu_init(setup_items,function() return setup_sel end, function(val) setup_sel=val end, function() menu_tracks() end)
end

function menu_init(items,get,set,back)
	menu=items
	menu_get_sel=get
	menu_set_sel=set
	menu_back=back
end

function menu_update()
	if btnp(0) then
		local left=menu[menu_get_sel()].l
		if left~=nil then sfx(50) left() end
	end
	
	if btnp(1) then
		local right=menu[menu_get_sel()].r
		if right~=nil then sfx(50) right() end
	end

	if btnp(2) then
		sfx(50)
		menu_set_sel(max(menu_get_sel()-1,1))
	end

	if btnp(3) then
		sfx(50)
		menu_set_sel(min(menu_get_sel()+1,#menu))
	end

	if btnp(4) then
		local enter=menu[menu_get_sel()].e
		if enter~=nil then sfx(51) enter() end
	end

	if btnp(5) then
		sfx(52)
		menu_back()
	end

	if game_state~=1 then return end
	for i=1,#menu do
		if menu[i].un~=nil then
			menu[i].n=menu[i].un()
		end
	end
end

function menu_draw()
	draw_shade(32,92,32,126,94,126,94,92)
	rect(32,92,96,126,0)

	for i=1,#menu do
		local x=(96+34-#menu[i].n*4)\2
		local y=(126+92-#menu*7)\2+(i-1)*8
		local nx=(96+34-#car_colors_default[player_color][3]*4)\2
		
		printo(car_colors_default[player_color][3],nx,85,11)
		
		if menu_get_sel()==i and menu[i].l~=nil then
			print("ã", 34, y, 2)
			print("ë", 88, y, 2)
		end
		
		printo(menu[i].n, x, y, 7-5*is(menu_get_sel(),i))
	end
end

function is(x,y)
	if x==y then return 1 end
	return 0
end


posn={"1ST","2ND","3RD","4TH"}

function results_init()
	res_sorting={1,2,3,4}
	res_t=t()
	res_d=120
	res_tour=false
	res_frame=0
end

function results_update()
	if btnp(5) and res_d < 4 then
		sfx(51)
		if tour==nil then
			set_state(1)
			return
		end
		if res_tour then
			track=track%#tracks+1
			if track == 1 then
				waypoint_order*=-1
				if waypoint_order==1 then
					if final_position == 4 then
						set_state(1)
					else
						set_state(4)
					end
					return
				end
			end
			set_state(2)
			return
		end
		res_tour=true
		res_d=120
		res_frame=0
		for i=1,cars_count do
			tour[res_sorting[i]]+=cars_count-i+1
		end
	end
end

function results_draw()
	for y=-1,15 do
		for x=-1,15 do
			local ofs=(time()*16)%8
			rectfill(x*8+ofs,y*8+ofs,x*8+7+ofs,y*8+7+ofs,((x^^y)&1))
		end
	end
	
	local base_y=37-res_d
	res_d/=1.2

	rect(2,base_y,126,base_y+54,0)
	rectfill(3,base_y+1,125,base_y+53,5)

	local title="race results"
	if res_tour then
		title="tournament"
	end
	printo(title, 64-(12/2)*4,base_y+3,7)
	line(4,base_y+10,123,base_y+10,7)

	printo("pos",5,base_y+13,7)
	printo("car",22,base_y+13,7)
	if not res_tour then
		printo("time",83,base_y+13,7)
	end
	if tour~=nil then
		printo("pts",113,base_y+13,7)
	end
	
	for i=1,cars_count do
		local y=base_y+23+i*8-8

		local j=res_sorting[i]
		if j==1 then
			rectfill(3,y-2,125,y+6,13)
			final_position=i
		end

		local ni=min(i+1,cars_count)
		local nj=res_sorting[ni]
		if (res_tour and tour[j]<tour[nj]) or (not res_tour and cars[j].finish_time > cars[nj].finish_time) then
			res_sorting[i],res_sorting[ni]=res_sorting[ni],res_sorting[i]
		end
		
		local c=car_colors[j][1]
		printo(posn[i],5,y,c)
		printo(car_colors[j][3],22,y,c)
		if not res_tour then
			printo(time_str(cars[j].finish_time),83,y,c)
		end
		if tour~=nil then
			if res_tour then
				printo(tour[j],117,y,c)
			else
				printo(cars_count-i+1,117,y,c)
			end
		end
	end
	
	printo("ó continue",44,120,7)
	res_frame+=1
end



trophy_image=[[ ± ˇÛ**ów*1 Î<…2â8ç6-n'_{:|Â<ú7ÿæ/4!/4'∑)6!6 π<É4ı8'5á6"5ô7Ù8ë<s<”7ñ?⁄eﬁ8q;Â∂76çh⁄3ﬁ59|º?ç7ﬁ9¶9⁄∏:{Ω6˚9⁄fﬁ∑<yø>è6‰=á6ﬁ@v6%=ç9ﬁb⁄3ﬁ^ã∆6‘5ﬁa⁄Ÿ9⁄fﬁ⁄=⁄eﬁÿ:ﬁb⁄3ﬁƒ2‰¡=ﬁ9 9⁄¬;î∫9⁄fﬁø7É¬6‹7á7ﬁ5á6ﬁ…:›9ãf⁄3ﬁ>¬=Ê>‹7ﬁa⁄¡@ó∂9⁄fﬁΩ;Ä¿=⁄eﬁ`€>›2x9ﬁb⁄3ﬁb~@Í=ﬁ9 9⁄∫=ã<Î;⁄fﬁø:ã;Ï8‹7á7ﬁ5á6ﬁc€>ç_›^‹eã;ﬁ4€8‹9â<‹fã5Ò3Ú2z2Ç6Ÿ`⁄6‹8sdç3y4ÿ=à2›7⁄µeã8ﬁ2⁄3à6"3/9é8‹gã6¯4˛2‹6Ü9ﬂ3ä6ﬁ5ˆcã9é3Å9‹5€3~1›5çkä:ﬂ3Å2Ñ@‹2⁄3#mã;ç4›3îπ4ÿ8€kã9ﬂ3‹<à5€3ê2Ênä7ﬂ3ä6ç4›2Œ5ÿµqã6‡3ÿ2ﬁ8ﬂ6ç2€uâ7‡5ﬂ2'8€5‹yã7ç2„:€Å⁄=ﬁ6›4ã⁄:ç1ﬁ3Áà⁄7ﬂ3ã4⁄2çÉŸbçâã4ﬁ2‡8äàã7ﬁìã6ﬂ6çåä3ﬂ7€èã5ﬁïã2ﬂ1ﬁïäˇˇˇˇˇˇˇˇˇˇˇˇˇˇ>ã¥ñ›ˇˇ≥2€˙4€ï›ˇˇ7€ì›ˇˇ2⁄2!4›çﬁ1Ö8ãéﬁ±‹±‹rÿ5⁄6ﬂÖ‡2Ñ^ç±‹±‹§‹7◊:Ÿ5›ê2Çfç±‹±‹ö‹%v ˇˇ⁄/l *ﬁ*k )ˇˇˇˇˇˇ„*)l ›s#ˇˇ’#x ˇ”±^Ÿ]]

function trophy_init()
	pal()
	pal(3,128,1)
	pal(15,7)
	
	if final_position==2 then
		pal(9,5)
		pal(10,6)
	elseif final_position==3 then
		pal(9,132,1)
		pal(10,4)
		pal(15,137,1)
	end

	lz77_decomp(0,0,80,112,trophy_image,sset)
	music(-1)
	sfx(57)
	
	dots={}
	for i=1,64 do
		add(dots,{x=rnd(128),y=rnd(128)-128})
	end
end

function trophy_update()
	if btnp(5) then
		sfx(51)
		set_state(1)
	end
end

function trophy_draw()
	for y=-1,15 do
		for x=-1,15 do
			local ofs=(time()*16)%8
			rectfill(x*8+ofs,y*8+ofs,x*8+7+ofs,y*8+7+ofs,((x^^y)&1))
		end
	end
	
	spr(0,24,2,10,14)

	print(posn[final_position],58,100,1)

	for i=1,64 do
		local dx=flr(rnd(5))-2
		local dy=flr(rnd(5))-2
		line(dots[i].x-dx,dots[i].y-dy,dots[i].x+dx,dots[i].y+dy,i%16)

		dots[i].y+=1
		if dots[i].y>=128 then
			dots[i].y = 0
		end
	end

	printo("ó continue",44,120,7)
end



game_states={
	{init=title_init,update=title_update,draw=title_draw},
	{init=game_init,update=game_update,draw=game_draw},
	{init=results_init,update=results_update,draw=results_draw},
	{init=trophy_init,update=trophy_update,draw=trophy_draw}
}

game_state=1
next_state=0
trans=1
trans_dir=-0.066

function game_states_init()
	--set_state(1)
	title_init()
	title_update()
end

function game_states_update()
	if trans>0 then
		trans=max(trans+trans_dir,0)
		if trans>1 then
			trans=1
			trans_dir*=-1
			
			reload(0,0,0x2fff)
			pal()
			game_state=next_state
			game_states[game_state].init()
			game_states[game_state].update()
		end
	else
		game_states[game_state].update()
	end
end

function game_states_draw()
	game_states[game_state].draw()
	if trans>0 then
		set_transparent_pattern(trans)
		rectfill(0,0,127,127,0)
		fillp()
	end
end

function set_state(state)
	next_state=state
	trans_dir=0.066
	trans=0.01
end




--#include debug.lua

function _init()
 --poke(0x5f2e,1) --keep palette after program ends
 car_mesh_init()
 game_states_init()
end

function _update()
	game_states_update()
end

function _draw()
	game_states_draw()
end
__gfx__
00000000eeeeeeee777777776666666644444447888888484444444e7fffffffddddddddefffffff2222222288888848eeeeeeee444444544444444444444444
0000000022222222dddddddd666666444444447688888844444444e8d7ff4ff44ddddddd2ef4f4ff422422228888488488888888555444444544454444454444
0070070022222222dddddddd66666644444447668888884444444e88dd7ff4fff4dddddd22ef4f4ff42222228888884588888888444455445444544444444454
0007700022222222dddddddd6664644444447666888484444444e888ddd7ff4fff44dddd222efff4ff4422228f84f4f48888f8f4454444555445445444444444
0007700022222222dddddddd666444444447666688884444444e8888dddd7ffff4f4dddd2222effffff42222ffffffff8884ffff444454444454444444445444
0070070022222222dddddddd64644444447666668844444444e88888ddddd7ffff4f4d4d22222efff4ff4422f45f4445848f4445444444444444544545444444
0000000022222222dddddddd6644444447666666884444444e888888dddddd7ffff4f4dd222222efff4ff4224544544488445444444445545445445444444444
00000000225255255d555dd5644444447666666684444444e8888888ddddddd7f4ffff4d2222222e4fffff424444444484444444455544444454444444444444
444454444445444e4445444444444eeeee4444444444444e4444444e7445444500000000e44544444444444e5551555e5455455e444444444444444455555555
44444444444444e84444444444eee22222e44444454444e84454444ed7444f44000000002e44454f445445e8515555e8455455e8445444444445445444444444
4544445444444e884444444eee222222222e454444444e88444445e8dd7544ff0000000022e4444f44444e8815515e8845454e88444445445444544444444454
444444444544e88845444ee222222222222e444444454e88444444e8ddd74f4f00000000222e4ff44f4fe8881551e8884454e888444444444544444444544444
4445444444ee8888444ee82222222222222e44444444e88845444e88dddd7fff000000002222effffffe8888551e8888544e8888454444444444454444444444
44444444ee28888844e882222222222222e844444444e88844444e88ddddd7ff0000000022222efff4e8888855e8888844e88888444444444445445444445445
44444eee828888884e888222222222222e8844454544e8884444e884dddddd7f00000000222222ef4e8888885e8888884e888888444445444444544454444444
44eee22228288888e888222222222522e888444444442e884444e888ddddddd7000000002222222ee8888888e8888888e8888888444444444544444444454444
ee22222282888888888822222222255588884444444422ee444e888444445447000000000000000000000000eeeeeeee4544544ef5ff1ffe0000000000000000
222222222828858588822252225554448888454445442222445e88854544447d00000000000000000000000088888888444444e84f44ffe80000000000000000
22222222828858548882225555454444888844454444222244e88855444447dd000000000000000000000000888888884f444e8844444e880000000000000000
22222222285855448822525444444445888844444444222244e8845545447ddd000000000000000000000000888888f8ffffe8884444e8880000000000000000
2222222282554444882255444444444488484444444422224e8885554447dddd0000000000000000000000008888ffff54fe8888544e88880000000000000000
2222225255444444822544444544444488844444444522224e884551447ddddd000000000000000000000000888f444544e8888844e888880000000000000000
222525554444444482544444444544448444544445445252e888555147dddddd000000000000000000000000884454444e8888884e8888880000000000000000
225555444444444485444444444444448444444444444522e88855157ddddddd00000000000000000000000084444444e8888888e88888880000000000000000
22222222ddddddddeeeeeeee777777771111115111111eee88884444dddddd510000000000000000000000000000000000000000000000000000000000011554
22222222dddddddd22222222dddddddd1151111111eee22288884445ddddd5550000000000000000000000000000000000000000000000000000000000115544
22222222dddddddd22222222dddddddd1111511eee22222288844444dddd1554000000000000000000000000000000000000000000000000000000000115444f
22222222dddddddd22222222dddddddd15111ee22222222288844444dd555544000000000000000000000000000000000000000000000000000000001155444f
22222222dddddddd22222222dddddddd111ee8222222222288445454d55555440000000000000000000000000000000000000000000000000000000015544fff
22222222dddddddd22222222dddddddd11e88222222222228844444455154455000000000000000000000000000000000000000000000000000000005544ffff
22222222dddddddd22222222dddddddd1e88822222222222844445445544554400000000000000000000000000000000000000000000000000000000544fffff
22222222dddddddd22222222dddddddde88822222222252284544444544544540000000000000000000000000000000000000000000000000000000044ffffff
00000000eeeeeeee777777776666666600000007888888880000000e70000000dddddddde00000002222222288888888eeeeeeee000000000000000044444444
000aaa0022222222dddddddd666666640000007688888884000000e8d70000004ddddddd2e000000422222228888888488888888000000000000000044454444
00a00a0022222222dddddddd66666644000007668888884400000e88dd700000f4dddddd22e00000f42222228888884588888888000000000000000044444454
00000a0022222222dddddddd6666644400007666888884440000e888ddd70000ff4ddddd222e0000ff4222228f84f4f488888888000000000000000044444444
000aaa0022222222dddddddd666644440007666688884444000e8888dddd7000f4f4dddd2222e000fff42222ffffffff88888888000000000000000044445444
00aa000022222222dddddddd66644444007666668884444400e88888ddddd700ff4f4ddd22222e00f4ff4222f45f444588888888000000000000000045444444
00aaaa0022222222dddddddd6644444407666666884444440e888888dddddd70fff4f4dd222222e0ff4ff4224544544488888888000000000000000044444544
0000000022222222dddddddd644444447666666684444444e8888888ddddddd7f4ffff4d2222222e4fffff424444444488888888000000000000000044444444
000000000000000e0000000000000eeeee0000000000000e0000000e7000000000000000e00000000000000e0000000e0000000e000000000000000055555555
00000000000000e80000000000eee22222e00000000000e80000000ed7000000000000002e000000000000e8000000e8000000e8000000000000000044445444
0000000000000e880000000eee222222222e000000000e88000000e8dd7000000000000022e0000000000e8800000e8800000e88000000000000000044444454
000000000000e88800000ee222222222222e000000000e88000000e8ddd7000000000000222e00000000e8880000e8880000e888000000000000000044544444
0000000000ee8888000ee82222222222222e00000000e88800000e88dddd7000000000002222e000000e8888000e8888000e8888000000000000000044444444
00000000ee28888800e882222222222222e800000000e88800000e88ddddd7000000000022222e0000e8888800e8888800e88888000000000000000044445445
00000eee828888880e888222222222222e8800000000e8880000e888dddddd7000000000222222e00e8888880e8888880e888888000000000000000054444444
00eee22228288888e888222222222222e888000000002e880000e888ddddddd7000000002222222ee8888888e8888888e8888888000000000000000044454444
ee22222282888888888822222222255588880000000022ee000e888800000007000000000000000000000000eeeeeeee0000000e0000000e0000000000000000
222222222828888588822222225554448888000000002222000e88850000007d00000000000000000000000088888888000000e8000000e80000000000000000
22222222828888548882222555454444888800000000222200e88885000007dd0000000000000000000000008888888800000e8800000e880000000000000000
22222222288855448822225444444445888800000000222200e8885500007ddd000000000000000000000000888888f80000e8880000e8880000000000000000
2222222282554444882255444444444488880000000022220e8888550007dddd0000000000000000000000008888ffff000e8888000e88880000000000000000
2222222255444444822544444544444488800000000022220e888551007ddddd000000000000000000000000888f444500e8888800e888880000000000000000
222225554444444482544444444544448800000000005222e888855107dddddd000000000000000000000000884454440e8888880e8888880000000000000000
222555444444444485444444444444448000000000000522e88855157ddddddd00000000000000000000000084444444e8888888e88888880000000000000000
000000000000000000000000000000000000000000000eee88885515ddddddd10000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000eee22288885155dddddd550000000000000000000000000000000000000000000000000000000000000000
777777770777077707000000000000000000000eee22222288855551ddddd5540000000000000000000000000000000000000000000000000000000000000000
dd7dd7d707dd07d7070000000000000000000ee22222222288851555dddd55440000000000000000000000000000000000000000000000000000000000000000
07777707070007070700000000000000000ee8222222222288515555ddd555440000000000000000000000000000000000000000000000000000000000000000
0d77dd07070707070d0000000000000000e882222222222288515515dd1544550000000000000000000000000000000000000000000000000000000000000000
777777777777077707000000000000000e8882222222222285155515d54455440000000000000000000000000000000000000000000000000000000000000000
dddddddddddd0ddd0d00000000000000e88822222222222285555155544544540000000000000000000000000000000000000000000000000000000000000000
1111151511111111fff4ffff11111c45222225254444444777700004555555555555555554444444555555554444444400000000000000004544445445544544
1111c554111111114fff4fff1111145422222554445444777d00004444544447444054444544f4454444f4f45444ff4400000000000000005454454454554554
1c15544411111151f4fff4f511514455222554444444400007777544444440405774754444f545f445f5454f44f54f4400000000000000005544544555545555
5155444411151111fffff4f41c1455555255444444440000777744444444000077774444454444f4454444f44f4444f400000000000000004454554555555555
11544544111111114f4fc4411145555522544544454777700004444445477770000444444544444f5444444f4544444500000000000000005555555455555455
5544444411111111ffff411c155455555544444444777d000044444444777d0000444444455445f4554445f44f5444f400000000000000005515515554555555
5444444411115111ff44f1515455555554444444400007777444454440000777744445444545544445445454f454544400000000000000005155155555545545
4445445411111111f415c11155545545444544540000777744444444000077774444444454444444445445444444454400000000000000005555155544554454
44444551445444540000000000000000000f4f0000f0000000000000000000000000000000c000004444444e444444444444444e444444444444444444444444
44455555444444440000000000f05f0000f45f50000000400000700000700070700c070000000700445445e844544544445445e8445445444454454444544544
44441554444444440000f4000f0ff5f0ff00000ff000000007000000000c0000000070000000000c44444e884444444544444e88444444454444444544444444
5455554445445454000f4f0005f4f450540000040000000000000c000707000000000c07700000004f44e8884f44f4f44444e8f8444444f44f4ff4f44f4f4445
45555544444444450005f5000fffff40050000f50000000f007c700000700c7000c0000000000000fffe8888ffffffff454e8fff45444ffffff4fffffff4f444
551544554444444500f05000004f5f0000ff00500400000000c70070000c70000000007000000007f4e88888f45f444544e8f4544444f454f45f4445f45f4f44
55445544445444550000000000050000f054f000000000400000000000000000007000c000c000004e888888454454444e88555544445555454454444544fff4
5445445444444555000000000000000000054040000f000000000000070000000000000000000070e888888844444444e88855554444555555455455554fff4f
eeeeeeee44444445eeeeee44ffff4fffffff4ff4545555540000000022222244dddddddd44444155f4f44f4f14f11f1f88855551444555515551555144444444
22222222444545452222444f4ffff4fff4fff4ff45454445000000002222444fddddddddf4454515ffffffffffffffff88855515454555155155551544444444
222222224444455522244ffffff4ffffffffffff444444440000000022244fffddddddddff4445154f44f4444f44f44488551515445515151551551544444444
22222222444455552524fffff4ff4ffffffff4ff45445454000000002524ffffddddddddff444451444454444444544488555555445555551551555544444444
2222222244445455544ff4ffff4ff4fff4f4ff4f4444444500000000544ff4ffddddddd4f4f54455444444444444444488555155445551555515515544444444
222222254545555544ffff4fffffffffff4f4ff4444444440000000044ffff4fddddddddff4f44f5445444454454444585555155455551555515515544444444
22522554455555544fff4ff4f4ffff4ffffff4ff44544444000000004fff4ff4dddd4d45fffff445454454444544544485551551455515515155151544444444
5555554455455544ff4ff4ffff4fffffff4fffff4444454400000000ff4ff4ffddddd455ff4ffff4444444444444444455551555555515555555155544444444
445544f455555444f7777777445544f4fff4fffff4444444ffff4ffff4444444444422ee82888888555515551551515588888888555f4fff5455455545544544
54444f4f5545544fffdddddd54444f4f4fff4ffffff454455ffff4ff4ff44444454422222828858551515454551551558888484454fffff44554554554555455
44f44fff55544fffff4d4ddd44f44ffff4fff4f5fff4444454f4ff4ff4ff4444445422228288585551555444555515518888844554f4ff4f4545444445544444
4554ffff4544fffff4ff4dd44554fffffffff4f4ffff4454555f4ffffffff444454422222858554515554444515151158f8ff4f44ffff4444454444544444555
4f4ff4ff554ff4ffff4f44dd4f4ff4ff4f4f4444f4fff4445554ff4f4f4f444454552222825555551554454411151111fff4ffff4fff44445444454444555544
4fffff4f44ffff4f4fffff4d4fffff4fffff4455ff4f4ff455554ff4ffff445555552222554454515544444415111151f45f44455f4444544444444455544554
4fff4ff44fff4ff4f4ff4ffd4fff4ff4ff44f444fffff4f4545554ffff44f4445515525244445515544444441111111145445444ff4444444444444444455444
ff4ff4ffff4ff4fffffff4f4ff4ff4fff4454454ff4fffff4554554ff44544545155152244444515444544541111511155455455f44454444454454454444455
f0f0f0f0f0f0f0f0f0f0f0f021311020202010101020202010102020202323233333332323102020102a2b202010101010101020202010101020202045f0f0f0
5150f0b898f098f098f0fbfbfbfbfbfbd0f03b3a4bd0d01a6b4bd01a1b5bf0d0d0f0b8d0f03b4a28bbbbbbbbbbbbabd0d01909e1e1f0ebebf0fbfbfb4454f0f0
f0f0f0f0f0f0f0f0f0f0f0402232f1f1f1f1f1f1a8f1f1f1f1f1f1f10ba003031313130348f1f11a1b4a4bf1f1f1f1f1f1f1f1f1f1f1a8f1f1a8f16446f0f0f0
5614141424242414141424242414141424714a4bb8f0f0ebebd01a1b4a4be1f098d0f0983b4a2818181818181808f0d0762445f0e1f0e1f0fbf0fb4434f0f0f0
f0f0f0f0f0f0f0f0f0f04030f0fbe0f0f0d0d0f0f0d0f0f01a1b5b0b3a28181818181808d0f01a1b4a4bf0f0d0f0f0d0d098fbf0fbfbfbfbf0f04454f0f0f0f0
f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f03b8024242414141414242424141414242424453b4a2818181818475724242424776142e0f0e0f0f0e0f06534f0f0f0f0
f0f0f0f0f0f0f0f0f06030e0f0e0fbfbd0f0f0d0f0f0d01a1b3a3a3a28181818181808f0f01a1b4a4bf0d0f0f0d0f0d0f0e1f0fbe1fbf0fbf04434f0f0f0f0f0
f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f86b4bf0f0f0f0f0f0f0f0f0f0f0f0f0f0011142aaaababababad62636f0f0f019e862e8e8e8e8e8e8e8e866e8e8e8e8e8
f0f0f0f0f0f0f0f0c9cbe9e9f9f0e055242414141424242414141424242414141424242414141424242414141424242445f0fbfbd9e9e9e9a534f0f0f0f0f0f0
f0f0f0f0f0f0f0f0f0f0f021312020101020202010102a2b20202a2b202020200212f0e0d9e9e9e9a554f0f0f0f0f0dab1caeaeaeaeaeaeaeab567eaeaeaeaea
f0f0f0f0f0f0f040caeaeaeadbf0f05220202010101020202045f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f56042f0f0f0daeaeab554f0f0f0f0f0f0f0
f0f0f0f0f0f0f0f0f0f0402232fba8fbfbf1a8f11a1b3a4b1a1b4a4bf1f1f1f1f0f0e0f0daeaeab554f0f0f0f0f0f0c150ebebebebebebebc554ebebebebebeb
f0f0f0f0f0f04030ebebebebf0f0f0f0f1f1a8f1f1a8f1f16446f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f06050f0e0f0e0ebebc554f0f0f0f0f0f0f0f0
f0f0f0f0f0f0f0f0f04030fbfbf0fbfbd0fbf01a1b4a4b1a1b4a4bf0d0f0d0f0d0f0f0f0ebebc554f0f0f0f0f0f06050b898f0b8e0e0b86454f0f0f0f0f0f0f0
f0f0f0f0f05130f0f0e0f0e0e0f0e1e1f0f0f0f098f0f06454f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0c9cbe9e9f9f0f0984454f0f0f0f0f0f0f0f0f0
f0f0f0f0f0f0f0f06030f0fbfbfbe0fbfbf01a1b3a4b1a1b4a4bf0f0d0f0f0d0f0d0f0f0051554f0f0f0f0f0f0c9cbe9f9b898d9e9e9a554f0f0f0f0f0f0f0f0
f0f0f0f0f05614242445d9e9e9e9f9f0f0b8f0f0f0984454f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f040caeaeaeadbf0e04434f0f0f0f0f0f0f0f0f0f0
f0f0f0f0f0f0f06050f0fbfbfb25352424241414142424241414142424241414142424240616f0f0f0f0f0f060caeaeadbf098daeab554f0f0f0f0f0f0f0f0f0
f0f0f0f0f0f0f0f06042daeaeaeadbf0f0f0f0b8f04434f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f04030ebebebebf0e04434f0f0f0f0f0f0f0f0f0f0f0
f0f0f0f0f0f04050f0fbe0fb552636f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f4f4f0f0f0f0011150ebebebf0e0f0ebc554f0f0f0f0f0f0f0f0f0f0
f0f0f0f0f0f0f06050f0ebebebebe0f0f0f0f0f06434f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f04030f0e0d9e9e9e9a534f0f0f0f0f0f0f0f0f0f0f0f0
f0f0f0f0f04030f0f0f0f0f05210101020202010101020202010101020202010101020202010101020200212f0fbf0fbfbfbf06454f0f0f0f0f0f0f0f0f0f0f0
b9b9b9b9b9a9c0b0b9b9b9b9b9b9b9b9b9b9c6b6b4b9b9f9f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0603098e0f0daeaeab554f0f0f0f0f0f0f0f0f0f0f0f0f0
f0f0f0f06030f0f0f0e1f0f0f0f1f1f1f1a8f1f1f1f1f1a8f17888f1f1f1f1a8f1f1f1f1f1f1f1f1a8f1fbfbfbe0fbf0fbfb4454f0f0f0f0f0f0f0f0f0f0f0f0
f0f0f0f06050f0e098f098e0e0f0fbf0e05554f0f0f03b4a7bf0f0f0f0f0f0f0f0f0f0f0f0f0f0f06050f0f0f0f0ebebc554f0f0f0f0f0f0f0f0f0f0f0f0f0f0
f0f0f06050f098f0e1f0f0e1f0d0f0f0f0d0f0d0f0d0f0f05868d0f0f0d0f0f0d0d0d0d0f0f098f0f0fbfbfbe0fbfbfbfb4434f0f0f0f0f0f0f0f0f0f0f0f0f0
f0f0f0405098f0b8f0b8b898fbfbf0fbe152202010914a4bf0f0f0f0f0f0f0f0f0f0f0f0f0f0011150f0b8e0f0e0f05554f0f0f0722010102a2b202010101041
f0f05150f0b8f098f0e1f0f0d0f0f0d0f0f0f0f0d0f0f05868f0f0d0b8f0f0f0f0f0d0f0f0f0f0f0fbfbf0f0fbf0f0051534f0f0f0f0f0f0f0f0f0f0f0f0f0f0
f0f04030f0f098f0b8b8f0fbf0fbe1fbfbfbf1f13ba01010102a2b2020201010101020202020029be8e8e8e8e8e8e88b1020202073f1f10b4a4bf1a8f1a86446
f0f05614141414242424141414242424141414242424141414242424141414242424141414242424141414242424140616f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0
f06030b8f0b8f098b8fbe1f0fbfbfbfbf0d0f03b4a4bf1a80b4a4bf1f1f1f1f1f1a8f1f1f1f13b9aeaeaeaeaeaeaeaaba8f1f109f0d01a6b4bf0fbfbb86454f0
f0f0f0f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0
__gff__
0101010101010101010101000001010101010101010101010101000100010101010101010101010101010100010101010101010101010101010101010101010100020202020202020202020002000002020202020202020200020202020000020202020202020202000000000202000000000000020202020000000000000000
0101010101010101010101010000010001000000000000000000000000000000010101010100000100010000010101000101010101010101010101000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0f0f0f0f0f0f0f0f1213010202020101a2b2020201010101140fb3a3a4a3b40f1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d0f0f0f0f0f0f0f121302020201010102020201323232333333010101020202010119a4b40f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f91900fb3a4b40f0f0f0f0f0f
0f0f0f0f0f0f0f0422231f1f1f1f1fa1b6b41f1f1f1f1f5564b3a3a3a4b40f0f1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d0f0f0f0f0f0f0422238a1f8a1f1f1f1f1f1f1fb30a303131a8841f1f8a0d1f8ab00a010202020101010202020101010202540f91900fb3a4b40f0f0f0f0f0f0f
0f0f0f0f0f0f04030f0e0f0f0d0d0d0f0d0f0d0e0f0f0f2517a4a3a3b40f1d0f1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d0f0f0f0f0f04030f0f0e8b0f0f0d0f0d0d0fb3a4b41f8a8a900f0f0d0f0f0db0a3b41f1f1f8a1fbfbf1fbfbf8a1f1f1f466491900fb3a4b40f0f0f0f0f0f0f0f
0f0f0f0f0f06030f0e0f0e0f525342540f0f0e0f1e0f0fb30807a4b40f1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d0f0f0f0f06030f890f0f0f0e52534242414141424242414141424242414159a4b40f0fbf0dbfbfbf1ebf8bbf0f8b0f444591900fb3a4b40f0f0f0f0f0f0f0f0f
0f0f0f0f06059d9e9f0e0e44626306240e0f0f0e0f0fb3a4a408020101010202020101a2b2020201a0a2b20202010101020202010101020202010101020202140f0f0f9cbc9e9e9e9f890f5562631f1f5f5f5f5f5f5f5f5f1f1f1f1f1fb04a414242424154bf1ebf1ebfbf0e0f0f464391900fb3a4b40f0f0f0f0f0f0f0f0f0f
0f0f0f04050fadaebd0e44430f15050f1e0f0e0f0db3a3a4a3b40d8a1f8a8a1f1fa1b1a4b41f1fa1b1a4b41f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f46640f0f06acaeaeaeaebd0f8b250202023232323333333201010202020119a3b41f1f1f101124bfbf0e0f0f890f89554527020217a4b40f0f0f0f0f0f0f0f0f0f0f
0f0f04030f0ebebe0e46431d1d6542424141414257a3a4a4b40f898b8b0f8989a1b1a4b41d0da1b1a3b41d0d1d0d1d0d1d1d1d0d0d0d0dbfbf0dbfbf1d44454f0f0405bebebebebe8b0f0d0f0f0fb30a30303131a8841f1f1f8a1fb00a010202020120210e0ebf0e0f0e0f0f0f2502370fb3080201010202020101010202140f
0f06039d9e9f0e0e15450f0f1d1d1f1f1f1f1fb34849a3b40f8b0f890d8b0fa1b1a4b41d0da1b1a3b41d1d1d1d0d1d1d1d0d1d1d0d1dbf1ebfbf1dbf44434f4f04030f0f890f891e0f890f0d0fb3a4b4898abf8a900f0f0d0f0db3a4b41f1f1f1f1f898b0f0f0f0f0f0f0f0f0d0f900db3a4b41fbf1fbf1fbf1f1fbf1f46640f
06050fadaebd0e0f2501010202020101541db3a3a44a4141424242414141424242414141424242414141424242414141424242414154bfbfbf0dbf46434f4f4f030f0f0f0f0f0f0f0f0f0d0fb3a4b489bf8b89900f0f0d0f0fb0a4b40f0f0d0f0f0f0f0d0d0f0d0f0e0f0f0f0d900fb3a4b40fbf1ebf1ebfbfbfbf0f44454f0f
058b0fbebe1e1e0f0d1f1f1f1f1f1f4664b3a3a3a3b45f5f5f5f5f5f5f12130202020101010202020101010202020101010202020124bf0ebfbf46454f4f4f4f41414242424141414242424141414242424141414242424159a4b40f0f0f0f0f0f0f0d0f0d0d0d0f0f0f0f67424259a4b40d0fbfbfbfbfbf1ebf0f44434f4f0f
0f898b0f0f0f0d0dbfbf1ebfbf0f4445b3a3a3a3b40f0f0f0f0f0f0f0622231f1f1f1f1f1f1f1f8a8a1f8a8a1f8a1f1f1f1f1f1f1fbfbfbfbf44454f4f4f4f4f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5fb04a4142424241540f0f0e0f0f0e0f0f0f554141770fb34a41414242541ebfbfbfbf0f46434f4f4f0f
42424141414242540fbfbfbfbf4443b3a3a3a3b40f0f0f0f0f0f0f06050f1d1d0d1d1d0d0d891d8b89898b1d891d891d0d1d0d0dbfbfbf0d44434f4f4f4f4f4f0f0f0f0f0f0f0f0f0f0f0f12130102020201010102020201010102020201240f0f0f0f0e0f0f0f0f250102020201010102020124bfbfbf0f0f46454f4f4f4f0f
5f5f5f5f5f5f0624bfbf0ebf4443b3a3a4a3b40f0f0f0f0f0f0f04050f0e1d1d1d0d1d1d1d1d891d891d898b89891d8b1d0d0dbfbf0d5051434f4f4f4f4f4f4f0f0f0f0f0f0f0f0f0f0f0422231f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f0f0f0d0f0d0d0f0d0d0f0f0f1f1f1f8a1f1f1fbfbfbf0ebfbf0ebf44454f4f4f4f4f0f
0f0f0f0f0f9cbc9e9e9e9e5a43b3a4a4a4b40f0f0f0f0f0f0f04038b0f0f0e525342424241414142424241414142424241414142424260614f4f4f4f4f4f4f4f0f0f0f0f0f0f0f0f0f04030f0f0f0f890f0d0d0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0d0f0f0f0f0f0d0f0d0f0f0d0f0d0fbfbfbfbfbf5051434f4f4f4f4f4f4f
1d1d0f0f04acaeaeaeae5b45b3a4a3a3b40f0f0f0f0f0f0f06030f0f0e0f4462631f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f5f5f5f4f4f4f4f4f4f4f4f4f4f0f0f0f0f0f0f0f0f06030f0f0f0f0f0f52534242414141424242540f0f0f0e0f0f0f0f0f52534242424141414242424141414242424160610f0f0f0f0f0f0f0f
0f0f0f0403bebebebe5c45b3a4a3a4b40f0f0f0f0f0f0f06050f0f0e0f15430f0f0f0f0f0f0f1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d0f0f0f0f0f0f0f0605890f890f0e0e5562635f5f5f5f5f5f1011240f0f0f0f0e0f0f0f1522231f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f0f0f0f0f0f0f0f0f0f0f
0f0f06030f0e0f0f1545b3a4a4a4b40f0f0f0f0f0f0f04050f0e0e0f0f2501020202010132323333333333323232a2b202020202010101020202010101141d1d0f0f0f0f0f0f04050f0f8b0e89890f25010101020202020120210f0f0e0f0f0f0f0e0f250102a2b2323232333333323201a2b202010101020202010101140f0f
0f06050f1e0e1e0d2517a3a3a4b40f0f0f0f0f0f0f04031d890f0f1e0f0f1f1f1f1f1fb30a3031313131313030a7a4b41f1f1f1f1f1f1f1f1f1f1f1f46641d1d0f0f0f0f0f04030f89890f8989890d0f1f1f1f1f1f1f1f1f0f0f0f0f0e0d0f0d0f0f0d0f1fb3a4a40a30303131313030a7a4b41f1f1f1f8a1f1f1f1f44640f0f
04050f0f0f1e0d0db30807a3b40f0f0f0f0f0f0f0603898b0e0f1e0f0f0d0fa1b3b5b3a4828181818181818183b6b40f0d0f1e1d1e1d1e1d1d1d1d44451d1d1d0f0f0f0f0603890f8b890f8b0f0d890f0d0f0f0f0d0f0f0f0f0d0f0e0d0d0f0d0d0d0f0fa1b6a4a48281818181818183b6b40f0f890f1e0f890f0f46430f0f0f
030f0f8b0f0f0fb3a3a408010102020201011415050f0f0f0f0f0f0d0f0fa1b3a4a3a48281818181818181800f0f0f0f0f0f0f1e1e1e1d1d1d1d44431d1d1d1d0f0f0f15050f0f890f0f890f0f890f0f0f0d0f890f890f0f0f0f0f0f0e0f0f0f0f0f0f0fbeb0a382818181818181800d0f0d0f0d0f0f8b0f0f0f46450f0f0f0f
41414142424259a3a3a4b41f1f1f1f1f8a44646541424242414141424242414141424242414141424242414141424242540f1d1d9d9e9e9f1d46431d1d1d1d1d0f0f0f6542424241414142424241414142424241540f0e0f0e0f0e0f0f0f5253424242414141424242414141424242540f1e1e891e0f1e8b0f44450f0f0f0f0f
5f5f5f5f5fb34a49a3b40f1e1e1e0f0f44434f4f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f06241d0e0eadaeaebd46451d1d1d1d1d1d0f0f0f0f5f5f5f5f5f5f12130202020101010202240f0f0e0f0f0f0f0f4462635f5f5f5f5f5f5f5f5f5f5f5f5f5f06240f0f0f0f0f0f0f8b44430f0f0f0f0f0f
0f0f0f0fb3a3a44a41540f0e0f0f0f46434f4f0f0f0f0f0f0f0f0f0f0f0f0f0f1d1d1d1d1d1d1d1d1d1d1d1d1d1d06059d9e9e9fbebebe44451d1d1d1d1d1d1d0f0f0f0f0f0f0f0f0f0422231f1f1f1f1f1f1f1f0f0f0f0f0f0f890f44430f0f0f0f0f0f0f0f0f0f0f0f0f0f0f06050f0f0e9d9e9e9e9e6c430f0f0f0f0f0f0f
0f0f0fb3a3a4a3b404240f0f0e0f46454f4f0f0f0f0f0f0f0f0f0f0f0f0f0f0f1d1d1d1d1d1d1d1d1d1d1d1d1d04051dadaeaebd0e1d44431d1d1d1d1d1d1d1d0f0f0f0f0f0f0f0f06030f0f0e0f0d0f0d0f0f0d0f0f0d0f0f8b5051430f0f0f0f0f0f0f0f0f0f0f0f0f0f0f04058b0e0f0fadaeaeae5b450f0f0f0f0f0f0f0f
0f0fb3a4a4a3b406030f0e0f0e44454f4f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f1d1d1d1d1d1d1d1d1d1d1d1d04030e1dbebebe0e1d46431d1d1d1d1d1d1d1d1d0f0f0f0f0f0f0f9cbc9e9e9e9f0e0e525342424241414142424260610f0f0f0f0f0f0f90a5a5a5b0b50f0f0403bf0f0f0ebfbebebe5c450f0f0f0f0f0f0f0f0f
0fb3a3a3a3b406050f0e0f0f55430f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f1d1d1d1d1d1d1d1d1d1d1011039d9e9e9e9e9f0e46451d1d1d1d1d1d1d1d1d1d0f0f0f0f0f0f06acaeaeaeaebd0f5562635f5f5f5f5f5f5f5f5f4f4f4f0f0f0f0f270201010119a3b4101103bf0ebfbfbf0e0f0f44450f0f0f0f0f0f0f0f0f0f
b3a3a3a3b404050f0f0f1e0f25a0a2b2020101010202020101010202020101010202020101010202020120211dadaeaeaeaebd44451d1d1d1d1d1d1d1d1d1d1d0f0f0f0f0f0405bebebebebe8b0f25010202010102020201010102020201010102370f0f0fb00a010120210fbfbfbf0ebfbf0f44430f0f0f0f0f0f0f0f0f0f0f
a4a3a4b404030f0f0f1e1e1e0fb3a3b41f1f1f1f1f1f1f1f87881f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1d1d0ebebebebebe44431d1d1d1d1d1d1d1d1d1d1d1d0f0f0f0f04030f0f0f1e0f1e0f0f1e1f1f8a1f1f1f1f1f8a87881f1f1f1f1f8a900f0f0fb0a3b41f8a0f0dbf0ebfbfbf0f0f44430f0f0f0f0f0f0f0f0f0f0f0f
a3a3b406030f8b0f1e0f0d0fa1b6b40f0f0f0f0f0d0f0f85860f1d0f0d0f0f0f1d0d0d1d1d1d1d0d1d0d0d1d0e1d0e0e1d46431d1d1d1d1d1d1d1d1d1d1d1d1d0f0f0f06030f890f1e0f0f1e0f0d0f0f0f0d0f0d0f0d0f85860d0d0f0f0d0f900d0d0db0a3b4890fbfbfbfbfbfbfbfbf0f46430f0f0f0f0f0f0f0f0f0f0f0f0f
a3b415050f890f0f0f0f0f0f0d0f0f0f0f0d0d0d0d0f85860f0f0f0f0f0f0d0f1d1d1d1d0d1d0d1d0d1d1d0d1d1d1d5051451d1d1d1d1d1d1d1d1d1d1d1d1d1d0f0f15050f8b0f890f1e0f0f0d0f0f0d0f0f0f0f0d0f85860d0f0f0d8b674242414159a3b40f0d0f0fbf0dbf0fbf0f5051450f0f0f0f0f0f0f0f0f0f0f0f0f0f
b40f65424242414141424241414142424241414142424241414142424241414142424241414142424241414142424260611d1d1d1d1d1d1d1d1d1d1d1d1d1d1d0f0f654141424242414141424242414141424242414141424242414142775f5f5fb04a41414242424141414242424160610f0f0f0f0f0f0f0f0f0f0f0f0f0f0f
0f1d0f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d0f0f0f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f900f0f0fb0a3b45f5f5f5f5f5f5f5f5f5f5f5f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f
__sfx__
010300200017300145001250011500173001450012500115001730014500125001150015000140001300013000173001450012500115001500014000130001300017300145001250011500150001400013000130
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00201834518325183151d3051d3451d3251d3151b3051f3451f3251f3151d3051d3451d3251d315183051834518325183151d3051d3451d3251d3151b3051834518325183151630516345163251631511305
010c00201834518325183151d3051d3451d3251d3151b3051f3451f3251f3151d3051d3451d3251d315183051834518325183151d3051d3451d3251d3151b305243452432524315223052234522325223151d305
010c002018850188401885018840188501884018850188401a8501a8401a8501a8401a8501a8401a8501a8401c8501c8401c8501c8401c8501c8401c8501c8401a8501a8401a8501a8401a8501a8401a8501a840
010c002018342183221d3401d3321d3221d3121b3301b3121f3421f3221d3401d3321d3221d312183301831218342183221d3401d3321d3221d3121b3301b3121834218322163401633216322163121133011312
010c002018342183221d3401d3221d3421d3221b3401b3221f3421f3221d3401d3221d3421d322183401832218342183221d3401d3221d3421d3221b3401b3222434224322223402232222342223221d3401d322
010c00200c0630000000000246030c0630000000000246030c0630000000000246030c0630000000000246030c0630000000000246050c0630000000000000000c0630000000000246050c063000000000000000
010c002018345183251d3451d3251d3451d3251b3351b3151f3451f3251d3451d3251d3451d325183351831518345183251d3451d3251d3451d3251b3351b3151834518325163451632516345163251134511325
010c002018345183251d3451d3251d3451d3251b3451b3251f3451f3251d3451d3251d3451d325183451832518345183251d3451d3251d3451d3251b3451b3252434524325223452232522345223251d3451d325
010c00201d3451d3251b3451b32518345183251f3451f325223452232522345223251f3451d3251d3451b325183451832518345183251b3451b3252234522325183451832518345183251b3451b3251b3451b325
010c00201d3451d3251b3451b32518345183251f3451f325223452232522345223251f3451d3251d3451b325183451832518345183251b3451b32522345223252434524325243452432527345273352732527315
010c002018731187301873018730187301873018730187301b7311b7301b7301b7301b7301b7301b7301b7301d7311d7301d7301d7301d7301d7301d7301d7301b7311b7301b7301b7301b7301b7301b7301b730
010c00202731527315273052730522300223002230022300223002230022300223001d3001b30018300183001830018300183001b300223002230024300243000000000000243002430027300273002730027300
010c002018770187601d7701d7601d7501d7401d7201d7101f7701f7601d7701d7601d7501d7401d7201d71018770187601d7701d7601d7501d7401d7201d7101877018760167701676016750167401672016710
010c002018770187601d7701d7601d7501d7401d7201d7101f7701f7601d7701d7601d7501d7401d7201d71018770187601d7701d7601d7501d7401d7201d7102477024760227702276022750227402272022710
010c00201d7701d7601b7701b76018750187401872018710227702276022750227401d7501d7401d7201d7101f7701f7601f7501f7401b7501b7401b7201b710187701876018750187401b7501b7401b7201b710
010c00201d7701d7601b7701b76018750187401872018710227702276022750227401d7501d7401d7201d7101f7701f7601f7501f7401b7501b7401b7201b710247711816518155181451b3551b3451b3251b315
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
01030000240532c003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010300001f05021050240502905030050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200001a050120500d0500c05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010900000e6000e6000e6000e6000e6000e6000e6000e6000e6010e6010e601006010060100601006010060100601006010060100601006010060100601006010060100601006010060100601006010060100601
010800001837018370183701837018370003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
010800002437024370243702437024370003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
010300001f050210502405029050300500000000000000001f035210352403529035300350000000000000001f025210252402529025300250000000000000001f01521015240152901530015000000000000000
01080000180401b0401d0401f0402204024040000001f040220402404027040290402b0401b00227050290502b0502e0503005033050350503505235052350523505235055350453503535025350150000000000
010c00000060308600056000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 41 42 08 44
00 41 42 09 44
00 41 0a 0b 44
00 41 0a 0c 44
01 0d 0a 0e 44
00 0d 0a 0f 44
00 0d 0a 10 44
00 0d 0a 11 44
00 0d 0a 0e 12
00 0d 0a 0f 12
00 0d 0a 10 12
00 0d 0a 11 12
00 0d 0a 13 14
00 0d 0a 43 15
00 0d 0a 43 16
02 0d 0a 43 17
01 41 0a 43 44
02 0d 0a 43 44
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
