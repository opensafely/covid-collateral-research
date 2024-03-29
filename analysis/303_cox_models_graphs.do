/* ===========================================================================
Do file name:   cox_models_graphs.do
Project:        COVID Collateral
Date:           17/05/2022
Author:         Ruth Costello
                    adapted from Rohini Mathur
Description:    Plots proportional hazards and runs Cox models
==============================================================================*/
*local dataset `1'
adopath + ./analysis/ado 
cap log using ./logs/cox_model_graphs.log, replace
cap mkdir ./output/survival
cap mkdir ./output/tempdata
/* Pre-pandemic
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

foreach sub in cvd dm copd mh mi stroke hf vte t1dm t2dm dm_keto asthma depress anx smi sh {
    * Cox model for each outcome category
    * Generate flags and end dates for each outcome
    gen `sub'_admit=(`sub'_admit_date!=.)
    tab `sub'_admit
    count if `sub'_admit_date==.
    gen `sub'_end = end_date
    replace `sub'_end = `sub'_admit_date if `sub'_admit==1

    stset `sub'_end, fail(`sub'_admit) id(patient_id) enter(index_date) origin(index_date) scale(365.25) 
    * Cox model - fully adjusted
    stcox i.eth5 i.age_cat i.male i.urban_rural_bin i.imd i.shielded
    * Create graph of HRs
    coefplot, keep(2.eth5 3.eth5 4.eth5 5.eth5) xline(1) eform xtitle("Hazard ratio") title("Pre-pandemic") graphregion(color(white)) name(`sub'_pre, replace)
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

foreach sub in cvd dm copd mh mi stroke hf vte t1dm t2dm dm_keto asthma depress anx smi sh {
    * Cox model for each outcome category
    * Generate flags and end dates for each outcome
    gen `sub'_admit=(`sub'_admit_date!=.)
    tab `sub'_admit
    count if `sub'_admit_date==.
    gen `sub'_end = end_date
    replace `sub'_end = `sub'_admit_date if `sub'_admit==1

    stset `sub'_end, fail(`sub'_admit) id(patient_id) enter(index_date) origin(index_date) scale(365.25) 
    * Cox model - fully adjusted
    stcox i.eth5 i.age_cat i.male i.urban_rural_bin i.imd i.shielded
    * Create graph of HRs
    coefplot, keep(2.eth5 3.eth5 4.eth5 5.eth5) xline(1) eform xtitle("Hazard ratio") title("Pandemic") graphregion(color(white)) name(`sub'_pan, replace)
} //end outcomes


* Combine pre and pandemic graphs
local var "cvd dm copd mh mi stroke hf vte t1dm t2dm dm_keto asthma depress anx smi sh"
local title "CVD-overall MI Stroke Heart-failure VTE Diabetes(T1) Diabetes(T2) DKA Asthma Depression Anxiety Serious_mental_illess Self-harm "
forvalues i=1/16 {
    local sub: word `i' of `var'
    local name: word `i' of `title'
    graph combine `sub'_pre `sub'_pan, graphregion(color(white)) title(`name')
    graph export ./output/survival/estimates_combine_`sub'.svg, as(svg) replace
}
*/
foreach period in pre pandemic {
use ./output/prep_survival_`period', clear
    describe
    * Drop events that occur on index date
    replace t1dm_admit_date=. if t1dm_admit_date==index_date

    * Update study population for diabetes outcomes
    preserve
    drop if has_t1_diabetes==0

    * Cox model for each outcome category
    * Generate flags and end dates for each outcome
    gen t1dm_admit=(t1dm_admit_date!=.)
    tab t1dm_admit
    count if t1dm_admit_date!=.
    
    gen t1dm_end = end_date
    replace t1dm_end = t1dm_admit_date if t1dm_admit==1

    stset t1dm_end, fail(t1dm_admit) id(patient_id) enter(index_date) origin(index_date) 

    bys t1dm_end eth5: egen t1dm_tot_events_date = total(_d)
    bys t1dm_end eth5: gen t1dm_tot_end = _N 

    bys eth5: sum t1dm_tot_events_date, d
    bys eth5: sum t1dm_tot_end, d
    count if t1dm_tot_events_date<=5
    count if t1dm_tot_end<=5

    restore 

    replace anx_admit_date=. if anx_admit_date==index_date

        
    * Cox model for each outcome category
    * Generate flags and end dates for each outcome
    gen anx_admit=(anx_admit_date!=.)
    tab anx_admit
    count if `outcome'_admit_date!=.
    gen anx_end = end_date
    replace anx_end = anx_admit_date if anx_admit==1
    stset anx_end, fail(anx_admit) id(patient_id) enter(index_date) origin(index_date) 
            
    bys anx_end eth5: egen anx_tot_events_date = total(_d)
    bys anx_end eth5: gen anx_tot_end = _N 

    bys eth5: sum anx_tot_events_date, d
    bys eth5: sum anx_tot_end, d
    count if anx_tot_events_date<=5
    count if anx_tot_end<=5

}

log close