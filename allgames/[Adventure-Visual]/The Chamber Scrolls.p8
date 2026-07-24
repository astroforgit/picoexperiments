pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
--  the chamber scrolls
--  copyright (c) 2016 sam hocevar <sam@hocevar.net>
image_width, image_height =600,252
facts = {}
big_data = {}
rom = {
[0]=
0x9aed.9c78, 0x451d.684f, 0x6f7f.c71c, 0xfba6.f2fb, 0x1e96.de6c, 0xbc35.43d2,
0xc45e.342e, 0xbe96.a9bb, 0xa351.82b6, 0xd0b6.29bd, 0x4a45.50f4, 0x4324.14cd,
0x8b62.c853, 0x5a9a.1ea7, 0x5d07.7850, 0x40f8.7d41, 0xc721.4143, 0x56bd.0b44,
0x636f.68a9, 0x24b9.fed1, 0x7b06.8c4b, 0x666f.e7d8, 0x7979.9b77, 0x16ee.ecfb,
0xcbef.ea54, 0xccec.ec9b, 0xdf9b.f3ef, 0x7676.66fc, 0x7878.010f, 0xa6ed.5bc4,
0xfcee.4cdd, 0x1b6f.ace6, 0xa214.cdbd, 0x81cc.015b, 0x44ee.4ad3, 0x46ab.cda7,
0xd885.2b6f, 0x8bfd.39a8, 0x07e0.6182, 0x0c07.c00f, 0xefbb.b54b, 0x87f0.f2be,
0x31db.6cf3, 0x6fc1.b2df, 0xc6db.41db, 0xefc3.b896, 0x4be9.c3ce, 0xdfe7.c743,
0x745a.ec79, 0xe63f.8337, 0xe636.6c04, 0x4d8d.8045, 0xabc5.60bc, 0x63c3.aada,
0xa9e1.5266, 0x7657.27f7, 0xb5fa.fa1d, 0x2e54.2ee8, 0x0da2.06ee, 0x9598.1d20,
0xd17c.77cc, 0x7d56.4c92, 0x607c.c3c7, 0x9398.0cc7, 0xdaf0.6082, 0x9e37.87d8,
0x87c7.b858, 0x5551.0b70, 0x874a.eef7, 0x4d60.e6d7, 0xaa12.aa3a, 0xf531.368a,
0x2e87.a7fc, 0xecfe.9f6d, 0x865f.832d, 0xca1a.0ea5, 0xa09d.2925, 0x5659.d4b6,
0x54d4.aabc, 0xa7fe.06c7, 0xbf93.2333, 0xc466.fe1f, 0x7519.aa68, 0x4fe8.9719,
0xdf0e.4e8a, 0xd7ea.38b9, 0xbd23.74ee, 0xa6a7.4cbe, 0xf272.be9e, 0xcc2f.cbd1,
0x7dd3.ed9f, 0xbb3e.dd5f, 0xef89.e6e7, 0xdb31.1d77, 0x6063.e14e, 0xe836.03f7,
0x67f3.23e0, 0xe2fe.9f1e, 0x73e9.a33b, 0x9bae.7201, 0xa73b.6a17, 0xf8ea.fcea,
0x7602.470f, 0x5346.34da, 0x2d23.cdd9, 0x476f.f9d2, 0xd5f1.de3f, 0x5b9f.978b,
0x65b4.096f, 0x1bf9.26d7, 0xf8c9.fabe, 0x7bde.a78f, 0x16f5.e7f2, 0x715a.f5e9,
0xd14a.a3a1, 0x3cdd.2f2f, 0xabeb.fc3a, 0x99a6.8ce7, 0x09be.cb14, 0x8ec2.f378,
0x2f0f.77f9, 0xd7a1.9d98, 0xdf97.da6b, 0x97ed.e572, 0x5726.4657, 0x53d0.b6cd,
0x9bb4.300f, 0xf570.3020, 0x48bc.4704, 0xcf6f.c399, 0xbc1d.9f5c, 0x86f7.717e,
0x6699.10e1, 0x911c.da5f, 0xe6a6.c840, 0x6352.1255, 0x4350.9148, 0x1e18.4282,
0x3c44.1f04, 0xe795.9e03, 0x6a8c.bd4d, 0x968d.98d2, 0x67df.c51d, 0xd02b.750f,
0x7c26.4b7c, 0xca35.6088, 0x7a07.265f, 0x9e25.a1eb, 0xe105.5565, 0xe28a.d1a1,
0x97f3.4c87, 0x5af8.1b1d, 0x3047.420d, 0x63c4.7fcd, 0x0323.a55e, 0x508e.c32f,
0xe1e8.7b8f, 0x076b.a98a, 0x6ac3.1ff7, 0xdbfd.fada, 0x9bae.bbaa, 0x0388.ab14,
0x8452.92e4, 0x5270.38e7, 0xd90c.f10a, 0x45e2.14b8, 0x4b88.9ddd, 0x3042.7e11,
0x78c5.2937, 0x053a.bf51, 0xf8c5.2aae, 0x5130.2a37, 0xc229.5577, 0xe062.9d5f,
0xc989.db6e, 0x8ebf.c82b, 0xa0bb.d789, 0x5f10.b3b4, 0x435b.aa99, 0xfdf5.7147,
0x3ebe.217a, 0x9db0.e751, 0xf331.e515, 0x8500.be15, 0x20dc.4c79, 0x8ac8.381f,
0x7a3d.5fce, 0x0ac7.2bd6, 0x7a55.dfcf, 0x2aa7.fc80, 0xa002.6bf3, 0x4426.bdf7,
0xaf8e.739e, 0x95d3.eb1b, 0x3d96.5bab, 0x259e.1c00, 0x5c28.548e, 0x9efc.c8bb,
0xaf11.f652, 0x9a33.c486, 0xe766.7573, 0x009c.59e0, 0x4be9.df16, 0x1098.1e76,
0x6304.cf31, 0xe5f4.abc8, 0x801c.45e0, 0x64c4.3d9e, 0xc6b1.3e0e, 0x73cc.4598,
0xb9d7.8f91, 0x1fce.3cd3, 0x6bff.d7f3, 0x2c00.5fb1, 0x371c.7d5a, 0x1f27.391e,
0x395e.192f, 0xf1f2.00e8, 0x1d0a.0f7a, 0xe7a1.d707, 0xd0d4.0079, 0x1108.cf7a,
0xffb5.c8b9, 0xbe1b.1923, 0x7fc2.47d8, 0x4482.c3ef, 0x2448.9122, 0x2244.8912,
0x1224.4891, 0x9122.4489, 0x8912.2448, 0x4891.2244, 0x1fe9.1224, 0xfedf.6952,
0x71ff.8d03, 0x6dad.56d9, 0xaed9.b2de, 0x4aac.540c, 0x0ca0.cca9, 0xb160.9416,
0x409c.ca54, 0x59fb.3180, 0x8fa3.61bb, 0xd512.a972, 0xd031.ac1b, 0x3c6b.d4d8,
0xe96f.fe96, 0x2b43.4b7b, 0xaad6.1fd6, 0xa579.67f5, 0x2a5e.5cbc, 0x845a.cd63,
0x990b.5cc5, 0xb68f.b8c7, 0x41f2.0f92, 0xf907.c83e, 0x83e4.1f20, 0xf20f.907c,
0x07c8.3e41, 0xe41f.20f9, 0xf1f4.61e3, 0xa085.9517, 0x.0035,
}
obj = {
  { "painting", 1, false, { }, { }, { }, { { 26, 95, 53, 139 }, { 53, 101, 75, 139} },
    "you look at the painting.\na beautiful painting with\na lot of emotions in it.\nyou can almost smell the\npixels." },
  { "painting", 1, false, { }, { }, { }, { { 209, 112, 228, 129 } },
    "you look at the painting.\nan impressive painting. it\nmust be very expensive.\nit must also be very\npretentious." },
  { "painting", 1, false, { }, { }, { }, { { 422, 115, 455, 137 } },
    "you look at the painting.\nit's ugly. you cannot\nunderstand why people\nbuy these things." },
  { "painting", 1, false, { }, { }, { }, { { 258, 88, 306, 126 } },
    "you look at the painting.\nthere are a lot of such\npaintings in the room." },
  { "painting", 1, false, { }, { }, { }, { { 520, 104, 544, 128 } },
    "why do people buy\npaintings? clearly\nvideo games are a\nlot better. ever seen\na 60 fps painting?" },
  { "flowers",  1, true,  { }, { 3 }, { 3 }, { { 99, 146, 118, 166 } },
    "there was a crowbar hidden\nin the flower pot!\nseriously, what are the\nodds?" },
  { "flowers",  1, false, { 3 }, { }, { }, { { 99, 146, 118, 166 } },
    "these flowers do not\nlook healthy. hard to\ntell in this resolution," },
  { "painting", 1, true,  { }, { 1 }, { 1 }, { { 107, 128, 114, 133 } },
    "you look at the painting.\n\nthere was a safe hidden\nbehind it!\n\nclassic point-n-click\nmechanism, but damn\neffective!" },
  { "safe",     1, false, { 1 }, { 7 }, { }, { { 107, 128, 114, 133 } },
    "the safe is closed.\nyou need the combination." },
  { "open",     2, true, { 7 }, { 2 }, { 2 }, { { 107, 128, 114, 133 } },
    "congratulations! you\nopened the safe and the\ngrand secret will be\nrevealed to you.\n\nthere are no scrolls, the\nscrolls are a lie. the\ngame is called the\nchamber scrolls because\nthe chamber... scrolls." },
  { "painting", 1, true,  { 2 }, { }, { }, { { 107, 128, 114, 133 } },
    "another boring painting." },
  { "pillow",  1, true, { }, { 5 }, { 5 }, { { 51,159,70,176 } }, "you found the key behind\nthe pillow. you're pretty\nsmart it seems!" },
  { "pillow",  1, false, { 5 }, { }, { }, { { 51,159,70,176 } }, "this pillow seems comfy." },
  { "drawer",  1, false, { }, { }, { }, { { 245,146,314,158 } }, "a drawer. it is locked." },
  { "drawer",  1, false, { }, { }, { }, { { 245,158,314,172 } }, "a drawer. it is locked." },
  { "drawer",  1, false, { }, { 3 }, { }, { { 245,172,314,184 } }, "a drawer. it is locked." },
  { "drawer",  1, false, { }, { }, { }, { { 245,184,314,196 } }, "a drawer. it is locked." },
  { "crack open", 2, true,  { 3 }, { 4 }, { 4 }, { { 245,172,314,184 } },
    "you crack the drawer open\nand find a plastic chicken\nwith a pulley. what a\nweird object." },
  { "drawer",  1, false, { 4 }, { }, { }, { { 245,172,314,184 } },
    "a drawer. it was cracked\nopen by a vandal." },
  { "lamp", 1, false, { }, { 6 }, { }, { { 441, 100, 452, 106 }, { 130, 90, 144, 98 } },
    "why are the lights on during\ndaylight? clearly i should\nhave downloaded another\nstock photo on google\nimages." },
  { "use plates", 2, true,  { 6 }, { 7 }, { 7 }, { { 441, 100, 452, 106 }, { 130, 90, 144, 98 } },
    "the photographic plates\nwere hiding the secret\nsafe combination! kudos to\nscience once again!" },
  { "lamp", 1, false, { 7 }, { }, { }, { { 441, 100, 452, 106 }, { 130, 90, 144, 98 } },
    "why are the lights on during\ndaylight? clearly i should\nhave downloaded another\nstock photo on google\nimages." },
  { "look", 1, false, { }, { }, { }, { { 130,118,162,152 }, { 389,114, 402,154 } }, "the weather is beautiful.\nvideo games are too." },
  { "chest", 1, false, { }, { 5 }, { }, { { 503,177, 514,189 } }, "this chest's lock requires\na key of some sort." },
  { "open",  2, true,  { 5 }, { 6 }, { 6 }, { { 503,177, 514,189 } }, "you find old photographic\nplates in the chest.\nwhat could they be good for?" },
  { "chest", 1, false, { 6 }, { }, { }, { { 503,177, 514,189 } }, "the chest is open but there\nis no longer anything\ninteresting in there." },
  { "go outside", 2, false, { }, { }, { }, { { 493,123, 501,156 } }, "why go outside? this isn't\nan escape game." },
}
function u32_to_memory(address,size,data)
  for i=0,size/4-1 do
    poke4(address+i*4,data[i])
  end
