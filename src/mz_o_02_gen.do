////////////////////////////////////////////////////////////////////////////////
//
//		Immigration and Labor Market Integration in Germany: A Long View
//
//		2 -- Generate Analysis Dataset
//
//		Maximilian Sprengholz
//		maximilian.sprengholz@hu-berlin.de
//
////////////////////////////////////////////////////////////////////////////////


//---------------------------//
//	  SETTINGS/PARAMETERS	 //
//---------------------------//

// set waves
local years ///
	1976 1978 1980 1982 1985 1987 1989 1991 1993

forvalues y=1995/2015 {
	local years "`years' `y'"
}
// no of waves
local yno : word count `years'
// first year
local yfirst : word 1 of `years'
// most recent year
local yrec : word `yno' of `years'
// cache indicator for matrices (load correspondence matrix only once)
local ckldb88 = 0
local ckldb10 = 0
local cisco88 = 0
// year counter
local ycnt = 0
// observation counter (used for generating random ids)
local obs 0
// country label helpers
capture erase "${dir_src}mz_o_99_cship_lbls.do" // erase labels to avoid dublettes
local ccnt 1000 // country counter starting at 1000 to avoid overwriting
local ulbls "" // string macro for labels for uniquely identifiable countries


//---------------------------//
//		 FULL GEN LOOP		 //
//---------------------------//

