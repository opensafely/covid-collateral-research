/* ===========================================================================
Do file name:   graphs.do
Project:        COVID Collateral
Date:           07/03/2022
Author:         Ruth Costello
Description:    Generates line graphs of rates of each outcome and strata per month
==============================================================================*/
cap log using ./logs/check.log, replace

* Import each spreadhseet and create graph
foreach v in primary any emergency {
    * Ethnicity
    clear 
    import delimited using ./output/measures/measure_dm_`v'_ethnicity_rate.csv
    * Generate rate per 100,000
    gen rate = value*100000 
    * Format date
    gen dateA = date(date, "YMD")
    drop date
    format dateA %dD/M/Y
    tab dateA 
    * reshape dataset so columns with rates for each ethnicity 
    reshape wide value rate population dm_admission_`v', i(dateA) j(ethnicity)
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

    graph export ./output/line_ethnic_dm_`v'.eps, as(eps) replace
    * IMD
    clear 
    import delimited using ./output/measures/measure_dm_`v'_imd_rate.csv
    * Generate rate per 100,000
    gen rate = value*100000 
    * Format date
    gen dateA = date(date, "YMD")
    drop date
    format dateA %dD/M/Y
    tab dateA 
    * reshape dataset so columns with rates for each ethnicity 
    reshape wide value rate population dm_admission_`v', i(dateA) j(imd)
    describe
    * Labelling ethnicity variables
    label var rate1 "IMD - 1"
    label var rate2 "IMD - 2"
    label var rate3 "IMD - 3"
    label var rate4 "IMD - 4"
    label var rate5 "IMD - 5"

    * Generate line graph
    graph twoway line rate1 rate2 rate3 rate4 rate5 date, xlabel(, format(%dM-CY)) ///
    ytitle("Rate per 100,000") 

    graph export ./output/line_imd_dm_`v'.eps, as(eps) replace

}

log close
