/* ===========================================================================
Do file name:   model_check_resp.do
Project:        COVID Collateral
Date:     		24/03/2022
Author:         Ruth Costello (based on code by Dominik Piehlmaier)
Description:    Run model checks before time-series
==============================================================================*/

*Log file
cap log using ./logs/model_checks_resp.log, replace
cap mkdir ./output/time_series

*Respiratory outcomes:
*Clinical monitoring for asthma & copd and hospital admissions for copd exacerbation - 
* both by IMD and ethnicity
* hospital admissions for asthma exacerbation only by IMD as ethnicity has small numbers
foreach var in asthma_monitoring copd_monitoring asthma_exacerbation copd_exacerbation {
	foreach strata in ethnicity imd {
		import delimited "./output/measures/resp/measure_`var'_`strata'_rate.csv", numericcols(4) clear	//get csv
		gen temp_date=date(date, "YMD")
		format temp_date %td
		gen postcovid=(temp_date>=date("23/03/2020", "DMY"))
		gen month=mofd(temp_date)
		format month %tm
		drop temp_date
		*Value to rate per 100k
		gen rate = value*100000
		*Set time series
		tsset `strata' month 
		*Kernel density plots to check for normality and extreme values
		kdensity rate if `strata'==1, normal name(kd_`strata'_1, replace)
		kdensity rate if `strata'==2, normal name(kd_`strata'_2, replace)
		kdensity rate if `strata'==3, normal name(kd_`strata'_3, replace)
		kdensity rate if `strata'==4, normal name(kd_`strata'_4, replace)
		kdensity rate if `strata'==5, normal name(kd_`strata'_5, replace)
		*Autoregression plots by ethnicity
		ac rate if `strata'==1, name(ac_`strata'_1, replace)
		ac rate if `strata'==2, name(ac_`strata'_2, replace)
		ac rate if `strata'==3, name(ac_`strata'_3, replace)
		ac rate if `strata'==4, name(ac_`strata'_4, replace)
		ac rate if `strata'==5, name(ac_`strata'_5, replace)
		*Partial autoregression plots by ethnicity
		pac rate if `strata'==1, name(pac_`strata'_1, replace)
		pac rate if `strata'==2, name(pac_`strata'_2, replace)
		pac rate if `strata'==3, name(pac_`strata'_3, replace)
		pac rate if `strata'==4, name(pac_`strata'_4, replace)
		pac rate if `strata'==5, name(pac_`strata'_5, replace)
		*Combine Graphs
		graph combine kd_`strata'_1 kd_`strata'_2 kd_`strata'_3 kd_`strata'_4 kd_`strata'_5, altshrink
		graph export ./output/time_series/resp_kd_`var'_`strata'.svg, as(svg) replace
		graph combine ac_`strata'_1 ac_`strata'_2 ac_`strata'_3 ac_`strata'_4 ac_`strata'_5, altshrink
		graph export ./output/time_series/resp_ac_`var'_`strata'.svg, as(svg) replace
		
		graph combine pac_`strata'_1 pac_`strata'_2 pac_`strata'_3 pac_`strata'_4 pac_`strata'_5, altshrink
		graph export ./output/time_series/resp_pac_`var'_`strata'.svg, as(svg) replace
	}
}	

	
log close