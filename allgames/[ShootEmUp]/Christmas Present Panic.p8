pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--christmas present panic
--sorcery

--12/20/2019



function main()

_set_fps(60)

debug=false


story=[[
christmas time...

a busy time for most, but nary
a soul alive be as busy as the
jolly red man himself!

but there's some wildness afoot
this evening at the north
pole...

it seems in her desperation to
curb some of that business,
mrs. clause made a rash
purchase indeed!

"the gift master 3000! (as seen
 on tv!)"

it's not long before mrs. claus
realizes she has gotten much
more than she bargained for!

so, with the other elves on
vacation in tahiti, it's up to
you to put a stop to this
infernal machine!
]]

wontext=[[
b ivti gbmmt pwfs uif hsfbu
xijuf pg uif opsui qpmf.

xibu npnfout bhp xbt gjmmfe
xjui xijssjoh hfbst boe
gsfofujd dsboljoh ibt cffo
sfqmbdfe.

sfqmbdfe cz uif tpgu xijtqjoh
gmvssz pg topxgmblft esjgujoh
bmpoh uifjs voevmbuf dpvstf
upxbset uif fbsui cfmpx.

sfqmbdfe cz uif ivn pg dptnpt
txjsmjoh bcpwf jo uif opx
dsztubm dmfbs ojhiu tlz.

zpv ujmu zpvs ifbe cbdl up hbaf
pvu vqpo uif ifbwfot, mfbojoh
cbdl fopvhi up mfu zpvstfmg
gbmm joup uif topx't fncsbdf.

zpvs csfbui jt tujmm ipu, zpvs
diftu ifbwz, ifbsu qpvoejoh
bhbjotu zpvs fbs esvnt tp mpve
uifz njhiu svquvsf boe zfu zpv
gffm dbmn.

zpv eje ju. zpv cfbu uif
nbdijof. zpv cfbu uif peet.
zpv eje uif jnqpttjcmf!

cvu nptu jnqpsubou pg bmm,
zpv eje zpvs kpc boe zpv ofwfs
hbwf vq.

zpv joibmf effqmz boe mfu pvu b
mpoh tjhi, boe up uijol, uijt
xbt kvtu uif gjstu ebz po uif
kpc!

kvtu bt zpv gffm zpvstfmg bcpvu
up esjgu pgg up tmffq, zpv tff
tboub't tmfjhi gmz jo pwfsifbe
boe b tnbmm cpy cf upttfe gspn
uif tjef.

uif cpy gbmmt sjhiu joup zpvs
mbq xjui bmm uif hsbdf pg b
gfbuifs gspn uif tlz.

zpv tju vq fopvhi up pqfo uif
cpy boe jotjef zpv gjoe b
qbsdinfou, spmmfe, sjccpofe,
boe xby tubnqfe.

cfjoh dbsfgvm up opu ebnbhf ju,
zpv dsbdl uif xby boe vogvsm
uif qbqfs.

"jo uif obnf pg uif opsui qpmf
boe cz uif qpxfst jowftufe jo
nf cz uif tqjsju pg disjtunbt,
j ifsfcz efdmbsf zpv bo
pggjdjbm disjtunbt fmg.

tjhofe, tboub dmbvt"
]]

chr6,asc6,char6={},{},"abcdefghijklmnopqrstuvwxyz.1234567890 !@#$%,&*()~_=+[{]};:'|<>/?"
for i=0,63 do
  c=sub(char6,i+1,i+1)
  chr6[i]=c
  asc6[c]=i
end

char6=nil

mastscores="dasher,1000,dancer,900,prancer,800,vixen,700,comet,600,cupid,500,dunder,400,blixem,300,rudolph,200,olive,100"

cartdata("sorcery_christmas_present_panic")


if dget(63)!=1234.5678 then

  savescores(mastscores)
end

