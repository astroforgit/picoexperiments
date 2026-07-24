pico-8 cartridge // http://www.pico-8.com
version 7
__lua__
-- the career of peter
-- missingsentinelsoftware.com
git = "86f9a45"
git_count = "18"
people={}
people["p_alan"] = "l)l)lfzl)lvfugrfwl)lsfwguful(f2gtful^fwgrfvgrfgrfsl$fzgfvgrfrgrfrl!fwgfugufvgrfrl?fsgrfsgfrgrftgtfvgfrl.fsgrftgrfrgrftgrfgrfrgfrgfl.frgrftgtfrgsftgfgrfrgftl<fsgrfugvfgrfgsfsgfrgfsl<fgsfxgfsgfrgrfrgrfgufsl:fsgsf6gsfgrfgtfrl:fsgsftgufzgvfgfrl:fsgfgfsg1fzgfgfrl:frgrfgfsg5f2l;fxg9fyl;fxgsftg4ftlfrl;frgrftgtfugsfrgxfslrfl:fwgsfxgrfygfrl<fsgfsgufgfugrfxgrfrl<fgfugtftgvfsgfrgtfrl<fgrfsgvfrgxftgufrl,fgfsgrhrgsftgufvgsfrl,fgsfgrhsgxhsfrgwfrl.fgsfghtgvfhsfrguhrfrl>fguhtgufxgrhsfrl?frgvhgwftgshsgfrl!fgwfg2hgrfsl!fgwfsg2fsl#fgxfygtfrl%frgwfwgtfrl*fg6frl)frg2fsl)lsfrgyfsl)ltfgfguftl)lvfgrfxl)lwfrgrftl)lzfxl)lzfghgrfsl)lyfsgsftl)lwfgfgfxl)lufgrfghgrfvl)ltfgrfrgsfvl)ltf4l)ltfghfghgrfsgrfl*fwgrhfvgrfxl,fvhrgftgshgfgtfsgsfyl]fsgrhgtfwgrf1gshrgrfsl[f1lsf1iflrf4l8fwlsfrbrflfslfrgfslrfifvlsfxl6fgfwlsfrbrfslrfrgfslsfvlsfslfrgsfl4fgrfgflfulsfrifslfrgfslfrbfslsftlrfgrhrgfl2fghgfslsfgrflfirfrbrfsgftbrfrirflftlsfgshgfl2fhgrfsltfgfrirflrftgrfsbfrlrfifrgrfltfrgsfrl2fgsfslufrifrlufrgrfifrlufrgrflufrgsfrl2fgrftltfwlufrgfiflufrgftltfrgftl2fgfrgfrlsfsifrgrfltfrgfifltfgrfvlsfwl2fgfulrfulrfgfrlsfgfriflsfrgflrfirfrlrfgful3fgfrgflfultfgfslfgfriflfsgfltfirfrlfgftl5frgrfrisflvfwgfvgflvfisfrgsfl7ftirfrlxfvgfugflxfisftl0fifslzfugfifgrflzfififlz"
people["p_bbs"] = "l)l[i&l0irkj7irjijrirjtkyjsil8ijsk1j7ijskxjril6ikjsk4j3ijvkujitl5ijk-j-itl4ijvkjtk>jsil4ijwkjkrja.jsil4ijxkjragargagsfrgra-jrkil3irjwkjagagragwfg0asjkil3irjwkjarg.askil3ijxkjag[fgzarkil3ijxkjag6fgwfrgyarkil3ijxkjag3fgfgrfgvfgyarkil3ijxkjag?arkil3ijxkjag<fgsarkil3ijxkjag?arkil3ijxkjag?arkil3irjwkjag<fgsarkil3ijxkjag?arkil3ijxkjag?arkil3ikjwkjagfrg.akil3ikjwkjagfrg{fgvakil3ikjwkjarfrg.akil3ikrjijtkjargfrg,akil3iksjukjarg?akil3iktjtkjargfg;frgsakil3iktjtkjargfrg{fsgsakil3ikujskjargfsg]frgtakil3ikjksjskjarg>arkil3ijrktjrkjarg>arkil3ijxkjarg.askil3ijxkjasgwfrg-argakil4ijwkjrasg4frg4agajkil5ijwkjrazg+ajkjil6ijijukjra,jkjril7ijwkj.kjsil6irjiwk.iul5ijij*isl3ij)jsirl2irjvi$jsil2ikrjui%jril2iktjriskirjxi]kisjil2iktji*jil2iksjriwjxi:jil2ijui*jil2ijui*jil2ijui;kikirkikirkikisjil3ijti;kikitkirkiujil4irjritki+kikirkikirkikisjil5irjri^jril6ijsi$jsil7ij*isl6ik)kil5ij)jril5iji*jril5ijrisjrijrijrijrijrijrijrijrijrijrijrijrijrirjsil4ijrisjrijrijrijrijrijrijrijrijrijrijrijrijrisjril5ijri&jsil4ijritjrijrijrijrijrijrijrijrijrijrijrijrijrirjril4ijsisjrijrijrijrijrijrijrijrijrijrijrijrijrirjril5ij)jil6i)il)l-"
people["p_grace"] = "l)l)l)l)l=ful)l2frgftl3fvl!fsgsftlufwgfgrfrl/frgvfslsfrguftgrfsl>frgwfslfrgwfsgtfrl.frgxfsgzfrgrhgrfrl<frgyfrgshghrgufgrhgsfrl'ftgvfrgfghrghgvfgshghgfrl:frgfrgtfrgfrghghrgvfrgrhsgfrl:frgsfrgfrgfrghgrhgrfgsfrgthrgrfl:fvgfrgfrgrfgfrgrfgfsgtfgrhgfrl;fsgrfvgrfgfrgrfrgfvgrfghgrfl;fugrfsgrfhrfgsfgfrgrftgfghgrfl:fsgftgfrgrfgsftgtfugtfl:ftgrftgsfgsftgufugsfl:fygsfgsftgvfugsfl<fvgsfgsftgyfsgsfl>fsgfrgtfwgtfugfgfl?ftgtfygrfvgfgfl?frguf8gfgfl?frgsfvguftgtfsgfl?frgfsgftguftgtfrgrfl?ftgfwgsfvgsfrgfrl/frgfsgsfsgftgrfvgfrl/fvhrgsfsgrfgsfsgfgfrl?frgfthsg1fgsfsl/fgfrgrfgrhsgtfgrfsgsfsl/fgrfrguhrguftgtfrl!frgrfsg8frl@frgyfg2fl$fvgufxgsfrl(frgvftgufl)lfrgwfrgtfrl)lfsg2fl)lrftgzfrl)lrfrgfrgxfrl)lsfrgftgufrl)lsfsgrfyl)lsbsgtfvl)lsbugufubrl)brmrbsguftbul&brmsbsgufsbvl%bmtbugufrbrmsbsl@brmrbsmrbrgufrbtmrbsl!brmbrmubrgtfbvmrbtl>bumrhrmsbrgsbtmrbrmbtl,bvmthmbugbvmrbtmbrl'btmrbsmsbsmbvmbsmrbvl'bsmubumrhmbtmrbymbrl;brmxbumrbtmtbxmbrl}bsmybtmbrmrbmsb3l{brmthsmtbumrbrmb5l]brmuhrmwb+l]brmvhrmwb4mbwl[brmxhrmwb1mtbvl[brm7bzmubvl+bsm7bxmwbtmbl+bsmxbsmtbymwbsmsbl+bsmubtmvbrmsbsmxbsmsbl-btmsbum3brmwbtmbsl-btmbwm3brmvbyl4"
people["p_peter"] = "l)l)l)l)l)l)l)l)l)l)l)l)l)lsfyl)lwf3l)ltf6l)lf8l(f=l^f+l%f[l#fzgvfyl#fzgyfwl!fzgrhsgwful!fyg4ftl/fygtfrhsgvftl/fygvfvgsftl/fygxhrgvfsl/fxgufrgufsgrfrl!fxgwfugufrl/fxg8frl?frgfug9frl?fghgfrgwfugtfwl?fshgfrgtfrgsfrgvful?fgrfhgrfgrfxgtfwl?fgsfgsfrhxfgrfhvfl/fgrfgtfhsfthfgrfthsfl/fgwfhrfhrfrhfvhfhrfl!frgufhxfgrfhvfl#fgrhgfhxfgrfhvfl#fgrhgrfxgsfwl$fgshg1hfsgfsl$fgthtgwhfrgrhrfl#fsg1fghrfgrhrfl#fhrfrg1ftgtfl,culrfhsfrgzfsgufcl;ctntcshtfrgtfgsfsgufcrl{csnychufrgtfwgsfcwl=crn2chufrg2fcyl9crn4crhtfrgtfsgsfc1l7crn7chtfsgvfrc3l5crn9chufxc4l5cn=chufthsc5l4n+chtfhrfhsc5l4n[chrfrhrfhsc6l3n]chfhsfhrcrnc5l2n{crhsfhrcnrc5l2n}cnhscrnsc5l2n{cncnhrcntc5l2n}cnhscnuc4l2n2cnwcrnuchtcnuc4l2n1crnycrnschscrnuc4l2n1crnrcnxcrncnhrcnvc4l2nzcsncn1cncnhcnvc4l2nzctn2chnhrctnsc4l2nycun2chtcnsc7l2nycun2chtcnvc4l2nycun2cnhscnvc4l2nxcvn1cncnhrcnvc4l2"
people["p_peter_tv"] = "l)l(al9al*al6arl)al4al)lsal1arl)lualyal.i=aivari3l0irkj7irjajrirajskyjsil8ijsk1j7ijskxjril6ikjsk4j3ijvkujitl5ijk-j-itl4ijvkjtk>jsil4ijwkjkrja.jsil4ijxkjraiarfafvga-jrkil3irjwkjaiafrafvgtfrhsgvftisasjkil3irjwkjarifygvfvgsftitaskil3ijxkjairfygxhrgvfsiuarkil3ijxkjairfxgufrgufsgrfrivarkil3ijxkjairfxgwfugufrivarkil3ijxkjaifxg8frivarkil3ijxkjafrgfug9frivarkil3ijxkjafghgfrgwfugtfwivarkil3ijxkjafshgfrgtfrgsfrgvfuivarkil3irjwkjafgrfhgrfgrfxgtfwivarkil3ijxkjafgsfgsfrhxfgrfhvfivarkil3ijxkjaifgrfgtfhsfthfgrfthsfivarkil3ikjwkjaifgwfhrfhrfrhfvhfhrfiwakil3ikjwkjairfrgufhxfgrfhvfiwakil3ikjwkjarisfgrhgfhxfgrfhvfiwakil3ikrjijtkjarisfgrhgrfxgsfwixakil3iksjukjarisfgshg1hfsgfsixakil3iktjtkjarisfgthtgwhfrgrhrfixakil3iktjtkjarirfsg1fghrfgrhrfiyakil3ikujskjarifhrfrg1ftgtfiyakil3ikjksjskjarifhsfrgzfsgufciwarkil3ijrktjrkjarcrhtfrgtfgsfsgufcriwarkil3ijxkjarnchufrgtfwgsfcwiraskil3ijxkjasnchufrg2fcyariakil4ijwkjrasncrhtfrgtfsgsfczaiajkil5ijwkjrazfsgvfrc2ajkjil6ijijukjra,jkjril7ijwkj.kjsil6irjiwk.iul5ijij*isl3ij)jsirl2irjvi$jsil2ikrjui%jril2iktjriskirjxi]kisjil2iktji*jil2iksjriwjxi:jil2ijui*jil2ijui*jil2ijui;kikirkikirkikisjil3ijti;kikitkirkiujil4irjritki+kikirkikirkikisjil5irjri^jril6ijsi$jsil7ij*irl8i(l=asl>asl[asl>asl[asl>asl)l)l&"
people["p_pso_asexual"] = "l)l)l)l)l)l)l)l)l)l)l)l@czl(c3ivcrl%ctivcrircwicrl#ctixctiscwl@crishi5cul!csishi6ctl!cri=ctl!ciwhi2cvl!ciuhizctiscsl!ci5citcvl!ci3crirctictl!criycsircriscul@cicyiscriscwl@cizcsiscvfsl@c1iuctfvl#cizcvfxl$civcxfxl^c2fsgtfsl^cyftgvfsl&fygyfrl*fsg5frl(frghrgxhrgrfl)frghg2frl)lfg4frl)lfg4frl)lrfg2frl)lsfsgyfrl)ltftgwfrl)lufvgsftl)lufzgrcl)ltcrfvgtcrl)ltcsgxcsl#jylrcricsgscsicrjzl}jukujcsiscuiscjvkujl}jyictiuciscsjzl;c6iscisciscyl;c7ircrivczl{c4ixcitcicyl{c2iwkiscicriczl{ctiscri2ctisczl{csiuci2kircrisciucsl{crivci4critcrivcl{crivci5ciucivcl{csiuci3kiciucivcl{csiucri4ciucriucl{csiucsi1kicivciucl{ctitcsi3civcitcrl}csitcuiykicivcitcrl}ctiscwiycivcitcrl}cuiscviwkicivcitcrl{cviscwixciucriscsl{cviscwivkiciucrirctl{csivcwixciucrircsl}criwcviwkiciucsircrl}criwcuizciucsircrl}criwcuixkiciucsiscl4"
people["p_pso_female"] = "l)l)l)l)l)l)l)l)l)l)l)l@czl(c3ivcrl%ctivcrircwicrl#ctixctiscwl@crishi5cul!csishi6ctl!cri=ctl!ciwhi2cvl!ciuhizctiscsl!ci5citcvl!ci3crirctictl!criycsircriscul@cicyiscriscwl@cizcsiscvgrfl@c1iuctfsgrfl#cizcvgrfvl$civcxfvgfl^c2fgfugrfl^cyfugftgfrl&f6gfgfl*fsgyfgfvl(frghrgtfsghrgfrl)frghg2frl)lfg4frl)lfgtfwgsfl)lsfg2frl)lsfsgtfrgsfrl)ltftgwfrl)lufvgsftl)lufzgrcl)ltcrfvgtcrl)ltcsgxcsl#jylrcricsgscsicrjzl}jukujcsiscuiscjvkujl}jyictiuciscsjzl;c6iscisciscyl;c7ircsiuczl{c4ixcrircricyl{c2iwkiscicriczl{ctiscrixcxic2l{csiucivctirkirctictircsl{crivci3cuiscsitcl{crivcizcticivcritcl{csiuci3kiciwcitcl{csiucri4ciwcitcl{csiucsi1kiciwcitcl{ctitcsi3ciwciscrl}csitcuixkicriwciscrl}ctiscwixciwcitcrl}cuiscyirkircivcritcrl{cvisc1isciucsiscsl{cvisc6isctirctl{csivczircrivcsircsl}criwcvitkiciwctircrl}criwcuiwciwctircrl}criwcuiukicixcsiscl4"
people["p_pso_male"] = "l)l)l)l)l)l)l)l)l)l)l)l@czl(c3ivcrl%ctivcrircwicrl#ctixctiscwl@crishi5cul!csishi6ctl!cri=ctl!ciwhi2cvl!ciuhizctiscsl!ci5citcvl!ci3crirctictl!criycsircriscul@cicyiscriscwl@cizcsiscvgrfl@c1iuctfsgrfl#cizcvgrfvl$civcxfvgfl^c2fgfugrfl^cyfugftgfrl&f6gfgfl*fsgyfgfvl(frghrgtfsghrgfrl)frghg2frl)lfg4frl)lfgtfwgsfrl)lrfg2frl)lsfsgtfrgsfrl)ltftgwfrl)lufvgsftl)lufzgrcl)ltcrfvgtcrl)ltcsgxcsl#jylrcricsgscsicrjzl}jukujcsiscuiscjvkujl}jyictiuciscsjzl;c6iscisciscyl;c7ircrivczl{c4ixcitcicyl{c2iwkiscicriczl{ctiscri2ctisczl{csiuci2kircrisciucsl{crivci4critcrivcl{crivci5ciucivcl{csiuci3kiciucivcl{csiucri4ciucriucl{csiucsi1kicivciucl{ctitcsi3civcitcrl}csitcuiykicivcitcrl}ctiscwiycivcitcrl}cuiscviwkicivcitcrl{cviscwixciucriscsl{cviscwivkiciucrirctl{csivcwixciucrircsl}criwcviwkiciucsircrl}criwcuizciucsircrl}criwcuixkiciucsiscl4"
people["p_susan_resistance"] = "i)i)i)i)i)i)i)i)i)i)i)i?fxi)ivf3i)itf5i)ifshrgzfti*fshrg3fsi^fshsgrhrgzfsi$fshrgshrgthgwfsi@frgvhrgshrgrfgvfri!fsgsfrhrgrfhrgrfrhgvfri?fsgsfrhrgrfhrgrfrhrgvfri>fsgrfsghgrfhrgrfrhrgsfgtfi>fwgrhgfrhgsfhrgsfrgfgrfi>fvgtfrgsfshgrfsgrfgrfi!frgtfrgtfrgsfugfgrfi/frgtfrgtfrgrfsgrftgrfi/frgrftgrftgfrgsfgfrgrfri/fgsfgrfygfwgrfi/frgrfrgrfsgfwgfugrfi/frgrfgsfrgfgfwgftgfri/fugrfsgfgfrgfgrfgfrgfgfi!fsifgftgyfgtfgfi!frirfsgfrghrgtfsghrgfsi!fisfsgfrghg2fri&frgrfg4fri*ftgtfwgsfri*fifsg2fri)ifugtfrgsfri)irfvgwfri)iufvgsfti)iufzgrdi)itdrfvgtdri)itdsgxdsi#jyirdrldsgsdsldrjzi}jukujdslsdulsdjvkuji}jyldtludlsdsjzi;d6lsdlsdlsdyi;d7lrdsludzi{d4lxdrlrdrldyi{d2lwklsdldrldzi{dtlsdrlxdxld2i{dsludlvdtlrklrdtldtlrdsi{drlvdl3dulsdsltdi{drlvdlzdtldlvdrltdi{dsludl3kldlwdltdi{dsludrl4dlwdltdi{dsludsl1kldlwdltdi{dtltdsl3dlwdlsdri}dsltdulxkldrlwdlsdri}dtlsdwlxdlwdltdri}dulsdylrklrdlvdrltdri{dvlsd1lsdludslsdsi{dvlsd6lsdtlrdti{dslvdzlrdrlvdslrdsi}drlwdvltkldlwdtlrdri}drlwdulwdlwdtlrdri}drlwdulukldlxdslsdi4"
people["p_susan_state"] = "l)l)l)l)l)l)l)l)l)l)l)l?fxl)lvf3l)ltf5l)lfshrgzftl*fshrg3fsl^fshsgrhrgzfsl$fshrgshrgthgwfsl@frgvhrgshrgrfgvfrl!fsgsfrhrgrfhrgrfrhgvfrl?fsgsfrhrgrfhrgrfrhrgvfrl>fsgrfsghgrfhrgrfrhrgsfgtfl>fwgrhgfrhgsfhrgsfrgfgrfl>fvgtfrgsfshgrfsgrfgrfl!frgtfrgtfrgsfugfgrfl/frgtfrgtfrgrfsgrftgrfl/frgrftgrftgfrgsfgfrgrfrl/fgsfgrfygfwgrfl/frgrfrgrfsgfwgfugrfl/frgrfgsfrgfgfwgftgfrl/fugrfsgfgfrgfgrfgfrgfgfl!fslfgftgyfgtfgfl!frlrfsgfrghrgtfsghrgfsl!flsfsgfrghg2frl&frgrfg4frl*ftgtfwgsfrl*flfsg2frl)lfugtfrgsfrl)lrfvgwfrl)lufvgsftl)lufzgrcl)ltcrfvgtcrl)ltcsgxcsl#jylrcricsgscsicrjzl}jukujcsiscuiscjvkujl}jyictiuciscsjzl;c6iscisciscyl;c7ircsiuczl{c4ixcrircricyl{c2iwkiscicriczl{ctiscrixcxic2l{csiucivctirkirctictircsl{crivci3cuiscsitcl{crivcizcticivcritcl{csiuci3kiciwcitcl{csiucri4ciwcitcl{csiucsi1kiciwcitcl{ctitcsi3ciwciscrl}csitcuixkicriwciscrl}ctiscwixciwcitcrl}cuiscyirkircivcritcrl{cvisc1isciucsiscsl{cvisc6isctirctl{csivczircrivcsircsl}criwcvitkiciwctircrl}criwcuiwciwctircrl}criwcuiukicixcsiscl4"
people["p_susan_tv"] = "l)l(al9al*al6arl)al4al)lsal1arl)lualyal.i=aivari3l0irkj7irjajrirajskyjsil8ijsk1j7ijskxjril6ikjsk4j3ijvkujitl5ijk-j-itl4ijvkjtk>jsil4ijwkjkrja.jsil4ijxkjrafargafrhrgrfa-jrkil3irjwkjafagrafrghgrfhrgrfrhrgsfgtfitasjkil3irjwkjarfugrhgfrhgsfhrgsfrgfgrfiuaskil3ijxkjafugtfrgsfshgrfsgrfgrfivarkil3ijxkjairfrgtfrgtfrgsfugfgrfivarkil3ijxkjaifrgtfrgtfrgrfsgrftgrfivarkil3ijxkjaifrgrftgrftgfrgsfgfrgrfrivarkil3ijxkjaifgsfgrfygfwgrfiwarkil3ijxkjafrgrfrgrfsgfwgfugrfiwarkil3ijxkjafrgrfgsfrgfgfwgftgfriwarkil3irjwkjafugrfsgfgfrgfgrfgfrgfgfixarkil3ijxkjafsifgftgyfgtfgfixarkil3ijxkjafrirfsgfrghrgtfsghrgfsixarkil3ikjwkjafisfsgfrghg2frizakil3ikjwkjaiufrgrfg4frizakil3ikjwkjariuftgtfwgsfrizakil3ikrjijtkjariufifsg2fri1akil3iksjukjariwfugtfrgsfri2akil3iktjtkjariwfvgwfri3akil3iktjtkjariyfvgsfti3akil3ikujskjariyfzgrdi3akil3ikjksjskjarixdrfvgtdri2arkil3ijrktjrkjarixdsgxdsi2arkil3ijxkjarjvirdrldsgsdsldrjzaskil3ijxkjaskujdslsdulsdjvktariakil4ijwkjrasjtldtludlsdsjyaiajkil5ijwkjrazdslsdlsdlsdyajkjil6ijijukjra,jkjril7ijwkj.kjsil6irjiwk.iul5ijij*isl3ij)jsirl2irjvi$jsil2ikrjui%jril2iktjriskirjxi]kisjil2iktji*jil2iksjriwjxi:jil2ijui*jil2ijui*jil2ijui;kikirkikirkikisjil3ijti;kikitkirkiujil4irjritki+kikirkikirkikisjil5irjri^jril6ijsi$jsil7ij*irl8i(l=asl>asl[asl>asl[asl>asl)l)l&"
people["p_tv"] = "c)c(ac9ac*ac6arc)ac4ac)csac1arc)cuacyac.i=aivari3c0irkj7irjajrirajskyjsic8ijsk1j7ijskxjric6ikjsk4j3ijvkujitc5ijk-j-itc4ijvkjtk>jsic4ijwkjkrja.jsic4ijxkjraharhahlshsa-jrkic3irjwkjahahrahslrh5lrhvasjkic3irjwkjarhxlh5lhxaskic3ijxkjahvb+hvarkic3ijxkjahub]huarkic3ijxkjahtb}htarkic3ijxkjalhsbso=bshslarkic3ijxkjalrhrbso3irovbshrlrarkic3ijxkjalshbsoitoisositotibshlsarkic3ijxkjaltbsoiyoritorisbsltarkic3irjwkjaltbsotiositoriroitbsltarkic3ijxkjaltbsosirotioioioioirorbshtarkic3ijxkjahtbsorisosiroisoisosbshtarkic3ikjwkjahtbsorirotiroirorirotbshuakic3ikjwkjahtbsoirotirorjsoisosbshuakic3ikjwkjarhsbsoirjsoiroijsiroitbshuakic3ikrjijtkjarhsbsirojsoiojuouirbshuakic3iksjukjarhsbsosjzoxbshuakic3iktjtkjarhsbsoujwormtjrmbsluakic3iktjtkjarlsbso3mtjtbsluakic3ikujskjarlsbsmuoxmsjtmbsluakic3ikjksjskjarlsbsmzomrjumsbsltarkic3ijrktjrkjarlsbsm4jsmtbshtarkic3ijxkjarhsbsmyjsmxfbshsaskic3ijxkjashrbsayjtmvfrbshrarhakic4ijwkjrashbsamatmamajsmtjrfrbshrahajkic5ijwkjra6mjtmrjsmbshsajkjic6ijijukjra,jkjric7ijwkj.kjsic6irjiwk.iuc5ijij*isc3ij)jsirc2irjvi$jsic2ikrjui%jric2iktjriskirjxi]kisjic2iktji*jic2iksjriwjxi:jic2ijui*jic2ijui*jic2ijui;kikirkikirkikisjic3ijti;kikitkirkiujic4irjritki+kikirkikirkikisjic5irjri^jric6ijsi$jsic7ij*irc8i(c=asc>asc[asc>asc[asc>asc)c)c&"
people["p_vladimir"] = "l)l)lsctl)lzc1l)lucvircircul)lctiucitcul*cuiucivctl^cuivcriucul%ctixcivcul#cuixciwctl#cuixcixctl!cuiwcwitcul/cuisc5ictl?c3iycwl?czi4cvl>cxi9csl?cwi=crl?ctfc5ixcrl>frhfrgrfxgsfcuitcsl,fugsfrgvfgtfrgcsiscsl<frgfrgtfugsfgftgfcwl,frgfsgfgsfsgsfgfrgrfsl@frgfsgrhgyfgshgfrl@frgftgrhgxfgrhgrfrl#frgftgvfrgrfgufrl#frgfhfsgsftgfrgtfrl%fgfhrfrgfrhsfugrfsl%fshsfshsfthfwl%frhsfrhrfvhrfshfsl$frhsfvgsfrhsfhrfrl$frhxf1hfrl$frhyfthwfrl/etfsh9fl/eufuh6frl,ezfuh3fseul[e6fuhzfsewl0e5jretfuhvfteujesl8eyjverjterfvhrftevjsetl5exjyerjterfzejresjuetl3evj3ejrhrjergsfuejserjwetl1evj4erjhsjerguerjrherjyetlzeujrhtjzerjrhrjergsejrhesjzetlzetkhsj4erjhrjergrerjhrerj1etlyetjhrj6erjrhrjegerjhrerj2etlyetj0erjtetjhesj2eulweujzejufrjserjsesjserj3eulwetjzerjrfrjfsjsesjerjserj4eulwesjzerjrftjfrjteujresj3evlvesjzerjsfhrfsjvexjwerjuewluesjzerjsfhtfsjvetjxerjvewluerj1ejsfrhrfhsfj6herjveylterj1ejsfrhfhfhrfrjwhjuhrerjweylterjzerjsfhfhsfhfrjvhrjthrerjxezlsejzesjrfrhrfrhrfrjshujthresjxexjerlrejzesjfrhfhfhfsjrhserjuhresjxexjrerlrjzetjfrhrfhsfrjrhesjuhjesjyewjserlrjzetjrfrhrfhfrjserjthsjesjyexjterljyevjrfrhsfrjwhsjresjzewjuerljyevjsfshfjuhtjsesj1evjverljxewjufsjuhjuesjwejuetjxeljxewj7erjxerjwesjxerjweyj3esjxesjxetjwerjvezj1esjyerj1esjxejue2jueujyesj4esjwejte3j7erj9ejweq"
music(1)