end
local reverse = {}
local function bs_init(addr)
  local bs = {
    pos = addr,
    b = 0,
    n = 0,
    out = {},
    outpos = 0,
  }
  function bs:flushb(n)
    self.n -= n
    self.b = shr(self.b,n)
  end
  function bs:getb(n)
    while self.n < n do
      self.b += shr(peek(self.pos),16-self.n)
      self.pos += 1
      self.n += 8
    end
    local ret = shl(band(self.b,shl(0x.0001,n)-0x.0001),16)
    self.n -= n
    self.b = shr(self.b,n)
    return ret
  end
  function bs:getv(hufftable,n)
    while self.n < n do
      self.b += shr(peek(self.pos),16-self.n)
      self.pos += 1
      self.n += 8
    end
    local h = reverse[shl(band(self.b,0x.00ff),16)]
    local l = reverse[shl(band(self.b,0x.ff),8)]
    local v = band(shr(shl(h,8)+l,16-n),2^n-1)
    local e = hufftable[v]
    local len = band(e,15)
    local ret = flr(shr(e,4))
    self.n -= len
    self.b = shr(self.b,len)
    return ret
  end
  function bs:write(n)
    local d = band(self.outpos, 0.75)
    local off = flr(self.outpos)
    if d==0 then
      n=shr(n,16)
    else
      if d==0.25 then
        n=shr(n,8)
      elseif d==0.75 then
        n=shl(n,8)
      end
      n+=self.out[off]
    end
    self.out[off] = n
    self.outpos += 0.25
  end
  function bs:readback(off)
    local d = band(self.outpos + off * 0.25, 0.75)
    local n = self.out[flr(self.outpos + off * 0.25)]
    if d==0 then
      n=shl(n,16)
    elseif d==0.25 then
      n=shl(n,8)
    elseif d==0.75 then
      n=shr(n,8)
    end
    return band(n,0xff)
  end
  return bs
end
local bl_count = {}
local next_code = {}
local function hufftable_create(table,depths,nvalues)
  local nbits = 1
  for i=0,16 do
    bl_count[i] = 0
  end
  for i=1,nvalues do
    local d = depths[i]
    if d > nbits then
      nbits = d
    end
    bl_count[d] += 1
  end
  local code = 0
  bl_count[0] = 0
  for i=1,nbits do
    code = (code + bl_count[i-1]) * 2
    next_code[i] = code
  end
  for i=1,nvalues do
    local len = depths[i] or 0
    if len > 0 then
      local e = (i-1)*16 + len
      local code = next_code[len]
      next_code[len] = next_code[len] + 1
      local code0 = code * 2^(nbits-len)
      local code1 = (code+1) * 2^(nbits-len)
      for j=code0,code1-1 do
        table[j] = e
      end
    end
  end
  return nbits
end
local littable = {}
local disttable = {}
local function inflate_block_loop(bs,nlit,ndist)
  local lit
  repeat
    lit = bs:getv(littable,nlit)
    if lit < 256 then
      bs:write(lit)
    elseif lit > 256 then
      local nbits = 0
      local size = 3
      local dist = 1
      if lit < 265 then
        size += lit - 257
      elseif lit < 285 then
        nbits = flr(shr(lit-261,2))
        size += shl(band(lit-261,3)+4,nbits)
      else
        size = 258
      end
      if nbits > 0 then
        size += bs:getb(nbits)
      end
      local v = bs:getv(disttable,ndist)
      if v < 4 then
        dist += v
      else
        nbits = flr(shr(v-2,1))
        dist += shl(band(v,1)+2,nbits)
        dist += bs:getb(nbits)
      end
      for n = 1,size do
        bs:write(bs:readback(-dist))
      end
    end
  until lit == 256
end
local order = { 17, 18, 19, 1, 9, 8, 10, 7, 11, 6, 12, 5, 13, 4, 14, 3, 15, 2, 16 }
local depths = {}
local lengthtable = {}
local litdepths = {}
local distdepths = {}
local function inflate_block_dynamic(bs)
  local hlit = 257 + bs:getb(5)
  local hdist = 1 + bs:getb(5)
  local hclen = 4 + bs:getb(4)
  for i=1,hclen do
    local v = bs:getb(3)
    depths[order[i]] = v
  end
  for i=hclen+1,19 do
    depths[order[i]] = 0
  end
  local nlen = hufftable_create(lengthtable,depths,19)
  local i=1
  while i<=hlit+hdist do
    local v = bs:getv(lengthtable,nlen)
    if v < 16 then
      depths[i] = v
      i += 1
    elseif v < 19 then
      local nbt = {2,3,7}
      local nb = nbt[v-15]
      local c = 0
      local n = 3 + bs:getb(nb)
      if v == 16 then
        c = depths[i-1]
      elseif v == 18 then
        n += 8
      end
      for j=1,n do
        depths[i] = c
        i += 1
      end
    end
  end
  for i=1,hlit do litdepths[i] = depths[i] end
  local nlit = hufftable_create(littable,litdepths,hlit)
  for i=1,hdist do distdepths[i] = depths[i+hlit] end
  local ndist = hufftable_create(disttable,distdepths,hdist)
  inflate_block_loop(bs,nlit,ndist,littable,disttable)
end
local stcnt = { 144, 112, 24, 8 }
local stdpt = { 8, 9, 7, 8 }
local function inflate_block_static(bs)
  local k = 1
  for i=1,4 do
    local d = stdpt[i]
    for j=1,stcnt[i] do
      depths[k] = d
    end
  end
  local nlit = hufftable_create(littable,depths,288)
  for i=1,32 do
    depths[i] = 5
  end
  local ndist = hufftable_create(disttable,depths,32)
  inflate_block_loop(bs,nlit,ndist,littable,disttable)
end
local function inflate_block_uncompressed(bs)
  bs:flushb(band(bs.n,7))
  local len = bs:getb(16)
  local nlen = bs:getb(16)
  for i=0,len-1 do
    bs:write(peek(bs.pos+i))
  end
  bs.pos += len
end
local function inflate_main(bs)
  bs.pos += 2
  repeat
    local block
    last = bs:getb(1)
    type = bs:getb(2)
    if type == 0 then
      inflate_block_uncompressed(bs)
    elseif type == 1 then
      inflate_block_static(bs)
    elseif type == 2 then
      inflate_block_dynamic(bs)
    end
  until last == 1
  bs:flushb(band(bs.n,7))
  return bs.out
end
function inflate(inaddr)
  return inflate_main(bs_init(inaddr))
end
function blit_bigpic(lines, dst, dstwidth, src, srcwidth, xoff, yoff)
  local data = src[1 - xoff % 2]
  xoff = band(xoff,0xfffe)
  srcwidth /= 8
  dstwidth /= 2
  local dx = band(xoff,7)
  local xoff = flr(xoff/8)
  local srcoff = yoff * srcwidth + xoff
  local w1 = min(max(0, srcwidth - xoff - 1), dstwidth / 4)
  local w2 = dstwidth / 4
  tmp_mem = 0x5e00 + shr(dx,1)
  for line = 0,lines-1 do
    local off = srcoff + srcwidth * line
    for j = 0,w1    do poke4(0x5e00+j*4,data[off + j]) end
    off -= srcwidth
    for j = w1+1,w2 do poke4(0x5e00+j*4,data[off + j]) end
    memcpy(dst + dstwidth * line, tmp_mem, dstwidth)
  end