logo="a<;9bk]5?>x4@>#91o;k7>}5?>@y0<#8rsy b(sy?n@e?f@e?rxy0ei!co$6y.;0b%sy?nhead_5_bb~q<h37rc6toi!cgz6vkiidkz6$e]5+bb~q<x2qame?rxy90i!cg$7rk#ig8sy/vb~v2xfax_57n=68ei cg$6r8y0bs=6#e!5q02e}br=r<xy9e;ibkz7rky0dk=6qg;l6e!522hh?fwkkg:6roijd/ci7>}5?>h277s78ey0eo$6 i;l7>}5?>h27>cibkj7vk;l!e!522hh? gkakz7xk;k%:hejh_3q02e?f]27b}y a#0iw$6#i!26nxy/vb~v2xfax_57rhy+j!ip4ij8vxy=f]5+bb~q<x2qame?fh6_fg36vxy7#;l0zhy=f]5+bb~q<x2qame?jy27rhy{jgkb/sy=fw36jxy_f;5s<x2s[}6=fg36z@y@e#j0jsy[fg36jxy=j;5?>@2bc56=fg36zhy~f!jbs8y=vw36nhy+f!2e/}5/ji<boxy+fw37fhy!e;i7 @y+*]2bc?6?>x4cg56[$g28jxy e#i7_hy_jgk7rx6=p;5?r@6=hy3738y{bwjbkcy>n!k7vx6[p;5?j;<b.xy$eg3 bs68aw58*sy]f#>d/@4co)6}f]k6f}y=fw68a]2 nxy&e]3c4)6?rh7+ly47*=y]bw68a!27nsy+bgl7 x6;?#7]h;47_sy}bw68a!26vcy[b]k7$}6??5<c=xy,i]36f#i7fhy ag36*sy>r;?'p#57 8y:bw69aw27rcy[b]k7>x2j(57?jxy$a]46f;i0nsy[b]k7>@4n/}377cy<bw6,ew36*sy?>}5?bxy#a]2 jhyb(cy{f]k7>}5?>h277cy_j]i7bxyb(sy=jgl7>}5?>h277cy~f!j6bhy6eil0:8y?>}5?fgk6bhy@igib/=l6m]5pp<5'fwk73sy7e;l)asz{><+d?x28>=i6js8)0czp?&+|nglc4c80e;l0<2~5m_+b,wles=77q;l7[<h5mr+ >=9cgz6)&<h5[_=6>8ibs:7tgylj?_h52r=)es6rwy b=s=5<_h36<jkg:6vg#icwc=zq/hva:h362jb%$6qgy0bg=602<g7ly;5qb05<regts6zsy0bcc782&h6ti;5qb05<_ehls6sk;0dcj7rgiih?be7di;bc4e9}r05<rfhhs6t4; ac8_4m4e6dy;ao467+r05<bggp#0f.$6f?r;_n469ti;2e:hq0|hfty0hkz6f?be7t@;eg766)705ale~cb&qale+/befty0egz6f?re7x};ao_66)b06c$h~cb&qale~cr&_f|hrum8rcy_5e7;{f467t;;1aj#q]b&qale~cb&qe|2_/7ee@y_5er;ak(27l;:3ej#q=b&qale~cb&qe|2+/7efxy_5eb:bs(67dx;5eb07c:g~cb&qale~c_&=b1m_/_efli_5e7;=j467ly;=j(hrg.0.ele~cb&qa,m_cx&~q|htqm6e?re6db;{f460xh;4a:#q%b&qale~cr&+ilm_kh&5q__5ib;qaoe6t};ag438|b09c$g_cb&qal2=gt&~e|2_/rfe?7e6db;qaoe6h@;bgo67px;5e:#r!b&qale~o}&~e13=/bfc?bf6db;qaoe8p#;ag(26?r0 czg_cb&[f1m[wh&5ub~5yb;qaoe6db;qiy;~fo60?b0!gzg=k@&_e,m_k@&5<7h6db;qaoe6d7;=b467?ber4k01q1m[kt&~f|h5<re6db;qaoe6db;+n/hqej%r=r&~i,2_k+*5<7h6db;qaoe6db;+f/hqe$%q]7&{f1m_s+&5<bh6db;qaoe6db;_f/hqe:%r'r&{nlmtmd&5<rh6db;qaoe6d7;5ar0*c:h_s@&[e7m~/_h46/hqe$,q/be_g}&_mln~/_h5<_fr/.05a_&ralm_c+&_e|h5<_hvi:,7g:huelm~gd&rm|h5<_hui:,0c:hualn~/_h5<rgr/%$q/bf_kt&52b&5<_hqa:,@g:huq|hxi|h5;r0)8.05<7h{/_h3a:,%c:h5[_*5<bhq/%%q/_h.&|h5&b0)%k05<bg?/_hza:,%g:h5e_)>/_hraj,7+k05[_)?!|hwi10%o/%q/bg?/|)?!l0$w(%q/|)?/|)?k10#c428@.0?/|)?/|)=g:$7lh;$g:)?/|)?/,&r4k;f4%0?/|)?/|)_kj%6px;@c:)?/|)?81ork'08g/269.0_<|)?/|)=%906o$mqgk77@.0[<|)?/|(<ej#s.d07ti$tkk0/<|)?',pu8t;[bo =iz#q/tm?/|)]/dmu%d;[f4osc.0?i+)?/l&?i90<ao7~boprc.0?m+)?=|p>i,m61i;/m:p{<|)]/tp+sd6{b;p_i:p}<|)_kt&?69&]eo37?9ms/do?],m_/do=8d;[f/n=!90?#+)}=t&?i1o6ti26,9&?[d&:<1&>i,p_(d;gcop_/9p_89)>i,p_(d;ao@6?e|p:a|m_4+(>m1p==d;{b/p=e|p:a|m=.d(=elo+]t&>eo37?+m=/do_o+&{ylm_8d*<e|p6ti26?9n=/+n=o+&[2,m~ot*<a|p~2i;?6t&?69&+mln[gd&[ulp~/tmcg@66?9o_/9n+s+&[e1m~st*|e|p_e43a/dp_/9n[s9&{e|m]%t&?md;{f/p>i|p{y,m+4+*'a|p[e436|+;>e|p{2,m+s+*'a|p{ao7_b4p }t&?ud(~q,m}%d&?yd;gc4p7lx;>e|p{[1m;!d&?296_ji;>ao37|t&?qd(_elm;8d&?6t;{f4p6xx;/e|p+0|m}8d&>e1o61x;>a42f/t&?m9(_y|n_=+&:a(37}t;bk@6?a|p[#lm].d&<u1o6p}66|t;[f;p~a|p+#lm{/+m]%d;_vy;>a46[b/p?y+)~wd&|2,o7t#26+9;ckh;?<9n?wd&|6|o6li38@9;_jy26?+p};|p_0|o6h#3bc(n7di3cg4o_/dp</tm'=d;]ji'co@66,9&?&d)+a|o|=t;[ji3bo@6+by;'m|p|#|p~~1p7px6[ji3box;|q|p'#|p~~,p7h@6[ji3bkx;<u,n~/9m;kd&<;,p7d@6[ji3bc@;<2,n~/9m}/dm//9;bs@6[fy;/2|p'2|p?/tm8t@6[j/p}4d&?it*?a+)~/9m0d@6_n/p~0|p'u|p~<l&?y+:?mt(?&+&?e+)_/+p?a9(?~9&?e+)_/+p?a+(?&9&?e+)=/+p/~|p<e|p_<,&?<dp/4d&?qd&?e+)+/+p'<l&?~d&?e+)[/+p}<,&?<+p?.|p?m+)[/dp~"

