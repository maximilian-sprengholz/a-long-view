////////////////////////////////////////////////////////////////////////////////
//
//		Immigration and Labor Market Integration in Germany: A Long View
//
//		4 -- Process register data on foreigner inflows
//
//		Maximilian Sprengholz
//		maximilian.sprengholz@hu-berlin.de
//
////////////////////////////////////////////////////////////////////////////////

/*
 Data from Destatis Fachserie 1, Reihe 1.2 (Bevölkerung und Erwerbstätigkeit: Wanderungen)
 https://www.statistischebibliothek.de/mir/receive/DEHeft_mods_00128336
*/

//-------------//
//    FETCH    //
//-------------//

// Do for women and men
local sheet11 "Zuzug - M."
local sheet12 "Zuzug - W."
local sheet21 "Zuzüge männl."
local sheet22 "Zuzüge weibl."
local fname1 m
local fname2 f
local lbl1 Men
local lbl2 Women

forvalues s=1/2 {

    //
    // 1952-1990
    //

    // Excel import
    clear
    import excel ///
        using "${dir_data}raw/A_Herkunft-Ziel - Pers insgesamt 1952-1990.xls", ///
        sheet("`sheet1`s''") cellrange(A13:AO142)

    // Clean
    local chars ///
        C D E F G H I J K L M N O P Q R S T U V W X Y Z ///
        AA AB AC AD AE AF AG AH AI AJ AK AL AM AN AO

    local y 1952 // series starts in 1952
    qui foreach char in `chars' {
        rename `char' y`y'
        replace y`y'=. if y`y'==0 // 0 only possible if missing
        local ++y
    }

    drop B
    rename A country

    // drop aggregates
    drop if inlist(country,"","Afrika","Amerika","Asien","Australien und Ozeanien")

    // drop completely missing rows
    egen rnm = rownonmiss(y1952-y1990)
    drop if rnm == 0
    drop rnm

    // Totals for Vietnam
    qui forvalues y=1952/1975 {
        cap drop total
        egen total = total(y`y') ///
            if inlist(country, "Vietnam", "Vietnam, Demokratische Republik", "Vietnam, Süd-")
        replace y`y'=total if country=="Vietnam"
    }
    drop total
    drop if inlist(country, "Vietnam, Demokratische Republik", "Vietnam, Süd-")

    // add continent indicator
    gen continent = .
    replace continent=5 if _n<=111
    replace continent=4 if _n<=108
    replace continent=3 if _n<=82
    replace continent=2 if _n<=58
    replace continent=1 if _n<=27
    lab def continent 1 "Europe" 2 "Africa" 3 "America" 4 "Asia" 5 "Australia and Oceania"
    lab val continent continent

    // prepare merge
    replace country = "Benin" if country=="Benin ( bis1974 Dahome, ab1975 Benin)"
    replace country = "Burkina Faso" if country=="Burkina Faso ( ehemals Obervolta)"
    replace country = "Taiwan" if country=="China Taiwan"
    replace country = "China" if country=="China, Volksrepublik einschl. Tibet"
    replace country = "Côte de'lvoire" if country=="Côte d'lvoire ( bis 1976 Elfenbeinküste, ab 1977 Côte d'lvoire)"
    replace country = "Ecuador" if country=="Ecuador, einschl. Galápagos- Inseln"
    replace country = "Ehem. Sowjetunion" if country=="Ehem.Sowjetunion"
    replace country = "Frankreich" if country=="Frankreich, einschl. Korsika"
    replace country = "Iran" if country=="Iran, Islam. Republik"
    replace country = "Kongo, Dem. Republik" if country=="Kongo, Dem. Republik ( ehem. Republik Zaire)"
    replace country = "Myanmar" if country=="Myanmar ( bis1989 Birma, ab 1990 Myanmar)"
    replace country = "Norwegen" if country=="Norwegen, einschl Bäreninsel"
    replace country = "Sri Lanka" if country=="Sri Lanka ( ehemals Ceylon, ab dem 22.05.1972 Sri Lanka)"
    replace country = "Syrien" if country=="Syrien, Arabische Republik"
    replace country = "Tansania" if country=="Tansania, Vereinigte Republik (vor dem 25.04.1964 Tananjika)"
    replace country = strtrim(country) // remove leading/trailing blanks

    // save
    save "${dir_data}temp/foreign_inflows_1952_1990_`fname`s''.dta", replace

    //
    // 1991-2015
    //

    // Excel import
    clear
    import excel ///
        using "${dir_data}raw/A_Herkunft-Ziel - Pers insgesamt 1991-2015.xls", ///
        sheet("`sheet2`s''") cellrange(A16:AA243) // "ungeklaert und ohne Angabe" not imported!

    // Clean
    local chars ///
        C D E F G H I J K L M N O P Q R S T U V W X Y Z ///
        AA

    local y 1991 // series starts in 1991
    qui foreach char in `chars' {
        rename `char' y`y'
        replace y`y'=. if y`y'==0 // 0 only possible if missing
        local ++y
    }

    drop B
    rename A country
    replace country = strtrim(country) // remove leading/trailing blanks

    // drop aggregates
    drop if inlist(country,"","Afrika","Amerika","Asien","Australien und Ozeanien")

    // Merge 'Other/Unknown' and 'Von und nach See'
    qui forvalues y=1991/2015 {
        cap drop total
        egen total = total(y`y') ///
            if inlist(country, "Unbekanntes Ausland", "Von und nach See")
        replace y`y'=total if country=="Unbekanntes Ausland"
    }
    drop total
    drop if inlist(country, "Von und nach See")

    // drop completely missing rows
    egen rnm = rownonmiss(y1991-y2015)
    drop if rnm == 0
    drop rnm

    // prepare merge
    replace country = "Ehem. Jugoslawien" if country=="ehemals Bundesrepublik Jugoslawien bzw. Serbien und Montenegro"

    // add continent indicator
    gen continent = .
    replace continent=5 if _n<=210
    replace continent=4 if _n<=192
    replace continent=3 if _n<=144
    replace continent=2 if _n<=107
    replace continent=1 if _n<=52
    lab def continent 1 "Europe" 2 "Africa" 3 "America" 4 "Asia" 5 "Australia and Oceania"
    lab val continent continent

    //
    //    MERGING HERE
    //

    merge 1:1 country using "${dir_data}temp/foreign_inflows_1952_1990_`fname`s''.dta"
    erase "${dir_data}temp/foreign_inflows_1952_1990_`fname`s''.dta"
    drop _merge
    order country continent y1952-y1990

    //
    // Harmonize
    //

    sort continent country
    replace country = "Übriges Europa" if country=="übriges Europa"
    replace country = "Übriges Afrika" if country=="übriges Afrika"

    /*
     Clean by hand:
     - Yugoslavia as one entity for the arrival periods 1986-1995, 1996-2005,
       and 2006-2010
     - Soviet Union as one entity for 1986-1995, split category for 1996-2005
     - Czechoslovakia as one entity for 1986-1995, split category 1996-2005
    */

    local cohort3 y1991-y1993 // detailed info starts 1991
    local cohort4 y1994-y2003
    local cohort5 y2004-y2015

    // cohort 1991-1993
    qui foreach y of varlist `cohort3' {

        // Yugoslavia
        cap drop total
        egen total = total(`y') ///
            if inlist(country, "Ehem. Jugoslawien", "Bosnien und Herzegowina", ///
                "Kosovo", "Kroatien", "Mazedonien", "Montenegro", "Slowenien", ///
                "Serbien mit Kosovo", "Serbien ohne Kosovo")
        replace `y'=total if country=="Ehem. Jugoslawien"
        replace `y'=. if inlist(country, "Bosnien und Herzegowina", ///
                "Kosovo", "Kroatien", "Mazedonien", "Montenegro", "Slowenien", ///
                "Serbien mit Kosowo", "Serbien ohne Kosowo")

        // Soviet Union
        cap drop total1
        egen total1 = total(`y') ///
            if inlist(country, "Ehem. Sowjetunion", "Armenien", "Aserbaidschan", ///
                "Estland", "Georgien", "Kasachstan", "Kirgisistan", "Lettland", ///
                "Litauen") // expression too long, split
        cap drop total2
        egen total2 = total(`y') ///
            if inlist(country, "Republik Moldau", "Russische Föderation", ///
            "Tadschikistan", "Turkmenistan", "Ukraine", "Usbekistan", ///
            "Weißrussland (Belarus)")
        cap drop total
        sum total2, meanonly
        gen total = total1 + r(mean)
        replace `y'=total if country=="Ehem. Sowjetunion"
        replace `y'=. if inlist(country, "Armenien", "Aserbaidschan", ///
            "Estland", "Georgien", "Kasachstan", "Kirgisistan", "Lettland", ///
            "Litauen")
        replace `y'=. if inlist(country, "Republik Moldau", "Russische Föderation", ///
            "Tadschikistan", "Turkmenistan", "Ukraine", "Usbekistan", ///
            "Weißrussland (Belarus)")

        // Czechoslovakia
        cap drop total
        egen total = total(`y') ///
            if inlist(country, "Ehem. Tschechoslowakei", "Tschechische Republik", ///
                "Slowakei")
        replace `y'=total if country=="Ehem. Tschechoslowakei"
        replace `y'=. if inlist(country, "Tschechische Republik", ///
            "Slowakei")

    }

    // cohort 1994-2003
    qui foreach y of varlist `cohort4' {

        // Yugoslavia
        cap drop total
        egen total = total(`y') ///
            if inlist(country, "Ehem. Jugoslawien", "Bosnien und Herzegowina", ///
                "Kosovo", "Kroatien", "Mazedonien", "Montenegro", "Slowenien", ///
                "Serbien mit Kosovo", "Serbien ohne Kosovo")
        replace `y'=total if country=="Ehem. Jugoslawien"
        replace `y'=. if inlist(country, "Bosnien und Herzegowina", ///
                "Kosovo", "Kroatien", "Mazedonien", "Montenegro", "Slowenien", ///
                "Serbien mit Kosowo", "Serbien ohne Kosowo")

        // Soviet Union
        /*
         Here I assign the individuals in "unspecified from. Soviet Union" to all
         the constituing countries based on their respective shares of the total
         inflows. Might be not totally correct, but sensible approximation and
         allowing to distinguish more countries.
        */
        // get total based on all former SU countries
        cap drop total1
        egen total1 = total(`y') ///
            if inlist(country, "Ehem. Sowjetunion", "Armenien", "Aserbaidschan", ///
                "Estland", "Georgien", "Kasachstan", "Kirgisistan", "Lettland", ///
                "Litauen") // expression too long, split
        cap drop total2
        egen total2 = total(`y') ///
            if inlist(country, "Republik Moldau", "Russische Föderation", ///
            "Tadschikistan", "Turkmenistan", "Ukraine", "Usbekistan", ///
            "Weißrussland (Belarus)")
        cap drop total
        sum total2, meanonly
        gen total = total1 + r(mean)
        sum total1, meanonly
        replace total = total2 + r(mean) if mi(total)
        // get number of obs in "form. SU"
        sum `y' if country=="Ehem. Sowjetunion", meanonly
        if r(mean)!=. {
            // add respective shares of the unspecified category to single country obs
            replace `y' = `y' + round((`y'/(total-r(mean)))*r(mean)) if !mi(total)
            replace `y'=. if country=="Ehem. Sowjetunion"
        }

        // Czechoslovakia
        /*
         Same procedure as above.
        */
        cap drop total
        egen total = total(`y') ///
            if inlist(country, "Ehem. Tschechoslowakei", "Tschechische Republik", ///
                "Slowakei")
        // get number of obs former Czechoslovakia
        sum `y' if country=="Ehem. Tschechoslowakei"
        if r(mean)!=. {
            // add respective shares of the unspecified category to single country obs
            replace `y' = `y' + round((`y'/(total-r(mean)))*r(mean)) if !mi(total)
            replace `y'=. if country=="Ehem. Tschechoslowakei"
        }

    }

    // cohort 2004-2015
    qui foreach y of varlist `cohort5' {

        // Yugoslavia
        cap drop total
        egen total = total(`y') ///
            if inlist(country, "Ehem. Jugoslawien", "Bosnien und Herzegowina", ///
                "Kosovo", "Kroatien", "Mazedonien", "Montenegro", "Slowenien", ///
                "Serbien mit Kosovo", "Serbien ohne Kosovo")
        replace `y'=total if country=="Ehem. Jugoslawien"
        replace `y'=. if inlist(country, "Bosnien und Herzegowina", ///
                "Kosovo", "Kroatien", "Mazedonien", "Montenegro", "Slowenien", ///
                "Serbien mit Kosovo", "Serbien ohne Kosovo")

    }
    drop total*

    // add gender indicator
    gen sex = `s'
    lab def sex 1 "Man" 2 "Woman", modify
    lab val sex sex

    // save
    save "${dir_data}temp/foreign_inflows_1952_2015_`fname`s''.dta", replace

}


//--------------------------//
//    MERGE WOMEN AND MEN   //
//--------------------------//

// stack
use "${dir_data}temp/foreign_inflows_1952_2015_m.dta", replace
append using "${dir_data}temp/foreign_inflows_1952_2015_f.dta"


/*
 SAVE DATASET FOR YEARLY TOTALS BY GENDER
*/

preserve
    forvalues y=1952/2015 {
        egen total`y' = total(y`y'), by(sex)
    }
    bys sex: gen n = _n
    keep if n==1
    keep sex total*
    reshape long total, i(sex) j(year)
    replace total = total/1000 // in thousands
    egen totalmf = total(total), by(year)
    save "${dir_data}temp/foreign_inflows_1952_2015_totals.dta", replace
restore

//-------------//
//    CLEAN    //
//-------------//

// drop
drop y1952-y1963 y2011-y2015

/*
 The following routine checks if countries are unavailable for the full
 arrival period and if so, merges them with the rest category for the
 respective continent.
*/

local cohort1 y1964-y1973
local cohort2 y1974-y1983
local cohort3 y1984-y1993
local cohort4 y1994-y2003
local cohort5 y2004-y2010

local other `" "Übriges Europa" "Übriges Afrika" "Übriges Amerika" "Übriges Asien" "Übriges Ozeanien" "'

// for cohorts
qui forvalues i=1/5 {
    // check if missing values within period
    cap drop rnm
    egen rnm = rownonmiss(`cohort`i'')
    cap drop miss
    if `i'<5 {
        gen miss=1 if rnm<10
    }
    else {
        gen miss=1 if rnm<7
    }
    // condition: non-missing for both men and women
    egen totmiss = max(miss==1), by(country)
    replace miss=totmiss
    drop totmiss
    // replace with totals
    foreach y of varlist `cohort`i'' {
        local cnt 0
        foreach c in `other' {
            local ++cnt
            forvalues s=1/2 {
                cap drop total
                egen total = total(`y') if (miss==1 | country=="`c'") & continent==`cnt' & sex==`s'
                replace `y' = total if country=="`c'" & sex==`s'
                replace `y' = . if miss==1 & country!="`c'" & continent==`cnt' & sex==`s'
            }
        }
    }
}
drop rnm miss

/*
 The following routine merges all countries with the rest category of the
 continent if their respective share per cohort is below a threshold
*/

// gen cohorts
qui forvalues i=1/5 {
    egen cohort`i' = rowtotal(`cohort`i'') // per country/gender in period
}
label var cohort1 "Arrival cohort 1964-1973"
label var cohort2 "Arrival cohort 1974-1983"
label var cohort3 "Arrival cohort 1984-1993"
label var cohort4 "Arrival cohort 1994-2003"
label var cohort5 "Arrival cohort 2004-2010"

// replace those under threshold with respective 'other' category
local th = 0.008 // 0.8%
qui forvalues i=1/5 {
    // gen share
    gen cohort`i'_belowth = 0
    gen cohort`i'_total = .
    forvalues s=1/2 {
        egen cohort`i'_total_temp = total(cohort`i') ///
            if sex==`s'
        replace cohort`i'_total = cohort`i'_total_temp if sex==`s'
        drop cohort`i'_total_temp
        replace cohort`i'_belowth = 1 ///
            if (cohort`i'/cohort`i'_total)<`th' & sex==`s'
        // replace with 'other' category if below threshold
        local cnt 0
        foreach c in `other' {
            local ++cnt
            cap drop total
            egen total = total(cohort`i') ///
                if (cohort`i'_belowth==1 | country=="`c'") & continent==`cnt' & sex==`s'
            replace cohort`i' = total ///
                if country=="`c'" & sex==`s'
            replace cohort`i' = . ///
                if cohort`i'_belowth==1 & country!="`c'" & continent==`cnt' & sex==`s'
        }
    }
}
drop total

// check which countries are left
cap drop rtotal
egen rtotal = rowtotal(cohort1-cohort5)
tab country sex if rtotal!=0 // these countries end up in the graph, labeling only them for now
drop rtotal

// rename
#delimit ;
    local ctuples `"
        "Algerien" "Algeria"
        "Argentinien" "Argentina"
        "Australien" "Australia"
        "Belgien" "Belgium"
        "Brasilien" "Brasil"
        "Bulgarien" "Bulgaria"
        "Dominikanische Republik" "Dominican Republic"
        "Dänemark" "Denmark"
        "Ehem. Jugoslawien" "(form.) Yugoslavia"
        "Ehem. Tschechoslowakei" "(form.) Czechoslovakia"
        "Ehem. Sowjetunion" "(form.) Soviet Union"
        "Finnland" "Finland"
        "Frankreich" "France"
        "Griechenland" "Greece"
        "Indien" "India"
        "Indonesien" "Indonesia"
        "Irak" "Iraq"
        "Irland" "Ireland"
        "Island" "Iceland"
        "Italien" "Italy"
        "Jordanien" "Jordan"
        "Kambodscha" "Cambodia"
        "Kamerun" "Cameroon"
        "Kanada" "Canada"
        "Kasachstan" "Kazakhstan"
        "Kolumbien" "Columbia"
        "Kongo, Dem. Republik" "DRC"
        "Korea, Dem. Volksrepublik" "North Korea"
        "Korea, Republik" "South Korea"
        "Kuba" "Cuba"
        "Lettland" "Latvia"
        "Libanon" "Lebanon"
        "Libyen" "Libya"
        "Litauen" "Lithuania"
        "Luxemburg" "Luxembourg"
        "Madagaskar" "Madagascar"
        "Marokko" "Marocco"
        "Mexiko" "Mexico"
        "Neuseeland" "New Zealand"
        "Niederlande" "Netherlands"
        "Norwegen" "Norway"
        "Philippinen" "Philippines"
        "Polen" "Poland"
        "Rumänien" "Romania"
        "Russische Föderation" "Russian Federation"
        "Saudi-Arabien" "Saudi-Arabia"
        "Schweden" "Sweden"
        "Schweiz" "Switzerland"
        "Slowakei" "Slovakia"
        "Spanien" "Spain"
        "Syrien" "Syria"
        "Südafrika" "South Africa"
        "Tansania" "Tanzania"
        "Trinidad und Tobago" "Trinidad and Tobago"
        "Tschad" "Chad"
        "Tschechische Republik" "Czech Republic"
        "Tunesien" "Tunisia"
        "Türkei" "Turkey"
        "Ungarn" "Hungary"
        "Vereinigte Staaten, auch USA" "USA"
        "Vereinigtes Königreich" "UK"
        "Ägypten" "Egypt"
        "Äthiopien" "Ethiopia"
        "Österreich" "Austria"
        "Übriges Afrika" "Other Africa"
        "Übriges Amerika" "Other America"
        "Übriges Asien" "Other Asia"
        "Übriges Europa" "Other Europe"
        "Übriges Ozeanien" "Other Oceania"
        "Unbekanntes Ausland" "Other"
        "'
#delimit cr

local cvals : word count `ctuples'
qui forvalues i=1(2)`cvals' {
    local j = `i'+1
    local ori : word `i' of `ctuples'
    local rep : word `j' of `ctuples'
    dis "`ori'"
    dis "`rep'"
    replace country="`rep'" if country=="`ori'"
}

// transform values into labels
sort continent country sex
by continent: gen id = continent*100 + ceil(_n/2) // grouped by continent, same id for women and men
replace id = 999 if country=="Other"
replace id = 199 if country=="Other Europe"
replace id = 299 if country=="Other Africa"
replace id = 399 if country=="Other America"
replace id = 499 if country=="Other Asia"
replace id = 599 if country=="Other Oceania"
qui levelsof id, local(idlvls)
qui foreach id in `idlvls' {
    levelsof country if id==`id', local(val)
    lab def country `id' `val', modify
}

lab var id "Country"
drop country
rename id country
lab val country country
order continent country sex

// save
save "${dir_data}temp/foreign_inflows_1952_2015_all_clean.dta", replace


//-------------//
//    PLOT     //
//-------------//

// merge all 'other' categories
qui forvalues s=1/2 {
    forvalues i=1/5 {
        cap drop total
        egen total = total(cohort`i') ///
            if inlist(country, 199, 299, 399, 499, 599, 999) & sex==`s'
        replace cohort`i'=total if country==999 & sex==`s'
    }
}
drop total
drop if inlist(country, 199, 299, 399, 499, 599)

// ABSOLUTE

local th 5 // select number of main groups

// gen values to be stacked for each cohort
qui forvalues i=1/5 {
    preserve
        local lbl : variable label cohort`i'
        // make per 1,000
        replace cohort`i'=cohort`i'/1000
        // restrict for plots of the 5 most important by sex
        drop if mi(cohort`i') // exclude missings
        replace cohort`i'=0 if country==999 // new rest category to 0 for ordering
        cap drop n
        sort sex cohort`i'
        by sex: gen n = _N - _n + 1
        keep if n<=`th' | country==999 // exclude rest
        replace n=6 if country==999
        // create cumulative values to manually stack bars
        sort sex n
        gen cohort_cum = .
        gen cohort_cum_lo = .
        gen cohort_cum_hi = .
        local nother = `th'+1
        forvalues n=1/`th' {
            if `n'==1 {
                // first value
                replace cohort_cum = cohort`i' if n==`n' // sum helper
                replace cohort_cum_lo = 0 if n==`n' // sum helper
                replace cohort_cum_hi = cohort_cum if n==`n' // sum helper
                gen cohort_cum_`n' = cohort`i' if n==`n' // variable to be plotted
            }
            else {
                // cumulative values in between
                replace cohort_cum = cohort`i' + cohort_cum[_n-1] if n==`n'
                replace cohort_cum_lo = cohort_cum[_n-1] if n==`n' // sum helper
                replace cohort_cum_hi = cohort_cum if n==`n' // sum helper
                gen cohort_cum_`n' = cohort_cum if n==`n'
            }
            // reverse for women
            //replace cohort_cum_`n' = -1 * cohort_cum_`n' if sex==2 & n==`n'
            // last value: other always 100%
            if `n'==`th' {
                gen cohort_cum_`nother' = cohort`i'_total/1000 if n==`th'+1
                // save rest value for other
                replace cohort`i'=cohort_cum_`nother' - cohort_cum[_n-1] if country==999 & n==`th'+1 // new rest category
                replace cohort_cum_lo = cohort_cum[_n-1] if n==`th'+1 // sum helper
                replace cohort_cum_hi = cohort_cum_6 if n==`th'+1 // sum helper
                // reverse for women
                //replace cohort_cum_`nother' = -1 * cohort_cum_`nother' if sex==2 & n==`th'+1
            }
        }
        // make all positive again (puh!)
        gen femtot_temp = cohort_cum_`nother' if sex==2
        egen femtot = total(femtot)
        drop femtot_temp
        forvalues n=1/`nother' {
            // replace cohort_cum_`n' = cohort_cum_`n' + femtot if sex==1
        }
        // new for rbar plots
        //replace cohort_cum = cohort_cum + femtot if sex==1
        //replace cohort_cum_lo = cohort_cum_lo + femtot if sex==1
        //replace cohort_cum_hi = cohort_cum_hi + femtot if sex==1
        // avoid overlapping
        //replace cohort_cum_lo = cohort_cum_lo-4 if n>1 | sex==1
        //replace cohort_cum_hi = cohort_cum_hi+4 if n<6 | sex==2
        // save dataset
        gen i = `i'
        keep cohort`i' cohort_cum_* i n sex country
        save "${dir_data}temp/foreign_inflows_1952_2015_plot_part`i'.dta", replace
    restore
}

