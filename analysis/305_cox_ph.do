/* ===========================================================================
Do file name:   cox_models.do
Project:        COVID Collateral
Date:           04/05/2023
Author:         Ruth Costello
                    adapted from Rohini Mathur
Description:    Plots proportional hazards - separate from other script as only 
                required for one ethnicity reference group
==============================================================================*/
adopath + ./analysis/ado 
cap log using ./logs/cox_model_ph.log, replace
cap mkdir ./output/graphs

foreach outcome in stroke mi hf vte {
    foreach period in pre pandemic wave1 easing1 wave2 easing2 wave3 easing3 {
    use ./output/prep_survival_`period', clear
    describe
    * Drop events that occur on index date
    drop if `outcome'_admit_date==index_date

    * Update study population for diabetes and respiratory outcomes
  /*drop if has_t1_diabetes==0 & `outcome'== t1dm
    drop if has_t2_diabetes==0 & `outcome'== t2dm
    drop if diabetes_subgroup==0 & `outcome'== dm_keto
    drop if has_asthma==0 & `outcome'== asthma
    drop if has_copd==0 & `outcome'== copd*/

    * Cox model for each outcome category
    * Generate flags and end dates for each outcome
    gen `outcome'_admit=(`outcome'_admit_date!=.)
    tab `outcome'_admit
    count if `outcome'_admit_date!=.
    if r(N) > 10 {
            gen `outcome'_end = end_date
            replace `outcome'_end = `outcome'_admit_date if `outcome'_admit==1

            stset `outcome'_end, fail(`outcome'_admit) id(patient_id) enter(index_date) origin(index_date) 
            * Kaplan-Meier plot
            sts graph, by(eth5) ylabel(.95(.01)1) saving(`period', replace) title("`period'") graphregion(fcolor(white))
        }
    } 
    graph combine "pre" "pandemic" "wave1" "easing1" "wave2" "easing2" "wave3" "easing3", graphregion(fcolor(white))
    graph export ./output/graphs/km_`outcome'_combined.svg, as(svg) replace    
}