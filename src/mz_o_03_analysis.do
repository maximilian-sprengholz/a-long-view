////////////////////////////////////////////////////////////////////////////////
//
//		From "guestworkers" to EU migrants: A gendered view on the labor market
//      integration of different arrival cohorts in Germany
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

local outfmt MD // switch

if "`outfmt'"=="HTML" {
	global gsfx ".svg"
	global gsavemode "export"
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
	global gsavemode "export"
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
	global gsavemode "export"
	global tsfx ".docx"
 	global tabout_gen ///
 		show(none) font(bold)
 	global tabout_ttlpre ///
		style(docx) font(bold) fsize(8) tw(16cm) title(
 	global tabout_ttlpost ///
 		)
}
else if "`outfmt'"=="JFR" {
	global gsfx ".gph"
	global gsavemode "save"
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
grstyle set color cblind, select(2): p6 // natives
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
// CHECK: graph nonresponse magnitude immigration year
//

preserve
	gen miyimmi = mi(yimmi)
	collapse miyimmi [aw=hhpw] if ger==0 ///
		& ((gerborn!=1 & year>=2005) | (forgerborn!=1 & year<2005)) ///
		& inrange(age,25,54) ///
		& res==1 ///
		& priv==1 ///
		& east==0 ///
		& !mi(isced) ///
		, by(year sex)
	replace year = cond(sex==2, year - 0.2, year + 0.2)
	colorpalette cblind, locals
	grstyle set size 5pt: legend_key_xsize legend_key_ysize
	grstyle set size 2pt: legend_key_gap
	grstyle set graphsize 9cm 18cm
	twoway ///
		(bar miyimmi year if sex==2, ///
			color(`Orange') lcolor(`Orange') barwidth(0.4) fintensity(80)) ///
		(bar miyimmi year if sex==1, color(`Orange') lcolor(`Orange') ///
			barwidth(0.4) fintensity(30) xlabel(1976 1980(5)2015) ///
			ytitle(Share with missing information (in %)) ///
			legend(order(1 "Women" 2 "Men")) /* ///
			note("Corresponds to analysis sample except for arrival year restrictions. Shares for persons with non-German citizenship who did not state to have been born in Germany.")*/)
	// export and add HTML wrapper
	graph ${gsavemode} "${dir_g}sum_yimmi_nonres${gsfx}", replace
	grstyle set size 22pt: legend_key_xsize
	grstyle set size 0pt: legend_key_gap
	grstyle set graphsize 9cm 9cm
restore

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
	& east==0
keep if asample==1

// some checks
count if missing(ageykidc)
count if missing(nkids)
count if missing(marstat)
count if missing(isced) // some missings due to measurement inconsistency
tab year isced [aw=hhpw] if asample==1 & age<=54, mi row // 8% missing in 1991/1993, otherwise negligible
tab ger isced [aw=hhpw] if asample==1 & age<=54, mi row // 2% missing with or without german citizenship
foreach y in 1976 1982 1987 1993 1998 2003 {
	tab ger isced [aw=hhpw] if asample==1 & age<=54 & year==`y', mi row // also largely comparable over years
}

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
label var isei88_res "ISEI-88 (employed only)"

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

// Employment as percent (not used in any other way here)
replace empl_dummy = empl_dummy*100
lab var empl_dummy "Employment rate (in %)"

//----------------------------------//
//    SELECTION TESTS: AGE 18-54    //
//----------------------------------//

/*
 Problem: Persons who immigrated with age 18-23 show up in our analysis sample
 with a timelag. Thus, early developments in indicators might be due to changes
 in the cohort composition that are not a result of remigration or
 naturalization (as we presume in the text).

 The following estimates are therefore based on a sample of persons aged 18-54.
*/

//
// Cohort size development over time (population projection): Duration of stay
//

local lbl1 Men
local lbl2 Women
local fname1 m
local fname2 f

// Table
qui forvalues s=1/2 {
	// Table
	local tblname 	"sum_cohortsize_timeres_`fname`s''_18_54"
	local tblttl 	"Cohort size development by duration of stay, `lbl`s'' (age 18-54)"
	tabout timeres arrcoh [iw=hhpw_pop] if sex==`s' & inrange(timeres,1,30) & arrcoh!=0 & age<=54 ///
		using "${dir_t}`tblname'${tsfx}", replace ///
		c(freq) f(0c) clab(n) npos(lab) ///
		fn(Projected to population counts.) ${tabout_gen} ///
		${tabout_ttlpre}`tblttl'|`tblname'${tabout_ttlpost}
}

// Plot
preserve
	gen i = 1
	local var i
	// collapse
	collapse (count) n`var' = `var' if age<=54 ///
		[pw=hhpw_pop], by(arrcoh timeres sex)
	// apply restrictions
	replace n`var' = . ///
		if arrcoh==1 & timeres<12 ///
		 | arrcoh==2 & timeres<2 ///
		 | arrcoh==3 & timeres>22 ///
		 | arrcoh==4 & timeres>12 ///
		 | arrcoh==5 & timeres>5 // sensible combinations
	replace timeres = . if !inrange(timeres,1,30) // graph bug
	replace n`var' = n`var' / 1000 // show in 1,000
	// plots and tables
	forvalues s=1/2 {
		// plot
		twoway ///
			(line n`var' timeres if arrcoh==1 & sex==`s', ///
			title("`lbl`s''") ytitle("Population counts (in 1,000)") ///
			xlabel(0(5)31) ylabel(0(200)800) ///
			legend(order(- "Arr. cohort: " 1 "1964-73" 2 "1974-83" 3 "1984-93" ///
			4 "1994-03" 5 "2004-10") cols(6) stack span)) ///
			(line n`var' timeres if arrcoh==2 & sex==`s') ///
			(line n`var' timeres if arrcoh==3 & sex==`s') ///
			(line n`var' timeres if arrcoh==4 & sex==`s') ///
			(line n`var' timeres if arrcoh==5 & sex==`s')
		// export and add HTML wrapper
		graph ${gsavemode} "${dir_g}sum_cohortsize_timeres_`fname`s''_18_54${gsfx}", replace
	}
restore


//
// Compare educational levels by arrival age
//

preserve
	// Those excluded from age restrictions (they 'grow into' the sample over time)
	clonevar isced1 = isced ///
		if inrange(arrage,18,23) & timeres<=abs(arrage-24)
	lab var isced1 "Excluded by age restriction 25-54"
	// Those included (the plot base)
	clonevar isced2 = isced ///
		if inrange(arrage,24,54) & inrange(age,25,54) & inrange(timeres,1,6)
	lab var isced2 "Included by age restriction 25-54"
	// Table
	qui forvalues s=1/2 {
		local tblname "sum_isced_arrage_`fname`s''"
		local tblttl "Educational levels (ISCED-97) by cohort and arrival age groups, `lbl`s'' (duration of stay 1-6)"
		tabout isced1 isced2 arrcoh if arrcoh!=0 & sex==`s' [iw=hhpw_pop] ///
			using "${dir_t}`tblname'${tsfx}", replace ///
			c(col) f(1) clab(%) npos(lab) fn(Column percent.) ${tabout_gen} ///
			${tabout_ttlpre}`tblttl'|`tblname'${tabout_ttlpost}
	}
restore

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

foreach var in empl_dummy ahours isei88_res {

	local ttl : variable label `var'

	preserve
		// collapse
		collapse (mean) `var' (count) n`var' = `var' ///
			if asample==1 & age<=54 & timeres>0 & !missing(timeres) ///
			[aw=hhpw], by(arrcoh timeres sex)
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
		// plots and tables
		forvalues s=1/2 {
			// plot
			twoway ///
				(line `var' timeres if arrcoh==1 & sex==`s', ///
				title("`lbl`s''") ytitle("`ttl'") ylabel(`ylbl_`var'') ///
				xlabel(0(5)31) ///
				legend(order(- "Arr. cohort: " 1 "1964-73" 2 "1974-83" 3 "1984-93" ///
				4 "1994-03" 5 "2004-10") cols(6) stack span)) ///
				(line `var' timeres if arrcoh==2 & sex==`s') ///
				(line `var' timeres if arrcoh==3 & sex==`s') ///
				(line `var' timeres if arrcoh==4 & sex==`s') ///
				(line `var' timeres if arrcoh==5 & sex==`s')
			graph ${gsavemode} "${dir_g}`var'_timeres_`fname`s''_18_54${gsfx}", replace
			// table
			local tblname "`var'_timeres_`fname`s''_18_54"
			local tblttl "Means by arrival cohort and duration of stay: `ttl', `lbl`s'' (age 18-54)"
			tabout timeres arrcoh if sex==`s' ///
				using "${dir_t}`tblname'${tsfx}", replace ///
				sum c(mean `var') f(2) clab(Mean) ${tabout_gen} ///
				${tabout_ttlpre}`tblttl'|`tblname'${tabout_ttlpost}
		}
	restore

}

//
// Remigration/Naturalization: ISCED levels by duration of stay
//

local lbl1 Men
local lbl2 Women
local fname1 m
local fname2 f

preserve

	replace isced = . ///
		if arrcoh==1 & timeres<12 ///
		 | arrcoh==2 & timeres<2 ///
		 | arrcoh==3 & timeres>22 ///
		 | arrcoh==4 & timeres>12 ///
		 | arrcoh==5 & timeres>5 // sensible combinations

	forvalues t=1/7 {
		local hi = `t'*3
		local lo = (`t'-1)*3
		clonevar isced_timeres`t' = isced if timeres>`lo' & timeres<=`hi' & !mi(arrcoh) & age<=54
		lab var isced_timeres`t' "ISCED, dur. of stay: `lo'-`hi'y."
	}

	// Table
	qui forvalues s=1/2 {
		local tblname "sum_isced_remig_`fname`s''_18_54"
		local tblttl "Educational levels (ISCED-97) by cohort and duration of stay, `lbl`s'' (age 18-54)"
		tabout isced_timeres1 isced_timeres2 isced_timeres3 isced_timeres4 ///
			isced_timeres5 isced_timeres6 isced_timeres7 arrcoh if arrcoh!=0 & sex==`s' [iw=hhpw_pop] ///
			using "${dir_t}`tblname'${tsfx}", replace ///
			c(col) f(1) clab(%) npos(lab) fn(Column percent.) ${tabout_gen} ///
			${tabout_ttlpre}`tblttl'|`tblname'${tabout_ttlpost} ///
			h2(1964-1973 1974-1983 1984-1993 1994-2003 2004-2010 Total) h2c(1 1 1 1 1 1) ///
			plugc(1:2 2:2 3:2 5:5 6:5 7:5 8:5 3:6 4:6 5:6 6:6 7:6 8:6)
	}

restore


//----------------------------------//
//     SELECTION TESTS: AGE 25+     //
//----------------------------------//

/*
 The following numbers are estimated with lower age limit 25 and without
 the upper age limit.
*/

// analysis sample: restrict to minimum age 25
keep if age>=25

//
// Cohort size development over time (population projection): Period
//

local lbl1 Men
local lbl2 Women
local fname1 m
local fname2 f

// Table
qui forvalues s=1/2 {
	// Table
	local tblname "sum_cohortsize_period_`fname`s''_unres"
	local tblttl "Cohort size development by period, `lbl`s'' (no upper age limit)"
	tabout year arrcoh [iw=hhpw_pop] if sex==`s' ///
		using "${dir_t}`tblname'${tsfx}", replace ///
		c(freq) f(0c) clab(n) npos(lab) show(all) ///
		fn(Projected to population counts.) ${tabout_gen} ///
		${tabout_ttlpre}`tblttl'|`tblname'${tabout_ttlpost}
}

// Plot
preserve
	gen i = 1
	local var i
	// collapse
	collapse (count) n`var' = `var' ///
		[pw=hhpw_pop], by(arrcoh year sex)
	// apply restrictions`
	replace n`var' = . ///
		if arrcoh==1 & (year<=1973 | year>2003) ///
		 | arrcoh==2 & (year<=1983 | year>2013) ///
		 | arrcoh==3 & year<=1993 ///
		 | arrcoh==4 & year<=2003 ///
		 | arrcoh==5 & year<=2010 // sensible cominations + max. interval
	replace n`var' = n`var' / 1000 // show in 1,000
	// plots and tables
	forvalues s=1/2 {
		// plot
		twoway ///
			(line n`var' year if arrcoh==1 & sex==`s', ///
			title("`lbl`s''") ytitle("Population counts (in 1,000)") ///
			xlabel(1976 1980(5)2015) ylabel(0(200)800) ///
			legend(order(- "Arr. cohort: " 1 "1964-73" 2 "1974-83" 3 "1984-93" ///
			4 "1994-03" 5 "2004-10") cols(6) stack span)) ///
			(line n`var' year if arrcoh==2 & sex==`s') ///
			(line n`var' year if arrcoh==3 & sex==`s') ///
			(line n`var' year if arrcoh==4 & sex==`s') ///
			(line n`var' year if arrcoh==5 & sex==`s')
		graph ${gsavemode} "${dir_g}sum_cohortsize_period_`fname`s''_unres${gsfx}", replace
	}
restore

//
// Cohort size development over time (population projection): Duration of stay
//

local lbl1 Men
local lbl2 Women
local fname1 m
local fname2 f

// Table
qui forvalues s=1/2 {
	// Table
	local tblname "sum_cohortsize_timeres_`fname`s''_unres"
	local tblttl "Cohort size development by duration of stay, `lbl`s'' (no upper age limit)"
	tabout timeres arrcoh [iw=hhpw_pop] if sex==`s' & arrcoh!=0 & inrange(timeres,1,30) ///
		using "${dir_t}`tblname'${tsfx}", replace ///
		c(freq) f(0c) clab(n) npos(lab) ///
		fn(Projected to population counts.) ${tabout_gen} ///
		${tabout_ttlpre}`tblttl'|`tblname'${tabout_ttlpost}
}

// Plot
preserve
	gen i = 1
	local var i
	// collapse
	collapse (count) n`var' = `var' ///
		[pw=hhpw_pop], by(arrcoh timeres sex)
	// apply restrictions
	replace n`var' = . ///
		if arrcoh==1 & timeres<12 ///
		 | arrcoh==2 & timeres<2 ///
		 | arrcoh==3 & timeres>22 ///
		 | arrcoh==4 & timeres>12 ///
		 | arrcoh==5 & timeres>5 // sensible combinations
	replace timeres = . if !inrange(timeres,1,30) // graph bug
	replace n`var' = n`var' / 1000 // show in 1,000
	// plots and tables
	forvalues s=1/2 {
		// plot
		twoway ///
			(line n`var' timeres if arrcoh==1 & sex==`s', ///
			title("`lbl`s''") ytitle("Population counts (in 1,000)") ///
			xlabel(0(5)31) ylabel(0(200)800) ///
			legend(order(- "Arr. cohort: " 1 "1964-73" 2 "1974-83" 3 "1984-93" ///
			4 "1994-03" 5 "2004-10") cols(6) stack span)) ///
			(line n`var' timeres if arrcoh==2 & sex==`s') ///
			(line n`var' timeres if arrcoh==3 & sex==`s') ///
			(line n`var' timeres if arrcoh==4 & sex==`s') ///
			(line n`var' timeres if arrcoh==5 & sex==`s')
		graph ${gsavemode} "${dir_g}sum_cohortsize_timeres_`fname`s''_unres${gsfx}", replace
	}
restore

//
// Remigration/Naturalization: ISCED levels by duration of stay
//

local lbl1 Men
local lbl2 Women
local fname1 m
local fname2 f

preserve

	replace isced = . ///
		if arrcoh==1 & timeres<12 ///
		 | arrcoh==2 & timeres<2 ///
		 | arrcoh==3 & timeres>22 ///
		 | arrcoh==4 & timeres>12 ///
		 | arrcoh==5 & timeres>5 // sensible combinations

	forvalues t=1/7 {
		local hi = `t'*3
		local lo = (`t'-1)*3
		clonevar isced_timeres`t' = isced if timeres>`lo' & timeres<=`hi' & !mi(arrcoh)
		lab var isced_timeres`t' "ISCED, dur. of stay: `lo'-`hi'y."
	}

	// Table
	qui forvalues s=1/2 {
		local tblname "sum_isced_remig_`fname`s''_unres"
		local tblttl "Educational levels (ISCED-97) by cohort and duration of stay, `lbl`s'' (no upper age limit)"
		tabout isced_timeres1 isced_timeres2 isced_timeres3 isced_timeres4 ///
			isced_timeres5 isced_timeres6 isced_timeres7 arrcoh if arrcoh!=0 & sex==`s' [iw=hhpw_pop] ///
			using "${dir_t}`tblname'${tsfx}", replace ///
			c(col) f(1) clab(%) npos(lab) fn(Column percent.) ${tabout_gen} ///
			${tabout_ttlpre}`tblttl'|`tblname'${tabout_ttlpost} ///
			h2(1964-1973 1974-1983 1984-1993 1994-2003 2004-2010 Total) h2c(1 1 1 1 1 1) ///
			plugc(1:2 2:2 3:2 5:5 6:5 7:5 8:5 3:6 4:6 5:6 6:6 7:6 8:6)
	}

restore

//
// Naturalization: ISCED levels by citizenship/naturalization status
//

preserve
	// Prep
	/*
	 Use all years where naturalization data available disaggregated for
	 naturalized immigrants and ethnic Germans with German citizenship.
	*/
	keep if year>=2007
	recode cship_nat (.=.) (1=.) (3=2) (4 2 = 3) (0 -5 = 1), gen(nat_c)
	lab var nat_c "Naturalization status"
	lab def nat_c 1 "Non-naturalized immigrant" 2 "Naturalized immigrant" ///
		3 "Naturalized/recognized Ethnic German" 4 "German by birth", modify
	lab val nat_c nat_c

	// arrival cohort var (the other is missing if ger==1)
	recode yimmi ///
		(1964/1973=1 "1964-73") (1974/1983=2 "1974-83") (1984/1993=3 "1984-93") ///
		(1994/2003=4 "1994-03") (2004/2010=5 "2004-10") (else=.), gen(arrcoh_unres)
	lab var arrcoh_unres "Arrival cohort"

	// Table
	qui forvalues s=1/2 {
		// Education
		foreach var in isced {

			local vlbl : variable label `var'

			forvalues c=1/3 {
				cap drop isced`c'
				clonevar isced`c' = isced if nat_c==`c'
			}
			label var isced1 "ISCED-97, non-naturalized immigrant"
			label var isced2 "ISCED-97, naturalized immigrant"
			label var isced3 "ISCED-97, naturalized/recognized Ethnic German"

			local tblname "nat_`var'_`fname`s''_unres"
			local tblttl "ISCED-97 composition by arrival cohort and naturalization, `lbl`s'', 2007-2015 (no upper age limit)"
			tabout isced1 isced2 isced3 arrcoh_unres [aw=hhpw] if sex==`s' ///
				using "${dir_t}`tblname'${tsfx}", ///
				replace c(col) f(1) clab(% n) npos(both) ${tabout_gen} ///
				${tabout_ttlpre}`tblttl'|`tblname'${tabout_ttlpost}
		}
	}
restore


//----------------------------------//
//    SELECTION TESTS: AGE 25-54   	//
//----------------------------------//

// analysis sample: restrict to maximum age 54
keep if (age>=25 & age<=54)

//
// Cohort size development over time (population projection): Period
//

local lbl1 Men
local lbl2 Women
local fname1 m
local fname2 f

// Table
qui forvalues s=1/2 {
	// Table
	local tblname "sum_cohortsize_period_`fname`s''"
	local tblttl "Cohort size development by period, `lbl`s''"
	tabout year arrcoh [iw=hhpw_pop] if sex==`s' ///
		using "${dir_t}`tblname'${tsfx}", replace ///
		c(freq) f(0c) clab(n) npos(lab) ///
		fn(Projected to population counts.) ${tabout_gen} ///
		${tabout_ttlpre}`tblttl'|`tblname'${tabout_ttlpost}
}

// Plot
preserve
	gen i = 1
	local var i
	// collapse
	collapse (count) n`var' = `var' ///
		[pw=hhpw_pop], by(arrcoh year sex)
	// apply restrictions
	replace n`var' = . ///
		if arrcoh==1 & (year<=1973 | year>2003) ///
		 | arrcoh==2 & (year<=1983 | year>2013) ///
		 | arrcoh==3 & year<=1993 ///
		 | arrcoh==4 & year<=2003 ///
		 | arrcoh==5 & year<=2010 // sensible cominations + max. interval
	replace n`var' = n`var' / 1000 // show in 1,000
	// plots and tables
	forvalues s=1/2 {
		// plot
		twoway ///
			(line n`var' year if arrcoh==1 & sex==`s', ///
			title("`lbl`s''") ytitle("Population counts (in 1,000)") ///
			xlabel(1976 1980(5)2015) ylabel(0(200)800) ///
			legend(order(- "Arr. cohort: " 1 "1964-73" 2 "1974-83" 3 "1984-93" ///
			4 "1994-03" 5 "2004-10") cols(6) stack span)) ///
			(line n`var' year if arrcoh==2 & sex==`s') ///
			(line n`var' year if arrcoh==3 & sex==`s') ///
			(line n`var' year if arrcoh==4 & sex==`s') ///
			(line n`var' year if arrcoh==5 & sex==`s')
		graph ${gsavemode} "${dir_g}sum_cohortsize_period_`fname`s''${gsfx}", replace
	}
restore

//
// Cohort size development over time (population projection): Duration of stay
//

local lbl1 Men
local lbl2 Women
local fname1 m
local fname2 f

// Table
qui forvalues s=1/2 {
	// Table
	local tblname "sum_cohortsize_timeres_`fname`s''"
	local tblttl "Cohort size development by duration of stay, `lbl`s''"
	tabout timeres arrcoh [iw=hhpw_pop] if sex==`s' & arrcoh!=0 & inrange(timeres,1,30) ///
		using "${dir_t}`tblname'${tsfx}", replace ///
		c(freq) f(0c) clab(n) npos(lab) ///
		fn(Projected to population counts.) ${tabout_gen} ///
		${tabout_ttlpre}`tblttl'|`tblname'${tabout_ttlpost}
}

// Plot
preserve
	gen i = 1
	local var i
	// collapse
	collapse (count) n`var' = `var' ///
		[pw=hhpw_pop], by(arrcoh timeres sex)
	// apply restrictions
	replace n`var' = . ///
		if arrcoh==1 & timeres<12 ///
		 | arrcoh==2 & timeres<2 ///
		 | arrcoh==3 & timeres>22 ///
		 | arrcoh==4 & timeres>12 ///
		 | arrcoh==5 & timeres>5 // sensible combinations
	replace timeres = . if !inrange(timeres,1,30) // graph bug
	replace n`var' = n`var' / 1000 // show in 1,000
	// plots and tables
	forvalues s=1/2 {
		// plot
		twoway ///
			(line n`var' timeres if arrcoh==1 & sex==`s', ///
			title("`lbl`s''") ytitle("Population counts (in 1,000)") ///
			xlabel(0(5)31) ylabel(0(200)800) ///
			legend(order(- "Arr. cohort: " 1 "1964-73" 2 "1974-83" 3 "1984-93" ///
			4 "1994-03" 5 "2004-10") cols(6) stack span)) ///
			(line n`var' timeres if arrcoh==2 & sex==`s') ///
			(line n`var' timeres if arrcoh==3 & sex==`s') ///
			(line n`var' timeres if arrcoh==4 & sex==`s') ///
			(line n`var' timeres if arrcoh==5 & sex==`s')
		graph ${gsavemode} "${dir_g}sum_cohortsize_timeres_`fname`s''${gsfx}", replace
	}
restore

//
// Remigration/Naturalization: ISCED levels by duration of stay
//

local lbl1 Men
local lbl2 Women
local fname1 m
local fname2 f

preserve

	replace isced = . ///
		if arrcoh==1 & timeres<12 ///
		 | arrcoh==2 & timeres<2 ///
		 | arrcoh==3 & timeres>22 ///
		 | arrcoh==4 & timeres>12 ///
		 | arrcoh==5 & timeres>5 // sensible combinations

	forvalues t=1/7 {
		local hi = `t'*3
		local lo = (`t'-1)*3
		clonevar isced_timeres`t' = isced if timeres>`lo' & timeres<=`hi' & !mi(arrcoh)
		lab var isced_timeres`t' "ISCED, dur. of stay: `lo'-`hi'y."
	}

	// Table
	qui forvalues s=1/2 {
		local tblname "sum_isced_remig_`fname`s''"
		local tblttl "Educational levels (ISCED-97) by cohort and duration of stay, `lbl`s''"
		tabout isced_timeres1 isced_timeres2 isced_timeres3 isced_timeres4 ///
			isced_timeres5 isced_timeres6 isced_timeres7 arrcoh if arrcoh!=0 & sex==`s' [iw=hhpw_pop] ///
			using "${dir_t}`tblname'${tsfx}", replace ///
			c(col) f(1) clab(%) npos(lab) fn(Column percent.) ${tabout_gen} ///
			${tabout_ttlpre}`tblttl'|`tblname'${tabout_ttlpost} ///
			h2(1964-1973 1974-1983 1984-1993 1994-2003 2004-2010 Total) h2c(1 1 1 1 1 1) ///
			plugc(1:2 2:2 3:2 5:5 6:5 7:5 8:5 3:6 4:6 5:6 6:6 7:6 8:6)
	}

restore

//
// Naturalization
//

// ISCED levels and employment outcomes by citizenship/naturalization status
preserve
	// Prep
	/*
	 Use all years where naturalization data available disaggregated for
	 naturalized immigrants and ethnic Germans with German citizenship.
	*/
	keep if year>=2007
	recode cship_nat (.=.) (1=.) (3=2) (4 2 = 3) (0 -5 = 1), gen(nat_c)
	lab var nat_c "Naturalization status"
	lab def nat_c 1 "Non-naturalized immigrant" 2 "Naturalized immigrant" ///
		3 "Naturalized/recognized Ethnic German" 4 "German by birth", modify
	lab val nat_c nat_c

	// arrival cohort var (the other is missing if ger==1)
	recode yimmi ///
		(1964/1973=1 "1964-73") (1974/1983=2 "1974-83") (1984/1993=3 "1984-93") ///
		(1994/2003=4 "1994-03") (2004/2010=5 "2004-10") (else=.), gen(arrcoh_unres)
	lab var arrcoh_unres "Arrival cohort"

	// Table
	qui forvalues s=1/2 {
		// Education
		foreach var in isced {

			local ttl : variable label `var'

			forvalues c=1/3 {
				cap drop isced`c'
				clonevar isced`c' = isced if nat_c==`c'
			}
			label var isced1 "ISCED-97, non-naturalized immigrant"
			label var isced2 "ISCED-97, naturalized immigrant"
			label var isced3 "ISCED-97, naturalized/recognized Ethnic German"

			local tblname "nat_`var'_`fname`s''"
			local tblttl "ISCED-97 composition by arrival cohort and naturalization, `lbl`s'', 2007-2015"
			tabout isced1 isced2 isced3 arrcoh_unres [aw=hhpw] if sex==`s' ///
				using "${dir_t}`tblname'${tsfx}", ///
				replace c(col) f(1) clab(% n) npos(both) ${tabout_gen} ///
				${tabout_ttlpre}`tblttl'|`tblname'${tabout_ttlpost}
		}
		// Outcomes
		foreach var in empl_dummy ahours isei88_res {

			local vlbl : variable label `var'

			local tblname "nat_`var'_`fname`s''"
			local tblttl "`vlbl' by arrival cohort and naturalization, `lbl`s'', 2007-2015"
			tabout nat_c arrcoh_unres [aw=hhpw] if sex==`s' ///
				using "${dir_t}`tblname'${tsfx}", ///
				replace sum c(mean `var') f(2) clab(Mean) ${tabout_gen} ///
				${tabout_ttlpre}`tblttl'|`tblname'${tabout_ttlpost}

			local tblname "nat_`var'_n_`fname`s''"
			local tblttl "No. of obs.: `vlbl' by arrival cohort and naturalization, `lbl`s'', 2007-2015"
			tabout nat_c arrcoh_unres [aw=hhpw] if sex==`s' ///
				using "${dir_t}`tblname'${tsfx}", ///
				replace c(freq) f(0) clab(n) npos(both) ${tabout_gen} ///
				${tabout_ttlpre}`tblttl'|`tblname'${tabout_ttlpost}

		}
	}
restore

// Plot by time of residence

// grstyle set
grstyle clear
grstyle init
grstyle set plain, grid noextend horizontal  // imesh = R
grstyle set color cblind, select(3 3 4 4 5 5 8 8 9 9)
grstyle set color cblind, select(2): p11 p12 // natives
grstyle set lpattern shortdash: p2 p4 p6 p8 p10 p12 // natives & full immigrant sample
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
		// keep MZ sample with naturalization info
		keep if year>=2007
		recode cship_nat (.=.) (1=4) (3=2) (4 2 = 3) (0 -5 = 1), gen(nat_c)
		lab var nat_c "Naturalization status"
		lab def nat_c 1 "Non-naturalized immigrant" 2 "Naturalized immigrant" ///
			3 "Naturalized/recognized Ethnic German" 4 "German by birth", modify
		lab val nat_c nat_c
		// recode arrival cohort var (the other is missing if ger==1)
		recode yimmi ///
			(1964/1973=1 "1964-73") (1974/1983=2 "1974-83") (1984/1993=3 "1984-93") ///
			(1994/2003=4 "1994-03") (2004/2010=5 "2004-10") (else=.), gen(arrcoh_unres)
		replace arrcoh_unres = 0 if ger==1 & mi(yimmi)
		lab def arrcoh_unres 0 "Germans", modify
		lab var arrcoh_unres "Arrival cohort"
		// collapse
		collapse (mean) `var' (count) n`var' = `var' ///
			[aw=hhpw], by(arrcoh_unres year sex nat_c)
		// estimate general mean for immigrants
		gen `var'_temp = `var' * n`var'
		egen tot`var' = total(`var'_temp), by(arrcoh_unres year sex)
		egen totn`var' = total(n`var'), by(arrcoh_unres year sex)
		gen gm_`var' = tot`var' /  totn`var' // grand mean
		// apply restrictions
		replace `var' = . ///
			if arrcoh_unres==1 & (year<=1973 | year>2003) ///
			 | arrcoh_unres==2 & (year<=1983 | year>2013) ///
			 | arrcoh_unres==3 & year<=1993 ///
			 | arrcoh_unres==4 & year<=2003 ///
			 | arrcoh_unres==5 & year<=2010 // sensible cominations + max. interval
		replace gm_`var' = . ///
			if arrcoh_unres==1 & (year<=1973 | year>2003) ///
			 | arrcoh_unres==2 & (year<=1983 | year>2013) ///
			 | arrcoh_unres==3 & year<=1993 ///
			 | arrcoh_unres==4 & year<=2003 ///
			 | arrcoh_unres==5 & year<=2010 // sensible cominations + max. interval
		replace `var' = . if n`var'<`nmin' // cell counts too low
		replace gm_`var' = . if totn`var'<`nmin' // cell counts too low
		// plots and tables
		forvalues s=1/2 {
			// plot
			twoway ///
				(line `var' year if arrcoh_unres==1 & sex==`s' & nat_c==1, ///
				title("`lbl`s''") ytitle("`ttl'") ylabel(`ylbl_`var'') ///
				xlabel(2007(2)2015) ///
				legend(order(- "Arr. cohort: " 1 "1964-73" 3 "1974-83" 5 "1984-93" ///
				7 "1994-03" 9 "2004-10" 11 "German" - "" 2 "incl. nat." 4 "incl. nat." ///
				6 "incl. nat." 8 "incl. nat." 10 "incl. nat.") cols(7) stack span)) ///
				(line gm_`var'  year if arrcoh_unres==1 & sex==`s') ///
				(line `var' 	year if arrcoh_unres==2 & sex==`s' & nat_c==1) ///
				(line gm_`var'  year if arrcoh_unres==2 & sex==`s') ///
				(line `var' 	year if arrcoh_unres==3 & sex==`s' & nat_c==1) ///
				(line gm_`var'  year if arrcoh_unres==3 & sex==`s') ///
				(line `var' 	year if arrcoh_unres==4 & sex==`s' & nat_c==1) ///
				(line gm_`var'  year if arrcoh_unres==4 & sex==`s') ///
				(line `var' 	year if arrcoh_unres==5 & sex==`s' & nat_c==1) ///
				(line gm_`var'  year if arrcoh_unres==5 & sex==`s') /*
				german natives as grey reference
			*/	(line gm_`var' 	year if arrcoh_unres==0 & sex==`s', lcolor(gs10) lpattern(dash))
			graph ${gsavemode} "${dir_g}nat_`var'_period_`fname`s''${gsfx}", replace
		}
	restore
}

// grstyle reset
grstyle clear
grstyle init
grstyle set plain, grid noextend horizontal  // imesh = R
grstyle set color cblind, select(3 4 5 8 9)
grstyle set color cblind, select(2): p6 // natives
grstyle set lpattern shortdash: p6 p7 p8 p9 p10 p11 // natives
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
// Other tests
//

// distribution cohorts at break 2004 -> 2005
local tblname "sum_cohort_sel_nonres_2004-2006"
local tblttl "Cohort selective nonresponse test 2004-2006"
tabout year arrcoh if inrange(year,2004,2006) & !inlist(arrcoh,0,5) [iw=hhpw_pop] ///
	using "${dir_t}`tblname'${tsfx}", ///
	replace c(freq row) f(0c 1) clab(n %) npos(lab) ${tabout_gen} ///
	${tabout_ttlpre}`tblttl'|`tblname'${tabout_ttlpost}

// employment status by year for men
local tblname "sum_cohort_1_emplst_m"
local tblttl "Employment status cohort 1964-1973 by period, Men"
tabout year empl if arrcoh==1 & sex==1 [iw=hhpw_pop] ///
	using "${dir_t}`tblname'${tsfx}", ///
	replace c(freq row) f(0c 1) clab(n %) npos(lab) ${tabout_gen} ///
	${tabout_ttlpre}`tblttl'|`tblname'${tabout_ttlpost}

// subsistence source by year for men
local tblname "sum_cohort_1_subsis_m"
local tblttl "Main subsistence source cohort 1964-1973 by period, Men"
tabout year subsis if arrcoh==1 & sex==1 [iw=hhpw_pop] ///
	using "${dir_t}`tblname'${tsfx}", ///
	replace c(freq row) f(0c 1) clab(n %) npos(lab) landscape ${tabout_gen} ///
	${tabout_ttlpre}`tblttl'|`tblname'${tabout_ttlpost}

// Cohort arrival age composition
local lbl1 Men
local lbl2 Women
local fname1 m
local fname2 f

qui forvalues s=1/2 {
	local tblname "sum_arrage_`fname`s''"
	local tblttl "Arrival age composition by cohort, `lbl`s''"
	tabout arragec arrcoh [iw=hhpw] if sex==`s' ///
		using "${dir_t}`tblname'${tsfx}", replace ///
		c(col) f(1) clab(%) npos(lab) ${tabout_gen} ///
		${tabout_ttlpre}`tblttl'|`tblname'${tabout_ttlpost}
}


//----------------------------------//
//    DESCRIPTIVES (W. AGE LIMIT)   //
//----------------------------------//

// analysis sample: restrict to maximum age 54
keep if (age>=25 & age<=54)

// final sample counts
count if !missing(arrcoh)
count if arrcoh==0
count if inrange(arrcoh,1,5)

//
// Reduced summary statistics: ISCED groups, mean age
//

// table
local lbl2 Women
local lbl1 Men
local fname2 m
local fname1 f

cap drop sum_*

preserve

	qui forvalues s=1/2 {

		// placeholders
		gen sum_isced1_`s' = .
		gen sum_isced2_`s' = .
		gen sum_isced3_`s' = .
		gen sum_age_`s' = .

		if `s'==1 {
			gen sum_sex = . // just one variable for all
		}

		local ccnt 0

		foreach y in 1976 1985 1995 2004 2011 {

			local ++ccnt // cohort counter
			local clbl : label arrcoh `ccnt'

			if `s'==1 {
				gen sum_grp_`y'=. // placeholder
			}

			//
			// germans
			//
			replace sum_grp_`y' = 1 if year==`y' & arrcoh==0 & sex==`s'
			lab var sum_grp_`y' "Year: `y'"
			lab def sum_grp_`y' 1 "Germans" 2 "Arrival cohort `clbl'", modify
			lab val sum_grp_`y' sum_grp_`y'
			// isced
			replace sum_isced1_`s' = 0 if !mi(isced) & year==`y' & arrcoh==0 & sex==`s'
			replace sum_isced1_`s' = 100 if isced==1 & year==`y' & arrcoh==0 & sex==`s'
			replace sum_isced2_`s' = 0 if !mi(isced) & year==`y' & arrcoh==0 & sex==`s'
			replace sum_isced2_`s' = 100 if isced==2 & year==`y' & arrcoh==0 & sex==`s'
			replace sum_isced3_`s' = 0 if !mi(isced) & year==`y' & arrcoh==0 & sex==`s'
			replace sum_isced3_`s' = 100 if isced==3 & year==`y' & arrcoh==0 & sex==`s'
			// age
			replace sum_age_`s' = age if year==`y' & arrcoh==0 & sex==`s'
			// % women
			replace sum_sex = (sex-1)*100 if year==`y' & arrcoh==0 & sex==`s'

			//
			// foreigners
			//
			replace sum_grp_`y' = 2 if year==`y' & arrcoh==`ccnt' & sex==`s'
			// isced
			replace sum_isced1_`s' = 0 if !mi(isced) & year==`y' & arrcoh==`ccnt' & sex==`s'
			replace sum_isced1_`s' = 100 if isced==1 & year==`y' & arrcoh==`ccnt' & sex==`s'
			replace sum_isced2_`s' = 0 if !mi(isced) & year==`y' & arrcoh==`ccnt' & sex==`s'
			replace sum_isced2_`s' = 100 if isced==2 & year==`y' & arrcoh==`ccnt' & sex==`s'
			replace sum_isced3_`s' = 0 if !mi(isced) & year==`y' & arrcoh==`ccnt' & sex==`s'
			replace sum_isced3_`s' = 100 if isced==3 & year==`y' & arrcoh==`ccnt' & sex==`s'
			// age
			replace sum_age_`s' = age if year==`y' & arrcoh==`ccnt' & sex==`s'
			// % women
			replace sum_sex = (sex-1)*100 if year==`y' & arrcoh==`ccnt' & sex==`s'

		}

	}
	local tblname "sum_edu_age_init"
	local tblttl "Education and age composition by arrival cohort"
	tabout ///
		sum_grp_1976 sum_grp_1985 sum_grp_1995 sum_grp_2004 sum_grp_2011 [aw=hhpw] ///
		using "${dir_t}`tblname'${tsfx}", replace sum  ///
		c(mean sum_isced1_2 mean sum_isced2_2 mean sum_isced3_2 mean sum_age_2 ///
		  mean sum_isced1_1 mean sum_isced2_1 mean sum_isced3_1 mean sum_age_1 ///
	  	  mean sum_sex) ///
		h3(0-2 3-4 5-6 Mean 0-2 3-4 5-6 Mean %) h3c(1 1 1 1 1 1 1 1 1) ///
		h2(ISCED_(%) Age ISCED_(%) Age Women) h2c(3 1 3 1 1) ///
		h1(Women Men All) h1c(4 4 1) ptotal(none) f(1) npos(lab) ${tabout_gen} ///
		${tabout_ttlpre}`tblttl'|`tblname'${tabout_ttlpost} ///
		fn(Statistics reported for each immigration cohort in the first observed ///
			year after end of the respective arrival period. ISCED values sum to ///
			100% per row and gender.)
restore



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

foreach var in empl_dummy ahours isei88_res {

	local ttl : variable label `var'


	preserve
		// collapse
		collapse (mean) `var' (count) n`var' = `var' ///
			if asample==1 & timeres>0 & !missing(timeres) ///
			[aw=hhpw], by(arrcoh timeres sex)
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
		// plots and tables
		forvalues s=1/2 {
			// plot
			twoway ///
				(line `var' timeres if arrcoh==1 & sex==`s', ///
				title("`lbl`s''") ytitle("`ttl'") ylabel(`ylbl_`var'') ///
				xlabel(0(5)31) ///
				legend(order(- "Arr. cohort: " 1 "1964-73" 2 "1974-83" 3 "1984-93" ///
				4 "1994-03" 5 "2004-10") cols(6) stack span)) ///
				(line `var' timeres if arrcoh==2 & sex==`s') ///
				(line `var' timeres if arrcoh==3 & sex==`s') ///
				(line `var' timeres if arrcoh==4 & sex==`s') ///
				(line `var' timeres if arrcoh==5 & sex==`s')
			graph ${gsavemode} "${dir_g}`var'_timeres_`fname`s''${gsfx}", replace
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

// ISEI drops in the first years of residence due to rising employment rates of less educated?

local ttl : variable label empl_dummy

preserve
	// collapse
	collapse (mean) empl_dummy (count) nempl_dummy = empl_dummy ///
		if asample==1 & timeres>0 & !missing(timeres) ///
		[pw=hhpw_pop], by(arrcoh timeres sex isced)
	// n employed
	replace nempl_dummy = (nempl_dummy * (empl_dummy/100))/1000
	grstyle set color cblind, select(3 4 5 8 9): p1 p2 p3 p4 p5
	grstyle set color cblind, select(3 4 5 8 9): p6 p7 p8 p9 p10
	grstyle set lpattern shortdash: p6 p7 p8 p9 p10
	grstyle set color cblind, select(3 4 5 8 9): p11 p12 p13 p14 p15
	grstyle set lpattern dash_dot: p11 p12 p13 p14 p15
	// apply restrictions
	replace empl_dummy = . ///
		if arrcoh==1 & timeres<12 ///
		 | arrcoh==2 & timeres<2 ///
		 | arrcoh==3 & timeres>22 ///
		 | arrcoh==4 & timeres>12 ///
		 | arrcoh==5 & timeres>5 // sensible combinations
	replace nempl_dummy = . ///
		if arrcoh==1 & timeres<12 ///
		 | arrcoh==2 & timeres<2 ///
		 | arrcoh==3 & timeres>22 ///
		 | arrcoh==4 & timeres>12 ///
		 | arrcoh==5 & timeres>5 // sensible combinations
	replace timeres = . if timeres>30 // 30 years max
	replace empl_dummy = . if nempl_dummy<(`nmin'/10) // cell counts too low
	replace nempl_dummy = . if nempl_dummy<(`nmin'/10) // cell counts too low
	forvalues s=1/2 {
		// n
		twoway ///
			(line nempl_dummy timeres if arrcoh==1 & sex==`s' & isced==1, ///
			title("`lbl`s''") ytitle("No. of employed (in 1,000)") ///
			xlabel(0(5)31) ylabel(0(50)200) ///
			legend(order(- "ISCED 0-2: " 1 "1964-73" 2 "1974-83" 3 "1984-93" ///
			4 "1994-03" 5 "2004-10" - "ISCED 3-4:" 6 "1964-73" 7 "1974-83" ///
			8 "1984-93" 9 "1994-03" 10 "2004-10" - "ISCED 5-6:" 11 "1964-73" ///
			12 "1974-83" 13 "1984-93" 14 "1994-03" 15 "2004-10") ///
			cols(6) stack span)) ///
			(line nempl_dummy timeres if arrcoh==2 & sex==`s' & isced==1) ///
			(line nempl_dummy timeres if arrcoh==3 & sex==`s' & isced==1) ///
			(line nempl_dummy timeres if arrcoh==4 & sex==`s' & isced==1) ///
			(line nempl_dummy timeres if arrcoh==5 & sex==`s' & isced==1) ///
			(line nempl_dummy timeres if arrcoh==1 & sex==`s' & isced==2) ///
			(line nempl_dummy timeres if arrcoh==2 & sex==`s' & isced==2) ///
			(line nempl_dummy timeres if arrcoh==3 & sex==`s' & isced==2) ///
			(line nempl_dummy timeres if arrcoh==4 & sex==`s' & isced==2) ///
			(line nempl_dummy timeres if arrcoh==5 & sex==`s' & isced==2) ///
			(line nempl_dummy timeres if arrcoh==1 & sex==`s' & isced==3) ///
			(line nempl_dummy timeres if arrcoh==2 & sex==`s' & isced==3) ///
			(line nempl_dummy timeres if arrcoh==3 & sex==`s' & isced==3) ///
			(line nempl_dummy timeres if arrcoh==4 & sex==`s' & isced==3) ///
			(line nempl_dummy timeres if arrcoh==5 & sex==`s' & isced==3)
		graph ${gsavemode} "${dir_g}empl_dummy_timeres_edu_n_`fname`s''${gsfx}", replace
		// share
		twoway ///
			(line empl_dummy timeres if arrcoh==1 & sex==`s' & isced==1, ///
			title("`lbl`s''") ytitle("`ttl'") ///
			xlabel(0(5)31) ///
			legend(order(- "ISCED 0-2: " 1 "1964-73" 2 "1974-83" 3 "1984-93" ///
			4 "1994-03" 5 "2004-10" - "ISCED 3-4:" 6 "1964-73" 7 "1974-83" ///
			8 "1984-93" 9 "1994-03" 10 "2004-10" - "ISCED 5-6:" 11 "1964-73" ///
			12 "1974-83" 13 "1984-93" 14 "1994-03" 15 "2004-10") ///
			cols(6) stack span)) ///
			(line empl_dummy timeres if arrcoh==2 & sex==`s' & isced==1) ///
			(line empl_dummy timeres if arrcoh==3 & sex==`s' & isced==1) ///
			(line empl_dummy timeres if arrcoh==4 & sex==`s' & isced==1) ///
			(line empl_dummy timeres if arrcoh==5 & sex==`s' & isced==1) ///
			(line empl_dummy timeres if arrcoh==1 & sex==`s' & isced==2) ///
			(line empl_dummy timeres if arrcoh==2 & sex==`s' & isced==2) ///
			(line empl_dummy timeres if arrcoh==3 & sex==`s' & isced==2) ///
			(line empl_dummy timeres if arrcoh==4 & sex==`s' & isced==2) ///
			(line empl_dummy timeres if arrcoh==5 & sex==`s' & isced==2) ///
			(line empl_dummy timeres if arrcoh==1 & sex==`s' & isced==3) ///
			(line empl_dummy timeres if arrcoh==2 & sex==`s' & isced==3) ///
			(line empl_dummy timeres if arrcoh==3 & sex==`s' & isced==3) ///
			(line empl_dummy timeres if arrcoh==4 & sex==`s' & isced==3) ///
			(line empl_dummy timeres if arrcoh==5 & sex==`s' & isced==3)
		graph ${gsavemode} "${dir_g}empl_dummy_timeres_edu_`fname`s''${gsfx}", replace
	}
restore


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
			[aw=hhpw], by(arrcoh year sex)
		// apply restrictions
		replace `var' = . ///
			if arrcoh==1 & (year<=1973 | year>2003) ///
			 | arrcoh==2 & (year<=1983 | year>2013) ///
			 | arrcoh==3 & year<=1993 ///
			 | arrcoh==4 & year<=2003 ///
			 | arrcoh==5 & year<=2010 // sensible cominations + max. interval
		replace `var' = . if n`var'<`nmin' // cell counts too low
		// plots and tables
		forvalues s=1/2 {
			// plot
			twoway ///
				(line `var' year if arrcoh==1 & sex==`s', ///
				title("`lbl`s''") ytitle("`ttl'") ylabel(`ylbl_`var'') ///
				xlabel(1976 1980(5)2015) ///
				legend(order(- "Arr. cohort: " 1 "1964-73" 2 "1974-83" 3 "1984-93" ///
				4 "1994-03" 5 "2004-10" 6 "German") cols(7) stack span)) ///
				(line `var' year if arrcoh==2 & sex==`s') ///
				(line `var' year if arrcoh==3 & sex==`s') ///
				(line `var' year if arrcoh==4 & sex==`s') ///
				(line `var' year if arrcoh==5 & sex==`s') /*
				german natives as grey reference
			*/	(line `var' year if arrcoh==0 & sex==`s', lcolor(gs10) lpattern(dash))
			graph ${gsavemode} "${dir_g}`var'_period_`fname`s''${gsfx}", replace
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

// plot employment type shares
local ttl1 "Full-time"
local ttl2 "Part-time"
local ttl3 "Marginal"

preserve
	// gen dummies
	tab emplst, gen(emplst)
	// keep employed only
	keep if empl_dummy==100
	// collapse
	collapse (mean) emplst1 emplst2 emplst3 ///
		(count) nemplst1=emplst1 nemplst2=emplst2 nemplst3=emplst3 ///
		if asample==1 & ((timeres>0 & !missing(timeres)) | (missing(timeres) & arrcoh==0))  ///
		[aw=hhpw], by(arrcoh year sex)
	// apply restrictions
	replace year = . ///
		if arrcoh==1 & (year<=1973 | year>2003) ///
		 | arrcoh==2 & (year<=1983 | year>2013) ///
		 | arrcoh==3 & year<=1993 ///
		 | arrcoh==4 & year<=2003 ///
		 | arrcoh==5 & year<=2010 // sensible cominations + max. interval
	replace year = . if nemplst1<`nmin' // cell counts too low
	replace year = . if nemplst2<`nmin' // cell counts too low
	replace year = . if nemplst3<`nmin' // cell counts too low
	// percent
	replace emplst1 = emplst1*100
	replace emplst2 = emplst2*100
	replace emplst3 = emplst3*100
	// plot
	forvalues s=1/2 {
		forvalues e=1/3 {
			local var emplst`e'
			twoway ///
				(line `var' year if arrcoh==1 & sex==`s', ///
				title("`lbl`s''") ytitle("`ttl`e'' employment share (in %)") ylabel(0(0.1)1) ///
				ylabel(0(10)100) xlabel(1976 1980(5)2015) /*
				note("Shares correspond to individuals in employment.", span) ///
				*/ legend(order(- "Arr. cohort: " 1 "1964-73" 2 "1974-83" 3 "1984-93" ///
				4 "1994-03" 5 "2004-10" 6 "German") cols(7) stack span)) ///
				(line `var' year if arrcoh==2 & sex==`s') ///
				(line `var' year if arrcoh==3 & sex==`s') ///
				(line `var' year if arrcoh==4 & sex==`s') ////
				(line `var' year if arrcoh==5 & sex==`s') /*
				german natives as grey reference
			*/	(line `var' year if arrcoh==0 & sex==`s', lcolor(gs10) lpattern(dash))
			graph ${gsavemode} "${dir_g}`var'_period_`fname`s''${gsfx}", replace
		}
	}
restore


// combine graphs of women and men side-by-side for JFR
else if "`outfmt'"=="JFR" {
	
	// grstyle
	grstyle set graphsize 8cm 15cm
	grstyle set size 11pt: heading
	grstyle set size 9pt: axis_title
	grstyle set size 8pt: key_label
	grstyle set size 8pt: tick_label body small_body
	grstyle set size 0pt: legend_key_gap
	grstyle set size 29pt: legend_key_xsize
	grstyle set size -1pt: legend_row_gap
	grstyle set size 5pt: legend_col_gap
	grstyle set symbolsize 5, pt
	grstyle set linewidth 1pt: p1 p2 p3 p4 p5 p6 p7 p8 p9 p10 p11 p12
	grstyle set linewidth .4pt: pmark legend axisline tick major_grid
	grstyle set margin "0 0 2 0": heading
	grstyle set margin "0 3 3 0": axis_title
	grstyle set margin "3 3 3 3": graph
	
	local i = 1
	
	// for each outcome by period
	foreach var in empl_dummy ahours isei88_res {
		local ++i
		graph combine ///
			"${dir_g}`var'_period_f${gsfx}" ///
			"${dir_g}`var'_period_m${gsfx}" ///		
			, rows(1) imargin(0 4 0 0)
		graph export "${dir_g}fig`i'_`var'_period.eps", replace // for JFR
		graph export "${dir_g}fig`i'_`var'_period.svg", replace // for view			
	}
	
	grstyle set size 30pt: legend_key_xsize
	
	// for isei by duration of stay
	foreach var in isei88_res {
		local ++i
		graph combine ///
			"${dir_g}`var'_timeres_f${gsfx}" ///
			"${dir_g}`var'_timeres_m${gsfx}" ///		
			, rows(1) imargin(0 4 0 0)
		graph export "${dir_g}fig`i'_`var'_timeres.eps", replace // for JFR
		graph export "${dir_g}fig`i'_`var'_timeres.svg", replace // for view
	}
	
}

// clear
clear