ywin="a6b25e_tjf:tcnk06ojty2>gqhb24a}fnv'tln:tbz7{3i*e9?b2r;0#t/[te*we2@r{ruof~$_r7we#w/0q78[16f7}xu3e7px;32[#fz:tdbkr)37{4u*e6xh;2yu$gn:tcb.r)fb[x2*gwpb;[fog~f7r0g$rr/0r8ce.vawewt_}vxr;_n4e~3_qqi[#s/et7fky6.gh3t_]vawe!@_qri[#s/eq6gu#eng##fb]v;3fu1ryti42697qsmu#t/eq9k[zqo!fzx7}1ugf6h@;yaee~j7q7o:tcb.q#f$yri3f59*g$rb;_j(hcb'0pruy;b:2qu*gtp_]v~wf9dh;saxgcf:tenw0}b:2r23fy5_[v[wf8hx;2<[r8n@0[bb0x<>[5e71ra@e7lx;.ecypn0y;fz2sa:[run#wlr]z<wywa4299bi8>uq8*x0~br[q(>#v1b{w<]ywa428dh;ve=ypj!5qcherd${tc*#yx_[r<g.wao28lh;se8zlb!g{jb0ren0qd'[rk>#rdr]x0@1xm427hbi# uyr0we=fr[q!30td.[7c*et,_5$rb2ri(28ds.gnwe!f7yqihesdj]r(>g?3@zye427h=.djw2rq]e9fr2qan#qdz[6gn#5d>f?{hzya427ds1bj]2qmgf br2qin0rhk]ry>e?>}297b;_boi,$xe7rryrage7b72q2>erd.[z<}5]jge~3r;66!5qegf6jbyrawe~r_[segeu1_5?$xyze8z?fhe7bb<qmwe6nb2re]erd7yrm*e?>}5~b]e~nbi!>}2qege~d_yqege7bbu5a3f?>}5_3bi >x3qege~drzqi]e&*_5?{@f6q]5}fbysm!f(vrzr<}5<vbi0>x4re!e6f7y5iryxege_v_5?rxe~fbi0>}4re]e@jr.riwetfbytmwe?>}2tacz?*xuuigg%zbvrawe7r_5?n@e6q]5>fve6rrv32{2teges>}5[fbi0b}&:nl5rj_xz_he7j_5?vhe6ug2~g9&{j1m_(}e|${5~r_59@};[bsz_b|m_kx&{a|5?>}5<b468x@;bg/2 jh&~e1m[g9&_a|5[3/5?>h;dg(27xi;+v!2~gt&~mlm=kt&?j@;ek/5?:h;ag460h#;bc/20n@&~elm_ct&=i|5_j/77?}5/b467d;;ak(67phz[f|m_o9&?j@;jg/5?{@;ago67dy;cko39rx*~2|5=j/87?}5>f/67p#;]n]2~o+&~a|m_/@;oc/5?_x:a4/39j}*=2157?i67,@g?rh;doo66py;]j]2~wh&=a13~=x;c(/669@eyl_5_3(6@x@y=b13_kd&{b|4 ,@;bc/3r~*e?b436li;{b438j})+%};?fo67t}e4hr56xx;cc436xxy+b13~od&{b148?@29l@e5l3e<>/;{f]2~wh&+a13~!x;?r@;=b_}vh_46xh;dc436xxy+b13~od&{bl47x@|_f42r<*{q&h;{b/66xh;{f]2~wh&+a13~8h;+vo/9hh;_br{x03e'b436pi;{b436rh&{b|m~wh&}fo29?p<0dhevdr>uyne'b436pi;{b436rh&{b|m~wh&}n/?[p4ewh_>sqne'b436pi;{b436rh&{b|m~wh&}j/?]loevl7/rm3e:b436pi;{b436rh&{b|m~wh&qyx;?lr>qaoetlr?rmne:b436pi;{b/4~wh&+a13~gba[boe{pb>qipe[l7[r<p<qmne:b436pi;{b/4~wh&+a13~gr;+boe[d_<q2pe[l7[qi5f=l7<rine;bb;{b/66xh;|>|&ri/2qqpe?l)esdr<rm}e=fr<qine}fb;{b/66xh;?3xg6dx;=b_?;l7[qepe_fq2rexa~fb<qine]fb2)p/5}7r;_f42q<p/sene=db2aehasaha_ba2qapesdb3=&he?>x2xa(27hxe>d_<a2b[qm5g+bb<qe3e+fd&~#xe?>@2ve429hhe}db>qepasiha_bb[q#pe_pr<qa3e_nt&_6xe?>h3te(27d#;vipe[tb3qaxeqd7/q2peqdb2+qlm}f_5?zxe7lx;dc4e=zr<tyhe+a_>t2)e=y1m{f_5?7x;=fo77dr3x2xe[a_?=d7m:k92r<}5:jo271i;r<h3qeon?hpa_~,m~f_5?_@;hgoe?nxe7xd>r05m?gde?>}575i;r6hea2xe6di;{qpf[lt)=<}5?j};fc(e]f73ra466pd&_[)m|k+5?>@39ty;sqxe[jr;bcon~g+/+0,m?>}5'j477hr4raq;cgon~kd/[2,m?>}5/jo77pb3sio76t9&?e1n?>}5?jx;fk(fae(76x9(|<}5?>x389#;am/77xd('<}5?>h47,;;jg(n{8+5?>}5<fo979y;;m1o?>}5?{h;mgo879+&;<}5?>@e|f/875#;;m|nq[xe?>}5qaye'f/875y;:m|nr#}e?>}5qe#e:j4871#;:m|nr6@ebc_5?vhe;b_6r6@;jg478hho+.9e}f_6q<}5{bb4qqie[b_289y;do(2;i|nsehe=rr6r<}5{f_3qeif=fb3)h(e=79&}ir2qa}e_hb6q<}5]f_3tm5f{>7e=79&]mb2tu)e?>@3r2@e]p_3wmxf=3+&]e72s25e?>@3qaie]fr/r2@f+nr;=fd&[m1naqxe;d_5?3heagr3qype+d_3wm@e8lxm:kt&~uhe:d_5?3hebcr3q&pe;n(f8di;=f9)~uhe+db>q<}5}br6qm}e=d_<qepe_j+26l;:cc(2_~,m{br>qipe?>@3qiye~br2qape}dr<qa}m+fo96lxm|ot3q0pe~j_5?jhebwr2qape=p7<qahm_cd36xi;fc(2_&|m{br<qy)e~d_5?fhf=lr2r0pe_elm[b476xi;=f9(+yhe_d7>qe5e]j_5}jr>rmha}drm_gd36xi;fc(2=6ln~f+2qepf=db<ry}e?zxe;db2_exe[hbm=ct36xi;fc/2+q1n_nt2q6?e{fr6q<h3rahe{d7<qa@m_zrm_gd3qeo76p#;+brp_bt&~exe]h_2qixecc_5[nr<qype~n92=q1m{f_'rixed792~i|mxmxe~j76r<h3rape:dbn=ft*_q}hrexejbb3_qln}3b6q<@3sype_d7m~gd2=ulm[>_e~b7srm@m}.t2sm)e?3@e{dr<qad&~aln{gd35mb2q&ee{j9(_exe]h_5}fr<qipe_dr&~&1m[>rflbr3=0|m~b7<qqpe?7xe_lr<qad&=&lm[>rflbr3_2|m~gd2qupe_d_5=rt2qupe~elm~jt(_m}hvqeefbr3_u1n~gd2q6pe?jhm=gt2sepa_a1m~rd(_m}hviuefbb3=u1m_bt&_ahe_db>u<xm=wte_e1m=n+*_qhg~3r2wmue[jd*_ihm_gd2qe?e_dr<r<x2_u|m=gd3_6,m{rr3s6xf~zd*=ixm~gd2q2?e?r}m;gt3_01m?>x2_a|m{k92_a,mru)e?3xn{gt3_#lm?>x2_#1m+f9&=y72=<@3=u1m]b+&}<}5_jt(~uxm+sde{alm?7xm[g93_ilm?>@4]mlm{f+*{e1m? hm{c93_e1m?>}5~f9&~uxm>k+5'fd*_uxn?>}5~f9&~uxm's+5|fd*=u@m?>}5=jt&~uxm}s+5?bt*[<}5? hn{b+*=<}5=bd(_<}5?$}m[f9*_<}5_n9&}<}5?>@2=ylm?>@2_q|n?>}5?b@m}g+5?jxm+g+5?>}5}f9&~q1m?>@2_i1m?>}5? hn+g+5?nxn?>}5?_@m+c+5?v}m?>}5?>hm=g+5?>}5?>}5:jd&_<}5?>}5?>x4[<}5?>}5?>}4=<}5?>}5?>}5?>}5?>}5?>}5?>}5?>}5?>}5?>}5?>}5?>}5?>}5?>}5?>}5?>}5?>}5?>}5?>}5?3h2"

_n=nil _0=false _1=true hu=0

first=1

wingame=0

gameovr=0

fadedir=0 fadepos=0

scrn={}

butn={} butc={} nobutn=0
for i=0,5 do
  butc[i]=0
end

gamename="christmas present panic"

