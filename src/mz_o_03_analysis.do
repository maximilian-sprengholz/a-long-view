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

local outfmt MD // switch

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
			barwidth(0.4) fintensity(30) xlabel(1976(5)2016) ///
			ytitle(Share with missing information (percent)) ///
			title(Non-reponse on arrival year variable) subtitle(By Year) ///
			legend(order(1 "Women" 2 "Men")) /* ///
			note("Corresponds to analysis sample except for arrival year restrictions. Shares for persons with non-German citizenship who did not state to have been born in Germany.")*/)
	// export and add HTML wrapper
	graph export "${dir_g}sum_yimmi_nonres${gsfx}", replace
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
			ytitle("Population counts in 1,000") ///
			title("Cohort size development by duration of stay, `lbl`s''") subtitle("N total, age 18-54") ///
			xlabel(0(5)31) ylabel(0(200)800) ///
			legend(order(- "Arr. cohort: " 1 "1964-73" 2 "1974-83" 3 "1984-93" ///
			4 "1994-03" 5 "2004-10") cols(6) stack span)) ///
			(line n`var' timeres if arrcoh==2 & sex==`s') ///
			(line n`var' timeres if arrcoh==3 & sex==`s') ///
			(line n`var' timeres if arrcoh==4 & sex==`s') ///
			(line n`var' timeres if arrcoh==5 & sex==`s')
		// export and add HTML wrapper
		graph export "${dir_g}sum_cohortsize_timeres_`fname`s''_18_54${gsfx}", replace
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
			if asample==1 & age<=54 & timeres>0 & !missing(timeres) ///
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
				title("`ttl', `lbl`s''") subtitle("`sttl_`var'', age 18-54") ///
				xlabel(0(5)31) ///
				legend(order(- "Arr. cohort: " 1 "1964-73" 2 "1974-83" 3 "1984-93" ///
				4 "1994-03" 5 "2004-10") cols(6) stack span)) ///
				(line `var' timeres if arrcoh==2 & sex==`s') ///
				(line `var' timeres if arrcoh==3 & sex==`s') ///
				(line `var' timeres if arrcoh==4 & sex==`s') ///
				(line `var' timeres if arrcoh==5 & sex==`s')
			graph export "${dir_g}`var'_timeres_`fname`s''_18_54${gsfx}", replace
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
			ytitle("Population counts in 1,000") ///
			title("Cohort size development by period, `lbl`s''") subtitle("N total, no upper age limit") ///
			xlabel(1976(5)2016) ylabel(0(200)800) ///
			legend(order(- "Arr. cohort: " 1 "1964-73" 2 "1974-83" 3 "1984-93" ///
			4 "1994-03" 5 "2004-10") cols(6) stack span)) ///
			(line n`var' year if arrcoh==2 & sex==`s') ///
			(line n`var' year if arrcoh==3 & sex==`s') ///
			(line n`var' year if arrcoh==4 & sex==`s') ///
			(line n`var' year if arrcoh==5 & sex==`s')
		graph export "${dir_g}sum_cohortsize_period_`fname`s''_unres${gsfx}", replace
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
			ytitle("Population counts in 1,000") ///
			title("Cohort size development by duration of stay, `lbl`s''") subtitle("N total, no upper age limit") ///
			xlabel(0(5)31) ylabel(0(200)800) ///
			legend(order(- "Arr. cohort: " 1 "1964-73" 2 "1974-83" 3 "1984-93" ///
			4 "1994-03" 5 "2004-10") cols(6) stack span)) ///
			(line n`var' timeres if arrcoh==2 & sex==`s') ///
			(line n`var' timeres if arrcoh==3 & sex==`s') ///
			(line n`var' timeres if arrcoh==4 & sex==`s') ///
			(line n`var' timeres if arrcoh==5 & sex==`s')
		graph export "${dir_g}sum_cohortsize_timeres_`fname`s''_unres${gsfx}", replace
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
			ytitle("Population counts in 1,000") ///
			title("Cohort size development by period, `lbl`s''") subtitle("N total") ///
			xlabel(1976(5)2016) ylabel(0(200)800) ///
			legend(order(- "Arr. cohort: " 1 "1964-73" 2 "1974-83" 3 "1984-93" ///
			4 "1994-03" 5 "2004-10") cols(6) stack span)) ///
			(line n`var' year if arrcoh==2 & sex==`s') ///
			(line n`var' year if arrcoh==3 & sex==`s') ///
			(line n`var' year if arrcoh==4 & sex==`s') ///
			(line n`var' year if arrcoh==5 & sex==`s')
		graph export "${dir_g}sum_cohortsize_period_`fname`s''.svg", replace
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
			ytitle("Population counts in 1,000") ///
			title("Cohort size development by duration of stay, `lbl`s''") subtitle("N total") ///
			xlabel(0(5)31) ylabel(0(200)800) ///
			legend(order(- "Arr. cohort: " 1 "1964-73" 2 "1974-83" 3 "1984-93" ///
			4 "1994-03" 5 "2004-10") cols(6) stack span)) ///
			(line n`var' timeres if arrcoh==2 & sex==`s') ///
			(line n`var' timeres if arrcoh==3 & sex==`s') ///
			(line n`var' timeres if arrcoh==4 & sex==`s') ///
			(line n`var' timeres if arrcoh==5 & sex==`s')
		graph export "${dir_g}sum_cohortsize_timeres_`fname`s''.svg", replace
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

			local vlbl : variable label `var'

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

local sttl_empl_dummy 	Percent
local sttl_ahours 		Means
local sttl_isei88 		Means
local sttl_isei88_res 	Means
local sttl_isced 		Means


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
			[pw=hhpw], by(arrcoh_unres year sex nat_c)
		// estimate general mean for immigrants
		gen `var'_temp = `var' * n`var'
		egen tot`var' = total(`var'_temp), by(arrcoh_unres year sex)
		egen totn`var' = total(n`var'), by(arrcoh_unres year sex)
		gen gm_`var' = tot`var' /  totn`var' // grand mean
		// apply restrictions
		replace `var' = . ///
			if arrcoh==1 & (year<=1973 | year>2003) ///
			 | arrcoh==2 & (year<=1983 | year>2013) ///
			 | arrcoh==3 & year<=1993 ///
			 | arrcoh==4 & year<=2003 ///
			 | arrcoh==5 & year<=2010 // sensible cominations + max. interval
		replace gm_`var' = . ///
			if arrcoh==1 & (year<=1973 | year>2003) ///
			 | arrcoh==2 & (year<=1983 | year>2013) ///
			 | arrcoh==3 & year<=1993 ///
			 | arrcoh==4 & year<=2003 ///
			 | arrcoh==5 & year<=2010 // sensible cominations + max. interval
		replace `var' = . if n`var'<`nmin' // cell counts too low
		replace gm_`var' = . if totn`var'<`nmin' // cell counts too low
		if "`var'"=="empl_dummy" {
			replace empl_dummy = empl_dummy*100
			replace gm_empl_dummy = gm_empl_dummy*100
		}
		// plots and tables
		forvalues s=1/2 {
			// plot
			twoway ///
				(line `var' year if arrcoh==1 & sex==`s' & nat_c==1, ///
				ytitle("`ttl'") ylabel(`ylbl_`var'') ///
				title("`ttl', `lbl`s''") subtitle("`sttl_`var''") ///
				xlabel(2007(2)2015) ///
				legend(order(- "Arr. cohort: " 1 "1964-73" 3 "1974-83" 5 "1984-93" ///
				7 "1994-03" 9 "2004-10" 11 "German" - "" 2 "incl. nat." 4 "incl. nat." ///
				6 "incl. nat." 8 "incl. nat." 10 "incl. nat.") cols(7) stack span)) ///
				(line gm_`var'  year if arrcoh==1 & sex==`s') ///
				(line `var' 	year if arrcoh==2 & sex==`s' & nat_c==1) ///
				(line gm_`var'  year if arrcoh==2 & sex==`s') ///
				(line `var' 	year if arrcoh==3 & sex==`s' & nat_c==1) ///
				(line gm_`var'  year if arrcoh==3 & sex==`s') ///
				(line `var' 	year if arrcoh==4 & sex==`s' & nat_c==1) ///
				(line gm_`var'  year if arrcoh==4 & sex==`s') ///
				(line `var' 	year if arrcoh==5 & sex==`s' & nat_c==1) ///
				(line gm_`var'  year if arrcoh==5 & sex==`s') /*
				german natives as grey reference
			*/	(line gm_`var' 	year if arrcoh==0 & sex==`s', lcolor(gs10) lpattern(dash))
			graph export "${dir_g}nat_`var'_period_`fname`s''${gsfx}", replace
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

// plot
preserve

	tab isced, gen(isced)
	keep if inlist(year, 1976, 1985, 1995, 2004, 2011)

	collapse isced1 isced2 isced3 ///
	[pw=hhpw], by(year arrcoh sex)

	replace isced2 = isced1 + isced2
	replace isced3 = 1

	gen id=_n

	reshape long isced, i(id) j(iscedl)

	drop if year==1976 & !inlist(arrcoh,0,1)
	drop if year==1985 & !inlist(arrcoh,0,2)
	drop if year==1995 & !inlist(arrcoh,0,3)
	drop if year==2004 & !inlist(arrcoh,0,4)
	drop if year==2011 & !inlist(arrcoh,0,5)

	lab def iscedl 1 "ISCED-97 0-2" 2 "ISCED-97 3-4" 3 "ISCED-97 5-6"
	lab val iscedl iscedl

	egen grp = group(year arrcoh)

	// grstyle
	grstyle clear
	grstyle init
	grstyle set plain, noextend horizontal  // imesh = R
	grstyle set color cblind, select(2): p1 p2 p3 p4 p5 p6
	grstyle set color cblind, select(3): p7 p8 p9 p10 p11 p12
	grstyle set color cblind, select(4): p13 p14 p15 p16 p17 p18
	grstyle set color cblind, select(5): p19 p20 p21 p22 p23 p24
	grstyle set color cblind, select(8): p25 p26 p27 p28 p29 p30
	grstyle set color cblind, select(9): p31 p32 p33 p34 p35 p36
	grstyle set intensity 80: p1 p4 p7 p10 p13 p16 p19 p22 p25 p28 p31 p34
	grstyle set intensity 55: p2 p5 p8 p11 p14 p17 p20 p23 p25 p29 p32 p33
	grstyle set intensity 30: p3 p6 p9 p12 p15 p18 p21 p24 p26 p30 p33 p36
	grstyle set legend 6, nobox klength(medsmall)
	grstyle set graphsize 9cm 12cm
	grstyle set size 8pt: heading
	grstyle set size 6pt: subheading axis_title
	grstyle set size 5pt: tick_label body small_body key_label
	grstyle set size 3pt: legend_key_gap
	grstyle set size 6pt: legend_key_xsize legend_key_ysize
	grstyle set size 5pt: legend_row_gap
	grstyle set symbolsize 2, pt
	grstyle set linewidth 1pt: p1 p2 p3 p4 p5 p6 p7 p8 p9 p10 p11 p12
	grstyle set linewidth .4pt: pmark legend axisline tick major_grid xyline
	grstyle set margin "0 0 2 0": subheading
	grstyle set margin "2 3 0 3": axis_title
	grstyle set margin "0 0 0 0": graph

	replace grp = grp-0.15 if sex==1
	replace grp = grp+0.15 if sex==2

	// ADD COLORS MANUALLY
	colorpalette cblind, locals
	local ycolors `"`Orange' `Sky_Blue' `bluish_Green' `Vermillion' `reddish_Purple'"'

	twoway  (bar isced grp if sex==1 & iscedl==3 & arrcoh==0, barwidth(0.25) color(gs8) lcolor(gs8)) ///
			(bar isced grp if sex==1 & iscedl==2 & arrcoh==0, barwidth(0.25) color(gs8) lcolor(gs8)) ///
			(bar isced grp if sex==1 & iscedl==1 & arrcoh==0, barwidth(0.25) color(gs8) lcolor(gs8)) ///
			(bar isced grp if sex==2 & iscedl==3 & arrcoh==0, barwidth(0.25) color(gs8) lcolor(gs8)) ///
			(bar isced grp if sex==2 & iscedl==2 & arrcoh==0, barwidth(0.25) color(gs8) lcolor(gs8)) ///
			(bar isced grp if sex==2 & iscedl==1 & arrcoh==0, barwidth(0.25) color(gs8) lcolor(gs8)) ///
			(bar isced grp if sex==1 & iscedl==3 & arrcoh==1, barwidth(0.25) color(`Orange') lcolor(`Orange')) ///
			(bar isced grp if sex==1 & iscedl==2 & arrcoh==1, barwidth(0.25) color(`Orange') lcolor(`Orange')) ///
			(bar isced grp if sex==1 & iscedl==1 & arrcoh==1, barwidth(0.25) color(`Orange') lcolor(`Orange')) ///
			(bar isced grp if sex==2 & iscedl==3 & arrcoh==1, barwidth(0.25) color(`Orange') lcolor(`Orange')) ///
			(bar isced grp if sex==2 & iscedl==2 & arrcoh==1, barwidth(0.25) color(`Orange') lcolor(`Orange')) ///
			(bar isced grp if sex==2 & iscedl==1 & arrcoh==1, barwidth(0.25) color(`Orange') lcolor(`Orange')) ///
			(bar isced grp if sex==1 & iscedl==3 & arrcoh==2, barwidth(0.25) color(`Sky_Blue') lcolor(`Sky_Blue')) ///
			(bar isced grp if sex==1 & iscedl==2 & arrcoh==2, barwidth(0.25) color(`Sky_Blue') lcolor(`Sky_Blue')) ///
			(bar isced grp if sex==1 & iscedl==1 & arrcoh==2, barwidth(0.25) color(`Sky_Blue') lcolor(`Sky_Blue')) ///
			(bar isced grp if sex==2 & iscedl==3 & arrcoh==2, barwidth(0.25) color(`Sky_Blue') lcolor(`Sky_Blue')) ///
			(bar isced grp if sex==2 & iscedl==2 & arrcoh==2, barwidth(0.25) color(`Sky_Blue') lcolor(`Sky_Blue')) ///
			(bar isced grp if sex==2 & iscedl==1 & arrcoh==2, barwidth(0.25) color(`Sky_Blue') lcolor(`Sky_Blue')) ///
			(bar isced grp if sex==1 & iscedl==3 & arrcoh==3, barwidth(0.25) color(`bluish_Green') lcolor(`bluish_Green')) ///
			(bar isced grp if sex==1 & iscedl==2 & arrcoh==3, barwidth(0.25) color(`bluish_Green') lcolor(`bluish_Green')) ///
			(bar isced grp if sex==1 & iscedl==1 & arrcoh==3, barwidth(0.25) color(`bluish_Green') lcolor(`bluish_Green')) ///
			(bar isced grp if sex==2 & iscedl==3 & arrcoh==3, barwidth(0.25) color(`bluish_Green') lcolor(`bluish_Green')) ///
			(bar isced grp if sex==2 & iscedl==2 & arrcoh==3, barwidth(0.25) color(`bluish_Green') lcolor(`bluish_Green')) ///
			(bar isced grp if sex==2 & iscedl==1 & arrcoh==3, barwidth(0.25) color(`bluish_Green') lcolor(`bluish_Green')) ///
			(bar isced grp if sex==1 & iscedl==3 & arrcoh==4, barwidth(0.25) color(`Vermillion') lcolor(`Vermillion')) ///
			(bar isced grp if sex==1 & iscedl==2 & arrcoh==4, barwidth(0.25) color(`Vermillion') lcolor(`Vermillion')) ///
			(bar isced grp if sex==1 & iscedl==1 & arrcoh==4, barwidth(0.25) color(`Vermillion') lcolor(`Vermillion')) ///
			(bar isced grp if sex==2 & iscedl==3 & arrcoh==4, barwidth(0.25) color(`Vermillion') lcolor(`Vermillion')) ///
			(bar isced grp if sex==2 & iscedl==2 & arrcoh==4, barwidth(0.25) color(`Vermillion') lcolor(`Vermillion')) ///
			(bar isced grp if sex==2 & iscedl==1 & arrcoh==4, barwidth(0.25) color(`Vermillion') lcolor(`Vermillion')) ///
			(bar isced grp if sex==1 & iscedl==3 & arrcoh==5, barwidth(0.25) color(`reddish_Purple') lcolor(`reddish_Purple')) ///
			(bar isced grp if sex==1 & iscedl==2 & arrcoh==5, barwidth(0.25) color(`reddish_Purple') lcolor(`reddish_Purple')) ///
			(bar isced grp if sex==1 & iscedl==1 & arrcoh==5, barwidth(0.25) color(`reddish_Purple') lcolor(`reddish_Purple')) ///
			(bar isced grp if sex==2 & iscedl==3 & arrcoh==5, barwidth(0.25) color(`reddish_Purple') lcolor(`reddish_Purple')) ///
			(bar isced grp if sex==2 & iscedl==2 & arrcoh==5, barwidth(0.25) color(`reddish_Purple') lcolor(`reddish_Purple')) ///
			(bar isced grp if sex==2 & iscedl==1 & arrcoh==5, barwidth(0.25) color(`reddish_Purple') lcolor(`reddish_Purple')) ///
		,  ///
		legend(cols(7) order(- "Educational levels:" 3 "ISCED 0-2" 2 "ISCED 3-4" 1 "ISCED 5-6" - "" - "" - "" ///
			- "Cohorts:" 1 "German" 7 "1964-73 (76)" 13 "1974-83 (85)" 19 "1984-93 (95)" 25 "1994-03 (04)" 31 "2004-10 (11)")) xtitle("") ///
		ytitle(ISCED Shares) xlabel(0.85 "M" 1.15 "W" 1.85 "M" 2.15 "W" 2.85 "M" 3.15 "W" 3.85 "M" 4.15 "W" ///
		4.85 "M" 5.15 "W" 5.85 "M" 6.15 "W" 6.85 "M" 7.15 "W" 7.85 "M" 8.15 "W" ///
		8.85 "M" 9.15 "W" 9.85 "M" 10.15 "W")
	graph export "${dir_g}sum_edu${gsfx}", replace

	// grstyle reset
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

restore


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
				title("`ttl', `lbl`s''") subtitle("`sttl_`var''") ///
				xlabel(0(5)31) ///
				legend(order(- "Arr. cohort: " 1 "1964-73" 2 "1974-83" 3 "1984-93" ///
				4 "1994-03" 5 "2004-10") cols(6) stack span)) ///
				(line `var' timeres if arrcoh==2 & sex==`s') ///
				(line `var' timeres if arrcoh==3 & sex==`s') ///
				(line `var' timeres if arrcoh==4 & sex==`s') ///
				(line `var' timeres if arrcoh==5 & sex==`s')
			graph export "${dir_g}`var'_timeres_`fname`s''${gsfx}", replace
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
foreach var in empl_dummy {

	local ttl : variable label `var'

	preserve
		// collapse
		collapse (mean) `var' (count) n`var' = `var' ///
			if asample==1 & timeres>0 & !missing(timeres) ///
			[pw=hhpw_pop], by(arrcoh timeres sex isced)
		// n employed
		gen nemp = n`var' * `var'
		grstyle set color cblind, select(3 4 5 8 9): p1 p2 p3 p4 p5
		grstyle set color cblind, select(3 4 5 8 9): p6 p7 p8 p9 p10
		grstyle set lpattern shortdash: p6 p7 p8 p9 p10
		grstyle set color cblind, select(3 4 5 8 9): p11 p12 p13 p14 p15
		grstyle set lpattern dash_dot: p11 p12 p13 p14 p15
		// apply restrictions
		// apply restrictions
		replace emp = . ///
			if arrcoh==1 & timeres<12 ///
			 | arrcoh==2 & timeres<2 ///
			 | arrcoh==3 & timeres>22 ///
			 | arrcoh==4 & timeres>12 ///
			 | arrcoh==5 & timeres>5 // sensible combinations
		replace nemp = . ///
			if arrcoh==1 & timeres<12 ///
			 | arrcoh==2 & timeres<2 ///
			 | arrcoh==3 & timeres>22 ///
			 | arrcoh==4 & timeres>12 ///
			 | arrcoh==5 & timeres>5 // sensible combinations
		replace timeres = . if timeres>30 // 30 years max
		replace emp = . if n`var'<`nmin' // cell counts too low
		replace nemp = . if n`var'<`nmin' // cell counts too low
		forvalues s=1/2 {
			// n
			twoway ///
				(line nemp timeres if arrcoh==1 & sex==`s' & isced==1, ///
				ytitle("`ttl'") ///
				title("`ttl', `lbl`s''") subtitle("N employed") ///
				xlabel(0(5)31) ///
				legend(order(- "ISCED 0-2: " 1 "1964-73" 2 "1974-83" 3 "1984-93" ///
				4 "1994-03" 5 "2004-10" - "ISCED 3-4:" 6 "1964-73" 7 "1974-83" ///
				8 "1984-93" 9 "1994-03" 10 "2004-10" - "ISCED 5-6:" 11 "1964-73" ///
				12 "1974-83" 13 "1984-93" 14 "1994-03" 15 "2004-10") ///
				cols(6) stack span)) ///
				(line nemp timeres if arrcoh==2 & sex==`s' & isced==1) ///
				(line nemp timeres if arrcoh==3 & sex==`s' & isced==1) ///
				(line nemp timeres if arrcoh==4 & sex==`s' & isced==1) ///
				(line nemp timeres if arrcoh==5 & sex==`s' & isced==1) ///
				(line nemp timeres if arrcoh==1 & sex==`s' & isced==2) ///
				(line nemp timeres if arrcoh==2 & sex==`s' & isced==2) ///
				(line nemp timeres if arrcoh==3 & sex==`s' & isced==2) ///
				(line nemp timeres if arrcoh==4 & sex==`s' & isced==2) ///
				(line nemp timeres if arrcoh==5 & sex==`s' & isced==2) ///
				(line nemp timeres if arrcoh==1 & sex==`s' & isced==3) ///
				(line nemp timeres if arrcoh==2 & sex==`s' & isced==3) ///
				(line nemp timeres if arrcoh==3 & sex==`s' & isced==3) ///
				(line nemp timeres if arrcoh==4 & sex==`s' & isced==3) ///
				(line nemp timeres if arrcoh==5 & sex==`s' & isced==3)
			graph export "${dir_g}`var'_timeres_edu_n_`fname`s''${gsfx}", replace
			//
			twoway ///
				(line emp timeres if arrcoh==1 & sex==`s' & isced==1, ///
				ytitle("`ttl'") ///
				title("`ttl', `lbl`s''") subtitle("Means") ///
				xlabel(0(5)31) ///
				legend(order(- "ISCED 0-2: " 1 "1964-73" 2 "1974-83" 3 "1984-93" ///
				4 "1994-03" 5 "2004-10" - "ISCED 3-4:" 6 "1964-73" 7 "1974-83" ///
				8 "1984-93" 9 "1994-03" 10 "2004-10" - "ISCED 5-6:" 11 "1964-73" ///
				12 "1974-83" 13 "1984-93" 14 "1994-03" 15 "2004-10") ///
				cols(6) stack span)) ///
				(line emp timeres if arrcoh==2 & sex==`s' & isced==1) ///
				(line emp timeres if arrcoh==3 & sex==`s' & isced==1) ///
				(line emp timeres if arrcoh==4 & sex==`s' & isced==1) ///
				(line emp timeres if arrcoh==5 & sex==`s' & isced==1) ///
				(line emp timeres if arrcoh==1 & sex==`s' & isced==2) ///
				(line emp timeres if arrcoh==2 & sex==`s' & isced==2) ///
				(line emp timeres if arrcoh==3 & sex==`s' & isced==2) ///
				(line emp timeres if arrcoh==4 & sex==`s' & isced==2) ///
				(line emp timeres if arrcoh==5 & sex==`s' & isced==2) ///
				(line emp timeres if arrcoh==1 & sex==`s' & isced==3) ///
				(line emp timeres if arrcoh==2 & sex==`s' & isced==3) ///
				(line emp timeres if arrcoh==3 & sex==`s' & isced==3) ///
				(line emp timeres if arrcoh==4 & sex==`s' & isced==3) ///
				(line emp timeres if arrcoh==5 & sex==`s' & isced==3)
			graph export "${dir_g}`var'_timeres_edu_`fname`s''${gsfx}", replace
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

local sttl_empl_dummy 	Percent
local sttl_ahours 		Means
local sttl_isei88 		Means
local sttl_isei88_res 	Means
local sttl_isced 		Means

foreach var in empl_dummy ahours isei88_res {

	local ttl : variable label `var'
	preserve
		lab def arrcoh 0 "Germans", modify
		// collapse
		collapse (mean) `var' (count) n`var' = `var' ///
			[pw=hhpw], by(arrcoh year sex)
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
		//sum `var', d
		// plots and tables
		forvalues s=1/2 {
			// plot
			twoway ///
				(line `var' year if arrcoh==1 & sex==`s', ///
				ytitle("`ttl'") ylabel(`ylbl_`var'') ///
				title("`ttl', `lbl`s''") subtitle("`sttl_`var''") ///
				xlabel(1976(5)2016) ///
				legend(order(- "Arr. cohort: " 1 "1964-73" 2 "1974-83" 3 "1984-93" ///
				4 "1994-03" 5 "2004-10" 6 "German") cols(7) stack span)) ///
				(line `var' year if arrcoh==2 & sex==`s') ///
				(line `var' year if arrcoh==3 & sex==`s') ///
				(line `var' year if arrcoh==4 & sex==`s') ///
				(line `var' year if arrcoh==5 & sex==`s') /*
				german natives as grey reference
			*/	(line `var' year if arrcoh==0 & sex==`s', lcolor(gs10) lpattern(dash))
			graph export "${dir_g}`var'_period_`fname`s''${gsfx}", replace
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
	keep if empl_dummy==1
	// collapse
	collapse (mean) emplst1 emplst2 emplst3 ///
		(count) nemplst1=emplst1 nemplst2=emplst2 nemplst3=emplst3 ///
		if asample==1 & ((timeres>0 & !missing(timeres)) | (missing(timeres) & arrcoh==0))  ///
		[pw=hhpw], by(arrcoh year sex)
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
	// plot
	forvalues s=1/2 {
		forvalues e=1/3 {
			local ttl "`ttl`e'' employment"
			local var emplst`e'
			twoway ///
				(line `var' year if arrcoh==1 & sex==`s', ///
				ytitle("`ttl'") ylabel(0(0.1)1) ///
				title("`ttl', `lbl`s''") subtitle("Percent") ///
				xlabel(1976(5)2016) /*
				note("Shares correspond to individuals in employment.", span) ///
				*/ legend(order(- "Arr. cohort: " 1 "1964-73" 2 "1974-83" 3 "1984-93" ///
				4 "1994-03" 5 "2004-10" 6 "German") cols(7) stack span)) ///
				(line `var' year if arrcoh==2 & sex==`s') ///
				(line `var' year if arrcoh==3 & sex==`s') ///
				(line `var' year if arrcoh==4 & sex==`s') ////
				(line `var' year if arrcoh==5 & sex==`s') /*
				german natives as grey reference
			*/	(line `var' year if arrcoh==0 & sex==`s', lcolor(gs10) lpattern(dash))
			graph export "${dir_g}`var'_period_`fname`s''${gsfx}", replace
		}
	}
restore

// clear
clear
