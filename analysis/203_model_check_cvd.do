/* ===========================================================================
Do file name:   model_checks_cvd.do
Project:        COVID Collateral
Date:     		24/03/2022
Author:         Ruth Costello (based on code by Dominik Piehlmaier)
Description:    Run model checks before time-series
==============================================================================*/

*Log file
cap log using ./logs/model_checks_cvd.log, replace
cap mkdir ./output/time_series

* CVD outcomes
* Clinical monitoring: BP measurement
/* Hospital admissions: any code and primary code for MI, stroke, heart failure and vte
local a "bp_meas_cvd mi_admission stroke_admission heart_failure_admission vte_admission mi_primary_admission stroke_primary_admission heart_failure_primary_admission vte_primary_admission"
local z "bp_cvd mi_admit stroke_admit hf_admit vte_admit mi_pri stroke_pri hf_pri vte_pri"
forvalues i=1/9 {
    local c: word `i' of `a' 
	local e: word `i' of `z'
	local b "ethnicity imd"
	forvalues i=1/2 {
    	local d: word `i' of `b'
		import delimited "./output/measures/cvd/measure_`c'_`d'_rate.csv", numericcols(4) clear	//get csv
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
		kdensity rate if `d'==1, normal name(kd_`d'_1_`e')
		kdensity rate if `d'==2, normal name(kd_`d'_2_`e')
		kdensity rate if `d'==3, normal name(kd_`d'_3_`e')
		kdensity rate if `d'==4, normal name(kd_`d'_4_`e')
		kdensity rate if `d'==5, normal name(kd_`d'_5_`e')
		*Autoregression plots by ethnicity
		ac rate if `d'==1, name(ac_`d'_1_`e')
		ac rate if `d'==2, name(ac_`d'_2_`e')
		ac rate if `d'==3, name(ac_`d'_3_`e')
		ac rate if `d'==4, name(ac_`d'_4_`e')
		ac rate if `d'==5, name(ac_`d'_5_`e')
		*Partial autoregression plots by ethnicity
		pac rate if `d'==1, name(pac_`d'_1_`e')
		pac rate if `d'==2, name(pac_`d'_2_`e')
		pac rate if `d'==3, name(pac_`d'_3_`e')
		pac rate if `d'==4, name(pac_`d'_4_`e')
		pac rate if `d'==5, name(pac_`d'_5_`e')
		*Combine Graphs
		graph combine kd_`d'_1_`e' kd_`d'_2_`e' kd_`d'_3_`e' kd_`d'_4_`e' kd_`d'_5_`e', altshrink
		graph export ./output/time_series/cvd_kd_`d'_`c'.svg, as(svg) replace
		graph combine ac_`d'_1_`e' ac_`d'_2_`e' ac_`d'_3_`e' ac_`d'_4_`e' ac_`d'_5_`e', altshrink
		graph export ./output/time_series/cvd_ac_`d'_`c'.svg, as(svg) replace
		graph combine pac_`d'_1_`e' pac_`d'_2_`e' pac_`d'_3_`e' pac_`d'_4_`e' pac_`d'_5_`e', altshrink
		graph export ./output/time_series/cvd_pac_`d'_`e'.svg, as(svg) replace
		}
	}*/

	* BP only
	import delimited "./output/measures/cvd/measure_bp_meas_cvd_ethnicity_rate.csv", numericcols(4) clear	//get csv
	putexcel set ./output/time_series/tsreg_tables_cvd, sheet(bp_meas_cvd_ethnicity) modify			//open xlsx
	* Drop records where ethnicity is missing - no missing IMD
	drop if ethnicity==0 | ethnicity==.
	drop if cvd_subgroup==0
	*Format time
	gen temp_date=date(date, "YMD")
	format temp_date %td
	gen postcovid=(temp_date>=date("23/03/2020", "DMY"))
	gen month=mofd(temp_date)
	format month %tm
	*Define Seasons
	gen season=4
	replace season = 1 if inrange(month(temp_date),3,5)
	replace season = 2 if inrange(month(temp_date),6,8)
	replace season = 3 if inrange(month(temp_date),9,11)
	label define seasonlab 1 "Spring" 2 "Summer" 3 "Autumn" 4 "Winter"
	label values season seasonlab
	drop temp_date
	*Value to rate per 100k
	gen rate = value*100000
	*Run time series with EWH-robust SE and 1 Lag
	tsset ethnicity month
	*Kernel density plots to check for normality and extreme values
		kdensity rate if ethnicity==1, normal name(kd_ethnicity_1_bp_cvd)
		kdensity rate if ethnicity==2, normal name(kd_ethnicity_2_bp_cvd)
		kdensity rate if ethnicity==3, normal name(kd_ethnicity_3_bp_cvd)
		kdensity rate if ethnicity==4, normal name(kd_ethnicity_4_bp_cvd)
		kdensity rate if ethnicity==5, normal name(kd_ethnicity_5_bp_cvd)
		*Autoregression plots by ethnicity
		ac rate if ethnicity==1, name(ac_ethnicity_1_bp_cvd)
		ac rate if ethnicity==2, name(ac_ethnicity_2_bp_cvd)
		ac rate if ethnicity==3, name(ac_ethnicity_3_bp_cvd)
		ac rate if ethnicity==4, name(ac_ethnicity_4_bp_cvd)
		ac rate if ethnicity==5, name(ac_ethnicity_5_bp_cvd)
		*Partial autoregression plots by ethnicity
		pac rate if ethnicity==1, name(pac_ethnicity_1_bp_cvd)
		pac rate if ethnicity==2, name(pac_ethnicity_2_bp_cvd)
		pac rate if ethnicity==3, name(pac_ethnicity_3_bp_cvd)
		pac rate if ethnicity==4, name(pac_ethnicity_4_bp_cvd)
		pac rate if ethnicity==5, name(pac_ethnicity_5_bp_cvd)
		*Combine Graphs
		graph combine kd_ethnicity_1_bp_cvd kd_ethnicity_2_bp_cvd kd_ethnicity_3_bp_cvd kd_ethnicity_4_bp_cvd kd_ethnicity_5_bp_cvd, altshrink
		graph export ./output/time_series/cvd_kd_ethnicity_`c'.svg, as(svg) replace
		graph combine ac_ethnicity_1_bp_cvd ac_ethnicity_2_bp_cvd ac_ethnicity_3_bp_cvd ac_ethnicity_4_bp_cvd ac_ethnicity_5_bp_cvd, altshrink
		graph export ./output/time_series/cvd_ac_ethnicity_`c'.svg, as(svg) replace
		graph combine pac_ethnicity_1_bp_cvd pac_ethnicity_2_bp_cvd pac_ethnicity_3_bp_cvd pac_ethnicity_4_bp_cvd pac_ethnicity_5_bp_cvd, altshrink
		graph export ./output/time_series/cvd_pac_ethnicity_bp_cvd.svg, as(svg) replace
log close