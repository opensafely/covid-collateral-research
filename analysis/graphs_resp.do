/* ===========================================================================
Do file name:   graphs_resp.do
Project:        COVID Collateral
Date:           10/03/2022
Author:         Ruth Costello
Description:    Generates line graphs of rates of each outcome and strata per month
==============================================================================*/
cap log using ./logs/graphs_resp.log, replace

* Generates graphs for clinical monitoring measures
local outcomes "asthma copd"
local strata "monitoring exacerbation"
local other "review exacerbation"
forvalues i=1/2 {
    local this_outcome :word `i' of `outcomes'
    forvalues j=1/2 {
        local this_strata :word `j' of `strata'
        local this_other :word `j' of `other'
    * Ethnicity
    clear 
    import delimited using "./output/measures/resp/measure_`this_outcome'_`this_strata'_ethnicity_rate.csv", numericcols(4)
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
    label var rate1 "Ethnicity - White"
    label var rate2 "Ethnicity - Mixed"
    label var rate3 "Ethnicity - Asian"
    label var rate4 "Ethnicity - Black"
    label var rate5 "Ethnicity - Other"

    * Generate line graph
    graph twoway line rate1 rate2 rate3 rate4 rate5 dateA, xlabel(, angle(45) format(%dM-CY)) ///
    ytitle("Rate per 100,000") 

    graph export ./output/line_resp_ethnic_`this_outcome'_`this_strata'.eps, as(eps) replace
    * IMD
    clear 
    import delimited using "./output/measures/resp/measure_`this_outcome'_`this_strata'_imd_rate.csv", numericcols(4)
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
    graph twoway line rate1 rate2 rate3 rate4 rate5 dateA, xlabel(, format(%dM-CY)) ///
    ytitle("Rate per 100,000") 

    graph export ./output/line_resp_imd_`this_outcome'_`this_strata'.eps, as(eps) replace
    }
}