colorset={4,0,8,14,0,10}

lev={}
lev[1]={1,1,1,1,1,1,1,1,1,1,1,1}
lev[2]={2,2,2,2,2,2,2,2,2,2,2,2}
lev[3]={3,3,3,3,3,3,3,3,3,3,3,3}
lev[4]={1,1,2,1,1,2,1,1,2,1,1,2}
lev[5]={1,2,1,2,1,1,2,1,2,1,2,1}
lev[6]={2,2,3,2,2,3,2,2,3,2,2,3}
lev[7]={2,3,2,3,2,3,2,3,2,3,2,3}
lev[8]={1,2,3,1,2,3,1,2,3,1,2,3}
lev[9]={1,3,2,3,1,3,2,3,1,3,2,3}
lev[10]={1,1,2,1,2,2,3,2,3,3,1,3}

sc=0

wontext=decrypt(wontext)

::hi_scores::

skip=0

loadscores()

if gameovr==1 and wingame==0 then
  hiscore(1,nam,sc)
  savescores(scores)
  gameovr=0
elseif first==1 then
  fadeout()
  fadedir=-1
  hiscore(0)
end

loadscores()

men=3

bigt=0

box={}

hit=0

tmo=rand(60,120) tms=120

mx=1 mxa=.5

ce=0 hx=60 hsx=0 hsy=0

boxc=1 cea=.1

bt4=0

perf=1

bonc=0

nokey()

if first==1 then

fadeout()
fadedir=-1
t=0
b=rnd(128)
c=0

repeat
 cls()
 spr(128,36,0,7,2)
 prit(16,"presents",7,0)
 prit(36,"dw817",7,0)
 prit(60,"chris",7,0)
 prit(84,"scrub",7,0)
 prit(108,"cable",7,0)
 for i=0,127 do
  for j=0,127 do
   if(pget(j,i)==7) pset(j,i,(i+t)%6+8)
  end
 end
 spr(137,58,24,1.5,1.5)
 spr(141,58,48,1.5,1.5)
 spr(135,58,72,1.5,1.5)
 spr(139,58,96,1.5,1.5)
 prit(42,"programmer+pixelart",7,0)
 prit(66,"artist+illustrations",7,0)
 if(b>1) prit(90,"titles+musician",7,0) else prit(90,"boom operator",7,0)
 prit(114,"crosscheck+writer",7)
 t-=0.7
 c+=1
 if (c==30) music()
 flp()
 holdframe()
until btn(4)
nokey()

end

if (debug) goto skip

if (story>"") tellmeastory(story)
story=""

pal()
fadepos=0
if wingame==1 then
  decompres(ywin)
else
  decompres(logo)
end

if wingame+first>0 then
  for i=0,255 do
    for j=0,i do
      pset(i-j,j,i+j)
    end
    pause(2)
    for j=0,i do
      pset(i-j,j,sget(i-j,j))
    end
  end
end

reload()

if wingame==0 and first==1 then
  pause(40) sfx(52)
  prit(69,gamename,7)
  pause(40)
  sfx(58)
  prit(120,"press a key to begin",7)
  music(1)
elseif wingame==1 then
  music(3)
  waitkey()
end

if first==1 then
  waitkey()
end

if wingame==1 then
  tellmeastory(wontext)
  k=""
  hiscore(1,nam,sc)
  savescores(scores)
  if k=="o" then
    hiscore(0)
  end
  gameovr=0
  wingame=0
end

::skip::

if wingame==1 then
  hiscore(nam,sc)
  wingame=0
  goto hi_scores
end

cls()color(7)
fadedir=-1
fadeout()
fadedir=-1

c=0
sfx(52)
repeat
  cls()
  if c%4<2 then
    prit(61,"press 1 player button",7)
  end
  c+=1
  getkey()
  flp()
until anybutn
nokey()
sfx(58)
fadeout()
fadedir=-1
first=0
sc=0
music(7)
repeat

if (hit==-1) sfx(51)

update()

spr(27+perf,81,0)

for i=2,men do
  spr(26,80-i*8,0)
end

sspr(16,8,16,16,mx,9)

spr(10,0,ce*6+cea+13)
spr(13,120,ce*6+cea+13)

if cea>0 then
  if ce==10 then
    wongame()
    cls()
    goto hi_scores
  end
  cea+=.1

  poke(16676,cea+ce*6)
  sfx(57)

  if cea>=6 then

    mxa=.5+ce*.05

    cea=0

    ce+=1

    sfx(56)

    perf=1

    bigt=0

bonc=0

  end

  bigt=0
end

for i=1,14 do
  spr(11+mx%2,i*8,ce*6+cea+13)
end

if (hit==1) sfx(59)

if (hit>0) hit+=1

if (hit==80) hit=-1 men-=1

if men==0 then
  gameover()
  goto hi_scores
end

if hit>=0 then
  spr(52+hit/16,hx,116)
else

  sspr(100,18,8,12,hx-1,114)
end

if (btn(3) and ce<=3) hit=-1

if hit<=0 then
  if (btn(0)) hx-=1
  if (btn(1)) hx+=1

  if ((btn(5) and bt4==0) or btn(4)) and hsy==0 and hit<=0 then

    hit=0

    hsy=112

    hsx=hx+1

    sfx(63)

    bt4=1

  elseif btn(4)==false and btn(5)==false then

    bt4=0
  end
end

