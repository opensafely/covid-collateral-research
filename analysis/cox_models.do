/* ===========================================================================
Do file name:   cox_models.do
Project:        COVID Collateral
Date:           17/05/2022
Author:         Ruth Costello
                    adapted from Rohini Mathur
Description:    Plots proportional hazards and runs Cox models
==============================================================================*/
*local dataset `1'
adopath + ./analysis/ado 
cap log using ./logs/cox_model_checks.log, replace
cap mkdir ./output/graphs
cap mkdir ./output/tempdata
cap mkdir ./output/tables
* Pre-pandemic
import delimited using ./output/survival/input_survival_pre.csv, clear
* First preparing dataset
* Drop variables that make up COPD hospitalisation as not required
drop copd_exacerbation_hospital copd_hospital lrti_hospital copd_any eth ethnicity_sus

* Assume deregistered on 1st of month
gen dereg_dateA = date(dereg_date, "YM")
format %dD/N/CY dereg_dateA
drop dereg_date

* Format dates
local a "mi_primary_admission stroke_primary_admission heart_failure_primary_admission vte_primary_admission t1dm_admission_primary t2dm_admission_primary dm_keto_admission_primary asthma_exacerbation depression_primary_admission anxiety_primary_admission smi_primary_admission self_harm_primary_admission cvd_admission_date dm_admission copd_hospitalisation_date mh_admission" 
local b "mi_admit_date stroke_admit_date hf_admit_date vte_admit_date t1dm_admit_date t2dm_admit_date dm_keto_admit_date asthma_admit_date depress_admit_date anx_admit_date smi_admit_date sh_admit_date cvd_admit_date dm_admit_date copd_admit_date mh_admit_date" 
forvalues i=1/16 {
    local c: word `i' of `a'
    local d: word `i' of `b' 
    count if `c'!=""   
    gen `d'=date(`c', "YMD")
    format %dD/N/CY `d'
    drop `c'
    }
* Define index date
gen index_date = date("01/03/2018", "DMY")
* Define end of follow-up
gen end_study = date("22/03/2020", "DMY")
format %dD/N/CY index_date end_study
egen end_date = rowmin(dereg_dateA end_study)
format %dD/N/CY end_date

* Reorder ethnicity - white, asian, black, mixed, other
*re-order ethnicity
 gen eth5=1 if ethnicity==1
 replace eth5=2 if ethnicity==3
 replace eth5=3 if ethnicity==4
 replace eth5=4 if ethnicity==2
 replace eth5=5 if ethnicity==5
 replace eth5=. if ethnicity==.

 label define eth5 			1 "White"  					///
							2 "South Asian"				///						
							3 "Black"  					///
							4 "Mixed"					///
							5 "Other"					
					

label values eth5 eth5
safetab eth5, m

* Make gender numeric
gen male = 1 if sex == "M"
replace male = 0 if sex == "F"
label define male 0"Female" 1"Male"
label values male male
safetab male, miss
drop sex

* Make region numeric
generate region2=.
replace region2=0 if region=="East"
replace region2=1 if region=="East Midlands"
replace region2=2 if region=="London"
replace region2=3 if region=="North East"
replace region2=4 if region=="North West"
replace region2=5 if region=="South East"
replace region2=6 if region=="South West"
replace region2=7 if region=="West Midlands"
replace region2=8 if region=="Yorkshire and The Humber"
drop region
rename region2 region
label var region "region of England"
label define region 0 "East" 1 "East Midlands"  2 "London" 3 "North East" 4 "North West" 5 "South East" 6 "South West" 7 "West Midlands" 8 "Yorkshire and The Humber"
label values region region
safetab region, miss

