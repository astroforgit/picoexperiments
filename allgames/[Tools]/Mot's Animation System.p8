pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- mot's animation system
-- by mot

-- immediate mode gui
do	
	-- private
	local itms,dolast,co,autonl,nextregions,regions,rstack={},{},{},true,{}
	
	-- public 
	
	-- current position & margins
	-- mouse state
	g_x,g_y,g_left,g_right,g_mx,g_my,g_mb,g_mbp,g_mbb=1,1,1,128,64,64,false,false,0
	
	-- private functions
	local function getitm(typ,props)
	
	 -- look for matching item
		for itm in all(itms) do
			if itm.x==g_x and itm.y==g_y and itm.typ==typ then
				itm.active=true
				return itm
			end
		end
		
		-- create new item
		local itm={typ=typ,x=g_x,y=g_y,active=true}
		if props then
			for k,v in pairs(props) do
				itm[k]=v
			end
		end  
		add(itms,itm)
		return itm
	end	

	-- public functions

 -- begin gui rendering
 -- all rendering should be between
 -- g_beg() and g_end()

	function g_beg()
		poke(0x5f2d,1)	
		-- deactivate items
		for itm in all(itms) do
			itm.active=false
		end
		-- reset state
		g_x,g_y,g_left,g_right,autonl=1,1,1,128,true
		-- reset regions
		regions=nextregions
		nextregions,rstack={},{{0,g_left,g_right}}
		
		-- read mouse
		g_mx,g_my,g_mbb=stat(32),stat(33),stat(34)
		g_mbp=g_mb
		g_mb=g_mbb~=0
		g_clk=g_mbb==1 and not g_mbp
	end

	function g_end()
	 runcoroutines(co)
		
		-- do scheduled "do last" tasks
		for fn in all(dolast) do
			fn()
		end
		dolast={}
		for itm in all(itms) do
			if(not itm.active)del(itms,itm)
		end
		
		-- draw mouse pointer
		line(g_mx,g_my,g_mx,g_my+3,7)
		line(g_mx,g_my,g_mx+2,g_my+2,7)
	end
	
	function g_beginregion(x1,y1,x2,y2,col,bdrcol,modal)
	
	 -- add to regions to apply next frame
	 -- (region logic is always applied using
	 -- the previous frame's regions, because 
	 -- we don't know what is still to be 
	 -- drawn in the current frame)
		add(nextregions,{x1,y1,x2,y2,modal})
		
		-- add to stack
		add(rstack,{#nextregions,g_left,g_right})
		
		-- border and background
		if(col)rectfill(x1,y1,x2-1,y2-1,col)
		if(bdrcol)rect(x1,y1,x2-1,y2-1,bdrcol)
		
		-- reposition cursor and set column
		g_x,g_y,g_left,g_right=x1,y1,x1,x2
	end
	
	function g_endregion()
		local top=rstack[#rstack] 
		deli(rstack)
		
		-- restore previous columns
		g_left,g_right=top[2],top[3]
	end

	function g_autonewline(v)
		autonl=v
	end  

	function g_newline(h)
		g_x=g_left
		g_y+=(h or 10)
	end

	function g_makespc(w,h)
		if(g_x+w>g_right and g_x>g_left)g_newline(h)
	end
	
	function g_advance(w,h)
		if autonl then g_newline(h)
		else           g_x+=w
		end
	end 

	function g_gethoverraw(w,h)
		return g_mx>=g_x and g_my>=g_y and g_mx<g_x+w and g_my<g_y+(h or 10)-1 
	end 

	function g_gethover(w,h)	
		-- is mouse in the correct region?
		local i=#regions
		local r=regions[i]
		while i>0 
			and not (g_mx>=r[1] and g_my>=r[2] and g_mx<r[3] and g_my<r[4]) do
			if(r[5])return false -- modal region found. block hover notifications to underneath regions
			i-=1
			r=regions[i]
		end
		if(i~=rstack[#rstack][1])return false
		
		-- check if hovering over ui element
		return g_gethoverraw(w,h)
	end
	
	function g_strwidth(s)
	 return #s*4
	 
	 -- this version handles high
	 -- ascii characters, if you can
	 -- spare the tokens
--		local w=0 s=""..s
--		for i=1,#s do
--			if ord(sub(s,i,i))<128 then
--				w+=4
--			else 
--				w+=7
--			end
--		end
--		return w
	end 
	
	function g_getpos() return g_x,g_y end
	function g_setpos(nx,ny) g_x=nx g_y=ny end

	function g_column(l,r,t)
		g_left=l or 1
		g_right=r or 127
		g_x,g_y=l,t or g_y
	end
	
	function g_btnex(drawfn,w,h,state)
		w=w or 16 h=h or 16
		g_makespc(w,h)

		local itm=getitm("btn")
		local hover=g_gethover(w,h)

		-- behaviour
		local clicked=false
		
		if hover and g_clk then
			itm.down=true
		elseif itm.down and not g_mb then
			itm.down=false
			clicked=hover  
		end
		
		-- draw
		drawfn(itm.down,hover,g_x,g_y,w,h,state)
		g_advance(w,h)
		
		return clicked  
	end

--	local function drawbtn(down,hover,x,y,w,h,state)
--  x+=1 w-=3

--		-- colour
--  local col=hover and down and 10
--            or hover and 7
--            or 6
  
--  -- button
--		line(x,y+7,x+w,y+7,5)		
--		if(state.dep or clicked or (hover and down))y+=1
--  rectfill(x,y,x+w,y+6,col)
  
  -- text
--		print(state.text,x+1+(w-g_strwidth(state.text))/2,y+1,1)  
--	end

	function g_btn(text,w,dep)
	
	 -- can use text button to save tokens
	 return g_txtbtn(text,w,dep)
	 
	 -- or draw the full buttons
--		return g_btnex(drawbtn,w or 32,10, { text=text, dep=dep })
	end

	local function drawtxtbtn(down,hover,x,y,w,h,state)
		local col=5
		if(hover)col=10
		if((hover and down)or state.dep)col=7
		local textw=g_strwidth(state.text)
		print(state.text,x+(state.leftalign and 0 or (w-textw)/2),y+2,col)	  
	end

	function g_txtbtn(text,w,dep,leftalign)
		return g_btnex(drawtxtbtn,w or 10,10,{text=text,dep=dep,leftalign=leftalign})
	end

	local function drawexpand(down,hover,x,y,w,h,state)
		local col=1
		if hover and down then col=10
		elseif hover then col=12
		end
		rectfill(x-1,y,x+w,y+8,col)
		print(state.expanded and "É" or "î",x+2,y+2,7)
		print(state.text,x+12,y+2,7)
	end  

	function g_expand(text,expanded,w)
		if(g_x>g_left)g_newline()
		if(g_btnex(drawexpand,w or 126,10,{text=text,expanded=expanded}))expanded=not expanded
		return expanded
	end
	
	function g_drag(drawfn,xpos,ypos,w,h)
		g_makespc(w,h)

		local itm=getitm("drag")
		local hover=g_gethover(w,h)

		-- behaviour
		if hover and g_mbb==4 and not g_mbp then
			itm.drag=true
			itm.dx,itm.dy=xpos-g_mx,ypos-g_my
		elseif not g_mb then
			itm.drag=false
		end
		
		if itm.drag then
			xpos,ypos=g_mx+itm.dx,g_my+itm.dy
		end

		-- draw
		drawfn(itm.drag,hover,g_x,g_y,xpos,ypos)
		g_advance(w,h)
		
		return xpos,ypos,itm.drag
	end 
	
	function g_chk(checked,text,value,w)
		if not w then 
			w=text and 53 or 10
		end
		g_makespc(w)
		local itm=getitm("chk",{checked=checked})
		local hover=g_gethover(w)
		
		-- behaviour
		local clicked=false
		
		if hover and g_clk then
			itm.down=true
		elseif itm.down and not g_mb then
			itm.down=false
			if hover then
				checked=value or not checked
			end
		end
		
		-- draw
		local col=0
		if(hover)col=6
		if(hover and itm.down)col=10
		if value then
			circfill(g_x+4,g_y+4,4,col)
			circ(g_x+4,g_y+4,4,5)
			if checked==value then
				circfill(g_x+4,g_y+4,2,7)
			end
		else
			rectfill(g_x,g_y,g_x+8,g_y+8,col)
			rect(g_x,g_y,g_x+8,g_y+8,5)  
			if checked then
				line(g_x+2,g_y+2,g_x+6,g_y+6,7)
				line(g_x+6,g_y+2,g_x+2,g_y+6,7)   
			end
		end
		if(text)print(text,g_x+12,g_y+2,7)  
		
		g_advance(w)  
		return checked
	end
	
	function g_label(text,w,centered)
		w=w or 63
		g_makespc(w)
		local lx=g_x
		if(centered)lx+=(w-g_strwidth(text))/2
		print(text,lx,g_y+2,7)
		g_advance(w)
	end

	function g_txtbox(text,w)
		w=w or 63
		g_makespc(w)
		local itm=getitm("txt")
		local hover=g_gethover(w)
		
		-- behaviour
		if hover and g_clk then
			itm.down=true
		elseif not g_mb and g_mbp then
			if itm.down and hover then
				itm.sel=true
			else
				itm.sel=false
			end
			itm.down=false
		end
		
		-- draw
		local col,bcol=7,13
		if(hover)col=6
		if(hover and itm.down)col=10
		if(itm.sel)bcol=12
		rectfill(g_x,g_y,g_x+w-1,g_y+8,col)
		rect(g_x,g_y,g_x+w-1,g_y+8,bcol)
		local ptext,maxl=text,flr((w-4)/4)
		if(#ptext>maxl)ptext=sub(ptext,#ptext-maxl+1)  
		print(ptext,g_x+2,g_y+2,0)
		if itm.sel then
			print("_",g_x+2+g_strwidth(ptext),g_y+2,12)
		end  

		g_advance(w)

		-- keyboard input
		local enter=false
		if itm.sel then
	  local key=stat(31)
	  if key then
		  if key>=" " and key<chr(128) then
		   text=text..key
		  elseif key==chr(8) and #text>0 then
		  	text=sub(text,1,#text-1)
		  elseif key==chr(13) then
		   itm.sel=false
		  end
	  end
		end

		-- text and enter state from previous frame
		text=itm.text or text
		enter=itm.enter or enter
		
		-- clear previous frame state
		itm.text,itm.enter=nil,nil
		
		return text,enter
	end
	
	function g_slider(val,lo,hi,step,w)
		lo,hi,step=lo or 1,hi or 10,step or 1
		w=w or 63
		local itm=getitm("sld")
		local hover=g_gethover(w)

		-- behaviour
		if hover and g_clk then
			itm.drag=true
		elseif not g_mb then
			itm.drag=false
		end
		
		if itm.drag then
			local f=(g_mx-(g_x+1))/(w-3)
			f=max(0,min(1,f))
			val=flr(((hi-lo)*f)/step+.5)*step+lo
		end

		-- draw
		local col=0
		if(hover)col=5
		rectfill(g_x,g_y,g_x+w-2,g_y+8,col)
		if val>lo then
			local barcol=9
			if(itm.drag)barcol=8
			local tx=(val-lo)/(hi-lo)*(w-3)+g_x+1
			rectfill(g_x,g_y,tx-1,g_y+8,barcol)
		end
		rect(g_x,g_y,g_x+w-2,g_y+8,5)
		
		g_advance(w)
		
		return val
	end
	
	function g_numbox(val,step,lo,hi,w)
	 step=step or 1
	 w=w or 63
	 local itm=getitm("nbx")
  local hover,click=g_gethover(w),g_mb and not g_mbp
  
		-- behaviour
		if hover and click then
			itm.drag=true
   itm.mx=g_mx
		elseif not g_mb then
			itm.drag=false
		end
  
	 if itm.drag and val then
	  local s=step
	  if(g_mbb==2)s*=10
	  val+=(g_mx-itm.mx)*s
	  val=flr(val/step+0.5)*step
   itm.mx=g_mx
   if(lo)val=max(val,lo)
   if(hi)val=min(val,hi)
	 end
	 
		-- draw
		local col=0
		if(hover)col=5
		rectfill(g_x,g_y,g_x+w-2,g_y+8,col)
		if lo and hi and val and val>lo then
			local barcol=9
			if(itm.drag)barcol=8
			local tx=(val-lo)/(hi-lo)*(w-3)+g_x+1
			rectfill(g_x,g_y,tx-1,g_y+8,barcol)
		end
		rect(g_x,g_y,g_x+w-2,g_y+8,5)
		local text=""
		if(val)text=""..(flr(val*100+0.5)/100)
		print(text,g_x+4,g_y+2,7)
		
		g_advance(w)
		
		return val
	end
	 
	function g_menu(header,items)
		local w=0
		for item in all(items) do
			w=max(w,g_strwidth(item))
		end
		w+=8
		local h=#items*10
		local itm=getitm("mnu")
		local mx,my=g_x,g_y+10
		if(mx+w>128)mx=128-w
		if(my+h>128)my=g_y-h
		local headerclicked=g_txtbtn(header,g_strwidth(header)+4,itm.open)
		if(headerclicked)itm.open=true
		if itm.open then
			add(dolast,function()
				g_x,g_y=mx,my
				g_beginregion(mx,my,mx+w,my+h,1)
				local hover=g_gethover(w,h)
				if(g_clk and not hover)itm.open=false
				for m in all(items) do
					if g_txtbtn(m,w) then
						itm.selected=m
						itm.open=false
					end
				end    
				g_endregion()
			end)
		end
		
		local selected=itm.selected
		itm.selected=nil
		return selected
	end
	
	function g_co(fn)
  add(co,cocreate(fn))	 
	end
	
	function g_choosefromlist(list,gettextfn,callbackfn,curidx,nonetext)
  g_co(function()
   local first=(curidx or 1)-5
  	while true do
  	 first=max(min(first,#list-9),1)
 	
	 		-- modal window
	 		g_beginregion(24,8,104,120,1,6,true)
	 	 g_column(26,102,10)
	 	 local hover=g_gethover(80,112)
 	 
	 	 -- none option	 	 
	 	 if nonetext and g_txtbtn(nonetext,76,not curidx) then
 	 	 g_endregion()
	 	  callbackfn(nil,0)
 		  return
	 	 end
 	 
 	  -- items
	 	 local i=first
	 	 while i<=#list and g_y<110 do
	 	  local item=list[i]
 		  if g_txtbtn(gettextfn and gettextfn(item) or item,76,curidx==i,true) then
  	 	 g_endregion()
	 	   callbackfn(item,i)
	 	   return
 		  end 	  
	 	 	i+=1
 		 end
 	 
	 	 g_endregion()

	 	 -- mouse wheel logic
	 	 if hover then
	 	  first-=stat(36)
	 	 end
 	 
 		 -- click outside to close
	 	 if g_clk and not hover then
 		  return
	 	 end 	 

	 	 yield()
	 	end
  end)	
	end
	
	function g_msgbox(text,buttons,callbackfn)
	 g_co(function()
	  local result
	  while not result do
	 	 g_autonewline(false)
	  
	   -- modal region
	 		g_beginregion(24,40,104,88,1,6,true)
	 	 g_column(26,102,42)
	 	 
	 	 -- text
	 	 for t in all(text) do
		 	 g_label(t,90) g_newline()
		 	end
	 	 
	 	 -- buttons
	 	 for b in all(buttons) do
	 	  if(g_btn(b,32))result=b
	 	 end
	 	 
	 	 g_endregion()
	 	 yield()
	 	end
	 	callbackfn(result)	 		
		end)
	end
	
	function g_promptbox(prompt,callbackfn,value)
	 g_co(function()
   value=value or ""
	  while true do
	 	 g_autonewline(true)
	  
	   -- modal region
	 		g_beginregion(24,40,104,88,1,6,true)
	 		local hover,top=g_gethover(80,48)
	 	 g_column(26,102,42)
	 	 
	 	 -- prompt
	 	 g_label(prompt)
	 	 
	 	 -- text
	 	 value=g_txtbox(value,64) g_newline()
	 	 
	 	 -- buttons
	 	 g_autonewline(false)
	 	 if g_btn("ok",32) then
	 	  callbackfn(value)
		 	 g_endregion()
		 	 return
		 	end		 	
	 	 if g_btn("cancel",32) then
		 	 g_endregion()
		 	 return
		 	end
	 	 
	 	 g_endregion()
	 	 yield()

			 -- click outside to cancel
	 	 if(g_clk and not hover and top)return
	  end
	 end)
	end
end

-->8
-- shared animation code
-- tHIS TAB CONTAINS ALL CODE 
-- NECESSARY TO LOAD AND PLAY
-- ANIMATIONS.

-- constants
animfilever=1

-- routines

function runcoroutines(co)
	for c in all(co) do
		if costatus(c)=="dead"then
			del(co,c)
		else
			assert(coresume(c))
		end
	end
end

function lerp(a,b,f)
 return (1-f)*a+f*b
end

function clamp(v,mn,mx)
	return min(max(v,mn),mx)
end

function sprcoords(n)
	return (n%16)*8,flr(n/16)*8
end

function tilecoords(n)
 return n%128,flr(n/128)
end

function smap(cx,cy,cw,ch,sx,sy,sw,sh,flipx,flipy)
 -- delta
 local dx,dy=cw/sw,ch/sh
 
 -- apply flip
 if flipx then
  cx+=cw
  dx=-dx
 end
 if flipy then
  cy+=ch
  dy=-dy
 end
 
-- cx+=dx/2 cy+=dy/2
 
 -- possible optimisations:
 -- * clip to screen region
 -- * render vertically when it would be fewer tline calls
 
 -- render with tlines
 for y=sy,sy+sh-1 do
  tline(sx,y,sx+sw-1,y,cx,cy,dx,0)
  cy+=dy
 end
end

-- file i/o

-- stream helpers

function read2(self)
 return self:read1()|(self:read1()<<8)
end

-- memory stream

function mem_size(self)
	return self.addr-self.baseaddr
end

function mem_r1(self)
 local v=peek(self.addr)
 self.addr+=1
 return v
end

function readmemstream(addr)
	return {
		baseaddr=addr,
		addr=addr,
		size=mem_size,
		read1=mem_r1,
		read2=read2
	}
end

-- hex string stream

function fromhexchar(c)
 return ord(c)-(c>"9" and 87 or 48)
end

function str_size(self)
	return #self.str/2
end

function str_r1(self)
 local str,offs=self.strs[flr(self.offs>>10)+1],self.offs&0x3ff
 offs+=1
 local hi=fromhexchar(sub(str,offs,offs))
 offs+=1
 local lo=fromhexchar(sub(str,offs,offs))
 self.offs+=2
 return (hi<<4)|lo
end 

function readstrstream(strs)
	return {
		strs=strs,
		offs=0,
		size=str_size,
		read1=str_r1,
		read2=read2
	}
end

-- helper functions

function readstrfixed(stream,len)
	local result=""
	for i=1,len do
		result..=chr(stream:read1())
	end
	return result
end

function readstr(stream)
	local len=stream:read1()
	return readstrfixed(stream,len)
end

-- file io

function loadanims(stream)
	printh("*** loading animations ***")

	-- verify header and version
	local hdr=readstrfixed(stream,3)
	if hdr~="mas" then
		printh("'mas' header not found")
		stop()
	end
	
	local ver=stream:read1()
	if ver>animfilever then
		printh("unsupported file version: "..ver)
		stop()
	end
	
	-- load each animation
	local ct=stream:read1()
	local anims={}
	for i=1,ct do
		local typ=stream:read1()
		local anim
		if typ==1 then
			anim=loadspriteanim(stream)
		else
		 anim=loadtlanim(stream,typ)
		end
		add(anims,anim)
		anims[anim.name]=anim
	end
	
	-- convert indices into references
	for anim in all(anims) do
	 if anim.typ~="sprite" then
	  for tl in all(anim.tls) do
	   for k in all(tl.keyframes) do
	    k.anim=k.anim and anims[k.anim]
	   end
	  end
	 end
 end

	return anims
end

function loadspriteanim(stream)
	local anim=makespriteanim()
	
	-- properties
	anim.name=readstr(stream)
	anim.subtype=stream:read1()
	anim.fps=stream:read1()/4
	anim.w=stream:read1()
	anim.h=stream:read1()
	anim.ox=stream:read1()/100
	anim.oy=stream:read1()/100

	-- frames
	anim.frames={}
	local ct=stream:read1()
	for i=1,ct do
		local frame={}
		frame.frame=stream:read2()
		local flags=stream:read1()
		frame.flipx=(flags&1)==1
		frame.flipy=(flags&2)==2
		add(anim.frames,frame)
	end
	
	return anim   
end

function loadtlanim(stream,typ)
 local anim=maketlanim()
 if(typ==3)anim.typ="storyboard"
 
	-- properties
	anim.name=readstr(stream)
	anim.d=stream:read2()/100
	
	-- timelines
	anim.tls={}
	local ct=stream:read1()
	for i=1,ct do
	 local keyframes={}
	 local kct=stream:read1()
	 for j=1,kct do
	 
	  -- time
	  local t=stream:read2()/100
	  local k=makekeyframe(t)
	  
	  -- content 
	  local flags=stream:read1()
	  if (flags&1)~=0 then 
	  	k.anim=stream:read1()		-- will be converted to object reference later
			end
	  if (flags&2)~=0 then
	  	k.x=stream:read2()
	  	k.y=stream:read2()
	  end
	  if (flags&4)~=0 then
	   k.xscale=stream:read2()/100
	   k.yscale=stream:read2()/100	   
	  end
	  if (flags&8)~=0 then
	   k.animt=stream:read2()/100
	   k.animspd=stream:read2()/100
	  end 
	  
	  -- state flags
	  flags=stream:read1()
	  k.flipx=(flags&1)~=0
	  k.flipy=(flags&2)~=0
	  k.visible=(flags&4)~=0
	  k.loop=(flags&8)~=0
	  
	  add(keyframes,k)
	 end
	 add(anim.tls,{keyframes=keyframes})	 
	end
	
	-- events
	anim.events.keyframes={}
	local ct=stream:read1()
	for i=1,ct do
	
  -- time
  local t=stream:read2()/100
	 local k=makeevent(t)
	 
	 -- type
	 k.typ=readstr(stream)
	 local flags=stream:read1()
	 if (flags&1)~=0 then
  	k.x=stream:read2()
  	k.y=stream:read2()	 	
  end
  if (flags&2)~=0 then
   k.n=stream:read1()
  end
  if (flags&4)~=0 then
   k.txt=readstr(stream)
  end	 
  add(anim.events.keyframes,k)
	end
	
	return anim
end

-- sprite animations

function drawanim(
		self,
		t,
		x,y,
		xscale,yscale,
		flipx,flipy,
		dt)
		
 self:dodraw(
 	t or 0,
 	x or 64,
 	y or 64,
 	xscale or 1,
 	yscale or 1,
 	flipx,
 	flipy,
 	dt or 1/(_update and 30 or 60),
 	0)
end

function spriteanim_draw(self,t,x,y,xscale,yscale,flipx,flipy)

	-- find frame
	local f=clamp(flr(t*self.fps)+1,1,#self.frames)
	local frame=self.frames[f]

	-- display width and height
	local dw,dh=self.w*8*xscale,self.h*8*yscale
	
	-- flip flags
	if(frame.flipx)flipx=not flipx
	if(frame.flipy)flipy=not flipy

	-- adjust for orgin pt
	x-=dw*(flipx and (1-self.ox) or self.ox)
	y-=dh*(flipy and (1-self.oy) or self.oy)

	-- draw
 if self.subtype==1 then	

		-- as sprite coords
		local sx,sy=sprcoords(frame.frame)
		sspr(
			sx,sy,
			self.w*8,self.h*8,
			x,y,
			dw,dh,
			flipx,flipy)
	
	else
	
		-- as tilemap coords
		local cx,cy=tilecoords(frame.frame)
		smap(
		 cx,cy,
		 self.w,self.h,
		 x,y,
		 dw,dh,
		 flipx,flipy)
	end		
end

function spriteanim_duration(self)
	return #self.frames/self.fps
end

function makespriteanim()
	return {
		typ="sprite",
		subtype=1, -- 1=sprite, 2=tiles
		name="sprite",
		fps=10,
		w=1,h=1,
		ox=0.5,oy=0.5,
		frames={
			makespriteframe(1),
		},
		duration=spriteanim_duration,
		dodraw=spriteanim_draw,
		draw=drawanim
	}
end

function makespriteframe(n)
	return {
		frame=n--,
--		flipx=false,
--		flipy=false
	}
end

-- timelined animations

function tlanim_duration(self)
	return self.d
end

keyframeswitch=split("anim,animt,animspd")
keyframelerp=split("x,y,xscale,yscale")
keyframeflags=split("flipx,flipy,visible,loop")

function findrefkeyframes(tl,prop,t)
 -- find nearest frames before/after t
 -- where property is not null
 local before,after
 local beforet,aftert=-1000,1000
 for k in all(tl.keyframes) do
  if k[prop] then
   if k.t<=t and k.t>beforet then
    before,beforet=k,k.t
   end
   if k.t>t and k.t<aftert then
    after,aftert=k,k.t
   end
  end
 end
 return before,after
end

function getvirtualkeyframe(tl,t)

 -- calculate the effective 
 -- "virtual" keyframe at time t
 -- on the timeline, interpolating
 -- as necessary.
 local props={
  visible=true,
  animt=0,animspd=1,
  x=0,y=0,
  xscale=1,yscale=1,
  flipx=false,flipy=false
 }

	-- switchover properties
 local animtt				
	for prop in all(keyframeswitch) do
	 before,after=findrefkeyframes(tl,prop,t)
	 local frame=before or after
	 if(frame)props[prop]=frame[prop]
		if prop=="animt" then
		 animtt=before and before.t
		end
	end

	-- interpolated properties
	for prop in all(keyframelerp) do
	 before,after=findrefkeyframes(tl,prop,t)
  if before and after then
   props[prop]=lerp(before[prop],after[prop],(t-before.t)/(after.t-before.t))
  else
		 local frame=before or after
		 if(frame)props[prop]=frame[prop]
		end			  
	end
	
	-- flags
	before,after=findrefkeyframes(tl,"t",t)
	local k=before or after
	if k then 
	 for prop in all(keyframeflags) do
	  props[prop]=k[prop]
	 end
	end
	
	-- calculate effective animt
	-- at time t, taking into account
	-- animation speed an looping.
	if animtt then
	 props.animt+=(t-animtt)*props.animspd
	end
	if props.loop and props.anim then
	 props.animt%=props.anim:duration()
	end
	return props
end

function tlanim_draw(self,t,x,y,xscale,yscale,flipx,flipy,dt,r)
 -- recursion limit
 r+=1
 if(r>10) return
 
 -- draw anims for each timeline
 for tl in all(self.tls) do

  -- get effective keyframe for t
		local props=getvirtualkeyframe(tl,t)
		
		-- draw child animation
		if props.visible and props.anim then
		
		 -- calculate effective position,scale and flip
		 local cx=x+props.x*xscale*(flipx and -1 or 1)
		 local cy=y+props.y*yscale*(flipy and -1 or 1)
		 local cxscale,cyscale=xscale*props.xscale,yscale*props.yscale
		 local cflipx,cflipy=flipx,flipy
   if(props.flipx)cflipx=not cflipx
   if(props.flipy)cflipy=not cflipy
   local cdt=dt and dt*props.animspd
		 
		 -- draw
		 props.anim:dodraw(props.animt,cx,cy,cxscale,cyscale,cflipx,cflipy,cdt,r)
		end		
	end
	
	-- trigger events
	if dt then
	 for k in all(self.events.keyframes) do
	  if k.t>t-dt and k.t<=t and anim_events[k.typ] then
    anim_events[k.typ](k,x,y)
	  end
	 end
	end	
end

function makekeyframe(t)
	return {
		t=t,
		anim=nil,
		loop=true,
		after=false,
--		animt=nil,
--		animspd=nil,
--		x=nil,
--		y=nil,
--		xscale=nil,
--		yscale=nil,
		visible=true,
		flipx=false,
		flipy=false
	}
end

function makeevent(t,typ)
 return {
  t=t,
  typ=""--,
--  x=nil,
--  y=nil,
--  n=nil,
--  txt=nil
 }
end

function maketl()

 -- default keyframe
 local k=makekeyframe(0)
 k.animt,k.animspd,k.x,k.y=0,1,0,0
 
	return {
		keyframes={k}	
	}
end

function maketlanim()
	return {
		typ="tl",
		name="timeline",
		d=10,
		tls={ maketl() },
		events={ keyframes={} },
		duration=tlanim_duration,
		dodraw=tlanim_draw,
		draw=drawanim
	}
end

-- events

do 
 local afterframeco={}
	local function doafterframe(fn)
		 add(afterframeco,cocreate(fn))
 end
 
 anim_events={
  sfx=function(ev)	sfx(ev.n)         end,
  mus=function(ev) music(ev.n or -1) end,
  txt=function(ev)
   doafterframe(function()
    for i=1,ev.n or 30 do
     print(ev.txt,ev.x,ev.y)
     yield()
    end
   end)
		end,
  reltxt=function(ev,x,y)
   doafterframe(function()
    for i=1,ev.n or 30 do
     print(ev.txt,x+(ev.x or 0),y+(ev.y or 0))
     yield()
    end
   end)
		end,
		clr=function()
		 afterframeco={}
		end,

		-- schedule code to execute after the frame
		-- can use yield() to execute after multiple frames
		doafterframe=doafterframe,
  
  -- call this after the frame is rendered
		framedone=function()
		 runcoroutines(afterframeco)
		end
 }
end
-->8
-- sprite animations

function drawspriteui(anim)

	-- fixups
	sprite_frame=clamp(sprite_frame,1,#anim.frames)

	-- mode icons
	local px,py=g_getpos()
	g_beginregion(100,py,128,py+10)
	g_x=108
	if(g_txtbtn("I", 8,sprite_mode==spritemode_props)) sprite_mode=spritemode_props
	if(g_txtbtn("â",10,sprite_mode==spritemode_frames))sprite_mode=spritemode_frames
	g_endregion()
	g_newline()
	
	-- properties
	if sprite_mode==spritemode_props then
		spritepropsui(anim)
	else
		spriteframesui(anim)
	end
end

function spritepropsui(anim)
	g_label("name",32)
	anim.name=g_txtbox(anim.name)
 g_newline()
 g_label("type",32)
 anim.subtype=g_chk(anim.subtype,"sprite",1,40)
 anim.subtype=g_chk(anim.subtype,"tiles",2,40)
 g_newline()
 	g_label("fps",32) 
	anim.fps=g_numbox(anim.fps,0.1,0.1,60,64) g_newline()	
 g_label("size",32)
 anim.w=g_numbox(anim.w,1,1,128,32)
 anim.h=g_numbox(anim.h,1,1,64,32) g_newline()
 g_label("origin",32)
 anim.ox=g_numbox(anim.ox,0.01,0,1,32)
 anim.oy=g_numbox(anim.oy,0.01,0,1,32) g_newline()
end

function drawtiles(drag,hover,x,y,xpos,ypos)
 map(0,0,x+sprite_xoffs,y+sprite_yoffs)
end

function spriteframesui(anim)
	-- frames
	local px,py=g_getpos()
	g_x=16
	local f=sprite_frame-2
	f=min(f,#anim.frames-4)
	f=max(f,1)
	for i=f,f+4 do
		if i<=#anim.frames then
			local frame=anim.frames[i]
			local function drawframe(down,hover,x,y)

    if anim.subtype==1 then	
					local sx,sy=sprcoords(frame.frame)
					sspr(sx,sy,anim.w*8,anim.h*8,x,y,16,16,frame.flipx,frame.flipy)
				else
				 local cx,cy=tilecoords(frame.frame)
				 smap(cx,cy,anim.w,anim.h,x,y,16,16,frame.flipx,frame.flipy)
				end
				
				-- selection rectangle
				local col
				if i==sprite_frame then col=7
				elseif down then col=10
				elseif hover then col=6
				end
				if col then
					rect(x-1,y-1,x+16,y+16,col)    
				end    
			end
			if g_btnex(drawframe,16,16,i==sprite_frame) then 
				if sprite_frame==i then
					-- show selected sprite
					if anim.subtype==1 then
						sprite_page=flr(frame.frame/64)
					else
      local tx,ty=frame.frame%128,flr(frame.frame/128)
					 sprite_xoffs,sprite_yoffs=-tx*8,-ty*8
					end      
				end
				sprite_frame=i
			end
			g_x+=2
		end
	end
	
	g_setpos(1,py+8)
	g_label(sprite_frame.."/"..#anim.frames)
	
	g_setpos(108,py)    
	if g_btn("+",10) then
		-- add new frame
		local lastframe=anim.frames[#anim.frames]
		local newframe=copyspriteframe(lastframe)
		add(anim.frames,newframe)
		sprite_frame=#anim.frames
	end
	if g_btn("-",10) and #anim.frames>1 then
		deli(anim.frames,sprite_frame)
		if(sprite_frame>#anim.frames)sprite_frame-=1
	end
	g_setpos(108,py+10)
	if g_btn("iNS",20) then
		-- insert new frame
		local frame=anim.frames[sprite_frame]
		local newframe=copyspriteframe(frame)
		add(anim.frames,newframe,sprite_frame)
	end
		
	-- frame properties
	local frame=anim.frames[sprite_frame]
	g_newline()
	frame.flipx=g_chk(frame.flipx,"flip x",nil,40)
	frame.flipy=g_chk(frame.flipy,"flip y",nil,40)

	-- page chooser buttons
	if anim.subtype==1 then
		g_setpos(88,86)
		for i=0,3 do
			if g_btn(""..(i+1),10,i==sprite_page) then
				sprite_page=i
			end
		end
	end
	
	-- frame chooser
	g_setpos(0,96)
	local hover=g_gethover(128,32)
	clip(0,96,128,128)
	
	if anim.subtype==1 then
	 for y=0,3 do
	  for x=0,15 do
	   local f=sprite_page*64+y*16+x
	   spr(f,x*8,y*8+96)
	  end
	 end
	else
	 -- draw/drag tilemap
	 local isdrag
	 sprite_xoffs,sprite_yoffs,isdrag=g_drag(drawtiles,sprite_xoffs,sprite_yoffs,128,32)
	 if not isdrag then
	  sprite_xoffs=clamp(round(sprite_xoffs/8)*8,-1920,0)
	  sprite_yoffs=clamp(round(sprite_yoffs/8)*8,-224,0)
	 end
	end
	
	-- hover/select frame
	local rowsize=anim.subtype==1 and 16 or 128
	if hover then
		local fx,fy=flr(g_mx/8),flr((g_my-96)/8)
		local sx,sy=fx*8,fy*8+96
		rect(sx,sy,sx+anim.w*8-1,sy+anim.h*8-1,6)
		if g_clk then
		 if anim.subtype==1 then
		  fy+=sprite_page*4
		 else
		  fx-=flr(sprite_xoffs/8)
		  fy-=flr(sprite_yoffs/8)
		 end
			frame.frame=fy*rowsize+fx
		end
	end
		
	-- show selected frame
	local sx,sy=(frame.frame%rowsize)*8,flr(frame.frame/rowsize)*8+96
	if anim.subtype==1 then
	 sy-=sprite_page*32
	else	
	 sx+=sprite_xoffs
	 sy+=sprite_yoffs
	end
	rect(sx,sy,sx+anim.w*8-1,sy+anim.h*8-1,7)
	
	clip()
	camera()
end

function copyspriteframe(f)
	local newframe=makespriteframe(f.frame)
	newframe.flipx=f.flipx
	newframe.flipy=f.flipy
	return newframe
end

-->8
-- timelined animations

eventtypes=split("sfx,mus,txt,reltxt,clr")

function addeventtype(typ)
 if not indexof(eventtypes,typ) then
  add(eventtypes,typ)
 end
end

function drawtlui(anim)

 layoutstoryboard(anim)

	-- mode icons
	local px,py=g_getpos()
	g_beginregion(100,py,128,py+10)
	g_x=108
	if(g_txtbtn("I", 8,tl_mode==tlmode_props)) tl_mode=tlmode_props
	if(g_txtbtn("ê",10,tl_mode==tlmode_keyframes))tl_mode=tlmode_keyframes
	g_endregion()
	g_newline()
	
	if tl_mode==tlmode_props then
		tlpropsui(anim)
	else
		tlkeyframesui(anim)
	end
end

function tlpropsui(anim)
	g_label("name",32)
	anim.name=g_txtbox(anim.name)
	g_newline()
	g_label("duration",32)
 anim.d=g_numbox(anim.d,0.1,0.1,nil,64) g_newline()
end

function tlkeyframesui(anim)

 -- ensure timeline index in range
 tl_tl=clamp(tl_tl,0,#anim.tls)

 local sx,sy=g_x,g_y

 -- draw timelines
 local nlines=7
 local px,py,w,h=g_x,g_y,60,5
	local f=tl_tl-flr(nlines/2+0.5)
	f=min(f,#anim.tls-nlines+1)
	f=max(f,1)
	local hoverany=g_gethover(w,h*nlines) and not g_mbp
	local hovert=clamp((g_mx-g_x)/w,0,1)*anim.d

 local xfromt=function(t)
  return g_x+(t/anim.d)*w
 end

 -- show current time
 local x=xfromt(app_t)
 line(x,py,x,py+h*nlines-1,6)

	-- show hover time
 if hoverany then
  local x=xfromt(hovert)
  line(x,py,x,py+h*nlines-1,5)
  print(hovert,x-8,py-6,5)
  app_toverride=hovert
 end 

 -- click to select time
	if g_clk and hoverany then
  -- select time
  app_t=hovert
	 app_animating=false
	 tl_keyframe=nil
 end

 -- draw timelines and keyframes
 local function drawtlui(tl,i,seltl)
		g_makespc(w,h)
		local hover=g_gethover(w,h) and not g_mbp
			
		-- draw timeline
		local col=i~=0 and 5 or 1
		if(hover)col=6
		if(seltl)col=i~=0 and 7 or 12
		if(hover and g_mb)col=10

		line(g_x,g_y+2,g_x+w,g_y+2,col)
			
		-- draw keyframes
		local hoverkd,hoverki,hoverkx=5
		for ki,k in ipairs(tl.keyframes) do
		 local x=xfromt(k.t)
		 local selk=seltl and ki==tl_keyframe
		 if hover then
			 -- find nearest hovered keyframe
			 local d=abs(g_mx-x)
			 if d<hoverkd then
			  hoverkx,hoverki,hoverkd=x,ki,d
			 end
		 end
		 pset(x,g_y+2,selk and 9 or 2)
		end
		if(hoverkx)pset(hoverkx,g_y+2,14)
		
		-- hover/click logic
		if hover then
		 if g_clk then		  
		  -- select timeline
		  tl_tl=i
		  -- select keyframe
			 tl_keyframe=hoverki
			 
			 -- select keyframe time
			 if tl_keyframe then
					app_t=tl.keyframes[tl_keyframe].t
				end
		 end
		end
			
		g_newline(h)
	end

 -- draw events timeline
 if anim.typ=="tl" then
	 drawtlui(anim.events,0,tl_tl==0) 	
 end

 -- draw animation timelines
	for i=f,f+nlines-1 do
		if i<=#anim.tls then
			drawtlui(anim.tls[i],i,i==tl_tl)
		end
	end
	
	-- keyframe buttons
	local tl=tl_tl~=0 and anim.tls[tl_tl] or anim.events
	g_setpos(1,py+h*(nlines+1)+2)
	g_label("k",4)
	if g_btn("+",8) then
	 local k
	 if tl_tl~=0 then
	 	-- regular animation keyframe
		 local props=getvirtualkeyframe(tl,app_t)
		 k=makekeyframe(app_t)
		 k.flipx,k.flipy,k.visible,k.loop=props.flipx,props.flipy,props.visible,props.loop
		else
		 -- event
		 k=makeevent(app_t)
		end
	 -- add to timeline and select
	 add(tl.keyframes,k)
	 tl_keyframe=#tl.keyframes
	end
	if g_btn("-",8) and tl_keyframe then
	 deli(tl.keyframes,tl_keyframe)
	 tl_keyframe=nil
	end
	if anim.typ=="storyboard" then
		local swapd
	 if g_btn("ã",11) and tl_keyframe>1 then
	  swapd=-1
	 end
	 if g_btn("ë",11) and tl and tl_keyframe<#tl.keyframes then
	  swapd=1
	 end
	 if swapd then
	  -- swap keyframes
	  local k=tl.keyframes[tl_keyframe+swapd]
	  tl.keyframes[tl_keyframe+swapd]=tl.keyframes[tl_keyframe]
	  tl.keyframes[tl_keyframe]=k
	  -- select prev keyframe in new position
	  tl_keyframe+=swapd
	  app_t=k.t
	 end	 
	end
	
	g_newline()
	
	-- timeline buttons
	if anim.typ=="tl" then
		g_label("t",4)	
		if g_btn("+",8) then
			-- add new timeline
			add(anim.tls,maketl())
			tl_tl=#anim.tls
		end
		if g_btn("-",8) and #anim.tls>1 then
			-- delete timeline
			deli(anim.tls,tl_tl)
			tl_tl=min(tl_tl,#anim.tls)
		end
		-- move timeline up/down
		local move
		if(g_btn("î",11) and tl_tl>1)move=-1
		if(g_btn("É",11) and tl_tl<#anim.tls)move=1
		if move then
		 local tl=anim.tls[tl_tl]
		 anim.tls[tl_tl]=anim.tls[tl_tl+move]
		 tl_tl+=move
		 anim.tls[tl_tl]=tl
		end
	end
	
	-- keyframe properties
	local tl=tl_tl~=0 and anim.tls[tl_tl] or anim.events
	if tl_keyframe and tl_keyframe<=#tl.keyframes then
  local k=tl.keyframes[tl_keyframe]	

	 -- header and time slider
	 g_column(sx+w+3,127,sy)
	 rectfill(sx+w+2,sy-1,127,sy+9,1)
		if anim.typ=="tl" then
	  k.t=g_numbox(k.t,0.05,0,anim.d,48)
  end
 
 	if tl_tl~=0 then
	  -- regular animation keyframe
	  
   -- calculate default keyframe properties
   -- based on other keyframes in the timeline
   local otherkeyframes={}
   for ok in all(tl.keyframes) do
    if(ok~=k)add(otherkeyframes,ok)
   end
   local props=getvirtualkeyframe({keyframes=otherkeyframes},k.t)
	 
	  -- tabs
  	if(g_txtbtn("â",7,tl_tab==1))tl_tab=1
  	if(g_txtbtn("ï",7,tl_tab==2))tl_tab=2
  	g_newline()
 	
 		-- anim tab
 		if tl_tab==1 then
   	g_label("anm",13)
 	 	if g_txtbtn(k.anim and k.anim.name or "nONE",50) then
 	   chooseanim(k.anim,function(anim)k.anim=anim end)
 	 	end
 	 	g_newline()
 	 	if anim.typ=="tl" then
	   	g_x+=13 k.loop=g_chk(k.loop,"loop",nil,27) g_newline()
	   	g_label("t",13)
		  	if k.animt then
	 	  	k.animt=g_numbox(k.animt,0.1,0,60,40)
	 	  else
	 				g_x+=40
	 	  end
	 	  if g_chk(k.animt~=nil) then
	 	   if not k.animt then
	 		   k.animt,k.animspd=props.animt,props.animspd
	 		  end
	 	  else
	 	   k.animt,k.animspd=nil,nil
	 	  end
 	  end
   	g_label("spd",13)
   	if k.animt then
 	  	k.animspd=g_numbox(k.animspd,0.1,-10,10,40)
 	  end
 	  g_newline()
   elseif tl_tab==2 then		
	   numbox2d(k,"pos","x","y",props,1)
 	  numbox2d(k,"sca","xscale","yscale",props,0.01)
 	  g_label("flp",13)
 	  k.flipx=g_chk(k.flipx,"x",nil,18)
 	  k.flipy=g_chk(k.flipy,"y",nil,18) g_newline()
 		end
  	g_y=118
   g_x+=13 
   if(anim.typ=="tl")k.visible=g_chk(k.visible,"visible",nil,39)
 	else
 	 -- event
  	g_newline()
  	g_label("typ",13)
  	if g_txtbtn(k.typ~="" and k.typ or "[none]",49) then
  	 g_choosefromlist(
  	 	eventtypes,
  	 	nil,
  	 	function(choice)
  	 	 if choice then
  	 	  k.typ=choice
  	 	 else
  	 	  g_promptbox(
	  	 	  "event type",
	  	 	  function(keyed)
	  	 	   k.typ=keyed	  
	  	 	   if(keyed~="")addeventtype(keyed)	 	   
	  	 	  end,
	  	 	  k.typ)  	 	  
  	 	 end
  	 	end,
  	 	indexof(eventtypes,k.typ),
  	 	"cUSTOM")
  	end
--  	k.typ=g_txtbox(k.typ,49) 
  	g_newline()
  	numbox2d(k,"pos","x","y",{x=0,y=0},1)
  	g_label("n",13)
  	if k.n then
	  	k.n=g_numbox(k.n,1,0,255,40) 
	  else
    g_x+=40	   
   end
   if g_chk(k.n~=nil) then
    k.n=k.n or 0
   else
    k.n=nil
   end   
  	g_newline()
  	g_label("txt",13)
  	if k.txt then
	  	k.txt=g_txtbox(k.txt,40)
	  else
	   g_x+=40
	  end
	  if g_chk(k.txt~=nil) then
	   k.txt=k.txt or ""
	  else
	   k.txt=nil	   
	  end
 	end
	end
end

function numbox2d(obj,caption,xprop,yprop,defprops,incr)
 g_label(caption,13)   
 if obj[xprop] then
  obj[xprop]=g_numbox(obj[xprop],incr,nil,nil,20)
	 obj[yprop]=g_numbox(obj[yprop],incr,nil,nil,20)
	else
	 g_x+=40
	end
	if g_chk(obj[xprop]~=nil) then
	 if(not obj[xprop])obj[xprop],obj[yprop]=defprops[xprop],defprops[yprop]
	else
  obj[xprop],obj[yprop]=nil,nil
	end
	g_newline()
end

function layoutstoryboards(anims)

 -- if storyboards are nested, it
 -- may take more than one iteration
 -- for the duration changes to propogate 
 -- through.
 -- so we loop until no duration changes 
 -- are detected.
 for i=1,10 do
  local changed=false
  
  -- find and layout storyboard animations
	 for anim in all(anims) do
	  if layoutstoryboard(anim) then
	  	changed=true
	  end
	 end
	 if(not changed)return
	end
end

function layoutstoryboard(anim)
 if(anim.typ~="storyboard")return

 -- storyboard animations should
 -- always have exactly one timeline
 local t=0
 for k in all(anim.tls[1].keyframes) do

  -- set keyframe storyboard defaults
  k.t,k.animt,k.loop=t,0,false
  k.animspd=k.animspd or 1
  
  -- calculate start of next keyframe
	 if k.anim and k.animspd>0 then
	  t+=k.anim:duration()/k.animspd
	 else
	  t+=1		-- 1 second default duration to prevent keyframes piling up.
	 end
	end
	
	-- adjust duration. return true if changed.
	local changed=t~=anim.d
	anim.d=t
	
	return changed
end

-->8
-- main

-- constants
spritemode_props,
spritemode_frames,
tlmode_props,
tlmode_keyframes
=1,2,1,2

function reset()

	-- default anim
	anims={ makespriteanim() }
	
	-- initial state
	app_anim=anims[1]
	app_t=0
	app_toverride=nil
	app_animating=true
	
	-- current animation
	anim_scalebit=0
	anim_scale=1
	anim_xoffs=0
	anim_yoffs=0
	anim_maximised=true
	
	-- sprite editor
	sprite_frame=1
	sprite_page=0
	sprite_xoffs,sprite_yoffs=0,0
	sprite_mode=spritemode_frames
	
	-- timeline editor
	tl_mode=tlmode_keyframes
	tl_tl=1
	tl_keyframe=1
	tl_tab=1
end

function doload()

	-- load into gfx ram, then decode
	reload(0x0,0x0,0x4300,datacart)
	local stream=memstream(0x0)
	anims=loadanims(stream)
	app_anim=anims[1]	
	
	-- restore gfx ram
	reload(0,0,0x4300,gfxcart)
end

function _init()

	-- initial state
	reset()
	
	-- drop down menus
	menu_main=split("load,save,save as,import gfx,export anims,clear")
	menu_main_fn={
	 menuload,
		menusave,
		menusaveas,
		menuimportgfx,
		menuexportanims,
		menuclear
	}
	menu_anim=split("new sprite anim,new timeline anim,new storyboard anim,delete anim")
	menu_anim_fn={
		menunewspriteanim,
		menunewtlanim,
		menunewstoryanim,
		menudeleteanim
	}

	-- load builtin animations
	local stream=memstream(0x1000)
	anims=loadanims(stream)
	app_anim=anims["intro"]	
end

function _draw()
	cls()
	
	-- immediate mode gui
	g_beg()

	-- editor
	draweditor()
	
	g_end()
end

function getanimname(anim)
 return anim.typ..":"..anim.name
end

function draweditor()

 -- keep animation list sorted
 sort(anims,getanimname)
 
 local isfullscreen=anim_maximised and (g_mx<0 or g_mx>128 or g_my<0 or g_my>128)

	-- animation selector
	if not isfullscreen then
		rectfill(0,0,128,10,1)
		local animi=indexof(anims,app_anim)
		g_autonewline(false)
		if g_txtbtn(app_anim.name,64) then
	  chooseanim(app_anim,function(anim)
	   app_anim=anim or app_anim
	   anim_events.clr()
	   layoutstoryboards(anims)
	  end)	 
		end
	
		-- drop down menus
		g_x=105
		local item=g_menu("ò",menu_anim)
		if item then
		 menu_anim_fn[indexof(menu_anim,item)]()
  end
		local item=g_menu("ì",menu_main)
		if item then
   menu_main_fn[indexof(menu_main,item)]()
		end
	end 
	
	-- animation ui
	g_newline()
	g_autonewline(false)

	-- preview
	drawpreview(isfullscreen)
	if(isfullscreen)return
	anim_maximised=not g_expand("properties", not anim_maximised)
	if(anim_maximised)return
	
	if app_anim.typ=="sprite" then
		drawspriteui(app_anim)
	else
		drawtlui(app_anim)
	end 
end

function dosave()

 -- ensure all storyboards are up to date
 layoutstoryboards()

 -- write to gfx ram, then copy to cart
	local stream=memstream(0)
	saveanims(anims,stream)
	cstore(0x0,0,stream:size(),datacart)
	printh(stream:size().."/17152 bytes")

	-- restore gfx ram
	reload(0,0,0x4300,gfxcart)	
end

function menusave()
 if not datacart then
 	menusaveas()
 else
 	dosave()
 end 
end

function menusaveas()
 carts=getanimcarts()
 local idx=indexof(carts,datacart)
 
 function confirmandsave(cart)
  g_msgbox(
  	{"overwrite?"},
  	{"yes","no"},
  	function(choice)
  	 if choice=="yes" then
		   datacart=cart
		   dosave()
		  end
		 end)			
 end 
 
 function promptandsave()
  g_promptbox("new cart",
  	function(cart)
  	 datacart=cart..".anim.p8"
  	 dosave()
  	end)
 end
 
 g_choosefromlist(
  carts,
  nil,
  function(cart)
   if cart then
	   confirmandsave(cart)
	  else
	  	promptandsave()
	  end
  end,
  idx,
  "nEW cART")
end

function menuload()
 local carts=getanimcarts()
 local idx=indexof(carts,datacart)
 g_choosefromlist(
  carts,
  nil,
  function(cart)
	  datacart=cart
		 reset()
		 doload()
  end,
  idx)
end

function doimportgfx()
 reload(0,0,0x4300,gfxcart)
end

function menuimportgfx()
 local carts=getregularcarts()
 local idx=indexof(carts,gfxcart)
 g_choosefromlist(
  carts,
  nil,
  function(cart)
	  gfxcart=cart
		 doimportgfx()
  end,
  idx) 
end

function menuexportanims()
 local stream=strstream()
	saveanims(anims,stream)
	printh("{")
	for str in all(stream.strs) do
		printh(" \""..str.."\",")
	end
	printh(" \"\"}")
end

function menuclear()
 g_msgbox(
 	{"clear all anims?"},
 	{"yes","no"},
 	function(choice)
 	 if choice=="yes" then
 	  reset()
	  end
	 end)			
end

function menunewspriteanim()
 app_anim=makespriteanim()
	add(anims,app_anim)
end

function menunewtlanim()
 app_anim=maketlanim()
	add(anims,app_anim)
end

function menunewstoryanim()
 -- internally a "storyboard" animation
 -- is just a timelined animation.
 -- the editor just lays out the
 -- keyframes so that each anim starts
 -- after the previous one finishes.
 app_anim=maketlanim()
 app_anim.name,app_anim.typ="storyboard","storyboard"
 add(anims,app_anim)
end

function menudeleteanim()
	if #anims>1 then
		del(anims,app_anim)
		app_anim=anims[1]
	end
end

function drawpreview(isfullscreen)

	-- preview - with dragging
	local px,py=g_getpos()
	g_x=0
	local w,h=128,anim_maximised and 107 or 44
	if(isfullscreen)g_y,h=0,128
	local hover=g_gethoverraw(w,h)
	local wheel=g_gethover(w,h) and stat(36) or 0
	local function drawanim(drag,hover,x,y,xpos,ypos)
		camera(-x-anim_xoffs,-y-anim_yoffs)
		clip(x,y,w,h)
		
		-- draw main animation
		app_anim:draw(
			app_toverride or app_t,
			w/2,h/2,
			anim_scale,anim_scale,
			false,false,
			app_animating and 1/30 or 0)

  -- perform any frame-done events
		color(7)
		anim_events.framedone()
		
		if hover then
		 local col=drag and 6 or 5
			line(-1000,h/2,1000,h/2,col)
			line(w/2,-1000,w/2,1000,col)
		end
		camera()
		clip() 
	end
	anim_xoffs,anim_yoffs=g_drag(drawanim,anim_xoffs,anim_yoffs,w,h)
	app_toverride=nil

	-- preview controls 
	if hover then
		g_beginregion(72,py+h-10,128,py+h)
		anim_scalebit=clamp(g_slider(anim_scalebit,-3,3,1,32)+wheel,-3,3)
		anim_scale=1<<anim_scalebit
		if g_btn(app_animating and "||" or ">",12) then
			app_animating=not app_animating
			anim_events.clr()
			music(-1)
		end
		if g_btn("ä",12) then
		 anim_xoffs,anim_yoffs,anim_scalebit,anim_scale=0,0,0,1
		end
		g_setpos(88,py+h-10)
		g_label(""..anim_scale,12)
		g_endregion()
	end
	
	-- position cursor
	py+=h
	g_setpos(px,py)
end

function chooseanim(refanim,callbackfn)
 local idx=indexof(anims,refanim)
 g_choosefromlist(
 	anims,
 	function(anim)
 		return (anim.typ=="sprite" and "â " or "ê ")..anim.name 
 	end,
 	callbackfn,
 	idx,
 	"nONE")
end

function _update()

	-- advance animation
	if app_animating then
		app_t=app_t+1/30
		local duration=app_anim:duration()
		app_t%=duration
	end   
end
-->8
-- routines

function round(v)
 return flr(v+0.5)
end

function indexof(array,elem) 
 for i,e in ipairs(array) do
  if(e==elem)return i
 end
end

function sort(array,getkeyfn)
 getkeyfn=getkeyfn or function(e)return e end
 for i=2,#array do
  local e,j=array[i],i
  local k=getkeyfn(e)
  while j>1 and getkeyfn(array[j-1])>k do
   array[j]=array[j-1]
   j-=1
  end
  array[j]=e
 end
end

function filter(array,pred)
 local result={}
 for e in all(array) do
  if(pred(e))add(result,e)
 end
 return result
end

function isanimcart(file)
 return #file>=9 and sub(file,#file-7,#file)==".anim.p8"
end

function isregularcart(file)
 return #file>=4 and sub(file,#file-2,#file)==".p8" and not isanimcart(file)
end

function getregularcarts()
 return filter(dir(),isregularcart)
end

function getanimcarts()
 return filter(dir(),isanimcart)
end

-->8
-- file i/o

function write2(self,v)
 self:write1(v&0xff)
 self:write1((v>>8)&0xff)
end

-- memory stream

function mem_w1(self,v)
 poke(self.addr,v)
 self.addr+=1
end

function memstream(addr)
 local stream=readmemstream(addr)
 stream.write1=mem_w1
 stream.write2=write2
 return stream
end

-- hex string stream

function tohexchar(num)
 return chr(num+(num>=10 and 87 or 48))
end

function str_w1(self,v)
 self.strs[flr(self.offs>>10)+1]..=tohexchar((v&0xf0)>>4)..tohexchar(v&0x0f)
 self.offs+=2
end

function strstream()
 local stream=readstrstream(split(",,,,,,,,,,,,,,,"))
 stream.write1=str_w1
 stream.write2=write2
 return stream
end

-- helper functions

function writestrfixed(s,stream)
-- printh("write string: "..s)
	for i=1,#s do
		stream:write1(ord(s,i))
	end
end

function writestr(s,stream)
	stream:write1(#s)
	writestrfixed(s,stream)
end

-- file io

function saveanims(anims,stream)
	printh("*** saving animations ***")
	writestrfixed("mas",stream)
	stream:write1(animfilever)
	stream:write1(#anims)
	for anim in all(anims) do
		if anim.typ=="sprite" then
			savespriteanim(anim,stream)
		else
		 savetlanim(anim,stream)
		end
	end
end

function savespriteanim(anim,stream)
-- printh("saving sprite anim: "..anim.name)
	stream:write1(1)
	
	-- properties
	writestr(anim.name,stream)
	stream:write1(anim.subtype)
	stream:write1(anim.fps*4)
	stream:write1(anim.w)
	stream:write1(anim.h)
	stream:write1(round(anim.ox*100))
	stream:write1(round(anim.oy*100))
	
	-- frames
	stream:write1(#anim.frames)
	for frame in all(anim.frames) do
		stream:write2(frame.frame)
		local flags=0
		if(frame.flipx)flags|=1
		if(frame.flipy)flags|=2
		stream:write1(flags)
	end
end

function savetlanim(anim,stream)
-- printh("saving timeline anim: "..anim.name)
	stream:write1(anim.typ=="tl" and 2 or 3)
	
	-- properties
	writestr(anim.name,stream)
	stream:write2(round(anim.d*100))
	
	-- timelines
 stream:write1(#anim.tls)		
 for tl in all(anim.tls) do
  stream:write1(#tl.keyframes)
  for k in all(tl.keyframes) do

			-- time  
   stream:write2(round(k.t*100))

   -- content flags
   local flags=0
   if(k.anim)flags|=1
   if(k.x)flags|=2
   if(k.xscale)flags|=4
   if(k.animt)flags|=8
   stream:write1(flags)
   
   -- content
   if k.anim then
    stream:write1(indexof(anims,k.anim))
   end
   if k.x then
	   stream:write2(k.x)
 	  stream:write2(k.y)
 	 end
 	 if k.xscale then
	   stream:write2(round(k.xscale*100))
	   stream:write2(round(k.yscale*100))
 	 end
 	 if k.animt then
 	  stream:write2(round(k.animt*100))
 	  stream:write2(round(k.animspd*100))
 	 end
   
   -- state flags
   flags=0
   if(k.flipx)flags|=1
   if(k.flipy)flags|=2
   if(k.visible)flags|=4
   if(k.loop)flags|=8
   stream:write1(flags)   
  end  
 end
 
 -- events
	stream:write1(#anim.events.keyframes)
	for k in all(anim.events.keyframes) do

		-- time and type
  stream:write2(round(k.t*100))
  writestr(k.typ,stream)
  
  -- content flags
	 local flags=0
	 if(k.x)flags|=1
	 if(k.n)flags|=2
	 if(k.txt)flags|=4
	 stream:write1(flags)
	 
	 -- content
  if k.x then
   stream:write2(k.x)
	  stream:write2(k.y)
	 end
	 if(k.n)stream:write1(k.n)
	 if(k.txt)writestr(k.txt,stream)
	end
end


__gfx__
000000000000000a0000000000031000000007aaaaaaaaaaaaaaaaa0a9999999aaaaaaa0aaaaaaaa0aaaaaa0000077a7aaa90000ccccccccdddddddd00000555
000000000000000000000000000310000007aa999999999999999994a99999999999999499999999a999999400007a9999940000ccccccccdddddddd00000575
00700700000000070000000000033000007a99999999999999999994a99999999999999499999999a99999940000a99999940000ccccccccdddddddd00000545
0007700000000007000000000033310007a999999999999999999994a99999999999999499999999a99999940000a99999940000ccccccccdddddddd00000545
00077000000000a7a0000000003b31000a9999999999999999999994a99999999999999499999999a99999940000799999940000ccccccccdddddddd00000595
007007000000007770000000003333007a999999aaaaaaaa99999994a9999999aaaaaaa499999999a999999400000a9999400000ccccccccdddddddd00000545
000000000000aa777aa00000003b3300a999999444444444a9999994a999999944444444a9999994a999999400000a9999400000ccccccccdddddddd00000545
00000000a0777777777770a003333310a999999444444444a9999994a999999444444440a9999994a999999400000a9999400000ccccccccdddddddd00000595
000000000000aa777aa0000003b33310a99999949999999955555555777a7aa7a9999994a9999994a999999900000a99994000001111cc11cccccccc00000595
00000000000000777000000003333330a999999499999999555555557aa9999999999994a99999949999999900000a999940000011111111cccccccc00000595
00000000000000a7a000000003b33330a99999949999999955555555a999999999999994a999999499999999000000a99400000011c11111cccccccc00000545
00000000000000070000000033333331a9999994999999995555555579999999999999947999999499999999000000a994000000c111111ccccccccc00000545
00000000000000070000000033333311a99999949999999955555555a999999999999994aa99999499999999000000799400000011111c11cccccccc00000595
00000000000000000000000001311110a99999949999999955555555a7aaaaaa99999994777a7a94aaaaaaaa00000077a400000011111111cccccccc00000545
000000000000000a0000000000094000a99999949999999955555555a944944499999994a944944444444444000000a44400000011cc1111cccccccc00000545
00000000000000000000000000094000a99999949999999955555555049444449999999404944440444444440000000440000000c111111ccccccccc00000595
7e0007e0000000000000000000000000a99999997999999400000000000000111111111100bbbbbbbbbbbbbbbbbbbbbbbbbbbb00a999494dd000ddddd4994994
e8000e80000000000000000000000000a9999999999999940000000000001155555555550344b3943b343bb33bbbbbb449bb3bb04944494ccdddcccccc444994
888088807e07ee807e0807ee807e0000799999999999999400000000001155555555555504a9934a9ba9934a93b39b3a94a3943094a994ccccccccccc4a9944a
58808850e80e8550e8080e8580e80000a999999999999994000000001155555555555555049949499399434993934b49949349409499494cccccccccc4994949
08808800e8088880e8080e8080e800007aa999999999999400000011555555555555555500449a9449449a944944939449449a9449449a94cccccccccc449a94
05888500880555808808088880880000777a7aaaaaaaaa94000011555555555555555555004a4994994a4994994a4394994a4994994a4994cccccccccc4a4994
00888000880888808888088580888800a944944444444444001155555555555555555555004944494449444944494449444944404449444ccccccccccc494449
00555000550555505555055050555500049444444444444011555555555555555555555504a44a947a944a947a944a947a94a4007a94a4ccccccccccc4a44a94
7ccdd000000000000000000000000000000000000000000000000000110000000000000004994994a9994994a9994994a9994940a999494ccccccccc49994994
cc111000000000000000000000000000000000000000000000000000551100000000000000444994494449944944499449444940494449944c444cc449444994
cd00007cd007c07ccd07ccd07ccd0000000000000000000000000000555511000000000004a9944a94a9944a94a9944a94a9940094a9944a94a9944a94a9944a
cddd00cd1d0cd01dd10cd1d0cd1d0000000000000000000000000000555555110000000004994949949949499499465994994940949949499499494994994949
dd1100cd0d0cd00dd00cd0d0cd0d0000000000000000000000000000555555551100000000449a9449449a944944676549449a9449449a9449449a9449449a94
cd0000dd0d0dd00dd00dd0d0ddd100000000000000000000000000005555555555110000004a4994994a4994994a5665994a4994994a4994994a4994994a4994
ddddd0ddd10dd00dd00dddd0dd0d0000000000000000000000000000555555555555110000494449444944494449455944494440444944494449444944494449
11111011100110011001111011010000000000000000000000000000555555555555551104a44a947a944a947a944a947a94a4007a944a947a944a947a944a94
000000000000000000000000000bb3bb33335000000000000333335000000000677666dd00000000006dddddddddddddddddddddddddddddddddddd500555550
00044000000440000000000f00b11b3b3b3335000000000003bb3350000000005dd55555000000000656ddddddddddddd5555555555555555555555100576d50
0049940000499400000044070b1c7bbb33333550000000003bbb335500000000d66ddd55000000000656666666666666d5555555555555555555555100576d50
00effe0000effe00000499703b176bbbb3333355000000003bbb333500000000d66ddd55000000000656777777777777d5555555555555555555555155555555
000ee000000ee000000ef7703bbb3bb3333335550033300033bb335500555000d66ddd55000000000656777777777777d5555555555555555555555156d75766
007ff700077ff7000000e70033bbbb3b3333335303bb35003bb3335d05335500d66ddd55000000000656666666666666d5555555555555555555555155d75d6d
0777777077777770007ff700333b3b333333355503b3550033bb335d05355500d66ddd550000000065dd666666666666d5555555555555555555555155555555
77777777707777770777770053333333d333335503b355000333355505355d00d66ddd550000000065dd677777777777d5555555555555555555555156d7dd65
70677607f0677607076776000553335d3333355503333500033b35d005555500d55555510000000065dd666666666666d5555555555555555555555155555555
f067760f006776077067760005555dd33b33335d03b355000333355005355d00d55555510000000065dd666666666666d5555555555555555555555156d7dd57
00dddd0000dddd0ff0dddd0000ddd553bbb3353d033355000033350005555d00d55555510000000065dd666666666666d5555555555555555555555155d7dd56
00dddd0000dddd0000dd0dd00000553bbb33535d03335500003b350005555d00d55555510000000065dd666666666666d5555555555555555555555155555555
00d00d0000d00d00000d00d00000553bb333355d03b335000033350005355d00d55555510000000065dd666666666666d5555555555555555555555156d75766
00d00d0000d00d00000d0dd000000333b33353d003b355000bb3b33005355d00d555555100000000655d666666666666d5555555555555555555555155d75d6d
00d00d0000d00d000ddd0d0000000333333555d00eeeee000333335002222200d555555100000000566d666666666666d5555555555555555555555155555555
0dd00dd00dd00dd00d000dd00000003333355d00effefe40055555502ee2e240d555555100000000677d6dddddddddddd5555555555555555555555156d7dd65
000000000000000000066600ddddddddddddddddddddddd5555555555555555500000dddddd00000d66d666666666666d5555555555555555555555100555550
000000000066600006677760d555555555555555555555516657665766576657000dd676666dd0005ddd666666666666d5555555555555555555555100576650
000660000677760006777776d55555555555555555555551dd566d56dd566d5600d77dddddd66d00655d6dddddddddddd5555555555555555555555100566d50
006776000677776067777776d5555555555555555555555155555555555555550d76d555555d66d065dd6dddddddddddd5555555555555555555555155555555
000676000677776067777760d555555555555555555555515766565d5d5657660d6d55555555d6d065dd666666666666d5555555555555555555555157665766
000060000067776067777776d55555555555555555555551566d55d5d5d5566dd6d5555555555d6d65dd6dddddddddddd55555555555555555555551566d566d
000000000006660006677660d5555555555555555555555155555d5ddd5d5555d6d5555dd5555d6d65dd6dddddddddddd5555555555555555555555155555555
000000000000000000066000511111111111111111111111665755ddddd55665d6d555d76d555d6d65dd6ddddddddddd51111111111111111111111166576665
00000000000000000000000000000000004444400000000055555d5ddd5d5555d6d555d66d555d6d65dd6ddddddddddd0d66666666666666666666d055555555
00000000000000000000000000000000444f444440000000665755ddddd55657d6d5555dd5555d6d65dd65555555555567777777777777777777777666576657
6666666666666666000000000000000044f4444444400000dd565d5ddd5d5d56d6d5555555555d6d0656ddddddddddddd6666666666666666666666ddd566d56
777777777777777700000000000000004444f44444444444555555ddddd555550d6d55555555d6d00656555555555555d6666666666666666666666d55555555
55555555555555550000000000000000444444444455554457665d5ddd5d57660d66d555555d66d00656555555555555d6666666666666666666666d57665766
004445000000000000000000000000005444455555500000566d55d5d5d5566d00d66dddddd66d000656dddddddddddd5dddddddddddddddddddddd5566d566d
0045550000000000000000000000000005555455000000005555555555555555000dd666666dd00006565555555555555dddddddddddddddddddddd555555555
000000000000000000000000000000000005455000000000665766656657666500000dddddd00000006555555555555505555555555555555555555066576665
d616371093108026d236163747c65620820101232310097000107026d28696c6c637208201802300100ab000107026d2271696c6372082011023231002800010
5026d237561620820101232310087000107026d2472756563720820101232310020000107036d24616e6365610b310202346a004000014000004000014001004
0000140000240000240000240000240000107007d237071627b610822020232310100000106047d216e696d620820140232310003000107047d216e696d63720
822140232310003000108047d256469647f62710824010232310030000106047d2d6f6473720820140232310000000108047d23797374756d620820140232310
085000108047d26796375716c61082401023231002000010604786d21627d61082102023411064000010704786d226f646971082202014461034000010704786
d236c657261082201005231047000010604786d2c656761082102023461054000010704786d2c65676261082102023461074000010704727d226f646972082b0
5023231049200010704727d2073747e62082201023231089600010704727d227f646232082501023231081700010804727d237b69627472082b0102323104150
0010804727d237d6f6b6561031101023233006000016000026000010904727d277865656c6372082b020232310495000308036d24616e6365623880010200000
b06000000000000046004044009060000046005000305096e64727f669231090000090b100004600402990b0c100000000000046004068b090d10000460040ed
d090e10000460040a22190f10000460040a6819002000046004025c190120000460040a302902200004600402d82903200004600400020701313d24786f67629
9010400000f013960041008c008c0000004600c08e30a09100410028000000c0c6702091004100c0e97020960041008030c4403047874770c0008000a5314786
f67602265602478696e6b696e676e2e2e2aa5030478747702000e00087f17786164702963702d6f64772370216e696d6164796f6e6023797374756d6f30d7030
478747700100c30087819672d60237f60276c616460297f657021637b65646e2e2e220801323d2479647c6564f1040400000b0c20000000000004600c0690040
46004600c0aa004046004600c00a004069006900c0200000b0920000000000004600009b00a01000dcff00004b0040200000b0920000000000004600002d00a0
0dff32000000aa0040200000b0920000000000004600000f00a01300e0000000cd0040308c003037668720201e00303766872030af0030376687204020701333
d246563736852030600000b0d06fff6dff000046008014004023002300c055004087008700c096004046004600c02c10206fff6dffc0fe10206aff6dffc06000
00b0a081006dff000046008037004023002300c078004087008700c0b9004046004600c02c102081006dffc0fe102025006dffc070000090900000460080be00
600000d00082008200c0ff004046004600c031104055004600c02c104055004600c0bd104055005000c0fe1040a000500080400000304787477041004100ff40
96370216fa00304787477086004100ff3066f6270c00602756c6478747704fff8effff60079636f6d2832c103036c6270020602313d2375617c44030600000f0
606dff22008c008c000000000000af0000407710206dff2200404f10b0910000e10000006900c02530200000e100c010402000000600c0400000f06011002000
8c008c00a0000000003110004077102011002000404f10200000e10000400000f0607200a2008c008c006400000000c21000407710207200a200404f10200000
e10000601100602756c6478747703dff8dffff613756175756e636560237072796475602662716d6563771203036c627008520602756c6478747708dff8dffff
31c6f6f6b696e6760276f6f6460226279616e612ed303036c627004f1030d657372050744030d657370020702323d236f6d62604601040c210d0038c008c0000
00460050000000004f10b013a000320000004600d08750200500320080400000602756c6478747700cff8dffff0236f6d62696e65602370727964756370266f6
2702d6f627560236f6d607c656874600602756c647874770ceff2effffa016e696d6164796f6e63762203036c627008e30602756c6478747702fff8effc32147
86f67602665656c6027756962746e2e2e220502333d226768e3020500000b042080000000000460080fa002008000000c01e002000000000c048302000000000
c06b302008ff000080400000901300004600909e00a06eff800000004600d00320a05fff8000c8000000d048300090300000602756c6478747704cffecffa5d1
573756024796c65602d61607370266f62702261636b67627f657e646372c10602756c647874770cdff7effc3d0b6e6f636b602b6e6f636b6e2e2e920602756c6
478747706fffecff6421775672275602e6f6470216470286f6d656e220802343d236f6d626238e3010508c0090530000460040c710804b000000408520804b00
4600404920b0934100000000004600c08e302029ff0000c0200000602756c647874770ecff4cffa591f6270247f602d616b65602c61627765627023707279647
56374f10602756c647874770ecff4cff46a17786963686023616e60216c637f60226560236f6d62696e6564620803313d2373656e656898010200000b0d20000
000000000000808c008000004600c0400000602756c6478747704cff4cff87c1478656e60236f6d62696e6560296470216c6c60247f676564786562746006027
56c6478747708dffecff873147f60236275616475602365747373656e65637c21030d657372000338030d657370020604313d2f657474c9010300000b0b20000
000000004600c080704046004600c0c67040460000008000209026d236163747c656238e3030100000b0400000000000004600c0100000b02000000000000046
0080100000b0100000000000004600c000208026d24727565637238e3020100000b0500000000000004600c0100000b0300000510000004600c000208026d247
27565637668c0030100000b0400000000000004600c0100000b02000001eff00004600c0100000b0720000000000004600c000208026d24727565637c68c0020
200000b0520000000000004600c08c002008000000c0200000b05208ff000000004600c08c002000000000c000206036d24786f6768c0010100000a000000000
00004600c000208007d237071627b6238c0010400000f07000000000a000a00000004600c0e1004046004600c08c0040a000a00080e6004046004600c0002080
37d236163747c6568e3020100000b0420000000000004600c0200000b0134eff800023004600d0c210a00fff800069000000d0107710602756c6478747708dff
4effc3d04786f6760236f6d6560296e6f3205037d2f657470d7040200000b0c20000000000004600c0c21080c2100000c0204b00b09329ffe10000004600d031
10200bffe100d0301e00b0137500410000006900c0a820a093004100c3000000c00000008020c800b091ceff4eff00004600c00000008000207037d2479647c6
564f1030404100f0b00000cdff4600460000004600c0000060000007ff09100910c0e510200000cdffc0c710200800cdff80502300f080000000000910091000
004600c00000008064004046004600c027102000000000c009102008ff000080504600f0c0000009000910091000004600c08700600000420046004600c00000
008068102000004200c04a1020080042008030910030376687201064003037668720108700303766872010207037d247271696e60d7020100000b06200000000
00004600c0400000b043e6006fff00004600c0852020a0006fffc00b4020a0006fffc0c67020e2ff6fffc010dd20602756c6478747708dff8dffc3a147869637
02373656e65602d616b65602e6f6023756e63756e2e220a04786d21627d636c65726460020100000f001efffb0007800460000004600c0100000b0e000000000
00004600c00020704786d226964737091040700000b0211000000000004600c023002030000000c04600201000ffffc0690020ffff0000c08c002010000000c0
e010200100b000c0e5100080700000b0f000008fff00004600c02300200000afffc046002000008fffc06900200000afffc08c002000008fffc0e0102090004f
ffc045100080700000b011ffffffff00004600c0230020dfff0000c0760020ffff0000c069002010000000c08c0020ffffffffc0e01020cfffd000c027100080
700000b0e20000feff00004600c0f3002010001fffc01700200000feffc00a0020ffff1fffc08c00200000feffc0e01020deff7effc0c71000c0202300303766
872000690030376687200020704786d2d616b6568c0010100000b0f2000000000910c9ff400020704786d27716c6b68c0010100000b0f20000000000004600c0
0020704727d226964737e51060200000b0830eff6eff00004600c046000080400000b0330000bfff00004600c04600200000bfffc00a00a0feffaeff00000000
c0c2100080400000b0610000310000004600c046002000003100c00a0020e1009000c0af000080400000b0810000510000004600c046002000005100c00a0020
9000c100c031100080700000f051510031006500460000004600c023002051009100c091002011006100c0b4002081006100c046002051003100c00a0020b200
d200c01e000080700000b0510fff910000004600c02300200fff3100c09100203fff6100c0b40020deff6100c04600200fff9100c00a0020ddff8200c08c0000
800020804727d226f6469723410010200000b0310000000000004600c0a0002000001000c00020704727d2c6f6e6768e3060100000b0134200a0000000000040
100000b0930000000000004600c0100000b063b500510000004600c0100000b0915400a00000004600c0100000b0914500a00041004600c0100000b0915600a0
00a0004600c00020704727d2d616b6560f0010100000b023000000004510c9ff400020904727d207c6476627d68e3020100000b06100009fff00004600c01000
00b0810000000000004600c00020904727d237d6f6b65623460010200000b0710000000000004600404600200000beff400020904727d237d6f6b65633460040
100000b0730000000000004600c0100000b07300000000e1004600c0100000b07300000000c3004600c0100000b0730000000005004600c00020804727d24727
1696e6460010100000b0230000000000004600c000e6460010100000b0330000000000004600c00000c000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
04090600040506001709080b0c04050800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
14141400140014000014001b1c24050600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1414140014001400001400000000001400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1919190024052500001900000017052500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000004800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000004800004800004c64646500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
040604060a0409060017090804060406040800004a4b4b4b4b4b4b5800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
14141414141414140406140a14141414240600005a5b5b5b5b5b5b5800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07181414141414140718141414141414001400006a6b6b6b6b6b6b5c4d4d4e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
19191919191919191919191924251919172500007a7b7b7b7b7b7b6c6d6d6e00000003000000000303000003000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000636464646464646464646500000013000000001313000013000013000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04080a000a0408170908040508040906000000006869686900686968696869002a2b2b2a2a2a2b2a2a2a2a2a2b2a2a2a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
24062409252406001400070800141414000000007879787900787978797879003a3a3a3a3a3a3a3a3a3a3b3a3a3a3a3a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0014001400001400140014000014141400000000000000007c7e0000000000003a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
17250019001725001900240508191919000000000000000071717171710000003a3a3a3b3a3a3a3a3a3a3a3a3a3b3a3a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e000000000000000000000000000000003a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e00000000000000000000000000000000707170717071707170717071707170710000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e000000000000000000004f6f6f6f6f6f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e000000000000000000005f66677f6667000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e000000000000000000005f76777f7677000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0000000000000000000f5f7f7f7f7f7f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0000000000000000001f5f7f7f7f7f7f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0000000000000000001f5f7f7f7f7f7f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0000292b2a2a2b2c00292b2a2b2a2a2a000000002627373800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0000393a3a3a3a2d2e2f3a3a3a3a3a3a000026271616161637382627283738000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d0000393a3a3a3a2d0d2f3a3a3a3a3a3a262716161616161616161616161616370000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d0000393a3a3a3b2d0d2f3a3a3a3a3a3a161616161616161616161616161616160000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d0000393a3a3a3a3d3e3f3a3a3b3a3a3a161616161616161616161616161616160000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d2a2a3a3a3a3a3a3a3a3a3a3a3a3a3a3a161616161616161616161616161616160000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d3a3a3a3b3a3a3a3a3a3a3a3a3a3a3a3a161616161616161616161616161616160000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
011000000c0530c200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011400000e15300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003
011000002b52500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000002652500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000002852500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000905000000150500000009050000001505000000090500000015050000000905000000150500000009050000001505000000090500000015050000000905000000150500000009050000001505000000
0110000000000000001d0530000000000000001d0530000000000000001d0530000000000000001d0530000000000000001d0530000000000000001d0530000000000000001d0530000000000000001d05300000
0110000000000000001c5200000000000000001c5201d5201f520000001d5200000000000000001f520000001c5201c5201c5201c5201c5201c5201c5201c5200000000000000000000000000000000000000000
011000000705000000130500000007050000001305000000070500000013050000000705000000130500000005050000001105000000050500000011050000000405000000100500000004050000001005000000
01100000000000000000000000001a5251a5251a5251a5251a52000000185200000000000000001a5200000018520185251752000000175200000015520000001752017520175201752000000000000000000000
001000001052010520105201052010520000000e520000000952009520095200952009520000000000000000000000000010520000000e52000000135201052000000105200e5200000009520095200952009520
001000001552300000000000000015523000000000000000155230000000000000001552300000000000000015523000000000000000155230000000000000001552300000000000000015523000000000000000
011000000c5200c5200c5200c5200c520000000c5250c5250c5200c5200c5200c5200c520000000c5250c5250c5200c5200c5200c5200c5200c5200c5200c5200c5100c5100c5100c5100c510000000000000000
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
01 05 06 07 44
00 08 06 09 44
00 05 06 07 44
02 08 06 09 44
00 0a 0b 43 44
00 0a 0b 43 44
00 0c 0b 43 44
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