// append datasets
use "${dir_data}temp/foreign_inflows_1952_2015_plot_part1.dta", replace
forvalues i=2/5 {
    append using "${dir_data}temp/foreign_inflows_1952_2015_plot_part`i'.dta"
}

// shorten labels
tab country
tab country, nol
lab def country_short ///
    102 "SU" 103 "YU" 106 "AT" 115 "GR" 116 "HU" 119 "IT" 135 "PL" ///
    137 "RO" 138 "RU" 144 "ES" 147 "TR" 334 "US" 420 "KZ" 999 "Other"
lab val country country_short

/*
 OPTIONS FOR AXIS 1 (UPPER!)
*/

local yalign1 1966.125 1976.125 1986.125 1996.125 2005.375 // x values where the bars appear
local lastyalign1 : word 5 of `yalign1'
local yalign2 1970.875 1980.875 1990.875 2000.875 2008.625 // x values where the bars appear
local lastyalign2 : word 5 of `yalign2'

// ADD COLORS MANUALLY
colorpalette cblind, locals
local ycolors `"`Orange' `Sky_Blue' `bluish_Green' `Vermillion' `reddish_Purple'"'

// plot options
local plotopts1 `" ylabel(0(1000)5000, axis(1)) ymtick(0(500)5000, axis(1)) yscale(range(-2050 5250) axis(1)) yaxis(1)"'

// plot input
local plotme
local cnt 0
foreach ya in `yalign1' {
    local ++cnt
    local color : word `cnt' of `ycolors'
    if "`ya'"=="`lastyalign1'" {
        local barwidth "barwidth(3.25)"
    }
    else {
        local barwidth "barwidth(4.75)"
    }
    local plotme `"(rbar cohort_cum_lo cohort_cum_hi i if sex==2 & i==`ya', `plotopts1' color("`color'") lcolor("`color'") fintensity(60) `barwidth') `plotme'"'
}
local cnt 0
foreach ya in `yalign2' {
    local ++cnt
    local color : word `cnt' of `ycolors'
    dis "`color'"
    if "`ya'"=="`lastyalign2'" {
        local barwidth "barwidth(3.25)"
    }
    else{
        local barwidth "barwidth(4.75)"
    }
    local plotme `"(rbar cohort_cum_lo cohort_cum_hi i if sex==1 & i==`ya', `plotopts1' color("`color'") lcolor("`color'") fintensity(30) `barwidth') `plotme'"'
}