*create a 4 category rural urban variable 
generate urban_rural_5=.
la var urban_rural_5 "Rural Urban in five categories"
replace urban_rural_5=1 if urban_rural==1
replace urban_rural_5=2 if urban_rural==2
replace urban_rural_5=3 if urban_rural==3|urban_rural==4
replace urban_rural_5=4 if urban_rural==5|urban_rural==6
replace urban_rural_5=5 if urban_rural==7|urban_rural==8
label define urban_rural_5 1 "Urban major conurbation" 2 "Urban minor conurbation" 3 "Urban city and town" 4 "Rural town and fringe" 5 "Rural village and dispersed"
label values urban_rural_5 urban_rural_5
safetab urban_rural_5, miss

*generate a binary rural urban (with missing assigned to urban)
generate urban_rural_bin=.
replace urban_rural_bin=1 if urban_rural<=4|urban_rural==.
replace urban_rural_bin=0 if urban_rural>4 & urban_rural!=.
label define urban_rural_bin 0 "Rural" 1 "Urban"
label values urban_rural_bin urban_rural_bin
safetab urban_rural_bin urban_rural, miss
label var urban_rural_bin "Rural-Urban"

* Define age categories
* Create age categories
egen age_cat = cut(age), at(18, 40, 60, 80, 120) icodes
label define age 0 "18 - 40 years" 1 "41 - 60 years" 2 "61 - 80 years" 3 ">80 years"
label values age_cat age
safetab age_cat, miss

* open file to write results to
file open tablecontent using ./output/tables/cox_models.txt, write text replace
file write tablecontent ("Association between ethnicity and outcomes pre-pandemic") _n
file write tablecontent _tab ("Denominator") _tab ("Event") _tab ("Total person-weeks") _tab ("Rate per 1,000") _tab ("Crude") _tab _tab ("Age/Sex Adjusted") _tab _tab ("Fully Adjusted") _tab _tab  _n
file write tablecontent _tab _tab _tab _tab _tab   ("HR") _tab ("95% CI") _tab ("HR") _tab ("95% CI") _tab ("HR") _tab ("95% CI") _tab _tab  _n

