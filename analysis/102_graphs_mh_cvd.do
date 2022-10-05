/* ===========================================================================
Do file name:   graphs_mh_cvd.do
Project:        COVID Collateral
Date:           21/03/2022
Author:         Ruth Costello
Description:    Generates line graphs of rates of each outcome and strata per month
==============================================================================*/
cap log using ./logs/graphs_mh_cvd.log, replace
cap mkdir ./output/collapsed
cap mkdir ./output/graphs

* Generates graphs for clinical monitoring measures
foreach this_group in cvd mh {
* Ethnicity
        import delimited using ./output/measures/`this_group'/measure_bp_meas_`this_group'_ethnicity_rate.csv, numericcols(4) clear
        * Shouldn't be missing on server but is in dummy data
        count if ethnicity==.
        * Drop missings as not required
        drop if ethnicity==0 | ethnicity==.
        tab `this_group'_subgroup 
        drop if `this_group'_subgroup==0
        drop `this_group'_subgroup 
        * Generate rate per 100,000
        gen rate = value*100000 
        * Format date
        gen dateA = date(date, "YMD")
        drop date
        format dateA %dD/M/Y
        * reshape dataset so columns with rates for each ethnicity 
        reshape wide value rate population bp_meas, i(dateA) j(ethnicity)
        describe
        * Labelling ethnicity variables
        label var rate1 "White"
        label var rate2 "Mixed"
        label var rate3 "Asian"
        label var rate4 "Black"
        label var rate5 "Other"

        * Generate line graph
        graph twoway line rate1 rate2 rate3 rate4 rate5 date, tlabel(01Jan2018(120)01Apr2022, angle(45) ///
        format(%dM-CY) labsize(small)) ytitle("Rate per 100,000") xtitle("Date") ylabel(#5, labsize(small) ///
        angle(0)) yscale(r(0) titlegap(*10)) xmtick(##6) legend(row(1) size(small) ///
        title("Ethnic categories", size(small))) graphregion(fcolor(white))

        graph export ./output/graphs/line_`this_group'_bp_ethnic.svg, as(svg) replace
    /* IMD
    clear 
    import delimited using ./output/measures/`this_group'/measure_bp_meas_`this_group'_imd_rate.csv, numericcols(4)
    * IMD should not have missings as . on server but could be in dummy data
    count if imd==.
    * Drop missings
    drop if imd==. | imd==0
    * Generate rate per 100,000
    gen rate = value*100000 
    * Format date
    gen dateA = date(date, "YMD")
    drop date
    format dateA %dD/M/Y
    * reshape dataset so columns with rates for each ethnicity 
    reshape wide value rate `this_group'_subgroup bp_meas, i(dateA) j(imd)
    describe
    * Labelling ethnicity variables
    label var rate1 "IMD - 1"
    label var rate2 "IMD - 2"
    label var rate3 "IMD - 3"
    label var rate4 "IMD - 4"
    label var rate5 "IMD - 5"

    * Generate line graph
    graph twoway line rate1 rate2 rate3 rate4 rate5 date, tlabel(01Jan2018(120)01Apr2022, angle(45) ///
    format(%dM-CY) labsize(small)) ytitle("Rate per 100,000") xtitle("Date") ylabel(#5, labsize(small) ///
    angle(0)) yscale(r(0) titlegap(*10)) xmtick(##6) legend(row(1) size(small) ///
    title("IMD categories", size(small))) graphregion(fcolor(white))

    graph export ./output/graphs/line_`this_group'_bp_imd.svg, as(svg) replace
    */
    }

