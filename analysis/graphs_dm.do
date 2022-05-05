/* ===========================================================================
Do file name:   graphs.do
Project:        COVID Collateral
Date:           07/03/2022
Author:         Ruth Costello
Description:    Generates line graphs of rates of each outcome and strata per month
==============================================================================*/
cap log using ./logs/graphs_dm.log, replace

* Generates graphs for clinical monitoring measures
foreach v in hba1c systolic_bp {
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
    label var rate1 "Ethnicity - White"
    label var rate2 "Ethnicity - Mixed"
    label var rate3 "Ethnicity - Asian"
    label var rate4 "Ethnicity - Black"
    label var rate5 "Ethnicity - Other"

    * Generate line graph
    graph twoway line rate1 rate2 rate3 rate4 rate5 date, xlabel(, angle(45) format(%dM-CY)) ///
    ytitle("Rate per 100,000") 

    graph export ./output/line_dm_ethnic_`v'.eps, as(eps) replace
    * IMD
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
    graph twoway line rate1 rate2 rate3 rate4 rate5 date, xlabel(, format(%dM-CY)) ///
    ytitle("Rate per 100,000") 

    graph export ./output/line_dm_imd_`v'.eps, as(eps) replace

}
* Generates graphs for DM hospital admissions
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
    export delimited using ./output/measures/dm/collapse_measure_dm_t1_`v'_ethnicity_rate.csv
    * reshape dataset so columns with rates for each ethnicity 
    reshape wide value rate has_t1_diabetes t1dm_admission_`v', i(dateA) j(ethnicity)
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

    graph export ./output/line_dm_ethnic_t1_`v'.eps, as(eps) replace
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
    graph twoway line rate1 rate2 rate3 rate4 rate5 date, xlabel(, format(%dM-CY)) ///
    ytitle("Rate per 100,000") 

    graph export ./output/line_dm_imd_t1_`v'.eps, as(eps) replace

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
    export delimited using ./output/measures/dm/collapse_measure_dm_t2_`v'_ethnicity_rate.csv 
    * reshape dataset so columns with rates for each ethnicity 
    reshape wide value rate has_t2_diabetes t2dm_admission_`v', i(dateA) j(ethnicity)
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

    graph export ./output/line_dm_ethnic_t2_`v'.eps, as(eps) replace
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
    graph twoway line rate1 rate2 rate3 rate4 rate5 date, xlabel(, format(%dM-CY)) ///
    ytitle("Rate per 100,000") 

    graph export ./output/line_dm_imd_t2_`v'.eps, as(eps) replace

    * Ethnicity - Ketoacidosis
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
    export delimited using ./output/measures/dm/collapse_measure_dm_keto_`v'_ethnicity_rate.csv
    * reshape dataset so columns with rates for each ethnicity 
    reshape wide value rate population dm_keto_admission_`v', i(dateA) j(ethnicity)
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

    graph export ./output/line_dm_ethnic_keto_`v'.eps, as(eps) replace
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
    graph twoway line rate1 rate2 rate3 rate4 rate5 date, xlabel(, format(%dM-CY)) ///
    ytitle("Rate per 100,000") 

    graph export ./output/line_dm_imd_keto_`v'.eps, as(eps) replace

}

log close