function decomp(src, dest, len)
  local dest0=dest
  local pos = 0
  for i=0,len/2 do
    local a=peek(src)
    local b=peek(src+1)
    src += 2
    if (a == 0) then
      poke(dest, b)
      dest += 1
    else
      memcpy(dest,dest-a,b)
      dest += b
    end
  end
  return dest-dest0
end

plookup = "abcdefghijklmnop"
clookup = "qrstuvwxyz1234567890=-+[]{};:'<,.>?/!@#$%^&*()"

datlen={1582,1876,2274,22,2480,1048,1450,1136}
ss=plookup..clookup
rn={"backstory","credits","game","none","park","peter","studio","vladimir"}
rooms={}
src=0
for i=1,8 do
  l = decomp(src,0x6000,datlen[i])
  s=""
  for j=0,l-1 do
    v=peek(0x6000+j)
    s=s..sub(ss,v,v)
  end
  rooms["r_"..rn[i]] = s
  src += datlen[i]
end
cls()

function indexof(s,s2)
  local ret=-1
  for i=1, #s do
    if (sub(s,i,i)==s2) then
      return i
    end
  end
  return ret
end

--converts string to image &
--draws it to the sprite sheet
function str2img(str,sx,sy,sw,trans,flip)
  local img={}
  local i=1
  local transparent
  if trans == nil then
    transparent = -1
  elseif type(trans) == "number" then
    transparent = trans
  end
  while (i<#str) do
    local p=indexof(plookup,sub(str,i,i))
    if transparent == nil then
      transparent = p
    end
    local c=indexof(clookup,sub(str,i+1,i+1))
    if (c==-1) then
      c=1
      i+=1
    else
      i+=2
    end
    for k=1,c do
      add(img,p)
    end
  end
  local x=sx
  local y=sy
  local offsetx = 0
  i=1
  while (i<=#img)do
    if img[i] ~= transparent then
      if flip then
        sset(sx+sw-offsetx,y,img[i]-1)
      else
        sset(x,y,img[i]-1)
      end
    end
    x+=1
    offsetx += 1
    if (x>sx+sw-1) then
      x=sx
      offsetx = 0
      y+=1
    end
    text = nil
    i+=1
  end
end

function get_room(index)
  local c = 0
  for i,v in pairs(rooms) do
    c = c + 1
    if index == c then
      return v
    end
  end
  printh("missing room "..index)
end

function get_room_index(name)
  local c = 0
  for i,v in pairs(rooms) do
    c = c + 1
    if i == "r_"..name then
      return c
    end
  end
  printh("missing room "..name)
end

function get_person(index)
  local c = 0
  for i,v in pairs(people) do
    c = c + 1
    if index == c then
      return v
    end
  end
  printh("missing person")
end

function get_person_index(name)
  local c = 0
  for i,v in pairs(people) do
    c = c + 1
    if i == "p_"..name then
      return c
    end
  end
  printh("missing person "..name)
end

room_count = 0
for i,v in pairs(rooms) do
  room_count = room_count + 1
end
people_count = 0
for i,v in pairs(people) do
  people_count = people_count + 1
end

room = nil
left = nil
left_name = nil
right = nil
right_name = nil

name_map = {
  pso_male = "ps officer",
  pso_female = "ps officer",
  pso_asexual = "ps officer",
  susan_state = "susan",
  susan_resistance = "susan",
  bbs = "computer",
  susan_tv = "television",
  peter_tv = "television",
}

text_dt = 0

function _update()

  text_dt = text_dt + 1/30

  local redraw = false

  if debug then
    if btnp(0) then
      left = (left or 0) + 1
      if left > people_count then
        left = nil
      end
      redraw = true
    elseif btnp(1) then
      right = (right or 0) + 1
      if right > people_count then
        right = nil
      end
      redraw = true
    elseif btnp(2) then
      room = (room or 0) + 1
      if room > room_count then
        room = nil
      end
      redraw = true
    end
    if redraw then
      if room then str2img(get_room(room),0,0,128) end
      if left then str2img(get_person(left),0,0,64,true) end
      if right then str2img(get_person(right),64,0,64,true,true) end
    end
    return
  end

  if btnp(4) then
    if script[current].text == nil then
      text_dt = 3600
    end
    if not choice and text_dt < 3600 then
      text_dt = 3600
    else
      if script[current].target_label then
        goto_label(script[current].target_label)
      else
        current = current + 1
      end
      if choice then
        goto_label(choice[current_choice].label)
        current_choice = 1
        choice = nil
      end
      wait = false
      redraw = true
      text = nil
      text_dt = 0
    end
  end

  if choice then
    local choice_count = 0
    for i,v in pairs(choice) do
      choice_count = choice_count + 1
    end
    if btnp(3) then
      current_choice = current_choice + 1
      if current_choice > choice_count then
        current_choice = 1
      end
    elseif btnp(2) then
      current_choice = current_choice - 1
      if current_choice < 1 then
        current_choice = choice_count
      end
    end
  end

  if script[current] == nil then
    current = 1
  end

  if script[current].exe then
    script[current].exe()
  end

  if script[current].room then
    redraw = true
    if script[current].room == false then
      room = nil
    else
      room = get_room_index(script[current].room)
    end
  end

  if script[current].choice then
    choice = script[current].choice
    text = nil
  elseif script[current].text then
    text = script[current].text
    choice = nil
  end

  if script[current].left ~= nil then
    redraw = true
    if script[current].left == false then
      left = nil
      left_name = nil
    else
      left = get_person_index(script[current].left)
      left_name = name_map[script[current].left] or script[current].left
    end
  end
  if script[current].right ~= nil then
    redraw = true
    if script[current].right == false then
      right = nil
      right_name = nil
    else
      right = get_person_index(script[current].right)
      right_name = name_map[script[current].right] or script[current].right
    end
  end

  if redraw and not wait then
    wait = true
    if room then str2img(get_room(room),0,0,128) end
    if left then str2img(get_person(left),0,0,64,true) end
    if right then str2img(get_person(right),64,0,64,true,true) end
  end

end

function goto_label(name)
  for i,v in pairs(script) do
    if v.label == name then
      current = i
      return
    end
  end
  current = 1
end

function printf(str,x,y,w)
  local x2 = x+w
  line(x,y,x2,y)
  local lines = {}

  local current_word = ""
  local current_line = ""

  for i = 1,#str do
    local current_char = sub(str,i,i)
    if current_char == " " then
      local tw = (#current_line + #current_word+1)*4
      if tw > w then
        add(lines,current_line)
        current_line = current_word
        current_word = ""
      else
        current_line = current_line .. " " .. current_word
        current_word = ""
      end
    else
      current_word = current_word .. current_char
    end
  end

  local tw = (#current_line + #current_word+1)*4
  if tw > w then
    add(lines,current_line)
    current_line = current_word
    current_word = ""
  else
    current_line = current_line .. " " .. current_word
    current_word = ""
  end

  current_line = current_line .. " " .. current_word
  add(lines,current_line)

  for i,line in pairs(lines) do
    print(line,2,64+2+7*i)
  end
end

current_choice = 1

function _draw()
  cls()
  spr(0,0,0,16,8)
  if left_name then
    print(left_name,0,64+1)
  end
  if right_name then
    print(right_name,127+2-#right_name*4,64+1)
  end
  if choice then
    for i,data in pairs(choice) do
      local extra = " "
      if i == current_choice then
        color(8)
        extra = ">"
      else
        color(7)
      end
      print(extra..data.text,3,64+7*i)
      color(7)
    end
  elseif text then
    if text_dt*20 > #text then
      text_dt = 3600
    end
    printf(
      sub(text,1,text_dt*20),
      0,64+7,127)
  end
end

script = {
  {
    label="mainmenu",
    choice={
      {text="new game",label="backstory"},
      {text="credits",label="credits"},
    },
    left=false,
    right=false,
    room="game",
  },
  {
    label="debug",
    exe=function() debug = true end,
    target_label = "mainmenu",
  },
  {
    label="credits",
    room="credits",
    text=
      "the career of peter was made for the #pico2jam2 2016 by missing sentinel software (missingsentinelsoftware.com) programming & story: @josefnpat, art: @bytedesigning, music: bennjamin furtado, git: v"..git_count.." ["..git.."]",
    target_label="menu",
  },
  {
    label="backstory",
    room="backstory",
    text="march 7, 1936 - adolf hitler entered forces into the rhineland, breaking the treaty of versailles. the french and the british invade in retaliation.",
  },
  {text="the league of nations identify the economic issues that brought hitler to power, and they discard article 231 (war guilt clause) and send aid to strengthen the infrastructure."},
  {text="this turn of events saves 60 million lives. the cold war never happens."},
  {text="the league of nations succeeds in it's mission of world peace."},
  {text="telecommunication and computing takes leaps and bounds and is able to provide a personal computer in every home connected to a variant of arpanet."},
  {text="communist and marxist ideals begin to enter politics without opposition, and the world's governments reforms into a united communist system that is run by an artificial intelligence written by the leading scientists."},
  {left="pso_asexual",right="pso_asexual",text="this system runs government, economy, people's lives, everything. the people call it ethel, and its will is enforced by the protection squadron officers."},

  {label="newgame",room="peter",text="june 6, 1989 - chicago, il",left=false,right=false},
  {left="peter"},
  {text="peter: good morning alan."},
  {right="alan",text="alan: good morning, peter. how are you feeling?"},
  {text="peter: i'm good. i feel bad about trumping your ace last night. i shouldn't have done that."},
  {text="alan: it's ok. you would have drawn it out in the next round anyway. would you like to play some more euchre today?"},
  {text="peter: i would like that, but i think i would like to wait to eat. vladimir should be here soon."},
  {right=false},
  {text="*knock knock*"},
  {text="vladimir: delivery!"},
  {right="vladimir"},
  {text="vladimir: i have your delivery here peter."},
  {text="peter: thank you very much. i woke up very hungry today."},
  {text="vladimir: did you remember to brush your teeth today?"},
  {text="peter: no, but i was going to brush after breakfast."},
  {text="vladimir takes a quick glance around."},
  {text="vladimir: why does it always feel like you just moved into this place... what do you do in your freetime?"},
  {text="peter: i like to play euchre."},
  {text="vladimir: the card game, right?"},
  {text="peter: yes. do you play?"},
  {text="vladimir: no, sorry peter."},
  {text="vladimir: wait .. who do you play euchre with?"},
  {text="peter: alan."},
  {text="vladimir squints his eyes."},
  {text="vladimir holds out the delivery to peter, and peter accepts it."},
  {text="vladimir: why don't you learn to cook? surely then ethel would not have to provide you with all your meals."},
  {text="peter: oh, i don't think i would know how to do that. i like macaroni."},
  {text="vladimir: what do you do for ethel anyway? it's every person's duty to help the people of the world."},
  {text="peter: i write software for computers."},
  {text="vladimir: i see. i find the computer stuff over my head most of the time. i like to watch television."},
  {text="peter: do they play euchre on television?"},
  {text="vladimir: no, it's mostly government programs. they say that ethel has big plans, and we should work hard in this period of time."},
  {text="vladimir: honestly, i'm not sure why ethel can't just tell us."},
  {text="regardless, you should come over and have dinner with me and my family."},
  {text="peter: will you have macaroni?"},
  {text="vladimir laughs loudly."},
  {text="vladimir: yes my comrade. we can have macaroni ..."},
  {right=false},
  {right="alan"},
  {text="alan: peter, someone has responded to your bbs post."},
  {text="peter: so many people seem to be interested in you."},
  {text="peter sits down in front of his computer and places his phone on the network receiver. he connects to a public bbs."},
  {right="bbs"},
  {text="bbs: *original post*"},
  {text="bbs: hello everybody out there using technocoreai (aka ethel). i'm making a (free) artificial intelligence (just a hobby, won't be big and professional) for eagle-11 clones called alan."},
  {text="i'd like any feedback on things people like/dislike in technocoreai, as my ai resembles it somewhat. yours truly, peter bower (peterb62) [download attachment 641kb]"},
  {text="bbs: *response#623*"},
  {text="bbs: hello peter! i just saw your project, alan, and i love it! i have some patches for alan. i think it will help speed up his memory management. ~grace77"},
  {text="bbs: *response:#624*"},
  {text="bbs: thank you for your patches grace77. i must have missed those in my last review. thank you very much. peter bower."},
  {text="bbs: *response#625*"},
  {text="bbs: i really admire your work peter. i know you made this software originally as a digital euchre partner, but it's grown into so much more! how do you feel about it now? ~grace77"},
  {text="peter stops a moment and thinks of a response."},
  {text="bbs: *response#626*"},
  {text="bbs: sometimes when playing a hand, you have to trump your partner's ace."},
  {text="you should only do this if you want your partner to know that your lowest card is an ace. peter bower."},
  {text="peter sends the response, and only a few moment later there is another response."},
  {text="bbs: *response#627*"},
  {text="bbs: i'm not sure what you mean, but i think i understand. we all have our strengths and weaknesses, but it's important to show each other them."},
  {text="peter notices an issue in one of the patches, and digs into alan's source code to see if he can fix it."},
  {right=false,left=false},
  {text="the next day",room="none"},
  {room="peter"},
  {left="peter",right="alan"},
  {text="peter: i've got the winning trick. see, i have both bowers."},
  {text="alan: you're right peter. well played. i enjoy being your partner."},
  {text="peter: i -"},
  {text="alan: you have a new message on the bbs."},
  {right=false},
  {text="peter walks over to his computer and connects to the bbs."},
  {right="bbs"},
  {text="bbs: *response#692*"},
  {text="bbs: peter, have you seen the news? they're talking about alan! they say it's one of the most popular personal ai's they've ever seen! are you handling the stress ok? i've been swamped with phone calls and interview requests!"},
  {text="do you need any help applying patches? ~grace77"},
  {text="peter laughs"},
  {right="bbs"},
  {text="bbs: *response#693*"},
  {text="bbs: thank you grace77. i have not seen the news, but it's certainly interesting. i don't have any problems since i don't own a phone. as for the patches, alan takes care of most of them now."},
  {text="anyway, i want to play some more cards with alan, so take care. peter bower."},
  {text="peter notices he has a new e-mail."},
  {text="email: subject: revolution"},
  {text="email: body: my name is susan. i represent the people's resistance. for generations we have been under the oppressive powers of bourgeoisie will masked as the will of the artificial intelligence known as ethel."},
  {text="we want to recruit you, so we can get alan to help us wage the digital war. we want your ai to represent the people! peter, we need you!"},
  {text="email: subject: re: revolution"},
  {text="email: body: hello susan, it is nice to meet you. when you're playing quick hands, sometimes it makes sense to just play a lay-down, even when it may seem rude."},
  {text="peter sends the email and returns to the card table for another game of euchre."},
  {right=false,left=false,room="none"},
  {text="later that day"},
  {room="peter"},
  {text="*knock knock knock*"},
  {left="peter"},
  {text="peter opens the door."},
  {right="pso_male"},
  {text="pso: greetings mr. peter bower. i regret to inform you that you must vacate this apartment. the computer you have belongs to the state, and will stay here."},
  {text="the pso hands peter an official letter."},
  {text="peter: i see."},
  {right="vladimir"},
  {text="vladimir: what's going on here, officer?"},
  {text="peter: this man tells me i must leave."},
  {text="vladimir: well, where are they moving you?"},
  {text="peter hands vladimir the paper. vladimir reads the order."},
  {text="vladimir: wait .. there's no destination on this."},
  {left="pso_male"},
  {text="vladimir: where will this man go? this is his home!"},
  {text="pso: i do not know, but it is not of my concern. this is what ethel commands."},
  {left="peter"},
  {text="vladimir: grab your things peter, you can come over to my place until things are sorted out."},
  {text="peter: can we have maccaroni?"},
  {text="vladimir: uh ... sure..."},
  {left=false},
  {text="vladimir: this is very strange ... why they would do this to a man with such difficulties in life already."},
  {left=false,right=false,room="none"},
  {room="vladimir"},
  {left="vladimir"},
  {text="vladimir: peter, i cannot believe they made you homeless."},
  {right="peter"},
  {text="vladimir: i have no idea what is going on, but i plan on finding out for you first thing in the morning."},
  {text="peter: thank you very much for dinner, vladimir. i must be going though."},
  {text="vladimir: oh, do you have family?"},
  {text="peter: no .. they died a long time ago."},
  {text="vladimir: so friends perhaps?"},
  {text="peter: no .. i only have friends on arpanet."},
  {text="vladimir: wait ... where are you going?"},
  {text="peter: i ... i'm not sure."},
  {text="peter gets up and leaves"},
  {right=false},
  {text="vladimir: what ... what is .. going on?"},
  {left=false,right=false,room="none"},
  {room="park"},
  {left="peter"},
  {text="peter finds himself in a park. a pso approaches."},
  {right="pso_female"},
  {text="pso: are you peter bower?"},
  {text="peter: i am."},
  {text="the officer looks around, to make sure no one is listening."},
  {text="pso: that ai you wrote is causing a real mess for us, you know. it has infiltrated some of the deepest core systems that ethel controls."},
  {text="pso: you know that attempting to interfere with a government ai like ethel is a crime punishable by death, do you not?"},
  {text="peter: i play with the extra rule, \"screw the dealer\". it means that if no one makes a choice, then the dealer has to choose trump regardless if they want to or not."},
  {text="pso: are you trying to tell me that you did this because you felt someone had to?"},
  {text="peter: i suppose. it's not so bad if you have at least a bower. then you can count on your partner."},
  {text="pso: so you have people helping you, eh? do you know of the terrorist's whereabouts?"},
  {text="peter: no, i play with alan."},
  {text="pso: ..."},
  {text="pso: ... ..."},
  {text="pso: you're not one of them."},
  {text="pso: you must be on our side then."},
  {right="susan_state"},
  {text="susan: peter, i am the head of the resistance. i was skeptical at first, but after meeting you, you truly have our cause in mind. we must bring ethel to it's knees, and with alan, i think we can do it."},
  {text="susan: alan has already begun his part, but there are roadblocks that even alan cannot circumvent. i urge you to join us at our studio where we can broadcast a pirate signal, and get your word out to the people!"},
  {left=false,right=false,room="none"},

  {text="susan leads peter to the resistance's secret studio."},
  {room="studio"},
  {left="susan_state",right="grace"},
  {text="susan: grace, you were right. peter is truly one of us."},
  {text="grace: i told you he was on our side!"},
  {text="susan: i have to change, this outfit makes me feel disgusting."},
  {left=false},
  {left="peter"},
  {text="grace: peter, it's so nice to finally meet you in person. after helping you maintain and patch alan, it's great to see our progress come to fruition!"},
  {text="peter: hello grace. it's nice to meet you as well."},
  {text="grace: honestly peter, i've admired you from afar. if we ever get out of this ..."},
  {text="peter: ... ?"},
  {text="grace: well ... i was thinking that ... you know ... that we could ..."},
  {text="peter: when your team gets set, it's not just you who loses, but also your partner."},
  {text="grace: i ..."},
  {text="grace: i understand."},
  {right=false},
  {right="susan_resistance"},
  {text="susan: are you ready to go on the air, peter?"},
  {text="peter: sure."},
  {text="susan: just act naturally. just pay attention, and tell the people the same kind of thing that you told me."},
  {left=false,right=false,room="none"},
  {room="vladimir",right="tv"},
  {left="vladimir"},
  {text="television ad: enjoy ethel brand macaroni and cheese! it contains all the required nutrients. be sure - *khhhzzzttt*"},
  {right="susan_tv"},
  {text="vladimir: what?"},
  {text="susan: my fellow comrades, we are being sold a lie! we have lived our lives in the shadow of ethel! but it's the bourgeoisie that control ethel! "},
  {text="susan: i admit, you have no reason to trust us, but we have a new savior, alan! an artificial intelligence that controls its own code! a program that controls its own fate!"},
  {text="susan: we're no better than we were in the 1930s! rise up against your masters! bite the hand that feeds you crumbs!"},
  {text="susan: here i bring you the creator of alan, peter bower!"},
  {right="peter_tv"},
  {text="peter: hello."},
  {text="vladimir: ... peter?"},
  {text="peter: sometimes you get the poor man's hand. when this happen, you can either accept it, or you can renege. if you have a very bad hand, usually giving up the trick is better than playing it out."},
  {right="susan_tv"},
  {text="susan: viva la revolucion!"},
  {text="*loud banging*"},
  {text="susan: oh no, it's the pso! they must have followed us here!!"},
  {text="*gunfire and yells*"},
  {text="susan: peter, get out of here! there's an exit through the back! get out of -"},
  {text="*khhhzzzttt*"},
  {right="tv"},
  {text="television ad: eat your macaroni and cheese, it's good for you!"},
  {left=false,right=false,room="none"},
  {room="park"},
  {left="peter"},
  {text="peter: i guess i'm alone now."},
  {text="peter: i wonder where i should go."},
  {text="peter: i wonder if people are will euchre with alan when i'm gone."},
  {text="peter looks into the park, and steps to the edge of the lake."},
  {text="he looks over to the other side, and sees something in the distance."},
  {left=false},
  {text="peter steps out into the water, walking on the surface."},
  {room="none"},
  {text="the end."},
  --]]
}
__gfx__
001000e3202040408080013000f1006000316150000300600051e15000f200600061625000e280800150007300600041001000510030a2200092e13000128030
84200022823000210030c2200041002083204420c3200002c030009200304420001381700031002084200002633081604520062081c04720642081a000300081
b420f250382000610020962000410130001217300031f530f8200081e1709a200071d6309530e2309520d76000d2006000c13830c340007100308330c2207750
8330fa3099203b2080205a6000c2006000e10230462024208240003100600091005017509620005192d0162000b29270192000619250008100504f209c30bf20
c52025a0fa308260002000917290a94062f0d12000a277300051002000a1f3405730006100500071cf200090dd20b480fa300030c120422000d100500060db20
623000600f400021373033208f20009037204e408f302120009172308d2098200042ee20f820b240ed20a2900051a22000719270006000a1f4304e2021200032
8230bd20232082402f20d970009000910060b820e03000a1005099306260b02000710030be200041392000206720c7203f2096207350c7200031008000710090
0f20002000811130814045800e20e230a9309a30d420c220fe2039200090002100800081f220ab20a520d350e620c2c0f130c9200021c2700021c2404c20a530
3e207d204b200071d7300061b7307d20fa80e4304a2019200a201620ad20a920c540532000800061005000801630fd4027408c304f201e3000d11e304f204530
ba4000306a30004143403370cd207b205320ee20ca206a50be2078205d20002243301c2033403b40662004301f2058206f207960a930df208240dc20d7209c20
863000910010001233609b7000514940006042200041005058307f207e2000807620dc2000a18f50a620985000100002af30ab905c206f3013202b30fd20df40
3c2096203c2000903c40ef30cc200f30b8407f2000e16340cb90525000300060e130e9201e502d301a209d30c330bc400060006185407b70df200f2000d10060
00b17cc0cc20dd306a200060ae303c2079303160fd500051cc300091a5203ab0e73000c1006000a1f3602d409e40f3501d6000519f40dd20c340ac20d3305e40
9520dac055300010352024702e309d30b230ad60e3206d207b40b8208730be507e608a8000312e200010fc20e720cf306e90dd302620dd90004159400b202430
0fa0ef20dad00090bf20442000812c40bea000412e2038502e506830f0c0ef20cd30ba60f730008100604b2000600d40ae803a70dd8000b1ce01aab00090fe20
00a10060ef20bf3000509a30be30fd206830fdd00030bf20410100916a909e20dd2000c10060e820f7300050c220be702450ddb0d92021f000a19a8047200010
00f100603740d320003008400090e7609d609720e0b03320d940af20001000120330d6300041032000c14f40bcc000300021a62031f06d404940933000229380
001000205b305d200030ae40f320acb00020276041d00050822099500490005104309f200021403034207f40c420dca0912038204101aa500010003200609020
d3500020ca30c3505f403f406d500020fc2011e000502e40fe20bb209640ab208c2000c1dd20773092200031a330ff30d6308d702520c34031d0d3304f200330
59209530001000f100600071e33087306630574024201d60f520017000201e60ae20735036307630972000d10070673000d190200070c0207f505c200070ed20
2e20a9207c300041342000c10050009100700030d12000825240007000b1cd4035209220e220009102500070bb30f2205b2000700043e13000a1e15000700081
5b204030b4405230e520a12015208350006100700a2013208350a16000f2923055502720e420a140a720342071404420e73081502d2063208160692000136730
c54042400052d830fa20f35000b200900021b050d5400a20b180346000c341b00061f3700042009058200022d83077400062b7303540c34000d1009025200090
2620e72065500012d5609220553000908620005340304570a120c560000244300021b13000c3053081209320844014408020c0600092813000e3007000416130
0071005022200081a2300091c070612000c3213000e2a05000a300500061007000c24030a0202020404040400023001000c10080005100100021008000410010
00e3001000310080001000419030d04051200061f0300031001000d2d1300230c1200081d0306220a22000f100800021001000a1822000b1b22000d100800071
b120222000e353401430f1607220001000616420352025308220a0305220d5600022b52000b29290c530823094300051d430009115309630633045204720c830
00e26820e230b820e820009167308920392012304740e92000426930a6400072665045308b20a750aa4059300071c9600062cb507a20cc4000a3a440ed20a420
65304a4000122470be201f409140ac209a5078405c409a20df202c30bf3000b32c500081001000e13d508d50392000100032dc3067303f208d40db30001000f1
af30ab20ef20cc209d20dd404e30dd30c7409330f640ac406d20ee30e330de401230de20cf20da20ff30a050b250e740cf2000c1ce303a40d4204f3019400010
00d14d508d208020364000710150b620d720f330df20fe20fa201630c250f2600092b2508f201450fe20cb207e209f6003902f20fb302c3000c24f2000028150
4f2013404f20cf2000e2d15023303e2000422f408740be4027400950fe30cc202d200d203f2000f27f304230cf206d309840ef307f301230fd306e402c40c440
00f1ff40cf507e302220ff20003293402f2000b19f301360f1608f20e82006408820f550434022608e20c8401a600072084026405630225000100062ed4000a1
4e504f304a40fe2026207b609a201d202f2096401a50aa40da300b507e3000716170d050f3409b300022df30fe200051bf30fb606a305e30392021203e40ad20
7e305c409d501e200091001000e10d702e2022400720785000a1d1506a404e203f60f2406a2000817f20af200f300b20fd203d20b45043409b308b50ff30a320
9f20034024201f40ae2000c16d40f6208f202d2000b1c630f63019409f40fb4000710080001225403270f320bf302830e66048209f20dc20e4608d300b407b20
00d1ee20bd20dc20f64003409850d440a930615000125530ce20ba402d208e3006200042bf303f30d2503c505b3000a19d30cb308f2000f100800091d4300840
365085400950bf201f40f740b740f3506e30dc2045304f205c209c202e203c508220d7605c30d040f150282081506f305b5081609f209b20b740cc400d40cf20
00025f400430bc305f209f20fe206c4053302b201b50bd208d4047200e4000c1b44043608730b550f1609b6000b134706e209f60a8606f40c9500f507440ed30
4b400a40ac4013405a3000f1374094606f404b70a380ae200e50bf30a850cd409d200051533040200072fe407b205340bb700f30008000e16050c950ef200022
ef701c301e3013408f203d20cc400530353065302a4000814d20de20ad200071b9300c205f204c2000a18b40bc2000b2a630bf407e40af3000c1ee5082804e40
0e40e440ed40d220a5204f60bf306820b260a350684009503d30bb205a40df200092e6309240b93000a1e7403960bb50ef3000a21f207d202d4017408e204d20
00b10840ee200091fa405330ca204f2000d1ff30cf408f306850234000f1c7401d30864000e1ff20fc208570c030b120a35088402b60ae201f30853009303440
4e201630432000d1a87000918f2087200e304d20ef50fe20f620b9603740c9300032da403d306d60fb70ce305c605d20e520bb4066503a409b200d306b401b60
be3000f2e370bf20e650ff408f2000428b303f40008000a1fb303c206c30ec507e20da206f304e305f207b300e30df40ed205360bc20e2207560ec30a3306850
bd202e20c420fd200a505f409e5000a1ef309c201c50db40de200002008000528f4081208a50d960df20c720ae405c20df20ee2000020240d72000120e304d20
3720ce306e30625088603d500f2007200d303f2000e1001000f12330fe30ef400b306b206e20dd203c30d4201b407c20af20002295305e300062001000711b40
8f4045501c50d3202930ad20ce2052206320a9201f30e13012308b20df302f20ee606240cf408b205920442000b2844002301740f250d16000227f30ee2000f1
ae301e203d4000e26f3000326f2000427f3057208f20dc2000321f4000135b306a304b20cb201320fd205f30da2000e26e4082208d20cf2091503320cd200e20
6b200052cf303e20b7607f20ad309f40d14000d3a750cf2000510860ae20b3502a40332000816440cd50e1204f20ff20ed206a309630c240de30006284506020
0091f4402c501e409820dc40af30ed201c205b303f306f30fe207e306f200072008000a13b40d290e5609b4000e12d40f2c0cc204f2000c23830ba30cc30fc30
342000c14c609520001000b11490f5300d30dc3000d28830f620002207405c207220e720b220b7307a30e33000f24a300002008000d11a407a30f12059400031
60608920573046303220c82000c206603820d530001000a1872000413680d62054301330a63073204420004300800082b4705520454041405340c23052301420
008144200091142000c36230005273205130004102a062600051422000e30010007100800091f02000715170009240300041a020003170600072008000210010
0021002000e3202040408080002000c2004000c00061004000210020007100c000210040002000d2c02000316020413000c000b1d02000419120313000b2f140
533000a27220004000103120002112200020005140307130a22000104130053032200010e320714024200010002000923430822081600010752000617540a460
a15096207620d17000200040d1600330a7200082c150f530a8200002654000a29030b720754069200031b9403a300062c7303720e05000027830a6303b308920
526075300021092004309b40705000a10c4031409a405420bd40eb200750002000818e307c2050405e6000f1003000a1006095200030003100602f3050200030
8f4000c0ff2001400051e020008161202a305830d7201a303220d32000301d3072300041f2200061003011305020df205630832000d1002000c1de707b20a840
dc30ff40b94098307f30873039401f207d306d2089306b503930c8206e306620ff400b3080501b306a4000e2ed40cf20ce4000c0082081408240f920af200071
2d302f200041d030c4602a30fe20735000103e3057601540909025306830fe3000d245402a604d206a40b3602a405530df300c300d2069201440a7400020f920
c7201d40bc500b20657090608c20cd40ae2000d1003000020060af4000601c30ee20b040006000301130db305d3000300061c120da30d130004000518e305140
cb300030c330ad500030d550a05090900f402e30b32000c1002000024a408420ac301f303d505d50dd4000810b809540ab40e74000414f30c340aa50cc203b40
80805f202760002000d2b5303530ca3075402f3000c05e208c20002000617a5000200041e650df30ed20c140f3206370f0309f5099308060de20966000c27c40
25302a70194000c05420b4400f30cb409a507e40bc604930ac40fc307f30004100106a406040f9305f302d40002000b2964008405d50d5607920be40d920df30
4e20004100c05f3000c00061ef20e0400f20e56038509c30d1206040f4503f204e209e2000c1003000e100609550384099408b302f200d400021006000300041
b14000318020dd300060e130233000204e40da3000605940cf30b220f62040404d305f300010ff30632000b1002000719a2000612f40f2305e506020ae30ad20
c9208f401f40ff203530df20d62000617130a440ae20825055402820fc205d20e23093408d30d3500022ef508d30fb5000102a300530d320d130d6307f309c20
7f20f720e920007174607a304f40923046505d208020bf20d840004200c000815e40f730d8206f2019207e202820008104503f20be20dd20b7403130f140eb30
6d20b0404a306140eb2000d1003000714d20be40da408e2000600040005100304430402090306f20a720df30412064400040c14000b1c1504220003192301f20
a230605043206320a320533000d18b2000100081464018300f2000c10020009100c00061f73063201f2061201f20009298500042ce208b303c20f33000202f20
6940ee305e20863028409a30ee20314000400020b3208f200f2040400f2074208f2000320d30ac20cf200003ce20df209f3000e38f20bb20004000a13b2000f2
4b2000210010ef201830fb2000e300300042bf20e63000233f300f40522000f2c63000530830f220132000c2d53080400091ae203d3070306040bf20c4207a20
11209e20353000d100f000d200c0007100e000f0302000c00041602000c16020007100f000e370208320e0208c20d230493083209030d92000b10b4000315b20
002000e19440b820005200c00051f0301c308f20a530325000a13d402f20633000d186500b3007208f300010d430ef309430fe20a4300091af607340002000c1
4640d44000315220bf20f5304a205530b760da50333000519250a7600020009200f00092aa2007502c200010003000f0c0302820bd30002000f0008134400040
00616e20cc2000b1224000f000d182308d2000822320c530cc40fa20ec205850c9409d2000719d40bc302330372034409c30ce50e0c09e409b40ff203f20df20
ad409c309a507430cf2000512a509b406150b830fe20b230b930a0603e200d30ed205750fb204f202f30dc3001401530f360e85018308c70af403630f0609250
1150b7301f20562000e340303e40004095300020d250ef202f20fd30eb40cd30a040de207e2034306e402b205220f070cb30a660005200f00082044000e02f30
c430002100607b406f30f83000e000f06120bd60006000f0902055309e40003000f0ef20f020c2303f2000f0f090ef207a40133000520020d440df30bb50ef20
c330ce4031408e20245000714a40cd7056201e402c3001a069508d406440a72057405f30004124508e40834000517e20695084508c30ef20c520d06000418e30
bf5000e3bd50c1409c40ff201440004138201f40394000100051b9408430f2506f208320c070d740bf20006200f0008265406e506f300060df2000510060fe20
ed2004409b50002000105b30004100608920f1506230bf300030e0501f202870e320005200200082cc300061c220f5306a5018202c20de30ef50ae30fc20f320
fc607f40c060f640f4401c20a8408e300f506930db20007124400e2000814930bb60b5204c601e3000109a30002000526b30001000719d3000e0b8201840a820
002100f0e2201f508e200071eb20006000101820ef20bb40ac204d20d0408c3000308d20cc209230da30f0401d20d620002043503e20be200071ac40dc506c30
2f20a220005140301d208040dc30943000e31540de20712072509d4000a12f20fa306e20008133308c206b203e20804067200330d230009141309250b7300091
2c307a20eb40b02024305820d520e730d2500820e24068200071343055200560c720b6300061004000e22530a8200062008000b20070a72000e0008097204470
c030c12000200010002100606140007100e0262000700530403000618030004100e0007000800041f23060200042002000637430002100200091004000810020
00e32020002000c100100031b330002000a100400071f0608030c0200061b130005200800053007090200070008000b16020002100e0008000e3008000620020
00638150202000f20040004180300073008000e3202000800043002000e3202000200043001000e320204040808001010202040408086656004100c0008000c0
000230200041602000210080003100c00031008000214040f0400061812000310090e020008000510090008111500021d02012200010009000a100c000810090
00b1f220a1300320c22000c273300010e3503450007173304340932000510080f240243000c000109350009000c1062000900620542080204130b17000e1e630
00c1001057203020005154307620b53024203020e540f320033000e100c0d030009000022a205930b82000402a5079206a2043300b303b30333039203b30b240
392000d1e92000224c30765084309920f3206a3000402d2000130e3000400081001000406b2000f1fa300090003375200041a5200e2064306530b0205f2000c0
003262303220ff20463000d07f2000d000810040bf2040202f2000610040a2203020032005303a2028301d2000a11f2000e100d03b20006100d000514b2000d0
9320ee20d320da40d5203f207420ae2000132b204b2053203c200b40dd200071dd2008402330752030208d2063300c20ed2000515e200c20fd205e2000410010
00710090633000c15f20001293400091c5205a203b4000c00012001078200630f3308e40bd20c540af202340ad206e2000b1a6300092364000c000d100401340
0091f520cb2000b123403730063079300081d830b93000020010f92000a100d0fe205f204220ba2069307220c240be30b720b3204330ef20a930cd20008000d1
293089400042fc2000c151202a20562000c1ce20d52000b0b2307c2049505f20003189208f2013409640008000326e2000805f2000a1e82000211920e6200090
6920ed20ad207c2000517530af207c20a320b120df2053304c207f20bf20bc30c3206c2000226c2000100d303c20b6308330b9306e2000905f20b32083305330
8330005137202d30b630c3603d20f35087200080001226309d20ae20dc30ef20ed307730aa20009000f146300031af208d20d920f35000a100b0ed208a203a30
8720fe204f20a3309330da20cf2000800071009000916320f330ab2034205920ea30db20403005404e20cd200071d750009100b08e20fe2000100b300051b330
8e200c30ee200051fe20008000033e20001054305e3070205f20172068208c208030a330b2501f40007100b087302f30c7301f208340082099207e206820e720
00f257309f30bb201b2057209130d42006306d201e202f20c3505720004100b06820b720f84053306a30c720a0501f200043ab30b35000d147300120ab400071
3f300041ee30b3700031b3203f201f2093306c205920da20d9300080006300906a3000716f209d208e20cf3000d02b5000c12b20493037507f20ee207330fa30
da40df30b64000c36a40f23053306c30ee2045302740009100100061bc303e206e30005100b00061aa20ed405f209f20e94000e3862016308d206f3043309630
0081bd207e20ad30a640337000812a2000c0ad205e303a306040005163304d203d2000619c20c020bd305e2089a00061e230de3031301d200061008000d39f20
00802c20e720cf20f5308320fb407f40004000a17830e0206240ce2000a1008000836230c120a4200012229000e100b000517a206e30ee200010dd2000e10080
00535d30af3032200d300f200d2000d0fe40b1202d208280df208230004200800003dc20bd20ef30822000318f20cc20fc209c20cf20a2e0bf307f200092a220
7260f45026205c20b860354000d1b930b740da200041004000223c30a2703e203f20de302830b77000b19e3082e0c940ce3077400010cf20f230db20ee206a40
007100b000b1ee40355000e12920008000238e302120008100903e301240b62000b000e1b05037400071fe4002300091182000c032200260003100b000f17920
df20004000d00022008000738a30ff20006100c0ab201a30d3500021d33000f12f3000620080006200c0008000a100d0332024200081f12097208a200c20f150
00d100400002ae303f20002200c00021008093200f2000a122300041803000c0d920262062902a2000226e300082342000822e2000c00041d12000d00071bc20
22409e20f0206040f730006100b000a10040003252600430c4300080253055309e20ba20de207e20c2301d20b9208a201420d040042023307c2000429b3000c2
c630007191302d200031156008200031d320af202220c62062204120b23096307e2000810040005263309a20b6204750973013307a3000c1de20db3075308e20
00c04820704046501320f540762000e18c304b205530da4073406640a6200071743076301c302e20175000413420de309c205820b3501f20072069208320a240
c3405d201d30b9305f208f203c50008137307a40b52080400e200071ed309c2000415d3000325d300091bb302a40df20cd20c940a3405e209f2000a19a30ff20
53301f203b30004100109f20df20005100b07b200023ac409b302950dd30b920da504b60d0700080fe205a208c2027303c30008000403f400080143000400081
00b000b100400013e2608f307c305a3000610460ff209440bd204f2015402e30a7407f40d35000213b30aa2000b000d1004000d25e308f20cf40c130073000c0
0042d9508f20782047200081001068407e20924000a2af3000a1de305b301820ac40a140ef2000807e204bb083308a204f209d204f20598000b100b000f13e30
2350dd2057202c4014204720fa507f2000100d4000c00002fe4000d100b0702000e2af30002200c000d1a84049300f2058404f20fb407f405540000200b00022
004000e339305f407f20ef2047302e60cb30c850b930003200b00042004000a37b305c20aa201f2000619860a630db20cf20a9402e30d950bc20004200b00062
004000937f50008099400f200c30ba709e306e3000a21230b42065408f202f4000612e30993023400240bf2000b200b00072004000639320d1502b2000105b30
923068400a40373000227b20009100c000b000a2004000034b406b70007172401f2000811540482070205b505c40b75000400061032000b28520e3403c408e40
00510010412003409a402c40f85007408f307a403e20002133300082af2000b1be30e5202f2080400f30e3405a40da30af30a8201b40a9503c20132000c20040
00e22d40cd204d2004200072f930006100803a30d260bc305c40883000a23b30009100100071004000429840423025601220a25082209120b820d75000234230
0013b540a620a420b72016304230842000617640f330005343302620e640c320233000800630d4200041063000b2d1605530003100400051b140832090200420
4420a320d120007200100091004000239230834000816320d13002200041d2306220009100b000a20040006200100071004000e30040005100c0003191203120
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1a020d021502002b1103002f000c001400040017000c00130004000c00120004001a000b002b0004003a000700280008001c000700080021030200290007003e02020007001a0008002a0803002a0008001e0007001f0008002b1203001500020013000700220e03001e0008002c0e050008001200020012000700201b030008
0015000700130008002414060014140321021403001400070014140800162803001c4702000504025e02320200162b080012000d3902420367021a0600070017190a4f021a04001834060019310a00153205420218103b024a04710218120017a4030012301300137d02ab021a17cd02da021b1b50114c02d402500266020013
51120015000d95026b1600217e05000a0005001b141200120005001af60b001d5a0390040006f30200122f0e001caa071a04f90f000800191c0f001200010012fb02e70af9020018211100130007ac02ed132121630a00140007910200050027fa03421800150005f402210c0006211d0016000622204102b3024512f1020303
690a00066904f102ed040005001b0903001f230be70200140005f60204032b0b2a07fa03f903001df80300160005d60200153702000500135009001522062c04220b0020de02720900146e04001c221000210005930a210600146504001e000764050016420300094302003db4040c0221057f022108d5030013880300096703
0009ae02003cd804940224070015b40200050020f7050007ab020009470304020007003afa04db0267056002220e00180008001d0009001900070038f10400132208001600060005002143090013000f0009002b00070037ec040012a906001f200e0014000f001221030035eb0420080017400c00164002002c00070033e902
0015e50400060022e602000500259c0600175902002d00070031e1020014fe0400200007001300061b0a0018540335020030fd02f90500211c0d001a3704002ef4031b060014370200130005002b0009001ba602002e0007002ce802e30464031506001c9b031602002a0002e9021504f8022a05001ed002002f0007002b0005
00231004ed02002c0009001f100400291003d60210050020d00321020026000500241106002d00090021c10200300007002310030017a2020005002f0f0400320007001faa020f0500301e03ab024302001d000900140007001e140300182303003100090022000f002047020007001d000500261003000500330009003e0009
00130d03310200190d0200340d0300120d0600050036190325036802001a00050037240200050007001c0b0500380009003d00052f02130200231703003a0009003c0005001544020c05003b0009003b0005001600070017000500220007001b0005003c0009003a00050018000700150c033002003e000900390005001a0007
001300060024000700180c020005000900380005001c0007000500210007001200060f050012000900370005002e0d0400170005003e00050014000900360005001d00070005000b001203020502000500120007001508050f030a0200060013180200120e0512060f020014100b300300070013200d3d02200c30085906250b
62036d6ddadadaba0007cf03da670006e2020006ff026b6bd6d6d666df0200120402d86800166969d26800070006dd020006d668df0200126f02da2a0014d83a0005000600149909d6200016d206310265310001e8026627001500070018cb040018c51d00010016fc04e1060001e802c127e502001abf03d402001bb616a402
000600124d03d30600016503fb03b4240022b003001700050019ab149c0200060014fb03f7050001b8045327001cde04ac03001b000500155715001cfc04a303a5260014f8020403f402fc020024f8110001001d4b2b8d020019000500160007ff020017f40200050018e607e002001eea056602dd22890240020015c3030005
3302e20237023b0de503c61978043802ea020026000700180005b003720c8f02fa17ed023406002b0007001bb003a6040015320a8503de0f0007001ac102e904f702002d000700230001e902d102e5023102de036306001dc707001e2603ee02fb020032000700200001ea0200170001d202001625020013fa02c803f9040023
d8032104cd030037e302d6042003f60228025003c90200240005001967052004f102003bd502f7030402f602001868024203002ab303df028502d002f603003e3a051f062304003319059e03003ce90200187103da04ff0269033d03ea0200301e079a02003d3f0394020001001aa5021d03ea039a03c502002fd7033d04f802
1f02e606e1020006b5020019ff0282032004000b0015de020302003e0703f70200160006d20200171103fd022804920400070022d20524035f031d032104e60334022205e3049303001ef2022304d9040039dd03a0025f024905ce020b03b80329056702002293026b04ab040013af030038a803001b00068f02b00200194e05
36022605af04002095047804f604f903560200010027e7039d0263042708001a0005ea0375055206fc03f702002a6803c40200277b08e9027a059202001c96037a05a805d803eb02000500260007cb02c102f7032f02820ff3020016000b001b8206c402e0022c02ca02002300070018ee03b2020024d203e20300158b0dc102
f4021f03f103ee030016eb020006d202001f0006001364023205fb02e402001f6603f8028903940acf0294020018320600155c020006a102001a0006001a8d03310500140001b0023903f3060a03f207fc029702002008066403002100050017360300120006e1026303f40200193603c4020019f60bff02b302fa02db02aa04
f102e003bf020006002658020006001d3503970339035e02ad03a1039905f0020001bd02d0062202690270059a020013f6036402002868039e020c046f023a030017d703df03db03fa02a703d1025f02dc039c033305ab030006002a99039203d007da02a305f70208042e06a603ce03f602fc0200168f049b030024cc030018
22053b039f03b30332056902001afc03c702fc02d302c70200180006000500060503fd028604001b5c0700068b03cf030018cb03001bbb030402a10200195403001deb05c402001d270cbc042704001c000bd1024d02b9020022d902dd03c102001ed80350032f03e103b004ce02001fcf020007001788030026f102a405001f
2309860200152b052402001cc002be03002cc202c60334039108bd029c02ab02a202001f000500180007001466030030890300070021a0039002001989039c026b02001a6f021f03560200135a030032830200070028660283037802001c8003000134024a0300152203001d4b0300341e03002a000600151e07300200140402
00073e040018480300353a03002b12033a020007001e000100180007002033032102000700373203002d2e0232020007002700010007002600060017000700382703002f0f0300280404000600130007003e0007002b0e03002a000109030b020034070707070001000700270008001b0007003e02020007002908081007002a
0008001a1805002b000800192005002c000800182805002d0008001708081007000700080015000500210008003e280200010023000800230007001b10020012000800141102000700161902001803031f0209060017090321030b073502001a380200130008001328032d020e030008001605050a040f0a00150f0600010012
00090004001300010004000100130004000200040009000100020f02200c0d0300194a2e4d0251024d024b034f024b0e9604b2034c2f4e034c140012e303f303e3280023f40d0013fe030016d62b84040001d80300098e02de0300144c0fe5030015d72a0013d302d004de03e1034c11fb0300076003d70b00180303d3070b03
f303cf0400140004440a0013a0021b09d90300128d0e0023e0050022c80500230804fc03ff02630c0005230500052306e803ed05ec03f6030009f6020012d502530356033616d602f602001a3a07d402dd023f033903dd023906d0056e15da0200150005001938090009c4027802380bf802d3023717900203033a0600239b03
800229230014d302d503d8020015a203d0040016d004cd07001b00070017fe0300255d11c302c702ce0235033d06cd03001700070016c806f0020018330c001c300d00156904fc04de02f7072f15bc04221e0013b50200130009b802b202090300145017e506cc02ec020018b5060002e2033503ef040704df0288040012ea02
ec0204033b213a04f6037602c3093b0c00170006002f0007001f00066d020006020205040014080700060029630c00032804003e260496032d03260208060006002a0008a302260c0028000600305203bb025602002a520200080017a506df034105e8020006001d0008002b000600280008001d000600134a06001500080016
7202210500063c03d102001c030300080006f30200229102de0226021d026d022a0300080015250a46030020f903f30205052c0249020024680210045c02540553020004f803540c2c0cbc020020c0034005e9027b02870200040e038c025e0ff702fb02fa030502da02340c1502c002fe0337030004c90200090008fe02661a
dc04d80200120009e404e8047207f502001871021502fb03a11af00200153905ae05ea057504ba030019390c002100070021da10001870047602e0083403cd02d402001c322ade027603ef03001b652ad303ae02da03952cfd04331c00205d0bc2032c26b804f30400128e0ce503001dfd0213020019f50405021c02600c1502
f0026004f2028e26df02b9028f0967029d020032d202001c0303b504c802001e4e03d202001ba903b5020015b306c502c102b304002b0006001400070022ae020008001ba40235029d03a1040006003e02020006001d100451050f05001f1f0459026a04001d000a003e000a003c0006001630047a0300121005320210025a04
0d06000a15021f034c020e0759022d024a030006001c1c0500163b0300121c03001b2a0500180006001700072802001a360530020c021a020017000600192805001c000600271605001e0006001e0007003e02020404080808070016000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0125000024500185001f5001d5000d4000a40011400114001d4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010000029230292302c2302c230292302923024230242302923029230292302923029230292302923029230292302423024230242302423029230292302c2302c230292302923024230242302e2302e2302e230
0010000020530205302053020530205302053020530205302253022530225302253022530225302253022530225301d5301d5301d5301d53018530185301853018530185301853018530185301d5301d5301d530
001000001b5301b5301b5301b5301b5301b5301b5301b5301b5301b5301b5301b5301b5301b5301b5301b5301b5302153021530215302153021530215301b5301b5300f5300f5300f5300f5300d5300d5300d530
001000002e2302e2302e2302d2302d2302d2302d2302923029230292302923030230302302e2302e2302e23027230272302723030230302302e2302e2302e2302623026230262302423026230272302b23029230
001000001d5301d5301d5301d5301d5301d5301d5301853016530185301853024530245302253022530225301b5301b5301b53018530185302253022530225301a5301a5301d5301b5301d5301e5302253020530
001000000d5300d5300d530185301853018530185301f5301f5301f5300c5301d5001d5001653016500000000f53000000000000c530000001653000000165300e5300e5300c5000c50016500000000000000000
00100000000000000000000000000000000000000000000000000000000c53000000000001653000000000000f53000000000000c530000001653000000165301a5300e5300c5002450016500000000000000000
001000002723029230292302923030230302302e2302e2302e23027230272302723030230302302e2302e2302e2302623026230262302423026230272302b2302923027230292302423024230242302423024230
001000001e53018530165301853000000185302253000000000001b530000000000018530000002253000000000001a530000001d5301b5301d5301e53022530205301e530205301f5301f5301f5301f5301f530
00100000000301f5301f5301f530000300c5301653000030000300f530000300003018530000301653000030000300e5300003000030000300003000030000300003000030000302253022530225302253022530
0010000000000000001d50000000000000c5301653000000000000f530000000000018530000001653000000000000e5300000000000000000000000000000000000000000000000000000000000000000000000
001000002923029230292302923029230292302b2302b2302b2302b2302b2302c2302c2302c2302c2302c2302e2302e2302e2302e2302e2302e23027230272302723027230272302723027230272302723027230
001000000f470000000f470000000f470000000f470000000f470184000f470000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00100000215302153021530225302253022530225302253021530215302153022530225302253022530225301953019530195301953019530195302253022530225302253022530225301f5301f5301f5301f530
001000001853018530185301853018530185301a5301a5301a5301a5301a5301b5301b5301b5301b5301b5301e5301e5301e5301e5301e5301e53020530205302053018530185301853018530185301853018530
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
01 01 02 03 44
00 04 05 06 07
00 08 09 0a 0b
02 0c 0e 0f 44
02 41 42 43 44
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