end
strlen = {}
function _init()
  cls()
  for i=0,255 do
    local k=0
    for j=0,7 do
      if band(i,shl(1,j)) != 0 then
        k += shl(1,7-j)
      end
    end
    reverse[i] = k
  end
  local s = "\151"
  for i=1,#s do strlen[sub(s,i,i)] = true end
    big_data = { [0] = inflate(0x0), {} }
    u32_to_memory(0x0, band(4*#rom+0xff,0x7f00), rom)
    rom = inflate(0x0)
    u32_to_memory(0x0, band(4*#rom+0xff,0x7f00), rom)
  music(0,0,1)
  for n=0,#big_data[0]-1 do
    local off = n - 1
    if n % (image_width / 8) == 0 then off += image_width / 8 end
    big_data[1][n] = shl(big_data[0][n],4) + band(shr(big_data[0][off],28),0x.000f)
  end
  for i=0x2000,0x2010,2 do
    poke(i,16) poke(i+1,17) poke(i+0x80,32) poke(i+0x81,33)
  end
  memcpy(0x2100,0x2000,0x100)
  memcpy(0x2200,0x2000,0x200)
  memcpy(0x2400,0x2000,0x400)
end
world_x, world_y = 0, 0
mouse_x, mouse_y = 0, 0
mouse_speed = 0
mouse_type = 0
mouse_shake = 0
fog_t, fog, fog_dir, fog_color = 0.5, 0, 1, 0
state = 0
function _update60()
  rnd()
  fog_t += shr(1,7)
  local new_fog = 8.0 * (1 - cos(min(fog_t%3.0,1.0))) - 0.5
  fog, fog_dir = new_fog, new_fog > fog and 1 or -1
  mouse_info = nil
  mouse_type = 0
  mouse_shake = max(mouse_shake - 0.25, 0)
  local clicked = false
  if not down then
    clicked = btnp(4) or btnp(5)
  end
  down = btn(4) or btn(5)
  if state==0 then
    world_x = (world_x + 0.125) % image_width
    if fog >= 15 then world_x, world_y = rnd(image_width), rnd(image_height) end
    if clicked then
      sfx(2)
      world_x, world_y = 170, 190
      facts = {}
      state = 1
    end
  elseif state==1 then
    if not btn(0) and not btn(1) and not btn(2) and not btn(3) then
      mouse_speed = 0
    end
    if btnp(0) or btnp(1) or btnp(2) or btnp(3) then
      mouse_speed = max(min(mouse_speed + 0.25, 3), 1)
    end
    if btn(0) then world_x -= mouse_speed end
    if btn(1) then world_x += mouse_speed end
    world_x %= image_width
    if world_y - mouse_speed >= 0 and btn(2) then world_y -= mouse_speed end
    if world_y + mouse_speed < image_height and btn(3) then world_y += mouse_speed end
    for k,v in pairs(obj) do
      local context, mouse, important, facts_wanted, facts_notwanted, facts_activated, coords, message = v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8]
      local wanted = true
      for k,v in pairs(facts_wanted) do
        if not facts[v] then wanted = false end
      end
      for k,v in pairs(facts_notwanted) do
        if facts[v] then wanted = false end
      end
      if wanted then
        local inside = false
        for q in all(coords) do
          if (world_x >= q[1] and world_x <= q[3] and world_y >= q[2] and world_y <= q[4]) inside = true
        end
        if inside then
          mouse_type = mouse
          mouse_info = context
          if clicked then
            sfx(2)
            for k,v in pairs(facts_activated) do
              facts[v] = true
            end
            message_info = message
            if important then
              fog_t, fog, fog_dir, fog_color = 0, 0, 1, 3
              state = 2
            else
              state = 5
            end
            break
          end
        end
      end
    end
    if clicked and state==1 then
      mouse_shake = 5
      sfx(0)
    end
  elseif state==2 then
    if fog_t > 0.5 then state = 3 end
  elseif state==3 then
    if clicked then
      sfx(2)
      fog_t, fog, fog_dir, fog_color = 0.5, 16, 1, 3
      state = 4
    end
  elseif state==4 then
    if fog_t > 1 then state = 1 end
  elseif state==5 then
    if clicked then
      sfx(2)
      state = 1
    end
  end
end
function draw_mouse()
  palt(0,false)
  palt(2,true)
  local x = 64 + rnd(mouse_shake)
  local y = mouse_y + rnd(mouse_shake)
  spr(0x40+mouse_type,x, y)
  spr(0x50+mouse_type,x, y+8)
  palt()
  if mouse_info then
    box("\151 "..mouse_info, -1, mouse_y - 20)
  end
end
function title()
  local blit = function(i, j)
    print("    a pico-8 game", 50+i, 85+j, 7)
    print("  by  sam hocevar", 50+i, 93+j, 7)
    print("for ludum dare 37", 50+i,101+j, 7)
    print("press \151 to start", 53+i, 120+j, 7)
    sspr(24, 0, 80, 32, 5+i, j, 118, 80)
  end
  for i=1,15 do pal(i,0) end
  for i=-1,1 do for j=-1,1 do
    blit(i, j)
  end end
  pal()
  blit(0, 0)
end
function box(text, x, y)
  local l=#text
  local w,lw,h = 0,0,1
  for i=1,l do
    local c = sub(text,i,i)
    if(c=="\n") then
      w=max(lw,w) lw=0 h+=1
    elseif(strlen[c]) then
      lw += 2
    else
      lw += 1
    end
  end
  w=max(lw,w)
  if (x<0) x=60-2*w
  if (y<0) y=55-3*h
  rectfill(x,y,x+4*w+6,y+h*6+6,0)
  rect(x+1,y+1,x+4*w+5,y+h*6+5,7)
  print(text, x+4, y+4)
end
function draw_world()
  local lines = 128
  local dst = 0x6000
  local dstwidth = 0x80
  local srcwidth = image_width
  mouse_x, mouse_y = (flr(world_x + rnd(mouse_shake)) + image_width - 64) % image_width, flr((world_y + rnd(mouse_shake)) * 126 / image_height)
  blit_bigpic(lines, dst, dstwidth, big_data, srcwidth, mouse_x, mouse_y)
end
function draw_fog()
  for i=0,15 do pal(i,fog_color) end
  for n=0,15 do
    for i=0,15 do palt(i,(i+n)/2>fog) end
    map(n%2, 0, (7.5 - (7.5-n) * fog_dir) * 8, 0, 1, 16)
  end
  pal()
end
function _draw()
  if state!=3 then
    draw_world()
  else
    cls(fog_color)
  end
  if state==0 then
    draw_fog()
    title()
  elseif state==1 then
    draw_mouse()
  elseif state==2 or state==4 then
    draw_fog()
  elseif state==3 then
    box(message_info, -1, 20)
    box("\151 continue", 72, 111)
  elseif state==5 then
    box(message_info, -1, -1)
    box("\151 continue", 72, 111)
  end
end
__gfx__
87c9dcd9fcf6b194697e94da8d73304d4b9d7330c634e9bd003378eeb910e814900a00a849b59ed3526a6616358e543bbe43aab4716ef58930130ce146f5889b
59befa8dae3510ea5333b063a2bd711a109182cce18de68b10d873edfa887119199c4ad5eaed4759441f74664e72fbfe5cb7f22229f5d75f5dce738bd7d6e1c9
f76f36f6f55e37a3cff6ebb2273d69f1db10d47bfdfcc012165f7da67ef68965e971fff33b2389eba913cafb65b2dc1fd05a8e69fc87bfb253dcbd08599dece7
c725760800874f87b4ce66155a8b1f33f75706ccae7ff32f5abcb0b80c79f4152f89404d24b9f6867adb401c6f30c902873ffdffef7c4453b24925ec4e9d336d
779959bf0214ba006a09aeba0a6b45f5897f96939eae7c2054c92e71994fd6cbcf68d70942335cb669332ca321e9cd2d7f2d9185fdfef74a8412f4becfe0678c
f5d6665f995830cb665c6deec4b98e65cbe34c3554d53cc7e1fd16e5c62f63fb180eaebad4ef8ce648ba99b0b8c39ea5ef15d8ac03ac597b51f300f0235b9686
97ad0ec98485d4d1284306efed631c7e19d7c2c5e9f688b48439427c0d8841cebb92b2cd3a890e70e996ef174c53367bad47fc9b47c5d0fae3605af5f6e77293
eb377f8f3ccdd21da9f70de3cbd093db78c537b2fadcfe50f85b1d9bf95847e780954ed0772d42f88c7b2d358f1c9f667ce8b1911efe63de03c670c35f1caa08
6264fcf88d06216c114bb0e032a76a33d7fa6185d0014ba73614655f043e764eb90dc8ae00095eec4f6d0adaa7f2e26f5f737fc46121b68e8973f1efc637793b
926db955d5cfc5e9f955e67e41a343adbb5a4cffbeeed5d33e3fa29378de6b0fa4d6cdb1801aaf5fa225f9958557a02166537c7e869d2d942aaaa43c765a3bfc
e30c5144cf8c60fd2fb136f359f26d0aa3f3bcb2257a07ba5374ec5535fd0d260d2d2fbbe38c96e38436e0aaefc8b6855e5d1a41a50c63d6d95cce17663318d4
c822a7b6c171545ed59d8fd0dd654af1ca761762ee26b4761e99bf95e544cb19f052397da2875d6fd551a66bd1f5cf5ba3904560c033322dd0d68da169ad8ba7
1e38a425b9e70b36f45f613965c3ae8d4dc2361859f69a137aaadaa26545de8a6c9b967e0de1747411b0165a5ad630da6471f8c9555b31d46b3d045cbfb4149e
bf80b8baa6e9f3a2b292b894b268b6b7a596dbbab3bde065edcedd9fbf80b27defa3d82c8684b2da134cf0a39bda0654b74d8ebf6b516988ac9da5915404b29d
c2daad65c950f770727132d1d3ffaa42ba16830973d73adf04aa2c4acc9317712a73585e1fa294b2e5f6c3f87ffd12ccfc6b220955db45eb64bdab147eaaa860
ed9a13c2fa915bed8a99dc437bcafcb9f197b11610a2b2aa0944c3c486eaca2ba30c86a4d87412444945a7b533f8dbdc9ff639db61a2e0f66a1aa67fe52a5e1c
214476a73a7aa9a06a9158daceaebd6eca27f3e47f7ba76511d55986dc572257ecb59a4f13b6cd5c531c0fde67efab139dcd5f4f543385a31c1fe9b83d2b3c11
766119e3e3f39dcfcec7fadcf17fda77bca9053dea0d5f08b906504bc11980b2f0610a159a2b6beb37562851516d27b8d64f87ee677a6fe7ebdaca8fdf6b0fb5
53e0daae1c963385acba598e52510bec38dc3510c92e99885a90f21391f7e328c893ec6b7651b98f1191cbf4383df88b42f33d1bce8e162ae30591c9ada8a97c
a4bb675650b94e505e44c15eb22367e1ef5b1cfba17ac06707436e91cf71a0fc5abf7e9e1d25a3b4c765aefca48537b05ecdb13e0b3e145427eec4234fe3aec0
804765d5e02bd8868dba23d8a9af68c00c4e52a0d486146b8a52653ca4bbc2b79a2e53fa9d9974b261691192fa0c6ec205a17e4a6b1179b1bc1c044a2edec5c6
ea179e59e3bc337c4c7655d4bae8313d2abc765e71a7539c48451ca5eae8d3870f47d71d15762eb9a72c99aedf632da23ca4c7d552e1ca29f1997c74dc2847b5
079d80cc19288b028ae63a68cf4e5dfa8da9da23870f3ca8d8db14e1121bd0c27d71691659dc0b9e637f24b0f8456eb01d6eea587dac4cf8cf2a4ba410817630
147e318ea296eca4282d09558754b285de977e9ea6ea56db9b09e554e49bf4aa82477546575992fc92d692952642f9a70595690b2b28db59ead43756552ba030
dadb0045114c12e3706a5e56242dfe593ae5f9659fac6964763a3774b63dc11955486d610bcbe00d5b3dfe5136eb522a688b4b243f3b7592cd2ad6d294ba2a20
35f5899709af60859798ae065ae90926cf28e7b63f5c0fdf69315d9023c8c000450ea4d5ff898baa365ae7631ba68d70653ca4c1e94c3654f04beaa9f10a40ba
88ade6ce3b9ae3915f772238695d51d9a3785972d83e580e0f959d6032ca63898432c53f298a6bad95ae7f09898155a75aa36543cf7bd1aaca4d36aa8305036a
51ca636f4baf012adaa045d47f9a5a5b12635a28f9a7d3895ebfe1ca2a9a162101bad123b64cc487937f5e5333173a52b9673e9956d4f57ec9b70126167c2fe3
2bac492edf85431d18cf78f65e8b33e02a994ba90ca0959d8783f46b2fceab1a6f8c27d55ccfc1ba8beae30865d06868ca2da4324976e10e8d807e75a16d384a
9ac89f8751da058a2465f300eaa1f45dc9693ee2392a3e5cd23e0ba49c8adeb5290e0c5b7cb2f3748a9e11b3ba29ffaf1e069a7e47b9b9a3da223bec22a5026c
c1a4721aeae2d43e11d8959fe0d9b3fb08550185df08668562856a5d406519ac272cc3632cb76949b66b7656955393892f95e3ba420bc3f2b4cf06c50cbacf4e
694b28d5975be178dc837f37d5d9d82ba627c2fff4165a3b4a44801ef59e63d1261bd3d2fb9db1e40cde8c588b5a13293379386eab4c1942b52c25f831e2119b
f45212baccf8cbaa9141d4abcc24f9f653faadd8fd692b516ee3c2910a0f2a93e16c947bb028de973bb0f420f758f95e6c49bee0131509454edd963a92c4d845
a5b0b0f0cacfbb2055a11a12a643018b9c56a5e49179b4c3b1b44dcf327629e500f98bd758782b50a7bca2da218515a62d6b0ba82f7e459c7c5a6e1977e94cab
1ed0743d131466b2e6466ced3f19a1344eaea8de51e1baa5d6515ad94d0d2df6f228f81772daa68199fd93055c63826d6dc1cc3d59222555a3f8aeaa2b816e4f
412ba22adc922b46b265e1bd228fc1e17caf7f91fbca069b5d2bae40dfa757c961f9fb5625e5321ad60349e55c910739d1ba2cd3e27b9a885dbaa90ca48e0810
c27a965e4a21b3ebfeed646f192fdc802bdc0b4517463f6b9959fa1a421521b2a295561d27c63585e1e2dfa8471429c89b508d959eaf4388a52ee1aaedc05ffe
a5659ab9ea16bd958d794f937a131753185c7a9ae3fa959e1ed4fe865495e85e6659065659e1aa2989ac0a3e7206ddab645951143aa8435baf3b7edd80651ef9
2488e252f5e8d85fd3660745778c4d13fa665bd172cd2b449d2653caca0d282bde2d2da249fd8f001650f72eeb5a2edc75630d659e2f438e4afdb839712c7d0b
2f4331afa096a6a632dd2d5be7f065c078e9cc84656db4a3f561e76a8d8628b9d9a7d80fae57596806c3539fa7a2a4a5b2a90ca2aa490582baac26882ed3ed64
7ee1846c7b08a3c596d192523929eaa4a63f9196c89e625659590636a596087431d504c9551b14651100e179699d6a7215555a945f9a41ea14e9fba22426effd
568bb116977a754919598660ab2df11bdcea834506454b57a52b97cba413b6de0159d327212727d0a2b2ac79c9e0b636b9f258850d65444a5870f2fe5b8a7765
1aff120348884c3cf6b6bc39e3c5e98555d7211355561e33959c599c986a696177455b7893de68d2158fd3656bffd0fdfb995986585f33e222dd7a0e2f16199d
69169b39843209a4627c054bbe2ffc6a2c1dbbea30a378e5fa772efb343b251ecbd0dfa13ba2927ad98ab28cdd786f608fe925c8f1d0b1c765e50ce10d1bff97
2daa0855e30522f2344823f2208559ca2da0f75d0055adf6d9426b9f6fcbcd922f722b48086ab1575959c603b23eaa2654bb056d763688a8371c35e92ee249d1
a4ce6e9913c56eae8436329a4c28aafd86762df26626fb1dbed56c0ac8f857b51ca2ce7d47c0359cac850e32817fb9bd9b9a9279d0221cdaf243fa1d55ca8f15
b7a729533254bfae814b19b731451ba05355a8b12430c0fc1ce98ae6a407e527b04b9fcd92be027f0f8bf36e1dee13eb95140e9177e42ccbda90d251aa26e585
59134c7f39a7afaa9e89a84d75141105a2ce1f022318abe90cac2938aa925ce7ca2d4161b6428332c56d337cf537af51e5d46d2a40e05e0a4df033b804c5e3a7
f4a511bb0ea4c57e4a36633e851bdc16857238638de52f0fa8554495b9b446145b39d159c9d0cd7a199e4ecb1ef937e7255f0618126a5de5bc31495a6e97215c
48f404fea2946a8b9a859173f871836fcde2b69ed940cace12c913755c12270575a16415577aae446ee637ca66ef39afc9388d4b6855aaf3688a4454824a256d
1e5bfbdb32dac0de9b78dbcc8d68759b3654e0ef0ba7edd0e10ae0656e1ba483c9a81ba82ca9bf6a39676ae7095193ca304e4f5927c5aab782e6f96941e3b0ae
da5f5a2f60f56540be43f68caac0bcbc98d745c626337cace6e3b2d0c8fc4cee5b8295f4593d2f575e3f15d4f463182657180c1f16ea955b9561510bc36552c5
e051aababafe46d3717b43374a468bf34969234c3d61a9e9eec0b4ca2cdcaec282559c740f1b9752b644a44c558e587744b6a7a789651bac4d1caccb23f15574
3a210328a6637184566537576d0ed4c938773ab7a859f725e598647d9ac6b6da3ba6e4a283d016554a2ca2dc22b5c16524fca3bfb493042fe02377ff4415e855
cd019c0521f60611e88e49517fce92df55519028ad6b72512bacd2ba6c6682f4766575997aa2b64737f0896c55634c0069ad25f6df75957516e73673f264051d
1bf0303ceb9b5fba598a895d8f4493e98203b9b7a7ca21d8ac98ac33b3fc4fcbd6e15655233c25495189d979e166eb908bf05b2b878bf588faccdab380079d96
55805d0ba4632c27a52bd67fb3049bcde2840f76f65e1aaba6175724651a2b2c08d3392935ce217c94dcd571c37f859bf2ee0f48541937adecc18a620b0b5eaf
3372a77e46479708a2aaba959155a52334f059ec295515c2e307a2bba880922ce47b22f00513ca3d2a07dfe8cf4eefab2959a3313aaa9ade8c360bae6b9fc3a1
a960aca4206599be98a88c01a87d4e0c35932590d7d99ce9dde150de8cbc0b0855f6aecbf8ed217a3391bec085924537904a04f2d40490ba95c1693fb06dbcb3
c5e42463282db9d71ad9486f78155ad19296b09a657ff9b4227d79bd1bae877af2c8c27a433f537ed62aaa0cd45348510eacb60698132da05ba07d024a8d7aa6
05cdbe5f43227b5fe19645292950ca6c549a56ab39bc4f8b459747a20f559737bfb916fe237f2a3593d2831dac1444a9da9ff49a35451a8556676cb508a43b29
147b317b5f2b02dfa23a26651b69561f1e67deca215de1685bd82b06d510fcced0575553c8f42ba772b88136eb10f398db379cd7b5b0cd3624e4657bc76559ab
a884e3a35288baec165612c0aaa9a7ba91fd31a8fdfad1614a4717859c53dc92777f392f859a6ad94a11656e481bcb78df5c92d64ab87411651aea654b3ae454
3da6635ea351ba854e95fca21c581949f6b265510bef4fe075d289beb1919549685445529fc7fa3c132976947be6d32fbf992ac9fe7123f946bc9b560d229b47
6d1263564a955a231659faaa2b2c81a84958541243bfba2db1b48a06fac1d722b2ffbdfca74ca6e63aeb959d1611ba9f62651f790a18969955361513b2b7e93f
80badb0f894c5e3f75ba3d4dbbd42983b2cdb54d759d66a1a4f02425a959e0af4535d9eaed34856b065978abad6d601bbca67f89690ca89bcaca47ddc6f38a3a
e14459600a27bcaa3f020951e811c327d3874fc80951d7fac4d5f2d1bdc93bacfd3d005bfb28e98826c1d268c23d7646ef33d3897d648812b756a8de85ca0216
2b3657070453618d309fb2797a69f4a0e3ab2baaf8239a8d2445d836aa29eae4915570746027feb37251c26c4e5da32d5153b302811304e1832868a2d5d3a1bd
c4a29e93658d43a2b29ab0b335efa6b31658903f6517597ca0733d2fe182be4290485898d7889c2b297a6ce59ae3cab28d146b995d5575c60b7e1b2b25a849db
13660591e780b0704176feed59869f8ae30855f82e147151e433f227052a9ca6951d8af59959e800662efa6f6ad9e9b399e559eace931b3c7805c492e5de3837
aff758d2d257cc161c8fd7959c1fc0cae2856c4bbad284c80571f021c8d3dbad595a6dee681c2ccd950ec4855a6fc2f4b7655df8cb8d0b46382ca237de27ca23
bcae339fa49b0a4c715659bf7beb9d8ca42d23ccdf985d944691058548955ac0a860cb8851952469561565c209e99e17bdd377e92589974e9727f4658eda095d
389a385d9e8e6b1663afe085117254b0c80228a0d30d3ad28516736ca92ac3d07cec37f56590f0788b928516944de847566b5656775ccaad96755cc04e7e3eab
2d1df89791475d935b0bab8f9781cdfea85fff9c09a63f590285c7b41d2bbb2ccdae43b6089485d45c3605affb77209da5b5b750125192a8e8d2f0e1a7e23ba9
bb87143baea8824c49addea7f75933ba9a0c24165b9b7d15a36af54c036eda877e363f2ee676b365d3ee00b7c658d5e60450c21e3ba0555546ec3db6fce61593
f118ca0169de25c36559ab2ee6b5623403888d8a70f5ca41a767f78209e809203fec65aba91bcf7f8d7602bae6bd9eaa0a9cbf20a2238ece7b033435c0f9fc34
6564e1dd69b23fd98265556389b66595d3a2bdacc468408a913f28d52e967e060d2a475cfbb0cd60654e969cbab1c40ca02dd1f859ccb798c6365f8ba8554575
4b986a1c03df4763c8eac1ba4b8443caaddc3b0c3d103c743f4e797b165d5ae409a73c63ad067accaa9c891761732cec43465d216563006665a375e8ad0e003e
384a92c2a0859841419178c1aee092f8ed69557585dd484ec6f07e8d97ab2d0b651f6258ca4f396677d5fa3b67cac55dd1b1099711260ca83b32aab9fe0f0134
381f437126c1a111cef5b565c1fdc039d295197c29920988b4f0343415fc9ea6c13262109586388db58365cab23efa052ce0513ba970ebddef182ba70d3e45b0
da0a0fb36e8e6a4750ddfed6bca4a68bb7b51b2b6d7d5998bd8fc9fcaa0732bc4fe91201b51d659ab295791da2cb291cd0e53148e71b3e1baa6d5dcd2463d375
bde40d2f53c53ab2c213e0ee93b1c46b7d593f450d01094d415a63f21c2ea27f02935f7b125847169610cafabd2ee7bcbabd11bad3bdf0a154f94cdf59fd6d70
d3e504487516ad946c5ba9a085ddc1cececdb085df9efbf9c631330892093c28e8c1d190cfe39cd7850704c0fe028a8d7b4967cc635e59152b4b2da51adc9bbb
10b22b1ce0747d4eddb317d597d6d695656ea38e814921f0ad56bade724b8c335ce3eb4ca6bb8fa211650af2e57370ca29c53c296214632812b201ae3cf28d0e
463927759e66bd4bcf227fd1c34c947bde26b3c3dc80b2dfc4ad1bca6e4523b9abba243ad881622d9240d49e7f9e9ebe095d69638410616fa481230a159e29f9
39a32da1f09737628abae55265dbeaf3b77ee05a8e35e94ad4521ae5ba6d603729590ba73839f6ad10b2add0839c026cbe3f58d168abaed6fca8cf502ba1428d
e939c51ca4bc9238c0cb264eb8d78615ad6a830510ec52465c93f6fc611b038aba5d516728e85dce18b97284ca451efad10ba1b4ae60ca07f6c9637f6b4d55f8
db70f53930cb3cf01ba27fa207a6fcf37af8a5f0477b7e1ba04759594758511c5d4ef8fae51c8605a27e7ddca6575f0a52bcb2eff0d2c39f4eee73e85939eb9b
c7732465d9d1b638e5981c48197038de57529b3f10d4f6fa265fb031792e901dde711f128b3fd35d6d0955a18f67ce20b3e6151392abdb1855aa851e5daa0650
d3191659be25834f8ce3bab92560a38dadf598fc0265ff86e7450b28af3c7eeee7b84f53e3fbaa465c3595d7fde4ee7d0027653906c475bdf028eaee83657e9f
73a85d3b81b2bdc70d51b59ecd3658db4c67cac61cdd6003bb59ababba851fdd507efcf97c2923a997ce1b2a39ee5bdaa9c478265e55bab2265980b283676f33
7efa41b2c3270d21411f459372165059cd6c389a8efa8e2da165851009b6c138508a41b22d59165ee2170ca0b5435f95dd86b2d55fc5c2a5b1f5dc1df599e9c0
c3d8fca6e1365634e9c195de0d5d81e53ded2d4866350ea86dde85171b142cd18ddec2a0be71722ab27f57810f5b1b156525726aa338fcaab22c2b5fba4221f5
97abae9989e67215abaf5a00231e35f424bce1504748987d9300b2c89978e859d1c8d3d6a8a8ae7525891a9eb94dd164051c43332f756fb09a105d9dcfeafca2
da5650375dc7f55caaeed32fca1c7656cbf0082fc60f18d02938b73747a5a659426c530113b9e05c365c87f47b2b1417758ca82d4016597985d37f851efcfab8
8bf6f69b6a3599187c7cdf24abd4f065e7bc20659f38e3fefeefa485dfaef1bcca6ca8590fa3cb33048535bca07a604f7081d4f63ca4aeb025921a0943fa0b1c
2c2ba99cd7f4dc9ce3f317fe9095575c9f9d9a245cccb1570bbce5633bae36fc38f5a540f49265efc1105ca079b5c003913d6387f93de8d9d6a62386e7ce9a82
d62ca82782b2a259a665a57555ca88cf4db28b74629ac3a84bcaccaafe851a7c4665371d55f235246e90f34b4e9a37f0d365b49ea0b72cec69efa874b9f48df4
1a50a1fc052fde492beda085d7e8cae93f4ac825661d6aad08665a6c23fd03788ec182fc051ef02654653764ebd5855b7aef4a8c69838424b924564671683fc1
b2ce52842ad89518d02bf0ed3a1e06a2869fca0f0af86e63668095997af3f0cc592660e0cb89599376c2e7e18212df3d7a54e59ca47c2a6a723f855e974855fc
36509296bc2b284e9567e83d446bbd06c70585d90d81105d49ee37b75984e4895d7712b20bd40db55d2e115b87896d1f7aebf3d1f1ab6f8df13b9594758c3c36
52236bebd9b4792d990475cdd28a849bb8107cb7e4bf07ca4a7dedb48aa5277e67f1ca8d571537dca2f0df5df6ebbbb11d51ea775e39657ed7898ec1ce358f17
a7332d2b979d605c7b37f3809222f1ba3351be3aa98361cc27a9a4f352658edd783dbe7f76533b3f0842976ab0438466a7a07b7638978efacc3d54fa4a5247ea
a6ea39cf17ae99020ca166ab9467931586386df556ccae797bacca8bbe5e4410a42803b62f7e7bd8f16465baf02656d607fc5e388aba9b265c76fe1b2add0425
8fdddda265ae85cf7087a81ad64c7a80be16cad7ab231000ff618517cde263821376bba85dd0a01ef634e64bb688e703bae62ea839cdbfa8958e5fd7933abcf7
7a85d933baf5596994aa96993793f5872e098cc7a2bdcc73b0bdd4ec308d922ba35dcae756959abb1a16ae7377ca236656cf599d3c70bea6ae6a5f9de15a4caa
0bdd2efe20f759b0baa4959e95a0605dbbbe736b910ac2f7a410fc00908515c75a3f1c911ba2c2b24702d6dcaa8f90648d3bd1e0b3dc6f9eb70a27efa8b46eef
c2ae3883b2aaf1b0baf33f776133bac34856b743d785858407d1ccd03bddf1fab9d23b2c8fa609a3657ec6388dca6ba2a12514141bac03668b701b7e61503e80
0b4066254aa6318551cae9b2d5df9daeaa09987ea63f6cc856b3b951f5cfb2f7cef5de712931aae477e1a90afca0389c307ca4c7bbe53fb37b71a8061dce170b
143cac5cdefe90bce1642402ac9d6643f9559fb28d26caec085d3f254755137d71de7cbfaaac53ad52038162a754bb665371fde4efa8ec8f7947b151e67bc437
3f6d62fd21f757702f4ed9f036557b1ecdf5f1695b1c3b21ba640bcc35b46d5db1bca650efac447d3e5d03cb9d6826509e5a5b1440efb4575997d5a40b6dd995
1d054ce72f11959a864da6ab0ee70d1ba33dcae1c64d55e3e7781599dfa40288e476032673913600f371d67985993555caec071a8a36533df9b085de8876f554
bd4f382aacd3657ee5cc0cca87a70d62656e4bef24b4ae8ab2cbec19f248d8685d0d2ba99ab1bb070ef6afcf351f75cca02167f7509752b2e18fd7fae60b11b2
132c23ba336857e26388169d7273a6951d4fa1865fa78431d6a0d348d881c96428bb33cfca5b3f9c96b4bea4a3f5d5de981b2c8fd9529f1f8558aba28fb5a74b
d0ec895d43065190916f872b48cc7b4c1876a9810c3aa33d9ad4e62cb19502b2d133cc8b3415973aca7f6bb1e4111c2dc81650eedf361a270b484dc4bd0a665f
d190be997caa493dfd867b12de44c4b347adc939c49aec807bc04bbc67a057ba03f85dac9eaceae1b0079d091ab49b3fe39fbaf8febd5cafe140cae335ca0575
b7a955ca714a1d5b389629a73ceca6090f9975cb1befac2ba35f4759583d1cb4cae40d60f63a59f7c5d594c2a211b611565fde77079e4628a4d0ba706d931f25
8b2cdcf85e253e72e75ab2065bb6377e3f0955e584f6012b282dc06075f15955ee85514503b4bcca0bf1cfeee272395bebd58555f670f9853aa80ba76d15ca8c
60d542a708fd4f510b2c26f3aeae06712ebaf8813307ec0f777783bf92beaec5cf598d0ad923357aba55482d04859db5b0ecac638d256387e0b6a3e441ba40da
cf443e266545291055e7c4659b331cc5475f99d27e3f7f22aee701c97750ca3b70e2c380841611f0e5af403205eda4ab2c9b16d9595f750df8a808f62e808893
cfcc765fd8265bf3c0bd4f303b2c519c6ecd1c1b3c418f0361588f91485916b4d4796dd4b6d601782fa48a6f82163abffe499518d311ba180ba37eb730a0b285
e7cf0c2b2efc8265bbf159593951dc6e3e9c6c881b826c2366b8ca0b4e835a9a4996d9d06c051ec05d1a3d5980a53ba4957570d1ea5f13b2e950178030890147
265fb5ca89b027017bf744659e3a99db999d49a0b592fa573c6cdd9b3774d2fd0e297f49b04957ab23f6c148638d1a59e62ca44853f80b2c73ec8afd97e99c18
0dafef117eb258cae999007585d7c0fde6fbabe6ee5fae72a753087ba00ebebbd651e2d4b6d60962601b2c0b32f12cc52beb3f75e85dc53ba692d515bde93dd7
f1875aec41b87add2c1ba704ca6003c56f1585179bf677ff19c05e4223d4a4c1797fefc1aac0e1b2982b2eca675051ce2985d09aa5e10ba9fcde8e40f8ab1e2f
948336a826e9fd2391f1fdd24e0ce8c337b71dbe3e4aa53cf670841c4168f1a141d42c935b73f83a1ab076381e76c82debe23bac33f7cca885d1d2499e143f70
30ba5b35f959b321d503c11f747e3fc965050f2685a7fb46d48596eea4a004d7dc0a503eecbb7fbfdfb7f34282cb31704502dfb5b68d968251ca22ab24787ed2
a48f4f72496cc1837358165d0c5cd038f76165c9256e616994de0610add78e70f7685f6037c53703e0f0a5c37cd1d2551ba612b24d51b72df18831f6d7c95f2c
__gff__
e3a1c616f827089701870ce0aac0aa3f74e37768822d5416a4ce2b9854e4e6161b561832903b5f3a34e3b03bbca4d78f46d221dd33b460d477a7dc5c80ed84c5af9087e893bff258edc747bfe3b0ccbee235872e56b679335687b9181ef6f6ae4d2bf09d46516d999587d5311e3e2077c52b6cb8b675c0acf0bf75108b821b67
332c070f0b8f963766d012b90d431bdc8769d95d6cab4cd0cb0abb04744b56435a6652272b8c947548de37ba621c3b012b5be835c2da1556b0f20e8aa1331ccb964933c8eab7282a090f4662914b856b34bc5c5267b824f3aa4a393ec1b1ff89d99b767bb832044ca2c539302f90a51e6a0b54026b7aab74ec6eab2b339e0cab
__map__
2b910a99359fc852bd08abafefee955881117d03affef6738f95cfcb8f46a79fb87b5315b94605fe0a7585ac50b7e8da6f5856fd3e5699615e28e5e2e2af90d43ef53b271f08abb06b90eef4d5022a5930b8cad43d2a2a75556605d3ee326685e3362616c5bd409379c13e2d85d5b9b338a9b9a7ab82a6dddce4f8ca8e937cc3
3103b26a312b5a5344ba6acb5298fdc47d07ce7be21acb942d3066ecefa9f2a8570af2d7c19c54b32a94ae5aceb7132bbe5bc4b9ce9d1d1cbdb5e55e90c12d9db4bf8276721a440de35587d0f7e22c71c8c21d2b5ac14d364843875567d10c158c7180e39b9229f04a331750d1bd79dc5d4cfd5d9017febac4ea114762f8f33c
6005b8baf6d62c6a4ede279690afabb9e86a30c0a880748545339c1d31c738a593d09a17c50a6db08f333f60cd54df7e8fd996bc0ead8702c7475696241eabb1f82bfe32882a56dfdd68aba51019ce5ac3337d33c749d13eab88b7629ff589d25551d2d54dd25526fd24b1422b3c1156a4ab13adab5d1ab2e6c9c87df95a2eb9
cf5a0352e0a6b8c31ee08a44ca050edcb79373547e8a5fcd84b31e2a7505acd4b7acf14a949fcd290138d7ba2aa538ceb9f7a79eae72c70a263a222b385fea5def9a77a0249fe5d606a13f4a522cbfe2ec67ea10810f5e4a84c57d40a23c7025ae9467f43cd8d9b93740499fca34f0fb58843b907ba4e1776af14a2e94eeb36a
5ddd72ac605ac15d5c488c037ff3c2638513a839be3a154c848f59d9715c3be6a07485c68423f978ae986a112b1e64066b85f976b0d8a6a0bb7374b12f119f85415da236be114e80091b2bebecefe0a256376763d5c1dbf1a109726845f7b4e9d32c5f1364c75849eedc7637eefdfbee5d9cf28ee6a774c51d09a474d85cc70a
6f0202d7ed1bcdaa70ac4857fccd302b4af530be1ae0e00347721d7c7448a5ea139a494feb0e5af269961654ff926096bd774ec0d05ce7314e1683f997abb13f7b96632c453c295663f2877b15bab2acbc1e8deea18069bfeb0791558b35e48250b03db40cababdcb3c1b98eaf64a102f4afd0a10c40c6b800e3840d0be655d3
1ace16dfc904d7d0da55b4b43e0ed72177bc5509ea948c7f7a8433e60ec98fe08819c7500600ddf667b53a0d5865605a5445b8ff8c2201ab445736d7813be7cf28ad5fa589cf8a129b219b0177c3b82a6988ba52532a94ac0aab2ba0738f587d874bc4292820d6b4a2724029d994e378ab2b7a75877a455eb6dd57b4d4845f63
0c0ff1df98598def3f6257952382d36e722aac3a76dc209300f567c2ea76d08fc1b34142483750105a736783eca53037c33a03ca8a16d80a2bb929ac0feb01b30213625d3d7fde625670eec88a248afa2356b7fc080e21f5091879f91dbbdc3f64453688b91abe9c0aab3174b63baca61eac44e7909dfa8a6f707e7446b3c56d
5706852893f3a2c85a740515ae7fc0e77fc15ff7760eb38686e2d4a10b46b3416c400ab2109c576f0705c5b793ae526b45b07ace6ccfd0f0ef312b3c6f0abf06ac14647043fa4169599fc3adbeecceddfac96345779cfcbb39b3cafcbbfc24ee66029ce0ac38fc00b85cd8a677c1aa170675df9cf8d75a579e19921f340f6037
b7f0ba270ed7406486059301af494752b37911e907c986708ec29d67f8dc6db641529898228584dc9abed728dc30a0b4e863ac700601fcbbc1ac56f43569b242bf6defbb606f3147b643a564fa0316768c29c3c6320a74c4e6b5af7dadb7ba7b22ace7f85d8be82879feee5465cbc3031d3ef01acf2a5dddc4fb98a1ae7a3802
b2c7ac089170613fd28a6f547880285eee2de1d65078ac0ee6c46ace85051a4ae6e0bc6d57f414ecc4382eca6f99ed445cf40ade0bbd16d4d0d05b4f49e33bf66c648ac2239ccbf22b1272cecedc38b396eff128ab9d4a38106165752536687640cbfef75bdc8b32ad1dd64b052980c56e0adf15b74158c609a4e68e55069d14
95822d2bfad88a55c5a35b80ea847b70d1de3d7db2771277e81d710ded3db869139603b00a7e67a0d9e09283834ea2aa0cec89cae195cd07dbe4690e7152c7ff6e63afb83f004cd605f5fb5640ed763c49c719156d4e136d4f78223110d4a2c1eae7078e15aef7259dd077434c9353a5abb15bd6839aa4c823c5ceb29ca00cd9
53a2eff96f1616fea32a087c1f17747643bfd2d07593c6e19db952133fa2215d1b4d76a5f3db4353220beaef781bcd23b1b0fa2a2045582709f507ea6b0ff5bad8bf7d06512830c89915747969e61669b6f81bf5209ac298db8e03e2cd9390798237523b1dfb4644751d9c8d0256f9d3b6559669eedfb70b1a5de48206cbeb6f
6c14287be924d34c8691a1d8e7c6718855b7e358a1e9b4f8d2dcc7b2d6cd5db7110f9e881eb877dcf6f82b35db76bece54dbe033d014f0425673eef8f0ee26ab44be351b237f49283fb337decc398b843b1ce49a55ac6470f3a7722d7f4a6b9ae52ed9d4ff9d90b6d4b6bb037e1e4ed1b1522500ee07490c6c6a189e9086c893
df2748fbf81fbaab8c0a11ed7e2beabc706464aa5788cd7d564e572ee9436abc4c6370d0e199c9e662dae5df3218ffd9b7a7e0a4419eee44c7e318303ea77fe08e0f4b2d1d13b043008a7da81bfb8260b443a3523f8fb1127f05acf0bc13397962779f23977d856a47befa63af0a1529cf26d1a9bebb13f82b9f15af1cc5bb79
ede942cc6aae8475ae618d134aff4ec7828862f1c86c8e5d2a16fd3d79addb786078de1812860a03aabfa1a468e63af6e46ede87ad26533f880bdf5a3f076b3a31e9bc5e5682c21256fb18d4ee5041ae45a0a2bd223e2765c6d4bbd3a863955a565db43ccc0bf1891b242a7616d9ccde88416899a41bbe6882605528ca6e03ca
237031030e0d1dd86905c608a1f3bab74be647abfe14abd9cce98a67ad628ec321f8373fc7a677dbbcd88a8d9040419da9cfac2476a88920dc4d7b7c567702563c47936abe32d0f45056eb274e4fb498e4b33cc1fb318ce7c970acfe55c38214845051cac79b714e70426443944643bca258a990419243baeb22b869b0ae1bd4
1b0210982788290480dad9a77dd3700487102a4e3d29c3ea79ac78c01a2386038f1547fdf65e06fc6580d46d3d529e0a37fc1aa16f5351d546650d87181443b64a1110c5813cbe0563c3e4eba9c1bb5a57735f57d07c8a97a488cb37eceae2eaa403c5ea006b7903462599a2cfca1f3c1261cdb5ae4e51593dbc553af5833d4a
1032755311bb069d136f6587b7fe85581d16ccaa4654bc19f7f453d3b2db7d2aecd0d5615b84b07f7757acf1804b9e544480b98b731d69d17d8a282a429975f866c454b853acb0e2434e9b610d068a8bffdb63e5e67e77699401084bcc403773a212db8abf18c2de7cb98d590d2c03b14b1c78bad5834356d5665cfb7d5c1b8c
d7d645a143f2fd036d973842f20dde321592b5ae9d51c433505a1c23e0d8028546525783cf5346c9babac7fd1b0fe06856a79e6f2fb3e21bdb9289533ec839969c08fef9904b093c438d582923fc36a5bed0246d3434767838de28ace12f7e8185b73ead751c3226fd0e286049110a831ef2b95482cd79f628e4ce6d2aaa2458
c8e3dc040be8b615038eb6eec8083a39ae8055df3744cd6a6e6fbccc73f93b734ab85058e800e5eb65e53b12c7e83c3d1bb4ae7df5107485bde5abc9465670db35e6e142d0764b7cfd60d78ba6c1b388cd646e4d00b3dab17755e4a480eeeaa2b1ef5a95622a01c6b8ab594dcbbebd250394f65b3f6779c7da97652577ea1bac
6816ed2b76552bba72ae5248acd0d9630d7e4c837fc5abc834596f7bf8cb7f48d897082bcc4a141ebadb3e9d76df6e7c432c99b486374f825b80ef684dc0b5de1fdc0bd2533b688069b50837ca4a6ecb4cac642a45ae58a58f2c2c1ae5dff91fe342e6879127c3f434c39b84236e64f52f34f510e61ace2cab5a97b558dd3d91
4bde275626ff83df26f9e31bf5e2a9e2a0129d0b5497f1449e59567ccf2c4e6f6c14b987f653c58a6c109ff99b3d1fd18ef357242afa9a6e3737aec7f5bb42be864c58f5b1d2f80ab64346d8e7c6dad92a28abcfc9b50f6df0f3dbbc2cacd191c72ae1674cbed7b7ac1c3638a116d633b163044e560478adc4fe2c2b5534c030
a2acab534d6b3fc6aa6c82fc5d912ac3924833c5684fbe0b109a4ef7a97985f6b792fe54ca49acabec73bae5d4906ea9409de2c36a2b5cf2cf914c50e3f9c034843b70dc3014205668277daa4175bb346b4d6ae5382ed1b2f112673195ac86d423c233f1329682d516561c35146e6de2d8de71ac6559bde28b8843f272e10a8f
15051d87a739df2a08f7fa5063a1ff5e38912d16fcacd89eb01a0cf8571f02f136e523bbc00826670d48417043cb0752bc2356080b4f9f92beb20506b8aa58d99a201afe3727d65f518265b4655319aa2ed88f61c080921bf758e3b0af7dc5ea41061de96c4cb105c712d765612dd5a311fea46724dcb4b80e18555faa2d144b
709e82ed7a34d6c111b11a70c1bee52a3215b8f6a5769be8f551d18d9698a999cfbc864c6e62a7da000116b82bfcae29b7edd865099f9d255cbee7d94212cb5f7bac16a506232d82858b87fe69788703c413a72cf8b1bbe3e22e301c8ab8a9b6a358c18f01c986cbb0c39a4d54570f8ab6ae8ddc39d75b49b2e595ef8109f9af
71c75530dc3c0b5a30fb00515d437c6159fda7b01ad5f586448b1dfae2744035268c3bedbf5dd1956c6884d4981dcd6a20ac70464405ab204ddd8d8bc9ffd37474fb34dec9b3306732cce7b3ba7f48f7adefaaabb86327f09c61727858483d09f6c1ab96af1fd65d578d0a6071c4d3c2284b1c174d6dd8c575026ac46317b248
68e46da52b529bdcc1fbf64ebfe4af2ab646ca92d4f29a6fbac0b67843f33579c201758076ec88bdc1545556ff9ca1ae78e2b9b0d246b8744638b24fd1cf232024752b310eeaa406543828cdcbdac5a0feb67316c46a47c605885544578a9ea0545eaf7283fe17dfcf77fbcbecdd51a460cf5870f4b1af50dd2633016151d5ef
cf6f48635c4064567f701116757a23afd98ceaf1c51067b1b38b020b3122b39365785cf2f6ae3f706840f4e9a639aea92d4ac98415e6dff7ea0b43b46d56159ffebdffcb8103f68310158d8306607588021bb4c3dbec52707509dc30c76cd87f62eecc36f86d2ea13b215983ac9ccc586440ef31fa0c1b3fddc35ba9e3c81a8c
12e2641174e7ff16086b1f5edab7eda4ffa7f67bd63ab498aec95637bcaa7465b647aff8b60773fe52657fc2948c13d928907a224ac1d322a1db2f41273ae471295e94fae97f1e4eb48ad6b1662e962830dbdadba22d1cb9c521ecfe8ed4b81c5f0a0bfa85fdaa312caff65d61a0ca06a3dba011ac7bf778c02471dfab71ffb6
ea8dedc411f7c4bd218fae24f44d9dcc0af6f1080354aa999a2b70bd72ce69818ff45f2cad2530749d91b5c4dbb77926e6404a53129e4d18d6bdaedcdc1226aef7adae8a6d590d490e757116488586664f75477a0f6b91c2da9a1e67f1d81f0ca89406f127ce38333d25cc5cc6af9ffdc3a7c4ea8f069692d232587133b2bf28
68d08d4aa8d26b158d570ba347b30ba5d52edf1fcfc60d7dc70abed4ae312b8655bd91b7e241b43bb4c1e768506e47b17265242245f14e82b3d5b0b6476b1981d4f7d7720facebdffe976525908e988f8eb70caa2b0627c20535c140cebe320d38f2d1e4a5d7414cfb368ee9f318965b2d44894013d7ee60c595d5b5f3772862
__sfx__
046b82a00b223183741851416646098310bb5525a662a53038f253c23527d2011a240a3653fe7108e42307353ce023fa161b9423a7420de0234507314070543703766344043dc0433a3419e63358020cb3308266
56af455826021370622557309f6104c6406b36251260524516e4307632326632ce571ed022ee223dd700c94626550341502ad45394333df001ef021c117231171ca210d0363ba4614900154502bf150b5722b602
ff4e859a1734020d6026d4300d26180450b12635327293022dc641f4741950720a5217b122b0200067039904022140606101036165303be64114430b530131122762637c232ca452512322b2537d263997107437
42d81c540d1740347235a01150721c7752da2234a671b5213095126a06190742406005373311232212528a412be052bf7320e1037c7716b302971514955135023532732b760a26410f703b8323cc0111b132a707
1650320f190350b5532d83115c250ea5703b702de5623f5311533282721a6312b25302a152d5430a2103b9302b11635d6003e401fa163dc710fe301ed70350670c9741be6335e02042702b1101e1601fc4117901
1c122ce33eb1736f661767435b3725f3126f47116632d87611c072b265062042b53011e4136e701f73016e6508b1128a1401b620683720e53225752c155272771c9131bd331a127178323ab2320567157642a832
76779bef32a6331704302042ac540c105178073ff37389672301732712121313c67638b55204033ff731dd5730a73348570204507177130530957027873099102dd310dc630f84211a32055122d9743db6022003
9f76c8213c5312272018a422f4163190316a7424d643f147150742814523e110641723c541b9030f3570d70701b402c06014f30067360c9762da1116f160bc1712607016760360019f5134f243d4531c52610254
8e0aadf20ba512d924274243da2429e46185670f5650ab340fd6301d310dc51099123f6731c77110b23188471fc7311c7424a0521b650f0500553518f5711433287000f64200b200dc1227c161bf6025e0007213
6c28623118c5707722167740d71433b330737523c053f4073166700b423ae6201b073db331121516c052a63635e260667521a070755406c6210b202cf22092133fa32384003ef321e2700272003a372a34023530
43d2d5ab3d612381621eb700ca2310d2126f222300517a1506067286541ff1302b750a044359751312514c511072130d253fc762dc5303523029101eb771eb050ee652d9553f87637b373de1437867183652ef14
e0eec59012555306031305610c673b5401e750185650cc7029e7003a7130f621db70041662c42410c310b8153035610b6634871103432e1422aa55133162dd21028301a6602f427386242b845264271ce453f070
fe8ab6be1e3612b335315642f720164341143125a64132160d82116a47331102e4613b70430725242622265432863048321e6560722706c3038d421ea3035f763ef571af7134d150435222c523566317c6721a36
468495b50b53610e25313571d4422f6711ab471bc1610702052452b92608c61237033ea20061431446411e2522620025743ad062ff0530251133532f04118653081553146415f710cb742dd2707c273225518151
0b3fbb761166236c340a0362b6002ce540b56511e0223164300341f5053ad3430a020220304a111f8301aa3611f16270213c9110fb162056120d2107d720f9272ab77133752036522c512fc401da070572037870
16ac959d07a5233727031300634406d142d95701307037062ec160813231e402a570095311097233015195543c4761e753025651d4053347217b440ab0611a23064460e4252a7641b74426d5420e66389741ac65
d984033d16617298351796004a04229121fe10146161997509a2408e7609866183662b847194472d31601721109720236438663009311a442292023853330126123372cd4531b1314b4203075279451f31205131
c34399a0280273a00237f5423c56346451814114d1615c1313e340655508d523c33418856327450984735b012f8440b84405c351864032f051055504540123710ae421e473053530ef2508274012123eb252eb33
878f258628234233010b43202847114060572020c463567523947026050172217a57172533551318f7036c022aa4634d040dd411f47228d332ba070d65032a142362231c140c1070233136d0707e0705b1412314
2ae08a8507b413c4752257330245040371df313b82515f33368043186229b2607131168733bb462d02325722143431cb0214853159560e20637c640d9052b7130d7022e0030e043344443194506f0118b4711c47
97f8b7db211600a86010c46094522d84739a370a34535f520b0510041616b61031201f6240c51415741329362a9152ae54176721fa633b54021d07178343110729117215530db3021f2528061119731841513232
33a185f50b3170893107d763ff71130050d72238076343071880119a363d26728e072821516d271ca3603a0727e071d52529b733632312f3309652125772dc641975335306090202bb600445604f3233a2130316
d833777112a373d10227650179261353627d243f3070153019d51305403d0313df1200a602f6012c4053100529a66075503c951371231572511845161671ae501837017835216621cd32022343944121e1300a36
c12561c52b90317e223e7543f6043b66639d00185612b4720ad730d66725c14374543a871016103c14116f311777417b331da362594019060369421c21604d7021f4511b361ce521e72709e01391511d14623926
e9d8f0a31f8411056316b462a31431a1113b171df532f54623c273a14132b412d3150f554333740ec233f3142a0452b7233b50234c143757417b1303f500b616136103e46513b3008a350b9101a11413d4025871
a06f30493c6622cf74112402b11322c571f470179411d66306a111164335d473c020097223f27312d1006b3102b141da7305a100a2552ab3139e610d20712233145113803502c403d0301602129d6707b550e827
98858644257531272118246332633e2341595625e011de32232231f8711ab4426f66201203f23407253216560b33038a33237763037727a7405e552fb440e540020340b7202f77728841380531f8551480432832
4b0545a9315702b7143a57102c41009420ec000203723230150773720109e561db1336b660fd540fd21360743924233c0219c1623a062c2610b720390762cf022945605660020732cc6023d452db443a54715806
b66474fc2f1223a1550ec35167622d8222b07530f2223125222761386210e5501c171fd150515705837374023130428c2306b301ac031b0172fa752de750960236c65241143b03502f140d0550dd471ec331f255
358cc1da2c4431355316b301e7110150637d17057152eb5425e1414d410ea203075025615092041c84411b443bf0031c572566332e22059531ac042847135562044500ad3418f641c17224b571946501b650a922
746c93911446415e67150711ca1310f203a7042d55322c253b54104314069142905706b371d1060c92306f610d1652c52427154322050492602c050ee601690538e431e9000fe72168760db1206955117142c152
ca2dc9b604a44268250204730e07043301a4353df723507337600093053b050262410d0512c5363fd0417047246723ef012783011251047223712022a10367061af23067772aa500a73010a1628b112291111671
b97a7f31397151202208f561cf50283120fc432f14330f511140203a403d7152cf16380713e8733a210169061d7322fb341b64505120167421325522772331330cb503f90739a1204f222d3352d1431cc3019b02
78a7a1aa2d114057701fa62290561fa43343343964235f15330521410135d143016010b540a6643cf40288750b22428f1510e261907314c063d4043f9070a8440052514c370aa533a77423d202a4103713508f70
1cb3985622a4730e461702216a14392052fa01202633eb140d352385603920206a540b1401e6051f9323d9462887108950213740d520297520e0711606724e0528b4702e470c1622b02037d033411722f3129603
92163b8c204620c56100f453fe470f041133533a9101d0600e4073de5018b0608417282421624134c342a92338873206062d7311e1062e2532b0743ec221fe32044502b2561092636e551021218050237472af74
a092a37d04423390760e26338923383442a71730b253187421b022a95334e201a94310a14224053bd6421b3229f36002730ef67006311ef6321b750182506c103272214d2201f0206e440f43414a4132b7314c17
3a8362a20ff011ca03353363c413058122c81302126351203aa120ae371bf26105603e3461696515b5026334186741ab740f67037d401cb72300163a251319463b3453c232224002d4002b0011372115b052fa43
1a89399e18805302572d96612f612fb1712f4121545035511452704b15064123a31422517121531754439c6632d431ec442f703371632fe020fc103aa3339f7635e0036c063430709561002021e10729b443c353
beb01d952c0022ad24211263c5330d80300f421f475115233d7033d01131c7205e25080520c06306f273ab570b6220f71700d722a10519a420a3662f675230620af73288702f910272122d9313912114d7015442
15d51ddf1c0242c57402c522542419107213753ee222ee762dc033a557044202e1512276139c34238501c953223112ef060a0301307208711222600fe0600c70318273ea240f37326d1623f160e46608e1001f47
25bab741205063db502e63036b441836130b421365618c0135f361b34312d512e10021605021340c974018513bc010e9700d6151c20218d040be2122d23007520e611070041714523c211f0060367416a3613570
308e2161193503ac7423c4205e142e17530b430b8733e316047000703728e7029307347043b742262742c272288050257235f262395439a313cc1228d4326747295562536731f700a24022d26306242de1516f73
889551ce099040d53639c012eb502af7102b502bf4518e452371630555171433542007b0417754064563b274389003d3730706418013226163aa011296537325098041cd1118d0400b422393718e563516506167
e3e9044b289711a2401d455342020d916241410862108f551e1341832116c44010210183403171009163b176159031a942380462825211512370322315104c611cf033815508176270433980032161126310e721
ea92510d36d26364023ff372f8602234730f2622562364240994334f621492438737144300416638337339600922401b650500623c02127372542619412256333f9243a3011ee2515f212da02392050852239024
bc040ac20542122716016241380207a521b7513921409c6125b510d6160d2723716724425068611cc6015405286073ba4321f6508e1437143136010fb33032700a210061110d7220e5133821235175316673d820
c139d182303630a7212f4603ea30177210704417e3412655122471f5723834730c112ff2627245048221e247342401624414222253052575216e70370122966611b3105a200fc0007351116601ee35125753ad50
b06002110bc7718416009610010420200007113a7503ef322e711181600bc413c7570961226325391450f275033702f2421c5302f4161e5652370511b503020600c7202e723e0211b822395041470523f2439154
75f404cd1c835381721c23013541324633c2752d647107101e80608b3721b413e97025b7508d5208a0416a31100733a2710ab261e72117663170633b2200266338c230be07039220c466166443d2212f61427227
7a3eb8db30d600644039e70319362b62118c5234150320643702427b33246450d247185162367221b101cc16147422870501f372310006e133c0473b1660737401d270fc4224a043f07231973070200c85326a06
66d7eb2b06b553e4070c9113ba632e8653d82210855181252662625b2534a321985232d052fa723883207f022565029b420d9273750602b201585400363023741903637b773ad603d22308456025773de2409627
cd6b5aea1ee4409c323cb31066470e2461ed3239d4631c2639a053ad132be31204120cb5021f1204b560a460199132665428305260123f94639975203620f840260032e141211403ab26297513c646041531f610
273c465c238750503720910121613e12317911141241211601d62045430ea452531530e04126741ca54244250e631368162424002e633072038946375720771632b06138610f1701e216097313575408c2631513
0adf6150202021c0643c012097053ac1004d7310e73003222126200e413483632921066160015006a57101450da422056401b170a3631ac6221a133eb45245341807602d1100d122c3211632115f45135240e511
a62bab2b2df250aa122f6033dd7036c4121b55390722184411a070ae031d11632d040673705f023a3243a73630d622b1723787306a260fb66327770157505d1732440150411e71638f511cc67172212930239923
596dfc553cd330d0072f20228214215650167124e0135965398353b10019b413aa0535474350372b4721f1140a630113300e331194250f073205340ee1234a242a3153c021329122fd073b073046550ad0217b54
357a428124f1635b013736017307095133cd0638b3637a502fd421496324b71078513ef3137a013e8041ce711734310253217472193602177018363f94035a442fc421326522222278410670625656029313a357
4612a8b406826330063c8442ad003501004720320570da140235524c24300410676039e6616f363c57701e222c803377161c04013e061511338654346523231607f313c057181611a1253f9003bb733d0230fc06
127c019e39c542a96018c072c0321613600c573811724c130cc2735f4130e5027271072503286616a072e046130620eb06132230eb2704c17310622ac70043251f57119f420ba421b9032b4103356419d141b602
8aac39ae27f271a1102ce30381613c25428062201301fa6734f3507327127113b2542eb0710a522fc7503c122ff2213c53144011174333d451d07120f641760505d353876619d720c71723945077232632417366
0010000023a071cc5017046374200d2432216324d32003062c6663a25330d0220b130f6421d3142f97306530317222a3401e8773fc470cf400c20000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
05 1b 42 43 44
02 3e 3e 43 2f
03 41 3a 43 2a
06 37 42 3d 1d
03 03 0b 43 04
04 21 3e 43 44
01 00 42 2e 44
03 18 42 0a 44
03 41 42 43 2f
04 41 3c 43 44
01 41 42 43 44
04 41 42 43 44
01 41 42 2d 44
02 41 3a 43 2c
03 24 42 2e 0e
03 2f 42 35 2f
02 19 07 05 1f
06 41 2a 06 18
02 41 42 31 44
05 1a 05 43 44
05 41 3b 12 29
04 25 3c 43 16
00 41 30 3f 19
04 41 42 43 44
03 2c 42 0a 15
00 41 42 3c 3d
04 05 36 43 1e
00 28 3b 06 35
04 2b 42 43 00
06 3f 42 43 44
05 41 3f 0d 44
01 41 42 43 2f
07 04 42 43 35
03 41 42 10 44
04 2f 42 43 08
03 41 42 09 16
05 41 16 24 2b
00 23 2d 2d 34
04 3a 07 43 08
02 36 42 43 44
06 41 42 43 44
00 41 42 43 44
06 41 42 18 44
04 0a 42 43 44
02 41 1f 15 18
03 21 42 0a 44
06 41 42 43 44
02 41 22 43 44
01 2e 10 43 44
05 41 30 3a 44
06 41 2c 0c 1b
00 20 42 43 1c
03 2b 42 43 44
03 41 21 43 1a
00 0b 31 20 10
04 1a 42 43 20
01 25 17 43 44
07 41 04 43 2e
02 2f 42 1d 44
06 41 42 43 35
03 41 1a 2c 1c
02 41 13 1d 44
02 41 13 2b 44
02 41 21 3e 23
