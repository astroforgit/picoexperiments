"""Native bobber designs: small and large, with top-centre attachment."""
NAMES=['CLASSIC','QUILL','PEAR','ROUND','LANTERN','CORK','BLUE TIP','DOUBLE BAND']
COLORS={'k':253,'i':252,'r':255,'g':250,'b':251,'o':248}
DESIGNS=[
 [['..r..','.iri.','.rrr.','..i..','..k..'],['...r...','...r...','..rrr..','.iiiii.','.iiiii.','..iii..','...i...','...i...','...k...']],
 [['i','r','i','r','i','k'],['.i.','.i.','.r.','.i.','.i.','.r.','.i.','.i.','.r.','.i.','.k.']],
 [['..r..','..i..','.iii.','.iii.','..i..','..k..'],['...r...','...r...','...i...','..iii..','.iiiii.','kiiiiik','kiiiiik','.kiiik.','..kik..','...k...']],
 [['..r..','.iii.','iiiii','rrrrr','.rrr.','..i..','..k..'],['....r....','...krk...','..kiiik..','.kiiiiik.','kiiiiiiik','krrrrrrrk','.krrrrrk.','..krrrk..','...kik...','....i....','....k....']],
 [['..k..','.kkk.','kgkgk','kgkgk','.kkk.','..k..'],['...k...','..kkk..','.kkkkk.','kkkkkkk','.kgkgk.','.kgkgk.','.kgkgk.','.kgkgk.','kkkkkkk','..kkk..','...k...']],
 [['.i.','iii','ooo','oko','ooo','.k.'],['..iii..','.iiiii.','.ooooo.','.okooo.','.ooooo.','.ookoo.','.ooooo.','..ooo..','...k...']],
 [['.b.','.i.','iii','.i.','.r.','.k.'],['..b..','..b..','.bbb.','.iii.','.iii.','.iii.','.iii.','..i..','..r..','..r..','..k..']],
 [['.r.','iii','rrr','iii','rrr','.i.'],['..r..','..r..','..r..','.iii.','.iii.','.rrr.','.iii.','.rrr.','.iii.','..i..','..k..']]
]

def pixels(design,size):
 rows=DESIGNS[design][size];width=max(map(len,rows));center=width//2
 return [(x-center,y,COLORS[c]) for y,row in enumerate(rows) for x,c in enumerate(row.ljust(width,'.')) if c!='.']

def build_popup(palette):
 from PIL import Image,ImageDraw,ImageFont
 im=Image.new('P',(240,164),249);im.putpalette(palette);d=ImageDraw.Draw(im)
 title=ImageFont.load_default(size=13);small=ImageFont.load_default(size=7)
 label=ImageFont.load_default(size=8)
 rule=min(range(1,246),key=lambda i:sum((palette[i*3+j]-[64,78,108][j])**2 for j in range(3)))
 d.rectangle((0,0,239,163),outline=251)
 d.rectangle((2,2,237,161),outline=rule)
 def center(text,y,font,color):
  box=d.textbbox((0,0),text,font=font);d.text(((240-(box[2]-box[0]))//2,y),text,font=font,fill=color)
 center('STAR FISHER',9,title,250)
 d.line((10,29,55,29),fill=251);d.line((184,29,229,29),fill=251)
 center('BOBBER DESIGNS',25,label,251)
 center('EIGHT DESIGNS  /  TWO SIZES',40,small,251)
 for i,name in enumerate(NAMES):
  x=5+(i%4)*58;y=55+(i//4)*42
  d.rectangle((x-1,y-1,x+55,y+40),outline=rule)
  text=f'{i+1:02} {name}'
  text_font=small
  if d.textbbox((0,0),text,font=text_font)[2]>52:text_font=ImageFont.load_default(size=6)
  d.text((x+2,y+1),text,font=text_font,fill=251)
  d.text((x+2,y+1),f'{i+1:02}',font=text_font,fill=250)
  for size in (0,1):
   cx=x+13+size*27;cy=y+10
   d.line((cx,cy-2,cx,cy),fill=254)
   pts=pixels(i,size)
   for dx,dy,c in pts:d.rectangle((cx+dx*2-1,cy+dy*2-1,cx+dx*2+2,cy+dy*2+2),fill=253)
   for dx,dy,c in pts:d.rectangle((cx+dx*2,cy+dy*2,cx+dx*2+1,cy+dy*2+1),fill=c)
   d.text((cx-3,y+33),'S' if size==0 else 'L',font=small,fill=251)
 center('LEFT/RIGHT: DESIGN   UP/DOWN: SIZE',142,small,251)
 center('ENTER / FIRE: CHOOSE   B / ESC: CLOSE',152,small,250)
 return im

def tables():
 lines=['bobber_visible dta '+','.join(str(len(DESIGNS[i//2][i%2])-max(1,len(DESIGNS[i//2][i%2])//3)) for i in range(16))]
 lines.append('bobber_height dta '+','.join(str(len(DESIGNS[i//2][i%2])) for i in range(16)))
 for i in range(16):
  pts=pixels(i//2,i%2)
  data=[n&255 for p in pts for n in p]+[0,0,0]
  lines.append(f'bobber_{i} dta '+','.join(map(str,data)))
 for part,op in [('lo','<'),('hi','>')]:lines.append(f'bobber_{part} dta '+','.join(f'{op}bobber_{i}' for i in range(16)))
 # Top-left offsets of selection rectangles, drawn procedurally in native code.
 offsets=[]
 for i in range(16):
  x=40+5+(i//2%4)*58+(i%2)*27+1;y=38+55+(i//8)*42+8
  offsets.append(y*320+x)
 for part,shift in [('lo',0),('hi',8)]:lines.append(f'bobber_border_{part} dta '+','.join(str((o>>shift)&255) for o in offsets))
 return lines
