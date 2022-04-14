/* ===========================================================================
Do file name:   graphs_mortality.do
Project:        COVID Collateral
Date:           23/03/2022
Author:         Ruth Costello
Description:    Generates line graphs of rates of each outcome and strata per month
==============================================================================*/
cap log using ./logs/graphs_mortality.log, replace

* Generates graphs for ethnicity - to include DM once defined
local groups "resp asthma copd cvd mi stroke heart_failure vte mh keto"
forvalues i=1/9 {
    local this_group :word `i' of `groups'
* Ethnicity
    clear 
    import delimited using ./output/measures/mortality/measure_`this_group'_mortality_ethnic_rate.csv, numericcols(4)
    * Generate rate per 100,000
    gen rate = value*100000 
    * Format date
    gen dateA = date(date, "YMD")
    drop date
    format dateA %dD/M/Y
    tab dateA 
    * Collapse at 3 monthly intervals
    gen quarter = qofd(dateA)
    collapse (sum) value rate population `this_group'_mortality (min) dateA,  by(quarter ethnicity)
    drop quarter
    * Outputing file 
    export delimited using ./output/measures/mortality/collapse_measure_`this_group'_mortality_ethnic_rate.csv 
    * reshape dataset so columns with rates for each ethnicity 
    reshape wide value rate `this_group'_mortality population, i(dateA) j(ethnicity)
    describe
    * Labelling ethnicity variables
    label var rate1 "Ethnicity - White"
    label var rate2 "Ethnicity - Mixed"
    label var rate3 "Ethnicity - Asian"
    label var rate4 "Ethnicity - Black"
    label var rate5 "Ethnicity - Other"

    * Generate line graph
    graph twoway line rate1 rate2 rate3 rate4 rate5 date, xlabel(, angle(45) format(%dM-CY)) ///
    ytitle("Rate per 100,000") 

    graph export ./output/line_mortality_`this_group'_ethnic.eps, as(eps) replace
    * IMD
    clear 
    import delimited using ./output/measures/mortality/measure_`this_group'_mortality_imd_rate.csv, numericcols(4)
    * Generate rate per 100,000
    gen rate = value*100000 
    * Format date
    gen dateA = date(date, "YMD")
    drop date
    format dateA %dD/M/Y
    tab dateA 
    * reshape dataset so columns with rates for each level of IMD
    reshape wide value rate `this_group'_mortality population, i(dateA) j(imd)
    describe
    * Labelling IMD variables
    label var rate1 "IMD - 1"
    label var rate2 "IMD - 2"
    label var rate3 "IMD - 3"
    label var rate4 "IMD - 4"
    label var rate5 "IMD - 5"

    * Generate line graph
    graph twoway line rate1 rate2 rate3 rate4 rate5 date, xlabel(, format(%dM-CY)) ///
    ytitle("Rate per 100,000") 
    * save graph
    graph export ./output/line_mortality_`this_group'_imd.eps, as(eps) replace
}

* Adding three monthly graphs for MH and asthma
* Generates graphs for ethnicity - to include DM once defined
local groups "asthma vte mh"
forvalues i=1/3 {
    local this_group :word `i' of `groups'
     * IMD
    clear 
    import delimited using ./output/measures/mortality/measure_`this_group'_mortality_imd_rate.csv, numericcols(4)
    * Generate rate per 100,000
    gen rate = value*100000 
    * Format date
    gen dateA = date(date, "YMD")
    drop date
    format dateA %dD/M/Y
    tab dateA 
    * Collapse at 3 monthly intervals
    gen quarter = qofd(dateA)
    collapse (sum) value rate population `this_group'_mortality (min) dateA,  by(quarter imd)
    drop quarter
    * Outputing file 
    export delimited using ./output/measures/mortality/collapse_measure_`this_group'_mortality_imd_rate.csv 
    * reshape dataset so columns with rates for each level of IMD
    reshape wide value rate `this_group'_mortality population, i(dateA) j(imd)
    describe
    * Labelling IMD variables
    label var rate1 "IMD - 1"
    label var rate2 "IMD - 2"
    label var rate3 "IMD - 3"
    label var rate4 "IMD - 4"
    label var rate5 "IMD - 5"

    * Generate line graph
    graph twoway line rate1 rate2 rate3 rate4 rate5 date, xlabel(, format(%dM-CY)) ///
    ytitle("Rate per 100,000") 
    * save graph
    graph export ./output/line_mortality_`this_group'_imd_collapse.eps, as(eps) replace
}