foreach sub in cvd dm copd mh mi stroke hf vte t1dm t2dm dm_keto asthma depress anx smi sh  {
    * Cox model for each outcome category
    * Generate flags and end dates for each outcome
    gen `sub'_admit=(`sub'_admit_date!=.)
    tab `sub'_admit
    count if `sub'_admit_date==.
    gen `sub'_end = end_date
    replace `sub'_end = `sub'_admit_date if `sub'_admit==1

    stset `sub'_end, fail(`sub'_admit) id(patient_id) enter(index_date) origin(index_date) scale(365.25) 
    * Kaplan-Meier plot
    sts graph, by(eth5)
    graph export ./output/graphs/km_`sub'_pre_eth.svg, as(svg) replace
    * Cox model - crude
    stcox i.eth5
    estimates save "./output/tempdata/crude_`sub'_eth", replace 
    eststo model1
    parmest, label eform format(estimate p lb ub) saving("./output/tempdata/surv_crude_`sub'_eth16", replace) idstr("crude_`sub'_eth") 
    estat phtest, detail
    * Cox model - age and gender adjusted
    stcox i.eth5 i.age_cat i.male
    estimates save "./output/tempdata/model1_`sub'_eth", replace 
    eststo model2
    parmest, label eform format(estimate p lb ub) saving("./output/tempdata/surv_model1_`sub'_eth", replace) idstr("model1_`sub'_eth") 
    estat phtest, detail
    * Cox model - fully adjusted
    stcox i.eth5 i.age_cat i.male i.urban_rural_bin i.imd i.shielded
    estimates save "./output/tempdata/model2_`sub'_eth", replace 
    eststo model3
    parmest, label eform format(estimate p lb ub) saving("./output/tempdata/surv_model2_`sub'_eth", replace) idstr("model2_`sub'_eth") 
    estat phtest, detail
    esttab model1 model2 model3 using "./output/tables/estout_table_eth_.txt", b(a2) ci(2) label wide compress eform ///
	title ("`sub'") ///
	varlabels(`e(labels)') ///
	stats(N_sub) ///
	append 
    eststo clear
   * Write results to table
    * Column headings 
    file write tablecontent ("`sub'") _n

    * eth16 labelled columns

    local lab1: label eth5 1
    local lab2: label eth5 2
    local lab3: label eth5 3
    local lab4: label eth5 4
    local lab5: label eth5 5
    /* counts */
    
    * First row, eth16 = 1 (White British) reference cat
    qui safecount if eth5==1
    local denominator = r(N)
    qui safecount if eth5 == 1 & `sub'_admit == 1
    local event = r(N)
    bysort eth5: egen total_follow_up = total(_t)
    qui su total_follow_up if eth5 == 1
    local person_week = r(mean)/7
    local rate = 1000*(`event'/`person_week')
    
    file write tablecontent  ("`lab1'") _tab (`denominator') _tab (`event') _tab %10.0f (`person_week') _tab %3.2f (`rate') _tab
    file write tablecontent ("1.00") _tab _tab ("1.00") _tab _tab ("1.00")  _tab _tab ("1.00") _tab _tab ("1.00") _n
    
    * Subsequent ethnic groups
    forvalues eth=2/5 {
        qui safecount if eth5==`eth'
        local denominator = r(N)
        qui safecount if eth5 == `eth' & `sub'_admit == 1
        local event = r(N)
        qui su total_follow_up if eth5 == `eth'
        local person_week = r(mean)/7
        local rate = 1000*(`event'/`person_week')
        file write tablecontent  ("`lab`eth''") _tab (`denominator') _tab (`event') _tab %10.0f (`person_week') _tab %3.2f (`rate') _tab  
        cap estimates use "./output/tempdata/crude_`sub'_eth" 
        cap lincom `eth'.eth5, eform
        file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _tab 
        cap estimates clear
        cap estimates use "./output/tempdata/model1_`sub'_eth" 
        cap lincom `eth'.eth5, eform
        file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _tab 
        cap estimates clear
        cap estimates use "./output/tempdata/model2_`sub'_eth" 
        cap lincom `eth'.eth5, eform
        file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _tab _n
        cap estimates clear
    }  //end ethnic group
drop total_follow_up

} //end outcomes


* Pandemic
import delimited using ./output/survival/input_survival_pandemic.csv, clear
* First preparing dataset
* Drop variables that make up COPD hospitalisation as not required
drop copd_exacerbation_hospital copd_hospital lrti_hospital copd_any eth ethnicity_sus

* Assume deregistered on 1st of month
gen dereg_dateA = date(dereg_date, "YM")
format %dD/N/CY dereg_dateA
drop dereg_date

* Format dates
local a "mi_primary_admission stroke_primary_admission heart_failure_primary_admission vte_primary_admission t1dm_admission_primary t2dm_admission_primary dm_keto_admission_primary asthma_exacerbation depression_primary_admission anxiety_primary_admission smi_primary_admission self_harm_primary_admission cvd_admission_date dm_admission copd_hospitalisation_date mh_admission" 
local b "mi_admit_date stroke_admit_date hf_admit_date vte_admit_date t1dm_admit_date t2dm_admit_date dm_keto_admit_date asthma_admit_date depress_admit_date anx_admit_date smi_admit_date sh_admit_date cvd_admit_date dm_admit_date copd_admit_date mh_admit_date" 
forvalues i=1/16 {
    local c: word `i' of `a'
    local d: word `i' of `b' 
    count if `c'!=""   
    gen `d'=date(`c', "YMD")
    format %dD/N/CY `d'
    drop `c'
    }
* Define index date
gen index_date = date("23/03/2020", "DMY")
* Define end of follow-up
gen end_study = date("30/04/2022", "DMY")
format %dD/N/CY index_date end_study
egen end_date = rowmin(dereg_dateA end_study)
format %dD/N/CY end_date