// Bar labels and positions
local plotme2
gen cohort_cum_lab = .
gen mlabpos = .
forvalues n=1/`nother' {
    forvalues i=1/5 {
        replace cohort_cum_lab = cohort_cum_`n' - (cohort`i'/2) if i==`i' & n==`n'
    }
    local odd = mod(`n',2)
    if `odd'==1 {
        replace mlabpos = 12 if n==`n'
    }
    else {
        replace mlabpos = 12 if n==`n'
    }
}
local cnt 0
foreach ya in `yalign1' {
    local ++cnt
    local color : word `cnt' of `ycolors'
    local plotme2 ///
        `"(scatter cohort_cum_lab i if sex==2 & i==`ya', mlabel(country) mlabcolor(white) mcolor(none) mlabvposition(mlabpos)) `plotme2'"'
}
local cnt 0
foreach ya in `yalign2' {
    local ++cnt
    local color : word `cnt' of `ycolors'
    local plotme2 ///
        `"(scatter cohort_cum_lab i if sex==1 & i==`ya', mlabel(country) mlabcolor("`color'") mcolor(none) mlabvposition(mlabpos)) `plotme2'"'
}


// order
forvalues i=1/5 {
    local j : word `i' of `yalign1'
    replace i = `j' if i==`i' & sex==2
    local k : word `i' of `yalign2'
    replace i = `k' if i==`i' & sex==1
}


