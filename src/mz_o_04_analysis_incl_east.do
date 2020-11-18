////////////////////////////////////////////////////////////////////////////////
//
//		Immigration and Labor Market Integration in Germany: A Long View
//
//		3 -- Analysis
//
//		Maximilian Sprengholz
//		maximilian.sprengholz@hu-berlin.de
//
////////////////////////////////////////////////////////////////////////////////


//---------------------------//
//	 SETTINGS/PARAMETERS	 //
//---------------------------//

// load dataset
use "${dir_mzproc}mz_o_gen_1976_2015.dta", clear

//
// Export options and styling
//

local outfmt HTML // switch

if "`outfmt'"=="HTML" {
	global gsfx ".svg"
	global tsfx ".html"
	global tabout_gen ///
		show(none) font(bold)
	global tabout_ttlpre ///
		style(htm) psymbol(@) noplines nohlines noborder ntc ///
		topf(${dir_src}tabout_topf_detail.txt) topstr(
	global tabout_ttlpost ///
		|scientific medleftstub) botf(${dir_src}tabout_botf_detail.txt)
}
else if "`outfmt'"=="MD" {
	global gsfx ".svg"
	global tsfx ".md"
	global tabout_gen ///
		show(none) font(bold)
	global tabout_ttlpre ///
		style(htm) psymbol(@) noplines nohlines noborder ntc ///
		topf(${dir_src}tabout_topf_detail_md.txt) topstr(
	global tabout_ttlpost ///
		|scientific medleftstub) botf(${dir_src}tabout_botf_detail_md.txt)
}
else if "`outfmt'"=="WORD" {
	global gsfx ".emf"
	global tsfx ".docx"
 	global tabout_gen ///
 		show(none) font(bold)
 	global tabout_ttlpre ///
		style(docx) font(bold) fsize(8) tw(16cm) title(
 	global tabout_ttlpost ///
 		)
}

// grstyle
grstyle clear
grstyle init
grstyle set plain, grid noextend horizontal  // imesh = R
grstyle set color cblind, select(3 4 5 8 9)
grstyle set color cblind, select(2): p6 p7 // natives
grstyle set lpattern shortdash: p6 p7 p8 p9 p10 p11 p12 // natives
grstyle set legend 6, nobox klength(medsmall)
grstyle set graphsize 9cm 9cm
grstyle set size 9pt: heading
grstyle set size 6pt: subheading axis_title key_label
grstyle set size 5pt: tick_label body small_body
grstyle set size 0pt: legend_key_gap
grstyle set size 22pt: legend_key_xsize
grstyle set size -1pt: legend_row_gap
grstyle set symbolsize 5, pt
grstyle set linewidth 1pt: p1 p2 p3 p4 p5 p6 p7 p8 p9 p10 p11 p12
grstyle set linewidth .4pt: pmark legend axisline tick major_grid
grstyle set margin "0 0 2 0": subheading
grstyle set margin "0 3 3 0": axis_title
grstyle set margin "3 8 3 3": graph

//
// Analysis sample
//
/*
 - Age: 25-54 (upper and lower age limit restricted below, starting with 18+, then 25+, then 25-54)
 - Residence population
 - Age at immigration: 18+
 - Sample region: West Germany
*/
gen asample = 0
replace asample = 1 ///
	if (age>=18) ///
	& res==1 ///
	& priv==1 ///
	& ( ((yimmi>=(year-age+18)) & !missing(yimmi)) | (missing(yimmi) & ger==1)) ///
	// & east==0
keep if asample==1

// some checks
count if missing(ageykidc)
count if missing(nkids)
count if missing(marstat)
count if missing(isced) // some missings due to measurement inconsistency
tab year isced [aw=hhpw] if asample==1 & age<=54, mi row // 8% missing in 1991/1993, otherwise negligible

tab empl_dummy isced, mis
sum isei88 if mi(isced), d
sum isei88 if !mi(isced), d
/*
 Missing information on the ISCED variable seems somewhat related to lower
 employment outcomes, however, not very clear. I suggest to look only at cases
 where we have the information.
*/

// Check employment selection on ISEI
table emplst, c(m isei88 p25 isei88 p75 isei88)
clonevar isei88_res = isei88
replace isei88_res = . if empl_dummy==0 // restricted to those employed
label var isei88_res "ISEI-88, employed only"

// final sample
keep if !missing(isced)

//
// Weights
//

// replace weights to reflect population
gen hhpw_pop = hhpw * (100/0.7) // 70% subsample, per 100 persons
//table year i [pw=hhpw_pop] if asample==1, format(%16.0gc)