/* Hospital admission graphs
local groups "mi stroke heart_failure vte"
forvalues i=1/4 {
    local this_group :word `i' of `groups'
* Ethnicity
    clear 
    import delimited using ./output/measures/cvd/measure_`this_group'_admission_ethnicity_rate.csv, numericcols(4)
     * Shouldn't be missing on server but is in dummy data
    count if ethnicity==.
    * Drop missings as not required
    drop if ethnicity==0 | ethnicity==.
    * Generate rate per 100,000
    gen rate = value*100000 
    * Format date
    gen dateA = date(date, "YMD")
    drop date
    format dateA %dD/M/Y
    tab dateA 
    * reshape dataset so columns with rates for each ethnicity 
    reshape wide value rate `this_group'_admission population, i(dateA) j(ethnicity)
    describe
    * Labelling ethnicity variables
    label var rate1 "White"
    label var rate2 "Mixed"
    label var rate3 "Asian"
    label var rate4 "Black"
    label var rate5 "Other"

    * Generate line graph
    graph twoway line rate1 rate2 rate3 rate4 rate5 date, tlabel(01Jan2018(120)01Apr2022, angle(45) ///
    format(%dM-CY) labsize(small)) ytitle("Rate per 100,000") xtitle("Date") ylabel(#5, labsize(small) ///
    angle(0)) yscale(r(0) titlegap(*10)) xmtick(##6) legend(row(1) size(small) ///
    title("Ethnic categories", size(small))) graphregion(fcolor(white))

    graph export ./output/graphs/line_`this_group'_admission_ethnicity.svg, as(svg) replace
    * IMD
    clear 
    import delimited using ./output/measures/cvd/measure_`this_group'_admission_imd_rate.csv, numericcols(4)
    * IMD should not have missings as . on server but could be in dummy data
    count if imd==.
    * Drop missings
    drop if imd==. | imd==0
    * Generate rate per 100,000
    gen rate = value*100000 
    * Format date
    gen dateA = date(date, "YMD")
    drop date
    format dateA %dD/M/Y
    tab dateA 
    * reshape dataset so columns with rates for each ethnicity 
    reshape wide value rate `this_group'_admission population, i(dateA) j(imd)
    describe
    * Labelling ethnicity variables
    label var rate1 "IMD - 1"
    label var rate2 "IMD - 2"
    label var rate3 "IMD - 3"
    label var rate4 "IMD - 4"
    label var rate5 "IMD - 5"

    * Generate line graph
    graph twoway line rate1 rate2 rate3 rate4 rate5 date, tlabel(01Jan2018(120)01Apr2022, angle(45) ///
    format(%dM-CY) labsize(small)) ytitle("Rate per 100,000") xtitle("Date") ylabel(#5, labsize(small) ///
    angle(0)) yscale(r(0) titlegap(*10)) xmtick(##6) legend(row(1) size(small) ///
    title("IMD categories", size(small))) graphregion(fcolor(white))

    graph export ./output/graphs/line_`this_group'_admission_imd.svg, as(svg) replace

}
local groups "depression anxiety smi self_harm eating_dis ocd"
forvalues i=1/6 {
    local this_group :word `i' of `groups'
* Ethnicity
    clear 
    import delimited using ./output/measures/mh/measure_`this_group'_admission_ethnicity_rate.csv, numericcols(4)
     * Shouldn't be missing on server but is in dummy data
    count if ethnicity==.
    * Drop missings as not required
    drop if ethnicity==0 | ethnicity==.
    * Generate rate per 100,000
    gen rate = value*100000 
    * Format date
    gen dateA = date(date, "YMD")
    drop date
    format dateA %dD/M/Y
    tab dateA 
    * reshape dataset so columns with rates for each ethnicity 
    reshape wide value rate `this_group'_admission population, i(dateA) j(ethnicity)
    describe
    * Labelling ethnicity variables
    label var rate1 "White"
    label var rate2 "Mixed"
    label var rate3 "Asian"
    label var rate4 "Black"
    label var rate5 "Other"

    * Generate line graph
    graph twoway line rate1 rate2 rate3 rate4 rate5 date, tlabel(01Jan2018(120)01Apr2022, angle(45) ///
    format(%dM-CY) labsize(small)) ytitle("Rate per 100,000") xtitle("Date") ylabel(#5, labsize(small) ///
    angle(0)) yscale(r(0) titlegap(*10)) xmtick(##6) legend(row(1) size(small) ///
    title("Ethnic categories", size(small))) graphregion(fcolor(white))

    graph export ./output/graphs/line_`this_group'_admission_ethnicity.svg, as(svg) replace
    * IMD
    clear 
    import delimited using ./output/measures/mh/measure_`this_group'_admission_imd_rate.csv, numericcols(4)
    * IMD should not have missings as . on server but could be in dummy data
    count if imd==.
    * Drop missings
    drop if imd==. | imd==0
    * Generate rate per 100,000
    gen rate = value*100000 
    * Format date
    gen dateA = date(date, "YMD")
    drop date
    format dateA %dD/M/Y
    tab dateA 
    * reshape dataset so columns with rates for each ethnicity 
    reshape wide value rate `this_group'_admission population, i(dateA) j(imd)
    describe
    * Labelling ethnicity variables
    label var rate1 "IMD - 1"
    label var rate2 "IMD - 2"
    label var rate3 "IMD - 3"
    label var rate4 "IMD - 4"
    label var rate5 "IMD - 5"

    * Generate line graph
    graph twoway line rate1 rate2 rate3 rate4 rate5 date, tlabel(01Jan2018(120)01Apr2022, angle(45) ///
    format(%dM-CY) labsize(small)) ytitle("Rate per 100,000") xtitle("Date") ylabel(#5, labsize(small) ///
    angle(0)) yscale(r(0) titlegap(*10)) xmtick(##6) legend(row(1) size(small) ///
    title("IMD categories", size(small))) graphregion(fcolor(white))

    graph export ./output/graphs/line_`this_group'_admission_imd.svg, as(svg) replace

}

* Hospital admissions - primary diagnosis CVD
local groups "mi stroke heart_failure vte"
forvalues i=1/4 {
    local this_group :word `i' of `groups'
* Ethnicity
    clear 
    import delimited using ./output/measures/cvd/measure_`this_group'_primary_admission_ethnicity_rate.csv, numericcols(4)
     * Shouldn't be missing on server but is in dummy data
    count if ethnicity==.
    * Drop missings as not required
    drop if ethnicity==0 | ethnicity==.
    * Generate rate per 100,000
    gen rate = value*100000 
    * Format date
    gen dateA = date(date, "YMD")
    drop date
    format dateA %dD/M/Y
    tab dateA 
    * reshape dataset so columns with rates for each ethnicity 
    reshape wide value rate `this_group'_primary_admission population, i(dateA) j(ethnicity)
    describe
    * Labelling ethnicity variables
    label var rate1 "White"
    label var rate2 "Mixed"
    label var rate3 "Asian"
    label var rate4 "Black"
    label var rate5 "Other"

    * Generate line graph
    graph twoway line rate1 rate2 rate3 rate4 rate5 date, tlabel(01Jan2018(120)01Apr2022, angle(45) ///
    format(%dM-CY) labsize(small)) ytitle("Rate per 100,000") xtitle("Date") ylabel(#5, labsize(small) ///
    angle(0)) yscale(r(0) titlegap(*10)) xmtick(##6) legend(row(1) size(small) ///
    title("Ethnic categories", size(small))) graphregion(fcolor(white))

    graph export ./output/graphs/line_cvd_`this_group'_primary_admission_ethnicity.svg, as(svg) replace
    * IMD
    clear 
    import delimited using ./output/measures/cvd/measure_`this_group'_primary_admission_imd_rate.csv, numericcols(4)
    * IMD should not have missings as . on server but could be in dummy data
    count if imd==.
    * Drop missings
    drop if imd==. | imd==0
    * Generate rate per 100,000
    gen rate = value*100000 
    * Format date
    gen dateA = date(date, "YMD")
    drop date
    format dateA %dD/M/Y
    tab dateA 
    * reshape dataset so columns with rates for each ethnicity 
    reshape wide value rate `this_group'_primary_admission population, i(dateA) j(imd)
    describe
    * Labelling ethnicity variables
    label var rate1 "IMD - 1"
    label var rate2 "IMD - 2"
    label var rate3 "IMD - 3"
    label var rate4 "IMD - 4"
    label var rate5 "IMD - 5"

    * Generate line graph
    graph twoway line rate1 rate2 rate3 rate4 rate5 date, tlabel(01Jan2018(120)01Apr2022, angle(45) ///
    format(%dM-CY) labsize(small)) ytitle("Rate per 100,000") xtitle("Date") ylabel(#5, labsize(small) ///
    angle(0)) yscale(r(0) titlegap(*10)) xmtick(##6) legend(row(1) size(small) ///
    title("IMD categories", size(small))) graphregion(fcolor(white))

    graph export ./output/graphs/line_cvd_`this_group'_primary_admission_imd.svg, as(svg) replace

}*/
/* Mental health measures - 3 monthly rates for primary admissions
local groups "depression anxiety smi self_harm eating_dis ocd"
forvalues i=1/6 {
    local this_group :word `i' of `groups'
* Ethnicity
    clear 
    import delimited using ./output/measures/measure_`this_group'_primary_admission_ethnicity_rate.csv, numericcols(4)
    * Generate rate per 100,000
    gen rate = value*100000 
    * Format date
    gen dateA = date(date, "YMD")
    drop date
    format dateA %dD/M/Y
    tab dateA 
    * Collapse at 3 monthly intervals
    gen quarter = qofd(dateA)
    collapse (sum) value rate `this_group'_primary_admission population (min) dateA,  by(quarter ethnicity)
    drop quarter
    * Outputing file 
    export delimited using ./output/collapsed/collapse_measure_`this_group'_primary_admission_ethnicity_rate.csv
    * reshape dataset so columns with rates for each ethnicity 
    reshape wide value rate `this_group'_primary_admission population, i(dateA) j(ethnicity)
    describe
    * Labelling ethnicity variables
    label var rate1 "White"
    label var rate2 "Mixed"
    label var rate3 "Asian"
    label var rate4 "Black"
    label var rate5 "Other"

    * Generate line graph
    graph twoway line rate1 rate2 rate3 rate4 rate5 date, tlabel(01Jan2018(180)01Jan2022, angle(45) ///
    format(%dM-CY) labsize(small)) ytitle("Rate per 100,000") xtitle("Date") ylabel(, labsize(small) ///
    angle(0)) yscale(titlegap(*10)) xmtick(##6) legend(row(1) size(small) title("Ethnic categories", size(small))) 

    graph export ./output/graphs/line_`this_group'_primary_admission_ethnicity.svg, as(svg) replace
    
    * IMD
    clear 
    import delimited using ./output/measures/measure_`this_group'_primary_admission_imd_rate.csv, numericcols(4)
    * Generate rate per 100,000
    gen rate = value*100000 
    * Format date
    gen dateA = date(date, "YMD")
    drop date
    format dateA %dD/M/Y
    tab dateA 
    * Collapse at 3 monthly intervals
    gen quarter = qofd(dateA)
    collapse (sum) value rate `this_group'_primary_admission population (min) dateA,  by(quarter imd)
    drop quarter
    * Outputing file 
    export delimited using ./output/collapsed/collapse_measure_`this_group'_primary_admission_imd_rate.csv
    * reshape dataset so columns with rates for each ethnicity 
    reshape wide value rate `this_group'_primary_admission population, i(dateA) j(imd)
    describe
    * Labelling ethnicity variables
    label var rate1 "IMD - 1"
    label var rate2 "IMD - 2"
    label var rate3 "IMD - 3"
    label var rate4 "IMD - 4"
    label var rate5 "IMD - 5"

    * Generate line graph
    graph twoway line rate1 rate2 rate3 rate4 rate5 date, tlabel(01Jan2018(180)01Jan2022, angle(45) ///
    format(%dM-CY) labsize(small)) ytitle("Rate per 100,000") xtitle("Date") ylabel(, labsize(small) ///
    angle(0)) yscale(titlegap(*10)) xmtick(##6) legend(row(1) size(small) title("IMD categories", size(small))) 

    graph export ./output/graphs/line_`this_group'_primary_admission_imd.svg, as(svg) replace

}
*/
/* Emergency admissions - small numbers for eating disorders and ocd so those not included
local groups "anxiety smi self_harm"
forvalues i=1/3 {
    local this_group :word `i' of `groups'
* Ethnicity
    clear 
    import delimited using ./output/measures/mh/measure_`this_group'_emergency_ethnicity_rate.csv, numericcols(4)
     * Shouldn't be missing on server but is in dummy data
    count if ethnicity==.
    * Drop missings as not required
    drop if ethnicity==0 | ethnicity==.
    * Generate rate per 100,000
    gen rate = value*100000 
    * Format date
    gen dateA = date(date, "YMD")
    drop date
    format dateA %dD/M/Y
    tab dateA 
    * reshape dataset so columns with rates for each ethnicity 
    reshape wide value rate `this_group'_emergency population, i(dateA) j(ethnicity)
    describe
    * Labelling ethnicity variables
    label var rate1 "White"
    label var rate2 "Mixed"
    label var rate3 "Asian"
    label var rate4 "Black"
    label var rate5 "Other"

    * Generate line graph
    graph twoway line rate1 rate2 rate3 rate4 rate5 date, tlabel(01Jan2018(180)01Jan2022, angle(45) ///
    format(%dM-CY) labsize(small)) ytitle("Rate per 100,000") xtitle("Date") ylabel(, labsize(small) ///
    angle(0)) yscale(titlegap(*10)) xmtick(##6) legend(row(1) size(small) title("Ethnic categories", size(small))) 

    graph export ./output/graphs/line_`this_group'_emergency_ethnicity.svg, as(svg) replace
    * IMD
    clear 
    import delimited using ./output/measures/mh/measure_`this_group'_emergency_imd_rate.csv, numericcols(4)
    * IMD should not have missings as . on server but could be in dummy data
    count if imd==.
    * Drop missings
    drop if imd==. | imd==0
    * Generate rate per 100,000
    gen rate = value*100000 
    * Format date
    gen dateA = date(date, "YMD")
    drop date
    format dateA %dD/M/Y
    tab dateA 
    * reshape dataset so columns with rates for each ethnicity 
    reshape wide value rate `this_group'_emergency population, i(dateA) j(imd)
    describe
    * Labelling ethnicity variables
    label var rate1 "IMD - 1"
    label var rate2 "IMD - 2"
    label var rate3 "IMD - 3"
    label var rate4 "IMD - 4"
    label var rate5 "IMD - 5"

    * Generate line graph
    graph twoway line rate1 rate2 rate3 rate4 rate5 date, tlabel(01Jan2018(180)01Jan2022, angle(45) ///
    format(%dM-CY) labsize(small)) ytitle("Rate per 100,000") xtitle("Date") ylabel(, labsize(small) ///
    angle(0)) yscale(titlegap(*10)) xmtick(##6) legend(row(1) size(small) title("IMD categories", size(small))) 

    graph export ./output/graphs/line_`this_group'_emergency_imd.svg, as(svg) replace

}*/