// Styling
grstyle clear
grstyle init
grstyle set plain, noextend horizontal  // imesh = R
grstyle set nogrid
//grstyle set grid, minor
grstyle set color cblind, select(5 5 5 5 5 5 5 5 5 5 5 5 4 4 4 4 4 4 4 4 4 4 4 4 5 4 5 4): p#
//grstyle set color cblind, select(5): p7label
//grstyle set intensity 35, plots(1/24): p#bar
grstyle set color cblind, select(5) opacity(0) plots(25/26): p#markline p#markfill
grstyle set color cblind, select(4) opacity(0) plots(25/26): p#markline p#markfill
grstyle set color gs0: xyline
grstyle set lpattern solid: p#
grstyle set intensity 100: bar_line
grstyle set legend 6, nobox
grstyle set graphsize 14cm 12cm
grstyle set size 9pt: heading
grstyle set size 6pt: subheading axis_title key_label
grstyle set size 4pt, plots(1/40): p#label
grstyle set size 5pt: tick_label body small_body
grstyle set size 2pt: axis
grstyle set size -1.5, pt: label_gap
grstyle set size 3pt: tick
grstyle set size 0pt: minortick
grstyle set size 2pt: tickgap
grstyle set size 3pt: legend_key_gap
grstyle set size 5pt: legend_key_xsize legend_key_ysize
grstyle set size 1pt: legend_row_gap
grstyle set symbolsize 0, pt
grstyle set linewidth 0.4, pt plots(1/40): p# p#bar p#barline p#lineplot
grstyle set linewidth 0.25, pt plots(1/40): p#bar
grstyle set linewidth 0.4, pt: pmark legend tick axisline major_grid xyline
grstyle set linewidth 0.4, pt: xyline
grstyle set lpattern dot: xyline
grstyle set color cblind, select(1) opacity(50): xyline
grstyle set margin "0 0 2 0", pt: subheading
grstyle set margin "3 3 0 0", pt: axis_title
grstyle set margin "3 8 3 3", pt: graph
grstyle set margin "0 0 0 0", pt: twoway