//
// Categorize
//

// marital status
recode marstat (1 3 4 7 = 0 "Not married") (2 5 = 1 "Married"), gen(married)
lab var married "Married"

// number of children
recode nkids (0=0 "No children") (1=1 "1 child") (2=2 "2 children") ///
	(3/99=3 "3+ children"), gen(nkidsc)
label var nkidsc "No. of children, cat."

// time of residence
gen timeresc = 0 if ger==1
replace timeresc = 1 if timeres <= 5 & ger!=1
replace timeresc = 2 if timeres > 5 & timeres <= 10 & ger!=1
replace timeresc = 3 if timeres > 10 & timeres <= 15 & ger!=1
replace timeresc = 4 if timeres > 15 & timeres <= 20 & ger!=1
replace timeresc = 5 if timeres > 20 & !missing(timeres) & ger!=1
lab def timeresc 0 "German" 1 "1-5" 2 "6-10" 3 "11-15" 4 "16-20" 5 "21-25", modify
lab val timeresc timeresc
lab var timeresc "Duration of stay"
label var timeres "Duration of stay"

// age at arrival
gen arrage = age-(year-yimmi)
lab var arrage "Age at arrival"
recode arrage (18/27=1 "18-27") (28/37=2 "28-37") (38/47=3 "38-47") ///
	(48/54=4 "48-54"), gen(arragec)
label var arragec "Age at arrival"
replace arrage = . if ger==1
replace arragec = . if ger==1

// age
recode age (25/34=1 "25-34") (35/44=2 "35-44") (45/54=3 "45-54"), gen(agec)
label var agec "Age, cat."

// center age
sum age [aw=hhpw] if sex==1, meanonly
gen z_age = age - r(mean) if sex==1
sum age [aw=hhpw] if sex==2, meanonly
replace z_age = age - r(mean) if sex==2
label var z_age "Age"

// arrival cohort
recode yimmi ///
	(1964/1973=1 "1964-73") (1974/1983=2 "1974-83") (1984/1993=3 "1984-93") ///
	(1994/2003=4 "1994-03") (2004/2010=5 "2004-10") (else=.), gen(arrcoh)
lab var arrcoh "Arrival cohort"
lab def arrcoh 0 "German", modify
replace arrcoh=0 if ger==1

// immigrant dummy
gen for = 1 if ger==0
replace for=0 if ger==1
lab var for "Foreigner (dummy)"
lab def for 0 "German" 1 "Foreigner"
lab val for for

//----------------------------------//
//    TEST INCLUDING EAST GERMANY   //
//----------------------------------//

// analysis sample: restrict to maximum age 54
keep if (age>=25 & age<=54)

tab east arrcoh if asample==1 // not enough for the plots

//
// Plot outcome means for cohorts by time of residence
//

/*
 Observation interval for each arrival cohort: durationof stay <=30y.
*/

local nmin 100 // set minium observations per cell

local lbl1 Men
local lbl2 Women
local fname1 m
local fname2 f

local ylbl_empl_dummy 	0(10)100
local ylbl_ahours 		20(5)45
local ylbl_isei88 		25(5)52
local ylbl_isei88_res 	25(5)52
local ylbl_isced 		1(0.5)2.5

local sttl_empl_dummy 	Percent
local sttl_ahours 		Means
local sttl_isei88 		Means
local sttl_isei88_res 	Means
local sttl_isced 		Means


