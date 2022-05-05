/* ===========================================================================
Do file name:   model_check_dm.do
Project:        COVID Collateral
Date:     		24/03/2022
Author:         Ruth Costello (based on code by Dominik Piehlmaier)
Description:    Run model checks before time-series
==============================================================================*/

*Log file
cap log using ./logs/model_checks_dm.log, replace
cap mkdir ./output/time_series
* Diabetes outcomes
* Clinical monitoring: hba1c and BP measurement, hospital admissions: t1, t2 & keto both primary and any code
local a "hba1c systolic_bp t1_primary t2_primary keto_primary t1_any t2_any keto_any t1_primary t1_any t2_primary t2_any keto_primary keto_any"
forvalues i=1/14 {
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
		kdensity rate if `d'==1, normal name(kd_`d'_1_`c', replace)
		kdensity rate if `d'==2, normal name(kd_`d'_2_`c', replace)
		kdensity rate if `d'==3, normal name(kd_`d'_3_`c', replace)
		kdensity rate if `d'==4, normal name(kd_`d'_4_`c', replace)
		kdensity rate if `d'==5, normal name(kd_`d'_5_`c', replace)
		*Autoregression plots by ethnicity
		ac rate if `d'==1, name(ac_`d'_1_`c', replace)
		ac rate if `d'==2, name(ac_`d'_2_`c', replace)
		ac rate if `d'==3, name(ac_`d'_3_`c', replace)
		ac rate if `d'==4, name(ac_`d'_4_`c', replace)
		ac rate if `d'==5, name(ac_`d'_5_`c', replace)
		*Partial autoregression plots by ethnicity
		pac rate if `d'==1, name(pac_`d'_1_`c', replace)
		pac rate if `d'==2, name(pac_`d'_2_`c', replace)
		pac rate if `d'==3, name(pac_`d'_3_`c', replace)
		pac rate if `d'==4, name(pac_`d'_4_`c', replace)
		pac rate if `d'==5, name(pac_`d'_5_`c', replace)
		*Combine Graphs
		graph combine kd_`d'_1_`c' kd_`d'_2_`c' kd_`d'_3_`c' kd_`d'_4_`c' kd_`d'_5_`c', altshrink
		graph export ./output/time_series/dm_kd_`c'_`d'.svg, as(svg) replace
		graph combine ac_`d'_1_`c' ac_`d'_2_`c' ac_`d'_3_`c' ac_`d'_4_`c' ac_`d'_5_`c', altshrink
		graph export ./output/time_series/dm_ac_`c'_`d'.svg, as(svg) replace
		graph combine pac_`d'_1_`c' pac_`d'_2_`c' pac_`d'_3_`c' pac_`d'_4_`c' pac_`d'_5_`c', altshrink
		graph export .output/graphs/dm_pac_`c'_`d'.svg, as(svg) replace
		}
	}

