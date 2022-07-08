/* ===========================================================================
Do file name:   cox_models.do
Project:        COVID Collateral
Date:           17/05/2022
Author:         Ruth Costello
                    adapted from Rohini Mathur
Description:    Plots proportional hazards and runs Cox models
==============================================================================*/
local outcome `1'
adopath + ./analysis/ado 
cap log using ./logs/cox_model_`outcome'.log, replace
cap mkdir ./output/graphs
cap mkdir ./output/tempdata
cap mkdir ./output/tables

* open file to write results to
file open tablecontent using ./output/tables/`outcome'_cox_models.txt, write text replace
file write tablecontent ("Period") _tab ("Denominator") _tab ("Events") _tab ("Total person-weeks") _tab ("Rate per 1000") _tab ("Crude HR") _tab _tab ("Age/Sex Adjusted") _tab _tab ("Fully Adjusted") _tab _tab  _n
file write tablecontent _tab _tab _tab _tab _tab _tab _tab   ("HR") _tab ("95% CI") _tab ("HR") _tab ("95% CI") _tab ("HR") _tab ("95% CI") _tab _tab  _n

foreach period in pre pandemic wave1 easing1 wave2 easing2 wave3 easing3 {
use ./output/prep_survival_`period', clear

    * Drop events that occur on index date
    drop if `outcome'_admit_date==index_date
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
        sts graph, by(eth5) ylabel(.75(.05)1)
        graph export ./output/graphs/km_`outcome'_`period'_eth.svg, as(svg) replace
        * Cox model - crude
        stcox i.eth5
        estimates save "./output/tempdata/crude_`outcome'_eth", replace 
        eststo model1
        parmest, label eform format(estimate p lb ub) saving("./output/tempdata/surv_crude_`outcome'_eth", replace) idstr("crude_`outcome'_eth") 
        estat phtest, detail
        * Cox model - age and gender adjusted
        stcox i.eth5 i.age_cat i.male
        estimates save "./output/tempdata/model1_`outcome'_eth", replace 
        eststo model2
        parmest, label eform format(estimate p lb ub) saving("./output/tempdata/surv_model1_`outcome'_eth", replace) idstr("model1_`outcome'_eth") 
        estat phtest, detail
        * Cox model - fully adjusted
        stcox i.eth5 i.age_cat i.male i.urban_rural_bin i.imd i.shielded
        estimates save "./output/tempdata/model2_`outcome'_eth", replace 
        eststo model3
        parmest, label eform format(estimate p lb ub) saving("./output/tempdata/surv_model2_`outcome'_eth", replace) idstr("model2_`outcome'_eth") 
        estat phtest, detail
        esttab model1 model2 model3 using "./output/tables/`outcome'_estout_table_eth_`period'.txt", b(a2) ci(2) label wide compress eform ///
        title ("`outcome'") ///
        varlabels(`e(labels)') ///
        stats(N_outcome) ///
        append 
        eststo clear
    * Write results to table
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
        qui safecount if eth5 == 1 & `outcome'_admit == 1
        local event = r(N)
        bysort eth5: egen total_follow_up = total(_t)
        qui su total_follow_up if eth5 == 1
        local person_week = r(mean)/7
        local rate = 1000*(`event'/`person_week')
        if `event'>10 & `event'!=. {
            file write tablecontent  ("`period'") _tab ("`lab1'") _tab (`denominator') _tab (`event') _tab %10.0f (`person_week') _tab %3.2f (`rate') _tab
            file write tablecontent ("1.00") _tab _tab ("1.00") _tab _tab ("1.00") _n
            }
        else {
            file write tablecontent ("`period'") _tab ("`lab`eth''") _tab ("redact") _n
            continue
        }
    * outcomesequent ethnic groups
        forvalues eth=2/5 {
            qui safecount if eth5==`eth'
            local denominator = r(N)
            qui safecount if eth5 == `eth' & `outcome'_admit == 1
            local event = r(N)
            qui su total_follow_up if eth5 == `eth'
            local person_week = r(mean)/7
            local rate = 1000*(`event'/`person_week')
            if `event'>10 & `event'!=. {
                file write tablecontent ("`period'") _tab ("`lab`eth''") _tab (`denominator') _tab (`event') _tab %10.0f (`person_week') _tab %3.2f (`rate') _tab  
                cap estimates use "./output/tempdata/crude_`outcome'_eth" 
                cap lincom `eth'.eth5, eform
                file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _tab 
                cap estimates clear
                cap estimates use "./output/tempdata/model1_`outcome'_eth" 
                cap lincom `eth'.eth5, eform
                file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _tab 
                cap estimates clear
                cap estimates use "./output/tempdata/model2_`outcome'_eth" 
                cap lincom `eth'.eth5, eform
                file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _tab _n
                cap estimates clear
            }
            else {
                file write tablecontent ("`period'") _tab ("`lab`eth''") _tab ("redact") _n
                continue
            }
        }  //end ethnic group
drop total_follow_up
    }
else { 
    file write tablecontent ("`period'") _tab ("redact") _n
    continue
}
} //end outcomes
file close tablecontent

log close