if hsy>0 then

  spr(58,hsx,hsy)

  hsy-=2


  v=ce*6+18

  if (bonc==0) v=0
  if hsy<=v then

    hsy=0

   if (#box>0) perf=0

  end
end

hx=mid(0,hx,120)

mx+=mxa

if (mx<1 or mx>111) mxa=-mxa

if bigt==1500 then

  addbox(mx+3,18,4)

end

bigt+=1

if (bigt>1500) bigt=1501

if tmo>0 then
  tmo-=1
else

  if tms>0 then
    tms-=1

  elseif boxc>0 then

    if ce>0 then
      addbox(mx+3,18,lev[ce][boxc])
    end

    tms=(10-ce)*10

    boxc+=1

    if (boxc==13) boxc=0
  end
end  

for i in all(box) do

  if i.a<2 then

    if (i.t==3) sfx(60)

    i.x+=i.ax
    i.y+=i.ay

    spr(1+i.t*2+i.a,i.x,i.y)

  else

    spr(34+i.a,i.x,i.y)
    i.a+=.1
    if i.a>=10 then

      del(box,i)

      sc+=(i.t+1)*10

      if (i.t==3) sc+=60

      if #box==0 then

        tmo=rand(60,120)+60*ce

        boxc=1

        cea=.1

        if perf==1 then

          sfx(55)

          perf=2

          men+=1

        end
      end
    end
  end

  if abs(hx-i.x-3)<5 and i.y>=112 and hit==0 then

    hit=1

  end

  if hsy>0 then
    if abs(hsx-i.x-3)<5 and abs(hsy-i.y)<6 and i.a<2 then

      sfx(62)

      i.a=2
      hsy=0

      if (i.t==3) bigt=0

    end
  end

  if i.x>=120 or i.x<=0 then
    i.ax=-i.ax
  end

  if i.y<=ce*6+18 or i.y>=120 then

    if i.t==3 and i.y>=120 and hit>=0 then

      hit=1
    end

    if i.y>=120 or (i.y<=ce*6+18 and i.ay<0) then
      i.ay=-i.ay

      if (i.ay<0) bonc=1

    end
  end

  if i.a<2 then
    i.a=(i.a+.1)%2
  end
end

if perf==2 then
  print("perfect! bonus man",28,60,7)
end

flp()

until forever

end

function decrypt(t)
local chr,asc,alph,r,c={},{},"abcdefghijklmnopqrstuvwxyz",""
  for i=0,25 do
    c=sub(alph,i+1,i+1)
    chr[i]=c asc[c]=i
  end
  for i=1,#t do
    c=sub(t,i,i)
    if asc[c]!=nil then
      r=r..chr[(asc[c]-1)%26]
    else
      r=r..c
    end
  end
  return r
end

function tellmeastory(t)
local v=8
  for i=1,17 do
    t="\n"..t
  end
  pal()
  pal(15,0,1)
  repeat
    cls() clip()
    prit(122,"press Ž faster — exit ",1)
    sspr(16,24,8,8,0,114,128,8)
    sspr(16,24,8,8,0,0,128,8)
    clip(0,8,128,105)
    print(t,1,v+1,1)
    print(t,0,v,12)
    v=v-.1
    if (btn(4)) v=flr(v)
    for i=0,15 do
      spr(48,i*8,106)
      spr(49,i*8,8)
    end
    flip()
  until btnp(5)
  cls()
  fadedir=-1
end

function wrap(a,b,c)
  if (b>c) b,c=c,b
  repeat
    if (a<b) a+=c-b+1
    if (a>c) a-=c-b+1
  until a>=b and a<=c
  return a
end

function yank(t)
local r
  t=t..","
  r=sub(t,1,instr(t,",")-1)
  t=sub(t,instr(t,",")+1)
  if (t==",,") t=""
  return r,t
end

function instr(a,b)
local i,r=0
  if (a==nil or a=="" or b==nil or b=="") return 0
  for i=1,#a-#b+1 do
    if (sub(a,i,i+#b-1)==b) return i
  end
  return 0
end

function vlenx(t)
local r,x,y,c=0,0,1
  for i=1,#t do
    c=sub(t,i,i)
    if c=="," then
      x=0 y+=1
      doubvlenx=0
    else
      x+=1
      if (doubvlenx==1) x+=1
      if (r<x) r=x
    end
  end
  doubvlenx=0
  if vlenyflag then
    return y
  else
    return r
  end
end

function menu(t)
local c,mh,mv,mx,my,m,n,mo
doubvlenx=1
local x,y,mop=vlenx(t),0,{}
local rep,fra="",{0,2,8,9,0}
local ov=0
  nokey()
  repeat
    mop[y],t=yank(t)
    y+=1
  until t==""
  mo=mop
  mx=x*4+14
  my=y*10+10
  mh=62-mx/2
  mv=62-my/2
  y-=1
  for i=mv,mv+my do
    for j=mh,mh+mx do
      n=pget(j,i)
      rep=rep..chr6[n]
    end
  end
  for i=0,5 do
    rectfill(mh+i,mv+i,mh+mx-i,mv+my-i,colorset[i])
  end
  c=colorset[6]
  for i=0,y do
    print(mop[i],mh+7,mv+7+i*10,c)
    c=6
    if i==0 then
      m=#mop[0]
      for j=0,4 do
        for l=m*4-1,0,-1 do
          line(mh+7+l*2,mv+7+j,mh+7+l*2+1,mv+7+j,pget(mh+7+l,mv+7+j))
        end
      end
    end
  end
  v=1
  x=mx-12
  m=y
  enflag=1
  sfx(52)
  repeat
    for i=0,1 do
      for j=0,6 do
        for l=0,mx-12 do
          x=mh+6+l
          y=mv+6+v*10+j
          pset(x,y,6-pget(x,y))
        end
      end
      if (i==0) waitkey()
    end
    if (butn[0] or butn[2]) v-=1
    if (butn[1] or butn[3]) v+=1
    if (v!=ov) ov=v sfx(54)
    v=wrap(v,1,m)
  until butn[4]
  x=1
  for i=mv,mv+my do
    for j=mh,mh+mx do
      n=asc6[sub(rep,x,x)]
      pset(j,i,n)
      x+=1
    end
  end
  k=sub(mop[v],1,1)
  enflag=0
  sfx(58)
  pause(10)
end

function trim(a)
  local b,c,d=0,0
  for i=1,#a do
    d=#a-i+1
    if sub(a,i,i)!=" " and b==0 then
      b=i
    end
    if sub(a,d,d)!=" " and c==0 then
      c=d
    end
  end
  return sub(a,b,c)
end

function charset(a,b,c)
  return sub(sub(a,1,b-1)..c..sub(a,b+1),1,#a)
end

function loadscores()
  scores=""
  for i=1,255 do
    c=peek(24063+i)
    if c!=0 then
      scores=scores..chr6[c-1]
    else

      break
    end
  end
end

function savescores(t)
  for i=0,62 do
    dset(i,0)
  end

  dset(63,1234.5678)

  for i=1,#t do
    poke(24063+i,asc6[sub(t,i,i)]+1)
  end
end

function nano()
local hue,c={1,13,14,15,14,13,1,2,8,14,15,14,8,2,4,9,10,15,10,9,4,3,11,15,11,3,1,13,12,15,12,13}
  for i=0,127 do
    for j=0,127 do
      if scrn[j][i]>0 then
        c=hue[flr((i+j+hu)/4)%32+1]
        pset(j,i,c)
      end
    end
  end
  flp()
  getkey()
  hu=(hu+1)%128
end

function pad(a,b)
  for i=#a+1,b do
    a=a.." "
  end
  return sub(a,1,b)
end

function hiscore(mode,name,score)
local so,scs,sc,hue
local spe,p,l,m,r,t1,t2,rv,n,c,v,e,x,y,ox,ok,t={},1,#gamename*2,0,0,"",""
  nokey()
  so,scs={},scores
  for i=1,10 do
    spe[i]=0
  end
  if (tostr(name)==_n) name=""
  if (tonum(score)==_n) score="0"
  cls()
  rect(1,1,126,126,7)
  rect(127,127)
  print("all time greatest",30,32)
  if score>"0" then
    scs=scs..",*,"..score
  end
  scs=scs..","
  e=0
  for i=1,#scs do
    c=sub(scs,i,i)
    if c=="," then
      m=1-m
      if m==0 then
        so[p]=""
        if t2==score and sub(t1,1,1)!="@" and e==0 then
          t1="*"
          e=1
        end
        for j=#t2+1,5 do
          so[p]=so[p].." "
        end
        if sub(t1,1,1)=="@" then
          t1=sub(t1,2)
          spe[p]=1
        end
        so[p]=pad(so[p]..t2..t1,16)
        t1="" t2="" p+=1
      end
    else
      if m==0 then
        t1=t1..c
        if e==1 and c=="*" then
          break
        end
      else
        t2=t2..c
      end
    end
  end
  repeat
    ok=1
    for i=1,#so-1 do
      if so[i]<so[i+1] then
        so[i],so[i+1]=so[i+1],so[i]
        ok=0
      end
    end
  until ok==1
  c=#so
  if (c>=11) so[11]=_n c=10
  y=6+11-c r=0
  v=(72-(y*c/2))-(10-c)*.5
  for i=1,c do
    if sub(so[i],6,6)!="*" then
      print(sub(so[i],6),30,v+i*y)
    end
    print(sub(so[i],1,5),78,v+i*y)
    if sub(so[i],6,6)=="*" then
      rv=v+i*y
      r=i
    end
  end
  if (r==0) mode=0
  for j=0,127 do
    scrn[j]={}
    for i=0,127 do
      c=0
      if (pget(j,i)>0) c=1
      scrn[j][i]=c
    end
  end
  print(gamename,64-l,15,colorset[6])
  for i=0,4 do
    rect(56-l+i,8+i,70+l-i,26-i,colorset[i])
  end
  line(30,38,96,38,5)
  if mode==0 then
    print("press —+Ž to reset scores",10,117,1)
  else
    print("enter in your name",28,117,1)
    t=sub(so[r],6) x=0 hu=4
    if sub(t,1,1)=="*" then
      if name=="" then
        t=pad("a",11)
      else
        t=pad(name,11)
      end
    end
    for i=11,1,-1 do
      c=sub(t,i,i)
      if (c!=" " and x==0) x=i
    end
    y=asc6[sub(t,x,x)]
    x-=1 ox=0
  end
  repeat
    nano()
    if mode>0 then
      c=8
      if butn[4] or (nobutn==7 and hu%16<8) then
        c=0
      end
      if mode>0 and butn[4]==false then
        rectfill(29+ox*4,rv-1,33+ox*4,rv+5,0)
        ox=x
      end
      rectfill(29+x*4,rv-1,33+x*4,rv+5,c)
      if butn[0] and x>0 then
        t=charset(t,x+1,chr6[y])
        y=asc6[sub(t,x,x)]
        x-=1
        sfx(53)
      elseif (butn[1] or butn[4]) and x<10 then
        x+=1
        t=charset(t,x,chr6[y])
        y=asc6[sub(t,x+1,x+1)]
        sfx(53)
      elseif butn[2] then
        y-=1
        sfx(54)
      elseif butn[3] then
        y+=1
        sfx(54)
      end
      if butn[5] then
        y=37
        t=charset(t,x+1," ")
        sfx(60)
      end
      y%=38
      print(chr6[y],30+x*4,rv,7)
      print(sub(t,1,x),30,rv,7)
    else
      if btn(4) and btn(5) then
        menu("reset,okay,cancel")
        if k=="o" then
          scores=mastscores
          savescores(scores)
          hiscore(0)
          return
        end
      end
    end    
  until butn[4]
  if mode==1 then
    x-=1
    c=sub(t,1,x+1)
    so[r]=sub(so[r],1,5)
    so[r]=so[r]..pad(sub(c,1,x+1),11)
    t=""
    for i=1,10 do
      if spe[i]==1 or i==r then
        t=t.."@"
      end
      t=t..trim(sub(so[i],6))..","
      t=t..trim(sub(so[i],1,5))
      if (i<10) t=t..","
    end
    c=trim(c)
    name=c
    if name=="" then
      name="no-name"
    end
    menu(name.."?,okay,cancel")
    if k=="c" then
      menu("skip?,okay,cancel")
      if k=="c" then
        hiscore(1,name,score)
        return
      end
    else
      scores=t
      sfx(58)
    end
  end
end

function fadeout()
  fadedir=1
  for i=0,21 do
    flp()
  end
end

function fadein()
  fadedir=-1
  for i=0,21 do
    flp()
  end
end

function fade()
local fade,c,p={[0]=0,17,18,19,20,16,22,6,24,25,9,27,28,29,29,31,0,0,16,17,16,16,5,0,2,4,0,3,1,18,2,4}
  pal()
  for i=0,fadepos do
    if i%2==1 then
      for j=0,15 do
        c=peek(24336+j)
        if (c>=128) c-=112
        p=fade[c]
        if (p>=16) p+=112
        pal(j,p,1)
      end
    end
  end
  fadepos+=fadedir
  if (fadepos<0) fadedir=0 fadepos=0
  if (fadepos>21) fadedir=0 fadepos=21
end   

function getkey()
local b
  if butn==_n then
    butn={} butc={}
    for i=0,5 do
      butc[i]=0
    end
  end
  anybutn=_0
  for i=0,5 do
    butn[i]=_0
    if btn(i) then
      nobutn=0
      butc[i]+=1 b=butc[i]
      if b==1 or (b>16 and b%3==1) then
        butn[i]=_1
        anybutn=_1
      end
    else
      butc[i]=0
    end
  end
  if anybutn==_1 then
    nobutn=max(nobutn-1,0)
  else
    nobutn=min(nobutn+1,7)
  end
end

function waitkey()
  nokey()
  fadedir=-1
  repeat
    getkey()
    flp()
  until anybutn
end

function prit(y,t,p,no)
local o,e,c={[0]=-1,-1,0,-1,1,-1,-1,0,1,0,-1,1,0,1,1,1,0,0},0
  if (no!=nil) e=8
  for i=e,8 do
    if (i==8) c=p
    print(t,64-#t*2+o[i*2],y+o[i*2+1],c)
  end
end

function pause(n)
  if (debug or skip>0) n=0
  for i=1,n do
    if (btn(4)) skip=5
    flp()
  end
  if (skip>0) skip-=1
end

function nokey()
local c=0
  repeat
    for i=0,5 do
      if (btn(i)==true) c=0
    end
    c+=1
  until c==16
  for i=0,5 do
    butn[i]=false
  end
end

function wongame()
  music(-1)
  fadeout()
  fadedir=-1
  if (nam==nil) nam=""
  sc+=500
  sc=""..sc
  wingame=1
  gameovr=1
end

function gameover()
local snow,b={}
  music(-1)
  nokey()
  for i=1,100 do
    b={}

    b.x=rnd(128)
    b.y=rnd(128)
    b.ax=-1+rnd(2)
    b.ay=.5+rnd(.5)
    add(snow,b)
  end
  fadeout()
  cls()
  fadedir=-1
  music(5)
  repeat
    update()
    for i in all(snow) do
      pset(i.x,i.y,7)
      i.x+=i.ax i.y+=i.ay
      if (i.x<0 or i.x>127) i.x=127-i.x
      if (i.y>127) i.y=0
    end
    sspr(0,32,40,24,44,52)
    flp()
  until btnp(4)
  pal()
  fadeout()
  fadedir=-1
  if (nam==nil) nam=""
  sc=""..sc
  gameovr=1
end

function update()
  cls()color(7)
  ?"score="..sc
  if ce>0 then
    print("ceiling="..11-ce,89,0)
  end
end

function addbox(x,y,t)
local sx,sy,b=1,1,{}
  b.x=x
  b.y=y
  if (t==2) sx=1.5
  if (t==3) sy=1.5
  if (t==4) sx=0 sy=.5
  b.ax=sx

  if (rnd()<.5) b.ax=-sx
  b.ay=sy
  b.t=t-1
  b.a=0
  add(box,b)
end

function decompres(t)
local b,p,c,n=0,1,0,0
  for i=-1,16383 do
    if n>0 then
      n-=1
    else
      c=0
      for j=0,7 do
        if band(asc6[sub(t,p,p)],2^b)>0 then
          if j<4 then n+=2^j else c+=2^(j-4) end
        end
        b+=1 if (b==6) p+=1 b=0
      end
    end
    sset(i%128,i/128,c)
  end
end

function flp()
  fade()
  flip()
end

function rand(a,b)
  if (a>b) a,b=b,a
  return a+flr(rnd(b-a+1))
end

main()
__gfx__
00000000000011000011000000002200002200000000330000330000dcd0fef0dcd0fef008000000000500000000000000000000000050000000055555000000
0000000000d6d100001d6d00008682000028680000b6b300003b6b00cdc2efe0cdc2efe008000000505000000000000000000000000005050005566666550000
0070070011d7ddd00ddd7d11228788800888782233b7bbb00bbb7b33dcd2fef0dcd2fef008000000606500000000000000000000000056060056600000665000
000770001ddee760067eedd1288ff760067ff8823bbaa760067aabb3022822000227220008880000707776507676767667676767056777070560000000006500
00077000067eedd11ddee760067ff882288ff760067aabb33bbaa760fef2dcd0fef2dcd008888000606500000000000000000000000056060560aa9998806500
007007000ddd7d1111d7ddd008887822228788800bbb7b3333b7bbb0efe2cdc0efe2cdc008888000505000000000000000000000000005055600aa0000800650
00000000001d6d0000d6d1000028680000868200003b6b0000b6b300fef0dcd0fef0dcd000000000000500000000000000000000000050005600bb0000000650
00000000001100000000110000220000000022000033000000003300000000000000000006777600000000000000000000000000000000005600bb0000000650
55555555555555500055555555555000dcd0fef000000000000000000006000000006000000000000028e8200151510008787800000000005600cc0000000650
50000000000000500567777777776500cdc2efe00044000000004400006060000006060000000000028e82070515150007878700000000005600cc0000f00650
55505550555055505677c77777c77650dcd2fef00445400000045440060776000067706000000000066666000051500000787000000000000560ddeeeff06500
5050500000505050577ccc777ccc77500222220004544400004445406077776006777706000000007fcfcf700005000000070000000000000560000000006500
50505050505050505777777777777750fef2dcd00044544004454400067777766777776000000000777f777000010000000d0000000000000056600000665000
5000505050500050577ccc777ccc7750efe2cdc00004445005444000006777600677760000000000777777700015100000ded000000000000005566666550000
55555050505555505777c77777c77750fef0dcd00000450000540000000676000067600000000000077f770000010000000d0000000000000000055555000000
50000055500000505787777777778750000000000000000000000000000060000006000000000000007770000000000000000000000000000000000000000000
555550505055555057887777777887500000770000007700000077000000c70000000c0000000000000000000000000000000000000000000000000000000000
5000505050500050578e8877788e8750007777000077770000c77700000c77000000c70000000c00000000000000000000000000000000000000000000000000
50505050505050505778ee888ee8775077777770c77777700c77777000c77770000c77700000c7c000000c00000000000000e2e2e00000000000000000000000
5050500000505050577788eee88777507777777077777770c77777700c77777000c777c0000c7c000000c0000000c00000002000200000000000000000000000
5550555055505550567777888777765007777777077777770777777c077777c00c777c0000c7c000000c0000000c00000000e080e00000000000000000000000
50000000000000500567777777776500077777770777777c077777c007777c000777c0000c7c000000c000000000000000002070200000000000000000000000
55555555555555500055555555555000007777000077770000777c000077c000007c000000c0000000000000000000000000e080e2e200000000000000000000
00000000000000000000000000000000007700000077000000770000007c000000c0000000000000000000000000000000002070000e00000000000000000000
000f0000ffffffff111111110000000007000000700000000000000000000000000000000000000070000000000000000000e080070200000000000000000008
0f000f00fff0ffffdddddddd00000000080000000080000070000000000000000000000000000000600000000000000000002070080e00000000000000000088
f00f00f0f0fff0ffeeeeeeee0000000007000000700000000080000000000000000000000000000060000000000000000000e008700200000000000000000888
f0f0f0f00ff0ff0f7777777700000000080000000080000070000000708000000000000000000000400000000000000000002e00002e00000000000000008888
0ff0ff0ff0f0f0f0eeeeeeee000000000700800070000800008000007000000077000000000000004000000000000000000002e2e2e000000000000000088888
f0fff0fff00f00f0dddddddd00000000080070000087000070000080708000007880000078800000500000000000000000000000000000000000000000888888
fff0ffff0f000f001111111100000000007800000700800007878000078780800787808077887880500000000000000000000000000000000000000008888888
ffffffff000f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088888888
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00001177771011111111111111001111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00011717111017117771717771101777110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00017117771111711711171717101711711100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00017117117111771710171717101717117100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00017117117117111710171117101771171100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00011711171117117711171117111711711000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00001177711011771771117111711177110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000111110001111111011101110111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00001177711011100000111110000111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00011717171117111111177711001171711100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00017117717117717771171171111777177100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00017117117111711711171711711171111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00017117717101711710177117111171110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00011717171101177710171171101771710000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00001177711000117110117711001177110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000111110000011100011110000111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007770000077700077777000007770007777777077777000700000700000ccf0000000000880008000000000000000010000000000000a000000000000000000
07000700070007007000070007000700700000007000070070000070000ccccf00000000018800800000000000000010000000000000baa00000000000000000
7000007070077070700000707000007070000000700000700700070000ccccccf000000000888088000000000144444441000000000bbaaa0000000000000000
7000007070007070700000707000007070000000700000700700070000cc000cf00000000018888880800000014161dd4100000000bbbbaaa000000000000000
7000000070000070700000707000007070000000700000700070700000cc808cc00000000888888888100000014dd661410000000bbb33baaa00000000000000
7000000070000070700000707000000070000000700000700070700000cc000cc000000018888f888100000001416dd641000000033b333baa00000000000000
07000000700000707000070070000000700000007000070000070000000ccfcc00000000018fcfcf100000000146dd16410000000333b33bbb00000000000000
0077700070000070777770007000000077777000777770000007000000ccc8ccf0000000001fcfcf10000000014616dd4100000000333bbbb000000000000000
0000070070000070700700007000000070000000700700000007000001ccc1cccf000000008fffff800000000144444441000000000333bb0000000000000000
0000007070000070700070007000000070000000700070000007000001ccc1cccf0000000010fff0100000000111111111000000000033b00000000000000000
00000070700000707000700070000070700000007000700000070000111cc1ccccf00000000fffff000000001111111111100000000003000000000000000000
70000070700000707000070070000070700000007000070000070000000000000000000000000000000000000000000000000000000000000000000000000000
70000070700000707000070070000070700000007000070000070000000000000000000000000000000000000000000000000000000000000000000000000000
07000700070007007000007007000700700000007000007000070000000000000000000000000000000000000000000000000000000000000000000000000000
00777000007770007000007000777000777777707000007000070000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
010c0000023000030002300003000e3000230000300023000030000300003000030000300003000130000300023000030002300003000e3000230000300023000030000300003000030000300003000130000300
010800001d5501d5501d5501d5401d5401d5401d5301d5301d5501d5301d5201d5101c5501c5501c5501c5401c5401c5401c5301c5301c5301c5201c5201c5201c5101c5101c5101c51000500005000050000500
01080000225502255022550225502254022540225402253022530225502253022520225101f5501f5501f5501f5401f5401f5401f5301f5301f5301f5201f5201f5201f5101f5101f5101f510005000050000500
010800001855018550185501855018550185401854018540185301853018550185301852018510185501855018550185401854018540185301853018530185201852018520185101851018510185100050000500
010800000c5500c5500c5500c5500c5500c5400c5400c5400c5300c5300c5300c5300c5200c5100c5500c5500c5500c5400c5400c5400c5300c5300c5300c5200c5200c5200c5100c5100c5100c5101f0001f000
010c000021300000002130000000213000000000000000002130000000213000000021300000000000000000213000000021300000001d300000001f300213000000000000000000000000000000000000000000
010400002400024000240002400024000240002400024000240002400024000240002400024000240002400024000240002400024000240002400024000240002400024000240002400024000240002400024000
010800002775527720287552a7552a7202a7202a7552a7202a7202a7202a7202a7552c7552c7202e7552f7552f7202f7202f7552f7202f7202f7202f7202f7202775527720287552a7552a7202a7202a7552a720
010800002c7552c7202e7552e7202f7552f7202f7202f7202f7202f72023755237202372023720237202372027755277202772027720277202772027720277202772027720277202772027720277202772027720
010800001715517120171221712217122171221712217122171221712217122171551515515122151221512215122151221512215122151221512215122151551415514122141221412214122141221412214122
010800001412214122141221415513155131221312213122131221312213122131221312213122131221312212155121221212212122121221212212122121221212212122121221212212122121221212212122
010800002775527720287552a7552a7202a7202a7552a72029755297202a7552c7552c7202c7202c7552c7202a7552a7202c7552d7552d7202d7202d7552d7202c7552c7202d7552f7552f7202f7202f7552f720
01080000171551712217122171221712217122171221712219155191221912219122191221912219122191221a1551a1221a1221a1221a1221a1221a1221a1221c1551c1221c1221c1221c1221c1221c1221c122
010a00002e7552e7202e7202e7202e7202e7202e7202e7202e7202e7202e7202e7202e7202e7202e7202e72000000000000000000000000000000000000000000000000000000000000000000000000000000000
010a00001e1551e1221e1221e1221e1221e1221e1221e1221e1221e1221e1221e1221e1221e1221e1221e12200000000000000000000000000000000000000000000000000000000000000000000000000000000
010800002775527720287552a7552a7202a7202a7552a720267552672027755297552972029720297552972025755257202675528755287202872028755287202475524720257552775527720277202775527720
010800002375523720237202372023720237202372023720237202372023720237202372023720237202372023720237202372023720237202372023720237202372023720237202372023720237202372023720
010800001715517122161551612215155151221415514122161551612215155151221415514122131551312215155151221415514122131551312212155121221415514122131551312212155121221115511122
010800001215512122121221212212122121221212212122121221212212122121221212212122121221212212122121221212212122121221212212122121221212212122121221212212122121221212212122
010c0000021500010002150001000e1500215032005021502600500100001500010000150001000115000100021500010002150001000e1500215026005021502600500100001500010000150001000115000100
010c000021755217202175521720217552172021720217202175521720217552172021755217202172021720217552172021755217201d7551d7201f755217552172021720217202172021720217202172021720
010c000005150001000515000100111500515000100051500415000100041500010010150041500110004150021500010002150001000e150021500010002150011500010001150001000d150011500110001150
010c00002275522720227552272022755227202275522720227552272021755217202175521720217552172021755217202075520720207552072020755207202175521720217202172021755217202172021720
010c0000207161a726207361a746207561a746207361a7262071600700207160070020716007000070000700217161a726217361a746217561a746217361a7261a726007061a726007061a726007060070600706
010c0000227161d726227361d746227561d746227361d7262271600700227160070022716007000070000700217161a726217361a746217561a746217361a7261a726007061a726007061a726007060070600706
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
011000001305200002150520000217052000021505200002130520000215052000021705200002000020000213052131520000213052131520000200002000021305213152000021305213152000000000000000
01100000150722400024000240001107224000240002400010072240002400024000090722400024000240000e072090520e072090520e072090520e072090521007224002000000000000000000000000000000
010200001851119511185111951118511195111851119511185111951118511195111851119511185111951118500195011850119501185011950118501195011850119501185011950118501195011850119501
010300003c074000003c044000003c014000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200003351500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200003f51500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00003017524075301752407530175240753017524075000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800003c0533f05311000000003c0533f05300000000003c0533f05300000000003c0533f053000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000c05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400002457530575305553053530515000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c0000306503c650000000000024640336400000000000186302463000000000000c620246200000000000006100c6100000000000006100061000000000000000000000000000000000000000000000000000
010200002661500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000003c55530555005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800001355313003185430c0032b53313003305230c003375130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200003c0513904137031300212d0113c0003c0000c001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
04 01 02 03 44
00 07 09 43 44
04 08 0a 43 44
00 0b 0c 43 44
04 0d 0e 43 44
00 0f 11 43 44
04 10 12 43 44
01 13 14 43 44
00 13 14 43 44
00 15 16 43 44
00 13 14 43 44
00 13 14 43 44
00 15 16 43 44
00 13 17 43 44
00 13 17 43 44
02 15 18 43 44
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
