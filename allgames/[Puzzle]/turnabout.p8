pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
-- turnabout v.1.0
-- by peter antoine

function _init()
    levels =  
    {
       --[[001]] "F59X08F06xF06xF06xF06xF06xF06xF06xr.xs..xF06X08F59", 
       --[[002]] "F44X09F05xr..x..rxF05xx..x..xxF06xF05xF07xF05xF06xxF05xxF05xF07xF05X09F45", 
       --[[003]] "F30X10F04xF06xxxF04x.X04.xxxF04x.xx.x.xxxF04x.xsF05xF04x.xx.x.x.xF04x.x..x.x.xF04x.xF06xF04xrx.X04.xF04X10F30", 
       --[[004]] "F45X08F06x...x..xF06x.xrxs.xF06x.X04.xF06x.x.xx.xF06x.x1xx.xF06x..1...xF06X08F45", 
       --[[005]] "F30X10F04xF08xF04x.X044x.xF04x.33xx4x.xF04x.X06.xF04x...xF04xF04xxx.x.x2xxF04x11.x.x2xxF04xxxsxrX04F04X10F30", 
       --[[006]] "F44X07F07x...x.xF07xs1.r.xF07xx111.xF08x111.xxF07x111..xF07x.X05F07xxxF50", 
       --[[007]] "F44X09F05xF07xF05x.X05.xF05x.xx.xx.xF05x.xx.xx.xF05x.xx99..xxF04x.xx2xx..xF04xrxs2F04xF04X10F30", 
       --[[008]] "X04F10x...xF09xF04xF08xF05xF07xrF05xF07xF06xF07xF06xF07xF06xF07xF06xF07xF06xF07xF0411xF07x...11xF08x...sxF09X05", 
       --[[009]] "F30X05F09xr..xxF08xxx..xxF09xx1.xxF09xx..xF09xx..xF08xx27xxF06xxx38xxF07xs49xxF08X05F35", 
       --[[010]] "F15X12..xF10x..x.x..s..x..x..xF06x...x..x...xF06x..x.x..r...x.x..xF04xF05x..x.xF05x..x..x...x.xF04x..x..xF05x.x..xF10x..X12F15", 
       --[[011]] "F44X09F05xF07xF05xb...x.rxF05X04.X04F08x.xF08X04.X04F05xsF05cxF05X09F45", 
       --[[012]] "F06xF13xxF12xcxF11x..xF07X04..xF06xF06xF05xrF04x.X10.xF04bxF05xF06xF06x..X04F07x..xF11xsxF12xxF13xF06", 
       --[[013]] "F29X04F04X04..x..X06..x..xbF08rx..xxF08xx...x..x..x..x...xx..c..s..xx..xxxF06xxx..xxF08xx...xxF06xxF05X08F31", 
       --[[014]] "F30X07F07xF05xxF06xx..x..xxF05x..bxx.sxF05x..xx..xxF05xF04bxxF06x..X04F07x..xF10x.rxF10X04F36", 
       --[[015]] "F45X08F06xF05sxF06xr..11xxF06xx.xx1xxF06xF041xxF06x.x111xxF06xbF04cxF06X08F45", 
       --[[016]] "F45X08F06xF06xF05xx.X04.xF05xF05x.xF05x.xxx.x.xF05x.xxx.x.xF05xsxbr.xcxF05X09F45", 
       --[[017]] "F45X08F06xF06xF05xx.X04.xF05xF05x.xF05x.xxx.x.xF05x.xxx.x.xF05xsxrb.xcxF05X09F45", 
       --[[018]] "F33X06F08xF04xF08x.rb.xF08x.xx.xF08x..x.xF08x..x.xF06X04.x.xF06x...cxxxF06xrx..sxF07X07F32", 
       --[[019]] ".xxxF07xxx.x.xF07x.x.x1.xF05x.2x.xb.xF05x.rx..x..x...x..xF04x..xxx..xF05xF07xF04xF09x..x..sF04c...x.xF11x.xF04x.xF04x..xF04xF04xF04x..x.x..xF06X07F03", 
       --[[020]] "F32X07F05xxxF05xF05xF07xF05xF07xF05x...c...xF05x.b...r.xF05xxxs..xxxF07x...xF09X05F47", 
       --[[021]] "F30X10F04xr...xxz.xF04X04...x.xF04x...q..h.xF04x.x..x.xxxF04x.x..x...xF04xsX06.xF04xbxgxx...xF04xyxc.p.xxxF04X10F30", 
       --[[022]] "F20X04F10xs.xF10xc.xF08xxxh.xF08x.1z.xF08x.xq.xF08x.xx.xF08x.xp.xF08x.2y.xF08xxxg.xF10xb.xF10xr.xF10X04F04", 
       --[[023]] "F30X10F04xF04x.g.xF04xr.x.b.x.xF04xxsxxx...xF04x..xxF04xF04x.xF06xF04x.hF06xF04x.cF06xF04x.xxF05xF04X10F30", 
       --[[024]] "F16X11...xF08xx...xrgr..s...x...X09sx...xF09x...x.X04.h..x...xF04xF04x...X06...xx...xhc..x..xxx...xxxgb...xxx...X11F29", 
       --[[025]] "...X04F08xxxs.X07..xF08x.x..xF08x.x..xF04rxxx..x..xF04cF05x..xxx..xF05x..x..xxF04x.x..x..hx...b..x..xF04X04.xx..xF09x...xgF08x...xx..X07F04X04F08", 
       --[[026]] "F32xxxF11x.xxxF08xx.x.xxxF06xF0488xF05xxx.x.xxxF05x993...xF06xxr3x2xxF07X042xF11xsxF11xxxF33", 
       --[[027]] "F18X05F09x...xF09x...xxF08xF04xF08x.r.xxF08x777xF09x7.7xF09x.99xxF08x.49.xF08x.44.xF08x..sxxF08X05F19", 
       --[[028]] "F05X04F11xxF12xxF06xF04X04F04x.x..xz..zx..x...X04..X04F05xF06xF06xF06xF04xxx..9...xxx.x..x..99..x..x...x.779..xF05xxyx7.xyxx...x..xx..xx..x.xF05xxF05x", 
       --[[029]] "F16X09F05xF07xF05xF04s..xF05xxF05xxF06xxb.rxxF08xx.xxF10x.xF10xc.xxF08xx...xxF06xxF05xxF05xF04x..xF05xF07xF05X09F03", 
       --[[030]] "F04X06F07xxF04xxF05xxF06xx...xxF08xx.xxF10x.xF11x.xF06sF04xxxF11cxxF11X04bF08xx..xxrF06xxF04xxF05xxF06xx...xxF08X05F05", 
       --[[031]] "F17X08F05xF08x...xF10x.xF12xxx.x.x..x.x..xx..xrx..xpx..xx..xxx..xxx.xxxF05sF06xx..x...q..x..xx...xF04x...x.x...X04...x...xF08xF05X08F03", 
       --[[032]] "F19X05F08xF05xF06xF07xF04x.bF07x..x..sx...xx..x.x..xx..x..crx.xF05xF04xx.x.c..x..xx..x.xr.xx...xs..x..xF08bxF04xF07xF06xF05xF08X05F04", 
       --[[033]] "F45xxx.xxxF06xx.xxxcxxxF04x..xxF04x...xxF05xx.x...xsF08x...xx..x7xxx.xx...x.997F05x...xr.9xF04bx...X11F29", 
       --[[034]] "F18X05F09xr..xF09xx..xF10x..x.xxx..X05..xxx.x..xF10x..x9876xF05x..xsxxx..X05..xxx.x..xF10x..xxF09x01.xF09X05F18", 
       --[[035]] "X15F0711...xx.rF04xx11..X08..x.x.xx99F09xxx9F11xx9T04F05X11.xxs.xxF0533.x...xxF0533.x...xx5..xx.xx..8.xx5..x...4488.xx55.x..44..8.X15", 
       --[[036]] "F20xxxF10x...xF09x...xF09x...xF06xxxcF04xxx..xF11x.x...r..sF04x.x...x...b...x..X04...X04F06x...xF08xF05xF07X07F17", 
       --[[037]] "...xxx...xxxF04x...x.x...x..xF05xF05x.xF11x.xF11x.xF11x..xF09x...xrF08xF04xF07xF06xrx...xF08x...xF10xsxF12xF20", 
       --[[038]] "F34xxF11x..xF09xF04xF07xF06xF05xF08x...xF05hF04x..xF06s...x..xcgrxF05bx...X04..X04F07x..xF09xF04xF08X06F04", 
       --[[039]] "F20xxF11x.cxF09xF04xF07x...x..xF05xxF06xx...xF05x...sx..xF07x.gx...xF08xF05xr.x..bxF07xF04xF09xg.xF11xxF20", 
       --[[040]] "F32X06F08xF04xxxF04xxx.xF04xF04x577xx...xF04x5xrxF04xF04x5X06.xF04x882xs...xF04xxx2xx3xxxF06x9993xF08X06F32", 
       --[[041]] "F44X05.xxxF05x...xxx.xF05xx..rx..xF06xx.x...xxF05x..b.s.cxF05x..x...xxF05X08F59", 
       --[[042]] "F18X06F08xF04xF08xr77rxF08x22r3xF08xs44sxF08xxs5xxF09X04F11xxF12xxF12xxF12xxF10X06F18", 
       --[[043]] "F45X09F05X04sX04F05xxx...xxxF05xx...11xxF05xF051.xF05xxF04rxxF05xxx..rxxxF05X04.X04F05X09F30", 
       --[[044]] "F06xxxF10x...xF09x.h.xF09x...xF10x.xF08X04.X04F05xF07x...x.X04.X04.x.xx...x.x...xx.x.xx.x.x.xx.x.x...xx.xx...x..x.3F054.xF04x3.7g2.4xF06X07F03", 
       --[[045]] "F07xF12xzxF10xs.sxF09x...xF10x.xF08xxx...xxxF04xF09x...x.xF05x.x..x..x..x..x..x.xc.x7x.x2x.cx.X047.x.2X04F05x.x.xF08xybxbrxF06X09F02", 
       --[[046]] "F18X08F06xF06xF06x.bF04xF06x.x..x.xF06xF06xF04xxx..44..xxx..x...X04...x..xxx..c...xxxF04xF06xF06x7.22..xF06x7.22.3xF05xx7X043xxF04X04..X04.", 
       --[[047]] "F17xxF10xx..xF08xcsx.xF09x...xF10x..xF06xx..x.X08.x..x...222F04x..x..7..2..bx...x..7..2..xF05xx777rxxF07X06F09x..xF09X06F04", 
       --[[048]] "F08xxF11xb.xF11x..xF08xxx...xF06x4F06xF04x.sF04x.x...xF05x...x..xF06x.x.x.xF0423x..x.xxc...7xx...x.xx..xxx.xxF04xxcxF05xx...xxxF07xx.rxF10X04", 
       --[[049]] "F19X04F10x..xF07X04..X06..x99F05000x..xxx.rX07F04x55xF09xx5X08..xx...4r.333x.xx8.xx4bxxx2x.x61xxx4X042x.xbxx.xQ052x.xxx..X08F14", 
       --[[050]] "F19X04F10x..xF07X0477X06..xh222ypF04x..xxx..X07F04x..xF09xx.X08..xxF0733x.xx6.X04..xxx.x18X05.4xxx.xqxx.xg5.44yx.xxx..X08F14", 
       --[[051]] "F47xxF11x..xF09x.r77xF08x.4.22xF08x45.33xF08x56.sxF09x6xxF11xF48", 
       --[[052]] "F19X04F09xx..xxF07xxF04xxF05xx..xx..xx...xx..xs.x..xx..x..x23F05x..x..x99F05x..xx..x9.x..xx...xx..xx..xxF05xxF04xxF07xxr.xxF09X04F19", 
       --[[053]] "F15X05..X05..x...x..x...x..x78.X04.90x..xbyF06pgx..xxx.X04.xxxF04x.x..x.xF06x.X04.xF04xxxF06xxx..xF10x..x123X04456x..xrgpx..xrbyx..X05..X05F15", 
       --[[054]] "F15X12..xF10x..xF05X04.x..xF05x..x.x..xF05x..x.x..xF05x..x.x..xF05x..x.x..xF05x..x.x..xr12..x..x.x..xx3456X04.x..xs7890F05x..X12F15", 
       --[[055]] "F15X08F06xF05yxF06xF05bxF06x.q.c.rxF06x..h..pX05..x.z.sgxF04x..xF04x.s.h.x..X05...c..xF06x..q.y.xF06xF06xF06xyrbgp.xF06X08F15", 
       --[[056]] "F19X05F08xx...xxF07xF05xF07x.s.s.xF07xx...xxF08xx.xxF08xx...xxF06xxF05xxF05x.13r42.xF05xx15672xxF06xx890xxF08X05F18", 
       --[[057]] "F05X04F09xx.rxxF07xx992.xxF06x.3xx7.xF06x43xx78xF06xx55.6xxF07xx..xxF09x..xF10x..xF08xxx..xF10x..xF08xxx..xF08xr...xF08X06F05", 
       --[[058]] "...x...x...xF04xxx.xxx.xxx..x.r.xpxpx.r.x.xrprprprprprx.x8rprprprpr9x..xprprprprpxF04xxrprprxxF07xx7xxF05xxx..xrx..xxx.x..x.xyx.x..x.x4gyxx5xxyg6x..xygyxyxygyxF04x1gy2yg3xF06X07F03", 
       --[[059]] "F14X15qzhcsF07X13.xxF12xx.X13F12X13.xxF12xx.X13F12X12..xxrbgypF07X15", 
       --[[060]] "F06xxF11x.rxF10x.yxF10x.xxF10x..xF06X05r.X05.xp4rb5b.6bg7px.X05r.X05F06xb.xF10xg9xF10xy9xF10x32xF10x22xF11xxF06", 
       --[[061]] "F30X10F04xF08xF04x.X06.xF04x...xs...xF04x...xc...xF04x..X04..xF04x...xx...xF04x...xx...xF04x.X06gxF04x...gyrbyxF04X10F16", 
       --[[062]] "F31X08F06xF06xF06x92F04xF06xr3.xscxF06x44.xc.xF06xr5.xs.xF06xb6xx..xF06xr7.xs.xF06xb7.x..xF06xr8.xs.xF06X08F17", 
       --[[063]] "F32X07F07xF05xF07x.c...xF06xxF05xxF04xx...111.xx...x..xx.xx..x...xF04bF04x...x..x.s.x..x...xx..xxx..xxF04xx..r..xxF06X07F17", 
       --[[064]] "F19xxxF10xxsxxF08xx...xxF06xxcF04xxF04xxF059.xx...x..x.x.x..x...x..x.x.x..x...x..x.x.x..x...x..x.x.x..x...x...2rF04x...xx..xxx.bxxF04X04.X04F17", 
       --[[065]] "F30X10F04xr..xF04xF04xxF07xF04x.bx...x.xF04x.xF04x.xF04x...sx.x.xF04xF04x.x.xF04xF08xF04x...x...cxF04X10F30", 
       --[[066]] "F32X05F07xxxsx.X05...xF09x...x..x...xx.x...xF052999x...x.x..222sxx...x..x...x.xF04x...xxx..xF04xxF05rxxF05x...r.xxF06X07F18", 
       --[[067]] "F31xxx..xxxF06x.x..x.xF06x.X04.xxF05xF07xF04xxF07xx...x..r..r...x...xxF07xxF04x9.22...xF05x9F06xF05X09F30", 
       --[[068]] "X05F04X06...X06...xxF04xxF06X04...xF04xxx..x...sF04xF04xF08xF04xF08xF04xF08xF04xF08xF04x..rF05x..xxx..c.x...X04F06xxF04xx...X06..bX15", 
       --[[069]] "F17X07F05xxx.r...X04..x.x.x.x..xsx..x...x..x...x..xF08x.x..x.xF04x.x.x..x.r..x...x.x..x.x.xF06x..x.r...xx...x..xxx.x..x.xsx...xsF06xxx...X09F17", 
       --[[070]] "F72X11...xF06999x..xx...xsx222xx.xF05x.3335x.xxF05r444xx..X11F43", 
       --[[071]] "F48xxxF06X06.xxxF04x..x22.xsX04.xF042.x.999x.x.xx33F04xxx.xF04x.x.xx...x..rF05xF04X04...xxxF07X05F33", 
       --[[072]] "F15X12..X05F04rxx..x.b..c...q.x..x.zF05s..x..xF10x..x.pF04y..bx..x.shc..x..hx..xy..r..z.b.x..xxp.xF04s.x..xxxF07gx..X04.gxr.byx..X12F15", 
       --[[073]] "X04F10xc.X06F05xxF05sxF06x.X11.x.xF09x.x.x.X04.x.xx.x.x.x..x.x.x..x.x.x..x.x.x..x.x.X04.x.x..x.xrbgy1.x.x.xx.X08.x.xF11xxxhX09.zX04F07X04", 
       --[[074]] "xxxF08X04r.xF06x.yxxg..xF04x..bx.x...x..x...x...x...xx...xF05xF06xF07xs..cxF08xx..xxF07xF06xF05x...xx...x...x...x..x...x.x...xF04x...xxh.xF06x.zX04F08X03", 
       --[[075]] "F46X08F06x.s.s..xF06xF06xF06xF06xF05xx.x...xxF05xF051.xF05xF0511xF05x..rx..xxF05X08F31", 
       --[[076]] "F45X08F06xF05rxF06x300..xxF06x4229xxF07x568xxF08x57xxF09xsxxF10xxxF50", 
       --[[077]] "F46X06F08xF04xF08x...bxF08x..3rxF08x..99xF08x...2xF08xrb.xxF08X05F47", 
       --[[078]] "F58xxxF11xzX09..xx.44..x...xx.x..4F08x.xx.332999y.xx..X059X05F07xxxF47", 
       --[[079]] "F30X10F04xF04x...xF04x..xzxhx.xF04xF04q...xF04x..xzxcx.xF04xF04q...xF04x..sxxcx.xF04x.x..x...xF04x..xxF04xF04x.bprbgypxF04X10F16", 
       --[[080]] "..X09...xxxrg.x...X05ybyr.x.xF04xxbgpx...xF04X12.xxF10xsxF11xcxF11xzxF11xhxF11xqxF11xhxF10xxzxF10xrcxF10X04.", 
       --[[081]] "F18X06F07xx.xx.xxF05xx..xx..xx...xx3..xx..4xx..xr33F0444bx..X04.sc.X04..X04.hz.X04..xgF08yx..xx...xx...xx...xx99xx22xxF05xx9xx2xxF07X06F18", 
       --[[082]] "F30X09F05x...x..sxxF04x.x.x.s..xF04xF08xF04x..xx.x.xxF04xF05x.xF04X04...11xF04xx..xx.x.xF04x.rF06xF04xxx.rx...xF06X08F17", 
       --[[083]] "F15X12..xF10x..xxF09x..xF04X04..x..xF10x..xF10x..x..xxxF05x..x.9..x.s.x.x..x99F06x.x..x22xxx...x.x..x2F07xrx..X12F15", 
       --[[084]] "F05X04F08xxxsX04F05xF08x...x..99..22..x..x..9x..x2..x..xF10x.xF05xF06xxF05xF06xxF12x.xxxF06xxx..xF10x.xF04x..xF04xx..xxxr.xxx..x.xx...xx...xx.", 
       --[[085]] "F15X12..x..xF07x..xF10x..xF10x..x...3..s...x..x..333F05x..x..23F06x..x.222F06x..x.72F06xx..x777F07x..xr7F08x..X12F15", 
       --[[086]] "F45X08F06xs00...xF06x99.32.xF06x8.4321xF06x874321xF06x875551xF06x666..rxF06X08F45", 
       --[[087]] "F31X09F04xx..x.x..xx...xF04rF04x...xx.x.x.x.xx...x..p.b.p..x...x..x.x.x..x...xx.y.p.y.xx...xgrxbxbxrgx...xygprbrpgyx...xrbgypygbrx...X11F15", 
       --[[088]] "F04X06F07x..sh..xF05xF08x...xF10x.xF12xxF05xF06xxF04x.xF05xxx...x..x...xxxyF04x.x...bxxgF05xF04rx.xF10x...xF08xF05x..cz..xF07X06F04", 
       --[[089]] "..xxxF04xxx...xx.xF04x.xx.xx..X06..xxxF12xx..zF06c..X05F06X04..xr..xx..gxF04xy..xx..bx..X04F06X05..sF06h..xxF12xxx..X06..xx.xx.xF04x.xx...xxxF04xxxF02", 
       --[[090]] "F15X12..xr.xxxrbgy4x..xxF042D04x..xx..xxT043x..xF04x..s..x..x.x.xxF05x..x.xF08x..x.X10..xF10x..xxF087x..xsbgyF0477x..X12F15", 
       --[[091]] "F21X05F08xx...xxF05xxx777..xx...xxx..xxx..x..xx...xsxs.xx..x4x.xx5s6xx..xx4x..X07.xr3...2xF04x.xx33..2F04xx...X0599..xF06x.r99rxxF07X06F16", 
       --[[092]] "F32X05F09xcshxF08xx.xzxxF06xx..777xxF04xx.x.x.x.xx...x..x.x.x..x...xp.x.x.x.px...xx22.x.33xxF04xxrg.ybxxF06X07F32", 
       --[[093]] "F15X12..xF10x..x.xschzqxx.x..xF08x.x..x.x..x...x.x..x..xF05x.x..xF05x..xrx..x...xF04xbx..xF08xgx..x.1F04x.xyx..x.1..x...xpx..X12F15", 
       --[[094]] "F24X04F10xc.xF10x..xF07X04..xF07xh..x.xF07xF05xF04X04F05xF04xz..xF04xF04xF08x.X04F04xxx.x.xq..x..xyg..x.xF06xpb23x.X13", 
       --[[095]] "F31X09F05xM04..sxF05x.x...x.xF05x.x...x.xF05x.x..3x.xF05x.2.33..xF05x.2xxx44xF05x555..44xF05xx66X05F06x77rxF09X05F19", 
       --[[096]] "F18X05F08xx.66xxF06xx555..xxF05x..xF04xF05xscx3...xF04X04.3.44xxx...x...3xx4..x...xx222..xrxxF04xxx99.bxxF07X06F09x.xF09X05F19", 
       --[[097]] "X15F05s.V05xxW05x.4...4xx5.x.5..4.x.4xx5...5..4...4xx5...5..V05xxW05F05xcxxzx...qF06xxT05..D05xx2...21p3...3xx2.x.2gy3.x.3xx2...2bx3...3xxT05rhD05X15", 
       --[[098]] "X15F12xxF12xxF12X04F0511...xxbxF061...xxyxF061rX04pxF061bxrxxs.cX08bxxqgprbygprbrgxxzchqsczhqscsxxcrbgyprbgyphxxschzqschzqscX15", 
       --[[099]] "F21xF12x.xF10xgrgxF08xgrxrgxF06xgrpbprgxF04xgrybgbyrgx...xrgbyrybgrxF04xrgpypgrxF06xrgxgrxF08xrgrxF10xrxF12xF20", 
       --[[100]] "F43X13.xF11x.x..rF05x..x.x.555...444.x.xx.2F053.xx.x..222.333..x.xF04s.sF04x.xF11x.X13F28" 
    }           
 
    size = 14
    bc = 13     
    current_level = 1

    gs_show_splashscreen = 0
    gs_select_level = 1
    gs_playing = 2
    gs_level_complete = 3
    gs_show_info = 4
    gs_show_yesno = 5
    
    info_index = 1 
    
    yn_restart,yn_giveup = 0,1
    yn = yn_restart
    
    txt_version = "v1.0"
    txt_by = "by"
    txt_author = "peter antoine"
    txt_start = "— to start"

    trigger_drop_dynamic_pieces = false

    initialize()    
    new_game(current_level)
    
    gs = gs_show_splashscreen
    
    info_text={
    [[        
turnabout consists of 100 
levels. the game's main 
feature is the ability to 
rotate the stage 90 degrees 
cw or cww causing all the 
dynamic elements to fall 
in that direction. the 
stages are grids, being 
14x14 at maximum size. 

the goal is to get all the 
colored pieces to disappear 
    ]],
    [[

there are colored balls, 
which are dynamic, and 
colored blocks, which are 
stationary and often act 
as blockages. 

when a ball collides with 
another ball, block of the 
same color, all of them 
disappear. this repeats 
until the player makes all 
colored pieces disappear 
    ]],
    [[

or cannot make a move, 
requiring the level to be 
restarted.

the levels introduce a 
number of obstacles. blocks 
are dynamic pieces, which, 
unlike balls, are not 
limited to taking up only 
one space. colorless 
blocks may have compli-
cated and specific shapes 
    ]],
    [[

that make progression 
difficult.  

blocks can not be matched, 
meaning they exist for the 
entire round.

balls and colored blocks 
can have five different 
colors. 

each color can only match 
    ]],    
    [[
    
with itself, and can touch 
a block of a different 
color without disappearing.
    ]],
    [[
        
    
    
  ‹ = rotate 90 deg. ccw
  
  ‘ = rotate 90 deg. cw
  
  
  — = retry level
  
  Ž = give up level
    ]]    
}    

