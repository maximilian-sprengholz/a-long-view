////////////////////////////////////////////////////////////////////////////////
//
//		Immigration and Labor Market Integration in Germany: A Long View
//
//		1 -- Prepare KldB -> ISCO Translation
//
//		Maximilian Sprengholz
//		maximilian.sprengholz@hu-berlin.de
//
////////////////////////////////////////////////////////////////////////////////

/*
 Based on official conversion tables:
 https://statistik.arbeitsagentur.de/Navigation/Statistik/Grundlagen/Klassifikationen/Klassifikation-der-Berufe/Klassifikation-der-Berufe-Nav.html

 Harmonized and adjusted.
*/


//---------------------------//
//	 KldB1988 -> KldB1992	 //
//---------------------------//

// import excel
import excel using "${dir_data}temp/kldb88_kldb92.xlsx", ///
	firstrow cellrange(A1:B421) clear
// destring
destring _all, replace
// save
save "${dir_data}temp/kldb88_kldb92.dta", replace


//---------------------------//
// 	  KldB2010 -> KldB1992   //
//---------------------------//

// import excel
import excel using "${dir_data}temp/kldb10_kldb92.xlsx", ///
	firstrow cellrange(A1:B4016) clear
// trim KldB2010 to 4 digits; KldB1992 to 3 digits (standard: KldB92 3-digit)
/*
 Caution: MZ omits the 4th not the 5th digit for general categories,
 in KldB2010 --> extra routine necessary before trimming
*/
replace kldb2010 = ustrleft(kldb2010, 3) + ustrright(kldb2010, 1) ///
	if kldb2010!="01203" & kldb2010!="01302" // quirk for soldiers/officers in MZ
replace kldb2010 = usubstr(kldb2010, 1, 4)
replace kldb1992 = usubstr(kldb1992, 1, 3)
// destring
replace kldb1992="" if kldb1992=="-"
destring _all, replace
drop if missing(kldb1992)
drop if kldb2010<0

//
// (0) Most basic assignment (v0): Direct correspondence, deletion of other poss. codes
//

preserve
	bys kldb2010: gen n = _n
	keep if n==1
	drop n
	gen pkldb92=1 // (no subgroups = p = 1, usable with the same routine as tables below)
// save (allow for the same loop with suffix)
	save "${dir_data}temp/kldb10_kldb92_v0_1.dta", replace // direct correspondence to fill missing values later
// save base dataset containing all kldb2010 codes
	drop kldb1992 p
	save "${dir_data}temp/kldb10.dta", replace // base dataset containing all kldb2010 codes
restore

//
// (1) Assignment based on no of possible corresponding options of kldb92 target codes	(v1)
//

bys kldb2010 kldb1992: gen n=_n
keep if n==1
egen N = total(n), by(kldb2010)
gen pkldb92 = n/N
lab var pkldb92 "LIST Prob. of assoc. KldB92 codes for given KldB2010"
// table kldb2010, c(m N m pkldb92)
drop n N
// save (allow for the same loop with suffix)
save "${dir_data}temp/kldb10_kldb92_v1_1.dta", replace

//
// (2) Advanced assignment (v2): Gen rel. conversion probabilities based on double-coding of occupations in MZ2012
//

use "${dir_mz}mz2012.dta", clear
// gen groups
rename EF114 kldb2010
rename EF119 kldb1992
rename EF46 sex
rename EF366 gerborn
rename EF367 yimmi
rename EF368 ger
rename EF44 age
rename EF31 res
// east/west
recode EF1 (1/3 5/7 9/12 15 = 0) (4 8 13 14 16 = 1) (.=.), gen(east)
// german citizenship
replace ger = . if ger<1
replace ger = 1 if ger<3
replace ger = 0 if ger>2 & !missing(ger)
// keep
drop if missing(kldb1992)
drop if kldb2010<0
// keep
keep kldb2010 kldb1992 ger sex east
// relative probabilities by (1) east (2) sex, (3) ger citizenship,
local c=0
forvalues e=0/1 {
	forvalues i=1/2 {
		forvalues j=0/1 {
			local ++c
			preserve
			// keep
			keep if east==`e' & sex==`i' & ger==`j'
			// n, N, groups
			bys kldb2010: gen N=_N
			bys kldb2010 kldb1992: gen n=_N
			bys kldb2010 kldb1992: gen c=_n
			keep if c==1
			// relative probabilities
			gen pkldb92 = n/N
			lab var pkldb92 "DATA BASED Prob. of assoc. KldB92 codes for given KldB2010"
			// table kldb2010, c(m n m N m p1kldb92)
			drop n N c east sex ger
			// save
			save "${dir_data}temp/kldb10_kldb92_v2_`c'.dta", replace
			restore
		}
	}
}
local c=0
forvalues e=0/1 {
	forvalues i=1/2 {
		forvalues j=0/1 {
			local ++c
			// merge & update possible unmatched values (missings)
			use "${dir_data}temp/kldb10.dta", clear
			merge 1:m kldb2010 using "${dir_data}/temp/kldb10_kldb92_v2_`c'.dta", nogen
			count if missing(kldb1992)
			* only 9 kldb2010 categories have no match:
			* 120, 130, 1134, 2224, 2834, 6253, 9114, 9123, 9364
			* basic assignment OK
			merge m:1 kldb2010 using "${dir_data}temp/kldb10_kldb92_v0_1.dta", update
			replace pkldb92=1 if _merge==4 // updated missings have direct correspondence
			drop _merge
			// save
			save "${dir_data}temp/kldb10_kldb92_v2_`c'.dta", replace
		}
	}
}