* Reorder ethnicity - white, asian, black, mixed, other
*re-order ethnicity
 gen eth5=1 if ethnicity==1
 replace eth5=2 if ethnicity==3
 replace eth5=3 if ethnicity==4
 replace eth5=4 if ethnicity==2
 replace eth5=5 if ethnicity==5
 replace eth5=. if ethnicity==.

 label define eth5 			1 "White"  					///
							2 "South Asian"				///						
							3 "Black"  					///
							4 "Mixed"					///
							5 "Other"					
					

label values eth5 eth5
safetab eth5, m

* Make gender numeric
gen male = 1 if sex == "M"
replace male = 0 if sex == "F"
label define male 0"Female" 1"Male"
label values male male
safetab male, miss
drop sex

* Make region numeric
generate region2=.
replace region2=0 if region=="East"
replace region2=1 if region=="East Midlands"
replace region2=2 if region=="London"
replace region2=3 if region=="North East"
replace region2=4 if region=="North West"
replace region2=5 if region=="South East"
replace region2=6 if region=="South West"
replace region2=7 if region=="West Midlands"
replace region2=8 if region=="Yorkshire and The Humber"
drop region
rename region2 region
label var region "region of England"
label define region 0 "East" 1 "East Midlands"  2 "London" 3 "North East" 4 "North West" 5 "South East" 6 "South West" 7 "West Midlands" 8 "Yorkshire and The Humber"
label values region region
safetab region, miss

*create a 4 category rural urban variable 
generate urban_rural_5=.
la var urban_rural_5 "Rural Urban in five categories"
replace urban_rural_5=1 if urban_rural==1
replace urban_rural_5=2 if urban_rural==2
replace urban_rural_5=3 if urban_rural==3|urban_rural==4
replace urban_rural_5=4 if urban_rural==5|urban_rural==6
replace urban_rural_5=5 if urban_rural==7|urban_rural==8
label define urban_rural_5 1 "Urban major conurbation" 2 "Urban minor conurbation" 3 "Urban city and town" 4 "Rural town and fringe" 5 "Rural village and dispersed"
label values urban_rural_5 urban_rural_5
safetab urban_rural_5, miss

*generate a binary rural urban (with missing assigned to urban)
generate urban_rural_bin=.
replace urban_rural_bin=1 if urban_rural<=4|urban_rural==.
replace urban_rural_bin=0 if urban_rural>4 & urban_rural!=.
label define urban_rural_bin 0 "Rural" 1 "Urban"
label values urban_rural_bin urban_rural_bin
safetab urban_rural_bin urban_rural, miss
label var urban_rural_bin "Rural-Urban"

* Define age categories
* Create age categories
egen age_cat = cut(age), at(18, 40, 60, 80, 120) icodes
label define age 0 "18 - 40 years" 1 "41 - 60 years" 2 "61 - 80 years" 3 ">80 years"
label values age_cat age
safetab age_cat, miss

* open file to write results to

file write tablecontent ("Association between ethnicity and outcomes pandemic") _n
file write tablecontent _tab ("Denominator") _tab ("Event") _tab ("Total person-weeks") _tab ("Rate per 1,000") _tab ("Crude") _tab _tab ("Age/Sex Adjusted") _tab _tab ("Fully Adjusted") _tab _tab  _n
file write tablecontent _tab _tab _tab _tab _tab   ("HR") _tab ("95% CI") _tab ("HR") _tab ("95% CI") _tab ("HR") _tab ("95% CI") _tab _tab  _n

