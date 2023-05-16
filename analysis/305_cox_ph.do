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
cap log using ./logs/cox_model_ph_2.log, replace
cap mkdir ./output/graphs

/* Creating files for R survival curves plotting 5+ event steps
foreach period in pre pandemic {
    use ./output/prep_survival_`period', clear
    describe
    foreach outcome in stroke mi hf vte dm_keto t1dm t2dm depress anx copd asthma {
        * Drop events that occur on index date
        replace `outcome'_admit_date=. if `outcome'_admit_date==index_date

        /* Update study population for diabetes and respiratory outcomes
        drop if diabetes_subgroup==0 & "`outcome'"== "dm_keto"
        drop if has_t1_diabetes==0 & "`outcome'"=="t1dm"
        drop if has_t2_diabetes==0 & "`outcome'"== "t2dm"
        drop if has_asthma==0 & "`outcome'"== "asthma"
        drop if has_copd==0 & "`outcome'"=="copd"*/
        
        * Cox model for each outcome category
        * Generate flags and end dates for each outcome
        gen `outcome'_admit=(`outcome'_admit_date!=.)
        tab `outcome'_admit
        gen `outcome'_end = end_date
        replace `outcome'_end = `outcome'_admit_date if `outcome'_admit==1
        gen `outcome'_days = `outcome'_end - index_date
    }
    save ./output/survival/survival__`period'.dta, replace
}
*/

* For outcomes where axis 0.99
foreach period in pre pandemic /*wave1 easing1 wave2 easing2 wave3 easing3*/ {
    use ./output/prep_survival_`period', clear
    describe
    foreach outcome in stroke mi hf vte dm_keto depress anx {
        * Drop events that occur on index date
        drop if `outcome'_admit_date==index_date

        * Update study population for diabetes and respiratory outcomes
        drop if diabetes_subgroup==0 & "`outcome'"== "dm_keto"
        
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
                sts graph, by(eth5) ylabel(.99(0.01)1) title("`period'") graphregion(fcolor(white))
                graph export ./output/graphs/km_`outcome'_`period'.svg, as(svg) replace
                /*qui stcox eth5, strata(stp)
                estat phtest 
                qui stcox eth5 i.age_cat i.male, strata(stp)
                estat phtest 
                qui stcox eth5 i.age_cat i.male i.urban_rural_bin i.imd i.shielded, strata(stp)
                estat phtest*/
        }
    } 
}

* T1 DM plots 
foreach period in pre pandemic wave1 easing1 wave2 easing2 wave3 easing3 {
    use ./output/prep_survival_`period', clear
    describe
    * Drop events that occur on index date
    drop if t1dm_admit_date==index_date

    * Update study population for diabetes and respiratory outcomes
    drop if has_t1_diabetes==0

    * Cox model for each outcome category
    * Generate flags and end dates for each outcome
    gen t1dm_admit=(t1dm_admit_date!=.)
    tab t1dm_admit
    count if t1dm_admit_date!=.
    if r(N) > 10 {
            gen t1dm_end = end_date
            replace t1dm_end = t1dm_admit_date if t1dm_admit==1

            stset t1dm_end, fail(t1dm_admit) id(patient_id) enter(index_date) origin(index_date) 
            * Kaplan-Meier plot
            sts graph, by(eth5) ylabel(.80(.05)1) title("`period'") graphregion(fcolor(white))
            graph export ./output/graphs/km_t1dm_`period'.svg, as(svg) replace
            /*qui stcox eth5, strata(stp)
            estat phtest 
            qui stcox eth5 i.age_cat i.male, strata(stp)
            estat phtest 
            qui stcox eth5 i.age_cat i.male i.urban_rural_bin i.imd i.shielded, strata(stp)
            estat phtest*/
    }
} 

* T2 DM and asthma plots 
foreach period in pre pandemic /*wave1 easing1 wave2 easing2 wave3 easing3*/ {
    use ./output/prep_survival_`period', clear
    describe
    foreach outcome in asthma t2dm {
    * Drop events that occur on index date
        drop if `outcome'_admit_date==index_date 

        * Update study population for diabetes and respiratory outcomes
        drop if has_t2_diabetes==0 & "`outcome'"== "t2dm"
        drop if has_asthma==0 & "`outcome'"== "asthma"

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
                sts graph, by(eth5) ylabel(.95(.01)1) title("`period'") graphregion(fcolor(white))
                graph export ./output/graphs/km_`outcome'_`period'.svg, as(svg) replace
                /*qui stcox eth5, strata(stp)
                estat phtest 
                qui stcox eth5 i.age_cat i.male, strata(stp)
                estat phtest 
                qui stcox eth5 i.age_cat i.male i.urban_rural_bin i.imd i.shielded, strata(stp)
                estat phtest*/
        }
    } 
}

* COPD plots
foreach period in pre pandemic wave1 easing1 wave2 easing2 wave3 easing3 {
    use ./output/prep_survival_`period', clear
    describe
    * Drop events that occur on index date
    drop if copd_admit_date==index_date

    * Update study population for diabetes and respiratory outcomes
    drop if has_copd==0

    * Cox model for each outcome category
    * Generate flags and end dates for each outcome
    gen copd_admit=(copd_admit_date!=.)
    tab copd_admit
    count if copd_admit_date!=.
    if r(N) > 10 {
            gen copd_end = end_date
            replace copd_end = copd_admit_date if copd_admit==1

            stset copd_end, fail(copd_admit) id(patient_id) enter(index_date) origin(index_date) 
            * Kaplan-Meier plot
            sts graph, by(eth5) ylabel(.90(.02)1) title("`period'") graphregion(fcolor(white))
            graph export ./output/graphs/km_copd_`period'.svg, as(svg) replace
            /*qui stcox eth5, strata(stp)
            estat phtest 
            qui stcox eth5 i.age_cat i.male, strata(stp)
            estat phtest 
            qui stcox eth5 i.age_cat i.male i.urban_rural_bin i.imd i.shielded, strata(stp)
            estat phtest*/
    }
} 