//
// APPEND FOR SECOND PLOT: Inflows by year x gender
//

append using "${dir_data}temp/foreign_inflows_1952_2015_totals.dta"
egen i_temp = rowtotal(y i)
replace i = i_temp
drop i_temp year
drop if i<1959

gen total_hi = totalmf if sex==1
gen total_lo = totalmf-total if sex==1
replace total_hi = total if sex==2
replace total_lo = 0 if sex==2

replace total_hi = total_hi - 2000 // DROP in plot
replace total_lo = total_lo - 2000 // DROP in plot

/*
 OPTIONS FOR AXIS 2 (LOWER!)
*/

// plot options
local plotopts2 `" ylabel(-2000 "0" -1500 "500" -1000 "1000" -500 "1500" 0 "2000", axis(2)) ytick(,axis(2)) ymtick(none) yscale(range(-2050 5250) axis(2)) xscale(range(1957 2017)) xlabel(1964(10)2014) ytitle("") xmlabel(none) xmtick(none) xtitle(Year) barwidth(0.5) yaxis(2)"'


// plot
twoway `plotme' `plotme2' ///
    (rbar total_lo total_hi i if sex==1 & inrange(i,1959,1963), yaxis(2) color(gs12) lcolor(gs12) fintensity(30) barwidth(0.5)) ///
    (rbar total_lo total_hi i if sex==2 & inrange(i,1959,1963), yaxis(2) color(gs8) lcolor(gs8) fintensity(80) barwidth(0.5)) ///
    (rbar total_lo total_hi i if sex==1 & inrange(i,1964,1973), yaxis(2) color(`Orange') lcolor(`Orange') fintensity(30) barwidth(0.5)) ///
    (rbar total_lo total_hi i if sex==2 & inrange(i,1964,1973), yaxis(2) color(`Orange') lcolor(`Orange') fintensity(80) barwidth(0.5)) ///
    (rbar total_lo total_hi i if sex==1 & inrange(i,1974,1983), yaxis(2) color(`Sky_Blue') lcolor(`Sky_Blue') fintensity(30) barwidth(0.5)) ///
    (rbar total_lo total_hi i if sex==2 & inrange(i,1974,1983), yaxis(2) color(`Sky_Blue') lcolor(`Sky_Blue') fintensity(80) barwidth(0.5)) ///
    (rbar total_lo total_hi i if sex==1 & inrange(i,1984,1993), yaxis(2) color(`bluish_Green') lcolor(`bluish_Green') fintensity(30) barwidth(0.5)) ///
    (rbar total_lo total_hi i if sex==2 & inrange(i,1984,1993), yaxis(2) color(`bluish_Green') lcolor(`bluish_Green') fintensity(80) barwidth(0.5)) ///
    (rbar total_lo total_hi i if sex==1 & inrange(i,1994,2003), yaxis(2) color(`Vermillion') lcolor(`Vermillion') fintensity(30) barwidth(0.5)) ///
    (rbar total_lo total_hi i if sex==2 & inrange(i,1994,2003), yaxis(2) color(`Vermillion') lcolor(`Vermillion') fintensity(80) barwidth(0.5)) ///
    (rbar total_lo total_hi i if sex==1 & inrange(i,2004,2010), yaxis(2) color(`reddish_Purple') lcolor(`reddish_Purple') fintensity(30) barwidth(0.5)) ///
    (rbar total_lo total_hi i if sex==2 & inrange(i,2004,2010), yaxis(2) color(`reddish_Purple') lcolor(`reddish_Purple') fintensity(80) barwidth(0.5)) ///
    (rbar total_lo total_hi i if sex==1 & inrange(i,2011,2015), yaxis(2) color(gs12) lcolor(gs12) fintensity(30) barwidth(0.5)) ///
    (rbar total_lo total_hi i if sex==2 & inrange(i,2011,2015), color(gs8) lcolor(gs8) barwidth(0.5) fintensity(80) ///
    `plotopts2' yline(-1000(1000)5000) xline(1963.5 1973.5 1983.5 1993.5 2003.5 2010.5) ///
    xtitle("Year", margin(0 0 0 2)) ytitle("N in 1,000", axis(1) margin(0 1 25 0)) ytitle("N in 1,000", margin(1 0 0 65) justification(left) axis(2)) ///
    title("Immigrant inflows") subtitle("By arrival cohort, gender and main citizenships (upper panel). By year and gender (lower panel). ", margin(bottom)) ///
    legend(order(22 "Women" 21 "Men") cols(2)))
graph export "${dir_g}sum_cohortcomp.emf", replace
graph export "${dir_g}sum_cohortcomp.svg", replace