//---------------------------//
//    KldB1992 -> ISCO-88    //
//---------------------------//

/*
 Underlying spredsheet based the following PDFs:
 https://www.gesis.org/missy/files/documents/MZ/kldb92_isco88com.pdf
 https://www.gesis.org/missy/files/documents/MZ/isco88com.pdf
*/

// import excel
import excel using "${dir_data}temp/kldb92_isco88_p.xlsx", ///
	firstrow cellrange(A1:G578) clear
// destring
destring _all, replace
// drop
drop if kldb1992==.

// list based rel. probabilities (see above v1)
bys kldb1992 valc1: gen N=_N
// if N==1 --> unambiguous, if N>1 --> more than 1 poss. ISCO code assignable
gen pisco88 = weight if N==1
egen W = total(weight), by(kldb1992 valc1)
replace pisco88 = weight/W if N>1
lab var pisco88 "LIST Prob. of assoc. ISCO88com codes for given KldB1992"
table kldb1992, c(m N m pisco88)
drop weight mz_code N W
// save
save "${dir_data}temp/kldb92_isco88com_v1.dta", replace

// max distance test ISEI per KldB1992 code
gen isei88 = isco88com

////////////////////////////////////////////////////////////////////////

/*
 *	Mikrozensus isco88 to isei88 translation
 *
 *	Written by Irena Kogan / Bernhard Schimpl-Neimanns:
 *	https://www.gesis.org/missy/files/documents/MZ/isei/isei_mz_96-04.do
*/

#delimit;
recode isei88
 (100=55) (110=70) (111=77) (112=77) (113=66) (114=58) (120=68)
 (121=70) (122=67) (123=61) (124=58) (125=64) (130=51) (131=51)
 (200=70) (210=69) (211=74) (212=71) (213=71) (214=73) (220=80)
 (221=78) (222=85) (223=43) (230=69) (231=77) (232=69) (233=66)
 (234=66) (235=66) (240=68) (241=69) (242=85) (243=65) (244=65)
 (245=61) (246=53) (247=68) (300=54) (310=50) (311=49) (312=52)
 (313=52) (314=57) (315=50) (320=48) (321=50) (322=55) (323=38)
 (324=49) (330=38) (331=38) (332=38) (333=38) (334=38) (340=55)
 (341=55) (342=55) (343=54) (344=56) (345=56) (346=43) (347=52)
 (348=38) (400=45) (410=45) (411=51) (412=51) (413=36) (414=39)
 (419=39) (420=49) (421=48) (422=52) (500=40) (510=38) (511=34)
 (512=32) (513=25) (514=30) (515=43) (516=47) (520=43) (521=43)
 (522=43) (523=37) (600=23) (610=23) (611=23) (612=23) (613=23)
 (614=22) (615=28) (620=16) (621=16) (700=34) (710=31) (711=30)
 (712=30) (713=34) (714=29) (720=34) (721=31) (722=35) (723=34)
 (724=40) (730=34) (731=38) (732=28) (733=29) (734=40) (740=33)
 (741=30) (742=33) (743=36) (744=31) (750=42) (751=42) (752=38)
 (753=26) (800=31) (810=30) (811=35) (812=30) (813=22) (814=27)
 (815=35) (816=32) (817=26) (820=32) (821=36) (822=30) (823=30)
 (824=29) (825=38) (826=30) (827=29) (828=31) (829=26) (830=32)
 (831=36) (832=34) (833=26) (834=32) (840=24) (900=20) (910=25)
 (911=29) (912=28) (913=16) (914=23) (915=27) (916=23) (920=16)
 (921=16) (930=23) (931=21) (932=20) (933=29) (else=.);
 #delimit cr

////////////////////////////////////////////////////////////////////////

lab var isei88 "ISEI-88"
egen min_isei=min(isei88), by(kldb1992)
egen max_isei=max(isei88), by(kldb1992)
gen d_isei=max_isei-min_isei
bys kldb1992: gen n=_n
keep if n==1
sum d_isei, d
tab d_isei
hist d_isei, scheme(s1mono) xtitle("Max. ISEI-88 difference within one KldB1992 code", ///
	margin(medium)) bin(50) note("Difference in ISEI-88 stems from multiple corresponding ISCO-88 codes to one KldB1992 code.")