foreach var in empl_dummy ahours isei88_res {

	local ttl : variable label `var'

	preserve
		// collapse
		collapse (mean) `var' (count) n`var' = `var' ///
			if asample==1 & timeres>0 & !missing(timeres) ///
			[pw=hhpw], by(arrcoh timeres sex)	
		// apply restrictions
		replace `var' = . ///
			if arrcoh==1 & timeres<12 ///
			 | arrcoh==2 & timeres<2 ///
			 | arrcoh==3 & timeres>22 ///
			 | arrcoh==4 & timeres>12 ///
			 | arrcoh==5 & timeres>5 // sensible combinations
		replace `var' = . if timeres>30 // 30 years max.
		replace timeres = . if timeres>30 // graph bug
		replace `var' = . if n`var'<`nmin' // cell counts too low
		if "`var'"=="empl_dummy" {
			replace empl_dummy = empl_dummy*100
		}		
		// plots and tables
		forvalues s=1/2 {
			// plot
			twoway ///
				(line `var' timeres if arrcoh==1 & sex==`s', ///
				ytitle("`ttl'") ylabel(`ylbl_`var'') ///
				title("`ttl', `lbl`s''") subtitle("`sttl_`var'', including East Germany") ///
				xlabel(0(5)31) ///
				legend(order(- "Arr. cohort: " 1 "1964-73" 2 "1974-83" 3 "1984-93" ///
				4 "1994-03" 5 "2004-10") cols(6) stack span)) ///
				(line `var' timeres if arrcoh==2 & sex==`s') ///
				(line `var' timeres if arrcoh==3 & sex==`s') ///
				(line `var' timeres if arrcoh==4 & sex==`s') ///
				(line `var' timeres if arrcoh==5 & sex==`s')
			graph export "${dir_g}`var'_timeres_`fname`s''_east${gsfx}", replace
			// table
			local tblname "`var'_timeres_`fname`s''"
			local tblttl "Means by arrival cohort and duration of stay: `ttl', `lbl`s''"
			tabout timeres arrcoh if sex==`s' ///
				using "${dir_t}`tblname'${tsfx}", replace ///
				sum c(mean `var') f(2) clab(Mean) ${tabout_gen} ///
				${tabout_ttlpre}`tblttl'|`tblname'${tabout_ttlpost}
		}
	restore

}


//
// Plot outcome means for cohorts by period
//

/*
 Observation interval for each arrival cohort:
 Begin: arrival period end year + 1
 End: arrival period end year year + 30
 = 30 year maximum
*/

local nmin 100 // set minium observations per cell

local lbl1 Men
local lbl2 Women
local fname1 m
local fname2 f

local ylbl_empl_dummy 	0(10)100
local ylbl_ahours 		20(5)45
local ylbl_isei88 		25(5)52
local ylbl_isei88_res 	25(5)52
local ylbl_isced 		1(0.5)2.5

foreach var in empl_dummy ahours isei88_res {

	local ttl : variable label `var'
	preserve
		lab def arrcoh 0 "Germans", modify
		// collapse
		collapse (mean) `var' (count) n`var' = `var' ///
			[pw=hhpw], by(arrcoh year sex east)
		gen `var'_product_temp	= `var' * n`var'
		egen `var'_mean_temp = total(`var'_product_temp), by(arrcoh year sex)
		egen n`var'_total_temp = total(n`var'), by(arrcoh year sex)
		gen `var'_temp = `var'_mean_temp / n`var'_total_temp
		replace `var' = `var'_temp if arrcoh!=0
		drop *_temp
		// apply restrictions
		replace `var' = . ///
			if arrcoh==1 & (year<=1973 | year>2003) ///
			 | arrcoh==2 & (year<=1983 | year>2013) ///
			 | arrcoh==3 & year<=1993 ///
			 | arrcoh==4 & year<=2003 ///
			 | arrcoh==5 & year<=2010 // sensible cominations + max. interval
		replace `var' = . if n`var'<`nmin' // cell counts too low
		if "`var'"=="empl_dummy" {
			replace empl_dummy = empl_dummy*100
		}		
		// plots and tables
		forvalues s=1/2 {
			// plot
			twoway ///
				(line `var' year if arrcoh==1 & sex==`s', ///
				ytitle("`ttl'") ylabel(`ylbl_`var'') ///
				title("`ttl', `lbl`s''") subtitle("`sttl_`var'', including East Germany") ///
				xlabel(1976(5)2016) ///
				legend(order(- "Arr. cohort: " 1 "1964-73" 2 "1974-83" 3 "1984-93" ///
				4 "1994-03" 5 "2004-10" 6 "West G." 7 "East G.") cols(8) stack span)) ///
				(line `var' year if arrcoh==2 & sex==`s') ///
				(line `var' year if arrcoh==3 & sex==`s') ///
				(line `var' year if arrcoh==4 & sex==`s') ///
				(line `var' year if arrcoh==5 & sex==`s') /*
				german natives as grey reference
			*/	(line `var' year if arrcoh==0 & sex==`s' & east==0, lcolor(gs10) lpattern(dash)) ///
				(line `var' year if arrcoh==0 & sex==`s' & east==1, lcolor(gs10) lpattern(shortdash_dot))
			graph export "${dir_g}`var'_period_`fname`s''_east${gsfx}", replace
			// table
			local tblname "`var'_period_`fname`s''"
			local tblttl "Means by arrival cohort and period: `ttl', `lbl`s''"
			tabout year arrcoh if sex==`s' ///
				using "${dir_t}`tblname'${tsfx}", replace ///
				sum c(mean `var') f(2) clab(Mean) ${tabout_gen} ///
				${tabout_ttlpre}`tblttl'|`tblname'${tabout_ttlpost}
		}
	restore
}

// clear
clear