foreach sub in cvd dm copd mh mi stroke hf vte t1dm t2dm dm_keto asthma depress anx smi sh {
    * Cox model for each outcome category
    * Generate flags and end dates for each outcome
    gen `sub'_admit=(`sub'_admit_date!=.)
    tab `sub'_admit
    count if `sub'_admit_date==.
    gen `sub'_end = end_date
    replace `sub'_end = `sub'_admit_date if `sub'_admit==1

    stset `sub'_end, fail(`sub'_admit) id(patient_id) enter(index_date) origin(index_date) scale(365.25) 
    * Kaplan-Meier plot
    sts graph, by(eth5)
    graph export ./output/graphs/km_`sub'_pan_eth.svg, as(svg) replace
    * Cox model - crude
    stcox i.eth5
    estimates save "./output/tempdata/crude_`sub'_eth", replace 
    eststo model1
    parmest, label eform format(estimate p lb ub) saving("./output/tempdata/surv_crude_`sub'_eth16", replace) idstr("crude_`sub'_eth") 
    estat phtest, detail
    * Cox model - age and gender adjusted
    stcox i.eth5 i.age_cat i.male
    estimates save "./output/tempdata/model1_`sub'_eth", replace 
    eststo model2
    parmest, label eform format(estimate p lb ub) saving("./output/tempdata/surv_model1_`sub'_eth", replace) idstr("model1_`sub'_eth") 
    estat phtest, detail
    * Cox model - fully adjusted
    stcox i.eth5 i.age_cat i.male i.urban_rural_bin i.imd i.shielded
    estimates save "./output/tempdata/model2_`sub'_eth", replace 
    eststo model3
    parmest, label eform format(estimate p lb ub) saving("./output/tempdata/surv_model2_`sub'_eth", replace) idstr("model2_`sub'_eth") 
    estat phtest, detail
    esttab model1 model2 model3 using "./output/tables/estout_table_eth_pan.txt", b(a2) ci(2) label wide compress eform ///
	title ("`sub'") ///
	varlabels(`e(labels)') ///
	stats(N_sub) ///
	append 
    eststo clear
   * Write results to table
    * Column headings 
    file write tablecontent ("`sub'") _n

    * eth16 labelled columns

    local lab1: label eth5 1
    local lab2: label eth5 2
    local lab3: label eth5 3
    local lab4: label eth5 4
    local lab5: label eth5 5
    /* counts */
    
    * First row, eth16 = 1 (White British) reference cat
    qui safecount if eth5==1
    local denominator = r(N)
    qui safecount if eth5 == 1 & `sub'_admit == 1
    local event = r(N)
    bysort eth5: egen total_follow_up = total(_t)
    qui su total_follow_up if eth5 == 1
    local person_week = r(mean)/7
    local rate = 1000*(`event'/`person_week')
    
    file write tablecontent  ("`lab1'") _tab (`denominator') _tab (`event') _tab %10.0f (`person_week') _tab %3.2f (`rate') _tab
    file write tablecontent ("1.00") _tab _tab ("1.00") _tab _tab ("1.00")  _tab _tab ("1.00") _tab _tab ("1.00") _n
    
    * Subsequent ethnic groups
    forvalues eth=2/5 {
        qui safecount if eth5==`eth'
        local denominator = r(N)
        qui safecount if eth5 == `eth' & `sub'_admit == 1
        local event = r(N)
        qui su total_follow_up if eth5 == `eth'
        local person_week = r(mean)/7
        local rate = 1000*(`event'/`person_week')
        file write tablecontent  ("`lab`eth''") _tab (`denominator') _tab (`event') _tab %10.0f (`person_week') _tab %3.2f (`rate') _tab  
        cap estimates use "./output/tempdata/crude_`sub'_eth" 
        cap lincom `eth'.eth5, eform
        file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _tab 
        cap estimates clear
        cap estimates use "./output/tempdata/model1_`sub'_eth" 
        cap lincom `eth'.eth5, eform
        file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _tab 
        cap estimates clear
        cap estimates use "./output/tempdata/model2_`sub'_eth" 
        cap lincom `eth'.eth5, eform
        file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _tab _n
        cap estimates clear
    }  //end ethnic group
drop total_follow_up

} //end outcomes

file close tablecontent


log close