/* ===========================================================================
Do file name:   graphs_mh_cvd.do
Project:        COVID Collateral
Date:           21/03/2022
Author:         Ruth Costello
Description:    Generates line graphs of rates of each outcome and strata per month
==============================================================================*/
cap log using ./logs/graphs_mh_cvd.log, replace

* Generates graphs for clinical monitoring measures
foreach this_group in cvd mh {
    foreach strata in ethnicity imd {
* Ethnicity
        import delimited using ./output/measures/measure_systolic_bp_`this_group'_ethnicity_rate.csv, numericcols(4) clear
        * Generate rate per 100,000
        gen rate = value*100000 
        * Format date
        gen dateA = date(date, "YMD")
        drop date
        format dateA %dD/M/Y
        tab dateA 
        * reshape dataset so columns with rates for each ethnicity 
        reshape wide value rate `this_group'_group systolic_bp, i(dateA) j(ethnicity)
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

        graph export ./output/line_bp_`this_group'_ethnic.eps, as(eps) replace
    * IMD
    clear 
    import delimited using ./output/measures/measure_systolic_bp_`this_group'_imd_rate.csv, numericcols(4)
    * Generate rate per 100,000
    gen rate = value*100000 
    * Format date
    gen dateA = date(date, "YMD")
    drop date
    format dateA %dD/M/Y
    tab dateA 
    * reshape dataset so columns with rates for each ethnicity 
    reshape wide value rate `this_group'_group systolic_bp, i(dateA) j(imd)
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

    graph export ./output/line_bp_`this_group'_imd.eps, as(eps) replace
    }
}
* Hospital admission graphs
local groups "mi stroke heart_failure vte depression anxiety smi self_harm eating_dis ocd"
forvalues i=1/10 {
    local this_group :word `i' of `groups'
* Ethnicity
    clear 
    import delimited using ./output/measures/measure_`this_group'_admission_ethnicity_rate.csv, numericcols(4)
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
    label var rate1 "Ethnicity - White"
    label var rate2 "Ethnicity - Mixed"
    label var rate3 "Ethnicity - Asian"
    label var rate4 "Ethnicity - Black"
    label var rate5 "Ethnicity - Other"

    * Generate line graph
    graph twoway line rate1 rate2 rate3 rate4 rate5 date, xlabel(, angle(45) format(%dM-CY)) ///
    ytitle("Rate per 100,000") 

    graph export ./output/line_`this_group'_admission_ethnicity.eps, as(eps) replace
    * IMD
    clear 
    import delimited using ./output/measures/measure_`this_group'_admission_imd_rate.csv, numericcols(4)
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
    graph twoway line rate1 rate2 rate3 rate4 rate5 date, xlabel(, format(%dM-CY)) ///
    ytitle("Rate per 100,000") 

    graph export ./output/line_`this_group'_admission_imd.eps, as(eps) replace

}
* Hospital admissions - primary diagnosis
local groups "mi stroke heart_failure vte"
forvalues i=1/4 {
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
    * reshape dataset so columns with rates for each ethnicity 
    reshape wide value rate `this_group'_primary_admission population, i(dateA) j(ethnicity)
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

    graph export ./output/line_`this_group'_primary_admission_ethnicity.eps, as(eps) replace
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
    graph twoway line rate1 rate2 rate3 rate4 rate5 date, xlabel(, format(%dM-CY)) ///
    ytitle("Rate per 100,000") 

    graph export ./output/line_`this_group'_primary_admission_imd.eps, as(eps) replace

}
* Mental health measures - 3 monthly rates for primary admissions
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
    export delimited using ./output/measures/collapse_measure_`this_group'_primary_admission_ethnicity_rate.csv
    * reshape dataset so columns with rates for each ethnicity 
    reshape wide value rate `this_group'_primary_admission population, i(dateA) j(ethnicity)
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

    graph export ./output/line_`this_group'_primary_admission_ethnicity.eps, as(eps) replace
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
    export delimited using ./output/measures/collapse_measure_`this_group'_primary_admission_imd_rate.csv
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
    graph twoway line rate1 rate2 rate3 rate4 rate5 date, xlabel(, format(%dM-CY)) ///
    ytitle("Rate per 100,000") 

    graph export ./output/line_`this_group'_primary_admission_imd.eps, as(eps) replace

}

* Emergency admissions - collapsed to 3 monthly
local groups "anxiety smi self_harm eating_dis ocd"
forvalues i=1/5 {
    local this_group :word `i' of `groups'
* Ethnicity
    clear 
    import delimited using ./output/measures/measure_`this_group'_emergency_ethnicity_rate.csv, numericcols(4)
    * Generate rate per 100,000
    gen rate = value*100000 
    * Format date
    gen dateA = date(date, "YMD")
    drop date
    format dateA %dD/M/Y
    tab dateA 
    * Collapse at 3 monthly intervals
    gen quarter = qofd(dateA)
    collapse (sum) value rate `this_group'_emergency population (min) dateA,  by(quarter ethnicity)
    drop quarter
    * Outputing file 
    export delimited using ./output/measures/collapse_measure_`this_group'_emergency_ethnicity_rate.csv
    * reshape dataset so columns with rates for each ethnicity 
    reshape wide value rate `this_group'_emergency population, i(dateA) j(ethnicity)
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

    graph export ./output/line_`this_group'_emergency_ethnicity.eps, as(eps) replace
    * IMD
    clear 
    import delimited using ./output/measures/measure_`this_group'_emergency_imd_rate.csv, numericcols(4)
    * Generate rate per 100,000
    gen rate = value*100000 
    * Format date
    gen dateA = date(date, "YMD")
    drop date
    format dateA %dD/M/Y
    tab dateA 
    * Collapse at 3 monthly intervals
    gen quarter = qofd(dateA)
    collapse (sum) value rate `this_group'_emergency population (min) dateA,  by(quarter imd)
    drop quarter
    * Outputing file 
    export delimited using ./output/measures/collapse_measure_`this_group'_emergency_imd_rate.csv
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
    graph twoway line rate1 rate2 rate3 rate4 rate5 date, xlabel(, format(%dM-CY)) ///
    ytitle("Rate per 100,000") 

    graph export ./output/line_`this_group'_emergency_imd.eps, as(eps) replace

}

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
    graph twoway line rate1 rate2 rate3 rate4 rate5 dateA, xlabel(, format(%dM-CY)) ///
    ytitle("Rate per 100,000") 

    graph export ./output/line_resp_imd_`this_outcome'_`this_strata'.eps, as(eps) replace
    }
}