foreach y in `years' {

	dis "" ///
	_newline as result _dup(80) "-" ///
	_newline "Processing year:" _col(20) "`y'" ///
	_newline "Waves processed:" _col(20) "`ycnt'" ///
	_newline ""

	local ++ycnt // run counter

	quietly {

		//---------------------------//
		//   CORRESPONDENCE TABLES	 //
		//---------------------------//

		/*
		 This code loades the correspondence tables to convert KldB codes into
		 ISEI-88 scores. The tables have been priorly generated.
		*/

		// KldB88 -> KldB92 (KldB92 basis for translation into ISCO (and ISEI, eventually))
		if `y'<1993 & `ckldb88' == 0 {
			use "${dir_data}temp/kldb88_kldb92.dta", clear
			mkmat kldb1988 kldb1992, matrix(ct_kldb)
			local ckldb88 = 1
		}
		// KldB10 -> KldB92 (KldB92 basis for translation into ISCO (and ISEI, eventually))
		// STATE CORRESPONDENCE TABLE VERSION (v2 is the most elaborate)
		local vct v2
		if `y'>2012 & `ckldb10' == 0 {
			// for each group (east, sex, ger cit.; are always the same for v0 & v1!)
			if "`vct'"=="v2" {
				forvalues i=1/8 {
					use "${dir_data}temp/kldb10_kldb92_`vct'_`i'.dta", clear
					mkmat kldb2010 kldb1992 pkldb92, matrix(ct_kldb_`i')
				}
			}
			else {
				use "${dir_data}temp/kldb10_kldb92_`vct'_1.dta", clear
				mkmat kldb2010 kldb1992 pkldb92, matrix(ct_kldb_1)
			}
			local ckldb10 = 1
		}
		// KldB92 -> ISCO88 (v1!)
		if `cisco88' == 0 {
			use "${dir_data}temp/kldb92_isco88com_v1.dta", clear
			mkmat kldb1992 isco88com c1 valc1 valc2 pisco88, matrix(ct_isco)
			local cisco88 = 1
		}
		// report
		noisily dis "-> Correspondence tables set"


		//---------------------------//
		// MZ TRANSLATION OVER YEARS //
		//---------------------------//

		/*
		 Structure:
		 - tuple (varname prior to change, last year before change) (tuple) ...
		 - local name: later var name
		*/

		//
		// Variables consistently available
		//

		// federal states
		local state ///
			EF1 `yrec'
		// household random id
		local hhrid ///
			EF203 1982 EF4 1987 o303 1989 o402 1991 EF2 1995 EF4 `yrec'
		// family in household random id
		local famrid ///
			EF10 1978 EF205 1982 EF6 1995 EF28 2004 EF25 `yrec'
		// person in household random id
		local prid ///
			EF16 1982 EF5 1995 EF5u1 1996 EF5 2005 EF5a 2006 EF5 2007 EF5a `yrec'
		// Gemeindegrößenklasse
		local gemgk ///
			EF6 1982 EF8 1995 EF708 2004 EF563 `yrec'
		// private household
		local priv ///
			EF60 1982 EF27 1995 EF506 2004 EF31 `yrec'
		// main residence
		local res ///
			EF58 1982 EF26 1995 EF505 2004 EF30 `yrec'
		// age
		local age ///
			EF66 1982 EF23 1995 EF30 2004 EF44 `yrec'
		// sex
		local sex ///
			EF18 1982 EF35 1995 EF32 2004 EF46 `yrec'
		// immigration year
		local yimmi ///
			EF3 1978 EF3U1 1980 EF7 1982 EF47 1995 EF53 2004 EF367 `yrec'
		// citizenship
		local cship ///
			EF17 1982 EF41 1995 EF44 2004 EF369 `yrec'
		// employment status
		local emp ///
			EF65 1982 EF34 1995 EF504 2004 EF29 `yrec'
		// working hours (usual)
		local uhours ///
			EF43 1982 EF97 1995 EF141 2004 EF131 `yrec'
		// working hours (actual)
		local ahours ///
			EF44 1982 EF99 1995 EF143 2004 EF134 `yrec'
		// KldB
		local kldb ///
			EF42 1982 EF93 1995 EF128 2004 EF119 2012 EF114 `yrec'
		// stellung im beruf (employment type)
		local stib ///
			EF39 1982 EF94 1995 EF127 2004 EF117 `yrec'
		// main subsistence type
		local subsis ///
			EF48 1982 EF139 1995 EF338u2 1996 EF338 2004 EF401 `yrec'
		// eductional degree
		local edus_d ///
			EF78 1976 EF49 1978 EF158 1980 EF78 1982 EF121 1995 EF287 2002 ///
			EF259 2004 EF310 `yrec'
		// vocational degree
		local eduv_d ///
			EF79 1976 EF50 1978 EF160 1980 EF79 1982 EF122 1995 EF290 1998 ///
			EF289 2002 EF261 2004 EF312 `yrec'
		// position in household
		local poshh ///
			EF23 1982 EF33 1995 EF507 2004 EF661 `yrec'
		// position in family
		local posfam ///
			EF62 1982 EF30 1995 EF509 2004 EF34 `yrec'
		// marital status
		local marstat ///
			EF21 1982 EF38 1995 EF35 2004 EF49 `yrec'

		//
		// Irregular variables
		//

		// drawn district random id
		if `y'<=1987 {
			local drid ///
				EF5 1982 EF3 1987
		}
		if `y'>=1996 {
			local drid ///
				EF3 `yrec'
		}
		// Person from prior wave
		if `y'==2006 {
			local uehang ///
				EF5b 2006
		}
		if `y'>=2008 {
			local uehang ///
				EF5b `yrec'
		}
		// Quadriennal sample
		if `y'>=2005 {
			local quart ///
				EF12 `yrec'
		}
		// Gebäudedegrößenklasse
		if `y'>=1996 {
			local gebgk ///
				EF712 2004 EF570 `yrec'
		}
		// Weights (household level, also available on person level prior to 2005)
		/*
		 *  Weights provided by the MZ differ in their range (normalized to different
		 *  numbers of persons) and adjustment to the 70% sample of the SUF over years.
		 *	See weighting adjustments in the GEN section.
		*/
		if `y'<=1982 {
			local wdup ///
				EF38 1982
		}
	 	if `y'<=1987 {
			local wadj ///
				EF76 1978 EF4 1980 EF76 1982 EF252 1987
		}
	 	if inlist(`y',1985,1987) {
			local wdupid ///
				EF255 1987
		}
		if `y'>=1989 {
			local hhpw ///
				EF257u4 1989 EF254 1995 EF751 2004 EF952 `yrec'
		}
		if `y'>=1996 & `y'<=2004 {
			local ppw_sub ///
				EF755 2004
		}
		// company size (unavailable prior to 1996)
		if `y'>=1996 {
			local compsize ///
				EF131 2004 EF122 `yrec'
		}
		// educational degree screener
		if `y'>=1991 {
			local edus_screener ///
				EF59 1995 EF286 2002 EF258 2004 EF309 2015
		}
		// vocational degree (dummy)
		if `y'>=1996 {
			local eduv_dummy ///
				EF289 1998 EF288 2002 EF260 2004 EF311 `yrec'
		}
		// Isced 2011
		if `y'>=2014 {
			local isced2011 ///
				EF540 `yrec'
		}
		// family typology (partly available also prior to 2005)
		if `y'>=2005 {
			// partner in hh, partnership type
			local reltypehh ///
				EF33 `yrec'
			// family type (traditonal)
			local famtype_trad ///
				EF865 `yrec'
			// familiy type (enhanced)
			local famtype ///
				EF763 `yrec'
			// non-marital partnerships in hh
			local nonmarital ///
				EF811 `yrec'
		}
		// ethnic minority background
		if `y'>=2005 {
			// born in germany
			local gerborn ///
				EF366 `yrec'
			// country of birth PROXIED BY PRIOR CITIZENSHIP!
			local cship_nat ///
				EF372 `yrec'
			local cship_prenat ///
				EF374 `yrec'
		}
		if `y'==2005 | `y'==2009 | `y'==2013 {
			/*
			 *	Construct 2nd gen minority status from these vars:
			 *	Necessary for 2005, 2009 as comparison to the provided country
			 *	of origin by the MZ would be great, but merged categories make
			 *	this impossible.
			 */
			// parents arrival year
			local yimmi_f ///
				EF356 2005
			local yimmi_m ///
				EF351 2005
			// parents citizenship
			local cship_f ///
				EF361 2005
			local cship_m ///
				EF353 2005
			// parents citizenship before naturalization
			local cship_f_prenat ///
				EF363 2005
			local cship_m_prenat ///
				EF382 2005
		}
		if `y'>=2009 {
			// country of origin
			local corigin ///
				EF2007 `yrec'
			local corigin_enh ///
				EF2008 `yrec'
			local corigin_for ///
				EF2006 `yrec'
			local migback ///
				EF2009 `yrec'
		}
		// german citizenship (no distinction between German citizenship only or additional citizenship prior to 1996)
		if `y'>=1996 {
			local gerc ///
				EF43 2004 EF368 `yrec'
		}
		// return migration
		if `y'>=2011 {
			local remig ///
				EF384 `yrec'
		}
		// household net income (available for every year, but only used since 2005)
		if `y'>=2005 {
			local hhinc ///
				EF707 `yrec'
		}

		// set irregularly available vars
		local irregvars ///
			compsize edus_screener eduv_dummy isced_2011 ///
			reltypehh famtype famtype_trad nonmarital ///
			gerc gerborn cship_nat cship_prenat yimmi_f yimmi_m ///
			corigin corigin_enh corigin_for migback remig ///
			cship_f cship_m cship_f_prenat cship_m_prenat hhinc ///
			hhpw ppw_sub wdup wadj quart uehang isced2011 wdupid gebgk

		// set regular vars (available in all years)
		local vars ///
			age sex res priv yimmi cship emp uhours ahours state kldb stib ///
			subsis edus_d eduv_d nhh marstat drid hhrid famrid prid poshh ///
			posfam gemgk `irregvars'

		// 	save varnames in macro to keep only this part of datasets
		local uselist // empty macro
		foreach var in `vars'	{
			local trigger=0
			local l : word count ``var''
			forvalues i=2(2)`l' {
				local yv : word `i' of ``var'' // year
				if `y'<=`yv' & `trigger'==0 {
					local trigger=1
					local j=`i'-1
					local v : word `j' of ``var'' // associated var
						// adjust lowercase var naming scheme in some years
					if inlist(	`y', 1976, 1982, 1989, 1991, 1993, 1995, 1996, ///
								1997, 1998, 1999, 2000, 2001, 2002, 2003) {
						local v = subinstr("`v'", "EF", "ef",.)
					}
					// uselist
					local uselist "`uselist' `v'"
					// privathaushalt
					if "`var'"=="priv" {
						local privv `v'
					}
					// hauptwohnsitz
					else if "`var'"=="res" {
						local resv `v'
					}
				}
			}
		}

		// read
		use "${dir_mz}mz`y'.dta" /*
			Bevölkerung in privathaushalten (priv = 1) am ort der hauptwohnung (res < 3)
			*/ if `privv' == 1 & `resv' < 3, clear

		// run isced routines
		if `y'<2014 {
			run "${dir_bin}external/mz`y'_isced_gml.do"
			rename is isced97
			local keep isced97
		}
		else {
			local keep
		}

		// keep
		keep `uselist' `keep'

		// rename
		foreach var in `vars'	{
			local trigger=0
			local l : word count ``var''
			forvalues i=2(2)`l' {
				local yv : word `i' of ``var'' // year
				if `y'<=`yv' & `trigger'==0 {
					local trigger=1
					local j=`i'-1
					local v : word `j' of ``var'' // associated var
					// adjust lowercase var naming scheme in some years
					if inlist(	`y', 1976, 1982, 1989, 1991, 1993, 1995, 1996, ///
								1997, 1998, 1999, 2000, 2001, 2002, 2003) {
						local v = subinstr("`v'", "EF", "ef",.)
					}
					rename `v' `var' // rename to local name
				}
			}
		}
		// report
		noisily dis "-> MZ variables fetched"


		//---------------------------//
		// 		  CLEAN & GEN		 //
		//---------------------------//

		//
		// Uniquely identify households / families
		//

		// HHID
		if `y'<=1987 {
				// prior to 1989 ids are stratified...
			gen double hhid_temp ///
				= (state*1000000000000) + (drid*1000000) ///
				+ hhrid
		}
		else if `y'<=1997 {
			// ... then consecutive until 1997 (although otherwise stated in the labels!)
			gen double hhid_temp ///
				= hhrid
		}
		else if `y'<=2004 {
				// ... then again stratified
			gen double hhid_temp ///
				= (state*1000000000000) + (drid*1000000) ///
				+ hhrid
		}
		else if `y'>=2008 | `y'==2006 {
			// use info on quadriennal survey and ueberhang
			replace uehang=0 if uehang<0 // Ueberhanginterview
			gen double hhid_temp ///
				= (state*1000000000000) + (drid*1000000) ///
				+ (quart*100000) + (uehang*10000) + hhrid
		}
		else if inlist(`y',2005,2007) {
			// use only info on quadriennal survey
			gen double hhid_temp ///
				= (state*1000000000000) + (drid*1000000) ///
				+ (quart*100000) + hhrid
		}
		egen hhid_temp2 = group(hhid_temp)
		gen double hhid = (`y'-1975)*10000000000 + (hhid_temp2*10000)
		drop hhid_temp*
		// FAMID
		gen double famid = hhid + famrid*1000
		// PID
		gen double pid_temp = hhid + prid
		if `y'<=1982 {
			bys pid_temp: gen wdupid=_n if inlist(wadj,0,1,3) // consecutive number for doubled cases
		}
		if `y'<=1987 {
			bys hhid (prid): gen prid_dup = _n
			replace prid = prid_dup
		}
		gen double pid = hhid + prid
		// clean up (2 Persons are doubled for 2006, otherwise unique)
		bys pid: gen n=_N
		noisily dis in red "Non-unique persons:"
		noisily drop if n>1
		drop *rid n
		// label and clean up
		lab var hhid 	"Unique household id, full period"
		lab var famid 	"Unique family id, full period"
		lab var pid 	"Unique person id, full period"
		format hhid famid pid %16.0gc

		//
		// Standard demographics
		//

		// 	year
		gen year = `y'
		lab var year "Year"

		// east/west
		if inlist(`y',2005,2006) {
			// LET'S JUST ORDER IT ALPHABETICALLY FOR 2 YEARS...
			recode state (1=8) (2=9) (3=11) (4=12) (5=4) (6=2) ///
			 	(7=6) (8=13) (9=3) (10=5) (11=7) (12=10) (13=14) ///
				(14=15) (15=1) (16=16) (.=.)
		}
		recode state (1/11 = 0) (12/16 = 1) (.=.), gen(east)
		local vallbl : value label state
		if `y'<`yrec' {
			label drop `vallbl'
		}

		// sex
		replace sex=. if sex<1 | sex>2
		lab def sex 1 "Male" 2 "Female"
		lab val sex sex

		// age
		replace age=94 if age>94 & !missing(age)
		replace age=. if age<0
		lab var age "Age"

		//
		// Migration related variables
		//

		// german citizenship
		/*
		 * No distinction between German citizenship only or additional
		 * citizenship prior to 1996.
		 */
		if `y'<=1995 {
			gen ger = cship
			replace ger = . if ger<1
			replace ger = 0 if ger!=1 & !missing(ger)
		}
		else {
			gen ger = gerc
			replace ger = . if ger<1
			replace ger = 1 if ger<3
			replace ger = 0 if ger>1 & !missing(ger)
		}
		label var ger "German citizenship"
		label def ger 0 "No" 1 "Yes, including dual citizenship"
		label val ger ger

		// born in germany
		if `y'>=2005 {
			replace gerborn = . if gerborn<1
			replace gerborn = 0 if gerborn!=1 & !missing(gerborn)
		}

		// immigration year & born in Germany
		clonevar yimmi_save = yimmi // save for edits later
		if `y'<=1995 {
			// foreigner born in Germany
			gen forgerborn = 1 if yimmi==0 & ger==0
			replace forgerborn = 0 if !inlist(yimmi,0,9,98,99) & ger==0
			// immigration year
			replace yimmi = . if inlist(yimmi,0,9,98,99)
			replace yimmi = yimmi + 1900
		}
		else if `y'<=2005 {
			// foreigner born in Germany
			gen forgerborn = 1 if yimmi==1900 & ger==0
			replace forgerborn = 0 if !inlist(yimmi,0,9999) & ger==0
			// immigration year
			replace yimmi = . if inlist(yimmi,0,1900,9999)
		}
		else {
			// immigration year
			replace yimmi = . if inlist(yimmi,-8,-7,-5,0,9999)
		}
		replace yimmi = . if yimmi<1950
		if `y'>=2011 {
			replace yimmi = remig if remig>yimmi & !missing(remig) & remig!=9999 // possible re-immigration
		}

		// time of residence
		gen timeres = `y' - yimmi
		lab var timeres "Years of residence"
		replace timeres=. if timeres<0

		// citizenship harmonization (Identification over time: Fetch info from labels (needs some cleaning afterwards))
		capture do "${dir_src}mz_o_99_cship_lbls.do"
		labellist cship
		local lbls = r(labels)
		local vals = r(values)
		local lblname = r(lblname)
		// loop over all existing labels
		local i 0
		foreach v in `vals' {
			local ++i
			local lbl : word `i' of `lbls'
			dis as result "Current label: [`v'] `lbl'"
			// check if there is any number in the label to assess combined values
			if strpos("`lbl'", "0")!=0 ///
			 | strpos("`lbl'", "1")!=0 ///
			 | strpos("`lbl'", "2")!=0 ///
			 | strpos("`lbl'", "3")!=0 ///
			 | strpos("`lbl'", "4")!=0 ///
			 | strpos("`lbl'", "5")!=0 ///
			 | strpos("`lbl'", "6")!=0 ///
			 | strpos("`lbl'", "7")!=0 ///
			 | strpos("`lbl'", "8")!=0 ///
			 | strpos("`lbl'", "9")!=0 {
				/*
				 If countries are combined into one value for anonymity reasons,
				 we cannot uniquely assign them. However, we do not want to loose the
				 information and thus assign them a new unique value. In that way, the
				 country information can be assessed even when different countries
				 have been subsumed under the same value across various MZ waves.
				*/
				local newval = (`v'+1)*1000
				dis "Merged categories. Assigning new value `newval'."
				replace cship = `newval' if cship==`v' // replace with more digits
				label def lblcship `newval' "`lbl'", add modify // transfer the label
			}
			else {
				// use string to gather all labels, check if already existent
				local match 0 // indicator if entry already exists
				// all new entries cross checked for existence
				tokenize `"`ulbls'"' // split into numbered parts
				// start new labels at 1000 to avoid overwriting
				forvalues j=1001/`ccnt' {
					local lc = `j'-1000 // tokenize begins with 1, adjust interval accordingly
					if `"`lbl'"'==`"``lc''"'  {
						// existing entries
						dis "Already existent. Assigning value `j'."
						replace cship = `j' if cship==`v'
						local match 1
						break
					}
					else if strpos(`"`lbl'"', `"``lc''"')!=0 {
						// similar entries exist, gen new entry but raise flag
						dis "Partly matched: Existing label: [`j'] ``lc''. Check manually."
					}
				}
				if `match'==0 {
					// new entry
					local ++ccnt
					local ulbls `" `ulbls' "`lbl'" "'
					dis "Assigning new value `ccnt' to `lbl'."
					replace cship = `ccnt' if cship==`v' // assign new unique value
					label def lblcship `ccnt' "`lbl'", add modify // transfer the label
				}
			}
		}
		label save lblcship using "${dir_src}mz_o_99_cship_lbls.do", replace

		// Naturalization status (since 2007 further distinction possible)
		if `y'==2007 {
			recode cship_nat (1/2=0) (3=1) (else=.), gen(cship_nat_d)
			label var cship_nat_d "Naturalized (NOT HARMONIZED)"
		}
		if `y'>=2008 {
			recode cship_nat (1 4 = 0) (2/3=1) (else=.), gen(cship_nat_d)
			label var cship_nat_d "Naturalized (NOT HARMONIZED)"
		}

		//
		// Employment
		//

		// main source of subsistence
		if `y'<=1982 {
			recode subsis (6/9=1), gen(subsis_temp)
		}
		else if `y'<=1995 {
			recode subsis (6/7=2), gen(subsis_temp)
		}
		else if `y'<=2006 {
			recode subsis (6/8=2), gen(subsis_temp)
		}
		else {
			recode subsis (6/9=2), gen(subsis_temp)
		}
		replace subsis = subsis_temp if !missing(subsis_temp)
		replace subsis = . if subsis<0
		lab var subsis "Main subsistence source"
		lab def subsis 1 "Employment" ///
			2 "Unemployment and other (also non-public) benefits" ///
			3 "Pension" 4 "Maintenance" 5 "Own wealth, rent, interest"
		lab val subsis subsis

		// employment
		if `y'<=1982 {
			recode emp (1/4 10 = 1) (5/7 = 2) (8/9 11 = 3) (else=.), gen(empl)
		}
		else if `y'>1982 & `y'<=1995 {
			recode emp (1/4 = 1) (5/7 = 2) (8/9 = 3) (else=.), gen(empl)
		}
		else {
			recode emp (1 = 1) (2 = 2) (3/4 = 3) (else=.), gen(empl)
		}
		drop emp
		lab var empl "Employment status"
		lab def empl 1 "Employed" 2 "Unemployed (available)" 3 "Non-employed"
		lab val empl empl
		recode empl (1=1) (2/3=0) (else=.), gen(empl_dummy)
		lab var empl_dummy "Employment"
		lab def empl_dummy 0 "No" 1 "Yes"
		lab val empl_dummy empl_dummy

		// labor force participation
		recode empl (1/2=1 "Yes") (3=3 "No"), gen(lfp)
		lab var lfp "Labor force particpation"

		// working hours (usual)
		replace uhours = . if uhours<1
		replace uhours = 80 if uhours>80 &  uhours<=95
		replace uhours = . if uhours>95
		lab var uhours "Weekly working hours (usual)"

		// working hours (actual, resp. week)
		replace ahours = . if ahours<1
		replace ahours = 80 if ahours>80 &  ahours<=95
		replace ahours = . if ahours>95
		lab var ahours "Weekly working hours (actual)"

		// full-time/part-time/marginal classification
		gen ahoursc=1 if ahours>=35 & !missing(ahours) // full-time
		replace ahoursc=2 if ahours<35 & ahours>=15 // part-time
		replace ahoursc=3 if ahours<15 // marginal
		lab var ahoursc "Employment type"
		lab def ahoursc 1 "Full-time" 2 "Part-time" 3 "Marginal"
		lab val ahoursc ahoursc

		// extended employment status
		gen emplst = 1 if ahoursc==1
			replace emplst = 2 if ahoursc==2
			replace emplst = 3 if ahoursc==3
			replace emplst = 4 if empl==2
			replace emplst = 5 if empl==3
		lab var emplst "Employment status, enhanced"
		lab def emplst 1 "Full-time" 2 "Part-time" 3 "Marginal" ///
			4 "Unemployed" 5 "Non-employed", modify
		lab val emplst emplst

		// self-employment
		gen selfemp = 0 if empl_dummy==1
			replace selfemp = 1 if stib==1 | stib==2
			label var selfemp "Self-employed"

		// compsize
		if `y'>=1996 {
			gen compsize_dummy = 1 if compsize>0 & compsize<11
			replace compsize_dummy = 2 if compsize>=11 & compsize<99
			lab var compsize "Company size (employees)"
			lab var compsize_dummy "Company size cat."
			lab def labcompsize_dummy 1 "<=10 employees" 2 ">10 employees"
			lab val compsize_dummy labcompsize_dummy
		}

		//
		// Education
		//

		// schooling
		// screener
		if `y'>=1991 & `y'<=1993 {
			recode edus_screener (1 = 1) (2 = 0) (else=.), gen(edus_dummy)
			drop edus_screener
		}
		else if `y'==1995 {
			recode edus_screener (1 = 1) (9 = 0) (else=.), gen(edus_dummy)
			drop edus_screener
		}
		else if `y'>=1996 {
			recode edus_screener (1 = 1) (8 = 0) (else=.), gen(edus_dummy)
			drop edus_screener
		}
		// degree
		if `y'<1991 {
			/*
			 Missing = not applicable/no degree in 1978 and 1980.
			 Bug in our SUFs? This is different in Missy.
			*/
			recode edus_d (1 = 1 "Volks-/Hauptschule") ///
				(2 = 2 "Mittlere Reife") (3 4 = 3 "(Fach-)Hochschulreife") (else = .), gen(edus)
		}
		else if `y'<1996 {
			/*
			 Not possible to distinguish nonresponse from inapplicable in 1995.
			 Many missings in 1993 (10%). Try screener to solve.
			*/
			recode edus_d (1 = 1 "Volks-/Hauptschule") ///
				(2 3 = 2 "Mittlere Reife") (4 5 = 3 "(Fach-)Hochschulreife") (else = .), gen(edus)
		}
		else if `y'<2010 {
			/*
			 Degree after a maximum of 7 years counted as no degree.
			*/
			recode edus_d (-5 6 = 0 "Kein Abschluss") (1 = 1 "Volks-/Hauptschule") ///
				(2 3 = 2 "Mittlere Reife") (4 5 = 3 "(Fach-)Hochschulreife") (else = .), gen(edus)
		}
		else if `y'<2012 {
			recode edus_d (-5 6 = 0 "Kein Abschluss") (1 2 = 1 "Volks-/Hauptschule") ///
				(3 7= 2 "Mittlere Reife") (4 5 = 3 "(Fach-)Hochschulreife") (else = .), gen(edus)
		}
		else {
			recode edus_d (-5 6 = 0 "Kein Abschluss") (1 2 = 1 "Volks-/Hauptschule") ///
				(3 7= 2 "Mittlere Reife") (4 5 = 3 "(Fach-)Hochschulreife") (else = .), gen(edus)
		}

		// vocational/university
		// screener
		if `y'>=1996 {
			replace eduv_dummy = . if !inlist(eduv_dummy, 8, 1)
			replace eduv_dummy = 0 if eduv_dummy==8
			lab def eduv_dummy 0 "No" 1 "Yes", modify
			lab val eduv_dummy eduv_dummy
		}
		// degree
		if `y'<1980 {
			recode eduv_d (1 3 = 0 "Kein Abschluss") (2 = 1 "Ausbildung/Berufsschulabschluss") ///
				(4 = 2 "Meister/Techniker") (5 6 = 3 "(Fach-)Hochschulabschluss") (else=.), gen(eduv)
		}
		else if `y'==1980 {
			recode eduv_d (9 = 0 "Kein Abschluss") (1 3 = 1 "Ausbildung/Berufsschulabschluss") ///
				(2 4 = 2 "Meister/Techniker") (5 6 = 3 "(Fach-)Hochschulabschluss") (else=.), gen(eduv)
		}
		else if `y'<1991 {
			recode eduv_d (1 3 = 0 "Kein Abschluss") (2 = 1 "Ausbildung/Berufsschulabschluss") ///
				(4 = 2 "Meister/Techniker") (5 6 = 3 "(Fach-)Hochschulabschluss") (else=.), gen(eduv)
		}
		else if `y'<1995 {
			recode eduv_d (1 3 = 0 "Kein Abschluss") (2 = 1 "Ausbildung/Berufsschulabschluss") ///
				(4 5 = 2 "Meister/Techniker") (6 7 = 3 "(Fach-)Hochschulabschluss") (else=.), gen(eduv)
		}
		else if `y'==1995 {
			// No distinction between non-response and inapplicable
			recode eduv_d (1 3 = 0 "Kein Abschluss") (2 = 1 "Ausbildung/Berufsschulabschluss") ///
				(4 5 = 2 "Meister/Techniker") (6 7 = 3 "(Fach-)Hochschulabschluss") (else=.), gen(eduv)
		}
		else if `y'<1999 {
			// since 1996 new question accompanied by general question if vocational degree completed
			recode eduv_d (1 = 0 "Kein Abschluss") (2 = 1 "Ausbildung/Berufsschulabschluss") ///
				(3 4 = 2 "Meister/Techniker") (5 6 = 3 "(Fach-)Hochschulabschluss") (else=.), gen(eduv)
		}
		else if `y'<2011 {
			recode eduv_d (1 2 -5 = 0 "Kein Abschluss") (3 4 11 = 1 "Ausbildung/Berufsschulabschluss") ///
				(5 6 = 2 "Meister/Techniker") (7 8 9 10 12 = 3 "(Fach-)Hochschulabschluss") (else=.), gen(eduv)
		}
		else {
			recode eduv_d (1 2 -5 = 0 "Kein Abschluss") (3/7 16 17 = 1 "Ausbildung/Berufsschulabschluss") ///
				(8/10= 2 "Meister/Techniker") (11/15= 3 "(Fach-)Hochschulabschluss") (else=.), gen(eduv)
		}

		// ISCED
		// Recode GML classification
		if `y'<=1982 {
			// GML definition ISCED-97
			recode isced97 (1=1) (2=3) (3=4) (4=5) (5=6) (6=7) (7=8) (8=9) (9/10=99) (9/10=99)
		}
		else if `y'<=2013 {
			label define isced97 1 "1B" /// Ohne allgemeinen Schulabschluss; ohne beruflichen Abschluss
			                2 "1A" /// Schulbesuch Klassen 1-4; Personen mit Schulbesuch, in Ausbildung
			                3 "2B" /// Hauptschulabschluss, Schulbesuch Klassen 5-10, ...
			                4 "2A" /// Realschulabschluss, kein beruflicher Abschluss ...
			                5 "3B" /// Abschluss einer Lehrausbildung ...
			                6 "3A" /// Fach-/Hochschulreife, Schulbesuch Klassen 11-13
			                7 "4A" /// Fach-/Hochschulreife und Abschluss einer Lehrausbildung ...
			                8 "5B" /// Meister-/Techniker- oder Fachschulabschluss ...
			                9 "5A" /// Fachhochschulabschluss, Hochschulabschluss ...
			                10 "6" /// Promotion
			                99 "NA", modify
			label values isced97 isced97
			numlabel isced97, add mask("[#] ") force
		}
		// Merge to 3 categories
		if `y'<=2013 {
			// GML definition ISCED-97
			recode isced97 (0/4=1) (5/7=2) (8/10=3 "5-6") (else=.), gen(isced)
		}
		else {
			// MZ definition ISCED-2011
			recode isced2011 (0/29=1) (30/49=2) (50/89=3) (else=.), gen(isced)
		}
		label variable isced "ISCED-97"
		label define isced 	1 "0-2"  /* 	1A, 1B, 2A, 2B: Ohne allgemeinen Schulabschluss; ohne beruflichen Abschluss; Schulbesuch Klassen 1-4;
													Personen mit Schulbesuch, in Ausbildung, Hauptschulabschluss, Schulbesuch Klassen 5-10,
													Realschulabschluss, kein beruflicher Abschluss ...
						*/	2 "3-4" 		/*	3A, 3B, 4A: Abschluss einer Lehrausbildung; Fach-/Hochschulreife, Schulbesuch Klassen 11-13;
													Fach-/Hochschulreife und Abschluss einer Lehrausbildung ...
						*/	3 "5-6" 		/* 	5A, 5B, 6: Fachhochschulabschluss, Hochschulabschluss; Meister-/Techniker- oder Fachschulabschluss;
													Promotion
						*/ , modify
		label values isced isced
		// Correct using own data (because of categorizing, some missings can be filled)
		/*
		 Because of the coarsened ISCED categories, we can replace some missings
		 in the data. For example, some persons state to not have a vocational
		 degree, these cannot get a specific ISCED values, but definitely belong
		 to the category 0-2
		*/
		generate isced_corr = .
		if `y'<1991 {
			replace isced_corr = 1 if !missing(edus) | eduv==0
			replace isced_corr = 2 if edus==3 | eduv==1
			replace isced_corr = 3 if eduv>=2 & !missing(eduv)
		}
		else if `y'<1996 {
			replace isced_corr = 1 if !missing(edus) | edus_dummy==1 | eduv==0
			replace isced_corr = 2 if edus==3 | eduv==1
			replace isced_corr = 3 if eduv>=2 & !missing(eduv)
		}
		else {
			replace isced_corr = 1 if !missing(edus) | edus_dummy==1 | eduv==0 | eduv_dummy==0
			replace isced_corr = 2 if edus==3 | eduv==1 | eduv_dummy==1
			replace isced_corr = 3 if eduv>=2 & !missing(eduv)
		}
		label variable isced_corr "ISCED-97, for correction, self-generated"
		label val isced_corr isced
		// Final, corrected version
		/*
		 Because the GML/Destatis ISCED scale is prospective (you get the
	 	 degree you're about to obtain), replacement is done only if value
		 replaces a missing or is greater than the GML/Destatis value.
		*/
		replace isced = isced_corr ///
			if missing(isced) | (isced_corr>isced & !missing(isced_corr))

		//
		// Household
		//

		/*
		 * IMPORTANT:
		 * The family definition is different from the household definition.
		 */

		// position in the household
		replace poshh = . if poshh<=0
		recode poshh (1 = 1 "Household head") (2 = 2 "Spouse of household head") ///
			(3/4 = 3 "Children or grandchildren") (5/6 = 4 "Parents or grandparents") ///
			(7/8 = 5 "Other relative or non-relative"), gen(poshhc)

		// number of persons in the hh
		gen x = 1
		egen nhh = sum(x), by(hhid)
		drop x
		label var nhh "No. of persons in hh"

		// no of children in hh
		gen x = 1 if age<18 & poshhc==3
		egen nkidshh = sum(x), by(hhid)
		drop x
		label var nkidshh "No. of children in hh <18"

		// age youngest kid (categorized)
		egen ageykidhh = min(age), by(hhid)
		replace ageykidhh = . if ageykidhh>=18 & !missing(ageykidhh) // children >=18
		lab var ageykidhh "Age youngest child in household"
		recode ageykidhh (0/2=1) (3/9=2) (10/17=3), gen(ageykidhhc)
		replace ageykidhhc = 0 if nkidshh==0 // no children present
		replace ageykidhhc = 0 if ageykidhh>=18 & !missing(ageykidhh) // children >=18
		lab var ageykidhhc "Age youngest child <18, cat."
		lab def ageykidhhc 0 "None in hh." 1 "0-2" 2 "3-9" 3 "10-17"
		lab val ageykidhhc ageykidhhc

		//
		// FAMILY (some data available since 2005 only)
		//

		// marital status
		label def marstat 1 "Single" 2 "Married" 3 "Widowed" 4 "Divorced" 5 "Civil partnership" 7 "Civil partnership rescindet"
		lab val marstat marstat

		// family type (some info available since 1996)
		if `y'>=2005 {
			// family type	// Living in different family forms: at the moment, but what about having had children?
			replace reltypehh = 0 if reltypehh==-5
			replace reltypehh = . if reltypehh<0
			replace famtype = . if famtype<=0
			gen famtypec = .
				replace famtypec = 1 if inlist(famtype, 9, 2, 4, 6)  // single, no kids (this includes children of other family types!)
				replace famtypec = 2 if famtype==5 // single, kids
				replace famtypec = 3 if famtype==7 // married, no kids
				replace famtypec = 4 if famtype==1 // married, kids
				replace famtypec = 5 if famtype==8 // cohabiting, no kids
				replace famtypec = 6 if famtype==3 // cohabiting, kids
			lab var famtypec "Family type"
			lab def famtypec 1 "Single no children" 2 "Single with children" ///
				3 "Married no children" ///
				4 "Married with children" 5 "Cohabiting no children" 6 "Cohabiting with children", modify
			lab val famtypec famtypec
		}

		// position in family
		replace posfam=. if posfam<=0

		// number of children in family
		gen x = 1 if age<18 & posfam==3
		egen nkidsfam = sum(x), by(famid)
		drop x
		label var nkidsfam "No. of children in family <18"

		// number of children for parent(s); approximate as good as possible...
		clonevar nkids = nkidsfam
		if `y'<2005 {
			replace nkids = 0 if posfam==3
		}
		else {
			replace nkids = 0 if inlist(famtypec,1,3,5)
		}

		// kids dummy
		gen kids = 0 if nkids==0
		replace kids = 1 if nkids>0 & !missing(nkids)
		lab var kids "Has children"
		lab def kids 0 "No children" 1 "Children"
		lab val kids kids

		// age of youngest child for parent(s)
		egen ageykid = min(age), by(famid)
		replace ageykid = . if ageykid>=18 & !missing(ageykid) // children >=18
		lab var ageykid "Age youngest child"
		recode ageykid (0/2=1) (3/9=2) (10/17=3), gen(ageykidc)
		replace ageykidc = 0 if nkids==0 // no children present
		replace ageykidc = 0 if ageykid>=18 & !missing(ageykid) // children >=18
		lab var ageykidc "Age youngest child, cat."
		lab def ageykidc 0 "None in hh." 1 "0-2" 2 "3-9" 3 "10-17" 4 "18+"
		lab val ageykidc ageykidc
		if `y'>=2005 {
			// household income (midpoint of interval)
			qui recode hhinc ///
				(1 = 75) (2 = 225) (3 = 400) (4 = 600) (5 = 800) (6 = 1000) (7 = 1200) ///
				(8 = 1400) (9 = 1600) (10 = 1850) (11 = 2150) (12 = 2450) (13 = 2750) ///
				(14 = 3150) (15 = 3400) (16 = 3800) (17 = 4250) (18 = 4750) (19 = 520) ///
				(20 = 5750) (21 = 6750) (22 = 8750) (23 = 14000) (24 = 20000) (else = .) ///
				, gen(hhinc_imp)
			lab var hhinc_imp "Monthly net household income, int. midpoints"
		}

		//
		// WEIGHTS
		//

		/*
		 * (PER 100 persons, correspondence to 70% of 1% sample)
		 * Needs to be consistent for pooled estimations. Otherwise only
		 * frequencies affected. Accounting for the 70% sample of the SUF:
		 * Multiply by 1/0.7.
		 *
		 *  Weight usage over years:
		 *
		 *	<1989: 	Random doubling/crossing-Out of person/household observations
		 *			serve as weights.
		 *
		 *	<2005:	Person and household weights.
		 *
		 *	2005:	Provided for 1.000 persons ONLY on household level,
		 *			not adjusted to SUF sample. Multiply by 10.
		 *
		 *	>2005:	Provided for 1.000, already adjusted to SUF sample.
		 *			Multiply by (10*0.7)
		 */

		if `y'<=1982 {
			if inlist(`y', 1978, 1980) {
				replace wdup = 0 if missing(wdup)
				replace wadj = 0 if missing(wadj)
			}
			gen ppw = ( (wdup==0 | wdup==1) & /// duplicate no / yes
						(wadj==0 | wadj==1 | wadj==3) )  // adjustment: doubling/omitting: 0 does not apply; 1, 3 doubled
			egen hhpw = mean(ppw), by(hhid)
			lab var ppw "Probability weight, person level"
		}
		if `y'>=1985 & `y'<=1987  {
			gen ppw = ( (wadj==0 | wadj==1 | wadj==3) )  // adjustment: doubling/omitting: 0 does not apply; 1, 3 doubled
			egen hhpw = mean(ppw), by(hhid)
			lab var ppw "Probability weight, person level"
		}
		if `y'>=1989 & `y'<=2004 {
			// standard weight (no person level weightsa vailable!)
			gen ppw = hhpw
			drop hhpw
			egen hhpw = mean(ppw), by(hhid)
			lab var ppw "Probability weight, person level"
		}
		if `y'>=1996 & `y'<=2004 {
			// subsample weight (Unterstichprobe)
			egen hhpw_sub = mean(ppw_sub), by(hhid)
			lab var hhpw_sub "Probability weight, household level, subsample"
		}
		if `y'==2005 {
			replace hhpw = hhpw * 10
		}
		if `y'==2006 {
			replace hhpw = hhpw * 10 * 0.7
		}
		if `y'==2007 {
			replace hhpw = hhpw * 1/100000 * 0.7 // bug in our datasets?!
		}
		if `y'>=2008 {
			replace hhpw = hhpw * 10 * 0.7
		}
		lab var hhpw "Probability weight, household level"	// to have a consistent weight for all years

		// report
		noisily dis "-> Variables recoded"


		//---------------------------//
		// 	 	 KLdB --> ISCO		 //
		//---------------------------//

		//
		// kldb --> kldb92
		//

		gen kldb92 = .
		if `y'<1993 {
			local r_ct = rowsof(ct_kldb) // loop through rows of correspondence matrix
			forvalues r=1/`r_ct' {
				if ct_kldb[`r',1]!=. & ct_kldb[`r',2]!=. {
					replace kldb92 = ct_kldb[`r',2] if kldb==ct_kldb[`r',1]
				}
				else {
					replace kldb92 = kldb if kldb==ct_kldb[`r',2] & `y'<1993
				}
			}
		}
		else if `y'>2012 {
			if "`vct'"=="v2" {
				// run for each group: (e) east, (i) sex, (j) german citizenship
				set seed 1234
				bys kldb east sex ger: gen puni=runiform() // prob. tested against correspondence prob. of single kldb92 codes
				local c = 0 // counter
				local lo = 0 // lower p bound
				local hi = 0 // upper p bound
				forvalues e=0/1 {
					forvalues i=1/2 {
						forvalues j=0/1 {
							local ++c
							// loop over rows of correspondence matrix
							local r_ct = rowsof(ct_kldb_`c')
							forvalues r=1/`r_ct' {
								local t = `r'-1
								if ct_kldb_`c'[`r',1]!=ct_kldb_`c'[`t',1] {
									// reset p interval if kldb2010 changes between rows
									local lo = 0 // lower p bound
									local hi = ct_kldb_`c'[`r',3] // upper p bound
								}
								else {
									// change interval bounds acc. to rel. prob. in matrix
									local lo = `hi'
									local hi = `hi' + ct_kldb_`c'[`r',3]
								}
								if `lo'==0 | `lo'==1  {
									local eq "=" // greater or equal if lower bound = 0/1
								}
								else {
									local eq
								}
								if ct_kldb_`c'[`r',1]!=. & ct_kldb_`c'[`r',2]!=. & ct_kldb_`c'[`r',3]!=. {
									// set corresponding kldb92 code
									dis 					_dup(65) "-" ///
										_newline as result  "Assigning:" _col(20) "KldB2010" _col(35) "KldB1992" _col(50) "P-Interval" ///
										_newline 			_col(20) ct_kldb_`c'[`r',1] _col(35) ct_kldb_`c'[`r',2] _col(50) "[" %-5.3f `lo' ";" %-5.3f `hi' "]" ///
										_newline as text	_dup(65) "-"
									replace kldb92 = ct_kldb_`c'[`r',2] if kldb==ct_kldb_`c'[`r',1] ///
										& puni>`eq'`lo' & puni<=`hi' & east==`e' & sex==`i' & ger==`j'
								}
							}
						}
					}
				}
			}
			else {
				// run once (no difference in rel. conversion probabilities between groups for v0 and v1)
				set seed 1234
				gen puni=runiform() // prob. tested against correspondence prob. of single kldb92 codes
				local c = 1 // counter
				local lo = 0 // lower p bound
				local hi = 0 // upper p bound
				// loop over rows of correspondence matrix
				local r_ct = rowsof(ct_kldb_`c')
				forvalues r=1/`r_ct' {
					local t = `r'-1
					if ct_kldb_`c'[`r',1]!=ct_kldb_`c'[`t',1] {
						// reset p interval if kldb2010 changes between rows
						local lo = 0 // lower p bound
						local hi = ct_kldb_`c'[`r',3] // upper p bound
					}
					else {
						// change interval bounds acc. to rel. prob. in matrix
						local lo = `hi'
						local hi = `hi' + ct_kldb_`c'[`r',3]
					}
					if `lo'==0 | `lo'==1  {
						local eq "=" // greater or equal if lower bound = 0/1
					}
					else {
						local eq
					}
					if ct_kldb_`c'[`r',1]!=. & ct_kldb_`c'[`r',2]!=. & ct_kldb_`c'[`r',3]!=. {
						// set corresponding kldb92 code
						dis 					_dup(65) "-" ///
							_newline as result  "Assigning:" _col(20) "KldB2010" _col(35) "KldB1992" _col(50) "P-Interval" ///
							_newline 			_col(20) ct_kldb_`c'[`r',1] _col(35) ct_kldb_`c'[`r',2] _col(50) "[" %-5.3f `lo' ";" %-5.3f `hi' "]" ///
							_newline as text	_dup(65) "-"
						replace kldb92 = ct_kldb_`c'[`r',2] if kldb==ct_kldb_`c'[`r',1] ///
							& puni>`eq'`lo' & puni<=`hi'
					}
				}
			}
		}
		else {
			replace kldb92 = kldb
			destring kldb92, replace
		}
		label var kldb92 "KldB-1992"

		//
		// kldb92 --> isco88-com
		//

		gen isco88 = .
		set seed 1234
		cap drop puni
		gen puni = runiform() // prob. tested against correspondence prob. of single isco88 codes
		local lo = 0 // lower p bound
		local hi = 0 // upper p bound
		local r_ct = rowsof(ct_isco) // loop through rows of correspondence matrix
		forvalues r=1/`r_ct' {
			local t = `r'-1
			if (ct_isco[`r',1]!=ct_isco[`t',1]) | (ct_isco[`r',1]==ct_isco[`t',1] & ct_isco[`r',4]!=ct_isco[`t',4]) {
				// reset p interval if kldb2010 changes between rows
				// OR condition within one kldb2010 code !!!
				local lo = 0 // lower p bound
				local hi = ct_isco[`r',6] // upper p bound
			}
			else {
				// change interval bounds acc. to rel. prob. in matrix
				local lo = `hi'
				local hi = `hi' + ct_isco[`r',6]
			}
			if `lo'==0 | `lo'==1  {
				local eq "=" // greater or equal if lower bound = 0/1
			}
			else {
				local eq
			}
			// conditions (prior employment translation possible w mat, but not done)
			dis 					_dup(65) "-" ///
				_newline as result  "Assigning:" _col(20) "KldB1992" _col(35) "ISCO-88" _col(50) "P-Interval" ///
				_newline			_col(20) ct_isco[`r',1] _col(35) ct_isco[`r',2] _col(50) "[" %-5.3f `lo' ";" %-5.3f `hi' "]"
			if ct_isco[`r',3]==. & ct_isco[`r',2]!=. {
				// set corresponding isco88com code
				dis _dup(65) "-"
				replace isco88 = ct_isco[`r',2] if kldb92==ct_isco[`r',1] ///
					& puni>`eq'`lo' & puni<=`hi'
			}
			else if ct_isco[`r',3]==1 {
					// company size only available since 1996; use MZ provided probabilities against p instead
					// smaller than random value = compsize<11
				dis as result			"Company size:" _col(20) ct_isco[`r',4] ///
					_newline as text	_dup(65) "-"
				if `y'<1996 {
					if ct_isco[`r',4]==1 {
						replace isco88 = ct_isco[`r',2] if kldb92==ct_isco[`r',1] ///
							& puni<=ct_isco[`r',5]	& !missing(puni) & puni>`eq'`lo' & puni<=`hi'
					}
					else {
						replace isco88 = ct_isco[`r',2] if kldb92==ct_isco[`r',1] ///
							& puni>ct_isco[`r',5] & !missing(puni) & puni>`eq'`lo' & puni<=`hi'
					}
				}
				else {
					replace isco88 = ct_isco[`r',2] if kldb92==ct_isco[`r',1] ///
						& compsize_dummy==ct_isco[`r',4] & puni>`eq'`lo' & puni<=`hi'
				}
			}
			else if ct_isco[`r',3]==2 {
				dis as result			"Self-employed:" _col(20) ct_isco[`r',4] ///
					_newline as text	_dup(65) "-"
				replace isco88 = ct_isco[`r',2] if kldb92==ct_isco[`r',1] ///
					& selfemp==ct_isco[`r',4] & puni>`eq'`lo' & puni<=`hi'
			}
		}
		label var isco88 "ISCO-88"
		drop puni

		//
		// isco-88 --> isei88
		//

		gen isei88 = isco88
		lab var isei88 "ISEI-88"

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

		// report
		noisily dis "-> ISEI scores translated from KldB->ISCO"

		// save
		save "${dir_mzproc}mz_o_gen_`y'", replace // save generated dataset

	}
	// end quietly
}

//	append all
drop _all
foreach y in `years' {
	append using "${dir_mzproc}mz_o_gen_`y'.dta"
}

//
//	End of pipe stuff: citizenship labels
//

/*
 This can probably also be regex-ed and put into
 a program requiring user input using "_request(macro name)". However,
 the matching would require to cross check everything with a given country
 name list. For now done by hand.
*/

label val cship lblcship // assign merged citizenship labels
// clean: unique, but differently labeled countries
recode cship /*
	Missings (due to different reasons)
*/	(1130/1132 = .) /*
	Without citizenship / Other
*/	(1010 1011 1014 1018 1023 1039 1065 1077 1083 1093 56000 99000 998000 = 9999) /*
	German (single or dual citizenship)
*/	(1019 1024 1036 1066 1084 1085 1099 1108 = 1001) /*
	(former) Yugoslavia
*/	(1037 1052 1089 = 1004) /*
	Serbia and Montenegro
*/	(1089 59000 171000 = 1070) /*
	Bosnia-Herzegovina
*/	(1067 = 1100) /*
	Austria
*/	(1006 = 1012) /*
	Turkey
*/	(1008 = 1013) /*
	USA
*/	(1017 1022 1026 1038 1054= 1009) /*
	GB/UK
*/	(1025 1021 = 1103) /*
	Romania
*/	(1045 = 1087)
lab def lblcship ///
	9999 "Other" 1009 "USA", modify
numlabel lblcship, add mask("[#] ")

//	save
save "${dir_mzproc}mz_o_gen_`yfirst'_`yrec'.dta", replace
clear
