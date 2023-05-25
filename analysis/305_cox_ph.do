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

    describe
/* Page on time_varying splitting: https://stats.stackexchange.com/questions/112555/what-s-wrong-with-this-way-of-fitting-time-dependent-coefficients-in-a-cox-regre 
* For outcomes where axis 0.99
foreach period in pre pandemic /*wave1 easing1 wave2 easing2 wave3 easing3*/ {
    use ./output/prep_survival_`period', clear
    describe
    foreach outcome in stroke mi hf vte dm_keto depress anx {
        preserve
        * Drop events that occur on index date
        replace `outcome'_admit_date=. if `outcome'_admit_date==index_date

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
                *sts graph, by(eth5) ylabel(.99(0.01)1) title("`period'") graphregion(fcolor(white))
                *graph export ./output/graphs/km_`outcome'_`period'.svg, as(svg) replace
                stcox i.eth5, strata(stp) nolog
                forvalues z=2/5 {
                    estat phtest, plot(`z'.eth5) ///
                        graphregion(fcolor(white)) ///
                        ylabel(, nogrid labsize(small)) ///
                        xlabel(, labsize(small)) ///
                        xtitle("Time", size(small)) ///
                        ytitle("Scaled Schoenfeld Residuals", size(small)) ///
                        msize(small) ///
                        mcolor(gs6) ///
                        msymbol(circle_hollow) ///
                        scheme(s1mono) ///
                        title ("`z'", position(11) size(medsmall)) ///
                        name(uni_plot_`period'_`outcome'_`z')
                    }
                graph combine uni_plot_`period'_`outcome'_2 uni_plot_`period'_`outcome'_3 uni_plot_`period'_`outcome'_4 uni_plot_`period'_`outcome'_5
                graph export ./output/graphs/schoenplot_uni_`outcome'_`period'.svg, as(svg) replace 
                stcox i.eth5 i.age_cat i.male, strata(stp) nolog
                forvalues z=2/5 {
                    di `title'
                    estat phtest, plot(`z'.eth5) ///
                        graphregion(fcolor(white)) ///
                        ylabel(, nogrid labsize(small)) ///
                        xlabel(, labsize(small)) ///
                        xtitle("Time", size(small)) ///
                        ytitle("Scaled Schoenfeld Residuals", size(small)) ///
                        msize(small) ///
                        mcolor(gs6) ///
                        msymbol(circle_hollow) ///
                        scheme(s1mono) ///
                        title ("`z'", position(11) size(medsmall)) ///
                        name(age_sex_plot_`period'_`outcome'_`z')
                    }
                graph combine age_sex_plot_`period'_`outcome'_2 age_sex_plot_`period'_`outcome'_3 age_sex_plot_`period'_`outcome'_4 age_sex_plot_`period'_`outcome'_5
                graph export ./output/graphs/schoenplot_age_sex_`outcome'_`period'.svg, as(svg) replace 
                *stcox eth5 i.age_cat i.male, strata(stp) tvc(i.age_cat i.male) texp(_t) nolog
                stcox i.eth5 i.age_cat i.male i.urban_rural_bin i.imd i.shielded, strata(stp) nolog
                forvalues z=2/5 {
                    estat phtest, plot(`z'.eth5) ///
                        graphregion(fcolor(white)) ///
                        ylabel(, nogrid labsize(small)) ///
                        xlabel(, labsize(small)) ///
                        xtitle("Time", size(small)) ///
                        ytitle("Scaled Schoenfeld Residuals", size(small)) ///
                        msize(small) ///
                        mcolor(gs6) ///
                        msymbol(circle_hollow) ///
                        scheme(s1mono) ///
                        title ("`z'", position(11) size(medsmall)) ///
                        name(multi_plot_`period'_`outcome'_`z')
                    }
                graph combine multi_plot_`period'_`outcome'_2 multi_plot_`period'_`outcome'_3 multi_plot_`period'_`outcome'_4 multi_plot_`period'_`outcome'_5
                graph export ./output/graphs/schoenplot_multi_`outcome'_`period'.svg, as(svg) replace 
                *stcox eth5 i.age_cat i.male i.urban_rural_bin i.imd i.shielded, strata(stp) tvc(i.age_cat i.male i.urban_rural_bin i.imd i.shielded) texp(_t)
        }
    restore
    } 
}
*/
* T1 DM plots 
foreach period in pre pandemic /*wave1 easing1 wave2 easing2 wave3 easing3*/ {
    use ./output/prep_survival_`period', clear
    describe
    * Drop events that occur on index date
    replace t1dm_admit_date=. if t1dm_admit_date==index_date

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
            *sts graph, by(eth5) ylabel(.80(.05)1) title("`period'") graphregion(fcolor(white))
            *graph export ./output/graphs/km_t1dm_`period'.svg, as(svg) replace
            stcox i.eth5, strata(stp) nolog
                forvalues z=2/5 {
                    estat phtest, plot(`z'.eth5) ///
                        graphregion(fcolor(white)) ///
                        ylabel(, nogrid labsize(small)) ///
                        xlabel(, labsize(small)) ///
                        xtitle("Time", size(small)) ///
                        ytitle("Scaled Schoenfeld Residuals", size(small)) ///
                        msize(small) ///
                        mcolor(gs6) ///
                        msymbol(circle_hollow) ///
                        scheme(s1mono) ///
                        title ("`z'", position(11) size(medsmall)) ///
                        name(uni_plot_t1dm_`z')
                    }
                graph combine uni_plot_t1dm_2 uni_plot_t1dm_3 uni_plot_t1dm_4 uni_plot_t1dm_5
                graph export ./output/graphs/schoenplot_uni_t1dm_`period'.svg, as(svg) replace 
                stcox i.eth5 i.age_cat i.male, strata(stp) nolog
                forvalues z=2/5 {
                    estat phtest, plot(`z'.eth5) ///
                        graphregion(fcolor(white)) ///
                        ylabel(, nogrid labsize(small)) ///
                        xlabel(, labsize(small)) ///
                        xtitle("Time", size(small)) ///
                        ytitle("Scaled Schoenfeld Residuals", size(small)) ///
                        msize(small) ///
                        mcolor(gs6) ///
                        msymbol(circle_hollow) ///
                        scheme(s1mono) ///
                        title ("`z'", position(11) size(medsmall)) ///
                        name(age_sex_plot_t1dm_`z')
                    }
                graph combine age_sex_plot_t1dm_2 age_sex_plot_t1dm_3 age_sex_plot_t1dm_4 age_sex_plot_t1dm_5
                graph export ./output/graphs/schoenplot_age_sex_t1dm_`period'.svg, as(svg) replace 
                *stcox eth5 i.age_cat i.male, strata(stp) tvc(i.age_cat i.male) texp(_t) nolog
                stcox i.eth5 i.age_cat i.male i.urban_rural_bin i.imd i.shielded, strata(stp) nolog
                forvalues z=2/5 {
                    estat phtest, plot(`z'.eth5) ///
                        graphregion(fcolor(white)) ///
                        ylabel(, nogrid labsize(small)) ///
                        xlabel(, labsize(small)) ///
                        xtitle("Time", size(small)) ///
                        ytitle("Scaled Schoenfeld Residuals", size(small)) ///
                        msize(small) ///
                        mcolor(gs6) ///
                        msymbol(circle_hollow) ///
                        scheme(s1mono) ///
                        title ("`z'", position(11) size(medsmall)) ///
                        name(multi_plot_t1dm_`z')
                    }
                graph combine multi_plot_t1dm_2 multi_plot_t1dm_3 multi_plot_t1dm_4 multi_plot_t1dm_5
                graph export ./output/graphs/schoenplot_multi_t1dm_`period'.svg, as(svg) replace 
            *stcox eth5 i.age_cat i.male i.urban_rural_bin i.imd i.shielded, strata(stp) tvc(i.age_cat i.male i.urban_rural_bin i.imd i.shielded) texp(_t)
    }
} 

/* T2 DM and asthma plots 
foreach period in pre pandemic /*wave1 easing1 wave2 easing2 wave3 easing3*/ {
    use ./output/prep_survival_`period', clear
    describe
    foreach outcome in asthma t2dm {
    preserve
    * Drop events that occur on index date
        replace `outcome'_admit_date=. if `outcome'_admit_date==index_date 

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
                *sts graph, by(eth5) ylabel(.95(.01)1) title("`period'") graphregion(fcolor(white))
                *graph export ./output/graphs/km_`outcome'_`period'.svg, as(svg) replace
                stcox i.eth5, strata(stp) nolog
                forvalues z=2/5 {
                    estat phtest, plot(`z'.eth5) ///
                        graphregion(fcolor(white)) ///
                        ylabel(, nogrid labsize(small)) ///
                        xlabel(, labsize(small)) ///
                        xtitle("Time", size(small)) ///
                        ytitle("Scaled Schoenfeld Residuals", size(small)) ///
                        msize(small) ///
                        mcolor(gs6) ///
                        msymbol(circle_hollow) ///
                        scheme(s1mono) ///
                        title ("`z'", position(11) size(medsmall)) ///
                        name(uni_plot_`period'_`outcome'_`z')
                    }
                graph combine uni_plot_`period'_`outcome'_2 uni_plot_`period'_`outcome'_3 uni_plot_`period'_`outcome'_4 uni_plot_`period'_`outcome'_5
                graph export ./output/graphs/schoenplot_uni_`outcome'_`period'.svg, as(svg) replace 
                stcox i.eth5 i.age_cat i.male, strata(stp) nolog
                forvalues z=2/5 {
                    estat phtest, plot(`z'.eth5) ///
                        graphregion(fcolor(white)) ///
                        ylabel(, nogrid labsize(small)) ///
                        xlabel(, labsize(small)) ///
                        xtitle("Time", size(small)) ///
                        ytitle("Scaled Schoenfeld Residuals", size(small)) ///
                        msize(small) ///
                        mcolor(gs6) ///
                        msymbol(circle_hollow) ///
                        scheme(s1mono) ///
                        title ("`z'", position(11) size(medsmall)) ///
                        name(age_sex_plot_`period'_`outcome'_`z')
                    }
                graph combine age_sex_plot_`period'_`outcome'_2 age_sex_plot_`period'_`outcome'_3 age_sex_plot_`period'_`outcome'_4 age_sex_plot_`period'_`outcome'_5
                graph export ./output/graphs/schoenplot_age_sex_`outcome'_`period'.svg, as(svg) replace 
                *stcox eth5 i.age_cat i.male, strata(stp) tvc(i.age_cat i.male) texp(_t) nolog
                stcox i.eth5 i.age_cat i.male i.urban_rural_bin i.imd i.shielded, strata(stp) nolog
                forvalues z=2/5 {
                    estat phtest, plot(`z'.eth5) ///
                        graphregion(fcolor(white)) ///
                        ylabel(, nogrid labsize(small)) ///
                        xlabel(, labsize(small)) ///
                        xtitle("Time", size(small)) ///
                        ytitle("Scaled Schoenfeld Residuals", size(small)) ///
                        msize(small) ///
                        mcolor(gs6) ///
                        msymbol(circle_hollow) ///
                        scheme(s1mono) ///
                        title ("`z'", position(11) size(medsmall)) ///
                        name(multi_plot_`period'_`outcome'_`z')
                    }
                graph combine multi_plot_`period'_`outcome'_2 multi_plot_`period'_`outcome'_3 multi_plot_`period'_`outcome'_4 multi_plot_`period'_`outcome'_5
                graph export ./output/graphs/schoenplot_multi_`outcome'_`period'.svg, as(svg) replace 
                *stcox eth5 i.age_cat i.male i.urban_rural_bin i.imd i.shielded, strata(stp) tvc(i.age_cat i.male i.urban_rural_bin i.imd i.shielded) texp(_t)
        }
    restore
    } 
}

* COPD plots
foreach period in pre pandemic /*wave1 easing1 wave2 easing2 wave3 easing3*/ {
    use ./output/prep_survival_`period', clear
    describe
    * Drop events that occur on index date
     replace copd_admit_date=. if copd_admit_date==index_date

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
            stcox i.eth5, strata(stp) nolog
                forvalues z=2/5 {
                    estat phtest, plot(`z'.eth5) ///
                        graphregion(fcolor(white)) ///
                        ylabel(, nogrid labsize(small)) ///
                        xlabel(, labsize(small)) ///
                        xtitle("Time", size(small)) ///
                        ytitle("Scaled Schoenfeld Residuals", size(small)) ///
                        msize(small) ///
                        mcolor(gs6) ///
                        msymbol(circle_hollow) ///
                        scheme(s1mono) ///
                        title ("`z'", position(11) size(medsmall)) ///
                        name(uni_plot_copd_`z')
                    }
                graph combine uni_plot_copd_2 uni_plot_copd_3 uni_plot_copd_4 uni_plot_copd_5
                graph export ./output/graphs/schoenplot_uni_copd_`period'.svg, as(svg) replace 
                stcox i.eth5 i.age_cat i.male, strata(stp) nolog
                forvalues z=2/5 {
                    estat phtest, plot(`z'.eth5) ///
                        graphregion(fcolor(white)) ///
                        ylabel(, nogrid labsize(small)) ///
                        xlabel(, labsize(small)) ///
                        xtitle("Time", size(small)) ///
                        ytitle("Scaled Schoenfeld Residuals", size(small)) ///
                        msize(small) ///
                        mcolor(gs6) ///
                        msymbol(circle_hollow) ///
                        scheme(s1mono) ///
                        title ("`z'", position(11) size(medsmall)) ///
                        name(age_sex_plot_copd_`z')
                    }
                graph combine age_sex_plot_copd_2 age_sex_plot_copd_3 age_sex_plot_copd_4 age_sex_plot_copd_5
                graph export ./output/graphs/schoenplot_age_sex_copd.svg, as(svg) replace 
                *stcox eth5 i.age_cat i.male, strata(stp) tvc(i.age_cat i.male) texp(_t) nolog
                stcox i.eth5 i.age_cat i.male i.urban_rural_bin i.imd i.shielded, strata(stp) nolog
                forvalues z=2/5 {
                    estat phtest, plot(`z'.eth5) ///
                        graphregion(fcolor(white)) ///
                        ylabel(, nogrid labsize(small)) ///
                        xlabel(, labsize(small)) ///
                        xtitle("Time", size(small)) ///
                        ytitle("Scaled Schoenfeld Residuals", size(small)) ///
                        msize(small) ///
                        mcolor(gs6) ///
                        msymbol(circle_hollow) ///
                        scheme(s1mono) ///
                        title ("`z'", position(11) size(medsmall)) ///
                        name(multi_plot_copd_`z')
                    }
                graph combine multi_plot_copd_2 multi_plot_copd_3 multi_plot_copd_4 multi_plot_copd_5
                graph export ./output/graphs/schoenplot_multi_copd_`period'.svg, as(svg) replace 
            stcox eth5 i.age_cat i.male i.urban_rural_bin i.imd i.shielded, strata(stp) tvc(i.age_cat i.male i.urban_rural_bin i.imd i.shielded) texp(_t)
    }
} 
/*foreach period in pre pandemic {
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

}*/
