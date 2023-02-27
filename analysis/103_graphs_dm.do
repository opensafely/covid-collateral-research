/* ===========================================================================
Do file name:   graphs.do
Project:        COVID Collateral
Date:           07/03/2022
Author:         Ruth Costello
Description:    Generates line graphs of rates of each outcome and strata per month
==============================================================================*/
cap log using ./logs/graphs_dm.log, replace
cap mkdir ./output/collapsed
cap mkdir ./output/graphs

* Generates graphs for clinical monitoring measures
foreach v in hba1c systolic_bp bp_meas {
    * Ethnicity
    clear 
    import delimited using ./output/measures/dm/measure_dm_`v'_ethnicity_rate.csv, numericcols(4)
    * Generate rate per 100,000
    gen rate = value*100000 
    * Format date
    gen dateA = date(date, "YMD")
    drop date
    format dateA %dD/M/Y
    tab dateA 
    * reshape dataset so columns with rates for each ethnicity 
    reshape wide value rate population `v', i(dateA) j(ethnicity)
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
 

    graph export ./output/graphs/line_dm_ethnic_`v'.svg, as(svg) replace 

    * Reviewer comments plotting first derivative i.e. difference between current rate and previous months rate
    forvalues i=1/5 {
        sort dateA
        gen first_derivative`i' = rate`i' - rate`i'[_n-1]
        }
    * Label variables 
    label var first_derivative1 "White"
    label var first_derivative2 "Mixed"
    label var first_derivative3 "Asian"
    label var first_derivative4 "Black"
    label var first_derivative5 "Other"
    * Plot this
    graph twoway line first_derivative1 first_derivative2 first_derivative3 first_derivative4 first_derivative5 date, tlabel(01Jan2018(120)01Apr2022, angle(45) ///
    format(%dM-CY) labsize(small)) ytitle("Difference per 100,000") xtitle("Date") ylabel(#5, labsize(small) ///
    angle(0)) yscale(r(0) titlegap(*10)) xmtick(##6) legend(row(1) size(small) ///
    title("Ethnic categories", size(small))) graphregion(fcolor(white))

    graph export ./output/graphs/line_dm_`v'_diff_ethnic.svg, as(svg) replace
    /* IMD
    clear 
    import delimited using ./output/measures/dm/measure_dm_`v'_imd_rate.csv, numericcols(4)
    * Generate rate per 100,000
    gen rate = value*100000 
    * Format date
    gen dateA = date(date, "YMD")
    drop date
    format dateA %dD/M/Y
    tab dateA 
    * reshape dataset so columns with rates for each ethnicity 
    reshape wide value rate population `v', i(dateA) j(imd)
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
    angle(0)) yscale(r(0) titlegap(*10)) xmtick(##6) legend(row(1) size(small) title("IMD categories", size(small))) ///
    graphregion(fcolor(white))


    graph export ./output/graphs/line_dm_imd_`v'.svg, as(svg) replace
    */
}
/* Generates graphs for DM hospital admissions
foreach v in primary any /*emergency*/ {
    * Ethnicity - Type 1 DM
    clear 
    import delimited using ./output/measures/dm/measure_dm_t1_`v'_ethnicity_rate.csv, numericcols(4)
    * Generate rate per 100,000
    gen rate = value*100000 
    * Format date
    gen dateA = date(date, "YMD")
    drop date
    format dateA %dD/M/Y
    tab dateA 
    * Collapse at 3 monthly intervals
    gen quarter = qofd(dateA)
    collapse (sum) value rate has_t1_diabetes t1dm_admission_`v' (min) dateA,  by(quarter ethnicity)
    drop quarter
    * Outputing file 
    export delimited using ./output/collapsed/collapse_measure_dm_t1_`v'_ethnicity_rate.csv
    * reshape dataset so columns with rates for each ethnicity 
    reshape wide value rate has_t1_diabetes t1dm_admission_`v', i(dateA) j(ethnicity)
    describe
    * Labelling ethnicity variables
    label var rate1 "White"
    label var rate2 "Mixed"
    label var rate3 "Asian"
    label var rate4 "Black"
    label var rate5 "Other"

    * Generate line graph
    graph twoway line rate1 rate2 rate3 rate4 rate5 date, tlabel(01Jan2018(120)01Apr2022, angle(45) ///
    format(%dM-CY) labsize(small)) ytitle("Rate per 100,000") xtitle("Date") ylabel(, labsize(small) ///
    angle(0)) yscale(r(0) titlegap(*10)) xmtick(##6) legend(row(1) size(small) title("Ethnic categories", size(small)))


    graph export ./output/graphs/line_dm_ethnic_t1_`v'.svg, as(svg) replace
    
    * IMD - type 1 DM
    clear 
    import delimited using ./output/measures/dm/measure_dm_t1_`v'_imd_rate.csv, numericcols(4)
    * Generate rate per 100,000
    gen rate = value*100000 
    * Format date
    gen dateA = date(date, "YMD")
    drop date
    format dateA %dD/M/Y
    tab dateA 
    * reshape dataset so columns with rates for each ethnicity 
    reshape wide value rate has_t1_diabetes t1dm_admission_`v', i(dateA) j(imd)
    describe
    * Labelling ethnicity variables
    label var rate1 "IMD - 1"
    label var rate2 "IMD - 2"
    label var rate3 "IMD - 3"
    label var rate4 "IMD - 4"
    label var rate5 "IMD - 5"

    * Generate line graph
    graph twoway line rate1 rate2 rate3 rate4 rate5 date, tlabel(01Jan2018(120)01Apr2022, angle(45) ///
    format(%dM-CY) labsize(small)) ytitle("Rate per 100,000") xtitle("Date") ylabel(, labsize(small) ///
    angle(0)) yscale(titlegap(*10)) xmtick(##6) legend(row(1) size(small) title("IMD categories", size(small)))


    graph export ./output/graphs/line_dm_imd_t1_`v'.svg, as(svg) replace

    * Ethnicity - Type 2 DM
    clear 
    import delimited using ./output/measures/dm/measure_dm_t2_`v'_ethnicity_rate.csv
    * Generate rate per 100,000
    gen rate = value*100000 
    * Format date
    gen dateA = date(date, "YMD")
    drop date
    format dateA %dD/M/Y
    tab dateA
    * Collapse at 3 monthly intervals
    gen quarter = qofd(dateA)
    collapse (sum) value rate has_t2_diabetes t2dm_admission_`v' (min) dateA,  by(quarter ethnicity)
    drop quarter
    * Outputing file 
    export delimited using ./output/collapsed/collapse_measure_dm_t2_`v'_ethnicity_rate.csv 
    * reshape dataset so columns with rates for each ethnicity 
    reshape wide value rate has_t2_diabetes t2dm_admission_`v', i(dateA) j(ethnicity)
    describe
    * Labelling ethnicity variables
    label var rate1 "White"
    label var rate2 "Mixed"
    label var rate3 "Asian"
    label var rate4 "Black"
    label var rate5 "Other"

    * Generate line graph
    graph twoway line rate1 rate2 rate3 rate4 rate5 date, tlabel(01Jan2018(120)01Apr2022, angle(45) ///
    format(%dM-CY) labsize(small)) ytitle("Rate per 100,000") xtitle("Date") ylabel(, labsize(small) ///
    angle(0)) yscale(titlegap(*10)) xmtick(##6) legend(row(1) size(small) title("Ethnic categories", size(small)))
 

    graph export ./output/graphs/line_dm_ethnic_t2_`v'.svg, as(svg) replace
    * IMD - type 2 DM
    clear 
    import delimited using ./output/measures/dm/measure_dm_t2_`v'_imd_rate.csv
    * Generate rate per 100,000
    gen rate = value*100000 
    * Format date
    gen dateA = date(date, "YMD")
    drop date
    format dateA %dD/M/Y
    tab dateA 
    * reshape dataset so columns with rates for each ethnicity 
    reshape wide value rate has_t2_diabetes t2dm_admission_`v', i(dateA) j(imd)
    describe
    * Labelling ethnicity variables
    label var rate1 "IMD - 1"
    label var rate2 "IMD - 2"
    label var rate3 "IMD - 3"
    label var rate4 "IMD - 4"
    label var rate5 "IMD - 5"

    * Generate line graph
    graph twoway line rate1 rate2 rate3 rate4 rate5 date, tlabel(01Jan2018(120)01Apr2022, angle(45) ///
    format(%dM-CY) labsize(small)) ytitle("Rate per 100,000") xtitle("Date") ylabel(, labsize(small) ///
    angle(0)) yscale(titlegap(*10)) xmtick(##6) legend(row(1) size(small) title("IMD categories", size(small)))

    graph export ./output/graphs/line_dm_imd_t2_`v'.svg, as(svg) replace

    /* Ethnicity - Ketoacidosis
    clear 
    import delimited using ./output/measures/dm/measure_dm_keto_`v'_ethnicity_rate.csv
    * Generate rate per 100,000
    gen rate = value*100000 
    * Format date
    gen dateA = date(date, "YMD")
    drop date
    format dateA %dD/M/Y
    tab dateA 
    * Collapse at 3 monthly intervals
    gen quarter = qofd(dateA)
    collapse (sum) value rate population dm_keto_admission_`v' (min) dateA,  by(quarter ethnicity)
    drop quarter
    * Outputing file 
    export delimited using ./output/collapsed/collapse_measure_dm_keto_`v'_ethnicity_rate.csv
    * reshape dataset so columns with rates for each ethnicity 
    reshape wide value rate population dm_keto_admission_`v', i(dateA) j(ethnicity)
    describe
    * Labelling ethnicity variables
    label var rate1 "White"
    label var rate2 "Mixed"
    label var rate3 "Asian"
    label var rate4 "Black"
    label var rate5 "Other"

    * Generate line graph
    graph twoway line rate1 rate2 rate3 rate4 rate5 date, tlabel(01Jan2018(120)01Apr2022, angle(45) ///
    format(%dM-CY) labsize(small)) ytitle("Rate per 100,000") xtitle("Date") ylabel(, labsize(small) ///
    angle(0)) yscale(titlegap(*10)) xmtick(##6) legend(row(1) size(small) title("Ethnic categories", size(small)))
 

    graph export ./output/graphs/line_dm_ethnic_keto_`v'.svg, as(svg) replace
    
    * IMD - type 1 DM
    clear 
    import delimited using ./output/measures/dm/measure_dm_keto_`v'_imd_rate.csv
    * Generate rate per 100,000
    gen rate = value*100000 
    * Format date
    gen dateA = date(date, "YMD")
    drop date
    format dateA %dD/M/Y
    tab dateA 
    * reshape dataset so columns with rates for each ethnicity 
    reshape wide value rate population dm_keto_admission_`v', i(dateA) j(imd)
    describe
    * Labelling ethnicity variables
    label var rate1 "IMD - 1"
    label var rate2 "IMD - 2"
    label var rate3 "IMD - 3"
    label var rate4 "IMD - 4"
    label var rate5 "IMD - 5"

    * Generate line graph
    graph twoway line rate1 rate2 rate3 rate4 rate5 date, tlabel(01Jan2018(120)01Apr2022, angle(45) ///
    format(%dM-CY) labsize(small)) ytitle("Rate per 100,000") xtitle("Date") ylabel(, labsize(small) ///
    angle(0)) yscale(titlegap(*10)) xmtick(##6) legend(row(1) size(small) title("IMD categories", size(small)))


    graph export ./output/graphs/line_dm_imd_keto_`v'.svg, as(svg) replace

}
*/
log close