/*foreach var in t1_primary t1_any t2_primary t2_any keto_primary keto_any {
	import delimited "./output/measures/dm/collapse_measure_dm_`var'_ethnicity_rate.csv", numericcols(2) clear	//get csv
	gen temp_date=date(datea, "DM20Y")
	format temp_date %td
	gen postcovid=(temp_date>=date("23/03/2020", "DMY"))
	* identify 3 monthly intervals
    gen quarter = qofd(temp_date)
	format quarter %tq
	drop temp_date
	*Set time series
	tsset ethnicity quarter
	*Kernel density plots to check for normality and extreme values
	kdensity rate if ethnicity==1, normal name(kd_ethnicity_1_`var', replace)
	kdensity rate if ethnicity==2, normal name(kd_ethnicity_2_`var', replace)
	kdensity rate if ethnicity==3, normal name(kd_ethnicity_3_`var', replace)
	kdensity rate if ethnicity==4, normal name(kd_ethnicity_4_`var', replace)
	kdensity rate if ethnicity==5, normal name(kd_ethnicity_5_`var', replace)
	*Autoregression plots by ethnicity
	ac rate if ethnicity==1, name(ac_ethnicity_1_`var', replace)
	ac rate if ethnicity==2, name(ac_ethnicity_2_`var', replace)
	ac rate if ethnicity==3, name(ac_ethnicity_3_`var', replace)
	ac rate if ethnicity==4, name(ac_ethnicity_4_`var', replace)
	ac rate if ethnicity==5, name(ac_ethnicity_5_`var', replace)
	/*Partial autoregression plots by ethnicity
	pac rate if ethnicity==1, name(pac_ethnicity_1_`var', replace)
	pac rate if ethnicity==2, name(pac_ethnicity_2_`var', replace)
	pac rate if ethnicity==3, name(pac_ethnicity_3_`var', replace)
	pac rate if ethnicity==4, name(pac_ethnicity_4_`var', replace)
	pac rate if ethnicity==5, name(pac_ethnicity_5_`var', replace)*/
	*Combine Graphs
	graph combine kd_ethnicity_1_`var' kd_ethnicity_2_`var' kd_ethnicity_3_`var' kd_ethnicity_4_`var' kd_ethnicity_5_`var', altshrink
	graph export ./output/time_series/dm_kd_`var'_ethnicity.svg, as(svg) replace
	graph combine ac_ethnicity_1_`var' ac_ethnicity_2_`var' ac_ethnicity_3_`var' ac_ethnicity_4_`var' ac_ethnicity_5_`var', altshrink
	graph export ./output/time_series/dm_ac_`var'_ethnicity.svg, as(svg) replace
	*graph combine pac_ethnicity*', altshrink
	*graph export .output/graphs/dm_pac_`var'_ethnicity.svg, as(svg) replace
	}

foreach var in t1_primary t1_any t2_primary t2_any keto_primary keto_any {
	import delimited "./output/measures/dm/measure_dm_`var'_imd_rate.csv", numericcols(4) clear	//get csv
	gen temp_date=date(date, "YMD")
	format temp_date %td
	gen postcovid=(temp_date>=date("23/03/2020", "DMY"))
	gen month=mofd(temp_date)
	format month %tm
	drop temp_date
	*Value to rate per 100k
	gen rate = value*100000
	label variable rate "Rate of `var' exacerbation per 100,000"
	*Set time series
	tsset imd month 
	*Kernel density plots to check for normality and extreme values
	kdensity rate if imd==1, normal name(kd_imd_1_`var', replace)
	kdensity rate if imd==2, normal name(kd_imd_2_`var', replace)
	kdensity rate if imd==3, normal name(kd_imd_3_`var', replace)
	kdensity rate if imd==4, normal name(kd_imd_4_`var', replace)
	kdensity rate if imd==5, normal name(kd_imd_5_`var', replace)
	*Autoregression plots by imd
	ac rate if imd==1, name(ac_imd_1_`var', replace)
	ac rate if imd==2, name(ac_imd_2_`var', replace)
	ac rate if imd==3, name(ac_imd_3_`var', replace)
	ac rate if imd==4, name(ac_imd_4_`var', replace)
	ac rate if imd==5, name(ac_imd_5_`var', replace)
	/*Partial autoregression plots by imd
	pac rate if imd==1, name(pac_imd_1_`var', replace)
	pac rate if imd==2, name(pac_imd_2_`var', replace)
	pac rate if imd==3, name(pac_imd_3_`var', replace)
	pac rate if imd==4, name(pac_imd_4_`var', replace)
	pac rate if imd==5, name(pac_imd_5_`var', replace)*/
	*Combine Graphs
	graph combine kd_imd_1_`var' kd_imd_2_`var' kd_imd_3_`var' kd_imd_4_`var' kd_imd_5_`var', altshrink
	graph export ./output/time_series/dm_kd_`var'_imd.svg, as(svg) replace
	graph combine ac_imd_1_`var' ac_imd_2_`var' ac_imd_3_`var' ac_imd_4_`var' ac_imd_5_`var', altshrink
	graph export ./output/time_series/dm_ac_`var'_imd.svg, as(svg) replace
	*graph combine pac_imd*', altshrink
	*graph export .output/graphs/dm_pac_`var'_imd.svg, as(svg) replace
	}*/

log close