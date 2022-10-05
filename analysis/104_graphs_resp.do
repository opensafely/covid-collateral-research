/* ===========================================================================
Do file name:   graphs_resp.do
Project:        COVID Collateral
Date:           10/03/2022
Author:         Ruth Costello
Description:    Generates line graphs of rates of each outcome and strata per month
==============================================================================*/
cap log using ./logs/graphs_resp.log, replace
cap mkdir ./output/collapsed
cap mkdir ./output/graphs

* Generates graphs for clinical monitoring measures
local outcomes "asthma copd"
local strata "monitoring /*exacerbation*/"
local other "review /*exacerbation*/"
forvalues i=1/2 {
    local this_outcome :word `i' of `outcomes'
    forvalues j=1/1 {
        local this_strata :word `j' of `strata'
        local this_other :word `j' of `other'
    * Ethnicity
    clear 
    import delimited using "./output/measures/resp/measure_`this_outcome'_`this_strata'_ethnicity_rate.csv", numericcols(4)
    * Take out measures where population is not within subgroup
    tab has_`this_outcome' 
    drop if has_`this_outcome'==0
    drop has_`this_outcome' 
    * Generate rate per 100,000
    gen rate = value*100000 
    * Format date
    gen dateA = date(date, "YMD")
    drop date
    format dateA %dD/M/Y
    tab dateA 
    * reshape dataset so columns with rates for each ethnicity 
    reshape wide value rate population `this_outcome'_`this_other', i(dateA) j(ethnicity)
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
    angle(0)) yscale(r(0) titlegap(*10)) xmtick(##6) legend(row(1) size(small) title("Ethnic categories", ///
    size(small))) graphregion(fcolor(white))


    graph export ./output/graphs/line_resp_ethnic_`this_outcome'_`this_strata'.svg, as(svg) replace
    * IMD
    clear 
    import delimited using "./output/measures/resp/measure_`this_outcome'_`this_strata'_imd_rate.csv", numericcols(4)
    * Take out measures where population is not within subgroup
    tab has_`this_outcome' 
    drop if has_`this_outcome'==0
    drop has_`this_outcome'  
    * Generate rate per 100,000
    gen rate = value*100000 
    * Format date
    gen dateA = date(date, "YMD")
    drop date
    format dateA %dD/M/Y
    tab dateA 
    * reshape dataset so columns with rates for each ethnicity 
    reshape wide value rate population `this_outcome'_`this_other', i(dateA) j(imd)
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
    angle(0)) yscale(range(0) titlegap(*10)) xmtick(##6) legend(row(1) size(small) ///
    title("IMD categories", size(small))) graphregion(fcolor(white))


    graph export ./output/graphs/line_resp_imd_`this_outcome'_`this_strata'.svg, as(svg) replace
    }
}

/* Adding three monthly intervals for asthma exacerbation for ethnicity
* Ethnicity
    clear 
    import delimited using "./output/measures/resp/measure_asthma_exacerbation_ethnicity_rate.csv", numericcols(4)
    * Generate rate per 100,000
    gen rate = value*100000 
    * Format date
    gen dateA = date(date, "YMD")
    drop date
    format dateA %dD/M/Y
    tab dateA 
    * Collapse at 3 monthly intervals
    gen quarter = qofd(dateA)
    collapse (sum) value rate has_asthma asthma_exacerbation (min) dateA,  by(quarter ethnicity)
    drop quarter
    * Outputing file 
    export delimited using ./output/measures/resp/collapse_measure_asthma_exacerbation_ethnicity_rate.csv 
    * reshape dataset so columns with rates for each ethnicity 
    reshape wide value rate has_asthma asthma_exacerbation, i(dateA) j(ethnicity)
    describe
    * Labelling ethnicity variables
    label var rate1 "White"
    label var rate2 "Mixed"
    label var rate3 "Asian"
    label var rate4 "Black"
    label var rate5 "Other"

    * Generate line graph
    graph twoway line rate1 rate2 rate3 rate4 rate5 dateA, xlabel(, angle(45) format(%dM-CY)) ///
    ytitle("Rate per 100,000") 

    graph export ./output/line_resp_ethnic_asthma_exacerbation_collapse.svg, as(svg) replace