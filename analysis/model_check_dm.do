/* ===========================================================================
Do file name:   model_check_dm.do
Project:        COVID Collateral
Date:     		24/03/2022
Author:         Ruth Costello (based on code by Dominik Piehlmaier)
Description:    Run model checks before time-series
==============================================================================*/
* NOTE: Will need updating to use 3-monthly files for keto, t1 & t2 primary and any admissions
* created in graphs_dm.do - check data first
*Log file
cap log using ./logs/model_checks_dm.log, replace
cap mkdir ./output/time_series
* Diabetes outcomes
* Clinical monitoring: hba1c and BP measurement, hospital admissions: t1, t2 & keto both primary and any code
local a "hba1c systolic_bp t1_primary t2_primary keto_primary t1_any t2_any keto_any"
forvalues i=1/8 {
    local c: word `i' of `a' 
	local b "ethnicity imd"
	forvalues i=1/2 {
    	local d: word `i' of `b'
	import delimited "./output/measures/dm/measure_dm_`c'_`d'_rate.csv", numericcols(4) clear	//get csv
	gen temp_date=date(date, "YMD")
	format temp_date %td
	gen postcovid=(temp_date>=date("23/03/2020", "DMY"))
	gen month=mofd(temp_date)
	format month %tm
	drop temp_date
	*Value to rate per 100k
	gen rate = value*100000
	label variable rate "Rate of `c' exacerbation per 100,000"
	*Set time series
	tsset `d' month 
	*Kernel density plots to check for normality and extreme values
	kdensity rate if `d'==1, normal name(kd_`d'_1_`c')
	kdensity rate if `d'==2, normal name(kd_`d'_2_`c')
    kdensity rate if `d'==3, normal name(kd_`d'_3_`c')
    kdensity rate if `d'==4, normal name(kd_`d'_4_`c')
    kdensity rate if `d'==5, normal name(kd_`d'_5_`c')
	*Autoregression plots by ethnicity
    ac rate if `d'==1, name(ac_`d'_1_`c')
	ac rate if `d'==2, name(ac_`d'_2_`c')
    ac rate if `d'==3, name(ac_`d'_3_`c')
    ac rate if `d'==4, name(ac_`d'_4_`c')
    ac rate if `d'==5, name(ac_`d'_5_`c')
	/*Partial autoregression plots by ethnicity
	pac rate if `d'==1, name(pac_`d'_1_`c')
	pac rate if `d'==2, name(pac_`d'_2_`c')
    pac rate if `d'==3, name(pac_`d'_3_`c')
    pac rate if `d'==4, name(pac_`d'_4_`c')
    pac rate if `d'==5, name(pac_`d'_5_`c')*/
	*Combine Graphs
	graph combine kd_`d'_1_`c' kd_`d'_2_`c' kd_`d'_3_`c' kd_`d'_4_`c' kd_`d'_5_`c', altshrink
	graph export ./output/time_series/dm_kd_`c'_`d'.eps, as(eps) replace
	graph combine ac_`d'_1_`c' ac_`d'_2_`c' ac_`d'_3_`c' ac_`d'_4_`c' ac_`d'_5_`c', altshrink
	graph export ./output/time_series/dm_ac_`c'_`d'.eps, as(eps) replace
    /*graph combine pac_`d'*', altshrink
	graph export .output/graphs/dm_pac_`c'_`d'.eps, as(eps) replace*/
	}
}

log close