/*local outcomes "systolic_bp"
local strata "monitoring exacerbation"
local other "review exacerbation"
forvalues i=1/2 {
    local this_outcome :word `i' of `outcomes'
    forvalues j=1/2 {
        local this_strata :word `j' of `strata'
        local this_other :word `j' of `other'
    * Ethnicity
    clear 
    import delimited using "./output/measures/measure_`this_outcome'_`this_strata'_ethnicity_rate.csv"
    * Generate rate per 100,000
    gen rate = value*100000 
    * Format date
    gen dateA = date(date, "YMD")
    drop date
    format dateA %dD/M/Y
    tab dateA 
    * reshape dataset so columns with rates for each ethnicity 
    reshape wide value rate has_`this_outcome' `this_outcome'_`this_other', i(dateA) j(ethnicity)
    describe
    * Labelling ethnicity variables
    label var rate1 "White"
    label var rate2 "Mixed"
    label var rate3 "Asian"
    label var rate4 "Black"
    label var rate5 "Other"

    * Generate line graph
    graph twoway line rate1 rate2 rate3 rate4 rate5 date, tlabel(01Jan2018(180)01Jan2022, angle(45) ///
    format(%dM-CY) labsize(small)) ytitle("Rate per 100,000") xtitle("Date") ylabel(, labsize(small) ///
    angle(0)) yscale(titlegap(*10)) xmtick(##6) legend(row(1) size(small) title("Ethnic categories", size(small))) 

    graph export ./output/graphs/line_resp_ethnic_`this_outcome'_`this_strata'.svg, as(svg) replace
    * IMD
    clear 
    import delimited using "./output/measures/resp/measure_`this_outcome'_`this_strata'_imd_rate.csv"
    * Generate rate per 100,000
    gen rate = value*100000 
    * Format date
    gen dateA = date(date, "YMD")
    drop date
    format dateA %dD/M/Y
    tab dateA 
    * reshape dataset so columns with rates for each ethnicity 
    reshape wide value rate has_`this_outcome' `this_outcome'_`this_other', i(dateA) j(imd)
    describe
    * Labelling ethnicity variables
    label var rate1 "IMD - 1"
    label var rate2 "IMD - 2"
    label var rate3 "IMD - 3"
    label var rate4 "IMD - 4"
    label var rate5 "IMD - 5"

    * Generate line graph
    graph twoway line rate1 rate2 rate3 rate4 rate5 date, tlabel(01Jan2018(180)01Jan2022, angle(45) ///
    format(%dM-CY) labsize(small)) ytitle("Rate per 100,000") xtitle("Date") ylabel(, labsize(small) ///
    angle(0)) yscale(titlegap(*10)) xmtick(##6) legend(row(1) size(small) title("IMD categories", size(small)))

    graph export ./output/graphs/line_resp_imd_`this_outcome'_`this_strata'.svg, as(svg) replace
    }
}
*/
*/
*/

log close