end

function _update()    
    if (gs == gs_playing) then       
        if (is_level_complete()) then               
            finished[current_level][1] = true
            if (total_moves < finished[current_level][2]) then
                finished[current_level][2] = total_moves
            end
            sfx(2)
            new_game(current_level)            
            gs = gs_level_complete                
        end            
        if (trigger_drop_dynamic_pieces) then 
            wait(10) 
            move_dynamic_pieces()           
            trigger_drop_dynamic_pieces = false
        end
        if (btnp(‹)) then 
            rotate_ccw()              
        elseif (btnp(‘)) then 
            rotate_cw()        
        elseif (btnp(—)) then 
            yn = yn_restart
            gs = gs_show_yesno
        elseif (btnp(Ž)) then 
            yn = yn_giveup
            gs = gs_show_yesno
        end     
        
    elseif (gs == gs_level_complete) then             
        wait(100)    
        if (current_level < #levels) then
            current_level += 1
            new_game(current_level)            
        end
        gs = gs_select_level                
            
    elseif (gs == gs_show_yesno) then
        if (btnp(—)) then
            new_game(current_level)
            if (yn == yn_restart) then            
                gs = gs_playing
                trigger_drop_dynamic_pieces = true 
            elseif (yn == yn_giveup) then            
                gs = gs_select_level            
            end
        elseif (btnp(Ž)) then 
            gs = gs_playing
        end   
       
    elseif (gs == gs_show_splashscreen) then
        if (btnp(—)) then
            gs = gs_show_info            
        end        

    elseif (gs == gs_show_info) then
        if (btnp(—)) then
            if (info_index == #info_text) then
                gs = gs_select_level
            else
                info_index += 1
            end
        end        

    elseif (gs == gs_select_level) then
        if (btnp(‹)) then             
            if (current_level > 1) then
                current_level -= 1
                new_game(current_level)
            end
            
        elseif (btnp(‘)) then 
            if (current_level < #levels) then
                current_level += 1   
                new_game(current_level)
            end
            
        elseif (btnp(—)) then            
            new_game(current_level);
            gs = gs_playing
            trigger_drop_dynamic_pieces = true 
        end        
    end        
end

function _draw()        
    if (gs == gs_playing) then       
        cls(1)
        draw_grid()      
        draw_game_menu()          
    elseif (gs == gs_level_complete) then draw_level_complete()   
    elseif (gs == gs_show_yesno) then draw_yesno()           
    elseif (gs == gs_show_info) then draw_info()        
    elseif (gs == gs_select_level) then draw_select_level()        
    elseif (gs == gs_show_splashscreen) then draw_splashscreen()
    end     
end

function initialize()    
    grid = {}
    for y=1, size do
        grid[y] = {}
        for x=1, size do
            grid[y][x] = 0
        end
    end
    
    finished = {}
    for i=1, #levels do
        add(finished, {false,9999}) --finished + #moves
    end
end

function draw_game_menu()        
    rectfill(0,0,128,6, 13)
    rectfill(0,121,128,128, 13)
    print("level:",2,1,10)  print(tostr(current_level),26,1,11)
    print("moves:",48,1,10) print(tostr(total_moves),72,1,11)
    print("best:",93,1,10)
    if (finished[current_level][2] < 9999) then
        print(tostr(finished[current_level][2]),113,1,11)
    else
        print(tostr(total_moves),113,1,11)        
    end     
    print("—=retry  ‹‘=move  Ž=give up",2,122,7)        
    print("—        ‹‘       Ž        ",2,122,9)        
end

function draw_yesno()
    cls(13)
    draw_bevelled_box(30,40,95,90,1)
    if (yn == yn_restart) then
        print("retry level?",40,64,7)        
    else
        print("give up level?",36,64,7)        
    end
    draw_bevelled_box(30,112,95,120,1)    
    print("—=yes  Ž=no",38,114,6)
    print("—      Ž",38,114,9)
end

function draw_grid()    
    for y=1, size do
        for x=1, size do
            if (grid[y][x] != 0) then                
                spr(grid[y][x],x*8,y*8)                                  
            end
        end
    end
end

function get_sprite_coordinates(s)  
    if (s <= 11) return { 0, s*8 }        
    return {8, (s-16)*8} 
end

function is_ball(v)        
    return v == 2 or v == 4 or v == 6 or v == 8 or v == 10 
end

function is_exit(v)        
    return v == 3 or v == 5 or v == 7 or v == 9 or v == 11 
end

function is_dynamic_wall(v)   
    return v >= 16 and v <= 25 
end

function is_player_piece(v)        
    return is_ball(v) or is_exit(v)
end

function is_dynamic_piece(v)        
    return is_ball(v) or is_dynamic_wall(v)
end

function get_dynamic_pieces()          
    local dps = {} --dynamic_pieces
    for y=1, size do
        for x=1, size do
            if (is_dynamic_piece(grid[y][x])) then                 
                add(dps, {y,x,grid[y][x]})
            end
       end
    end

    -- sort by y descending
    for i=1,#dps do
        local j=i
        while (j > 1 and dps[j-1][1] < dps[j][1]) do
            dps[j][1],dps[j][2],dps[j][3],dps[j-1][1],dps[j-1][2],dps[j-1][3] = dps[j-1][1],dps[j-1][2],dps[j-1][3],dps[j][1],dps[j][2],dps[j][3]
            j-=1
        end
    end
    
    -- group sorted dynamic pieces per piece_type (player_pieces: index 1-5, dynamic_walls: index 6-15)
    local ppt = { {},{},{},{},{},   {},{},{},{},{},{},{},{},{},{} } -- pieces_per_type

    for i=1, #dps do     
        local y,x,v = dps[i][1],dps[i][2],dps[i][3]      
        if (is_ball(v)) then
            add(ppt[v/2], {y,x,v})  --2/4/6/8/10 -> 1/2/3/4/5    
        elseif (is_dynamic_wall(v)) then
            add(ppt[v-10], {y,x,v}) --16-25 -> 6-15
        end
    end            

    return ppt
end

function move_dynamic_pieces()      
    local piecesremoved = false
    local dropsound = false    
  
    repeat        
        local keepmoving = false
        
        -- dps[i] could contain 1 piece (single block)
        -- dps[i] could contain multiple pieces of monolithic block
        -- dps[i] could contain 1 or more player pieces of the same color

        local dps = get_dynamic_pieces()

        for i=1, #dps do
            if (#dps[i] != 0) then       
                if (#dps[i] == 1) then -- single_piece (single_player_piece or single_wall_piece)
                    if (move_single_piece(dps[i][1][1], dps[i][1][2])) then                                                                        
                        keepmoving = true
                        sfx(0)
                    end
                elseif (i <= 5) then -- multiple player_piece(s) of same color
                    for j=1, #dps[i] do -- one or more player pieces
                        if (move_single_piece(dps[i][j][1], dps[i][j][2])) then
                            keepmoving = true
                            sfx(0)
                        end
                    end
                elseif (can_move_monolithic_piece(dps[i])) then -- monolithic_wall_piece
                    move_monolithic_piece(dps[i])                                                            
                    keepmoving = true
                    dropsound = true                    
                end                          
            end
        end
        if (not keepmoving) then            
            piecesremoved = remove_player_pieces()           
        end
    until (keepmoving == false and piecesremoved == false)

    if (dropsound) then
        sfx(0)
    end
end

function move_single_piece(y, x)  
    local hasmoved = false
    while (y+1 < size and grid[y+1][x] == 0) do                    
        grid[y+1][x] = grid[y][x]          
        grid[y][x] = 48 -- falling sprite                                  
        draw_grid()                 
        flip()
        grid[y][x] = 0 
        y += 1 
        hasmoved = true 
    end        
    return hasmoved  
end

function can_move_monolithic_piece(mps)       
    for i=1, #mps do
        local y,x,v=mps[i][1]+1,mps[i][2],mps[i][3]             
        if (y >= 14 or (grid[y][x] != 0 and grid[y][x] != v)) then 
            return false
        end        
    end    
    return true
end

function move_monolithic_piece(mps)   
    local rows = { } -- monolithic_piece split up by rows    
    
    -- group by y    
    local cy = -1 
    local idx = 0
    for i=1, #mps do
        if (cy != mps[i][1]) then 
            cy = mps[i][1]
            idx += 1            
            rows[idx] = {}            
        end
        add(rows[idx], {mps[i][1], mps[i][2]})
    end

    local cycle = 0
    for r=1, #rows do          
        for p=1, #rows[r] do  
            local y,x = rows[r][p][1],rows[r][p][2]
            rows[r][p][1] += 1                 
            grid[y+1][x] = grid[y][x]
            grid[y][x] = 48 
            draw_grid() -- no flip(), should fall as 1 monolithic piece                               
            grid[y][x] = 0  
        end        
    end
    flip()
end

function remove_player_pieces()
    local ptr = {}  --pieces_to_remove
    for y=1, size do
        for x=1, size do    
            local dp1 = get_player_piece(grid[y][x])
            if (dp1 != nil) then       
                local dtc = {} -- directions_to_check
                if (y > 1) add(dtc, {-1,0})
                if (y < size) add(dtc, {1,0}) 
                if (x > 1) add(dtc, {0,-1})
                if (x < size) add(dtc, {0,1})              
                for i=1, #dtc do
                    local ny = y+dtc[i][1]
                    local nx = x+dtc[i][2]
                    local dp2 = get_player_piece(grid[ny][nx])
                    if (dp2 != nil and fget(dp1) == fget(dp2) and
                       ((abs(x-nx) == 0 and abs(y-ny) != 0) or (abs(x-nx) != 0 and abs(y-ny) == 0))) then
                        add(ptr, {y,x})
                        add(ptr, {ny,nx})
                    end
                end
            end
        end
    end       

    if (#ptr > 0) then        
        for i=1, #ptr do
            local y = ptr[i][1]
            local x = ptr[i][2]      
            grid[y][x] = 50
        end
        sfx(1)
        draw_grid()
        wait(10)       
        for i=1, #ptr do
            local y = ptr[i][1]
            local x = ptr[i][2]      
            grid[y][x] = 0
        end        
    end

    return (#ptr > 0)
end

function get_player_piece(v)
    if (is_player_piece(v)) return v
    return nil
end

function is_level_complete()
    for y=1, size do
        for x=1, size do    
            if (is_player_piece(grid[y][x])) return false
        end
    end
    return true
end

function rotate(n)   
    for i=1, n do       
        local tmp = {}
        for y=1, size do
            tmp[y] = {}
        end        
        for i=1, size do
            for j=1, size do
                tmp[i][j]=grid[size-j+1][i]
            end
        end
        grid=tmp
    end
end

function rotate_cw()    
    rotate(1)        
    total_moves += 1
    trigger_drop_dynamic_pieces = true
end

function rotate_ccw()    
    rotate(3)        
    total_moves += 1
    trigger_drop_dynamic_pieces = true
end

function new_game(level)    
    total_moves=0    
    local i=1
    local ds = decompress(levels[level])
    for y=1, size do
        for x=1, size do
            grid[y][x] = get_sprite(sub(ds,i,i))
            i += 1
        end
    end
end

function draw_splashscreen()
    cls(bc)    
    for y = 1, 8 do        
        for x = 1, 8 do  
            local c = get_rnd_color()
            sspr(16*c, 0, 8, 8, (x-1)*16,(y-1)*16, 16, 16)
        end
    end                 
    draw_bevelled_box(32,33,95,79,1)
    draw_shadow_text('turnabout',45,37,9)       
    print(txt_version, hcenter(txt_version)-2,49,6)    
    print(txt_by, hcenter(txt_by)-2,60,5)    
	print(txt_author, hcenter(txt_author)-1,70,5)    
    draw_bevelled_box(32,112,95,120,1)    
    print(txt_start, hcenter(txt_start)-3,114,6)	
    wait(3)               
end

function draw_start()
    draw_bevelled_box(30,112,95,120,1)    
    print(txt_start, hcenter(txt_start)-3,114,6)	
end

function draw_select_level()
    cls(bc)    
    draw_shadow_text('select level',40,10,7)    
    draw_bevelled_box(30,30,95,95,1)    
    rectfill(30,30,95,95,1)
    print("-"..tostr(lpad(current_level)).."-",56,20,10)    
    print("‹                  ‘",20,60,7)             
    for y = 1, size do
        for x = 1, size do
            if (grid[y][x] != 0) then                
                local c = get_sprite_coordinates(grid[y][x])
                sspr(c[2],c[1],8,8,(x-1)*4+35,(y-1)*4+35,4,4)
            end
       end
    end        
    if (finished[current_level][1]) then
        print("cleared in "..finished[current_level][2].." moves",27,100,11)            
    else
        print("unsolved",48,100,7)            
    end    
    draw_start()
end

function draw_level_complete()    
    cls(bc)        
    draw_shadow_text("!!! congratulations !!!",18,14,9)        
    draw_shadow_text("level cleared",38,34,11)        
    rect(34,44,91,101,11)
    for y = 1, size do
        for x = 1, size do
            if (grid[y][x] != 0) then                
                local c = get_sprite_coordinates(grid[y][x])
                sspr(c[2],c[1],8,8,(x-1)*4+35,(y-1)*4+45,4,4)
            else
                sspr(8,24,8,8,(x-1)*4+35,(y-1)*4+45,4,4)
            end
       end
    end            
end

function draw_info()
    cls(bc)    
    draw_bevelled_box(8,22,120,100,1)    
    draw_shadow_text("info ["..tostr(info_index).."/"..tostr(#info_text).. "]",43,10,7)    
    print(info_text[info_index],11,20,9)    
    draw_start()
end

function draw_bevelled_box(x1, y1, x2, y2, c)
    rectfill(x1,y1,x2,y2,c)
    line(x1,y1-1,x2,y1-1,5)
    line(x1,y2+1,x2,y2+1,6)
    line(x1-1,y1,x1-1,y2,6)
    line(x2+1,y1,x2+1,y2,5)
end

function draw_shadow_text(s, x, y, c)
    print(s,x+1,y+1,5)
    print(s,x,y,c)
end

function compress(s)
    local r = ""    
    local pc = ""
    local cnt = 0
    local p = 1
    while (p <= #s) do        
        local c = sub(s,p,p)
        if (c == pc) then
            cnt+=1
        else
            if (cnt > 3) then r=r..cc(pc, cnt)
            else for i=1, cnt do r=r..pc end
            end            
            pc = c
            cnt=1
        end
        p+=1
    end    
    if (cnt > 1) then r=r..cc(pc, cnt)
    else r=r..pc
    end
    return r
end

function decompress(s)
    local r = ""
    local p = 1    
    while (p <= #s) do
        local c = sub(s,p,p)
        if (c == "F" or c == "X" or 
            c == "C" or c == "O" or c == "T" or c == "D" or c == "V" or 
            c == "W" or c == "B" or c == "Q" or c == "Z" or c == "M") then  
            local n = tonum(sub(s,p+1,p+2))
            for i=1, n do r=r..tc(c) end            
            p+=3
        else
            r=r..c            
            p+=1
        end        
    end    
    return r
end

function cc(c, cnt)
    local r = ""    
    if (c==".") then r=r.."F"
    elseif (c=="x") then r=r.."X"
    elseif (c=="0") then r=r.."C"    
    elseif (c=="1") then r=r.."O"
    elseif (c=="2") then r=r.."T"
    elseif (c=="3") then r=r.."D"
    elseif (c=="4") then r=r.."V"
    elseif (c=="5") then r=r.."W"    
    elseif (c=="6") then r=r.."B"    
    elseif (c=="7") then r=r.."Q"    
    elseif (c=="8") then r=r.."Z"    
    elseif (c=="9") then r=r.."M"        
    end    
    if (cnt < 10) r=r.."0"
    r=r..cnt    
    return r
end

function tc(c)
    if (c=="F") return "."
    if (c=="X") return "x"
    if (c=="C") return "0"
    if (c=="O") return "1"
    if (c=="T") return "2"
    if (c=="D") return "3"
    if (c=="V") return "4"
    if (c=="W") return "5" 
    if (c=="B") return "6"
    if (c=="Q") return "7"
    if (c=="Z") return "8"
    if (c=="M") return "9"
    return ""
end

function get_sprite(c)
    -- x=wall, .=empty, r/s=red, b/c=blue, g/h=green, y/w=yellow, p/q=purple, 0,1,2,3,4,5,6,7,8,9=blocks    
    if (c==".") return 0
    if (c=="x") return 1  
    if (c=="r") return 2
    if (c=="s") return 3
    if (c=="b") return 4 
    if (c=="c") return 5
    if (c=="g") return 6
    if (c=="h") return 7
    if (c=="y") return 8
    if (c=="z") return 9
    if (c=="p") return 10 
    if (c=="q") return 11
    return tostr(c) + 16 -- blocks    
end

function get_rnd_color()
    return  flr(rnd(4)) + 1
end

function wait(a) 
    for i=1, a do 
        flip() 
    end 
end

function lpad(n)    
    if (n < 10) return "0"..n
    return ""..n;
end

function hcenter(s)
  return 64-#s*2
end
__gfx__
0000000055555555112222112222222211555511dddddddd11333311333333331199991199999999115555115555555500000000000000000000000000000000
0000000056666665128888212888888215cccc51dccccccd13bbbb313bbbbbb319aaaa919aaaaaa9152222515222222500000000000000000000000000000000
000000005655556528688882288888825c6cccc5dccccccd3b6bbbb33bbbbbb39a7aaaa99aaaaaa9527222255222222500000000000000000000000000000000
000000005655556528888882288888825cccccc5dccccccd3bbbbbb33bbbbbb39aaaaaa99aaaaaa9522222255222222500000000000000000000000000000000
000000005655556528888882288888825cccccc5dccccccd3bbbbbb33bbbbbb39aaaaaa99aaaaaa9522222255222222500000000000000000000000000000000
000000005655556528888882288888825cccccc5dccccccd3bbbbbb33bbbbbb39aaaaaa99aaaaaa9522222255222222500000000000000000000000000000000
0000000056666665128888212888888215cccc51dccccccd13bbbb313bbbbbb319aaaa919aaaaaa9152222515222222500000000000000000000000000000000
0000000055555555112222112222222211555511dddddddd11333311333333331199991199999999115555115555555500000000000000000000000000000000
24444999244449992444499924444999244449992444499924444999244449992444499924444999000000000000000000000000000000000000000000000000
24222229242222292422222924222229242222292422222924222229242222292422222924222229000000000000000000000000000000000000000000000000
24444424244444242444442424444424244444242444442424444424244444242444442424444424000000000000000000000000000000000000000000000000
244dd42424499424244cc4242447742424433424244ee4242446642424488424244bb424244aa424000000000000000000000000000000000000000000000000
244dd42424499424244cc4242447742424433424244ee4242446642424488424244bb424244aa424000000000000000000000000000000000000000000000000
29444424294444242944442429444424294444242944442429444424294444242944442429444424000000000000000000000000000000000000000000000000
29994444299944442999444429994444299944442999444429994444299944442999444429994444000000000000000000000000000000000000000000000000
22222222222222222222222222222222222222222222222222222222222222222222222222222222000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11101111111111111111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11101011111111111111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11101011111111111110011100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111111111111101101100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11011011111111111101101100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11011011111111111110011100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11011111111111111111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111111111111111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
0000010110100808040440400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
00000000000000000000001c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000001c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
000100001875013750107500d7500c75005700097000b7000f7001170017600156001560000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300000c5301053014530195301e53022530285302c530315303653030500395003a5002e500395003a5002250022500215002050020500205001a5003f30031300393003d3000000000000000000000000000
0006000015030180301c0301f03023030270302b0302f03033030360303a0303c0303f0303e0003e0003f0002c000370003d0003f0003d0000000000000000000000000000000000000000000000000000000000
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
