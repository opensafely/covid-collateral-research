/* ===========================================================================
Do file name:   model_check.do
Project:        COVID Collateral
Date:     		24/03/2022
Author:         Ruth Costello (based on code by Dominik Piehlmaier)
Description:    Run model checks before time-series
==============================================================================*/

*Log file
cap log using ./logs/model_checks.log, replace
cap mkdir ./output/time_series
local a "asthma copd"
local b "ethnicity imd"
forvalues i=1/2 {
    local c: word `i' of `a' 
    local d: word `i' of `b'
	import delimited "./output/measures/resp/measure_`c'_exacerbation_`d'_rate.csv", clear	//get csv
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
	kdensity rate if `d'==1, normal name(kd_`d'_1_`x')
	kdensity rate if `d'==2, normal name(kd_`d'_2_`x')
    kdensity rate if `d'==3, normal name(kd_`d'_3_`x')
    kdensity rate if `d'==4, normal name(kd_`d'_4_`x')
    kdensity rate if `d'==5, normal name(kd_`d'_5_`x')
	*Autoregression plots by ethnicity
    ac rate if `d'==1, name(ac_`d'_1_`x')
	ac rate if `d'==2, name(ac_`d'_2_`x')
    ac rate if `d'==3, name(ac_`d'_3_`x')
    ac rate if `d'==4, name(ac_`d'_4_`x')
    ac rate if `d'==5, name(ac_`d'_5_`x')
	/*Partial autoregression plots by ethnicity
	pac rate if `d'==1, name(pac_`d'_1_`x')
	pac rate if `d'==2, name(pac_`d'_2_`x')
    pac rate if `d'==3, name(pac_`d'_3_`x')
    pac rate if `d'==4, name(pac_`d'_4_`x')
    pac rate if `d'==5, name(pac_`d'_5_`x')*/
	*Combine Graphs
	graph combine kd_`d'_1_`x' kd_`d'_2_`x' kd_`d'_3_`x' kd_`d'_4_`x' kd_`d'_5_`x', altshrink
	graph export ./output/time_series/checks_kd_`d'.eps, as(eps) replace
	graph combine ac_`d'_1_`x' ac_`d'_2_`x' ac_`d'_3_`x' ac_`d'_4_`x' ac_`d'_5_`x', altshrink
	graph export ./output/time_series/checks_ac_`d'.eps, as(eps) replace
    /*graph combine pac_`d'*', altshrink
	graph export .output/graphs/checks_pac_`d'.eps, as(eps) replace*/
}
