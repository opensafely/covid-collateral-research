/* ===========================================================================
Do file name:   graphs_mortality.do
Project:        COVID Collateral
Date:           23/03/2022
Author:         Ruth Costello
Description:    Generates line graphs of rates of each outcome and strata per month
==============================================================================*/
cap log using ./logs/graphs_mortality.log, replace
cap mkdir ./output/collapsed
cap mkdir ./output/graphs

* Generates graphs for ethnicity - to include DM once defined
local a "resp asthma copd cvd mi stroke heart_failure vte mh keto"
forvalues i=1/9 {
    local b :word `i' of `a'
* Ethnicity
    clear 
    import delimited using ./output/measures/mortality/measure_`b'_mortality_ethnic_rate.csv, numericcols(4)
    * Generate rate per 100,000
    gen rate = value*100000 
    * Format date
    gen dateA = date(date, "YMD")
    drop date
    format dateA %dD/M/Y
    * Collapse at 3 monthly intervals
    gen quarter = qofd(dateA)
    format quarter %tq
    collapse (sum) value rate population `b'_mortality (min) dateA,  by(quarter ethnicity)
    * Outputing file 
    export delimited using "./output/measures/mortality/collapsed/collapse_measure_`b'_mortality_ethnic_rate.csv", replace 
    * reshape dataset so columns with rates for each ethnicity 
    reshape wide value rate `b'_mortality population, i(dateA) j(ethnicity)
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

    graph export "./output/graphs/line_mortality_`b'_ethnic.svg", as(svg) replace
    * IMD
    clear 
    import delimited using ./output/measures/mortality/measure_`b'_mortality_imd_rate.csv, numericcols(4)
    * Generate rate per 100,000
    gen rate = value*100000 
    * Format date
    gen dateA = date(date, "YMD")
    drop date
    format dateA %dD/M/Y
    tab dateA 
    * Collapse at 3 monthly intervals
    gen quarter = qofd(dateA)
    collapse (sum) value rate population `b'_mortality (min) dateA,  by(quarter imd)
    * Outputing file 
    export delimited using "./output/measures/mortality/collapsed/collapse_measure_`b'_mortality_imd_rate.csv", replace 
    * reshape dataset so columns with rates for each level of IMD
    reshape wide value rate `b'_mortality population, i(dateA) j(imd)
    describe
    * Labelling IMD variables
    label var rate1 "IMD - 1"
    label var rate2 "IMD - 2"
    label var rate3 "IMD - 3"
    label var rate4 "IMD - 4"
    label var rate5 "IMD - 5"

    * Generate line graph
    graph twoway line rate1 rate2 rate3 rate4 rate5 date, tlabel(01Jan2018(180)01Jan2022, angle(45) ///
    format(%dM-CY) labsize(small)) ytitle("Rate per 100,000") xtitle("Date") ylabel(, labsize(small) ///
    angle(0)) yscale(titlegap(*10)) xmtick(##6) legend(row(1) size(small) title("IMD categories", size(small)))
    * save graph
    graph export "./output/graphs/line_mortality_`b'_imd.svg", as(svg) replace
}