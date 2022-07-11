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
cap log using ./logs/cox_model_prep.log, replace

* Prepare datasets
foreach period in pre pandemic wave1 easing1 wave2 easing2 wave3 easing3 {
    import delimited using ./output/survival/input_survival_`period'.csv, clear stringcols(3/18 36 37 38 39)
    * First preparing dataset
    * Drop variables that make up COPD hospitalisation as not required
    drop copd_exacerbation_hospital copd_hospital lrti_hospital copd_any eth ethnicity_sus

    * Assume deregistered on 1st of month
    gen dereg_dateA = date(dereg_date, "YMD")
    format %dD/N/CY dereg_dateA
    drop dereg_date

    * Format dates
    local a "mi_primary_admission stroke_primary_admission heart_failure_primary_admission vte_primary_admission t1dm_admission_primary t2dm_admission_primary dm_keto_admission_primary asthma_exacerbation depression_primary_admission anxiety_primary_admission smi_primary_admission cvd_admission_date dm_admission copd_hospitalisation_date mh_admission died_fu" 
    local b "mi_admit_date stroke_admit_date hf_admit_date vte_admit_date t1dm_admit_date t2dm_admit_date dm_keto_admit_date asthma_admit_date depress_admit_date anx_admit_date smi_admit_date cvd_admit_date dm_admit_date copd_admit_date mh_admit_date date_died" 
    forvalues i=1/16 {
        local c: word `i' of `a'
        local d: word `i' of `b' 
        di "number of missing values"
        count if `c'==""  
        gen `d'=date(`c', "YMD")
        format %dD/N/CY `d'
        drop `c'
        }
   
    if "`period'"=="pre" {
        * Define index date
        gen index_date = date("01/03/2018", "DMY")
        * Define end of follow-up
        gen end_study = date("22/03/2020", "DMY")
    }
        else if "`period'"=="pandemic" {
            * Define index date
            gen index_date = date("23/03/2020", "DMY")
            * Define end of follow-up
            gen end_study = date("30/04/2022", "DMY")
        }
           else if "`period'"=="wave1" {
            * Define index date
            gen index_date = date("23/03/2020", "DMY")
            * Define end of follow-up
            gen end_study = date("30/05/2020", "DMY")
            } 
                else if "`period'"=="easing1" {
                    * Define index date
                    gen index_date = date("31/05/2020", "DMY")
                    * Define end of follow-up
                    gen end_study = date("06/09/2020", "DMY")
                    } 
                    else if "`period'"=="wave2" {
                        * Define index date
                        gen index_date = date("07/09/2020", "DMY")
                        * Define end of follow-up
                        gen end_study = date("24/04/2021", "DMY")
                        } 
                        else if "`period'"=="easing2" {
                            * Define index date
                            gen index_date = date("25/04/2021", "DMY")
                            * Define end of follow-up
                            gen end_study = date("27/05/2021", "DMY")
                            } 
                            else if "`period'"=="wave3" {
                                * Define index date
                                gen index_date = date("28/05/2021", "DMY")
                                * Define end of follow-up
                                gen end_study = date("14/12/2021", "DMY")
                                } 
                                else if "`period'"=="easing3" {
                                    * Define index date
                                    gen index_date = date("15/12/2021", "DMY")
                                    * Define end of follow-up
                                    gen end_study = date("30/04/2022", "DMY")
                                    } 
        format %dD/N/CY index_date end_study
       list index_date in 1/5 
       list end_study in 1/5
        egen end_date = rowmin(dereg_dateA end_study date_died)
        format %dD/N/CY end_date
        di "Number where end date is prior to index"
        count if end_date<index_date

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

    save "./output/prep_survival_`period'", replace
}

